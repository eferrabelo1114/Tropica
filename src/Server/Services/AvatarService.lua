-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local InsertService = game:GetService("InsertService")
local PhysicsService = game:GetService("PhysicsService")

-- Private Variables
local Knit = require(ReplicatedStorage.Knit)

local ProfileInterface

local AssetsFolder

-- Public varaibles
local MAX_ACCESSORIES = 4 --CURRENTLY THE MAX ACCESSORIES IS 1 ABOVE THIS NUMBER, I DONT CARE JUST TAKE THIS INTO COUNT

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
        if AssetType ~= "Skintones" and AssetType ~= "Faces" then 

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

local PossibleAccessories = {"Face", "Front", "Hat", "Neck", "Shoulders", "Waist"}
function AvatarService:GetAccessoriesFromDesc(Desc)
    local Accessories = {}

    for _, PossibleAccesory in pairs(PossibleAccessories) do
        if Desc[PossibleAccesory.."Accessory"] and Desc[PossibleAccesory.."Accessory"] ~= "" then
            table.insert(Accessories, Desc[PossibleAccesory.."Accessory"])
        end
    end

    return Accessories
end

function AvatarService:GetAccessoriesEquippedLeft(char)
    local TotalEquipped = 0

    if char then
        local Player = game.Players:GetPlayerFromCharacter(char)
        local Profile = ProfileInterface.Profiles[Player]

        local EquippedAccessories = Profile.Data.AccessoriesWearing

        for _, AccessoryID in pairs(EquippedAccessories) do
            if not table.find(Profile.TempData["DefaultCharacterAccessories"], AccessoryID) then
                TotalEquipped = TotalEquipped + 1
            end

        end
    end

    return MAX_ACCESSORIES - TotalEquipped
end

function AvatarService:EquipAccessory(char, accessoryID, default)
    if char then
        local Humanoid = char.Humanoid
        local Asset = AvatarService:RetrieveAsset("Accessory", accessoryID)

        if Asset == nil and default == true then
            local AssetOBJ = InsertService:LoadAsset(accessoryID)

            Asset = AssetOBJ:FindFirstChildOfClass("Accessory"):Clone()
            Asset:SetAttribute("AssetID", accessoryID)

            AssetOBJ:Remove()
            AssetOBJ = nil
        end

        if Asset then
            Humanoid:AddAccessory(Asset)
        end
    end
end

function AvatarService:ChangeFace(player, faceID)
    if player.Character then
        if ProfileInterface.Profiles[player].Data.Face ~= faceID then
            ProfileInterface.Profiles[player].Data.Face = faceID
        end
        

        local Humanoid = player.Character.Humanoid


        local CurrentClothing = Humanoid:GetAppliedDescription()
        CurrentClothing.Face = ProfileInterface.Profiles[player].Data.Face

        Humanoid:ApplyDescription(CurrentClothing)
    end
end

function AvatarService.Client:ResetToDefault(player)
    if player.Character then
        local char = player.Character
        local profile = ProfileInterface.Profiles[player]

        AvatarService.Client:RemoveAccesories(player)

        local DefaultOutfit = profile.TempData.DefaultCharacterDescription
        local DefaultAccessories = profile.TempData.DefaultCharacterAccessories
        local DefaultFace = profile.TempData.DefaultFace

        profile.Data.Outfit = AvatarService:TurnDescriptionIntoTable(DefaultOutfit)
        profile.Data.Face = DefaultFace

        for _,v in pairs(DefaultAccessories) do
            table.insert(profile.Data.AccessoriesWearing, v)
        end

        local description = AvatarService:CreateDescriptionFromTable(profile.Data.Outfit)

        AvatarService:ChangeFace(player, DefaultFace)
        char.Humanoid:ApplyDescription(description)

        for _, AccessoryID in pairs(DefaultAccessories) do
            AvatarService:EquipAccessory(char, AccessoryID, true)
        end
    end
end

function AvatarService.Client:RequestChangeFace(player, faceID)
    if player.Character then
        if ProfileInterface.Profiles[player] then
            local profile = ProfileInterface.Profiles[player]

            if table.find(CustomizationOptions.Faces, faceID) then
                if profile.Data.Face ~= faceID then
                    profile.Data.Face = faceID
                    AvatarService:ChangeFace(player, faceID)
                end
            end 
        end
    end
end

function AvatarService.Client:RemoveAccesories(player)
    if player.Character then
        local Humanoid = player.Character.Humanoid

        local AccessoriesWearingData = ProfileInterface.Profiles[player].Data.AccessoriesWearing
        local HumanoidAccesoriesWearing = Humanoid:GetAccessories()

        for _, accessory in pairs(HumanoidAccesoriesWearing) do
            if accessory:GetAttribute("AssetID") then

                local AssetID = accessory:GetAttribute("AssetID")

                if table.find(AccessoriesWearingData, AssetID) then
                    local i = table.find(AccessoriesWearingData, AssetID)
                    accessory:Remove()
                    table.remove(ProfileInterface.Profiles[player].Data.AccessoriesWearing, i)
                end
            end
        end

    end
