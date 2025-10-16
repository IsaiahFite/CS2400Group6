@ Jackson T, Victor N, Isaiah F, Matt C, Mason B
@ Group Project Phase 3
@ 10/2/25

    .equ CORE_ID, 0        @ core0 build
    ;.equ CORE_ID, 1       @ core1 build

.section .data
arr:        .word 6, 2, 7, 13, 3, 5, 7, 4, 10, 9, 3, 11, 12, 14, 7, 2
core1Done:  .word 0

.section .rodata
    .align 2
coreID:     .word CORE_ID
arrLength:  .word 16

.text
.global main
main:
    ldr r4, =arr                  @ r4 = array base
    ldr r9, =arr                  @ debug scratch
    ldr r5, =arrLength            @ r5 = &len
    ldr r5, [r5]                  @ r5 = len
    mov r6, #1                    @ dir = 1 (ascending)

    ldr r7, =coreID
    ldr r7, [r7]
    cmp r7, #1
    beq core1

core0:
    @ Sort first half
    mov r5, r5, lsr #1            @ halfLen
    mov r0, r4                    @ bitonicSort(base=r4, len=r5, dir=r6)
    mov r1, r5
    mov r2, r6
    bl  bitonicSort

waitForCore1:
    ldr r7, =core1Done
    ldr r7, [r7]
    cmp r7, #1
    beq finalMerge
    b   waitForCore1

core1:
    @ Sort second half
    mov r5, r5, lsr #1            @ halfLen
    mov r0, #4
    mul r0, r0, r5
    add r4, r0, r4                @ r4 = second-half base
    mov r0, r4                    @ bitonicSort(base=r4, len=r5, dir=r6)
    mov r1, r5
    mov r2, r6
    bl  bitonicSort

core1FinishSort:
    ldr r7, =core1Done
    mov r8, #1
    str r8, [r7]                  @ signal core0
    b   core1FinishSort           @ park core1

finalMerge:
    @ Reset for full list and final merge
    ldr r4, =arr
    ldr r5, =arrLength
    ldr r5, [r5]
    mov r6, #1
    mov r0, r4                    @ merge(base=r4, len=r5, dir=r6)
    mov r1, r5
    mov r2, r6
    bl  merge

end:
    b   end

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ merge(base,len,dir): r0=base, r1=len, r2=dir
merge:
    push {lr}
    push {r4, r5, r6, r7, r8}

    mov  r4, r0                   @ base
    mov  r5, r1                   @ len
    mov  r6, r2                   @ dir

    cmp  r5, #1
    ble  mDone

    @ halfLen (barrel shifter)
    mov  r5, r5, lsr #1           @ r5 = halfLen

    mov  r7, #4
    mul  r7, r5, r7               @ r7 = halfLen * 4
    add  r8, r4, r7               @ r8 = second-half base

    mov  r0, r4                   @ cur = base

mLoop:
    cmp  r0, r8
    beq  mLoopEnd
    add  r1, r0, r7               @ mate = cur + bytes
    mov  r2, r6                   @ dir
    bl   compAndSwap
    add  r0, r0, #4
    b    mLoop

mLoopEnd:
    @ merge first half
    mov  r0, r4
    mov  r1, r5
    mov  r2, r6
    bl   merge

    @ merge second half
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
    push {r3, r12}

    ldr  r3,  [r0]                @ a
    ldr  r12, [r1]                @ b
    cmp  r2, #1
    beq  increasing

    @ decreasing: swap if a < b
    cmp  r3, r12
    blt  doSwap
    b    cDone

increasing:
    @ increasing: swap if a > b
    cmp  r3, r12
    bgt  doSwap
    b    cDone

doSwap:
    str  r3,  [r1]
    str  r12, [r0]

cDone:
    pop  {r3, r12}
    pop  {lr}
    bx   lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ bitonicSort(base,len,dir): r0=addr, r1=len, r2=dir
bitonicSort:
    push {lr}
    push {r4, r5, r6}

    mov  r4, r0                   @ base
    mov  r5, r1                   @ len
    mov  r6, r2                   @ dir

    cmp  r5, #1
    ble  bsDone

    @ halfLen (barrel shifter)
    mov  r5, r5, lsr #1           @ r5 = halfLen
    mov  r0, r5                   @ (comment context preserved)

    @ sort first half
    mov  r0, r4
    mov  r1, r5
    mov  r2, r6
    bl   bitonicSort

    @ second-half base = base + 4*halfLen
    mov  r0, r5
    mov  r1, #4
    mul  r0, r0, r1
    add  r4, r4, r0

    eor  r6, r6, #1               @ toggle dir for second half

    @ sort second half
    mov  r0, r4
    mov  r1, r5
    mov  r2, r6
    bl   bitonicSort

    @ merge full range
    pop  {r4, r5, r6}             @ restore full base/len/dir
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
