const video = @import("gba/video.zig");
const renderer = @import("gba/renderer.zig");
const keypad = @import("gba/keypad.zig");
export fn _start() noreturn {
    
    video.DISPCNT.* = video.DCNT_MODE0 | video.DCNT_BG0;

    video.PAL_BG[0] = renderer.rgb15(0,0,0);
    video.PAL_BG[1] = renderer.rgb15(0,0,31);
    video.PAL_BG[2] = renderer.rgb15(31,0,0);
    video.PAL_BG[3] = renderer.rgb15(31,31,31);
    
    // 256 Color Mode,Tile(64 Bytes) size same as 16 u32 words section
    const tile_data = @as([*]volatile u32,@ptrFromInt(0x06000000));

    var i:u32 =0;
    //pack 4 pixel per u32 : 0x
    //Tile 0 - blue
    while(i < 16):(i+=1){
        tile_data[i] = 0x01010101;
    }
    
    i = 0;
    //Tile 1 - red;
    while(i < 16) : (i+=1){
        tile_data[16 + i] = 0x02020202; 
    }


    //Setup tile map in screen block 20;
    
    const map = video.screenBase(28);

    i = 0;
    while (i < 32 * 32):(i+=1){
        map[i] = 0 ;
    }
    var pos_x:u32 = 10;
    // var pos_y:u32 = 10;
    // Y * Map Size + X
    map[10 * 32 + pos_x] = 1; // tile index


    video.BG0CNT.* = video.bgControl(0,0,28,true);

    while(true){
        video.vBlankStart();
        if(keypad.down(keypad.RIGHT)){
            pos_x +=1 ;
            map[10 * 32 + pos_x] = 1; // tile index
            map[10 * 32 + (pos_x-1)] = 0; // tile index
        }
        if(keypad.down(keypad.LEFT)){
            pos_x -=1;
            map[10 * 32 + pos_x] = 1; // tile index
            map[10 * 32 + (pos_x+1)] = 0; // tile index
        }
        video.vBlankEnd();
    }
}
