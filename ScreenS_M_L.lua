local enable_background_image = true
local background_image = loadImage("assets.prod.novaquark.com/102348/718b6805-93cb-4310-b271-0b20907b05c0.png")
theme_color = true --set to false to use below colors 
imageRed = 1 --background image red channel
imageGreen = 1 --background image green channel
imageBlue = 1 --background image blue channel
imageTrans = 1 --background image transparency


local cursor_image = loadImage("assets.prod.novaquark.com/102348/a6ad4ff3-372f-46f6-8e2c-86aa0c54f3a3.png")
local json = require('json')
layer = createLayer()
frontlayer = createLayer()
cursorlayer = createLayer()
cursorlayer2 = createLayer()
inactive_layer = createLayer()

local input = getInput()
if input ~= "" then
    values = {}
    for word in string.gmatch(input, "([^,]+)") do
        table.insert(values, word:match("^%s*(.-)%s*$"))
    end
end

if getInput():len() > 0 then
    aggstate = values[1]
    aggtarget = tonumber(values[2])
    active = values[3]
    Preset_1 = tonumber(values[4])
    Preset_2 = tonumber(values[5]) 
    Preset_3 = tonumber(values[6])
    Preset_4 = tonumber(values[7])
    
    RGBr = values[8]
    RGBg = values[9]
    RGBb = values[10]
    aggbase = tonumber(values[11])
    traveltime = values[12]
    maxAGGheight = values[13]
    currentAlt = values[14]
    atmoheight = tonumber(values[15]) -- 10% atmo
    
    Preset_5 = tonumber(values[16])
    Preset_6 = tonumber(values[17]) 
    Preset_7 = tonumber(values[18])
    Preset_8 = tonumber(values[19])
    atmoheight_0 = values[20]
else  --fallback values--
    aggstate = 0
    aggtarget = 1000
    active = false
    Preset_1 = 0
    Preset_2 = 0  
    Preset_3 = 0
    Preset_4 = 0
    RGBr = 1
    RGBg = 1
    RGBb = 1
    aggbase = 0
    traveltime = 1
    maxAGGheight = 200000
    currentAlt = 2000
    atmoheight = 3600
    Preset_5 = 0
    Preset_6 = 0  
    Preset_7 = 0
    Preset_8 = 0
end

color = {r=RGBr,g=RGBg,b=RGBb}
color1 = {r=1,g=1,b=1} -- text color
setBackgroundColor (color.r/6,color.g/6,color.b/6)

config_altitude_min = 1000
config_altitude_max = maxAGGheight
config_altitude_steps = {
    -- { start, altitude }
    { 0.00, config_altitude_min },
    { 0.70, config_altitude_max*0.25 },
    { 0.85, config_altitude_max*0.5 },
    { 1.00, config_altitude_max },
}   

rx, ry = getResolution()
cx, cy = getCursor() 

if enable_background_image == true then
    if theme_color == true then
    setNextFillColor(layer, color.r, color.g, color.b, 0.05) --Background Image colour and Transparency
        else 
    setNextFillColor(layer, imageRed, imageGreen, imageBlue, imageTrans) end
 -- setNextFillColor(layer, 1, 1, 1, 1) --Use this for an normal colour Background Image!
    addImage(layer, background_image, 0, 0, rx, ry)
end

--fonts--
font_big = loadFont('Oxanium-Bold',40)
font_small = loadFont('Oxanium',20)
font_tiny = loadFont('Oxanium-Light',14)
----------------------------------------------------------
------------------ FUNCTIONS -----------------------------
----------------------------------------------------------
--Cursor setup--
function drawCursor ()
    if cx < 0 then return end
    setNextFillColor(cursorlayer,  0.45, 0.45, 0.45, 1)
    addTriangle(cursorlayer,cx+1,cy+3, cx+4,cy+27, cx+17,cy+22)
    addImage(cursorlayer2,cursor_image,cx-5.5,cy-2,32,32) 
    if getCursorDown() then
       setNextFillColor(cursorlayer,color.r,color.g,color.b, 1)
       addTriangle(cursorlayer,cx+1,cy+3, cx+3,cy+24, cx+18,cy+19)
       setNextFillColor(cursorlayer, 0.45, 0.45, 0.45, 1)
       addTriangle(cursorlayer,cx+5,cy+12, cx+7,cy+24, cx+13,cy+22)
    end
