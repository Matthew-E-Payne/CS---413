@ Matthew Payne

@ To run the program type the following lines
@ as -o mPayneLab3.o -g mPayneLab3.s
@ gcc -o mPayneLab3 -g mPayneLab3.s
@./mPayneLab3

@ Secret code is "s"


.global main
.extern printf
.extern scanf
.data
    welcome_msg:           .asciz "Welcome to the vending machine\nCost of Gum ($0.50), Peanuts ($0.55), Cheese Crackers ($0.65), or M&Ms ($1.00)\n\n"
    select_item_msg:       .asciz "Enter item selection: Gum(G), Peanuts(P), Cheese Crackers (C), or M&Ms (M).\n---> "
    confirm_msg:           .asciz "You selected %s. Is this correct (Y/N)?\n"
    enter_money_msg:       .asciz "Current balance = %d\nEnter money for selection (D = dimes, Q = quarters, B = dollars)\nPress any other key to continue... "
    success_msg:           .asciz "Enough money entered. Dispensing item.\nInventory left: %d\n"
    invalid_msg:           .asciz "Invalid selection, please try again.\n"
    gum_inventory_msg:     .asciz "Inventory: Gum: %d,"
    peanuts_inventory_msg: .asciz " Peanuts: %d,"
    crackers_inventory_msg:.asciz " Cheese Crackers: %d,"
    mms_inventory_msg:     .asciz " M&Ms: %d\n"
    shutdown_msg:          .asciz "Machine shutting down. No inventory left.\n"
    moneySum_msg:          .asciz "Your money total is: %d cents\n"
    not_enough_msg:        .asciz "Not enough money entered... restarting\n"
    return_money:          .asciz "Change of %d cents has been returned\n"
    out_of_item:           .asciz "Sorry we are currently out of this item\n"

    spaces:                .asciz "\n\n\n\n\n"

    gum:                   .asciz "Gum"
    peanuts:               .asciz "Peanuts"
    cheeseCrackers:        .asciz "Cheese Crackers"
    mms:                   .asciz "M&Ms"

    gum_inventory:         .word 0
    peanuts_inventory:     .word 0
    crackers_inventory:    .word 0
    mms_inventory:         .word 1

    scanf_format:          .asciz "%s"
    scanf_secret:          .asciz "%d"     @ For secret code entry

.bss
    user_input:        .space 2  @ Space for user input
    money_input:       .space 2  @ Space for money input
    secret_code_input: .space 4  @ Space for secret code input

.text



main:
    ldr r4, =gum_inventory
    ldr r11, =peanuts_inventory
    ldr r9,  =crackers_inventory
    ldr r8,  =mms_inventory
    ldr r8, [r8]
    ldr r9, [r9]
    ldr r11, [r11]
    ldr r4, [r4]

after_init:
    @ Display welcome message
    ldr r0, =welcome_msg
    bl printf

main_loop:
    @ Display item selection
    ldr r0, =select_item_msg
    bl printf

    @ Read user selection (G, P, C, M)
    ldr r1, =user_input     @ buffer for input
    ldr r0, =scanf_format   @ format string for scanf
    bl scanf                @ call scanf to get the input

    @ Load selected item into r3
    ldr r5, =user_input
    ldr r5, [r5]

    @ Check if selection is a valid item or secret code
    cmp r5, #'G'
    beq select_gum
    cmp r5, #'P'
    beq select_peanuts
    cmp r5, #'C'
    beq select_crackers
    cmp r5, #'M'
    beq select_mms
    cmp r5, #'S'            @ Check for secret code 'S'
    beq secret_mode
    b invalid_selection

out_of_items:
    ldr r0, =out_of_item
    bl printf
    b main_loop

select_gum:
    mov r7, #50
    ldr r1, =gum
    ldr r2, =gum_inventory
    ldr r2, [r2]
    cmp r2, #0
    bgt confirm_selection
    b out_of_items
select_peanuts:
    mov r7, #55
    ldr r1, =peanuts
    ldr r2, =peanuts_inventory
    ldr r2, [r2]
    cmp r2, #0
    bgt confirm_selection
    b out_of_items
select_crackers:
    mov r7, #65
    ldr r1, =cheeseCrackers
    ldr r2, =crackers_inventory
    ldr r2, [r2]
    cmp r2, #0
    bgt confirm_selection
    b out_of_items
select_mms:
    mov r7, #100
    ldr r1, =mms
    ldr r2, =mms_inventory
    ldr r2, [r2]
    cmp r2, #0
    bgt confirm_selection
    b out_of_items
decrementGum:
    ldr r2, =gum_inventory   @ Load the address of gum_inventory
    ldr r3, [r2]             @ Load the current value into a temp register
    sub r3, r3, #1           @ Decrement the value
    str r3, [r2]             @ Store the decremented value back into gum_inventory
    mov r1, r3               @ Move the updated value to r1 for any further operations
    B return

