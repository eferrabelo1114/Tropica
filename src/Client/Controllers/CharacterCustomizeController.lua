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
local UI_Parts = ReplicatedStorage.UI_Parts
local SquareTemplate = UI_Parts.Template:Clone()

local MainUI;
local MainCustomizationFrame;

local janitor = Janitor.new()

local itemsJanitor = Janitor.new()

local CategoriesOriginalPos = UDim2.new(-0.5, 0 ,0.5, 0)
local MainOriginalPos = UDim2.new(1.5, 0 ,0.5, 0)

local Category = "Shirts"

-- Create UIController Controller:
local CharCustomization = Knit.CreateController {
	Name = "CharCustomization";
}



function CharCustomization:LoadItemsFrame()



end

function CharCustomization:Load()
    local Categories = MainCustomizationFrame.Categories
    local MainFrame = MainCustomizationFrame.Main

    -- Enable/Handle Category changing

    for _, button in pairs(Categories.Tabs.Main.List:GetChildren()) do
        
    end
    
    janitor:Add(
        Categories.Tabs.Main.Done.MouseButton1Click:connect(function ()
            -- Submit Clothes

            self:Close()
        end)
    )

    janitor:Add(
        Categories.Tabs.Main.Reset.MouseButton1Click:connect(function ()
            -- Reset Character to default

            print(" Test ")
        end)
    )


end


function CharCustomization:Open()
    UIController:ToggleShowHotbar(true)
    UIController:ToggleShowSidebuttons(true)

    self:Load()
    
    MainCustomizationFrame["Self"].Visible = true

    Tween(MainCustomizationFrame.Categories, {"Position"}, {UDim2.new(-0.15, 0, 0.5, 0)}, 0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    Tween(MainCustomizationFrame.Main, {"Position"}, {UDim2.new(1.06, 0, 0.5, 0)}, 0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
end

function CharCustomization:Close()
    janitor:Cleanup()
    itemsJanitor:Cleanup()

    UIController:ToggleShowHotbar(false)
    UIController:ToggleShowSidebuttons(false)

    Tween(MainCustomizationFrame.Categories, {"Position"}, {CategoriesOriginalPos}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local tweenObj = Tween(MainCustomizationFrame.Main, {"Position"}, {MainOriginalPos}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    spawn(function ()
        tweenObj.Completed:Wait()
        MainCustomizationFrame["Self"].Visible = false
    end)

    UIController.UI_Open = nil
end

function CharCustomization:Initialize(UI)
    ClientInput = Knit.GetController("InputController")
    UIController = Knit.GetController("UIController")

    MainUI = UI
    MainCustomizationFrame = MainUI.Pages.CharacterCustomization

    MainCustomizationFrame["Self"].Visible = false
    MainCustomizationFrame.Categories.Position = CategoriesOriginalPos
    MainCustomizationFrame.Main.Position = MainOriginalPos

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