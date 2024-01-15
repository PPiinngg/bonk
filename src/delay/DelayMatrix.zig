const std = @import("std");

const DelayLine = @import("DelayLine.zig").DelayLine;
const InterpolatorType = @import("DelayLine.zig").InterpolatorType;
const bonk = @import("../bonk.zig");

pub fn DelayMatrix(
    comptime T: type,
    comptime max_delay: comptime_int,
    comptime interpolator: InterpolatorType,
    comptime n_delays: usize,
    comptime n_channel_out: bool,
) type {
    bonk.assertTypeIsSample(T);
    return struct {
        delay_lines: [n_delays]DelayLine(T, max_delay, interpolator) = undefined,
        connections: [n_delays][n_delays]T = undefined, // [from][to]
        inputs: [n_delays]T = undefined,
        outputs: [n_delays]T = undefined,

        const Self = @This();

        pub inline fn init(self: *Self) void {
            @memset(&self.connections, 0);
            @memset(&self.inputs, 0);
            @memset(&self.outputs, 0);
            for (self.delay_lines) |dly| dly.init();
        }

        pub inline fn clearBuffers(self: *Self) void {
            for (self.delay_lines) |dly| dly.clearBuffer();
        }

        pub inline fn tick(self: *Self, s: T) if (n_channel_out) [n_delays]T else T {
            var s_fb: [n_delays]T = undefined;
            for (0..n_delays) |i| s_fb[i] = s * self.inputs[i];

            const s_delay: [n_delays]T = undefined;

            for (0..n_delays) |f| { //from
                s_delay[f] = self.delay_lines[f].read();
                for (0..n_delays) |t| //to
                    s_fb[t] += s_delay[f] * self.connections[f][t];
            }

            if (n_channel_out) {
                for (0..n_delays) |i| s_delay[i] *= self.outputs[i];
                return s_delay;
            } else {
                var s_out: T = 0;
                for (0..n_delays) |i| s_out += s_delay[i] * self.outputs[i];
                return s_out;
            }
        }
    };
}
