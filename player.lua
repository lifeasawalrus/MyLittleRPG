
SCREEN_WIDTH = love.graphics.getWidth()
SCREEN_HEIGHT = love.graphics.getHeight()

CHARACTERS = { "AJ", "CT", "FS", "GA", "L", "PP", "R", "RD", "RL", "RW", "TS", "YW", }
Ponies = { "AJ", "CT", "L", "PP", "RL", "RW", }
Unicorns = { "GA", "R", "YW", "TS", }
Pegasi = { "FS", "RD", "TS", }

--Player run ratio
RUN_RATIO = 0.5
MOVE_CAP = 0.066

--Table of players
Player = {}

function Add_New_Players()
    if Size(Player) < Size(Controller) then
        for i=Size(Player)+1,Size(Controller),1 do
            Player:new_player()
            Player[i]:init(CHARACTERS[(i)%(Size(CHARACTERS)+1)], Controller[i])
        end
    end
end

function Player:new_player()

    P = {

        Controller = nil,
        Attributes = {
            pos = {
                x = Camera.pos.x + SCREEN_WIDTH/2,
                y = Camera.pos.y + SCREEN_HEIGHT/2,
                z = 0,
            },
            dx = 0, dy = 0, dz = 0,
            scale = 3, --3
            sprite_dimension = 64,
            max_speed = 12,
            direction = "SW",
            state = "idle",
            grounded = true,
            type = "pony",
            health = 100,
            --player frame
            p_frame = 1,
            --stores start frame of an animation
            s_frame = 1,
        },
        Cursor = {
            pos = {
                x = SCREEN_WIDTH/2,
                y = SCREEN_HEIGHT/2,
                z = 0,
            },
            speed = 12,
            selection = 1,
            selected = false,
            color = {math.random()%256,math.random()%256,math.random()%256},
            button = {
                select = "a",
                movelr = "leftx",
                moveud = "lefty",
            },
        },
        Sprites = {
            E = {},
            N = {},
            NE = {},
            NW = {},
            S = {},
            SE = {},
            SW = {},
            W = {},
        },
        Shadow = {
            sprites = {},
            x_offset = -12,
            y_offset = 42,
        },
        Button = {
            movelr = "leftx",
            moveud = "lefty",
            rear   = "a",
            buck   = "y",
            jump   = "x",
            fly    = "a",
            alt    = "righty",
            menu   = "guide",
            start  = "start",
        },
        --Numbers denote frames in the respective animation cycle
        States = {
            state_frame = 1,
            idle    = {
                2,
                blinking  = false,
                blink     = { 14 },
                max_frame = 1,
            },
            walking = {
                1, 2, 3, 2,
                blinking  = false,
                blink     = { 13, 14, 15, 14, },
                max_frame = 4,
            },
            running = {
                18, 19,
                max_frame = 2,
            },
            jumping = {
                8, 17, 18, 12, 11,
                max_frame = 5,
                --variable to store p_frame at time of jump
                jumpstart = 1,
                --multiplier determining height of jump
                height = 3,
            },
            falling = {
                11,
                max_frame = 1,
                gravity = 12,
            },
            rearing = {
                8, 9, 10,
                max_frame = 3,
            },
            bucking = {
                11, 12,
                max_frame = 2,
            },
            flying  = {
                4, 5, 6, 7,
                max_frame = 4,
                offset = 0,
                --speed of altitude adjustment
                alt_speed = 6,
            },
            dead    = {
                20,
                max_frame = 1,
            },
        },

    }

    function P:init(character, controller)
        --Extract sprites by direction, and load them into 'Sprites' field
        for dir in pairs(self.Sprites) do
            for j=1,20,1 do
                local path = "assets/ponies/"..character.."/"..dir.."/"..dir..j..".png"
                self.Sprites[dir][j] =  GetImg(path)
            end
        end
        --extract shadow sprites
        for i=1,4,1 do
            local path = "assets/shadow/S"..i..".png"
            self.Shadow.sprites[i] = GetImg(path)
        end
        --
        if character=="GA" or character=="R" or character=="YW"
            --[[or character=="TS"--]] then
            self.Attributes.type = "unicorn"
        elseif character=="FS" or character=="RD" or character=="TS" then
            self.Attributes.type = "pegasus"
        elseif character=="AJ" or character=="CT" or character=="L" or character=="PP" or
            character=="RL" or character=="RW" then
            self.Attributes.type = "pony"
        end
        --self.Attributes.sprite_dimension = self.Attributes.sprite_dimension *
          --  self.Attributes.scale
        self.Controller = controller
    end

    function P:state_change(new_state)
        self.Attributes.state = new_state
        if new_state == "jumping" or new_state == "falling" or new_state == "flying" then
            self.Attributes.grounded = false
        else self.Attributes.grounded = true
        end
        self.States.state_frame = 1
        self.Attributes.p_frame = 0
        self.Attributes.s_frame = 0
        self:update_direction()
    end

    function P:last_frame()
        if self.States.state_frame == self.States[self.Attributes.state].max_frame then
            return true
        else return false
        end
    end

    function P:end_anim()
        local state = self.Attributes.state
        return self.Attributes.p_frame >= self.Attributes.s_frame
                + self.States[state].max_frame*TICK_SIZE
    end

    function P:get_movement()
        self.Attributes.dx = self.Controller:getGamepadAxis(self.Button.movelr)
        self.Attributes.dy = self.Controller:getGamepadAxis(self.Button.moveud)
        self.Attributes.dz = self.Controller:getGamepadAxis(self.Button.alt)
    end

    function P:is_moving()
        if math.abs(self.Attributes.dx) > MOVE_CAP or
            math.abs(self.Attributes.dy) > MOVE_CAP then
            return true
        else return false end
    end

    function P:moveable()
        return self.Attributes.state ~= "rearing" and self.Attributes.state ~= "bucking"
            and self.Attributes.state ~= "dead"
    end

    function P:move()
        local level = Map.current_level
        local map_width = Map[level].width * Camera.zoom - Camera.player_dimension
        local map_height = Map[level].height * Camera.zoom - Camera.player_dimension
        local origin_x = Map[level].worldX * Camera.zoom
        local origin_y = Map[level].worldY * Camera.zoom


        if self.Attributes.pos.y + self.Attributes.pos.z < origin_y then
            if self.Attributes.grounded then
                self.Attributes.pos.y = origin_y
            else
                local diff = self.Attributes.pos.y + self.Attributes.pos.z - 0
                self.Attributes.pos.z = self.Attributes.pos.z - diff
            end
        end
        if self.Attributes.pos.y > map_height then
            self.Attributes.pos.y = map_height
        end
        if self.Attributes.pos.x < origin_x then self.Attributes.pos.x = origin_x end
        if self.Attributes.pos.x > map_width then
            self.Attributes.pos.x = map_width end
        if self:moveable() then
            if math.abs(self.Attributes.dx) > MOVE_CAP then
                self.Attributes.pos.x =
                self.Attributes.pos.x + self.Attributes.max_speed * self.Attributes.dx
            end

            if math.abs(self.Attributes.dy) > MOVE_CAP then
                self.Attributes.pos.y =
                self.Attributes.pos.y + self.Attributes.max_speed * self.Attributes.dy
            end

            if math.abs(self.Attributes.dz) > MOVE_CAP and
                self.Attributes.state == "flying" then
                    self.Attributes.pos.z =
                    self.Attributes.pos.z + self.Attributes.max_speed * self.Attributes.dz
            end

            if self.Attributes.state == "jumping" then
                if self.States.state_frame < 3 then
                    self.Attributes.pos.z = self.Attributes.pos.z -
                        self.States.jumping.height
                elseif self.States.state_frame > 3 then
                    self.Attributes.pos.z = self.Attributes.pos.z +
                        self.States.jumping.height
                end
            elseif self.Attributes.state == "falling" then
                self.Attributes.pos.z = self.Attributes.pos.z +
                    self.States.falling.gravity
            end
        end

        self:update_direction()
    end

    function P:update_direction()
        local range = 0.09
        local dx = self.Attributes.dx
        local dy = self.Attributes.dy
        if math.abs(dx) > range and math.abs(dy) > range then
            if dx > range and dy > range then
                self.Attributes.direction = "SE"
            elseif dx < -range and dy > range then
                self.Attributes.direction = "SW"
            elseif dx > range and dy < -range then
                self.Attributes.direction = "NE"
            else self.Attributes.direction = "NW"
            end
        elseif math.abs(dx) > range then
            if dx > range then
                self.Attributes.direction = "E"
            else self.Attributes.direction = "W"
            end
        elseif math.abs(dy) > range then
            if dy > range then
                self.Attributes.direction = "S"
            else self.Attributes.direction = "N"
            end
        end
    end

    --Update player's animation frame
    function P:update_frame()
        self.Attributes.p_frame = self.Attributes.p_frame + 1
        --reset to first frame for loop
        if self.Attributes.p_frame%TICK_SIZE == 0 then
            if self:last_frame() then
                self.States.state_frame = 1
            else self.States.state_frame = self.States.state_frame + 1
            end
        end
    end


    table.insert(Player, P)

