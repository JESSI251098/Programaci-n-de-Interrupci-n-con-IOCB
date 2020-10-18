PROCESSOR 16F887 
    ;INSTITUTO TECNOLOGICO SUPERIOR DE COATZACOALCOS 
    ;INGENIERIA MECATR�NICA    
    ;Pr�ctica 2: Programaci�n de Interrupci�n con IOCB
    ;EQUIPO: LA EGG.CELENCIA          MATERIA:MICROCONTROLADORES
    ;INTEGRANTES:
    ;Agust�n Madrigal Luis          17080167          imct17.lagustinm@itesco.edu.mx
    ;Cruz Gallegos Isaac            17080186          imct17.icruzg@itesco.edu.mx
    ;God�nez Palma Jessi Darissel   17080205	imct17.jgodinezp@itesco.edu.mx
    ;Guzm�n Garc�a Omar de Jes�s    17080211          imct17.oguzmang@itesco.edu.mx
    ;Medina Ortiz Mauricio          17080237          imct17.mmedinao@itesco.edu.mx
    ;M�ndez Osorio Julia Vanessa    17080238          imct17.jmendezo@itesco.edu.mx
    ;DOCENTE:JORGE ALBERTO SILVA VALENZUELA 
    ;SEMESTRE:7�    GRUPO:A 
    ;FECHA: 16/10/2020
#include <xc.inc>
    ;configuracion de fuses 
config FOSC = INTRC_CLKOUT ;Bits de selecci�n del oscilador (oscilador INTOSC: funci�n CLKOUT en el pin RA6 / OSC2 / CLKOUT, funci�n de E / S en RA7 / OSC1 / CLKIN)
 config WDTE = OFF         ;Bit de habilitaci�n del temporizador de vigilancia (WDT deshabilitado y puede habilitarse mediante el bit SWDTEN del registro WDTCON)
 config PWRTE = OFF        ;Bit de habilitaci�n del temporizador de encendido (PWRT habilitado)
 config MCLRE = ON         ;Bit de selecci�n de funci�n de pin RE3 / MCLR (la funci�n de pin RE3 / MCLR es MCLR)
 config CP = OFF           ;Bit de protecci�n de c�digo (la protecci�n de c�digo de memoria del programa est� desactivada)
 config CPD = OFF          ;Bit de protecci�n de c�digo de datos (la protecci�n de c�digo de memoria de datos est� desactivada)
 config BOREN = ON         ;Bits de selecci�n de reinicio de Brown Out (BOR habilitado)
 config IESO = ON          ;Bit de conmutaci�n interna externa (el modo de conmutaci�n interno / externo est� habilitado)
 config FCMEN = ON         ;Bit de control de reloj a prueba de fallas habilitado (el monitor de reloj a prueba de fallas est� habilitado)
 config LVP = OFF          ;Bit de habilitaci�n de programaci�n de bajo voltaje (el pin RB3 tiene E / S digital, HV en MCLR debe usarse para la programaci�n)
 config DEBUG=ON
;configuracion de alimentacion
 config BOR4V = BOR40V     ;Bit de selecci�n de reinicio de bajada (Brown-out Reset establecido en 4.0V)
 config WRT = OFF          ;Bits de habilitaci�n de autoescritura de memoria de programa flash (protecci�n contra escritura desactivada)
 
PSECT udata
gel: ;declaraci�n de nuestras variables 
    DS 1
counter:
    DS 1
counter2:
    DS 1
paro2:
    DS 1
paro1:
    DS 1
operador:
    DS 1
        
PSECT code
tiempo:
movlw 0xff
movwf counter
counter_loop:
movlw 0xff
movwf gel
tick_loop:
decfsz gel,f
goto gel_loop
decfsz counter,f
goto counter_loop
return

PSECT code
delay_2s:
movlw 0x05
movwf paro1
call tiempo
decfsz  paro1
goto $-2
return

PSECT code
delay2:
movlw 0xff
movwf counter
counter_loop2:
movlw 0xff
movwf gel
tick_loop2:
decfsz gel,f
goto gel_loop2
decfsz counter,f
goto counter_loop2
return
    
PSECT resetVec,class=CODE,delta=2
resetVec:
goto main
    
PSECT isr,class=CODE,delta=2 ;proceso el cual dara las interupciones
isr:
BANKSEL PORTD
btfss INTCON,0
retfie
clrf PORTD 
control: ;si tenemos interrupci�n en 1 de PORTB, nos dirige al proceso de disminuye
btfss PORTB,1
goto proceso
goto disminuye
proceso: ;si tenemos interrupci�n en 7 de PORTB, nos dirige al aumento
btfss PORTB,7
retfie
goto aumenta
disminuye: ;disminuye el encendido y apagado del LED
bcf INTCON,0
bcf PORTD,0
bcf PORTB,1
retfie
aumenta: ;aumenta el encendido y apagado del LED
bcf INTCON,0
bsf PORTD,0
bcf PORTB,7
retfie
    
PSECT main,class=CODE,delta=2
main:
BANKSEL OPTION_REG
movlw 0b11000000
movwf OPTION_REG
BANKSEL WPUB
movlw 0b10000010
movwf WPUB
clrf INTCON
movlw 0b11001000
movwf INTCON
BANKSEL IOCB
movlw 0b10000010
movwf IOCB
BANKSEL OSCCON
movlw 0b01110000
Movwf OSCCON
BANKSEL ANSELH
movlw 0b00000000
movwf ANSELH
BANKSEL ANSEL
movlw 0b00000000
movwf ANSEL
BANKSEL TRISB
movlw 0b10000010
movwf TRISB    
clrf TRISD
movlw 0b00000000
movwf TRISA 
BANKSEL PORTB
clrf PORTB
movlw 0b00000000
movwf PORTD
BANKSEL PORTA
movlw 0b00000000
movwf PORTA
INICIO:
btfss PORTD,0
goto caso2
goto caso1
caso1:
bsf PORTA,0
call tiempo
bcf PORTA,0
call tiempo
caso2:
btfss PORTD,0
goto subcaso
goto caso1
subcaso:
bsf PORTA,0
call delay_2s
bcf PORTA,0
call tiempo
goto INICIO  ;regresamos a inicio 
END resetVec


