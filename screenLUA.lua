local enable_background_image = true
local background_image = loadImage("assets.prod.novaquark.com/102348/718b6805-93cb-4310-b271-0b20907b05c0.png")
theme_color = true --set to false to use below colors 
imageRed = 1 --background image red channel
imageGreen = 1 --background image green channel
imageBlue = 1 --background image blue channel
imageTrans = 1 --background image transparency

local time = getTime()
local t2 = 2*math.sin(time*2)

local cursor_image = loadImage("assets.prod.novaquark.com/102348/a6ad4ff3-372f-46f6-8e2c-86aa0c54f3a3.png")
local json = require('json')
back = createLayer()
layer = createLayer()
frontlayer = createLayer()
numpad = createLayer()
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
    traveltime = "1h 22min 35sec"
    maxAGGheight = 200000
    currentAlt = 2000
    atmoheight = 3600
    Preset_5 = 0
    Preset_6 = 0  
    Preset_7 = 0
    Preset_8 = 0
    atmoheight_0 = 100
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
    setNextFillColor(back, color.r, color.g, color.b, 0.05) --Background Image colour and Transparency
        else 
    setNextFillColor(back, imageRed, imageGreen, imageBlue, imageTrans) end
 -- setNextFillColor(layer, 1, 1, 1, 1) --Use this for an normal colour Background Image!
    addImage(back, background_image, 0, 0, rx, ry)
end

--fonts--
font_big = loadFont('Oxanium-Bold',42)
font_small = loadFont('Oxanium',29)
font_tiny = loadFont('Oxanium-Light',19)
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
                addText(layer, font_tiny, '10%', x + w + 36, atmo_y)

                addLine(layer, x - 6, atmo_y, x - 25, atmo_y)
                setNextTextAlign(layer, AlignH_Right, AlignV_Middle)
                addText(layer, font_tiny, '10%', x - 33, atmo_y)
            end
            -- Draw Atmosphere 0%
            if atmoheight then
                local atmo0_y = self:getYForValue(atmoheight_0)
                 setDefaultStrokeColor(layer,Shape_Line,0, 0.4, 1, 1)
                addLine(layer, x + w + 6, atmo0_y, x + w + 25, atmo0_y)
                setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                addText(layer, font_tiny, '0%', x + w + 36, atmo0_y)

                addLine(layer, x - 6, atmo0_y, x - 25, atmo0_y)
                setNextTextAlign(layer, AlignH_Right, AlignV_Middle)
                addText(layer, font_tiny, '0%', x - 36, atmo0_y)
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
            
         end


        return setmetatable(self, Slider)
    end

end

-- NumPad --
Display_Value = Display_Value or '' -- This initializes the top value as a string
function drawnumpad(layer,nx,ny,nl,nw)
    setNextFillColor(layer,0,0,0,0)
    setNextStrokeWidth(layer,0.1)
    setNextStrokeColor(layer,color.r,color.g,color.b,0.5)    
    addBox(layer,nx,ny,nl,nw)
    function drawbutton(layer,bx,by,bl,bw,btext,static)
        setDefaultStrokeWidth(layer,Shape_Box,1)
        setDefaultStrokeColor(layer,Shape_Box,color.r,color.g,color.b,0.1) 
        setDefaultTextAlign(layer, AlignH_Center, AlignV_Middle)
        setDefaultFillColor(layer,Shape_Box,color.r/10,color.g/10,color.b/10,1)
        
        if isCursorIn(bx,    by,    bx+bl,    by+bw) and not static then 
            setNextFillColor(layer,color.r,color.g,color.b,0.2)
            if  getCursorDown() then
                setNextFillColor(layer,color.r,color.g,color.b,0.3)
                setNextShadow(layer,15,color.r,color.g,color.b,0.7)
                end
            if getCursorPressed() then
                if 'C' == btext then
                  Display_Value = '' -- Clears value
                elseif 'SET' == btext then
                    set_altitude(Display_Value)
                    Display_Value = '' -- Clears value  
                else
                  Display_Value = Display_Value .. btext -- This appends the clicked number to your display
                end
            end 
        end
            addBox(layer,bx,by,bl,bw)
                        
            setDefaultStrokeWidth(layer,Shape_Line,0.5)
            setDefaultStrokeColor(layer,Shape_Line,color.r,color.g,color.b,1) 
            addLine(layer,bx,by+7+t2,bx,by)
            addLine(layer,bx,by,bx+7+t2,by)
            addLine(layer,bx+bl,by+bw-7-t2,bx+bl,by+bw)
            addLine(layer,bx+bl,by+bw,bx+bl-7-t2,by+bw)
        
            setDefaultStrokeWidth(layer,Shape_Line,1)
            setDefaultStrokeColor(layer,Shape_Line,color.r,color.g,color.b,1) 
            addLine(layer,bx,by+5,bx,by)       
            addLine(layer,bx,by,bx+5,by)
            addLine(layer,bx+bl,by+bw,bx+bl-5,by+bw)
            addLine(layer,bx+bl,by+bw-5,bx+bl,by+bw)
            
            setDefaultFillColor(layer,Shape_Text,color1.r,color1.g,color1.b,1)        
            addText(layer,font_small,btext,bx+(bl/2),by+(bw/2))
    end
