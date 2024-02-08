# The compiler to use for C
CC=clang

# The executable paths for programs compiled with C and Golang
CC_SOURCE=./bin/source_cc_program.out
CC_STATIC=./bin/static_cc_program.out
CC_SHARED=./bin/shared_cc_program.out
GO_SOURCE=./bin/source_go_program.out
GO_STATIC=./bin/static_go_program.out
GO_SHARED=./bin/shared_go_program.out

# Path at which the object files are generated
OBJ_FILES=./*.o

# The path for storing the static library
STATIC_LIB=static_lib/libfoobar.a

# The directory for storing shared library
SHARED_DIR=./shared_lib

# The path for storing the shared library
SHARED_LIB=$(SHARED_DIR)/libfoobar.so

# The path of C source code
MAIN_C=program.c
LIB_H=lib/foobar.h
LIB_C=lib/*.c

#The path of Golang source code
MAIN_GO_SOURCE=source_program.go
MAIN_GO_STATIC=static_program.go
MAIN_GO_SHARED=shared_program.go

.PHONY: all clean go-shared go-static go-source c-shared c-static c-source run-go-shared run-go-static run-go-source run-c-shared run-c-static run-c-source static-lib shared-lib

all: c-shared c-static c-source go-shared go-static go-source 

clean:
	rm -f $(OBJ_FILES) $(STATIC_LIB) $(SHARED_LIB) $(CC_SHARED) $(CC_STATIC) $(CC_SOURCE) $(GO_SHARED) $(GO_STATIC) $(GO_SHARED) $(GO_SOURCE)

static: $(STATIC_LIB)

$(STATIC_LIB): $(LIB_H) $(LIB_C)
	mkdir -p static_lib && $(CC) -c $(LIB_C) && ar rcs $(STATIC_LIB) $(OBJ_FILES) ; rm $(OBJ_FILES)

shared: $(SHARED_LIB)

$(SHARED_LIB): $(LIB_H) $(LIB_C)
	mkdir -p shared_lib && $(CC) -c -fPIC $(LIB_C) && $(CC) -shared -o $(SHARED_LIB) $(OBJ_FILES) ; rm $(OBJ_FILES)

bin:
	mkdir -p bin

run-c-source: $(CC_SOURCE)
	$(CC_SOURCE)

c-source: $(CC_SOURCE)

$(CC_SOURCE): $(MAIN_C) bin
	$(CC) -o $(CC_SOURCE) $(MAIN_C) $(LIB_C)

run-c-static: $(CC_STATIC)
	$(CC_STATIC)

c-static: $(CC_STATIC)

$(CC_STATIC): static $(MAIN_C) bin
	$(CC) -o $(CC_STATIC) $(MAIN_C) -L'./static_lib' -lfoobar

run-c-shared: $(CC_SHARED)
	LD_LIBRARY_PATH=$(SHARED_DIR) $(CC_SHARED)

c-shared: $(CC_SHARED)

$(CC_SHARED): shared $(MAIN_C) bin
	$(CC) -o $(CC_SHARED) $(MAIN_C) -L'./shared_lib' -lfoobar

run-go-source: $(GO_SOURCE)
	$(GO_SOURCE)

go-source: $(GO_SOURCE)

$(GO_SOURCE): $(MAIN_GO_SOURCE) bin
	go build -o $(GO_SOURCE) $(MAIN_GO_SOURCE)

run-go-static: $(GO_STATIC)
	$(GO_STATIC)

go-static: $(GO_STATIC) 

$(GO_STATIC): static $(MAIN_GO_STATIC) bin
	go build -o $(GO_STATIC) $(MAIN_GO_STATIC)

run-go-shared: $(GO_SHARED)
	LD_LIBRARY_PATH=$(SHARED_DIR) $(GO_SHARED)

go-shared: $(GO_SHARED) 

$(GO_SHARED): shared $(MAIN_GO_SHARED) bin
	go build -o $(GO_SHARED) $(MAIN_GO_SHARED)
