;latest with sound and music 
[org 0x0100]
jmp start
soundflag: dw 0

misc: ;plays the music

	pusha 
	; send DSP Command 10h
	loopofmusic:
		mov bl, 10h
		call sb_write_dsp
		; send byte audio sample
		mov si, [sound_index]
		mov bl, [sound_data + si]
		call sb_write_dsp	
		mov cx, 200 ; <-- change this value according to the speed of your computer
	delaymm:
		nop
		loop delaymm
			
		inc word [sound_index]
		in al,0x60
		cmp al,25
		jne hpp
		jmp stoop
		hpp:
			cmp al,35
			jne epp
			jmp stoop
		epp:
			cmp al,01
			jne nnnnn
		stoop:
			mov word [soundflag],1
		nnnnn:
			cmp word [sound_index], 51529
			jne mmm
			mov word [sound_index],0
		mmm:
			cmp word [soundflag],0
			je loopofmusic
			
			popa 
			ret 
	
	sb_write_dsp:
			mov dx, 22ch
		busy:
			in al, dx
			test al, 10000000b
			jnz busy
			mov al, bl
			out dx, al
			ret

section .data

	sound_index dw 0

	sound_data:
			incbin "kingsv.wav" ; 51,529 bytes

s_delay:
	push cx
	push si
	mov si, 3
	s_dc11:	
		mov cx, 0x0fff
			s_dc1:
				dec cx
			jnz s_dc1
		dec si
		jnz s_dc11	
	pop si
	pop cx
	ret	

sound: ;beep sound
	mov al, 0B6H
	out 43h, al
	
	mov ax, 1FB4H
	out 42h, al
	mov al, ah
	out 42h, al
	
	in al, 61h
	mov ah, al
	or al, 0000001b
	out 61h, al
	
	mov ax, 152fh
	out 42, al
	mov al, ah
	out 42, al
	
	in al, 61h
	mov ah, al 
	or al, 00000011b
	out 61h, al
	call s_delay
	 
	mov al, ah
	out 61h, al
	
	mov al, ah
	out 61h, al
	
	ret
	
delay:
	push cx
	mov cx,770 ; change the values  to increase delay time
	delay_loop1:
		push cx
		delay_loop2:
			loop delay_loop2
		pop cx
		loop delay_loop1
	pop cx
	ret
clear_screen: ;clears the screen 
	push ax
	push di
	mov ax,0xb800
	mov es,ax
	mov di,0
	clear_loop1:
		mov word [es:di],0720h
		add di,2
		cmp di,4000
		jne clear_loop1
	pop di
	pop ax 
	ret 

;Printing Score:Fuel(Values)	
show: 
	push bp
	mov bp,sp
	pusha
	push es
	push ds

	mov ax, [bp+4]; number to be printed 	
	mov bx, 10
	mov cx, 0 ; counter
	get_digits:
		mov dx, 0 ; will perform word div
		div bx; DX has remainder and AX has Quotient
		push dx
		inc cx
		cmp ax,0
		jnz get_digits
	; print digits
	mov ax, 0xb800
	mov es, ax
	mov di, [bp+6]
	print_nums:
		pop dx ; get digit in dx
		add dx, 30h
		mov dh, [bp+8]; attributes
		mov [es: di], dx
		add di, 2
		loop print_nums		
		
		pop ds
		pop es
		popa
		pop bp
		ret 6

printHeadings: ;printing the headings on screen 
	push ip 
	push score
	push fuel 
	call Display
	ret
	
;Score_Fuel_Display
Display:
	push bp
	mov bp,sp
	sub sp,2
	pusha
	push es
	push ds
	mov ax,0xb800
	mov es,ax
	mov di,440
	mov dx,3
	mov ah,07
	mov si,8
	mov [bp-2],di
	printing:
			mov bx,[bp+si]
			prints:
				mov al,[bx]
				mov [es:di],ax
				inc bx 
				add di,2 
				cmp byte [bx],1
				jne prints
			sub si,2
			add word [bp-2],1280
			mov di,[bp-2]
			dec dx
			jnz printing
	;printing Score and Fuel
	
	pop ds
	pop es
	popa
	mov sp,bp
	pop bp
	ret 6

		
