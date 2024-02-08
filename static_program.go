package main

import "fmt"

// #cgo LDFLAGS: -L'static_lib' -lfoobar
// #include "lib/foobar.h"
import "C"

func main(){
	fmt.Println("Now running go program (compiled with static C library)")
	x := C.magic_number()
	fmt.Printf("Obtained magic number:%d\n", x)
	res := C.add_safe(x, x)
	fmt.Printf("Answer is %d, with valid flag %d\n", res.answer, res.invalid)
	res = C.sub_safe(x, x)
	fmt.Printf("Answer is %d, with valid flag %d\n", res.answer, res.invalid)
}
