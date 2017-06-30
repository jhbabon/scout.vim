function! scout#buffers#run()
  let l:callbacks = {
        \ "parsers": [function("scout#buffers#parse")],
        \ "terminators": [function("scout#buffers#terminate")]
        \ }

  let l:choices_command = scout#buffers#choices_command()

  call scout#open(l:choices_command, l:callbacks, "buffers")
endfunction

function! scout#buffers#choices_command()
  let l:list = execute(":ls")
  let l:list = substitute(l:list, "'", "\'", "g")

  return "echo '" . l:list . "'"
endfunction

function! scout#buffers#parse(selection, ...)
  let selection = substitute(a:selection, '^\(\d\+\).*', '\1', '')
  echom "scout#buffers#parse : selection : " . selection

  return selection
endfunction

function! scout#buffers#terminate(selection, instance)
  echom "scout#buffers#terminate : selection : " . a:selection

  let l:function_name = "scout#buffers#" . a:instance.signal

  if !empty(a:selection) && exists("*" . l:function_name)
    let l:Fn = function(l:function_name)
    call l:Fn(a:selection)
  endif

  return a:selection
endfunction

function! scout#buffers#vsplit(filename)
  execute ":vert sb " . a:filename
endfunction

function! scout#buffers#split(filename)
  execute ":sb " . a:filename
endfunction

function! scout#buffers#tab(filename)
  execute ":tab sb " . a:filename
endfunction

function! scout#buffers#edit(filename)
  execute ":b " . a:filename
endfunction
