local loveFFT = require("lovefft")
local audioPath = "audio.mp3"
local audio = love.audio.newSource(audioPath, "static")

local fftSize = 1024
local fftArray = {}

loveFFT:init(fftSize)
loveFFT:setSoundData(audioPath)

function love.resize()
    W, H = love.graphics.getDimensions()
end
love.resize()

function love.draw()
    local barWidth = W / fftSize * 8
    for i = 1, fftSize/8 do
        local barHeight = fftArray[i] * H
        love.graphics.rectangle("fill", (i - 1) * barWidth, H - barHeight, barWidth, barHeight)
    end
    love.graphics.print(tostring(love.timer.getFPS()), 0, 0)
end

function love.update(dt)
    if not(audio:isPlaying()) then
        audio:play()
    end
    local time = audio:tell()
    loveFFT:updatePlayTime(time)
    fftArray = loveFFT:get()
end
