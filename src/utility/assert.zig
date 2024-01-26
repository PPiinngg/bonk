const std = @import("std");

pub fn typeIsSample(comptime T: type) void {
    const T_info: std.builtin.Type = @typeInfo(T);
    switch (T_info) {
        .Float => return,
        else => @compileError("Bad type [" ++ @typeName(T) ++ "]: " ++
            "Bonk's DSP objects currently only work with floats."),
    }
}

pub fn intIsPowerOf2(comptime v: anytype) void {
    if (v == 1) @compileError("1 is not a power of 2");
    var ones: usize = 0;
    for (1..@bitSizeOf(@TypeOf(v))) |bit| {
        if (v & (1 << bit) > 1)
            ones += 1;
        if (ones > 1)
            @compileError(
                std.fmt.comptimePrint("{}", .{v}) ++ " is not a power of 2",
            );
    }
}
