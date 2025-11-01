# 🔫 Sniper Tag - Garry's Mod Addon

Een intense competitieve hide-and-seek gamemode tussen twee spelers: één Sniper en één Hider.

## 📋 Beschrijving

**Sniper Tag** is een spannende 1v1 gamemode waarin een goed uitgeruste Sniper moet jagen op een kwetsbare maar slimme Hider. De Sniper heeft 100 HP en krachtige wapens inclusief een thermal camera, terwijl de Hider slechts 11 HP heeft maar beschikt over een invisibility cloak en andere survival tools. Wie wint: de jager of de gejaagde?

## ✨ Features

### 🎮 Core Gameplay
- **1v1 Competitive Gamemode**: Spannende duels tussen Sniper en Hider
- **Role-Based Equipment**: Unieke wapens en tools per rol
- **Round Timer System**: Configureerbare speeltijd (5-60 minuten)
- **Win Conditions**: 
  - Sniper wint door Hider te elimineren
  - Hider wint door te overleven tot tijd op is

### 🚀 Advanced Mechanics
- **Intelligent Spawn System**: 
  - **3000+ units** minimum afstand tussen spelers
  - Automatische "furthest point" berekening op grote maps
  - Anti-stuck Z-offset van +10 units
- **Anti-Camping Systeem**: 
  - Detecteert spelers die **60 seconden** stilstaan binnen 200 unit radius
  - **10 seconden** waarschuwing voordat locatie revealed wordt
  - Creëert **3D marker** prop bij revealed positie
  - Blijft actief tot speler beweegt buiten detection radius

### 🖥️ Visual & UI
- **Thermal Vision Systeem**:
  - Volledige screen filter met kleurgradiënt (koud blauw → heet wit)
  - Post-processing effecten: grain/noise, vignette, scanning lines
  - Temperature HUD overlay met gradient bar
  - Dual-color player halos (Hider: wit/geel, Sniper: oranje/rood)
  - Werkt door muren en tijdens cloak
- **Comprehensive HUD**:
  - Round timer (MM:SS formaat, top center)
  - Role indicator met health display
  - Cooldown timers voor thermal camera
  - **Grote cloak countdown** (center screen, pulsing effect)
  - Warnings bij <10 seconden remaining
  - Anti-camping waarschuwingen
  - Revealed position markers
- **In-Game Menu** (Q-menu):
  - Player selection dropdowns (Sniper/Hider)
  - Round duration slider (5-60 min)
  - Admin-only access met server-side validatie
  - Live game rules weergave

### 🛡️ Balancing & Protection
- **Damage Control**: Geen friendly fire, alleen Sniper→Hider damage
- **Weapon Restrictions**: Players kunnen geen extra wapens oppakken tijdens round
- **Cloak Balancing**: Lange cooldown (3 min) vs korte gebruik (60s)
- **Thermal Counter**: Beperkte gebruik tijd (20s) + cooldown (20s)

### 🟦 Sniper Loadout
- **Sniper Rifle**: `arc9_eft_sv98` - Krachtig long-range wapen
- **Flashbang**: `arc9_eft_m7290` - Tactische granaat
- **Thermal Camera**: Custom thermal vision systeem
  - **20 seconden** actieve gebruik tijd
  - **20 seconden** cooldown
  - **Volledige thermal imaging**: Blauw→Rood kleurspectrum
  - **Speler highlighting**: Hider licht fel op in wit/geel (hoge hitte-signaal)
  - **Scanning lines & HUD overlay** voor realistisch effect
  - **Werkt door muren** en detecteert zelfs invisible Hiders
- **Health**: 100 HP

### 🟨 Hider Loadout
- **Knife**: `arc9_eft_melee_wycc` - Melee wapen voor noodgevallen
- **Cloak Device**: Geavanceerd invisibility systeem
  - **60 seconden** complete onzichtbaarheid
  - **3 minuten** cooldown
  - **Grote countdown display** tijdens active cloak
  - **Waarschuwing** bij laatste 10 seconden
- **Marker Gun**: Troll weapon zonder damage
  - Stuurt "You have been marked" bericht naar Sniper
  - Geen gameplay impact, puur psychologisch
  - Screen flash effect bij hit
- **Health**: 11 HP (blijf in beweging!)

## 📦 Installatie

