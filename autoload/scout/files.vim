function! scout#files#run()
  let l:callbacks = {
        \ 'parsers': [],
        \ 'terminators': [function('scout#files#terminate')]
        \ }

  call scout#open(g:scout_find_files_command, l:callbacks, "files")
endfunction

function! scout#files#terminate(selection, instance)
  echom "scout#files#terminate : selection : " . a:selection

  let l:function_name = "scout#files#" . a:instance.signal

  if !empty(a:selection) && exists("*" . l:function_name)
    let l:Fn = function(l:function_name)
    call l:Fn(a:selection)
  endif

  return a:selection
endfunction

function! scout#files#vsplit(filename)
  execute ":vsplit " . a:filename
endfunction

function! scout#files#split(filename)
  execute ":split " . a:filename
endfunction

function! scout#files#tab(filename)
  execute ":tab split " . a:filename
endfunction

function! scout#files#edit(filename)
  execute ":e " . a:filename
endfunction
