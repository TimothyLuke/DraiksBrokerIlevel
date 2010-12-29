local UPDATEPERIOD, elapsed = 0.5, 0
local DraiksBrokerDB = LibStub("AceAddon-3.0"):NewAddon("DraiksBrokerDB", "AceEvent-3.0")
local class, classFileName = UnitClass("player");
local f = CreateFrame("frame")
local name = GetUnitName("player", false);
local iLevel = GetAverageItemLevel()
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
 -- Get a reference to the lib
local LibQTip = LibStub('LibQTip-1.0')
local dataobj = ldb:NewDataObject("iLevel", {type = "data source", text = "Current ilevel: 200"})
local L = LibStub("AceLocale-3.0"):GetLocale("DraiksBrokerDB") 


f:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
f:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out


-- Setup Display Fonts
-- Hunter
hunterFont = CreateFont("hunterFont")
hunterFont:SetFont(GameTooltipText:GetFont(), 10)
hunterFont:SetTextColor(RAID_CLASS_COLORS["HUNTER"].r,RAID_CLASS_COLORS["HUNTER"].g,RAID_CLASS_COLORS["HUNTER"].g)

-- Warlock
warlockFont = CreateFont("warlockFont")
warlockFont:SetFont(GameTooltipText:GetFont(), 10)
warlockFont:SetTextColor(RAID_CLASS_COLORS["WARLOCK"].r,RAID_CLASS_COLORS["WARLOCK"].g,RAID_CLASS_COLORS["WARLOCK"].g)

-- Priest
priestFont = CreateFont("priestFont")
priestFont:SetFont(GameTooltipText:GetFont(), 10)
priestFont:SetTextColor(RAID_CLASS_COLORS["PRIEST"].r,RAID_CLASS_COLORS["PRIEST"].g,RAID_CLASS_COLORS["PRIEST"].g)

-- Mage
mageFont = CreateFont("mageFont")
mageFont:SetFont(GameTooltipText:GetFont(), 10)
mageFont:SetTextColor(RAID_CLASS_COLORS["MAGE"].r,RAID_CLASS_COLORS["MAGE"].g,RAID_CLASS_COLORS["MAGE"].g)

-- Paladin
paladinFont = CreateFont("paladinFont")
paladinFont:SetFont(GameTooltipText:GetFont(), 10)
paladinFont:SetTextColor(RAID_CLASS_COLORS["PALADIN"].r,RAID_CLASS_COLORS["PALADIN"].g,RAID_CLASS_COLORS["PALADIN"].g)

-- Shaman
shamanFont = CreateFont("shamanFont")
shamanFont:SetFont(GameTooltipText:GetFont(), 10)
shamanFont:SetTextColor(RAID_CLASS_COLORS["SHAMAN"].r,RAID_CLASS_COLORS["SHAMAN"].g,RAID_CLASS_COLORS["SHAMAN"].g)

-- Druid
druidFont = CreateFont("druidFont")
druidFont:SetFont(GameTooltipText:GetFont(), 10)
druidFont:SetTextColor(RAID_CLASS_COLORS["DRUID"].r,RAID_CLASS_COLORS["DRUID"].g,RAID_CLASS_COLORS["DRUID"].g)

-- deathknight
deathknightFont = CreateFont("warlockFont")
deathknightFont:SetFont(GameTooltipText:GetFont(), 10)
deathknightFont:SetTextColor(RAID_CLASS_COLORS["DEATHKNIGHT"].r,RAID_CLASS_COLORS["DEATHKNIGHT"].g,RAID_CLASS_COLORS["DEATHKNIGHT"].g)

-- Rogue
rogueFont = CreateFont("rogueFont")
rogueFont:SetFont(GameTooltipText:GetFont(), 10)
rogueFont:SetTextColor(RAID_CLASS_COLORS["ROGUE"].r,RAID_CLASS_COLORS["ROGUE"].g,RAID_CLASS_COLORS["ROGUE"].g)

