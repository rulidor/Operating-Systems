#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"




struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table at boot time.
void
procinit(void)
{
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      p->kstack = KSTACK((int) (p - proc));
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  //  struct proc *p = c->thread->parent_proc;
  pop_off();
  return p;
}

// // Return the current struct thread *, or zero if none.
// struct thread*
// mythread(void) {
//   push_off();
//   struct cpu *c = mycpu();
//   struct thread *t = c->thread;
//   pop_off();
//   return t;
// }

int
allocpid() {
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// // Look in the thread table for an UNUSED thread.
// // If found, initialize state required to run in the kernel,
// // and return with t->lock held.
// // If there are no free threads, or a memory allocation fails, return 0.
// static struct thread*
// allocthread(struct proc* p)
// {
//   // struct proc *p = myproc();
//   acquire(&p->lock);

//   struct thread *t;
// //  for(p = proc; p < &proc[NPROC]; p++) {
//     for(t = p->threads[0]; t < p->threads[NTHREAD]; t++) {
//     acquire(&t->lock);
//     if(t->state == TUNUSED) {
//       goto Tfound;
//     }
//     else
//     {
//       release(&t->lock);
//     }
//   }
//   release(&p->lock);
//   return 0;

// Tfound:
//  t->parent_proc = p;
//   t->state = TRUNNABLE;

//   // Allocate a trapframe page.
//   if((p->trapframe = (struct trapframe *)kalloc()) == 0){
//     release(&t->lock);
//     freeproc(p);
//     release(&p->lock);
//     return 0;
//   }
//   //added in assign2:
//   if((p->trapframeBackup = (struct trapframe *)kalloc()) == 0){
//     release(&t->lock);
//     freeproc(p);
//     release(&p->lock);
//     return 0;
//   }
//    // Set up new context to start executing at forkret,
//   // which returns to user space.
//   memset(&p->context, 0, sizeof(p->context));
//   p->context.ra = (uint64)forkret;
//   p->context.sp = p->kstack + PGSIZE;

//   // release(&t->lock); //todo: check if needed

//   // release(&p->lock); //todo: check if needed


//   return t;

// }


// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;
  
  //added in assign2:
  p->signalMask = 0;
  p->signalMaskBackup = 0;
  p-> userHandlerFlag = 0;
  p->pendingSignals = 0;


  //added in assign2:
  for(int i = 0; i<SIGNUM; i++){
    p->sigHandlers[i] = SIG_DFL; 
    p->handlersMask[i] = 0;
  }

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }
  //added in assign2:
  if((p->trapframeBackup = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;
  p->waitingForSem = -1; // added task4

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);
  p->trapframe = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;

  // struct thread *t;

  // for(t = p->threads[0]; t < p->threads[NTHREAD]; t++) {
  //   acquire(&t->lock);
  //   t->state = TUNUSED;
  //   if(t->trapframe)
  //     kfree((void*)t->trapframe);
  //   t->trapframe = 0;
  //   t->chan=0;  
  //   t->killed = 0; 
  //   release(&t->lock);

  // }
  // p->state = UNUSED;
}

// Create a user page table for a given process,
// with no user memory, but with trampoline pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe just below TRAMPOLINE, for trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// od -t xC initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  // allocate one user page and copy init's instructions
  // and data into it.
  uvminit(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;      // user program counter
  p->trapframe->sp = PGSIZE;  // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;

  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *p = myproc();
  // acquire(&p->lock);
  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  // release(&p->lock);
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();
  //  struct thread *t = mythread();


  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;
  
  //added in assign2:
  np->signalMask = p->signalMask;
  for(int i = 0; i<SIGNUM; i++){
    np->sigHandlers[i] = p->sigHandlers[i];
    np->handlersMask[i] = p->handlersMask[i]; 
  }

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);
  //  *(np->threads[0]->trapframe) = *(t->trapframe);

  //duplicate the calling thread:
  // np->threads[0] = allocthread(np);
  // struct thread *nt = np->threads[0];
  // nt->state = RUNNABLE; //thread's state
  // nt->parent_proc = np;
  // nt->trapframe = t->trapframe;
  // nt->context = t->context;  

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);



  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
