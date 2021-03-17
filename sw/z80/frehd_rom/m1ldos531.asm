	LISTING ON
	NEWPAGE
;*=*=*
;	M1 LDOS 5.3.1  BOOT/SYS PATCH
;*=*=*

;;
;; CONFIG/SYS needs to be created correctly for autoboot to succeed 
;;            use v1.2 ROM only.. V1.3 ROM fails to build
;;            CONFIG/SYS correctly at @4303H.. don't know why.. yet

m1ldos531:

	START_PATCH 7F00h
;*=*=*
;	routine to read a sector from HD
;	D = cylinder  E = sector
;*=*=*
m1_read_sector_DE:
			
	push	hl
	push	de
	ld		h,b				; bc used in BOOT/SYS as m1 buffer address, instead of HL
	ld		l,c

	m1_modified_read:		; HL now has buffer address, used by LDOS SYS0/SYS
	ld		c,e
	ld		e,d
	ld		d,00h			; CYLHI
	ld		b,0ch			; 
	ld		a,02h			; 
	call	hd_read_sector
	pop		de
	pop		hl
	ld		a,(4709h)
	sub		d
	ld		a,06h
	jr		z,+
	xor		a
+	and		a
	ret
	
;*=*=*
;	DCT handler, only read from HD
;*=*=*
m1_dct_read_hd
	ld	a,09h				; command READ SECTOR ?
	sub	b					; 
	jr	nz, +				; z, do the read
	push	hl
	push	de
	jr	m1_modified_read
+	xor	a					; no, return ok.
	ret

	END_PATCH

	START_PATCH 4709h
	db	0					; must force directory to 0 else reboot fails - DCT 
	END_PATCH

;4200  00           nop
;4201  fe 65        cp   65h					; 4202 is dir cyl
;4203  f3           di
;4204  31 e0 41     ld   sp,41e0h
;4207  fd 21 00 00  ld   iy,0000h
;420b  21 e4 42     ld   hl,42e4h				; clear screen
;420e  cd 9e 42     call 429eh					; display msg	
	
	
	START_PATCH 4211h		; no longer selecting floppy drive 0
	db 0,0,0,0,0
;4211  3e 01        ld   a,01h					; drive 0
;4213  32 e1 37     ld   (37e1h),a				; floppy drive select xxxx3210
	END_PATCH
 
;4216  3a 02 42     ld   a,(4202h)				; directory cylinder
;4219  57           ld   d,a                     
;421a  1e 04        ld   e,04h                  ; sector 4
;421c  01 00 51     ld   bc,5100h				; buffer to load sec 4 
;421f  cd ac 42     call 42ach					; read it !
;4222  20 70        jr   nz,4294h
;4224  3a 00 51     ld   a,(5100h)				; test if system disk
;4227  e6 10        and  10h
;4229  21 e7 42     ld   hl,42e7h				; no system msg
;422c  28 69        jr   z,4297h				; "no system" if z
;
;422e  d9           exx
;422f  2a 16 51     ld   hl,(5116h)
;4232  55           ld   d,l
;4233  7c           ld   a,h
;4234  07           rlca
;4235  07           rlca
;4236  07           rlca
;4237  e6 07        and  07h
;4239  67           ld   h,a
;423a  07           rlca
;423b  07           rlca
;423c  84           add  a,h
;423d  5f           ld   e,a
;; 	;;
;; 	;; Prepare to load SYS0/SYS
;; 	;; 
;423e  01 ff 51     ld   bc,51ffh
;4241  d9           exx
;; 	;;
;; 	;; LOAD
;; 	;; 
;4242  cd 79 42     call 4279h					; get type code
;4245  3d           dec  a                       
;4246  20 17        jr   nz,425fh                ; bypass if not type 1
;4248  cd 79 42     call 4279h                   ; get address
;424b  47           ld   b,a
;424c  cd 79 42     call 4279h					; get low-order load addr
;424f  6f           ld   l,a
;4250  05           dec  b						; adj length for this byte
;4251  cd 79 42     call 4279h					; get high-order load addr
;4254  67           ld   h,a
;4255  05           dec  b						; adj length for this byte
;4256  cd 79 42     call 4279h
;4259  77           ld   (hl),a
;425a  23           inc  hl
;425b  10 f9        djnz 4256h
;425d  18 e3        jr   4242h					 ; continue to read
;
;425f  3d           dec  a						 ; test if type 2 (TRAADR)
;4260  28 0b        jr   z,426dh                 ; ah, go if transfer addr
;4262  cd 79 42     call 4279h                   ; assume comment
;4265  47           ld   b,a                     ; get comment length
;4266  cd 79 42     call 4279h                   ; and ignore it
;4269  10 fb        djnz 4266h                   
;426b  18 d5        jr   4242h                   ; continue to read
;
;426d  cd 79 42     call 4279h					; and ignore it
;4270  cd 79 42     call 4279h					; get low-order transfer addr
;4273  6f           ld   l,a
;4274  cd 79 42     call 4279h					; get low-order transfer addr 

	START_PATCH 4277h		; patch DCT before transfer to 4e00h
	jr m1_pp2
