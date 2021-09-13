export const idlFactory = ({ IDL }) => {
  const testData = IDL.Record({
    'blob' : IDL.Vec(IDL.Vec(IDL.Nat8)),
    'text' : IDL.Text,
  });
  const BucketIndex = IDL.Record({
    'key' : IDL.Text,
    'bucket_id' : IDL.Principal,
  });
  const TrueContainer = IDL.Service({
    'getBalance' : IDL.Func([], [IDL.Nat], ['query']),
    'getBucket' : IDL.Func([IDL.Text], [IDL.Opt(IDL.Principal)], ['query']),
    'getData' : IDL.Func([IDL.Text], [testData], []),
    'getMemory' : IDL.Func([], [IDL.Nat], ['query']),
    'putData' : IDL.Func([IDL.Text, IDL.Text], [IDL.Opt(BucketIndex)], []),
    'wallet_receive' : IDL.Func([], [IDL.Nat], []),
  });
  return TrueContainer;
};
export const init = ({ IDL }) => { return [IDL.Principal]; };
