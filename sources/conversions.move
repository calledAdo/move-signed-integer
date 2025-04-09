module int::conversions;

use int::int128::{Self, Int128};
use int::int16::{Self, Int16};
use int::int256::{Self, Int256};
use int::int32::{Self, Int32};
use int::int64::{Self, Int64};
use int::int8::{Self, Int8};

///Int256 type casting functions
///
///
///
public fun int256_as_int8(x: Int256): Int8 {
    let bits = x.raw_bits();
    let factor: u256 = (1 << 8) - 1;
    let rep = (bits  & factor) as u8;
    return int8::from_raw_bits(rep)
}

public fun int256_as_int16(x: Int256): Int16 {
    let bits = x.raw_bits();
    let factor: u256 = (1 << 16) - 1;
    let rep = (bits  & factor) as u16;
    return int16::from_raw_bits(rep)
}

public fun int256_as_int32(x: Int256): Int32 {
    let bits = x.raw_bits();
    let factor: u256 = (1 << 32) - 1;
    let rep = (bits  & factor) as u32;
    return int32::from_raw_bits(rep)
}

public fun int256_as_int64(x: Int256): Int64 {
    let bits = x.raw_bits();
    let factor: u256 = (1 << 64) - 1;
    let rep = (bits  & factor) as u64;
    return int64::from_raw_bits(rep)
}

public fun int256_as_int128(x: Int256): Int128 {
    let bits = x.raw_bits();
    let factor: u256 = (1 << 128) - 1;
    let rep = (bits  & factor) as u128;
    return int128::from_raw_bits(rep)
}

///Int128 type  casting functions
///
///
///
///
public fun int128_as_int8(x: Int128): Int8 {
    let bits = x.raw_bits();
    let factor: u128 = (1 << 8) - 1;
    let rep = (bits & factor) as u8;
    return int8::from_raw_bits(rep)
}

public fun int128_as_int16(x: Int128): Int16 {
    let bits = x.raw_bits();
    let factor: u128 = (1 << 16) - 1;
    let rep = (bits  & factor) as u16;
    return int16::from_raw_bits(rep)
}

public fun int128_as_int32(x: Int128): Int32 {
    let bits = x.raw_bits();
    let factor: u128 = (1 << 32) - 1;
    let rep = (bits  & factor) as u32;
    return int32::from_raw_bits(rep)
}

public fun int128_as_int64(x: Int128): Int64 {
    let bits = x.raw_bits();
    let factor: u128 = (1 << 64) - 1;
    let rep = (bits  & factor) as u64;
    return int64::from_raw_bits(rep)
}

public fun int128_as_int256(x: Int128): Int256 {
    let bitsize_diff = (256 - 128) as u8;
    let bits = x.raw_bits() as u256;
    let parity = ((1<<127) & bits);
    let map: u256 = (parity << (bitsize_diff)) - parity;
    let factor = map << 128;
    let rep = (bits  ^ factor) as u256;
    return int256::from_raw_bits(rep)
}

///Int64  type casting functions
///
///
///
///
public fun int64_as_int8(x: Int64): Int8 {
    let bits = x.raw_bits();
    let factor: u64 = (1 << 8) - 1;
    let rep = (bits  & factor) as u8;
    return int8::from_raw_bits(rep)
}

public fun int64_as_int16(x: Int64): Int16 {
    let bits = x.raw_bits();
    let factor: u64 = (1 << 16) - 1;
    let rep = (bits & factor) as u16;
    return int16::from_raw_bits(rep)
}

public fun int64_as_int32(x: Int64): Int32 {
    let bits = x.raw_bits();
    let factor: u64 = (1 << 32) - 1;
    let rep = (bits & factor) as u32;
    return int32::from_raw_bits(rep)
}

public fun int64_as_int128(x: Int64): Int128 {
    let bitsize_diff = 128 - 64;
    let bits = x.raw_bits() as u256;
    let parity = ((1<<63) & bits);
    let map = (parity << (bitsize_diff )) - parity;
    let factor = map << 64;
    let rep = (bits  ^ factor) as u128;
    return int128::from_raw_bits(rep)
}

public fun int64_as_int256(x: Int64): Int256 {
    let bitsize_diff = (256 - 64) as u8;
    let bits = x.raw_bits() as u256;
    let parity = ((1<<63) & bits);
    let map = (parity << (bitsize_diff)) - parity;
    let factor = map << 64;
    let rep = (bits  ^ factor);
    return int256::from_raw_bits(rep)
}

/// Int32 type casting
///
///
public fun int32_as_int8(x: Int32): Int8 {
    let bits = x.raw_bits();
    let factor: u32 = (1 << 8) - 1;
    let rep = (bits  & factor) as u8;
    return int8::from_raw_bits(rep)
}

public fun int32_as_int16(x: Int32): Int16 {
    let bits = x.raw_bits();
    let factor: u32 = (1 << 16) - 1;
    let rep = (bits  & factor) as u16;
    return int16::from_raw_bits(rep)
}

