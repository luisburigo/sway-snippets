# Actions Names
Allows the creation of an identifier and configure its metadata to execute a certain action.

## Todo
- [ ] Create a contract to register the names
- [ ] Add to the names contract the possibility of adding metadata
- [ ] Create a standard ABI with the methods of the actions

## Action Executor
This contract provides a standard ABI for action execution, where the contract that wants to execute the action, must follow.

```sway
abi ActionExecutorAbi {
    fn execute();
}
```

## Manager Contracts
In this contract, it has the responsibility to manage names, from its identifier to its metadata, 
storing them in its storage.

### Storage
```sway
// sha256(name + key)
type MetadataKey = b256;

storage {
    // Maps the name to the user's address
    names: StorageMap<String, Identity> = StorageMap {},

    // Maps the metadata of the actions
    metadatas: StorageMap<MetadataKey, ContractId> = StorageMap {},

    // Maps the actions to the execution date of the action
    actions_registers: StorageMap<MetadataKey, u8> = StorageMap {},
}
```

### ABI
#### **ABI** - NameManager
  - `save_name(name: String)`
    - Validates if the name already exists, if it does not exist, saves the name in the storage.
    - The name must be linked to the address of the user who registered it.
  - `get_owner(name: String) -> Identity`
    - If the name does not exist, returns an error.
    - Returns the address of the user who registered the name.

#### **ABI** - MetadataManager
  - `insert(name: String, key: String, value: ContractId)`
    - Validates if the name exists, if it does not exist, returns an error.
    - Validates if the contract contains the methods of the [ABI](#action-executor).
    - The metadata key must be a `sha256(name + key)`.
    - Saves the metadata in the storage.
  - `get(name: String, key: String) -> Option<ContractId>`
    - If the metadata does not exist, returns an `Option::None`.
    - Returns the contract id that contains the methods of the [ABI](#action-executor).

#### **ABI** - ActionManager
- `execute(action: String)`
  - The action must follow the pattern `name/metadata_key`, examples:
    - `nick/transfer`
    - `nick/myaction`
    - `nick/btc`
  - Splits the string by `/` and returns the two values::
    - The first part before the `/` is the name.
    - The second part after the `/` is the metadata key.
    - `fn action_split(action: String) -> (String, String)`.
  - Converts the two strings to `sha256(key + name)` and searches for the metadata.
  - Executes the [Contract](#action-executor) with the saved id.
    - `abi(ActionExecutorAbi, metadata_value)`. 
  - Saves in the storage the execution date of the action.