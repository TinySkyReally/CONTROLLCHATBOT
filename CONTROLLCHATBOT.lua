local Commands = {"hello", "help", "start"}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("CHAT BOT LOADED IN GAME!", "All")

local function onMessageReceived(message, sender)
    if sender == LocalPlayer then
        return -- Ignore messages from the local player
    end
    
    local firstWord = string.match(message, "^(%S+)") -- Extract the first word
    if firstWord and table.find(Commands, string.lower(firstWord)) then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Hi", "All")
    end
end

local function onPlayerChatted(player)
    player.Chatted:Connect(function(message)
        onMessageReceived(message, player)
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    onPlayerChatted(player)
end

Players.PlayerAdded:Connect(onPlayerChatted)
