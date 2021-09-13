import StableMap "../Utils/StableMap";
import Blob "mo:base/Blob";
import Option "mo:base/Option";
import Prim "mo:⛔";
import Principal "mo:base/Principal";
import Cycles "mo:base/ExperimentalCycles";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import TrieSet "mo:base/TrieSet";
import Error "mo:base/Error";

/**
* defabult, installer is owner
*/
shared(installer_) actor class Bucket() = this{

    private let cycle_limit = 20_000_000_000_000;
    private stable var map = StableMap.defaults<Blob, [Blob]>();
    private stable let installer = installer_.caller;
    private stable var owners = TrieSet.empty<Principal>();
    
    private type BucketIndex = {
        key : Blob;
        bucket_id : Principal;
    };

    private func isOwner(u : Principal) : Bool{
        if(TrieSet.mem<Principal>(owners, u, Principal.hash(u), Principal.equal)){ return true };
        if(Principal.equal(u, installer)){ return true };
        false
    };

    public query(msg) func getBalance() : async Nat{
        if(not isOwner(msg.caller)){ throw Error.reject("you are not the owner of this Bucket") };
        assert(isOwner(msg.caller));
        Cycles.balance()
    };

    public query(msg) func getMemory() : async Nat{
        if(not isOwner(msg.caller)){ throw Error.reject("you are not the owner of this Bucket") };
        assert(isOwner(msg.caller));      
        Prim.rts_memory_size() 
    };

    public query(msg) func get(key : Blob) : async ?[Blob]{
        if(not isOwner(msg.caller)){ throw Error.reject("you are not the owner of this Bucket") };
        assert(isOwner(msg.caller));
        StableMap.get<Blob, [Blob]>(map, key, Blob.hash, Blob.equal)
    };


    public shared(msg) func wallet_receive() : async Nat {
        let available = Cycles.available();
        let accepted = Cycles.accept(Nat.min(available, cycle_limit));
        accepted
    };

    public shared(msg) func addOwner(newOwner : Principal) : async Bool{
        if(not isOwner(msg.caller)){ throw Error.reject("you are not the owner of this Bucket") };
        owners := TrieSet.put<Principal>(owners, newOwner, Principal.hash(newOwner), Principal.equal);
        true
    };

    public shared(msg) func delOwner(o : Principal) : async Bool{
        if(not isOwner(msg.caller)){ throw Error.reject("you are not the owner of this Bucket") };        
        assert(isOwner(msg.caller));
        owners := TrieSet.delete<Principal>(owners, o, Principal.hash(o), Principal.equal);
        true
    };

    public shared(msg) func put(key : Blob, data : [Blob]) : async ?BucketIndex{
        assert(isOwner(msg.caller));
        map := StableMap.put<Blob, [Blob]>(map, key, data, Blob.hash, Blob.equal);
        ?{
            key = key;
            bucket_id = Principal.fromActor(this);
        }
    };

    public shared(msg) func change(key : Blob, data : [Blob]) : async ?[Blob]{
        if(not isOwner(msg.caller)){ throw Error.reject("you are not the owner of this Bucket") };
        assert(isOwner(msg.caller));
        map := StableMap.put<Blob, [Blob]>(map, key, data, Blob.hash, Blob.equal);
        StableMap.get<Blob, [Blob]>(map, key, Blob.hash, Blob.equal)
    };

    public shared(msg) func delete(key : Blob) : async ?[Blob]{
        if(not isOwner(msg.caller)){ throw Error.reject("you are not the owner of this Bucket") };
        assert(isOwner(msg.caller));
        map := StableMap.delete<Blob, [Blob]>(map, key, Blob.hash, Blob.equal);
        StableMap.get<Blob, [Blob]>(map, key, Blob.hash, Blob.equal)
    };



};