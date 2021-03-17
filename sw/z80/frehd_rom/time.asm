;;;
;;; TIME
;;;
;;  reference : Apply Year 2000 date patches from 
;;  http://www.trs-80.org/ldos-and-ls-dos-2012-and-beyond-a-solution/
;;  by Matthew Reed (applied automatically to virtual disks using trstools.exe WIN32 only)
;;
;;  The time patch below is for LSDOS_631 (dean.bear@gmail.com) It prevents sys0/sys zeroing the addresses
;;  used to store the time, when the cmd file is loaded from disk. 
;;  The one time patch allows the FreHD RTC to load the time bytes before sys0/sys is loaded.
;; 
;;  *** Start of Patch ***
;. Patch for LS-DOS 6.3.1 
;. Preserve the current time when rebooting
;. Designed for the FREHD real time clock   
;. Created by Dean Bear - dean.bear@gmail.com 03/13/2014
;. PATCH SYS0/SYS.SYSTEM6 LS6TIME
;D00,39=16
;F00,39=1D
;D00,50=01 05 30 00
;F00,50=00 00 00 00
;. EOP
;; *** end of patch

NEWDOS_VALID_BYTE  equ 0a5h
;; Model 1
NEWDOS_VALID_ADDR  equ 43abh
NEWDOS_MONTH       equ 43b1h
NEWDOS_DAY         equ 43b0h
NEWDOS_YEAR        equ 43afh
NEWDOS_HOUR        equ 43aeh
NEWDOS_MIN         equ 43adh
NEWDOS_SEC         equ 43ach
;; LDOS
LDOS_MONTH         equ 4306h
LDOS_DAY           equ 4307h
LDOS_YEAR          equ 4466h
LDOS_SEC           equ 4041h
;; DOSPLUS3 M1
DOSPLUS1_DATE_CMD_SET equ 4315h
DOSPLUS1_SEC        equ 4041h
DOSPLUS1_MIN        equ 4042h
DOSPLUS1_HOUR       equ 4043h
DOSPLUS1_YEAR       equ 4044h
DOSPLUS1_DAY        equ 4045h
DOSPLUS1_MONTH      equ 4046h

;; Model 3
NEWDOS3_VALID_ADDR equ 42cbh
NEWDOS3_MONTH      equ 42d1h
NEWDOS3_DAY        equ 42d0h
NEWDOS3_YEAR       equ 42cfh
NEWDOS3_HOUR       equ 42ceh
NEWDOS3_MIN        equ 42cdh
NEWDOS3_SEC        equ 42cch
;; LDOS 3
LDOS3_MONTH        equ 442fh
LDOS3_DAY          equ 4457h
LDOS3_YEAR         equ 4413h
LDOS3_SEC          equ 4217h
LDOS3_MIN          equ 4218h
LDOS3_HOUR         equ 4219h
;; DOSPLUS3 M3
DOSPLUS3_DATE_CMD_SET equ 42bbh
DOSPLUS3_SEC        equ 4217h
DOSPLUS3_MIN        equ 4218h
DOSPLUS3_HOUR       equ 4219h
DOSPLUS3_YEAR       equ 421ah
DOSPLUS3_DAY        equ 421bh
DOSPLUS3_MONTH      equ 421ch
;; Model 4
;; LSDOS 6
LDOS4_MONTH        equ 0035h
LDOS4_DAY          equ 0034h
LDOS4_YEAR         equ 0033h
LDOS4_SEC          equ 002dh
LDOS4_MIN          equ 002eh
LDOS4_HOUR         equ 002fh
;; DOSPLUS_IV M4
DOSPLUS_IV_SEC        equ 00a4h
DOSPLUS_IV_MIN        equ 00a5h
DOSPLUS_IV_HOUR       equ 00a6h
DOSPLUS_IV_YEAR       equ 00a7h
DOSPLUS_IV_DAY        equ 00a8h
DOSPLUS_IV_MONTH      equ 00a9h

hack_time:
	call	get_datetime
	ld	a,(ROM_MODEL)
	cp	ROM_MODEL_1
	jr	nz,+
	call	time_newdos_m1		; model 1
	call	time_ldos5_m1
	call    time_dosplus_m1
	ret
