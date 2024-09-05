-- UI.lua
iLoot = iLoot or {}

-- Create a basic frame
local frame = CreateFrame("Frame", "iLootFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(300, 360)
frame:SetPoint("CENTER")
frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlight")
frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 0, 0)
frame.title:SetText("iLoot")

-- Hide the frame by default
frame:Hide()

-- Define a function to toggle the UI frame
function iLoot:ToggleUI()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

-- Register the /iloot command
SLASH_ILOOT1 = "/iloot"
SlashCmdList["ILOOT"] = function(msg)
    iLoot:ToggleUI()
end