-- Warrior
warriorFont = CreateFont("warlockFont")
warriorFont:SetFont(GameTooltipText:GetFont(), 10)
warriorFont:SetTextColor(RAID_CLASS_COLORS["WARRIOR"].r,RAID_CLASS_COLORS["WARRIOR"].g,RAID_CLASS_COLORS["WARRIOR"].g)

CLASS_FONTS = {
    ["HUNTER"] = hunterFont,
    ["WARLOCK"] = warlockFont,
    ["PRIEST"] = priestFont,
    ["PALADIN"] = paladinFont,
    ["MAGE"] = mageFont,
    ["ROGUE"] = rogueFont,
    ["DRUID"] = druidFont,
    ["SHAMAN"] = shamanFont,
    ["WARRIOR"] = warriorFont,
    ["DEATHKNIGHT"] = deathknightFont,
};



function DraiksBrokerDB:OnInitialize()

    self:RegisterEvent("PARTY_MEMBERS_CHANGED")
    self:RegisterEvent("RAID_ROSTER_UPDATE")

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
			show_coins		   = true,
			refresh_rate               = 20,
			show_class_name            = true,
			colorize_class             = true,
			tooltip_scale		   = 1,
			opacity			   = .9,
			sort_type		   = "alpha",
			use_icons		   = false,
                        display_bars               = false,
			show_level		   = false,
			calculate_own_ilvl	   = false,
			show_party		   = true,
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


   self.db = LibStub("AceDB-3.0"):New("ilvlDB", default_options, true)
   self.faction = UnitFactionGroup("player")
   self.realm = GetRealmName()
   self.pc = UnitName("player")
   if self.db.profile.options.calculate_own_ilvl then
	self.db.global.data[self.faction][self.realm][self.pc].ilvl = CalculateUnitItemLevel(self.pc)    
   else
     	self.db.global.data[self.faction][self.realm][self.pc].ilvl = GetAverageItemLevel()    
   end
   self.db.global.data[self.faction][self.realm][self.pc].level = UnitLevel("player")    
   self.db.global.data[self.faction][self.realm][self.pc].class = classFileName    
   
   local options = {
	name = L["Draiks Broker ILevel"],
	childGroups = 'tab',
	type = 'group',
	order = 1,
	args = {
		display = {
			type = 'group', 
			name = L["Display"], 
			desc = L["Specify what to display"], 
			args = {
				main = {
					type = 'header', 
					name = L["Main Settings"], 
					order     = 1,
				},
				show_level = {
					name      = L["Show Level"],
					desc      = L["Show Character Levels"],
					type      = 'toggle',
					get       = function() return DraiksBrokerDB:GetOption('show_level') end,
					set       = function(info, v) DraiksBrokerDB:SetOption('show_level',v) end,
					order     = 1.1,
				},
				show_party = {
					name      = L["Show Party"],
					desc      = L["Show the ilvl of party and raid members from your server."],
					type      = 'toggle',
					get       = function() return DraiksBrokerDB:GetOption('show_party') end,
					set       = function(info, v) DraiksBrokerDB:SetOption('show_party',v) end,
					order     = 1.2,
				},
				calculate_own_ilvl = {
					name      = L["Calculate Own Average iLevel"],
					desc      = L["Calculate your own average iLevel based on what you have equiped instead of using the Blizzard Reported Average iLevel"],
					type      = 'toggle',
					get       = function() return DraiksBrokerDB:GetOption('calculate_own_ilvl') end,
					set       = function(info, v) DraiksBrokerDB:SetOption('calculate_own_ilvl',v) end,
					order     = 1.3,
				},
				faction_and_realms = {
					type = 'header', 
					name = L["Factions and Realms"], 
					order     = 2,
				},
				all_factions = {
					name      = L["All Factions"],
					desc      = L["All factions will be displayed"],
					type      = 'toggle',
					get       = function() return DraiksBrokerDB:GetOption('all_factions') end,
					set       = function(info, v) DraiksBrokerDB:SetOption('all_factions',v) end,
					order     = 2.1,
				},
				all_realms = {
					name      = L["All Realms"],
					desc      = L["All realms will be displayed"],
					type      = 'toggle',
					get       = function() return DraiksBrokerDB:GetOption('all_realms') end,
					set       = function(info, v) DraiksBrokerDB:SetOption('all_realms',v) end,
					order     = 2.2,
				},
--				sort = {
--					type = 'header', 
--					name = L["Sort Order"], 
--					order = 9,
--				},
--				sort_type = {
--					name      = L["Sort Type"],
--					desc      = L["Select the sort type"],
--					type      = 'select',
--					get       = function() return DraiksBrokerDB:GetOption('sort_type') end,
--					set       = function(info, v) DraiksBrokerDB:SetOption('sort_type',v) end,
--					values  = {
--						["alpha"] 	= L["By Name"],
--						["level"] 	= L["By Level"],
--						["ilvl"]	= L["By Item Level"],
--						["coin"]	= L["By Money"],
--					},
--					order     = 9.1,
--				},
--				reverse_sort = {
--					name      = L["Sort in reverse order"],
--					desc      = L["Use the curent sort type in reverse order"],
--					type      = 'toggle',
--					get       = function() return DraiksBrokerDB:GetOption('reverse_sort') end,
--					set       = function(info, v) DraiksBrokerDB:SetOption('reverse_sort',v) end,
--					order     = 9.2,
--				}
			}
		},
		ignore = {
			name    = L["Ignore Characters"],
			desc    = L["Hide characters from display"],
			type    = 'group',
			args    = {
				realm = {
					name = L["Realm"],
					type = 'description',
					order = .5,
				},
				name = {
					name = L["Character Name"],
					type = 'description',
					order = .7,
				},
			}, 
			order   = 20
		},
		ui = {
			type = 'group', 
			name = L["UI"], 
			desc = L["Set UI options"], 
			args = {
--				tooltip_scale = {
--					name      = L["Scale"],
--					desc      = L["Scale the tooltip (70% to 150%)"],
--					width	  = "full",
--					type      = 'range',
--					min	  = .7,
--					max       = 1.5,
--					step      = .05,
--					isPercent = true,
--					get       = function() return DraiksBrokerDB:GetOption('tooltip_scale') end,
--					set       = function(info, v) DraiksBrokerDB:SetOption('tooltip_scale',v) end,
--					order     = .6,
--				},
--				opacity = {
--					name      = L["Opacity"],
--					desc      = L["% opacity of the tooltip background"],
--					width	  = "full",
--					type      = 'range',
--					min	  = 0,
--					max       = 1,
--					step      = .05,
--					isPercent = true,
--					get       = function() return DraiksBrokerDB:GetOption('opacity') end,
--					set       = function(info, v) DraiksBrokerDB:SetOption('opacity',v) end,
--					order     = .7,
--				},
				display_bars = {
					name      = L["Show Bars"],
					desc      = L["Display Table Rows as colored bars with white text"],
					type      = 'toggle',
					get       = function() return DraiksBrokerDB:GetOption('display_bars') end,
					set       = function(info, v) DraiksBrokerDB:SetOption('display_bars',v) end,
					order     = .7,
				},
			}, 
                        order = 30 
		},

	}
   }   

	-- Ignore section
	local faction_order = 1
	for faction, faction_table in pairs(DraiksBrokerDB.db.global.data) do
		local faction_id = "faction" .. faction_order
		options.args.ignore.args[faction_id] = {
				type 	= 'group', 
				name 	= faction, 
				args	= {},
		}
		faction_order = faction_order + 1
		
		local realm_order = 1
		for realm, realm_table in pairs(faction_table) do
			local realm_id = "realm" .. realm_order
			options.args.ignore.args[faction_id].args[realm_id] = {
				type 	= 'group', 
				name 	= realm, 
				args	= {},
			}
	  	
			local pc_order = 1
			for pc, _ in pairs(realm_table) do
				pc_id = "pc" .. pc_order
				options.args.ignore.args[faction_id].args[realm_id].args[pc_id] = {
					name = pc,
					desc = string.format("Hide %s of %s from display", pc, realm),
					type = 'toggle',
					get  = function() return DraiksBrokerDB:GetOption('is_ignored',realm, pc) end,
					set  = function(info, value) DraiksBrokerDB:SetOption('is_ignored', value, realm, pc) end
				}
				
				pc_order = pc_order + 1
			end
			
			realm_order = realm_order + 1
	  	end
	end

   options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
   local AceConfig = LibStub("AceConfig-3.0")
 
   AceConfig:RegisterOptionsTable(L["Draiks Broker ILevel"], options, {L["dil"], L["draiksbrokerilevel"], L["draiksilvl"], L["draiksilevel"]})


   DraiksBrokerDB.config_menu = options
	
   LibStub("AceConfig-3.0"):RegisterOptionsTable(L["Draiks Broker ILevel"], options)
   DraiksBrokerDB.options_frame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(L["Draiks Broker ILevel"])

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
    if DraiksBrokerDB.db.profile.options.calculate_own_ilvl then
	DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].ilvl = CalculateUnitItemLevel(self.pc)    
    else
     	DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].ilvl = GetAverageItemLevel()    
    end
    DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].level = UnitLevel("player")
    addonLoadedBool = true



