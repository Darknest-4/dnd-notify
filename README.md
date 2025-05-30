# DND Notify - FiveM Értesítési Rendszer

> A dnd-notify egy letisztult, könnyen használható és rugalmas értesítési rendszer FiveM szerverekhez. Egyéni stílusjegyekkel és sok beállítási lehetőséggel rendelkezik. Különböző típusú értesítéseket (siker, hiba, információ, figyelmeztetés) jelenithetsz meg a képernyő bármely pozíciójában. A rendszer könnyen integrálható más scriptekkel, és gyors készítésre lett optimalizálva.

## Bemutatás
A `dnd-notify` egy egyszerű, de sokoldalú értesítési rendszer FiveM szerverekhez. A rendszer lehetővé teszi, hogy különböző típusú, stílusú és pozíciójú értesítéseket jelenítsen meg a játékosok számára.

### Értesítési típusok

| Típus | Kép |
|-------|-----|
| **KÉP** | ![KÉP](https://i.imgur.com/z44fTr9.png) |

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
    title = '',
    position = 'top-right',     -- opcionális
    duration = 5000             -- opcionális, milliszekundumban
})
```

#### Event használata
```lua
TriggerEvent('dnd-notify:showNotification', {
    type = 'info',
    title = '',
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

## es_extended beállítása dnd-notify használatához

A dnd-notify rendszer könnyen integrálható az es_extended keretrendszerbe, hogy az alapértelmezett értesítési rendszerként működjön. Kövesd az alábbi lépéseket:

### 1. Módosítsd az es_extended konfigurációs fájlt

Nyisd meg az `es_extended/config.lua` fájlt, és keresd meg az értesítésekre vonatkozó részt. Általában van ott egy `Config.Notification` beállítás.

### 2. Az ESX ShowNotification funkció felülírása

A következő kódot add hozzá az `es_extended/client/functions.lua` fájlhoz (a fájl vége felé):

```lua
-- Eredeti ESX.ShowNotification funkció felülírása dnd-notify használatához
ESX.ShowNotification = function(message, type, duration)
    if not message then return end
    
    local notificationType = type or 'info' -- alapértelmezett típus: info
    local notificationDuration = duration or 5000 -- alapértelmezett időtartam: 5000ms
    
    -- dnd-notify meghívása
    exports['dnd-notify']:SendNotification({
        type = notificationType,
        message = message,
        duration = notificationDuration
    })
end

-- ESX.ShowAdvancedNotification funkció felülírása (ha szükséges)
ESX.ShowAdvancedNotification = function(title, subject, msg, icon, iconType, duration)
    if not msg then return end
    
    -- Értesítés típus meghatározása az iconType alapján
    local notificationType = 'info'
    if iconType == 1 then notificationType = 'info'
    elseif iconType == 2 then notificationType = 'warning'
    elseif iconType == 3 then notificationType = 'error'
    elseif iconType == 7 then notificationType = 'success'
    end
    
    local notificationDuration = duration or 5000
    
    -- dnd-notify meghívása fejlett értesítéshez
    exports['dnd-notify']:SendNotification({
        type = notificationType,
        title = title,
        message = msg,
        duration = notificationDuration
    })
end

-- ESX.ShowHelpNotification funkció felülírása (ha szükséges)
ESX.ShowHelpNotification = function(message, thisFrame, beep, duration)
    if not message then return end
    
    local notificationDuration = duration or 5000
    
    -- dnd-notify meghívása segítséghez
    exports['dnd-notify']:SendNotification({
        type = 'info',
        message = message,
        duration = notificationDuration
    })
end
```

### 3. Ellenőrizd a server.cfg fájlt

Győződj meg róla, hogy a dnd-notify előbb töltődik be, mint az es_extended:

```
ensure dnd-notify
ensure es_extended
```

### 4. Újraindítás

Indítsd újra a szervert a változtatások érvénybe léptetéséhez. Most már az ESX alapértelmezett értesítései helyett a dnd-notify rendszert fogja használni a szerver.

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
