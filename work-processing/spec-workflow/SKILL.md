---
name: spec-workflow
description: Run a Trae-style spec-first development workflow that generates three linked documents (spec outline, task list, acceptance checklist) before implementation. Use for large-scope or complex tasks such as system-level features, major refactors, or multi-person projects. Do not use for trivial fixes, questions, or when the user asks to code immediately.
---

# Spec Workflow（对齐 TRAE Spec 模式）

对范围较大、需要先对齐方案和验收标准的复杂任务，一次性生成三类文档后执行。核心原则：**三份文档一次产出、用户确认后才开始执行；执行中进度状态实时回写，结构变更按变更规则管理**。

## 适用判断

- 适用：系统级任务、大规模重构、多人协作项目、需求边界复杂的功能开发。
- 不适用：边界清晰的中小任务（直接做）、口头问答、用户明确要求“直接改”。

## Phase 0 — 澄清（可选）

若存在影响整个产品方向的关键歧义，先提出 1-3 个具体问题。轻微歧义不要阻塞：做出合理假设并在 spec.md 中标注。

## Phase 1 — 生成 Spec 文档组（一次性三份）

1. 只读探索代码库，理解现状和相关模块。
2. 在项目根目录创建 `specs/<任务名>/`，**一次性生成三份文档**（对齐 TRAE 的 `.trae/specs/` 按任务名分组的约定；不要用 `.codex/`，该目录在 Codex 沙箱中只读）：
   - `spec.md` — 大纲：背景、目标、范围、功能要点、非目标、开放问题与假设。
   - `tasks.md` — 任务列表：按优先级排序，每项标注关联的 spec 功能要点、验收标准、复杂度、依赖。
   - `checklist.md` — 验收清单：逐项可勾选的验收条目，与 tasks.md 一一对应。
3. 展示三份文档的链接和摘要，停下等用户确认。用户可直接编辑文档，或用自然语言要求调整；有调整则更新文档后重新确认。

## Phase 2 — 实施（Implement）

前置条件：用户已确认文档组。

### 2a. 进度状态更新（可直接执行）

1. 每完成一个任务，立即在 tasks.md 中勾选该任务。
2. 同步更新 checklist.md 中对应验收项的状态（未检 / 通过 / 失败）；失败或阻塞项如实标注，不得静默跳过。

### 2b. 任务结构变更（拆分 / 新增 / 减少）

执行中任务可能需要重新拆分、增加或减少，按以下规则处理：

1. **区分轻重**：
   - 轻微变更（不影响验收标准、spec 目标和总体范围，如把 T3 拆成 T3a/T3b）：直接回写 tasks.md 与 checklist.md，在两份文档的「变更记录」中注明变更内容和原因，然后继续执行。
   - 重大变更（影响验收标准、spec 目标、范围或明显增加工作量）：先停下，向用户说明变更内容、原因和影响，征得同意后再回写文档并继续。
2. **编号保持稳定**：
   - 拆分任务用子编号（如 T3a、T3b），不全局重编号。
   - 新增任务顺延编号（如 T7），并在描述中标注来源（由哪个任务/发现引出）。
   - 对应的 checklist 条目使用相同子编号规则（如 AC-3a），保证引用不断裂。
3. **移除不删除**：不再适用的任务/验收条目标记为「已移除（原因：…）」，保留痕迹，不物理删除。
4. **同步检查**：每次结构变更后，重新核对 tasks.md 与 checklist.md 的对应关系是否完整（每个任务有验收、每个 AC 有任务）。
5. **回写先于编码**：结构变更回写完成前，不开始基于新任务结构的编码。

## Phase 3 — 验证与收尾（Verify）

1. 运行项目自带的测试/lint/构建命令（若无则说明）。
2. 对照 checklist.md 逐项自检，将结果回写到 checklist.md。
3. 汇报：改动摘要、checklist 结果、执行期间的结构变更记录、已知残留问题、后续建议。

## 硬性约束

- 三份文档必须齐全且相互对应：tasks.md 的每项关联 spec.md 的功能要点，checklist.md 覆盖 tasks.md 的全部验收标准。
- 用户确认前不写任何业务代码。
- 进度勾选可直接更新；任务/验收的结构变更必须按 Phase 2b 规则回写，重大变更需用户确认。
- 文档使用中文撰写，代码标识符保持原文。
