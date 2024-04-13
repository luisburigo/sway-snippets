contract;

use std::{
    hash::*,
    bytes::*,
    string::*,
    storage::storage_map::*,
    storage::storage_vec::*,
    storage::storage_key::*,
    storage::storage_bytes::*,
};

struct Metadata {
    key: Bytes,
    value: Bytes,
    // metadata_type: Bytes,
}

abi MetadataBytesContract {
    #[storage(read, write)]
    fn add(username: String, metadata: Metadata);

    #[storage(read)]
    fn get_all(username: String) -> Vec<Metadata>;
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
    // sha256(username, key): Bytes(matadata value)
    metadata_values: StorageMap<b256, StorageBytes> = StorageMap {},

    // sha256(username): [Bytes()]
    metadata_keys: StorageMap<b256, StorageVec<StorageBytes>> = StorageMap {},

    // Bytes(metadata type)
    metadata_types: StorageVec<StorageBytes> = StorageVec {},
}

fn create_metadata_key(username: Bytes, key: Bytes) -> b256 {
    return sha256((username, key));
}

impl MetadataBytesContract for Contract {
    #[storage(read, write)]
    fn add(username: String, metadata: Metadata) {
        // let metadata_key = create_metadata_key(username.into(), metadata.key);
        let metadata_key = sha256(1u8);

        log(metadata_key);
        log(storage.metadata_values.get(metadata_key).try_read().is_some());
        storage.metadata_values.insert(metadata_key, StorageBytes {});
        storage.metadata_values.get(metadata_key).write_slice(metadata.value);

        // Check values has inserted
        // let metadata_value = storage.metadata_values.get(metadata_key).try_read();

        // match metadata_value {
        //     Some(_) => {
        //         log(1);
        //         // Update metadata value
        //         storage.metadata_values.get(metadata_key).write_slice(metadata.value);
        //     },
        //     None => {
        //         log(2);
        //         // Start storage of values
        //         storage.metadata_values.insert(metadata_key, StorageBytes {});

        //         // Write metadata value
        //         storage.metadata_values.get(metadata_key).write_slice(metadata.value);

        //         // Try start storage of keys
        //         let user_hash = sha256(username);
        //         storage.metadata_keys.try_insert(user_hash, StorageVec {});
        //         storage.metadata_keys.get(user_hash).push(StorageBytes {});
        //         let storage_key = storage.metadata_keys.get(user_hash).last().unwrap();
        //         storage_key.write_slice(metadata.key);
        //     },
        // }
    }

    #[storage(read)]
    fn get_all(username: String) -> Vec<Metadata> {
        // let metadata_keys = storage.metadata_keys.get(sha256(username));
        let metadata_key = sha256(1u8);
        let metadata_value = storage.metadata_values.get(metadata_key).try_read();

        match metadata_value {
            Some(value) => {
                let mut vec = Vec::new();
                vec.push(Metadata {
                    key: Bytes::new(),
                    value: Bytes::new(),
                });
                return vec;
            },
            None => {
                log(2);
                return Vec::new();
            },
        }
        

        let mut metadata_vec = Vec::new();
        // let mut count = 0;

        // while count < metadata_keys.len() {
            
        // }

        return metadata_vec;
    }
}