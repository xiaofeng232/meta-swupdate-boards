#include <time.h>
#include <stdio.h>

void delay(int milliseconds) {
    struct timespec req, rem;
    req.tv_sec = milliseconds / 1000;
    req.tv_nsec = (milliseconds % 1000) * 1000000L;
        if (nanosleep(&req, &rem) == -1) {
        printf("Sleep interrupted, remaining time: %ld seconds and %ld nanoseconds\n",
               rem.tv_sec, rem.tv_nsec);
    }
}

int main() {
    printf("Hello, World!\n");
    while(1){
        time_t t;
        time(&t);
        printf("Hello, World!: %lld\n", (long long)t);
        delay(1000);
    }
    return 0;
}
// This program prints "Hello, World!" to the console.