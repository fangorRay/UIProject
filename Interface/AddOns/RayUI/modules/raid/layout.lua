local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local RA = R:GetModule("Raid")
local UF = R:GetModule("UnitFrames")

local oUF = RayUF or oUF

local backdrop, border, border2, glowBorder
RA._Objects = {}
RA._Headers = {}

local colors = RayUF.colors

function RA:Hex(r, g, b)
    if(type(r) == "table") then
        if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
    end
    return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
end

-- Unit Menu
local dropdown = CreateFrame("Frame", "RayUFRaidDropDown", UIParent, "UIDropDownMenuTemplate")

local function menu(self)
    dropdown:SetParent(self)
    return ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
end

local function ColorGradient(perc, color1, color2, color3)
	local r1,g1,b1 = 1, 0, 0
	local r2,g2,b2 = .85, .8, .45
	local r3,g3,b3 = .12, .12, .12

	if perc >= 1 then
		return r3, g3, b3
	elseif perc <= 0 then
		return r1, g1, b1
	end

	local segment, relperc = math.modf(perc*(3-1))
	local offset = (segment*3)+1

	-- < 50% > 0%
	if(offset == 1) then
		return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
	end
	-- < 99% > 50%
	return r2 + (r3-r2)*relperc, g2 + (g3-g2)*relperc, b2 + (b3-b2)*relperc
end

local init = function(self)
    if RA.db.hidemenu and InCombatLockdown() then
        return
    end

    local unit = self:GetParent().unit
    local menu, name, id

    if(not unit) then
        return
    end

    if(UnitIsUnit(unit, "player")) then
        menu = "SELF"
    elseif(UnitIsUnit(unit, "vehicle")) then
        menu = "VEHICLE"
    elseif(UnitIsUnit(unit, "pet")) then
        menu = "PET"
    elseif(UnitIsPlayer(unit)) then
        id = UnitInRaid(unit)
        if(id) then
            menu = "RAID_PLAYER"
            name = GetRaidRosterInfo(id)
        elseif(UnitInParty(unit)) then
            menu = "PARTY"
        else
            menu = "PLAYER"
        end
    else
        menu = "TARGET"
        name = RAID_TARGET_ICON
    end

    if(menu) then
        UnitPopup_ShowMenu(self, menu, unit, name, id)
    end
end

-- Show Target Border
local function ChangedTarget(self)
    if UnitIsUnit("target", self.unit) then
        self.TargetBorder:Show()
    else
		self.TargetBorder:Hide()
	end
end

-- Show Focus Border
local function FocusTarget(self)
    if UnitIsUnit("focus", self.unit) then
        self.FocusHighlight:Show()
    else
		self.FocusHighlight:Hide()
	end
end

local function updateThreat(self, event, unit)
    if(unit ~= self.unit) then return end

    local status = UnitThreatSituation(unit)

    if(status and status > 1) then
        local r, g, b = GetThreatStatusColor(status)
        self.Threat:SetBackdropBorderColor(r, g, b, 1)
        self.border:SetBackdropColor(r, g, b, 1)
    else
        self.Threat:SetBackdropBorderColor(0, 0, 0, 1)
        self.border:SetBackdropColor(0, 0, 0, 1)
    end
    self.Threat:Show()
end

oUF.Tags.Methods["RayUFRaid:name"] = function(u, r)
    local name = (u == "vehicle" and UnitName(r or u)) or UnitName(u)

    if RA.nameCache[name] then
        return RA.nameCache[name]
    end
end
oUF.Tags.Events["RayUFRaid:name"] = "UNIT_NAME_UPDATE"

RA.nameCache = {}
RA.colorCache = {}
RA.debuffColor = {} -- hex debuff colors for tags