;Printing Obstacles on Screen		
obstacles:
	push bp
	mov bp,sp
	push di
	push ax
	push cx
	mov di,[bp+4]
	mov ah,[bp+6]
	mov al,0x08

	mov cx,[bp+8]
	rep stosw
	pop cx
	pop ax
	pop di
	pop bp
	ret 6
	
;Main Background	
background:
	push bp 
	mov bp,sp 
	sub sp,2
	pusha 
	mov ax,0xb800
	mov es,ax
	mov ax,00B3h
	mov di,0
	mov cx,2000
	rep stosw
	mov di,2
	mov ax,0FB3h
	mov cx,25 ;down
	white:
		mov [es:di],ax
		add di,160
		loop white
	mov ax,08DBh
	mov di,4 ;row+column
	mov dx,25 ;down
	mov bx,di
	loop1: ;Left grey part
		mov cx,5
		rep stosw
		add bx,160
		mov di,bx
		dec dx 
		jnz loop1
		mov di,20 ;row+column
		mov ax,0ADBh
		mov dx,25 ;down
		mov bx,di
	loop2: ;Left green part
		mov cx,10
		rep stosw
		add bx,160
		mov di,bx
		dec dx
		jnz loop2
		mov di,40 ;row+column
		mov ax,0x0FB3
		mov dx,25 ;down
		mov bx,di
	loop3: ;Left white edges
		mov cx,2
		rep stosw
		add bx,160
		mov di,bx
		dec dx
		jnz loop3
		mov di,44 ;row+column
		mov ax,08DBh
		mov bx,di
		mov dx,25 ;down
	loop4: ;grey part main 
		mov cx,20
		rep stosw
		add bx,160
		mov di,bx
		dec dx
		jnz loop4
		
	;now printing the obstacles	
	mov di,48 ;row+column
	add di,320
	mov dx ,6
	mov cx,2
	mov ax,01h
	oprint: ;printing obstacles 
		push dx
		push ax 
		push di 
		call obstacles
		add di,1132
		add di,320
		add ax,2
		sub dx,2
		loop oprint
		
		mov dx,4
		push dx
		push ax 
		push di 
		call obstacles
			
		mov di,84
		mov ax,0x0FB3
		mov dx,79
		mov bx,di
		
	loop5: ;Right white edges
		mov cx,2
		rep stosw
		add bx,160
		mov di,bx
		dec dx
		jnz loop5
		mov di,88
		mov ax,0ADBh
		mov bx,di
		mov dx,79
		
	loop6: ;Right green part 
		mov cx,10
		rep stosw
		add bx,160
		mov di,bx
		dec dx
		jnz loop6

		mov di,380
		mov si,di
		mov ax,0FDBh
		mov bx,4
		mov [bp-2],di 
	roads: ;printing roads
		mov dx,3
		loop7:
			stosw 
			add si,160
			mov di,si 
			dec dx
			jnz loop7
		
	add word [bp-2],960
	mov di,[bp-2]
	mov si,[bp-2]
	dec bx 
	jnz roads
	popa
	mov sp,bp
	pop bp
	ret 
	
;Background Movement	
movement:
	push bp
	mov bp,sp
	sub sp,14 ;creating local variables to store the car position 
	pusha
	mov ax,[bp+4]
	mov [bp-4],ax
	mov [bp-6],ax 
	mov [bp-8],ax 
	add word [bp-6],2
	add word [bp-8],4
	mov ax,[bp+6]
	mov [bp-10],ax
	mov [bp-12],ax
	mov [bp-14],ax
	add word [bp-12],2
	add word [bp-14],4
	
	push es
	push ds
	push 0xb800
	pop es
	mov word[bp-2],24
	push 0xb800
	pop ds
	mov di,3840
	mov si,3680	
	outertes:	
		mov cx,60
		mov bx,si
		mov dx,di
		testing:
			cmp si,[bp-4] ;car position
			je incs
			cmp si,[bp-6]
			je incs
			cmp si,[bp-8]
			je incs
			cmp si,[bp-10]
			je incs
			cmp si,[bp-12]
			je incs 
			cmp si,[bp-14]
			je incs
			cmp di,[bp-4]
			je incs
			cmp di,[bp-6]
			je incs
			cmp di,[bp-8]
			je incs
			cmp di,[bp-10]
			je incs
			cmp di,[bp-12]
			je incs 
			cmp di,[bp-14]
			je incs
		falsecase:	
			mov ax,[es:si]
			mov [es:di],ax
		incs:
			add si,2
			add di,2
			loop testing
	
		mov si,bx
		mov di,dx
		sub di,160
		sub si,160
		dec word [bp-2]
		jnz outertes
		
	pop ds
	pop es
	popa
	mov sp,bp
	pop bp
	ret 4
	
