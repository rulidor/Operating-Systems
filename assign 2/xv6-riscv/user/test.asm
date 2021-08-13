
user/_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <user_handler1>:
        printf("\nKILL!\n");
        sleep(30);
    }
}

void user_handler1(){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  printf("user_handler1!\n");
   8:	00001517          	auipc	a0,0x1
   c:	f2050513          	addi	a0,a0,-224 # f28 <csem_up+0x4a>
  10:	00001097          	auipc	ra,0x1
  14:	c62080e7          	jalr	-926(ra) # c72 <printf>
  exit(0);
  18:	4501                	li	a0,0
  1a:	00001097          	auipc	ra,0x1
  1e:	886080e7          	jalr	-1914(ra) # 8a0 <exit>

0000000000000022 <user_handler2>:
}
void user_handler2(){
  22:	1141                	addi	sp,sp,-16
  24:	e406                	sd	ra,8(sp)
  26:	e022                	sd	s0,0(sp)
  28:	0800                	addi	s0,sp,16
  printf("success!\n");
  2a:	00001517          	auipc	a0,0x1
  2e:	f0e50513          	addi	a0,a0,-242 # f38 <csem_up+0x5a>
  32:	00001097          	auipc	ra,0x1
  36:	c40080e7          	jalr	-960(ra) # c72 <printf>
  exit(0);
  3a:	4501                	li	a0,0
  3c:	00001097          	auipc	ra,0x1
  40:	864080e7          	jalr	-1948(ra) # 8a0 <exit>

0000000000000044 <user_handler3>:
}