end
--boundary check--
function isCursorIn(x1,y1,x2,y2)
    local cx,cy = getCursor()
    if cx >= x1 and cx <= x2 and cy >= y1 and cy <= y2 then
       return true 
    else 
        return false 
    end
end
--
function get_pretty_distance(meters)
    meters = tonumber(meters)
    if meters > (atmoheight or 3600) then
        return ('%.1fkm'):format(meters / 1000)
    end
    return ('%.0fm'):format(meters)
end

function set_altitude(value)
    slider_altitude:setValue(value)
    setOutput(
        json.encode({ 'manualAlt', value })
    )
end

function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

--local mx, my = getCursor()

function VerticalGauge(Data,X,Y,SX,SY,n,r,g,b)
    local Height = math.ceil(Data/(100/n))

    for jj = 1,Height,1 do
        -- inside bar
        setNextStrokeColor(layer,r,g,b,0.2+(jj^3)*(0.8/(Height^3)))
        setNextStrokeWidth(layer,0.1)
        setNextFillColor(layer,r,g,b,0.2+(jj^3)*(0.8/(Height^3)))
        addQuad(layer,
            X - SX/2,
            Y+SY/2 - (jj-1)*SY/n - SY/n*0.1,
            X - SX/2,
            Y+SY/2 - (jj-1)*SY/n - SY/n*0.6,
            X - 1,
            Y+SY/2 - (jj-1)*SY/n - SY/n*1.1,
            X - 1,
            Y+SY/2 - (jj-1)*SY/n - SY/n*0.6)
        setNextStrokeColor(layer,r,g,b,0.2+(jj^3)*(0.8/(Height^3)))
        setNextStrokeWidth(layer,0.1)
        setNextFillColor(layer,r,g,b,0.2+(jj^3)*(0.8/(Height^3)))
        addQuad(layer,
            X,
            Y+SY/2 - (jj-1)*SY/n - SY/n*1.1,
            X,
            Y+SY/2 - (jj-1)*SY/n - SY/n*0.6,
            X + SX/2,
            Y+SY/2 - (jj-1)*SY/n - SY/n*0.1,
            X + SX/2,
            Y+SY/2 - (jj-1)*SY/n - SY/n*0.6)
    end
end

