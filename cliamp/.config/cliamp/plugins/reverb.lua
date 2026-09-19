-- reverb: horizontal LED-matrix visualizer rendered with Braille,
-- inspired by vintage HiFi "Reverberation Graphic" displays.
-- Layout: 10 frequency bands drawn as vertical bars that grow symmetrically
-- up AND down from a center line. Band 1 (subbass) sits in the middle;
-- higher bands fan outward to both sides (mirrored left/right). The result
-- is a quad-symmetric pattern that pulses outward with the music.

local p = plugin.register({
    name = "reverb",
    type = "visualizer",
})

local ESC = string.char(27)
local RESET = ESC .. "[0m"
-- Use ANSI 16-color SGR codes (30-37 / 90-97) so the terminal theme
-- (Omarchy, etc.) drives the actual RGB values. 256-color slots would
-- be hardcoded and ignore the theme.
local function sgr(n) return ESC .. "[" .. n .. "m" end

-- Intensity ramp, low -> high. Matches the classic VU/LED-meter
-- palette used by the sibling plugins (led-burst, block-burst):
-- bright green -> green -> bright yellow -> bright red, all driven by
-- the terminal's ANSI 16-color theme.
local LEVEL_RAMP = { sgr(92), sgr(32), sgr(93), sgr(91) }

-- Bar width scales with the panel (computed in render). MIN_GAP is the
-- smallest gap in dots between adjacent bars; bars grow until they'd
-- collide with this gap. MAX_BAR_WIDTH caps growth on very wide panels
-- so bars don't blob into solid blocks.
local MIN_GAP       = 1
local MAX_BAR_WIDTH = 10
-- Vertical dot spacing for the LED-matrix look. 1 = solid line, 2 = LEDs.
local DOT_STEP  = 2

local NUM_BANDS = 10
local bandEnergy = {}

function p:init()
    bandEnergy = {}
end

local BRAILLE_BIT = {
    { 1, 8 },
    { 2, 16 },
    { 4, 32 },
    { 64, 128 },
}

local function brailleChar(dots)
    local low = dots % 64
    local high = math.floor(dots / 64) % 4
    return string.char(0xE2, 0xA0 + high, 0x80 + low)
end

