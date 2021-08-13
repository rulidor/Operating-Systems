struct counting_semaphore{
    int Bsem1;
    int Bsem2;
    int value;
};
void csem_down(struct counting_semaphore *Csem);
void csem_up(struct counting_semaphore *Csem);
int csem_alloc(struct counting_semaphore *Csem, int initVal);
void csem_free(struct counting_semaphore *Csem);
