local Commands = {"hello", "help", "start"}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

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
    if sender and sender == LocalPlayer then
        return -- Ignore messages from the local player
    end
    
    local firstWord = string.match(message, "^(%S+)")
    if firstWord and table.find(Commands, string.lower(firstWord)) then
        sendMessage("Hi")
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

sendMessage("CHAT BOT LOADED IN GAME!")
