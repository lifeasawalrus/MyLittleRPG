local ldtk = require "ldtk"

Map = {

    current_level = "",
    scale = 3,
    layers = {},
    ents = {}, --entities

}

Camera = {

    pos = {
        x = 0,
        y = 0,
    },
    target = {
        x = 0,
        y = 0,
    },
    speed = {
        dx = 0,
        dy = 0,
    },
    zoom = 3,
    acceleration = 0.12,
    player_dimension = 64,
    zoom_out = true,
    zoom_acc = 0.999,

}

function Camera:_init()
    Camera.pos.x = Map.ents.Camera_start.x
    Camera.pos.y = Map.ents.Camera_start.y
end

function Camera:update_target()
    local sum_x, sum_y = 0, 0

    for i in ipairs(Player) do
        local p_x = Player[i].Attributes.pos.x
        local p_y = Player[i].Attributes.pos.y
        sum_x = sum_x + p_x
        sum_y = sum_y + p_y
    end
    self.target.x = (sum_x / Size(Player)) - SCREEN_WIDTH/2 + Camera.player_dimension
    self.target.y = (sum_y / Size(Player)) - SCREEN_HEIGHT/2
end

function Camera:update_pos()

    local map_width = Map[Map.current_level].width * Camera.zoom
    local map_height = Map[Map.current_level].height * Camera.zoom
    local origin_x = Map[Map.current_level].worldX * Camera.zoom
    local origin_y = Map[Map.current_level].worldY * Camera.zoom

    if self.pos.x < self.target.x and Camera.pos.x + SCREEN_WIDTH < map_width then
        self.speed.dx = math.abs(self.pos.x - self.target.x)*self.acceleration
        self.pos.x = self.pos.x + self.speed.dx
    end

    if self.pos.x > self.target.x and Camera.pos.x > origin_x then
        self.speed.dx = math.abs(self.pos.x - self.target.x)*self.acceleration
        self.pos.x = self.pos.x - self.speed.dx
    end

    if self.pos.y < self.target.y and Camera.pos.y + SCREEN_HEIGHT < map_height then
        self.speed.dy = math.abs(self.pos.y - self.target.y)*self.acceleration
        self.pos.y = self.pos.y + self.speed.dy
    end

    if self.pos.y > self.target.y and Camera.pos.y > origin_y then
        self.speed.dy = math.abs(self.pos.y - self.target.y)*self.acceleration
        self.pos.y = self.pos.y - self.speed.dy
    end
end




function Load_Map()
    ldtk:load("assets/maps/test.ldtk")
    ldtk:goTo(1)
    Camera:_init()
end

function Update_Map()
    Camera:update_target()
    Camera:update_pos()
    --update player_dimension
    Camera.player_dimension = 64*Camera.zoom/Map.scale

    --\/\/\/MAKE THIS A FUNCTION STUPID\/\/\/
    -----------------------------------------
    --[[
    if Camera.zoom_out == true then
        Camera.zoom = Camera.zoom * Camera.zoom_acc
        if Camera.zoom < 1.5 then Camera.zoom_out = false end
    else Camera.zoom = Camera.zoom / Camera.zoom_acc
        if Camera.zoom > 3 then Camera.zoom_out = true end
    end
    --]]
    -----------------------------------------
    --print(Camera.zoom)
end

function Draw_Map()
    love.graphics.scale(Camera.zoom, Camera.zoom)

    for i = 1, #Map.layers do
        Map.layers[i]:draw()
    end

    love.graphics.origin()
    --Printf("Camera.x "..Camera.pos.x, Color_Palette.white, 5, 5, SCREEN_WIDTH)
    --Printf("Camera.y "..Camera.pos.y, Color_Palette.white, 5, 45, SCREEN_WIDTH)
    --Printf("player.x "..Player[1].Attributes.pos.x - Camera.pos.x, Color_Palette.white, 5, 90, SCREEN_WIDTH)
    --Printf("player.y "..Player[1].Attributes.pos.y - Camera.pos.y, Color_Palette.white, 5, 135, SCREEN_WIDTH)
    --Printf("map_width "..Map[Map.current_level].width*Camera.zoom.." map_height "..Map[Map.current_level].height*Camera.zoom, Color_Palette.white, 5, 180, SCREEN_WIDTH)
end


--ldtk callback overrides:
function ldtk.onEntity(entity, level)
    local ent = entity.id
    Map.ents[entity.id] = entity
    Map.ents[ent].x = Map.ents[ent].x --* Map.scale
    Map.ents[ent].y = Map.ents[ent].y --* Map.scale
    --
    --TODO: create helper functions to extract and scale all properties of the entity
    --
end

function ldtk.onLayer(layer)
    table.insert(Map.layers, 1, layer)
end

function ldtk.onLevelLoaded(levelData)
end

function ldtk.onLevelCreated(levelData)
    Map[levelData.id] = levelData
    Map.current_level = levelData.id
    local level = Map.current_level
    Map[level].width = Map[level].width --* Map.scale
    Map[level].height = Map[level].height --* Map.scale
    Map[level].worldX = Map[level].worldX --* Map.scale
    Map[level].worldY = Map[level].worldY --* Map.scale
    --print(levelData.width, levelData.height)
    --print(SCREEN_WIDTH, SCREEN_HEIGHT)
    --
    --TODO: create helper functions to extract and scale all properties of the entity
    --
end

