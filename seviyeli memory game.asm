
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

        
        
 .model small 
.data                                    
    sequence       DB 100 dup(?)   ;  olusturulan diziyi depolamak icin arabellek
            
    player_input   DB 100 dup(?)   ;  Oyuncunun girisini depolamak icin arabellek
    
    correct        DB 1             ;  girisin dogrulugunu izlemek icin bayrak
    
    level          DB 3             ; baslangic oyun seviyesi
    
    win_msg        DB 10,13,"CORRECT ANSWER  --- NEXT LEVEL  ", "$"
    lose_msg       DB 10,13,"WRONG ANSWER  --- END THE GAME ", "$"
    prompt_msg     DB 10,13,"TRY THE SYMBOL","$"
    exit_msg       DB 10,13,"GAME OVER! PRESS ANY KEY TO EXIT", "$"

.stack 256         ; Yigin boyutunu tanimlayin

.code 
    main PROC FAR
        mov ax, @data     ;  Veri segmentini (.startup) dogru sekilde baslatin
        mov ds, ax
        
    start_game:
        call generate_sequence    
        call display_sequence
        call get_player_input        
        call check_input             
        cmp correct, 1 
        je  next_level
        jmp game_over               

    next_level:
        lea dx, win_msg
        mov ah, 09h
        int 21h                      
        inc level                    
        cmp level, 10                ; Maksimum seviye kontrolu ekle
        jl start_game
        jmp game_over
    
    game_over:
        lea dx, exit_msg             ; cikis mesaji eklendi
        mov ah, 09h
        int 21h
        
        mov ah, 00h                  ; tusa basilmasini bekleyin
        int 16h
        
        mov ah, 4Ch                  ; Proper exit to DOS
        int 21h
    
    main ENDP

    generate_sequence PROC NEAR
        push cx                      ; kayitlari kaydet
        push si
        
        mov al, level                ;   diziyi olusturmak icin baslangic degeri al
        mov ah, 0
        mov cx, ax                   ; cx kaydi dongu yinelemelerinin sayisini belirler
        
                     
        xor si, si                   ; Degerleri saklamak icin index olarak SI kaydi
    
    generate_loop:
        push cx                      ; Dongu sayacini kaydet 
        
        ;                              Daha iyi bir random sayi uretilsin
        
        
        mov ah, 00h                  ; Sistem saatini alin      
        
        int 1Ah                      ; CX:DX artik saat tiklerini iceriyor
        
        mov al, dl                   ; Use lower part of tick count
                                                         
                                                         
        and al, 0Fh                  ;  0-15 arasinda sinirlandirildi
        
        add al, '0'                  ; ASCII'ye donusturuldu
        
        
        mov [sequence + si], al      ; diziyi depolayin
        inc si
        
        pop cx                       ; dongu sayacini geri yukle.
        loop generate_loop
        
        pop si                       ; kayitlari geri yukle
        pop cx
        ret
    generate_sequence ENDP

    display_sequence PROC NEAR
        push cx
        push si
        
        mov al, level
        mov ah, 0
        mov cx, ax
        xor si, si                   
    
    display_loop:
        mov al, [sequence + si]
        mov ah, 0Eh                  ;      
        int 10h                          
        inc si
        loop display_loop
        
        call delay   
        call clear_screen
        
        pop si
        pop cx
        ret
    display_sequence ENDP

    get_player_input PROC NEAR
        push cx
        push di
        
        lea dx, prompt_msg
        mov ah, 09h           
        int 21h                      
        
        mov al, level
        mov ah, 0
        mov cx, ax                  
        xor di, di                   
   
    input_loop:
        mov ah, 00h                  ;  Klavye girisini bekleyin                
        int 16h                      
        mov [player_input + di], al  
        
        mov ah, 0Eh                  ;  Giris karakterini goruntule  
        int 10h
        
        inc di                       
        loop input_loop              
        
        pop di
        pop cx
        ret
    get_player_input ENDP       
        
        
   check_input PROC NEAR
        push cx
        push si
        push di
        
        mov al, level
        mov ah, 0
        mov cx, ax           
        xor si, si
        xor di, di
        mov correct, 1               
    
    compare_loop:
        mov al, [sequence + si]     
        cmp al, [player_input + di] 
        jne incorrect_input          
        inc si
        inc di 
        loop compare_loop
        
        pop di
        pop si
        pop cx
        ret
    
    incorrect_input:
        mov correct, 0               
        pop di
        pop si
        pop cx
        ret
    check_input ENDP
    
    delay PROC NEAR
        push cx
        push dx
        
        mov cx, 0000fh               ;  Artan gecikme suresi
        
    delay_loop:
        push cx                      ;  Daha guvenilir gecikme icin ic ice dongu
        mov cx, 0000fh
        
    inner_delay_loop:
        nop
        loop inner_delay_loop
        
        pop cx
        loop delay_loop
        
        pop dx
        pop cx
        ret
    delay ENDP
    
    clear_screen PROC NEAR
        mov ah, 06h                  ;  Kaydirma islevi
        mov al, 0                    ;  Tum ekrani temizle
        mov bh, 07h                  ; Varsayilan renk ozelligi
        mov cx, 0                    ;  Sol ust kose
        mov dx, 184Fh                ; Sag alt kose
        int 10h
        ret
    clear_screen ENDP

END main         


ret




