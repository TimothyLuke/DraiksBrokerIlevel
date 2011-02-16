local UPDATEPERIOD, elapsed = 0.5, 0
local DraiksBrokerDB = LibStub("AceAddon-3.0"):NewAddon("DraiksBrokerDB", "AceEvent-3.0", "AceTimer-3.0")
local class, classFileName = UnitClass("player");
local f = CreateFrame("frame")
local name = GetUnitName("player", false);
local iLevel = GetAverageItemLevel()
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local L = LibStub("AceLocale-3.0"):GetLocale("DraiksBrokerDB")
-- Get a reference to the lib
local LibQTip = LibStub('LibQTip-1.0')
local dataobj = ldb:NewDataObject(L["Draiks Broker ILevel"], {type = "data source", text = "ilvl: 200"})

f:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
f:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out

 
-- Setup Display Fonts
-- Hunter
hunterFont = CreateFont("hunterFont")
hunterFont:SetFont(GameTooltipText:GetFont(), 10)
hunterFont:SetTextColor(RAID_CLASS_COLORS["HUNTER"].r,RAID_CLASS_COLORS["HUNTER"].g,RAID_CLASS_COLORS["HUNTER"].b)
 
-- Warlock
warlockFont = CreateFont("warlockFont")
warlockFont:SetFont(GameTooltipText:GetFont(), 10)
warlockFont:SetTextColor(RAID_CLASS_COLORS["WARLOCK"].r,RAID_CLASS_COLORS["WARLOCK"].g,RAID_CLASS_COLORS["WARLOCK"].b)
 
-- Priest
priestFont = CreateFont("priestFont")
priestFont:SetFont(GameTooltipText:GetFont(), 10)
priestFont:SetTextColor(RAID_CLASS_COLORS["PRIEST"].r,RAID_CLASS_COLORS["PRIEST"].g,RAID_CLASS_COLORS["PRIEST"].b)
 
-- Mage
mageFont = CreateFont("mageFont")
mageFont:SetFont(GameTooltipText:GetFont(), 10)
mageFont:SetTextColor(RAID_CLASS_COLORS["MAGE"].r,RAID_CLASS_COLORS["MAGE"].g,RAID_CLASS_COLORS["MAGE"].b)
 
-- Paladin
paladinFont = CreateFont("paladinFont")
paladinFont:SetFont(GameTooltipText:GetFont(), 10)
paladinFont:SetTextColor(RAID_CLASS_COLORS["PALADIN"].r,RAID_CLASS_COLORS["PALADIN"].g,RAID_CLASS_COLORS["PALADIN"].b)
 
-- Shaman
shamanFont = CreateFont("shamanFont")
shamanFont:SetFont(GameTooltipText:GetFont(), 10)
shamanFont:SetTextColor(RAID_CLASS_COLORS["SHAMAN"].r,RAID_CLASS_COLORS["SHAMAN"].g,RAID_CLASS_COLORS["SHAMAN"].b)
 
-- Druid
druidFont = CreateFont("druidFont")
druidFont:SetFont(GameTooltipText:GetFont(), 10)
druidFont:SetTextColor(RAID_CLASS_COLORS["DRUID"].r,RAID_CLASS_COLORS["DRUID"].g,RAID_CLASS_COLORS["DRUID"].b)
 
-- deathknight
deathknightFont = CreateFont("deathknightFont") 
deathknightFont:SetFont(GameTooltipText:GetFont(), 10)
deathknightFont:SetTextColor(RAID_CLASS_COLORS["DEATHKNIGHT"].r,RAID_CLASS_COLORS["DEATHKNIGHT"].g,RAID_CLASS_COLORS["DEATHKNIGHT"].b)
 
-- Rogue
rogueFont = CreateFont("rogueFont")
rogueFont:SetFont(GameTooltipText:GetFont(), 10)
rogueFont:SetTextColor(RAID_CLASS_COLORS["ROGUE"].r,RAID_CLASS_COLORS["ROGUE"].g,RAID_CLASS_COLORS["ROGUE"].b)
 
