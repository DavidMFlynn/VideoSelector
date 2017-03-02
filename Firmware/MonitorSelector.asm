;=========================================================================================
;
;   Filename:	MonitorSelector.asm
;   Date:	2/1/2017
;   File Version:	1.0d1
;
;    Author:	David M. Flynn
;    Company:	Oxford V.U.E., Inc.
;    E-Mail:	dflynn@oxfordvue.com
;    Web Site:	http://www.oxfordvue.com/

;=========================================================================================
;   Reads 8 1 of 16 selector switches and sends serial commands to a video switch
;
;    History:
;
; 1.0d1  2/1/2017	First code
;
;=========================================================================================
; Options
;
DefaultFlags	EQU	b'00000000'
;
;=========================================================================================
;=========================================================================================
;
;      Pic
;
; 1    RA2	D2
; 2    RA3	D3
; 3    RA4	Status LED (active low)
; 4    RA5	MCLR/vpp (P2.1)
; 5    VSS	GND
; 6    RB0	n/c
; 7    RB1/RX	RX
; 8    RB2/TX	TX
; 9    RB3	A0
;
;10    RB4	A1
;11    RB5	A2
;12    RB6/PGC	PGC (P2.4)
;13    RB7/PGD	PGD (P2.5)
;14    VDD	+5V
;15    RA6	n/c
;16    RA7	n/c
;17    RA0	D0
;18    RA1	D1
;
;=========================================================================================
;
	list	p=16f1847,r=hex,W=1	; define processor
;
	nolist
	include	p16f1847.inc	; processor specific variableis
	list
;
	__CONFIG _CONFIG1,_FOSC_INTOSC & _WDTE_ON & _MCLRE_OFF & _IESO_OFF
;
; INTOSC oscillator: I/O function on CLKIN pin
; WDT on
; PWRT disabled
; MCLR/VPP pin function is digital input
; Program memory code protection is disabled
; Data memory code protection is disabled
; Brown-out Reset enabled
; CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin
; Internal/External Switchover mode is disabled
; Fail-Safe Clock Monitor is enabled
;
	__CONFIG _CONFIG2,_WRT_ALL & _PLLEN_OFF & _LVP_OFF
;
; Write protection on
; 4x PLL disabled
; Stack Overflow or Underflow will cause a Reset
; Brown-out Reset Voltage (Vbor), low trip point selected.
; Low-voltage programming Disabled ( allow MCLR to be digital in )
;  *** must set apply Vdd before Vpp in ICD 3 settings ***
;
; '__CONFIG' directive is used to embed configuration data within .asm file.
; The lables following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.
;
	constant	oldCode=0
	constant	UseEEParams=0
;
#Define	_C	STATUS,C
#Define	_Z	STATUS,Z
;
;=========================================================================================
;
	nolist
	include	F1847_Macros.inc
	list
;
;    Port A  set up
PortAValue	EQU	b'00000000'
PortADDRBits	EQU	b'11111111'	; pin 4/RA5 MSG Sw
;
#Define	Data0	PORTA,0	;Databits
#Define	Data1	PORTA,1	; 4 bit gray code
#Define	Data2	PORTA,2
#Define	Data3	PORTA,3
#Define	heartBeat	TRISA,4	; RA4:  0=LED On
			;       1=LED Off
;RA5/MCLR P2.1
;
;    Port B  set up
;
PortBValue	EQU	b'00001100'
PortBDDRBits	EQU	b'11000011'
;
#Define	RB0_In	PORTB,0	;n/c
;RB1 UART RX
;RB2 UART TX
#define	Sel_A0	LATB,3	; A0 U13.1
#define	Sel_A1	LATB,4	; A1 U13.2
#define	Sel_A2	LATB,5	; A2 U13.3
;RB6 PGC			;P2.4
;RB7 PGD			;P2.5
;
;OSCCON_Val	equ	b'01110000'	;  8 MHz
OSCCON_Val	equ	b'11110000'	; 32 MHz
;T2CON_Value	EQU	b'01001110'	;T2 On, /16 pre, /10 post
T2CON_Value	EQU	b'01001111'	;T2 On, /64 pre, /10 post
PR2_Value	EQU	.125
;
;
;============================================================
;============================================================
;
;	Constants
;
All_In	EQU	0xFF
All_Out	EQU	0x00
;
LEDTIME	EQU	d'100'	; 1.00 secondsLEDTIME
LEDErrorTime	EQU	d'10'
;
DebounceTime	EQU	d'10'
;
;========================================================
;***** VARIABLE DEFINITIONS
; there are 128 bytes of ram, Bank0 0x20..0x7F, Bank1 0xA0..0xBF
; there are 256 bytes of EEPROM starting at 0x00
; the EEPROM is not mapped into memory but
; accessed through the EEADR and EEDATA registers
;========================================================
;
;  Bank0 Ram 020h-06Fh 80 Bytes
;
	cblock	0x20
	LED_Time	
	tickcount		; Timer tick count
	ISRScratch
