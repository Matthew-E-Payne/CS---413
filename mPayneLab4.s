.thumb
.global main
.extern printf
.extern scanf

.data
    .align 4
    welcome_msg:           .asciz "Welcome to the vending machine\nCost of Gum ($0.50), Peanuts ($0.55), Cheese Crackers ($0.65), or M&Ms ($1.00)\n\n"
    select_item_msg:       .asciz "Enter item selection: Gum(G), Peanuts(P), Cheese Crackers(C), M&Ms(M).\n---> "
    confirm_msg:           .asciz "You selected %s. Is this correct (Y/N)?\n"
    enter_money_msg:       .asciz "Current balance = %d cents\nEnter money for selection (D = dimes, Q = quarters, B = dollars)\nPress any other key to continue... "
    success_msg:           .asciz "Enough money entered. Dispensing item.\nInventory left: %d\n"
    invalid_msg:           .asciz "Invalid selection, please try again.\n"
    out_of_item_msg:       .asciz "Sorry we are currently out of this item\n"
    gum_inventory_msg:     .asciz "Inventory: Gum: %d,"
    peanuts_inventory_msg: .asciz " Peanuts: %d,"
    crackers_inventory_msg: .asciz " Cheese Crackers: %d,"
    mms_inventory_msg:     .asciz " M&Ms: %d\n"
    shutdown_msg:          .asciz "Machine shutting down. No inventory left.\n"
    moneySum_msg:          .asciz "Your money total is: %d cents\n"
    not_enough_msg:        .asciz "Not enough money entered... restarting\n"
    return_money:          .asciz "Change of %d cents has been returned\n"

    gum:                   .asciz "Gum"
    peanuts:               .asciz "Peanuts"
    cheeseCrackers:        .asciz "Cheese Crackers"
    mms:                   .asciz "M&Ms"

    .align 4
    gum_inventory:         .word 2
    peanuts_inventory:     .word 2
    crackers_inventory:    .word 2
    mms_inventory:         .word 2

    .align 4
    gum_price:             .word 50
    peanuts_price:         .word 55
    crackers_price:        .word 65
    mms_price:             .word 100

    scanf_format:          .asciz "%s"

.bss
    .align 4
    user_input:        .space 2
    current_money:     .word 0

.text
.thumb_func
main:
    @ Display welcome message
    ldr r0, =welcome_msg
    bl printf

main_loop:
    @ Check if the vending machine is empty if it is then shutdown
    bl check_inventory

    @ Display item selection message
    ldr r0, =select_item_msg
    bl printf

    @ Read user input (G, P, C, M, S)
    ldr r0, =scanf_format
    ldr r1, =user_input
    bl scanf

    @ Load first byte of user input into r0
    ldr r1, =user_input
    ldrb r0, [r1]

    @ Check which item was selected
    cmp r0, #'G'
    beq select_gum
    cmp r0, #'P'
    beq select_peanuts
    cmp r0, #'C'
    beq select_crackers
    cmp r0, #'M'
    beq select_mms
    cmp r0, #'S'

    @ Branch to secret mode if S is selected to display inventory
    beq secret_mode
    b invalid_selection


@ Init values based on selected items
select_gum:
    ldr r1, =gum
    ldr r6, =gum_inventory
    ldr r4, =gum_price
    ldr r4, [r4]
    b item_selected

select_peanuts:
    ldr r1, =peanuts
    ldr r6, =peanuts_inventory
    ldr r4, =peanuts_price
    ldr r4, [r4]
    b item_selected

select_crackers:
    ldr r1, =cheeseCrackers
    ldr r6, =crackers_inventory
    ldr r4, =crackers_price
    ldr r4, [r4]
    b item_selected

select_mms:
    ldr r1, =mms
    ldr r6, =mms_inventory
    ldr r4, =mms_price
    ldr r4, [r4]
    b item_selected

@ Secret mode to display values
secret_mode:
    @ Display all inventory values
    ldr r0, =gum_inventory_msg
    ldr r1, =gum_inventory
    ldr r1, [r1]
    bl printf

    ldr r0, =peanuts_inventory_msg
    ldr r1, =peanuts_inventory
    ldr r1, [r1]
    bl printf

    ldr r0, =crackers_inventory_msg
    ldr r1, =crackers_inventory
    ldr r1, [r1]
    bl printf

    ldr r0, =mms_inventory_msg
    ldr r1, =mms_inventory
    ldr r1, [r1]
    bl printf

    b main_loop

item_selected:
    ldr r2, [r6]
    cmp r2, #0
    beq out_of_item @ If out of selected item branch back to main

    ldr r0, =confirm_msg
    bl printf @ Display message confirming the item selected

    ldr r0, =scanf_format
    ldr r1, =user_input
    bl scanf

    ldr r1, =user_input @ Load user input into r1
    ldrb r3, [r1]
    cmp r3, #'Y'
    bne main_loop @ If user input is not 'Y' ie if it is N then branch back to main_loop

    mov r5, #0 @ Init counter to store the money
    b money_loop

money_loop:
    ldr r0, =enter_money_msg
    mov r1, r5
    bl printf @ Ask user what money they would like to input

    ldr r0, =scanf_format
    ldr r1, =user_input
    bl scanf @ Take user input

    ldr r1, =user_input
    ldrb r3, [r1] @Load user input into r3

    cmp r3, #'D'
    beq add_dime
    cmp r3, #'Q'
    beq add_quarter
    cmp r3, #'B'
    beq add_dollar

    b money_loop @ If user did not input a valid input branch back to money_loop

@Add said currency to counter then if money is still not greater than price then go back to money_loop
add_dime:
    add r5, r5, #10
    b money_check

add_quarter:
    add r5, r5, #25
    b money_check

add_dollar:
    add r5, r5, #100

money_check:
    cmp r5, r4
    blt money_loop

    ldr r3, [r6]
    sub r3, r3, #1
    str r3, [r6]

    ldr r0, =success_msg
    mov r1, r3
    bl printf

    ldr r0, =return_money
    sub r1, r5, r4
    bl printf

    b main_loop

invalid_selection:
    ldr r0, =invalid_msg
    bl printf
    b main_loop

out_of_item:
    ldr r0, =out_of_item_msg
    bl printf
    b main_loop

check_inventory:
    ldr r0, =gum_inventory
    ldr r1, [r0]
    ldr r0, =peanuts_inventory
    ldr r2, [r0]
    ldr r0, =crackers_inventory
    ldr r3, [r0]
    ldr r0, =mms_inventory
    ldr r4, [r0]

    add r1, r1, r2
    add r1, r1, r3
    add r1, r1, r4

    cmp r1, #0
    beq shutdown
    bx lr

shutdown:
    ldr r0, =shutdown_msg
    bl printf
    b .

