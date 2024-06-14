local G = GLOBAL

local fonts = { -- 加入了苍耳玄三的原版字体列表
  'belisaplumilla_outline',
  'bellefair_outline',
  'bellefair',
  'hammerhead',
  'spirequal_outline',
  'spirequal',
  'stint_outline',
  'sugarplum_outline',
  'hennypenny_outline'
}

local replaces = { -- 字体替换列表
  TITLEFONT             = 'belisaplumilla_outline',
  UIFONT                = 'belisaplumilla_outline',
  TALKINGFONT           = 'belisaplumilla_outline',
  TALKINGFONT_HERMIT    = 'sugarplum_outline',
  TALKINGFONT_TRADEIN   = 'belisaplumilla_outline',
  TALKINGFONT_WORMWOOD  = 'hennypenny_outline',
  CHATFONT_OUTLINE      = 'bellefair_outline',
  CHATFONT              = 'bellefair',
  BUTTONFONT            = 'bellefair',
  HEADERFONT            = 'hammerhead',
  NEWFONT_OUTLINE       = 'spirequal_outline',
  NEWFONT_OUTLINE_SMALL = 'spirequal_outline',
  NEWFONT               = 'spirequal',
  NEWFONT_SMALL         = 'spirequal',
  BODYTEXTFONT          = 'stint_outline',
  NUMBERFONT            = 'stint_outline',
  SMALLNUMBERFONT       = 'stint_outline',
}

local assets = {} -- 资源文件列表
for _, font in pairs(fonts) do table.insert(assets, Asset('FONT', MODROOT .. 'fonts/' .. font .. '.zip')) end

local function RegisterFonts() -- 注册字体
  for _, font in pairs(fonts) do G.TheSim:UnloadFont(font) end
  G.TheSim:UnloadPrefabs { 'tsanger_xuansan' }
  G.TheSim:RegisterPrefab('tsanger_xuansan', assets, {})
  G.TheSim:LoadPrefabs { 'tsanger_xuansan' }
  for _, font in pairs(fonts) do
    local fallback = font:find 'outline' and G.DEFAULT_FALLBACK_TABLE_OUTLINE or G.DEFAULT_FALLBACK_TABLE
    G.TheSim:LoadFont(MODROOT .. 'fonts/' .. font .. '.zip', font)
    G.TheSim:SetupFontFallbacks(font, fallback)
  end
  for k, v in pairs(replaces) do G[k] = v end
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
local ratio = GetModConfigData 'font_scale_ratio'
G.LOC.GetTextScale = function() -- 仅对客户端语言为简体中文的情况调整缩放
  return (G.LANGUAGE.CHINESE_S == G.LOC.CurrentLocale.id) and ratio or G.LOC.CurrentLocale.scale
end

-- 细节微调
AddClassPostConstruct('screens/pausescreen', function(self) if self.subtitle then self.subtitle:SetSize(24) end end)
AddClassPostConstruct('screens/redeemdialog', function(self) if self.fineprint then self.fineprint:SetSize(24) end end)
AddClassPostConstruct('widgets/badge', function(self)
  if self.num then self.num:SetSize(24 / ratio) end
  if self.maxnum then self.maxnum:SetSize(20 / ratio) end
end)
AddClassPostConstruct('widgets/controls', function(self)
  if self.seasonclock and self.seasonclock._text then self.seasonclock._text:SetSize(34 / ratio) end
end)
AddClassPostConstruct('widgets/ingredientui', function(self) if self.quant then self.quant:SetSize(32 / ratio) end end)
AddClassPostConstruct('widgets/skincollector', function(self) if self.text then self.text:SetSize(26 / ratio) end end)
AddClassPostConstruct('widgets/uiclock', function(self)
  if self._text then self._text:SetSize(GetModConfigData 'world_clock_size' / ratio) end
  if self._moonanim and self._moonanim.moontext then self._moonanim.moontext:SetSize(18 / ratio) end
end)
