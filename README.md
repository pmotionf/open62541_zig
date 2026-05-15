Under development to create a wrapper for a client and a server. Translate the OPC UA library to zig by the following

``` 
zig translate-c vendor/OPC_types_helper.h --library c > generated.zig
```

Current workflow requires generated.zig to be put inside src.

TODO: Make this repo as a library so that it is easily used by other program.
