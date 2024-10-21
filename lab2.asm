.686
.model flat
extern _ExitProcess@4 : PROC
extern _MessageBoxA@16 : PROC
extern _MessageBoxW@16 : PROC
extern __write : PROC
extern __read : PROC 
public _main

.data
tekst_pocz db 10, 'Prosz',0A9H,' ','napisa',086H,' ','jaki',098H,' ','tekst '
db 'i nacisnac Enter', 10
koniec_t db ?
buffor db 80 dup (?)
output db 320 dup (?)
liczba_znakow dd ?

msgbox_title db 'Answer - ASCII ', 0
msgbox_text db 160 dup(0)

.code
_main PROC
 mov ecx,(OFFSET koniec_t) - (OFFSET tekst_pocz)
 push ecx
 push OFFSET tekst_pocz
 push 1
 call __write
 add esp, 12
 push 120
 push OFFSET buffor
 push 0
 call __read
 add esp, 12

 mov liczba_znakow, eax
 mov ecx, eax
 mov ebx, 0
 mov edi, 0

ptl: 
 mov dl, buffor[ebx]

 cmp dl, 0Ah
 je dalej

 cmp dl, 'A'
 jb check_polish
 cmp dl, 'Z'
 jbe lower

 cmp dl, 'a'
 jb check_polish
 cmp dl, 'z'
 ja check_polish 
 sub dl, 20H
 jmp store_char

lower:
    add dl, 20H
    jmp store_char

check_polish:
    cmp dl, 0A4H    ;•      
    je set_a
    cmp dl, 08FH    ;∆
    je set_c
    cmp dl, 0A8H    ; 
    je set_e
    cmp dl, 09DH    ;£
    je set_l
    cmp dl, 0E3H    ;—
    je set_n
    cmp dl, 0E0H    ;”
    je set_o
    cmp dl, 097H    ;å
    je set_s
    cmp dl, 08DH    ;è
    je set_z1
    cmp dl, 0BDH    ;Ø
    je set_z2

    cmp dl, 0A5H    ;π      
    je set_A1
    cmp dl, 086H    ;Ê
    je set_C1
    cmp dl, 0A9H    ;Í
    je set_E1
    cmp dl, 088H    ;≥
    je set_L1
    cmp dl, 0E4H    ;Ò
    je set_N1
    cmp dl, 0A2H    ;Û
    je set_O1
    cmp dl, 098H    ;ú
    je set_S1
    cmp dl, 0ABH    ;ü
    je set_Z11
    cmp dl, 0BEH    ;ø
    je set_Z21

    jb not_letter
    ;jmp store_char

set_a:
    mov dl, 0B9H    ;π
    jmp store_char
set_c:
    mov dl, 0E6H    ;Ê
    jmp store_char
set_e:
    mov dl, 0EAH    ;Í
    jmp store_char
set_l:
    mov dl, 0B3H    ;≥
    jmp store_char
set_n:
    mov dl, 0F1H    ;Ò
    jmp store_char
set_o:
    mov dl, 0F3H    ;Û
    jmp store_char
set_s:
    mov dl, 09CH    ;ú
    jmp store_char
set_z1:
    mov dl, 09FH    ;ü
    jmp store_char
set_z2:
    mov dl, 0BFH    ;ø
    jmp store_char
         

set_A1:
    mov dl, 0A5H    ;•
    jmp store_char
set_C1:
    mov dl, 0C6H    ;∆
    jmp store_char
set_E1:
    mov dl, 0CAH    ; 
    jmp store_char
set_L1:
    mov dl, 0A3H    ;£
    jmp store_char
set_N1:
    mov dl, 0D1H    ;—
    jmp store_char
set_O1:
    mov dl, 0D3H    ;”
    jmp store_char
set_S1:
    mov dl, 08CH    ;å
    jmp store_char
set_Z11:
    mov dl, 08FH    ;è
    jmp store_char
set_Z21:
    mov dl, 0AFH    ;Ø
    jmp store_char

not_letter: 
    mov dl, '*'
    jmp store_char            

store_char:
    mov output[edi], dl 
    inc edi

dalej:
    inc ebx
    dec ecx
    jnz ptl

    push liczba_znakow
    push edi

    lea esi, output
    lea edi, msgbox_text
    mov ecx, liczba_znakow
    rep movsb

    push 0
    push OFFSET msgbox_title
    push OFFSET msgbox_text
    push 0
    call _MessageBoxA@16

    push 0
    call _ExitProcess@4

_main ENDP
END