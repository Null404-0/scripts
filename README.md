# 服务器管理脚本集合

一些实用的Linux服务器管理脚本，主要用于Debian/Ubuntu系统。

## 📋 脚本列表

### 1. SSH端口修改脚本 (change_ssh_port.sh)

**功能描述**: 交互式修改SSH服务端口，自动备份配置、验证端口可用性、配置防火墙。

**主要特性**:
- ✅ 交互式端口选择，提供智能建议
- ✅ 自动检测端口冲突和占用
- ✅ 警告系统保留端口和常见服务端口
- ✅ 二次确认机制，防止误操作
- ✅ 自动备份配置文件
- ✅ 配置文件语法检查
- ✅ 自动配置防火墙规则（支持UFW和firewalld）
- ✅ 错误自动回滚
- ✅ 彩色界面输出

---

## 🚀 使用方法

### 方法1: 直接在线执行（推荐）

```bash
bash <(curl -Ls https://raw.githubusercontent.com/Null404-0/scripts/main/change_ssh_port.sh)
```

或使用 wget:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/Null404-0/scripts/main/change_ssh_port.sh)
```

### 方法2: 下载后执行

```bash
# 下载脚本
curl -O https://raw.githubusercontent.com/Null404-0/scripts/main/change_ssh_port.sh

# 添加执行权限
chmod +x change_ssh_port.sh

# 运行脚本
sudo bash change_ssh_port.sh
```

---

## 📖 使用示例

### SSH端口修改流程

```bash
# 1. 执行脚本
sudo bash change_ssh_port.sh

# 2. 脚本会显示当前端口和推荐端口范围
当前SSH端口: 22

推荐端口范围:
  • 10000-20000  - 常用自定义范围
  • 20000-30000  - 高端口范围
  • 30000-65535  - 安全高端口

# 3. 输入你想要的端口号
请输入新的SSH端口号 [建议: 10000-65535]: 22333

# 4. 确认修改
确认要修改SSH端口吗? [yes/no]: yes

# 5. 等待完成
[1/5] 备份SSH配置文件...
[2/5] 修改SSH端口为 22333...
[3/5] 测试SSH配置文件...
[4/5] 配置防火墙规则...
[5/5] 重启SSH服务...

# 6. 修改完成，按提示测试新端口
ssh -p 22333 user@your_server
```

---

## ⚠️ 重要提醒

### 修改SSH端口前必读

1. **不要关闭当前连接**: 修改完成后，先用新端口测试连接成功，再关闭旧连接
2. **云服务器安全组**: 如果使用阿里云/腾讯云/AWS等，需要在控制台的安全组中开放新端口
3. **防火墙配置**: 确保防火墙允许新端口的TCP连接
4. **备份配置**: 脚本会自动备份，但建议手动再备份一次

### 端口选择建议

**✅ 推荐端口**:
- `22333` - 好记且不易冲突
- `23456` - 连续数字好记
- `12345` - 简单好记
- `10022` - 在10000基础上加22

**❌ 避免端口**:
- `1-1023` - 系统保留端口
- `80, 443` - HTTP/HTTPS服务
- `3306` - MySQL数据库
- `6379` - Redis
- `8080, 8888` - 常见Web服务

---

## 🔧 常见问题

### Q1: 修改后无法连接怎么办？

**A**: 通过云服务器控制台的VNC/远程连接功能登录，恢复备份：

```bash
# 查找备份文件
ls -lt /etc/ssh/sshd_config.backup.*

# 恢复备份
sudo cp /etc/ssh/sshd_config.backup.XXXXXXXX /etc/ssh/sshd_config

# 重启SSH
sudo systemctl restart ssh
```

### Q2: 提示端口被占用怎么办？

**A**: 更换其他端口，或查看占用情况：

```bash
# 查看端口占用
sudo ss -tuln | grep :端口号

# 查看占用进程
sudo lsof -i :端口号
```

### Q3: 防火墙规则未生效？

**A**: 手动添加防火墙规则：

```bash
# UFW防火墙
sudo ufw allow 22333/tcp

# firewalld防火墙
sudo firewall-cmd --permanent --add-port=22333/tcp
sudo firewall-cmd --reload

