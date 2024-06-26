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

import type { Vec } from "./common";

export type RawBytesInput = { ptr: BigNumberish, cap: BigNumberish };
export type RawBytesOutput = { ptr: BN, cap: BN };

interface MetadataMapAbiInterface extends Interface {
  functions: {
    add: FunctionFragment;
    add_metadata: FunctionFragment;
    get: FunctionFragment;
    get_all: FunctionFragment;
    get_last: FunctionFragment;
  };

  encodeFunctionData(functionFragment: 'add', values: [StdString]): Uint8Array;
  encodeFunctionData(functionFragment: 'add_metadata', values: [StdString, StdString, StdString]): Uint8Array;
  encodeFunctionData(functionFragment: 'get', values: [StdString, StdString]): Uint8Array;
  encodeFunctionData(functionFragment: 'get_all', values: []): Uint8Array;
  encodeFunctionData(functionFragment: 'get_last', values: []): Uint8Array;

  decodeFunctionData(functionFragment: 'add', data: BytesLike): DecodedValue;
  decodeFunctionData(functionFragment: 'add_metadata', data: BytesLike): DecodedValue;
  decodeFunctionData(functionFragment: 'get', data: BytesLike): DecodedValue;
  decodeFunctionData(functionFragment: 'get_all', data: BytesLike): DecodedValue;
  decodeFunctionData(functionFragment: 'get_last', data: BytesLike): DecodedValue;
}

export class MetadataMapAbi extends Contract {
  interface: MetadataMapAbiInterface;
  functions: {
    add: InvokeFunction<[metadata_key: StdString], void>;
    add_metadata: InvokeFunction<[handle_name: StdString, key: StdString, value: StdString], void>;
    get: InvokeFunction<[handle_name: StdString, key: StdString], StdString>;
    get_all: InvokeFunction<[], Vec<StdString>>;
    get_last: InvokeFunction<[], StdString>;
  };
}
