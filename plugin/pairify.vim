if exists('g:loaded_pairify')
  finish
endif
let g:loaded_pairify = 1

let g:pairifier_lefts  = [ "[", "(", "{", "<", "'", '"', "`" ]
let g:pairifier_rights = [ "]", ")", "}", ">", "'", '"', "`" ]

let g:pairify_default_mapping = get(g:, 'pairify_default_mapping', 1)

inoremap <expr> <silent> <Plug>(pairify-complete) pairify#pairify()

if g:pairify_default_mapping == 1
  imap <C-J> <Plug>(pairify-complete)
endif
