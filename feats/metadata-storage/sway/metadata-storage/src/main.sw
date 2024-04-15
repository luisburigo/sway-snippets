contract;

mod storage_metadata;

use ::storage_metadata::*;

use std::{
    bytes::Bytes,
    string::String,
    bytes_conversions::u16::*,
    primitive_conversions::u64::*,
};

storage {
    metadata: StorageMetadata = StorageMetadata {}
}

abi MyContract {
    #[storage(read, write)]
    fn save(handle_name: String, key: String, value: String);

    #[storage(read)]
    fn get(handle_name: String, key: String) -> String;

    #[storage(read)]
    fn get_all(handle_name: String) -> Bytes;
}

fn vec_metadata_to_bytes(metadata_vec: Vec<String>) -> Bytes {
    let mut metadata_bytes = Bytes::new();

    let mut i = 0;
    while i < metadata_vec.len() {
        let metadata_key = metadata_vec.get(i).unwrap();
        let metadata_value = metadata_vec.get(i + 1).unwrap();

        let key_bytes = metadata_key.as_bytes();
        let value_bytes = metadata_value.as_bytes();
        
        metadata_bytes.append(key_bytes.len().try_as_u16().unwrap().to_be_bytes());
        metadata_bytes.append(key_bytes);
        metadata_bytes.append(value_bytes.len().try_as_u16().unwrap().to_be_bytes());
        metadata_bytes.append(value_bytes);

        i += 2;
    }


    return metadata_bytes;
}

impl MyContract for Contract {
    #[storage(read, write)]
    fn save(handle_name: String, key: String, value: String) {
        storage.metadata.insert(handle_name, key, value);
    }

    #[storage(read)]
    fn get(handle_name: String, key: String) -> String {
        return storage.metadata.get(handle_name, key)
    }

    #[storage(read)]
    fn get_all(handle_name: String) -> Bytes {
        let user_metadata_list = storage.metadata.get_all(handle_name);
        return vec_metadata_to_bytes(user_metadata_list);
    }
}