-- Warrior
warriorFont = CreateFont("warriorFont")
warriorFont:SetFont(GameTooltipText:GetFont(), 10)
warriorFont:SetTextColor(RAID_CLASS_COLORS["WARRIOR"].r,RAID_CLASS_COLORS["WARRIOR"].g,RAID_CLASS_COLORS["WARRIOR"].b)
 
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
                                   class = "",   -- Non Localised class name
                                   level = 0,
                                   ilvl = 0,
                                   last_update = 0,
                              }
                         }
                    },
                    partyData = {
                         -- GUID
                         ['*'] = {
                              -- DateTime
                              ['*'] = {
                                   class = "",   -- Non localised class name
                                   level = 0,
                                   ilvl = 0,
                                   name = 0,
                              }
                         }
                    },
               },
               settings = {
                    addonVersion = 1.5
               },
          },
          profile = {
               options = {
                    all_factions = true,
                    all_realms = true,
                    show_coins = true,
                    refresh_rate = 20,
                    show_class_name = true,
                    colorize_class = true,
                    tooltip_scale = 1,
                    opacity = .9,
                    sort_type = "alpha",
                    use_icons = false,
                    display_bars = false,
                    show_level = false,
                    calculate_own_ilvl = false,
                    show_party = true,
                    save_externals = true,
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
                    group = {
                         formedDate = nil,
                         active = false,
                         type = nil
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
     self.db.global.data[self.faction][self.realm][self.pc].key = UnitGUID("player")
 
     self.sort_table = {}
     self.scanqueue = {}
     self.partyName = {}
     self.partyClass = {}
     self.partyLevel = {}
     self.partyiLvl = {}

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
                              order = 1,
                         },
                         show_level = {
                              name = L["Show Level"],
                              desc = L["Show Character Levels"],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('show_level') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('show_level',v) end,
                              order = 1.1,
                         },
                         calculate_own_ilvl = {
                              name = L["Calculate Own Average iLevel"],
                              desc = L["Calculate your own average iLevel based on what you have equiped instead of using the Blizzard Reported Average iLevel"],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('calculate_own_ilvl') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('calculate_own_ilvl',v) end,
                              order = 1.2,
                         },
                         display_bars = {
                              name = L["Show Bars"],
                              desc = L["Display Table Rows as colored bars with white text"],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('display_bars') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('display_bars',v) end,
                              order = 1.3,
                         },
                         faction_and_realms = {
                              type = 'header',
                              name = L["Factions and Realms"],
                              order = 2,
                         },
                         all_factions = {
                              name = L["All Factions"],
                              desc = L["All factions will be displayed"],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('all_factions') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('all_factions',v) end,
                              order = 2.1,
                         },
                         all_realms = {
                              name = L["All Realms"],
                              desc = L["All realms will be displayed"],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('all_realms') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('all_realms',v) end,
                              order = 2.2,
                         },
                         group_raid = {
                              type = 'header',
                              name = L["Group and Raid Options"],
                              order = 3,
                         },
                         show_party = {
                              name = L["Show Party"],
                              desc = L["Show the ilvl of party and raid members from your server."],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('show_party') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('show_party',v) end,
                              order = 3.1,
                         },
                         save_party = {
                              name = L["Save Party"],
                              desc = L["Save the ilvl of party and raid members from your server."],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('save_externals') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('save_externals',v) end,
                              order = 3.2,
                         },
                         sort = {
                              type = 'header',
                              name = L["Sort Order"],
                              order = 9,
                         },
                         sort_type = {
                              name = L["Sort Type"],
                              desc = L["Select the sort type"],
                              type = 'select',
                              get = function() return DraiksBrokerDB:GetOption('sort_type') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('sort_type',v) end,
                              values  = {
                                   ["alpha"]   = L["By Name"],
                                   ["level"]   = L["By Level"],
                                   ["ilvl"]    = L["By Item Level"],
                              },
                              order     = 9.1,
                         },
                         reverse_sort = {
                              name = L["Sort in reverse order"],
                              desc = L["Use the curent sort type in reverse order"],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('reverse_sort') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('reverse_sort',v) end,
                              order = 9.2,
                         }
                    }
               },
               ignore = {
                    name = L["Ignore Characters"],
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
          },
     }
 
 
     -- Ignore section
     local faction_order = 1
     for faction, faction_table in pairs(DraiksBrokerDB.db.global.data) do
 
          local faction_id = "faction" .. faction_order
          options.args.ignore.args[faction_id] = {
               type    = 'group',
               name    = formatFaction(faction),
               args    = {},
          }
          faction_order = faction_order + 1
 
          local realm_order = 1
          for realm, realm_table in pairs(faction_table) do
               local realm_id = "realm" .. realm_order
               options.args.ignore.args[faction_id].args[realm_id] = {
                    type    = 'group',
                    name    = formatRealm(faction, realm),
                    args    = {},
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
 
     -- Check if already in party
     if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
          if self.db.profile.options.group.active then
               self.db.profile.options.group.active = false
               --print("Group party formed :" .. self.db.profile.options.group.formedDate)
          end
     end
 
     -- setup the timer to run every 10 seconds
     self.queueTimer = self:ScheduleRepeatingTimer("TimerQueue", 10)
 
end
 
function formatFaction(faction)
    if faction == "partyData" then
        faction = "Other Player Characters"
    end
    return faction
end
 
function formatRealm(faction,realm)
    returnval = realm
    if faction == "partyData" then
        for  _, raid_table in pairs(DraiksBrokerDB.db.global.data.partyData[realm]) do
            returnval = raid_table.name
        end
    end
    return returnval
end
 
f:SetScript("OnUpdate", function(self, elap)
     elapsed = elapsed + elap
     if elapsed < UPDATEPERIOD then return end
 
 
     elapsed = 0
     iLevel = GetAverageItemLevel()
     self.faction = UnitFactionGroup("player")
     self.realm = GetRealmName()
     self.pc = UnitName("player")
     DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].ilvl = iLevel
     if not draiksAddonInitialised then
          ilevelDB = {}
          draiksAddonInitialised = true
     end
     
     if DraiksBrokerDB.db.profile.options.calculate_own_ilvl then
          DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].ilvl = CalculateUnitItemLevel(self.pc)
     end
     DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].level = UnitLevel("player")
     dataobj.text = string.format("ilvl: %.1f", DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].ilvl)

     addonLoadedBool = true
 
 
 
