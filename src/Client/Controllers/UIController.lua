-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Knit)
local Tween = require(Knit.Util.Tween)
local Janitor = require(Knit.Util.Janitor)

-- Controllers
local ClientInput;
local NametagController;

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

UIController.UI_Open = nil

local frameControllers;

UIController.UI_Table = {
    ["HUD"] = {};
    ["Pages"] = {};
} 

-- Save Button Data
local function saveButtonInformation(buttons, dataSave)
    local Buttons = UIController.UI_Table.HUD[buttons]
    UIController.UI_Table.HUD[buttons]["Button_Information"] = {}

    for v, button in pairs(Buttons) do
        if v ~= "Button_Information" then
            if button:IsA("ImageButton") then
                if dataSave == "Rotation" then
                    Buttons["Button_Information"][button] = button.Rotation
                elseif dataSave == "Size" then
                    Buttons["Button_Information"][button] = button.Size
                end
            end
        end
    end
end
-- Get Frame From Self
local function getUiFrame(requestedFrame)
    local UITable 

    for MainFrame, Frames in pairs(UIController.UI_Table) do
        for Frame, FrameChildren in pairs(Frames) do
            if FrameChildren["Self"] == requestedFrame then
                UITable = Frame
            end
        end
    end
end

-- Load Right Side Buttons
function UIController:EnableSidebuttons()
    local sideButtons = self.UI_Table.HUD.Buttons

    for v, button in pairs(sideButtons) do
        if v ~= "Button_Information" then
            if button:IsA("ImageButton") then
                local originalRotation =  sideButtons["Button_Information"][button]

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
                    button.MouseButton1Click:connect(function()
                        if self.UI_Open and self.UI_Open ~= button.Name then
                            frameControllers[self.UI_Open]:Close()
                        end

                        if frameControllers[button.Name] then
                            frameControllers[button.Name]:Open(self.UI_Table)
                            self.UI_Open = button.Name
                        end
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

-- Hotbar Buttons
function UIController:EnableHotbar()
    local hotbar = self.UI_Table.HUD.Hotbar

    -- Load Hotbar Buttons
    for v, button in pairs(hotbar) do
        if v ~= "Button_Information" then
            if button:IsA("ImageButton") then
                local originalSize = hotbar["Button_Information"][button]

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

function UIController:KnitStart()
    ClientInput = Knit.GetController("InputController")
    NametagController = Knit.GetController("NametagController")

    InputType  = ClientInput.InputType
    InputFunctions = ClientInput.InputFunctions

    local main = mainUI:Clone()

    -- Load Frame Controllers
    frameControllers = {
        ["Nametag"] = NametagController;
    }

    -- Turn off all pages
    for _, page in pairs(main.Pages:GetChildren()) do
        page.Visible = false
    end

    -- Load all UI into a table
    for uiType, _ in pairs(self.UI_Table) do
        if main:FindFirstChild(uiType) then
            for _, Frame in pairs(main:FindFirstChild(uiType):GetChildren()) do
                if Frame:IsA("Frame") or Frame:IsA("ImageButton") or Frame:IsA("ImageLabel") then
                    UIController.UI_Table[uiType][Frame.Name] = {}
                    
                    if Frame.Name ~= "Hotbar" then
                        for _, child in pairs(Frame:GetChildren()) do
                            UIController.UI_Table[uiType][Frame.Name][child.Name] = child
                        end
                    else
                        for _, child in pairs(Frame:GetChildren()) do
                            UIController.UI_Table[uiType][Frame.Name][child] = child
                        end
                    end

                    UIController.UI_Table[uiType][Frame.Name]["Self"] = Frame
                end
            end
        end
    end

    -- Save Element Data
    saveButtonInformation("Hotbar", "Size")
    saveButtonInformation("Buttons", "Rotation")

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

    -- Enable Elements
    self:EnableHotbar()
    self:EnableSidebuttons()

    main.Parent = playerGui
end





return UIController
