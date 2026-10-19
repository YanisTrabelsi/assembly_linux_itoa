.intel_syntax noprefix

.global _start

.text

_start:
    push rbp
    mov rbp, rsp

    and rsp, 0xfffffffffffffff0
    
    mov rcx, 424143
    call print_int
    
    mov rsp, rbp
    pop rbp

    mov eax, 60
    mov edi, 0
    syscall
    
print_int:
    push rbp
    mov rbp, rsp
    
    mov r8, rcx
    mov r9, 1
    sub rsp, 8
    mov byte ptr [rsp], 10
  loop:
    cmp r8, 0
    je end
    add r9, 1
    
    xor rdx, rdx
    mov rax, r8
    mov rbx, 10
    div rbx
    
    mov r8, rax
    add rdx, 48
    
    sub rsp, 1
    mov byte ptr [rsp], dl
    
    jmp loop
  end:

    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, r9
    syscall
    
    mov rsp, rbp
    pop rbp
    ret
