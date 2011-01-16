data segment para public 'data'
	startmessage db 'Lab 1', '$'
	exitmessage db 'Bye', '$'
data ends

stk segment stack
	db 256 dup ('?')
stk ends

code segment para public 'code'
main proc
	assume cs:code, ds:data, ss:stk
	mov ax, data
	mov ds, ax
	mov ah, 09h
	mov dx, offset startmessage
	int 21h
; —юда потом можно вставл€ть вс€кий код 
	mov dx, offset exitmessage
	int 21h
	mov ax, 4c00h
	int 21h
main endp
code ends
end main























