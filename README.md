# pesde-exec
pesde x + process.exec

## Usage
```luau
local pesdeExec = require("../")

local result = pesdeExec(
	"darklua",
	"pesde/darklua@0.16.0",
	true,
	{"--version"},
	false
)

print("result:", result)

```

## Installation
via pesde
```sh
> pesde add jiwonz/pesde_exec -t lune
> pesde install
```
