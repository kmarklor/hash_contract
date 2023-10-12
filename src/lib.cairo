#[starknet::contract]
mod hash {
    use starknet::{ContractAddress, get_caller_address};
    use keccak::{keccak_u256s_le_inputs};
    use array::ArrayTrait;
    use traits::{Into};

    #[storage]
    struct Storage {
        trunk: LegacyMap<u256, felt252>,
    }

    #[event]
    #[derive(starknet::Event, Drop, Serde)]
    enum Event {
        StoreData: StoreData
    }

    #[derive(starknet::Event, Drop, Serde)]
    struct StoreData {
        key_hash: u256
    }


    #[starknet::interface]
    trait IHashContractTrait<TContractState> {
        fn store(ref self: TContractState, password: felt252, store: felt252);
        fn at(self: @TContractState, address: ContractAddress, password: felt252) -> felt252;
    }

    #[external(v0)]
    impl HashContract of IHashContractTrait<ContractState> {
        fn store(ref self: ContractState, password: felt252, store: felt252) {
            let caller_address = starknet::get_caller_address();
            
            self._store_syscall_(caller_address, password, store);
        }

        fn at(self: @ContractState, address: ContractAddress, password: felt252) -> felt252 {
            self._at_syscall_(address, password)
        }
    }

    trait InternalFunctions<TContractState> {
        fn _store_syscall_(
            ref self: TContractState,
            address: ContractAddress,
            password: felt252,
            store: felt252
        );

        fn _at_syscall_(self: @TContractState, address: ContractAddress, password: felt252) -> felt252;        
    }

    impl InternalFunctionsImpl of InternalFunctions<ContractState> {
        fn _store_syscall_(
            ref self: ContractState,
            address: ContractAddress,
            password: felt252,
            store: felt252
        ) {
            assert_address_not_zero(address);

            let mut array: Array<u256> = ArrayTrait::new();
            set_sn_keccak256(ref array, address, password);

            let hash: u256 = keccak_u256s_le_inputs(array.span());
            self.trunk.write(hash, store);

            self.emit( StoreData { key_hash: hash } );
        }

        fn _at_syscall_(self: @ContractState, address: ContractAddress, password: felt252) -> felt252 {
            assert_address_not_zero(address);

            let mut array: Array<u256> = ArrayTrait::new();
            set_sn_keccak256(ref array, address, password);

            let key_hash: u256 = keccak_u256s_le_inputs(array.span());

            self.trunk.read(key_hash)
        }
    }

    fn assert_address_not_zero(address: ContractAddress) {
        assert(!address.is_zero(),'NON_VALID_ADDRESS');
    }

    fn set_sn_keccak256(ref buffer: Array<u256>, address: ContractAddress, password: felt252) {
        let u256_address: u256 = addr_to_u256(address);
        let u256_password: u256 = password.into();
        buffer.append(u256_address);
        buffer.append(u256_password);
    }

    fn addr_to_u256(address: ContractAddress) -> u256 {
        let felt_address: felt252 = address.into();
        let u256_address: u256 = felt_address.into();
        u256_address
    }
}

#[cfg(test)]
mod tests {
    mod assert_test;

    use super::hash::{
        assert_address_not_zero,
        set_sn_keccak256,
        addr_to_u256
    };
}