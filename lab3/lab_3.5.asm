; ---------------------------------------------------------
; TASK 3.5:
; Write an assembly program that will read a decimal number and display this number in octal notation
; ---------------------------------------------------------
.686
.model flat

extern __write : PROC
extern __read : PROC
extern _ExitProcess@4 : PROC
public _main

; ---------------------------------------------------------
; Data section - define memory buffers and constants
; ---------------------------------------------------------
.data
    input_msg db "Enter decimal number: $" ; Prompt for user input
    error_msg db "Error: Invalid input!", 0Ah ; Error message
    buffer db 50 dup(?)                     ; Buffer for user input (up to 50 characters)
    number dd 0                             ; Variable to store the converted decimal number
    octal_result db 50 dup(?)               ; Buffer for storing the octal conversion result
    ten dd 10                               ; Constant value 10 (for decimal base)
    eight dd 8                              ; Constant value 8 (for octal base)

; ---------------------------------------------------------
; Code section - define procedures and main logic
; ---------------------------------------------------------
.code

; ---------------------------------------------------------
; Procedure read_decimal: Reads a decimal number from input
; ---------------------------------------------------------
read_decimal PROC
    push ebp                      ; Save base pointer
    mov ebp, esp                  ; Set stack frame

    ; Read input from console into buffer
    push 50                       ; Max number of characters to read
    push offset buffer            ; Address of the buffer
    push 0                        ; Device ID for keyboard input
    call __read                   ; Call __read to get input
    add esp, 12                   ; Clean up stack

    ; Initialize registers for conversion
    xor ecx, ecx                  ; Clear ECX (loop counter)
    xor eax, eax                  ; Clear EAX (to accumulate the result)
    mov esi, offset buffer        ; Load the address of the buffer into ESI

process_digit:
    movzx ebx, byte ptr [esi + ecx] ; Load next character from buffer into BL
    cmp bl, 0Ah                   ; Check if the character is a newline (Enter key)
    je conversion_done            ; If newline, end of input reached

    ; Validate if character is a digit
    cmp bl, '0'                   ; Check if character >= '0'
    jb invalid_digit              ; If less than '0', invalid input
    cmp bl, '9'                   ; Check if character <= '9'
    ja invalid_digit              ; If greater than '9', invalid input

    ; Perform arithmetic: Multiply accumulated result by 10 and add the new digit
    push edx                      ; Save EDX since MUL modifies it
    mul dword ptr [ten]           ; Multiply EAX by 10 (base-10 shift)
    pop edx                       ; Restore EDX
    jo number_too_large           ; Jump if overflow occurs

    sub bl, '0'                   ; Convert ASCII character to digit (0-9)
    add eax, ebx                  ; Add the digit to the result
    jo number_too_large           ; Jump if overflow occurs

    inc ecx                       ; Move to the next character in buffer
    jmp process_digit             ; Loop back to process the next digit

invalid_digit:
number_too_large:
    mov eax, -1                   ; Set EAX to -1 to indicate an error
    jmp read_exit                 ; Jump to exit the procedure

conversion_done:
    mov dword ptr [number], eax   ; Store the valid decimal number in 'number' variable

read_exit:
    mov esp, ebp                  ; Restore stack frame
    pop ebp                       ; Restore base pointer
    ret                           ; Return from procedure
read_decimal ENDP

; ---------------------------------------------------------
; Procedure convert_to_octal: Converts the decimal number in 'number' to octal and displays it
; ---------------------------------------------------------
convert_to_octal PROC
    push ebp                      ; Save base pointer
    mov ebp, esp                  ; Set up stack frame

    mov eax, [number]             ; Load the decimal number into EAX
    mov edi, offset octal_result  ; Load the address of the result buffer into EDI
    xor ecx, ecx                  ; Clear ECX (to count digits in the result)

convert_loop:
    xor edx, edx                  ; Clear EDX for DIV operation
    div dword ptr [eight]         ; Divide EAX by 8 (octal conversion)
    add dl, '0'                   ; Convert remainder to ASCII ('0'-'7')
    push edx                      ; Store the digit on the stack temporarily
    inc ecx                       ; Increment digit count
    test eax, eax                 ; Check if the quotient is zero
    jnz convert_loop              ; Repeat until the quotient is zero

store_digits:
    pop edx                       ; Retrieve the digit from stack
    mov [edi], dl                 ; Store the digit in the result buffer
    inc edi                       ; Move to the next position in the buffer
    loop store_digits             ; Repeat for all stored digits

    mov byte ptr [edi], 0Ah       ; Append newline character at the end
    inc edi                       ; Move EDI to end of result

    ; Display the result buffer
    mov ecx, edi                  ; Calculate the number of characters in result
    sub ecx, offset octal_result  ; Subtract base address to get length
    push ecx                      ; Push length onto the stack
    push offset octal_result      ; Push the result buffer address onto the stack
    push 1                        ; Device ID (1 for screen)
    call __write                  ; Call __write to display the octal result
    add esp, 12                   ; Clean up stack

    mov esp, ebp                  ; Restore stack frame
    pop ebp                       ; Restore base pointer
    ret                           ; Return from procedure
convert_to_octal ENDP

; ---------------------------------------------------------
; Main procedure _main: Reads input, converts to octal, and displays result or error
; ---------------------------------------------------------
_main PROC
    call read_decimal             ; Call procedure to read decimal input
    cmp eax, -1                   ; Check if read_decimal returned an error
    je error_exit                 ; If error, jump to error handling

    call convert_to_octal         ; Convert valid decimal input to octal and display it

normal_exit:
    push 0                        ; Push exit code 0
    call _ExitProcess@4           ; Exit program normally

error_exit:
    ; Display error message if input was invalid
    push 19                       ; Length of error message
    push offset error_msg         ; Address of error message
    push 1                        ; Device ID (1 for screen)
    call __write                  ; Call __write to display the error
    add esp, 12                   ; Clean up stack

    ; Exit program with error code
    push 1                        ; Push exit code 1 for error
    call _ExitProcess@4           ; Exit program with error code
_main ENDP

END                               ; End of program
