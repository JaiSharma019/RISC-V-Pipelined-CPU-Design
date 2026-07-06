OUTPUT_ARCH( "riscv" )
ENTRY( _start )

/* HARD PARTITIONING THE MEMORY */
MEMORY
{
  /* 2KB for Instructions and Variables */
  RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 0x0800 
  
  /* A dedicated VIP Zone starting exactly at 0x0800 (Word 512) */
  SIG (rw)  : ORIGIN = 0x00000800, LENGTH = 0x0100 
}

SECTIONS
{
  .text : { *(.text*) } > RAM
  .rodata : { *(.rodata*) } > RAM
  .data : { *(.data*) *(.sdata*) } > RAM
  .bss : { *(.bss*) *(.sbss*) } > RAM

  /* Force the signature array into the SIG block, not RAM! */
  .signature : {
    *(.signature)
  } > SIG
}