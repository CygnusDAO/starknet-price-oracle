%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address, get_block_timestamp

// @title  Context
// @notice OZ' Context contract using Cairo's v0.10 simple return feature + address(this) + block.timestamp
//         https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol

// simple return for msg.sender
func msg_sender{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> felt {
    let (caller_address: felt) = get_caller_address();
    return caller_address;
}

// simple return for address(this)
func address_this{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> felt {
    let (contract_address: felt) = get_contract_address();
    return contract_address;
}

func block_timestamp{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> felt{
  let (block_timestamp: felt) = get_block_timestamp();
  return block_timestamp;
}

