STACKSG SEGMENT PARA STACK 'Stack'
	DB 32 DUP(?)
STACKSG ENDS
;________________________________________________________
DATASG SEGMENT PARA 'Data'
	
	NAMEPAR LABEL BYTE
		MAXLEN DB 10			;������������ ���-�� �������� ��������
		INPLEN DB ?			;���-�� ��������� ��������
		INPSTR DB 20 DUP('1'),'$'	;������ ��� �����
	
	TEMPSTR DB 20 DUP('1'),'$'	;��������� ������
	ENTSTR DB 0AH, 0DH, '$'		;������� ������ + ������� �������
	M DW 0				;���-�� ��������
	N DW 0				;���-�� �����
	MAT DW 1000 DUP('%%')		;�������, ������ � ������ (i,j) -> (M*i + j)*2
	SUM DW 0
	vector dw 10 dup('00')

	STRINGSTR DB 'string: ','$'	;����������� ������ ������
	COLUMNSTR DB 'column: ','$'	;����������� ������ �������
	MSTR DB 'Enter M ','$'	;����������� ������ ���-�� ��������
	NSTR DB 'Enter N ','$'	;����������� ������ ���-�� �����
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
		
		LEA SI,[MAT]		;������� ����� � �������� ��� � AX
		CALL FINDSUM	
		RET
	MAIN ENDP
	
;________________________________________________________

	;������� ������
	CLS PROC
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX

		MOV AX,0600H	;�������
		MOV BH,07
		MOV CX,0000
		MOV DX,184FH
		INT 10H
		
		MOV AH,02	;��������� �������
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

	;���� ������ INPSTR -> ������, MAXLEN -> ���� �����, INPLEN -> ������� �����
	INPUT PROC
		
		PUSH AX
		PUSH DX
		PUSH BX

		MOV AH,0AH
		LEA DX,[NAMEPAR]
		INT 21H
		
		MOV BL,INPLEN
		MOV INPSTR[BX],'$'	;���������� ����� ����� ������
		
		POP BX
		POP DX
		POP AX		

		RET
	INPUT ENDP


;________________________________________________________

	;����� ������ �� ������ � DX
	DISP PROC
		PUSH AX

		MOV AH,09
		INT 21H
		
		POP AX
		RET
	DISP ENDP

;________________________________________________________

	;������� AX � ������ �� ������ SI
	TOSTR PROC
		
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI

		XOR CX,CX
		XOR BX,BX
		MOV BX,10

		CMP AX,0		;�������� �� ���������������
		JNL .NOTMINUS

			MOV DL,'-'	;��������� � ������ �����
			MOV [SI],DL
			INC SI
			NEG AX

		.NOTMINUS:

		.DIVIDE:

			XOR DX,DX	;�������� DX
			IDIV BX		;����� AX �� 10 -> ������� � AX, ������� -> DX
			ADD DX,'0'	;��������� ��� ����
			PUSH DX		;������� � ����
			INC CX		;����������� ������� ����
			CMP AX,0	;���� ������� ����� ����, ������� �� �����

		JNE .DIVIDE
		
		XOR BX,BX
		XOR AX,AX

		.REVERSE:

			POP AX			;�� ����� � ������
			MOV [SI+BX],AL
			INC BX

		LOOP .REVERSE
		
		MOV AL,'$'		;��������� ������
		MOV [SI+BX],AL
			
		POP SI			;������������ ������� ������ �� ������
		POP DX
		POP CX
		POP BX

		RET
	TOSTR ENDP

