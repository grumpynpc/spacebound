local addonName, Spacebound = ...;

local L = Spacebound.L;
local Settings = Spacebound.Settings;

--[[----------------------------------------------------------------------------
	PrintMessage
------------------------------------------------------------------------------]]
local function PrintMessage(text)
	print(L.ChatPrefix .. text);
end

--[[----------------------------------------------------------------------------
	ApplyChanges
	Applies saved settings and refreshes the window after a command.
------------------------------------------------------------------------------]]
local function ApplyChanges()
	Spacebound.Refresh();
	Spacebound.RefreshSettingsWindow();
end

--[[----------------------------------------------------------------------------
	PrintStatus
	Prints the current configuration to chat.
------------------------------------------------------------------------------]]
local function PrintStatus()
	local spellIdentifier = Settings.GetSpellIdentifier();
	local spellName = spellIdentifier and C_Spell.GetSpellName(spellIdentifier) or L.None;
	local macroText = Settings.GetMacroText();
	if macroText == "" then
		macroText = L.None;
	end

	PrintMessage(L.StatusEnabled:format(Settings.GetEnabled() and L.Yes or L.No));
	PrintMessage(L.StatusMode:format(Settings.GetUseMacro() and L.ModeMacro or L.ModeSpell));
	PrintMessage(L.StatusSpell:format(spellName));
	PrintMessage(L.StatusMacro:format(macroText));
end

--[[----------------------------------------------------------------------------
	HandleSlashCommand
	Entry point for /spacebound and /sb.
------------------------------------------------------------------------------]]
local function HandleSlashCommand(message)
	local command, argument = message:match("^%s*(%S*)%s*(.-)%s*$");
	command = command:lower();

	if command == "" then
		Spacebound.ToggleSettingsWindow();
		return;
	end

	if command == "status" then
		PrintStatus();
		return;
	end

	if command ~= "spell" and command ~= "macro" and command ~= "on" and command ~= "off" then
		PrintMessage(L.Help);
		return;
	end

	if InCombatLockdown() then
		PrintMessage(L.InCombat);
		return;
	end

	if command == "on" or command == "off" then
		Settings.SetEnabled(command == "on");
		PrintMessage(command == "on" and L.Enabled or L.Disabled);
	elseif command == "spell" then
		local spellIdentifier = Settings.ResolveSpellIdentifier(argument);
		if not spellIdentifier then
			PrintMessage(L.UnknownSpell:format(argument));
			return;
		end
		Settings.SetSpellIdentifier(spellIdentifier);
		Settings.SetUseMacro(false);
		PrintMessage(L.SpellSet:format(C_Spell.GetSpellName(spellIdentifier)));
	else
		Settings.SetMacroText((argument:gsub("\\n", "\n")));
		Settings.SetUseMacro(true);
		PrintMessage(L.MacroSet);
	end

	ApplyChanges();
end

SLASH_SPACEBOUND1, SLASH_SPACEBOUND2 = "/spacebound", "/sb";
SlashCmdList.SPACEBOUND = HandleSlashCommand;
