local process = require("@lune/process")
local stdio = require("@lune/stdio")
local gt = require("./lune_packages/greentea")

local stringType = gt.build(gt.string())
local booleanType = gt.build(gt.boolean())
local optionalStringArrayType = gt.build(gt.opt(gt.array(gt.string())))
local optionalBooleanType = gt.build(gt.opt(gt.boolean()))

--[=[
	Spawns a child process that will run the program `program`, and returns a dictionary that describes the final status and ouput of the child process.

	The second argument, `params`, can be passed as a list of string parameters to give to the program.

	The third argument, `options`, can be passed as a dictionary of options to give to the child process.
	Refer to the documentation for `SpawnOptions` for specific option keys and their values.

	@param program The program to spawn as a child process
	@param pesdePackage The package to run if the program is not found
	@param warnIfProgramIsNotFound Whether to warn if the program is not found
	@param params Additional parameters to pass to the program
	@param options A dictionary of options for the child process
	@return A dictionary representing the result of the child process
]=]
return function(
	program: typeof(stringType:type()),
	pesdeBinaryPackage: typeof(stringType:type()),
	warnIfProgramIsNotFound: typeof(booleanType:type()),
	params: typeof(optionalStringArrayType:type()),
	inherit: typeof(optionalBooleanType:type())
): process.SpawnResult
	stringType:assert(program)
	stringType:assert(pesdeBinaryPackage)
	booleanType:assert(warnIfProgramIsNotFound)
	optionalStringArrayType:assert(params)
	optionalBooleanType:assert(inherit)

	-- TODO: Add support for options after pesde 0.6
	local options: process.SpawnOptions? = if inherit
		then {
			stdio = "inherit",
		}
		else nil
	local ok, result = pcall(process.spawn, program, params, options)
	if ok and (result and result.ok and result.stderr == "") then -- remove stderr check after pesde 0.6
		return result
	end

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
	if warnIfProgramIsNotFound then
		-- if options then
		-- 	options.stdio = options.stdio or "forward"
		-- else
		-- 	options = { stdio = "forward" }
		-- end
		print(
			`[{stdio.color("yellow")}WARNING{stdio.color("reset")}] Using 'pesde x'. Just a heads-up: the program '{program}' wasn't found. For a smoother experience, you might consider installing it.`
		)
	end
	return process.spawn("pesde", args, options)
end
