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

--------------------------------------------------------------------------------
-- 覆盖补全
local ratio = GetModConfigData('font_scale_ratio') -- 缩放倍率

-- 交易小店 最后一件 警告弹窗
AddClassPostConstruct('screens/imagepopupdialog', function(self)
  if self.title then self.title:SetFont(G.BUTTONFONT) end
  if self.text then self.text:SetFont(G.NEWFONT) end
end)

-- 制作配方 皮肤选择器
AddClassPostConstruct('widgets/redux/craftingmenu_skinselector', function(self)
  if self.spinner and self.spinner.text then self.spinner.text:SetFont(G.NUMBERFONT) end
end)

-- 服务器设置
AddClassPostConstruct('widgets/redux/serversettingstab', function(self)
  local buttons = self.privacy_type and self.privacy_type.buttons or {}
  for _, widget in ipairs(buttons.buttonwidgets or {}) do
    if widget and widget.button then widget.button:SetFont(G.NEWFONT) end
  end
end)

-- 世界设置
AddClassPostConstruct('widgets/redux/worldsettings/settingslist', function(self)
  local OldMakeScrollList = self.MakeScrollList
  function self:MakeScrollList()
    OldMakeScrollList(self)
    for _, widget in ipairs(self.scroll_list:GetListWidgets()) do
      widget.opt_spinner.spinner.label:SetFont(G.HEADERFONT)
      widget.opt_spinner.spinner.label:SetSize(22 / ratio)
      widget.opt_spinner.spinner.text:SetFont(G.BUTTONFONT)
      widget.opt_spinner.spinner.text:SetSize(20 / ratio)
    end
  end
end)

-- 检测还未替换字体的文本控件，直接替换成寄居蟹专属字体，就当彩蛋了。
local function is_replaced(font)
  for _, v in ipairs(fonts) do
    if font == 'tsanger_' .. v then return true end
  end
end
AddClassPostConstruct('widgets/text', function(self)
  if not is_replaced(self.font) then self:SetFont('tsanger_sugarplum_outline') end
end)
