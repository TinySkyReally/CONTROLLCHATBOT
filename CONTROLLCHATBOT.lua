local Commands = {"hello", "help", "start"} -- List of commands to check for
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

-- Function to send messages to the chat
local function sendMessage(text)
    TextChatService.TextChannels.RBXGeneral:SendAsync(text)
end

-- Function to check messages
local function onMessageReceived(textChatMessage)
    local sender = textChatMessage.TextSource
    if sender and sender.UserId == LocalPlayer.UserId then
        return -- Ignore messages from the local player
    end

    local message = textChatMessage.Text
    local firstWord = string.match(message, "^(%S+)") -- Extract the first word
    if firstWord and table.find(Commands, string.lower(firstWord)) then
        sendMessage("Hi") -- Respond with "Hi"
    end
end

-- Listen to chat messages in the general channel
local generalChannel = TextChatService:FindFirstChild("RBXGeneral")
if generalChannel then
    generalChannel.MessageReceived:Connect(onMessageReceived)
else
    warn("Default chat channel 'RBXGeneral' not found! Ensure TextChatService is enabled.")
end

-- Notify when the script is loaded
sendMessage("CHAT BOT LOADED IN GAME!")
