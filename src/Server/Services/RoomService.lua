-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

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
                if room.Self:GetAttribute("Claimed") == false then
                    profile.TempData.RoomOwned = room

                    room.Claimed = true
                    room.Locked = profile.Data.Roomsettings.Locked
                    room.Owner = player

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
                end
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

        room.PrimaryPart.Touched:connect(function()end) -- Create touch interest

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
                local success, response = pcall(function()
                    local ownerProfile = ProfileInterface.Profiles[roomOwner]

                    if ownerProfile then
                        local ownerRoomSettings = ProfileInterface.Profiles[roomOwner].Data.Roomsettings
    
                        for _, Part in pairs(RoomPrimaryPart:GetTouchingParts()) do
                            if game.Players:GetPlayerFromCharacter(Part.Parent) ~= nil then
                                local PlayerInRoom = game.Players:GetPlayerFromCharacter(Part.Parent)
                                local Char = PlayerInRoom.Character
    
                                if room.Locked then
                                    if PlayerInRoom ~= roomOwner then
                                        
                                        if not table.find(ownerRoomSettings.AllowedUsers, PlayerInRoom) then
                                            
                                            local newCFrame = CFrame.new((RoomPrimaryPart.CFrame * CFrame.new(-3, 0 ,0)).Position)
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