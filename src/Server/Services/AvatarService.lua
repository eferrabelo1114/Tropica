-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local InsertService = game:GetService("InsertService")

-- Private Variables
local Knit = require(ReplicatedStorage.Knit)

local ProfileInterface

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

function AvatarService:RetrieveAsset(Type, AssetID)
    local AssetType = Type

    if AssetType == "Hair" then AssetType = "Accessory" end

    if AssetsFolder:FindFirstChild(Type) then
        local TypeFolder = AssetsFolder:FindFirstChild(Type)

        for _, Asset in pairs(TypeFolder:GetChildren()) do
            if Asset:GetAttribute("AssetID") == AssetID then
                return Asset:Clone()
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

function AvatarService:TurnDescriptionIntoTable(description)
    local descTable = {}

    descTable["Accessories"] = {
        ["Hair"] = description.HairAccessory;
    }
    
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

    print(description)
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

	description.HairAccessory = descriptionTable.Accessories.Hair

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

function AvatarService:GetAccessoriesFromDesc(Desc)
    local Accessories = {}
    local AccessoriesInDesc = Desc.Accessories

    for _, accessory in pairs(AccessoriesInDesc) do
        table.insert(Accessories, accessory)
    end

    return Accessories
end

function AvatarService:EquipAccessory(char, accessoryID)
    if char then
        local Humanoid = char.Humanoid
        local Asset = AvatarService:RetrieveAsset("Accessory", accessoryID)

        if Asset then
            Humanoid:AddAccessory(Asset)
        end
    end
end

function AvatarService.Client:RequestChangeAsset(player, AssetType, AssetID)
    if player.Character then
        local Humanoid = player.Character.Humanoid
        local Asset = AvatarService:RetrieveAsset(AssetType, AssetID)
            
        if Asset ~= nil then
            if AssetType == "Accessory" then
                local AccessoriesWearingData = ProfileInterface.Profiles[player].Data.AccessoriesWearing
                --Check if player is already wearing accessory
                local AlreadyWearing, wearingAccessory = false, nil
                for _, accessory in pairs(Humanoid:GetAccessories()) do
                    if accessory:GetAttribute("AssetID") then
                        local alreadyWearingAccessoryID = accessory:GetAttribute("AssetID")
                        if alreadyWearingAccessoryID == Asset:GetAttribute("AssetID") then
                            AlreadyWearing = true
                            wearingAccessory = accessory
                        end
                    end
                end

                if not AlreadyWearing then
                    -- Add Accessory
                    table.insert(AccessoriesWearingData, AssetID)
                    Humanoid:AddAccessory(Asset)
                else
                    -- Remove Accessory
                    local i = table.find(AccessoriesWearingData, AssetID)
                    table.remove(AccessoriesWearingData, i)
                    wearingAccessory:Remove()
                end 
            elseif AssetType == "Hair" then
                if ProfileInterface.Profiles[player].Data.Outfit.Accessories.Hair ~= AssetID then
                    ProfileInterface.Profiles[player].Data.Outfit.Accessories.Hair = AssetID

                    local CurrentClothing = Humanoid:GetAppliedDescription()
                    CurrentClothing.HairAccessory = ProfileInterface.Profiles[player].Data.Outfit.Accessories.Hair

                    Humanoid:ApplyDescription(CurrentClothing)
                else
                    ProfileInterface.Profiles[player].Data.Outfit.Accessories.Hair = ""

                    local CurrentClothing = Humanoid:GetAppliedDescription()
                    CurrentClothing.HairAccessory = ProfileInterface.Profiles[player].Data.Outfit.Accessories.Hair

                    Humanoid:ApplyDescription(CurrentClothing)
                end
            elseif AssetType == "Shirt" then
                if ProfileInterface.Profiles[player].Data.Outfit.Clothes.S ~= AssetID then
                    ProfileInterface.Profiles[player].Data.Outfit.Clothes.S = AssetID
                end
                
                local CurrentClothing = Humanoid:GetAppliedDescription()
                CurrentClothing.Shirt = ProfileInterface.Profiles[player].Data.Outfit.Clothes.S

                Humanoid:ApplyDescription(CurrentClothing)
            elseif AssetType == "Pants" then
                if ProfileInterface.Profiles[player].Data.Outfit.Clothes.P ~= AssetID then
                    ProfileInterface.Profiles[player].Data.Outfit.Clothes.P = AssetID
                end
                
                local CurrentClothing = Humanoid:GetAppliedDescription()
                CurrentClothing.Pants = ProfileInterface.Profiles[player].Data.Outfit.Clothes.P

                Humanoid:ApplyDescription(CurrentClothing)
            end
        end

    end
end


function AvatarService:KnitStart()
    ProfileInterface = Knit.GetService("ProfileInterface")

    self:LoadAssets()

    return
end


return AvatarService