end

function Player:update_frame()
    for i in ipairs(self) do
        self[i]:update_frame()
    end
end

function Player:move()
    for i in ipairs(self) do
        self[i]:move()
    end
end

function Player:update()
    for i,p in ipairs(Player) do
        p:get_movement(i)
        local dx = p.Attributes.dx
        local dy = p.Attributes.dy
        if p.Attributes.state == "idle" then
            --can walk
            if p:is_moving() then
                if math.abs(dx) < RUN_RATIO and math.abs(dy) < RUN_RATIO then
                    p:state_change("walking")
            --can run
                else
                    p:state_change("running")
                end
            --can jump 
            elseif p.Controller:isGamepadDown(p.Button.jump) then
                p:state_change("jumping")
            --can rear
            elseif p.Controller:isGamepadDown(p.Button.rear) then
                p:state_change("rearing")
            --can buck
            elseif p.Controller:isGamepadDown(p.Button.buck) then
                p:state_change("bucking")
            end
        elseif p.Attributes.state == "jumping" then
            --can fly
            if p.Controller:isGamepadDown(p.Button.fly) and
                p.Attributes.type == "pegasus" then
                    p:state_change("flying")
            elseif p:end_anim() or p.Attributes.pos.z >=0 then
                if p.Attributes.pos.z < 0 then
                    p:state_change("falling")
                else
                    p.Attributes.pos.z = 0
                    --can idle
                    if p:is_moving() == false then
                        p:state_change("idle")
                    --can walk
                    elseif p:is_moving() then
                        if math.abs(dx) < RUN_RATIO and math.abs(dy) < RUN_RATIO then
                            p:state_change("walking")
                    --can run
                        else
                            p:state_change("running")
                        end
                    --can jump
                    elseif p.Controller:isGamepadDown(p.Button.jump) then
                        p:state_change("jumping")
                    --TODO: can fall
                    end
                end
            end
        elseif p.Attributes.state == "walking" then
            --can idle
            if p:is_moving() == false then
                p:state_change("idle")
            --can run
            elseif math.abs(dx) > RUN_RATIO or math.abs(dy) > RUN_RATIO then
                p:state_change("running")
            --can jump 
            elseif p.Controller:isGamepadDown(p.Button.jump) then
                p:state_change("jumping")
            --can rear
            elseif p.Controller:isGamepadDown(p.Button.rear) then
                p:state_change("rearing")
            --can buck
            elseif p.Controller:isGamepadDown(p.Button.buck) then
                p:state_change("bucking")
            --TODO: can fall
            end
        elseif p.Attributes.state == "running" then
            --can idle
            if p:is_moving() == false then
                p:state_change("idle")
            --can walk
            elseif math.abs(dx) < RUN_RATIO and math.abs(dy) < RUN_RATIO then
                p:state_change("walking")
            --can jump
            elseif p.Controller:isGamepadDown('x') then
                p:state_change("jumping")
            --can rear
            elseif p.Controller:isGamepadDown(p.Button.rear) then
                p:state_change("rearing")
            --can buck
            elseif p.Controller:isGamepadDown(p.Button.buck) then
                p:state_change("bucking")
            --TODO: can fall
            end
        elseif p.Attributes.state == "rearing" then
            if p:end_anim() then
                --can rear
                if p.Controller:isGamepadDown(p.Button.rear) then
                    p:state_change("rearing")
                --can idle
                elseif p:is_moving() == false then
                    p:state_change("idle")
                --can walk
                elseif p:is_moving() then
                    if math.abs(dx) < RUN_RATIO and math.abs(dy) < RUN_RATIO then
                        p:state_change("walking")
                    --can run
                    else
                        p:state_change("running")
                    end
                end
            end
        elseif p.Attributes.state == "bucking" then
            if p:end_anim() then
                --can idle
                if p:is_moving() == false then
                    p:state_change("idle")
                --can walk
                elseif p:is_moving() then
                    if math.abs(dx) < RUN_RATIO and math.abs(dy) < RUN_RATIO then
                        p:state_change("walking")
                --can run
                    else
                        p:state_change("running")
                    end
                end
            end
        elseif p.Attributes.state == "flying" then
            --can land (end frames of jump)
            if p.Controller:isGamepadDown(p.Button.jump) or p.Attributes.pos.z >= 0 then
                p:state_change("falling")
                --end animation of jump for landing
                --p.States.state_frame = 4
                --p.Attributes.p_frame = 3*TICK_SIZE
            end
        elseif p.Attributes.state == "falling" then
            if p.Attributes.pos.z >= 0 then
                p.Attributes.pos.z = 0
                p:state_change("idle")
            elseif p.Controller:isGamepadDown(p.Button.fly) and
                p.Attributes.type == "pegasus" then
                    p:state_change("flying")
            end
        elseif p.Attributes.state == "dead" then
            --can idle
        end
        if p.Attributes.health <= 0 then
            p.Attributes.health = 0
            p.Attributes.state = "dead"
        end
    end
