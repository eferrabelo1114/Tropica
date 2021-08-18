-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

-- Private Variables
local Knit = require(ReplicatedStorage.Knit)
local ProfileInterface = Knit.GetService("ProfileInterface")

local timeObj
-- Create Nametag Service
local ServerTimeService = Knit.CreateService{
	Name = "ServerTimeService";
	Client = {};
}

-- Public Variables
ServerTimeService.CurrentTime = "";


function ServerTimeService:GetCurrentTime()
    local totalMinutes = game.Lighting:GetMinutesAfterMidnight()
    local hours = math.floor(totalMinutes / 60)
    local minutes = math.floor(totalMinutes % 60)
    local period
    
    if hours < 12 then
        period = "AM"
    else
        period = "PM"
        hours -= 12
    end
    
    if hours == 0 then
        hours = 12
    end
    
    return string.format("%02d:%02d %s", hours, minutes, period)
end

function ServerTimeService:StartTime()
    local minutesAfterMidnight = 0

    local Time = Instance.new("Smoke")
    Time.Parent = ReplicatedStorage
    Time.Name = "Server_Time"

    while true do
        minutesAfterMidnight = minutesAfterMidnight + 1
     
        local minutesNormalised = minutesAfterMidnight % (60 * 24)
        local seconds = minutesNormalised * 60
        local hours = string.format("%02.f", math.floor(seconds/3600))
        local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
        local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60))
        local timeString = hours..":"..mins..":"..secs
     
        Lighting.TimeOfDay = timeString

        ServerTimeService.CurrentTime = self:GetCurrentTime()
        Time:SetAttribute("Time", self:GetCurrentTime())
        wait(1)
    end
end

function ServerTimeService:KnitStart()
    coroutine.resume(coroutine.create(function ()
        self:StartTime()
    end))
end

return ServerTimeService