-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)

-- Create UIController Controller:
local UIController = Knit.CreateController {
	Name = "UIController";
}

-- Private Variables
local mainUI = ReplicatedStorage:WaitForChild("MainGui")

local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui


function UIController:LoadUI()
    local main = mainUI:Clone()

    -- Turn off all pages
    for _, page in pairs(main.Pages:GetChildren()) do
        page.Visible = false
    end


    main.Parent = playerGui
end



return UIController
