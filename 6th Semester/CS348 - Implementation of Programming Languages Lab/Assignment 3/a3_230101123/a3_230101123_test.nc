/* Multi-line comment test
   spanning two lines */

// Single-line comment test

// --- Keywords ---
int main() {
    break;
    default:
    return;
    void;
    case 1:
    float f;
    short s;
    double d;
    char c;
    for (;;) {}
    signed x;
    while (1) {}
    else {}
    unsigned u;
    long l;
    _Bool b;
    continue;
    if (1) {}
    static int st;
    do {} while(0);
    int i;
}

// --- Identifiers ---
int myVar;
int abc123;
int A;
int z;

// --- Integer Constants ---
int a = 0;
int bb = 1;
int cc = 42;
int dd = 9999;

// --- Floating Constants ---
float p = 3.14;
float q = .5;
float r = 10.;
float s = 0.0;

// --- Character Constants ---
char ch1 = 'a';
char ch2 = 'Z';
char ch3 = '\n';
char ch4 = '\t';
char ch5 = '\\';
char ch6 = '\'';

// --- String Literals ---
char *str1 = "hello world";
char *str2 = "";
char *str3 = "escape \n test \t done";

// --- Punctuators ---
// grouping
int arr[10];
(1 + 2);
{ int x; }

// member access
// obj.field  obj->field  (just tokens, not valid standalone)

// increment / decrement
int n;
n++;
n--;

// bitwise & address-of
int *ptr = &n;
int val = *ptr;

// arithmetic
int res = 10 + 2 - 3 * 4 / 2 % 3;

// bitwise
int bit = ~n & 0;

// logical
int lg = !1 && 0 || 1;

// shift
int sh = 1 << 2;
int sh2 = 8 >> 1;

// relational
int cmp = (1 < 2) && (3 > 2) && (2 <= 2) && (2 >= 2) && (1 == 1) && (1 != 2);

// bitwise xor / or
int bx = n ^ val;
int bo = n | val;

// ternary
int tn = 1 ? 2 : 3;

// assignment operators
n = 5;
n += 1;
n -= 1;
n *= 2;
n /= 2;
n %= 3;
n <<= 1;
n >>= 1;
n &= 3;
n ^= 1;
n |= 2;

// ellipsis
// void func(int x, ...);   -- just show the token
int comma_test = (1, 2);

// hash / preprocessor marker
#

// semicolon and colon (already used above)
;

// --- Lexical Error ---
@
