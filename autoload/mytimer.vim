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

fu! mytimer#check_time()
    "    echo diff
    let cur = localtime()
    let diff = cur-s:mytime
    let left = s:duration - diff
    " add here different message after done
    if diff >= s:duration || s:done
        return "Done: ".left
        let s:done = 1
    endif
    return "Timer: ".left
endfunction

fu! mytimer#done()
    let cool = bufadd("Cool")
    " This is for full screen stuff
    " This just writes all
    wa
    tabnew Cool

    " call airline#parts#define_function('mytimer', 'mytimer#check_time')
    call airline#parts#define_accent('mytimer', 'red')
    " let g:airline_section_y = airline#section#create_right(['ffenc','mytimer'])
    AirlineRefresh

    " exec "b ".cool
    " split Cool
    " resize 3
    nmap <buffer> <cr> :bd!<cr>
    " nmap <buffer> <cr> :q<cr>
    set modifiable
    "normal Gdgg
    let lines = [s:mymessage,"time is up ".s:duration]
    call appendbufline(cool,0,lines)

    " " Change to append
    " let line = 0
    " call setbufline(cool,line,s:mymessage)
    " let line += 1
    " call setbufline(cool,line,"timediff ".(localtime()-s:mytime))
    " let line += 1
    " call setbufline(cool,line,"mytime ".s:duration)
    " let line += 1
    " call setbufline(cool,line,"buf ".cool)
    " call append(0,s:mymessage)
    normal G
    " set hidden
    " let s:mywin = winnr()
    " wincmd j
endfunction


fu! mytimer#star_timer()
    let dur = eval(input("How many seconds? "))
    if dur != ""
       let s:duration = dur
    endif
    " this is important that things will end
    let s:done = 0
    if !exists("s:mytimer")
    endif
    call AirlineInit()
    AirlineRefresh
    let s:mytime = localtime()
endfunction

fu! mytimer#init_timer()
    let s:mymessage = "Current session is over. Take a break!"
    let s:mywin = -1
    let s:duration = 10
    let s:interval = 1000
    let s:done = 1
    let s:mytime = localtime()
    let s:mytimer = timer_start(s:interval,"mytimer#timer_event", { "repeat" : -1 })
endfunction

if !exists("s:timer")
    call mytimer#init_timer()
endif
