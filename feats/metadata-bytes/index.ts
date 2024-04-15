import {
    Wallet,
    hexlify,
    Provider,
    NumberCoder,
    bn,
} from "fuels";
import {MetadataStorageAbi__factory} from "./types";
import {metadataStorage} from "./types/contract-ids.json";

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

    const txParams = {
        gasPrice: 1,
        gasLimit: 1_000_000,
    };
    const addMetadataKeyResult = await metadataStorageAbi.functions.add_meta_key({
        key: "foo2",
        value: "bar3",
    }).txParams(txParams).call();

    // console.log(addMetadataKeyResult.logs);

    const addMetadataResult = await metadataStorageAbi.functions.add("aaaa", {
        key: "foo2",
        value: "bar3",
    }).txParams(txParams).call();
    // console.log(addMetadataResult.logs);

    // 0xfa62818059ef1c45b55ee44a76dfdfd17e2bd9d33c3ff33ef0532e9a28a863e2
    // 0xfa62818059ef1c45b55ee44a76dfdfd17e2bd9d33c3ff33ef0532e9a28a863e2
    // console.log(addMetadataResult.logs)
    // console.log(addMetadataResult.transactionResult?.status)

    function bytesToNumber(byteArray: number[]) {
        if (byteArray.length !== 2) {
          throw new Error('Array must contain exactly 2 bytes');
        }
        return (byteArray[0] << 8) + byteArray[1];
      }

    const userMetadataList = await metadataStorageAbi.functions.get_all("aaaa").txParams(txParams).call();

    function decodeMetadata(bytes: number[]) {
        const metdata = {};

        function decode(_bytes: number[], index: number) {
            const offset = index + 2;
            const size = bytesToNumber(_bytes.slice(index, offset));
            const value = _bytes.slice(offset, offset + size);
            return [strBytesAscii(value), offset + size] as const;
        }
        function _decodeMetadata(bytes: number[], index: number) {
            if (index >= bytes.length) return;
            const [key, offset] = decode(bytes, index);
            const [value, offset2] = decode(bytes, offset);
            metdata[key] = value;
            _decodeMetadata(bytes, offset2);
        }
        _decodeMetadata(bytes, 0);
        return metdata;
    }

    console.log(userMetadataList.value);
    console.log(decodeMetadata(Array.from(userMetadataList.value)));

    // console.log(userMetadataList.value);
    // console.log(userMetadataList.transactionResult?.receipts);
    console.log(userMetadataList.logs);
}

// saveAndReadAll();
saveAsBytes();

