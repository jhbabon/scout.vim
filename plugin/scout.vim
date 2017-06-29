if !has("nvim") || get(g:, "scout_loaded", 0)
  finish
endif

let g:scout_loaded = 1

let g:scout = {
      \ "buffer_id": 0,
      \ "job_id": 0,
      \ "origin_id": 0
      \ }

if !exists("g:scout_command")
  let g:scout_command = "scout"
end

if !exists("g:scout_find_files_command")
  let g:scout_find_files_command = "find * -type f"
end

" Set the main neovim Ex commands
command! ScoutFiles call scout#files#run() " remove silent for debugging
command! ScoutBuffers call scout#buffers#run() " remove silent for debugging
" command! ScoutFiles silent call scout#files#run() " remove silent for debugging
