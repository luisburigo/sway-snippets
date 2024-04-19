import {Account} from "fuels";
import {MetadataStorageAbi, MetadataStorageAbi__factory} from "../types";
import {metadataStorage} from "../types/contract-ids.json";
import {decodeMetadata, Metadata} from "./utils";

const txParams = {
    gasPrice: 1,
    gasLimit: 1_000_000,
};

const getContract = (account: Account) =>
    MetadataStorageAbi__factory.connect(metadataStorage, account);

export class UserMetadataContract {
    private contract: MetadataStorageAbi;
    private handleName: string;

    protected constructor(account: Account, handleName: string) {
        this.contract = getContract(account);
        this.handleName = handleName;
    }

    static initialize(account: Account, handleName: string) {
        return new UserMetadataContract(account, handleName);
    }

    async saveMetadata(metadata: Metadata) {
        return this.contract.functions.save(
            this.handleName,
            metadata.key,
            metadata.value
        ).txParams(txParams).call();
    }

    async getMetadata(key: string) {
        const {value} = await this.contract.functions.get(
            this.handleName, key,
        ).txParams(txParams).call();

        if (!value) return null;

        return {key, value} as Metadata;
    }

    async getAll() {
        const {value: metadataBytes, gasUsed} = await this.contract.functions.get_all(this.handleName).get();
        console.log(gasUsed.toString())
        return decodeMetadata(Array.from(metadataBytes));
    }

    get contractABI() {
        return this.contract;
    }
}