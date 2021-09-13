import Array "mo:base/Array";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Blob "mo:base/Blob";
import Nat32 "mo:base/Nat32";

module {
  
  type Hash = Hash.Hash;

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