library;

use std::{
    hash::*,
    vec::Vec,
    bytes::Bytes,
    string::String,
    storage::storage_api::*,
    storage::storage_key::*,
    storage::storable_slice::*,
    alloc::{alloc_bytes, realloc_bytes},
};

// Pre computed sha256("KEY")
const KEY = 0x5ca24005b740717ba4f3f6bc48a230700e68c2a4b11ecedb96f169f4efaf1f21;

// Pre computed sha256("KEY_LIST")
const KEY_LIST = 0x58c02a1cb3dfa824be1fbcca886a75d519fe83b77d6f1de863e121857427755e;

// Pre computed sha256("VALUE")
const VALUE = 0x8ec121c93e4a0de65f26e1500cb501e383531efb2c2ca9ec1d457478d6d3627b;

// A persistent storage type to metadata.
pub struct StorageMetadata {}

// METHODS:
// insert -> receive the user handle name, the metadata key and the metadata value.
//           storage.metadata.insert('handle_name', 'meta_key', 'meta_value');

// Hash identifier for the metadata key.
pub fn hash_key(field_id: b256, user_meta_key: b256) -> b256 {
    return sha256((field_id, KEY, user_meta_key));
}

// Hash identifier for the value of the metadata. 
pub fn hash_key_value(field_id: b256, user_meta_key: b256) -> b256 {
    return sha256((field_id, VALUE, user_meta_key));
}

// Hash identifier for the list of metadata keys.
pub fn hash_key_list(field_id: b256, user: b256) -> b256 {
    return sha256((field_id, KEY_LIST, user));
}

#[storage(read, write)]
pub fn store_user_metadata_list(field_id: b256, value: b256) {
    // Length of the list
    let len = read::<u64>(field_id, 0).unwrap_or(0);

    // Write the new key
    let offset = offset_calculator::<b256>(len);
    write::<b256>(sha256(field_id), offset, value);

    // Incrementing the length
    write(field_id, 0, len + 1);
}

// List of hash identifiers for the metadata keys.
#[storage(read)]
pub fn load_user_metadata_list(field_id: b256) -> Vec<b256> {
    match read::<u64>(field_id, 0).unwrap_or(0) {
        0 => Vec::new(),
        len => {
            // Get the number of storage slots needed based on the size.
            let bytes = len * __size_of::<b256>();
            let number_of_slots = (bytes + 31) >> 5;
            let ptr = alloc_bytes(number_of_slots * 32);
            // Load the stored slice into the pointer.
            let _ = __state_load_quad(sha256(field_id), ptr, number_of_slots);
            Vec::from(asm(ptr: (ptr, bytes)) {
                ptr: raw_slice
            })
        }
    }
}

#[storage(read)]
pub fn load_metadata_key(field_id: b256) -> String {
    match read_slice(field_id) {
        Some(slice) => String::from(slice),
        None => String::new(),
    }
}

#[storage(read)]
pub fn load_metadata_value(field_id: b256) -> String {
    match read_slice(field_id) {
        Some(slice) => String::from(slice),
        None => String::new(),
    }
}

impl StorageKey<StorageMetadata> {
    // Insert method:
    //
    // # Arguments
    // * `handle_name`: String - The owner of metadata.
    // * `metadata`: Bytes - The metadata to be stored.
    //
    #[storage(read, write)]
    pub fn insert(self, handle_name: String, key: String, value: String) {
        let user_hash = sha256(handle_name);
        let user_metadata_key_hash = sha256((user_hash, key));
        
        let metadata_value_hash = hash_key_value(self.field_id, user_metadata_key_hash);
        write_slice(metadata_value_hash, value.as_bytes().as_raw_slice());
        
        let metadata_key_hash = hash_key(self.field_id, user_metadata_key_hash);
        
        match read_slice(metadata_key_hash) {
            Some(_) => (),
            None => {
                write_slice(metadata_key_hash, key.as_bytes().as_raw_slice());
                let metadata_list_hash = hash_key_list(self.field_id, user_hash);
                store_user_metadata_list(metadata_list_hash, metadata_key_hash);
            }
        }
    }
    

    #[storage(read)]
    pub fn get(self, handle_name: String, key: String) -> String {
        let user_hash = sha256(handle_name);
        let user_metadata_key_hash = sha256((user_hash, key));
        let metadata_value_hash = hash_key_value(self.field_id, user_metadata_key_hash);
        
        return load_metadata_key(metadata_value_hash);
    }

    #[storage(read)]
    pub fn get_all(self, handle_name: String) -> Vec<String> {
        let user_hash = sha256(handle_name);
        let metadata_list_hash = hash_key_list(self.field_id, user_hash);
        
        let metadata_keys = load_user_metadata_list(metadata_list_hash);
        let mut metadata_values: Vec<String> = Vec::new();

        let mut i = 0;
        while i < metadata_keys.len() {
            let metdata_key = load_metadata_key(metadata_keys.get(i).unwrap());
            metadata_values.push(metdata_key);

            let user_metadata_key_hash = sha256((user_hash, metdata_key));
            let metadata_value_hash = hash_key_value(self.field_id, user_metadata_key_hash);

            let metadata_value = load_metadata_value(metadata_value_hash);
            metadata_values.push(metadata_value);
            i += 1;
        }

        return metadata_values;
    }
}

// Add padding to type so it can correctly use the storage api
fn offset_calculator<T>(offset: u64) -> u64 {
    let size_in_bytes = __size_of::<T>();
    let size_in_bytes = (size_in_bytes + (8 - 1)) - ((size_in_bytes + (8 - 1)) % 8);
    (offset * size_in_bytes) / 8
}