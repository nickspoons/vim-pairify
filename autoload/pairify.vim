function! s:is_compliment(char1, char2)
  let idx = index(g:pairifier_lefts, a:char1)
  if idx >= 0
    return a:char2 == g:pairifier_rights[idx]
  endif
endfunction

function! s:is_quote(char)
  return a:char ==# "'" || a:char ==# '"' || a:char ==# "`"
endfunction

function! pairify#find_pair(string)
  let stack = []
  let characters = split(a:string, '\zs')

  for char in reverse(characters)
    let lidx = index(g:pairifier_lefts, char)
    let ridx = index(g:pairifier_rights, char)
    if ridx >= 0
      if !empty(stack) && s:is_quote(char) && stack[-1] ==# char
        call remove(stack, -1)
        continue
      endif
      call add(stack, char)
    elseif lidx >= 0
      if !empty(stack) && s:is_compliment(char, stack[-1])
        call remove(stack, -1)
      elseif empty(stack)
        return g:pairifier_rights[lidx]
      endif
    endif
  endfor

  let result = get(stack, 0, '')
  return index(g:pairifier_lefts, result) >= 0 ? result : ''
endfunction
