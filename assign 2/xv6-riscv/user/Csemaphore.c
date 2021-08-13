#include "Csemaphore.h"
// #include "kernel/proc.h"
// #include "kernel/defs.h"
#include "kernel/types.h"
#include "kernel/param.h"
// #include "kernel/memlayout.h"
#include "kernel/riscv.h"
// #include "kernel/spinlock.h"
#include "kernel/defs.h"


// #include "kernel/types.h"
// #include "user/user.h"
// #include "kernel/fcntl.h"



int csem_alloc(struct counting_semaphore *Csem, int initVal){
    // return -1;     //************************todo: fix and remove!
    int Bsem1 = bsem_alloc();
    int Bsem2 = bsem_alloc();
    if( Bsem1 == -1 || Bsem2 == -1) // one of the semaphores is not valid
        return -1;

    Csem->Bsem1 = Bsem1;
    Csem->Bsem2 = Bsem2;
    Csem->value = initVal;
    return 0;
}


void csem_free(struct counting_semaphore *Csem){
    bsem_free(Csem->Bsem1);
    bsem_free(Csem->Bsem2);
}

void csem_down(struct counting_semaphore *Csem){
    bsem_down(Csem->Bsem2);
    bsem_down(Csem->Bsem1);
    Csem->value--;
    if(Csem->value >0){
        bsem_up(Csem->Bsem2);
    }
    bsem_up(Csem->Bsem1);
}



void csem_up(struct counting_semaphore *Csem){
    bsem_down(Csem->Bsem1);
    Csem->value++;
    if(Csem->value ==1){
        bsem_up(Csem->Bsem2);
    }
    bsem_up(Csem->Bsem1);


}





