function! scout#get_origin_id()
  return exists("*win_getid") ? win_getid() : 0
endfunction

function! scout#open(choices_command, callbacks, title)
  let s:origin_id = scout#get_origin_id()
  let s:command = a:choices_command . " | " . g:scout_command

  let s:instance = {
        \ "parsers": [function("scout#parse")] + a:callbacks.parsers,
        \ "terminators": [function("scout#terminate")] + a:callbacks.terminators,
        \ "on_stdout": function("scout#on_stdout"),
        \ "on_exit": function("scout#on_exit"),
        \ "signal": "open",
        \ "selection": ""
        \}

  " create new split
  exec "botright new"
  let s:job_id = termopen(s:command, s:instance)

  let g:scout.job_id = s:job_id
  let g:scout.origin_id = s:origin_id
  let g:scout.buffer_id = bufnr("")

  call scout#mappings(s:instance)

  call scout#ui(a:title)

  startinsert
endfunction

function! scout#mappings(instance)
  let b:instance = a:instance

  tnoremap <buffer> <c-v> <c-\><c-n>:call scout#signal(b:instance, "vsplit")<cr>
  tnoremap <buffer> <c-x> <c-\><c-n>:call scout#signal(b:instance, "split")<cr>
  tnoremap <buffer> <c-t> <c-\><c-n>:call scout#signal(b:instance, "tab")<cr>
endfunction

function! scout#signal(instance, signal)
  let a:instance.signal = a:signal
  call jobsend(g:scout.job_id, "\n")
endfunction

function! scout#ui(title)
  let b:term_title = "scout > " . a:title
  setlocal statusline=%{b:term_title}
endfunction

function! scout#on_stdout(term_id, data, event) dict
  let self.selection = scout#apply_callbacks(self.parsers, a:data[0], self)
  echom "scout#on_stdout : selection parsed : " . self.selection
endfunction

function! scout#on_exit(term_id, data, event) dict
  call scout#apply_callbacks(self.terminators, self.selection, self)
endfunction

function! scout#parse(selection, ...)
  echom "scout#parse : selection : " . a:selection

  let selection = substitute(a:selection, '[[:cntrl:]]', '', 'g')

  " Remove the escape sequence to change the terminal ^[[1049l
  let selection = substitute(selection, '^[[:escape]]', '', 'g')
  let selection = substitute(selection, '^[?1049l', '', 'g')
  let selection = substitute(selection, '^[?1049h', '', 'g')

  return selection
endfunction

function! scout#terminate(selection, ...)
  echom "scout#terminate : selection : " . a:selection

  call win_gotoid(g:scout.origin_id)
  exec g:scout.buffer_id . "bdelete!"

  let g:scout.buffer_id = 0
  let g:scout.job_id = 0
  let g:scout.origin_id = 0

  return a:selection
endfunction

function! scout#apply_callbacks(callbacks_list, initial_value, extra_argument)
  let acc = a:initial_value
  for Callback in a:callbacks_list[0:]
    let acc = Callback(acc, a:extra_argument)
  endfor

  return acc
endfunction
