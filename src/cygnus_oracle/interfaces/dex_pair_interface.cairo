%lang starknet
# ─────────────────────────────────────────
# From Jediswap
@contract_interface
namespace IPair:
    func getReserve0() -> (reserve0 : felt):
    end

    func getReserve1() -> (reserve1 : felt):
    end

    func getReserves() -> (reserve0, reserve1, timestamp):
    end

    # @notice Total Supply of the token
    # @return totalSupply
    func totalSupply() -> (totalSupply : felt):
    end

    # @notice token0
    func getToken0() -> (token0 : felt):
    end

    # @notice token1
    func getToken1() -> (token1 : felt):
    end
end

