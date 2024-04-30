/* Autogenerated file. Do not edit manually. */

/* tslint:disable */
/* eslint-disable */

/*
  Fuels version: 0.79.0
  Forc version: 0.49.3
  Fuel-Core version: 0.22.1
*/

import type {
  BigNumberish,
  BN,
  Bytes,
  BytesLike,
  Contract,
  DecodedValue,
  FunctionFragment,
  Interface,
  InvokeFunction,
  StdString,
} from 'fuels';

export type AddressInput = { value: string };
export type AddressOutput = AddressInput;
export type RawBytesInput = { ptr: BigNumberish, cap: BigNumberish };
export type RawBytesOutput = { ptr: BN, cap: BN };

interface StringListAbiInterface extends Interface {
  functions: {
    list: FunctionFragment;
    register: FunctionFragment;
    transfer_name: FunctionFragment;
  };

  encodeFunctionData(functionFragment: 'list', values: [string]): Uint8Array;
  encodeFunctionData(functionFragment: 'register', values: [StdString]): Uint8Array;
  encodeFunctionData(functionFragment: 'transfer_name', values: [StdString, AddressInput]): Uint8Array;

  decodeFunctionData(functionFragment: 'list', data: BytesLike): DecodedValue;
  decodeFunctionData(functionFragment: 'register', data: BytesLike): DecodedValue;
  decodeFunctionData(functionFragment: 'transfer_name', data: BytesLike): DecodedValue;
}

export class StringListAbi extends Contract {
  interface: StringListAbiInterface;
  functions: {
    list: InvokeFunction<[address: string], Bytes>;
    register: InvokeFunction<[value: StdString], void>;
    transfer_name: InvokeFunction<[name: StdString, new_owner: AddressInput], void>;
  };
}