end)
 
 
function dataobj:OnEnter()
     -- Acquire a tooltip with 3 columns, respectively aligned to left, center and right
     local tooltip = LibQTip:Acquire("DraiksBrokerDB", 3, "LEFT", "CENTER", "RIGHT")
     self.tooltip = tooltip
 
     tooltip:Clear()
 
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
     names = {}
     tooltip:AddSeparator()
 
     for faction, faction_table in pairs (DraiksBrokerDB.db.global.data) do
          if DraiksBrokerDB:GetOption('all_factions') or faction == DraiksBrokerDB.faction  then
               if faction ~= "partyData" then
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
                              DraiksBrokerDB:FetchOrderedNames(names, realm_table)
                              for _,name in ipairs (names) do
                                   if not DraiksBrokerDB:GetOption('is_ignored', realm, name) then
                                        local line, column = tooltip:AddLine()
                                        if DraiksBrokerDB.db.profile.options.display_bars  then
                                             color = RAID_CLASS_COLORS[DraiksBrokerDB.db.global.data[faction][realm][name].class]
                                             tooltip:SetCell(line, 1, name, white10Font)
                                             tooltip:SetCell(line, 3, string.format("%.1f", DraiksBrokerDB.db.global.data[faction][realm][name].ilvl), white10font)
                                             tooltip:SetLineColor(line, color.r, color.g, color.b)
                                             if DraiksBrokerDB.db.profile.options.show_level then
                                                  tooltip:SetCell(line, 2, DraiksBrokerDB.db.global.data[faction][realm][name].level, white10Font)
                                             end
                                        else
                                             tooltip:SetCell(line, 1, name, CLASS_FONTS[DraiksBrokerDB.db.global.data[faction][realm][name].class])
                                             tooltip:SetCell(line, 3, string.format("%.1f",DraiksBrokerDB.db.global.data[faction][realm][name].ilvl), CLASS_FONTS[DraiksBrokerDB.db.global.data[faction][realm][name].class])
                                             if DraiksBrokerDB.db.profile.options.show_level then
                                                  tooltip:SetCell(line, 2, DraiksBrokerDB.db.global.data[faction][realm][name].level, CLASS_FONTS[DraiksBrokerDB.db.global.data[faction][realm][name].class])
                                             end
                                        end
                                   end
                              end
                         end
                    end
                    tooltip:AddLine(" ")
               end
          end
     end
     
     -- Party Ilevel
      if DraiksBrokerDB:GetOption('show_party') and DraiksBrokerDB.db.profile.options.group.active then
          tooltip:AddSeparator()
          tooltip:SetHeaderFont(green12Font)
          tooltip:AddHeader(L["Current Group"])
         if DraiksBrokerDB.locals == true then
          for GUID,pc_table in pairs (DraiksBrokerDB.db.global.data.partyData) do
             for formedDate, resttable in pairs(pc_table) do
              if formedDate == DraiksBrokerDB.db.profile.options.group.formedDate then
               --print(resttable.name)

               if check_player_in_group(resttable.name) then
                 local line, column = tooltip:AddLine()
                 if DraiksBrokerDB.db.profile.options.display_bars  then
                      color = RAID_CLASS_COLORS[resttable.class]
                      tooltip:SetCell(line, 1, resttable.name, white10Font)
                      tooltip:SetCell(line, 3, string.format("%.1f", resttable.ilvl), white10font)
                     -- print (GUID)
                      --print (resttable.class)
                      tooltip:SetLineColor(line, color.r, color.g, color.b)
                      if DraiksBrokerDB.db.profile.options.show_level then
                           tooltip:SetCell(line, 2, resttable.level, white10Font)
                      end
                     else
                      tooltip:SetCell(line, 1, resttable.name, CLASS_FONTS[DraiksBrokerDB.db.global.data.partyData[GUID][DraiksBrokerDB.db.profile.options.group.formedDate].class])
                      tooltip:SetCell(line, 3, string.format("%.1f",resttable.ilvl), CLASS_FONTS[DraiksBrokerDB.db.global.data.partyData[GUID][DraiksBrokerDB.db.profile.options.group.formedDate].class])
                      if DraiksBrokerDB.db.profile.options.show_level then
                           tooltip:SetCell(line, 2, resttable.level, CLASS_FONTS[DraiksBrokerDB.db.global.data.partyData[GUID][DraiksBrokerDB.db.profile.options.group.formedDate].class])
                      end
                    end
                 end
               end
             end
          end
        end
  
        if DraiksBrokerDB.foreigners == true then
          -- SHow foreigners from RAM but not saved
          for theirName,_ in pairs(DraiksBrokerDB.partyName) do
            if check_player_in_group(theirName) then
               --print ("Found :" .. theirName)
               local line, column = tooltip:AddLine()
               if DraiksBrokerDB.db.profile.options.display_bars  then
                    color = RAID_CLASS_COLORS[DraiksBrokerDB.partyClass[theirName]]
                    tooltip:SetCell(line, 1, theirName, white10Font)
                    tooltip:SetCell(line, 3, string.format("%.1f", DraiksBrokerDB.partyiLvl[theirName]), white10font)
                    tooltip:SetLineColor(line, color.r, color.g, color.b)
                    if DraiksBrokerDB.db.profile.options.show_level then
                         tooltip:SetCell(line, 2, DraiksBrokerDB.partyLevel[theirName], white10Font)
                    end
               else
                    tooltip:SetCell(line, 1, theirName, CLASS_FONTS[DraiksBrokerDB.partyClass[theirName]])
                    tooltip:SetCell(line, 3, string.format("%.1f",DraiksBrokerDB.partyiLvl[theirName]), CLASS_FONTS[DraiksBrokerDB.partyClass[theirName]])
                    if DraiksBrokerDB.db.profile.options.show_level then
                         tooltip:SetCell(line, 2, DraiksBrokerDB.partyLevel[theirName], CLASS_FONTS[DraiksBrokerDB.partyClass[theirName]])
                    end
               end
            end
          end
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
 
 
    return self.db.profile.options[option] end
 
 
 
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
 
