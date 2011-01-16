data segment para public 'data'
	startmessage db 'Lab 4', '$'

	inputmessage db 'Please input some text: ', '$'
	exitmessage db 'Bye', '$'

	counter db 2

	namepar label byte
	max1length db 20	
	string1length db ?
	string1 db 20 dup ('?'), '$'

	namepar2 label byte
	max2length db 20
	string2length db ?
	string2 db 20 dup ('?'), '$'

	maxlength db 20
	result db 40 dup ('?'), '$'
	resultlength db ?
data ends

stk segment stack
	db 256 dup ('0')
stk ends

code segment para public 'code'
main proc
	assume cs:code, ds:data, ss:stk
	call initialize

	lea dx,inputmessage

	call disp

	mov ah, 0ah
	lea dx, namepar
	int 21h	
	mov bl, string1length
	mov string1[bx+1],'$'
	call sclear

	lea dx,inputmessage
	call disp

	mov ah, 0ah
	lea dx, namepar2
	int 21h	
	mov bl, string2length
	mov string2[bx+1],'$'
	call sclear
	
	call concat
	lea dx,result
	call disp
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

concat proc
	call rclear
	mov dl, 0
	mov al,string1length
	add al,string2length
	mov resultlength,al

	mov al,string1length
	cmp al,string2length
	jge counter2
	mov counter,al
	jmp concat1
	counter2:
	
	mov al,string2length
	mov counter,al
	
	concat1:
	cmp dl,counter
	jge concat2
	mov bx,dx
	mov al,string1[bx]
	add bx,dx
	mov result[bx],al
	sub bx,dx
	mov al,string2[bx]
	add bx,dx
	mov result[bx+1],al

	
	inc dx
	
	jmp concat1
	
	concat2:
	mov bx,dx
	add bx,dx
	mov result[bx],'$'
	ret
concat endp
;Выход из программы

exit proc
	mov ah, 0ah
	lea dx, namepar
	int 21h	
	mov bl, string1length
	mov string1[bx+1],'$'
	lea dx, exitmessage
	call disp
	mov ax, 4c00h
	int 21h
exit endp


code ends
end main























