local G = GLOBAL

if GetModConfigData('replace_fonts_fully_but_crash_when_mod_disabled') then
  modimport('replace_fonts_fully')
else
  modimport('replace_fonts_safely')
end

-- 加载字符串修复文件
modimport('chinese_s_patch')

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

-- 交易小店 店主台词 字号
AddClassPostConstruct('widgets/skincollector', function(self)
  if self.text then self.text:SetSize(26 / ratio) end
end)

-- 时钟 > 世界天数、月相
AddClassPostConstruct('widgets/uiclock', function(self)
  if self._text then self._text:SetSize(GetModConfigData('world_clock_size') / ratio) end
  if self._moonanim and self._moonanim.moontext then self._moonanim.moontext:SetSize(18 / ratio) end
end)
