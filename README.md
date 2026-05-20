Under development to create a wrapper for a client and a server. Currently, all functionality is imported, yielding a very huge binary when compiled. We are going to minimize the binary size by only importing required files from open62541. In the future, this may be extended to fully make OPC UA library in Zig.

See build.zig and examples to see how to use the library. 

## Things to note
In open62541, when you are referring a datatype, usually we use 
```c
UA_TYPES[UA_TYPES_XXX]
```

Since UA_DataType is translated as opaque, this convention cannot be used anymorer. To have similar output, use
```zig
import zigopc = @import("zigopc");
import open62541 = zigopc.c;

open62541.UA_DataType_get(open62541.UA_TYPES_INT32);
```
