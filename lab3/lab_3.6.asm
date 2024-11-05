; ---------------------------------------------------------
; TASK 3.6:
; Write an assembly program that will read a hexadecimal number from the keyboard
; and will display its decimal representation on the screen.
; ---------------------------------------------------------
.686
.model flat

extern _ExitProcess@4 : PROC
extern __write : PROC
extern __read : PROC

public _main

; ---------------------------------------------------------
; Data Section
; ---------------------------------------------------------
.data
znaki db 12 dup (?)             ; Buffer for storing the formatted output

; ---------------------------------------------------------
; Code Section
; ---------------------------------------------------------
.code

; ---------------------------------------------------------
; Procedure wyswietl_EAX: Displays the decimal value in EAX
; ---------------------------------------------------------
wyswietl_EAX PROC
    pusha                       ; Save all registers

    ; Setup for converting EAX to ASCII in decimal
    mov esi, 10                 ; Index for filling `znaki` buffer from the end
    mov ebx, 10                 ; Divisor for base-10 conversion

konwersja:
    mov edx, 0                  ; Clear EDX for division
    div ebx                     ; Divide EAX by 10, remainder in EDX, quotient in EAX
    add dl, 30H                 ; Convert remainder to ASCII
    mov znaki[esi], dl          ; Store ASCII character in buffer
    dec esi                     ; Move buffer index left
    cmp eax, 0                  ; Check if quotient is zero
    jne konwersja               ; Repeat if quotient is not zero

; Fill remaining positions in the buffer with spaces
wypeln:
    or esi, esi                 ; Check if buffer index has reached 0
    jz wyswietl                 ; If zero, all positions are filled
    mov byte PTR znaki[esi], 20H ; Insert space character
    dec esi                     ; Move buffer index left
    jmp wypeln                  ; Repeat until the buffer is filled

wyswietl:
    mov byte PTR znaki[0], 0AH  ; Add newline at the start
    mov byte PTR znaki[11], 0AH ; Add newline at the end

    ; Display the buffer
    push dword PTR 12           ; Length of the buffer
    push dword PTR OFFSET znaki ; Address of the buffer
    push dword PTR 1            ; Device ID (1 for console)
    call __write                ; Call write to display the result
    add esp, 12                 ; Clean up stack

    popa                        ; Restore all registers
    ret                         ; Return from procedure
wyswietl_EAX ENDP

; ---------------------------------------------------------
; Procedure wczytaj_do_EAX_hex: Reads a hexadecimal number from input
; ---------------------------------------------------------
wczytaj_do_EAX_hex PROC
    ; Save registers
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp

    ; Reserve memory for 12 bytes on the stack
    sub esp, 12
    mov esi, esp                ; Store the address of the reserved space
    push dword PTR 10           ; Maximum number of characters to read
    push esi                    ; Address of the reserved space
    push dword PTR 0            ; Device ID for keyboard input
    call __read                 ; Read input from keyboard
    add esp, 12                 ; Clean up stack

    mov eax, 0                  ; Initialize EAX to 0 (for result accumulation)

pocz_konw:
    mov dl, [esi]               ; Load the next character
    inc esi                     ; Move to the next character
    cmp dl, 10                  ; Check if Enter was pressed (newline)
    je gotowe                   ; If Enter, end input

    ; Check if character is a digit (0-9)
    cmp dl, '0'                 ; If character < '0'
    jb pocz_konw                ; Ignore, continue with next character
    cmp dl, '9'                 ; If character > '9'
    ja sprawdzaj_dalej          ; Check if it is a letter (A-F or a-f)

    sub dl, '0'                 ; Convert ASCII digit to numeric value

dopisz:
    shl eax, 4                  ; Shift EAX left by 4 bits
    or al, dl                   ; Add the 4-bit value to EAX
    jmp pocz_konw               ; Repeat the conversion loop

; Check if character is an uppercase hex letter (A-F)
sprawdzaj_dalej:
    cmp dl, 'A'
    jb pocz_konw                ; Ignore if not within A-F or a-f
    cmp dl, 'F'
    ja sprawdzaj_dalej2
    sub dl, 'A' - 10            ; Convert ASCII letter to numeric hex value
    jmp dopisz                  ; Add to EAX

; Check if character is a lowercase hex letter (a-f)
sprawdzaj_dalej2:
    cmp dl, 'a'
    jb pocz_konw                ; Ignore if not a-f
    cmp dl, 'f'
    ja pocz_konw                ; Ignore if outside of valid range
    sub dl, 'a' - 10            ; Convert ASCII letter to numeric hex value
    jmp dopisz                  ; Add to EAX

gotowe:
    add esp, 12                 ; Free reserved memory on the stack
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret                         ; Return from procedure
wczytaj_do_EAX_hex ENDP

; ---------------------------------------------------------
; Main procedure: Calls input, multiply, and display procedures
; ---------------------------------------------------------
_main PROC
    call wczytaj_do_EAX_hex      ; Call to read hexadecimal input
    mul eax                      ; Multiply EAX by itself (square the value)
    call wyswietl_EAX            ; Display the result in decimal

    push 0                       ; Exit code 0
    call _ExitProcess@4          ; End the program
_main ENDP

END                             ; End of program
