local addonName, Spacebound = ...;

local L = Spacebound.L;
local Settings = Spacebound.Settings;

local QUESTION_MARK_ICON = 134400;
local WINDOW_WIDTH = 300;
local LAYOUT_PADDING = 10;

local _isDirty = false;

------------
--- frame setup

local window = CreateFrame("Frame", "SpaceboundSettingsWindow", UIParent, "PortraitFrameFlatTemplate, ResizeLayoutFrame");
window:SetPoint("CENTER");
window:SetSize(WINDOW_WIDTH, 300);
window:SetMovable(true);
window:SetDontSavePosition(true);
window:Hide();
ButtonFrameTemplate_HidePortrait(window);
window.fixedWidth = WINDOW_WIDTH;
window.minimumHeight = 200;
window.heightPadding = 20;

tinsert(UISpecialFrames, window:GetName());

local dragBar = CreateFrame("Frame", nil, window, "PanelDragBarTemplate");
dragBar:SetHeight(28);
dragBar:SetPoint("TOPLEFT");
dragBar:SetPoint("TOPRIGHT");

local elements = {};

--[[----------------------------------------------------------------------------
	CreateCheckboxRow
	Creates a labelled checkbox row and adds it to the layout.
------------------------------------------------------------------------------]]
local function CreateCheckboxRow(labelText)
	local container = CreateFrame("Frame", nil, window);
	container:SetSize(WINDOW_WIDTH, 20);

	local label = container:CreateFontString(nil, "ARTWORK", "GameFontWhite");
	label:SetJustifyH("CENTER");
	label:SetText(labelText);
	label:SetPoint("TOPLEFT", 25, 0);
	label:SetPoint("BOTTOM");

	local checkbox = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate");
	checkbox:SetPoint("LEFT", container, "CENTER", WINDOW_WIDTH / 4, 0);

	tinsert(elements, container);
	return checkbox;
end

local enableCheckbox = CreateCheckboxRow(L.SettingsEnableCheckboxLabel);
local useMacroCheckbox = CreateCheckboxRow(L.SettingsUseMacroCheckboxLabel);

local macroInputContainer = CreateFrame("Frame", nil, window, "ResizeLayoutFrame");
macroInputContainer:SetSize(WINDOW_WIDTH, 100);
macroInputContainer.fixedWidth = WINDOW_WIDTH;
macroInputContainer.minimumHeight = 100;

local macroScrollFrame = CreateFrame("ScrollFrame", "SpaceboundMacroScrollFrame", macroInputContainer, "InputScrollFrameTemplate");
macroScrollFrame:SetPoint("TOPLEFT", 20, 0);
macroScrollFrame:SetPoint("BOTTOMRIGHT", -20, 0);
macroScrollFrame.EditBox:SetWidth(260);
macroScrollFrame.EditBox:SetFontObject("GameFontWhite");
macroScrollFrame.CharCount:Hide();

tinsert(elements, macroInputContainer);

local spellContainer = CreateFrame("Frame", nil, window);
spellContainer:SetSize(WINDOW_WIDTH, 20);

local spellLabel = spellContainer:CreateFontString(nil, "ARTWORK", "GameFontWhite");
spellLabel:SetJustifyH("CENTER");
spellLabel:SetText(L.SettingsSpellLabel);
spellLabel:SetPoint("TOPLEFT", 25, 0);
spellLabel:SetPoint("BOTTOM");

local spellEditBox = CreateFrame("EditBox", nil, spellContainer, "InputBoxTemplate");
spellEditBox:SetAutoFocus(false);
spellEditBox:SetFontObject("GameFontWhite");
spellEditBox:SetPoint("TOPLEFT", spellContainer, "TOP", 10, 0);
spellEditBox:SetPoint("BOTTOMRIGHT", -20, 0);

spellContainer:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	GameTooltip_SetTitle(GameTooltip, L.SettingsSpellTooltip, nil, true);
	GameTooltip_AddInstructionLine(GameTooltip, L.SettingsSpellTooltipInstruction, true);
	GameTooltip:Show();
end);
spellContainer:SetScript("OnLeave", function()
	GameTooltip:Hide();
end);

tinsert(elements, spellContainer);

local spellInfoContainer = CreateFrame("Frame", nil, window, "ResizeLayoutFrame");
spellInfoContainer:SetSize(WINDOW_WIDTH, 100);
spellInfoContainer.fixedWidth = WINDOW_WIDTH;
spellInfoContainer.minimumHeight = 100;