--# Slider class definition called only at the first frame
if not Slider then

    Slider = {}
    Slider.__index = Slider
    -- Slider object constructor
    -- .x : X component of the position
    -- .y : Y component of the position
    -- .width : Width of the slider
    -- .length : Lenght of the slider
    -- .min : Minimum value
    -- .max : Maximum value
    -- .label : Associated text label
    function Slider:new(x, y, width, length, min, max, value, label, steps)
        local self = {
            x = x or 0,
            y = y or 0,
            l = length or 100,
            w = width or 20,
            min = tonumber(min or 1000),
            max = tonumber(max or 20000),
            ratio = 0,
            label = label or "",
            drag = false,
            color = {1,1,1}
        }

        steps = steps or { { 0, self.min } }

        -- Gets the correct ratio considering our steps
        function self:getRatioForValue(value)
            local ratio = math.max(0, math.min(1, (value or self.min)/(self.max-self.min)))
            for _, step in pairs(steps) do
                local step_next = steps[_ + 1] or { 1.0, self.max }
                local step_min, step_max = tonumber(step[2]), tonumber(step_next[2])
                if value >= step_min 
                and value < step_max then
                    ratio = step[1] + ((value - step_min) / (step_max - step_min)) * (step_next[1] - step[1])
                elseif value < step_min then
                    break
                end
            end
            return ratio
        end
        self.ratio = self:getRatioForValue(value or self.min)

        -- Gets the Y position of a value
        function self:getYForValue(value)
		        --logMessage("value2="..tostring(tonumber(value)))
            return self.y + (1 - self:getRatioForValue(tonumber(value))) * self.l
        end

        -- Set the value of the slider
        function self:setValue(val)
            if type(val) == 'number' then
                self.value = math.max(self.min, math.min(self.max, val))
				--logMessage("value3="..tostring(val))
                self.ratio = self:getRatioForValue(val)
            end
        end
        -- Get the value of the slider
        function self:getValue(val)
            local min, max = self.min, self.max
            local ratio = self.ratio
            for _, step in pairs(steps) do
                local step_next = steps[_ + 1] or { 1.0, self.max }
                local step_min, step_max = step[1], step_next[1]
                if self.ratio >= step_min and self.ratio < step_max then
                    min = step[2]
                    max = step_next[2]
                    ratio = (self.ratio - step_min) / (step_max - step_min)
                elseif self.ratio < step_min then
                    break
                end
            end
            return ratio*(max - min) + min
        end
        -- Draws the slider on the screen using the given layer
        function self:draw(layer)

            -- Localize object data
            local x, y, w, l = self.x, self.y, self.w, self.l
            local min, max, ratio = self.min, self.max


            -- Get cursor data (position and button state)
            local mx, my = getCursor()
            local pressed = getCursorPressed()
            local released = getCursorReleased()

            -- Determine if the cursor is on the bar and detect if the mouse is down
            if (mx >= x and mx <= x+w) and (my >= y and my <= y+l) then

                if pressed then self.drag = true end
            end

            if mx < 0 and self.drag == true then 
                self.drag = false
                released = true
                set_altitude(alt)
            end

            -- Set the ratio based on the cursor position
            if self.drag then
                self.ratio = math.max(0, math.min(1, 1 - (my-y)/l))
                if released then
                    self.drag = false
                    set_altitude(alt)
                end
            end
            dragging = self.drag
            --logMessage("dragging="..tostring(dragging).." self.drag="..tostring(self.drag))

            -- Compute the slider ratio
            local ratio = self.ratio
            --local h = ratio*(max-min)
            local color = self.color
            --# Draw the slider
            -- Define box default strokes style
            setDefaultStrokeColor(layer, Shape_BoxRounded, color[1], color[2], color[3], 1)
            setDefaultStrokeWidth(layer, Shape_BoxRounded, 0.1)

            -- Draw the back box
            setNextFillColor(layer, 0.1, 0.1, 0.1, 1)
            addBoxRounded(layer, x, y, w, l, 0)

            -- Draw the fill box
            --setNextFillColor(layer, color[1], color[2], color[3], 1)
            --addBoxRounded(layer, x+5, y+(1-ratio)*l, w-10, l*ratio, 0)
            pData = (ratio*l)-15
            pX = x+w/2
            pY = y+l-55
            pSX = w-10
            pSY = 100--l-offset
            pn = 5
            pr = RGBr
            pg = RGBg
            pb = RGBb
            VerticalGauge(pData,pX,pY,pSX,pSY,pn,pr,pg,pb)

            -- Draw the handle
            setNextFillColor(frontlayer, 0.5, 0.5, 0.5, 1)
            setDefaultStrokeColor(frontlayer,Shape_BoxRounded,color[1], color[2], color[3], 1)
            setDefaultStrokeWidth(frontlayer,Shape_BoxRounded,0.1)
            addBoxRounded(frontlayer, x-3, y+(1-ratio)*l -3, w+6, 6, 0)
            setNextFillColor(layer, 0.5, 0.5, 0.5, 1)
            addTriangle(layer, x-8, y+(1-ratio)*l,     x-20, y+(1-ratio)*l -8,        x-20,y+(1-ratio)*l +8)-- left bar Triangle
            setNextFillColor(layer, 0.5, 0.5, 0.5, 1)
            addTriangle(layer, x+w+8, y+(1-ratio)*l,     x+w+20, y+(1-ratio)*l -8,        x+w+20,y+(1-ratio)*l +8)-- right bar Triangle

            -- Draw the gravity well
            local well_y_min, well_y_max = self:getYForValue(math.max(self.min, aggbase - 100)), self:getYForValue(math.min(aggbase + 100, self.max))
            setDefaultShadow(frontlayer,Shape_Line, 15, 2, 2, 2, 0.1)
            addLine(frontlayer, x + w + 6, well_y_max, x + w + 12, well_y_max)
            addLine(frontlayer, x + w + 12, well_y_min, x + w + 12, well_y_max)
            addLine(frontlayer, x + w + 6, well_y_min, x + w + 12, well_y_min)
            addLine(frontlayer, x - 6, well_y_max, x - 12, well_y_max)
            addLine(frontlayer, x - 12, well_y_min, x - 12, well_y_max)
            addLine(frontlayer, x - 6, well_y_min, x - 12, well_y_min)

            -- Draw Atmosphere 10%

            if atmoheight then
                local atmo_y = self:getYForValue(atmoheight)
                setDefaultStrokeColor(layer,Shape_Line,0, 0.4, 1, 1)
                addLine(layer, x + w + 6, atmo_y, x + w + 25, atmo_y)
                setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                addText(layer, font_tiny, '10% ATMO', x + w + 36, atmo_y)

                addLine(layer, x - 6, atmo_y, x - 25, atmo_y)
                setNextTextAlign(layer, AlignH_Right, AlignV_Middle)
                addText(layer, font_tiny, '10% ATMO', x - 33, atmo_y)
            end
            -- Draw Atmosphere 0%
            if atmoheight then
                local atmo0_y = self:getYForValue(atmoheight_0)
                 setDefaultStrokeColor(layer,Shape_Line,0, 0.4, 1, 1)
                addLine(layer, x + w + 6, atmo0_y, x + w + 25, atmo0_y)
                setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                addText(layer, font_tiny, '0% ATMO', x + w + 36, atmo0_y)

                addLine(layer, x - 6, atmo0_y, x - 25, atmo0_y)
                setNextTextAlign(layer, AlignH_Right, AlignV_Middle)
                addText(layer, font_tiny, '0% ATMO', x - 36, atmo0_y)
            end
            
            -- ship height marker
           -- currentAlt = values[14]
            if tonumber(currentAlt) >= self.min and tonumber(currentAlt) <= self.max then
                setDefaultStrokeColor(frontlayer,Shape_BoxRounded,2,2,2, 1)
                setDefaultStrokeWidth(frontlayer,Shape_BoxRounded,0.1)
                setNextFillColor(frontlayer,color[1], color[2], color[3], 1)
                addBoxRounded(frontlayer, x + 12, self:getYForValue(currentAlt), w - 24, 6, 0) -- ship marker must include the ratio in the vertical position. based on currentheight.                        -- AGG gravity well position
            end

            for _, step in pairs(steps) do
                if steps[_ - 1] and steps[_ + 1] then
                    local altitude = step[2]
                    local bar_y = self:getYForValue(altitude)
                    setNextStrokeColor(layer, color[1], color[2], color[3], 1)
                    setNextFillColor(layer, color[1], color[2], color[3], 0)
                    setNextStrokeWidth(layer, 1)
                    setNextFillColor(layer, 2, 0.5, 0.5, 1)
                    addBoxRounded(layer, x, bar_y, w, 0, 0)

                    setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                    addText(layer, font_tiny, get_pretty_distance(altitude), x + w + 36, bar_y)

                    setNextTextAlign(layer, AlignH_Right, AlignV_Middle)
                    addText(layer, font_tiny, get_pretty_distance(altitude), x - 36, bar_y)
                end
            end
 
            -- Draw label and value display
            local label = self.label
            setDefaultTextAlign( layer, AlignH_Center, AlignV_Middle)
            addText( layer, font_tiny, label, x+0.5*w+100, y)
            addText( layer, font_tiny, label, x+0.5*w-100, y)
            addText( layer, font_tiny, get_pretty_distance(1000), x+0.5*w, y+l+18)
            
            local display = string.format('%.0f', self:getValue())
            addText( layer, font_big, ""..display.."m", x-270, y+265)
            -- altitude Bar Box            
            setNextStrokeColor(layer,color1.r, color1.g, color1.b, 1)
            setNextFillColor(layer,color1.r/8, color1.g/8, color1.b/8, 1)
            setNextStrokeWidth(layer,1)
            addBoxRounded(layer, rx/2-430,ry/2-75,240,100,8)
            
        end


        return setmetatable(self, Slider)
    end

