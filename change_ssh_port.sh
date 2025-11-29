#!/bin/bash

# SSH端口自动修改脚本 - 适用于Debian/Ubuntu
# 使用方法: sudo bash change_ssh_port.sh

set -e

# 配置部分
NEW_PORT=2233
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_FILE="${SSHD_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}错误: 此脚本需要root权限运行${NC}"
   echo "请使用: sudo bash $0"
   exit 1
fi

echo -e "${GREEN}=== SSH端口修改脚本 ===${NC}"
echo -e "${YELLOW}新端口: ${NEW_PORT}${NC}"
echo ""

# 备份原配置文件
echo -e "${GREEN}[1/5]${NC} 备份SSH配置文件..."
cp "$SSHD_CONFIG" "$BACKUP_FILE"
echo -e "      备份已保存至: $BACKUP_FILE"

# 检查当前端口
CURRENT_PORT=$(grep "^Port " "$SSHD_CONFIG" | awk '{print $2}')
if [ -z "$CURRENT_PORT" ]; then
    CURRENT_PORT=22
    echo -e "      当前使用默认端口: ${CURRENT_PORT}"
else
    echo -e "      当前端口: ${CURRENT_PORT}"
fi

# 修改端口
echo -e "${GREEN}[2/5]${NC} 修改SSH端口为 ${NEW_PORT}..."
if grep -q "^Port " "$SSHD_CONFIG"; then
    # 如果存在Port行,则替换
    sed -i "s/^Port .*/Port ${NEW_PORT}/" "$SSHD_CONFIG"
else
    # 如果不存在,则添加
    sed -i "/^#Port 22/a Port ${NEW_PORT}" "$SSHD_CONFIG"
fi

# 取消Port 22的注释(如果存在),防止冲突
sed -i "s/^#Port 22/#Port 22/" "$SSHD_CONFIG"

# 测试配置文件
echo -e "${GREEN}[3/5]${NC} 测试SSH配置文件..."
if sshd -t; then
    echo -e "      ${GREEN}✓${NC} 配置文件语法正确"
else
    echo -e "${RED}✗ 配置文件语法错误,正在恢复备份...${NC}"
    cp "$BACKUP_FILE" "$SSHD_CONFIG"
    exit 1
fi

# 配置防火墙(如果存在)
echo -e "${GREEN}[4/5]${NC} 配置防火墙规则..."
if command -v ufw &> /dev/null; then
    echo -e "      检测到UFW防火墙"
    ufw allow ${NEW_PORT}/tcp comment 'SSH' 2>/dev/null || true
    echo -e "      ${GREEN}✓${NC} UFW规则已添加"
elif command -v firewall-cmd &> /dev/null; then
    echo -e "      检测到firewalld防火墙"
    firewall-cmd --permanent --add-port=${NEW_PORT}/tcp 2>/dev/null || true
    firewall-cmd --reload 2>/dev/null || true
    echo -e "      ${GREEN}✓${NC} firewalld规则已添加"
else
    echo -e "      ${YELLOW}⚠${NC} 未检测到UFW或firewalld,请手动配置防火墙"
fi

# 重启SSH服务
echo -e "${GREEN}[5/5]${NC} 重启SSH服务..."
systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null

# 验证服务状态
if systemctl is-active --quiet ssh || systemctl is-active --quiet sshd; then
    echo -e "      ${GREEN}✓${NC} SSH服务已成功重启"
else
    echo -e "${RED}✗ SSH服务重启失败,正在恢复备份...${NC}"
    cp "$BACKUP_FILE" "$SSHD_CONFIG"
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
    exit 1
fi

echo ""
echo -e "${GREEN}=== 修改完成 ===${NC}"
echo -e "${YELLOW}重要提示:${NC}"
echo -e "1. SSH端口已改为: ${GREEN}${NEW_PORT}${NC}"
echo -e "2. ${RED}请不要关闭当前SSH连接!${NC}"
echo -e "3. 请打开新终端测试连接: ${GREEN}ssh -p ${NEW_PORT} user@your_server${NC}"
echo -e "4. 确认新端口可用后再关闭当前连接"
echo -e "5. 配置备份位置: ${BACKUP_FILE}"
echo ""
echo -e "如需恢复原配置,执行: sudo cp ${BACKUP_FILE} ${SSHD_CONFIG} && sudo systemctl restart ssh"
