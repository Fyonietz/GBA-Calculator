//Register
pub const KEYINPUT = @as(*volatile u16,@ptrFromInt(0x04000130));

//Key Mask
pub const A     =1 << 0;
pub const B     =1 << 1; 
pub const SELECT=1 << 2; 
pub const START =1 << 3;
pub const RIGHT =1 << 4;
pub const LEFT  =1 << 5;
pub const UP    =1 << 6;
pub const DOWN  =1 << 7;
pub const R     =1 << 8;
pub const L     =1 << 9;

//Key Event
pub inline fn down(key:u16) bool {
    return (KEYINPUT.* & key) == 0;
}

pub inline fn up(key:u16) bool  {
    return (~KEYINPUT.* & key) == 0;
}
