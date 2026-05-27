const video = @import("gba/video.zig");
const renderer = @import("gba/renderer.zig");
const keypad = @import("gba/keypad.zig");
const UI = @import("tools.zig").UI;

//CONSTANTS
const SCREEN_WIDTH = 240;
const SCREEN_HEIGHT = 160;
const TILE_WIDTH = undefined;
const TILE_HEIGHT= undefined;

fn CenterHorizontal(width:u32,x:*u32) void{
    x.* = (SCREEN_WIDTH / 8 - width) / 2;
}

export fn _start() noreturn {
    
    video.DISPCNT.* = video.DCNT_MODE0 | video.DCNT_BG0;

    video.PAL_BG[0] = renderer.rgb15(0,0,0);
    video.PAL_BG[1] = renderer.rgb15(0,0,31);
    video.PAL_BG[2] = renderer.rgb15(31,0,0);
    video.PAL_BG[3] = renderer.rgb15(31,31,31);
    
    // 256 Color Mode,Tile(64 Bytes) size same as 16 u32 words section
    const tile_data = @as([*]volatile u32,@ptrFromInt(0x06000000));

    const map = video.screenBase(28);
    var i:u32 =0;
    //pack 4 pixel per u32 : 0x
    //Tile 0 - blue
    while(i < 16):(i+=1){
        tile_data[i] = 0x01010101;
    }
    //BorderRect Setup
    var container = UI.BorderRect{
        .width = 3,
        .height = 3,
        .x = 0,
        .y = 0,
        .border_size = 1,
        .color = 0x02020202,
        .id = 1,
        .map = map,
        .tile_data = tile_data
    };
    CenterHorizontal(container.width,&container.x);
    i = 0;
    //Tile 1 - red;
    while(i < 16) : (i+=1){
        container.tile_data[16 + i]=container.color;
    }
    //Setup tile map in screen block 20;
    i = 0;
    while (i < 32 * 32):(i+=1){
        map[i] = 0 ;
    }
    video.BG0CNT.* = video.bgControl(0,0,28,true);
    map[0] = 2;
    UI.Font.drawChar(tile_data, 2, 9 , 3);
    while(true){
        video.vBlankStart();

        container.draw();

        video.vBlankEnd();
    }
    
}
