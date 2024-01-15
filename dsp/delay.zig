const std = @import("std");

const dsp = @import("dsp.zig");
const sampleCast = dsp.sampleCast;

pub fn DelayLine(
    comptime T: type,
    comptime max_delay: comptime_int,
    comptime interpolator_type: enum {
        Lerp,
        Lagrange3rd,
    },
) type {
    dsp.assertTypeIsSample(T);
    return struct {
        buffer: [max_delay]T = undefined,
        read_head: usize = undefined,
        read_head_fract: T = 0,
        write_head: usize = undefined,

        const Self = @This();

        pub inline fn init(self: *Self) void {
            self.write_head = 0;
            self.setDelaySamples(max_delay);
        }

        pub inline fn setDelaySamples(self: *Self, delay: T) void {
            self.read_head_fract = delay - @floor(delay);
            self.read_head = @mod(self.write_head + max_delay - @as(usize, @intFromFloat(delay)), max_delay);
        }

        pub inline fn setDelayMs(self: *Self, delay: T, samplerate: T) void {
            self.setDelaySamples((samplerate / 1000) * delay);
        }

        pub inline fn setDelayHz(self: *Self, delay: T, samplerate: T) void {
            self.setDelaySamples(samplerate / delay);
        }

        pub inline fn clearBuffer(self: *Self) void {
            @memset(&self.buffer, 0);
        }

        pub inline fn tick(self: *Self, s: T) T {
            defer {
                self.buffer[self.write_head] = s;
                self.buffer[self.write_head] += self.buffer[self.read_head] * self.feedback;

                self.read_head = @mod(self.read_head + 1, max_delay);
                self.write_head = @mod(self.write_head + 1, max_delay);
            }
            switch (interpolator_type) {
                .Lerp => {
                    const v1 = self.buffer[self.read_head];
                    const v2 = self.buffer[@mod(self.read_head + max_delay - 1, max_delay)];
                    return interpolator.lerp(T, self.read_head_fract, v1, v2);
                },
                .Lagrange3rd => {
                    const v1 = self.buffer[self.read_head];
                    const v2 = self.buffer[@mod(self.read_head + max_delay - 1, max_delay)];
                    const v3 = self.buffer[@mod(self.read_head + max_delay - 2, max_delay)];
                    const v4 = self.buffer[@mod(self.read_head + max_delay - 3, max_delay)];
                    return interpolator.lagrange3rd(T, self.read_head_fract, v1, v2, v3, v4);
                },
            }
        }
    };
}

const interpolator = struct {
    pub inline fn lerp(comptime T: type, t: T, v1: T, v2: T) T {
        return v1 + t * (v2 - v1);
    }
    pub inline fn lagrange3rd(comptime T: type, t: T, v1: T, v2: T, v3: T, v4: T) T {
        const d1 = t - 1;
        const d2 = t - 2;
        const d3 = t - 3;

        const c1 = -d1 * d2 * d3 / 6;
        const c2 = d2 * d3 * 0.5;
        const c3 = -d1 * d3 * 0.5;
        const c4 = d1 * d2 / 6;

        return v1 * c1 + t * (v2 * c2 + v3 * c3 + v4 * c4);
    }
};
