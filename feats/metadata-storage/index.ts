import {MetadataStorageAbi__factory} from "./types";
import {metadataStorage} from "./types/contract-ids.json";
import {Provider, Wallet} from "fuels";

const strBytesAscii = (bytes: number[]) => bytes.map(a => String.fromCharCode(a)).join('');

function bytesToNumber(byteArray: number[]) {
    if (byteArray.length !== 2) {
      throw new Error('Array must contain exactly 2 bytes');
    }
    return (byteArray[0] << 8) + byteArray[1];
}

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

const getContract = async () => {
    const provider = await Provider.create('http://localhost:4000/graphql');
    const wallet = Wallet.fromPrivateKey('0xa449b1ffee0e2205fa924c6740cc48b3b473aa28587df6dab12abc245d1f5298', provider);
    const contractABI = MetadataStorageAbi__factory.connect(metadataStorage, wallet);

    const txParams = {
        gasPrice: 1,
        gasLimit: 1_000_000,
    };

    return {contractABI, wallet, provider, txParams};
}

async function main() {
    const {contractABI, txParams} = await getContract();

    const metadataConfig = {
        github: {
            // key: 'com.github90',
            key: 'com.github',
            value: 'mygithubuser'
        },
        linkedin: {
            key: 'com.linkedin90',
            value: 'mylinkuser'
        },
        user: {
            handle: 'myhandle'
        },
    }

    await contractABI.functions.save(
        metadataConfig.user.handle,
        metadataConfig.github.key,
        metadataConfig.github.value
    ).txParams(txParams).call();

    await contractABI.functions.save(
        metadataConfig.user.handle,
        metadataConfig.linkedin.key,
        metadataConfig.linkedin.value
    ).txParams(txParams).call();

    const githubMetadataResult = await contractABI.functions.get(
        metadataConfig.user.handle,
        metadataConfig.github.key,
    ).txParams(txParams).get();
    console.log('Github: ', githubMetadataResult.value);

    const linkedinMetadataResult = await contractABI.functions.get(
        metadataConfig.user.handle,
        metadataConfig.linkedin.key,
    ).txParams(txParams).get();
    console.log('Linkedin: ', linkedinMetadataResult.value);

    const userMetadata = await contractABI.functions.get_all(metadataConfig.user.handle).call();
    console.log('User metadata: ', decodeMetadata(Array.from(userMetadata.value)), userMetadata.gasUsed.toString());
}

main();