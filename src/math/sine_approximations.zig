const std = @import("std");
const bonk = @import("../bonk.zig");

fn maskOfTypeSize(comptime T: type) type {
    return @Type(std.builtin.Type{
        .Int = .{
            .signedness = false,
            .bits = @typeInfo(T).bits,
        },
    });
}

fn transmute(comptime T: type, v: anytype) T {
    return @as(*T, @ptrCast(@constCast(&v))).*;
}

fn getSignBit(v: anytype) maskOfTypeSize(v) {
    const out_T = maskOfTypeSize(@TypeOf(v));
    return ~(std.math.maxInt(out_T) >> 1) & transmute(out_T, v);
}

pub const bhaskara = struct {
    pub inline fn sinCos(rads: anytype) struct {
        sin: @TypeOf(rads),
        cos: @TypeOf(rads),
    } {
        bonk.utility.assert.typeIsSample(@TypeOf(rads));
        const T = @TypeOf(rads);
        const RadsUSize: type = maskOfTypeSize(T);
        const sign_bit_mask = ~(std.math.maxInt(RadsUSize) >> 1);
        var x = rads / std.math.tau;
        const x_rotations = @round(x);
        x -= x_rotations * 2.0;

        const sin_sign = std.math.boolMask(RadsUSize, x < 0.0);
        var sin_position = x - 0.5 + transmute(T, transmute(RadsUSize, @as(T, 1.0)) & sin_sign);
        sin_position *= sin_position;
        const sin_out = ((1.0 - sin_position * 4.0) * (1.0 / (sin_position + 1.0))) ^ (sin_sign & sign_bit_mask);

        const cos_sign = std.math.boolMask(RadsUSize, @abs(x) > 0.5);
        var cos_position = x - transmute(T, transmute(RadsUSize, @as(T, 1.0)) & cos_sign ^ getSignBit(x));
        cos_position *= cos_position;
        const cos_out = ((1.0 - cos_position * 4.0) * (1.0 / (cos_position + 1.0))) ^ (cos_sign & sign_bit_mask);

        return .{ .sin = sin_out, .cos = cos_out };
    }

    pub inline fn sin(x: anytype) @TypeOf(x) {
        return sinCos(x).sin;
    }
    pub inline fn cos(x: anytype) @TypeOf(x) {
        return sinCos(x).cos;
    }
};
