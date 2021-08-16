--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.Knit)

Knit.AddControllers(script.Parent:WaitForChild("Controllers"))

Knit.Start():Catch(warn)
