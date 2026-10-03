local addonName, Spacebound = ...;

local MACRO_BUTTON_NAME = "SpaceboundMacroButton";
local SLOW_FALL_SPELL_IDENTIFIER = 1259416;

local _, PLAYER_CLASS = UnitClass("player");

--[[----------------------------------------------------------------------------
	GetDefaultSettings
	Returns a fresh copy of the default per-character settings.
------------------------------------------------------------------------------]]
local function GetDefaultSettings()
	return {
		Enabled = true,
		UseMacro = false,
		MacroText = "",
		SpellIdentifier = PLAYER_CLASS == "MAGE" and SLOW_FALL_SPELL_IDENTIFIER or nil,
	};
end

local Settings = {};
Spacebound.Settings = Settings;
Spacebound.MACRO_BUTTON_NAME = MACRO_BUTTON_NAME;

--[[----------------------------------------------------------------------------
	Settings.Initialize
	Creates the saved settings on first load and fills in any missing keys.
------------------------------------------------------------------------------]]
function Settings.Initialize()
	if type(SPACEBOUND_SETTINGS) ~= "table" then
		SPACEBOUND_SETTINGS = GetDefaultSettings();
		return;
	end

	for key, value in pairs(GetDefaultSettings()) do
		if SPACEBOUND_SETTINGS[key] == nil then
			SPACEBOUND_SETTINGS[key] = value;
		end
	end
end

--[[----------------------------------------------------------------------------
	Settings.ResetToDefaults
	Replaces the saved settings with the defaults.
------------------------------------------------------------------------------]]
function Settings.ResetToDefaults()
	SPACEBOUND_SETTINGS = GetDefaultSettings();
end

--[[----------------------------------------------------------------------------
	Settings.GetEnabled
------------------------------------------------------------------------------]]
function Settings.GetEnabled()
	return SPACEBOUND_SETTINGS.Enabled;
end

--[[----------------------------------------------------------------------------
	Settings.SetEnabled
------------------------------------------------------------------------------]]
function Settings.SetEnabled(enabled)
	SPACEBOUND_SETTINGS.Enabled = enabled;
end

--[[----------------------------------------------------------------------------
	Settings.GetUseMacro
------------------------------------------------------------------------------]]
function Settings.GetUseMacro()
	return SPACEBOUND_SETTINGS.UseMacro;
end

--[[----------------------------------------------------------------------------
	Settings.SetUseMacro
------------------------------------------------------------------------------]]
function Settings.SetUseMacro(useMacro)
	SPACEBOUND_SETTINGS.UseMacro = useMacro;
end

--[[----------------------------------------------------------------------------
	Settings.GetMacroText
------------------------------------------------------------------------------]]
function Settings.GetMacroText()
	return SPACEBOUND_SETTINGS.MacroText;
end

--[[----------------------------------------------------------------------------
	Settings.SetMacroText
------------------------------------------------------------------------------]]
function Settings.SetMacroText(macroText)
	SPACEBOUND_SETTINGS.MacroText = macroText;
end

--[[----------------------------------------------------------------------------
	Settings.GetSpellIdentifier
------------------------------------------------------------------------------]]
function Settings.GetSpellIdentifier()
	return SPACEBOUND_SETTINGS.SpellIdentifier;
end

--[[----------------------------------------------------------------------------
	Settings.SetSpellIdentifier
------------------------------------------------------------------------------]]
function Settings.SetSpellIdentifier(spellIdentifier)
	SPACEBOUND_SETTINGS.SpellIdentifier = spellIdentifier;
end

--[[----------------------------------------------------------------------------
	Settings.ResolveSpellIdentifier
	Turns a spell name or ID string into a spell ID, or nil if unknown.
------------------------------------------------------------------------------]]
function Settings.ResolveSpellIdentifier(text)
	local spellIdentifier = tonumber(text);
	if not spellIdentifier then
		spellIdentifier = C_Spell.GetSpellIDForSpellIdentifier(text);
	end

	if spellIdentifier and C_Spell.GetSpellName(spellIdentifier) then
		return spellIdentifier;
	end
end

--[[----------------------------------------------------------------------------
	Settings.GetOverrideCommand
	Returns the binding command to put on the jump key while falling,
	or nil when nothing is configured.
------------------------------------------------------------------------------]]
function Settings.GetOverrideCommand()
	if Settings.GetUseMacro() then
		local macroText = Settings.GetMacroText();
		if macroText and macroText ~= "" then
			return "CLICK " .. MACRO_BUTTON_NAME .. ":LeftButton";
		end
	else
		local spellIdentifier = Settings.GetSpellIdentifier();
		local spellName = spellIdentifier and C_Spell.GetSpellName(spellIdentifier);
		if spellName then
			return "SPELL " .. spellName;
		end
	end
end
