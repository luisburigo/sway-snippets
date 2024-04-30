import {Address, Provider, Wallet} from "fuels";
import {StringListAbi__factory} from "./types";
import {stringList} from "./types/contract-ids.json";

function convertBytesToNameList(bytes: number[]) {
    const result: string[] = [];

    const [, size] = bytes.splice(0, 2);
    const name = String.fromCharCode(...bytes.splice(0, size));
    result.push(name);

    if (bytes.length) {
        result.push(...convertBytesToNameList(bytes));
    }

    return result;
}

const getContract = async () => {
    const provider = await Provider.create('http://localhost:4000/graphql');
    const wallet = Wallet.fromPrivateKey('0xa449b1ffee0e2205fa924c6740cc48b3b473aa28587df6dab12abc245d1f5298', provider);
    const contractAbi = StringListAbi__factory.connect(stringList, wallet);

    return {contractAbi, wallet, provider};
}

async function main() {
    const {contractAbi, wallet} = await getContract();

    const txParams = {
        gasPrice: 1,
        gasLimit: 2_000_000,
    };

    await contractAbi.functions.register("myhandle").txParams(txParams).call();
    await contractAbi.functions.register("myhandle2").txParams(txParams).call();
    await contractAbi.functions.register("myhandle3").txParams(txParams).call();

    let listResult = await contractAbi.functions.list(wallet.address.toB256()).get();
    let nameList = convertBytesToNameList(Array.from(listResult.value));
    console.log('Owner: ', nameList);
}

// 1000000
// 8992413

main();