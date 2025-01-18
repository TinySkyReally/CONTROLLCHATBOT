loadstring(game:HttpGet("https://raw.githubusercontent.com/TinySkyReally/CONTROLLCHATBOT/refs/heads/main/Version.lua"))()

local version = "0.0.35"
local Latest

local Hotkey = "."
local Whitelist = {}
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

local function sendCommandList()
    local commands = "Available Commands: hotkey [key] - Change the hotkey for commands, say [message] - Make the bot say something in chat, jump - Make the character jump, bring - Teleports bot to you"
    local secondcommands = "whitelist [player] - Add a player to the whitelist, whitelist all - Add all players to the whitelist, blacklist [player] - Remove a player from the whitelist, sit - Makes player sit"
    local thirdcommands = "blacklist all - Clear the entire whitelist, reset - Reset the player's position, walkto [player] - Make the character walk to a player, cmds - Show the list of available commands"
    local fourthcommands = "random [minnumber] [maxnumber] - Sends random number"
    
    sendMessage(commands)
    sendMessage(secondcommands)
    sendMessage(thirdcommands)
    sendMessage(fourthcommands)
end

local function onMessageReceived(message, sender)
    if sender ~= LocalPlayer then
        if not table.find(Whitelist, sender.Name) then
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
        sendMessage("[Tiny Control Bot]: "..table.concat(Words, " "))
    elseif Command == "jump" then
        humanoid.Jump = true
    elseif Command == "whitelist" then
        if sender ~= LocalPlayer then return end
        if Words[2] == "all" then
            for _, player in ipairs(Players:GetPlayers()) do
                if not table.find(Whitelist, string.lower(player.Name)) then
                    table.insert(Whitelist, string.lower(player.Name))
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if not table.find(Whitelist, string.lower(player.Name)) and player.Name == string.lower(Words[2]) then
                    table.insert(Whitelist, string.lower(player.Name))
                end
            end
        end
    elseif Command == "blacklist" then
        if sender ~= LocalPlayer then return end
        if Words[2] == "all" then
            Whitelist = {}
        else
            if table.find(Whitelist, string.lower(Words[2])) then
                table.remove(Whitelist, getIndexOfItem(Whitelist, string.lower(Words[2])))
            end
        end
    elseif Command == "reset" then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(0, -70, 0)
        end
    elseif Command == "walkto" then
        local TargetPlayer = string.lower(Words[2])
        for _, player in ipairs(Players:GetPlayers()) do
            if string.lower(player.Name) == TargetPlayer then
                WalkToPart(player.Character.HumanoidRootPart)
            end
        end
    elseif Command == "cmds" then
        sendCommandList()
    elseif Command == "bring" then
        character.HumanoidRootPart.CFrame = CFrame.new(sender.Character.HumanoidRootPart.Position)
    elseif Command == "sit" then
        humanoid.Sit = true
    elseif Command == "random" then
        sendMessage("[Tiny Control Bot]: "..math.random(tonumber(Words[2]), tonumber(Words[3])))
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

sendMessage("[Tiny Control Bot]: Chat bot loaded into game!")
if Latest then
    sendMessage("[Tiny Control Bot]: Version: "..version.." Latest!")
else
    sendMessage("[Tiny Control Bot]: Version: "..version.." Outdated!")
end