-- Draw Keypad Buttons
drawbutton(numpad,nx+(nl/40),ny+(nw/50),nl/1.05,nw/6.5,Display_Value,true) 
drawbutton(numpad,nx+(nl/40),ny+(nw/5),nl/3.5,nw/6,"7")
drawbutton(numpad,nx+(nl/40),ny+(nw/2.5),nl/3.5,nw/6,"4")
drawbutton(numpad,nx+(nl/40),ny+(nw/1.67),nl/3.5,nw/6,"1")
drawbutton(numpad,nx+(nl/40),ny+(nw/1.25),nl/3.5,nw/6,"C")
drawbutton(numpad,nx+(nl/2.8),ny+(nw/5),nl/3.5,nw/6,"8")
drawbutton(numpad,nx+(nl/2.8),ny+(nw/2.5),nl/3.5,nw/6,"5")
drawbutton(numpad,nx+(nl/2.8),ny+(nw/1.675),nl/3.5,nw/6,"2")
drawbutton(numpad,nx+(nl/2.8),ny+(nw/1.25),nl/3.5,nw/6,"0") 
drawbutton(numpad,nx+(nl/1.45),ny+(nw/5),nl/3.5,nw/6,"9")
drawbutton(numpad,nx+(nl/1.45),ny+(nw/2.5),nl/3.5,nw/6,"6")
drawbutton(numpad,nx+(nl/1.45),ny+(nw/1.675),nl/3.5,nw/6,"3")
drawbutton(numpad,nx+(nl/1.45),ny+(nw/1.25),nl/3.5,nw/6,"SET") 
end

function drawbuttonPre(layer,bx,by,bl,bw,btext,static)
    setDefaultStrokeWidth(layer,Shape_Box,1)
    setDefaultStrokeColor(layer,Shape_Box,color.r,color.g,color.b,0.1) 
    setDefaultTextAlign(layer, AlignH_Center, AlignV_Middle)
    setDefaultFillColor(layer,Shape_Box,color.r/10,color.g/10,color.b/10,1)
    --setLayerClipRect(layer, bx,by,bl,bw)
    if isCursorIn(bx,    by,    bx+bl,    by+bw) and not static then 
            setNextFillColor(layer,color.r,color.g,color.b,0.2)
            if  getCursorDown() then
                setNextFillColor(layer,color.r,color.g,color.b,0.3)
                setNextShadow(layer,15,color.r,color.g,color.b,0.7)
                end
                if getCursorPressed() then set_altitude(btext) end 
            end
            addBox(layer,bx,by,bl,bw)
    
            setDefaultStrokeWidth(layer,Shape_Line,1)
            setDefaultStrokeColor(layer,Shape_Line,color.r,color.g,color.b,1) 
            addLine(layer,bx,by+5,bx,by)       
            addLine(layer,bx,by,bx+5,by)
            addLine(layer,bx+bl,by+bw,bx+bl-5,by+bw)
            addLine(layer,bx+bl,by+bw-5,bx+bl,by+bw)
    
            setDefaultStrokeWidth(numpad,Shape_Line,1)
            setDefaultStrokeColor(numpad,Shape_Line,color.r,color.g,color.b,1) 
            addLine(layer,bx,by+15+t2,bx,by)
            addLine(layer,bx,by,bx+15+t2,by)
            addLine(layer,bx+bl,by+bw-15-t2,bx+bl,by+bw)
            addLine(layer,bx+bl,by+bw,bx+bl-15-t2,by+bw)
    
            setDefaultFillColor(layer,Shape_Text,color1.r,color1.g,color1.b,1)        
            addText(layer,font_small,""..btext.."m",bx+(bl/2),by+(bw/2))
