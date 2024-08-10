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
}

Assets = {} -- 资源列表
local file_path = {} -- 文件路径列表
for _, font in ipairs(fonts) do
  file_path[font] = MODROOT .. 'fonts/' .. font .. '.zip'
  local fb = G.DEFAULT_FALLBACK_TABLE
  if font:find('outline') then fb = G.DEFAULT_FALLBACK_TABLE_OUTLINE end
  table.insert(Assets, Asset('FONT', file_path[font]))
  table.insert(G.FONTS, { filename = file_path[font], alias = 'tsanger_' .. font, fallback = fb })
end

local function RegisterFonts() -- 注册字体
  for _, font in ipairs(fonts) do
    G.TheSim:UnloadFont('tsanger_' .. font)
  end
  G.TheSim:UnloadPrefabs({ 'tsanger_fonts' })
  G.TheSim:RegisterPrefab('tsanger_fonts', Assets, {})
  G.TheSim:LoadPrefabs({ 'tsanger_fonts' })
  for _, font in ipairs(fonts) do
    G.TheSim:LoadFont(file_path[font], 'tsanger_' .. font)
  end
  G.DEFAULTFONT = 'tsanger_stint_outline' -- opensans
  G.TITLEFONT = 'tsanger_belisaplumilla_outline' -- bp100
  G.UIFONT = 'tsanger_belisaplumilla_outline' -- bp50
  G.BUTTONFONT = 'tsanger_bellefair' -- buttonfont
  G.NEWFONT = 'tsanger_spirequal'
  G.NEWFONT_SMALL = 'tsanger_spirequal' -- spirequal_small
  G.NEWFONT_OUTLINE = 'tsanger_spirequal_outline'
  G.NEWFONT_OUTLINE_SMALL = 'tsanger_spirequal_outline' -- spirequal_outline_small
  G.NUMBERFONT = 'tsanger_stint_outline' -- stint-ucr
  G.TALKINGFONT = 'tsanger_belisaplumilla_outline' -- talkingfont
  G.TALKINGFONT_WORMWOOD = 'tsanger_hennypenny_outline'
  G.TALKINGFONT_TRADEIN = 'tsanger_belisaplumilla_outline'
  G.TALKINGFONT_HERMIT = 'tsanger_sugarplum_outline'
  G.CHATFONT = 'tsanger_bellefair'
  G.HEADERFONT = 'tsanger_hammerhead'
  G.CHATFONT_OUTLINE = 'tsanger_bellefair_outline'
  G.SMALLNUMBERFONT = 'tsanger_stint_outline' -- stint-small
  G.BODYTEXTFONT = 'tsanger_stint_outline' -- stint-ucr
end

-- 插入字体注册函数
local OldUnregisterAllPrefabs = G.Sim.UnregisterAllPrefabs
G.Sim.UnregisterAllPrefabs = function(self, ...)
  OldUnregisterAllPrefabs(self, ...)
  RegisterFonts()
end
local OldRegisterPrefabs = G.ModManager.RegisterPrefabs
G.ModManager.RegisterPrefabs = function(...)
  OldRegisterPrefabs(...)
  RegisterFonts()
end
local OldStart = G.Start
G.Start = function()
  RegisterFonts()
  OldStart()
end

-- 缩放倍率
local ratio = GetModConfigData('font_scale_ratio')
G.LOC.GetTextScale = function() -- 仅对客户端语言为简体中文的情况调整缩放
  return (G.LOC.GetLocaleCode() == 'zh') and ratio or G.LOC.CurrentLocale and G.LOC.CurrentLocale.scale or 1.0
end

-- 细节微调
AddClassPostConstruct('screens/pausescreen', function(self)
  if self.subtitle then self.subtitle:SetSize(24) end
end)
AddClassPostConstruct('screens/redeemdialog', function(self)
  if self.fineprint then self.fineprint:SetSize(24) end
end)
AddClassPostConstruct('widgets/badge', function(self)
  if self.num then self.num:SetSize(24 / ratio) end
  if self.maxnum then self.maxnum:SetSize(20 / ratio) end
end)
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

LoadPOFile(MODROOT .. 'chinese_s.po', 'zh') -- 加载字符串换行修复文件
