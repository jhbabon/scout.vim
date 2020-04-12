if !has("nvim")
  echoerr "[scout.vim][error] scout.vim only works on neovim!"
  finish
endif

if get(g:, "scout_loaded", 0)
  finish
endif

let g:scout_loaded = 1

if !exists("g:scout_window_type")
  let g:scout_window_type = "split"
else
  if g:scout_window_type == 'floating' && !has('nvim-0.4')
    echomsg "[scout.vim][warning] floating window option only works on neovim >= 0.4!"
    echomsg "[scout.vim][warning] reverting option to 'split'"
    let g:scout_window_type = "split"
  endif
endif

let g:scout_version = "v2.1.0"

if !exists("g:scout_find_files_command")
  let g:scout_find_files_command = "find * -type f"
endif

if !exists("g:scout_command")
  let g:scout_command = "scout"
endif

if !exists("g:scout_size")
  let g:scout_size = ""
endif

if !executable(g:scout_command)
  echoerr "[scout.vim][error] The command '" . g:scout_command . "' doesn't exist!"
  finish
endif

" Set the main Ex commands
command! -nargs=? ScoutFiles silent call scout#files#run({ 'search': expand(<q-args>) })
command! -nargs=? ScoutBuffers silent call scout#buffers#run({ 'search': expand(<q-args>) })
command! ScoutVersion :echo "scout.vim " . g:scout_version
