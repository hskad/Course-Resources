; ===============================================================
; Finding a Character in document.txt (with Iteration Count)
; ===============================================================

section .data
    filename db "document.txt", 0        ; File to be searched
    p_char db "Enter character to search: ", 0
    l_char equ $ - p_char
    msg_found db "Found: ", 0
    len_found equ $ - msg_found
    msg_iter db 10, "Iterations: ", 0
    len_iter equ $ - msg_iter
    msg_err db "Error: document.txt not found!", 10, 0
    len_err equ $ - msg_err
    newline db 10

section .bss
    search_char resb 2     ; Buffer for target character
    file_buffer resb 4096  ; Buffer to hold document contents
    num_buffer resb 12     ; Buffer for converting integer to string
    fd_in resd 1           ; File descriptor storage
    iter_count resd 1      ; Iteration counter storage

section .text
    global _start

_start:
    ; --- 1. Open document.txt ---
    mov eax, 5              ; sys_open
    mov ebx, filename       ; pointer to "document.txt"
    mov ecx, 0              ; O_RDONLY
    mov edx, 0
    int 0x80

    test eax, eax
    js open_error           ; If EAX is negative, file error
    mov [fd_in], eax        ; Save File Descriptor

    ; --- 2. Prompt for Search Character ---
    mov eax, 4
    mov ebx, 1
    mov ecx, p_char
    mov edx, l_char
    int 0x80

    ; Read character from user
    mov eax, 3
    mov ebx, 0
    mov ecx, search_char
    mov edx, 2              ; character + newline
    int 0x80

    ; --- 3. Read File Content ---
    mov eax, 3              ; sys_read
    mov ebx, [fd_in]        ; from the opened file
    mov ecx, file_buffer
    mov edx, 4096           ; read up to 4KB
    int 0x80
    mov edi, eax            ; EDI = actual number of bytes read

    ; Close the file descriptor
    mov eax, 6              ; sys_close
    mov ebx, [fd_in]
    int 0x80

    ; --- 4. Search Logic ---
    mov al, [search_char]   ; Character to find
    mov esi, file_buffer    ; Document start
    xor ecx, ecx            ; Counter = 0

search_loop:
    cmp ecx, edi            ; Reached end of data?
    je not_found

    mov bl, [esi + ecx]     ; Get current byte from file data
    inc ecx                 ; Iteration count starts at 1

    cmp bl, al              ; Match?
    je found
    jmp search_loop

found:
    mov [iter_count], ecx
    call print_found_1
    jmp print_iters

not_found:
    mov [iter_count], ecx
    call print_found_0

print_iters:
    ; Print "Iterations: "
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_iter
    mov edx, len_iter
    int 0x80

    ; Print the iteration count integer
    mov eax, [iter_count]
    call print_int

    ; Print trailing newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

open_error:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_err
    mov edx, len_err
    int 0x80
    jmp exit

; ===================================================
; Subroutines for Output
; ===================================================

print_found_1:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_found
    mov edx, len_found
    int 0x80
    mov byte [num_buffer], '1'
    mov ecx, num_buffer
    mov edx, 1
    mov eax, 4
    int 0x80
    ret

print_found_0:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_found
    mov edx, len_found
    int 0x80
    mov byte [num_buffer], '0'
    mov ecx, num_buffer
    mov edx, 1
    mov eax, 4
    int 0x80
    ret

print_int:
    pushad
    mov ebx, 10
    mov edi, num_buffer + 11
    mov byte [edi], 0       ; Null terminator
.loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .loop
    mov ecx, edi
    mov edx, num_buffer + 11
    sub edx, edi
    mov eax, 4
    mov ebx, 1
    int 0x80
    popad
    ret
