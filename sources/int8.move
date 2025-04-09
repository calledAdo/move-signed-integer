module int::int8;

const OverFlowError: u64 = 1;
const OutofBoundError: u64 = 2;
const DivisionByZeroError: u64 = 3;
const NegativeMod: u64 = 4;

const BIT_SIZE: u8 = 8;
const MAX_MAGNITUDE: u8 = 1 << (BIT_SIZE - 1); // 2^7
const LIMIT: u8 = MAX_MAGNITUDE + (MAX_MAGNITUDE - 1);
const MAX_POSITIVE_INT8: u8 = MAX_MAGNITUDE - 1;
const MIN_NEGATIVE_INT8: u8 = MAX_MAGNITUDE;

public struct Int8 has copy, drop, store {
    rep: u8,
}

public fun from_raw_bits(bits: u8): Int8 {
    return Int8 { rep: bits }
}

public fun from_u8(magnitude: u8): Int8 {
    try_from_u8(magnitude).extract()
}

public fun try_from_u8(magnitude: u8): Option<Int8> {
    if (magnitude > MAX_POSITIVE_INT8) {
        option::none()
    } else {
        option::some(Int8 { rep: magnitude })
    }
}

public fun new(magnitude: u8, is_positive: bool): Int8 {
    try_new(magnitude, is_positive).extract()
}

public fun try_new(magnitude: u8, is_positive: bool): Option<Int8> {
    if (magnitude > MIN_NEGATIVE_INT8) {
        return option::none()
    };
    if (is_positive) {
        if (magnitude > MAX_POSITIVE_INT8) {
            return option::none()
        };
        option::some(Int8 { rep: magnitude })
    } else {
        let twos_comp_rep = to_2s_complement(magnitude);
        option::some(Int8 { rep: twos_comp_rep })
    }
}

public fun to_u8(a: Int8): u8 {
    try_to_u8(a).extract()
}

public fun try_to_u8(a: Int8): Option<u8> {
    if (a.rep > MAX_POSITIVE_INT8) {
        option::none()
    } else {
        option::some(a.rep)
    }
}

public fun raw_bits(a: Int8): u8 {
    return a.rep
}

public fun max(a: Int8, b: Int8): Int8 {
    let rep = max_int8(a.rep, b.rep);
    Int8 { rep }
}

public fun min(a: Int8, b: Int8): Int8 {
    let rep = min_int8(a.rep, b.rep);
    Int8 { rep }
}

public fun lt(a: Int8, b: Int8): bool {
    if (a == b) { return false };
    a == min(a, b)
}

public fun gt(a: Int8, b: Int8): bool {
    if (a == b) { return false };
    a == max(a, b)
}

public fun lteq(a: Int8, b: Int8): bool {
    a == min(a, b)
}

public fun gteq(a: Int8, b: Int8): bool {
    a == max(a, b)
}

public fun eq(a: Int8, b: Int8): bool {
    a.rep == b.rep
}

public fun is_zero(a: Int8): bool {
    a.rep == 0
}

public fun is_positive(a: Int8): bool {
    is_positive_int8(a.rep)
}

public fun is_negative(a: Int8): bool {
    is_negative_int8(a.rep)
}

public fun is_nat(a: Int8): bool {
    return a.rep > 0 && a.rep < MIN_NEGATIVE_INT8
}

public fun shl(x: Int8, shift: u8): Int8 {
    let rep = x.rep << shift;
    return Int8 { rep }
}

public fun shr(x: Int8, shift: u8): Int8 {
    let rep = shr_int8(x.rep, shift);
    return Int8 { rep }
}

public fun abs(a: Int8): Int8 {
    assert!(a.rep != MIN_NEGATIVE_INT8, OutofBoundError);
    if (is_positive_int8(a.rep)) {
        a
    } else {
        let rep = to_2s_complement(a.rep);
        Int8 { rep }
    }
}

public fun neg(a: Int8): Int8 {
    assert!(a.rep != MIN_NEGATIVE_INT8, OutofBoundError);
    let rep = to_2s_complement(a.rep);
    Int8 { rep }
}

public fun add(a: Int8, b: Int8): Int8 {
    let rep = add_int8(a.rep, b.rep);
    Int8 { rep }
}

public fun try_add(a: Int8, b: Int8): Option<Int8> {
    let mut rep = try_add_int8(a.rep, b.rep);

    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int8 { rep: (&mut rep).extract() })
}

public fun sub(a: Int8, b: Int8): Int8 {
    let rep = sub_int8(a.rep, b.rep);
    Int8 { rep }
}

public fun try_sub(a: Int8, b: Int8): Option<Int8> {
    let mut rep = try_sub_int8(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int8 { rep: (&mut rep).extract() })
}

public fun mul(a: Int8, b: Int8): Int8 {
    let rep = mul_int8(a.rep, b.rep);
    Int8 { rep }
}

public fun try_mul(a: Int8, b: Int8): Option<Int8> {
    let mut rep = try_mul_int8(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int8 { rep: (&mut rep).extract() })
}

