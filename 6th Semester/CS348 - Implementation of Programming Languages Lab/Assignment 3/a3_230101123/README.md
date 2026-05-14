# Assignment 3 – Lexer for nanoC
**Course:** CS348 – Implementation of Programming Languages Lab  
**Roll No:** 230101123

---

## Files
| File | Description |
|------|-------------|
| `a3_ROLL.l` | Flex specification for the nanoC lexer |
| `a3_ROLL_test.nc` | Test input covering all lexical rules |
| `a3_ROLL_token.txt` | *(generated)* Token output |
| `a3_ROLL_st.txt` | *(generated)* Symbol table |
| `Makefile` | Build script |

---

## How to Build and Run

```bash
# Build the lexer
make

# Run on the test file
make run

# Or manually:
flex a3_ROLL.l
gcc lex.yy.c -lfl -o lexer
./lexer a3_ROLL_test.nc
```

## Token Output Format
```
<TOKEN_TYPE, lexeme, line_number>
```

## Symbol Table Format
Identifiers only (keywords excluded), deduplicated, printed with an index.

## Lexical Rules Covered
- All 27 keywords
- Identifiers (letters followed by letters/digits)
- Integer constants (0, and nonzero-leading sequences)
- Floating constants (digit.digit, .digit, digit.)
- Character constants with escape sequences
- String literals with escape sequences
- All punctuators including multi-character ones (`->`, `++`, `<<=`, `...`, etc.)
- Single-line (`//`) and multi-line (`/* */`) comments
- Lexical errors reported with line numbers
