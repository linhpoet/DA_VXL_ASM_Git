PROCESSOR pic18f4520
#INCLUDE <p18F4520.INC>

; CONFIG1H
  CONFIG  OSC = RCIO6           ; Oscillator Selection bits (External RC oscillator, port function on RA6)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 3              ; Brown Out Reset Voltage bits (Minimum setting)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = PORTC        ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = OFF           ; MCLR Pin Enable bit (RE3 input pin enabled; MCLR disabled)

; CONFIG4L
  CONFIG  STVREN = OFF          ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will not cause Reset)
  CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) not protected from table reads executed in other blocks)

W_TEMP equ 0x0e
STATUS_TEMP equ 0x0f
BSR_TEMP equ 0x0c
cblock 0x40
dulieu                          ;0x40
muc
muc_temp
vong
vong2
endc
#define RS PORTC,5
#define RW PORTC,6
#define E  PORTC,7


org 0x00
goto main


org 0x08
MOVWF W_TEMP ; W_TEMP is in virtual bank
MOVFF STATUS, STATUS_TEMP ; STATUS_TEMP located anywhere
MOVFF BSR, BSR_TEMP ; BSR_TMEP located anywhere
;
btfss PORTB,4               ;skip if set
call start
btfss PORTB,5               ;skip if set
call Up
btfss PORTB,6
call Down
;
MOVFF BSR_TEMP, BSR ; Restore BSR
MOVF W_TEMP, W ; Restore WREG
MOVFF STATUS_TEMP, STATUS ; Restore STATUS
call delay2                 ;cho nut nhan on dinh
bcf INTCON,0                ;xoa co ngat
RETFIE                      ;The ?return from interrupt? instruction, RETFIE, exits
                            ;the interrupt routine and sets the GIE bit (GIEH or GIEL
                            ;if priority levels are used), which re-enables interrupts


org 0x50
main
clrf TRISC
clrf TRISD                  ;portD output
movlw 0xff
movwf TRISB                 ;portB input
movlw 0x00
movwf PORTD
;Interrupt_configuration
movlw 0x88
movwf INTCON                ;intcon = 0x88
bsf INTCON2,1               ;RBIP = 1, high priority interrupt PortB
;lm298_configuration
bsf PORTC, 4                ;ENA = ENB = 5v
bcf PORTC, 3                ;IN2 = 0
;khoi tao lcd
movlw 0x38                  ;Mode8bit2line
call ghi_lenh
movlw 0x0c                  ;DisplayOn
call ghi_lenh
movlw 0x01                  ;clear lcd
call ghi_lenh
call muc_0
movff muc_temp, muc
loop
goto loop


start
movf muc,0                  ;copy muc into W
xorlw D'0'                  ;xor W with 0; if W=0, Z=1 else Z=0
btfsc STATUS,Z              ;skip next instruction if Z=0
call muc_1                  ;so if muc=0, call muc_1
;tuong tu phia tren
movf muc,0
xorlw D'0'                  ;if W != 0, Z=0
btfss STATUS,Z              ;skip next instruction if Z=1
call muc_0                  ;so if muc != 0, call muc_0
movff muc_temp, muc
return


Up
movf muc,0
xorlw D'0'
btfsc STATUS,Z
return
movf muc,0
xorlw D'1'
btfsc STATUS,Z
call muc_2
movf muc,0
xorlw D'2'
btfsc STATUS,Z
call muc_3
movff muc_temp, muc
return


Down
movf muc,0
xorlw D'0'
btfsc STATUS,Z
return
movf muc,0
xorlw D'3'
btfsc STATUS,Z
call muc_2
movf muc,0
xorlw D'2'
btfsc STATUS,Z
call muc_1
movff muc_temp, muc
return



