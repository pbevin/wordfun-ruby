#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include "accent.h"
#include "wordfun.h"

int
direct_match(char *pat, char *str)
{
  int i;

  for (i = 0; pat[i] && str[i]; i++) {
    if (pat[i] == '.')
      continue;
    if (pat[i] == '/' && str[i] == ' ')
      continue;
    if (pat[i] == str[i])
      continue;
    return 0;
  }

  return pat[i] == str[i];  /* both 0 */
}

int
canon_match(char *pat, char *str)
{
  int i;

  for (i = 0; pat[i] && str[i]; i++) {
    if (pat[i] == '.')
      continue;
    if (pat[i] == str[i])
      continue;
    return 0;
  }

  return pat[i] == str[i];  /* both 0 */
}

int crypto_match(char *pat, char *str)
{
  int i;
  char key[256];
  char rkey[256];
  memset(key, 0, 256);
  memset(rkey, 0, 256);

  for (i = 0; pat[i] && str[i]; i++) {
    int idx = pat[i];
    int idx2 = str[i];
    char ch = key[idx];
    char ch2 = rkey[idx2];
    if (ch && str[i] != ch) return 0;
    if (ch2 && pat[i] != ch2) return 0;

    key[idx] = str[i];
    rkey[idx2] = pat[i];
  }

  return pat[i] == str[i];  /* both 0 */
}


int
main(int argc, char *argv[])
{
  FILE *fp;
  char *filename = DICT;
  char *fw;
  char buf[100];
  char buf2[100];
  int spaces;
  int c;
  int cryptogram = 0;

  while ((c = getopt(argc, argv, "f:c")) != -1) {
    switch (c) {
      case 'f':
        filename = strdup(optarg);
        break;
      case 'c':
        cryptogram = 1;
        break;
    }
  }

  if (optind == argc) {
    fprintf(stderr, "Usage: %s [-f dictionary-file] pattern\n", argv[0]);
    exit(1);
  }

  fw = argv[optind];

  init_accent();

  spaces = strchr(fw, '/') != 0;

  fp = fopen(filename, "r");
  if (fp == 0) {
    perror(filename);
    return 1;
  }
  while (fgets(buf, sizeof(buf), fp) != NULL) {
    if (cryptogram) {
      canon(buf2, buf, 1);
      if (crypto_match(fw, buf2)) {
        fputs(buf, stdout);
      }
    }
    else if (spaces) {
      canon(buf2, buf, 1);
      if (direct_match(fw, buf2)) {
        fputs(buf, stdout);
      }
    }
    else {
      canon(buf2, buf, 0);
      if (canon_match(fw, buf2)) {
        fputs(buf, stdout);
      }
    }
  }
  fclose(fp);

  return 0;
}