;User Car	
Car:
	push bp 
	mov bp,sp
	pusha
	push es
	mov ax,0xb800
	mov es,ax

	;Middle
	mov ax,0x0608
	mov di,[bp+4]
	mov cx,3
	rep stosw

	mov ax,0x0408
	mov di,[bp+6]
	mov cx,3
	rep stosw
	pop es
	popa
	pop bp
    ret 4
 	
loaddata: ;storing the data of background in arrays
	pusha 
	push es
	push ds
	push ds
	pop es
	push 0xb800
	pop ds
	mov si,0 
	mov di,arr1
	mov cx,80
	rep movsw
	mov di,arr2
	mov cx,80
	rep movsw
	mov di,arr3
	mov cx,80
	rep movsw
	mov di,arr4
	mov cx,80
	rep movsw
	mov di,arr5
	mov cx,80
	rep movsw
	mov di,arr6
	mov cx,80
	rep movsw
	mov di,arr7
	mov cx,80
	rep movsw
	mov di,arr8
	mov cx,80
	rep movsw
	mov di,arr9
	mov cx,80
	rep movsw
	mov di,arr10
	mov cx,80
	rep movsw 
	mov di,arr11
	mov cx,80
	rep movsw 
	mov di,arr12
	mov cx,80
	rep movsw 
	mov di,arr13
	mov cx,80
	rep movsw 
	mov di,arr14
	mov cx,80
	rep movsw 
	mov di,arr15
	mov cx,80
	rep movsw 
	mov di,arr16
	mov cx,80
	rep movsw 
	mov di,arr17
	mov cx,80
	rep movsw 
	mov di,arr18
	mov cx,80
	rep movsw 
	mov di,arr19
	mov cx,80
	rep movsw 
	mov di,arr20
	mov cx,80
	rep movsw 
	mov di,arr21
	mov cx,80
	rep movsw 
	mov di,arr22
	mov cx,80
	rep movsw 
	mov di,arr23
	mov cx,80
	rep movsw 
	mov di,arr24
	mov cx,80
	rep movsw 
	mov di,arr25
	mov cx,80
	rep movsw
	pop ds
	pop es
	popa
	ret 
	
