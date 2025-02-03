# pesde-exec
pesde x + process.exec

## Usage
```luau
local pesdeExec = require("../")

local result = pesdeExec(
	"darklua",
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