void user_handler3(){
  44:	1141                	addi	sp,sp,-16
  46:	e406                	sd	ra,8(sp)
  48:	e022                	sd	s0,0(sp)
  4a:	0800                	addi	s0,sp,16
  printf("user_handler3!\n");
  4c:	00001517          	auipc	a0,0x1
  50:	efc50513          	addi	a0,a0,-260 # f48 <csem_up+0x6a>
  54:	00001097          	auipc	ra,0x1
  58:	c1e080e7          	jalr	-994(ra) # c72 <printf>
  exit(0);
  5c:	4501                	li	a0,0
  5e:	00001097          	auipc	ra,0x1
  62:	842080e7          	jalr	-1982(ra) # 8a0 <exit>

0000000000000066 <user_handler4>:
}
void user_handler4(){
  66:	1141                	addi	sp,sp,-16
  68:	e406                	sd	ra,8(sp)
  6a:	e022                	sd	s0,0(sp)
  6c:	0800                	addi	s0,sp,16
    printf("FAILED!\n");
  6e:	00001517          	auipc	a0,0x1
  72:	eea50513          	addi	a0,a0,-278 # f58 <csem_up+0x7a>
  76:	00001097          	auipc	ra,0x1
  7a:	bfc080e7          	jalr	-1028(ra) # c72 <printf>
    exit(0);
  7e:	4501                	li	a0,0
  80:	00001097          	auipc	ra,0x1
  84:	820080e7          	jalr	-2016(ra) # 8a0 <exit>

0000000000000088 <test1>:
void test1(){
  88:	1101                	addi	sp,sp,-32
  8a:	ec06                	sd	ra,24(sp)
  8c:	e822                	sd	s0,16(sp)
  8e:	e426                	sd	s1,8(sp)
  90:	e04a                	sd	s2,0(sp)
  92:	1000                	addi	s0,sp,32
    printf("running test1. expected: child print some 'c'->stop->continue.\n");
  94:	00001517          	auipc	a0,0x1
  98:	ed450513          	addi	a0,a0,-300 # f68 <csem_up+0x8a>
  9c:	00001097          	auipc	ra,0x1
  a0:	bd6080e7          	jalr	-1066(ra) # c72 <printf>
    sleep(30);
  a4:	4579                	li	a0,30
  a6:	00001097          	auipc	ra,0x1
  aa:	88a080e7          	jalr	-1910(ra) # 930 <sleep>
  int pid = fork();
  ae:	00000097          	auipc	ra,0x0
  b2:	7ea080e7          	jalr	2026(ra) # 898 <fork>
  if(pid == 0){
  b6:	cd31                	beqz	a0,112 <test1+0x8a>
  b8:	84aa                	mv	s1,a0
    sleep(2);
  ba:	4509                	li	a0,2
  bc:	00001097          	auipc	ra,0x1
  c0:	874080e7          	jalr	-1932(ra) # 930 <sleep>
    printf("\nSTOP!\n");
  c4:	00001517          	auipc	a0,0x1
  c8:	efc50513          	addi	a0,a0,-260 # fc0 <csem_up+0xe2>
  cc:	00001097          	auipc	ra,0x1
  d0:	ba6080e7          	jalr	-1114(ra) # c72 <printf>
    kill(pid, SIGSTOP);
  d4:	45c5                	li	a1,17
  d6:	8526                	mv	a0,s1
  d8:	00000097          	auipc	ra,0x0
  dc:	7f8080e7          	jalr	2040(ra) # 8d0 <kill>
    sleep(30);
  e0:	4579                	li	a0,30
  e2:	00001097          	auipc	ra,0x1
  e6:	84e080e7          	jalr	-1970(ra) # 930 <sleep>
    printf("\nCONT!\n");
  ea:	00001517          	auipc	a0,0x1
  ee:	ede50513          	addi	a0,a0,-290 # fc8 <csem_up+0xea>
  f2:	00001097          	auipc	ra,0x1
  f6:	b80080e7          	jalr	-1152(ra) # c72 <printf>
    kill(pid, SIGCONT);
  fa:	45cd                	li	a1,19
  fc:	8526                	mv	a0,s1
  fe:	00000097          	auipc	ra,0x0
 102:	7d2080e7          	jalr	2002(ra) # 8d0 <kill>
}
 106:	60e2                	ld	ra,24(sp)
 108:	6442                	ld	s0,16(sp)
 10a:	64a2                	ld	s1,8(sp)
 10c:	6902                	ld	s2,0(sp)
 10e:	6105                	addi	sp,sp,32
 110:	8082                	ret
 112:	3e800493          	li	s1,1000
      printf("c");
 116:	00001917          	auipc	s2,0x1
 11a:	e9290913          	addi	s2,s2,-366 # fa8 <csem_up+0xca>
 11e:	854a                	mv	a0,s2
 120:	00001097          	auipc	ra,0x1
 124:	b52080e7          	jalr	-1198(ra) # c72 <printf>
    for(int i=0; i<1000; i++)
 128:	34fd                	addiw	s1,s1,-1
 12a:	f8f5                	bnez	s1,11e <test1+0x96>
    printf("\n");
 12c:	00001517          	auipc	a0,0x1
 130:	e1450513          	addi	a0,a0,-492 # f40 <csem_up+0x62>
 134:	00001097          	auipc	ra,0x1
 138:	b3e080e7          	jalr	-1218(ra) # c72 <printf>
    printf("child exits\n");
 13c:	00001517          	auipc	a0,0x1
 140:	e7450513          	addi	a0,a0,-396 # fb0 <csem_up+0xd2>
 144:	00001097          	auipc	ra,0x1
 148:	b2e080e7          	jalr	-1234(ra) # c72 <printf>
    exit(0);
 14c:	4501                	li	a0,0
 14e:	00000097          	auipc	ra,0x0
 152:	752080e7          	jalr	1874(ra) # 8a0 <exit>

0000000000000156 <test2>:
void test2(){
 156:	1101                	addi	sp,sp,-32
 158:	ec06                	sd	ra,24(sp)
 15a:	e822                	sd	s0,16(sp)
 15c:	e426                	sd	s1,8(sp)
 15e:	e04a                	sd	s2,0(sp)
 160:	1000                	addi	s0,sp,32
    printf("running test2. expected: child print some 'c' and killed, not reaching 1000 chars.\n");
 162:	00001517          	auipc	a0,0x1
 166:	e6e50513          	addi	a0,a0,-402 # fd0 <csem_up+0xf2>
 16a:	00001097          	auipc	ra,0x1
 16e:	b08080e7          	jalr	-1272(ra) # c72 <printf>
    sleep(50);
 172:	03200513          	li	a0,50
 176:	00000097          	auipc	ra,0x0
 17a:	7ba080e7          	jalr	1978(ra) # 930 <sleep>
    int pid = fork();
 17e:	00000097          	auipc	ra,0x0
 182:	71a080e7          	jalr	1818(ra) # 898 <fork>
    if(pid == 0){
 186:	c121                	beqz	a0,1c6 <test2+0x70>
 188:	84aa                	mv	s1,a0
        sleep(1);
 18a:	4505                	li	a0,1
 18c:	00000097          	auipc	ra,0x0
 190:	7a4080e7          	jalr	1956(ra) # 930 <sleep>
        kill(pid, SIGKILL);
 194:	45a5                	li	a1,9
 196:	8526                	mv	a0,s1
 198:	00000097          	auipc	ra,0x0
 19c:	738080e7          	jalr	1848(ra) # 8d0 <kill>
        printf("\nKILL!\n");
 1a0:	00001517          	auipc	a0,0x1
 1a4:	e8850513          	addi	a0,a0,-376 # 1028 <csem_up+0x14a>
 1a8:	00001097          	auipc	ra,0x1
 1ac:	aca080e7          	jalr	-1334(ra) # c72 <printf>
        sleep(30);
 1b0:	4579                	li	a0,30
 1b2:	00000097          	auipc	ra,0x0
 1b6:	77e080e7          	jalr	1918(ra) # 930 <sleep>
}
 1ba:	60e2                	ld	ra,24(sp)
 1bc:	6442                	ld	s0,16(sp)
 1be:	64a2                	ld	s1,8(sp)
 1c0:	6902                	ld	s2,0(sp)
 1c2:	6105                	addi	sp,sp,32
 1c4:	8082                	ret
 1c6:	3e800493          	li	s1,1000
            printf("c");
 1ca:	00001917          	auipc	s2,0x1
 1ce:	dde90913          	addi	s2,s2,-546 # fa8 <csem_up+0xca>
 1d2:	854a                	mv	a0,s2
 1d4:	00001097          	auipc	ra,0x1
 1d8:	a9e080e7          	jalr	-1378(ra) # c72 <printf>
        for(int i=0; i<1000; i++)
 1dc:	34fd                	addiw	s1,s1,-1
 1de:	f8f5                	bnez	s1,1d2 <test2+0x7c>
        printf("\n");
 1e0:	00001517          	auipc	a0,0x1
 1e4:	d6050513          	addi	a0,a0,-672 # f40 <csem_up+0x62>
 1e8:	00001097          	auipc	ra,0x1
 1ec:	a8a080e7          	jalr	-1398(ra) # c72 <printf>
        printf("child exits\n");
 1f0:	00001517          	auipc	a0,0x1
 1f4:	dc050513          	addi	a0,a0,-576 # fb0 <csem_up+0xd2>
 1f8:	00001097          	auipc	ra,0x1
 1fc:	a7a080e7          	jalr	-1414(ra) # c72 <printf>
        exit(0);
 200:	4501                	li	a0,0
 202:	00000097          	auipc	ra,0x0
 206:	69e080e7          	jalr	1694(ra) # 8a0 <exit>

000000000000020a <test3>:
}

void test3(){
 20a:	715d                	addi	sp,sp,-80
 20c:	e486                	sd	ra,72(sp)
 20e:	e0a2                	sd	s0,64(sp)
 210:	fc26                	sd	s1,56(sp)
 212:	f84a                	sd	s2,48(sp)
 214:	0880                	addi	s0,sp,80
    printf("running test3. expected: printed some '~' -> 'success!'\n");
 216:	00001517          	auipc	a0,0x1
 21a:	e1a50513          	addi	a0,a0,-486 # 1030 <csem_up+0x152>
 21e:	00001097          	auipc	ra,0x1
 222:	a54080e7          	jalr	-1452(ra) # c72 <printf>
    printf("handler1 addr: %d\n", user_handler1);
 226:	00000597          	auipc	a1,0x0
 22a:	dda58593          	addi	a1,a1,-550 # 0 <user_handler1>
 22e:	00001517          	auipc	a0,0x1
 232:	e4250513          	addi	a0,a0,-446 # 1070 <csem_up+0x192>
 236:	00001097          	auipc	ra,0x1
 23a:	a3c080e7          	jalr	-1476(ra) # c72 <printf>
    printf("handler2 addr: %d\n", user_handler2);
 23e:	00000597          	auipc	a1,0x0
 242:	de458593          	addi	a1,a1,-540 # 22 <user_handler2>
 246:	00001517          	auipc	a0,0x1
 24a:	e4250513          	addi	a0,a0,-446 # 1088 <csem_up+0x1aa>
 24e:	00001097          	auipc	ra,0x1
 252:	a24080e7          	jalr	-1500(ra) # c72 <printf>

    struct sigaction act;
    struct sigaction oldact;
    act.sa_handler = user_handler2;
 256:	00000797          	auipc	a5,0x0
 25a:	dcc78793          	addi	a5,a5,-564 # 22 <user_handler2>
 25e:	fcf43823          	sd	a5,-48(s0)
    //  act.sa_handler = (void*)&sigret;
    act.sigmask = 0;
 262:	fc042c23          	sw	zero,-40(s0)
    sigaction(4, &act, &oldact);
 266:	fc040613          	addi	a2,s0,-64
 26a:	fd040593          	addi	a1,s0,-48
 26e:	4511                	li	a0,4
 270:	00000097          	auipc	ra,0x0
 274:	6d8080e7          	jalr	1752(ra) # 948 <sigaction>
    int xsatus;

    sleep(30);
 278:	4579                	li	a0,30
 27a:	00000097          	auipc	ra,0x0
 27e:	6b6080e7          	jalr	1718(ra) # 930 <sleep>

    printf("child running...\n");
 282:	00001517          	auipc	a0,0x1
 286:	e1e50513          	addi	a0,a0,-482 # 10a0 <csem_up+0x1c2>
 28a:	00001097          	auipc	ra,0x1
 28e:	9e8080e7          	jalr	-1560(ra) # c72 <printf>

    int pid = fork();
 292:	00000097          	auipc	ra,0x0
 296:	606080e7          	jalr	1542(ra) # 898 <fork>
    if(pid == 0){
 29a:	c90d                	beqz	a0,2cc <test3+0xc2>
 29c:	84aa                	mv	s1,a0
            printf("~");
        }
        exit(0);
    }
    else{
        sleep(2);
 29e:	4509                	li	a0,2
 2a0:	00000097          	auipc	ra,0x0
 2a4:	690080e7          	jalr	1680(ra) # 930 <sleep>
        // wait(&xsatus);

        kill(pid, 4);
 2a8:	4591                	li	a1,4
 2aa:	8526                	mv	a0,s1
 2ac:	00000097          	auipc	ra,0x0
 2b0:	624080e7          	jalr	1572(ra) # 8d0 <kill>
        wait(&xsatus);
 2b4:	fbc40513          	addi	a0,s0,-68
 2b8:	00000097          	auipc	ra,0x0
 2bc:	5f0080e7          	jalr	1520(ra) # 8a8 <wait>

        // printf("\n\n");
        // sleep(30);
    }
}
 2c0:	60a6                	ld	ra,72(sp)
 2c2:	6406                	ld	s0,64(sp)
 2c4:	74e2                	ld	s1,56(sp)
 2c6:	7942                	ld	s2,48(sp)
 2c8:	6161                	addi	sp,sp,80
 2ca:	8082                	ret
 2cc:	3e800493          	li	s1,1000
            printf("~");
 2d0:	00001917          	auipc	s2,0x1
 2d4:	de890913          	addi	s2,s2,-536 # 10b8 <csem_up+0x1da>
 2d8:	854a                	mv	a0,s2
 2da:	00001097          	auipc	ra,0x1
 2de:	998080e7          	jalr	-1640(ra) # c72 <printf>
        for(int i=0; i<1000; i++){
 2e2:	34fd                	addiw	s1,s1,-1
 2e4:	f8f5                	bnez	s1,2d8 <test3+0xce>
        exit(0);
 2e6:	4501                	li	a0,0
 2e8:	00000097          	auipc	ra,0x0
 2ec:	5b8080e7          	jalr	1464(ra) # 8a0 <exit>

00000000000002f0 <test4>:

void test4(){
 2f0:	1101                	addi	sp,sp,-32
 2f2:	ec06                	sd	ra,24(sp)
 2f4:	e822                	sd	s0,16(sp)
 2f6:	1000                	addi	s0,sp,32
    printf("running test4. expected: '09377'\n");
 2f8:	00001517          	auipc	a0,0x1
 2fc:	dc850513          	addi	a0,a0,-568 # 10c0 <csem_up+0x1e2>
 300:	00001097          	auipc	ra,0x1
 304:	972080e7          	jalr	-1678(ra) # c72 <printf>
    int xsatus;
    sleep(30);
 308:	4579                	li	a0,30
 30a:	00000097          	auipc	ra,0x0
 30e:	626080e7          	jalr	1574(ra) # 930 <sleep>

    fprintf(1, "%d", sigprocmask(9));
 312:	4525                	li	a0,9
 314:	00000097          	auipc	ra,0x0
 318:	62c080e7          	jalr	1580(ra) # 940 <sigprocmask>
 31c:	0005061b          	sext.w	a2,a0
 320:	00001597          	auipc	a1,0x1
 324:	dc858593          	addi	a1,a1,-568 # 10e8 <csem_up+0x20a>
 328:	4505                	li	a0,1
 32a:	00001097          	auipc	ra,0x1
 32e:	91a080e7          	jalr	-1766(ra) # c44 <fprintf>
    fprintf(1, "%d", sigprocmask(3));
 332:	450d                	li	a0,3
 334:	00000097          	auipc	ra,0x0
 338:	60c080e7          	jalr	1548(ra) # 940 <sigprocmask>
 33c:	0005061b          	sext.w	a2,a0
 340:	00001597          	auipc	a1,0x1
 344:	da858593          	addi	a1,a1,-600 # 10e8 <csem_up+0x20a>
 348:	4505                	li	a0,1
 34a:	00001097          	auipc	ra,0x1
 34e:	8fa080e7          	jalr	-1798(ra) # c44 <fprintf>
    fprintf(1, "%d", sigprocmask(7));
 352:	451d                	li	a0,7
 354:	00000097          	auipc	ra,0x0
 358:	5ec080e7          	jalr	1516(ra) # 940 <sigprocmask>
 35c:	0005061b          	sext.w	a2,a0
 360:	00001597          	auipc	a1,0x1
 364:	d8858593          	addi	a1,a1,-632 # 10e8 <csem_up+0x20a>
 368:	4505                	li	a0,1
 36a:	00001097          	auipc	ra,0x1
 36e:	8da080e7          	jalr	-1830(ra) # c44 <fprintf>

    int pid = fork();
 372:	00000097          	auipc	ra,0x0
 376:	526080e7          	jalr	1318(ra) # 898 <fork>
    if(pid == 0){
 37a:	e915                	bnez	a0,3ae <test4+0xbe>
      fprintf(1, "%d", sigprocmask(1));
 37c:	4505                	li	a0,1
 37e:	00000097          	auipc	ra,0x0
 382:	5c2080e7          	jalr	1474(ra) # 940 <sigprocmask>
 386:	0005061b          	sext.w	a2,a0
 38a:	00001597          	auipc	a1,0x1
 38e:	d5e58593          	addi	a1,a1,-674 # 10e8 <csem_up+0x20a>
 392:	4505                	li	a0,1
 394:	00001097          	auipc	ra,0x1
 398:	8b0080e7          	jalr	-1872(ra) # c44 <fprintf>
      sleep(5);
 39c:	4515                	li	a0,5
 39e:	00000097          	auipc	ra,0x0
 3a2:	592080e7          	jalr	1426(ra) # 930 <sleep>
    else
    {
        wait(&xsatus);
        fprintf(1, "%d\n", sigprocmask(1));
    }
}
 3a6:	60e2                	ld	ra,24(sp)
 3a8:	6442                	ld	s0,16(sp)
 3aa:	6105                	addi	sp,sp,32
 3ac:	8082                	ret
        wait(&xsatus);
 3ae:	fec40513          	addi	a0,s0,-20
 3b2:	00000097          	auipc	ra,0x0
 3b6:	4f6080e7          	jalr	1270(ra) # 8a8 <wait>
        fprintf(1, "%d\n", sigprocmask(1));
 3ba:	4505                	li	a0,1
 3bc:	00000097          	auipc	ra,0x0
 3c0:	584080e7          	jalr	1412(ra) # 940 <sigprocmask>
 3c4:	0005061b          	sext.w	a2,a0
 3c8:	00001597          	auipc	a1,0x1
 3cc:	d2858593          	addi	a1,a1,-728 # 10f0 <csem_up+0x212>
 3d0:	4505                	li	a0,1
 3d2:	00001097          	auipc	ra,0x1
 3d6:	872080e7          	jalr	-1934(ra) # c44 <fprintf>
}
 3da:	b7f1                	j	3a6 <test4+0xb6>

00000000000003dc <test5>:

void test5(){
 3dc:	7139                	addi	sp,sp,-64
 3de:	fc06                	sd	ra,56(sp)
 3e0:	f822                	sd	s0,48(sp)
 3e2:	f426                	sd	s1,40(sp)
 3e4:	f04a                	sd	s2,32(sp)
 3e6:	0080                	addi	s0,sp,64
    printf("running test5 - restoring previous handlers using the sigaction oldact. expected: printed some '~' -> 'success!'\n");
 3e8:	00001517          	auipc	a0,0x1
 3ec:	d1050513          	addi	a0,a0,-752 # 10f8 <csem_up+0x21a>
 3f0:	00001097          	auipc	ra,0x1
 3f4:	882080e7          	jalr	-1918(ra) # c72 <printf>
    printf("handler1 addr: %d\n", user_handler1);
 3f8:	00000597          	auipc	a1,0x0
 3fc:	c0858593          	addi	a1,a1,-1016 # 0 <user_handler1>
 400:	00001517          	auipc	a0,0x1
 404:	c7050513          	addi	a0,a0,-912 # 1070 <csem_up+0x192>
 408:	00001097          	auipc	ra,0x1
 40c:	86a080e7          	jalr	-1942(ra) # c72 <printf>
    printf("handler2 addr: %d\n", user_handler2);
 410:	00000597          	auipc	a1,0x0
 414:	c1258593          	addi	a1,a1,-1006 # 22 <user_handler2>
 418:	00001517          	auipc	a0,0x1
 41c:	c7050513          	addi	a0,a0,-912 # 1088 <csem_up+0x1aa>
 420:	00001097          	auipc	ra,0x1
 424:	852080e7          	jalr	-1966(ra) # c72 <printf>
    printf("handler3 addr: %d\n", user_handler3);
 428:	00000597          	auipc	a1,0x0
 42c:	c1c58593          	addi	a1,a1,-996 # 44 <user_handler3>
 430:	00001517          	auipc	a0,0x1
 434:	d4050513          	addi	a0,a0,-704 # 1170 <csem_up+0x292>
 438:	00001097          	auipc	ra,0x1
 43c:	83a080e7          	jalr	-1990(ra) # c72 <printf>

    sleep(30);
 440:	4579                	li	a0,30
 442:	00000097          	auipc	ra,0x0
 446:	4ee080e7          	jalr	1262(ra) # 930 <sleep>

    struct sigaction act;
    struct sigaction oldact;
    act.sa_handler = user_handler2;
 44a:	00000797          	auipc	a5,0x0
 44e:	bd878793          	addi	a5,a5,-1064 # 22 <user_handler2>
 452:	fcf43823          	sd	a5,-48(s0)
    act.sigmask = 0;
 456:	fc042c23          	sw	zero,-40(s0)

    int pid = fork();
 45a:	00000097          	auipc	ra,0x0
 45e:	43e080e7          	jalr	1086(ra) # 898 <fork>
    if(pid == 0){
 462:	c11d                	beqz	a0,488 <test5+0xac>
 464:	84aa                	mv	s1,a0
        sigaction(4, &oldact, &act);
        for(int i=0; i<1000; i++)
            printf("~");
        exit(0);
    }else{
        sleep(3);
 466:	450d                	li	a0,3
 468:	00000097          	auipc	ra,0x0
 46c:	4c8080e7          	jalr	1224(ra) # 930 <sleep>
        kill(pid, 4);
 470:	4591                	li	a1,4
 472:	8526                	mv	a0,s1
 474:	00000097          	auipc	ra,0x0
 478:	45c080e7          	jalr	1116(ra) # 8d0 <kill>
    }

    


}
 47c:	70e2                	ld	ra,56(sp)
 47e:	7442                	ld	s0,48(sp)
 480:	74a2                	ld	s1,40(sp)
 482:	7902                	ld	s2,32(sp)
 484:	6121                	addi	sp,sp,64
 486:	8082                	ret
        sigaction(4, &act, &oldact); //now oldact.handler adrs should be 0.
 488:	fc040613          	addi	a2,s0,-64
 48c:	fd040593          	addi	a1,s0,-48
 490:	4511                	li	a0,4
 492:	00000097          	auipc	ra,0x0
 496:	4b6080e7          	jalr	1206(ra) # 948 <sigaction>
        act.sa_handler = user_handler3;
 49a:	00000797          	auipc	a5,0x0
 49e:	baa78793          	addi	a5,a5,-1110 # 44 <user_handler3>
 4a2:	fcf43823          	sd	a5,-48(s0)
        sigaction(4, &act, &oldact); //now oldact.handler adrs should be that of user_handler2.
 4a6:	fc040613          	addi	a2,s0,-64
 4aa:	fd040593          	addi	a1,s0,-48
 4ae:	4511                	li	a0,4
 4b0:	00000097          	auipc	ra,0x0
 4b4:	498080e7          	jalr	1176(ra) # 948 <sigaction>
        sigaction(4, &oldact, &act);
 4b8:	fd040613          	addi	a2,s0,-48
 4bc:	fc040593          	addi	a1,s0,-64
 4c0:	4511                	li	a0,4
 4c2:	00000097          	auipc	ra,0x0
 4c6:	486080e7          	jalr	1158(ra) # 948 <sigaction>
 4ca:	3e800493          	li	s1,1000
            printf("~");
 4ce:	00001917          	auipc	s2,0x1
 4d2:	bea90913          	addi	s2,s2,-1046 # 10b8 <csem_up+0x1da>
 4d6:	854a                	mv	a0,s2
 4d8:	00000097          	auipc	ra,0x0
 4dc:	79a080e7          	jalr	1946(ra) # c72 <printf>
        for(int i=0; i<1000; i++)
 4e0:	34fd                	addiw	s1,s1,-1
 4e2:	f8f5                	bnez	s1,4d6 <test5+0xfa>
        exit(0);
 4e4:	4501                	li	a0,0
 4e6:	00000097          	auipc	ra,0x0
 4ea:	3ba080e7          	jalr	954(ra) # 8a0 <exit>

00000000000004ee <test6>:

void test6(){
 4ee:	7179                	addi	sp,sp,-48
 4f0:	f406                	sd	ra,40(sp)
 4f2:	f022                	sd	s0,32(sp)
 4f4:	1800                	addi	s0,sp,48
    printf("running test6 - blocking signals. expected: printed 'success!'\n");
 4f6:	00001517          	auipc	a0,0x1
 4fa:	c9250513          	addi	a0,a0,-878 # 1188 <csem_up+0x2aa>
 4fe:	00000097          	auipc	ra,0x0
 502:	774080e7          	jalr	1908(ra) # c72 <printf>
    printf("handler1 addr: %d\n", user_handler1);
 506:	00000597          	auipc	a1,0x0
 50a:	afa58593          	addi	a1,a1,-1286 # 0 <user_handler1>
 50e:	00001517          	auipc	a0,0x1
 512:	b6250513          	addi	a0,a0,-1182 # 1070 <csem_up+0x192>
 516:	00000097          	auipc	ra,0x0
 51a:	75c080e7          	jalr	1884(ra) # c72 <printf>
    printf("handler2 addr: %d\n", user_handler2);
 51e:	00000597          	auipc	a1,0x0
 522:	b0458593          	addi	a1,a1,-1276 # 22 <user_handler2>
 526:	00001517          	auipc	a0,0x1
 52a:	b6250513          	addi	a0,a0,-1182 # 1088 <csem_up+0x1aa>
 52e:	00000097          	auipc	ra,0x0
 532:	744080e7          	jalr	1860(ra) # c72 <printf>
    printf("handler3 addr: %d\n", user_handler3);
 536:	00000597          	auipc	a1,0x0
 53a:	b0e58593          	addi	a1,a1,-1266 # 44 <user_handler3>
 53e:	00001517          	auipc	a0,0x1
 542:	c3250513          	addi	a0,a0,-974 # 1170 <csem_up+0x292>
 546:	00000097          	auipc	ra,0x0
 54a:	72c080e7          	jalr	1836(ra) # c72 <printf>

    sleep(30);
 54e:	4579                	li	a0,30
 550:	00000097          	auipc	ra,0x0
 554:	3e0080e7          	jalr	992(ra) # 930 <sleep>


    struct sigaction act;
    struct sigaction oldact;
    act.sa_handler = user_handler4;
 558:	00000797          	auipc	a5,0x0
 55c:	b0e78793          	addi	a5,a5,-1266 # 66 <user_handler4>
 560:	fef43023          	sd	a5,-32(s0)
    act.sigmask = 0;
 564:	fe042423          	sw	zero,-24(s0)
    sigaction(4, &act, &oldact);
 568:	fd040613          	addi	a2,s0,-48
 56c:	fe040593          	addi	a1,s0,-32
 570:	4511                	li	a0,4
 572:	00000097          	auipc	ra,0x0
 576:	3d6080e7          	jalr	982(ra) # 948 <sigaction>

    uint mask = (1 << 4);
    sigprocmask(mask);
 57a:	4541                	li	a0,16
 57c:	00000097          	auipc	ra,0x0
 580:	3c4080e7          	jalr	964(ra) # 940 <sigprocmask>

    kill(getpid(), 4);
 584:	00000097          	auipc	ra,0x0
 588:	39c080e7          	jalr	924(ra) # 920 <getpid>
 58c:	4591                	li	a1,4
 58e:	00000097          	auipc	ra,0x0
 592:	342080e7          	jalr	834(ra) # 8d0 <kill>

    printf("success!\n");
 596:	00001517          	auipc	a0,0x1
 59a:	9a250513          	addi	a0,a0,-1630 # f38 <csem_up+0x5a>
 59e:	00000097          	auipc	ra,0x0
 5a2:	6d4080e7          	jalr	1748(ra) # c72 <printf>
}
 5a6:	70a2                	ld	ra,40(sp)
 5a8:	7402                	ld	s0,32(sp)
 5aa:	6145                	addi	sp,sp,48
 5ac:	8082                	ret

00000000000005ae <main>:



int main(int argc, char **argv)
{
 5ae:	1141                	addi	sp,sp,-16
 5b0:	e406                	sd	ra,8(sp)
 5b2:	e022                	sd	s0,0(sp)
 5b4:	0800                	addi	s0,sp,16


    printf("**testing signals***\n");
 5b6:	00001517          	auipc	a0,0x1
 5ba:	c1250513          	addi	a0,a0,-1006 # 11c8 <csem_up+0x2ea>
 5be:	00000097          	auipc	ra,0x0
 5c2:	6b4080e7          	jalr	1716(ra) # c72 <printf>
    test1();
 5c6:	00000097          	auipc	ra,0x0
 5ca:	ac2080e7          	jalr	-1342(ra) # 88 <test1>
    sleep(10);
 5ce:	4529                	li	a0,10
 5d0:	00000097          	auipc	ra,0x0
 5d4:	360080e7          	jalr	864(ra) # 930 <sleep>
    test2();
 5d8:	00000097          	auipc	ra,0x0
 5dc:	b7e080e7          	jalr	-1154(ra) # 156 <test2>
    sleep(10);
 5e0:	4529                	li	a0,10
 5e2:	00000097          	auipc	ra,0x0
 5e6:	34e080e7          	jalr	846(ra) # 930 <sleep>
    test3();
 5ea:	00000097          	auipc	ra,0x0
 5ee:	c20080e7          	jalr	-992(ra) # 20a <test3>
    sleep(10);
 5f2:	4529                	li	a0,10
 5f4:	00000097          	auipc	ra,0x0
 5f8:	33c080e7          	jalr	828(ra) # 930 <sleep>
    test4();
 5fc:	00000097          	auipc	ra,0x0
 600:	cf4080e7          	jalr	-780(ra) # 2f0 <test4>
    sleep(10);
 604:	4529                	li	a0,10
 606:	00000097          	auipc	ra,0x0
 60a:	32a080e7          	jalr	810(ra) # 930 <sleep>
    test5();
 60e:	00000097          	auipc	ra,0x0
 612:	dce080e7          	jalr	-562(ra) # 3dc <test5>
    sleep(10);
 616:	4529                	li	a0,10
 618:	00000097          	auipc	ra,0x0
 61c:	318080e7          	jalr	792(ra) # 930 <sleep>
    test6();
 620:	00000097          	auipc	ra,0x0
 624:	ece080e7          	jalr	-306(ra) # 4ee <test6>

  exit(0);
 628:	4501                	li	a0,0
 62a:	00000097          	auipc	ra,0x0
 62e:	276080e7          	jalr	630(ra) # 8a0 <exit>

0000000000000632 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 632:	1141                	addi	sp,sp,-16
 634:	e422                	sd	s0,8(sp)
 636:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 638:	87aa                	mv	a5,a0
 63a:	0585                	addi	a1,a1,1
 63c:	0785                	addi	a5,a5,1
 63e:	fff5c703          	lbu	a4,-1(a1)
 642:	fee78fa3          	sb	a4,-1(a5)
 646:	fb75                	bnez	a4,63a <strcpy+0x8>
    ;
  return os;
}
 648:	6422                	ld	s0,8(sp)
 64a:	0141                	addi	sp,sp,16
 64c:	8082                	ret

000000000000064e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 64e:	1141                	addi	sp,sp,-16
 650:	e422                	sd	s0,8(sp)
 652:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 654:	00054783          	lbu	a5,0(a0)
 658:	cb91                	beqz	a5,66c <strcmp+0x1e>
 65a:	0005c703          	lbu	a4,0(a1)
 65e:	00f71763          	bne	a4,a5,66c <strcmp+0x1e>
    p++, q++;
 662:	0505                	addi	a0,a0,1
 664:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 666:	00054783          	lbu	a5,0(a0)
 66a:	fbe5                	bnez	a5,65a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 66c:	0005c503          	lbu	a0,0(a1)
}
 670:	40a7853b          	subw	a0,a5,a0
 674:	6422                	ld	s0,8(sp)
 676:	0141                	addi	sp,sp,16
 678:	8082                	ret

000000000000067a <strlen>:

uint
strlen(const char *s)
{
 67a:	1141                	addi	sp,sp,-16
 67c:	e422                	sd	s0,8(sp)
 67e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 680:	00054783          	lbu	a5,0(a0)
 684:	cf91                	beqz	a5,6a0 <strlen+0x26>
 686:	0505                	addi	a0,a0,1
 688:	87aa                	mv	a5,a0
 68a:	4685                	li	a3,1
 68c:	9e89                	subw	a3,a3,a0
 68e:	00f6853b          	addw	a0,a3,a5
 692:	0785                	addi	a5,a5,1
 694:	fff7c703          	lbu	a4,-1(a5)
 698:	fb7d                	bnez	a4,68e <strlen+0x14>
    ;
  return n;
}
 69a:	6422                	ld	s0,8(sp)
 69c:	0141                	addi	sp,sp,16
 69e:	8082                	ret
  for(n = 0; s[n]; n++)
 6a0:	4501                	li	a0,0
 6a2:	bfe5                	j	69a <strlen+0x20>

00000000000006a4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 6a4:	1141                	addi	sp,sp,-16
 6a6:	e422                	sd	s0,8(sp)
 6a8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 6aa:	ca19                	beqz	a2,6c0 <memset+0x1c>
 6ac:	87aa                	mv	a5,a0
 6ae:	1602                	slli	a2,a2,0x20
 6b0:	9201                	srli	a2,a2,0x20
 6b2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 6b6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 6ba:	0785                	addi	a5,a5,1
 6bc:	fee79de3          	bne	a5,a4,6b6 <memset+0x12>
  }
  return dst;
}
 6c0:	6422                	ld	s0,8(sp)
 6c2:	0141                	addi	sp,sp,16
 6c4:	8082                	ret

