const std = @import("std");

const bonk = @import("../bonk.zig");

pub fn FreqShifter(comptime T: type) T {
    return struct {
        quadrature: bonk.filter.Quadrature(T) = .{},
        phasor: T = 0,
        phasor_step: T = 0,

        const Self = @This();

        pub inline fn setShiftHz(self: Self, hz: T, samplerate: T) void {
            self.phasor_step = std.math.tau / (samplerate / hz);
        }

        /// This is separate from `tick` in order to be run only at the
        /// beginning of a buffer for the sake of performance
        pub inline fn phasorMod(self: Self) void {
            self.phasor = @mod(self.phasor, std.math.tau);
        }

        /// Returns a struct containing positive and negative sideband
        /// samples
        pub inline fn tick(self: Self, s: T) struct { pos: T, neg: T } {
            defer self.phasor += self.phasor_step;
            const s_quad = self.quadrature.tick(s);
            const add45 = s_quad[0];
            const sub45 = s_quad[1];
            const cos = bonk.math.sine.CosTable(T, 32).cos(self.phasor);
            const sin = bonk.math.sine.SinTable(T, 32).sin(self.phasor);
            return .{
                .pos = add45 * sin + sub45 * cos,
                .neg = add45 * cos + sub45 * sin,
            };
        }
    };
}
