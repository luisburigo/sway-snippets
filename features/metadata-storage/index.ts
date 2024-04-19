import {Provider, Wallet} from "fuels";
import {UserMetadataContract} from "./ts/metadata";

async function main() {
    const provider = await Provider.create('http://localhost:4000/graphql');
    const wallet = Wallet.fromPrivateKey('0xa449b1ffee0e2205fa924c6740cc48b3b473aa28587df6dab12abc245d1f5298', provider);

    const metadataConfig = {
        github: {
            key: 'com.github',
            value: 'mygithubuser'
        },
        linkedin: {
            key: 'com.linkedin',
            value: 'mylinkuser'
        },
        user: {
            handle: 'myhandle'
        },
    }

    const userMetadata = UserMetadataContract.initialize(wallet, metadataConfig.user.handle);

    await userMetadata.saveMetadata({
        key: 'short.description',
        value: 'Create a string with 150 characters or less. This description will be used in the user profile or...'
    });

    await userMetadata.saveMetadata(metadataConfig.github);

    console.log(await userMetadata.getAll());
    console.log(await userMetadata.getMetadata(metadataConfig.github.key));
}

main();