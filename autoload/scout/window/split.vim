" Internal: Open a new split window at the bottom of the page
"
" It uses the global value g:scout_size to set the size
"
" Return: Dict with the id of the buffer and a window restoration command
function! scout#window#split#open()
  let l:winres = [winrestcmd(), &lines, winnr('$')]

  exec printf("botright%s new", g:scout_size)

  return { "buffer_id": bufnr(""), "winres": l:winres }
endfunction

" Internal: Close the split window
"
" Arg: config  Dict with the keys returned by the 'open()' function.
function! scout#window#split#close(config)
  exec a:config.buffer_id . "bwipeout!"

  if a:config.winres[1] >= &lines && a:config.winres[2] == winnr('$')
    execute a:config.winres[0].a:config.winres[0]
  endif
endfunction

" Internal: Set the title in the statusline
"
" Arg: title  String
function! scout#window#split#decorate(title, ...)
  let b:term_title = "scout > " . a:title
  setlocal statusline=%{b:term_title}
endfunction