00000000000006c6 <strchr>:

char*
strchr(const char *s, char c)
{
 6c6:	1141                	addi	sp,sp,-16
 6c8:	e422                	sd	s0,8(sp)
 6ca:	0800                	addi	s0,sp,16
  for(; *s; s++)
 6cc:	00054783          	lbu	a5,0(a0)
 6d0:	cb99                	beqz	a5,6e6 <strchr+0x20>
    if(*s == c)
 6d2:	00f58763          	beq	a1,a5,6e0 <strchr+0x1a>
  for(; *s; s++)
 6d6:	0505                	addi	a0,a0,1
 6d8:	00054783          	lbu	a5,0(a0)
 6dc:	fbfd                	bnez	a5,6d2 <strchr+0xc>
      return (char*)s;
  return 0;
 6de:	4501                	li	a0,0
}
 6e0:	6422                	ld	s0,8(sp)
 6e2:	0141                	addi	sp,sp,16
 6e4:	8082                	ret
  return 0;
 6e6:	4501                	li	a0,0
 6e8:	bfe5                	j	6e0 <strchr+0x1a>

00000000000006ea <gets>:

char*
gets(char *buf, int max)
{
 6ea:	711d                	addi	sp,sp,-96
 6ec:	ec86                	sd	ra,88(sp)
 6ee:	e8a2                	sd	s0,80(sp)
 6f0:	e4a6                	sd	s1,72(sp)
 6f2:	e0ca                	sd	s2,64(sp)
 6f4:	fc4e                	sd	s3,56(sp)
 6f6:	f852                	sd	s4,48(sp)
 6f8:	f456                	sd	s5,40(sp)
 6fa:	f05a                	sd	s6,32(sp)
 6fc:	ec5e                	sd	s7,24(sp)
 6fe:	1080                	addi	s0,sp,96
 700:	8baa                	mv	s7,a0
 702:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 704:	892a                	mv	s2,a0
 706:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 708:	4aa9                	li	s5,10
 70a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 70c:	89a6                	mv	s3,s1
 70e:	2485                	addiw	s1,s1,1
 710:	0344d863          	bge	s1,s4,740 <gets+0x56>
    cc = read(0, &c, 1);
 714:	4605                	li	a2,1
 716:	faf40593          	addi	a1,s0,-81
 71a:	4501                	li	a0,0
 71c:	00000097          	auipc	ra,0x0
 720:	19c080e7          	jalr	412(ra) # 8b8 <read>
    if(cc < 1)
 724:	00a05e63          	blez	a0,740 <gets+0x56>
    buf[i++] = c;
 728:	faf44783          	lbu	a5,-81(s0)
 72c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 730:	01578763          	beq	a5,s5,73e <gets+0x54>
 734:	0905                	addi	s2,s2,1
 736:	fd679be3          	bne	a5,s6,70c <gets+0x22>
  for(i=0; i+1 < max; ){
 73a:	89a6                	mv	s3,s1
 73c:	a011                	j	740 <gets+0x56>
 73e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 740:	99de                	add	s3,s3,s7
 742:	00098023          	sb	zero,0(s3)
  return buf;
}
 746:	855e                	mv	a0,s7
 748:	60e6                	ld	ra,88(sp)
 74a:	6446                	ld	s0,80(sp)
 74c:	64a6                	ld	s1,72(sp)
 74e:	6906                	ld	s2,64(sp)
 750:	79e2                	ld	s3,56(sp)
 752:	7a42                	ld	s4,48(sp)
 754:	7aa2                	ld	s5,40(sp)
 756:	7b02                	ld	s6,32(sp)
 758:	6be2                	ld	s7,24(sp)
 75a:	6125                	addi	sp,sp,96
 75c:	8082                	ret

000000000000075e <stat>:

int
stat(const char *n, struct stat *st)
{
 75e:	1101                	addi	sp,sp,-32
 760:	ec06                	sd	ra,24(sp)
 762:	e822                	sd	s0,16(sp)
 764:	e426                	sd	s1,8(sp)
 766:	e04a                	sd	s2,0(sp)
 768:	1000                	addi	s0,sp,32
 76a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 76c:	4581                	li	a1,0
 76e:	00000097          	auipc	ra,0x0
 772:	172080e7          	jalr	370(ra) # 8e0 <open>
  if(fd < 0)
 776:	02054563          	bltz	a0,7a0 <stat+0x42>
 77a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 77c:	85ca                	mv	a1,s2
 77e:	00000097          	auipc	ra,0x0
 782:	17a080e7          	jalr	378(ra) # 8f8 <fstat>
 786:	892a                	mv	s2,a0
  close(fd);
 788:	8526                	mv	a0,s1
 78a:	00000097          	auipc	ra,0x0
 78e:	13e080e7          	jalr	318(ra) # 8c8 <close>
  return r;
}
 792:	854a                	mv	a0,s2
 794:	60e2                	ld	ra,24(sp)
 796:	6442                	ld	s0,16(sp)
 798:	64a2                	ld	s1,8(sp)
 79a:	6902                	ld	s2,0(sp)
 79c:	6105                	addi	sp,sp,32
 79e:	8082                	ret
    return -1;
 7a0:	597d                	li	s2,-1
 7a2:	bfc5                	j	792 <stat+0x34>

00000000000007a4 <atoi>:

int
atoi(const char *s)
{
 7a4:	1141                	addi	sp,sp,-16
 7a6:	e422                	sd	s0,8(sp)
 7a8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 7aa:	00054603          	lbu	a2,0(a0)
 7ae:	fd06079b          	addiw	a5,a2,-48
 7b2:	0ff7f793          	andi	a5,a5,255
 7b6:	4725                	li	a4,9
 7b8:	02f76963          	bltu	a4,a5,7ea <atoi+0x46>
 7bc:	86aa                	mv	a3,a0
  n = 0;
 7be:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 7c0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 7c2:	0685                	addi	a3,a3,1
 7c4:	0025179b          	slliw	a5,a0,0x2
 7c8:	9fa9                	addw	a5,a5,a0
 7ca:	0017979b          	slliw	a5,a5,0x1
 7ce:	9fb1                	addw	a5,a5,a2
 7d0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 7d4:	0006c603          	lbu	a2,0(a3)
 7d8:	fd06071b          	addiw	a4,a2,-48
 7dc:	0ff77713          	andi	a4,a4,255
 7e0:	fee5f1e3          	bgeu	a1,a4,7c2 <atoi+0x1e>
  return n;
}
 7e4:	6422                	ld	s0,8(sp)
 7e6:	0141                	addi	sp,sp,16
 7e8:	8082                	ret
  n = 0;
 7ea:	4501                	li	a0,0
 7ec:	bfe5                	j	7e4 <atoi+0x40>

00000000000007ee <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 7ee:	1141                	addi	sp,sp,-16
 7f0:	e422                	sd	s0,8(sp)
 7f2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 7f4:	02b57463          	bgeu	a0,a1,81c <memmove+0x2e>
    while(n-- > 0)
 7f8:	00c05f63          	blez	a2,816 <memmove+0x28>
 7fc:	1602                	slli	a2,a2,0x20
 7fe:	9201                	srli	a2,a2,0x20
 800:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 804:	872a                	mv	a4,a0
      *dst++ = *src++;
 806:	0585                	addi	a1,a1,1
 808:	0705                	addi	a4,a4,1
 80a:	fff5c683          	lbu	a3,-1(a1)
 80e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 812:	fee79ae3          	bne	a5,a4,806 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 816:	6422                	ld	s0,8(sp)
 818:	0141                	addi	sp,sp,16
 81a:	8082                	ret
    dst += n;
 81c:	00c50733          	add	a4,a0,a2
    src += n;
 820:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 822:	fec05ae3          	blez	a2,816 <memmove+0x28>
 826:	fff6079b          	addiw	a5,a2,-1
 82a:	1782                	slli	a5,a5,0x20
 82c:	9381                	srli	a5,a5,0x20
 82e:	fff7c793          	not	a5,a5
 832:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 834:	15fd                	addi	a1,a1,-1
 836:	177d                	addi	a4,a4,-1
 838:	0005c683          	lbu	a3,0(a1)
 83c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 840:	fee79ae3          	bne	a5,a4,834 <memmove+0x46>
 844:	bfc9                	j	816 <memmove+0x28>

0000000000000846 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 846:	1141                	addi	sp,sp,-16
 848:	e422                	sd	s0,8(sp)
 84a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 84c:	ca05                	beqz	a2,87c <memcmp+0x36>
 84e:	fff6069b          	addiw	a3,a2,-1
 852:	1682                	slli	a3,a3,0x20
 854:	9281                	srli	a3,a3,0x20
 856:	0685                	addi	a3,a3,1
 858:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 85a:	00054783          	lbu	a5,0(a0)
 85e:	0005c703          	lbu	a4,0(a1)
 862:	00e79863          	bne	a5,a4,872 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 866:	0505                	addi	a0,a0,1
    p2++;
 868:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 86a:	fed518e3          	bne	a0,a3,85a <memcmp+0x14>
  }
  return 0;
 86e:	4501                	li	a0,0
 870:	a019                	j	876 <memcmp+0x30>
      return *p1 - *p2;
 872:	40e7853b          	subw	a0,a5,a4
}
 876:	6422                	ld	s0,8(sp)
 878:	0141                	addi	sp,sp,16
 87a:	8082                	ret
  return 0;
 87c:	4501                	li	a0,0
 87e:	bfe5                	j	876 <memcmp+0x30>

