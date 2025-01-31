" editerm.vim - 
" Maintainer:   kyoh86

if exists('g:loaded_editerm')
  finish
endif
let g:loaded_editerm = 1

let s:save_cpo = &cpo
set cpo&vim

let s:remotes={}

function! s:kill_remote()
  let l:bufnr = bufnr('%')
  call s:release_remote(l:bufnr, '1')
  execute(l:bufnr .. 'bwipeout!')
endfunction

function! s:leave_remote()
  call s:release_remote(expand('<abuf>')+0, '0')
endfunction

function! s:release_remote(bufnum, ret)
  " lockfile for the buffer
  let l:locker = get(s:remotes, a:bufnum, '')

  if l:locker != ''
    " delete lockfile
    call writefile([a:ret], l:locker)

    unlet s:remotes[a:bufnum]
  endif
endfunction

function! s:open_buffer(filename)
  execute('new '.a:filename)
  setlocal bufhidden=wipe
  command -buffer Cq :call <SID>kill_remote()
  command -buffer CQ :call <SID>kill_remote()
  return bufnr('%')
endfunction

" Function: Tapi_EditermEditFile
" Description: It should be called from :terminal with two parameters
" [(lock file), (editing file)] as $EDITOR.
function! Tapi_EditermEditFile(bufnum, arglist)
  if len(a:arglist) == 2
    let l:locker = a:arglist[0]
    let l:bufnum = s:open_buffer(a:arglist[1])
    let s:remotes[l:bufnum] = l:locker
    augroup EDITERM
      autocmd! * <buffer>
      autocmd BufUnload <buffer> :call <SID>leave_remote()
    augroup END
  endif
endfunction

let $EDITOR=expand('<sfile>:p:h') . '/tvim'

let &cpo = s:save_cpo
unlet s:save_cpo
