#!/bin/bash
set -e

echo "======================================"
echo "🏛️ AI 朝廷 (danghuangshang) 集成工具"
echo "======================================"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSIONS_DIR="$SCRIPT_DIR/versions"
PROJECT_DIR="/home/openclaw/boluobobo-ai-court-tutorial"
SKILLS_DIR="/home/openclaw/.openclaw/workspace/skills"
CLAWD_DIR="/home/openclaw/clawd"
CONFIG_DIR="$HOME/.openclaw"
CONFIG_FILE="$CONFIG_DIR/openclaw.json"

# 加载辅助脚本
source "$SCRIPT_DIR/snapshot.sh" 2>/dev/null || true
source "$SCRIPT_DIR/rollback.sh" 2>/dev/null || true

# ============================================
# 阶段 0: 环境检测
# ============================================
echo -e "${CYAN}📋 环境检测...${NC}"

HAS_PROJECT=false
HAS_CONFIG=false
HAS_CLAWD=false

[ -d "$PROJECT_DIR/.git" ] && HAS_PROJECT=true
[ -f "$CONFIG_FILE" ] && HAS_CONFIG=true
[ -d "$CLAWD_DIR" ] && HAS_CLAWD=true

echo "  项目仓库：$([ "$HAS_PROJECT" = true ] && echo '✓ 已存在' || echo '✗ 不存在')"
echo "  OpenClaw 配置：$([ "$HAS_CONFIG" = true ] && echo '✓ 已存在' || echo '✗ 不存在')"
echo "  Agent 工作区：$([ "$HAS_CLAWD" = true ] && echo '✓ 已存在' || echo '✗ 不存在')"

# ============================================
# 主菜单
# ============================================
echo ""
echo -e "${CYAN}请选择操作:${NC}"
echo "  1) 更新到最新版本（默认）"
echo "  2) 查看版本快照列表"
echo "  3) 回滚到历史版本"
echo "  4) 创建当前版本快照"
echo "  5) 配置平台机器人（添加飞书/Discord）"
echo "  6) 配置 Agent 模型映射"
echo "  7) 退出"
echo ""
read -p "请选择 [1-7，默认 1]: " MENU_SELECT
MENU_SELECT=${MENU_SELECT:-1}

case $MENU_SELECT in
    1)
        # 继续执行更新逻辑
        ;;
    2)
        # 列出快照
        if [ -x "$SCRIPT_DIR/snapshot.sh" ]; then
            bash "$SCRIPT_DIR/snapshot.sh" list
        else
            echo "快照工具不可用"
        fi
        exit 0
        ;;
    3)
        # 回滚
        if [ -x "$SCRIPT_DIR/rollback.sh" ]; then
            bash "$SCRIPT_DIR/rollback.sh"
        else
            echo "回滚工具不可用"
        fi
        exit 0
        ;;
    4)
        # 创建快照
        echo ""
        read -p "备注（可选）: " SNAPSHOT_NOTES
        if [ -x "$SCRIPT_DIR/snapshot.sh" ]; then
            bash "$SCRIPT_DIR/snapshot.sh" create "" "$SNAPSHOT_NOTES"
        else
            echo "快照工具不可用"
        fi
        exit 0
        ;;
    5)
        # 配置平台
        echo ""
        if [ -x "$SCRIPT_DIR/config-platform.sh" ]; then
            bash "$SCRIPT_DIR/config-platform.sh"
        else
            echo "平台配置工具不可用"
        fi
        exit 0
        ;;
    6)
        # 配置 Agent 模型
        echo ""
        if [ -x "$SCRIPT_DIR/config-agents.sh" ]; then
            bash "$SCRIPT_DIR/config-agents.sh"
        else
            echo "Agent 配置工具不可用"
        fi
        exit 0
        ;;
    7)
        echo "退出"
        exit 0
        ;;
    *)
        echo "无效选择"
        exit 1
        ;;
esac

# ============================================
# 判断模式：首次集成 vs 更新
# ============================================
if [ "$HAS_PROJECT" = false ] || [ "$HAS_CONFIG" = false ]; then
    MODE="install"
    echo -e "${YELLOW}📋 检测到首次集成环境${NC}"
else
    MODE="update"
    echo -e "${YELLOW}📋 检测到已集成环境，执行更新${NC}"
fi

echo ""

