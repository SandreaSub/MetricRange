-------------------------------------------------
-- MetricRange
-- Vanilla 1.12 / Turtle / OctoWoW
-- Instant tooltip scan while a tooltip is visible
-------------------------------------------------

local MetricRangeFrame = CreateFrame("Frame")

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
    if not tooltip or not tooltip.IsVisible or not tooltip:IsVisible() then
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

local function MetricRange_RefreshVisibleTooltips()
    MetricRange_ConvertTooltip(GameTooltip)
    MetricRange_ConvertTooltip(ItemRefTooltip)
    MetricRange_ConvertTooltip(ShoppingTooltip1)
    MetricRange_ConvertTooltip(ShoppingTooltip2)
    MetricRange_ConvertTooltip(ShoppingTooltip3)
end

MetricRangeFrame:SetScript("OnUpdate", function()
    if (GameTooltip and GameTooltip:IsVisible())
        or (ItemRefTooltip and ItemRefTooltip:IsVisible())
        or (ShoppingTooltip1 and ShoppingTooltip1:IsVisible())
        or (ShoppingTooltip2 and ShoppingTooltip2:IsVisible())
        or (ShoppingTooltip3 and ShoppingTooltip3:IsVisible()) then
        MetricRange_RefreshVisibleTooltips()
    end
end)

SLASH_METRICRANGE1 = "/metricrange"
SlashCmdList["METRICRANGE"] = function()
    MetricRange_RefreshVisibleTooltips()
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd200MetricRange|r refreshed")
end