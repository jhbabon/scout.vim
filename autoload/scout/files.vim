function! scout#files#run()
  let s:callbacks = {
        \ 'parsers': [function('scout#files#parse')],
        \ 'terminators': [function('scout#files#terminate')]
        \ }

  call scout#open(g:scout_find_files_command, s:callbacks)
endfunction

function! scout#files#parse(selection, ...)
  echom "scout#files#parse : selection : " . a:selection

  return a:selection
endfunction

function! scout#files#terminate(selection, instance)
  echom "scout#files#terminate : selection : " . a:selection

  let signal = a:instance.signal

  if !empty(a:selection)
    if signal == "vsplit"
      exec ":vsplit " . a:selection
    elseif signal == "split"
      exec ":split " . a:selection
    elseif signal == "tab"
      exec ":tab split " . a:selection
    else
      exec ":e " . a:selection
    endif
  endif

  return a:selection
endfunction
