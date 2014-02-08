CC=gcc
CFLAGS=-g -O2 -Wall

all: test_accent an fw
	./test_accent

test_accent: test_accent.o accent.o

an: an.o accent.o

fw: fw.o accent.o

clean:
	rm *.o test_accent an fw
