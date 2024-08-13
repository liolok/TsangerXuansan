local G = GLOBAL

local fonts = { -- 加入了中文字体的原版字体列表
  'belisaplumilla_outline',
  'bellefair_outline',
  'bellefair',
  'hammerhead',
  'hennypenny_outline',
  'spirequal_outline',
  'spirequal',
  'stint_outline',
  'sugarplum_outline',
}

-- stylua: ignore
local replace = { -- 替换列表
  ['bellefair']               = 'bellefair',
  ['bellefair_outline']       = 'bellefair_outline',
  ['bp100']                   = 'belisaplumilla_outline',
  ['bp50']                    = 'belisaplumilla_outline',
  ['buttonfont']              = 'bellefair',
  ['hammerhead']              = 'hammerhead',
  ['opensans']                = 'stint_outline',
  ['spirequal']               = 'spirequal',
  ['spirequal_small']         = 'spirequal',
  ['spirequal_outline']       = 'spirequal_outline',
  ['spirequal_outline_small'] = 'spirequal_outline',
  ['stint-ucr']               = 'stint_outline',
  ['stint-small']             = 'stint_outline',
  ['talkingfont']             = 'belisaplumilla_outline',
  ['talkingfont_tradein']     = 'belisaplumilla_outline',
  ['talkingfont_hermit']      = 'sugarplum_outline', -- 寄居蟹隐士：中文部分使用仓耳瓜藤体
  ['talkingfont_wormwood']    = 'hennypenny_outline', -- 沃姆伍德：中文部分使用仓耳青丘小九
}

-- 注入字体
local function ReloadFonts()
  Assets = {}
  for _, v in ipairs(G.FONTS) do
    local font = replace[v.alias]
    if font then
      local filename = MODROOT .. 'fonts/' .. font .. '.zip'
      table.insert(Assets, Asset('FONT', filename))
      v.filename = filename
      G.TheSim:UnloadFont(v.alias)
    end
  end
  G.TheSim:UnregisterPrefabs({ 'tsanger_fonts' })
  G.TheSim:RegisterPrefab('tsanger_fonts', Assets, {})
  G.TheSim:LoadPrefabs({ 'tsanger_fonts' })
  G.LoadFonts()
end
local OldUnregisterAllPrefabs = G.Sim.UnregisterAllPrefabs
G.Sim.UnregisterAllPrefabs = function(...)
  OldUnregisterAllPrefabs(...)
  return ReloadFonts()
end
local OldRegisterPrefabs = G.ModManager.RegisterPrefabs
G.ModManager.RegisterPrefabs = function(...)
  OldRegisterPrefabs(...)
  return ReloadFonts()
end
local OldStart = G.Start
G.Start = function()
  ReloadFonts() -- 此处会概率触发字体错乱，克雷全责。
  return OldStart()
end

-- 加载字符串换行修复文件
LoadPOFile(MODROOT .. 'chinese_s_patch.po', 'zh')

-- 缩放倍率
local ratio = GetModConfigData('font_scale_ratio')
G.LOC.GetTextScale = function() return ratio end

-- 季节时钟
AddClassPostConstruct('widgets/controls', function(self)
  if self.seasonclock and self.seasonclock._text then self.seasonclock._text:SetSize(34 / ratio) end
end)

-- 制作配方
AddClassPostConstruct('widgets/ingredientui', function(self)
  if self.quant then self.quant:SetSize(32 / ratio) end
end)

-- 世界设置
AddClassPostConstruct('widgets/redux/worldsettings/settingslist', function(self)
  local OldMakeScrollList = self.MakeScrollList
  self.MakeScrollList = function(self)
    OldMakeScrollList(self)
    for _, widget in ipairs(self.scroll_list:GetListWidgets()) do
      widget.opt_spinner.spinner.label:SetFont(G.HEADERFONT)
      widget.opt_spinner.spinner.label:SetSize(22 / ratio)
      widget.opt_spinner.spinner.text:SetFont(G.BUTTONFONT)
      widget.opt_spinner.spinner.text:SetSize(20 / ratio)
    end
  end
end)

-- 交易小店 店主台词
AddClassPostConstruct('widgets/skincollector', function(self)
  if self.text then self.text:SetSize(26 / ratio) end
end)

-- 时钟 > 世界天数、月相
AddClassPostConstruct('widgets/uiclock', function(self)
  if self._text then self._text:SetSize(GetModConfigData('world_clock_size') / ratio) end
  if self._moonanim and self._moonanim.moontext then self._moonanim.moontext:SetSize(18 / ratio) end
end)
