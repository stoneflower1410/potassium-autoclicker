--[[
	Potassium AutoClicker
	Autoclicker de alto CPS para ejecutores de scripts de Roblox (Potassium, etc.)

	FORMAS DE USAR:

	1) Cargar desde GitHub (recomendado). Pega esto en Potassium:
	   loadstring(game:HttpGet("https://raw.githubusercontent.com/USUARIO/potassium-autoclicker/main/autoclicker.lua"))()
	   (cambia USUARIO por tu usuario de GitHub)

	2) Pegar este archivo entero en la caja de scripts y ejecutar.

	CONTROLES:
	   - Pulsa la TECLA de toggle (por defecto F) para activar / desactivar.
	   - Ajusta los valores en CONFIG abajo antes de ejecutar.
]]

--========================= CONFIGURACION =========================
local CONFIG = {
	CPS           = 50,                  -- clics por segundo objetivo (sube/baja a gusto)
	TOGGLE_KEY    = Enum.KeyCode.F,      -- tecla para activar/desactivar
	START_ENABLED = false,               -- true = empieza ya clicando
	ONLY_FOCUSED  = true,                -- no clicar si la ventana de Roblox no tiene el foco
	NOTIFY        = true,                 -- mostrar aviso en pantalla al cambiar de estado
	MAX_PER_FRAME = 250,                  -- tope de seguridad de clics por frame
}
--================================================================

local UserInputService    = game:GetService("UserInputService")
local RunService          = game:GetService("RunService")
local StarterGui          = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local enabled     = CONFIG.START_ENABLED
local accumulator = 0
local hasFocus    = true

-- Elige el mejor metodo de clic que exponga el ejecutor -------------
local clickFn
if type(mouse1click) == "function" then
	clickFn = function() mouse1click() end
elseif type(mouse1press) == "function" and type(mouse1release) == "function" then
	clickFn = function() mouse1press(); mouse1release() end
else
	clickFn = function()
		VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
		VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
	end
end

local function notify(text)
	print("[AutoClicker] " .. text)
	if not CONFIG.NOTIFY then return end
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "AutoClicker",
			Text = text,
			Duration = 2,
		})
	end)
end

-- Seguimiento del foco de la ventana --------------------------------
UserInputService.WindowFocused:Connect(function() hasFocus = true end)
UserInputService.WindowFocusReleased:Connect(function() hasFocus = false end)

-- Tecla de toggle --------------------------------------------------
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == CONFIG.TOGGLE_KEY then
		enabled = not enabled
		accumulator = 0
		notify(enabled and ("ON  -  " .. CONFIG.CPS .. " CPS") or "OFF")
	end
end)

-- Bucle principal: reparte CPS exactos por frame -------------------
RunService.Heartbeat:Connect(function(dt)
	if not enabled then return end
	if CONFIG.ONLY_FOCUSED and not hasFocus then return end

	accumulator = accumulator + dt * CONFIG.CPS

	local budget = CONFIG.MAX_PER_FRAME
	while accumulator >= 1 and budget > 0 do
		accumulator = accumulator - 1
		budget = budget - 1
		local ok, err = pcall(clickFn)
		if not ok then
			enabled = false
			notify("Error al clicar (" .. tostring(err) .. "). Desactivado.")
			return
		end
	end

	-- si nos quedamos muy atras (lag), no acumules una avalancha de clics
	if accumulator > 5 then accumulator = 0 end
end)

notify("Cargado. Pulsa " .. CONFIG.TOGGLE_KEY.Name .. " para activar.")
