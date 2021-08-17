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
local UIController = Knit.CreateController {
	Name = "UIController";
}

-- Private Variables
local mainUI = ReplicatedStorage:WaitForChild("MainGui")

local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui

local janitor = Janitor.new()

local UI_Open = nil


UIController.UI_Table = {
    ["HUD"] = {};
    ["Pages"] = {};
} 

function UIController:EnableSidebuttons()
    local sideButtons = self.UI_Table.HUD.Buttons
    self.UI_Table.HUD.Buttons["Button_Information"] = {}

    -- Load Hotbar Buttons
    for v, button in pairs(sideButtons) do
        if v ~= "Button_Information" then
            if button:IsA("ImageButton") then
                local originalRotation = 1
                sideButtons["Button_Information"][button] = originalRotation

                -- Hover
                janitor:Add(
                    button[InputFunctions[InputType]["GUI_Enter"]]:connect(function ()
                        Tween(button, {"Rotation"}, {8}, 0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    end)
                )
                
                janitor:Add(
                    button[InputFunctions[InputType]["GUI_Exit"]]:connect(function ()
                        Tween(button, {"Rotation"}, {originalRotation}, 0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    end)
                )

                -- Click handling
                janitor:Add(
                    button.MouseButton1Click:connect(function ()
                        print("Clicked")
                    end)
                )
            end
        end
    end
end

function UIController:ResetSidebuttons()
    local sideButtons = self.UI_Table.HUD.Buttons

    for v, button in pairs(sideButtons) do
        if v ~= "Button_Information" then
            if button:IsA("ImageButton") then
                local originalRotation = sideButtons["Button_Information"][button] 
                Tween(button, {"Rotation"}, {originalRotation}, 0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            end
        end
    end
end

function UIController:EnableHotbar()
    local hotbar = self.UI_Table.HUD.Hotbar
    self.UI_Table.HUD.Hotbar["Button_Information"] = {}

    -- Load Hotbar Buttons
    for v, button in pairs(hotbar) do
        if v ~= "Button_Information" then
            if button:IsA("ImageButton") then
                local originalSize = UDim2.new(1, 0, 1, 0)
                hotbar["Button_Information"][button] = originalSize

                -- Hover
                janitor:Add(
                    button[InputFunctions[InputType]["GUI_Enter"]]:connect(function ()
                        Tween(button, {"Size"}, {UDim2.new(button.Size.X.Scale, button.Size.X.Offset, button.Size.Y.Scale + 0.2, button.Size.Y.Offset)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    end)
                )
                
                janitor:Add(
                    button[InputFunctions[InputType]["GUI_Exit"]]:connect(function ()
                        Tween(button, {"Size"}, {originalSize}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    end)
                )

                -- Click handling
                janitor:Add(
                    button.MouseButton1Click:connect(function ()
                        print("Clicked")
                    end)
                )
            end
        end
    end
end

function UIController:ResetHotbar()
    local hotbar = self.UI_Table.HUD.Hotbar

    for v, button in pairs(hotbar) do
        if v ~= "Button_Information" then
            if button:IsA("ImageButton") then
                local originalSize = hotbar["Button_Information"][button] 
                Tween(button, {"Size"}, {originalSize}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            end
        end
    end
end

function UIController:LoadUI()
    ClientInput = Knit.GetController("InputController")

    InputType  = ClientInput.InputType
    InputFunctions = ClientInput.InputFunctions

    local main = mainUI:Clone()

    -- Turn off all pages
    for _, page in pairs(main.Pages:GetChildren()) do
        page.Visible = false
    end

    -- Load all UI into a table
    for uiType, _ in pairs(self.UI_Table) do
        if main:FindFirstChild(uiType) then
            for _, Frame in pairs(main:FindFirstChild(uiType):GetChildren()) do
                if Frame:IsA("Frame") or Frame:IsA("ImageButton") or Frame:IsA("ImageLabel") then
                    UIController.UI_Table[uiType][Frame.Name] = Frame:GetChildren() 
                end
            end
        end
    end

    -- Check if player input ever changes to reload UI to take in the new input
    ClientInput.UserChangedInput:Connect(function()
        janitor:Cleanup()

        InputType = ClientInput.InputType

        -- Hotbar Handler
        self:ResetHotbar()
        self:EnableHotbar()

        -- Sidebutton Handler
        self:ResetSidebuttons()
        self:EnableSidebuttons()
    end)

    self:EnableHotbar()

    self:EnableSidebuttons()

    main.Parent = playerGui
end





return UIController
