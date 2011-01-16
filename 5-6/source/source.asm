STACKSG SEGMENT PARA STACK 'Stack'
	DB 32 DUP(?)
STACKSG ENDS
;________________________________________________________
DATASG SEGMENT PARA 'Data'
	
	NAMEPAR LABEL BYTE
		MAXLEN DB 10			;максимальное кол-во вводимых символов
		INPLEN DB ?			;кол-во введенных символов
		INPSTR DB 20 DUP('1'),'$'	;строка для ввода
	
	TEMPSTR DB 20 DUP('1'),'$'	;временная строка
	ENTSTR DB 0AH, 0DH, '$'		;перевод строки + возврат коретки
	M DW 0				;кол-во столбцов
	N DW 0				;кол-во строк
	MAT DW 1000 DUP('%%')		;матрица, доступ к ячейке (i,j) -> (M*i + j)*2
	SUM DW 0
	vector dw 10 dup('00')

	STRINGSTR DB 'string: ','$'	;приглашение ввести строку
	COLUMNSTR DB 'column: ','$'	;приглашение ввести столбец
	MSTR DB 'Enter M ','$'	;приглашение ввести кол-во столбцов
	NSTR DB 'Enter N ','$'	;приглашение ввести кол-во строк
	SPACESTR DB ' ','$'

DATASG ENDS
;________________________________________________________
CODESG SEGMENT PARA 'Code'
	MAIN PROC FAR
		ASSUME CS:CODESG,DS:DATASG,SS:STACKSG
		PUSH DS
		XOR AX,AX
		PUSH AX
		MOV AX,DATASG
		MOV DS,AX
		XOR AX,AX
		;________________________________________

		CALL CLS
		
		CALL INPMAT
		
		LEA SI,[MAT]		;находим ответ и помещаем его в AX
		CALL FINDSUM	
		RET
	MAIN ENDP
	
;________________________________________________________

	;очистка экрана
	CLS PROC
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX

		MOV AX,0600H	;очистка
		MOV BH,07
		MOV CX,0000
		MOV DX,184FH
		INT 10H
		
		MOV AH,02	;установка курсора
		MOV BH,00
		MOV DX,0000
		INT 10H
		
		POP DX
		POP CX
		POP BX
		POP AX
		
		RET
	CLS ENDP

;________________________________________________________

	;ввод строки INPSTR -> строка, MAXLEN -> макс длина, INPLEN -> текущая длина
	INPUT PROC
		
		PUSH AX
		PUSH DX
		PUSH BX

		MOV AH,0AH
		LEA DX,[NAMEPAR]
		INT 21H
		
		MOV BL,INPLEN
		MOV INPSTR[BX],'$'	;добавление знака конца строки
		
		POP BX
		POP DX
		POP AX		

		RET
	INPUT ENDP


;________________________________________________________

	;вывод строки по адресу в DX
	DISP PROC
		PUSH AX

		MOV AH,09
		INT 21H
		
		POP AX
		RET
	DISP ENDP

;________________________________________________________

	;перевод AX в строку по адресу SI
	TOSTR PROC
		
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI

		XOR CX,CX
		XOR BX,BX
		MOV BX,10

		CMP AX,0		;проверка на отрицательность
		JNL .NOTMINUS

			MOV DL,'-'	;добавляем в строку минус
			MOV [SI],DL
			INC SI
			NEG AX

		.NOTMINUS:

		.DIVIDE:

			XOR DX,DX	;обнуляем DX
			IDIV BX		;делим AX на 10 -> частное в AX, остаток -> DX
			ADD DX,'0'	;добавляем код нуля
			PUSH DX		;остаток в стек
			INC CX		;увеличиваем счетчик цифр
			CMP AX,0	;если частное равно нулю, выходим из цикла

		JNE .DIVIDE
		
		XOR BX,BX
		XOR AX,AX

		.REVERSE:

			POP AX			;из стека в строку
			MOV [SI+BX],AL
			INC BX

		LOOP .REVERSE
		
		MOV AL,'$'		;окончание строки
		MOV [SI+BX],AL
			
		POP SI			;восстановить прежнюю ссылку на строку
		POP DX
		POP CX
		POP BX

		RET
	TOSTR ENDP

;________________________________________________________

	;перевод строки по адресу SI в AX
	TONUM PROC
		;CX -> основание системы счисления
		
		PUSH CX
		PUSH BX
		PUSH DX
		PUSH SI

		MOV DL,[SI]		;для проверки на минус
		MOV CX,10
		XOR BX,BX
		XOR AX,AX
		
		CMP DL,'-'
		JNE .NOTNEG
			
			;отрицательное
			INC SI		;пропускаем минус
		
		.NOTNEG:
		
			MOV BL,[SI]	;читаем цифру в BL
			CMP BL,'$'	;проверка на конец строки
			JE .DONE
		
			SUB BL,'0'	;нет проверки на неправильный ввод
			IMUL CX		;умножить AX на CX и сохранить в DX:AX
		
			ADD AX,BX
			INC SI

		JMP .NOTNEG

		.DONE:
		
		
		POP SI			;восстановить SI
		MOV DL,[SI]
		CMP DL,'-'		;если первый символ -
		JNE .END
			NEG AX		;сделать отрицательным

		.END:
		
		POP DX
		POP BX
		POP CX		

		RET
	TONUM ENDP
