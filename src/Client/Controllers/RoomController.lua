-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
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
local MainUI;
local ChangeRoomsPage;
local TeleportToRoomPage;

local janitor = Janitor.new()
local teleportPageJanitor = Janitor.new()

local Camera = workspace.CurrentCamera

local PossibleRooms = {}

local RoomIndex;
local RoomLookingAt;

local player = game.Players.LocalPlayer;

local ChoseClaim;

-- Create UIController Controller:
local RoomController = Knit.CreateController {
	Name = "RoomController";
}


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
            else
                ChoseClaim = false
                print("Unable to claim room!")
            end
        end)
    )
end


function RoomController:Open()
    if player:GetAttribute("RoomOwned") == 0 then
        UIController:ToggleShowHotbar(true)
        UIController:ToggleShowSidebuttons(true)

        
        ChangeRoomsPage["Self"].Visible = true

        self:Enable()
    else
        print("Already owns room. Display room UI.")
    end
end

function RoomController:Close()
    janitor:Cleanup()

    Camera.CameraType = Enum.CameraType.Custom

    UIController:ToggleShowHotbar(false)
    UIController:ToggleShowSidebuttons(false)

    
    ChangeRoomsPage["Self"].Visible = false
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


end




return RoomController