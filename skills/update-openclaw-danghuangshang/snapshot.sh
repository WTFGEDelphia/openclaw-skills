#!/bin/bash
# AI 朝廷版本快照工具

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

# 参数
ACTION=${1:-"create"}
VERSION_NAME=${2:-""}
NOTES=${3:-""}

create_snapshot() {
    echo -e "${CYAN}📸 创建版本快照...${NC}"
    
    # 生成版本名
    if [ -z "$VERSION_NAME" ]; then
        VERSION_NAME="$(date +%Y%m%d-%H%M%S)"
    fi
    
    VERSION_DIR="$VERSIONS_DIR/$VERSION_NAME"
    mkdir -p "$VERSION_DIR"
    
    echo "  版本：$VERSION_NAME"
    
    # 1. 保存配置
    echo "  保存配置文件..."
    [ -f "$CONFIG_FILE" ] && cp "$CONFIG_FILE" "$VERSION_DIR/"
    
    # 2. 保存工作区
    echo "  保存 Agent 工作区..."
    [ -d "$CLAWD_DIR" ] && cp -r "$CLAWD_DIR" "$VERSION_DIR/"
    
    # 3. 保存 Skills（只保存官方 Skills）
    echo "  保存 Skills..."
    if [ -d "$PROJECT_DIR/skills" ]; then
        mkdir -p "$VERSION_DIR/skills"
        cp -r "$PROJECT_DIR/skills"/* "$VERSION_DIR/skills/" 2>/dev/null || true
    fi
    
    # 4. 获取 Git 信息
    GIT_COMMIT=""
    if [ -d "$PROJECT_DIR/.git" ]; then
        GIT_COMMIT=$(cd "$PROJECT_DIR" && git log --oneline -1 2>/dev/null | cut -d' ' -f1)
    fi
    
    # 5. 创建版本信息
    TIMESTAMP=$(date +%s)
    cat > "$VERSION_DIR/version.json" << EOF
{
  "version": "$VERSION_NAME",
  "timestamp": $TIMESTAMP,
  "datetime": "$(date -Iseconds)",
  "action": "${ACTION:-update}",
  "git_commit": "$GIT_COMMIT",
  "notes": "$NOTES",
  "config_size": $([ -f "$CONFIG_FILE" ] && stat -c%s "$CONFIG_FILE" || echo 0),
  "agent_count": $(python3 -c "import json; c=json.load(open('$CONFIG_FILE')); print(len(c.get('agents',{}).get('list',[]))" 2>/dev/null || echo 0)
}
EOF
    
    echo -e "${GREEN}  ✓ 快照已创建：$VERSION_DIR${NC}"
    echo ""
    echo "版本信息:"
    jq -r '"  时间：\(.datetime)
  操作：\(.action)
  Git commit: \(.git_commit)
  Agent 数量：\(.agent_count)
  备注：\(.notes // "无")' "$VERSION_DIR/version.json"
    
    # 保留最近 10 个快照，删除旧的
    echo ""
    echo "  清理旧快照..."
    SNAPSHOTS=$(ls -t "$VERSIONS_DIR" 2>/dev/null | tail -n +11)
    for old in $SNAPSHOTS; do
        if [ -d "$VERSIONS_DIR/$old" ] && [[ ! "$old" =~ ^rollback-point ]]; then
            rm -rf "$VERSIONS_DIR/$old"
            echo "    删除：$old"
        fi
    done
    
    echo -e "${GREEN}✓ 快照创建完成${NC}"
}

list_snapshots() {
    echo -e "${CYAN}📋 版本快照列表:${NC}"
    echo ""
    
    if [ ! -d "$VERSIONS_DIR" ] || [ -z "$(ls -A $VERSIONS_DIR 2>/dev/null)" ]; then
        echo "  无可用快照"
        return
    fi
    
    ls -lt "$VERSIONS_DIR" 2>/dev/null | tail -n +2 | while read line; do
        VERSION_DIR=$(echo "$line" | awk '{print $NF}')
        VERSION_FILE="$VERSIONS_DIR/$VERSION_DIR/version.json"
        if [ -f "$VERSION_FILE" ]; then
            TIMESTAMP=$(jq -r '.timestamp' "$VERSION_FILE" 2>/dev/null)
            GIT_COMMIT=$(jq -r '.git_commit' "$VERSION_FILE" 2>/dev/null)
            ACTION=$(jq -r '.action' "$VERSION_FILE" 2>/dev/null)
            NOTES=$(jq -r '.notes // "无"' "$VERSION_FILE" 2>/dev/null)
            DATE=$(date -d "@$TIMESTAMP" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "$TIMESTAMP")
            AGENT_COUNT=$(jq -r '.agent_count' "$VERSION_FILE" 2>/dev/null)
            echo "  [$VERSION_DIR]"
            echo "    时间：$DATE"
            echo "    操作：$ACTION"
            echo "    Git: ${GIT_COMMIT:0:8}"
            echo "    Agent: $AGENT_COUNT 个"
            echo "    备注：$NOTES"
            echo ""
        fi
    done
}

delete_snapshot() {
    local VERSION_NAME=$1
    
    if [ -z "$VERSION_NAME" ]; then
        echo -e "${RED}✗ 请指定版本号${NC}"
        exit 1
    fi
    
    VERSION_DIR="$VERSIONS_DIR/$VERSION_NAME"
    if [ ! -d "$VERSION_DIR" ]; then
        echo -e "${RED}✗ 版本不存在：$VERSION_NAME${NC}"
        exit 1
    fi
    
    read -p "确认删除版本 $VERSION_NAME？[y/N]: " CONFIRM
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        echo "已取消"
        exit 0
    fi
    
    rm -rf "$VERSION_DIR"
    echo -e "${GREEN}✓ 版本已删除：$VERSION_NAME${NC}"
}

# 主逻辑
case "$ACTION" in
    create)
        create_snapshot
        ;;
    list)
        list_snapshots
        ;;
    delete)
        delete_snapshot "$VERSION_NAME"
        ;;
    *)
        echo "用法:"
        echo "  $0 create [版本号] [备注]  - 创建快照"
        echo "  $0 list                    - 列出所有快照"
        echo "  $0 delete 版本号           - 删除快照"
        exit 1
        ;;
esac