0000000000000880 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 880:	1141                	addi	sp,sp,-16
 882:	e406                	sd	ra,8(sp)
 884:	e022                	sd	s0,0(sp)
 886:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 888:	00000097          	auipc	ra,0x0
 88c:	f66080e7          	jalr	-154(ra) # 7ee <memmove>
}
 890:	60a2                	ld	ra,8(sp)
 892:	6402                	ld	s0,0(sp)
 894:	0141                	addi	sp,sp,16
 896:	8082                	ret

0000000000000898 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 898:	4885                	li	a7,1
 ecall
 89a:	00000073          	ecall
 ret
 89e:	8082                	ret

00000000000008a0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 8a0:	4889                	li	a7,2
 ecall
 8a2:	00000073          	ecall
 ret
 8a6:	8082                	ret

00000000000008a8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 8a8:	488d                	li	a7,3
 ecall
 8aa:	00000073          	ecall
 ret
 8ae:	8082                	ret

00000000000008b0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 8b0:	4891                	li	a7,4
 ecall
 8b2:	00000073          	ecall
 ret
 8b6:	8082                	ret

00000000000008b8 <read>:
.global read
read:
 li a7, SYS_read
 8b8:	4895                	li	a7,5
 ecall
 8ba:	00000073          	ecall
 ret
 8be:	8082                	ret

