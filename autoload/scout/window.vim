" Internal: Open a new window to interact with scout
"
" Arg: options  Dict with the key 'type'. Valid values are 'split', for
"   a split window, or 'floating', for a floating window.
"
" Return: Dict with the keys 'type' (as before) and 'config', which is a
"   dict that depends on the 'type' of window created. It will hold
"   information specific to the type of window.
function! scout#window#open(options)
  let l:type = a:options.type " TODO ensure type by checking neovim version
  let l:Func = s:impl(l:type, 'open')

  let l:config = Func()

  return { 'type': l:type, 'config': l:config }
endfunction

" Internal: Close the given window
"
" Arg: window  Dict with the 'type' and 'config' keys returned by the
" 'open()' function.
function! scout#window#close(window)
  let l:type = a:window.type
  let l:Func = s:impl(l:type, 'close')

  call l:Func(a:window.config)
endfunction

" Internal: Decorate the window with a title
"
" Arg: window  Dict with the 'type' and 'config' keys returned by the
" 'open()' function.
"
" Arg: title  A string
function! scout#window#decorate(window, title)
  let l:type = a:window.type
  let l:Func = s:impl(l:type, 'decorate')

  call l:Func(a:title, a:window.config)
endfunction

" Internal: Terminate the current window using the main termination sequence,
"   after scout exits
"
" Arg: selection  String. The selection from scout
"
" Arg: instance  Dict. Current instance with the execution context (job id,
"   window information, etc)
"
" Return: String with the selection unchanged
function! scout#window#terminate(selection, instance)
  call scout#window#close(a:instance.window)

  return a:selection
endfunction

function! s:impl(type, func_name)
  return function('scout#window#' . a:type . '#' . a:func_name)
endfunction
