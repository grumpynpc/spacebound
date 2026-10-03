local addonName, Spacebound = ...;

--[[----------------------------------------------------------------------------
	ReturnKeyAsText
	Fallback for missing translations: the key itself is used as the text.
------------------------------------------------------------------------------]]
local function ReturnKeyAsText(localization, key)
	return key;
end

local L = setmetatable({}, { __index = ReturnKeyAsText });
Spacebound.L = L;

L["ChatPrefix"] = "|cff66bbffSpacebound|r: ";
L["InCombat"] = "Cannot change settings while in combat.";
L["Enabled"] = "Enabled.";
L["Disabled"] = "Disabled.";
L["UnknownSpell"] = "Unknown spell: %s";
L["SpellSet"] = "Falling spell set to %s.";
L["MacroSet"] = "Falling macro set.";
L["StatusEnabled"] = "Enabled: %s";
L["StatusMode"] = "Mode: %s";
L["StatusSpell"] = "Spell: %s";
L["StatusMacro"] = "Macro: %s";
L["ModeSpell"] = "Spell";
L["ModeMacro"] = "Macro";
L["None"] = "none";
L["Yes"] = YES;
L["No"] = NO;
L["Help"] = "Commands:|n"
	.. "  /sb - toggle the settings window|n"
	.. "  /sb spell <name or id> - cast this spell while falling|n"
	.. "  /sb macro <text> - run this macro while falling (use \\n for new lines)|n"
	.. "  /sb on | off - enable or disable|n"
	.. "  /sb status - show the current configuration";
L["ThisCannotBeUndone"] = RED_FONT_COLOR:WrapTextInColorCode("This cannot be undone!");
L["SettingsEnableCheckboxLabel"] = "Enable Spacebound: ";
L["SettingsUseMacroCheckboxLabel"] = "Use Macro Text: ";
L["SettingsSpellLabel"] = "Falling Spell";
L["SettingsSpellTooltip"] = "The spell cast when you press jump while falling.";
L["SettingsSpellTooltipInstruction"] = "This can be either a spell name or ID.";
L["SettingsSpellInfoNoSpellName"] = "No spell chosen";
L["SettingsSpellInfoNoSpellDescription"] = "Type in the name or ID of a spell above|nand hit " .. KEY_ENTER .. " to preview the spell.";
L["SettingsSaveButtonLabel"] = SAVE;
L["SettingsDefaultsButtonLabel"] = "Reset to Defaults";
L["SettingsDefaultsButtonTooltipEnabled"] = "Reset Spacebound to its default configuration.";
L["SettingsDefaultsButtonTooltipDisabled"] = SHIFT_KEY_TEXT .. "-CLICK to reset Spacebound to its default configuration.";
