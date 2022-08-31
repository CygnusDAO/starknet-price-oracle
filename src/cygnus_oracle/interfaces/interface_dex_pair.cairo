%lang starknet

from starkware.cairo.common.uint256 import Uint256
#
# From Jediswap
# example of DAI/ETH https://goerli.voyager.online/contract/0x261ddbc69fe568a8239c29a8907d72fc6adb10b6810175584c151a8278875d#readContract
#
@contract_interface
namespace IPair:
    func get_reserves() -> (reserve0 : Uint256, reserve1 : Uint256, block_timestamp_last : felt):
    end

    func totalSupply() -> (totalSupply : Uint256):
    end

    func token0() -> (token0 : felt):
    end

    func token1() -> (token1 : felt):
    end
end

