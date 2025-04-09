/// Module: Int32
/// This module provides operations for 32-bit signed integers.

module int::int32;

const OverFlowError: u64 = 1;
const OutofBoundError: u64 = 2;
const DivisionByZeroError: u64 = 3;
const NegativeMod: u64 = 4;

const BIT_SIZE: u8 = 32;

/// Maximum magnitude for a 32-bit signed integer
/// magnitude of a => |a| eg |-2| = 2
const MAX_MAGNITUDE: u32 = 1 << (BIT_SIZE - 1); // 2^31

/// Maximum unsigned number representable as 32-bit
const LIMIT: u32 = MAX_MAGNITUDE + (MAX_MAGNITUDE - 1);

/// Maximum positive integer (2^31 - 1)
const MAX_POSITIVE_INT32: u32 = MAX_MAGNITUDE - 1;

/// Minimum negative integer (-2^31)
const MIN_NEGATIVE_INT32: u32 = MAX_MAGNITUDE;

public struct Int32 has copy, drop, store {
    rep: u32,
}

/// Create Int32 type functions
public fun from_raw_bits(bits: u32): Int32 {
    return Int32 { rep: bits }
}

public fun from_u32(magnitude: u32): Int32 {
    try_from_u32(magnitude).extract()
}

public fun try_from_u32(magnitude: u32): Option<Int32> {
    if (magnitude > MAX_POSITIVE_INT32) {
        option::none()
    } else {
        option::some(Int32 { rep: magnitude })
    }
}

public fun new(magnitude: u32, is_positive: bool): Int32 {
    try_new(magnitude, is_positive).extract()
}

public fun try_new(magnitude: u32, is_positive: bool): Option<Int32> {
    if (magnitude > MIN_NEGATIVE_INT32) {
        return option::none()
    };
    if (is_positive) {
        if (magnitude > MAX_POSITIVE_INT32) {
            return option::none()
        };
        option::some(Int32 { rep: magnitude })
    } else {
        let twos_comp_rep = to_2s_complement(magnitude);
        option::some(Int32 { rep: twos_comp_rep })
    }
}

/// Convert from type functions
public fun to_u32(a: Int32): u32 {
    try_to_u32(a).extract()
}

public fun try_to_u32(a: Int32): Option<u32> {
    if (a.rep > MAX_POSITIVE_INT32) {
        option::none()
    } else {
        option::some(a.rep)
    }
}

public fun raw_bits(a: Int32): u32 {
    return a.rep
}

/// Comparison Operations
public fun max(a: Int32, b: Int32): Int32 {
    let rep = max_int32(a.rep, b.rep);
    Int32 { rep }
}

public fun min(a: Int32, b: Int32): Int32 {
    let rep = min_int32(a.rep, b.rep);
    Int32 { rep }
}

public fun lt(a: Int32, b: Int32): bool {
    if (a == b) { return false };
    a == min(a, b)
}

public fun gt(a: Int32, b: Int32): bool {
    if (a == b) { return false };
    a == max(a, b)
}

public fun lteq(a: Int32, b: Int32): bool { a == min(a, b) }

public fun gteq(a: Int32, b: Int32): bool { a == max(a, b) }

public fun eq(a: Int32, b: Int32): bool {
    a.rep == b.rep
}

public fun is_zero(a: Int32): bool {
    a.rep == 0
}

public fun is_positive(a: Int32): bool {
    is_positive_int32(a.rep)
}

public fun is_negative(a: Int32): bool {
    is_negative_int32(a.rep)
}

public fun is_nat(a: Int32): bool {
    return a.rep > 0 && a.rep < MIN_NEGATIVE_INT32
}

/// Operations on Int32 type
public fun shl(x: Int32, shift: u8): Int32 {
    let rep = x.rep << shift;
    return Int32 { rep }
}

public fun shr(x: Int32, shift: u8): Int32 {
    let rep = shr_int32(x.rep, shift);
    return Int32 { rep }
}

