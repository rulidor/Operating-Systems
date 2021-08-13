//*****************TEST FOR TASK 2.5 - SIGNALS********************
#define SIG_DFL 0 /* default signal handling */
#define SIG_IGN 1 /* ignore signal */
#define SIGKILL 9
#define SIGSTOP 17
#define SIGCONT 19

#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

struct sigaction{
  void (*sa_handler)(int);
  uint sigmask;
};


void test1(){
    printf("running test1. expected: child print some 'c'->stop->continue.\n");
    sleep(30);
  int pid = fork();
  if(pid == 0){
    for(int i=0; i<1000; i++)
      printf("c");
    printf("\n");
    printf("child exits\n");
    exit(0);
  }
  else{
    sleep(2);
    printf("\nSTOP!\n");
    kill(pid, SIGSTOP);
    sleep(30);

    printf("\nCONT!\n");
    kill(pid, SIGCONT);
    // kill(pid, SIGKILL);
    // kill(pid, 4);


    // kill(pid, SIGCONT);
  }
//exit(0);  
}

void test2(){
    printf("running test2. expected: child print some 'c' and killed, not reaching 1000 chars.\n");
    sleep(50);
    int pid = fork();
    if(pid == 0){
        for(int i=0; i<1000; i++)
            printf("c");
        printf("\n");
        printf("child exits\n");
        exit(0);
    }
    else{
        sleep(1);
        kill(pid, SIGKILL);
        printf("\nKILL!\n");
        sleep(30);
    }
}

void user_handler1(){
  printf("user_handler1!\n");
  exit(0);
}
void user_handler2(){
  printf("success!\n");
  exit(0);
}

void user_handler3(){
  printf("user_handler3!\n");
  exit(0);
}
void user_handler4(){
    printf("FAILED!\n");
    exit(0);
}

void test3(){
    printf("running test3. expected: printed some '~' -> 'success!'\n");
    printf("handler1 addr: %d\n", user_handler1);
    printf("handler2 addr: %d\n", user_handler2);

    struct sigaction act;
    struct sigaction oldact;
    act.sa_handler = user_handler2;
    //  act.sa_handler = (void*)&sigret;
    act.sigmask = 0;
    sigaction(4, &act, &oldact);
    int xsatus;

    sleep(30);

    printf("child running...\n");

    int pid = fork();
    if(pid == 0){
        for(int i=0; i<1000; i++){
            printf("~");
        }
        exit(0);
    }
    else{
        sleep(2);
        // wait(&xsatus);

        kill(pid, 4);
        wait(&xsatus);

        // printf("\n\n");
        // sleep(30);
    }
}

void test4(){
    printf("running test4. expected: '09377'\n");
    int xsatus;
    sleep(30);

    fprintf(1, "%d", sigprocmask(9));
    fprintf(1, "%d", sigprocmask(3));
    fprintf(1, "%d", sigprocmask(7));

    int pid = fork();
    if(pid == 0){
      fprintf(1, "%d", sigprocmask(1));
      sleep(5);
    }
    else
    {
        wait(&xsatus);
        fprintf(1, "%d\n", sigprocmask(1));
    }
}

void test5(){
    printf("running test5 - restoring previous handlers using the sigaction oldact. expected: printed some '~' -> 'success!'\n");
    printf("handler1 addr: %d\n", user_handler1);
    printf("handler2 addr: %d\n", user_handler2);
    printf("handler3 addr: %d\n", user_handler3);

    sleep(30);

    struct sigaction act;
    struct sigaction oldact;
    act.sa_handler = user_handler2;
    act.sigmask = 0;

    int pid = fork();
    if(pid == 0){
        sigaction(4, &act, &oldact); //now oldact.handler adrs should be 0.
        act.sa_handler = user_handler3;
        sigaction(4, &act, &oldact); //now oldact.handler adrs should be that of user_handler2.

        sigaction(4, &oldact, &act);
        for(int i=0; i<1000; i++)
            printf("~");
        exit(0);
    }else{
        sleep(3);
        kill(pid, 4);
    }

    


}

void test6(){
    printf("running test6 - blocking signals. expected: printed 'success!'\n");
    printf("handler1 addr: %d\n", user_handler1);
    printf("handler2 addr: %d\n", user_handler2);
    printf("handler3 addr: %d\n", user_handler3);

    sleep(30);


    struct sigaction act;
    struct sigaction oldact;
    act.sa_handler = user_handler4;
    act.sigmask = 0;
    sigaction(4, &act, &oldact);

    uint mask = (1 << 4);
    sigprocmask(mask);

    kill(getpid(), 4);

    printf("success!\n");
}