local function utf8sub(str, start, numChars) 
    local currentIndex = start 
    while numChars > 0 and currentIndex <= #str do 
        local char = string.byte(str, currentIndex) 
        if char >= 240 then 
            currentIndex = currentIndex + 4 
        elseif char >= 225 then 
            currentIndex = currentIndex + 3 
        elseif char >= 192 then 
            currentIndex = currentIndex + 2 
        else 
            currentIndex = currentIndex + 1 
        end 
        numChars = numChars - 1 
    end 
    return str:sub(start, currentIndex - 1) 
end 

function RA:UpdateName(name, unit) 
    if(unit) then
        local _NAME = UnitName(unit)
        local _, class = UnitClass(unit)
        if not _NAME or not class then return end

        local substring
        for length=#_NAME, 1, -1 do
            substring = utf8sub(_NAME, 1, length)
            name:SetText(substring)
            if name:GetStringWidth() <= RA.db.width - 8 then name:SetText(nil); break end
        end

        local str = RA.colorCache[class]..substring
        RA.nameCache[_NAME] = str
        name:UpdateTag()
    end
end

local function PostHealth(hp, unit)
    local self = hp.__owner
    local name = UnitName(unit)

    if not RA.nameCache[name] then
        RA:UpdateName(self.Name, unit)
    end

    local suffix = self:GetAttribute"unitsuffix"
    if suffix == "pet" or unit == "vehicle" or unit == "pet" then
        local r, g, b = .2, .9, .1
        hp:SetStatusBarColor(r*.2, g*.2, b*.2)
        hp.bg:SetVertexColor(r, g, b)
        return
    end

	if UF.db.healthColorClass then
		hp.colorClass=true
		hp.bg.multiplier = .2
	else
		local curhealth, maxhealth = UnitHealth(unit), UnitHealthMax(unit)
		local r, g, b
		if UF.db.smoothColor then
			r,g,b = ColorGradient(curhealth/maxhealth)
		else
			r,g,b = .12, .12, .12, 1
		end

		if(b) then
			hp:SetStatusBarColor(r, g, b, 1)
		elseif not UnitIsConnected(unit) then
			local color = colors.disconnected
			local power = hp.__owner.Power
			if power then
				power:SetValue(0)
				if power.value then
					power.value:SetText(nil)
				end
			end
		elseif UnitIsDeadOrGhost(unit) then
			local color = colors.disconnected
			local power = hp.__owner.Power
			if power then
				power:SetValue(0)
				if power.value then
					power.value:SetText(nil)
				end
			end
		end
		if UF.db.smoothColor then
			if UnitIsDeadOrGhost(unit) or (not UnitIsConnected(unit)) then
				hp:SetStatusBarColor(0.5, 0.5, 0.5, 1)
				hp.bg:SetVertexColor(0.5, 0.5, 0.5, 1)
			else
				hp.bg:SetVertexColor(0.12, 0.12, 0.12, 1)
			end
		end
	end
end

function RA:UpdateHealth(hp)
    hp:SetStatusBarTexture(R["media"].normal)
    hp:SetOrientation("HORIZONTAL")
    hp.bg:SetTexture(R["media"].normal)
    hp.freebSmooth = UF.db.smooth

	hp:ClearAllPoints()
	hp:SetPoint"TOP"
	hp:SetPoint"LEFT"
	hp:SetPoint"RIGHT"
end

local function PostPower(power, unit)
    local self = power.__owner
    local _, ptype = UnitPowerType(unit)
    local _, class = UnitClass(unit)

	power:Height(RA.db.height*RA.db.powerbarsize)
	-- self.Health:SetHeight((1 - RA.db.powerbarsize)*self:GetHeight()-1)
	self.Health:Point("BOTTOM", self.Power, "TOP", 0, 1)

    local perc = oUF.Tags.Methods["perpp"](unit)
    -- This kinda conflicts with the threat module, but I don't really care
    if (perc < 10 and UnitIsConnected(unit) and ptype == "MANA" and not UnitIsDeadOrGhost(unit)) then
        self.Threat:SetBackdropBorderColor(0, 0, 1, 1)
        self.border:SetBackdropColor(0, 0, 1, 1)
    else
        -- pass the coloring back to the threat func
        updateThreat(self, nil, unit)
    end

    local r, g, b, t
    t = UF.db.powerColorClass and colors.class[class] or colors.power[ptype]

	if UF.db.powerColorClass then
		power.colorClass=true
		power.bg.multiplier = .2
	else
		power.colorPower=true
		power.bg.multiplier = .2
	end
