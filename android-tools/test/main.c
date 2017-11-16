#include <stdio.h>
#include <stdlib.h>

/* test using the following allocation sizes */
const size_t allocSizes[] = {
//    1 << 8,     // small
//    1 << 16,    // large
    1 << 23     // huge
};

int iterations = 1;
int main() {
    //printf("pointer size=%lu\n", sizeof(void *));

    for(int j=0; j<iterations; j++){
        for(int index = 0; index < 3; index++){
            void* p = malloc(allocSizes[index]);
            printf("size=%zu, index=%d, p=%p, j=%d\n", allocSizes[index], index, p, j);
            free(p);
        }
    }
    printf("=====================================\n");
    for(int index = 0; index<3; index++){
        for(int j=0; j<iterations; j++){
            void* p = malloc(allocSizes[index]);
            printf("size=%zu, index=%d, p=%p, j=%d\n", allocSizes[index], index, p, j);
            free(p);
        }
    }
    return 0;
}
