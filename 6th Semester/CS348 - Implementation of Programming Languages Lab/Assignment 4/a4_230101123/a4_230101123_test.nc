/* a4_230101123_test.nc
   Comprehensive test for nanoC parser – Roll 230101123
   Tests: declarations, expressions, statements, functions, loops, conditionals
*/

// --- Global variable declarations ---
int g_count;
float g_pi;
static int g_flag = 0;

// --- Type specifiers ---
void    f_void(void);
char    f_char(char c);
short   f_short(short s);
long    f_long(long l);
double  f_double(double d);
signed  int f_signed(signed int x);
unsigned int f_unsigned(unsigned int x);
_Bool   f_bool(_Bool b);

// --- Simple function: no params ---
void f_void(void) {
    return;
}

// --- Integer arithmetic and assignment operators ---
int arithmetic(int a, int b) {
    int result;
    result = a + b;
    result = a - b;
    result = a * b;
    result = a / b;
    result = a % b;
    result += 1;
    result -= 2;
    result *= 3;
    result /= 4;
    result %= 5;
    return result;
}

// --- Bitwise and shift operators ---
int bitwise(int x, int y) {
    int r;
    r = x & y;
    r = x | y;
    r = x ^ y;
    r = ~x;
    r = x << 2;
    r = x >> 1;
    r <<= 1;
    r >>= 2;
    r &= 255;
    r ^= y;
    r |= y;
    return r;
}

// --- Relational and logical operators ---
int logical(int a, int b) {
    int t;
    t = (a == b);
    t = (a != b);
    t = (a < b);
    t = (a > b);
    t = (a <= b);
    t = (a >= b);
    t = (a && b);
    t = (a || b);
    t = !a;
    return t;
}

// --- Conditional (ternary) expression ---
int max(int a, int b) {
    return (a > b) ? a : b;
}

// --- Unary operators ---
int unary_test(int n) {
    int val;
    val = ~n;
    val = !n;
    val = -n;
    val = +n;
    return val;
}

// --- Increment / decrement ---
int incdec(int x) {
    x++;
    x--;
    ++x;
    --x;
    return x;
}

// --- if / if-else / nested if ---
void conditionals(int x) {
    if (x > 0) {
        x = x - 1;
    }

    if (x == 0) {
        x = 1;
    } else {
        x = x + 1;
    }

    if (x < 0) {
        x = 0;
    } else if (x > 100) {
        x = 100;
    } else {
        x = x;
    }
}

// --- while loop ---
int sum_while(int n) {
    int s;
    s = 0;
    while (n > 0) {
        s = s + n;
        n = n - 1;
    }
    return s;
}

// --- do-while loop ---
int sum_dowhile(int n) {
    int s;
    s = 0;
    do {
        s = s + n;
        n--;
    } while (n > 0);
    return s;
}

// --- for loop ---
int sum_for(int n) {
    int i;
    int s;
    s = 0;
    for (i = 0; i < n; i++) {
        s = s + i;
    }
    return s;
}

// --- for loop with declaration ---
int sum_for_decl(int n) {
    int s;
    s = 0;
    for (int i = 0; i < n; i++) {
        s += i;
    }
    return s;
}

// --- break and continue ---
int break_continue(int n) {
    int i;
    int s;
    s = 0;
    for (i = 0; i < n; i++) {
        if (i == 5) break;
        if (i == 3) continue;
        s = s + i;
    }
    return s;
}

// --- Labeled statements: identifier label, case, default ---
void labels(int x) {
    my_label:
        x = x + 1;
    case 1:
        x = 10;
    case 2:
        x = 20;
    default:
        x = 0;
}

// --- String literal and character constant ---
void literals(void) {
    char c;
    c = 'A';
    c = '\n';
    c = '\t';
    c = '\\';
    /* string literals are primary-expressions; assign to demonstrate */
    "hello, nanoC!";
    "escape: \n \t \\";
}

// --- Array declarator ---
int array_test(void) {
    int arr[10];
    int i;
    for (i = 0; i < 10; i++) {
        arr[i] = i * i;
    }
    return arr[9];
}

// --- Multi-param function with ellipsis (parameter-type-list with ...) ---
int variadic_like(int n, ...) {
    return n;
}

// --- Compound / initializer-list ---
void init_list(void) {
    int a = 5;
    float b = 3.14;
    double c = 2.71828;
    short  d = 100;
    long   e = 123456789;
}

// --- Comma expression ---
int comma_expr(void) {
    int a;
    int b;
    a = (b = 3, b + 1);
    return a;
}

// --- main ---
int main(void) {
    int x;
    int y;
    int z;
    x = 10;
    y = 20;

    z = arithmetic(x, y);
    z = bitwise(x, y);
    z = logical(x, y);
    z = max(x, y);
    z = incdec(x);
    z = sum_while(x);
    z = sum_dowhile(x);
    z = sum_for(x);
    z = sum_for_decl(x);
    z = break_continue(y);
    z = unary_test(x);
    z = array_test();
    z = variadic_like(1);
    z = comma_expr();

    conditionals(x);
    literals();
    init_list();

    return 0;
}
