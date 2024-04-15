# Metadata Map
Store all metadata values of user in a `StorageMap` and all keys in `StorageVec<StorageString>`.

## Storage
First step is store all metadata keys in a vec
```sway
// Store all meta keys string
metadata_keys: StorageVec<StorageString> = StorageVec {}, 
```

The second step is to store all metadata values in a `StorageMap` and create a `sha256` of `username` and `metadata_key` 
as a key of the map.   
```sway
//  Map for store all metadatas of user
//  Map key is a sha256 of handle_name and metadtata key - sha256((handle_name, metadata_key))
//  Map value is a metadata value - String
metadata_values: StorageMap<b256, StorageString> = StorageMap {},
```

## Methods (ABI)
- ✅ `add(metadata_key: String)` - Add a metadata key to the metadata_keys
- ✅ `add_metadata(handle_name: String, key: String, value: String)` - Add the metadata value of the user.
- ✅ `get(handle_name: String, key: String) -> String` - Get the metadata value of the user.
- [🚫 `get_all() -> Vec<String>` - Get all metadata keys.](#get-all-metadata-keys)

## Problems

### Get all metadata keys
In this method, it should be possible to return a vector of all the metadata_keys, however, the `fuels-ts` decode ends 
up returning an error.

#### Sway
```sway
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
```

#### TS
```ts
const metadataConfig = {
    github: {
        key: 'com.github',
        value: 'mygituser'
    },
    linkedin: {
        key: 'com.linkedin',
        value: 'mylinkuser'
    },
    user: {
        handle: 'myhandle'
    },
};

// Add github metadata key
await contractABI.functions.add(metadataConfig.github.key).txParams(txParams).call();
const githubKey = await contractABI.functions.get_last().txParams(txParams).call();
console.log(githubKey.value);

// Add linkedin metadata key
await contractABI.functions.add(metadataConfig.linkedin.key).txParams(txParams).call();
const linkedinKey = await contractABI.functions.get_last().txParams(txParams).call();
console.log(linkedinKey.value);

// Try get all metadata keys
await contractABI.functions.get_all().get(); // Not working
```

Receive the following error when try to decode the result:
```bash
/sandbox/test-metadata/node_modules/.pnpm/@fuel-ts+abi-coder@0.79.0/node_modules/@fuel-ts/abi-coder/src/encoding/coders/v0/BigNumberCoder.ts:33
      throw new FuelError(ErrorCode.DECODE_ERROR, `Invalid ${this.type} data size.`);
            ^
_FuelError: Invalid u64 data size.
    at BigNumberCoder.decode (/sandbox/test-metadata/node_modules/.pnpm/@fuel-ts+abi-coder@0.79.0/node_modules/@fuel-ts/abi-coder/src/encoding/coders/v0/BigNumberCoder.ts:33:13)
    at StdStringCoder.decode (/sandbox/test-metadata/node_modules/.pnpm/@fuel-ts+abi-coder@0.79.0/node_modules/@fuel-ts/abi-coder/src/encoding/coders/v0/StdStringCoder.ts:59:56)
    at /sandbox/test-metadata/node_modules/.pnpm/@fuel-ts+abi-coder@0.79.0/node_modules/@fuel-ts/abi-coder/src/encoding/coders/v0/VecCoder.ts:67:31
    at Array.map (<anonymous>)
    at VecCoder.decode (/sandbox/test-metadata/node_modules/.pnpm/@fuel-ts+abi-coder@0.79.0/node_modules/@fuel-ts/abi-coder/src/encoding/coders/v0/VecCoder.ts:66:62)
    at FunctionFragment.decodeOutput (/sandbox/test-metadata/node_modules/.pnpm/@fuel-ts+abi-coder@0.79.0/node_modules/@fuel-ts/abi-coder/src/FunctionFragment.ts:211:18)
    at /sandbox/test-metadata/node_modules/.pnpm/@fuel-ts+program@0.79.0_dexie@4.0.4/node_modules/@fuel-ts/program/src/functions/invocation-results.ts:108:19
    at Array.map (<anonymous>)
    at InvocationCallResult.getDecodedValue (/sandbox/test-metadata/node_modules/.pnpm/@fuel-ts+program@0.79.0_dexie@4.0.4/node_modules/@fuel-ts/program/src/functions/invocation-results.ts:106:41)
    at new InvocationResult (/sandbox/test-metadata/node_modules/.pnpm/@fuel-ts+program@0.79.0_dexie@4.0.4/node_modules/@fuel-ts/program/src/functions/invocation-results.ts:60:23) {
  VERSIONS: { FORC: '0.49.3', FUEL_CORE: '0.22.1', FUELS: '0.79.0' },
  code: 'decode-error'
}
```

### Method `try_read()` always returns `None`
When trying to access a key in `StorageMap<b256, StorageString>` and executing the method `try_read()`, it always returns 
`None` even if the key exists.

#### Sway
```sway 
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
```


#### TS
```ts
const metadataConfig = {
    github: {
        key: 'com.github',
        value: 'mygituser'
    },
    linkedin: {
        key: 'com.linkedin',
        value: 'mylinkuser'
    },
    user: {
        handle: 'myhandle'
    },
};

// Add github metadata key
await contractABI.functions.add(metadataConfig.github.key).txParams(txParams).call();
const githubKey = await contractABI.functions.get_last().txParams(txParams).call();
console.log(githubKey.value);

// Add linkedin metadata key
await contractABI.functions.add(metadataConfig.linkedin.key).txParams(txParams).call();
const linkedinKey = await contractABI.functions.get_last().txParams(txParams).call();
console.log(linkedinKey.value);

// Add github metadata value of user
await contractABI.functions.add_metadata(
    metadataConfig.user.handle,
    metadataConfig.github.key,
    metadataConfig.github.value,
).txParams(txParams).call();

// Get github metadata value of user
const userGithubMetadataValue = await contractABI.functions.get(
    metadataConfig.user.handle,
    metadataConfig.github.key
).txParams(txParams).call();
console.log('Github metakey: ', {
    value: userGithubMetadataValue.value,
    isSome: userGithubMetadataValue.logs[0]
});

// Get linkedin metadata value of user
const userLinkedinMetadataValue = await contractABI.functions.get(
    metadataConfig.user.handle,
    metadataConfig.github.key
).txParams(txParams).call();
console.log('Linkedin metakey: ', {
    value: userLinkedinMetadataValue.value,
    isSome: userLinkedinMetadataValue.logs[0]
});
```

The console result: 
```bash
com.github
com.linkedin
Github metakey:  { value: '', isSome: false }
Linkedin metakey:  { value: '', isSome: false }
```