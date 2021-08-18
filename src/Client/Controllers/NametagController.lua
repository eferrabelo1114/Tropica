-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Knit = require(ReplicatedStorage.Knit)
local Tween = require(Knit.Util.Tween)
local Janitor = require(Knit.Util.Janitor)

-- Controllers
local ClientInput;
local UIController;

local InputType;
local InputFunctions;

-- Private Variables
local Player = game.Players.LocalPlayer

local janitor = Janitor.new()

local savedButtonInfo = {}

local NametagFrame;

local TextColorSelected = Color3.fromRGB(255, 255, 255)
local BorderColorSelected = Color3.fromRGB(0, 0, 0)
local PreviewtextSelected = Player.Name

local CurrencyChanging = "TextColor"

-- Create NametagController:
local NametagController = Knit.CreateController {
	Name = "NametagController";
}

local function saveButtonInfo()
    local NametagChildren = NametagFrame["Self"]:GetDescendants()

    for _, button in pairs(NametagChildren) do
        if button:GetAttribute("Interaction_Type") and button:IsA("ImageButton") then
            savedButtonInfo[button] = button.Position
        end
    end
end

function NametagController:LoadColors()
    local ColorFrame = NametagFrame.Main:FindFirstChild("Colors")
    local PreviewText = NametagFrame.Preview:FindFirstChild("Text")

    PreviewText.Text = Player:GetAttribute("Nametag_Text")
    PreviewText.TextColor3 = Player:GetAttribute("Nametag_TextColor")
    PreviewText.TextStrokeColor3 = Player:GetAttribute("Nametag_BorderColor")
end

function NametagController:LoadButtons()
    local NametagChildren = NametagFrame["Self"]:GetDescendants()

    for _, button in pairs(NametagChildren) do
        if button:GetAttribute("Interaction_Type") and button:IsA("ImageButton") then

            janitor:Add(
                button[InputFunctions[InputType]["GUI_Enter"]]:connect(function ()
                    Tween(button, {"Position"}, {UDim2.new(button.Position.X.Scale, button.Position.X.Offset, button.Position.Y.Scale - 0.01, button.Position.Y.Offset)}, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                end)
            )

            janitor:Add(
                button[InputFunctions[InputType]["GUI_Exit"]]:connect(function ()
                    Tween(button, {"Position"}, {savedButtonInfo[button]}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                end)
            )

            if button.Name == "Close" then
                janitor:Add(
                    button.MouseButton1Click:connect(function()
                        self:Close()
                    end)
                )
            elseif button.Name == "TextColor" then
                janitor:Add(
                    button.MouseButton1Click:connect(function()
                        print("Changing Text Color")
                    end)
                )
            elseif button.Name == "BorderColor" then
                janitor:Add(
                    button.MouseButton1Click:connect(function()
                        print("Changing Border Color")
                    end)
                )
            elseif button.Name == "Confirm" then
                janitor:Add(
                    button.MouseButton1Click:connect(function()
                        print("Change Name Tag")
                        print(NametagFrame.Enter.Type.Text)
                    end)
                )
            end
        end
    end
end

function NametagController:ResetSidebuttons()
    local NametagChildren = NametagFrame["Self"]:GetDescendants()

    for _, button in pairs(NametagChildren) do
        if savedButtonInfo[button]  then
            local originalPosition =  savedButtonInfo[button]
            Tween(button, {"Position"}, {originalPosition}, 0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        end
    end
end

function NametagController:Close()
    janitor:Cleanup()
    self:ResetSidebuttons()
    NametagFrame["Self"].Visible = false
    UIController.UI_Open = nil
end


function NametagController:Open(MainUI)
    NametagFrame = MainUI.Pages.Customization
    saveButtonInfo()

    self:LoadColors()

    self:ResetSidebuttons()
    self:LoadButtons()

    
    NametagFrame["Self"].Visible = true
end

function NametagController:Initialize()
    ClientInput = Knit.GetController("InputController")
    UIController = Knit.GetController("UIController")

    -- Input Controller
    InputType = ClientInput.InputType
    InputFunctions = ClientInput.InputFunctions

    ClientInput.UserChangedInput:Connect(function()
        janitor:Cleanup()

        if NametagFrame ~= nil then
            self:ResetSidebuttons()
            self:LoadButtons()
        end

        InputType = ClientInput.InputType
    end)
end




return NametagController