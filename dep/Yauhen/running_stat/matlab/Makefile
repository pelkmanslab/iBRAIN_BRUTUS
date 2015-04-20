CC=mex
CFLAGS=-c -I ../src
LDFLAGS=-L ../src
SOURCES=running_stat_update.cc
OBJECTS=$(SOURCES:.cc=.o)

all: $(SOURCES) matlab

matlab: $(OBJECTS)
		
.cc.o:
		$(CC) $<

clean:
		rm -rf *.pyc *.so *.o a.out* *.mex*

