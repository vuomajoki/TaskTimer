" My timer functions

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

fu! mytimer#done()
    call system("afplay ~/Documents/bell.mp3 &")
    call feedkeys("\e")
    edit ~/doc/quicknote.md
    " call airline#parts#define_accent('mytimer', 'red')
    " let g:airline_section_y = airline#section#create(['mytimer'])
    " AirlineRefresh
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

" dictionary
"
let g:keywords_for_time = { "minutes" : ["minute","minutes","min","m"], 
            \ "seconds" : ["second","seconds","sec","s"], 
            \ "hours" : ["hour","hours","h"],
            \ "days" : ["day","days","d"],
            \ "weeks" : ["week","weeks"], 
            \ "years" : ["year","years"],  
            \ }   

let g:second_variant = { "minutes" : 60, 
            \ "seconds" : 1, 
            \ "hours" : 60*60,
            \ "days" : 24*60*60,
            \ "weeks" : 7*24*60*60,
            \ "years" : 365*24*60*60 
            \ }   

let g:descenting_time_values = [ "years", "weeks", "days", "hours", "minutes", "seconds" ]

fu! IsTimeKeyword(word) 
    " check is numeric
    if a:word =~# '^\d\+$'
        return 1
    endif
    for item in items(g:keywords_for_time)
        let words = item[1]
        let idx = index(words,a:word)
        if idx >= 0
            return 1
        endif
    endfor
    return 0
endfunction

fu! ParseExpression(str) 
    let items = split(a:str)
    let words = [] 
    let isTime = 1
    let tags = []
    for item in items 
        let word = trim(item)
        if stridx(word,"#") == 0
            call add(tags,word)
            let isTime = 0
            continue
        endif
        if !IsTimeKeyword(word)
            let isTime = 0 
        endif
        call add(words,word)
    endfor
    return { "words" : words, "isTime" : isTime, "tags" : tags}
endfunction

fu! MyTimeSeparate(seconds)
    let time = {}
    let seconds = a:seconds
    for item in g:descenting_time_values
        let val = g:second_variant[item]
        let time[item] = seconds / val 
        let seconds = seconds % val 
    endfor
    return time
endfunction

fu! ResolveTime(words)
    let time = {}
    let number = 0
    let isNumber = 1
    for item in a:words
        if isNumber
            let number = str2nr(item)
            let isNumber = 0
        else
            for [key, value] in items(g:keywords_for_time)
                if index(value,item)>=0
                    let time[key] = number
                endif
            endfor
            let isNumber = 1
        endif
    endfor
    let seconds = 0
    for [key, value] in items(time)
       let seconds += g:second_variant[key] * value
    endfor
    return seconds

endfunction

fu! mytimer#line_parse(line) 
    " Trim unnecessary stuff -- This is timer -- 4 minutes 6 hours 62 seconds 1 day 7 weeks 45 years -- #vim #presence #velka
    let line = trim(a:line,"#\"/ ")
    let list = split(l:line,'--')
    let tags = []
    let sentences = []
    let time_periods = []
    for item in list
       let exp = trim(item)
       let parsed = ParseExpression(item)
       if parsed["isTime"]
            let seconds = ResolveTime(parsed["words"])
            echo MyTimeSeparate(seconds)
        else 
            let tags = parsed["tags"]
            if len(tags) > 0
                echo "Tags "
                echo tags
            endif
       endif
    endfor
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

    if exists("l:line")
        unlet l:line
    endif

    let t = localtime()
    let l:time = strftime(s:myformat, t)
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
    "
     
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
    let s:duration = 10
    let s:interval = 1000
    " this is important to set
    let g:mytimer_done = 1
    let s:mytime = localtime()
    let s:mytimer = timer_start(s:interval,"mytimer#timer_event", { "repeat" : -1 })
    let s:myformat = "%Y-%m-%d %H:%M:%S"
    let s:quicknote_file = "~/doc/quicknote.md"
    let s:jump_cursor = [0,0]
    let s:jump_buffer = [0,0]
endfunction

if !exists("s:mytimer")
    call mytimer#init_timer()
endif

call mytimer#init_timer()


