### Stable Storage
* Container
* Bucket

## Container
Container:  Container - Bucket 两层结构， Container作为Bucket的管理层与第一次query（查询key在哪个Bucket）的处理层
* 负责：
* 生成新的Container Canister
* 生成新的Bucket Canister
* 对Bucket充值Cycle
* 处理询问： 数据是否存在于本Container-Bucket组， 不存在则返回false/null， 存在则返回{Bucket_Canister_id : Principal, key : Blob}

### TODO
* 集成Bucket布隆过滤器及其对应措施
* Container自管理（自动扩容，Cycle等）


## Bucket
Bucket主要作为一个存储Canister的模板， 提供基础的增删改查
* 负责：
* 对数据的增删改查

### TODO
* 完善存储树， 现在为Hashmap， 带补充TrieMap， RBTree-Map， BinarySearchTree ···
* 集成布隆过滤器
* Compacting GC 版 和 Coping GC 版
 