end

function Player:draw()
    local order = {}
    for i in ipairs(Player) do
        table.insert(order, i)
    end
    table.sort(order, function(yLhs, yRhs)
        return Player[yLhs].Attributes.pos.y < Player[yRhs].Attributes.pos.y end)

    --increase opacity for shadow drawing
    love.graphics.setColor({1,1,1,0.09})

    --draw player shadows
    for i in ipairs(Player) do
        if Player[order[i]].Cursor.selected == true then
            local dir = Player[order[i]].Attributes.direction
            local pos = { x = Player[order[i]].Attributes.pos.x - Camera.pos.x,
                y = Player[order[i]].Attributes.pos.y - Camera.pos.y, z = 0
            }
            local x_offset = Player[order[i]].Shadow.x_offset * Camera.zoom/Map.scale
            local y_offset = Player[order[i]].Shadow.y_offset * Camera.zoom/Map.scale
            local z = Player[order[i]].Attributes.pos.z
            local scale = Camera.zoom --Player[order[i]].Attributes.scale
            local index = 1
            if dir == "W" then
                scale = -scale
                local var1, var2 = 40, 32 --IDK DUDE
                x_offset = x_offset - var1*scale
                y_offset = y_offset - var2*scale
            end
            if dir == "W" or dir =="E" then
                index = 1
            elseif dir == "NE" or dir == "SW" then
                index = 2
            elseif dir == "N" or dir == "S" then
                index = 3
            elseif dir == "NW" or dir == "SE" then
                index = 4
            end
            local magic_num = math.sqrt(math.sqrt(math.sqrt(math.sqrt(z*z))))
            if math.abs(z) > 0 then
                scale = scale / magic_num
            end
            if scale > Player[order[i]].Attributes.scale then
                scale = Player[order[i]].Attributes.scale
            end
            pos.x = pos.x + x_offset + (6/scale*scale)*magic_num*scale
            pos.y = pos.y + y_offset + (6/scale*scale)*magic_num*scale
            Draw(Player[order[i]].Shadow.sprites[index], pos, scale)
        end
    end

    love.graphics.setColor({1,1,1,1})

    --draw player sprites
    for i in ipairs(Player) do
        if Player[order[i]].Cursor.selected == true then
            local state = Player[order[i]].Attributes.state
            local state_frame = Player[order[i]].States.state_frame
            local aniframe = Player[order[i]].States[state][state_frame]
            local dir = Player[order[i]].Attributes.direction
            local pos = { x = Player[order[i]].Attributes.pos.x - Camera.pos.x,
                         y = Player[order[i]].Attributes.pos.y - Camera.pos.y,
                         z = Player[order[i]].Attributes.pos.z}
            local scale = Camera.zoom --Player[order[i]].Attributes.scale
            Draw(Player[order[i]].Sprites[dir][aniframe], pos, scale)
        end
    end
