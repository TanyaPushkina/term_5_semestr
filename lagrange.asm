.686
option casemap:none
.MODEL FLAT, C
.data
denominator dq 0
pol1	dq 256 dup(0)
pol2	dq 0,0
C_		dq 256 dup(0)
.CODE
public  Lagrange	;���������� �������, ����� �� ������ ������ ����� ����
;������� ��� ������� �������� ��������
Lagrange PROC x_values:dword, y_values:dword, n:dword, x:qword, coefficients:dword, basisPolynomials:dword
		push edi		; ��������� ��������. �� ���������� �� ebx, esi, edi ������ �����������
		push esi
		push ebx
		;������� �������������
		mov edi,coefficients
		mov eax,0
		mov ecx,n
		shl ecx,1
		rep stosd
;���������� �������� ���������
;BasisPolynomials(x_values, n, x, basisPolynomials);
		push basisPolynomials
		fld x
		sub esp,8
		fstp qword ptr [esp]
		push n
		push x_values
		call BasisPolynomials
		add esp,20

;���������� ������������� ��������
		mov edx,0		;i=0
l2:		cmp edx,n		;���� i>=n
		jge m4			;��������� ����
		;������� �
		lea edi,C_
		mov eax,0
		mov ecx,n
		shl ecx,1
		rep stosd
		fld1
		fst C_			;C[0] = 1
		fstp denominator	;denominator = 1.0
		mov ebx,0		;j=0
l3:		cmp ebx,n		;���� j>=n
		jge m5			;��������� ����
		cmp edx,ebx		;if (j != i) 
		jz sk2
		fld1
		fstp pol2+8		;pol2[1] = 1;
		mov eax,x_values
		fld qword ptr [eax+ebx*8]	;x_values[j]
		fchs						;-x_values[j]
		fstp pol2					;pol2[0] = -x_values[j];
		lea esi,C_
		;pol1=C
		lea edi,pol1
		mov ecx,n
		shl ecx,1
		rep movsd
;��������� ��������� �=pol1*pol2
		;�������� �
		lea edi,C_
		mov eax,0
		mov ecx,n
		shl ecx,1
		rep stosd
		mov ecx,0		;k=0
l4:		mov eax,n		;n
		dec eax			;n-1
		cmp ecx,eax		;���� k>=n-1
		jge m6			;��������� ����
		mov esi,0		;p=0
l5:		fld pol1[ecx*8]	;pol1[k]
		fmul pol2[esi*8]	;pol1[k] * pol2[p]
		lea eax,[ecx+esi]
		fadd C_[eax*8]	;C[k + p] + pol1[k] * pol2[p]
		fstp C_[eax*8]	;C[k + p] += pol1[k] * pol2[p]

		inc esi			;p++
		cmp esi,2		;���� p < 2
		jl l5			;���������� ����

		inc ecx			;k++
		jmp l4			;���������� ����
m6:		mov eax,x_values			
		fld qword ptr[eax+edx*8]	;x_values[i]
		fsub qword ptr[eax+ebx*8]	;x_values[i] - x_values[j]
		fmul denominator			;denominator * (x_values[i] - x_values[j])
		fstp denominator			;denominator *= (x_values[i] - x_values[j])

sk2:	inc ebx			;j++
		jmp l3			;���������� ����
m5:
		mov ebx,0		;j=0
l6:		cmp ebx,n		;���� j>=n
		jge m7			;��������� ����

		mov eax,y_values
		fld qword ptr [eax+edx*8]	;y_values[i]
		fdiv denominator			;y_values[i] / denominator
		fmul C_[ebx*8]				;C[j] * y_values[i] / denominator
		fstp C_[ebx*8]				;C[j] *= y_values[i] / denominator
		mov eax,coefficients
		fld qword ptr [eax+ebx*8]	;coefficients[j]
		fadd C_[ebx*8]				;coefficients[j] + C[j]
		fstp qword ptr [eax+ebx*8]	;coefficients[j] += C[j]
		inc ebx			;j++
		jmp l6			;���������� ����
m7:		inc edx			;i++
		jmp l2			;���������� ����
m4:
;���������� �������� �������� � ����� x
		fldz
		mov edx,0		;i=0
l1:		cmp edx,n		;���� i>=n
		jge m3			;��������� ����
		mov eax,y_values	
		fld qword ptr [eax+edx*8]	;y_values[i]
		mov eax,basisPolynomials
		fmul qword ptr [eax+edx*8]	;y_values[i] * basisPolynomials[i]
		fadd						;polynomialValue += y_values[i] * basisPolynomials[i]
		inc edx						;i++
		jmp l1						;���������� ����
m3:;� st0 ��������� �������� �������� � ����� x
		pop ebx
		pop esi
		pop edi			;������������ ��������
		ret
Lagrange ENDP
;������� ��� ���������� �������� ��������� L_i(x)
BasisPolynomials proc	x_values:dword, n:dword, x:qword, basisPolynomials:dword
		push edi		; ��������� ��������. �� ���������� �� ebx, esi, edi ������ �����������
		mov edi,x_values
		mov edx,0		;i=0
lpi:	cmp edx,n		;���� i>=n
		jge m1			;��������� ����
		fld1			;L_i = 1.0;
		mov ecx,0		;j=0
lpj:	cmp ecx,n		;���� j>=n
		jge m2			;��������� ����
		cmp ecx,edx		;if (i != j){
		jz sk1
		fld x						;x
		fsub qword ptr[edi+ecx*8]	;(x - x_values[j])
		fld qword ptr[edi+edx*8]	;x_values[i]
		fsub qword ptr[edi+ecx*8]	;(x_values[i] - x_values[j])
		fdiv						;(x - x_values[j]) / (x_values[i] - x_values[j])
		fmul						;L_i *= (x - x_values[j]) / (x_values[i] - x_values[j])
sk1:	inc ecx						;j++
		jmp lpj						;���������� ����
m2:		mov eax,basisPolynomials	
		fstp qword ptr[eax+edx*8]	;basisPolynomials[i] = L_i
		inc edx						;i++
		jmp lpi						;���������� ����
m1:
		pop edi			;������������ ��������
		ret
BasisPolynomials endp
END