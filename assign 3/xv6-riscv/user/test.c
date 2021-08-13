#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

#define PGSIZE 4096

/*****************************TEST 2*********************************/
void uTest1_allocate_less_than_16_pages(){
    printf("***running test: uTest1_allocate_less_than_16_pages\n");
    char* arr[20];

    for(int i=0;i<10;i++){
        arr[i] = sbrk(PGSIZE);
        printf("arr[i]=0x%x\n",arr[i]);

    }
}

void uTest2_allocate_more_than_16_pages(){
    printf("***running test: uTest2_allocate_more_than_16_pages\n");

    char* arr[20];

    for(int i=0;i<19;i++){ //todo check free space in ram
        arr[i] = sbrk(PGSIZE);
        printf("arr[i]=0x%x\n",arr[i]);

    }
}

/*checks that if trying to access swapped page, than gets pagefault*/
void uTest3_page_fault(){
    printf("***running test: uTest3_page_fault\n");
    char* arr[32];
    
    for(int i=0;i<16;i++){
        arr[i] = sbrk(PGSIZE);
    }

    arr[13][0] = 0; //should not get page fault
    arr[15][0] = 0; //should not get page fault

    for(int i=17;i<30;i++){
        arr[i] = sbrk(PGSIZE);
    }

    //now should throw page faults:
    for(int i=0;i<15;i++){
        arr[i][0] = 0;
    }


}

/*checking that after fork, child process receives its parent's pages and can access/modify them*/
void uTest4_fork(){

    printf("***running test: uTest4_fork\n");
    char* arr[32];
    int status;
    
    for(int i=0;i<10;i++){
        arr[i] = sbrk(PGSIZE);
    }

    int pid= fork();

    if(pid!=0)
        wait(&status);
    else{
    printf("test ok if pagefault hasn't been thrown\n");
    arr[7][0] =1;
    arr[9][0] =1;
    exit(0);
    }
}


int main(int argc, char **argv)
{   
    uTest1_allocate_less_than_16_pages();
    // uTest2_allocate_more_than_16_pages();
    // uTest3_page_fault();
    // uTest4_fork();

    exit(0);
}


/*****************************BASIC TEST*********************************/

// int main(int argc, char **argv)
// {
//     int status;
//     int pid = fork();
//     uint64 *adrs = malloc(sizeof(PGSIZE*10));
//     uint64 *adrs2 = malloc(sizeof(PGSIZE*20));

//     if(pid != 0)
//         wait(&status);

//     printf("adrs=%d\n", adrs);
//     printf("adrs2=%d\n", adrs2);

//     exit(0);
// }
