# 服务器管理脚本集合

## SSH端口修改脚本

适用于Debian/Ubuntu

快速修改SSH端口为2233

### 使用方法
```bash
bash <(curl -Ls https://raw.githubusercontent.com/Null404-0/scripts/main/change_ssh_port.sh)
```

### 功能特性

- ✅ 自动备份配置文件
- ✅ 配置文件语法检查
- ✅ 自动配置防火墙规则
- ✅ 错误自动回滚
- ✅ 彩色输出提示

### 注意事项

⚠️ 修改后请勿立即关闭当前SSH连接，先用新端口测试连接成功后再关闭

## 许可证

MIT License
