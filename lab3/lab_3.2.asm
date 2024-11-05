; ---------------------------------------------------------
; TASK 3.2:
; write an assembly program that will read a decimal number and display this number in binary form
; ---------------------------------------------------------
.686
.model flat 

extern _ExitProcess@4 : PROC
extern __write : PROC
extern __read : PROC
public _main

; ---------------------------------------------------------
; Data section - defines memory buffers
; ---------------------------------------------------------
.data
    obszar dd 32 dup (?)       ; Reserve 32 dwords (128 bytes) for input storage
    znaki dd 32 dup (?)        ; Reserve 32 dwords for binary representation
    dziesiec dd 10             ; Constant value 10 for decimal multiplication

; ---------------------------------------------------------
; Code section - defines the procedures and main logic
; ---------------------------------------------------------
.code

; ---------------------------------------------------------
; Procedure wyswietl_EAX: Converts EAX to binary and displays it
; ---------------------------------------------------------
wyswietl_EAX PROC
    mov ecx, 32                ; Set loop counter to 32 (for 32 bits)
    mov ebx, OFFSET znaki      ; Load address of the znaki buffer into EBX
    mov edx, eax               ; Copy EAX value into EDX for manipulation

convert_to_binary:
    shl edx, 1                 ; Shift EDX left by 1, moving the next bit into CF
    mov al, '0'                ; Set AL to ASCII '0' as default character
    jc set_one                 ; If CF is set (bit was 1), jump to set_one
    jmp store_bit              ; Otherwise, proceed to store_bit

set_one:
    mov al, '1'                ; Set AL to ASCII '1' if CF was set

store_bit:
    mov [ebx], al              ; Store '0' or '1' in the znaki buffer
    inc ebx                    ; Move to the next position in the buffer
    loop convert_to_binary     ; Repeat for each bit until ECX reaches zero

    ; -------------------------------------------------
    ; Display the binary string stored in znaki buffer
    ; -------------------------------------------------
    push dword PTR 32          ; Number of characters to display
    push dword PTR OFFSET znaki; Address of the znaki buffer
    push dword PTR 1           ; Device ID (1 = console/screen)
    call __write               ; Call __write to display the binary value
    add esp, 12                ; Clean up parameters from the stack
    ret                        ; Return from procedure

wyswietl_EAX ENDP              ; End of wyswietl_EAX procedure

; ---------------------------------------------------------
; Procedure wczytaj_do_EAX: Reads a decimal number from input and stores in EAX
; ---------------------------------------------------------
wczytaj_do_EAX PROC
    push dword PTR 32          ; Number of characters to read
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
    jc overflow                ; If overflow, jump to handle overflow
    add eax, ecx               ; Add the digit to EAX
    jc overflow                ; If overflow, jump to handle overflow

    jmp pobieraj_znaki         ; Repeat for the next character in buffer

overflow:
    stc                        ; Set carry flag to indicate overflow
    mov eax, 0                 ; Reset EAX to 0 on overflow
    jmp byl_enter              ; Jump to end

byl_enter:
    ; The binary value of the entered decimal number is now in EAX
    ret                        ; Return from procedure

wczytaj_do_EAX ENDP            ; End of wczytaj_do_EAX procedure

; ---------------------------------------------------------
; Main procedure _main: Reads input, converts to binary, and displays it
; ---------------------------------------------------------
_main PROC
    call wczytaj_do_EAX        ; Call procedure to read and convert input
    call wyswietl_EAX          ; Call procedure to display EAX in binary

    ; -------------------------------------------------
    ; Exit the program by calling _ExitProcess@4
    ; -------------------------------------------------
    push 0                     ; Push exit code 0 onto the stack
    call _ExitProcess@4        ; Call Windows API to exit process

_main ENDP                     ; End of _main procedure

END                            ; End of program
