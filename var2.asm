.model small
.stack 100h

.data
filename     db "test.in", 0

numbers      dw 10000 dup(0)  ; Масив для зберігання чисел
numCount     dw 0             ; Лічильник кількості чисел
oneChar      db 0
bufferIndex  db 0             ; Індекс для відстеження поточної позиції в буфері
inputBuffer  db 255 dup(?)    ; Буфер для зберігання одного рядка, максимум 255 символів
lineEnd      db 0Ah, 0Dh      ; Для перевірки кінця рядка (LF, CR)

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Відкриття файлу
    mov dx, offset filename
    mov ah, 3Dh
    mov al, 0
    int 21h

    ; Ініціалізація файлового дескриптора
    mov bx, ax

read_loop:
    ; Читання одного символу з файлу
    mov ah, 3Fh
    mov cx, 1            ; Читати 1 байт
    mov dx, offset oneChar
    int 21h
    cmp ax, 0            ; Перевірка на кінець файлу

    ; Обробка зчитаного символу
    cmp oneChar, 0Dh     ; Перевірка на CR
    je read_loop         ; Пропускаємо CR
    cmp oneChar, 0Ah     ; Перевірка на LF
    je process_number    ; Обробляємо число
    cmp oneChar, ' '     ; Перевірка на пробіл
    je read_loop         ; Пропускаємо пробіл
    ; Додаємо символ до буфера
    mov al, oneChar              ; Load the character to register AL
    mov si, offset inputBuffer   ; Get the starting address of the buffer
    add si, offset bufferIndex          ; Adjust SI to point to the current insert position
    mov [si], al                 ; Store the character in the buffer at the current position
    inc bufferIndex              ; Increment the bufferIndex for the next character
    ; Перевірка на переповнення буфера
    cmp bufferIndex, 255
    je process_number
    jmp read_loop

process_number:
    ; Конвертація рядка в число та додавання його до масиву numbers
    mov si, offset inputBuffer
    call atoi
    ; Перевірка чи не перевищено кількість чисел
    mov ax, numCount
    cmp ax, 10000
    jae atoi
    mov di, ax ; Додавання числа до масиву numbers
    shl di, 1 ; di = ax * 2
    mov [numbers + di], ax
   
    inc numCount            ; Збільшуємо лічильник чисел
    mov bufferIndex, 0 ; Очищення буфера
    jmp read_loop
atoi proc
    xor ax, ax               ; Очищення ax для результату
    xor bx, bx               ; bx буде використовуватись для знака
    mov cx, 10               ; База десяткової системи числення
    mov si, offset inputBuffer ; si вказує на початок буфера
    cmp byte ptr [si], '-'   ; Перевірка на від'ємне число
    jne check_digit
    inc si                   ; Пропускаємо знак мінус
    dec bx                   ; Встановлюємо bx в -1 для пізнішої корекції знака

check_digit:
    cmp byte ptr [si], '0'
    jb atoi_done
    cmp byte ptr [si], '9'
    ja atoi_done

atoi_loop:
    lodsb                    ; Завантажуємо наступний символ у al
    cmp al, '0'
    jb convert_done          ; Вихід, якщо символ не є числом
    cmp al, '9'
    ja convert_done
    sub al, '0'              ; Конвертуємо символ у цифру
    mul cx                   ; ax = ax * 10
    add ax, ax               ; ax = ax + цифра
    jo overflow_handler      ; Переходимо до обробника переповнення якщо OF=1
    jmp check_digit

convert_done:
    ; Коригування за знаком
    or bx, bx                ; Перевіряємо знак
    jz atoi_done             ; Якщо bx = 0, число позитивне
    neg ax                   ; Якщо bx не 0, число від'ємне
    jmp short atoi_done

overflow_handler:
    ; Встановлення максимально можливого значення
    cmp bx, 0
    jge positive_overflow
    mov ax, 8000h            ; Мінімальне від'ємне число для 16 біт
    jmp short atoi_done

positive_overflow:
    mov ax, 7FFFh            ; Максимальне позитивне число для 16 біт
    jmp short atoi_done

atoi_done:
    ret

atoi endp

bubblesort:
mov cx, word ptr numCount
    dec cx  ; count-1
outerLoop:
    push cx
    lea si, numbers
innerLoop:
    mov ax, [si]
    cmp ax, [si+2]
    jl nextStep
    xchg [si+2], ax
    mov [si], ax
nextStep:
    add si, 2
    loop innerLoop
    pop cx
    loop outerLoop

; Assuming bubblesort has been called already

; Calculate Average
calc_average:
    xor bx, bx               ; bx will hold sum
    xor cx, cx               ; Counter
    lea si, numbers          ; Pointer to start of numbers
calc_loop:
    cmp cx, numCount
    jae display_results      ; If cx == numCount, we're done
    add bx, [si]             ; Add number to sum
    add si, 2                ; Move to next number
    inc cx
    jmp calc_loop

display_results:
    mov ax, bx
    cwd                      ; Convert to double word because we're going to divide
    idiv word ptr numCount   ; Divide by count to get average
    ; ax now contains the average
    ; Convert ax to string and print (skipped, requires implementation)
    
    ; Calculate Median
    ; Assuming numCount is even for simplicity, otherwise adjust for odd case
    xor dx, dx               ; Clear dx for later use
    mov cx, numCount
    shr cx, 1                ; cx = numCount / 2
    lea si, numbers          ; si points to start of numbers array
    shl cx, 1                ; Multiply by 2 to get byte offset
    add si, cx               ; si points to the "middle" element
    mov ax, [si-2]           ; Get the n/2th element
    add ax, [si]             ; Add the (n/2 + 1)th element
    shr ax, 1                ; Divide by 2 to get median
    ; Convert ax to string and print (skipped, requires implementation)

    jmp exit_program         ; Jump to exit procedure when done

skip_character:
    jmp read_loop

display_message:
    mov ah, 09h
    int 21h
    jmp exit_program

exit_program:
    ; Закриття файлу (якщо він був відкритий)
    mov ah, 3Eh
    int 21h
    ; Завершення програми
    mov ax, 4C00h
    int 21h

main endp

end main