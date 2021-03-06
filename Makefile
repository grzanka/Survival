# Makefile: use this to create the executable (Linux and MacOS X)

EXE = survival

CC = g++
CCFLAGS = -O3 -Wall -W -fopenmp -std=c++11

INCLUDE = ./include
EXT_INCLUDE = ./ext_include/gsl ./ext_include/omp
INCLUDE_PATHS = $(foreach d, $(INCLUDE), -I$d) $(foreach e, $(EXT_INCLUDE), -I$e)

EXT_LIB = ./ext_lib/
LDFLAGS = $(foreach e, $(EXT_LIB), -L$e) -lgsl -lgslcblas -lm

SRC = ./src
BIN = ./

ifeq ($(OS),Windows_NT)
    CCFLAGS += -D WIN32
    ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
        CCFLAGS += -D AMD64
    endif
    ifeq ($(PROCESSOR_ARCHITECTURE),x86)
        CCFLAGS += -D IA32
    endif
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        CCFLAGS += -D LINUX
    endif
    ifeq ($(UNAME_S),Darwin)
        CCFLAGS += -D OSX
    endif
    UNAME_P := $(shell uname -p)
    ifeq ($(UNAME_P),x86_64)
        CCFLAGS += -D AMD64
    endif
    ifneq ($(filter %86,$(UNAME_P)),)
        CCFLAGS += -D IA32
    endif
    ifneq ($(filter arm%,$(UNAME_P)),)
        CCFLAGS += -D ARM
    endif
endif


.PHONY : all clean

all : $(BIN)/$(EXE)

debug : CCFLAGS += -g
debug : $(BIN)/$(EXE)

clean :
	@rm -f $(SRC)/*.o *~ $(BIN)/$(EXE) $(BIN)/dep.mk

ifeq (,$(findstring $(MAKECMDGOALS),clean))
-include dep.mk
endif

dep.mk : $(SRC)/*.cpp $(INCLUDE)/*.h
	$(CC) -MM $(INCLUDE_PATHS) $(SRC)/*.cpp > dep.mk
	
$(BIN)/$(EXE) : $(SRC)/main.o $(SRC)/Particles.o $(SRC)/Tracks.o $(SRC)/Track_Scholz2000.o $(SRC)/Track_Elsasser2007.o $(SRC)/Track_Elsasser2008.o $(SRC)/Track_KieferChatterjee.o $(SRC)/CellLine.o $(SRC)/Nucleus_Pixel.o $(SRC)/Nucleus_Integral.o $(SRC)/Nucleus_MonteCarlo.o $(SRC)/Nucleus_MKM.o $(SRC)/Calculus.o $(SRC)/Nucleus_tMKM.o $(SRC)/Nucleus_Integral_t.o $(SRC)/usefulFunctions.o
	$(CC) $(CCFLAGS) $(INCLUDE_PATHS) $^ $(LDFLAGS)  -o $@

%.o : %.cpp
	$(CC) $(CCFLAGS) $(INCLUDE_PATHS) -c $< -o $@

