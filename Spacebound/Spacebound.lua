local addonName, Spacebound = ...;

local Settings = Spacebound.Settings;

local _jumpKeyPrimary, _jumpKeySecondary;
local _inCombat = InCombatLockdown();

local keyWatcherFrame = CreateFrame("Frame");

local macroButton = CreateFrame("Button", Spacebound.MACRO_BUTTON_NAME, nil, "SecureActionButtonTemplate");
macroButton:SetAttribute("type", "macro");
macroButton:RegisterForClicks("AnyDown", "AnyUp");

--[[----------------------------------------------------------------------------
	IsJumpKey
	True when the pressed key is bound to the game's JUMP action.
------------------------------------------------------------------------------]]
local function IsJumpKey(key)
	return key == _jumpKeyPrimary or key == _jumpKeySecondary;
end

--[[----------------------------------------------------------------------------
	ShouldHandleJump
	True when the jump key may be redirected right now.
------------------------------------------------------------------------------]]
local function ShouldHandleJump()
	return Settings.GetEnabled() and not IsMounted() and not UnitIsDeadOrGhost("player");
end

--[[----------------------------------------------------------------------------
	Spacebound.Refresh
	Applies saved settings: updates the macro button and drops any active
	override so the next jump key press re-evaluates. No-op in combat.
------------------------------------------------------------------------------]]
function Spacebound.Refresh()
	if InCombatLockdown() then
		return;
	end

	macroButton:SetAttribute("macrotext", Settings.GetMacroText() or "");
	ClearOverrideBindings(keyWatcherFrame);
	Spacebound.UpdateCombatButton();
end

--[[----------------------------------------------------------------------------
	OnKeyDown
	Before the key press reaches the bindings, point the jump key at the
	configured action while falling, and back at jump while grounded.
------------------------------------------------------------------------------]]
local function OnKeyDown(self, key)
	if _inCombat or not IsJumpKey(key) then
		return;
	end

	if IsFalling() and ShouldHandleJump() then
		local command = Settings.GetOverrideCommand();
		if command then
			SetOverrideBinding(self, true, key, command);
		end
	else
		ClearOverrideBindings(self);
	end
end

--[[----------------------------------------------------------------------------
	OnEvent
------------------------------------------------------------------------------]]
local function OnEvent(self, event, ...)
	if event == "ADDON_LOADED" then
		if ... == addonName then
			Settings.Initialize();
			self:UnregisterEvent("ADDON_LOADED");
		end
	elseif event == "PLAYER_LOGIN" then
		_jumpKeyPrimary, _jumpKeySecondary = GetBindingKey("JUMP");
		Spacebound.Refresh();
	elseif event == "UPDATE_BINDINGS" then
		_jumpKeyPrimary, _jumpKeySecondary = GetBindingKey("JUMP");
	elseif event == "PLAYER_REGEN_DISABLED" then
		_inCombat = true;
		ClearOverrideBindings(self);
	elseif event == "PLAYER_REGEN_ENABLED" then
		_inCombat = false;
	end
end

keyWatcherFrame:SetScript("OnEvent", OnEvent);
keyWatcherFrame:SetScript("OnKeyDown", OnKeyDown);
keyWatcherFrame:SetPropagateKeyboardInput(true);
keyWatcherFrame:RegisterEvent("ADDON_LOADED");
keyWatcherFrame:RegisterEvent("PLAYER_LOGIN");
keyWatcherFrame:RegisterEvent("UPDATE_BINDINGS");
keyWatcherFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
keyWatcherFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
