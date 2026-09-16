# 竹林试剑

单机 2D 横版武侠 ARPG 切片。玩家在青溪竹径上走、跑、跳、闪、滑，用刀剑对招：三连斩、空斩、坠击、踢、蓄力重斩、弹刀与格挡。

角色是水墨剪影分件模型（斗笠、蒙面、披风），不是贴图立绘；场景由程序生成竹林、栈道与试剑亭。目标平台是 Windows，引擎为 Godot 4。

## 运行

需要 [Godot 4.3+](https://godotengine.org/)（当前按 4.7 开发）。也可用：

```text
winget install GodotEngine.GodotEngine
```

1. 打开 Godot 项目管理器 → **导入** → 选择本仓库的 `project.godot`。
2. 按 **F5** 运行。

导出 Windows：工程 → 导出 → Windows Desktop（需先下载对应 export template）。

## 操作

| 输入 | 作用 |
| --- | --- |
| A / D | 走路 |
| Shift 按住 | 奔跑（拖刀） |
| Shift 点按 | 闪避（短无敌） |
| 空格 | 跳跃 |
| S | 蹲；奔跑中再按 S 为滑步 |
| 鼠标左键 | 地面三连斩；空中旋斩；空中 + S 下劈坠击 |
| 弹刀成功后左键 | 反击 |
| E | 踢（蹲下左键同样踢） |
| F 按住再松开 | 蓄力重斩 |
| 鼠标右键点按 | 弹刀 |
| 鼠标右键按住 | 格挡 |
| Tab | 显隐招式说明 |

气绝后当前场景重开。站立垂剑、行走提剑、奔跑拖刀、滑行贴地横剑、跳跃收剑的持剑姿势不同。

## 内容概要

- **关卡**：视差远山、竹林、石径、木石平台、试剑亭。
- **战斗**：连招窗口、弹刀硬直、格挡减伤、受击流血粒子、伤害飘字。
- **HUD**：安全区内的气血条（数字 +「气/残/绝」）、地点、闪/滑冷却、蓄力条；招式说明默认数秒后收起。

## 目录

```text
project.godot
scenes/main.tscn          关卡入口
scenes/player.tscn
scenes/enemy.tscn
scenes/hud.tscn
scripts/player.gd         移动与招式
scripts/enemy.gd          追击、前摇、出刀
scripts/character_model.gd 水墨分件与动作
scripts/hud.gd            界面
scripts/combat_text.gd    飘字
scripts/blood_spray.gd    流血粒子
scripts/level_builder.gd  青溪竹径生成
scripts/scene_kit.gd      竹、石、灯笼等积木
```

## 许可

个人练习项目。欢迎克隆与改；若公开发布衍生内容，请自行处理引擎与素材许可。
