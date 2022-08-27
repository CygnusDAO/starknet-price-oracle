# SPDX-License-Identifier: Unlicensed
%lang starknet

# Cairo libraries
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.math import (
    assert_250_bit,
    assert_lt_felt,
    assert_le_felt,
    unsigned_div_rem,
    split_felt,
    assert_not_zero,
    assert_nn_le,
    assert_in_range,
)
from starkware.cairo.common.bitwise import (
    bitwise_and as bitwise_and_cairo,
    bitwise_or as bitwise_or_cairo,
)
from starkware.cairo.common.uint256 import Uint256

# ════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

# Library - 58.18-Decimal Math Library
#
# @name   math58x18
# @author cygnusdao (0xHyoga@gmx.com)
# @notice Simple Cairo implementation of PRB Math, specifically the unsigned library:
#         https://github.com/paulrberg/prb-math/blob/main/contracts/PRBMathUD58.18.sol)
#
# Fixed point Smart contract library for basic fixed-point math that operates with unsigned 58.18-decimal fixed-point
# numbers. The name of the number formats stems from the fact that there can be up to 58 digits in the integer part
# and up to 18 decimals in the fractional part. The numbers are bound by the minimum and the maximum values permitted
# by the Cairo `felt` type.

# ════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

namespace MathUD58x18:
    # ───────────────── CONSTANTS

    #
    # @dev Cairo's highest possible number `P` before overflows occur
    #
    const P_UD58x18 = 3618502788666131213697322783095070105623107215331596699973092056135872020481  # 2^251 + 17 * 2^192 + 1

    #
    # @dev Half Cairo's `P`
    #
    const HALF_P_UD58x18 = 1809251394333065606848661391547535052811553607665798349986546028067936010240  # 2^250 + 8 * 2^192 + 2^191

    #
    # @dev The maximum value an unsigned 58.18-decimal fixed-point number can have
    #
    const MAX_UD58x18 = 1809251394333065553493296640760748560207343510400633813116524750123642650623  # 2^250 - 1

    #
    # @dev The maximum whole value an unsigned 58.18-decimal fixed-point number can have
    #
    const MAX_WHOLE_UD58x18 = 1809251394333065553493296640760748560207343510400633813116000000000000000000

    #
    # @dev How many trailing decimals can be represented
    #
    const SCALE = 10 ** 18

    #
    # @dev Half the SCALE number
    #
    const HALF_SCALE = 5 * 10 ** 17

    #
    # @dev Used for the bitwise not operator
    #
    const ALL_ONES = 2 ** 251 - 1

    # ───────────────── UINT250 CHECK

    #
    # @dev Asserts that params and the result are in the range [0, 2^250].
    #
    func assert58x18{range_check_ptr}(x : felt, y : felt, result : felt):
        # check that the param `x` passed is ud58x18
        assert_250_bit(value=x)

        # check that the param `y` passed is ud58x18
        assert_250_bit(value=y)

        # check that the result of calculation(x,y) is ud58x18
        assert_250_bit(value=result)

        return ()
    end

    # ───────────────── BITWISE OPERATIONS

    #
    # @return result The value whose bit pattern shows which bits in either of the operands has the value 1.
    #
    func bitwise_or{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : felt, y : felt) -> (
        result : felt
    ):
        # from cairo lib
        let (result) = bitwise_or_cairo(x, y)

        #
        # ERROR: uint250_overflow
        #
        with_attr error_message("math_ud58x18__uint250_overflow({x}, {y}, {result})"):
            assert58x18(x, y, result)
        end

        return (result=result)
    end

    #
    # @return result The bitwise ANDing of the bits of all the arguments
    #
    func bitwise_and{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : felt, y : felt) -> (
        result : felt
    ):
        # from cairo lib
        let (result) = bitwise_and_cairo(x, y)

        #
        # ERROR: uint250_overflow
        #
        with_attr error_message("math_ud58x18__uint250_overflow({x}, {y}, {result})"):
            assert58x18(x, y, result)
        end

        return (result)
    end

    # ────────────────────────────────── SHIFT OPERATORS

    #
    # @notice Shift bits to the right and lose values
    # @param word a 32 bits word
    # @param n the amount of bits to shift
    # @return The word with the last n bits shifted
    #
    # func right_shift{range_check_ptr}(word : felt, n : felt) -> (word : felt):
    #    let (divisor) = pow2(n)
    #    let (p, _) = unsigned_div_rem(word, divisor)
    #    return (p)
    # end

    #
    # @notice Shift bits to the left and lose values
    # @param word a 32 bits word
    # @param n the amount of bits to shift
    # @return The word with the last n bits shifted
    #
    # func left_shift{range_check_ptr}(word : felt, n : felt) -> (word : felt):
    #    alloc_locals
    #    let (divisor) = pow2(32 - n)
    #    let (_, r) = unsigned_div_rem(word, divisor)
    #    let (multiplicator) = pow2(n)
    #    return (multiplicator * r)
    # end

    # ────────────────────────────────── AVERAGE

    #
    # @notice Calculates the arithmetic average of x and y, rounding down due to unsigned_div_rem
    # @param x The first operand as an unsigned 58.18-decimal fixed-point number.
    # @param y The second operand as an unsigned 58.18-decimal fixed-point number.
    # @return result The arithmetic average as an unsigned 58.18-decimal fixed-point number.
    #
    func avg{range_check_ptr}(x : felt, y : felt) -> (result : felt):
        let (result : felt, _) = unsigned_div_rem(x + y, 2)

        #
        # ERROR: uint250_overflow
        #
        with_attr error_message("math_ud58x18__uint250_overflow({x}, {y}, {result})"):
            assert58x18(x, y, result)
        end

        return (result=result)
    end

    # ────────────────────────────────── SAFE MATH

    #
    # @notice Adds two unsigned 58.18-decimal numbers, returning a new unsigned 58.18 decimal number
    # @param x An unsigned 58.18-decimal fixed-point number
    # @param y An unsigned 58.18-decimal fixed-point number
    # @return result The result of the addition
    #
    func sum{range_check_ptr}(x : felt, y : felt) -> (result : felt):
        let result : felt = x + y

        #
        # ERROR: sum_overflow
        #
        with_attr error_message("ud58x18__sum_overflow({x}, {y})"):
            assert_le_felt(x, result)
        end

        #
        # ERROR: uint250_overflow
        #
        with_attr error_message("math_ud58x18__uint250_overflow({x}, {y}, {result})"):
            assert58x18(x, y, result)
        end

        return (result=result)
    end

    #
    # @notice Subtracts two integers, reverting on overflow
    # @param x the minuend as an unsigned 58.18-decimal fixed-point number
    # @param y the subtrahend as an unsigned 58.18-decimal fixed-point number
    # @return result the result of the substraction, it can be 0
    #
    func sub{range_check_ptr}(x : felt, y : felt) -> (result : felt):
        #
        # ERROR: uint250_substraction_overflow
        #
        with_attr error_message("math_ud58x18__uint250_substraction_overflow({x}, {y})"):
            assert_le_felt(y, x)
        end

        # Substract x and y
        let result : felt = x - y

        #
        # ERROR: uint250_overflow
        #
        with_attr error_message("math_ud58x18__uint250_overflow({x}, {y})"):
            assert58x18(x, y, result)
        end

        return (result=result)
    end

    #
    # @notice Multiplies two unsigned 58.18-decimal numbers, returning a new unsigned 58.18-decimal number
    # @param x The multiplicand as an unsigned 58.18-decimal fixed-point number
    # @param y The multiplier as an unsigned 58.18-decimal fixed-point number
    # @return result The product as an unsigned 58.18-decimal fixed-point number
    #
    func mul{range_check_ptr}(x : felt, y : felt) -> (result : felt):
        # Get the product of x and y
        let result : felt = x * y

        # Return 0 and avoid more steps
        if result == 0:
            return (result=0)
        end

        # asserts that (result / x == y)
        # ERROR: uint250_multiplication_overflow
        #
        with_attr error_message(
                "math_ud58x18__uint250_multiplication_overflow({x}, {y}, {result})"):
            let (_y : felt, _) = unsigned_div_rem(result, x)
            assert _y = y
        end

        #
        # ERROR: uint250_overflow
        #
        with_attr error_message("math_ud58x18__uint250_overflow({x}, {y}, {result})"):
            assert58x18(x, y, result)
        end

        return (result=result)
    end

    #
    # @notice Divides two unsigned 58.18-decimal numbers, returning a new unsigned 58.18 decimal number
    # @param x The numerator as an unsigned 58.18-decimal fixed-point number
    # @param y The denominator as an unsigned 58.18-decimal fixed-point number
    # @param result The quotient as an unsigned 58.18-decimal fixed-point number
    #
    func div{range_check_ptr}(x : felt, y : felt) -> (result : felt):
        # Conforms to EVM specifications: division by 0 yields 0.
        if y == 0:
            return (result=0)
        end

        # unsigned_div_rem already checks:
        #   remainder < divisor
        #   quotient * divisor + remainder == dividend
        let (result : felt, _) = unsigned_div_rem(x, y)

        #
        # ERROR: uint250_overflow
        #
        with_attr error_message("math_ud58x18__uint250_overflow({x}, {y}, {result})"):
            assert58x18(x, y, result)
        end

        return (result=result)
    end

    # ────────────────────────────────── SAFE FIXED POINT MATH

    #
    # @notice Calculates floor(x*y÷1e18) with full precision
    # @param x The multiplicand as an unsigned 58.18-decimal fixed-point number
    # @param y The multiplier as an unsigned 58.18-decimal fixed-point number
    # @return result The result as an unsigned 58.18-decimal fixed-point number
    #
    func mul_fixed_point{range_check_ptr}(x : felt, y : felt) -> (result : felt):
        # Inner call to mul doing sufficient checks
        let product : felt = mul(x, y)

        # Return 0 and avoid more steps
        if product == 0:
            return (result=0)
        end

        #
        # ERROR: uint250_multiplication_overflow
        #
        with_attr error_message("math_ud58x18__uint250_multiplication_overflow({result})"):
            let (result : felt, _) = unsigned_div_rem(product, SCALE)

            #
            # ERROR: uint250_overflow
            #
            assert_250_bit(value=result)
        end

        return (result=result)
    end

    #
    # @notice Calculates floor(x*1e18÷y) with full precision
    # @param x The numerator as an unsigned 58.18-decimal fixed-point number
    # @param y The denominator as an unsigned 58.18-decimal fixed-point number
    # @param result The quotient as an unsigned 58.18-decimal fixed-point number
    #
    func div_fixed_point{range_check_ptr}(x : felt, y : felt) -> (result : felt):
        if y == 0:
            return (result=0)
        end

        # Uses `mul` to enable overflow-safe multiplication and division.
        let product : felt = mul(x, SCALE)

        #
        # ERROR: uint250_multiplication_overflow
        #
        with_attr error_message("math_ud58x18__uint250_multiplication_overflow({result})"):
            let (result : felt, _) = unsigned_div_rem(product, y)

            #
            # ERROR: uint250_overflow
            #
            assert_250_bit(value=result)
        end

        return (result=result)
    end

    # ────────────────────────────────── GEOMETRIC MEAN

    #
    # @notice Calculates geometric mean of x and y, i.e. sqrt(x * y), rounding down.
    #
    # @dev Requirements:
    # - x * y must fit within MAX_UD60x18, lest it overflows.
    #
    # @param x The first operand as an unsigned 58.18-decimal fixed-point number
    # @param y The second operand as an unsigned 58.18-decimal fixed-point number
    # @return result The result as an unsigned 58.18-decimal fixed-point number
    #
    func gm{range_check_ptr}(x : felt, y : felt) -> (result : felt):
        # explicit return
        if x == 0:
            return (result=0)
        end

        # calculate product and checks for overflow
        let (xy : felt) = mul(x, y)

        return sqrt(xy)
    end

    func mul_div{range_check_ptr}(x : felt, y : felt, z : felt) -> (result : felt):
        let (xy : felt) = mul(x, y)

        let (result : felt) = div(xy, z)
        
        return(result)
    end

    #
    # from: https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/math.cairo
    # Returns the floor value of the square root of the given value.
    # Assumptions: 0 <= value < 2**250.
    #
    func sqrt{range_check_ptr}(value) -> (result : felt):
        alloc_locals
        local root : felt

        %{
            from starkware.python.math_utils import isqrt
            value = ids.value % PRIME
            assert value < 2 ** 250, f"value={value} is outside of the range [0, 2**250)."
            assert 2 ** 250 < PRIME
            ids.root = isqrt(value)
        %}

        assert_nn_le(root, 2 ** 125 - 1)
        tempvar root_plus_one = root + 1
        assert_in_range(value, root * root, root_plus_one * root_plus_one)

        return (result=root)
    end
end
