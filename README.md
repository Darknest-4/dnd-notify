# DND Notify - FiveM Értesítési Rendszer

## Bemutatás
A `dnd-notify` egy egyszerű, de sokoldalú értesítési rendszer FiveM szerverekhez. A rendszer lehetővé teszi, hogy különböző típusú, stílusú és pozíciójú értesítéseket jelenítsen meg a játékosok számára.

![Kép az értesítésekről](https://i.imgur.com/placeholder.png)

## Jellemzők
- **9 különböző pozíció** az értesítések megjelenítéséhez
- **4 előre beállított értesítéstípus** (success, error, info, warning)
- **Testre szabható design** egyszerű config fájl segítségével
- **Színkód támogatás** az értesítések szövegében (pl. ~r~, ~g~, ~b~)
- **Automatikus link felismerés** a szövegben
- **Könnyen integrálható** más erőforrásokkal
- **Szerver és kliens** oldalról is használható

## Telepítés
1. Töltsd le a `dnd-notify` mappát
2. Helyezd el a szerver `resources` mappájában (például: `resources/[scripts]/dnd-notify`)
3. Add hozzá a `server.cfg` fájlhoz: `ensure dnd-notify`
4. Indítsd újra a szervert vagy használd a `refresh` és `ensure dnd-notify` parancsokat

## Konfiguráció

A rendszer beállításai a `config.lua` fájlban találhatók:

### Alapvető beállítások
```lua
-- Alapértelmezett pozíció
Config.DefaultPosition = 'top-right' 
-- Elérhető pozíciók: 'top-left', 'top-center', 'top-right', 
--                     'middle-left', 'middle-center', 'middle-right',
--                     'bottom-left', 'bottom-center', 'bottom-right'

-- Teszt parancs engedélyezése/letiltása
Config.EnableTestCommand = false -- Állítsd true-ra, ha szeretnéd használni a /testnotify parancsot
```

### Értesítések stílusa
```lua
Config.Notifications = {
    BackgroundColor = 'rgba(20, 20, 40, 0.85)', -- Háttérszín átlátszósággal
    TextColor = '#ffffff',                     -- Szöveg színe
    BorderWidth = '4px',                       -- Szegély szélessége
    BorderRadius = '8px',                      -- Lekerekített sarkok
    FontSize = '14px',                         -- Betűméret
    Width = '320px',                           -- Értesítés szélessége
    Padding = '12px',                          -- Belső margó
    MarginBottom = '8px',                      -- Értesítések közti távolság
    Duration = 4000                            -- Időtartam ezredmásodpercben
}
```

### Értesítéstípusok beállítása
```lua
Config.NotificationTypes = {
    ['success'] = {
        icon = '<i class="fas fa-check-circle"></i>',   -- FontAwesome ikon
        borderColor = '#2ecc71',                        -- Zöld szegély
        backgroundColor = 'rgba(20, 40, 20, 0.85)'      -- Sötétzöld háttér
    },
    -- Hasonlóan beállíthatod a többi típust is (error, info, warning)
}
```

## Használat

### Kliens oldalról

#### Export használata
```lua
exports['dnd-notify']:SendNotification({
    type = 'success',           -- success, error, info, warning
    message = 'Sikeres művelet!',
    position = 'top-right',     -- opcionális
    duration = 5000             -- opcionális, milliszekundumban
})
```

#### Event használata
```lua
TriggerEvent('dnd-notify:showNotification', {
    type = 'info',
    message = 'Ez egy információs értesítés'
})
```

### Szerver oldalról

#### Export használata
```lua
exports['dnd-notify']:SendNotification(source, {
    type = 'warning',
    message = 'Ez egy figyelmeztető üzenet'
})
```

#### Event használata
```lua
-- Egy játékosnak
TriggerClientEvent('dnd-notify:showNotification', playerId, {
    type = 'error',
    message = 'Hiba történt!'
})

-- Minden játékosnak
TriggerClientEvent('dnd-notify:showNotification', -1, {
    type = 'info',
    message = 'Szerverüzenet mindenkinek'
})
```

### Színkódok használata az üzenetekben
A következő színkódokat használhatod az üzenetekben:
- `~r~` - Piros
- `~g~` - Zöld
- `~b~` - Kék
- `~y~` - Sárga
- `~w~` - Fehér
- `~s~` - Alapértelmezett szín

Példa: `'~r~Hiba~s~ történt a ~b~művelet~s~ során'`

## Integrálás más scriptekbe

### ESX script esetén (shared.lua vagy config.lua fájlban)
```lua
-- Értesítési rendszer konfigurálása
Config.NotifySystem = 'dnd-notify' -- dnd-notify, esx, okok, stb.

-- Értesítési funkció
function Config.Notify(message, type)
    if Config.NotifySystem == 'dnd-notify' then
        exports['dnd-notify']:SendNotification({
            type = type or 'info',
            message = message,
            position = 'top-right',
            duration = 5000
        })
    elseif Config.NotifySystem == 'esx' then
        ESX.ShowNotification(message)
    elseif Config.NotifySystem == 'okok' then
        -- okok notify kód
    end
end
```

## Hibaelhárítás

### Fekete háttér probléma
Ha fekete hátteret tapasztalsz az értesítésekben, ellenőrizd a következőket:
1. A `style.css` fájlban a háttérbeállítások megfelelőek: `background-color: transparent !important;`
2. A `script.js` fájlban az initialize funkció beállítja az átlátszó hátteret

### Értesítések nem jelennek meg
1. Ellenőrizd a böngésző konzolodat (F8) a hibaüzenetekért
2. Győződj meg róla, hogy a resource el van indítva: `ensure dnd-notify`
3. Ellenőrizd, hogy a megfelelő export/event neveket használod

### Értesítések egymásra torlódnak
Az új verzió automatikusan kezeli ezt, de ha túl sok értesítést küldesz, a következőket teheted:
1. Csökkentsd az értesítések időtartamát a `Config.Notifications.Duration` értékkel
2. Módosítsd a MAX_NOTIFICATIONS értéket a `script.js` fájlban (alapértelmezetten 5)

## Támogatás
Ha segítségre van szükséged, keresd fel a Discord szerverünket: [Discord link](https://discord.gg/QYaQWRuDVs)
