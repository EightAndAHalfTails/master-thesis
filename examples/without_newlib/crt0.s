	.global _start
	.org 0x100
reset:
	l.j	_start
	l.nop

	.org 0x300

dpgflt: # add pte

	.org 0x900
	
dtlbms:	# find pte and add to tlb
	l.mfspr r13, r0, 0x20 		# exception pc reg -> r13
	l.mfspr r15, r0, 0x30 		# exception ea reg -> r15
	l.ori	r17, r0, 0x2000		# table base pointer -> r17
	
	l.andi	r19, r15, 0xfff		# mask upper bytes of ea
	l.add	r19, r19, r17		# offset into page table
	l.lwz	r19, 0(r15)		# page table entry -> r19

	l.andi	r21, r15, 0x3f000	# extract bits 18-13 of ea
	l.srli	r21, r21, 12		# r21 <- tlb reg num

	# dtlbw0mrX[31:12] <- ea[31:19]
	l.andi	r23, r15, 0xfff00000	# extract bits 31:19 of ea
	l.srli	r23, r23, 7		# move to vpn position
	l.ori	r23, r23, 1		# set valid bit
	l.mtspr	r21, r23, 0x0a00	# move to tlb match reg

	# dtlbw0trX[31:12] <- pte[31:10]
	l.andi	r23, r15, 0xfffffb00	# extract bits 31:10 of pte
	l.slli	r23, r23, 2		# move to ppn location
	l.andi	r25, r15, 0x3f		# extract bits 5:0 of pte
	l.or	r23, r23, r15		# add to translate reg
	l.nop # look up protection bits
	l.ori	r23, r23, 0x3b0		# add protection bits to reg
	l.mtspr	r21, r23, 0x0a80	# move to tlb translate reg

	# dtlbwYtrX:
	# 31:12 PPN
	# 11:10 reserved
	# 9 supervisor write enable
	# 8 supervisor read enable
	# 7 user write enable
	# 6 user read enable
	# 5 dirty
	# 4 accessed
	# 3 weakly-ordered
	# 2 write-back
	# 1 cache inhibit
	# 0 cache coherency
	
	l.rfe				# return from exception
	
	.org 0x2000
	.org 0x3000
_start:
	l.andi	r0, r0,	0
	l.movhi	r1, hi(_stack)
	l.ori	r1, r1, lo(_start)
	l.or	r2, r0, r1

	# add base pointer to tlb
	l.ori	r13, r0, 0x02000001 	# vpn = 0x2000
	l.mtspr	r0, r13, 0x0a00		#  put in w0mr0
	l.ori	r13, r0, 0x080003b1 	# ppn = 0x2000
	l.mtspr	r0, r13, 0x0a80		#  put in w0tr0
	
	# place test value in memory
	l.movhi	r13, 0xbabe
	l.ori	r13, r13, 0xface
	l.sw	0x4000(r0), r13		# mem(0x04000) <- 0xbabeface
		
	# put pte in page table
	l.ori	r13, r0, 0x04000001
	l.sw	0x2000(r0), r13		# pt[0] = 0x0400 0001
	
	# activate mmu
	l.mfspr	r13, r0, 0x00000011	# r13 <- sr
	l.ori	r13, r13, 0x20		# enable bit 5 (dmmu)
	l.mtspr	r0, r13, 0x00000011	# r13 -> sr
	
	# do memory access
	l.lwz	r15, 0x4000(r0)

	l.j	end
#	l.jal	main		
	l.nop

end:	l.j	end
	l.nop
	