end)


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
  tooltip:SetCell(line, 1, L["Character iLevel Breakdown"], "CENTER", 3)
	
  tooltip:AddSeparator()  

    for faction, faction_table in pairs (DraiksBrokerDB.db.global.data) do
	
      if DraiksBrokerDB:GetOption('all_factions') or faction == DraiksBrokerDB.faction then
        if faction == "Horde" then
            tooltip:SetHeaderFont(hordeFont)
        else
            tooltip:SetHeaderFont(allianceFont)
        end
        tooltip:AddHeader(faction)   
        for realm, realm_table in pairs (faction_table) do
          if DraiksBrokerDB:GetOption('all_realms') or realm == DraiksBrokerDB.realm then
            tooltip:SetHeaderFont(green12Font)
            tooltip:AddHeader(realm)

            for pc, pc_table in pairs (realm_table) do
                if not DraiksBrokerDB:GetOption('is_ignored', realm, pc) then
                    local color = RAID_CLASS_COLORS[pc_table.class];
                    --self:AddDoubleLine(pc, string.format("%.1f",pc_table.ilvl), color.r, color.g, color.b, 1, 1, 1) 
                    local line, column = tooltip:AddLine()
                    if DraiksBrokerDB.db.profile.options.display_bars  then 
                        tooltip:SetCell(line, 1, pc, white10Font)
                        tooltip:SetCell(line, 3, string.format("%.1f",pc_table.ilvl), white10font)
                        tooltip:SetLineColor(line, color.r, color.g, color.b)
		        if DraiksBrokerDB.db.profile.options.show_level then
                    	    tooltip:SetCell(line, 2, pc_table.level, white10Font)
                        end 
                    else
                        tooltip:SetCell(line, 1, pc, CLASS_FONTS[pc_table.class])
                        tooltip:SetCell(line, 3, string.format("%.1f",pc_table.ilvl), CLASS_FONTS[pc_table.class])
		        if DraiksBrokerDB.db.profile.options.show_level then
                    	    tooltip:SetCell(line, 2, pc_table.level, CLASS_FONTS[pc_table.class])
                        end 

                    end
                end
            end
          end
        end
        tooltip:AddLine(" ")
      end
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


