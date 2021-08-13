
user/_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <uTest1_allocate_less_than_16_pages>:
#include "kernel/fcntl.h"

#define PGSIZE 4096

/*****************************TEST 2*********************************/
void uTest1_allocate_less_than_16_pages(){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
    printf("***running test: uTest1_allocate_less_than_16_pages\n");
   c:	00001517          	auipc	a0,0x1
  10:	93c50513          	addi	a0,a0,-1732 # 948 <malloc+0xea>
  14:	00000097          	auipc	ra,0x0
  18:	78c080e7          	jalr	1932(ra) # 7a0 <printf>
  1c:	44a9                	li	s1,10
    char* arr[20];

    for(int i=0;i<10;i++){
        arr[i] = sbrk(PGSIZE);
        printf("arr[i]=0x%x\n",arr[i]);
  1e:	00001917          	auipc	s2,0x1
  22:	96290913          	addi	s2,s2,-1694 # 980 <malloc+0x122>
        arr[i] = sbrk(PGSIZE);
  26:	6505                	lui	a0,0x1
  28:	00000097          	auipc	ra,0x0
  2c:	488080e7          	jalr	1160(ra) # 4b0 <sbrk>
  30:	85aa                	mv	a1,a0
        printf("arr[i]=0x%x\n",arr[i]);
  32:	854a                	mv	a0,s2
  34:	00000097          	auipc	ra,0x0
  38:	76c080e7          	jalr	1900(ra) # 7a0 <printf>
    for(int i=0;i<10;i++){
  3c:	34fd                	addiw	s1,s1,-1
  3e:	f4e5                	bnez	s1,26 <uTest1_allocate_less_than_16_pages+0x26>

    }
}
  40:	60e2                	ld	ra,24(sp)
  42:	6442                	ld	s0,16(sp)
  44:	64a2                	ld	s1,8(sp)
  46:	6902                	ld	s2,0(sp)
  48:	6105                	addi	sp,sp,32
  4a:	8082                	ret

000000000000004c <uTest2_allocate_more_than_16_pages>:

void uTest2_allocate_more_than_16_pages(){
  4c:	1101                	addi	sp,sp,-32
  4e:	ec06                	sd	ra,24(sp)
  50:	e822                	sd	s0,16(sp)
  52:	e426                	sd	s1,8(sp)
  54:	e04a                	sd	s2,0(sp)
  56:	1000                	addi	s0,sp,32
    printf("***running test: uTest2_allocate_more_than_16_pages\n");
  58:	00001517          	auipc	a0,0x1
  5c:	93850513          	addi	a0,a0,-1736 # 990 <malloc+0x132>
  60:	00000097          	auipc	ra,0x0
  64:	740080e7          	jalr	1856(ra) # 7a0 <printf>
  68:	44cd                	li	s1,19

    char* arr[20];

    for(int i=0;i<19;i++){ //todo check free space in ram
        arr[i] = sbrk(PGSIZE);
        printf("arr[i]=0x%x\n",arr[i]);
  6a:	00001917          	auipc	s2,0x1
  6e:	91690913          	addi	s2,s2,-1770 # 980 <malloc+0x122>
        arr[i] = sbrk(PGSIZE);
  72:	6505                	lui	a0,0x1
  74:	00000097          	auipc	ra,0x0
  78:	43c080e7          	jalr	1084(ra) # 4b0 <sbrk>
  7c:	85aa                	mv	a1,a0
        printf("arr[i]=0x%x\n",arr[i]);
  7e:	854a                	mv	a0,s2
  80:	00000097          	auipc	ra,0x0
  84:	720080e7          	jalr	1824(ra) # 7a0 <printf>
    for(int i=0;i<19;i++){ //todo check free space in ram
  88:	34fd                	addiw	s1,s1,-1
  8a:	f4e5                	bnez	s1,72 <uTest2_allocate_more_than_16_pages+0x26>

    }
}
  8c:	60e2                	ld	ra,24(sp)
  8e:	6442                	ld	s0,16(sp)
  90:	64a2                	ld	s1,8(sp)
  92:	6902                	ld	s2,0(sp)
  94:	6105                	addi	sp,sp,32
  96:	8082                	ret

0000000000000098 <uTest3_page_fault>:

/*checks that if trying to access swapped page, than gets pagefault*/
void uTest3_page_fault(){
  98:	7169                	addi	sp,sp,-304
  9a:	f606                	sd	ra,296(sp)
  9c:	f222                	sd	s0,288(sp)
  9e:	ee26                	sd	s1,280(sp)
  a0:	ea4a                	sd	s2,272(sp)
  a2:	e64e                	sd	s3,264(sp)
  a4:	1a00                	addi	s0,sp,304
    printf("***running test: uTest3_page_fault\n");
  a6:	00001517          	auipc	a0,0x1
  aa:	92250513          	addi	a0,a0,-1758 # 9c8 <malloc+0x16a>
  ae:	00000097          	auipc	ra,0x0
  b2:	6f2080e7          	jalr	1778(ra) # 7a0 <printf>
    char* arr[32];
    
    for(int i=0;i<16;i++){
  b6:	ed040913          	addi	s2,s0,-304
  ba:	f5040993          	addi	s3,s0,-176
    printf("***running test: uTest3_page_fault\n");
  be:	84ca                	mv	s1,s2
        arr[i] = sbrk(PGSIZE);
  c0:	6505                	lui	a0,0x1
  c2:	00000097          	auipc	ra,0x0
  c6:	3ee080e7          	jalr	1006(ra) # 4b0 <sbrk>
  ca:	e088                	sd	a0,0(s1)
    for(int i=0;i<16;i++){
  cc:	04a1                	addi	s1,s1,8
  ce:	ff3499e3          	bne	s1,s3,c0 <uTest3_page_fault+0x28>
    }

    arr[13][0] = 0; //should not get page fault
  d2:	f3843783          	ld	a5,-200(s0)
  d6:	00078023          	sb	zero,0(a5)
    arr[15][0] = 0; //should not get page fault
  da:	f4843783          	ld	a5,-184(s0)
  de:	00078023          	sb	zero,0(a5)

    for(int i=17;i<30;i++){
  e2:	f5840493          	addi	s1,s0,-168
  e6:	0f090993          	addi	s3,s2,240
        arr[i] = sbrk(PGSIZE);
  ea:	6505                	lui	a0,0x1
  ec:	00000097          	auipc	ra,0x0
  f0:	3c4080e7          	jalr	964(ra) # 4b0 <sbrk>
  f4:	e088                	sd	a0,0(s1)
    for(int i=17;i<30;i++){
  f6:	04a1                	addi	s1,s1,8
  f8:	ff3499e3          	bne	s1,s3,ea <uTest3_page_fault+0x52>
  fc:	07890713          	addi	a4,s2,120
    }

    //now should throw page faults:
    for(int i=0;i<15;i++){
        arr[i][0] = 0;
 100:	00093783          	ld	a5,0(s2)
 104:	00078023          	sb	zero,0(a5)
    for(int i=0;i<15;i++){
 108:	0921                	addi	s2,s2,8
 10a:	fee91be3          	bne	s2,a4,100 <uTest3_page_fault+0x68>
    }


}
 10e:	70b2                	ld	ra,296(sp)
 110:	7412                	ld	s0,288(sp)
 112:	64f2                	ld	s1,280(sp)
 114:	6952                	ld	s2,272(sp)
 116:	69b2                	ld	s3,264(sp)
 118:	6155                	addi	sp,sp,304
 11a:	8082                	ret

000000000000011c <uTest4_fork>:

/*checking that after fork, child process receives its parent's pages and can access/modify them*/
void uTest4_fork(){
 11c:	7169                	addi	sp,sp,-304
 11e:	f606                	sd	ra,296(sp)
 120:	f222                	sd	s0,288(sp)
 122:	ee26                	sd	s1,280(sp)
 124:	ea4a                	sd	s2,272(sp)
 126:	1a00                	addi	s0,sp,304

    printf("***running test: uTest4_fork\n");
 128:	00001517          	auipc	a0,0x1
 12c:	8c850513          	addi	a0,a0,-1848 # 9f0 <malloc+0x192>
 130:	00000097          	auipc	ra,0x0
 134:	670080e7          	jalr	1648(ra) # 7a0 <printf>
    char* arr[32];
    int status;
    
    for(int i=0;i<10;i++){
 138:	ee040493          	addi	s1,s0,-288
 13c:	f3040913          	addi	s2,s0,-208
        arr[i] = sbrk(PGSIZE);
 140:	6505                	lui	a0,0x1
 142:	00000097          	auipc	ra,0x0
 146:	36e080e7          	jalr	878(ra) # 4b0 <sbrk>
 14a:	e088                	sd	a0,0(s1)
    for(int i=0;i<10;i++){
 14c:	04a1                	addi	s1,s1,8
 14e:	ff2499e3          	bne	s1,s2,140 <uTest4_fork+0x24>
    }

    int pid= fork();
 152:	00000097          	auipc	ra,0x0
 156:	2ce080e7          	jalr	718(ra) # 420 <fork>

    if(pid!=0)
 15a:	cd09                	beqz	a0,174 <uTest4_fork+0x58>
        wait(&status);
 15c:	edc40513          	addi	a0,s0,-292
 160:	00000097          	auipc	ra,0x0
 164:	2d0080e7          	jalr	720(ra) # 430 <wait>
    printf("test ok if pagefault hasn't been thrown\n");
    arr[7][0] =1;
    arr[9][0] =1;
    exit(0);
    }
}
 168:	70b2                	ld	ra,296(sp)
 16a:	7412                	ld	s0,288(sp)
 16c:	64f2                	ld	s1,280(sp)
 16e:	6952                	ld	s2,272(sp)
 170:	6155                	addi	sp,sp,304
 172:	8082                	ret
    printf("test ok if pagefault hasn't been thrown\n");
 174:	00001517          	auipc	a0,0x1
 178:	89c50513          	addi	a0,a0,-1892 # a10 <malloc+0x1b2>
 17c:	00000097          	auipc	ra,0x0
 180:	624080e7          	jalr	1572(ra) # 7a0 <printf>
    arr[7][0] =1;
 184:	4785                	li	a5,1
 186:	f1843703          	ld	a4,-232(s0)
 18a:	00f70023          	sb	a5,0(a4)
    arr[9][0] =1;
 18e:	f2843703          	ld	a4,-216(s0)
 192:	00f70023          	sb	a5,0(a4)
    exit(0);
 196:	4501                	li	a0,0
 198:	00000097          	auipc	ra,0x0
 19c:	290080e7          	jalr	656(ra) # 428 <exit>

00000000000001a0 <main>:


int main(int argc, char **argv)
{   
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e406                	sd	ra,8(sp)
 1a4:	e022                	sd	s0,0(sp)
 1a6:	0800                	addi	s0,sp,16
    uTest1_allocate_less_than_16_pages();
 1a8:	00000097          	auipc	ra,0x0
 1ac:	e58080e7          	jalr	-424(ra) # 0 <uTest1_allocate_less_than_16_pages>
    // uTest2_allocate_more_than_16_pages();
    // uTest3_page_fault();
    // uTest4_fork();

    exit(0);
 1b0:	4501                	li	a0,0
 1b2:	00000097          	auipc	ra,0x0
 1b6:	276080e7          	jalr	630(ra) # 428 <exit>

00000000000001ba <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1c0:	87aa                	mv	a5,a0
 1c2:	0585                	addi	a1,a1,1
 1c4:	0785                	addi	a5,a5,1
 1c6:	fff5c703          	lbu	a4,-1(a1)
 1ca:	fee78fa3          	sb	a4,-1(a5)
 1ce:	fb75                	bnez	a4,1c2 <strcpy+0x8>
    ;
  return os;
}
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret

00000000000001d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1dc:	00054783          	lbu	a5,0(a0)
 1e0:	cb91                	beqz	a5,1f4 <strcmp+0x1e>
 1e2:	0005c703          	lbu	a4,0(a1)
 1e6:	00f71763          	bne	a4,a5,1f4 <strcmp+0x1e>
    p++, q++;
 1ea:	0505                	addi	a0,a0,1
 1ec:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ee:	00054783          	lbu	a5,0(a0)
 1f2:	fbe5                	bnez	a5,1e2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1f4:	0005c503          	lbu	a0,0(a1)
}
 1f8:	40a7853b          	subw	a0,a5,a0
 1fc:	6422                	ld	s0,8(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret

0000000000000202 <strlen>:

uint
strlen(const char *s)
{
 202:	1141                	addi	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 208:	00054783          	lbu	a5,0(a0)
 20c:	cf91                	beqz	a5,228 <strlen+0x26>
 20e:	0505                	addi	a0,a0,1
 210:	87aa                	mv	a5,a0
 212:	4685                	li	a3,1
 214:	9e89                	subw	a3,a3,a0
 216:	00f6853b          	addw	a0,a3,a5
 21a:	0785                	addi	a5,a5,1
 21c:	fff7c703          	lbu	a4,-1(a5)
 220:	fb7d                	bnez	a4,216 <strlen+0x14>
    ;
  return n;
}
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret
  for(n = 0; s[n]; n++)
 228:	4501                	li	a0,0
 22a:	bfe5                	j	222 <strlen+0x20>

000000000000022c <memset>:

void*
memset(void *dst, int c, uint n)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 232:	ca19                	beqz	a2,248 <memset+0x1c>
 234:	87aa                	mv	a5,a0
 236:	1602                	slli	a2,a2,0x20
 238:	9201                	srli	a2,a2,0x20
 23a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 23e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 242:	0785                	addi	a5,a5,1
 244:	fee79de3          	bne	a5,a4,23e <memset+0x12>
  }
  return dst;
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret

000000000000024e <strchr>:

char*
strchr(const char *s, char c)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e422                	sd	s0,8(sp)
 252:	0800                	addi	s0,sp,16
  for(; *s; s++)
 254:	00054783          	lbu	a5,0(a0)
 258:	cb99                	beqz	a5,26e <strchr+0x20>
    if(*s == c)
 25a:	00f58763          	beq	a1,a5,268 <strchr+0x1a>
  for(; *s; s++)
 25e:	0505                	addi	a0,a0,1
 260:	00054783          	lbu	a5,0(a0)
 264:	fbfd                	bnez	a5,25a <strchr+0xc>
      return (char*)s;
  return 0;
 266:	4501                	li	a0,0
}
 268:	6422                	ld	s0,8(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret
  return 0;
 26e:	4501                	li	a0,0
 270:	bfe5                	j	268 <strchr+0x1a>

0000000000000272 <gets>:

char*
gets(char *buf, int max)
{
 272:	711d                	addi	sp,sp,-96
 274:	ec86                	sd	ra,88(sp)
 276:	e8a2                	sd	s0,80(sp)
 278:	e4a6                	sd	s1,72(sp)
 27a:	e0ca                	sd	s2,64(sp)
 27c:	fc4e                	sd	s3,56(sp)
 27e:	f852                	sd	s4,48(sp)
 280:	f456                	sd	s5,40(sp)
 282:	f05a                	sd	s6,32(sp)
 284:	ec5e                	sd	s7,24(sp)
 286:	1080                	addi	s0,sp,96
 288:	8baa                	mv	s7,a0
 28a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 28c:	892a                	mv	s2,a0
 28e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 290:	4aa9                	li	s5,10
 292:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 294:	89a6                	mv	s3,s1
 296:	2485                	addiw	s1,s1,1
 298:	0344d863          	bge	s1,s4,2c8 <gets+0x56>
    cc = read(0, &c, 1);
 29c:	4605                	li	a2,1
 29e:	faf40593          	addi	a1,s0,-81
 2a2:	4501                	li	a0,0
 2a4:	00000097          	auipc	ra,0x0
 2a8:	19c080e7          	jalr	412(ra) # 440 <read>
    if(cc < 1)
 2ac:	00a05e63          	blez	a0,2c8 <gets+0x56>
    buf[i++] = c;
 2b0:	faf44783          	lbu	a5,-81(s0)
 2b4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2b8:	01578763          	beq	a5,s5,2c6 <gets+0x54>
 2bc:	0905                	addi	s2,s2,1
 2be:	fd679be3          	bne	a5,s6,294 <gets+0x22>
  for(i=0; i+1 < max; ){
 2c2:	89a6                	mv	s3,s1
 2c4:	a011                	j	2c8 <gets+0x56>
 2c6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2c8:	99de                	add	s3,s3,s7
 2ca:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ce:	855e                	mv	a0,s7
 2d0:	60e6                	ld	ra,88(sp)
 2d2:	6446                	ld	s0,80(sp)
 2d4:	64a6                	ld	s1,72(sp)
 2d6:	6906                	ld	s2,64(sp)
 2d8:	79e2                	ld	s3,56(sp)
 2da:	7a42                	ld	s4,48(sp)
 2dc:	7aa2                	ld	s5,40(sp)
 2de:	7b02                	ld	s6,32(sp)
 2e0:	6be2                	ld	s7,24(sp)
 2e2:	6125                	addi	sp,sp,96
 2e4:	8082                	ret

00000000000002e6 <stat>:

int
stat(const char *n, struct stat *st)
{
 2e6:	1101                	addi	sp,sp,-32
 2e8:	ec06                	sd	ra,24(sp)
 2ea:	e822                	sd	s0,16(sp)
 2ec:	e426                	sd	s1,8(sp)
 2ee:	e04a                	sd	s2,0(sp)
 2f0:	1000                	addi	s0,sp,32
 2f2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2f4:	4581                	li	a1,0
 2f6:	00000097          	auipc	ra,0x0
 2fa:	172080e7          	jalr	370(ra) # 468 <open>
  if(fd < 0)
 2fe:	02054563          	bltz	a0,328 <stat+0x42>
 302:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 304:	85ca                	mv	a1,s2
 306:	00000097          	auipc	ra,0x0
 30a:	17a080e7          	jalr	378(ra) # 480 <fstat>
 30e:	892a                	mv	s2,a0
  close(fd);
 310:	8526                	mv	a0,s1
 312:	00000097          	auipc	ra,0x0
 316:	13e080e7          	jalr	318(ra) # 450 <close>
  return r;
}
 31a:	854a                	mv	a0,s2
 31c:	60e2                	ld	ra,24(sp)
 31e:	6442                	ld	s0,16(sp)
 320:	64a2                	ld	s1,8(sp)
 322:	6902                	ld	s2,0(sp)
 324:	6105                	addi	sp,sp,32
 326:	8082                	ret
    return -1;
 328:	597d                	li	s2,-1
 32a:	bfc5                	j	31a <stat+0x34>

000000000000032c <atoi>:

int
atoi(const char *s)
{
 32c:	1141                	addi	sp,sp,-16
 32e:	e422                	sd	s0,8(sp)
 330:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 332:	00054603          	lbu	a2,0(a0)
 336:	fd06079b          	addiw	a5,a2,-48
 33a:	0ff7f793          	andi	a5,a5,255
 33e:	4725                	li	a4,9
 340:	02f76963          	bltu	a4,a5,372 <atoi+0x46>
 344:	86aa                	mv	a3,a0
  n = 0;
 346:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 348:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 34a:	0685                	addi	a3,a3,1
 34c:	0025179b          	slliw	a5,a0,0x2
 350:	9fa9                	addw	a5,a5,a0
 352:	0017979b          	slliw	a5,a5,0x1
 356:	9fb1                	addw	a5,a5,a2
 358:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 35c:	0006c603          	lbu	a2,0(a3)
 360:	fd06071b          	addiw	a4,a2,-48
 364:	0ff77713          	andi	a4,a4,255
 368:	fee5f1e3          	bgeu	a1,a4,34a <atoi+0x1e>
  return n;
}
 36c:	6422                	ld	s0,8(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret
  n = 0;
 372:	4501                	li	a0,0
 374:	bfe5                	j	36c <atoi+0x40>

0000000000000376 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 376:	1141                	addi	sp,sp,-16
 378:	e422                	sd	s0,8(sp)
 37a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 37c:	02b57463          	bgeu	a0,a1,3a4 <memmove+0x2e>
    while(n-- > 0)
 380:	00c05f63          	blez	a2,39e <memmove+0x28>
 384:	1602                	slli	a2,a2,0x20
 386:	9201                	srli	a2,a2,0x20
 388:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 38c:	872a                	mv	a4,a0
      *dst++ = *src++;
 38e:	0585                	addi	a1,a1,1
 390:	0705                	addi	a4,a4,1
 392:	fff5c683          	lbu	a3,-1(a1)
 396:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 39a:	fee79ae3          	bne	a5,a4,38e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 39e:	6422                	ld	s0,8(sp)
 3a0:	0141                	addi	sp,sp,16
 3a2:	8082                	ret
    dst += n;
 3a4:	00c50733          	add	a4,a0,a2
    src += n;
 3a8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3aa:	fec05ae3          	blez	a2,39e <memmove+0x28>
 3ae:	fff6079b          	addiw	a5,a2,-1
 3b2:	1782                	slli	a5,a5,0x20
 3b4:	9381                	srli	a5,a5,0x20
 3b6:	fff7c793          	not	a5,a5
 3ba:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3bc:	15fd                	addi	a1,a1,-1
 3be:	177d                	addi	a4,a4,-1
 3c0:	0005c683          	lbu	a3,0(a1)
 3c4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3c8:	fee79ae3          	bne	a5,a4,3bc <memmove+0x46>
 3cc:	bfc9                	j	39e <memmove+0x28>

00000000000003ce <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ce:	1141                	addi	sp,sp,-16
 3d0:	e422                	sd	s0,8(sp)
 3d2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3d4:	ca05                	beqz	a2,404 <memcmp+0x36>
 3d6:	fff6069b          	addiw	a3,a2,-1
 3da:	1682                	slli	a3,a3,0x20
 3dc:	9281                	srli	a3,a3,0x20
 3de:	0685                	addi	a3,a3,1
 3e0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3e2:	00054783          	lbu	a5,0(a0)
 3e6:	0005c703          	lbu	a4,0(a1)
 3ea:	00e79863          	bne	a5,a4,3fa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3ee:	0505                	addi	a0,a0,1
    p2++;
 3f0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3f2:	fed518e3          	bne	a0,a3,3e2 <memcmp+0x14>
  }
  return 0;
 3f6:	4501                	li	a0,0
 3f8:	a019                	j	3fe <memcmp+0x30>
      return *p1 - *p2;
 3fa:	40e7853b          	subw	a0,a5,a4
}
 3fe:	6422                	ld	s0,8(sp)
 400:	0141                	addi	sp,sp,16
 402:	8082                	ret
  return 0;
 404:	4501                	li	a0,0
 406:	bfe5                	j	3fe <memcmp+0x30>

0000000000000408 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 408:	1141                	addi	sp,sp,-16
 40a:	e406                	sd	ra,8(sp)
 40c:	e022                	sd	s0,0(sp)
 40e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 410:	00000097          	auipc	ra,0x0
 414:	f66080e7          	jalr	-154(ra) # 376 <memmove>
}
 418:	60a2                	ld	ra,8(sp)
 41a:	6402                	ld	s0,0(sp)
 41c:	0141                	addi	sp,sp,16
 41e:	8082                	ret

0000000000000420 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 420:	4885                	li	a7,1
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <exit>:
.global exit
exit:
 li a7, SYS_exit
 428:	4889                	li	a7,2
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <wait>:
.global wait
wait:
 li a7, SYS_wait
 430:	488d                	li	a7,3
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 438:	4891                	li	a7,4
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <read>:
.global read
read:
 li a7, SYS_read
 440:	4895                	li	a7,5
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <write>:
.global write
write:
 li a7, SYS_write
 448:	48c1                	li	a7,16
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <close>:
.global close
close:
 li a7, SYS_close
 450:	48d5                	li	a7,21
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <kill>:
.global kill
kill:
 li a7, SYS_kill
 458:	4899                	li	a7,6
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <exec>:
.global exec
exec:
 li a7, SYS_exec
 460:	489d                	li	a7,7
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <open>:
.global open
open:
 li a7, SYS_open
 468:	48bd                	li	a7,15
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 470:	48c5                	li	a7,17
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 478:	48c9                	li	a7,18
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 480:	48a1                	li	a7,8
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <link>:
.global link
link:
 li a7, SYS_link
 488:	48cd                	li	a7,19
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 490:	48d1                	li	a7,20
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 498:	48a5                	li	a7,9
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4a0:	48a9                	li	a7,10
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4a8:	48ad                	li	a7,11
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4b0:	48b1                	li	a7,12
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4b8:	48b5                	li	a7,13
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4c0:	48b9                	li	a7,14
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4c8:	1101                	addi	sp,sp,-32
 4ca:	ec06                	sd	ra,24(sp)
 4cc:	e822                	sd	s0,16(sp)
 4ce:	1000                	addi	s0,sp,32
 4d0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4d4:	4605                	li	a2,1
 4d6:	fef40593          	addi	a1,s0,-17
 4da:	00000097          	auipc	ra,0x0
 4de:	f6e080e7          	jalr	-146(ra) # 448 <write>
}
 4e2:	60e2                	ld	ra,24(sp)
 4e4:	6442                	ld	s0,16(sp)
 4e6:	6105                	addi	sp,sp,32
 4e8:	8082                	ret

00000000000004ea <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ea:	7139                	addi	sp,sp,-64
 4ec:	fc06                	sd	ra,56(sp)
 4ee:	f822                	sd	s0,48(sp)
 4f0:	f426                	sd	s1,40(sp)
 4f2:	f04a                	sd	s2,32(sp)
 4f4:	ec4e                	sd	s3,24(sp)
 4f6:	0080                	addi	s0,sp,64
 4f8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4fa:	c299                	beqz	a3,500 <printint+0x16>
 4fc:	0805c863          	bltz	a1,58c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 500:	2581                	sext.w	a1,a1
  neg = 0;
 502:	4881                	li	a7,0
 504:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 508:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 50a:	2601                	sext.w	a2,a2
 50c:	00000517          	auipc	a0,0x0
 510:	53c50513          	addi	a0,a0,1340 # a48 <digits>
 514:	883a                	mv	a6,a4
 516:	2705                	addiw	a4,a4,1
 518:	02c5f7bb          	remuw	a5,a1,a2
 51c:	1782                	slli	a5,a5,0x20
 51e:	9381                	srli	a5,a5,0x20
 520:	97aa                	add	a5,a5,a0
 522:	0007c783          	lbu	a5,0(a5)
 526:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 52a:	0005879b          	sext.w	a5,a1
 52e:	02c5d5bb          	divuw	a1,a1,a2
 532:	0685                	addi	a3,a3,1
 534:	fec7f0e3          	bgeu	a5,a2,514 <printint+0x2a>
  if(neg)
 538:	00088b63          	beqz	a7,54e <printint+0x64>
    buf[i++] = '-';
 53c:	fd040793          	addi	a5,s0,-48
 540:	973e                	add	a4,a4,a5
 542:	02d00793          	li	a5,45
 546:	fef70823          	sb	a5,-16(a4)
 54a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 54e:	02e05863          	blez	a4,57e <printint+0x94>
 552:	fc040793          	addi	a5,s0,-64
 556:	00e78933          	add	s2,a5,a4
 55a:	fff78993          	addi	s3,a5,-1
 55e:	99ba                	add	s3,s3,a4
 560:	377d                	addiw	a4,a4,-1
 562:	1702                	slli	a4,a4,0x20
 564:	9301                	srli	a4,a4,0x20
 566:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 56a:	fff94583          	lbu	a1,-1(s2)
 56e:	8526                	mv	a0,s1
 570:	00000097          	auipc	ra,0x0
 574:	f58080e7          	jalr	-168(ra) # 4c8 <putc>
  while(--i >= 0)
 578:	197d                	addi	s2,s2,-1
 57a:	ff3918e3          	bne	s2,s3,56a <printint+0x80>
}
 57e:	70e2                	ld	ra,56(sp)
 580:	7442                	ld	s0,48(sp)
 582:	74a2                	ld	s1,40(sp)
 584:	7902                	ld	s2,32(sp)
 586:	69e2                	ld	s3,24(sp)
 588:	6121                	addi	sp,sp,64
 58a:	8082                	ret
    x = -xx;
 58c:	40b005bb          	negw	a1,a1
    neg = 1;
 590:	4885                	li	a7,1
    x = -xx;
 592:	bf8d                	j	504 <printint+0x1a>

0000000000000594 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 594:	7119                	addi	sp,sp,-128
 596:	fc86                	sd	ra,120(sp)
 598:	f8a2                	sd	s0,112(sp)
 59a:	f4a6                	sd	s1,104(sp)
 59c:	f0ca                	sd	s2,96(sp)
 59e:	ecce                	sd	s3,88(sp)
 5a0:	e8d2                	sd	s4,80(sp)
 5a2:	e4d6                	sd	s5,72(sp)
 5a4:	e0da                	sd	s6,64(sp)
 5a6:	fc5e                	sd	s7,56(sp)
 5a8:	f862                	sd	s8,48(sp)
 5aa:	f466                	sd	s9,40(sp)
 5ac:	f06a                	sd	s10,32(sp)
 5ae:	ec6e                	sd	s11,24(sp)
 5b0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5b2:	0005c903          	lbu	s2,0(a1)
 5b6:	18090f63          	beqz	s2,754 <vprintf+0x1c0>
 5ba:	8aaa                	mv	s5,a0
 5bc:	8b32                	mv	s6,a2
 5be:	00158493          	addi	s1,a1,1
  state = 0;
 5c2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5c4:	02500a13          	li	s4,37
      if(c == 'd'){
 5c8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5cc:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5d0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5d4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d8:	00000b97          	auipc	s7,0x0
 5dc:	470b8b93          	addi	s7,s7,1136 # a48 <digits>
 5e0:	a839                	j	5fe <vprintf+0x6a>
        putc(fd, c);
 5e2:	85ca                	mv	a1,s2
 5e4:	8556                	mv	a0,s5
 5e6:	00000097          	auipc	ra,0x0
 5ea:	ee2080e7          	jalr	-286(ra) # 4c8 <putc>
 5ee:	a019                	j	5f4 <vprintf+0x60>
    } else if(state == '%'){
 5f0:	01498f63          	beq	s3,s4,60e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5f4:	0485                	addi	s1,s1,1
 5f6:	fff4c903          	lbu	s2,-1(s1)
 5fa:	14090d63          	beqz	s2,754 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5fe:	0009079b          	sext.w	a5,s2
    if(state == 0){
 602:	fe0997e3          	bnez	s3,5f0 <vprintf+0x5c>
      if(c == '%'){
 606:	fd479ee3          	bne	a5,s4,5e2 <vprintf+0x4e>
        state = '%';
 60a:	89be                	mv	s3,a5
 60c:	b7e5                	j	5f4 <vprintf+0x60>
      if(c == 'd'){
 60e:	05878063          	beq	a5,s8,64e <vprintf+0xba>
      } else if(c == 'l') {
 612:	05978c63          	beq	a5,s9,66a <vprintf+0xd6>
      } else if(c == 'x') {
 616:	07a78863          	beq	a5,s10,686 <vprintf+0xf2>
      } else if(c == 'p') {
 61a:	09b78463          	beq	a5,s11,6a2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 61e:	07300713          	li	a4,115
 622:	0ce78663          	beq	a5,a4,6ee <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 626:	06300713          	li	a4,99
 62a:	0ee78e63          	beq	a5,a4,726 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 62e:	11478863          	beq	a5,s4,73e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 632:	85d2                	mv	a1,s4
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	e92080e7          	jalr	-366(ra) # 4c8 <putc>
        putc(fd, c);
 63e:	85ca                	mv	a1,s2
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	e86080e7          	jalr	-378(ra) # 4c8 <putc>
      }
      state = 0;
 64a:	4981                	li	s3,0
 64c:	b765                	j	5f4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 64e:	008b0913          	addi	s2,s6,8
 652:	4685                	li	a3,1
 654:	4629                	li	a2,10
 656:	000b2583          	lw	a1,0(s6)
 65a:	8556                	mv	a0,s5
 65c:	00000097          	auipc	ra,0x0
 660:	e8e080e7          	jalr	-370(ra) # 4ea <printint>
 664:	8b4a                	mv	s6,s2
      state = 0;
 666:	4981                	li	s3,0
 668:	b771                	j	5f4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66a:	008b0913          	addi	s2,s6,8
 66e:	4681                	li	a3,0
 670:	4629                	li	a2,10
 672:	000b2583          	lw	a1,0(s6)
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	e72080e7          	jalr	-398(ra) # 4ea <printint>
 680:	8b4a                	mv	s6,s2
      state = 0;
 682:	4981                	li	s3,0
 684:	bf85                	j	5f4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 686:	008b0913          	addi	s2,s6,8
 68a:	4681                	li	a3,0
 68c:	4641                	li	a2,16
 68e:	000b2583          	lw	a1,0(s6)
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	e56080e7          	jalr	-426(ra) # 4ea <printint>
 69c:	8b4a                	mv	s6,s2
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	bf91                	j	5f4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6a2:	008b0793          	addi	a5,s6,8
 6a6:	f8f43423          	sd	a5,-120(s0)
 6aa:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6ae:	03000593          	li	a1,48
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	e14080e7          	jalr	-492(ra) # 4c8 <putc>
  putc(fd, 'x');
 6bc:	85ea                	mv	a1,s10
 6be:	8556                	mv	a0,s5
 6c0:	00000097          	auipc	ra,0x0
 6c4:	e08080e7          	jalr	-504(ra) # 4c8 <putc>
 6c8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ca:	03c9d793          	srli	a5,s3,0x3c
 6ce:	97de                	add	a5,a5,s7
 6d0:	0007c583          	lbu	a1,0(a5)
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	df2080e7          	jalr	-526(ra) # 4c8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6de:	0992                	slli	s3,s3,0x4
 6e0:	397d                	addiw	s2,s2,-1
 6e2:	fe0914e3          	bnez	s2,6ca <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6e6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	b721                	j	5f4 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ee:	008b0993          	addi	s3,s6,8
 6f2:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6f6:	02090163          	beqz	s2,718 <vprintf+0x184>
        while(*s != 0){
 6fa:	00094583          	lbu	a1,0(s2)
 6fe:	c9a1                	beqz	a1,74e <vprintf+0x1ba>
          putc(fd, *s);
 700:	8556                	mv	a0,s5
 702:	00000097          	auipc	ra,0x0
 706:	dc6080e7          	jalr	-570(ra) # 4c8 <putc>
          s++;
 70a:	0905                	addi	s2,s2,1
        while(*s != 0){
 70c:	00094583          	lbu	a1,0(s2)
 710:	f9e5                	bnez	a1,700 <vprintf+0x16c>
        s = va_arg(ap, char*);
 712:	8b4e                	mv	s6,s3
      state = 0;
 714:	4981                	li	s3,0
 716:	bdf9                	j	5f4 <vprintf+0x60>
          s = "(null)";
 718:	00000917          	auipc	s2,0x0
 71c:	32890913          	addi	s2,s2,808 # a40 <malloc+0x1e2>
        while(*s != 0){
 720:	02800593          	li	a1,40
 724:	bff1                	j	700 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 726:	008b0913          	addi	s2,s6,8
 72a:	000b4583          	lbu	a1,0(s6)
 72e:	8556                	mv	a0,s5
 730:	00000097          	auipc	ra,0x0
 734:	d98080e7          	jalr	-616(ra) # 4c8 <putc>
 738:	8b4a                	mv	s6,s2
      state = 0;
 73a:	4981                	li	s3,0
 73c:	bd65                	j	5f4 <vprintf+0x60>
        putc(fd, c);
 73e:	85d2                	mv	a1,s4
 740:	8556                	mv	a0,s5
 742:	00000097          	auipc	ra,0x0
 746:	d86080e7          	jalr	-634(ra) # 4c8 <putc>
      state = 0;
 74a:	4981                	li	s3,0
 74c:	b565                	j	5f4 <vprintf+0x60>
        s = va_arg(ap, char*);
 74e:	8b4e                	mv	s6,s3
      state = 0;
 750:	4981                	li	s3,0
 752:	b54d                	j	5f4 <vprintf+0x60>
    }
  }
}
 754:	70e6                	ld	ra,120(sp)
 756:	7446                	ld	s0,112(sp)
 758:	74a6                	ld	s1,104(sp)
 75a:	7906                	ld	s2,96(sp)
 75c:	69e6                	ld	s3,88(sp)
 75e:	6a46                	ld	s4,80(sp)
 760:	6aa6                	ld	s5,72(sp)
 762:	6b06                	ld	s6,64(sp)
 764:	7be2                	ld	s7,56(sp)
 766:	7c42                	ld	s8,48(sp)
 768:	7ca2                	ld	s9,40(sp)
 76a:	7d02                	ld	s10,32(sp)
 76c:	6de2                	ld	s11,24(sp)
 76e:	6109                	addi	sp,sp,128
 770:	8082                	ret

0000000000000772 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 772:	715d                	addi	sp,sp,-80
 774:	ec06                	sd	ra,24(sp)
 776:	e822                	sd	s0,16(sp)
 778:	1000                	addi	s0,sp,32
 77a:	e010                	sd	a2,0(s0)
 77c:	e414                	sd	a3,8(s0)
 77e:	e818                	sd	a4,16(s0)
 780:	ec1c                	sd	a5,24(s0)
 782:	03043023          	sd	a6,32(s0)
 786:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 78a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 78e:	8622                	mv	a2,s0
 790:	00000097          	auipc	ra,0x0
 794:	e04080e7          	jalr	-508(ra) # 594 <vprintf>
}
 798:	60e2                	ld	ra,24(sp)
 79a:	6442                	ld	s0,16(sp)
 79c:	6161                	addi	sp,sp,80
 79e:	8082                	ret

00000000000007a0 <printf>:

void
printf(const char *fmt, ...)
{
 7a0:	711d                	addi	sp,sp,-96
 7a2:	ec06                	sd	ra,24(sp)
 7a4:	e822                	sd	s0,16(sp)
 7a6:	1000                	addi	s0,sp,32
 7a8:	e40c                	sd	a1,8(s0)
 7aa:	e810                	sd	a2,16(s0)
 7ac:	ec14                	sd	a3,24(s0)
 7ae:	f018                	sd	a4,32(s0)
 7b0:	f41c                	sd	a5,40(s0)
 7b2:	03043823          	sd	a6,48(s0)
 7b6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ba:	00840613          	addi	a2,s0,8
 7be:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c2:	85aa                	mv	a1,a0
 7c4:	4505                	li	a0,1
 7c6:	00000097          	auipc	ra,0x0
 7ca:	dce080e7          	jalr	-562(ra) # 594 <vprintf>
}
 7ce:	60e2                	ld	ra,24(sp)
 7d0:	6442                	ld	s0,16(sp)
 7d2:	6125                	addi	sp,sp,96
 7d4:	8082                	ret

00000000000007d6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d6:	1141                	addi	sp,sp,-16
 7d8:	e422                	sd	s0,8(sp)
 7da:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7dc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e0:	00000797          	auipc	a5,0x0
 7e4:	2807b783          	ld	a5,640(a5) # a60 <freep>
 7e8:	a805                	j	818 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ea:	4618                	lw	a4,8(a2)
 7ec:	9db9                	addw	a1,a1,a4
 7ee:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f2:	6398                	ld	a4,0(a5)
 7f4:	6318                	ld	a4,0(a4)
 7f6:	fee53823          	sd	a4,-16(a0)
 7fa:	a091                	j	83e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7fc:	ff852703          	lw	a4,-8(a0)
 800:	9e39                	addw	a2,a2,a4
 802:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 804:	ff053703          	ld	a4,-16(a0)
 808:	e398                	sd	a4,0(a5)
 80a:	a099                	j	850 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80c:	6398                	ld	a4,0(a5)
 80e:	00e7e463          	bltu	a5,a4,816 <free+0x40>
 812:	00e6ea63          	bltu	a3,a4,826 <free+0x50>
{
 816:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 818:	fed7fae3          	bgeu	a5,a3,80c <free+0x36>
 81c:	6398                	ld	a4,0(a5)
 81e:	00e6e463          	bltu	a3,a4,826 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 822:	fee7eae3          	bltu	a5,a4,816 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 826:	ff852583          	lw	a1,-8(a0)
 82a:	6390                	ld	a2,0(a5)
 82c:	02059813          	slli	a6,a1,0x20
 830:	01c85713          	srli	a4,a6,0x1c
 834:	9736                	add	a4,a4,a3
 836:	fae60ae3          	beq	a2,a4,7ea <free+0x14>
    bp->s.ptr = p->s.ptr;
 83a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 83e:	4790                	lw	a2,8(a5)
 840:	02061593          	slli	a1,a2,0x20
 844:	01c5d713          	srli	a4,a1,0x1c
 848:	973e                	add	a4,a4,a5
 84a:	fae689e3          	beq	a3,a4,7fc <free+0x26>
  } else
    p->s.ptr = bp;
 84e:	e394                	sd	a3,0(a5)
  freep = p;
 850:	00000717          	auipc	a4,0x0
 854:	20f73823          	sd	a5,528(a4) # a60 <freep>
}
 858:	6422                	ld	s0,8(sp)
 85a:	0141                	addi	sp,sp,16
 85c:	8082                	ret

000000000000085e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 85e:	7139                	addi	sp,sp,-64
 860:	fc06                	sd	ra,56(sp)
 862:	f822                	sd	s0,48(sp)
 864:	f426                	sd	s1,40(sp)
 866:	f04a                	sd	s2,32(sp)
 868:	ec4e                	sd	s3,24(sp)
 86a:	e852                	sd	s4,16(sp)
 86c:	e456                	sd	s5,8(sp)
 86e:	e05a                	sd	s6,0(sp)
 870:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 872:	02051493          	slli	s1,a0,0x20
 876:	9081                	srli	s1,s1,0x20
 878:	04bd                	addi	s1,s1,15
 87a:	8091                	srli	s1,s1,0x4
 87c:	0014899b          	addiw	s3,s1,1
 880:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 882:	00000517          	auipc	a0,0x0
 886:	1de53503          	ld	a0,478(a0) # a60 <freep>
 88a:	c515                	beqz	a0,8b6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88e:	4798                	lw	a4,8(a5)
 890:	02977f63          	bgeu	a4,s1,8ce <malloc+0x70>
 894:	8a4e                	mv	s4,s3
 896:	0009871b          	sext.w	a4,s3
 89a:	6685                	lui	a3,0x1
 89c:	00d77363          	bgeu	a4,a3,8a2 <malloc+0x44>
 8a0:	6a05                	lui	s4,0x1
 8a2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8a6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8aa:	00000917          	auipc	s2,0x0
 8ae:	1b690913          	addi	s2,s2,438 # a60 <freep>
  if(p == (char*)-1)
 8b2:	5afd                	li	s5,-1
 8b4:	a895                	j	928 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8b6:	00000797          	auipc	a5,0x0
 8ba:	1b278793          	addi	a5,a5,434 # a68 <base>
 8be:	00000717          	auipc	a4,0x0
 8c2:	1af73123          	sd	a5,418(a4) # a60 <freep>
 8c6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8cc:	b7e1                	j	894 <malloc+0x36>
      if(p->s.size == nunits)
 8ce:	02e48c63          	beq	s1,a4,906 <malloc+0xa8>
        p->s.size -= nunits;
 8d2:	4137073b          	subw	a4,a4,s3
 8d6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8d8:	02071693          	slli	a3,a4,0x20
 8dc:	01c6d713          	srli	a4,a3,0x1c
 8e0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8e6:	00000717          	auipc	a4,0x0
 8ea:	16a73d23          	sd	a0,378(a4) # a60 <freep>
      return (void*)(p + 1);
 8ee:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8f2:	70e2                	ld	ra,56(sp)
 8f4:	7442                	ld	s0,48(sp)
 8f6:	74a2                	ld	s1,40(sp)
 8f8:	7902                	ld	s2,32(sp)
 8fa:	69e2                	ld	s3,24(sp)
 8fc:	6a42                	ld	s4,16(sp)
 8fe:	6aa2                	ld	s5,8(sp)
 900:	6b02                	ld	s6,0(sp)
 902:	6121                	addi	sp,sp,64
 904:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 906:	6398                	ld	a4,0(a5)
 908:	e118                	sd	a4,0(a0)
 90a:	bff1                	j	8e6 <malloc+0x88>
  hp->s.size = nu;
 90c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 910:	0541                	addi	a0,a0,16
 912:	00000097          	auipc	ra,0x0
 916:	ec4080e7          	jalr	-316(ra) # 7d6 <free>
  return freep;
 91a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 91e:	d971                	beqz	a0,8f2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 920:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 922:	4798                	lw	a4,8(a5)
 924:	fa9775e3          	bgeu	a4,s1,8ce <malloc+0x70>
    if(p == freep)
 928:	00093703          	ld	a4,0(s2)
 92c:	853e                	mv	a0,a5
 92e:	fef719e3          	bne	a4,a5,920 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 932:	8552                	mv	a0,s4
 934:	00000097          	auipc	ra,0x0
 938:	b7c080e7          	jalr	-1156(ra) # 4b0 <sbrk>
  if(p == (char*)-1)
 93c:	fd5518e3          	bne	a0,s5,90c <malloc+0xae>
        return 0;
 940:	4501                	li	a0,0
 942:	bf45                	j	8f2 <malloc+0x94>