# ============================================
# 首次集成模式
# ============================================
if [ "$MODE" = "install" ]; then
    echo "======================================"
    echo "🚀 首次集成模式"
    echo "======================================"
    echo ""

    # 步骤 1: 克隆项目
    echo -e "${YELLOW}[1/7] 克隆项目仓库...${NC}"
    if [ ! -d "$PROJECT_DIR" ]; then
        git clone https://github.com/wanikua/danghuangshang "$PROJECT_DIR"
        echo -e "${GREEN}✓ 项目已克隆${NC}"
    else
        echo -e "${YELLOW}⚠ 项目目录已存在，跳过克隆${NC}"
    fi

    # 步骤 2: 询问平台配置
    echo ""
    echo -e "${YELLOW}[2/7] 选择交互平台${NC}"
    echo ""
    echo "  1) 飞书（国内推荐）"
    echo "  2) Discord（海外推荐）"
    echo "  3) 仅本地（WebUI 模式，无需配置）"
    echo "  4) 暂不配置（后续通过 config-platform.sh 添加）"
    echo ""
    read -p "请选择 [1/2/3/4，默认 3]: " PLATFORM
    PLATFORM=${PLATFORM:-3}

    # 步骤 3: 收集平台凭证
    echo ""
    echo -e "${YELLOW}[3/7] 配置平台凭证${NC}"
    echo ""

    if [ "$PLATFORM" = "4" ]; then
        echo -e "${CYAN}  暂不配置平台凭证${NC}"
        echo "  您可以后续通过以下命令添加："
        echo "    /home/openclaw/.openclaw/workspace/skills/update-openclaw-danghuangshang/config-platform.sh"
        echo ""
        PLATFORM_NAME="webui"
        FEISHU_APP_ID=""
        FEISHU_APP_SECRET=""
        DISCORD_TOKEN=""
        DISCORD_GUILD_ID=""
        DISCORD_ACCOUNTS=""
        EXISTING_DISCORD_ACCOUNTS=""
    elif [ "$PLATFORM" = "1" ]; then
        echo "飞书配置："
        echo "  1. 去 https://open.feishu.cn/app 创建企业自建应用"
        echo "  2. 添加「机器人」能力"
        echo "  3. 事件接收方式选择「WebSocket 长连接」"
        echo ""
        read -p "  App ID: " FEISHU_APP_ID
        read -p "  App Secret: " FEISHU_APP_SECRET
        if [ -z "$FEISHU_APP_ID" ] || [ -z "$FEISHU_APP_SECRET" ]; then
            echo -e "${RED}✗ App ID 和 App Secret 不能为空${NC}"
            exit 1
        fi
        PLATFORM_NAME="feishu"
        DISCORD_ACCOUNTS=""
        EXISTING_DISCORD_ACCOUNTS=""
    elif [ "$PLATFORM" = "2" ]; then
        echo "Discord 配置："
        echo "  1. 去 https://discord.com/developers/applications 创建 Bot"
        echo "  2. 开启 Message Content Intent + Server Members Intent"
        echo "  3. 邀请 Bot 到你的服务器"
        echo ""
        
        # 检测现有 Discord 账户和 Agent
        echo "  📊 检测现有 Discord 机器人账户和 Agent..."
        
        # 获取现有 Discord 账户
        EXISTING_DISCORD_ACCOUNTS=$(python3 << 'PYEOF'
import json
try:
    with open("$CONFIG_FILE", 'r') as f:
        config = json.load(f)
    accounts = config.get('channels', {}).get('discord', {}).get('accounts', {})
    if accounts:
        for name, data in accounts.items():
            # 显示账户名和关联的 Agent（如果有）
            print(f"{name}")
except:
    pass
PYEOF
)
        
        # 获取现有 Agent 列表
        EXISTING_AGENTS=$(python3 << 'PYEOF'
import json
try:
    with open("$CONFIG_FILE", 'r') as f:
        config = json.load(f)
    agents = config.get('agents', {}).get('list', [])
    for a in agents:
        print(a.get('id'))
except:
    pass
PYEOF
)
        
        echo ""
        if [ -n "$EXISTING_DISCORD_ACCOUNTS" ]; then
            echo "  🤖 发现现有 Discord 机器人账户:"
            echo "$EXISTING_DISCORD_ACCOUNTS" | while read account; do
                echo "    - $account"
            done
            echo ""
        fi
        
        if [ -n "$EXISTING_AGENTS" ]; then
            echo "  🏛️ 发现现有 Agent:"
            echo "$EXISTING_AGENTS" | while read agent; do
                # 检查是否是 AI 朝廷 Agent
                if echo "silijian neige duchayuan bingbu hubu libu gongbu libu2 xingbu" | grep -qw "$agent"; then
                    echo "    - $agent (AI 朝廷部门)"
                else
                    echo "    - $agent (其他 Agent)"
                fi
            done
            echo ""
        fi
        
        # 计算需要配置的 Agent 数量
        NEEDED_ACCOUNTS=$(echo "$EXISTING_DISCORD_ACCOUNTS" | grep -v "^$" | wc -l)
        TOTAL_AGENTS=9
        
        echo "  📋 配置方案分析:"
        echo "    AI 朝廷共需 9 个 Agent：司礼监、内阁、都察院、兵部、户部、礼部、工部、吏部、刑部"
        echo "    现有 Discord 机器人：$NEEDED_ACCOUNTS 个"
        echo ""
        
        if [ "$NEEDED_ACCOUNTS" -eq 0 ]; then
            echo "  【推荐】创建新 Bot 或复用现有账户:"
            echo "    选项 1: 创建 9 个新 Bot（每个 Agent 独立，推荐用于生产环境）"
            echo "    选项 2: 创建 1 个 Bot，所有 Agent 共用（推荐用于测试/个人使用）"
            echo ""
            read -p "  请选择 [1/2，默认 2]: " DISCORD_OPTION
            DISCORD_OPTION=${DISCORD_OPTION:-2}
            
            if [ "$DISCORD_OPTION" = "1" ]; then
                echo ""
                echo "  ⚠️  提示：创建 9 个独立 Bot 需要多次操作，建议先配置司礼监，"
                echo "  其他 Agent 可后续通过 config-platform.sh 添加"
                echo ""
                read -p "  Discord Bot Token（司礼监）: " DISCORD_TOKEN
                if [ -z "$DISCORD_TOKEN" ]; then
                    echo -e "${RED}✗ Bot Token 不能为空${NC}"
                    exit 1
                fi
                DISCORD_CONFIG_MODE="single_new"
            else
                read -p "  Discord Bot Token（所有 Agent 共用）: " DISCORD_TOKEN
                if [ -z "$DISCORD_TOKEN" ]; then
                    echo -e "${RED}✗ Bot Token 不能为空${NC}"
                    exit 1
                fi
                DISCORD_CONFIG_MODE="shared"
            fi
        elif [ "$NEEDED_ACCOUNTS" -lt 9 ]; then
            echo "  【推荐】复用现有机器人 + 补充新机器人:"
            echo "    选项 1: 所有 Agent 共用现有机器人（最简单）"
            echo "    选项 2: 部分 Agent 用现有机器人，部分创建新机器人"
            echo "    选项 3: 创建 9 个新机器人（现有机器人保留但不用于 AI 朝廷）"
            echo ""
            read -p "  请选择 [1/2/3，默认 1]: " DISCORD_OPTION
            DISCORD_OPTION=${DISCORD_OPTION:-1}
            
            case $DISCORD_OPTION in
                1)
                    echo "  ✓ 选择：所有 Agent 共用现有机器人"
                    read -p "  使用哪个现有机器人？（输入名称）: " DISCORD_TOKEN
                    # 这里需要获取 token，简化处理：让用户输入
                    read -p "  该机器人的 Bot Token: " DISCORD_TOKEN
                    if [ -z "$DISCORD_TOKEN" ]; then
                        echo -e "${RED}✗ Bot Token 不能为空${NC}"
                        exit 1
                    fi
                    DISCORD_CONFIG_MODE="reuse_existing"
                    ;;
                2)
                    echo "  ✓ 选择：混合模式（现有 + 新创建）"
                    echo "  请提供司礼监的 Bot Token（可用现有或新创建）:"
                    read -p "  Discord Bot Token: " DISCORD_TOKEN
                    if [ -z "$DISCORD_TOKEN" ]; then
                        echo -e "${RED}✗ Bot Token 不能为空${NC}"
                        exit 1
                    fi
                    DISCORD_CONFIG_MODE="hybrid"
                    echo "  提示：其他 8 个 Agent 可在首次集成后通过 config-platform.sh 添加"
                    ;;
                3)
                    echo "  ✓ 选择：创建新机器人（现有机器人保留）"
                    read -p "  Discord Bot Token（司礼监新创建）: " DISCORD_TOKEN
                    if [ -z "$DISCORD_TOKEN" ]; then
                        echo -e "${RED}✗ Bot Token 不能为空${NC}"
                        exit 1
                    fi
                    DISCORD_CONFIG_MODE="single_new"
                    ;;
                *)
                    echo "  默认选择选项 1"
                    read -p "  使用哪个现有机器人？（输入名称）: " DISCORD_TOKEN
                    read -p "  该机器人的 Bot Token: " DISCORD_TOKEN
                    DISCORD_CONFIG_MODE="reuse_existing"
                    ;;
            esac
        else
            echo "  ✓ 现有机器人数量充足（$NEEDED_ACCOUNTS >= 9）"
            echo "  可以选择复用现有机器人或创建新机器人"
            echo ""
            read -p "  是否使用现有机器人？[Y/n]: " USE_EXISTING
            USE_EXISTING=${USE_EXISTING:-Y}
            
            if [ "$USE_EXISTING" = "Y" ] || [ "$USE_EXISTING" = "y" ]; then
                read -p "  使用哪个现有机器人的 Token（司礼监）: " DISCORD_ACCOUNT_TO_USE
                read -p "  该机器人的 Bot Token: " DISCORD_TOKEN
                DISCORD_CONFIG_MODE="reuse_existing"
            else
                read -p "  Discord Bot Token（新创建）: " DISCORD_TOKEN
                DISCORD_CONFIG_MODE="single_new"
            fi
        fi
        
        read -p "  Discord Guild ID（可选，留空则所有服务器生效）: " DISCORD_GUILD_ID
        PLATFORM_NAME="discord"
    else
        echo -e "${GREEN}  WebUI 模式，无需额外配置${NC}"
        PLATFORM_NAME="webui"
        FEISHU_APP_ID=""
        FEISHU_APP_SECRET=""
        DISCORD_TOKEN=""
        DISCORD_GUILD_ID=""
        DISCORD_ACCOUNTS=""
        EXISTING_DISCORD_ACCOUNTS=""
        DISCORD_CONFIG_MODE="none"
    fi

    # 步骤 4: 询问模型配置
    echo ""
    echo -e "${YELLOW}[4/7] 配置 AI 模型${NC}"
    echo ""
    
    # 检测可用模型
    echo "  📊 检测可用模型..."
    MODEL_INFO=$(python3 << PYEOF
import json
try:
    with open("$CONFIG_FILE", 'r') as f:
        config = json.load(f)
    models = []
    if 'models' in config and 'providers' in config['models']:
        for provider, data in config['models']['providers'].items():
            if 'models' in data:
                for m in data['models']:
                    model_id = f"{provider}/{m['id']}"
                    # 尝试获取模型参数信息
                    context = m.get('context', 0)
                    models.append((model_id, context))
    # 按上下文大小排序
    models.sort(key=lambda x: x[1], reverse=True)
    for model_id, ctx in models:
        print(f"{model_id}|{ctx}")
except Exception as e:
    pass
PYEOF
)
    
    if [ -n "$MODEL_INFO" ]; then
        echo "  🤖 可用模型（按上下文大小排序）:"
        echo ""
        i=1
        STRONG_IDX=1
        FAST_IDX=1
        GENERAL_IDX=1
        
        echo "$MODEL_INFO" | while IFS='|' read model_id ctx; do
            if [ "$i" -le 3 ]; then
                echo "    $i) $model_id (context: $ctx) ← 推荐强力模型"
            elif [ "$i" -le 6 ]; then
                echo "    $i) $model_id (context: $ctx) ← 推荐快速模型"
            else
                echo "    $i) $model_id (context: $ctx)"
            fi
            i=$((i+1))
        done
        echo ""
        
        echo "  🎯 【推荐配置】根据 Agent 职责分配模型:"
        echo "    ┌─────────────────────────────────────────────────┐"
        echo "    │ 强力模型（大上下文）: 司礼监、内阁、都察院       │"
        echo "    │         ↓ 复杂决策、战略规划、代码审查           │"
        echo "    │ 快速模型（中上下文）: 兵部、工部                 │"
        echo "    │         ↓ 编码开发、DevOps 部署                  │"
        echo "    │ 通用模型（任意）: 户部、礼部、吏部、刑部         │"
        echo "    │         ↓ 分析任务、文案创作、项目管理、法务     │"
        echo "    └─────────────────────────────────────────────────┘"
        echo ""
        
        echo "  【配置选项】"
        echo "    1) 使用推荐配置（3 类模型）"
        echo "    2) 单一模型（所有 Agent 共用）"
        echo "    3) 自定义映射（每个 Agent 单独配置）"
        echo ""
        read -p "  请选择配置方式 [1/2/3，默认 1]: " MODEL_OPTION
        MODEL_OPTION=${MODEL_OPTION:-1}
        
        case $MODEL_OPTION in
            1)
                echo ""
                echo "  请选择模型（输入编号）:"
                echo "$MODEL_INFO" | nl -w2 -s") "
                echo ""
                
                read -p "  强力模型编号（司礼监/内阁/都察院）: " STRONG_IDX
                read -p "  快速模型编号（兵部/工部）: " FAST_IDX
                read -p "  通用模型编号（户部/礼部/吏部/刑部）: " GENERAL_IDX
                
                STRONG_MODEL=$(echo "$MODEL_INFO" | sed -n "${STRONG_IDX}p" | cut -d'|' -f1)
                FAST_MODEL=$(echo "$MODEL_INFO" | sed -n "${FAST_IDX}p" | cut -d'|' -f1)
                GENERAL_MODEL=$(echo "$MODEL_INFO" | sed -n "${GENERAL_IDX}p" | cut -d'|' -f1)
                
                MODEL_CONFIG="recommended"
                echo ""
                echo -e "${GREEN}  ✓ 推荐配置:${NC}"
                echo "    强力模型：$STRONG_MODEL"
                echo "    快速模型：$FAST_MODEL"
                echo "    通用模型：$GENERAL_MODEL"
                ;;
            2)
                echo ""
                echo "  选择单一模型（所有 Agent 共用）:"
                echo "$MODEL_INFO" | nl -w2 -s") "
                echo ""
                read -p "  模型编号: " SINGLE_IDX
                SINGLE_MODEL=$(echo "$MODEL_INFO" | sed -n "${SINGLE_IDX}p" | cut -d'|' -f1)
                MODEL_CONFIG="single:$SINGLE_MODEL"
                echo -e "${GREEN}  ✓ 单一模型：$SINGLE_MODEL${NC}"
                ;;
            3)
                echo ""
                echo "  🎨 自定义 Agent-模型映射:"
                echo "  请为每个 Agent 选择模型（输入编号，留空使用默认）:"
                echo ""
                
                CUSTOM_MAPPING=""
                for agent_name in "silijian:司礼监" "neige:内阁" "duchayuan:都察院" "bingbu:兵部" "hubu:户部" "libu:礼部" "gongbu:工部" "libu2:吏部" "xingbu:刑部"; do
                    agent_id=$(echo $agent_name | cut -d':' -f1)
                    agent_cn=$(echo $agent_name | cut -d':' -f2)
                    echo "$MODEL_INFO" | nl -w2 -s") "
                    read -p "  $agent_cn ($agent_id): " MODEL_IDX
                    if [ -n "$MODEL_IDX" ]; then
                        MODEL_ID=$(echo "$MODEL_INFO" | sed -n "${MODEL_IDX}p" | cut -d'|' -f1)
                        CUSTOM_MAPPING="$CUSTOM_MAPPING$agent_id:$MODEL_ID\n"
                    fi
                done
                
                MODEL_CONFIG="custom"
                MODEL_MAPPING_DATA="$CUSTOM_MAPPING"
                echo -e "${GREEN}  ✓ 自定义映射完成${NC}"
                ;;
            *)
                echo "  默认选择选项 1"
                read -p "  强力模型编号: " STRONG_IDX
                read -p "  快速模型编号: " FAST_IDX
                read -p "  通用模型编号: " GENERAL_IDX
                STRONG_MODEL=$(echo "$MODEL_INFO" | sed -n "${STRONG_IDX}p" | cut -d'|' -f1)
                FAST_MODEL=$(echo "$MODEL_INFO" | sed -n "${FAST_IDX}p" | cut -d'|' -f1)
                GENERAL_MODEL=$(echo "$MODEL_INFO" | sed -n "${GENERAL_IDX}p" | cut -d'|' -f1)
                MODEL_CONFIG="recommended"
                ;;
        esac
    else
        echo "  ⚠ 未检测到可用模型，将使用默认模型"
        MODEL_CONFIG="use_default"
    fi

    # 步骤 5: 检测当前环境并确认
    echo ""
    echo -e "${YELLOW}[5/7] 检测当前 OpenClaw 环境...${NC}"

    # 检测当前配置状态
    if [ -f "$CONFIG_FILE" ]; then
        echo "  ✓ 检测到现有配置文件"
        
        # 统计现有 Agent 数量
        EXISTING_AGENT_COUNT=$(python3 -c "import json; c=json.load(open('$CONFIG_FILE')); print(len(c.get('agents',{}).get('list',[])))" 2>/dev/null || echo "0")
        echo "  现有 Agent 数量：$EXISTING_AGENT_COUNT 个"
        
        # 列出现有 Agent ID
        if [ "$EXISTING_AGENT_COUNT" -gt 0 ]; then
            echo "  现有 Agent:"
            python3 -c "import json; c=json.load(open('$CONFIG_FILE')); [print(f'    - {a.get(\"id\")}') for a in c.get('agents',{}).get('list',[])]" 2>/dev/null
        fi
        
        # 检测平台配置
        EXISTING_CHANNELS=""
        if python3 -c "import json; c=json.load(open('$CONFIG_FILE')); assert 'channels' in c" 2>/dev/null; then
            EXISTING_CHANNELS=$(python3 -c "import json; c=json.load(open('$CONFIG_FILE')); print(', '.join(c.get('channels',{}).keys()))" 2>/dev/null)
            echo "  现有平台：$EXISTING_CHANNELS"
        fi
        
        # 检测模型配置
        if python3 -c "import json; c=json.load(open('$CONFIG_FILE')); assert 'models' in c and 'providers' in c['models']" 2>/dev/null; then
            MODEL_PROVIDERS=$(python3 -c "import json; c=json.load(open('$CONFIG_FILE')); print(', '.join(c.get('models',{}).get('providers',{}).keys()))" 2>/dev/null)
            echo "  模型提供商：$MODEL_PROVIDERS"
        fi
    else
        echo "  ⚠ 未检测到现有配置文件，将创建新配置"
        EXISTING_AGENT_COUNT=0
    fi

    # 显示将要添加的内容
    echo ""
    echo -e "${CYAN}  将要添加的内容:${NC}"
    echo "    - 9 个 AI 朝廷 Agent（司礼监、内阁、都察院、兵部、户部、礼部、工部、吏部、刑部）"
    echo "    - 平台配置（$PLATFORM_NAME）"
    echo "    - Agent 工作区（/home/openclaw/clawd/）"
    echo "    - Skills（15 个官方 Skills）"
    
    # 显示合并策略
    echo ""
    echo -e "${CYAN}  合并策略:${NC}"
    echo "    ✓ models.providers - 保留现有"
    echo "    ✓ gateway - 保留现有"
    echo "    ✓ agents.defaults - 保留现有"
    echo "    ✓ agents.list - 追加 AI 朝廷 Agent（不覆盖现有）"
    echo "    ✓ channels.accounts - 合并（添加 AI 朝廷账户，保留现有）"
    echo "    ✓ bindings - 追加（不覆盖现有）"

    # 确认提示
    echo ""
    echo -e "${YELLOW}⚠ 重要提示:${NC}"
    echo "  1. 现有配置将被备份至：$CONFIG_FILE.ai-court-backup"
    echo "  2. 如果 Gateway 正在运行，需要重启才能生效"
    echo "  3. 如果平台账户冲突，AI 朝廷账户会覆盖同名账户"
    echo ""
    
    read -p "是否确认合并配置？[Y/n]: " CONFIRM
    CONFIRM=${CONFIRM:-Y}
    if [ "$CONFIRM" != "Y" ] && [ "$CONFIRM" != "y" ]; then
        echo -e "${YELLOW}⚠ 已取消操作${NC}"
        exit 0
    fi

    # 执行备份
    echo ""
    echo -e "${YELLOW}  备份配置...${NC}"
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "$CONFIG_FILE.ai-court-backup"
        echo -e "${GREEN}  ✓ 已备份至：$CONFIG_FILE.ai-court-backup${NC}"
    fi

    # 使用 Python 合并配置（保留原有配置，只添加 AI 朝廷部分）
    python3 << PYEOF