end

function Player:update_cursors()
    for i,p in ipairs(Player) do
        p:get_movement(i)
        local dx = p.Attributes.dx
        local dy = p.Attributes.dy
        if p.Cursor.selected == false then
            if math.abs(dx) > MOVE_CAP then
                p.Cursor.pos.x = p.Cursor.pos.x + p.Cursor.speed * dx
            end
            if math.abs(dy) > MOVE_CAP then
                p.Cursor.pos.y = p.Cursor.pos.y + p.Cursor.speed * dy
            end
        else
            p.Cursor.color = {math.random()%256,math.random()%256,math.random()%256,}
        end
        if p.Controller:isGamepadDown(p.Button.rear) then
            p.Cursor.selection = Get_Character(p.Cursor.pos.x, p.Cursor.pos.y)
            if p.Cursor.selection ~= nil then
                p.Cursor.selected = true
            end
        end
        if p.Controller:isGamepadDown(p.Button.buck) then
            p.Cursor.selected = false
        end
    end
end

function Player:draw_cursors()
    for i,p in ipairs(Player) do
        --offsets to center cursor visual over actual location
        local x = p.Cursor.pos.x - 60
        local y = p.Cursor.pos.y - 21
        Printf("P"..i, p.Cursor.color, x, y, 120, "center")
    end