00000000000008c0 <write>:
.global write
write:
 li a7, SYS_write
 8c0:	48c1                	li	a7,16
 ecall
 8c2:	00000073          	ecall
 ret
 8c6:	8082                	ret

00000000000008c8 <close>:
.global close
close:
 li a7, SYS_close
 8c8:	48d5                	li	a7,21
 ecall
 8ca:	00000073          	ecall
 ret
 8ce:	8082                	ret

00000000000008d0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 8d0:	4899                	li	a7,6
 ecall
 8d2:	00000073          	ecall
 ret
 8d6:	8082                	ret

00000000000008d8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 8d8:	489d                	li	a7,7
 ecall
 8da:	00000073          	ecall
 ret
 8de:	8082                	ret

00000000000008e0 <open>:
.global open
open:
 li a7, SYS_open
 8e0:	48bd                	li	a7,15
 ecall
 8e2:	00000073          	ecall
 ret
 8e6:	8082                	ret

00000000000008e8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 8e8:	48c5                	li	a7,17
 ecall
 8ea:	00000073          	ecall
 ret
 8ee:	8082                	ret

00000000000008f0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 8f0:	48c9                	li	a7,18
 ecall
 8f2:	00000073          	ecall
 ret
 8f6:	8082                	ret

00000000000008f8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 8f8:	48a1                	li	a7,8
 ecall
 8fa:	00000073          	ecall
 ret
 8fe:	8082                	ret

0000000000000900 <link>:
.global link
link:
 li a7, SYS_link
 900:	48cd                	li	a7,19
 ecall
 902:	00000073          	ecall
 ret
 906:	8082                	ret

0000000000000908 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 908:	48d1                	li	a7,20
 ecall
 90a:	00000073          	ecall
 ret
 90e:	8082                	ret

0000000000000910 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 910:	48a5                	li	a7,9
 ecall
 912:	00000073          	ecall
 ret
 916:	8082                	ret

0000000000000918 <dup>:
.global dup
dup:
 li a7, SYS_dup
 918:	48a9                	li	a7,10
 ecall
 91a:	00000073          	ecall
 ret
 91e:	8082                	ret

0000000000000920 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 920:	48ad                	li	a7,11
 ecall
 922:	00000073          	ecall
 ret
 926:	8082                	ret

0000000000000928 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 928:	48b1                	li	a7,12
 ecall
 92a:	00000073          	ecall
 ret
 92e:	8082                	ret

0000000000000930 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 930:	48b5                	li	a7,13
 ecall
 932:	00000073          	ecall
 ret
 936:	8082                	ret

0000000000000938 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 938:	48b9                	li	a7,14
 ecall
 93a:	00000073          	ecall
 ret
 93e:	8082                	ret

0000000000000940 <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
 940:	48d9                	li	a7,22
 ecall
 942:	00000073          	ecall
 ret
 946:	8082                	ret

0000000000000948 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
 948:	48dd                	li	a7,23
 ecall
 94a:	00000073          	ecall
 ret
 94e:	8082                	ret

0000000000000950 <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
 950:	48e1                	li	a7,24
 ecall
 952:	00000073          	ecall
 ret
 956:	8082                	ret

0000000000000958 <bsem_alloc>:
.global bsem_alloc
bsem_alloc:
 li a7, SYS_bsem_alloc
 958:	48e5                	li	a7,25
 ecall
 95a:	00000073          	ecall
 ret
 95e:	8082                	ret

0000000000000960 <bsem_free>:
.global bsem_free
bsem_free:
 li a7, SYS_bsem_free
 960:	48e9                	li	a7,26
 ecall
 962:	00000073          	ecall
 ret
 966:	8082                	ret

0000000000000968 <bsem_down>:
.global bsem_down
bsem_down:
 li a7, SYS_bsem_down
 968:	48ed                	li	a7,27
 ecall
 96a:	00000073          	ecall
 ret
 96e:	8082                	ret

