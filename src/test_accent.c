#include <assert.h>

#include "accent.h"

int
main(int argc, char *argv[])
{
  char buf[100];
  int len;

  init_accent();
  
  /* accented 'a' characters */
  char *accented_as = "\345\342\341\340\344\343\305";
  len = canon(buf, accented_as, 0);

  assert(len == 7);
  assert(buf[0] == 'a');
  assert(buf[1] == 'a');
  assert(buf[2] == 'a');
  assert(buf[3] == 'a');
  assert(buf[4] == 'a');
  assert(buf[5] == 'a');
  assert(buf[6] == 'a');
  assert(buf[7] == 0);

  return 0;
}