function DraiksBrokerDB:FetchOrderedNames(names, characters)
    wipe(names)
    for name, name_table in pairs(characters) do
        table.insert(names, name)
    end
    DraiksBrokerDB.sort_table = characters
        if self.db.profile.options.sort_type == "alpha" then
        table.sort(names)
    elseif self.db.profile.options.sort_type == "rev-alpha" then
        table.sort(names, revAlphaSort)
    elseif self.db.profile.options.sort_type == "rev-level" then
        table.sort(names, revlevelSort)
    elseif self.db.profile.options.sort_type == "level" then
        table.sort(names, levelSort)
    elseif self.db.profile.options.sort_type == "rev-ilvl" then
        table.sort(names, revilvlSort)
    elseif self.db.profile.options.sort_type == "ilvl" then
        table.sort(names, ilvlSort)
    end
end
 
 
 
function revAlphaSort(a,b)
    return b < a
end
 
function revlevelSort(a,b)
  return DraiksBrokerDB.sort_table[b].level < DraiksBrokerDB.sort_table[a].level
end
 
function levelSort(a,b)
  return DraiksBrokerDB.sort_table[a].level < DraiksBrokerDB.sort_table[b].level
end
 
function revilvlSort(a,b)
  return DraiksBrokerDB.sort_table[b].ilvl < DraiksBrokerDB.sort_table[a].ilvl end
 
