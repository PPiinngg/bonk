pub const delay = struct {
    pub const DelayLine = @import("delay/DelayLine.zig").DelayLine;
    pub const FeedbackDelayLine = @import("delay/DelayLine.zig").FeedbackDelayLine;
    pub const DelayMatrix = @import("delay/DelayMatrix.zig").DelayMatrix;
};

pub const filter = struct {
    pub const Allpass1 = @import("filter/allpass.zig").Allpass1;
    pub const Allpass2 = @import("filter/allpass.zig").Allpass2;
    pub const Biquad = @import("filter/biquad.zig").Biquad;
    pub const Quadrature = @import("filter/quadrature.zig").Quadrature;
};

pub fn assertTypeIsSample(comptime T: type) void {
    const T_info: @import("std").builtin.Type = @typeInfo(T);
    switch (T_info) {
        .Float => return,
        else => {},
    }
    @compileError("Bad type [" ++ @typeName(T) ++ "]: " ++
        "Bonk's DSP objects currently only work with floats.");
}
