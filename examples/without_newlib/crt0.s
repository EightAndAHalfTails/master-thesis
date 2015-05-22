	.global _start
	.org 0x100
reset:
	l.j	_start
	l.nop

	.org 0x300

dpgflt: # add pte
	l.j	dpgflt
	l.nop
	l.rfe

	.org 0x900
	
dtlbms:	# find pte and add to tlb
	l.mfspr r15, r0, 0x30 		# exception ea reg -> r15
	l.ori	r17, r0, 0x2000		# table base pointer -> r17
	
	l.srli	r19, r15, 11		# get vpn:set from ea (>>13 then <<2 to use as pointer)
	l.add	r19, r19, r17		# offset into page table
	l.lwz	r19, 0(r19)		# page table entry -> r19

	l.movhi	r13, 0x0003
	l.ori	r13, r13, 0xf000
	l.and	r21, r15, r13		# extract bits 18-13 of ea
	l.srli	r21, r21, 13		# r21 <- tlb set reg num

	# dtlbw0mrX[31:12] <- ea[31:19]
	l.movhi	r13, 0xfff0
	l.and	r23, r15, r13		# extract bits 31:19 of ea
	l.srli	r23, r23, 7		# move to vpn position
	l.ori	r23, r23, 1		# set valid bit
	l.mtspr	r21, r23, 0x0a00	# move to tlb match reg

	# dtlbw0trX[31:12] <- pte[31:10]
	l.movhi	r13, 0xffff
	l.ori	r13, r13, 0xfc00
	l.and	r23, r19, r13		# extract bits 31:10 of pte
	l.slli	r23, r23, 3		# move to ppn location
	l.andi	r25, r19, 0x003f	# extract bits 5:0 of pte
	l.or	r23, r23, r25		# add to translate reg
	# todo: look up protection bits
	l.ori	r23, r23, 0x03b0	# add protection bits to reg
	l.mtspr	r21, r23, 0x0a80	# move to tlb translate reg
	
	l.rfe				# return from exception
	
	.org 0x2000
	.org 0x3000
_start:
	l.andi	r0, r0,	0
	l.movhi	r1, hi(_stack)
	l.ori	r1, r1, lo(_start)
	l.or	r2, r0, r1

	# add base pointer to tlb
	#l.movhi r13, 0x0000		# ea = 0x2000 -> vpn = 0
	l.ori	r13, r0, 0x0001 	# reg = 0x0000 0001
	l.mtspr	r0, r13, 0x0a01		#  put in w0mr1
	l.movhi	r13, 0x0000		# pa = 0x2000 -> ppn = 0
	l.ori	r13, r13, 0x03b0 	# reg = 0x0000 03b0
	l.mtspr	r0, r13, 0x0a81		#  put in w0tr1
	
	# place test value in memory
	l.movhi	r13, 0xbabe
	l.ori	r13, r13, 0xface
	l.sw	0x4000(r0), r13		# mem(0x04000) <- 0xbabeface
		
	# put pte in page table
	#l.movhi r13, 0x0000		# vp 0 -> pp 0
	l.ori	r13, r0, 0x0200		# 0x0000 0200
	l.sw	0x2008(r0), r13		# pt[2] = 0x0000 0200
	
	# activate mmu
	l.mfspr	r13, r0, 0x0011		# r13 <- sr
	l.ori	r13, r13, 0x20		# enable bit 5 (dmmu)
	l.mtspr	r0, r13, 0x0011		# r13 -> sr
	
	# do memory access
	l.lwz	r15, 0x4000(r0)

	l.j	end
#	l.jal	main		
	l.nop

end:	l.j	end
	l.nop
	