end
------------------ INIT -----------------------------
if active == "false" then
    message = "START THE PROGRAMMING BOARD TO USE"
    local wfont = loadFont('Play-Bold', 40)
    local sx, sy = getTextBounds(wfont, message)
    setNextFillColor(inactive_layer,color.r/5,color.g/5,color.b/5, 0.8)
    addBox(inactive_layer,0,0,rx,ry)
    setNextShadow(inactive_layer, 64, color.r, color.g, color.b, 0.4)
    setNextFillColor(inactive_layer,color.r,color.g,color.b, 0.8)
    setNextStrokeColor(inactive_layer,color1.r, color1.g, color1.b, 1)
    setNextStrokeWidth(inactive_layer,2)
    addBoxRounded(inactive_layer,(rx-sx-16)/2, (ry-sy-16)/2, sx+16, sy+16, 8)
    setNextTextAlign(inactive_layer, AlignH_Center, AlignV_Middle)
    addText(inactive_layer,wfont,message,rx/2,ry/2)
else
    requestAnimationFrame(1)
    --# Initialization called only at the first frame
    --logMessage("dragging="..tostring(dragging))
    if not dragging then
        local h = aggtarget  -- this is the inital value at the start, must be the agg target height coming from the board.     
        slider_altitude = Slider:new(rx/2-35, ry*0.025, 70, ry* 0.92, config_altitude_min, config_altitude_max, h, get_pretty_distance(config_altitude_max), config_altitude_steps)
        slider_altitude.color = {color.r,color.g,color.b}

        _init = true
    end
    --------------------------------------------------------------
    slider_altitude:draw( layer)
    alt = slider_altitude:getValue()
    drawCursor()
