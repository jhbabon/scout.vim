
let g:scout = {
      \ "term_id": 0,
      \ "job_id": 0,
      \ "open": 0,
      \ "origin": 0,
      \ "vim_command": ":e"
      \ }

function! s:ScoutOutput(term_id, data, event) dict
  let self.output = a:data
endfunction

function! s:ScoutExit(term_id, data, event) dict
  let selection = ""
  if a:data == 0
    let selection = self.output[0]

    " Remove any control sequence like ^M (CTRL-M)
    let selection = substitute(selection, '[[:cntrl:]]', '', 'g')

    " Remove the escape sequence to change the terminal ^[[1049l
    let selection = substitute(selection, '[[:escape]]', '', 'g')
    let selection = substitute(selection, '[?1049l', '', 'g')
  endif

  " go back to the origin window
  call win_gotoid(g:scout.origin)
  if !empty(selection)
    exec g:scout.vim_command . " " . selection
  endif

  call s:ScoutCloseTerm()
endfunction

function! s:ScoutCloseTerm()
  if g:scout.open == 1
    exec g:scout.term_id . "bdelete!"
    let g:scout.term_id = 0
    let g:scout.job_id = 0
    let g:scout.open = 0
    let g:scout.origin = 0
  endif
endfunction

function! ScoutVSplit()
  let g:scout.vim_command = ":vsplit"
  call jobsend(g:scout.job_id, "\n")
endfunction

function! ScoutCommand(choice_command, vim_command)
  " get origin window
  let origin = exists('*win_getid') ? win_getid() : 0

  " First create a new split
  exec "botright new"

  " In the new split, create the term
  let s:callbacks = {
        \ 'on_stdout': function('s:ScoutOutput'),
        \ 'on_exit': function('s:ScoutExit')
        \ }
  let job_id = termopen(a:choice_command . ' | scout ', extend({'output': [], 'vim_command': a:vim_command}, s:callbacks))

  let g:scout.term_id = bufnr("")
  let g:scout.job_id  = job_id
  let g:scout.open    = 1
  let g:scout.origin  = origin
  let g:scout.vim_command = ":e"

  " mappings
  tnoremap <buffer> <c-v> <C-\><C-n>:call ScoutVSplit()<cr>

  startinsert
endfunction

" Find all files in all non-dot directories starting in the working directory.
" Fuzzy select one of those. Open the selected file with :e.
nnoremap <leader>f :call ScoutCommand("find * -type f", ":e")<cr>
