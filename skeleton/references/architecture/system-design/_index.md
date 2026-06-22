# 系统设计模式

> 从 Insurance Atom Trigger / InsightHub / LexFlow 等项目中蒸馏的系统级设计原则。

## 已沉淀

- **背压必须在管道入口** — auto-commit 是背压的敌人；信号量挡在 consume loop 是最可靠的背压原语
- **保活循环不能和慢业务绑死** — Kafka consumer poll、分布式锁续租、heartbeat 必须独立于业务执行路径
- **并发消费 ≠ 精确 at-least-once** — commit 提交最大 offset；at-most-once + 幂等已等价
- **双循环是过度工程信号** — 生命周期不独立的循环应合并；信号量 + TaskGroup 足够
- **集群限频状态必须在共享存储** — 只共享配置阈值不共享运行状态，不构成全局约束（Redis `SET NX EX`）
- **不可逆操作延迟到确定性最高点** — Pipeline 入口不做 DELETE；原子替换只在新值已准备好时执行
- **配置热同步：拉取 + 版本比对** — 定期 polling 比 pub/sub 更可靠；失败降级用 last-known-good config
- **超时策略按操作语义拆分** — connect 探活和文件传输不能用同一个 timeout 桶
- **运行时不变式放统一出口** — 所有分支产出相同契约结构，出口只管校验和去重
- **容器日志 vs 应用日志是两条边界** — 谁产生、谁保存、谁轮转，三个问题分开回答
- **JWT 是声明系统，不是完整会话** — 签发→传输→验证→续期→撤销，五段缺一不可
- **Redis 乐观锁保护读改写意图** — 原子 `SET` 不保护"读到的东西仍然成立"；WATCH/MULTI/EXEC 做 CAS
- **分库分表本质矛盾是物理切分 vs 多维查询** — 分片键选的是"牺牲哪个查询维度"
- **扩容不如控量** — 冷热分离 + 归档让热库数据量可控；2 倍扩容能做但很痛；终局是分布式数据库
- **Worker 消费模型四段拆分** — KafkaPoller(保活) → WorkQueue(背压) → Executor(执行) → OffsetTracker+CommitLoop(提交)
