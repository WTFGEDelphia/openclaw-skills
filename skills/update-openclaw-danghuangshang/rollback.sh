#!/bin/bash
# AI 朝廷版本回滚工具

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置
VERSIONS_DIR="/home/openclaw/.openclaw/workspace/skills/update-openclaw-danghuangshang/versions"
PROJECT_DIR="/home/openclaw/boluobobo-ai-court-tutorial"
CONFIG_FILE="$HOME/.openclaw/openclaw.json"
CLAWD_DIR="/home/openclaw/clawd"
SKILLS_DIR="/home/openclaw/.openclaw/workspace/skills"

echo "======================================"
echo "🔄 AI 朝廷 版本回滚工具"
echo "======================================"
echo ""

# 检查版本目录
if [ ! -d "$VERSIONS_DIR" ] || [ -z "$(ls -A $VERSIONS_DIR 2>/dev/null)" ]; then
    echo -e "${RED}✗ 未找到任何版本快照${NC}"
    echo "  请先运行更新脚本创建版本快照"
    exit 1
fi

# 列出所有版本
echo -e "${CYAN}📋 可用版本快照:${NC}"
echo ""

# 按时间排序显示版本
ls -lt "$VERSIONS_DIR" 2>/dev/null | tail -n +2 | while read line; do
    VERSION_DIR=$(echo "$line" | awk '{print $NF}')
    VERSION_FILE="$VERSIONS_DIR/$VERSION_DIR/version.json"
    if [ -f "$VERSION_FILE" ]; then
        TIMESTAMP=$(jq -r '.timestamp' "$VERSION_FILE" 2>/dev/null)
        GIT_COMMIT=$(jq -r '.git_commit' "$VERSION_FILE" 2>/dev/null)
        ACTION=$(jq -r '.action' "$VERSION_FILE" 2>/dev/null)
        DATE=$(date -d "@$TIMESTAMP" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$TIMESTAMP")
        echo "  [$VERSION_DIR] $DATE | $ACTION | commit: ${GIT_COMMIT:0:8}"
    fi
done

echo ""
echo "  [latest] 当前运行版本"
echo ""

# 选择回滚版本
echo -e "${YELLOW}选择要回滚到的版本:${NC}"
echo "  输入版本号（如 20260319-075823）"
echo "  输入 'latest' 查看当前版本信息"
echo "  输入 'cancel' 取消操作"
echo ""
read -p "版本号：" VERSION_SELECT

if [ "$VERSION_SELECT" = "cancel" ]; then
    echo -e "${YELLOW}⚠ 已取消操作${NC}"
    exit 0
fi

if [ "$VERSION_SELECT" = "latest" ]; then
    echo ""
    echo -e "${CYAN}当前运行版本信息:${NC}"
    if [ -f "$CONFIG_FILE" ]; then
        AGENT_COUNT=$(python3 -c "import json; c=json.load(open('$CONFIG_FILE')); print(len(c.get('agents',{}).get('list',[])))" 2>/dev/null || echo "0")
        echo "  Agent 数量：$AGENT_COUNT 个"
    fi
    if [ -d "$PROJECT_DIR/.git" ]; then
        GIT_COMMIT=$(cd "$PROJECT_DIR" && git log --oneline -1 2>/dev/null | cut -d' ' -f1)
        echo "  Git commit: ${GIT_COMMIT:0:8}"
    fi
    exit 0
fi

# 验证版本
VERSION_DIR="$VERSIONS_DIR/$VERSION_SELECT"
if [ ! -d "$VERSION_DIR" ]; then
    echo -e "${RED}✗ 版本不存在：$VERSION_SELECT${NC}"
    exit 1
fi

VERSION_FILE="$VERSION_DIR/version.json"
if [ ! -f "$VERSION_FILE" ]; then
    echo -e "${RED}✗ 版本文件不存在${NC}"
    exit 1
fi

# 显示版本详情
echo ""
echo -e "${CYAN}版本详情:${NC}"
jq -r '"  时间：\(.timestamp | todate)
  操作：\(.action)
  Git commit: \(.git_commit)
  备注：\(.notes // "无")' "$VERSION_FILE"

echo ""
echo -e "${YELLOW}将要回滚的内容:${NC}"
echo "  - 配置文件 (openclaw.json)"
[ -d "$VERSION_DIR/clawd" ] && echo "  - Agent 工作区 (clawd/)"
[ -d "$VERSION_DIR/skills" ] && echo "  - Skills 目录"
echo ""

# 确认回滚
read -p "确认回滚到此版本？[y/N]: " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo -e "${YELLOW}⚠ 已取消操作${NC}"
    exit 0
fi

# 执行回滚
echo ""
echo -e "${YELLOW}执行回滚...${NC}"

# 1. 创建当前状态的快照（回滚点）
CURRENT_SNAPSHOT="$VERSIONS_DIR/rollback-point-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$CURRENT_SNAPSHOT"
echo "  创建回滚点快照..."
[ -f "$CONFIG_FILE" ] && cp "$CONFIG_FILE" "$CURRENT_SNAPSHOT/"
[ -d "$CLAWD_DIR" ] && cp -r "$CLAWD_DIR" "$CURRENT_SNAPSHOT/" 2>/dev/null || true

# 2. 恢复配置
echo "  恢复配置文件..."
if [ -f "$VERSION_DIR/openclaw.json" ]; then
    cp "$VERSION_DIR/openclaw.json" "$CONFIG_FILE"
    echo -e "${GREEN}  ✓ 配置已恢复${NC}"
else
    echo -e "${RED}  ✗ 配置文件不存在${NC}"
fi

# 3. 恢复工作区
if [ -d "$VERSION_DIR/clawd" ]; then
    echo "  恢复 Agent 工作区..."
    rm -rf "$CLAWD_DIR"
    cp -r "$VERSION_DIR/clawd" "$CLAWD_DIR"
    echo -e "${GREEN}  ✓ 工作区已恢复${NC}"
fi

# 4. 恢复 Skills
if [ -d "$VERSION_DIR/skills" ]; then
    echo "  恢复 Skills 目录..."
    # 先备份当前 Skills
    CURRENT_SKILLS_BACKUP="$VERSIONS_DIR/current-skills-backup"
    mkdir -p "$CURRENT_SKILLS_BACKUP"
    cp -r "$SKILLS_DIR"/* "$CURRENT_SKILLS_BACKUP/" 2>/dev/null || true
    
    # 恢复版本中的 Skills
    rm -rf "$SKILLS_DIR"/*
    cp -r "$VERSION_DIR/skills"/* "$SKILLS_DIR/"
    
    # 恢复自定义 Skills
    for skill in $(ls "$CURRENT_SKILLS_BACKUP"); do
        # 跳过官方 Skills
        if ! [ -d "$VERSION_DIR/skills/$skill" ]; then
            cp -r "$CURRENT_SKILLS_BACKUP/$skill" "$SKILLS_DIR/"
        fi
    done
    
    echo -e "${GREEN}  ✓ Skills 已恢复${NC}"
fi

# 5. 更新版本记录
echo "  更新版本记录..."
echo "{\"rolled_back_to\": \"$VERSION_SELECT\", \"timestamp\": $(date +%s), \"from_snapshot\": \"$CURRENT_SNAPSHOT\"}" > "$VERSION_DIR/rollback_record.json"

echo ""
echo -e "${GREEN}======================================"
echo "🎉 回滚完成！${NC}"
echo "======================================"
echo ""
echo "回滚点快照：$CURRENT_SNAPSHOT"
echo ""
echo "下一步："
echo "  1. 重启 Gateway: openclaw gateway restart"
echo "  2. 验证功能是否正常"
echo "  3. 如有问题，可回滚到回滚点"
echo ""
