local pesdeExec = require("../")

local result = pesdeExec(
	"darklua",
	{"--version"},
	true
)

print("result:", result)
