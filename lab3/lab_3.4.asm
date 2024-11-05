; ---------------------------------------------------------
; TASK 3.4:
; Write an assembly program that will read a decimal number from the keyboard and
; will display its hexadecimal representation on the screen.
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
    dekoder db '0123456789ABCDEF' ; Table for hex character conversion
    obszar db 12 dup (?)          ; Reserve 12 bytes for input storage
    dziesiec dd 10                ; Constant value 10 for decimal multiplication

; ---------------------------------------------------------
; Code section - defines the procedures and main logic
; ---------------------------------------------------------
.code

; ---------------------------------------------------------
; Procedure wyswietl_EAX_hex: Converts EAX to hexadecimal and displays it
; ---------------------------------------------------------
wyswietl_EAX_hex PROC
    pusha                       ; Save all general-purpose registers

    ; Reserve 12 bytes on the stack for temporary storage of hex digits
    sub esp, 12                 ; Adjust ESP to create space on the stack
    mov edi, esp                ; Store the base address of the allocated area in EDI

    ; Initialize the loop for conversion
    mov ecx, 8                  ; Set loop counter to 8 (for 8 hex digits)
    mov esi, 1                  ; Starting index to store hex digits in the temporary area

ptl3hex:
    ; Rotate EAX left by 4 bits to bring the next hex digit to the lower nibble
    rol eax, 4

    ; Extract the lowest 4 bits to convert to a hex digit
    mov ebx, eax                ; Copy EAX to EBX
    and ebx, 0000000FH          ; Mask out all but the lowest 4 bits in EBX
    mov dl, dekoder[ebx]        ; Use the value in EBX as an index into 'dekoder' to get the hex digit

    ; Store the hex digit in the temporary buffer
    mov [edi][esi], dl          ; Store the hex character at the current position
    inc esi                     ; Move to the next position in the buffer
    loop ptl3hex                ; Repeat for all 8 hex digits

    ; Insert newline characters before and after the hex digits
    mov byte PTR [edi][0], 10   ; Insert newline character at the start
    mov byte PTR [edi][9], 10   ; Insert newline character at the end

    ; Display the hex digits on the screen
    push 10                     ; Length of data to display (8 digits + 2 newline characters)
    push edi                    ; Address of the buffer containing hex digits
    push 1                      ; Device ID (1 for screen)
    call __write                ; Call __write to display the data

    ; Clean up stack
    add esp, 24                 ; Remove 24 bytes (12 for local buffer, 12 for function arguments)

    popa                        ; Restore all general-purpose registers
    ret                         ; Return from procedure

wyswietl_EAX_hex ENDP           ; End of wyswietl_EAX_hex procedure

; ---------------------------------------------------------
; Procedure wczytaj_do_EAX: Reads a decimal number from input and stores it in EAX
; ---------------------------------------------------------
wczytaj_do_EAX PROC
    push dword PTR 12           ; Number of characters to read
    push dword PTR OFFSET obszar ; Address of input buffer
    push dword PTR 0            ; Device ID (0 for keyboard input)
    call __read                 ; Call __read to read input from keyboard
    add esp, 12                 ; Clean up parameters from the stack

    ; Initialize registers for conversion
    mov eax, 0                  ; Initialize EAX to 0 (starting number)
    mov ebx, OFFSET obszar      ; Load address of input buffer into EBX

pobieraj_znaki:
    mov cl, [ebx]               ; Load next ASCII character from buffer
    inc ebx                     ; Move to the next character in buffer
    cmp cl, 10                  ; Check if Enter (newline) is pressed
    je byl_enter                ; Jump to end if Enter is pressed
    sub cl, 30H                 ; Convert ASCII code to digit (0-9)
    movzx ecx, cl               ; Move digit to ECX as zero-extended value

    ; Multiply current EAX by 10 (shift decimal place left)
    mul dword PTR dziesiec      ; Multiply EAX by 10
    add eax, ecx                ; Add the digit to EAX

    jmp pobieraj_znaki          ; Repeat for the next character in buffer

byl_enter:
    ; The decimal value entered is now in EAX
    ret                         ; Return from procedure

wczytaj_do_EAX ENDP             ; End of wczytaj_do_EAX procedure

; ---------------------------------------------------------
; Main procedure _main: Reads input, displays it as hex, and exits
; ---------------------------------------------------------
_main PROC
    call wczytaj_do_EAX         ; Call procedure to read and convert input
    call wyswietl_EAX_hex       ; Call procedure to display EAX as hexadecimal

    ; -------------------------------------------------
    ; Exit the program by calling _ExitProcess@4
    ; -------------------------------------------------
    push 0                      ; Push exit code 0 onto the stack
    call _ExitProcess@4         ; Call Windows API to exit process

_main ENDP                      ; End of _main procedure

END                             ; End of program
