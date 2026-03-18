//Register
pub const KEYINPUT = @as(*volatile u16,@ptrFromInt(0x04000130));

//Key Mask
pub const A     =0x001;
pub const B     =0x002; 
pub const SELECT=0x004; 
pub const START =0x008;
pub const RIGHT =0x010;
pub const LEFT  =0x020;
pub const UP    =0x040;
pub const DOWN  =0x080;
pub const R     =0x100;
pub const L     =0x200;

//Key Event
pub inline fn down(key:u16) bool {
    return (KEYINPUT.* & key) == 0;
}

pub inline fn up(key:u16) bool  {
    return (~KEYINPUT.* & key) == 0;
}
