-- Bachelor of Software Engineering
-- Media Design School
-- Auckland
-- New Zealand
-- 
-- (c) 2021 Media Design School
--
-- File Name   : node.lua
-- Description : Controls behaviour of the node based system of storing moves
-- Author      : Keane Carotenuto
-- Mail        : KeaneCarotenuto@gmail.com

Node = {parent = nil, children = {}, stacks = {}, score = 0}

function Node:New (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Node:AddChild (_child)
    table.insert(self.children, _child)
end

--Deletes all children and values down the tree, then sets self to nil
function Node:Delete()
    --call delete on all children once
    for k, v in pairs(self.children) do
        if v then v:Delete() end
        v = nil
    end
    
    --remove all children
    while #self.children > 0 do
        table.remove(self.children, 1)
    end

    --set own meta table to nil, properly delete it
    setmetatable(self, nil)
end

--Searches for the root parent
function Node:FindRoot()
    
   if (self.parent == nil) then
       return self
   else
       return self.parent:FindRoot()
   end
end

--Creates all of the immediate children
function Node:FindChildren (_isMaxi)
    local foundValid = false;

    for k,v in pairs(self.stacks) do
        if v > 2 then
            foundValid = true
            local num = 1
            while v < (v - num)*2 do
                local childNode = Node:New()
                childNode.stacks = {}
                childNode.children = {}
                childNode.parent = self
                table.insert(childNode.stacks, v - num)
                table.insert(childNode.stacks,num)
                
                for key,val in pairs(self.stacks) do
                    if key ~= k then table.insert(childNode.stacks,val) end
                end
                
                self:AddChild(childNode)
                --Dont do this anymore, but used to create entire tree. Now tree is dynamically created when AB prune needs it
                --childNode:FindChildren(not _isMaxi)
                num = num + 1
            end
        end
    end

    if not foundValid then
        return
    end
end

--Replace this node with a child node
function Node:BecomeChild(_childIndex)
    if self.children[_childIndex] ~= nil then
       return self.children[_childIndex]
    end
end

--Prints out the tree in console
local space = " "
function Node:Print
    ()
    print("Stacks: ")
    for index, stackVal in pairs (self.stacks) do
        print(space .. stackVal)
    end
    space = space .. "|"
    
    for k, v in pairs(self.children) do
        v:Print()
    end
    
    space = space:sub(1, -2)
end

--Print out possible options in console
function PrintOptions(_node)
    print("Current Stack: ")
    local printString = ""
    for k, s in pairs(_node.stacks) do printString = printString .. s .. " " end
    print(printString)
    
    print("Children Stacks: ")
    for k, c in pairs(_node.children) do
        local printString = ""
        for k, s in pairs(c.stacks) do printString = printString .. s .. " " end
        print(printString)
    end 
end