# Compiling go with C libraries

This repository is for showcasing the steps for compilation of go programs with a sample C library.

## Cgo

Cgo allows using C code in a Go program. Regardless of which way you compile your go program, you will need to (at least) load the declarations of functions and structures from the header files. Cgo allows to use pure C code in comments(yuck!) and compile the program. Using Cgo also makes use of a C compiler (such as clang or gcc) which must be available on the machine.

Thus, to use a C library in a Go program, it is important to understand the compilation process in C as well.

## Types of compilation

Compilation can be done either using only source code, or using pre-compiled library like a static or shared library. This tutorial showcases all 3 mentioned approaches for the same C library in this repository.

A simple C library is given as an example in the folder `lib` as shown.

```
lib
├── foobar.h
├── add_safe.c
├── magic_number.c
└── sub_safe.c
```

The header file `foobar.h` contains all the functions and structures that can be accessed by a project that would use this library. There are 3 functions described in this header file, whose implementation are provided in the files `add_safe.c`, `sub_safe.c` and `magic_number.c`.

### Source compilation

The most straight-forward way of compilation of this library would be to compile a program that includes the header file, and compile all the C source files along with it. Such an example of a C program is provided in the file `program.c` in this repository. It can be compiled using a C compiler like `gcc` or `clang` as 

```
gcc -o bin/source_cc_program.out program.c ./lib/*.c
```

Needless to say, we invoke the C compiler (gcc in this case), create an executable file `bin/source_cc_program.out`, which is prepared with the source code in `program.c` and `./lib/*.c` (which are all the files with extension .c in the `lib` folder)


The `program.c` file includes only the header file, and by providing all the other C files of the library, and thus, the C compiler can successfully link all the functions used in the program.

With a similar approach, we can make a go program that includes all the C files within the library as shown in `source_program.go`

```go
// #include "lib/add_safe.c"
// #include "lib/sub_safe.c"
// #include "lib/magic_number.c"
import "C"
```
This enables the usage of C source files by including all the C source files. This go program can be compiled as shown

```
go build -o bin/source_go_program.out source_program.go
```

---

### Compilation with a static library

A static C library is a pre-compiled object file. This static library file can be later passed to the C compiler to link and create an executable that uses the library. So instead of providing the compiler with the C source files, we provide it with the pre-compiled objects (that is the static library).

Thus, the static library is compiled first, and in the next step it is compiled with the C program to prepare an executable. This can be helpful, since any changes made in the program that uses the library will not require the recompilation of the entire library; rather only the program file. This is especially helpful when working with a large library.

To prepare a static library for the example in this repository, we use the -c flag to prepare the object files as shown

```
gcc -c lib/*.c 
```

This will prepare object files (with extension `.o`) to be created for each file. While these object files can also be passed to the C compiler, we typically prefer to create an a single archive for combining the multiple object files into a single file. The linux utility `ar` is used to create an archive as shown.

```
ar rcs libfoobar.a ./*.o
```

This will use the `ar` utility to make an archive of all the object files into a single file called `libfoobar.a`. Note the convention followed for the naming is `lib<name>.a`. This convention is followed by most compilers. For this example, we will move this `libfoobar.a` file into a folder `static_lib`.

```
static_lib
└── libfoobar.a
```

This is the static library that can be used by the C compiler as well as the go compiler to create an executable. For the same `program.c` as used in previously, we use the following to create an executable.

```
gcc -o ./bin/static_cc_program.out program.c -L'./static_lib' -lfoobar
```

Here, the compiler creates an executable `./bin/static_cc_program.out`, which is made with the source code `program.c`, and the following link instructions.

- **Set the folder to load the link files as `./static_lib` :** This is provided using the `-L` flag. Note the uppercase flag and no space between the flag and the folder path.
- **Use the library `foobar`** : By following the convention, the compiler looks for a file `libfoobar.a`. This is indicated with the `-l` flag. Again, note the case (lowercase this time), and no space between the flag(`-l`) and the library name(foobar). Also, note that although the actual static library created is `libfoobar.a`, we only specify the name foobar with the -l flag. In general, for any library `<name>`, the convention is to make a static library `lib<name>.a`, and specify it with the flag `-l<name>` 

