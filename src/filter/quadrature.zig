const bonk = @import("../bonk.zig");

// const Biquad = @import("biquad.zig").Biquad;

/// An approximation of a hilbert transformer using cascading 2nd order biquads
pub fn Quadrature(comptime T: type) type {
    bonk.assertTypeIsSample(T);
    return struct {
        pos_ap: [4]QuadratureAllpass = .{ // pos_bq: [4]Biquad(T, 2) = .{
            .{ .a1 = 0.161758 }, // .{ .ff = .{ 0.161758, 0, -1 }, .fb = .{ undefined, 0, -0.161758 } },
            .{ .a1 = 0.733029 }, // .{ .ff = .{ 0.733029, 0, -1 }, .fb = .{ undefined, 0, -0.733029 } },
            .{ .a1 = 0.94535 }, // .{ .ff = .{ 0.94535, 0, -1 }, .fb = .{ undefined, 0, -0.94535 } },
            .{ .a1 = 0.990598 }, // .{ .ff = .{ 0.990598, 0, -1 }, .fb = .{ undefined, 0, -0.990598 } },
        }, // },

        neg_z_1: T = 0,
        neg_ap: [4]QuadratureAllpass = .{ // neg_bq: [4]Biquad(T, 2) = .{
            .{ .a1 = 0.479401 }, // .{ .ff = .{ 0.479401, 0, -1 }, .fb = .{ undefined, 0, -0.479401 } },
            .{ .a1 = 0.876218 }, // .{ .ff = .{ 0.876218, 0, -1 }, .fb = .{ undefined, 0, -0.876218 } },
            .{ .a1 = 0.976599 }, // .{ .ff = .{ 0.976599, 0, -1 }, .fb = .{ undefined, 0, -0.976599 } },
            .{ .a1 = 0.9975 }, // .{ .ff = .{ 0.9975, 0, -1 }, .fb = .{ undefined, 0, -0.9975 } },
        }, // },

        const QuadratureAllpass = struct {
            a1: T,
            v_1: T = 0,
            v_2: T = 0,

            const ApSelf = @This();

            pub inline fn tick(self: *ApSelf, x: T) T {
                const v = x + (self.v_2 * -self.a1);
                self.v_1 = v;
                self.v_2 = self.v_1;
                return self.v_2 + (v * self.a1);
            }

            pub inline fn clear(self: *ApSelf) void {
                self.v_1 = 0;
                self.v_2 = 0;
            }
        };

        const Self = @This();

        pub inline fn clear(self: Self) void {
            for (self.pos_ap) |ap| ap.clear();
            for (self.neg_ap) |ap| ap.clear();
        }

        pub inline fn tick(self: Self, s: T) [2]T {
            var pos_s = s;
            var neg_s = self.neg_z_1;
            defer self.neg_z_1 = s;
            inline for (self.pos_ap) |ap| pos_s = ap.tick(pos_s);
            inline for (self.neg_ap) |ap| neg_s = ap.tick(pos_s);
            return .{ pos_s + neg_s, pos_s - neg_s }; // {real, imag}
        }
    };
}
