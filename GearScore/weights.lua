--local AceLocale = LibStub("AceLocale-3.0")
--local L = AceLocale:GetLocale( "GearScore" )

function GearScoreClassScan(Name)

	GS_WeightsTips = {}
	PlayersSumBonuses = {}; local TotalStats = 0; local SumStats = 0; local FinalTable = {}; local SumTotalStats = 0; local TitanGrip = 0; local MissingEnchantTable = {}; 
	local MissingGemCount = 0; GS_MissingGemWeightsTips = nil; local TenStatCount = 0;
	local MetaGemMissing, RedGemMissing, BlueGemMissing, YellowGemMissing = 0,0,0,0
	if ( GS_Data[GetRealmName()].Players[Name] ) or LookAtCurrentTarget then
		if UnitName("target") == Name then
			for i = 1, 18 do
				local ItemSubStringTable = {}
			   	if ( i ~= 4 ) and ( GetInventoryItemLink("target", i) ) then
					local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(GetInventoryItemLink("target", i))
					if ( ItemLink ) then
					
						--MetaGemMissing, RedGemMissing, BlueGemMissing, YellowGemMissing = BonusScanner:GetEmptySockets(ItemLink)
						MetaGemMissing, RedGemMissing, BlueGemMissing, YellowGemMissing = 0, 0, 0, 0
						MissingGemCount = MissingGemCount + MetaGemMissing + RedGemMissing + BlueGemMissing + YellowGemMissing	
							
						if ( MetaGemMissing > 0 ) or ( BlueGemMissing > 0 ) or ( YellowGemMissing > 0 ) or ( RedGemMissing > 0 )then 
							if not GS_MissingGemWeightsTips then GS_MissingGemWeightsTips = {}; end
							GS_MissingGemWeightsTips[1] = {[1] = "Missing "..MissingGemCount.." gems.", [2] = " "}
							table.insert(GS_MissingGemWeightsTips, {[1] = "|cffffffff     "..string.sub(ItemEquipLoc, 9), [2]  = "|cffff0000-"..( MetaGemMissing + RedGemMissing + BlueGemMissing + YellowGemMissing ).."%" })
						end
						local found, _, ItemSubString = string.find(ItemLink, "^|c%x+|H(.+)|h%[.*%]");

						if string.find(ItemSubString, ":3879:") then TenStatCount = TenStatCount + 1; end
						if string.find(ItemSubString, ":3832:") then TenStatCount = TenStatCount + 1; end

						for v in string.gmatch(ItemSubString, "[^:]+") do tinsert(ItemSubStringTable, v); end
						ItemSubString = ItemSubStringTable[2]..":"..ItemSubStringTable[3], ItemSubStringTable[2]
						local StringStart, StringEnd = string.find(ItemSubString, ":") 
						ItemSubString = string.sub(ItemSubString, StringStart + 1)
			
						if ( ItemSubString == "0" ) and ( GS_ItemTypes[ItemEquipLoc]["Enchantable"] )then
							 table.insert(MissingEnchantTable, ItemEquipLoc)
						end
						--local GS_TempBonuses = BonusScanner:ScanItem(ItemLink)
						local GS_TempBonuses = {}
    					if GS_TempBonuses then
							for i,v in pairs(GS_TempBonuses) do
								if ( PlayersSumBonuses[i] ) then PlayersSumBonuses[i] = PlayersSumBonuses[i] + v else PlayersSumBonuses[i] = v; end
							end
						end
					end
				end
			end
		else
			for i = 1, 18 do
			   	if ( i ~= 4 ) and ( GS_Data[GetRealmName()].Players[Name].Equip[i] ) then
			        local SubLink = GS_Data[GetRealmName()].Players[Name].Equip[i]
		        	SubLink = (string.sub(SubLink, 1, (string.find(SubLink, ":")) - 1))
					local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo("item:"..SubLink)
					if ( ItemLink ) then
						--local GS_TempBonuses = BonusScanner:ScanItem(ItemLink)
						local GS_TempBonuses = {}
    					if GS_TempBonuses then
							for i,v in pairs(GS_TempBonuses) do
								if ( PlayersSumBonuses[i] ) then PlayersSumBonuses[i] = PlayersSumBonuses[i] + v else PlayersSumBonuses[i] = v; end
							end
						end
					end
				end
			end
		end
		
		--if ( UnitName("target") or " " ) == Name then end 		
 		local SumTotalStats = 0
		----------------------------
		GS_DatabaseFrame.tooltip = nil
		local tooltip = LibQTip:Acquire("GearScoreTooltip", 2, "RIGHT", "LEFT")
		tooltip:SetCallback("OnMouseUp", GearScore_DatabaseOnClick)
		GS_DatabaseFrame.tooltip = tooltip
		tooltip:SetPoint("TOPLEFT", GS_DisplayFrame, 30, -180)
		tooltip:SetPoint("TOPRIGHT", GS_DisplayFrame, -370, -180)
 	   	tooltip:SetFrameStrata("DIALOG")
		tooltip:SetAlpha(100)
		tooltip:SetScale(1)
 		-------------------------------
		for i,v in pairs(PlayersSumBonuses) do
			if PlayersSumBonuses[i] == 0 then PlayersSumBonuses[i] = nil; end
			if PlayersSumBonuses and not ( string.find(i, "DPS") ) then tooltip:AddLine("+"..PlayersSumBonuses[i], i); end
			if GearScoreClassStats[i] then PlayersSumBonuses[i] = PlayersSumBonuses[i] * GearScoreClassStats[i]; else PlayersSumBonuses[i] = nil; end
			if ( PlayersSumBonuses[i] ) then SumTotalStats = SumTotalStats + PlayersSumBonuses[i];end
		end
		tooltip:UpdateScrolling(180)
		tooltip:SetHeight(180)
		if not GS_ExPFrame:IsVisible() then tooltip:Show(); end
		
		GS_MissingEnchantWeightsTips = nil
		
		if ( #MissingEnchantTable ) > 0 then 
			if not GS_MissingEnchantWeightsTips then GS_MissingEnchantWeightsTips = {}; end
			table.insert(GS_MissingEnchantWeightsTips, {[1] = " ", [2]  = " "}); 
			table.insert(GS_MissingEnchantWeightsTips, {[1] = "Missing "..#MissingEnchantTable.." enchantments:", [2]  = ""})
			for i,v in ipairs(MissingEnchantTable) do
				table.insert(GS_MissingEnchantWeightsTips, {[1] = "|cffffffff     "..string.sub(v, 9), [2]  = "|cffff0000"..( floor((-2 * ( GS_ItemTypes[v]["SlotMOD"] )) * 100) / 100 ).."%" });
			end
		end
	end
end

GearScoreClassSpecList = {
	["SHAMAN"] = {[1] = "Elemental",[2] = "Enhancement",[3] = "Restoration",},
	["ShamanCustomWeights"] = {[1] = "Elemental",[2] = "Enhancement",[3] = "Restoration",},
	["MAGE"] = {[1] = "Arcane",[3] = "Frost",[2] = "Fire",},
	["ROGUE"] = {[1] = "Combat",[2] = "Assassination",[3] = "Subtlety",},
	["HUNTER"] = {[1] = "Marksmanship",[2] = "Beast Mastery",[3] = "Survival",},
	["DRUID"] = {[1] = "Balance",[2] = "Feral (DPS)",[3] = "Feral (Tank)",[4] = "Restoration",},
	["WARLOCK"] = {[1] = "Affliction",[2] = "Demonology",[3] = "Destruction",},
	["WARRIOR"] = {[1] = "Arms",[2] = "Fury",[3] = "Protection",},
	["DEATHKNIGHT"] = {[1] = "Blood (DPS)",[2] = "Unholy (DPS)",[3] = "Frost (DPS)",[4] = "Tanking",},
	["PRIEST"] = {[1] = "Discipline",[2] = "Holy",[3] = "Shadow",},
	["PALADIN"] = {[1] = "Holy",[2] = "Protection",[3] = "Retribution",},
}

GearScoreSpecWeights = {
	["PALADIN"] = {
		[1] = {--Holy
			["HASTE"] = 1,
			["SPELLPOW"] = 1,
			["CRIT"] = 1,
			["INT"] = 1,
			["ATTACKPOWER"] = 0,
			["BLOCKVALUE"] = 1,
			["MANAREG"] = 1,
			["SPI"] = 1,
			["STA"] = 1,
		},
		[2] = {--Protection
			["DEFENSE"] = 1,
			["DEFENSECAP"] = { [1] = { ["Minimum Bonus Defense Skill"] = "+140" }, [3] = { ["Resilience (Stat)"] = "XXX" } },
			["STR"] = 1,
			["AGI"] = 1,
			["BLOCK"] = 1,
			["DODGE"] = 1,
			["STA"] = 1,
			["PARRY"] = 1,
			["EXPERTISE"] = 1,
			["BLOCKVALUE"] = 1,
			["TOHIT"] = 1,
			["ATTACKPOWER"] = 1,
			["CRIT"] = 1,
			["SPELLPOW"] = 1,
			["STA"] = 1,
			["SPI"] = 1
		},
		[3] = {
			["STR"] = 1,
			["SPI"] = 1,
			["CRIT"] = 1,
			["ARMORPEN"] = 1,
			["AGI"] = 1,
			["TOHIT"] = 1,
			["EXPERTISE"] = 1,
			["HASTE"] = 1,
			["ATTACKPOWER"] = 1,
			["SPELLPOW"] = 1,
			["TOHITMIN"] = 263,
			["HITCAP"] = {[1] = { ["Minimum Hit Rating"] = "8.00%" }, [3] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 229.53,
			["CAPRATIO"] = 32.79,
			["STA"] = 1,
		},
	},
	["DRUID"] = {
		[1] = {--Balance
			["TOHIT"] = 1,
			["SPELLPOW"] = 1,
			["HASTE"] = 1,
			["CRIT"] = 1,
			["SPI"] = 1,
			["MANAREG"] = 1,
			["INT"] = 1,
			["ATTACKPOWER"] = 0,
			["HITCAP"] = {[1] = { ["Required Hit Rating"] = "17.00%" }, [3] = { ["Balance of Power (Talent)"] = "+4.00%" }, [4] = { ["Improved Faerie Fire (Talent + Spell)"] = "+3.00%" }, [5] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 236.07,
			["CAPRATIO"] = 26.23,
			["OVERHITCAP"] = 1,
			["STA"] = 1,
		},
		[2] = {--Feral (DPS)
			["STR"] = 1,
			["AGI"] = 1,
			["EXPERTISE"] = 1,
			["TOHIT"] = 1,
			["CRIT"] = 1,
			["ATTACKPOWER"] = 1,
			["ARMORPEN"] = 1,
			["HASTE"] = 1,
			["SPELLPOW"] = 0,
			["HITCAP"] = {[1] = { ["Minimum Hit Rating"] = "8.00%" }, [3] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 229.53,
			["CAPRATIO"] = 32.79,
			["OVERHITCAP"] = 0,
			["STA"] = 1,
		},
		[3] = {--Feral (Tank)
			["STR"] = 1,
			["AGI"] = 1,
			["EXPERTISE"] = 1,
			["TOHIT"] = 1,
			["CRIT"] = 1,
			["ATTACKPOWER"] = 1,
			["DODGE"] = 1,
			["DEFENSECAP"] = { [1] = { ["Minimum Bonus Defense Skill"] = "+140" }, [3] = { ["Resilience (Stat)"] = "XXX" }, [4] = { ["Survival of the Fittest (Talent)"] = "+150" } },	
			["DEFENSE"] = 1,
			["ARMORPEN"] = 1,
			["HASTE"] = 1,
			["SPELLPOW"] = 0,
			["STA"] = 1,
		},
		[4] = {--Restoration
			["SPELLPOW"] = 1,
			["HASTE"] = 1,
			["CRIT"] = 1,
			["SPI"] = 1,
			["MANAREG"] = 1,
			["INT"] = 1,
			["ATTACKPOWER"] = 0,
			["STA"] = 1,
		},
	},
	["DEATHKNIGHT"] = {
		[1] = {--Blood
			["TOHIT"] = 1,
			["SPELLPOW"] = 0,
			["HASTE"] = 1,
			["ATTACKPOWER"] = 1,
			["ARMORPEN"] = 1,
			["CRIT"] = 1,
			["EXPERTISE"] = 1,
			["STR"] = 1,
			["HITCAP"] = {[1] = { ["Minimum Hit Rating"] = "8.00%" }, [3] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 229.53,
			["CAPRATIO"] = 32.79,
			["DUEL"] = 0,
			["AGI"] = 1,
			["OVERHITCAP"] = 1,
			["STA"] = 1,
		},
		[2] = {--Unholy
			["TOHIT"] = 1,
			["SPELLPOW"] = 0,
			["HASTE"] = 1,
			["ATTACKPOWER"] = 1,
			["ARMORPEN"] = 1,
			["CRIT"] = 1,
			["EXPERTISE"] = 1,
			["STR"] = 1,
			["HITCAP"] = {[1] = { ["Minimum Hit Rating"] = "8.00%" }, [3] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 229.53,
			["CAPRATIO"] = 32.79,
			["DUEL"] = 0,
			["AGI"] = 1,
			["OVERHITCAP"] = 1,
			["STA"] = 1,
		},
		[3] = {--Frost (DPS)
			["TOHIT"] = 1,
			["SPELLPOW"] = 0,
			["HASTE"] = 1,
			["ATTACKPOWER"] = 1,
			["ARMORPEN"] = 1,
			["CRIT"] = 1,
			["EXPERTISE"] = 1,
			["STR"] = 1,
			["HITCAP"] = {[1] = { ["Minimum Hit Rating"] = "8.00%" }, [3] = { ["Nerves of Cold Steel (Talent)"] = "+3.00%" },  [4] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 131.16,
			["CAPRATIO"] = 32.79,
			["DUEL"] = 1,
			["AGI"] = 1,
			["OVERHITCAP"] = 0,
			["STA"] = 1,
		},
		[4] = {--Tanking
			["PARRY"] = 1,
			["TOHIT"] = 1,
			["STR"] = 1,
			["HASTE"] = 1,
			["DEFENSE"] = 1,
			["EXPERTISE"] = 1,
			["DODGE"] = 1,
			["AGI"] = 1,
			["STA"] = 1,
			["CRIT"] = 1,
			["ATTACKPOWER"] = 1,
			["ARMORPEN"] = 1,
			["DEFENSECAP"] = { [1] = { ["Minimum Bonus Defense Skill"] = "+140" }, [3] = { ["Resilience (Stat)"] = "XXX" } },
			--["DEFENSECAP"] = 540,
			--["DUEL"] = 0,
			["STA"] = 1,
			--["OVERHITCAP"] = 1,
   		},
	},
	["WARRIOR"] = {
		[1] = {--Arms (DPS)
			["EXPERTISE"] = 1,
			["ATTACKPOWER"] = 1,
			["ARMORPEN"] = 1,
			["STR"] = 1,
			["TOHIT"] = 1,
			["CRIT"] = 1,
			["AGI"] = 1,
			["HASTE"] = 1,
			["SPELLPOW"] = 0,
			["BLOCK"] = 0,
			["STA"] = 1,
			["DUEL"] = 0,
			["HITCAP"] = {[1] = { ["Minimum Hit Rating"] = "8.00%" }, [3] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 229.53,
			["CAPRATIO"] = 32.79,
		},
		[2] = {--Fury(DPS)
			["EXPERTISE"] = 1,
			["ATTACKPOWER"] = 1,
			["ARMORPEN"] = 1,
			["STR"] = 1,
			["TOHIT"] = 1,
			["STA"] = 1,
			["CRIT"] = 1,
			["AGI"] = 1,
			["HASTE"] = 1,
			["DUEL"] = 1,
			["SPELLPOW"] = 0,
			["BLOCK"] = 0,
			["HITCAP"] = {[1] = { ["Minimum Hit Rating"] = "8.00%" }, [3] = { ["Precision (Talent)"] = "+3%" }, [4] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 131.16,
			["CAPRATIO"] = 32.79,
		},
		[3] = {--Protection (Tank)
		    ["DEFENSE"] = 1,
		    ["DODGE"] = 1,
		    ["EXPERTISE"] = 1,
		    ["AGI"] = 1,
		    ["PARRY"] = 1,
		    ["BLOCK"] = 1,
		    ["DUEL"] = 0,
		    ["STR"] = 1,
		    ["TOHIT"] = 1,
		    ["CRIT"] = 1,
		    ["ARMORPEN"] = 1,
			["STA"] = 1,
		    ["ATTACKPOWER"] = 1,
		    ["HASTE"] = 1,
		    ["SPELLPOW"] = 0,
		    ["BLOCKVALUE"] = 1,
		    ["DEFENSECAP"] = { [1] = { ["Minimum Bonus Defense Skill"] = "+140" }, [3] = { ["Resilience (Stat)"] = "XXX" } },
			["OVERHITCAP"] = 0.5,
		},
	},
	["PRIEST"] = {
        [1] = {--Discipline
			["SPELLPOW"] = 1,
			["HASTE"] = 1,
			["CRIT"] =1,
			["INT"] = 1,
			["SPI"] = 1,
			["STA"] = 1,
			["MANAREG"] = 1,
			["ATTACKPOWER"] = 0,
		},
        [2] = {--Holy
			["SPELLPOW"] = 1,
			["HASTE"] = 1,
			["CRIT"] =1,
			["INT"] = 1,
			["STA"] = 1,
			["SPI"] = 1,
			["MANAREG"] = 1,
			["ATTACKPOWER"] = 0,
		},
        [3] = {--Shadow
			["TOHIT"] = 1,
			["TOHITMIN"] = 446,
			["HITMODS"] = {[1] = { ["Index"] = 6, ["Tab"] = 3, ["Amount"] = 26.23}, [2] = { ["Index"] = 22, ["Tab"] = 3, ["Amount"] = 26.23 }, },			
			["SPELLPOW"] = 1,
			["HASTE"] = 1,
			["CRIT"] =1,
			["INT"] = 1,
			["SPI"] = 1,
			["STA"] = 1,
			["MANAREG"] = 1,
			["ATTACKPOWER"] = 0,
			["HITCAP"] = {[1] = { ["Required Hit Rating"] = "17.00%" }, [3] = { ["Shadow Focus (Talent)"] = "+3.00%" }, [4] = { ["Misery (Talent)"] = "+3.00%" }, [5] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 262.3,
			["CAPRATIO"] = 26.23,			
			["OVERHITCAP"] = 1,
		},
	},
	["WARLOCK"] = {
		[1] = {--Affliction
			["TOHIT"] = 1,
			["SPELLPOW"] = 1,
			["HASTE"] = 1,
			["CRIT"] =1,
			["INT"] = 1,
			["STA"] = 1,
			["SPI"] = 1,
			["MANAREG"] = 0,
			["ATTACKPOWER"] = 0,
			["HITCAP"] = {[1] = { ["Required Hit Rating"] = "17.00%" }, [3] = { ["Suppresion (Talent)"] = "+3.00%" }, [4] = { ["Faerie Fire / Misery (Debuff)"] = "+3.00%" }, [5] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 262.3,
			["CAPRATIO"] = 26.23,			
			["OVERHITCAP"] = 1,
		},
		[2] = {--Demonology
			["TOHIT"] = 1,
			["SPELLPOW"] = 1,
			["HASTE"] = 1,
			["STA"] = 1,
			["CRIT"] =1,
			["INT"] = 1,
			["SPI"] = 1,
			["MANAREG"] = 0,
			["ATTACKPOWER"] = 0,
			["HITCAP"] = {[1]= { ["Required Hit Rating"] = "17.00%" }, [3] = { ["Suppresion (Talent)"] = "+3.00%" }, [4] = { ["Faerie Fire / Misery (Debuff)"] = "+3.00%" }, [5] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 340.99,
			["CAPRATIO"] = 26.23,			
			["OVERHITCAP"] = 1,
		},
		[3] = {--Destruction
			["TOHIT"] = 1,
			["SPELLPOW"] = 1,
			["HASTE"] = 1,
			["CRIT"] =1,
			["STA"] = 1,
			["INT"] = 1,
			["SPI"] = 1,
			["MANAREG"] = 0,
			["ATTACKPOWER"] = 0,
			["HITCAP"] = {[1] = { ["Required Hit Rating"] = "17.00%" }, [3] = { ["Suppresion (Talent)"] = "+3.00%" }, [4] = { ["Faerie Fire / Misery (Debuff)"] = "+3.00%" }, [5] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 340.99,
			["CAPRATIO"] = 26.23,
		},
	},
	["ROGUE"] = {
		[1] = {--DPS Combat
			["SPELLPOW"] = 0,
			["ATTACKPOWER"] = 1,
			["STA"] = 1,
			["STR"] = 1,
			["ARMORPEN"] = 1,
			["CRIT"] = 1,
			["TOHIT"] = 1,
			["DUEL"] = 1,
			["HASTE"] = 1,
			["EXPERTISE"] = 1,
			["AGI"] = 1,
			["HITCAP"] = {[1] = { ["Minimum Hit Rating"] = "8.00%" }, [3] = { ["Precision (Talent)"] = "+5.00%" }, [4] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 65.58,
			["CAPRATIO"] = 32.79,

		},
		[2] = {--DPS Assassination
			["SPELLPOW"] = 0,
			["ATTACKPOWER"] = 1,
			["STA"] = 1,
			["STR"] = 1,
			["ARMORPEN"] = 1,
			["CRIT"] = 1,
			["TOHIT"] = 1,
			["DUEL"] = 1,
			["HASTE"] = 1,
			["EXPERTISE"] = 1,
			["AGI"] = 1,
			["HITCAP"] = {[1] = { ["Minimum Hit Rating"] = "8.00%" }, [3] = { ["Precision (Talent)"] = "+5.00%" }, [4] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 65.58,
			["CAPRATIO"] = 32.79,
		},
		[3] = {--Subtlety
			["SPELLPOW"] = 0,
			["ATTACKPOWER"] = 1,
			["STR"] = 1,
			["ARMORPEN"] = 1,
			["STA"] = 1,
			["CRIT"] = 1,
			["DUEL"] = 1,
			["TOHIT"] = 1,
			["HASTE"] = 1,
			["EXPERTISE"] = 1,
			["AGI"] = 1,
			["HITCAP"] = {[1] = { ["Minimum Hit Rating"] = "8.00%" }, [3] = { ["Precision (Talent)"] = "+5.00%" }, [4] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 65.58,
			["CAPRATIO"] = 32.79,
		},
	},
	["HUNTER"] = {
		[1] = {--DPS Combat
			["SPELLPOW"] = 0,
			["ATTACKPOWER"] = 1,
			["STR"] = 1,
			["ARMORPEN"] = 1,
			["STA"] = 1,
			["CRIT"] = 1,
			["TOHIT"] = 1,
			["HASTE"] = 1,
			["EXPERTISE"] = 1,
			["AGI"] = 1,
			["RANGEDCRIT"] = 1,
			["INT"] = 1,
			["HITCAP"] = {[1] = { ["Minimum Hit Rating"] = "8.00%" }, [3] = { ["Focused Aim (Talent)"] = "+3.00%" }, [4] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 131.16,
			["CAPRATIO"] = 32.79,
		},
		[2] = {--DPS Assassination
			["SPELLPOW"] = 0,
			["ATTACKPOWER"] = 1,
			["STR"] = 1,
			["ARMORPEN"] = 1,
			["CRIT"] = 1,
			["TOHIT"] = 1,
			["INT"] = 1,
			["RANGEDCRIT"] = 1,
			["HASTE"] = 1,
			["STA"] = 1,
			["EXPERTISE"] = 1,
			["AGI"] = 1,
			["HITCAP"] = {[1] = { ["Minimum Hit Rating"] = "8.00%" }, [3] = { ["Focused Aim (Talent)"] = "+3.00%" }, [4] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 131.16,
			["CAPRATIO"] = 32.79,
		},
		[3] = {--Subtlety
			["SPELLPOW"] = 0,
			["ATTACKPOWER"] = 1,
			["INT"] = 1,
			["STR"] = 1,
			["ARMORPEN"] = 1,
			["CRIT"] = 1,
			["TOHIT"] = 1,
			["RANGEDCRIT"] = 1,
			["HASTE"] = 1,
			["STA"] = 1,
			["EXPERTISE"] = 1,
			["AGI"] = 1,
			["HITCAP"] = {[1] = { ["Minimum Hit Rating"] = "8.00%" }, [3] = { ["Focused Aim (Talent)"] = "+3.00%" }, [4] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 131.16,
			["CAPRATIO"] = 32.79,
		},
	},
	["MAGE"] = {
		[1] = {--DPS Arcane
			["TOHIT"] = 1,
			["TOHITMIN"] = 446,
			["HITMODS"] = {[1] = { ["Index"] = 2, ["Tab"] = 1, ["Amount"] = 26.23}, [2] = { ["Index"] = 6, ["Tab"] = 3, ["Amount"] = 26.23 }, },
			["OVERHITCAP"] = 1,			
			["SPELLPOW"] = 1,
			["HASTE"] = 1,
			["CRIT"] =1,
			["STA"] = 1,
			["INT"] = 1,
			["SPI"] = 1,
			--["STA"] = 1,
			--["MANAREG"] = 0,
			["SPI"] = 1,
			["HITCAP"] = {[1] = { ["Required Hit Rating"] = "17.00%" }, [3] = { ["Arcane Focus (Talent)"] = "+3.00%" }, [4] = { ["Precision (Talent)"] = "+3.00%" },  [5] = { ["Faerie Fire / Misery (Debuff)"] = "+3.00%" }, [6] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 183.61,
			["CAPRATIO"] = 26.23,
		},
		[2] = {--DPS  Fire
			["TOHIT"] = 1,
			["TOHITMIN"] = 446,
			["HITMODS"] = {[1] = { ["Index"] = 2, ["Tab"] = 1, ["Amount"] = 26.23}, [2] = { ["Index"] = 6, ["Tab"] = 3, ["Amount"] = 26.23 }, },
			["OVERHITCAP"] = 1,				
			["SPELLPOW"] = 1,
			["HASTE"] = 1,
			["CRIT"] =1,
			["INT"] = 1,
			["STA"] = 1,
			["SPI"] = 1,
			--["STA"] = 1,
			--["MANAREG"] = 0,
			["SPI"] = 1,
			["HITCAP"] = {[1] = { ["Required Hit Rating"] = "17.00%" }, [3] = { ["Faerie Fire / Misery (Debuff)"] = "+3.00%" }, [4] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 367.22,
			["CAPRATIO"] = 26.23,
		},
		[3] = {--DPS Frost
			["TOHIT"] = 1,
			["TOHITMIN"] = 446,
			["HITMODS"] = {[1] = { ["Index"] = 2, ["Tab"] = 1, ["Amount"] = 26.23}, [2] = { ["Index"] = 6, ["Tab"] = 3, ["Amount"] = 26.23 }, },
			["OVERHITCAP"] = 1,				
			["SPELLPOW"] = 1,
			["HASTE"] = 1,
			["STA"] = 1,
			["CRIT"] =1,
			["INT"] = 1,
			["SPI"] = 1,
			--["STA"] = 1,
			--["MANAREG"] = 0,
			["SPI"] = 1,
			["HITCAP"] = {[1] = { ["Required Hit Rating"] = "17.00%" }, [3] = { ["Precision (Talent)"] = "+3.00%" }, [4] = { ["Faerie Fire / Misery (Debuff)"] = "+3.00%" }, [5] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 262.3,
			["CAPRATIO"] = 26.23,
		},
	},
	["ShamanCustomWeights"] = {
		[1] = {--Elemental
			["SPELLPOW"] = 0.60,
			["HASTE"] = 0.56,
			["CRIT"] = 0.40,
			["INT"] = 0.11,
			["Total"] = 2.67,			
			["TOHIT"] = 1,
		},
		[2] = {--Enhancement
			["TOHIT"] = 1,
			["EXPERTISE"] = 0.84,
			["AGI"] = 0.55,
			["INT"] = 0.55,
			["CRIT"] = 0.55,
			["HASTE"] = 0.42,
			["STR"] = 0.35,
			["DUEL"] = 1,
			["SPELLPOW"] = 0.29,
			["ATTACKPOWER"] = 0.32,
			["Total"] = 5.13,
			--["SPELLPOW"] = 0.25,
			["ARMORPEN"] = 0.26,
		},
        [3] = {--Restoration
            ["MANAREG"] = 1,
			["SPELLPOW"] = 0.77,
			["HASTE"] = 0.35,
			["CRIT"] = 0.62,
			["INT"] = 0.85,
			["Total"] = 3.59,
		},
	},

	["SHAMAN"] = {
		[1] = {--Elemental
			["TOHIT"] = 1,
			["TOHITMIN"] = 446,
			["HITMODS"] = {[1] = { ["Index"] = 14, ["Tab"] = 1, ["Amount"] = 26.23}, },
			["SPELLPOW"] = 1,
			["STA"] = 1,
			["HASTE"] = 1,
			["CRIT"] =1,
			["INT"] = 1,
			["BLOCK"] = 1,
			["HITCAP"] = {[1] = { ["Required Hit Rating"] = "17.00%" }, [3] = { ["Elemental Precision (Talent)"] = "+3.00%" }, [4] = { ["Faerie Fire / Misery (Debuff)"] = "+3.00%" }, [5] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 262.3,
			["CAPRATIO"] = 26.23,
			["BLOCKVALUE"] = 1,
			["OVERHITCAP"] = 1,
		},
		[2] = {--Enhancement
			["TOHIT"] = 1,
			["EXPERTISE"] = 1,
			["INT"] = 1,
			["CRIT"] = 1,
			["AGI"] = 1,
			["STA"] = 1,
			["HASTE"] = 1,
			["STR"] = 1,
			["DUEL"] = 1,
			["ATTACKPOWER"] = 1,
			["ARMORPEN"] = 1,
			["BLOCK"] = 0,
			["HITCAP"] = {[1] = { ["Minimum Hit Rating"] = "8.00%" }, [3] = { ["Dual Wield Specialization (Talent)"] = "+6.00%" }, [4] = { ["Draenei's Heroic Presence (Racial)"] = "+1.00%" } },
			["ABSOLUTEMINHIT"] = 32.79,
			["CAPRATIO"] = 32.79,
		},
        [3] = {--Restoration
            ["MANAREG"] = 1,
			["SPELLPOW"] = 1,
			["HASTE"] = 1,
			["CRIT"] = 1,
			["INT"] = 1,
			["STA"] = 1,
			["BLOCK"] = 1,
			["BLOCKVALUE"] = 1,
		},
	},
}

GearScoreClassStats = {
	["STR"] = 1,["AGI"] = 1,["STA"] = 2/3,["INT"] = 1,["SPI"] = 1,["BLOCK"] = 1,["BLOCKVALUE"] = 0.65,["DODGE"] = 1,["PARRY"] = 1,
	["RESILIENCE"] = 1,["ARMORPEN"] = 1,["EXPERTISE"] = 1,["DEFENSE"] = 1,["ATTACKPOWER"] = 0.5,["RANGEDATTACKPOWER"] = 0.5,["CRIT"] = 1,
	["RANGEDCRIT"] = 1,["TOHIT"] = 1,["RANGEDHIT"] = 1,["HASTE"] = 1,["ARCANERES"] = 0,["FROSTRES"] = 0,["FIRERES"] = 0,["SHADOWRES"] = 0,	
	["SPELLPEN"] = 0.80,["SPELLPOW"] = 6/7,["MANAREG"] = 2,
}


GearScoreClassStatsTranslation = {
	["STR"] = "Strength",["AGI"] = "Agility",["STA"] = "Stamina",["INT"] = "Intellect",["SPI"] = "Spirit",["ARMOR"] = "Armor",
	["BLOCK"] = "Block Rating",["BLOCKVALUE"] = "Sheild Block",["DODGE"] = "Dodge Rating",["PARRY"] = "Parry Rating",["RESILIENCE"] = "Resilience",
	["ARMORPEN"] = "Armor Penetration",["EXPERTISE"] = "Expertise",["DEFENSE"] = "Defense Rating",["ATTACKPOWER"] = "Attack Power",
	["RANGEDATTACKPOWER"] = "Ranged Attack Power",["CRIT"] = "Critical strike rating",["RANGEDCRIT"] = "Ranged critical strike rating",
	["TOHIT"] = "Hit rating",["RANGEDHIT"] = "Ranged hit rating",["HASTE"] = "Haste rating",["SPELLPEN"] = "Spell Penetration",["SPELLPOW"] = "Spell Power",
	["MANAREG"] = "Mana per 5",
}
LibQTip = LibStub("LibQTipClick-1.1")