end

function RA:UpdatePower(power)
	power:Show()
	power.PostUpdate = PostPower
    power:SetStatusBarTexture(R["media"].normal)
    power:SetOrientation("HORIZONTAL")
    power.bg:SetTexture(R["media"].normal)

    power:ClearAllPoints()
	power:SetPoint"LEFT"
	power:SetPoint"RIGHT"
	power:SetPoint"BOTTOM"
end

-- Show Mouseover highlight
local function OnEnter(self)
    if RA.db.tooltip then
        UnitFrame_OnEnter(self)
    else
        GameTooltip:Hide()
    end

    if RA.db.highlight then
        self.Highlight:Show()
    end

    if RA.db.arrow and RA.db.arrowmouseover then
        RA:arrow(self, self.unit)
    end
end

local function OnLeave(self)
    if RA.db.tooltip then
        UnitFrame_OnLeave(self)
    end
    self.Highlight:Hide()

    if(self.freebarrow and self.freebarrow:IsShown()) and RA.db.arrowmouseover then
        self.freebarrow:Hide()
    end
end

local function style(self)
    self.menu = menu

    self.BG = CreateFrame("Frame", nil, self)
    self.BG:SetPoint("TOPLEFT", self, "TOPLEFT")
    self.BG:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
    self.BG:SetFrameLevel(3)
    self.BG:SetBackdrop(backdrop)
    self.BG:SetBackdropColor(0, 0, 0)

    self.border = CreateFrame("Frame", nil, self)
    self.border:SetPoint("TOPLEFT", self, "TOPLEFT")
    self.border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
    self.border:SetFrameLevel(2)
    self.border:SetBackdrop(border2)
    self.border:SetBackdropColor(0, 0, 0)

    -- Mouseover script
    self:SetScript("OnEnter", OnEnter)
    self:SetScript("OnLeave", OnLeave)
    self:RegisterForClicks("AnyUp")

    -- Health
    self.Health = CreateFrame"StatusBar"
    self.Health:SetParent(self)
    self.Health.frequentUpdates = true

    self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
    self.Health.bg:SetAllPoints(self.Health)

    self.Health.PostUpdate = PostHealth
    RA:UpdateHealth(self.Health)

    -- Threat
    local threat = CreateFrame("Frame", nil, self)
    threat:Point("TOPLEFT", self, "TOPLEFT", -5, 5)
    threat:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", 5, -5)
    threat:SetFrameLevel(0)
    threat:SetBackdrop(glowBorder)
    threat:SetBackdropColor(0, 0, 0, 0)
    threat:SetBackdropBorderColor(0, 0, 0, 1)
    threat.Override = updateThreat
    self.Threat = threat

    -- Name
    local name = self.Health:CreateFontString(nil, "OVERLAY", -8)
    name:SetPoint("CENTER")
    name:SetJustifyH("CENTER")
    name:SetFont(R["media"].font, R["media"].fontsize, R["media"].fontflag)
    name:SetWidth(RA.db.width)
    name.overrideUnit = true
    self.Name = name
    self:Tag(self.Name, "[RayUFRaid:name]")

    RA:UpdateName(self.Name)

    -- Power
    self.Power = CreateFrame"StatusBar"
    self.Power:SetParent(self)
    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg:SetAllPoints(self.Power)
    RA:UpdatePower(self.Power)

    -- Highlight tex
    local hl = self.Health:CreateTexture(nil, "OVERLAY")
    hl:SetAllPoints(self)
    hl:SetTexture(R["media"].blank)
    hl:SetVertexColor(1,1,1,.1)
    hl:SetBlendMode("ADD")
    hl:Hide()
    self.Highlight = hl

    -- Target tex
    local tBorder = CreateFrame("Frame", nil, self)
    tBorder:SetPoint("TOPLEFT", self, "TOPLEFT")
    tBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
    tBorder:SetBackdrop(border)
    tBorder:SetBackdropColor(.8, .8, .8, 1)
    tBorder:SetFrameLevel(1)
    tBorder:Hide()
    self.TargetBorder = tBorder

    -- Focus tex
    local fBorder = CreateFrame("Frame", nil, self)
    fBorder:SetPoint("TOPLEFT", self, "TOPLEFT")
    fBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
    fBorder:SetBackdrop(border)
    fBorder:SetBackdropColor(.6, .8, 0, 1)
    fBorder:SetFrameLevel(1)
    fBorder:Hide()
    self.FocusHighlight = fBorder

    -- Raid Icons
    local ricon = self.Health:CreateTexture(nil, "OVERLAY")
    ricon:SetPoint("TOP", self, 0, 5)
    ricon:SetSize(RA.db.leadersize+2, RA.db.leadersize+2)
    self.RaidIcon = ricon

    -- Leader Icon
    self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
    self.Leader:SetPoint("TOPLEFT", self, 0, 8)
    self.Leader:SetSize(RA.db.leadersize, RA.db.leadersize)

    -- Assistant Icon
    self.Assistant = self.Health:CreateTexture(nil, "OVERLAY")
    self.Assistant:SetPoint("TOPLEFT", self, 0, 8)
    self.Assistant:SetSize(RA.db.leadersize, RA.db.leadersize)

    local masterlooter = self.Health:CreateTexture(nil, "OVERLAY")
    masterlooter:SetSize(RA.db.leadersize, RA.db.leadersize)
    masterlooter:SetPoint("LEFT", self.Leader, "RIGHT")
    self.MasterLooter = masterlooter

    -- Role Icon
    if RA.db.roleicon then
        self.LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
        self.LFDRole:SetSize(RA.db.leadersize, RA.db.leadersize)
        self.LFDRole:SetPoint("RIGHT", self, "LEFT", RA.db.leadersize/2, 0)
		self.LFDRole:SetTexture("Interface\\AddOns\\RayUI\\media\\lfd_role")
    end

    self.freebIndicators = true
    self.freebAfk = true
    self.freebHeals = true

    self.ResurrectIcon = self.Health:CreateTexture(nil, "OVERLAY")
    self.ResurrectIcon:SetPoint("TOP", self, 0, -2)
    self.ResurrectIcon:SetSize(16, 16)

    -- Range
    local range = {
        insideAlpha = 1,
        outsideAlpha = RA.db.outsideRange,
    }

    self.freebRange = RA.db.arrow and range
    self.Range = RA.db.arrow == false and range

    -- ReadyCheck
	local ReadyCheck = CreateFrame("Frame", nil, self.Health)
    ReadyCheck:SetPoint("CENTER")
    ReadyCheck:SetSize(RA.db.leadersize + 4, RA.db.leadersize + 4)
    self.ReadyCheck = ReadyCheck:CreateTexture(nil, "OVERLAY")
    self.ReadyCheck:SetPoint("TOP")
    self.ReadyCheck:SetSize(RA.db.leadersize + 4, RA.db.leadersize+ 4)

    -- Auras
    local auras = CreateFrame("Frame", nil, self)
    auras:SetSize(RA.db.aurasize, RA.db.aurasize)
    auras:SetPoint("CENTER", self.Health)
    auras.size = RA.db.aurasize
    self.freebAuras = auras

    -- Add events
    self:RegisterEvent("PLAYER_FOCUS_CHANGED", FocusTarget)
    self:RegisterEvent("RAID_ROSTER_UPDATE", FocusTarget)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", ChangedTarget)
    self:RegisterEvent("RAID_ROSTER_UPDATE", ChangedTarget)

    table.insert(RA._Objects, self)
