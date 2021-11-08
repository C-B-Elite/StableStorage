import D "mo:base/Debug";
import N32 "mo:base/Nat32";
import S "mo:base/ExperimentalStableMemory";
import T "mo:base/Text";


actor{

    let metadata = T.encodeUtf8("metadata");
    let change = "x";
    let size = N32.fromNat(metadata.size());
    public func grow() : async Nat32{ S.grow(1:Nat32) };
    public func store() : async (){
        S.storeBlob(1:Nat32, metadata);
    };
    public func load() : async Text{
        switch(T.decodeUtf8(S.loadBlob(1, N32.toNat(size)))){
            case null { "load error" };
            case (?t){ t };
        }
    };
    public func offset_store() : async (){
        S.storeBlob((1+size):Nat32, metadata)
    };
    public func offset_load() : async Text{
        switch(T.decodeUtf8(S.loadBlob(1+size, N32.toNat(size)))){
            case null { "load error" };
            case (?t){ t };
        }
    };
    public func multi_load() : async Text{
        switch(T.decodeUtf8(S.loadBlob(1, N32.toNat(size+size)))){
            case null { "load error" };
            case (?t){ t };
        }
    };


}