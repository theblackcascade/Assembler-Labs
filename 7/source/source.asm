data segment para public 'data'
	vowels db 'a','e','i','o','u','y','A','E','I','O','U','Y'
	vowelscount dw 12
	old_dx dw 0
	old_ds dw 0
	new_handl dd new_handler
	namepar label byte
	maxlength db 20
	inputlength db ?
	string db 20 dup (' '),'$'
data ends

stk segment stack
	db 256 dup (?)
stk ends

code segment para public 'code'
main proc
	assume cs:code, ds:data, ss:stk

	mov ax,data
	mov ds,ax
	xor ax,ax

	mov ah,35h;������ ������ ��������� ����������.
	mov al,09h
	int 21h
	
	mov old_dx, bx
	mov old_ds, ds
	
	call input
	call sclear
	
	push ds
	
	mov dx, offset new_handler
	mov ax, seg new_handler
	mov ds, ax
	
	mov ah,25h
	mov al,09h
	int 21h

	pop ds
	int 09h

	mov dx, old_dx
	mov ds, old_ds
	mov ah, 25h
	int 21h

	mov ah,4ch;���������
	int 21h
main endp

new_handler proc; 
	push bx
	xor bx,bx
l1:
	mov dl,string[bx]
	cmp string[bx],'$'	
je endh
	cmp string[bx],'a'	
je incr
	cmp string[bx],'e'	
je incr
	cmp string[bx],'i'	
je incr
	cmp string[bx],'o'	
je incr
	cmp string[bx],'u'	
je incr
	cmp string[bx],'y'	
je incr
	call disp
incr:
	inc bx
	jmp l1
endh:
	pop bx
	iret
new_handler endp
disp proc; ����� ������ �� dl
	push ax
	mov ah, 02h
	int 21h
	xor ah,ah
	pop ax
	ret
disp endp

input proc
	push ax
	push bx
	mov ah, 0ah
	lea dx, namepar
	int 21h	
	mov bl, inputlength
	mov string[bx+1],'$'
	pop bx
	pop ax
	ret	
input endp

sclear proc
	push ax
	push bx
	push cx
	push dx
	mov ax,0600h
	mov bh,7
	mov cx,0000
	mov dx,184fh
	int 10h
	mov ah,02
	mov bh,00
	mov dx,0000
	int 10h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
sclear endp

code ends
end main























