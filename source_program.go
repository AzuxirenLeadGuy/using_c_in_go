package main

import "fmt"

// #include "lib/add_safe.c"
// #include "lib/sub_safe.c"
// #include "lib/magic_number.c"
import "C"

func main(){
	fmt.Println("Now running go program compiled with source code...")
	x := C.magic_number()
	fmt.Printf("Obtained magic number:%d\n", x)
	res := C.add_safe(x, x)
	fmt.Printf("Answer is %d, with valid flag %d\n", res.answer, res.invalid)
	res = C.sub_safe(x, x)
	fmt.Printf("Answer is %d, with valid flag %d\n", res.answer, res.invalid)
}