intro: ;introducing a new 1st row after shifting
	push bp
	mov bp,sp
	pusha
	push es
	push 0xb800 
	pop es
	mov cx,60
	
	cmp word [bp+4],1
	jne case2
	mov di,0
	mov si,arr1
	rep movsw 
	pop es
	popa
	pop bp
	ret 2
	case2:
		cmp word [bp+4],2
		jne case3
		mov di,0
		mov si,arr2
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case3:	
		cmp word [bp+4],3
		jne case4
		mov di,0
		mov si,arr3
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case4:
		cmp word [bp+4],4
		jne case5
		mov di,0
		mov si,arr4
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case5:	
		cmp word [bp+4],5
		jne case6
		mov di,0
		mov si,arr5
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case6:	
		cmp word [bp+4],6
		jne case7
		mov di,0
		mov si,arr6
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case7:	
		cmp word [bp+4],7
		jne case8
		mov di,0
		mov si,arr7
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case8:	
		cmp word [bp+4],8
		jne case9
		mov di,0
		mov si,arr8
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case9:
		cmp word [bp+4],9
		jne case10
		mov di,0
		mov si,arr9
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case10:
		cmp word [bp+4],10
		jne case11
		mov di,0
		mov si,arr10
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case11:	
		cmp word [bp+4],11
		jne case12
		mov di,0
		mov si,arr11
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case12:	
		cmp word [bp+4],12
		jne case13
		mov di,0
		mov si,arr12
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case13:	
		cmp word [bp+4],13
		jne case14
		mov di,0
		mov si,arr13
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case14:	
		cmp word [bp+4],14
		jne case15
		mov di,0
		mov si,arr14
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case15:	
		cmp word [bp+4],15
		jne case16
		mov di,0
		mov si,arr15
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case16:	
		cmp word [bp+4],16
		jne case17
		mov di,0
		mov si,arr16
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case17:	
		cmp word [bp+4],17
		jne case18
		mov di,0
		mov si,arr17
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case18:	
		cmp word [bp+4],18
		jne case19
		mov di,0
		mov si,arr18
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case19:	
		cmp word [bp+4],19
		jne case20
		mov di,0
		mov si,arr19
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case20:	
		cmp word [bp+4],20
		jne case21
		mov di,0
		mov si,arr20
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case21:	
		cmp word [bp+4],21
		jne case22
		mov di,0
		mov si,arr21
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case22:
		cmp word [bp+4],22
		jne case23
		mov di,0
		mov si,arr22
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case23:	
		cmp word [bp+4],23
		jne case24
		mov di,0
		mov si,arr23
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case24:	
		cmp word [bp+4],24
		jne case25
		mov di,0
		mov si,arr24
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	case25:	
		cmp word [bp+4],25
		jne nocase
		mov di,0
		mov si,arr25
		rep movsw 
		pop es
		popa
		pop bp
		ret 2
	nocase:
		pop es
		popa
		pop bp
		ret 2


clscore:
	push cx
	push ax 
	push di
	push es 
	 
	mov cx,5
	mov ax,0720h
	push 0xb800
	pop es
	mov di,3170
	rep stosw
	pop es
	pop di
	pop ax
	pop cx
	ret

clearcar: ;erases the car from screen
	push bp 
	mov bp,sp
	pusha 
	push es
	push 0xb800
	pop es
	mov cx,3
	mov dx,[bp+4]
	sub dx,3520 ;3520 value for 23rd row
	mov di,[bp+4]
	mov si,arr23 
	add si,dx
	rep movsw 
	mov cx,3
	mov dx,[bp+6]
	sub dx,3680 ;3680 value for 24th row 
	mov di,[bp+6]
	mov si,arr24
	add si,dx 
	rep movsw
	pop es
	popa
	pop bp
	ret 4
	
RANDNUM: ;generates the randum number 

	 push bp
	 mov bp, sp
	 push bx
	 push dx	 
	 push ax
	 
	 mov   ax, 25173
	 mul   word [seed]
	 add   ax, 13849
	 mov   [seed], ax    ; save the seed for the next call
	 ror   ax,8 
	 
	 mov   bx,[bp+4]  ; maximum value
	 inc bx
	 mov   dx,0
	 div   bx      ; divide by max value
	 mov   [bp+6],dx  ; return the remainder
	 
	 pop ax
	 pop dx
	 pop bx
	 pop bp

	 ret 2
	
;all the functions with name starting from crash deals with the collision of car with obstacles
crashleft:
	push bp
	mov bp,sp
	pusha 
	push es
	push 0xb800
	pop es
	mov ax,0
	mov di,[bp+4]
	sub di,2
	cmp byte [es:di],0x08
	jne crashleftdown
	mov ax,1
	jmp endcrashleft
	crashleftdown:
		mov di,[bp+4]
		sub di,2
		add di,160
		cmp byte [es:di],0x08
		jne endcrashleft
		mov ax,1
	endcrashleft:	
		mov [bp+6],ax
	pop es
	popa
	pop bp
	ret 2
	
crashright:
	push bp
	mov bp,sp
	pusha 
	push es
	push 0xb800
	pop es
	mov ax,0
	mov di,[bp+4]
	add di,6
	cmp byte [es:di],0x08
	jne crashrightdown
	mov ax,1
	jmp endcrashright
	crashrightdown:
	mov di,[bp+4]
	add di,6
	add di,160
	cmp byte [es:di],0x08
	jne endcrashright
	mov ax,1
	endcrashright:	
		mov [bp+6],ax
	pop es
	popa
	pop bp
	ret 2	
	
