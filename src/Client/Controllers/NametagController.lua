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
local NametagService;

local InputType;
local InputFunctions;

-- Private Variables
local Player = game.Players.LocalPlayer

local janitor = Janitor.new()

local savedButtonInfo = {}

local MainUI;
local NametagFrame;

local TextColorSelected = Color3.fromRGB(255, 255, 255)
local BorderColorSelected = Color3.fromRGB(0, 0, 0)
local PreviewtextSelected = Player.Name

local CurrentlyChanging = "TextColor"


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

function NametagController:UpdatePreview()
    local PreviewText = NametagFrame.Preview:FindFirstChild("Text")
    
    PreviewText.Text = PreviewtextSelected
    PreviewText.TextColor3 = TextColorSelected
    PreviewText.TextStrokeColor3 = BorderColorSelected
end

function NametagController:LoadColors()
    local ColorFrame = NametagFrame.Main:FindFirstChild("Colors")

    self:UpdatePreview()

    for _,colorButton in pairs(ColorFrame:GetChildren()) do
        if colorButton:IsA("ImageButton") then
            local color = Color3.fromRGB(colorButton.BackgroundColor3.R * 255, colorButton.BackgroundColor3.G * 255, colorButton.BackgroundColor3.B * 255)

            janitor:Add(
                colorButton.MouseButton1Click:connect(function()
                    if CurrentlyChanging == "TextColor" then
                        TextColorSelected = color
                    elseif CurrentlyChanging == "BorderColor" then
                        BorderColorSelected = color
                    end
                    self:UpdatePreview()
                end)
            )
        end
    end
end

function NametagController:UpdateButtons(previousChanging, newSelected)
    local NametagChildren = NametagFrame["Self"]:GetDescendants()

    CurrentlyChanging = newSelected
    for _, button in pairs(NametagChildren) do
        if button:GetAttribute("Interaction_Type") and button:IsA("ImageButton") then
            if button.Name == previousChanging then
                button.ImageColor3 = Color3.fromRGB(255, 255, 255)
            elseif button.Name == CurrentlyChanging then
                button.ImageColor3 = Color3.fromRGB(155, 155, 155)
            end
        end
    end
end

function NametagController:LoadButtons()
    local NametagChildren = NametagFrame["Self"]:GetDescendants()

    for _, button in pairs(NametagChildren) do
        if button:GetAttribute("Interaction_Type") and button:IsA("ImageButton") then
            if button.Name == CurrentlyChanging then
                button.ImageColor3 = Color3.fromRGB(155, 155, 155)
            end

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
                        self:UpdateButtons(CurrentlyChanging, "TextColor")
                    end)
                )
            elseif button.Name == "BorderColor" then
                janitor:Add(
                    button.MouseButton1Click:connect(function()
                        self:UpdateButtons(CurrentlyChanging, "BorderColor")
                    end)
                )
            elseif button.Name == "Confirm" then
                janitor:Add(
                    button.MouseButton1Click:connect(function()
                        print("Change Name Tag")
                        NametagService:ChangeNametag(PreviewtextSelected, TextColorSelected, BorderColorSelected)
                    end)
                )
            end
        end
    end

    janitor:Add(NametagFrame.Enter.Type.Changed:connect(function ()
        PreviewtextSelected = NametagFrame.Enter.Type.Text
        self:UpdatePreview()
    end))
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


function NametagController:Open()
    saveButtonInfo()

    
    self:LoadColors()

    self:ResetSidebuttons()
    self:LoadButtons()

    
    NametagFrame["Self"].Visible = true
end

function NametagController:Initialize(UI)
    ClientInput = Knit.GetController("InputController")
    UIController = Knit.GetController("UIController")
    NametagService = Knit.GetService("NametagService")

    PreviewtextSelected = Player:GetAttribute("Nametag_Text")
    TextColorSelected = Player:GetAttribute("Nametag_TextColor")
    BorderColorSelected = Player:GetAttribute("Nametag_BorderColor")

    MainUI = UI
    NametagFrame = MainUI.Pages.Customization

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