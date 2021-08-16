-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileService = require(ServerScriptService.ProfileService)
local Knit = require(ReplicatedStorage.Knit)

local Players = game:GetService("Players")

-- Create ProfileInterface Service:
local ProfileInterface = Knit.CreateService {
	Name = "ProfileInterface";
	Client = {};
}

-- Public Variables
ProfileInterface.Profiles = {}

-- Private Varirables


local ProfileTemplate = { -- Profile Template
    Cash = 0;
}

local ProfileStore = ProfileService.GetProfileStore( --Profile Data Store
    "Tropica_Data_Version1.0",
    ProfileTemplate
)


-- Functions

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

            --Loaded Profile now do things




        else
            profile:Release()
        end

    else
        -- Couldnt load profile
        player:Kick("Couldn't load profile, please reconnect")
    end
end

function ProfileInterface:KnitInit()
    


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