;
	EEAddrTemp		; EEProm address to read or write
	EEDataTemp		; Data to be writen to EEProm
;
	Timer1Lo		; 1st 16 bit timer
	Timer1Hi		; one second RX timeiout
	Timer2Lo		; 2nd 16 bit timer
	Timer2Hi		; 
	Timer3Lo		; 3rd 16 bit timer
	Timer3Hi		; GP wait timer
	Timer4Lo		; 4th 16 bit timer
	Timer4Hi		; debounce timer
;
	SysFlags		; System status
	SWFlags
	LEDFlags
;
	TXByte		;Next byte to send
	RXByte		;Last byte received
	SerFlags
	OldSWValues:8
;
	endc
;
#Define	DataReceivedFlag	SerFlags,1
#Define	DataSentFlag	SerFlags,2
;
;SysFlags bits
;
;
;=========================================================================================
;
;  Bank1 Ram 0A0h-0EFh 80 Bytes
;
;=========================================================================================
;
; Bank2 Variables:
#Define	Ser_Buff_Bank	2
	cblock	0x120
	Ser_In_Bytes		;Bytes in Ser_In_Buff
	Ser_Out_Bytes		;Bytes in Ser_Out_Buff
	Ser_In_InPtr
	Ser_In_OutPtr
	Ser_Out_InPtr
	Ser_Out_OutPtr
	Ser_In_Buff:20
	Ser_Out_Buff:20
	endc
;=========================================================================================
; Common Ram 70-7F same for all banks
; paramiter passing and temp vars
;=========================================================================================

	cblock	0x70
	Param70
	Param71
	Param72
	Param73
	Param74
	Param75
	Param76
	Param77
	Param78		; LoadFSRx working index
	Param79		; I2C message start
	Param7A		; Counter for LCD display
	Param7B
	Param7C
	Param7D
	Param7E
	Param7F
	endc
;
			;  Flags bits
;
;
;=========================================================================================
; Conditionals
;
HasISR	EQU	0x80	; Used to enable interupts
;			;    0x80=true 0x00=false
;=========================================================================================
;=========================================================================================
; ID Locations
	__idlocs	0x10d1
;
;=========================================================================================
; ***************** Reset Vector ******************
;=========================================================================================
;
	ORG	0x000	; processor reset vector
	CLRF	STATUS
	CLRF	PCLATH
	goto	Main	; go to beginning of program
;
;===============================================================================================
; Interupt Service Routine
;
; we loop through the interupt service routing every 0.008192 seconds
;
;
	ORG	0x004	; interrupt vector location
	clrf	BSR	; bank0
	clrf	PCLATH
;
; Timer 2
	BTFSS	PIR1,TMR2IF
	GOTO	TMR2_End
;Decrement timers until they are zero
; 
;
	CLRF	FSR0H
	call	DecTimer1	; Decrement timers if not zero
	call	DecTimer2
	call	DecTimer3
	call	DecTimer4
;
;-------------------------------------------------------------
; Blink LEDs

	BankSel	TRISA
	BSF	heartBeat	; HeartBeat LED off
;
	BankSel	PORTA	; Bank 0
;
;
SystemBlink_1	DECFSZ	tickcount,F
	goto	TMR2_Done
;
	MOVF	LED_Time,W
	MOVWF	tickcount
	BankSel	TRISA
	BCF	heartBeat	; HeartBeat LED on
	movlb	0
