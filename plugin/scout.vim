augroup terminal
        autocmd!
        autocmd TermClose * call s:ScoutCloseTerm()
augroup end

let g:scout = {
      \ "term_id": 0,
      \ "open": 0
      \ }

function! s:ScoutOutput(term_id, data, event) dict
  let self.output = a:data
endfunction

function! s:ScoutExit(term_id, data, event) dict
  if a:data == 0
    let selection = self.output[0]

    " Remove any control sequence like ^M (CTRL-M)
    let selection = substitute(selection, '[[:cntrl:]]', '', 'g')

    " Remove the escape sequence to change the terminal ^[[1049l
    let selection = substitute(selection, '[[:escape]]', '', 'g')
    let selection = substitute(selection, '[?1049l', '', 'g')
    exec self.vim_command . " " . selection
  endif
endfunction

function! s:ScoutCloseTerm()
  if g:scout.open == 1
    echom g:scout.term_id
    exec g:scout.term_id . "bdelete!"
    let g:scout.term_id = 0
    let g:scout.open = 0
  endif
endfunction

function! ScoutCommand(choice_command, vim_command)
  let s:callbacks = {
        \ 'on_stdout': function('s:ScoutOutput'),
        \ 'on_exit': function('s:ScoutExit')
        \ }
  let termid = termopen(a:choice_command . ' | scout ', extend({'output': [], 'vim_command': a:vim_command}, s:callbacks))
  let g:scout.term_id = termid
  let g:scout.open = 1
  startinsert
endfunction

" Find all files in all non-dot directories starting in the working directory.
" Fuzzy select one of those. Open the selected file with :e.
nnoremap <leader>f :call ScoutCommand("find * -type f", ":e")<cr>
