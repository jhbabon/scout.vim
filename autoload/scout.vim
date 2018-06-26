let s:new_tty = '?1049h'
let s:return_tty = '?1049l'

" Open a new scout buffer
"
" Arg: choices_command  The command that needs to be executed to get the
"   list of choices for scout. This command will be piped to scout.
"
" Arg: options  A dict with all possible options for scout. The expected
"   keys are 'search' and 'callbacks' (see below).
"
" Arg: options.search  Scout can take a initial term to start filtering
"   the list of choices with it. It can take that term with the '-s' option.
"   With this option, options.search, you can pass this initial term to
"   scout so the buffer will start filtering the choices with it right away.
"   If the string is empty it will start with all the choices.
"
" Arg: options.callbacks  A dict with the keys 'parsers' and 'terminators',
"   both lists of funcrefs that will be exectuted during the on_stdout and
"   on_exit events as described in the job-control documentation.
"
"   For the on_stdout event the 'parsers' callbacks will be used.
"   These callbacks will operate over the output of scout
"   (e.g: cleaning any special char).
"
"   For the on_exit event the 'terminators' callbacks will be used.
"   These callbacks will operate once scout has finished. They are used
"   to open buffers or new windows.
"
"   These functions (i.e: all the parsers) will be executed one after
"   another and they will receive the output of the previous function.
"   The arguments are the current scout selection and a dict representing
"   the job executing scout in a terminal buffer.
"
" Arg: title  What is the title to put in the statusline of the buffer
function! scout#open(choices_command, options, title)
  let l:origin_id = scout#get_origin_id()
  let l:defaults = {
    \ 'search': '',
    \ 'callbacks': {
      \ 'parsers': [],
      \ 'terminators': [],
    \ }
  \}
  let l:options = extend(a:options, l:defaults, 'keep')
  let l:search = scout#search_option(l:options.search)

  let l:command = a:choices_command . " | " . g:scout_command . l:search

  let l:instance = {
    \ "parsers": [function("scout#parse")] + l:options.callbacks.parsers,
    \ "terminators": [function("scout#terminate")] + l:options.callbacks.terminators,
    \ "on_stdout": function("scout#on_stdout"),
    \ "on_exit": function("scout#on_exit"),
    \ "signal": "edit",
    \ "selection": "",
    \ "raw_output": "",
    \ "collect_output": v:false
  \}

  let l:winres = [winrestcmd(), &lines, winnr('$')]

  " create new split
  exec printf("botright%s new", g:scout_size)
  let l:job_id = termopen(l:command, l:instance)

  let g:scout.job_id = l:job_id
  let g:scout.origin_id = l:origin_id
  let g:scout.buffer_id = bufnr("")
  let g:scout.winres = l:winres

  call scout#mappings(l:instance)
  call scout#ui(a:title)
endfunction

" Internal: Build the search option for scout from a given string.
"
" Arg: term  The string to be searched. It can be an empty string.
"   The string will be expanded with the expand() function so it can
"   contain valid VIM expand() expressions.
"
" Return: A string with the search argument for scout. It will be
"   empty if there is nothing to search.
function! scout#search_option(term)
  if empty(a:term) == 0 " empty returns 1 if is true ¯\_(ツ)_/¯
    let l:search = " -s " . expand(a:term)
  else
    let l:search = ""
  endif

  return l:search
endfunction

" Internal: Get the the ID of the calling window
"
" Return: N (a number representing the ID) or 0
function! scout#get_origin_id()
  return exists("*win_getid") ? win_getid() : 0
endfunction

" Internal: Set the mappings on the terminal buffer so it's possible to
" press <c-?> sequences to send custom signals.
"
" The signals are:
"
" - <c-v> for 'vsplit'
" - <c-x> for 'split'
" - <c-t> for 'tab'
"
" Arg: instance  Dict representing the current job executing scout
function! scout#mappings(instance)
  let b:instance = a:instance

  tnoremap <buffer> <c-v> <c-\><c-n>:call scout#signal(b:instance, "vsplit")<cr>
  tnoremap <buffer> <c-x> <c-\><c-n>:call scout#signal(b:instance, "split")<cr>
  tnoremap <buffer> <c-t> <c-\><c-n>:call scout#signal(b:instance, "tab")<cr>
