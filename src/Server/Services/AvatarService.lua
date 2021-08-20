-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local InsertService = game:GetService("InsertService")

-- Private Variables
local Knit = require(ReplicatedStorage.Knit)

local ProfileInterface = Knit.GetService("ProfileInterface")

local AssetsFolder

-- Modules
local CustomizationOptions = require(ReplicatedStorage.Modules.Customization)

-- Create Nametag Service
local AvatarService = Knit.CreateService{
	Name = "AvatarService";
	Client = {};
}


-- Functions


local Avatar = {
    ["Shirt"] = 0000;
    ["Pants"] = 0000;
    ["Scale"] = 0;
    ["Hair"] = 0000;
    ["Accesories"] = {};
}


function AvatarService:LoadAssets()
    AssetsFolder = Instance.new("Folder")
    AssetsFolder.Name = "Assets"
    
    for AssetType, AssetIDs in pairs(CustomizationOptions) do
        local AssetTypeFolder = Instance.new("Folder")
        AssetTypeFolder.Name = AssetType

        if AssetType == "Hair" then AssetType = "Accessory" end

        for _, AssetID in pairs(AssetIDs) do
            local AssetOBJ = InsertService:LoadAsset(AssetID)
            
            local Asset = AssetOBJ:FindFirstChildOfClass(AssetType)
            Asset:SetAttribute("AssetID", AssetID)
            Asset.Parent = AssetTypeFolder

            AssetOBJ:Remove()
            AssetOBJ = nil
        end

        AssetTypeFolder.Parent = AssetsFolder
    end


    AssetsFolder.Parent = ReplicatedStorage
end

function AvatarService:RetrieveAsset(AssetType, AssetID)
    if AssetsFolder:FindFirstChild(AssetType) then
        local TypeFolder = AssetsFolder:FindFirstChild(AssetType)

        for _, Asset in pairs(TypeFolder:GetChildren()) do
            if Asset:GetAttribute("AssetID") == AssetID then
                return Asset
            end
        end

    end

    return nil
end

local function getSaveableColor3(color)
	return {r = color.r, g = color.g, b = color.b}
end

local function loadColorFromTable(t)
	return Color3.new(t.r, t.g, t.b)
end

function AvatarService:TurnTableIntoDescription(description)
    local descTable = {}

    descTable["Scale"] = {
        ["BodyType"] = description.BodyTypeScale;
        ["Depth"] = description.DepthScale;
        ["Head"] = description.HeadScale;
        ["Height"] = description.HeightScale;
        ["Proportion"] = description.ProportionScale;
        ["Width"] = description.WidthScale;
    }

    descTable["BodyParts"] = {
        ["F"] = description.Face;
        ["H"] = description.Head;
        ["LA"] = description.LeftArm;
        ["LL"] = description.LeftLeg;
        ["RA"] = description.RightArm;
        ["RL"] = description.RightLeg;
        ["T"] = description.Torso;
    }

    descTable["Clothes"] = {
        ["TShirt"] = description.GraphicTShirt;
        ["P"] = description.Pants;
        ["S"] = description.Shirt;
    }

    descTable["BodyColors"] = {
        ["H"] = getSaveableColor3(description.HeadColor);
        ["LA"] = getSaveableColor3(description.LeftArmColor);
        ["LL"] = getSaveableColor3(description.LeftLegColor);
        ["RA"] = getSaveableColor3(description.RightArmColor);
        ["RL"] = getSaveableColor3(description.RightLegColor);
        ["T"] = getSaveableColor3(description.TorsoColor);
    }

    return descTable
end

function AvatarService:CreateDescriptionFromTable(descriptionTable)
	local description = Instance.new("HumanoidDescription")

	description.BackAccessory = nil
	description.FaceAccessory = nil
	description.FrontAccessory = nil
	description.HairAccessory = nil
	description.HatAccessory = nil
	description.NeckAccessory = nil
	description.ShouldersAccessory = nil
	description.WaistAccessory = nil

	description.BodyTypeScale = descriptionTable.Scale.BodyType
	description.DepthScale = descriptionTable.Scale.Depth
	description.HeadScale = descriptionTable.Scale.Head
	description.HeightScale = descriptionTable.Scale.Height
	description.ProportionScale = descriptionTable.Scale.Proportion
	description.WidthScale = descriptionTable.Scale.Width

	description.Face = descriptionTable.BodyParts.F
	description.Head = descriptionTable.BodyParts.H
	description.LeftArm = descriptionTable.BodyParts.LA
	description.LeftLeg = descriptionTable.BodyParts.LL
	description.RightArm = descriptionTable.BodyParts.RA
	description.RightLeg = descriptionTable.BodyParts.RL
	description.Torso = descriptionTable.BodyParts.T

	description.GraphicTShirt = descriptionTable.Clothes.TShirt
	description.Pants = descriptionTable.Clothes.P
	description.Shirt = descriptionTable.Clothes.S

	description.HeadColor = loadColorFromTable(descriptionTable.BodyColors.H)
	description.LeftArmColor = loadColorFromTable(descriptionTable.BodyColors.LA)
	description.LeftLegColor = loadColorFromTable(descriptionTable.BodyColors.LL)
	description.RightArmColor = loadColorFromTable(descriptionTable.BodyColors.RA)
	description.RightLegColor = loadColorFromTable(descriptionTable.BodyColors.RL)
	description.TorsoColor = loadColorFromTable(descriptionTable.BodyColors.T)

	return description
end

function AvatarService:ApplyAccessories(Profile, Char)

    

end


function AvatarService.Client:RequestChangeAsset(player, AssetType, AssetID)
    if player.Character then
        local Humanoid = player.Character.Humanoid
        local Asset = AvatarService:RetrieveAsset(AssetType, AssetID)
        
        if Asset ~= nil then
            local asset = Asset:Clone()

            if AssetType == "Hair" or "Accessory" then
                --Check if player is already wearing accessory
                local AlreadyWearing, wearingAccessory = false, nil
                for _, accessory in pairs(Humanoid:GetAccessories()) do
                    if accessory:GetAttribute("AssetID") then
                        local alreadyWearingAccessoryID = accessory:GetAttribute("AssetID")
                        if alreadyWearingAccessoryID == asset:GetAttribute("AssetID") then
                            AlreadyWearing = true
                            wearingAccessory = accessory
                        end
                    end
                end

                if not AlreadyWearing then
                    -- Add Accessory
                    Humanoid:AddAccessory(asset)
                else
                    -- Remove Accessory
                    wearingAccessory:Remove()
                end 
            end
        end

    end
end


function AvatarService:KnitStart()
    self:LoadAssets()

    return
end


return AvatarService