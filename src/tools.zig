const Video = @import("gba/video.zig");
const TILE:u32 = 32;
pub const UI = struct {
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
};
