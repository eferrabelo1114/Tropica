-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RoomService;

local Knit = require(ReplicatedStorage.Knit)
local Tween = require(Knit.Util.Tween)
local Janitor = require(Knit.Util.Janitor)

-- Controllers
local ClientInput;
local UIController;

local InputType;
local InputFunctions;

-- Private Variables
local UI_Parts = ReplicatedStorage.UI_Parts

local MainUI;
local ChangeRoomsPage;
local TeleportToRoomPage;
local CustomizeRoomPage;
local PlayerListPage;
local ColorsPage;


local janitor = Janitor.new()
local teleportPageJanitor = Janitor.new()
local playerListJanitor = Janitor.new()
local colorsJanitor = Janitor.new()

local Camera = workspace.CurrentCamera

local PossibleRooms = {}

local RoomIndex;
local RoomLookingAt;

local player = game.Players.LocalPlayer;

local PlayerButtonTemplate = UI_Parts.Player_Button

local ChoseClaim;
local PlayerRoom;

-- Create UIController Controller:
local RoomController = Knit.CreateController {
	Name = "RoomController";
}


-- Other Functions
function RoomController:FindRoomByID(RoomID)
    for _, Room in pairs(game.Workspace.Rooms:GetChildren()) do
        if Room:GetAttribute("RoomID") == RoomID then
            return Room
        end
    end

    return nil
end

-- Room Colors
function RoomController:OpenColorPage(objectChangingColor)
    colorsJanitor:Cleanup()

    





end


