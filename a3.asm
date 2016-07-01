#define LCD_LIBONLY
.include "lcd.asm"

.cseg

	sei	
	call lcd_init
	call str_cpy
	call init_pointers
lp:	
	call lcd_clr
	call display_lines
	call fill_lines
	call display_lines
	call move_pointers
	call delay
	jmp lp

move_pointers:
	push XH
	push XL
	push YH
	push YL
	push r16
	push r17
	push r18
	;incrementing first pointer
	ldi XH, high(l1ptr)
	ldi XL, low(l1ptr)
	ld YH, X+ ;high byte
	ld YL, X  ;low byte
	ldi XH, high(l1ptr)
	ldi XL, low(l1ptr)
	ld r18, Y
	cpi r18, 0x00
	brne dont_wrap1
	ldi r16, high(msg1)
	ldi r17, low(msg1)
	st X+, r16
	st X, r17
	jmp inc_line2
dont_wrap1:
	mov r17, YL
	mov r16, YH
	inc r17
	brne skip1
	inc r16
skip1:
	st X+, r16
	st X, r17
	;incrementing second pointer
inc_line2:
	ldi XH, high(l2ptr)
	ldi XL, low(l2ptr)
	ld YH, X+ ;high byte
	ld YL, X  ;low byte
	ldi XH, high(l2ptr)
	ldi XL, low(l2ptr)
	ld r18, Y
	cpi r18, 0x00
	brne dont_wrap2
	ldi r16, high(msg2)
	ldi r17, low(msg2)
	st X+, r16
	st X, r17
	jmp do_pop
dont_wrap2:
	mov r17, YL
	mov r16, YH
	inc r17
	brne skip2
	inc r16
skip2:
	st X+, r16
	st X, r17
do_pop:
	pop r18
	pop r17
	pop r16
	pop YL
	pop YH
	pop XL
	pop XH
	ret

delay:
	push r20
	push r21
	push r22
	ldi r20, 0x25
del1:	nop
		ldi r21,0xFF
del2:	nop
		ldi r22, 0xFF
del3:	nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1
		pop r22
		pop r21
		pop r20	
		ret

display_lines:
	;saved regs
	push r16

	;line 1 xy
	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16
	;message 1 display
	ldi r16, high(line1)
	push r16
	ldi r16, low(line1)
	push r16
	call lcd_puts
	pop r16
	pop r16

	;line 2 xy
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16
	;message 2 display
	ldi r16, high(line2)
	push r16
	ldi r16, low(line2)
	push r16
	call lcd_puts
	pop r16
	pop r16

	;popping saved regs
	pop r16
	ret
;as loading in the values check each one and if zero then do the wrap there
fill_lines:
	;saved regs
	push XH
	push XL
	push YH
	push YL
	push r16
	push r17; counter
	;line one
	ldi XH, high(l1ptr)
	ldi XL, low(l1ptr)
	ld YH, X+
	ld YL, X
	ldi XH, high(line1)
	ldi XL, low(line1)
	ldi r17, 0x10
load1:
	cpi r17, 0x00
	breq add_null1
	dec r17
	ld r16, Y+
	cpi r16, 0x00
	breq wrap1
	st X+, r16
	jmp load1
wrap1:
	ldi YH, high(msg1)
	ldi YL, low(msg1)
	ld r16, Y+
	st X+, r16
	jmp load1
add_null1:
	ldi r16, 0x00
	st X, r16
	;line 2
	ldi XH, high(l2ptr)
	ldi XL, low(l2ptr)
	ld YH, X+
	ld YL, X
	ldi XH, high(line2)
	ldi XL, low(line2)
	ldi r17, 0x10
load2:
	cpi r17, 0x00
	breq add_null2
	dec r17
	ld r16, Y+
	cpi r16, 0x00
	breq wrap2
	st X+, r16
	jmp load2
wrap2:
	ldi YH, high(msg2)
	ldi YL, low(msg2)
	ld r16, Y+
	st X+, r16
	jmp load2
add_null2:
	ldi r16, 0x00
	st X, r16
	pop r17
	pop r16
	pop YL
	pop YH
	pop XL
	pop XH
	ret

init_pointers:
	;saved regs
	push XH
	push XL
	push r16
	;line one pointer
	ldi XH, high(l1ptr)
	ldi XL, low(l1ptr)
	;storing in big endian
	ldi r16, high(msg1)
	st X+, r16
	ldi r16, low(msg1)
	st X, r16
	;line 2 pointer
	ldi XH, high(l2ptr)
	ldi XL, low(l2ptr)
	ldi r16, high(msg2)
	st X+, r16
	ldi r16, low(msg2)
	st X, r16
	;pooping saved regs
	pop r16
	pop XL
	pop XL
	ret

str_cpy:
	;saved reg
	push r16
	;line one, pushing on destination first then source
	ldi r16, high(msg1)		
	push r16
	ldi r16, low(msg1)
	push r16
	ldi r16, high(msg1_p << 1) 
	push r16
	ldi r16, low(msg1_p << 1)
	push r16
	call str_init			
	pop r16					;
	pop r16
	pop r16
	pop r16
	;line 2, pusing on destination first then source
	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	ldi r16, high(msg2_p << 1)
	push r16
	ldi r16, low(msg2_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16
	;popping saved reg
	pop r16
	ret

msg1_p:	.db "This is whats being put on line 1 ", 0	
msg2_p: .db "wubbalubbadubdub thats a thing i say now remember i said it at the end of last episode ", 0

.dseg
msg1: .byte 200
msg2: .byte 200
line1: .byte 17
line2: .byte 17
l1ptr: .byte 2
l2ptr: .byte 2
