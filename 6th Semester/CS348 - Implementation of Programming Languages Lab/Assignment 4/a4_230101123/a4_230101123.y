%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int line_num;
extern int yylex(void);
void yyerror(const char *s);
%}

%union {
    int    ival;
    float  fval;
    char  *sval;
}

/* ── Tokens ── */
%token <sval> IDENTIFIER STRING_LITERAL
%token <ival> INTEGER_CONST
%token <fval> FLOAT_CONST
%token <sval> CHAR_CONST

/* Keywords */
%token BREAK CASE CHAR CONTINUE DEFAULT DO DOUBLE ELSE
%token FLOAT_KW FOR IF INT LONG RETURN SHORT SIGNED
%token STATIC UNSIGNED VOID WHILE BOOL

/* Multi-char operators */
%token ELLIPSIS
%token LEFT_ASSIGN RIGHT_ASSIGN ADD_ASSIGN SUB_ASSIGN
%token MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN AND_ASSIGN XOR_ASSIGN OR_ASSIGN
%token RIGHT_OP LEFT_OP INC_OP DEC_OP PTR_OP
%token AND_OP OR_OP LE_OP GE_OP EQ_OP NE_OP

/* ── Operator precedence (low → high) ── */
%right '=' ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
       AND_ASSIGN XOR_ASSIGN OR_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN
%right '?' ':'
%left OR_OP
%left AND_OP
%left '|'
%left '^'
%left '&'
%left EQ_OP NE_OP
%left '<' '>' LE_OP GE_OP
%left LEFT_OP RIGHT_OP
%left '+' '-'
%left '*' '/' '%'
%right '!' '~' INC_OP DEC_OP
%left '[' ']' '(' ')' '.' PTR_OP

/* Resolve dangling-else */
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

/* ────────────────────────────────────────
   Top-level: one or more declarations /
   function definitions
──────────────────────────────────────── */
translation_unit
    : external_declaration
    | translation_unit external_declaration
    ;

external_declaration
    : declaration
    | function_definition
    ;

function_definition
    : declaration_specifiers declarator compound_statement
    ;

/* ══════════════════════════════════════
   1. EXPRESSIONS
══════════════════════════════════════ */

primary_expression
    : IDENTIFIER
    | INTEGER_CONST
    | FLOAT_CONST
    | CHAR_CONST
    | STRING_LITERAL
    | '(' expression ')'
    ;

postfix_expression
    : primary_expression
    | postfix_expression '[' expression ']'
    | postfix_expression '(' argument_expression_list_opt ')'
    | postfix_expression INC_OP
    | postfix_expression DEC_OP
    ;

argument_expression_list_opt
    : /* empty */
    | argument_expression_list
    ;

argument_expression_list
    : assignment_expression
    | argument_expression_list ',' assignment_expression
    ;

unary_expression
    : postfix_expression
    | INC_OP unary_expression
    | DEC_OP unary_expression
    | unary_operator unary_expression
    ;

unary_operator
    : '&' | '*' | '+' | '-' | '~' | '!'
    ;

multiplicative_expression
    : unary_expression
    | multiplicative_expression '*' unary_expression
    | multiplicative_expression '/' unary_expression
    | multiplicative_expression '%' unary_expression
    ;

additive_expression
    : multiplicative_expression
    | additive_expression '+' multiplicative_expression
    | additive_expression '-' multiplicative_expression
    ;

shift_expression
    : additive_expression
    | shift_expression LEFT_OP  additive_expression
    | shift_expression RIGHT_OP additive_expression
    ;

relational_expression
    : shift_expression
    | relational_expression '<'   shift_expression
    | relational_expression '>'   shift_expression
    | relational_expression LE_OP shift_expression
    | relational_expression GE_OP shift_expression
    ;

equality_expression
    : relational_expression
    | equality_expression EQ_OP relational_expression
    | equality_expression NE_OP relational_expression
    ;

and_expression
    : equality_expression
    | and_expression '&' equality_expression
    ;

exclusive_or_expression
    : and_expression
    | exclusive_or_expression '^' and_expression
    ;

inclusive_or_expression
    : exclusive_or_expression
    | inclusive_or_expression '|' exclusive_or_expression
    ;

logical_and_expression
    : inclusive_or_expression
    | logical_and_expression AND_OP inclusive_or_expression
    ;

logical_or_expression
    : logical_and_expression
    | logical_or_expression OR_OP logical_and_expression
    ;

