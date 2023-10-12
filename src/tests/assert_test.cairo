use starknet::contract_address::{contract_address_const};
use starknet::{ContractAddress};
use array::{ArrayTrait};

use super::{
    assert_address_not_zero,
    set_sn_keccak256,
    addr_to_u256
};

#[test]
#[available_gas(3000)]
fn assert_on_valid_address() {
    let valid_address: ContractAddress = contract_address_const::<0x1234>();
    assert_address_not_zero(valid_address);
}

#[test]
#[available_gas(3000)]
#[should_panic(expected: ('NON_VALID_ADDRESS', ))]
fn assert_on_invalid_address() {
    let non_valid_address: ContractAddress = contract_address_const::<0x0000>();
    assert_address_not_zero(non_valid_address);
}

#[test]
#[available_gas(25000)]
fn preset_keccak_function() {
    // the caller address
    let contract_address: ContractAddress = contract_address_const::<0x1234>();
    // the password, little bit as a salt
    let password: felt252 = 'plain_text';

    let mut array: Array<u256> = ArrayTrait::new();
    set_sn_keccak256(ref array, contract_address, password);

    assert(
        *array[0] == 0x1234_u256, ''
    );
     assert(
        *array[1] == 0x706c61696e5f74657874_u256, ''
    );
}

#[test]
#[available_gas(7000)]
fn convert_an_address_to_u256() {
    let contract_address: ContractAddress = contract_address_const::<0x1234>();
    
    // ContractAddress to felt252 -> felt252 to u256
    let u256_contract_address: u256 = addr_to_u256(contract_address);
    assert(u256_contract_address == 0x1234_u256, '');
}