end

---- Touch Box setup ----
box1 = {x1=rx/2+200,y1=ry/2-75,x2=220,y2=100}
box11 = {x1=rx/2+220,y1=ry/2+80,x2=190,y2=55}
box2 = {x1=rx/2-460,y1=ry/2+175,x2=130,y2=50}
box3 = {x1=rx/2-290,y1=ry/2+175,x2=130,y2=50}
box4 = {x1=rx/2-460,y1=ry/2+245,x2=130,y2=50}
box5 = {x1=rx/2-290,y1=ry/2+245,x2=130,y2=50}

box6 = {x1=rx/2+170,y1=ry/2+175,x2=130,y2=50}
box7 = {x1=rx/2+330,y1=ry/2+175,x2=130,y2=50}
box8 = {x1=rx/2+170,y1=ry/2+245,x2=130,y2=50}
box9 = {x1=rx/2+330,y1=ry/2+245,x2=130,y2=50}
setDefaultStrokeColor(frontlayer,Shape_BoxRounded,color1.r, color1.g, color1.b, 1)
setDefaultFillColor(frontlayer,Shape_BoxRounded,color1.r/9, color1.g/9, color1.b/9, 1)
setDefaultStrokeWidth(frontlayer,Shape_BoxRounded,1)
setDefaultTextAlign(frontlayer, AlignH_Center, AlignV_Middle)
--box1--
addBoxRounded(frontlayer, box1.x1,box1.y1,box1.x2,box1.y2,8)
if aggstate == "0" then
        setNextFillColor(frontlayer,1,0, 0, 1)
        addText(frontlayer,font_big,"OFFLINE",box1.x1+(box1.x2/2),box1.y1+(box1.y2/2))
        else
        setNextFillColor(frontlayer,0,1, 0, 1)
        addText(frontlayer,font_big,"ONLINE",box1.x1+(box1.x2/2),box1.y1+(box1.y2/2))
        end
--box11--
setNextFillColor(frontlayer,0.1, 0.1, 0.1, 1)
addBoxRounded(frontlayer, box11.x1,box11.y1,box11.x2,box11.y2,4)
if aggstate == "0" then
        setNextFillColor(frontlayer,0,1, 0, 1)
        addText(frontlayer,font_small,"ACTIVATE",box11.x1+(box11.x2/2),box11.y1+(box11.y2/2))
        else
        setNextFillColor(frontlayer,1,0, 0, 1)
        addText(frontlayer,font_small,"DEACTIVATE",box11.x1+(box11.x2/2),box11.y1+(box11.y2/2))
        end
if isCursorIn(box11.x1,box11.y1,box11.x1+box11.x2,box11.y1+box1.y2) then
setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
    if  getCursorDown() then
        setNextFillColor(frontlayer,0.1, 0.1, 0.1, 1)
