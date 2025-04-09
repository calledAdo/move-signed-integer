/// Module: Int256
/// This module provides operations for 256-bit signed integers.

module int::int256;

const OverFlowError: u64 = 1;
const OutofBoundError: u64 = 2;
const DivisionByZeroError: u64 = 3;
const NegativeMod: u64 = 4;

const BIT_SIZE: u16 = 256;

/// Maximum magnitude for a 256-bit signed integer
/// magnitude of a => |a| eg |-2| = 2
const MAX_MAGNITUDE: u256 = 1 << (BIT_SIZE - 1 as u8); // 2^255

/// Maximum unsigned number representable as 256-bit
const LIMIT: u256 = MAX_MAGNITUDE + (MAX_MAGNITUDE - 1);

/// Maximum positive integer (2^255 - 1)
const MAX_POSITIVE_INT256: u256 = MAX_MAGNITUDE - 1;

/// Minimum negative integer (-2^255)
const MIN_NEGATIVE_INT256: u256 = MAX_MAGNITUDE;

public struct Int256 has copy, drop, store {
    rep: u256,
}

/// Create Int256 type functions
public fun from_raw_bits(bits: u256): Int256 {
    return Int256 { rep: bits }
}

public fun from_u256(magnitude: u256): Int256 {
    try_from_u256(magnitude).extract()
}

public fun try_from_u256(magnitude: u256): Option<Int256> {
    if (magnitude > MAX_POSITIVE_INT256) {
        option::none()
    } else {
        option::some(Int256 { rep: magnitude })
    }
}

public fun new(magnitude: u256, is_positive: bool): Int256 {
    try_new(magnitude, is_positive).extract()
}

public fun try_new(magnitude: u256, is_positive: bool): Option<Int256> {
    if (magnitude > MIN_NEGATIVE_INT256) {
        return option::none()
    };
    if (is_positive) {
        if (magnitude > MAX_POSITIVE_INT256) {
            return option::none()
        };
        option::some(Int256 { rep: magnitude })
    } else {
        let twos_comp_rep = to_2s_complement(magnitude);
        option::some(Int256 { rep: twos_comp_rep })
    }
}

/// Convert from type functions
public fun to_u256(a: Int256): u256 {
    try_to_u256(a).extract()
}

public fun try_to_u256(a: Int256): Option<u256> {
    if (a.rep > MAX_POSITIVE_INT256) {
        option::none()
    } else {
        option::some(a.rep)
    }
}

public fun raw_bits(a: Int256): u256 {
    return a.rep
}

/// Comparison Operations
public fun max(a: Int256, b: Int256): Int256 {
    let rep = max_int256(a.rep, b.rep);
    Int256 { rep }
}

public fun min(a: Int256, b: Int256): Int256 {
    let rep = min_int256(a.rep, b.rep);
    Int256 { rep }
}

public fun lt(a: Int256, b: Int256): bool {
    if (a == b) { return false };
    a == min(a, b)
}

public fun gt(a: Int256, b: Int256): bool {
    if (a == b) { return false };
    a == max(a, b)
}

public fun lteq(a: Int256, b: Int256): bool {
    if (a == b) { return true };
    a == min(a, b)
}

public fun gteq(a: Int256, b: Int256): bool {
    if (a == b) { return true };
    a == max(a, b)
}

public fun eq(a: Int256, b: Int256): bool {
    a.rep == b.rep
}

public fun is_zero(a: Int256): bool {
    a.rep == 0
}

public fun is_positive(a: Int256): bool {
    is_positive_int256(a.rep)
}

public fun is_negative(a: Int256): bool {
    is_negative_int256(a.rep)
}

public fun is_nat(a: Int256): bool {
    return a.rep > 0 && a.rep < MIN_NEGATIVE_INT256
}

/// Operations on Int256 type
public fun shl(x: Int256, shift: u8): Int256 {
    let rep = x.rep << shift;
    return Int256 { rep }
}

public fun shr(x: Int256, shift: u8): Int256 {
    let rep = shr_int256(x.rep, shift);
    return Int256 { rep }
}

public fun abs(a: Int256): Int256 {
    assert!(a.rep != MIN_NEGATIVE_INT256, OutofBoundError);
    if (is_positive_int256(a.rep)) {
        a
    } else {
        let rep = to_2s_complement(a.rep);
        Int256 { rep }
    }
}

public fun neg(a: Int256): Int256 {
    assert!(a.rep != MIN_NEGATIVE_INT256, OutofBoundError);
    let rep = to_2s_complement(a.rep);
    Int256 { rep }
}

/// Arithmetic Operations
public fun add(a: Int256, b: Int256): Int256 {
    let rep = add_int256(a.rep, b.rep);
    Int256 { rep }
}

public fun try_add(a: Int256, b: Int256): Option<Int256> {
    let mut rep = try_add_int256(a.rep, b.rep);

    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int256 { rep: (&mut rep).extract() })
}

public fun sub(a: Int256, b: Int256): Int256 {
    let rep = sub_int256(a.rep, b.rep);
    Int256 { rep }
}

public fun try_sub(a: Int256, b: Int256): Option<Int256> {
    let mut rep = try_sub_int256(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int256 { rep: (&mut rep).extract() })
}

public fun mul(a: Int256, b: Int256): Int256 {
    let rep = mul_int256(a.rep, b.rep);
    Int256 { rep }
}

