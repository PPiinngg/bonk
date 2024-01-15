const std = @import("std");

pub const delay = @import("delay.zig");

pub const filter = struct {
    pub const allpass = @import("filter/allpass.zig");
};

pub fn assertTypeIsSample(comptime T: type) void {
    const T_info: std.builtin.Type = @typeInfo(T);
    switch (T_info) {
        .Float, .ComptimeFloat, .ComptimeInt => return,
        else => {},
    }
    @compileError("Bad type [" ++ @typeName(T) ++ "]: " ++
        "Opal's DSP objects only work with floats or vectors of floats.");
}