0000000000000970 <bsem_up>:
.global bsem_up
bsem_up:
 li a7, SYS_bsem_up
 970:	48f1                	li	a7,28
 ecall
 972:	00000073          	ecall
 ret
 976:	8082                	ret

0000000000000978 <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
 978:	48f5                	li	a7,29
 ecall
 97a:	00000073          	ecall
 ret
 97e:	8082                	ret

0000000000000980 <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
 980:	48f9                	li	a7,30
 ecall
 982:	00000073          	ecall
 ret
 986:	8082                	ret

0000000000000988 <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
 988:	48fd                	li	a7,31
 ecall
 98a:	00000073          	ecall
 ret
 98e:	8082                	ret

0000000000000990 <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
 990:	02000893          	li	a7,32
 ecall
 994:	00000073          	ecall
 ret
 998:	8082                	ret

000000000000099a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 99a:	1101                	addi	sp,sp,-32
 99c:	ec06                	sd	ra,24(sp)
 99e:	e822                	sd	s0,16(sp)
 9a0:	1000                	addi	s0,sp,32
 9a2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 9a6:	4605                	li	a2,1
 9a8:	fef40593          	addi	a1,s0,-17
 9ac:	00000097          	auipc	ra,0x0
 9b0:	f14080e7          	jalr	-236(ra) # 8c0 <write>
}
 9b4:	60e2                	ld	ra,24(sp)
 9b6:	6442                	ld	s0,16(sp)
 9b8:	6105                	addi	sp,sp,32
 9ba:	8082                	ret

00000000000009bc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 9bc:	7139                	addi	sp,sp,-64
 9be:	fc06                	sd	ra,56(sp)
 9c0:	f822                	sd	s0,48(sp)
 9c2:	f426                	sd	s1,40(sp)
 9c4:	f04a                	sd	s2,32(sp)
 9c6:	ec4e                	sd	s3,24(sp)
 9c8:	0080                	addi	s0,sp,64
 9ca:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 9cc:	c299                	beqz	a3,9d2 <printint+0x16>
 9ce:	0805c863          	bltz	a1,a5e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 9d2:	2581                	sext.w	a1,a1
  neg = 0;
 9d4:	4881                	li	a7,0
 9d6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 9da:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 9dc:	2601                	sext.w	a2,a2
 9de:	00001517          	auipc	a0,0x1
 9e2:	80a50513          	addi	a0,a0,-2038 # 11e8 <digits>
 9e6:	883a                	mv	a6,a4
 9e8:	2705                	addiw	a4,a4,1
 9ea:	02c5f7bb          	remuw	a5,a1,a2
 9ee:	1782                	slli	a5,a5,0x20
 9f0:	9381                	srli	a5,a5,0x20
 9f2:	97aa                	add	a5,a5,a0
 9f4:	0007c783          	lbu	a5,0(a5)
 9f8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 9fc:	0005879b          	sext.w	a5,a1
 a00:	02c5d5bb          	divuw	a1,a1,a2
 a04:	0685                	addi	a3,a3,1
 a06:	fec7f0e3          	bgeu	a5,a2,9e6 <printint+0x2a>
  if(neg)
 a0a:	00088b63          	beqz	a7,a20 <printint+0x64>
    buf[i++] = '-';
 a0e:	fd040793          	addi	a5,s0,-48
 a12:	973e                	add	a4,a4,a5
 a14:	02d00793          	li	a5,45
 a18:	fef70823          	sb	a5,-16(a4)
 a1c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 a20:	02e05863          	blez	a4,a50 <printint+0x94>
 a24:	fc040793          	addi	a5,s0,-64
 a28:	00e78933          	add	s2,a5,a4
 a2c:	fff78993          	addi	s3,a5,-1
 a30:	99ba                	add	s3,s3,a4
 a32:	377d                	addiw	a4,a4,-1
 a34:	1702                	slli	a4,a4,0x20
 a36:	9301                	srli	a4,a4,0x20
 a38:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 a3c:	fff94583          	lbu	a1,-1(s2)
 a40:	8526                	mv	a0,s1
 a42:	00000097          	auipc	ra,0x0
 a46:	f58080e7          	jalr	-168(ra) # 99a <putc>
  while(--i >= 0)
 a4a:	197d                	addi	s2,s2,-1
 a4c:	ff3918e3          	bne	s2,s3,a3c <printint+0x80>
}
 a50:	70e2                	ld	ra,56(sp)
 a52:	7442                	ld	s0,48(sp)
 a54:	74a2                	ld	s1,40(sp)
 a56:	7902                	ld	s2,32(sp)
 a58:	69e2                	ld	s3,24(sp)
 a5a:	6121                	addi	sp,sp,64
 a5c:	8082                	ret
    x = -xx;
 a5e:	40b005bb          	negw	a1,a1
    neg = 1;
 a62:	4885                	li	a7,1
    x = -xx;
 a64:	bf8d                	j	9d6 <printint+0x1a>