public fun abs(a: &Int32): Int32 {
    assert!(a.rep != MIN_NEGATIVE_INT32, OutofBoundError);
    if (is_positive_int32(a.rep)) {
        Int32 { rep: a.rep }
    } else {
        let rep = to_2s_complement(a.rep);
        Int32 { rep }
    }
}

public fun neg(a: Int32): Int32 {
    assert!(a.rep != MIN_NEGATIVE_INT32, OutofBoundError);
    let rep = to_2s_complement(a.rep);
    Int32 { rep }
}

/// Arithmetic Operations
public fun add(a: Int32, b: Int32): Int32 {
    let rep = add_int32(a.rep, b.rep);
    Int32 { rep }
}

public fun try_add(a: Int32, b: Int32): Option<Int32> {
    let mut rep = try_add_int32(a.rep, b.rep);

    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int32 { rep: (&mut rep).extract() })
}

public fun sub(a: Int32, b: Int32): Int32 {
    let rep = sub_int32(a.rep, b.rep);
    Int32 { rep }
}

public fun try_sub(a: Int32, b: Int32): Option<Int32> {
    let mut rep = try_sub_int32(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int32 { rep: (&mut rep).extract() })
}

public fun mul(a: Int32, b: Int32): Int32 {
    let rep = mul_int32(a.rep, b.rep);
    Int32 { rep }
}

public fun try_mul(a: Int32, b: Int32): Option<Int32> {
    let mut rep = try_mul_int32(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int32 { rep: (&mut rep).extract() })
}

public fun div(a: Int32, b: Int32): Int32 {
    assert!(b.rep != 0, DivisionByZeroError);
    let rep = div_int32(a.rep, b.rep);
    Int32 { rep }
}

public fun try_div(a: Int32, b: Int32): Option<Int32> {
    assert!(b.rep != 0, DivisionByZeroError);
    let mut rep = try_div_int32(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int32 { rep: (&mut rep).extract() })
}

public fun mod(a: Int32, b: Int32): Int32 {
    let rep = mod_int32(a.rep, b.rep);
    Int32 { rep }
}

/// Internal helper functions
fun max_int32(a: u32, b: u32): u32 {
    if (is_positive_int32(a) && is_positive_int32(b)) {
        max_value(a, b)
    } else if (is_negative_int32(a) && is_negative_int32(b)) {
        max_value(a, b)
    } else {
        min_value(a, b)
    }
}

fun min_int32(a: u32, b: u32): u32 {
    if (is_positive_int32(a) && is_positive_int32(b)) {
        min_value(a, b)
    } else if (is_negative_int32(a) && is_negative_int32(b)) {
        min_value(a, b)
    } else {
        max_value(a, b)
    }
}

