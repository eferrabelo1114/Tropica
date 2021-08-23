-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

-- Private Variables
local Knit = require(ReplicatedStorage.Knit)

local ProfileInterface;
local Rooms;

-- Create Nametag Service
local RoomService = Knit.CreateService{
	Name = "RoomService";
	Client = {};
}


-- Functions



function RoomService:FindRoomByID(RoomID)
    local Room

    for _,roomInTable in pairs(Rooms) do
        if roomInTable:GetAttribute("RoomID") == RoomID then
            Room = roomInTable
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
                if room:GetAttribute("Claimed") == false then
                    profile.TempData.RoomOwned = room
                    room:SetAttribute("Claimed", true)
                    room:SetAttribute("Owner", player.Name)

                    player:SetAttribute("RoomOwned", RoomID)

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

                    local floor = room:FindFirstChild("Floor")

                    local newCFrame = CFrame.new((floor.CFrame * CFrame.new(0, 1, 0)).Position)

                    player.Character:SetPrimaryPartCFrame(newCFrame)
                end
            end
        end
    end
end


function RoomService:KnitStart()
    ProfileInterface = Knit.GetService("ProfileInterface")
    Rooms = game.Workspace:WaitForChild("Rooms"):GetChildren()


    for i, room in pairs(Rooms) do
        room:SetAttribute("Claimed", false)
        room:SetAttribute("Owner", "Nobody")
        room:SetAttribute("RoomID", i)
    end


end








return RoomService