public fun try_mul(a: Int256, b: Int256): Option<Int256> {
    let mut rep = try_mul_int256(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int256 { rep: (&mut rep).extract() })
}

public fun div(a: Int256, b: Int256): Int256 {
    assert!(b.rep != 0, DivisionByZeroError);
    let rep = div_int256(a.rep, b.rep);
    Int256 { rep }
}

public fun try_div(a: Int256, b: Int256): Option<Int256> {
    assert!(b.rep != 0, DivisionByZeroError);
    let mut rep = try_div_int256(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int256 { rep: (&mut rep).extract() })
}

public fun mod(a: Int256, b: Int256): Int256 {
    let rep = mod_int256(a.rep, b.rep);
    Int256 { rep }
}

/// Internal helper functions
fun max_int256(a: u256, b: u256): u256 {
    if (is_positive_int256(a) && is_positive_int256(b)) {
        max_value(a, b)
    } else if (is_negative_int256(a) && is_negative_int256(b)) {
        max_value(a, b)
    } else {
        min_value(a, b)
    }
}

fun min_int256(a: u256, b: u256): u256 {
    if (is_positive_int256(a) && is_positive_int256(b)) {
        min_value(a, b)
    } else if (is_negative_int256(a) && is_negative_int256(b)) {
        min_value(a, b)
    } else {
        max_value(a, b)
    }
}

fun mul_int256(a: u256, b: u256): u256 {
    let mut result = try_mul_int256(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_mul_int256(a: u256, b: u256): Option<u256> {
    if (is_positive_int256(a) && is_positive_int256(b)) {
        if (safe_multiply(a, b)) {
            return option::some(a * b)
        };
    } else if (is_negative_int256(a) && is_negative_int256(b)) {
        let a_neg = to_2s_complement(a);
        let b_neg = to_2s_complement(b);
        if (safe_multiply(a_neg, b_neg)) {
            let result = a_neg * b_neg;
            return option::some(result)
        }
    } else if (is_negative_int256(b)) {
        let b_neg = to_2s_complement(b);
        if (safe_multiply_polar(a, b_neg)) {
            return option::some(to_2s_complement(a * b_neg))
        }
    } else {
        let a_neg = to_2s_complement(a);
        if (safe_multiply_polar(b, a_neg)) {
            return option::some(to_2s_complement(b * a_neg))
        }
    };
    return option::none()
}

fun safe_multiply(a: u256, b: u256): bool {
    return MAX_POSITIVE_INT256 / a >= b
}

fun safe_multiply_polar(a: u256, b: u256): bool {
    return MIN_NEGATIVE_INT256 / a >= b
}

fun div_int256(a: u256, b: u256): u256 {
    let mut result = try_div_int256(a, b);
    if (option::is_none(&result)) {
        abort OutofBoundError
    };
    result.extract()
}

fun try_div_int256(a: u256, b: u256): Option<u256> {
    if (is_positive_int256(a) && is_positive_int256(b)) {
        return option::some(a / b)
    } else if (is_negative_int256(a) && is_negative_int256(b)) {
        let result = to_2s_complement(a) / to_2s_complement(b);
        if (is_negative_int256(result)) {
            return option::none()
        };
        option::some(result)
    } else if (is_negative_int256(b)) {
        let magnitude = a / to_2s_complement(b);
        option::some(to_2s_complement(magnitude))
    } else {
        let magnitude = to_2s_complement(a) / b;
        option::some(to_2s_complement(magnitude))
    }
}

fun sub_int256(a: u256, b: u256): u256 {
    let mut result = try_sub_int256(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_sub_int256(a: u256, b: u256): Option<u256> {
    if (b== 0) {
        return option::some(a)
    };
    try_add_int256(a, to_2s_complement(b))
}

fun add_int256(a: u256, b: u256): u256 {
    let mut result = try_add_int256(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_add_int256(a: u256, b: u256): Option<u256> {
    if (is_positive_int256(a) && is_positive_int256(b)) {
        if (safe_add(a, b)) {
            return option::some(a + b)
        };
    } else if (is_negative_int256(a) && is_negative_int256(b)) {
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

fun safe_add(a: u256, b: u256): bool {
    return MAX_POSITIVE_INT256 - a >= b
}

fun safe_add_neg(a: u256, b: u256): bool {
    return MIN_NEGATIVE_INT256 -a >= b
}

fun truncated_sum(a: u256, b: u256): u256 {
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

fun mod_int256(a: u256, b: u256): u256 {
    assert!(is_positive_int256(b), NegativeMod);
    let mut increment = a;
    while (is_negative_int256(increment)) {
        increment = add_int256(increment, b)
    };
    increment % b
}

fun shr_int256(x: u256, shift: u8): u256 {
    let mut rep = x >> shift;
    if (x & MAX_MAGNITUDE != 0) {
        let bits = (1 << (shift)) - 1;

        let factor = bits << (BIT_SIZE as u8 - shift);

        rep = rep + factor;
    };

    return rep
}

// Internal helper functions
fun is_positive_int256(a: u256): bool {
    a <= MAX_POSITIVE_INT256
}

fun is_negative_int256(a: u256): bool {
    a >= MIN_NEGATIVE_INT256
}

fun to_2s_complement(value: u256): u256 {
    if (value == 0) { return 0 };
    (value ^ LIMIT) + 1
}

fun max_value(a: u256, b: u256): u256 {
    if (a >= b) { a } else { b }
}

fun min_value(a: u256, b: u256): u256 {
    if (a <= b) { a } else { b }
}