+	call	time_ldos5_m3
	call	time_newdos_m3		; model 3, 4, 4P
	call    time_dosplus_m3

	ld	a,(ROM_MODEL)
	cp	ROM_MODEL_4
	ret	c
	call	time_ldos6		; model 4, 4P
	call    time_dosplus_m4
	ret
	
get_datetime:
	ld	a,GET_TIME
	out	(COMMAND2),a
	call	wait
	ld	hl,BUF1
	ld	bc,6<<8|DATA2
	inir
	ret
	
time_newdos_m1:
	ld	hl,NEWDOS_VALID_ADDR
	ld	de,NEWDOS_SEC
	jr	+

time_newdos_m3:	
	ld	hl,NEWDOS3_VALID_ADDR
	ld	de,NEWDOS3_SEC
+	ld	(hl),NEWDOS_VALID_BYTE
	ld	hl,BUF1+FREHD_SEC
	ld	bc,6
	ldir
	ret
	
time_dosplus_m1:	
	ld	de,DOSPLUS1_SEC
	ld	hl,BUF1+FREHD_SEC
	ld	bc,6
	ldir
	ld	hl,DOSPLUS1_YEAR
	ld	a,(hl)
	add	a,64h 	;convert RTC year to DOSPLUS year
    ld  (hl),a
	xor a
	ld (DOSPLUS1_DATE_CMD_SET),a
	ret	
	
time_dosplus_m3:	
	ld	de,DOSPLUS3_SEC
	ld	hl,BUF1+FREHD_SEC
	ld	bc,6
	ldir
	ld	hl,DOSPLUS3_YEAR
	ld	a,(hl)
	add	a,64h 	;convert RTC year to DOSPLUS year
    ld  (hl),a
	xor a
	ld (DOSPLUS3_DATE_CMD_SET),a
	ret
	
time_dosplus_m4:	
	ld	a,2			; map RAM
	out	(84h),a
	ld	de,DOSPLUS_IV_SEC
	ld	hl,BUF1+FREHD_SEC
	ld	bc,6
	ldir
	ld	hl,DOSPLUS_IV_YEAR
	ld	a,(hl)
	add	a,64h 	;convert RTC year to DOSPLUS year
    ld  (hl),a
	xor	a
	out	(84h),a			; unmap ROM
	ret
	
time_ldos5_m1:
	ld	hl,BUF1+FREHD_YEAR	; year
	ld	de,LDOS_YEAR
	ld	a,(hl)
	;sub	80
	add	 a,20		; 1980+20+current year
	ld	(de),a
	inc	hl			; day
	ld	de,LDOS_DAY
	ld	a,(hl)
	ld	(de),a
	inc	hl			; month
	ld	de,LDOS_MONTH
	ld	a,(hl)
	xor	50h
	ld	(de),a
	
	ld	hl,BUF1+FREHD_SEC 
	ld	de,LDOS_SEC
	ld	bc,3		; sec:min:hour
	ldir
	ret

time_ldos5_m3:	
	ld	hl,BUF1+FREHD_YEAR	; year
	ld	de,LDOS3_YEAR
	ld	a,(hl)
	;sub	80
	add	 a,20		; 1980+20+current year
	ld	(de),a
	inc	hl			; day
	ld	de,LDOS3_DAY
	ld	a,(hl)
	ld	(de),a
	inc	hl			; month
	ld	de,LDOS3_MONTH
	ld	a,(hl)
	xor	50h
	ld	(de),a
	
	ld	hl,BUF1+FREHD_SEC 
	ld	de,LDOS3_SEC
	ld	bc,3		; sec:min:hour
	ldir
	ret

time_ldos6:
	ld	a,2			; map RAM
	out	(84h),a
	ld	hl,BUF1+FREHD_YEAR
	ld	de,LDOS4_YEAR
	ld	bc,3	
	ldir
	ld	hl,BUF1+FREHD_SEC 
	ld	de,LDOS4_SEC
	ld	bc,3		; sec:min:hour
	ldir
	xor	a
	out	(84h),a			; unmap ROM
	ret
