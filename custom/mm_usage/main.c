#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <sys/types.h>

#define pr_prnt(fmt, ...) printf("parent: " fmt, ## __VA_ARGS__)
#define pr_chld(fmt, ...) printf("child: " fmt, ## __VA_ARGS__)

#define gettid() syscall(SYS_gettid)

void __attribute__((noreturn)) *sleep_while_not(void *xflag)
{
    int *flag = (int *)xflag;

    pr_chld("Hi, im %d\n", (int)gettid());
    pr_chld("Waiting...\n");
    while (*flag == 0)
        ;
    pr_chld("Now im finished. Exiting...\n");
    pthread_exit(0);
}

int __attribute__((noreturn)) main(int argc, char const *argv[])
{
    int parent_done = 0, p_time_sleep = 2;
    pthread_t nt;

    pr_prnt("Hi, im %d\n", (int)gettid());
    pr_prnt("Creating task\n");

    if (pthread_create(&nt, NULL, sleep_while_not, (void *)&parent_done)) {
        pr_prnt("Cannot create task. Exiting...");
        exit(1);
    }

    pr_prnt("Task has been created. Going sleep...\n");
    sleep(p_time_sleep);
    pr_prnt("Now im finished. Exiting...\n");

    parent_done = 1;

    pthread_exit(0);
}