if getCursorPressed() then setOutput(json.encode({'1'})) end 
        else
setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
end
    setNextShadow(frontlayer, 32, color.r, color.g, color.b, 0.4)
    addBoxRounded(frontlayer, box11.x1,box11.y1,box11.x2,box11.y2,4)
end  
--box2--
   addBoxRounded(frontlayer, box2.x1,box2.y1,box2.x2,box2.y2,4)
   addText(frontlayer,font_small,""..Preset_1.."m",box2.x1+(box2.x2/2),box2.y1+(box2.y2/2))
if isCursorIn(box2.x1,box2.y1,box2.x1+box2.x2,box2.y1+box2.y2) then
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
if getCursorDown() then
   setNextFillColor(frontlayer,0.1, 0.1, 0.1, 1)
if getCursorPressed() then set_altitude(Preset_1) end 
   else
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
end
   setNextShadow(frontlayer, 32, color.r, color.g, color.b, 0.4)
   addBoxRounded(frontlayer, box2.x1,box2.y1,box2.x2,box2.y2,4)
end
--box3--
   addBoxRounded(frontlayer, box3.x1,box3.y1,box3.x2,box3.y2,4)
   addText(frontlayer,font_small,""..Preset_2.."m",box3.x1+(box3.x2/2),box3.y1+(box3.y2/2))
if isCursorIn(box3.x1,box3.y1,box3.x1+box3.x2,box3.y1+box3.y2) then
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
if getCursorDown() then
   setNextFillColor(frontlayer,0.1, 0.1, 0.1, 1)
if getCursorPressed() then set_altitude(Preset_2) end 
   else
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
end
   setNextShadow(frontlayer, 32, color.r, color.g, color.b, 0.4)
   addBoxRounded(frontlayer, box3.x1,box3.y1,box3.x2,box3.y2,4)
end

--box4--
   addBoxRounded(frontlayer, box4.x1,box4.y1,box4.x2,box4.y2,4)
   addText(frontlayer,font_small,""..Preset_3.."m",box4.x1+(box4.x2/2),box4.y1+(box4.y2/2))
if isCursorIn(box4.x1,box4.y1,box4.x1+box4.x2,box4.y1+box4.y2) then
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
if getCursorDown() then
   setNextFillColor(frontlayer,0.1, 0.1, 0.1, 1)
if getCursorPressed() then set_altitude(Preset_3) end
   else
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
end
   setNextShadow(frontlayer, 32, color.r, color.g, color.b, 0.4)
   addBoxRounded(frontlayer, box4.x1,box4.y1,box4.x2,box4.y2,4)
end
--box5--
   addBoxRounded(frontlayer, box5.x1,box5.y1,box5.x2,box5.y2,4)
   addText(frontlayer,font_small,""..Preset_4.."m",box5.x1+(box5.x2/2),box5.y1+(box5.y2/2))
if isCursorIn(box5.x1,box5.y1,box5.x1+box5.x2,box5.y1+box5.y2) then
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
if getCursorDown() then
   setNextFillColor(frontlayer,0.1, 0.1, 0.1, 1)
if getCursorPressed() then set_altitude(Preset_4)  end                
   else
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
end
   setNextShadow(frontlayer, 32, color.r, color.g, color.b, 0.4)
   addBoxRounded(frontlayer, box5.x1,box5.y1,box5.x2,box5.y2,4)
end
--box6--
   addBoxRounded(frontlayer, box6.x1,box6.y1,box6.x2,box6.y2,4)
   addText(frontlayer,font_small,""..Preset_5.."m",box6.x1+(box6.x2/2),box6.y1+(box6.y2/2))
if isCursorIn(box6.x1,box6.y1,box6.x1+box6.x2,box6.y1+box6.y2) then
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
if getCursorDown() then
   setNextFillColor(frontlayer,0.1, 0.1, 0.1, 1)
if getCursorPressed() then set_altitude(Preset_5)  end                
   else
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
end
   setNextShadow(frontlayer, 32, color.r, color.g, color.b, 0.4)
   addBoxRounded(frontlayer, box6.x1,box6.y1,box6.x2,box6.y2,4)
