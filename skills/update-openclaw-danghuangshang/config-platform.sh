#!/bin/bash
# AI 朝廷平台配置工具 - 用于后续添加/修改平台配置

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置
CONFIG_FILE="$HOME/.openclaw/openclaw.json"

echo "======================================"
echo "🔧 AI 朝廷 平台配置工具"
echo "======================================"
echo ""

# 检查配置
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}✗ 未找到 OpenClaw 配置文件${NC}"
    echo "  请先运行首次集成：./update.sh"
    exit 1
fi

# 显示当前平台配置
echo -e "${CYAN}当前平台配置:${NC}"
python3 << 'PYEOF'
import json

with open("$CONFIG_FILE", 'r') as f:
    config = json.load(f)

channels = config.get('channels', {})
if channels:
    for name, data in channels.items():
        if name in ['feishu', 'discord', 'webui']:
            accounts = data.get('accounts', {})
            print(f"  {name}: {len(accounts)} 个账户")
            for acc_name in accounts.keys():
                print(f"    - {acc_name}")
else:
    print("  无平台配置")
PYEOF

echo ""
echo -e "${CYAN}请选择操作:${NC}"
echo "  1) 添加飞书机器人"
echo "  2) 添加 Discord 机器人"
echo "  3) 移除平台账户"
echo "  4) 查看平台配置详情"
echo "  5) 退出"
echo ""
read -p "请选择 [1-5]: " SELECT

case $SELECT in
    1)
        echo ""
        echo -e "${CYAN}📱 添加飞书机器人${NC}"
        echo ""
        echo "创建飞书机器人步骤："
        echo "  1. 访问 https://open.feishu.cn/app"
        echo "  2. 点击「创建应用」→「企业自建应用」"
        echo "  3. 填写应用名称（如「AI 朝廷 - 司礼监」）"
        echo "  4. 在「功能能力」中添加「机器人」"
        echo "  5. 在「事件订阅」中："
        echo "     - 接收消息类型：选择「消息」"
        echo "     - 接收方式：选择「WebSocket 长连接」"
        echo "     - 请求 URL：留空（脚本会自动处理）"
        echo "  6. 在「凭证管理」中获取 App ID 和 App Secret"
        echo ""
        read -p "机器人名称（如 司礼监）: " BOT_NAME
        read -p "App ID: " APP_ID
        read -p "App Secret: " APP_SECRET
        read -p "是否添加到所有群聊？[Y/n]: " GROUP_POLICY
        GROUP_POLICY=${GROUP_POLICY:-Y}
        
        if [ -z "$APP_ID" ] || [ -z "$APP_SECRET" ]; then
            echo -e "${RED}✗ App ID 和 App Secret 不能为空${NC}"
            exit 1
        fi
        
        python3 << PYEOF
import json

config_file = "$CONFIG_FILE"
bot_name = "$BOT_NAME"
app_id = "$APP_ID"
app_secret = "$APP_SECRET"
group_policy = "$GROUP_POLICY"

with open(config_file, 'r') as f:
    config = json.load(f)

if 'channels' not in config:
    config['channels'] = {}

if 'feishu' not in config['channels']:
    config['channels']['feishu'] = {
        "enabled": True,
        "dmPolicy": "open",
        "groupPolicy": "open" if group_policy in ['Y', 'y', ''] else "allowlist",
        "accounts": {}
    }

config['channels']['feishu']['accounts'][bot_name] = {
    "name": bot_name,
    "appId": app_id,
    "appSecret": app_secret,
    "groupPolicy": "open" if group_policy in ['Y', 'y', ''] else "allowlist"
}

if 'bindings' not in config:
    config['bindings'] = []

# 添加绑定
binding_exists = any(
    b.get('agentId') == bot_name and 
    b.get('match', {}).get('channel') == 'feishu'
    for b in config['bindings']
)
if not binding_exists:
    config['bindings'].append({
        "agentId": bot_name,
        "match": {"channel": "feishu", "accountId": bot_name}
    })

with open(config_file, 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)

print(f"  ✓ 飞书机器人 '{bot_name}' 已添加")
PYEOF
        ;;
        
    2)
        echo ""
        echo -e "${CYAN}🎮 添加 Discord 机器人${NC}"
        echo ""
        echo "创建 Discord 机器人步骤："
        echo "  1. 访问 https://discord.com/developers/applications"
        echo "  2. 点击「New Application」"
        echo "  3. 填写应用名称（如「AI 朝廷 - 司礼监」）"
        echo "  4. 在「Bot」中创建机器人"
        echo "  5. 开启以下权限："
        echo "     - Message Content Intent"
        echo "     - Server Members Intent"
        echo "  6. 复制 Bot Token"
        echo "  7. 在「OAuth2」→「URL Generator」中："
        echo "     - 选择 scopes: bot, applications.commands"
        echo "     - 选择权限：Administrator（或按需选择）"
        echo "     - 复制生成的 URL，在浏览器中打开并添加到服务器"
        echo ""
        read -p "机器人名称（如 司礼监）: " BOT_NAME
        read -p "Bot Token: " BOT_TOKEN
        read -p "Guild ID（可选，留空则所有服务器生效）: " GUILD_ID
        
        if [ -z "$BOT_TOKEN" ]; then
            echo -e "${RED}✗ Bot Token 不能为空${NC}"
            exit 1
        fi
        
        python3 << PYEOF
