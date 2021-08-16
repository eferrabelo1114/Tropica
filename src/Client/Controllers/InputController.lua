-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local Knit = require(ReplicatedStorage.Knit)

-- Create InputController Controller:
local InputController = Knit.CreateController {
	Name = "InputController";
}






return InputController
