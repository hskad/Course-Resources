# Assignment 4 – Parser for nanoC
**Name:** Daksh Agarwal
**Roll Number:** 230101123

---

## Files

| File | Description |
|------|-------------|
| `a4_230101123.l` | Flex lexer specification |
| `a4_230101123.y` | Bison parser specification |
| `a4_230101123_test.nc` | Test input file covering all grammar rules |
| `Makefile` | Build automation |
| `README.md` | This file |

---

## How to Build and Run

```bash
make        # builds the parser (runs flex + yacc + gcc)
make run    # builds and runs parser on the test file
make clean  # removes generated files
```

Or manually:
```bash
flex a4_230101123.l
yacc -d a4_230101123.y
gcc lex.yy.c y.tab.c -lfl -o a.out
./a.out < a4_230101123_test.nc
```

---

## Grammar Changes Made

The bison grammar is derived directly from the nanoC Phase Structure Grammar.
The following changes were made to handle optionality and resolve conflicts:

### 1. Optional non-terminals expanded
Every `Xopt` notation from the spec was replaced with a new non-terminal `X_opt` with two productions:
```
X_opt : /* empty */ | X ;
```
Non-terminals introduced:
- `argument_expression_list_opt`
- `assignment_expression_opt`
- `init_declarator_list_opt`
- `identifier_list_opt`
- `designation_opt`
- `block_item_list_opt`
- `expression_opt`

### 2. Dangling-else resolved
Used `%prec LOWER_THAN_ELSE` on the single-branch `if` rule so that the `else` always binds to the nearest `if`.

### 3. Operator precedence
Declared via `%left` / `%right` / `%nonassoc` directives matching C's standard precedence table, eliminating shift/reduce conflicts for expressions.

### 4. `translation_unit` added
The grammar needed a top-level start symbol. A `translation_unit` rule was added that accepts one or more `external_declaration` items (either a declaration or a function definition), following the C standard.

---

## Test File Coverage

`a4_230101123_test.nc` exercises:
- All type specifiers (`int`, `char`, `short`, `long`, `float`, `double`, `signed`, `unsigned`, `void`, `_Bool`)
- `static` storage class specifier
- All arithmetic, bitwise, shift, relational, logical, and assignment operators
- Unary operators (`!`, `~`, `&`, `*`, `++`, `--`)
- Ternary / conditional expression
- Array declarators
- Function declarations with parameter lists and `...` (ellipsis)
- `if`, `if-else`, nested `if-else`
- `while`, `do-while`, `for` (both forms)
- `break`, `continue`, `return`
- Labeled statements (`identifier:`, `case`, `default`)
- Compound statements (nested blocks)
- Variable initializers (scalar)
- String literals and character constants (including escape sequences)
- Comma expressions
- Comments (both `/* */` and `//` styles)
