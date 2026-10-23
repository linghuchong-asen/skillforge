---
name: create-code-project
description: Create a new code project from scratch through a staged six-document workflow — product requirements (PRD), UI/UX design handoff, technical architecture, test documentation, and deployment/ops documentation (including canary/gray release) — then scaffold the project, implement the code, and generate runnable test code from the confirmed test cases. Use when the user asks to create or generate a new code project or application. Do not use for adding features to an existing project, document-only requests, or when the user asks to start coding immediately.
---

# Create Code Project（新项目六文档工作流）

从零创建一个代码项目。产出六份文档（PRD、UI/UX 设计交接、技术架构、测试计划、测试用例、部署运维（含灰度发版）），逐份确认后实施；**测试用例最终必须落成可运行的测试代码**。

## Phase 0 — 澄清

- 产品方向级歧义先问 1-3 个问题（做什么、给谁用、核心场景）；轻微歧义做合理假设并在 PRD 中标注。
- 技术栈偏好在此确认；用户未指定时由架构文档给出推荐选型，并在确认时说明理由。
- UI/UX 粒度在此确认：默认输出 Markdown 设计交接文档；若用户要求视觉稿或原型，再明确产出形式。
- 部署目标在此确认：部署到哪（云服务器 / 容器平台 / 静态托管 / Serverless）、是否有现成 CI/CD；用户未指定时由部署运维文档给出推荐方案。

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

## Phase 4 — 测试文档

前置条件：架构已确认。

1. 生成 `specs/test-plan.md` 与 `specs/test-cases.md` 两份文件：
   - `test-plan.md`（测试计划）：测试范围与策略、测试类型划分（单元/集成/E2E/人工）、测试环境与数据准备、准入准出标准、缺陷管理与回归策略、测试风险。
   - `test-cases.md`（测试用例）：按功能需求逐条编写用例（TC 编号、类型、前置条件、步骤、预期结果、优先级、关联 FR）。
2. 每个用例必须可翻译为自动化测试；无法自动化的（如纯视觉验收）标注「人工」并说明原因。
3. 停下等用户确认。

## Phase 5 — 部署运维文档

前置条件：测试文档已确认。

1. 生成 `specs/deployment.md`：
   - 环境与发布配置：环境划分（开发/测试/预发/生产）、配置与密钥管理、依赖的基础设施。
   - 部署方案：构建产物、部署步骤、回滚方案。
   - **灰度发版**：灰度策略（按用户/流量比例/特性开关）、灰度批次与放量节奏（如 5% → 20% → 50% → 100%）、每批次的观察指标与观察时长、放量与回退的判定条件、灰度验收标准。
   - 监控与告警：健康检查、关键指标、告警规则与通知渠道。
   - 应急预案：常见故障场景与处置步骤、值班/联系人（如适用）。
2. 小项目允许裁剪（如纯前端静态站可简化灰度为多环境预览验证），但裁剪项必须在文档中显式标注「本期不适用」并说明原因，不得整节省略。
3. 停下等用户确认。

## Phase 6 — 实施

前置条件：全部六份文档已确认。

1. 按架构文档搭建项目骨架：目录结构、依赖清单、构建配置、README。
2. 实现功能代码。
3. **按测试用例生成测试代码**：测试文件中用注释标注对应 TC 编号（如 `// TC-1`、`# TC-3a`），保持用例文档 ↔ 测试代码可追溯。
4. 每实现一个用例的测试，在 test-cases.md 勾选并记录测试文件路径。
5. 按 deployment.md 产出可执行的部署配置/脚本（如 Dockerfile、CI 配置、部署脚本），与文档保持一致。
6. 运行全部测试，把通过/失败状态回写 test-cases.md；失败项修复后重跑（不扩大范围）。

## Phase 7 — 收尾

1. 运行全量构建/测试命令，确认无报错。
2. 对照 test-cases.md 逐项汇报结果。
3. 交付说明：如何运行、目录结构、测试结果、如何按 deployment.md 部署（含灰度发布步骤）、已知残留问题、后续建议。

## 变更管理

- 六份文档均含「变更记录」小节；实施中发现文档需要改动，先回写文档再继续。
- 轻微变更（不影响范围/验收）直接回写并在变更记录留痕；重大变更（影响 PRD 目标、UI 交付范围、架构选型、测试范围、部署/灰度策略）先停下征得用户确认。
- 编号保持稳定：FR/TC 用子编号扩展（如 TC-3a），不全局重编号；移除条目标注「已移除（原因：…）」，保留痕迹。

## 硬性约束

- 六份文档全部确认前，不搭建项目骨架、不写任何业务代码。
- 测试用例文档中每条可自动化用例必须对应实际测试代码；未实现的用例在收尾时如实列为残留问题。
- 部署运维文档必须包含灰度发版方案；确不适用的须显式标注「本期不适用」并说明原因，不得省略。
- 文档使用中文撰写，代码标识符与命令保持原文。

## 参考

- 各文档模板见 [references/templates.md](references/templates.md)。
