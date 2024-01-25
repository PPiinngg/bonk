const std = @import("std");

// Implementations translated from the below paper by Olli Niemitalo (the GOAT)
// https://yehar.com/blog/wp-content/uploads/2009/08/deip.pdf

pub fn linear(comptime T: type, t: T, x0: T, x1: T) T {
    return x0 + t * (x1 - x0);
}

pub fn hermite(comptime T: type, t: T, x_1: T, x0: T, x1: T, x2: T) T {
    const c1: T = 1.0 / 2.0 * (x1 - x_1);
    const c2: T = x_1 - (5.0 / 2.0) * x0 + 2.0 * x1 - (1.0 / 2.0) * x2;
    const c3: T = 1.0 / 2.0 * (x2 - x_1) + 3.0 / 2.0 * (x0 - x1);
    return ((c3 * t + c2) * t + c1) * t + x0;
}

pub fn lagrange(comptime T: type, t: T, x_1: T, x0: T, x1: T, x2: T) T {
    const c1: T = x1 - 1.0 / 3.0 * x_1 - 1.0 / 2.0 * x0 - 1.0 / 6.0 * x2;
    const c2: T = 1.0 / 2.0 * (x_1 + x1) - x0;
    const c3: T = 1.0 / 6.0 * (x2 - x_1) + 1.0 / 2.0 * (x0 - x1);
    return ((c3 * t + c2) * t + c1) * t + x0;
}

pub fn b_spline(comptime T: type, t: T, x_1: T, x0: T, x1: T, x2: T) T {
    const ym1py1: T = x_1 + x1;
    const c0: T = 1.0 / 6.0 * ym1py1 + 2.0 / 3.0 * x0;
    const c1: T = 1.0 / 2.0 * (x1 - x_1);
    const c2: T = 1.0 / 2.0 * ym1py1 - x0;
    const c3: T = 1.0 / 2.0 * (x0 - x1) + 1.0 / 6.0 * (x2 - x_1);
    return ((c3 * t + c2) * t + c1) * t + c0;
}
