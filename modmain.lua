local _G = GLOBAL

local fonts = {
    "belisaplumilla_outline",
    "bellefair_outline",
    "bellefair",
    "hammerhead",
    "spirequal_outline",
    "spirequal",
    "stint_outline"
}

local assets = {}
for _, v in pairs(fonts) do table.insert(assets, _G.Asset("FONT", MODROOT.."fonts/"..v..".zip")) end

local replaces = {
    TITLEFONT               = "belisaplumilla_outline",
    UIFONT                  = "belisaplumilla_outline",
    TALKINGFONT             = "belisaplumilla_outline",
    TALKINGFONT_HERMIT      = "belisaplumilla_outline",
    TALKINGFONT_TRADEIN     = "belisaplumilla_outline",
    TALKINGFONT_WORMWOOD    = "belisaplumilla_outline",
    CHATFONT_OUTLINE        = "bellefair_outline",
    CHATFONT                = "bellefair",
    BUTTONFONT              = "bellefair",
    HEADERFONT              = "hammerhead",
    NEWFONT_OUTLINE         = "spirequal_outline",
    NEWFONT_OUTLINE_SMALL   = "spirequal_outline",
    NEWFONT                 = "spirequal",
    NEWFONT_SMALL           = "spirequal",
    BODYTEXTFONT            = "stint_outline",
    NUMBERFONT              = "stint_outline",
    SMALLNUMBERFONT         = "stint_outline",
}

local function RegisterFonts()
    local prefab = "tsanger_xuansan"
    for _, font in pairs(fonts) do _G.TheSim:UnloadFont(font) end
    _G.TheSim:UnloadPrefabs({prefab})
    _G.TheSim:RegisterPrefab(prefab, assets, {})
    _G.TheSim:LoadPrefabs({prefab})
    for _, font in pairs(fonts) do
        _G.TheSim:LoadFont(MODROOT.."fonts/"..font..".zip", font)
        _G.TheSim:SetupFontFallbacks(font, font:find("outline")
            and _G.DEFAULT_FALLBACK_TABLE_OUTLINE or _G.DEFAULT_FALLBACK_TABLE)
    end
    for k, v in pairs(replaces) do _G[k] = v end
end

local OldRegisterPrefabs = _G.ModManager.RegisterPrefabs
_G.ModManager.RegisterPrefabs = function(...)
    OldRegisterPrefabs(...)
    RegisterFonts()
end

local OldStart = _G.Start
_G.Start = function()
    RegisterFonts()
    OldStart()
end

-- 缩放倍率

local ratio = GetModConfigData("font_scale_ratio")

_G.LOC.GetTextScale = function() -- 仅对客户端语言为简体中文的情况调整缩放
    return (_G.LANGUAGE.CHINESE_S == _G.LOC.CurrentLocale.id) and ratio or _G.LOC.CurrentLocale.scale
end

-- 以下调节一些较小的字体

AddClassPostConstruct("screens/pausescreen", function(self)
    if self.subtitle then self.subtitle:SetSize(24) end
end)

AddClassPostConstruct("screens/redeemdialog", function(self)
    if self.fineprint then self.fineprint:SetSize(24) end
end)

AddClassPostConstruct("widgets/badge", function(self)
    if self.num then self.num:SetSize(24 / ratio) end
    if self.maxnum then self.maxnum:SetSize(20 / ratio) end
end)

AddClassPostConstruct("widgets/controls", function(self)
    if self.seasonclock and self.seasonclock._text then self.seasonclock._text:SetSize(34 / ratio) end
end)

AddClassPostConstruct("widgets/itemtile", function(self)
    if self.quantity then self.quantity:SetSize(44 / ratio) end
    if self.percent then self.percent:SetSize(44 / ratio) end
end)

AddClassPostConstruct("widgets/ingredientui", function(self)
    if self.quant then self.quant:SetSize(25 / ratio) end
end)

AddClassPostConstruct("widgets/skincollector", function(self)
    if self.text then self.text:SetSize(26 / ratio) end
end)

AddClassPostConstruct("widgets/uiclock", function(self)
    if self._text then self._text:SetSize(GetModConfigData("world_clock_size") / ratio) end
    if self._moonanim and self._moonanim.moontext then self._moonanim.moontext:SetSize(18 / ratio) end
end)
