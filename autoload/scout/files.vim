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

function! scout#files#terminate(selection, ...)
  echom "scout#files#terminate : selection : " . a:selection

  if !empty(a:selection)
    exec ":e " . a:selection
  endif

  return a:selection
endfunction
