local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(ArchaeologyFrame)
	R.Reskin(ArchaeologyFrameArtifactPageSolveFrameSolveButton)
	R.Reskin(ArchaeologyFrameArtifactPageBackButton)
	ArchaeologyFramePortrait:Hide()
	ArchaeologyFrame:DisableDrawLayer("BACKGROUND")
	ArchaeologyFrame:DisableDrawLayer("BORDER")
	ArchaeologyFrame:DisableDrawLayer("OVERLAY")
	ArchaeologyFrameInset:DisableDrawLayer("BACKGROUND")
	ArchaeologyFrameInset:DisableDrawLayer("BORDER")
	ArchaeologyFrameSummaryPageTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameArtifactPageHistoryTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameArtifactPageHistoryScrollChildText:SetTextColor(1, 1, 1)
	ArchaeologyFrameHelpPageTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameHelpPageDigTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameHelpPageHelpScrollHelpText:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPage:GetRegions():SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPageTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPageTitleTop:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPageTitleMid:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPagePageText:SetTextColor(1, 1, 1)

	for i = 1, 10 do
		_G["ArchaeologyFrameSummaryPageRace"..i]:GetRegions():SetTextColor(1, 1, 1)
	end
	for i = 1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
		local bu = _G["ArchaeologyFrameCompletedPageArtifact"..i]
		bu:GetRegions():Hide()
		select(2, bu:GetRegions()):Hide()
		select(3, bu:GetRegions()):SetTexCoord(.08, .92, .08, .92)
		select(4, bu:GetRegions()):SetTextColor(1, 1, 1)
		select(5, bu:GetRegions()):SetTextColor(1, 1, 1)
		local bg = CreateFrame("Frame", nil, bu)
		bg:Point("TOPLEFT", -1, 1)
		bg:Point("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(bu:GetFrameLevel()-1)
		R.CreateBD(bg, .25)
		local vline = CreateFrame("Frame", nil, bu)
		vline:SetPoint("LEFT", 44, 0)
		vline:SetSize(1, 44)
		R.CreateBD(vline)
	end

	ArchaeologyFrameInfoButton:Point("TOPLEFT", 3, -3)

	R.ReskinDropDown(ArchaeologyFrameRaceFilter)
	R.ReskinClose(ArchaeologyFrameCloseButton)
	R.ReskinScroll(ArchaeologyFrameArtifactPageHistoryScrollScrollBar)
	R.ReskinArrow(ArchaeologyFrameCompletedPagePrevPageButton, 1)
	R.ReskinArrow(ArchaeologyFrameCompletedPageNextPageButton, 2)
	ArchaeologyFrameCompletedPagePrevPageButtonIcon:Hide()
	ArchaeologyFrameCompletedPageNextPageButtonIcon:Hide()

	ArchaeologyFrameRankBarBorder:Hide()
	ArchaeologyFrameRankBarBackground:Hide()
	ArchaeologyFrameRankBarBar:SetTexture(C.Aurora.backdrop)
	ArchaeologyFrameRankBarBar:SetGradient("VERTICAL", 0, .65, 0, 0, .75, 0)
	ArchaeologyFrameRankBar:SetHeight(14)
	R.CreateBD(ArchaeologyFrameRankBar, .25)

	ArchaeologyFrameArtifactPageSolveFrameStatusBarBarBG:Hide()
	local bar = select(3, ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetRegions())
	bar:SetTexture(C.Aurora.backdrop)
	bar:SetGradient("VERTICAL", .65, .25, 0, .75, .35, .1)

	local bg = CreateFrame("Frame", nil, ArchaeologyFrameArtifactPageSolveFrameStatusBar)
	bg:Point("TOPLEFT", -1, 1)
	bg:Point("BOTTOMRIGHT", 1, -1)
	bg:SetFrameLevel(0)
	R.CreateBD(bg, .25)

	ArchaeologyFrameArtifactPageIcon:SetTexCoord(.08, .92, .08, .92)
	R.CreateBG(ArchaeologyFrameArtifactPageIcon)
end

R.SkinFuncs["Blizzard_ArchaeologyUI"] = LoadSkin