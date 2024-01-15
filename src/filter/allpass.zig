const std = @import("std");

const bonk = @import("../bonk.zig");

pub fn Allpass1stOrder(comptime T: type) type {
    bonk.assertTypeIsSample(T);
    return struct {
        a1: T = 0,
        v_1: T = 0,

        const Self = @This();

        pub inline fn setBreakHz(self: *Self, hz: T, s_rate: T) void {
            self.a1 = hz / s_rate;
        }

        pub inline fn tick(self: *Self, x: T) T {
            const v = x + (self.v_1 * -self.a1);
            self.v_1 = v;
            return self.v_1 + (v * self.a1);
        }

        pub inline fn flush(self: *Self) void {
            self.v_1 = 0;
        }
    };
}

pub fn Allpass2ndOrder(comptime T: type) type {
    bonk.assertTypeIsSample(T);

    return struct {
        c: T = 0.125,
        d: T = 0.022,
        v_1: T = 0,
        v_2: T = 0,

        const Self = @This();

        pub inline fn setBandwidthHz(self: *Self, hz: T, s_rate: T) void {
            const tmp = @tan(std.math.pi * (hz / s_rate));
            self.c = (tmp - 1) / (tmp + 1);
        }

        pub inline fn setBreakHz(self: *Self, hz: T, s_rate: T) void {
            self.d = -@cos(std.math.tau * (hz / s_rate));
        }

        pub inline fn tick(self: *Self, x: T) T {
            const v =
                x +
                (self.v_1 * (-self.d * (1 - self.c))) +
                (self.v_2 * self.c);

            const y =
                (v * -self.c) +
                (self.v_1 * (self.d * (1 - self.c))) +
                self.v_2;

            self.v_2 = self.v_1;
            self.v_1 = v;

            return y;
        }

        pub inline fn flush(self: *Self) void {
            self.v_1 = 0;
            self.v_2 = 0;
        }
    };
}