exit(int status)
{
  struct proc *p = myproc();

  if(p == initproc)
    panic("init exiting");

  // struct thread *t;
  // for(t = p->threads[0]; t < p->threads[NTHREAD]; t++){
  //   if(t->state != TUNUSED){
  //     t->killed = 1;
  //     if(t->state == TSLEEPING){
  //       t->state = TRUNNABLE;
  //     }
  //   }
  // }

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);
  
  acquire(&p->lock);

  p->xstate = status;
  p->state = ZOMBIE;

  // struct thread *t;
  // for(t = p->threads[0]; t < p->threads[NTHREAD]; t++) {
  //   acquire(&t->lock);
  //   t->state = TZOMBIE;
  //   release(&t->lock);
  // }  

  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(uint64 addr)
{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(np = proc; np < &proc[NPROC]; np++){
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
          // Found one.
          pid = np->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
                                  sizeof(np->xstate)) < 0) {
            release(&np->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(np);
          release(&np->lock);
          release(&wait_lock);
          return pid;
        }
        release(&np->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || p->killed){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  
  c->proc = 0;
  for(;;){
    // Avoid deadlock by ensuring that devices can interrupt.
    intr_on();

    for(p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);
      if(p->state == RUNNABLE) { //in threads implementation - remove this line.
        /*
                struct thread *t;
        for(t = p->threads[0]; t < p->threads[NTHREAD]; t++) {
          acquire(&t->lock);
          if(t->state == TEMBRYO) {
            t->state = TRUNNING;
            c->thread = t;
            swtch(&c->context, &t->context);
            t->state = TRUNNABLE;
            c->thread = 0;
          }
          else
          {
            release(&t->lock);
          }
        }  
      } 
        */
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        p->state = RUNNING;
        c->proc = p;
        swtch(&c->context, &p->context);

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
      }
      release(&p->lock);
    }
  }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// void
// sched(void)
// {
//   int intena;
//   struct thread *t = mythread();

//   if(!holding(&t->lock))
//     panic("sched t->lock");
//   if(mycpu()->noff != 1)
//     panic("sched locks");
//   if(t->state == TRUNNING)
//     panic("sched running");
//   if(intr_get())
//     panic("sched interruptible");

//   intena = mycpu()->intena;
//   swtch(&t->context, &mycpu()->context);
//     mycpu()->intena = intena;
// }

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;
  sched();
  release(&p->lock);

  // struct thread *t = mythread();
  // acquire(&t->lock);
  // t->state = TRUNNABLE;
  // sched();
  // release(&t->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        p->state = RUNNABLE;
      }
      release(&p->lock);
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid, int signum)
{
  struct proc *p;
  if(signum>=SIGNUM || signum<0) // CHANGED >= SIGNUM
    return -1;
  uint32 signal = 1 << signum;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      // if (signum == SIGKILL){ // think need to change - move this code to handling signals
      //   printf("**got sigKILL!\n");
      //   //p->killed = 1;
      //   p->pendingSignals = p->pendingSignals | signal;
      //   if(p->state == SLEEPING){
      //     // Wake process from sleep().
      //     p->state = RUNNABLE;
      //   }
      // } // end of move this code..
        // printf("**got sig: %d!\n", signal);
        p->pendingSignals = p->pendingSignals | signal; // logic or?
        // printf("**pending sigs: %d!\n", p->pendingSignals);
        release(&p->lock);
        return 0;
    }
    release(&p->lock);
  }
  return -1;
}

//updates process signal mask. returns old mask.
uint
sigprocmask(uint sigmask)
{
  struct proc *p = myproc();
  uint oldMask = p->signalMask;
  p->signalMask = sigmask;
  return oldMask;
}

//register a new handler for a given signal number (signum).
// sigaction returns 0 on success, on error, -1 is returned.
int sigaction(int signum, const struct sigaction *act, struct sigaction *oldact)
{

  struct sigaction prevAct; //CHANGED
  struct sigaction currAct; //CHANGED

  if(act == 0) //checks if act is null
    return -1; 
  if(signum == SIGKILL || signum == SIGSTOP || signum < 0 || signum >=SIGNUM)
    return -1;  
  if(act->sigmask < 0) // CHANGED < 0
    return -1;  

  struct proc *p = myproc();

  if(oldact < 0) // check CHANGED
    return -1;

  prevAct.sa_handler = p->sigHandlers[signum]; 
  prevAct.sigmask = p->handlersMask[signum]; 
  copyout(p->pagetable, (uint64)oldact, (char*)&prevAct, sizeof(struct sigaction));

  // printf("in sigaction, addr of old is ")
  // oldact->sigmask = p->signalMask;
  // if(!p->sigHandlers[signum]){ //checks if old act is not null
  //   oldact->sa_handler = (void*)p->sigHandlers[signum];
  // }
  //copyin(p->pagetable, (char*)&p->sigHandlers[signum], (uint64)act, sizeof(struct sigaction));

  copyin(p->pagetable, (char*)&currAct, (uint64)act, sizeof(struct sigaction));
  p->sigHandlers[signum] = currAct.sa_handler; 
  p->handlersMask[signum] = currAct.sigmask; 

  // p->sigHandlers[signum] = (void*)act->sa_handler;
  // p->signalMask = act->sigmask;
  
 return 0; //success
}