;
; ----------------------------------------------------------
;
TMR2_Done	BCF	PIR1,TMR2IF
TMR2_End:
;
;-----------------------------------------------------------------------------------------
;AUSART Serial ISR
;
IRQ_Ser	BTFSS	PIR1,RCIF	;RX has a byte?
	BRA	IRQ_Ser_End
	CALL	RX_TheByte
;
IRQ_Ser_End:
;--------------------------------------------------------------------
	retfie		; Return from interrupt
;
;=========================================================================================
;*****************************************************************************************
;=========================================================================================
;
Main:
	BankSel	OPTION_REG	; Bank 1
	bsf	OPTION_REG,NOT_WPUEN	; disable pullups on port B
	bcf	OPTION_REG,TMR0CS	; TMR0 clock Fosc/4
	bcf	OPTION_REG,PSA	; prescaler assigned to TMR0
	bsf	OPTION_REG,PS0	; 111 8mhz/4/256=7812.5hz=128uS/Ct=0.032768S/ISR
	bsf	OPTION_REG,PS1	; 101 8mhz/4/64=31250hz=32uS/Ct=0.008192S/ISR
	bsf	OPTION_REG,PS2
;
	BankSel	OSCCON	; Bank 1
	movlw	OSCCON_Val	;  8 MHz
	MOVWF	OSCCON
	movlw	b'00010111'	;WDT prescaler  RESET value
			; 1:65536 period is 2 sec
	movwf	WDTCON 	
;
;Setup T2 for 100/s
	movlb	0
	MOVLW	T2CON_Value
	MOVWF	T2CON
	MOVLW	PR2_Value
	MOVWF	PR2
;
; setup data ports
	BankSel	ANSELA	; Analog ports 
	clrf	ANSELA
	clrf	ANSELB
;
	BankSel	PORTA	; Init ports
	movlw	PortAValue
	movwf	PORTA
	movlw	PortBValue
	movwf	PORTB
;
	BankSel	TRISA
	MOVLW	PortADDRBits	; 0x20  LCD out | MSG Sw input
	MOVWF	TRISA
	movlw	PortBDDRBits	; Set RB1/SDA, RB4/SLC input
	movwf	TRISB
;
	CLRWDT
	call	ClearRam	; clear memory to zero
;
	movlb	0
	MOVLW	LEDTIME	; for heart beat
	MOVWF	LED_Time
	MOVLW	0x01
	MOVWF	tickcount
;
	CLRWDT
;
BAUDCON_Value	EQU	b'00001000'
TXSTA_Value	EQU	b'00100100'	;8 bit, TX enabled, Async, High speed
RCSTA_Value	EQU	b'10010000'	;RX enabled, 8 bit, Continious receive
; 8MHz clock high speed (BRGH=1,BRG16=1)
Baud_300	EQU	d'6666'	;0.299, -0.02%
Baud_1200	EQU	d'1666'	;1.199, -0.08%
Baud_2400	EQU	d'832'	;2.404, +0.16%
Baud_9600	EQU	d'207'	;9.615, +0.16%
Baud_19_2	EQU	d'103'	;19.23k, +0.16
Baud_57_6	EQU	d'34'	;57.14k, -0.79
BaudRate	EQU	Baud_9600
;-------------
;
; setup serial I/O
	BANKSEL	TXSTA	; bank 3
	MOVLW	TXSTA_Value
	MOVWF	TXSTA
	MOVLW	low BaudRate
	MOVWF	SPBRGL
	MOVLW	high BaudRate
	MOVWF	SPBRGH
	MOVLW	RCSTA_Value
	MOVWF	RCSTA
;
	movlb	0x01	; bank 1
	BSF	PIE1,RCIE	; Serial Receive interupt
	movlb	0x00	; bank 0
;
;Enable Interrupts
	BANKSEL	PIE1	;bank 1
	BSF	PIE1,TMR2IE
	bsf	INTCON,PEIE	; enable periferal interupts
	bsf	INTCON,GIE	; enable interupts
;
	movlb	0
	movlw	.100	; Wait 1 Secs
	movwf	Timer4Lo
Init_L1	movf	Timer4Lo,F
	btfss	_Z
	bra	Init_L1
;
;=================================
; Test
	clrf	Param78
	bra	Test_End