crashup:
	push bp
	mov bp,sp
	pusha
	push es
	push 0xb800
	pop es
	mov ax,0
	mov di,[bp+4]
	sub di,160
	cmp byte [es:di],0x08
	jne crashupr
	mov ax,1
	jmp endcrashup
	crashupr:
		mov di,[bp+4]
		add di,4
		sub di,160
		cmp byte [es:di],0x08
		jne endcrashup
		mov ax,1
	endcrashup:
	mov [bp+6],ax
	pop es
	popa
	pop bp
	ret 2	

;displays intro screen 	
intro_screen:
	pusha 
	push es 

	mov ax , 0x0b800		
	mov es , ax
	mov di,1324
	mov al,'*'
	mov ah, 0xcc
	begincase1:
	stosw
	cmp di,1408
	jne begincase1
	mov di,1324
	mov al,'*'
	mov ah, 0xcc
	begincase2:
		mov word[es:di],ax
		add di,160
		cmp di,2924
		jl begincase2
		mov si,84
		add si,di 
	begincase3:
		stosw
		cmp di,si
		jl begincase3
		mov si,1408
	begincase4:
		mov word[es:di],ax
		sub di,160
		cmp di,si
		jge begincase4

	mov ax , 0x0b800		
	mov es , ax
	mov di,160
	mov ah,0x0e
	mov si,0
	le_:
	mov al,[namearr+si]
	mov word [es:di],ax
	add si,1
	add di,2
	cmp byte [namearr+si],0
	jne le_

	mov ax , 0x0b800		
	mov es , ax

	mov di,1660
	mov ah,0x8c
	mov si,0
	le1:
	mov al,[titlearr+si]
	mov word [es:di],ax
	add si,1
	add di,2
	cmp byte [titlearr+si],0
	jne le1

	mov ax , 0x0b800		
	mov es , ax

	mov di,1980
	mov ah,0x0e
	mov si,0
	le2:
	mov al,[startarr+si]
	mov word [es:di],ax
	add si,1
	add di,2
	cmp byte [startarr+si],0
	jne le2

	mov di,2300
	mov ah,0x0e
	mov si,0
	le3:
	mov al,[note+si]
	mov word [es:di],ax
	add si,1
	add di,2
	cmp byte [note+si],0
	jne le3

	mov di,2460
	add di,160
	mov si,charity
	mov ah,0x0e
	le4:
	mov al,[si]
	mov word [es:di],ax
	add di,2
	inc si 
	cmp byte [si],0
	jne le4

	add di,2
	mov ax,0x0e01
	stosw 

	push word 3844
	push word 3684
	call Car

	pop es 
	popa 
	ret
	
;creates the score car 	
coins:
	push bp
	mov bp,sp
	push ax
	push di 
	push es 	
	push 0xb800
	pop es 
	mov ax,0xEE02
	mov di,[bp+4]	
	stosw 
	pop es 
	pop di
	pop ax 
	pop bp
	ret 2
	
	
	
;crash cases 	
crashleftscore:
	push bp
	mov bp,sp
	pusha 
	push es
	push 0xb800
	pop es
	mov ax,0
	mov di,[bp+4]
	sub di,2
	cmp byte [es:di],0x02
	jne crashleftdownscore
	mov ax,1
	jmp endcrashleftscore
	crashleftdownscore:
		mov di,[bp+4]
		sub di,2
		add di,160
		cmp byte [es:di],0x02
		jne endcrashleftscore
		mov ax,1
	endcrashleftscore:	
		mov [bp+6],ax
	pop es
	popa
	pop bp
	ret 2
	
crashrightscore:
	push bp
	mov bp,sp
	pusha 
	push es
	push 0xb800
	pop es
	mov ax,0
	mov di,[bp+4]
	add di,6
	cmp byte [es:di],0x02
	jne crashrightdownscore
	mov ax,1
	jmp endcrashrightscore
	crashrightdownscore:
		mov di,[bp+4]
		add di,6
		add di,160
		cmp byte [es:di],0x02
		jne endcrashrightscore
		mov ax,1
	endcrashrightscore:	
		mov [bp+6],ax
	pop es
	popa
	pop bp
	ret 2	
	
