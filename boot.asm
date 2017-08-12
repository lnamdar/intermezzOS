global start

section .text
bits 32

start:
    mov word [0xb8000], 0xDF48 ; print a pink H in upper left corner with white background
    mov word [0xb8002], 0xDF65 ; e
    mov word [0xb8004], 0xDF6c ; l
    mov word [0xb8006], 0xDF6c ; l
    mov word [0xb8008], 0xDF6f ; o
    mov word [0xb800a], 0xDF2c ; ,
    mov word [0xb800c], 0xDF20 ; space
    mov word [0xb800e], 0xDF77 ; w
    mov word [0xb8010], 0xDF6f ; o
    mov word [0xb8012], 0xDF72 ; r
    mov word [0xb8014], 0xDF6c ; l
    mov word [0xb8016], 0xDF64 ; d
    mov word [0xb8018], 0xDF21 ; !
    
    hlt ; stop