end
--box7--
   addBoxRounded(frontlayer, box7.x1,box7.y1,box7.x2,box7.y2,4)
   addText(frontlayer,font_small,""..Preset_6.."m",box7.x1+(box7.x2/2),box7.y1+(box7.y2/2))
if isCursorIn(box7.x1,box7.y1,box7.x1+box7.x2,box7.y1+box7.y2) then
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
if getCursorDown() then
   setNextFillColor(frontlayer,0.1, 0.1, 0.1, 1)
if getCursorPressed() then set_altitude(Preset_6)  end                
   else
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
end
   setNextShadow(frontlayer, 32, color.r, color.g, color.b, 0.4)
   addBoxRounded(frontlayer, box7.x1,box7.y1,box7.x2,box7.y2,4)
end
--box8--
   addBoxRounded(frontlayer, box8.x1,box8.y1,box8.x2,box8.y2,4)
   addText(frontlayer,font_small,""..Preset_7.."m",box8.x1+(box8.x2/2),box8.y1+(box8.y2/2))
if isCursorIn(box8.x1,box8.y1,box8.x1+box8.x2,box8.y1+box8.y2) then
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
if getCursorDown() then
   setNextFillColor(frontlayer,0.1, 0.1, 0.1, 1)
if getCursorPressed() then set_altitude(Preset_7)  end                
   else
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
end
   setNextShadow(frontlayer, 32, color.r, color.g, color.b, 0.4)
   addBoxRounded(frontlayer, box8.x1,box8.y1,box8.x2,box8.y2,4)
end

--box9--
   addBoxRounded(frontlayer, box9.x1,box9.y1,box9.x2,box9.y2,4)
   addText(frontlayer,font_small,""..Preset_8.."m",box9.x1+(box9.x2/2),box9.y1+(box9.y2/2))
if isCursorIn(box9.x1,box9.y1,box9.x1+box9.x2,box9.y1+box9.y2) then
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
if getCursorDown() then
   setNextFillColor(frontlayer,0.1, 0.1, 0.1, 1)
if getCursorPressed() then set_altitude(Preset_8)  end                
   else
   setNextFillColor(frontlayer,0.3, 0.3, 0.3, 1)
end
   setNextShadow(frontlayer, 32, color.r, color.g, color.b, 0.4)
   addBoxRounded(frontlayer, box9.x1,box9.y1,box9.x2,box9.y2,4)
end
--left text and deco
setDefaultTextAlign(frontlayer, AlignH_Left, AlignV_Middle)
addText(frontlayer,font_small,"Target Altitude:",50,ry/2-240)
addText(frontlayer,font_small,"Gravity Well Altitude:",50,ry/2-200)
addText(frontlayer,font_small,"Current Altitude: ",50,ry/2-160)
addText(frontlayer,font_small,"Travel Time: ~",50,ry/2-120)

setDefaultTextAlign(frontlayer, AlignH_Right, AlignV_Middle)
addText(frontlayer,font_small,""..math.floor(aggtarget).."m",350,ry/2-240)
addText(frontlayer,font_small,""..math.floor(aggbase).."m",350,ry/2-200)
addText(frontlayer,font_small,""..math.floor(currentAlt).."m",350,ry/2-160)
addText(frontlayer,font_small,""..traveltime,350,ry/2-120)

setDefaultFillColor(layer, Shape_Box, color.r, color.g, color.b, 0.05)
setDefaultStrokeColor(layer,Shape_Box,color.r, color.g, color.b, 1)
setDefaultStrokeWidth(layer,Shape_Box,1)
addBox(layer,30,40, 340, 420)
addBox(layer,660,40, 330, 420)

setNextTextAlign(frontlayer, AlignH_Center, AlignV_Middle)
addText(frontlayer,font_big,"AGG Controller",rx/2+315,ry/2-240)
setNextTextAlign(frontlayer, AlignH_Center, AlignV_Middle)
addText(frontlayer,font_small,"v1.4.15 by:",rx/2+315,ry/2-200)
setNextTextAlign(frontlayer, AlignH_Center, AlignV_Middle)
addText(frontlayer,font_tiny,"Hadron | Wolfe Labs | TheGreatSardini",rx/2+315,ry/2-160)


