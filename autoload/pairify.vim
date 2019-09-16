function! s:find_pair() abort
  let lnum = line('.')
  let start_from = 1
  if lnum > g:pairifier_max_lines
    let start_from = lnum - g:pairifier_max_lines
    echohl WarningMsg
    echom 'More than max of ' . g:pairifier_max_lines . ' lines before cursor.'
    \ . ' Searching from line ' . start_from
    echohl None
  endif
  let lines = getline(start_from, lnum)
  " Truncate the current line after the cursor position
  let lines[-1] = col('.') == 1 ? '' : lines[-1][:col('.') - 2]
  " New vimscript syntax is so nice:
  " let characters = lines->join()->split('\zs')->reverse()
  let characters = reverse(split(join(lines), '\zs'))

  let stack = []

  let char_len = len(characters)
  for idx in range(char_len)
    let char = characters[idx]
    let lidx = index(g:pairifier_lefts, char)
    let ridx = index(g:pairifier_rights, char)
    if lidx < 0 && ridx < 0
      continue
    endif
    " Remember that characters has been reversed
    let prev = idx <= char_len ? '' : characters[idx + 1]
    let next = idx == 0 ? '' : characters[idx - 1]
    if s:is_equality_or_lambda(char, next, prev)
      continue
    elseif ridx >= 0
      if lidx == ridx && !empty(stack) && stack[-1] ==# char
        call remove(stack, -1)
        continue
      endif
      call add(stack, char)
    elseif lidx >= 0
      if !empty(stack) && stack[-1] ==# g:pairifier_rights[lidx]
        call remove(stack, -1)
      elseif empty(stack)
        return g:pairifier_rights[lidx]
      endif
    endif
  endfor

  let result = get(stack, 0, '')
  return index(g:pairifier_lefts, result) >= 0 ? result : ''
endfunction

function! s:is_already_matched(match, remaining) abort
  let characters = split(a:remaining, '\zs')
  for char in characters
    if index(g:pairifier_rights, char) >= 0
      return char ==# a:match
    endif
  endfor
  return 0
endfunction

" Detect whether the current char is < or > and part of <=, >=, =>, ->
" TODO: Add language-specific string escaping here, to ignore e.g.: \' in
"   'This \'string\''
function! s:is_equality_or_lambda(char, next, prev) abort
  return (a:char ==# '<' && a:next ==# '=')
  \   || (a:char ==# '>' && (a:next ==# '=' || a:prev =~# '[=-]'))
endfunction

function! pairify#pairify() abort
  let pair_match = s:find_pair()
  let remaining = getline('.')[col('.') - 1 :]
  if s:is_already_matched(pair_match, remaining)
    let newpos = stridx(remaining, pair_match) + 1
    return newpos == len(remaining) ? "\<C-O>A" : "\<C-O>" . newpos . 'l'
  else
    return pair_match
  endif
endfunction
