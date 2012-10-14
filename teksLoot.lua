
local myname, ns = ...


local backdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}


local function ClickRoll(frame)
	if IsShiftKeyDown() then ConfirmLootRoll(frame.parent.rollid, frame.rolltype)
	else RollOnLoot(frame.parent.rollid, frame.rolltype) end
end


local function HideTip() GameTooltip:Hide() end
local function HideTip2() GameTooltip:Hide(); ResetCursor() end


local rolltypes = {"need", "greed", "disenchant", [0] = "pass"}
local function SetTip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetText(frame.tiptext)
	if not frame:IsEnabled() then
		GameTooltip:AddLine("|cffff3333"..frame.errtext)
	end
	for name,roll in pairs(frame.parent.rolls) do if roll == rolltypes[frame.rolltype] then GameTooltip:AddLine(name, 1, 1, 1) end end
	GameTooltip:AddLine('', 1, 1, 1)
	GameTooltip:AddLine('Shift-click to bypass the confirm dialog', 1, 1, 1)
	GameTooltip:Show()
end


local function SetItemTip(frame)
	if not frame.link then return end
	GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
	GameTooltip:SetHyperlink(frame.link)
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
end


local function ItemOnUpdate(self)
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	CursorOnUpdate(self)
end


local function LootClick(frame)
	if IsControlKeyDown() then DressUpItemLink(frame.link)
	elseif IsShiftKeyDown() then ChatEdit_InsertLink(frame.link) end
end


local cancelled_rolls = {}
local function OnEvent(frame, event, rollid)
	cancelled_rolls[rollid] = true
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
	f:SetMotionScriptsWhileDisabled(true)
	local txt = f:CreateFontString(nil, nil, "GameFontHighlightSmallOutline")
	txt:SetPoint("CENTER", 0, rolltype == 2 and 1 or rolltype == 0 and -1.2 or 0)
	return f, txt
end


local function CreateRollFrame()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetWidth(328)
	frame:SetHeight(26)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0, 0, 0, .9)
	frame:SetScript("OnEvent", OnEvent)
	frame:RegisterEvent("CANCEL_LOOT_ROLL")
	frame:Hide()

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

	local need, needtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Dice-Up", "Interface\\Buttons\\UI-GroupLoot-Dice-Highlight", "Interface\\Buttons\\UI-GroupLoot-Dice-Down", 1, NEED, "LEFT", frame.button, "RIGHT", 5, -1)
	local greed, greedtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Coin-Up", "Interface\\Buttons\\UI-GroupLoot-Coin-Highlight", "Interface\\Buttons\\UI-GroupLoot-Coin-Down", 2, GREED, "LEFT", need, "RIGHT", 0, -1)
	local de, detext
	de, detext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-DE-Up", "Interface\\Buttons\\UI-GroupLoot-DE-Highlight", "Interface\\Buttons\\UI-GroupLoot-DE-Down", 3, ROLL_DISENCHANT, "LEFT", greed, "RIGHT", 0, -1)
	local pass, passtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", nil, "Interface\\Buttons\\UI-GroupLoot-Pass-Down", 0, PASS, "LEFT", de or greed, "RIGHT", 0, 2.2)
	frame.needbutt, frame.greedbutt, frame.disenchantbutt = need, greed, de
	frame.need, frame.greed, frame.pass, frame.disenchant = needtext, greedtext, passtext, detext

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

	frame.rolls = {}

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

