local pesdeExec = require("../")

local result = pesdeExec(
	"darklua",
	"pesde/darklua@0.16.0",
	true,
	{"--version"},
	false
)

print("result:", result)
