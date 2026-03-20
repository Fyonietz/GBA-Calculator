const video = @import("video.zig");
//dmaClear
pub inline fn dmaClear(color: u16) void {
    // Pack two 16-bit pixels into one 32-bit word
    const fill_val: u32 = @as(u32, color) | (@as(u32, color) << 16);
    
    // We use a static to ensure the address is in IWRAM/EWRAM, not a register
    const S = struct { var val: u32 = 0; };
    S.val = fill_val;

    video.DMA3SAD.* = @intFromPtr(&S.val);
    video.DMA3DAD.* = 0x06000000;
    
    // DMA_SOURCE_FIXED (0x01000000) is CRITICAL here. 
    // It tells DMA: "Keep reading from the same address (S.val)"
    // Otherwise, it reads S.val, then S.val + 4, then S.val + 8... (Garbage!)
    const DMA_SOURCE_FIXED = 0x01000000; 
    
    video.DMA3CNT.* = video.DMA_ENABLE | video.DMA_32BIT | DMA_SOURCE_FIXED | 19200;

    // Optional: If the bug persists, add a small assembly 'nop' or 
    // check the DMA_ENABLE bit to wait until it's finished.
    while ((video.DMA3CNT.* & video.DMA_ENABLE) != 0) {}
}
pub fn waitDMA() void {
    while(video.DMA3CNT.* & (1 << 15) != 0) {}
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
