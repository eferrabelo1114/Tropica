-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Knit)
local Janitor = require(Knit.Util.Janitor)
local Signal = require(Knit.Util.Signal)

-- Private Variables
local Player = game.Players.LocalPlayer

local janitor = Janitor.new()

-- Create InputController Controller:
local InputController = Knit.CreateController {
	Name = "InputController";
}

InputController.InputFunctions = {
    ["Controller"] = {
        ["GUI_Enter"] = "SelectionGained";
        ["GUI_Exit"] = "SelectionLost";

    };

    ["Mouse"] = {
        ["GUI_Enter"] = "MouseEnter";
        ["GUI_Exit"] = "MouseLeave";

    }
}

InputController.InputType = nil;
InputController.UserChangedInput = Signal.new()


function InputController:KnitInit()

    -- Initial Check
    if UserInputService.GamepadEnabled then
        self.InputType = "Controller";
    elseif UserInputService.MouseEnabled then
        self.InputType = "Mouse";
    end

    -- Check Player Input and if it changes tell the other scripts
    janitor:Add(
        RunService.RenderStepped:connect(function ()
            local lastInput = UserInputService:GetLastInputType()
            local lastInputType = self.InputType

            if lastInput == Enum.UserInputType.MouseMovement then
                self.InputType = "Mouse";
            elseif lastInput == Enum.UserInputType.Gamepad1 then
                self.InputType = "Controller";
            end

            if self.InputType ~= lastInputType then
                self.UserChangedInput:Fire()
            end
        end)
    )

end


return InputController