local f = CreateRollFrame() -- Create one for good measure
f:SetPoint("TOPLEFT", next(frames) and frames[#frames] or anchor, "BOTTOMLEFT", 0, -4)
table.insert(frames, f)

local function GetFrame()
	for i,f in ipairs(frames) do
		if not f.rollid then return f end
	end

	local f = CreateRollFrame()
	f:SetPoint("TOPLEFT", next(frames) and frames[#frames] or anchor, "BOTTOMLEFT", 0, -4)
	table.insert(frames, f)
	return f
end


local function FindFrame(rollid)
	for _,f in ipairs(frames) do
		if f.rollid == rollid then return f end
	end
end


local typemap = {[0] = 'pass', 'need', 'greed', 'disenchant'}
local function UpdateRoll(i, rolltype)
	local num = 0
	local rollid, itemLink, numPlayers, isDone = C_LootHistory.GetItem(i)

	if isDone or not numPlayers then return end

	local f = FindFrame(rollid)
	if not f then return end

	for j=1,numPlayers do
		local name, class, thisrolltype = C_LootHistory.GetPlayerInfo(i, j)
		f.rolls[name] = typemap[thisrolltype]
		if rolltype == thisrolltype then num = num + 1 end
	end

	f[typemap[rolltype]]:SetText(num)
end

local function START_LOOT_ROLL(rollid, time)
	if cancelled_rolls[rollid] then return end

	local f = GetFrame()
	f.rollid = rollid
	f.time = time
	for i in pairs(f.rolls) do f.rolls[i] = nil end
	f.need:SetText(0)
	f.greed:SetText(0)
	f.pass:SetText(0)
	f.disenchant:SetText(0)

	local texture, name, count, quality, bop, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired = GetLootRollItemInfo(rollid)
	f.button:SetNormalTexture(texture)
	f.button.link = GetLootRollItemLink(rollid)

	if canNeed then
		f.needbutt:Enable()
		f.needbutt:SetAlpha(1.0)
		SetDesaturation(f.needbutt:GetNormalTexture(), false)
	else
		f.needbutt:Disable()
		f.needbutt:SetAlpha(0.35)
		SetDesaturation(f.needbutt:GetNormalTexture(), true)
		f.needbutt.errtext = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonNeed]
	end

	if canGreed then
		f.greedbutt:Enable()
		f.greedbutt:SetAlpha(1.0)
		SetDesaturation(f.greedbutt:GetNormalTexture(), false)
	else
		f.greedbutt:Disable()
		f.greedbutt:SetAlpha(0.35)
		SetDesaturation(f.greedbutt:GetNormalTexture(), true)
		f.greedbutt.errtext = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonGreed]
	end

	if canDisenchant then
		f.disenchantbutt:Enable()
		f.disenchantbutt:SetAlpha(1.0)
		SetDesaturation(f.disenchantbutt:GetNormalTexture(), false)
	else
		f.disenchantbutt:Disable()
		f.disenchantbutt:SetAlpha(0.35)
		SetDesaturation(f.disenchantbutt:GetNormalTexture(), true)
		f.disenchantbutt.errtext = format(_G["LOOT_ROLL_INELIGIBLE_REASON"..reasonDisenchant], deSkillRequired)
	end

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
end


local function LOOT_HISTORY_ROLL_CHANGED(rollindex, playerindex)
	local _, _, rolltype = C_LootHistory.GetPlayerInfo(rollindex, playerindex)
	UpdateRoll(rollindex, rolltype)
end


anchor:RegisterEvent("ADDON_LOADED")
anchor:SetScript("OnEvent", function(frame, event, addon)
	if addon ~= "teksLoot" then return end

	anchor:UnregisterEvent("ADDON_LOADED")
	anchor:RegisterEvent("START_LOOT_ROLL")
	anchor:RegisterEvent("LOOT_HISTORY_ROLL_CHANGED")
	UIParent:UnregisterEvent("START_LOOT_ROLL")
	UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")

	anchor:SetScript("OnEvent", function(frame, event, ...)
		if event == "LOOT_HISTORY_ROLL_CHANGED" then return LOOT_HISTORY_ROLL_CHANGED(...)
		else return START_LOOT_ROLL(...) end
	end)


	if not teksLootDB then teksLootDB = {} end
	anchor.db = teksLootDB
	anchor:SetPoint("CENTER", UIParent, anchor.db.x and "BOTTOMLEFT" or "BOTTOM", anchor.db.x or 0, anchor.db.y or 221)
end)


SlashCmdList["TEKSLOOT"] = function() if anchor:IsVisible() then anchor:Hide() else anchor:Show() end end
SLASH_TEKSLOOT1 = "/teksloot"