end

function RA:Colors()
    for class, color in next, colors.class do
		RA.colorCache[class] = RA:Hex(color)
    end

    for dtype, color in next, DebuffTypeColor do
        RA.debuffColor[dtype] = RA:Hex(color)
    end
end

function RA:Raid15SmartVisibility(event)
	local inInstance, instanceType = IsInInstance()
	local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
	if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
	if not InCombatLockdown() then
		if inInstance and instanceType == "raid" and maxPlayers > 15 then
			RegisterAttributeDriver(self, "state-visibility", "hide")
			self:SetAttribute("showRaid", false)
			self:SetAttribute("showParty", false)
		elseif inInstance and instanceType == "raid" and maxPlayers <= 15 then
			RegisterAttributeDriver(self, "state-visibility", "[group:party,nogroup:raid][group:raid] show;hide")
			self:SetAttribute("showRaid", true)
			self:SetAttribute("showParty", RA.db.showgridwhenparty)
		else
			RegisterAttributeDriver(self, "state-visibility", "[@raid16,exists] hide;show")
			self:SetAttribute("showRaid", true)
			self:SetAttribute("showParty", RA.db.showgridwhenparty)
		end
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
end

function RA:Raid25SmartVisibility(event)
	local inInstance, instanceType = IsInInstance()
	local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
	if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
	if not InCombatLockdown() then
		if inInstance and instanceType == "raid" and maxPlayers <= 15 then
			RegisterAttributeDriver(self, "state-visibility", "hide")
			self:SetAttribute("showRaid", false)
			self:SetAttribute("showParty", false)
		elseif inInstance and instanceType == "raid" and maxPlayers > 15 then
			RegisterAttributeDriver(self, "state-visibility", "[group:party,nogroup:raid][group:raid] show;hide")
			self:SetAttribute("showRaid", true)
			self:SetAttribute("showParty", RA.db.showgridwhenparty)
		else
			RegisterAttributeDriver(self, "state-visibility", "[@raid16,noexists] hide;show")
			self:SetAttribute("showRaid", true)
			self:SetAttribute("showParty", RA.db.showgridwhenparty)
		end
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
end

