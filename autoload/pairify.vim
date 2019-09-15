function! s:find_pair(string, start_col) abort
  let stack = []
  let characters = split(a:string, '\zs')

  let char_idx = a:start_col
  for char in reverse(characters)
    let char_idx -= 1
    let lidx = index(g:pairifier_lefts, char)
    let ridx = index(g:pairifier_rights, char)
    if s:is_equality_or_lambda(a:string, char, char_idx)
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
function! s:is_equality_or_lambda(string, char, char_idx) abort
  if a:char !~# '[<>]' | return 0 | endif
  let prev = a:char_idx == 1 ? '' : a:string[a:char_idx - 1]
  let next = a:char_idx <= len(a:string) ? '' : a:string[a:char_idx + 1]
  return (a:char ==# '<' && next ==# '=')
  \   || (a:char ==# '>' && (next ==# '=' || prev =~# '[=-]'))
endfunction

function! pairify#pairify() abort
  let line = getline('.')
  let idx = col('.')-1
  let pair_match = s:find_pair(line[:idx-1], idx)
  let remaining = line[idx :]
  if s:is_already_matched(pair_match, remaining)
    let newpos = stridx(remaining, pair_match) + 1
    return newpos == len(remaining) ? "\<C-O>A" : "\<C-O>" . newpos . 'l'
  else
    return pair_match
  endif
endfunction
