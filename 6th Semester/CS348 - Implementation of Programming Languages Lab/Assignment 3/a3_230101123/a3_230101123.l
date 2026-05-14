%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Output files */
FILE *token_file;
FILE *st_file;

int line_num = 1;

/* ---- Symbol Table ---- */
#define MAX_SYMBOLS 1000
char symbol_table[MAX_SYMBOLS][100];
int sym_count = 0;

/* Returns index if found, -1 otherwise */
int lookup(const char *name) {
    for (int i = 0; i < sym_count; i++) {
        if (strcmp(symbol_table[i], name) == 0)
            return i;
    }
    return -1;
}

/* Inserts identifier if not already present */
void insert(const char *name) {
    if (lookup(name) == -1) {
        strncpy(symbol_table[sym_count], name, 99);
        sym_count++;
    }
}
%}

/* ---- Definitions ---- */
DIGIT       [0-9]
NONZERO     [1-9]
LETTER      [a-zA-Z]
ID          [a-zA-Z_][a-zA-Z0-9_]*

INT_CONST   {NONZERO}{DIGIT}*
FRAC_CONST  ({DIGIT}*"."{DIGIT}+)|({DIGIT}+".")

ESC_SEQ     (\\'|\\\"|\\\?|\\\\|\\a|\\b|\\f|\\n|\\r|\\t|\\v)
C_CHAR      [^'\\\n]|{ESC_SEQ}
CHAR_CONST  '({C_CHAR})'

S_CHAR      [^"\\\n]|{ESC_SEQ}
STR_LIT     \"({S_CHAR})*\"

SL_COMMENT  "//"[^\n]*
ML_COMMENT  "/*"([^*]|\*+[^*/])*\*+"/"

%%

{SL_COMMENT}    { /* skip single-line comment */ }
{ML_COMMENT}    { /* count newlines inside block comment */
                  for (int i = 0; yytext[i]; i++)
                      if (yytext[i] == '\n') line_num++;
                }

"break"     { fprintf(token_file, "<KEYWORD, break, %d>\n", line_num); }
"default"   { fprintf(token_file, "<KEYWORD, default, %d>\n", line_num); }
"return"    { fprintf(token_file, "<KEYWORD, return, %d>\n", line_num); }
"void"      { fprintf(token_file, "<KEYWORD, void, %d>\n", line_num); }
"case"      { fprintf(token_file, "<KEYWORD, case, %d>\n", line_num); }
"float"     { fprintf(token_file, "<KEYWORD, float, %d>\n", line_num); }
"short"     { fprintf(token_file, "<KEYWORD, short, %d>\n", line_num); }
"double"    { fprintf(token_file, "<KEYWORD, double, %d>\n", line_num); }
"char"      { fprintf(token_file, "<KEYWORD, char, %d>\n", line_num); }
"for"       { fprintf(token_file, "<KEYWORD, for, %d>\n", line_num); }
"signed"    { fprintf(token_file, "<KEYWORD, signed, %d>\n", line_num); }
"while"     { fprintf(token_file, "<KEYWORD, while, %d>\n", line_num); }
"else"      { fprintf(token_file, "<KEYWORD, else, %d>\n", line_num); }
"unsigned"  { fprintf(token_file, "<KEYWORD, unsigned, %d>\n", line_num); }
"long"      { fprintf(token_file, "<KEYWORD, long, %d>\n", line_num); }
"_Bool"     { fprintf(token_file, "<KEYWORD, _Bool, %d>\n", line_num); }
"continue"  { fprintf(token_file, "<KEYWORD, continue, %d>\n", line_num); }
"if"        { fprintf(token_file, "<KEYWORD, if, %d>\n", line_num); }
"static"    { fprintf(token_file, "<KEYWORD, static, %d>\n", line_num); }
"do"        { fprintf(token_file, "<KEYWORD, do, %d>\n", line_num); }
"int"       { fprintf(token_file, "<KEYWORD, int, %d>\n", line_num); }

{ID}        {
                fprintf(token_file, "<IDENTIFIER, %s, %d>\n", yytext, line_num);
                insert(yytext);
            }

{INT_CONST} { fprintf(token_file, "<INTEGER_CONSTANT, %s, %d>\n", yytext, line_num); }
"0"         { fprintf(token_file, "<INTEGER_CONSTANT, 0, %d>\n", line_num); }

{FRAC_CONST} { fprintf(token_file, "<FLOATING_CONSTANT, %s, %d>\n", yytext, line_num); }

{CHAR_CONST} { fprintf(token_file, "<CHARACTER_CONSTANT, %s, %d>\n", yytext, line_num); }

{STR_LIT}   { fprintf(token_file, "<STRING_LITERAL, %s, %d>\n", yytext, line_num); }

"["     { fprintf(token_file, "<PUNCTUATOR, [, %d>\n", line_num); }
"]"     { fprintf(token_file, "<PUNCTUATOR, ], %d>\n", line_num); }
"("     { fprintf(token_file, "<PUNCTUATOR, (, %d>\n", line_num); }
")"     { fprintf(token_file, "<PUNCTUATOR, ), %d>\n", line_num); }
"{"     { fprintf(token_file, "<PUNCTUATOR, {, %d>\n", line_num); }
"}"     { fprintf(token_file, "<PUNCTUATOR, }, %d>\n", line_num); }
"."     { fprintf(token_file, "<PUNCTUATOR, ., %d>\n", line_num); }
"->"    { fprintf(token_file, "<PUNCTUATOR, ->, %d>\n", line_num); }
"++"    { fprintf(token_file, "<PUNCTUATOR, ++, %d>\n", line_num); }
"--"    { fprintf(token_file, "<PUNCTUATOR, --, %d>\n", line_num); }
"&&"    { fprintf(token_file, "<PUNCTUATOR, &&, %d>\n", line_num); }
"||"    { fprintf(token_file, "<PUNCTUATOR, ||, %d>\n", line_num); }
"<<"    { fprintf(token_file, "<PUNCTUATOR, <<, %d>\n", line_num); }
">>"    { fprintf(token_file, "<PUNCTUATOR, >>, %d>\n", line_num); }
"<="    { fprintf(token_file, "<PUNCTUATOR, <=, %d>\n", line_num); }
">="    { fprintf(token_file, "<PUNCTUATOR, >=, %d>\n", line_num); }
"=="    { fprintf(token_file, "<PUNCTUATOR, ==, %d>\n", line_num); }
"!="    { fprintf(token_file, "<PUNCTUATOR, !=, %d>\n", line_num); }
"*="    { fprintf(token_file, "<PUNCTUATOR, *=, %d>\n", line_num); }
"/="    { fprintf(token_file, "<PUNCTUATOR, /=, %d>\n", line_num); }
"%="    { fprintf(token_file, "<PUNCTUATOR, %%=, %d>\n", line_num); }
"+="    { fprintf(token_file, "<PUNCTUATOR, +=, %d>\n", line_num); }
"-="    { fprintf(token_file, "<PUNCTUATOR, -=, %d>\n", line_num); }
"<<="   { fprintf(token_file, "<PUNCTUATOR, <<=, %d>\n", line_num); }
">>="   { fprintf(token_file, "<PUNCTUATOR, >>=, %d>\n", line_num); }
"&="    { fprintf(token_file, "<PUNCTUATOR, &=, %d>\n", line_num); }
"^="    { fprintf(token_file, "<PUNCTUATOR, ^=, %d>\n", line_num); }
"|="    { fprintf(token_file, "<PUNCTUATOR, |=, %d>\n", line_num); }
"..."   { fprintf(token_file, "<PUNCTUATOR, ..., %d>\n", line_num); }
"&"     { fprintf(token_file, "<PUNCTUATOR, &, %d>\n", line_num); }
"*"     { fprintf(token_file, "<PUNCTUATOR, *, %d>\n", line_num); }
"+"     { fprintf(token_file, "<PUNCTUATOR, +, %d>\n", line_num); }
"-"     { fprintf(token_file, "<PUNCTUATOR, -, %d>\n", line_num); }
"~"     { fprintf(token_file, "<PUNCTUATOR, ~, %d>\n", line_num); }
"!"     { fprintf(token_file, "<PUNCTUATOR, !, %d>\n", line_num); }
"/"     { fprintf(token_file, "<PUNCTUATOR, /, %d>\n", line_num); }
"%"     { fprintf(token_file, "<PUNCTUATOR, %%, %d>\n", line_num); }
"<"     { fprintf(token_file, "<PUNCTUATOR, <, %d>\n", line_num); }
">"     { fprintf(token_file, "<PUNCTUATOR, >, %d>\n", line_num); }
"^"     { fprintf(token_file, "<PUNCTUATOR, ^, %d>\n", line_num); }
"|"     { fprintf(token_file, "<PUNCTUATOR, |, %d>\n", line_num); }
"?"     { fprintf(token_file, "<PUNCTUATOR, ?, %d>\n", line_num); }
":"     { fprintf(token_file, "<PUNCTUATOR, :, %d>\n", line_num); }
";"     { fprintf(token_file, "<PUNCTUATOR, ;, %d>\n", line_num); }
"="     { fprintf(token_file, "<PUNCTUATOR, =, %d>\n", line_num); }
","     { fprintf(token_file, "<PUNCTUATOR, ,, %d>\n", line_num); }
"#"     { fprintf(token_file, "<PUNCTUATOR, #, %d>\n", line_num); }

"\n"    { line_num++; }
[ \t\r] { /* skip whitespace */ }

.       { fprintf(stderr, "Lexical error: unknown character '%s' at line %d\n", yytext, line_num); }

%%

int yywrap() { return 1; }

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        fprintf(stderr, "Error: cannot open input file '%s'\n", argv[1]);
        return 1;
    }

    token_file = fopen("a3_230101123_token.txt", "w");
    if (!token_file) {
        fprintf(stderr, "Error: cannot open token output file\n");
        return 1;
    }

    st_file = fopen("a3_230101123_st.txt", "w");
    if (!st_file) {
        fprintf(stderr, "Error: cannot open symbol table output file\n");
        return 1;
    }

    yyin = input;
    yylex();

    /* Write symbol table */
    fprintf(st_file, "%-5s | %s\n", "Index", "Identifier");
    fprintf(st_file, "------|-----------\n");
    for (int i = 0; i < sym_count; i++) {
        fprintf(st_file, "%-5d | %s\n", i, symbol_table[i]);
    }

    fclose(input);
    fclose(token_file);
    fclose(st_file);

    printf("Done. Check a3_230101123_token.txt and a3_230101123_st.txt\n");
    return 0;
}
