local Hotkey = "."
local Whitelist = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

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

local function onMessageReceived(message, sender)
    if sender ~= LocalPlayer and not table.find(Whitelist, sender.Name) then
        return
    end
    print(string.sub(message, 1, 1))
    if not (string.sub(message, 1, 1) == Hotkey) then
        return
    end
    
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
        if playerName == "all" then
            for _, player in ipairs(Players:GetPlayers()) do
                if not table.find(Whitelist, player.Name) then
                    table.insert(Whitelist, player.Name)
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if not table.find(Whitelist, player.Name) and player.Name == string.lower(Words[2]) then
                    table.insert(Whitelist, player.Name)
                end
            end
        end
    elseif Command == "blacklist" then
        if Words[2] == "all" then
            Whitelist = {}
        else
            if table.find(Whitelist, string.lower(Words[2])) then
                table.remove(Whitelist, getIndexOfItem(Whitelist, string.lower(Words[2])))
            end
        end
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

sendMessage("[Tiny Control Bot]: CHAT BOT LOADED IN GAME!")