crashupscore:
	push bp
	mov bp,sp
	pusha
	push es
	push 0xb800
	pop es
	mov ax,0
	mov di,[bp+4]
	sub di,160
	cmp byte [es:di],0x02
	jne crashuprscore
	mov ax,1
	jmp endcrashupscore
	crashuprscore:
		mov di,[bp+4]
		add di,4
		sub di,160
		cmp byte [es:di],0x02
		jne midscore
		mov ax,1
	midscore:
		mov di,[bp+4]
		add di,2
		sub di,160
		cmp byte [es:di],0x02
		jne endcrashrightscore
		mov ax,1
	
	endcrashupscore :
	mov [bp+6],ax
	pop es
	popa
	pop bp
	ret 2		
	
	
		
;Main functionality of game 		
road_fighter:
	pusha
	push es 
	call background
	;Display Function
	call printHeadings
	call loaddata
	;creates car 
	push word 3726
	push word 3566
	call Car
	mov si,3726 ;coordinates of car
	mov bp,3566
	
	mov cx,10000 ;fuel 
    mov bx,0000 ;score 
	mov word [soundflag],0
	trying:  
		call clscore
		push word 07
		push 1890 
		push bx
		call show ;for score
		push word 07
		push 3170
		push cx
		call show ;for fuel
		call delay
		push word si
		push word bp
		call movement
		
		in al,0x60 ;keyboard scan code check
		cmp al,77 ;scan code of right arrow key
		je right
		cmp al,75 ;scan code of left arrow key 
		je left 
		jmp checktheup
	 
	right: ;checking for cars 
		push 0
		push bp 
		call crashright
		pop di
		cmp di,1
		jne very 
		jmp termination
		
	very: ;now checking for potholes	
		push 0
		push bp 
		call crashrightspecial
		pop di
		cmp di,1
		jne rightscoring
		jmp termination

	rightscoring: ;checking for coins 
		push 0
		push bp 
		call crashrightscore
		pop di
		cmp di,1
		jne fff 
		add bx,100
		call sound 

	fff:
		call sound
		cmp bp,3598
		jge checktheup
		push word si
		push word bp
		call clearcar
		add bp,2
		add si,2
		jmp nokey ;print the car 
	left:
		push 0
		push bp 
		call crashleft ;checking for cars 
		pop di
		cmp di,1
		jne another
		jmp termination
	another:	
		push 0
		push bp 
		call crashleftspecial ;checking for potholes
		pop di
		cmp di,1
		jne lefty 
		jmp termination

	lefty:
		push 0
		push bp 
		call crashleftscore ;checking for coins 
		pop di
		cmp di,1
		jne zyw 
		add bx,100
		call sound

	zyw:
		call sound
		cmp bp,3564
		jle checktheup
		push word si
		push word bp
		call clearcar
		sub bp,2
		sub si,2
	nokey:
		push word si
		push word bp
		call Car
	checktheup:	
		push 0
		push bp
		call crashup ;checking for cars 
		pop di
		cmp di,1
		jne nicee
		jmp termination
	nicee:	
		push 0
		push bp
		call crashupspecial ;checking for potholes
		pop di
		cmp di,1
		jne restp
		jmp termination
	restp:
		push 0
		push bp
		call crashupscore ;checking for coins 
		pop di
		cmp di,1
		jne nonek
		add bx,100
		call sound 
	nonek:	
		inc bx
		push 0
		push word 25
		call RANDNUM ;introducing a new row randomly
		pop dx 
		inc dx 
		push dx 
		call intro
		
		push 0
		push word 960
		call RANDNUM ;randomly printing special score coins  
		pop di 
		cmp di,48
		jl remains
		cmp di,80
		jge remains
		mov dx,di
		shr dx,1
		jc remains
		cmp byte [es:di],0x08 ;making sure at coordinates other obstacles dont exist 
		je remains
		push di 
		call coins
			
	remains:	
		push 0
		push word 1100
		call RANDNUM ;randomly printing potholes
		pop di 
		cmp di,48
		jl no_special
		cmp di,80
		jge no_special
		mov dx,di
		shr dx,1
		jc no_special
		cmp byte [es:di],0x08 ;making sure at coordinates other obstacles dont exist 
		je no_special
		push di 
		call special
	no_special:	
		dec cx
		jz termination
		jmp trying
	termination:
		mov [total_score],bx
		pop es 
		popa
		ret 