;________________________________________________________

	;������� ������ �� ������ SI � AX
	TONUM PROC
		;CX -> ��������� ������� ���������
		
		PUSH CX
		PUSH BX
		PUSH DX
		PUSH SI

		MOV DL,[SI]		;��� �������� �� �����
		MOV CX,10
		XOR BX,BX
		XOR AX,AX
		
		CMP DL,'-'
		JNE .NOTNEG
			
			;�������������
			INC SI		;���������� �����
		
		.NOTNEG:
		
			MOV BL,[SI]	;������ ����� � BL
			CMP BL,'$'	;�������� �� ����� ������
			JE .DONE
		
			SUB BL,'0'	;��� �������� �� ������������ ����
			IMUL CX		;�������� AX �� CX � ��������� � DX:AX
		
			ADD AX,BX
			INC SI

		JMP .NOTNEG

		.DONE:
		
		
		POP SI			;������������ SI
		MOV DL,[SI]
		CMP DL,'-'		;���� ������ ������ -
		JNE .END
			NEG AX		;������� �������������

		.END:
		
		POP DX
		POP BX
		POP CX		

		RET
	TONUM ENDP
;________________________________________________________

	;������ ����� � ������� BX -> i, CX -> j
	SETMATEL PROC
		
		PUSH BX
		PUSH CX
		PUSH AX


		MOV AX,M	;��������� ���-�� �������� � AX
		IMUL BX		;�������� BX �� AX  � ��������� ��������� � DX:AX
		ADD AX,CX

		MOV BX,AX	;����������� AX � BX
		SHL BX,1	;�������� �� ���
		
		POP AX		;������������ ������ AX

		MOV [SI+BX],AX	;��������� AX � �������
		
		POP CX
		POP BX		

		RET
	SETMATEL ENDP


;________________________________________________________

	;���� ������� �� ������ SI
	INPMAT PROC
		
		;���� ���-�� ��������
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
		
		LEA DX,[ENTSTR]		;������� ������
		CALL DISP

		;���� ���-�� �����
		;*************************

		LEA DX,[NSTR]
		CALL DISP
		
		LEA DX,[ENTSTR]
		CALL DISP

		CALL INPUT

		LEA SI,[INPSTR]
		CALL TONUM

		MOV N,AX
		
		;��������������� ���� �������
		;**************************

		XOR BX,BX	;BX => i
		XOR CX,CX	;CX => j
		
		;������� �����
		;************************************************

		.STRINGS:
			LEA DX,[ENTSTR]		;������� ������
			CALL DISP
					
			LEA DX,[STRINGSTR]	;����������� ������ ������ ������ 
			CALL DISP			

			MOV AX,BX		;����� ������ ������
			LEA SI,[TEMPSTR]
			CALL TOSTR

			MOV DX,SI			
			CALL DISP		
			
			;������� �������
			;*******************************

			.COLUMNS:
				LEA DX,[ENTSTR]		;������� ������
				CALL DISP
					
				LEA DX,[COLUMNSTR]	;����������� ������ ������ ������ 
				CALL DISP			

				MOV AX,CX		;����� ������ ������
				LEA SI,[TEMPSTR]
				CALL TOSTR
				
				MOV DX,SI			
				CALL DISP
				
				LEA DX,[SPACESTR]	;����� �������
				CALL DISP

				CALL INPUT		;���� ��������, ������������ ����������� � �������
				LEA SI,[INPSTR]
				CALL TONUM				
				
				LEA SI,[MAT]
				CALL SETMATEL
				
				INC CX
				CMP CX,M
			JNE .COLUMNS

			;********************************
			
			XOR CX,CX		;�������� ����� �������
			INC BX			;����������� BX
			CMP BX,N		;���� �� ����� ���-�� �����
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

	;������� ����� �� ������� (BX -> i, CX -> j) � AX
	GETMATEL PROC
		
		PUSH DX
		PUSH BX
		PUSH CX

		MOV AX,M	;��������� ���-�� �������� � AX
		IMUL BX		;�������� BX �� AX  � ��������� ��������� � DX:AX
		ADD AX,CX

		MOV BX,AX	;����������� AX � BX
		SHL BX,1	;�������� �� ���
				
		MOV AX,[SI+BX]
		
		POP CX
		POP BX
		POP DX		

		RET
	GETMATEL ENDP


;________________________________________________________



CODESG ENDS
END MAIN
