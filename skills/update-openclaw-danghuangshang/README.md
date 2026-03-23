# update-openclaw-danghuangshang

🏛️ AI 朝廷（danghuangshang）项目集成/更新/版本管理工具

> 一键集成到已安装的 OpenClaw，支持首次安装、增量更新、版本快照和一键回滚

---

## 🚀 快速开始

### 方式一：直接运行

```bash
/home/openclaw/.openclaw/workspace/skills/update-openclaw-danghuangshang/update.sh
```

### 方式二：通过 Agent 调用

在飞书/Discord @司礼监：

```
请帮我集成/更新 AI 朝廷
```

---

## 📋 核心功能

| 功能 | 说明 |
|------|------|
| **首次集成** | 克隆 + 配置 + 工作区 + Skills |
| **增量更新** | 备份 + git pull + 同步 + 重启 |
| **版本快照** | 自动创建，保留历史 |
| **一键回滚** | 回退到任意历史版本 |
| **配置合并** | 保留现有配置，不覆盖 |
| **4 层校验** | JSON/字段/Agent/schema 验证 |
| **用户确认** | 执行前显示环境并确认 |
| **平台配置** | 后续添加飞书/Discord 机器人 |
| **现有 Agent 处理** | 自动检测并跳过已存在 Agent，仅更新模型配置 |
| **Discord 机器人不足** | 提供 3 种方案：共用/混合/新创建 |
| **多模型推荐配置** | 智能排序 + 3 种配置方式（推荐/单一/自定义） |

---

## 🎯 主菜单

运行 `update.sh` 后会出现以下选项：

```
请选择操作:
  1) 更新到最新版本（默认）
  2) 查看版本快照列表
  3) 回滚到历史版本
  4) 创建当前版本快照
  5) 配置平台机器人（添加飞书/Discord） ← 新增
  6) 退出
```

---

## 📊 工作流程

### 首次集成（7 步）

