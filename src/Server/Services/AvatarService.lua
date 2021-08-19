-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

-- Private Variables
local Knit = require(ReplicatedStorage.Knit)

local ProfileInterface = Knit.GetService("ProfileInterface")

-- Create Nametag Service
local AvatarService = Knit.CreateService{
	Name = "AvatarService";
	Client = {};
}


-- Functions


local Avatar = {
    ["Shirt"] = 0000;
    ["Pants"] = 0000;
    ["Scale"] = 0;
    ["Hair"] = 0000;
    ["Accesories"] = {};
}





return AvatarService