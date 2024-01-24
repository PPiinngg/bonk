const std = @import("std");

const bonk = @import("../bonk.zig");

/// https://en.wikipedia.org/wiki/Digital_biquad_filter
pub fn Biquad(comptime T: type, order: comptime_int) type {
    bonk.assertTypeIsSample(T);
    if (order == 0) @compileError("A 0th order biquad is not a thing");
    return struct {
        ff: [order + 1]T, // feedforward
        fb: [order + 1]T, // feedback
        z_: [order]T = 0,

        const Self = @This();

        pub inline fn clear(self: Self) void {
            @memset(self.z_, 0);
        }

        pub inline fn tick(self: Self, s: T) T {
            const xb0z_1 = (s * self.ff[0]) + self.z_[0];

            inline for (0..order - 1) |i| {
                self.z_[i] = self.z_[i + 1];
                self.z_[i] += s * self.ff[i + 1];
                self.z_[i] += xb0z_1 * self.fb[i + 1];
            }
            self.z_[order - 1] = s * self.ff[order];
            self.z_[order - 1] += xb0z_1 * self.fb[order];

            return xb0z_1;
        }
    };
}
