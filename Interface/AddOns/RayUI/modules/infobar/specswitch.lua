local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local IF = R:GetModule("InfoBar")

local function LoadTalent()
	local infobar = _G["RayUIBottomInfoBar"]
	local Status = CreateFrame("Frame")
	Status:EnableMouse(true)
	Status:SetFrameStrata("BACKGROUND")
	Status:SetFrameLevel(3)

	local Text  = infobar:CreateFontString(nil, "OVERLAY")
	Text:SetFont(R["media"].font, R["media"].fontsize, R["media"].fontflag)
	Text:SetShadowOffset(1.25, -1.25)
	Text:SetShadowColor(0, 0, 0, 0.4)
	Text:SetPoint("BOTTOMLEFT", infobar, "TOPLEFT", 10, -3)
	Text:SetText(NONE..TALENTS)
	Status:SetParent(Text:GetParent())

	local talentString = string.join("", "|cffFFFFFF%s:|r %d/%d/%d")
	local spec = LibStub("Tablet-2.0")

	local SpecEquipList = {}

	local function SpecChangeClickFunc(self, ...)
		if ... then
			if GetActiveTalentGroup() == ... then return end
		end

		if GetNumTalentGroups() > 1 then
			SetActiveTalentGroup(GetActiveTalentGroup() == 1 and 2 or 1)
		end
	end

	local function SpecGearClickFunc(self, index, equipName)
		if not index then return end

		if IsShiftKeyDown() then
			if R.db.specgear.primary == index then
				R.db.specgear.primary = -1
			end
			if R.db.specgear.secondary == index then
				R.db.specgear.secondary = -1
			end
		elseif IsAltKeyDown() then
			R.db.specgear.secondary = index
		elseif IsControlKeyDown() then
			R.db.specgear.primary = index
		else
			EquipmentManager_EquipSet(equipName)
		end

		spec:Refresh(self)
	end

	local function SpecAddEquipListToCat(self, cat)
		resSizeExtra = 2
		local numTalentGroups = GetNumTalentGroups()

		-- Sets
		local line = {}
		if #SpecEquipList > 0 then
			for k, v in ipairs(SpecEquipList) do
				local _, _, _, isEquipped = GetEquipmentSetInfo(k)

				wipe(line)
				for i = 1, 4 do
					if i == 1 then
						line["text"] = string.format("|T%s:%d:%d:0:0:64:64:5:59:5:59|t %s", SpecEquipList[k].icon, 10 + resSizeExtra, 10 + resSizeExtra, SpecEquipList[k].name)
						line["size"] = 10 + resSizeExtra
						line["justify"] = "LEFT"
						line["textR"] = 0.9
						line["textG"] = 0.9
						line["textB"] = 0.9
						line["hasCheck"] = true
						line["isRadio"] = true
						line["checked"] = isEquipped
						line["func"] = function() SpecGearClickFunc(self, k, SpecEquipList[k].name) end
						line["customwidth"] = 110
					elseif i == 2 then
						line["text"..i] = PRIMARY
						line["size"..i] = 10 + resSizeExtra
						line["justify"..i] = "LEFT"
						line["text"..i.."R"] = (R.db.specgear.primary == k) and 0 or 0.3
						line["text"..i.."G"] = (R.db.specgear.primary == k) and 0.9 or 0.3
						line["text"..i.."B"] = (R.db.specgear.primary == k) and 0 or 0.3
					elseif (i == 3) and (numTalentGroups > 1) then
						line["text"..i] = SECONDARY
						line["size"..i] = 10 + resSizeExtra
						line["justify"..i] = "LEFT"
						line["text"..i.."R"] = (R.db.specgear.secondary == k) and 0 or 0.3
						line["text"..i.."G"] = (R.db.specgear.secondary == k) and 0.9 or 0.3
						line["text"..i.."B"] = (R.db.specgear.secondary == k) and 0 or 0.3
					end
				end

				cat:AddLine(line)
			end
		end
	end

	local TalentInfo = {}

	local function SpecAddTalentGroupLineToCat(self, cat, talentGroup)
		resSizeExtra = 2

		local ActiveColor = {0, 0.9, 0}
		local InactiveColor = {0.9, 0.9, 0.9}
		local PrimaryTreeColor = {0.8, 0.8, 0.8}
		local OtherTreeColor = {0.8, 0.8, 0.8}

		local IsPrimary = GetActiveTalentGroup()
		local maxPrimaryTree = GetPrimaryTalentTree()

		local line = {}
		for i = 1, 4 do
			local SpecColor = (IsPrimary == talentGroup) and ActiveColor or InactiveColor
			local TreeColor = ((IsPrimary == talentGroup) and (maxPrimaryTree == i - 1)) and PrimaryTreeColor or OtherTreeColor
			if i == 1 then
				line["text"] = talentGroup == 1 and PRIMARY or SECONDARY
				line["justify"] = "LEFT"
				line["size"] = 10 + resSizeExtra
				line["textR"] = SpecColor[1]
				line["textG"] = SpecColor[2]
				line["textB"] = SpecColor[3]
				line["hasCheck"] = true
				line["checked"] = IsPrimary == talentGroup
				line["isRadio"] = true
				line["func"] = function() SpecChangeClickFunc(self, talentGroup) end
				line["customwidth"] = 130
			elseif i == 2 then
				line["text"..i] = TalentInfo[talentGroup][1].points
				line["justify"..i] = "CENTER"
				line["text"..i.."R"] = TreeColor[1]
				line["text"..i.."G"] = TreeColor[2]
				line["text"..i.."B"] = TreeColor[3]
				line["customwidth"..i] = 20
			elseif i == 3 then
				line["text"..i] = TalentInfo[talentGroup][2].points
				line["justify"..i] = "CENTER"
				line["text"..i.."R"] = TreeColor[1]
				line["text"..i.."G"] = TreeColor[2]
				line["text"..i.."B"] = TreeColor[3]
				line["customwidth"..i] = 20
			elseif i == 4 then
				line["text"..i] = TalentInfo[talentGroup][3].points
				line["justify"..i] = "CENTER"
				line["text"..i.."R"] = TreeColor[1]
				line["text"..i.."G"] = TreeColor[2]
				line["text"..i.."B"] = TreeColor[3]
				line["customwidth"..i] = 20
			end
		end
		cat:AddLine(line)
	end

	local SpecSection = {}

	local function Spec_UpdateTablet(self)
		resSizeExtra = 2
		local Cols, lineHeader

		local numTalentGroups = GetNumTalentGroups()

		if numTalentGroups > 0 then
			wipe(SpecSection)

			-- Spec Category
			SpecSection["specs"] = {}
			SpecSection["specs"].cat = spec:AddCategory()
			SpecSection["specs"].cat:AddLine("text", R:RGBToHex(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)..TALENTS.."|r", "size", 10 + resSizeExtra, "textR", 1, "textG", 1, "textB", 1)

			-- Talent Cat
			Cols = {
				" ",
				string.format("|T%s:%d:%d:0:0:64:64:5:59:5:59|t", TalentInfo[1][1].icon or "", 16 + resSizeExtra, 16 + resSizeExtra),
				string.format("|T%s:%d:%d:0:0:64:64:5:59:5:59|t", TalentInfo[1][2].icon or "", 16 + resSizeExtra, 16 + resSizeExtra),
				string.format("|T%s:%d:%d:0:0:64:64:5:59:5:59|t", TalentInfo[1][3].icon or "", 16 + resSizeExtra, 16 + resSizeExtra),
			}
			SpecSection["specs"].talentCat = spec:AddCategory("columns", #Cols)
			lineHeader = R:MakeTabletHeader(Cols, 10 + resSizeExtra, 12, {"LEFT", "CENTER", "CENTER", "CENTER"})
			SpecSection["specs"].talentCat:AddLine(lineHeader)
			R:AddBlankTabLine(SpecSection["specs"].talentCat, 1)

			-- Primary Talent line
			SpecAddTalentGroupLineToCat(self, SpecSection["specs"].talentCat, 1)

			-- Secondary Talent line
			if numTalentGroups > 1 then
				SpecAddTalentGroupLineToCat(self, SpecSection["specs"].talentCat, 2)
			end
		end

		local numEquipSets = GetNumEquipmentSets()
		if numEquipSets > 0 then
			if numTalentGroups > 1 then
				R:AddBlankTabLine(SpecSection["specs"].talentCat, 8)
			end

			-- Equipment Category
			SpecSection["equipment"] = {}
			SpecSection["equipment"].cat = spec:AddCategory()
			SpecSection["equipment"].cat:AddLine("text", R:RGBToHex(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)..EQUIPMENT_MANAGER.."|r", "size", 10 + resSizeExtra, "textR", 1, "textG", 1, "textB", 1)
			R:AddBlankTabLine(SpecSection["equipment"].cat, 2)

			-- Equipment Cat
			SpecSection["equipment"].equipCat = spec:AddCategory("columns", 3)
			R:AddBlankTabLine(SpecSection["equipment"].equipCat, 1)

			SpecAddEquipListToCat(self, SpecSection["equipment"].equipCat)
		end

		-- Hint
		if (numTalentGroups > 0) and (numEquipSets > 0) then
			spec:SetHint(L["<点击天赋> 切换天赋."].."\n"..L["<点击套装> 装备套装."].."\n"..L["<Ctrl+点击套装> 套装绑定至主天赋."].."\n"..L["<Alt+点击套装> 套装绑定至副天赋."].."\n"..L["<Shift+点击套装> 解除天赋绑定."])
		elseif numTalentGroups > 0 then
			spec:SetHint(L["<点击天赋> 切换天赋."])
		elseif numEquipSets > 0 then
			spec:SetHint(L["<点击套装> 装备套装."].."\n"..L["<Ctrl+点击套装> 套装绑定至主天赋."]..PRIMARY.."\n"..L["<Shift+点击套装> 解除天赋绑定."])
		end
	end

	local function Spec_OnEnter(self)
		if InCombatLockdown() then return end
		-- Register spec
		if not spec:IsRegistered(self) then
			spec:Register(self,
				"children", function()
					Spec_UpdateTablet(self)
				end,
				"point", "BOTTOM",
				"relativePoint", "TOP",
				"maxHeight", 500,
				"clickable", true,
				"hideWhenEmpty", true
			)
		end

		if spec:IsRegistered(self) then
			-- spec appearance
			spec:SetColor(self, 0, 0, 0)
			spec:SetTransparency(self, .65)
			spec:SetFontSizePercent(self, 1)

			-- Open
			spec:Open(self)
		end

		collectgarbage()
	end

	local function Spec_Update(self)
		-- Talent Info
		wipe(TalentInfo)
		local numTalentGroups = GetNumTalentGroups()
		for i = 1, numTalentGroups do
			TalentInfo[i] = {}
			for t = 1, 3 do
				local _, _, _, talentIcon, pointsSpent = GetTalentTabInfo(t, false, false, i)
				TalentInfo[i][t] = {
					points = pointsSpent,
					icon = talentIcon,
				}
			end
		end

		-- Gear sets
		wipe(SpecEquipList)
		local numEquipSets = GetNumEquipmentSets()
		if numEquipSets > 0 then
			for index = 1, numEquipSets do
				local equipName, equipIcon = GetEquipmentSetInfo(index)
				SpecEquipList[index] = {
					name = equipName,
					icon = equipIcon,
				}
			end
		end
		-- if R.db.specgear.primary > numEquipSets then
			-- R.db.specgear.primary = -1
		-- end
		-- if R.db.specgear.secondary > numEquipSets then
			-- R.db.specgear.secondary = -1
		-- end

		local active = GetActiveTalentGroup(false, false)
		if GetPrimaryTalentTree(false, false, active) and select(2, GetTalentTabInfo(GetPrimaryTalentTree(false, false, active))) then
			Text:SetFormattedText(talentString, select(2, GetTalentTabInfo(GetPrimaryTalentTree(false, false, active))), TalentInfo[active][1].points, TalentInfo[active][2].points, TalentInfo[active][3].points)
			self:SetScript("OnEnter", Spec_OnEnter)
		else
			self:SetScript("OnEnter", nil)
		end
	end

	Status:SetScript("OnEnter", Spec_OnEnter)
	local manager = CreateFrame("Frame")

	local function OnEvent(self, event, ...)
		if event == "PLAYER_LOGIN" then
			R.db.specgear = R.db.specgear or {}
			R.db.specgear.primary = R.db.specgear.primary or -1
			R.db.specgear.secondary = R.db.specgear.secondary or -1
			self:UnregisterEvent("PLAYER_LOGIN")
			self:RegisterEvent("PLAYER_ENTERING_WORLD");
			self:RegisterEvent("CHARACTER_POINTS_CHANGED");
			self:RegisterEvent("PLAYER_TALENT_UPDATE");
			self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
			self:RegisterEvent("EQUIPMENT_SETS_CHANGED")
			self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
			manager:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		end

		-- Setup Talents Tooltip
		self:SetAllPoints(Text)

		Spec_Update(self)
	end

	Status:RegisterEvent("PLAYER_LOGIN")
	Status:SetScript("OnEvent", OnEvent)

	Status:SetScript("OnMouseDown", function()
		local active = GetActiveTalentGroup(false, false)
		SetActiveTalentGroup(active == 1 and 2 or 1)
	end)

	manager:SetScript("OnEvent", function(self, event, id)
		local numEquipSets = GetNumEquipmentSets()
		if id == 1 then
			if R.db.specgear.primary > 0 and R.db.specgear.primary <= numEquipSets then
				self.needEquipSet = GetEquipmentSetInfo(R.db.specgear.primary)
			end
		else
			if R.db.specgear.secondary > 0 and R.db.specgear.secondary <= numEquipSets then
				self.needEquipSet = GetEquipmentSetInfo(R.db.specgear.secondary)
			end
		end
	end)

	manager:SetScript("OnUpdate", function(self, elapsed)
		self.updateElapsed = (self.updateElapsed or 0) + elapsed
		if self.updateElapsed > TOOLTIP_UPDATE_TIME then
			self.updateElapsed = 0

			if self.needEquipSet then
				EquipmentManager_EquipSet(self.needEquipSet)
				self.needEquipSet = nil
			end
		end
	end)
end

IF:RegisterInfoText("Talent", LoadTalent)