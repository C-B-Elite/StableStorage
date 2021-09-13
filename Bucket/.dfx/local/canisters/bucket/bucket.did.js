export const idlFactory = ({ IDL }) => {
  const BucketIndex = IDL.Record({
    'key' : IDL.Vec(IDL.Nat8),
    'bucket_id' : IDL.Principal,
  });
  const Bucket = IDL.Service({
    'addOwner' : IDL.Func([IDL.Principal], [IDL.Bool], []),
    'change' : IDL.Func(
        [IDL.Vec(IDL.Nat8), IDL.Vec(IDL.Vec(IDL.Nat8))],
        [IDL.Opt(IDL.Vec(IDL.Vec(IDL.Nat8)))],
        [],
      ),
    'delOwner' : IDL.Func([IDL.Principal], [IDL.Bool], []),
    'delete' : IDL.Func(
        [IDL.Vec(IDL.Nat8)],
        [IDL.Opt(IDL.Vec(IDL.Vec(IDL.Nat8)))],
        [],
      ),
    'get' : IDL.Func(
        [IDL.Vec(IDL.Nat8)],
        [IDL.Opt(IDL.Vec(IDL.Vec(IDL.Nat8)))],
        ['query'],
      ),
    'getBalance' : IDL.Func([], [IDL.Nat], ['query']),
    'getMemory' : IDL.Func([], [IDL.Nat], ['query']),
    'put' : IDL.Func(
        [IDL.Vec(IDL.Nat8), IDL.Vec(IDL.Vec(IDL.Nat8))],
        [IDL.Opt(BucketIndex)],
        [],
      ),
    'wallet_receive' : IDL.Func([], [IDL.Nat], []),
  });
  return Bucket;
};
export const init = ({ IDL }) => { return [IDL.Principal]; };
