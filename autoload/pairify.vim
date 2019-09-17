function! s:find_pair() abort
  let lnum = line('.')
  let start_from = 1
  if lnum > g:pairify_max_lines
    let start_from = lnum - g:pairify_max_lines
    echohl WarningMsg
    echom 'More than max of ' . g:pairify_max_lines . ' lines before cursor.'
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
    let lidx = index(g:pairify.lefts, char)
    let ridx = index(g:pairify.rights, char)
    if lidx < 0 && ridx < 0
      continue
    endif
    " Remember that characters has been reversed
    let prev = idx >= char_len ? '' : characters[idx + 1]
    let next = idx == 0 ? '' : characters[idx - 1]
    if s:ignore(char, next, prev)
      continue
    elseif ridx >= 0
      if lidx == ridx && !empty(stack) && stack[-1] ==# char
        call remove(stack, -1)
        continue
      endif
      call add(stack, char)
    elseif lidx >= 0
      if !empty(stack) && stack[-1] ==# g:pairify.rights[lidx]
        call remove(stack, -1)
      elseif empty(stack)
        return g:pairify.rights[lidx]
      endif
    endif
  endfor

  let result = get(stack, 0, '')
  return index(g:pairify.lefts, result) >= 0 ? result : ''
endfunction

" Detect whether the current char is < or > and part of <=, >=, =>, ->, or has
" whitespace around it (`<cast_in_typescript>` is paired, `4 < 5` is not).
" TODO: Add language-specific string escaping here, to ignore e.g.: \' in
"   'This \'string\''
function! s:ignore(char, next, prev) abort
  return (a:char ==# '<' && a:next =~# '[ =]')
  \   || (a:char ==# '>' && (a:next ==# '=' || a:prev =~# '[ =-]'))
endfunction

function! pairify#pairify() abort
  let pair_match = s:find_pair()
  let pat = '[' . substitute(join(g:pairify.rights, ''), ']', '\\]', '') . ']'
  let m_col = matchstrpos(getline('.'), pat, col('.') - 1)[1]
  if m_col >= col('.') - 1 && strpart(getline('.'), m_col, 1) ==# pair_match
    return "\<C-o>:call cursor(" . line('.') . ',' . (m_col + 2) . ")\<CR>"
  else
    return pair_match
  endif
endfunction
