local addonName, Spacebound = ...;

local Settings = Spacebound.Settings;

local QUESTION_MARK_ICON = 134400;
local ICON_REFRESH_INTERVAL = 0.2;

local _isPreviewing = false;
local _secondsSinceIconRefresh = 0;

-- Override bindings are blocked in combat, so this button is the fallback:
-- a secure state driver shows it for the whole of combat (no [falling]
-- conditional exists) and OnUpdate makes it fully visible only while falling.
local combatButton = CreateFrame("Button", "SpaceboundCombatButton", UIParent, "SecureActionButtonTemplate");
combatButton:SetMovable(true);
combatButton:SetDontSavePosition(true);
combatButton:SetClampedToScreen(true);
combatButton:RegisterForClicks("AnyDown", "AnyUp");
combatButton:RegisterForDrag("LeftButton");
combatButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD");
combatButton:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
combatButton:Hide();

local icon = combatButton:CreateTexture(nil, "ARTWORK");
icon:SetAllPoints();

--[[----------------------------------------------------------------------------
	GetIconForName
	Returns the icon of a spell or item name, or nil if neither is known.
------------------------------------------------------------------------------]]
local function GetIconForName(name)
	name = name:gsub("^!", "");
	return C_Spell.GetSpellTexture(name) or C_Item.GetItemIconByID(name);
end

--[[----------------------------------------------------------------------------
	GetMacroIcon
	Resolves a macro's icon the way #showtooltip does: from the #showtooltip
	argument, else the first /cast, /use or /castsequence line. Conditionals
	are evaluated, so the icon follows modifiers and targets.
------------------------------------------------------------------------------]]
local function GetMacroIcon(macroText)
	for line in macroText:gmatch("[^\n]+") do
		local command, arguments = line:match("^%s*([#/]%S+)%s*(.-)%s*$");
		command = command and command:lower();

		local result;
		if command == "#showtooltip" or command == "#show" or command == "/cast" or command == "/use" then
			if arguments ~= "" then
				result = SecureCmdOptionParse(arguments);
			end
		elseif command == "/castsequence" then
			local sequence = SecureCmdOptionParse(arguments);
			if sequence then
				sequence = sequence:gsub("^reset=%S+%s*", "");
				result = sequence:match("^([^,]+)");
			end
		end

		result = result and result:match("^%s*(.-)%s*$");
		if result and result ~= "" then
			local texture = GetIconForName(result);
			if texture then
				return texture;
			end
		end
	end

	return QUESTION_MARK_ICON;
end

--[[----------------------------------------------------------------------------
	RefreshIcon
	Shows the configured spell's icon, or the macro's resolved icon.
------------------------------------------------------------------------------]]
local function RefreshIcon()
	if Settings.GetUseMacro() then
		icon:SetTexture(GetMacroIcon(Settings.GetMacroText() or ""));
	else
		local spellIdentifier = Settings.GetSpellIdentifier();
		icon:SetTexture(spellIdentifier and C_Spell.GetSpellTexture(spellIdentifier) or QUESTION_MARK_ICON);
	end
end

--[[----------------------------------------------------------------------------
	ApplyPreview
	Shows the button for dragging, with clicks disabled.
------------------------------------------------------------------------------]]
local function ApplyPreview()
	UnregisterStateDriver(combatButton, "visibility");
	combatButton:SetAttribute("type", nil);
	combatButton:SetAlpha(1);
	combatButton:Show();
end

--[[----------------------------------------------------------------------------
	Spacebound.UpdateCombatButton
	Applies saved settings to the button: position, size, action, icon and
	the combat visibility driver. No-op in combat.
------------------------------------------------------------------------------]]
function Spacebound.UpdateCombatButton()
	if InCombatLockdown() then
		return;
	end

	local point, relativePoint, x, y = Settings.GetCombatButtonPosition();
	combatButton:ClearAllPoints();
	combatButton:SetPoint(point, UIParent, relativePoint, x, y);

	local size = Settings.GetCombatButtonSize();
	combatButton:SetSize(size, size);

	if Settings.GetUseMacro() then
		combatButton:SetAttribute("type", "macro");
		combatButton:SetAttribute("macrotext", Settings.GetMacroText() or "");
	else
		combatButton:SetAttribute("type", "spell");
		combatButton:SetAttribute("spell", Settings.GetSpellIdentifier());
	end
	RefreshIcon();

	if _isPreviewing then
		ApplyPreview();
		return;
	end

	if Settings.GetEnabled() and Settings.GetShowCombatButton() and Settings.GetOverrideCommand() then
		RegisterStateDriver(combatButton, "visibility", "[combat] show; hide");
	else
		UnregisterStateDriver(combatButton, "visibility");
		combatButton:Hide();
	end
end

--[[----------------------------------------------------------------------------
	Spacebound.SetCombatButtonPreview
	Shows the button for dragging while the settings window is open, or
	returns it to normal combat behaviour. No-op in combat.
------------------------------------------------------------------------------]]
function Spacebound.SetCombatButtonPreview(isPreviewing)
	if InCombatLockdown() then
		return;
	end

	if not isPreviewing then
		combatButton:StopMovingOrSizing();
	end

	_isPreviewing = isPreviewing;
	Spacebound.UpdateCombatButton();
end

--[[----------------------------------------------------------------------------
	Spacebound.SetCombatButtonPreviewSize
	Resizes the preview button live, before the size is saved.
------------------------------------------------------------------------------]]
function Spacebound.SetCombatButtonPreviewSize(size)
	if _isPreviewing and not InCombatLockdown() then
		combatButton:SetSize(size, size);
	end
end

--[[----------------------------------------------------------------------------
	OnUpdate
	In combat, fully shows the button while falling and uses the grounded
	opacity otherwise. Keeps conditional macro icons up to date.
------------------------------------------------------------------------------]]
local function OnUpdate(self, elapsed)
	if not _isPreviewing then
		self:SetAlpha(IsFalling() and 1 or Settings.GetCombatButtonGroundedOpacity());
	end

	_secondsSinceIconRefresh = _secondsSinceIconRefresh + elapsed;
	if _secondsSinceIconRefresh >= ICON_REFRESH_INTERVAL then
		_secondsSinceIconRefresh = 0;
		RefreshIcon();
	end
end

--[[----------------------------------------------------------------------------
	OnDragStart
------------------------------------------------------------------------------]]
local function OnDragStart(self)
	if _isPreviewing and not InCombatLockdown() then
		self:StartMoving();
	end
end

--[[----------------------------------------------------------------------------
	OnDragStop
	Saves the new position.
------------------------------------------------------------------------------]]
local function OnDragStop(self)
	self:StopMovingOrSizing();

	local point, _, relativePoint, x, y = self:GetPoint();
	Settings.SetCombatButtonPosition(point, relativePoint, x, y);
end

--[[----------------------------------------------------------------------------
	OnEvent
	Ends the preview just before combat lockdown so the button works.
------------------------------------------------------------------------------]]
local function OnEvent(self, event)
	if _isPreviewing then
		Spacebound.SetCombatButtonPreview(false);
	end
end

combatButton:SetScript("OnUpdate", OnUpdate);
combatButton:SetScript("OnDragStart", OnDragStart);
combatButton:SetScript("OnDragStop", OnDragStop);
combatButton:SetScript("OnEvent", OnEvent);
combatButton:RegisterEvent("PLAYER_REGEN_DISABLED");
