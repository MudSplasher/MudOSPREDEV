global _start


section .data
  fileName:  db "boot.bmp",0
  fileFlags: dq 0102o         ; create file + read and write mode
  fileMode:  dq 00600o        ; user has read write permission
  fileDescriptor: dq 0
  bitmapImage: times 3000000 db 0
section .rodata    ; read only data section
    bmpWidth   equ  1000
    bmpHeight   equ  1000
    bmpSize equ 3 * bmpWidth * bmpHeight
    headerLen equ 54
    header: db "BM"         ; BM  Windows 3.1x, 95, NT, ... etc.
    bfSize: dd bmpSize + headerLen   ; The size of the BMP file in bytes
            dd 0                 ; reserved
    bfOffBits: dd headerLen   ; The offset, i.e. starting address, of the byte where the bitmap image data (pixel array) can be found
    biSize:   dd 40    ; header size, min = 40
    biWidth:  dd bmpWidth
    biHeight: dd bmpHeight
    biPlanes:       dw 1     ; must be 1
    biBitCount:     dw 24    ; bits per pixel: 1, 4, 8, 16, 24, or 32
    biCompression:  dd 0     ; uncompressed = 0
    biSizeImage:    dd bmpSize  ; Image Size - may be zero for uncompressed images
    hresolution:    dd 0
    vresolution:    dd 0
    palettecolors:  dd 0
    importantcolors: dd 0

section .text

; drawPixel(x,y,color{RGB}) ( R8,R9,R10) 
drawPixel:
    push rax
    push rbx
    ;---------------------------------
    mov rax,3000
    mul r9
    push rax
    mov rax,3
    mul r8
    pop rbx
    add rax,rbx         ; offset:  rax = 3*x+3000*y
    push r10
    pop rbx
    mov word[bitmapImage+rax],bx
    shr rbx,16
    mov byte[bitmapImage+rax+2],bl
    ;----------------------------------
    pop rbx
    pop rax
    ret
; drawLine(x1,y1,x2,y2,color) color = R10  x1=r8 y1=r9 x2=r11 y2=r12    
drawLine:
    push rax
    push rbx
    push rcx                  ;  line   y = M*x/1000   M=w*1000/q  w=y2-y1  q=x2-x1 
    push rdx
    ;-----------------------------------
    mov rax,r12             ; rax <- y2
    sub rax,r9              ; rax <- y2 - y1
    mov rbx,1000
    mul rbx                 ; rax <- rax*1000
    mov rbx,r11             ; rbx <- x2
    sub rbx,r8              ; rbx <- x2 - x1
    xor rdx,rdx             ; rdx = 0
    div rbx                 ; RAX / RBX  RAX= value  M
    push rax
    pop rcx                 ; rcx <- M
    mov rbx,r8              ; rbx <- x1
    ;-----------------------------------------
    push r8
    push r9
nextPixel:
    mov rax,rbx             ; rbx = x
    mul rcx                 ; rax = M*x
    push rcx
    xor rdx,rdx
    mov rcx,1000
    div rcx                 ; rax = M*x/1000
    pop rcx
    mov r8,rbx              ; r8 <- x
    mov r9,rax              ; r9 <- y
    call drawPixel
    inc rbx
    cmp rbx,r11
    jnz nextPixel
    pop r9
    pop r8
    ;-----------------------------------
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret


drawLines:
    mov r8,0
    mov r9,0
    mov r10,0xff0000        ; color RED
    mov r11,900
    mov r12,900
    call drawLine
    ret  

_start:
    mov rax,2                 ;   sys_open
    mov rdi,fileName          ;   const char *filename
    mov rsi,[fileFlags]       ;   int flags
    mov rdx,[fileMode]        ;   int mode
    syscall
    mov [fileDescriptor],rax

    ; write the header to file
    mov rax,1                 ; sys_write
    mov rdi,[fileDescriptor]
    mov rsi,header
    mov rdx,54
    syscall

    call drawLines

    ; write the Image to file
    mov rax,1                 ; sys_write
    mov rdi,[fileDescriptor]
    mov rsi,bitmapImage
    mov rdx,3000000
    syscall

    ; close file Descriptor
    mov rax,3                 ; sys_close
    mov rdi,[fileDescriptor]
    syscall

    ; EXIT to OS  sys_exit
    mov rax,60
    mov rdi,0
    syscall