int main(int argc, char **argv)
{


    printf("**testing signals***\n");
    test1();
    sleep(10);
    test2();
    sleep(10);
    test3();
    sleep(10);
    test4();
    sleep(10);
    test5();
    sleep(10);
    test6();

  exit(0);
}




//*****************TEST FOR bsem********************


// #include "kernel/types.h"
// #include "user/user.h"
// #include "kernel/fcntl.h"
// #include "kernel/param.h"

// void func1(int s1, int s2){
//     printf("S1\n");
//     bsem_up(s2);
//     printf("S5\n");
//     bsem_up(s2);
//     printf("S8\n");
//     printf("S9\n");
//     bsem_down(s1);
//     printf("S7\n");
//     bsem_up(s2);
// }   

// void func2(int s1, int s2){
//     bsem_down(s2);
//     printf("got time to run");
//     printf("S2\n");
//     printf("S3\n");
//     bsem_down(s2);
//     printf("S6\n");
//     bsem_up(s1);
//     bsem_down(s2);
//     printf("S4\n");
//     bsem_up(s2);
// }

// int main(){
//     int s1 = bsem_alloc();
//     int s2 = bsem_alloc();
//     bsem_down(s1);
//     bsem_down(s2);
//     // printf("S1: %d S2: %d\n", s1, s2);
//     if (s1 < 0 || s2 < 0){
//         printf("bsem_alloc failed\n");
//     }

//     int pid = fork();

//     if(pid == 0){
//         func1(s1, s2);
//     }
//     else{
//         func2(s1, s2);
//     }
//     // printf("need to print: 1 5 8 9 2 3 6 7 4\n");
//     exit(0);
// }






// //*****************TEST FOR sigaction********************
// #define SIG_DFL 0 /* default signal handling */
// #define SIG_IGN 1 /* ignore signal */
// #define SIGKILL 9
// #define SIGSTOP 17
// #define SIGCONT 19

// #include "kernel/types.h"
// #include "user/user.h"
// #include "kernel/fcntl.h"


// void sig(){
//   printf("sig!\n");
// }

// void test1(){
//   int pid = fork();
//   if(pid == 0){
//     for(int i=0; i<1000; i++)
//       printf("c");
//     printf("\n");
//     printf("child exits\n");
//     exit(0);
//   }
//   else{
//     sleep(2);
//     kill(pid, SIGSTOP);
//     printf("father");
//     sleep(30);

//     kill(pid, SIGCONT);
//     // kill(pid, SIGKILL);
//     // kill(pid, 4);


//     // printf("sending cont\n");
//     // kill(pid, SIGCONT);
//     printf("finished\n");
//   }
// //exit(0);  
// }


// int main(int argc, char **argv)
// {
//   printf("**test\n");
//   // struct sigaction act;
//   // struct sigaction oldact;
//   // act.sa_handler = sig;
//   // //  act.sa_handler = (void*)&sigret;
//   // act.sigmask = 0;
//   // sigaction(4, &act, &oldact);
//   // kill(getpid(), 4);

//   test1();

//   exit(0);
// }

//*****************TEST FOR sigret********************


// #include "kernel/types.h"
// #include "user/user.h"
// #include "kernel/fcntl.h"


// int main(int argc, char **argv)
// {
//   sigret();
//   exit(0);
// }

//*****************TEST FOR sigprocmask********************


// #include "kernel/types.h"
// #include "user/user.h"
// #include "kernel/fcntl.h"


// int main(int argc, char **argv)
// {

//     fprintf(1, "FIRST invoked with 9: old mask returned is %d\n", sigprocmask(9));

//     fprintf(1, "SECOND invoked with 3: old mask returned is %d\n", sigprocmask(3));

//     fprintf(1, "THIRD invoked with 7: old mask returned is %d\n", sigprocmask(7));

//     fprintf(1, "forking\n");

//     int pid = fork();
//     if(pid == 0){
//       fprintf(1, "child's mask changed to %d, expected: 7\n", sigprocmask(1));
//     }
//     else
//     {
//       fprintf(1, "parent's mask stayed to %d, expected: 7\n", sigprocmask(1));
//     }
    




//   exit(0);
// }
