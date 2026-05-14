%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

int line_num = 1;
%}

/* Definitions */
DIGIT       [0-9]
NONZERO     [1-9]
LETTER      [a-zA-Z_]
ID          [a-zA-Z_][a-zA-Z0-9_]*
INTEGER     {NONZERO}{DIGIT}*|0
FRAC1       {DIGIT}*\.{DIGIT}+
FRAC2       {DIGIT}+\.
FLOAT       ({FRAC1}|{FRAC2})
ESC         \\['"?\\abfnrtv]
CCHAR       ([^'\\\n]|{ESC})
SCHAR       ([^"\\\n]|{ESC})

%%

 /* Keywords */
"break"         { return BREAK; }
"case"          { return CASE; }
"char"          { return CHAR; }
"continue"      { return CONTINUE; }
"default"       { return DEFAULT; }
"do"            { return DO; }
"double"        { return DOUBLE; }
"else"          { return ELSE; }
"float"         { return FLOAT_KW; }
"for"           { return FOR; }
"if"            { return IF; }
"int"           { return INT; }
"long"          { return LONG; }
"return"        { return RETURN; }
"short"         { return SHORT; }
"signed"        { return SIGNED; }
"static"        { return STATIC; }
"unsigned"      { return UNSIGNED; }
"void"          { return VOID; }
"while"         { return WHILE; }
"_Bool"         { return BOOL; }

 /* Identifiers */
{ID}            { yylval.sval = strdup(yytext); return IDENTIFIER; }

 /* Constants */
{INTEGER}       { yylval.ival = atoi(yytext); return INTEGER_CONST; }
{FLOAT}         { yylval.fval = atof(yytext); return FLOAT_CONST; }
"'"{CCHAR}"'"   { yylval.sval = strdup(yytext); return CHAR_CONST; }

 /* String literals */
"\""({SCHAR})*"\""  { yylval.sval = strdup(yytext); return STRING_LITERAL; }

 /* Punctuators - multi-char first */
"..."           { return ELLIPSIS; }
"<<="           { return LEFT_ASSIGN; }
">>="           { return RIGHT_ASSIGN; }
"+="            { return ADD_ASSIGN; }
"-="            { return SUB_ASSIGN; }
"*="            { return MUL_ASSIGN; }
"/="            { return DIV_ASSIGN; }
"%="            { return MOD_ASSIGN; }
"&="            { return AND_ASSIGN; }
"^="            { return XOR_ASSIGN; }
"|="            { return OR_ASSIGN; }
">>"            { return RIGHT_OP; }
"<<"            { return LEFT_OP; }
"++"            { return INC_OP; }
"--"            { return DEC_OP; }
"->"            { return PTR_OP; }
"&&"            { return AND_OP; }
"||"            { return OR_OP; }
"<="            { return LE_OP; }
">="            { return GE_OP; }
"=="            { return EQ_OP; }
"!="            { return NE_OP; }

 /* Single-char punctuators */
"["             { return '['; }
"]"             { return ']'; }
"("             { return '('; }
")"             { return ')'; }
"{"             { return '{'; }
"}"             { return '}'; }
"."             { return '.'; }
"&"             { return '&'; }
"*"             { return '*'; }
"+"             { return '+'; }
"-"             { return '-'; }
"~"             { return '~'; }
"!"             { return '!'; }
"/"             { return '/'; }
"%"             { return '%'; }
"<"             { return '<'; }
">"             { return '>'; }
"^"             { return '^'; }
"|"             { return '|'; }
"?"             { return '?'; }
":"             { return ':'; }
";"             { return ';'; }
"="             { return '='; }
","             { return ','; }
"#"             { return '#'; }

 /* Comments */
"/*"([^*]|\*+[^*/])*\*+"/"  { /* skip multi-line comment */
    for (int i = 0; yytext[i]; i++)
        if (yytext[i] == '\n') line_num++;
}
"//"[^\n]*      { /* skip single-line comment */ }

 /* Whitespace */
"\n"            { line_num++; }
[ \t\r]+        { /* skip whitespace */ }

 /* Unknown */
.               {
    fprintf(stderr, "Lexical error at line %d: unknown character '%s'\n", line_num, yytext);
}

%%

int yywrap(void) {
    return 1;
}