void sigret (void)
{
  struct proc *p = myproc();
  memmove(p->trapframe, p->trapframeBackup, sizeof(struct trapframe));
  p->signalMask = p->signalMaskBackup;
  p->userHandlerFlag = 0;
}

extern void signal_handler(){
  struct proc *p = myproc();
  uint32 contBit = 1 << SIGCONT;
  uint32 stopBit = 1 << SIGSTOP;
  while( ((p->pendingSignals & stopBit) !=0) && (p->pendingSignals & contBit) == 0 ){
    // printf("***yielding\n");
    yield();
  }

  for(int i=0; i<SIGNUM; i++){
    if( (p->pendingSignals & (1 << i)) == 0 ) //check if signal i is pending
      continue;
    // if( p->pendingSignals & (1 << SIGSTOP) == 1 ) //handling SIGSTOP is in trap.c->usertrapret()
    //   continue;
    if( ( p->signalMask & (1<< i) ) != 0)
      continue;

    if (p->sigHandlers[i] == (void*)SIG_IGN){
      p->pendingSignals ^= (1<<i); //xor, to set the i'th bit to 0
      continue;
    }
    if(p->sigHandlers[i] == (void*)SIG_DFL){
      switch (i)
      {
      case SIGSTOP: // handle this case in start of the function signal_handler
        break;
      case SIGCONT:
        if((p->pendingSignals & (1<< SIGSTOP)) == 0){
          p->pendingSignals ^= (1<<SIGCONT);
          continue;
        }
        //else, STOP bit is on:
        p->pendingSignals ^= (1<<SIGSTOP); //set STOP bit to 0
        p->pendingSignals ^= (1<<SIGCONT); //set CONT bit to 0 
        break;
      default: // kill the proccess 
        // printf("**got sigKILL!\n");
        p->killed = 1;
        if(p->state == SLEEPING){
          // Wake process from sleep().
          p->state = RUNNABLE;
        }
      } // end of move this code..
          break;
    }
    
    else{ //user handler for the signal
      // printf("**user handling\n");

      uint64 handlerPtr;
      copyin(p->pagetable, (char*)&handlerPtr, (uint64)p->sigHandlers[i], sizeof(uint64));

      p->signalMaskBackup = p->signalMask;
      p->signalMask = p->handlersMask[i];

      p->userHandlerFlag = 1;

      p->trapframe->sp = p->trapframe->sp - sizeof(struct trapframe);

      memmove(p->trapframeBackup, p->trapframe, sizeof(struct trapframe));
      p->trapframe->epc = (uint64)p->sigHandlers[i];

      //TODO: reduces sp by length of the function
      //p->trapframe->sp = p->trapframe->sp - (funcEnd-funcStart);

      // copyout(p->pagetable, p->trapframe->sp, (char*)&funcStart, funcEnd-funcStart);

      p->trapframe->a0 = i;
      p->trapframe->ra = p->trapframe->sp;

      p->pendingSignals ^= (1 << i);

    }
  }
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
  
}


//task4 Binary Semaphores

static int semaphore_table[MAX_BSEM] =  
                                   {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
                                    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
                                    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
                                    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
                                    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
                                    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
                                    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
                                    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
                                    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
                                    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
                                    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
                                    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
                                    -1,-1,-1,-1,-1,-1,-1,-1};
//-1 not init
// 0 lock is take - acquired
// 1 lock is free


int bsem_alloc(){
    for(int i =0; i< MAX_BSEM; i++){
      if(semaphore_table[i] == -1){ // free semaphore
        semaphore_table[i] = 1; // unlock semaphore
        return i;
      }
    }
      return -1; // if all full
}

void bsem_free(int semNum){
  semaphore_table[semNum] = -1;
}


// void bsem_down(int semNum){
//     if(semaphore_table[semNum] == -1) // if semaphore wasnt init - not suppose to happend
//       return;
    
//     while(semaphore_table[semNum == 0]){
//       acquire(&wait_lock);
//       sleep(&semaphore_table[semNum], &wait_lock);
//       release(&wait_lock);
//     }
// }

// void bsem_up(int semNum){
//     if(semaphore_table[semNum] == -1) // if semaphore wasnt init - not suppose to happend
//       return;
    
//     if(semaphore_table[semNum] == 1) // lock is free
//       return; // do nothing
//     else{ // lock is taken
//       struct proc *p;
//       for(p = proc; p<&proc[NPROC];p++){
//           acquire(&p->lock);
//           if(p->waitingForSem == semNum){
//             // release(&p->lock);
//             wakeup(&semaphore_table[semNum]);
//           }
//           release(&p->lock);