function p:render(bands, frame, rows, cols)
    if rows < 4 or cols < 11 then return "" end

    for i = 1, NUM_BANDS do
        local raw = bands[i] or 0
        local prev = bandEnergy[i] or 0
        if raw > prev then
            bandEnergy[i] = raw
        else
            bandEnergy[i] = math.max(raw, prev - 0.05)
        end
    end

    local dotW = 2 * cols
    local dotH = 4 * rows
    local centerX = math.floor(dotW / 2)
    -- Snap centerX to an even dot position (= char-cell boundary) so
    -- mirrored bars on both sides land on identical cell alignments.
    if centerX % 2 == 1 then centerX = centerX - 1 end
    local centerY = math.floor(dotH / 2)

    -- Bar spacing in dots. Aim to fit (NUM_BANDS - 1) bars on each side
    -- inside the available width, with a small margin from the edges.
    local availHalf = centerX - 2
    local spacing = math.floor(availHalf / (NUM_BANDS - 1))
    -- Snap spacing to an even number of dots so every band's xPos
    -- shares parity, otherwise odd spacing alternates each bar's
    -- cell alignment and they render at different widths (1|2|2|...).
    if spacing % 2 == 1 then spacing = spacing - 1 end
    if spacing < 2 then spacing = 2 end
    -- Bar width: even number of dots (= whole char cells), ~50% of
    -- spacing, capped by MAX_BAR_WIDTH.
    local BAR_WIDTH = math.max(2, math.min(MAX_BAR_WIDTH, math.floor(spacing / 2)))
    if BAR_WIDTH % 2 == 1 then BAR_WIDTH = BAR_WIDTH - 1 end
    if BAR_WIDTH < 2 then BAR_WIDTH = 2 end
    local minSpacing = BAR_WIDTH + MIN_GAP
    if minSpacing % 2 == 1 then minSpacing = minSpacing + 1 end
    if spacing < minSpacing then spacing = minSpacing end

    -- Leave one char cell of headroom (4 dots) above and below the
    -- center line so peak-level bars don't slam into the panel edges
    -- or cliamp's separator line below.
    local maxHalfH = math.max(2, centerY - 4)

    local grid = {}
    for y = 0, dotH - 1 do
        local row = {}
        for x = 0, dotW - 1 do
            row[x] = 0
        end
        grid[y] = row
    end

    local function plot(x, y, idx)
        if x < 0 or x >= dotW or y < 0 or y >= dotH then return end
        if idx > grid[y][x] then
            grid[y][x] = idx
        end
    end

    -- Draw a vertical bar BAR_WIDTH dots wide, centered at xPos,
    -- extending halfH dots above and below centerY.
    local function drawBar(xPos, halfH, idx)
        if halfH < 0 then halfH = 0 end
        local x0 = xPos - math.floor(BAR_WIDTH / 2)
        -- Snap x0 to an even dot position (= char-cell boundary) so
        -- the bar fills exactly BAR_WIDTH/2 whole cells, regardless of
        -- whether floor(BAR_WIDTH/2) itself is odd.
        if x0 % 2 == 1 then x0 = x0 + 1 end
        for dx = 0, BAR_WIDTH - 1 do
            local x = x0 + dx
            plot(x, centerY, idx)
            for d = DOT_STEP, halfH, DOT_STEP do
                plot(x, centerY - d, idx)
                plot(x, centerY + d, idx)
            end
            -- Add a tip dot only when the bar is shorter than one
            -- DOT_STEP, so very quiet bars still show as more than a
            -- single center dot. For taller bars the DOT_STEP loop
            -- already covers the ends; adding a separate tip would
            -- place a dot adjacent to the last stepped one, fusing
            -- into a fully-filled char cell at the bar's end.
            if halfH > 0 and halfH < DOT_STEP then
                plot(x, centerY - halfH, idx)
                plot(x, centerY + halfH, idx)
            end
        end
    end

    for i = 1, NUM_BANDS do
        local e = bandEnergy[i] or 0
        -- Position-based attenuation: inner bands (low i) keep their
        -- full mapped height, outer bands are damped so even a flat or
        -- treble-poor spectrum still renders as a centered burst
        -- with inner bars clearly taller than outer ones.
        local positionFactor = 1.0 - 0.65 * (i - 1) / (NUM_BANDS - 1)
        local halfH = math.floor(e * maxHalfH * positionFactor + 0.5)
        local idx = math.floor(e * (#LEVEL_RAMP - 1) + 0.5) + 1
        if idx < 1 then idx = 1 end
        if idx > #LEVEL_RAMP then idx = #LEVEL_RAMP end

        if i == 1 then
            drawBar(centerX, halfH, idx)
        else
            local offset = (i - 1) * spacing
            drawBar(centerX - offset, halfH, idx)
            drawBar(centerX + offset, halfH, idx)
        end
    end

    local lines = {}
    local sentinel = {}  -- unique table value so the first cell always flushes
    for row = 0, rows - 1 do
        local parts = {}
        local runColor = sentinel
        local runChars = {}
        local function flush()
            if #runChars == 0 then return end
            if runColor then
                parts[#parts+1] = runColor .. table.concat(runChars) .. RESET
            else
                parts[#parts+1] = table.concat(runChars)
            end
            runChars = {}
        end
        for col = 0, cols - 1 do
            local dots = 0
            local maxIdx = 0
            for dr = 0, 3 do
                for dc = 0, 1 do
                    local y = row * 4 + dr
                    local x = col * 2 + dc
                    local idx = grid[y][x]
                    if idx > 0 then
                        dots = dots + BRAILLE_BIT[dr + 1][dc + 1]
                        if idx > maxIdx then maxIdx = idx end
                    end
                end
            end
            local color = (maxIdx > 0) and LEVEL_RAMP[maxIdx] or nil
            if color ~= runColor then
                flush()
                runColor = color
            end
            if dots == 0 then
                runChars[#runChars+1] = " "
            else
                runChars[#runChars+1] = brailleChar(dots)
            end
        end
        flush()
        lines[row + 1] = table.concat(parts)
    end

    return table.concat(lines, "\n")
end
