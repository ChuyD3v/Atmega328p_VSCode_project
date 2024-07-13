/* Linker script for ATmega328P */

/* Memory definitions */
MEMORY
{
  FLASH (rx)  : ORIGIN = 0x0000, LENGTH = 30K  /* 32KB total, 2KB reserved for bootloader */
  BOOT (rx)   : ORIGIN = 0x7800, LENGTH = 2K   /* 2KB Boot section starts at 0x7800 */
  RAM (rw!x)  : ORIGIN = 0x0100, LENGTH = 2K   /* 2KB SRAM */
  EEPROM (rw!x) : ORIGIN = 0x0000, LENGTH = 1K /* 1KB EEPROM */
}

/* Sections */
SECTIONS
{
  .text :
  {
    *(.vectors)
    *(.text)
    *(.text*)
    *(.rodata)
    *(.rodata*)
    *(.data*)
  } > FLASH

  .data : AT (ADDR(.text) + SIZEOF(.text))
  {
    __data_start = .;
    *(.data)
    *(.data*)
    __data_end = .;
  } > RAM

  .bss :
  {
    __bss_start = .;
    *(.bss)
    *(.bss*)
    *(COMMON)
    __bss_end = .;
  } > RAM

  .eeprom :
  {
    *(.eeprom*)
  } > EEPROM

  .boot :
  {
    *(.boot*)
  } > BOOT

  /* Ensure the stack pointer is set up correctly */
  __stack = ORIGIN(RAM) + LENGTH(RAM);
  PROVIDE(_stack = __stack);
}