conditional_expression
    : logical_or_expression
    | logical_or_expression '?' expression ':' conditional_expression
    ;

assignment_expression
    : conditional_expression
    | unary_expression assignment_operator assignment_expression
    ;

assignment_operator
    : '='
    | MUL_ASSIGN | DIV_ASSIGN | MOD_ASSIGN
    | ADD_ASSIGN  | SUB_ASSIGN
    | LEFT_ASSIGN | RIGHT_ASSIGN
    | AND_ASSIGN  | XOR_ASSIGN  | OR_ASSIGN
    ;

expression
    : assignment_expression
    | expression ',' assignment_expression
    ;

constant_expression
    : conditional_expression
    ;

/* ══════════════════════════════════════
   2. DECLARATIONS
══════════════════════════════════════ */

declaration
    : declaration_specifiers init_declarator_list_opt ';'
    ;

init_declarator_list_opt
    : /* empty */
    | init_declarator_list
    ;

declaration_specifiers
    : storage_class_specifier
    | storage_class_specifier declaration_specifiers
    | type_specifier
    | type_specifier declaration_specifiers
    ;

init_declarator_list
    : init_declarator
    | init_declarator_list ',' init_declarator
    ;

init_declarator
    : declarator
    | declarator '=' initializer
    ;

storage_class_specifier
    : STATIC
    ;

type_specifier
    : VOID | CHAR | SHORT | INT | LONG
    | FLOAT_KW | DOUBLE | SIGNED | UNSIGNED | BOOL
    ;

declarator
    : direct_declarator
    ;

direct_declarator
    : IDENTIFIER
    | '(' declarator ')'
    | direct_declarator '[' assignment_expression_opt ']'
    | direct_declarator '(' parameter_type_list ')'
    | direct_declarator '(' identifier_list_opt ')'
    ;

assignment_expression_opt
    : /* empty */
    | assignment_expression
    ;

parameter_type_list
    : parameter_list
    | parameter_list ',' ELLIPSIS
    ;

parameter_list
    : parameter_declaration
    | parameter_list ',' parameter_declaration
    ;

parameter_declaration
    : declaration_specifiers declarator
    | declaration_specifiers
    ;

identifier_list_opt
    : /* empty */
    | identifier_list
    ;

identifier_list
    : IDENTIFIER
    | identifier_list ',' IDENTIFIER
    ;

initializer
    : assignment_expression
    | '{' initializer_list '}'
    | '{' initializer_list ',' '}'
    ;

initializer_list
    : designation_opt initializer
    | initializer_list ',' designation_opt initializer
    ;

designation_opt
    : /* empty */
    | designation
    ;

designation
    : designator_list '='
    ;

designator_list
    : designator
    | designator_list designator
    ;

designator
    : '[' constant_expression ']'
    ;

/* ══════════════════════════════════════
   3. STATEMENTS
══════════════════════════════════════ */

statement
    : labeled_statement
    | compound_statement
    | expression_statement
    | selection_statement
    | iteration_statement
    | jump_statement
    ;

labeled_statement
    : IDENTIFIER ':' statement
    | CASE constant_expression ':' statement
    | DEFAULT ':' statement
    ;

compound_statement
    : '{' block_item_list_opt '}'
    ;

block_item_list_opt
    : /* empty */
    | block_item_list
    ;

block_item_list
    : block_item
    | block_item_list block_item
    ;

block_item
    : declaration
    | statement
    ;

expression_statement
    : expression_opt ';'
    ;

expression_opt
    : /* empty */
    | expression
    ;

selection_statement
    : IF '(' expression ')' statement                %prec LOWER_THAN_ELSE
    | IF '(' expression ')' statement ELSE statement
    ;

iteration_statement
    : WHILE '(' expression ')' statement
    | DO statement WHILE '(' expression ')' ';'
    | FOR '(' expression_opt ';' expression_opt ';' expression_opt ')' statement
    | FOR '(' declaration expression_opt ';' expression_opt ')' statement
    ;

jump_statement
    : CONTINUE ';'
    | BREAK ';'
    | RETURN expression_opt ';'
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error at line %d: %s\n", line_num, s);
}

int main(int argc, char *argv[]) {
    printf("nanoC Parser – Roll 230101123\n");
    printf("Parsing input...\n");
    int result = yyparse();
    if (result == 0) {
        printf("Parsing successful!\n");
    } else {
        printf("Parsing failed.\n");
    }
    return result;
}