0000000000000a66 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 a66:	7119                	addi	sp,sp,-128
 a68:	fc86                	sd	ra,120(sp)
 a6a:	f8a2                	sd	s0,112(sp)
 a6c:	f4a6                	sd	s1,104(sp)
 a6e:	f0ca                	sd	s2,96(sp)
 a70:	ecce                	sd	s3,88(sp)
 a72:	e8d2                	sd	s4,80(sp)
 a74:	e4d6                	sd	s5,72(sp)
 a76:	e0da                	sd	s6,64(sp)
 a78:	fc5e                	sd	s7,56(sp)
 a7a:	f862                	sd	s8,48(sp)
 a7c:	f466                	sd	s9,40(sp)
 a7e:	f06a                	sd	s10,32(sp)
 a80:	ec6e                	sd	s11,24(sp)
 a82:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 a84:	0005c903          	lbu	s2,0(a1)
 a88:	18090f63          	beqz	s2,c26 <vprintf+0x1c0>
 a8c:	8aaa                	mv	s5,a0
 a8e:	8b32                	mv	s6,a2
 a90:	00158493          	addi	s1,a1,1
  state = 0;
 a94:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 a96:	02500a13          	li	s4,37
      if(c == 'd'){
 a9a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 a9e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 aa2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 aa6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 aaa:	00000b97          	auipc	s7,0x0
 aae:	73eb8b93          	addi	s7,s7,1854 # 11e8 <digits>
 ab2:	a839                	j	ad0 <vprintf+0x6a>
        putc(fd, c);
 ab4:	85ca                	mv	a1,s2
 ab6:	8556                	mv	a0,s5
 ab8:	00000097          	auipc	ra,0x0
 abc:	ee2080e7          	jalr	-286(ra) # 99a <putc>
 ac0:	a019                	j	ac6 <vprintf+0x60>
    } else if(state == '%'){
 ac2:	01498f63          	beq	s3,s4,ae0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 ac6:	0485                	addi	s1,s1,1
 ac8:	fff4c903          	lbu	s2,-1(s1)
 acc:	14090d63          	beqz	s2,c26 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 ad0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 ad4:	fe0997e3          	bnez	s3,ac2 <vprintf+0x5c>
      if(c == '%'){
 ad8:	fd479ee3          	bne	a5,s4,ab4 <vprintf+0x4e>
        state = '%';
 adc:	89be                	mv	s3,a5
 ade:	b7e5                	j	ac6 <vprintf+0x60>
      if(c == 'd'){
 ae0:	05878063          	beq	a5,s8,b20 <vprintf+0xba>
      } else if(c == 'l') {
 ae4:	05978c63          	beq	a5,s9,b3c <vprintf+0xd6>
      } else if(c == 'x') {
 ae8:	07a78863          	beq	a5,s10,b58 <vprintf+0xf2>
      } else if(c == 'p') {
 aec:	09b78463          	beq	a5,s11,b74 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 af0:	07300713          	li	a4,115
 af4:	0ce78663          	beq	a5,a4,bc0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 af8:	06300713          	li	a4,99
 afc:	0ee78e63          	beq	a5,a4,bf8 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 b00:	11478863          	beq	a5,s4,c10 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b04:	85d2                	mv	a1,s4
 b06:	8556                	mv	a0,s5
 b08:	00000097          	auipc	ra,0x0
 b0c:	e92080e7          	jalr	-366(ra) # 99a <putc>
        putc(fd, c);
 b10:	85ca                	mv	a1,s2
 b12:	8556                	mv	a0,s5
 b14:	00000097          	auipc	ra,0x0
 b18:	e86080e7          	jalr	-378(ra) # 99a <putc>
      }
      state = 0;
 b1c:	4981                	li	s3,0
 b1e:	b765                	j	ac6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 b20:	008b0913          	addi	s2,s6,8
 b24:	4685                	li	a3,1
 b26:	4629                	li	a2,10
 b28:	000b2583          	lw	a1,0(s6)
 b2c:	8556                	mv	a0,s5
 b2e:	00000097          	auipc	ra,0x0
 b32:	e8e080e7          	jalr	-370(ra) # 9bc <printint>
 b36:	8b4a                	mv	s6,s2
      state = 0;
 b38:	4981                	li	s3,0
 b3a:	b771                	j	ac6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b3c:	008b0913          	addi	s2,s6,8
 b40:	4681                	li	a3,0
 b42:	4629                	li	a2,10
 b44:	000b2583          	lw	a1,0(s6)
 b48:	8556                	mv	a0,s5
 b4a:	00000097          	auipc	ra,0x0
 b4e:	e72080e7          	jalr	-398(ra) # 9bc <printint>
 b52:	8b4a                	mv	s6,s2
      state = 0;
 b54:	4981                	li	s3,0
 b56:	bf85                	j	ac6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 b58:	008b0913          	addi	s2,s6,8
 b5c:	4681                	li	a3,0
 b5e:	4641                	li	a2,16
 b60:	000b2583          	lw	a1,0(s6)
 b64:	8556                	mv	a0,s5
 b66:	00000097          	auipc	ra,0x0
 b6a:	e56080e7          	jalr	-426(ra) # 9bc <printint>
 b6e:	8b4a                	mv	s6,s2
      state = 0;
 b70:	4981                	li	s3,0
 b72:	bf91                	j	ac6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 b74:	008b0793          	addi	a5,s6,8
 b78:	f8f43423          	sd	a5,-120(s0)
 b7c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 b80:	03000593          	li	a1,48
 b84:	8556                	mv	a0,s5
 b86:	00000097          	auipc	ra,0x0
 b8a:	e14080e7          	jalr	-492(ra) # 99a <putc>
  putc(fd, 'x');
 b8e:	85ea                	mv	a1,s10
 b90:	8556                	mv	a0,s5
 b92:	00000097          	auipc	ra,0x0
 b96:	e08080e7          	jalr	-504(ra) # 99a <putc>
 b9a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 b9c:	03c9d793          	srli	a5,s3,0x3c
 ba0:	97de                	add	a5,a5,s7
 ba2:	0007c583          	lbu	a1,0(a5)
 ba6:	8556                	mv	a0,s5
 ba8:	00000097          	auipc	ra,0x0
 bac:	df2080e7          	jalr	-526(ra) # 99a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 bb0:	0992                	slli	s3,s3,0x4
 bb2:	397d                	addiw	s2,s2,-1
 bb4:	fe0914e3          	bnez	s2,b9c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 bb8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 bbc:	4981                	li	s3,0
 bbe:	b721                	j	ac6 <vprintf+0x60>
        s = va_arg(ap, char*);
 bc0:	008b0993          	addi	s3,s6,8
 bc4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 bc8:	02090163          	beqz	s2,bea <vprintf+0x184>
        while(*s != 0){
 bcc:	00094583          	lbu	a1,0(s2)
 bd0:	c9a1                	beqz	a1,c20 <vprintf+0x1ba>
          putc(fd, *s);
 bd2:	8556                	mv	a0,s5
 bd4:	00000097          	auipc	ra,0x0
 bd8:	dc6080e7          	jalr	-570(ra) # 99a <putc>
          s++;
 bdc:	0905                	addi	s2,s2,1
        while(*s != 0){
 bde:	00094583          	lbu	a1,0(s2)
 be2:	f9e5                	bnez	a1,bd2 <vprintf+0x16c>
        s = va_arg(ap, char*);
 be4:	8b4e                	mv	s6,s3
      state = 0;
 be6:	4981                	li	s3,0
 be8:	bdf9                	j	ac6 <vprintf+0x60>
          s = "(null)";
 bea:	00000917          	auipc	s2,0x0
 bee:	5f690913          	addi	s2,s2,1526 # 11e0 <csem_up+0x302>
        while(*s != 0){
 bf2:	02800593          	li	a1,40
 bf6:	bff1                	j	bd2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 bf8:	008b0913          	addi	s2,s6,8
 bfc:	000b4583          	lbu	a1,0(s6)
 c00:	8556                	mv	a0,s5
 c02:	00000097          	auipc	ra,0x0
 c06:	d98080e7          	jalr	-616(ra) # 99a <putc>
 c0a:	8b4a                	mv	s6,s2
      state = 0;
 c0c:	4981                	li	s3,0
 c0e:	bd65                	j	ac6 <vprintf+0x60>
        putc(fd, c);
 c10:	85d2                	mv	a1,s4
 c12:	8556                	mv	a0,s5
 c14:	00000097          	auipc	ra,0x0
 c18:	d86080e7          	jalr	-634(ra) # 99a <putc>
      state = 0;
 c1c:	4981                	li	s3,0
 c1e:	b565                	j	ac6 <vprintf+0x60>
        s = va_arg(ap, char*);
 c20:	8b4e                	mv	s6,s3
      state = 0;
 c22:	4981                	li	s3,0
 c24:	b54d                	j	ac6 <vprintf+0x60>
    }
  }
}
 c26:	70e6                	ld	ra,120(sp)
 c28:	7446                	ld	s0,112(sp)
 c2a:	74a6                	ld	s1,104(sp)
 c2c:	7906                	ld	s2,96(sp)
 c2e:	69e6                	ld	s3,88(sp)
 c30:	6a46                	ld	s4,80(sp)
 c32:	6aa6                	ld	s5,72(sp)
 c34:	6b06                	ld	s6,64(sp)
 c36:	7be2                	ld	s7,56(sp)
 c38:	7c42                	ld	s8,48(sp)
 c3a:	7ca2                	ld	s9,40(sp)
 c3c:	7d02                	ld	s10,32(sp)
 c3e:	6de2                	ld	s11,24(sp)
 c40:	6109                	addi	sp,sp,128
 c42:	8082                	ret

0000000000000c44 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c44:	715d                	addi	sp,sp,-80
 c46:	ec06                	sd	ra,24(sp)
 c48:	e822                	sd	s0,16(sp)
 c4a:	1000                	addi	s0,sp,32
 c4c:	e010                	sd	a2,0(s0)
 c4e:	e414                	sd	a3,8(s0)
 c50:	e818                	sd	a4,16(s0)
 c52:	ec1c                	sd	a5,24(s0)
 c54:	03043023          	sd	a6,32(s0)
 c58:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c5c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c60:	8622                	mv	a2,s0
 c62:	00000097          	auipc	ra,0x0
 c66:	e04080e7          	jalr	-508(ra) # a66 <vprintf>
}
 c6a:	60e2                	ld	ra,24(sp)
 c6c:	6442                	ld	s0,16(sp)
 c6e:	6161                	addi	sp,sp,80
 c70:	8082                	ret

0000000000000c72 <printf>:

void
printf(const char *fmt, ...)
{
 c72:	711d                	addi	sp,sp,-96
 c74:	ec06                	sd	ra,24(sp)
 c76:	e822                	sd	s0,16(sp)
 c78:	1000                	addi	s0,sp,32
 c7a:	e40c                	sd	a1,8(s0)
 c7c:	e810                	sd	a2,16(s0)
 c7e:	ec14                	sd	a3,24(s0)
 c80:	f018                	sd	a4,32(s0)
 c82:	f41c                	sd	a5,40(s0)
 c84:	03043823          	sd	a6,48(s0)
 c88:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 c8c:	00840613          	addi	a2,s0,8
 c90:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 c94:	85aa                	mv	a1,a0
 c96:	4505                	li	a0,1
 c98:	00000097          	auipc	ra,0x0
 c9c:	dce080e7          	jalr	-562(ra) # a66 <vprintf>
}
 ca0:	60e2                	ld	ra,24(sp)
 ca2:	6442                	ld	s0,16(sp)
 ca4:	6125                	addi	sp,sp,96
 ca6:	8082                	ret

0000000000000ca8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ca8:	1141                	addi	sp,sp,-16
 caa:	e422                	sd	s0,8(sp)
 cac:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 cae:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cb2:	00000797          	auipc	a5,0x0
 cb6:	54e7b783          	ld	a5,1358(a5) # 1200 <freep>
 cba:	a805                	j	cea <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 cbc:	4618                	lw	a4,8(a2)
 cbe:	9db9                	addw	a1,a1,a4
 cc0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 cc4:	6398                	ld	a4,0(a5)
 cc6:	6318                	ld	a4,0(a4)
 cc8:	fee53823          	sd	a4,-16(a0)
 ccc:	a091                	j	d10 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 cce:	ff852703          	lw	a4,-8(a0)
 cd2:	9e39                	addw	a2,a2,a4
 cd4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 cd6:	ff053703          	ld	a4,-16(a0)
 cda:	e398                	sd	a4,0(a5)
 cdc:	a099                	j	d22 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 cde:	6398                	ld	a4,0(a5)
 ce0:	00e7e463          	bltu	a5,a4,ce8 <free+0x40>
 ce4:	00e6ea63          	bltu	a3,a4,cf8 <free+0x50>
{
 ce8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cea:	fed7fae3          	bgeu	a5,a3,cde <free+0x36>
 cee:	6398                	ld	a4,0(a5)
 cf0:	00e6e463          	bltu	a3,a4,cf8 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 cf4:	fee7eae3          	bltu	a5,a4,ce8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 cf8:	ff852583          	lw	a1,-8(a0)
 cfc:	6390                	ld	a2,0(a5)
 cfe:	02059813          	slli	a6,a1,0x20
 d02:	01c85713          	srli	a4,a6,0x1c
 d06:	9736                	add	a4,a4,a3
 d08:	fae60ae3          	beq	a2,a4,cbc <free+0x14>
    bp->s.ptr = p->s.ptr;
 d0c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d10:	4790                	lw	a2,8(a5)
 d12:	02061593          	slli	a1,a2,0x20
 d16:	01c5d713          	srli	a4,a1,0x1c
 d1a:	973e                	add	a4,a4,a5
 d1c:	fae689e3          	beq	a3,a4,cce <free+0x26>
  } else
    p->s.ptr = bp;
 d20:	e394                	sd	a3,0(a5)
  freep = p;
 d22:	00000717          	auipc	a4,0x0
 d26:	4cf73f23          	sd	a5,1246(a4) # 1200 <freep>
}
 d2a:	6422                	ld	s0,8(sp)
 d2c:	0141                	addi	sp,sp,16
 d2e:	8082                	ret

