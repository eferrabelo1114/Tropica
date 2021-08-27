-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local ProfileService = require(ServerScriptService.ProfileService)
local Knit = require(ReplicatedStorage.Knit)
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local Players = game:GetService("Players")

local AvatarService;

-- Create ProfileInterface Service:
local ProfileInterface = Knit.CreateService{
	Name = "ProfileInterface";
	Client = {};
}

-- Public Variables
ProfileInterface.Profiles = {}
ProfileInterface.Client.ProfileLoaded = RemoteSignal.new()

-- Settings
game.StarterGui.MainGui.Parent = ReplicatedStorage
game:GetService("Players").CharacterAutoLoads = false

-- Private Varirables


local ProfileTemplate = { -- Profile Template
    Nametag = {
        ["TextColor"] = {255, 255, 255};
        ["BorderColor"] = {0, 0, 0};
        ["Text"] = "9367bg";
    };
    Outfit = nil;
    AccessoriesWearing = {};
    Face = 000000;
    Roomsettings = {
        ["Walls"] = {};
        ["Floor"] = {};
        ["WhitelistedUsers"] = {};
        ["BannedUsers"] = {};
        ["Locked"] = false;
    }
}


local ProfileStore = ProfileService.GetProfileStore( --Profile Data Store
    "Tropica_Data_Version4.1",
    ProfileTemplate
)


