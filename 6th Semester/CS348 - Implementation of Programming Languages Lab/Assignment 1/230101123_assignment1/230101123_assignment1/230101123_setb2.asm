; ===============================================================
; Finding Inverse Matrix (using Gauss-Jordan Elimination Method)
; ===============================================================

extern printf
extern scanf
extern exit

section .data
    msg_n       db "Enter matrix size N (max 10): ", 0
    msg_row     db "Enter row %d (space separated): ", 0
    msg_res     db 10, "Inverse Matrix:", 10, 0
    fmt_in      db "%f", 0
    fmt_int     db "%d", 0
    fmt_out     db "%7.3f ", 0   
    newline     db 10, 0

    one         dd 1.0
    zero        dd 0.0

section .bss
    n           resd 1           
    n2          resd 1           
    matrix      resd 800         
    pivot       resd 1           
    factor      resd 1           
    
    i           resd 1
    j           resd 1
    k           resd 1

section .text
    global main

main:
    ; --- 1. Get N ---
    push msg_n
    call printf
    add esp, 4

    push n
    push fmt_int
    call scanf
    add esp, 8

    ; Calculate 2*N
    mov eax, [n]
    shl eax, 1
    mov [n2], eax

    ; --- 2. Read Input & Setup Augmented Matrix ---
    mov dword [i], 0
input_row_loop:
    mov eax, [i]
    cmp eax, [n]
    jge start_gauss

    push eax
    push msg_row
    call printf
    add esp, 8

    mov dword [j], 0
input_col_loop:
    mov eax, [j]
    cmp eax, [n]
    jge setup_identity

    call get_index_address
    push eax
    push fmt_in
    call scanf
    add esp, 8

    inc dword [j]
    jmp input_col_loop

setup_identity:
    mov eax, [n]
    mov [j], eax

identity_loop:
    mov eax, [j]
    cmp eax, [n2]
    jge input_next_row

    call get_index_address
    mov ecx, [i]
    add ecx, [n]
    cmp [j], ecx
    je set_one

    mov edx, [zero]
    mov [eax], edx
    jmp next_ident_col

set_one:
    mov edx, [one]
    mov [eax], edx

next_ident_col:
    inc dword [j]
    jmp identity_loop

input_next_row:
    inc dword [i]
    jmp input_row_loop

start_gauss:
    mov dword [i], 0

pivot_loop:
    mov eax, [i]
    cmp eax, [n]
    jge print_result

    ; --- Step A: Normalize Pivot Row ---
    ; Get matrix[i][i]
    mov eax, [i]
    mov ecx, [n2]
    imul ecx
    add eax, [i]        ; Col i
    shl eax, 2
    fld dword [matrix + eax]
    fstp dword [pivot]

    ; Divide Row i by Pivot
    mov dword [k], 0
norm_loop:
    mov eax, [k]
    cmp eax, [n2]
    jge eliminate_rows

    ; Calculate address matrix[i][k] manually
    mov eax, [i]
    mov ecx, [n2]
    imul ecx
    add eax, [k]
    shl eax, 2
    lea ebx, [matrix + eax]

    fld dword [ebx]
    fdiv dword [pivot]
    fstp dword [ebx]

    inc dword [k]
    jmp norm_loop

    ; --- Step B: Eliminate Rows ---
eliminate_rows:
    mov dword [j], 0

elim_outer_loop:
    mov eax, [j]
    cmp eax, [n]
    jge next_pivot

    ; Skip if j == i
    mov eax, [j]
    cmp eax, [i]
    je elim_next_j

    ; Get Factor: matrix[j][i]
    ; We calculate address using registers only. Do NOT touch memory [j].
    
    mov eax, [j]        ; Row j
    mov ecx, [n2]
    imul ecx            ; EAX = j * n2
    add eax, [i]        ; Add Col i
    shl eax, 2          ; * 4 bytes
    
    fld dword [matrix + eax]    ; Load matrix[j][i]
    fstp dword [factor]         ; Store factor

    ; Subtract: Row_j = Row_j - (Factor * Row_i)
    mov dword [k], 0
elim_inner_loop:
    mov eax, [k]
    cmp eax, [n2]
    jge elim_next_j

    ; Load Row_i[k]
    mov eax, [i]
    mov ecx, [n2]
    imul ecx
    add eax, [k]
    shl eax, 2
    fld dword [matrix + eax]    ; ST0 = Row_i[k]
    fmul dword [factor]         ; ST0 = Row_i[k] * Factor

    ; Load Row_j[k]
    mov eax, [j]
    mov ecx, [n2]
    imul ecx
    add eax, [k]
    shl eax, 2
    fld dword [matrix + eax]    ; ST0=Row_j, ST1=Term

    fsubrp st1, st0             ; Result = Row_j - Term
    fstp dword [matrix + eax]   ; Store result

    inc dword [k]
    jmp elim_inner_loop

elim_next_j:
    inc dword [j]
    jmp elim_outer_loop

next_pivot:
    inc dword [i]
    jmp pivot_loop

print_result:
    push msg_res
    call printf
    add esp, 4

    mov dword [i], 0
print_i:
    mov eax, [i]
    cmp eax, [n]
    jge done

    ; Loop j from N to 2N
    mov eax, [n]
    mov [j], eax

print_j:
    mov eax, [j]
    cmp eax, [n2]
    jge print_newline

    call get_index_address
    
    fld dword [eax]
    sub esp, 8
    fstp qword [esp]
    push fmt_out
    call printf
    add esp, 12

    inc dword [j]
    jmp print_j

print_newline:
    push newline
    call printf
    add esp, 4
    inc dword [i]
    jmp print_i

done:
    push 0
    call exit

get_index_address:
    mov eax, [i]
    mov ecx, [n2]
    imul ecx
    add eax, [j]
    shl eax, 2
    add eax, matrix
    ret