fun mul_int32(a: u32, b: u32): u32 {
    let mut result = try_mul_int32(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_mul_int32(a: u32, b: u32): Option<u32> {
    if (is_positive_int32(a) && is_positive_int32(b)) {
        if (safe_multiply(a, b)) {
            return option::some(a * b)
        };
    } else if (is_negative_int32(a) && is_negative_int32(b)) {
        let a_neg = to_2s_complement(a);
        let b_neg = to_2s_complement(b);
        if (safe_multiply(a_neg, b_neg)) {
            let result = a_neg * b_neg;
            return option::some(result)
        }
    } else if (is_negative_int32(b)) {
        let b_neg = to_2s_complement(b);
        if (safe_multiply_polar(a, b_neg)) {
            return option::some(to_2s_complement(a * b_neg))
        }
    } else {
        let a_neg = to_2s_complement(a);
        if (safe_multiply_polar(b, a_neg)) {
            return option::some(to_2s_complement(a_neg * b))
        }
    };
    return option::none()
}

fun safe_multiply(a: u32, b: u32): bool {
    return MAX_POSITIVE_INT32 / a >= b
}

fun safe_multiply_polar(a: u32, b: u32): bool {
    return MIN_NEGATIVE_INT32 / a >= b
}

fun div_int32(a: u32, b: u32): u32 {
    let mut result = try_div_int32(a, b);
    if (option::is_none(&result)) {
        abort OutofBoundError
    };
    result.extract()
}

fun try_div_int32(a: u32, b: u32): Option<u32> {
    if (is_positive_int32(a) && is_positive_int32(b)) {
        return option::some(a / b)
    } else if (is_negative_int32(a) && is_negative_int32(b)) {
        let result = to_2s_complement(a) / to_2s_complement(b);
        if (is_negative_int32(result)) {
            return option::none()
        };
        option::some(result)
    } else if (is_negative_int32(b)) {
        let magnitude = a / to_2s_complement(b);
        option::some(to_2s_complement(magnitude))
    } else {
        let magnitude = to_2s_complement(a) / b;
        option::some(to_2s_complement(magnitude))
    }
}

fun sub_int32(a: u32, b: u32): u32 {
    let mut result = try_sub_int32(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_sub_int32(a: u32, b: u32): Option<u32> {
    if (b ==0) {
        return option::some(a)
    };
    try_add_int32(a, to_2s_complement(b))
}

fun add_int32(a: u32, b: u32): u32 {
    let mut result = try_add_int32(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_add_int32(a: u32, b: u32): Option<u32> {
    if (is_positive_int32(a) && is_positive_int32(b)) {
        if (safe_add(a, b)) {
            return option::some(a + b)
        };
    } else if (is_negative_int32(a) && is_negative_int32(b)) {
        let a_neg = to_2s_complement(a);
        let b_neg = to_2s_complement(b);
        if (safe_add_neg(a_neg, b_neg)) {
            let magnitude = a_neg + b_neg;
            return option::some(to_2s_complement(magnitude))
        }
    } else {
        if (LIMIT - a < b) {
            return option::some(truncated_sum(a, b))
        } else {
            return option::some(a + b)
        }
    };

    return option::none()
}

fun safe_add(a: u32, b: u32): bool {
    return MAX_POSITIVE_INT32 - a >= b
}

fun safe_add_neg(a: u32, b: u32): bool {
    return MIN_NEGATIVE_INT32 - a >= b
}

fun truncated_sum(a: u32, b: u32): u32 {
    if (a & MAX_MAGNITUDE != 0 && b & MAX_MAGNITUDE != 0) {
        ((a ^ MAX_MAGNITUDE) + (b ^ MAX_MAGNITUDE))
    } else if (a & MAX_MAGNITUDE == 0) {
        let reduced_factor = (b ^ MAX_MAGNITUDE) + a;
        reduced_factor ^ MAX_MAGNITUDE
    } else {
        let reduced_factor = (a ^ MAX_MAGNITUDE) + b;
        reduced_factor ^ MAX_MAGNITUDE
    }
}

fun mod_int32(a: u32, b: u32): u32 {
    assert!(is_positive_int32(b), NegativeMod);
    let mut increment = a;
    while (is_negative_int32(increment)) {
        increment = add_int32(increment, b)
    };
    increment % b
}

fun shr_int32(x: u32, shift: u8): u32 {
    let mut rep = x >> shift;
    if (x & MAX_MAGNITUDE != 0) {
        let bits = (1 << (shift)) - 1;

        let factor = bits << (BIT_SIZE  - shift);

        rep = rep + factor;
    };

    return rep
}

// Internal helper functions
fun is_positive_int32(a: u32): bool {
    a <= MAX_POSITIVE_INT32
}

fun is_negative_int32(a: u32): bool {
    a >= MIN_NEGATIVE_INT32
}

fun to_2s_complement(value: u32): u32 {
    if (value == 0) { return 0 };
    (value ^ LIMIT) + 1
}

fun max_value(a: u32, b: u32): u32 {
    if (a >= b) { a } else { b }
}

fun min_value(a: u32, b: u32): u32 {
    if (a <= b) { a } else { b }
}
