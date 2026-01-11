local G = GLOBAL

if GetModConfigData('replace_fonts_fully_but_crash_when_mod_disabled') then
  modimport('replace_fonts_fully')
else
  modimport('replace_fonts_safely')
end

modimport('chinese_s_patch') -- 加载字符串修复文件

--------------------------------------------------------------------------------
-- 字号微调

-- 缩放倍率
local ratio = GetModConfigData('font_scale_ratio')
G.LOC.GetTextScale = function() return ratio end

-- 季节时钟 字号
AddClassPostConstruct('widgets/controls', function(self)
  if self.seasonclock and self.seasonclock._text then self.seasonclock._text:SetSize(34 / ratio) end
end)

-- 制作配方 材料数量 字号
AddClassPostConstruct('widgets/ingredientui', function(self)
  if self.quant then self.quant:SetSize(32 / ratio) end
end)

-- 世界设置
AddClassPostConstruct('widgets/redux/worldsettings/settingslist', function(self)
  local OldMakeScrollList = self.MakeScrollList
  function self:MakeScrollList()
    OldMakeScrollList(self)
    local scroll_list = self.scroll_list
    if not (scroll_list and scroll_list.GetListWidgets) then return end

    for _, widget in ipairs(scroll_list:GetListWidgets()) do
      local spinner = widget.opt_spinner and widget.opt_spinner.spinner
      if spinner then
        if spinner.label then spinner.label:SetSize(22 / ratio) end
        if spinner.text then spinner.text:SetSize(22 / ratio) end
      end
    end
  end
end)

-- 交易小店 店主台词 字号
AddClassPostConstruct('widgets/skincollector', function(self)
  if self.text then self.text:SetSize(26 / ratio) end
end)

-- 时钟 > 世界天数、月相
AddClassPostConstruct('widgets/uiclock', function(self)
  if self._text then self._text:SetSize(GetModConfigData('world_clock_size') / ratio) end
  if self._moonanim and self._moonanim.moontext then self._moonanim.moontext:SetSize(18 / ratio) end
end)

--------------------------------------------------------------------------------
-- 错乱修复

-- 加载提示
AddClassPostConstruct('widgets/redux/loadingwidget', function(self)
  local OldOnUpdate = self.OnUpdate
  function self:OnUpdate(dt)
    if self.loading_widget then self.loading_widget:SetFont(G.UIFONT) end
    if self.loading_tip_text then self.loading_tip_text:SetFont(G.CHATFONT_OUTLINE) end
    OldOnUpdate(self, dt)
  end
end)

-- 暂停提示
AddClassPostConstruct('widgets/redux/serverpausewidget', function(self)
  local OldUpdateText = self.UpdateText
  function self:UpdateText(...)
    if self.text then self.text:SetFont(G.UIFONT) end
    OldUpdateText(self, ...)
  end
end)

-- 控制台日志
AddGlobalClassPostConstruct('frontend', 'FrontEnd', function(self)
  local OldShowConsoleLog = self.ShowConsoleLog
  function self:ShowConsoleLog()
    if self.consoletext then self.consoletext:SetFont(G.BODYTEXTFONT) end
    return OldShowConsoleLog(self)
  end
end)
