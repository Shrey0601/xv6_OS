#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
  if(argc != 3)
  {
  	exit(0);
  }
  else
  {
  	int m=atoi(argv[1]);
  	int n=atoi(argv[2]);
  	
  	if(m<=0 || n<0 || n>1)
		exit(0);
  	
  	/* fork a child process */
   	   	
  	if(fork()==0)
  	{
  		if(n==0)
  		{
  			sleep(m);
  		}
  		printf("%d: Child\n",getpid());
  	}
  	else
  	{
  		if(n==1)
  		{
  			sleep(m);
  		}
  		printf("%d: Parent\n",getpid());
		wait(0);
  	}
  }
  exit(0);
}