function DraiksBrokerDB:GetOption( option, ... )

	-- is_ignored has multiple parameters
	if option == 'is_ignored' then
		local realm, name = ...

		return self.db.profile.options.is_ignored[realm][name]

	-- The sort direction is kept in the sort name
	elseif option == 'reverse_sort' then
		if string.find(self.db.profile.options.sort_type, "rev-") == 1 then
			return true
		else
			return false
		end
	elseif option == 'sort_type' then
		if string.find(self.db.profile.options.sort_type, "rev-") == 1 then
			return string.sub(self.db.profile.options.sort_type, 5)
		else
			return self.db.profile.options.sort_type
		end
	elseif option == 'display_sort_type' then
		-- For display, we need the complete thing
		return self.db.profile.options.sort_type
	end


	return self.db.profile.options[option]
end



-- Set an option value
function DraiksBrokerDB:SetOption( option, value, ... )

	local already_set = false

	-- Do we need to recompute the totals?
	if option == 'all_factions' or option == 'all_realms' or option == 'is_ignored' then
		if option == 'is_ignored' then
			local realm, name = ...
			self.db.profile.options.is_ignored[realm][name] = value
		else
			self.db.profile.options[option] = value
		end

		already_set = true
	-- Set the scale of the tooltip
	elseif option == 'tooltip_scale' and self.tooltip then
		self.tooltip:SetScale(value)
	
	-- Set the opacity of the tablet frame
	elseif option == 'opacity' then
		self:SetTTOpacity(value)
		
	-- Ajust the sort type with the direction
	elseif option == 'sort_type' then
	    if self:GetOption('reverse_sort') then
	    	self.db.profile.options.sort_type = "rev-" .. value
	    else
	    	self.db.profile.options.sort_type = value
	    end

	    already_set = true

	-- Modify the direction of the sort
	elseif option == 'reverse_sort' then
		local sort_type
		if self:GetOption('reverse_sort') then
			sort_type = string.sub(self.db.profile.options.sort_type,5)
		else
			sort_type = self.db.profile.options.sort_type
		end

		if value then
			self.db.profile.options.sort_type = "rev-" .. sort_type
		else
			self.db.profile.options.sort_type = sort_type
		end

		already_set = true
        end

	-- Set the value
	if not already_set then
		self.db.profile.options[option] = value
	end

