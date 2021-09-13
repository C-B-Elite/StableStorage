import type { Principal } from '@dfinity/principal';
export interface Bucket {
  'addOwner' : (arg_0: Principal) => Promise<boolean>,
  'change' : (arg_0: Array<number>, arg_1: Array<Array<number>>) => Promise<
      [] | [Array<Array<number>>]
    >,
  'delOwner' : (arg_0: Principal) => Promise<boolean>,
  'delete' : (arg_0: Array<number>) => Promise<[] | [Array<Array<number>>]>,
  'get' : (arg_0: Array<number>) => Promise<[] | [Array<Array<number>>]>,
  'getBalance' : () => Promise<bigint>,
  'getMemory' : () => Promise<bigint>,
  'put' : (arg_0: Array<number>, arg_1: Array<Array<number>>) => Promise<
      [] | [BucketIndex]
    >,
  'wallet_receive' : () => Promise<bigint>,
}
export interface BucketIndex { 'key' : Array<number>, 'bucket_id' : Principal }
export interface _SERVICE extends Bucket {}
