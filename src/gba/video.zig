// ============================================================
// src/video.zig — GBA complete video library
// All addresses from GBATEK / gbadoc hardware specification
// ============================================================

// ============================================================
// SECTION 1: Core display registers
// ============================================================

// DISPCNT — display control — 0x04000000
// This is the master switch for everything on screen.
// Write to this first before anything else.
pub const DISPCNT = @as(*volatile u16, @ptrFromInt(0x04000000));

// DISPCNT bit flags
pub const DCNT_MODE0: u16 = 0x0000; // tile mode — 4 BG layers, no rotation
pub const DCNT_MODE1: u16 = 0x0001; // tile mode — BG0+BG1 text, BG2 rotscale
pub const DCNT_MODE2: u16 = 0x0002; // tile mode — BG2+BG3 rotscale only
pub const DCNT_MODE3: u16 = 0x0003; // bitmap 240x160 16-bit, 1 buffer
pub const DCNT_MODE4: u16 = 0x0004; // bitmap 240x160 8-bit palette, 2 buffers
pub const DCNT_MODE5: u16 = 0x0005; // bitmap 160x128 16-bit, 2 buffers

pub const DCNT_GB:     u16 = 1 << 3;  // GBC mode — read only, always 0 on GBA
pub const DCNT_PAGE:   u16 = 1 << 4;  // page select for mode 4/5 (0=frame0, 1=frame1)
pub const DCNT_HBLANK: u16 = 1 << 5;  // allow OAM access during hblank
pub const DCNT_OBJ1D:  u16 = 1 << 6;  // sprite tile layout: 0=2D, 1=1D (sequential)
pub const DCNT_BLANK:  u16 = 1 << 7;  // force screen white/blank (useful during VRAM setup)

pub const DCNT_BG0: u16 = 1 << 8;  // enable background layer 0
pub const DCNT_BG1: u16 = 1 << 9;  // enable background layer 1
pub const DCNT_BG2: u16 = 1 << 10; // enable background layer 2
pub const DCNT_BG3: u16 = 1 << 11; // enable background layer 3
pub const DCNT_OBJ: u16 = 1 << 12; // enable sprites (objects)

pub const DCNT_WIN0: u16 = 1 << 13; // enable window 0
pub const DCNT_WIN1: u16 = 1 << 14; // enable window 1
pub const DCNT_WINOBJ: u16 = 1 << 15; // enable sprite window

// DISPSTAT — display status and interrupt control — 0x04000004
// Read the low bits for current draw state.
// Write the upper bits to enable vblank/hblank/vcount IRQs.
pub const DISPSTAT = @as(*volatile u16, @ptrFromInt(0x04000004));

pub const DSTAT_IN_VBL:  u16 = 1 << 0; // (read) currently in vblank
pub const DSTAT_IN_HBL:  u16 = 1 << 1; // (read) currently in hblank
pub const DSTAT_IN_VCT:  u16 = 1 << 2; // (read) vcount trigger matched
pub const DSTAT_VBL_IRQ: u16 = 1 << 3; // enable vblank interrupt
pub const DSTAT_HBL_IRQ: u16 = 1 << 4; // enable hblank interrupt
pub const DSTAT_VCT_IRQ: u16 = 1 << 5; // enable vcount interrupt
// bits 8-15: vcount trigger line value (write the line number you want IRQ on)

// VCOUNT — current scanline — 0x04000006 — read only
// 0-159   = visible lines being drawn
// 160-227 = vblank (safe to write VRAM here)
pub const VCOUNT = @as(*volatile u16, @ptrFromInt(0x04000006));
//DMA
pub const DMA3SAD  = @as(*volatile u32, @ptrFromInt(0x040000D4)); // source
pub const DMA3DAD  = @as(*volatile u32, @ptrFromInt(0x040000D8)); // destination
pub const DMA3CNT  = @as(*volatile u32, @ptrFromInt(0x040000DC)); // count + control

pub const DMA_ENABLE:  u32 = 1 << 31;
pub const DMA_32BIT:   u32 = 1 << 26; // transfer 32 bits at a time
pub const DMA_FILL:    u32 = 1 << 24; // fixed source (fill mode)
// ============================================================
// SECTION 2: Background control registers
// ============================================================

// BGnCNT — background n control — one register per layer
// BG0: 0x04000008  BG1: 0x0400000A  BG2: 0x0400000C  BG3: 0x0400000E
pub const BG0CNT = @as(*volatile u16, @ptrFromInt(0x04000008));
pub const BG1CNT = @as(*volatile u16, @ptrFromInt(0x0400000A));
pub const BG2CNT = @as(*volatile u16, @ptrFromInt(0x0400000C));
pub const BG3CNT = @as(*volatile u16, @ptrFromInt(0x0400000E));

