local Commands = {"hello", "help", "start"} -- List of commands to check for
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Check if DefaultChatSystemChatEvents exists
local ChatEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
if not ChatEvent or not ChatEvent:FindFirstChild("SayMessageRequest") then
    warn("Chat system events not found! Ensure your game uses the default chat system.")
    return
end

-- Function to send messages
local function sendMessage(text)
    ChatEvent.SayMessageRequest:FireServer(text, "All")
end

-- Function to check messages
local function onMessageReceived(message, sender)
    if sender == LocalPlayer then
        return -- Ignore messages from the local player
    end
    
    local firstWord = string.match(message, "^(%S+)") -- Extract the first word
    if firstWord and table.find(Commands, string.lower(firstWord)) then
        sendMessage("Hi") -- Respond with "Hi"
    end
end

-- Listen to chat messages
local function onPlayerChatted(player)
    player.Chatted:Connect(function(message)
        onMessageReceived(message, player)
    end)
end

-- Connect to existing players
for _, player in pairs(Players:GetPlayers()) do
    onPlayerChatted(player)
end

-- Listen for new players joining
Players.PlayerAdded:Connect(onPlayerChatted)

-- Notify when the script is loaded
sendMessage("CHAT BOT LOADED IN GAME!")
