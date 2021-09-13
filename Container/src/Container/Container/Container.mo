import List "mo:base/List";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Prim "mo:⛔";
import Bucket "../Bucket/Bucket";
import StableMap "../Type/StableMap";
import Types "../Type/Types";

shared(installer) actor class Container() = this{

    private type BucketIndex = {
        key : Text;
        bucket_id : Principal;
    };

    private type BucketInfo = {
        bucket : Bucket.Bucket;
        //threshold - rts_memory_size
        avalMemory : Nat;
    };

    //use trie map will be better
    private stable var kvMap = StableMap.defaults<Blob,  Principal>();
    private stable var bucketMap = StableMap.defaults<Principal, BucketInfo>();
    private let cycleShare = 1_000_000_000_000;
    private let limit = 20_000_000_000_000;
    private let threshold = 2147483648; //  ~2GB
    private let ic = actor "aaaaa-aa" : Types.ICActor;
    private let owner = Principal.fromText("slqa4-73acs-65lmr-d52by-ugflp-4dm7p-i2omo-yrw65-5d7mn-qqcbh-lae");

    private type testData = {
        blob : [Blob];
        text : Text;
    };

    public shared(msg) func putData(key : Text, data : Text) : async ?BucketIndex{
        let blob = Text.encodeUtf8(data);
        let info = switch(getBucketInfo(blob.size())){
            case null { await newBucketInfo() };
            case (?info) { info };
        };
        let temp_bucketIndex = switch((await info.bucket.put(Text.encodeUtf8(key), [blob]))){
            case null { return null };
            case (?i) { i };
        }; 
        var index = {
                        key = Option.unwrap(Text.decodeUtf8(temp_bucketIndex.key));
                        bucket_id = temp_bucketIndex.bucket_id;
                    };
        kvMap := StableMap.put<Blob, Principal>(kvMap, Text.encodeUtf8(key), temp_bucketIndex.bucket_id, Blob.hash, Blob.equal);
        bucketMap := StableMap.put<Principal, BucketInfo>(bucketMap, temp_bucketIndex.bucket_id, info, Principal.hash, Principal.equal);
        ?index
    };

    //key : Text for test
    public query(msg) func getBucket(key : Text) : async ?Principal{
        StableMap.get<Blob, Principal>(kvMap, Text.encodeUtf8(key), Blob.hash, Blob.equal)
    };

    public shared(msg) func getData(key : Text) : async testData{
        var principal = Option.unwrap(StableMap.get<Blob, Principal>(kvMap, Text.encodeUtf8(key), Blob.hash, Blob.equal));
        var data = Option.unwrap(await Option.unwrap(StableMap.get<Principal, BucketInfo>(bucketMap, principal, Principal.hash, Principal.equal)).bucket.get(Text.encodeUtf8(key)));
        {
            blob = data;
            text = Option.unwrap(Text.decodeUtf8(data[0]));
        }
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

    private func newBucketInfo() : async BucketInfo{
        Cycles.add(cycleShare);
        let newBucket = await Bucket.Bucket();
        ignore updateCanister(newBucket);
        let principal = Principal.fromActor(newBucket);
        let am = Int.abs(threshold - (await newBucket.getMemory()));
        ignore StableMap.put(
            bucketMap,
            principal, 
            {
                bucket = newBucket;
                avalMemory = am;
            },
            Principal.hash,
            Principal.equal
        );
        {
            bucket = newBucket;
            avalMemory = am;
        }
    };

    private func updateCanister(a : actor{}) : async () {
        Debug.print("balance before: " # Nat.toText(Cycles.balance()));
        let cid = { canister_id = Principal.fromActor(a)};
        Debug.print("IC status..."  # debug_show(await ic.canister_status(cid)));
        await (ic.update_settings({
                canister_id = cid.canister_id; 
                settings = {
                    controllers = ?[owner, Principal.fromActor(this)];
                    compute_allocation = null;
                    memory_allocation = ?4_294_967_296; // 4GB
                    freezing_threshold = ?31_540_000
                }
            })
        );
    };

    private func getBucketInfo(dataSize : Nat) : ?BucketInfo{
        for((_, info) in Iter.toArray<(Principal, BucketInfo)>(StableMap.entries<Principal, BucketInfo>(bucketMap)).vals()){
            if(info.avalMemory > dataSize){
                return ?{
                    bucket = info.bucket;
                    avalMemory = info.avalMemory;
                }
            }
        };
        null
    };


};