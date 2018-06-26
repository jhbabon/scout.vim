" Use scout to find and open a buffer
"
" Args: options  A dict with the 'search' key.
"   see scout#open() for more info about that option.
function! scout#buffers#run(options)
  let l:callbacks = {
    \ "parsers": [function("scout#buffers#parse")],
    \ "terminators": [function("scout#buffers#terminate")]
  \ }
  let l:options = extend(a:options, { 'callbacks': l:callbacks }, 'keep')

  let l:choices_command = scout#buffers#choices_command()

  call scout#open(l:choices_command, l:options, "buffers")
endfunction

" Internal: Build a command that will print out the list of buffers
"   so scout can use them.
"
" Return: String with the full command to execute in the shell
function! scout#buffers#choices_command()
  let l:list = execute(":ls")
  let l:list = substitute(l:list, "'", "\'", "g")

  return "echo '" . l:list . "'"
endfunction

" Internal: extract buffer number from a line with the format
"   described in the :ls command
"
" Arg: selection  the line selected with scout
"
" Return: String with the number of the buffer to open
function! scout#buffers#parse(selection, ...)
  let selection = substitute(a:selection, '^\s*\(\d\+\).*', '\1', '')

  return selection
endfunction

" Internal: Open the buffer selected with scout
"
" Note: the buffer will be opened in different ways depending on the
"   signal sent to the scout job.
"
" Arg: selection  The number of the buffer selected with scout
" Arg: instance  Dict representing the current job executing scout
"
" Return: the selection
function! scout#buffers#terminate(selection, instance)
  let l:function_name = "scout#buffers#" . a:instance.signal

  if !empty(a:selection) && exists("*" . l:function_name)
    let l:Fn = function(l:function_name)
    call l:Fn(a:selection)
  endif

  return a:selection
endfunction

" Internal: Open a buffer in a vertical split
"
" Arg: buffer_id  the ID of the buffer to open
function! scout#buffers#vsplit(buffer_id)
  execute ":vert sb " . a:buffer_id
endfunction

" Internal: Open a buffer in a horizontal split
"
" Arg: buffer_id  the ID of the buffer to open
function! scout#buffers#split(buffer_id)
  execute ":sb " . a:buffer_id
endfunction

" Internal: Open a buffer in a new tab
"
" Arg: buffer_id  the ID of the buffer to open
function! scout#buffers#tab(buffer_id)
  execute ":tab sb " . a:buffer_id
endfunction

" Internal: Open a buffer in the origin window
"
" The origin window is the window from where scout was called in the first
" place
"
" Arg: buffer_id  the ID of the buffer to open
function! scout#buffers#edit(buffer_id)
  execute ":b " . a:buffer_id
endfunction
