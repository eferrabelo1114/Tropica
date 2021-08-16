local SoundLibrary = {}

--Variables
local Debris = game:GetService("Debris")
local Sounds = game:GetService("ReplicatedStorage"):FindFirstChild("Sounds")

function SoundLibrary:PlaySound(SoundName, PlayLocation)
    local sound = Sounds:FindFirstChild(SoundName)
    if sound then
        local b = sound:Clone()
        b.Parent = PlayLocation
        b:Play()
        Debris:AddItem(b, 7)
    end
end




return SoundLibrary