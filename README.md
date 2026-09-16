# 竹林试剑

单机 3D 横版武侠 ARPG 切片，面向 Windows，使用 Godot 4.7。

在青溪竹径上移动、跳跃、闪避与对刀。角色为水墨分件骨骼（斗笠、蒙面、披风），站立垂剑、行走提剑、奔跑拖刀、滑行贴地横剑、跳跃收剑的持剑姿势不同。

仓库：<https://github.com/luyushu-shu/zhujian-arpg>

## 运行

安装 [Godot 4.3+](https://godotengine.org/)（按 4.7 开发）：

```text
winget install GodotEngine.GodotEngine
```

1. Godot 项目管理器 → **导入** → 选择本仓库的 `project.godot`。
2. 按 **F5** 运行。
3. **先用鼠标点进游戏窗口**，再按键盘。若开着中文输入法，请切到英文。

不要在编辑器 3D 视口里按键，那不会控制角色。

导出 Windows：工程 → 导出 → Windows Desktop（需下载 export template）。

## 操作

| 输入 | 作用 |
| --- | --- |
| A / D 或 ← / → | 走路 |
| Shift 按住 | 奔跑 |
| Shift 点按 | 闪避（短无敌） |
| 空格 | 跳跃 |
| S | 蹲；奔跑中再按 S 为滑步 |
| 鼠标左键 | 地面三连斩；空中旋斩；空中 + S 下劈坠击 |
| 弹刀成功后左键 | 反击 |
| E 或蹲下左键 | 踢 |
| F 按住再松开 | 蓄力重斩 |
| 鼠标右键点按 | 弹刀 |
| 鼠标右键按住 | 格挡 |
| Tab | 显隐招式说明 |

气绝后场景重开。

## 内容

- **关卡**：夜间雾气、竹林、木栈、石台、试剑亭。
- **战斗**：连招窗口、弹刀硬直、格挡减伤、流血粒子、3D 飘字。
- **HUD**：安全区内气血条（数字 +「气 / 残 / 绝」）、地点、闪/滑冷却、蓄力条。

## 目录

```text
project.godot
scenes/main.tscn            3D 关卡入口
scenes/player_3d.tscn
scenes/enemy_3d.tscn
scenes/hud.tscn
scripts/player_3d.gd        移动与招式
scripts/enemy_3d.gd         追击与出刀
scripts/character_rig_3d.gd 水墨分件与动作
scripts/level_builder_3d.gd 场景生成
scripts/hud.gd
scripts/combat_text.gd
scripts/blood_spray_3d.gd
```

旧版 2D 脚本与场景已从仓库移除。

## 许可

个人练习项目。克隆与修改请自行遵守 Godot 引擎许可。
