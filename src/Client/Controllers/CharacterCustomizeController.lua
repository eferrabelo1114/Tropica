-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local AvatarService;

local Knit = require(ReplicatedStorage.Knit)
local Tween = require(Knit.Util.Tween)
local Janitor = require(Knit.Util.Janitor)

local CustomizationOptions = require(ReplicatedStorage.Modules.Customization)

-- Controllers
local ClientInput;
local UIController;

local InputType;
local InputFunctions;

local controls = require(game:GetService("Players").LocalPlayer.PlayerScripts.PlayerModule):GetControls()

-- Private Variables
local UI_Parts = ReplicatedStorage.UI_Parts
local SquareTemplate = UI_Parts.Template
local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local MainUI;
local MainCustomizationFrame;

local janitor = Janitor.new()
local itemsJanitor = Janitor.new()
local cameraJanitor = Janitor.new()

local CategoriesOriginalPos = UDim2.new(-0.5, 0 ,0.5, 0)
local MainOriginalPos = UDim2.new(1.5, 0 ,0.5, 0)

local Category = "Shirt"

-- Create UIController Controller:
local CharCustomization = Knit.CreateController {
	Name = "CharCustomization";
}
local CameraOriginalCFrame;
function CharCustomization:ModifyCharacter()
    controls:Disable()

    local Camera = workspace.CurrentCamera
    Camera.CameraType = Enum.CameraType.Scriptable

    local Player = game:GetService("Players").LocalPlayer
    local Mouse = Player:GetMouse()
    local RunService = game:GetService("RunService")

    local player = game.Players.LocalPlayer
    local character = player.Character
    local primary = character.PrimaryPart

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Parent = primary
    bodyGyro.D = 40
    bodyGyro.P = 10000
    bodyGyro.MaxTorque = Vector3.new(4000000, 4000000, 4000000)
    bodyGyro.CFrame = primary.CFrame


    janitor:Add(bodyGyro)

    local function rayPlane(planepoint, planenormal, origin, direction)
        return -((origin-planepoint):Dot(planenormal))/(direction:Dot(planenormal))
    end

    janitor:Add(UserInputService.InputBegan:Connect(function(input)
        local inputType = input.UserInputType
        if inputType == Enum.UserInputType.MouseButton1 then
            cameraJanitor:Add(RunService.Stepped:Connect(function ()
                local ray = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
                local UI = PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)

                if UI then
                    if table.find(UI, MainUI.Pages.CharacterCustomization.MoveAvatar) then

                        local t = rayPlane(Player.Character.Head.Position, Vector3.new(0, 1, 0), ray.Origin, ray.Direction)
                        
                        local primaryPos = primary.Position
                            
                        local plane_intersection_point = (ray.Direction * t) + ray.Origin
                        bodyGyro.CFrame = CFrame.new(primaryPos, Vector3.new(plane_intersection_point.X, primaryPos.Y, plane_intersection_point.Z))
                    end
                end
            end))
         end
     end))
     
     janitor:Add(UserInputService.InputEnded:Connect(function(input)
         local inputType = input.UserInputType
         if inputType == Enum.UserInputType.MouseButton1 then
            cameraJanitor:Cleanup()
         end
     end))

     Tween(Camera, {"CFrame"}, {CFrame.new((Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, -6)).Position, Player.Character.HumanoidRootPart.Position)  })
end

function CharCustomization:LoadItemsFrame()
    -- Reset Current Items
    itemsJanitor:Cleanup()

    for _, button in pairs(MainCustomizationFrame.Main.Main.Scroll:GetChildren()) do
        if button:IsA("ImageButton") then
            button:Remove()
        end
    end

    -- Load new items
    if Category ~= "AvatarEditor" then
        for _, ItemID in pairs(CustomizationOptions[Category]) do
            local ImageButon = SquareTemplate:Clone()
            ImageButon.Icon.Image = string.format("https://www.roblox.com/asset-thumbnail/image?assetId=%d&width=420&height=420&format=png", ItemID)
            ImageButon:SetAttribute("AssetID", ItemID)

            itemsJanitor:Add(
                ImageButon.MouseButton1Click:connect(function ()
                    AvatarService:RequestChangeAsset(Category, ItemID)
                end)
            )

            ImageButon.Parent = MainCustomizationFrame.Main.Main.Scroll
        end
    else
        -- Load Avatar Editor
    end

    MainCustomizationFrame.Main.Main.Scroll.CanvasSize = UDim2.new(0, 0, 0, MainCustomizationFrame.Main.Main.Scroll.UIGridLayout.AbsoluteContentSize.Y)
end

function CharCustomization:Load()
    local Categories = MainCustomizationFrame.Categories
    local MainFrame = MainCustomizationFrame.Main

    self:LoadItemsFrame()

    -- Enable/Handle Category changing
    for _, button in pairs(Categories.Tabs.Main.List:GetChildren()) do
        if button:IsA("ImageButton") then

            janitor:Add(
                button.MouseButton1Click:connect(function ()
                    if button:GetAttribute("Category") ~= Category then
                        self:UpdateCategoryButtons(Category, button:GetAttribute("Category"))
                        self:LoadItemsFrame()
                    end
                end)
            )
        end
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

    local Camera = workspace.CurrentCamera
    CameraOriginalCFrame = Camera.CFrame

    self:UpdateCategoryButtons(nil, Category)
    self:Load()
    self:ModifyCharacter()

    MainCustomizationFrame["Self"].Visible = true

    Tween(MainCustomizationFrame.Categories, {"Position"}, {UDim2.new(-0.15, 0, 0.5, 0)}, 0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    Tween(MainCustomizationFrame.Main, {"Position"}, {UDim2.new(1.06, 0, 0.5, 0)}, 0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
end

function CharCustomization:Close()
    janitor:Cleanup()
    itemsJanitor:Cleanup()
    cameraJanitor:Cleanup()

    local Camera = workspace.CurrentCamera
    Camera.CameraType = Enum.CameraType.Custom

    Tween(Camera, {"CFrame"}, {CameraOriginalCFrame})

    UIController:ToggleShowHotbar(false)
    UIController:ToggleShowSidebuttons(false)

    Tween(MainCustomizationFrame.Categories, {"Position"}, {CategoriesOriginalPos}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local tweenObj = Tween(MainCustomizationFrame.Main, {"Position"}, {MainOriginalPos}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    spawn(function ()
        tweenObj.Completed:Wait()
        MainCustomizationFrame["Self"].Visible = false
    end)

    controls:Enable()
    UIController.UI_Open = nil
end

function CharCustomization:UpdateCategoryButtons(previousChanging, newSelected)
    local CategoryChildren = MainCustomizationFrame.Categories:GetDescendants()

    Category = newSelected
    for _, button in pairs(CategoryChildren) do
        if button:GetAttribute("Interaction_Type") and button:IsA("ImageButton") then
            if button:GetAttribute("Category") == previousChanging then
                button.ImageColor3 = Color3.fromRGB(255, 255, 255)
            elseif button:GetAttribute("Category") == Category then
                button.ImageColor3 = Color3.fromRGB(155, 155, 155)
            end
        end
    end
end

function CharCustomization:Initialize(UI)
    ClientInput = Knit.GetController("InputController")
    UIController = Knit.GetController("UIController")

    AvatarService = Knit.GetService("AvatarService")


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