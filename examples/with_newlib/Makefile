CROSSCOMPILE=/comelec/softs/opt/gnu_tools_for_or1k/bin/or1k-elf-
LD=$(CROSSCOMPILE)ld
CC=$(CROSSCOMPILE)gcc

CFLAGS = -g -Wall -O2 -mboard=de2

EXE = hello
OBJS = hello.o

all: $(EXE)

$(EXE): hello.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(OBJS) $(EXE) *~