muc_0
movlw 0x00
movwf muc_temp
movlw 0x01                  ;clear lcd
call ghi_lenh
movlw 0x63
movwf PR2
movlw 0x0c
movwf CCP1CON
movlw 0x21
movwf CCPR1L
movlw 0x00
movwf T2CON
movlw 'C'
call ghi_dulieu
movlw 'a'
call ghi_dulieu
movlw 'i'
call ghi_dulieu
movlw ' '
call ghi_dulieu
movlw 'd'
call ghi_dulieu
movlw 'a'
call ghi_dulieu
movlw 't'
call ghi_dulieu
movlw ':'
call ghi_dulieu
movlw '0'
call ghi_dulieu
movlw '%'
call ghi_dulieu
movlw 0xc0              ;xuong hang 2
call ghi_lenh
return


muc_1
movlw 0x01
movwf muc_temp
movlw 0x01                  ;clear lcd
call ghi_lenh
movlw 0x63
movwf PR2
movlw 0x0c
movwf CCP1CON
movlw 0x21
movwf CCPR1L
movlw 0x05
movwf T2CON
movlw 'C'
call ghi_dulieu
movlw 'a'
call ghi_dulieu
movlw 'i'
call ghi_dulieu
movlw ' '
call ghi_dulieu
movlw 'd'
call ghi_dulieu
movlw 'a'
call ghi_dulieu
movlw 't'
call ghi_dulieu
movlw ':'
call ghi_dulieu
movlw '3'
call ghi_dulieu
movlw '3'
call ghi_dulieu
movlw '%'
call ghi_dulieu
movlw 0xc0              ;xuong hang 2
call ghi_lenh
return


muc_2                   ;50%
movlw 0x02
movwf muc_temp
movlw 0x01                  ;clear lcd
call ghi_lenh
movlw 0x63
movwf PR2
movlw 0x0c
movwf CCP1CON
movlw 0x32
movwf CCPR1L
movlw 0x05
movwf T2CON
movlw 'C'
call ghi_dulieu
movlw 'a'
call ghi_dulieu
movlw 'i'
call ghi_dulieu
movlw ' '
call ghi_dulieu
movlw 'd'
call ghi_dulieu
movlw 'a'
call ghi_dulieu
movlw 't'
call ghi_dulieu
movlw ':'
call ghi_dulieu
movlw '5'
call ghi_dulieu
movlw '0'
call ghi_dulieu
movlw '%'
call ghi_dulieu
movlw 0xc0              ;xuong hang 2
call ghi_lenh
return

muc_3                   ;66%
movlw 0x03
movwf muc_temp
movlw 0x01                  ;clear lcd
call ghi_lenh
movlw 0x63
movwf PR2
movlw 0x0c
movwf CCP1CON
movlw 0x41
movwf CCPR1L
movlw 0x05
movwf T2CON
movlw 'C'
call ghi_dulieu
movlw 'a'
call ghi_dulieu
movlw 'i'
call ghi_dulieu
movlw ' '
call ghi_dulieu
movlw 'd'
call ghi_dulieu
movlw 'a'
call ghi_dulieu
movlw 't'
call ghi_dulieu
movlw ':'
call ghi_dulieu
movlw '6'
call ghi_dulieu
movlw '6'
call ghi_dulieu
movlw '%'
call ghi_dulieu
movlw 0xc0              ;xuong hang 2
call ghi_lenh
return



ghi_dulieu
bcf RW                  ;RW = 0
bsf RS                  ;RW = 1
movwf PORTD
call cho_phep
return


ghi_lenh
bcf RW
bcf RS
movwf PORTD
call cho_phep
return


cho_phep
bsf E                   ;E=1
call delay
call delay
bcf E                   ;E=0
call delay
call delay
call delay
call delay
call delay
call delay
return


delay                           ;delay 500us
movlw D'199'                    ;T delay = 5(D+1)*/f, D 8 bit,
movwf vong
lap
nop
decfsz vong
goto lap
RETURN


delay2                           ;delay >100ms
movlw D'199'                    ;T delay = 5(D+1)*/f, D 8 bit,
movwf vong2
lap2
call delay
decfsz vong2
goto lap2
RETURN

end







