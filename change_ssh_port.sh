#!/bin/bash

# SSH端口自动修改脚本 - 优化版
# 适用于Debian/Ubuntu
# 使用方法: sudo bash change_ssh_port.sh
# 作者: Null404-0
# 仓库: https://github.com/Null404-0/scripts

set -e

# 配置文件路径
SSHD_CONFIG="/etc/ssh/sshd_config"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 常见服务端口列表（需要警告）
COMMON_PORTS=(21 22 23 25 53 80 110 143 443 465 587 993 995 3306 3389 5432 6379 8080 8443 8888 9000)

# 清屏函数
clear_screen() {
    clear
}

# 打印标题
print_header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          SSH 端口修改工具 v2.0                              ║"
    echo "║          SSH Port Change Script                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}✗ 错误: 此脚本需要root权限运行${NC}"
        echo -e "${YELLOW}请使用: sudo bash $0${NC}"
        exit 1
    fi
}

# 获取当前SSH端口
get_current_port() {
    local port=$(grep "^Port " "$SSHD_CONFIG" 2>/dev/null | awk '{print $2}')
    if [ -z "$port" ]; then
        echo "22"
    else
        echo "$port"
    fi
}

# 检查端口是否被占用
check_port_in_use() {
    local port=$1
    if ss -tuln | grep -q ":${port} "; then
        return 0  # 端口被占用
    else
        return 1  # 端口未被占用
    fi
}

# 检查是否为常见服务端口
is_common_port() {
    local port=$1
    for common_port in "${COMMON_PORTS[@]}"; do
        if [ "$port" -eq "$common_port" ]; then
            return 0  # 是常见端口
        fi
    done
    return 1  # 不是常见端口
}

# 验证端口号
validate_port() {
    local port=$1
    
    # 检查是否为数字
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}✗ 错误: 端口必须是数字${NC}"
        return 1
    fi
    
    # 检查端口范围
    if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo -e "${RED}✗ 错误: 端口范围必须在 1-65535 之间${NC}"
        return 1
    fi
    
    # 警告系统保留端口
    if [ "$port" -lt 1024 ]; then
        echo -e "${YELLOW}⚠ 警告: 端口 $port 是系统保留端口 (1-1023)${NC}"
        echo -e "${YELLOW}   建议使用 10000-65535 范围的端口${NC}"
    fi
    
    # 检查是否为常见服务端口
    if is_common_port "$port"; then
        echo -e "${YELLOW}⚠ 警告: 端口 $port 是常见服务端口，可能会冲突${NC}"
        echo -e "${YELLOW}   常见端口: 80(HTTP), 443(HTTPS), 3306(MySQL), 6379(Redis)等${NC}"
    fi
    
    # 检查端口是否已被占用
    if check_port_in_use "$port"; then
        echo -e "${RED}✗ 错误: 端口 $port 已被其他服务占用${NC}"
        echo -e "${YELLOW}提示: 使用 'ss -tuln | grep :$port' 查看占用情况${NC}"
        return 1
    fi
    
    return 0
}

# 获取用户输入的端口
get_user_port() {
    local current_port=$(get_current_port)
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}当前SSH端口:${NC} ${YELLOW}$current_port${NC}"
    echo ""
    echo -e "${CYAN}推荐端口范围:${NC}"
    echo -e "  • ${GREEN}10000-20000${NC}  - 常用自定义范围"
    echo -e "  • ${GREEN}20000-30000${NC}  - 高端口范围"
    echo -e "  • ${GREEN}30000-65535${NC}  - 安全高端口"
    echo ""
    echo -e "${CYAN}端口建议:${NC}"
    echo -e "  ✓ 避免使用 ${RED}1-1023${NC} (系统保留)"
    echo -e "  ✓ 避免使用 ${RED}80, 443, 3306, 8080${NC} 等常见端口"
    echo -e "  ✓ 推荐使用 ${GREEN}5位数端口${NC}，如: 12345, 23456, 33333"
    echo -e "  ✓ 使用好记的数字，如: 22333, 22888, 23333"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    while true; do
        read -p "$(echo -e ${GREEN}请输入新的SSH端口号${NC} [建议: 10000-65535]: )" NEW_PORT
        
        # 如果用户直接回车，给出提示
        if [ -z "$NEW_PORT" ]; then
            echo -e "${YELLOW}⚠ 端口不能为空，请重新输入${NC}"
            continue
        fi
        
        # 验证端口
        if validate_port "$NEW_PORT"; then
            break
        fi
        echo ""
    done
}

# 确认修改
confirm_change() {
    local current_port=$(get_current_port)
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}修改确认:${NC}"
    echo -e "  当前端口: ${RED}$current_port${NC}"
    echo -e "  新端口:   ${GREEN}$NEW_PORT${NC}"
    echo ""
    echo -e "${YELLOW}注意事项:${NC}"
    echo -e "  • 修改后需要使用新端口连接: ${GREEN}ssh -p $NEW_PORT user@server${NC}"
    echo -e "  • 请确保防火墙/安全组已开放端口 ${GREEN}$NEW_PORT${NC}"
    echo -e "  • 修改前会自动备份配置文件"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    while true; do
        read -p "$(echo -e ${GREEN}确认要修改SSH端口吗? ${NC}[yes/no]: )" confirm
        case $confirm in
            [Yy]|[Yy][Ee][Ss])
                echo -e "${GREEN}✓ 开始修改...${NC}"
                return 0
                ;;
            [Nn]|[Nn][Oo])
                echo -e "${YELLOW}✗ 已取消修改${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}请输入 yes 或 no${NC}"
                ;;
        esac
    done
}

