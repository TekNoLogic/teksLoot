

local backdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}


local function ClickRoll(frame)
	frame.clicked = which
	RollOnLoot(frame.parent.rollid, frame.rolltype)
end


local function HideTip() GameTooltip:Hide() end
local function HideTip2() GameTooltip:Hide(); ResetCursor() end


local function SetTip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetText(frame.tiptext)
	GameTooltip:Show()
end


local function SetItemTip(frame)
	if not frame.link then return end
	GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
	GameTooltip:SetHyperlink(frame.link)
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	CursorUpdate()
end


local function ItemOnUpdate()
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	CursorOnUpdate()
end


local function LootClick(frame)
	if IsControlKeyDown() then DressUpItemLink(frame.link)
	elseif IsShiftKeyDown() then ChatEdit_InsertLink(frame.link) end
end


local function OnEvent(frame, event, rollid)
	if frame.rollid ~= rollid then return end

	frame.rollid = nil
	frame.time = nil
	frame:Hide()
end


local function StatusUpdate(frame)
	local t = GetLootRollTimeLeft(frame.parent.rollid)
	local perc = t / frame.parent.time
	frame.spark:SetPoint("CENTER", frame, "LEFT", perc * frame:GetWidth(), 0)
	frame:SetValue(t)
end


local function CreateRollButton(parent, ntex, ptex, htex, rolltype, tiptext, ...)
	local f = CreateFrame("Button", nil, parent)
	f:SetPoint(...)
	f:SetWidth(28)
	f:SetHeight(28)
	f:SetNormalTexture(ntex)
	if ptex then f:SetPushedTexture(ptex) end
	f:SetHighlightTexture(htex)
	f.rolltype = rolltype
	f.parent = parent
	f.tiptext = tiptext
	f:SetScript("OnEnter", SetTip)
	f:SetScript("OnLeave", HideTip)
	f:SetScript("OnClick", ClickRoll)
	return f
end


local function CreateRollFrame()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetWidth(300)
	frame:SetHeight(26)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0, 0, 0, .9)
	frame:SetScript("OnEvent", OnEvent)
	frame:RegisterEvent("CANCEL_LOOT_ROLL")

	local button = CreateFrame("Button", nil, frame)
	button:SetPoint("LEFT", 5, 0)
	button:SetWidth(24)
	button:SetHeight(24)
	button:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	button:GetHighlightTexture():SetBlendMode("ADD")
	button:SetScript("OnEnter", SetItemTip)
	button:SetScript("OnLeave", HideTip2)
	button:SetScript("OnUpdate", ItemOnUpdate)
	button:SetScript("OnClick", LootClick)
	frame.button = button

	local buttonborder = CreateFrame("Frame", nil, button)
	buttonborder:SetWidth(32)
	buttonborder:SetHeight(32)
	buttonborder:SetPoint("CENTER", button, "CENTER")
	buttonborder:SetBackdrop(backdrop)
	buttonborder:SetBackdropColor(1, 1, 1, 0)
	frame.buttonborder = buttonborder

	local tfade = frame:CreateTexture(nil, "BORDER")
	tfade:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
	tfade:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
	tfade:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	tfade:SetBlendMode("ADD")
	tfade:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .25, .25, .25, 1)

	local status = CreateFrame("StatusBar", nil, frame)
	status:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
	status:SetPoint("BOTTOM", frame, "BOTTOM", 0, 4)
	status:SetPoint("LEFT", frame.button, "RIGHT", -1, 0)
	status:SetScript("OnUpdate", StatusUpdate)
	status:SetFrameLevel(status:GetFrameLevel()-1)
	status:SetStatusBarTexture("Interface\\AddOns\\teksLoot\\DarkBottom.tga")
	status:SetStatusBarColor(.8, .8, .8, .9)
	status.parent = frame
	frame.status = status

	local spark = frame:CreateTexture(nil, "OVERLAY")
	spark:SetWidth(14)
	spark:SetHeight(35)
	spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	spark:SetBlendMode("ADD")
	status.spark = spark

	local need = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Dice-Up", "Interface\\Buttons\\UI-GroupLoot-Dice-Highlight", "Interface\\Buttons\\UI-GroupLoot-Dice-Down", 1, NEED, "LEFT", frame.button, "RIGHT", 5, -1)
	local greed = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Coin-Up", "Interface\\Buttons\\UI-GroupLoot-Coin-Highlight", "Interface\\Buttons\\UI-GroupLoot-Coin-Down", 2, GREED, "LEFT", need, "RIGHT", 0, -1)
	local pass = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", nil, "Interface\\Buttons\\UI-GroupLoot-Pass-Down", 0, PASS, "LEFT", greed, "RIGHT", 0, 2.2)

	local bind = frame:CreateFontString()
	bind:SetPoint("LEFT", pass, "RIGHT", 3, 1)
	bind:SetFont("Fonts\\FRIZQT__.TTF", 13, "THICKOUTLINE")
	frame.fsbind = bind

	local loot = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	loot:SetPoint("LEFT", bind, "RIGHT", 0, .12)
	loot:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
	loot:SetHeight(16)
	loot:SetJustifyH("LEFT")
	frame.fsloot = loot

	return frame
