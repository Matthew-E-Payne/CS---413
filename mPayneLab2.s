.global main

main:
    LDR r0, =strInputPrompt   @ Load prompt for user input
    BL printf                 @ Print input prompt
    LDR r0, =strInputPattern  @ Load the format pattern for scanf
    LDR r1, =userInput        @ Store the address to store user input
    BL scanf                  @ Read user input

    LDR r0, =userInput
    LDR r1, =strTriangle      @ Load string "TRIANGLE" into R1
    BL strcmp                 @ Compare "TRIANGLE" to user input
    CMP r0, #0
    BEQ prepare_triangle_area @ If equal branch to triangle area calculation

    LDR r0, =userInput
    LDR r1, =strRectangle     @ Load "RECTANGLE" into r1
    BL strcmp                 @ Compare "RECTANGLE" to user input
    CMP r0, #0
    BEQ prepare_rectangle_area@ If equal then just branch to area calculation

    LDR r0, =userInput
    LDR r1, =strSquare        @ Load "SQUARE" into r1
    BL strcmp
    CMP r0, #0                @ Check if the input is equal to "SQUARE"
    BEQ prepare_square_area   @ If it is equal then branch to square area calculation

    LDR r0, =userInput
    LDR r1, =strTrapezoid     @ Load "TRAPEZOID" into r1
    BL strcmp
    CMP r0, #0                @ Check if the input is equal to "TRAPEZOID"
    BEQ prepare_trapezoid_area@ If it is equal then branch to trapezoid area calculation

    LDR r0, =userInput
    LDR r1, =strQuit
    BL strcmp
    CMP r0, #0
    BEQ quit

    LDR r0, =strInvalidInput
    BL printf
    LDR r0, =strInvalidInput
    LDR r1, =userInput
    BL scanf
    B main

prepare_triangle_area:
    LDR r0, =strTrianglePrompt
    BL printf                 @ Prompt for base and height
    LDR r0, =numInputPattern
    LDR r1, =triangleBase     @ Store base into r1
    BL scanf                  @ Read base input
    LDR r0, =numInputPattern
    LDR r1, =triangleHeight   @ Store height into r1
    BL scanf                  @ Read height input

    LDR r2, =triangleBase     @ Load base into r2
    LDR r3, =triangleHeight   @ Load height into r3
    LDR r2, [r2]
    LDR r3, [r3]
    PUSH {r2, r3}             @ Push base and height onto the stack
    BL calc_triangle_area     @ Call the triangle area calculation
    B continue_calculation_prompt

prepare_rectangle_area:
    LDR r0, =strRectanglePrompt
    BL printf                 @ Prompt for width and height
    LDR r0, =numInputPattern
    LDR r1, =rectangleWidth   @ Store width into r1
    BL scanf                  @ Read width input
    LDR r0, =numInputPattern
    LDR r1, =rectangleHeight  @ Store height into r1
    BL scanf                  @ Read height input

    LDR r2, =rectangleWidth   @ Load width into r2
    LDR r3, =rectangleHeight  @ Load height into r3
    LDR r2, [r2]
    LDR r3, [r3]
    PUSH {r2, r3}             @ Push width and height onto the stack
    BL calc_rectangle_area    @ Call the rectangle area calculation
    B continue_calculation_prompt

prepare_square_area:
    LDR r0, =strSquarePrompt
    BL printf                 @ Prompt for side length
    LDR r0, =numInputPattern
    LDR r1, =squareSide       @ Store side into r1
    BL scanf                  @ Read side input

    LDR r2, =squareSide       @ Load side into r2
    LDR r2, [r2]
    PUSH {r2}                 @ Push side length onto the stack
    BL calc_square_area       @ Call the square area calculation
    B continue_calculation_prompt

prepare_trapezoid_area:
    LDR r0, =strTrapezoidPrompt
    BL printf                 @ Prompt for bases and height
    LDR r0, =numInputPattern
    LDR r1, =trapezoidBase1   @ Store first base into r1
    BL scanf                  @ Read first base input
    LDR r0, =numInputPattern
    LDR r1, =trapezoidBase2   @ Store second base into r1
    BL scanf                  @ Read second base input
    LDR r0, =numInputPattern
    LDR r1, =trapezoidHeight  @ Store height into r1
    BL scanf                  @ Read height input

    LDR r2, =trapezoidBase1   @ Load first base into r2
    LDR r3, =trapezoidBase2   @ Load second base into r3
    LDR r4, =trapezoidHeight  @ Load height into r4
    LDR r2, [r2]
    LDR r3, [r3]
    LDR r4, [r4]
    PUSH {r2, r3, r4}         @ Push base1, base2, and height onto the stack
    BL calc_trapezoid_area    @ Call the trapezoid area calculation
    B continue_calculation_prompt

calc_triangle_area:
    POP {r2, r3}              @ Pop base and height from the stack
    MUL r4, r2, r3            @ Calculate base * height
    MOV r1, r4, LSR #1        @ Divide by 2 (area = base * height / 2)
    LDR r0, =strResult        @ Load result prompt
    PUSH {lr}                 @Push LR to stack
    BL printf                 @ Print area
    POP {pc}                     @ Return by popping LR to PC

