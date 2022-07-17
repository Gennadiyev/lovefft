# LÖVE FFT (LOVE FFT)

![love2d>11.0](https://img.shields.io/badge/L%C3%96VE-%3E11.0-yellowgreen)

This is a simple FFT module for audio visualizer, rhythm games, and all your other needs against FFT. It is powered by [Lua FFT](https://github.com/h4rm/luafft).

> Attribution is appreciated but not required.

![showcase.gif](https://s2.loli.net/2022/07/17/uyfUXFL7VOvW8c1.gif)

## Usage

First require the module and prepare your audio path.
    
```lua
local loveFFT = require("lovefft")
local audioPath = "audio.mp3"
local audio = love.audio.newSource(audioPath, "static")
```

Then set up parameters and use it to initialize LÖVE FFT.

```lua
local fftSize = 1024
local fftArray = {}

loveFFT:init(fftSize) -- Initialize LOVE FFT with fftSize
loveFFT:setSoundData(audioPath) -- Set the audio path
```

Play the audio wherever you'd like. LÖVE FFT only takes care of the playback position.

```lua
audio:play()
```

Preferred in `love.update`, tell LÖVE FFT the playback position. This function should be called in every update, or every time you want to update the FFT output.

```lua
loveFFT:updatePlayTime(audio:tell()) -- Update playback position
```

Good! You're done. Now enjoy the FFT output wherever you'd like!

```lua
function love.draw()
    fftArray = loveFFT:get() -- This operation takes almost no time
    local barWidth = W / fftSize * 8 -- We only take care of the lowest 1/8 of the frequencies because it is where most energy resides
    for i = 1, fftSize / 8 do
        local barHeight = fftArray[i] * H -- H is window height
        love.graphics.rectangle("fill", (i - 1) * barWidth, H - barHeight, barWidth, barHeight)
    end
    love.graphics.print(tostring(love.timer.getFPS()), 0, 0)
end
```

[Full example](lovefft.lua)

## Functions

(In order of importance)

- `loveFFT:init(fftSize)`: Initializes the module and gives the number of samples to be used to calculate FFT, must be a power of 2. A good starting point is 1024.
- `loveFFT:setSoundData(soundDataOrPath)`: Sets the sound data to be used for FFT. You can either pass a [SoundData](https://love2d.org/wiki/SoundData) object or a path to an audio file.
- `loveFFT:updatePlayTime(time)`: Syncs with audio playback position and starts an FFT computation in a separate thread.
- `loveFFT:push()`: Immediately launches a new FFT computation in a separate thread using `self.playPosition`. Set `self.playPosition` with `loveFFT:updatePlayPosition(time)` or `loveFFT:setPlayPosition(time)`.
- `loveFFT:get()`: Gets the current result of FFT computation. This function promises a non-blocking call and always yields a valid array.
- `loveFFT:setPlayPosition(time)`: Set the audio playback position but does not start an FFT computation.
- `loveFFT:setFFTSize(fftSize)`: Dynamically changes the FFT size. This is not recommended.
- `loveFFT:getFFTSize()`: Gets the current FFT size.
- `loveFFT:getFFTArray()`: Gets the current FFT array.
- `loveFFT:getSoundData()`: Gets the current sound data.
- `loveFFT:getPlayPosition()`: *Why do you need this? Getting playback position from the Audio object is better.*
- `loveFFT:release()`: Releases the thread and the channels. According to LÖVE documentation, this is necessary on Android platforms. *But based on my personal experience, it is always unnecessary to call this function.*

---

- Alias: `loveFFT:tell()` = `loveFFT:getPlayPosition()`
- Alias: `loveFFT:destroy()` = `loveFFT:release()`
- Alias: `loveFFT:pop()` = `loveFFT:get()`

## Notes

- This is a threaded FFT module, so there is no `fftResult = loveFFT.fftImmediately(array)`. Bear in mind that FFT is a very time-consuming operation and should usually not be used in game development unless for special needs.
- Based on my personal test, use `fftSize=2048` on laptops with fast CPU (12th Gen Intel CPU), and `fftSize=512` or `fftSize=1024` on low-end devices and mobile devices. **Higher FFT size will not block the main thread, but you will see a lag and low update frequency in FFT output.**
- Poor maths? No worries, no complex value is used in this module! The complex results are post-processed using `abs()`.
- If you have a special project structure that does not use `libs` to place certain libraries, or if you do not want to see `lovefft.lua` and `ffthread.lua` in root directory, you may need to modify require paths accordingly:
  - `libs/luafft.lua` requires `libs/complex.lua` in line 26.
  - `ffthread.lua` requires `libs/luafft.lua` in line 2.
  - `lovefft.lua` requires `libs/ffthread.lua` in line 15 and line 23.
- Because the project uses `Thread:release()`, which is [a feature introduced in LÖVE 11.0](https://love2d.org/wiki/Thread), LÖVE FFT supports LÖVE 11.0 and is tested against 11.0, 11.3 and 11.4.
