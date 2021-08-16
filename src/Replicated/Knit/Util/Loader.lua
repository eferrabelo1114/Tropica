-- Loader
-- Stephen Leitnick
-- January 10, 2021

--[[

	Loads all ModuleScripts within the given parent.

	Loader.LoadChildren(parent: Instance): module[]
	Loader.LoadDescendants(parent: Instance): module[]

--]]
local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()


local Loader = {}


function Loader.LoadChildren(parent)
	local modules = {}
	for _,child in ipairs(parent:GetChildren()) do
		if (child:IsA("ModuleScript")) then
			local m = require(child)
			table.insert(modules, m)

			if isClient then
				print("[CLIENT] Loaded "..child.Name)
			else
				print("[SERVER] Loaded "..child.Name)
			end

		end
	end
	return modules
end


function Loader.LoadDescendants(parent)
	local modules = {}
	for _,descendant in ipairs(parent:GetDescendants()) do
		if (descendant:IsA("ModuleScript")) then
			local m = require(descendant)
			table.insert(modules, m)
		end
	end
	return modules
end


return Loader
