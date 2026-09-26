# Omarchy Color Picker

简体中文 | [English](README.md)

https://github.com/user-attachments/assets/1ee22eef-4369-42eb-83d6-507146b6a505

一个 Omarchy 4 顶栏取色插件。点击取色器图标后，光标会变成圆形像素放大镜；点击任意像素即可退出取色模式，并把颜色复制到系统剪贴板。

## 功能

- 默认显示在 Omarchy 顶栏右侧
- 8 倍圆形像素放大镜，精确标示中心取样像素
- 左键开始取色，点击像素完成，`Esc` 取消
- 右键选择并持久保存剪贴板格式
- 支持 `HEX`、`RGB` 和 `HSL`

复制结果示例：

```text
#1E90FF
rgb(30, 144, 255)
hsl(210, 100%, 56%)
```

## 依赖

- Omarchy 4（Quattro）及其 Quickshell 插件系统
- `hyprpicker`
- `wl-clipboard`（提供 `wl-copy`）

## 安装

使用 Omarchy 插件管理器从 GitHub 安装并启用：

```bash
omarchy plugin add https://github.com/manateelazycat/omarchy-color-picker.git --enable --yes
```

插件默认显示在顶栏右侧。

## 使用

- 左键点击顶栏取色器图标开始取色。
- 移动鼠标，通过圆形放大镜选择中心像素。
- 点击复制颜色，或按 `Esc` 取消。
- 右键点击顶栏图标，在菜单中切换 `HEX`、`RGB` 或 `HSL`。

## 验证

```bash
omarchy plugin validate .
./tests/color-pickerctl-test.sh
```

## 卸载

```bash
omarchy plugin remove io.github.manateelazycat.color-picker --yes
```

卸载插件不会删除 `hyprpicker` 或 `wl-clipboard`。

## 许可证

本项目依据 [GNU General Public License v3.0](LICENSE) 发布，SPDX 标识为 `GPL-3.0-only`。
