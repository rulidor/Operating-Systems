#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

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
sys_kthread_create(void)
{
  uint64 start_func;
  uint64 stack;
  if(argaddr(0, &start_func) < 0)
    return -1;
  if(argaddr(1, &stack) < 0)
    return -1;
  return kthread_create((void*)start_func, &stack);
}

uint64
sys_kthread_id(void){
  return kthread_id();
}

uint64
sys_kthread_exit(void)
{
  int status;
  if(argint(0, &status) < 0)
    return -1;
  kthread_exit(status);
  return 0;
}

uint64
sys_kthread_join(void)
{
  int thread_id;
  uint64 status;
  //int* status;
  if(argint(0, &thread_id) < 0)
    return -1;
  if(argaddr(1, &status) < 0)
    return -1;
  return kthread_join(thread_id, status);
}

uint64
sys_bsem_alloc(void)
{
  return bsem_alloc();
}

uint64
sys_bsem_free(void)
{
  int semNum;
  if(argint(0, &semNum) < 0)
    return -1;
  bsem_free(semNum);
  return 0;
}

uint64
sys_bsem_down(void)
{
  int semNum;
  if(argint(0, &semNum) < 0)
    return -1;
  bsem_down(semNum);
  return 0;
}

uint64
sys_bsem_up(void)
{
  int semNum;
  if(argint(0, &semNum) < 0)
    return -1;
  bsem_up(semNum);
  return 0;
}

//on success returns old mask. else - returns -1.
uint64
sys_sigprocmask(void)
{
  int sigmask;
  if(argint(0, &sigmask) < 0)
    return -1;
  return sigprocmask(sigmask);
}

//register a new handler for a given signal number (signum).
// sigaction returns 0 on success, on error, -1 is returned.
uint64
sys_sigaction(void)
{
  int signum;
  uint64 act;
  uint64 oldact;
  if(argint(0, &signum) < 0)
    return -1;
  if(argaddr(1, &act) < 0)
    return -1;
  if(argaddr(2, &oldact) < 0)
    return -1;

  return sigaction(signum, (struct sigaction*)act, (struct sigaction*)oldact);
}

uint64
sys_sigret(void)
{
  sigret();
  return 0;
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
  int signum;

  if(argint(0, &pid) < 0)
    return -1;
  if(argint(1, &signum) < 0)
    return -1;
  return kill(pid, signum);
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
