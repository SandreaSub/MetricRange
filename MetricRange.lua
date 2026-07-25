-------------------------------------------------
-- MetricRange
-- Vanilla 1.12 / Turtle / OctoWoW
-- Old-style hooks only
-------------------------------------------------

local MetricRange_Elapsed = 0
local MetricRange_Original = {}

local function MetricRange_ConvertNumber(yardsText)
    local yards = tonumber(yardsText)
    if not yards then
        return yardsText
    end

    local metres = yards * 0.9144
    metres = math.floor(metres * 10 + 0.5) / 10

    return string.format("%.1f m", metres)
end

local function MetricRange_Convert(text)
    if type(text) ~= "string" then
        return text
    end

    text = string.gsub(text, "([%d%.]+)%s*[Yy][Dd][Ss]?", MetricRange_ConvertNumber)
    text = string.gsub(text, "([%d%.]+)%s*[Yy][Aa][Rr][Dd][Ss]?", MetricRange_ConvertNumber)

    return text
end

local function MetricRange_ConvertTooltip(tooltip)
    if not tooltip then
        return
    end

    local name = tooltip:GetName()
    if not name then
        return
    end

    local i
    for i = 1, 30 do
        local left = getglobal(name .. "TextLeft" .. i)
        if left then
            local t = left:GetText()
            if t then
                local newText = MetricRange_Convert(t)
                if newText ~= t then
                    left:SetText(newText)
                end
            end
        end

        local right = getglobal(name .. "TextRight" .. i)
        if right then
            local t = right:GetText()
            if t then
                local newText = MetricRange_Convert(t)
                if newText ~= t then
                    right:SetText(newText)
                end
            end
        end
    end
end

local function MetricRange_RefreshAll()
    MetricRange_ConvertTooltip(GameTooltip)
    MetricRange_ConvertTooltip(ItemRefTooltip)
    MetricRange_ConvertTooltip(ShoppingTooltip1)
    MetricRange_ConvertTooltip(ShoppingTooltip2)
    MetricRange_ConvertTooltip(ShoppingTooltip3)
end

local function MetricRange_HookEnterFunction(name)
    if type(getglobal(name)) ~= "function" then
        return
    end

    MetricRange_Original[name] = getglobal(name)

    setglobal(name, function()
        MetricRange_Original[name]()

        MetricRange_RefreshAll()
    end)
end

local function MetricRange_HookEnterFunctionWithTooltip(name)
    if type(getglobal(name)) ~= "function" then
        return
    end

    MetricRange_Original[name] = getglobal(name)

    setglobal(name, function()
        MetricRange_Original[name]()

        if GameTooltip then
            MetricRange_ConvertTooltip(GameTooltip)
        end
        if ItemRefTooltip then
            MetricRange_ConvertTooltip(ItemRefTooltip)
        end
    end)
end

local function MetricRange_OnEvent()
    MetricRange_RefreshAll()
end

local function MetricRange_OnUpdate()
    MetricRange_Elapsed = MetricRange_Elapsed + arg1
    if MetricRange_Elapsed < 0.20 then
        return
    end
    MetricRange_Elapsed = 0

    MetricRange_RefreshAll()
end

local function MetricRange_Init()
    if MetricRange_Original.__inited then
        return
    end
    MetricRange_Original.__inited = 1

    MetricRange_HookEnterFunctionWithTooltip("SpellButton_OnEnter")
    MetricRange_HookEnterFunctionWithTooltip("ActionButton_OnEnter")
    MetricRange_HookEnterFunctionWithTooltip("BagSlotButton_OnEnter")
    MetricRange_HookEnterFunctionWithTooltip("ContainerFrameItemButton_OnEnter")
    MetricRange_HookEnterFunctionWithTooltip("MerchantItemButton_OnEnter")
    MetricRange_HookEnterFunctionWithTooltip("TradeSkillSkillButton_OnEnter")
    MetricRange_HookEnterFunctionWithTooltip("QuestInfo_GetRewardButton_OnEnter")
    MetricRange_HookEnterFunctionWithTooltip("QuestInfoItem_OnEnter")
    MetricRange_HookEnterFunctionWithTooltip("UnitPopup_OnEnter")
    MetricRange_HookEnterFunctionWithTooltip("PaperDollItemSlotButton_OnEnter")

    MetricRange_HookEnterFunction("GameTooltip_OnTooltipSetItem")
    MetricRange_HookEnterFunction("GameTooltip_OnTooltipSetSpell")

    MetricRange_RefreshAll()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("SPELLS_CHANGED")
frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UPDATE_MACROS")
frame:SetScript("OnEvent", MetricRange_OnEvent)
frame:SetScript("OnUpdate", MetricRange_OnUpdate)

MetricRange_Init()

SLASH_METRICRANGE1 = "/metricrange"
SlashCmdList["METRICRANGE"] = function()
    MetricRange_RefreshAll()
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd200MetricRange|r refreshed")
end