These same conventions are also applied in go for static linkage of a go program, and can be seen in the program `static_program.go`. Compared with the previous go code, this file is identical, except here only the header file is loaded, and rest of the link instructions is provided in `LDFLAGS` as shown

```go

// #cgo LDFLAGS: -L'shared_lib' -lfoobar
// #include "lib/foobar.h"
import "C"
```

### Compilation with a shared library

We can also use a shared library in a similar fashion. A shared library is loaded by the program at runtime, whereas the static library gets compiled within the executable. Thus, when comiling an executable that depends on a shared library, it is required to specify within the program the shared library being loaded by the program. The executable is also required to be able to load the shared library file when it is running.

Thus, the instructions of the shared library is not present within the compiled executable file, (apart from the function callsand other metadata of the library). This can allow the executable file size to remain smaller compared to a statically compiled executable. Shared libraries are especially useful as it allowes saving space for multiple program that uses the same shared library. It also allows the updation of library to be done (by simply replacing the old shared library with the new one), without affecting the executables (as long as all the function calls remain consistent).

To compile a shared library file for the example code in the repository, we again generate the object files for each C file, passing the `-fPIC` flag as shown.

```
gcc -fPIC -c ./lib/*.c
```

This will prepare the object files. Next, all the object files are compiled into into a single shared library using the following

```
gcc -o libfoobar.so -shared ./*.o 
```

The above command creates a shared library `libfoobar.so` using all the object files. For this example, we will move this library into the folder `shared_lib`

```
shared_lib
└── libfoobar.so
```

The conventions used in making a static library also comes in play here. Thus, to prepare an executable in C that uses this shared library, we use the following

```
gcc -o bin/shared_cc_program.out program.c -L'./shared_lib' -lfoobar
```

As discussed in prepration of static libraries, the same conventions applies here. The C compiler can figure out whether or not the linked library is a shared or a static library, and prepares the executable as desired.

To run the executable the `libfoobar.so` file must be available to the program to link at the runtime. Running the shared executable with specifying this will result in an error as shown.

```
$ ./bin/shared_cc_program.out
./bin/shared_cc_program.out: error while loading shared libraries: libfoobar.so: cannot open shared object file: No such file or directory
```

The folder of the shared libraries can be provided in linux using the environment variable `LD_LIBRARY_PATH`. Setting this and running the program now runs as expected.

```
$ LD_LIBRARY_PATH=./shared_lib ./bin/shared_cc_program.out
Running C program (this could be compiled with source/shared/static library)...

On adding 2 and 3, obtained answer 5 with valid 0

On subtracting 2 and 3, obtained answer 32543 with valid 1
```

To link the shared library in a go program, the example is virtually unchanged from the go program that linked with the static library, apart from the parent directory. The load flags are similar as it follows the same convention. Building the executable from the go program is unchanged as before

```
go build -o ./bin/shared_go_program.out shared_program.go
```

Needless to say, running this go program requires to specify the `libfoobar.so` file. It can be done by setting the `LD_LIBRARY_PATH` environment variable as shown

```
$ LD_LIBRARY_PATH=./shared_lib ./bin/shared_go_program.out
Now running go program (compiled with shared C library)
Obtained magic number:42
Answer is 84, with valid flag 0
Answer is 32571, with valid flag 1
```

---

## Understanding the provided Makefile

The Makefile consists of the following commands

- `make static` : Compiles the static C library
- `make shared` : Compiles the shared C library
- C executable
    - `make c-source` : Compiles the executable for a C program that is linked with the source code of the library
    - `make c-static` : Compiles the executable for a C program using the static library
    - `make c-shared` : Compiles the executable for a C program using the shared library
- Go executable
    - `make go-souce` : Compiles the executable for a Go program that is linked with the source code of the C library
    - `make go-static` : Compiles the executable for a go program linked with the static C library
    - `make go-shared` : Compiles the executable for a gor program linked with the shared C library
- Others:
    - `make all` : Compiles all the files listed above
    - `make clean`: Deletes all the built files
- Running programs:
    - `make run-c-source`
    - `make run-c-static`
    - `make run-c-shared`
    - `make run-go-source`
    - `make run-go-static`
    - `make run-go-shared`

## Further reading

The following blogs by the official golang team will be helpful

- [cgo documentation](https://pkg.go.dev/cmd/cgo)
- [C? Go? Cgo!](https://go.dev/blog/cgo)