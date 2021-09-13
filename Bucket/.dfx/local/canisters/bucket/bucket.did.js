export const idlFactory = ({ IDL }) => {
  const BucketIndex = IDL.Record({
    'key' : IDL.Vec(IDL.Nat8),
    'bucket_id' : IDL.Principal,
  });
  const Bucket = IDL.Service({
    'change' : IDL.Func(
        [IDL.Vec(IDL.Nat8), IDL.Vec(IDL.Vec(IDL.Nat8))],
        [IDL.Opt(IDL.Vec(IDL.Vec(IDL.Nat8)))],
        [],
      ),
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
export const init = ({ IDL }) => { return []; };
