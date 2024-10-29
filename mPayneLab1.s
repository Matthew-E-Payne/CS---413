.equ READERROR, 0 @ Used to check for scanf read error.

.global main
main:
    LDR r4, =array1        @ Load address of array1 into r4
    LDR r5, =array2        @ Load address of array2 into r5
    LDR r6, =array3        @ Load address of array3 into r6

    MOV r7, #10            @ Define loop counter into r7

addArrLoop:
    LDR r0, [r4], #4       @ Load array1[i] into r0
    LDR r1, [r5], #4       @ Load array2[i] into r1
    ADD r2, r0, r1         @ Store array1[i] + array2[i] into r2
    STR r2, [r6], #4       @ Base index of array3 gets r2
    SUBS r7, r7, #1        @ i -= 1
    BNE addArrLoop         @ Break if loop counter is 0

    LDR r4, =array1        @ Load array1 into r4 for printing
    MOV r1, #1             @ Pass which array is being printed (this is just for strPrintArr)
    BL printArr

    LDR r4, =array2
    MOV r1, #2
    BL printArr

    LDR r4, =array3
    MOV r1, #3
    BL printArr

    @ Get user input
    LDR r0, =strInputPrompt
    BL printf               @ Print input prompt
    LDR r0, =numInputPattern
    LDR r1, =userInput      @ Store user input map into r1
    BL scanf                @ Read user input

    LDR r0, =userInput      @ Load the user input into r0
    LDRB r0, [r0]
    LDR r4, =array3

    CMP r0, #48             @ if input == '0' (code for 0 is 48)
    BEQ printZeros

    CMP r0, #112            @ if input == 'p' (code for p is 112)
    BEQ printPositives

    CMP r0, #110            @ if input == 'n' (code for n is 110)
    BEQ printNegatives

    LDR r0, =invalidInput
    BL printf

    B main

printZeros:
    LDR r0, =strPrintZeros
    BL printf

    LDR r4, =array3      @ Load base address of array3
    MOV r7, #10          @ Sets value to compare i to
    MOV r8, #0           @ i = 0

printZerosLoop:
    LDR r0, [r4], #4     @ Load the current element of array3 into r0, auto-increment r4
    CMP r0, #0
    BNE skipPrint        @ arr[i] != 0, skip printing

    LDR r0, =printInt    @ Load format string
    BL printf

skipPrint:
    ADDS r8, r8, #1      @ i += 1
    CMP r8, #10          @ compare i to array length
    BNE printZerosLoop   @ Break if i equals array length

    B exit

printPositives:
    LDR r0, =strPrintPositives
    BL printf

    LDR r4, =array3      @ Load base address of array3
    MOV r7, #10          @ Set values to compare i to
    MOV r8, #0           @ i = 0

printPositivesLoop:
    LDR r0, [r4], #4     @ Load the current element of array3 into r0, auto-increment r4
    CMP r0, #0
    BLE skipPrintPos     @ if (arr[i] >= 0) skip printing

    MOV r1, r0
    LDR r0, =printInt    @ Load format string
    BL printf            @ Print arr[i]

skipPrintPos:
    ADDS r8, r8, #1      @ i += 1
    CMP r8, #10          @ Compare i to array length
    BNE printPositivesLoop

    B exit


printNegatives:
    LDR r0, =strPrintNegatives
    BL printf

    LDR r4, =array3      @ Load base address of array3
    MOV r7, #10          @ Set value to compare i to
    MOV r8, #0           @ i = 0

printNegativesLoop:
    LDR r0, [r4], #4     @ Load the current element of array3 into r0, auto-increment r4
    CMP r0, #0
    BGE skipPrintNeg     @ if (arr[i] <= 0) skip printing

    MOV r1, r0
    LDR r0, =printInt    @ Load format string
    BL printf            @ Print arr[i]

skipPrintNeg:
    ADDS r8, r8, #1      @ i += 1
    CMP r8, #10          @ Compare i to array length
    BNE printNegativesLoop

    B exit






@ Function to print an array that is passed into r4
printArr:
    PUSH {lr}              @ Push lr as we are about to call another BL
    MOV r7, #10            @ Define loop counter into r7
    MOV r8, #0             @ Define index counter

    LDR r0, =strPrintArr
    BL printf
printArrLoop:
    MOV r1, r8
    LDR r0, =strOutputNum
    BL printf

    LDR r1, [r4], #4       @ Load array[i] into r1
    LDR r0, =printInt
    BL printf              @ Call printf to print array[i]

    ADDS r8, r8, #1        @ i += 1
    CMP r8, #10            @ Set flags to check if loop index = arrayLength
    BNE printArrLoop       @ Break loop if loop counter = 0

    LDR r0, =newLines
    BL printf

    POP {lr}               @ Pop the lr back off the stack
    BX lr                  @ Return from function


exit:
    MOV r7, #0x01
    SVC 0

    .data                  @ Data section starts here
    .balign 4
    strOutputNum: .asciz "Array[%d] = "

    .balign 4
    strPrintArr: .asciz "Array: %d \n"

    .balign 4
    newLines: .asciz "\n"

    .balign 4
    printInt: .asciz "%d\n"

    .balign 4
    strInputPrompt: .asciz "Input 'n' for negative numbers, 'p' for positive, or '0' for zero\n---> "
    .balign 4
    numInputPattern: .asciz "%c"
    .balign 4
    userInput: .word 0    @ Space for user input
    .balign 4
    invalidInput: .asciz "Invalid Input!\nPress any key to continue..."
    .balign 4
    strZeroOutput: .asciz "Array[%d] = 0\n"
    .balign 4
    strPrintZeros: .asciz "Zeros in Array3: \n"
    .balign 4
    strPrintPositives: .asciz "Positives in Array3: \n"
    .balign 4
    strPrintNegatives: .asciz "Negatives in Array3: \n"


    .balign 4
    array1: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10    @ Array 1
    array2: .word -1, -4, -3, 22, -6, 8, -12, 10, -10, 100  @ Array 2
    array3: .space 40       @ Space for array3 (10 integers)

@ To use printf:
@ r0 - Contains the starting address of the string to be printed. The string
@ must conform to the C coding standards.
@ r1 - If the string contains an output parameter i.e., %d, %c, etc. register
@ r1 must contain the value to be printed.
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed.
@ r2 - Is the ending address of the string
