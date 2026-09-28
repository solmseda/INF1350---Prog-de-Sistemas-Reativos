local xinit = 50
local yinit = 50
local retangulos = {}

function retangulo (x,y,w,h)
  local originalx, originaly, rx, ry, rw, rh = x, y, x, y, w, h
    return {
      draw = function ()
        love.graphics.rectangle("line", x, y, w, h)
      end,
      keypressed = function (key)
        local mx, my = love.mouse.getPosition()
        if key == 'b' and naimagem (mx,my, x, y, w, h) then
          y = yinit  
        elseif key == 'down' and naimagem(mx, my, x, y, w, h) then
          y = y + 10
        elseif key == 'right' and naimagem(mx, my, x, y, w, h) then
          x = x + 10
        end
      end
  }
end

function naimagem(mx, my, x, y, w, h)
  return mx > x and mx < x + w and my > y and my < y + h
end

function love.load()
  retangulos = {
    retangulo (xinit, yinit, 200, 300);
  }
  
  -- x = xinit 
  -- y = yinit
  -- w = 200 h = 300
end

function love.keypressed(key)
  for _, ret in ipairs(retangulos) do 
    ret.keypressed(key)
  end
  -- local mx, my = love.mouse.getPosition() 
  -- if key == 'b' and naimagem (mx,my, x, y) then
  --    y = yinit  
  -- elseif key == 'down' and naimagem(mx, my, x, y) then
  --   y = y + 10
  -- elseif key == 'right' and naimagem(mx, my, x, y) then
  --   x = x + 10
end

function love.draw ()
  -- love.graphics.rectangle("line", x, y, w, h)
  for _, ret in ipairs(retangulos) do
    ret.draw()
  end
end
