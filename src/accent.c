#include <memory.h>
#include <ctype.h>

static char accent_map[256];


void
strip_accents(char *str)
{
  int i;
  for (i = 0; str[i]; i++) {
    int ch = str[i];
    char unaccented = accent_map[ch];
    if (unaccented != 0) {
      str[i] = unaccented;
    }
  }
}

int
canon(char *dst, char *str, int keep_spc)
{
  char *p = str;
  char *q = dst;

  for (; *p; p++) {
    unsigned char ch = (unsigned char)*p;
    if (accent_map[ch]) {
      ch = accent_map[ch];
    }
      
    if (isalpha(ch)) {
      *q++ = tolower(ch);
    }
    else if (keep_spc && ch == ' ') {
      *q++ = ch;
    }
  }
  *q = 0;

  return q - dst;
}


static void
add_accents(int unaccented, char *accented)
{
  unsigned char *p;

  for (p = (unsigned char *)accented; *p; p++) {
    accent_map[(int)*p] = unaccented;
  }
}

void init_accent()
{
  memset(accent_map, 0, sizeof(accent_map));
  char a[] = { 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0 };
  char c[] = { 0xe7, 0 };
  char e[] = { 0xe8, 0xe9, 0xea, 0xeb, 0 };
  char i[] = { 0xec, 0xee, 0xef, 0 };
  char n[] = { 0xf1, 0 };
  char o[] = { 0xf2, 0xf3, 0xf4, 0xf6, 0xf8, 0 };
  char u[] = { 0xf9, 0xfa, 0xfb, 0xfc, 0 };

  add_accents('a', a);
  add_accents('c', c);
  add_accents('e', e);
  add_accents('i', i);
  add_accents('n', n);
  add_accents('o', o);
  add_accents('u', u);
}
