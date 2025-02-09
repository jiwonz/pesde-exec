local process = require("@lune/process")
local gt = require("../lune_packages/greentea")
local pathfs = require("../lune_packages/pathfs")
local serde = require("@lune/serde")

local stringType = gt.build(gt.string())
local optionalStringArrayType = gt.build(gt.opt(gt.array(gt.string())))

local PESDE_ROOT: string? = _G.PESDE_ROOT
if not PESDE_ROOT then
	error("PESDE_ROOT not found. Are you running through pesde?")
end

local optionalOptionsType = gt.build(gt.opt(gt.anyTable()))

--[=[
	Spawns a child process that will run the program `program`, and returns a dictionary that describes the final status and ouput of the child process.

	The second argument, `params`, can be passed as a list of string parameters to give to the program.

	The third argument, `options`, can be passed as a dictionary of options to give to the child process.
	Refer to the documentation for `SpawnOptions` for specific option keys and their values.

	@param peerDependencyProgram -- peerDependencyProgram The program to spawn as a child process. must be a peer dependency
	@param params -- params Additional parameters to pass to the program
	@param options -- options A dictionary of options for the child process
	@return SpawnResult -- A dictionary representing the result of the child process

	### Example
	#### `pesde.toml`
	```toml
	[peer_dependencies]
	darklua = { name = "pesde/darklua", version = "x.x.x" }
	```
	#### `example.luau`
	```lua
	local result = spawn("darklua", {"arg1", "arg2"}, {})
	```
]=]
return function(
	peerDependencyProgram: typeof(stringType:type()),
	params: typeof(optionalStringArrayType:type()),
	options: typeof(optionalOptionsType:type())
): process.SpawnResult
	stringType:assert(peerDependencyProgram)
	optionalStringArrayType:assert(params)
	optionalOptionsType:assert(options)

	local ok, result = pcall(process.spawn, peerDependencyProgram, params, options)
	if ok and (result and result.ok) then
		return result
	end

	local pesdeToml = pathfs.findFile(pathfs.Path.from(PESDE_ROOT):join("pesde.toml"))
	if not pesdeToml then
		error("pesde.toml not found")
	end
	-- selene: allow(shadowing)
	local pesdeToml: {
		peer_dependencies: {
			[string]: {
				name: string?,
				version: string?,
			}?,
		}?,
	} =
		serde.decode("toml", pesdeToml:readFile())
	if not pesdeToml.peer_dependencies then
		error("peer dependencies not found in pesde.toml")
	end
	local peerDependency = pesdeToml.peer_dependencies[peerDependencyProgram]
	if not peerDependency then
		error("peer dependency not found in pesde.toml")
	end
	if not peerDependency.name then
		error("peer dependency name not found in pesde.toml")
	end
	if not peerDependency.version then
		error("peer dependency version not found in pesde.toml")
	end
	local pesdeBinaryPackage = peerDependency.name .. "@" .. peerDependency.version

	local args = {
		"x",
		pesdeBinaryPackage,
	}
	if params and #params > 0 then
		table.insert(args, "--")
		for _, v in params do
			table.insert(args, v)
		end
	end
	return process.spawn("pesde", args, options)
end
