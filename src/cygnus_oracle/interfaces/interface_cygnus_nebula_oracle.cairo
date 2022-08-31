%lang starknet

@contract_interface
namespace ICygnusNebulaOracle:
    func name() -> (name : felt):
    end

    func symbol() -> (symbol : felt):
    end

    func decimals() -> (decimals : felt):
    end

    func version() -> (version : felt):
    end

    func admin() -> (admin : felt):
    end

    func pending_admin() -> (pending_admin : felt):
    end

    func empiric_oracle_address() -> (empiric_oracle_address : felt):
    end

    func aggregation_mode() -> (aggregation_mode : felt):
    end

    func get_price_oracle(lp_token_pair : felt) -> (
        oracle_id : felt,
        initialized : felt,
        empiric_key_token0 : felt,
        empiric_key_token1 : felt,
    ):
    end

    func total_oracles() -> (total_oracles : felt):
    end

    func get_dai_price() -> (dai_price : felt):
    end

    func get_lp_token_price(lp_token_pair : felt) -> (lp_token_price : felt):
    end

    func initialize_oracle(lp_token_pair : felt, empiric_key_token0 : felt, empiric_key_token1 : felt):
    end

    func delete_oracle(lp_token_pair : felt):
    end

    func set_oracle_pending_admin(new_pending_admin : felt):
    end

    func set_oracle_admin():
    end
end
