import StableMap "../Type/StableMap";
import Blob "mo:base/Blob";
import Option "mo:base/Option";
import Prim "mo:⛔";
import Principal "mo:base/Principal";
import Cycles "mo:base/ExperimentalCycles";
import Nat "mo:base/Nat";
import Array "mo:base/Array";

shared(installer) actor class Bucket() = this{

    private let limit = 20_000_000_000_000;

    private stable var map = StableMap.defaults<Blob, [Blob]>();

    private type BucketIndex = {
        key : Blob;
        bucket_id : Principal;
    };

    public func wallet_receive() : async Nat {
        let available = Cycles.available();
        let accepted = Cycles.accept(Nat.min(available, limit));
        accepted
    };

    public query(msg) func getBalance() : async Nat{ Cycles.balance() };

    public query(msg) func getMemory() : async Nat{
        Prim.rts_memory_size()
    };
    
    public shared(msg) func put(key : Blob, data : [Blob]) : async ?BucketIndex{
        map := StableMap.put<Blob, [Blob]>(map, key, data, Blob.hash, Blob.equal);
        ?{
            key = key;
            bucket_id = Principal.fromActor(this);
        }
    };

    public query(msg) func get(key : Blob) : async ?[Blob]{
        StableMap.get<Blob, [Blob]>(map, key, Blob.hash, Blob.equal)
    };

    public shared(msg) func change(key : Blob, data : [Blob]) : async ?[Blob]{
        map := StableMap.put<Blob, [Blob]>(map, key, data, Blob.hash, Blob.equal);
        StableMap.get<Blob, [Blob]>(map, key, Blob.hash, Blob.equal)
    };

    public shared(msg) func delete(key : Blob) : async ?[Blob]{
        map := StableMap.delete<Blob, [Blob]>(map, key, Blob.hash, Blob.equal);
        StableMap.get<Blob, [Blob]>(map, key, Blob.hash, Blob.equal)
    };





};