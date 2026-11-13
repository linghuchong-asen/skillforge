# Codex 模型 / Provider 更新指南

## 典型分层

这台主机上的 Codex 模型更新通常涉及四层：

1. **Codex 当前配置**
   - 路径：`/root/.codex/config.toml`
   - 控制当前 provider 和默认模型。
   - 示例字段：
     ```toml
     model_provider = "custom"
     model = "glm-5.3"
     model_catalog_json = "/root/.codex/cc-switch-model-catalog.json"
     ```

2. **模型目录**
   - 路径：`/root/.codex/cc-switch-model-catalog.json`
   - 包含 Codex 里展示的模型元数据。
   - 重命名模型时至少要更新：
     - `slug`
     - `description`
     - `display_name`
   - 如果新模型的能力、上下文窗口、reasoning 级别或模态也变了，也要同步更新这些字段。

3. **relay 路由**
   - 路径：`/root/.codex/cc-relay/routes.json`
   - 定义前缀、上游路径和 allowlist。
   - 默认路由可以使用 `prefix: ""` 和 `allowlist`。
   - 特定 provider 的路由可以使用类似 `ccs-qianwenai/` 的模型前缀。

4. **relay 环境变量**
   - 路径：`/root/.codex/cc-relay/env`
   - 保存上游 base URL 和 API key。
   - API key 只放在这里，不要输出。
   - 如果新模型名要路由到已有 provider，需要在这里更新 allowlist。

## 推荐流程

1. 备份要修改的文件：
   ```bash
   ts=$(date +%Y%m%d-%H%M%S)
   cp /root/.codex/config.toml /root/.codex/config.toml.bak.$ts
   cp /root/.codex/cc-switch-model-catalog.json /root/.codex/cc-switch-model-catalog.json.bak.$ts
   cp /root/.codex/cc-relay/routes.json /root/.codex/cc-relay/routes.json.bak.$ts
   cp /root/.codex/cc-relay/env /root/.codex/cc-relay/env.bak.$ts
   cp /root/.codex/cc-relay/verify.sh /root/.codex/cc-relay/verify.sh.bak.$ts
   ```

2. 明确这次变更类型：
   - 模型重命名；
   - 模型替换；
   - provider 替换；
   - 在已有 provider 下新增模型；
   - 新增 provider / 渠道。

3. 把变更应用到正确的层：
   - 更新模型目录里的条目；
   - 更新 allowlist 或前缀；
   - 只有用户要求时才修改当前 `model`；
   - 只有上游真的变化时才新增或修改 provider 路由；
   - 如果验证脚本引用了旧模型名，也要更新。

4. 验证：
   ```bash
   python3 -m json.tool /root/.codex/cc-switch-model-catalog.json
   bash -n /root/.codex/cc-relay/verify.sh
   codex debug models
   codex doctor
   curl -sS http://127.0.0.1:18080/healthz
   ```

5. 确认正确模型已经可见：
   ```bash
   codex debug models | python3 -c 'import json,sys; d=json.load(sys.stdin); print([m["slug"] for m in d["models"] if "MODEL_NAME" in m["slug"]])'
   ```

6. **强制刷新 app-server，让桌面端模型选择器重新加载模型目录：**
   ```bash
   /root/.codex/skills/codex-remote-model-provider-update/scripts/refresh-model-picker.sh
   ```
   如果脚本不存在，再使用：
   ```bash
   /root/.codex/cc-relay/refresh-model-picker.sh
   ```

## 推理强度配置习惯

新增或更新模型时，不要直接照抄模板模型的推理强度档位。必须核对：

- `supported_reasoning_levels`
- `default_reasoning_level`

优先以服务商官方文档或用户明确给出的档位为准。**默认推理强度使用 `high`**，除非用户或服务商文档明确要求其他档位。常见中文档位映射：

| 中文档位 | effort |
| --- | --- |
| 中 | `medium` |
| 高 | `high` |
| 极高 | `xhigh` |
| ultra | `ultra` |

例如 `qwen4-max-preview` 应配置为：

```json
"default_reasoning_level": "high",
"supported_reasoning_levels": [
  { "effort": "medium", "description": "Balances speed and reasoning depth for everyday tasks" },
  { "effort": "high", "description": "Greater reasoning depth for complex problems" },
  { "effort": "xhigh", "description": "Extra high reasoning depth for complex problems" },
  { "effort": "ultra", "description": "Ultra reasoning depth" }
]
```

如果用户没有明确给出档位，也不要默认沿用旧模型；应先查服务商文档，或向用户确认。

## 桌面端缓存处理

如果模型目录和 CLI 都已经正确，但 Codex 桌面端模型选择器仍显示旧模型：

1. 新建一个对话；模型选择器可能使用会话级快照。
2. 重启 Codex 桌面端。
3. 如果仍然显示旧数据，检查 app-server daemon：
   ```bash
   codex app-server daemon version
   ps -ef | grep -E 'codex.*app-server|app-server.*codex'
   ```
4. 如果 `codex app-server daemon restart` 提示 daemon 是非托管的，不要盲目杀进程。先确认它确实是旧的 app-server，再停止它并 bootstrap/start 一个托管 daemon。

## 缓存说明

修改模型名或 provider 可能影响上游 prompt cache 的复用，因为不同模型 / provider 的缓存通常是分开的。只修改展示元数据或路由 allowlist，一般不会影响请求体，也不会影响上游缓存行为。