Test_L1	CLRWDT
	BTFSS	PIR1,TXIF
	bra	Test_L1
	movlw	'A'
	BANKSEL	TXREG
	MOVWF	TXREG
	MOVLB	0
	decfsz	Param78,F
	bra	Test_L1
Test_End:
;	movlw	.10
;	MOVWF	LED_Time
;
;=========================================================================================
;******** Main Loop **********************************************************************
;=========================================================================================
MainLoop	CLRWDT
	movf	Timer1Lo,F
	SKPZ
	bra	ML_1
;
	movlw	0x20	;take 1.6 seconds to do all 8
	movwf	Timer1Lo
;
	call	GetSwitchValue	;Param71 3:0
	movf	Param70,W
	addlw	OldSWValues
	movwf	FSR1L
	movlw	high OldSWValues
	movwf	FSR1H
	movf	Param71,W
	subwf	INDF1,W
	SKPNZ		;Changed?
	bra	ML_1	; No
;
	movf	Param71,W
	movwf	INDF1
	call	SendConnectString
;
ML_1	BTFSC	PIR1,TXIF	;TX done?
	CALL	TX_TheByte	; Yes
;
; move any serial data received into the 32 byte input buffer
	BTFSS	DataReceivedFlag
	BRA	ML_Ser_Out
	MOVF	RXByte,W
	BCF	DataReceivedFlag
	CALL	StoreSerIn
;
;=========================================================================================
; If the serial data has been sent and there are bytes in the buffer, send the next byte
;
ML_Ser_Out	BTFSS	DataSentFlag
	BRA	ML_Ser_End
	CALL	GetSerOut
	BTFSS	Param78,0
	BRA	ML_Ser_End
	MOVWF	TXByte
	BCF	DataSentFlag
ML_Ser_End
;
	goto	MainLoop
;
;=========================================================================================
;*****************************************************************************************
;=========================================================================================
;Entry: Param70 Monitor number, Param71 camera number
;Exit: none
;Format: Input# * Output# ! <cr>
SendConnectString	movf	Param71,W	;Switch value
	andlw	0x07
	addlw	'1'
	call	StoreSerOut
	movlw	'*'
	call	StoreSerOut
	movf	Param70,W
	addlw	'1'
	call	StoreSerOut
	movlw	'!'
	call	StoreSerOut
	movlw	0x0D
	call	StoreSerOut	
;
	return
;
;=========================================================================================
;Entry: Param70 Address in LSb 3 bits
;Exit: Param70++, Param71 Data
;
GetSwitchValue	incf	Param70,F	;Next Address
	movlw	0x07
	andwf	Param70,F	;keep low 3 bits
;
	movlb	2	;Bank 2
	btfss	Param70,0
	bcf	Sel_A0
	btfsc	Param70,0
	bsf	Sel_A0
;
	btfss	Param70,1
	bcf	Sel_A1
	btfsc	Param70,1
	bsf	Sel_A1
;
	btfss	Param70,2
	bcf	Sel_A2
	btfsc	Param70,2
	bsf	Sel_A2
; convert gray code to binary
	movf	Param70,W
	sublw	0x01	;monitor 2
	SKPNZ
	bra	FixMon2
;
	movlb	0
	movf	PORTA,W
	andlw	0x0F
	movwf	Param78
GetSwitchValue_E2	andlw	0x08
	movwf	Param71	;copy MSb
	lsrf	WREG,F
	xorwf	Param78,W	;make bit 2
	andlw	0x04
	iorwf	Param71,F	;save bit 2
	lsrf	WREG,F
	xorwf	Param78,W	;make bit 1
	andlw	0x02
	iorwf	Param71,F	;save bit 1
	lsrf	WREG,F
	xorwf	Param78,W	;make bit 0
	andlw	0x01
	iorwf	Param71,F	;save bit 0
;
	return
;
; monitor 2 has bits 0 and 1 reversed
FixMon2	movlb	0
	movf	PORTA,W
	andlw	0x0F
	movwf	Param79
	andlw	0x0C
	movwf	Param78
	btfsc	Param79,0
	bsf	Param78,1
	btfsc	Param79,1
	bsf	Param78,0
	movf	Param78,W
	bra	GetSwitchValue_E2
;
	include	F1847_Common.inc
	include	SerBuff1847.inc
;
	END
