contract;

use src3::SRC3;
use src20::SRC20;
use src7::{Metadata, SRC7};

use asset::{
    base::{
        _name,
        _set_name,
        _set_symbol,
        _symbol,
        _total_assets,
        _total_supply,
        SetAssetAttributes,
    },
    metadata::*,
    mint::{
        _burn,
        _mint,
    },
};
use std::{
    hash::*,
    bytes::*,
    string::String,
    storage::storage_map::*,
    call_frames::contract_id,
    storage::storage_string::*,
    storage::storage_key::*,
};

storage {
    // NFT
    total_assets: u64 = 0,
    total_supply: StorageMap<AssetId, u64> = StorageMap {},
    metadata: StorageMetadata = StorageMetadata {},

    // PixelNFT
    names: StorageMap<b256, StorageString> = StorageMap {},
}

fn concat_string(string1: String, string2: String) -> String {
    let mut new_string = Bytes::new();
    new_string.append(string1.as_bytes());
    new_string.append(string2.as_bytes());
    
    return String::from(new_string);
}

abi PixelNFTContract {
    #[storage(read, write)]
    fn register(name: String) -> AssetId;
}

impl PixelNFTContract for Contract {
    #[storage(read, write)]
    fn register(name: String) -> AssetId {
        let sender = msg_sender().unwrap();
        let sub_id = sha256(name);

        require(
            storage.names.get(sub_id).try_read().is_none(), 
            "You have already registered a name"
        );

        let asset =  _mint(
            storage
                .total_assets,
            storage
                .total_supply,
            sender,
            sub_id,
            1,
        );

        storage.names.insert(sub_id, StorageString {});
        storage.names.get(sub_id).write_slice(name);

        let image_url_key = String::from_ascii_str("image_url");
        let image_url_value = concat_string(String::from_ascii_str("http://localhost:3002/"), name);
        storage.metadata.insert(asset, image_url_key, Metadata::Bytes(image_url_value.into()));

        return asset;
    }
}

impl SRC20 for Contract {
    #[storage(read)]
    fn total_assets() -> u64 {
        _total_assets(storage.total_assets)
    }

    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        _total_supply(storage.total_supply, asset)
    }

    #[storage(read)]
    fn name(asset: AssetId) -> Option<String> {
        Some(String::from_ascii_str("Pixel NFT"))
    }

    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
         Some(String::from_ascii_str("PNFT"))
    }

    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8> {
        Some(0u8)
    }
}

impl SRC7 for Contract {
    #[storage(read)]
    fn metadata(asset: AssetId, key: String) -> Option<Metadata> {
        storage.metadata.get(asset, key)
    }
}

#[test]
fn test_string_concat() {
    let a = String::from_ascii_str("Hello");
    let b = String::from_ascii_str("World");

    let mut c = Bytes::new();
    c.append(a.as_bytes());
    c.append(b.as_bytes());
    
    assert(String::from(c) == String::from_ascii_str("HelloWorld"));
}