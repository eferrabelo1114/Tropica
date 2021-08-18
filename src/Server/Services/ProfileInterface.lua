-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game.StarterGui.MainGui.Parent = ReplicatedStorage

local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local ProfileService = require(ServerScriptService.ProfileService)
local Knit = require(ReplicatedStorage.Knit)
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local Players = game:GetService("Players")

-- Create ProfileInterface Service:
local ProfileInterface = Knit.CreateService{
	Name = "ProfileInterface";
	Client = {};
}

-- Public Variables
ProfileInterface.Profiles = {}
ProfileInterface.Client.ProfileLoaded = RemoteSignal.new()

-- Private Varirables


local ProfileTemplate = { -- Profile Template
    Nametag = {
        ["TextColor"] = {255, 255, 255};
        ["BorderColor"] = {0, 0, 0};
        ["Text"] = "Name";
    }
}

local ProfileStore = ProfileService.GetProfileStore( --Profile Data Store
    "Tropica_Data_Version1.0",
    ProfileTemplate
)


-- Functions

function ProfileInterface:LoadProfile(Player, Profile)

    -- Load Nametag Data
    for Attribute, Data in pairs(Profile.Data.Nametag) do
        if typeof(Data) == "string" then
            Player:SetAttribute("Nametag_"..Attribute, Data)
        else
            Player:SetAttribute("Nametag_"..Attribute, Color3.fromRGB(Data[1], Data[2], Data[3]))
        end
    end

    -- Character Stuff
    function Profile:UpdateNametag(text, textcolor, bordercolor)
        local nametagText = function()
            if text ~= nil then return text else return Player:GetAttribute("Nametag_Text") end
        end

        local nametagTextColor = function ()
            if textcolor then return textcolor else return Player:GetAttribute("Nametag_TextColor") end
        end

        local nametagBorderColor = function ()
            if bordercolor then return bordercolor else return Player:GetAttribute("Nametag_BorderColor") end
        end
        
        
        if Player.Character then
            local char = Player.Character
            local nametag

            if char.Head:FindFirstChild("Nametag") == nil then
                local BillboardGui = Instance.new("BillboardGui")
                BillboardGui.AlwaysOnTop = true
                BillboardGui.LightInfluence = 0
                BillboardGui.Size = UDim2.new(9, 0, 2, 0)
                BillboardGui.StudsOffset = Vector3.new(0, 2, 0)

                local NametagText = Instance.new("TextLabel")
                NametagText.BackgroundTransparency = 1
                NametagText.Size = UDim2.new(1, 0, 1, 0)
                NametagText.TextScaled = true
                NametagText.TextStrokeTransparency = 0
                NametagText.Font = Enum.Font.FredokaOne
                NametagText.Parent = BillboardGui

                BillboardGui.Parent = char.Head
                nametag = NametagText
            else
                nametag = char.Head:FindFirstChild("Nametag")
            end

            nametag.Text = nametagText()
            nametag.TextStrokeColor3 = nametagBorderColor()
            nametag.TextColor3 = nametagTextColor()
        end
    end


    if Player.Character then
        Profile:UpdateNametag()
    end

    Player.CharacterAppearanceLoaded:connect(function()
        Profile:UpdateNametag()
    end)
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

            self.Profiles[player].Data.Nametag.Text = player.Name
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