1. 克隆项目仓库
2. 选择交互平台（飞书/Discord/WebUI/**暂不配置**）
3. 配置平台凭证（或跳过）
4. 配置 AI 模型
5. 合并 OpenClaw 配置
6. 创建 Agent 工作区
7. 同步 Skills → **自动创建快照**

**预计时间：** 5-10 分钟

### 更新模式（8 步）

1. 备份当前配置
2. 停止 GUI
3. git pull 更新仓库
4. 同步 Skills
5. Agent 配置检查
6. 构建 GUI
7. 重启 Gateway
8. 启动 GUI → **自动创建快照**

**预计时间：** 5-10 分钟

---

## 🏛️ 支持的 Agent（9 个核心部门）

| Agent | 名称 | 职责 | 沙箱 |
|-------|------|------|------|
| silijian | 司礼监 | 总管调度 | off |
| neige | 内阁 | Prompt 优化 | off |
| duchayuan | 都察院 | 代码审查 | agent |
| bingbu | 兵部 | 编码开发 | agent |
| hubu | 户部 | 财务分析 | off |
| libu | 礼部 | 品牌营销 | off |
| gongbu | 工部 | DevOps | agent |
| libu2 | 吏部 | 项目管理 | off |
| xingbu | 刑部 | 法务合规 | off |

---

## 🔄 版本管理

### 查看版本列表

```bash
# 方式 1：通过主菜单
./update.sh → 选择 2)

# 方式 2：直接调用
bash snapshot.sh list
```

### 一键回滚

```bash
# 方式 1：通过主菜单
./update.sh → 选择 3) → 输入版本号

# 方式 2：直接调用
bash rollback.sh
```

### 手动创建快照

```bash
# 方式 1：通过主菜单
./update.sh → 选择 4) → 输入备注

# 方式 2：直接调用
bash snapshot.sh create [版本号] [备注]
```

---

## 🤖 平台机器人配置

### 首次集成时选择

**选项：**
1. **飞书** - 需要 App ID + App Secret
2. **Discord** - 需要 Bot Token
3. **仅本地** - WebUI 模式，无需配置
4. **暂不配置** - 后续通过 `config-platform.sh` 添加 ← **新增**

### 配置 Agent 模型映射

运行 `update.sh` 后选择 6) 或直接运行：

```bash
/home/openclaw/.openclaw/workspace/skills/update-openclaw-danghuangshang/config-agents.sh
```

**主菜单：**
```
请选择操作:
  1) 批量配置 Agent 模型（推荐配置）
  2) 逐个配置 Agent 模型
  3) 重置为默认模型
  4) 查看配置详情
  5) 退出
```

**推荐配置方案：**
- **强力模型**（司礼监/内阁/都察院）：复杂决策、战略规划、代码审查
- **快速模型**（兵部/工部）：编码开发、DevOps 部署
- **通用模型**（户部/礼部/吏部/刑部）：分析任务、文案创作、项目管理

### 后续添加机器人

如果首次集成时选择了"暂不配置"，或需要添加更多机器人：

```bash
/home/openclaw/.openclaw/workspace/skills/update-openclaw-danghuangshang/config-platform.sh
```
- **快速模型**（兵部/工部）：编码开发、DevOps 部署
- **通用模型**（户部/礼部/吏部/刑部）：分析任务、文案创作、项目管理

**主菜单：**
```
请选择操作:
  1) 添加飞书机器人
  2) 添加 Discord 机器人
  3) 移除平台账户
  4) 查看平台配置详情
  5) 退出
```

### 添加飞书机器人步骤

1. 访问 https://open.feishu.cn/app
2. 点击「创建应用」→「企业自建应用」
3. 填写应用名称（如「AI 朝廷 - 司礼监」）
4. 在「功能能力」中添加「机器人」
5. 在「事件订阅」中：
   - 接收消息类型：选择「消息」
   - 接收方式：选择「WebSocket 长连接」
6. 在「凭证管理」中获取 App ID 和 App Secret
7. 运行 `config-platform.sh` 输入凭证

### 添加 Discord 机器人步骤

#### 首次集成时的智能检测

运行 `update.sh` 时会自动检测现有 Discord 机器人和 Agent：

```
📊 检测现有 Discord 机器人账户和 Agent...
🤖 发现现有 Discord 机器人账户:
    - my-bot-1
    - my-bot-2

🏛️ 发现现有 Agent:
    - custom-agent-1 (其他 Agent)

📋 配置方案分析:
    AI 朝廷共需 9 个 Agent：司礼监、内阁、都察院、兵部、户部、礼部、工部、吏部、刑部
    现有 Discord 机器人：2 个
```

根据机器人数量提供 3 种方案：

| 机器人数量 | 方案 1 | 方案 2 | 方案 3 |
|-----------|-------|-------|-------|
| 0 个 | 创建 9 个独立 Bot | 创建 1 个共用 Bot | - |
| 1-8 个 | 所有 Agent 共用现有 | 混合模式（现有 + 新创建） | 创建新机器人（保留现有） |
| ≥9 个 | 复用现有机器人 | 创建新机器人 | - |

#### 手动添加机器人步骤

1. 访问 https://discord.com/developers/applications
2. 点击「New Application」
3. 填写应用名称（如「AI 朝廷 - 司礼监」）
4. 在「Bot」中创建机器人
5. 开启以下权限：
   - Message Content Intent
   - Server Members Intent
6. 复制 Bot Token
7. 在「OAuth2」→「URL Generator」中生成邀请链接
8. 运行 `config-platform.sh` 输入 Token

---

## 📁 文件结构

```
update-openclaw-danghuangshang/
├── update.sh           # 主脚本（集成版本管理）
├── snapshot.sh         # 快照工具
├── rollback.sh         # 回滚工具
├── config-platform.sh  # 平台配置工具 ← 新增
├── SKILL.md            # 完整说明
├── README.md           # 本文件
└── versions/           # 版本快照目录
```

---

## ⚠️ 注意事项

### 首次集成

- ✅ 需要平台凭证（飞书 App ID/Secret 或 Discord Token）
- ✅ 或选择「暂不配置」后续添加
- ✅ 会自动备份 OpenClaw 现有配置
- ✅ Gateway 重启后才能在平台使用

### 更新

- ✅ Gateway 重启期间服务不可用（约 30-60 秒）
- ⚠️ 新增 Agent 需手动配置（脚本会提示）
  - guozijian（国子监）
  - taiyiyuan（太医院）
  - neiwufu（内务府）
  - yushanfang（御膳房）

### 现有 Agent 处理（v7.2 新增）

- ✅ 自动检测已存在的 Agent，跳过添加
- ✅ 如果模型配置不同，自动更新模型映射
- ✅ 保留现有 Discord 账户和绑定关系

### Discord 机器人不足（v7.2 新增）

- ✅ 机器人数量为 0：提供创建 1 个或 9 个的选项
- ✅ 机器人数量 1-8：提供共用/混合/新创建三种方案
- ✅ 首次只需配置司礼监，其他 Agent 可后续添加

### 多模型配置（v7.2 新增）

- ✅ 自动检测模型并按上下文大小排序
- ✅ 推荐配置：强力/快速/通用三类模型
- ✅ 单一模型：所有 Agent 共用
- ✅ 自定义映射：每个 Agent 单独配置

### 版本管理

- ✅ 自动保留最近 10 个快照
- ✅ 回滚前自动创建回滚点
- ✅ 自定义 Skills 不会被删除

---

## 🆘 故障恢复

### 配置校验失败

脚本会自动恢复备份：
```
✗ 配置验证失败，已恢复备份
```

### 手动恢复

```bash
# 恢复最新备份
cp ~/.openclaw/openclaw.json.ai-court-backup ~/.openclaw/openclaw.json
openclaw gateway restart
```

### 回滚到历史版本

```bash
./update.sh → 选择 3) → 输入版本号
```

---

## 🔧 高级用法

### 使用自定义 Token

```bash
export BOLUO_AUTH_TOKEN=your_token_here
./update.sh
```

### 查看版本详情

```bash
cat versions/20260319-135800/version.json | jq .
```

### 删除旧快照

```bash
bash snapshot.sh delete 版本号
```

### 静默模式

编辑 `update.sh`，将交互式 `read -p` 改为默认值。

---

## 📞 获取帮助

| 资源 | 地址 |
|------|------|
| **诊断工具** | `bash <(curl -fsSL https://raw.githubusercontent.com/wanikua/danghuangshang/main/doctor.sh)` |
| **项目文档** | `/home/openclaw/boluobobo-ai-court-tutorial/docs/` |
| **GitHub Issues** | https://github.com/wanikua/danghuangshang/issues |

---

## 📝 版本历史

### v1.0.0 (2026-03-19)

- 初始版本
- 支持首次集成
- 环境检测 + 用户确认
- 配置合并（不覆盖）use config validate
- 版本管理 + 一键回滚
- 平台配置工具 + 暂不配置选项
- 现有 Agent 处理、Discord 机器人不足、多模型推荐配置

---

## ✅ 特性对比

| 功能 | 本工具 | 官方 install.sh |
|------|--------|---------------|
| 首次集成 | ✅ | ✅ |
| 增量更新 | ✅ | ❌ |
| 配置合并 | ✅ | ❌ |
| 版本快照 | ✅ | ❌ |
| 一键回滚 | ✅ | ❌ |
| 配置校验 | ✅ | ❌ |
| 用户确认 | ✅ | ❌ |
| 后续添加机器人 | ✅ | ❌ |
| 暂不配置平台 | ✅ | ❌ |
| **现有 Agent 处理** | ✅ | ❌ |
| **Discord 机器人不足处理** | ✅ | ❌ |
| **多模型推荐配置** | ✅ | ❌ |
| **自定义模型映射** | ✅ | ❌ |

---

**Skill 版本：** v1.0.0  
**最后更新：** 2026-03-19  
