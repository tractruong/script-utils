#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>
#include <iostream>

//refer from https://linux.die.net/man/2/waitpid

int func_app(int argc, char *argv[])
{
    printf("Child process started \n");
    int i;
    printf("  1. access out of array\n"
           "  2. divide by zero\n"
           "  3. killed by other process\n"
           "  4. normal exit (default case)\n"
           "Select case to run : ");
    scanf("%d",&i);

    switch (i)
    {
    case 1:
    {
        printf("Access out of array\n");
        int arr[10] = { 0 };
        arr[100001] = 100 ;
        break;
    }
    case 2:
    {
        printf("Divide by zero\n");
        int a = 10;
        int b = 0;
        a = a/b;
        break;
    }
    case 3:
    {
        printf("Process %d wait to be killed....\n", getpid());
        while(1);
        break;
    }
    default:
        printf("Normal test\n");
        exit(EXIT_SUCCESS);
        break;
    }
    return 0;
}

int main(int argc, char *argv[])
{
    pid_t pid = fork();
    if (pid == -1) {
        perror("fork");
        exit(EXIT_FAILURE);
    }

    if ( pid == 0 )
    {
        // child process
        func_app(argc, argv);
    }
    else
    {
        // parent process
        int status;
        do {
            pid_t w = waitpid(pid, &status, WUNTRACED | WCONTINUED);
            if (w == -1) {
                perror("waitpid");
                exit(EXIT_FAILURE);
            }
            printf("Child process status changed %d\n", status ) ;

            if (WIFEXITED(status)) {
              printf("exited, status=%d\n", WEXITSTATUS(status));
            } else if (WIFSIGNALED(status)) {
              printf("killed by signal %d - %s\n", WTERMSIG(status), strsignal(WTERMSIG(status)));
            } else if (WIFSTOPPED(status)) {
                printf("stopped by signal %d - %s\n", WSTOPSIG(status), strsignal(WSTOPSIG(status)));
            } else if (WIFCONTINUED(status)) {
                printf("continued\n");
            }
        } while (!WIFEXITED(status) && !WIFSIGNALED(status));
    }
    exit(EXIT_SUCCESS);
    return 0;
}

