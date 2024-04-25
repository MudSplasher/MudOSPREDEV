    org 0x7C00
    bits 16
    
    %define ENDL 0x0D, 0x0A
    
    start:
    jmp main
    
    puts:
     push si
     push ax
    .loop:
     lodsb
     or   al, al
     jz   .done
     mov  bh, 0
     mov  ah, 0x0E    ; BIOS.Teletype
     int  0x10
     jmp  .loop
    .done:
     pop  ax
     pop  si
     ret
	 
main:
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00
   mov si, msg_bootstring
   mov si, msg_bootstring1
   call puts
hlt

.halt:
jmp .halt



msg_bootstring: db "MudOS 1.0 Beta Development Preview", ENDL, 0
msg_bootstring1: db "Starting", ENDL, 23
msg_bootstring2: db "Starting", ENDL, 23
msg_bootstring3: db "Starting", ENDL, 23
msg_bootstring4: db "Starting", ENDL, 23
msg_bootstring5: db "Starting", ENDL, 23


times 510-($-$$) db 0
dw 0AA55h 