// BGnCNT bit fields:
// bits 0-1: priority (0=front/highest, 3=back/lowest)
// bits 2-3: character base block — tile pixel data starts at 0x06000000 + block * 0x4000
// bit  6:   mosaic effect on/off
// bit  7:   color mode — 0=16 colors x 16 palettes, 1=256 colors x 1 palette
// bits 8-12: screen base block — tile map starts at 0x06000000 + block * 0x800
// bit  13:  screen overflow (rotscale only) — 0=transparent edges, 1=wrap/tile edges
// bits 14-15: map size (see tables below)

// Map sizes for TEXT backgrounds (mode 0, BG0-BG3):
pub const BG_SIZE_TEXT_256x256: u16 = 0 << 14; // 32x32 tiles
pub const BG_SIZE_TEXT_512x256: u16 = 1 << 14; // 64x32 tiles
pub const BG_SIZE_TEXT_256x512: u16 = 2 << 14; // 32x64 tiles
pub const BG_SIZE_TEXT_512x512: u16 = 3 << 14; // 64x64 tiles

// Map sizes for ROTSCALE backgrounds (mode 1 BG2, mode 2 BG2/BG3):
pub const BG_SIZE_ROT_128x128:   u16 = 0 << 14; // 16x16 tiles
pub const BG_SIZE_ROT_256x256:   u16 = 1 << 14; // 32x32 tiles
pub const BG_SIZE_ROT_512x512:   u16 = 2 << 14; // 64x64 tiles
pub const BG_SIZE_ROT_1024x1024: u16 = 3 << 14; // 128x128 tiles

// Color mode flags for BGnCNT
pub const BG_COLOR_16x16:  u16 = 0 << 7; // 16 colors, 16 sub-palettes per tile
pub const BG_COLOR_256x1:  u16 = 1 << 7; // 256 colors, single palette

// Helper: build a BGnCNT value cleanly
pub inline fn bgControl(
    priority: u2,      // 0-3
    char_base: u2,     // character block 0-3
    screen_base: u5,   // screen block 0-31
    color256: bool,    // true = 256 colors, false = 16x16
    size: u16,         // one of BG_SIZE_TEXT_* or BG_SIZE_ROT_*
) u16 {
    return @as(u16, priority) |
           (@as(u16, char_base) << 2) |
           (@as(u16, screen_base) << 8) |
           (if (color256) @as(u16, 1 << 7) else 0) |
           size;
}

// ============================================================
// SECTION 3: Background scroll registers (text modes only)
// ============================================================

// These are WRITE ONLY — reading gives garbage.
// Setting to N scrolls the background so pixel N appears at left/top edge.
pub const BG0HOFS = @as(*volatile u16, @ptrFromInt(0x04000010)); // BG0 horizontal scroll
pub const BG0VOFS = @as(*volatile u16, @ptrFromInt(0x04000012)); // BG0 vertical scroll
pub const BG1HOFS = @as(*volatile u16, @ptrFromInt(0x04000014));
pub const BG1VOFS = @as(*volatile u16, @ptrFromInt(0x04000016));
pub const BG2HOFS = @as(*volatile u16, @ptrFromInt(0x04000018));
pub const BG2VOFS = @as(*volatile u16, @ptrFromInt(0x0400001A));
pub const BG3HOFS = @as(*volatile u16, @ptrFromInt(0x0400001C));
pub const BG3VOFS = @as(*volatile u16, @ptrFromInt(0x0400001E));

// ============================================================
// SECTION 4: Background affine / rotation+scale registers
// ============================================================

// These apply to BG2 (modes 1 and 2) and BG3 (mode 2).
// They form a 2x2 matrix + offset for rotation, scaling, and shearing.
// All are WRITE ONLY. Values are 8.8 fixed point (except X/Y which are 20.8).

// BG2 affine matrix
pub const BG2PA = @as(*volatile i16, @ptrFromInt(0x04000020)); // dx/dx  (x scale)
pub const BG2PB = @as(*volatile i16, @ptrFromInt(0x04000022)); // dy/dx  (x shear)
pub const BG2PC = @as(*volatile i16, @ptrFromInt(0x04000024)); // dx/dy  (y shear)
pub const BG2PD = @as(*volatile i16, @ptrFromInt(0x04000026)); // dy/dy  (y scale)
pub const BG2X  = @as(*volatile i32, @ptrFromInt(0x04000028)); // reference x (20.8 fixed)
pub const BG2Y  = @as(*volatile i32, @ptrFromInt(0x0400002C)); // reference y (20.8 fixed)

