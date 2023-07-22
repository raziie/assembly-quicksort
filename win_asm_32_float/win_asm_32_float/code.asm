%include "asm_io.inc"
extern _scanf

segment .bss
; initialize array
array:	resd 100 	

segment .data
msg1:	dd "enter length of array:",0
msg2:	dd "elements:",0
msg3:	dd "invalid length",0
before:	dd "before:", 0
after:	dd "after:", 0
; for read_float
float_format: db  "%f", 0 
len:	dd 0

segment .text
        global  _asm_main
_asm_main:
        enter   0,0
        pusha

		; get length of array
		mov eax, msg1 
		call print_string
		call print_nl
		call read_int
		mov [len], eax

		cmp dword [len], 0
        jle invalid

		; get elements of array
		mov eax, msg2
		call print_string
		call print_nl

		; edi = index
		mov edi, 0
		mov ecx, [len]
l1:
		call read_float
		mov [array + 4*edi], eax
		inc edi
		loop l1	

		; print input array before sorting
		mov eax, before
		call print_string
		call print_nl
		push dword [len]
		push array
		call print_array
		add esp, 8

		; edx = index of last element
		mov edx, [len]
		dec edx

		; sorting array
		push array
		push 0
		push edx
		call sort
		add esp, 12

		; print input array after sorting
		mov eax, after
		call print_nl
		call print_string
		call print_nl
		push dword [len]
		push array
		call print_array
		add esp, 8
		jmp end	

invalid:
		mov eax, msg3
		call print_string
		call print_nl		

end:
        popa
        mov     eax, 0
        leave                     
        ret

sort:
		enter 0,0
		pusha

		; esi = low
		; edi = high
		mov esi, [ebp + 12] 
		mov edi, [ebp + 8] 
quicksort:
		; ecx = j
		; edx = i
		; if high <= low -> return
		cmp edi, esi
		jle end1
		; ecx = j = low - 1
		lea ecx, [esi - 1]
		; i = low
		mov edx, esi
		mov ebx, [ebp + 16]
loop1:	
		; comparing array[i], array[high]
		fld dword [ebx + 4*edi]
		fld dword [ebx + 4*edx]
		fcomip st1
		fstp st0
		; if array[i] > array[high] -> jump to begining of loop
		ja continue

		; j += 1
		; if i <= j -> jump to begining of loop
		add ecx, 1
		cmp edx, ecx
		jle continue
		
		; swap array[i], array[j]
		; array[i] = array[j] and then array[j] = array[i]
		fld dword [ebx + 4*edx]
		fld dword [ebx + 4*ecx]
		fstp dword [ebx + 4*edx]
		fstp dword [ebx + 4*ecx]
continue:
		; i++
		; if i <= high -> continue loop
		add edx, 1
		cmp edx, edi
		jle loop1

		; quickSort(array, low, j - 1)
part1:	
		push dword [ebp + 16]	
		push esi
		dec ecx
		push ecx
		inc ecx
		call sort
		add esp, 12
		
		; quickSort(array, j + 1, high)
part2:
		push dword [ebp + 16]	
		inc ecx
		push ecx
		dec ecx
		push edi
		call sort
		add esp, 12			 
end1:
		popa
		leave
		ret
			
print_array:		
		enter 0,0
		pusha

		mov ecx, [ebp + 12]
		mov ebx, [ebp + 8]
loop2:
		mov eax, [ebx]
		call print_float
		mov eax, ' '
		call print_char
		add ebx, 4
		loop loop2

		popa
		leave
		ret


read_float:
        enter 4,0
        pusha
        pushf
        lea eax, [ebp-4]
        push eax
        push dword float_format
        call _scanf
        pop eax
        pop eax
        popf
        popa
        mov eax, [ebp-4]
        leave
        ret	