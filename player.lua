-- Bachelor of Software Engineering
-- Media Design School
-- Auckland
-- New Zealand
-- 
-- (c) 2021 Media Design School
--
-- File Name   : player.lua
-- Description : Behaviour for player turns, and player vars
-- Author      : Keane Carotenuto
-- Mail        : KeaneCarotenuto@gmail.com

playerChoice = 1
playerAmount = 1

playing = false

startAmount = 7
playerFirst = false
difficulty = 1

playerTurn = false

--Logic for the player entering a move
function PlayerTurn()
    local validMove = false
    
    --copy current stacks
    local tempStacks = table.shallow_copy(startNode.stacks)
    --replace chosen stack with new split stack
    tempStacks[playerChoice] = tempStacks[playerChoice] - playerAmount
    --add on other bit of split stack
    table.insert(tempStacks, playerAmount)
    --sort to check later
    table.sort(tempStacks, function(a, b) return a > b end)
    
    --check if any child stacks are the same as current stack, if so, become that, otherwise, invalid move
    for k, c in pairs(startNode.children) do
        local allSame = true
        table.sort(c.stacks, function(a, b) return a > b end)
        if table.concat(c.stacks) ~= table.concat(tempStacks) then
            allSame = false
            goto continue
        end
        
        if allSame then 
            validMove = true
            startNode = startNode:BecomeChild(k)
            playerTurn = false
            break
        end
        ::continue::
    end 
    if (not validMove) then debugMsg = ("Invalid Move") end
    if (#startNode.children == 0) then startNode:FindChildren(false) end
end