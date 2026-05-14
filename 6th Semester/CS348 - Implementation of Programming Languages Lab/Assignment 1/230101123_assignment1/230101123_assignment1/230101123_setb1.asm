; ===============================================================
; Finding kth Largest Element using Insertion Sort
; ===============================================================

extern printf
extern scanf
extern exit

section .data
    fmt_in_int  db "%d", 0
    fmt_in_flt  db "%f", 0
    
    msg_n       db "Enter number of elements (n): ", 0
    msg_k       db "Enter rank to find (k): ", 0
    msg_val     db "Enter float value %d: ", 0
    
    ; Output format: "The <k>th largest number is: <value>"
    msg_res     db "The %d-th largest number is: %f", 10, 0 

section .bss
    n           resd 1          ; Number of elements
    k           resd 1          ; Rank to find
    array       resd 100        ; Array of floats (4 bytes each)
    temp_val    resd 1          ; Temp storage for swapping

section .text
    global main                 ; Use 'main' so GCC can link it

main:
    ; --- 1. Ask for N ---
    push msg_n
    call printf
    add esp, 4                  ; Clean stack

    push n                      ; Address of n
    push fmt_in_int             ; "%d"
    call scanf
    add esp, 8                  ; Clean stack

    ; --- 2. Ask for K ---
    push msg_k
    call printf
    add esp, 4

    push k                      ; Address of k
    push fmt_in_int
    call scanf
    add esp, 8

    ; --- 3. Read N Floats ---
    xor ecx, ecx                ; ECX = Loop Index (i)

input_loop:
    cmp ecx, [n]
    jge start_sort              ; If i >= n, start sorting

    ; Print prompt "Enter float value i+1: "
    push ecx                    ; Save caller-saved registers
    
    mov eax, ecx
    inc eax
    push eax                    ; Push (i+1)
    push msg_val
    call printf
    add esp, 8

    pop ecx                     ; Restore ECX
    
    ; Read Float directly into array[ecx]
    ; Calculate address: array + (ecx * 4)
    lea eax, [array + ecx*4]
    
    push ecx                    ; Save ECX again (scanf destroys it)
    push eax                    ; Push address of array[i]
    push fmt_in_flt             ; Push "%f"
    call scanf
    add esp, 8
    pop ecx                     ; Restore ECX

    inc ecx
    jmp input_loop

start_sort:
    ; --- 4. Insertion Sort (Descending Order) ---
    ; We want K-th largest, so we sort High -> Low.
    ; C Code:
    ; for (i = 1; i < n; i++) {
    ;     float key = array[i];
    ;     int j = i - 1;
    ;     while (j >= 0 && array[j] < key) {  // Shift small values right
    ;         array[j+1] = array[j];
    ;         j--;
    ;     }
    ;     array[j+1] = key;
    ; }

    mov ecx, 1                  ; i = 1

outer_loop:
    cmp ecx, [n]
    jge print_result

    ; Load Key (array[i]) into FPU Stack
    fld dword [array + ecx*4]   ; ST0 = Key

    mov edx, ecx
    dec edx                     ; j = i - 1

inner_loop:
    cmp edx, -1                 ; If j < 0, break
    je place_key

    ; Compare array[j] with Key (ST0)
    fld dword [array + edx*4]   ; Load array[j] to ST0 (Key is now ST1)
    
    ; Compare ST0 (array[j]) vs ST1 (Key)
    fcomip st0, st1             ; Compare and pop ST0. Flags set.
    
    ; We want Ascending. 
    ; If array[j] <= Key (AE), it's in the right place relative to Key. Break.
    jbe place_key 

    ; Shift: array[j+1] = array[j]
    ; Note: We don't use FPU for moving data to keep it fast/simple
    mov eax, [array + edx*4]
    mov [array + edx*4 + 4], eax

    dec edx                     ; j--
    jmp inner_loop

place_key:
    ; array[j+1] = Key
    ; Key is currently sitting in ST0. We pop it to memory.
    fstp dword [array + edx*4 + 4]

    inc ecx                     ; i++
    jmp outer_loop

print_result:
    ; --- 5. Print Result ---
    ; Array is sorted Descending. K-th largest is at index [k-1].
    
    mov eax, [k]
    dec eax                     ; Index = k - 1
    
    ; Prepare arguments for printf (Right to Left)
    
    ; Argument 2: The Float Value
    ; printf expects a DOUBLE (8 bytes) for %f, even if data is float.
    fld dword [array + eax*4]   ; Load float to FPU
    sub esp, 8                  ; Make space on stack
    fstp qword [esp]            ; Store as double (8 bytes) on stack

    ; Argument 1: The Integer K
    push dword [k]

    ; Argument 0: Format String
    push msg_res

    call printf
    add esp, 16                 ; Cleanup (8 + 4 + 4)

    ; --- 6. Exit ---
    push 0
    call exit