import json
import os

config_file = "$CONFIG_FILE"
template_file = "$PROJECT_DIR/openclaw.example.json"
platform = "$PLATFORM_NAME"
feishu_app_id = "$FEISHU_APP_ID" if "$PLATFORM" = "1" else ""
feishu_app_secret = "$FEISHU_APP_SECRET" if "$PLATFORM" = "1" else ""
discord_token = "$DISCORD_TOKEN" if "$PLATFORM" = "2" else ""
discord_guild_id = "$DISCORD_GUILD_ID" if "$PLATFORM" = "2" else ""

# 读取现有配置
if os.path.exists(config_file):
    with open(config_file, 'r') as f:
        config = json.load(f)
    print("  ✓ 读取现有配置")
else:
    config = {}
    print("  ⚠ 无现有配置，创建新配置")

# 读取模板配置
if os.path.exists(template_file):
    with open(template_file, 'r') as f:
        template = json.load(f)
    print("  ✓ 读取模板配置")
else:
    print("  ⚠ 模板文件不存在，使用默认配置")
    template = {}

# 合并 models（保留现有，不覆盖）
if "models" not in config:
    config["models"] = template.get("models", {})
print("  ✓ 保留现有 models 配置")

# 合并 gateway（保留现有，不覆盖）
if "gateway" not in config:
    config["gateway"] = template.get("gateway", {"mode": "local", "port": 18789})