public fun int32_as_int64(x: Int32): Int64 {
    let bitsize_diff = (64 - 32) as u8;
    let bits = x.raw_bits() as u256;
    let parity = ((1<<31) & bits);
    let map = (parity << (bitsize_diff)) - parity;
    let factor = map << 32;
    let rep = (bits  & factor) as u64;
    return int64::from_raw_bits(rep)
}

public fun int32_as_int128(x: Int32): Int128 {
    let bitsize_diff = (128 - 32) as u8;
    let bits = x.raw_bits() as u256;
    let parity = ((1<<31) & bits);
    let map: u256 = (parity << (bitsize_diff)) - parity;
    let factor = map << 32;
    let rep = (bits ^ factor) as u128;
    return int128::from_raw_bits(rep)
}

public fun int32_as_int256(x: Int32): Int256 {
    let bitsize_diff = (256 - 32) as u8;
    let bits = x.raw_bits() as u256;
    let parity = ((1<<31) & bits);
    let map: u256 = (parity << (bitsize_diff)) - parity;
    let factor = map << 32;
    let rep = (bits ^ factor) as u256;
    return int256::from_raw_bits(rep)
}

/// Int16 type casting
///
///
public fun int16_as_int8(x: Int16): Int8 {
    let bits = x.raw_bits();
    let factor: u16 = (1 << 8) - 1;
    let rep = (bits  & factor) as u8;
    return int8::from_raw_bits(rep)
}

public fun int16_as_int32(x: Int16): Int32 {
    let bitsize_diff = (32 - 16) as u8;
    let bits = x.raw_bits() as u256;
    let parity = ((1<<15) & bits);
    let map = (parity << (bitsize_diff)) - parity;
    let factor = map << 16;
    let rep = (bits & factor) as u32;
    return int32::from_raw_bits(rep)
}

public fun int16_as_int64(x: Int16): Int64 {
    let bitsize_diff = (64 - 16) as u8;
    let bits = x.raw_bits() as u256;
    let parity = ((1<<15) & bits);
    let map = (parity << (bitsize_diff)) - parity;
    let factor = map << 16;
    let rep = (bits  & factor) as u64;
    return int64::from_raw_bits(rep)
}

public fun int16_as_int128(x: Int16): Int128 {
    let bitsize_diff = (128 - 16) as u8;
    let bits = x.raw_bits() as u256;
    let parity = ((1<<15) & bits);
    let map = (parity << (bitsize_diff)) - parity;
    let factor = map << 16;
    let rep = (bits  ^ factor) as u128;
    return int128::from_raw_bits(rep)
}

public fun int16_as_int256(x: Int16): Int256 {
    let bitsize_diff = (256 - 16) as u8;
    let bits = x.raw_bits() as u256;
    let parity = ((1<<15) & bits);
    let map = (parity << (bitsize_diff)) - parity;
    let factor = map << 16;
    let rep = (bits ^ factor) as u256;
    return int256::from_raw_bits(rep)
}

/// Int8 type casting
///
///
public fun int8_as_int16(x: Int8): Int16 {
    let bitsize_diff = (16 -8) as u8;
    let bits = x.raw_bits() as u256;
    let parity = ((1<<7) & bits);
    let map = (parity << (bitsize_diff)) - parity;
    let factor = map << 8;
    let rep = (bits & factor) as u16;
    return int16::from_raw_bits(rep)
}

public fun int8_as_int32(x: Int8): Int32 {
    let bitsize_diff = (32 -8) as u8;
    let bits = x.raw_bits() as u256;
    let parity = ((1<<7) & bits);
    let map = (parity << (bitsize_diff)) - parity;
    let factor = map << 8;
    let rep = (bits  & factor) as u32;
    return int32::from_raw_bits(rep)
}

public fun int8_as_int64(x: Int8): Int64 {
    let bitsize_diff = (64 -8) as u8;
    let bits = x.raw_bits() as u256;
    let parity = ((1<<7) & bits);
    let map: u256 = (parity << (bitsize_diff)) - parity;
    let factor = map << 8;
    let rep = (bits & factor) as u64;
    return int64::from_raw_bits(rep)
}

public fun int8_as_int128(x: Int8): Int128 {
    let bitsize_diff = (128 -8) as u8;
    let bits = x.raw_bits() as u256;
    let parity = ((1<<7) & bits);
    let map = (parity << (bitsize_diff)) - parity;
    let factor = map << 8;
    let rep = (bits ^ factor) as u128;
    return int128::from_raw_bits(rep)
}

public fun int8_as_int256(x: Int8): Int256 {
    let bitsize_diff = (256 -8) as u8;
    let bits = x.raw_bits();
    let parity = ((1<<7) & bits) as u256;
    let map: u256 = (parity << (bitsize_diff)) - parity;
    let factor = map << 8;
    let rep = (bits  as  u256 ^ factor) as u256;
    return int256::from_raw_bits(rep)
}
