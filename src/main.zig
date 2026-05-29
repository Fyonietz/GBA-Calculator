const video = @import("gba/video.zig");
const renderer = @import("gba/renderer.zig");
const keypad = @import("gba/keypad.zig");
const UI = @import("tools.zig").UI;
const State = @import("tools.zig").CalcState;

//CONSTANTS
const SCREEN_WIDTH = 240;
const SCREEN_HEIGHT = 160;
const TILE_WIDTH = undefined;
const TILE_HEIGHT = undefined;

fn CenterHorizontal(width: u32, x: *u32) void {
    x.* = (SCREEN_WIDTH / 8 - width) / 2;
}

export fn _start() noreturn {
    // var calc = State{};
    video.DISPCNT.* = video.DCNT_MODE0 | video.DCNT_BG0;

    video.PAL_BG[0] = renderer.rgb15(0, 0, 0);
    video.PAL_BG[1] = renderer.rgb15(0, 0, 31);
    video.PAL_BG[2] = renderer.rgb15(31, 0, 0);
    video.PAL_BG[3] = renderer.rgb15(31, 31, 31);

    // 256 Color Mode,Tile(64 Bytes) size same as 16 u32 words section
    const tile_data = @as([*]volatile u32, @ptrFromInt(0x06000000));

    const map = video.screenBase(28);
    var i: u32 = 0;
    //pack 4 pixel per u32 : 0x
    //Tile 0 - blue
    while (i < 16) : (i += 1) {
        tile_data[i] = 0x01010101;
    }
    //BorderRect Setup
    var container = UI.BorderRect{ .width = 3, .height = 3, .x = 0, .y = 0, .border_size = 1, .color = 0x02020202, .id = 1, .map = map, .tile_data = tile_data };
    CenterHorizontal(container.width, &container.x);
    i = 0;
    //Tile 1 - red;
    while (i < 16) : (i += 1) {
        container.tile_data[16 + i] = container.color;
    }
    //Setup tile map in screen block 20;
    i = 0;
    while (i < 32 * 32) : (i += 1) {
        map[i] = 0;
    }
    //Init Font
    var c: u32 = 0;
    while (c < 15) : (c += 1) {
        UI.Font.drawChar(tile_data, c + 2, c, 3);
    }

    video.BG0CNT.* = video.bgControl(0, 0, 28, true);
    var display = UI.BorderRect{
        .width = 20,
        .height = 3,
        .border_size = 1,
        .color = 0x02020202,
        .id = 1,
        .map = map,
        .tile_data = tile_data,
        .x = 6,
        .y = 1,
    };
    display.draw();
    var display_value: []const u8 = "0";
    UI.Font.drawText(map, display_value, 7, 2);
    const BUTTONS: [4][4][]const u8 = .{
        .{ "7", "8", "9", "/" },
        .{ "4", "5", "6", "*" },
        .{ "1", "2", "3", "-" },
        .{ "0", "=", "=", "+" },
    };

    const GRID_X: u32 = 9;
    const GRID_Y: u32 = 5;

    var row: u32 = 0;
    while (row < 4) : (row += 1) {
        var col: u32 = 0;
        while (col < 4) : (col += 1) {
            container.x = GRID_X + (col * 4);
            container.y = GRID_Y + (row * 2);
            const tx = container.x + 1; // +1 to center label
            const ty = container.y + 1;
            UI.Font.drawText(map, BUTTONS[row][col], tx, ty);
        }
    }

    var cursor_row: u32 = 0;
    var cursor_col: u32 = 0;
    var input_delay: u32 = 0;
    var delay: u32 = 5;
    var digits: u32 = 0;
    while (true) {
        video.vBlankStart();

        if (input_delay == 0) {
            if (keypad.down(keypad.UP)) {
                if (cursor_row > 0) cursor_row -= 1;
                input_delay = delay;
            }
            if (keypad.down(keypad.DOWN)) {
                if (cursor_row < 3) cursor_row += 1;
                input_delay = delay;
            }
            if (keypad.down(keypad.LEFT)) {
                if (cursor_col > 0) cursor_col -= 1;
                input_delay = delay;
            }
            if (keypad.down(keypad.RIGHT)) {
                if (cursor_col < 3) cursor_col += 1;
                input_delay = delay;
            }
        } else {
            input_delay -= 1;
        }
        // highlight selected button
        row = 0;
        while (row < 4) : (row += 1) {
            var col: u32 = 0;
            while (col < 4) : (col += 1) {
                container.x = GRID_X + (col * 4);
                container.y = GRID_Y + (row * 2);
                container.id = if (row == cursor_row and col == cursor_col) 1 else 0;
                container.draw();
                UI.Font.drawText(map, BUTTONS[row][col], container.x + 1, container.y + 1);
            }
        }
        delay = 10;
        if (input_delay == 0) {
            if (keypad.down(keypad.A)) {
                input_delay = delay;
                digits += 1;
                display_value = BUTTONS[cursor_row][cursor_col];
                UI.Font.drawText(map, display_value, 7 + digits - 1, 2);
                if (digits == 0) {
                    display_value = "0";
                    UI.Font.drawText(map, display_value, 7, 2);
                }
            }

            if (keypad.down(keypad.B)) {
                if (digits != 0) {
                    digits -= 1;
                    display_value = "c";
                    UI.Font.drawText(map, display_value, 7 + digits + 1, 2);
                    input_delay = delay;

                    if (digits == 0) {
                        display_value = "0";
                        UI.Font.drawText(map, display_value, 7, 2);
                    }
                }
            }
        } else {
            input_delay -= 1;
        }

        video.vBlankEnd();
    }
}
