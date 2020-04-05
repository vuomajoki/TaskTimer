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
    "
    " Todo make conditional here
    if diff >= s:duration || s:done
        return "Done: ".left
        let s:done = 1
    endif
    return "Timer: ".left
endfunction



fu! mytimer#close()
    if exists("g:timer_running")
        unlet g:timer_running
    endif
    silent w
    " Avoid calling twice
    au! * <buffer> 
    silent Bdelete 
    " echo "closed"
endfu


fu! mytimer#done()
    " This is for full screen stuff
    " This just writes all
    " Add more accents
    " Int is nice to have red before end so th
    edit ~/doc/MyTimer 
    let cool = bufnr()
    echo cool
    call airline#parts#define_accent('mytimer', 'red')
    let g:airline_section_y = airline#section#create(['mytimer'])
    AirlineRefresh

    au! * <buffer> 
    au BufLeave <buffer> call mytimer#close()

    let lines = [s:mymessage,"time is up ".s:duration,""]
    " call appendbufline(cool,0,lines)
    call append(line("$"),lines)
    nmap <buffer> <esc><esc> :call mytimer#close()<cr>
    nmap <buffer> <space><cr> :call mytimer#close()<cr>
    normal G
    " call feedkeys("\e")

endfunction


fu! mytimer#star_timer()
    " ask task
    " set current timestamp
    edit ~/doc/MyTimer 
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
    let g:timer_running = 0
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

if !exists("s:mytimer")
    call mytimer#init_timer()
endif

call mytimer#init_timer()