-- Functions
function ProfileInterface:LoadCharacter(Player, Profile)
    if Profile.Data.Outfit == nil then --Player has no saved outfit
        -- Load Player default outfit
        local DefaultDescirptionTable = AvatarService:TurnDescriptionIntoTable(Profile.TempData["DefaultCharacterDescription"])
        Profile.Data.Outfit = DefaultDescirptionTable
 
        for _,v in pairs(Profile.TempData["DefaultCharacterAccessories"]) do
            table.insert(Profile.Data.AccessoriesWearing, v)
        end
        
        Profile.Data.Face = Profile.TempData["DefaultFace"]
        
        local AccessoriesWearing = Profile.Data.AccessoriesWearing
        local RemovedAccessoriesOutfit = AvatarService:CreateDescriptionFromTable(DefaultDescirptionTable)
       
        Player:LoadCharacterWithHumanoidDescription(RemovedAccessoriesOutfit)
        local char = Player.Character
        
        Profile:UpdateNametag()
        for _, AccessoryID in pairs(AccessoriesWearing) do
            AvatarService:EquipAccessory(char, AccessoryID, true)
        end
    else
        local OutfitSaved = AvatarService:CreateDescriptionFromTable(Profile.Data.Outfit)
        local AccessoriesWearing = Profile.Data.AccessoriesWearing

        Player:LoadCharacterWithHumanoidDescription(OutfitSaved)
        local char = Player.Character

        Profile:UpdateNametag()

        AvatarService:ChangeFace(Player, Profile.Data.Face)

        for _, AccessoryID in pairs(AccessoriesWearing) do
            AvatarService:EquipAccessory(char, AccessoryID, true)
        end
    end

    for _, v in pairs(Player.Character:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            PhysicsService:SetPartCollisionGroup(v, "Characters")
        end
    end

    Player.Character.Humanoid.Died:connect(function ()
        wait(2)
        self:LoadCharacter(Player, Profile)
    end)
end


function ProfileInterface:LoadProfile(Player, Profile)
    --Attributes
    Player:SetAttribute("RoomOwned", 0)
    Player:SetAttribute("BannedUsers", HttpService:JSONEncode(Profile.Data.Roomsettings.BannedUsers))
    Player:SetAttribute("WhitelistedUsers", HttpService:JSONEncode(Profile.Data.Roomsettings.WhitelistedUsers))
   
    -- Load Nametag Data
    for Attribute, Data in pairs(Profile.Data.Nametag) do
        if typeof(Data) == "string" then
            if Data == "9367bg" then Data = Player.Name end

            Player:SetAttribute("Nametag_"..Attribute, Data)
        else
            Player:SetAttribute("Nametag_"..Attribute, Color3.fromRGB(Data[1], Data[2], Data[3]))
        end
    end

    -- Character Stuff
    function Profile:UpdateNametag(text, textcolor, bordercolor)
        local nametagText = function()
            if text ~= nil then
                Profile.Data.Nametag.Text = text
                 return text 
            else 
                return Player:GetAttribute("Nametag_Text") 
            end
        end

        local nametagTextColor = function ()
            if textcolor then 
                Profile.Data.Nametag.TextColor = {textcolor.R * 255, textcolor.G * 255, textcolor.B * 255}
                return textcolor 
            else 
                return Player:GetAttribute("Nametag_TextColor") 
            end
        end

        local nametagBorderColor = function ()
            if bordercolor then 
                Profile.Data.Nametag.BorderColor = {bordercolor.R * 255, bordercolor.G * 255, bordercolor.B * 255}
                return bordercolor 
            else 
                return Player:GetAttribute("Nametag_BorderColor") 
            end
        end
        
        
        if Player.Character then
            local char = Player.Character
            Player.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

            local nametag

            if char.Head:FindFirstChild("Nametag") == nil then
                local BillboardGui = Instance.new("BillboardGui")
                BillboardGui.AlwaysOnTop = true
                BillboardGui.LightInfluence = 0
                BillboardGui.Size = UDim2.new(9, 0, 2, 0)
                BillboardGui.StudsOffset = Vector3.new(0, 2, 0)
                BillboardGui.Name = "Nametag"

                local NametagText = Instance.new("TextLabel")
                NametagText.BackgroundTransparency = 1
                NametagText.Size = UDim2.new(1, 0, 1, 0)
                NametagText.TextScaled = true
                NametagText.TextStrokeTransparency = 0
                NametagText.Font = Enum.Font.FredokaOne
                NametagText.Parent = BillboardGui
                NametagText.Name = "Nametag"

                BillboardGui.Parent = char.Head
                nametag = NametagText
            else
                nametag = char.Head:FindFirstChild("Nametag").Nametag
            end

            nametag.Text = nametagText()
            nametag.TextStrokeColor3 = nametagBorderColor()
            nametag.TextColor3 = nametagTextColor()

            -- Set Player Attributes
            for Attribute, Data in pairs(Profile.Data.Nametag) do
                if typeof(Data) == "string" then
                    Player:SetAttribute("Nametag_"..Attribute, Data)
                else
                    Player:SetAttribute("Nametag_"..Attribute, Color3.fromRGB(Data[1], Data[2], Data[3]))
                end
            end
        end
    end

    -- Load Character
    local PlayerDefaultOutfit = Players:GetHumanoidDescriptionFromUserId(Player.UserId)
    local PlayerAppearence = Players:GetCharacterAppearanceInfoAsync(Player.UserId)
    local defaultFace

    -- Get Default Face
    for _, appearenceAsset in pairs (PlayerAppearence.assets) do
        if appearenceAsset.assetType.name == "Face" then
            defaultFace = appearenceAsset.id
        end
    end

    Profile.TempData["DefaultCharacterDescription"] = PlayerDefaultOutfit
    Profile.TempData["DefaultCharacterAccessories"] = AvatarService:GetAccessoriesFromDesc(PlayerDefaultOutfit)
    Profile.TempData["DefaultFace"] = defaultFace
        
    self:LoadCharacter(Player, Profile)
end

function ProfileInterface.Client:GetProfile(player)
    if ProfileInterface.Profiles[player] then
        return ProfileInterface.Profiles[player].Data
    end
end

function ProfileInterface:CreateProfile(player)
    local profile = ProfileStore:LoadProfileAsync("Player_" ..player.UserId)

    if profile ~= nil then

        profile:AddUserId(player.UserId)
        profile:Reconcile()

        profile:ListenToRelease(function ()
            self.Profiles[player] = nil
            player:Kick("Profile Already Loaded")
        end)

        if player:IsDescendantOf(Players) == true then
            self.Profiles[player] = profile
            self.Profiles[player]["TempData"] = {}
            
            --Loaded Profile now do things
            self:LoadProfile(player, profile)

            ProfileInterface.Client.ProfileLoaded:Fire(player)
        else
            profile:Release()
        end

    else
        -- Couldnt load profile
        player:Kick("Couldn't load profile, please reconnect")
    end
end


function ProfileInterface:KnitStart()
    AvatarService = Knit.GetService("AvatarService")

    -- If any players joined earlier than the script loaded
    for _, player in ipairs(Players:GetPlayers()) do
        coroutine.wrap(function ()
            self:CreateProfile(player)
        end)
    end

    -- Setup Player Joined/Left connections
    Players.PlayerAdded:connect(function(player)
        self:CreateProfile(player)
    end)

    Players.PlayerRemoving:connect(function(player)
        local profile = self.Profiles[player]
        if profile then
            profile:Release()
        end
    end)
end

return ProfileInterface