;create potholes	
special:
	push bp 
	mov bp,sp
	push ax
	push di
	push cx
	push es
	push 0xb800
	pop es

	mov cx,2
	mov di,[bp+4]
	mov ax,0x0006
	rep stosw
	pop es 
	pop cx 
	pop di
	pop ax 
	pop bp 
	ret	2
	
crashleftspecial:
	push bp
	mov bp,sp
	pusha 
	push es
	push 0xb800
	pop es
	mov ax,0
	mov di,[bp+4]
	sub di,2
	cmp byte [es:di],0x06
	jne crashleftdownspecial
	mov ax,1
	jmp endcrashleftspecial
	crashleftdownspecial:
		mov di,[bp+4]
		sub di,2
		add di,160
		cmp byte [es:di],0x06
		jne endcrashleftspecial
		mov ax,1
	endcrashleftspecial:	
		mov [bp+6],ax
	pop es
	popa
	pop bp
	ret 2
			
crashupspecial:
	push bp
	mov bp,sp
	pusha
	push es
	push 0xb800
	pop es
	mov ax,0
	mov di,[bp+4]
	sub di,160
	cmp byte [es:di],0x06
	jne crashuprspecial
	mov ax,1
	jmp endcrashupspecial
	crashuprspecial:
		mov di,[bp+4]
		add di,4
		sub di,160
		cmp byte [es:di],0x06
		jne endcrashupspecial
		mov ax,1
	endcrashupspecial:
	mov [bp+6],ax
	pop es
	popa
	pop bp
	ret 2	

crashrightspecial:
	push bp
	mov bp,sp
	pusha 
	push es
	push 0xb800
	pop es
	mov ax,0
	mov di,[bp+4]
	add di,6
	cmp byte [es:di],0x06
	jne crashrightdownspecial
	mov ax,1
	jmp endcrashright
	crashrightdownspecial:
		mov di,[bp+4]
		add di,6
		add di,160
		cmp byte [es:di],0x06
		jne endcrashrightspecial
		mov ax,1
	endcrashrightspecial:	
		mov [bp+6],ax
	pop es
	popa
	pop bp
	ret 2	

;creates ending screen
ending_screen:
	pusha 
	push es 
	mov ax , 0x0b800		
	mov es , ax
	mov di,1324
	mov al,'*'
	mov ah, 0xee
	endcase1:
	stosw
	cmp di,1408
	jne endcase1
	mov di,1324
	mov al,'*'
	mov ah, 0xee
	endcase2:
		mov word[es:di],ax
		add di,160
		cmp di,2924
		jl endcase2
		mov si,84
		add si,di 
	endcase3:
		stosw
		cmp di,si
		jl endcase3
		mov si,1408
	endcase4:
		mov word[es:di],ax
		sub di,160
		cmp di,si
		jge endcase4
	mov di,1824
	mov ah,0x0e
	mov si,0
	end_dis:
		mov al,[endarr+si]
		mov word [es:di],ax
		add si,1
		add di,2
		cmp byte [endarr+si],0
		jne end_dis


	;using int 10h to print the substrings 
	
	mov ah,13h
	mov al,1
	mov bh,0
	mov bl,0x0c
	mov cx,11
	mov dh,3
	mov dl,30
	push cs 
	pop es
	mov bp,score_note
	int 10h
	
	push word 0x8c
	push word 564
	push word [total_score]
	call show

	mov ah,13h
	mov al,1
	mov bh,0
	mov bl,0x0e
	mov cx,18
	mov dh,13
	mov dl,32
	push cs 
	pop es
	mov bp,note
	int 10h
	
	mov ah,13h
	mov al,1
	mov bh,0
	mov bl,0x0e
	mov cx,26
	mov dh,15
	mov dl,32
	push cs 
	pop es
	mov bp,again
	int 10h
	
	pop es 
	popa
	ret	

