-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Knit)
local Tween = require(Knit.Util.Tween)
local Janitor = require(Knit.Util.Janitor)

-- Controllers
local ClientInput;
local UIController;

local InputType;
local InputFunctions;

-- Private Variables
local janitor = Janitor.new()

-- Create UIController Controller:
local CharCustomization = Knit.CreateController {
	Name = "CharCustomization";
}

--152, 152, 152

function CharCustomization:Open(UI)
    local MainCustomizationFrame = UI.Pages.CharacterCustomization
    MainCustomizationFrame.Categories.Position = UDim2.new(-0.5, 0 ,0.5, 0)
    MainCustomizationFrame.Main.Position = UDim2.new(1.5, 0 ,0.5, 0)

    UIController:ToggleShowHotbar(true)
    UIController:ToggleShowSidebuttons(true)

    MainCustomizationFrame["Self"].Visible = true

    Tween(MainCustomizationFrame.Categories, {"Position"}, {UDim2.new(-0.15, 0, 0.5, 0)}, 0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    Tween(MainCustomizationFrame.Main, {"Position"}, {UDim2.new(1.06, 0, 0.5, 0)}, 0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
end

function CharCustomization:Close()
    UIController:ToggleShowHotbar(false)
    UIController:ToggleShowSidebuttons(false)
end

function CharCustomization:Initialize()
    ClientInput = Knit.GetController("InputController")
    UIController = Knit.GetController("UIController")

    -- Input Controller
    InputType = ClientInput.InputType
    InputFunctions = ClientInput.InputFunctions

    --[[
    ClientInput.UserChangedInput:Connect(function()
        janitor:Cleanup()

        if NametagFrame ~= nil then
            self:ResetSidebuttons()
            self:LoadButtons()
        end

        InputType = ClientInput.InputType
    end)
    ]]--
end






return CharCustomization