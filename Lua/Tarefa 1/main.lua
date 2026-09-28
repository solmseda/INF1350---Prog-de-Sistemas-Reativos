local blips= {}
local meublip
local player
local totalAcertados = 0

local numVoltasImortal = 3

local perdaAtingiImortails = 3
local totalAcertosImortals = 0
local estadoJogo = "jogando"

local tempoSpawn = 0
local intervaloSpawn = 2

local function newblip (vel)
  local x, y = 0, 0
  local tam = 40
  local numVoltas = 0
  local acertado = false
  local imortal = false
  return {
    update = function (dt)
      local width, _ = love.graphics.getDimensions( )
      x = x+(vel+1)*dt*40
      if x > width then
        -- volta para a esquerda da janela
        numVoltas = numVoltas + 1
        if(numVoltas == numVoltasImortal) then
          imortal = true
        end
        x = 0
      end
    end,
    affected = function (pos)
      if pos>x and pos<x+tam then
      -- "pegou" o blip
        return true
      else
        return false
      end
    end,
    isImortal = function ()
      return imortal
    end,
    draw = function()
      if imortal then
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", x, y, tam, 10)
      else
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", x, y, tam, 10)
      end
        love.graphics.setColor(1, 1, 1)
    end
  }
end

local function criarBlipAleatorio()
    local velocidade = love.math.random()
    table.insert(blips, newblip(velocidade))
end

local function newplayer ()
  local x, y = 0, 200
  local tam = 30
  local width, height = love.graphics.getDimensions( )
  return {
  try = function ()
    return x + tam/2
  end,
  update = function (dt)
    x = x + 0.5*30*dt
    if x > width then
      x = 0
    end
  end,
  draw = function ()
    love.graphics.rectangle("line", x, y, tam, 10)
  end
  }
end

function love.keypressed (key)
  if key == 'space' and estadoJogo == "jogando" then
    local pos = player.try()
    for _, blip in ipairs(blips) do
      if blip.affected(pos) then
        if blip.isImortal() then
          totalAcertosImortals = totalAcertosImortals + 1
        elseif not blip.acertado then
          blip.acertado = true
          totalAcertados = totalAcertados + 1
        end
      end
    end

    if totalAcertosImortals >= perdaAtingiImortails then
      estadoJogo = "perdeu"
    elseif totalAcertados == #blips then
      estadoJogo = "ganhou"
    end
  end
end


function love.load()
  player =  newplayer()
  blips = {newblip(love.math.random()), 
          newblip(love.math.random()), 
          newblip(love.math.random())}
--   meublip = newblip(5)
end

function love.draw()
  if estadoJogo ~= "jogando" then
    local mensagem = estadoJogo == "ganhou" and "Ganhou" or "Perdeu"
    local fonte = love.graphics.getFont()
    local largura, altura = love.graphics.getDimensions()

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
      mensagem,
      (largura - fonte:getWidth(mensagem)) / 2,
      (altura - fonte:getHeight()) / 2
    )
    return
  end

  player.draw()
  for _, blip in ipairs(blips) do
    blip.draw()
  end
--   meublip.draw()
end

function love.update(dt)
  if estadoJogo ~= "jogando" then
    return
  end

  tempoSpawn = tempoSpawn + dt

   if tempoSpawn >= intervaloSpawn then
      criarBlipAleatorio()
      tempoSpawn = 0
      intervaloSpawn = love.math.random(1, 3)
   end

  player.update(dt)
  for _, blip in ipairs(blips) do
    blip.update(dt)
  end
--   meublip.update(dt)
end
  
function love.quit ()
  love.window.close()
  os.exit()
end
