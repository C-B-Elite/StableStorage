import StableMap "../Utils/StableMap";
import Blob "mo:base/Blob";
import Prim "mo:⛔";
import Principal "mo:base/Principal";
import Cycles "mo:base/ExperimentalCycles";
import Nat "mo:base/Nat";
import TrieSet "mo:base/TrieSet";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Int "mo:base/Int";
import Time "mo:base/Time";

/**
* defabult, init_owner is owner
*/
shared(installer) actor class Bucket(init_owner_ : Principal, gc : Text) = this{

    private let cycle_limit = 20_000_000_000_000;
    private stable var map = StableMap.defaults<Blob, [Blob]>();
    private stable let init_owner = init_owner_;
    private stable var owners = TrieSet.empty<Principal>();
    //2G or 4G - 196608 byte
    private stable let threshold = if(gc == "coping"){
            2147287040
        }else if(gc == "compacting"){
            4294770688
        }else{
            2147287040
        };

    private type BucketIndex = {
        key : Blob;
        bucket_id : Principal;
    };

    private func isOwner(u : Principal) : Bool{
        if(TrieSet.mem<Principal>(owners, u, Principal.hash(u), Principal.equal)){ return true };
        if(Principal.equal(u, init_owner)){ return true };
        false
    };

    public query(msg) func getTime() : async Nat{
        Int.abs(Time.now())
    };

    public query(msg) func getGcType() : async Text{
        if(not isOwner(msg.caller)){ throw Error.reject("you are not the owner of this Bucket") };
        assert(isOwner(msg.caller));
        if(threshold == 2147287040){
            "coping"
        }else{
            "compacting"
        }
    };

    public query(msg) func getBalance() : async Nat{
        if(not isOwner(msg.caller)){ throw Error.reject("you are not the owner of this Bucket") };
        assert(isOwner(msg.caller));
        Cycles.balance()
    };

    public query(msg) func getMemory() : async Text{
        if(not isOwner(msg.caller)){ throw Error.reject("you are not the owner of this Bucket") };
        assert(isOwner(msg.caller));      
        "RTS_Memory : " # Nat.toText(Prim.rts_memory_size()) # "\n"
        # "RTS Heap Memory : " # Nat.toText(Prim.rts_heap_size()) # "\n"
        # "RTS Total Alive Size : " # Nat.toText(Prim.rts_max_live_size()) # "\n"
        # "RTS Available Memory Size : " # Nat.toText(threshold - Prim.rts_heap_size())
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

    /**
    *   append : append more [blob] to the same file
    *       true : append chunk ; false : new data chunk
    */
    public shared(msg) func put(key : Blob, data : [Blob], append : Bool) : async ?BucketIndex{
        if(not isOwner(msg.caller)){ throw Error.reject("you are not the owner of this Bucket") };        
        assert(isOwner(msg.caller));
        if(append){
            let pre = switch(StableMap.get<Blob, [Blob]>(map, key, Blob.hash, Blob.equal)){
                case null { [] };
                case (?data){ data };
            };
            //need improve
            let new = Array.append<Blob>(pre, data);
            map := StableMap.put<Blob, [Blob]>(map, key, new, Blob.hash, Blob.equal);
        }else{
            map := StableMap.put<Blob, [Blob]>(map, key, data, Blob.hash, Blob.equal);
        };
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
