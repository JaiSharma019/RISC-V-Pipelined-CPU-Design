.global _start

.section .text
_start:
    # Initialize the Stack Pointer to the very top of your 4KB memory
    li sp, 4096     

    # Jump to your C main() function
    jal ra, main    

    # The Infinite Trap (If main ever returns, freeze here safely)
end_trap:
    j end_trap