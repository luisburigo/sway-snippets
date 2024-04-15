import {MetadataMapAbi__factory} from "./types";
import {metadataMap} from "./types/contract-ids.json";
import {Provider, Wallet} from "fuels";

const getContract = async () => {
    const provider = await Provider.create('http://localhost:4000/graphql');
    const wallet = Wallet.fromPrivateKey('0xa449b1ffee0e2205fa924c6740cc48b3b473aa28587df6dab12abc245d1f5298', provider);
    const contractABI = MetadataMapAbi__factory.connect(metadataMap, wallet);

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
    }

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

    /**
        TODO: Not working! fuels-ts(0.79.0) not supporting vector of string
        const allMetaKeys = await contractABI.functions.get_all().txParams(txParams).call();
        console.log(allMetaKeys.value)
    **/
}

main();