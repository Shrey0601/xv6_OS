#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include <stddef.h>

void func(int n, int x){
	if(n==0){
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
			int temp = x, ans;
			write(fd1[1], &temp, sizeof(temp));
			wait(NULL);
			read(fd2[0], &ans, sizeof(ans));
			close(fd1[0]);
			close(fd1[1]);
			close(fd2[0]);
			close(fd2[1]);
			return func(n-1, ans);
		}
		else{
			int temp, ans;
			read(fd1[0], &temp, sizeof(temp));
			ans = temp;
			ans += getpid();
			printf("%d : %d\n",getpid(),ans);
			write(fd2[1], &ans, sizeof(ans));
			close(fd1[0]);
			close(fd2[0]);
			close(fd1[1]);
			close(fd2[1]);
			return;
		}
	}
	
}

int main(int argc, char* argv[]){
    if(argc!=3){
        exit(0);
    }
    else{
        int n = atoi(argv[1]);
        int x = atoi(argv[2]);
        // printf("%d\n", getpid());
        if(n<=0){
            exit(0);
        }
        printf("%d : %d\n",getpid(), x + getpid());
		func(n-1, x+getpid());
        
    }
    exit(0);
}

