#include <stdio.h>

/* CJK/kana etc:
 *   U+3000 - U+303F  (symbols)
 *   U+3040 - U+30FF  (kana)
 *   U+3300 - U+33FF
 *   U+3400 - U+4DBF
 *   U+4DC0 - U+4DFF  (hexgrams)
 *   U+4E00 - U+9FFF
 *   U+F900 - U+FAFF
 * Full-width symbols:  U+FF00 - U+FF60 */

 /* ⽕ U+2F55 */

int main(void) {
  int c;
  int count = 0;

  while ((c = getchar()) > 0) {
    if ((c & 0xF0) == 0xE0) { /* [U+0800 - U+FFFF] leading byte */
      int b1, b2;
      b1 = getchar();
      b2 = getchar();

      int cp = (c  & 0x0F) << 12
             | (b1 & 0x3F) <<  6
             | (b2 & 0x3F);

      if (0x3000 <= cp && cp <= 0x30FF ||
          0x3300 <= cp && cp <= 0x9FFF ||
          0xFF00 <= cp && cp <= 0xFF60) {
        count++;
      }
    }
  }

  printf("%d\n", count);
  return 0;
}