function RA:Raid40SmartVisibility(event)
	local inInstance, instanceType = IsInInstance()
	local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
	if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
	if not InCombatLockdown() then
		if inInstance and instanceType == "pvp" and maxPlayers == 40 then
			RegisterAttributeDriver(self, "state-visibility", "[group:party,nogroup:raid][group:raid] show;hide")
			self:SetAttribute("showRaid", true)
			self:SetAttribute("showParty", RA.db.showgridwhenparty)
		else
			RegisterAttributeDriver(self, "state-visibility", "hide")
			self:SetAttribute("showRaid", false)
			self:SetAttribute("showParty", false)
		end
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
end

local pos, posRel, colX, colY
function RA:SpawnHeader(name, group, layout)
    local horiz, grow = RA.db.horizontal, RA.db.growth
	local width, height = RA.db.width, RA.db.height
	local visibility = "custom [@raid16,noexists] hide;show"

	if layout == 15 then
		width = width * 1.3
		height = height * 1.3
		visibility = "custom [@raid16,exists] hide;show"
	end

    local initconfig = [[
    self:SetWidth(%d)
    self:SetHeight(%d)
    ]]

    local point, growth, xoff, yoff
    if horiz then
        point = "LEFT"
        xoff = RA.db.spacing
        yoff = 0
        if grow == "UP" then
            growth = "BOTTOM"
            pos = "BOTTOMLEFT"
            posRel = "TOPLEFT"
            colY = RA.db.spacing
        else
            growth = "TOP"
            pos = "TOPLEFT"
            posRel = "BOTTOMLEFT"
            colY = -RA.db.spacing
        end
    else
        point = "TOP"
        xoff = 0
        yoff = -RA.db.spacing
        if grow == "RIGHT" then
            growth = "LEFT"
            pos = "TOPLEFT"
            posRel = "TOPRIGHT"
            colX = RA.db.spacing
        else
            growth = "RIGHT"
            pos = "TOPRIGHT"
            posRel = "TOPLEFT"
            colX = -RA.db.spacing
        end
    end

    local header = oUF:SpawnHeader(name, nil, visibility,
    "oUF-initialConfigFunction", (initconfig):format(R:Scale(width), R:Scale(height)),
    "showPlayer", RA.db.showplayerinparty,
    "showSolo", RA.db.showwhensolo,
    "showParty", RA.db.showgridwhenparty,
    "showRaid", true,
    "xOffset", xoff,
    "yOffset", yoff,
    "point", point,
    "sortMethod", "INDEX",
    "groupFilter", group,
    "groupingOrder", "1,2,3,4,5,6,7,8",
    "groupBy", "GROUP",
    "maxColumns", 8,
    "unitsPerColumn", 5,
    "columnSpacing", RA.db.spacing,
    "columnAnchorPoint", growth)

	header:RegisterEvent("PLAYER_ENTERING_WORLD")
	header:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	if layout == 15 then
		header:HookScript("OnEvent", RA.Raid15SmartVisibility)
	elseif layout == 25 then
		header:HookScript("OnEvent", RA.Raid25SmartVisibility)
	elseif layout == 40 then
		header:HookScript("OnEvent", RA.Raid40SmartVisibility)
	end

    return header