function ilvlSort(a,b)
  return DraiksBrokerDB.sort_table[a].ilvl < DraiksBrokerDB.sort_table[b].ilvl end
 
 
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
                    --print ("Found " .. iname .. ". ilvl: " .. l .. ", total=" .. t .. " Average= " .. t/c)
                end
            end
        end
        ClearInspectPlayer()
        if c>0 then
            --print(t/c)
            return(t/c)
        end
    end
end
 
 
 
 
function DraiksBrokerDB:PARTY_MEMBERS_CHANGED(...)
  
   if GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then
     if not self.db.profile.options.group.active then
        self.db.profile.options.group.formedDate = date("%y/%m/%d %H:%M:%S")
        self.db.profile.options.group.type = "group"
        self.db.profile.options.group.active = true
        --print("Group party formed :" .. self.db.profile.options.group.formedDate)
     else
    --print("Already in party formed :" .. self.db.profile.options.group.formedDate)
     end
   else
    self.db.profile.options.group.active = false
    DraiksBrokerDB.locals = false
    DraiksBrokerDB.foreigners = false
    zap(DraiksBrokerDB.partyClass)
    zap(DraiksBrokerDB.partyName)
    zap(DraiksBrokerDB.partyLevel )
    zap(DraiksBrokerDB.partyiLvl)

        --print("Group formed :" .. self.db.profile.options.group.formedDate .. " Disbanded")
   end
   if self.db.profile.options.group.type == "group" then
      -- if we're in a raid the raid roster event will handle things
       --print ("Starting Scan")
       Scan_Party("party", GetNumPartyMembers())
   end
end
 
function DraiksBrokerDB:RAID_ROSTER_UPDATE(...)
   if  self.db.profile.options.group.type == "group" then
       -- we've been changed into a raid
       self.db.profile.options.group.type = "raid"
   end
 
   if GetNumRaidMembers() > 0 then
     if not self.db.profile.options.group.active then
        self.db.profile.options.group.formedDate = date("%y/%m/%d %H:%M:%S")
        self.db.profile.options.group.type = "raid"
        self.db.profile.options.group.active = true
        --print("Raid party formed :" .. self.db.profile.options.group.formedDate)
     else
    --print("Already in party formed :" .. self.db.profile.options.group.formedDate)
     end
   else
    self.db.profile.options.group.active = false
                    DraiksBrokerDB.locals = false
    zap(DraiksBrokerDB.partyClass)
    zap(DraiksBrokerDB.partyName)
    zap(DraiksBrokerDB.partyLevel )
    zap(DraiksBrokerDB.partyiLvl)
               DraiksBrokerDB.foreigners = false

        --print("Raid formed :" .. self.db.profile.options.group.formedDate .. " Disbanded")
   end 
 
   Scan_Party("raid", GetNumRaidMembers())
