-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

local Knit = require(ReplicatedStorage.Knit)
local Tween = require(Knit.Util.Tween)
local Janitor = require(Knit.Util.Janitor)

local CustomizationOptions = require(ReplicatedStorage.Modules.Customization)

-- Controllers
local ClientInput;
local UIController;

local InputType;
local InputFunctions;

-- Private Variables
local UI_Parts = ReplicatedStorage.UI_Parts
local SquareTemplate = UI_Parts.Template

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

    self:UpdateCategoryButtons(nil, Category)
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