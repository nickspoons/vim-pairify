if exists('g:loaded_pairify')
  finish
endif
let g:loaded_pairify = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

let g:pairify = {
\ 'lefts': [ '[', '(', '{', '<', "'", '"', '`' ],
\ 'rights': [ ']', ')', '}', '>', "'", '"', '`' ]
\}

if !exists('g:pairify_map')
  let g:pairify_map = '<C-J>'
endif

let g:pairify_max_lines = get(g:, 'pairify_max_lines', 500)

let g:pairify_default_mapping = get(g:, 'pairify_default_mapping', 1)

inoremap <expr> <silent> <Plug>(pairify-complete) pairify#pairify()

if !hasmapto('<Plug>(pairify-complete)') && maparg(g:pairify_map, 'i') ==# ''
  execute 'imap' g:pairify_map '<Plug>(pairify-complete)'
endif

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim:et:sw=2:sts=2
