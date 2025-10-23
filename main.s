; Jackson T, Victor N, Isaiah F, Matt C, Mason B
; Group Project Phase 3
; 10/2/25

        AREA    BitonicSortData, DATA, READWRITE
arr       DCD   6, 2, 7, 13, 3, 5, 7, 4, 10, 9, 3, 11, 12, 14, 7, 2
core1Done DCD   0          

        AREA    BitonicSortConst, DATA, READONLY
        ALIGN   2
arrLength   DCD     16
coreID      DCD     0       ; assuming CORE_ID=0, can patch if needed

        AREA    BitonicSortCode, CODE, READONLY
        EXPORT  main
        ENTRY
main
	ldr r4, =arr			; r4 = array's address
	ldr r9, =arr			; r9 = array's address; DEBUGGING
	ldr r5, =arrLength		; r5 = length of array's address
	mov r6, #1				; Loads the direction as 1 into R6 (1 will create an increasing list a 0 would create a decreasing list)	
	ldr r5, [r5]			; r5 = length of array
	
core1
	 ;Sorts second half
	eor r6, r6, #1
	mov r5, r5, lsr #1		; shift right one bit to divide a power of 2 by 2
	mov r0, #4
	mul r0, r0, r5			; Calculate bytes of halfLen
	add r4, r0, r4			; Calculate starting address of second half
		
	bl bitonicSort			; Expects r4 = Addr, r5 = AddrLen, r6 = dir
	
core0
	;Sorts first half and merges both halves
	eor r6, r6, #1
	ldr r4, =arr			; r4 = array's address
	ldr r5, =arrLength		; r5 = length of array's address
	ldr r5, [r5]			; r5 = length of array
	mov r5, r5, lsr #1		; shift right one bit to divide a power of 2 by 2
	
	bl bitonicSort			; Expects r4 = Address, r5 = AddrLength, r6 = dir
	
	;Reset for full list
	ldr r4, =arr			; r4 = array's address
	ldr r5, =arrLength		; r5 = length of array's address
	ldr r5, [r5]			; r5 = length of array
	mov r6, #1				; r6 = accending
	bl merge				; final merge
	

end  b end       ;stop program
	
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@	

merge
    push {lr}                     ; return addr
    push {r4, r5, r6, r7, r8}     ; save callee-saved regs and params
                                  ; r4 = base addr, r5 = count, r6 = dir

    cmp r5, #1
    ble mDone

    ; compute halfLen = r5 / 2 (works for power-of-two counts)
    mov r5, r5, lsr #1			  ; shift right one bit to divide a power of 2 by 2
    mov r7, #4
    mul r7, r5, r7                ; r7 = halfLen * 4 (bytes)
    add r8, r4, r7                ; r8 = start address of second half

    mov r0, r4                    ; pointer = start of first half

mLoop
    cmp r0, r8
    beq mLoopEnd
    add r1, r0, r7                ; r1 = corresponding element in second half
    bl compAndSwap                ; compares memory at [r0] and [r1] using r6 (dir)
    add r0, r0, #4
    b mLoop

mLoopEnd
     ;merge first half (r4 already points to first half, r5=halfLen, r6=dir)
    bl merge

     ;merge second half (set r4 to second-half base)
    mov r4, r8
    bl merge

mDone
    pop {r4, r5, r6, r7, r8}
    pop {lr}
    bx lr


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;	 The addresses of the two values that are being compared are stored in r0 and r1
;	 The direction of the sorting is stored in r6 (1 for increasing and 0 for decreasing)
compAndSwap
	push {lr}
	push {r2, r3}					; Store the original values of r2 and r3
	LDR r2, [r0]					; Load the first value being compared into r2
	LDR r3, [r1]					; Load the second value being compared into r3
	cmp r6, #1						; Detirmine if the list being sorted is increasing or decreasing
	beq increasing
	blt decreasing
	
increasing
	cmp r2, r3						; If the first element is greater than the second swap. Otherwise exit
	bgt swap
	b cDone
	
decreasing
	cmp r2, r3						; If the first element is less than the second swap. Otherwise exit
	blt swap
	b cDone

swap
	str r2, [r1]					; Swap by storing the fist element in the second's address
	str r3, [r0]					; And store the second element in the first's address

cDone
	pop {r2, r3}					; Restore r2 and r3
	pop {lr}						; Restore return address
	bx lr

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

bitonicSort
    push {lr}
    cmp r5, #1                     ; If the partition length <= 1, done
    ble done
    push {r4, r5, r6}              ; store params

    mov r5, r5, lsr #1		       ; shift right one bit to divide a power of 2 by 2
	mov r0, r5					   ; store halfLen
	
    bl bitonicSort                 ; sort first half (r4=start, r5=halfLen, r6=dir)

   ;  prepare second half: compute byte offset from halfLen in r0 again
    mov r0, r5                     ; r0 = halfLen
    mov r1, #4
    mul r0, r0, r1                 ; r0 = halfLen * 4 (bytes)
    add r4, r4, r0                 ; r4 = address of second half

    eor r6, r6, #1                 ; toggle direction for second half
    bl bitonicSort                 ; sort second half (r4=second half addr, r5=halfLen, r6=opposite dir)

   ;  restore full-list params and merge
    pop {r4, r5, r6}
    bl merge

done
    pop {lr}
    bx lr

	
	END