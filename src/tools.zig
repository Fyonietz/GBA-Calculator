const Video = @import("gba/video.zig");
const TILE:u32 = 32;
pub const UI = struct {
    //Struct For Making Bordered Rectangle
    pub const BorderRect = struct {
    width:u32,
    height:u32,
    x:u32 = 0,
    y:u32 = 0,
    color:u32,
    id:u16 = 1,
    border_size:u32=1,
    map:[*]volatile u16,
    tile_data:[*]volatile u32 = &.{},
    //Draw Function
        pub fn draw(self:*BorderRect) void {
            var row:u32 = 0;
            while(row < self.height):(row+=1){
                var col:u32 = 0;
                while(col<self.width):(col+=1) {
                    const is_border:bool = 
                            col < self.border_size or
                            col >= self.width - self.border_size or
                            row < self.border_size or
                            row >= self.height - self.border_size;

                    if(is_border){
                        self.map[(self.y + row) * TILE + (self.x+col)] = self.id;  
                    }
                }
            }
        }
    };

    //Function For Draw Pixel Inside 8px Tile
    pub fn drawPixel(tile_data:[*]volatile u32,tile_index:u32,px:u32,py:u32,color:u8) void{
    const byte_offset = (tile_index * 64) + (py * 8) + px;
    const u32_index = byte_offset / 4;
    const shift = (byte_offset % 4) * 8;

    const mask = ~(@as(u32, 0xFF) << @intCast(shift));
    const val = @as(u32, color) << @intCast(shift);

    tile_data[u32_index] = (tile_data[u32_index] & mask) | val;
    }

    pub const Font = struct {
        const Data: [10][8]u8 = .{
            .{0x3C,0x42,0x42,0x42,0x42,0x42,0x42,0x3C}, // 0
            .{0x08,0x18,0x08,0x08,0x08,0x08,0x08,0x1C}, // 1
            .{0x3C,0x42,0x02,0x04,0x18,0x20,0x40,0x7E}, // 2
            .{0x3C,0x42,0x02,0x1C,0x02,0x02,0x42,0x3C}, // 3
            .{0x04,0x0C,0x14,0x24,0x7E,0x04,0x04,0x04}, // 4
            .{0x7E,0x40,0x40,0x7C,0x02,0x02,0x42,0x3C}, // 5
            .{0x3C,0x42,0x40,0x7C,0x42,0x42,0x42,0x3C}, // 6
            .{0x7E,0x02,0x04,0x08,0x10,0x10,0x10,0x10}, // 7
            .{0x3C,0x42,0x42,0x3C,0x42,0x42,0x42,0x3C}, // 8
            .{0x3C,0x42,0x42,0x3E,0x02,0x02,0x42,0x3C}, // 9
        };
        pub fn drawChar(tile_data: [*]volatile u32, tile_index: u32, char_index: u32, fg: u8) void {
            const bitmap = Data[char_index];
            var row: u32 = 0;
            while (row < 8) : (row += 1) {
                var col: u32 = 0;
                while (col < 8) : (col += 1) {
                    const bit = (bitmap[row] >> @intCast(7 - col)) & 1;
                    const color: u8 = if (bit == 1) fg else 0;
                    drawPixel(tile_data, tile_index, col, row, color);
                }
            }
        }
    };
    
};
