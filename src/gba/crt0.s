.section .gba.header, "ax", %progbits
.arm
.global _gba_entry

_gba_entry:
    b _start

@ Nintendo logo data — 156 bytes (0x9C), gbafix overwrites this
.fill 156, 1, 0

@ Game title — 12 bytes
.ascii "HELLOGBA    "

@ Game code — 4 bytes
.ascii "HELO"

@ Maker code — 2 bytes
.ascii "00"

@ Fixed byte 0x96
.byte 0x96

@ Unit code
.byte 0x00

@ Device type
.byte 0x00

@ Reserved — 7 bytes
.fill 7, 1, 0

@ Version
.byte 0x00

@ Checksum — gbafix fills this
.byte 0x00

@ Reserved — 2 bytes
.fill 2, 1, 0

@ Verify we are exactly at 0xC0 (192) bytes
.if (. - _gba_entry) != 0xC0
.error "GBA header is not 192 bytes!"
.endif
