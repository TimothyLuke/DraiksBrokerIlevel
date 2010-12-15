local UPDATEPERIOD, elapsed = 0.5, 0
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:NewDataObject("iLevel", {type = "data source", text = "Current ilevel: 200"})
local class, classFileName = UnitClass("player");
local f = CreateFrame("frame")
local name = GetUnitName("player", false);
local iLevel = GetAverageItemLevel()
f:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
f:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out


f:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < UPDATEPERIOD then return end

	elapsed = 0
	iLevel = GetAverageItemLevel()
	dataobj.text = string.format("Current ilevel: %.1f", iLevel)
        addonLoadedBool = true

        if not draiksAddonInitialised  then
         characterclassTable = {}
         characterilevelTable = {}
         characterNameTable = {}
         draiksAddonLoadedBool = false
         draiksAddonInitialised = true
         ConsoleAddMessage("initialised")
        end
        draiksAddonLoadedBool = true
        characterNameTable[name] = name;
        characterilevelTable[name] = iLevel
        characterclassTable[name] = classFileName;
end)

function dataobj:OnTooltipShow()
  if addonLoadedBool then	
    for key,value in pairs(characterNameTable) do
      local color = RAID_CLASS_COLORS[characterclassTable[key]];
      self:AddDoubleLine(characterNameTable[key], characterilevelTable[key], color.r, color.g, color.b, 255, 255, 255);
    end
  else	
    self:AddLine("Loading Characters");
  end
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
