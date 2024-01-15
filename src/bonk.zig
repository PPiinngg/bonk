pub const delay = struct {
    pub const DelayLine = @import("delay/DelayLine.zig").DelayLine;
    pub const FeedbackDelayLine = @import("delay/DelayLine.zig").FeedbackDelayLine;
};

pub const filter = struct {
    pub const allpass = @import("filter/allpass.zig");
};

pub fn assertTypeIsSample(comptime T: type) void {
    const T_info: @import("std").builtin.Type = @typeInfo(T);
    switch (T_info) {
        .Float => return,
        else => {},
    }
    @compileError("Bad type [" ++ @typeName(T) ++ "]: " ++
        "Opal's DSP objects only work with floats.");
}
