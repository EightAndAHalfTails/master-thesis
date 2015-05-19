	.global _start
	.org 0x100
reset:
	l.j	_start
	l.nop

	.org 0x300

dpgflt: // add pte
	

	.org 0x900
	
dtlbms:	// find pte and add to tlb
	l.mfspr r13, r0, 0x20 		// exception pc reg -> r13
	l.mfspr r15, r0, 0x30 		// exception ea reg -> r15
	l.ori	r17, r0, 0x2000		// table base pointer -> r17
	
	l.andi	r15, r15, 0xfff		// mask upper bytes of ea
	l.addi	r15, r15, 0x2000	// offset into page table
	l.lwa				// page table entry -> r19
	
	l.rfe				// return from exception
	
	.org 0x2000
	.org 0x3000
_start:
	l.andi	r0, r0,	0
	l.movhi	r1, hi(_stack)
	l.ori	r1, r1, lo(_start)
	l.or	r2, r0, r1
	l.jal	main
	l.nop

end:	l.j	end
	l.nop
	
