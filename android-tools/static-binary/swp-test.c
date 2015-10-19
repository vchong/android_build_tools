#include<stdio.h>
#include<unistd.h>

void swp_smoke()
{
   int result, in, mem;
   int *addr = &mem;
   in = 2;
   mem = 3;
   asm ("swp %0, %1, [%2]"
        : "=r"(result)
        : "r"(in), "r"(addr)
        : "memory");

   printf("command: swp result, in, addr\n");
   printf("in=2\nmem=3\n");
   printf("result: %d\nin: %d\nmem: %d\n", result, in, mem);
   if (mem==in && result==3) {
       printf("swp-smoke: pass\n");
   } else {
       printf("swp-smoke: fail\n");
   }
}

void swpb_smoke()
{
   char result, in, mem;
   char *addr = &mem;
   in = 2;
   mem = 3;
   asm ("swpb %0, %1, [%2]"
        : "=r"(result)
        : "r"(in), "r"(addr)
        : "memory");

   printf("command: swpb result, in, addr\n");
   printf("in=2\nmem=3\n");
   printf("result: %d\nin: %d\nmem: %d\n", result, in, mem);
   if (mem==in && result==3) {
       printf("swpb-smoke: pass\n");
   } else {
       printf("swpb-smoke: fail\n");
   }

}

int main()
{
    swp_smoke();
    swpb_smoke();
}