end
 
function Scan_Party(type, numMembers)
    --print("Event Captured of type: ", type)
    --print("Raid Members: ",  GetNumRaidMembers())
    --print("Party Members: ", GetNumPartyMembers())
    --print("Real Party Members: ", GetRealNumPartyMembers())
    for i=1, numMembers do
     table.insert(DraiksBrokerDB.scanqueue, type..i)
     --print("adding " .. type..i .. "to queue")
     --ScanUnit(type..i)
     i = i +1
    end
end
 
function Scan_Unit(unit)
     returnval = false
     if CanInspect(unit) and CheckInteractDistance(unit, 1) then
        local class_loc, class = UnitClass(unit)
        local theirName = GetUnitName(unit)
        local theiriLvl = CalculateUnitItemLevel(unit)
        local theirLevel = UnitLevel(unit)
        --print("Found " .. theirName  .." with average ilevel of " .. theiriLvl)
        local theirGUID = UnitGUID(unit)
       if UnitIsSameServer(unit, "player") and DraiksBrokerDB:GetOption('save_externals') then   --Only save units from my server
 
        --if DraiksBrokerDB.db.global.data.partyData[theirGUID][DraiksBrokerDB.db.profile.options.group.formedDate].ilvl = 0 then
                DraiksBrokerDB.db.global.data.partyData[theirGUID][DraiksBrokerDB.db.profile.options.group.formedDate].class =  class
                DraiksBrokerDB.db.global.data.partyData[theirGUID][DraiksBrokerDB.db.profile.options.group.formedDate].name =  theirName
                DraiksBrokerDB.db.global.data.partyData[theirGUID][DraiksBrokerDB.db.profile.options.group.formedDate].level =  theirLevel
                if theiriLvl > DraiksBrokerDB.db.global.data.partyData[theirGUID][DraiksBrokerDB.db.profile.options.group.formedDate].ilvl then
                    DraiksBrokerDB.db.global.data.partyData[theirGUID][DraiksBrokerDB.db.profile.options.group.formedDate].ilvl =  theiriLvl
                end
                -- I have them take them out of the queue
                returnval = true
                DraiksBrokerDB.locals = true
        --end
       else
               --print("Added " .. theirName .. " to local table.")
               DraiksBrokerDB.partyClass[theirName] =  class
               DraiksBrokerDB.partyLevel[theirName] =  theirLevel
               DraiksBrokerDB.partyiLvl[theirName] =  theiriLvl
               DraiksBrokerDB.partyName[theirName] =  theirName
               
                -- I have them take them out of the queue
               returnval = true
               DraiksBrokerDB.foreigners = true
       end
      end
     return returnval
end
 
function DraiksBrokerDB:TimerQueue()
 
    for i,v in ipairs(DraiksBrokerDB.scanqueue) do
       --print ("about to scan unit " .. v)
       if not UnitAffectingCombat("player") then
          if Scan_Unit(v) then
                table.remove(DraiksBrokerDB.scanqueue, i)
          end
        end
    end
    --print("Num Units in queue: ", # DraiksBrokerDB.scanqueue)
end

function zap(table)
    local next = next
    local k = next(table)
    while k do
        table[k] = nil
        k = next(table)
    end
end

function check_player_in_group(name)
    local found = false
    -- if its you skip it
    if name ~= DraiksBrokerDB.pc then
       -- loop party members
       for i=1, GetNumPartyMembers() do
            if GetUnitName("party" .. i) == name then
              found = true
           end
       end



       -- loop raid members
       for i=1, GetNumRaidMembers() do
           if GetUnitName("raid" .. i) == name then
              found = true
           end
       end
    end
    return found
end