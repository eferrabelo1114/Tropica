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
local InteractionController = Knit.CreateController {
	Name = "InteractionController";
}



function InteractionController:LoadInteraction()
    ClientInput = Knit.GetController("InputController")

    InputType  = ClientInput.InputType
    InputFunctions = ClientInput.InputFunctions



    

    -- Check if player input ever changes to reload UI to take in the new input
    ClientInput.UserChangedInput:Connect(function()
       
    end)


    
end




return InteractionController