### Methode 1: Steam Workshop (Aanbevolen)
1. Subscribe naar de addon op Steam Workshop
2. Start Garry's Mod
3. De addon wordt automatisch geladen

### Methode 2: Handmatige Installatie
1. Download de addon
2. Pak uit naar: `GarrysMod/garrysmod/addons/`
3. Herstart Garry's Mod

## 🎯 Hoe te Spelen

### Voor Admins/Hosts:

1. **Open het menu**:
   - Via Q-Menu: `Utilities → Admin → Sniper Tag`
   - Of via console: `snipertag_menu`

2. **Configureer de ronde**:
   - Stel de ronde duur in (5-60 minuten)
   - Selecteer een speler als Sniper
   - Selecteer een speler als Hider

3. **Start de ronde**:
   - Klik op "START ROUND"
   - Beide spelers worden automatisch uitgerust en gespawned

### Voor Spelers:

#### Als Sniper 🟦:
- **Doel**: Vind en elimineer de Hider voordat de tijd om is
- **Thermal Camera**: 
  - Linker muisknop = activeren (20s gebruik)
  - Rechter muisknop = deactiveren
  - **Thermal Vision Features**:
    - Volledige screen filter: Koud (blauw) → Heet (rood/wit)
    - Hider licht fel op in wit/geel (hoge hitte-signaal)
    - Sniper zelf zichtbaar in oranje/rood
    - Werkt **door muren** en tijdens cloak!
    - Temperature gradient HUD overlay
    - Scanning lines & noise effects voor realism
  - Cooldown: 20 seconden na gebruik
- **Strategie**: 
  - Gebruik thermal strategisch op verdachte locaties
  - Let op de camping alerts (geeft Hider locatie weg)
  - Thermal ziet door cloak, maar heeft beperkte tijd

#### Als Hider 🟨:
- **Doel**: Overleef tot de timer afloopt
- **Cloak Device**:
  - Linker muisknop = activeren (60s onzichtbaar)
  - Rechter muisknop = deactiveren
  - **Complete invisibility**: Speler + alle wapens worden transparent
  - **Grote countdown** in center screen tijdens gebruik
  - **Waarschuwing** bij laatste 10 seconden (pulsing red)
  - Cooldown: 3 minuten
- **Marker Gun**:
  - Richt op Sniper en schiet om troll message te sturen
  - "You have been marked" bericht + screen flash
  - Doet geen damage, puur psychologisch
- **Strategie**:
  - BLIJF BEWEGEN! Stilstaan >60s revealt je positie
  - Je krijgt 10 seconden waarschuwing voordat je locatie wordt gerevealed
  - Gebruik cloak slim (lange cooldown!)
  - Thermal camera kan je ZIE zelfs tijdens cloak!

## 🚫 Anti-Camping Mechanic

Het anti-camping systeem houdt de Hider actief en voorkomt saai stilstaan:

- **Detection Radius**: 200 units (~2.5 meter)
- **Detection Time**: 60 seconden stilstaan binnen radius
- **Warning System**: 
  - Bij **50 seconden**: ⚠️ Eerste waarschuwing "MOVE NOW!" op scherm
  - Bij **60 seconden**: Positie wordt **gerevealed** aan Sniper
- **Reveal Effect**:
  - 3D marker prop spawnt op Hider locatie (10 seconden zichtbaar)
  - Sniper ziet marker + afstand indicator in wereld
  - Blijft actief tot Hider meer dan 200 units beweegt
- **Hider Check**: System checkt elke seconde positie via Think hook

## 🎮 Console Commands

### Admin Commands:
```
snipertag_menu                           # Open settings menu
snipertag_assign_sniper <player_name>   # Assign Sniper role
snipertag_assign_hider <player_name>    # Assign Hider role
snipertag_start                          # Start round
snipertag_stop                           # Stop current round
snipertag_setduration <minutes>          # Set round duration (5-60)
```

## 🔧 Vereisten

### Aanbevolen (maar niet vereist):
- **ARC9 Base**: Voor de standaard wapens (SV98, M7290, WYCC knife)
- Als je ARC9 niet hebt, kun je de weapon class names aanpassen in `lua/snipertag/shared/sh_config.lua`

