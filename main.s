@ Jackson T, Victor N, Isaiah F, Matt C, Mason B
@ Group Project Phase 3
@ 9/9/25

.section       .data
arr:      .word   6, 2, 7, 13, 3, 5, 7, 4, 10, 9, 3, 11, 12, 14, 7, 2

.section       .rodata
arrLength:   .word   16

.text
.global main
main:
    ldr r4, =arr                  @ r4 = array's address
    ldr r9, =arr                  @ r9 = array's address; debugging
    ldr r5, =arrLength            @ r5 = &length
    ldr r5, [r5]                  @ r5 = length of array
    mov r6, #1                    @ dir = 1 (ascending)

    @ bitonicSort(base=r4, len=r5, dir=r6)  --- pass via r0..r2
    mov r0, r4
    mov r1, r5
    mov r2, r6
    bl  bitonicSort

    @ Debugging
    ldr  r4, =arr                 @ Loads arr's immediate address onto R4
    ldmia r4, {r0-r3}             @ Loads the first 4 list values into R0-R3

end: b end                        @ stop program

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ merge(base,len,dir): r0=base, r1=len, r2=dir
merge:
    push {lr}                         @ return addr
    push {r4, r5, r6, r7, r8}         @ save locals/temps

    @ Map incoming params to original locals (keep body unchanged)
    mov  r4, r0                       @ base
    mov  r5, r1                       @ len
    mov  r6, r2                       @ dir

    cmp  r5, #1
    ble  mDone

    @ compute halfLen = len / 2  (BARREL SHIFTER REPLACEMENT)
    mov  r5, r5, lsr #1               @ r5 = halfLen

    mov  r7, #4
    mul  r7, r5, r7                   @ r7 = halfLen * 4 (bytes)
    add  r8, r4, r7                   @ r8 = start address of second half

    mov  r0, r4                       @ r0 = pointer = start of first half

mLoop:
    cmp  r0, r8
    beq  mLoopEnd
    add  r1, r0, r7                   @ r1 = mate in second half
    mov  r2, r6                       @ r2 = dir
    bl   compAndSwap                  @ compAndSwap(ptrA=r0, ptrB=r1, dir=r2)
    add  r0, r0, #4
    b    mLoop

mLoopEnd:
    @ merge first half: merge(base=r4, len=halfLen, dir=r6)
    mov  r0, r4
    mov  r1, r5
    mov  r2, r6
    bl   merge

    @ merge second half: merge(base=r8, len=halfLen, dir=r6)
    mov  r0, r8
    mov  r1, r5
    mov  r2, r6
    bl   merge

mDone:
    pop  {r4, r5, r6, r7, r8}
    pop  {lr}
    bx   lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ compAndSwap(ptrA, ptrB, dir): r0=ptrA, r1=ptrB, r2=dir
compAndSwap:
    push {lr}
    push {r3, r12}                    @ temporaries

    ldr  r3,  [r0]                    @ a
    ldr  r12, [r1]                    @ b
    cmp  r2, #1                       @ dir? (1=increasing)
    beq  increasing

    @ decreasing: swap if a < b
    cmp  r3, r12
    blt  swap
    b    cDone

increasing:
    @ increasing: swap if a > b
    cmp  r3, r12
    bgt  swap
    b    cDone

swap:
    str  r3,  [r1]                    @ write a into B
    str  r12, [r0]                    @ write b into A

cDone:
    pop  {r3, r12}
    pop  {lr}
    bx   lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ bitonicSort(base,len,dir): r0=addr, r1=len, r2=dir
bitonicSort:
    push {lr}
    push {r4, r5, r6}                 @ save locals

    @ Map incoming params to original locals
    mov  r4, r0                       @ base
    mov  r5, r1                       @ len
    mov  r6, r2                       @ dir

    cmp  r5, #1
    ble  bsDone

    @ r5 := halfLen for first half (BARREL SHIFTER REPLACEMENT)
    mov  r5, r5, lsr #1               @ r5 = halfLen
    mov  r0, r5                       @ (kept original comment context)

    @ sort first half: bitonicSort(base=r4, len=r5, dir=r6)
    mov  r0, r4
    mov  r1, r5
    mov  r2, r6
    bl   bitonicSort

    @ prepare second half: base += 4*halfLen
    mov  r0, r5
    mov  r1, #4
    mul  r0, r0, r1                   @ bytes
    add  r4, r4, r0                   @ r4 = second-half base

    eor  r6, r6, #1                   @ toggle dir for second half

    @ sort second half: bitonicSort(base=r4, len=r5, dir=r6)
    mov  r0, r4
    mov  r1, r5
    mov  r2, r6
    bl   bitonicSort

    @ merge full: merge(base=?, len=?, dir=?)
    @ restore full-list params and merge
    pop  {r4, r5, r6}                 @ restore full base/len/dir
    mov  r0, r4
    mov  r1, r5
    mov  r2, r6
    bl   merge

    pop  {lr}
    bx   lr

bsDone:
    pop  {r4, r5, r6}
    pop  {lr}
    bx   lr
