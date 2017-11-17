#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
  if ((argc - 1) % 8 != 0) {
    fprintf(stderr, "%s: Error: param count must be a multiple of 8.\n", argv[0]);
    return 1;
  }

  int value;
  for (int i=0; i<argc-1; i++) {
    char *arg = argv[i + 1];

    if (i % 8 == 0) {
      value = 0;
    }

    if ((arg[0] == '0' || arg[0] == '1') && strlen(arg) == 1) {
   // fprintf(stderr, "Set bit: %d to %d\n", (i % 8), (arg[0] - '0'));
      value |= (arg[0] - '0') << (i % 8);
    } else {
      /* Bad argument */
      fprintf(stderr, "%s: Error: all arguments must be 0 or 1.\n", argv[0]);
      return 1;
    }

    if (i % 8 == 7) {
      // 11100010 101000xx 10xxxxxx
      putchar(0xE2);
      putchar(0xA0 | (value >> 6));
      putchar(0x80 | (value & 0x3F));
    }
  }

  putchar('\n');
  return 0;
}