end

function RA:SpawnRaid()
	UIDropDownMenu_Initialize(dropdown, init, "MENU")
	backdrop = {
		bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		insets = {top = 0, left = 0, bottom = 0, right = 0},
	}
	border = {
		bgFile = R["media"].blank,
		insets = {top = -R:Scale(2), left = -R:Scale(2), bottom = -R:Scale(2), right = -R:Scale(2)},
	}
	border2 = {
		bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		insets = {top = -R.mult, left = -R.mult, bottom = -R.mult, right = -R.mult},
	}
	glowBorder = {
		bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		edgeFile = R["media"].glow, edgeSize = R:Scale(5),
		insets = {left = R:Scale(3), right = R:Scale(3), top = R:Scale(3), bottom = R:Scale(3)}
	}
	oUF:RegisterStyle("RayUFRaid", style)
	oUF:SetActiveStyle("RayUFRaid")
	RA:Colors()
	CompactRaidFrameContainer:Kill()
	CompactRaidFrameManager:Kill()
	local raid10 = {}
	for i=1, 3 do
		local group = self:SpawnHeader("RayUFRaid10_"..i, i, 15)
		if i == 1 then
			group:Point("TOPLEFT", UIParent, "BOTTOMRIGHT", - RA.db.width*1.3*3 -  RA.db.spacing*2 - 50, 461)
		else
			group:Point(pos, raid10[i-1], posRel, colX or 0, colY or 0)
		end
		raid10[i] = group
		RA._Headers[group:GetName()] = group
	end
	local raid25 = {}
	for i=1, 5 do
		local group = self:SpawnHeader("RayUFRaid25_"..i, i, 25)
		if i == 1 then
			group:Point("TOPLEFT", UIParent, "BOTTOMRIGHT", - RA.db.width*5 -  RA.db.spacing*4 - 50, 422)
		else
			group:Point(pos, raid25[i-1], posRel, colX or 0, colY or 0)
		end
		raid25[i] = group
		RA._Headers[group:GetName()] = group
	end
	if RA.db.raid40 then
		local raid40 = {}
		for i=6, 8 do
			local group = self:SpawnHeader("RayUFRaid40_"..i, i, 40)
			if i == 6 then
				group:Point("TOPLEFT", raid25[3], "TOPLEFT", 0, RA.db.height * 5 + RA.db.spacing*5 )
			else
				group:Point(pos, raid40[i-1], posRel, colX or 0, colY or 0)
			end
			raid40[i] = group
			RA._Headers[group:GetName()] = group
		end
	end
end