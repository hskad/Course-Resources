ROLL = 230101123
LEX_FILE = a3_$(ROLL).l
TEST_FILE = a3_$(ROLL)_test.nc
TOKEN_OUT = a3_$(ROLL)_token.txt
ST_OUT    = a3_$(ROLL)_st.txt

all: lexer

lexer: $(LEX_FILE)
	flex $(LEX_FILE)
	gcc lex.yy.c -lfl -o lexer

run: lexer
	./lexer $(TEST_FILE)

clean:
	rm -f lex.yy.c lexer $(TOKEN_OUT) $(ST_OUT)
