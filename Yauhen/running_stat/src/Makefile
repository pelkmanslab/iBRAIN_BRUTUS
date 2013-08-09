CC=g++
CFLAGS=-c -Wall
LDFLAGS=
SOURCES=running_stat.cc
OBJECTS=$(SOURCES:.cc=.o)
EXECUTABLE=test_rs

all: $(SOURCES) $(OBJECTS) $(EXECUTABLE)

.cc.o:
		$(CC) $(CFLAGS) $< -o $@

clean:
		rm -rf *.pyc *.so *.o a.out* *.mex* test_rs

