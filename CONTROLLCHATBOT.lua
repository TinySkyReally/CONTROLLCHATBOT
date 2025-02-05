loadstring(game:HttpGet("https://raw.githubusercontent.com/TinySkyReally/CONTROLLCHATBOT/refs/heads/main/Version.lua"))()

local version = "0.0.49"
local Latest

local TeleportService = game:GetService("TeleportService")
local Name = "Tiny Control Bot"
local Hotkey = "."
local Whitelist = {"wakemeup"}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

print("Your version: "..version)
if LatestVersion == version then
    Latest = true
    print("Latest")
else
    Latest = false
    print("Outdated")
end

local function rejoinGame()
    local placeId = game.PlaceId
    local serverId = game.JobId
    TeleportService:TeleportToPlaceInstance(placeId, serverId, LocalPlayer)
end

local function WalkToPart(targetPart)
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:MoveTo(targetPart.Position)
        end
    end
end

local function getIndexOfItem(list, value)
    for i, v in ipairs(list) do
        if v == value then
            return i  -- Return the index if item is found
        end
    end
    return nil  -- Return nil if item is not found
end

local function splitL(message)
    local words = {}
    for word in string.gmatch(message, "%S+") do
        table.insert(words, word)
    end
    return words
end

local function sendMessage(text)
    if TextChatService:FindFirstChild("TextChannels") then
        local generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if generalChannel then
            generalChannel:SendAsync(text)
        else
            warn("RBXGeneral chat channel not found!")
        end
    elseif ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then
        local chatEvent = ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
        if chatEvent then
            chatEvent:FireServer(text, "All")
        else
            warn("SayMessageRequest not found!")
        end
    else
        warn("No supported chat system found!")
    end
end

local function sendCommandList(pick)
    local controlCommands = "Control Character Commands: jump - Make the character jump, sit - Makes player sit, reset - Reset the player's position, walkto [player] - Make the character walk to a player, bring - Teleports bot to you, rotate [degree] - sets rotation, emote [emote] - uses emote, jumppower [JumpPower] - changes bots jump power, speed [Number] - changes bots speed"
    local chatCommands = "Chat Commands: hotkey [key] - Change the hotkey for commands, say [message] - Make the bot say something in chat, cmds - Show the list of available commands"
    local whitelistCommands = "Whitelist Commands: whitelist [player] - Add a player to the whitelist, whitelist all - Add all players to the whitelist, blacklist [player] - Remove a player from the whitelist, blacklist all - Clear the entire whitelist"
    local utilityCommands = "Utility Commands: random [minnumber] [maxnumber] - Sends random number, name [Name] - renames bot, rejoin - rejoins bot"

    local commands = {
        control = controlCommands,
        chat = chatCommands,
        whitelist = whitelistCommands,
        utility = utilityCommands,
    }

    if commands[pick] then
        local message = commands[pick]
        while #message > 200 do
            local chunk = message:sub(1, 200)
            sendMessage(chunk)
            message = message:sub(201)
        end
        sendMessage(message)
    else
        sendMessage("["..Name.."]: pick control, chat, whitelist, utility.")
        sendMessage("["..Name.."]: say .cmds [Your choice]")
    end
end


local function onMessageReceived(message, sender)
    if sender ~= LocalPlayer and not table.find(Whitelist, string.lower(sender.Name)) then
        if not table.find(Whitelist, string.lower(sender.DisplayName)) then
            return
        end
    end

    if not (string.sub(message, 1, 1) == Hotkey) then
        return
    end

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    local Words = splitL(message)
    Command = string.sub(Words[1], 2)
    if Command == "hotkey" then
        Hotkey = Words[2]
    elseif Command == "say" then
        table.remove(Words, 1)
        sendMessage("["..Name.."]: "..table.concat(Words, " "))
    elseif Command == "jump" then
        humanoid.Jump = true
    elseif Command == "whitelist" then
        if sender ~= LocalPlayer then return end
        if Words[2] == "all" then
            for _, player in ipairs(Players:GetPlayers()) do
                if player and player.Name then
                    table.insert(Whitelist, string.lower(player.Name))
                else
                    warn("Invalid player detected while adding to whitelist.")
                end
            end
            print("Whitelist:", table.concat(Whitelist, ", "))
        else
            table.insert(Whitelist, string.lower(Words[2]))
            print("Whitelist:", table.concat(Whitelist, ", "))
        end
    elseif Command == "blacklist" then
        if sender ~= LocalPlayer then return end
        if Words[2] == "all" then
            Whitelist = {}
        else
            table.remove(Whitelist, getIndexOfItem(Whitelist, string.lower(Words[2])))
        end
    elseif Command == "reset" then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(0, -70, 0)
        end
    elseif Command == "walkto" then
        local TargetPlayer = string.lower(Words[2])
        for _, player in ipairs(Players:GetPlayers()) do
            if string.lower(player.Name) == TargetPlayer or string.lower(player.DisplayName) == TargetPlayer then
                WalkToPart(player.Character.HumanoidRootPart)
            end
        end
    elseif Command == "cmds" then
        sendCommandList(Words[2])
    elseif Command == "bring" then
        character.HumanoidRootPart.CFrame = CFrame.new(sender.Character.HumanoidRootPart.Position)
    elseif Command == "sit" then
        humanoid.Sit = true
    elseif Command == "random" then
        sendMessage("["..Name.."]: "..math.random(tonumber(Words[2]), tonumber(Words[3])))
    elseif Command == "rotate" then
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local targetRotation = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, math.rad(Words[2]), 0)
        humanoidRootPart.CFrame = targetRotation
    elseif Command == "emote" then
        sendMessage("/e "..Words[2])
    elseif Command == "name" then
        table.remove(Words, 1)
        Name = table.concat(Words, " ")
    elseif Command == "rejoin" then
        rejoinGame()
    elseif Command == "speed" then
        humanoid.WalkSpeed = Words[2]
    elseif Command == "jumppower" then
        humanoid.JumpPower = Words[2]
    end
end

if TextChatService:FindFirstChild("TextChannels") then
    local generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    if generalChannel then
        generalChannel.MessageReceived:Connect(function(textChatMessage)
            local message = textChatMessage.Text
            local sender = Players:GetPlayerByUserId(textChatMessage.TextSource.UserId)
            onMessageReceived(message, sender)
        end)
    else
        warn("RBXGeneral chat channel not found!")
    end
elseif ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then
    for _, player in pairs(Players:GetPlayers()) do
        player.Chatted:Connect(function(message)
            onMessageReceived(message, player)
        end)
    end
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(message)
            onMessageReceived(message, player)
        end)
    end)
else
    warn("No chat system detected!")
end

sendMessage("["..Name.."]: Chat bot loaded into game!")
if Latest then
    sendMessage("["..Name.."]: Version: "..version.." Latest!")
else
    sendMessage("["..Name.."]: Version: "..version.." Outdated!")
end
sendMessage("["..Name.."]: Use .cmds")