;creates the screen for instructions 
helping_screen:
	pusha
	push es 
	push 0xb800
	pop es 
	mov ax,0x0cDb
	mov cx,2000
	mov di,0
	rep stosw 
	mov di,340
	mov si,help1
	hs:
		mov al ,[si]
		mov ah,0x0e
		mov [es:di],ax 
		add di,2
		inc si 
		cmp byte [si],0
		jne hs 

	mov di,660
	mov si,help2 
	hs1:
		mov al,[si]
		mov ah,0x0e
		mov [es:di],ax 
		add di,2
		inc si 
		cmp byte [si],0
		jne hs1 
		
	mov di,980
	mov si,help3 
	hs2:
		mov al,[si]
		mov ah,0x0e
		mov [es:di],ax 
		add di,2
		inc si 
		cmp byte [si],0
		jne hs2 
		
	mov ax,0x0a08 	
	add di,2
	mov cx,3
	rep stosw 

	mov di,1300
	mov si,help4
	hs3:
	mov al,[si]
		mov ah,0x0e
		mov [es:di],ax 
		add di,2
		inc si 
		cmp byte [si],0
		jne hs3

	add di,2
	mov ax,0006
	mov cx,2
	rep stosw 

	mov di,1620
	mov si,help6	
	hs5:
		mov al,[si]
		mov ah,0x0e
		mov [es:di],ax 
		add di,2
		inc si 
		cmp byte [si],0
		jne hs5
		
	mov di,1940
	mov si,help7
	hsl:
		mov al,[si]
		mov ah,0x0e
		mov [es:di],ax 
		add di,2
		inc si 
		cmp byte [si],0
		jne hsl
		
	add di,2
	mov word [es:di],0xEE02
	mov di,2100
	add di,320
	add di,160
	mov si,help5
	hs4:
		mov al,[si]
		mov ah,0x8e
		mov [es:di],ax 
		add di,2
		inc si 
		cmp byte [si],0
		jne hs4
		
	pop es
	popa 
	ret 

start:
	mov al,00
	out 0x60,al ;this line is for adjusting the music 

	call clear_screen
	call intro_screen
	call misc

	fresh:
	mov ah,00
	int 16h
	cmp ah,25 ;scan code of P
	je so_it_begins
	cmp ah,01 ;scan code of esc 
	je program_finish
	cmp ah,35 ;scan code of H 
	je helpers
	jmp fresh

	helpers:
	call clear_screen
	call helping_screen
	mov ah,00
	int 16h
	mov word [soundflag],0
	jmp start 

	so_it_begins:
	mov word [soundflag],1
	call road_fighter	
	
	mov cx,100
	sound_ending:
	call sound
	loop sound_ending
	
	mov word [sound_index],0

	call clear_screen
	call ending_screen

	happyending:
	mov ah,00
	int 16h
	cmp ah,0x1c ;scan code of enter 
	je start 
	cmp ah,01 ;scan code of esc 
	jne happyending

program_finish:
	mov ax, 0x4c00 ; termination statements 
	int 21h

;arrays used in the code 	
charity: db "Press H for help",0 
help1: db "To move car right press right arrow key!",0
help2: db "To move car left press left arrow key!",0
help3: db "Beware of these hurdles if you crash them game will be over",0
help4: db "Also beware of these potholes and if you crash then game ends!",0
help5: db "Press any key to exit help",0
help6: db "Game will also end when fuel will become 0",0
help7: db "Dont be afraid of crashing on them they will give you bonus score",0
score_note: db "YOUR SCORE: "
total_score: dw 0
again: db "Press enter to play again!"
note: db "Press esc to exit!",0
namearr: db "Game Developed by Abdullah and Sameer",0
titlearr: db "Welcome to Road Fighter",0
startarr: db "Press P to start the game",0
endarr: db "Thanks For Playing!",0
seed: dw 50
ip: db "1 Player",1
score: db "Score",1
fuel: db "Fuel",1
arr1: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr2: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr3: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr4: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr5: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr6: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr7: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr8: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr9: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr10: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr11: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr12: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr13: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr14: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr15: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr16: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr17: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr18: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr19: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr20: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr21: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr22: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr23: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr24: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
arr25: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,































