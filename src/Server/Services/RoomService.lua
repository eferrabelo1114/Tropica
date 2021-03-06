-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Private Variables
local Knit = require(ReplicatedStorage.Knit)

local ProfileInterface;
local Rooms;

-- Create Nametag Service
local RoomService = Knit.CreateService{
	Name = "RoomService";
	Client = {};
}

RoomService.Rooms = {}


-- Functions



function RoomService:FindRoomByID(RoomID)
    local Room

    for _,roomInTable in pairs(Rooms) do
        if roomInTable:GetAttribute("RoomID") == RoomID then
            Room = RoomService.Rooms[roomInTable]
        end
    end

    return Room
end

function RoomService.Client:ClaimRoom(player, RoomID)
    local Claimed = false

    if player.Character then
        if ProfileInterface.Profiles[player] then
            local profile = ProfileInterface.Profiles[player]
            local room = RoomService:FindRoomByID(RoomID)

            if room ~= nil then
                if room.Self:GetAttribute("Claimed") == false then --Make sure the room isn't owned already
                    profile.TempData.RoomOwned = room

                    room.Claimed = true
                    room.Locked = profile.Data.Roomsettings.Locked
                    room.Owner = player

                    player:SetAttribute("RoomOwned", room.RoomID)

                    room.Self:SetAttribute("Claimed", true)
                    room.Self:SetAttribute("Owner", player.Name)
                    room.Self:SetAttribute("Locked", profile.Data.Roomsettings.Locked)

                    Claimed = true
                end
            end
        end
    end

    return Claimed
end

function RoomService.Client:RequestTeleportToRoom(player)
    if player.Character then
        if player.Character.Humanoid.Health > 0 then
            if ProfileInterface.Profiles[player] then
                local profile = ProfileInterface.Profiles[player]

                if profile.TempData.RoomOwned ~= nil then
                    local room = profile.TempData.RoomOwned

                    local PrimaryPart = room.Self:FindFirstChild("PrimaryPart")

                    local newCFrame = CFrame.new((PrimaryPart.CFrame).Position)

                    player.Character:SetPrimaryPartCFrame(newCFrame)
                end
            end
        end
    end
end

function RoomService.Client:LockRoom(player, toggle)
    if player.Character then
        if player.Character.Humanoid.Health > 0 then
            if ProfileInterface.Profiles[player] then
                local profile = ProfileInterface.Profiles[player]

                if profile.TempData.RoomOwned ~= nil then
                    local room = profile.TempData.RoomOwned
                    room.Locked = toggle
                    room.Self:SetAttribute("Locked", toggle)
                end
            end
        end
    end
end

function RoomService.Client:BanUser(player, UserID)
    if ProfileInterface.Profiles[player] then
        local Profile = ProfileInterface.Profiles[player]
        local PlayerExists = false

        for _, _Player in pairs(game.Players:GetPlayers()) do
            if _Player.UserId == UserID then
                PlayerExists = true
            end
        end

        if PlayerExists then
            if table.find(Profile.Data.Roomsettings.BannedUsers, UserID) == nil then
                table.insert(Profile.Data.Roomsettings.BannedUsers, UserID)
                player:SetAttribute("BannedUsers", HttpService:JSONEncode(Profile.Data.Roomsettings.BannedUsers))
            else --Unban User if they are already banned
                local UserIndex = table.find(Profile.Data.Roomsettings.BannedUsers, UserID)
                table.remove(Profile.Data.Roomsettings.BannedUsers, UserIndex)
                player:SetAttribute("BannedUsers", HttpService:JSONEncode(Profile.Data.Roomsettings.BannedUsers))
            end
        end
    end
end

function RoomService.Client:WhitelistUser(player, UserID)
    if ProfileInterface.Profiles[player] then
        local Profile = ProfileInterface.Profiles[player]
        local PlayerExists = false

        for _, _Player in pairs(game.Players:GetPlayers()) do
            if _Player.UserId == UserID then
                PlayerExists = true
            end
        end

        if PlayerExists then
            if table.find(Profile.Data.Roomsettings.WhitelistedUsers, UserID) == nil then
                table.insert(Profile.Data.Roomsettings.WhitelistedUsers, UserID)
                player:SetAttribute("WhitelistedUsers", HttpService:JSONEncode(Profile.Data.Roomsettings.WhitelistedUsers))
            else --Unban User if they are already banned
                local UserIndex = table.find(Profile.Data.Roomsettings.WhitelistedUsers, UserID)
                table.remove(Profile.Data.Roomsettings.WhitelistedUsers, UserIndex)
                player:SetAttribute("WhitelistedUsers", HttpService:JSONEncode(Profile.Data.Roomsettings.WhitelistedUsers))
            end
        end
    end
end


function RoomService:KnitStart()
    ProfileInterface = Knit.GetService("ProfileInterface")
    Rooms = game.Workspace:WaitForChild("Rooms"):GetChildren()


    for i, room in pairs(Rooms) do
        RoomService.Rooms[room] = {}
        
        RoomService.Rooms[room].Claimed = false
        RoomService.Rooms[room].Locked = false
        RoomService.Rooms[room].Owner = nil
        RoomService.Rooms[room].RoomID = i
        RoomService.Rooms[room].Self = room


        room:SetAttribute("Claimed", false)
        room:SetAttribute("Locked", false)
        room:SetAttribute("Owner", "Nobody")
        room:SetAttribute("RoomID", i)
    end

    game.Players.PlayerRemoving:connect(function(player)
        for _, room in pairs(self.Rooms) do
            if room.Owner == player then
                -- reset room looks

                room.Claimed = false
                room.Locked = false
                room.Owner = nil
        
                room.Self:SetAttribute("Claimed", false)
                room.Self:SetAttribute("Locked", false)
                room.Self:SetAttribute("Owner", "Nobody")
            end
        end
    end)

    RunService.Stepped:connect(function ()
        for _, room in pairs(self.Rooms) do
            local RoomPrimaryPart = room.Self.PrimaryPart
            local roomOwner = room.Owner

            if roomOwner then
                local success, error = pcall(function() -- The player may leave mid call, so pcall this >_<
                    local ownerProfile = ProfileInterface.Profiles[roomOwner]

                    if ownerProfile then
                        local ownerRoomSettings = ProfileInterface.Profiles[roomOwner].Data.Roomsettings
    
                        for _, Part in pairs(workspace:GetPartsInPart(RoomPrimaryPart)) do
                            if game.Players:GetPlayerFromCharacter(Part.Parent) ~= nil then
                                local PlayerInRoom = game.Players:GetPlayerFromCharacter(Part.Parent)
                                local Char = PlayerInRoom.Character
    
                                if PlayerInRoom ~= roomOwner then
                                    if room.Locked then
                                        if not table.find(ownerRoomSettings.WhitelistedUsers, PlayerInRoom.UserId) then
                                            local newCFrame = CFrame.new((RoomPrimaryPart.CFrame * CFrame.new(0, 0 ,17)).Position)
                                            Char:SetPrimaryPartCFrame(newCFrame)
                                        end
                                    elseif not room.Locked then
                                        if table.find(ownerRoomSettings.BannedUsers, PlayerInRoom.UserId) then
                                            local newCFrame = CFrame.new((RoomPrimaryPart.CFrame * CFrame.new(0, 0 ,17)).Position)
                                            Char:SetPrimaryPartCFrame(newCFrame)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end

        end
    end)
end








return RoomService