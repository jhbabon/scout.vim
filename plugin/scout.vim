if !has("nvim")
  echoerr "[scout.vim][error] scout.vim only works on neovim!"
  finish
endif

if get(g:, "scout_loaded", 0)
  finish
endif

let g:scout_loaded = 1

let g:scout = {
      \ "buffer_id": 0,
      \ "job_id": 0,
      \ "origin_id": 0
      \ }

if !exists("g:scout_find_files_command")
  let g:scout_find_files_command = "find * -type f"
endif

if !exists("g:scout_command")
  let g:scout_command = "scout"
endif

if !executable(g:scout_command)
  echoerr "[scout.vim][error] The command '" . g:scout_command . "' doesn't exist!"
  finish
endif

" Set the main Ex commands
command! ScoutFiles silent call scout#files#run()
command! ScoutBuffers silent call scout#buffers#run()
