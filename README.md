# DYYYLoginBypass

抖音绕过登录插件（独立版），基于 DYYY 项目的绕登录功能独立提取。

## 功能特性

- **绕过登录限制**：未登录状态下可正常浏览抖音内容
- **设备指纹屏蔽**：禁用 GF 和 Dtrait 设备指纹采集
- **Bundle ID 伪装**：自动替换网络请求中的 Bundle ID，防止服务端识别
- **双指长按设置**：在抖音主界面双指长按 0.8 秒打开设置面板，手动控制开关
- **自动状态管理**：登录成功后自动关闭绕过，退出登录后自动重新开启
- **分身包支持**：支持抖音数字分身包（Aweme3760、Aweme3800 等）

## 系统要求

- iOS 14.0+
- 需要越狱
- 支持 rootless / rootful / roothide 三种越狱方案

## 安装方法

### 从 GitHub Actions 下载

1. 进入项目的 Actions 页面
2. 选择最新的 workflow run
3. 下载 Artifacts 中的 `.deb` 文件
4. 安装到设备

### 本地编译

```bash
# 安装 Theos
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"

# 编译
make package

# 安装到设备
make install
```

## 使用方法

1. 安装插件后重启抖音
2. 在抖音主界面**双指长按 0.8 秒**打开设置面板
3. 通过开关控制是否启用绕过登录功能
4. 登录成功后插件会自动关闭绕过

## 项目结构

```
DYYYLoginBypass/
├── Makefile                          # 编译配置
├── control                           # 包信息
├── DYYYLoginBypass.plist             # 过滤器配置
├── DYYYLoginBypass.xm                # 主入口文件
├── Sources/
│   ├── Core/
│   │   ├── DYYYLoginBypassConstants.h
│   │   ├── DYYYLoginBypassUtils.h
│   │   └── DYYYLoginBypassUtils.m
│   ├── Features/
│   │   ├── DYYYLoginBypassManager.h
│   │   ├── DYYYLoginBypassManager.m
│   │   ├── DYYYLoginRepairHooks.h
│   │   └── DYYYLoginRepairHooks.m
│   └── UI/
│       ├── DYYYBypassSettingsPanel.h
│       └── DYYYBypassSettingsPanel.m
├── .github/workflows/
│   └── build.yml                     # GitHub Actions 编译配置
└── README.md
```

## 致谢

本项目的核心逻辑提取自 [DYYY](https://github.com/xiaoye-debug/DYYY)，感谢原作者及所有贡献者。

## 许可证

MIT License
