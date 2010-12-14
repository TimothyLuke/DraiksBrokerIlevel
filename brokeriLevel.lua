local UPDATEPERIOD, elapsed = 0.5, 0
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:NewDataObject("iLevel", {type = "data source", text = "Current ilevel: 200"})
local f = CreateFrame("frame")

f:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < UPDATEPERIOD then return end

	elapsed = 0
	local iLevel = GetAverageItemLevel()
	dataobj.text = string.format("Current ilevel: %.1f", iLevel)
end)

function dataobj:OnTooltipShow()
	self:AddLine("Average iLevel")
end

function dataobj:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines()
	dataobj.OnTooltipShow(GameTooltip)
	GameTooltip:Show()
end

function dataobj:OnLeave()
	GameTooltip:Hide()
end
