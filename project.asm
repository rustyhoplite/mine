section .text
    global _start

_start:
    mov rdi, 0x0      ; file descriptor = stdin = 0
    lea rsi, [rsp+8]  ; buffer = address to store the bytes read
    mov rdx, 0x2      ; number of bytes to read
    mov rax, 0x0      ; SYSCALL number for reading from STDIN
    syscall           ; make the syscall

    xor rax, rax      ; clear off rax
    mov rbx, [rsp+8]  ; read the first byte read into rsp+8 by STDIN call to rbp
    sub rbx, 0x30     ; Since this is read as a character, it is obtained as ASCII value, so subtract by 0x30 to get the number
    and rbx, 0xff     ; This ensures that everything other than the last byte is set to 0 while the last byte is as is
    mov rax, rbx      ; move this value to rax since we want to store the final result in rax
    shl rbx, 0x1      ; We need to multiply this by 10 so that we can add up all the digits read so multiplying the number by 2 and then by 8 and adding them up, so multiply by 2 here
    shl rax, 0x3      ; multiply by 8 here
    add rax, rbx      ; add 8 times multiplied value with 2 times multiplied value to get 10 times multiplied value
    mov rbx, [rsp+9]  ; now read the next byte (or digit)
    sub rbx, 0x30     ; Again get the digit value from ASCII value of that digit's character
    and rbx, 0xff     ; clear higher bytes
    add rax, rbx      ; Add this to rax as unit's place value
    mov [rsp+8], rax  ; Move the entire byte to rax
    mov rdi, 0x1      ; file descriptor = stdout
    lea rsi, [rsp+8]  ; buffer = address to write to console
    mov rdx, 0x1      ; number of bytes to write
    mov rax, 0x1      ; SYSCALL number for writing to STDOUT
    syscall           ; make the syscall

    xor rax, rax      ; clear off rax
    mov rax, 0xa      ; move the new line character to rax
    mov [rsp+8], rax  ; put this on the stack
    mov rdi, 0x1      ; file descriptor = stdout
    lea rsi, [rsp+8]  ; buffer = address to write to console
    mov rdx, 0x1      ; number of bytes to write
    mov rax, 0x1      ; SYSCALL number for writing to STDOUT
    syscall           ; make the syscall

    mov rdi, 0        ; set exit status = 0
    mov rax, 60       ; SYSCALL number for EXIT
    syscall           ; make the syscall
EDIT 2: Here is my attempt to read an unsigned 32-bit decimal integer from standard input, store it as integer for computations and then write that back to std out.

section .text
        global _start

_start:
;Read from STDIN
        mov rdi, 0x0      ; file descriptor = stdin = 0
        lea rsi, [rsp+8]  ; buffer = address to store the bytes read
        mov rdx, 0xa      ; number of bytes to read
        mov rax, 0x0      ; SYSCALL number for reading from STDIN
        syscall           ; make the syscall


; Ascii to decimal conversion
        xor rax, rax      ; clear off rax
        mov rbx, 0x0      ; initialize the counter which stores the number of bytes in the string representation of the integer
        lea rsi, [rsp+8]  ; Get the address on the stack where the first ASCII byte of the integer is stored.

rnext:
        mov rcx, [rsi]    ; Read the byte on the stack at the address represented by rsi
        cmp rcx, 0xa      ; Check if it is a newline character
        je  return        ; If so we are done
        cmp rbx, 0xa      ; OR check if we have read 10 bytes (the largest 32 bit number contains 10 digits, so we will have to process at most 10 bytes
        jg  return        ; If so we are done
        sub rcx, 0x30     ; For the byte read, subtract by 0x30/48 to get the value from the ASCII code. 0 == 0x30 in ASCII, 1 == 0x31 in ASCII and so on.
        and rcx, 0xff     ; Clear off the higher order bytes to ensure there is no interference
        mov rdx, rax      ; We need to multiple this by 10 to get the next byte which goes to the unit's place and this byte becomes the ten's value. So make a copy
        shl rax, 0x3      ; Multiply the original by 8 (Shift left by 3 is multiply by 8)
        shl rdx, 0x1      ; Multiply the copy by 2 (Shift left by 1 is multiply by 2)
        add rax, rdx      ; Add these a * 8 + a * 2 to get a * 10.
        add rax, rcx      ; Add the digit to be at the units place to the original number
        add rsi, 1        ; Advance the memory address by 1 to read the next byte
        inc rbx           ; Increment the digit counter
        jmp rnext         ; Loop until we have read all the digits or max is reached.

return:
        push rax          ; Push the read number on to the stack

; write New Line
        mov rax, 0xa      ; move the new line character to rax
        mov [rsp+8], rax  ; put this on the stack
        mov rdi, 0x1      ; file descriptor = stdout
        lea rsi, [rsp+8]  ; buffer = address to write to console
        mov rdx, 0x1      ; number of bytes to write
        mov rax, 0x1      ; SYSCALL number for writing to STDOUT
        syscall           ; make the syscall


; Convert from Decimal to bytes
        xor  rdx, rdx     ; Clear rdx which stores obtains a single digit of the number to convert to ASCII bytes
        mov  r8, 0x0      ; Initialize the counter containing the number of digits

        pop  rax          ; Pop the read number from the stack
        mov  rbx, 0xa     ; We store the divisor which is 10 for decimals (base-10) in rbx. rbx will be the divisor.

wnext: 
        div  rbx          ; Divide the number in rdx:rax by rbx to get the remainder in rdx
        add  rdx, 0x30    ; Add 0x30 to get the ASCII byte equivalent of the remainder which is the digit in the number to be written to display.
        push rdx          ; Push this byte to the stack. We do this because, we get the individial digit bytes in reverse order. So to reverse the order we use the stack
        xor  rdx, rdx     ; Clear rdx preparing it for next division
        inc  r8           ; Increment the digits counter
        cmp  rax, 0x0     ; Continue until the number becomes 0 when there are no more digits to write to the console.
        jne  wnext        ; Loop until there aren't any more digits.

popnext:
        cmp  r8, 0x0      ; Check if the counter which contains the number of digits to write is 0
        jle  endw         ; If so there are no more digits to write
        mov  rdx, 0x1     ; number of bytes to write
        mov  rsi, rsp     ; buffer = address to write to console
        mov  rdi, 0x1     ; file descriptor = stdout
        mov  rax, 0x1     ; SYSCALL number for writing to STDOUT
        syscall           ; make the syscall
        dec  r8           ; Decrement the counter
        pop  rbx          ; Pop the current digit that was already written to the display preparing the stack pointer for next digit.
        jmp  popnext      ; Loop until the counter which contains the number of digits goes down to 0.

endw:
; write New Line
        xor rax, rax      ; clear off rax
        mov rax, 0xa      ; move the new line character to rax
        mov [rsp+9], rax  ; put this on the stack
        mov rdi, 0x1      ; file descriptor = stdout
        lea rsi, [rsp+9]  ; buffer = address to write to console
        mov rdx, 0x1      ; number of bytes to write
        mov rax, 0x1      ; SYSCALL number for writing to STDOUT
        syscall           ; make the syscall

; Exit
        mov rdi, 0        ; set exit status = 0
        mov rax, 60       ; SYSCALL number for EXIT
        syscall           ; make the syscall
