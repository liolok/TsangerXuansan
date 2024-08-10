local G = GLOBAL

local fonts = { -- 加入了中文字体的原版字体列表
  'belisaplumilla_outline',
  'bellefair_outline',
  'bellefair',
  'hammerhead',
  'hennypenny_outline', -- 沃姆伍德：中文部分使用仓耳青丘小九
  'spirequal_outline',
  'spirequal',
  'stint_outline',
  'sugarplum_outline', -- 寄居蟹隐士：中文部分使用仓耳瓜藤体
  'belisaplumilla_outline', -- 防止寄居蟹字体和常用字体错乱
}

-- stylua: ignore
local replace = { -- 替换列表，参考原版的 fonts.lua
  DEFAULTFONT           = 'stint_outline', -- opensans
  TITLEFONT             = 'belisaplumilla_outline', -- bp100
  UIFONT                = 'belisaplumilla_outline', -- bp50
  BUTTONFONT            = 'bellefair', -- buttonfont
  NEWFONT               = 'spirequal',
  NEWFONT_SMALL         = 'spirequal', -- spirequal_small
  NEWFONT_OUTLINE       = 'spirequal_outline',
  NEWFONT_OUTLINE_SMALL = 'spirequal_outline', -- spirequal_outline_small
  NUMBERFONT            = 'stint_outline', -- stint-ucr
  TALKINGFONT           = 'belisaplumilla_outline', -- talkingfont
  TALKINGFONT_WORMWOOD  = 'hennypenny_outline', -- talkingfont_wormwood
  TALKINGFONT_TRADEIN   = 'belisaplumilla_outline', -- talkingfont_tradein
  TALKINGFONT_HERMIT    = 'sugarplum_outline', -- talkingfont_hermit
  CHATFONT              = 'bellefair',
  HEADERFONT            = 'hammerhead',
  CHATFONT_OUTLINE      = 'bellefair_outline',
  SMALLNUMBERFONT       = 'stint_outline', -- stint-small
  BODYTEXTFONT          = 'stint_outline', -- stint-ucr
}

Assets = {} -- 资源列表
for _, font in ipairs(fonts) do
  local file_path = MODROOT .. 'fonts/' .. font .. '.zip'
  local fb = font:find('_outline$') and G.DEFAULT_FALLBACK_TABLE_OUTLINE or G.DEFAULT_FALLBACK_TABLE
  table.insert(Assets, Asset('FONT', file_path))
  table.insert(G.FONTS, { filename = file_path, alias = 'tsanger_' .. font, fallback = fb })
end

local function ApplyFonts() -- 应用字体
  for _, font in ipairs(fonts) do
    G.TheSim:UnloadFont('tsanger_' .. font)
  end
  G.TheSim:UnregisterPrefabs({ 'tsanger_fonts' })
  G.TheSim:RegisterPrefab('tsanger_fonts', Assets, {})
  G.TheSim:LoadPrefabs({ 'tsanger_fonts' })
  for _, font in ipairs(fonts) do
    G.TheSim:LoadFont(MODROOT .. 'fonts/' .. font .. '.zip', 'tsanger_' .. font)
    local fallback = font:find('outline') and G.DEFAULT_FALLBACK_TABLE_OUTLINE or G.DEFAULT_FALLBACK_TABLE
    G.TheSim:SetupFontFallbacks('tsanger_' .. font, fallback)
  end
  for FONT, font in pairs(replace) do
    G[FONT] = 'tsanger_' .. font
  end
end

-- 注入字体
local OldUnregisterAllPrefabs = G.Sim.UnregisterAllPrefabs
G.Sim.UnregisterAllPrefabs = function(...)
  OldUnregisterAllPrefabs(...)
  ApplyFonts()
end
local OldRegisterPrefabs = G.ModManager.RegisterPrefabs
G.ModManager.RegisterPrefabs = function(...)
  OldRegisterPrefabs(...)
  ApplyFonts()
end
local OldStart = G.Start
G.Start = function()
  ApplyFonts()
  OldStart()
end

-- 缩放倍率
local ratio = GetModConfigData('font_scale_ratio')
G.LOC.GetTextScale = function() -- 仅对客户端语言为简体中文的情况调整缩放
  return (G.LOC.GetLocaleCode() == 'zh') and ratio or G.LOC.CurrentLocale and G.LOC.CurrentLocale.scale or 1.0
end

-- 调整字号
AddClassPostConstruct('widgets/controls', function(self)
  if self.seasonclock and self.seasonclock._text then self.seasonclock._text:SetSize(34 / ratio) end
end)
AddClassPostConstruct('widgets/ingredientui', function(self)
  if self.quant then self.quant:SetSize(32 / ratio) end
end)
AddClassPostConstruct('widgets/skincollector', function(self)
  if self.text then self.text:SetSize(26 / ratio) end
end)
AddClassPostConstruct('widgets/uiclock', function(self)
  if self._text then self._text:SetSize(GetModConfigData('world_clock_size') / ratio) end
  if self._moonanim and self._moonanim.moontext then self._moonanim.moontext:SetSize(18 / ratio) end
end)

-- 补全覆盖
AddClassPostConstruct('widgets/redux/craftingmenu_skinselector', function(self)
  if self.spinner and self.spinner.text then self.spinner.text:SetFont(G.BODYTEXTFONT) end
end)
AddClassPostConstruct('widgets/redux/serversettingstab', function(self) -- 创建世界 > 设置标签页
  for _, buttonwidget in ipairs(self.privacy_type.buttons.buttonwidgets) do
    buttonwidget.button:SetFont(G.NEWFONT)
  end
end)
AddClassPostConstruct('screens/imagepopupdialog', function(self) -- 只有交易小店的警告在用这个弹窗
  self.title:SetFont(G.TITLEFONT)
  self.title:SetColour(G.unpack(G.WHITE))
  self.text:SetFont(G.BODYTEXTFONT)
  self.text:SetSize(26 / ratio)
  self.text:SetColour(G.unpack(G.WHITE))
end)

-- 加载字符串换行修复文件
LoadPOFile(MODROOT .. 'chinese_s_patch.po', 'zh')
