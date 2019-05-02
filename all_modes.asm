		title	"All Modes"
		list	p=16f84A
		radix	hex
		include	"p16f84A.inc"
	
COUNT1	EQU		d'12'
COUNT2	EQU		d'13'
COUNT3	EQU		d'14'
COUNT4	EQU		d'15'
COUNT5	EQU		d'16'
COUNT6	EQU		d'17'
COUNT7	EQU		d'18'
LOC		EQU		d'20'	;knowing in which mode we are (and dealing differently with interrupts)
ADDRESS	EQU		d'21'	;address of lcd
CCARD	EQU		d'22'	;current card address
FLAGS	EQU		d'23'	;bit 0: first card (if 0 it's the first)
;register FLAGS: bits 7 downto 2 are used in the bonus part
PREVC	EQU		d'24'	;register address of the previous card opened for matching
MATCHES	EQU		d'25'	;number of matches
METER	EQU		d'26'	;number of non-matching
NEXTMET	EQU		d'27'	;address of the next meter lcd address to change
TEMP	EQU		d'28'	;temporary reg
PREVLCD	EQU		d'29'	;storing the lcd address of first opened card
SCORE3	EQU		d'30'	;storing the score in mode 3 which starts at 13
REV3	EQU		d'31'	;storing the number of revealed cards in mode 3
BONUS	EQU		d'32'	;used for the bonus part
CARD1	EQU		d'50'	;for the cards, bit 7 is 1 if it is opened (in mode 1-3). bit 6 is 1 if it was revealed (in mode 3)
CARD2	EQU		d'51'
CARD3	EQU		d'52'
CARD4	EQU		d'53'
CARD5	EQU		d'54'
CARD6	EQU		d'55'
CARD7	EQU		d'56'
CARD8	EQU		d'57'
CARD9	EQU		d'58'
CARD10	EQU		d'59'
CARD11	EQU		d'60'
CARD12	EQU		d'61'
C1		EQU		d'62'	;COUNTER FOR TMR0 INTERRUPT	
DIGIT	EQU		d'63'	;DIGIT IN MODE2 TO BE CHANGED
OLDADD	EQU		d'64'	;OLD ADDRESS OF THE USER CURSOR

		ORG		0x0
		GOTO	MAIN
		ORG		0x04		
		BTFSC	INTCON,RBIF
		GOTO	RBINT
		BTFSC	INTCON,T0IF		;TMR0 INTERRUPT
		GOTO	T0INT


MAIN	BSF		STATUS,RP0
		CLRF	TRISA		;all ports on A are output
		MOVLW	b'11110000'
		MOVWF	TRISB		;ports(0-3) on B are output and ports(4-7) are input

		MOVLW	b'10000111'	;disable portb pull-ups and set tmr0 prescaler to 1:256
		MOVWF	OPTION_REG
		BCF		STATUS,RP0
		CLRF	PORTB
		CLRF	PORTA
		MOVLW	b'00001000' ;disable global interrupt and enable RB port change interrupt for the welcome screen
		MOVWF	INTCON

		CALL	DELAY40		;4-bit mode
		MOVLW	b'00010'
		MOVWF	PORTA
		CALL	ET

		CALL	ET

		MOVLW	b'01000'	;2-line and 5x7 dots
		MOVWF	PORTA
		CALL	ET


		MOVLW	b'00000'
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'00110'	;increment mode and entire shift off
		MOVWF	PORTA
		CALL	ET

	
		;initialize registers to be used
		CLRF	LOC
		BSF		LOC,0	;we're in welcome

		CALL	INITIAL

		;welcome screen
		CALL	PRTBL
		CALL	PRINTM
		CALL	PRINTE
		CALL	PRINTM
		CALL	PRINTO
		CALL	PRINTR
		CALL	PRINTY
		CALL	PRTBL
		CALL	PRINTG
		CALL	PRINTA
		CALL	PRINTM
		CALL	PRINTE
		CALL	DELAYBUZ
		CALL	DELAYBUZ
		
		CALL	MMENU

INF		GOTO	INF		;infinite loop


INITIAL	CLRF	CCARD		;initialization
		CLRF	FLAGS
		CLRF	PREVC
		CLRF	MATCHES
		CLRF	METER
		CLRF	BONUS
		MOVLW	d'9'
		MOVWF	NEXTMET		;first lcd address to fill is 9 (for the S-W meter in Mode 1)
		CLRF	REV3
		MOVLW	d'13'
		MOVWF	SCORE3		;the score in mode 3 starts at 13 and then gets updated
		MOVLW	b'00000001'	;card A
		MOVWF	CARD2
		MOVWF	CARD11
		MOVLW	b'00000010'	;card B
		MOVWF	CARD5
		MOVWF	CARD7
		MOVLW	b'00000100'	;card C
		MOVWF	CARD1
		MOVWF	CARD10
		MOVLW	b'00001000'	;card D
		MOVWF	CARD6
		MOVWF	CARD8
		MOVLW	b'00010000'	;card E
		MOVWF	CARD3
		MOVWF	CARD12
		MOVLW	b'00100000'	;card F
		MOVWF	CARD4
		MOVWF	CARD9

		CALL	CURSOFF
		CALL	CLRDSP
		
		RETURN

		
		;mode screen
MMENU	BCF		LOC,0	
		BSF		LOC,1	;we're in menu

		MOVLW	b'10001000' ;enable global interrupt and enable RB port change interrupt
		MOVWF	INTCON

		CALL	CLRDSP

		CALL	PRINTM
		CALL	PRINTO
		CALL	PRINTD
		CALL	PRINTE
		CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINTST
		CALL	PRINT1
		CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINT2
		CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINT3
		
		MOVLW	d'6'	;current star address
		MOVWF	ADDRESS
		RETURN


DELAY40	MOVLW	H'00'	;delay of 40ms
		MOVWF	COUNT1
		MOVLW	d'52'
		MOVWF	COUNT2
		
LOOP40	INCFSZ	COUNT1,F
		GOTO	LOOP40
		DECFSZ	COUNT2,F
		GOTO	LOOP40
		RETURN

DELAY2	MOVLW	H'00'	;delay of 2ms
		MOVWF	COUNT3
		MOVLW	d'3'
		MOVWF	COUNT4
		
LOOP2	INCFSZ	COUNT3,F
		GOTO	LOOP2
		DECFSZ	COUNT4,F
		GOTO	LOOP2
		RETURN

DELAYBUZ	MOVLW	H'00'	;Delay for Buzzer sound ABOUT 1 SECOND
		MOVWF	COUNT7
		MOVWF	COUNT6
		MOVLW	0x06
		MOVWF	COUNT5
		
LOOPBUZ	INCFSZ	COUNT7,F
		GOTO	LOOPBUZ
		INCFSZ	COUNT6,F
		GOTO	LOOPBUZ
		DECFSZ	COUNT5,F
		GOTO	LOOPBUZ
		RETURN

ET		BSF		PORTB,1
		NOP
		BCF		PORTB,1
		CALL	DELAY2
		RETURN


RBINT	CALL	DELAY40		;debounce
		BTFSC	LOC,1		;mode selection
		GOTO	MSEL
		BTFSS	PORTB,4
		GOTO	LEFTM1
		BTFSS	PORTB,5
		GOTO	RIGHTM1
		BTFSS	PORTB,6
		GOTO	UDM1
		BTFSS	PORTB,7
		GOTO	CONFM1
		GOTO	EXITRB
		
T0INT 	DECFSZ	C1,F			;TIMER0 INTERRUPT
		GOTO	RETZ			
		CALL	SAVEADD			;SAVE ADDRESS
		DECF	DIGIT,1			;DECREMENT VALUE OF DIGIT
		MOVF	DIGIT,0		
		MOVWF	TEMP			;PRINT NEW DIGIT
		CALL	PRINTDIG
		MOVLW	d'0'
		SUBWF	DIGIT,0			;CHECK IF NEW DIGIT ZERO
		BTFSC	STATUS,2
		GOTO	ENDG2			
		MOVF	OLDADD,0
		MOVWF	ADDRESS			;RESTORE OLD ADDRESS
		CALL	SETLCD
		MOVLW	d'154'			;using 1:256 we need 154 
		MOVWF	C1
		CLRF	TMR0
RETZ	BCF		INTCON,T0IF
		RETFIE

EXITRB	BCF		INTCON,RBIF
		NOP
		RETFIE

MSEL	BTFSS	PORTB,5		;in mode select, completely ignore left and up-down -> don't even check for them
		GOTO	RMODE
		BTFSS	PORTB,7
		GOTO	CONMODE
		GOTO	EXITRB		;if none of them is set (so left or up-down was) exit

LEFTM1	INCF	ADDRESS,0		;CHECK IF ADDRESS 0(first line)
		MOVWF	TEMP			;TEMP=ADDRESS+1
		DECFSZ	TEMP,0			;CHECK IF TEMP-1=0 OR ADDRESS=0
		GOTO	NOTADDFL		;NOT ADDRESS FIRST LINE LEFT
		CALL	BUZZER			;BUZZER SOUND
		GOTO	EXITRB

NOTADDFL MOVLW	D'63'			;IF IT IS NOT AT THE FIRST LINE
		SUBWF	ADDRESS,0		;IF SECOND LINE=>64 DO 64-63 THEN CHECK IF WHEN WE DEC IT IS ZERO
		MOVWF	TEMP			;DONT WANT TO CHANGE ADDRESS
		DECFSZ	TEMP,0
		GOTO	NOTADD0
		CALL	BUZZER			;BUZZER SOUND
		GOTO	EXITRB
		
NOTADD0	DECF	ADDRESS,1		;DECREMENT ADDRESS AND CHANGE ON LCD
		CALL	SETLCD
		GOTO	EXITRB



RMODE	CALL	SETLCD		;go on lcd to address
		CALL	PRINTSP		;replace the star by a space
		MOVLW	d'12'
		SUBWF	ADDRESS,0
		BTFSC	STATUS,2	;if star is at address 1100 (12), we don't skip		
		GOTO	STAR12
		MOVLW	d'3'
		ADDWF	ADDRESS,1	;add 3 to the address otherwise
RMODEX	CALL	SETLCD		;go on lcd to new address for star
		CALL	PRINTST
		GOTO	EXITRB
STAR12	MOVLW	d'6'
		MOVWF	ADDRESS
		GOTO	RMODEX

RIGHTM1	MOVLW	H'4'
		SUBWF	ADDRESS,0		;IF FIRST LINE=>16 DO 16-15 THEN CHECK IF WHEN WE DEC IT IS ZERO
		MOVWF	TEMP			;DONT WANT TO CHANGE ADDRESS
		DECFSZ	TEMP,0
		GOTO	NOTADDFLR		;NOT ADDRESS FIRST LINE RIGHT
		CALL	BUZZER
		GOTO	EXITRB
		
NOTADDFLR	MOVLW	H'44'
		SUBWF	ADDRESS,0		;IF SECOND LINE=>45HEX DO 45H-44H THEN CHECK IF WHEN WE DEC IT IS ZERO
		MOVWF	TEMP			;DONT WANT TO CHANGE ADDRESS
		DECFSZ	TEMP,0
		GOTO	NOTADD0F
		CALL	BUZZER			;BUZZER SOUND
		GOTO	EXITRB		

NOTADD0F	INCF	ADDRESS,1		;INCREMENT ADDRESS AND CHANGE ON LCD
		CALL	SETLCD
		GOTO	EXITRB


								;THIS IS OPTIMIZED SINCE WE ONLY CHANGE A XOR
UDM1	MOVLW	b'01000000'		;WE NEED TO CHANGE BIT7 OF ADDRESS SO IF WE XOR IT WITH 1 WE WILL CHANGE IT		
		XORWF	ADDRESS,1		;ONLY USED A XOR GATE
		CALL	SETLCD			;SET NEW ADDRESS
		GOTO	EXITRB

CONMODE	BTFSS	ADDRESS,3	;if star is at address 0110 (6) then the bit 3 is 0 (in others it's 1)
		GOTO	MODE1
		BTFSC	ADDRESS,0	;if star is at address 1001 (9) then the bit 0 is 1 then don't skip and go to mode 2
		GOTO	MODE2	;if the bit is 1 then go to mode 2
		GOTO	MODE3	;otherwise go to mode 3
		GOTO	EXITRB

MODE1	CLRF	LOC
		BSF		LOC,2		;we're in mode 1
		CALL	CLRDSP
		CALL	CURSON		;turn the cursor on
		CALL	PRINTSC1
		CLRF	ADDRESS		;set address to 0
		GOTO	EXITRB

MODE2	CLRF	LOC		
		BSF		LOC,3		;we're in mode 2
		CALL	CLRDSP
		CALL	CURSON		;turn the cursor on
		MOVLW	d'154'		;NEED 154 TO MAKE 10 SECOND DELAY
		MOVWF	C1		
		MOVLW	d'9'		;DIGIT STARTS AT 9 SINCE WE ONLY NEED TO CHANGE ONE DIGIT
		MOVWF	DIGIT			
		BSF		INTCON,T0IE	;ENABLING TIMER 0 INTERRUPT
		CALL	PRINTM2
		CLRF	ADDRESS
		GOTO	EXITRB

MODE3	CLRF	LOC
		BSF		LOC,4		;we're in mode 3
		CALL	CLRDSP
		CALL	CURSON		;turn the cursor on
		CALL	PRINTSC3
		CLRF	ADDRESS
		GOTO	EXITRB

CONFM1	CALL	FINDC
		BTFSC	INDF,7	;if 7th bit of INDF is 0 then skip because the card was not revealed before
		GOTO	BUZZOP	;error while opening because the card was revealed
		
		BTFSS	FLAGS,0	;if bit 0 of flags is 0 then we are opening the first card
		GOTO	OPENF	;goto open first card if bit is 0
		GOTO	OPENS	;goto open second card if bit is 1	

OPENF	BSF		INDF,7	;set the 7th bit of the corresponding card because we are opening it
		BSF		FLAGS,0	;set 0th bit of FLAGS because we are opening the first card
		MOVF	FSR,0
		MOVWF	PREVC	;moving register address of first opened card to PREVC
		CALL 	CHARP	;character print
		MOVF	ADDRESS,0
		MOVWF	PREVLCD	;moving lcd address of first opened card to PREVLCD
		
		GOTO	EXITCON


CHARP	CALL	SETLCD
		BTFSC	INDF,0
		CALL 	PRINTA
		BTFSC	INDF,1
		CALL 	PRINTB
		BTFSC	INDF,2
		CALL 	PRINTC
		BTFSC	INDF,3
		CALL 	PRINTD
		BTFSC	INDF,4
		CALL 	PRINTE
		BTFSC	INDF,5
		CALL 	PRINTF
		RETURN

OPENS	BTFSC	INDF,7	;if 7th bit of INDF is 0 then skip because the card was not opened before
		GOTO	BUZZOP	;error while opening because the card was opened
		BCF		FLAGS,0	;change this back to 0 because we are opening second card

		CALL	CHARP	;print opened character
		BSF		INDF,7
		MOVF	FSR,0
		MOVWF	CCARD	;placing register address of current card in CCARD
		MOVF	INDF,0
		ANDLW	b'00111111'	;this line makes the last two bits 0 because in mode 0, one card might be revealed and the other not
		MOVWF	TEMP	;placing register content (with first two bits 0) of current card in TEMP
		MOVF	PREVC,0
		MOVWF	FSR		;moving to FSR the register address of the previous card
		MOVF	INDF,0	;moving the register content of the previous card to W
		ANDLW	b'00111111'	;this line makes the last two bits 0 because in mode 0, one card might be revealed and the other not
		SUBWF	TEMP,1	;subtracting register contents of current and previous card
		INCF	TEMP	;if subtraction result was 0, change it to 1
		DECFSZ	TEMP,1	;if result is 0 then both register contents were equal then we have a match
		GOTO	NOMATCH
		INCF	MATCHES	;if we got here then we have a match
		INCF	SCORE3	;increment the score
		CALL	BUZZER	;buzzer should be activated in case of a match
		BTFSC	LOC,2	;if bit 2 is set, then you are in mode1, do not skip and go to got a match in mode 1 (GOOD1)
		GOTO	GOOD1
		BTFSC	LOC,3	;if bit 3 is set, then you are in mode 2, do not skip and go to got a match in mode 2 (GOOD2)
		GOTO	GOOD2
		GOTO	GOOD3	;go to got a match in mode 3 (GOOD3) 

GOOD1	MOVLW	d'6'
		SUBWF	MATCHES,0
		BTFSS	STATUS,2	;if result is 0 then the user won so skip and go to victory
		GOTO	EXITCON
		GOTO	WIN1

GOOD2	MOVLW	d'6'
		SUBWF	MATCHES,0
		BTFSS	STATUS,2	;if result is 0 then the user won so skip and go to victory
		GOTO	EXITCON
		GOTO	ENDG2

GOOD3	MOVF	ADDRESS,0
		MOVWF	CCARD	;save current LCD address in CCARD (we are thus overwriting the current register address of the card but it's okay because we don't need it anymore)

		MOVLW	d'13'	
		MOVWF	ADDRESS
		CALL	SETLCD
		CALL	PRTMAT	;printing the number of matches in the right position
		MOVLW	d'78'
		MOVWF	ADDRESS
		CALL	SETLCD
		CALL	PRTSCOR	;printing the score in the right position

		MOVF	CCARD,0
		MOVWF	ADDRESS	;setting back address to right position

		MOVLW	d'6'
		SUBWF	MATCHES,0
		BTFSS	STATUS,2	;if result is 0 then the user won so skip and go to victory
		GOTO	EXITCON
		GOTO	WIN3

NOMATCH	CALL 	RED1S	;turning the red led on, with a delay of 1 second
		
		BCF		INDF,7	;clearing 7th bit of previous card because we will close it

		MOVF	CCARD,0
		MOVWF	FSR
		BCF		INDF,7	;clearing 7th bit of current card because we will close it

		CALL	SETLCD
		CALL	PrtBox	;printing back a box instead of the second opened character
		MOVF	ADDRESS,0
		MOVWF	TEMP
		MOVF	PREVLCD,0
		MOVWF	ADDRESS	;getting address of first opened character
		CALL	SETLCD
		CALL 	PrtBox	;printing back a box instead of the first opened character
		MOVF	TEMP,0
		MOVWF	ADDRESS

		INCF	METER	;incrementing number of nonmatching
		BTFSC	LOC,2	;if bit 2 is set, then you are in mode1, do not skip and go to update mode 1 (M1UP)
		GOTO	M1UP
		BTFSC	LOC,3	;if bit 3 is set, then you are in mode 2, do not skip and go to update mode 2 (M2UP)
		GOTO	M2UP
		GOTO	M3UP	


;BONUS function for score -2 if both cards had been revealed
;for setting the appropriate flags
RBONUS	BTFSC	INDF,0	;card is an A
		CALL	RBONUSA
		BTFSC	INDF,1	;B
		CALL	RBONUSB
		BTFSC	INDF,2	;C
		CALL	RBONUSC
		BTFSC	INDF,3	;D
		CALL	RBONUSD
		BTFSC	INDF,4	;E
		CALL	RBONUSE
		BTFSC	INDF,5	;F
		CALL	RBONUSF
		RETURN

RBONUSA	BTFSC	FLAGS,2	
		BSF		BONUS,2	;both cards A have been revealed
		BTFSS	FLAGS,2	;if this bit is set, then we have already revealed a card of type A
		BSF		FLAGS,2
		RETURN

RBONUSB	BTFSC	FLAGS,3	
		BSF		BONUS,3	;both cards B have been revealed
		BTFSS	FLAGS,3	;if this bit is set, then we have already revealed a card of type B
		BSF		FLAGS,3
		RETURN

RBONUSC	BTFSC	FLAGS,4	
		BSF		BONUS,4	;both cards C have been revealed
		BTFSS	FLAGS,4	;if this bit is set, then we have already revealed a card of type C
		BSF		FLAGS,4
		RETURN

RBONUSD	BTFSC	FLAGS,5	
		BSF		BONUS,5	;both cards D have been revealed
		BTFSS	FLAGS,5	;if this bit is set, then we have already revealed a card of type D
		BSF		FLAGS,5
		RETURN

RBONUSE	BTFSC	FLAGS,6	
		BSF		BONUS,6	;both cards E have been revealed
		BTFSS	FLAGS,6	;if this bit is set, then we have already revealed a card of type E
		BSF		FLAGS,6
		RETURN

RBONUSF	BTFSC	FLAGS,7	
		BSF		BONUS,7	;both cards F have been revealed
		BTFSS	FLAGS,7	;if this bit is set, then we have already revealed a card of type F
		BSF		FLAGS,7
		RETURN

IBONUS	BTFSC	INDF,0	;card is an A
		CALL	IBONUSA
		BTFSC	INDF,1	;B
		CALL	IBONUSB
		BTFSC	INDF,2	;C
		CALL	IBONUSC
		BTFSC	INDF,3	;D
		CALL	IBONUSD
		BTFSC	INDF,4	;E
		CALL	IBONUSE
		BTFSC	INDF,5	;F
		CALL	IBONUSF
		RETURN

IBONUSA	BTFSS	BONUS,2	;if the bit is set, then both cards have been revealed
		RETURN
		INCF	REV3	;if score is 1, then only increment the rev3 and dont decrement the score, since it will be decremented again
		DECFSZ	SCORE3,1
		RETURN
		INCF	SCORE3	;if score is 0, re-increment it to 1
		RETURN

IBONUSB	BTFSS	BONUS,3	;if the bit is set, then both cards have been revealed
		RETURN
		INCF	REV3	;if score is 1, then only increment the rev3 and dont decrement the score, since it will be decremented again
		DECFSZ	SCORE3,1
		RETURN
		INCF	SCORE3	;if score is 0, re-increment it to 1
		RETURN

IBONUSC	BTFSS	BONUS,4	;if the bit is set, then both cards have been revealed
		RETURN
		INCF	REV3	;if score is 1, then only increment the rev3 and dont decrement the score, since it will be decremented again
		DECFSZ	SCORE3,1
		RETURN
		INCF	SCORE3	;if score is 0, re-increment it to 1
		RETURN

IBONUSD	BTFSS	BONUS,5	;if the bit is set, then both cards have been revealed
		RETURN
		INCF	REV3	;if score is 1, then only increment the rev3 and dont decrement the score, since it will be decremented again
		DECFSZ	SCORE3,1
		RETURN
		INCF	SCORE3	;if score is 0, re-increment it to 1
		RETURN

IBONUSE	BTFSS	BONUS,6	;if the bit is set, then both cards have been revealed
		RETURN
		INCF	REV3	;if score is 1, then only increment the rev3 and dont decrement the score, since it will be decremented again
		DECFSZ	SCORE3,1
		RETURN
		INCF	SCORE3	;if score is 0, re-increment it to 1
		RETURN

IBONUSF	BTFSS	BONUS,7	;if the bit is set, then both cards have been revealed
		RETURN
		INCF	REV3	;if score is 1, then only increment the rev3 and dont decrement the score, since it will be decremented again
		DECFSZ	SCORE3,1
		RETURN
		INCF	SCORE3	;if score is 0, re-increment it to 1
		RETURN


;now updating the nonmatching bar meter
M1UP	MOVLW	d'15'	;15 is the lcd address of W on the screen
		SUBWF	NEXTMET,0
		BTFSS	STATUS,2	;if result is 0 then we next need to print on W (which should not happen) so do not print and exit
		GOTO	UPDATE1		;if result was not 0 then we need to update the bar meter accordingly so go to UPDATE1
		GOTO	EXITCON

M2UP	GOTO	EXITCON

M3UP	BTFSS	INDF,6		;if 6th bit of current card is 1, then the card was already revealed, so skip, decrement score and increment revealed
		GOTO	NOINC3		;no need to increment because of current card so go to NOINC3
		CALL	IBONUS
		INCF	REV3		;increment number of revealed cards
		DECF	SCORE3		;decrement score
		CALL	NEWSC		;print the new score and the new number of revealed cards
		MOVLW	d'13'		;now check if we reached the maximum number of revealed cards which is 13
		SUBWF	REV3,W		;don't set card as revealed again
		BTFSC	STATUS,0	;if bit 0 of status register is 1 then number of revealed is >= 13 then don't skip and go to loss (LOSS3)
		GOTO	LOSS3
		GOTO	NOSETR		
NOINC3	BSF		INDF,6		;set current card as revealed
		CALL	RBONUS
NOSETR	MOVF	PREVC,0		
		MOVWF	FSR
		BTFSS	INDF,6		;if 6th bit of previous card is 1, skip and increment score and revealed
		GOTO	NOINC3B		;if previous card wasn't already revealed then no need to update score and revealed so go to NOINC3B
		CALL	IBONUS
		INCF	REV3
		DECF	SCORE3
		CALL	NEWSC		;print the new score and the new number of revealed cards
		MOVLW	d'13'		;now check if we reached the maximum number of revealed cards which is 13
		SUBWF	REV3,W
		BTFSC	STATUS,0	;if bit 0 of status register is 1 then number of revealed is 13 then don't skip and go to loss (LOSS3)
		GOTO	LOSS3
		GOTO	EXITCON

NOINC3B	BSF		INDF,6		;set previous card as revealed
		CALL	RBONUS
		GOTO	EXITCON

LOSS3	CALL	CURSOFF
		CALL	BUZZER		;number of revealed cards was exceeded so make a short buzz
		CALL	DELAYBUZ	;additional delay of 1 sec before leaving
		GOTO	LEAVE		;leaving and resetting everything to go back to mode select

;this function prints again the number of revealed cards and the score in case we need to update one of them
NEWSC	MOVF	ADDRESS,0
		MOVWF	CCARD	;save current LCD address in CCARD (we are thus overwriting the current register address of the card but it's okay because we don't need it anymore)

		MOVLW	d'9'	
		MOVWF	ADDRESS
		CALL	SETLCD
		CALL	PRTREV	;printing the number of revealed cards in the right position
		MOVLW	d'78'
		MOVWF	ADDRESS
		CALL	SETLCD
		CALL	PRINTSP	;remove previous digit
		CALL	PRINTSP
		MOVLW	d'78'
		MOVWF	ADDRESS		
		CALL	SETLCD
		CALL	PRTSCOR	;printing the score in the right position

		MOVF	CCARD,0
		MOVWF	ADDRESS	;setting back address to right position
		RETURN

;this function updates the bar meter in mode1 in case of a non-match
UPDATE1	MOVF	METER,0	;moving meter to W
		MOVWF	TEMP
		DECFSZ	TEMP,1	;if result is 0 it means the meter was equal to 1
		GOTO	NOCHANGE	;if we got here then meter was not 1 so it was 2 so don't print
		
		MOVF	ADDRESS,0
		MOVWF	TEMP	;save address in temp

		MOVF	NEXTMET,0
		MOVWF	ADDRESS
		CALL	SETLCD
		CALL	PRINTBS	;printing a black square in the right position

		MOVF	TEMP,0
		MOVWF	ADDRESS	;setting back address to right position

		INCF	NEXTMET	;incrementing address where we will write next on the bar meter
		GOTO	EXITCON

NOCHANGE	CLRF	METER
			GOTO	EXITCON

WIN1	CALL	CURSOFF	;disable the cursor when you win
		MOVLW	h'49'
		MOVWF	ADDRESS
		CALL	SETLCD
		
		MOVLW	d'16'	;if address to print next is 15 or 14 then it is weak
		
		SUBWF	NEXTMET,1
		INCFSZ	NEXTMET,1	;if it's 0 then it is weak then go to weak
		GOTO	DEC2
		GOTO	WEAK

DEC2	INCFSZ	NEXTMET,1	;if it's 0 then it is weak then go to weak
		GOTO	DEC3
		GOTO	WEAK

DEC3	INCFSZ	NEXTMET,1	;if it's 0 then it is verage then go to average
		GOTO	DEC4
		GOTO	AVERAGE

DEC4	INCFSZ	NEXTMET,1	;if it's 0 then it is average then go to average
		GOTO	SUPER
AVERAGE	CALL	PRINTA
		CALL	PRINTV
		CALL	PRINTG
		CALL	GREEN1S
		GOTO	LEAVE

SUPER	CALL	PRINTS
		CALL	PRINTU
		CALL	PRINTP
		CALL	PRINTE
		CALL	PRINTR
		CALL	BLINKGR
		GOTO	LEAVE

WEAK	CALL	PRINTW
		CALL	PRINTE
		CALL	PRINTA
		CALL	PRINTK
		CALL	RED1S
		GOTO	LEAVE

ENDG2	CALL	CURSOFF
		MOVLW	d'72'		;ENDG2 is called from either the tmr0 interrupt or when 6 matches are done
		MOVWF	ADDRESS
		CALL	SETLCD
		CALL	PRINTS
		CALL	PRINTC
		CALL	PRINTO
		CALL	PRINTR
		CALL	PRINTE
		CALL	PRINTSP
		MOVF	DIGIT,0
		ADDWF	MATCHES,0
		MOVWF	SCORE3
		CALL	PRTSCOR
		CALL	DELAYBUZ
		CALL	DELAYBUZ
		GOTO	LEAVE


WIN3	CALL	CURSOFF		;turn the cursor off
		CALL	BLINKGR		;display a flashing pattern of red and green LEDs
		GOTO	LEAVE	

LEAVE	CALL 	DELAYBUZ	;1sec delay
		CALL	INITIAL		;initialize all the variables again
		CALL	MMENU
		GOTO	EXITRB

FINDC	MOVLW	d'50'	;this function stores in FSR the register number of the card
		BTFSC	ADDRESS,6	;if 6th bit of address is 0 then it is the first line then skip
		ADDLW	D'6'	;if it is the second line then add 6
		MOVWF	FSR
		MOVF	ADDRESS,0
		MOVWF	TEMP
		BCF		TEMP,6
		INCF	TEMP
DEC		DECFSZ	TEMP,1
		GOTO	ADDC
		RETURN	;when result is 0, FSR contains the register number of the right card; return
		
ADDC	INCF	FSR
		GOTO	DEC

BUZZOP	CALL	BUZZER	;error while opening; call buzzer then return to home position then exit rb

EXITCON	CALL	HOMER
		GOTO	EXITRB

HOMER	MOVLW	b'00000'	;this is to return the cursor to the home position	
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'00010'
		MOVWF	PORTA
		CALL	ET
		CLRF	ADDRESS
		RETURN

CURSOFF	MOVLW	b'00000'
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'01100'	;display on, cursor off, blink off
		MOVWF	PORTA
		CALL	ET
		RETURN

CURSON	MOVLW	b'00000'
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'01110'	;display on, cursor on, blink off
		MOVWF	PORTA
		CALL	ET
		RETURN


CLRDSP	MOVLW	b'00000'	;clear display
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'00001'
		MOVWF	PORTA
		CALL	ET
		RETURN
		
		
SAVEADD	MOVF	ADDRESS,0		;SAVE OLD ADDRESS OF CURSOR 
		MOVWF	OLDADD
		MOVLW	d'13'
		MOVWF	ADDRESS			;MAKES THE ADDRESS THAT OF THE DIGIT
		CALL	SETLCD
		RETURN
		
		

SETLCD	SWAPF	ADDRESS,0	;VERY NICE FUNCTION! could be used to decrement	(to address in ADDRESS)
		ANDLW	b'00000111'	;get bits 2-0 (corresponding to bits 6-4 of address)
		IORLW	b'00001000'	;add the 1 for the set ddram address
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'00001111'
		ANDWF	ADDRESS,0	;get bits 3-0 of address
		MOVWF	PORTA
		CALL	ET
		RETURN


PRINTDIG	MOVLW	d'10'		;function for printing a digit stored in TEMP
			SUBWF	TEMP,0
			BTFSC	STATUS,0	;if the bit is 1, then there has been an overflow for the subtraction, and the result is positive (digit is >=10)
			GOTO	BIGDIG
SINGLEDIG	MOVLW	b'10011'	;we are sure that temp has a number < 10	
			MOVWF	PORTA
			CALL	ET
			BSF		TEMP,4		;TEMP already has the bits necessary for PORTA, it only needs the bit 4 to be set
			MOVF	TEMP,0
			MOVWF	PORTA
			CALL	ET
			RETURN			
BIGDIG		CALL	PRINT1		;assuming our numbers can't be greater than 19
			MOVLW	d'10'
			SUBWF	TEMP,1
			GOTO	SINGLEDIG


;Function to print the initial screen in mode 1
PRINTSC1	CALL	PRT6BOX		;Print 6 cards
		CALL	PRTBL			;Print blank
		CALL	PRINTS			;Print S
		CALL	PRT6DV			;Print 6 divide signs (+)
		CALL	PRINTW
		CALL	NEWLINE			;Move to new line
		CALL	PRT6BOX			;Print 6 cards
		CALL	HOMER
		RETURN

;Function to print the initial screen in mode 2
PRINTM2	CALL	PRT6BOX
		CALL	PRTBL
		CALL	PRINTR
		CALL	PRINTE
		CALL	PRINTM
		CALL	PRINTSP
		CALL	PRINTT
		MOVLW	d'9'
		MOVWF	TEMP
		CALL	PRINTDIG
		MOVLW	d'0'
		MOVWF	TEMP
		CALL	PRINTDIG
		CALL	NEWLINE	
		CALL	PRT6BOX
		CALL	HOMER
		RETURN



;Function to print the initial screen in mode 3
PRINTSC3	CALL	PRT6BOX
		CALL	PRTBL
		CALL	PRTMIN
		CALL	PRTREV		;to print number of revealed cards
		CALL	PRTBL
		CALL	PRTPLUS
		CALL	PRTMAT		;to print number of matched cards
		CALL	NEWLINE
		CALL	PRT6BOX
		CALL	PRTBL
		CALL	PRINTS
		CALL	PRINTC
		CALL	PRINTO
		CALL	PRINTR
		CALL	PRINTE
		CALL	PRINTSP
		CALL	PRTSCOR		;to print the current score (initialized to 13)
		CALL	HOMER
		RETURN

PRTREV	MOVF	REV3,W		;print number of revealed cards [MODE 3]
		MOVWF	TEMP
		CALL	PRINTDIG
		RETURN

PRTMAT	MOVF	MATCHES,W	;print number of matches[MODE 3]
		MOVWF	TEMP
		CALL	PRINTDIG
		RETURN

PRTSCOR	MOVF	SCORE3,W	;print score [MODE 3]
		MOVWF	TEMP
		CALL	PRINTDIG
		RETURN

BUZZER	BSF		PORTB,0		;turn on buzz sound
		CALL	DELAYBUZ	;delay of 1 sec
		BCF		PORTB,0		;turn off buzz sound
		RETURN


PRINTSP	MOVLW	b'10010'	;space
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10000'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTBS	MOVLW	b'11111'	;black square
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'11111'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRTMIN	MOVLW	b'11011'	;minus sign
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10000'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRTPLUS	MOVLW	b'10010'	;plus sign
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'11011'
		MOVWF	PORTA
		CALL	ET
		RETURN


PRINT1	MOVLW	b'10011'	;1
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10001'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINT2	MOVLW	b'10011'	;2
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10010'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINT3	MOVLW	b'10011'	;3
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10011'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTST	MOVLW	b'10010'	;*
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'11010'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTA	MOVLW	b'10100'	;A
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10001'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTB	MOVLW	b'10100'	;B
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10010'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTC	MOVLW	b'10100'	;C
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10011'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTD	MOVLW	b'10100'	;D
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10100'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTE	MOVLW	b'10100'	;E
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10101'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTF	MOVLW	b'10100'	;F
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10110'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTM	MOVLW	b'10100'	;M
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'11101'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTK	MOVLW	b'10100'	;K
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'11011'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTV	MOVLW	b'10101'	;V
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10110'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTG	MOVLW	b'10100'	;G
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10111'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTU	MOVLW	b'10101'	;U
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10101'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTP	MOVLW	b'10101'	;P
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10000'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTR	MOVLW	b'10101'	;R
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10010'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTS	MOVLW	b'10101'	;Print S
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10011'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTO	MOVLW	b'10100'	;O
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'11111'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTW	MOVLW	b'10101'	;Print W
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10111'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRINTY	MOVLW	b'10101'	;Print Y
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'11001'
		MOVWF	PORTA
		CALL	ET
		RETURN


PrtBox	MOVLW	b'11101'	;Card
		MOVWF	PORTA		
		CALL	ET
		MOVLW	b'11011'
		MOVWF	PORTA
		CALL	ET
		RETURN	

PRT6BOX	MOVLW	d'6'		;printing 6 boxes
		MOVWF	TEMP
BOXLOOP	CALL	PrtBox
		DECFSZ	TEMP,1
		GOTO	BOXLOOP	
		RETURN

PRTBL	CALL	PRINTSP		;Print Blank made of 2 spaces
		CALL	PRINTSP
		RETURN

PRTDV	MOVLW	b'11010'	;Print Divide sign
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10011'
		MOVWF	PORTA
		CALL	ET
		RETURN

PRT6DV	MOVLW	d'6'		;Print 6 Divide sign
		MOVWF	TEMP	
DVLOOP	CALL	PRTDV
		DECFSZ	TEMP,1
		GOTO	DVLOOP	
		RETURN
		
NEWLINE	MOVLW	b'01100'	;increment address for new line
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'00000'
		MOVWF	PORTA
		CALL	ET
		RETURN
		
PRINTT	MOVLW	b'10101'	;Print T
		MOVWF	PORTA
		CALL	ET
		MOVLW	b'10100'
		MOVWF	PORTA
		CALL	ET
		RETURN


RED1S	BSF		PORTB,2		;turns red led on
		CALL	DELAYBUZ	;calls delay of 1 sec
		BCF		PORTB,2		;turns red led off
		RETURN

GREEN1S	BSF		PORTB,3		;turns green led on
		CALL	DELAYBUZ	;calls delay of 1 sec
		BCF		PORTB,3		;turns green led off
		RETURN

BLINKGR	MOVLW	d'10'
		MOVWF	TEMP
LOOPBL	BSF		PORTB,2		;turns red led on
		CALL	DELAY120	;calls delay of 1 sec
		BCF		PORTB,2		
		BSF		PORTB,3	
		CALL	DELAY120	;calls delay of 1 sec
		BCF		PORTB,3	
		DECFSZ	TEMP,1
		GOTO	LOOPBL
		RETURN

DELAY120	CALL	DELAY40	;delay of 120ms
			CALL	DELAY40
			CALL	DELAY40
			RETURN

		END