# iptables防火墙
sudo iptables -A INPUT -p tcp --dport 22333 -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4
```

### Q4: 云服务器安全组如何配置？

**A**: 
- **阿里云**: 控制台 → 云服务器ECS → 安全组 → 配置规则 → 添加入方向规则
- **腾讯云**: 控制台 → 云服务器 → 安全组 → 添加规则
- **AWS**: EC2 → Security Groups → Inbound Rules → Add Rule

规则配置：
- 类型: 自定义TCP
- 端口: 你的新端口号
- 来源: 0.0.0.0/0（所有IP）或指定IP

---

## 🛡️ 安全建议

1. **使用密钥登录**: 禁用密码登录，只允许SSH密钥
2. **限制登录IP**: 如果有固定IP，在防火墙中限制只允许特定IP连接
3. **安装fail2ban**: 防止暴力破解
4. **定期更新系统**: 及时修补安全漏洞
5. **使用高端口**: 推荐使用10000以上的端口

---

## 📝 更新日志

### v2.0 (2024-11-30)
- ✨ 新增交互式端口选择功能
- ✨ 新增端口冲突检测
- ✨ 新增常见服务端口警告
- ✨ 新增二次确认机制
- ✨ 优化界面显示，增加彩色输出
- ✨ 优化结果展示，提供详细的后续操作指南

### v1.0 (2024-11-29)
- 🎉 初始版本发布
- ✅ 基础的SSH端口修改功能

---

## 📄 许可证

MIT License - 自由使用、修改和分发

---

## 🤝 贡献

欢迎提交Issue和Pull Request！

---

## 📮 联系方式

如有问题，请在GitHub Issues中提出。

---

## ⭐ 支持

如果这个脚本对你有帮助，请给个Star ⭐️

1-1023 - 系统保留端口
80, 443 - HTTP/HTTPS服务
3306 - MySQL数据库
6379 - Redis
8080, 8888 - 常见Web服务


🔧 常见问题
Q1: 修改后无法连接怎么办？
A: 通过云服务器控制台的VNC/远程连接功能登录，恢复备份：
bash# 查找备份文件
ls -lt /etc/ssh/sshd_config.backup.*

# 恢复备份
sudo cp /etc/ssh/sshd_config.backup.XXXXXXXX /etc/ssh/sshd_config

# 重启SSH
sudo systemctl restart ssh
Q2: 提示端口被占用怎么办？
A: 更换其他端口，或查看占用情况：
bash# 查看端口占用
sudo ss -tuln | grep :端口号

# 查看占用进程
sudo lsof -i :端口号
Q3: 防火墙规则未生效？
A: 手动添加防火墙规则：
bash# UFW防火墙
sudo ufw allow 22333/tcp

# firewalld防火墙
sudo firewall-cmd --permanent --add-port=22333/tcp
sudo firewall-cmd --reload

# iptables防火墙
sudo iptables -A INPUT -p tcp --dport 22333 -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4
Q4: 云服务器安全组如何配置？
A:

阿里云: 控制台 → 云服务器ECS → 安全组 → 配置规则 → 添加入方向规则
腾讯云: 控制台 → 云服务器 → 安全组 → 添加规则
AWS: EC2 → Security Groups → Inbound Rules → Add Rule

规则配置：

类型: 自定义TCP
端口: 你的新端口号
来源: 0.0.0.0/0（所有IP）或指定IP


🛡️ 安全建议

使用密钥登录: 禁用密码登录，只允许SSH密钥
限制登录IP: 如果有固定IP，在防火墙中限制只允许特定IP连接
安装fail2ban: 防止暴力破解
定期更新系统: 及时修补安全漏洞
使用高端口: 推荐使用10000以上的端口


📝 更新日志
v2.0 (2024-11-30)

✨ 新增交互式端口选择功能
✨ 新增端口冲突检测
✨ 新增常见服务端口警告
✨ 新增二次确认机制
✨ 优化界面显示，增加彩色输出
✨ 优化结果展示，提供详细的后续操作指南

v1.0 (2024-11-29)

🎉 初始版本发布
✅ 基础的SSH端口修改功能


📄 许可证
MIT License - 自由使用、修改和分发

🤝 贡献
欢迎提交Issue和Pull Request！

📮 联系方式
如有问题，请在GitHub Issues中提出。

⭐ 支持
如果这个脚本对你有帮助，请给个Star ⭐️
