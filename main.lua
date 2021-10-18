require("node")
require("minimax")
require("player")

local font = love.graphics.newFont(20)
love.graphics.setFont(font)

local startInstruct = "First Choose Start Amount, [Up] and [Down], then [Enter to confirm]\nPress [F] to toggle who goes first\n[D] to change difficulty"
local instruct = "Use Arrow Keys to change split selection (In Green)\nPress [ENTER] to split stack"
debugMsg = ""

--Copy table
function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function love.load(arg)
    math.randomseed(os.time())
    
    io.stdout:setvbuf("no")
    if arg[#arg] == "-debug" then require("mobdebug").start() end

    love.window.setMode(1000, 500, {resizable=true, vsync=false, minwidth=1000, minheight=500})
    centerX = love.graphics.getWidth()/2
    centerY = love.graphics.getHeight()/2

    love.graphics.setDefaultFilter("nearest", "nearest")
end

function love.keypressed(key, scancode, isrepeat)
    if playing then
        Game(key, scancode, isrepeat)        
    else
        Menu(key, scancode, isrepeat)
    end
end

--logic for menu 
function Menu(key, scancode, isrepeat)
    --Difficulty
    if key == "d" then
        difficulty = difficulty + 1
        if difficulty > 3 then difficulty = 1 end
    end
    
    --Who goes first
    if key == "f" then
        playerFirst = not playerFirst
    end
    
    --Start size choosing
    if key == "up" then
        startAmount = startAmount + 1
        if startAmount > 15 then startAmount = 15 end
    end
    
    if key == "down" then
        startAmount = startAmount - 1
        if startAmount < 5 then startAmount = 5 end
    end
    
    --Confirm choices
    if key == "return"  then
        startNode = Node:New()
        startNode.stacks = {startAmount}

        startNode:FindChildren(false)
        
        playing = true
        
        if playerFirst then playerTurn = true else playerTurn = false end
        
        debugMsg = "Be the last to make a move to win!"
    end
end

--Logic for game
function Game(key, scancode, isrepeat) 
    --Restart
   if key == "r" then
        local root = startNode:FindRoot()
        root:Delete()
        startNode = nil
        Node:New()
        collectgarbage()
        playing = false
        startAmount = 7
        
        debugMsg = "Choose Start Amount, [Up] and [Down], then [Enter to confirm]"
    end
    
    --If player turn, then allow controls
    if playerTurn then
        --stack selection stuff
        if key == "right" then
            playerAmount = 1
            playerChoice = playerChoice + 1
            if not startNode.stacks[playerChoice] then playerChoice = 1 end
        end
        
        if key == "left" then
            playerAmount = 1
            playerChoice = playerChoice - 1
            if playerChoice < 1 then playerChoice = #startNode.stacks end
        end
        
        if key == "up" then
            playerAmount = playerAmount + 1
            if startNode.stacks[playerChoice] < playerAmount then playerAmount = startNode.stacks[playerChoice] end
        end
        
        if key == "down" then
            playerAmount = playerAmount - 1
            if playerAmount < 1 then playerAmount = 1 end
        end
        
        --Try split chosen stack
        if key == "return"  then
            PlayerTurn()
        end            
    end 
end

function love.update(dt)
    if playing then
        if not playerTurn then
            AITurn() 
        end
        
        if #startNode.children <= 0 then
            if playerTurn then debugMsg = "AI Won!\nPress [R] to restart" else debugMsg = "Player Won!\nPress [R] to restart" end
        end
    end
end

function love.draw()
    if playing then
        DrawStacks()
    else
        DrawMenu()
    end
    
    local offset = 0
    if playing then offset = 90 else offset = 0 end
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(startInstruct, 10, 10 - offset, love.graphics.getWidth() - 20, 'right')
    love.graphics.printf(instruct, 10, 100 - offset, love.graphics.getWidth() - 20, 'right')
    
    love.graphics.setColor(0, 1, 1, 1)
    love.graphics.printf(debugMsg, 10, 200 - offset, love.graphics.getWidth() - 20, 'right')
end

--Draw any relevant info for menu
function DrawMenu()
    love.graphics.setColor(0, 1, 0, 1) 
    for i=1, startAmount do
        love.graphics.rectangle("fill", 
                    10, 
                    love.graphics.getHeight() - math.min(((love.graphics.getHeight()-10) / (startAmount)) , 60) * (i), 
                    50, 
                    math.min((love.graphics.getHeight()-10) / (startAmount * 1.2), 50))
    end
    
    if playerFirst then debugMsg = "PLAYER is going first." else debugMsg = "AI is going first." end
    if difficulty == 1 then 
        debugMsg = debugMsg .. "\nEasy Difficulty" 
    elseif difficulty == 2 then 
        debugMsg = debugMsg .. "\nMedium Difficulty" 
    else
        debugMsg = debugMsg .. "\nHard Difficulty" 
    end
end

--Draw current stacks on screen, with selection
function DrawStacks()
    local numTall = startNode.stacks[1]
    local numWide = #startNode.stacks
    
    for k, s in pairs(startNode.stacks) do 
        for i=1, s do
            if k == playerChoice and i <= playerAmount then love.graphics.setColor(0, 1, 0, 1) 
            else love.graphics.setColor(1, 0, 0, 1) end
            
            love.graphics.rectangle("fill", 
                math.min(((love.graphics.getWidth()-10) / (numWide)) , 60) * (k-1) + 10, 
                love.graphics.getHeight() - math.min(((love.graphics.getHeight()-10) / (numTall)) , 60) * (i), 
                math.min((love.graphics.getWidth()-10) / (numWide * 1.2), 50), 
                math.min((love.graphics.getHeight()-10) / (numTall * 1.2), 50))
        end
    end 
end
