import {Provider, Wallet} from "fuels";
import {NftContractAbi__factory} from "./types";
import {nftContract} from "./types/contract-ids.json";

const getContract = async () => {
    const provider = await Provider.create('http://localhost:4000/graphql');
    const wallet = Wallet.fromPrivateKey('0xa449b1ffee0e2205fa924c6740cc48b3b473aa28587df6dab12abc245d1f5298', provider);
    const contractABI = NftContractAbi__factory.connect(nftContract, wallet);

    const txParams = {
        gasPrice: 1,
        gasLimit: 1_000_000,
    };

    return {contractABI, wallet, provider, txParams};
}

async function main() {
    const {contractABI, txParams} = await getContract();

    const profile = {
        name: '@myname',
    };

    // Create profile and mint nft
    const registerCallResult = await contractABI
        .functions
        .register(profile.name)
        .txParams(txParams)
        .call();
    const assetId = registerCallResult.value;
    console.log('Asset ID: ', assetId);

    await contractABI.functions.set_name(assetId, 'Pixel NFT').txParams(txParams).call();
    await contractABI.functions.set_symbol(assetId, 'PNFT').txParams(txParams).call();

    // Get nft name
    const nftName = await contractABI
        .functions
        .name(assetId)
        .txParams(txParams)
        .call();
    console.log('NFT Name: ', nftName.value);

}

main();