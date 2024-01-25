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

pub const frequency = struct {
    pub const FreqShifter = @import("frequency/FreqShifter.zig").FreqShifter;
};

pub const math = struct {
    pub const interpolation = @import("math/interpolation.zig");
    pub const sine = @import("math/sine.zig");
};

pub const utility = struct {
    pub const assert = @import("utility/assert.zig");
    pub const bit = @import("utility/bit.zig");
};
