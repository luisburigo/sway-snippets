# Storage Metadata
Persistent storage for metadata values of users.

## Explanation
The metadata storage is a combination of StorageMap and StorageVec, where three hashes are generated for the identification of the metadata.

- **metadata_key_id** 
  - Hash for the identification of the metadata key.
  - `sha256(username + sha256("KEY") + metadata_key)`
    ```sway
    // Pre computed sha256("KEY")
    const KEY = 0x5ca24005b740717ba4f3f6bc48a230700e68c2a4b11ecedb96f169f4efaf1f21;
    
    // Hash identifier for the metadata key.
    fn _metadata_key_id(field_id: b256, user_meta_key: b256) -> b256 {
        return sha256((field_id, KEY, user_meta_key));
    }
    ```
- **metadata_value_id** 
  - Hash for the identification of the metadata value.
  - `sha256(username + sha256("VALUE") + metadata_key)`
    ```sway
    // Pre computed sha256("VALUE")
    const VALUE = 0x8ec121c93e4a0de65f26e1500cb501e383531efb2c2ca9ec1d457478d6d3627b;

    // Hash identifier for the value of the metadata.
    fn _metadata_value_id(field_id: b256, user_meta_key: b256) -> b256 {
        return sha256((field_id, VALUE, user_meta_key));
    }
    ```
- **metadata_list_id**
  - Hash for the identification of where the metadata keys of the user will be stored.  
  - `sha256(field_id + sha256("KEY_LIST") + username)`
    ```sway
    // Pre computed sha256("KEY_LIST")
    const KEY_LIST = 0x58c02a1cb3dfa824be1fbcca886a75d519fe83b77d6f1de863e121857427755e;
  
    // Hash identifier for the list of metadata keys.
    fn _metadata_list_id(field_id: b256, user: b256) -> b256 {
        return sha256((field_id, KEY_LIST, user));
    }
    ```

With these three identifiers, it's possible to manage each part of the metadata individually, making it easier to find
the user's metadata list. This solution enhances the retrieval efficiency and cuts down the time taken to look up specific metadata.

## Methods

### Insert
Responsible for saving the user's metadata, this method performs 3 operations:
- Saves the `metadata_value` in the storage, receiving the value as a string and converting it to raw_slice.  
- Checks if this metadata exists, if it doesn't, saves the `metadata_key` in the storage.
- Checks if this metadata exists, if it doesn't, adds the `metadata_key` to the list. 

Implementation of the method:
```sway
#[storage(read, write)]
pub fn insert(self, handle_name: String, key: String, value: String) {
    let user_id = sha256(handle_name);
    let user_metadata_key_id = sha256((user_id, key));
    let metadata_value_id = _metadata_value_id(self.field_id, user_metadata_key_id);
    let metadata_key_id = _metadata_key_id(self.field_id, user_metadata_key_id);
    
    write_slice(metadata_value_id, value.as_bytes().as_raw_slice());
    
    match read_slice(metadata_key_id) {
        Some(_) => (),
        None => {
            write_slice(metadata_key_id, key.as_bytes().as_raw_slice());
            let metadata_list_id = _metadata_list_id(self.field_id, user_id);
            store_user_metadata_list(metadata_list_id, metadata_key_id);
        }
    }
}
```

Example of use:
```sway
storage {
    metadata: StorageMetadata = StorageMetadata {}
}

impl MyContract for Contract {
    #[storage(read, write)]
    fn save() {
        let username = String::from_ascii_str("myuser");
        let meta_key = String::from_ascii_str("com.github");
        let meta_value = String::from_ascii_str("com.github");
        storage.metadata.insert(username, meta_key, meta_value);
    }
}
```

## Get by key
Responsible for fetching the metadata value, in all cases it will always return a String. If it does not exist, 
an empty String will be returned. This method performs 2 operations:
- Generates the hash of the user's `metadata_key`
- Searches for the metadata value in storage

Implementation of the method:
```sway
#[storage(read)]
pub fn get(self, handle_name: String, key: String) -> String {
    let user_id = sha256(handle_name);
    let user_metadata_key_id = sha256((user_id, key));
    let metadata_value_id = _metadata_value_id(self.field_id, user_metadata_key_id);
    
    return load_metadata_field_id(metadata_value_id);
}
```

Example of use:
```sway
storage {
    metadata: StorageMetadata = StorageMetadata {}
}

impl MyContract for Contract {
    #[storage(read, write)]
    fn get() -> String {
        let username = String::from_ascii_str("myuser");
        let meta_key = String::from_ascii_str("com.github");
      
        storage.metadata.get(username, meta_key)
    }
}
```

## Get all
Fetches all metadata for the user, returning Bytes that represent the map of all the user's metadata.
In this method, the following operations are performed:
- Generates the hash of the user's `metadata_list` to perform the list search of the keys
- Loads the list containing a `Vec` of `b256` with the identifiers of the metadata
- Scrolls through the list of keys looking for the value and key of the metadata
- Returns a `Vec` of `String` with its key and value

Implementation of the method:
```sway
#[storage(read)]
pub fn get_all(self, handle_name: String) -> Vec<String> {
    let user_id = sha256(handle_name);
    let metadata_list_id = _metadata_list_id(self.field_id, user_id);
    
    let metadata_ids = load_user_metadata_list(metadata_list_id);
    let mut metadata_values: Vec<String> = Vec::new();

    let mut i = 0;
    while i < metadata_ids.len() {
        let metdata_key = load_metadata_field_id(metadata_ids.get(i).unwrap());

        let user_metadata_key_hash = sha256((user_id, metdata_key));
        let metadata_value_hash = _metadata_value_id(self.field_id, user_metadata_key_hash);
        let metadata_value = load_metadata_field_id(metadata_value_hash);

        metadata_values.push(metdata_key);
        metadata_values.push(metadata_value);
        i += 1;
    }

    return metadata_values;
}
```

Example of use:
```sway
storage {
    metadata: StorageMetadata = StorageMetadata {}
}

impl MyContract for Contract {
    #[storage(read, write)]
    fn get_all() -> Vec<String> {
        let username = String::from_ascii_str("myuser");
        let meta_key = String::from_ascii_str("com.github");
        let meta_value = String::from_ascii_str("com.github");
      
        storage.metadata.insert(username, meta_key, meta_value);
        
        return storage.metadata.get_all(handle_name);
    }
}
```

⚠️ **NOTE**: In the current version of `fuels-ts` (0.0.79) it's not possible to return a `Vec` of `String`. 
To overcome this problem, it has been implemented to return from the contract a `Bytes` representing a map of all user's metadata.

Converting `Vec` of `String` to `Bytes`:
```sway
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
``` 

To make the conversion, each item of the `Vec` of `String` is traversed, where:
- `metadata_vec.get(i)`: Represents the metadata key
- `metadata_vec.get(i + 1)`: Represents the metadata value