// BG3 affine matrix (same layout, mode 2 only)
pub const BG3PA = @as(*volatile i16, @ptrFromInt(0x04000030));
pub const BG3PB = @as(*volatile i16, @ptrFromInt(0x04000032));
pub const BG3PC = @as(*volatile i16, @ptrFromInt(0x04000034));
pub const BG3PD = @as(*volatile i16, @ptrFromInt(0x04000036));
pub const BG3X  = @as(*volatile i32, @ptrFromInt(0x04000038));
pub const BG3Y  = @as(*volatile i32, @ptrFromInt(0x0400003C));

// Reset affine to identity (no rotation, no scale, no offset)
pub fn bgAffineReset(pa: *volatile i16, pb: *volatile i16, pc: *volatile i16, pd: *volatile i16, x: *volatile i32, y: *volatile i32) void {
    pa.* = 0x0100; // 1.0 in 8.8 fixed point
    pb.* = 0x0000;
    pc.* = 0x0000;
    pd.* = 0x0100; // 1.0 in 8.8 fixed point
    x.*  = 0;
    y.*  = 0;
}

// ============================================================
// SECTION 5: Window registers
// ============================================================

// Windows let you define rectangular regions where certain
// BG/sprite layers appear or disappear. Useful for HUD areas.

pub const WIN0H   = @as(*volatile u16, @ptrFromInt(0x04000040)); // win0 left(8-15) right(0-7)
pub const WIN1H   = @as(*volatile u16, @ptrFromInt(0x04000042));
pub const WIN0V   = @as(*volatile u16, @ptrFromInt(0x04000044)); // win0 top(8-15) bottom(0-7)
pub const WIN1V   = @as(*volatile u16, @ptrFromInt(0x04000046));
pub const WININ   = @as(*volatile u16, @ptrFromInt(0x04000048)); // layers shown INSIDE win0/win1
pub const WINOUT  = @as(*volatile u16, @ptrFromInt(0x0400004A)); // layers shown OUTSIDE windows

// Helper: set a window's bounds in one write
pub inline fn setWin0H(left: u8, right: u8) void {
    WIN0H.* = (@as(u16, left) << 8) | @as(u16, right);
}
pub inline fn setWin0V(top: u8, bottom: u8) void {
    WIN0V.* = (@as(u16, top) << 8) | @as(u16, bottom);
}
pub inline fn setWin1H(left: u8, right: u8) void {
    WIN1H.* = (@as(u16, left) << 8) | @as(u16, right);
}
pub inline fn setWin1V(top: u8, bottom: u8) void {
    WIN1V.* = (@as(u16, top) << 8) | @as(u16, bottom);
}

// WININ / WINOUT bit flags (bits 0-5 = BG0-BG3, OBJ, effects for win0;
//                            bits 8-13 same for win1 in WININ, or outside in WINOUT)
pub const WIN_BG0: u16 = 1 << 0;
pub const WIN_BG1: u16 = 1 << 1;
pub const WIN_BG2: u16 = 1 << 2;
pub const WIN_BG3: u16 = 1 << 3;
pub const WIN_OBJ: u16 = 1 << 4;
pub const WIN_BLD: u16 = 1 << 5; // color special effects inside this window

// ============================================================
// SECTION 6: Mosaic register
// ============================================================

// MOSAIC — 0x0400004C — write only
// Makes BG/sprites look "blocky" by repeating pixels in NxN blocks.
pub const MOSAIC = @as(*volatile u16, @ptrFromInt(0x0400004C));
// bits 0-3:  BG horizontal mosaic size  (0=off, 1=2px blocks, etc.)
// bits 4-7:  BG vertical mosaic size
// bits 8-11: OBJ horizontal mosaic size
// bits 12-15: OBJ vertical mosaic size

pub inline fn setMosaic(bg_h: u4, bg_v: u4, obj_h: u4, obj_v: u4) void {
    MOSAIC.* = @as(u16, bg_h) |
               (@as(u16, bg_v)  << 4) |
               (@as(u16, obj_h) << 8) |
               (@as(u16, obj_v) << 12);
}

// ============================================================
// SECTION 7: Blend / color special effects registers
// ============================================================

pub const BLDCNT   = @as(*volatile u16, @ptrFromInt(0x04000050)); // blend mode and source/target layers
pub const BLDALPHA = @as(*volatile u16, @ptrFromInt(0x04000052)); // alpha blend coefficients
pub const BLDY     = @as(*volatile u16, @ptrFromInt(0x04000054)); // brightness coefficient

