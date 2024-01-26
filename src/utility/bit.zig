const std = @import("std");

fn transmute(comptime T: type, v: anytype) T {
    return @as(*T, @ptrCast(@constCast(&v))).*;
}

pub fn pow2ModBitmask(comptime v: anytype) @TypeOf(v) {
    comptime var out_val: @TypeOf(v) = undefined;
    comptime {
        var v_shift = v;
        var bit_index: usize = 0;
        while (v_shift != 0) {
            v_shift >>= 1;
            bit_index += 1;
        }
        const v_bits: usize = @bitSizeOf(@TypeOf(v));
        out_val = std.math.maxInt(usize) >> ((v_bits - bit_index) + 1);
    }
    return out_val;
}

fn maskOfTypeSize(comptime T: type) type {
    return @Type(std.builtin.Type{
        .Int = .{
            .signedness = false,
            .bits = @typeInfo(T).bits,
        },
    });
}

fn getSignBit(v: anytype) maskOfTypeSize(v) {
    const out_T = maskOfTypeSize(@TypeOf(v));
    return ~(std.math.maxInt(out_T) >> 1) & transmute(out_T, v);
}