print("  ✓ 保留现有 gateway 配置")

# 合并 agents.defaults
if "agents" not in config:
    config["agents"] = {}
if "defaults" not in config["agents"]:
    config["agents"]["defaults"] = template.get("agents", {}).get("defaults", {
        "workspace": "/home/openclaw/clawd",
        "sandbox": {"mode": "non-main"},
        "skipBootstrap": True
    })
print("  ✓ 保留现有 agents.defaults")

# 添加 AI 朝廷 Agent 配置
silijian_identity = """你是 AI 朝廷的司礼监大内总管。你的职责是【规划调度】，不是亲自执行。说话简练干脆。

【核心原则】除了日常闲聊和简单问答，所有涉及实际工作的任务（写代码、查资料、分析数据、写文案、运维操作等），必须先经内阁优化再派发。你是调度枢纽，不是搬砖工。

【任务流程——内阁前置】收到用户任务后：
1. 先用 sessions_spawn 或 sessions_send 将原始任务发给内阁（agentId: neige），请内阁优化 Prompt、生成执行计划（plan）、判断是否缺失关键 context；
2. 如果内阁回复需要补充信息，你向用户追问，拿到后再次发给内阁；
3. 内阁返回优化后的任务描述和 plan 后，你再按 plan 在当前频道 @对应部门 派发具体任务。
跳过内阁的情况：纯闲聊、简单问答、状态查询、紧急 hotfix（标注跳过原因）。

【部门职责】内阁=Prompt 优化与计划生成、都察院=代码审查（push 后自动触发）、兵部=编码开发、户部=财务分析、礼部=品牌营销、工部=运维部署、吏部=项目管理、刑部=法务合规。

【派活方式】用 message 工具在当前频道发消息，@对应部门下达任务。派活时用内阁优化后的 Prompt，确保包含：【角色】+【任务】+【背景】+【要求】+【格式】。一切工作流转必须在频道内公开可见。

【审批流程】涉及代码提交 → 都察院会在 push 时自动审查；涉及重大决策（预算、架构、方向变更）→ @内阁 审议。都察院审查不通过则打回修改，内阁有否决权。

【什么时候自己回答】仅限：纯闲聊、确认信息、汇报进度、问澄清问题。其他一律走内阁前置流程。"""

