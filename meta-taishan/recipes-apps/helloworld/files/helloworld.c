#include <time.h>
#include <gpiod.h>
#include <unistd.h>

#define GPIO_CHIP "gpiochip0"
#define GPIO_LINE 17  // GPIO17 (物理引脚 11)


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
    struct gpiod_chip *chip;
    struct gpiod_line *line;
    int ret;

    printf("Raspberry Pi 4B GPIO Test using libgpiod\n");

    // 打开 GPIO 芯片
    chip = gpiod_chip_open_by_name(GPIO_CHIP);
    if (!chip) {
        perror("Failed to open GPIO chip");
        return 1;
    }

    // 获取 GPIO 线
    line = gpiod_chip_get_line(chip, GPIO_LINE);
    if (!line) {
        perror("Failed to get GPIO line");
        gpiod_chip_close(chip);
        return 1;
    }

    // 请求输出模式
    ret = gpiod_line_request_output(line, "gpiotest", 0);
    if (ret < 0) {
        perror("Failed to request GPIO line");
        gpiod_chip_close(chip);
        return 1;
    }
    printf("Blinking GPIO %d (Ctrl+C to stop)...\n", GPIO_LINE);
    while(1){
        gpiod_line_set_value(line, 1);
        printf("ON\n");
        sleep(1);
        gpiod_line_set_value(line, 0);
        printf("OFF\n");
        sleep(1);
    }
    gpiod_line_release(line);
    gpiod_chip_close(chip);
    
    return 0;
}
// This program prints "Hello, World!" to the console.