
Menu = {

    meta_state = "main_menu",

    meta_frame = 1,

    --should move selection due to user input. Here to prevent fast scrolling
    move_up = false,
    move_down = false,

    main_menu = {
        --is an index of selection
        curr_selection = 1,
        selection = {
            "Resume",
            "Character Select",
            "Controls",
            "Audio",
            "Save",
            "Quit",
        },
    },

    character_select = {
        selection = {
            "Character Select",
        },
        sprites = {},
    },

    controls = {},

    audio = {},

    save = {},

    quit = {
        curr_selection = 1,
        selection = {
            --sloppy, but effective solution to pretty print a title
            "",
            "No",
            "Yes",
        },
    },

    animate = {
        anim_state = "open",
        --current animation frame
        frame = 1,
        --start frame of an animation, for timing page flips
        s_frame = 1,
        sprite = {},
        open = { 1, 2, 3, max_frame=3 },
        close = { 3, 2, 1, max_frame=3 },
        flip_r = { 4, 5, 6, 7, max_frame=4 },
        flip_l = { 7, 6, 5, 4, max_frame=4 },
        still = { 4, max_frame=1 },
    },

    Attributes = {
        pos = {
            x = 0,
            y = 0,
            z = 0,
        },
        scale = 1,
        sprite_w=190,
        sprite_h=160,
        left_page=0,
        right_page=0,
        page_y=0,
        page_width=0,
    },

}

CHARACTER_SELECTION = {}

function Wipe_Character_Selection()
    if Size(CHARACTER_SELECTION) > 0 then
        for p in pairs(CHARACTER_SELECTION) do
            CHARACTER_SELECTION[p] = nil
        end
    end
end

function Menu:init()
    local frames = 7
    for i=1,frames,1 do
        local path = "assets/menu/PG"..i..".png"
        table.insert(Menu.animate.sprite, GetImg(path))
    end
    --scale and center the menu display
    local sprite_w = Menu.Attributes.sprite_w
    local sprite_h = Menu.Attributes.sprite_h
    local scale_w = math.floor(SCREEN_WIDTH/sprite_w)
    local scale_h = math.floor(SCREEN_HEIGHT/sprite_h)
    if scale_h < scale_w then Menu.Attributes.scale = scale_h
    else Menu.Attributes.scale = scale_w end
    Menu.Attributes.pos.x = SCREEN_WIDTH/2 -
        Menu.Attributes.sprite_w*Menu.Attributes.scale/2
    Menu.Attributes.pos.y = SCREEN_HEIGHT/2 -
        Menu.Attributes.sprite_h*Menu.Attributes.scale/2
    --set page margins
    local book_w = sprite_w*Menu.Attributes.scale
    Menu.Attributes.left_page = Menu.Attributes.pos.x + book_w*0.15
    Menu.Attributes.right_page = Menu.Attributes.pos.x + book_w*0.21 + math.floor(book_w/3)
    Menu.Attributes.page_y = Menu.Attributes.pos.y + scale_h*sprite_h*0.21
    Menu.Attributes.page_width = math.floor(book_w/3)
end

function Menu.main_menu:action(selection)
    if selection=="Resume" then
        Menu:state_change("close")
    elseif selection == "Quit" then
        Menu:state_change("flip_l")
        Menu.meta_state = "quit"
    elseif selection == "Character Select" then
        Menu:state_change("flip_r")
        Menu.meta_state = "character_select"
        Wipe_Character_Selection()
        Player:cursor_init()
    end
end

function Menu.quit:action(selection)
    if selection=="No" then
        Menu:state_change("flip_r")
        Menu.meta_state = "main_menu"
    elseif selection=="Yes" or Input("y") then
        love.event.push("quit")
    end
end

--for animations only
function Menu:state_change(new_state)
    self.animate.anim_state=new_state
    self.animate.frame = 1
    self.animate.s_frame = 1
    self.meta_frame = 1
end

function Menu:end_anim()
    local state = Menu.animate.anim_state
    local max = Menu.animate[state].max_frame
    return self.meta_frame >= max*TICK_SIZE
end

function Menu:update_frame()
    if Menu.meta_frame%TICK_SIZE==0 and Menu.animate.anim_state~="still" then
        Menu.animate.frame = Menu.animate.frame + 1
    elseif Menu.animate.anim_state=="flip_r" or Menu.animate.anim_state=="flip_l" then
        if Menu.meta_frame%3==0 then
            if Menu.animate.frame>=Menu.animate.flip_l.max_frame then
                Menu.animate.frame = 1
            else
                Menu.animate.frame = Menu.animate.frame + 1
            end
        end
    end
end