endfunction

" Internal: Set the given signal to the instance and
"   send a termination sequence ("\n") to scout so
"   it finish its job
"
" Arg: instance  Dict representing the current job executing scout
" Arg: signal  String with the signal triggered by the user
function! scout#signal(instance, signal)
  let a:instance.signal = a:signal
  call jobsend(g:scout.job_id, "\n")
endfunction

" Set UI elements, like the title and the statusline
"
" Arg: title  The title of the scout job
function! scout#ui(title)
  let b:term_title = "scout > " . a:title
  setlocal statusline=%{b:term_title}

  " Ensure that we can type things in scout right away
  startinsert
endfunction

" Internal: callback executed whenever scout prints something out.
"
" We will collect scout output but only the output printed to the
" original TTY
function! scout#on_stdout(term_id, data, event) dict
  if self.collect_output || match(a:data[0], s:return_tty) != -1
    let self.collect_output = v:true
    let self.raw_output .= a:data[0]
  endif
endfunction

" Internal: callback executed whenever scout exits.
"
" This callback will first execute all the defined parsers in order to
" process the output of scout. This could mean to remove special chars
" or to transform a complex line into the argument needed to open a new
" buffer.
"
" Then it will execute all the defined terminators in order to
" perform an action with the choice selected with scout, like opening
" a file in a new window or tab.
function! scout#on_exit(term_id, data, event) dict
  if a:data == 0
    let l:output = split(self.raw_output, s:return_tty)
    let self.selection = scout#apply_callbacks(self.parsers, l:output[1], self)
  else
    " Scout had an error, so we remove any selection to prevent
    " any processing
    let self.selection = ""
  endif

  let self.raw_output = "" " reset the global raw registry
  let self.collect_output = v:false

  call scout#apply_callbacks(self.terminators, self.selection, self)
endfunction

" Internal: Clean up any special chararacter from the output
"
" This parse function is the first to be executed.
"
" Arg: selection  the selection from scout
"
" Return: String with the selection cleaned up
function! scout#parse(selection, ...)
  " This removes things like <C-M> chars.
  let selection = substitute(a:selection, '[[:cntrl:]]', '', 'g')

  " Remove the escape sequence to change the terminal ^[[1049l
  let selection = substitute(selection, '^[[:escape]]', '', 'g')
  let selection = substitute(selection, '^[' . s:return_tty, '', 'g')
  let selection = substitute(selection, '^[' . s:new_tty, '', 'g')

  return selection
endfunction

" Internal: Close the terminal buffer and reset all IDs after
"   scout exits
"
" This terminate function is the first to be executed.
"
" Arg: selection  the selection from scout
"
" Return: String with the selection unchanged
function! scout#terminate(selection, ...)
  call win_gotoid(g:scout.origin_id)
  exec g:scout.buffer_id . "bwipeout!"

  let g:scout.buffer_id = 0
  let g:scout.job_id = 0
  let g:scout.origin_id = 0

  if g:scout.winres[1] >= &lines && g:scout.winres[2] == winnr('$')
    execute g:scout.winres[0].g:scout.winres[0]
  endif

  return a:selection
endfunction

" Internal: This is a reduce function. It will call each callback from
"   a list with the result of the previous call.
"
" Arg: callbacks_list  List of funcrefs, the callbacks
" Arg: initial_value   The first value to use to start the iteration
" Arg: extra_argument  other argument to use when calling a callback
"
" Return: the value returned by the last callback, the accumulation.
function! scout#apply_callbacks(callbacks_list, initial_value, extra_argument)
  let acc = a:initial_value
  for Callback in a:callbacks_list[0:]
    let acc = Callback(acc, a:extra_argument)
  endfor

  return acc
endfunction
