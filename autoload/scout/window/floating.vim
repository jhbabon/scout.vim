" Internal: Get the options for the main window for nvim_open_win function
"
" Return: Dict
function! s:display_options()
  let l:width = &columns * 2 /3
  let l:width = l:width < 1 ? 1 : l:width
  let l:height = &lines * 1 / 3
  let l:height = l:height < 1 ? 1 : l:height
  let l:row = (&lines - l:height) / 2
  let l:col = (&columns - l:width) / 2

  let l:options = {
    \ "relative": "editor",
    \ "style": "minimal",
    \ "width": l:width,
    \ "height": l:height,
    \ "row": l:row,
    \ "col": l:col
  \}

  return l:options
endfunction

" Internal: Get the options for the title window for nvim_open_win function
"
" Arg: display_options  Dict
"
" Return: Dict
function! s:title_options(display_options)
  let l:width = a:display_options.width
  let l:height = 1
  let l:row = a:display_options.row + a:display_options.height
  let l:col = a:display_options.col

  let l:options = {
    \ "relative": "editor",
    \ "style": "minimal",
    \ "width": l:width,
    \ "height": l:height,
    \ "row": l:row,
    \ "col": l:col
  \}

  return l:options
endfunction

" Internal: Open a new set of floating windows to present scout terminal
"
" There are two windows, one with the terminal output and another with the
" title, as a statusline
"
" Example:
"
"        -------------------------------
"        | 1 > abc                     |
"        | abcd                        |
"        | abcdf                       |
"        |                             |
"        |                             |
"        -------------------------------
"        | scout > files               |
"        -------------------------------
"
" Return: Dict with the ids of the buffers and windows created so they can be
"   cleaned up later
function! scout#window#floating#open()
  let l:display_options = s:display_options()
  let l:title_options = s:title_options(l:display_options)

  let l:title_buffer = nvim_create_buf(v:false, v:true)
  let l:title_id = nvim_open_win(l:title_buffer, v:false, l:title_options)

  let l:display_buffer = nvim_create_buf(v:false, v:true)
  let l:display_id = nvim_open_win(l:display_buffer, v:true, l:display_options)

  " Use the signcolumn as a left margin so the list has some space
  let l:signcolumn = 'yes:1'

  " Add a little spacing before the lines with the signcolumn
  call setwinvar(l:title_id, '&winhl', 'Normal:StatusLine,SignColumn:StatusLine')
  call setbufvar(l:title_buffer, '&signcolumn', l:signcolumn)
  call setwinvar(l:display_id, '&winhl', 'Normal:Pmenu,SignColumn:Pmenu')
  call setbufvar(l:display_buffer, '&signcolumn', l:signcolumn)

  return {
    \ "display_buffer": l:display_buffer,
    \ "display_id": l:display_id,
    \ "title_buffer": l:title_buffer,
    \ "title_id": l:title_id,
  \}
endfunction

" Internal: Close all the existing floating windows
"
" Arg: config  Dict with the keys returned by the 'open()' function.
function! scout#window#floating#close(config)
  call nvim_win_close(a:config.title_id, v:true)
  call nvim_win_close(a:config.display_id, v:true)
endfunction

" Internal: Add the text to the title window
"
" Arg: title  String
"
" Arg: config  Dict with the keys returned by the 'open()' function.
function! scout#window#floating#decorate(title, config)
  let l:title = "scout > " . a:title
  call nvim_buf_set_lines(a:config.title_buffer, 0, -1, 0, [l:title])
endfunction
