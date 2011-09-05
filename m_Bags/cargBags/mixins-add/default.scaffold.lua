--[[
LICENSE
	cargBags: An inventory framework addon for World of Warcraft

	Copyright (C) 2010  Constantin "Cargor" Schomburg <xconstruct@gmail.com>

	cargBags is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	cargBags is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with cargBags; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

DESCRIPTION
	Provides a Scaffold that generates a default Blizz' ContainerButton

DEPENDENCIES
	mixins/api-common.lua
]]
local R, C = unpack(RayUI)
local addon, ns = ...
local cargBags = ns.cargBags

local function noop() end

local function ItemButton_Scaffold(self)
	self:SetSize(37, 37)

	local name = self:GetName()
	self.Icon = _G[name.."IconTexture"]
	self.Count = _G[name.."Count"]
	self.Cooldown = _G[name.."Cooldown"]
	self.Quest = _G[name.."IconQuestTexture"]
	self.Border = _G[name.."NormalTexture"]
	self.Count:SetFont(C.media.pxfont, 11, "OUTLINE,MONOCHROME")
	self.Count:SetShadowColor(0, 0, 0)
	self.Count:SetShadowOffset(R.mult, -R.mult)
end

--[[!
	Update the button with new item-information
	@param item <table> The itemTable holding information, see Implementation:GetItemInfo()
	@callback OnUpdate(item)
]]
local function ItemButton_Update(self, item)
	self.Icon:SetTexture(item.texture or self.bgTex)
	self.Icon:SetTexCoord(.08, .92, .08, .92)
	self.Border:Hide()
	if(item.count and item.count > 1) then
		self.Count:SetText(item.count >= 1e3 and "*" or item.count)
		self.Count:Show()
	else
		self.Count:Hide()
	end
	self.count = item.count -- Thank you Blizz for not using local variables >.> (BankFrame.lua @ 234 )

	self:UpdateCooldown(item)
	self:UpdateLock(item)
	self:UpdateQuest(item)

	if(self.OnUpdate) then self:OnUpdate(item) end
end

--[[!
	Updates the buttons cooldown with new item-information
	@param item <table> The itemTable holding information, see Implementation:GetItemInfo()
	@callback OnUpdateCooldown(item)
]]
local function ItemButton_UpdateCooldown(self, item)
	if(item.cdEnable == 1 and item.cdStart and item.cdStart > 0) then
		self.Cooldown:SetCooldown(item.cdStart, item.cdFinish)
		self.Cooldown:Show()
	else
		self.Cooldown:Hide()
	end

	if(self.OnUpdateCooldown) then self:OnUpdateCooldown(item) end
end

--[[!
	Updates the buttons lock with new item-information
	@param item <table> The itemTable holding information, see Implementation:GetItemInfo()
	@callback OnUpdateLock(item)
]]
local function ItemButton_UpdateLock(self, item)
	self.Icon:SetDesaturated(item.locked)

	if(self.OnUpdateLock) then self:OnUpdateLock(item) end
end

--[[!
	Updates the buttons quest texture with new item information
	@param item <table> The itemTable holding information, see Implementation:GetItemInfo()
	@callback OnUpdateQuest(item)
]]
local function ItemButton_UpdateQuest(self, item)
	local r,g,b,a = 1,1,1,1
	local tL,tR,tT,tB = 0,1, 0,1
	local blend = "BLEND"
	local texture

	if(item.questID and not item.questActive) then
		texture = TEXTURE_ITEM_QUEST_BANG
	elseif(item.questID or item.isQuestItem) then
		texture = TEXTURE_ITEM_QUEST_BORDER
	elseif(item.rarity and item.rarity > 1 and self.glowTex) then
		a, r,g,b = self.glowAlpha, GetItemQualityColor(item.rarity)
		texture = self.glowTex
		blend = self.glowBlend
		tL,tR,tT,tB = unpack(self.glowCoords)
	end

	if(not self.glow) then
		self.glow = CreateFrame("Frame",nil,self)
		self.glow:Point("TOPLEFT", 0, 0)
		self.glow:Point("BOTTOMRIGHT", 0, 0)
		self.glow:CreateBorder()
	end

	if(texture) then
		if item.questID then
			r, g, b = 1, 0, 0
		else
			if(r==1) then r, g, b = 1, 1, 0 end
		end
		self.glow:SetBackdropBorderColor(r, g, b)
		self.glow:Show()
	else
		self.glow:Hide()
	end
	
	if (item.rarity) then
		-- self:SetAlpha(1)
	else
		-- self:SetAlpha(0)
	end

	if(self.OnUpdateQuest) then self:OnUpdateQuest(item) end
end

cargBags:RegisterScaffold("Default", function(self)
	self.glowTex = "" --! @property glowTex <string> The textures used for the glow
	self.glowAlpha = 0.8 --! @property glowAlpha <number> The alpha of the glow texture
	self.glowBlend = "ADD" --! @property glowBlend <string> The blendMode of the glow texture
	self.glowCoords = { 16/64, 48/64, 16/64, 48/64 } --! @property glowCoords <table> Indexed table of texCoords for the glow texture
	self.bgTex = nil --! @property bgTex <string> Texture used as a background if no item is in the slot

	self.CreateFrame = ItemButton_CreateFrame
	self.Scaffold = ItemButton_Scaffold

	self.Update = ItemButton_Update
	self.UpdateCooldown = ItemButton_UpdateCooldown
	self.UpdateLock = ItemButton_UpdateLock
	self.UpdateQuest = ItemButton_UpdateQuest

	self.OnEnter = ItemButton_OnEnter
	self.OnLeave = ItemButton_OnLeave
end)