end
----------------------------------------------------------
------------------ FUNCTIONS END -------------------------
----------------------------------------------------------

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
    
    if not dragging then
        local h = aggtarget  
        slider_altitude = Slider:new(rx/2-35, ry*0.025, 70, ry* 0.92, config_altitude_min, config_altitude_max, h, get_pretty_distance(config_altitude_max), config_altitude_steps)
        slider_altitude.color = {color.r,color.g,color.b}

        _init = true
    end
    --------------------------------------------------------------
    slider_altitude:draw( layer)
    alt = slider_altitude:getValue()
    drawnumpad(numpad,50,130,270,340)
    drawbuttonPre(numpad,rx/2-490,ry/2+175,130,50,Preset_1,false)
    drawbuttonPre(numpad,rx/2-290,ry/2+175,130,50,Preset_2,false) 
    drawbuttonPre(numpad,rx/2-490,ry/2+245,130,50,Preset_3,false) 
    drawbuttonPre(numpad,rx/2-290,ry/2+245,130,50,Preset_4,false) 
    
    drawbuttonPre(numpad,rx/2+165,ry/2+175,130,50,Preset_5,false) 
    drawbuttonPre(numpad,rx/2+365,ry/2+175,130,50,Preset_6,false)
    drawbuttonPre(numpad,rx/2+165,ry/2+245,130,50,Preset_7,false) 
    drawbuttonPre(numpad,rx/2+365,ry/2+245,130,50,Preset_8,false) 
  
    drawCursor()
end

---- Touch Box setup ----
box1 = {x1=rx/2+220,y1=ry/2-75,x2=220,y2=100}
box11 = {x1=rx/2+235,y1=ry/2+80,x2=190,y2=55}

setDefaultStrokeColor(frontlayer,Shape_BoxRounded,color1.r, color1.g, color1.b, 1)
setDefaultFillColor(frontlayer,Shape_BoxRounded,color1.r/9, color1.g/9, color1.b/9, 1)
setDefaultStrokeWidth(frontlayer,Shape_BoxRounded,1)
setDefaultStrokeColor(layer,Shape_BoxRounded,color.r, color.g, color.b, 1)
setDefaultTextAlign(frontlayer, AlignH_Center, AlignV_Middle)
--box1--
addBoxRounded(frontlayer, box1.x1,box1.y1,box1.x2,box1.y2,4)
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

--left text and deco
setDefaultTextAlign(frontlayer, AlignH_Left, AlignV_Middle)
addText(frontlayer,font_small,"Target:",20,ry/2-270)
addText(frontlayer,font_small,"Gravity Well:",20,ry/2-235)
addText(frontlayer,font_small,"Current: ",20,ry/2-200)
addText(frontlayer,font_small,"Time:",675,ry/2-150)

setDefaultTextAlign(frontlayer, AlignH_Right, AlignV_Middle)
addText(frontlayer,font_small,""..math.floor(aggtarget).."m",350,ry/2-270)
addText(frontlayer,font_small,""..math.floor(aggbase).."m",350,ry/2-235)
addText(frontlayer,font_small,""..math.floor(currentAlt).."m",350,ry/2-200)
addText(frontlayer,font_small,""..traveltime,985,ry/2-150)

setDefaultFillColor(layer, Shape_Box, color.r, color.g, color.b, 0.05)
setDefaultStrokeColor(layer,Shape_Box,color.r, color.g, color.b, 1)
setDefaultStrokeWidth(layer,Shape_Box,1)
addBox(layer,15,15, 340, 455)
addBox(layer,670,15, 340, 455)

setNextTextAlign(frontlayer, AlignH_Center, AlignV_Middle)
addText(frontlayer,font_big,"AGG Controller",rx/2+325,ry/2-270)
setNextTextAlign(frontlayer, AlignH_Center, AlignV_Middle)
addText(frontlayer,font_small,"v1.4.15v4 by:",rx/2+325,ry/2-230)
setNextTextAlign(frontlayer, AlignH_Center, AlignV_Middle)
addText(frontlayer,font_tiny,"Hadron | Wolfe Labs | TheGreatSardini",rx/2+330,ry/2-190)