;________________________________________________________

	;ввести число в матрицу BX -> i, CX -> j
	SETMATEL PROC
		
		PUSH BX
		PUSH CX
		PUSH AX


		MOV AX,M	;поместить аол-во столбцов в AX
		IMUL BX		;умножить BX на AX  и сохранить результат в DX:AX
		ADD AX,CX

		MOV BX,AX	;переместить AX в BX
		SHL BX,1	;умножить на два
		
		POP AX		;восстановить бывший AX

		MOV [SI+BX],AX	;поместить AX в матрицу
		
		POP CX
		POP BX		

		RET
	SETMATEL ENDP


;________________________________________________________

	;ввод матрицы по адресу SI
	INPMAT PROC
		
		;ввод кол-ва столбцов
		;*************************

		LEA DX,[MSTR]
		CALL DISP
		
		LEA DX,[ENTSTR]
		CALL DISP

		CALL INPUT

		LEA SI,[INPSTR]
		CALL TONUM

		MOV M,AX
				
		;*************************
		
		LEA DX,[ENTSTR]		;перевод строки
		CALL DISP

		;ввод кол-ва строк
		;*************************

		LEA DX,[NSTR]
		CALL DISP
		
		LEA DX,[ENTSTR]
		CALL DISP

		CALL INPUT

		LEA SI,[INPSTR]
		CALL TONUM

		MOV N,AX
		
		;непосредственно ввод матрицы
		;**************************

		XOR BX,BX	;BX => i
		XOR CX,CX	;CX => j
		
		;перебор строк
		;************************************************

		.STRINGS:
			LEA DX,[ENTSTR]		;перевод строки
			CALL DISP
					
			LEA DX,[STRINGSTR]	;приглашение ввести данную строку 
			CALL DISP			

			MOV AX,BX		;вывод номера строки
			LEA SI,[TEMPSTR]
			CALL TOSTR

			MOV DX,SI			
			CALL DISP		
			
			;перебор колонок
			;*******************************

			.COLUMNS:
				LEA DX,[ENTSTR]		;перевод строки
				CALL DISP
					
				LEA DX,[COLUMNSTR]	;приглашение ввести данную строку 
				CALL DISP			

				MOV AX,CX		;вывод номера строки
				LEA SI,[TEMPSTR]
				CALL TOSTR
				
				MOV DX,SI			
				CALL DISP
				
				LEA DX,[SPACESTR]	;вывод пробела
				CALL DISP

				CALL INPUT		;ввод значения, впоследствии помещаемого в матрицу
				LEA SI,[INPSTR]
				CALL TONUM				
				
				LEA SI,[MAT]
				CALL SETMATEL
				
				INC CX
				CMP CX,M
			JNE .COLUMNS

			;********************************
			
			XOR CX,CX		;обнуляем число колонок
			INC BX			;увеличиваем BX
			CMP BX,N		;если не равно кол-ву строк
		JNE .STRINGS

		;************************************************
		
		RET
	INPMAT ENDP
print proc
	xor bx,bx
	mov cx,m
	add cx,m
	
	printf:
	cmp bx,cx
	jge exitprint

	lea dx,[ENTSTR]
	call disp

	lea si,[TEMPSTR]
	mov ax,vector[bx]
	call tostr
	mov dx,si
	call disp
	
	inc bx
	add bx,bx	
	jmp printf

	exitprint:

	call input
	ret
print endp
;________________________________________________________
findsum proc
	push bx
	push cx
	push dx
	xor bx,bx ; i
	xor cx,cx ; j
	xor dx,dx
	
	columns1:
		xor bx,bx
		xor dx,dx
		cmp cx,m
		jnl endsum
	strings1:
		call getmatel
		add dx,ax
		inc bx
		cmp bx,n
	jne strings1
		push bx
		mov bx,cx
		add bx,cx
		mov vector[bx],dx
		pop bx
		inc cx	
		jmp columns1
	endsum:
		CALL PRINT
		mov di,vector[0]
	ret
findsum endp
;________________________________________________________

	;достать число из матрицы (BX -> i, CX -> j) в AX
	GETMATEL PROC
		
		PUSH DX
		PUSH BX
		PUSH CX

		MOV AX,M	;поместить кол-во столбцов в AX
		IMUL BX		;умножить BX на AX  и сохранить результат в DX:AX
		ADD AX,CX

		MOV BX,AX	;переместить AX в BX
		SHL BX,1	;умножить на два
				
		MOV AX,[SI+BX]
		
		POP CX
		POP BX
		POP DX		

		RET
	GETMATEL ENDP


;________________________________________________________



CODESG ENDS
END MAIN
