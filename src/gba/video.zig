// video.zig additions for mode 0
pub const DISPCNT  = @as(*volatile u16, @ptrFromInt(0x04000000));
pub const VCOUNT   = @as(*volatile u16, @ptrFromInt(0x04000006));

// display control flags
pub const DCNT_MODE0: u16 = 0x0000;
pub const DCNT_BG0:   u16 = 1 << 8;
pub const DCNT_BG1:   u16 = 1 << 9;
pub const DCNT_BG2:   u16 = 1 << 10;
pub const DCNT_BG3:   u16 = 1 << 11;

// background control registers
pub const BG0CNT = @as(*volatile u16, @ptrFromInt(0x04000008));
pub const BG1CNT = @as(*volatile u16, @ptrFromInt(0x0400000A));
pub const BG2CNT = @as(*volatile u16, @ptrFromInt(0x0400000C));
pub const BG3CNT = @as(*volatile u16, @ptrFromInt(0x0400000E));

// background scroll registers (write only)
pub const BG0HOFS = @as(*volatile u16, @ptrFromInt(0x04000010));
pub const BG0VOFS = @as(*volatile u16, @ptrFromInt(0x04000012));

// palette RAM
pub const PAL_BG  = @as([*]volatile u16, @ptrFromInt(0x05000000));
pub const PAL_OBJ = @as([*]volatile u16, @ptrFromInt(0x05000200));

// VRAM as raw u16 array
pub const VRAM = @as([*]volatile u16, @ptrFromInt(0x06000000));

// char block base addresses (tile pixel data)
// each block = 16 KB = 512 tiles of 8x8 pixels in 4bpp
pub inline fn charBase(block: u2) [*]volatile u32 {
    return @as([*]volatile u32, @ptrFromInt(0x06000000 + @as(u32, block) * 0x4000));
}

// screen block base addresses (tile maps)
// each block = 2 KB = 32x32 tile entries
pub inline fn screenBase(block: u5) [*]volatile u16 {
    return @as([*]volatile u16, @ptrFromInt(0x06000000 + @as(u32, block) * 0x800));
}

// build a BGnCNT value
// char_block: where tile graphics live (0-3)
// screen_block: where tile map lives (0-31)
// color256: true = 256 colors, false = 16 colors x 16 palettes
pub inline fn bgControl(priority: u2, char_block: u2, screen_block: u5, color256: bool) u16 {
    return @as(u16, priority) |
           (@as(u16, char_block) << 2) |
           (@as(u16, screen_block) << 8) |
           (if (color256) @as(u16, 1 << 7) else 0);
}

pub fn vBlankStart() void { while (VCOUNT.* < 160) {} }
pub fn vBlankEnd()   void { while (VCOUNT.* >= 160) {} }
