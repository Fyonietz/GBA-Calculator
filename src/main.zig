const REG_DISPCNT = @as(*volatile u16, @ptrFromInt(0x04000000));
const REG_BG0CNT  = @as(*volatile u16, @ptrFromInt(0x04000008));
const REG_VCOUNT  = @as(*volatile u16, @ptrFromInt(0x04000006));
const PALETTE_RAM = @as([*]volatile u16, @ptrFromInt(0x05000000));

fn getCharBlock(block: u32) [*]volatile u16 { return @ptrFromInt(0x06000000 + (block * 0x4000)); }
fn getScreenBlock(block: u32) [*]volatile u16 { return @ptrFromInt(0x06000000 + (block * 0x800)); }

export fn _start() void {
    // 1. Crayon Box
    PALETTE_RAM[0] = 0x0000; // Black (Empty)
    PALETTE_RAM[1] = 0x03E0; // Green
    PALETTE_RAM[2] = 0x7FFF; // White

    const char0 = getCharBlock(0);

    // 2. Tile 0: The "Empty" Stamp (All Zeros/Black)
    var t: u32 = 0;
    while (t < 16) : (t += 1) { char0[t] = 0x0000; }

    // 3. Tile 1: The "Green Rectangle" Stamp
    const rect_tile = [16]u16{
        0x2222, 0x2222, // 1 White 
        0x1111, 0x1111, // 2 Green
        0x2222, 0x2222, // 3 White
        0x1111, 0x1111, // 4 Green
        0x2222, 0x2222, // 5 White
        0x1111, 0x1111, // 6 Green
        0x2222, 0x2222, // 7 White
        0x1111, 0x1111, // 8 Green
    };
    for (rect_tile, 0..) |data, i| { char0[16 + i] = data; }

    // 4. Setup the Map
    const map31 = getScreenBlock(31);
    
    // FIRST: Fill everything with Tile 0 (The Black/Empty one)
    var i: u32 = 0;
    while (i < 32 * 32) : (i += 1) { map31[i] = 0; }

    // SECOND: Place only ONE Tile 1 in the middle
    // Screen is 30 tiles wide, 20 high. Middle is ~ (15, 10)
    const tx = 15;
    const ty = 10;
    map31[ty * 32 + tx] = 1; // Use the ID of our green tile

    // 5. Turn it on
    REG_BG0CNT.* = (31 << 8); 
    REG_DISPCNT.* = 0x0100;

    while (true) { vsync(); }
}

pub fn vsync() void {
    while (REG_VCOUNT.* >= 160) {}
    while (REG_VCOUNT.* < 160) {}
}