### Alternatieve Wapens:
Als je geen ARC9 hebt, pas deze aan in de config:
```lua
SniperTag.Config.Weapons = {
    Sniper = {
        Primary = "weapon_smg1",        -- Vervang met gewenst wapen
        Secondary = "weapon_frag",       -- Vervang met gewenst wapen
        Melee = "weapon_thermal"         -- Custom weapon (blijft hetzelfde)
    },
    Hider = {
        Primary = "weapon_cloak",        -- Custom weapon (blijft hetzelfde)
        Secondary = "weapon_marker",     -- Custom weapon (blijft hetzelfde)
        Melee = "weapon_crowbar"         -- Vervang met gewenst wapen
    }
}
```

## 📁 Bestandsstructuur

```
sniper tag/
├── addon.json                                    # Steam Workshop metadata
├── README.md                                     # Volledige documentatie
└── lua/
    ├── autorun/
    │   ├── server/
    │   │   └── sv_snipertag_init.lua            # Server initialisatie + AddCSLuaFile
    │   └── client/
    │       └── cl_snipertag_init.lua            # Client initialisatie
    ├── snipertag/
    │   ├── shared/
    │   │   ├── sh_config.lua                    # Configuratie (HP, cooldowns, spawn distance)
    │   │   └── sh_debug.lua                     # Error handling systeem
    │   ├── server/
    │   │   ├── sv_rounds.lua                    # Round lifecycle, timer, win conditions
    │   │   ├── sv_player.lua                    # Role assignment, spawning, commands
    │   │   └── sv_anticamping.lua               # Think hook, position tracking
    │   └── client/
    │       ├── cl_hud.lua                       # HUD rendering (timer, cooldowns, cloak)
    │       └── cl_menu.lua                      # Derma menu interface (Q-menu)
    └── weapons/
        ├── weapon_thermal/
        │   └── shared.lua                       # Thermal camera SWEP (RenderScreenspaceEffects)
        ├── weapon_cloak/
        │   └── shared.lua                       # Invisibility device SWEP
        └── weapon_marker/
            └── shared.lua                       # Troll gun SWEP
```

## 🎨 Customization

### Config File: `lua/snipertag/shared/sh_config.lua`

Alle gameplay parameters zijn configureerbaar:

#### Spawn Settings:
```lua
MinSpawnDistance = 3000,        -- Minimum units afstand tussen spawns
SpawnOffset = Vector(0, 0, 10)  -- Z-offset om stuck te voorkomen
```

#### Health Settings:
```lua
SniperHP = 100,                 -- Sniper health
HiderHP = 11                    -- Hider health (kwetsbaar!)
```

#### Thermal Camera Settings:
```lua
ThermalDuration = 20,           -- Seconden actief
ThermalCooldown = 20            -- Seconden cooldown
```

#### Cloak Device Settings:
```lua
CloakDuration = 60,             -- Seconden invisible
CloakCooldown = 180             -- Seconden cooldown (3 min)
```

#### Anti-Camping Settings:
```lua
CampRadius = 200,               -- Detection radius in units
CampTime = 60,                  -- Seconden voordat reveal
CampWarningTime = 10,           -- Seconden waarschuwing vooraf
RevealDuration = 10             -- Seconden dat marker zichtbaar blijft
```

#### Round Settings:
```lua
MinRoundDuration = 5,           -- Minimum minuten
MaxRoundDuration = 60,          -- Maximum minuten
DefaultRoundDuration = 30       -- Default minuten
```

### Weapon Loadouts Aanpassen:
```lua
Weapons = {
    Sniper = {
        Primary = "arc9_eft_sv98",      -- Vervang met gewenst wapen
        Secondary = "arc9_eft_m7290",    -- Vervang met gewenst wapen
        Melee = "weapon_thermal"         -- Custom weapon
    },
    Hider = {
        Primary = "weapon_cloak",        -- Custom weapon
        Secondary = "weapon_marker",     -- Custom weapon
        Melee = "arc9_eft_melee_wycc"   -- Vervang met gewenst wapen
    }
}
```

## 🐛 Troubleshooting

### Addon laadt niet:
- ✅ Controleer of `addon.json` aanwezig is in de hoofdmap
- ✅ Check console voor errors (`~` key)
- ✅ Verify file structure matches documentatie

