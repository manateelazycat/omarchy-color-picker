# Omarchy Color Picker

[Omarchy Color Picker 演示视频](preview.mp4)

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

在 Arch Linux 上可以使用以下命令安装缺失依赖：

```bash
sudo pacman -S hyprpicker wl-clipboard
```

## 本地安装

代码固定保存在 `/home/andy/omarchy-color-picker`。把源码目录链接到 Omarchy 用户插件目录，然后启用到顶栏右侧：

```bash
ln -s /home/andy/omarchy-color-picker \
  ~/.config/omarchy/plugins/io.github.manateelazycat.color-picker
omarchy-shell shell rescanPlugins
omarchy plugin enable io.github.manateelazycat.color-picker right
```

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
