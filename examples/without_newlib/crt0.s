	.global _start
	.org 0x100
reset:
	l.j	_start
	l.nop

	.org 0x2000

_start:
	l.andi	r0, r0,	0
	l.movhi	r1, hi(_stack)
	l.ori	r1, r1, lo(_start)
	l.or	r2, r0, r1
	l.jal	main
	l.nop

end:	l.j	end
	l.nop
	
