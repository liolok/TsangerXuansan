LoadPOFile(MODROOT .. 'chinese_s_patch.po', 'zh')

local STRINGS = GLOBAL.STRINGS -- string name -> English
local STRINGS_NEW = GLOBAL.LanguageTranslator.languages.zh -- string name -> Simplified Chinese we patched

local DICTIONARY = {} -- English -> Simplified Chinese we patched
local function BuildDictionary(stringsNode, str)
  for i, v in pairs(stringsNode) do
    if type(v) == 'table' then
      BuildDictionary(stringsNode[i], str .. '.' .. i)
    else
      DICTIONARY[v] = STRINGS_NEW[str .. '.' .. i]
    end
  end
end
BuildDictionary(STRINGS, 'STRINGS')

local function TranslateFromDictionary(s)
  -- it's just in the dictionary
  local tmp = DICTIONARY[s]
  if tmp then return tmp end

  local function isAcceptableAfterNick(x)
    return (x == ' ') or (x == ',') or (x == '.') or (x == '!') or (x == '?') or (x == "'")
  end

  -- we are looking for subtitles with one %s
  local n = s:len()
  local ret, nickLen = nil, n + 1
  for i = 1, n do
    if i == 1 or s:sub(i - 1, i - 1) == ' ' then
      for j = math.min(n, i + nickLen - 2), i, -1 do
        if j == n or isAcceptableAfterNick(s:sub(j + 1, j + 1)) then
          -- the string [i,j] can be the player's nickname
          local x = s:sub(1, i - 1) .. '%s' .. s:sub(j + 1)
          -- print("x1=", x)
          x = DICTIONARY[x]
          -- print("x2=", x) ;
          if x then
            -- print("cand=", x)
            x = x:gsub('%%s', s:sub(i, j))
            if j - i + 1 < nickLen then
              nickLen = j - i + 1
              ret = x
            end
          end
        end
      end
    end
  end
  if ret then return ret end

  -- we are looking for subtitles with two %s
  ret, nickLen = nil, n + 1
  for i = 1, n do
    if i == 1 or s:sub(i - 1, i - 1) == ' ' then
      for j = math.min(n, i + nickLen - 2), i, -1 do
        if j == n or isAcceptableAfterNick(s:sub(j + 1, j + 1)) then
          -- the string [i,j] can be the player's nickname
          for k = j + 2, n do
            if s:sub(k - 1, k - 1) == ' ' then
              for l = k, n do
                if l == n or isAcceptableAfterNick(s:sub(l + 1, l + 1)) then
                  -- the string [k,l] may be the attacker
                  local x = s:sub(1, i - 1) .. '%s' .. s:sub(j + 1, k - 1) .. '%s' .. s:sub(l + 1)
                  -- print("x1=", x)
                  x = DICTIONARY[x]
                  -- print("x2=", x) ;
                  if x then
                    -- print("cand=", x)
                    local attacker = s:sub(k, l)
                    attacker = DICTIONARY[attacker] or attacker
                    x = x:gsub('%%s', s:sub(i, j), 1)
                    x = x:gsub('%%s', attacker)
                    if j - i + 1 < nickLen then
                      nickLen = j - i + 1
                      ret = x
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  if ret then return ret end

  -- not translated
  return s or ''
end

-- split string using given separator
local function split(str, sep)
  local fields, first = {}, 1
  str = str .. sep
  for i = 1, #str do
    if str:sub(i, i) == sep then
      fields[#fields + 1] = str:sub(first, i - 1)
      first = i + 1
    end
  end
  return fields
end

local function TranslateMessage(message)
  local messages = split(message, '\n') or { message }
  local ret = ''
  for i = 1, #messages do
    local translated = TranslateFromDictionary(messages[i])
    if i == 1 then
      ret = translated
    elseif translated ~= messages[i] then
      ret = ret .. '\n' .. translated
    else
      ret = ret .. TranslateFromDictionary('\n' .. messages[i])
    end
  end
  return ret
end

-- On-the-fly translation of quotes from the server
local OldTalk = GLOBAL.Networking_Talk

GLOBAL.Networking_Talk = function(guid, message, ...)
  -- print("Networking_Talk", guid, message, ...)
  message = TranslateMessage(message)
  -- message = "+ "..message.." +"
  if OldTalk then OldTalk(guid, message, ...) end
end

--------------------------------------------------------------------------------
-- Fix translation of death notifications

local OldDeathAnnouncement = GLOBAL.Networking_DeathAnnouncement

local deathSeparator = STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1
local deathPossibleEnds = {
  STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_DEFAULT,
  STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_MALE,
  STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_FEMALE,
  STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_ROBOT,
}

GLOBAL.Networking_DeathAnnouncement = function(message, colour, ...)
  if deathSeparator then
    local k, l = message:find(deathSeparator)
    if k and l then
      for i = 1, #deathPossibleEnds do
        if deathPossibleEnds[i] and message:sub(-deathPossibleEnds[i]:len()) == deathPossibleEnds[i] then
          local victim = message:sub(1, k - 1)
          local attacker = message:sub(l + 2, message:len() - deathPossibleEnds[i]:len())
          -- print(victim)
          -- print(attacker)
          OldDeathAnnouncement(
            victim
              .. (DICTIONARY[deathSeparator] or deathSeparator)
              .. ' '
              .. (DICTIONARY[attacker] or attacker)
              .. (DICTIONARY[deathPossibleEnds[i]] or deathPossibleEnds[i]),
            color,
            ...
          )
          return nil
        end
      end
    end
  end
  return OldDeathAnnouncement(message, color, ...)
end

--------------------------------------------------------------------------------
-- Fix translation of resurrection notifications

local OlsResurrectAnnouncement = GLOBAL.Networking_ResurrectAnnouncement

local resSeparator = STRINGS.UI.HUD.REZ_ANNOUNCEMENT

GLOBAL.Networking_ResurrectAnnouncement = function(message, color, ...)
  if resSeparator then
    local k, l = message:find(resSeparator)
    if k and l then
      local victim = message:sub(1, k - 1)
      local attacker = message:sub(l + 2, message:len() - 1)
      -- print(victim)
      -- print(attacker)
      OlsResurrectAnnouncement(
        victim
          .. (DICTIONARY[resSeparator] or resSeparator)
          .. ' '
          .. (DICTIONARY[attacker] or attacker)
          .. message:sub(message:len()),
        color,
        ...
      )
      return nil
    end
  end
  return OlsResurrectAnnouncement(message, color, ...)
end
