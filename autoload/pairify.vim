function! s:find_pair(string, start_col) abort
  let stack = []
  let characters = split(a:string, '\zs')

  let char_idx = a:start_col
  for char in reverse(characters)
    let char_idx -= 1
    let lidx = index(g:pairifier_lefts, char)
    let ridx = index(g:pairifier_rights, char)
    if <SID>is_equality_or_lambda(a:string, char, char_idx)
      continue
    elseif ridx >= 0
      if !empty(stack) && <SID>is_quote(char) && stack[-1] ==# char
        call remove(stack, -1)
        continue
      endif
      call add(stack, char)
    elseif lidx >= 0
      if !empty(stack) && <SID>is_compliment(char, stack[-1])
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

function! s:is_compliment(char1, char2) abort
  let idx = index(g:pairifier_lefts, a:char1)
  return idx >= 0 ? a:char2 == g:pairifier_rights[idx] : 0
endfunction

" Detect whether the current char is < or > and part of <=, >=, =>, ->
function! s:is_equality_or_lambda(string, char, char_idx) abort
  let ps = a:char_idx == 1
  let pe = a:char_idx <= len(a:string)
  let prev = ps ? '' : a:string[a:char_idx-1]
  let next = pe ? '' : a:string[a:char_idx+1]
  return (a:char ==# '<' && next ==# '=') ||
  \ (a:char ==# '>' && (next ==# '=' || prev ==# '=' || prev ==# '-'))
endfunction

function! s:is_quote(char) abort
  return a:char ==# "'" || a:char ==# '"' || a:char ==# "`"
endfunction

function! pairify#pairify() abort
  let line = getline('.')
  let idx = col('.')-1
  let cchar = line[idx]
  let pair_match = <SID>find_pair(line[0:idx-1], idx)
  let remaining = line[col('.')-1:]
  if <SID>is_already_matched(pair_match, remaining)
    let newpos = stridx(remaining, pair_match) + 1
    return newpos == len(remaining) ? "\<C-O>A" : "\<C-O>" . newpos . "l"
  else
    return pair_match
  endif
endfunction
