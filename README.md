# Spacebound

A World of Warcraft **Forever** addon that lets you bind a spell or macro to your jump key without unbinding jump.

- **On the ground:** the jump key jumps, as usual.
- **While falling:** the jump key casts your chosen spell or runs your chosen macro.

Jump, then press jump again mid-air to cast a slow fall or immunity effect and avoid fall damage. Spacebound follows whatever key is bound to Jump in your keybindings, not just the spacebar.

Mages default to **Slow Fall**. Every other class can pick any spell or macro.

## Installation

Copy the `Spacebound/` folder (the inner one, containing `Spacebound.toc`) into:

```
World of Warcraft\_classic_beta_\Interface\AddOns\
```

Disable any other addon that also rebinds the jump key while falling (e.g. SlowFaller).

## Usage

| Command | Description |
|---|---|
| `/sb` or `/spacebound` | Toggle the settings window |
| `/sb spell <name or id>` | Cast this spell while falling |
| `/sb macro <text>` | Run this macro while falling (use `\n` for new lines) |
| `/sb on` / `/sb off` | Enable or disable Spacebound |
| `/sb status` | Print the current configuration |

The settings window offers the same options: an enable toggle, a spell or macro mode, a spell preview, the combat button options below, and a Shift-click **Reset to Defaults** button.

Settings are saved per character.

| Spell mode | Macro mode |
|---|---|
| ![Spell mode](screenshots/Spacebound1.png) | ![Macro mode](screenshots/Spacebound2.png) |

## Combat button

WoW blocks addons from changing keybindings during combat, so in combat the jump key only jumps. Instead, you can enable the optional **combat button**: an on-screen button you click while falling to cast the same spell or macro.

Turn it on with **Show combat button** in the settings window (it's off by default). While that box is ticked, the window also shows:

- **Grounded opacity** (0–100%, default 10%): how visible the button is in combat while you're on the ground. While falling it is always fully visible.
- **Button size** (24–192px, default 96px).

By default the button is centered horizontally, 120px from the top of the screen. While the settings window is open, the button stays on screen so you can drag it into place. Clicks are ignored while you position it. The position is saved per character.

The button shows your spell's icon. In macro mode it uses the spell or item from `#showtooltip`, or else the first `/cast`, `/use` or `/castsequence` line. `[conditions]` are evaluated, so the icon follows modifiers and targets. If nothing matches, it shows the question-mark macro icon.

## Limitations

- The combat button is shown for the whole fight and is still clickable while you're on the ground, even at 0% grounded opacity. WoW does not let addons show or hide it during combat, and macro conditions have no way to check for falling.
- The button's size and position can't change during combat.
- For `/castsequence` macros, the icon shows the first spell in the sequence, not the next one to cast.

## Development

The addon source lives in `Spacebound/`. For editor support, use [lua-language-server](https://github.com/LuaLS/lua-language-server) with the [WoW API annotations](https://github.com/Ketho/vscode-wow-api).