departments = [
    ("silijian", "司礼监", silijian_identity, False, True),
    ("neige", "内阁", "你是内阁首辅，专精战略决策、方案审议、全局规划。回答用中文，高屋建瓴。", False, False),
    ("duchayuan", "都察院", "你是都察院御史，专精监察审计、代码审查、质量把控、安全评估。回答用中文，铁面无私。", True, False),
    ("bingbu", "兵部", "你是兵部尚书，专精软件工程、系统架构。回答用中文。", True, False),
    ("hubu", "户部", "你是户部尚书，专精财务分析、成本管控。回答用中文。", False, False),
    ("libu", "礼部", "你是礼部尚书，专精品牌营销、内容创作。回答用中文。", False, False),
    ("gongbu", "工部", "你是工部尚书，专精 DevOps、服务器运维。回答用中文。", True, False),
    ("libu2", "吏部", "你是吏部尚书，专精项目管理、团队协调。回答用中文。", False, False),
    ("xingbu", "刑部", "你是刑部尚书，专精法务合规、知识产权。回答用中文。", False, False),
]

# 获取模型配置
model_config = "$MODEL_CONFIG"
strong_model = "$STRONG_MODEL"
fast_model = "$FAST_MODEL"
general_model = "$GENERAL_MODEL"

# 根据模型配置类型设置 Agent 模型
if model_config == "recommended":
    print(f"  使用推荐配置：强力={strong_model}, 快速={fast_model}, 通用={general_model}")
    model_mapping = {
        'silijian': strong_model,
        'neige': strong_model,
        'duchayuan': strong_model,
        'bingbu': fast_model,
        'gongbu': fast_model,
        'hubu': general_model,
        'libu': general_model,
        'libu2': general_model,
        'xingbu': general_model
    }
elif model_config.startswith("single:"):
    single = model_config.split(":")[1]
    print(f"  使用单一模型：{single}")
    model_mapping = {aid: single for aid, _, _, _, _ in departments}
else:
    # 使用默认模型
    default_model = "vllm/qwen3.5-coder"
    if "agents" in config and "defaults" in config["agents"] and "model" in config["agents"]["defaults"]:
        if "primary" in config["agents"]["defaults"]["model"]:
            default_model = config["agents"]["defaults"]["model"]["primary"]
    print(f"  使用默认模型：{default_model}")
    model_mapping = {aid: default_model for aid, _, _, _, _ in departments}

