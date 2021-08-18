-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

-- Private Variables
local Knit = require(ReplicatedStorage.Knit)

local ProfileInterface = Knit.GetService("ProfileInterface")

local PlayerGui;

-- Create Nametag Service
local NametagService = Knit.CreateService{
	Name = "NametagService";
	Client = {};
}


-- Functions




local function getTextObject(message, fromPlayerId)
	local textObject
	local success, errorMessage = pcall(function()
		textObject = TextService:FilterStringAsync(message, fromPlayerId)
	end)
	if success then
		return textObject
	elseif errorMessage then
		print("Error generating TextFilterResult:", errorMessage)
	end
	return false
end

function NametagService:CheckColor(color)
    local ColorFrame = PlayerGui.Pages.Customization.Main.Colors

    local colorExits = false
    for _, colorButton in pairs(ColorFrame:GetChildren()) do
        if colorButton:IsA("ImageButton") then
            local buttonColor = Color3.fromRGB(colorButton.BackgroundColor3.R * 255, colorButton.BackgroundColor3.G * 255, colorButton.BackgroundColor3.B * 255)

            if buttonColor == color then
                colorExits = true
                return colorExits
            end
        end
    end

    return colorExits
end

function NametagService:FilterText(textToFilter, playerUserID)
    local textObject = getTextObject(textToFilter, playerUserID)

	local filteredMessage
	local success, errorMessage = pcall(function()
		filteredMessage = textObject:GetNonChatStringForBroadcastAsync()
	end)
	if success then
		return filteredMessage
	elseif errorMessage then
		print("Error filtering message:", errorMessage)
	end
	return false
end


function NametagService.Client:ChangeNametag(player, text, textColor, textBorderColor)
    if ProfileInterface.Profiles[player] then
        local profile = ProfileInterface.Profiles[player]
        local newNametagText =  NametagService:FilterText(text, player.UserId)


        if NametagService:CheckColor(textColor) and NametagService:CheckColor(textBorderColor) then
            profile:UpdateNametag(newNametagText, textColor, textBorderColor)
        else
            warn(player.Name.." sent an invalid color through the system. Possibly exploiting.")
        end
    end
end

function NametagService:KnitStart()
    PlayerGui = ReplicatedStorage:FindFirstChild("MainGui")
    



end








return NametagService