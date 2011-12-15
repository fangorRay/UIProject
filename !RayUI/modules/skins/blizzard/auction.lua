local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	local r, g, b = C.Aurora.classcolours[R.myclass].r, C.Aurora.classcolours[R.myclass].g, C.Aurora.classcolours[R.myclass].b
	R.SetBD(AuctionFrame, 2, -10, 0, 10)
	R.CreateBD(AuctionProgressFrame)

	SideDressUpModel:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:SetPoint("LEFT", self:GetParent():GetParent(), "RIGHT", 1, 0)
	end)
	SideDressUpModel.bg = CreateFrame("Frame", nil, SideDressUpModel)
	SideDressUpModel.bg:SetPoint("TOPLEFT", 0, 1)
	SideDressUpModel.bg:SetPoint("BOTTOMRIGHT", 1, -1)
	SideDressUpModel.bg:SetFrameLevel(SideDressUpModel:GetFrameLevel()-1)
	R.CreateBD(SideDressUpModel.bg)
	R.Reskin(SideDressUpModelResetButton)
	R.ReskinClose(SideDressUpModelCloseButton)
	select(5, SideDressUpModelCloseButton:GetRegions()):Hide()

	AuctionProgressBar:SetStatusBarTexture(C.Aurora.backdrop)
	local ABBD = CreateFrame("Frame", nil, AuctionProgressBar)
	ABBD:SetPoint("TOPLEFT", -1, 1)
	ABBD:SetPoint("BOTTOMRIGHT", 1, -1)
	ABBD:SetFrameLevel(AuctionProgressBar:GetFrameLevel()-1)
	R.CreateBD(ABBD, .25)

	AuctionProgressBarIcon:SetTexCoord(.08, .92, .08, .92)
	R.CreateBG(AuctionProgressBarIcon)

	AuctionProgressBarText:SetPoint("CENTER")

	R.ReskinClose(AuctionProgressFrameCancelButton, "LEFT", AuctionProgressBar, "RIGHT", 4, 0)
	select(15, AuctionProgressFrameCancelButton:GetRegions()):SetPoint("CENTER", 0, 2)

	AuctionFrame:DisableDrawLayer("ARTWORK")
	AuctionPortraitTexture:Hide()
	for i = 1, 4 do
		select(i, AuctionProgressFrame:GetRegions()):Hide()
	end
	AuctionProgressBarBorder:Hide()
	for i = 1, 4 do
		select(i, SideDressUpFrame:GetRegions()):Hide()
	end
	BrowseFilterScrollFrame:GetRegions():Hide()
	select(2, BrowseFilterScrollFrame:GetRegions()):Hide()
	BrowseScrollFrame:GetRegions():Hide()
	select(2, BrowseScrollFrame:GetRegions()):Hide()
	BidScrollFrame:GetRegions():Hide()
	select(2, BidScrollFrame:GetRegions()):Hide()
	AuctionsScrollFrame:GetRegions():Hide()
	select(2, AuctionsScrollFrame:GetRegions()):Hide()
	BrowseQualitySort:DisableDrawLayer("BACKGROUND")
	BrowseLevelSort:DisableDrawLayer("BACKGROUND")
	BrowseDurationSort:DisableDrawLayer("BACKGROUND")
	BrowseHighBidderSort:DisableDrawLayer("BACKGROUND")
	BrowseCurrentBidSort:DisableDrawLayer("BACKGROUND")
	BidQualitySort:DisableDrawLayer("BACKGROUND")
	BidLevelSort:DisableDrawLayer("BACKGROUND")
	BidDurationSort:DisableDrawLayer("BACKGROUND")
	BidBuyoutSort:DisableDrawLayer("BACKGROUND")
	BidStatusSort:DisableDrawLayer("BACKGROUND")
	BidBidSort:DisableDrawLayer("BACKGROUND")
	AuctionsQualitySort:DisableDrawLayer("BACKGROUND")
	AuctionsDurationSort:DisableDrawLayer("BACKGROUND")
	AuctionsHighBidderSort:DisableDrawLayer("BACKGROUND")
	AuctionsBidSort:DisableDrawLayer("BACKGROUND")

	for i = 1, NUM_FILTERS_TO_DISPLAY do
		_G["AuctionFilterButton"..i]:SetNormalTexture("")
	end

	for i = 1, 3 do
		R.CreateTab(_G["AuctionFrameTab"..i])
	end

	local abuttons = {
		"BrowseBidButton",
		"BrowseBuyoutButton",
		"BrowseCloseButton",
		"BrowseSearchButton",
		"BrowseResetButton",
		"BidBidButton",
		"BidBuyoutButton",
		"BidCloseButton",
		"AuctionsCloseButton",
		"SideDressUpModelResetButton",
		"AuctionsCancelAuctionButton",
		"AuctionsCreateAuctionButton",
		"AuctionsNumStacksMaxButton",
		"AuctionsStackSizeMaxButton"
	}
	for i = 1, #abuttons do
		local reskinbutton = _G[abuttons[i]]
		if reskinbutton then
			R.Reskin(reskinbutton)
		end
	end

	BrowseCloseButton:ClearAllPoints()
	BrowseCloseButton:SetPoint("BOTTOMRIGHT", AuctionFrameBrowse, "BOTTOMRIGHT", 66, 13)
	BrowseBuyoutButton:ClearAllPoints()
	BrowseBuyoutButton:SetPoint("RIGHT", BrowseCloseButton, "LEFT", -1, 0)
	BrowseBidButton:ClearAllPoints()
	BrowseBidButton:SetPoint("RIGHT", BrowseBuyoutButton, "LEFT", -1, 0)
	BidBuyoutButton:ClearAllPoints()
	BidBuyoutButton:SetPoint("RIGHT", BidCloseButton, "LEFT", -1, 0)
	BidBidButton:ClearAllPoints()
	BidBidButton:SetPoint("RIGHT", BidBuyoutButton, "LEFT", -1, 0)
	AuctionsCancelAuctionButton:ClearAllPoints()
	AuctionsCancelAuctionButton:SetPoint("RIGHT", AuctionsCloseButton, "LEFT", -1, 0)
	BrowseSearchButton:ClearAllPoints()
	BrowseSearchButton:SetPoint("TOPRIGHT", AuctionFrameBrowse, "TOPRIGHT", 25, -30)
	
	-- Blizz needs to be more consistent

	BrowseBidPriceSilver:SetPoint("LEFT", BrowseBidPriceGold, "RIGHT", 1, 0)
	BrowseBidPriceCopper:SetPoint("LEFT", BrowseBidPriceSilver, "RIGHT", 1, 0)
	BidBidPriceSilver:SetPoint("LEFT", BidBidPriceGold, "RIGHT", 1, 0)
	BidBidPriceCopper:SetPoint("LEFT", BidBidPriceSilver, "RIGHT", 1, 0)
	StartPriceSilver:SetPoint("LEFT", StartPriceGold, "RIGHT", 1, 0)
	StartPriceCopper:SetPoint("LEFT", StartPriceSilver, "RIGHT", 1, 0)
	BuyoutPriceSilver:SetPoint("LEFT", BuyoutPriceGold, "RIGHT", 1, 0)
	BuyoutPriceCopper:SetPoint("LEFT", BuyoutPriceSilver, "RIGHT", 1, 0)

	for i = 1, NUM_BROWSE_TO_DISPLAY do
		local bu = _G["BrowseButton"..i]
		local it = _G["BrowseButton"..i.."Item"]
		local ic = _G["BrowseButton"..i.."ItemIconTexture"]

		if bu and it then
			it:SetNormalTexture("")
			ic:SetTexCoord(.08, .92, .08, .92)

			R.CreateBG(it)

			_G["BrowseButton"..i.."Left"]:Hide()
			select(6, _G["BrowseButton"..i]:GetRegions()):Hide()
			_G["BrowseButton"..i.."Right"]:Hide()

			local bd = CreateFrame("Frame", nil, bu)
			bd:SetPoint("TOPLEFT")
			bd:SetPoint("BOTTOMRIGHT", 0, 5)
			bd:SetFrameLevel(bu:GetFrameLevel()-1)
			R.CreateBD(bd, .25)

			bu:SetHighlightTexture(C.Aurora.backdrop)
			local hl = bu:GetHighlightTexture()
			hl:SetVertexColor(r, g, b, .2)
			hl:ClearAllPoints()
			hl:SetPoint("TOPLEFT", 0, -1)
			hl:SetPoint("BOTTOMRIGHT", -1, 6)

			it:StyleButton()
			it:GetHighlightTexture():SetAllPoints()
			it:GetPushedTexture():SetAllPoints()
		end
	end

	for i = 1, NUM_BIDS_TO_DISPLAY do
		local bu = _G["BidButton"..i]
		local it = _G["BidButton"..i.."Item"]
		local ic = _G["BidButton"..i.."ItemIconTexture"]

		it:SetNormalTexture("")
		ic:SetTexCoord(.08, .92, .08, .92)

		R.CreateBG(it)

		_G["BidButton"..i.."Left"]:Hide()
		select(6, _G["BidButton"..i]:GetRegions()):Hide()
		_G["BidButton"..i.."Right"]:Hide()

		local bd = CreateFrame("Frame", nil, bu)
		bd:SetPoint("TOPLEFT")
		bd:SetPoint("BOTTOMRIGHT", 0, 5)
		bd:SetFrameLevel(bu:GetFrameLevel()-1)
		R.CreateBD(bd, .25)

		bu:SetHighlightTexture(C.Aurora.backdrop)
		local hl = bu:GetHighlightTexture()
		hl:SetVertexColor(r, g, b, .2)
		hl:ClearAllPoints()
		hl:SetPoint("TOPLEFT", 0, -1)
		hl:SetPoint("BOTTOMRIGHT", -1, 6)

		it:StyleButton()
		it:GetHighlightTexture():SetAllPoints()
		it:GetPushedTexture():SetAllPoints()
	end

	for i = 1, NUM_AUCTIONS_TO_DISPLAY do
		local bu = _G["AuctionsButton"..i]
		local it = _G["AuctionsButton"..i.."Item"]
		local ic = _G["AuctionsButton"..i.."ItemIconTexture"]

		it:SetNormalTexture("")
		ic:SetTexCoord(.08, .92, .08, .92)

		R.CreateBG(it)

		_G["AuctionsButton"..i.."Left"]:Hide()
		select(5, _G["AuctionsButton"..i]:GetRegions()):Hide()
		_G["AuctionsButton"..i.."Right"]:Hide()

		local bd = CreateFrame("Frame", nil, bu)
		bd:SetPoint("TOPLEFT")
		bd:SetPoint("BOTTOMRIGHT", 0, 5)
		bd:SetFrameLevel(bu:GetFrameLevel()-1)
		R.CreateBD(bd, .25)

		bu:SetHighlightTexture(C.Aurora.backdrop)
		local hl = bu:GetHighlightTexture()
		hl:SetVertexColor(r, g, b, .2)
		hl:ClearAllPoints()
		hl:SetPoint("TOPLEFT", 0, -1)
		hl:SetPoint("BOTTOMRIGHT", -1, 6)

		it:StyleButton()
		it:GetHighlightTexture():SetAllPoints()
		it:GetPushedTexture():SetAllPoints()
	end

	local auctionhandler = CreateFrame("Frame")
	auctionhandler:RegisterEvent("NEW_AUCTION_UPDATE")
	auctionhandler:SetScript("OnEvent", function()
		local _, _, _, _, _, _, _, _, _, _, _, _, _, AuctionsItemButtonIconTexture = AuctionsItemButton:GetRegions() -- blizzard, please name your textures
		if AuctionsItemButtonIconTexture then
			AuctionsItemButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
			AuctionsItemButtonIconTexture:SetPoint("TOPLEFT", 1, -1)
			AuctionsItemButtonIconTexture:SetPoint("BOTTOMRIGHT", -1, 1)
		end
	end)

	R.CreateBD(AuctionsItemButton, .25)
	local _, AuctionsItemButtonNameFrame = AuctionsItemButton:GetRegions()
	AuctionsItemButtonNameFrame:Hide()

	R.ReskinClose(AuctionFrameCloseButton, "TOPRIGHT", AuctionFrame, "TOPRIGHT", -4, -14)
	R.ReskinScroll(BrowseScrollFrameScrollBar)
	R.ReskinScroll(AuctionsScrollFrameScrollBar)
	R.ReskinScroll(BrowseFilterScrollFrameScrollBar)
	R.ReskinDropDown(PriceDropDown)
	R.ReskinDropDown(DurationDropDown)
	R.ReskinInput(BrowseName)
	R.ReskinArrow(BrowsePrevPageButton, 1)
	R.ReskinArrow(BrowseNextPageButton, 2)
	R.ReskinCheck(IsUsableCheckButton)
	R.ReskinCheck(ShowOnPlayerCheckButton)
	
	BrowsePrevPageButton:GetRegions():SetPoint("LEFT", BrowsePrevPageButton, "RIGHT", 2, 0)

	-- seriously, consistency
	BrowseDropDownLeft:SetAlpha(0)
	BrowseDropDownMiddle:SetAlpha(0)
	BrowseDropDownRight:SetAlpha(0)

	local a1, p, a2, x, y = BrowseDropDownButton:GetPoint()
	BrowseDropDownButton:SetPoint(a1, p, a2, x, y-4)
	BrowseDropDownButton:SetSize(16, 16)
	R.Reskin(BrowseDropDownButton)

	local downtex = BrowseDropDownButton:CreateTexture(nil, "OVERLAY")
	downtex:SetTexture("Interface\\AddOns\\!RayUI\\media\\arrow-down-active")
	downtex:SetSize(8, 8)
	downtex:SetPoint("CENTER")
	downtex:SetVertexColor(1, 1, 1)

	local bg = CreateFrame("Frame", nil, BrowseDropDown)
	bg:SetPoint("TOPLEFT", 16, -5)
	bg:SetPoint("BOTTOMRIGHT", 109, 11)
	bg:SetFrameLevel(BrowseDropDown:GetFrameLevel(-1))
	R.CreateBD(bg, 0)

	local tex = bg:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT")
	tex:SetPoint("BOTTOMRIGHT")
	tex:SetTexture(C.Aurora.backdrop)
	tex:SetGradientAlpha("VERTICAL", 0, 0, 0, .3, .35, .35, .35, .35)

	local inputs = {
		"BrowseMinLevel",
		"BrowseMaxLevel",
		"BrowseBidPriceGold",
		"BrowseBidPriceSilver",
		"BrowseBidPriceCopper",
		"BidBidPriceGold",
		"BidBidPriceSilver",
		"BidBidPriceCopper",
		"StartPriceGold",
		"StartPriceSilver",
		"StartPriceCopper",
		"BuyoutPriceGold",
		"BuyoutPriceSilver",
		"BuyoutPriceCopper",
		"AuctionsStackSizeEntry",
		"AuctionsNumStacksEntry"
	}
	for i = 1, #inputs do
		R.ReskinInput(_G[inputs[i]])
	end
	
	BrowseMinLevel:SetPoint("TOPLEFT", BrowseLevelText, "BOTTOMLEFT", -7, -1)
	BrowseDropDown:SetPoint("TOPLEFT", BrowseLevelText, "BOTTOMRIGHT", 2, 4)
	BrowseNameText:ClearAllPoints()
	BrowseNameText:SetPoint("TOPLEFT", AuctionFrameBrowse, "TOPLEFT", 75, -44)
end

R.SkinFuncs["Blizzard_AuctionUI"] = LoadSkin