.text            
.global _start

_start:

main:
    /**************************
     * Program overview:
     * First we will display a prompt
     * to the user asking for a positive integer
     * with the write syscall
     * Then we will use the read syscall to 
     * take input. This input will be stored in entry
     **************************/
     
    /********************
     * Write syscall
     * syscall number: 0x40 (64)
     * first arg: file descriptor 
     *    1 is the fd for stdout
     * second arg: pointer to string
     *    here it is stored in prompt
     * third arg: num of bytes to print
     *    here it's the length of prompt
     *********************/
    mov x0, #1          //put value 1 in x0
    ldr x1, =prompt     //load prompt pointer in x1
    ldr x2, =plen       //load prompt length in x2
    mov x8, 0x40        //put value 64 in x8
    svc 0               //system call
    
    
    /********************
     * Read syscall
     * syscall number: 0x3f (63)
     * first arg: file descriptor 
     *    0 is the fd for stdin
     * second arg: pointer to buffer
     *    here it is stored in "message"
     * third arg: num of bytes to read in
     *    here it's the length of message
     *********************/
    mov x0, #1          //put value 1 in x0
    ldr x1, =entry      //load entry pointer in x1
    ldr x2, =entrysize  //put entrysize in x2
    mov x8, 0x3f        //put value 63 in x8
    svc 0               //system call
    
    mov x4, x0          //put value of x0 in x4

    ldr x10, =entry     //load entry pointer to x10 (start address)
    mov x11, #0         //put value 0 to x11 (char index)

    mov x16, #0         //digits count, put value 0 in x16
    mov x17, #0         //uppercase count, put value 0 in x17
    mov x18, #0         //lowercase count, put value 0 in x18
    mov x19, #0         //special count, put value 0 in x19

    loop:               //label

    ldrb w5, [x10, x11]     //load byte into w5 form address x10 index x11

    add x20, x11, #1        //index of next character for end of string check, add 1 to x11 and put into x20
    ldrb w6, [x10, x20]     //load byte into w6 from address x10 index x20

    cmp w6, #0          //compare w6 and 0 (end of string check)
    B.EQ stop           //if equal jump to stop
    add x11, x11, #1    //increment x11 by 1


    //is digit check         
    cmp w5, #48         //compare w5 and value 48 (ASCII for digit 0)
    B.LT special        //if w5 is less than 48 jump to special
    cmp w5, #57         //compare w5 and value 57 (ASCII for digit 9)
    B.GT upercase       //if w5 is greather than 57 jump to uppercase

    //increment digits
    add x16, x16, #1    //increment x16 by 1
    b loop              //jump to loop

    //is upper case
    upercase:           //label
    cmp w5, #65         //compare w5 and value 65 (ASCII for letter A)
    B.LT special        //if w5 is less than 65 jump to special
    cmp w5, #90         //compare w5 and value 90 (ASCII for letter Z)
    B.GT lowercase      //if w5 is greather than 90 jump to lowercase

    add x17, x17, #1    //increment x17 by 1
    b loop              //jump to loop

    lowercase:          //label
    cmp w5, #97         //compare w5 and value 97 (ASCII for letter a)
    B.LT special        //if w5 is less than 97 jump to special
    cmp w5, #122        //compare w5 and value 122 (ASCII for letter z)
    B.GT special        //if w5 is greather than 122 jump to special

    add x18, x18, #1    //increment x18 by 1
    b loop              //jump to loop

    //is special char
    special:            //label
    add x19, x19, #1    //increment x19 by 1
    
    b loop              //jump to loop

    stop:               //label

    /*print message*/
    mov x0, #1              //put value 1 in x0
    ldr x1, =containsmsg    //load prompt pointer in x1
    ldr x2, =cmlen          //load prompt length in x2
    mov x8, 0x40            //put value 64 in x8
    svc 0                   //system call

    /*print result for uppercase*/
    ldr x1, =uppercasemsg   //load pointer of uppercasemsg to x1 (message for printing)
    ldr x2, =umlen          //load size of uppercasemsg to x2
    mov x3, x17             //put x17 in to x3 (number for printing)
    bl print                //jump link to print

    /*print result for lowercase*/
    ldr x1, =lowercasemsg   //load pointer of uppercasemsg to x1 (message for printing)
    ldr x2, =lmlen          //load size of uppercasemsg to x2
    mov x3, x18             //put x17 in to x3 (number for printing)
    bl print                //jump link to print

    /*print result for digits*/
    ldr x1, =digitsmsg      //load pointer of uppercasemsg to x1 (message for printing)
    ldr x2, =dmlen          //load size of uppercasemsg to x2
    mov x3, x16             //put x17 in to x3 (number for printing)
    bl print                //jump link to print

    /*print result for special*/
    ldr x1, =specialmsg     //load pointer of uppercasemsg to x1 (message for printing)
    ldr x2, =smlen          //load size of uppercasemsg to x2
    mov x3, x19             //put x17 in to x3 (number for printing)
    bl print                //jump link to print


    exit:           //label
    mov x8, #93     //put value 93 in to x8
    svc 0           //system call


    /*print fucnction, arguments x1,x2,x3*/
    print:                      //label
    stp fp, lr, [sp, #-16]!     //sotre return address on stack
    mov x0, #1                  //put value 1 in x0
    mov x8, 0x40                //put value 64 in x8
    svc 0                       //system call

    mov x0, x3          //put x3 in to x0 (number argument)
    bl int2str          //jump link int2str
    ldr x1, =number     //load number pointer in x1
    str x0, [x1]        //write x0 to where is x1 pointing

    mov x0, #1                  //put value 1 in x0
    ldr x1, =number             //load number pointer in x1
    mov x2, 8                   //put value 8 in x2
    mov x8, 0x40                //put value 64 in to x8
    svc 0                       //system call
    ldp fp, lr, [sp], #16       //restore return address
    ret                         //return

    int2str:                    //label
    stp fp, lr, [sp, #-16]!     //store return address on stack

    //use x10 as a constant containing for mul/div
    mov x10, 10
    
    //keep result in x4, starting with newline character
    mov x4,0xa
    
    //make room for the next byte
    lsl x4,x4,8
    .loop:
    //get the remainder in x3
    udiv x2, x0, x10
    msub x3, x10, x2, x0
    //put byte at end of result
    add x3, x3, 0x30
    orr x4, x4, x3
    //mov string by a byte
    lsl x4, x4, 8
    //actually divide number
    udiv x0, x0, x10
    //if number is less than 10, finish 
    cmp x0, 9
    bgt .loop

    //put in most significant byte
    add x3, x0, 0x30
    orr  x4, x4, x3
    //return result
    mov x0, x4
    ldp fp, lr, [sp], #16
    ret


.data
prompt: .asciz "Please enter a string: "
plen = .-prompt

containsmsg: .asciz "The string contains \n"
cmlen = .-containsmsg

uppercasemsg: .asciz "Uppercase letters: "
umlen = .-uppercasemsg

lowercasemsg: .asciz "Lowercase letters: "
lmlen = .-lowercasemsg

digitsmsg: .asciz "Digits: "
dmlen = .-digitsmsg

specialmsg: .asciz "Special characters: "
smlen = .-specialmsg

entrysize = 100

/*bss is for uninitialized data*/
.bss
entry: .space entrysize
number: .space 8
