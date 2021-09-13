import Array "mo:base/Array";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Blob "mo:base/Blob";
import Nat32 "mo:base/Nat32";

module {
    /// Manages BloomFilters, deploys new BloomFilters, and checks for element membership across filters.
  /// Args:
  ///   |capacity|    The maximum number of elements a BlooomFilter may store.
  ///   |errorRate|   The maximum false positive rate a BloomFilter may maintain.
  ///   |hashFuncs|   The hash functions used to hash elements into the filter.
  type Hash = Hash.Hash;
  private stable var filters : [BloomFilter] = [];
    
  private stable let numSlices = Float.ceil(Float.log(1.0 / errorRate));
  private stable let bitsPerSlice = Float.ceil(
        (Float.fromInt(capacity) * Float.abs(Float.log(errorRate))) /
        (numSlices * (Float.log(2) ** 2)));
  private stable let bitMapSize : Nat = Int.abs(Float.toInt(numSlices * bitsPerSlice));
  
  public class AutoScalingBloomFilter(capacity : Nat, errorRate: Float, hashFuncs: [(Blob) -> Hash]){

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
        for (filter in filters.vals()) {
            if (filter.check(item)) { return true; };
        };
        false
    };
  }

  /// The specific BloomFilter implementation used in AutoScalingBloomFilter.
  /// Args:
  ///   |bitMapSize|    The size of the bitmap (as determined in AutoScalingBloomFilter).
  ///   |hashFuncs|     The hash functions used to hash elements into the filter.
  public class BloomFilter(bitMapSize: Nat, hashFuncs: [(Nat) -> Hash]) {

    var numItems = 0;
    let bitMap: [var Bool] = Array.init<Bool>(bitMapSize, false);

    public func add(item: Blob) {
      for (f in Iter.fromArray(hashFuncs)) {
        let digest = Nat32.toNat(f(item)) % bitMapSize;
        bitMap[digest] := true;
      };
      numItems += 1;
    };

    public func check(item: Blob) : Bool {
      for (f in Iter.fromArray(hashFuncs)) {
        let digest = Nat32.toNat(f(item)) % bitMapSize;
        if (bitMap[digest] == true) return false;
      };
      true
    };

    public func getNumItems() : Nat {
      numItems
    };

    public func getBitMap() : [Bool] {
      Array.freeze(bitMap)
    };

    public func setData(data: [Bool]) {
      assert data.size() == bitMapSize;
      for (i in Iter.range(0, data.size())) {
        bitMap[i] := data[i];
      };
    };

  };

};