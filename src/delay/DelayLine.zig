const std = @import("std");

const bonk = @import("../bonk.zig");

pub fn DelayLine(
    comptime T: type,
    comptime max_delay: comptime_int,
    comptime interpolator: InterpolatorType,
) type {
    bonk.assertTypeIsSample(T);
    return struct {
        buffer: [max_delay]T = undefined,
        read_head: usize = undefined,
        read_head_fract: T = 0,
        write_head: usize = undefined,

        const Self = @This();

        pub inline fn init(self: *Self) void {
            @memset(self.buffer, 0);
            self.write_head = 0;
            self.setDelaySamples(max_delay / 2);
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

        inline fn getSampleAtDelayPlus(self: *Self, offset: isize) T {
            return self.buffer[@mod(self.read_head + max_delay - offset, max_delay)];
        }

        pub inline fn readWriteTick(self: *Self, s: T) T {
            defer tick();
            defer write(s);
            return self.read();
        }

        pub inline fn tick(self: *Self) void {
            self.read_head = @mod(self.read_head + 1, max_delay);
            self.write_head = @mod(self.write_head + 1, max_delay);
        }

        pub inline fn write(self: *Self, s: T) void {
            self.buffer[self.write_head] = s;
        }

        pub inline fn read(self: *Self) T {
            switch (interpolator) {
                .Lerp => {
                    const v1 = self.buffer[self.read_head];
                    const v2 = getSampleAtDelayPlus(1);
                    return interpolators.lerp(T, self.read_head_fract, v1, v2);
                },
                .Lagrange3rd => {
                    const v1 = self.buffer[self.read_head];
                    const v2 = getSampleAtDelayPlus(1);
                    const v3 = getSampleAtDelayPlus(2);
                    const v4 = getSampleAtDelayPlus(3);
                    return interpolators.lagrange3rd(T, self.read_head_fract, v1, v2, v3, v4);
                },
            }
        }
    };
}

pub fn FeedbackDelayLine(
    comptime T: type,
    comptime max_delay: comptime_int,
    comptime interpolator: InterpolatorType,
) type {
    bonk.assertTypeIsSample(T);
    return struct {
        delay_line: DelayLine(T, max_delay, interpolator) = undefined,
        feedback: T = 0,

        const Self = @This();

        pub inline fn init(self: *Self) void {
            self.delay_line.init();
        }

        pub inline fn setDelaySamples(self: *Self, delay: T) void {
            self.delay_line.setDelaySamples(delay);
        }

        pub inline fn setDelayMs(self: *Self, delay: T, samplerate: T) void {
            self.delay_line.setDelayMs(delay, samplerate);
        }

        pub inline fn setDelayHz(self: *Self, delay: T, samplerate: T) void {
            self.delay_line.setDelayHz(delay, samplerate);
        }

        pub inline fn clearBuffer(self: *Self) void {
            self.delay_line.clearBuffer();
        }

        pub inline fn tick(self: *Self, s: T) T {
            defer {
                self.delay_line.buffer[self.delay_line.read_head] *= self.feedback;
                self.delay_line.buffer[self.delay_line.read_head] += s;

                self.delay_line.tick();
            }
            return self.delay_line.read();
        }
    };
}

pub const InterpolatorType = enum {
    Lerp,
    Lagrange3rd,
};
const interpolators = struct {
    pub inline fn lerp(comptime T: type, t: T, v1: T, v2: T) T {
        return v1 + t * (v2 - v1);
    }
    pub inline fn lagrange3rd(comptime T: type, t: T, v1: T, v2: T, v3: T, v4: T) T {
        // TODO: brush up on maths so i can actually understand what's going on here,
        // i just nicked this from juce so i could have anything other than lerp for now
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