public fun div(a: Int8, b: Int8): Int8 {
    assert!(b.rep != 0, DivisionByZeroError);
    let rep = div_int8(a.rep, b.rep);
    Int8 { rep }
}

public fun try_div(a: Int8, b: Int8): Option<Int8> {
    if (b.rep == 0) {
        return option::none()
    };
    let mut rep = try_div_int8(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int8 { rep: (&mut rep).extract() })
}

public fun mod(a: Int8, b: Int8): Int8 {
    let rep = mod_int8(a.rep, b.rep);
    Int8 { rep }
}

fun max_int8(a: u8, b: u8): u8 {
    if (is_positive_int8(a) && is_positive_int8(b)) {
        max_value(a, b)
    } else if (is_negative_int8(a) && is_negative_int8(b)) {
        max_value(a, b)
    } else {
        min_value(a, b)
    }
}

fun min_int8(a: u8, b: u8): u8 {
    if (is_positive_int8(a) && is_positive_int8(b)) {
        min_value(a, b)
    } else if (is_negative_int8(a) && is_negative_int8(b)) {
        min_value(a, b)
    } else {
        max_value(a, b)
    }
}

fun mul_int8(a: u8, b: u8): u8 {
    let mut result = try_mul_int8(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_mul_int8(a: u8, b: u8): Option<u8> {
    if (is_positive_int8(a) && is_positive_int8(b)) {
        if (safe_multiply(a, b)) {
            return option::some(a * b)
        };
    } else if (is_negative_int8(a) && is_negative_int8(b)) {
        let a_neg = to_2s_complement(a);
        let b_neg = to_2s_complement(b);
        if (safe_multiply(a_neg, b_neg)) {
            let result = a_neg * b_neg;
            return option::some(result)
        }
    } else if (is_negative_int8(b)) {
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

fun safe_multiply(a: u8, b: u8): bool {
    return MAX_POSITIVE_INT8 / a >= b
}

fun safe_multiply_polar(a: u8, b: u8): bool {
    return MIN_NEGATIVE_INT8 / a >= b
}

fun div_int8(a: u8, b: u8): u8 {
    let mut result = try_div_int8(a, b);
    if (option::is_none(&result)) {
        abort OutofBoundError // caused by division of -128 and -1
    };
    result.extract()
}

fun try_div_int8(a: u8, b: u8): Option<u8> {
    if (is_positive_int8(a) && is_positive_int8(b)) {
        return option::some(a / b)
    } else if (is_negative_int8(a) && is_negative_int8(b)) {
        let result = to_2s_complement(a) / to_2s_complement(b);
        if (is_negative_int8(result)) {
            return option::none()
        };
        option::some(result)
    } else if (is_negative_int8(b)) {
        let magnitude = a / to_2s_complement(b);
        option::some(to_2s_complement(magnitude))
    } else {
        let magnitude = to_2s_complement(a) / b;
        option::some(to_2s_complement(magnitude))
    }
}

fun sub_int8(a: u8, b: u8): u8 {
    let mut result = try_sub_int8(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_sub_int8(a: u8, b: u8): Option<u8> {
    if (b == 0) {
        return option::some(a)
    };
    try_add_int8(a, to_2s_complement(b))
}

fun add_int8(a: u8, b: u8): u8 {
    let mut result = try_add_int8(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_add_int8(a: u8, b: u8): Option<u8> {
    if (is_positive_int8(a) && is_positive_int8(b)) {
        if (safe_add(a, b)) {
            return option::some(a + b)
        };
    } else if (is_negative_int8(a) && is_negative_int8(b)) {
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

fun safe_add(a: u8, b: u8): bool {
    return MAX_POSITIVE_INT8 - a >= b
}

fun safe_add_neg(a: u8, b: u8): bool {
    return MIN_NEGATIVE_INT8 - a>= b
}

fun truncated_sum(a: u8, b: u8): u8 {
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

fun mod_int8(a: u8, b: u8): u8 {
    assert!(is_positive_int8(b), NegativeMod);
    let mut increment = a;
    while (is_negative_int8(increment)) {
        increment = add_int8(increment, b)
    };
    increment % b
}

fun shr_int8(x: u8, shift: u8): u8 {
    let mut rep = x >> shift;
    if (x & MAX_MAGNITUDE != 0) {
        let bits = (1 << (shift) ) - 1;
        let factor = bits << (BIT_SIZE  - shift);

        rep = rep + factor;
    };

    return rep
}

fun is_positive_int8(a: u8): bool {
    a <= MAX_POSITIVE_INT8
}

fun is_negative_int8(a: u8): bool {
    a >= MIN_NEGATIVE_INT8
}

fun to_2s_complement(value: u8): u8 {
    if (value == 0) { return 0 };
    (value ^ LIMIT) + 1
}

fun max_value(a: u8, b: u8): u8 {
    if (a >= b) { a } else { b }
}

fun min_value(a: u8, b: u8): u8 {
    if (a <= b) { a } else { b }
}
