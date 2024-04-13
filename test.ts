import {
    Wallet,
    hexlify,
    Provider,
} from "fuels";
import {MetadataStorageAbi__factory} from "./types";
import {metadataStorage} from "./types/contract-ids.json";
import {toUtf8String} from "ethers";

const getContract = async () => {
    const provider = await Provider.create('http://localhost:4000/graphql');
    const wallet = Wallet.fromPrivateKey('0xa449b1ffee0e2205fa924c6740cc48b3b473aa28587df6dab12abc245d1f5298', provider);
    const metadataStorageAbi = MetadataStorageAbi__factory.connect(metadataStorage, wallet);

    return {metadataStorageAbi, wallet, provider};
}

const asciiStrBytes = (value: string) => value.split('').map(a => a.charCodeAt(0));
const strBytesAscii = (bytes: number[]) => bytes.map(a => String.fromCharCode(a)).join('');

async function saveAsBytes() {
    const {metadataStorageAbi, wallet} = await getContract();

    const addMetadataResult = await metadataStorageAbi.functions.add(wallet.address.toHexString(), {
        key: asciiStrBytes('com.github'),
        value: asciiStrBytes('luisburigo'),
        // metadata_type: asciiStrBytes('text'),
    }).call();

    // 0xfa62818059ef1c45b55ee44a76dfdfd17e2bd9d33c3ff33ef0532e9a28a863e2
    // 0xfa62818059ef1c45b55ee44a76dfdfd17e2bd9d33c3ff33ef0532e9a28a863e2
    console.log(addMetadataResult.logs)

    const userMetadataList = await metadataStorageAbi.functions.get_all(wallet.address.toHexString()).call();
    
    console.log(userMetadataList.logs);
    console.log(userMetadataList.value);
}

// saveAndReadAll();
saveAsBytes();

