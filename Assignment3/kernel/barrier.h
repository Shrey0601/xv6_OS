#include "condvar.h"



struct barrier {
    int counter;
    struct cond_t cv;
    struct sleeplock lock;
};