function Menu:update_selection()
    if (Menu.meta_frame-Menu.animate.s_frame)%TICK_SIZE==0  and
        Menu.meta_frame~=Menu.animate.s_frame then
        if Menu.move_down then
            local state = Menu.meta_state
            if Menu[state].curr_selection == Size(Menu[state].selection) then
                Menu[state].curr_selection = 1
            else
                Menu[state].curr_selection = Menu[state].curr_selection + 1
            end
            Menu.move_down = false
        end
        if Menu.move_up then
            local state = Menu.meta_state
            if Menu[state].curr_selection == 1 then
                Menu[state].curr_selection = Size(Menu[state].selection)
            else
                Menu[state].curr_selection = Menu[state].curr_selection - 1
            end
            Menu.move_up = false
        end
        local index = Menu[Menu.meta_state].curr_selection
        if Menu[Menu.meta_state].selection[index] == "" then
            Menu[Menu.meta_state].curr_selection = Menu[Menu.meta_state].curr_selection+1
        end
    end
end

function Menu:update()
    if Menu.animate.anim_state~="still" then
        if Menu:end_anim() then
            local state = Menu.animate.anim_state
            if state=="close" then
                PAUSE=false
                --Prep Menu class for next PAUSE command
                Menu:state_change("open")
            else
                Menu:state_change("still")
            end
        end
    else
        if Menu.meta_state=="character_select" then
            if Input("start") then
                Player:update_characters()
                Menu:state_change("flip_l")
                Menu.meta_state = "main_menu"
            end
            Player:update_cursors()
        else
            if InputAxis("lefty") > MOVE_CAP*5 or Input("dpdown") then
                if Menu.move_down==false then
                    Menu.animate.s_frame = Menu.meta_frame
                end
                Menu.move_down = true
            elseif InputAxis("lefty") < -MOVE_CAP*5 or Input("dpup") then
                if Menu.move_up==false then
                    Menu.animate.s_frame = Menu.meta_frame
                end
                Menu.move_up = true
            end
            Menu:update_selection()
            if Input("a") then
                local state = Menu.meta_state
                local index = Menu[state].curr_selection
                Menu[state]:action(Menu[state].selection[index])
            end
            if Input("start") or Input("y") then
                Menu:state_change("close")
            end
        end
    end
    Menu.meta_frame = Menu.meta_frame + 1
end

function Menu:draw()
    local frame = Menu.animate.frame
    local state = Menu.animate.anim_state
    local index = Menu.animate[state][frame]
    if index==nil then index = 4 end
    Draw(Menu.animate.sprite[index], Menu.Attributes.pos,
        Menu.Attributes.scale)
    if self.animate.anim_state=="still" then
        if self.meta_state == "character_select" then
            Menu:draw_character_selection()
            Player:draw_cursors()
        else
            local curr_opt = Menu[Menu.meta_state].curr_selection
            local num_opt = Size(Menu[Menu.meta_state].selection)
            local spacing = Menu.Attributes.scale*Menu.Attributes.sprite_h/(num_opt*1.8)
            if Menu.meta_state=="quit" then
                Printf("Are you sure you want to quit?", Color_Palette.black,
                    Menu.Attributes.left_page, Menu.Attributes.page_y,
                    Menu.Attributes.page_width,"left")
            end
            for i in ipairs(Menu[Menu.meta_state].selection) do
                if i==curr_opt then
                        Printf(Menu[Menu.meta_state].selection[i], Color_Palette.white,
                            self.Attributes.left_page, Menu.Attributes.page_y+(i-1)*spacing,
                        self.Attributes.page_width,"left")
                else
                    Printf(Menu[Menu.meta_state].selection[i], Color_Palette.black, self.Attributes.left_page,
                        Menu.Attributes.page_y+(i-1)*spacing,
                        self.Attributes.page_width,"left")
                end
            end
        end
    end
end

function Menu:draw_character_selection()
    local spacing = Menu.Attributes.scale*Menu.Attributes.sprite_h/(3*1.8)
    for i in ipairs(CHARACTERS) do
        local page
        if i <= 6 then
            page = "left_page"
        else page = "right_page"
        end
        if i%2==1 then
            local pos = {
                x = Menu.Attributes[page],
                y = Menu.Attributes.page_y+math.floor(((i-1)%6)/2)*spacing + 24,
                z = 0,
            }
            Draw(Menu.character_select.sprites[i], pos, 3)
        else
            local pos = {
                x = Menu.Attributes[page]+Menu.Attributes.page_width/2,
                y = Menu.Attributes.page_y+math.floor(((i-1)%6)/2)*spacing + 24,
                z = 0,
            }
            Draw(Menu.character_select.sprites[i], pos, 3)
        end
    end
end

function Menu:char_select_init()
    for i in ipairs(CHARACTERS) do
        local path = "assets/ponies/"..CHARACTERS[i].."/E/E2.png"
        table.insert(Menu.character_select.sprites, GetImg(path))
    end
end
