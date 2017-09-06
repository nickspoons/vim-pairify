if exists('g:loaded_pairify')
  finish
endif
let g:loaded_pairify = 1

let g:pairify_default_mapping = get(g:, 'pairify_default_mapping', 1)

let g:pairifier_lefts  = [ "[", "(", "{", "<", "'", '"', "`" ]
let g:pairifier_rights = [ "]", ")", "}", ">", "'", '"', "`" ]

function! s:is_already_matched(match, remaining)
  let characters = split(a:remaining, '\zs')
  for char in characters
    if index(g:pairifier_rights, char) >= 0
      return char ==# a:match
    endif
  endfor
endfunction

function! s:pairify()
  let line = getline('.')
  let cchar = line[col('.')-1]
  let pair_match = pairify#find_pair(line[0:col('.')-2])
  let remaining = line[col('.')-1:]
  if s:is_already_matched(pair_match, remaining)
    let newpos = stridx(remaining, pair_match) + 1
    return newpos == len(remaining) ? "\<C-O>A" : "\<C-O>" . newpos . "l"
  else
    return pair_match
  endif
endfunction

inoremap <expr> <silent> <Plug>(pairify-complete) <SID>pairify()

if g:pairify_default_mapping == 1
  imap <C-J> <Plug>(pairify-complete)
endif
