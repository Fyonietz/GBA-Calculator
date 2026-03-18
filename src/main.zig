const video = @import("gba/video.zig");
const renderer = @import("gba/renderer.zig");
const keypad = @import("gba/keypad.zig");

export fn _start() noreturn{
    //Display Mode 3 with Background 2
    video.DISPCNT.* = video.DCNT_MODE3 | video.DCNT_BG2;
    const screen_w:u32 = 240;
    const screen_h:u32 = 160;
    var frame_counter:u32 = 0;
    //Color
    const color_white = renderer.rgb15(31,31,31);
    const color_blue =  renderer.rgb15(0,0,31);
    const color_red =  renderer.rgb15(31,0,0);
    var bg_color:u16 =color_white ;
    //Rectangle
    const rect_size:u32 = 8;
    var rect_x:u32 = 120;
    var rect_y:u32 = 80;

    while(true){
        video.vBlankStart();
        frame_counter +=1;
        //Bg Colour Changing
        
        // L Button UnPressed Changing to White (31,31,31)
        if(keypad.up(keypad.L)){
            bg_color =  color_white;
        }

        //L Button Press Changing to Blue (0,0,0)
        if(keypad.down(keypad.L)){
            bg_color = color_blue;
        }

        
        renderer.dmaClear(bg_color);

        renderer.m3FillRect(rect_x,rect_y,rect_size,rect_size,color_red);

        if(frame_counter % 3 == 0){
            if(keypad.down(keypad.UP)){
                rect_y -|=1;
            }
            if(keypad.down(keypad.DOWN)){
                rect_y =@min(rect_y+1,screen_h-rect_size);
            }
            if(keypad.down(keypad.LEFT)){
                rect_x -|=1;
            }
            if(keypad.down(keypad.RIGHT)){
                rect_x =@min(rect_x+1,screen_w-rect_size);
            }

        }

        

        video.vBlankEnd();
    }

}

