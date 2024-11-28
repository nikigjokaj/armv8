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
    mov x2, 8           //put value 8 in x2
    mov x8, 0x3f        //put value 63 in x8
    svc 0               //system call

    /********************
    * load user input in x0 
    * for to int conversion
    ********************/
    mov x1, x0          //put value of x0 in x1
    ldr x0, =entry      //load entry pointer in x0

    /********************
    * conversion from string to int
    * Return value is in x0
    * we'll use x4 as a temp register
    * to store it for a later write call
    ********************/
    bl str2int          //jump with link

    /********************
    * check if input is
    * positive integer
    * if not, jump to error
    ********************/
    mov x1, #0          //put value 0 in x1
    CMP x0, x1          //compare x0 and x1
    B.LE error          //if x0 is less or equal to x1, jump to error

    /********************
    * store input in x15
    * for loop condition
    ********************/
    mov x15, x0         //put value of x0 in x15

    /********************
    * jump to main loop
    * to start checking
    * the range of numbers
    * from 1 to x15 (input)
    ********************/
    b automorifcnumber  //jump to automorifcnumber


    /********************
     * Exit syscall
     * syscall number: 0x5d (93)
     * no arguments
     *********************/
    exit:               //label
    mov x8, #93         //put value 93 in x8
    svc 0               //system call


    /********************
     * Print error message
     * than go to exit
     *********************/
    error:              //label
    mov x0, #1          //put value 1 in x0
    ldr x1, =errormsg   //load pointer of errormsg in x1
    ldr x2, =elen       //load errormsg length in x2
    mov x8, 0x40        //put value 64 in x8
    svc 0               //system call
    b exit              //jump to exit


    /********************
    * main loop
    *********************/
    automorifcnumber:   //label
 
    /*initialize base*/
    mov x16, #10        //put value 10 in x16
    /*initialize counter*/
    mov x7, #1          //put value 1 in x7

    mainloop:           //label

    /*loop condition*/
    CMP x7, x15         //compare x7 and x15
    B.GT exit           //if x7 is greather than x15 jump to exit
 
    /***************************************
    * mod of x7 (mainloop counter) and x16 (base)
    * if mod is == 0, multiply base by 10
    * else go to skip
    ***************************************/
    UDIV x10, x7, x16       //unsigned devide x7 with x16 and put result in x10
    MSUB x11, x10, x16, x7  //multiply substract x11 = x7 - x10 * x16

    CBNZ x11, skip      //if x11 is not equal to 0, go to skip

    /***************************
    * multiply the base by 10
    * base number of digits should
    * be the same as counters number
    * of digits
    ***************************/

    MOV x13, #10        //put value 10 in x13
    MUL x16, x16, x13   //multiply x16 by x13 and save in x16

    skip:               //label

    /***************************************
    * check if number is automorifc
    * (counter * counter) % base
    * if mod is == 0, number is automorfic
    * else go to notautomorfic
    ***************************************/

    MUL X12, x7, x7             //multiply x7 by x7 and save to x12
    UDIV x10, x12, x16          //unsigned devide x12 with x16 and put result in x10
    MSUB x11, x10, x16, x12     //multiply substract x11 = x12 - x10 * x16
    SUB x11, x11, x7            //substract x11 and x7 and save to x11

    /*********************************
    * if remainder of counter * counter
    * is equal to counter we have found
    * automorific number
    *********************************/
    CBNZ x11, notautomorfic     //if x11 is not equalt to 0, jump to notautomorfic

    /*********************************
    * print counter as it is automorfic
    *********************************/
    mov x0, x7          //put x7 in to x0
    bl int2str          //jump link to int2str to convert x7 to string

    ldr x1, =number     //load number pointer in x1
    str x0, [x1]        //write x0 to where is x1 pointing

    mov x0, #1          //put value 1 in x0
    ldr x1, =number     //load number pointer in x1
    mov x2, 8           //put value 8 in x2
    mov x8, 0x40        //put value 64 in to x8
    svc 0               //system call

    notautomorfic:      //label

    add x7, x7, #1      //add 1 to x7 - increse loop counter by 1

    b mainloop          //jump to mainloop

    str2int:
    /***********************
    * Push return address:
    * sp <- sp - 16
    * *sp <- fp
    * *(sp + 8) <- lr
    ***********************/
    stp fp, lr, [sp, #-16]!
    
    //string length - 1 (because of newline char)
    sub x1, x1, 1
    
    //use x10 as a constant containing for mul/div
    mov x10, 10
    
    //x2 holds power of ten
    mov x2, 1
    
    //get most significant power of ten (# of digits - 1)
    sub x1, x1, 1
    pow:
    cbz x1, endpow
    mul x2, x2, x10
    sub x1, x1, 1
    b pow
    endpow:
    
    //x3 holds ALL bytes of the string
    ldr x3, [x0]
 
    //we will accumulate the result in x5
    mov x5, 0
    
    loop:

    //get first byte (which is the most significant (little endian)
    and x4, x3, 0xff

    //convert char -> int 
    sub x4, x4, 0x30
    
    //multiply by current power of 10
    mul x4, x4, x2
    
    //add to result
    add x5, x5, x4
    
    //decrease power of ten
    udiv x2, x2, x10
    
    //shift by a byte to expose next-most significant byte
    asr x3, x3, 8
    //loop ends when multipler is 0
    cbnz x2, loop
    
    //put result in return value
    mov x0, x5
    /***********************
    * Pop return address
    * fp <- *sp 
    * lr <- *(sp + 8)
    * sp <- sp + 16 
    ***********************/
    ldp fp, lr, [sp], #16
    ret

    int2str:
    stp fp, lr, [sp, #-16]!
    //use x10 as a constant containing for mul/div
    mov x10, 10
    
    //keep result in x4, starting with newline character
    mov x4,0xa
    
    //make room for the next byte
    lsl x4,x4,8
    .loop:
    //get the remainder in x3 (see guess.s for how this works)
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
prompt: .asciz "Enter a positive integer: "
plen = .-prompt

errormsg: .asciz "Error: number must be a positive integer \n"
elen = .-errormsg

/*bss is for uninitialized data*/
.bss
entry: .space 8
number: .space 8
