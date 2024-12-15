// sample_gpio
#include <string.h>

#define GPIO_IN (0x80000000)
#define GPIO_OUT (0x80000004)

// CPUレジスタの書き込み
#define reg_write(x, y) \
  *(volatile int *)(x) = y;

// CPUレジスタの読み込み
#define reg_read(x, y) \
  y = *(volatile int *)(x);

// メインプログラム
int main()
{
  int i;
  unsigned int rslt = 0x0;

  // 永久ループ
  while (1)
  {
    reg_write(GPIO_OUT, rslt);
    reg_read(GPIO_OUT, rslt);
    rslt += 1;
    for (i = 0; i < 10; i++)
      ;
  };

  return 0;
}