// BLDCNT bits 0-5: first target layers  (BG0 BG1 BG2 BG3 OBJ backdrop)
// BLDCNT bits 6-7: blend mode
pub const BLD_OFF:   u16 = 0 << 6; // no blending
pub const BLD_ALPHA: u16 = 1 << 6; // alpha blend first+second target
pub const BLD_WHITE: u16 = 2 << 6; // fade to white
pub const BLD_BLACK: u16 = 3 << 6; // fade to black
// BLDCNT bits 8-13: second target layers

// ============================================================
// SECTION 8: VRAM and palette memory
// ============================================================

// VRAM base — 96 KB total at 0x06000000
pub const VRAM = @as([*]volatile u16, @ptrFromInt(0x06000000));
pub const VRAM8 = @as([*]volatile u8, @ptrFromInt(0x06000000)); // byte access (use carefully)

// Palette RAM — 0x05000000
// First 512 bytes (256 entries) = BG palette
// Next  512 bytes (256 entries) = sprite palette
pub const PAL_BG  = @as([*]volatile u16, @ptrFromInt(0x05000000)); // 256 BG colors
pub const PAL_OBJ = @as([*]volatile u16, @ptrFromInt(0x05000200)); // 256 sprite colors

// OAM — sprite attribute memory — 0x07000000
// 128 sprites x 3 u16 attributes + 1 u16 padding = 8 bytes per sprite
pub const OAM = @as([*]volatile u16, @ptrFromInt(0x07000000));

// Mode 3: single 240x160 16-bit framebuffer
pub const MODE3_VRAM = @as([*]volatile u16, @ptrFromInt(0x06000000));

// Mode 4: two 240x160 8-bit (palette index) framebuffers
pub const MODE4_FRAME0 = @as([*]volatile u8, @ptrFromInt(0x06000000));
pub const MODE4_FRAME1 = @as([*]volatile u8, @ptrFromInt(0x0600A000));

// Mode 5: two 160x128 16-bit framebuffers
pub const MODE5_FRAME0 = @as([*]volatile u16, @ptrFromInt(0x06000000));
pub const MODE5_FRAME1 = @as([*]volatile u16, @ptrFromInt(0x0600A000));

// Tile character data base addresses (used when building BGnCNT)
// Each char block is 16 KB. There are 4 blocks (0x0000-0x3FFF each)
pub const CHAR_BASE_0 = @as([*]volatile u32, @ptrFromInt(0x06000000));
pub const CHAR_BASE_1 = @as([*]volatile u32, @ptrFromInt(0x06004000));
pub const CHAR_BASE_2 = @as([*]volatile u32, @ptrFromInt(0x06008000));
pub const CHAR_BASE_3 = @as([*]volatile u32, @ptrFromInt(0x0600C000));

// Tile screen/map base addresses (used when building BGnCNT)
// Each screen block is 2 KB. There are 32 blocks (0x0000-0x07FF each)
pub inline fn screenBase(block: u5) [*]volatile u16 {
    return @as([*]volatile u16, @ptrFromInt(0x06000000 + @as(u32, block) * 0x800));
}

// ============================================================
// SECTION 9: Color helpers
// ============================================================

// Pack r,g,b (each 0-31) into a 15-bit GBA color word
pub inline fn rgb15(r: u5, g: u5, b: u5) u16 {
    return @as(u16, r) | (@as(u16, g) << 5) | (@as(u16, b) << 10);
}

// Common colors pre-built
pub const COLOR_BLACK:   u16 = rgb15(0,  0,  0);
pub const COLOR_WHITE:   u16 = rgb15(31, 31, 31);
pub const COLOR_RED:     u16 = rgb15(31, 0,  0);
pub const COLOR_GREEN:   u16 = rgb15(0,  31, 0);
pub const COLOR_BLUE:    u16 = rgb15(0,  0,  31);
pub const COLOR_YELLOW:  u16 = rgb15(31, 31, 0);
pub const COLOR_CYAN:    u16 = rgb15(0,  31, 31);
pub const COLOR_MAGENTA: u16 = rgb15(31, 0,  31);

// ============================================================
// SECTION 11: Vsync + timing
// ============================================================

// Wait for vblank — call once per game loop iteration
// This locks your game to exactly 60fps
pub fn vBlankStart() void {
    while (VCOUNT.* < 160) {} // wait until we enter vblank
}
pub fn vBlankEnd() void {
    while (VCOUNT.* >= 160) {} // wait until vblank ends
}
pub fn vsync() void {
    vBlankStart();
    vBlankEnd();
}

// Wait for a specific scanline (useful for raster effects)
pub fn waitLine(line: u16) void {
    while (VCOUNT.* != line) {}
}
