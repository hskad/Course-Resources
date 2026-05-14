ROLL = 230101123
LEX_FILE  = a4_$(ROLL).l
YACC_FILE = a4_$(ROLL).y
TEST_FILE = a4_$(ROLL)_test.nc

CC      = gcc
CFLAGS  = -w

.PHONY: all clean run

all: a.out

y.tab.c y.tab.h: $(YACC_FILE)
	yacc -d $(YACC_FILE)

lex.yy.c: $(LEX_FILE) y.tab.h
	flex $(LEX_FILE)

a.out: lex.yy.c y.tab.c
	$(CC) $(CFLAGS) lex.yy.c y.tab.c -lfl -o a.out

run: a.out
	./a.out < $(TEST_FILE)

clean:
	rm -f lex.yy.c y.tab.c y.tab.h a.out