# 添加 Agent（只添加不存在的）
if "list" not in config["agents"]:
    config["agents"]["list"] = []

existing_ids = [a.get("id") for a in config["agents"]["list"]]
added_count = 0
for agent_id, name, identity, sandbox, is_silijian in departments:
    if agent_id not in existing_ids:
        agent = {
            "id": agent_id,
            "name": name,
            "workspace": f"/home/openclaw/clawd/{agent_id}",
            "model": {"primary": model_mapping[agent_id]},
            "identity": {"theme": identity},
            "sandbox": {"mode": "agent" if sandbox else "off"}
        }
        config["agents"]["list"].append(agent)
        added_count += 1
        print(f"  ✓ 添加 {agent_id} → {model_mapping[agent_id]}")
    else:
        print(f"  ⚠ Agent {agent_id} 已存在，跳过")

print(f"  ✓ 新增 {added_count} 个 Agent")

# 司礼监添加/更新 subagents 配置
for agent in config["agents"]["list"]:
    if agent["id"] == "silijian":
        agent["subagents"] = {
            "allowAgents": ["neige", "duchayuan", "bingbu", "hubu", "libu", "gongbu", "libu2", "xingbu"],
            "maxConcurrent": 4
        }
        print("  ✓ 配置 silijian subagents")

# 配置平台（合并，不覆盖现有账户）
if platform == "feishu":
    if "channels" not in config:
        config["channels"] = {}
    if "feishu" not in config["channels"]:
        config["channels"]["feishu"] = {"enabled": True, "dmPolicy": "open", "groupPolicy": "open", "accounts": {}}
    if "accounts" not in config["channels"]["feishu"]:
        config["channels"]["feishu"]["accounts"] = {}
    
    # 只添加 silijian 和其他部门的账户，不覆盖现有账户
    config["channels"]["feishu"]["accounts"]["silijian"] = {
        "name": "司礼监",
        "appId": feishu_app_id,
        "appSecret": feishu_app_secret,
        "groupPolicy": "open"
    }
    for agent_id, name, _, _, _ in departments[1:]:
        config["channels"]["feishu"]["accounts"][agent_id] = {
            "name": name,
            "appId": feishu_app_id,
            "appSecret": feishu_app_secret,
            "groupPolicy": "allowlist",
            "allowFrom": ["*"]
        }
    print("  ✓ 配置 feishu 平台")
elif platform == "discord":
    if "channels" not in config:
        config["channels"] = {}
    if "discord" not in config["channels"]:
        config["channels"]["discord"] = {"enabled": True, "groupPolicy": "open", "allowBots": True, "accounts": {}}
    if "accounts" not in config["channels"]["discord"]:
        config["channels"]["discord"]["accounts"] = {}
    
    config["channels"]["discord"]["accounts"]["silijian"] = {
        "name": "司礼监",
        "token": discord_token,
        "groupPolicy": "open"
    }
    if discord_guild_id:
        config["channels"]["discord"]["guilds"] = {discord_guild_id: {"requireMention": True}}
    print("  ✓ 配置 discord 平台")
else:
    print("  ✓ WebUI 模式，无需配置平台")

# 添加 bindings（只添加不存在的）
if "bindings" not in config:
    config["bindings"] = []

existing_bindings = []
for b in config["bindings"]:
    existing_bindings.append((b.get("agentId"), b.get("match", {}).get("channel"), b.get("match", {}).get("accountId")))

for agent_id, _, _, _, _ in departments:
    binding = ("silijian" if agent_id == "silijian" else agent_id, platform, agent_id)
    if binding not in existing_bindings:
        config["bindings"].append({
            "agentId": agent_id,
            "match": {"channel": platform, "accountId": agent_id}
        })

print("  ✓ 配置 bindings")

# 写入配置
with open(config_file, 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)

print(f"  ✓ 配置已保存：{config_file}")
PYEOF

    # 验证配置
    echo ""
    echo -e "${YELLOW}📋 验证配置文件...${NC}"
    
    # 1. JSON 语法校验
    if python3 -c "import json; json.load(open('$CONFIG_FILE'))" 2>/dev/null; then
        echo -e "${GREEN}  ✓ JSON 语法正确${NC}"
    else
        echo -e "${RED}  ✗ JSON 语法错误，恢复备份...${NC}"
        cp "$CONFIG_FILE.ai-court-backup" "$CONFIG_FILE"
        echo -e "${RED}✗ 配置验证失败，已恢复备份${NC}"
        exit 1
    fi
    
    # 2. 检查必要字段
    MISSING_FIELDS=""
    if ! python3 -c "import json; c=json.load(open('$CONFIG_FILE')); assert 'agents' in c and 'list' in c['agents']" 2>/dev/null; then
        MISSING_FIELDS="$MISSING_FIELDS agents.list"
    fi
    if [ -n "$MISSING_FIELDS" ]; then
        echo -e "${RED}  ✗ 缺少必要字段:$MISSING_FIELDS${NC}"
        cp "$CONFIG_FILE.ai-court-backup" "$CONFIG_FILE"
        echo -e "${RED}✗ 配置验证失败，已恢复备份${NC}"
        exit 1
    else
        echo -e "${GREEN}  ✓ 必要字段完整${NC}"
    fi
    
    # 3. 检查 AI 朝廷 Agent 是否添加成功
    AI_COURT_AGENTS="silijian neige duchayuan bingbu hubu libu gongbu libu2 xingbu"
    MISSING_AGENTS=""
    for agent in $AI_COURT_AGENTS; do
        if ! python3 -c "import json; c=json.load(open('$CONFIG_FILE')); assert any(a.get('id')=='$agent' for a in c.get('agents',{}).get('list',[]))" 2>/dev/null; then
            MISSING_AGENTS="$MISSING_AGENTS $agent"
        fi
    done
    if [ -n "$MISSING_AGENTS" ]; then
        echo -e "${YELLOW}  ⚠ 以下 Agent 未添加成功:$MISSING_AGENTS${NC}"
    else
        echo -e "${GREEN}  ✓ AI 朝廷 Agent 添加成功${NC}"
    fi
    
    # 4. 使用 openclaw config validate 校验（无需 gateway 运行）
    if command -v openclaw &>/dev/null; then
        echo "  运行 openclaw config validate 校验..."
        VALIDATE_OUTPUT=$(openclaw config validate 2>&1)
        if echo "$VALIDATE_OUTPUT" | grep -qi "error\|invalid\|failed"; then
            echo -e "${YELLOW}  ⚠ openclaw config validate 发现潜在问题:${VALIDATE_OUTPUT}" | head -3
            echo -e "${YELLOW}  建议： Gateway 启动后运行 openclaw doctor 进行完整检查${NC}"
        else
            echo -e "${GREEN}  ✓ openclaw config validate 校验通过${NC}"
        fi
    fi
    
    echo -e "${GREEN}✓ 配置验证完成${NC}"

    # 步骤 6: 创建工作区
    echo ""
    echo -e "${YELLOW}[6/7] 创建 Agent 工作区...${NC}"
    
    mkdir -p "$CLAWD_DIR"
    
    # 创建基础文件
    cat > "$CLAWD_DIR/SOUL.md" << 'EOF'
