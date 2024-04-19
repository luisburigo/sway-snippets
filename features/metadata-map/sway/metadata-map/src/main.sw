contract;

use std::{
    hash::*,
    string::String,
    storage::storage_vec::*,
    storage::storage_map::*,
    storage::storage_string::*,
};

abi MetadataStorage {
    #[storage(read, write)]
    fn add(metadata_key: String);

    #[storage(read, write)]
    fn add_metadata(handle_name: String, key: String, value: String);

    #[storage(read)]
    fn get(handle_name: String, key: String) -> String;

    #[storage(read)]
    fn get_all() -> Vec<String>;

    // TODO: remove
    #[storage(read)]
    fn get_last() -> String;
}

storage {
    // Store all meta keys string
    metadata_keys: StorageVec<StorageString> = StorageVec {},

    /*
        Map for store all metadatas of user
        Map key is a sha256 of handle_name and metadtata key - sha256((handle_name, metadata_key))
        Map value is a metadata value - String
    */
    metadata_values: StorageMap<b256, StorageString> = StorageMap {},
}

impl MetadataStorage for Contract {
    #[storage(read, write)]
    fn add(metadata_key: String) {
        storage.metadata_keys.push(StorageString {});
        storage.metadata_keys.last().unwrap().write_slice(metadata_key);
    }

    #[storage(read, write)]
    fn add_metadata(handle_name: String, key: String, value: String) {
        let metadata_handle_key = sha256((handle_name, key));
        storage.metadata_values.get(metadata_handle_key).write_slice(value);
    }

    #[storage(read)]
    fn get(handle_name: String, key: String) -> String {
        let metadata_handle_key = sha256((handle_name, key));

        let metadata_storage_value = storage.metadata_values.get(metadata_handle_key);
        return metadata_storage_value.read_slice().unwrap_or(String::new());
    }

    /*  
        TODO: Not working, return always a empty String
    

        #[storage(read)]
        fn get(handle_name: String, key: String) -> String {
            let metadata_handle_key = sha256((handle_name, key));

            let metadata_storage_value = storage.metadata_values.get(metadata_handle_key);
            log(metadata_storage_value.try_read().is_some());
            
            match metadata_storage_value.try_read() {
                Some(_) => {
                    return storage.metadata_values.get(metadata_handle_key).read_slice().unwrap_or(String::new());
                },
                None => {
                    return String::new();
                }
            }
        }
    */

    /*
        Not working:
        Vec of strings in fuels-ts dispatch a error (_FuelError: Invalid u64 data size.)
    */
    #[storage(read)]
    fn get_all() -> Vec<String> {
        let mut metadata_keys: Vec<String> = Vec::new();

        let mut i = 0;
        while i < storage.metadata_keys.len() {
            metadata_keys.push(storage.metadata_keys.get(i).unwrap().read_slice().unwrap());
            i += 1;
        }

        return metadata_keys;
    }

    // TODO: remove
    #[storage(read)]
    fn get_last() -> String {
        let metadata_key = storage.metadata_keys.last().unwrap().read_slice();

        return metadata_key.unwrap_or(String::new());
    }
}
