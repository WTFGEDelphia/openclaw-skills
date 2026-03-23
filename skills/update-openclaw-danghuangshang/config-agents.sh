#!/bin/bash
# AI 朝廷 Agent 配置工具 - 用于配置 Agent 与模型的映射关系

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
echo "🤖 AI 朝廷 Agent 配置工具"
echo "======================================"
echo ""

# 检查配置
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}✗ 未找到 OpenClaw 配置文件${NC}"
    exit 1
fi

# 获取可用模型列表
echo -e "${CYAN}📊 可用模型列表:${NC}"
python3 << 'PYEOF'
import json

with open("$CONFIG_FILE", 'r') as f:
    config = json.load(f)

models = {}
if 'models' in config and 'providers' in config['models']:
    for provider, data in config['models']['providers'].items():
        if 'models' in data:
            for m in data['models']:
                model_id = f"{provider}/{m['id']}"
                models[model_id] = m.get('name', m['id'])

if models:
    for i, (model_id, name) in enumerate(models.items(), 1):
        print(f"  {i}. {model_id} ({name})")
else:
    print("  未检测到可用模型")
PYEOF

echo ""

# 获取 AI 朝廷 Agent 列表
echo -e "${CYAN}🏛️ AI 朝廷 Agent 列表:${NC}"
python3 << 'PYEOF'
import json

with open("$CONFIG_FILE", 'r') as f:
    config = json.load(f)

agents = []
if 'agents' in config and 'list' in config['agents']:
    for agent in config['agents']['list']:
        agent_id = agent.get('id', '')
        if agent_id in ['silijian', 'neige', 'duchayuan', 'bingbu', 'hubu', 'libu', 'gongbu', 'libu2', 'xingbu']:
            current_model = agent.get('model', {}).get('primary', '未配置')
            agents.append((agent_id, current_model))

if agents:
    for agent_id, model in agents:
        print(f"  - {agent_id}: {model}")
else:
    print("  未检测到 AI 朝廷 Agent")
PYEOF

echo ""
echo -e "${CYAN}请选择操作:${NC}"
echo "  1) 批量配置 Agent 模型（推荐配置）"
echo "  2) 逐个配置 Agent 模型"
echo "  3) 重置为默认模型"
echo "  4) 查看配置详情"
echo "  5) 退出"
echo ""
read -p "请选择 [1-5]: " SELECT

case $SELECT in
    1)
        # 批量配置 - 推荐方案
        echo ""
        echo -e "${CYAN}🎯 推荐配置方案${NC}"
        echo ""
        echo "根据 Agent 职责，推荐以下模型配置："
        echo ""
        echo "  【强力模型】（适合复杂任务）"
        echo "    - silijian（司礼监）- 调度决策"
        echo "    - neige（内阁）- Prompt 优化"
        echo "    - duchayuan（都察院）- 代码审查"
        echo ""
        echo "  【快速模型】（适合执行任务）"
        echo "    - bingbu（兵部）- 编码开发"
        echo "    - gongbu（工部）- DevOps"
        echo ""
        echo "  【通用模型】（适合分析任务）"
        echo "    - hubu（户部）- 财务分析"
        echo "    - libu（礼部）- 品牌营销"
        echo "    - libu2（吏部）- 项目管理"
        echo "    - xingbu（刑部）- 法务合规"
        echo ""
        
        read -p "是否应用推荐配置？[Y/n]: " APPLY
        APPLY=${APPLY:-Y}
        
        if [ "$APPLY" = "Y" ] || [ "$APPLY" = "y" ]; then
            read -p "请输入强力模型 ID: " STRONG_MODEL
            read -p "请输入快速模型 ID: " FAST_MODEL
            read -p "请输入通用模型 ID: " GENERAL_MODEL
            
            python3 << PYEOF
import json

config_file = "$CONFIG_FILE"
strong_model = "$STRONG_MODEL"
fast_model = "$FAST_MODEL"
general_model = "$GENERAL_MODEL"

with open(config_file, 'r') as f:
    config = json.load(f)

# 配置映射
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

for agent in config['agents']['list']:
    agent_id = agent.get('id', '')
    if agent_id in model_mapping:
        agent['model'] = {'primary': model_mapping[agent_id]}
        print(f"  ✓ {agent_id} → {model_mapping[agent_id]}")

with open(config_file, 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)

print("\n✓ 配置已保存")
PYEOF
        fi
        ;;
        
    2)
        # 逐个配置
        echo ""
        echo -e "${CYAN}逐个配置 Agent 模型${NC}"
        echo ""
        
        python3 << 'PYEOF'
import json

config_file = "$CONFIG_FILE"

with open(config_file, 'r') as f:
    config = json.load(f)

ai_court_agents = ['silijian', 'neige', 'duchayuan', 'bingbu', 'hubu', 'libu', 'gongbu', 'libu2', 'xingbu']

for agent in config['agents']['list']:
    agent_id = agent.get('id', '')
    if agent_id in ai_court_agents:
        current_model = agent.get('model', {}).get('primary', '未配置')
        print(f"\nAgent: {agent_id}")
        print(f"  当前模型：{current_model}")
        new_model = input(f"  新模型 ID（回车保持不变）: ").strip()
        if new_model:
            agent['model'] = {'primary': new_model}
            print(f"  ✓ 已更新为：{new_model}")

with open(config_file, 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)

print("\n✓ 配置已保存")
PYEOF
        ;;
        
    3)
        # 重置为默认模型
        echo ""
        read -p "请输入默认模型 ID: " DEFAULT_MODEL
        
        python3 << PYEOF
import json

config_file = "$CONFIG_FILE"
default_model = "$DEFAULT_MODEL"

with open(config_file, 'r') as f:
    config = json.load(f)

ai_court_agents = ['silijian', 'neige', 'duchayuan', 'bingbu', 'hubu', 'libu', 'gongbu', 'libu2', 'xingbu']

for agent in config['agents']['list']:
    agent_id = agent.get('id', '')
    if agent_id in ai_court_agents:
        agent['model'] = {'primary': default_model}
        print(f"  ✓ {agent_id} → {default_model}")

with open(config_file, 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)

print("\n✓ 配置已保存")
PYEOF
        ;;
        
    4)
        # 查看配置详情
        echo ""
        echo -e "${CYAN}Agent 配置详情:${NC}"
        echo ""
        python3 << 'PYEOF'
import json

with open("$CONFIG_FILE", 'r') as f:
    config = json.load(f)

ai_court_agents = {
    'silijian': '司礼监 - 总管调度',
    'neige': '内阁 - Prompt 优化',
    'duchayuan': '都察院 - 代码审查',
    'bingbu': '兵部 - 编码开发',
    'hubu': '户部 - 财务分析',
    'libu': '礼部 - 品牌营销',
    'gongbu': '工部 - DevOps',
    'libu2': '吏部 - 项目管理',
    'xingbu': '刑部 - 法务合规'
}

for agent in config['agents']['list']:
    agent_id = agent.get('id', '')
    if agent_id in ai_court_agents:
        model = agent.get('model', {}).get('primary', '未配置')
        sandbox = agent.get('sandbox', {}).get('mode', '未配置')
        print(f"  {agent_id} ({ai_court_agents[agent_id]})")
        print(f"    模型：{model}")
        print(f"    沙箱：{sandbox}")
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
echo "  2. 验证 Agent 是否正常工作"
