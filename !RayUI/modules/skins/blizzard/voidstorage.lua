local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(VoidStorageFrame, 20, 0, 0, 20)
	VoidStorageBorderFrame:DisableDrawLayer("BACKGROUND")
	VoidStorageBorderFrame:DisableDrawLayer("BORDER")
	VoidStorageDepositFrame:DisableDrawLayer("BACKGROUND")
	VoidStorageDepositFrame:DisableDrawLayer("BORDER")
	VoidStorageWithdrawFrame:DisableDrawLayer("BACKGROUND")
	VoidStorageWithdrawFrame:DisableDrawLayer("BORDER")
	VoidStorageCostFrame:DisableDrawLayer("BACKGROUND")
	VoidStorageCostFrame:DisableDrawLayer("BORDER")
	VoidStorageStorageFrame:DisableDrawLayer("BACKGROUND")
	VoidStorageStorageFrame:DisableDrawLayer("BORDER")
	VoidStorageFrameMarbleBg:Hide()
	select(2, VoidStorageFrame:GetRegions()):Hide()
	VoidStorageFrameLines:Hide()
	VoidStorageBorderFrameTitleBg:Hide()
	VoidStorageBorderFrameTopLeftCorner:Hide()
	VoidStorageBorderFrameTopBorder:Hide()
	VoidStorageBorderFrameTopRightCorner:Hide()
	VoidStorageBorderFrameTopEdge:Hide()
	VoidStorageBorderFrameHeader:Hide()
	VoidStorageStorageFrameLine1:Hide()
	VoidStorageStorageFrameLine2:Hide()
	VoidStorageStorageFrameLine3:Hide()
	VoidStorageStorageFrameLine4:Hide()
	select(12, VoidStorageDepositFrame:GetRegions()):Hide()
	select(12, VoidStorageWithdrawFrame:GetRegions()):Hide()

	for i = 1, 9 do
		local bu1 = _G["VoidStorageDepositButton"..i]
		local bu2 = _G["VoidStorageWithdrawButton"..i]

		_G["VoidStorageDepositButton"..i.."Bg"]:Hide()
		_G["VoidStorageWithdrawButton"..i.."Bg"]:Hide()

		_G["VoidStorageDepositButton"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
		_G["VoidStorageWithdrawButton"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)

		bu1:StyleButton()
		bu1:GetHighlightTexture():Point("TOPLEFT", -1, 1)
		bu1:GetHighlightTexture():Point("BOTTOMRIGHT", 1, -1)
		bu1:GetPushedTexture():Point("TOPLEFT", -1, 1)
		bu1:GetPushedTexture():Point("BOTTOMRIGHT", 1, -1)
		if not bu1.border then
			local border = CreateFrame("Frame", nil, bu1)
			border:Point("TOPLEFT", -1, 1)
			border:Point("BOTTOMRIGHT", 1, -1)
			border:SetFrameStrata("BACKGROUND")
			border:SetFrameLevel(0)
			bu1.border = border
			bu1.border:CreateBorder()
		end
		bu1:SetNormalTexture("")
		bu1:SetFrameStrata("HIGH")

		bu2:StyleButton()
		bu2:GetHighlightTexture():Point("TOPLEFT", -1, 1)
		bu2:GetHighlightTexture():Point("BOTTOMRIGHT", 1, -1)
		bu2:GetPushedTexture():Point("TOPLEFT", -1, 1)
		bu2:GetPushedTexture():Point("BOTTOMRIGHT", 1, -1)
		if not bu2.border then
			local border = CreateFrame("Frame", nil, bu2)
			border:Point("TOPLEFT", -1, 1)
			border:Point("BOTTOMRIGHT", 1, -1)
			border:SetFrameStrata("BACKGROUND")
			border:SetFrameLevel(0)
			bu2.border = border
			bu2.border:CreateBorder()
		end
		bu2:SetNormalTexture("")
		bu2:SetFrameStrata("HIGH")
	end

	for i = 1, 80 do
		local bu = _G["VoidStorageStorageButton"..i]

		_G["VoidStorageStorageButton"..i.."Bg"]:Hide()
		_G["VoidStorageStorageButton"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
		
		bu:StyleButton()
		bu:GetHighlightTexture():Point("TOPLEFT", -1, 1)
		bu:GetHighlightTexture():Point("BOTTOMRIGHT", 1, -1)
		bu:GetPushedTexture():Point("TOPLEFT", -1, 1)
		bu:GetPushedTexture():Point("BOTTOMRIGHT", 1, -1)
		if not bu.border then
			local border = CreateFrame("Frame", nil, bu)
			border:Point("TOPLEFT", -1, 1)
			border:Point("BOTTOMRIGHT", 1, -1)
			border:SetFrameStrata("BACKGROUND")
			border:SetFrameLevel(0)
			bu.border = border
			bu.border:CreateBorder()
		end
		bu:SetNormalTexture("")
		bu:SetFrameStrata("HIGH")
	end

	R.Reskin(VoidStoragePurchaseButton)
	R.Reskin(VoidStorageHelpBoxButton)
	R.Reskin(VoidStorageTransferButton)
	R.ReskinClose(VoidStorageBorderFrameCloseButton)
	R.ReskinInput(VoidItemSearchBox)
end

R.SkinFuncs["Blizzard_VoidStorageUI"] = LoadSkin