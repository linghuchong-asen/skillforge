---
name: create-code-project
description: Create a new code project from scratch through a staged four-document workflow — product requirements (PRD), UI/UX design handoff, technical architecture, and test cases — then scaffold the project, implement the code, and generate runnable test code from the confirmed test cases. Use when the user asks to create or generate a new code project or application. Do not use for adding features to an existing project, document-only requests, or when the user asks to start coding immediately.
---

# Create Code Project（新项目四文档工作流）

从零创建一个代码项目。产出四份文档（PRD、UI/UX 设计交接、技术架构、测试用例），逐份确认后实施；**测试用例最终必须落成可运行的测试代码**。

## Phase 0 — 澄清

- 产品方向级歧义先问 1-3 个问题（做什么、给谁用、核心场景）；轻微歧义做合理假设并在 PRD 中标注。
- 技术栈偏好在此确认；用户未指定时由架构文档给出推荐选型，并在确认时说明理由。
- UI/UX 粒度在此确认：默认输出 Markdown 设计交接文档；若用户要求视觉稿或原型，再明确产出形式。

## Phase 1 — PRD

1. 只读探索目标目录，确认无同名项目冲突。
2. 创建项目目录 `<项目名>/`，在其下建立 `specs/`。
3. 生成 `specs/prd.md`：背景目标、用户故事、功能需求（FR）、非目标、验收标准、开放问题与假设。
4. 展示文档链接与摘要，停下等用户确认。

## Phase 2 — UI/UX 设计交接

前置条件：PRD 已确认（有修改意见先更新再确认）。

1. 生成 `specs/ui-design.md`：页面/模块清单与信息架构、关键页面与组件的 UI/交互说明、状态设计（空态、加载、错误、禁用、悬停）、响应式与可访问性要求、文案与占位资源、交付给开发的标注/切图/资源说明（如适用）。
2. 视觉稿或原型不是默认必需品；如果用户明确要求，再产出对应文件并在文档中链接。
3. 停下等用户确认。

## Phase 3 — 技术架构

前置条件：UI/UX 设计交接已确认。

1. 生成 `specs/architecture.md`：技术栈选型及理由、整体架构、模块划分、数据模型、目录结构、依赖与构建方式、风险。
2. 技术栈在此定盘；停下等用户确认。

## Phase 4 — 测试用例

前置条件：架构已确认。

1. 生成 `specs/test-cases.md`：按功能需求逐条编写用例（TC 编号、类型、前置条件、步骤、预期结果、优先级、关联 FR）。
2. 每个用例必须可翻译为自动化测试；无法自动化的（如纯视觉验收）标注「人工」并说明原因。
3. 停下等用户确认。

## Phase 5 — 实施

前置条件：测试用例已确认。

1. 按架构文档搭建项目骨架：目录结构、依赖清单、构建配置、README。
2. 实现功能代码。
3. **按测试用例生成测试代码**：测试文件中用注释标注对应 TC 编号（如 `// TC-1`、`# TC-3a`），保持用例文档 ↔ 测试代码可追溯。
4. 每实现一个用例的测试，在 test-cases.md 勾选并记录测试文件路径。
5. 运行全部测试，把通过/失败状态回写 test-cases.md；失败项修复后重跑（不扩大范围）。

## Phase 6 — 收尾

1. 运行全量构建/测试命令，确认无报错。
2. 对照 test-cases.md 逐项汇报结果。
3. 交付说明：如何运行、目录结构、测试结果、已知残留问题、后续建议。

## 变更管理

- 四份文档均含「变更记录」小节；实施中发现文档需要改动，先回写文档再继续。
- 轻微变更（不影响范围/验收）直接回写并在变更记录留痕；重大变更（影响 PRD 目标、UI 交付范围、架构选型、用例范围）先停下征得用户确认。
- 编号保持稳定：FR/TC 用子编号扩展（如 TC-3a），不全局重编号；移除条目标注「已移除（原因：…）」，保留痕迹。

## 硬性约束

- 四份文档全部确认前，不搭建项目骨架、不写任何业务代码。
- 测试用例文档中每条可自动化用例必须对应实际测试代码；未实现的用例在收尾时如实列为残留问题。
- 文档使用中文撰写，代码标识符与命令保持原文。
