--Services
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Knit = require(ReplicatedStorage.Knit)

local Player = game.Players.LocalPlayer

Knit.AddControllers(script.Parent:WaitForChild("Controllers"))


ContentProvider:PreloadAsync(ReplicatedStorage.Sounds:GetChildren())
ContentProvider:PreloadAsync(ReplicatedStorage.Animations:GetChildren())
ContentProvider:PreloadAsync(ReplicatedStorage.Textures:GetChildren())


Knit.Start():Catch(warn)