decrementPeanuts:
    sub r11, #1
    ldr r1, =peanuts_inventory
    str r11, [r1]
    mov r1, r11
    B return

decrementCrackers:
    sub r9, #1
    ldr r1, =crackers_inventory
    str r9, [r1]
    mov r1, r9
    B return

decrementMMS:
    sub r8, #1
    ldr r1, =mms_inventory
    str r8, [r1]
    mov r1, r8
    B return

confirm_selection:
    @ Display confirmation
    ldr r0, =confirm_msg    @ Load address of confirmation message
    bl printf               @ Call printf to display confirmation message

    @ Read user confirmation (Y/N)
    ldr r0, =scanf_format   @ Load format string "%c" into r0
    ldr r1, =user_input     @ Load address of buffer for storing input into r1
    bl scanf                @ Call scanf to read confirmation

    @ Check if confirmation is 'Y'
    ldr r1, =user_input     @ Load the address of the buffer
    ldr r1, [r1]            @ Load the actual input character (byte) from the buffer
    cmp r1, #'Y'            @ Compare input with 'Y'
    bne main_loop           @ If not 'Y', go back to selection

 @   @ Check if inventory is available
    mov r6, #0
money_loop:
    ldr r0, =enter_money_msg
    mov r1, r6
    bl printf

    ldr r0, =scanf_format
    ldr r1, =user_input
    bl scanf

    ldr r1, =user_input
    ldr r1, [r1]

    cmp r1, #'D'            @ If 'D', add 10 cents (dime)
    beq add_dime
    cmp r1, #'Q'            @ If 'Q', add 25 cents (quarter)
    beq add_quarter
    cmp r1, #'B'            @ If 'B', add 100 cents (dollar)
    beq add_dollar

    ldr r0, =moneySum_msg
    mov r1, r6
    bl printf

return2:
    ldr r0, =return_money
    sub r1, r6, r7
    bl printf
    cmp r5, #'G'
    beq decrementGum
    cmp r5, #'P'
    beq decrementPeanuts
    cmp r5, #'C'
    beq decrementCrackers
    cmp r5, #'M'
    beq decrementMMS

return:
    ldr r0, =success_msg
    bl printf

    bl shutdown_check
    b main_loop

shutdown_check:
    ldr r1, =gum_inventory         @ Load gum inventory
    ldr r1, [r1]
    ldr r2, =peanuts_inventory     @ Load peanuts inventory
    ldr r2, [r2]
    ldr r3, =crackers_inventory    @ Load cheese crackers inventory
    ldr r3, [r3]
    ldr r4, =mms_inventory         @ Load M&Ms inventory
    ldr r4, [r4]

    add r5, r1, r2                 @ Add gum and peanuts inventory
    add r5, r5, r3                 @ Add cheese crackers inventory
    add r5, r5, r4                 @ Add M&Ms inventory

    cmp r5, #0                     @ Compare the total to zero
    beq shutdown                   @ If all inventories are zero, shut down
    b main_loop                    @ Otherwise, return to the main loop

shutdown:
    @ Display shutdown message
    ldr r0, =shutdown_msg
    bl printf
    b .                             @ End execution


add_dollar:
    add r6, r6, #100
    cmp r6, r7 @r7 is price r6 is money
    bge return2
    b money_loop
add_quarter:
    add r6, r6, #25
    cmp r6, r7 @r7 is price r6 is money
    bge return2
    b money_loop
add_dime:
    add r6, r6, #10
    cmp r6, r7 @r7 is price r6 is money
    bge return2
    b money_loop

invalid_selection:
    @ Handle invalid selection
    ldr r0, =invalid_msg
    bl printf
    b main_loop

out_of_stock:
    @ Handle out of stock situation
    ldr r0, =invalid_msg
    bl printf
    b main_loop

secret_mode:
    @ Display inventory
    ldr r0, =gum_inventory_msg         @ Load the inventory message
    ldr r1, =gum_inventory         @ Load the address of gum inventory
    ldr r1, [r1]                   @ Load gum inventory value
    bl printf
    ldr r0, =peanuts_inventory_msg         @ Load the inventory message
    ldr r1, =peanuts_inventory     @ Load the address of peanuts inventory
    ldr r1, [r1]                   @ Load peanuts inventory value
    bl printf
    ldr r0, =crackers_inventory_msg         @ Load the inventory message
    ldr r1, =crackers_inventory    @ Load the address of cheese crackers inventory
    ldr r1, [r1]                   @ Load cheese crackers inventory value
    bl printf
    ldr r0, =mms_inventory_msg         @ Load the inventory message
    ldr r1, =mms_inventory         @ Load the address of M&Ms inventory
    ldr r1, [r1]                   @ Load M&Ms inventory value

    @ Call printf to display the inventory values
    bl printf

    b main_loop                    @ Return to the main loop after displaying inventory


