.686
option casemap:none
.MODEL FLAT, C
.data
denominator dq 0
pol1	dq 256 dup(0)
pol2	dq 0,0
C_		dq 256 dup(0)
.CODE
public  Lagrange	;объявление функции, чтобы ее видела сишная часть кода
;Функция для расчета полинома Лагранжа
Lagrange PROC x_values:dword, y_values:dword, n:dword, x:qword, coefficients:dword, basisPolynomials:dword
		push edi		; сохранить регистры. По соглашению си ebx, esi, edi должны сохраняться
		push esi
		push ebx
		;очистка коэффициентов
		mov edi,coefficients
		mov eax,0
		mov ecx,n
		shl ecx,1
		rep stosd
;Вычисление базисных полиномов
;BasisPolynomials(x_values, n, x, basisPolynomials);
		push basisPolynomials
		fld x
		sub esp,8
		fstp qword ptr [esp]
		push n
		push x_values
		call BasisPolynomials
		add esp,20

;Вычисление коэффициентов полинома
		mov edx,0		;i=0
l2:		cmp edx,n		;если i>=n
		jge m4			;закончить цикл
		;очистка С
		lea edi,C_
		mov eax,0
		mov ecx,n
		shl ecx,1
		rep stosd
		fld1
		fst C_			;C[0] = 1
		fstp denominator	;denominator = 1.0
		mov ebx,0		;j=0
l3:		cmp ebx,n		;если j>=n
		jge m5			;закончить цикл
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
;умножение полиномов С=pol1*pol2
		;обнулить С
		lea edi,C_
		mov eax,0
		mov ecx,n
		shl ecx,1
		rep stosd
		mov ecx,0		;k=0
l4:		mov eax,n		;n
		dec eax			;n-1
		cmp ecx,eax		;если k>=n-1
		jge m6			;закончить цикл
		mov esi,0		;p=0
l5:		fld pol1[ecx*8]	;pol1[k]
		fmul pol2[esi*8]	;pol1[k] * pol2[p]
		lea eax,[ecx+esi]
		fadd C_[eax*8]	;C[k + p] + pol1[k] * pol2[p]
		fstp C_[eax*8]	;C[k + p] += pol1[k] * pol2[p]

		inc esi			;p++
		cmp esi,2		;пока p < 2
		jl l5			;продолжить цикл

		inc ecx			;k++
		jmp l4			;продолжить цикл
m6:		mov eax,x_values			
		fld qword ptr[eax+edx*8]	;x_values[i]
		fsub qword ptr[eax+ebx*8]	;x_values[i] - x_values[j]
		fmul denominator			;denominator * (x_values[i] - x_values[j])
		fstp denominator			;denominator *= (x_values[i] - x_values[j])

sk2:	inc ebx			;j++
		jmp l3			;продолжить цикл
m5:
		mov ebx,0		;j=0
l6:		cmp ebx,n		;если j>=n
		jge m7			;закончить цикл

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
		jmp l6			;продолжить цикл
m7:		inc edx			;i++
		jmp l2			;продолжить цикл
m4:
;Вычисление значения полинома в точке x
		fldz
		mov edx,0		;i=0
l1:		cmp edx,n		;если i>=n
		jge m3			;закончить цикл
		mov eax,y_values	
		fld qword ptr [eax+edx*8]	;y_values[i]
		mov eax,basisPolynomials
		fmul qword ptr [eax+edx*8]	;y_values[i] * basisPolynomials[i]
		fadd						;polynomialValue += y_values[i] * basisPolynomials[i]
		inc edx						;i++
		jmp l1						;продолжить цикл
m3:;в st0 находится значение полинома в точке x
		pop ebx
		pop esi
		pop edi			;восстановить регистры
		ret
Lagrange ENDP
;Функция для вычисления базисных полиномов L_i(x)
BasisPolynomials proc	x_values:dword, n:dword, x:qword, basisPolynomials:dword
		push edi		; сохранить регистры. По соглашению си ebx, esi, edi должны сохраняться
		mov edi,x_values
		mov edx,0		;i=0
lpi:	cmp edx,n		;если i>=n
		jge m1			;закончить цикл
		fld1			;L_i = 1.0;
		mov ecx,0		;j=0
lpj:	cmp ecx,n		;если j>=n
		jge m2			;закончить цикл
		cmp ecx,edx		;if (i != j){
		jz sk1
		fld x						;x
		fsub qword ptr[edi+ecx*8]	;(x - x_values[j])
		fld qword ptr[edi+edx*8]	;x_values[i]
		fsub qword ptr[edi+ecx*8]	;(x_values[i] - x_values[j])
		fdiv						;(x - x_values[j]) / (x_values[i] - x_values[j])
		fmul						;L_i *= (x - x_values[j]) / (x_values[i] - x_values[j])
sk1:	inc ecx						;j++
		jmp lpj						;продолжить цикл
m2:		mov eax,basisPolynomials	
		fstp qword ptr[eax+edx*8]	;basisPolynomials[i] = L_i
		inc edx						;i++
		jmp lpi						;продолжить цикл
m1:
		pop edi			;восстановить регистры
		ret
BasisPolynomials endp
END