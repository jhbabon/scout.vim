function! scout#buffers#run()
  let s:callbacks = {
        \ "parsers": [function("scout#buffers#parse")],
        \ "terminators": [function("scout#buffers#terminate")]
        \ }

  let s:choices_command = scout#buffers#choices_command()

  call scout#open(s:choices_command, s:callbacks)
endfunction

function! scout#buffers#choices_command()
  let s:list = execute(":ls")
  let s:list = substitute(s:list, "'", "\'", "g")

  return "echo '" . s:list . "'"
endfunction

function! scout#buffers#parse(selection, ...)
  let selection = substitute(a:selection, '^\(\d\+\).*', '\1', '')
  echom "scout#buffers#parse : selection : " . selection

  return selection
endfunction

function! scout#buffers#terminate(selection, instance)
  echom "scout#buffers#terminate : selection : " . a:selection

  let signal = a:instance.signal

  if !empty(a:selection)
    if signal == "vsplit"
      exec ":vert sb " . a:selection
    elseif signal == "split"
      exec ":sb " . a:selection
    elseif signal == "tab"
      exec ":tab sb " . a:selection
    else
      exec ":b " . a:selection
    endif
  endif

  return a:selection
endfunction
