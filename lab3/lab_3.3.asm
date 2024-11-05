; ---------------------------------------------------------
; TASK 3.3:
; Write an assembly program that will read a decimal number less than from the keyboard
; 60000 and will display the square of this number on the screen.
; ---------------------------------------------------------
.686
.model flat

extern _ExitProcess@4 : PROC
extern __write : PROC
extern __read : PROC
public _main

; ---------------------------------------------------------
; Data section - defines memory buffers and constants
; ---------------------------------------------------------
.data
    obszar db 12 dup (?)       ; Reserve 12 bytes for input storage
    znaki db 12 dup (?)        ; Reserve 12 bytes for storing ASCII characters to display
    dziesiec dd 10             ; Constant value 10 for decimal multiplication

; ---------------------------------------------------------
; Code section - defines the procedures and main logic
; ---------------------------------------------------------
.code

; ---------------------------------------------------------
; Procedure wyswietl_EAX: Converts EAX to ASCII and displays it
; ---------------------------------------------------------
wyswietl_EAX PROC
    pusha                       ; Save all general-purpose registers

    ; Initialize variables for conversion
    mov esi, 10                ; Index for 'znaki' buffer (starting from the end)
    mov ebx, 10                ; Set divisor to 10 for decimal conversion

konwersja:
    mov edx, 0                 ; Clear higher part of dividend for division
    div ebx                    ; Divide EAX by 10 (quotient in EAX, remainder in EDX)

    add dl, 30H                ; Convert remainder to ASCII ('0' = 30H in ASCII)
    mov znaki[esi], dl         ; Store ASCII digit in 'znaki' buffer
    dec esi                    ; Move to the previous position in the buffer
    cmp eax, 0                 ; Check if quotient is zero
    jne konwersja              ; If not zero, continue conversion

wypeln:
    or esi, esi                ; Check if ESI is zero (start of buffer)
    jz wyswietl                ; Jump if ESI is zero, proceed to display
    mov byte PTR znaki[esi], 20H ; Fill with space character
    dec esi                    ; Move to the previous position in buffer
    jmp wypeln                 ; Repeat until buffer is filled

wyswietl:
    mov byte PTR znaki[0], 0AH ; Add newline at beginning of buffer
    mov byte PTR znaki[11], 0AH ; Add newline at end of buffer

    ; Prepare and call __write to display buffer contents
    push dword PTR 12          ; Number of characters to display
    push dword PTR OFFSET znaki ; Address of buffer to display
    push dword PTR 1           ; Device ID (1 = console/screen)
    call __write               ; Call __write to display the number
    add esp, 12                ; Clean up parameters from the stack
    popa                       ; Restore all general-purpose registers
    ret                        ; Return from procedure

wyswietl_EAX ENDP              ; End of wyswietl_EAX procedure

; ---------------------------------------------------------
; Procedure wczytaj_do_EAX: Reads a decimal number from input and stores in EAX
; ---------------------------------------------------------
wczytaj_do_EAX PROC
    push dword PTR 12          ; Number of characters to read
    push dword PTR OFFSET obszar ; Address of input buffer
    push dword PTR 0           ; Device ID (0 = keyboard input)
    call __read                ; Call __read to read input from keyboard
    add esp, 12                ; Clean up parameters from the stack

    ; Initialize registers for conversion
    mov eax, 0                 ; Initialize EAX to 0 (starting number)
    mov ebx, OFFSET obszar     ; Load address of input buffer into EBX

pobieraj_znaki:
    mov cl, [ebx]              ; Load next ASCII character from buffer
    inc ebx                    ; Move to the next character in buffer
    cmp cl, 10                 ; Check if Enter (newline) is pressed
    je byl_enter               ; Jump to end if Enter is pressed
    sub cl, 30H                ; Convert ASCII code to digit (0-9)
    movzx ecx, cl              ; Move digit to ECX as zero-extended value

    ; Multiply current EAX by 10 (shift decimal place left)
    mul dword PTR dziesiec     ; Multiply EAX by 10
    add eax, ecx               ; Add the digit to EAX

    jmp pobieraj_znaki         ; Repeat for the next character in buffer

byl_enter:
    ; The decimal value entered is now in EAX
    ret                        ; Return from procedure

wczytaj_do_EAX ENDP            ; End of wczytaj_do_EAX procedure

; ---------------------------------------------------------
; Main procedure _main: Reads input, squares it, and displays the result
; ---------------------------------------------------------
_main PROC
    call wczytaj_do_EAX        ; Call procedure to read and convert input
    mul eax                    ; Square the value in EAX by multiplying it by itself
    call wyswietl_EAX          ; Call procedure to display EAX as decimal

    ; -------------------------------------------------
    ; Exit the program by calling _ExitProcess@4
    ; -------------------------------------------------
    push 0                     ; Push exit code 0 onto the stack
    call _ExitProcess@4        ; Call Windows API to exit process

_main ENDP                     ; End of _main procedure

END                            ; End of program
