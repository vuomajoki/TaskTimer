" My timer functions
"

" if exists
"

fu! mytimer#timer_event(timer)
    let cur = localtime()
    let diff = cur-s:mytime
    " echo "tidii ".s:done." ".s:duration." ".diff
    if diff >= s:duration && !s:done
        call mytimer#done()
        let s:done = 1
    endif
    call mytimer#check_time()
endfunction




fu! mytimer#close()
    if exists("s:timer_running")
        unlet s:timer_running
    endif
    silent w
    " Avoid calling twice
    au! * <buffer> 
    silent Bdelete 
    " echo "closed"
endfu


fu! mytimer#done()
    " move from insert mode
    call feedkeys("\e")
    edit ~/doc/quicknote.md

    " Find where thing was started
    " with search

    call airline#parts#define_accent('mytimer', 'red')
    let g:airline_section_y = airline#section#create(['mytimer'])
    AirlineRefresh

    " au! * <buffer> 
    " au BufLeave <buffer> call mytimer#close()
    let lines = ["Time is up ".s:duration,""]
    " call appendbufline(cool,0,lines)
    call append(line("$"),lines)
    normal G$
endfunction

fu! mytimer#check_time()
    "    echo diff
    let cur = localtime()
    let diff = cur-s:mytime
    let left = s:duration - diff
    " add here different message after done
    " Todo make conditional here
    if diff >= s:duration || s:done
        return "Done: ".left
        let s:done = 1
    endif
    return "Timer: ".left
endfunction

fu! mytimer#parse_line(line) 
    " This is line for timer. Time: 4 min 40 s
    let idx = match(a:line,"\\ctime:") 
    let hours = 0
    let minutes = 0
    let seconds = 0
    if idx >= 0
        let list = split(strpart(a:line,idx+5)," ",'\W\+')
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
    endif
    let add_minutes = seconds/60
    let seconds = seconds%60
    let minutes = minutes + add_minutes
    let add_hours = minutes/60
    let minutes = minutes%60
    let hours = hours+add_hours
    
    let timerstr = hours." hours ".minutes." minutes ".seconds." seconds"
    echo timerstr
endfu


fu! mytimer#star_timer()
    " ask task
    " set current timestamp
    "
    let bn = bufnr(s:quicknote_file)
    if bn > 0 
        exec "b ".bn
    else
        exec "e ".s:quicknote_file
    endif
    return 
    redraw
    " Get the curren line:  

    let line = getline(".")
    
    " split line

    let in = input("How many seconds to set the timer? (".s:duration.") ")
    if in!= ""
       let s:duration = eval(in) 
    endif
    redraw
    echo "Timer set to ".s:duration." seconds"
    " this is important that things will end
    let s:done = 0
    if !exists("s:mytimer")
    endif
    call AirlineInit()
    AirlineRefresh
    let s:mytime = localtime()
    let s:timer_running = 0
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

    let l:time = strftime(s:myformat)
    let l:line = "# QN ".l:time." file:".l:currentFile.":".l:cur[1]
    let mylist = [ "", l:line,""]
    let line = line("$")
    call append(line,mylist)
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
    let s:done = 1
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