-- Room Banning Stuff
function RoomController:OpenBanPage()
    playerListJanitor:Cleanup()

    local LocalPlayerBannedUsers = HttpService:JSONDecode(player:GetAttribute("BannedUsers"))

    local function makeButton(PlayerButton, Player_)            
        if table.find(LocalPlayerBannedUsers, Player_.UserId) then
            PlayerButton.MainButton.Text.Text = "Unban Player"
            PlayerButton.MainButton.ImageColor3 = Color3.fromRGB(255, 47, 47)
        else
            PlayerButton.MainButton.Text.Text = "Ban Player"
            PlayerButton.MainButton.ImageColor3 = Color3.fromRGB(119, 243, 140)
        end

        playerListJanitor:Add(PlayerButton.MainButton.MouseButton1Click:connect(function ()
            RoomService:BanUser(Player_.UserId)
        end))

        playerListJanitor:Add(player:GetAttributeChangedSignal("BannedUsers"):Connect(function()
            local BannedUsers = HttpService:JSONDecode(player:GetAttribute("BannedUsers"))
        
            if table.find(BannedUsers, Player_.UserId) then
                PlayerButton.MainButton.Text.Text = "Unban Player"
                PlayerButton.MainButton.ImageColor3 = Color3.fromRGB(255, 47, 47)
            else
                PlayerButton.MainButton.Text.Text = "Ban Player"
                PlayerButton.MainButton.ImageColor3 = Color3.fromRGB(119, 243, 140)
            end
        end))

        -- Bind Text Button
        PlayerButton.Parent = PlayerListPage.Main.Scroll

        playerListJanitor:Add(PlayerButton)
    end


    -- Load player list menu
    for _, Player_ in pairs(game.Players:GetPlayers()) do
        if Player_ ~= player then
            local Icon = game.Players:GetUserThumbnailAsync(Player_.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
            local IsPlayerFriend = player:IsFriendsWith(Player_.UserId)
            
            local PlayerButton = PlayerButtonTemplate:Clone()

            PlayerButton.Player_Icon.Image = Icon
            PlayerButton.PlayerName.Text = Player_.Name
            PlayerButton.Friend.Visible = IsPlayerFriend

            makeButton(PlayerButton, Player_)      
        end
    end

    --Check if a new player joins
    playerListJanitor:Add(game.Players.PlayerAdded:connect(function(Player_)
        local Icon = game.Players:GetUserThumbnailAsync(Player_.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
            local IsPlayerFriend = player:IsFriendsWith(Player_.UserId)
            
            local PlayerButton = PlayerButtonTemplate:Clone()

            PlayerButton.Player_Icon.Image = Icon
            PlayerButton.PlayerName.Text = Player_.Name
            PlayerButton.Friend.Visible = IsPlayerFriend

            makeButton(PlayerButton, Player_)   
    end))

    playerListJanitor:Add(PlayerListPage.Main.Close.MouseButton1Click:connect(function ()
        PlayerListPage["Self"].Visible = false
        playerListJanitor:Cleanup()
    end))

    
    PlayerListPage.Main.Scroll.CanvasSize = UDim2.new(0, 0, 0, PlayerListPage.Main.Scroll.UIGridLayout.AbsoluteContentSize.Y)
    PlayerListPage["Self"].Visible = true
end

-- Room Whitelisting Stuff
function RoomController:OpenWhitelistPage()
    playerListJanitor:Cleanup()

    local LocalPlayerWhitelistedPlayers = HttpService:JSONDecode(player:GetAttribute("WhitelistedUsers"))

    local function makeButton(PlayerButton, Player_)            
        if table.find(LocalPlayerWhitelistedPlayers, Player_.UserId) then
            PlayerButton.MainButton.Text.Text = "Unwhitelist Player"
            PlayerButton.MainButton.ImageColor3 = Color3.fromRGB(255, 47, 47)
        else
            PlayerButton.MainButton.Text.Text = "Whitelist Player"
            PlayerButton.MainButton.ImageColor3 = Color3.fromRGB(119, 243, 140)
        end

        playerListJanitor:Add(PlayerButton.MainButton.MouseButton1Click:connect(function ()
            RoomService:WhitelistUser(Player_.UserId)
        end))

        playerListJanitor:Add(player:GetAttributeChangedSignal("WhitelistedUsers"):Connect(function()
            local WhitelistUsers = HttpService:JSONDecode(player:GetAttribute("WhitelistedUsers"))
        
            if table.find(WhitelistUsers, Player_.UserId) then
                PlayerButton.MainButton.Text.Text = "Unwhitelist Player"
                PlayerButton.MainButton.ImageColor3 = Color3.fromRGB(255, 47, 47)
            else
                PlayerButton.MainButton.Text.Text = "Whitelist Player"
                PlayerButton.MainButton.ImageColor3 = Color3.fromRGB(119, 243, 140)
            end
        end))

        -- Bind Text Button
        PlayerButton.Parent = PlayerListPage.Main.Scroll

        playerListJanitor:Add(PlayerButton)
    end


    -- Load player list menu
    for _, Player_ in pairs(game.Players:GetPlayers()) do
        if Player_ ~= player then
            local Icon = game.Players:GetUserThumbnailAsync(Player_.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            local IsPlayerFriend = player:IsFriendsWith(Player_.UserId)
            
            local PlayerButton = PlayerButtonTemplate:Clone()

            PlayerButton.Player_Icon.Image = Icon
            PlayerButton.PlayerName.Text = Player_.Name
            PlayerButton.Friend.Visible = IsPlayerFriend

            makeButton(PlayerButton, Player_)      
        end
    end

    --Check if a new player joins
    playerListJanitor:Add(game.Players.PlayerAdded:connect(function(Player_)
        local Icon = game.Players:GetUserThumbnailAsync(Player_.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            local IsPlayerFriend = player:IsFriendsWith(Player_.UserId)
            
            local PlayerButton = PlayerButtonTemplate:Clone()

            PlayerButton.Player_Icon.Image = Icon
            PlayerButton.PlayerName.Text = Player_.Name
            PlayerButton.Friend.Visible = IsPlayerFriend

            makeButton(PlayerButton, Player_)   
    end))

    playerListJanitor:Add(PlayerListPage.Main.Close.MouseButton1Click:connect(function ()
        PlayerListPage["Self"].Visible = false
        playerListJanitor:Cleanup()
    end))

    
    PlayerListPage.Main.Scroll.CanvasSize = UDim2.new(0, 0, 0, PlayerListPage.Main.Scroll.UIGridLayout.AbsoluteContentSize.Y)
    PlayerListPage["Self"].Visible = true
end

-- Room Claiming Functions
function RoomController:DisplayTeleportPage()
    
    local function close()
        teleportPageJanitor:Cleanup()
        TeleportToRoomPage["Self"].Visible = false
    end

    teleportPageJanitor:Add(
        TeleportToRoomPage.Yes.MouseButton1Click:connect(function()
            RoomService:RequestTeleportToRoom()
            close()
        end)
    )

    teleportPageJanitor:Add(
        TeleportToRoomPage.No.MouseButton1Click:connect(function()
            close()
        end)
    )

    TeleportToRoomPage["Self"].Visible = true
end

function RoomController:UpdateCamera()
    RoomLookingAt = PossibleRooms[RoomIndex]

    local newCframe = CFrame.new((RoomLookingAt.CameraPart.CFrame * CFrame.new(0, 5, 10)).Position, RoomLookingAt.CameraPart.Position)
    Tween(Camera, {"CFrame"}, {newCframe})
end

function RoomController:InitializeRoomUpdater()
    local Rooms = workspace:FindFirstChild("Rooms"):GetChildren()

    for _, Room in pairs(Rooms) do
        if Room:GetAttribute("Claimed") == false then
            table.insert(PossibleRooms, Room)
        end

        janitor:Add(
            Room:GetAttributeChangedSignal("Claimed"):connect(function ()
                if Room:GetAttribute("Claimed") == true then
                    if not ChoseClaim then
                        local i = table.find(PossibleRooms, Room)
                        table.remove(PossibleRooms, i)

                        if RoomLookingAt == Room then
                            self:UpdateCamera()
                        end
                    end
                elseif Room:GetAttribute("Claimed") == false then
                    table.insert(PossibleRooms, Room)
                end
            end)
        )
    end

    RoomIndex = 1
    RoomLookingAt = PossibleRooms[RoomIndex]

    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = CFrame.new((RoomLookingAt.CameraPart.CFrame * CFrame.new(0, 5, 10)).Position, RoomLookingAt.CameraPart.Position)
end

function RoomController:Enable()
    self:InitializeRoomUpdater()
    
    janitor:Add(
        ChangeRoomsPage.NextRoom.MouseButton1Click:connect(function()
            RoomIndex = RoomIndex + 1

            if RoomIndex > #PossibleRooms  then
                RoomIndex = 1
            end
            
            self:UpdateCamera()
        end)
    )

    janitor:Add(
        ChangeRoomsPage.PreviousRoom.MouseButton1Click:connect(function()
            RoomIndex = RoomIndex - 1

            if RoomIndex < 1  then
                RoomIndex = #PossibleRooms
            end
            
           self:UpdateCamera()
        end)
    )


    janitor:Add(
        ChangeRoomsPage.PickRoom.MouseButton1Click:connect(function()
            ChoseClaim = true
            local Claimed = RoomService:ClaimRoom(RoomLookingAt:GetAttribute("RoomID"))

            if Claimed then
                self:DisplayTeleportPage()
                self:Close()

                PlayerRoom = RoomController:FindRoomByID(player:GetAttribute("RoomOwned"))
            else
                ChoseClaim = false
                print("Unable to claim room!")
            end
        end)
    )
end

-- Room Cusotmizing Functions
function RoomController:EnableCustomizationMenu()
    local CloseButton = CustomizeRoomPage.BG.Main.Close

    local LockButton = CustomizeRoomPage.BG.Main.Lock
    local BanPlayerButton = CustomizeRoomPage.BG.Main.Ban
    local WhitelistPlayerButton = CustomizeRoomPage.BG.Main.Allow

    local RoomLocked = PlayerRoom:GetAttribute("Locked")

    if RoomLocked == true then
        LockButton.Text.Text = "Unlock Room"
    elseif not RoomLocked then
        LockButton.Text.Text = "Lock Room"
    end

    janitor:Add(
        CloseButton.MouseButton1Click:connect(function ()
            local a = Tween(CustomizeRoomPage["Self"], {"Position"}, {UDim2.new(0.5, 0, 0.8, 0)})
            a.Completed:Wait()
            self:Close()
        end)
    )

    janitor:Add(
        LockButton.MouseButton1Click:connect(function ()
            RoomService:LockRoom(not RoomLocked)

            RoomLocked = PlayerRoom:GetAttribute("Locked")
            if RoomLocked == true then
                LockButton.Text.Text = "Unlock Room"
            elseif not RoomLocked then
                LockButton.Text.Text = "Lock Room"
            end
        end)
    )

    janitor:Add(
        BanPlayerButton.MouseButton1Click:connect(function ()
            self:OpenBanPage()
        end)
    )

    janitor:Add(
        WhitelistPlayerButton.MouseButton1Click:connect(function ()
            self:OpenWhitelistPage()
        end)
    )


    CustomizeRoomPage["Self"].Position = UDim2.new(0.5, 0, 0.8, 0)
    CustomizeRoomPage["Self"].Visible = true
    Tween(CustomizeRoomPage["Self"], {"Position"}, {UDim2.new(0.5, 0, 0.54, 0)})
end

-- Main Functions
function RoomController:Open()
    if player:GetAttribute("RoomOwned") == 0 then -- Fix This
        UIController:ToggleShowHotbar(true)
        UIController:ToggleShowSidebuttons(true)

        
        ChangeRoomsPage["Self"].Visible = true

        self:Enable()
    else
        self:EnableCustomizationMenu()
    end
end

function RoomController:Close()
    janitor:Cleanup()
    playerListJanitor:Cleanup()

    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = player.Character

    UIController:ToggleShowHotbar(false)
    UIController:ToggleShowSidebuttons(false)

    
    ChangeRoomsPage["Self"].Visible = false
    CustomizeRoomPage["Self"].Visible = false
    PlayerListPage["Self"].Visible = false

    UIController.UI_Open = nil
end


function RoomController:LoadInteraction()
    ClientInput = Knit.GetController("InputController")

    InputType  = ClientInput.InputType
    InputFunctions = ClientInput.InputFunctions




    -- Check if player input ever changes to reload UI to take in the new input
    ClientInput.UserChangedInput:Connect(function()
       
    end)


    
end

function RoomController:Initialize(UI)
    UIController = Knit.GetController("UIController")
    RoomService = Knit.GetService("RoomService")
    
    MainUI = UI;
    ChangeRoomsPage = MainUI.Pages.Change_Rooms
    TeleportToRoomPage = MainUI.Pages.TeleportToRoom
    CustomizeRoomPage = MainUI.Pages.Customize_Room
    PlayerListPage = MainUI.Pages.Player_List
    ColorsPage = MainUI.Pages.Colors

    CustomizeRoomPage.Visible = false
    TeleportToRoomPage.Visible = false
    ChangeRoomsPage.Visible = false
end




return RoomController