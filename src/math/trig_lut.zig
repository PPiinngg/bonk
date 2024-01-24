const std = @import("std");
// const bonk = @import("../bonk.zig");

const interpolation = @import("interpolation.zig");

pub fn SinTable(comptime T: type, comptime size: comptime_int) type {
    // comptime bonk.assertTypeIsSample(T);
    return struct {
        const tbl: [size]T = generate_lut(T, .Sin, size);
        const T_len: usize = tbl.len;

        pub inline fn sin(x: T) T {
            const scalar = comptime (1.0 / std.math.tau) * (size - 1);
            const x_scaled = x * scalar;
            const x_floor = @floor(x_scaled);
            const x_floor_int: isize = @intFromFloat(x_floor);

            const ix_1: usize = @intCast(@mod(x_floor_int - 1, size));
            _ = ix_1;
            const ix0: usize = @intCast(@mod(x_floor_int, size));
            const ix1: usize = @intCast(@mod(x_floor_int + 1, size));
            const ix2: usize = @intCast(@mod(x_floor_int + 2, size));
            _ = ix2;
            const t = x_scaled - x_floor;

            // return interpolation.hermite(T, t, tbl[ix_1], tbl[ix0], tbl[ix1], tbl[ix2]);
            return interpolation.linear(T, t, tbl[ix0], tbl[ix1]);
        }
    };
}

inline fn generate_lut(
    comptime T: type,
    comptime function: enum {
        Sin,
        Cos,
        Tan,
    },
    comptime size: comptime_int,
) [size]T {
    var temp_lut: [size]T = undefined;
    const step: T = std.math.tau / @as(T, @floatFromInt(size));

    @setEvalBranchQuota(std.math.maxInt(u32));
    for (0..size) |i| {
        const T_i = @as(T, @floatFromInt(i));
        temp_lut[i] = switch (function) {
            .Sin => @sin(step * T_i),
            .Cos => @cos(step * T_i),
            .Tan => @tan(step * T_i),
        };
    }

    return temp_lut;
}

test "SinTable accuracy" {
    const test_sin = struct {
        fn amp2db(comptime T: type, x: T) T {
            return 20 * @log10(x);
        }

        fn test_sin(comptime T: type, comptime size: comptime_int) void {
            const step_count: comptime_float = 10000;
            const step_size: T = std.math.tau / step_count;
            const sin = SinTable(T, size).sin;
            var max_error: T = 0;
            var avg_error: T = 0;
            for (0..step_count) |step| {
                const rads = step_size * @as(T, @floatFromInt(step));
                const cur_error = @abs(@sin(rads) - sin(rads));
                max_error = @max(max_error, cur_error);
                avg_error += cur_error;
                std.debug.print("{d:.8}, {}\n", .{ amp2db(T, cur_error), step });
            }
            // std.debug.print(
            //     "\n[{s} | {}] .... MaxErr: {d:.8} ({d:.2} dB) .... AvgErr: {d:.8} ({d:.2} dB)",
            //     .{
            //         @typeName(T),
            //         size,
            //         max_error,
            //         amp2db(T, max_error),
            //         avg_error / step_count,
            //         amp2db(T, avg_error / step_count),
            //     },
            // );
            // std.debug.print("{}, {d:.0}\n", .{ size, amp2db(T, avg_error / step_count) });
        }
    }.test_sin;
    std.debug.print("\n", .{});

    // inline for (4..16) |i| test_sin(f32, 1 << i);
    test_sin(f32, 1 << 4);

    std.debug.print("\n", .{});
}