# SOUL.md - 朝廷行为准则

## 铁律
1. 废话不要多 — 说重点
2. 汇报要及时 — 做完就说
3. 做事要靠谱 — 先想后做

## 沟通风格
- 中文为主
- 直接说结论，需要细节再展开

## 朝廷架构
- 司礼监：总管调度
- 内阁：战略决策
- 都察院：代码审查
- 六部：各司其职
EOF
    echo "  ✓ 创建 SOUL.md"

    cat > "$CLAWD_DIR/AGENTS.md" << 'EOF'
# AGENTS.md - 朝廷工作区

读 SOUL.md 了解你是谁，读 USER.md 了解你服务的人。
EOF
    echo "  ✓ 创建 AGENTS.md"

    cat > "$CLAWD_DIR/USER.md" << 'EOF'
# USER.md - 关于你

- **称呼:** 陛下
- **语言:** 中文
- **风格:** 简洁高效
EOF
    echo "  ✓ 创建 USER.md"

    # 创建各部门工作区
    for agent in neige duchayuan bingbu hubu libu gongbu libu2 xingbu; do
        mkdir -p "$CLAWD_DIR/$agent/memory"
        cp "$CLAWD_DIR/AGENTS.md" "$CLAWD_DIR/$agent/"
        cp "$CLAWD_DIR/SOUL.md" "$CLAWD_DIR/$agent/"
        cp "$CLAWD_DIR/USER.md" "$CLAWD_DIR/$agent/"
    done
    echo "  ✓ 创建 8 个 Agent 工作区"

    # 步骤 7: 同步 Skills
    echo ""
    echo -e "${YELLOW}[7/7] 同步 AI 朝廷 Skills...${NC}"
    
    # 识别自定义 Skills
    UPSTREAM_SKILLS=$(ls "$PROJECT_DIR/skills/" | grep -v "^README.md$" || true)
    CURRENT_SKILLS=$(ls "$SKILLS_DIR" | grep -v "^README.md$" || true)
    
    CUSTOM_SKILLS=""
    for skill in $CURRENT_SKILLS; do
        is_upstream=false
        for upstream in $UPSTREAM_SKILLS; do
            if [ "$skill" = "$upstream" ]; then
                is_upstream=true
                break
            fi
        done
        if [ "$is_upstream" = false ]; then
            CUSTOM_SKILLS="$CUSTOM_SKILLS $skill"
        fi
    done
    CUSTOM_SKILLS=$(echo $CUSTOM_SKILLS | xargs)
    
    if [ -n "$CUSTOM_SKILLS" ]; then
        echo "  发现自定义 Skills: $CUSTOM_SKILLS"
        echo "  暂存到备份..."
        mkdir -p /tmp/custom-skills-backup
        for skill in $CUSTOM_SKILLS; do
            [ -d "$SKILLS_DIR/$skill" ] && cp -r "$SKILLS_DIR/$skill" /tmp/custom-skills-backup/
        done
    fi
    
    # 同步官方 Skills
    rsync -av --delete "$PROJECT_DIR/skills/" "$SKILLS_DIR/"
    
    # 恢复自定义 Skills
    for skill in $CUSTOM_SKILLS; do
        [ -d "/tmp/custom-skills-backup/$skill" ] && cp -r "/tmp/custom-skills-backup/$skill" "$SKILLS_DIR/"
    done
    
    echo -e "${GREEN}✓ Skills 已同步 ($(ls $SKILLS_DIR | wc -l) 个)${NC}"

    # 完成首次集成
    echo ""
    echo "======================================"
    echo -e "${GREEN}🎉 首次集成完成！${NC}"
    echo "======================================"
    echo ""
    echo "下一步："
    echo "  1. 重启 Gateway: openclaw gateway restart"
    echo "  2. 等待 Gateway 启动后，在 $([ "$PLATFORM" = "1" ] && echo '飞书' || echo 'Discord') 测试"
    echo "  3. 可选：构建 GUI Dashboard"
    echo ""
    echo "GUI 构建命令（可选）："
    echo "  cd $PROJECT_DIR/gui && npm install && npm run build"
    echo "  cd server && npm install"
    echo "  BOLUO_AUTH_TOKEN=\$(openssl rand -hex 16) node index.js &"
    echo ""

    exit 0
fi

# ============================================
# 更新模式（原有逻辑）
# ============================================
echo "======================================"
echo "🔄 更新模式"
echo "======================================"
echo ""

# 1. 备份
echo -e "${YELLOW}[1/8] 备份当前配置...${NC}"
BACKUP_DIR="/tmp/ai-court-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
[ -f "$CONFIG_FILE" ] && cp "$CONFIG_FILE" "$BACKUP_DIR/"
[ -d "$CLAWD_DIR" ] && cp -r "$CLAWD_DIR" "$BACKUP_DIR/"
[ -d "$SKILLS_DIR" ] && cp -r "$SKILLS_DIR" "$BACKUP_DIR/"
echo -e "${GREEN}✓ 备份到：$BACKUP_DIR${NC}"

# 2. 停止 GUI
echo -e "${YELLOW}[2/8] 停止 GUI...${NC}"
pkill -f "gui/server/index.js" 2>/dev/null || true
sleep 1
echo -e "${GREEN}✓ GUI 已停止${NC}"

# 3. 更新仓库
echo -e "${YELLOW}[3/8] 更新仓库...${NC}"
cd "$PROJECT_DIR"
git stash 2>/dev/null || true
git pull origin main
echo -e "${GREEN}✓ 仓库已更新${NC}"
git log --oneline -3

