-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Knit)
local Tween = require(Knit.Util.Tween)
local Janitor = require(Knit.Util.Janitor)

-- Controllers
local ClientInput;

local InputType;
local InputFunctions;

-- Create UIController Controller:
local PlayerListController = Knit.CreateController {
	Name = "PlayerListController";
}












return PlayerListController