local spellInfoIcon = CreateFrame("Button", nil, spellInfoContainer, "UIPanelBorderedButtonTemplate");
spellInfoIcon:SetPoint("TOPLEFT", 70, 0);
spellInfoIcon:Disable();

local spellInfoName = spellInfoContainer:CreateFontString(nil, "ARTWORK", "GameFontWhite");
spellInfoName:SetPoint("LEFT", spellInfoIcon, "RIGHT", 40, 0);
spellInfoName:SetJustifyH("CENTER");

local spellInfoDescription = spellInfoContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal");
spellInfoDescription:SetPoint("TOPLEFT", 20, -45);
spellInfoDescription:SetPoint("TOPRIGHT", -20, -45);

tinsert(elements, spellInfoContainer);

local saveButtonContainer = CreateFrame("Frame", nil, window);
saveButtonContainer:SetSize(WINDOW_WIDTH, 30);

local saveButton = CreateFrame("Button", nil, saveButtonContainer, "SharedGoldRedButtonLargeTemplate");
saveButton:SetText(L.SettingsSaveButtonLabel);
saveButton:SetPoint("CENTER", saveButtonContainer, "CENTER", 0, 0);

tinsert(elements, saveButtonContainer);

local defaultsButtonContainer = CreateFrame("Frame", nil, window);
defaultsButtonContainer:SetSize(WINDOW_WIDTH, 24);

local defaultsButton = CreateFrame("Button", nil, defaultsButtonContainer, "SharedButtonSmallTemplate");
defaultsButton:SetWidth(160);
defaultsButton:SetText(L.SettingsDefaultsButtonLabel);
defaultsButton:SetPoint("CENTER", defaultsButtonContainer, "CENTER", 0, 0);
defaultsButton:Disable();

tinsert(elements, defaultsButtonContainer);

local initialAnchor = CreateAnchor("TOPLEFT", window, "TOPLEFT", 8, -38);

------------
--- behaviour

--[[----------------------------------------------------------------------------
	RebuildLayout
	Stacks the visible rows vertically and resizes the window to fit.
------------------------------------------------------------------------------]]
local function RebuildLayout()
	local activeElements = {};
	for _, element in ipairs(elements) do
		if element:IsShown() then
			tinsert(activeElements, element);
		end
	end
	AnchorUtil.VerticalLayout(activeElements, initialAnchor, LAYOUT_PADDING);
	window:Layout();
end

--[[----------------------------------------------------------------------------
	UpdateTitle
	Shows the addon name, with an asterisk when there are unsaved changes.
------------------------------------------------------------------------------]]
local function UpdateTitle()
	local title = addonName;
	if _isDirty then
		title = title .. "*";
	end
	window:SetTitle(title);
end

--[[----------------------------------------------------------------------------
	MarkDirty
	Flags unsaved changes.
------------------------------------------------------------------------------]]
local function MarkDirty()
	_isDirty = true;
	UpdateTitle();
end

--[[----------------------------------------------------------------------------
	ShowModeRows
	Shows either the macro box or the spell input rows.
------------------------------------------------------------------------------]]
local function ShowModeRows(useMacro)
	macroInputContainer:SetShown(useMacro);
	spellContainer:SetShown(not useMacro);
	spellInfoContainer:SetShown(not useMacro);
	RebuildLayout();
end

--[[----------------------------------------------------------------------------
	UpdateSpellInfo
	Shows the icon, name and description of the given spell.
------------------------------------------------------------------------------]]
local function UpdateSpellInfo(spellIdentifier)
	local icon, name, description;
	if spellIdentifier then
		icon = C_Spell.GetSpellTexture(spellIdentifier);
		name = C_Spell.GetSpellName(spellIdentifier);
		description = C_Spell.GetSpellDescription(spellIdentifier);
	else
		icon = QUESTION_MARK_ICON;
		name = L.SettingsSpellInfoNoSpellName;
		description = L.SettingsSpellInfoNoSpellDescription;
	end

	spellInfoIcon.Icon:SetTexture(icon);
	spellInfoName:SetTextToFit(name);

	-- grow the description to its full height without wrapping early
	-- see https://warcraft.wiki.gg/wiki/API_FontString_GetStringHeight
	spellInfoDescription:SetHeight(1000);
	spellInfoDescription:SetTextToFit(description);
	spellInfoDescription:SetHeight(spellInfoDescription:GetStringHeight());

	spellInfoContainer:MarkDirty();
end

--[[----------------------------------------------------------------------------
	ShowSpellPreview
	Fills the spell box and preview with the given spell.
------------------------------------------------------------------------------]]
local function ShowSpellPreview(spellIdentifier)
	spellEditBox:SetText(spellIdentifier and C_Spell.GetSpellName(spellIdentifier) or "");
	UpdateSpellInfo(spellIdentifier);
