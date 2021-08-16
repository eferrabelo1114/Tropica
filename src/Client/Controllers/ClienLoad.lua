-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local Knit = require(ReplicatedStorage.Knit)

-- Create ClientLoad Controller:
local ClientLoad = Knit.CreateController {
	Name = "ClientLoad";
}


function ClientLoad:KnitStart()
    local handleClientUi = Knit.GetController("UIController")

    handleClientUi:LoadUI()
end



return ClientLoad
