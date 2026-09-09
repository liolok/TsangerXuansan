local G = GLOBAL

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
  ['talkingfont_hermit']      = GetModConfigData('enable_hermit_font') and 'sugarplum_outline' or 'belisaplumilla_outline',
  ['talkingfont_wormwood']    = GetModConfigData('enable_wormwood_font') and 'hennypenny_outline' or 'belisaplumilla_outline',
}

-- 注入字体
local fonts_loaded = false -- 本局是否已经注册并加载过 tsanger_fonts

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
  -- 最新测试版引擎：UnregisterPrefabs 只允许注销“未加载”的 prefab，
  -- 否则触发 C++ 断言 (mLoadFlags & PrefabLoadFlags_Loaded) == 0。
  -- 与游戏内置 loadedprefabs 记账一致，注销前先 UnloadPrefabs。
  if fonts_loaded then G.TheSim:UnloadPrefabs({ 'tsanger_fonts' }) end
  G.TheSim:UnregisterPrefabs({ 'tsanger_fonts' })
  G.TheSim:RegisterPrefab('tsanger_fonts', Assets, {})
  G.TheSim:LoadPrefabs({ 'tsanger_fonts' })
  fonts_loaded = true
  G.LoadFonts()
end
local OldUnregisterAllPrefabs = G.Sim.UnregisterAllPrefabs
G.Sim.UnregisterAllPrefabs = function(...)
  OldUnregisterAllPrefabs(...)
  fonts_loaded = false -- 引擎已注销全部 prefab，之后需要重新注册加载
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