//       }
//       //no one waits for semaphore
//       semaphore_table[semNum] = 1; // free
//     }
// }

void bsem_down(int semNum){
    if(semaphore_table[semNum] == -1) // if semaphore wasnt init - not suppose to happend
      return;
    // while(true){

    
    if(semaphore_table[semNum] == 1) // lock is free
      semaphore_table[semNum] = 0; // locks and finish
      //break for while
    
    else{ // lock is taken
      struct proc *p = myproc();
      acquire(&p->lock);
      p->waitingForSem = semNum;
      p->state = SLEEPING; // needed?
      sched();
      release(&p->lock);
      // kill(p->pid,SIGSTOP);  // make procces stop
    }
  // } end while
}

void bsem_up(int semNum){
    if(semaphore_table[semNum] == -1) // if semaphore wasnt init - not suppose to happend
      return;
    
    if(semaphore_table[semNum] == 1) // lock is free
      return; // do nothing
  
    else{ // lock is taken
      struct proc *p;
      for(p = proc; p<&proc[NPROC];p++){
          acquire(&p->lock);
          if(p->waitingForSem == semNum){
            p->state = RUNNABLE;
            p->waitingForSem = -1;
            release(&p->lock);
            // kill(p->pid,SIGCONT); // make procces run again
            return; // someone took the semaphore and finish
          }
          release(&p->lock);
      }
      //no one waits for semaphore
      semaphore_table[semNum] = 1; // free
    }
}

/*Calling kthread_create will create a new thread within the context of the calling
process. returns the new thread's id, or -1 in error.
*/
int kthread_create(void (*start_func)(), void* stack){

  return -1;

  // struct thread *t = allocthread(myproc());
  // if(t == 0)
  //   return -1;
  // *t->trapfram = *mythread()->trapframe;
  // t->trapframe->sp = stack;
  // t->trapframe->epc = start_func;
  // t->state = TRUNNABLE;

  // release(&t->lock);
  // return t->id;
}

//returns calling thread id
int kthread_id(){
  return -1;

  // struct thread *t=mythread();
  // return t->id;
}

/*This function terminates the execution of the calling thread. If called by a thread
(even the main thread) while other threads exist within the same process, it shouldn't
terminate the whole process. If it is the last running thread, the process should
terminate.
*/
void kthread_exit(int status){
  // struct thread *t = mythread();
  // struct proc *p = t->parent_proc;

  // struct thread *tempThread;
  // for(tempThread = p->threads[0]; tempThread < p->threads[NTHREAD]; tempThread++) {
  //   acquire(&tempThread->lock);
  //   if( ( tempThread->state == TRUNNING )
  //               && (tempThread->id !=t->id)) {//case it's not the only running thread
  //    // t->killed = 1;
  //    t->state = TZOMBIE;
  //    //todo: free the thread stack
  //    // if(t->state == TZOMBIE) // Wake thread from sleep()
  //    //   t->state = TRUNNABLE;
  //     release(&tempThread->lock);
  //     return;
  //   }
  //   else //case it's the only running thread
  //   {
  //     t->parent_proc->killed = 1;
  //     release(&tempThread->lock);
  //   }
  // }
}

int kthread_join(int thread_id, uint64 status){
  return -1;

  // struct thread *nt;
  // int hasFound;
  // int tid;
  // struct thread *t = mythread();
  // struct proc *p = t->parent_proc;

  // acquire(&wait_lock);

  // for(;;){
  //   // Scan through table looking for exited thread.
  //   hasFound = 0;
  //   for(nt = p->threads[0]; nt < p->threads[NTHREAD]; nt++){
  //     if(nt->id == thread_id){
  //       // make sure the child thread isn't still in exit() or swtch().
  //       acquire(&nt->lock);
  //       hasFound = 1;
  //       if(nt->state == TZOMBIE){
  //         tid = nt->id;
  //         if(status != 0 && copyout(p->pagetable, status, (char *)&nt->xstate,
  //                                 sizeof(nt->xstate)) < 0) {
  //           release(&nt->lock);
  //           release(&wait_lock);
  //           return -1;
  //         }
  //         release(&nt->lock);
  //         release(&wait_lock);
  //         return tid;
  //       }
  //       release(&nt->lock);
  //     }
  //   }

  //   // No point waiting if we don't have any children.
  //   if(!hasFound || t->killed){
  //     release(&wait_lock);
  //     return -1;
  //   }
    
  //   // Wait for the thread to exit.
  //   sleep(t, &wait_lock);  //DOC: wait-sleep
  // }
}