data segment para public 'data'
	startmessage db 'Lab 1', '$'

	inputmessage db 'Please input any value: ', '$'

	exitmessage db 'Bye', '$'
	negative dw 32767
	number dw 0
	array db 0,0,0,0,0
	isnegative db 0
	counter db 4
	stackheight db 4
	namepar label byte
	maxlength db 20
	inputlength db ?
	inputstring db 20 dup ('?'),'$'
data ends

stk segment stack
	db 256 dup ('0')
stk ends

code segment para public 'code'
main proc
	assume cs:code, ds:data, ss:stk
	call initialize
	mov counter,5
	l0:
	cmp counter,0
	je l01
	dec counter
	lea dx,inputmessage
	call disp
	call input
	call tonumber
	push ax
	call sclear
	jmp l0
	l01:
	call compare
	call exit
main endp

;Инициализация
initialize proc
	mov ax, data
	mov ds, ax
	xor ax, ax
	call sclear
initialize endp
;Чистим регистры
rclear proc
	xor ax,ax
	xor bx,bx
	xor cx,cx
	xor dx,dx
	xor si,si
	ret
rclear endp
;Очищаем экран
sclear proc
	mov ax,0600h
	mov bh,7
	mov cx,0000
	mov dx,184fh
	int 10h
	call rclear
	mov ah,02
	mov bh,00
	mov dx,0000
	int 10h
	call rclear
	ret
sclear endp
;Выводим на экран из dx
disp proc
	mov ah, 09h
	int 21h
	xor ah,ah
	ret
disp endp

input proc
	mov ah, 0ah
	lea dx, namepar
	int 21h	
	mov bl, inputlength
	mov inputstring[bx+1],'$'
	call sclear
	ret	
input endp

tonumber proc
	mov isnegative, 0
	mov number, 0
	mov cl,inputlength
	mov dl,10
	l1:
		mov al,inputstring[bx]
		cmp al,2dh
	je l4
		sub al,'0'
		mov si,cx
		dec si
	l2:
		cmp si,0
		je l3
		mul dl
		dec si
		jmp l2
	l4:
		mov isnegative,1 
		xor ax,ax
		inc bx
		loop l1

	l3:
		add number,ax
		xor ax,ax
		inc bx
	loop l1
	cmp isnegative,0	
	je l5
	neg number
	l5:
	call sclear
	mov ax,number
	ret
tonumber endp

compare proc
		pop dx
		pop dx
	c0:
		cmp stackheight,1
	jle c02
		dec stackheight
		pop ax
		cmp ax, negative
	jg nax
		pop bx
		cmp bx, negative
	jg nbx
		cmp ax,bx
	jle c1
		push bx
		cmp dx, negative
	jg c0
		cmp dx,ax; 
	jle c0
		mov dx,ax
	jmp c0
	
	c1:
		push ax
		cmp dx,negative
	jg c0
		cmp dx,bx
	jle c0
		mov dx,bx
	jmp c0
	c00:
		jmp c0
	c02: 	
		jmp c2
	nax:
		pop bx
		cmp bx,negative
	jg naxbx
		push ax
		cmp dx,negative
	jg c00	
		cmp dx,bx
	jle c00
		mov dx,bx
	jmp c00

	nbx:	
		push dx
		cmp dx,negative
	jg c00
		cmp dx,ax
	jle c00
		mov dx,ax
	jmp c00

	naxbx:
		cmp ax,bx
	jle naxbx1
		push bx
		cmp dx,negative
	jg naxdx
		mov dx,ax
	jmp c00
	naxdx:
		cmp dx,ax
	jle c00
		mov dx,ax
	jmp c00
	
	naxbx1:
		push ax
		cmp dx,negative
	jg nbxdx
		mov dx,bx
	jmp c00
	nbxdx:
		cmp dx,bx
	jle c00
		mov dx,bx
	jmp c00

	c2:
		pop ax
		imul dx
	ret
compare endp

;Выход из программы
exit proc
	lea dx, exitmessage
	call disp
	mov ah, 0ah
	int 21h
	mov ax, 4c00h
	int 21h
exit endp


code ends
end main























