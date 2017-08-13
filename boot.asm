global start

section .text
bits 32
start:
    ; point first entry of level 4 page
    ; to first entry of p3 table

    mov eax, p3_table ; copy contents of first level 3 table entry to eax
    
    ; first 2 bits of page table entry are 'present bit' and 'writable bit'
    ; first bit set: page currently in memory
    ; second bit set: page may be written to

    or eax, 0b11 ; set first 2 bits to 1 and store result in eax
    mov dword [p4_table + 0], eax ; accessing 0th entry of level 4 table

    ; point first entry of level 3 page table
    ; to first entry of p2 table

    mov eax, p2_table
    or eax, 0b11
    mov dword [p3_table + 0], eax

    ; point each entry of level 2 table to a page
    
    mov ecx, 0 ; counter variable

.map_p2_table:
    mov eax, 0x200000 ; each page is 2 megabytes in size

    mul ecx ; ecx * eax
    or eax, 0b10000011

    mov [p2_table + ecx * 8], eax ; multiply counter by 8 because each entry is 8 bits in size (0b10000011)

    inc ecx
    cmp ecx, 512 ; mapping 512 page entries in total
    jne .map_p2_table    

    ; move page table 4 address to cr3

    mov eax, p4_table
    mov cr3, eax ; control register

    ; enable PAE (physical address extension)

    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; set long mode bit

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; enable paging

    mov eax, cr0
    or eax, 1 << 31
    or eax, 1 << 16
    mov cr0, eax

    lgdt [gdt64.pointer] ; load global descriptor table (GDT)

    mov word [0xb8000], 0xDF48 ; H
    mov word [0xb8002], 0xDF65 ; e
    mov word [0xb8004], 0xDF6c ; l
    mov word [0xb8006], 0xDF6c ; l
    mov word [0xb8008], 0xDF6f ; o
    mov word [0xb800a], 0xDF2c ; ,
    mov word [0xb800c], 0xDF20 ;
    mov word [0xb800e], 0xDF77 ; w
    mov word [0xb8010], 0xDF6f ; o
    mov word [0xb8012], 0xDF72 ; r
    mov word [0xb8014], 0xDF6c ; l
    mov word [0xb8016], 0xDF64 ; d
    mov word [0xb8018], 0xDF21 ; !
    hlt

; the following section sets up a single valid entry
; for each level in the page table

section .bss ; entries in bss section set to 0 by linker

align 4096 ; make sure tables aligned properly

p4_table:
    resb 4096 ; reserve 4096 bytes for an entry

p3_table:
    resb 4096

p2_table:
    resb 4096

section .rodata ; read-only data

gdt64:
    dq 0 ; define quad-word

.code: equ $ - gdt64 ; get offset number

    ; in order to have valid code segment, need:
    ; bit 44: 'descriptor type' - 1 for code and data segments
    ; bit 47: 'present' - 1 if valid entry
    ; bit 41: 'read/ write' - 1 if readable code segment
    ; bit 43: 'executable' - 1 if code segment
    ; bit 53: '64-bit' - 1 if 64-bit GDT

    dq (1 << 44) | (1 << 47) | (1 << 41) | (1 << 43) | (1 << 53)

.data: equ $ - gdt64
    dq (1 << 44) | (1 << 47) | (1 << 41) ; bit 41: 1 if data is writable

.pointer:
    dw .pointer - gdt64 - 1 ; calculate length
    dq gdt64 ; address of table
