const video = @import("video.zig");
//dmaClear
pub inline fn dmaClear(color:u32) void {
    // Pack color into a u32 (fills two pixels per transfer)
    const fill: u32 = @as(u32, color) | (@as(u32, color) << 16);

    // We need fill value in memory for DMA to read from
    // Use a static variable so it has a stable address
    const S = struct { var val: u32 = 0; };
    S.val = fill;

    video.DMA3SAD.* = @intFromPtr(&S.val);
    video.DMA3DAD.* = 0x06000000;
    // 240*160 pixels = 38400 pixels / 2 pixels per 32-bit transfer = 19200 transfers
    video.DMA3CNT.* = video.DMA_ENABLE | video.DMA_32BIT | video.DMA_FILL | 19200;

}
//Packing RGB Colour to GBA Colour
pub inline fn rgb15(r:u5,g:u5,b:u5)u16{
    return @as(u16,r) | (@as(u16,g) << 5) | (@as(u16,b) << 10);
}

// Mode 3: draw one pixel at (x, y)
pub inline fn m3Pixel(x: u32, y: u32, color: u16) void {
   video.MODE3_VRAM[y * 240 + x] = color;
}

// Mode 3: fill a rectangle
pub fn m3FillRect(x: u32, y: u32, w: u32, h: u32, color: u16) void {
    var dy: u32 = 0;
    while (dy < h) : (dy += 1) {
        var dx: u32 = 0;
        while (dx < w) : (dx += 1) {
            video.MODE3_VRAM[(y + dy) * 240 + (x + dx)] = color;
        }
    }
}

// Mode 3: clear entire screen to one color
pub fn m3Clear(color: u16) void {
    var i: u32 = 0;
    while (i < 240 * 160) : (i += 1) {
        video.MODE3_VRAM[i] = color;
    }
}

// Mode 4: draw one pixel at (x, y) using palette index
// NOTE: VRAM byte writes must be done as 16-bit aligned pairs on GBA
pub inline fn m4Pixel(x: u32, y: u32, index: u8, frame1: bool) void {
    const base = if (frame1) video.MODE4_FRAME1 else video.MODE4_FRAME0;
    const offset = y * 240 + x;
    // GBA can't write individual bytes to VRAM — must read-modify-write a u16
    const addr = @as([*]volatile u16, @ptrFromInt(@intFromPtr(base) + (offset & ~@as(u32, 1))));
    if (offset & 1 == 0) {
        addr[0] = (addr[0] & 0xFF00) | @as(u16, index);
    } else {
        addr[0] = (addr[0] & 0x00FF) | (@as(u16, index) << 8);
    }
}

// Mode 4: flip to other frame buffer (page flip)
pub fn m4Flip() void {
   video.DISPCNT.* ^= video.DCNT_PAGE;
}

// Mode 5: draw one pixel at (x, y) — resolution 160x128
pub inline fn m5Pixel(x: u32, y: u32, color: u16, frame1: bool) void {
    if (frame1) {
       video.MODE5_FRAME1[y * 160 + x] = color;
    } else {
        video.MODE5_FRAME0[y * 160 + x] = color;
    }
}

// Mode 5: flip page
pub fn m5Flip() void {
    video.DISPCNT.* ^= video.DCNT_PAGE;
}
