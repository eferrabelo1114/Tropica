--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Knit = require(ReplicatedStorage.Knit)

local Player = game.Players.LocalPlayer

Knit.AddControllers(script.Parent:WaitForChild("Controllers"))

Knit.Start():Catch(warn)