### Weapons spawnen niet:
- ✅ Zorg dat ARC9 geïnstalleerd is, OF
- ✅ Pas weapon class names aan in `sh_config.lua` naar vanilla weapons
- ✅ Check console: "Attempted to create unknown entity type"

### HUD niet zichtbaar:
- ✅ Controleer of `cl_drawhud 1` is ingesteld in console
- ✅ Check of je een role hebt gekregen (Sniper/Hider)
- ✅ Refresh met: `lua_run_cl include("snipertag/client/cl_hud.lua")`

### Thermal Camera werkt niet:
- ✅ Check of je Sniper role hebt
- ✅ Kijk naar cooldown timer in HUD (20s cooldown)
- ✅ Gebruik linker muisknop om te activeren
- ✅ Console errors checken voor RenderScreenspaceEffects issues

### Cloak Device werkt niet:
- ✅ Check of je Hider role hebt
- ✅ Kijk naar cooldown timer (3 min)
- ✅ Grote countdown moet verschijnen bij activatie
- ✅ Test met `lua_run print(LocalPlayer():GetNWBool("SniperTag_Cloaked"))`

### Menu niet zichtbaar in Q-Menu:
- ✅ Alleen admins kunnen het zien
- ✅ Check met: `lua_run_cl OpenSniperTagMenu()`
- ✅ Verify je bent admin: `ulx who` of `sam who`

### Round start niet:
- ✅ Zorg dat beide rollen zijn toegewezen (Sniper + Hider)
- ✅ Minimaal 2 spelers nodig
- ✅ Check console voor error messages
- ✅ Probeer manual command: `snipertag_start`

### Anti-Camping triggert niet:
- ✅ Alleen Hider wordt getracked
- ✅ Check CampRadius in config (default 200 units)
- ✅ Wacht 60 seconden binnen radius
- ✅ Console print elke 5 seconden: "ANTICAMPING CHECK"

### Players spawnen te dichtbij:
- ✅ Verhoog `MinSpawnDistance` in config (default 3000)
- ✅ Kleine maps kunnen geen grote distance garanderen
- ✅ Check console: "Spawn distance: X units"

## 📝 Changelog

### Version 1.0 (Initial Release)
- ✅ Complete 1v1 gamemode: Sniper vs Hider
- ✅ Custom SWEP weapons:
  - Thermal Camera (full thermal vision filter + player highlighting)
  - Cloak Device (complete invisibility voor speler + wapens)
  - Marker Gun (psychological troll weapon)
- ✅ Comprehensive HUD:
  - Round timer (MM:SS format, top center)
  - Role indicators met HP display
  - Cooldown timers (thermal/cloak)
  - Large cloak countdown (center screen, pulsing)
  - Anti-camping warnings
- ✅ Q-Menu integration met admin-only access
- ✅ Anti-camping mechanisme:
  - Think hook position tracking
  - 60 seconden detection, 10 seconden warning
  - 3D marker prop bij reveal
- ✅ Intelligent spawn system:
  - 3000+ units minimum distance
  - Furthest point calculation
  - Anti-stuck Z-offset
- ✅ Win/loss conditions met automatic round end
- ✅ Damage control: Alleen Sniper→Hider damage
- ✅ Weapon restrictions tijdens round
- ✅ Network synchronization (client-server)
- ✅ Visual effects:
  - Thermal vision post-processing
  - Player halos (dual-color)
  - Screen flashes
  - Temperature gradient overlay
  - Scanning lines & noise effects

## 🤝 Contributing

Gevonden bugs of suggesties? Open een issue op de Steam Workshop pagina!

## 📜 License

Deze addon is gratis te gebruiken en aan te passen voor persoonlijk gebruik. Redistribution op andere platforms zonder credits is niet toegestaan.

## 👤 Credits

**Developer**: Created for Steam Workshop
**Gamemode Concept**: Sniper Tag - Competitive Hide & Seek
**Built with**: Garry's Mod Lua API
**Gamemode**: Sniper Tag
**Type**: Competitive Hide & Seek

## 📄 License

Free to use en modify voor persoonlijk gebruik.
Niet doorverkopen zonder toestemming.

## 🔗 Links

- Steam Workshop: [Link komt hier]
- Bug Reports: Meld bugs via Steam Workshop comments
- Suggesties: Welkom via Workshop discussies

---

**Veel plezier met Sniper Tag! 🎯**
