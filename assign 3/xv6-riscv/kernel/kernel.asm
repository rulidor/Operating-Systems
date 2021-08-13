
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	18010113          	addi	sp,sp,384 # 80009180 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	7ac78793          	addi	a5,a5,1964 # 80006810 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd07ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dde78793          	addi	a5,a5,-546 # 80000e8c <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000106:	04c05663          	blez	a2,80000152 <consolewrite+0x5e>
    8000010a:	8a2a                	mv	s4,a0
    8000010c:	84ae                	mv	s1,a1
    8000010e:	89b2                	mv	s3,a2
    80000110:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000112:	5afd                	li	s5,-1
    80000114:	4685                	li	a3,1
    80000116:	8626                	mv	a2,s1
    80000118:	85d2                	mv	a1,s4
    8000011a:	fbf40513          	addi	a0,s0,-65
    8000011e:	00003097          	auipc	ra,0x3
    80000122:	9a8080e7          	jalr	-1624(ra) # 80002ac6 <either_copyin>
    80000126:	01550c63          	beq	a0,s5,8000013e <consolewrite+0x4a>
      break;
    uartputc(c);
    8000012a:	fbf44503          	lbu	a0,-65(s0)
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	77a080e7          	jalr	1914(ra) # 800008a8 <uartputc>
  for(i = 0; i < n; i++){
    80000136:	2905                	addiw	s2,s2,1
    80000138:	0485                	addi	s1,s1,1
    8000013a:	fd299de3          	bne	s3,s2,80000114 <consolewrite+0x20>
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60a6                	ld	ra,72(sp)
    80000142:	6406                	ld	s0,64(sp)
    80000144:	74e2                	ld	s1,56(sp)
    80000146:	7942                	ld	s2,48(sp)
    80000148:	79a2                	ld	s3,40(sp)
    8000014a:	7a02                	ld	s4,32(sp)
    8000014c:	6ae2                	ld	s5,24(sp)
    8000014e:	6161                	addi	sp,sp,80
    80000150:	8082                	ret
  for(i = 0; i < n; i++){
    80000152:	4901                	li	s2,0
    80000154:	b7ed                	j	8000013e <consolewrite+0x4a>

0000000080000156 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000156:	7159                	addi	sp,sp,-112
    80000158:	f486                	sd	ra,104(sp)
    8000015a:	f0a2                	sd	s0,96(sp)
    8000015c:	eca6                	sd	s1,88(sp)
    8000015e:	e8ca                	sd	s2,80(sp)
    80000160:	e4ce                	sd	s3,72(sp)
    80000162:	e0d2                	sd	s4,64(sp)
    80000164:	fc56                	sd	s5,56(sp)
    80000166:	f85a                	sd	s6,48(sp)
    80000168:	f45e                	sd	s7,40(sp)
    8000016a:	f062                	sd	s8,32(sp)
    8000016c:	ec66                	sd	s9,24(sp)
    8000016e:	e86a                	sd	s10,16(sp)
    80000170:	1880                	addi	s0,sp,112
    80000172:	8aaa                	mv	s5,a0
    80000174:	8a2e                	mv	s4,a1
    80000176:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000178:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000017c:	00011517          	auipc	a0,0x11
    80000180:	00450513          	addi	a0,a0,4 # 80011180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a5e080e7          	jalr	-1442(ra) # 80000be2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00011497          	auipc	s1,0x11
    80000190:	ff448493          	addi	s1,s1,-12 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000194:	00011917          	auipc	s2,0x11
    80000198:	08490913          	addi	s2,s2,132 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    8000019c:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000019e:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001a0:	4ca9                	li	s9,10
  while(n > 0){
    800001a2:	07305863          	blez	s3,80000212 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001a6:	0984a783          	lw	a5,152(s1)
    800001aa:	09c4a703          	lw	a4,156(s1)
    800001ae:	02f71463          	bne	a4,a5,800001d6 <consoleread+0x80>
      if(myproc()->killed){
    800001b2:	00002097          	auipc	ra,0x2
    800001b6:	c8e080e7          	jalr	-882(ra) # 80001e40 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	4f0080e7          	jalr	1264(ra) # 800026b2 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef700e3          	beq	a4,a5,800001b2 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001d6:	0017871b          	addiw	a4,a5,1
    800001da:	08e4ac23          	sw	a4,152(s1)
    800001de:	07f7f713          	andi	a4,a5,127
    800001e2:	9726                	add	a4,a4,s1
    800001e4:	01874703          	lbu	a4,24(a4)
    800001e8:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001ec:	077d0563          	beq	s10,s7,80000256 <consoleread+0x100>
    cbuf = c;
    800001f0:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f4:	4685                	li	a3,1
    800001f6:	f9f40613          	addi	a2,s0,-97
    800001fa:	85d2                	mv	a1,s4
    800001fc:	8556                	mv	a0,s5
    800001fe:	00003097          	auipc	ra,0x3
    80000202:	872080e7          	jalr	-1934(ra) # 80002a70 <either_copyout>
    80000206:	01850663          	beq	a0,s8,80000212 <consoleread+0xbc>
    dst++;
    8000020a:	0a05                	addi	s4,s4,1
    --n;
    8000020c:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000020e:	f99d1ae3          	bne	s10,s9,800001a2 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000212:	00011517          	auipc	a0,0x11
    80000216:	f6e50513          	addi	a0,a0,-146 # 80011180 <cons>
    8000021a:	00001097          	auipc	ra,0x1
    8000021e:	a7c080e7          	jalr	-1412(ra) # 80000c96 <release>

  return target - n;
    80000222:	413b053b          	subw	a0,s6,s3
    80000226:	a811                	j	8000023a <consoleread+0xe4>
        release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	f5850513          	addi	a0,a0,-168 # 80011180 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a66080e7          	jalr	-1434(ra) # 80000c96 <release>
        return -1;
    80000238:	557d                	li	a0,-1
}
    8000023a:	70a6                	ld	ra,104(sp)
    8000023c:	7406                	ld	s0,96(sp)
    8000023e:	64e6                	ld	s1,88(sp)
    80000240:	6946                	ld	s2,80(sp)
    80000242:	69a6                	ld	s3,72(sp)
    80000244:	6a06                	ld	s4,64(sp)
    80000246:	7ae2                	ld	s5,56(sp)
    80000248:	7b42                	ld	s6,48(sp)
    8000024a:	7ba2                	ld	s7,40(sp)
    8000024c:	7c02                	ld	s8,32(sp)
    8000024e:	6ce2                	ld	s9,24(sp)
    80000250:	6d42                	ld	s10,16(sp)
    80000252:	6165                	addi	sp,sp,112
    80000254:	8082                	ret
      if(n < target){
    80000256:	0009871b          	sext.w	a4,s3
    8000025a:	fb677ce3          	bgeu	a4,s6,80000212 <consoleread+0xbc>
        cons.r--;
    8000025e:	00011717          	auipc	a4,0x11
    80000262:	faf72d23          	sw	a5,-70(a4) # 80011218 <cons+0x98>
    80000266:	b775                	j	80000212 <consoleread+0xbc>

0000000080000268 <consputc>:
{
    80000268:	1141                	addi	sp,sp,-16
    8000026a:	e406                	sd	ra,8(sp)
    8000026c:	e022                	sd	s0,0(sp)
    8000026e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000270:	10000793          	li	a5,256
    80000274:	00f50a63          	beq	a0,a5,80000288 <consputc+0x20>
    uartputc_sync(c);
    80000278:	00000097          	auipc	ra,0x0
    8000027c:	55e080e7          	jalr	1374(ra) # 800007d6 <uartputc_sync>
}
    80000280:	60a2                	ld	ra,8(sp)
    80000282:	6402                	ld	s0,0(sp)
    80000284:	0141                	addi	sp,sp,16
    80000286:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000288:	4521                	li	a0,8
    8000028a:	00000097          	auipc	ra,0x0
    8000028e:	54c080e7          	jalr	1356(ra) # 800007d6 <uartputc_sync>
    80000292:	02000513          	li	a0,32
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	540080e7          	jalr	1344(ra) # 800007d6 <uartputc_sync>
    8000029e:	4521                	li	a0,8
    800002a0:	00000097          	auipc	ra,0x0
    800002a4:	536080e7          	jalr	1334(ra) # 800007d6 <uartputc_sync>
    800002a8:	bfe1                	j	80000280 <consputc+0x18>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	e04a                	sd	s2,0(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	00011517          	auipc	a0,0x11
    800002bc:	ec850513          	addi	a0,a0,-312 # 80011180 <cons>
    800002c0:	00001097          	auipc	ra,0x1
    800002c4:	922080e7          	jalr	-1758(ra) # 80000be2 <acquire>

  switch(c){
    800002c8:	47d5                	li	a5,21
    800002ca:	0af48663          	beq	s1,a5,80000376 <consoleintr+0xcc>
    800002ce:	0297ca63          	blt	a5,s1,80000302 <consoleintr+0x58>
    800002d2:	47a1                	li	a5,8
    800002d4:	0ef48763          	beq	s1,a5,800003c2 <consoleintr+0x118>
    800002d8:	47c1                	li	a5,16
    800002da:	10f49a63          	bne	s1,a5,800003ee <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002de:	00003097          	auipc	ra,0x3
    800002e2:	83e080e7          	jalr	-1986(ra) # 80002b1c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002e6:	00011517          	auipc	a0,0x11
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80011180 <cons>
    800002ee:	00001097          	auipc	ra,0x1
    800002f2:	9a8080e7          	jalr	-1624(ra) # 80000c96 <release>
}
    800002f6:	60e2                	ld	ra,24(sp)
    800002f8:	6442                	ld	s0,16(sp)
    800002fa:	64a2                	ld	s1,8(sp)
    800002fc:	6902                	ld	s2,0(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch(c){
    80000302:	07f00793          	li	a5,127
    80000306:	0af48e63          	beq	s1,a5,800003c2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000030a:	00011717          	auipc	a4,0x11
    8000030e:	e7670713          	addi	a4,a4,-394 # 80011180 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf763e3          	bltu	a4,a5,800002e6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x14a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	00000097          	auipc	ra,0x0
    80000330:	f3c080e7          	jalr	-196(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000334:	00011797          	auipc	a5,0x11
    80000338:	e4c78793          	addi	a5,a5,-436 # 80011180 <cons>
    8000033c:	0a07a703          	lw	a4,160(a5)
    80000340:	0017069b          	addiw	a3,a4,1
    80000344:	0006861b          	sext.w	a2,a3
    80000348:	0ad7a023          	sw	a3,160(a5)
    8000034c:	07f77713          	andi	a4,a4,127
    80000350:	97ba                	add	a5,a5,a4
    80000352:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000356:	47a9                	li	a5,10
    80000358:	0cf48563          	beq	s1,a5,80000422 <consoleintr+0x178>
    8000035c:	4791                	li	a5,4
    8000035e:	0cf48263          	beq	s1,a5,80000422 <consoleintr+0x178>
    80000362:	00011797          	auipc	a5,0x11
    80000366:	eb67a783          	lw	a5,-330(a5) # 80011218 <cons+0x98>
    8000036a:	0807879b          	addiw	a5,a5,128
    8000036e:	f6f61ce3          	bne	a2,a5,800002e6 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000372:	863e                	mv	a2,a5
    80000374:	a07d                	j	80000422 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000376:	00011717          	auipc	a4,0x11
    8000037a:	e0a70713          	addi	a4,a4,-502 # 80011180 <cons>
    8000037e:	0a072783          	lw	a5,160(a4)
    80000382:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000386:	00011497          	auipc	s1,0x11
    8000038a:	dfa48493          	addi	s1,s1,-518 # 80011180 <cons>
    while(cons.e != cons.w &&
    8000038e:	4929                	li	s2,10
    80000390:	f4f70be3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	37fd                	addiw	a5,a5,-1
    80000396:	07f7f713          	andi	a4,a5,127
    8000039a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000039c:	01874703          	lbu	a4,24(a4)
    800003a0:	f52703e3          	beq	a4,s2,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003a4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a8:	10000513          	li	a0,256
    800003ac:	00000097          	auipc	ra,0x0
    800003b0:	ebc080e7          	jalr	-324(ra) # 80000268 <consputc>
    while(cons.e != cons.w &&
    800003b4:	0a04a783          	lw	a5,160(s1)
    800003b8:	09c4a703          	lw	a4,156(s1)
    800003bc:	fcf71ce3          	bne	a4,a5,80000394 <consoleintr+0xea>
    800003c0:	b71d                	j	800002e6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003c2:	00011717          	auipc	a4,0x11
    800003c6:	dbe70713          	addi	a4,a4,-578 # 80011180 <cons>
    800003ca:	0a072783          	lw	a5,160(a4)
    800003ce:	09c72703          	lw	a4,156(a4)
    800003d2:	f0f70ae3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003d6:	37fd                	addiw	a5,a5,-1
    800003d8:	00011717          	auipc	a4,0x11
    800003dc:	e4f72423          	sw	a5,-440(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003e0:	10000513          	li	a0,256
    800003e4:	00000097          	auipc	ra,0x0
    800003e8:	e84080e7          	jalr	-380(ra) # 80000268 <consputc>
    800003ec:	bded                	j	800002e6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003ee:	ee048ce3          	beqz	s1,800002e6 <consoleintr+0x3c>
    800003f2:	bf21                	j	8000030a <consoleintr+0x60>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	00000097          	auipc	ra,0x0
    800003fa:	e72080e7          	jalr	-398(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003fe:	00011797          	auipc	a5,0x11
    80000402:	d8278793          	addi	a5,a5,-638 # 80011180 <cons>
    80000406:	0a07a703          	lw	a4,160(a5)
    8000040a:	0017069b          	addiw	a3,a4,1
    8000040e:	0006861b          	sext.w	a2,a3
    80000412:	0ad7a023          	sw	a3,160(a5)
    80000416:	07f77713          	andi	a4,a4,127
    8000041a:	97ba                	add	a5,a5,a4
    8000041c:	4729                	li	a4,10
    8000041e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000422:	00011797          	auipc	a5,0x11
    80000426:	dec7ad23          	sw	a2,-518(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000042a:	00011517          	auipc	a0,0x11
    8000042e:	dee50513          	addi	a0,a0,-530 # 80011218 <cons+0x98>
    80000432:	00002097          	auipc	ra,0x2
    80000436:	40c080e7          	jalr	1036(ra) # 8000283e <wakeup>
    8000043a:	b575                	j	800002e6 <consoleintr+0x3c>

000000008000043c <consoleinit>:

void
consoleinit(void)
{
    8000043c:	1141                	addi	sp,sp,-16
    8000043e:	e406                	sd	ra,8(sp)
    80000440:	e022                	sd	s0,0(sp)
    80000442:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000444:	00008597          	auipc	a1,0x8
    80000448:	bcc58593          	addi	a1,a1,-1076 # 80008010 <etext+0x10>
    8000044c:	00011517          	auipc	a0,0x11
    80000450:	d3450513          	addi	a0,a0,-716 # 80011180 <cons>
    80000454:	00000097          	auipc	ra,0x0
    80000458:	6fe080e7          	jalr	1790(ra) # 80000b52 <initlock>

  uartinit();
    8000045c:	00000097          	auipc	ra,0x0
    80000460:	32a080e7          	jalr	810(ra) # 80000786 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000464:	00029797          	auipc	a5,0x29
    80000468:	4b478793          	addi	a5,a5,1204 # 80029918 <devsw>
    8000046c:	00000717          	auipc	a4,0x0
    80000470:	cea70713          	addi	a4,a4,-790 # 80000156 <consoleread>
    80000474:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000476:	00000717          	auipc	a4,0x0
    8000047a:	c7e70713          	addi	a4,a4,-898 # 800000f4 <consolewrite>
    8000047e:	ef98                	sd	a4,24(a5)
}
    80000480:	60a2                	ld	ra,8(sp)
    80000482:	6402                	ld	s0,0(sp)
    80000484:	0141                	addi	sp,sp,16
    80000486:	8082                	ret

0000000080000488 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000488:	7179                	addi	sp,sp,-48
    8000048a:	f406                	sd	ra,40(sp)
    8000048c:	f022                	sd	s0,32(sp)
    8000048e:	ec26                	sd	s1,24(sp)
    80000490:	e84a                	sd	s2,16(sp)
    80000492:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80000494:	c219                	beqz	a2,8000049a <printint+0x12>
    80000496:	08054663          	bltz	a0,80000522 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    8000049a:	2501                	sext.w	a0,a0
    8000049c:	4881                	li	a7,0
    8000049e:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004a2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004a4:	2581                	sext.w	a1,a1
    800004a6:	00008617          	auipc	a2,0x8
    800004aa:	b9a60613          	addi	a2,a2,-1126 # 80008040 <digits>
    800004ae:	883a                	mv	a6,a4
    800004b0:	2705                	addiw	a4,a4,1
    800004b2:	02b577bb          	remuw	a5,a0,a1
    800004b6:	1782                	slli	a5,a5,0x20
    800004b8:	9381                	srli	a5,a5,0x20
    800004ba:	97b2                	add	a5,a5,a2
    800004bc:	0007c783          	lbu	a5,0(a5)
    800004c0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004c4:	0005079b          	sext.w	a5,a0
    800004c8:	02b5553b          	divuw	a0,a0,a1
    800004cc:	0685                	addi	a3,a3,1
    800004ce:	feb7f0e3          	bgeu	a5,a1,800004ae <printint+0x26>

  if(sign)
    800004d2:	00088b63          	beqz	a7,800004e8 <printint+0x60>
    buf[i++] = '-';
    800004d6:	fe040793          	addi	a5,s0,-32
    800004da:	973e                	add	a4,a4,a5
    800004dc:	02d00793          	li	a5,45
    800004e0:	fef70823          	sb	a5,-16(a4)
    800004e4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004e8:	02e05763          	blez	a4,80000516 <printint+0x8e>
    800004ec:	fd040793          	addi	a5,s0,-48
    800004f0:	00e784b3          	add	s1,a5,a4
    800004f4:	fff78913          	addi	s2,a5,-1
    800004f8:	993a                	add	s2,s2,a4
    800004fa:	377d                	addiw	a4,a4,-1
    800004fc:	1702                	slli	a4,a4,0x20
    800004fe:	9301                	srli	a4,a4,0x20
    80000500:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000504:	fff4c503          	lbu	a0,-1(s1)
    80000508:	00000097          	auipc	ra,0x0
    8000050c:	d60080e7          	jalr	-672(ra) # 80000268 <consputc>
  while(--i >= 0)
    80000510:	14fd                	addi	s1,s1,-1
    80000512:	ff2499e3          	bne	s1,s2,80000504 <printint+0x7c>
}
    80000516:	70a2                	ld	ra,40(sp)
    80000518:	7402                	ld	s0,32(sp)
    8000051a:	64e2                	ld	s1,24(sp)
    8000051c:	6942                	ld	s2,16(sp)
    8000051e:	6145                	addi	sp,sp,48
    80000520:	8082                	ret
    x = -xx;
    80000522:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000526:	4885                	li	a7,1
    x = -xx;
    80000528:	bf9d                	j	8000049e <printint+0x16>

000000008000052a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000052a:	1101                	addi	sp,sp,-32
    8000052c:	ec06                	sd	ra,24(sp)
    8000052e:	e822                	sd	s0,16(sp)
    80000530:	e426                	sd	s1,8(sp)
    80000532:	1000                	addi	s0,sp,32
    80000534:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000536:	00011797          	auipc	a5,0x11
    8000053a:	d007a523          	sw	zero,-758(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    8000053e:	00008517          	auipc	a0,0x8
    80000542:	ada50513          	addi	a0,a0,-1318 # 80008018 <etext+0x18>
    80000546:	00000097          	auipc	ra,0x0
    8000054a:	02e080e7          	jalr	46(ra) # 80000574 <printf>
  printf(s);
    8000054e:	8526                	mv	a0,s1
    80000550:	00000097          	auipc	ra,0x0
    80000554:	024080e7          	jalr	36(ra) # 80000574 <printf>
  printf("\n");
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	b8050513          	addi	a0,a0,-1152 # 800080d8 <digits+0x98>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	014080e7          	jalr	20(ra) # 80000574 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000568:	4785                	li	a5,1
    8000056a:	00009717          	auipc	a4,0x9
    8000056e:	a8f72b23          	sw	a5,-1386(a4) # 80009000 <panicked>
  for(;;)
    80000572:	a001                	j	80000572 <panic+0x48>

0000000080000574 <printf>:
{
    80000574:	7131                	addi	sp,sp,-192
    80000576:	fc86                	sd	ra,120(sp)
    80000578:	f8a2                	sd	s0,112(sp)
    8000057a:	f4a6                	sd	s1,104(sp)
    8000057c:	f0ca                	sd	s2,96(sp)
    8000057e:	ecce                	sd	s3,88(sp)
    80000580:	e8d2                	sd	s4,80(sp)
    80000582:	e4d6                	sd	s5,72(sp)
    80000584:	e0da                	sd	s6,64(sp)
    80000586:	fc5e                	sd	s7,56(sp)
    80000588:	f862                	sd	s8,48(sp)
    8000058a:	f466                	sd	s9,40(sp)
    8000058c:	f06a                	sd	s10,32(sp)
    8000058e:	ec6e                	sd	s11,24(sp)
    80000590:	0100                	addi	s0,sp,128
    80000592:	8a2a                	mv	s4,a0
    80000594:	e40c                	sd	a1,8(s0)
    80000596:	e810                	sd	a2,16(s0)
    80000598:	ec14                	sd	a3,24(s0)
    8000059a:	f018                	sd	a4,32(s0)
    8000059c:	f41c                	sd	a5,40(s0)
    8000059e:	03043823          	sd	a6,48(s0)
    800005a2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005a6:	00011d97          	auipc	s11,0x11
    800005aa:	c9adad83          	lw	s11,-870(s11) # 80011240 <pr+0x18>
  if(locking)
    800005ae:	020d9b63          	bnez	s11,800005e4 <printf+0x70>
  if (fmt == 0)
    800005b2:	040a0263          	beqz	s4,800005f6 <printf+0x82>
  va_start(ap, fmt);
    800005b6:	00840793          	addi	a5,s0,8
    800005ba:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005be:	000a4503          	lbu	a0,0(s4)
    800005c2:	14050f63          	beqz	a0,80000720 <printf+0x1ac>
    800005c6:	4981                	li	s3,0
    if(c != '%'){
    800005c8:	02500a93          	li	s5,37
    switch(c){
    800005cc:	07000b93          	li	s7,112
  consputc('x');
    800005d0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005d2:	00008b17          	auipc	s6,0x8
    800005d6:	a6eb0b13          	addi	s6,s6,-1426 # 80008040 <digits>
    switch(c){
    800005da:	07300c93          	li	s9,115
    800005de:	06400c13          	li	s8,100
    800005e2:	a82d                	j	8000061c <printf+0xa8>
    acquire(&pr.lock);
    800005e4:	00011517          	auipc	a0,0x11
    800005e8:	c4450513          	addi	a0,a0,-956 # 80011228 <pr>
    800005ec:	00000097          	auipc	ra,0x0
    800005f0:	5f6080e7          	jalr	1526(ra) # 80000be2 <acquire>
    800005f4:	bf7d                	j	800005b2 <printf+0x3e>
    panic("null fmt");
    800005f6:	00008517          	auipc	a0,0x8
    800005fa:	a3250513          	addi	a0,a0,-1486 # 80008028 <etext+0x28>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	f2c080e7          	jalr	-212(ra) # 8000052a <panic>
      consputc(c);
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	c62080e7          	jalr	-926(ra) # 80000268 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000060e:	2985                	addiw	s3,s3,1
    80000610:	013a07b3          	add	a5,s4,s3
    80000614:	0007c503          	lbu	a0,0(a5)
    80000618:	10050463          	beqz	a0,80000720 <printf+0x1ac>
    if(c != '%'){
    8000061c:	ff5515e3          	bne	a0,s5,80000606 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c783          	lbu	a5,0(a5)
    8000062a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000062e:	cbed                	beqz	a5,80000720 <printf+0x1ac>
    switch(c){
    80000630:	05778a63          	beq	a5,s7,80000684 <printf+0x110>
    80000634:	02fbf663          	bgeu	s7,a5,80000660 <printf+0xec>
    80000638:	09978863          	beq	a5,s9,800006c8 <printf+0x154>
    8000063c:	07800713          	li	a4,120
    80000640:	0ce79563          	bne	a5,a4,8000070a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	85ea                	mv	a1,s10
    80000654:	4388                	lw	a0,0(a5)
    80000656:	00000097          	auipc	ra,0x0
    8000065a:	e32080e7          	jalr	-462(ra) # 80000488 <printint>
      break;
    8000065e:	bf45                	j	8000060e <printf+0x9a>
    switch(c){
    80000660:	09578f63          	beq	a5,s5,800006fe <printf+0x18a>
    80000664:	0b879363          	bne	a5,s8,8000070a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000668:	f8843783          	ld	a5,-120(s0)
    8000066c:	00878713          	addi	a4,a5,8
    80000670:	f8e43423          	sd	a4,-120(s0)
    80000674:	4605                	li	a2,1
    80000676:	45a9                	li	a1,10
    80000678:	4388                	lw	a0,0(a5)
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	e0e080e7          	jalr	-498(ra) # 80000488 <printint>
      break;
    80000682:	b771                	j	8000060e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80000694:	03000513          	li	a0,48
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	bd0080e7          	jalr	-1072(ra) # 80000268 <consputc>
  consputc('x');
    800006a0:	07800513          	li	a0,120
    800006a4:	00000097          	auipc	ra,0x0
    800006a8:	bc4080e7          	jalr	-1084(ra) # 80000268 <consputc>
    800006ac:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ae:	03c95793          	srli	a5,s2,0x3c
    800006b2:	97da                	add	a5,a5,s6
    800006b4:	0007c503          	lbu	a0,0(a5)
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bb0080e7          	jalr	-1104(ra) # 80000268 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006c0:	0912                	slli	s2,s2,0x4
    800006c2:	34fd                	addiw	s1,s1,-1
    800006c4:	f4ed                	bnez	s1,800006ae <printf+0x13a>
    800006c6:	b7a1                	j	8000060e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	addi	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	6384                	ld	s1,0(a5)
    800006d6:	cc89                	beqz	s1,800006f0 <printf+0x17c>
      for(; *s; s++)
    800006d8:	0004c503          	lbu	a0,0(s1)
    800006dc:	d90d                	beqz	a0,8000060e <printf+0x9a>
        consputc(*s);
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	b8a080e7          	jalr	-1142(ra) # 80000268 <consputc>
      for(; *s; s++)
    800006e6:	0485                	addi	s1,s1,1
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	f96d                	bnez	a0,800006de <printf+0x16a>
    800006ee:	b705                	j	8000060e <printf+0x9a>
        s = "(null)";
    800006f0:	00008497          	auipc	s1,0x8
    800006f4:	93048493          	addi	s1,s1,-1744 # 80008020 <etext+0x20>
      for(; *s; s++)
    800006f8:	02800513          	li	a0,40
    800006fc:	b7cd                	j	800006de <printf+0x16a>
      consputc('%');
    800006fe:	8556                	mv	a0,s5
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b68080e7          	jalr	-1176(ra) # 80000268 <consputc>
      break;
    80000708:	b719                	j	8000060e <printf+0x9a>
      consputc('%');
    8000070a:	8556                	mv	a0,s5
    8000070c:	00000097          	auipc	ra,0x0
    80000710:	b5c080e7          	jalr	-1188(ra) # 80000268 <consputc>
      consputc(c);
    80000714:	8526                	mv	a0,s1
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b52080e7          	jalr	-1198(ra) # 80000268 <consputc>
      break;
    8000071e:	bdc5                	j	8000060e <printf+0x9a>
  if(locking)
    80000720:	020d9163          	bnez	s11,80000742 <printf+0x1ce>
}
    80000724:	70e6                	ld	ra,120(sp)
    80000726:	7446                	ld	s0,112(sp)
    80000728:	74a6                	ld	s1,104(sp)
    8000072a:	7906                	ld	s2,96(sp)
    8000072c:	69e6                	ld	s3,88(sp)
    8000072e:	6a46                	ld	s4,80(sp)
    80000730:	6aa6                	ld	s5,72(sp)
    80000732:	6b06                	ld	s6,64(sp)
    80000734:	7be2                	ld	s7,56(sp)
    80000736:	7c42                	ld	s8,48(sp)
    80000738:	7ca2                	ld	s9,40(sp)
    8000073a:	7d02                	ld	s10,32(sp)
    8000073c:	6de2                	ld	s11,24(sp)
    8000073e:	6129                	addi	sp,sp,192
    80000740:	8082                	ret
    release(&pr.lock);
    80000742:	00011517          	auipc	a0,0x11
    80000746:	ae650513          	addi	a0,a0,-1306 # 80011228 <pr>
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	54c080e7          	jalr	1356(ra) # 80000c96 <release>
}
    80000752:	bfc9                	j	80000724 <printf+0x1b0>

0000000080000754 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000754:	1101                	addi	sp,sp,-32
    80000756:	ec06                	sd	ra,24(sp)
    80000758:	e822                	sd	s0,16(sp)
    8000075a:	e426                	sd	s1,8(sp)
    8000075c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000075e:	00011497          	auipc	s1,0x11
    80000762:	aca48493          	addi	s1,s1,-1334 # 80011228 <pr>
    80000766:	00008597          	auipc	a1,0x8
    8000076a:	8d258593          	addi	a1,a1,-1838 # 80008038 <etext+0x38>
    8000076e:	8526                	mv	a0,s1
    80000770:	00000097          	auipc	ra,0x0
    80000774:	3e2080e7          	jalr	994(ra) # 80000b52 <initlock>
  pr.locking = 1;
    80000778:	4785                	li	a5,1
    8000077a:	cc9c                	sw	a5,24(s1)
}
    8000077c:	60e2                	ld	ra,24(sp)
    8000077e:	6442                	ld	s0,16(sp)
    80000780:	64a2                	ld	s1,8(sp)
    80000782:	6105                	addi	sp,sp,32
    80000784:	8082                	ret

0000000080000786 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000786:	1141                	addi	sp,sp,-16
    80000788:	e406                	sd	ra,8(sp)
    8000078a:	e022                	sd	s0,0(sp)
    8000078c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000078e:	100007b7          	lui	a5,0x10000
    80000792:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000796:	f8000713          	li	a4,-128
    8000079a:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000079e:	470d                	li	a4,3
    800007a0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007a4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007a8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ac:	469d                	li	a3,7
    800007ae:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007b2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007b6:	00008597          	auipc	a1,0x8
    800007ba:	8a258593          	addi	a1,a1,-1886 # 80008058 <digits+0x18>
    800007be:	00011517          	auipc	a0,0x11
    800007c2:	a8a50513          	addi	a0,a0,-1398 # 80011248 <uart_tx_lock>
    800007c6:	00000097          	auipc	ra,0x0
    800007ca:	38c080e7          	jalr	908(ra) # 80000b52 <initlock>
}
    800007ce:	60a2                	ld	ra,8(sp)
    800007d0:	6402                	ld	s0,0(sp)
    800007d2:	0141                	addi	sp,sp,16
    800007d4:	8082                	ret

00000000800007d6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007d6:	1101                	addi	sp,sp,-32
    800007d8:	ec06                	sd	ra,24(sp)
    800007da:	e822                	sd	s0,16(sp)
    800007dc:	e426                	sd	s1,8(sp)
    800007de:	1000                	addi	s0,sp,32
    800007e0:	84aa                	mv	s1,a0
  push_off();
    800007e2:	00000097          	auipc	ra,0x0
    800007e6:	3b4080e7          	jalr	948(ra) # 80000b96 <push_off>

  if(panicked){
    800007ea:	00009797          	auipc	a5,0x9
    800007ee:	8167a783          	lw	a5,-2026(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800007f6:	c391                	beqz	a5,800007fa <uartputc_sync+0x24>
    for(;;)
    800007f8:	a001                	j	800007f8 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007fa:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007fe:	0207f793          	andi	a5,a5,32
    80000802:	dfe5                	beqz	a5,800007fa <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000804:	0ff4f513          	andi	a0,s1,255
    80000808:	100007b7          	lui	a5,0x10000
    8000080c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000810:	00000097          	auipc	ra,0x0
    80000814:	426080e7          	jalr	1062(ra) # 80000c36 <pop_off>
}
    80000818:	60e2                	ld	ra,24(sp)
    8000081a:	6442                	ld	s0,16(sp)
    8000081c:	64a2                	ld	s1,8(sp)
    8000081e:	6105                	addi	sp,sp,32
    80000820:	8082                	ret

0000000080000822 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000822:	00008797          	auipc	a5,0x8
    80000826:	7e67b783          	ld	a5,2022(a5) # 80009008 <uart_tx_r>
    8000082a:	00008717          	auipc	a4,0x8
    8000082e:	7e673703          	ld	a4,2022(a4) # 80009010 <uart_tx_w>
    80000832:	06f70a63          	beq	a4,a5,800008a6 <uartstart+0x84>
{
    80000836:	7139                	addi	sp,sp,-64
    80000838:	fc06                	sd	ra,56(sp)
    8000083a:	f822                	sd	s0,48(sp)
    8000083c:	f426                	sd	s1,40(sp)
    8000083e:	f04a                	sd	s2,32(sp)
    80000840:	ec4e                	sd	s3,24(sp)
    80000842:	e852                	sd	s4,16(sp)
    80000844:	e456                	sd	s5,8(sp)
    80000846:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000848:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000084c:	00011a17          	auipc	s4,0x11
    80000850:	9fca0a13          	addi	s4,s4,-1540 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000854:	00008497          	auipc	s1,0x8
    80000858:	7b448493          	addi	s1,s1,1972 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000085c:	00008997          	auipc	s3,0x8
    80000860:	7b498993          	addi	s3,s3,1972 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000864:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000868:	02077713          	andi	a4,a4,32
    8000086c:	c705                	beqz	a4,80000894 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086e:	01f7f713          	andi	a4,a5,31
    80000872:	9752                	add	a4,a4,s4
    80000874:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000878:	0785                	addi	a5,a5,1
    8000087a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000087c:	8526                	mv	a0,s1
    8000087e:	00002097          	auipc	ra,0x2
    80000882:	fc0080e7          	jalr	-64(ra) # 8000283e <wakeup>
    
    WriteReg(THR, c);
    80000886:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000088a:	609c                	ld	a5,0(s1)
    8000088c:	0009b703          	ld	a4,0(s3)
    80000890:	fcf71ae3          	bne	a4,a5,80000864 <uartstart+0x42>
  }
}
    80000894:	70e2                	ld	ra,56(sp)
    80000896:	7442                	ld	s0,48(sp)
    80000898:	74a2                	ld	s1,40(sp)
    8000089a:	7902                	ld	s2,32(sp)
    8000089c:	69e2                	ld	s3,24(sp)
    8000089e:	6a42                	ld	s4,16(sp)
    800008a0:	6aa2                	ld	s5,8(sp)
    800008a2:	6121                	addi	sp,sp,64
    800008a4:	8082                	ret
    800008a6:	8082                	ret

00000000800008a8 <uartputc>:
{
    800008a8:	7179                	addi	sp,sp,-48
    800008aa:	f406                	sd	ra,40(sp)
    800008ac:	f022                	sd	s0,32(sp)
    800008ae:	ec26                	sd	s1,24(sp)
    800008b0:	e84a                	sd	s2,16(sp)
    800008b2:	e44e                	sd	s3,8(sp)
    800008b4:	e052                	sd	s4,0(sp)
    800008b6:	1800                	addi	s0,sp,48
    800008b8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ba:	00011517          	auipc	a0,0x11
    800008be:	98e50513          	addi	a0,a0,-1650 # 80011248 <uart_tx_lock>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	320080e7          	jalr	800(ra) # 80000be2 <acquire>
  if(panicked){
    800008ca:	00008797          	auipc	a5,0x8
    800008ce:	7367a783          	lw	a5,1846(a5) # 80009000 <panicked>
    800008d2:	c391                	beqz	a5,800008d6 <uartputc+0x2e>
    for(;;)
    800008d4:	a001                	j	800008d4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008d6:	00008717          	auipc	a4,0x8
    800008da:	73a73703          	ld	a4,1850(a4) # 80009010 <uart_tx_w>
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	72a7b783          	ld	a5,1834(a5) # 80009008 <uart_tx_r>
    800008e6:	02078793          	addi	a5,a5,32
    800008ea:	02e79b63          	bne	a5,a4,80000920 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008ee:	00011997          	auipc	s3,0x11
    800008f2:	95a98993          	addi	s3,s3,-1702 # 80011248 <uart_tx_lock>
    800008f6:	00008497          	auipc	s1,0x8
    800008fa:	71248493          	addi	s1,s1,1810 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fe:	00008917          	auipc	s2,0x8
    80000902:	71290913          	addi	s2,s2,1810 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000906:	85ce                	mv	a1,s3
    80000908:	8526                	mv	a0,s1
    8000090a:	00002097          	auipc	ra,0x2
    8000090e:	da8080e7          	jalr	-600(ra) # 800026b2 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00093703          	ld	a4,0(s2)
    80000916:	609c                	ld	a5,0(s1)
    80000918:	02078793          	addi	a5,a5,32
    8000091c:	fee785e3          	beq	a5,a4,80000906 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000920:	00011497          	auipc	s1,0x11
    80000924:	92848493          	addi	s1,s1,-1752 # 80011248 <uart_tx_lock>
    80000928:	01f77793          	andi	a5,a4,31
    8000092c:	97a6                	add	a5,a5,s1
    8000092e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000932:	0705                	addi	a4,a4,1
    80000934:	00008797          	auipc	a5,0x8
    80000938:	6ce7be23          	sd	a4,1756(a5) # 80009010 <uart_tx_w>
      uartstart();
    8000093c:	00000097          	auipc	ra,0x0
    80000940:	ee6080e7          	jalr	-282(ra) # 80000822 <uartstart>
      release(&uart_tx_lock);
    80000944:	8526                	mv	a0,s1
    80000946:	00000097          	auipc	ra,0x0
    8000094a:	350080e7          	jalr	848(ra) # 80000c96 <release>
}
    8000094e:	70a2                	ld	ra,40(sp)
    80000950:	7402                	ld	s0,32(sp)
    80000952:	64e2                	ld	s1,24(sp)
    80000954:	6942                	ld	s2,16(sp)
    80000956:	69a2                	ld	s3,8(sp)
    80000958:	6a02                	ld	s4,0(sp)
    8000095a:	6145                	addi	sp,sp,48
    8000095c:	8082                	ret

000000008000095e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000095e:	1141                	addi	sp,sp,-16
    80000960:	e422                	sd	s0,8(sp)
    80000962:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000964:	100007b7          	lui	a5,0x10000
    80000968:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000096c:	8b85                	andi	a5,a5,1
    8000096e:	cb91                	beqz	a5,80000982 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000970:	100007b7          	lui	a5,0x10000
    80000974:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000978:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000097c:	6422                	ld	s0,8(sp)
    8000097e:	0141                	addi	sp,sp,16
    80000980:	8082                	ret
    return -1;
    80000982:	557d                	li	a0,-1
    80000984:	bfe5                	j	8000097c <uartgetc+0x1e>

0000000080000986 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000986:	1101                	addi	sp,sp,-32
    80000988:	ec06                	sd	ra,24(sp)
    8000098a:	e822                	sd	s0,16(sp)
    8000098c:	e426                	sd	s1,8(sp)
    8000098e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000990:	54fd                	li	s1,-1
    80000992:	a029                	j	8000099c <uartintr+0x16>
      break;
    consoleintr(c);
    80000994:	00000097          	auipc	ra,0x0
    80000998:	916080e7          	jalr	-1770(ra) # 800002aa <consoleintr>
    int c = uartgetc();
    8000099c:	00000097          	auipc	ra,0x0
    800009a0:	fc2080e7          	jalr	-62(ra) # 8000095e <uartgetc>
    if(c == -1)
    800009a4:	fe9518e3          	bne	a0,s1,80000994 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009a8:	00011497          	auipc	s1,0x11
    800009ac:	8a048493          	addi	s1,s1,-1888 # 80011248 <uart_tx_lock>
    800009b0:	8526                	mv	a0,s1
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	230080e7          	jalr	560(ra) # 80000be2 <acquire>
  uartstart();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	e68080e7          	jalr	-408(ra) # 80000822 <uartstart>
  release(&uart_tx_lock);
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	2d2080e7          	jalr	722(ra) # 80000c96 <release>
}
    800009cc:	60e2                	ld	ra,24(sp)
    800009ce:	6442                	ld	s0,16(sp)
    800009d0:	64a2                	ld	s1,8(sp)
    800009d2:	6105                	addi	sp,sp,32
    800009d4:	8082                	ret

00000000800009d6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	e04a                	sd	s2,0(sp)
    800009e0:	1000                	addi	s0,sp,32


  struct run *r;

  if( ((uint64)pa % PGSIZE) != 0 ) 
    800009e2:	03451793          	slli	a5,a0,0x34
    800009e6:	ebb9                	bnez	a5,80000a3c <kfree+0x66>
    800009e8:	84aa                	mv	s1,a0
    panic("kfree1");

  if( ( (char*)pa ) < end)
    800009ea:	0002d797          	auipc	a5,0x2d
    800009ee:	61678793          	addi	a5,a5,1558 # 8002e000 <end>
    800009f2:	04f56d63          	bltu	a0,a5,80000a4c <kfree+0x76>
    panic("kfree2");

  if( ( (uint64) pa) >= PHYSTOP)
    800009f6:	47c5                	li	a5,17
    800009f8:	07ee                	slli	a5,a5,0x1b
    800009fa:	06f57163          	bgeu	a0,a5,80000a5c <kfree+0x86>

  // if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
  //   panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009fe:	6605                	lui	a2,0x1
    80000a00:	4585                	li	a1,1
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	2dc080e7          	jalr	732(ra) # 80000cde <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0a:	00011917          	auipc	s2,0x11
    80000a0e:	87690913          	addi	s2,s2,-1930 # 80011280 <kmem>
    80000a12:	854a                	mv	a0,s2
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	1ce080e7          	jalr	462(ra) # 80000be2 <acquire>
  r->next = kmem.freelist;
    80000a1c:	01893783          	ld	a5,24(s2)
    80000a20:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a22:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	26e080e7          	jalr	622(ra) # 80000c96 <release>
}
    80000a30:	60e2                	ld	ra,24(sp)
    80000a32:	6442                	ld	s0,16(sp)
    80000a34:	64a2                	ld	s1,8(sp)
    80000a36:	6902                	ld	s2,0(sp)
    80000a38:	6105                	addi	sp,sp,32
    80000a3a:	8082                	ret
    panic("kfree1");
    80000a3c:	00007517          	auipc	a0,0x7
    80000a40:	62450513          	addi	a0,a0,1572 # 80008060 <digits+0x20>
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	ae6080e7          	jalr	-1306(ra) # 8000052a <panic>
    panic("kfree2");
    80000a4c:	00007517          	auipc	a0,0x7
    80000a50:	61c50513          	addi	a0,a0,1564 # 80008068 <digits+0x28>
    80000a54:	00000097          	auipc	ra,0x0
    80000a58:	ad6080e7          	jalr	-1322(ra) # 8000052a <panic>
    panic("kfree3");
    80000a5c:	00007517          	auipc	a0,0x7
    80000a60:	61450513          	addi	a0,a0,1556 # 80008070 <digits+0x30>
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	ac6080e7          	jalr	-1338(ra) # 8000052a <panic>

0000000080000a6c <freerange>:
{
    80000a6c:	7179                	addi	sp,sp,-48
    80000a6e:	f406                	sd	ra,40(sp)
    80000a70:	f022                	sd	s0,32(sp)
    80000a72:	ec26                	sd	s1,24(sp)
    80000a74:	e84a                	sd	s2,16(sp)
    80000a76:	e44e                	sd	s3,8(sp)
    80000a78:	e052                	sd	s4,0(sp)
    80000a7a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a7c:	6785                	lui	a5,0x1
    80000a7e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a82:	94aa                	add	s1,s1,a0
    80000a84:	757d                	lui	a0,0xfffff
    80000a86:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a88:	94be                	add	s1,s1,a5
    80000a8a:	0095ee63          	bltu	a1,s1,80000aa6 <freerange+0x3a>
    80000a8e:	892e                	mv	s2,a1
    kfree(p);
    80000a90:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a92:	6985                	lui	s3,0x1
    kfree(p);
    80000a94:	01448533          	add	a0,s1,s4
    80000a98:	00000097          	auipc	ra,0x0
    80000a9c:	f3e080e7          	jalr	-194(ra) # 800009d6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa0:	94ce                	add	s1,s1,s3
    80000aa2:	fe9979e3          	bgeu	s2,s1,80000a94 <freerange+0x28>
}
    80000aa6:	70a2                	ld	ra,40(sp)
    80000aa8:	7402                	ld	s0,32(sp)
    80000aaa:	64e2                	ld	s1,24(sp)
    80000aac:	6942                	ld	s2,16(sp)
    80000aae:	69a2                	ld	s3,8(sp)
    80000ab0:	6a02                	ld	s4,0(sp)
    80000ab2:	6145                	addi	sp,sp,48
    80000ab4:	8082                	ret

0000000080000ab6 <kinit>:
{
    80000ab6:	1141                	addi	sp,sp,-16
    80000ab8:	e406                	sd	ra,8(sp)
    80000aba:	e022                	sd	s0,0(sp)
    80000abc:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000abe:	00007597          	auipc	a1,0x7
    80000ac2:	5ba58593          	addi	a1,a1,1466 # 80008078 <digits+0x38>
    80000ac6:	00010517          	auipc	a0,0x10
    80000aca:	7ba50513          	addi	a0,a0,1978 # 80011280 <kmem>
    80000ace:	00000097          	auipc	ra,0x0
    80000ad2:	084080e7          	jalr	132(ra) # 80000b52 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ad6:	45c5                	li	a1,17
    80000ad8:	05ee                	slli	a1,a1,0x1b
    80000ada:	0002d517          	auipc	a0,0x2d
    80000ade:	52650513          	addi	a0,a0,1318 # 8002e000 <end>
    80000ae2:	00000097          	auipc	ra,0x0
    80000ae6:	f8a080e7          	jalr	-118(ra) # 80000a6c <freerange>
}
    80000aea:	60a2                	ld	ra,8(sp)
    80000aec:	6402                	ld	s0,0(sp)
    80000aee:	0141                	addi	sp,sp,16
    80000af0:	8082                	ret

0000000080000af2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000af2:	1101                	addi	sp,sp,-32
    80000af4:	ec06                	sd	ra,24(sp)
    80000af6:	e822                	sd	s0,16(sp)
    80000af8:	e426                	sd	s1,8(sp)
    80000afa:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000afc:	00010497          	auipc	s1,0x10
    80000b00:	78448493          	addi	s1,s1,1924 # 80011280 <kmem>
    80000b04:	8526                	mv	a0,s1
    80000b06:	00000097          	auipc	ra,0x0
    80000b0a:	0dc080e7          	jalr	220(ra) # 80000be2 <acquire>
  r = kmem.freelist;
    80000b0e:	6c84                	ld	s1,24(s1)
  if(r)
    80000b10:	c885                	beqz	s1,80000b40 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b12:	609c                	ld	a5,0(s1)
    80000b14:	00010517          	auipc	a0,0x10
    80000b18:	76c50513          	addi	a0,a0,1900 # 80011280 <kmem>
    80000b1c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b1e:	00000097          	auipc	ra,0x0
    80000b22:	178080e7          	jalr	376(ra) # 80000c96 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b26:	6605                	lui	a2,0x1
    80000b28:	4595                	li	a1,5
    80000b2a:	8526                	mv	a0,s1
    80000b2c:	00000097          	auipc	ra,0x0
    80000b30:	1b2080e7          	jalr	434(ra) # 80000cde <memset>
  return (void*)r;
}
    80000b34:	8526                	mv	a0,s1
    80000b36:	60e2                	ld	ra,24(sp)
    80000b38:	6442                	ld	s0,16(sp)
    80000b3a:	64a2                	ld	s1,8(sp)
    80000b3c:	6105                	addi	sp,sp,32
    80000b3e:	8082                	ret
  release(&kmem.lock);
    80000b40:	00010517          	auipc	a0,0x10
    80000b44:	74050513          	addi	a0,a0,1856 # 80011280 <kmem>
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	14e080e7          	jalr	334(ra) # 80000c96 <release>
  if(r)
    80000b50:	b7d5                	j	80000b34 <kalloc+0x42>

0000000080000b52 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b52:	1141                	addi	sp,sp,-16
    80000b54:	e422                	sd	s0,8(sp)
    80000b56:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b58:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b5a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b5e:	00053823          	sd	zero,16(a0)
}
    80000b62:	6422                	ld	s0,8(sp)
    80000b64:	0141                	addi	sp,sp,16
    80000b66:	8082                	ret

0000000080000b68 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b68:	411c                	lw	a5,0(a0)
    80000b6a:	e399                	bnez	a5,80000b70 <holding+0x8>
    80000b6c:	4501                	li	a0,0
  return r;
}
    80000b6e:	8082                	ret
{
    80000b70:	1101                	addi	sp,sp,-32
    80000b72:	ec06                	sd	ra,24(sp)
    80000b74:	e822                	sd	s0,16(sp)
    80000b76:	e426                	sd	s1,8(sp)
    80000b78:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b7a:	6904                	ld	s1,16(a0)
    80000b7c:	00001097          	auipc	ra,0x1
    80000b80:	2a8080e7          	jalr	680(ra) # 80001e24 <mycpu>
    80000b84:	40a48533          	sub	a0,s1,a0
    80000b88:	00153513          	seqz	a0,a0
}
    80000b8c:	60e2                	ld	ra,24(sp)
    80000b8e:	6442                	ld	s0,16(sp)
    80000b90:	64a2                	ld	s1,8(sp)
    80000b92:	6105                	addi	sp,sp,32
    80000b94:	8082                	ret

0000000080000b96 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b96:	1101                	addi	sp,sp,-32
    80000b98:	ec06                	sd	ra,24(sp)
    80000b9a:	e822                	sd	s0,16(sp)
    80000b9c:	e426                	sd	s1,8(sp)
    80000b9e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ba0:	100024f3          	csrr	s1,sstatus
    80000ba4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ba8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000baa:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	276080e7          	jalr	630(ra) # 80001e24 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	cf89                	beqz	a5,80000bd2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bba:	00001097          	auipc	ra,0x1
    80000bbe:	26a080e7          	jalr	618(ra) # 80001e24 <mycpu>
    80000bc2:	5d3c                	lw	a5,120(a0)
    80000bc4:	2785                	addiw	a5,a5,1
    80000bc6:	dd3c                	sw	a5,120(a0)
}
    80000bc8:	60e2                	ld	ra,24(sp)
    80000bca:	6442                	ld	s0,16(sp)
    80000bcc:	64a2                	ld	s1,8(sp)
    80000bce:	6105                	addi	sp,sp,32
    80000bd0:	8082                	ret
    mycpu()->intena = old;
    80000bd2:	00001097          	auipc	ra,0x1
    80000bd6:	252080e7          	jalr	594(ra) # 80001e24 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bda:	8085                	srli	s1,s1,0x1
    80000bdc:	8885                	andi	s1,s1,1
    80000bde:	dd64                	sw	s1,124(a0)
    80000be0:	bfe9                	j	80000bba <push_off+0x24>

0000000080000be2 <acquire>:
{
    80000be2:	1101                	addi	sp,sp,-32
    80000be4:	ec06                	sd	ra,24(sp)
    80000be6:	e822                	sd	s0,16(sp)
    80000be8:	e426                	sd	s1,8(sp)
    80000bea:	1000                	addi	s0,sp,32
    80000bec:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bee:	00000097          	auipc	ra,0x0
    80000bf2:	fa8080e7          	jalr	-88(ra) # 80000b96 <push_off>
  if(holding(lk))
    80000bf6:	8526                	mv	a0,s1
    80000bf8:	00000097          	auipc	ra,0x0
    80000bfc:	f70080e7          	jalr	-144(ra) # 80000b68 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c00:	4705                	li	a4,1
  if(holding(lk))
    80000c02:	e115                	bnez	a0,80000c26 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c04:	87ba                	mv	a5,a4
    80000c06:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c0a:	2781                	sext.w	a5,a5
    80000c0c:	ffe5                	bnez	a5,80000c04 <acquire+0x22>
  __sync_synchronize();
    80000c0e:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c12:	00001097          	auipc	ra,0x1
    80000c16:	212080e7          	jalr	530(ra) # 80001e24 <mycpu>
    80000c1a:	e888                	sd	a0,16(s1)
}
    80000c1c:	60e2                	ld	ra,24(sp)
    80000c1e:	6442                	ld	s0,16(sp)
    80000c20:	64a2                	ld	s1,8(sp)
    80000c22:	6105                	addi	sp,sp,32
    80000c24:	8082                	ret
    panic("acquire");
    80000c26:	00007517          	auipc	a0,0x7
    80000c2a:	45a50513          	addi	a0,a0,1114 # 80008080 <digits+0x40>
    80000c2e:	00000097          	auipc	ra,0x0
    80000c32:	8fc080e7          	jalr	-1796(ra) # 8000052a <panic>

0000000080000c36 <pop_off>:

void
pop_off(void)
{
    80000c36:	1141                	addi	sp,sp,-16
    80000c38:	e406                	sd	ra,8(sp)
    80000c3a:	e022                	sd	s0,0(sp)
    80000c3c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c3e:	00001097          	auipc	ra,0x1
    80000c42:	1e6080e7          	jalr	486(ra) # 80001e24 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c46:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c4a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4c:	e78d                	bnez	a5,80000c76 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4e:	5d3c                	lw	a5,120(a0)
    80000c50:	02f05b63          	blez	a5,80000c86 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c54:	37fd                	addiw	a5,a5,-1
    80000c56:	0007871b          	sext.w	a4,a5
    80000c5a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5c:	eb09                	bnez	a4,80000c6e <pop_off+0x38>
    80000c5e:	5d7c                	lw	a5,124(a0)
    80000c60:	c799                	beqz	a5,80000c6e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c62:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c66:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c6a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6e:	60a2                	ld	ra,8(sp)
    80000c70:	6402                	ld	s0,0(sp)
    80000c72:	0141                	addi	sp,sp,16
    80000c74:	8082                	ret
    panic("pop_off - interruptible");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41250513          	addi	a0,a0,1042 # 80008088 <digits+0x48>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8ac080e7          	jalr	-1876(ra) # 8000052a <panic>
    panic("pop_off");
    80000c86:	00007517          	auipc	a0,0x7
    80000c8a:	41a50513          	addi	a0,a0,1050 # 800080a0 <digits+0x60>
    80000c8e:	00000097          	auipc	ra,0x0
    80000c92:	89c080e7          	jalr	-1892(ra) # 8000052a <panic>

0000000080000c96 <release>:
{
    80000c96:	1101                	addi	sp,sp,-32
    80000c98:	ec06                	sd	ra,24(sp)
    80000c9a:	e822                	sd	s0,16(sp)
    80000c9c:	e426                	sd	s1,8(sp)
    80000c9e:	1000                	addi	s0,sp,32
    80000ca0:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ca2:	00000097          	auipc	ra,0x0
    80000ca6:	ec6080e7          	jalr	-314(ra) # 80000b68 <holding>
    80000caa:	c115                	beqz	a0,80000cce <release+0x38>
  lk->cpu = 0;
    80000cac:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cb4:	0f50000f          	fence	iorw,ow
    80000cb8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cbc:	00000097          	auipc	ra,0x0
    80000cc0:	f7a080e7          	jalr	-134(ra) # 80000c36 <pop_off>
}
    80000cc4:	60e2                	ld	ra,24(sp)
    80000cc6:	6442                	ld	s0,16(sp)
    80000cc8:	64a2                	ld	s1,8(sp)
    80000cca:	6105                	addi	sp,sp,32
    80000ccc:	8082                	ret
    panic("release");
    80000cce:	00007517          	auipc	a0,0x7
    80000cd2:	3da50513          	addi	a0,a0,986 # 800080a8 <digits+0x68>
    80000cd6:	00000097          	auipc	ra,0x0
    80000cda:	854080e7          	jalr	-1964(ra) # 8000052a <panic>

0000000080000cde <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cde:	1141                	addi	sp,sp,-16
    80000ce0:	e422                	sd	s0,8(sp)
    80000ce2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ce4:	ca19                	beqz	a2,80000cfa <memset+0x1c>
    80000ce6:	87aa                	mv	a5,a0
    80000ce8:	1602                	slli	a2,a2,0x20
    80000cea:	9201                	srli	a2,a2,0x20
    80000cec:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cf0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cf4:	0785                	addi	a5,a5,1
    80000cf6:	fee79de3          	bne	a5,a4,80000cf0 <memset+0x12>
  }
  return dst;
}
    80000cfa:	6422                	ld	s0,8(sp)
    80000cfc:	0141                	addi	sp,sp,16
    80000cfe:	8082                	ret

0000000080000d00 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d00:	1141                	addi	sp,sp,-16
    80000d02:	e422                	sd	s0,8(sp)
    80000d04:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d06:	ca05                	beqz	a2,80000d36 <memcmp+0x36>
    80000d08:	fff6069b          	addiw	a3,a2,-1
    80000d0c:	1682                	slli	a3,a3,0x20
    80000d0e:	9281                	srli	a3,a3,0x20
    80000d10:	0685                	addi	a3,a3,1
    80000d12:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d14:	00054783          	lbu	a5,0(a0)
    80000d18:	0005c703          	lbu	a4,0(a1)
    80000d1c:	00e79863          	bne	a5,a4,80000d2c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d20:	0505                	addi	a0,a0,1
    80000d22:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d24:	fed518e3          	bne	a0,a3,80000d14 <memcmp+0x14>
  }

  return 0;
    80000d28:	4501                	li	a0,0
    80000d2a:	a019                	j	80000d30 <memcmp+0x30>
      return *s1 - *s2;
    80000d2c:	40e7853b          	subw	a0,a5,a4
}
    80000d30:	6422                	ld	s0,8(sp)
    80000d32:	0141                	addi	sp,sp,16
    80000d34:	8082                	ret
  return 0;
    80000d36:	4501                	li	a0,0
    80000d38:	bfe5                	j	80000d30 <memcmp+0x30>

0000000080000d3a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d3a:	1141                	addi	sp,sp,-16
    80000d3c:	e422                	sd	s0,8(sp)
    80000d3e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d40:	02a5e563          	bltu	a1,a0,80000d6a <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d44:	fff6069b          	addiw	a3,a2,-1
    80000d48:	ce11                	beqz	a2,80000d64 <memmove+0x2a>
    80000d4a:	1682                	slli	a3,a3,0x20
    80000d4c:	9281                	srli	a3,a3,0x20
    80000d4e:	0685                	addi	a3,a3,1
    80000d50:	96ae                	add	a3,a3,a1
    80000d52:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d54:	0585                	addi	a1,a1,1
    80000d56:	0785                	addi	a5,a5,1
    80000d58:	fff5c703          	lbu	a4,-1(a1)
    80000d5c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d60:	fed59ae3          	bne	a1,a3,80000d54 <memmove+0x1a>

  return dst;
}
    80000d64:	6422                	ld	s0,8(sp)
    80000d66:	0141                	addi	sp,sp,16
    80000d68:	8082                	ret
  if(s < d && s + n > d){
    80000d6a:	02061713          	slli	a4,a2,0x20
    80000d6e:	9301                	srli	a4,a4,0x20
    80000d70:	00e587b3          	add	a5,a1,a4
    80000d74:	fcf578e3          	bgeu	a0,a5,80000d44 <memmove+0xa>
    d += n;
    80000d78:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d7a:	fff6069b          	addiw	a3,a2,-1
    80000d7e:	d27d                	beqz	a2,80000d64 <memmove+0x2a>
    80000d80:	02069613          	slli	a2,a3,0x20
    80000d84:	9201                	srli	a2,a2,0x20
    80000d86:	fff64613          	not	a2,a2
    80000d8a:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d8c:	17fd                	addi	a5,a5,-1
    80000d8e:	177d                	addi	a4,a4,-1
    80000d90:	0007c683          	lbu	a3,0(a5)
    80000d94:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d98:	fef61ae3          	bne	a2,a5,80000d8c <memmove+0x52>
    80000d9c:	b7e1                	j	80000d64 <memmove+0x2a>

0000000080000d9e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d9e:	1141                	addi	sp,sp,-16
    80000da0:	e406                	sd	ra,8(sp)
    80000da2:	e022                	sd	s0,0(sp)
    80000da4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000da6:	00000097          	auipc	ra,0x0
    80000daa:	f94080e7          	jalr	-108(ra) # 80000d3a <memmove>
}
    80000dae:	60a2                	ld	ra,8(sp)
    80000db0:	6402                	ld	s0,0(sp)
    80000db2:	0141                	addi	sp,sp,16
    80000db4:	8082                	ret

0000000080000db6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000db6:	1141                	addi	sp,sp,-16
    80000db8:	e422                	sd	s0,8(sp)
    80000dba:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dbc:	ce11                	beqz	a2,80000dd8 <strncmp+0x22>
    80000dbe:	00054783          	lbu	a5,0(a0)
    80000dc2:	cf89                	beqz	a5,80000ddc <strncmp+0x26>
    80000dc4:	0005c703          	lbu	a4,0(a1)
    80000dc8:	00f71a63          	bne	a4,a5,80000ddc <strncmp+0x26>
    n--, p++, q++;
    80000dcc:	367d                	addiw	a2,a2,-1
    80000dce:	0505                	addi	a0,a0,1
    80000dd0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dd2:	f675                	bnez	a2,80000dbe <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dd4:	4501                	li	a0,0
    80000dd6:	a809                	j	80000de8 <strncmp+0x32>
    80000dd8:	4501                	li	a0,0
    80000dda:	a039                	j	80000de8 <strncmp+0x32>
  if(n == 0)
    80000ddc:	ca09                	beqz	a2,80000dee <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dde:	00054503          	lbu	a0,0(a0)
    80000de2:	0005c783          	lbu	a5,0(a1)
    80000de6:	9d1d                	subw	a0,a0,a5
}
    80000de8:	6422                	ld	s0,8(sp)
    80000dea:	0141                	addi	sp,sp,16
    80000dec:	8082                	ret
    return 0;
    80000dee:	4501                	li	a0,0
    80000df0:	bfe5                	j	80000de8 <strncmp+0x32>

0000000080000df2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000df2:	1141                	addi	sp,sp,-16
    80000df4:	e422                	sd	s0,8(sp)
    80000df6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000df8:	872a                	mv	a4,a0
    80000dfa:	8832                	mv	a6,a2
    80000dfc:	367d                	addiw	a2,a2,-1
    80000dfe:	01005963          	blez	a6,80000e10 <strncpy+0x1e>
    80000e02:	0705                	addi	a4,a4,1
    80000e04:	0005c783          	lbu	a5,0(a1)
    80000e08:	fef70fa3          	sb	a5,-1(a4)
    80000e0c:	0585                	addi	a1,a1,1
    80000e0e:	f7f5                	bnez	a5,80000dfa <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e10:	86ba                	mv	a3,a4
    80000e12:	00c05c63          	blez	a2,80000e2a <strncpy+0x38>
    *s++ = 0;
    80000e16:	0685                	addi	a3,a3,1
    80000e18:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e1c:	fff6c793          	not	a5,a3
    80000e20:	9fb9                	addw	a5,a5,a4
    80000e22:	010787bb          	addw	a5,a5,a6
    80000e26:	fef048e3          	bgtz	a5,80000e16 <strncpy+0x24>
  return os;
}
    80000e2a:	6422                	ld	s0,8(sp)
    80000e2c:	0141                	addi	sp,sp,16
    80000e2e:	8082                	ret

0000000080000e30 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e30:	1141                	addi	sp,sp,-16
    80000e32:	e422                	sd	s0,8(sp)
    80000e34:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e36:	02c05363          	blez	a2,80000e5c <safestrcpy+0x2c>
    80000e3a:	fff6069b          	addiw	a3,a2,-1
    80000e3e:	1682                	slli	a3,a3,0x20
    80000e40:	9281                	srli	a3,a3,0x20
    80000e42:	96ae                	add	a3,a3,a1
    80000e44:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e46:	00d58963          	beq	a1,a3,80000e58 <safestrcpy+0x28>
    80000e4a:	0585                	addi	a1,a1,1
    80000e4c:	0785                	addi	a5,a5,1
    80000e4e:	fff5c703          	lbu	a4,-1(a1)
    80000e52:	fee78fa3          	sb	a4,-1(a5)
    80000e56:	fb65                	bnez	a4,80000e46 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e58:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e5c:	6422                	ld	s0,8(sp)
    80000e5e:	0141                	addi	sp,sp,16
    80000e60:	8082                	ret

0000000080000e62 <strlen>:

int
strlen(const char *s)
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e422                	sd	s0,8(sp)
    80000e66:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e68:	00054783          	lbu	a5,0(a0)
    80000e6c:	cf91                	beqz	a5,80000e88 <strlen+0x26>
    80000e6e:	0505                	addi	a0,a0,1
    80000e70:	87aa                	mv	a5,a0
    80000e72:	4685                	li	a3,1
    80000e74:	9e89                	subw	a3,a3,a0
    80000e76:	00f6853b          	addw	a0,a3,a5
    80000e7a:	0785                	addi	a5,a5,1
    80000e7c:	fff7c703          	lbu	a4,-1(a5)
    80000e80:	fb7d                	bnez	a4,80000e76 <strlen+0x14>
    ;
  return n;
}
    80000e82:	6422                	ld	s0,8(sp)
    80000e84:	0141                	addi	sp,sp,16
    80000e86:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e88:	4501                	li	a0,0
    80000e8a:	bfe5                	j	80000e82 <strlen+0x20>

0000000080000e8c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e8c:	1141                	addi	sp,sp,-16
    80000e8e:	e406                	sd	ra,8(sp)
    80000e90:	e022                	sd	s0,0(sp)
    80000e92:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e94:	00001097          	auipc	ra,0x1
    80000e98:	f80080e7          	jalr	-128(ra) # 80001e14 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e9c:	00008717          	auipc	a4,0x8
    80000ea0:	17c70713          	addi	a4,a4,380 # 80009018 <started>
  if(cpuid() == 0){
    80000ea4:	c139                	beqz	a0,80000eea <main+0x5e>
    while(started == 0)
    80000ea6:	431c                	lw	a5,0(a4)
    80000ea8:	2781                	sext.w	a5,a5
    80000eaa:	dff5                	beqz	a5,80000ea6 <main+0x1a>
      ;
    __sync_synchronize();
    80000eac:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb0:	00001097          	auipc	ra,0x1
    80000eb4:	f64080e7          	jalr	-156(ra) # 80001e14 <cpuid>
    80000eb8:	85aa                	mv	a1,a0
    80000eba:	00007517          	auipc	a0,0x7
    80000ebe:	20e50513          	addi	a0,a0,526 # 800080c8 <digits+0x88>
    80000ec2:	fffff097          	auipc	ra,0xfffff
    80000ec6:	6b2080e7          	jalr	1714(ra) # 80000574 <printf>
    kvminithart();    // turn on paging
    80000eca:	00000097          	auipc	ra,0x0
    80000ece:	0d8080e7          	jalr	216(ra) # 80000fa2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ed2:	00002097          	auipc	ra,0x2
    80000ed6:	d8c080e7          	jalr	-628(ra) # 80002c5e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eda:	00006097          	auipc	ra,0x6
    80000ede:	976080e7          	jalr	-1674(ra) # 80006850 <plicinithart>
  }

  scheduler();        
    80000ee2:	00001097          	auipc	ra,0x1
    80000ee6:	616080e7          	jalr	1558(ra) # 800024f8 <scheduler>
    consoleinit();
    80000eea:	fffff097          	auipc	ra,0xfffff
    80000eee:	552080e7          	jalr	1362(ra) # 8000043c <consoleinit>
    printfinit();
    80000ef2:	00000097          	auipc	ra,0x0
    80000ef6:	862080e7          	jalr	-1950(ra) # 80000754 <printfinit>
    printf("\n");
    80000efa:	00007517          	auipc	a0,0x7
    80000efe:	1de50513          	addi	a0,a0,478 # 800080d8 <digits+0x98>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000f0a:	00007517          	auipc	a0,0x7
    80000f0e:	1a650513          	addi	a0,a0,422 # 800080b0 <digits+0x70>
    80000f12:	fffff097          	auipc	ra,0xfffff
    80000f16:	662080e7          	jalr	1634(ra) # 80000574 <printf>
    printf("\n");
    80000f1a:	00007517          	auipc	a0,0x7
    80000f1e:	1be50513          	addi	a0,a0,446 # 800080d8 <digits+0x98>
    80000f22:	fffff097          	auipc	ra,0xfffff
    80000f26:	652080e7          	jalr	1618(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f2a:	00000097          	auipc	ra,0x0
    80000f2e:	b8c080e7          	jalr	-1140(ra) # 80000ab6 <kinit>
    kvminit();       // create kernel page table
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	310080e7          	jalr	784(ra) # 80001242 <kvminit>
    kvminithart();   // turn on paging
    80000f3a:	00000097          	auipc	ra,0x0
    80000f3e:	068080e7          	jalr	104(ra) # 80000fa2 <kvminithart>
    procinit();      // process table
    80000f42:	00001097          	auipc	ra,0x1
    80000f46:	e22080e7          	jalr	-478(ra) # 80001d64 <procinit>
    trapinit();      // trap vectors
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	cec080e7          	jalr	-788(ra) # 80002c36 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f52:	00002097          	auipc	ra,0x2
    80000f56:	d0c080e7          	jalr	-756(ra) # 80002c5e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f5a:	00006097          	auipc	ra,0x6
    80000f5e:	8e0080e7          	jalr	-1824(ra) # 8000683a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	8ee080e7          	jalr	-1810(ra) # 80006850 <plicinithart>
    binit();         // buffer cache
    80000f6a:	00002097          	auipc	ra,0x2
    80000f6e:	56a080e7          	jalr	1386(ra) # 800034d4 <binit>
    iinit();         // inode cache
    80000f72:	00003097          	auipc	ra,0x3
    80000f76:	bfc080e7          	jalr	-1028(ra) # 80003b6e <iinit>
    fileinit();      // file table
    80000f7a:	00004097          	auipc	ra,0x4
    80000f7e:	ebc080e7          	jalr	-324(ra) # 80004e36 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f82:	00006097          	auipc	ra,0x6
    80000f86:	9f0080e7          	jalr	-1552(ra) # 80006972 <virtio_disk_init>
    userinit();      // first user process
    80000f8a:	00001097          	auipc	ra,0x1
    80000f8e:	220080e7          	jalr	544(ra) # 800021aa <userinit>
    __sync_synchronize();
    80000f92:	0ff0000f          	fence
    started = 1;
    80000f96:	4785                	li	a5,1
    80000f98:	00008717          	auipc	a4,0x8
    80000f9c:	08f72023          	sw	a5,128(a4) # 80009018 <started>
    80000fa0:	b789                	j	80000ee2 <main+0x56>

0000000080000fa2 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fa2:	1141                	addi	sp,sp,-16
    80000fa4:	e422                	sd	s0,8(sp)
    80000fa6:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fa8:	00008797          	auipc	a5,0x8
    80000fac:	0787b783          	ld	a5,120(a5) # 80009020 <kernel_pagetable>
    80000fb0:	83b1                	srli	a5,a5,0xc
    80000fb2:	577d                	li	a4,-1
    80000fb4:	177e                	slli	a4,a4,0x3f
    80000fb6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fb8:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fbc:	12000073          	sfence.vma
  sfence_vma();
}
    80000fc0:	6422                	ld	s0,8(sp)
    80000fc2:	0141                	addi	sp,sp,16
    80000fc4:	8082                	ret

0000000080000fc6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc6:	7139                	addi	sp,sp,-64
    80000fc8:	fc06                	sd	ra,56(sp)
    80000fca:	f822                	sd	s0,48(sp)
    80000fcc:	f426                	sd	s1,40(sp)
    80000fce:	f04a                	sd	s2,32(sp)
    80000fd0:	ec4e                	sd	s3,24(sp)
    80000fd2:	e852                	sd	s4,16(sp)
    80000fd4:	e456                	sd	s5,8(sp)
    80000fd6:	e05a                	sd	s6,0(sp)
    80000fd8:	0080                	addi	s0,sp,64
    80000fda:	84aa                	mv	s1,a0
    80000fdc:	89ae                	mv	s3,a1
    80000fde:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fe0:	57fd                	li	a5,-1
    80000fe2:	83e9                	srli	a5,a5,0x1a
    80000fe4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fe8:	04b7f263          	bgeu	a5,a1,8000102c <walk+0x66>
    panic("walk");
    80000fec:	00007517          	auipc	a0,0x7
    80000ff0:	0f450513          	addi	a0,a0,244 # 800080e0 <digits+0xa0>
    80000ff4:	fffff097          	auipc	ra,0xfffff
    80000ff8:	536080e7          	jalr	1334(ra) # 8000052a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffc:	060a8663          	beqz	s5,80001068 <walk+0xa2>
    80001000:	00000097          	auipc	ra,0x0
    80001004:	af2080e7          	jalr	-1294(ra) # 80000af2 <kalloc>
    80001008:	84aa                	mv	s1,a0
    8000100a:	c529                	beqz	a0,80001054 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000100c:	6605                	lui	a2,0x1
    8000100e:	4581                	li	a1,0
    80001010:	00000097          	auipc	ra,0x0
    80001014:	cce080e7          	jalr	-818(ra) # 80000cde <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001018:	00c4d793          	srli	a5,s1,0xc
    8000101c:	07aa                	slli	a5,a5,0xa
    8000101e:	0017e793          	ori	a5,a5,1
    80001022:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001026:	3a5d                	addiw	s4,s4,-9
    80001028:	036a0063          	beq	s4,s6,80001048 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000102c:	0149d933          	srl	s2,s3,s4
    80001030:	1ff97913          	andi	s2,s2,511
    80001034:	090e                	slli	s2,s2,0x3
    80001036:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001038:	00093483          	ld	s1,0(s2)
    8000103c:	0014f793          	andi	a5,s1,1
    80001040:	dfd5                	beqz	a5,80000ffc <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001042:	80a9                	srli	s1,s1,0xa
    80001044:	04b2                	slli	s1,s1,0xc
    80001046:	b7c5                	j	80001026 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001048:	00c9d513          	srli	a0,s3,0xc
    8000104c:	1ff57513          	andi	a0,a0,511
    80001050:	050e                	slli	a0,a0,0x3
    80001052:	9526                	add	a0,a0,s1
}
    80001054:	70e2                	ld	ra,56(sp)
    80001056:	7442                	ld	s0,48(sp)
    80001058:	74a2                	ld	s1,40(sp)
    8000105a:	7902                	ld	s2,32(sp)
    8000105c:	69e2                	ld	s3,24(sp)
    8000105e:	6a42                	ld	s4,16(sp)
    80001060:	6aa2                	ld	s5,8(sp)
    80001062:	6b02                	ld	s6,0(sp)
    80001064:	6121                	addi	sp,sp,64
    80001066:	8082                	ret
        return 0;
    80001068:	4501                	li	a0,0
    8000106a:	b7ed                	j	80001054 <walk+0x8e>

000000008000106c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000106c:	57fd                	li	a5,-1
    8000106e:	83e9                	srli	a5,a5,0x1a
    80001070:	00b7f463          	bgeu	a5,a1,80001078 <walkaddr+0xc>
    return 0;
    80001074:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001076:	8082                	ret
{
    80001078:	1141                	addi	sp,sp,-16
    8000107a:	e406                	sd	ra,8(sp)
    8000107c:	e022                	sd	s0,0(sp)
    8000107e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001080:	4601                	li	a2,0
    80001082:	00000097          	auipc	ra,0x0
    80001086:	f44080e7          	jalr	-188(ra) # 80000fc6 <walk>
  if(pte == 0)
    8000108a:	c105                	beqz	a0,800010aa <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000108c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000108e:	0117f693          	andi	a3,a5,17
    80001092:	4745                	li	a4,17
    return 0;
    80001094:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001096:	00e68663          	beq	a3,a4,800010a2 <walkaddr+0x36>
}
    8000109a:	60a2                	ld	ra,8(sp)
    8000109c:	6402                	ld	s0,0(sp)
    8000109e:	0141                	addi	sp,sp,16
    800010a0:	8082                	ret
  pa = PTE2PA(*pte);
    800010a2:	00a7d513          	srli	a0,a5,0xa
    800010a6:	0532                	slli	a0,a0,0xc
  return pa;
    800010a8:	bfcd                	j	8000109a <walkaddr+0x2e>
    return 0;
    800010aa:	4501                	li	a0,0
    800010ac:	b7fd                	j	8000109a <walkaddr+0x2e>

00000000800010ae <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010ae:	715d                	addi	sp,sp,-80
    800010b0:	e486                	sd	ra,72(sp)
    800010b2:	e0a2                	sd	s0,64(sp)
    800010b4:	fc26                	sd	s1,56(sp)
    800010b6:	f84a                	sd	s2,48(sp)
    800010b8:	f44e                	sd	s3,40(sp)
    800010ba:	f052                	sd	s4,32(sp)
    800010bc:	ec56                	sd	s5,24(sp)
    800010be:	e85a                	sd	s6,16(sp)
    800010c0:	e45e                	sd	s7,8(sp)
    800010c2:	0880                	addi	s0,sp,80
    800010c4:	8aaa                	mv	s5,a0
    800010c6:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010c8:	777d                	lui	a4,0xfffff
    800010ca:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ce:	167d                	addi	a2,a2,-1
    800010d0:	00b609b3          	add	s3,a2,a1
    800010d4:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010d8:	893e                	mv	s2,a5
    800010da:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010de:	6b85                	lui	s7,0x1
    800010e0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010e4:	4605                	li	a2,1
    800010e6:	85ca                	mv	a1,s2
    800010e8:	8556                	mv	a0,s5
    800010ea:	00000097          	auipc	ra,0x0
    800010ee:	edc080e7          	jalr	-292(ra) # 80000fc6 <walk>
    800010f2:	c51d                	beqz	a0,80001120 <mappages+0x72>
    if(*pte & PTE_V)
    800010f4:	611c                	ld	a5,0(a0)
    800010f6:	8b85                	andi	a5,a5,1
    800010f8:	ef81                	bnez	a5,80001110 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010fa:	80b1                	srli	s1,s1,0xc
    800010fc:	04aa                	slli	s1,s1,0xa
    800010fe:	0164e4b3          	or	s1,s1,s6
    80001102:	0014e493          	ori	s1,s1,1
    80001106:	e104                	sd	s1,0(a0)
    if(a == last)
    80001108:	03390863          	beq	s2,s3,80001138 <mappages+0x8a>
    a += PGSIZE;
    8000110c:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000110e:	bfc9                	j	800010e0 <mappages+0x32>
      panic("remap");
    80001110:	00007517          	auipc	a0,0x7
    80001114:	fd850513          	addi	a0,a0,-40 # 800080e8 <digits+0xa8>
    80001118:	fffff097          	auipc	ra,0xfffff
    8000111c:	412080e7          	jalr	1042(ra) # 8000052a <panic>
      return -1;
    80001120:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001122:	60a6                	ld	ra,72(sp)
    80001124:	6406                	ld	s0,64(sp)
    80001126:	74e2                	ld	s1,56(sp)
    80001128:	7942                	ld	s2,48(sp)
    8000112a:	79a2                	ld	s3,40(sp)
    8000112c:	7a02                	ld	s4,32(sp)
    8000112e:	6ae2                	ld	s5,24(sp)
    80001130:	6b42                	ld	s6,16(sp)
    80001132:	6ba2                	ld	s7,8(sp)
    80001134:	6161                	addi	sp,sp,80
    80001136:	8082                	ret
  return 0;
    80001138:	4501                	li	a0,0
    8000113a:	b7e5                	j	80001122 <mappages+0x74>

000000008000113c <kvmmap>:
{
    8000113c:	1141                	addi	sp,sp,-16
    8000113e:	e406                	sd	ra,8(sp)
    80001140:	e022                	sd	s0,0(sp)
    80001142:	0800                	addi	s0,sp,16
    80001144:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001146:	86b2                	mv	a3,a2
    80001148:	863e                	mv	a2,a5
    8000114a:	00000097          	auipc	ra,0x0
    8000114e:	f64080e7          	jalr	-156(ra) # 800010ae <mappages>
    80001152:	e509                	bnez	a0,8000115c <kvmmap+0x20>
}
    80001154:	60a2                	ld	ra,8(sp)
    80001156:	6402                	ld	s0,0(sp)
    80001158:	0141                	addi	sp,sp,16
    8000115a:	8082                	ret
    panic("kvmmap");
    8000115c:	00007517          	auipc	a0,0x7
    80001160:	f9450513          	addi	a0,a0,-108 # 800080f0 <digits+0xb0>
    80001164:	fffff097          	auipc	ra,0xfffff
    80001168:	3c6080e7          	jalr	966(ra) # 8000052a <panic>

000000008000116c <kvmmake>:
{
    8000116c:	1101                	addi	sp,sp,-32
    8000116e:	ec06                	sd	ra,24(sp)
    80001170:	e822                	sd	s0,16(sp)
    80001172:	e426                	sd	s1,8(sp)
    80001174:	e04a                	sd	s2,0(sp)
    80001176:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001178:	00000097          	auipc	ra,0x0
    8000117c:	97a080e7          	jalr	-1670(ra) # 80000af2 <kalloc>
    80001180:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001182:	6605                	lui	a2,0x1
    80001184:	4581                	li	a1,0
    80001186:	00000097          	auipc	ra,0x0
    8000118a:	b58080e7          	jalr	-1192(ra) # 80000cde <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118e:	4719                	li	a4,6
    80001190:	6685                	lui	a3,0x1
    80001192:	10000637          	lui	a2,0x10000
    80001196:	100005b7          	lui	a1,0x10000
    8000119a:	8526                	mv	a0,s1
    8000119c:	00000097          	auipc	ra,0x0
    800011a0:	fa0080e7          	jalr	-96(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a4:	4719                	li	a4,6
    800011a6:	6685                	lui	a3,0x1
    800011a8:	10001637          	lui	a2,0x10001
    800011ac:	100015b7          	lui	a1,0x10001
    800011b0:	8526                	mv	a0,s1
    800011b2:	00000097          	auipc	ra,0x0
    800011b6:	f8a080e7          	jalr	-118(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011ba:	4719                	li	a4,6
    800011bc:	004006b7          	lui	a3,0x400
    800011c0:	0c000637          	lui	a2,0xc000
    800011c4:	0c0005b7          	lui	a1,0xc000
    800011c8:	8526                	mv	a0,s1
    800011ca:	00000097          	auipc	ra,0x0
    800011ce:	f72080e7          	jalr	-142(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d2:	00007917          	auipc	s2,0x7
    800011d6:	e2e90913          	addi	s2,s2,-466 # 80008000 <etext>
    800011da:	4729                	li	a4,10
    800011dc:	80007697          	auipc	a3,0x80007
    800011e0:	e2468693          	addi	a3,a3,-476 # 8000 <_entry-0x7fff8000>
    800011e4:	4605                	li	a2,1
    800011e6:	067e                	slli	a2,a2,0x1f
    800011e8:	85b2                	mv	a1,a2
    800011ea:	8526                	mv	a0,s1
    800011ec:	00000097          	auipc	ra,0x0
    800011f0:	f50080e7          	jalr	-176(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f4:	4719                	li	a4,6
    800011f6:	46c5                	li	a3,17
    800011f8:	06ee                	slli	a3,a3,0x1b
    800011fa:	412686b3          	sub	a3,a3,s2
    800011fe:	864a                	mv	a2,s2
    80001200:	85ca                	mv	a1,s2
    80001202:	8526                	mv	a0,s1
    80001204:	00000097          	auipc	ra,0x0
    80001208:	f38080e7          	jalr	-200(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120c:	4729                	li	a4,10
    8000120e:	6685                	lui	a3,0x1
    80001210:	00006617          	auipc	a2,0x6
    80001214:	df060613          	addi	a2,a2,-528 # 80007000 <_trampoline>
    80001218:	040005b7          	lui	a1,0x4000
    8000121c:	15fd                	addi	a1,a1,-1
    8000121e:	05b2                	slli	a1,a1,0xc
    80001220:	8526                	mv	a0,s1
    80001222:	00000097          	auipc	ra,0x0
    80001226:	f1a080e7          	jalr	-230(ra) # 8000113c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122a:	8526                	mv	a0,s1
    8000122c:	00001097          	auipc	ra,0x1
    80001230:	aa2080e7          	jalr	-1374(ra) # 80001cce <proc_mapstacks>
}
    80001234:	8526                	mv	a0,s1
    80001236:	60e2                	ld	ra,24(sp)
    80001238:	6442                	ld	s0,16(sp)
    8000123a:	64a2                	ld	s1,8(sp)
    8000123c:	6902                	ld	s2,0(sp)
    8000123e:	6105                	addi	sp,sp,32
    80001240:	8082                	ret

0000000080001242 <kvminit>:
{
    80001242:	1141                	addi	sp,sp,-16
    80001244:	e406                	sd	ra,8(sp)
    80001246:	e022                	sd	s0,0(sp)
    80001248:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124a:	00000097          	auipc	ra,0x0
    8000124e:	f22080e7          	jalr	-222(ra) # 8000116c <kvmmake>
    80001252:	00008797          	auipc	a5,0x8
    80001256:	dca7b723          	sd	a0,-562(a5) # 80009020 <kernel_pagetable>
}
    8000125a:	60a2                	ld	ra,8(sp)
    8000125c:	6402                	ld	s0,0(sp)
    8000125e:	0141                	addi	sp,sp,16
    80001260:	8082                	ret

0000000080001262 <deletePage>:
void deletePage(uint64 va){
    80001262:	1101                	addi	sp,sp,-32
    80001264:	ec06                	sd	ra,24(sp)
    80001266:	e822                	sd	s0,16(sp)
    80001268:	e426                	sd	s1,8(sp)
    8000126a:	1000                	addi	s0,sp,32
    8000126c:	84aa                	mv	s1,a0

  struct proc *p = myproc();
    8000126e:	00001097          	auipc	ra,0x1
    80001272:	bd2080e7          	jalr	-1070(ra) # 80001e40 <myproc>
  if(p->pid < 3)
    80001276:	5918                	lw	a4,48(a0)
    80001278:	4789                	li	a5,2
    8000127a:	02e7d563          	bge	a5,a4,800012a4 <deletePage+0x42>
    8000127e:	17050713          	addi	a4,a0,368
    return;
  for(int i=0; i<MAX_PSYC_PAGES; i++){
    80001282:	4781                	li	a5,0
    80001284:	4641                	li	a2,16
    if(p->pages_in_ram[i].va != va)
    80001286:	6314                	ld	a3,0(a4)
    80001288:	02969363          	bne	a3,s1,800012ae <deletePage+0x4c>
      continue;
    p->pages_in_ram[i].va = 0;
    8000128c:	0792                	slli	a5,a5,0x4
    8000128e:	97aa                	add	a5,a5,a0
    80001290:	1607b823          	sd	zero,368(a5)
    p->pages_in_ram[i].is_free = 1;
    80001294:	4705                	li	a4,1
    80001296:	16e7ac23          	sw	a4,376(a5)
    p->ram_pages_counter --;
    8000129a:	27052783          	lw	a5,624(a0)
    8000129e:	37fd                	addiw	a5,a5,-1
    800012a0:	26f52823          	sw	a5,624(a0)
    p->pages_in_file[i].va = 0;
    p->pages_in_file[i].is_free = 1;
    p->pages_in_file_counter --;
    return;
  }
}
    800012a4:	60e2                	ld	ra,24(sp)
    800012a6:	6442                	ld	s0,16(sp)
    800012a8:	64a2                	ld	s1,8(sp)
    800012aa:	6105                	addi	sp,sp,32
    800012ac:	8082                	ret
  for(int i=0; i<MAX_PSYC_PAGES; i++){
    800012ae:	2785                	addiw	a5,a5,1
    800012b0:	0741                	addi	a4,a4,16
    800012b2:	fcc79ae3          	bne	a5,a2,80001286 <deletePage+0x24>
    800012b6:	27850713          	addi	a4,a0,632
  for(int i=0; i<MAX_PSYC_PAGES; i++){
    800012ba:	4781                	li	a5,0
    800012bc:	4641                	li	a2,16
    800012be:	a029                	j	800012c8 <deletePage+0x66>
    800012c0:	2785                	addiw	a5,a5,1
    800012c2:	0741                	addi	a4,a4,16
    800012c4:	fec780e3          	beq	a5,a2,800012a4 <deletePage+0x42>
    if(p->pages_in_file[i].va != va)
    800012c8:	6314                	ld	a3,0(a4)
    800012ca:	fe969be3          	bne	a3,s1,800012c0 <deletePage+0x5e>
    p->pages_in_file[i].va = 0;
    800012ce:	0792                	slli	a5,a5,0x4
    800012d0:	97aa                	add	a5,a5,a0
    800012d2:	2607bc23          	sd	zero,632(a5)
    p->pages_in_file[i].is_free = 1;
    800012d6:	4705                	li	a4,1
    800012d8:	28e7a023          	sw	a4,640(a5)
    p->pages_in_file_counter --;
    800012dc:	37852783          	lw	a5,888(a0)
    800012e0:	37fd                	addiw	a5,a5,-1
    800012e2:	36f52c23          	sw	a5,888(a0)
    return;
    800012e6:	bf7d                	j	800012a4 <deletePage+0x42>

00000000800012e8 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012e8:	715d                	addi	sp,sp,-80
    800012ea:	e486                	sd	ra,72(sp)
    800012ec:	e0a2                	sd	s0,64(sp)
    800012ee:	fc26                	sd	s1,56(sp)
    800012f0:	f84a                	sd	s2,48(sp)
    800012f2:	f44e                	sd	s3,40(sp)
    800012f4:	f052                	sd	s4,32(sp)
    800012f6:	ec56                	sd	s5,24(sp)
    800012f8:	e85a                	sd	s6,16(sp)
    800012fa:	e45e                	sd	s7,8(sp)
    800012fc:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012fe:	03459793          	slli	a5,a1,0x34
    80001302:	e795                	bnez	a5,8000132e <uvmunmap+0x46>
    80001304:	8a2a                	mv	s4,a0
    80001306:	892e                	mv	s2,a1
    80001308:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");
  
  // printf("uvmubmap: va=%d\n", va);

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130a:	0632                	slli	a2,a2,0xc
    8000130c:	00b609b3          	add	s3,a2,a1
        else
          panic("uvmunmap: page is not valid");
      }else
        panic("uvmunmap: not mapped");
    }
    if(PTE_FLAGS(*pte) == PTE_V)
    80001310:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001312:	6b05                	lui	s6,0x1
    80001314:	0935e263          	bltu	a1,s3,80001398 <uvmunmap+0xb0>
      kfree((void*)pa);
    }
    deletePage(a);
    *pte = 0;
  }
}
    80001318:	60a6                	ld	ra,72(sp)
    8000131a:	6406                	ld	s0,64(sp)
    8000131c:	74e2                	ld	s1,56(sp)
    8000131e:	7942                	ld	s2,48(sp)
    80001320:	79a2                	ld	s3,40(sp)
    80001322:	7a02                	ld	s4,32(sp)
    80001324:	6ae2                	ld	s5,24(sp)
    80001326:	6b42                	ld	s6,16(sp)
    80001328:	6ba2                	ld	s7,8(sp)
    8000132a:	6161                	addi	sp,sp,80
    8000132c:	8082                	ret
    panic("uvmunmap: not aligned");
    8000132e:	00007517          	auipc	a0,0x7
    80001332:	dca50513          	addi	a0,a0,-566 # 800080f8 <digits+0xb8>
    80001336:	fffff097          	auipc	ra,0xfffff
    8000133a:	1f4080e7          	jalr	500(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    8000133e:	00007517          	auipc	a0,0x7
    80001342:	dd250513          	addi	a0,a0,-558 # 80008110 <digits+0xd0>
    80001346:	fffff097          	auipc	ra,0xfffff
    8000134a:	1e4080e7          	jalr	484(ra) # 8000052a <panic>
        if (( *pte & PTE_PG ) == 0)
    8000134e:	2007f793          	andi	a5,a5,512
    80001352:	eb89                	bnez	a5,80001364 <uvmunmap+0x7c>
          panic("uvmunmap: page has been swapped");
    80001354:	00007517          	auipc	a0,0x7
    80001358:	dcc50513          	addi	a0,a0,-564 # 80008120 <digits+0xe0>
    8000135c:	fffff097          	auipc	ra,0xfffff
    80001360:	1ce080e7          	jalr	462(ra) # 8000052a <panic>
          panic("uvmunmap: page is not valid");
    80001364:	00007517          	auipc	a0,0x7
    80001368:	ddc50513          	addi	a0,a0,-548 # 80008140 <digits+0x100>
    8000136c:	fffff097          	auipc	ra,0xfffff
    80001370:	1be080e7          	jalr	446(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    80001374:	00007517          	auipc	a0,0x7
    80001378:	dec50513          	addi	a0,a0,-532 # 80008160 <digits+0x120>
    8000137c:	fffff097          	auipc	ra,0xfffff
    80001380:	1ae080e7          	jalr	430(ra) # 8000052a <panic>
    deletePage(a);
    80001384:	854a                	mv	a0,s2
    80001386:	00000097          	auipc	ra,0x0
    8000138a:	edc080e7          	jalr	-292(ra) # 80001262 <deletePage>
    *pte = 0;
    8000138e:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001392:	995a                	add	s2,s2,s6
    80001394:	f93972e3          	bgeu	s2,s3,80001318 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001398:	4601                	li	a2,0
    8000139a:	85ca                	mv	a1,s2
    8000139c:	8552                	mv	a0,s4
    8000139e:	00000097          	auipc	ra,0x0
    800013a2:	c28080e7          	jalr	-984(ra) # 80000fc6 <walk>
    800013a6:	84aa                	mv	s1,a0
    800013a8:	d959                	beqz	a0,8000133e <uvmunmap+0x56>
    if((*pte & PTE_V) == 0){
    800013aa:	611c                	ld	a5,0(a0)
    800013ac:	0017f713          	andi	a4,a5,1
    800013b0:	df59                	beqz	a4,8000134e <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013b2:	3ff7f713          	andi	a4,a5,1023
    800013b6:	fb770fe3          	beq	a4,s7,80001374 <uvmunmap+0x8c>
    if(do_free && ((*pte & PTE_PG)==0)){
    800013ba:	fc0a85e3          	beqz	s5,80001384 <uvmunmap+0x9c>
    800013be:	2007f713          	andi	a4,a5,512
    800013c2:	f369                	bnez	a4,80001384 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
    800013c4:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800013c6:	00c79513          	slli	a0,a5,0xc
    800013ca:	fffff097          	auipc	ra,0xfffff
    800013ce:	60c080e7          	jalr	1548(ra) # 800009d6 <kfree>
    800013d2:	bf4d                	j	80001384 <uvmunmap+0x9c>

00000000800013d4 <swap>:

//sort the page array functions
void swap(int* xp, int* yp)
{
    800013d4:	1141                	addi	sp,sp,-16
    800013d6:	e422                	sd	s0,8(sp)
    800013d8:	0800                	addi	s0,sp,16
    int temp = *xp;
    800013da:	411c                	lw	a5,0(a0)
    *xp = *yp;
    800013dc:	4198                	lw	a4,0(a1)
    800013de:	c118                	sw	a4,0(a0)
    *yp = temp;
    800013e0:	c19c                	sw	a5,0(a1)
}
    800013e2:	6422                	ld	s0,8(sp)
    800013e4:	0141                	addi	sp,sp,16
    800013e6:	8082                	ret

00000000800013e8 <selectionSort>:
 
// Function to perform Selection Sort
void selectionSort(int arr[], int n)
{
    800013e8:	1141                	addi	sp,sp,-16
    800013ea:	e422                	sd	s0,8(sp)
    800013ec:	0800                	addi	s0,sp,16
    int i, j, min_idx;
 
    // One by one move boundary of unsorted subarray
    for (i = 0; i < n - 1; i++) {
    800013ee:	4785                	li	a5,1
    800013f0:	04b7d863          	bge	a5,a1,80001440 <selectionSort+0x58>
    800013f4:	00450313          	addi	t1,a0,4
    800013f8:	fff58e1b          	addiw	t3,a1,-1
    800013fc:	4881                	li	a7,0
    800013fe:	a815                	j	80001432 <selectionSort+0x4a>
 
        // Find the minimum element in unsorted array
        min_idx = i;
        for (j = i + 1; j < n; j++)
    80001400:	2705                	addiw	a4,a4,1
    80001402:	0691                	addi	a3,a3,4
    80001404:	00e58c63          	beq	a1,a4,8000141c <selectionSort+0x34>
            if (arr[j] < arr[min_idx])
    80001408:	00261793          	slli	a5,a2,0x2
    8000140c:	97aa                	add	a5,a5,a0
    8000140e:	0006a803          	lw	a6,0(a3) # 1000 <_entry-0x7ffff000>
    80001412:	439c                	lw	a5,0(a5)
    80001414:	fef856e3          	bge	a6,a5,80001400 <selectionSort+0x18>
    80001418:	863a                	mv	a2,a4
    8000141a:	b7dd                	j	80001400 <selectionSort+0x18>
                min_idx = j;
 
        // Swap the found minimum element
        // with the first element
        swap(&arr[min_idx], &arr[i]);
    8000141c:	060a                	slli	a2,a2,0x2
    8000141e:	962a                	add	a2,a2,a0
    int temp = *xp;
    80001420:	421c                	lw	a5,0(a2)
    *xp = *yp;
    80001422:	ffc32703          	lw	a4,-4(t1)
    80001426:	c218                	sw	a4,0(a2)
    *yp = temp;
    80001428:	fef32e23          	sw	a5,-4(t1)
    for (i = 0; i < n - 1; i++) {
    8000142c:	0311                	addi	t1,t1,4
    8000142e:	01c88963          	beq	a7,t3,80001440 <selectionSort+0x58>
        for (j = i + 1; j < n; j++)
    80001432:	8646                	mv	a2,a7
    80001434:	2885                	addiw	a7,a7,1
    80001436:	feb8d3e3          	bge	a7,a1,8000141c <selectionSort+0x34>
    8000143a:	869a                	mv	a3,t1
    8000143c:	8746                	mv	a4,a7
    8000143e:	b7e9                	j	80001408 <selectionSort+0x20>
    }
}
    80001440:	6422                	ld	s0,8(sp)
    80001442:	0141                	addi	sp,sp,16
    80001444:	8082                	ret

0000000080001446 <chooseBySCFIFO>:

// assume all the age is initialize counter from 1 -15, takes the biggest
int chooseBySCFIFO(){
    80001446:	7109                	addi	sp,sp,-384
    80001448:	fe86                	sd	ra,376(sp)
    8000144a:	faa2                	sd	s0,368(sp)
    8000144c:	f6a6                	sd	s1,360(sp)
    8000144e:	f2ca                	sd	s2,352(sp)
    80001450:	eece                	sd	s3,344(sp)
    80001452:	ead2                	sd	s4,336(sp)
    80001454:	e6d6                	sd	s5,328(sp)
    80001456:	e2da                	sd	s6,320(sp)
    80001458:	0300                	addi	s0,sp,384
  struct proc *p = myproc();
    8000145a:	00001097          	auipc	ra,0x1
    8000145e:	9e6080e7          	jalr	-1562(ra) # 80001e40 <myproc>
    80001462:	892a                	mv	s2,a0
  int ages[16];
  struct page queue[MAX_PSYC_PAGES];
  
  for(int i=0; i<MAX_PSYC_PAGES;i++){
    80001464:	17c50993          	addi	s3,a0,380
    80001468:	f8040493          	addi	s1,s0,-128
    8000146c:	fc040613          	addi	a2,s0,-64
  struct proc *p = myproc();
    80001470:	87a6                	mv	a5,s1
    80001472:	874e                	mv	a4,s3
    ages[i] = p->pages_in_ram[i].age;
    80001474:	4314                	lw	a3,0(a4)
    80001476:	c394                	sw	a3,0(a5)
  for(int i=0; i<MAX_PSYC_PAGES;i++){
    80001478:	0741                	addi	a4,a4,16
    8000147a:	0791                	addi	a5,a5,4
    8000147c:	fec79ce3          	bne	a5,a2,80001474 <chooseBySCFIFO+0x2e>
  }
  
  selectionSort(ages,MAX_PSYC_PAGES); // sort the ages array
    80001480:	45c1                	li	a1,16
    80001482:	f8040513          	addi	a0,s0,-128
    80001486:	00000097          	auipc	ra,0x0
    8000148a:	f62080e7          	jalr	-158(ra) # 800013e8 <selectionSort>
  
  for(int i=0; i<MAX_PSYC_PAGES;i++){
    8000148e:	e8040a13          	addi	s4,s0,-384
    80001492:	f8040513          	addi	a0,s0,-128
  selectionSort(ages,MAX_PSYC_PAGES); // sort the ages array
    80001496:	85d2                	mv	a1,s4
    80001498:	27090613          	addi	a2,s2,624
    8000149c:	a005                	j	800014bc <chooseBySCFIFO+0x76>
    int temp = ages[i];
    for(int j=0;j<MAX_PSYC_PAGES;j++){
    8000149e:	07c1                	addi	a5,a5,16
    800014a0:	00c78a63          	beq	a5,a2,800014b4 <chooseBySCFIFO+0x6e>
      if(p->pages_in_ram[j].age == temp)
    800014a4:	47d8                	lw	a4,12(a5)
    800014a6:	fed71ce3          	bne	a4,a3,8000149e <chooseBySCFIFO+0x58>
        queue[i] = p->pages_in_ram[j];
    800014aa:	6398                	ld	a4,0(a5)
    800014ac:	e198                	sd	a4,0(a1)
    800014ae:	6798                	ld	a4,8(a5)
    800014b0:	e598                	sd	a4,8(a1)
    800014b2:	b7f5                	j	8000149e <chooseBySCFIFO+0x58>
  for(int i=0; i<MAX_PSYC_PAGES;i++){
    800014b4:	0491                	addi	s1,s1,4
    800014b6:	05c1                	addi	a1,a1,16
    800014b8:	00a58663          	beq	a1,a0,800014c4 <chooseBySCFIFO+0x7e>
    for(int j=0;j<MAX_PSYC_PAGES;j++){
    800014bc:	17090793          	addi	a5,s2,368
      if(p->pages_in_ram[j].age == temp)
    800014c0:	4094                	lw	a3,0(s1)
    800014c2:	b7cd                	j	800014a4 <chooseBySCFIFO+0x5e>
    800014c4:	4b09                	li	s6,2
      if(*pte & PTE_A){
        //PTE_A is on so second chance
        *pte &=~PTE_A;
      }
      else{
          for(int j=0; j<MAX_PSYC_PAGES;j++){
    800014c6:	4ac1                	li	s5,16
    for(int i=MAX_PSYC_PAGES-1; i>=0; i--){ // run from 15 to 0
    800014c8:	f7040493          	addi	s1,s0,-144
    800014cc:	a005                	j	800014ec <chooseBySCFIFO+0xa6>
            if(queue[i].age == p->pages_in_ram[j].age){
    800014ce:	44d4                	lw	a3,12(s1)
    800014d0:	87ce                	mv	a5,s3
          for(int j=0; j<MAX_PSYC_PAGES;j++){
    800014d2:	4501                	li	a0,0
            if(queue[i].age == p->pages_in_ram[j].age){
    800014d4:	4398                	lw	a4,0(a5)
    800014d6:	02d70f63          	beq	a4,a3,80001514 <chooseBySCFIFO+0xce>
          for(int j=0; j<MAX_PSYC_PAGES;j++){
    800014da:	2505                	addiw	a0,a0,1
    800014dc:	07c1                	addi	a5,a5,16
    800014de:	ff551be3          	bne	a0,s5,800014d4 <chooseBySCFIFO+0x8e>
    for(int i=MAX_PSYC_PAGES-1; i>=0; i--){ // run from 15 to 0
    800014e2:	ff048793          	addi	a5,s1,-16
    800014e6:	03448363          	beq	s1,s4,8000150c <chooseBySCFIFO+0xc6>
    800014ea:	84be                	mv	s1,a5
      pte_t *pte = walk(p->pagetable,queue[i].va,0);
    800014ec:	4601                	li	a2,0
    800014ee:	608c                	ld	a1,0(s1)
    800014f0:	05093503          	ld	a0,80(s2)
    800014f4:	00000097          	auipc	ra,0x0
    800014f8:	ad2080e7          	jalr	-1326(ra) # 80000fc6 <walk>
      if(*pte & PTE_A){
    800014fc:	611c                	ld	a5,0(a0)
    800014fe:	0407f713          	andi	a4,a5,64
    80001502:	d771                	beqz	a4,800014ce <chooseBySCFIFO+0x88>
        *pte &=~PTE_A;
    80001504:	fbf7f793          	andi	a5,a5,-65
    80001508:	e11c                	sd	a5,0(a0)
    8000150a:	bfe1                	j	800014e2 <chooseBySCFIFO+0x9c>
  while(counter < 2){
    8000150c:	3b7d                	addiw	s6,s6,-1
    8000150e:	fa0b1de3          	bnez	s6,800014c8 <chooseBySCFIFO+0x82>
          }
        }
    }
    counter++;
  }
  return -1; // cant happend
    80001512:	557d                	li	a0,-1
}
    80001514:	70f6                	ld	ra,376(sp)
    80001516:	7456                	ld	s0,368(sp)
    80001518:	74b6                	ld	s1,360(sp)
    8000151a:	7916                	ld	s2,352(sp)
    8000151c:	69f6                	ld	s3,344(sp)
    8000151e:	6a56                	ld	s4,336(sp)
    80001520:	6ab6                	ld	s5,328(sp)
    80001522:	6b16                	ld	s6,320(sp)
    80001524:	6119                	addi	sp,sp,384
    80001526:	8082                	ret

0000000080001528 <chooseByNFUA>:


// assume all the age is initialize with 0
//asume all pages are not free , becuase we need to switch pages from ram to disk
// need to update the age
int chooseByNFUA(){
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001530:	00001097          	auipc	ra,0x1
    80001534:	910080e7          	jalr	-1776(ra) # 80001e40 <myproc>
    80001538:	872a                	mv	a4,a0
  int minIndex = p->pages_in_ram[0].age;
    8000153a:	17c52503          	lw	a0,380(a0)
  for(int i=1; i<MAX_PSYC_PAGES; i++){
    8000153e:	18c70713          	addi	a4,a4,396 # fffffffffffff18c <end+0xffffffff7ffd118c>
    80001542:	4785                	li	a5,1
    80001544:	45c1                	li	a1,16
    80001546:	a029                	j	80001550 <chooseByNFUA+0x28>
    80001548:	2785                	addiw	a5,a5,1
    8000154a:	0741                	addi	a4,a4,16
    8000154c:	00b78963          	beq	a5,a1,8000155e <chooseByNFUA+0x36>
    if(p->pages_in_ram[i].age < minIndex){
    80001550:	4310                	lw	a2,0(a4)
    80001552:	0005069b          	sext.w	a3,a0
    80001556:	fed679e3          	bgeu	a2,a3,80001548 <chooseByNFUA+0x20>
    8000155a:	853e                	mv	a0,a5
    8000155c:	b7f5                	j	80001548 <chooseByNFUA+0x20>
      minIndex = i;
    }
  }
  return minIndex;

}
    8000155e:	60a2                	ld	ra,8(sp)
    80001560:	6402                	ld	s0,0(sp)
    80001562:	0141                	addi	sp,sp,16
    80001564:	8082                	ret

0000000080001566 <numberOfOnes>:

int numberOfOnes(int num){
    80001566:	1141                	addi	sp,sp,-16
    80001568:	e422                	sd	s0,8(sp)
    8000156a:	0800                	addi	s0,sp,16
    8000156c:	87aa                	mv	a5,a0
  int numOfOnes =0;
  while (num != 0){
    8000156e:	cd11                	beqz	a0,8000158a <numberOfOnes+0x24>
  int numOfOnes =0;
    80001570:	4501                	li	a0,0
    80001572:	a039                	j	80001580 <numberOfOnes+0x1a>
    if ((num & 1) == 1){
      numOfOnes++;
    }
    // num = num/10;
    num = num/2; //todo
    80001574:	01f7d71b          	srliw	a4,a5,0x1f
    80001578:	9fb9                	addw	a5,a5,a4
    8000157a:	4017d79b          	sraiw	a5,a5,0x1
  while (num != 0){
    8000157e:	c791                	beqz	a5,8000158a <numberOfOnes+0x24>
    if ((num & 1) == 1){
    80001580:	0017f713          	andi	a4,a5,1
    80001584:	db65                	beqz	a4,80001574 <numberOfOnes+0xe>
      numOfOnes++;
    80001586:	2505                	addiw	a0,a0,1
    80001588:	b7f5                	j	80001574 <numberOfOnes+0xe>
  }
  return numOfOnes;
} 
    8000158a:	6422                	ld	s0,8(sp)
    8000158c:	0141                	addi	sp,sp,16
    8000158e:	8082                	ret

0000000080001590 <chooseByLAPA>:

// assume all the age is initialize with -1 = 0xffffffff
//asume all pages are not free , becuase we need to switch pages from ram to disk
// need to update the age
int chooseByLAPA(){
    80001590:	715d                	addi	sp,sp,-80
    80001592:	e486                	sd	ra,72(sp)
    80001594:	e0a2                	sd	s0,64(sp)
    80001596:	fc26                	sd	s1,56(sp)
    80001598:	f84a                	sd	s2,48(sp)
    8000159a:	f44e                	sd	s3,40(sp)
    8000159c:	f052                	sd	s4,32(sp)
    8000159e:	ec56                	sd	s5,24(sp)
    800015a0:	e85a                	sd	s6,16(sp)
    800015a2:	e45e                	sd	s7,8(sp)
    800015a4:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    800015a6:	00001097          	auipc	ra,0x1
    800015aa:	89a080e7          	jalr	-1894(ra) # 80001e40 <myproc>
    800015ae:	8baa                	mv	s7,a0
  int minNumOfOnes = numberOfOnes(p->pages_in_ram[0].age);
    800015b0:	17c52b03          	lw	s6,380(a0)
    800015b4:	855a                	mv	a0,s6
    800015b6:	00000097          	auipc	ra,0x0
    800015ba:	fb0080e7          	jalr	-80(ra) # 80001566 <numberOfOnes>
    800015be:	89aa                	mv	s3,a0
  int minIndex = p->pages_in_ram[0].age;
  for(int i=1; i<MAX_PSYC_PAGES; i++){
    800015c0:	18cb8913          	addi	s2,s7,396 # 118c <_entry-0x7fffee74>
    800015c4:	4485                	li	s1,1
    800015c6:	4ac1                	li	s5,16
    800015c8:	a039                	j	800015d6 <chooseByLAPA+0x46>
    800015ca:	8b26                	mv	s6,s1
    int onesAmount = numberOfOnes(p->pages_in_ram[i].age);
    if(onesAmount < minNumOfOnes){
      minNumOfOnes = onesAmount;
    800015cc:	89aa                	mv	s3,a0
  for(int i=1; i<MAX_PSYC_PAGES; i++){
    800015ce:	2485                	addiw	s1,s1,1
    800015d0:	0941                	addi	s2,s2,16
    800015d2:	03548663          	beq	s1,s5,800015fe <chooseByLAPA+0x6e>
    int onesAmount = numberOfOnes(p->pages_in_ram[i].age);
    800015d6:	00092a03          	lw	s4,0(s2)
    800015da:	8552                	mv	a0,s4
    800015dc:	00000097          	auipc	ra,0x0
    800015e0:	f8a080e7          	jalr	-118(ra) # 80001566 <numberOfOnes>
    if(onesAmount < minNumOfOnes){
    800015e4:	ff3543e3          	blt	a0,s3,800015ca <chooseByLAPA+0x3a>
      minIndex = i;
    }
    else if(onesAmount == minNumOfOnes){ //same amount of ones in age - take the lower age
    800015e8:	ff3513e3          	bne	a0,s3,800015ce <chooseByLAPA+0x3e>
      if(p->pages_in_ram[i].age < p->pages_in_ram[minIndex].age){
    800015ec:	017b0793          	addi	a5,s6,23 # 1017 <_entry-0x7fffefe9>
    800015f0:	0792                	slli	a5,a5,0x4
    800015f2:	97de                	add	a5,a5,s7
    800015f4:	47dc                	lw	a5,12(a5)
    800015f6:	fcfa7ce3          	bgeu	s4,a5,800015ce <chooseByLAPA+0x3e>
    800015fa:	8b26                	mv	s6,s1
    800015fc:	bfc9                	j	800015ce <chooseByLAPA+0x3e>
        minIndex = i;
      }
    }
  }
  return minIndex;
}
    800015fe:	855a                	mv	a0,s6
    80001600:	60a6                	ld	ra,72(sp)
    80001602:	6406                	ld	s0,64(sp)
    80001604:	74e2                	ld	s1,56(sp)
    80001606:	7942                	ld	s2,48(sp)
    80001608:	79a2                	ld	s3,40(sp)
    8000160a:	7a02                	ld	s4,32(sp)
    8000160c:	6ae2                	ld	s5,24(sp)
    8000160e:	6b42                	ld	s6,16(sp)
    80001610:	6ba2                	ld	s7,8(sp)
    80001612:	6161                	addi	sp,sp,80
    80001614:	8082                	ret

0000000080001616 <choosePageIndexToSwap>:

int choosePageIndexToSwap(){
    80001616:	1141                	addi	sp,sp,-16
    80001618:	e406                	sd	ra,8(sp)
    8000161a:	e022                	sd	s0,0(sp)
    8000161c:	0800                	addi	s0,sp,16
  if(SELECTION == SCFIFO)
    return chooseBySCFIFO();
    8000161e:	00000097          	auipc	ra,0x0
    80001622:	e28080e7          	jalr	-472(ra) # 80001446 <chooseBySCFIFO>

  if(SELECTION == LAPA)
    return chooseByLAPA();
  
  return -1;
}
    80001626:	60a2                	ld	ra,8(sp)
    80001628:	6402                	ld	s0,0(sp)
    8000162a:	0141                	addi	sp,sp,16
    8000162c:	8082                	ret

000000008000162e <swapPageToFile>:

void swapPageToFile(){
    8000162e:	7179                	addi	sp,sp,-48
    80001630:	f406                	sd	ra,40(sp)
    80001632:	f022                	sd	s0,32(sp)
    80001634:	ec26                	sd	s1,24(sp)
    80001636:	e84a                	sd	s2,16(sp)
    80001638:	e44e                	sd	s3,8(sp)
    8000163a:	e052                	sd	s4,0(sp)
    8000163c:	1800                	addi	s0,sp,48

  
  struct proc *p = myproc();
    8000163e:	00001097          	auipc	ra,0x1
    80001642:	802080e7          	jalr	-2046(ra) # 80001e40 <myproc>
    80001646:	84aa                	mv	s1,a0
    return chooseBySCFIFO();
    80001648:	00000097          	auipc	ra,0x0
    8000164c:	dfe080e7          	jalr	-514(ra) # 80001446 <chooseBySCFIFO>
  int indexToSwap = 0;
  indexToSwap = choosePageIndexToSwap();
  // indexToSwap=15;
  if(indexToSwap<0)
    80001650:	06054e63          	bltz	a0,800016cc <swapPageToFile+0x9e>
    80001654:	89aa                	mv	s3,a0
    panic("negative index\n");
  // else
  //   printf("chosenIndexToFreeInRam=%d\n", indexToSwap);

  pte_t *pte;
  pte = walk(p->pagetable, p->pages_in_ram[indexToSwap].va, 0);
    80001656:	00451a13          	slli	s4,a0,0x4
    8000165a:	9a26                	add	s4,s4,s1
    8000165c:	4601                	li	a2,0
    8000165e:	170a3583          	ld	a1,368(s4) # fffffffffffff170 <end+0xffffffff7ffd1170>
    80001662:	68a8                	ld	a0,80(s1)
    80001664:	00000097          	auipc	ra,0x0
    80001668:	962080e7          	jalr	-1694(ra) # 80000fc6 <walk>
    8000166c:	892a                	mv	s2,a0
  // *pte &= ~PTE_V; //turn off valid flag
  // *pte |=  PTE_PG; //turn on swapped flag
  // *pte = PTE2PA(*pte);
  writeToSwapFile(p, (char *)PTE2PA(*pte), indexToSwap*PGSIZE, PGSIZE);
    8000166e:	610c                	ld	a1,0(a0)
    80001670:	81a9                	srli	a1,a1,0xa
    80001672:	6685                	lui	a3,0x1
    80001674:	00c9961b          	slliw	a2,s3,0xc
    80001678:	05b2                	slli	a1,a1,0xc
    8000167a:	8526                	mv	a0,s1
    8000167c:	00003097          	auipc	ra,0x3
    80001680:	1a4080e7          	jalr	420(ra) # 80004820 <writeToSwapFile>

  p->pages_in_ram[indexToSwap].is_free = 1;
    80001684:	4785                	li	a5,1
    80001686:	16fa2c23          	sw	a5,376(s4)
  p->ram_pages_counter --;
    8000168a:	2704a783          	lw	a5,624(s1)
    8000168e:	37fd                	addiw	a5,a5,-1
    80001690:	26f4a823          	sw	a5,624(s1)
  
  p->pages_in_file_counter ++;
    80001694:	3784a783          	lw	a5,888(s1)
    80001698:	2785                	addiw	a5,a5,1
    8000169a:	36f4ac23          	sw	a5,888(s1)

  kfree((void*)PTE2PA(*pte));
    8000169e:	00093503          	ld	a0,0(s2)
    800016a2:	8129                	srli	a0,a0,0xa
    800016a4:	0532                	slli	a0,a0,0xc
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	330080e7          	jalr	816(ra) # 800009d6 <kfree>
  *pte &= ~PTE_V; //turn off valid flag
    800016ae:	00093783          	ld	a5,0(s2)
    800016b2:	9bf9                	andi	a5,a5,-2
  *pte |=  PTE_PG; //turn on swapped flag
    800016b4:	2007e793          	ori	a5,a5,512
    800016b8:	00f93023          	sd	a5,0(s2)
}
    800016bc:	70a2                	ld	ra,40(sp)
    800016be:	7402                	ld	s0,32(sp)
    800016c0:	64e2                	ld	s1,24(sp)
    800016c2:	6942                	ld	s2,16(sp)
    800016c4:	69a2                	ld	s3,8(sp)
    800016c6:	6a02                	ld	s4,0(sp)
    800016c8:	6145                	addi	sp,sp,48
    800016ca:	8082                	ret
    panic("negative index\n");
    800016cc:	00007517          	auipc	a0,0x7
    800016d0:	aac50513          	addi	a0,a0,-1364 # 80008178 <digits+0x138>
    800016d4:	fffff097          	auipc	ra,0xfffff
    800016d8:	e56080e7          	jalr	-426(ra) # 8000052a <panic>

00000000800016dc <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800016dc:	1101                	addi	sp,sp,-32
    800016de:	ec06                	sd	ra,24(sp)
    800016e0:	e822                	sd	s0,16(sp)
    800016e2:	e426                	sd	s1,8(sp)
    800016e4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800016e6:	fffff097          	auipc	ra,0xfffff
    800016ea:	40c080e7          	jalr	1036(ra) # 80000af2 <kalloc>
    800016ee:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800016f0:	c519                	beqz	a0,800016fe <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800016f2:	6605                	lui	a2,0x1
    800016f4:	4581                	li	a1,0
    800016f6:	fffff097          	auipc	ra,0xfffff
    800016fa:	5e8080e7          	jalr	1512(ra) # 80000cde <memset>
  return pagetable;
}
    800016fe:	8526                	mv	a0,s1
    80001700:	60e2                	ld	ra,24(sp)
    80001702:	6442                	ld	s0,16(sp)
    80001704:	64a2                	ld	s1,8(sp)
    80001706:	6105                	addi	sp,sp,32
    80001708:	8082                	ret

000000008000170a <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000170a:	7179                	addi	sp,sp,-48
    8000170c:	f406                	sd	ra,40(sp)
    8000170e:	f022                	sd	s0,32(sp)
    80001710:	ec26                	sd	s1,24(sp)
    80001712:	e84a                	sd	s2,16(sp)
    80001714:	e44e                	sd	s3,8(sp)
    80001716:	e052                	sd	s4,0(sp)
    80001718:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000171a:	6785                	lui	a5,0x1
    8000171c:	04f67863          	bgeu	a2,a5,8000176c <uvminit+0x62>
    80001720:	8a2a                	mv	s4,a0
    80001722:	89ae                	mv	s3,a1
    80001724:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001726:	fffff097          	auipc	ra,0xfffff
    8000172a:	3cc080e7          	jalr	972(ra) # 80000af2 <kalloc>
    8000172e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001730:	6605                	lui	a2,0x1
    80001732:	4581                	li	a1,0
    80001734:	fffff097          	auipc	ra,0xfffff
    80001738:	5aa080e7          	jalr	1450(ra) # 80000cde <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000173c:	4779                	li	a4,30
    8000173e:	86ca                	mv	a3,s2
    80001740:	6605                	lui	a2,0x1
    80001742:	4581                	li	a1,0
    80001744:	8552                	mv	a0,s4
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	968080e7          	jalr	-1688(ra) # 800010ae <mappages>
  memmove(mem, src, sz);
    8000174e:	8626                	mv	a2,s1
    80001750:	85ce                	mv	a1,s3
    80001752:	854a                	mv	a0,s2
    80001754:	fffff097          	auipc	ra,0xfffff
    80001758:	5e6080e7          	jalr	1510(ra) # 80000d3a <memmove>
}
    8000175c:	70a2                	ld	ra,40(sp)
    8000175e:	7402                	ld	s0,32(sp)
    80001760:	64e2                	ld	s1,24(sp)
    80001762:	6942                	ld	s2,16(sp)
    80001764:	69a2                	ld	s3,8(sp)
    80001766:	6a02                	ld	s4,0(sp)
    80001768:	6145                	addi	sp,sp,48
    8000176a:	8082                	ret
    panic("inituvm: more than a page");
    8000176c:	00007517          	auipc	a0,0x7
    80001770:	a1c50513          	addi	a0,a0,-1508 # 80008188 <digits+0x148>
    80001774:	fffff097          	auipc	ra,0xfffff
    80001778:	db6080e7          	jalr	-586(ra) # 8000052a <panic>

000000008000177c <allocPage>:

/*alocates a new page to my proc*/
void allocPage(uint64 va){
    8000177c:	1101                	addi	sp,sp,-32
    8000177e:	ec06                	sd	ra,24(sp)
    80001780:	e822                	sd	s0,16(sp)
    80001782:	e426                	sd	s1,8(sp)
    80001784:	e04a                	sd	s2,0(sp)
    80001786:	1000                	addi	s0,sp,32
    80001788:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000178a:	00000097          	auipc	ra,0x0
    8000178e:	6b6080e7          	jalr	1718(ra) # 80001e40 <myproc>
  


  if(  (p->ram_pages_counter + p->pages_in_file_counter ) == MAX_TOTAL_PAGES)
    80001792:	27052703          	lw	a4,624(a0)
    80001796:	37852783          	lw	a5,888(a0)
    8000179a:	9fb9                	addw	a5,a5,a4
    8000179c:	02000693          	li	a3,32
    800017a0:	04d78063          	beq	a5,a3,800017e0 <allocPage+0x64>
    800017a4:	84aa                	mv	s1,a0
    panic("a process cannot have more than 32 pages");
  
  if(p->ram_pages_counter == MAX_PSYC_PAGES){
    800017a6:	47c1                	li	a5,16
    800017a8:	04f70463          	beq	a4,a5,800017f0 <allocPage+0x74>
    printf("allocPage: 16 pages in ram\n");
    swapPageToFile();
  }

  
  for(int i=0; i<MAX_PSYC_PAGES; i++){
    800017ac:	17848713          	addi	a4,s1,376
    800017b0:	4781                	li	a5,0
    800017b2:	4641                	li	a2,16
    if(p->pages_in_ram[i].is_free == 0)
    800017b4:	4314                	lw	a3,0(a4)
    800017b6:	cab1                	beqz	a3,8000180a <allocPage+0x8e>
      continue;
    p->pages_in_ram[i].is_free = 0;
    800017b8:	0792                	slli	a5,a5,0x4
    800017ba:	97a6                	add	a5,a5,s1
    800017bc:	1607ac23          	sw	zero,376(a5) # 1178 <_entry-0x7fffee88>
    p->pages_in_ram[i].va = va;
    800017c0:	1727b823          	sd	s2,368(a5)

    //ADDED by gal - talk to lidor, saw this in allocproc

    if(SELECTION == NFUA || SELECTION == SCFIFO)
          p->pages_in_ram[i].age = 0;
    800017c4:	1607ae23          	sw	zero,380(a5)
    if(SELECTION == LAPA)
          p->pages_in_ram[i].age = -1; // 0xffffffff

    //ADDED END

    p->ram_pages_counter ++ ;
    800017c8:	2704a783          	lw	a5,624(s1)
    800017cc:	2785                	addiw	a5,a5,1
    800017ce:	26f4a823          	sw	a5,624(s1)

    //todo: check if in SCFIFO mode and act accordingly
    if(SELECTION == SCFIFO){
      for(int i=0; i<MAX_PSYC_PAGES; i++){
    800017d2:	17c48793          	addi	a5,s1,380
    800017d6:	27c48693          	addi	a3,s1,636
        if(p->pages_in_ram[i].is_free == 0){
          p->pages_in_ram[i].age >>= 1;
          p->pages_in_ram[i].age = p->pages_in_ram[i].age | 0x80000000;
    800017da:	80000637          	lui	a2,0x80000
    800017de:	a099                	j	80001824 <allocPage+0xa8>
    panic("a process cannot have more than 32 pages");
    800017e0:	00007517          	auipc	a0,0x7
    800017e4:	9c850513          	addi	a0,a0,-1592 # 800081a8 <digits+0x168>
    800017e8:	fffff097          	auipc	ra,0xfffff
    800017ec:	d42080e7          	jalr	-702(ra) # 8000052a <panic>
    printf("allocPage: 16 pages in ram\n");
    800017f0:	00007517          	auipc	a0,0x7
    800017f4:	9e850513          	addi	a0,a0,-1560 # 800081d8 <digits+0x198>
    800017f8:	fffff097          	auipc	ra,0xfffff
    800017fc:	d7c080e7          	jalr	-644(ra) # 80000574 <printf>
    swapPageToFile();
    80001800:	00000097          	auipc	ra,0x0
    80001804:	e2e080e7          	jalr	-466(ra) # 8000162e <swapPageToFile>
    80001808:	b755                	j	800017ac <allocPage+0x30>
  for(int i=0; i<MAX_PSYC_PAGES; i++){
    8000180a:	2785                	addiw	a5,a5,1
    8000180c:	0741                	addi	a4,a4,16
    8000180e:	fac793e3          	bne	a5,a2,800017b4 <allocPage+0x38>
    }


    return;
  }
}
    80001812:	60e2                	ld	ra,24(sp)
    80001814:	6442                	ld	s0,16(sp)
    80001816:	64a2                	ld	s1,8(sp)
    80001818:	6902                	ld	s2,0(sp)
    8000181a:	6105                	addi	sp,sp,32
    8000181c:	8082                	ret
      for(int i=0; i<MAX_PSYC_PAGES; i++){
    8000181e:	07c1                	addi	a5,a5,16
    80001820:	fed789e3          	beq	a5,a3,80001812 <allocPage+0x96>
        if(p->pages_in_ram[i].is_free == 0){
    80001824:	ffc7a703          	lw	a4,-4(a5)
    80001828:	fb7d                	bnez	a4,8000181e <allocPage+0xa2>
          p->pages_in_ram[i].age >>= 1;
    8000182a:	4398                	lw	a4,0(a5)
    8000182c:	0017571b          	srliw	a4,a4,0x1
          p->pages_in_ram[i].age = p->pages_in_ram[i].age | 0x80000000;
    80001830:	8f51                	or	a4,a4,a2
    80001832:	c398                	sw	a4,0(a5)
    80001834:	b7ed                	j	8000181e <allocPage+0xa2>

0000000080001836 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001836:	1101                	addi	sp,sp,-32
    80001838:	ec06                	sd	ra,24(sp)
    8000183a:	e822                	sd	s0,16(sp)
    8000183c:	e426                	sd	s1,8(sp)
    8000183e:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001840:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001842:	00b67d63          	bgeu	a2,a1,8000185c <uvmdealloc+0x26>
    80001846:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001848:	6785                	lui	a5,0x1
    8000184a:	17fd                	addi	a5,a5,-1
    8000184c:	00f60733          	add	a4,a2,a5
    80001850:	767d                	lui	a2,0xfffff
    80001852:	8f71                	and	a4,a4,a2
    80001854:	97ae                	add	a5,a5,a1
    80001856:	8ff1                	and	a5,a5,a2
    80001858:	00f76863          	bltu	a4,a5,80001868 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000185c:	8526                	mv	a0,s1
    8000185e:	60e2                	ld	ra,24(sp)
    80001860:	6442                	ld	s0,16(sp)
    80001862:	64a2                	ld	s1,8(sp)
    80001864:	6105                	addi	sp,sp,32
    80001866:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001868:	8f99                	sub	a5,a5,a4
    8000186a:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000186c:	4685                	li	a3,1
    8000186e:	0007861b          	sext.w	a2,a5
    80001872:	85ba                	mv	a1,a4
    80001874:	00000097          	auipc	ra,0x0
    80001878:	a74080e7          	jalr	-1420(ra) # 800012e8 <uvmunmap>
    8000187c:	b7c5                	j	8000185c <uvmdealloc+0x26>

000000008000187e <uvmalloc>:
  if(newsz < oldsz)
    8000187e:	0cb66263          	bltu	a2,a1,80001942 <uvmalloc+0xc4>
{
    80001882:	7139                	addi	sp,sp,-64
    80001884:	fc06                	sd	ra,56(sp)
    80001886:	f822                	sd	s0,48(sp)
    80001888:	f426                	sd	s1,40(sp)
    8000188a:	f04a                	sd	s2,32(sp)
    8000188c:	ec4e                	sd	s3,24(sp)
    8000188e:	e852                	sd	s4,16(sp)
    80001890:	e456                	sd	s5,8(sp)
    80001892:	e05a                	sd	s6,0(sp)
    80001894:	0080                	addi	s0,sp,64
    80001896:	8a2a                	mv	s4,a0
    80001898:	8ab2                	mv	s5,a2
  oldsz = PGROUNDUP(oldsz);
    8000189a:	6985                	lui	s3,0x1
    8000189c:	19fd                	addi	s3,s3,-1
    8000189e:	95ce                	add	a1,a1,s3
    800018a0:	79fd                	lui	s3,0xfffff
    800018a2:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800018a6:	0ac9f063          	bgeu	s3,a2,80001946 <uvmalloc+0xc8>
    800018aa:	894e                	mv	s2,s3
    if(myproc()->pid >= 3){
    800018ac:	4b09                	li	s6,2
    800018ae:	a0a9                	j	800018f8 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    800018b0:	864e                	mv	a2,s3
    800018b2:	85ca                	mv	a1,s2
    800018b4:	8552                	mv	a0,s4
    800018b6:	00000097          	auipc	ra,0x0
    800018ba:	f80080e7          	jalr	-128(ra) # 80001836 <uvmdealloc>
      return 0;
    800018be:	4501                	li	a0,0
}
    800018c0:	70e2                	ld	ra,56(sp)
    800018c2:	7442                	ld	s0,48(sp)
    800018c4:	74a2                	ld	s1,40(sp)
    800018c6:	7902                	ld	s2,32(sp)
    800018c8:	69e2                	ld	s3,24(sp)
    800018ca:	6a42                	ld	s4,16(sp)
    800018cc:	6aa2                	ld	s5,8(sp)
    800018ce:	6b02                	ld	s6,0(sp)
    800018d0:	6121                	addi	sp,sp,64
    800018d2:	8082                	ret
      kfree(mem);
    800018d4:	8526                	mv	a0,s1
    800018d6:	fffff097          	auipc	ra,0xfffff
    800018da:	100080e7          	jalr	256(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800018de:	864e                	mv	a2,s3
    800018e0:	85ca                	mv	a1,s2
    800018e2:	8552                	mv	a0,s4
    800018e4:	00000097          	auipc	ra,0x0
    800018e8:	f52080e7          	jalr	-174(ra) # 80001836 <uvmdealloc>
      return 0;
    800018ec:	4501                	li	a0,0
    800018ee:	bfc9                	j	800018c0 <uvmalloc+0x42>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800018f0:	6785                	lui	a5,0x1
    800018f2:	993e                	add	s2,s2,a5
    800018f4:	05597563          	bgeu	s2,s5,8000193e <uvmalloc+0xc0>
    mem = kalloc();
    800018f8:	fffff097          	auipc	ra,0xfffff
    800018fc:	1fa080e7          	jalr	506(ra) # 80000af2 <kalloc>
    80001900:	84aa                	mv	s1,a0
    if(mem == 0){
    80001902:	d55d                	beqz	a0,800018b0 <uvmalloc+0x32>
    memset(mem, 0, PGSIZE);
    80001904:	6605                	lui	a2,0x1
    80001906:	4581                	li	a1,0
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	3d6080e7          	jalr	982(ra) # 80000cde <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001910:	4779                	li	a4,30
    80001912:	86a6                	mv	a3,s1
    80001914:	6605                	lui	a2,0x1
    80001916:	85ca                	mv	a1,s2
    80001918:	8552                	mv	a0,s4
    8000191a:	fffff097          	auipc	ra,0xfffff
    8000191e:	794080e7          	jalr	1940(ra) # 800010ae <mappages>
    80001922:	f94d                	bnez	a0,800018d4 <uvmalloc+0x56>
    if(myproc()->pid >= 3){
    80001924:	00000097          	auipc	ra,0x0
    80001928:	51c080e7          	jalr	1308(ra) # 80001e40 <myproc>
    8000192c:	591c                	lw	a5,48(a0)
    8000192e:	fcfb51e3          	bge	s6,a5,800018f0 <uvmalloc+0x72>
      allocPage(a);
    80001932:	854a                	mv	a0,s2
    80001934:	00000097          	auipc	ra,0x0
    80001938:	e48080e7          	jalr	-440(ra) # 8000177c <allocPage>
    8000193c:	bf55                	j	800018f0 <uvmalloc+0x72>
  return newsz;
    8000193e:	8556                	mv	a0,s5
    80001940:	b741                	j	800018c0 <uvmalloc+0x42>
    return oldsz;
    80001942:	852e                	mv	a0,a1
}
    80001944:	8082                	ret
  return newsz;
    80001946:	8532                	mv	a0,a2
    80001948:	bfa5                	j	800018c0 <uvmalloc+0x42>

000000008000194a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000194a:	7179                	addi	sp,sp,-48
    8000194c:	f406                	sd	ra,40(sp)
    8000194e:	f022                	sd	s0,32(sp)
    80001950:	ec26                	sd	s1,24(sp)
    80001952:	e84a                	sd	s2,16(sp)
    80001954:	e44e                	sd	s3,8(sp)
    80001956:	e052                	sd	s4,0(sp)
    80001958:	1800                	addi	s0,sp,48
    8000195a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000195c:	84aa                	mv	s1,a0
    8000195e:	6905                	lui	s2,0x1
    80001960:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001962:	4985                	li	s3,1
    80001964:	a821                	j	8000197c <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001966:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001968:	0532                	slli	a0,a0,0xc
    8000196a:	00000097          	auipc	ra,0x0
    8000196e:	fe0080e7          	jalr	-32(ra) # 8000194a <freewalk>
      pagetable[i] = 0;
    80001972:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001976:	04a1                	addi	s1,s1,8
    80001978:	03248163          	beq	s1,s2,8000199a <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000197c:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000197e:	00f57793          	andi	a5,a0,15
    80001982:	ff3782e3          	beq	a5,s3,80001966 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001986:	8905                	andi	a0,a0,1
    80001988:	d57d                	beqz	a0,80001976 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000198a:	00007517          	auipc	a0,0x7
    8000198e:	86e50513          	addi	a0,a0,-1938 # 800081f8 <digits+0x1b8>
    80001992:	fffff097          	auipc	ra,0xfffff
    80001996:	b98080e7          	jalr	-1128(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    8000199a:	8552                	mv	a0,s4
    8000199c:	fffff097          	auipc	ra,0xfffff
    800019a0:	03a080e7          	jalr	58(ra) # 800009d6 <kfree>
}
    800019a4:	70a2                	ld	ra,40(sp)
    800019a6:	7402                	ld	s0,32(sp)
    800019a8:	64e2                	ld	s1,24(sp)
    800019aa:	6942                	ld	s2,16(sp)
    800019ac:	69a2                	ld	s3,8(sp)
    800019ae:	6a02                	ld	s4,0(sp)
    800019b0:	6145                	addi	sp,sp,48
    800019b2:	8082                	ret

00000000800019b4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800019b4:	1101                	addi	sp,sp,-32
    800019b6:	ec06                	sd	ra,24(sp)
    800019b8:	e822                	sd	s0,16(sp)
    800019ba:	e426                	sd	s1,8(sp)
    800019bc:	1000                	addi	s0,sp,32
    800019be:	84aa                	mv	s1,a0
  if(sz > 0)
    800019c0:	e999                	bnez	a1,800019d6 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800019c2:	8526                	mv	a0,s1
    800019c4:	00000097          	auipc	ra,0x0
    800019c8:	f86080e7          	jalr	-122(ra) # 8000194a <freewalk>
}
    800019cc:	60e2                	ld	ra,24(sp)
    800019ce:	6442                	ld	s0,16(sp)
    800019d0:	64a2                	ld	s1,8(sp)
    800019d2:	6105                	addi	sp,sp,32
    800019d4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800019d6:	6605                	lui	a2,0x1
    800019d8:	167d                	addi	a2,a2,-1
    800019da:	962e                	add	a2,a2,a1
    800019dc:	4685                	li	a3,1
    800019de:	8231                	srli	a2,a2,0xc
    800019e0:	4581                	li	a1,0
    800019e2:	00000097          	auipc	ra,0x0
    800019e6:	906080e7          	jalr	-1786(ra) # 800012e8 <uvmunmap>
    800019ea:	bfe1                	j	800019c2 <uvmfree+0xe>

00000000800019ec <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800019ec:	ce79                	beqz	a2,80001aca <uvmcopy+0xde>
{
    800019ee:	715d                	addi	sp,sp,-80
    800019f0:	e486                	sd	ra,72(sp)
    800019f2:	e0a2                	sd	s0,64(sp)
    800019f4:	fc26                	sd	s1,56(sp)
    800019f6:	f84a                	sd	s2,48(sp)
    800019f8:	f44e                	sd	s3,40(sp)
    800019fa:	f052                	sd	s4,32(sp)
    800019fc:	ec56                	sd	s5,24(sp)
    800019fe:	e85a                	sd	s6,16(sp)
    80001a00:	e45e                	sd	s7,8(sp)
    80001a02:	0880                	addi	s0,sp,80
    80001a04:	8b2a                	mv	s6,a0
    80001a06:	8aae                	mv	s5,a1
    80001a08:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001a0a:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001a0c:	4601                	li	a2,0
    80001a0e:	85ce                	mv	a1,s3
    80001a10:	855a                	mv	a0,s6
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	5b4080e7          	jalr	1460(ra) # 80000fc6 <walk>
    80001a1a:	c531                	beqz	a0,80001a66 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001a1c:	6118                	ld	a4,0(a0)
    80001a1e:	00177793          	andi	a5,a4,1
    80001a22:	cbb1                	beqz	a5,80001a76 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001a24:	00a75593          	srli	a1,a4,0xa
    80001a28:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001a2c:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001a30:	fffff097          	auipc	ra,0xfffff
    80001a34:	0c2080e7          	jalr	194(ra) # 80000af2 <kalloc>
    80001a38:	892a                	mv	s2,a0
    80001a3a:	c939                	beqz	a0,80001a90 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001a3c:	6605                	lui	a2,0x1
    80001a3e:	85de                	mv	a1,s7
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	2fa080e7          	jalr	762(ra) # 80000d3a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001a48:	8726                	mv	a4,s1
    80001a4a:	86ca                	mv	a3,s2
    80001a4c:	6605                	lui	a2,0x1
    80001a4e:	85ce                	mv	a1,s3
    80001a50:	8556                	mv	a0,s5
    80001a52:	fffff097          	auipc	ra,0xfffff
    80001a56:	65c080e7          	jalr	1628(ra) # 800010ae <mappages>
    80001a5a:	e515                	bnez	a0,80001a86 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001a5c:	6785                	lui	a5,0x1
    80001a5e:	99be                	add	s3,s3,a5
    80001a60:	fb49e6e3          	bltu	s3,s4,80001a0c <uvmcopy+0x20>
    80001a64:	a881                	j	80001ab4 <uvmcopy+0xc8>
      panic("uvmcopy: pte should exist");
    80001a66:	00006517          	auipc	a0,0x6
    80001a6a:	7a250513          	addi	a0,a0,1954 # 80008208 <digits+0x1c8>
    80001a6e:	fffff097          	auipc	ra,0xfffff
    80001a72:	abc080e7          	jalr	-1348(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    80001a76:	00006517          	auipc	a0,0x6
    80001a7a:	7b250513          	addi	a0,a0,1970 # 80008228 <digits+0x1e8>
    80001a7e:	fffff097          	auipc	ra,0xfffff
    80001a82:	aac080e7          	jalr	-1364(ra) # 8000052a <panic>
      kfree(mem);
    80001a86:	854a                	mv	a0,s2
    80001a88:	fffff097          	auipc	ra,0xfffff
    80001a8c:	f4e080e7          	jalr	-178(ra) # 800009d6 <kfree>
    }
  }
  return 0;

 err:
  printf("ERROR! in uvmcopy\n");
    80001a90:	00006517          	auipc	a0,0x6
    80001a94:	7b850513          	addi	a0,a0,1976 # 80008248 <digits+0x208>
    80001a98:	fffff097          	auipc	ra,0xfffff
    80001a9c:	adc080e7          	jalr	-1316(ra) # 80000574 <printf>
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001aa0:	4685                	li	a3,1
    80001aa2:	00c9d613          	srli	a2,s3,0xc
    80001aa6:	4581                	li	a1,0
    80001aa8:	8556                	mv	a0,s5
    80001aaa:	00000097          	auipc	ra,0x0
    80001aae:	83e080e7          	jalr	-1986(ra) # 800012e8 <uvmunmap>
  return -1;
    80001ab2:	557d                	li	a0,-1
}
    80001ab4:	60a6                	ld	ra,72(sp)
    80001ab6:	6406                	ld	s0,64(sp)
    80001ab8:	74e2                	ld	s1,56(sp)
    80001aba:	7942                	ld	s2,48(sp)
    80001abc:	79a2                	ld	s3,40(sp)
    80001abe:	7a02                	ld	s4,32(sp)
    80001ac0:	6ae2                	ld	s5,24(sp)
    80001ac2:	6b42                	ld	s6,16(sp)
    80001ac4:	6ba2                	ld	s7,8(sp)
    80001ac6:	6161                	addi	sp,sp,80
    80001ac8:	8082                	ret
  return 0;
    80001aca:	4501                	li	a0,0
}
    80001acc:	8082                	ret

0000000080001ace <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001ace:	1141                	addi	sp,sp,-16
    80001ad0:	e406                	sd	ra,8(sp)
    80001ad2:	e022                	sd	s0,0(sp)
    80001ad4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001ad6:	4601                	li	a2,0
    80001ad8:	fffff097          	auipc	ra,0xfffff
    80001adc:	4ee080e7          	jalr	1262(ra) # 80000fc6 <walk>
  if(pte == 0)
    80001ae0:	c901                	beqz	a0,80001af0 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001ae2:	611c                	ld	a5,0(a0)
    80001ae4:	9bbd                	andi	a5,a5,-17
    80001ae6:	e11c                	sd	a5,0(a0)
}
    80001ae8:	60a2                	ld	ra,8(sp)
    80001aea:	6402                	ld	s0,0(sp)
    80001aec:	0141                	addi	sp,sp,16
    80001aee:	8082                	ret
    panic("uvmclear");
    80001af0:	00006517          	auipc	a0,0x6
    80001af4:	77050513          	addi	a0,a0,1904 # 80008260 <digits+0x220>
    80001af8:	fffff097          	auipc	ra,0xfffff
    80001afc:	a32080e7          	jalr	-1486(ra) # 8000052a <panic>

0000000080001b00 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001b00:	c6bd                	beqz	a3,80001b6e <copyout+0x6e>
{
    80001b02:	715d                	addi	sp,sp,-80
    80001b04:	e486                	sd	ra,72(sp)
    80001b06:	e0a2                	sd	s0,64(sp)
    80001b08:	fc26                	sd	s1,56(sp)
    80001b0a:	f84a                	sd	s2,48(sp)
    80001b0c:	f44e                	sd	s3,40(sp)
    80001b0e:	f052                	sd	s4,32(sp)
    80001b10:	ec56                	sd	s5,24(sp)
    80001b12:	e85a                	sd	s6,16(sp)
    80001b14:	e45e                	sd	s7,8(sp)
    80001b16:	e062                	sd	s8,0(sp)
    80001b18:	0880                	addi	s0,sp,80
    80001b1a:	8b2a                	mv	s6,a0
    80001b1c:	8c2e                	mv	s8,a1
    80001b1e:	8a32                	mv	s4,a2
    80001b20:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001b22:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001b24:	6a85                	lui	s5,0x1
    80001b26:	a015                	j	80001b4a <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001b28:	9562                	add	a0,a0,s8
    80001b2a:	0004861b          	sext.w	a2,s1
    80001b2e:	85d2                	mv	a1,s4
    80001b30:	41250533          	sub	a0,a0,s2
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	206080e7          	jalr	518(ra) # 80000d3a <memmove>

    len -= n;
    80001b3c:	409989b3          	sub	s3,s3,s1
    src += n;
    80001b40:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001b42:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001b46:	02098263          	beqz	s3,80001b6a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001b4a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001b4e:	85ca                	mv	a1,s2
    80001b50:	855a                	mv	a0,s6
    80001b52:	fffff097          	auipc	ra,0xfffff
    80001b56:	51a080e7          	jalr	1306(ra) # 8000106c <walkaddr>
    if(pa0 == 0)
    80001b5a:	cd01                	beqz	a0,80001b72 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001b5c:	418904b3          	sub	s1,s2,s8
    80001b60:	94d6                	add	s1,s1,s5
    if(n > len)
    80001b62:	fc99f3e3          	bgeu	s3,s1,80001b28 <copyout+0x28>
    80001b66:	84ce                	mv	s1,s3
    80001b68:	b7c1                	j	80001b28 <copyout+0x28>
  }
  return 0;
    80001b6a:	4501                	li	a0,0
    80001b6c:	a021                	j	80001b74 <copyout+0x74>
    80001b6e:	4501                	li	a0,0
}
    80001b70:	8082                	ret
      return -1;
    80001b72:	557d                	li	a0,-1
}
    80001b74:	60a6                	ld	ra,72(sp)
    80001b76:	6406                	ld	s0,64(sp)
    80001b78:	74e2                	ld	s1,56(sp)
    80001b7a:	7942                	ld	s2,48(sp)
    80001b7c:	79a2                	ld	s3,40(sp)
    80001b7e:	7a02                	ld	s4,32(sp)
    80001b80:	6ae2                	ld	s5,24(sp)
    80001b82:	6b42                	ld	s6,16(sp)
    80001b84:	6ba2                	ld	s7,8(sp)
    80001b86:	6c02                	ld	s8,0(sp)
    80001b88:	6161                	addi	sp,sp,80
    80001b8a:	8082                	ret

0000000080001b8c <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001b8c:	caa5                	beqz	a3,80001bfc <copyin+0x70>
{
    80001b8e:	715d                	addi	sp,sp,-80
    80001b90:	e486                	sd	ra,72(sp)
    80001b92:	e0a2                	sd	s0,64(sp)
    80001b94:	fc26                	sd	s1,56(sp)
    80001b96:	f84a                	sd	s2,48(sp)
    80001b98:	f44e                	sd	s3,40(sp)
    80001b9a:	f052                	sd	s4,32(sp)
    80001b9c:	ec56                	sd	s5,24(sp)
    80001b9e:	e85a                	sd	s6,16(sp)
    80001ba0:	e45e                	sd	s7,8(sp)
    80001ba2:	e062                	sd	s8,0(sp)
    80001ba4:	0880                	addi	s0,sp,80
    80001ba6:	8b2a                	mv	s6,a0
    80001ba8:	8a2e                	mv	s4,a1
    80001baa:	8c32                	mv	s8,a2
    80001bac:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001bae:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001bb0:	6a85                	lui	s5,0x1
    80001bb2:	a01d                	j	80001bd8 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001bb4:	018505b3          	add	a1,a0,s8
    80001bb8:	0004861b          	sext.w	a2,s1
    80001bbc:	412585b3          	sub	a1,a1,s2
    80001bc0:	8552                	mv	a0,s4
    80001bc2:	fffff097          	auipc	ra,0xfffff
    80001bc6:	178080e7          	jalr	376(ra) # 80000d3a <memmove>

    len -= n;
    80001bca:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001bce:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001bd0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001bd4:	02098263          	beqz	s3,80001bf8 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001bd8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001bdc:	85ca                	mv	a1,s2
    80001bde:	855a                	mv	a0,s6
    80001be0:	fffff097          	auipc	ra,0xfffff
    80001be4:	48c080e7          	jalr	1164(ra) # 8000106c <walkaddr>
    if(pa0 == 0)
    80001be8:	cd01                	beqz	a0,80001c00 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001bea:	418904b3          	sub	s1,s2,s8
    80001bee:	94d6                	add	s1,s1,s5
    if(n > len)
    80001bf0:	fc99f2e3          	bgeu	s3,s1,80001bb4 <copyin+0x28>
    80001bf4:	84ce                	mv	s1,s3
    80001bf6:	bf7d                	j	80001bb4 <copyin+0x28>
  }
  return 0;
    80001bf8:	4501                	li	a0,0
    80001bfa:	a021                	j	80001c02 <copyin+0x76>
    80001bfc:	4501                	li	a0,0
}
    80001bfe:	8082                	ret
      return -1;
    80001c00:	557d                	li	a0,-1
}
    80001c02:	60a6                	ld	ra,72(sp)
    80001c04:	6406                	ld	s0,64(sp)
    80001c06:	74e2                	ld	s1,56(sp)
    80001c08:	7942                	ld	s2,48(sp)
    80001c0a:	79a2                	ld	s3,40(sp)
    80001c0c:	7a02                	ld	s4,32(sp)
    80001c0e:	6ae2                	ld	s5,24(sp)
    80001c10:	6b42                	ld	s6,16(sp)
    80001c12:	6ba2                	ld	s7,8(sp)
    80001c14:	6c02                	ld	s8,0(sp)
    80001c16:	6161                	addi	sp,sp,80
    80001c18:	8082                	ret

0000000080001c1a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001c1a:	c6c5                	beqz	a3,80001cc2 <copyinstr+0xa8>
{
    80001c1c:	715d                	addi	sp,sp,-80
    80001c1e:	e486                	sd	ra,72(sp)
    80001c20:	e0a2                	sd	s0,64(sp)
    80001c22:	fc26                	sd	s1,56(sp)
    80001c24:	f84a                	sd	s2,48(sp)
    80001c26:	f44e                	sd	s3,40(sp)
    80001c28:	f052                	sd	s4,32(sp)
    80001c2a:	ec56                	sd	s5,24(sp)
    80001c2c:	e85a                	sd	s6,16(sp)
    80001c2e:	e45e                	sd	s7,8(sp)
    80001c30:	0880                	addi	s0,sp,80
    80001c32:	8a2a                	mv	s4,a0
    80001c34:	8b2e                	mv	s6,a1
    80001c36:	8bb2                	mv	s7,a2
    80001c38:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001c3a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001c3c:	6985                	lui	s3,0x1
    80001c3e:	a035                	j	80001c6a <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001c40:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001c44:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001c46:	0017b793          	seqz	a5,a5
    80001c4a:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
    80001c4e:	60a6                	ld	ra,72(sp)
    80001c50:	6406                	ld	s0,64(sp)
    80001c52:	74e2                	ld	s1,56(sp)
    80001c54:	7942                	ld	s2,48(sp)
    80001c56:	79a2                	ld	s3,40(sp)
    80001c58:	7a02                	ld	s4,32(sp)
    80001c5a:	6ae2                	ld	s5,24(sp)
    80001c5c:	6b42                	ld	s6,16(sp)
    80001c5e:	6ba2                	ld	s7,8(sp)
    80001c60:	6161                	addi	sp,sp,80
    80001c62:	8082                	ret
    srcva = va0 + PGSIZE;
    80001c64:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001c68:	c8a9                	beqz	s1,80001cba <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001c6a:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001c6e:	85ca                	mv	a1,s2
    80001c70:	8552                	mv	a0,s4
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	3fa080e7          	jalr	1018(ra) # 8000106c <walkaddr>
    if(pa0 == 0)
    80001c7a:	c131                	beqz	a0,80001cbe <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001c7c:	41790833          	sub	a6,s2,s7
    80001c80:	984e                	add	a6,a6,s3
    if(n > max)
    80001c82:	0104f363          	bgeu	s1,a6,80001c88 <copyinstr+0x6e>
    80001c86:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001c88:	955e                	add	a0,a0,s7
    80001c8a:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001c8e:	fc080be3          	beqz	a6,80001c64 <copyinstr+0x4a>
    80001c92:	985a                	add	a6,a6,s6
    80001c94:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001c96:	41650633          	sub	a2,a0,s6
    80001c9a:	14fd                	addi	s1,s1,-1
    80001c9c:	9b26                	add	s6,s6,s1
    80001c9e:	00f60733          	add	a4,a2,a5
    80001ca2:	00074703          	lbu	a4,0(a4)
    80001ca6:	df49                	beqz	a4,80001c40 <copyinstr+0x26>
        *dst = *p;
    80001ca8:	00e78023          	sb	a4,0(a5)
      --max;
    80001cac:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001cb0:	0785                	addi	a5,a5,1
    while(n > 0){
    80001cb2:	ff0796e3          	bne	a5,a6,80001c9e <copyinstr+0x84>
      dst++;
    80001cb6:	8b42                	mv	s6,a6
    80001cb8:	b775                	j	80001c64 <copyinstr+0x4a>
    80001cba:	4781                	li	a5,0
    80001cbc:	b769                	j	80001c46 <copyinstr+0x2c>
      return -1;
    80001cbe:	557d                	li	a0,-1
    80001cc0:	b779                	j	80001c4e <copyinstr+0x34>
  int got_null = 0;
    80001cc2:	4781                	li	a5,0
  if(got_null){
    80001cc4:	0017b793          	seqz	a5,a5
    80001cc8:	40f00533          	neg	a0,a5
    80001ccc:	8082                	ret

0000000080001cce <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001cce:	7139                	addi	sp,sp,-64
    80001cd0:	fc06                	sd	ra,56(sp)
    80001cd2:	f822                	sd	s0,48(sp)
    80001cd4:	f426                	sd	s1,40(sp)
    80001cd6:	f04a                	sd	s2,32(sp)
    80001cd8:	ec4e                	sd	s3,24(sp)
    80001cda:	e852                	sd	s4,16(sp)
    80001cdc:	e456                	sd	s5,8(sp)
    80001cde:	e05a                	sd	s6,0(sp)
    80001ce0:	0080                	addi	s0,sp,64
    80001ce2:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ce4:	00010497          	auipc	s1,0x10
    80001ce8:	9ec48493          	addi	s1,s1,-1556 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001cec:	8b26                	mv	s6,s1
    80001cee:	00006a97          	auipc	s5,0x6
    80001cf2:	312a8a93          	addi	s5,s5,786 # 80008000 <etext>
    80001cf6:	04000937          	lui	s2,0x4000
    80001cfa:	197d                	addi	s2,s2,-1
    80001cfc:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cfe:	0001ea17          	auipc	s4,0x1e
    80001d02:	9d2a0a13          	addi	s4,s4,-1582 # 8001f6d0 <tickslock>
    char *pa = kalloc();
    80001d06:	fffff097          	auipc	ra,0xfffff
    80001d0a:	dec080e7          	jalr	-532(ra) # 80000af2 <kalloc>
    80001d0e:	862a                	mv	a2,a0
    if(pa == 0)
    80001d10:	c131                	beqz	a0,80001d54 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001d12:	416485b3          	sub	a1,s1,s6
    80001d16:	859d                	srai	a1,a1,0x7
    80001d18:	000ab783          	ld	a5,0(s5)
    80001d1c:	02f585b3          	mul	a1,a1,a5
    80001d20:	2585                	addiw	a1,a1,1
    80001d22:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001d26:	4719                	li	a4,6
    80001d28:	6685                	lui	a3,0x1
    80001d2a:	40b905b3          	sub	a1,s2,a1
    80001d2e:	854e                	mv	a0,s3
    80001d30:	fffff097          	auipc	ra,0xfffff
    80001d34:	40c080e7          	jalr	1036(ra) # 8000113c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d38:	38048493          	addi	s1,s1,896
    80001d3c:	fd4495e3          	bne	s1,s4,80001d06 <proc_mapstacks+0x38>
  }
}
    80001d40:	70e2                	ld	ra,56(sp)
    80001d42:	7442                	ld	s0,48(sp)
    80001d44:	74a2                	ld	s1,40(sp)
    80001d46:	7902                	ld	s2,32(sp)
    80001d48:	69e2                	ld	s3,24(sp)
    80001d4a:	6a42                	ld	s4,16(sp)
    80001d4c:	6aa2                	ld	s5,8(sp)
    80001d4e:	6b02                	ld	s6,0(sp)
    80001d50:	6121                	addi	sp,sp,64
    80001d52:	8082                	ret
      panic("kalloc");
    80001d54:	00006517          	auipc	a0,0x6
    80001d58:	51c50513          	addi	a0,a0,1308 # 80008270 <digits+0x230>
    80001d5c:	ffffe097          	auipc	ra,0xffffe
    80001d60:	7ce080e7          	jalr	1998(ra) # 8000052a <panic>

0000000080001d64 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001d64:	7139                	addi	sp,sp,-64
    80001d66:	fc06                	sd	ra,56(sp)
    80001d68:	f822                	sd	s0,48(sp)
    80001d6a:	f426                	sd	s1,40(sp)
    80001d6c:	f04a                	sd	s2,32(sp)
    80001d6e:	ec4e                	sd	s3,24(sp)
    80001d70:	e852                	sd	s4,16(sp)
    80001d72:	e456                	sd	s5,8(sp)
    80001d74:	e05a                	sd	s6,0(sp)
    80001d76:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001d78:	00006597          	auipc	a1,0x6
    80001d7c:	50058593          	addi	a1,a1,1280 # 80008278 <digits+0x238>
    80001d80:	0000f517          	auipc	a0,0xf
    80001d84:	52050513          	addi	a0,a0,1312 # 800112a0 <pid_lock>
    80001d88:	fffff097          	auipc	ra,0xfffff
    80001d8c:	dca080e7          	jalr	-566(ra) # 80000b52 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001d90:	00006597          	auipc	a1,0x6
    80001d94:	4f058593          	addi	a1,a1,1264 # 80008280 <digits+0x240>
    80001d98:	0000f517          	auipc	a0,0xf
    80001d9c:	52050513          	addi	a0,a0,1312 # 800112b8 <wait_lock>
    80001da0:	fffff097          	auipc	ra,0xfffff
    80001da4:	db2080e7          	jalr	-590(ra) # 80000b52 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001da8:	00010497          	auipc	s1,0x10
    80001dac:	92848493          	addi	s1,s1,-1752 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001db0:	00006b17          	auipc	s6,0x6
    80001db4:	4e0b0b13          	addi	s6,s6,1248 # 80008290 <digits+0x250>
      p->kstack = KSTACK((int) (p - proc));
    80001db8:	8aa6                	mv	s5,s1
    80001dba:	00006a17          	auipc	s4,0x6
    80001dbe:	246a0a13          	addi	s4,s4,582 # 80008000 <etext>
    80001dc2:	04000937          	lui	s2,0x4000
    80001dc6:	197d                	addi	s2,s2,-1
    80001dc8:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dca:	0001e997          	auipc	s3,0x1e
    80001dce:	90698993          	addi	s3,s3,-1786 # 8001f6d0 <tickslock>
      initlock(&p->lock, "proc");
    80001dd2:	85da                	mv	a1,s6
    80001dd4:	8526                	mv	a0,s1
    80001dd6:	fffff097          	auipc	ra,0xfffff
    80001dda:	d7c080e7          	jalr	-644(ra) # 80000b52 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001dde:	415487b3          	sub	a5,s1,s5
    80001de2:	879d                	srai	a5,a5,0x7
    80001de4:	000a3703          	ld	a4,0(s4)
    80001de8:	02e787b3          	mul	a5,a5,a4
    80001dec:	2785                	addiw	a5,a5,1
    80001dee:	00d7979b          	slliw	a5,a5,0xd
    80001df2:	40f907b3          	sub	a5,s2,a5
    80001df6:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001df8:	38048493          	addi	s1,s1,896
    80001dfc:	fd349be3          	bne	s1,s3,80001dd2 <procinit+0x6e>
  }
}
    80001e00:	70e2                	ld	ra,56(sp)
    80001e02:	7442                	ld	s0,48(sp)
    80001e04:	74a2                	ld	s1,40(sp)
    80001e06:	7902                	ld	s2,32(sp)
    80001e08:	69e2                	ld	s3,24(sp)
    80001e0a:	6a42                	ld	s4,16(sp)
    80001e0c:	6aa2                	ld	s5,8(sp)
    80001e0e:	6b02                	ld	s6,0(sp)
    80001e10:	6121                	addi	sp,sp,64
    80001e12:	8082                	ret

0000000080001e14 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001e14:	1141                	addi	sp,sp,-16
    80001e16:	e422                	sd	s0,8(sp)
    80001e18:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e1a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001e1c:	2501                	sext.w	a0,a0
    80001e1e:	6422                	ld	s0,8(sp)
    80001e20:	0141                	addi	sp,sp,16
    80001e22:	8082                	ret

0000000080001e24 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001e24:	1141                	addi	sp,sp,-16
    80001e26:	e422                	sd	s0,8(sp)
    80001e28:	0800                	addi	s0,sp,16
    80001e2a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001e2c:	2781                	sext.w	a5,a5
    80001e2e:	079e                	slli	a5,a5,0x7
  return c;
}
    80001e30:	0000f517          	auipc	a0,0xf
    80001e34:	4a050513          	addi	a0,a0,1184 # 800112d0 <cpus>
    80001e38:	953e                	add	a0,a0,a5
    80001e3a:	6422                	ld	s0,8(sp)
    80001e3c:	0141                	addi	sp,sp,16
    80001e3e:	8082                	ret

0000000080001e40 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001e40:	1101                	addi	sp,sp,-32
    80001e42:	ec06                	sd	ra,24(sp)
    80001e44:	e822                	sd	s0,16(sp)
    80001e46:	e426                	sd	s1,8(sp)
    80001e48:	1000                	addi	s0,sp,32
  push_off();
    80001e4a:	fffff097          	auipc	ra,0xfffff
    80001e4e:	d4c080e7          	jalr	-692(ra) # 80000b96 <push_off>
    80001e52:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001e54:	2781                	sext.w	a5,a5
    80001e56:	079e                	slli	a5,a5,0x7
    80001e58:	0000f717          	auipc	a4,0xf
    80001e5c:	44870713          	addi	a4,a4,1096 # 800112a0 <pid_lock>
    80001e60:	97ba                	add	a5,a5,a4
    80001e62:	7b84                	ld	s1,48(a5)
  pop_off();
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	dd2080e7          	jalr	-558(ra) # 80000c36 <pop_off>
  return p;
}
    80001e6c:	8526                	mv	a0,s1
    80001e6e:	60e2                	ld	ra,24(sp)
    80001e70:	6442                	ld	s0,16(sp)
    80001e72:	64a2                	ld	s1,8(sp)
    80001e74:	6105                	addi	sp,sp,32
    80001e76:	8082                	ret

0000000080001e78 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001e78:	1141                	addi	sp,sp,-16
    80001e7a:	e406                	sd	ra,8(sp)
    80001e7c:	e022                	sd	s0,0(sp)
    80001e7e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001e80:	00000097          	auipc	ra,0x0
    80001e84:	fc0080e7          	jalr	-64(ra) # 80001e40 <myproc>
    80001e88:	fffff097          	auipc	ra,0xfffff
    80001e8c:	e0e080e7          	jalr	-498(ra) # 80000c96 <release>

  if (first) {
    80001e90:	00007797          	auipc	a5,0x7
    80001e94:	a907a783          	lw	a5,-1392(a5) # 80008920 <first.1>
    80001e98:	eb89                	bnez	a5,80001eaa <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001e9a:	00001097          	auipc	ra,0x1
    80001e9e:	eb2080e7          	jalr	-334(ra) # 80002d4c <usertrapret>
}
    80001ea2:	60a2                	ld	ra,8(sp)
    80001ea4:	6402                	ld	s0,0(sp)
    80001ea6:	0141                	addi	sp,sp,16
    80001ea8:	8082                	ret
    first = 0;
    80001eaa:	00007797          	auipc	a5,0x7
    80001eae:	a607ab23          	sw	zero,-1418(a5) # 80008920 <first.1>
    fsinit(ROOTDEV);
    80001eb2:	4505                	li	a0,1
    80001eb4:	00002097          	auipc	ra,0x2
    80001eb8:	c3a080e7          	jalr	-966(ra) # 80003aee <fsinit>
    80001ebc:	bff9                	j	80001e9a <forkret+0x22>

0000000080001ebe <allocpid>:
allocpid() {
    80001ebe:	1101                	addi	sp,sp,-32
    80001ec0:	ec06                	sd	ra,24(sp)
    80001ec2:	e822                	sd	s0,16(sp)
    80001ec4:	e426                	sd	s1,8(sp)
    80001ec6:	e04a                	sd	s2,0(sp)
    80001ec8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001eca:	0000f917          	auipc	s2,0xf
    80001ece:	3d690913          	addi	s2,s2,982 # 800112a0 <pid_lock>
    80001ed2:	854a                	mv	a0,s2
    80001ed4:	fffff097          	auipc	ra,0xfffff
    80001ed8:	d0e080e7          	jalr	-754(ra) # 80000be2 <acquire>
  pid = nextpid;
    80001edc:	00007797          	auipc	a5,0x7
    80001ee0:	a4878793          	addi	a5,a5,-1464 # 80008924 <nextpid>
    80001ee4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ee6:	0014871b          	addiw	a4,s1,1
    80001eea:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001eec:	854a                	mv	a0,s2
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	da8080e7          	jalr	-600(ra) # 80000c96 <release>
}
    80001ef6:	8526                	mv	a0,s1
    80001ef8:	60e2                	ld	ra,24(sp)
    80001efa:	6442                	ld	s0,16(sp)
    80001efc:	64a2                	ld	s1,8(sp)
    80001efe:	6902                	ld	s2,0(sp)
    80001f00:	6105                	addi	sp,sp,32
    80001f02:	8082                	ret

0000000080001f04 <proc_pagetable>:
{
    80001f04:	1101                	addi	sp,sp,-32
    80001f06:	ec06                	sd	ra,24(sp)
    80001f08:	e822                	sd	s0,16(sp)
    80001f0a:	e426                	sd	s1,8(sp)
    80001f0c:	e04a                	sd	s2,0(sp)
    80001f0e:	1000                	addi	s0,sp,32
    80001f10:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	7ca080e7          	jalr	1994(ra) # 800016dc <uvmcreate>
    80001f1a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001f1c:	c121                	beqz	a0,80001f5c <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001f1e:	4729                	li	a4,10
    80001f20:	00005697          	auipc	a3,0x5
    80001f24:	0e068693          	addi	a3,a3,224 # 80007000 <_trampoline>
    80001f28:	6605                	lui	a2,0x1
    80001f2a:	040005b7          	lui	a1,0x4000
    80001f2e:	15fd                	addi	a1,a1,-1
    80001f30:	05b2                	slli	a1,a1,0xc
    80001f32:	fffff097          	auipc	ra,0xfffff
    80001f36:	17c080e7          	jalr	380(ra) # 800010ae <mappages>
    80001f3a:	02054863          	bltz	a0,80001f6a <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001f3e:	4719                	li	a4,6
    80001f40:	05893683          	ld	a3,88(s2)
    80001f44:	6605                	lui	a2,0x1
    80001f46:	020005b7          	lui	a1,0x2000
    80001f4a:	15fd                	addi	a1,a1,-1
    80001f4c:	05b6                	slli	a1,a1,0xd
    80001f4e:	8526                	mv	a0,s1
    80001f50:	fffff097          	auipc	ra,0xfffff
    80001f54:	15e080e7          	jalr	350(ra) # 800010ae <mappages>
    80001f58:	02054163          	bltz	a0,80001f7a <proc_pagetable+0x76>
}
    80001f5c:	8526                	mv	a0,s1
    80001f5e:	60e2                	ld	ra,24(sp)
    80001f60:	6442                	ld	s0,16(sp)
    80001f62:	64a2                	ld	s1,8(sp)
    80001f64:	6902                	ld	s2,0(sp)
    80001f66:	6105                	addi	sp,sp,32
    80001f68:	8082                	ret
    uvmfree(pagetable, 0);
    80001f6a:	4581                	li	a1,0
    80001f6c:	8526                	mv	a0,s1
    80001f6e:	00000097          	auipc	ra,0x0
    80001f72:	a46080e7          	jalr	-1466(ra) # 800019b4 <uvmfree>
    return 0;
    80001f76:	4481                	li	s1,0
    80001f78:	b7d5                	j	80001f5c <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f7a:	4681                	li	a3,0
    80001f7c:	4605                	li	a2,1
    80001f7e:	040005b7          	lui	a1,0x4000
    80001f82:	15fd                	addi	a1,a1,-1
    80001f84:	05b2                	slli	a1,a1,0xc
    80001f86:	8526                	mv	a0,s1
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	360080e7          	jalr	864(ra) # 800012e8 <uvmunmap>
    uvmfree(pagetable, 0);
    80001f90:	4581                	li	a1,0
    80001f92:	8526                	mv	a0,s1
    80001f94:	00000097          	auipc	ra,0x0
    80001f98:	a20080e7          	jalr	-1504(ra) # 800019b4 <uvmfree>
    return 0;
    80001f9c:	4481                	li	s1,0
    80001f9e:	bf7d                	j	80001f5c <proc_pagetable+0x58>

0000000080001fa0 <proc_freepagetable>:
{
    80001fa0:	1101                	addi	sp,sp,-32
    80001fa2:	ec06                	sd	ra,24(sp)
    80001fa4:	e822                	sd	s0,16(sp)
    80001fa6:	e426                	sd	s1,8(sp)
    80001fa8:	e04a                	sd	s2,0(sp)
    80001faa:	1000                	addi	s0,sp,32
    80001fac:	84aa                	mv	s1,a0
    80001fae:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001fb0:	4681                	li	a3,0
    80001fb2:	4605                	li	a2,1
    80001fb4:	040005b7          	lui	a1,0x4000
    80001fb8:	15fd                	addi	a1,a1,-1
    80001fba:	05b2                	slli	a1,a1,0xc
    80001fbc:	fffff097          	auipc	ra,0xfffff
    80001fc0:	32c080e7          	jalr	812(ra) # 800012e8 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001fc4:	4681                	li	a3,0
    80001fc6:	4605                	li	a2,1
    80001fc8:	020005b7          	lui	a1,0x2000
    80001fcc:	15fd                	addi	a1,a1,-1
    80001fce:	05b6                	slli	a1,a1,0xd
    80001fd0:	8526                	mv	a0,s1
    80001fd2:	fffff097          	auipc	ra,0xfffff
    80001fd6:	316080e7          	jalr	790(ra) # 800012e8 <uvmunmap>
  uvmfree(pagetable, sz);
    80001fda:	85ca                	mv	a1,s2
    80001fdc:	8526                	mv	a0,s1
    80001fde:	00000097          	auipc	ra,0x0
    80001fe2:	9d6080e7          	jalr	-1578(ra) # 800019b4 <uvmfree>
}
    80001fe6:	60e2                	ld	ra,24(sp)
    80001fe8:	6442                	ld	s0,16(sp)
    80001fea:	64a2                	ld	s1,8(sp)
    80001fec:	6902                	ld	s2,0(sp)
    80001fee:	6105                	addi	sp,sp,32
    80001ff0:	8082                	ret

0000000080001ff2 <freeproc>:
{
    80001ff2:	1101                	addi	sp,sp,-32
    80001ff4:	ec06                	sd	ra,24(sp)
    80001ff6:	e822                	sd	s0,16(sp)
    80001ff8:	e426                	sd	s1,8(sp)
    80001ffa:	1000                	addi	s0,sp,32
    80001ffc:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001ffe:	6d28                	ld	a0,88(a0)
    80002000:	c509                	beqz	a0,8000200a <freeproc+0x18>
    kfree((void*)p->trapframe);
    80002002:	fffff097          	auipc	ra,0xfffff
    80002006:	9d4080e7          	jalr	-1580(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    8000200a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    8000200e:	68a8                	ld	a0,80(s1)
    80002010:	c511                	beqz	a0,8000201c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80002012:	64ac                	ld	a1,72(s1)
    80002014:	00000097          	auipc	ra,0x0
    80002018:	f8c080e7          	jalr	-116(ra) # 80001fa0 <proc_freepagetable>
  p->pagetable = 0;
    8000201c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80002020:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80002024:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80002028:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    8000202c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80002030:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80002034:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80002038:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    8000203c:	0004ac23          	sw	zero,24(s1)
    p->ram_pages_counter = 0;
    80002040:	2604a823          	sw	zero,624(s1)
    p->pages_in_file_counter = 0;
    80002044:	3604ac23          	sw	zero,888(s1)
    for(int i=0; i<MAX_PSYC_PAGES; i++){
    80002048:	17048793          	addi	a5,s1,368
    8000204c:	27048493          	addi	s1,s1,624
      p->pages_in_file[i].is_free = 1;
    80002050:	4705                	li	a4,1
    80002052:	10e7a823          	sw	a4,272(a5)
      p->pages_in_ram[i].va = 0;
    80002056:	0007b023          	sd	zero,0(a5)
      p->pages_in_ram[i].age = 0;
    8000205a:	0007a623          	sw	zero,12(a5)
      p->pages_in_ram[i].is_free = 1;
    8000205e:	c798                	sw	a4,8(a5)
      p->pages_in_file[i].va = 0;
    80002060:	1007b423          	sd	zero,264(a5)
      p->pages_in_file[i].age = 0;
    80002064:	1007aa23          	sw	zero,276(a5)
    for(int i=0; i<MAX_PSYC_PAGES; i++){
    80002068:	07c1                	addi	a5,a5,16
    8000206a:	fe9794e3          	bne	a5,s1,80002052 <freeproc+0x60>
}
    8000206e:	60e2                	ld	ra,24(sp)
    80002070:	6442                	ld	s0,16(sp)
    80002072:	64a2                	ld	s1,8(sp)
    80002074:	6105                	addi	sp,sp,32
    80002076:	8082                	ret

0000000080002078 <allocproc>:
{
    80002078:	7179                	addi	sp,sp,-48
    8000207a:	f406                	sd	ra,40(sp)
    8000207c:	f022                	sd	s0,32(sp)
    8000207e:	ec26                	sd	s1,24(sp)
    80002080:	e84a                	sd	s2,16(sp)
    80002082:	e44e                	sd	s3,8(sp)
    80002084:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80002086:	0000f497          	auipc	s1,0xf
    8000208a:	64a48493          	addi	s1,s1,1610 # 800116d0 <proc>
    8000208e:	0001d997          	auipc	s3,0x1d
    80002092:	64298993          	addi	s3,s3,1602 # 8001f6d0 <tickslock>
    acquire(&p->lock);
    80002096:	8526                	mv	a0,s1
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	b4a080e7          	jalr	-1206(ra) # 80000be2 <acquire>
    if(p->state == UNUSED) {
    800020a0:	4c9c                	lw	a5,24(s1)
    800020a2:	cf81                	beqz	a5,800020ba <allocproc+0x42>
      release(&p->lock);
    800020a4:	8526                	mv	a0,s1
    800020a6:	fffff097          	auipc	ra,0xfffff
    800020aa:	bf0080e7          	jalr	-1040(ra) # 80000c96 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020ae:	38048493          	addi	s1,s1,896
    800020b2:	ff3492e3          	bne	s1,s3,80002096 <allocproc+0x1e>
  return 0;
    800020b6:	4481                	li	s1,0
    800020b8:	a849                	j	8000214a <allocproc+0xd2>
  p->pid = allocpid();
    800020ba:	00000097          	auipc	ra,0x0
    800020be:	e04080e7          	jalr	-508(ra) # 80001ebe <allocpid>
    800020c2:	d888                	sw	a0,48(s1)
  p->state = USED;
    800020c4:	4785                	li	a5,1
    800020c6:	cc9c                	sw	a5,24(s1)
  p->swapFile = 0;
    800020c8:	1604b423          	sd	zero,360(s1)
  p-> pages_in_file_counter = 0;
    800020cc:	3604ac23          	sw	zero,888(s1)
  p-> ram_pages_counter = 0;
    800020d0:	2604a823          	sw	zero,624(s1)
  for(int i=0; i<MAX_PSYC_PAGES; i++){
    800020d4:	17048793          	addi	a5,s1,368
    800020d8:	27048913          	addi	s2,s1,624
    p->pages_in_file[i].is_free = 1;
    800020dc:	4705                	li	a4,1
    800020de:	10e7a823          	sw	a4,272(a5)
    p->pages_in_ram[i].va = 0;
    800020e2:	0007b023          	sd	zero,0(a5)
    p->pages_in_ram[i].age = 0;
    800020e6:	0007a623          	sw	zero,12(a5)
    p->pages_in_ram[i].is_free = 1;
    800020ea:	c798                	sw	a4,8(a5)
    p->pages_in_file[i].va = 0;
    800020ec:	1007b423          	sd	zero,264(a5)
    p->pages_in_file[i].age = 0;
    800020f0:	1007aa23          	sw	zero,276(a5)
  for(int i=0; i<MAX_PSYC_PAGES; i++){
    800020f4:	07c1                	addi	a5,a5,16
    800020f6:	ff2794e3          	bne	a5,s2,800020de <allocproc+0x66>
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800020fa:	fffff097          	auipc	ra,0xfffff
    800020fe:	9f8080e7          	jalr	-1544(ra) # 80000af2 <kalloc>
    80002102:	892a                	mv	s2,a0
    80002104:	eca8                	sd	a0,88(s1)
    80002106:	c931                	beqz	a0,8000215a <allocproc+0xe2>
  p->pagetable = proc_pagetable(p);
    80002108:	8526                	mv	a0,s1
    8000210a:	00000097          	auipc	ra,0x0
    8000210e:	dfa080e7          	jalr	-518(ra) # 80001f04 <proc_pagetable>
    80002112:	892a                	mv	s2,a0
    80002114:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80002116:	cd31                	beqz	a0,80002172 <allocproc+0xfa>
  memset(&p->context, 0, sizeof(p->context));
    80002118:	07000613          	li	a2,112
    8000211c:	4581                	li	a1,0
    8000211e:	06048513          	addi	a0,s1,96
    80002122:	fffff097          	auipc	ra,0xfffff
    80002126:	bbc080e7          	jalr	-1092(ra) # 80000cde <memset>
  p->context.ra = (uint64)forkret;
    8000212a:	00000797          	auipc	a5,0x0
    8000212e:	d4e78793          	addi	a5,a5,-690 # 80001e78 <forkret>
    80002132:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002134:	60bc                	ld	a5,64(s1)
    80002136:	6705                	lui	a4,0x1
    80002138:	97ba                	add	a5,a5,a4
    8000213a:	f4bc                	sd	a5,104(s1)
    if(p->pid > 2){
    8000213c:	5898                	lw	a4,48(s1)
    8000213e:	4789                	li	a5,2
    80002140:	00e7d563          	bge	a5,a4,8000214a <allocproc+0xd2>
      if(p->swapFile == 0){
    80002144:	1684b783          	ld	a5,360(s1)
    80002148:	c3a9                	beqz	a5,8000218a <allocproc+0x112>
}
    8000214a:	8526                	mv	a0,s1
    8000214c:	70a2                	ld	ra,40(sp)
    8000214e:	7402                	ld	s0,32(sp)
    80002150:	64e2                	ld	s1,24(sp)
    80002152:	6942                	ld	s2,16(sp)
    80002154:	69a2                	ld	s3,8(sp)
    80002156:	6145                	addi	sp,sp,48
    80002158:	8082                	ret
    freeproc(p);
    8000215a:	8526                	mv	a0,s1
    8000215c:	00000097          	auipc	ra,0x0
    80002160:	e96080e7          	jalr	-362(ra) # 80001ff2 <freeproc>
    release(&p->lock);
    80002164:	8526                	mv	a0,s1
    80002166:	fffff097          	auipc	ra,0xfffff
    8000216a:	b30080e7          	jalr	-1232(ra) # 80000c96 <release>
    return 0;
    8000216e:	84ca                	mv	s1,s2
    80002170:	bfe9                	j	8000214a <allocproc+0xd2>
    freeproc(p);
    80002172:	8526                	mv	a0,s1
    80002174:	00000097          	auipc	ra,0x0
    80002178:	e7e080e7          	jalr	-386(ra) # 80001ff2 <freeproc>
    release(&p->lock);
    8000217c:	8526                	mv	a0,s1
    8000217e:	fffff097          	auipc	ra,0xfffff
    80002182:	b18080e7          	jalr	-1256(ra) # 80000c96 <release>
    return 0;
    80002186:	84ca                	mv	s1,s2
    80002188:	b7c9                	j	8000214a <allocproc+0xd2>
        release(&p->lock);
    8000218a:	8526                	mv	a0,s1
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	b0a080e7          	jalr	-1270(ra) # 80000c96 <release>
        createSwapFile(p);
    80002194:	8526                	mv	a0,s1
    80002196:	00002097          	auipc	ra,0x2
    8000219a:	5da080e7          	jalr	1498(ra) # 80004770 <createSwapFile>
        acquire(&p->lock);
    8000219e:	8526                	mv	a0,s1
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	a42080e7          	jalr	-1470(ra) # 80000be2 <acquire>
    800021a8:	b74d                	j	8000214a <allocproc+0xd2>

00000000800021aa <userinit>:
{
    800021aa:	1101                	addi	sp,sp,-32
    800021ac:	ec06                	sd	ra,24(sp)
    800021ae:	e822                	sd	s0,16(sp)
    800021b0:	e426                	sd	s1,8(sp)
    800021b2:	1000                	addi	s0,sp,32
  p = allocproc();
    800021b4:	00000097          	auipc	ra,0x0
    800021b8:	ec4080e7          	jalr	-316(ra) # 80002078 <allocproc>
    800021bc:	84aa                	mv	s1,a0
  initproc = p;
    800021be:	00007797          	auipc	a5,0x7
    800021c2:	e6a7b523          	sd	a0,-406(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    800021c6:	03400613          	li	a2,52
    800021ca:	00006597          	auipc	a1,0x6
    800021ce:	76658593          	addi	a1,a1,1894 # 80008930 <initcode>
    800021d2:	6928                	ld	a0,80(a0)
    800021d4:	fffff097          	auipc	ra,0xfffff
    800021d8:	536080e7          	jalr	1334(ra) # 8000170a <uvminit>
  p->sz = PGSIZE;
    800021dc:	6785                	lui	a5,0x1
    800021de:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800021e0:	6cb8                	ld	a4,88(s1)
    800021e2:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800021e6:	6cb8                	ld	a4,88(s1)
    800021e8:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800021ea:	4641                	li	a2,16
    800021ec:	00006597          	auipc	a1,0x6
    800021f0:	0ac58593          	addi	a1,a1,172 # 80008298 <digits+0x258>
    800021f4:	15848513          	addi	a0,s1,344
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	c38080e7          	jalr	-968(ra) # 80000e30 <safestrcpy>
  p->cwd = namei("/");
    80002200:	00006517          	auipc	a0,0x6
    80002204:	0a850513          	addi	a0,a0,168 # 800082a8 <digits+0x268>
    80002208:	00002097          	auipc	ra,0x2
    8000220c:	314080e7          	jalr	788(ra) # 8000451c <namei>
    80002210:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80002214:	478d                	li	a5,3
    80002216:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80002218:	8526                	mv	a0,s1
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	a7c080e7          	jalr	-1412(ra) # 80000c96 <release>
}
    80002222:	60e2                	ld	ra,24(sp)
    80002224:	6442                	ld	s0,16(sp)
    80002226:	64a2                	ld	s1,8(sp)
    80002228:	6105                	addi	sp,sp,32
    8000222a:	8082                	ret

000000008000222c <growproc>:
{
    8000222c:	1101                	addi	sp,sp,-32
    8000222e:	ec06                	sd	ra,24(sp)
    80002230:	e822                	sd	s0,16(sp)
    80002232:	e426                	sd	s1,8(sp)
    80002234:	e04a                	sd	s2,0(sp)
    80002236:	1000                	addi	s0,sp,32
    80002238:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000223a:	00000097          	auipc	ra,0x0
    8000223e:	c06080e7          	jalr	-1018(ra) # 80001e40 <myproc>
    80002242:	892a                	mv	s2,a0
  sz = p->sz;
    80002244:	652c                	ld	a1,72(a0)
    80002246:	0005861b          	sext.w	a2,a1
  if(n > 0){
    8000224a:	00904f63          	bgtz	s1,80002268 <growproc+0x3c>
  } else if(n < 0){
    8000224e:	0204cc63          	bltz	s1,80002286 <growproc+0x5a>
  p->sz = sz;
    80002252:	1602                	slli	a2,a2,0x20
    80002254:	9201                	srli	a2,a2,0x20
    80002256:	04c93423          	sd	a2,72(s2)
  return 0;
    8000225a:	4501                	li	a0,0
}
    8000225c:	60e2                	ld	ra,24(sp)
    8000225e:	6442                	ld	s0,16(sp)
    80002260:	64a2                	ld	s1,8(sp)
    80002262:	6902                	ld	s2,0(sp)
    80002264:	6105                	addi	sp,sp,32
    80002266:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80002268:	9e25                	addw	a2,a2,s1
    8000226a:	1602                	slli	a2,a2,0x20
    8000226c:	9201                	srli	a2,a2,0x20
    8000226e:	1582                	slli	a1,a1,0x20
    80002270:	9181                	srli	a1,a1,0x20
    80002272:	6928                	ld	a0,80(a0)
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	60a080e7          	jalr	1546(ra) # 8000187e <uvmalloc>
    8000227c:	0005061b          	sext.w	a2,a0
    80002280:	fa69                	bnez	a2,80002252 <growproc+0x26>
      return -1;
    80002282:	557d                	li	a0,-1
    80002284:	bfe1                	j	8000225c <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002286:	9e25                	addw	a2,a2,s1
    80002288:	1602                	slli	a2,a2,0x20
    8000228a:	9201                	srli	a2,a2,0x20
    8000228c:	1582                	slli	a1,a1,0x20
    8000228e:	9181                	srli	a1,a1,0x20
    80002290:	6928                	ld	a0,80(a0)
    80002292:	fffff097          	auipc	ra,0xfffff
    80002296:	5a4080e7          	jalr	1444(ra) # 80001836 <uvmdealloc>
    8000229a:	0005061b          	sext.w	a2,a0
    8000229e:	bf55                	j	80002252 <growproc+0x26>

00000000800022a0 <fork>:
{
    800022a0:	711d                	addi	sp,sp,-96
    800022a2:	ec86                	sd	ra,88(sp)
    800022a4:	e8a2                	sd	s0,80(sp)
    800022a6:	e4a6                	sd	s1,72(sp)
    800022a8:	e0ca                	sd	s2,64(sp)
    800022aa:	fc4e                	sd	s3,56(sp)
    800022ac:	f852                	sd	s4,48(sp)
    800022ae:	f456                	sd	s5,40(sp)
    800022b0:	f05a                	sd	s6,32(sp)
    800022b2:	ec5e                	sd	s7,24(sp)
    800022b4:	e862                	sd	s8,16(sp)
    800022b6:	e466                	sd	s9,8(sp)
    800022b8:	1080                	addi	s0,sp,96
  struct proc *p = myproc();
    800022ba:	00000097          	auipc	ra,0x0
    800022be:	b86080e7          	jalr	-1146(ra) # 80001e40 <myproc>
    800022c2:	8a2a                	mv	s4,a0
  if((np = allocproc()) == 0){
    800022c4:	00000097          	auipc	ra,0x0
    800022c8:	db4080e7          	jalr	-588(ra) # 80002078 <allocproc>
    800022cc:	1a050c63          	beqz	a0,80002484 <fork+0x1e4>
    800022d0:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800022d2:	048a3603          	ld	a2,72(s4)
    800022d6:	692c                	ld	a1,80(a0)
    800022d8:	050a3503          	ld	a0,80(s4)
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	710080e7          	jalr	1808(ra) # 800019ec <uvmcopy>
    800022e4:	04054863          	bltz	a0,80002334 <fork+0x94>
  np->sz = p->sz;
    800022e8:	048a3783          	ld	a5,72(s4)
    800022ec:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800022f0:	058a3683          	ld	a3,88(s4)
    800022f4:	87b6                	mv	a5,a3
    800022f6:	0589b703          	ld	a4,88(s3)
    800022fa:	12068693          	addi	a3,a3,288
    800022fe:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002302:	6788                	ld	a0,8(a5)
    80002304:	6b8c                	ld	a1,16(a5)
    80002306:	6f90                	ld	a2,24(a5)
    80002308:	01073023          	sd	a6,0(a4)
    8000230c:	e708                	sd	a0,8(a4)
    8000230e:	eb0c                	sd	a1,16(a4)
    80002310:	ef10                	sd	a2,24(a4)
    80002312:	02078793          	addi	a5,a5,32
    80002316:	02070713          	addi	a4,a4,32
    8000231a:	fed792e3          	bne	a5,a3,800022fe <fork+0x5e>
  np->trapframe->a0 = 0;
    8000231e:	0589b783          	ld	a5,88(s3)
    80002322:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002326:	0d0a0493          	addi	s1,s4,208
    8000232a:	0d098913          	addi	s2,s3,208
    8000232e:	150a0a93          	addi	s5,s4,336
    80002332:	a00d                	j	80002354 <fork+0xb4>
    freeproc(np);
    80002334:	854e                	mv	a0,s3
    80002336:	00000097          	auipc	ra,0x0
    8000233a:	cbc080e7          	jalr	-836(ra) # 80001ff2 <freeproc>
    release(&np->lock);
    8000233e:	854e                	mv	a0,s3
    80002340:	fffff097          	auipc	ra,0xfffff
    80002344:	956080e7          	jalr	-1706(ra) # 80000c96 <release>
    return -1;
    80002348:	5b7d                	li	s6,-1
    8000234a:	aa39                	j	80002468 <fork+0x1c8>
  for(i = 0; i < NOFILE; i++)
    8000234c:	04a1                	addi	s1,s1,8
    8000234e:	0921                	addi	s2,s2,8
    80002350:	01548b63          	beq	s1,s5,80002366 <fork+0xc6>
    if(p->ofile[i])
    80002354:	6088                	ld	a0,0(s1)
    80002356:	d97d                	beqz	a0,8000234c <fork+0xac>
      np->ofile[i] = filedup(p->ofile[i]);
    80002358:	00003097          	auipc	ra,0x3
    8000235c:	b70080e7          	jalr	-1168(ra) # 80004ec8 <filedup>
    80002360:	00a93023          	sd	a0,0(s2)
    80002364:	b7e5                	j	8000234c <fork+0xac>
  np->cwd = idup(p->cwd);
    80002366:	150a3503          	ld	a0,336(s4)
    8000236a:	00002097          	auipc	ra,0x2
    8000236e:	9be080e7          	jalr	-1602(ra) # 80003d28 <idup>
    80002372:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002376:	4641                	li	a2,16
    80002378:	158a0593          	addi	a1,s4,344
    8000237c:	15898513          	addi	a0,s3,344
    80002380:	fffff097          	auipc	ra,0xfffff
    80002384:	ab0080e7          	jalr	-1360(ra) # 80000e30 <safestrcpy>
  pid = np->pid;
    80002388:	0309ab03          	lw	s6,48(s3)
    if(pid > 2)
    8000238c:	4789                	li	a5,2
    8000238e:	0967db63          	bge	a5,s6,80002424 <fork+0x184>
          np->ram_pages_counter = p-> ram_pages_counter;
    80002392:	270a2783          	lw	a5,624(s4)
    80002396:	26f9a823          	sw	a5,624(s3)
          np->pages_in_file_counter = p-> pages_in_file_counter;
    8000239a:	378a2783          	lw	a5,888(s4)
    8000239e:	36f9ac23          	sw	a5,888(s3)
          for(int i=0; i< MAX_PSYC_PAGES; i++){
    800023a2:	170a0793          	addi	a5,s4,368
    800023a6:	17098713          	addi	a4,s3,368
    800023aa:	270a0613          	addi	a2,s4,624
              np->pages_in_ram[i].va = p->pages_in_ram[i].va;
    800023ae:	6394                	ld	a3,0(a5)
    800023b0:	e314                	sd	a3,0(a4)
              np->pages_in_ram[i].is_free = p->pages_in_ram[i].is_free;
    800023b2:	4794                	lw	a3,8(a5)
    800023b4:	c714                	sw	a3,8(a4)
              np->pages_in_ram[i].age = p->pages_in_ram[i].age;
    800023b6:	47d4                	lw	a3,12(a5)
    800023b8:	c754                	sw	a3,12(a4)
          for(int i=0; i< MAX_PSYC_PAGES; i++){
    800023ba:	07c1                	addi	a5,a5,16
    800023bc:	0741                	addi	a4,a4,16
    800023be:	fec798e3          	bne	a5,a2,800023ae <fork+0x10e>
            char* tempPage = kalloc();
    800023c2:	ffffe097          	auipc	ra,0xffffe
    800023c6:	730080e7          	jalr	1840(ra) # 80000af2 <kalloc>
    800023ca:	8caa                	mv	s9,a0
            for(int i=0; i< MAX_PSYC_PAGES; i++){
    800023cc:	278a0913          	addi	s2,s4,632
    800023d0:	27898493          	addi	s1,s3,632
    800023d4:	37898c13          	addi	s8,s3,888
            char* tempPage = kalloc();
    800023d8:	4a81                	li	s5,0
            for(int i=0; i< MAX_PSYC_PAGES; i++){
    800023da:	6b85                	lui	s7,0x1
    800023dc:	a03d                	j	8000240a <fork+0x16a>
                readFromSwapFile(p, tempPage, i*PGSIZE, PGSIZE);
    800023de:	6685                	lui	a3,0x1
    800023e0:	8656                	mv	a2,s5
    800023e2:	85e6                	mv	a1,s9
    800023e4:	8552                	mv	a0,s4
    800023e6:	00002097          	auipc	ra,0x2
    800023ea:	45e080e7          	jalr	1118(ra) # 80004844 <readFromSwapFile>
                writeToSwapFile(np, tempPage, i*PGSIZE, PGSIZE);
    800023ee:	6685                	lui	a3,0x1
    800023f0:	8656                	mv	a2,s5
    800023f2:	85e6                	mv	a1,s9
    800023f4:	854e                	mv	a0,s3
    800023f6:	00002097          	auipc	ra,0x2
    800023fa:	42a080e7          	jalr	1066(ra) # 80004820 <writeToSwapFile>
            for(int i=0; i< MAX_PSYC_PAGES; i++){
    800023fe:	0941                	addi	s2,s2,16
    80002400:	04c1                	addi	s1,s1,16
    80002402:	015b8abb          	addw	s5,s7,s5
    80002406:	01848a63          	beq	s1,s8,8000241a <fork+0x17a>
              np->pages_in_file[i].va = p->pages_in_file[i].va;
    8000240a:	00093783          	ld	a5,0(s2)
    8000240e:	e09c                	sd	a5,0(s1)
              np->pages_in_file[i].is_free = p->pages_in_file[i].is_free;
    80002410:	00892783          	lw	a5,8(s2)
    80002414:	c49c                	sw	a5,8(s1)
              if(p->pages_in_file[i].is_free == 0){
    80002416:	f7e5                	bnez	a5,800023fe <fork+0x15e>
    80002418:	b7d9                	j	800023de <fork+0x13e>
            kfree(tempPage);
    8000241a:	8566                	mv	a0,s9
    8000241c:	ffffe097          	auipc	ra,0xffffe
    80002420:	5ba080e7          	jalr	1466(ra) # 800009d6 <kfree>
  release(&np->lock);
    80002424:	854e                	mv	a0,s3
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	870080e7          	jalr	-1936(ra) # 80000c96 <release>
  acquire(&wait_lock);
    8000242e:	0000f497          	auipc	s1,0xf
    80002432:	e8a48493          	addi	s1,s1,-374 # 800112b8 <wait_lock>
    80002436:	8526                	mv	a0,s1
    80002438:	ffffe097          	auipc	ra,0xffffe
    8000243c:	7aa080e7          	jalr	1962(ra) # 80000be2 <acquire>
  np->parent = p;
    80002440:	0349bc23          	sd	s4,56(s3)
  release(&wait_lock);
    80002444:	8526                	mv	a0,s1
    80002446:	fffff097          	auipc	ra,0xfffff
    8000244a:	850080e7          	jalr	-1968(ra) # 80000c96 <release>
  acquire(&np->lock);
    8000244e:	854e                	mv	a0,s3
    80002450:	ffffe097          	auipc	ra,0xffffe
    80002454:	792080e7          	jalr	1938(ra) # 80000be2 <acquire>
  np->state = RUNNABLE;
    80002458:	478d                	li	a5,3
    8000245a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000245e:	854e                	mv	a0,s3
    80002460:	fffff097          	auipc	ra,0xfffff
    80002464:	836080e7          	jalr	-1994(ra) # 80000c96 <release>
}
    80002468:	855a                	mv	a0,s6
    8000246a:	60e6                	ld	ra,88(sp)
    8000246c:	6446                	ld	s0,80(sp)
    8000246e:	64a6                	ld	s1,72(sp)
    80002470:	6906                	ld	s2,64(sp)
    80002472:	79e2                	ld	s3,56(sp)
    80002474:	7a42                	ld	s4,48(sp)
    80002476:	7aa2                	ld	s5,40(sp)
    80002478:	7b02                	ld	s6,32(sp)
    8000247a:	6be2                	ld	s7,24(sp)
    8000247c:	6c42                	ld	s8,16(sp)
    8000247e:	6ca2                	ld	s9,8(sp)
    80002480:	6125                	addi	sp,sp,96
    80002482:	8082                	ret
    return -1;
    80002484:	5b7d                	li	s6,-1
    80002486:	b7cd                	j	80002468 <fork+0x1c8>

0000000080002488 <updatePagesAge>:
void updatePagesAge(){
    80002488:	7139                	addi	sp,sp,-64
    8000248a:	fc06                	sd	ra,56(sp)
    8000248c:	f822                	sd	s0,48(sp)
    8000248e:	f426                	sd	s1,40(sp)
    80002490:	f04a                	sd	s2,32(sp)
    80002492:	ec4e                	sd	s3,24(sp)
    80002494:	e852                	sd	s4,16(sp)
    80002496:	e456                	sd	s5,8(sp)
    80002498:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000249a:	00000097          	auipc	ra,0x0
    8000249e:	9a6080e7          	jalr	-1626(ra) # 80001e40 <myproc>
    800024a2:	8a2a                	mv	s4,a0
  for(int i=0; i<MAX_PSYC_PAGES; i++){
    800024a4:	17050493          	addi	s1,a0,368
    800024a8:	27050993          	addi	s3,a0,624
        p->pages_in_ram[i].age = p->pages_in_ram[i].age | 0x80000000;
    800024ac:	80000ab7          	lui	s5,0x80000
    800024b0:	a021                	j	800024b8 <updatePagesAge+0x30>
  for(int i=0; i<MAX_PSYC_PAGES; i++){
    800024b2:	04c1                	addi	s1,s1,16
    800024b4:	03348963          	beq	s1,s3,800024e6 <updatePagesAge+0x5e>
    if(p->pages_in_ram[i].is_free == 0){
    800024b8:	449c                	lw	a5,8(s1)
    800024ba:	ffe5                	bnez	a5,800024b2 <updatePagesAge+0x2a>
      p->pages_in_ram[i].age >>= 1;
    800024bc:	44dc                	lw	a5,12(s1)
    800024be:	0017d79b          	srliw	a5,a5,0x1
    800024c2:	c4dc                	sw	a5,12(s1)
      pte = walk(p->pagetable, p->pages_in_ram[i].va, 0);
    800024c4:	4601                	li	a2,0
    800024c6:	608c                	ld	a1,0(s1)
    800024c8:	050a3503          	ld	a0,80(s4)
    800024cc:	fffff097          	auipc	ra,0xfffff
    800024d0:	afa080e7          	jalr	-1286(ra) # 80000fc6 <walk>
      if ( ( *pte & PTE_A ) != 0 )
    800024d4:	611c                	ld	a5,0(a0)
    800024d6:	0407f793          	andi	a5,a5,64
    800024da:	dfe1                	beqz	a5,800024b2 <updatePagesAge+0x2a>
        p->pages_in_ram[i].age = p->pages_in_ram[i].age | 0x80000000;
    800024dc:	44dc                	lw	a5,12(s1)
    800024de:	0157e7b3          	or	a5,a5,s5
    800024e2:	c4dc                	sw	a5,12(s1)
    800024e4:	b7f9                	j	800024b2 <updatePagesAge+0x2a>
}
    800024e6:	70e2                	ld	ra,56(sp)
    800024e8:	7442                	ld	s0,48(sp)
    800024ea:	74a2                	ld	s1,40(sp)
    800024ec:	7902                	ld	s2,32(sp)
    800024ee:	69e2                	ld	s3,24(sp)
    800024f0:	6a42                	ld	s4,16(sp)
    800024f2:	6aa2                	ld	s5,8(sp)
    800024f4:	6121                	addi	sp,sp,64
    800024f6:	8082                	ret

00000000800024f8 <scheduler>:
{
    800024f8:	7139                	addi	sp,sp,-64
    800024fa:	fc06                	sd	ra,56(sp)
    800024fc:	f822                	sd	s0,48(sp)
    800024fe:	f426                	sd	s1,40(sp)
    80002500:	f04a                	sd	s2,32(sp)
    80002502:	ec4e                	sd	s3,24(sp)
    80002504:	e852                	sd	s4,16(sp)
    80002506:	e456                	sd	s5,8(sp)
    80002508:	e05a                	sd	s6,0(sp)
    8000250a:	0080                	addi	s0,sp,64
    8000250c:	8792                	mv	a5,tp
  int id = r_tp();
    8000250e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002510:	00779a93          	slli	s5,a5,0x7
    80002514:	0000f717          	auipc	a4,0xf
    80002518:	d8c70713          	addi	a4,a4,-628 # 800112a0 <pid_lock>
    8000251c:	9756                	add	a4,a4,s5
    8000251e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002522:	0000f717          	auipc	a4,0xf
    80002526:	db670713          	addi	a4,a4,-586 # 800112d8 <cpus+0x8>
    8000252a:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    8000252c:	498d                	li	s3,3
        p->state = RUNNING;
    8000252e:	4b11                	li	s6,4
        c->proc = p;
    80002530:	079e                	slli	a5,a5,0x7
    80002532:	0000fa17          	auipc	s4,0xf
    80002536:	d6ea0a13          	addi	s4,s4,-658 # 800112a0 <pid_lock>
    8000253a:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000253c:	0001d917          	auipc	s2,0x1d
    80002540:	19490913          	addi	s2,s2,404 # 8001f6d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002544:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002548:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000254c:	10079073          	csrw	sstatus,a5
    80002550:	0000f497          	auipc	s1,0xf
    80002554:	18048493          	addi	s1,s1,384 # 800116d0 <proc>
    80002558:	a811                	j	8000256c <scheduler+0x74>
      release(&p->lock);
    8000255a:	8526                	mv	a0,s1
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	73a080e7          	jalr	1850(ra) # 80000c96 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002564:	38048493          	addi	s1,s1,896
    80002568:	fd248ee3          	beq	s1,s2,80002544 <scheduler+0x4c>
      acquire(&p->lock);
    8000256c:	8526                	mv	a0,s1
    8000256e:	ffffe097          	auipc	ra,0xffffe
    80002572:	674080e7          	jalr	1652(ra) # 80000be2 <acquire>
      if(p->state == RUNNABLE) {
    80002576:	4c9c                	lw	a5,24(s1)
    80002578:	ff3791e3          	bne	a5,s3,8000255a <scheduler+0x62>
        p->state = RUNNING;
    8000257c:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002580:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002584:	06048593          	addi	a1,s1,96
    80002588:	8556                	mv	a0,s5
    8000258a:	00000097          	auipc	ra,0x0
    8000258e:	642080e7          	jalr	1602(ra) # 80002bcc <swtch>
        updatePagesAge();
    80002592:	00000097          	auipc	ra,0x0
    80002596:	ef6080e7          	jalr	-266(ra) # 80002488 <updatePagesAge>
        c->proc = 0;
    8000259a:	020a3823          	sd	zero,48(s4)
    8000259e:	bf75                	j	8000255a <scheduler+0x62>

00000000800025a0 <sched>:
{
    800025a0:	7179                	addi	sp,sp,-48
    800025a2:	f406                	sd	ra,40(sp)
    800025a4:	f022                	sd	s0,32(sp)
    800025a6:	ec26                	sd	s1,24(sp)
    800025a8:	e84a                	sd	s2,16(sp)
    800025aa:	e44e                	sd	s3,8(sp)
    800025ac:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800025ae:	00000097          	auipc	ra,0x0
    800025b2:	892080e7          	jalr	-1902(ra) # 80001e40 <myproc>
    800025b6:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800025b8:	ffffe097          	auipc	ra,0xffffe
    800025bc:	5b0080e7          	jalr	1456(ra) # 80000b68 <holding>
    800025c0:	c93d                	beqz	a0,80002636 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800025c2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800025c4:	2781                	sext.w	a5,a5
    800025c6:	079e                	slli	a5,a5,0x7
    800025c8:	0000f717          	auipc	a4,0xf
    800025cc:	cd870713          	addi	a4,a4,-808 # 800112a0 <pid_lock>
    800025d0:	97ba                	add	a5,a5,a4
    800025d2:	0a87a703          	lw	a4,168(a5)
    800025d6:	4785                	li	a5,1
    800025d8:	06f71763          	bne	a4,a5,80002646 <sched+0xa6>
  if(p->state == RUNNING)
    800025dc:	4c98                	lw	a4,24(s1)
    800025de:	4791                	li	a5,4
    800025e0:	06f70b63          	beq	a4,a5,80002656 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025e4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800025e8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800025ea:	efb5                	bnez	a5,80002666 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800025ec:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800025ee:	0000f917          	auipc	s2,0xf
    800025f2:	cb290913          	addi	s2,s2,-846 # 800112a0 <pid_lock>
    800025f6:	2781                	sext.w	a5,a5
    800025f8:	079e                	slli	a5,a5,0x7
    800025fa:	97ca                	add	a5,a5,s2
    800025fc:	0ac7a983          	lw	s3,172(a5)
    80002600:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002602:	2781                	sext.w	a5,a5
    80002604:	079e                	slli	a5,a5,0x7
    80002606:	0000f597          	auipc	a1,0xf
    8000260a:	cd258593          	addi	a1,a1,-814 # 800112d8 <cpus+0x8>
    8000260e:	95be                	add	a1,a1,a5
    80002610:	06048513          	addi	a0,s1,96
    80002614:	00000097          	auipc	ra,0x0
    80002618:	5b8080e7          	jalr	1464(ra) # 80002bcc <swtch>
    8000261c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000261e:	2781                	sext.w	a5,a5
    80002620:	079e                	slli	a5,a5,0x7
    80002622:	97ca                	add	a5,a5,s2
    80002624:	0b37a623          	sw	s3,172(a5)
}
    80002628:	70a2                	ld	ra,40(sp)
    8000262a:	7402                	ld	s0,32(sp)
    8000262c:	64e2                	ld	s1,24(sp)
    8000262e:	6942                	ld	s2,16(sp)
    80002630:	69a2                	ld	s3,8(sp)
    80002632:	6145                	addi	sp,sp,48
    80002634:	8082                	ret
    panic("sched p->lock");
    80002636:	00006517          	auipc	a0,0x6
    8000263a:	c7a50513          	addi	a0,a0,-902 # 800082b0 <digits+0x270>
    8000263e:	ffffe097          	auipc	ra,0xffffe
    80002642:	eec080e7          	jalr	-276(ra) # 8000052a <panic>
    panic("sched locks");
    80002646:	00006517          	auipc	a0,0x6
    8000264a:	c7a50513          	addi	a0,a0,-902 # 800082c0 <digits+0x280>
    8000264e:	ffffe097          	auipc	ra,0xffffe
    80002652:	edc080e7          	jalr	-292(ra) # 8000052a <panic>
    panic("sched running");
    80002656:	00006517          	auipc	a0,0x6
    8000265a:	c7a50513          	addi	a0,a0,-902 # 800082d0 <digits+0x290>
    8000265e:	ffffe097          	auipc	ra,0xffffe
    80002662:	ecc080e7          	jalr	-308(ra) # 8000052a <panic>
    panic("sched interruptible");
    80002666:	00006517          	auipc	a0,0x6
    8000266a:	c7a50513          	addi	a0,a0,-902 # 800082e0 <digits+0x2a0>
    8000266e:	ffffe097          	auipc	ra,0xffffe
    80002672:	ebc080e7          	jalr	-324(ra) # 8000052a <panic>

0000000080002676 <yield>:
{
    80002676:	1101                	addi	sp,sp,-32
    80002678:	ec06                	sd	ra,24(sp)
    8000267a:	e822                	sd	s0,16(sp)
    8000267c:	e426                	sd	s1,8(sp)
    8000267e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002680:	fffff097          	auipc	ra,0xfffff
    80002684:	7c0080e7          	jalr	1984(ra) # 80001e40 <myproc>
    80002688:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000268a:	ffffe097          	auipc	ra,0xffffe
    8000268e:	558080e7          	jalr	1368(ra) # 80000be2 <acquire>
  p->state = RUNNABLE;
    80002692:	478d                	li	a5,3
    80002694:	cc9c                	sw	a5,24(s1)
  sched();
    80002696:	00000097          	auipc	ra,0x0
    8000269a:	f0a080e7          	jalr	-246(ra) # 800025a0 <sched>
  release(&p->lock);
    8000269e:	8526                	mv	a0,s1
    800026a0:	ffffe097          	auipc	ra,0xffffe
    800026a4:	5f6080e7          	jalr	1526(ra) # 80000c96 <release>
}
    800026a8:	60e2                	ld	ra,24(sp)
    800026aa:	6442                	ld	s0,16(sp)
    800026ac:	64a2                	ld	s1,8(sp)
    800026ae:	6105                	addi	sp,sp,32
    800026b0:	8082                	ret

00000000800026b2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800026b2:	7179                	addi	sp,sp,-48
    800026b4:	f406                	sd	ra,40(sp)
    800026b6:	f022                	sd	s0,32(sp)
    800026b8:	ec26                	sd	s1,24(sp)
    800026ba:	e84a                	sd	s2,16(sp)
    800026bc:	e44e                	sd	s3,8(sp)
    800026be:	1800                	addi	s0,sp,48
    800026c0:	89aa                	mv	s3,a0
    800026c2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800026c4:	fffff097          	auipc	ra,0xfffff
    800026c8:	77c080e7          	jalr	1916(ra) # 80001e40 <myproc>
    800026cc:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800026ce:	ffffe097          	auipc	ra,0xffffe
    800026d2:	514080e7          	jalr	1300(ra) # 80000be2 <acquire>
  release(lk);
    800026d6:	854a                	mv	a0,s2
    800026d8:	ffffe097          	auipc	ra,0xffffe
    800026dc:	5be080e7          	jalr	1470(ra) # 80000c96 <release>

  // Go to sleep.
  p->chan = chan;
    800026e0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800026e4:	4789                	li	a5,2
    800026e6:	cc9c                	sw	a5,24(s1)

  sched();
    800026e8:	00000097          	auipc	ra,0x0
    800026ec:	eb8080e7          	jalr	-328(ra) # 800025a0 <sched>

  // Tidy up.
  p->chan = 0;
    800026f0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800026f4:	8526                	mv	a0,s1
    800026f6:	ffffe097          	auipc	ra,0xffffe
    800026fa:	5a0080e7          	jalr	1440(ra) # 80000c96 <release>
  acquire(lk);
    800026fe:	854a                	mv	a0,s2
    80002700:	ffffe097          	auipc	ra,0xffffe
    80002704:	4e2080e7          	jalr	1250(ra) # 80000be2 <acquire>
}
    80002708:	70a2                	ld	ra,40(sp)
    8000270a:	7402                	ld	s0,32(sp)
    8000270c:	64e2                	ld	s1,24(sp)
    8000270e:	6942                	ld	s2,16(sp)
    80002710:	69a2                	ld	s3,8(sp)
    80002712:	6145                	addi	sp,sp,48
    80002714:	8082                	ret

0000000080002716 <wait>:
{
    80002716:	715d                	addi	sp,sp,-80
    80002718:	e486                	sd	ra,72(sp)
    8000271a:	e0a2                	sd	s0,64(sp)
    8000271c:	fc26                	sd	s1,56(sp)
    8000271e:	f84a                	sd	s2,48(sp)
    80002720:	f44e                	sd	s3,40(sp)
    80002722:	f052                	sd	s4,32(sp)
    80002724:	ec56                	sd	s5,24(sp)
    80002726:	e85a                	sd	s6,16(sp)
    80002728:	e45e                	sd	s7,8(sp)
    8000272a:	e062                	sd	s8,0(sp)
    8000272c:	0880                	addi	s0,sp,80
    8000272e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002730:	fffff097          	auipc	ra,0xfffff
    80002734:	710080e7          	jalr	1808(ra) # 80001e40 <myproc>
    80002738:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000273a:	0000f517          	auipc	a0,0xf
    8000273e:	b7e50513          	addi	a0,a0,-1154 # 800112b8 <wait_lock>
    80002742:	ffffe097          	auipc	ra,0xffffe
    80002746:	4a0080e7          	jalr	1184(ra) # 80000be2 <acquire>
    havekids = 0;
    8000274a:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000274c:	4a15                	li	s4,5
        havekids = 1;
    8000274e:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002750:	0001d997          	auipc	s3,0x1d
    80002754:	f8098993          	addi	s3,s3,-128 # 8001f6d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002758:	0000fc17          	auipc	s8,0xf
    8000275c:	b60c0c13          	addi	s8,s8,-1184 # 800112b8 <wait_lock>
    havekids = 0;
    80002760:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002762:	0000f497          	auipc	s1,0xf
    80002766:	f6e48493          	addi	s1,s1,-146 # 800116d0 <proc>
    8000276a:	a0bd                	j	800027d8 <wait+0xc2>
          pid = np->pid;
    8000276c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002770:	000b0e63          	beqz	s6,8000278c <wait+0x76>
    80002774:	4691                	li	a3,4
    80002776:	02c48613          	addi	a2,s1,44
    8000277a:	85da                	mv	a1,s6
    8000277c:	05093503          	ld	a0,80(s2)
    80002780:	fffff097          	auipc	ra,0xfffff
    80002784:	380080e7          	jalr	896(ra) # 80001b00 <copyout>
    80002788:	02054563          	bltz	a0,800027b2 <wait+0x9c>
          freeproc(np);
    8000278c:	8526                	mv	a0,s1
    8000278e:	00000097          	auipc	ra,0x0
    80002792:	864080e7          	jalr	-1948(ra) # 80001ff2 <freeproc>
          release(&np->lock);
    80002796:	8526                	mv	a0,s1
    80002798:	ffffe097          	auipc	ra,0xffffe
    8000279c:	4fe080e7          	jalr	1278(ra) # 80000c96 <release>
          release(&wait_lock);
    800027a0:	0000f517          	auipc	a0,0xf
    800027a4:	b1850513          	addi	a0,a0,-1256 # 800112b8 <wait_lock>
    800027a8:	ffffe097          	auipc	ra,0xffffe
    800027ac:	4ee080e7          	jalr	1262(ra) # 80000c96 <release>
          return pid;
    800027b0:	a09d                	j	80002816 <wait+0x100>
            release(&np->lock);
    800027b2:	8526                	mv	a0,s1
    800027b4:	ffffe097          	auipc	ra,0xffffe
    800027b8:	4e2080e7          	jalr	1250(ra) # 80000c96 <release>
            release(&wait_lock);
    800027bc:	0000f517          	auipc	a0,0xf
    800027c0:	afc50513          	addi	a0,a0,-1284 # 800112b8 <wait_lock>
    800027c4:	ffffe097          	auipc	ra,0xffffe
    800027c8:	4d2080e7          	jalr	1234(ra) # 80000c96 <release>
            return -1;
    800027cc:	59fd                	li	s3,-1
    800027ce:	a0a1                	j	80002816 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800027d0:	38048493          	addi	s1,s1,896
    800027d4:	03348463          	beq	s1,s3,800027fc <wait+0xe6>
      if(np->parent == p){
    800027d8:	7c9c                	ld	a5,56(s1)
    800027da:	ff279be3          	bne	a5,s2,800027d0 <wait+0xba>
        acquire(&np->lock);
    800027de:	8526                	mv	a0,s1
    800027e0:	ffffe097          	auipc	ra,0xffffe
    800027e4:	402080e7          	jalr	1026(ra) # 80000be2 <acquire>
        if(np->state == ZOMBIE){
    800027e8:	4c9c                	lw	a5,24(s1)
    800027ea:	f94781e3          	beq	a5,s4,8000276c <wait+0x56>
        release(&np->lock);
    800027ee:	8526                	mv	a0,s1
    800027f0:	ffffe097          	auipc	ra,0xffffe
    800027f4:	4a6080e7          	jalr	1190(ra) # 80000c96 <release>
        havekids = 1;
    800027f8:	8756                	mv	a4,s5
    800027fa:	bfd9                	j	800027d0 <wait+0xba>
    if(!havekids || p->killed){
    800027fc:	c701                	beqz	a4,80002804 <wait+0xee>
    800027fe:	02892783          	lw	a5,40(s2)
    80002802:	c79d                	beqz	a5,80002830 <wait+0x11a>
      release(&wait_lock);
    80002804:	0000f517          	auipc	a0,0xf
    80002808:	ab450513          	addi	a0,a0,-1356 # 800112b8 <wait_lock>
    8000280c:	ffffe097          	auipc	ra,0xffffe
    80002810:	48a080e7          	jalr	1162(ra) # 80000c96 <release>
      return -1;
    80002814:	59fd                	li	s3,-1
}
    80002816:	854e                	mv	a0,s3
    80002818:	60a6                	ld	ra,72(sp)
    8000281a:	6406                	ld	s0,64(sp)
    8000281c:	74e2                	ld	s1,56(sp)
    8000281e:	7942                	ld	s2,48(sp)
    80002820:	79a2                	ld	s3,40(sp)
    80002822:	7a02                	ld	s4,32(sp)
    80002824:	6ae2                	ld	s5,24(sp)
    80002826:	6b42                	ld	s6,16(sp)
    80002828:	6ba2                	ld	s7,8(sp)
    8000282a:	6c02                	ld	s8,0(sp)
    8000282c:	6161                	addi	sp,sp,80
    8000282e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002830:	85e2                	mv	a1,s8
    80002832:	854a                	mv	a0,s2
    80002834:	00000097          	auipc	ra,0x0
    80002838:	e7e080e7          	jalr	-386(ra) # 800026b2 <sleep>
    havekids = 0;
    8000283c:	b715                	j	80002760 <wait+0x4a>

000000008000283e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000283e:	7139                	addi	sp,sp,-64
    80002840:	fc06                	sd	ra,56(sp)
    80002842:	f822                	sd	s0,48(sp)
    80002844:	f426                	sd	s1,40(sp)
    80002846:	f04a                	sd	s2,32(sp)
    80002848:	ec4e                	sd	s3,24(sp)
    8000284a:	e852                	sd	s4,16(sp)
    8000284c:	e456                	sd	s5,8(sp)
    8000284e:	0080                	addi	s0,sp,64
    80002850:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002852:	0000f497          	auipc	s1,0xf
    80002856:	e7e48493          	addi	s1,s1,-386 # 800116d0 <proc>
    if(p != myproc()){

      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000285a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000285c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000285e:	0001d917          	auipc	s2,0x1d
    80002862:	e7290913          	addi	s2,s2,-398 # 8001f6d0 <tickslock>
    80002866:	a811                	j	8000287a <wakeup+0x3c>
      }
      release(&p->lock);
    80002868:	8526                	mv	a0,s1
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	42c080e7          	jalr	1068(ra) # 80000c96 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002872:	38048493          	addi	s1,s1,896
    80002876:	03248663          	beq	s1,s2,800028a2 <wakeup+0x64>
    if(p != myproc()){
    8000287a:	fffff097          	auipc	ra,0xfffff
    8000287e:	5c6080e7          	jalr	1478(ra) # 80001e40 <myproc>
    80002882:	fea488e3          	beq	s1,a0,80002872 <wakeup+0x34>
      acquire(&p->lock);
    80002886:	8526                	mv	a0,s1
    80002888:	ffffe097          	auipc	ra,0xffffe
    8000288c:	35a080e7          	jalr	858(ra) # 80000be2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002890:	4c9c                	lw	a5,24(s1)
    80002892:	fd379be3          	bne	a5,s3,80002868 <wakeup+0x2a>
    80002896:	709c                	ld	a5,32(s1)
    80002898:	fd4798e3          	bne	a5,s4,80002868 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000289c:	0154ac23          	sw	s5,24(s1)
    800028a0:	b7e1                	j	80002868 <wakeup+0x2a>
    }
  }
}
    800028a2:	70e2                	ld	ra,56(sp)
    800028a4:	7442                	ld	s0,48(sp)
    800028a6:	74a2                	ld	s1,40(sp)
    800028a8:	7902                	ld	s2,32(sp)
    800028aa:	69e2                	ld	s3,24(sp)
    800028ac:	6a42                	ld	s4,16(sp)
    800028ae:	6aa2                	ld	s5,8(sp)
    800028b0:	6121                	addi	sp,sp,64
    800028b2:	8082                	ret

00000000800028b4 <reparent>:
{
    800028b4:	7179                	addi	sp,sp,-48
    800028b6:	f406                	sd	ra,40(sp)
    800028b8:	f022                	sd	s0,32(sp)
    800028ba:	ec26                	sd	s1,24(sp)
    800028bc:	e84a                	sd	s2,16(sp)
    800028be:	e44e                	sd	s3,8(sp)
    800028c0:	e052                	sd	s4,0(sp)
    800028c2:	1800                	addi	s0,sp,48
    800028c4:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800028c6:	0000f497          	auipc	s1,0xf
    800028ca:	e0a48493          	addi	s1,s1,-502 # 800116d0 <proc>
      pp->parent = initproc;
    800028ce:	00006a17          	auipc	s4,0x6
    800028d2:	75aa0a13          	addi	s4,s4,1882 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800028d6:	0001d997          	auipc	s3,0x1d
    800028da:	dfa98993          	addi	s3,s3,-518 # 8001f6d0 <tickslock>
    800028de:	a029                	j	800028e8 <reparent+0x34>
    800028e0:	38048493          	addi	s1,s1,896
    800028e4:	01348d63          	beq	s1,s3,800028fe <reparent+0x4a>
    if(pp->parent == p){
    800028e8:	7c9c                	ld	a5,56(s1)
    800028ea:	ff279be3          	bne	a5,s2,800028e0 <reparent+0x2c>
      pp->parent = initproc;
    800028ee:	000a3503          	ld	a0,0(s4)
    800028f2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800028f4:	00000097          	auipc	ra,0x0
    800028f8:	f4a080e7          	jalr	-182(ra) # 8000283e <wakeup>
    800028fc:	b7d5                	j	800028e0 <reparent+0x2c>
}
    800028fe:	70a2                	ld	ra,40(sp)
    80002900:	7402                	ld	s0,32(sp)
    80002902:	64e2                	ld	s1,24(sp)
    80002904:	6942                	ld	s2,16(sp)
    80002906:	69a2                	ld	s3,8(sp)
    80002908:	6a02                	ld	s4,0(sp)
    8000290a:	6145                	addi	sp,sp,48
    8000290c:	8082                	ret

000000008000290e <exit>:
{
    8000290e:	7179                	addi	sp,sp,-48
    80002910:	f406                	sd	ra,40(sp)
    80002912:	f022                	sd	s0,32(sp)
    80002914:	ec26                	sd	s1,24(sp)
    80002916:	e84a                	sd	s2,16(sp)
    80002918:	e44e                	sd	s3,8(sp)
    8000291a:	e052                	sd	s4,0(sp)
    8000291c:	1800                	addi	s0,sp,48
    8000291e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002920:	fffff097          	auipc	ra,0xfffff
    80002924:	520080e7          	jalr	1312(ra) # 80001e40 <myproc>
    80002928:	89aa                	mv	s3,a0
  if(p == initproc)
    8000292a:	00006797          	auipc	a5,0x6
    8000292e:	6fe7b783          	ld	a5,1790(a5) # 80009028 <initproc>
    80002932:	0d050493          	addi	s1,a0,208
    80002936:	15050913          	addi	s2,a0,336
    8000293a:	02a79363          	bne	a5,a0,80002960 <exit+0x52>
    panic("init exiting");
    8000293e:	00006517          	auipc	a0,0x6
    80002942:	9ba50513          	addi	a0,a0,-1606 # 800082f8 <digits+0x2b8>
    80002946:	ffffe097          	auipc	ra,0xffffe
    8000294a:	be4080e7          	jalr	-1052(ra) # 8000052a <panic>
      fileclose(f);
    8000294e:	00002097          	auipc	ra,0x2
    80002952:	5cc080e7          	jalr	1484(ra) # 80004f1a <fileclose>
      p->ofile[fd] = 0;
    80002956:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000295a:	04a1                	addi	s1,s1,8
    8000295c:	01248563          	beq	s1,s2,80002966 <exit+0x58>
    if(p->ofile[fd]){
    80002960:	6088                	ld	a0,0(s1)
    80002962:	f575                	bnez	a0,8000294e <exit+0x40>
    80002964:	bfdd                	j	8000295a <exit+0x4c>
  begin_op();
    80002966:	00002097          	auipc	ra,0x2
    8000296a:	0e8080e7          	jalr	232(ra) # 80004a4e <begin_op>
  iput(p->cwd);
    8000296e:	1509b503          	ld	a0,336(s3)
    80002972:	00001097          	auipc	ra,0x1
    80002976:	5ae080e7          	jalr	1454(ra) # 80003f20 <iput>
  end_op();
    8000297a:	00002097          	auipc	ra,0x2
    8000297e:	154080e7          	jalr	340(ra) # 80004ace <end_op>
  p->cwd = 0;
    80002982:	1409b823          	sd	zero,336(s3)
    if(p->pid >=3 && p->swapFile!=0)
    80002986:	0309a703          	lw	a4,48(s3)
    8000298a:	4789                	li	a5,2
    8000298c:	00e7da63          	bge	a5,a4,800029a0 <exit+0x92>
    80002990:	1689b783          	ld	a5,360(s3)
    80002994:	c791                	beqz	a5,800029a0 <exit+0x92>
      removeSwapFile(p);
    80002996:	854e                	mv	a0,s3
    80002998:	00002097          	auipc	ra,0x2
    8000299c:	c30080e7          	jalr	-976(ra) # 800045c8 <removeSwapFile>
  acquire(&wait_lock);
    800029a0:	0000f497          	auipc	s1,0xf
    800029a4:	91848493          	addi	s1,s1,-1768 # 800112b8 <wait_lock>
    800029a8:	8526                	mv	a0,s1
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	238080e7          	jalr	568(ra) # 80000be2 <acquire>
  reparent(p);
    800029b2:	854e                	mv	a0,s3
    800029b4:	00000097          	auipc	ra,0x0
    800029b8:	f00080e7          	jalr	-256(ra) # 800028b4 <reparent>
  wakeup(p->parent);
    800029bc:	0389b503          	ld	a0,56(s3)
    800029c0:	00000097          	auipc	ra,0x0
    800029c4:	e7e080e7          	jalr	-386(ra) # 8000283e <wakeup>
  acquire(&p->lock);
    800029c8:	854e                	mv	a0,s3
    800029ca:	ffffe097          	auipc	ra,0xffffe
    800029ce:	218080e7          	jalr	536(ra) # 80000be2 <acquire>
  p->xstate = status;
    800029d2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800029d6:	4795                	li	a5,5
    800029d8:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800029dc:	8526                	mv	a0,s1
    800029de:	ffffe097          	auipc	ra,0xffffe
    800029e2:	2b8080e7          	jalr	696(ra) # 80000c96 <release>
  sched();
    800029e6:	00000097          	auipc	ra,0x0
    800029ea:	bba080e7          	jalr	-1094(ra) # 800025a0 <sched>
  panic("zombie exit");
    800029ee:	00006517          	auipc	a0,0x6
    800029f2:	91a50513          	addi	a0,a0,-1766 # 80008308 <digits+0x2c8>
    800029f6:	ffffe097          	auipc	ra,0xffffe
    800029fa:	b34080e7          	jalr	-1228(ra) # 8000052a <panic>

00000000800029fe <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800029fe:	7179                	addi	sp,sp,-48
    80002a00:	f406                	sd	ra,40(sp)
    80002a02:	f022                	sd	s0,32(sp)
    80002a04:	ec26                	sd	s1,24(sp)
    80002a06:	e84a                	sd	s2,16(sp)
    80002a08:	e44e                	sd	s3,8(sp)
    80002a0a:	1800                	addi	s0,sp,48
    80002a0c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002a0e:	0000f497          	auipc	s1,0xf
    80002a12:	cc248493          	addi	s1,s1,-830 # 800116d0 <proc>
    80002a16:	0001d997          	auipc	s3,0x1d
    80002a1a:	cba98993          	addi	s3,s3,-838 # 8001f6d0 <tickslock>
    acquire(&p->lock);
    80002a1e:	8526                	mv	a0,s1
    80002a20:	ffffe097          	auipc	ra,0xffffe
    80002a24:	1c2080e7          	jalr	450(ra) # 80000be2 <acquire>
    if(p->pid == pid){
    80002a28:	589c                	lw	a5,48(s1)
    80002a2a:	01278d63          	beq	a5,s2,80002a44 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002a2e:	8526                	mv	a0,s1
    80002a30:	ffffe097          	auipc	ra,0xffffe
    80002a34:	266080e7          	jalr	614(ra) # 80000c96 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a38:	38048493          	addi	s1,s1,896
    80002a3c:	ff3491e3          	bne	s1,s3,80002a1e <kill+0x20>
  }
  return -1;
    80002a40:	557d                	li	a0,-1
    80002a42:	a829                	j	80002a5c <kill+0x5e>
      p->killed = 1;
    80002a44:	4785                	li	a5,1
    80002a46:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002a48:	4c98                	lw	a4,24(s1)
    80002a4a:	4789                	li	a5,2
    80002a4c:	00f70f63          	beq	a4,a5,80002a6a <kill+0x6c>
      release(&p->lock);
    80002a50:	8526                	mv	a0,s1
    80002a52:	ffffe097          	auipc	ra,0xffffe
    80002a56:	244080e7          	jalr	580(ra) # 80000c96 <release>
      return 0;
    80002a5a:	4501                	li	a0,0
}
    80002a5c:	70a2                	ld	ra,40(sp)
    80002a5e:	7402                	ld	s0,32(sp)
    80002a60:	64e2                	ld	s1,24(sp)
    80002a62:	6942                	ld	s2,16(sp)
    80002a64:	69a2                	ld	s3,8(sp)
    80002a66:	6145                	addi	sp,sp,48
    80002a68:	8082                	ret
        p->state = RUNNABLE;
    80002a6a:	478d                	li	a5,3
    80002a6c:	cc9c                	sw	a5,24(s1)
    80002a6e:	b7cd                	j	80002a50 <kill+0x52>

0000000080002a70 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002a70:	7179                	addi	sp,sp,-48
    80002a72:	f406                	sd	ra,40(sp)
    80002a74:	f022                	sd	s0,32(sp)
    80002a76:	ec26                	sd	s1,24(sp)
    80002a78:	e84a                	sd	s2,16(sp)
    80002a7a:	e44e                	sd	s3,8(sp)
    80002a7c:	e052                	sd	s4,0(sp)
    80002a7e:	1800                	addi	s0,sp,48
    80002a80:	84aa                	mv	s1,a0
    80002a82:	892e                	mv	s2,a1
    80002a84:	89b2                	mv	s3,a2
    80002a86:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a88:	fffff097          	auipc	ra,0xfffff
    80002a8c:	3b8080e7          	jalr	952(ra) # 80001e40 <myproc>
  if(user_dst){
    80002a90:	c08d                	beqz	s1,80002ab2 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002a92:	86d2                	mv	a3,s4
    80002a94:	864e                	mv	a2,s3
    80002a96:	85ca                	mv	a1,s2
    80002a98:	6928                	ld	a0,80(a0)
    80002a9a:	fffff097          	auipc	ra,0xfffff
    80002a9e:	066080e7          	jalr	102(ra) # 80001b00 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002aa2:	70a2                	ld	ra,40(sp)
    80002aa4:	7402                	ld	s0,32(sp)
    80002aa6:	64e2                	ld	s1,24(sp)
    80002aa8:	6942                	ld	s2,16(sp)
    80002aaa:	69a2                	ld	s3,8(sp)
    80002aac:	6a02                	ld	s4,0(sp)
    80002aae:	6145                	addi	sp,sp,48
    80002ab0:	8082                	ret
    memmove((char *)dst, src, len);
    80002ab2:	000a061b          	sext.w	a2,s4
    80002ab6:	85ce                	mv	a1,s3
    80002ab8:	854a                	mv	a0,s2
    80002aba:	ffffe097          	auipc	ra,0xffffe
    80002abe:	280080e7          	jalr	640(ra) # 80000d3a <memmove>
    return 0;
    80002ac2:	8526                	mv	a0,s1
    80002ac4:	bff9                	j	80002aa2 <either_copyout+0x32>

0000000080002ac6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002ac6:	7179                	addi	sp,sp,-48
    80002ac8:	f406                	sd	ra,40(sp)
    80002aca:	f022                	sd	s0,32(sp)
    80002acc:	ec26                	sd	s1,24(sp)
    80002ace:	e84a                	sd	s2,16(sp)
    80002ad0:	e44e                	sd	s3,8(sp)
    80002ad2:	e052                	sd	s4,0(sp)
    80002ad4:	1800                	addi	s0,sp,48
    80002ad6:	892a                	mv	s2,a0
    80002ad8:	84ae                	mv	s1,a1
    80002ada:	89b2                	mv	s3,a2
    80002adc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002ade:	fffff097          	auipc	ra,0xfffff
    80002ae2:	362080e7          	jalr	866(ra) # 80001e40 <myproc>
  if(user_src){
    80002ae6:	c08d                	beqz	s1,80002b08 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002ae8:	86d2                	mv	a3,s4
    80002aea:	864e                	mv	a2,s3
    80002aec:	85ca                	mv	a1,s2
    80002aee:	6928                	ld	a0,80(a0)
    80002af0:	fffff097          	auipc	ra,0xfffff
    80002af4:	09c080e7          	jalr	156(ra) # 80001b8c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002af8:	70a2                	ld	ra,40(sp)
    80002afa:	7402                	ld	s0,32(sp)
    80002afc:	64e2                	ld	s1,24(sp)
    80002afe:	6942                	ld	s2,16(sp)
    80002b00:	69a2                	ld	s3,8(sp)
    80002b02:	6a02                	ld	s4,0(sp)
    80002b04:	6145                	addi	sp,sp,48
    80002b06:	8082                	ret
    memmove(dst, (char*)src, len);
    80002b08:	000a061b          	sext.w	a2,s4
    80002b0c:	85ce                	mv	a1,s3
    80002b0e:	854a                	mv	a0,s2
    80002b10:	ffffe097          	auipc	ra,0xffffe
    80002b14:	22a080e7          	jalr	554(ra) # 80000d3a <memmove>
    return 0;
    80002b18:	8526                	mv	a0,s1
    80002b1a:	bff9                	j	80002af8 <either_copyin+0x32>

0000000080002b1c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002b1c:	715d                	addi	sp,sp,-80
    80002b1e:	e486                	sd	ra,72(sp)
    80002b20:	e0a2                	sd	s0,64(sp)
    80002b22:	fc26                	sd	s1,56(sp)
    80002b24:	f84a                	sd	s2,48(sp)
    80002b26:	f44e                	sd	s3,40(sp)
    80002b28:	f052                	sd	s4,32(sp)
    80002b2a:	ec56                	sd	s5,24(sp)
    80002b2c:	e85a                	sd	s6,16(sp)
    80002b2e:	e45e                	sd	s7,8(sp)
    80002b30:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002b32:	00005517          	auipc	a0,0x5
    80002b36:	5a650513          	addi	a0,a0,1446 # 800080d8 <digits+0x98>
    80002b3a:	ffffe097          	auipc	ra,0xffffe
    80002b3e:	a3a080e7          	jalr	-1478(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b42:	0000f497          	auipc	s1,0xf
    80002b46:	ce648493          	addi	s1,s1,-794 # 80011828 <proc+0x158>
    80002b4a:	0001d917          	auipc	s2,0x1d
    80002b4e:	cde90913          	addi	s2,s2,-802 # 8001f828 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b52:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002b54:	00005997          	auipc	s3,0x5
    80002b58:	7c498993          	addi	s3,s3,1988 # 80008318 <digits+0x2d8>
    printf("%d %s %s", p->pid, state, p->name);
    80002b5c:	00005a97          	auipc	s5,0x5
    80002b60:	7c4a8a93          	addi	s5,s5,1988 # 80008320 <digits+0x2e0>
    printf("\n");
    80002b64:	00005a17          	auipc	s4,0x5
    80002b68:	574a0a13          	addi	s4,s4,1396 # 800080d8 <digits+0x98>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b6c:	00005b97          	auipc	s7,0x5
    80002b70:	7ecb8b93          	addi	s7,s7,2028 # 80008358 <states.0>
    80002b74:	a00d                	j	80002b96 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002b76:	ed86a583          	lw	a1,-296(a3) # ed8 <_entry-0x7ffff128>
    80002b7a:	8556                	mv	a0,s5
    80002b7c:	ffffe097          	auipc	ra,0xffffe
    80002b80:	9f8080e7          	jalr	-1544(ra) # 80000574 <printf>
    printf("\n");
    80002b84:	8552                	mv	a0,s4
    80002b86:	ffffe097          	auipc	ra,0xffffe
    80002b8a:	9ee080e7          	jalr	-1554(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b8e:	38048493          	addi	s1,s1,896
    80002b92:	03248263          	beq	s1,s2,80002bb6 <procdump+0x9a>
    if(p->state == UNUSED)
    80002b96:	86a6                	mv	a3,s1
    80002b98:	ec04a783          	lw	a5,-320(s1)
    80002b9c:	dbed                	beqz	a5,80002b8e <procdump+0x72>
      state = "???";
    80002b9e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002ba0:	fcfb6be3          	bltu	s6,a5,80002b76 <procdump+0x5a>
    80002ba4:	02079713          	slli	a4,a5,0x20
    80002ba8:	01d75793          	srli	a5,a4,0x1d
    80002bac:	97de                	add	a5,a5,s7
    80002bae:	6390                	ld	a2,0(a5)
    80002bb0:	f279                	bnez	a2,80002b76 <procdump+0x5a>
      state = "???";
    80002bb2:	864e                	mv	a2,s3
    80002bb4:	b7c9                	j	80002b76 <procdump+0x5a>
  }
}
    80002bb6:	60a6                	ld	ra,72(sp)
    80002bb8:	6406                	ld	s0,64(sp)
    80002bba:	74e2                	ld	s1,56(sp)
    80002bbc:	7942                	ld	s2,48(sp)
    80002bbe:	79a2                	ld	s3,40(sp)
    80002bc0:	7a02                	ld	s4,32(sp)
    80002bc2:	6ae2                	ld	s5,24(sp)
    80002bc4:	6b42                	ld	s6,16(sp)
    80002bc6:	6ba2                	ld	s7,8(sp)
    80002bc8:	6161                	addi	sp,sp,80
    80002bca:	8082                	ret

0000000080002bcc <swtch>:
    80002bcc:	00153023          	sd	ra,0(a0)
    80002bd0:	00253423          	sd	sp,8(a0)
    80002bd4:	e900                	sd	s0,16(a0)
    80002bd6:	ed04                	sd	s1,24(a0)
    80002bd8:	03253023          	sd	s2,32(a0)
    80002bdc:	03353423          	sd	s3,40(a0)
    80002be0:	03453823          	sd	s4,48(a0)
    80002be4:	03553c23          	sd	s5,56(a0)
    80002be8:	05653023          	sd	s6,64(a0)
    80002bec:	05753423          	sd	s7,72(a0)
    80002bf0:	05853823          	sd	s8,80(a0)
    80002bf4:	05953c23          	sd	s9,88(a0)
    80002bf8:	07a53023          	sd	s10,96(a0)
    80002bfc:	07b53423          	sd	s11,104(a0)
    80002c00:	0005b083          	ld	ra,0(a1)
    80002c04:	0085b103          	ld	sp,8(a1)
    80002c08:	6980                	ld	s0,16(a1)
    80002c0a:	6d84                	ld	s1,24(a1)
    80002c0c:	0205b903          	ld	s2,32(a1)
    80002c10:	0285b983          	ld	s3,40(a1)
    80002c14:	0305ba03          	ld	s4,48(a1)
    80002c18:	0385ba83          	ld	s5,56(a1)
    80002c1c:	0405bb03          	ld	s6,64(a1)
    80002c20:	0485bb83          	ld	s7,72(a1)
    80002c24:	0505bc03          	ld	s8,80(a1)
    80002c28:	0585bc83          	ld	s9,88(a1)
    80002c2c:	0605bd03          	ld	s10,96(a1)
    80002c30:	0685bd83          	ld	s11,104(a1)
    80002c34:	8082                	ret

0000000080002c36 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002c36:	1141                	addi	sp,sp,-16
    80002c38:	e406                	sd	ra,8(sp)
    80002c3a:	e022                	sd	s0,0(sp)
    80002c3c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002c3e:	00005597          	auipc	a1,0x5
    80002c42:	74a58593          	addi	a1,a1,1866 # 80008388 <states.0+0x30>
    80002c46:	0001d517          	auipc	a0,0x1d
    80002c4a:	a8a50513          	addi	a0,a0,-1398 # 8001f6d0 <tickslock>
    80002c4e:	ffffe097          	auipc	ra,0xffffe
    80002c52:	f04080e7          	jalr	-252(ra) # 80000b52 <initlock>
}
    80002c56:	60a2                	ld	ra,8(sp)
    80002c58:	6402                	ld	s0,0(sp)
    80002c5a:	0141                	addi	sp,sp,16
    80002c5c:	8082                	ret

0000000080002c5e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002c5e:	1141                	addi	sp,sp,-16
    80002c60:	e422                	sd	s0,8(sp)
    80002c62:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c64:	00004797          	auipc	a5,0x4
    80002c68:	b1c78793          	addi	a5,a5,-1252 # 80006780 <kernelvec>
    80002c6c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002c70:	6422                	ld	s0,8(sp)
    80002c72:	0141                	addi	sp,sp,16
    80002c74:	8082                	ret

0000000080002c76 <insertPageToRam>:

void insertPageToRam(int index){
    80002c76:	7179                	addi	sp,sp,-48
    80002c78:	f406                	sd	ra,40(sp)
    80002c7a:	f022                	sd	s0,32(sp)
    80002c7c:	ec26                	sd	s1,24(sp)
    80002c7e:	e84a                	sd	s2,16(sp)
    80002c80:	e44e                	sd	s3,8(sp)
    80002c82:	1800                	addi	s0,sp,48
    80002c84:	892a                	mv	s2,a0

  struct proc *p = myproc();
    80002c86:	fffff097          	auipc	ra,0xfffff
    80002c8a:	1ba080e7          	jalr	442(ra) # 80001e40 <myproc>
    80002c8e:	84aa                	mv	s1,a0
  if (p->ram_pages_counter == MAX_PSYC_PAGES)
    80002c90:	27052703          	lw	a4,624(a0)
    80002c94:	47c1                	li	a5,16
    80002c96:	0af70063          	beq	a4,a5,80002d36 <insertPageToRam+0xc0>
    swapPageToFile();

  uvmalloc(p->pagetable, p->sz, p->sz + PGSIZE);
    80002c9a:	64ac                	ld	a1,72(s1)
    80002c9c:	6605                	lui	a2,0x1
    80002c9e:	962e                	add	a2,a2,a1
    80002ca0:	68a8                	ld	a0,80(s1)
    80002ca2:	fffff097          	auipc	ra,0xfffff
    80002ca6:	bdc080e7          	jalr	-1060(ra) # 8000187e <uvmalloc>
  uint64 buffer;
  buffer = walkaddr(p->pagetable, p->pages_in_file[index].va);
    80002caa:	02790793          	addi	a5,s2,39
    80002cae:	0792                	slli	a5,a5,0x4
    80002cb0:	97a6                	add	a5,a5,s1
    80002cb2:	678c                	ld	a1,8(a5)
    80002cb4:	68a8                	ld	a0,80(s1)
    80002cb6:	ffffe097          	auipc	ra,0xffffe
    80002cba:	3b6080e7          	jalr	950(ra) # 8000106c <walkaddr>
    80002cbe:	89aa                	mv	s3,a0
  printf("read invoked from insertPageToRam\n");
    80002cc0:	00005517          	auipc	a0,0x5
    80002cc4:	6d050513          	addi	a0,a0,1744 # 80008390 <states.0+0x38>
    80002cc8:	ffffe097          	auipc	ra,0xffffe
    80002ccc:	8ac080e7          	jalr	-1876(ra) # 80000574 <printf>
  readFromSwapFile(p, (char *)buffer, index*PGSIZE, PGSIZE);
    80002cd0:	6685                	lui	a3,0x1
    80002cd2:	00c9161b          	slliw	a2,s2,0xc
    80002cd6:	85ce                	mv	a1,s3
    80002cd8:	8526                	mv	a0,s1
    80002cda:	00002097          	auipc	ra,0x2
    80002cde:	b6a080e7          	jalr	-1174(ra) # 80004844 <readFromSwapFile>
  
  for(int i=0; i<MAX_PSYC_PAGES; i++){
    80002ce2:	17848713          	addi	a4,s1,376
    80002ce6:	4781                	li	a5,0
    80002ce8:	4641                	li	a2,16
    if(p->pages_in_ram[i].is_free == 0)
    80002cea:	4314                	lw	a3,0(a4)
    80002cec:	cab1                	beqz	a3,80002d40 <insertPageToRam+0xca>
      continue;
    p->pages_in_ram[i].va = p->sz;
    80002cee:	64b4                	ld	a3,72(s1)
    80002cf0:	00479713          	slli	a4,a5,0x4
    80002cf4:	9726                	add	a4,a4,s1
    80002cf6:	16d73823          	sd	a3,368(a4)
    p->ram_pages_counter ++ ;
    80002cfa:	2704a683          	lw	a3,624(s1)
    80002cfe:	2685                	addiw	a3,a3,1
    80002d00:	26d4a823          	sw	a3,624(s1)
    p->pages_in_ram[i].is_free = 0;
    80002d04:	16072c23          	sw	zero,376(a4)
    index = i;
    break;
  }
  pte_t *pte;
  pte = walk(p->pagetable, p->pages_in_ram[index].va, 0);
    80002d08:	07dd                	addi	a5,a5,23
    80002d0a:	0792                	slli	a5,a5,0x4
    80002d0c:	97a6                	add	a5,a5,s1
    80002d0e:	4601                	li	a2,0
    80002d10:	638c                	ld	a1,0(a5)
    80002d12:	68a8                	ld	a0,80(s1)
    80002d14:	ffffe097          	auipc	ra,0xffffe
    80002d18:	2b2080e7          	jalr	690(ra) # 80000fc6 <walk>
  *pte &= ~PTE_PG;
    80002d1c:	611c                	ld	a5,0(a0)
    80002d1e:	dff7f793          	andi	a5,a5,-513
  *pte |= PTE_A;
  *pte |= PTE_V;
    80002d22:	0417e793          	ori	a5,a5,65
    80002d26:	e11c                	sd	a5,0(a0)
    p->pages_in_ram[index].age = 0xffffffff;

  //todo:
  // else if (selection == SCFIFO)

}
    80002d28:	70a2                	ld	ra,40(sp)
    80002d2a:	7402                	ld	s0,32(sp)
    80002d2c:	64e2                	ld	s1,24(sp)
    80002d2e:	6942                	ld	s2,16(sp)
    80002d30:	69a2                	ld	s3,8(sp)
    80002d32:	6145                	addi	sp,sp,48
    80002d34:	8082                	ret
    swapPageToFile();
    80002d36:	fffff097          	auipc	ra,0xfffff
    80002d3a:	8f8080e7          	jalr	-1800(ra) # 8000162e <swapPageToFile>
    80002d3e:	bfb1                	j	80002c9a <insertPageToRam+0x24>
  for(int i=0; i<MAX_PSYC_PAGES; i++){
    80002d40:	2785                	addiw	a5,a5,1
    80002d42:	0741                	addi	a4,a4,16
    80002d44:	fac793e3          	bne	a5,a2,80002cea <insertPageToRam+0x74>
    80002d48:	87ca                	mv	a5,s2
    80002d4a:	bf7d                	j	80002d08 <insertPageToRam+0x92>

0000000080002d4c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002d4c:	1141                	addi	sp,sp,-16
    80002d4e:	e406                	sd	ra,8(sp)
    80002d50:	e022                	sd	s0,0(sp)
    80002d52:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002d54:	fffff097          	auipc	ra,0xfffff
    80002d58:	0ec080e7          	jalr	236(ra) # 80001e40 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d5c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002d60:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d62:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002d66:	00004617          	auipc	a2,0x4
    80002d6a:	29a60613          	addi	a2,a2,666 # 80007000 <_trampoline>
    80002d6e:	00004697          	auipc	a3,0x4
    80002d72:	29268693          	addi	a3,a3,658 # 80007000 <_trampoline>
    80002d76:	8e91                	sub	a3,a3,a2
    80002d78:	040007b7          	lui	a5,0x4000
    80002d7c:	17fd                	addi	a5,a5,-1
    80002d7e:	07b2                	slli	a5,a5,0xc
    80002d80:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d82:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002d86:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002d88:	180026f3          	csrr	a3,satp
    80002d8c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002d8e:	6d38                	ld	a4,88(a0)
    80002d90:	6134                	ld	a3,64(a0)
    80002d92:	6585                	lui	a1,0x1
    80002d94:	96ae                	add	a3,a3,a1
    80002d96:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002d98:	6d38                	ld	a4,88(a0)
    80002d9a:	00000697          	auipc	a3,0x0
    80002d9e:	13868693          	addi	a3,a3,312 # 80002ed2 <usertrap>
    80002da2:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002da4:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002da6:	8692                	mv	a3,tp
    80002da8:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002daa:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002dae:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002db2:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002db6:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002dba:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002dbc:	6f18                	ld	a4,24(a4)
    80002dbe:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002dc2:	692c                	ld	a1,80(a0)
    80002dc4:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002dc6:	00004717          	auipc	a4,0x4
    80002dca:	2ca70713          	addi	a4,a4,714 # 80007090 <userret>
    80002dce:	8f11                	sub	a4,a4,a2
    80002dd0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002dd2:	577d                	li	a4,-1
    80002dd4:	177e                	slli	a4,a4,0x3f
    80002dd6:	8dd9                	or	a1,a1,a4
    80002dd8:	02000537          	lui	a0,0x2000
    80002ddc:	157d                	addi	a0,a0,-1
    80002dde:	0536                	slli	a0,a0,0xd
    80002de0:	9782                	jalr	a5
}
    80002de2:	60a2                	ld	ra,8(sp)
    80002de4:	6402                	ld	s0,0(sp)
    80002de6:	0141                	addi	sp,sp,16
    80002de8:	8082                	ret

0000000080002dea <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002dea:	1101                	addi	sp,sp,-32
    80002dec:	ec06                	sd	ra,24(sp)
    80002dee:	e822                	sd	s0,16(sp)
    80002df0:	e426                	sd	s1,8(sp)
    80002df2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002df4:	0001d497          	auipc	s1,0x1d
    80002df8:	8dc48493          	addi	s1,s1,-1828 # 8001f6d0 <tickslock>
    80002dfc:	8526                	mv	a0,s1
    80002dfe:	ffffe097          	auipc	ra,0xffffe
    80002e02:	de4080e7          	jalr	-540(ra) # 80000be2 <acquire>
  ticks++;
    80002e06:	00006517          	auipc	a0,0x6
    80002e0a:	22a50513          	addi	a0,a0,554 # 80009030 <ticks>
    80002e0e:	411c                	lw	a5,0(a0)
    80002e10:	2785                	addiw	a5,a5,1
    80002e12:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002e14:	00000097          	auipc	ra,0x0
    80002e18:	a2a080e7          	jalr	-1494(ra) # 8000283e <wakeup>
  release(&tickslock);
    80002e1c:	8526                	mv	a0,s1
    80002e1e:	ffffe097          	auipc	ra,0xffffe
    80002e22:	e78080e7          	jalr	-392(ra) # 80000c96 <release>
}
    80002e26:	60e2                	ld	ra,24(sp)
    80002e28:	6442                	ld	s0,16(sp)
    80002e2a:	64a2                	ld	s1,8(sp)
    80002e2c:	6105                	addi	sp,sp,32
    80002e2e:	8082                	ret

0000000080002e30 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002e30:	1101                	addi	sp,sp,-32
    80002e32:	ec06                	sd	ra,24(sp)
    80002e34:	e822                	sd	s0,16(sp)
    80002e36:	e426                	sd	s1,8(sp)
    80002e38:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e3a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002e3e:	00074d63          	bltz	a4,80002e58 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002e42:	57fd                	li	a5,-1
    80002e44:	17fe                	slli	a5,a5,0x3f
    80002e46:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002e48:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002e4a:	06f70363          	beq	a4,a5,80002eb0 <devintr+0x80>
  }
}
    80002e4e:	60e2                	ld	ra,24(sp)
    80002e50:	6442                	ld	s0,16(sp)
    80002e52:	64a2                	ld	s1,8(sp)
    80002e54:	6105                	addi	sp,sp,32
    80002e56:	8082                	ret
     (scause & 0xff) == 9){
    80002e58:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002e5c:	46a5                	li	a3,9
    80002e5e:	fed792e3          	bne	a5,a3,80002e42 <devintr+0x12>
    int irq = plic_claim();
    80002e62:	00004097          	auipc	ra,0x4
    80002e66:	a26080e7          	jalr	-1498(ra) # 80006888 <plic_claim>
    80002e6a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002e6c:	47a9                	li	a5,10
    80002e6e:	02f50763          	beq	a0,a5,80002e9c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002e72:	4785                	li	a5,1
    80002e74:	02f50963          	beq	a0,a5,80002ea6 <devintr+0x76>
    return 1;
    80002e78:	4505                	li	a0,1
    } else if(irq){
    80002e7a:	d8f1                	beqz	s1,80002e4e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002e7c:	85a6                	mv	a1,s1
    80002e7e:	00005517          	auipc	a0,0x5
    80002e82:	53a50513          	addi	a0,a0,1338 # 800083b8 <states.0+0x60>
    80002e86:	ffffd097          	auipc	ra,0xffffd
    80002e8a:	6ee080e7          	jalr	1774(ra) # 80000574 <printf>
      plic_complete(irq);
    80002e8e:	8526                	mv	a0,s1
    80002e90:	00004097          	auipc	ra,0x4
    80002e94:	a1c080e7          	jalr	-1508(ra) # 800068ac <plic_complete>
    return 1;
    80002e98:	4505                	li	a0,1
    80002e9a:	bf55                	j	80002e4e <devintr+0x1e>
      uartintr();
    80002e9c:	ffffe097          	auipc	ra,0xffffe
    80002ea0:	aea080e7          	jalr	-1302(ra) # 80000986 <uartintr>
    80002ea4:	b7ed                	j	80002e8e <devintr+0x5e>
      virtio_disk_intr();
    80002ea6:	00004097          	auipc	ra,0x4
    80002eaa:	e98080e7          	jalr	-360(ra) # 80006d3e <virtio_disk_intr>
    80002eae:	b7c5                	j	80002e8e <devintr+0x5e>
    if(cpuid() == 0){
    80002eb0:	fffff097          	auipc	ra,0xfffff
    80002eb4:	f64080e7          	jalr	-156(ra) # 80001e14 <cpuid>
    80002eb8:	c901                	beqz	a0,80002ec8 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002eba:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002ebe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ec0:	14479073          	csrw	sip,a5
    return 2;
    80002ec4:	4509                	li	a0,2
    80002ec6:	b761                	j	80002e4e <devintr+0x1e>
      clockintr();
    80002ec8:	00000097          	auipc	ra,0x0
    80002ecc:	f22080e7          	jalr	-222(ra) # 80002dea <clockintr>
    80002ed0:	b7ed                	j	80002eba <devintr+0x8a>

0000000080002ed2 <usertrap>:
{
    80002ed2:	1101                	addi	sp,sp,-32
    80002ed4:	ec06                	sd	ra,24(sp)
    80002ed6:	e822                	sd	s0,16(sp)
    80002ed8:	e426                	sd	s1,8(sp)
    80002eda:	e04a                	sd	s2,0(sp)
    80002edc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ede:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002ee2:	1007f793          	andi	a5,a5,256
    80002ee6:	ebbd                	bnez	a5,80002f5c <usertrap+0x8a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ee8:	00004797          	auipc	a5,0x4
    80002eec:	89878793          	addi	a5,a5,-1896 # 80006780 <kernelvec>
    80002ef0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ef4:	fffff097          	auipc	ra,0xfffff
    80002ef8:	f4c080e7          	jalr	-180(ra) # 80001e40 <myproc>
    80002efc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002efe:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f00:	14102773          	csrr	a4,sepc
    80002f04:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f06:	14202773          	csrr	a4,scause
    if(r_scause() == 13 || r_scause() == 15){
    80002f0a:	47b5                	li	a5,13
    80002f0c:	06f70063          	beq	a4,a5,80002f6c <usertrap+0x9a>
    80002f10:	14202773          	csrr	a4,scause
    80002f14:	47bd                	li	a5,15
    80002f16:	04f70b63          	beq	a4,a5,80002f6c <usertrap+0x9a>
    80002f1a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002f1e:	47a1                	li	a5,8
    80002f20:	0af71263          	bne	a4,a5,80002fc4 <usertrap+0xf2>
    if(p->killed)
    80002f24:	549c                	lw	a5,40(s1)
    80002f26:	ebc9                	bnez	a5,80002fb8 <usertrap+0xe6>
    p->trapframe->epc += 4;
    80002f28:	6cb8                	ld	a4,88(s1)
    80002f2a:	6f1c                	ld	a5,24(a4)
    80002f2c:	0791                	addi	a5,a5,4
    80002f2e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f30:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002f34:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f38:	10079073          	csrw	sstatus,a5
    syscall();
    80002f3c:	00000097          	auipc	ra,0x0
    80002f40:	32c080e7          	jalr	812(ra) # 80003268 <syscall>
  if(p->killed)
    80002f44:	549c                	lw	a5,40(s1)
    80002f46:	eff1                	bnez	a5,80003022 <usertrap+0x150>
  usertrapret();
    80002f48:	00000097          	auipc	ra,0x0
    80002f4c:	e04080e7          	jalr	-508(ra) # 80002d4c <usertrapret>
}
    80002f50:	60e2                	ld	ra,24(sp)
    80002f52:	6442                	ld	s0,16(sp)
    80002f54:	64a2                	ld	s1,8(sp)
    80002f56:	6902                	ld	s2,0(sp)
    80002f58:	6105                	addi	sp,sp,32
    80002f5a:	8082                	ret
    panic("usertrap: not from user mode");
    80002f5c:	00005517          	auipc	a0,0x5
    80002f60:	47c50513          	addi	a0,a0,1148 # 800083d8 <states.0+0x80>
    80002f64:	ffffd097          	auipc	ra,0xffffd
    80002f68:	5c6080e7          	jalr	1478(ra) # 8000052a <panic>
      printf("PG_FAULT!\n");
    80002f6c:	00005517          	auipc	a0,0x5
    80002f70:	48c50513          	addi	a0,a0,1164 # 800083f8 <states.0+0xa0>
    80002f74:	ffffd097          	auipc	ra,0xffffd
    80002f78:	600080e7          	jalr	1536(ra) # 80000574 <printf>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f7c:	14302973          	csrr	s2,stval
      pte_t *pte = walk(p->pagetable, va, 0);
    80002f80:	4601                	li	a2,0
    80002f82:	85ca                	mv	a1,s2
    80002f84:	68a8                	ld	a0,80(s1)
    80002f86:	ffffe097          	auipc	ra,0xffffe
    80002f8a:	040080e7          	jalr	64(ra) # 80000fc6 <walk>
      if(*pte & PTE_PG){
    80002f8e:	611c                	ld	a5,0(a0)
    80002f90:	2007f793          	andi	a5,a5,512
    80002f94:	d3d9                	beqz	a5,80002f1a <usertrap+0x48>
    80002f96:	27848793          	addi	a5,s1,632
        for(int i=0; i< MAX_PSYC_PAGES; i++){
    80002f9a:	4501                	li	a0,0
    80002f9c:	46c1                	li	a3,16
          if(p->pages_in_file[i].va == va){
    80002f9e:	6398                	ld	a4,0(a5)
    80002fa0:	01270763          	beq	a4,s2,80002fae <usertrap+0xdc>
        for(int i=0; i< MAX_PSYC_PAGES; i++){
    80002fa4:	2505                	addiw	a0,a0,1
    80002fa6:	07c1                	addi	a5,a5,16
    80002fa8:	fed51be3          	bne	a0,a3,80002f9e <usertrap+0xcc>
    80002fac:	b7bd                	j	80002f1a <usertrap+0x48>
            insertPageToRam(i);
    80002fae:	00000097          	auipc	ra,0x0
    80002fb2:	cc8080e7          	jalr	-824(ra) # 80002c76 <insertPageToRam>
            break;
    80002fb6:	b795                	j	80002f1a <usertrap+0x48>
      exit(-1);
    80002fb8:	557d                	li	a0,-1
    80002fba:	00000097          	auipc	ra,0x0
    80002fbe:	954080e7          	jalr	-1708(ra) # 8000290e <exit>
    80002fc2:	b79d                	j	80002f28 <usertrap+0x56>
  } else if((which_dev = devintr()) != 0){
    80002fc4:	00000097          	auipc	ra,0x0
    80002fc8:	e6c080e7          	jalr	-404(ra) # 80002e30 <devintr>
    80002fcc:	892a                	mv	s2,a0
    80002fce:	c501                	beqz	a0,80002fd6 <usertrap+0x104>
  if(p->killed)
    80002fd0:	549c                	lw	a5,40(s1)
    80002fd2:	c3a1                	beqz	a5,80003012 <usertrap+0x140>
    80002fd4:	a815                	j	80003008 <usertrap+0x136>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fd6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002fda:	5890                	lw	a2,48(s1)
    80002fdc:	00005517          	auipc	a0,0x5
    80002fe0:	42c50513          	addi	a0,a0,1068 # 80008408 <states.0+0xb0>
    80002fe4:	ffffd097          	auipc	ra,0xffffd
    80002fe8:	590080e7          	jalr	1424(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fec:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ff0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ff4:	00005517          	auipc	a0,0x5
    80002ff8:	44450513          	addi	a0,a0,1092 # 80008438 <states.0+0xe0>
    80002ffc:	ffffd097          	auipc	ra,0xffffd
    80003000:	578080e7          	jalr	1400(ra) # 80000574 <printf>
    p->killed = 1;
    80003004:	4785                	li	a5,1
    80003006:	d49c                	sw	a5,40(s1)
    exit(-1);
    80003008:	557d                	li	a0,-1
    8000300a:	00000097          	auipc	ra,0x0
    8000300e:	904080e7          	jalr	-1788(ra) # 8000290e <exit>
  if(which_dev == 2)
    80003012:	4789                	li	a5,2
    80003014:	f2f91ae3          	bne	s2,a5,80002f48 <usertrap+0x76>
    yield();
    80003018:	fffff097          	auipc	ra,0xfffff
    8000301c:	65e080e7          	jalr	1630(ra) # 80002676 <yield>
    80003020:	b725                	j	80002f48 <usertrap+0x76>
  int which_dev = 0;
    80003022:	4901                	li	s2,0
    80003024:	b7d5                	j	80003008 <usertrap+0x136>

0000000080003026 <kerneltrap>:
{
    80003026:	7179                	addi	sp,sp,-48
    80003028:	f406                	sd	ra,40(sp)
    8000302a:	f022                	sd	s0,32(sp)
    8000302c:	ec26                	sd	s1,24(sp)
    8000302e:	e84a                	sd	s2,16(sp)
    80003030:	e44e                	sd	s3,8(sp)
    80003032:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003034:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003038:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000303c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003040:	1004f793          	andi	a5,s1,256
    80003044:	cb85                	beqz	a5,80003074 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003046:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000304a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000304c:	ef85                	bnez	a5,80003084 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000304e:	00000097          	auipc	ra,0x0
    80003052:	de2080e7          	jalr	-542(ra) # 80002e30 <devintr>
    80003056:	cd1d                	beqz	a0,80003094 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003058:	4789                	li	a5,2
    8000305a:	06f50a63          	beq	a0,a5,800030ce <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000305e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003062:	10049073          	csrw	sstatus,s1
}
    80003066:	70a2                	ld	ra,40(sp)
    80003068:	7402                	ld	s0,32(sp)
    8000306a:	64e2                	ld	s1,24(sp)
    8000306c:	6942                	ld	s2,16(sp)
    8000306e:	69a2                	ld	s3,8(sp)
    80003070:	6145                	addi	sp,sp,48
    80003072:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003074:	00005517          	auipc	a0,0x5
    80003078:	3e450513          	addi	a0,a0,996 # 80008458 <states.0+0x100>
    8000307c:	ffffd097          	auipc	ra,0xffffd
    80003080:	4ae080e7          	jalr	1198(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80003084:	00005517          	auipc	a0,0x5
    80003088:	3fc50513          	addi	a0,a0,1020 # 80008480 <states.0+0x128>
    8000308c:	ffffd097          	auipc	ra,0xffffd
    80003090:	49e080e7          	jalr	1182(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80003094:	85ce                	mv	a1,s3
    80003096:	00005517          	auipc	a0,0x5
    8000309a:	40a50513          	addi	a0,a0,1034 # 800084a0 <states.0+0x148>
    8000309e:	ffffd097          	auipc	ra,0xffffd
    800030a2:	4d6080e7          	jalr	1238(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030a6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800030aa:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800030ae:	00005517          	auipc	a0,0x5
    800030b2:	40250513          	addi	a0,a0,1026 # 800084b0 <states.0+0x158>
    800030b6:	ffffd097          	auipc	ra,0xffffd
    800030ba:	4be080e7          	jalr	1214(ra) # 80000574 <printf>
    panic("kerneltrap");
    800030be:	00005517          	auipc	a0,0x5
    800030c2:	40a50513          	addi	a0,a0,1034 # 800084c8 <states.0+0x170>
    800030c6:	ffffd097          	auipc	ra,0xffffd
    800030ca:	464080e7          	jalr	1124(ra) # 8000052a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800030ce:	fffff097          	auipc	ra,0xfffff
    800030d2:	d72080e7          	jalr	-654(ra) # 80001e40 <myproc>
    800030d6:	d541                	beqz	a0,8000305e <kerneltrap+0x38>
    800030d8:	fffff097          	auipc	ra,0xfffff
    800030dc:	d68080e7          	jalr	-664(ra) # 80001e40 <myproc>
    800030e0:	4d18                	lw	a4,24(a0)
    800030e2:	4791                	li	a5,4
    800030e4:	f6f71de3          	bne	a4,a5,8000305e <kerneltrap+0x38>
    yield();
    800030e8:	fffff097          	auipc	ra,0xfffff
    800030ec:	58e080e7          	jalr	1422(ra) # 80002676 <yield>
    800030f0:	b7bd                	j	8000305e <kerneltrap+0x38>

00000000800030f2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800030f2:	1101                	addi	sp,sp,-32
    800030f4:	ec06                	sd	ra,24(sp)
    800030f6:	e822                	sd	s0,16(sp)
    800030f8:	e426                	sd	s1,8(sp)
    800030fa:	1000                	addi	s0,sp,32
    800030fc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800030fe:	fffff097          	auipc	ra,0xfffff
    80003102:	d42080e7          	jalr	-702(ra) # 80001e40 <myproc>
  switch (n) {
    80003106:	4795                	li	a5,5
    80003108:	0497e163          	bltu	a5,s1,8000314a <argraw+0x58>
    8000310c:	048a                	slli	s1,s1,0x2
    8000310e:	00005717          	auipc	a4,0x5
    80003112:	3f270713          	addi	a4,a4,1010 # 80008500 <states.0+0x1a8>
    80003116:	94ba                	add	s1,s1,a4
    80003118:	409c                	lw	a5,0(s1)
    8000311a:	97ba                	add	a5,a5,a4
    8000311c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000311e:	6d3c                	ld	a5,88(a0)
    80003120:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003122:	60e2                	ld	ra,24(sp)
    80003124:	6442                	ld	s0,16(sp)
    80003126:	64a2                	ld	s1,8(sp)
    80003128:	6105                	addi	sp,sp,32
    8000312a:	8082                	ret
    return p->trapframe->a1;
    8000312c:	6d3c                	ld	a5,88(a0)
    8000312e:	7fa8                	ld	a0,120(a5)
    80003130:	bfcd                	j	80003122 <argraw+0x30>
    return p->trapframe->a2;
    80003132:	6d3c                	ld	a5,88(a0)
    80003134:	63c8                	ld	a0,128(a5)
    80003136:	b7f5                	j	80003122 <argraw+0x30>
    return p->trapframe->a3;
    80003138:	6d3c                	ld	a5,88(a0)
    8000313a:	67c8                	ld	a0,136(a5)
    8000313c:	b7dd                	j	80003122 <argraw+0x30>
    return p->trapframe->a4;
    8000313e:	6d3c                	ld	a5,88(a0)
    80003140:	6bc8                	ld	a0,144(a5)
    80003142:	b7c5                	j	80003122 <argraw+0x30>
    return p->trapframe->a5;
    80003144:	6d3c                	ld	a5,88(a0)
    80003146:	6fc8                	ld	a0,152(a5)
    80003148:	bfe9                	j	80003122 <argraw+0x30>
  panic("argraw");
    8000314a:	00005517          	auipc	a0,0x5
    8000314e:	38e50513          	addi	a0,a0,910 # 800084d8 <states.0+0x180>
    80003152:	ffffd097          	auipc	ra,0xffffd
    80003156:	3d8080e7          	jalr	984(ra) # 8000052a <panic>

000000008000315a <fetchaddr>:
{
    8000315a:	1101                	addi	sp,sp,-32
    8000315c:	ec06                	sd	ra,24(sp)
    8000315e:	e822                	sd	s0,16(sp)
    80003160:	e426                	sd	s1,8(sp)
    80003162:	e04a                	sd	s2,0(sp)
    80003164:	1000                	addi	s0,sp,32
    80003166:	84aa                	mv	s1,a0
    80003168:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000316a:	fffff097          	auipc	ra,0xfffff
    8000316e:	cd6080e7          	jalr	-810(ra) # 80001e40 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003172:	653c                	ld	a5,72(a0)
    80003174:	02f4f863          	bgeu	s1,a5,800031a4 <fetchaddr+0x4a>
    80003178:	00848713          	addi	a4,s1,8
    8000317c:	02e7e663          	bltu	a5,a4,800031a8 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003180:	46a1                	li	a3,8
    80003182:	8626                	mv	a2,s1
    80003184:	85ca                	mv	a1,s2
    80003186:	6928                	ld	a0,80(a0)
    80003188:	fffff097          	auipc	ra,0xfffff
    8000318c:	a04080e7          	jalr	-1532(ra) # 80001b8c <copyin>
    80003190:	00a03533          	snez	a0,a0
    80003194:	40a00533          	neg	a0,a0
}
    80003198:	60e2                	ld	ra,24(sp)
    8000319a:	6442                	ld	s0,16(sp)
    8000319c:	64a2                	ld	s1,8(sp)
    8000319e:	6902                	ld	s2,0(sp)
    800031a0:	6105                	addi	sp,sp,32
    800031a2:	8082                	ret
    return -1;
    800031a4:	557d                	li	a0,-1
    800031a6:	bfcd                	j	80003198 <fetchaddr+0x3e>
    800031a8:	557d                	li	a0,-1
    800031aa:	b7fd                	j	80003198 <fetchaddr+0x3e>

00000000800031ac <fetchstr>:
{
    800031ac:	7179                	addi	sp,sp,-48
    800031ae:	f406                	sd	ra,40(sp)
    800031b0:	f022                	sd	s0,32(sp)
    800031b2:	ec26                	sd	s1,24(sp)
    800031b4:	e84a                	sd	s2,16(sp)
    800031b6:	e44e                	sd	s3,8(sp)
    800031b8:	1800                	addi	s0,sp,48
    800031ba:	892a                	mv	s2,a0
    800031bc:	84ae                	mv	s1,a1
    800031be:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800031c0:	fffff097          	auipc	ra,0xfffff
    800031c4:	c80080e7          	jalr	-896(ra) # 80001e40 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800031c8:	86ce                	mv	a3,s3
    800031ca:	864a                	mv	a2,s2
    800031cc:	85a6                	mv	a1,s1
    800031ce:	6928                	ld	a0,80(a0)
    800031d0:	fffff097          	auipc	ra,0xfffff
    800031d4:	a4a080e7          	jalr	-1462(ra) # 80001c1a <copyinstr>
  if(err < 0)
    800031d8:	00054763          	bltz	a0,800031e6 <fetchstr+0x3a>
  return strlen(buf);
    800031dc:	8526                	mv	a0,s1
    800031de:	ffffe097          	auipc	ra,0xffffe
    800031e2:	c84080e7          	jalr	-892(ra) # 80000e62 <strlen>
}
    800031e6:	70a2                	ld	ra,40(sp)
    800031e8:	7402                	ld	s0,32(sp)
    800031ea:	64e2                	ld	s1,24(sp)
    800031ec:	6942                	ld	s2,16(sp)
    800031ee:	69a2                	ld	s3,8(sp)
    800031f0:	6145                	addi	sp,sp,48
    800031f2:	8082                	ret

00000000800031f4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800031f4:	1101                	addi	sp,sp,-32
    800031f6:	ec06                	sd	ra,24(sp)
    800031f8:	e822                	sd	s0,16(sp)
    800031fa:	e426                	sd	s1,8(sp)
    800031fc:	1000                	addi	s0,sp,32
    800031fe:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003200:	00000097          	auipc	ra,0x0
    80003204:	ef2080e7          	jalr	-270(ra) # 800030f2 <argraw>
    80003208:	c088                	sw	a0,0(s1)
  return 0;
}
    8000320a:	4501                	li	a0,0
    8000320c:	60e2                	ld	ra,24(sp)
    8000320e:	6442                	ld	s0,16(sp)
    80003210:	64a2                	ld	s1,8(sp)
    80003212:	6105                	addi	sp,sp,32
    80003214:	8082                	ret

0000000080003216 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003216:	1101                	addi	sp,sp,-32
    80003218:	ec06                	sd	ra,24(sp)
    8000321a:	e822                	sd	s0,16(sp)
    8000321c:	e426                	sd	s1,8(sp)
    8000321e:	1000                	addi	s0,sp,32
    80003220:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003222:	00000097          	auipc	ra,0x0
    80003226:	ed0080e7          	jalr	-304(ra) # 800030f2 <argraw>
    8000322a:	e088                	sd	a0,0(s1)
  return 0;
}
    8000322c:	4501                	li	a0,0
    8000322e:	60e2                	ld	ra,24(sp)
    80003230:	6442                	ld	s0,16(sp)
    80003232:	64a2                	ld	s1,8(sp)
    80003234:	6105                	addi	sp,sp,32
    80003236:	8082                	ret

0000000080003238 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003238:	1101                	addi	sp,sp,-32
    8000323a:	ec06                	sd	ra,24(sp)
    8000323c:	e822                	sd	s0,16(sp)
    8000323e:	e426                	sd	s1,8(sp)
    80003240:	e04a                	sd	s2,0(sp)
    80003242:	1000                	addi	s0,sp,32
    80003244:	84ae                	mv	s1,a1
    80003246:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003248:	00000097          	auipc	ra,0x0
    8000324c:	eaa080e7          	jalr	-342(ra) # 800030f2 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003250:	864a                	mv	a2,s2
    80003252:	85a6                	mv	a1,s1
    80003254:	00000097          	auipc	ra,0x0
    80003258:	f58080e7          	jalr	-168(ra) # 800031ac <fetchstr>
}
    8000325c:	60e2                	ld	ra,24(sp)
    8000325e:	6442                	ld	s0,16(sp)
    80003260:	64a2                	ld	s1,8(sp)
    80003262:	6902                	ld	s2,0(sp)
    80003264:	6105                	addi	sp,sp,32
    80003266:	8082                	ret

0000000080003268 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80003268:	1101                	addi	sp,sp,-32
    8000326a:	ec06                	sd	ra,24(sp)
    8000326c:	e822                	sd	s0,16(sp)
    8000326e:	e426                	sd	s1,8(sp)
    80003270:	e04a                	sd	s2,0(sp)
    80003272:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003274:	fffff097          	auipc	ra,0xfffff
    80003278:	bcc080e7          	jalr	-1076(ra) # 80001e40 <myproc>
    8000327c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000327e:	05853903          	ld	s2,88(a0)
    80003282:	0a893783          	ld	a5,168(s2)
    80003286:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000328a:	37fd                	addiw	a5,a5,-1
    8000328c:	4751                	li	a4,20
    8000328e:	00f76f63          	bltu	a4,a5,800032ac <syscall+0x44>
    80003292:	00369713          	slli	a4,a3,0x3
    80003296:	00005797          	auipc	a5,0x5
    8000329a:	28278793          	addi	a5,a5,642 # 80008518 <syscalls>
    8000329e:	97ba                	add	a5,a5,a4
    800032a0:	639c                	ld	a5,0(a5)
    800032a2:	c789                	beqz	a5,800032ac <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800032a4:	9782                	jalr	a5
    800032a6:	06a93823          	sd	a0,112(s2)
    800032aa:	a839                	j	800032c8 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800032ac:	15848613          	addi	a2,s1,344
    800032b0:	588c                	lw	a1,48(s1)
    800032b2:	00005517          	auipc	a0,0x5
    800032b6:	22e50513          	addi	a0,a0,558 # 800084e0 <states.0+0x188>
    800032ba:	ffffd097          	auipc	ra,0xffffd
    800032be:	2ba080e7          	jalr	698(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800032c2:	6cbc                	ld	a5,88(s1)
    800032c4:	577d                	li	a4,-1
    800032c6:	fbb8                	sd	a4,112(a5)
  }
}
    800032c8:	60e2                	ld	ra,24(sp)
    800032ca:	6442                	ld	s0,16(sp)
    800032cc:	64a2                	ld	s1,8(sp)
    800032ce:	6902                	ld	s2,0(sp)
    800032d0:	6105                	addi	sp,sp,32
    800032d2:	8082                	ret

00000000800032d4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800032d4:	1101                	addi	sp,sp,-32
    800032d6:	ec06                	sd	ra,24(sp)
    800032d8:	e822                	sd	s0,16(sp)
    800032da:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800032dc:	fec40593          	addi	a1,s0,-20
    800032e0:	4501                	li	a0,0
    800032e2:	00000097          	auipc	ra,0x0
    800032e6:	f12080e7          	jalr	-238(ra) # 800031f4 <argint>
    return -1;
    800032ea:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800032ec:	00054963          	bltz	a0,800032fe <sys_exit+0x2a>
  exit(n);
    800032f0:	fec42503          	lw	a0,-20(s0)
    800032f4:	fffff097          	auipc	ra,0xfffff
    800032f8:	61a080e7          	jalr	1562(ra) # 8000290e <exit>
  return 0;  // not reached
    800032fc:	4781                	li	a5,0
}
    800032fe:	853e                	mv	a0,a5
    80003300:	60e2                	ld	ra,24(sp)
    80003302:	6442                	ld	s0,16(sp)
    80003304:	6105                	addi	sp,sp,32
    80003306:	8082                	ret

0000000080003308 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003308:	1141                	addi	sp,sp,-16
    8000330a:	e406                	sd	ra,8(sp)
    8000330c:	e022                	sd	s0,0(sp)
    8000330e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003310:	fffff097          	auipc	ra,0xfffff
    80003314:	b30080e7          	jalr	-1232(ra) # 80001e40 <myproc>
}
    80003318:	5908                	lw	a0,48(a0)
    8000331a:	60a2                	ld	ra,8(sp)
    8000331c:	6402                	ld	s0,0(sp)
    8000331e:	0141                	addi	sp,sp,16
    80003320:	8082                	ret

0000000080003322 <sys_fork>:

uint64
sys_fork(void)
{
    80003322:	1141                	addi	sp,sp,-16
    80003324:	e406                	sd	ra,8(sp)
    80003326:	e022                	sd	s0,0(sp)
    80003328:	0800                	addi	s0,sp,16
  return fork();
    8000332a:	fffff097          	auipc	ra,0xfffff
    8000332e:	f76080e7          	jalr	-138(ra) # 800022a0 <fork>
}
    80003332:	60a2                	ld	ra,8(sp)
    80003334:	6402                	ld	s0,0(sp)
    80003336:	0141                	addi	sp,sp,16
    80003338:	8082                	ret

000000008000333a <sys_wait>:

uint64
sys_wait(void)
{
    8000333a:	1101                	addi	sp,sp,-32
    8000333c:	ec06                	sd	ra,24(sp)
    8000333e:	e822                	sd	s0,16(sp)
    80003340:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003342:	fe840593          	addi	a1,s0,-24
    80003346:	4501                	li	a0,0
    80003348:	00000097          	auipc	ra,0x0
    8000334c:	ece080e7          	jalr	-306(ra) # 80003216 <argaddr>
    80003350:	87aa                	mv	a5,a0
    return -1;
    80003352:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003354:	0007c863          	bltz	a5,80003364 <sys_wait+0x2a>
  return wait(p);
    80003358:	fe843503          	ld	a0,-24(s0)
    8000335c:	fffff097          	auipc	ra,0xfffff
    80003360:	3ba080e7          	jalr	954(ra) # 80002716 <wait>
}
    80003364:	60e2                	ld	ra,24(sp)
    80003366:	6442                	ld	s0,16(sp)
    80003368:	6105                	addi	sp,sp,32
    8000336a:	8082                	ret

000000008000336c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000336c:	7179                	addi	sp,sp,-48
    8000336e:	f406                	sd	ra,40(sp)
    80003370:	f022                	sd	s0,32(sp)
    80003372:	ec26                	sd	s1,24(sp)
    80003374:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003376:	fdc40593          	addi	a1,s0,-36
    8000337a:	4501                	li	a0,0
    8000337c:	00000097          	auipc	ra,0x0
    80003380:	e78080e7          	jalr	-392(ra) # 800031f4 <argint>
    return -1;
    80003384:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003386:	00054f63          	bltz	a0,800033a4 <sys_sbrk+0x38>
  addr = myproc()->sz;
    8000338a:	fffff097          	auipc	ra,0xfffff
    8000338e:	ab6080e7          	jalr	-1354(ra) # 80001e40 <myproc>
    80003392:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80003394:	fdc42503          	lw	a0,-36(s0)
    80003398:	fffff097          	auipc	ra,0xfffff
    8000339c:	e94080e7          	jalr	-364(ra) # 8000222c <growproc>
    800033a0:	00054863          	bltz	a0,800033b0 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800033a4:	8526                	mv	a0,s1
    800033a6:	70a2                	ld	ra,40(sp)
    800033a8:	7402                	ld	s0,32(sp)
    800033aa:	64e2                	ld	s1,24(sp)
    800033ac:	6145                	addi	sp,sp,48
    800033ae:	8082                	ret
    return -1;
    800033b0:	54fd                	li	s1,-1
    800033b2:	bfcd                	j	800033a4 <sys_sbrk+0x38>

00000000800033b4 <sys_sleep>:

uint64
sys_sleep(void)
{
    800033b4:	7139                	addi	sp,sp,-64
    800033b6:	fc06                	sd	ra,56(sp)
    800033b8:	f822                	sd	s0,48(sp)
    800033ba:	f426                	sd	s1,40(sp)
    800033bc:	f04a                	sd	s2,32(sp)
    800033be:	ec4e                	sd	s3,24(sp)
    800033c0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800033c2:	fcc40593          	addi	a1,s0,-52
    800033c6:	4501                	li	a0,0
    800033c8:	00000097          	auipc	ra,0x0
    800033cc:	e2c080e7          	jalr	-468(ra) # 800031f4 <argint>
    return -1;
    800033d0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800033d2:	06054563          	bltz	a0,8000343c <sys_sleep+0x88>
  acquire(&tickslock);
    800033d6:	0001c517          	auipc	a0,0x1c
    800033da:	2fa50513          	addi	a0,a0,762 # 8001f6d0 <tickslock>
    800033de:	ffffe097          	auipc	ra,0xffffe
    800033e2:	804080e7          	jalr	-2044(ra) # 80000be2 <acquire>
  ticks0 = ticks;
    800033e6:	00006917          	auipc	s2,0x6
    800033ea:	c4a92903          	lw	s2,-950(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    800033ee:	fcc42783          	lw	a5,-52(s0)
    800033f2:	cf85                	beqz	a5,8000342a <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800033f4:	0001c997          	auipc	s3,0x1c
    800033f8:	2dc98993          	addi	s3,s3,732 # 8001f6d0 <tickslock>
    800033fc:	00006497          	auipc	s1,0x6
    80003400:	c3448493          	addi	s1,s1,-972 # 80009030 <ticks>
    if(myproc()->killed){
    80003404:	fffff097          	auipc	ra,0xfffff
    80003408:	a3c080e7          	jalr	-1476(ra) # 80001e40 <myproc>
    8000340c:	551c                	lw	a5,40(a0)
    8000340e:	ef9d                	bnez	a5,8000344c <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003410:	85ce                	mv	a1,s3
    80003412:	8526                	mv	a0,s1
    80003414:	fffff097          	auipc	ra,0xfffff
    80003418:	29e080e7          	jalr	670(ra) # 800026b2 <sleep>
  while(ticks - ticks0 < n){
    8000341c:	409c                	lw	a5,0(s1)
    8000341e:	412787bb          	subw	a5,a5,s2
    80003422:	fcc42703          	lw	a4,-52(s0)
    80003426:	fce7efe3          	bltu	a5,a4,80003404 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000342a:	0001c517          	auipc	a0,0x1c
    8000342e:	2a650513          	addi	a0,a0,678 # 8001f6d0 <tickslock>
    80003432:	ffffe097          	auipc	ra,0xffffe
    80003436:	864080e7          	jalr	-1948(ra) # 80000c96 <release>
  return 0;
    8000343a:	4781                	li	a5,0
}
    8000343c:	853e                	mv	a0,a5
    8000343e:	70e2                	ld	ra,56(sp)
    80003440:	7442                	ld	s0,48(sp)
    80003442:	74a2                	ld	s1,40(sp)
    80003444:	7902                	ld	s2,32(sp)
    80003446:	69e2                	ld	s3,24(sp)
    80003448:	6121                	addi	sp,sp,64
    8000344a:	8082                	ret
      release(&tickslock);
    8000344c:	0001c517          	auipc	a0,0x1c
    80003450:	28450513          	addi	a0,a0,644 # 8001f6d0 <tickslock>
    80003454:	ffffe097          	auipc	ra,0xffffe
    80003458:	842080e7          	jalr	-1982(ra) # 80000c96 <release>
      return -1;
    8000345c:	57fd                	li	a5,-1
    8000345e:	bff9                	j	8000343c <sys_sleep+0x88>

0000000080003460 <sys_kill>:

uint64
sys_kill(void)
{
    80003460:	1101                	addi	sp,sp,-32
    80003462:	ec06                	sd	ra,24(sp)
    80003464:	e822                	sd	s0,16(sp)
    80003466:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003468:	fec40593          	addi	a1,s0,-20
    8000346c:	4501                	li	a0,0
    8000346e:	00000097          	auipc	ra,0x0
    80003472:	d86080e7          	jalr	-634(ra) # 800031f4 <argint>
    80003476:	87aa                	mv	a5,a0
    return -1;
    80003478:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000347a:	0007c863          	bltz	a5,8000348a <sys_kill+0x2a>
  return kill(pid);
    8000347e:	fec42503          	lw	a0,-20(s0)
    80003482:	fffff097          	auipc	ra,0xfffff
    80003486:	57c080e7          	jalr	1404(ra) # 800029fe <kill>
}
    8000348a:	60e2                	ld	ra,24(sp)
    8000348c:	6442                	ld	s0,16(sp)
    8000348e:	6105                	addi	sp,sp,32
    80003490:	8082                	ret

0000000080003492 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003492:	1101                	addi	sp,sp,-32
    80003494:	ec06                	sd	ra,24(sp)
    80003496:	e822                	sd	s0,16(sp)
    80003498:	e426                	sd	s1,8(sp)
    8000349a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000349c:	0001c517          	auipc	a0,0x1c
    800034a0:	23450513          	addi	a0,a0,564 # 8001f6d0 <tickslock>
    800034a4:	ffffd097          	auipc	ra,0xffffd
    800034a8:	73e080e7          	jalr	1854(ra) # 80000be2 <acquire>
  xticks = ticks;
    800034ac:	00006497          	auipc	s1,0x6
    800034b0:	b844a483          	lw	s1,-1148(s1) # 80009030 <ticks>
  release(&tickslock);
    800034b4:	0001c517          	auipc	a0,0x1c
    800034b8:	21c50513          	addi	a0,a0,540 # 8001f6d0 <tickslock>
    800034bc:	ffffd097          	auipc	ra,0xffffd
    800034c0:	7da080e7          	jalr	2010(ra) # 80000c96 <release>
  return xticks;
}
    800034c4:	02049513          	slli	a0,s1,0x20
    800034c8:	9101                	srli	a0,a0,0x20
    800034ca:	60e2                	ld	ra,24(sp)
    800034cc:	6442                	ld	s0,16(sp)
    800034ce:	64a2                	ld	s1,8(sp)
    800034d0:	6105                	addi	sp,sp,32
    800034d2:	8082                	ret

00000000800034d4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800034d4:	7179                	addi	sp,sp,-48
    800034d6:	f406                	sd	ra,40(sp)
    800034d8:	f022                	sd	s0,32(sp)
    800034da:	ec26                	sd	s1,24(sp)
    800034dc:	e84a                	sd	s2,16(sp)
    800034de:	e44e                	sd	s3,8(sp)
    800034e0:	e052                	sd	s4,0(sp)
    800034e2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800034e4:	00005597          	auipc	a1,0x5
    800034e8:	0e458593          	addi	a1,a1,228 # 800085c8 <syscalls+0xb0>
    800034ec:	0001c517          	auipc	a0,0x1c
    800034f0:	1fc50513          	addi	a0,a0,508 # 8001f6e8 <bcache>
    800034f4:	ffffd097          	auipc	ra,0xffffd
    800034f8:	65e080e7          	jalr	1630(ra) # 80000b52 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800034fc:	00024797          	auipc	a5,0x24
    80003500:	1ec78793          	addi	a5,a5,492 # 800276e8 <bcache+0x8000>
    80003504:	00024717          	auipc	a4,0x24
    80003508:	44c70713          	addi	a4,a4,1100 # 80027950 <bcache+0x8268>
    8000350c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003510:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003514:	0001c497          	auipc	s1,0x1c
    80003518:	1ec48493          	addi	s1,s1,492 # 8001f700 <bcache+0x18>
    b->next = bcache.head.next;
    8000351c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000351e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003520:	00005a17          	auipc	s4,0x5
    80003524:	0b0a0a13          	addi	s4,s4,176 # 800085d0 <syscalls+0xb8>
    b->next = bcache.head.next;
    80003528:	2b893783          	ld	a5,696(s2)
    8000352c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000352e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003532:	85d2                	mv	a1,s4
    80003534:	01048513          	addi	a0,s1,16
    80003538:	00001097          	auipc	ra,0x1
    8000353c:	7d4080e7          	jalr	2004(ra) # 80004d0c <initsleeplock>
    bcache.head.next->prev = b;
    80003540:	2b893783          	ld	a5,696(s2)
    80003544:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003546:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000354a:	45848493          	addi	s1,s1,1112
    8000354e:	fd349de3          	bne	s1,s3,80003528 <binit+0x54>
  }
}
    80003552:	70a2                	ld	ra,40(sp)
    80003554:	7402                	ld	s0,32(sp)
    80003556:	64e2                	ld	s1,24(sp)
    80003558:	6942                	ld	s2,16(sp)
    8000355a:	69a2                	ld	s3,8(sp)
    8000355c:	6a02                	ld	s4,0(sp)
    8000355e:	6145                	addi	sp,sp,48
    80003560:	8082                	ret

0000000080003562 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003562:	7179                	addi	sp,sp,-48
    80003564:	f406                	sd	ra,40(sp)
    80003566:	f022                	sd	s0,32(sp)
    80003568:	ec26                	sd	s1,24(sp)
    8000356a:	e84a                	sd	s2,16(sp)
    8000356c:	e44e                	sd	s3,8(sp)
    8000356e:	1800                	addi	s0,sp,48
    80003570:	892a                	mv	s2,a0
    80003572:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003574:	0001c517          	auipc	a0,0x1c
    80003578:	17450513          	addi	a0,a0,372 # 8001f6e8 <bcache>
    8000357c:	ffffd097          	auipc	ra,0xffffd
    80003580:	666080e7          	jalr	1638(ra) # 80000be2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003584:	00024497          	auipc	s1,0x24
    80003588:	41c4b483          	ld	s1,1052(s1) # 800279a0 <bcache+0x82b8>
    8000358c:	00024797          	auipc	a5,0x24
    80003590:	3c478793          	addi	a5,a5,964 # 80027950 <bcache+0x8268>
    80003594:	02f48f63          	beq	s1,a5,800035d2 <bread+0x70>
    80003598:	873e                	mv	a4,a5
    8000359a:	a021                	j	800035a2 <bread+0x40>
    8000359c:	68a4                	ld	s1,80(s1)
    8000359e:	02e48a63          	beq	s1,a4,800035d2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800035a2:	449c                	lw	a5,8(s1)
    800035a4:	ff279ce3          	bne	a5,s2,8000359c <bread+0x3a>
    800035a8:	44dc                	lw	a5,12(s1)
    800035aa:	ff3799e3          	bne	a5,s3,8000359c <bread+0x3a>
      b->refcnt++;
    800035ae:	40bc                	lw	a5,64(s1)
    800035b0:	2785                	addiw	a5,a5,1
    800035b2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035b4:	0001c517          	auipc	a0,0x1c
    800035b8:	13450513          	addi	a0,a0,308 # 8001f6e8 <bcache>
    800035bc:	ffffd097          	auipc	ra,0xffffd
    800035c0:	6da080e7          	jalr	1754(ra) # 80000c96 <release>
      acquiresleep(&b->lock);
    800035c4:	01048513          	addi	a0,s1,16
    800035c8:	00001097          	auipc	ra,0x1
    800035cc:	77e080e7          	jalr	1918(ra) # 80004d46 <acquiresleep>
      return b;
    800035d0:	a8b9                	j	8000362e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800035d2:	00024497          	auipc	s1,0x24
    800035d6:	3c64b483          	ld	s1,966(s1) # 80027998 <bcache+0x82b0>
    800035da:	00024797          	auipc	a5,0x24
    800035de:	37678793          	addi	a5,a5,886 # 80027950 <bcache+0x8268>
    800035e2:	00f48863          	beq	s1,a5,800035f2 <bread+0x90>
    800035e6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800035e8:	40bc                	lw	a5,64(s1)
    800035ea:	cf81                	beqz	a5,80003602 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800035ec:	64a4                	ld	s1,72(s1)
    800035ee:	fee49de3          	bne	s1,a4,800035e8 <bread+0x86>
  panic("bget: no buffers");
    800035f2:	00005517          	auipc	a0,0x5
    800035f6:	fe650513          	addi	a0,a0,-26 # 800085d8 <syscalls+0xc0>
    800035fa:	ffffd097          	auipc	ra,0xffffd
    800035fe:	f30080e7          	jalr	-208(ra) # 8000052a <panic>
      b->dev = dev;
    80003602:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003606:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000360a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000360e:	4785                	li	a5,1
    80003610:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003612:	0001c517          	auipc	a0,0x1c
    80003616:	0d650513          	addi	a0,a0,214 # 8001f6e8 <bcache>
    8000361a:	ffffd097          	auipc	ra,0xffffd
    8000361e:	67c080e7          	jalr	1660(ra) # 80000c96 <release>
      acquiresleep(&b->lock);
    80003622:	01048513          	addi	a0,s1,16
    80003626:	00001097          	auipc	ra,0x1
    8000362a:	720080e7          	jalr	1824(ra) # 80004d46 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000362e:	409c                	lw	a5,0(s1)
    80003630:	cb89                	beqz	a5,80003642 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003632:	8526                	mv	a0,s1
    80003634:	70a2                	ld	ra,40(sp)
    80003636:	7402                	ld	s0,32(sp)
    80003638:	64e2                	ld	s1,24(sp)
    8000363a:	6942                	ld	s2,16(sp)
    8000363c:	69a2                	ld	s3,8(sp)
    8000363e:	6145                	addi	sp,sp,48
    80003640:	8082                	ret
    virtio_disk_rw(b, 0);
    80003642:	4581                	li	a1,0
    80003644:	8526                	mv	a0,s1
    80003646:	00003097          	auipc	ra,0x3
    8000364a:	470080e7          	jalr	1136(ra) # 80006ab6 <virtio_disk_rw>
    b->valid = 1;
    8000364e:	4785                	li	a5,1
    80003650:	c09c                	sw	a5,0(s1)
  return b;
    80003652:	b7c5                	j	80003632 <bread+0xd0>

0000000080003654 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003654:	1101                	addi	sp,sp,-32
    80003656:	ec06                	sd	ra,24(sp)
    80003658:	e822                	sd	s0,16(sp)
    8000365a:	e426                	sd	s1,8(sp)
    8000365c:	1000                	addi	s0,sp,32
    8000365e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003660:	0541                	addi	a0,a0,16
    80003662:	00001097          	auipc	ra,0x1
    80003666:	77e080e7          	jalr	1918(ra) # 80004de0 <holdingsleep>
    8000366a:	cd01                	beqz	a0,80003682 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000366c:	4585                	li	a1,1
    8000366e:	8526                	mv	a0,s1
    80003670:	00003097          	auipc	ra,0x3
    80003674:	446080e7          	jalr	1094(ra) # 80006ab6 <virtio_disk_rw>
}
    80003678:	60e2                	ld	ra,24(sp)
    8000367a:	6442                	ld	s0,16(sp)
    8000367c:	64a2                	ld	s1,8(sp)
    8000367e:	6105                	addi	sp,sp,32
    80003680:	8082                	ret
    panic("bwrite");
    80003682:	00005517          	auipc	a0,0x5
    80003686:	f6e50513          	addi	a0,a0,-146 # 800085f0 <syscalls+0xd8>
    8000368a:	ffffd097          	auipc	ra,0xffffd
    8000368e:	ea0080e7          	jalr	-352(ra) # 8000052a <panic>

0000000080003692 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003692:	1101                	addi	sp,sp,-32
    80003694:	ec06                	sd	ra,24(sp)
    80003696:	e822                	sd	s0,16(sp)
    80003698:	e426                	sd	s1,8(sp)
    8000369a:	e04a                	sd	s2,0(sp)
    8000369c:	1000                	addi	s0,sp,32
    8000369e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036a0:	01050913          	addi	s2,a0,16
    800036a4:	854a                	mv	a0,s2
    800036a6:	00001097          	auipc	ra,0x1
    800036aa:	73a080e7          	jalr	1850(ra) # 80004de0 <holdingsleep>
    800036ae:	c92d                	beqz	a0,80003720 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800036b0:	854a                	mv	a0,s2
    800036b2:	00001097          	auipc	ra,0x1
    800036b6:	6ea080e7          	jalr	1770(ra) # 80004d9c <releasesleep>

  acquire(&bcache.lock);
    800036ba:	0001c517          	auipc	a0,0x1c
    800036be:	02e50513          	addi	a0,a0,46 # 8001f6e8 <bcache>
    800036c2:	ffffd097          	auipc	ra,0xffffd
    800036c6:	520080e7          	jalr	1312(ra) # 80000be2 <acquire>
  b->refcnt--;
    800036ca:	40bc                	lw	a5,64(s1)
    800036cc:	37fd                	addiw	a5,a5,-1
    800036ce:	0007871b          	sext.w	a4,a5
    800036d2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800036d4:	eb05                	bnez	a4,80003704 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800036d6:	68bc                	ld	a5,80(s1)
    800036d8:	64b8                	ld	a4,72(s1)
    800036da:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800036dc:	64bc                	ld	a5,72(s1)
    800036de:	68b8                	ld	a4,80(s1)
    800036e0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800036e2:	00024797          	auipc	a5,0x24
    800036e6:	00678793          	addi	a5,a5,6 # 800276e8 <bcache+0x8000>
    800036ea:	2b87b703          	ld	a4,696(a5)
    800036ee:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800036f0:	00024717          	auipc	a4,0x24
    800036f4:	26070713          	addi	a4,a4,608 # 80027950 <bcache+0x8268>
    800036f8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800036fa:	2b87b703          	ld	a4,696(a5)
    800036fe:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003700:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003704:	0001c517          	auipc	a0,0x1c
    80003708:	fe450513          	addi	a0,a0,-28 # 8001f6e8 <bcache>
    8000370c:	ffffd097          	auipc	ra,0xffffd
    80003710:	58a080e7          	jalr	1418(ra) # 80000c96 <release>
}
    80003714:	60e2                	ld	ra,24(sp)
    80003716:	6442                	ld	s0,16(sp)
    80003718:	64a2                	ld	s1,8(sp)
    8000371a:	6902                	ld	s2,0(sp)
    8000371c:	6105                	addi	sp,sp,32
    8000371e:	8082                	ret
    panic("brelse");
    80003720:	00005517          	auipc	a0,0x5
    80003724:	ed850513          	addi	a0,a0,-296 # 800085f8 <syscalls+0xe0>
    80003728:	ffffd097          	auipc	ra,0xffffd
    8000372c:	e02080e7          	jalr	-510(ra) # 8000052a <panic>

0000000080003730 <bpin>:

void
bpin(struct buf *b) {
    80003730:	1101                	addi	sp,sp,-32
    80003732:	ec06                	sd	ra,24(sp)
    80003734:	e822                	sd	s0,16(sp)
    80003736:	e426                	sd	s1,8(sp)
    80003738:	1000                	addi	s0,sp,32
    8000373a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000373c:	0001c517          	auipc	a0,0x1c
    80003740:	fac50513          	addi	a0,a0,-84 # 8001f6e8 <bcache>
    80003744:	ffffd097          	auipc	ra,0xffffd
    80003748:	49e080e7          	jalr	1182(ra) # 80000be2 <acquire>
  b->refcnt++;
    8000374c:	40bc                	lw	a5,64(s1)
    8000374e:	2785                	addiw	a5,a5,1
    80003750:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003752:	0001c517          	auipc	a0,0x1c
    80003756:	f9650513          	addi	a0,a0,-106 # 8001f6e8 <bcache>
    8000375a:	ffffd097          	auipc	ra,0xffffd
    8000375e:	53c080e7          	jalr	1340(ra) # 80000c96 <release>
}
    80003762:	60e2                	ld	ra,24(sp)
    80003764:	6442                	ld	s0,16(sp)
    80003766:	64a2                	ld	s1,8(sp)
    80003768:	6105                	addi	sp,sp,32
    8000376a:	8082                	ret

000000008000376c <bunpin>:

void
bunpin(struct buf *b) {
    8000376c:	1101                	addi	sp,sp,-32
    8000376e:	ec06                	sd	ra,24(sp)
    80003770:	e822                	sd	s0,16(sp)
    80003772:	e426                	sd	s1,8(sp)
    80003774:	1000                	addi	s0,sp,32
    80003776:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003778:	0001c517          	auipc	a0,0x1c
    8000377c:	f7050513          	addi	a0,a0,-144 # 8001f6e8 <bcache>
    80003780:	ffffd097          	auipc	ra,0xffffd
    80003784:	462080e7          	jalr	1122(ra) # 80000be2 <acquire>
  b->refcnt--;
    80003788:	40bc                	lw	a5,64(s1)
    8000378a:	37fd                	addiw	a5,a5,-1
    8000378c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000378e:	0001c517          	auipc	a0,0x1c
    80003792:	f5a50513          	addi	a0,a0,-166 # 8001f6e8 <bcache>
    80003796:	ffffd097          	auipc	ra,0xffffd
    8000379a:	500080e7          	jalr	1280(ra) # 80000c96 <release>
}
    8000379e:	60e2                	ld	ra,24(sp)
    800037a0:	6442                	ld	s0,16(sp)
    800037a2:	64a2                	ld	s1,8(sp)
    800037a4:	6105                	addi	sp,sp,32
    800037a6:	8082                	ret

00000000800037a8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800037a8:	1101                	addi	sp,sp,-32
    800037aa:	ec06                	sd	ra,24(sp)
    800037ac:	e822                	sd	s0,16(sp)
    800037ae:	e426                	sd	s1,8(sp)
    800037b0:	e04a                	sd	s2,0(sp)
    800037b2:	1000                	addi	s0,sp,32
    800037b4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800037b6:	00d5d59b          	srliw	a1,a1,0xd
    800037ba:	00024797          	auipc	a5,0x24
    800037be:	60a7a783          	lw	a5,1546(a5) # 80027dc4 <sb+0x1c>
    800037c2:	9dbd                	addw	a1,a1,a5
    800037c4:	00000097          	auipc	ra,0x0
    800037c8:	d9e080e7          	jalr	-610(ra) # 80003562 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800037cc:	0074f713          	andi	a4,s1,7
    800037d0:	4785                	li	a5,1
    800037d2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800037d6:	14ce                	slli	s1,s1,0x33
    800037d8:	90d9                	srli	s1,s1,0x36
    800037da:	00950733          	add	a4,a0,s1
    800037de:	05874703          	lbu	a4,88(a4)
    800037e2:	00e7f6b3          	and	a3,a5,a4
    800037e6:	c69d                	beqz	a3,80003814 <bfree+0x6c>
    800037e8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800037ea:	94aa                	add	s1,s1,a0
    800037ec:	fff7c793          	not	a5,a5
    800037f0:	8ff9                	and	a5,a5,a4
    800037f2:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800037f6:	00001097          	auipc	ra,0x1
    800037fa:	430080e7          	jalr	1072(ra) # 80004c26 <log_write>
  brelse(bp);
    800037fe:	854a                	mv	a0,s2
    80003800:	00000097          	auipc	ra,0x0
    80003804:	e92080e7          	jalr	-366(ra) # 80003692 <brelse>
}
    80003808:	60e2                	ld	ra,24(sp)
    8000380a:	6442                	ld	s0,16(sp)
    8000380c:	64a2                	ld	s1,8(sp)
    8000380e:	6902                	ld	s2,0(sp)
    80003810:	6105                	addi	sp,sp,32
    80003812:	8082                	ret
    panic("freeing free block");
    80003814:	00005517          	auipc	a0,0x5
    80003818:	dec50513          	addi	a0,a0,-532 # 80008600 <syscalls+0xe8>
    8000381c:	ffffd097          	auipc	ra,0xffffd
    80003820:	d0e080e7          	jalr	-754(ra) # 8000052a <panic>

0000000080003824 <balloc>:
{
    80003824:	711d                	addi	sp,sp,-96
    80003826:	ec86                	sd	ra,88(sp)
    80003828:	e8a2                	sd	s0,80(sp)
    8000382a:	e4a6                	sd	s1,72(sp)
    8000382c:	e0ca                	sd	s2,64(sp)
    8000382e:	fc4e                	sd	s3,56(sp)
    80003830:	f852                	sd	s4,48(sp)
    80003832:	f456                	sd	s5,40(sp)
    80003834:	f05a                	sd	s6,32(sp)
    80003836:	ec5e                	sd	s7,24(sp)
    80003838:	e862                	sd	s8,16(sp)
    8000383a:	e466                	sd	s9,8(sp)
    8000383c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000383e:	00024797          	auipc	a5,0x24
    80003842:	56e7a783          	lw	a5,1390(a5) # 80027dac <sb+0x4>
    80003846:	cbd1                	beqz	a5,800038da <balloc+0xb6>
    80003848:	8baa                	mv	s7,a0
    8000384a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000384c:	00024b17          	auipc	s6,0x24
    80003850:	55cb0b13          	addi	s6,s6,1372 # 80027da8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003854:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003856:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003858:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000385a:	6c89                	lui	s9,0x2
    8000385c:	a831                	j	80003878 <balloc+0x54>
    brelse(bp);
    8000385e:	854a                	mv	a0,s2
    80003860:	00000097          	auipc	ra,0x0
    80003864:	e32080e7          	jalr	-462(ra) # 80003692 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003868:	015c87bb          	addw	a5,s9,s5
    8000386c:	00078a9b          	sext.w	s5,a5
    80003870:	004b2703          	lw	a4,4(s6)
    80003874:	06eaf363          	bgeu	s5,a4,800038da <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003878:	41fad79b          	sraiw	a5,s5,0x1f
    8000387c:	0137d79b          	srliw	a5,a5,0x13
    80003880:	015787bb          	addw	a5,a5,s5
    80003884:	40d7d79b          	sraiw	a5,a5,0xd
    80003888:	01cb2583          	lw	a1,28(s6)
    8000388c:	9dbd                	addw	a1,a1,a5
    8000388e:	855e                	mv	a0,s7
    80003890:	00000097          	auipc	ra,0x0
    80003894:	cd2080e7          	jalr	-814(ra) # 80003562 <bread>
    80003898:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000389a:	004b2503          	lw	a0,4(s6)
    8000389e:	000a849b          	sext.w	s1,s5
    800038a2:	8662                	mv	a2,s8
    800038a4:	faa4fde3          	bgeu	s1,a0,8000385e <balloc+0x3a>
      m = 1 << (bi % 8);
    800038a8:	41f6579b          	sraiw	a5,a2,0x1f
    800038ac:	01d7d69b          	srliw	a3,a5,0x1d
    800038b0:	00c6873b          	addw	a4,a3,a2
    800038b4:	00777793          	andi	a5,a4,7
    800038b8:	9f95                	subw	a5,a5,a3
    800038ba:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800038be:	4037571b          	sraiw	a4,a4,0x3
    800038c2:	00e906b3          	add	a3,s2,a4
    800038c6:	0586c683          	lbu	a3,88(a3)
    800038ca:	00d7f5b3          	and	a1,a5,a3
    800038ce:	cd91                	beqz	a1,800038ea <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038d0:	2605                	addiw	a2,a2,1
    800038d2:	2485                	addiw	s1,s1,1
    800038d4:	fd4618e3          	bne	a2,s4,800038a4 <balloc+0x80>
    800038d8:	b759                	j	8000385e <balloc+0x3a>
  panic("balloc: out of blocks");
    800038da:	00005517          	auipc	a0,0x5
    800038de:	d3e50513          	addi	a0,a0,-706 # 80008618 <syscalls+0x100>
    800038e2:	ffffd097          	auipc	ra,0xffffd
    800038e6:	c48080e7          	jalr	-952(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800038ea:	974a                	add	a4,a4,s2
    800038ec:	8fd5                	or	a5,a5,a3
    800038ee:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800038f2:	854a                	mv	a0,s2
    800038f4:	00001097          	auipc	ra,0x1
    800038f8:	332080e7          	jalr	818(ra) # 80004c26 <log_write>
        brelse(bp);
    800038fc:	854a                	mv	a0,s2
    800038fe:	00000097          	auipc	ra,0x0
    80003902:	d94080e7          	jalr	-620(ra) # 80003692 <brelse>
  bp = bread(dev, bno);
    80003906:	85a6                	mv	a1,s1
    80003908:	855e                	mv	a0,s7
    8000390a:	00000097          	auipc	ra,0x0
    8000390e:	c58080e7          	jalr	-936(ra) # 80003562 <bread>
    80003912:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003914:	40000613          	li	a2,1024
    80003918:	4581                	li	a1,0
    8000391a:	05850513          	addi	a0,a0,88
    8000391e:	ffffd097          	auipc	ra,0xffffd
    80003922:	3c0080e7          	jalr	960(ra) # 80000cde <memset>
  log_write(bp);
    80003926:	854a                	mv	a0,s2
    80003928:	00001097          	auipc	ra,0x1
    8000392c:	2fe080e7          	jalr	766(ra) # 80004c26 <log_write>
  brelse(bp);
    80003930:	854a                	mv	a0,s2
    80003932:	00000097          	auipc	ra,0x0
    80003936:	d60080e7          	jalr	-672(ra) # 80003692 <brelse>
}
    8000393a:	8526                	mv	a0,s1
    8000393c:	60e6                	ld	ra,88(sp)
    8000393e:	6446                	ld	s0,80(sp)
    80003940:	64a6                	ld	s1,72(sp)
    80003942:	6906                	ld	s2,64(sp)
    80003944:	79e2                	ld	s3,56(sp)
    80003946:	7a42                	ld	s4,48(sp)
    80003948:	7aa2                	ld	s5,40(sp)
    8000394a:	7b02                	ld	s6,32(sp)
    8000394c:	6be2                	ld	s7,24(sp)
    8000394e:	6c42                	ld	s8,16(sp)
    80003950:	6ca2                	ld	s9,8(sp)
    80003952:	6125                	addi	sp,sp,96
    80003954:	8082                	ret

0000000080003956 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003956:	7179                	addi	sp,sp,-48
    80003958:	f406                	sd	ra,40(sp)
    8000395a:	f022                	sd	s0,32(sp)
    8000395c:	ec26                	sd	s1,24(sp)
    8000395e:	e84a                	sd	s2,16(sp)
    80003960:	e44e                	sd	s3,8(sp)
    80003962:	e052                	sd	s4,0(sp)
    80003964:	1800                	addi	s0,sp,48
    80003966:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003968:	47ad                	li	a5,11
    8000396a:	04b7fe63          	bgeu	a5,a1,800039c6 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000396e:	ff45849b          	addiw	s1,a1,-12
    80003972:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003976:	0ff00793          	li	a5,255
    8000397a:	0ae7e463          	bltu	a5,a4,80003a22 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000397e:	08052583          	lw	a1,128(a0)
    80003982:	c5b5                	beqz	a1,800039ee <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003984:	00092503          	lw	a0,0(s2)
    80003988:	00000097          	auipc	ra,0x0
    8000398c:	bda080e7          	jalr	-1062(ra) # 80003562 <bread>
    80003990:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003992:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003996:	02049713          	slli	a4,s1,0x20
    8000399a:	01e75593          	srli	a1,a4,0x1e
    8000399e:	00b784b3          	add	s1,a5,a1
    800039a2:	0004a983          	lw	s3,0(s1)
    800039a6:	04098e63          	beqz	s3,80003a02 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800039aa:	8552                	mv	a0,s4
    800039ac:	00000097          	auipc	ra,0x0
    800039b0:	ce6080e7          	jalr	-794(ra) # 80003692 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800039b4:	854e                	mv	a0,s3
    800039b6:	70a2                	ld	ra,40(sp)
    800039b8:	7402                	ld	s0,32(sp)
    800039ba:	64e2                	ld	s1,24(sp)
    800039bc:	6942                	ld	s2,16(sp)
    800039be:	69a2                	ld	s3,8(sp)
    800039c0:	6a02                	ld	s4,0(sp)
    800039c2:	6145                	addi	sp,sp,48
    800039c4:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800039c6:	02059793          	slli	a5,a1,0x20
    800039ca:	01e7d593          	srli	a1,a5,0x1e
    800039ce:	00b504b3          	add	s1,a0,a1
    800039d2:	0504a983          	lw	s3,80(s1)
    800039d6:	fc099fe3          	bnez	s3,800039b4 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800039da:	4108                	lw	a0,0(a0)
    800039dc:	00000097          	auipc	ra,0x0
    800039e0:	e48080e7          	jalr	-440(ra) # 80003824 <balloc>
    800039e4:	0005099b          	sext.w	s3,a0
    800039e8:	0534a823          	sw	s3,80(s1)
    800039ec:	b7e1                	j	800039b4 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800039ee:	4108                	lw	a0,0(a0)
    800039f0:	00000097          	auipc	ra,0x0
    800039f4:	e34080e7          	jalr	-460(ra) # 80003824 <balloc>
    800039f8:	0005059b          	sext.w	a1,a0
    800039fc:	08b92023          	sw	a1,128(s2)
    80003a00:	b751                	j	80003984 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003a02:	00092503          	lw	a0,0(s2)
    80003a06:	00000097          	auipc	ra,0x0
    80003a0a:	e1e080e7          	jalr	-482(ra) # 80003824 <balloc>
    80003a0e:	0005099b          	sext.w	s3,a0
    80003a12:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003a16:	8552                	mv	a0,s4
    80003a18:	00001097          	auipc	ra,0x1
    80003a1c:	20e080e7          	jalr	526(ra) # 80004c26 <log_write>
    80003a20:	b769                	j	800039aa <bmap+0x54>
  panic("bmap: out of range");
    80003a22:	00005517          	auipc	a0,0x5
    80003a26:	c0e50513          	addi	a0,a0,-1010 # 80008630 <syscalls+0x118>
    80003a2a:	ffffd097          	auipc	ra,0xffffd
    80003a2e:	b00080e7          	jalr	-1280(ra) # 8000052a <panic>

0000000080003a32 <iget>:
{
    80003a32:	7179                	addi	sp,sp,-48
    80003a34:	f406                	sd	ra,40(sp)
    80003a36:	f022                	sd	s0,32(sp)
    80003a38:	ec26                	sd	s1,24(sp)
    80003a3a:	e84a                	sd	s2,16(sp)
    80003a3c:	e44e                	sd	s3,8(sp)
    80003a3e:	e052                	sd	s4,0(sp)
    80003a40:	1800                	addi	s0,sp,48
    80003a42:	89aa                	mv	s3,a0
    80003a44:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003a46:	00024517          	auipc	a0,0x24
    80003a4a:	38250513          	addi	a0,a0,898 # 80027dc8 <itable>
    80003a4e:	ffffd097          	auipc	ra,0xffffd
    80003a52:	194080e7          	jalr	404(ra) # 80000be2 <acquire>
  empty = 0;
    80003a56:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a58:	00024497          	auipc	s1,0x24
    80003a5c:	38848493          	addi	s1,s1,904 # 80027de0 <itable+0x18>
    80003a60:	00026697          	auipc	a3,0x26
    80003a64:	e1068693          	addi	a3,a3,-496 # 80029870 <log>
    80003a68:	a039                	j	80003a76 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a6a:	02090b63          	beqz	s2,80003aa0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a6e:	08848493          	addi	s1,s1,136
    80003a72:	02d48a63          	beq	s1,a3,80003aa6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003a76:	449c                	lw	a5,8(s1)
    80003a78:	fef059e3          	blez	a5,80003a6a <iget+0x38>
    80003a7c:	4098                	lw	a4,0(s1)
    80003a7e:	ff3716e3          	bne	a4,s3,80003a6a <iget+0x38>
    80003a82:	40d8                	lw	a4,4(s1)
    80003a84:	ff4713e3          	bne	a4,s4,80003a6a <iget+0x38>
      ip->ref++;
    80003a88:	2785                	addiw	a5,a5,1
    80003a8a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a8c:	00024517          	auipc	a0,0x24
    80003a90:	33c50513          	addi	a0,a0,828 # 80027dc8 <itable>
    80003a94:	ffffd097          	auipc	ra,0xffffd
    80003a98:	202080e7          	jalr	514(ra) # 80000c96 <release>
      return ip;
    80003a9c:	8926                	mv	s2,s1
    80003a9e:	a03d                	j	80003acc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003aa0:	f7f9                	bnez	a5,80003a6e <iget+0x3c>
    80003aa2:	8926                	mv	s2,s1
    80003aa4:	b7e9                	j	80003a6e <iget+0x3c>
  if(empty == 0)
    80003aa6:	02090c63          	beqz	s2,80003ade <iget+0xac>
  ip->dev = dev;
    80003aaa:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003aae:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003ab2:	4785                	li	a5,1
    80003ab4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003ab8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003abc:	00024517          	auipc	a0,0x24
    80003ac0:	30c50513          	addi	a0,a0,780 # 80027dc8 <itable>
    80003ac4:	ffffd097          	auipc	ra,0xffffd
    80003ac8:	1d2080e7          	jalr	466(ra) # 80000c96 <release>
}
    80003acc:	854a                	mv	a0,s2
    80003ace:	70a2                	ld	ra,40(sp)
    80003ad0:	7402                	ld	s0,32(sp)
    80003ad2:	64e2                	ld	s1,24(sp)
    80003ad4:	6942                	ld	s2,16(sp)
    80003ad6:	69a2                	ld	s3,8(sp)
    80003ad8:	6a02                	ld	s4,0(sp)
    80003ada:	6145                	addi	sp,sp,48
    80003adc:	8082                	ret
    panic("iget: no inodes");
    80003ade:	00005517          	auipc	a0,0x5
    80003ae2:	b6a50513          	addi	a0,a0,-1174 # 80008648 <syscalls+0x130>
    80003ae6:	ffffd097          	auipc	ra,0xffffd
    80003aea:	a44080e7          	jalr	-1468(ra) # 8000052a <panic>

0000000080003aee <fsinit>:
fsinit(int dev) {
    80003aee:	7179                	addi	sp,sp,-48
    80003af0:	f406                	sd	ra,40(sp)
    80003af2:	f022                	sd	s0,32(sp)
    80003af4:	ec26                	sd	s1,24(sp)
    80003af6:	e84a                	sd	s2,16(sp)
    80003af8:	e44e                	sd	s3,8(sp)
    80003afa:	1800                	addi	s0,sp,48
    80003afc:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003afe:	4585                	li	a1,1
    80003b00:	00000097          	auipc	ra,0x0
    80003b04:	a62080e7          	jalr	-1438(ra) # 80003562 <bread>
    80003b08:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b0a:	00024997          	auipc	s3,0x24
    80003b0e:	29e98993          	addi	s3,s3,670 # 80027da8 <sb>
    80003b12:	02000613          	li	a2,32
    80003b16:	05850593          	addi	a1,a0,88
    80003b1a:	854e                	mv	a0,s3
    80003b1c:	ffffd097          	auipc	ra,0xffffd
    80003b20:	21e080e7          	jalr	542(ra) # 80000d3a <memmove>
  brelse(bp);
    80003b24:	8526                	mv	a0,s1
    80003b26:	00000097          	auipc	ra,0x0
    80003b2a:	b6c080e7          	jalr	-1172(ra) # 80003692 <brelse>
  if(sb.magic != FSMAGIC)
    80003b2e:	0009a703          	lw	a4,0(s3)
    80003b32:	102037b7          	lui	a5,0x10203
    80003b36:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b3a:	02f71263          	bne	a4,a5,80003b5e <fsinit+0x70>
  initlog(dev, &sb);
    80003b3e:	00024597          	auipc	a1,0x24
    80003b42:	26a58593          	addi	a1,a1,618 # 80027da8 <sb>
    80003b46:	854a                	mv	a0,s2
    80003b48:	00001097          	auipc	ra,0x1
    80003b4c:	e60080e7          	jalr	-416(ra) # 800049a8 <initlog>
}
    80003b50:	70a2                	ld	ra,40(sp)
    80003b52:	7402                	ld	s0,32(sp)
    80003b54:	64e2                	ld	s1,24(sp)
    80003b56:	6942                	ld	s2,16(sp)
    80003b58:	69a2                	ld	s3,8(sp)
    80003b5a:	6145                	addi	sp,sp,48
    80003b5c:	8082                	ret
    panic("invalid file system");
    80003b5e:	00005517          	auipc	a0,0x5
    80003b62:	afa50513          	addi	a0,a0,-1286 # 80008658 <syscalls+0x140>
    80003b66:	ffffd097          	auipc	ra,0xffffd
    80003b6a:	9c4080e7          	jalr	-1596(ra) # 8000052a <panic>

0000000080003b6e <iinit>:
{
    80003b6e:	7179                	addi	sp,sp,-48
    80003b70:	f406                	sd	ra,40(sp)
    80003b72:	f022                	sd	s0,32(sp)
    80003b74:	ec26                	sd	s1,24(sp)
    80003b76:	e84a                	sd	s2,16(sp)
    80003b78:	e44e                	sd	s3,8(sp)
    80003b7a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003b7c:	00005597          	auipc	a1,0x5
    80003b80:	af458593          	addi	a1,a1,-1292 # 80008670 <syscalls+0x158>
    80003b84:	00024517          	auipc	a0,0x24
    80003b88:	24450513          	addi	a0,a0,580 # 80027dc8 <itable>
    80003b8c:	ffffd097          	auipc	ra,0xffffd
    80003b90:	fc6080e7          	jalr	-58(ra) # 80000b52 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003b94:	00024497          	auipc	s1,0x24
    80003b98:	25c48493          	addi	s1,s1,604 # 80027df0 <itable+0x28>
    80003b9c:	00026997          	auipc	s3,0x26
    80003ba0:	ce498993          	addi	s3,s3,-796 # 80029880 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003ba4:	00005917          	auipc	s2,0x5
    80003ba8:	ad490913          	addi	s2,s2,-1324 # 80008678 <syscalls+0x160>
    80003bac:	85ca                	mv	a1,s2
    80003bae:	8526                	mv	a0,s1
    80003bb0:	00001097          	auipc	ra,0x1
    80003bb4:	15c080e7          	jalr	348(ra) # 80004d0c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003bb8:	08848493          	addi	s1,s1,136
    80003bbc:	ff3498e3          	bne	s1,s3,80003bac <iinit+0x3e>
}
    80003bc0:	70a2                	ld	ra,40(sp)
    80003bc2:	7402                	ld	s0,32(sp)
    80003bc4:	64e2                	ld	s1,24(sp)
    80003bc6:	6942                	ld	s2,16(sp)
    80003bc8:	69a2                	ld	s3,8(sp)
    80003bca:	6145                	addi	sp,sp,48
    80003bcc:	8082                	ret

0000000080003bce <ialloc>:
{
    80003bce:	715d                	addi	sp,sp,-80
    80003bd0:	e486                	sd	ra,72(sp)
    80003bd2:	e0a2                	sd	s0,64(sp)
    80003bd4:	fc26                	sd	s1,56(sp)
    80003bd6:	f84a                	sd	s2,48(sp)
    80003bd8:	f44e                	sd	s3,40(sp)
    80003bda:	f052                	sd	s4,32(sp)
    80003bdc:	ec56                	sd	s5,24(sp)
    80003bde:	e85a                	sd	s6,16(sp)
    80003be0:	e45e                	sd	s7,8(sp)
    80003be2:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003be4:	00024717          	auipc	a4,0x24
    80003be8:	1d072703          	lw	a4,464(a4) # 80027db4 <sb+0xc>
    80003bec:	4785                	li	a5,1
    80003bee:	04e7fa63          	bgeu	a5,a4,80003c42 <ialloc+0x74>
    80003bf2:	8aaa                	mv	s5,a0
    80003bf4:	8bae                	mv	s7,a1
    80003bf6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003bf8:	00024a17          	auipc	s4,0x24
    80003bfc:	1b0a0a13          	addi	s4,s4,432 # 80027da8 <sb>
    80003c00:	00048b1b          	sext.w	s6,s1
    80003c04:	0044d793          	srli	a5,s1,0x4
    80003c08:	018a2583          	lw	a1,24(s4)
    80003c0c:	9dbd                	addw	a1,a1,a5
    80003c0e:	8556                	mv	a0,s5
    80003c10:	00000097          	auipc	ra,0x0
    80003c14:	952080e7          	jalr	-1710(ra) # 80003562 <bread>
    80003c18:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003c1a:	05850993          	addi	s3,a0,88
    80003c1e:	00f4f793          	andi	a5,s1,15
    80003c22:	079a                	slli	a5,a5,0x6
    80003c24:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003c26:	00099783          	lh	a5,0(s3)
    80003c2a:	c785                	beqz	a5,80003c52 <ialloc+0x84>
    brelse(bp);
    80003c2c:	00000097          	auipc	ra,0x0
    80003c30:	a66080e7          	jalr	-1434(ra) # 80003692 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c34:	0485                	addi	s1,s1,1
    80003c36:	00ca2703          	lw	a4,12(s4)
    80003c3a:	0004879b          	sext.w	a5,s1
    80003c3e:	fce7e1e3          	bltu	a5,a4,80003c00 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003c42:	00005517          	auipc	a0,0x5
    80003c46:	a3e50513          	addi	a0,a0,-1474 # 80008680 <syscalls+0x168>
    80003c4a:	ffffd097          	auipc	ra,0xffffd
    80003c4e:	8e0080e7          	jalr	-1824(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003c52:	04000613          	li	a2,64
    80003c56:	4581                	li	a1,0
    80003c58:	854e                	mv	a0,s3
    80003c5a:	ffffd097          	auipc	ra,0xffffd
    80003c5e:	084080e7          	jalr	132(ra) # 80000cde <memset>
      dip->type = type;
    80003c62:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003c66:	854a                	mv	a0,s2
    80003c68:	00001097          	auipc	ra,0x1
    80003c6c:	fbe080e7          	jalr	-66(ra) # 80004c26 <log_write>
      brelse(bp);
    80003c70:	854a                	mv	a0,s2
    80003c72:	00000097          	auipc	ra,0x0
    80003c76:	a20080e7          	jalr	-1504(ra) # 80003692 <brelse>
      return iget(dev, inum);
    80003c7a:	85da                	mv	a1,s6
    80003c7c:	8556                	mv	a0,s5
    80003c7e:	00000097          	auipc	ra,0x0
    80003c82:	db4080e7          	jalr	-588(ra) # 80003a32 <iget>
}
    80003c86:	60a6                	ld	ra,72(sp)
    80003c88:	6406                	ld	s0,64(sp)
    80003c8a:	74e2                	ld	s1,56(sp)
    80003c8c:	7942                	ld	s2,48(sp)
    80003c8e:	79a2                	ld	s3,40(sp)
    80003c90:	7a02                	ld	s4,32(sp)
    80003c92:	6ae2                	ld	s5,24(sp)
    80003c94:	6b42                	ld	s6,16(sp)
    80003c96:	6ba2                	ld	s7,8(sp)
    80003c98:	6161                	addi	sp,sp,80
    80003c9a:	8082                	ret

0000000080003c9c <iupdate>:
{
    80003c9c:	1101                	addi	sp,sp,-32
    80003c9e:	ec06                	sd	ra,24(sp)
    80003ca0:	e822                	sd	s0,16(sp)
    80003ca2:	e426                	sd	s1,8(sp)
    80003ca4:	e04a                	sd	s2,0(sp)
    80003ca6:	1000                	addi	s0,sp,32
    80003ca8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003caa:	415c                	lw	a5,4(a0)
    80003cac:	0047d79b          	srliw	a5,a5,0x4
    80003cb0:	00024597          	auipc	a1,0x24
    80003cb4:	1105a583          	lw	a1,272(a1) # 80027dc0 <sb+0x18>
    80003cb8:	9dbd                	addw	a1,a1,a5
    80003cba:	4108                	lw	a0,0(a0)
    80003cbc:	00000097          	auipc	ra,0x0
    80003cc0:	8a6080e7          	jalr	-1882(ra) # 80003562 <bread>
    80003cc4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003cc6:	05850793          	addi	a5,a0,88
    80003cca:	40c8                	lw	a0,4(s1)
    80003ccc:	893d                	andi	a0,a0,15
    80003cce:	051a                	slli	a0,a0,0x6
    80003cd0:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003cd2:	04449703          	lh	a4,68(s1)
    80003cd6:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003cda:	04649703          	lh	a4,70(s1)
    80003cde:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003ce2:	04849703          	lh	a4,72(s1)
    80003ce6:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003cea:	04a49703          	lh	a4,74(s1)
    80003cee:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003cf2:	44f8                	lw	a4,76(s1)
    80003cf4:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003cf6:	03400613          	li	a2,52
    80003cfa:	05048593          	addi	a1,s1,80
    80003cfe:	0531                	addi	a0,a0,12
    80003d00:	ffffd097          	auipc	ra,0xffffd
    80003d04:	03a080e7          	jalr	58(ra) # 80000d3a <memmove>
  log_write(bp);
    80003d08:	854a                	mv	a0,s2
    80003d0a:	00001097          	auipc	ra,0x1
    80003d0e:	f1c080e7          	jalr	-228(ra) # 80004c26 <log_write>
  brelse(bp);
    80003d12:	854a                	mv	a0,s2
    80003d14:	00000097          	auipc	ra,0x0
    80003d18:	97e080e7          	jalr	-1666(ra) # 80003692 <brelse>
}
    80003d1c:	60e2                	ld	ra,24(sp)
    80003d1e:	6442                	ld	s0,16(sp)
    80003d20:	64a2                	ld	s1,8(sp)
    80003d22:	6902                	ld	s2,0(sp)
    80003d24:	6105                	addi	sp,sp,32
    80003d26:	8082                	ret

0000000080003d28 <idup>:
{
    80003d28:	1101                	addi	sp,sp,-32
    80003d2a:	ec06                	sd	ra,24(sp)
    80003d2c:	e822                	sd	s0,16(sp)
    80003d2e:	e426                	sd	s1,8(sp)
    80003d30:	1000                	addi	s0,sp,32
    80003d32:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d34:	00024517          	auipc	a0,0x24
    80003d38:	09450513          	addi	a0,a0,148 # 80027dc8 <itable>
    80003d3c:	ffffd097          	auipc	ra,0xffffd
    80003d40:	ea6080e7          	jalr	-346(ra) # 80000be2 <acquire>
  ip->ref++;
    80003d44:	449c                	lw	a5,8(s1)
    80003d46:	2785                	addiw	a5,a5,1
    80003d48:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d4a:	00024517          	auipc	a0,0x24
    80003d4e:	07e50513          	addi	a0,a0,126 # 80027dc8 <itable>
    80003d52:	ffffd097          	auipc	ra,0xffffd
    80003d56:	f44080e7          	jalr	-188(ra) # 80000c96 <release>
}
    80003d5a:	8526                	mv	a0,s1
    80003d5c:	60e2                	ld	ra,24(sp)
    80003d5e:	6442                	ld	s0,16(sp)
    80003d60:	64a2                	ld	s1,8(sp)
    80003d62:	6105                	addi	sp,sp,32
    80003d64:	8082                	ret

0000000080003d66 <ilock>:
{
    80003d66:	1101                	addi	sp,sp,-32
    80003d68:	ec06                	sd	ra,24(sp)
    80003d6a:	e822                	sd	s0,16(sp)
    80003d6c:	e426                	sd	s1,8(sp)
    80003d6e:	e04a                	sd	s2,0(sp)
    80003d70:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003d72:	c115                	beqz	a0,80003d96 <ilock+0x30>
    80003d74:	84aa                	mv	s1,a0
    80003d76:	451c                	lw	a5,8(a0)
    80003d78:	00f05f63          	blez	a5,80003d96 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003d7c:	0541                	addi	a0,a0,16
    80003d7e:	00001097          	auipc	ra,0x1
    80003d82:	fc8080e7          	jalr	-56(ra) # 80004d46 <acquiresleep>
  if(ip->valid == 0){
    80003d86:	40bc                	lw	a5,64(s1)
    80003d88:	cf99                	beqz	a5,80003da6 <ilock+0x40>
}
    80003d8a:	60e2                	ld	ra,24(sp)
    80003d8c:	6442                	ld	s0,16(sp)
    80003d8e:	64a2                	ld	s1,8(sp)
    80003d90:	6902                	ld	s2,0(sp)
    80003d92:	6105                	addi	sp,sp,32
    80003d94:	8082                	ret
    panic("ilock");
    80003d96:	00005517          	auipc	a0,0x5
    80003d9a:	90250513          	addi	a0,a0,-1790 # 80008698 <syscalls+0x180>
    80003d9e:	ffffc097          	auipc	ra,0xffffc
    80003da2:	78c080e7          	jalr	1932(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003da6:	40dc                	lw	a5,4(s1)
    80003da8:	0047d79b          	srliw	a5,a5,0x4
    80003dac:	00024597          	auipc	a1,0x24
    80003db0:	0145a583          	lw	a1,20(a1) # 80027dc0 <sb+0x18>
    80003db4:	9dbd                	addw	a1,a1,a5
    80003db6:	4088                	lw	a0,0(s1)
    80003db8:	fffff097          	auipc	ra,0xfffff
    80003dbc:	7aa080e7          	jalr	1962(ra) # 80003562 <bread>
    80003dc0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003dc2:	05850593          	addi	a1,a0,88
    80003dc6:	40dc                	lw	a5,4(s1)
    80003dc8:	8bbd                	andi	a5,a5,15
    80003dca:	079a                	slli	a5,a5,0x6
    80003dcc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003dce:	00059783          	lh	a5,0(a1)
    80003dd2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003dd6:	00259783          	lh	a5,2(a1)
    80003dda:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003dde:	00459783          	lh	a5,4(a1)
    80003de2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003de6:	00659783          	lh	a5,6(a1)
    80003dea:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003dee:	459c                	lw	a5,8(a1)
    80003df0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003df2:	03400613          	li	a2,52
    80003df6:	05b1                	addi	a1,a1,12
    80003df8:	05048513          	addi	a0,s1,80
    80003dfc:	ffffd097          	auipc	ra,0xffffd
    80003e00:	f3e080e7          	jalr	-194(ra) # 80000d3a <memmove>
    brelse(bp);
    80003e04:	854a                	mv	a0,s2
    80003e06:	00000097          	auipc	ra,0x0
    80003e0a:	88c080e7          	jalr	-1908(ra) # 80003692 <brelse>
    ip->valid = 1;
    80003e0e:	4785                	li	a5,1
    80003e10:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003e12:	04449783          	lh	a5,68(s1)
    80003e16:	fbb5                	bnez	a5,80003d8a <ilock+0x24>
      panic("ilock: no type");
    80003e18:	00005517          	auipc	a0,0x5
    80003e1c:	88850513          	addi	a0,a0,-1912 # 800086a0 <syscalls+0x188>
    80003e20:	ffffc097          	auipc	ra,0xffffc
    80003e24:	70a080e7          	jalr	1802(ra) # 8000052a <panic>

0000000080003e28 <iunlock>:
{
    80003e28:	1101                	addi	sp,sp,-32
    80003e2a:	ec06                	sd	ra,24(sp)
    80003e2c:	e822                	sd	s0,16(sp)
    80003e2e:	e426                	sd	s1,8(sp)
    80003e30:	e04a                	sd	s2,0(sp)
    80003e32:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003e34:	c905                	beqz	a0,80003e64 <iunlock+0x3c>
    80003e36:	84aa                	mv	s1,a0
    80003e38:	01050913          	addi	s2,a0,16
    80003e3c:	854a                	mv	a0,s2
    80003e3e:	00001097          	auipc	ra,0x1
    80003e42:	fa2080e7          	jalr	-94(ra) # 80004de0 <holdingsleep>
    80003e46:	cd19                	beqz	a0,80003e64 <iunlock+0x3c>
    80003e48:	449c                	lw	a5,8(s1)
    80003e4a:	00f05d63          	blez	a5,80003e64 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003e4e:	854a                	mv	a0,s2
    80003e50:	00001097          	auipc	ra,0x1
    80003e54:	f4c080e7          	jalr	-180(ra) # 80004d9c <releasesleep>
}
    80003e58:	60e2                	ld	ra,24(sp)
    80003e5a:	6442                	ld	s0,16(sp)
    80003e5c:	64a2                	ld	s1,8(sp)
    80003e5e:	6902                	ld	s2,0(sp)
    80003e60:	6105                	addi	sp,sp,32
    80003e62:	8082                	ret
    panic("iunlock");
    80003e64:	00005517          	auipc	a0,0x5
    80003e68:	84c50513          	addi	a0,a0,-1972 # 800086b0 <syscalls+0x198>
    80003e6c:	ffffc097          	auipc	ra,0xffffc
    80003e70:	6be080e7          	jalr	1726(ra) # 8000052a <panic>

0000000080003e74 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003e74:	7179                	addi	sp,sp,-48
    80003e76:	f406                	sd	ra,40(sp)
    80003e78:	f022                	sd	s0,32(sp)
    80003e7a:	ec26                	sd	s1,24(sp)
    80003e7c:	e84a                	sd	s2,16(sp)
    80003e7e:	e44e                	sd	s3,8(sp)
    80003e80:	e052                	sd	s4,0(sp)
    80003e82:	1800                	addi	s0,sp,48
    80003e84:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003e86:	05050493          	addi	s1,a0,80
    80003e8a:	08050913          	addi	s2,a0,128
    80003e8e:	a021                	j	80003e96 <itrunc+0x22>
    80003e90:	0491                	addi	s1,s1,4
    80003e92:	01248d63          	beq	s1,s2,80003eac <itrunc+0x38>
    if(ip->addrs[i]){
    80003e96:	408c                	lw	a1,0(s1)
    80003e98:	dde5                	beqz	a1,80003e90 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003e9a:	0009a503          	lw	a0,0(s3)
    80003e9e:	00000097          	auipc	ra,0x0
    80003ea2:	90a080e7          	jalr	-1782(ra) # 800037a8 <bfree>
      ip->addrs[i] = 0;
    80003ea6:	0004a023          	sw	zero,0(s1)
    80003eaa:	b7dd                	j	80003e90 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003eac:	0809a583          	lw	a1,128(s3)
    80003eb0:	e185                	bnez	a1,80003ed0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003eb2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003eb6:	854e                	mv	a0,s3
    80003eb8:	00000097          	auipc	ra,0x0
    80003ebc:	de4080e7          	jalr	-540(ra) # 80003c9c <iupdate>
}
    80003ec0:	70a2                	ld	ra,40(sp)
    80003ec2:	7402                	ld	s0,32(sp)
    80003ec4:	64e2                	ld	s1,24(sp)
    80003ec6:	6942                	ld	s2,16(sp)
    80003ec8:	69a2                	ld	s3,8(sp)
    80003eca:	6a02                	ld	s4,0(sp)
    80003ecc:	6145                	addi	sp,sp,48
    80003ece:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003ed0:	0009a503          	lw	a0,0(s3)
    80003ed4:	fffff097          	auipc	ra,0xfffff
    80003ed8:	68e080e7          	jalr	1678(ra) # 80003562 <bread>
    80003edc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003ede:	05850493          	addi	s1,a0,88
    80003ee2:	45850913          	addi	s2,a0,1112
    80003ee6:	a021                	j	80003eee <itrunc+0x7a>
    80003ee8:	0491                	addi	s1,s1,4
    80003eea:	01248b63          	beq	s1,s2,80003f00 <itrunc+0x8c>
      if(a[j])
    80003eee:	408c                	lw	a1,0(s1)
    80003ef0:	dde5                	beqz	a1,80003ee8 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003ef2:	0009a503          	lw	a0,0(s3)
    80003ef6:	00000097          	auipc	ra,0x0
    80003efa:	8b2080e7          	jalr	-1870(ra) # 800037a8 <bfree>
    80003efe:	b7ed                	j	80003ee8 <itrunc+0x74>
    brelse(bp);
    80003f00:	8552                	mv	a0,s4
    80003f02:	fffff097          	auipc	ra,0xfffff
    80003f06:	790080e7          	jalr	1936(ra) # 80003692 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003f0a:	0809a583          	lw	a1,128(s3)
    80003f0e:	0009a503          	lw	a0,0(s3)
    80003f12:	00000097          	auipc	ra,0x0
    80003f16:	896080e7          	jalr	-1898(ra) # 800037a8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003f1a:	0809a023          	sw	zero,128(s3)
    80003f1e:	bf51                	j	80003eb2 <itrunc+0x3e>

0000000080003f20 <iput>:
{
    80003f20:	1101                	addi	sp,sp,-32
    80003f22:	ec06                	sd	ra,24(sp)
    80003f24:	e822                	sd	s0,16(sp)
    80003f26:	e426                	sd	s1,8(sp)
    80003f28:	e04a                	sd	s2,0(sp)
    80003f2a:	1000                	addi	s0,sp,32
    80003f2c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f2e:	00024517          	auipc	a0,0x24
    80003f32:	e9a50513          	addi	a0,a0,-358 # 80027dc8 <itable>
    80003f36:	ffffd097          	auipc	ra,0xffffd
    80003f3a:	cac080e7          	jalr	-852(ra) # 80000be2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f3e:	4498                	lw	a4,8(s1)
    80003f40:	4785                	li	a5,1
    80003f42:	02f70363          	beq	a4,a5,80003f68 <iput+0x48>
  ip->ref--;
    80003f46:	449c                	lw	a5,8(s1)
    80003f48:	37fd                	addiw	a5,a5,-1
    80003f4a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f4c:	00024517          	auipc	a0,0x24
    80003f50:	e7c50513          	addi	a0,a0,-388 # 80027dc8 <itable>
    80003f54:	ffffd097          	auipc	ra,0xffffd
    80003f58:	d42080e7          	jalr	-702(ra) # 80000c96 <release>
}
    80003f5c:	60e2                	ld	ra,24(sp)
    80003f5e:	6442                	ld	s0,16(sp)
    80003f60:	64a2                	ld	s1,8(sp)
    80003f62:	6902                	ld	s2,0(sp)
    80003f64:	6105                	addi	sp,sp,32
    80003f66:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f68:	40bc                	lw	a5,64(s1)
    80003f6a:	dff1                	beqz	a5,80003f46 <iput+0x26>
    80003f6c:	04a49783          	lh	a5,74(s1)
    80003f70:	fbf9                	bnez	a5,80003f46 <iput+0x26>
    acquiresleep(&ip->lock);
    80003f72:	01048913          	addi	s2,s1,16
    80003f76:	854a                	mv	a0,s2
    80003f78:	00001097          	auipc	ra,0x1
    80003f7c:	dce080e7          	jalr	-562(ra) # 80004d46 <acquiresleep>
    release(&itable.lock);
    80003f80:	00024517          	auipc	a0,0x24
    80003f84:	e4850513          	addi	a0,a0,-440 # 80027dc8 <itable>
    80003f88:	ffffd097          	auipc	ra,0xffffd
    80003f8c:	d0e080e7          	jalr	-754(ra) # 80000c96 <release>
    itrunc(ip);
    80003f90:	8526                	mv	a0,s1
    80003f92:	00000097          	auipc	ra,0x0
    80003f96:	ee2080e7          	jalr	-286(ra) # 80003e74 <itrunc>
    ip->type = 0;
    80003f9a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f9e:	8526                	mv	a0,s1
    80003fa0:	00000097          	auipc	ra,0x0
    80003fa4:	cfc080e7          	jalr	-772(ra) # 80003c9c <iupdate>
    ip->valid = 0;
    80003fa8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003fac:	854a                	mv	a0,s2
    80003fae:	00001097          	auipc	ra,0x1
    80003fb2:	dee080e7          	jalr	-530(ra) # 80004d9c <releasesleep>
    acquire(&itable.lock);
    80003fb6:	00024517          	auipc	a0,0x24
    80003fba:	e1250513          	addi	a0,a0,-494 # 80027dc8 <itable>
    80003fbe:	ffffd097          	auipc	ra,0xffffd
    80003fc2:	c24080e7          	jalr	-988(ra) # 80000be2 <acquire>
    80003fc6:	b741                	j	80003f46 <iput+0x26>

0000000080003fc8 <iunlockput>:
{
    80003fc8:	1101                	addi	sp,sp,-32
    80003fca:	ec06                	sd	ra,24(sp)
    80003fcc:	e822                	sd	s0,16(sp)
    80003fce:	e426                	sd	s1,8(sp)
    80003fd0:	1000                	addi	s0,sp,32
    80003fd2:	84aa                	mv	s1,a0
  iunlock(ip);
    80003fd4:	00000097          	auipc	ra,0x0
    80003fd8:	e54080e7          	jalr	-428(ra) # 80003e28 <iunlock>
  iput(ip);
    80003fdc:	8526                	mv	a0,s1
    80003fde:	00000097          	auipc	ra,0x0
    80003fe2:	f42080e7          	jalr	-190(ra) # 80003f20 <iput>
}
    80003fe6:	60e2                	ld	ra,24(sp)
    80003fe8:	6442                	ld	s0,16(sp)
    80003fea:	64a2                	ld	s1,8(sp)
    80003fec:	6105                	addi	sp,sp,32
    80003fee:	8082                	ret

0000000080003ff0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ff0:	1141                	addi	sp,sp,-16
    80003ff2:	e422                	sd	s0,8(sp)
    80003ff4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ff6:	411c                	lw	a5,0(a0)
    80003ff8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ffa:	415c                	lw	a5,4(a0)
    80003ffc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003ffe:	04451783          	lh	a5,68(a0)
    80004002:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004006:	04a51783          	lh	a5,74(a0)
    8000400a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000400e:	04c56783          	lwu	a5,76(a0)
    80004012:	e99c                	sd	a5,16(a1)
}
    80004014:	6422                	ld	s0,8(sp)
    80004016:	0141                	addi	sp,sp,16
    80004018:	8082                	ret

000000008000401a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000401a:	457c                	lw	a5,76(a0)
    8000401c:	0ed7e963          	bltu	a5,a3,8000410e <readi+0xf4>
{
    80004020:	7159                	addi	sp,sp,-112
    80004022:	f486                	sd	ra,104(sp)
    80004024:	f0a2                	sd	s0,96(sp)
    80004026:	eca6                	sd	s1,88(sp)
    80004028:	e8ca                	sd	s2,80(sp)
    8000402a:	e4ce                	sd	s3,72(sp)
    8000402c:	e0d2                	sd	s4,64(sp)
    8000402e:	fc56                	sd	s5,56(sp)
    80004030:	f85a                	sd	s6,48(sp)
    80004032:	f45e                	sd	s7,40(sp)
    80004034:	f062                	sd	s8,32(sp)
    80004036:	ec66                	sd	s9,24(sp)
    80004038:	e86a                	sd	s10,16(sp)
    8000403a:	e46e                	sd	s11,8(sp)
    8000403c:	1880                	addi	s0,sp,112
    8000403e:	8baa                	mv	s7,a0
    80004040:	8c2e                	mv	s8,a1
    80004042:	8ab2                	mv	s5,a2
    80004044:	84b6                	mv	s1,a3
    80004046:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004048:	9f35                	addw	a4,a4,a3
    return 0;
    8000404a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000404c:	0ad76063          	bltu	a4,a3,800040ec <readi+0xd2>
  if(off + n > ip->size)
    80004050:	00e7f463          	bgeu	a5,a4,80004058 <readi+0x3e>
    n = ip->size - off;
    80004054:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004058:	0a0b0963          	beqz	s6,8000410a <readi+0xf0>
    8000405c:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000405e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004062:	5cfd                	li	s9,-1
    80004064:	a82d                	j	8000409e <readi+0x84>
    80004066:	020a1d93          	slli	s11,s4,0x20
    8000406a:	020ddd93          	srli	s11,s11,0x20
    8000406e:	05890793          	addi	a5,s2,88
    80004072:	86ee                	mv	a3,s11
    80004074:	963e                	add	a2,a2,a5
    80004076:	85d6                	mv	a1,s5
    80004078:	8562                	mv	a0,s8
    8000407a:	fffff097          	auipc	ra,0xfffff
    8000407e:	9f6080e7          	jalr	-1546(ra) # 80002a70 <either_copyout>
    80004082:	05950d63          	beq	a0,s9,800040dc <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004086:	854a                	mv	a0,s2
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	60a080e7          	jalr	1546(ra) # 80003692 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004090:	013a09bb          	addw	s3,s4,s3
    80004094:	009a04bb          	addw	s1,s4,s1
    80004098:	9aee                	add	s5,s5,s11
    8000409a:	0569f763          	bgeu	s3,s6,800040e8 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000409e:	000ba903          	lw	s2,0(s7)
    800040a2:	00a4d59b          	srliw	a1,s1,0xa
    800040a6:	855e                	mv	a0,s7
    800040a8:	00000097          	auipc	ra,0x0
    800040ac:	8ae080e7          	jalr	-1874(ra) # 80003956 <bmap>
    800040b0:	0005059b          	sext.w	a1,a0
    800040b4:	854a                	mv	a0,s2
    800040b6:	fffff097          	auipc	ra,0xfffff
    800040ba:	4ac080e7          	jalr	1196(ra) # 80003562 <bread>
    800040be:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040c0:	3ff4f613          	andi	a2,s1,1023
    800040c4:	40cd07bb          	subw	a5,s10,a2
    800040c8:	413b073b          	subw	a4,s6,s3
    800040cc:	8a3e                	mv	s4,a5
    800040ce:	2781                	sext.w	a5,a5
    800040d0:	0007069b          	sext.w	a3,a4
    800040d4:	f8f6f9e3          	bgeu	a3,a5,80004066 <readi+0x4c>
    800040d8:	8a3a                	mv	s4,a4
    800040da:	b771                	j	80004066 <readi+0x4c>
      brelse(bp);
    800040dc:	854a                	mv	a0,s2
    800040de:	fffff097          	auipc	ra,0xfffff
    800040e2:	5b4080e7          	jalr	1460(ra) # 80003692 <brelse>
      tot = -1;
    800040e6:	59fd                	li	s3,-1
  }
  return tot;
    800040e8:	0009851b          	sext.w	a0,s3
}
    800040ec:	70a6                	ld	ra,104(sp)
    800040ee:	7406                	ld	s0,96(sp)
    800040f0:	64e6                	ld	s1,88(sp)
    800040f2:	6946                	ld	s2,80(sp)
    800040f4:	69a6                	ld	s3,72(sp)
    800040f6:	6a06                	ld	s4,64(sp)
    800040f8:	7ae2                	ld	s5,56(sp)
    800040fa:	7b42                	ld	s6,48(sp)
    800040fc:	7ba2                	ld	s7,40(sp)
    800040fe:	7c02                	ld	s8,32(sp)
    80004100:	6ce2                	ld	s9,24(sp)
    80004102:	6d42                	ld	s10,16(sp)
    80004104:	6da2                	ld	s11,8(sp)
    80004106:	6165                	addi	sp,sp,112
    80004108:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000410a:	89da                	mv	s3,s6
    8000410c:	bff1                	j	800040e8 <readi+0xce>
    return 0;
    8000410e:	4501                	li	a0,0
}
    80004110:	8082                	ret

0000000080004112 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004112:	457c                	lw	a5,76(a0)
    80004114:	10d7e863          	bltu	a5,a3,80004224 <writei+0x112>
{
    80004118:	7159                	addi	sp,sp,-112
    8000411a:	f486                	sd	ra,104(sp)
    8000411c:	f0a2                	sd	s0,96(sp)
    8000411e:	eca6                	sd	s1,88(sp)
    80004120:	e8ca                	sd	s2,80(sp)
    80004122:	e4ce                	sd	s3,72(sp)
    80004124:	e0d2                	sd	s4,64(sp)
    80004126:	fc56                	sd	s5,56(sp)
    80004128:	f85a                	sd	s6,48(sp)
    8000412a:	f45e                	sd	s7,40(sp)
    8000412c:	f062                	sd	s8,32(sp)
    8000412e:	ec66                	sd	s9,24(sp)
    80004130:	e86a                	sd	s10,16(sp)
    80004132:	e46e                	sd	s11,8(sp)
    80004134:	1880                	addi	s0,sp,112
    80004136:	8b2a                	mv	s6,a0
    80004138:	8c2e                	mv	s8,a1
    8000413a:	8ab2                	mv	s5,a2
    8000413c:	8936                	mv	s2,a3
    8000413e:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004140:	00e687bb          	addw	a5,a3,a4
    80004144:	0ed7e263          	bltu	a5,a3,80004228 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004148:	00043737          	lui	a4,0x43
    8000414c:	0ef76063          	bltu	a4,a5,8000422c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004150:	0c0b8863          	beqz	s7,80004220 <writei+0x10e>
    80004154:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004156:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000415a:	5cfd                	li	s9,-1
    8000415c:	a091                	j	800041a0 <writei+0x8e>
    8000415e:	02099d93          	slli	s11,s3,0x20
    80004162:	020ddd93          	srli	s11,s11,0x20
    80004166:	05848793          	addi	a5,s1,88
    8000416a:	86ee                	mv	a3,s11
    8000416c:	8656                	mv	a2,s5
    8000416e:	85e2                	mv	a1,s8
    80004170:	953e                	add	a0,a0,a5
    80004172:	fffff097          	auipc	ra,0xfffff
    80004176:	954080e7          	jalr	-1708(ra) # 80002ac6 <either_copyin>
    8000417a:	07950263          	beq	a0,s9,800041de <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000417e:	8526                	mv	a0,s1
    80004180:	00001097          	auipc	ra,0x1
    80004184:	aa6080e7          	jalr	-1370(ra) # 80004c26 <log_write>
    brelse(bp);
    80004188:	8526                	mv	a0,s1
    8000418a:	fffff097          	auipc	ra,0xfffff
    8000418e:	508080e7          	jalr	1288(ra) # 80003692 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004192:	01498a3b          	addw	s4,s3,s4
    80004196:	0129893b          	addw	s2,s3,s2
    8000419a:	9aee                	add	s5,s5,s11
    8000419c:	057a7663          	bgeu	s4,s7,800041e8 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800041a0:	000b2483          	lw	s1,0(s6)
    800041a4:	00a9559b          	srliw	a1,s2,0xa
    800041a8:	855a                	mv	a0,s6
    800041aa:	fffff097          	auipc	ra,0xfffff
    800041ae:	7ac080e7          	jalr	1964(ra) # 80003956 <bmap>
    800041b2:	0005059b          	sext.w	a1,a0
    800041b6:	8526                	mv	a0,s1
    800041b8:	fffff097          	auipc	ra,0xfffff
    800041bc:	3aa080e7          	jalr	938(ra) # 80003562 <bread>
    800041c0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800041c2:	3ff97513          	andi	a0,s2,1023
    800041c6:	40ad07bb          	subw	a5,s10,a0
    800041ca:	414b873b          	subw	a4,s7,s4
    800041ce:	89be                	mv	s3,a5
    800041d0:	2781                	sext.w	a5,a5
    800041d2:	0007069b          	sext.w	a3,a4
    800041d6:	f8f6f4e3          	bgeu	a3,a5,8000415e <writei+0x4c>
    800041da:	89ba                	mv	s3,a4
    800041dc:	b749                	j	8000415e <writei+0x4c>
      brelse(bp);
    800041de:	8526                	mv	a0,s1
    800041e0:	fffff097          	auipc	ra,0xfffff
    800041e4:	4b2080e7          	jalr	1202(ra) # 80003692 <brelse>
  }

  if(off > ip->size)
    800041e8:	04cb2783          	lw	a5,76(s6)
    800041ec:	0127f463          	bgeu	a5,s2,800041f4 <writei+0xe2>
    ip->size = off;
    800041f0:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800041f4:	855a                	mv	a0,s6
    800041f6:	00000097          	auipc	ra,0x0
    800041fa:	aa6080e7          	jalr	-1370(ra) # 80003c9c <iupdate>

  return tot;
    800041fe:	000a051b          	sext.w	a0,s4
}
    80004202:	70a6                	ld	ra,104(sp)
    80004204:	7406                	ld	s0,96(sp)
    80004206:	64e6                	ld	s1,88(sp)
    80004208:	6946                	ld	s2,80(sp)
    8000420a:	69a6                	ld	s3,72(sp)
    8000420c:	6a06                	ld	s4,64(sp)
    8000420e:	7ae2                	ld	s5,56(sp)
    80004210:	7b42                	ld	s6,48(sp)
    80004212:	7ba2                	ld	s7,40(sp)
    80004214:	7c02                	ld	s8,32(sp)
    80004216:	6ce2                	ld	s9,24(sp)
    80004218:	6d42                	ld	s10,16(sp)
    8000421a:	6da2                	ld	s11,8(sp)
    8000421c:	6165                	addi	sp,sp,112
    8000421e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004220:	8a5e                	mv	s4,s7
    80004222:	bfc9                	j	800041f4 <writei+0xe2>
    return -1;
    80004224:	557d                	li	a0,-1
}
    80004226:	8082                	ret
    return -1;
    80004228:	557d                	li	a0,-1
    8000422a:	bfe1                	j	80004202 <writei+0xf0>
    return -1;
    8000422c:	557d                	li	a0,-1
    8000422e:	bfd1                	j	80004202 <writei+0xf0>

0000000080004230 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004230:	1141                	addi	sp,sp,-16
    80004232:	e406                	sd	ra,8(sp)
    80004234:	e022                	sd	s0,0(sp)
    80004236:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004238:	4639                	li	a2,14
    8000423a:	ffffd097          	auipc	ra,0xffffd
    8000423e:	b7c080e7          	jalr	-1156(ra) # 80000db6 <strncmp>
}
    80004242:	60a2                	ld	ra,8(sp)
    80004244:	6402                	ld	s0,0(sp)
    80004246:	0141                	addi	sp,sp,16
    80004248:	8082                	ret

000000008000424a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000424a:	7139                	addi	sp,sp,-64
    8000424c:	fc06                	sd	ra,56(sp)
    8000424e:	f822                	sd	s0,48(sp)
    80004250:	f426                	sd	s1,40(sp)
    80004252:	f04a                	sd	s2,32(sp)
    80004254:	ec4e                	sd	s3,24(sp)
    80004256:	e852                	sd	s4,16(sp)
    80004258:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000425a:	04451703          	lh	a4,68(a0)
    8000425e:	4785                	li	a5,1
    80004260:	00f71a63          	bne	a4,a5,80004274 <dirlookup+0x2a>
    80004264:	892a                	mv	s2,a0
    80004266:	89ae                	mv	s3,a1
    80004268:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000426a:	457c                	lw	a5,76(a0)
    8000426c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000426e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004270:	e79d                	bnez	a5,8000429e <dirlookup+0x54>
    80004272:	a8a5                	j	800042ea <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004274:	00004517          	auipc	a0,0x4
    80004278:	44450513          	addi	a0,a0,1092 # 800086b8 <syscalls+0x1a0>
    8000427c:	ffffc097          	auipc	ra,0xffffc
    80004280:	2ae080e7          	jalr	686(ra) # 8000052a <panic>
      panic("dirlookup read");
    80004284:	00004517          	auipc	a0,0x4
    80004288:	44c50513          	addi	a0,a0,1100 # 800086d0 <syscalls+0x1b8>
    8000428c:	ffffc097          	auipc	ra,0xffffc
    80004290:	29e080e7          	jalr	670(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004294:	24c1                	addiw	s1,s1,16
    80004296:	04c92783          	lw	a5,76(s2)
    8000429a:	04f4f763          	bgeu	s1,a5,800042e8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000429e:	4741                	li	a4,16
    800042a0:	86a6                	mv	a3,s1
    800042a2:	fc040613          	addi	a2,s0,-64
    800042a6:	4581                	li	a1,0
    800042a8:	854a                	mv	a0,s2
    800042aa:	00000097          	auipc	ra,0x0
    800042ae:	d70080e7          	jalr	-656(ra) # 8000401a <readi>
    800042b2:	47c1                	li	a5,16
    800042b4:	fcf518e3          	bne	a0,a5,80004284 <dirlookup+0x3a>
    if(de.inum == 0)
    800042b8:	fc045783          	lhu	a5,-64(s0)
    800042bc:	dfe1                	beqz	a5,80004294 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800042be:	fc240593          	addi	a1,s0,-62
    800042c2:	854e                	mv	a0,s3
    800042c4:	00000097          	auipc	ra,0x0
    800042c8:	f6c080e7          	jalr	-148(ra) # 80004230 <namecmp>
    800042cc:	f561                	bnez	a0,80004294 <dirlookup+0x4a>
      if(poff)
    800042ce:	000a0463          	beqz	s4,800042d6 <dirlookup+0x8c>
        *poff = off;
    800042d2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800042d6:	fc045583          	lhu	a1,-64(s0)
    800042da:	00092503          	lw	a0,0(s2)
    800042de:	fffff097          	auipc	ra,0xfffff
    800042e2:	754080e7          	jalr	1876(ra) # 80003a32 <iget>
    800042e6:	a011                	j	800042ea <dirlookup+0xa0>
  return 0;
    800042e8:	4501                	li	a0,0
}
    800042ea:	70e2                	ld	ra,56(sp)
    800042ec:	7442                	ld	s0,48(sp)
    800042ee:	74a2                	ld	s1,40(sp)
    800042f0:	7902                	ld	s2,32(sp)
    800042f2:	69e2                	ld	s3,24(sp)
    800042f4:	6a42                	ld	s4,16(sp)
    800042f6:	6121                	addi	sp,sp,64
    800042f8:	8082                	ret

00000000800042fa <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800042fa:	711d                	addi	sp,sp,-96
    800042fc:	ec86                	sd	ra,88(sp)
    800042fe:	e8a2                	sd	s0,80(sp)
    80004300:	e4a6                	sd	s1,72(sp)
    80004302:	e0ca                	sd	s2,64(sp)
    80004304:	fc4e                	sd	s3,56(sp)
    80004306:	f852                	sd	s4,48(sp)
    80004308:	f456                	sd	s5,40(sp)
    8000430a:	f05a                	sd	s6,32(sp)
    8000430c:	ec5e                	sd	s7,24(sp)
    8000430e:	e862                	sd	s8,16(sp)
    80004310:	e466                	sd	s9,8(sp)
    80004312:	1080                	addi	s0,sp,96
    80004314:	84aa                	mv	s1,a0
    80004316:	8aae                	mv	s5,a1
    80004318:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000431a:	00054703          	lbu	a4,0(a0)
    8000431e:	02f00793          	li	a5,47
    80004322:	02f70363          	beq	a4,a5,80004348 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004326:	ffffe097          	auipc	ra,0xffffe
    8000432a:	b1a080e7          	jalr	-1254(ra) # 80001e40 <myproc>
    8000432e:	15053503          	ld	a0,336(a0)
    80004332:	00000097          	auipc	ra,0x0
    80004336:	9f6080e7          	jalr	-1546(ra) # 80003d28 <idup>
    8000433a:	89aa                	mv	s3,a0
  while(*path == '/')
    8000433c:	02f00913          	li	s2,47
  len = path - s;
    80004340:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004342:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004344:	4b85                	li	s7,1
    80004346:	a865                	j	800043fe <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004348:	4585                	li	a1,1
    8000434a:	4505                	li	a0,1
    8000434c:	fffff097          	auipc	ra,0xfffff
    80004350:	6e6080e7          	jalr	1766(ra) # 80003a32 <iget>
    80004354:	89aa                	mv	s3,a0
    80004356:	b7dd                	j	8000433c <namex+0x42>
      iunlockput(ip);
    80004358:	854e                	mv	a0,s3
    8000435a:	00000097          	auipc	ra,0x0
    8000435e:	c6e080e7          	jalr	-914(ra) # 80003fc8 <iunlockput>
      return 0;
    80004362:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004364:	854e                	mv	a0,s3
    80004366:	60e6                	ld	ra,88(sp)
    80004368:	6446                	ld	s0,80(sp)
    8000436a:	64a6                	ld	s1,72(sp)
    8000436c:	6906                	ld	s2,64(sp)
    8000436e:	79e2                	ld	s3,56(sp)
    80004370:	7a42                	ld	s4,48(sp)
    80004372:	7aa2                	ld	s5,40(sp)
    80004374:	7b02                	ld	s6,32(sp)
    80004376:	6be2                	ld	s7,24(sp)
    80004378:	6c42                	ld	s8,16(sp)
    8000437a:	6ca2                	ld	s9,8(sp)
    8000437c:	6125                	addi	sp,sp,96
    8000437e:	8082                	ret
      iunlock(ip);
    80004380:	854e                	mv	a0,s3
    80004382:	00000097          	auipc	ra,0x0
    80004386:	aa6080e7          	jalr	-1370(ra) # 80003e28 <iunlock>
      return ip;
    8000438a:	bfe9                	j	80004364 <namex+0x6a>
      iunlockput(ip);
    8000438c:	854e                	mv	a0,s3
    8000438e:	00000097          	auipc	ra,0x0
    80004392:	c3a080e7          	jalr	-966(ra) # 80003fc8 <iunlockput>
      return 0;
    80004396:	89e6                	mv	s3,s9
    80004398:	b7f1                	j	80004364 <namex+0x6a>
  len = path - s;
    8000439a:	40b48633          	sub	a2,s1,a1
    8000439e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800043a2:	099c5463          	bge	s8,s9,8000442a <namex+0x130>
    memmove(name, s, DIRSIZ);
    800043a6:	4639                	li	a2,14
    800043a8:	8552                	mv	a0,s4
    800043aa:	ffffd097          	auipc	ra,0xffffd
    800043ae:	990080e7          	jalr	-1648(ra) # 80000d3a <memmove>
  while(*path == '/')
    800043b2:	0004c783          	lbu	a5,0(s1)
    800043b6:	01279763          	bne	a5,s2,800043c4 <namex+0xca>
    path++;
    800043ba:	0485                	addi	s1,s1,1
  while(*path == '/')
    800043bc:	0004c783          	lbu	a5,0(s1)
    800043c0:	ff278de3          	beq	a5,s2,800043ba <namex+0xc0>
    ilock(ip);
    800043c4:	854e                	mv	a0,s3
    800043c6:	00000097          	auipc	ra,0x0
    800043ca:	9a0080e7          	jalr	-1632(ra) # 80003d66 <ilock>
    if(ip->type != T_DIR){
    800043ce:	04499783          	lh	a5,68(s3)
    800043d2:	f97793e3          	bne	a5,s7,80004358 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800043d6:	000a8563          	beqz	s5,800043e0 <namex+0xe6>
    800043da:	0004c783          	lbu	a5,0(s1)
    800043de:	d3cd                	beqz	a5,80004380 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800043e0:	865a                	mv	a2,s6
    800043e2:	85d2                	mv	a1,s4
    800043e4:	854e                	mv	a0,s3
    800043e6:	00000097          	auipc	ra,0x0
    800043ea:	e64080e7          	jalr	-412(ra) # 8000424a <dirlookup>
    800043ee:	8caa                	mv	s9,a0
    800043f0:	dd51                	beqz	a0,8000438c <namex+0x92>
    iunlockput(ip);
    800043f2:	854e                	mv	a0,s3
    800043f4:	00000097          	auipc	ra,0x0
    800043f8:	bd4080e7          	jalr	-1068(ra) # 80003fc8 <iunlockput>
    ip = next;
    800043fc:	89e6                	mv	s3,s9
  while(*path == '/')
    800043fe:	0004c783          	lbu	a5,0(s1)
    80004402:	05279763          	bne	a5,s2,80004450 <namex+0x156>
    path++;
    80004406:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004408:	0004c783          	lbu	a5,0(s1)
    8000440c:	ff278de3          	beq	a5,s2,80004406 <namex+0x10c>
  if(*path == 0)
    80004410:	c79d                	beqz	a5,8000443e <namex+0x144>
    path++;
    80004412:	85a6                	mv	a1,s1
  len = path - s;
    80004414:	8cda                	mv	s9,s6
    80004416:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004418:	01278963          	beq	a5,s2,8000442a <namex+0x130>
    8000441c:	dfbd                	beqz	a5,8000439a <namex+0xa0>
    path++;
    8000441e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004420:	0004c783          	lbu	a5,0(s1)
    80004424:	ff279ce3          	bne	a5,s2,8000441c <namex+0x122>
    80004428:	bf8d                	j	8000439a <namex+0xa0>
    memmove(name, s, len);
    8000442a:	2601                	sext.w	a2,a2
    8000442c:	8552                	mv	a0,s4
    8000442e:	ffffd097          	auipc	ra,0xffffd
    80004432:	90c080e7          	jalr	-1780(ra) # 80000d3a <memmove>
    name[len] = 0;
    80004436:	9cd2                	add	s9,s9,s4
    80004438:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000443c:	bf9d                	j	800043b2 <namex+0xb8>
  if(nameiparent){
    8000443e:	f20a83e3          	beqz	s5,80004364 <namex+0x6a>
    iput(ip);
    80004442:	854e                	mv	a0,s3
    80004444:	00000097          	auipc	ra,0x0
    80004448:	adc080e7          	jalr	-1316(ra) # 80003f20 <iput>
    return 0;
    8000444c:	4981                	li	s3,0
    8000444e:	bf19                	j	80004364 <namex+0x6a>
  if(*path == 0)
    80004450:	d7fd                	beqz	a5,8000443e <namex+0x144>
  while(*path != '/' && *path != 0)
    80004452:	0004c783          	lbu	a5,0(s1)
    80004456:	85a6                	mv	a1,s1
    80004458:	b7d1                	j	8000441c <namex+0x122>

000000008000445a <dirlink>:
{
    8000445a:	7139                	addi	sp,sp,-64
    8000445c:	fc06                	sd	ra,56(sp)
    8000445e:	f822                	sd	s0,48(sp)
    80004460:	f426                	sd	s1,40(sp)
    80004462:	f04a                	sd	s2,32(sp)
    80004464:	ec4e                	sd	s3,24(sp)
    80004466:	e852                	sd	s4,16(sp)
    80004468:	0080                	addi	s0,sp,64
    8000446a:	892a                	mv	s2,a0
    8000446c:	8a2e                	mv	s4,a1
    8000446e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004470:	4601                	li	a2,0
    80004472:	00000097          	auipc	ra,0x0
    80004476:	dd8080e7          	jalr	-552(ra) # 8000424a <dirlookup>
    8000447a:	e93d                	bnez	a0,800044f0 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000447c:	04c92483          	lw	s1,76(s2)
    80004480:	c49d                	beqz	s1,800044ae <dirlink+0x54>
    80004482:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004484:	4741                	li	a4,16
    80004486:	86a6                	mv	a3,s1
    80004488:	fc040613          	addi	a2,s0,-64
    8000448c:	4581                	li	a1,0
    8000448e:	854a                	mv	a0,s2
    80004490:	00000097          	auipc	ra,0x0
    80004494:	b8a080e7          	jalr	-1142(ra) # 8000401a <readi>
    80004498:	47c1                	li	a5,16
    8000449a:	06f51163          	bne	a0,a5,800044fc <dirlink+0xa2>
    if(de.inum == 0)
    8000449e:	fc045783          	lhu	a5,-64(s0)
    800044a2:	c791                	beqz	a5,800044ae <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044a4:	24c1                	addiw	s1,s1,16
    800044a6:	04c92783          	lw	a5,76(s2)
    800044aa:	fcf4ede3          	bltu	s1,a5,80004484 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800044ae:	4639                	li	a2,14
    800044b0:	85d2                	mv	a1,s4
    800044b2:	fc240513          	addi	a0,s0,-62
    800044b6:	ffffd097          	auipc	ra,0xffffd
    800044ba:	93c080e7          	jalr	-1732(ra) # 80000df2 <strncpy>
  de.inum = inum;
    800044be:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044c2:	4741                	li	a4,16
    800044c4:	86a6                	mv	a3,s1
    800044c6:	fc040613          	addi	a2,s0,-64
    800044ca:	4581                	li	a1,0
    800044cc:	854a                	mv	a0,s2
    800044ce:	00000097          	auipc	ra,0x0
    800044d2:	c44080e7          	jalr	-956(ra) # 80004112 <writei>
    800044d6:	872a                	mv	a4,a0
    800044d8:	47c1                	li	a5,16
  return 0;
    800044da:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044dc:	02f71863          	bne	a4,a5,8000450c <dirlink+0xb2>
}
    800044e0:	70e2                	ld	ra,56(sp)
    800044e2:	7442                	ld	s0,48(sp)
    800044e4:	74a2                	ld	s1,40(sp)
    800044e6:	7902                	ld	s2,32(sp)
    800044e8:	69e2                	ld	s3,24(sp)
    800044ea:	6a42                	ld	s4,16(sp)
    800044ec:	6121                	addi	sp,sp,64
    800044ee:	8082                	ret
    iput(ip);
    800044f0:	00000097          	auipc	ra,0x0
    800044f4:	a30080e7          	jalr	-1488(ra) # 80003f20 <iput>
    return -1;
    800044f8:	557d                	li	a0,-1
    800044fa:	b7dd                	j	800044e0 <dirlink+0x86>
      panic("dirlink read");
    800044fc:	00004517          	auipc	a0,0x4
    80004500:	1e450513          	addi	a0,a0,484 # 800086e0 <syscalls+0x1c8>
    80004504:	ffffc097          	auipc	ra,0xffffc
    80004508:	026080e7          	jalr	38(ra) # 8000052a <panic>
    panic("dirlink");
    8000450c:	00004517          	auipc	a0,0x4
    80004510:	35c50513          	addi	a0,a0,860 # 80008868 <syscalls+0x350>
    80004514:	ffffc097          	auipc	ra,0xffffc
    80004518:	016080e7          	jalr	22(ra) # 8000052a <panic>

000000008000451c <namei>:

struct inode*
namei(char *path)
{
    8000451c:	1101                	addi	sp,sp,-32
    8000451e:	ec06                	sd	ra,24(sp)
    80004520:	e822                	sd	s0,16(sp)
    80004522:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004524:	fe040613          	addi	a2,s0,-32
    80004528:	4581                	li	a1,0
    8000452a:	00000097          	auipc	ra,0x0
    8000452e:	dd0080e7          	jalr	-560(ra) # 800042fa <namex>
}
    80004532:	60e2                	ld	ra,24(sp)
    80004534:	6442                	ld	s0,16(sp)
    80004536:	6105                	addi	sp,sp,32
    80004538:	8082                	ret

000000008000453a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000453a:	1141                	addi	sp,sp,-16
    8000453c:	e406                	sd	ra,8(sp)
    8000453e:	e022                	sd	s0,0(sp)
    80004540:	0800                	addi	s0,sp,16
    80004542:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004544:	4585                	li	a1,1
    80004546:	00000097          	auipc	ra,0x0
    8000454a:	db4080e7          	jalr	-588(ra) # 800042fa <namex>
}
    8000454e:	60a2                	ld	ra,8(sp)
    80004550:	6402                	ld	s0,0(sp)
    80004552:	0141                	addi	sp,sp,16
    80004554:	8082                	ret

0000000080004556 <itoa>:


#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
    80004556:	1101                	addi	sp,sp,-32
    80004558:	ec22                	sd	s0,24(sp)
    8000455a:	1000                	addi	s0,sp,32
    8000455c:	872a                	mv	a4,a0
    8000455e:	852e                	mv	a0,a1
    char const digit[] = "0123456789";
    80004560:	00004797          	auipc	a5,0x4
    80004564:	19078793          	addi	a5,a5,400 # 800086f0 <syscalls+0x1d8>
    80004568:	6394                	ld	a3,0(a5)
    8000456a:	fed43023          	sd	a3,-32(s0)
    8000456e:	0087d683          	lhu	a3,8(a5)
    80004572:	fed41423          	sh	a3,-24(s0)
    80004576:	00a7c783          	lbu	a5,10(a5)
    8000457a:	fef40523          	sb	a5,-22(s0)
    char* p = b;
    8000457e:	87ae                	mv	a5,a1
    if(i<0){
    80004580:	02074b63          	bltz	a4,800045b6 <itoa+0x60>
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    80004584:	86ba                	mv	a3,a4
    do{ //Move to where representation ends
        ++p;
        shifter = shifter/10;
    80004586:	4629                	li	a2,10
        ++p;
    80004588:	0785                	addi	a5,a5,1
        shifter = shifter/10;
    8000458a:	02c6c6bb          	divw	a3,a3,a2
    }while(shifter);
    8000458e:	feed                	bnez	a3,80004588 <itoa+0x32>
    *p = '\0';
    80004590:	00078023          	sb	zero,0(a5)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
    80004594:	4629                	li	a2,10
    80004596:	17fd                	addi	a5,a5,-1
    80004598:	02c766bb          	remw	a3,a4,a2
    8000459c:	ff040593          	addi	a1,s0,-16
    800045a0:	96ae                	add	a3,a3,a1
    800045a2:	ff06c683          	lbu	a3,-16(a3)
    800045a6:	00d78023          	sb	a3,0(a5)
        i = i/10;
    800045aa:	02c7473b          	divw	a4,a4,a2
    }while(i);
    800045ae:	f765                	bnez	a4,80004596 <itoa+0x40>
    return b;
}
    800045b0:	6462                	ld	s0,24(sp)
    800045b2:	6105                	addi	sp,sp,32
    800045b4:	8082                	ret
        *p++ = '-';
    800045b6:	00158793          	addi	a5,a1,1
    800045ba:	02d00693          	li	a3,45
    800045be:	00d58023          	sb	a3,0(a1)
        i *= -1;
    800045c2:	40e0073b          	negw	a4,a4
    800045c6:	bf7d                	j	80004584 <itoa+0x2e>

00000000800045c8 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
    800045c8:	711d                	addi	sp,sp,-96
    800045ca:	ec86                	sd	ra,88(sp)
    800045cc:	e8a2                	sd	s0,80(sp)
    800045ce:	e4a6                	sd	s1,72(sp)
    800045d0:	e0ca                	sd	s2,64(sp)
    800045d2:	1080                	addi	s0,sp,96
    800045d4:	84aa                	mv	s1,a0
  //path of proccess
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    800045d6:	4619                	li	a2,6
    800045d8:	00004597          	auipc	a1,0x4
    800045dc:	12858593          	addi	a1,a1,296 # 80008700 <syscalls+0x1e8>
    800045e0:	fd040513          	addi	a0,s0,-48
    800045e4:	ffffc097          	auipc	ra,0xffffc
    800045e8:	756080e7          	jalr	1878(ra) # 80000d3a <memmove>
  itoa(p->pid, path+ 6);
    800045ec:	fd640593          	addi	a1,s0,-42
    800045f0:	5888                	lw	a0,48(s1)
    800045f2:	00000097          	auipc	ra,0x0
    800045f6:	f64080e7          	jalr	-156(ra) # 80004556 <itoa>
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ];
  uint off;

  if(0 == p->swapFile)
    800045fa:	1684b503          	ld	a0,360(s1)
    800045fe:	16050763          	beqz	a0,8000476c <removeSwapFile+0x1a4>
  {
    return -1;
  }
  fileclose(p->swapFile);
    80004602:	00001097          	auipc	ra,0x1
    80004606:	918080e7          	jalr	-1768(ra) # 80004f1a <fileclose>

  begin_op();
    8000460a:	00000097          	auipc	ra,0x0
    8000460e:	444080e7          	jalr	1092(ra) # 80004a4e <begin_op>
  if((dp = nameiparent(path, name)) == 0)
    80004612:	fb040593          	addi	a1,s0,-80
    80004616:	fd040513          	addi	a0,s0,-48
    8000461a:	00000097          	auipc	ra,0x0
    8000461e:	f20080e7          	jalr	-224(ra) # 8000453a <nameiparent>
    80004622:	892a                	mv	s2,a0
    80004624:	cd69                	beqz	a0,800046fe <removeSwapFile+0x136>
  {
    end_op();
    return -1;
  }

  ilock(dp);
    80004626:	fffff097          	auipc	ra,0xfffff
    8000462a:	740080e7          	jalr	1856(ra) # 80003d66 <ilock>

    // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000462e:	00004597          	auipc	a1,0x4
    80004632:	0da58593          	addi	a1,a1,218 # 80008708 <syscalls+0x1f0>
    80004636:	fb040513          	addi	a0,s0,-80
    8000463a:	00000097          	auipc	ra,0x0
    8000463e:	bf6080e7          	jalr	-1034(ra) # 80004230 <namecmp>
    80004642:	c57d                	beqz	a0,80004730 <removeSwapFile+0x168>
    80004644:	00004597          	auipc	a1,0x4
    80004648:	0cc58593          	addi	a1,a1,204 # 80008710 <syscalls+0x1f8>
    8000464c:	fb040513          	addi	a0,s0,-80
    80004650:	00000097          	auipc	ra,0x0
    80004654:	be0080e7          	jalr	-1056(ra) # 80004230 <namecmp>
    80004658:	cd61                	beqz	a0,80004730 <removeSwapFile+0x168>
     goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    8000465a:	fac40613          	addi	a2,s0,-84
    8000465e:	fb040593          	addi	a1,s0,-80
    80004662:	854a                	mv	a0,s2
    80004664:	00000097          	auipc	ra,0x0
    80004668:	be6080e7          	jalr	-1050(ra) # 8000424a <dirlookup>
    8000466c:	84aa                	mv	s1,a0
    8000466e:	c169                	beqz	a0,80004730 <removeSwapFile+0x168>
    goto bad;
  ilock(ip);
    80004670:	fffff097          	auipc	ra,0xfffff
    80004674:	6f6080e7          	jalr	1782(ra) # 80003d66 <ilock>

  if(ip->nlink < 1)
    80004678:	04a49783          	lh	a5,74(s1)
    8000467c:	08f05763          	blez	a5,8000470a <removeSwapFile+0x142>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004680:	04449703          	lh	a4,68(s1)
    80004684:	4785                	li	a5,1
    80004686:	08f70a63          	beq	a4,a5,8000471a <removeSwapFile+0x152>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    8000468a:	4641                	li	a2,16
    8000468c:	4581                	li	a1,0
    8000468e:	fc040513          	addi	a0,s0,-64
    80004692:	ffffc097          	auipc	ra,0xffffc
    80004696:	64c080e7          	jalr	1612(ra) # 80000cde <memset>
  if(writei(dp,0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000469a:	4741                	li	a4,16
    8000469c:	fac42683          	lw	a3,-84(s0)
    800046a0:	fc040613          	addi	a2,s0,-64
    800046a4:	4581                	li	a1,0
    800046a6:	854a                	mv	a0,s2
    800046a8:	00000097          	auipc	ra,0x0
    800046ac:	a6a080e7          	jalr	-1430(ra) # 80004112 <writei>
    800046b0:	47c1                	li	a5,16
    800046b2:	08f51a63          	bne	a0,a5,80004746 <removeSwapFile+0x17e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    800046b6:	04449703          	lh	a4,68(s1)
    800046ba:	4785                	li	a5,1
    800046bc:	08f70d63          	beq	a4,a5,80004756 <removeSwapFile+0x18e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    800046c0:	854a                	mv	a0,s2
    800046c2:	00000097          	auipc	ra,0x0
    800046c6:	906080e7          	jalr	-1786(ra) # 80003fc8 <iunlockput>

  ip->nlink--;
    800046ca:	04a4d783          	lhu	a5,74(s1)
    800046ce:	37fd                	addiw	a5,a5,-1
    800046d0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800046d4:	8526                	mv	a0,s1
    800046d6:	fffff097          	auipc	ra,0xfffff
    800046da:	5c6080e7          	jalr	1478(ra) # 80003c9c <iupdate>
  iunlockput(ip);
    800046de:	8526                	mv	a0,s1
    800046e0:	00000097          	auipc	ra,0x0
    800046e4:	8e8080e7          	jalr	-1816(ra) # 80003fc8 <iunlockput>

  end_op();
    800046e8:	00000097          	auipc	ra,0x0
    800046ec:	3e6080e7          	jalr	998(ra) # 80004ace <end_op>

  return 0;
    800046f0:	4501                	li	a0,0
  bad:
    iunlockput(dp);
    end_op();
    return -1;

}
    800046f2:	60e6                	ld	ra,88(sp)
    800046f4:	6446                	ld	s0,80(sp)
    800046f6:	64a6                	ld	s1,72(sp)
    800046f8:	6906                	ld	s2,64(sp)
    800046fa:	6125                	addi	sp,sp,96
    800046fc:	8082                	ret
    end_op();
    800046fe:	00000097          	auipc	ra,0x0
    80004702:	3d0080e7          	jalr	976(ra) # 80004ace <end_op>
    return -1;
    80004706:	557d                	li	a0,-1
    80004708:	b7ed                	j	800046f2 <removeSwapFile+0x12a>
    panic("unlink: nlink < 1");
    8000470a:	00004517          	auipc	a0,0x4
    8000470e:	00e50513          	addi	a0,a0,14 # 80008718 <syscalls+0x200>
    80004712:	ffffc097          	auipc	ra,0xffffc
    80004716:	e18080e7          	jalr	-488(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000471a:	8526                	mv	a0,s1
    8000471c:	00001097          	auipc	ra,0x1
    80004720:	7ba080e7          	jalr	1978(ra) # 80005ed6 <isdirempty>
    80004724:	f13d                	bnez	a0,8000468a <removeSwapFile+0xc2>
    iunlockput(ip);
    80004726:	8526                	mv	a0,s1
    80004728:	00000097          	auipc	ra,0x0
    8000472c:	8a0080e7          	jalr	-1888(ra) # 80003fc8 <iunlockput>
    iunlockput(dp);
    80004730:	854a                	mv	a0,s2
    80004732:	00000097          	auipc	ra,0x0
    80004736:	896080e7          	jalr	-1898(ra) # 80003fc8 <iunlockput>
    end_op();
    8000473a:	00000097          	auipc	ra,0x0
    8000473e:	394080e7          	jalr	916(ra) # 80004ace <end_op>
    return -1;
    80004742:	557d                	li	a0,-1
    80004744:	b77d                	j	800046f2 <removeSwapFile+0x12a>
    panic("unlink: writei");
    80004746:	00004517          	auipc	a0,0x4
    8000474a:	fea50513          	addi	a0,a0,-22 # 80008730 <syscalls+0x218>
    8000474e:	ffffc097          	auipc	ra,0xffffc
    80004752:	ddc080e7          	jalr	-548(ra) # 8000052a <panic>
    dp->nlink--;
    80004756:	04a95783          	lhu	a5,74(s2)
    8000475a:	37fd                	addiw	a5,a5,-1
    8000475c:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80004760:	854a                	mv	a0,s2
    80004762:	fffff097          	auipc	ra,0xfffff
    80004766:	53a080e7          	jalr	1338(ra) # 80003c9c <iupdate>
    8000476a:	bf99                	j	800046c0 <removeSwapFile+0xf8>
    return -1;
    8000476c:	557d                	li	a0,-1
    8000476e:	b751                	j	800046f2 <removeSwapFile+0x12a>

0000000080004770 <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
    80004770:	7179                	addi	sp,sp,-48
    80004772:	f406                	sd	ra,40(sp)
    80004774:	f022                	sd	s0,32(sp)
    80004776:	ec26                	sd	s1,24(sp)
    80004778:	e84a                	sd	s2,16(sp)
    8000477a:	1800                	addi	s0,sp,48
    8000477c:	84aa                	mv	s1,a0
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    8000477e:	4619                	li	a2,6
    80004780:	00004597          	auipc	a1,0x4
    80004784:	f8058593          	addi	a1,a1,-128 # 80008700 <syscalls+0x1e8>
    80004788:	fd040513          	addi	a0,s0,-48
    8000478c:	ffffc097          	auipc	ra,0xffffc
    80004790:	5ae080e7          	jalr	1454(ra) # 80000d3a <memmove>

  itoa(p->pid, path+ 6);
    80004794:	fd640593          	addi	a1,s0,-42
    80004798:	5888                	lw	a0,48(s1)
    8000479a:	00000097          	auipc	ra,0x0
    8000479e:	dbc080e7          	jalr	-580(ra) # 80004556 <itoa>

  begin_op();
    800047a2:	00000097          	auipc	ra,0x0
    800047a6:	2ac080e7          	jalr	684(ra) # 80004a4e <begin_op>
  struct inode * in = create(path, T_FILE, 0, 0);
    800047aa:	4681                	li	a3,0
    800047ac:	4601                	li	a2,0
    800047ae:	4589                	li	a1,2
    800047b0:	fd040513          	addi	a0,s0,-48
    800047b4:	00002097          	auipc	ra,0x2
    800047b8:	916080e7          	jalr	-1770(ra) # 800060ca <create>
    800047bc:	892a                	mv	s2,a0
  iunlock(in);
    800047be:	fffff097          	auipc	ra,0xfffff
    800047c2:	66a080e7          	jalr	1642(ra) # 80003e28 <iunlock>
  p->swapFile = filealloc();
    800047c6:	00000097          	auipc	ra,0x0
    800047ca:	698080e7          	jalr	1688(ra) # 80004e5e <filealloc>
    800047ce:	16a4b423          	sd	a0,360(s1)
  if (p->swapFile == 0)
    800047d2:	cd1d                	beqz	a0,80004810 <createSwapFile+0xa0>
    panic("no slot for files on /store");

  p->swapFile->ip = in;
    800047d4:	01253c23          	sd	s2,24(a0)
  p->swapFile->type = FD_INODE;
    800047d8:	1684b703          	ld	a4,360(s1)
    800047dc:	4789                	li	a5,2
    800047de:	c31c                	sw	a5,0(a4)
  p->swapFile->off = 0;
    800047e0:	1684b703          	ld	a4,360(s1)
    800047e4:	02072023          	sw	zero,32(a4) # 43020 <_entry-0x7ffbcfe0>
  p->swapFile->readable = O_WRONLY;
    800047e8:	1684b703          	ld	a4,360(s1)
    800047ec:	4685                	li	a3,1
    800047ee:	00d70423          	sb	a3,8(a4)
  p->swapFile->writable = O_RDWR;
    800047f2:	1684b703          	ld	a4,360(s1)
    800047f6:	00f704a3          	sb	a5,9(a4)
    end_op();
    800047fa:	00000097          	auipc	ra,0x0
    800047fe:	2d4080e7          	jalr	724(ra) # 80004ace <end_op>

    return 0;
}
    80004802:	4501                	li	a0,0
    80004804:	70a2                	ld	ra,40(sp)
    80004806:	7402                	ld	s0,32(sp)
    80004808:	64e2                	ld	s1,24(sp)
    8000480a:	6942                	ld	s2,16(sp)
    8000480c:	6145                	addi	sp,sp,48
    8000480e:	8082                	ret
    panic("no slot for files on /store");
    80004810:	00004517          	auipc	a0,0x4
    80004814:	f3050513          	addi	a0,a0,-208 # 80008740 <syscalls+0x228>
    80004818:	ffffc097          	auipc	ra,0xffffc
    8000481c:	d12080e7          	jalr	-750(ra) # 8000052a <panic>

0000000080004820 <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004820:	1141                	addi	sp,sp,-16
    80004822:	e406                	sd	ra,8(sp)
    80004824:	e022                	sd	s0,0(sp)
    80004826:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004828:	16853783          	ld	a5,360(a0)
    8000482c:	d390                	sw	a2,32(a5)
  return kfilewrite(p->swapFile, (uint64)buffer, size);
    8000482e:	8636                	mv	a2,a3
    80004830:	16853503          	ld	a0,360(a0)
    80004834:	00001097          	auipc	ra,0x1
    80004838:	ad8080e7          	jalr	-1320(ra) # 8000530c <kfilewrite>
}
    8000483c:	60a2                	ld	ra,8(sp)
    8000483e:	6402                	ld	s0,0(sp)
    80004840:	0141                	addi	sp,sp,16
    80004842:	8082                	ret

0000000080004844 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004844:	1141                	addi	sp,sp,-16
    80004846:	e406                	sd	ra,8(sp)
    80004848:	e022                	sd	s0,0(sp)
    8000484a:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    8000484c:	16853783          	ld	a5,360(a0)
    80004850:	d390                	sw	a2,32(a5)
  return kfileread(p->swapFile, (uint64)buffer,  size);
    80004852:	8636                	mv	a2,a3
    80004854:	16853503          	ld	a0,360(a0)
    80004858:	00001097          	auipc	ra,0x1
    8000485c:	9f2080e7          	jalr	-1550(ra) # 8000524a <kfileread>
    80004860:	60a2                	ld	ra,8(sp)
    80004862:	6402                	ld	s0,0(sp)
    80004864:	0141                	addi	sp,sp,16
    80004866:	8082                	ret

0000000080004868 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004868:	1101                	addi	sp,sp,-32
    8000486a:	ec06                	sd	ra,24(sp)
    8000486c:	e822                	sd	s0,16(sp)
    8000486e:	e426                	sd	s1,8(sp)
    80004870:	e04a                	sd	s2,0(sp)
    80004872:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004874:	00025917          	auipc	s2,0x25
    80004878:	ffc90913          	addi	s2,s2,-4 # 80029870 <log>
    8000487c:	01892583          	lw	a1,24(s2)
    80004880:	02892503          	lw	a0,40(s2)
    80004884:	fffff097          	auipc	ra,0xfffff
    80004888:	cde080e7          	jalr	-802(ra) # 80003562 <bread>
    8000488c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000488e:	02c92683          	lw	a3,44(s2)
    80004892:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004894:	02d05863          	blez	a3,800048c4 <write_head+0x5c>
    80004898:	00025797          	auipc	a5,0x25
    8000489c:	00878793          	addi	a5,a5,8 # 800298a0 <log+0x30>
    800048a0:	05c50713          	addi	a4,a0,92
    800048a4:	36fd                	addiw	a3,a3,-1
    800048a6:	02069613          	slli	a2,a3,0x20
    800048aa:	01e65693          	srli	a3,a2,0x1e
    800048ae:	00025617          	auipc	a2,0x25
    800048b2:	ff660613          	addi	a2,a2,-10 # 800298a4 <log+0x34>
    800048b6:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800048b8:	4390                	lw	a2,0(a5)
    800048ba:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800048bc:	0791                	addi	a5,a5,4
    800048be:	0711                	addi	a4,a4,4
    800048c0:	fed79ce3          	bne	a5,a3,800048b8 <write_head+0x50>
  }
  bwrite(buf);
    800048c4:	8526                	mv	a0,s1
    800048c6:	fffff097          	auipc	ra,0xfffff
    800048ca:	d8e080e7          	jalr	-626(ra) # 80003654 <bwrite>
  brelse(buf);
    800048ce:	8526                	mv	a0,s1
    800048d0:	fffff097          	auipc	ra,0xfffff
    800048d4:	dc2080e7          	jalr	-574(ra) # 80003692 <brelse>
}
    800048d8:	60e2                	ld	ra,24(sp)
    800048da:	6442                	ld	s0,16(sp)
    800048dc:	64a2                	ld	s1,8(sp)
    800048de:	6902                	ld	s2,0(sp)
    800048e0:	6105                	addi	sp,sp,32
    800048e2:	8082                	ret

00000000800048e4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800048e4:	00025797          	auipc	a5,0x25
    800048e8:	fb87a783          	lw	a5,-72(a5) # 8002989c <log+0x2c>
    800048ec:	0af05d63          	blez	a5,800049a6 <install_trans+0xc2>
{
    800048f0:	7139                	addi	sp,sp,-64
    800048f2:	fc06                	sd	ra,56(sp)
    800048f4:	f822                	sd	s0,48(sp)
    800048f6:	f426                	sd	s1,40(sp)
    800048f8:	f04a                	sd	s2,32(sp)
    800048fa:	ec4e                	sd	s3,24(sp)
    800048fc:	e852                	sd	s4,16(sp)
    800048fe:	e456                	sd	s5,8(sp)
    80004900:	e05a                	sd	s6,0(sp)
    80004902:	0080                	addi	s0,sp,64
    80004904:	8b2a                	mv	s6,a0
    80004906:	00025a97          	auipc	s5,0x25
    8000490a:	f9aa8a93          	addi	s5,s5,-102 # 800298a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000490e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004910:	00025997          	auipc	s3,0x25
    80004914:	f6098993          	addi	s3,s3,-160 # 80029870 <log>
    80004918:	a00d                	j	8000493a <install_trans+0x56>
    brelse(lbuf);
    8000491a:	854a                	mv	a0,s2
    8000491c:	fffff097          	auipc	ra,0xfffff
    80004920:	d76080e7          	jalr	-650(ra) # 80003692 <brelse>
    brelse(dbuf);
    80004924:	8526                	mv	a0,s1
    80004926:	fffff097          	auipc	ra,0xfffff
    8000492a:	d6c080e7          	jalr	-660(ra) # 80003692 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000492e:	2a05                	addiw	s4,s4,1
    80004930:	0a91                	addi	s5,s5,4
    80004932:	02c9a783          	lw	a5,44(s3)
    80004936:	04fa5e63          	bge	s4,a5,80004992 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000493a:	0189a583          	lw	a1,24(s3)
    8000493e:	014585bb          	addw	a1,a1,s4
    80004942:	2585                	addiw	a1,a1,1
    80004944:	0289a503          	lw	a0,40(s3)
    80004948:	fffff097          	auipc	ra,0xfffff
    8000494c:	c1a080e7          	jalr	-998(ra) # 80003562 <bread>
    80004950:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004952:	000aa583          	lw	a1,0(s5)
    80004956:	0289a503          	lw	a0,40(s3)
    8000495a:	fffff097          	auipc	ra,0xfffff
    8000495e:	c08080e7          	jalr	-1016(ra) # 80003562 <bread>
    80004962:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004964:	40000613          	li	a2,1024
    80004968:	05890593          	addi	a1,s2,88
    8000496c:	05850513          	addi	a0,a0,88
    80004970:	ffffc097          	auipc	ra,0xffffc
    80004974:	3ca080e7          	jalr	970(ra) # 80000d3a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004978:	8526                	mv	a0,s1
    8000497a:	fffff097          	auipc	ra,0xfffff
    8000497e:	cda080e7          	jalr	-806(ra) # 80003654 <bwrite>
    if(recovering == 0)
    80004982:	f80b1ce3          	bnez	s6,8000491a <install_trans+0x36>
      bunpin(dbuf);
    80004986:	8526                	mv	a0,s1
    80004988:	fffff097          	auipc	ra,0xfffff
    8000498c:	de4080e7          	jalr	-540(ra) # 8000376c <bunpin>
    80004990:	b769                	j	8000491a <install_trans+0x36>
}
    80004992:	70e2                	ld	ra,56(sp)
    80004994:	7442                	ld	s0,48(sp)
    80004996:	74a2                	ld	s1,40(sp)
    80004998:	7902                	ld	s2,32(sp)
    8000499a:	69e2                	ld	s3,24(sp)
    8000499c:	6a42                	ld	s4,16(sp)
    8000499e:	6aa2                	ld	s5,8(sp)
    800049a0:	6b02                	ld	s6,0(sp)
    800049a2:	6121                	addi	sp,sp,64
    800049a4:	8082                	ret
    800049a6:	8082                	ret

00000000800049a8 <initlog>:
{
    800049a8:	7179                	addi	sp,sp,-48
    800049aa:	f406                	sd	ra,40(sp)
    800049ac:	f022                	sd	s0,32(sp)
    800049ae:	ec26                	sd	s1,24(sp)
    800049b0:	e84a                	sd	s2,16(sp)
    800049b2:	e44e                	sd	s3,8(sp)
    800049b4:	1800                	addi	s0,sp,48
    800049b6:	892a                	mv	s2,a0
    800049b8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800049ba:	00025497          	auipc	s1,0x25
    800049be:	eb648493          	addi	s1,s1,-330 # 80029870 <log>
    800049c2:	00004597          	auipc	a1,0x4
    800049c6:	d9e58593          	addi	a1,a1,-610 # 80008760 <syscalls+0x248>
    800049ca:	8526                	mv	a0,s1
    800049cc:	ffffc097          	auipc	ra,0xffffc
    800049d0:	186080e7          	jalr	390(ra) # 80000b52 <initlock>
  log.start = sb->logstart;
    800049d4:	0149a583          	lw	a1,20(s3)
    800049d8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800049da:	0109a783          	lw	a5,16(s3)
    800049de:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800049e0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800049e4:	854a                	mv	a0,s2
    800049e6:	fffff097          	auipc	ra,0xfffff
    800049ea:	b7c080e7          	jalr	-1156(ra) # 80003562 <bread>
  log.lh.n = lh->n;
    800049ee:	4d34                	lw	a3,88(a0)
    800049f0:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800049f2:	02d05663          	blez	a3,80004a1e <initlog+0x76>
    800049f6:	05c50793          	addi	a5,a0,92
    800049fa:	00025717          	auipc	a4,0x25
    800049fe:	ea670713          	addi	a4,a4,-346 # 800298a0 <log+0x30>
    80004a02:	36fd                	addiw	a3,a3,-1
    80004a04:	02069613          	slli	a2,a3,0x20
    80004a08:	01e65693          	srli	a3,a2,0x1e
    80004a0c:	06050613          	addi	a2,a0,96
    80004a10:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004a12:	4390                	lw	a2,0(a5)
    80004a14:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004a16:	0791                	addi	a5,a5,4
    80004a18:	0711                	addi	a4,a4,4
    80004a1a:	fed79ce3          	bne	a5,a3,80004a12 <initlog+0x6a>
  brelse(buf);
    80004a1e:	fffff097          	auipc	ra,0xfffff
    80004a22:	c74080e7          	jalr	-908(ra) # 80003692 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004a26:	4505                	li	a0,1
    80004a28:	00000097          	auipc	ra,0x0
    80004a2c:	ebc080e7          	jalr	-324(ra) # 800048e4 <install_trans>
  log.lh.n = 0;
    80004a30:	00025797          	auipc	a5,0x25
    80004a34:	e607a623          	sw	zero,-404(a5) # 8002989c <log+0x2c>
  write_head(); // clear the log
    80004a38:	00000097          	auipc	ra,0x0
    80004a3c:	e30080e7          	jalr	-464(ra) # 80004868 <write_head>
}
    80004a40:	70a2                	ld	ra,40(sp)
    80004a42:	7402                	ld	s0,32(sp)
    80004a44:	64e2                	ld	s1,24(sp)
    80004a46:	6942                	ld	s2,16(sp)
    80004a48:	69a2                	ld	s3,8(sp)
    80004a4a:	6145                	addi	sp,sp,48
    80004a4c:	8082                	ret

0000000080004a4e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004a4e:	1101                	addi	sp,sp,-32
    80004a50:	ec06                	sd	ra,24(sp)
    80004a52:	e822                	sd	s0,16(sp)
    80004a54:	e426                	sd	s1,8(sp)
    80004a56:	e04a                	sd	s2,0(sp)
    80004a58:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004a5a:	00025517          	auipc	a0,0x25
    80004a5e:	e1650513          	addi	a0,a0,-490 # 80029870 <log>
    80004a62:	ffffc097          	auipc	ra,0xffffc
    80004a66:	180080e7          	jalr	384(ra) # 80000be2 <acquire>
  while(1){
    if(log.committing){
    80004a6a:	00025497          	auipc	s1,0x25
    80004a6e:	e0648493          	addi	s1,s1,-506 # 80029870 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004a72:	4979                	li	s2,30
    80004a74:	a039                	j	80004a82 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004a76:	85a6                	mv	a1,s1
    80004a78:	8526                	mv	a0,s1
    80004a7a:	ffffe097          	auipc	ra,0xffffe
    80004a7e:	c38080e7          	jalr	-968(ra) # 800026b2 <sleep>
    if(log.committing){
    80004a82:	50dc                	lw	a5,36(s1)
    80004a84:	fbed                	bnez	a5,80004a76 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004a86:	509c                	lw	a5,32(s1)
    80004a88:	0017871b          	addiw	a4,a5,1
    80004a8c:	0007069b          	sext.w	a3,a4
    80004a90:	0027179b          	slliw	a5,a4,0x2
    80004a94:	9fb9                	addw	a5,a5,a4
    80004a96:	0017979b          	slliw	a5,a5,0x1
    80004a9a:	54d8                	lw	a4,44(s1)
    80004a9c:	9fb9                	addw	a5,a5,a4
    80004a9e:	00f95963          	bge	s2,a5,80004ab0 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004aa2:	85a6                	mv	a1,s1
    80004aa4:	8526                	mv	a0,s1
    80004aa6:	ffffe097          	auipc	ra,0xffffe
    80004aaa:	c0c080e7          	jalr	-1012(ra) # 800026b2 <sleep>
    80004aae:	bfd1                	j	80004a82 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004ab0:	00025517          	auipc	a0,0x25
    80004ab4:	dc050513          	addi	a0,a0,-576 # 80029870 <log>
    80004ab8:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004aba:	ffffc097          	auipc	ra,0xffffc
    80004abe:	1dc080e7          	jalr	476(ra) # 80000c96 <release>
      break;
    }
  }
}
    80004ac2:	60e2                	ld	ra,24(sp)
    80004ac4:	6442                	ld	s0,16(sp)
    80004ac6:	64a2                	ld	s1,8(sp)
    80004ac8:	6902                	ld	s2,0(sp)
    80004aca:	6105                	addi	sp,sp,32
    80004acc:	8082                	ret

0000000080004ace <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004ace:	7139                	addi	sp,sp,-64
    80004ad0:	fc06                	sd	ra,56(sp)
    80004ad2:	f822                	sd	s0,48(sp)
    80004ad4:	f426                	sd	s1,40(sp)
    80004ad6:	f04a                	sd	s2,32(sp)
    80004ad8:	ec4e                	sd	s3,24(sp)
    80004ada:	e852                	sd	s4,16(sp)
    80004adc:	e456                	sd	s5,8(sp)
    80004ade:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004ae0:	00025497          	auipc	s1,0x25
    80004ae4:	d9048493          	addi	s1,s1,-624 # 80029870 <log>
    80004ae8:	8526                	mv	a0,s1
    80004aea:	ffffc097          	auipc	ra,0xffffc
    80004aee:	0f8080e7          	jalr	248(ra) # 80000be2 <acquire>
  log.outstanding -= 1;
    80004af2:	509c                	lw	a5,32(s1)
    80004af4:	37fd                	addiw	a5,a5,-1
    80004af6:	0007891b          	sext.w	s2,a5
    80004afa:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004afc:	50dc                	lw	a5,36(s1)
    80004afe:	e7b9                	bnez	a5,80004b4c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004b00:	04091e63          	bnez	s2,80004b5c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004b04:	00025497          	auipc	s1,0x25
    80004b08:	d6c48493          	addi	s1,s1,-660 # 80029870 <log>
    80004b0c:	4785                	li	a5,1
    80004b0e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004b10:	8526                	mv	a0,s1
    80004b12:	ffffc097          	auipc	ra,0xffffc
    80004b16:	184080e7          	jalr	388(ra) # 80000c96 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004b1a:	54dc                	lw	a5,44(s1)
    80004b1c:	06f04763          	bgtz	a5,80004b8a <end_op+0xbc>
    acquire(&log.lock);
    80004b20:	00025497          	auipc	s1,0x25
    80004b24:	d5048493          	addi	s1,s1,-688 # 80029870 <log>
    80004b28:	8526                	mv	a0,s1
    80004b2a:	ffffc097          	auipc	ra,0xffffc
    80004b2e:	0b8080e7          	jalr	184(ra) # 80000be2 <acquire>
    log.committing = 0;
    80004b32:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004b36:	8526                	mv	a0,s1
    80004b38:	ffffe097          	auipc	ra,0xffffe
    80004b3c:	d06080e7          	jalr	-762(ra) # 8000283e <wakeup>
    release(&log.lock);
    80004b40:	8526                	mv	a0,s1
    80004b42:	ffffc097          	auipc	ra,0xffffc
    80004b46:	154080e7          	jalr	340(ra) # 80000c96 <release>
}
    80004b4a:	a03d                	j	80004b78 <end_op+0xaa>
    panic("log.committing");
    80004b4c:	00004517          	auipc	a0,0x4
    80004b50:	c1c50513          	addi	a0,a0,-996 # 80008768 <syscalls+0x250>
    80004b54:	ffffc097          	auipc	ra,0xffffc
    80004b58:	9d6080e7          	jalr	-1578(ra) # 8000052a <panic>
    wakeup(&log);
    80004b5c:	00025497          	auipc	s1,0x25
    80004b60:	d1448493          	addi	s1,s1,-748 # 80029870 <log>
    80004b64:	8526                	mv	a0,s1
    80004b66:	ffffe097          	auipc	ra,0xffffe
    80004b6a:	cd8080e7          	jalr	-808(ra) # 8000283e <wakeup>
  release(&log.lock);
    80004b6e:	8526                	mv	a0,s1
    80004b70:	ffffc097          	auipc	ra,0xffffc
    80004b74:	126080e7          	jalr	294(ra) # 80000c96 <release>
}
    80004b78:	70e2                	ld	ra,56(sp)
    80004b7a:	7442                	ld	s0,48(sp)
    80004b7c:	74a2                	ld	s1,40(sp)
    80004b7e:	7902                	ld	s2,32(sp)
    80004b80:	69e2                	ld	s3,24(sp)
    80004b82:	6a42                	ld	s4,16(sp)
    80004b84:	6aa2                	ld	s5,8(sp)
    80004b86:	6121                	addi	sp,sp,64
    80004b88:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b8a:	00025a97          	auipc	s5,0x25
    80004b8e:	d16a8a93          	addi	s5,s5,-746 # 800298a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004b92:	00025a17          	auipc	s4,0x25
    80004b96:	cdea0a13          	addi	s4,s4,-802 # 80029870 <log>
    80004b9a:	018a2583          	lw	a1,24(s4)
    80004b9e:	012585bb          	addw	a1,a1,s2
    80004ba2:	2585                	addiw	a1,a1,1
    80004ba4:	028a2503          	lw	a0,40(s4)
    80004ba8:	fffff097          	auipc	ra,0xfffff
    80004bac:	9ba080e7          	jalr	-1606(ra) # 80003562 <bread>
    80004bb0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004bb2:	000aa583          	lw	a1,0(s5)
    80004bb6:	028a2503          	lw	a0,40(s4)
    80004bba:	fffff097          	auipc	ra,0xfffff
    80004bbe:	9a8080e7          	jalr	-1624(ra) # 80003562 <bread>
    80004bc2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004bc4:	40000613          	li	a2,1024
    80004bc8:	05850593          	addi	a1,a0,88
    80004bcc:	05848513          	addi	a0,s1,88
    80004bd0:	ffffc097          	auipc	ra,0xffffc
    80004bd4:	16a080e7          	jalr	362(ra) # 80000d3a <memmove>
    bwrite(to);  // write the log
    80004bd8:	8526                	mv	a0,s1
    80004bda:	fffff097          	auipc	ra,0xfffff
    80004bde:	a7a080e7          	jalr	-1414(ra) # 80003654 <bwrite>
    brelse(from);
    80004be2:	854e                	mv	a0,s3
    80004be4:	fffff097          	auipc	ra,0xfffff
    80004be8:	aae080e7          	jalr	-1362(ra) # 80003692 <brelse>
    brelse(to);
    80004bec:	8526                	mv	a0,s1
    80004bee:	fffff097          	auipc	ra,0xfffff
    80004bf2:	aa4080e7          	jalr	-1372(ra) # 80003692 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004bf6:	2905                	addiw	s2,s2,1
    80004bf8:	0a91                	addi	s5,s5,4
    80004bfa:	02ca2783          	lw	a5,44(s4)
    80004bfe:	f8f94ee3          	blt	s2,a5,80004b9a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004c02:	00000097          	auipc	ra,0x0
    80004c06:	c66080e7          	jalr	-922(ra) # 80004868 <write_head>
    install_trans(0); // Now install writes to home locations
    80004c0a:	4501                	li	a0,0
    80004c0c:	00000097          	auipc	ra,0x0
    80004c10:	cd8080e7          	jalr	-808(ra) # 800048e4 <install_trans>
    log.lh.n = 0;
    80004c14:	00025797          	auipc	a5,0x25
    80004c18:	c807a423          	sw	zero,-888(a5) # 8002989c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004c1c:	00000097          	auipc	ra,0x0
    80004c20:	c4c080e7          	jalr	-948(ra) # 80004868 <write_head>
    80004c24:	bdf5                	j	80004b20 <end_op+0x52>

0000000080004c26 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004c26:	1101                	addi	sp,sp,-32
    80004c28:	ec06                	sd	ra,24(sp)
    80004c2a:	e822                	sd	s0,16(sp)
    80004c2c:	e426                	sd	s1,8(sp)
    80004c2e:	e04a                	sd	s2,0(sp)
    80004c30:	1000                	addi	s0,sp,32
    80004c32:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004c34:	00025917          	auipc	s2,0x25
    80004c38:	c3c90913          	addi	s2,s2,-964 # 80029870 <log>
    80004c3c:	854a                	mv	a0,s2
    80004c3e:	ffffc097          	auipc	ra,0xffffc
    80004c42:	fa4080e7          	jalr	-92(ra) # 80000be2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004c46:	02c92603          	lw	a2,44(s2)
    80004c4a:	47f5                	li	a5,29
    80004c4c:	06c7c563          	blt	a5,a2,80004cb6 <log_write+0x90>
    80004c50:	00025797          	auipc	a5,0x25
    80004c54:	c3c7a783          	lw	a5,-964(a5) # 8002988c <log+0x1c>
    80004c58:	37fd                	addiw	a5,a5,-1
    80004c5a:	04f65e63          	bge	a2,a5,80004cb6 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004c5e:	00025797          	auipc	a5,0x25
    80004c62:	c327a783          	lw	a5,-974(a5) # 80029890 <log+0x20>
    80004c66:	06f05063          	blez	a5,80004cc6 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004c6a:	4781                	li	a5,0
    80004c6c:	06c05563          	blez	a2,80004cd6 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004c70:	44cc                	lw	a1,12(s1)
    80004c72:	00025717          	auipc	a4,0x25
    80004c76:	c2e70713          	addi	a4,a4,-978 # 800298a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004c7a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004c7c:	4314                	lw	a3,0(a4)
    80004c7e:	04b68c63          	beq	a3,a1,80004cd6 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004c82:	2785                	addiw	a5,a5,1
    80004c84:	0711                	addi	a4,a4,4
    80004c86:	fef61be3          	bne	a2,a5,80004c7c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004c8a:	0621                	addi	a2,a2,8
    80004c8c:	060a                	slli	a2,a2,0x2
    80004c8e:	00025797          	auipc	a5,0x25
    80004c92:	be278793          	addi	a5,a5,-1054 # 80029870 <log>
    80004c96:	963e                	add	a2,a2,a5
    80004c98:	44dc                	lw	a5,12(s1)
    80004c9a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004c9c:	8526                	mv	a0,s1
    80004c9e:	fffff097          	auipc	ra,0xfffff
    80004ca2:	a92080e7          	jalr	-1390(ra) # 80003730 <bpin>
    log.lh.n++;
    80004ca6:	00025717          	auipc	a4,0x25
    80004caa:	bca70713          	addi	a4,a4,-1078 # 80029870 <log>
    80004cae:	575c                	lw	a5,44(a4)
    80004cb0:	2785                	addiw	a5,a5,1
    80004cb2:	d75c                	sw	a5,44(a4)
    80004cb4:	a835                	j	80004cf0 <log_write+0xca>
    panic("too big a transaction");
    80004cb6:	00004517          	auipc	a0,0x4
    80004cba:	ac250513          	addi	a0,a0,-1342 # 80008778 <syscalls+0x260>
    80004cbe:	ffffc097          	auipc	ra,0xffffc
    80004cc2:	86c080e7          	jalr	-1940(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004cc6:	00004517          	auipc	a0,0x4
    80004cca:	aca50513          	addi	a0,a0,-1334 # 80008790 <syscalls+0x278>
    80004cce:	ffffc097          	auipc	ra,0xffffc
    80004cd2:	85c080e7          	jalr	-1956(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004cd6:	00878713          	addi	a4,a5,8
    80004cda:	00271693          	slli	a3,a4,0x2
    80004cde:	00025717          	auipc	a4,0x25
    80004ce2:	b9270713          	addi	a4,a4,-1134 # 80029870 <log>
    80004ce6:	9736                	add	a4,a4,a3
    80004ce8:	44d4                	lw	a3,12(s1)
    80004cea:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004cec:	faf608e3          	beq	a2,a5,80004c9c <log_write+0x76>
  }
  release(&log.lock);
    80004cf0:	00025517          	auipc	a0,0x25
    80004cf4:	b8050513          	addi	a0,a0,-1152 # 80029870 <log>
    80004cf8:	ffffc097          	auipc	ra,0xffffc
    80004cfc:	f9e080e7          	jalr	-98(ra) # 80000c96 <release>
}
    80004d00:	60e2                	ld	ra,24(sp)
    80004d02:	6442                	ld	s0,16(sp)
    80004d04:	64a2                	ld	s1,8(sp)
    80004d06:	6902                	ld	s2,0(sp)
    80004d08:	6105                	addi	sp,sp,32
    80004d0a:	8082                	ret

0000000080004d0c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004d0c:	1101                	addi	sp,sp,-32
    80004d0e:	ec06                	sd	ra,24(sp)
    80004d10:	e822                	sd	s0,16(sp)
    80004d12:	e426                	sd	s1,8(sp)
    80004d14:	e04a                	sd	s2,0(sp)
    80004d16:	1000                	addi	s0,sp,32
    80004d18:	84aa                	mv	s1,a0
    80004d1a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004d1c:	00004597          	auipc	a1,0x4
    80004d20:	a9458593          	addi	a1,a1,-1388 # 800087b0 <syscalls+0x298>
    80004d24:	0521                	addi	a0,a0,8
    80004d26:	ffffc097          	auipc	ra,0xffffc
    80004d2a:	e2c080e7          	jalr	-468(ra) # 80000b52 <initlock>
  lk->name = name;
    80004d2e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004d32:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004d36:	0204a423          	sw	zero,40(s1)
}
    80004d3a:	60e2                	ld	ra,24(sp)
    80004d3c:	6442                	ld	s0,16(sp)
    80004d3e:	64a2                	ld	s1,8(sp)
    80004d40:	6902                	ld	s2,0(sp)
    80004d42:	6105                	addi	sp,sp,32
    80004d44:	8082                	ret

0000000080004d46 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004d46:	1101                	addi	sp,sp,-32
    80004d48:	ec06                	sd	ra,24(sp)
    80004d4a:	e822                	sd	s0,16(sp)
    80004d4c:	e426                	sd	s1,8(sp)
    80004d4e:	e04a                	sd	s2,0(sp)
    80004d50:	1000                	addi	s0,sp,32
    80004d52:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004d54:	00850913          	addi	s2,a0,8
    80004d58:	854a                	mv	a0,s2
    80004d5a:	ffffc097          	auipc	ra,0xffffc
    80004d5e:	e88080e7          	jalr	-376(ra) # 80000be2 <acquire>
  while (lk->locked) {
    80004d62:	409c                	lw	a5,0(s1)
    80004d64:	cb89                	beqz	a5,80004d76 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004d66:	85ca                	mv	a1,s2
    80004d68:	8526                	mv	a0,s1
    80004d6a:	ffffe097          	auipc	ra,0xffffe
    80004d6e:	948080e7          	jalr	-1720(ra) # 800026b2 <sleep>
  while (lk->locked) {
    80004d72:	409c                	lw	a5,0(s1)
    80004d74:	fbed                	bnez	a5,80004d66 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004d76:	4785                	li	a5,1
    80004d78:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004d7a:	ffffd097          	auipc	ra,0xffffd
    80004d7e:	0c6080e7          	jalr	198(ra) # 80001e40 <myproc>
    80004d82:	591c                	lw	a5,48(a0)
    80004d84:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004d86:	854a                	mv	a0,s2
    80004d88:	ffffc097          	auipc	ra,0xffffc
    80004d8c:	f0e080e7          	jalr	-242(ra) # 80000c96 <release>
}
    80004d90:	60e2                	ld	ra,24(sp)
    80004d92:	6442                	ld	s0,16(sp)
    80004d94:	64a2                	ld	s1,8(sp)
    80004d96:	6902                	ld	s2,0(sp)
    80004d98:	6105                	addi	sp,sp,32
    80004d9a:	8082                	ret

0000000080004d9c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004d9c:	1101                	addi	sp,sp,-32
    80004d9e:	ec06                	sd	ra,24(sp)
    80004da0:	e822                	sd	s0,16(sp)
    80004da2:	e426                	sd	s1,8(sp)
    80004da4:	e04a                	sd	s2,0(sp)
    80004da6:	1000                	addi	s0,sp,32
    80004da8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004daa:	00850913          	addi	s2,a0,8
    80004dae:	854a                	mv	a0,s2
    80004db0:	ffffc097          	auipc	ra,0xffffc
    80004db4:	e32080e7          	jalr	-462(ra) # 80000be2 <acquire>
  lk->locked = 0;
    80004db8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004dbc:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004dc0:	8526                	mv	a0,s1
    80004dc2:	ffffe097          	auipc	ra,0xffffe
    80004dc6:	a7c080e7          	jalr	-1412(ra) # 8000283e <wakeup>
  release(&lk->lk);
    80004dca:	854a                	mv	a0,s2
    80004dcc:	ffffc097          	auipc	ra,0xffffc
    80004dd0:	eca080e7          	jalr	-310(ra) # 80000c96 <release>
}
    80004dd4:	60e2                	ld	ra,24(sp)
    80004dd6:	6442                	ld	s0,16(sp)
    80004dd8:	64a2                	ld	s1,8(sp)
    80004dda:	6902                	ld	s2,0(sp)
    80004ddc:	6105                	addi	sp,sp,32
    80004dde:	8082                	ret

0000000080004de0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004de0:	7179                	addi	sp,sp,-48
    80004de2:	f406                	sd	ra,40(sp)
    80004de4:	f022                	sd	s0,32(sp)
    80004de6:	ec26                	sd	s1,24(sp)
    80004de8:	e84a                	sd	s2,16(sp)
    80004dea:	e44e                	sd	s3,8(sp)
    80004dec:	1800                	addi	s0,sp,48
    80004dee:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004df0:	00850913          	addi	s2,a0,8
    80004df4:	854a                	mv	a0,s2
    80004df6:	ffffc097          	auipc	ra,0xffffc
    80004dfa:	dec080e7          	jalr	-532(ra) # 80000be2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004dfe:	409c                	lw	a5,0(s1)
    80004e00:	ef99                	bnez	a5,80004e1e <holdingsleep+0x3e>
    80004e02:	4481                	li	s1,0
  release(&lk->lk);
    80004e04:	854a                	mv	a0,s2
    80004e06:	ffffc097          	auipc	ra,0xffffc
    80004e0a:	e90080e7          	jalr	-368(ra) # 80000c96 <release>
  return r;
}
    80004e0e:	8526                	mv	a0,s1
    80004e10:	70a2                	ld	ra,40(sp)
    80004e12:	7402                	ld	s0,32(sp)
    80004e14:	64e2                	ld	s1,24(sp)
    80004e16:	6942                	ld	s2,16(sp)
    80004e18:	69a2                	ld	s3,8(sp)
    80004e1a:	6145                	addi	sp,sp,48
    80004e1c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004e1e:	0284a983          	lw	s3,40(s1)
    80004e22:	ffffd097          	auipc	ra,0xffffd
    80004e26:	01e080e7          	jalr	30(ra) # 80001e40 <myproc>
    80004e2a:	5904                	lw	s1,48(a0)
    80004e2c:	413484b3          	sub	s1,s1,s3
    80004e30:	0014b493          	seqz	s1,s1
    80004e34:	bfc1                	j	80004e04 <holdingsleep+0x24>

0000000080004e36 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004e36:	1141                	addi	sp,sp,-16
    80004e38:	e406                	sd	ra,8(sp)
    80004e3a:	e022                	sd	s0,0(sp)
    80004e3c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004e3e:	00004597          	auipc	a1,0x4
    80004e42:	98258593          	addi	a1,a1,-1662 # 800087c0 <syscalls+0x2a8>
    80004e46:	00025517          	auipc	a0,0x25
    80004e4a:	b7250513          	addi	a0,a0,-1166 # 800299b8 <ftable>
    80004e4e:	ffffc097          	auipc	ra,0xffffc
    80004e52:	d04080e7          	jalr	-764(ra) # 80000b52 <initlock>
}
    80004e56:	60a2                	ld	ra,8(sp)
    80004e58:	6402                	ld	s0,0(sp)
    80004e5a:	0141                	addi	sp,sp,16
    80004e5c:	8082                	ret

0000000080004e5e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004e5e:	1101                	addi	sp,sp,-32
    80004e60:	ec06                	sd	ra,24(sp)
    80004e62:	e822                	sd	s0,16(sp)
    80004e64:	e426                	sd	s1,8(sp)
    80004e66:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004e68:	00025517          	auipc	a0,0x25
    80004e6c:	b5050513          	addi	a0,a0,-1200 # 800299b8 <ftable>
    80004e70:	ffffc097          	auipc	ra,0xffffc
    80004e74:	d72080e7          	jalr	-654(ra) # 80000be2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e78:	00025497          	auipc	s1,0x25
    80004e7c:	b5848493          	addi	s1,s1,-1192 # 800299d0 <ftable+0x18>
    80004e80:	00026717          	auipc	a4,0x26
    80004e84:	af070713          	addi	a4,a4,-1296 # 8002a970 <ftable+0xfb8>
    if(f->ref == 0){
    80004e88:	40dc                	lw	a5,4(s1)
    80004e8a:	cf99                	beqz	a5,80004ea8 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e8c:	02848493          	addi	s1,s1,40
    80004e90:	fee49ce3          	bne	s1,a4,80004e88 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004e94:	00025517          	auipc	a0,0x25
    80004e98:	b2450513          	addi	a0,a0,-1244 # 800299b8 <ftable>
    80004e9c:	ffffc097          	auipc	ra,0xffffc
    80004ea0:	dfa080e7          	jalr	-518(ra) # 80000c96 <release>
  return 0;
    80004ea4:	4481                	li	s1,0
    80004ea6:	a819                	j	80004ebc <filealloc+0x5e>
      f->ref = 1;
    80004ea8:	4785                	li	a5,1
    80004eaa:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004eac:	00025517          	auipc	a0,0x25
    80004eb0:	b0c50513          	addi	a0,a0,-1268 # 800299b8 <ftable>
    80004eb4:	ffffc097          	auipc	ra,0xffffc
    80004eb8:	de2080e7          	jalr	-542(ra) # 80000c96 <release>
}
    80004ebc:	8526                	mv	a0,s1
    80004ebe:	60e2                	ld	ra,24(sp)
    80004ec0:	6442                	ld	s0,16(sp)
    80004ec2:	64a2                	ld	s1,8(sp)
    80004ec4:	6105                	addi	sp,sp,32
    80004ec6:	8082                	ret

0000000080004ec8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004ec8:	1101                	addi	sp,sp,-32
    80004eca:	ec06                	sd	ra,24(sp)
    80004ecc:	e822                	sd	s0,16(sp)
    80004ece:	e426                	sd	s1,8(sp)
    80004ed0:	1000                	addi	s0,sp,32
    80004ed2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004ed4:	00025517          	auipc	a0,0x25
    80004ed8:	ae450513          	addi	a0,a0,-1308 # 800299b8 <ftable>
    80004edc:	ffffc097          	auipc	ra,0xffffc
    80004ee0:	d06080e7          	jalr	-762(ra) # 80000be2 <acquire>
  if(f->ref < 1)
    80004ee4:	40dc                	lw	a5,4(s1)
    80004ee6:	02f05263          	blez	a5,80004f0a <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004eea:	2785                	addiw	a5,a5,1
    80004eec:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004eee:	00025517          	auipc	a0,0x25
    80004ef2:	aca50513          	addi	a0,a0,-1334 # 800299b8 <ftable>
    80004ef6:	ffffc097          	auipc	ra,0xffffc
    80004efa:	da0080e7          	jalr	-608(ra) # 80000c96 <release>
  return f;
}
    80004efe:	8526                	mv	a0,s1
    80004f00:	60e2                	ld	ra,24(sp)
    80004f02:	6442                	ld	s0,16(sp)
    80004f04:	64a2                	ld	s1,8(sp)
    80004f06:	6105                	addi	sp,sp,32
    80004f08:	8082                	ret
    panic("filedup");
    80004f0a:	00004517          	auipc	a0,0x4
    80004f0e:	8be50513          	addi	a0,a0,-1858 # 800087c8 <syscalls+0x2b0>
    80004f12:	ffffb097          	auipc	ra,0xffffb
    80004f16:	618080e7          	jalr	1560(ra) # 8000052a <panic>

0000000080004f1a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004f1a:	7139                	addi	sp,sp,-64
    80004f1c:	fc06                	sd	ra,56(sp)
    80004f1e:	f822                	sd	s0,48(sp)
    80004f20:	f426                	sd	s1,40(sp)
    80004f22:	f04a                	sd	s2,32(sp)
    80004f24:	ec4e                	sd	s3,24(sp)
    80004f26:	e852                	sd	s4,16(sp)
    80004f28:	e456                	sd	s5,8(sp)
    80004f2a:	0080                	addi	s0,sp,64
    80004f2c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004f2e:	00025517          	auipc	a0,0x25
    80004f32:	a8a50513          	addi	a0,a0,-1398 # 800299b8 <ftable>
    80004f36:	ffffc097          	auipc	ra,0xffffc
    80004f3a:	cac080e7          	jalr	-852(ra) # 80000be2 <acquire>
  if(f->ref < 1)
    80004f3e:	40dc                	lw	a5,4(s1)
    80004f40:	06f05163          	blez	a5,80004fa2 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004f44:	37fd                	addiw	a5,a5,-1
    80004f46:	0007871b          	sext.w	a4,a5
    80004f4a:	c0dc                	sw	a5,4(s1)
    80004f4c:	06e04363          	bgtz	a4,80004fb2 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004f50:	0004a903          	lw	s2,0(s1)
    80004f54:	0094ca83          	lbu	s5,9(s1)
    80004f58:	0104ba03          	ld	s4,16(s1)
    80004f5c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004f60:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004f64:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004f68:	00025517          	auipc	a0,0x25
    80004f6c:	a5050513          	addi	a0,a0,-1456 # 800299b8 <ftable>
    80004f70:	ffffc097          	auipc	ra,0xffffc
    80004f74:	d26080e7          	jalr	-730(ra) # 80000c96 <release>

  if(ff.type == FD_PIPE){
    80004f78:	4785                	li	a5,1
    80004f7a:	04f90d63          	beq	s2,a5,80004fd4 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004f7e:	3979                	addiw	s2,s2,-2
    80004f80:	4785                	li	a5,1
    80004f82:	0527e063          	bltu	a5,s2,80004fc2 <fileclose+0xa8>
    begin_op();
    80004f86:	00000097          	auipc	ra,0x0
    80004f8a:	ac8080e7          	jalr	-1336(ra) # 80004a4e <begin_op>
    iput(ff.ip);
    80004f8e:	854e                	mv	a0,s3
    80004f90:	fffff097          	auipc	ra,0xfffff
    80004f94:	f90080e7          	jalr	-112(ra) # 80003f20 <iput>
    end_op();
    80004f98:	00000097          	auipc	ra,0x0
    80004f9c:	b36080e7          	jalr	-1226(ra) # 80004ace <end_op>
    80004fa0:	a00d                	j	80004fc2 <fileclose+0xa8>
    panic("fileclose");
    80004fa2:	00004517          	auipc	a0,0x4
    80004fa6:	82e50513          	addi	a0,a0,-2002 # 800087d0 <syscalls+0x2b8>
    80004faa:	ffffb097          	auipc	ra,0xffffb
    80004fae:	580080e7          	jalr	1408(ra) # 8000052a <panic>
    release(&ftable.lock);
    80004fb2:	00025517          	auipc	a0,0x25
    80004fb6:	a0650513          	addi	a0,a0,-1530 # 800299b8 <ftable>
    80004fba:	ffffc097          	auipc	ra,0xffffc
    80004fbe:	cdc080e7          	jalr	-804(ra) # 80000c96 <release>
  }
}
    80004fc2:	70e2                	ld	ra,56(sp)
    80004fc4:	7442                	ld	s0,48(sp)
    80004fc6:	74a2                	ld	s1,40(sp)
    80004fc8:	7902                	ld	s2,32(sp)
    80004fca:	69e2                	ld	s3,24(sp)
    80004fcc:	6a42                	ld	s4,16(sp)
    80004fce:	6aa2                	ld	s5,8(sp)
    80004fd0:	6121                	addi	sp,sp,64
    80004fd2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004fd4:	85d6                	mv	a1,s5
    80004fd6:	8552                	mv	a0,s4
    80004fd8:	00000097          	auipc	ra,0x0
    80004fdc:	542080e7          	jalr	1346(ra) # 8000551a <pipeclose>
    80004fe0:	b7cd                	j	80004fc2 <fileclose+0xa8>

0000000080004fe2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004fe2:	715d                	addi	sp,sp,-80
    80004fe4:	e486                	sd	ra,72(sp)
    80004fe6:	e0a2                	sd	s0,64(sp)
    80004fe8:	fc26                	sd	s1,56(sp)
    80004fea:	f84a                	sd	s2,48(sp)
    80004fec:	f44e                	sd	s3,40(sp)
    80004fee:	0880                	addi	s0,sp,80
    80004ff0:	84aa                	mv	s1,a0
    80004ff2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ff4:	ffffd097          	auipc	ra,0xffffd
    80004ff8:	e4c080e7          	jalr	-436(ra) # 80001e40 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ffc:	409c                	lw	a5,0(s1)
    80004ffe:	37f9                	addiw	a5,a5,-2
    80005000:	4705                	li	a4,1
    80005002:	04f76763          	bltu	a4,a5,80005050 <filestat+0x6e>
    80005006:	892a                	mv	s2,a0
    ilock(f->ip);
    80005008:	6c88                	ld	a0,24(s1)
    8000500a:	fffff097          	auipc	ra,0xfffff
    8000500e:	d5c080e7          	jalr	-676(ra) # 80003d66 <ilock>
    stati(f->ip, &st);
    80005012:	fb840593          	addi	a1,s0,-72
    80005016:	6c88                	ld	a0,24(s1)
    80005018:	fffff097          	auipc	ra,0xfffff
    8000501c:	fd8080e7          	jalr	-40(ra) # 80003ff0 <stati>
    iunlock(f->ip);
    80005020:	6c88                	ld	a0,24(s1)
    80005022:	fffff097          	auipc	ra,0xfffff
    80005026:	e06080e7          	jalr	-506(ra) # 80003e28 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000502a:	46e1                	li	a3,24
    8000502c:	fb840613          	addi	a2,s0,-72
    80005030:	85ce                	mv	a1,s3
    80005032:	05093503          	ld	a0,80(s2)
    80005036:	ffffd097          	auipc	ra,0xffffd
    8000503a:	aca080e7          	jalr	-1334(ra) # 80001b00 <copyout>
    8000503e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005042:	60a6                	ld	ra,72(sp)
    80005044:	6406                	ld	s0,64(sp)
    80005046:	74e2                	ld	s1,56(sp)
    80005048:	7942                	ld	s2,48(sp)
    8000504a:	79a2                	ld	s3,40(sp)
    8000504c:	6161                	addi	sp,sp,80
    8000504e:	8082                	ret
  return -1;
    80005050:	557d                	li	a0,-1
    80005052:	bfc5                	j	80005042 <filestat+0x60>

0000000080005054 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005054:	7179                	addi	sp,sp,-48
    80005056:	f406                	sd	ra,40(sp)
    80005058:	f022                	sd	s0,32(sp)
    8000505a:	ec26                	sd	s1,24(sp)
    8000505c:	e84a                	sd	s2,16(sp)
    8000505e:	e44e                	sd	s3,8(sp)
    80005060:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005062:	00854783          	lbu	a5,8(a0)
    80005066:	c3d5                	beqz	a5,8000510a <fileread+0xb6>
    80005068:	84aa                	mv	s1,a0
    8000506a:	89ae                	mv	s3,a1
    8000506c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000506e:	411c                	lw	a5,0(a0)
    80005070:	4705                	li	a4,1
    80005072:	04e78963          	beq	a5,a4,800050c4 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005076:	470d                	li	a4,3
    80005078:	04e78d63          	beq	a5,a4,800050d2 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000507c:	4709                	li	a4,2
    8000507e:	06e79e63          	bne	a5,a4,800050fa <fileread+0xa6>
    ilock(f->ip);
    80005082:	6d08                	ld	a0,24(a0)
    80005084:	fffff097          	auipc	ra,0xfffff
    80005088:	ce2080e7          	jalr	-798(ra) # 80003d66 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000508c:	874a                	mv	a4,s2
    8000508e:	5094                	lw	a3,32(s1)
    80005090:	864e                	mv	a2,s3
    80005092:	4585                	li	a1,1
    80005094:	6c88                	ld	a0,24(s1)
    80005096:	fffff097          	auipc	ra,0xfffff
    8000509a:	f84080e7          	jalr	-124(ra) # 8000401a <readi>
    8000509e:	892a                	mv	s2,a0
    800050a0:	00a05563          	blez	a0,800050aa <fileread+0x56>
      f->off += r;
    800050a4:	509c                	lw	a5,32(s1)
    800050a6:	9fa9                	addw	a5,a5,a0
    800050a8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800050aa:	6c88                	ld	a0,24(s1)
    800050ac:	fffff097          	auipc	ra,0xfffff
    800050b0:	d7c080e7          	jalr	-644(ra) # 80003e28 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800050b4:	854a                	mv	a0,s2
    800050b6:	70a2                	ld	ra,40(sp)
    800050b8:	7402                	ld	s0,32(sp)
    800050ba:	64e2                	ld	s1,24(sp)
    800050bc:	6942                	ld	s2,16(sp)
    800050be:	69a2                	ld	s3,8(sp)
    800050c0:	6145                	addi	sp,sp,48
    800050c2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800050c4:	6908                	ld	a0,16(a0)
    800050c6:	00000097          	auipc	ra,0x0
    800050ca:	5b6080e7          	jalr	1462(ra) # 8000567c <piperead>
    800050ce:	892a                	mv	s2,a0
    800050d0:	b7d5                	j	800050b4 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800050d2:	02451783          	lh	a5,36(a0)
    800050d6:	03079693          	slli	a3,a5,0x30
    800050da:	92c1                	srli	a3,a3,0x30
    800050dc:	4725                	li	a4,9
    800050de:	02d76863          	bltu	a4,a3,8000510e <fileread+0xba>
    800050e2:	0792                	slli	a5,a5,0x4
    800050e4:	00025717          	auipc	a4,0x25
    800050e8:	83470713          	addi	a4,a4,-1996 # 80029918 <devsw>
    800050ec:	97ba                	add	a5,a5,a4
    800050ee:	639c                	ld	a5,0(a5)
    800050f0:	c38d                	beqz	a5,80005112 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800050f2:	4505                	li	a0,1
    800050f4:	9782                	jalr	a5
    800050f6:	892a                	mv	s2,a0
    800050f8:	bf75                	j	800050b4 <fileread+0x60>
    panic("fileread");
    800050fa:	00003517          	auipc	a0,0x3
    800050fe:	6e650513          	addi	a0,a0,1766 # 800087e0 <syscalls+0x2c8>
    80005102:	ffffb097          	auipc	ra,0xffffb
    80005106:	428080e7          	jalr	1064(ra) # 8000052a <panic>
    return -1;
    8000510a:	597d                	li	s2,-1
    8000510c:	b765                	j	800050b4 <fileread+0x60>
      return -1;
    8000510e:	597d                	li	s2,-1
    80005110:	b755                	j	800050b4 <fileread+0x60>
    80005112:	597d                	li	s2,-1
    80005114:	b745                	j	800050b4 <fileread+0x60>

0000000080005116 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005116:	715d                	addi	sp,sp,-80
    80005118:	e486                	sd	ra,72(sp)
    8000511a:	e0a2                	sd	s0,64(sp)
    8000511c:	fc26                	sd	s1,56(sp)
    8000511e:	f84a                	sd	s2,48(sp)
    80005120:	f44e                	sd	s3,40(sp)
    80005122:	f052                	sd	s4,32(sp)
    80005124:	ec56                	sd	s5,24(sp)
    80005126:	e85a                	sd	s6,16(sp)
    80005128:	e45e                	sd	s7,8(sp)
    8000512a:	e062                	sd	s8,0(sp)
    8000512c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000512e:	00954783          	lbu	a5,9(a0)
    80005132:	10078663          	beqz	a5,8000523e <filewrite+0x128>
    80005136:	892a                	mv	s2,a0
    80005138:	8aae                	mv	s5,a1
    8000513a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000513c:	411c                	lw	a5,0(a0)
    8000513e:	4705                	li	a4,1
    80005140:	02e78263          	beq	a5,a4,80005164 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005144:	470d                	li	a4,3
    80005146:	02e78663          	beq	a5,a4,80005172 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000514a:	4709                	li	a4,2
    8000514c:	0ee79163          	bne	a5,a4,8000522e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005150:	0ac05d63          	blez	a2,8000520a <filewrite+0xf4>
    int i = 0;
    80005154:	4981                	li	s3,0
    80005156:	6b05                	lui	s6,0x1
    80005158:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000515c:	6b85                	lui	s7,0x1
    8000515e:	c00b8b9b          	addiw	s7,s7,-1024
    80005162:	a861                	j	800051fa <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005164:	6908                	ld	a0,16(a0)
    80005166:	00000097          	auipc	ra,0x0
    8000516a:	424080e7          	jalr	1060(ra) # 8000558a <pipewrite>
    8000516e:	8a2a                	mv	s4,a0
    80005170:	a045                	j	80005210 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005172:	02451783          	lh	a5,36(a0)
    80005176:	03079693          	slli	a3,a5,0x30
    8000517a:	92c1                	srli	a3,a3,0x30
    8000517c:	4725                	li	a4,9
    8000517e:	0cd76263          	bltu	a4,a3,80005242 <filewrite+0x12c>
    80005182:	0792                	slli	a5,a5,0x4
    80005184:	00024717          	auipc	a4,0x24
    80005188:	79470713          	addi	a4,a4,1940 # 80029918 <devsw>
    8000518c:	97ba                	add	a5,a5,a4
    8000518e:	679c                	ld	a5,8(a5)
    80005190:	cbdd                	beqz	a5,80005246 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005192:	4505                	li	a0,1
    80005194:	9782                	jalr	a5
    80005196:	8a2a                	mv	s4,a0
    80005198:	a8a5                	j	80005210 <filewrite+0xfa>
    8000519a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000519e:	00000097          	auipc	ra,0x0
    800051a2:	8b0080e7          	jalr	-1872(ra) # 80004a4e <begin_op>
      ilock(f->ip);
    800051a6:	01893503          	ld	a0,24(s2)
    800051aa:	fffff097          	auipc	ra,0xfffff
    800051ae:	bbc080e7          	jalr	-1092(ra) # 80003d66 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800051b2:	8762                	mv	a4,s8
    800051b4:	02092683          	lw	a3,32(s2)
    800051b8:	01598633          	add	a2,s3,s5
    800051bc:	4585                	li	a1,1
    800051be:	01893503          	ld	a0,24(s2)
    800051c2:	fffff097          	auipc	ra,0xfffff
    800051c6:	f50080e7          	jalr	-176(ra) # 80004112 <writei>
    800051ca:	84aa                	mv	s1,a0
    800051cc:	00a05763          	blez	a0,800051da <filewrite+0xc4>
        f->off += r;
    800051d0:	02092783          	lw	a5,32(s2)
    800051d4:	9fa9                	addw	a5,a5,a0
    800051d6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800051da:	01893503          	ld	a0,24(s2)
    800051de:	fffff097          	auipc	ra,0xfffff
    800051e2:	c4a080e7          	jalr	-950(ra) # 80003e28 <iunlock>
      end_op();
    800051e6:	00000097          	auipc	ra,0x0
    800051ea:	8e8080e7          	jalr	-1816(ra) # 80004ace <end_op>

      if(r != n1){
    800051ee:	009c1f63          	bne	s8,s1,8000520c <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800051f2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800051f6:	0149db63          	bge	s3,s4,8000520c <filewrite+0xf6>
      int n1 = n - i;
    800051fa:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800051fe:	84be                	mv	s1,a5
    80005200:	2781                	sext.w	a5,a5
    80005202:	f8fb5ce3          	bge	s6,a5,8000519a <filewrite+0x84>
    80005206:	84de                	mv	s1,s7
    80005208:	bf49                	j	8000519a <filewrite+0x84>
    int i = 0;
    8000520a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000520c:	013a1f63          	bne	s4,s3,8000522a <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005210:	8552                	mv	a0,s4
    80005212:	60a6                	ld	ra,72(sp)
    80005214:	6406                	ld	s0,64(sp)
    80005216:	74e2                	ld	s1,56(sp)
    80005218:	7942                	ld	s2,48(sp)
    8000521a:	79a2                	ld	s3,40(sp)
    8000521c:	7a02                	ld	s4,32(sp)
    8000521e:	6ae2                	ld	s5,24(sp)
    80005220:	6b42                	ld	s6,16(sp)
    80005222:	6ba2                	ld	s7,8(sp)
    80005224:	6c02                	ld	s8,0(sp)
    80005226:	6161                	addi	sp,sp,80
    80005228:	8082                	ret
    ret = (i == n ? n : -1);
    8000522a:	5a7d                	li	s4,-1
    8000522c:	b7d5                	j	80005210 <filewrite+0xfa>
    panic("filewrite");
    8000522e:	00003517          	auipc	a0,0x3
    80005232:	5c250513          	addi	a0,a0,1474 # 800087f0 <syscalls+0x2d8>
    80005236:	ffffb097          	auipc	ra,0xffffb
    8000523a:	2f4080e7          	jalr	756(ra) # 8000052a <panic>
    return -1;
    8000523e:	5a7d                	li	s4,-1
    80005240:	bfc1                	j	80005210 <filewrite+0xfa>
      return -1;
    80005242:	5a7d                	li	s4,-1
    80005244:	b7f1                	j	80005210 <filewrite+0xfa>
    80005246:	5a7d                	li	s4,-1
    80005248:	b7e1                	j	80005210 <filewrite+0xfa>

000000008000524a <kfileread>:

// Read from file f.
// addr is a kernel virtual address.
int
kfileread(struct file *f, uint64 addr, int n)
{
    8000524a:	7179                	addi	sp,sp,-48
    8000524c:	f406                	sd	ra,40(sp)
    8000524e:	f022                	sd	s0,32(sp)
    80005250:	ec26                	sd	s1,24(sp)
    80005252:	e84a                	sd	s2,16(sp)
    80005254:	e44e                	sd	s3,8(sp)
    80005256:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005258:	00854783          	lbu	a5,8(a0)
    8000525c:	c3d5                	beqz	a5,80005300 <kfileread+0xb6>
    8000525e:	84aa                	mv	s1,a0
    80005260:	89ae                	mv	s3,a1
    80005262:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005264:	411c                	lw	a5,0(a0)
    80005266:	4705                	li	a4,1
    80005268:	04e78963          	beq	a5,a4,800052ba <kfileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000526c:	470d                	li	a4,3
    8000526e:	04e78d63          	beq	a5,a4,800052c8 <kfileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005272:	4709                	li	a4,2
    80005274:	06e79e63          	bne	a5,a4,800052f0 <kfileread+0xa6>
    ilock(f->ip);
    80005278:	6d08                	ld	a0,24(a0)
    8000527a:	fffff097          	auipc	ra,0xfffff
    8000527e:	aec080e7          	jalr	-1300(ra) # 80003d66 <ilock>
    if((r = readi(f->ip, 0, addr, f->off, n)) > 0)
    80005282:	874a                	mv	a4,s2
    80005284:	5094                	lw	a3,32(s1)
    80005286:	864e                	mv	a2,s3
    80005288:	4581                	li	a1,0
    8000528a:	6c88                	ld	a0,24(s1)
    8000528c:	fffff097          	auipc	ra,0xfffff
    80005290:	d8e080e7          	jalr	-626(ra) # 8000401a <readi>
    80005294:	892a                	mv	s2,a0
    80005296:	00a05563          	blez	a0,800052a0 <kfileread+0x56>
      f->off += r;
    8000529a:	509c                	lw	a5,32(s1)
    8000529c:	9fa9                	addw	a5,a5,a0
    8000529e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800052a0:	6c88                	ld	a0,24(s1)
    800052a2:	fffff097          	auipc	ra,0xfffff
    800052a6:	b86080e7          	jalr	-1146(ra) # 80003e28 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800052aa:	854a                	mv	a0,s2
    800052ac:	70a2                	ld	ra,40(sp)
    800052ae:	7402                	ld	s0,32(sp)
    800052b0:	64e2                	ld	s1,24(sp)
    800052b2:	6942                	ld	s2,16(sp)
    800052b4:	69a2                	ld	s3,8(sp)
    800052b6:	6145                	addi	sp,sp,48
    800052b8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800052ba:	6908                	ld	a0,16(a0)
    800052bc:	00000097          	auipc	ra,0x0
    800052c0:	3c0080e7          	jalr	960(ra) # 8000567c <piperead>
    800052c4:	892a                	mv	s2,a0
    800052c6:	b7d5                	j	800052aa <kfileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800052c8:	02451783          	lh	a5,36(a0)
    800052cc:	03079693          	slli	a3,a5,0x30
    800052d0:	92c1                	srli	a3,a3,0x30
    800052d2:	4725                	li	a4,9
    800052d4:	02d76863          	bltu	a4,a3,80005304 <kfileread+0xba>
    800052d8:	0792                	slli	a5,a5,0x4
    800052da:	00024717          	auipc	a4,0x24
    800052de:	63e70713          	addi	a4,a4,1598 # 80029918 <devsw>
    800052e2:	97ba                	add	a5,a5,a4
    800052e4:	639c                	ld	a5,0(a5)
    800052e6:	c38d                	beqz	a5,80005308 <kfileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800052e8:	4505                	li	a0,1
    800052ea:	9782                	jalr	a5
    800052ec:	892a                	mv	s2,a0
    800052ee:	bf75                	j	800052aa <kfileread+0x60>
    panic("fileread");
    800052f0:	00003517          	auipc	a0,0x3
    800052f4:	4f050513          	addi	a0,a0,1264 # 800087e0 <syscalls+0x2c8>
    800052f8:	ffffb097          	auipc	ra,0xffffb
    800052fc:	232080e7          	jalr	562(ra) # 8000052a <panic>
    return -1;
    80005300:	597d                	li	s2,-1
    80005302:	b765                	j	800052aa <kfileread+0x60>
      return -1;
    80005304:	597d                	li	s2,-1
    80005306:	b755                	j	800052aa <kfileread+0x60>
    80005308:	597d                	li	s2,-1
    8000530a:	b745                	j	800052aa <kfileread+0x60>

000000008000530c <kfilewrite>:

// Write to file f.
// addr is a kernel virtual address.
int
kfilewrite(struct file *f, uint64 addr, int n)
{
    8000530c:	715d                	addi	sp,sp,-80
    8000530e:	e486                	sd	ra,72(sp)
    80005310:	e0a2                	sd	s0,64(sp)
    80005312:	fc26                	sd	s1,56(sp)
    80005314:	f84a                	sd	s2,48(sp)
    80005316:	f44e                	sd	s3,40(sp)
    80005318:	f052                	sd	s4,32(sp)
    8000531a:	ec56                	sd	s5,24(sp)
    8000531c:	e85a                	sd	s6,16(sp)
    8000531e:	e45e                	sd	s7,8(sp)
    80005320:	e062                	sd	s8,0(sp)
    80005322:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005324:	00954783          	lbu	a5,9(a0)
    80005328:	10078663          	beqz	a5,80005434 <kfilewrite+0x128>
    8000532c:	892a                	mv	s2,a0
    8000532e:	8aae                	mv	s5,a1
    80005330:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005332:	411c                	lw	a5,0(a0)
    80005334:	4705                	li	a4,1
    80005336:	02e78263          	beq	a5,a4,8000535a <kfilewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000533a:	470d                	li	a4,3
    8000533c:	02e78663          	beq	a5,a4,80005368 <kfilewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005340:	4709                	li	a4,2
    80005342:	0ee79163          	bne	a5,a4,80005424 <kfilewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005346:	0ac05d63          	blez	a2,80005400 <kfilewrite+0xf4>
    int i = 0;
    8000534a:	4981                	li	s3,0
    8000534c:	6b05                	lui	s6,0x1
    8000534e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005352:	6b85                	lui	s7,0x1
    80005354:	c00b8b9b          	addiw	s7,s7,-1024
    80005358:	a861                	j	800053f0 <kfilewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000535a:	6908                	ld	a0,16(a0)
    8000535c:	00000097          	auipc	ra,0x0
    80005360:	22e080e7          	jalr	558(ra) # 8000558a <pipewrite>
    80005364:	8a2a                	mv	s4,a0
    80005366:	a045                	j	80005406 <kfilewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005368:	02451783          	lh	a5,36(a0)
    8000536c:	03079693          	slli	a3,a5,0x30
    80005370:	92c1                	srli	a3,a3,0x30
    80005372:	4725                	li	a4,9
    80005374:	0cd76263          	bltu	a4,a3,80005438 <kfilewrite+0x12c>
    80005378:	0792                	slli	a5,a5,0x4
    8000537a:	00024717          	auipc	a4,0x24
    8000537e:	59e70713          	addi	a4,a4,1438 # 80029918 <devsw>
    80005382:	97ba                	add	a5,a5,a4
    80005384:	679c                	ld	a5,8(a5)
    80005386:	cbdd                	beqz	a5,8000543c <kfilewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005388:	4505                	li	a0,1
    8000538a:	9782                	jalr	a5
    8000538c:	8a2a                	mv	s4,a0
    8000538e:	a8a5                	j	80005406 <kfilewrite+0xfa>
    80005390:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005394:	fffff097          	auipc	ra,0xfffff
    80005398:	6ba080e7          	jalr	1722(ra) # 80004a4e <begin_op>
      ilock(f->ip);
    8000539c:	01893503          	ld	a0,24(s2)
    800053a0:	fffff097          	auipc	ra,0xfffff
    800053a4:	9c6080e7          	jalr	-1594(ra) # 80003d66 <ilock>
      if ((r = writei(f->ip, 0, addr + i, f->off, n1)) > 0)
    800053a8:	8762                	mv	a4,s8
    800053aa:	02092683          	lw	a3,32(s2)
    800053ae:	01598633          	add	a2,s3,s5
    800053b2:	4581                	li	a1,0
    800053b4:	01893503          	ld	a0,24(s2)
    800053b8:	fffff097          	auipc	ra,0xfffff
    800053bc:	d5a080e7          	jalr	-678(ra) # 80004112 <writei>
    800053c0:	84aa                	mv	s1,a0
    800053c2:	00a05763          	blez	a0,800053d0 <kfilewrite+0xc4>
        f->off += r;
    800053c6:	02092783          	lw	a5,32(s2)
    800053ca:	9fa9                	addw	a5,a5,a0
    800053cc:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800053d0:	01893503          	ld	a0,24(s2)
    800053d4:	fffff097          	auipc	ra,0xfffff
    800053d8:	a54080e7          	jalr	-1452(ra) # 80003e28 <iunlock>
      end_op();
    800053dc:	fffff097          	auipc	ra,0xfffff
    800053e0:	6f2080e7          	jalr	1778(ra) # 80004ace <end_op>

      if(r != n1){
    800053e4:	009c1f63          	bne	s8,s1,80005402 <kfilewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800053e8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800053ec:	0149db63          	bge	s3,s4,80005402 <kfilewrite+0xf6>
      int n1 = n - i;
    800053f0:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800053f4:	84be                	mv	s1,a5
    800053f6:	2781                	sext.w	a5,a5
    800053f8:	f8fb5ce3          	bge	s6,a5,80005390 <kfilewrite+0x84>
    800053fc:	84de                	mv	s1,s7
    800053fe:	bf49                	j	80005390 <kfilewrite+0x84>
    int i = 0;
    80005400:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005402:	013a1f63          	bne	s4,s3,80005420 <kfilewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
    80005406:	8552                	mv	a0,s4
    80005408:	60a6                	ld	ra,72(sp)
    8000540a:	6406                	ld	s0,64(sp)
    8000540c:	74e2                	ld	s1,56(sp)
    8000540e:	7942                	ld	s2,48(sp)
    80005410:	79a2                	ld	s3,40(sp)
    80005412:	7a02                	ld	s4,32(sp)
    80005414:	6ae2                	ld	s5,24(sp)
    80005416:	6b42                	ld	s6,16(sp)
    80005418:	6ba2                	ld	s7,8(sp)
    8000541a:	6c02                	ld	s8,0(sp)
    8000541c:	6161                	addi	sp,sp,80
    8000541e:	8082                	ret
    ret = (i == n ? n : -1);
    80005420:	5a7d                	li	s4,-1
    80005422:	b7d5                	j	80005406 <kfilewrite+0xfa>
    panic("filewrite");
    80005424:	00003517          	auipc	a0,0x3
    80005428:	3cc50513          	addi	a0,a0,972 # 800087f0 <syscalls+0x2d8>
    8000542c:	ffffb097          	auipc	ra,0xffffb
    80005430:	0fe080e7          	jalr	254(ra) # 8000052a <panic>
    return -1;
    80005434:	5a7d                	li	s4,-1
    80005436:	bfc1                	j	80005406 <kfilewrite+0xfa>
      return -1;
    80005438:	5a7d                	li	s4,-1
    8000543a:	b7f1                	j	80005406 <kfilewrite+0xfa>
    8000543c:	5a7d                	li	s4,-1
    8000543e:	b7e1                	j	80005406 <kfilewrite+0xfa>

0000000080005440 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005440:	7179                	addi	sp,sp,-48
    80005442:	f406                	sd	ra,40(sp)
    80005444:	f022                	sd	s0,32(sp)
    80005446:	ec26                	sd	s1,24(sp)
    80005448:	e84a                	sd	s2,16(sp)
    8000544a:	e44e                	sd	s3,8(sp)
    8000544c:	e052                	sd	s4,0(sp)
    8000544e:	1800                	addi	s0,sp,48
    80005450:	84aa                	mv	s1,a0
    80005452:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005454:	0005b023          	sd	zero,0(a1)
    80005458:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000545c:	00000097          	auipc	ra,0x0
    80005460:	a02080e7          	jalr	-1534(ra) # 80004e5e <filealloc>
    80005464:	e088                	sd	a0,0(s1)
    80005466:	c551                	beqz	a0,800054f2 <pipealloc+0xb2>
    80005468:	00000097          	auipc	ra,0x0
    8000546c:	9f6080e7          	jalr	-1546(ra) # 80004e5e <filealloc>
    80005470:	00aa3023          	sd	a0,0(s4)
    80005474:	c92d                	beqz	a0,800054e6 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005476:	ffffb097          	auipc	ra,0xffffb
    8000547a:	67c080e7          	jalr	1660(ra) # 80000af2 <kalloc>
    8000547e:	892a                	mv	s2,a0
    80005480:	c125                	beqz	a0,800054e0 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005482:	4985                	li	s3,1
    80005484:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005488:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000548c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005490:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005494:	00003597          	auipc	a1,0x3
    80005498:	36c58593          	addi	a1,a1,876 # 80008800 <syscalls+0x2e8>
    8000549c:	ffffb097          	auipc	ra,0xffffb
    800054a0:	6b6080e7          	jalr	1718(ra) # 80000b52 <initlock>
  (*f0)->type = FD_PIPE;
    800054a4:	609c                	ld	a5,0(s1)
    800054a6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800054aa:	609c                	ld	a5,0(s1)
    800054ac:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800054b0:	609c                	ld	a5,0(s1)
    800054b2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800054b6:	609c                	ld	a5,0(s1)
    800054b8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800054bc:	000a3783          	ld	a5,0(s4)
    800054c0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800054c4:	000a3783          	ld	a5,0(s4)
    800054c8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800054cc:	000a3783          	ld	a5,0(s4)
    800054d0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800054d4:	000a3783          	ld	a5,0(s4)
    800054d8:	0127b823          	sd	s2,16(a5)
  return 0;
    800054dc:	4501                	li	a0,0
    800054de:	a025                	j	80005506 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800054e0:	6088                	ld	a0,0(s1)
    800054e2:	e501                	bnez	a0,800054ea <pipealloc+0xaa>
    800054e4:	a039                	j	800054f2 <pipealloc+0xb2>
    800054e6:	6088                	ld	a0,0(s1)
    800054e8:	c51d                	beqz	a0,80005516 <pipealloc+0xd6>
    fileclose(*f0);
    800054ea:	00000097          	auipc	ra,0x0
    800054ee:	a30080e7          	jalr	-1488(ra) # 80004f1a <fileclose>
  if(*f1)
    800054f2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800054f6:	557d                	li	a0,-1
  if(*f1)
    800054f8:	c799                	beqz	a5,80005506 <pipealloc+0xc6>
    fileclose(*f1);
    800054fa:	853e                	mv	a0,a5
    800054fc:	00000097          	auipc	ra,0x0
    80005500:	a1e080e7          	jalr	-1506(ra) # 80004f1a <fileclose>
  return -1;
    80005504:	557d                	li	a0,-1
}
    80005506:	70a2                	ld	ra,40(sp)
    80005508:	7402                	ld	s0,32(sp)
    8000550a:	64e2                	ld	s1,24(sp)
    8000550c:	6942                	ld	s2,16(sp)
    8000550e:	69a2                	ld	s3,8(sp)
    80005510:	6a02                	ld	s4,0(sp)
    80005512:	6145                	addi	sp,sp,48
    80005514:	8082                	ret
  return -1;
    80005516:	557d                	li	a0,-1
    80005518:	b7fd                	j	80005506 <pipealloc+0xc6>

000000008000551a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000551a:	1101                	addi	sp,sp,-32
    8000551c:	ec06                	sd	ra,24(sp)
    8000551e:	e822                	sd	s0,16(sp)
    80005520:	e426                	sd	s1,8(sp)
    80005522:	e04a                	sd	s2,0(sp)
    80005524:	1000                	addi	s0,sp,32
    80005526:	84aa                	mv	s1,a0
    80005528:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000552a:	ffffb097          	auipc	ra,0xffffb
    8000552e:	6b8080e7          	jalr	1720(ra) # 80000be2 <acquire>
  if(writable){
    80005532:	02090d63          	beqz	s2,8000556c <pipeclose+0x52>
    pi->writeopen = 0;
    80005536:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000553a:	21848513          	addi	a0,s1,536
    8000553e:	ffffd097          	auipc	ra,0xffffd
    80005542:	300080e7          	jalr	768(ra) # 8000283e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005546:	2204b783          	ld	a5,544(s1)
    8000554a:	eb95                	bnez	a5,8000557e <pipeclose+0x64>
    release(&pi->lock);
    8000554c:	8526                	mv	a0,s1
    8000554e:	ffffb097          	auipc	ra,0xffffb
    80005552:	748080e7          	jalr	1864(ra) # 80000c96 <release>
    kfree((char*)pi);
    80005556:	8526                	mv	a0,s1
    80005558:	ffffb097          	auipc	ra,0xffffb
    8000555c:	47e080e7          	jalr	1150(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80005560:	60e2                	ld	ra,24(sp)
    80005562:	6442                	ld	s0,16(sp)
    80005564:	64a2                	ld	s1,8(sp)
    80005566:	6902                	ld	s2,0(sp)
    80005568:	6105                	addi	sp,sp,32
    8000556a:	8082                	ret
    pi->readopen = 0;
    8000556c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005570:	21c48513          	addi	a0,s1,540
    80005574:	ffffd097          	auipc	ra,0xffffd
    80005578:	2ca080e7          	jalr	714(ra) # 8000283e <wakeup>
    8000557c:	b7e9                	j	80005546 <pipeclose+0x2c>
    release(&pi->lock);
    8000557e:	8526                	mv	a0,s1
    80005580:	ffffb097          	auipc	ra,0xffffb
    80005584:	716080e7          	jalr	1814(ra) # 80000c96 <release>
}
    80005588:	bfe1                	j	80005560 <pipeclose+0x46>

000000008000558a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000558a:	711d                	addi	sp,sp,-96
    8000558c:	ec86                	sd	ra,88(sp)
    8000558e:	e8a2                	sd	s0,80(sp)
    80005590:	e4a6                	sd	s1,72(sp)
    80005592:	e0ca                	sd	s2,64(sp)
    80005594:	fc4e                	sd	s3,56(sp)
    80005596:	f852                	sd	s4,48(sp)
    80005598:	f456                	sd	s5,40(sp)
    8000559a:	f05a                	sd	s6,32(sp)
    8000559c:	ec5e                	sd	s7,24(sp)
    8000559e:	e862                	sd	s8,16(sp)
    800055a0:	1080                	addi	s0,sp,96
    800055a2:	84aa                	mv	s1,a0
    800055a4:	8aae                	mv	s5,a1
    800055a6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800055a8:	ffffd097          	auipc	ra,0xffffd
    800055ac:	898080e7          	jalr	-1896(ra) # 80001e40 <myproc>
    800055b0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800055b2:	8526                	mv	a0,s1
    800055b4:	ffffb097          	auipc	ra,0xffffb
    800055b8:	62e080e7          	jalr	1582(ra) # 80000be2 <acquire>
  while(i < n){
    800055bc:	0b405363          	blez	s4,80005662 <pipewrite+0xd8>
  int i = 0;
    800055c0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800055c2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800055c4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800055c8:	21c48b93          	addi	s7,s1,540
    800055cc:	a089                	j	8000560e <pipewrite+0x84>
      release(&pi->lock);
    800055ce:	8526                	mv	a0,s1
    800055d0:	ffffb097          	auipc	ra,0xffffb
    800055d4:	6c6080e7          	jalr	1734(ra) # 80000c96 <release>
      return -1;
    800055d8:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800055da:	854a                	mv	a0,s2
    800055dc:	60e6                	ld	ra,88(sp)
    800055de:	6446                	ld	s0,80(sp)
    800055e0:	64a6                	ld	s1,72(sp)
    800055e2:	6906                	ld	s2,64(sp)
    800055e4:	79e2                	ld	s3,56(sp)
    800055e6:	7a42                	ld	s4,48(sp)
    800055e8:	7aa2                	ld	s5,40(sp)
    800055ea:	7b02                	ld	s6,32(sp)
    800055ec:	6be2                	ld	s7,24(sp)
    800055ee:	6c42                	ld	s8,16(sp)
    800055f0:	6125                	addi	sp,sp,96
    800055f2:	8082                	ret
      wakeup(&pi->nread);
    800055f4:	8562                	mv	a0,s8
    800055f6:	ffffd097          	auipc	ra,0xffffd
    800055fa:	248080e7          	jalr	584(ra) # 8000283e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800055fe:	85a6                	mv	a1,s1
    80005600:	855e                	mv	a0,s7
    80005602:	ffffd097          	auipc	ra,0xffffd
    80005606:	0b0080e7          	jalr	176(ra) # 800026b2 <sleep>
  while(i < n){
    8000560a:	05495d63          	bge	s2,s4,80005664 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    8000560e:	2204a783          	lw	a5,544(s1)
    80005612:	dfd5                	beqz	a5,800055ce <pipewrite+0x44>
    80005614:	0289a783          	lw	a5,40(s3)
    80005618:	fbdd                	bnez	a5,800055ce <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000561a:	2184a783          	lw	a5,536(s1)
    8000561e:	21c4a703          	lw	a4,540(s1)
    80005622:	2007879b          	addiw	a5,a5,512
    80005626:	fcf707e3          	beq	a4,a5,800055f4 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000562a:	4685                	li	a3,1
    8000562c:	01590633          	add	a2,s2,s5
    80005630:	faf40593          	addi	a1,s0,-81
    80005634:	0509b503          	ld	a0,80(s3)
    80005638:	ffffc097          	auipc	ra,0xffffc
    8000563c:	554080e7          	jalr	1364(ra) # 80001b8c <copyin>
    80005640:	03650263          	beq	a0,s6,80005664 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005644:	21c4a783          	lw	a5,540(s1)
    80005648:	0017871b          	addiw	a4,a5,1
    8000564c:	20e4ae23          	sw	a4,540(s1)
    80005650:	1ff7f793          	andi	a5,a5,511
    80005654:	97a6                	add	a5,a5,s1
    80005656:	faf44703          	lbu	a4,-81(s0)
    8000565a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000565e:	2905                	addiw	s2,s2,1
    80005660:	b76d                	j	8000560a <pipewrite+0x80>
  int i = 0;
    80005662:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005664:	21848513          	addi	a0,s1,536
    80005668:	ffffd097          	auipc	ra,0xffffd
    8000566c:	1d6080e7          	jalr	470(ra) # 8000283e <wakeup>
  release(&pi->lock);
    80005670:	8526                	mv	a0,s1
    80005672:	ffffb097          	auipc	ra,0xffffb
    80005676:	624080e7          	jalr	1572(ra) # 80000c96 <release>
  return i;
    8000567a:	b785                	j	800055da <pipewrite+0x50>

000000008000567c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000567c:	715d                	addi	sp,sp,-80
    8000567e:	e486                	sd	ra,72(sp)
    80005680:	e0a2                	sd	s0,64(sp)
    80005682:	fc26                	sd	s1,56(sp)
    80005684:	f84a                	sd	s2,48(sp)
    80005686:	f44e                	sd	s3,40(sp)
    80005688:	f052                	sd	s4,32(sp)
    8000568a:	ec56                	sd	s5,24(sp)
    8000568c:	e85a                	sd	s6,16(sp)
    8000568e:	0880                	addi	s0,sp,80
    80005690:	84aa                	mv	s1,a0
    80005692:	892e                	mv	s2,a1
    80005694:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005696:	ffffc097          	auipc	ra,0xffffc
    8000569a:	7aa080e7          	jalr	1962(ra) # 80001e40 <myproc>
    8000569e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800056a0:	8526                	mv	a0,s1
    800056a2:	ffffb097          	auipc	ra,0xffffb
    800056a6:	540080e7          	jalr	1344(ra) # 80000be2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800056aa:	2184a703          	lw	a4,536(s1)
    800056ae:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800056b2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800056b6:	02f71463          	bne	a4,a5,800056de <piperead+0x62>
    800056ba:	2244a783          	lw	a5,548(s1)
    800056be:	c385                	beqz	a5,800056de <piperead+0x62>
    if(pr->killed){
    800056c0:	028a2783          	lw	a5,40(s4)
    800056c4:	ebc1                	bnez	a5,80005754 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800056c6:	85a6                	mv	a1,s1
    800056c8:	854e                	mv	a0,s3
    800056ca:	ffffd097          	auipc	ra,0xffffd
    800056ce:	fe8080e7          	jalr	-24(ra) # 800026b2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800056d2:	2184a703          	lw	a4,536(s1)
    800056d6:	21c4a783          	lw	a5,540(s1)
    800056da:	fef700e3          	beq	a4,a5,800056ba <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800056de:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800056e0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800056e2:	05505363          	blez	s5,80005728 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    800056e6:	2184a783          	lw	a5,536(s1)
    800056ea:	21c4a703          	lw	a4,540(s1)
    800056ee:	02f70d63          	beq	a4,a5,80005728 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800056f2:	0017871b          	addiw	a4,a5,1
    800056f6:	20e4ac23          	sw	a4,536(s1)
    800056fa:	1ff7f793          	andi	a5,a5,511
    800056fe:	97a6                	add	a5,a5,s1
    80005700:	0187c783          	lbu	a5,24(a5)
    80005704:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005708:	4685                	li	a3,1
    8000570a:	fbf40613          	addi	a2,s0,-65
    8000570e:	85ca                	mv	a1,s2
    80005710:	050a3503          	ld	a0,80(s4)
    80005714:	ffffc097          	auipc	ra,0xffffc
    80005718:	3ec080e7          	jalr	1004(ra) # 80001b00 <copyout>
    8000571c:	01650663          	beq	a0,s6,80005728 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005720:	2985                	addiw	s3,s3,1
    80005722:	0905                	addi	s2,s2,1
    80005724:	fd3a91e3          	bne	s5,s3,800056e6 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005728:	21c48513          	addi	a0,s1,540
    8000572c:	ffffd097          	auipc	ra,0xffffd
    80005730:	112080e7          	jalr	274(ra) # 8000283e <wakeup>
  release(&pi->lock);
    80005734:	8526                	mv	a0,s1
    80005736:	ffffb097          	auipc	ra,0xffffb
    8000573a:	560080e7          	jalr	1376(ra) # 80000c96 <release>
  return i;
}
    8000573e:	854e                	mv	a0,s3
    80005740:	60a6                	ld	ra,72(sp)
    80005742:	6406                	ld	s0,64(sp)
    80005744:	74e2                	ld	s1,56(sp)
    80005746:	7942                	ld	s2,48(sp)
    80005748:	79a2                	ld	s3,40(sp)
    8000574a:	7a02                	ld	s4,32(sp)
    8000574c:	6ae2                	ld	s5,24(sp)
    8000574e:	6b42                	ld	s6,16(sp)
    80005750:	6161                	addi	sp,sp,80
    80005752:	8082                	ret
      release(&pi->lock);
    80005754:	8526                	mv	a0,s1
    80005756:	ffffb097          	auipc	ra,0xffffb
    8000575a:	540080e7          	jalr	1344(ra) # 80000c96 <release>
      return -1;
    8000575e:	59fd                	li	s3,-1
    80005760:	bff9                	j	8000573e <piperead+0xc2>

0000000080005762 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005762:	de010113          	addi	sp,sp,-544
    80005766:	20113c23          	sd	ra,536(sp)
    8000576a:	20813823          	sd	s0,528(sp)
    8000576e:	20913423          	sd	s1,520(sp)
    80005772:	21213023          	sd	s2,512(sp)
    80005776:	ffce                	sd	s3,504(sp)
    80005778:	fbd2                	sd	s4,496(sp)
    8000577a:	f7d6                	sd	s5,488(sp)
    8000577c:	f3da                	sd	s6,480(sp)
    8000577e:	efde                	sd	s7,472(sp)
    80005780:	ebe2                	sd	s8,464(sp)
    80005782:	e7e6                	sd	s9,456(sp)
    80005784:	e3ea                	sd	s10,448(sp)
    80005786:	ff6e                	sd	s11,440(sp)
    80005788:	1400                	addi	s0,sp,544
    8000578a:	dea43c23          	sd	a0,-520(s0)
    8000578e:	deb43423          	sd	a1,-536(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005792:	ffffc097          	auipc	ra,0xffffc
    80005796:	6ae080e7          	jalr	1710(ra) # 80001e40 <myproc>
    8000579a:	84aa                	mv	s1,a0

  begin_op();
    8000579c:	fffff097          	auipc	ra,0xfffff
    800057a0:	2b2080e7          	jalr	690(ra) # 80004a4e <begin_op>

  int selection = SELECTION;

  if (selection == SCFIFO || selection == LAPA || selection == NFUA){
    for (int i = 0; i < MAX_PSYC_PAGES; i++){
    800057a4:	17048793          	addi	a5,s1,368
    800057a8:	27048693          	addi	a3,s1,624
      p->pages_in_ram[i].is_free = 1;
    800057ac:	4705                	li	a4,1
    800057ae:	c798                	sw	a4,8(a5)
      p->pages_in_ram[i].va = 0;
    800057b0:	0007b023          	sd	zero,0(a5)
      
      p->pages_in_file[i].is_free = 1;
    800057b4:	10e7a823          	sw	a4,272(a5)
      p->pages_in_file[i].va = 0;
    800057b8:	1007b423          	sd	zero,264(a5)
    for (int i = 0; i < MAX_PSYC_PAGES; i++){
    800057bc:	07c1                	addi	a5,a5,16
    800057be:	fed798e3          	bne	a5,a3,800057ae <exec+0x4c>
    }
  p->ram_pages_counter = 0;
    800057c2:	2604a823          	sw	zero,624(s1)
  }
  if((ip = namei(path)) == 0){
    800057c6:	df843503          	ld	a0,-520(s0)
    800057ca:	fffff097          	auipc	ra,0xfffff
    800057ce:	d52080e7          	jalr	-686(ra) # 8000451c <namei>
    800057d2:	8aaa                	mv	s5,a0
    800057d4:	c935                	beqz	a0,80005848 <exec+0xe6>
    end_op();
    return -1;
  }
  ilock(ip);
    800057d6:	ffffe097          	auipc	ra,0xffffe
    800057da:	590080e7          	jalr	1424(ra) # 80003d66 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800057de:	04000713          	li	a4,64
    800057e2:	4681                	li	a3,0
    800057e4:	e4840613          	addi	a2,s0,-440
    800057e8:	4581                	li	a1,0
    800057ea:	8556                	mv	a0,s5
    800057ec:	fffff097          	auipc	ra,0xfffff
    800057f0:	82e080e7          	jalr	-2002(ra) # 8000401a <readi>
    800057f4:	04000793          	li	a5,64
    800057f8:	00f51a63          	bne	a0,a5,8000580c <exec+0xaa>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800057fc:	e4842703          	lw	a4,-440(s0)
    80005800:	464c47b7          	lui	a5,0x464c4
    80005804:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005808:	04f70663          	beq	a4,a5,80005854 <exec+0xf2>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000580c:	8556                	mv	a0,s5
    8000580e:	ffffe097          	auipc	ra,0xffffe
    80005812:	7ba080e7          	jalr	1978(ra) # 80003fc8 <iunlockput>
    end_op();
    80005816:	fffff097          	auipc	ra,0xfffff
    8000581a:	2b8080e7          	jalr	696(ra) # 80004ace <end_op>
  }
  return -1;
    8000581e:	557d                	li	a0,-1
}
    80005820:	21813083          	ld	ra,536(sp)
    80005824:	21013403          	ld	s0,528(sp)
    80005828:	20813483          	ld	s1,520(sp)
    8000582c:	20013903          	ld	s2,512(sp)
    80005830:	79fe                	ld	s3,504(sp)
    80005832:	7a5e                	ld	s4,496(sp)
    80005834:	7abe                	ld	s5,488(sp)
    80005836:	7b1e                	ld	s6,480(sp)
    80005838:	6bfe                	ld	s7,472(sp)
    8000583a:	6c5e                	ld	s8,464(sp)
    8000583c:	6cbe                	ld	s9,456(sp)
    8000583e:	6d1e                	ld	s10,448(sp)
    80005840:	7dfa                	ld	s11,440(sp)
    80005842:	22010113          	addi	sp,sp,544
    80005846:	8082                	ret
    end_op();
    80005848:	fffff097          	auipc	ra,0xfffff
    8000584c:	286080e7          	jalr	646(ra) # 80004ace <end_op>
    return -1;
    80005850:	557d                	li	a0,-1
    80005852:	b7f9                	j	80005820 <exec+0xbe>
  if((pagetable = proc_pagetable(p)) == 0)
    80005854:	8526                	mv	a0,s1
    80005856:	ffffc097          	auipc	ra,0xffffc
    8000585a:	6ae080e7          	jalr	1710(ra) # 80001f04 <proc_pagetable>
    8000585e:	8b2a                	mv	s6,a0
    80005860:	d555                	beqz	a0,8000580c <exec+0xaa>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005862:	e6842783          	lw	a5,-408(s0)
    80005866:	e8045703          	lhu	a4,-384(s0)
    8000586a:	c735                	beqz	a4,800058d6 <exec+0x174>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000586c:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000586e:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005872:	6a05                	lui	s4,0x1
    80005874:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005878:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    8000587c:	6d85                	lui	s11,0x1
    8000587e:	7d7d                	lui	s10,0xfffff
    80005880:	ac1d                	j	80005ab6 <exec+0x354>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005882:	00003517          	auipc	a0,0x3
    80005886:	f8650513          	addi	a0,a0,-122 # 80008808 <syscalls+0x2f0>
    8000588a:	ffffb097          	auipc	ra,0xffffb
    8000588e:	ca0080e7          	jalr	-864(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005892:	874e                	mv	a4,s3
    80005894:	009c86bb          	addw	a3,s9,s1
    80005898:	4581                	li	a1,0
    8000589a:	8556                	mv	a0,s5
    8000589c:	ffffe097          	auipc	ra,0xffffe
    800058a0:	77e080e7          	jalr	1918(ra) # 8000401a <readi>
    800058a4:	2501                	sext.w	a0,a0
    800058a6:	1aa99863          	bne	s3,a0,80005a56 <exec+0x2f4>
  for(i = 0; i < sz; i += PGSIZE){
    800058aa:	009d84bb          	addw	s1,s11,s1
    800058ae:	012d093b          	addw	s2,s10,s2
    800058b2:	1f74f263          	bgeu	s1,s7,80005a96 <exec+0x334>
    pa = walkaddr(pagetable, va + i);
    800058b6:	02049593          	slli	a1,s1,0x20
    800058ba:	9181                	srli	a1,a1,0x20
    800058bc:	95e2                	add	a1,a1,s8
    800058be:	855a                	mv	a0,s6
    800058c0:	ffffb097          	auipc	ra,0xffffb
    800058c4:	7ac080e7          	jalr	1964(ra) # 8000106c <walkaddr>
    800058c8:	862a                	mv	a2,a0
    if(pa == 0)
    800058ca:	dd45                	beqz	a0,80005882 <exec+0x120>
      n = PGSIZE;
    800058cc:	89d2                	mv	s3,s4
    if(sz - i < PGSIZE)
    800058ce:	fd4972e3          	bgeu	s2,s4,80005892 <exec+0x130>
      n = sz - i;
    800058d2:	89ca                	mv	s3,s2
    800058d4:	bf7d                	j	80005892 <exec+0x130>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800058d6:	4481                	li	s1,0
  iunlockput(ip);
    800058d8:	8556                	mv	a0,s5
    800058da:	ffffe097          	auipc	ra,0xffffe
    800058de:	6ee080e7          	jalr	1774(ra) # 80003fc8 <iunlockput>
  end_op();
    800058e2:	fffff097          	auipc	ra,0xfffff
    800058e6:	1ec080e7          	jalr	492(ra) # 80004ace <end_op>
  p = myproc();
    800058ea:	ffffc097          	auipc	ra,0xffffc
    800058ee:	556080e7          	jalr	1366(ra) # 80001e40 <myproc>
    800058f2:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800058f4:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800058f8:	6785                	lui	a5,0x1
    800058fa:	17fd                	addi	a5,a5,-1
    800058fc:	94be                	add	s1,s1,a5
    800058fe:	77fd                	lui	a5,0xfffff
    80005900:	8fe5                	and	a5,a5,s1
    80005902:	def43823          	sd	a5,-528(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005906:	6609                	lui	a2,0x2
    80005908:	963e                	add	a2,a2,a5
    8000590a:	85be                	mv	a1,a5
    8000590c:	855a                	mv	a0,s6
    8000590e:	ffffc097          	auipc	ra,0xffffc
    80005912:	f70080e7          	jalr	-144(ra) # 8000187e <uvmalloc>
    80005916:	8c2a                	mv	s8,a0
  ip = 0;
    80005918:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000591a:	12050e63          	beqz	a0,80005a56 <exec+0x2f4>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000591e:	75f9                	lui	a1,0xffffe
    80005920:	95aa                	add	a1,a1,a0
    80005922:	855a                	mv	a0,s6
    80005924:	ffffc097          	auipc	ra,0xffffc
    80005928:	1aa080e7          	jalr	426(ra) # 80001ace <uvmclear>
  stackbase = sp - PGSIZE;
    8000592c:	7afd                	lui	s5,0xfffff
    8000592e:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005930:	de843783          	ld	a5,-536(s0)
    80005934:	6388                	ld	a0,0(a5)
    80005936:	c925                	beqz	a0,800059a6 <exec+0x244>
    80005938:	e8840993          	addi	s3,s0,-376
    8000593c:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005940:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005942:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005944:	ffffb097          	auipc	ra,0xffffb
    80005948:	51e080e7          	jalr	1310(ra) # 80000e62 <strlen>
    8000594c:	0015079b          	addiw	a5,a0,1
    80005950:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005954:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005958:	13596363          	bltu	s2,s5,80005a7e <exec+0x31c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000595c:	de843d83          	ld	s11,-536(s0)
    80005960:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005964:	8552                	mv	a0,s4
    80005966:	ffffb097          	auipc	ra,0xffffb
    8000596a:	4fc080e7          	jalr	1276(ra) # 80000e62 <strlen>
    8000596e:	0015069b          	addiw	a3,a0,1
    80005972:	8652                	mv	a2,s4
    80005974:	85ca                	mv	a1,s2
    80005976:	855a                	mv	a0,s6
    80005978:	ffffc097          	auipc	ra,0xffffc
    8000597c:	188080e7          	jalr	392(ra) # 80001b00 <copyout>
    80005980:	10054363          	bltz	a0,80005a86 <exec+0x324>
    ustack[argc] = sp;
    80005984:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005988:	0485                	addi	s1,s1,1
    8000598a:	008d8793          	addi	a5,s11,8
    8000598e:	def43423          	sd	a5,-536(s0)
    80005992:	008db503          	ld	a0,8(s11)
    80005996:	c911                	beqz	a0,800059aa <exec+0x248>
    if(argc >= MAXARG)
    80005998:	09a1                	addi	s3,s3,8
    8000599a:	fb3c95e3          	bne	s9,s3,80005944 <exec+0x1e2>
  sz = sz1;
    8000599e:	df843823          	sd	s8,-528(s0)
  ip = 0;
    800059a2:	4a81                	li	s5,0
    800059a4:	a84d                	j	80005a56 <exec+0x2f4>
  sp = sz;
    800059a6:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800059a8:	4481                	li	s1,0
  ustack[argc] = 0;
    800059aa:	00349793          	slli	a5,s1,0x3
    800059ae:	f9040713          	addi	a4,s0,-112
    800059b2:	97ba                	add	a5,a5,a4
    800059b4:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd0ef8>
  sp -= (argc+1) * sizeof(uint64);
    800059b8:	00148693          	addi	a3,s1,1
    800059bc:	068e                	slli	a3,a3,0x3
    800059be:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800059c2:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800059c6:	01597663          	bgeu	s2,s5,800059d2 <exec+0x270>
  sz = sz1;
    800059ca:	df843823          	sd	s8,-528(s0)
  ip = 0;
    800059ce:	4a81                	li	s5,0
    800059d0:	a059                	j	80005a56 <exec+0x2f4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800059d2:	e8840613          	addi	a2,s0,-376
    800059d6:	85ca                	mv	a1,s2
    800059d8:	855a                	mv	a0,s6
    800059da:	ffffc097          	auipc	ra,0xffffc
    800059de:	126080e7          	jalr	294(ra) # 80001b00 <copyout>
    800059e2:	0a054663          	bltz	a0,80005a8e <exec+0x32c>
  p->trapframe->a1 = sp;
    800059e6:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    800059ea:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800059ee:	df843783          	ld	a5,-520(s0)
    800059f2:	0007c703          	lbu	a4,0(a5)
    800059f6:	cf11                	beqz	a4,80005a12 <exec+0x2b0>
    800059f8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800059fa:	02f00693          	li	a3,47
    800059fe:	a029                	j	80005a08 <exec+0x2a6>
  for(last=s=path; *s; s++)
    80005a00:	0785                	addi	a5,a5,1
    80005a02:	fff7c703          	lbu	a4,-1(a5)
    80005a06:	c711                	beqz	a4,80005a12 <exec+0x2b0>
    if(*s == '/')
    80005a08:	fed71ce3          	bne	a4,a3,80005a00 <exec+0x29e>
      last = s+1;
    80005a0c:	def43c23          	sd	a5,-520(s0)
    80005a10:	bfc5                	j	80005a00 <exec+0x29e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005a12:	4641                	li	a2,16
    80005a14:	df843583          	ld	a1,-520(s0)
    80005a18:	158b8513          	addi	a0,s7,344
    80005a1c:	ffffb097          	auipc	ra,0xffffb
    80005a20:	414080e7          	jalr	1044(ra) # 80000e30 <safestrcpy>
  oldpagetable = p->pagetable;
    80005a24:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005a28:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005a2c:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005a30:	058bb783          	ld	a5,88(s7)
    80005a34:	e6043703          	ld	a4,-416(s0)
    80005a38:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005a3a:	058bb783          	ld	a5,88(s7)
    80005a3e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005a42:	85ea                	mv	a1,s10
    80005a44:	ffffc097          	auipc	ra,0xffffc
    80005a48:	55c080e7          	jalr	1372(ra) # 80001fa0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005a4c:	0004851b          	sext.w	a0,s1
    80005a50:	bbc1                	j	80005820 <exec+0xbe>
    80005a52:	de943823          	sd	s1,-528(s0)
    proc_freepagetable(pagetable, sz);
    80005a56:	df043583          	ld	a1,-528(s0)
    80005a5a:	855a                	mv	a0,s6
    80005a5c:	ffffc097          	auipc	ra,0xffffc
    80005a60:	544080e7          	jalr	1348(ra) # 80001fa0 <proc_freepagetable>
  if(ip){
    80005a64:	da0a94e3          	bnez	s5,8000580c <exec+0xaa>
  return -1;
    80005a68:	557d                	li	a0,-1
    80005a6a:	bb5d                	j	80005820 <exec+0xbe>
    80005a6c:	de943823          	sd	s1,-528(s0)
    80005a70:	b7dd                	j	80005a56 <exec+0x2f4>
    80005a72:	de943823          	sd	s1,-528(s0)
    80005a76:	b7c5                	j	80005a56 <exec+0x2f4>
    80005a78:	de943823          	sd	s1,-528(s0)
    80005a7c:	bfe9                	j	80005a56 <exec+0x2f4>
  sz = sz1;
    80005a7e:	df843823          	sd	s8,-528(s0)
  ip = 0;
    80005a82:	4a81                	li	s5,0
    80005a84:	bfc9                	j	80005a56 <exec+0x2f4>
  sz = sz1;
    80005a86:	df843823          	sd	s8,-528(s0)
  ip = 0;
    80005a8a:	4a81                	li	s5,0
    80005a8c:	b7e9                	j	80005a56 <exec+0x2f4>
  sz = sz1;
    80005a8e:	df843823          	sd	s8,-528(s0)
  ip = 0;
    80005a92:	4a81                	li	s5,0
    80005a94:	b7c9                	j	80005a56 <exec+0x2f4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005a96:	df043483          	ld	s1,-528(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005a9a:	e0843783          	ld	a5,-504(s0)
    80005a9e:	0017869b          	addiw	a3,a5,1
    80005aa2:	e0d43423          	sd	a3,-504(s0)
    80005aa6:	e0043783          	ld	a5,-512(s0)
    80005aaa:	0387879b          	addiw	a5,a5,56
    80005aae:	e8045703          	lhu	a4,-384(s0)
    80005ab2:	e2e6d3e3          	bge	a3,a4,800058d8 <exec+0x176>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005ab6:	2781                	sext.w	a5,a5
    80005ab8:	e0f43023          	sd	a5,-512(s0)
    80005abc:	03800713          	li	a4,56
    80005ac0:	86be                	mv	a3,a5
    80005ac2:	e1040613          	addi	a2,s0,-496
    80005ac6:	4581                	li	a1,0
    80005ac8:	8556                	mv	a0,s5
    80005aca:	ffffe097          	auipc	ra,0xffffe
    80005ace:	550080e7          	jalr	1360(ra) # 8000401a <readi>
    80005ad2:	03800793          	li	a5,56
    80005ad6:	f6f51ee3          	bne	a0,a5,80005a52 <exec+0x2f0>
    if(ph.type != ELF_PROG_LOAD)
    80005ada:	e1042783          	lw	a5,-496(s0)
    80005ade:	4705                	li	a4,1
    80005ae0:	fae79de3          	bne	a5,a4,80005a9a <exec+0x338>
    if(ph.memsz < ph.filesz)
    80005ae4:	e3843603          	ld	a2,-456(s0)
    80005ae8:	e3043783          	ld	a5,-464(s0)
    80005aec:	f8f660e3          	bltu	a2,a5,80005a6c <exec+0x30a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005af0:	e2043783          	ld	a5,-480(s0)
    80005af4:	963e                	add	a2,a2,a5
    80005af6:	f6f66ee3          	bltu	a2,a5,80005a72 <exec+0x310>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005afa:	85a6                	mv	a1,s1
    80005afc:	855a                	mv	a0,s6
    80005afe:	ffffc097          	auipc	ra,0xffffc
    80005b02:	d80080e7          	jalr	-640(ra) # 8000187e <uvmalloc>
    80005b06:	dea43823          	sd	a0,-528(s0)
    80005b0a:	d53d                	beqz	a0,80005a78 <exec+0x316>
    if(ph.vaddr % PGSIZE != 0)
    80005b0c:	e2043c03          	ld	s8,-480(s0)
    80005b10:	de043783          	ld	a5,-544(s0)
    80005b14:	00fc77b3          	and	a5,s8,a5
    80005b18:	ff9d                	bnez	a5,80005a56 <exec+0x2f4>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005b1a:	e1842c83          	lw	s9,-488(s0)
    80005b1e:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005b22:	f60b8ae3          	beqz	s7,80005a96 <exec+0x334>
    80005b26:	895e                	mv	s2,s7
    80005b28:	4481                	li	s1,0
    80005b2a:	b371                	j	800058b6 <exec+0x154>

0000000080005b2c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005b2c:	7179                	addi	sp,sp,-48
    80005b2e:	f406                	sd	ra,40(sp)
    80005b30:	f022                	sd	s0,32(sp)
    80005b32:	ec26                	sd	s1,24(sp)
    80005b34:	e84a                	sd	s2,16(sp)
    80005b36:	1800                	addi	s0,sp,48
    80005b38:	892e                	mv	s2,a1
    80005b3a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005b3c:	fdc40593          	addi	a1,s0,-36
    80005b40:	ffffd097          	auipc	ra,0xffffd
    80005b44:	6b4080e7          	jalr	1716(ra) # 800031f4 <argint>
    80005b48:	04054063          	bltz	a0,80005b88 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005b4c:	fdc42703          	lw	a4,-36(s0)
    80005b50:	47bd                	li	a5,15
    80005b52:	02e7ed63          	bltu	a5,a4,80005b8c <argfd+0x60>
    80005b56:	ffffc097          	auipc	ra,0xffffc
    80005b5a:	2ea080e7          	jalr	746(ra) # 80001e40 <myproc>
    80005b5e:	fdc42703          	lw	a4,-36(s0)
    80005b62:	01a70793          	addi	a5,a4,26
    80005b66:	078e                	slli	a5,a5,0x3
    80005b68:	953e                	add	a0,a0,a5
    80005b6a:	611c                	ld	a5,0(a0)
    80005b6c:	c395                	beqz	a5,80005b90 <argfd+0x64>
    return -1;
  if(pfd)
    80005b6e:	00090463          	beqz	s2,80005b76 <argfd+0x4a>
    *pfd = fd;
    80005b72:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005b76:	4501                	li	a0,0
  if(pf)
    80005b78:	c091                	beqz	s1,80005b7c <argfd+0x50>
    *pf = f;
    80005b7a:	e09c                	sd	a5,0(s1)
}
    80005b7c:	70a2                	ld	ra,40(sp)
    80005b7e:	7402                	ld	s0,32(sp)
    80005b80:	64e2                	ld	s1,24(sp)
    80005b82:	6942                	ld	s2,16(sp)
    80005b84:	6145                	addi	sp,sp,48
    80005b86:	8082                	ret
    return -1;
    80005b88:	557d                	li	a0,-1
    80005b8a:	bfcd                	j	80005b7c <argfd+0x50>
    return -1;
    80005b8c:	557d                	li	a0,-1
    80005b8e:	b7fd                	j	80005b7c <argfd+0x50>
    80005b90:	557d                	li	a0,-1
    80005b92:	b7ed                	j	80005b7c <argfd+0x50>

0000000080005b94 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005b94:	1101                	addi	sp,sp,-32
    80005b96:	ec06                	sd	ra,24(sp)
    80005b98:	e822                	sd	s0,16(sp)
    80005b9a:	e426                	sd	s1,8(sp)
    80005b9c:	1000                	addi	s0,sp,32
    80005b9e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005ba0:	ffffc097          	auipc	ra,0xffffc
    80005ba4:	2a0080e7          	jalr	672(ra) # 80001e40 <myproc>
    80005ba8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005baa:	0d050793          	addi	a5,a0,208
    80005bae:	4501                	li	a0,0
    80005bb0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005bb2:	6398                	ld	a4,0(a5)
    80005bb4:	cb19                	beqz	a4,80005bca <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005bb6:	2505                	addiw	a0,a0,1
    80005bb8:	07a1                	addi	a5,a5,8
    80005bba:	fed51ce3          	bne	a0,a3,80005bb2 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005bbe:	557d                	li	a0,-1
}
    80005bc0:	60e2                	ld	ra,24(sp)
    80005bc2:	6442                	ld	s0,16(sp)
    80005bc4:	64a2                	ld	s1,8(sp)
    80005bc6:	6105                	addi	sp,sp,32
    80005bc8:	8082                	ret
      p->ofile[fd] = f;
    80005bca:	01a50793          	addi	a5,a0,26
    80005bce:	078e                	slli	a5,a5,0x3
    80005bd0:	963e                	add	a2,a2,a5
    80005bd2:	e204                	sd	s1,0(a2)
      return fd;
    80005bd4:	b7f5                	j	80005bc0 <fdalloc+0x2c>

0000000080005bd6 <sys_dup>:

uint64
sys_dup(void)
{
    80005bd6:	7179                	addi	sp,sp,-48
    80005bd8:	f406                	sd	ra,40(sp)
    80005bda:	f022                	sd	s0,32(sp)
    80005bdc:	ec26                	sd	s1,24(sp)
    80005bde:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    80005be0:	fd840613          	addi	a2,s0,-40
    80005be4:	4581                	li	a1,0
    80005be6:	4501                	li	a0,0
    80005be8:	00000097          	auipc	ra,0x0
    80005bec:	f44080e7          	jalr	-188(ra) # 80005b2c <argfd>
    return -1;
    80005bf0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005bf2:	02054363          	bltz	a0,80005c18 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005bf6:	fd843503          	ld	a0,-40(s0)
    80005bfa:	00000097          	auipc	ra,0x0
    80005bfe:	f9a080e7          	jalr	-102(ra) # 80005b94 <fdalloc>
    80005c02:	84aa                	mv	s1,a0
    return -1;
    80005c04:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005c06:	00054963          	bltz	a0,80005c18 <sys_dup+0x42>
  filedup(f);
    80005c0a:	fd843503          	ld	a0,-40(s0)
    80005c0e:	fffff097          	auipc	ra,0xfffff
    80005c12:	2ba080e7          	jalr	698(ra) # 80004ec8 <filedup>
  return fd;
    80005c16:	87a6                	mv	a5,s1
}
    80005c18:	853e                	mv	a0,a5
    80005c1a:	70a2                	ld	ra,40(sp)
    80005c1c:	7402                	ld	s0,32(sp)
    80005c1e:	64e2                	ld	s1,24(sp)
    80005c20:	6145                	addi	sp,sp,48
    80005c22:	8082                	ret

0000000080005c24 <sys_read>:

uint64
sys_read(void)
{
    80005c24:	7179                	addi	sp,sp,-48
    80005c26:	f406                	sd	ra,40(sp)
    80005c28:	f022                	sd	s0,32(sp)
    80005c2a:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005c2c:	fe840613          	addi	a2,s0,-24
    80005c30:	4581                	li	a1,0
    80005c32:	4501                	li	a0,0
    80005c34:	00000097          	auipc	ra,0x0
    80005c38:	ef8080e7          	jalr	-264(ra) # 80005b2c <argfd>
    return -1;
    80005c3c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005c3e:	04054163          	bltz	a0,80005c80 <sys_read+0x5c>
    80005c42:	fe440593          	addi	a1,s0,-28
    80005c46:	4509                	li	a0,2
    80005c48:	ffffd097          	auipc	ra,0xffffd
    80005c4c:	5ac080e7          	jalr	1452(ra) # 800031f4 <argint>
    return -1;
    80005c50:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005c52:	02054763          	bltz	a0,80005c80 <sys_read+0x5c>
    80005c56:	fd840593          	addi	a1,s0,-40
    80005c5a:	4505                	li	a0,1
    80005c5c:	ffffd097          	auipc	ra,0xffffd
    80005c60:	5ba080e7          	jalr	1466(ra) # 80003216 <argaddr>
    return -1;
    80005c64:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005c66:	00054d63          	bltz	a0,80005c80 <sys_read+0x5c>
  return fileread(f, p, n);
    80005c6a:	fe442603          	lw	a2,-28(s0)
    80005c6e:	fd843583          	ld	a1,-40(s0)
    80005c72:	fe843503          	ld	a0,-24(s0)
    80005c76:	fffff097          	auipc	ra,0xfffff
    80005c7a:	3de080e7          	jalr	990(ra) # 80005054 <fileread>
    80005c7e:	87aa                	mv	a5,a0
}
    80005c80:	853e                	mv	a0,a5
    80005c82:	70a2                	ld	ra,40(sp)
    80005c84:	7402                	ld	s0,32(sp)
    80005c86:	6145                	addi	sp,sp,48
    80005c88:	8082                	ret

0000000080005c8a <sys_write>:

uint64
sys_write(void)
{
    80005c8a:	7179                	addi	sp,sp,-48
    80005c8c:	f406                	sd	ra,40(sp)
    80005c8e:	f022                	sd	s0,32(sp)
    80005c90:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005c92:	fe840613          	addi	a2,s0,-24
    80005c96:	4581                	li	a1,0
    80005c98:	4501                	li	a0,0
    80005c9a:	00000097          	auipc	ra,0x0
    80005c9e:	e92080e7          	jalr	-366(ra) # 80005b2c <argfd>
    return -1;
    80005ca2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ca4:	04054163          	bltz	a0,80005ce6 <sys_write+0x5c>
    80005ca8:	fe440593          	addi	a1,s0,-28
    80005cac:	4509                	li	a0,2
    80005cae:	ffffd097          	auipc	ra,0xffffd
    80005cb2:	546080e7          	jalr	1350(ra) # 800031f4 <argint>
    return -1;
    80005cb6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005cb8:	02054763          	bltz	a0,80005ce6 <sys_write+0x5c>
    80005cbc:	fd840593          	addi	a1,s0,-40
    80005cc0:	4505                	li	a0,1
    80005cc2:	ffffd097          	auipc	ra,0xffffd
    80005cc6:	554080e7          	jalr	1364(ra) # 80003216 <argaddr>
    return -1;
    80005cca:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ccc:	00054d63          	bltz	a0,80005ce6 <sys_write+0x5c>

  return filewrite(f, p, n);
    80005cd0:	fe442603          	lw	a2,-28(s0)
    80005cd4:	fd843583          	ld	a1,-40(s0)
    80005cd8:	fe843503          	ld	a0,-24(s0)
    80005cdc:	fffff097          	auipc	ra,0xfffff
    80005ce0:	43a080e7          	jalr	1082(ra) # 80005116 <filewrite>
    80005ce4:	87aa                	mv	a5,a0
}
    80005ce6:	853e                	mv	a0,a5
    80005ce8:	70a2                	ld	ra,40(sp)
    80005cea:	7402                	ld	s0,32(sp)
    80005cec:	6145                	addi	sp,sp,48
    80005cee:	8082                	ret

0000000080005cf0 <sys_close>:

uint64
sys_close(void)
{
    80005cf0:	1101                	addi	sp,sp,-32
    80005cf2:	ec06                	sd	ra,24(sp)
    80005cf4:	e822                	sd	s0,16(sp)
    80005cf6:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    80005cf8:	fe040613          	addi	a2,s0,-32
    80005cfc:	fec40593          	addi	a1,s0,-20
    80005d00:	4501                	li	a0,0
    80005d02:	00000097          	auipc	ra,0x0
    80005d06:	e2a080e7          	jalr	-470(ra) # 80005b2c <argfd>
    return -1;
    80005d0a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005d0c:	02054463          	bltz	a0,80005d34 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005d10:	ffffc097          	auipc	ra,0xffffc
    80005d14:	130080e7          	jalr	304(ra) # 80001e40 <myproc>
    80005d18:	fec42783          	lw	a5,-20(s0)
    80005d1c:	07e9                	addi	a5,a5,26
    80005d1e:	078e                	slli	a5,a5,0x3
    80005d20:	97aa                	add	a5,a5,a0
    80005d22:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005d26:	fe043503          	ld	a0,-32(s0)
    80005d2a:	fffff097          	auipc	ra,0xfffff
    80005d2e:	1f0080e7          	jalr	496(ra) # 80004f1a <fileclose>
  return 0;
    80005d32:	4781                	li	a5,0
}
    80005d34:	853e                	mv	a0,a5
    80005d36:	60e2                	ld	ra,24(sp)
    80005d38:	6442                	ld	s0,16(sp)
    80005d3a:	6105                	addi	sp,sp,32
    80005d3c:	8082                	ret

0000000080005d3e <sys_fstat>:

uint64
sys_fstat(void)
{
    80005d3e:	1101                	addi	sp,sp,-32
    80005d40:	ec06                	sd	ra,24(sp)
    80005d42:	e822                	sd	s0,16(sp)
    80005d44:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005d46:	fe840613          	addi	a2,s0,-24
    80005d4a:	4581                	li	a1,0
    80005d4c:	4501                	li	a0,0
    80005d4e:	00000097          	auipc	ra,0x0
    80005d52:	dde080e7          	jalr	-546(ra) # 80005b2c <argfd>
    return -1;
    80005d56:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005d58:	02054563          	bltz	a0,80005d82 <sys_fstat+0x44>
    80005d5c:	fe040593          	addi	a1,s0,-32
    80005d60:	4505                	li	a0,1
    80005d62:	ffffd097          	auipc	ra,0xffffd
    80005d66:	4b4080e7          	jalr	1204(ra) # 80003216 <argaddr>
    return -1;
    80005d6a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005d6c:	00054b63          	bltz	a0,80005d82 <sys_fstat+0x44>
  return filestat(f, st);
    80005d70:	fe043583          	ld	a1,-32(s0)
    80005d74:	fe843503          	ld	a0,-24(s0)
    80005d78:	fffff097          	auipc	ra,0xfffff
    80005d7c:	26a080e7          	jalr	618(ra) # 80004fe2 <filestat>
    80005d80:	87aa                	mv	a5,a0
}
    80005d82:	853e                	mv	a0,a5
    80005d84:	60e2                	ld	ra,24(sp)
    80005d86:	6442                	ld	s0,16(sp)
    80005d88:	6105                	addi	sp,sp,32
    80005d8a:	8082                	ret

0000000080005d8c <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    80005d8c:	7169                	addi	sp,sp,-304
    80005d8e:	f606                	sd	ra,296(sp)
    80005d90:	f222                	sd	s0,288(sp)
    80005d92:	ee26                	sd	s1,280(sp)
    80005d94:	ea4a                	sd	s2,272(sp)
    80005d96:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d98:	08000613          	li	a2,128
    80005d9c:	ed040593          	addi	a1,s0,-304
    80005da0:	4501                	li	a0,0
    80005da2:	ffffd097          	auipc	ra,0xffffd
    80005da6:	496080e7          	jalr	1174(ra) # 80003238 <argstr>
    return -1;
    80005daa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005dac:	10054e63          	bltz	a0,80005ec8 <sys_link+0x13c>
    80005db0:	08000613          	li	a2,128
    80005db4:	f5040593          	addi	a1,s0,-176
    80005db8:	4505                	li	a0,1
    80005dba:	ffffd097          	auipc	ra,0xffffd
    80005dbe:	47e080e7          	jalr	1150(ra) # 80003238 <argstr>
    return -1;
    80005dc2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005dc4:	10054263          	bltz	a0,80005ec8 <sys_link+0x13c>

  begin_op();
    80005dc8:	fffff097          	auipc	ra,0xfffff
    80005dcc:	c86080e7          	jalr	-890(ra) # 80004a4e <begin_op>
  if((ip = namei(old)) == 0){
    80005dd0:	ed040513          	addi	a0,s0,-304
    80005dd4:	ffffe097          	auipc	ra,0xffffe
    80005dd8:	748080e7          	jalr	1864(ra) # 8000451c <namei>
    80005ddc:	84aa                	mv	s1,a0
    80005dde:	c551                	beqz	a0,80005e6a <sys_link+0xde>
    end_op();
    return -1;
  }

  ilock(ip);
    80005de0:	ffffe097          	auipc	ra,0xffffe
    80005de4:	f86080e7          	jalr	-122(ra) # 80003d66 <ilock>
  if(ip->type == T_DIR){
    80005de8:	04449703          	lh	a4,68(s1)
    80005dec:	4785                	li	a5,1
    80005dee:	08f70463          	beq	a4,a5,80005e76 <sys_link+0xea>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    80005df2:	04a4d783          	lhu	a5,74(s1)
    80005df6:	2785                	addiw	a5,a5,1
    80005df8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005dfc:	8526                	mv	a0,s1
    80005dfe:	ffffe097          	auipc	ra,0xffffe
    80005e02:	e9e080e7          	jalr	-354(ra) # 80003c9c <iupdate>
  iunlock(ip);
    80005e06:	8526                	mv	a0,s1
    80005e08:	ffffe097          	auipc	ra,0xffffe
    80005e0c:	020080e7          	jalr	32(ra) # 80003e28 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    80005e10:	fd040593          	addi	a1,s0,-48
    80005e14:	f5040513          	addi	a0,s0,-176
    80005e18:	ffffe097          	auipc	ra,0xffffe
    80005e1c:	722080e7          	jalr	1826(ra) # 8000453a <nameiparent>
    80005e20:	892a                	mv	s2,a0
    80005e22:	c935                	beqz	a0,80005e96 <sys_link+0x10a>
    goto bad;
  ilock(dp);
    80005e24:	ffffe097          	auipc	ra,0xffffe
    80005e28:	f42080e7          	jalr	-190(ra) # 80003d66 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005e2c:	00092703          	lw	a4,0(s2)
    80005e30:	409c                	lw	a5,0(s1)
    80005e32:	04f71d63          	bne	a4,a5,80005e8c <sys_link+0x100>
    80005e36:	40d0                	lw	a2,4(s1)
    80005e38:	fd040593          	addi	a1,s0,-48
    80005e3c:	854a                	mv	a0,s2
    80005e3e:	ffffe097          	auipc	ra,0xffffe
    80005e42:	61c080e7          	jalr	1564(ra) # 8000445a <dirlink>
    80005e46:	04054363          	bltz	a0,80005e8c <sys_link+0x100>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    80005e4a:	854a                	mv	a0,s2
    80005e4c:	ffffe097          	auipc	ra,0xffffe
    80005e50:	17c080e7          	jalr	380(ra) # 80003fc8 <iunlockput>
  iput(ip);
    80005e54:	8526                	mv	a0,s1
    80005e56:	ffffe097          	auipc	ra,0xffffe
    80005e5a:	0ca080e7          	jalr	202(ra) # 80003f20 <iput>

  end_op();
    80005e5e:	fffff097          	auipc	ra,0xfffff
    80005e62:	c70080e7          	jalr	-912(ra) # 80004ace <end_op>

  return 0;
    80005e66:	4781                	li	a5,0
    80005e68:	a085                	j	80005ec8 <sys_link+0x13c>
    end_op();
    80005e6a:	fffff097          	auipc	ra,0xfffff
    80005e6e:	c64080e7          	jalr	-924(ra) # 80004ace <end_op>
    return -1;
    80005e72:	57fd                	li	a5,-1
    80005e74:	a891                	j	80005ec8 <sys_link+0x13c>
    iunlockput(ip);
    80005e76:	8526                	mv	a0,s1
    80005e78:	ffffe097          	auipc	ra,0xffffe
    80005e7c:	150080e7          	jalr	336(ra) # 80003fc8 <iunlockput>
    end_op();
    80005e80:	fffff097          	auipc	ra,0xfffff
    80005e84:	c4e080e7          	jalr	-946(ra) # 80004ace <end_op>
    return -1;
    80005e88:	57fd                	li	a5,-1
    80005e8a:	a83d                	j	80005ec8 <sys_link+0x13c>
    iunlockput(dp);
    80005e8c:	854a                	mv	a0,s2
    80005e8e:	ffffe097          	auipc	ra,0xffffe
    80005e92:	13a080e7          	jalr	314(ra) # 80003fc8 <iunlockput>

bad:
  ilock(ip);
    80005e96:	8526                	mv	a0,s1
    80005e98:	ffffe097          	auipc	ra,0xffffe
    80005e9c:	ece080e7          	jalr	-306(ra) # 80003d66 <ilock>
  ip->nlink--;
    80005ea0:	04a4d783          	lhu	a5,74(s1)
    80005ea4:	37fd                	addiw	a5,a5,-1
    80005ea6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005eaa:	8526                	mv	a0,s1
    80005eac:	ffffe097          	auipc	ra,0xffffe
    80005eb0:	df0080e7          	jalr	-528(ra) # 80003c9c <iupdate>
  iunlockput(ip);
    80005eb4:	8526                	mv	a0,s1
    80005eb6:	ffffe097          	auipc	ra,0xffffe
    80005eba:	112080e7          	jalr	274(ra) # 80003fc8 <iunlockput>
  end_op();
    80005ebe:	fffff097          	auipc	ra,0xfffff
    80005ec2:	c10080e7          	jalr	-1008(ra) # 80004ace <end_op>
  return -1;
    80005ec6:	57fd                	li	a5,-1
}
    80005ec8:	853e                	mv	a0,a5
    80005eca:	70b2                	ld	ra,296(sp)
    80005ecc:	7412                	ld	s0,288(sp)
    80005ece:	64f2                	ld	s1,280(sp)
    80005ed0:	6952                	ld	s2,272(sp)
    80005ed2:	6155                	addi	sp,sp,304
    80005ed4:	8082                	ret

0000000080005ed6 <isdirempty>:
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ed6:	4578                	lw	a4,76(a0)
    80005ed8:	02000793          	li	a5,32
    80005edc:	04e7fa63          	bgeu	a5,a4,80005f30 <isdirempty+0x5a>
{
    80005ee0:	7179                	addi	sp,sp,-48
    80005ee2:	f406                	sd	ra,40(sp)
    80005ee4:	f022                	sd	s0,32(sp)
    80005ee6:	ec26                	sd	s1,24(sp)
    80005ee8:	e84a                	sd	s2,16(sp)
    80005eea:	1800                	addi	s0,sp,48
    80005eec:	892a                	mv	s2,a0
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005eee:	02000493          	li	s1,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ef2:	4741                	li	a4,16
    80005ef4:	86a6                	mv	a3,s1
    80005ef6:	fd040613          	addi	a2,s0,-48
    80005efa:	4581                	li	a1,0
    80005efc:	854a                	mv	a0,s2
    80005efe:	ffffe097          	auipc	ra,0xffffe
    80005f02:	11c080e7          	jalr	284(ra) # 8000401a <readi>
    80005f06:	47c1                	li	a5,16
    80005f08:	00f51c63          	bne	a0,a5,80005f20 <isdirempty+0x4a>
      panic("isdirempty: readi");
    if(de.inum != 0)
    80005f0c:	fd045783          	lhu	a5,-48(s0)
    80005f10:	e395                	bnez	a5,80005f34 <isdirempty+0x5e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005f12:	24c1                	addiw	s1,s1,16
    80005f14:	04c92783          	lw	a5,76(s2)
    80005f18:	fcf4ede3          	bltu	s1,a5,80005ef2 <isdirempty+0x1c>
      return 0;
  }
  return 1;
    80005f1c:	4505                	li	a0,1
    80005f1e:	a821                	j	80005f36 <isdirempty+0x60>
      panic("isdirempty: readi");
    80005f20:	00003517          	auipc	a0,0x3
    80005f24:	90850513          	addi	a0,a0,-1784 # 80008828 <syscalls+0x310>
    80005f28:	ffffa097          	auipc	ra,0xffffa
    80005f2c:	602080e7          	jalr	1538(ra) # 8000052a <panic>
  return 1;
    80005f30:	4505                	li	a0,1
}
    80005f32:	8082                	ret
      return 0;
    80005f34:	4501                	li	a0,0
}
    80005f36:	70a2                	ld	ra,40(sp)
    80005f38:	7402                	ld	s0,32(sp)
    80005f3a:	64e2                	ld	s1,24(sp)
    80005f3c:	6942                	ld	s2,16(sp)
    80005f3e:	6145                	addi	sp,sp,48
    80005f40:	8082                	ret

0000000080005f42 <sys_unlink>:

uint64
sys_unlink(void)
{
    80005f42:	7155                	addi	sp,sp,-208
    80005f44:	e586                	sd	ra,200(sp)
    80005f46:	e1a2                	sd	s0,192(sp)
    80005f48:	fd26                	sd	s1,184(sp)
    80005f4a:	f94a                	sd	s2,176(sp)
    80005f4c:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    80005f4e:	08000613          	li	a2,128
    80005f52:	f4040593          	addi	a1,s0,-192
    80005f56:	4501                	li	a0,0
    80005f58:	ffffd097          	auipc	ra,0xffffd
    80005f5c:	2e0080e7          	jalr	736(ra) # 80003238 <argstr>
    80005f60:	16054363          	bltz	a0,800060c6 <sys_unlink+0x184>
    return -1;

  begin_op();
    80005f64:	fffff097          	auipc	ra,0xfffff
    80005f68:	aea080e7          	jalr	-1302(ra) # 80004a4e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005f6c:	fc040593          	addi	a1,s0,-64
    80005f70:	f4040513          	addi	a0,s0,-192
    80005f74:	ffffe097          	auipc	ra,0xffffe
    80005f78:	5c6080e7          	jalr	1478(ra) # 8000453a <nameiparent>
    80005f7c:	84aa                	mv	s1,a0
    80005f7e:	c961                	beqz	a0,8000604e <sys_unlink+0x10c>
    end_op();
    return -1;
  }

  ilock(dp);
    80005f80:	ffffe097          	auipc	ra,0xffffe
    80005f84:	de6080e7          	jalr	-538(ra) # 80003d66 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005f88:	00002597          	auipc	a1,0x2
    80005f8c:	78058593          	addi	a1,a1,1920 # 80008708 <syscalls+0x1f0>
    80005f90:	fc040513          	addi	a0,s0,-64
    80005f94:	ffffe097          	auipc	ra,0xffffe
    80005f98:	29c080e7          	jalr	668(ra) # 80004230 <namecmp>
    80005f9c:	c175                	beqz	a0,80006080 <sys_unlink+0x13e>
    80005f9e:	00002597          	auipc	a1,0x2
    80005fa2:	77258593          	addi	a1,a1,1906 # 80008710 <syscalls+0x1f8>
    80005fa6:	fc040513          	addi	a0,s0,-64
    80005faa:	ffffe097          	auipc	ra,0xffffe
    80005fae:	286080e7          	jalr	646(ra) # 80004230 <namecmp>
    80005fb2:	c579                	beqz	a0,80006080 <sys_unlink+0x13e>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    80005fb4:	f3c40613          	addi	a2,s0,-196
    80005fb8:	fc040593          	addi	a1,s0,-64
    80005fbc:	8526                	mv	a0,s1
    80005fbe:	ffffe097          	auipc	ra,0xffffe
    80005fc2:	28c080e7          	jalr	652(ra) # 8000424a <dirlookup>
    80005fc6:	892a                	mv	s2,a0
    80005fc8:	cd45                	beqz	a0,80006080 <sys_unlink+0x13e>
    goto bad;
  ilock(ip);
    80005fca:	ffffe097          	auipc	ra,0xffffe
    80005fce:	d9c080e7          	jalr	-612(ra) # 80003d66 <ilock>

  if(ip->nlink < 1)
    80005fd2:	04a91783          	lh	a5,74(s2)
    80005fd6:	08f05263          	blez	a5,8000605a <sys_unlink+0x118>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005fda:	04491703          	lh	a4,68(s2)
    80005fde:	4785                	li	a5,1
    80005fe0:	08f70563          	beq	a4,a5,8000606a <sys_unlink+0x128>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    80005fe4:	4641                	li	a2,16
    80005fe6:	4581                	li	a1,0
    80005fe8:	fd040513          	addi	a0,s0,-48
    80005fec:	ffffb097          	auipc	ra,0xffffb
    80005ff0:	cf2080e7          	jalr	-782(ra) # 80000cde <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ff4:	4741                	li	a4,16
    80005ff6:	f3c42683          	lw	a3,-196(s0)
    80005ffa:	fd040613          	addi	a2,s0,-48
    80005ffe:	4581                	li	a1,0
    80006000:	8526                	mv	a0,s1
    80006002:	ffffe097          	auipc	ra,0xffffe
    80006006:	110080e7          	jalr	272(ra) # 80004112 <writei>
    8000600a:	47c1                	li	a5,16
    8000600c:	08f51a63          	bne	a0,a5,800060a0 <sys_unlink+0x15e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    80006010:	04491703          	lh	a4,68(s2)
    80006014:	4785                	li	a5,1
    80006016:	08f70d63          	beq	a4,a5,800060b0 <sys_unlink+0x16e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    8000601a:	8526                	mv	a0,s1
    8000601c:	ffffe097          	auipc	ra,0xffffe
    80006020:	fac080e7          	jalr	-84(ra) # 80003fc8 <iunlockput>

  ip->nlink--;
    80006024:	04a95783          	lhu	a5,74(s2)
    80006028:	37fd                	addiw	a5,a5,-1
    8000602a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000602e:	854a                	mv	a0,s2
    80006030:	ffffe097          	auipc	ra,0xffffe
    80006034:	c6c080e7          	jalr	-916(ra) # 80003c9c <iupdate>
  iunlockput(ip);
    80006038:	854a                	mv	a0,s2
    8000603a:	ffffe097          	auipc	ra,0xffffe
    8000603e:	f8e080e7          	jalr	-114(ra) # 80003fc8 <iunlockput>

  end_op();
    80006042:	fffff097          	auipc	ra,0xfffff
    80006046:	a8c080e7          	jalr	-1396(ra) # 80004ace <end_op>

  return 0;
    8000604a:	4501                	li	a0,0
    8000604c:	a0a1                	j	80006094 <sys_unlink+0x152>
    end_op();
    8000604e:	fffff097          	auipc	ra,0xfffff
    80006052:	a80080e7          	jalr	-1408(ra) # 80004ace <end_op>
    return -1;
    80006056:	557d                	li	a0,-1
    80006058:	a835                	j	80006094 <sys_unlink+0x152>
    panic("unlink: nlink < 1");
    8000605a:	00002517          	auipc	a0,0x2
    8000605e:	6be50513          	addi	a0,a0,1726 # 80008718 <syscalls+0x200>
    80006062:	ffffa097          	auipc	ra,0xffffa
    80006066:	4c8080e7          	jalr	1224(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000606a:	854a                	mv	a0,s2
    8000606c:	00000097          	auipc	ra,0x0
    80006070:	e6a080e7          	jalr	-406(ra) # 80005ed6 <isdirempty>
    80006074:	f925                	bnez	a0,80005fe4 <sys_unlink+0xa2>
    iunlockput(ip);
    80006076:	854a                	mv	a0,s2
    80006078:	ffffe097          	auipc	ra,0xffffe
    8000607c:	f50080e7          	jalr	-176(ra) # 80003fc8 <iunlockput>

bad:
  iunlockput(dp);
    80006080:	8526                	mv	a0,s1
    80006082:	ffffe097          	auipc	ra,0xffffe
    80006086:	f46080e7          	jalr	-186(ra) # 80003fc8 <iunlockput>
  end_op();
    8000608a:	fffff097          	auipc	ra,0xfffff
    8000608e:	a44080e7          	jalr	-1468(ra) # 80004ace <end_op>
  return -1;
    80006092:	557d                	li	a0,-1
}
    80006094:	60ae                	ld	ra,200(sp)
    80006096:	640e                	ld	s0,192(sp)
    80006098:	74ea                	ld	s1,184(sp)
    8000609a:	794a                	ld	s2,176(sp)
    8000609c:	6169                	addi	sp,sp,208
    8000609e:	8082                	ret
    panic("unlink: writei");
    800060a0:	00002517          	auipc	a0,0x2
    800060a4:	69050513          	addi	a0,a0,1680 # 80008730 <syscalls+0x218>
    800060a8:	ffffa097          	auipc	ra,0xffffa
    800060ac:	482080e7          	jalr	1154(ra) # 8000052a <panic>
    dp->nlink--;
    800060b0:	04a4d783          	lhu	a5,74(s1)
    800060b4:	37fd                	addiw	a5,a5,-1
    800060b6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800060ba:	8526                	mv	a0,s1
    800060bc:	ffffe097          	auipc	ra,0xffffe
    800060c0:	be0080e7          	jalr	-1056(ra) # 80003c9c <iupdate>
    800060c4:	bf99                	j	8000601a <sys_unlink+0xd8>
    return -1;
    800060c6:	557d                	li	a0,-1
    800060c8:	b7f1                	j	80006094 <sys_unlink+0x152>

00000000800060ca <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    800060ca:	715d                	addi	sp,sp,-80
    800060cc:	e486                	sd	ra,72(sp)
    800060ce:	e0a2                	sd	s0,64(sp)
    800060d0:	fc26                	sd	s1,56(sp)
    800060d2:	f84a                	sd	s2,48(sp)
    800060d4:	f44e                	sd	s3,40(sp)
    800060d6:	f052                	sd	s4,32(sp)
    800060d8:	ec56                	sd	s5,24(sp)
    800060da:	0880                	addi	s0,sp,80
    800060dc:	89ae                	mv	s3,a1
    800060de:	8ab2                	mv	s5,a2
    800060e0:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800060e2:	fb040593          	addi	a1,s0,-80
    800060e6:	ffffe097          	auipc	ra,0xffffe
    800060ea:	454080e7          	jalr	1108(ra) # 8000453a <nameiparent>
    800060ee:	892a                	mv	s2,a0
    800060f0:	12050e63          	beqz	a0,8000622c <create+0x162>
    return 0;

  ilock(dp);
    800060f4:	ffffe097          	auipc	ra,0xffffe
    800060f8:	c72080e7          	jalr	-910(ra) # 80003d66 <ilock>
  
  if((ip = dirlookup(dp, name, 0)) != 0){
    800060fc:	4601                	li	a2,0
    800060fe:	fb040593          	addi	a1,s0,-80
    80006102:	854a                	mv	a0,s2
    80006104:	ffffe097          	auipc	ra,0xffffe
    80006108:	146080e7          	jalr	326(ra) # 8000424a <dirlookup>
    8000610c:	84aa                	mv	s1,a0
    8000610e:	c921                	beqz	a0,8000615e <create+0x94>
    iunlockput(dp);
    80006110:	854a                	mv	a0,s2
    80006112:	ffffe097          	auipc	ra,0xffffe
    80006116:	eb6080e7          	jalr	-330(ra) # 80003fc8 <iunlockput>
    ilock(ip);
    8000611a:	8526                	mv	a0,s1
    8000611c:	ffffe097          	auipc	ra,0xffffe
    80006120:	c4a080e7          	jalr	-950(ra) # 80003d66 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006124:	2981                	sext.w	s3,s3
    80006126:	4789                	li	a5,2
    80006128:	02f99463          	bne	s3,a5,80006150 <create+0x86>
    8000612c:	0444d783          	lhu	a5,68(s1)
    80006130:	37f9                	addiw	a5,a5,-2
    80006132:	17c2                	slli	a5,a5,0x30
    80006134:	93c1                	srli	a5,a5,0x30
    80006136:	4705                	li	a4,1
    80006138:	00f76c63          	bltu	a4,a5,80006150 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000613c:	8526                	mv	a0,s1
    8000613e:	60a6                	ld	ra,72(sp)
    80006140:	6406                	ld	s0,64(sp)
    80006142:	74e2                	ld	s1,56(sp)
    80006144:	7942                	ld	s2,48(sp)
    80006146:	79a2                	ld	s3,40(sp)
    80006148:	7a02                	ld	s4,32(sp)
    8000614a:	6ae2                	ld	s5,24(sp)
    8000614c:	6161                	addi	sp,sp,80
    8000614e:	8082                	ret
    iunlockput(ip);
    80006150:	8526                	mv	a0,s1
    80006152:	ffffe097          	auipc	ra,0xffffe
    80006156:	e76080e7          	jalr	-394(ra) # 80003fc8 <iunlockput>
    return 0;
    8000615a:	4481                	li	s1,0
    8000615c:	b7c5                	j	8000613c <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000615e:	85ce                	mv	a1,s3
    80006160:	00092503          	lw	a0,0(s2)
    80006164:	ffffe097          	auipc	ra,0xffffe
    80006168:	a6a080e7          	jalr	-1430(ra) # 80003bce <ialloc>
    8000616c:	84aa                	mv	s1,a0
    8000616e:	c521                	beqz	a0,800061b6 <create+0xec>
  ilock(ip);
    80006170:	ffffe097          	auipc	ra,0xffffe
    80006174:	bf6080e7          	jalr	-1034(ra) # 80003d66 <ilock>
  ip->major = major;
    80006178:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000617c:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80006180:	4a05                	li	s4,1
    80006182:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80006186:	8526                	mv	a0,s1
    80006188:	ffffe097          	auipc	ra,0xffffe
    8000618c:	b14080e7          	jalr	-1260(ra) # 80003c9c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80006190:	2981                	sext.w	s3,s3
    80006192:	03498a63          	beq	s3,s4,800061c6 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80006196:	40d0                	lw	a2,4(s1)
    80006198:	fb040593          	addi	a1,s0,-80
    8000619c:	854a                	mv	a0,s2
    8000619e:	ffffe097          	auipc	ra,0xffffe
    800061a2:	2bc080e7          	jalr	700(ra) # 8000445a <dirlink>
    800061a6:	06054b63          	bltz	a0,8000621c <create+0x152>
  iunlockput(dp);
    800061aa:	854a                	mv	a0,s2
    800061ac:	ffffe097          	auipc	ra,0xffffe
    800061b0:	e1c080e7          	jalr	-484(ra) # 80003fc8 <iunlockput>
  return ip;
    800061b4:	b761                	j	8000613c <create+0x72>
    panic("create: ialloc");
    800061b6:	00002517          	auipc	a0,0x2
    800061ba:	68a50513          	addi	a0,a0,1674 # 80008840 <syscalls+0x328>
    800061be:	ffffa097          	auipc	ra,0xffffa
    800061c2:	36c080e7          	jalr	876(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    800061c6:	04a95783          	lhu	a5,74(s2)
    800061ca:	2785                	addiw	a5,a5,1
    800061cc:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800061d0:	854a                	mv	a0,s2
    800061d2:	ffffe097          	auipc	ra,0xffffe
    800061d6:	aca080e7          	jalr	-1334(ra) # 80003c9c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800061da:	40d0                	lw	a2,4(s1)
    800061dc:	00002597          	auipc	a1,0x2
    800061e0:	52c58593          	addi	a1,a1,1324 # 80008708 <syscalls+0x1f0>
    800061e4:	8526                	mv	a0,s1
    800061e6:	ffffe097          	auipc	ra,0xffffe
    800061ea:	274080e7          	jalr	628(ra) # 8000445a <dirlink>
    800061ee:	00054f63          	bltz	a0,8000620c <create+0x142>
    800061f2:	00492603          	lw	a2,4(s2)
    800061f6:	00002597          	auipc	a1,0x2
    800061fa:	51a58593          	addi	a1,a1,1306 # 80008710 <syscalls+0x1f8>
    800061fe:	8526                	mv	a0,s1
    80006200:	ffffe097          	auipc	ra,0xffffe
    80006204:	25a080e7          	jalr	602(ra) # 8000445a <dirlink>
    80006208:	f80557e3          	bgez	a0,80006196 <create+0xcc>
      panic("create dots");
    8000620c:	00002517          	auipc	a0,0x2
    80006210:	64450513          	addi	a0,a0,1604 # 80008850 <syscalls+0x338>
    80006214:	ffffa097          	auipc	ra,0xffffa
    80006218:	316080e7          	jalr	790(ra) # 8000052a <panic>
    panic("create: dirlink");
    8000621c:	00002517          	auipc	a0,0x2
    80006220:	64450513          	addi	a0,a0,1604 # 80008860 <syscalls+0x348>
    80006224:	ffffa097          	auipc	ra,0xffffa
    80006228:	306080e7          	jalr	774(ra) # 8000052a <panic>
    return 0;
    8000622c:	84aa                	mv	s1,a0
    8000622e:	b739                	j	8000613c <create+0x72>

0000000080006230 <sys_open>:

uint64
sys_open(void)
{
    80006230:	7131                	addi	sp,sp,-192
    80006232:	fd06                	sd	ra,184(sp)
    80006234:	f922                	sd	s0,176(sp)
    80006236:	f526                	sd	s1,168(sp)
    80006238:	f14a                	sd	s2,160(sp)
    8000623a:	ed4e                	sd	s3,152(sp)
    8000623c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000623e:	08000613          	li	a2,128
    80006242:	f5040593          	addi	a1,s0,-176
    80006246:	4501                	li	a0,0
    80006248:	ffffd097          	auipc	ra,0xffffd
    8000624c:	ff0080e7          	jalr	-16(ra) # 80003238 <argstr>
    return -1;
    80006250:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006252:	0c054163          	bltz	a0,80006314 <sys_open+0xe4>
    80006256:	f4c40593          	addi	a1,s0,-180
    8000625a:	4505                	li	a0,1
    8000625c:	ffffd097          	auipc	ra,0xffffd
    80006260:	f98080e7          	jalr	-104(ra) # 800031f4 <argint>
    80006264:	0a054863          	bltz	a0,80006314 <sys_open+0xe4>

  begin_op();
    80006268:	ffffe097          	auipc	ra,0xffffe
    8000626c:	7e6080e7          	jalr	2022(ra) # 80004a4e <begin_op>

  if(omode & O_CREATE){
    80006270:	f4c42783          	lw	a5,-180(s0)
    80006274:	2007f793          	andi	a5,a5,512
    80006278:	cbdd                	beqz	a5,8000632e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000627a:	4681                	li	a3,0
    8000627c:	4601                	li	a2,0
    8000627e:	4589                	li	a1,2
    80006280:	f5040513          	addi	a0,s0,-176
    80006284:	00000097          	auipc	ra,0x0
    80006288:	e46080e7          	jalr	-442(ra) # 800060ca <create>
    8000628c:	892a                	mv	s2,a0
    if(ip == 0){
    8000628e:	c959                	beqz	a0,80006324 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006290:	04491703          	lh	a4,68(s2)
    80006294:	478d                	li	a5,3
    80006296:	00f71763          	bne	a4,a5,800062a4 <sys_open+0x74>
    8000629a:	04695703          	lhu	a4,70(s2)
    8000629e:	47a5                	li	a5,9
    800062a0:	0ce7ec63          	bltu	a5,a4,80006378 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800062a4:	fffff097          	auipc	ra,0xfffff
    800062a8:	bba080e7          	jalr	-1094(ra) # 80004e5e <filealloc>
    800062ac:	89aa                	mv	s3,a0
    800062ae:	10050263          	beqz	a0,800063b2 <sys_open+0x182>
    800062b2:	00000097          	auipc	ra,0x0
    800062b6:	8e2080e7          	jalr	-1822(ra) # 80005b94 <fdalloc>
    800062ba:	84aa                	mv	s1,a0
    800062bc:	0e054663          	bltz	a0,800063a8 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800062c0:	04491703          	lh	a4,68(s2)
    800062c4:	478d                	li	a5,3
    800062c6:	0cf70463          	beq	a4,a5,8000638e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800062ca:	4789                	li	a5,2
    800062cc:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800062d0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800062d4:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800062d8:	f4c42783          	lw	a5,-180(s0)
    800062dc:	0017c713          	xori	a4,a5,1
    800062e0:	8b05                	andi	a4,a4,1
    800062e2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800062e6:	0037f713          	andi	a4,a5,3
    800062ea:	00e03733          	snez	a4,a4
    800062ee:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800062f2:	4007f793          	andi	a5,a5,1024
    800062f6:	c791                	beqz	a5,80006302 <sys_open+0xd2>
    800062f8:	04491703          	lh	a4,68(s2)
    800062fc:	4789                	li	a5,2
    800062fe:	08f70f63          	beq	a4,a5,8000639c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006302:	854a                	mv	a0,s2
    80006304:	ffffe097          	auipc	ra,0xffffe
    80006308:	b24080e7          	jalr	-1244(ra) # 80003e28 <iunlock>
  end_op();
    8000630c:	ffffe097          	auipc	ra,0xffffe
    80006310:	7c2080e7          	jalr	1986(ra) # 80004ace <end_op>

  return fd;
}
    80006314:	8526                	mv	a0,s1
    80006316:	70ea                	ld	ra,184(sp)
    80006318:	744a                	ld	s0,176(sp)
    8000631a:	74aa                	ld	s1,168(sp)
    8000631c:	790a                	ld	s2,160(sp)
    8000631e:	69ea                	ld	s3,152(sp)
    80006320:	6129                	addi	sp,sp,192
    80006322:	8082                	ret
      end_op();
    80006324:	ffffe097          	auipc	ra,0xffffe
    80006328:	7aa080e7          	jalr	1962(ra) # 80004ace <end_op>
      return -1;
    8000632c:	b7e5                	j	80006314 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000632e:	f5040513          	addi	a0,s0,-176
    80006332:	ffffe097          	auipc	ra,0xffffe
    80006336:	1ea080e7          	jalr	490(ra) # 8000451c <namei>
    8000633a:	892a                	mv	s2,a0
    8000633c:	c905                	beqz	a0,8000636c <sys_open+0x13c>
    ilock(ip);
    8000633e:	ffffe097          	auipc	ra,0xffffe
    80006342:	a28080e7          	jalr	-1496(ra) # 80003d66 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006346:	04491703          	lh	a4,68(s2)
    8000634a:	4785                	li	a5,1
    8000634c:	f4f712e3          	bne	a4,a5,80006290 <sys_open+0x60>
    80006350:	f4c42783          	lw	a5,-180(s0)
    80006354:	dba1                	beqz	a5,800062a4 <sys_open+0x74>
      iunlockput(ip);
    80006356:	854a                	mv	a0,s2
    80006358:	ffffe097          	auipc	ra,0xffffe
    8000635c:	c70080e7          	jalr	-912(ra) # 80003fc8 <iunlockput>
      end_op();
    80006360:	ffffe097          	auipc	ra,0xffffe
    80006364:	76e080e7          	jalr	1902(ra) # 80004ace <end_op>
      return -1;
    80006368:	54fd                	li	s1,-1
    8000636a:	b76d                	j	80006314 <sys_open+0xe4>
      end_op();
    8000636c:	ffffe097          	auipc	ra,0xffffe
    80006370:	762080e7          	jalr	1890(ra) # 80004ace <end_op>
      return -1;
    80006374:	54fd                	li	s1,-1
    80006376:	bf79                	j	80006314 <sys_open+0xe4>
    iunlockput(ip);
    80006378:	854a                	mv	a0,s2
    8000637a:	ffffe097          	auipc	ra,0xffffe
    8000637e:	c4e080e7          	jalr	-946(ra) # 80003fc8 <iunlockput>
    end_op();
    80006382:	ffffe097          	auipc	ra,0xffffe
    80006386:	74c080e7          	jalr	1868(ra) # 80004ace <end_op>
    return -1;
    8000638a:	54fd                	li	s1,-1
    8000638c:	b761                	j	80006314 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000638e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006392:	04691783          	lh	a5,70(s2)
    80006396:	02f99223          	sh	a5,36(s3)
    8000639a:	bf2d                	j	800062d4 <sys_open+0xa4>
    itrunc(ip);
    8000639c:	854a                	mv	a0,s2
    8000639e:	ffffe097          	auipc	ra,0xffffe
    800063a2:	ad6080e7          	jalr	-1322(ra) # 80003e74 <itrunc>
    800063a6:	bfb1                	j	80006302 <sys_open+0xd2>
      fileclose(f);
    800063a8:	854e                	mv	a0,s3
    800063aa:	fffff097          	auipc	ra,0xfffff
    800063ae:	b70080e7          	jalr	-1168(ra) # 80004f1a <fileclose>
    iunlockput(ip);
    800063b2:	854a                	mv	a0,s2
    800063b4:	ffffe097          	auipc	ra,0xffffe
    800063b8:	c14080e7          	jalr	-1004(ra) # 80003fc8 <iunlockput>
    end_op();
    800063bc:	ffffe097          	auipc	ra,0xffffe
    800063c0:	712080e7          	jalr	1810(ra) # 80004ace <end_op>
    return -1;
    800063c4:	54fd                	li	s1,-1
    800063c6:	b7b9                	j	80006314 <sys_open+0xe4>

00000000800063c8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800063c8:	7175                	addi	sp,sp,-144
    800063ca:	e506                	sd	ra,136(sp)
    800063cc:	e122                	sd	s0,128(sp)
    800063ce:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800063d0:	ffffe097          	auipc	ra,0xffffe
    800063d4:	67e080e7          	jalr	1662(ra) # 80004a4e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800063d8:	08000613          	li	a2,128
    800063dc:	f7040593          	addi	a1,s0,-144
    800063e0:	4501                	li	a0,0
    800063e2:	ffffd097          	auipc	ra,0xffffd
    800063e6:	e56080e7          	jalr	-426(ra) # 80003238 <argstr>
    800063ea:	02054963          	bltz	a0,8000641c <sys_mkdir+0x54>
    800063ee:	4681                	li	a3,0
    800063f0:	4601                	li	a2,0
    800063f2:	4585                	li	a1,1
    800063f4:	f7040513          	addi	a0,s0,-144
    800063f8:	00000097          	auipc	ra,0x0
    800063fc:	cd2080e7          	jalr	-814(ra) # 800060ca <create>
    80006400:	cd11                	beqz	a0,8000641c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006402:	ffffe097          	auipc	ra,0xffffe
    80006406:	bc6080e7          	jalr	-1082(ra) # 80003fc8 <iunlockput>
  end_op();
    8000640a:	ffffe097          	auipc	ra,0xffffe
    8000640e:	6c4080e7          	jalr	1732(ra) # 80004ace <end_op>
  return 0;
    80006412:	4501                	li	a0,0
}
    80006414:	60aa                	ld	ra,136(sp)
    80006416:	640a                	ld	s0,128(sp)
    80006418:	6149                	addi	sp,sp,144
    8000641a:	8082                	ret
    end_op();
    8000641c:	ffffe097          	auipc	ra,0xffffe
    80006420:	6b2080e7          	jalr	1714(ra) # 80004ace <end_op>
    return -1;
    80006424:	557d                	li	a0,-1
    80006426:	b7fd                	j	80006414 <sys_mkdir+0x4c>

0000000080006428 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006428:	7135                	addi	sp,sp,-160
    8000642a:	ed06                	sd	ra,152(sp)
    8000642c:	e922                	sd	s0,144(sp)
    8000642e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006430:	ffffe097          	auipc	ra,0xffffe
    80006434:	61e080e7          	jalr	1566(ra) # 80004a4e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006438:	08000613          	li	a2,128
    8000643c:	f7040593          	addi	a1,s0,-144
    80006440:	4501                	li	a0,0
    80006442:	ffffd097          	auipc	ra,0xffffd
    80006446:	df6080e7          	jalr	-522(ra) # 80003238 <argstr>
    8000644a:	04054a63          	bltz	a0,8000649e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000644e:	f6c40593          	addi	a1,s0,-148
    80006452:	4505                	li	a0,1
    80006454:	ffffd097          	auipc	ra,0xffffd
    80006458:	da0080e7          	jalr	-608(ra) # 800031f4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000645c:	04054163          	bltz	a0,8000649e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80006460:	f6840593          	addi	a1,s0,-152
    80006464:	4509                	li	a0,2
    80006466:	ffffd097          	auipc	ra,0xffffd
    8000646a:	d8e080e7          	jalr	-626(ra) # 800031f4 <argint>
     argint(1, &major) < 0 ||
    8000646e:	02054863          	bltz	a0,8000649e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006472:	f6841683          	lh	a3,-152(s0)
    80006476:	f6c41603          	lh	a2,-148(s0)
    8000647a:	458d                	li	a1,3
    8000647c:	f7040513          	addi	a0,s0,-144
    80006480:	00000097          	auipc	ra,0x0
    80006484:	c4a080e7          	jalr	-950(ra) # 800060ca <create>
     argint(2, &minor) < 0 ||
    80006488:	c919                	beqz	a0,8000649e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000648a:	ffffe097          	auipc	ra,0xffffe
    8000648e:	b3e080e7          	jalr	-1218(ra) # 80003fc8 <iunlockput>
  end_op();
    80006492:	ffffe097          	auipc	ra,0xffffe
    80006496:	63c080e7          	jalr	1596(ra) # 80004ace <end_op>
  return 0;
    8000649a:	4501                	li	a0,0
    8000649c:	a031                	j	800064a8 <sys_mknod+0x80>
    end_op();
    8000649e:	ffffe097          	auipc	ra,0xffffe
    800064a2:	630080e7          	jalr	1584(ra) # 80004ace <end_op>
    return -1;
    800064a6:	557d                	li	a0,-1
}
    800064a8:	60ea                	ld	ra,152(sp)
    800064aa:	644a                	ld	s0,144(sp)
    800064ac:	610d                	addi	sp,sp,160
    800064ae:	8082                	ret

00000000800064b0 <sys_chdir>:

uint64
sys_chdir(void)
{
    800064b0:	7135                	addi	sp,sp,-160
    800064b2:	ed06                	sd	ra,152(sp)
    800064b4:	e922                	sd	s0,144(sp)
    800064b6:	e526                	sd	s1,136(sp)
    800064b8:	e14a                	sd	s2,128(sp)
    800064ba:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800064bc:	ffffc097          	auipc	ra,0xffffc
    800064c0:	984080e7          	jalr	-1660(ra) # 80001e40 <myproc>
    800064c4:	892a                	mv	s2,a0
  
  begin_op();
    800064c6:	ffffe097          	auipc	ra,0xffffe
    800064ca:	588080e7          	jalr	1416(ra) # 80004a4e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800064ce:	08000613          	li	a2,128
    800064d2:	f6040593          	addi	a1,s0,-160
    800064d6:	4501                	li	a0,0
    800064d8:	ffffd097          	auipc	ra,0xffffd
    800064dc:	d60080e7          	jalr	-672(ra) # 80003238 <argstr>
    800064e0:	04054b63          	bltz	a0,80006536 <sys_chdir+0x86>
    800064e4:	f6040513          	addi	a0,s0,-160
    800064e8:	ffffe097          	auipc	ra,0xffffe
    800064ec:	034080e7          	jalr	52(ra) # 8000451c <namei>
    800064f0:	84aa                	mv	s1,a0
    800064f2:	c131                	beqz	a0,80006536 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800064f4:	ffffe097          	auipc	ra,0xffffe
    800064f8:	872080e7          	jalr	-1934(ra) # 80003d66 <ilock>
  if(ip->type != T_DIR){
    800064fc:	04449703          	lh	a4,68(s1)
    80006500:	4785                	li	a5,1
    80006502:	04f71063          	bne	a4,a5,80006542 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006506:	8526                	mv	a0,s1
    80006508:	ffffe097          	auipc	ra,0xffffe
    8000650c:	920080e7          	jalr	-1760(ra) # 80003e28 <iunlock>
  iput(p->cwd);
    80006510:	15093503          	ld	a0,336(s2)
    80006514:	ffffe097          	auipc	ra,0xffffe
    80006518:	a0c080e7          	jalr	-1524(ra) # 80003f20 <iput>
  end_op();
    8000651c:	ffffe097          	auipc	ra,0xffffe
    80006520:	5b2080e7          	jalr	1458(ra) # 80004ace <end_op>
  p->cwd = ip;
    80006524:	14993823          	sd	s1,336(s2)
  return 0;
    80006528:	4501                	li	a0,0
}
    8000652a:	60ea                	ld	ra,152(sp)
    8000652c:	644a                	ld	s0,144(sp)
    8000652e:	64aa                	ld	s1,136(sp)
    80006530:	690a                	ld	s2,128(sp)
    80006532:	610d                	addi	sp,sp,160
    80006534:	8082                	ret
    end_op();
    80006536:	ffffe097          	auipc	ra,0xffffe
    8000653a:	598080e7          	jalr	1432(ra) # 80004ace <end_op>
    return -1;
    8000653e:	557d                	li	a0,-1
    80006540:	b7ed                	j	8000652a <sys_chdir+0x7a>
    iunlockput(ip);
    80006542:	8526                	mv	a0,s1
    80006544:	ffffe097          	auipc	ra,0xffffe
    80006548:	a84080e7          	jalr	-1404(ra) # 80003fc8 <iunlockput>
    end_op();
    8000654c:	ffffe097          	auipc	ra,0xffffe
    80006550:	582080e7          	jalr	1410(ra) # 80004ace <end_op>
    return -1;
    80006554:	557d                	li	a0,-1
    80006556:	bfd1                	j	8000652a <sys_chdir+0x7a>

0000000080006558 <sys_exec>:

uint64
sys_exec(void)
{
    80006558:	7145                	addi	sp,sp,-464
    8000655a:	e786                	sd	ra,456(sp)
    8000655c:	e3a2                	sd	s0,448(sp)
    8000655e:	ff26                	sd	s1,440(sp)
    80006560:	fb4a                	sd	s2,432(sp)
    80006562:	f74e                	sd	s3,424(sp)
    80006564:	f352                	sd	s4,416(sp)
    80006566:	ef56                	sd	s5,408(sp)
    80006568:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000656a:	08000613          	li	a2,128
    8000656e:	f4040593          	addi	a1,s0,-192
    80006572:	4501                	li	a0,0
    80006574:	ffffd097          	auipc	ra,0xffffd
    80006578:	cc4080e7          	jalr	-828(ra) # 80003238 <argstr>
    return -1;
    8000657c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000657e:	0c054a63          	bltz	a0,80006652 <sys_exec+0xfa>
    80006582:	e3840593          	addi	a1,s0,-456
    80006586:	4505                	li	a0,1
    80006588:	ffffd097          	auipc	ra,0xffffd
    8000658c:	c8e080e7          	jalr	-882(ra) # 80003216 <argaddr>
    80006590:	0c054163          	bltz	a0,80006652 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006594:	10000613          	li	a2,256
    80006598:	4581                	li	a1,0
    8000659a:	e4040513          	addi	a0,s0,-448
    8000659e:	ffffa097          	auipc	ra,0xffffa
    800065a2:	740080e7          	jalr	1856(ra) # 80000cde <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800065a6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800065aa:	89a6                	mv	s3,s1
    800065ac:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800065ae:	02000a13          	li	s4,32
    800065b2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800065b6:	00391793          	slli	a5,s2,0x3
    800065ba:	e3040593          	addi	a1,s0,-464
    800065be:	e3843503          	ld	a0,-456(s0)
    800065c2:	953e                	add	a0,a0,a5
    800065c4:	ffffd097          	auipc	ra,0xffffd
    800065c8:	b96080e7          	jalr	-1130(ra) # 8000315a <fetchaddr>
    800065cc:	02054a63          	bltz	a0,80006600 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    800065d0:	e3043783          	ld	a5,-464(s0)
    800065d4:	c3b9                	beqz	a5,8000661a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800065d6:	ffffa097          	auipc	ra,0xffffa
    800065da:	51c080e7          	jalr	1308(ra) # 80000af2 <kalloc>
    800065de:	85aa                	mv	a1,a0
    800065e0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800065e4:	cd11                	beqz	a0,80006600 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800065e6:	6605                	lui	a2,0x1
    800065e8:	e3043503          	ld	a0,-464(s0)
    800065ec:	ffffd097          	auipc	ra,0xffffd
    800065f0:	bc0080e7          	jalr	-1088(ra) # 800031ac <fetchstr>
    800065f4:	00054663          	bltz	a0,80006600 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    800065f8:	0905                	addi	s2,s2,1
    800065fa:	09a1                	addi	s3,s3,8
    800065fc:	fb491be3          	bne	s2,s4,800065b2 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006600:	10048913          	addi	s2,s1,256
    80006604:	6088                	ld	a0,0(s1)
    80006606:	c529                	beqz	a0,80006650 <sys_exec+0xf8>
    kfree(argv[i]);
    80006608:	ffffa097          	auipc	ra,0xffffa
    8000660c:	3ce080e7          	jalr	974(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006610:	04a1                	addi	s1,s1,8
    80006612:	ff2499e3          	bne	s1,s2,80006604 <sys_exec+0xac>
  return -1;
    80006616:	597d                	li	s2,-1
    80006618:	a82d                	j	80006652 <sys_exec+0xfa>
      argv[i] = 0;
    8000661a:	0a8e                	slli	s5,s5,0x3
    8000661c:	fc040793          	addi	a5,s0,-64
    80006620:	9abe                	add	s5,s5,a5
    80006622:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd0e80>
  int ret = exec(path, argv);
    80006626:	e4040593          	addi	a1,s0,-448
    8000662a:	f4040513          	addi	a0,s0,-192
    8000662e:	fffff097          	auipc	ra,0xfffff
    80006632:	134080e7          	jalr	308(ra) # 80005762 <exec>
    80006636:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006638:	10048993          	addi	s3,s1,256
    8000663c:	6088                	ld	a0,0(s1)
    8000663e:	c911                	beqz	a0,80006652 <sys_exec+0xfa>
    kfree(argv[i]);
    80006640:	ffffa097          	auipc	ra,0xffffa
    80006644:	396080e7          	jalr	918(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006648:	04a1                	addi	s1,s1,8
    8000664a:	ff3499e3          	bne	s1,s3,8000663c <sys_exec+0xe4>
    8000664e:	a011                	j	80006652 <sys_exec+0xfa>
  return -1;
    80006650:	597d                	li	s2,-1
}
    80006652:	854a                	mv	a0,s2
    80006654:	60be                	ld	ra,456(sp)
    80006656:	641e                	ld	s0,448(sp)
    80006658:	74fa                	ld	s1,440(sp)
    8000665a:	795a                	ld	s2,432(sp)
    8000665c:	79ba                	ld	s3,424(sp)
    8000665e:	7a1a                	ld	s4,416(sp)
    80006660:	6afa                	ld	s5,408(sp)
    80006662:	6179                	addi	sp,sp,464
    80006664:	8082                	ret

0000000080006666 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006666:	7139                	addi	sp,sp,-64
    80006668:	fc06                	sd	ra,56(sp)
    8000666a:	f822                	sd	s0,48(sp)
    8000666c:	f426                	sd	s1,40(sp)
    8000666e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006670:	ffffb097          	auipc	ra,0xffffb
    80006674:	7d0080e7          	jalr	2000(ra) # 80001e40 <myproc>
    80006678:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    8000667a:	fd840593          	addi	a1,s0,-40
    8000667e:	4501                	li	a0,0
    80006680:	ffffd097          	auipc	ra,0xffffd
    80006684:	b96080e7          	jalr	-1130(ra) # 80003216 <argaddr>
    return -1;
    80006688:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    8000668a:	0e054063          	bltz	a0,8000676a <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    8000668e:	fc840593          	addi	a1,s0,-56
    80006692:	fd040513          	addi	a0,s0,-48
    80006696:	fffff097          	auipc	ra,0xfffff
    8000669a:	daa080e7          	jalr	-598(ra) # 80005440 <pipealloc>
    return -1;
    8000669e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800066a0:	0c054563          	bltz	a0,8000676a <sys_pipe+0x104>
  fd0 = -1;
    800066a4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800066a8:	fd043503          	ld	a0,-48(s0)
    800066ac:	fffff097          	auipc	ra,0xfffff
    800066b0:	4e8080e7          	jalr	1256(ra) # 80005b94 <fdalloc>
    800066b4:	fca42223          	sw	a0,-60(s0)
    800066b8:	08054c63          	bltz	a0,80006750 <sys_pipe+0xea>
    800066bc:	fc843503          	ld	a0,-56(s0)
    800066c0:	fffff097          	auipc	ra,0xfffff
    800066c4:	4d4080e7          	jalr	1236(ra) # 80005b94 <fdalloc>
    800066c8:	fca42023          	sw	a0,-64(s0)
    800066cc:	06054863          	bltz	a0,8000673c <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800066d0:	4691                	li	a3,4
    800066d2:	fc440613          	addi	a2,s0,-60
    800066d6:	fd843583          	ld	a1,-40(s0)
    800066da:	68a8                	ld	a0,80(s1)
    800066dc:	ffffb097          	auipc	ra,0xffffb
    800066e0:	424080e7          	jalr	1060(ra) # 80001b00 <copyout>
    800066e4:	02054063          	bltz	a0,80006704 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800066e8:	4691                	li	a3,4
    800066ea:	fc040613          	addi	a2,s0,-64
    800066ee:	fd843583          	ld	a1,-40(s0)
    800066f2:	0591                	addi	a1,a1,4
    800066f4:	68a8                	ld	a0,80(s1)
    800066f6:	ffffb097          	auipc	ra,0xffffb
    800066fa:	40a080e7          	jalr	1034(ra) # 80001b00 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800066fe:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006700:	06055563          	bgez	a0,8000676a <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006704:	fc442783          	lw	a5,-60(s0)
    80006708:	07e9                	addi	a5,a5,26
    8000670a:	078e                	slli	a5,a5,0x3
    8000670c:	97a6                	add	a5,a5,s1
    8000670e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006712:	fc042503          	lw	a0,-64(s0)
    80006716:	0569                	addi	a0,a0,26
    80006718:	050e                	slli	a0,a0,0x3
    8000671a:	9526                	add	a0,a0,s1
    8000671c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006720:	fd043503          	ld	a0,-48(s0)
    80006724:	ffffe097          	auipc	ra,0xffffe
    80006728:	7f6080e7          	jalr	2038(ra) # 80004f1a <fileclose>
    fileclose(wf);
    8000672c:	fc843503          	ld	a0,-56(s0)
    80006730:	ffffe097          	auipc	ra,0xffffe
    80006734:	7ea080e7          	jalr	2026(ra) # 80004f1a <fileclose>
    return -1;
    80006738:	57fd                	li	a5,-1
    8000673a:	a805                	j	8000676a <sys_pipe+0x104>
    if(fd0 >= 0)
    8000673c:	fc442783          	lw	a5,-60(s0)
    80006740:	0007c863          	bltz	a5,80006750 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006744:	01a78513          	addi	a0,a5,26
    80006748:	050e                	slli	a0,a0,0x3
    8000674a:	9526                	add	a0,a0,s1
    8000674c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006750:	fd043503          	ld	a0,-48(s0)
    80006754:	ffffe097          	auipc	ra,0xffffe
    80006758:	7c6080e7          	jalr	1990(ra) # 80004f1a <fileclose>
    fileclose(wf);
    8000675c:	fc843503          	ld	a0,-56(s0)
    80006760:	ffffe097          	auipc	ra,0xffffe
    80006764:	7ba080e7          	jalr	1978(ra) # 80004f1a <fileclose>
    return -1;
    80006768:	57fd                	li	a5,-1
}
    8000676a:	853e                	mv	a0,a5
    8000676c:	70e2                	ld	ra,56(sp)
    8000676e:	7442                	ld	s0,48(sp)
    80006770:	74a2                	ld	s1,40(sp)
    80006772:	6121                	addi	sp,sp,64
    80006774:	8082                	ret
	...

0000000080006780 <kernelvec>:
    80006780:	7111                	addi	sp,sp,-256
    80006782:	e006                	sd	ra,0(sp)
    80006784:	e40a                	sd	sp,8(sp)
    80006786:	e80e                	sd	gp,16(sp)
    80006788:	ec12                	sd	tp,24(sp)
    8000678a:	f016                	sd	t0,32(sp)
    8000678c:	f41a                	sd	t1,40(sp)
    8000678e:	f81e                	sd	t2,48(sp)
    80006790:	fc22                	sd	s0,56(sp)
    80006792:	e0a6                	sd	s1,64(sp)
    80006794:	e4aa                	sd	a0,72(sp)
    80006796:	e8ae                	sd	a1,80(sp)
    80006798:	ecb2                	sd	a2,88(sp)
    8000679a:	f0b6                	sd	a3,96(sp)
    8000679c:	f4ba                	sd	a4,104(sp)
    8000679e:	f8be                	sd	a5,112(sp)
    800067a0:	fcc2                	sd	a6,120(sp)
    800067a2:	e146                	sd	a7,128(sp)
    800067a4:	e54a                	sd	s2,136(sp)
    800067a6:	e94e                	sd	s3,144(sp)
    800067a8:	ed52                	sd	s4,152(sp)
    800067aa:	f156                	sd	s5,160(sp)
    800067ac:	f55a                	sd	s6,168(sp)
    800067ae:	f95e                	sd	s7,176(sp)
    800067b0:	fd62                	sd	s8,184(sp)
    800067b2:	e1e6                	sd	s9,192(sp)
    800067b4:	e5ea                	sd	s10,200(sp)
    800067b6:	e9ee                	sd	s11,208(sp)
    800067b8:	edf2                	sd	t3,216(sp)
    800067ba:	f1f6                	sd	t4,224(sp)
    800067bc:	f5fa                	sd	t5,232(sp)
    800067be:	f9fe                	sd	t6,240(sp)
    800067c0:	867fc0ef          	jal	ra,80003026 <kerneltrap>
    800067c4:	6082                	ld	ra,0(sp)
    800067c6:	6122                	ld	sp,8(sp)
    800067c8:	61c2                	ld	gp,16(sp)
    800067ca:	7282                	ld	t0,32(sp)
    800067cc:	7322                	ld	t1,40(sp)
    800067ce:	73c2                	ld	t2,48(sp)
    800067d0:	7462                	ld	s0,56(sp)
    800067d2:	6486                	ld	s1,64(sp)
    800067d4:	6526                	ld	a0,72(sp)
    800067d6:	65c6                	ld	a1,80(sp)
    800067d8:	6666                	ld	a2,88(sp)
    800067da:	7686                	ld	a3,96(sp)
    800067dc:	7726                	ld	a4,104(sp)
    800067de:	77c6                	ld	a5,112(sp)
    800067e0:	7866                	ld	a6,120(sp)
    800067e2:	688a                	ld	a7,128(sp)
    800067e4:	692a                	ld	s2,136(sp)
    800067e6:	69ca                	ld	s3,144(sp)
    800067e8:	6a6a                	ld	s4,152(sp)
    800067ea:	7a8a                	ld	s5,160(sp)
    800067ec:	7b2a                	ld	s6,168(sp)
    800067ee:	7bca                	ld	s7,176(sp)
    800067f0:	7c6a                	ld	s8,184(sp)
    800067f2:	6c8e                	ld	s9,192(sp)
    800067f4:	6d2e                	ld	s10,200(sp)
    800067f6:	6dce                	ld	s11,208(sp)
    800067f8:	6e6e                	ld	t3,216(sp)
    800067fa:	7e8e                	ld	t4,224(sp)
    800067fc:	7f2e                	ld	t5,232(sp)
    800067fe:	7fce                	ld	t6,240(sp)
    80006800:	6111                	addi	sp,sp,256
    80006802:	10200073          	sret
    80006806:	00000013          	nop
    8000680a:	00000013          	nop
    8000680e:	0001                	nop

0000000080006810 <timervec>:
    80006810:	34051573          	csrrw	a0,mscratch,a0
    80006814:	e10c                	sd	a1,0(a0)
    80006816:	e510                	sd	a2,8(a0)
    80006818:	e914                	sd	a3,16(a0)
    8000681a:	6d0c                	ld	a1,24(a0)
    8000681c:	7110                	ld	a2,32(a0)
    8000681e:	6194                	ld	a3,0(a1)
    80006820:	96b2                	add	a3,a3,a2
    80006822:	e194                	sd	a3,0(a1)
    80006824:	4589                	li	a1,2
    80006826:	14459073          	csrw	sip,a1
    8000682a:	6914                	ld	a3,16(a0)
    8000682c:	6510                	ld	a2,8(a0)
    8000682e:	610c                	ld	a1,0(a0)
    80006830:	34051573          	csrrw	a0,mscratch,a0
    80006834:	30200073          	mret
	...

000000008000683a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000683a:	1141                	addi	sp,sp,-16
    8000683c:	e422                	sd	s0,8(sp)
    8000683e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006840:	0c0007b7          	lui	a5,0xc000
    80006844:	4705                	li	a4,1
    80006846:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006848:	c3d8                	sw	a4,4(a5)
}
    8000684a:	6422                	ld	s0,8(sp)
    8000684c:	0141                	addi	sp,sp,16
    8000684e:	8082                	ret

0000000080006850 <plicinithart>:

void
plicinithart(void)
{
    80006850:	1141                	addi	sp,sp,-16
    80006852:	e406                	sd	ra,8(sp)
    80006854:	e022                	sd	s0,0(sp)
    80006856:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006858:	ffffb097          	auipc	ra,0xffffb
    8000685c:	5bc080e7          	jalr	1468(ra) # 80001e14 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006860:	0085171b          	slliw	a4,a0,0x8
    80006864:	0c0027b7          	lui	a5,0xc002
    80006868:	97ba                	add	a5,a5,a4
    8000686a:	40200713          	li	a4,1026
    8000686e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006872:	00d5151b          	slliw	a0,a0,0xd
    80006876:	0c2017b7          	lui	a5,0xc201
    8000687a:	953e                	add	a0,a0,a5
    8000687c:	00052023          	sw	zero,0(a0)
}
    80006880:	60a2                	ld	ra,8(sp)
    80006882:	6402                	ld	s0,0(sp)
    80006884:	0141                	addi	sp,sp,16
    80006886:	8082                	ret

0000000080006888 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006888:	1141                	addi	sp,sp,-16
    8000688a:	e406                	sd	ra,8(sp)
    8000688c:	e022                	sd	s0,0(sp)
    8000688e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006890:	ffffb097          	auipc	ra,0xffffb
    80006894:	584080e7          	jalr	1412(ra) # 80001e14 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006898:	00d5179b          	slliw	a5,a0,0xd
    8000689c:	0c201537          	lui	a0,0xc201
    800068a0:	953e                	add	a0,a0,a5
  return irq;
}
    800068a2:	4148                	lw	a0,4(a0)
    800068a4:	60a2                	ld	ra,8(sp)
    800068a6:	6402                	ld	s0,0(sp)
    800068a8:	0141                	addi	sp,sp,16
    800068aa:	8082                	ret

00000000800068ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800068ac:	1101                	addi	sp,sp,-32
    800068ae:	ec06                	sd	ra,24(sp)
    800068b0:	e822                	sd	s0,16(sp)
    800068b2:	e426                	sd	s1,8(sp)
    800068b4:	1000                	addi	s0,sp,32
    800068b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800068b8:	ffffb097          	auipc	ra,0xffffb
    800068bc:	55c080e7          	jalr	1372(ra) # 80001e14 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800068c0:	00d5151b          	slliw	a0,a0,0xd
    800068c4:	0c2017b7          	lui	a5,0xc201
    800068c8:	97aa                	add	a5,a5,a0
    800068ca:	c3c4                	sw	s1,4(a5)
}
    800068cc:	60e2                	ld	ra,24(sp)
    800068ce:	6442                	ld	s0,16(sp)
    800068d0:	64a2                	ld	s1,8(sp)
    800068d2:	6105                	addi	sp,sp,32
    800068d4:	8082                	ret

00000000800068d6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800068d6:	1141                	addi	sp,sp,-16
    800068d8:	e406                	sd	ra,8(sp)
    800068da:	e022                	sd	s0,0(sp)
    800068dc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800068de:	479d                	li	a5,7
    800068e0:	06a7c963          	blt	a5,a0,80006952 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800068e4:	00024797          	auipc	a5,0x24
    800068e8:	71c78793          	addi	a5,a5,1820 # 8002b000 <disk>
    800068ec:	00a78733          	add	a4,a5,a0
    800068f0:	6789                	lui	a5,0x2
    800068f2:	97ba                	add	a5,a5,a4
    800068f4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800068f8:	e7ad                	bnez	a5,80006962 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800068fa:	00451793          	slli	a5,a0,0x4
    800068fe:	00026717          	auipc	a4,0x26
    80006902:	70270713          	addi	a4,a4,1794 # 8002d000 <disk+0x2000>
    80006906:	6314                	ld	a3,0(a4)
    80006908:	96be                	add	a3,a3,a5
    8000690a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000690e:	6314                	ld	a3,0(a4)
    80006910:	96be                	add	a3,a3,a5
    80006912:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006916:	6314                	ld	a3,0(a4)
    80006918:	96be                	add	a3,a3,a5
    8000691a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000691e:	6318                	ld	a4,0(a4)
    80006920:	97ba                	add	a5,a5,a4
    80006922:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006926:	00024797          	auipc	a5,0x24
    8000692a:	6da78793          	addi	a5,a5,1754 # 8002b000 <disk>
    8000692e:	97aa                	add	a5,a5,a0
    80006930:	6509                	lui	a0,0x2
    80006932:	953e                	add	a0,a0,a5
    80006934:	4785                	li	a5,1
    80006936:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000693a:	00026517          	auipc	a0,0x26
    8000693e:	6de50513          	addi	a0,a0,1758 # 8002d018 <disk+0x2018>
    80006942:	ffffc097          	auipc	ra,0xffffc
    80006946:	efc080e7          	jalr	-260(ra) # 8000283e <wakeup>
}
    8000694a:	60a2                	ld	ra,8(sp)
    8000694c:	6402                	ld	s0,0(sp)
    8000694e:	0141                	addi	sp,sp,16
    80006950:	8082                	ret
    panic("free_desc 1");
    80006952:	00002517          	auipc	a0,0x2
    80006956:	f1e50513          	addi	a0,a0,-226 # 80008870 <syscalls+0x358>
    8000695a:	ffffa097          	auipc	ra,0xffffa
    8000695e:	bd0080e7          	jalr	-1072(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006962:	00002517          	auipc	a0,0x2
    80006966:	f1e50513          	addi	a0,a0,-226 # 80008880 <syscalls+0x368>
    8000696a:	ffffa097          	auipc	ra,0xffffa
    8000696e:	bc0080e7          	jalr	-1088(ra) # 8000052a <panic>

0000000080006972 <virtio_disk_init>:
{
    80006972:	1101                	addi	sp,sp,-32
    80006974:	ec06                	sd	ra,24(sp)
    80006976:	e822                	sd	s0,16(sp)
    80006978:	e426                	sd	s1,8(sp)
    8000697a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000697c:	00002597          	auipc	a1,0x2
    80006980:	f1458593          	addi	a1,a1,-236 # 80008890 <syscalls+0x378>
    80006984:	00026517          	auipc	a0,0x26
    80006988:	7a450513          	addi	a0,a0,1956 # 8002d128 <disk+0x2128>
    8000698c:	ffffa097          	auipc	ra,0xffffa
    80006990:	1c6080e7          	jalr	454(ra) # 80000b52 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006994:	100017b7          	lui	a5,0x10001
    80006998:	4398                	lw	a4,0(a5)
    8000699a:	2701                	sext.w	a4,a4
    8000699c:	747277b7          	lui	a5,0x74727
    800069a0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800069a4:	0ef71163          	bne	a4,a5,80006a86 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800069a8:	100017b7          	lui	a5,0x10001
    800069ac:	43dc                	lw	a5,4(a5)
    800069ae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800069b0:	4705                	li	a4,1
    800069b2:	0ce79a63          	bne	a5,a4,80006a86 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800069b6:	100017b7          	lui	a5,0x10001
    800069ba:	479c                	lw	a5,8(a5)
    800069bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800069be:	4709                	li	a4,2
    800069c0:	0ce79363          	bne	a5,a4,80006a86 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800069c4:	100017b7          	lui	a5,0x10001
    800069c8:	47d8                	lw	a4,12(a5)
    800069ca:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800069cc:	554d47b7          	lui	a5,0x554d4
    800069d0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800069d4:	0af71963          	bne	a4,a5,80006a86 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800069d8:	100017b7          	lui	a5,0x10001
    800069dc:	4705                	li	a4,1
    800069de:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800069e0:	470d                	li	a4,3
    800069e2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800069e4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800069e6:	c7ffe737          	lui	a4,0xc7ffe
    800069ea:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd075f>
    800069ee:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800069f0:	2701                	sext.w	a4,a4
    800069f2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800069f4:	472d                	li	a4,11
    800069f6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800069f8:	473d                	li	a4,15
    800069fa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800069fc:	6705                	lui	a4,0x1
    800069fe:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006a00:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006a04:	5bdc                	lw	a5,52(a5)
    80006a06:	2781                	sext.w	a5,a5
  if(max == 0)
    80006a08:	c7d9                	beqz	a5,80006a96 <virtio_disk_init+0x124>
  if(max < NUM)
    80006a0a:	471d                	li	a4,7
    80006a0c:	08f77d63          	bgeu	a4,a5,80006aa6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006a10:	100014b7          	lui	s1,0x10001
    80006a14:	47a1                	li	a5,8
    80006a16:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006a18:	6609                	lui	a2,0x2
    80006a1a:	4581                	li	a1,0
    80006a1c:	00024517          	auipc	a0,0x24
    80006a20:	5e450513          	addi	a0,a0,1508 # 8002b000 <disk>
    80006a24:	ffffa097          	auipc	ra,0xffffa
    80006a28:	2ba080e7          	jalr	698(ra) # 80000cde <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006a2c:	00024717          	auipc	a4,0x24
    80006a30:	5d470713          	addi	a4,a4,1492 # 8002b000 <disk>
    80006a34:	00c75793          	srli	a5,a4,0xc
    80006a38:	2781                	sext.w	a5,a5
    80006a3a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006a3c:	00026797          	auipc	a5,0x26
    80006a40:	5c478793          	addi	a5,a5,1476 # 8002d000 <disk+0x2000>
    80006a44:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006a46:	00024717          	auipc	a4,0x24
    80006a4a:	63a70713          	addi	a4,a4,1594 # 8002b080 <disk+0x80>
    80006a4e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006a50:	00025717          	auipc	a4,0x25
    80006a54:	5b070713          	addi	a4,a4,1456 # 8002c000 <disk+0x1000>
    80006a58:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006a5a:	4705                	li	a4,1
    80006a5c:	00e78c23          	sb	a4,24(a5)
    80006a60:	00e78ca3          	sb	a4,25(a5)
    80006a64:	00e78d23          	sb	a4,26(a5)
    80006a68:	00e78da3          	sb	a4,27(a5)
    80006a6c:	00e78e23          	sb	a4,28(a5)
    80006a70:	00e78ea3          	sb	a4,29(a5)
    80006a74:	00e78f23          	sb	a4,30(a5)
    80006a78:	00e78fa3          	sb	a4,31(a5)
}
    80006a7c:	60e2                	ld	ra,24(sp)
    80006a7e:	6442                	ld	s0,16(sp)
    80006a80:	64a2                	ld	s1,8(sp)
    80006a82:	6105                	addi	sp,sp,32
    80006a84:	8082                	ret
    panic("could not find virtio disk");
    80006a86:	00002517          	auipc	a0,0x2
    80006a8a:	e1a50513          	addi	a0,a0,-486 # 800088a0 <syscalls+0x388>
    80006a8e:	ffffa097          	auipc	ra,0xffffa
    80006a92:	a9c080e7          	jalr	-1380(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006a96:	00002517          	auipc	a0,0x2
    80006a9a:	e2a50513          	addi	a0,a0,-470 # 800088c0 <syscalls+0x3a8>
    80006a9e:	ffffa097          	auipc	ra,0xffffa
    80006aa2:	a8c080e7          	jalr	-1396(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006aa6:	00002517          	auipc	a0,0x2
    80006aaa:	e3a50513          	addi	a0,a0,-454 # 800088e0 <syscalls+0x3c8>
    80006aae:	ffffa097          	auipc	ra,0xffffa
    80006ab2:	a7c080e7          	jalr	-1412(ra) # 8000052a <panic>

0000000080006ab6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006ab6:	7119                	addi	sp,sp,-128
    80006ab8:	fc86                	sd	ra,120(sp)
    80006aba:	f8a2                	sd	s0,112(sp)
    80006abc:	f4a6                	sd	s1,104(sp)
    80006abe:	f0ca                	sd	s2,96(sp)
    80006ac0:	ecce                	sd	s3,88(sp)
    80006ac2:	e8d2                	sd	s4,80(sp)
    80006ac4:	e4d6                	sd	s5,72(sp)
    80006ac6:	e0da                	sd	s6,64(sp)
    80006ac8:	fc5e                	sd	s7,56(sp)
    80006aca:	f862                	sd	s8,48(sp)
    80006acc:	f466                	sd	s9,40(sp)
    80006ace:	f06a                	sd	s10,32(sp)
    80006ad0:	ec6e                	sd	s11,24(sp)
    80006ad2:	0100                	addi	s0,sp,128
    80006ad4:	8aaa                	mv	s5,a0
    80006ad6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006ad8:	00c52c83          	lw	s9,12(a0)
    80006adc:	001c9c9b          	slliw	s9,s9,0x1
    80006ae0:	1c82                	slli	s9,s9,0x20
    80006ae2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006ae6:	00026517          	auipc	a0,0x26
    80006aea:	64250513          	addi	a0,a0,1602 # 8002d128 <disk+0x2128>
    80006aee:	ffffa097          	auipc	ra,0xffffa
    80006af2:	0f4080e7          	jalr	244(ra) # 80000be2 <acquire>
  for(int i = 0; i < 3; i++){
    80006af6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006af8:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006afa:	00024c17          	auipc	s8,0x24
    80006afe:	506c0c13          	addi	s8,s8,1286 # 8002b000 <disk>
    80006b02:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006b04:	4b0d                	li	s6,3
    80006b06:	a0ad                	j	80006b70 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006b08:	00fc0733          	add	a4,s8,a5
    80006b0c:	975e                	add	a4,a4,s7
    80006b0e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006b12:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006b14:	0207c563          	bltz	a5,80006b3e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006b18:	2905                	addiw	s2,s2,1
    80006b1a:	0611                	addi	a2,a2,4
    80006b1c:	19690d63          	beq	s2,s6,80006cb6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006b20:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006b22:	00026717          	auipc	a4,0x26
    80006b26:	4f670713          	addi	a4,a4,1270 # 8002d018 <disk+0x2018>
    80006b2a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006b2c:	00074683          	lbu	a3,0(a4)
    80006b30:	fee1                	bnez	a3,80006b08 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006b32:	2785                	addiw	a5,a5,1
    80006b34:	0705                	addi	a4,a4,1
    80006b36:	fe979be3          	bne	a5,s1,80006b2c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006b3a:	57fd                	li	a5,-1
    80006b3c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006b3e:	01205d63          	blez	s2,80006b58 <virtio_disk_rw+0xa2>
    80006b42:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006b44:	000a2503          	lw	a0,0(s4)
    80006b48:	00000097          	auipc	ra,0x0
    80006b4c:	d8e080e7          	jalr	-626(ra) # 800068d6 <free_desc>
      for(int j = 0; j < i; j++)
    80006b50:	2d85                	addiw	s11,s11,1
    80006b52:	0a11                	addi	s4,s4,4
    80006b54:	ffb918e3          	bne	s2,s11,80006b44 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006b58:	00026597          	auipc	a1,0x26
    80006b5c:	5d058593          	addi	a1,a1,1488 # 8002d128 <disk+0x2128>
    80006b60:	00026517          	auipc	a0,0x26
    80006b64:	4b850513          	addi	a0,a0,1208 # 8002d018 <disk+0x2018>
    80006b68:	ffffc097          	auipc	ra,0xffffc
    80006b6c:	b4a080e7          	jalr	-1206(ra) # 800026b2 <sleep>
  for(int i = 0; i < 3; i++){
    80006b70:	f8040a13          	addi	s4,s0,-128
{
    80006b74:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006b76:	894e                	mv	s2,s3
    80006b78:	b765                	j	80006b20 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006b7a:	00026697          	auipc	a3,0x26
    80006b7e:	4866b683          	ld	a3,1158(a3) # 8002d000 <disk+0x2000>
    80006b82:	96ba                	add	a3,a3,a4
    80006b84:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006b88:	00024817          	auipc	a6,0x24
    80006b8c:	47880813          	addi	a6,a6,1144 # 8002b000 <disk>
    80006b90:	00026697          	auipc	a3,0x26
    80006b94:	47068693          	addi	a3,a3,1136 # 8002d000 <disk+0x2000>
    80006b98:	6290                	ld	a2,0(a3)
    80006b9a:	963a                	add	a2,a2,a4
    80006b9c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006ba0:	0015e593          	ori	a1,a1,1
    80006ba4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006ba8:	f8842603          	lw	a2,-120(s0)
    80006bac:	628c                	ld	a1,0(a3)
    80006bae:	972e                	add	a4,a4,a1
    80006bb0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006bb4:	20050593          	addi	a1,a0,512
    80006bb8:	0592                	slli	a1,a1,0x4
    80006bba:	95c2                	add	a1,a1,a6
    80006bbc:	577d                	li	a4,-1
    80006bbe:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006bc2:	00461713          	slli	a4,a2,0x4
    80006bc6:	6290                	ld	a2,0(a3)
    80006bc8:	963a                	add	a2,a2,a4
    80006bca:	03078793          	addi	a5,a5,48
    80006bce:	97c2                	add	a5,a5,a6
    80006bd0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006bd2:	629c                	ld	a5,0(a3)
    80006bd4:	97ba                	add	a5,a5,a4
    80006bd6:	4605                	li	a2,1
    80006bd8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006bda:	629c                	ld	a5,0(a3)
    80006bdc:	97ba                	add	a5,a5,a4
    80006bde:	4809                	li	a6,2
    80006be0:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006be4:	629c                	ld	a5,0(a3)
    80006be6:	973e                	add	a4,a4,a5
    80006be8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006bec:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006bf0:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006bf4:	6698                	ld	a4,8(a3)
    80006bf6:	00275783          	lhu	a5,2(a4)
    80006bfa:	8b9d                	andi	a5,a5,7
    80006bfc:	0786                	slli	a5,a5,0x1
    80006bfe:	97ba                	add	a5,a5,a4
    80006c00:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006c04:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006c08:	6698                	ld	a4,8(a3)
    80006c0a:	00275783          	lhu	a5,2(a4)
    80006c0e:	2785                	addiw	a5,a5,1
    80006c10:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006c14:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006c18:	100017b7          	lui	a5,0x10001
    80006c1c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006c20:	004aa783          	lw	a5,4(s5)
    80006c24:	02c79163          	bne	a5,a2,80006c46 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006c28:	00026917          	auipc	s2,0x26
    80006c2c:	50090913          	addi	s2,s2,1280 # 8002d128 <disk+0x2128>
  while(b->disk == 1) {
    80006c30:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006c32:	85ca                	mv	a1,s2
    80006c34:	8556                	mv	a0,s5
    80006c36:	ffffc097          	auipc	ra,0xffffc
    80006c3a:	a7c080e7          	jalr	-1412(ra) # 800026b2 <sleep>
  while(b->disk == 1) {
    80006c3e:	004aa783          	lw	a5,4(s5)
    80006c42:	fe9788e3          	beq	a5,s1,80006c32 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006c46:	f8042903          	lw	s2,-128(s0)
    80006c4a:	20090793          	addi	a5,s2,512
    80006c4e:	00479713          	slli	a4,a5,0x4
    80006c52:	00024797          	auipc	a5,0x24
    80006c56:	3ae78793          	addi	a5,a5,942 # 8002b000 <disk>
    80006c5a:	97ba                	add	a5,a5,a4
    80006c5c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006c60:	00026997          	auipc	s3,0x26
    80006c64:	3a098993          	addi	s3,s3,928 # 8002d000 <disk+0x2000>
    80006c68:	00491713          	slli	a4,s2,0x4
    80006c6c:	0009b783          	ld	a5,0(s3)
    80006c70:	97ba                	add	a5,a5,a4
    80006c72:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006c76:	854a                	mv	a0,s2
    80006c78:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006c7c:	00000097          	auipc	ra,0x0
    80006c80:	c5a080e7          	jalr	-934(ra) # 800068d6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006c84:	8885                	andi	s1,s1,1
    80006c86:	f0ed                	bnez	s1,80006c68 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006c88:	00026517          	auipc	a0,0x26
    80006c8c:	4a050513          	addi	a0,a0,1184 # 8002d128 <disk+0x2128>
    80006c90:	ffffa097          	auipc	ra,0xffffa
    80006c94:	006080e7          	jalr	6(ra) # 80000c96 <release>
}
    80006c98:	70e6                	ld	ra,120(sp)
    80006c9a:	7446                	ld	s0,112(sp)
    80006c9c:	74a6                	ld	s1,104(sp)
    80006c9e:	7906                	ld	s2,96(sp)
    80006ca0:	69e6                	ld	s3,88(sp)
    80006ca2:	6a46                	ld	s4,80(sp)
    80006ca4:	6aa6                	ld	s5,72(sp)
    80006ca6:	6b06                	ld	s6,64(sp)
    80006ca8:	7be2                	ld	s7,56(sp)
    80006caa:	7c42                	ld	s8,48(sp)
    80006cac:	7ca2                	ld	s9,40(sp)
    80006cae:	7d02                	ld	s10,32(sp)
    80006cb0:	6de2                	ld	s11,24(sp)
    80006cb2:	6109                	addi	sp,sp,128
    80006cb4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006cb6:	f8042503          	lw	a0,-128(s0)
    80006cba:	20050793          	addi	a5,a0,512
    80006cbe:	0792                	slli	a5,a5,0x4
  if(write)
    80006cc0:	00024817          	auipc	a6,0x24
    80006cc4:	34080813          	addi	a6,a6,832 # 8002b000 <disk>
    80006cc8:	00f80733          	add	a4,a6,a5
    80006ccc:	01a036b3          	snez	a3,s10
    80006cd0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006cd4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006cd8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006cdc:	7679                	lui	a2,0xffffe
    80006cde:	963e                	add	a2,a2,a5
    80006ce0:	00026697          	auipc	a3,0x26
    80006ce4:	32068693          	addi	a3,a3,800 # 8002d000 <disk+0x2000>
    80006ce8:	6298                	ld	a4,0(a3)
    80006cea:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006cec:	0a878593          	addi	a1,a5,168
    80006cf0:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006cf2:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006cf4:	6298                	ld	a4,0(a3)
    80006cf6:	9732                	add	a4,a4,a2
    80006cf8:	45c1                	li	a1,16
    80006cfa:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006cfc:	6298                	ld	a4,0(a3)
    80006cfe:	9732                	add	a4,a4,a2
    80006d00:	4585                	li	a1,1
    80006d02:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006d06:	f8442703          	lw	a4,-124(s0)
    80006d0a:	628c                	ld	a1,0(a3)
    80006d0c:	962e                	add	a2,a2,a1
    80006d0e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd000e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006d12:	0712                	slli	a4,a4,0x4
    80006d14:	6290                	ld	a2,0(a3)
    80006d16:	963a                	add	a2,a2,a4
    80006d18:	058a8593          	addi	a1,s5,88
    80006d1c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006d1e:	6294                	ld	a3,0(a3)
    80006d20:	96ba                	add	a3,a3,a4
    80006d22:	40000613          	li	a2,1024
    80006d26:	c690                	sw	a2,8(a3)
  if(write)
    80006d28:	e40d19e3          	bnez	s10,80006b7a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006d2c:	00026697          	auipc	a3,0x26
    80006d30:	2d46b683          	ld	a3,724(a3) # 8002d000 <disk+0x2000>
    80006d34:	96ba                	add	a3,a3,a4
    80006d36:	4609                	li	a2,2
    80006d38:	00c69623          	sh	a2,12(a3)
    80006d3c:	b5b1                	j	80006b88 <virtio_disk_rw+0xd2>

0000000080006d3e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006d3e:	1101                	addi	sp,sp,-32
    80006d40:	ec06                	sd	ra,24(sp)
    80006d42:	e822                	sd	s0,16(sp)
    80006d44:	e426                	sd	s1,8(sp)
    80006d46:	e04a                	sd	s2,0(sp)
    80006d48:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006d4a:	00026517          	auipc	a0,0x26
    80006d4e:	3de50513          	addi	a0,a0,990 # 8002d128 <disk+0x2128>
    80006d52:	ffffa097          	auipc	ra,0xffffa
    80006d56:	e90080e7          	jalr	-368(ra) # 80000be2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006d5a:	10001737          	lui	a4,0x10001
    80006d5e:	533c                	lw	a5,96(a4)
    80006d60:	8b8d                	andi	a5,a5,3
    80006d62:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006d64:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006d68:	00026797          	auipc	a5,0x26
    80006d6c:	29878793          	addi	a5,a5,664 # 8002d000 <disk+0x2000>
    80006d70:	6b94                	ld	a3,16(a5)
    80006d72:	0207d703          	lhu	a4,32(a5)
    80006d76:	0026d783          	lhu	a5,2(a3)
    80006d7a:	06f70163          	beq	a4,a5,80006ddc <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006d7e:	00024917          	auipc	s2,0x24
    80006d82:	28290913          	addi	s2,s2,642 # 8002b000 <disk>
    80006d86:	00026497          	auipc	s1,0x26
    80006d8a:	27a48493          	addi	s1,s1,634 # 8002d000 <disk+0x2000>
    __sync_synchronize();
    80006d8e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006d92:	6898                	ld	a4,16(s1)
    80006d94:	0204d783          	lhu	a5,32(s1)
    80006d98:	8b9d                	andi	a5,a5,7
    80006d9a:	078e                	slli	a5,a5,0x3
    80006d9c:	97ba                	add	a5,a5,a4
    80006d9e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006da0:	20078713          	addi	a4,a5,512
    80006da4:	0712                	slli	a4,a4,0x4
    80006da6:	974a                	add	a4,a4,s2
    80006da8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80006dac:	e731                	bnez	a4,80006df8 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006dae:	20078793          	addi	a5,a5,512
    80006db2:	0792                	slli	a5,a5,0x4
    80006db4:	97ca                	add	a5,a5,s2
    80006db6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006db8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006dbc:	ffffc097          	auipc	ra,0xffffc
    80006dc0:	a82080e7          	jalr	-1406(ra) # 8000283e <wakeup>

    disk.used_idx += 1;
    80006dc4:	0204d783          	lhu	a5,32(s1)
    80006dc8:	2785                	addiw	a5,a5,1
    80006dca:	17c2                	slli	a5,a5,0x30
    80006dcc:	93c1                	srli	a5,a5,0x30
    80006dce:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006dd2:	6898                	ld	a4,16(s1)
    80006dd4:	00275703          	lhu	a4,2(a4)
    80006dd8:	faf71be3          	bne	a4,a5,80006d8e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006ddc:	00026517          	auipc	a0,0x26
    80006de0:	34c50513          	addi	a0,a0,844 # 8002d128 <disk+0x2128>
    80006de4:	ffffa097          	auipc	ra,0xffffa
    80006de8:	eb2080e7          	jalr	-334(ra) # 80000c96 <release>
}
    80006dec:	60e2                	ld	ra,24(sp)
    80006dee:	6442                	ld	s0,16(sp)
    80006df0:	64a2                	ld	s1,8(sp)
    80006df2:	6902                	ld	s2,0(sp)
    80006df4:	6105                	addi	sp,sp,32
    80006df6:	8082                	ret
      panic("virtio_disk_intr status");
    80006df8:	00002517          	auipc	a0,0x2
    80006dfc:	b0850513          	addi	a0,a0,-1272 # 80008900 <syscalls+0x3e8>
    80006e00:	ffff9097          	auipc	ra,0xffff9
    80006e04:	72a080e7          	jalr	1834(ra) # 8000052a <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
