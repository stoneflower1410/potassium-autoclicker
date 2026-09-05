# potassium-autoclicker

Autoclicker de alto CPS en Lua para ejecutores de scripts de Roblox (probado con **Potassium**).

Reparte los clics de forma uniforme en cada frame usando `RunService.Heartbeat`,
así que el CPS real se mantiene estable en lugar de venir a rachas.

## Uso rápido

Pega esto en Potassium:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/stoneflower1410/potassium-autoclicker/main/autoclicker.lua"))()
```

O copia el contenido de [`autoclicker.lua`](autoclicker.lua) directamente en la caja de scripts.

## Controles

| Acción | Por defecto |
|---|---|
| Activar / desactivar | Tecla `F` |
| CPS objetivo | `50` |

Edita el bloque `CONFIG` al principio de `autoclicker.lua` antes de ejecutar:

```lua
local CONFIG = {
    CPS           = 50,               -- clics por segundo
    TOGGLE_KEY    = Enum.KeyCode.F,   -- tecla de toggle
    START_ENABLED = false,            -- empezar ya clicando
    ONLY_FOCUSED  = true,             -- solo clicar con la ventana enfocada
    NOTIFY        = true,             -- avisos en pantalla
    MAX_PER_FRAME = 250,              -- tope de seguridad por frame
}
```

## Cómo funciona

- Detecta el método de clic disponible en el ejecutor, en este orden:
  `mouse1click` → `mouse1press` + `mouse1release` → `VirtualInputManager:SendMouseButtonEvent`.
- Un acumulador convierte `dt * CPS` en clics enteros por frame, con un tope
  (`MAX_PER_FRAME`) para no congelar el cliente.
- Si el cliente sufre lag, descarta la acumulación en vez de soltar una avalancha de clics.

## Aviso

Úsalo solo en juegos y situaciones donde esté permitido automatizar entradas.
Muchos juegos de Roblox prohíben los autoclickers y pueden sancionar la cuenta.