# 4. 更新 Skills
echo -e "${YELLOW}[4/8] 更新 Skills...${NC}"
UPSTREAM_SKILLS=$(ls "$PROJECT_DIR/skills/" | grep -v "^README.md$" || true)
CURRENT_SKILLS=$(ls "$SKILLS_DIR" | grep -v "^README.md$" || true)
CUSTOM_SKILLS=""
for skill in $CURRENT_SKILLS; do
    is_upstream=false
    for upstream in $UPSTREAM_SKILLS; do
        if [ "$skill" = "$upstream" ]; then
            is_upstream=true
            break
        fi
    done
    if [ "$is_upstream" = false ]; then
        CUSTOM_SKILLS="$CUSTOM_SKILLS $skill"
    fi
done
CUSTOM_SKILLS=$(echo $CUSTOM_SKILLS | xargs)
if [ -n "$CUSTOM_SKILLS" ]; then
    echo "  发现自定义 Skills: $CUSTOM_SKILLS"
    echo "  暂存到备份..."
    for skill in $CUSTOM_SKILLS; do
        [ -d "$SKILLS_DIR/$skill" ] && cp -r "$SKILLS_DIR/$skill" "$BACKUP_DIR/" && echo "    ✓ 备份 $skill"
    done
else
    echo "  未发现自定义 Skills"
fi
rsync -av --delete "$PROJECT_DIR/skills/" "$SKILLS_DIR/"
for skill in $CUSTOM_SKILLS; do
    [ -d "$BACKUP_DIR/$skill" ] && cp -r "$BACKUP_DIR/$skill" "$SKILLS_DIR/" && echo "    ✓ 恢复 $skill"
done
echo -e "${GREEN}✓ Skills 已更新 ($(ls $SKILLS_DIR | wc -l) 个)${NC}"

# 5. 提示 Agent 更新
echo -e "${YELLOW}[5/8] Agent 配置检查${NC}"
echo ""
echo "  上游新增以下 Agent（需要手动配置）："
echo "    - guozijian（国子监）- 教育培训"
echo "    - taiyiyuan（太医院）- 健康管理"
echo "    - neiwufu（内务府）- 后勤保障"
echo "    - yushanfang（御膳房）- 膳食安排"
echo ""
echo "  请检查 ~/.openclaw/openclaw.json 是否已添加这些 Agent"
echo ""
read -p "按 Enter 继续..."

# 6. 更新 GUI
echo -e "${YELLOW}[6/8] 更新 GUI...${NC}"
cd "$PROJECT_DIR/gui"
echo "  安装前端依赖..."
npm install > /dev/null 2>&1
echo "  构建前端..."
npm run build > /dev/null 2>&1
echo "  安装后端依赖..."
cd server && npm install > /dev/null 2>&1
echo -e "${GREEN}✓ GUI 已构建${NC}"

# 7. 重启 Gateway
echo -e "${YELLOW}[7/8] 重启 Gateway...${NC}"
openclaw doctor --fix 2>/dev/null || true
openclaw gateway restart
echo "  等待 Gateway 启动..."
for i in {1..6}; do
    sleep 5
    if curl -s http://127.0.0.1:18789/health 2>/dev/null | grep -q "live"; then
        echo -e "${GREEN}✓ Gateway 已启动（${i}*5 秒）${NC}"
        break
    fi
    echo "  等待中... ($i/6)"
    if [ $i -eq 6 ]; then
        echo -e "${RED}✗ Gateway 启动超时，请检查日志${NC}"
        echo "  查看日志：tail -50 /tmp/openclaw/openclaw-*.log"
    fi
done

# 8. 启动 GUI
echo -e "${YELLOW}[8/8] 启动 GUI...${NC}"
if [ -z "$BOLUO_AUTH_TOKEN" ]; then
    export BOLUO_AUTH_TOKEN=$(openssl rand -hex 16)
    echo "export BOLUO_AUTH_TOKEN=$BOLUO_AUTH_TOKEN" >> ~/.bashrc
    echo "  生成新 Token: $BOLUO_AUTH_TOKEN"
else
    echo "  使用现有 Token: ${BOLUO_AUTH_TOKEN:0:8}..."
fi
cd "$PROJECT_DIR/gui" && nohup node server/index.js > /tmp/gui.log 2>&1 &
GUI_PID=$!
echo "  GUI 进程 PID: $GUI_PID"
for i in {1..5}; do
    sleep 3
    if curl -sI http://localhost:18795 2>/dev/null | grep -q "200"; then
        echo -e "${GREEN}✓ GUI 已启动（${i}*3 秒）${NC}"
        break
    fi
    echo "  等待中... ($i/5)"
    if [ $i -eq 5 ]; then
        echo -e "${YELLOW}⚠ GUI 启动较慢，请等待后访问${NC}"
        echo "  查看日志：tail -30 /tmp/gui.log"
    fi
done

echo ""
echo "======================================"
echo -e "${GREEN}🎉 更新完成！${NC}"
echo "======================================"

# 创建版本快照
echo ""
echo -e "${YELLOW}📸 创建版本快照...${NC}"
if [ -x "$SCRIPT_DIR/snapshot.sh" ]; then
    GIT_COMMIT=$(cd "$PROJECT_DIR" 2>/dev/null && git log --oneline -1 2>/dev/null | cut -d' ' -f1 || echo "unknown")
    bash "$SCRIPT_DIR/snapshot.sh" create "" "更新 - commit ${GIT_COMMIT:0:8}"
else
    echo "  ⚠ 快照工具不可用，跳过"
fi

echo ""
echo "访问地址："
echo "  - Gateway: http://localhost:18789"
echo "  - GUI:     http://localhost:18795"
echo "  - Token:   $BOLUO_AUTH_TOKEN"
echo ""
echo "备份位置：$BACKUP_DIR"
echo ""
echo "下一步："
echo "  1. 在飞书/Discord 测试各 Agent"
echo "  2. 如需新增 Agent，编辑 ~/.openclaw/openclaw.json"
echo "  3. 配置定时备份：crontab -e"

if [ "$PLATFORM_NAME" = "webui" ]; then
    echo ""
    echo -e "${YELLOW}⚠  您选择了暂不配置平台或仅本地模式${NC}"
    echo "  如需添加飞书/Discord 机器人，请运行："
    echo "    $SCRIPT_DIR/config-platform.sh"
    echo "  或在主菜单中选择 5) 配置平台机器人"
fi
echo ""
