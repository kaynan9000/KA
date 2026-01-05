-- [[ KA HUB | PREMIUM EDITION - UNIFIED VERSION ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [[ SERVIÇOS ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ CONFIGURAÇÕES ]]
local Config = {
    -- Combate/Aimbot
    Aimbot = false,
    FOV = 150,
    CircleVisible = false,
    -- Visuais
    ESP = false,
    -- Auto Clicker
    Clicking = false,
    ClickCount = 0,
    LastCPS = 0
}

-- [[ VARIÁVEIS DE CONTROLE ]]
local lastUpdateTime = tick()
local lastClickCount = 0
local heartbeatConn

-- [[ CÍRCULO DE FOV ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false
FOVCircle.Visible = false

-- [[ JANELA PRINCIPAL RAYFIELD ]]
local Window = Rayfield:CreateWindow({
   Name = "KA Hub | Premium Edition",
   LoadingTitle = "Carregando Multi-Ferramentas...",
   LoadingSubtitle = "by Sirius & KA",
   ConfigurationSaving = { Enabled = true, FolderName = "KA_Hub_Config", FileName = "Config" },
   KeySystem = true, 
   KeySettings = {
      Title = "Sistema de Chave",
      Subtitle = "Acesse o Hub",
      Note = "A chave é: hub",
      Key = {"hub"} 
   }
})

---
--- SEÇÃO: COMBATE (AIMBOT)
---
local CombatTab = Window:CreateTab("Combate", 4483362458)

CombatTab:CreateToggle({
   Name = "Ativar Aimbot",
   CurrentValue = false,
   Callback = function(Value) Config.Aimbot = Value end,
})

CombatTab:CreateToggle({
   Name = "Mostrar Círculo FOV",
   CurrentValue = false,
   Callback = function(Value)
      Config.CircleVisible = Value
      FOVCircle.Visible = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Raio do FOV",
   Range = {50, 800},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 150,
   Callback = function(Value)
      Config.FOV = Value
      FOVCircle.Radius = Value
   end,
})

---
--- SEÇÃO: AUTO CLICKER (ULTRA SPEED)
---
local ClickerTab = Window:CreateTab("Auto Clicker", 4483362458)

local CPSLabel = ClickerTab:CreateLabel("CPS Atual: 0")
local TotalClicksLabel = ClickerTab:CreateLabel("Total de Cliques: 0")

ClickerTab:CreateToggle({
   Name = "Ativar Auto Clicker (MAX SPEED)",
   CurrentValue = false,
   Callback = function(Value)
      Config.Clicking = Value
      if Value then
          heartbeatConn = RunService.Heartbeat:Connect(function()
              local mousePos = UserInputService:GetMouseLocation()
              -- Simula o clique na posição atual do mouse
              VIM:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
              VIM:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
              Config.ClickCount = Config.ClickCount + 1
          end)
      else
          if heartbeatConn then heartbeatConn:Disconnect() end
      end
   end,
})

ClickerTab:CreateButton({
   Name = "Resetar Contador",
   Callback = function()
       Config.ClickCount = 0
       TotalClicksLabel:Set("Total de Cliques: 0")
   end,
})

---
--- SEÇÃO: VISUAIS (ESP)
---
local VisualTab = Window:CreateTab("Visuais", 4483362458)

VisualTab:CreateToggle({
   Name = "Ativar ESP (Highlights)",
   CurrentValue = false,
   Callback = function(Value)
      Config.ESP = Value
      if not Value then
          for _, player in pairs(Players:GetPlayers()) do
              if player.Character and player.Character:FindFirstChild("ESPHighlight") then
                  player.Character.ESPHighlight:Destroy()
              end
          end
      end
   end,
})

---
--- LÓGICA DE SUPORTE (FUNÇÕES)
---

local function GetClosestPlayer()
    local target = nil
    local shortestDistance = Config.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    target = player
                    shortestDistance = distance
                end
            end
        end
    end
    return target
end

-- Loop de Atualização
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    FOVCircle.Position = UserInputService:GetMouseLocation()
    
    -- Aimbot Logic
    if Config.Aimbot then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
    
    -- ESP Logic
    if Config.ESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = player.Character:FindFirstChild("ESPHighlight")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESPHighlight"
                    highlight.Parent = player.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end

    -- Update Labels (CPS e Contador)
    if tick() - lastUpdateTime >= 1 then
        local cps = Config.ClickCount - lastClickCount
        CPSLabel:Set("CPS Atual: " .. cps)
        TotalClicksLabel:Set("Total de Cliques: " .. Config.ClickCount)
        lastClickCount = Config.ClickCount
        lastUpdateTime = tick()
    end
end)

Rayfield:Notify({
   Title = "KA Hub Unificado",
   Content = "Auto Clicker e Aimbot carregados!",
   Duration = 5,
   Image = 4483362458,
})
