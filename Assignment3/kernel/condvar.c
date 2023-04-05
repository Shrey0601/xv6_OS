#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"
#include "condvar.h"

void cond_init(struct cond_t *cv){
    initsleeplock(&cv->lk, "condition variable");
}

void cond_wait(struct cond_t *cv, struct sleeplock *lock){
    condsleep(cv, lock);   
}


void cond_signal(struct cond_t *cv){
    wakeupone(cv);
}


void cond_broadcast(struct cond_t *cv){
    wakeup(cv);      
}