import json

config_file = "$CONFIG_FILE"
bot_name = "$BOT_NAME"
bot_token = "$BOT_TOKEN"
guild_id = "$GUILD_ID"

with open(config_file, 'r') as f:
    config = json.load(f)

if 'channels' not in config:
    config['channels'] = {}

if 'discord' not in config['channels']:
    config['channels']['discord'] = {
        "enabled": True,
        "groupPolicy": "open",
        "allowBots": True,
        "accounts": {}
    }

config['channels']['discord']['accounts'][bot_name] = {
    "name": bot_name,
    "token": bot_token,
    "groupPolicy": "open"
}

if guild_id:
    if 'guilds' not in config['channels']['discord']:
        config['channels']['discord']['guilds'] = {}
    config['channels']['discord']['guilds'][guild_id] = {
        "requireMention": True
    }

if 'bindings' not in config:
    config['bindings'] = []

# 添加绑定
binding_exists = any(
    b.get('agentId') == bot_name and 
    b.get('match', {}).get('channel') == 'discord'
    for b in config['bindings']
)
if not binding_exists:
    config['bindings'].append({
        "agentId": bot_name,
        "match": {"channel": "discord", "accountId": bot_name}
    })

with open(config_file, 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)

print(f"  ✓ Discord 机器人 '{bot_name}' 已添加")
PYEOF
        ;;
        
    3)
        echo ""
        echo -e "${CYAN}🗑️ 移除平台账户${NC}"
        echo ""
        echo "  平台选择:"
        echo "    1) 飞书"
        echo "    2) Discord"
        read -p "请选择平台 [1/2]: " PLATFORM_SELECT
        
        if [ "$PLATFORM_SELECT" = "1" ]; then
            PLATFORM_KEY="feishu"
        elif [ "$PLATFORM_SELECT" = "2" ]; then
            PLATFORM_KEY="discord"
        else
            echo "无效选择"
            exit 1
        fi
        
        python3 << PYEOF
import json

config_file = "$CONFIG_FILE"
platform = "$PLATFORM_KEY"

with open(config_file, 'r') as f:
    config = json.load(f)

if platform in config.get('channels', {}):
    accounts = config['channels'][platform].get('accounts', {})
    if accounts:
        print(f"  {platform} 账户列表:")
        for i, acc in enumerate(accounts.keys(), 1):
            print(f"    {i}. {acc}")
        print()
        
        try:
            choice = int(input("  输入要移除的账户编号："))
            if 1 <= choice <= len(accounts):
                acc_name = list(accounts.keys())[choice - 1]
                del config['channels'][platform]['accounts'][acc_name]
                
                # 移除对应的绑定
                config['bindings'] = [
                    b for b in config.get('bindings', [])
                    if not (b.get('agentId') == acc_name and b.get('match', {}).get('channel') == platform)
                ]
                
                with open(config_file, 'w') as f:
                    json.dump(config, f, indent=2, ensure_ascii=False)
                print(f"  ✓ 账户 '{acc_name}' 已移除")
            else:
                print("  ✗ 无效编号")
        except ValueError:
            print("  ✗ 请输入数字")
    else:
        print(f"  {platform} 无账户")
else:
    print(f"  {platform} 未配置")
PYEOF
        ;;
        
    4)
        echo ""
        echo -e "${CYAN}📋 平台配置详情${NC}"
        echo ""
        python3 << 'PYEOF'
import json

with open("$CONFIG_FILE", 'r') as f:
    config = json.load(f)

channels = config.get('channels', {})
for name, data in channels.items():
    if name in ['feishu', 'discord']:
        print(f"  {name}:")
        print(f"    启用：{data.get('enabled', False)}")
        print(f"    DM 策略：{data.get('dmPolicy', 'unknown')}")
        print(f"    群聊策略：{data.get('groupPolicy', 'unknown')}")
        accounts = data.get('accounts', {})
        print(f"    账户数：{len(accounts)}")
        for acc_name, acc_data in accounts.items():
            print(f"      - {acc_name}")
        print()
PYEOF
        ;;
        
    5)
        echo "退出"
        exit 0
        ;;
        
    *)
        echo "无效选择"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✓ 配置已更新${NC}"
echo ""
echo "下一步："
echo "  1. 重启 Gateway: openclaw gateway restart"
echo "  2. 验证机器人是否正常工作"
