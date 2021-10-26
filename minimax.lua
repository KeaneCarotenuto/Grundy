-- Bachelor of Software Engineering
-- Media Design School
-- Auckland
-- New Zealand
-- 
-- (c) 2021 Media Design School
--
-- File Name   : minimax.lua
-- Description : Logic for the minimax algo, with alpha beta pruning. Manages the AI.
-- Author      : Keane Carotenuto
-- Mail        : KeaneCarotenuto@gmail.com

function ABPrune(_node, _depth, alpha, beta, isMaxi) 
    if (#_node.children == 0) then _node:FindChildren(false) end
	--If end node, return value
	if (_depth == 0 or #_node.children == 0) then
		if isMaxi then _node.score = -100
        else _node.score = 100 end
        return _node.score
	end

	--If is maximiser
	if isMaxi then
		--Set really low
		local value = -10000

		--For each child
        for k,_child in pairs(_node.children) do
			local tempVal = ABPrune(_child, _depth - 1, alpha, beta, not isMaxi);
			value = math.max(value, tempVal)
			alpha = math.max(alpha, value)

			if beta <= alpha then
				break
			end
		end
		--Return value and best choice is set
		_node.score = value
		return value
	else
		--set really high
		local value = 10000;

		for k,_child in pairs(_node.children) do
			local tempVal = ABPrune(_child, _depth - 1, alpha, beta, true)
			value = math.min(value, tempVal)
			beta = math.min(beta, value)

			if beta <= alpha then
				break
			end
		end
		--Return value and best choice is set
		_node.score = value
		return value;
	end
    
end

--Perform turn based on difficulty
function AITurn()
    if difficulty == 1 then             --ez
        DoRandomTurn()
    elseif difficulty == 2 then
        if math.random(1,2) == 1 then   --med
            DoSmartTurn() 
        else
            DoRandomTurn()
        end
    else                                --hard
        DoSmartTurn() 
    end
end

--Chooses a random move to make if possible
function DoRandomTurn()
    --generate children if none
    if (#startNode.children == 0) then startNode:FindChildren(false) end
    
    --pick random
    if #startNode.children > 0 then
        local randNum = math.random(1, #startNode.children)
        debugMsg = ("AI made move:\n" .. table.concat(startNode.stacks, ",") .. " -> " .. table.concat(startNode.children[randNum].stacks, ","))
        startNode = startNode:BecomeChild(randNum)
        if (#startNode.children == 0) then startNode:FindChildren(false) end
        playerAmount = 1
        playerChoice = 1
        playerTurn = true 
    end
end

--Uses minimax with AB prune to make best move
function DoSmartTurn() 
    --Make tree and get best scores
    local returnval = ABPrune(startNode, 1000, -10000, 10000, true)
    
    local madeMove = false
    
    --check which child has the best score, then become that child
    for i = 1, #startNode.children, 1 do
        if startNode.children[i].score == startNode.score then
            madeMove = true
            table.sort(startNode.children[i].stacks, function(a, b) return a > b end)
            debugMsg = ("AI made move:\n" .. table.concat(startNode.stacks, ",") .. " -> " .. table.concat(startNode.children[i].stacks, ","))
            startNode = startNode:BecomeChild(i)
            playerAmount = 1
            playerChoice = 1
            playerTurn = true 
            break
        end
    end
    
    if (not madeMove) then debugMsg = ("AI cannot make a move.") end 
end