end

function Player:update_characters()
    for i,p in ipairs(Player) do
        Player[i]:init(CHARACTERS[p.Cursor.selection], p.Controller)
    end
end

function Player:cursor_init()
    for i in ipairs(Player) do
        Player[i].Cursor.selected = false
        Player[i].Cursor.pos.x = SCREEN_WIDTH/2
        Player[i].Cursor.pos.y = SCREEN_HEIGHT/2
    end
end

function Get_Character(x, y)
    local spacing = Menu.Attributes.scale * Menu.Attributes.sprite_h/(3*1.8)
    local far_left = Menu.Attributes.left_page
    local far_right = Menu.Attributes.right_page + Menu.Attributes.page_width
    local top = Menu.Attributes.page_y
    if x > far_left then
        if x < far_left + Menu.Attributes.page_width/2.7 then
            if y > top then
                if y < top + spacing then
                    return 1
                elseif y < top + 2*spacing then
                    return 3
                elseif y < top + 3*spacing then
                    return 5
                else return nil end
            end
        elseif x < far_left + Menu.Attributes.page_width then
            if y > top then
                if y < top + spacing then
                    return 2
                elseif y < top + 2*spacing then
                    return 4
                elseif y < top + 3*spacing then
                    return 6
                else return nil end
            end
        elseif x < Menu.Attributes.right_page + Menu.Attributes.page_width/2.7 then
            if y > top then
                if y < top + spacing then
                    return 7
                elseif y < top + 2*spacing then
                    return 9
                elseif y < top + 3*spacing then
                    return 11
                else return nil end
            end
        elseif x < far_right then
            if y > top then
                if y < top + spacing then
                    return 8
                elseif y < top + 2*spacing then
                    return 10
                elseif y < top + 3*spacing then
                    return 12
                else return nil end
            end
        end
    else return nil end
end
