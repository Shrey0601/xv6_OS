#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "buffer.h"


// Variables for semaphore Bounded Buffer problem

int buffer[20];

int fill;
int use;
struct semaphore empty;
struct semaphore full;
struct semaphore pro;
struct semaphore con;

struct sleeplock lk;


// Variables for conditional variable Bounded Buffer problem

int tail;
int head;
struct sleeplock insert;
struct sleeplock delete;
struct sleeplock print;

struct buffer_elem buff[20];


struct barrier barr[10];

// Can we use struct spinlock here and use it while allocation


uint64 
sys_barrier(void)
{

  int barr_inst, barr_id, n;
  if(argint(0, &barr_inst) < 0){
    return -1;
  }

  if(argint(1, &barr_id) < 0){
    return -1;
  }

  if(argint(2, &n) < 0){
    return -1;
  }

  if(barr[barr_id].counter == -1){
    printf("Barrier array id not allocated\n");
    return -1;
  }

  acquiresleep(&barr[barr_id].lock);

  barr[barr_id].counter ++ ;

  printf("%d: Entered barrier#%d for barrier array id %d\n", myproc()->pid, barr_inst, barr_id);


  if(barr[barr_id].counter != n){
    cond_wait(&barr[barr_id].cv, &barr[barr_id].lock);
  }
  else{
    barr[barr_id].counter = 0;
    cond_broadcast(&barr[barr_id].cv);
  }

  printf("%d: Finished barrier#%d for barrier array id %d\n", myproc()->pid, barr_inst, barr_id);

  releasesleep(&barr[barr_id].lock);

  return 0;
}


uint64 
sys_barrier_alloc(void)
{
    for(int i=0; i<10; ++i){
      acquiresleep(&barr[i].lock);
      if(barr[i].counter == -1){
        barr[i].counter = 0;
        releasesleep(&barr[i].lock);
        return i;
      }
      releasesleep(&barr[i].lock);
    } 
  return -1;
}


uint64 
sys_barrier_free(void)
{
   int barr_id;
   if(argint(0, &barr_id) < 0){
    return -1;
   }
   barr[barr_id].counter = -1;
   initsleeplock(&barr[barr_id].lock, "barrier");
   cond_init(&barr[barr_id].cv);

   return 0;

}

uint64
sys_buffer_cond_init(void){
  // printf("Entered init");
  tail = 0;
  head = 0;
  initsleeplock(&insert, "insert");
  initsleeplock(&delete, "delete");
  initsleeplock(&print, "print");

  for(int i=0;i<20;++i){
    buff[i].x = 0;
    buff[i].full = 0;
    initsleeplock(&buff[i].lock, "buffer lock");
    cond_init(&buff[i].inserted);
    cond_init(&buff[i].deleted);
  }
  // printf("EXITED init");

  return 0;
}

int q = 0;

uint64
sys_cond_produce(void){

  // q++;
  // printf("%d ", q); 

  int produce ;
  if(argint(0, &produce) < 0){
    return -1;
  }

  // printf("%d ", q);

  int index;
  acquiresleep(&insert);
  index = tail;
  tail = (tail + 1) % 20;
  releasesleep(&insert);
  acquiresleep(&(buff[index].lock));
  while (buff[index].full) cond_wait(&buff[index].deleted, &buff[index].lock);
  buff[index].x = produce;
  buff[index].full = 1;
  cond_signal(&buff[index].inserted);
  releasesleep(&buff[index].lock);

    
  // acquiresleep(&print);
  // printf("%d ", produce); 
  // releasesleep(&print);  
  return 0; 
}

uint64
sys_cond_consume(void){
  // printf("Entered Consumer\n");
  int index, v;
  acquiresleep(&delete);
  index = head;
  head = (head + 1) % 20;
  releasesleep(&delete);
  acquiresleep(&buff[index].lock);
  while (!buff[index].full) cond_wait(&buff[index].inserted, &buff[index].lock);
  v = buff[index].x;
  buff[index].full = 0;
  cond_signal(&buff[index].deleted);
  releasesleep(&buff[index].lock);
  acquiresleep(&print);
  printf("%d ", v); 
  releasesleep(&print);  
  return 0;
}

uint64
sys_buffer_sem_init(void){
  fill = 0;
  use = 0;
  sem_init(&empty, 20);
  sem_init(&full, 0);
  sem_init(&pro, 1);
  sem_init(&con, 1);
  for(int i=0;i<20;++i){
    buffer[i] = -1;
  }
  return 0;
}

uint64
sys_sem_produce(void){

  int produce;
  if(argint(0, &produce) < 0){
    return -1;
  }
  sem_wait(&empty);
  sem_wait(&pro);
  buffer[fill] = produce;
  fill =(fill+1)%20;
  sem_post(&pro);
  sem_post(&full);
  return 0; 
}

uint64
sys_sem_consume(void){
  sem_wait(&full);
  sem_wait(&con);
  int t = buffer[use];
  use = (use+1)%20;
  sem_post(&con);
  sem_post(&empty);
  acquiresleep(&lk);
  printf("%d ", t);
  releasesleep(&lk);
  return 0;
}


uint64
sys_exit(void)
{
  int n;
  if(argint(0, &n) < 0)
    return -1;
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  if(argaddr(0, &p) < 0)
    return -1;
  return wait(p);
}

uint64
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_getppid(void)
{
  if (myproc()->parent) return myproc()->parent->pid;
  else {
     printf("No parent found.\n");
     return 0;
  }
}

uint64
sys_yield(void)
{
  yield();
  return 0;
}

uint64
sys_getpa(void)
{
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
  return walkaddr(myproc()->pagetable, x) + (x & (PGSIZE - 1));
}

uint64
sys_forkf(void)
{
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
  return forkf(x);
}

uint64
sys_waitpid(void)
{
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    return -1;
  if(argaddr(1, &p) < 0)
    return -1;

  if (x == -1) return wait(p);
  if ((x == 0) || (x < -1)) return -1;
  return waitpid(x, p);
}

uint64
sys_ps(void)
{
   return ps();
}

uint64
sys_pinfo(void)
{
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    return -1;
  if(argaddr(1, &p) < 0)
    return -1;

  if ((x == 0) || (x < -1) || (p == 0)) return -1;
  return pinfo(x, p);
}

uint64
sys_forkp(void)
{
  int x;
  if(argint(0, &x) < 0) return -1;
  return forkp(x);
}

uint64
sys_schedpolicy(void)
{
  int x;
  if(argint(0, &x) < 0) return -1;
  return schedpolicy(x);
}
