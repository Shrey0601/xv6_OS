#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include <stddef.h>

int primes[]={2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97};

int count=0;

void func(int n){
    if(n==1 || count==25){
        return;
    }
    else{
        int fd1[2], fd2[2];

        if (pipe(fd1) < 0) {
           printf("Pipe 1 Failed");
           exit(0);
        }
        if (pipe(fd2) < 0) {
           printf("Pipe 2 Failed");
           exit(0);
        }
		int ret = fork();
		if(ret > 0){
			write(fd1[1], &n, sizeof(n));
			wait(NULL);
			read(fd2[0], &n, sizeof(n));
			close(fd1[0]);
			close(fd1[1]);
			close(fd2[0]);
			close(fd2[1]);
            count++;
            return func(n);
		}
		else{
            int temp;
			read(fd1[0], &temp, sizeof(temp));
            int div = primes[count];
            int num = 0;
			while(temp%div==0){
                printf("%d ", div);
                temp/=div;
                num++;
            }
            if(num>0){
                printf("[%d]\n", getpid());
            }
			write(fd2[1], &temp, sizeof(temp));
			close(fd1[0]);
			close(fd2[0]);
			close(fd1[1]);
			close(fd2[1]);
			return;
		}
	}
}

int main(int argc, char* argv[]){

    if(argc!=2){
        exit(0);
    }
    else{
        int n = atoi(argv[1]);
        while(1){
            int num = 0;
            while(n%primes[count]==0){
                printf("%d ", primes[count]);
                n/=primes[count];
                num++;
            }
            if(num>0){
                printf("[%d]\n", getpid());
                break;
            }
            count++;
        }

        func(n);

    }


    exit(0);
}