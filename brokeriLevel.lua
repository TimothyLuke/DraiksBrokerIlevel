local UPDATEPERIOD, elapsed = 0.5, 0
local DraiksBrokerDB = LibStub("AceAddon-3.0"):NewAddon("DraiksBrokerDB")
local class, classFileName = UnitClass("player");
local f = CreateFrame("frame")
local name = GetUnitName("player", false);
local iLevel = GetAverageItemLevel()
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
 -- Get a reference to the lib
local LibQTip = LibStub('LibQTip-1.0')
local dataobj = ldb:NewDataObject("iLevel", {type = "data source", text = "Current ilevel: 200"})
 

f:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
f:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out

RAID_FONTS = {
    ["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45 },
    ["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79 },
    ["PRIEST"] = { r = 1.0, g = 1.0, b = 1.0 },
    ["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73 },
    ["MAGE"] = { r = 0.41, g = 0.8, b = 0.94 },
    ["ROGUE"] = { r = 1.0, g = 0.96, b = 0.41 },
    ["DRUID"] = { r = 1.0, g = 0.49, b = 0.04 },
    ["SHAMAN"] = { r = 0.0, g = 0.44, b = 0.87 },
    ["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43 },
    ["DEATHKNIGHT"] = { r = 0.77, g = 0.12 , b = 0.23 },
};




function DraiksBrokerDB:OnInitialize()

    -- Default values for the save variables
    default_options = {
	global = {
		data = {
			-- Faction
			['*'] = {
				-- Realm
				['*'] = {
					-- Name
					['*'] = {
						class                      = "",   -- English class name
						level                      = 0,
						ilvl                       = 0,
						last_update                = 0,
					}
				}
			}
		},
                settings = {
                        addonVersion = 1
                },
	},
	profile = {
		options = {
			all_factions               = true,
			all_realms                 = true,
			show_coins						= true,
			refresh_rate               = 20,
			show_class_name            = true,
			colorize_class             = true,
			tooltip_scale					= 1,
			opacity							= .9,
			sort_type						= "alpha",
			use_icons						= false,
			is_ignored = {
				-- Realm
				['*'] = {
					-- Name
					['*'] = false,
				},
			},
			ldbicon = {
			  hide = nil,
			},
		},
	},
   }


   self.db = LibStub("AceDB-3.0"):New("ilvlDB", default_options)
   self.faction = UnitFactionGroup("player")
   self.realm = GetRealmName()
   self.pc = UnitName("player")
   self.db.global.data[self.faction][self.realm][self.pc].ilvl = GetAverageItemLevel()    
   self.db.global.data[self.faction][self.realm][self.pc].level = UnitLevel("player")    
   self.db.global.data[self.faction][self.realm][self.pc].class = classFileName    
end

f:SetScript("OnUpdate", function(self, elap)
    elapsed = elapsed + elap
    if elapsed < UPDATEPERIOD then return end


    elapsed = 0
    iLevel = GetAverageItemLevel()
    self.faction = UnitFactionGroup("player")
    self.realm = GetRealmName()
    self.pc = UnitName("player")

    if not draiksAddonInitialised then
        ilevelDB = {}
        draiksAddonInitialised = true
    end

    dataobj.text = string.format("ilvl: %.1f", DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].ilvl) 
    DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].ilvl = GetAverageItemLevel()
    DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].level = UnitLevel("player")
    addonLoadedBool = true
end)

--function dataobj:OnTooltipShow()

--end


function dataobj:OnEnter()
  
  -- Acquire a tooltip with 3 columns, respectively aligned to left, center and right
  local tooltip = LibQTip:Acquire("DraiksBrokerDB", 3, "LEFT", "CENTER", "RIGHT")
  self.tooltip = tooltip 

    -- New font looking like GameTooltipText but White with height 12
    local white10Font = CreateFont("white10Font")
    white10Font:SetFont(GameTooltipText:GetFont(), 10)
    white10Font:SetTextColor(1,1,1)
  
    -- New font looking like White15font but with height 14
    local white14Font = CreateFont("white14Font")
    white14Font:CopyFontObject(white10Font)
    white14Font:SetFont(white14Font:GetFont(), 14)

    local hordeFont = CreateFont("hordeFont")
    hordeFont:CopyFontObject(white10Font)
    hordeFont:SetTextColor(1,0,0)
    hordeFont:SetFont(hordeFont:GetFont(), 14)

    local allianceFont = CreateFont("allianceFont")
    allianceFont:CopyFontObject(white10Font)
    allianceFont:SetTextColor(0,0,1)
    allianceFont:SetFont(allianceFont:GetFont(), 14)

    -- New font looking like GameTooltipText but White with height 15
    local green12Font = CreateFont("green12Font")
    green12Font:SetFont(GameTooltipText:GetFont(), 12)
    green12Font:SetTextColor(0,1,0)



  tooltip:SetFont(white10Font)
  tooltip:SetHeaderFont(white14Font)


   
  -- Add an header filling only the first two columns
  local line, column = tooltip:AddHeader()
  tooltip:SetCell(line, 1, "Character iLevel Breakdown", "CENTER", 3)
	
  tooltip:AddSeparator()  

    for faction, faction_table in pairs (DraiksBrokerDB.db.global.data) do
	if faction == "Horde" then
            tooltip:SetHeaderFont(hordeFont)
        else
            tooltip:SetHeaderFont(allianceFont)
        end
        tooltip:AddHeader(faction)   
        for realm, realm_table in pairs (faction_table) do
            tooltip:SetHeaderFont(green12Font)
            tooltip:AddHeader(realm)

            for pc, pc_table in pairs (realm_table) do
                local color = RAID_CLASS_COLORS[pc_table.class];
                --self:AddDoubleLine(pc, string.format("%.1f",pc_table.ilvl), color.r, color.g, color.b, 1, 1, 1) 
                --local classFont = CreateFont("classFont")
                --classFont:CopyFontObject(white10Font)
                --classFont:SetTextColor(color.r, color.g, color.b)
                --classFont:SetFont(classFont:GetFont(), 10)
                local line, column = tooltip:AddLine()
                tooltip:SetCell(line, 1, pc, white10Font)
                tooltip:SetCell(line, 3, string.format("%.1f",pc_table.ilvl), white10font)
                tooltip:SetLineColor(line, color.r, color.g, color.b)
                classFont = nil
            end
        end
        tooltip:AddLine(" ")
    end






  
   -- Use smart anchoring code to anchor the tooltip to our frame
   tooltip:SmartAnchorTo(self)
   
   -- Show it, et voilà !
   tooltip:Show()



end



function dataobj:OnLeave()
   
   -- Release the tooltip
   LibQTip:Release(self.tooltip)
   self.tooltip = nil
end
