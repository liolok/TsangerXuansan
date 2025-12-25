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

-- stylua: ignore
local font_table = {
  DEFAULTFONT           = 'stint_outline',
  DIALOGFONT            = 'stint_outline',
  TITLEFONT             = 'belisaplumilla_outline',
  UIFONT                = 'belisaplumilla_outline',
  BUTTONFONT            = 'bellefair',
  NEWFONT               = 'spirequal',
  NEWFONT_SMALL         = 'spirequal',
  NEWFONT_OUTLINE       = 'spirequal_outline',
  NEWFONT_OUTLINE_SMALL = 'spirequal_outline',
  NUMBERFONT            = 'stint_outline',
  TALKINGFONT           = 'belisaplumilla_outline',
  TALKINGFONT_WORMWOOD  = GetModConfigData('enable_wormwood_font') and 'hennypenny_outline' or 'belisaplumilla_outline',
  TALKINGFONT_TRADEIN   = 'belisaplumilla_outline',
  TALKINGFONT_HERMIT    = GetModConfigData('enable_hermit_font') and 'sugarplum_outline' or 'belisaplumilla_outline',
  CHATFONT              = 'bellefair',
  HEADERFONT            = 'hammerhead',
  CHATFONT_OUTLINE      = 'bellefair_outline',
  SMALLNUMBERFONT       = 'stint_outline',
  BODYTEXTFONT          = 'stint_outline',
}

Assets = {} -- 资源列表
for _, font in ipairs(fonts) do
  local file_path = MODROOT .. 'fonts/' .. font .. '.zip'
  local fb = G.DEFAULT_FALLBACK_TABLE
  if font:find('_outline$') then fb = G.DEFAULT_FALLBACK_TABLE_OUTLINE end
  table.insert(Assets, Asset('FONT', file_path))
  table.insert(G.FONTS, { filename = file_path, alias = 'tsanger_' .. font, fallback = fb })
end

-- 注入字体
local function ReloadFonts()
  for _, font in ipairs(fonts) do
    G.TheSim:UnloadFont('tsanger_' .. font)
  end
  G.TheSim:UnregisterPrefabs({ 'tsanger_fonts' })
  G.TheSim:RegisterPrefab('tsanger_fonts', Assets, {})
  G.TheSim:LoadPrefabs({ 'tsanger_fonts' })
  G.LoadFonts()
  for k, v in pairs(font_table) do
    G[k] = 'tsanger_' .. v
  end
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

-- 加载字符串修复文件
modimport('chinese_s_patch')

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

-- 加载提示
AddClassPostConstruct('widgets/redux/loadingwidget', function(self)
  local OldOnUpdate = self.OnUpdate
  self.OnUpdate = function(self, dt)
    if self.loading_widget then self.loading_widget:SetFont(G.UIFONT) end
    if self.loading_tip_text then self.loading_tip_text:SetFont(G.CHATFONT_OUTLINE) end
    OldOnUpdate(self, dt)
  end
end)

-- 暂停提示
AddClassPostConstruct('widgets/redux/serverpausewidget', function(self)
  local OldUpdateText = self.UpdateText
  self.UpdateText = function(self, source)
    if self.text then self.text:SetFont(G.UIFONT) end
    OldUpdateText(self, source)
  end
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

-- 控制台日志
AddGlobalClassPostConstruct('frontend', 'FrontEnd', function(self)
  local OldShowConsoleLog = self.ShowConsoleLog
  self.ShowConsoleLog = function(self)
    if self.consoletext then self.consoletext:SetFont(G.BODYTEXTFONT) end
    return OldShowConsoleLog(self)
  end
end)