calc_rectangle_area:
    POP {r2, r3}              @ Pop width and height from the stack
    MUL r4, r2, r3            @ Calculate width * height
    MOV r1, r4                @ Move result into r1 (area = width * height)
    LDR r0, =strResult        @ Load result prompt
    PUSH {lr}
    BL printf                 @ Print area
    POP {pc}                     @ Return

calc_square_area:
    POP {r2}                  @ Pop side length from the stack
    MUL r4, r2, r2            @ Calculate side * side (area = side^2)
    MOV r1, r4                @ Move result into r1
    LDR r0, =strResult        @ Load result prompt
    PUSH {lr}
    BL printf                 @ Print area
    POP {pc}                  @ Return

calc_trapezoid_area:
    POP {r2, r3, r4}          @ Pop base1, base2, and height from the stack
    ADD r5, r2, r3            @ Calculate base1 + base2
    MUL r6, r5, r4            @ Multiply by height
    MOV r1, r6, LSR #1        @ Divide by 2 (area = (base1 + base2) * height / 2)
    LDR r0, =strResult        @ Load result prompt
    PUSH {lr}
    BL printf                 @ Print area
    POP {pc}                  @ Return

strcmp:
    PUSH {r4, lr}             @ Save registers
strcmp_loop:
    LDRB r2, [r0], #1         @ Load byte from first string, increment pointer
    LDRB r3, [r1], #1         @ Load byte from second string, increment pointer
    CMP r2, r3                @ Compare the two bytes
    BNE strcmp_diff           @ Branch if different
    CMP r2, #0                @ Check for null terminator
    BEQ strcmp_done           @ If both null, strings are equal
    B strcmp_loop             @ Continue comparing next characters
strcmp_diff:
    MOV r0, #1                @ Strings are different
    B strcmp_return
strcmp_done:
    MOV r0, #0                @ Strings are equal
strcmp_return:
    POP {r4, lr}              @ Restore registers
    BX lr                     @ Return

continue_calculation_prompt:
    LDR r0, =strCCPrompt  @ Load the prompt message
    BL printf                    @ Print the prompt

    LDR r0, =strInputPattern     @ Load format pattern for scanf
    LDR r1, =userInput           @ Address to store the response
    BL scanf                     @ Read user input

validate_continue_input:
    LDR r0, =userInput           @ Load user input
    LDR r1, =strYes              @ Load string "yes"
    BL strcmp                    @ Compare with "yes"
    CMP r0, #0                   @ Check if equal
    BEQ main                     @ If yes, branch to main

    LDR r0, =userInput           @ Load user input again
    LDR r1, =strNo                @ Load string "no"
    BL strcmp                    @ Compare with "no"
    CMP r0, #0                   @ Check if equal
    BEQ quit                     @ If no, branch to quit

    LDR r0, =userInput           @ Load user input for single character check
    LDRB r1, [r0]                @ Load the first byte of user input
    CMP r1, #'y'                 @ Check for 'y'
    BEQ main                     @ If yes, branch to main

    CMP r1, #'n'                 @ Check for 'n'
    BEQ quit                     @ If no, branch to quit

    B continue_calculation_prompt @ Invalid input, prompt again

quit:
    LDR r0, =strTerminate
    BL printf
    MOV r7, #0x01             @ Syscall number for exit in Linux
    svc 0                @ Exit status 0 (success)

.data
    .balign 4
    strInputPrompt:    .asciz "Input \"triangle\", \"rectangle\", \"trapezoid\" or \"square\" for area calculation... type quit to exit the program\n---> "
    strTrianglePrompt: .asciz "Enter base and height of the triangle\n"
    strInvalidInput:   .asciz "The input you entered is not valid please try again\nEnter anything into the textbox to continue..."
    strRectanglePrompt:.asciz "Enter width and height of the rectangle\n"
    strSquarePrompt:   .asciz "Enter side length of the square\n"
    strTrapezoidPrompt:.asciz "Enter both bases and the height of the trapezoid\n"
    strResult:         .asciz "The area is: %d\n"
    strInputPattern:   .asciz "%s"
    numInputPattern:   .asciz "%d"
    strTerminate:      .asciz "Terminating Program"
    strCCPrompt:       .asciz "Would you like to continue with another calculation? (y/n)\n---> "

    @ Variables to store inputs
    .balign 4
    userInput:         .space 20           @ Store user input string
    triangleBase:      .word 0
    triangleHeight:    .word 0
    rectangleWidth:    .word 0
    rectangleHeight:   .word 0
    squareSide:        .word 0
    trapezoidBase1:    .word 0
    trapezoidBase2:    .word 0
    trapezoidHeight:   .word 0

   @ Expected input strings for comparison
    strTriangle:       .asciz "triangle"
    strRectangle:      .asciz "rectangle"
    strSquare:         .asciz "square"
    strTrapezoid:      .asciz "trapezoid"
    strQuit:           .asciz "quit"
    strNo:             .asciz "no"
    strYes:            .asciz "yes"
