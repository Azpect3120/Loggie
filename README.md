# Loggie


## Notes for Building

If you plan to build this project, you will need to update the imports in the `./src/libs/zig-time/time.zig` file.
The import statements will not properly import the files required from the `zig-extra` module. The following import 
statements can be used.

```zig
const std = @import("std");
const string = []const u8;
// This is the only one that needs to be updated
const extras = @import("../zig-extras/src/TagNameJsonStringifyMixin.zig"); 
const time = @This();
```
