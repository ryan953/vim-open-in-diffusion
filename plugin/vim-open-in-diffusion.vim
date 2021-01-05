scriptencoding utf-8

if exists('g:loaded_open_in_diffusion')
    finish
endif
let g:loaded_open_in_diffusion = 1

let g:open_in_diffusion_default_branch = get(g:, 'open_in_diffusion_default_branch', 'main')

function! s:rmLeadingSlash(in) abort
    return substitute(a:in, '^/', '', '')
endfunction

function! s:rmTrailingSlash(in) abort
    return substitute(a:in, '/$', '', '')
endfunction

function! s:getNearestArcConfig() abort
    let l:path = findfile('.arcconfig', '.;')
    if filereadable(l:path)
        return json_decode(join(readfile(l:path)))
    else
        throw 'missing-arcconfig'
    endif
endfunction

function! s:getPhabProjectFile() abort
    return expand('%')
endfunction

function! s:getPhabFileRange() abort
    if mode() == 'v'
        let [line_start] = getpos('v')[1:1]
        let [line_end] = getpos('.')[1:1]
        return printf('$%s-%s', line_start, line_end)
    else
        let [cursor] = getpos('.')[1:1]
        let [line_start] = getpos("'<")[1:1]
        if cursor != line_start
            return printf('$%s', cursor)
        else
            let [line_end] = getpos("'>")[1:1]
            return printf('$%s-%s', line_start, line_end)
        endif
    endif
endfunction

function! s:getPhabUrl(branch) abort
    let l:url_format = '%s/diffusion/%s/browse/%s/%s%s'
    let l:arcconfig = s:getNearestArcConfig()
    let l:domain = s:rmTrailingSlash(l:arcconfig['phabricator.uri'])
    let l:callsign = s:rmLeadingSlash(s:rmTrailingSlash(l:arcconfig['repository.callsign']))
    let l:branch = a:branch
    let l:projectFile = s:rmLeadingSlash(s:getPhabProjectFile())
    let l:lineRange = s:getPhabFileRange()

    return printf(l:url_format, l:domain, l:callsign, l:branch, l:projectFile, l:lineRange)
endfunction

function! GetPhabUrl(...) abort
    return s:getPhabUrl(get(a:, 1, g:open_in_diffusion_default_branch))
endfunction

function! GetPhabUrlSafe(...) abort
    try
        return s:getPhabUrl(get(a:, 1, g:open_in_diffusion_default_branch))
    catch /missing-arcconfig/
        return 'Error: Cannot find parent .arcconfig file.'
    catch /phabricator\.uri/
        return 'Error: Missing phabricator.uri in .arcconfig'
    catch /phabricator\.callsign/
        return 'Error: Missing phabricator.callsign in .arcconfig'
    catch
        return 'Error: Something went wrong'
    endtry
endfunction