end

function CalculateUnitItemLevel(unit)

	if CanInspect(unit) and CheckInteractDistance(unit, 1) then	
		NotifyInspect(unit)
	
		local t,c=0,0
        	for i =1,18 do 
			if i~=4 then 
				local k=GetInventoryItemLink(unit,i) 
				if k then 
					local iname,_,_,l=GetItemInfo(k) 
					t=t+l 
					c=c+1
                                        print ("Found " .. iname .. ". ilvl: " .. l .. ", total=" .. t .. " Average= " .. t/c)
				end 
			end 
		end 
		if c>0 then 
			--print(t/c)
                        return(t/c)
		end
	end
end




function DraiksBrokerDB:PARTY_MEMBERS_CHANGED(...)
    Scan_Party("party", ...)
end

function DraiksBrokerDB:RAID_ROSTER_UPDATE(...)
    Scan_Party("raid", ...)
end

function Scan_Party(type, ...)
    print("Event Captured of type: ", type)
    if not DraiksBrokerDB.groupformed then
        DraiksBrokerDB.groupformeddate = date("%m/%d/%y %H:%M:%S")
        DraiksBrokerDB.groupformed = true
        print("Setting time to ", DraiksBrokerDB.groupformeddate)
    end
    print("Raid Members: ",  GetNumRaidMembers())
    print("Party Members: ", GetNumPartyMembers())
    print("Real Party Members: ", GetRealNumPartyMembers())
    for i=1, GetNumPartyMembers() do
       print(CalculateUnitItemLevel("party"..i))
       i = i +1
    end
end