---
name: codex-remote-model-provider-update
description: 更新 Codex 的模型、模型目录、provider、渠道、路由和 cc-relay 配置。当用户要求新增、删除、重命名、切换模型或修改上游渠道时使用。
metadata:
  short-description: 更新 Codex 模型和 provider 渠道
---

# Codex 模型 / Provider 更新

当用户要求新增、删除、重命名、切换 Codex 模型，或修改上游渠道、路由、provider 配置时，使用这个 skill。

## 相关文件

- `/root/.codex/config.toml`：Codex 当前使用的 provider、默认模型和模型目录指针。
- `/root/.codex/cc-switch-model-catalog.json`：Codex 可见的模型目录。
- `/root/.codex/cc-relay/routes.json`：上游路由规则和路径改写。
- `/root/.codex/cc-relay/env`：relay 环境变量，包括上游 base URL 和 API key。
- `/root/.codex/cc-relay/server.js`：relay 实现。
- `/root/.codex/cc-relay/verify.sh`：用于验证 relay 和模型路由的脚本。

## 更新规则

1. **密钥只放在 `/root/.codex/cc-relay/env`。** 不要把上游 API key 写进 `config.toml` 或模型目录，也不要输出 key 的值。
2. **同步更新所有相关层**，不要只改一处：
   - 模型目录里的 `slug`、`description`、`display_name`；
   - `routes.json` 或 `env` 里的 provider 路由前缀、allowlist；
   - 只有用户明确要求时，才修改 `config.toml` 里的当前 `model`；
   - `verify.sh` 里引用到的旧模型名。
3. **优先使用新的上游模型 ID，不要盲目改能力参数。** 如果能力、reasoning 级别或上下文窗口也变了，应以服务商官方文档为准更新。
4. **新增或更新模型时，必须核对推理强度配置。** 不要直接照抄模板模型的 `supported_reasoning_levels`。应以服务商文档或用户明确给出的档位为准，并同步检查 `default_reasoning_level`。**默认推理强度使用 `high`**，除非用户或服务商文档明确要求其他档位。常见中文档位映射：
   - 中 → `medium`
   - 高 → `high`
   - 极高 → `xhigh`
   - ultra → `ultra`
   例如 `qwen4-max-preview` 应配置为：`medium`、`high`、`xhigh`、`ultra`，默认 `high`。
5. **修改前先备份文件。**
6. **修改后必须验证**：
   ```bash
   python3 -m json.tool /root/.codex/cc-switch-model-catalog.json
   bash -n /root/.codex/cc-relay/verify.sh
   codex debug models
   codex doctor
   curl -sS http://127.0.0.1:18080/healthz
   ```
7. **更新或新增模型后，必须强制刷新 app-server。** Codex 桌面端的模型选择器使用长期运行的 `codex app-server` 进程，它只在启动时读取一次模型目录。只改 JSON 不会刷新桌面端模型列表。修改完成后运行：
   ```bash
   /root/.codex/skills/codex-remote-model-provider-update/scripts/refresh-model-picker.sh
   ```
   如果这个脚本不存在，再使用：
   ```bash
   /root/.codex/cc-relay/refresh-model-picker.sh
   ```
   刷新后让用户新建对话或重新打开模型选择器。

完整操作清单见 `references/update-guide.md`。