end


local anchor = CreateFrame("Button", nil, UIParent)
anchor:SetWidth(300) anchor:SetHeight(22)
anchor:SetBackdrop(backdrop)
anchor:SetBackdropColor(0.25, 0.25, 0.25, 1)
local label = anchor:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
label:SetAllPoints(anchor)
label:SetText("teksLoot")

anchor:SetScript("OnClick", anchor.Hide)
anchor:SetScript("OnDragStart", anchor.StartMoving)
anchor:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	self.db.x, self.db.y = self:GetCenter()
end)
anchor:SetMovable(true)
anchor:EnableMouse(true)
anchor:RegisterForDrag("LeftButton")
anchor:RegisterForClicks("RightButtonUp")
anchor:Hide()

local frames = {}
local function GetFrame()
	for i,f in ipairs(frames) do
		if not f.rollid then return f end
	end

	local f = CreateRollFrame()
	f:SetPoint("TOPLEFT", next(frames) and frames[#frames] or anchor, "BOTTOMLEFT", 0, -4)
	table.insert(frames, f)
	return f
end


anchor:RegisterEvent("ADDON_LOADED")
anchor:SetScript("OnEvent", function(frame, event, addon)
	if addon ~= "teksLoot" then return end

	anchor:UnregisterEvent("ADDON_LOADED")
	anchor:RegisterEvent("START_LOOT_ROLL")
	UIParent:UnregisterEvent("START_LOOT_ROLL")
	UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")

	anchor:SetScript("OnEvent", function(frame, event, rollid, time)
		local f = GetFrame()
		f.rollid = rollid
		f.time = time

		local texture, name, count, quality, bop = GetLootRollItemInfo(rollid)
		f.button:SetNormalTexture(texture)
		f.button.link = GetLootRollItemLink(rollid)

		f.fsbind:SetText(bop and "BoP" or "BoE")
		f.fsbind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)

		local color = ITEM_QUALITY_COLORS[quality]
		f.fsloot:SetVertexColor(color.r, color.g, color.b)
		f.fsloot:SetText(name)

		f:SetBackdropBorderColor(color.r, color.g, color.b, 1)
		f.buttonborder:SetBackdropBorderColor(color.r, color.g, color.b, 1)
		f.status:SetStatusBarColor(color.r, color.g, color.b, .7)

		f.status:SetMinMaxValues(0, time)
		f.status:SetValue(time)

		f:SetPoint("CENTER", WorldFrame, "CENTER")
		f:Show()
	end)

	if not teksLootDB then teksLootDB = {} end
	anchor.db = teksLootDB
	anchor:SetPoint("CENTER", UIParent, anchor.db.x and "BOTTOMLEFT" or "BOTTOM", anchor.db.x or 0, anchor.db.y or 221)
end)


SlashCmdList["TEKSLOOT"] = function() if anchor:IsVisible() then anchor:Hide() else anchor:Show() end end
SLASH_TEKSLOOT1 = "/teksloot"

