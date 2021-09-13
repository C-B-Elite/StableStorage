import StableMap "../Type/StableMap";
import Blob "mo:base/Blob";
import Option "mo:base/Option";
import Prim "mo:⛔";
import Principal "mo:base/Principal";
import Cycles "mo:base/ExperimentalCycles";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import BloomFilter "BloomFilter";

  /// Manages BloomFilters, deploys new BloomFilters, and checks for element membership across filters.
  /// Args:
  ///   |capacity|    The maximum number of elements a BlooomFilter may store.
  ///   |errorRate|   The maximum false positive rate a BloomFilter may maintain.
  ///   |hashFuncs|   The hash functions used to hash elements into the filter.
shared(installer) actor class Bucket(capacity : Nat, errorRate: Float, hashFuncs: [(Blob) -> Hash]) = this{
    
    private type BloomFilter = BloomFilter.BloomFilter;

    private stable let numSlices = Float.ceil(Float.log(1.0 / errorRate));
    private stable let bitsPerSlice = Float.ceil(
          (Float.fromInt(capacity) * Float.abs(Float.log(errorRate))) /
          (numSlices * (Float.log(2) ** 2)));
    private stable let bitMapSize : Nat = Int.abs(Float.toInt(numSlices * bitsPerSlice));
    
    private let limit = 20_000_000_000_000;


    private stable var map = StableMap.defaults<Blob, [Blob]>();
    private stable var filters : [BloomFilter] = [];

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
        bf_add(key);
        ?{
            key = key;
            bucket_id = Principal.fromActor(this);
        }
    };

    public query(msg) func get(key : Blob) : async ?[Blob]{
        if(not bf_check(key))){ null };
        StableMap.get<Blob, [Blob]>(map, key, Blob.hash, Blob.equal)
    };

    public shared(msg) func change(key : Blob, data : [Blob]) : async ?[Blob]{
        if(not bf_check(key)){ null };
        map := StableMap.put<Blob, [Blob]>(map, key, data, Blob.hash, Blob.equal);
        StableMap.get<Blob, [Blob]>(map, key, Blob.hash, Blob.equal)
    };

    public shared(msg) func delete(key : Blob) : async ?[Blob]{
        if(not bf_check(key)){ null };
        map := StableMap.delete<Blob, [Blob]>(map, key, Blob.hash, Blob.equal);
        StableMap.get<Blob, [Blob]>(map, key, Blob.hash, Blob.equal)
    };

    /// Adds an element to the BloomFilter's bitmap and deploys new BloomFilter if previous is at capacity.
    /// Args:
    ///   |item|   The item to be added.
    private func bf_add(item: Blob) {
        var filter = BloomFilter(bitMapSize, hashFuncs);
        if (filters.size() > 0) {
            let last_filter = filters[filters.size() - 1];
            if (last_filter.getNumItems() < capacity) {
                filter := last_filter;
            };
        };
        filter.add(item);
        filters := Array.append<BloomFilter>(filters, [filter]);
    };

    /// Checks if an item is contained in any BloomFilters
    /// Args:
    ///   |item|   The item to be searched for.
    /// Returns:
    ///   A boolean indicating set membership.
    private func bf_check(item: Blob) : Bool {
        for (filter in Iter.fromArray(filters)) {
            if (filter.check(item)) { return true; };
        };
        false
    };




};