0000000000000d30 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 d30:	7139                	addi	sp,sp,-64
 d32:	fc06                	sd	ra,56(sp)
 d34:	f822                	sd	s0,48(sp)
 d36:	f426                	sd	s1,40(sp)
 d38:	f04a                	sd	s2,32(sp)
 d3a:	ec4e                	sd	s3,24(sp)
 d3c:	e852                	sd	s4,16(sp)
 d3e:	e456                	sd	s5,8(sp)
 d40:	e05a                	sd	s6,0(sp)
 d42:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d44:	02051493          	slli	s1,a0,0x20
 d48:	9081                	srli	s1,s1,0x20
 d4a:	04bd                	addi	s1,s1,15
 d4c:	8091                	srli	s1,s1,0x4
 d4e:	0014899b          	addiw	s3,s1,1
 d52:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 d54:	00000517          	auipc	a0,0x0
 d58:	4ac53503          	ld	a0,1196(a0) # 1200 <freep>
 d5c:	c515                	beqz	a0,d88 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d5e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d60:	4798                	lw	a4,8(a5)
 d62:	02977f63          	bgeu	a4,s1,da0 <malloc+0x70>
 d66:	8a4e                	mv	s4,s3
 d68:	0009871b          	sext.w	a4,s3
 d6c:	6685                	lui	a3,0x1
 d6e:	00d77363          	bgeu	a4,a3,d74 <malloc+0x44>
 d72:	6a05                	lui	s4,0x1
 d74:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 d78:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 d7c:	00000917          	auipc	s2,0x0
 d80:	48490913          	addi	s2,s2,1156 # 1200 <freep>
  if(p == (char*)-1)
 d84:	5afd                	li	s5,-1
 d86:	a895                	j	dfa <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 d88:	00000797          	auipc	a5,0x0
 d8c:	48078793          	addi	a5,a5,1152 # 1208 <base>
 d90:	00000717          	auipc	a4,0x0
 d94:	46f73823          	sd	a5,1136(a4) # 1200 <freep>
 d98:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 d9a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 d9e:	b7e1                	j	d66 <malloc+0x36>
      if(p->s.size == nunits)
 da0:	02e48c63          	beq	s1,a4,dd8 <malloc+0xa8>
        p->s.size -= nunits;
 da4:	4137073b          	subw	a4,a4,s3
 da8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 daa:	02071693          	slli	a3,a4,0x20
 dae:	01c6d713          	srli	a4,a3,0x1c
 db2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 db4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 db8:	00000717          	auipc	a4,0x0
 dbc:	44a73423          	sd	a0,1096(a4) # 1200 <freep>
      return (void*)(p + 1);
 dc0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 dc4:	70e2                	ld	ra,56(sp)
 dc6:	7442                	ld	s0,48(sp)
 dc8:	74a2                	ld	s1,40(sp)
 dca:	7902                	ld	s2,32(sp)
 dcc:	69e2                	ld	s3,24(sp)
 dce:	6a42                	ld	s4,16(sp)
 dd0:	6aa2                	ld	s5,8(sp)
 dd2:	6b02                	ld	s6,0(sp)
 dd4:	6121                	addi	sp,sp,64
 dd6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 dd8:	6398                	ld	a4,0(a5)
 dda:	e118                	sd	a4,0(a0)
 ddc:	bff1                	j	db8 <malloc+0x88>
  hp->s.size = nu;
 dde:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 de2:	0541                	addi	a0,a0,16
 de4:	00000097          	auipc	ra,0x0
 de8:	ec4080e7          	jalr	-316(ra) # ca8 <free>
  return freep;
 dec:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 df0:	d971                	beqz	a0,dc4 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 df2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 df4:	4798                	lw	a4,8(a5)
 df6:	fa9775e3          	bgeu	a4,s1,da0 <malloc+0x70>
    if(p == freep)
 dfa:	00093703          	ld	a4,0(s2)
 dfe:	853e                	mv	a0,a5
 e00:	fef719e3          	bne	a4,a5,df2 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 e04:	8552                	mv	a0,s4
 e06:	00000097          	auipc	ra,0x0
 e0a:	b22080e7          	jalr	-1246(ra) # 928 <sbrk>
  if(p == (char*)-1)
 e0e:	fd5518e3          	bne	a0,s5,dde <malloc+0xae>
        return 0;
 e12:	4501                	li	a0,0
 e14:	bf45                	j	dc4 <malloc+0x94>

0000000000000e16 <csem_alloc>:
// #include "user/user.h"
// #include "kernel/fcntl.h"



int csem_alloc(struct counting_semaphore *Csem, int initVal){
 e16:	7179                	addi	sp,sp,-48
 e18:	f406                	sd	ra,40(sp)
 e1a:	f022                	sd	s0,32(sp)
 e1c:	ec26                	sd	s1,24(sp)
 e1e:	e84a                	sd	s2,16(sp)
 e20:	e44e                	sd	s3,8(sp)
 e22:	1800                	addi	s0,sp,48
 e24:	892a                	mv	s2,a0
 e26:	89ae                	mv	s3,a1
    // return -1;     //************************todo: fix and remove!
    int Bsem1 = bsem_alloc();
 e28:	00000097          	auipc	ra,0x0
 e2c:	b30080e7          	jalr	-1232(ra) # 958 <bsem_alloc>
 e30:	84aa                	mv	s1,a0
    int Bsem2 = bsem_alloc();
 e32:	00000097          	auipc	ra,0x0
 e36:	b26080e7          	jalr	-1242(ra) # 958 <bsem_alloc>
    if( Bsem1 == -1 || Bsem2 == -1) // one of the semaphores is not valid
 e3a:	57fd                	li	a5,-1
 e3c:	00f48b63          	beq	s1,a5,e52 <csem_alloc+0x3c>
 e40:	02f50163          	beq	a0,a5,e62 <csem_alloc+0x4c>
        return -1;

    Csem->Bsem1 = Bsem1;
 e44:	00992023          	sw	s1,0(s2)
    Csem->Bsem2 = Bsem2;
 e48:	00a92223          	sw	a0,4(s2)
    Csem->value = initVal;
 e4c:	01392423          	sw	s3,8(s2)
    return 0;
 e50:	4481                	li	s1,0
}
 e52:	8526                	mv	a0,s1
 e54:	70a2                	ld	ra,40(sp)
 e56:	7402                	ld	s0,32(sp)
 e58:	64e2                	ld	s1,24(sp)
 e5a:	6942                	ld	s2,16(sp)
 e5c:	69a2                	ld	s3,8(sp)
 e5e:	6145                	addi	sp,sp,48
 e60:	8082                	ret
        return -1;
 e62:	84aa                	mv	s1,a0
 e64:	b7fd                	j	e52 <csem_alloc+0x3c>

0000000000000e66 <csem_free>:


void csem_free(struct counting_semaphore *Csem){
 e66:	1101                	addi	sp,sp,-32
 e68:	ec06                	sd	ra,24(sp)
 e6a:	e822                	sd	s0,16(sp)
 e6c:	e426                	sd	s1,8(sp)
 e6e:	1000                	addi	s0,sp,32
 e70:	84aa                	mv	s1,a0
    bsem_free(Csem->Bsem1);
 e72:	4108                	lw	a0,0(a0)
 e74:	00000097          	auipc	ra,0x0
 e78:	aec080e7          	jalr	-1300(ra) # 960 <bsem_free>
    bsem_free(Csem->Bsem2);
 e7c:	40c8                	lw	a0,4(s1)
 e7e:	00000097          	auipc	ra,0x0
 e82:	ae2080e7          	jalr	-1310(ra) # 960 <bsem_free>
}
 e86:	60e2                	ld	ra,24(sp)
 e88:	6442                	ld	s0,16(sp)
 e8a:	64a2                	ld	s1,8(sp)
 e8c:	6105                	addi	sp,sp,32
 e8e:	8082                	ret

0000000000000e90 <csem_down>:

void csem_down(struct counting_semaphore *Csem){
 e90:	1101                	addi	sp,sp,-32
 e92:	ec06                	sd	ra,24(sp)
 e94:	e822                	sd	s0,16(sp)
 e96:	e426                	sd	s1,8(sp)
 e98:	1000                	addi	s0,sp,32
 e9a:	84aa                	mv	s1,a0
    bsem_down(Csem->Bsem2);
 e9c:	4148                	lw	a0,4(a0)
 e9e:	00000097          	auipc	ra,0x0
 ea2:	aca080e7          	jalr	-1334(ra) # 968 <bsem_down>
    bsem_down(Csem->Bsem1);
 ea6:	4088                	lw	a0,0(s1)
 ea8:	00000097          	auipc	ra,0x0
 eac:	ac0080e7          	jalr	-1344(ra) # 968 <bsem_down>
    Csem->value--;
 eb0:	449c                	lw	a5,8(s1)
 eb2:	37fd                	addiw	a5,a5,-1
 eb4:	0007871b          	sext.w	a4,a5
 eb8:	c49c                	sw	a5,8(s1)
    if(Csem->value >0){
 eba:	00e04c63          	bgtz	a4,ed2 <csem_down+0x42>
        bsem_up(Csem->Bsem2);
    }
    bsem_up(Csem->Bsem1);
 ebe:	4088                	lw	a0,0(s1)
 ec0:	00000097          	auipc	ra,0x0
 ec4:	ab0080e7          	jalr	-1360(ra) # 970 <bsem_up>
}
 ec8:	60e2                	ld	ra,24(sp)
 eca:	6442                	ld	s0,16(sp)
 ecc:	64a2                	ld	s1,8(sp)
 ece:	6105                	addi	sp,sp,32
 ed0:	8082                	ret
        bsem_up(Csem->Bsem2);
 ed2:	40c8                	lw	a0,4(s1)
 ed4:	00000097          	auipc	ra,0x0
 ed8:	a9c080e7          	jalr	-1380(ra) # 970 <bsem_up>
 edc:	b7cd                	j	ebe <csem_down+0x2e>

0000000000000ede <csem_up>:



void csem_up(struct counting_semaphore *Csem){
 ede:	1101                	addi	sp,sp,-32
 ee0:	ec06                	sd	ra,24(sp)
 ee2:	e822                	sd	s0,16(sp)
 ee4:	e426                	sd	s1,8(sp)
 ee6:	1000                	addi	s0,sp,32
 ee8:	84aa                	mv	s1,a0
    bsem_down(Csem->Bsem1);
 eea:	4108                	lw	a0,0(a0)
 eec:	00000097          	auipc	ra,0x0
 ef0:	a7c080e7          	jalr	-1412(ra) # 968 <bsem_down>
    Csem->value++;
 ef4:	449c                	lw	a5,8(s1)
 ef6:	2785                	addiw	a5,a5,1
 ef8:	0007871b          	sext.w	a4,a5
 efc:	c49c                	sw	a5,8(s1)
    if(Csem->value ==1){
 efe:	4785                	li	a5,1
 f00:	00f70c63          	beq	a4,a5,f18 <csem_up+0x3a>
        bsem_up(Csem->Bsem2);
    }
    bsem_up(Csem->Bsem1);
 f04:	4088                	lw	a0,0(s1)
 f06:	00000097          	auipc	ra,0x0
 f0a:	a6a080e7          	jalr	-1430(ra) # 970 <bsem_up>


}
 f0e:	60e2                	ld	ra,24(sp)
 f10:	6442                	ld	s0,16(sp)
 f12:	64a2                	ld	s1,8(sp)
 f14:	6105                	addi	sp,sp,32
 f16:	8082                	ret
        bsem_up(Csem->Bsem2);
 f18:	40c8                	lw	a0,4(s1)
 f1a:	00000097          	auipc	ra,0x0
 f1e:	a56080e7          	jalr	-1450(ra) # 970 <bsem_up>
 f22:	b7cd                	j	f04 <csem_up+0x26>
