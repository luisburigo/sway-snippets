contract;

use std::{
    hash::*,
    bytes::*,
    string::*,
    storage::storage_map::*,
    storage::storage_vec::*,
    storage::storage_key::*,
    storage::storage_bytes::*,
    storage::storage_string::*,
    storage::storable_slice::*,
    bytes_conversions::u16::*,
    primitive_conversions::u64::*,
};

struct MetadataInput {
    key: String,
    value: String,
}

struct Metadata {
    key: String,
    value: String,
}

struct MetadataOutput {
    key: Bytes,
    value: Bytes,
}

abi MetadataBytesContract {
    #[storage(write)]
    fn add_meta_key(metadata: MetadataInput);

    #[storage(read, write)]
    fn add(username: String, metadata: Metadata);

    #[storage(read)]
    fn get_all(username: String) -> Bytes;
}

//// 
/// write(username, sha256(username, key): b256, value: Bytes)
/// read(sha256(username, key): b256) -> Bytes

/// write(username, key: Bytes, value: Bytes)
///     metadataKey = sha256(username, key); ✅
//     -> metadata_values[metadataKey] = value
//     -> require(metadata_types.includes(type));
//     -> metadata_keys[username] = metadata_keys[username].push({ key, type }.into_bytes());
/// read(username, key) -> Bytes
//     -> sha256(username, key)
// readAll(username) -> 
//     -> sha256(username, key)

storage {
    metadata_values: StorageMap<b256, StorageString> = StorageMap::<b256, StorageString> {},
    metadata_keys: StorageVec<StorageString> = StorageVec {},
    // metadata_types: StorageMap<b256, StorageString> = StorageVec {},

    // metadata_keys: StorageMap<b256, StorageString> = StorageMap::<b256, StorageString> {},
    // sha256(username): [Bytes()]
    
    // metadata_keys: StorageMap<b256, StorageVec<StorageBytes>> = StorageMap {},

    // // Bytes(metadata type)
    
}

#[storage(read)]
fn create_metadata_key(username: String, key: String) -> b256 {
    return sha256((Bytes::from(username.as_raw_slice()), Bytes::from(key.as_raw_slice())));
}

impl MetadataBytesContract for Contract {
    #[storage(write)]
    fn add_meta_key(metadata: MetadataInput) {
        storage.metadata_keys.push(StorageString {});
        let keys_len = storage.metadata_keys.len();
        storage.metadata_keys.get(keys_len - 1).unwrap().write_slice(metadata.key);
    }

    #[storage(read, write)]
    fn add(username: String, metadata: Metadata) {
        let metadata_values_key = create_metadata_key(username, metadata.key);
        log(metadata_values_key);
        let key_of_string = storage.metadata_values.get(metadata_values_key);
        key_of_string.write_slice(metadata.value);
        log(key_of_string.read_slice().is_some());
    }

    #[storage(read)]
    fn get_all(username: String) -> Bytes {
        let mut metadata_bytes = Bytes::new();

        let mut i = 0;
        log(storage.metadata_keys.len());
        while i < storage.metadata_keys.len() {
            match storage.metadata_keys.get(i) {
                Option::Some(metadata_index) => {
                    let metadata_key = metadata_index.read_slice().unwrap();
                    let metadata_values_key = create_metadata_key(username, metadata_key);
                    log(metadata_values_key);
                    let value_slice = storage.metadata_values.get(metadata_values_key).read_slice();

                    match value_slice {
                        Some(value) => {
                            let key_bytes = metadata_key.as_bytes();
                            let value_bytes = value.as_bytes();
                            metadata_bytes.append(key_bytes.len().try_as_u16().unwrap().to_be_bytes());
                            metadata_bytes.append(key_bytes);
                            metadata_bytes.append(value_bytes.len().try_as_u16().unwrap().to_be_bytes());
                            metadata_bytes.append(value_bytes);
                        },
                        _ => (),
                    }
                },
                Option::None => (),
            }
            i += 1;
        }

        return metadata_bytes;
    }
}