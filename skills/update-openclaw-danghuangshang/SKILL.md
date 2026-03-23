---
name: update-openclaw-danghuangshang
description: 一键集成/更新 AI 朝廷 (danghuangshang) 项目到已安装的 OpenClaw，支持首次集成、增量更新、版本管理和平台配置
---

# 🏛️ update-openclaw-danghuangshang

一键集成/更新 AI 朝廷（danghuangshang）项目到已安装的 OpenClaw 环境。

**项目地址：** https://github.com/wanikua/danghuangshang

---

## 📋 核心功能

### 首次集成模式

- ✅ 克隆项目仓库
- ✅ 交互式配置平台（飞书/Discord/WebUI/暂不配置）
- ✅ 自动生成 openclaw.json 配置（合并现有配置）
- ✅ 创建 9 个 Agent 工作区
- ✅ 初始化 SOUL.md/USER.md/AGENTS.md
- ✅ 同步官方 Skills（保留自定义）
- ✅ 自动创建版本快照
- ✅ **自动检测现有 Agent，跳过已存在或仅更新模型配置（v7.2）**
- ✅ **Discord 机器人不足时提供 3 种配置方案（v7.2）**
- ✅ **多模型智能推荐 + 自定义映射（v7.2）**

### 更新模式

- ✅ 自动备份当前配置
- ✅ git pull 更新仓库
- ✅ 同步上游 Skills（保留自定义）
- ✅ 重新构建 GUI Dashboard
- ✅ 重启 Gateway 服务
- ✅ 启动 GUI（带永久 Token）
- ✅ 自动创建版本快照

### 版本管理

- ✅ 自动创建版本快照（每次更新后）
- ✅ 查看版本历史列表
- ✅ 一键回滚到任意历史版本
- ✅ 手动创建快照
- ✅ 保留最近 10 个快照

### 平台配置

- ✅ 添加飞书机器人
- ✅ 添加 Discord 机器人
- ✅ 移除平台账户
- ✅ 查看平台配置详情
- ✅ 支持多机器人配置

---

## 🚀 使用方法

### 方式一：直接运行脚本

```bash
/home/openclaw/.openclaw/workspace/skills/update-openclaw-danghuangshang/update.sh
```

### 方式二：通过 Agent 调用

在飞书/Discord @司礼监：

```
请帮我集成 AI 朝廷
```
或
```
请帮我更新 AI 朝廷到最新版本
```

### 方式三：调用辅助工具

```bash
# 查看版本快照
bash /home/openclaw/.openclaw/workspace/skills/update-openclaw-danghuangshang/snapshot.sh list

# 回滚到历史版本
bash /home/openclaw/.openclaw/workspace/skills/update-openclaw-danghuangshang/rollback.sh

# 配置平台机器人
bash /home/openclaw/.openclaw/workspace/skills/update-openclaw-danghuangshang/config-platform.sh
```

---

## 📊 工作流程

### 首次集成（7 步）

| 步骤 | 操作 | 预计时间 |
|------|------|---------|
| 1/7 | 克隆项目仓库 | 1 分钟 |
| 2/7 | 选择交互平台 | 手动 |
| 3/7 | 配置平台凭证（或跳过） | 2 分钟 |
| 4/7 | 配置 AI 模型 | <1 分钟 |
| 5/7 | 合并 OpenClaw 配置 | <1 分钟 |
| 6/7 | 创建 Agent 工作区 | <1 分钟 |
| 7/7 | 同步 Skills → 自动创建快照 | 1 分钟 |

**总耗时：** 5-10 分钟

### 更新模式（8 步）

| 步骤 | 操作 | 预计时间 |
|------|------|---------|
| 1/8 | 备份当前配置 | 1 分钟 |
| 2/8 | 停止 GUI | <10 秒 |
| 3/8 | git pull 更新仓库 | 1 分钟 |
| 4/8 | 同步 Skills | 1 分钟 |
| 5/8 | Agent 配置检查 | 手动确认 |
| 6/8 | 构建 GUI | 3-5 分钟 |
| 7/8 | 重启 Gateway | 1 分钟 |
| 8/8 | 启动 GUI → 自动创建快照 | <1 分钟 |

**总耗时：** 5-10 分钟

---

## 🎯 主菜单

运行 `update.sh` 后会出现以下选项：

```
请选择操作:
  1) 更新到最新版本（默认）
  2) 查看版本快照列表
  3) 回滚到历史版本
  4) 创建当前版本快照
  5) 配置平台机器人（添加飞书/Discord）
  6) 退出
```

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

## 🌐 平台支持

| 平台 | 说明 | 推荐场景 |
|------|------|---------|
| 飞书 | WebSocket 长连接 | 国内用户 |
| Discord | Bot Token | 海外用户 |
| WebUI | 仅本地访问 | 开发测试 |
| 暂不配置 | 后续通过 config-platform.sh 添加 | 先体验后配置 |

### Discord 机器人配置策略（v7.2 新增）

| 现有机器人数量 | 推荐方案 | 说明 |
|---------------|---------|------|
| 0 个 | 创建 1 个共用 Bot | 所有 Agent 共用，最简单 |
| 1-8 个 | 复用现有 + 后续补充 | 先用 1 个，其他后续通过 config-platform.sh 添加 |
| ≥9 个 | 按需分配 | 可为不同 Agent 分配不同机器人 |

---

## 🔧 辅助工具

### snapshot.sh - 版本快照工具

**功能：**
- 创建版本快照
- 列出所有快照
- 删除指定快照

**用法：**
```bash
# 创建快照
bash snapshot.sh create [版本号] [备注]

# 列出快照
bash snapshot.sh list

# 删除快照
bash snapshot.sh delete 版本号
```

### rollback.sh - 版本回滚工具

**功能：**
- 列出所有可用版本
- 选择回滚版本
- 创建回滚点（回滚前状态）
- 恢复配置、工作区、Skills

**用法：**
```bash
bash rollback.sh
```

### config-platform.sh - 平台配置工具

**功能：**
- 添加飞书机器人
- 添加 Discord 机器人
- 移除平台账户
- 查看平台配置详情

**用法：**
```bash
bash config-platform.sh
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

## 📁 文件结构

```
update-openclaw-danghuangshang/
├── update.sh           # 主脚本（集成版本管理）
├── snapshot.sh         # 快照工具
├── rollback.sh         # 回滚工具
├── config-platform.sh  # 平台配置工具
├── SKILL.md            # 完整说明（本文件）
├── README.md           # 简化说明
└── versions/           # 版本快照目录
    ├── 20260319-135800/
    │   ├── version.json
    │   ├── openclaw.json
    │   ├── clawd/
    │   └── skills/
    └── ...
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
| 现有 Agent 处理 | ✅ | ❌ |
| Discord 机器人不足处理 | ✅ | ❌ |
| 多模型推荐配置 | ✅ | ❌ |
| 自定义模型映射 | ✅ | ❌ |

---

**Skill 版本：** v1.0.0  
**最后更新：** 2026-03-19  
