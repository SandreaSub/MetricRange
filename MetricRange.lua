-------------------------------------------------
-- MetricRange
-- Vanilla 1.12 / Turtle / OctoWoW
-- No OnUpdate, convert on tooltip OnShow
-------------------------------------------------

local MetricRangeFrame = CreateFrame("Frame")
local MetricRangeHooked = {}

local function MetricRange_Convert(text)
    if type(text) ~= "string" then
        return text
    end

    -- plural first
    text = string.gsub(text, " yards", " metres")
    text = string.gsub(text, " yard", " metre")
    text = string.gsub(text, " yd", " m")

    return text
end

local function MetricRange_ConvertTooltip(tooltip)
    if not tooltip or not tooltip.GetName then
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

local function MetricRange_HookTooltipOnShow(tooltip)
    if not tooltip or MetricRangeHooked[tooltip] then
        return
    end

    MetricRangeHooked[tooltip] = 1

    local oldOnShow = nil
    if tooltip.GetScript then
        oldOnShow = tooltip:GetScript("OnShow")
    end

    tooltip:SetScript("OnShow", function()
        if oldOnShow then
            oldOnShow()
        end

        MetricRange_ConvertTooltip(this)
    end)
end

local function MetricRange_Init()
    MetricRange_HookTooltipOnShow(GameTooltip)
    MetricRange_HookTooltipOnShow(ItemRefTooltip)
    MetricRange_HookTooltipOnShow(ShoppingTooltip1)
    MetricRange_HookTooltipOnShow(ShoppingTooltip2)
    MetricRange_HookTooltipOnShow(ShoppingTooltip3)

    if GameTooltip and GameTooltip:IsVisible() then
        MetricRange_ConvertTooltip(GameTooltip)
    end

    if ItemRefTooltip and ItemRefTooltip:IsVisible() then
        MetricRange_ConvertTooltip(ItemRefTooltip)
    end
end

local function MetricRange_OnEvent()
    MetricRange_Init()
end

MetricRangeFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
MetricRangeFrame:RegisterEvent("VARIABLES_LOADED")
MetricRangeFrame:SetScript("OnEvent", MetricRange_OnEvent)

MetricRange_Init()

SLASH_METRICRANGE1 = "/metricrange"
SlashCmdList["METRICRANGE"] = function()
    MetricRange_Init()
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd200MetricRange|r refreshed")
    end
end
