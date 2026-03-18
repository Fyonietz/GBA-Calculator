MEMORY
{
    ewram (rwx) : ORIGIN = 0x02000000, LENGTH = 256K
    iwram (rwx) : ORIGIN = 0x03000000, LENGTH = 32K
    rom   (rx)  : ORIGIN = 0x08000000, LENGTH = 32M
}

ENTRY(_gba_entry)

SECTIONS
{
    .gba.header 0x08000000 :
    {
        KEEP(*(.gba.header))
    } > rom

    .text :
    {
        *(.text*)
        *(.rodata*)
    } > rom

    .data :
    {
        *(.data*)
    } > iwram AT> rom

    .bss (NOLOAD) :
    {
        *(.bss*)
        *(COMMON)
    } > iwram

    /DISCARD/ :
    {
        *(.ARM.exidx*)
        *(.ARM.extab*)
    }
}
