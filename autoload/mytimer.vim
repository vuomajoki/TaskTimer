" My timer functions
"

" if exists
"

fu! mytimer#timer_event(timer)
    let cur = localtime()
    let diff = cur-s:mytime
    let s:time_left = s:duration - diff

    if diff >= s:duration && !g:mytimer_done
        call mytimer#done()
        let g:mytimer_done = 1
    endif
    call mytimer#check_time()
endfunction


" fu! mytimer#close()
"     if exists("s:timer_running")
"         unlet s:timer_running
"     endif
"     silent w
"     " Avoid calling twice
"     au! * <buffer> 
"     silent Bdelete 
"     " echo "closed"
" endfu

fu! mytimer#done()
    " Check if buffe exists
    " let bn = bufnr(s:quicknote_file)
    " if bn > 0 
    "     exec "b! ".bn
    " else
    "     exec "e ".s:quicknote_file
    " endif
    "
    call feedkeys("\e")
    " go to buffer
    " maybe save current buffer
    edit ~/doc/quicknote.md
    call airline#parts#define_accent('mytimer', 'red')
    let g:airline_section_y = airline#section#create(['mytimer'])
    AirlineRefresh
    " au! * <buffer> 
    " au BufLeave <buffer> call mytimer#close()
    let lines = ["Time is up ".s:duration,""]
    call append(line("$"),lines)
    normal G$
endfunction

fu! mytimer#check_time()
    " todo format time nicely here
    return "Timer: ".s:time_left
endfunction

fu! mytimer#format_duration(seconds)
    return seconds
endfunction

fu! mytimer#parse_duration(duration)
    return "time" 
endfunction

fu! mytimer#parse_line(line) 
    let hours = 0
    let minutes = 0
    let seconds = 0
    let task = "Task"
    " todo move this part to parse duration
    let idx = match(a:line,"--") 
    if idx > 0
        let list = split(strpart(a:line,idx+2),'\W\+')
        let readNumber = 1
        let number = 0
        for item in list
            if readNumber 
                let number = str2nr(item) 
                let readNumber = 0
            else
                let readNumber = 1
                " equal ignore case
                if item ==? "min" || item ==? "minutes" || item ==? "minute" || item ==? "m"
                    let minutes = number
                elseif item ==? "sec" || item ==? "seconds" || item==? "second" || item ==? "s"
                    let seconds = number
                elseif item ==? "hour" || item ==? "hours" || item ==? "hour" || item ==? "h"
                    let hours = number
                endif
            endif
        endfor
        let task = trim(strpart(a:line,0,idx), " ")
    endif
    let add_minutes = seconds/60
    let seconds = seconds%60
    let minutes = minutes + add_minutes
    let add_hours = minutes/60
    let minutes = minutes%60
    let hours = hours+add_hours
    let totalSeconds = hours*60*60 + minutes*60 + seconds
    let l:time = strftime(s:myformat)
    " let timerstr = hours." hours ".minutes." minutes ".seconds." seconds"
    let timerstr = printf("%02d:%02d:%02d",hours,minutes,seconds)
    let g:timerid = l:time
    let line = "# Timer ".l:time." for: ".timerstr." -- ".task
    " echo line 
    " echo "'".task."'"
    return [totalSeconds,line]
endfu

" maybe at some point add timer
fu! mytimer#star_timer()
    let line = getline(".")
    " let pos = getcurpos()
    let parsed = mytimer#parse_line(line)
    let lines = ["",parsed[1],""]
    call append(line("$"),lines)
    " call setline(pos[1],parsed[1])
    " call setline(pos[1],parsed[1])
    let s:mytime = localtime()
    let s:duration = parsed[0]
    let s:time_left = s:duration 
    let g:mytimer_done = 0
    silent write
    normal G
    " add timer accent
    call AirlineInit()
    AirlineRefresh
endfunction



function! mytimer#new_note() 
    " Todo also current line for the reference
    write
    let l:currentFile = expand("%:p")
    let l:cur = getcurpos()
    let l:rootFile = expand("~/")
    " Test here if current file is readmefile
    " Use above rootfile
    e ~/doc/quicknote.md

    mkview

    let l:time = strftime(s:myformat)
    let l:line = "# QN ".l:time." file:".l:currentFile.":".l:cur[1]
    let mylist = [ "", l:line,""]
    let line = line("$")
    call append(line,mylist)

    loadview
    normal Gzz$
    call feedkeys("a")
endfunction


function! mytimer#go_to_spot() 
    " Todo FindEmptyLine function
    let l:cond = 1 
    let l:cur = getcurpos()
    let l:curLine = l:cur[1]
    while l:cond
        " todo search backwards
        let l:currentLine = getline(l:curLine)
        let l:test = stridx(l:currentLine,"# QN")
        if l:test < 0 || l:test > 5
            let l:curLine = l:curLine - 1
            if l:curLine < 0
                break
            endif
            continue
        endif
        let l:tag = "file:"
        let l:pos1 = stridx(l:currentLine,tag)
        let l:pos2 = stridx(l:currentLine,":",l:pos1+strlen(l:tag))
        let l:file = strpart(l:currentLine,l:pos1+strlen(l:tag),l:pos2-(l:pos1+strlen(l:tag)))
        let l:line = strpart(l:currentLine, l:pos2+1)
        echo "e +".l:line." ".l:file
        exec "e +".l:line." ".l:file
        break
    endwhile
endfunction

fu! mytimer#init_timer()
    let s:mymessage = "Current session is over. Take a break!"
    let s:mywin = -1
    let s:duration = 10
    let s:interval = 1000
    " this is important to set
    let g:mytimer_done = 1
    let s:mytime = localtime()
    let s:mytimer = timer_start(s:interval,"mytimer#timer_event", { "repeat" : -1 })
    let s:myformat = strftime("%Y-%m-%d %H:%M:%S")
    let s:quicknote_file = "~/doc/quicknote.md"
    let s:jump_cursor = [0,0]
    let s:jump_buffer = [0,0]
endfunction

if !exists("s:mytimer")
    call mytimer#init_timer()
endif

call mytimer#init_timer()
