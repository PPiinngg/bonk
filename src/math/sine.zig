const std = @import("std");
const bonk = @import("../bonk.zig");

const assert = bonk.utility.assert;
const bit = bonk.utility.bit;
const interpolation = @import("interpolation.zig");

pub fn SinTable(comptime T: type, comptime size: comptime_int) type {
    comptime assert.typeIsSample(T);
    comptime assert.intIsPowerOf2(@as(usize, size));
    return struct {
        pub fn sin(x: T) T {
            return CosTable(T, size).cos(x - (std.math.pi / 2.0));
        }
    };
}

pub fn CosTable(comptime T: type, comptime size: comptime_int) type {
    comptime assert.typeIsSample(T);
    comptime assert.intIsPowerOf2(@as(usize, size));
    return struct {
        const table: [size]T = generateCosLut(T, size);
        const T_len: usize = table.len;
        const bitmask: isize = @as(*isize, @ptrCast(@constCast(&bit.pow2ModBitmask(@as(usize, size))))).*;
        const normaliser = calculateNormaliser(T, size, table);

        pub inline fn cos(x: T) T {
            const scalar = comptime (1.0 / std.math.tau) * size;
            const x_scaled = @abs(x) * scalar;
            const idx_float = @trunc(x_scaled);
            var idx: isize = @intFromFloat(idx_float);
            idx += size;

            const ix_1: usize = @as(*usize, @ptrCast(@constCast(&((idx - 1) & bitmask)))).*;
            const ix0: usize = @as(*usize, @ptrCast(@constCast(&(idx & bitmask)))).*;
            const ix1: usize = @as(*usize, @ptrCast(@constCast(&((idx + 1) & bitmask)))).*;
            const ix2: usize = @as(*usize, @ptrCast(@constCast(&((idx + 2) & bitmask)))).*;
            const t = x_scaled - idx_float;

            return interpolation.b_spline(T, t, table[ix_1], table[ix0], table[ix1], table[ix2]) * normaliser;
        }
    };
}

inline fn calculateNormaliser(comptime T: type, comptime size: comptime_int, table: [size]T) T {
    const v = interpolation.b_spline(T, 0.0, table[size - 1], table[0], table[1], table[2]);
    return 1.0 / v;
}

inline fn generateCosLut(comptime T: type, comptime size: comptime_int) [size]T {
    var temp_lut: [size]T = undefined;
    const step: T = std.math.tau / @as(T, @floatFromInt(size));

    @setEvalBranchQuota(std.math.maxInt(u32));
    for (0..size) |i| {
        const T_i = @as(T, @floatFromInt(i));
        temp_lut[i] = @cos(step * T_i);
    }

    return temp_lut;
}