end

function AvatarService.Client:RequestAvatarSize(player, change)
    if player.Character then
        local Humanoid = player.Character.Humanoid

        if change == "Increase" then
            if ProfileInterface.Profiles[player].Data.Outfit.Scale.Height < 1.2 then
                ProfileInterface.Profiles[player].Data.Outfit.Scale.Height = ProfileInterface.Profiles[player].Data.Outfit.Scale.Height + 0.05
                ProfileInterface.Profiles[player].Data.Outfit.Scale.Depth = ProfileInterface.Profiles[player].Data.Outfit.Scale.Depth + 0.05
                ProfileInterface.Profiles[player].Data.Outfit.Scale.Width = ProfileInterface.Profiles[player].Data.Outfit.Scale.Width + 0.05
                ProfileInterface.Profiles[player].Data.Outfit.Scale.Head = ProfileInterface.Profiles[player].Data.Outfit.Scale.Head + 0.05
            end
            
            local CurrentClothing = Humanoid:GetAppliedDescription()
            CurrentClothing.HeightScale = ProfileInterface.Profiles[player].Data.Outfit.Scale.Height
            CurrentClothing.DepthScale = ProfileInterface.Profiles[player].Data.Outfit.Scale.Depth
            CurrentClothing.WidthScale = ProfileInterface.Profiles[player].Data.Outfit.Scale.Width
            CurrentClothing.HeadScale = ProfileInterface.Profiles[player].Data.Outfit.Scale.Head

            Humanoid:ApplyDescription(CurrentClothing)
        elseif change == "Decrease" then
            if ProfileInterface.Profiles[player].Data.Outfit.Scale.Height > 0.7 then
                ProfileInterface.Profiles[player].Data.Outfit.Scale.Height = ProfileInterface.Profiles[player].Data.Outfit.Scale.Height - 0.05
                ProfileInterface.Profiles[player].Data.Outfit.Scale.Depth = ProfileInterface.Profiles[player].Data.Outfit.Scale.Depth - 0.05
                ProfileInterface.Profiles[player].Data.Outfit.Scale.Width = ProfileInterface.Profiles[player].Data.Outfit.Scale.Width - 0.05
                ProfileInterface.Profiles[player].Data.Outfit.Scale.Head = ProfileInterface.Profiles[player].Data.Outfit.Scale.Head - 0.05
            end
            
            local CurrentClothing = Humanoid:GetAppliedDescription()
            CurrentClothing.HeightScale = ProfileInterface.Profiles[player].Data.Outfit.Scale.Height
            CurrentClothing.DepthScale = ProfileInterface.Profiles[player].Data.Outfit.Scale.Depth
            CurrentClothing.WidthScale = ProfileInterface.Profiles[player].Data.Outfit.Scale.Width
            CurrentClothing.HeadScale = ProfileInterface.Profiles[player].Data.Outfit.Scale.Head

            Humanoid:ApplyDescription(CurrentClothing)
        end

        return ProfileInterface.Profiles[player].Data.Outfit.Scale.Height
    end
end

function AvatarService.Client:RequestSkintoneChange(player, SkintoneColor)
    if player.Character then
        local Humanoid = player.Character.Humanoid
        local TableColor = getSaveableColor3(SkintoneColor)

        if ProfileInterface.Profiles[player].Data.Outfit.BodyColors.H ~=  TableColor then
            ProfileInterface.Profiles[player].Data.Outfit.BodyColors.H = TableColor
            ProfileInterface.Profiles[player].Data.Outfit.BodyColors.LA = TableColor
            ProfileInterface.Profiles[player].Data.Outfit.BodyColors.LL = TableColor
            ProfileInterface.Profiles[player].Data.Outfit.BodyColors.RA = TableColor
            ProfileInterface.Profiles[player].Data.Outfit.BodyColors.RL = TableColor
            ProfileInterface.Profiles[player].Data.Outfit.BodyColors.T = TableColor
        end
        
        local CurrentClothing = Humanoid:GetAppliedDescription()
        CurrentClothing.HeadColor = SkintoneColor
        CurrentClothing.LeftArmColor = SkintoneColor
        CurrentClothing.LeftLegColor = SkintoneColor
        CurrentClothing.RightArmColor = SkintoneColor
        CurrentClothing.RightLegColor = SkintoneColor
        CurrentClothing.TorsoColor = SkintoneColor


        Humanoid:ApplyDescription(CurrentClothing)
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
                        if AvatarService:GetAccessoriesEquippedLeft(player.Character) > 0 then
                            table.insert(AccessoriesWearingData, AssetID)
                            Humanoid:AddAccessory(Asset)
                        else
                            -- MAX ACCESSORIES WEARING
                        end
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

function AvatarService.Client:AvatarEditing(player, toggle)
    if player.Character then
        local char = player.Character

        if toggle then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    PhysicsService:SetPartCollisionGroup(v, "AvatarEditing")
                end
            end
        else
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    PhysicsService:SetPartCollisionGroup(v, "Characters")
                end
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