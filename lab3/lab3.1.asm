; ---------------------------------------------------------
; TASK 3.1:
; write an assembly program that will display the initial 50 on the screen
; elements of the number sequence: 1, 2, 4, 7, 11, 16, 22, ...
; ---------------------------------------------------------
.686
.model flat

extern __write : PROC
extern _ExitProcess@4 : PROC
extern _MessageBoxA@16 : PROC
public _main

; ---------------------------------------------------------
; Data section - defines a buffer for characters
; ---------------------------------------------------------
.data
    znaki db 12 dup (?) ; Allocate a buffer of 12 bytes to store characters for display

; ---------------------------------------------------------
; Code section - defines the procedures and main logic
; ---------------------------------------------------------
.code

; ---------------------------------------------------------
; Procedure wyswietl_EAX: Converts EAX register value to ASCII and displays it
; ---------------------------------------------------------
wyswietl_EAX PROC
    pusha                ; Save all general-purpose registers

    ; Set up constants for conversion
    mov esi, 10         ; Initialize index for 'znaki' buffer
    mov ebx, 10         ; Set divisor to 10 for decimal conversion

    ; -----------------------------
    ; Loop to convert EAX to ASCII
    ; -----------------------------
konwersja:
    mov edx, 0          ; Clear higher part of dividend for division
    div ebx             ; Divide EAX by 10 (quotient in EAX, remainder in EDX)

    add dl, 30H         ; Convert remainder to ASCII ('0' = 30H in ASCII)

    mov znaki[esi], dl  ; Store ASCII digit in 'znaki' buffer
    dec esi             ; Move to the next position in the buffer
    cmp eax, 0          ; Check if quotient is zero
    jne konwersja       ; If not zero, continue conversion

    ; -------------------------------------------------
    ; Fill remaining bytes in buffer with spaces (ASCII 20H)
    ; -------------------------------------------------
wypeln:
    or esi, esi         ; Check if esi is zero (end of buffer)
    jz wyswietl         ; Jump if esi is zero, proceed to display
    mov byte PTR znaki[esi], 20H ; Fill with space character
    dec esi             ; Move to the next position in buffer
    jmp wypeln          ; Repeat until buffer is filled

    ; -------------------------------------------------
    ; Display the converted ASCII characters on screen
    ; -------------------------------------------------
wyswietl:
    mov byte PTR znaki[0], 0AH   ; Add newline at beginning of buffer
    mov byte PTR znaki[11], 0AH  ; Add newline at end of buffer

    ; Prepare and call __write to display buffer contents
    push dword PTR 12            ; Number of characters to display
    push dword PTR OFFSET znaki  ; Address of buffer to display
    push dword PTR 1             ; Device ID (1 = console/screen)
    call __write                 ; Call __write to display the number

    add esp, 12                  ; Clean up parameters from the stack
    popa                         ; Restore all general-purpose registers
    ret                          ; Return from procedure

wyswietl_EAX ENDP                ; End of wyswietl_EAX procedure

; ---------------------------------------------------------
; Main procedure _main: Initializes loop and increments
; ---------------------------------------------------------
_main PROC
    mov eax, 1                   ; Initialize EAX to 1 (starting value)
    mov ebx, 1                   ; Initialize EBX to 1 (increment value)
    mov ecx, 50                  ; Set loop counter to 50 iterations

ptl:
    call wyswietl_EAX            ; Call procedure to display EAX value
    add eax, ebx                 ; Increment EAX by the current EBX
    inc ebx                      ; Increment EBX for the next cycle
    loop ptl                     ; Decrement ECX and loop if non-zero

    ; -------------------------------------------------
    ; Exit the program by calling _ExitProcess@4
    ; -------------------------------------------------
    push 0                       ; Push exit code 0 onto the stack
    call _ExitProcess@4          ; Call Windows API to exit process

_main ENDP                       ; End of _main procedure

END                              ; End of program
