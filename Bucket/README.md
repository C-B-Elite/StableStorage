## Bucket
存储Canister单体

### Bucket说明
Bucket 当前的存储使用的是Stable HashMap， 未来要支持更多Map

### 修改GC算法
若想要从Coping GC修改为Compacting GC, 参考:
修改dfx.json中的build为:

```
"build": {
    "args": "--compacting-gc",
    "packtool": "vessel sources"
}
```

默认GC为Coping GC， 两者区别与选择建议：[GC Algorithm Explaination](https://github.com/C-B-Elite/Internet-Computer-Research/blob/main/Storage/GC.md)

### TODO List :
* TODO 1 : 下一步是考虑数组存和stable树存，这两个哪一个更好
* TODO 2 : 测试Stable Map的stable特性
* TODO 3 : 支持多种索引树
* TODO 4 : 加上支持抗弱碰撞的的BloomFilter组件
-