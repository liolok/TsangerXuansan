name = '中文字体：仓耳玄三'
author = 'Skull, gcc, EvenMr, 幽晚枫乐, iaman2b & 李皓奇'
version = '2024.07.02.2'
description = [[
󰀏 制作目录皮肤名称字体替换方案：

(1) 在 Steam 库右键饥荒联机版 -> 管理 -> 浏览本地文件

(2) 编辑游戏内置字体压缩包 ./data/databundles/fonts.zip

(3) 在 Steam 库右键饥荒联机版 -> 管理 -> 浏览本地文件

(4) 模组目录 ../../workshop/content/322330/3264922393/

(5) 复制 fallback_full_outline_packed.zip 并替换掉游戏内置字体压缩包里的同名文件

(6) 重启游戏（游戏版本更新后，需要再次进行替换）
]]
api_version = 10
priority = -2022

icon_atlas = 'modicon.xml'
icon = 'modicon.tex'

dst_compatible = true
client_only_mod = true
all_clients_require_mod = false

configuration_options = {
  {
    name = 'font_scale_ratio',
    label = '缩放倍率',
    options = {
      { description = '0.80', data = 0.80 },
      { description = '0.85', data = 0.85 },
      { description = '0.90', data = 0.90 },
      { description = '0.95', data = 0.95 },
      { description = '1.00', data = 1.00 },
      { description = '1.05', data = 1.05 },
      { description = '1.10', data = 1.10 },
      { description = '1.15', data = 1.15 },
      { description = '1.20', data = 1.20 },
    },
    default = 1.00,
  },
  {
    name = 'world_clock_size',
    label = '世界时钟',
    hover = '世界天数、幸存天数的字号',
    options = {
      { description = '30', data = 30 },
      { description = '31', data = 31 },
      { description = '32', data = 32 },
      { description = '33', data = 33 },
      { description = '34', data = 34 },
      { description = '35', data = 35 },
      { description = '36', data = 36 },
      { description = '37', data = 37 },
      { description = '38', data = 38 },
      { description = '39', data = 39 },
      { description = '40', data = 40 },
      { description = '41', data = 41 },
      { description = '42', data = 42 },
      { description = '43', data = 43 },
      { description = '44', data = 44 },
      { description = '45', data = 45 },
    },
    default = 32,
  },
}
