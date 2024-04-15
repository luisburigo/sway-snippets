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

export type RawBytesInput = { ptr: BigNumberish, cap: BigNumberish };
export type RawBytesOutput = { ptr: BN, cap: BN };

interface MetadataStorageAbiInterface extends Interface {
  functions: {
    get: FunctionFragment;
    get_all: FunctionFragment;
    save: FunctionFragment;
  };

  encodeFunctionData(functionFragment: 'get', values: [StdString, StdString]): Uint8Array;
  encodeFunctionData(functionFragment: 'get_all', values: [StdString]): Uint8Array;
  encodeFunctionData(functionFragment: 'save', values: [StdString, StdString, StdString]): Uint8Array;

  decodeFunctionData(functionFragment: 'get', data: BytesLike): DecodedValue;
  decodeFunctionData(functionFragment: 'get_all', data: BytesLike): DecodedValue;
  decodeFunctionData(functionFragment: 'save', data: BytesLike): DecodedValue;
}

export class MetadataStorageAbi extends Contract {
  interface: MetadataStorageAbiInterface;
  functions: {
    get: InvokeFunction<[handle_name: StdString, key: StdString], StdString>;
    get_all: InvokeFunction<[handle_name: StdString], Bytes>;
    save: InvokeFunction<[handle_name: StdString, key: StdString, value: StdString], void>;
  };
}
