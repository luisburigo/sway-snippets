contract;

use std::{
    hash::*,
    constants::*,
    bytes::Bytes,
    string::String,
    alloc::{alloc_bytes, alloc},
    storage::storage_vec::*,
    storage::storage_api::*,
    storage::storage_map::*,
    storage::storage_bytes::*,
    bytes_conversions::u16::*,
    primitive_conversions::u64::*,
    primitive_conversions::b256::*,
    intrinsics::{size_of, size_of_val},
};

struct FuelDomain {
    name: String,
    owner: b256,
    resolver: b256,
}

impl FuelDomain {
    pub fn new(name: String, owner: b256, resolver: b256) -> Self {
        Self {
            name,
            owner,
            resolver,
        }
    }

    pub fn from_bytes(bytes: Bytes) -> Self {
        let (left, right) = bytes.split_at(2);
        let name_len = left.get(1).unwrap();
        let (name_bytes, right) = right.split_at(name_len.as_u64());
        let name = String::from(name_bytes);
        
        let (left, right) = right.split_at(2);
        let address_len = left.get(1).unwrap();
        let (owner_bytes, right) = right.split_at(address_len.as_u64());
        let owner = b256::try_from(owner_bytes).unwrap();

        let (left, right) = right.split_at(2);
        let address_len = left.get(1).unwrap();
        let (resolver_bytes, _) = right.split_at(address_len.as_u64());
        let resolver = b256::try_from(resolver_bytes).unwrap();

        return Self {
            name,
            owner,
            resolver,
        };
    }

    pub fn to_bytes(self) -> Bytes {
        let mut bytes = Bytes::new();
        bytes.append(self.name.as_bytes().len().try_as_u16().unwrap().to_be_bytes());
        bytes.append(self.name.as_bytes());
        bytes.append(Bytes::from(self.owner).len().try_as_u16().unwrap().to_be_bytes());
        bytes.append(Bytes::from(self.owner));
        bytes.append(Bytes::from(self.resolver).len().try_as_u16().unwrap().to_be_bytes());
        bytes.append(Bytes::from(self.resolver));
        return bytes;
    }
}

/*
    NameHash + sha256("OWNER") -> Owner 
    NameHash + sha256("RESOLVER") -> Resolver 
    NameHash + sha256("NAME") -> Name String 
*/ 


abi MyContract {
    #[storage(write)]
    fn register(value: String);

    #[storage(read)]
    fn list(address: b256) -> Bytes;

    #[storage(read, write)]
    fn transfer_name(name: String, new_owner: Address);
}

type NameHash = b256;

storage {
    names: StorageMap<NameHash, StorageBytes> = StorageMap {},
    owners: StorageMap<Address, StorageVec<NameHash>> = StorageMap {},
}

fn msg_sender_address() -> Address {
    match std::auth::msg_sender().unwrap() {
        Identity::Address(identity) => identity,
        _ => revert(0),
    }
}

impl MyContract for Contract {
    #[storage(write)]
    fn register(value: String) {
        let owner_address = msg_sender_address();
        let name_hash: NameHash = sha256(value);

        let domain = FuelDomain::new(
            value, 
            owner_address.into(), 
            owner_address.into()
        );
        let bytes = domain.to_bytes();

        let domain = FuelDomain::from_bytes(bytes);

        storage.names.insert(name_hash, StorageBytes {});
        storage.names.get(name_hash).write_slice(bytes);

        storage.owners.insert(owner_address, StorageVec {});
        storage.owners.get(owner_address).push(name_hash);
    }

    #[storage(read)]
    fn list(address: b256) -> Bytes {
        let mut names: Bytes = Bytes::new();
        let names_hashes = storage.owners.get(Address::from(address)).load_vec();

        let mut i = 0;
        while i < names_hashes.len() {
            let name_hash = names_hashes.get(i).unwrap();
            let name_bytes = storage.names.get(name_hash).read_slice().unwrap();
      let test = FuelDomain::from_bytes(name_bytes);
            // let name_bytes = String::from_ascii_str("Teste").as_bytes();

            names.append(test.name.as_bytes().len().try_as_u16().unwrap().to_be_bytes());
            names.append(test.name.as_bytes());

            i += 1;
        }

        return names;
    }

    #[storage(read, write)]
    fn transfer_name(name: String, new_owner: Address) {
        let owner_address = msg_sender_address();
        let name_hash: NameHash = sha256(name);

        let name_bytes = storage.names.get(name_hash).read_slice();
        let mut name_domain = FuelDomain::from_bytes(name_bytes.unwrap());
        if name_domain.owner != owner_address.into() {
            revert(0);
        }

        name_domain.owner = new_owner.into();
        let new_name_bytes = name_domain.to_bytes();
        storage.names.get(name_hash).write_slice(new_name_bytes);
        
        let names_hashes = storage.owners.get(owner_address).load_vec();

        let mut i = 0;
        while i < names_hashes.len() {
            if names_hashes.get(i).unwrap() == name_hash {
                storage.owners.get(owner_address).remove(i);
                break;
            }
        }

        storage.owners.insert(new_owner, StorageVec {});
        storage.owners.get(new_owner).push(name_hash);
    }
}

#[test]
fn test_contract() {
    // let contract_abi = abi(MyContract, CONTRACT_ID);

    // contract_abi.register(String::from_ascii_str("name1"));
    // let names = contract_abi.list();
    // assert(names.len() == 1);

    // contract_abi.register(String::from_ascii_str("name2"));
    // let names = contract_abi.list();
    // assert(names.len() == 2);

    // contract_abi.transfer_name(
    //     String::from_ascii_str("name1"), 
    //     Address::from(sha256(0x02134))
    // );
    // let names = contract_abi.list();
    // assert(names.len() == 1);

    // let names = contract_abi.list();
    // assert(names.len() == 1);
}

struct Test {
    name: String,
    name2: String,
}

#[test]
fn test_struct_bytes() {
    let name = String::from_ascii_str("Teste").as_bytes();
    let address = Bytes::from(sha256(0x02134));

    let mut bytes = Bytes::new();
    bytes.append(name.len().try_as_u16().unwrap().to_be_bytes());
    bytes.append(name);
    bytes.append(address.len().try_as_u16().unwrap().to_be_bytes());
    bytes.append(address);

    let (left, right) = bytes.split_at(2);
    assert(left.len() == 2);

    let name_len = left.get(1).unwrap();
    log(name_len);
    assert(name_len == name.len.try_as_u8().unwrap());
 }