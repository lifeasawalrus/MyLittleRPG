require("simp")
require("player")
require("init")
require("menu")
require("controller")
require("map")

FRAME = 0
TICK_SIZE = 9
PAUSE = false

----Main Loop
function love.load()
    --'init.lua'
    Initialize()
    Load_Map()
    Controller = love.joystick.getJoysticks()
    Add_New_Players()
end

function love.update(dt)
    FRAME = FRAME + 1
    Controller = love.joystick.getJoysticks()
    Add_New_Players()
    Update_Map()
    if Input("start") or Input("guide") and PAUSE==false then
        PAUSE = true
    elseif PAUSE then
        if Menu.state=="main_menu" then
            PAUSE = false
        end
    end
    --\/\/uncomment this line for slow frame update (debug tool)
    --if FRAME%TICK_SIZE==0 then
    if Size(Controller) > 0 and PAUSE==false then
        Player:update_frame()
        Player:update()
        Player:move()
    elseif PAUSE then
        Menu:update_frame()
        Menu:update()
    end
    --end
    --\/\/warning remover
    dt = dt + 0
end

function love.draw()
    love.graphics.translate(-Camera.pos.x, -Camera.pos.y)

    Draw_Map()
    if Size(Player) > 0 then
        Player:draw()
    end
    love.graphics.origin()
    if PAUSE then
        Menu:draw()
    end
    Debug()
end
----

function Debug()
    --debug
    --Printf("Players "..Size(Player),5,5,SCREEN_WIDTH)
    --Printf("Frames "..FRAME,5,45,SCREEN_WIDTH)
    --Printf("X "..Player[1].Attributes.pos.x.." Y "..Player[1].Attributes.pos.y,
    --       Color_Palette.white, 5, 5, SCREEN_WIDTH)
    --Printf("SCREEN_WIDTH "..SCREEN_WIDTH.." SCREEN_HEIGHT"..SCREEN_HEIGHT,
    --       Color_Palette.white, 5, 45, SCREEN_WIDTH)

    --local dx = Controller[1]:getGamepadAxis(Player[1].Button.movelr)
    --local dy = Controller[1]:getGamepadAxis(Player[1].Button.moveud)
    --Printf(Player[1].Attributes.state,5,SCREEN_HEIGHT-123,SCREEN_WIDTH)
    --[[
    if Player[1].Controller:isGamepadDown('x') then
        Printf("jump",5,SCREEN_HEIGHT-160,SCREEN_WIDTH)
    end
    --]]

    --Prints joysticks and mappings to screen (adjust conf.lua to 4096 for t.window.width)
    --[[
    local joysticks = love.joystick.getJoysticks()
    for i, joystick in ipairs(joysticks) do
        love.graphics.print(joystick:getName(), 250, i*80-21)
        love.graphics.print(joysticks[i]:getGamepadMappingString(), 5, i*80)
    end
    --]]
    --Draw all sprites for a player object
    --[[
    if TICK<21 then
        Draw(Player[1].Sprites.E[TICK%20+1], Player[1].Attributes.pos, Player[1].Attributes.scale)
    elseif TICK < 42 then
        Draw(Player[1].Sprites.SE[TICK%20+1], Player[1].Attributes.pos, Player[1].Attributes.scale)
    elseif TICK < 63 then
        Draw(Player[1].Sprites.S[TICK%20+1], Player[1].Attributes.pos, Player[1].Attributes.scale)
    elseif TICK < 84 then
        Draw(Player[1].Sprites.SW[TICK%20+1], Player[1].Attributes.pos, Player[1].Attributes.scale)
    elseif TICK < 105 then
        Draw(Player[1].Sprites.W[TICK%20+1], Player[1].Attributes.pos, Player[1].Attributes.scale)
    elseif TICK < 126 then
        Draw(Player[1].Sprites.NW[TICK%20+1], Player[1].Attributes.pos, Player[1].Attributes.scale)
    elseif TICK < 147 then
        Draw(Player[1].Sprites.N[TICK%20+1], Player[1].Attributes.pos, Player[1].Attributes.scale)
    elseif TICK < 168 then
        Draw(Player[1].Sprites.NE[TICK%20+1], Player[1].Attributes.pos, Player[1].Attributes.scale)
    else TICK = 1
    end
    --]]
    --
end


function love.run()
    if love.load then love.load(--[[love.arg.parseGameArguments(arg), arg--]]) end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local dt = 0

    -- Main loop time.
    return function()
        -- Process events.
        if love.event then
            love.event.pump()
            for name, a,b,c,d,e,f in love.event.poll() do
                if name == "quit" then
                    --[[if not love.quit or not love.quit() then--]]
                    return a or 0
                    --[[end--]]
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then dt = love.timer.step() end

        -- Call update and draw
        if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())

            if love.draw then love.draw() end

            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end
