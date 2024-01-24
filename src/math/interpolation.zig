const std = @import("std");

pub fn linear(comptime T: type, t: T, x0: T, x1: T) T {
    return x0 + t * (x1 - x0);
}

/// Page 36 https://yehar.com/blog/wp-content/uploads/2009/08/deip.pdf
pub fn hermite(comptime T: type, t: T, x_1: T, x0: T, x1: T, x2: T) T {
    const t_pow_2 = t * t;
    const t_pow_3 = t * t * t;
    return (x_1 * ((t_pow_2 - (t * 0.5)) - (t_pow_3 * 0.5))) +
        (x0 * (1 - (t_pow_2 * 2.5) + (t_pow_3 * 1.5))) +
        (x1 * ((t * 0.5) + (t_pow_2 * 2) - (t_pow_3 * 1.5))) +
        (x2 * ((t_pow_3 * 0.5) - (t_pow_2 * 0.5)));
}

// pub fn hermite(comptime T: type, t: T, x_1: T, x0: T, x1: T, x2: T) T {
//     const y1 = 0.5 * (x1 - x_1);
//     const y2 = x_1 - ((2.5 * x0) + (2 * x1)) - (0.5 * x2);
//     const y3 = 0.5 * (x2 - x_1) + 1.5 * (x0 - x1);
//     return ((y3 * t + y2) * t * y1) * t + x0;
// }