end

--[[----------------------------------------------------------------------------
	PopulateWindow
	Loads the saved settings into every control.
------------------------------------------------------------------------------]]
local function PopulateWindow()
	_isDirty = false;

	enableCheckbox:SetChecked(Settings.GetEnabled());
	useMacroCheckbox:SetChecked(Settings.GetUseMacro());
	macroScrollFrame.EditBox:SetText(Settings.GetMacroText() or "");
	ShowSpellPreview(Settings.GetSpellIdentifier());

	ShowModeRows(Settings.GetUseMacro());
	UpdateTitle();
end

--[[----------------------------------------------------------------------------
	OnSaveButtonClicked
	Writes every control back to the saved settings and applies them.
------------------------------------------------------------------------------]]
local function OnSaveButtonClicked()
	if InCombatLockdown() then
		print(L.ChatPrefix .. L.InCombat);
		return;
	end

	Settings.SetEnabled(enableCheckbox:GetChecked());
	Settings.SetUseMacro(useMacroCheckbox:GetChecked());
	Settings.SetMacroText(macroScrollFrame.EditBox:GetText());
	Settings.SetSpellIdentifier(Settings.ResolveSpellIdentifier(spellEditBox:GetText()));
	Spacebound.Refresh();

	PopulateWindow();
end

--[[----------------------------------------------------------------------------
	OnDefaultsButtonClicked
	Resets the saved settings to defaults and reloads the window.
------------------------------------------------------------------------------]]
local function OnDefaultsButtonClicked(self)
	if InCombatLockdown() then
		print(L.ChatPrefix .. L.InCombat);
		return;
	end

	Settings.ResetToDefaults();
	Spacebound.Refresh();
	PopulateWindow();
	self:Disable();
end

--[[----------------------------------------------------------------------------
	OnDefaultsButtonEnter
	Explains the Shift-click requirement of the defaults button.
------------------------------------------------------------------------------]]
local function OnDefaultsButtonEnter(self)
	local tooltipText = self:IsEnabled() and L.SettingsDefaultsButtonTooltipEnabled or L.SettingsDefaultsButtonTooltipDisabled;
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, tooltipText, nil, true);
	GameTooltip_AddNormalLine(GameTooltip, L.ThisCannotBeUndone, true, 40);
	GameTooltip:Show();
end

--[[----------------------------------------------------------------------------
	OnDefaultsButtonEvent
	Enables the defaults button only while Shift is held.
------------------------------------------------------------------------------]]
local function OnDefaultsButtonEvent(self, event)
	self:SetEnabled(IsShiftKeyDown());
	if self:IsVisible() and self:IsMouseOver() then
		OnDefaultsButtonEnter(self);
	end
end

enableCheckbox:SetScript("OnClick", MarkDirty);

useMacroCheckbox:SetScript("OnClick", function(self)
	MarkDirty();
	ShowModeRows(self:GetChecked());
end);

macroScrollFrame.EditBox:SetScript("OnTextChanged", function(self, userInput)
	if userInput then
		MarkDirty();
	end
end);

spellEditBox:SetScript("OnTextChanged", function(self, userInput)
	if userInput then
		MarkDirty();
	end
end);

spellEditBox:SetScript("OnEnterPressed", function(self)
	UpdateSpellInfo(Settings.ResolveSpellIdentifier(self:GetText()));
	self:ClearFocus();
end);

saveButton:SetScript("OnClick", OnSaveButtonClicked);

defaultsButton:SetScript("OnClick", OnDefaultsButtonClicked);
defaultsButton:SetScript("OnEnter", OnDefaultsButtonEnter);
defaultsButton:SetScript("OnLeave", function()
	GameTooltip:Hide();
end);
defaultsButton:SetScript("OnEvent", OnDefaultsButtonEvent);
defaultsButton:RegisterEvent("MODIFIER_STATE_CHANGED");

window:SetScript("OnShow", PopulateWindow);

--[[----------------------------------------------------------------------------
	Spacebound.ToggleSettingsWindow
------------------------------------------------------------------------------]]
function Spacebound.ToggleSettingsWindow()
	window:SetShown(not window:IsShown());
end

--[[----------------------------------------------------------------------------
	Spacebound.RefreshSettingsWindow
	Reloads the window if it is open, e.g. after a slash command change.
------------------------------------------------------------------------------]]
function Spacebound.RefreshSettingsWindow()
	if window:IsShown() then
		PopulateWindow();
	end
end
