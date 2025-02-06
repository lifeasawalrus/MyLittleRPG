function Init_font()
    return love.graphics.newFont("/fonts/alagard_by_pix3m-d6awiwp.ttf", 42)
end

function Printf(text,color,x,y,limit,alignment)
    love.graphics.printf( {color, text}, GOTHIC, x, y, limit, alignment )
end

function Color(r,g,b,a)
    return love.math.colorFromBytes(r,g,b,a)
end

Color_Palette = {
    black = {0,0,0,255},
    white = {255,255,255,255},
    shadow = {33,33,33,127},
}

function Draw(drawable,pos,scale)
    love.graphics.draw(drawable, pos.x, pos.y + pos.z, 0, scale)
end

function GetImg(path)
    return love.graphics.newImage(path)
end

function Size(t)
    return table.maxn(t)
end