;4277  67           ld   h,a	
	END_PATCH

	START_PATCH 427eh		; no longer selecting floppy drive 0
	db 0,0,0,0,0
;427e  3e 01        ld   a,01h					; drive 0
;4280  32 e1 37     ld   (37e1h),a				; floppy drive select xxxx3210	
;	call 42ach
	END_PATCH
;4283  cd ac 42     call 42ach					; read another sector
;4286  20 0c        jr   nz,4294h				; jump if error
;4288  c1           pop  bc
;4289  1c           inc  e						; bump sector counter
;428a  7b           ld   a,e

	START_PATCH 428bh		; now 32 sec/track
	sub 	1fh
;428b  d6 0a        sub  0ah					; last sector       [!!! 0ah = sec/track
	END_PATCH
;428d  20 02        jr   nz,4291h				; on this cylinder ?
;428f  5f           ld   e,a                    ; yes, restart at 0
;4290  14           inc  d                      ; and increment cylinder
;4291  0a           ld   a,(bc)                 ; get a byte
;4292  d9           exx                         ; exchange pointers back
;4293  c9           ret
;
;4294  21 f3 42     ld   hl,42f3h				; disk error
;4297  cd 9e 42     call 429eh					; display msg
;429a  cd 40 00     call 0040h					; input text from keyboard
;429d  76           halt
;;
;; display message
;;
;429e  e5           push hl
;429f  7e           ld   a,(hl)					; byte to display in a
;42a0  fe 03        cp   03h					; end of text?
;42a2  28 06        jr   z,42aah				; z, done
;42a4  cd 33 00     call 0033h					; dsp byte
;42a7  23           inc  hl						; get next byte of msg	
;42a8  18 f5        jr   429fh
;42aa  e1           pop  hl
;42ab  c9           ret

	START_PATCH 42ach
	call	m1_read_sector_DE
	ret

m1_pp2	
	ld 	h,a
	call	42ach	
	push	hl				; save SYS0 entry point
	ld		hl,m1_pdct		; load DCT
	ld		de,4701h
	ld		bc,0008h	
	ldir
	pop		hl				; restore entry point
	jp		(hl)			; and jump

m1_pdct	
	dw	m1_dct_read_hd
	db	0ch, 10h, 00h, 08bh, 1fh, 0e3h, 46h
	END_PATCH
	LAST_PATCH
	
;42ac  c5           push bc
;42ad  cd b4 42     call 42b4h
;42b0  e1           pop  hl
;42b1  c8           ret  z
;42b2  44           ld   b,h					; buffer address 
;42b3  4d           ld   c,l					;
;42b4  ed 53 ee 37  ld   (37eeh),de				; load cyl/sector
;42b8  21 ec 37     ld   hl,37ech				; 37ech = command register
;42bb  36 1b        ld   (hl),1bh				; send command - seek 1b 1=head load 0=no verf, 2 bits=40ms
;42bd  e3           ex   (sp),hl				; wait a bit
;42be  e3           ex   (sp),hl
;42bf  e3           ex   (sp),hl				; wait a bit longer
;42c0  e3           ex   (sp),hl
;42c1  7e           ld   a,(hl)					; get status
;42c2  0f           rrca						; busy in carry
;42c3  38 fc        jr   c,42c1h				; jp if busy
;42c5  36 88        ld   (hl),88h				; read sector command to FDC
;42c7  d5           push de
;42c8  11 ef 37     ld   de,37efh				; floppy data transfer addr in de
;42cb  e3           ex   (sp),hl				; wait a bit
;42cc  e3           ex   (sp),hl
;42cd  18 0b        jr   42dah					; data request check loop
;42cf  0f           rrca						; busy in carry
;42d0  30 0a        jr   nc,42dch				; jp if not busy, read done
;42d2  7e           ld   a,(hl)					; get status
;42d3  cb 4f        bit  1,a					; check data request
;42d5  28 f8        jr   z,42cfh				; loop until ready or sector done
;42d7  1a           ld   a,(de)					; get data byte, de = 37ef
;42d8  02           ld   (bc),a					; store in buffer
;42d9  03           inc  bc						; bump buffer pointer
;42da  18 f6        jr   42d2h					; loop back for more data
;42dc  7e           ld   a,(hl)					; get status
;42dd  e6 1c        and  1ch					; mask off non-error bits, "5ch" would fix F8 rather than FA DAM's
;42df  d1           pop  de
;42e0  c8           ret  z						; return if no error
;42e1  36 d0        ld   (hl),d0h				; give "force interrupt" command to FDC
;42e3  c9           ret
;42e4  db	01ch,01fh,03h						; tof/cls/etx
;42e7  db	17h,0e8h, 'No system',03h
;42f3  db	17h,0e8h,'Disk error',1Fh,03h