# 修改SSH端口
change_ssh_port() {
    local backup_file="${SSHD_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    
    echo ""
    echo -e "${CYAN}开始执行修改...${NC}"
    echo ""
    
    # 步骤1: 备份
    echo -e "${GREEN}[1/5]${NC} 备份SSH配置文件..."
    cp "$SSHD_CONFIG" "$backup_file"
    echo -e "      ${GREEN}✓${NC} 备份已保存: ${BLUE}$backup_file${NC}"
    
    # 步骤2: 修改端口
    echo -e "${GREEN}[2/5]${NC} 修改SSH端口为 ${YELLOW}$NEW_PORT${NC}..."
    if grep -q "^Port " "$SSHD_CONFIG"; then
        sed -i "s/^Port .*/Port ${NEW_PORT}/" "$SSHD_CONFIG"
    else
        sed -i "/^#Port 22/a Port ${NEW_PORT}" "$SSHD_CONFIG"
    fi
    sed -i "s/^#Port 22/#Port 22/" "$SSHD_CONFIG"
    echo -e "      ${GREEN}✓${NC} 配置已修改"
    
    # 步骤3: 测试配置
    echo -e "${GREEN}[3/5]${NC} 测试SSH配置文件..."
    if sshd -t 2>/dev/null; then
        echo -e "      ${GREEN}✓${NC} 配置文件语法正确"
    else
        echo -e "${RED}      ✗ 配置文件语法错误,正在恢复备份...${NC}"
        cp "$backup_file" "$SSHD_CONFIG"
        exit 1
    fi
    
    # 步骤4: 配置防火墙
    echo -e "${GREEN}[4/5]${NC} 配置防火墙规则..."
    if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
        echo -e "      检测到UFW防火墙"
        ufw allow ${NEW_PORT}/tcp comment 'SSH Custom Port' 2>/dev/null || true
        echo -e "      ${GREEN}✓${NC} UFW规则已添加"
    elif command -v firewall-cmd &> /dev/null; then
        echo -e "      检测到firewalld防火墙"
        firewall-cmd --permanent --add-port=${NEW_PORT}/tcp 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
        echo -e "      ${GREEN}✓${NC} firewalld规则已添加"
    else
        echo -e "      ${YELLOW}⚠${NC} 未检测到防火墙,请手动配置"
    fi
    
    # 步骤5: 重启服务
    echo -e "${GREEN}[5/5]${NC} 重启SSH服务..."
    if systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null; then
        echo -e "      ${GREEN}✓${NC} SSH服务已成功重启"
    else
        echo -e "${RED}      ✗ SSH服务重启失败${NC}"
        cp "$backup_file" "$SSHD_CONFIG"
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        exit 1
    fi
    
    # 验证服务状态
    sleep 1
    if systemctl is-active --quiet ssh || systemctl is-active --quiet sshd; then
        return 0
    else
        echo -e "${RED}✗ SSH服务未正常运行${NC}"
        return 1
    fi
}

# 打印最终结果
print_result() {
    local current_port=$(get_current_port)
    local backup_file=$(ls -t ${SSHD_CONFIG}.backup.* 2>/dev/null | head -1)
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    修改成功完成!                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}修改摘要:${NC}"
    echo -e "  ${GREEN}✓${NC} SSH端口已更改为: ${YELLOW}$NEW_PORT${NC}"
    echo -e "  ${GREEN}✓${NC} 配置文件已备份"
    echo -e "  ${GREEN}✓${NC} SSH服务运行正常"
    echo ""
    echo -e "${CYAN}下一步操作:${NC}"
    echo -e "${YELLOW}  ⚠ 重要: 请勿立即关闭当前SSH连接!${NC}"
    echo ""
    echo -e "  ${BLUE}1.${NC} 打开新终端,使用新端口测试连接:"
    echo -e "     ${GREEN}ssh -p $NEW_PORT $(whoami)@$(hostname -I | awk '{print $1}')${NC}"
    echo ""
    echo -e "  ${BLUE}2.${NC} 如果使用云服务器,需要在安全组/防火墙开放端口:"
    echo -e "     ${GREEN}端口: $NEW_PORT/TCP${NC}"
    echo ""
    echo -e "  ${BLUE}3.${NC} 确认新端口连接成功后,才关闭当前连接"
    echo ""
    echo -e "${CYAN}配置信息:${NC}"
    echo -e "  备份文件: ${BLUE}$backup_file${NC}"
    echo -e "  配置文件: ${BLUE}$SSHD_CONFIG${NC}"
    echo ""
    echo -e "${CYAN}回滚方法:${NC}"
    if [ -n "$backup_file" ]; then
        echo -e "  如需恢复原端口,执行:"
        echo -e "  ${YELLOW}sudo cp $backup_file $SSHD_CONFIG && sudo systemctl restart ssh${NC}"
    fi
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 主函数
main() {
    clear_screen
    print_header
    check_root
    get_user_port
    confirm_change
    change_ssh_port
    print_result
}

# 执行主函数
main
