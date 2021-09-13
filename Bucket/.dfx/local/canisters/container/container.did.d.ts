import type { Principal } from '@dfinity/principal';
export interface BucketIndex { 'key' : string, 'bucket_id' : Principal }
export interface Container {
  'getBalance' : () => Promise<bigint>,
  'getBucket' : (arg_0: string) => Promise<[] | [Principal]>,
  'getData' : (arg_0: string) => Promise<testData>,
  'getMemory' : () => Promise<bigint>,
  'putData' : (arg_0: string, arg_1: string) => Promise<[] | [BucketIndex]>,
  'wallet_receive' : () => Promise<bigint>,
}
export interface testData { 'blob' : Array<Array<number>>, 'text' : string }
export interface _SERVICE extends Container {}
