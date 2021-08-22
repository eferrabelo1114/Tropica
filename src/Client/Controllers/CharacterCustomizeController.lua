-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local AvatarService;
local ProfileInterface;

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

local Camera = workspace.CurrentCamera

local CategoriesOriginalPos = UDim2.new(-0.5, 0 ,0.5, 0)
local MainOriginalPos = UDim2.new(1.5, 0 ,0.5, 0)

local Category = "Shirt"

-- Create UIController Controller:
local CharCustomization = Knit.CreateController {
	Name = "CharCustomization";
}

-- Rounding Function MOVE THIS IN THE FUTURE
local roundDecimals = function(num, places) --num is your number or value and places is number of decimal places, in your case you would need 2
    
    places = math.pow(10, places or 0)
    num = num * places
   
    if num >= 0 then 
        num = math.floor(num + 0.5) 
    else 
        num = math.ceil(num - 0.5) 
    end
    
    return num / places
    
end


function CharCustomization:UpdateItemButtons() --FOR THE LOVE OF GOD FIND
    local profileData = ProfileInterface:GetProfile(Player)

    for _,button in pairs (MainCustomizationFrame.Main.Main.Scroll:GetChildren()) do
        if button:IsA("ImageButton") then
            local AssetID = button:GetAttribute("AssetID")

            if Category == "Accessory" then
                if table.find(profileData.AccessoriesWearing, AssetID) then
                    button.ImageColor3 = Color3.fromRGB(170, 255, 164)
                else
                    button.ImageColor3 = Color3.fromRGB(255,255,255)
                end
            elseif Category == "Shirt" then
                if profileData.Outfit.Clothes.S == AssetID then
                    button.ImageColor3 = Color3.fromRGB(170, 255, 164)
                else
                    button.ImageColor3 = Color3.fromRGB(255,255,255)
                end
            elseif Category == "Pants" then
                if profileData.Outfit.Clothes.P == AssetID then
                    button.ImageColor3 = Color3.fromRGB(170, 255, 164)
                else
                    button.ImageColor3 = Color3.fromRGB(255,255,255)
                end
            elseif Category == "Hair" then
                if profileData.Outfit.Accessories.Hair == AssetID then
                    button.ImageColor3 = Color3.fromRGB(170, 255, 164)
                else
                    button.ImageColor3 = Color3.fromRGB(255,255,255)
                end
            elseif Category == "Faces" then
                if profileData.Face == AssetID then
                    button.ImageColor3 = Color3.fromRGB(170, 255, 164)
                else
                    button.ImageColor3 = Color3.fromRGB(255,255,255)
                end
            end
        end
    end
end

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
    bodyGyro.P = 1000000
    bodyGyro.MaxTorque = Vector3.new(400000000, 400000000, 400000000)
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

     Tween(Camera, {"CFrame"}, {CFrame.new((Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, -7)).Position, Player.Character.HumanoidRootPart.Position)  })
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
        if MainCustomizationFrame.Main.Main.Editor.Visible == true then 
            MainCustomizationFrame.Main.Main.Editor.Visible = false 
        end

        for _, ItemID in pairs(CustomizationOptions[Category]) do
            local ImageButon = SquareTemplate:Clone()
            ImageButon.Icon.Image = string.format("https://www.roblox.com/asset-thumbnail/image?assetId=%d&width=420&height=420&format=png", ItemID)
            ImageButon:SetAttribute("AssetID", ItemID)

            if Category ~= "Faces" then
                itemsJanitor:Add(
                    ImageButon.MouseButton1Click:connect(function()
                        AvatarService:RequestChangeAsset(Category, ItemID)
                        self:UpdateItemButtons()
                    end)
                )
            else
                itemsJanitor:Add(
                    ImageButon.MouseButton1Click:connect(function()
                        AvatarService:RequestChangeFace(ItemID)
                        self:UpdateItemButtons()
                    end)
                )
            end

            ImageButon.Parent = MainCustomizationFrame.Main.Main.Scroll
        end

        self:UpdateItemButtons()
    elseif Category == "AvatarEditor" then
        if MainCustomizationFrame.Main.Main.Editor.Visible == false then 
            MainCustomizationFrame.Main.Main.Editor.Visible = true 
        end

        local AvatarEditorFrame = MainCustomizationFrame.Main.Main.Editor.AvatarSize

        local IncreaseSize = AvatarEditorFrame.Increase
        local DecreaseSize = AvatarEditorFrame.Decrease
        local SizeText = AvatarEditorFrame:FindFirstChild("Size")
        SizeText.Text = tostring(roundDecimals((Player.Character.Humanoid.BodyHeightScale.Value), 2))
        
        itemsJanitor:Add(
            IncreaseSize.MouseButton1Click:connect(function()
                SizeText.Text = tostring(roundDecimals(AvatarService:RequestAvatarSize("Increase"), 2))
                Tween(Camera, {"CFrame"}, {CFrame.new((Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, -7)).Position, Player.Character.HumanoidRootPart.Position)  }, 0.1)
            end)
        )

        itemsJanitor:Add(
            DecreaseSize.MouseButton1Click:connect(function()
                SizeText.Text = tostring(roundDecimals(AvatarService:RequestAvatarSize("Decrease"), 2))
                Tween(Camera, {"CFrame"}, {CFrame.new((Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, -7)).Position, Player.Character.HumanoidRootPart.Position)  }, 0.1)
            end)
        )

        local Skin_Tone_Frame = MainCustomizationFrame.Main.Main.Editor.Colors
        for _,skinColor in pairs(CustomizationOptions["Skintones"]) do
            local button = Instance.new("TextButton")
            button.Text = ""
            button.Size = UDim2.new(0, 40, 0, 50)
            button.BackgroundColor3 = skinColor
            button.BorderSizePixel = 0
            button.ZIndex = Skin_Tone_Frame.ZIndex + 1
            button.Parent = Skin_Tone_Frame

            itemsJanitor:Add(button)
            itemsJanitor:Add(button.MouseButton1Click:connect(function()
                AvatarService:RequestSkintoneChange(skinColor)
            end))
        end

        MainCustomizationFrame.Main.Main.Editor.Colors.CanvasSize = UDim2.new(0, 0, 0, MainCustomizationFrame.Main.Main.Editor.Colors.UIGridLayout.AbsoluteContentSize.Y)
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
            self:Close()
        end)
    )

    janitor:Add(
        Categories.Tabs.Main.Reset.MouseButton1Click:connect(function ()
            AvatarService:ResetToDefault()
            self:UpdateItemButtons()
        end)
    )

    janitor:Add(
        Categories.Tabs.Main.Remove_Accesories.MouseButton1Click:connect(function ()
            AvatarService:RemoveAccesories()
            self:UpdateItemButtons()
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

    Tween(MainCustomizationFrame.Categories, {"Position"}, {UDim2.new(-0.141, 0,0.5, 0)}, 0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
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
    ProfileInterface = Knit.GetService("ProfileInterface")
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