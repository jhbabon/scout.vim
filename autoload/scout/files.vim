" Use scout to find a file to edit
"
" Args: options  A dict with the 'search' key.
"   see scout#open() for more info about that option.
function! scout#files#run(options)
  let l:callbacks = {
    \ 'parsers': [],
    \ 'terminators': [function('scout#files#terminate')]
  \ }
  let l:options = extend(a:options, { 'callbacks': l:callbacks }, 'keep')

  call scout#open(g:scout_find_files_command, l:options, "files")
endfunction

" Internal: Open the file selected with scout
"
" Note: the file will be opened in different ways depending on the
"   signal sent to the scout job.
"
" Arg: selection  The name of the file selected with scout
" Arg: instance  Dict representing the current job executing scout
"
" Return: the selection
function! scout#files#terminate(selection, instance)
  let l:function_name = "scout#files#" . a:instance.signal

  if !empty(a:selection) && exists("*" . l:function_name)
    let l:Fn = function(l:function_name)
    call l:Fn(a:selection)
  endif

  return a:selection
endfunction

" Internal: Open a file in a new vertical split
"
" Arg: filename  the name of the file to open
function! scout#files#vsplit(filename)
  execute ":vsplit " . a:filename
endfunction

" Internal: Open a file in a new split
"
" Arg: filename  the name of the file to open
function! scout#files#split(filename)
  execute ":split " . a:filename
endfunction

" Internal: Open a file in a new tab
"
" Arg: filename  the name of the file to open
function! scout#files#tab(filename)
  execute ":tab split " . a:filename
endfunction

" Internal: Open a file in the origin window
"
" The origin window is the window from where scout was called in the first
" place
"
" Arg: filename  the name of the file to open
function! scout#files#edit(filename)
  execute ":e " . a:filename
endfunction
