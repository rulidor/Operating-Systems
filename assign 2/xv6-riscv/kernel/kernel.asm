
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
    80000068:	1cc78793          	addi	a5,a5,460 # 80006230 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd27ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dbe78793          	addi	a5,a5,-578 # 80000e6c <main>
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
    8000011e:	00002097          	auipc	ra,0x2
    80000122:	636080e7          	jalr	1590(ra) # 80002754 <either_copyin>
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
    80000188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
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
    800001b2:	00001097          	auipc	ra,0x1
    800001b6:	7cc080e7          	jalr	1996(ra) # 8000197e <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	f0c080e7          	jalr	-244(ra) # 800020ce <sleep>
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
    800001fe:	00002097          	auipc	ra,0x2
    80000202:	500080e7          	jalr	1280(ra) # 800026fe <either_copyout>
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
    8000021e:	a5c080e7          	jalr	-1444(ra) # 80000c76 <release>

  return target - n;
    80000222:	413b053b          	subw	a0,s6,s3
    80000226:	a811                	j	8000023a <consoleread+0xe4>
        release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	f5850513          	addi	a0,a0,-168 # 80011180 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a46080e7          	jalr	-1466(ra) # 80000c76 <release>
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
    800002c4:	902080e7          	jalr	-1790(ra) # 80000bc2 <acquire>

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
    800002de:	00002097          	auipc	ra,0x2
    800002e2:	4cc080e7          	jalr	1228(ra) # 800027aa <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002e6:	00011517          	auipc	a0,0x11
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80011180 <cons>
    800002ee:	00001097          	auipc	ra,0x1
    800002f2:	988080e7          	jalr	-1656(ra) # 80000c76 <release>
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
    80000436:	e28080e7          	jalr	-472(ra) # 8000225a <wakeup>
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
    80000458:	6de080e7          	jalr	1758(ra) # 80000b32 <initlock>

  uartinit();
    8000045c:	00000097          	auipc	ra,0x0
    80000460:	32a080e7          	jalr	810(ra) # 80000786 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000464:	00027797          	auipc	a5,0x27
    80000468:	6b478793          	addi	a5,a5,1716 # 80027b18 <devsw>
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
    8000055c:	b7050513          	addi	a0,a0,-1168 # 800080c8 <digits+0x88>
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
    800005f0:	5d6080e7          	jalr	1494(ra) # 80000bc2 <acquire>
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
    8000074e:	52c080e7          	jalr	1324(ra) # 80000c76 <release>
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
    80000774:	3c2080e7          	jalr	962(ra) # 80000b32 <initlock>
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
    800007ca:	36c080e7          	jalr	876(ra) # 80000b32 <initlock>
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
    800007e6:	394080e7          	jalr	916(ra) # 80000b76 <push_off>

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
    80000814:	406080e7          	jalr	1030(ra) # 80000c16 <pop_off>
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
    80000882:	9dc080e7          	jalr	-1572(ra) # 8000225a <wakeup>
    
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
    800008c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>
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
    8000090a:	00001097          	auipc	ra,0x1
    8000090e:	7c4080e7          	jalr	1988(ra) # 800020ce <sleep>
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
    8000094a:	330080e7          	jalr	816(ra) # 80000c76 <release>
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
    800009b6:	210080e7          	jalr	528(ra) # 80000bc2 <acquire>
  uartstart();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	e68080e7          	jalr	-408(ra) # 80000822 <uartstart>
  release(&uart_tx_lock);
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	2b2080e7          	jalr	690(ra) # 80000c76 <release>
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

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009e2:	03451793          	slli	a5,a0,0x34
    800009e6:	ebb9                	bnez	a5,80000a3c <kfree+0x66>
    800009e8:	84aa                	mv	s1,a0
    800009ea:	0002b797          	auipc	a5,0x2b
    800009ee:	61678793          	addi	a5,a5,1558 # 8002c000 <end>
    800009f2:	04f56563          	bltu	a0,a5,80000a3c <kfree+0x66>
    800009f6:	47c5                	li	a5,17
    800009f8:	07ee                	slli	a5,a5,0x1b
    800009fa:	04f57163          	bgeu	a0,a5,80000a3c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009fe:	6605                	lui	a2,0x1
    80000a00:	4585                	li	a1,1
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	2bc080e7          	jalr	700(ra) # 80000cbe <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0a:	00011917          	auipc	s2,0x11
    80000a0e:	87690913          	addi	s2,s2,-1930 # 80011280 <kmem>
    80000a12:	854a                	mv	a0,s2
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	1ae080e7          	jalr	430(ra) # 80000bc2 <acquire>
  r->next = kmem.freelist;
    80000a1c:	01893783          	ld	a5,24(s2)
    80000a20:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a22:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	24e080e7          	jalr	590(ra) # 80000c76 <release>
}
    80000a30:	60e2                	ld	ra,24(sp)
    80000a32:	6442                	ld	s0,16(sp)
    80000a34:	64a2                	ld	s1,8(sp)
    80000a36:	6902                	ld	s2,0(sp)
    80000a38:	6105                	addi	sp,sp,32
    80000a3a:	8082                	ret
    panic("kfree");
    80000a3c:	00007517          	auipc	a0,0x7
    80000a40:	62450513          	addi	a0,a0,1572 # 80008060 <digits+0x20>
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	ae6080e7          	jalr	-1306(ra) # 8000052a <panic>

0000000080000a4c <freerange>:
{
    80000a4c:	7179                	addi	sp,sp,-48
    80000a4e:	f406                	sd	ra,40(sp)
    80000a50:	f022                	sd	s0,32(sp)
    80000a52:	ec26                	sd	s1,24(sp)
    80000a54:	e84a                	sd	s2,16(sp)
    80000a56:	e44e                	sd	s3,8(sp)
    80000a58:	e052                	sd	s4,0(sp)
    80000a5a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a5c:	6785                	lui	a5,0x1
    80000a5e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a62:	94aa                	add	s1,s1,a0
    80000a64:	757d                	lui	a0,0xfffff
    80000a66:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a68:	94be                	add	s1,s1,a5
    80000a6a:	0095ee63          	bltu	a1,s1,80000a86 <freerange+0x3a>
    80000a6e:	892e                	mv	s2,a1
    kfree(p);
    80000a70:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a72:	6985                	lui	s3,0x1
    kfree(p);
    80000a74:	01448533          	add	a0,s1,s4
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	f5e080e7          	jalr	-162(ra) # 800009d6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe9979e3          	bgeu	s2,s1,80000a74 <freerange+0x28>
}
    80000a86:	70a2                	ld	ra,40(sp)
    80000a88:	7402                	ld	s0,32(sp)
    80000a8a:	64e2                	ld	s1,24(sp)
    80000a8c:	6942                	ld	s2,16(sp)
    80000a8e:	69a2                	ld	s3,8(sp)
    80000a90:	6a02                	ld	s4,0(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00007597          	auipc	a1,0x7
    80000aa2:	5ca58593          	addi	a1,a1,1482 # 80008068 <digits+0x28>
    80000aa6:	00010517          	auipc	a0,0x10
    80000aaa:	7da50513          	addi	a0,a0,2010 # 80011280 <kmem>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	084080e7          	jalr	132(ra) # 80000b32 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ab6:	45c5                	li	a1,17
    80000ab8:	05ee                	slli	a1,a1,0x1b
    80000aba:	0002b517          	auipc	a0,0x2b
    80000abe:	54650513          	addi	a0,a0,1350 # 8002c000 <end>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	f8a080e7          	jalr	-118(ra) # 80000a4c <freerange>
}
    80000aca:	60a2                	ld	ra,8(sp)
    80000acc:	6402                	ld	s0,0(sp)
    80000ace:	0141                	addi	sp,sp,16
    80000ad0:	8082                	ret

0000000080000ad2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ad2:	1101                	addi	sp,sp,-32
    80000ad4:	ec06                	sd	ra,24(sp)
    80000ad6:	e822                	sd	s0,16(sp)
    80000ad8:	e426                	sd	s1,8(sp)
    80000ada:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000adc:	00010497          	auipc	s1,0x10
    80000ae0:	7a448493          	addi	s1,s1,1956 # 80011280 <kmem>
    80000ae4:	8526                	mv	a0,s1
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	0dc080e7          	jalr	220(ra) # 80000bc2 <acquire>
  r = kmem.freelist;
    80000aee:	6c84                	ld	s1,24(s1)
  if(r)
    80000af0:	c885                	beqz	s1,80000b20 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af2:	609c                	ld	a5,0(s1)
    80000af4:	00010517          	auipc	a0,0x10
    80000af8:	78c50513          	addi	a0,a0,1932 # 80011280 <kmem>
    80000afc:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	178080e7          	jalr	376(ra) # 80000c76 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b06:	6605                	lui	a2,0x1
    80000b08:	4595                	li	a1,5
    80000b0a:	8526                	mv	a0,s1
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	1b2080e7          	jalr	434(ra) # 80000cbe <memset>
  return (void*)r;
}
    80000b14:	8526                	mv	a0,s1
    80000b16:	60e2                	ld	ra,24(sp)
    80000b18:	6442                	ld	s0,16(sp)
    80000b1a:	64a2                	ld	s1,8(sp)
    80000b1c:	6105                	addi	sp,sp,32
    80000b1e:	8082                	ret
  release(&kmem.lock);
    80000b20:	00010517          	auipc	a0,0x10
    80000b24:	76050513          	addi	a0,a0,1888 # 80011280 <kmem>
    80000b28:	00000097          	auipc	ra,0x0
    80000b2c:	14e080e7          	jalr	334(ra) # 80000c76 <release>
  if(r)
    80000b30:	b7d5                	j	80000b14 <kalloc+0x42>

0000000080000b32 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b32:	1141                	addi	sp,sp,-16
    80000b34:	e422                	sd	s0,8(sp)
    80000b36:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b38:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b3a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b3e:	00053823          	sd	zero,16(a0)
}
    80000b42:	6422                	ld	s0,8(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b48:	411c                	lw	a5,0(a0)
    80000b4a:	e399                	bnez	a5,80000b50 <holding+0x8>
    80000b4c:	4501                	li	a0,0
  return r;
}
    80000b4e:	8082                	ret
{
    80000b50:	1101                	addi	sp,sp,-32
    80000b52:	ec06                	sd	ra,24(sp)
    80000b54:	e822                	sd	s0,16(sp)
    80000b56:	e426                	sd	s1,8(sp)
    80000b58:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b5a:	6904                	ld	s1,16(a0)
    80000b5c:	00001097          	auipc	ra,0x1
    80000b60:	e06080e7          	jalr	-506(ra) # 80001962 <mycpu>
    80000b64:	40a48533          	sub	a0,s1,a0
    80000b68:	00153513          	seqz	a0,a0
}
    80000b6c:	60e2                	ld	ra,24(sp)
    80000b6e:	6442                	ld	s0,16(sp)
    80000b70:	64a2                	ld	s1,8(sp)
    80000b72:	6105                	addi	sp,sp,32
    80000b74:	8082                	ret

0000000080000b76 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b76:	1101                	addi	sp,sp,-32
    80000b78:	ec06                	sd	ra,24(sp)
    80000b7a:	e822                	sd	s0,16(sp)
    80000b7c:	e426                	sd	s1,8(sp)
    80000b7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b80:	100024f3          	csrr	s1,sstatus
    80000b84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b88:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b8a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b8e:	00001097          	auipc	ra,0x1
    80000b92:	dd4080e7          	jalr	-556(ra) # 80001962 <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	dc8080e7          	jalr	-568(ra) # 80001962 <mycpu>
    80000ba2:	5d3c                	lw	a5,120(a0)
    80000ba4:	2785                	addiw	a5,a5,1
    80000ba6:	dd3c                	sw	a5,120(a0)
}
    80000ba8:	60e2                	ld	ra,24(sp)
    80000baa:	6442                	ld	s0,16(sp)
    80000bac:	64a2                	ld	s1,8(sp)
    80000bae:	6105                	addi	sp,sp,32
    80000bb0:	8082                	ret
    mycpu()->intena = old;
    80000bb2:	00001097          	auipc	ra,0x1
    80000bb6:	db0080e7          	jalr	-592(ra) # 80001962 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bba:	8085                	srli	s1,s1,0x1
    80000bbc:	8885                	andi	s1,s1,1
    80000bbe:	dd64                	sw	s1,124(a0)
    80000bc0:	bfe9                	j	80000b9a <push_off+0x24>

0000000080000bc2 <acquire>:
{
    80000bc2:	1101                	addi	sp,sp,-32
    80000bc4:	ec06                	sd	ra,24(sp)
    80000bc6:	e822                	sd	s0,16(sp)
    80000bc8:	e426                	sd	s1,8(sp)
    80000bca:	1000                	addi	s0,sp,32
    80000bcc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bce:	00000097          	auipc	ra,0x0
    80000bd2:	fa8080e7          	jalr	-88(ra) # 80000b76 <push_off>
  if(holding(lk))
    80000bd6:	8526                	mv	a0,s1
    80000bd8:	00000097          	auipc	ra,0x0
    80000bdc:	f70080e7          	jalr	-144(ra) # 80000b48 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be0:	4705                	li	a4,1
  if(holding(lk))
    80000be2:	e115                	bnez	a0,80000c06 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	87ba                	mv	a5,a4
    80000be6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bea:	2781                	sext.w	a5,a5
    80000bec:	ffe5                	bnez	a5,80000be4 <acquire+0x22>
  __sync_synchronize();
    80000bee:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	d70080e7          	jalr	-656(ra) # 80001962 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00007517          	auipc	a0,0x7
    80000c0a:	46a50513          	addi	a0,a0,1130 # 80008070 <digits+0x30>
    80000c0e:	00000097          	auipc	ra,0x0
    80000c12:	91c080e7          	jalr	-1764(ra) # 8000052a <panic>

0000000080000c16 <pop_off>:

void
pop_off(void)
{
    80000c16:	1141                	addi	sp,sp,-16
    80000c18:	e406                	sd	ra,8(sp)
    80000c1a:	e022                	sd	s0,0(sp)
    80000c1c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1e:	00001097          	auipc	ra,0x1
    80000c22:	d44080e7          	jalr	-700(ra) # 80001962 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c26:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c2a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c2c:	e78d                	bnez	a5,80000c56 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c2e:	5d3c                	lw	a5,120(a0)
    80000c30:	02f05b63          	blez	a5,80000c66 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c34:	37fd                	addiw	a5,a5,-1
    80000c36:	0007871b          	sext.w	a4,a5
    80000c3a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c3c:	eb09                	bnez	a4,80000c4e <pop_off+0x38>
    80000c3e:	5d7c                	lw	a5,124(a0)
    80000c40:	c799                	beqz	a5,80000c4e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c42:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c46:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c4a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c4e:	60a2                	ld	ra,8(sp)
    80000c50:	6402                	ld	s0,0(sp)
    80000c52:	0141                	addi	sp,sp,16
    80000c54:	8082                	ret
    panic("pop_off - interruptible");
    80000c56:	00007517          	auipc	a0,0x7
    80000c5a:	42250513          	addi	a0,a0,1058 # 80008078 <digits+0x38>
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	8cc080e7          	jalr	-1844(ra) # 8000052a <panic>
    panic("pop_off");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	42a50513          	addi	a0,a0,1066 # 80008090 <digits+0x50>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8bc080e7          	jalr	-1860(ra) # 8000052a <panic>

0000000080000c76 <release>:
{
    80000c76:	1101                	addi	sp,sp,-32
    80000c78:	ec06                	sd	ra,24(sp)
    80000c7a:	e822                	sd	s0,16(sp)
    80000c7c:	e426                	sd	s1,8(sp)
    80000c7e:	1000                	addi	s0,sp,32
    80000c80:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	ec6080e7          	jalr	-314(ra) # 80000b48 <holding>
    80000c8a:	c115                	beqz	a0,80000cae <release+0x38>
  lk->cpu = 0;
    80000c8c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c90:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c94:	0f50000f          	fence	iorw,ow
    80000c98:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	f7a080e7          	jalr	-134(ra) # 80000c16 <pop_off>
}
    80000ca4:	60e2                	ld	ra,24(sp)
    80000ca6:	6442                	ld	s0,16(sp)
    80000ca8:	64a2                	ld	s1,8(sp)
    80000caa:	6105                	addi	sp,sp,32
    80000cac:	8082                	ret
    panic("release");
    80000cae:	00007517          	auipc	a0,0x7
    80000cb2:	3ea50513          	addi	a0,a0,1002 # 80008098 <digits+0x58>
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	874080e7          	jalr	-1932(ra) # 8000052a <panic>

0000000080000cbe <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cbe:	1141                	addi	sp,sp,-16
    80000cc0:	e422                	sd	s0,8(sp)
    80000cc2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cc4:	ca19                	beqz	a2,80000cda <memset+0x1c>
    80000cc6:	87aa                	mv	a5,a0
    80000cc8:	1602                	slli	a2,a2,0x20
    80000cca:	9201                	srli	a2,a2,0x20
    80000ccc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cd0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cd4:	0785                	addi	a5,a5,1
    80000cd6:	fee79de3          	bne	a5,a4,80000cd0 <memset+0x12>
  }
  return dst;
}
    80000cda:	6422                	ld	s0,8(sp)
    80000cdc:	0141                	addi	sp,sp,16
    80000cde:	8082                	ret

0000000080000ce0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ce6:	ca05                	beqz	a2,80000d16 <memcmp+0x36>
    80000ce8:	fff6069b          	addiw	a3,a2,-1
    80000cec:	1682                	slli	a3,a3,0x20
    80000cee:	9281                	srli	a3,a3,0x20
    80000cf0:	0685                	addi	a3,a3,1
    80000cf2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cf4:	00054783          	lbu	a5,0(a0)
    80000cf8:	0005c703          	lbu	a4,0(a1)
    80000cfc:	00e79863          	bne	a5,a4,80000d0c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d00:	0505                	addi	a0,a0,1
    80000d02:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d04:	fed518e3          	bne	a0,a3,80000cf4 <memcmp+0x14>
  }

  return 0;
    80000d08:	4501                	li	a0,0
    80000d0a:	a019                	j	80000d10 <memcmp+0x30>
      return *s1 - *s2;
    80000d0c:	40e7853b          	subw	a0,a5,a4
}
    80000d10:	6422                	ld	s0,8(sp)
    80000d12:	0141                	addi	sp,sp,16
    80000d14:	8082                	ret
  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	bfe5                	j	80000d10 <memcmp+0x30>

0000000080000d1a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d1a:	1141                	addi	sp,sp,-16
    80000d1c:	e422                	sd	s0,8(sp)
    80000d1e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d20:	02a5e563          	bltu	a1,a0,80000d4a <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d24:	fff6069b          	addiw	a3,a2,-1
    80000d28:	ce11                	beqz	a2,80000d44 <memmove+0x2a>
    80000d2a:	1682                	slli	a3,a3,0x20
    80000d2c:	9281                	srli	a3,a3,0x20
    80000d2e:	0685                	addi	a3,a3,1
    80000d30:	96ae                	add	a3,a3,a1
    80000d32:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d34:	0585                	addi	a1,a1,1
    80000d36:	0785                	addi	a5,a5,1
    80000d38:	fff5c703          	lbu	a4,-1(a1)
    80000d3c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d40:	fed59ae3          	bne	a1,a3,80000d34 <memmove+0x1a>

  return dst;
}
    80000d44:	6422                	ld	s0,8(sp)
    80000d46:	0141                	addi	sp,sp,16
    80000d48:	8082                	ret
  if(s < d && s + n > d){
    80000d4a:	02061713          	slli	a4,a2,0x20
    80000d4e:	9301                	srli	a4,a4,0x20
    80000d50:	00e587b3          	add	a5,a1,a4
    80000d54:	fcf578e3          	bgeu	a0,a5,80000d24 <memmove+0xa>
    d += n;
    80000d58:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d5a:	fff6069b          	addiw	a3,a2,-1
    80000d5e:	d27d                	beqz	a2,80000d44 <memmove+0x2a>
    80000d60:	02069613          	slli	a2,a3,0x20
    80000d64:	9201                	srli	a2,a2,0x20
    80000d66:	fff64613          	not	a2,a2
    80000d6a:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d6c:	17fd                	addi	a5,a5,-1
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	0007c683          	lbu	a3,0(a5)
    80000d74:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d78:	fef61ae3          	bne	a2,a5,80000d6c <memmove+0x52>
    80000d7c:	b7e1                	j	80000d44 <memmove+0x2a>

0000000080000d7e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d7e:	1141                	addi	sp,sp,-16
    80000d80:	e406                	sd	ra,8(sp)
    80000d82:	e022                	sd	s0,0(sp)
    80000d84:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	f94080e7          	jalr	-108(ra) # 80000d1a <memmove>
}
    80000d8e:	60a2                	ld	ra,8(sp)
    80000d90:	6402                	ld	s0,0(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9c:	ce11                	beqz	a2,80000db8 <strncmp+0x22>
    80000d9e:	00054783          	lbu	a5,0(a0)
    80000da2:	cf89                	beqz	a5,80000dbc <strncmp+0x26>
    80000da4:	0005c703          	lbu	a4,0(a1)
    80000da8:	00f71a63          	bne	a4,a5,80000dbc <strncmp+0x26>
    n--, p++, q++;
    80000dac:	367d                	addiw	a2,a2,-1
    80000dae:	0505                	addi	a0,a0,1
    80000db0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db2:	f675                	bnez	a2,80000d9e <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db4:	4501                	li	a0,0
    80000db6:	a809                	j	80000dc8 <strncmp+0x32>
    80000db8:	4501                	li	a0,0
    80000dba:	a039                	j	80000dc8 <strncmp+0x32>
  if(n == 0)
    80000dbc:	ca09                	beqz	a2,80000dce <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dbe:	00054503          	lbu	a0,0(a0)
    80000dc2:	0005c783          	lbu	a5,0(a1)
    80000dc6:	9d1d                	subw	a0,a0,a5
}
    80000dc8:	6422                	ld	s0,8(sp)
    80000dca:	0141                	addi	sp,sp,16
    80000dcc:	8082                	ret
    return 0;
    80000dce:	4501                	li	a0,0
    80000dd0:	bfe5                	j	80000dc8 <strncmp+0x32>

0000000080000dd2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd2:	1141                	addi	sp,sp,-16
    80000dd4:	e422                	sd	s0,8(sp)
    80000dd6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd8:	872a                	mv	a4,a0
    80000dda:	8832                	mv	a6,a2
    80000ddc:	367d                	addiw	a2,a2,-1
    80000dde:	01005963          	blez	a6,80000df0 <strncpy+0x1e>
    80000de2:	0705                	addi	a4,a4,1
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	fef70fa3          	sb	a5,-1(a4)
    80000dec:	0585                	addi	a1,a1,1
    80000dee:	f7f5                	bnez	a5,80000dda <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df0:	86ba                	mv	a3,a4
    80000df2:	00c05c63          	blez	a2,80000e0a <strncpy+0x38>
    *s++ = 0;
    80000df6:	0685                	addi	a3,a3,1
    80000df8:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000dfc:	fff6c793          	not	a5,a3
    80000e00:	9fb9                	addw	a5,a5,a4
    80000e02:	010787bb          	addw	a5,a5,a6
    80000e06:	fef048e3          	bgtz	a5,80000df6 <strncpy+0x24>
  return os;
}
    80000e0a:	6422                	ld	s0,8(sp)
    80000e0c:	0141                	addi	sp,sp,16
    80000e0e:	8082                	ret

0000000080000e10 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e10:	1141                	addi	sp,sp,-16
    80000e12:	e422                	sd	s0,8(sp)
    80000e14:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e16:	02c05363          	blez	a2,80000e3c <safestrcpy+0x2c>
    80000e1a:	fff6069b          	addiw	a3,a2,-1
    80000e1e:	1682                	slli	a3,a3,0x20
    80000e20:	9281                	srli	a3,a3,0x20
    80000e22:	96ae                	add	a3,a3,a1
    80000e24:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e26:	00d58963          	beq	a1,a3,80000e38 <safestrcpy+0x28>
    80000e2a:	0585                	addi	a1,a1,1
    80000e2c:	0785                	addi	a5,a5,1
    80000e2e:	fff5c703          	lbu	a4,-1(a1)
    80000e32:	fee78fa3          	sb	a4,-1(a5)
    80000e36:	fb65                	bnez	a4,80000e26 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e38:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e3c:	6422                	ld	s0,8(sp)
    80000e3e:	0141                	addi	sp,sp,16
    80000e40:	8082                	ret

0000000080000e42 <strlen>:

int
strlen(const char *s)
{
    80000e42:	1141                	addi	sp,sp,-16
    80000e44:	e422                	sd	s0,8(sp)
    80000e46:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e48:	00054783          	lbu	a5,0(a0)
    80000e4c:	cf91                	beqz	a5,80000e68 <strlen+0x26>
    80000e4e:	0505                	addi	a0,a0,1
    80000e50:	87aa                	mv	a5,a0
    80000e52:	4685                	li	a3,1
    80000e54:	9e89                	subw	a3,a3,a0
    80000e56:	00f6853b          	addw	a0,a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	fb7d                	bnez	a4,80000e56 <strlen+0x14>
    ;
  return n;
}
    80000e62:	6422                	ld	s0,8(sp)
    80000e64:	0141                	addi	sp,sp,16
    80000e66:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e68:	4501                	li	a0,0
    80000e6a:	bfe5                	j	80000e62 <strlen+0x20>

0000000080000e6c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e6c:	1141                	addi	sp,sp,-16
    80000e6e:	e406                	sd	ra,8(sp)
    80000e70:	e022                	sd	s0,0(sp)
    80000e72:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e74:	00001097          	auipc	ra,0x1
    80000e78:	ade080e7          	jalr	-1314(ra) # 80001952 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e7c:	00008717          	auipc	a4,0x8
    80000e80:	19c70713          	addi	a4,a4,412 # 80009018 <started>
  if(cpuid() == 0){
    80000e84:	c139                	beqz	a0,80000eca <main+0x5e>
    while(started == 0)
    80000e86:	431c                	lw	a5,0(a4)
    80000e88:	2781                	sext.w	a5,a5
    80000e8a:	dff5                	beqz	a5,80000e86 <main+0x1a>
      ;
    __sync_synchronize();
    80000e8c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e90:	00001097          	auipc	ra,0x1
    80000e94:	ac2080e7          	jalr	-1342(ra) # 80001952 <cpuid>
    80000e98:	85aa                	mv	a1,a0
    80000e9a:	00007517          	auipc	a0,0x7
    80000e9e:	21e50513          	addi	a0,a0,542 # 800080b8 <digits+0x78>
    80000ea2:	fffff097          	auipc	ra,0xfffff
    80000ea6:	6d2080e7          	jalr	1746(ra) # 80000574 <printf>
    kvminithart();    // turn on paging
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	0d8080e7          	jalr	216(ra) # 80000f82 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb2:	00002097          	auipc	ra,0x2
    80000eb6:	bdc080e7          	jalr	-1060(ra) # 80002a8e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00005097          	auipc	ra,0x5
    80000ebe:	3b6080e7          	jalr	950(ra) # 80006270 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	05a080e7          	jalr	90(ra) # 80001f1c <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00007517          	auipc	a0,0x7
    80000ede:	1ee50513          	addi	a0,a0,494 # 800080c8 <digits+0x88>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00007517          	auipc	a0,0x7
    80000eee:	1b650513          	addi	a0,a0,438 # 800080a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00007517          	auipc	a0,0x7
    80000efe:	1ce50513          	addi	a0,a0,462 # 800080c8 <digits+0x88>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	310080e7          	jalr	784(ra) # 80001222 <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	980080e7          	jalr	-1664(ra) # 800018a2 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	b3c080e7          	jalr	-1220(ra) # 80002a66 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	b5c080e7          	jalr	-1188(ra) # 80002a8e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00005097          	auipc	ra,0x5
    80000f3e:	320080e7          	jalr	800(ra) # 8000625a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	32e080e7          	jalr	814(ra) # 80006270 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	4f8080e7          	jalr	1272(ra) # 80003442 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	b8a080e7          	jalr	-1142(ra) # 80003adc <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	b38080e7          	jalr	-1224(ra) # 80004a92 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	430080e7          	jalr	1072(ra) # 80006392 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	d4a080e7          	jalr	-694(ra) # 80001cb4 <userinit>
    __sync_synchronize();
    80000f72:	0ff0000f          	fence
    started = 1;
    80000f76:	4785                	li	a5,1
    80000f78:	00008717          	auipc	a4,0x8
    80000f7c:	0af72023          	sw	a5,160(a4) # 80009018 <started>
    80000f80:	b789                	j	80000ec2 <main+0x56>

0000000080000f82 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f82:	1141                	addi	sp,sp,-16
    80000f84:	e422                	sd	s0,8(sp)
    80000f86:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f88:	00008797          	auipc	a5,0x8
    80000f8c:	0987b783          	ld	a5,152(a5) # 80009020 <kernel_pagetable>
    80000f90:	83b1                	srli	a5,a5,0xc
    80000f92:	577d                	li	a4,-1
    80000f94:	177e                	slli	a4,a4,0x3f
    80000f96:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f98:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9c:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa0:	6422                	ld	s0,8(sp)
    80000fa2:	0141                	addi	sp,sp,16
    80000fa4:	8082                	ret

0000000080000fa6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fa6:	7139                	addi	sp,sp,-64
    80000fa8:	fc06                	sd	ra,56(sp)
    80000faa:	f822                	sd	s0,48(sp)
    80000fac:	f426                	sd	s1,40(sp)
    80000fae:	f04a                	sd	s2,32(sp)
    80000fb0:	ec4e                	sd	s3,24(sp)
    80000fb2:	e852                	sd	s4,16(sp)
    80000fb4:	e456                	sd	s5,8(sp)
    80000fb6:	e05a                	sd	s6,0(sp)
    80000fb8:	0080                	addi	s0,sp,64
    80000fba:	84aa                	mv	s1,a0
    80000fbc:	89ae                	mv	s3,a1
    80000fbe:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc0:	57fd                	li	a5,-1
    80000fc2:	83e9                	srli	a5,a5,0x1a
    80000fc4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fc6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fc8:	04b7f263          	bgeu	a5,a1,8000100c <walk+0x66>
    panic("walk");
    80000fcc:	00007517          	auipc	a0,0x7
    80000fd0:	10450513          	addi	a0,a0,260 # 800080d0 <digits+0x90>
    80000fd4:	fffff097          	auipc	ra,0xfffff
    80000fd8:	556080e7          	jalr	1366(ra) # 8000052a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fdc:	060a8663          	beqz	s5,80001048 <walk+0xa2>
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	af2080e7          	jalr	-1294(ra) # 80000ad2 <kalloc>
    80000fe8:	84aa                	mv	s1,a0
    80000fea:	c529                	beqz	a0,80001034 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fec:	6605                	lui	a2,0x1
    80000fee:	4581                	li	a1,0
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	cce080e7          	jalr	-818(ra) # 80000cbe <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ff8:	00c4d793          	srli	a5,s1,0xc
    80000ffc:	07aa                	slli	a5,a5,0xa
    80000ffe:	0017e793          	ori	a5,a5,1
    80001002:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001006:	3a5d                	addiw	s4,s4,-9
    80001008:	036a0063          	beq	s4,s6,80001028 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000100c:	0149d933          	srl	s2,s3,s4
    80001010:	1ff97913          	andi	s2,s2,511
    80001014:	090e                	slli	s2,s2,0x3
    80001016:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001018:	00093483          	ld	s1,0(s2)
    8000101c:	0014f793          	andi	a5,s1,1
    80001020:	dfd5                	beqz	a5,80000fdc <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001022:	80a9                	srli	s1,s1,0xa
    80001024:	04b2                	slli	s1,s1,0xc
    80001026:	b7c5                	j	80001006 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001028:	00c9d513          	srli	a0,s3,0xc
    8000102c:	1ff57513          	andi	a0,a0,511
    80001030:	050e                	slli	a0,a0,0x3
    80001032:	9526                	add	a0,a0,s1
}
    80001034:	70e2                	ld	ra,56(sp)
    80001036:	7442                	ld	s0,48(sp)
    80001038:	74a2                	ld	s1,40(sp)
    8000103a:	7902                	ld	s2,32(sp)
    8000103c:	69e2                	ld	s3,24(sp)
    8000103e:	6a42                	ld	s4,16(sp)
    80001040:	6aa2                	ld	s5,8(sp)
    80001042:	6b02                	ld	s6,0(sp)
    80001044:	6121                	addi	sp,sp,64
    80001046:	8082                	ret
        return 0;
    80001048:	4501                	li	a0,0
    8000104a:	b7ed                	j	80001034 <walk+0x8e>

000000008000104c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000104c:	57fd                	li	a5,-1
    8000104e:	83e9                	srli	a5,a5,0x1a
    80001050:	00b7f463          	bgeu	a5,a1,80001058 <walkaddr+0xc>
    return 0;
    80001054:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001056:	8082                	ret
{
    80001058:	1141                	addi	sp,sp,-16
    8000105a:	e406                	sd	ra,8(sp)
    8000105c:	e022                	sd	s0,0(sp)
    8000105e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001060:	4601                	li	a2,0
    80001062:	00000097          	auipc	ra,0x0
    80001066:	f44080e7          	jalr	-188(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000106a:	c105                	beqz	a0,8000108a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000106c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000106e:	0117f693          	andi	a3,a5,17
    80001072:	4745                	li	a4,17
    return 0;
    80001074:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001076:	00e68663          	beq	a3,a4,80001082 <walkaddr+0x36>
}
    8000107a:	60a2                	ld	ra,8(sp)
    8000107c:	6402                	ld	s0,0(sp)
    8000107e:	0141                	addi	sp,sp,16
    80001080:	8082                	ret
  pa = PTE2PA(*pte);
    80001082:	00a7d513          	srli	a0,a5,0xa
    80001086:	0532                	slli	a0,a0,0xc
  return pa;
    80001088:	bfcd                	j	8000107a <walkaddr+0x2e>
    return 0;
    8000108a:	4501                	li	a0,0
    8000108c:	b7fd                	j	8000107a <walkaddr+0x2e>

000000008000108e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000108e:	715d                	addi	sp,sp,-80
    80001090:	e486                	sd	ra,72(sp)
    80001092:	e0a2                	sd	s0,64(sp)
    80001094:	fc26                	sd	s1,56(sp)
    80001096:	f84a                	sd	s2,48(sp)
    80001098:	f44e                	sd	s3,40(sp)
    8000109a:	f052                	sd	s4,32(sp)
    8000109c:	ec56                	sd	s5,24(sp)
    8000109e:	e85a                	sd	s6,16(sp)
    800010a0:	e45e                	sd	s7,8(sp)
    800010a2:	0880                	addi	s0,sp,80
    800010a4:	8aaa                	mv	s5,a0
    800010a6:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010a8:	777d                	lui	a4,0xfffff
    800010aa:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ae:	167d                	addi	a2,a2,-1
    800010b0:	00b609b3          	add	s3,a2,a1
    800010b4:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010b8:	893e                	mv	s2,a5
    800010ba:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010be:	6b85                	lui	s7,0x1
    800010c0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c4:	4605                	li	a2,1
    800010c6:	85ca                	mv	a1,s2
    800010c8:	8556                	mv	a0,s5
    800010ca:	00000097          	auipc	ra,0x0
    800010ce:	edc080e7          	jalr	-292(ra) # 80000fa6 <walk>
    800010d2:	c51d                	beqz	a0,80001100 <mappages+0x72>
    if(*pte & PTE_V)
    800010d4:	611c                	ld	a5,0(a0)
    800010d6:	8b85                	andi	a5,a5,1
    800010d8:	ef81                	bnez	a5,800010f0 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010da:	80b1                	srli	s1,s1,0xc
    800010dc:	04aa                	slli	s1,s1,0xa
    800010de:	0164e4b3          	or	s1,s1,s6
    800010e2:	0014e493          	ori	s1,s1,1
    800010e6:	e104                	sd	s1,0(a0)
    if(a == last)
    800010e8:	03390863          	beq	s2,s3,80001118 <mappages+0x8a>
    a += PGSIZE;
    800010ec:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010ee:	bfc9                	j	800010c0 <mappages+0x32>
      panic("remap");
    800010f0:	00007517          	auipc	a0,0x7
    800010f4:	fe850513          	addi	a0,a0,-24 # 800080d8 <digits+0x98>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	432080e7          	jalr	1074(ra) # 8000052a <panic>
      return -1;
    80001100:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001102:	60a6                	ld	ra,72(sp)
    80001104:	6406                	ld	s0,64(sp)
    80001106:	74e2                	ld	s1,56(sp)
    80001108:	7942                	ld	s2,48(sp)
    8000110a:	79a2                	ld	s3,40(sp)
    8000110c:	7a02                	ld	s4,32(sp)
    8000110e:	6ae2                	ld	s5,24(sp)
    80001110:	6b42                	ld	s6,16(sp)
    80001112:	6ba2                	ld	s7,8(sp)
    80001114:	6161                	addi	sp,sp,80
    80001116:	8082                	ret
  return 0;
    80001118:	4501                	li	a0,0
    8000111a:	b7e5                	j	80001102 <mappages+0x74>

000000008000111c <kvmmap>:
{
    8000111c:	1141                	addi	sp,sp,-16
    8000111e:	e406                	sd	ra,8(sp)
    80001120:	e022                	sd	s0,0(sp)
    80001122:	0800                	addi	s0,sp,16
    80001124:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001126:	86b2                	mv	a3,a2
    80001128:	863e                	mv	a2,a5
    8000112a:	00000097          	auipc	ra,0x0
    8000112e:	f64080e7          	jalr	-156(ra) # 8000108e <mappages>
    80001132:	e509                	bnez	a0,8000113c <kvmmap+0x20>
}
    80001134:	60a2                	ld	ra,8(sp)
    80001136:	6402                	ld	s0,0(sp)
    80001138:	0141                	addi	sp,sp,16
    8000113a:	8082                	ret
    panic("kvmmap");
    8000113c:	00007517          	auipc	a0,0x7
    80001140:	fa450513          	addi	a0,a0,-92 # 800080e0 <digits+0xa0>
    80001144:	fffff097          	auipc	ra,0xfffff
    80001148:	3e6080e7          	jalr	998(ra) # 8000052a <panic>

000000008000114c <kvmmake>:
{
    8000114c:	1101                	addi	sp,sp,-32
    8000114e:	ec06                	sd	ra,24(sp)
    80001150:	e822                	sd	s0,16(sp)
    80001152:	e426                	sd	s1,8(sp)
    80001154:	e04a                	sd	s2,0(sp)
    80001156:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001158:	00000097          	auipc	ra,0x0
    8000115c:	97a080e7          	jalr	-1670(ra) # 80000ad2 <kalloc>
    80001160:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001162:	6605                	lui	a2,0x1
    80001164:	4581                	li	a1,0
    80001166:	00000097          	auipc	ra,0x0
    8000116a:	b58080e7          	jalr	-1192(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000116e:	4719                	li	a4,6
    80001170:	6685                	lui	a3,0x1
    80001172:	10000637          	lui	a2,0x10000
    80001176:	100005b7          	lui	a1,0x10000
    8000117a:	8526                	mv	a0,s1
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	fa0080e7          	jalr	-96(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001184:	4719                	li	a4,6
    80001186:	6685                	lui	a3,0x1
    80001188:	10001637          	lui	a2,0x10001
    8000118c:	100015b7          	lui	a1,0x10001
    80001190:	8526                	mv	a0,s1
    80001192:	00000097          	auipc	ra,0x0
    80001196:	f8a080e7          	jalr	-118(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	004006b7          	lui	a3,0x400
    800011a0:	0c000637          	lui	a2,0xc000
    800011a4:	0c0005b7          	lui	a1,0xc000
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f72080e7          	jalr	-142(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011b2:	00007917          	auipc	s2,0x7
    800011b6:	e4e90913          	addi	s2,s2,-434 # 80008000 <etext>
    800011ba:	4729                	li	a4,10
    800011bc:	80007697          	auipc	a3,0x80007
    800011c0:	e4468693          	addi	a3,a3,-444 # 8000 <_entry-0x7fff8000>
    800011c4:	4605                	li	a2,1
    800011c6:	067e                	slli	a2,a2,0x1f
    800011c8:	85b2                	mv	a1,a2
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f50080e7          	jalr	-176(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011d4:	4719                	li	a4,6
    800011d6:	46c5                	li	a3,17
    800011d8:	06ee                	slli	a3,a3,0x1b
    800011da:	412686b3          	sub	a3,a3,s2
    800011de:	864a                	mv	a2,s2
    800011e0:	85ca                	mv	a1,s2
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f38080e7          	jalr	-200(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011ec:	4729                	li	a4,10
    800011ee:	6685                	lui	a3,0x1
    800011f0:	00006617          	auipc	a2,0x6
    800011f4:	e1060613          	addi	a2,a2,-496 # 80007000 <_trampoline>
    800011f8:	040005b7          	lui	a1,0x4000
    800011fc:	15fd                	addi	a1,a1,-1
    800011fe:	05b2                	slli	a1,a1,0xc
    80001200:	8526                	mv	a0,s1
    80001202:	00000097          	auipc	ra,0x0
    80001206:	f1a080e7          	jalr	-230(ra) # 8000111c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000120a:	8526                	mv	a0,s1
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	600080e7          	jalr	1536(ra) # 8000180c <proc_mapstacks>
}
    80001214:	8526                	mv	a0,s1
    80001216:	60e2                	ld	ra,24(sp)
    80001218:	6442                	ld	s0,16(sp)
    8000121a:	64a2                	ld	s1,8(sp)
    8000121c:	6902                	ld	s2,0(sp)
    8000121e:	6105                	addi	sp,sp,32
    80001220:	8082                	ret

0000000080001222 <kvminit>:
{
    80001222:	1141                	addi	sp,sp,-16
    80001224:	e406                	sd	ra,8(sp)
    80001226:	e022                	sd	s0,0(sp)
    80001228:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	f22080e7          	jalr	-222(ra) # 8000114c <kvmmake>
    80001232:	00008797          	auipc	a5,0x8
    80001236:	dea7b723          	sd	a0,-530(a5) # 80009020 <kernel_pagetable>
}
    8000123a:	60a2                	ld	ra,8(sp)
    8000123c:	6402                	ld	s0,0(sp)
    8000123e:	0141                	addi	sp,sp,16
    80001240:	8082                	ret

0000000080001242 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001242:	715d                	addi	sp,sp,-80
    80001244:	e486                	sd	ra,72(sp)
    80001246:	e0a2                	sd	s0,64(sp)
    80001248:	fc26                	sd	s1,56(sp)
    8000124a:	f84a                	sd	s2,48(sp)
    8000124c:	f44e                	sd	s3,40(sp)
    8000124e:	f052                	sd	s4,32(sp)
    80001250:	ec56                	sd	s5,24(sp)
    80001252:	e85a                	sd	s6,16(sp)
    80001254:	e45e                	sd	s7,8(sp)
    80001256:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001258:	03459793          	slli	a5,a1,0x34
    8000125c:	e795                	bnez	a5,80001288 <uvmunmap+0x46>
    8000125e:	8a2a                	mv	s4,a0
    80001260:	892e                	mv	s2,a1
    80001262:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001264:	0632                	slli	a2,a2,0xc
    80001266:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000126a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000126c:	6b05                	lui	s6,0x1
    8000126e:	0735e263          	bltu	a1,s3,800012d2 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001272:	60a6                	ld	ra,72(sp)
    80001274:	6406                	ld	s0,64(sp)
    80001276:	74e2                	ld	s1,56(sp)
    80001278:	7942                	ld	s2,48(sp)
    8000127a:	79a2                	ld	s3,40(sp)
    8000127c:	7a02                	ld	s4,32(sp)
    8000127e:	6ae2                	ld	s5,24(sp)
    80001280:	6b42                	ld	s6,16(sp)
    80001282:	6ba2                	ld	s7,8(sp)
    80001284:	6161                	addi	sp,sp,80
    80001286:	8082                	ret
    panic("uvmunmap: not aligned");
    80001288:	00007517          	auipc	a0,0x7
    8000128c:	e6050513          	addi	a0,a0,-416 # 800080e8 <digits+0xa8>
    80001290:	fffff097          	auipc	ra,0xfffff
    80001294:	29a080e7          	jalr	666(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    80001298:	00007517          	auipc	a0,0x7
    8000129c:	e6850513          	addi	a0,a0,-408 # 80008100 <digits+0xc0>
    800012a0:	fffff097          	auipc	ra,0xfffff
    800012a4:	28a080e7          	jalr	650(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    800012a8:	00007517          	auipc	a0,0x7
    800012ac:	e6850513          	addi	a0,a0,-408 # 80008110 <digits+0xd0>
    800012b0:	fffff097          	auipc	ra,0xfffff
    800012b4:	27a080e7          	jalr	634(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    800012b8:	00007517          	auipc	a0,0x7
    800012bc:	e7050513          	addi	a0,a0,-400 # 80008128 <digits+0xe8>
    800012c0:	fffff097          	auipc	ra,0xfffff
    800012c4:	26a080e7          	jalr	618(ra) # 8000052a <panic>
    *pte = 0;
    800012c8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012cc:	995a                	add	s2,s2,s6
    800012ce:	fb3972e3          	bgeu	s2,s3,80001272 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012d2:	4601                	li	a2,0
    800012d4:	85ca                	mv	a1,s2
    800012d6:	8552                	mv	a0,s4
    800012d8:	00000097          	auipc	ra,0x0
    800012dc:	cce080e7          	jalr	-818(ra) # 80000fa6 <walk>
    800012e0:	84aa                	mv	s1,a0
    800012e2:	d95d                	beqz	a0,80001298 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012e4:	6108                	ld	a0,0(a0)
    800012e6:	00157793          	andi	a5,a0,1
    800012ea:	dfdd                	beqz	a5,800012a8 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800012ec:	3ff57793          	andi	a5,a0,1023
    800012f0:	fd7784e3          	beq	a5,s7,800012b8 <uvmunmap+0x76>
    if(do_free){
    800012f4:	fc0a8ae3          	beqz	s5,800012c8 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800012f8:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012fa:	0532                	slli	a0,a0,0xc
    800012fc:	fffff097          	auipc	ra,0xfffff
    80001300:	6da080e7          	jalr	1754(ra) # 800009d6 <kfree>
    80001304:	b7d1                	j	800012c8 <uvmunmap+0x86>

0000000080001306 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001306:	1101                	addi	sp,sp,-32
    80001308:	ec06                	sd	ra,24(sp)
    8000130a:	e822                	sd	s0,16(sp)
    8000130c:	e426                	sd	s1,8(sp)
    8000130e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001310:	fffff097          	auipc	ra,0xfffff
    80001314:	7c2080e7          	jalr	1986(ra) # 80000ad2 <kalloc>
    80001318:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000131a:	c519                	beqz	a0,80001328 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000131c:	6605                	lui	a2,0x1
    8000131e:	4581                	li	a1,0
    80001320:	00000097          	auipc	ra,0x0
    80001324:	99e080e7          	jalr	-1634(ra) # 80000cbe <memset>
  return pagetable;
}
    80001328:	8526                	mv	a0,s1
    8000132a:	60e2                	ld	ra,24(sp)
    8000132c:	6442                	ld	s0,16(sp)
    8000132e:	64a2                	ld	s1,8(sp)
    80001330:	6105                	addi	sp,sp,32
    80001332:	8082                	ret

0000000080001334 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001334:	7179                	addi	sp,sp,-48
    80001336:	f406                	sd	ra,40(sp)
    80001338:	f022                	sd	s0,32(sp)
    8000133a:	ec26                	sd	s1,24(sp)
    8000133c:	e84a                	sd	s2,16(sp)
    8000133e:	e44e                	sd	s3,8(sp)
    80001340:	e052                	sd	s4,0(sp)
    80001342:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001344:	6785                	lui	a5,0x1
    80001346:	04f67863          	bgeu	a2,a5,80001396 <uvminit+0x62>
    8000134a:	8a2a                	mv	s4,a0
    8000134c:	89ae                	mv	s3,a1
    8000134e:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001350:	fffff097          	auipc	ra,0xfffff
    80001354:	782080e7          	jalr	1922(ra) # 80000ad2 <kalloc>
    80001358:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000135a:	6605                	lui	a2,0x1
    8000135c:	4581                	li	a1,0
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	960080e7          	jalr	-1696(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001366:	4779                	li	a4,30
    80001368:	86ca                	mv	a3,s2
    8000136a:	6605                	lui	a2,0x1
    8000136c:	4581                	li	a1,0
    8000136e:	8552                	mv	a0,s4
    80001370:	00000097          	auipc	ra,0x0
    80001374:	d1e080e7          	jalr	-738(ra) # 8000108e <mappages>
  memmove(mem, src, sz);
    80001378:	8626                	mv	a2,s1
    8000137a:	85ce                	mv	a1,s3
    8000137c:	854a                	mv	a0,s2
    8000137e:	00000097          	auipc	ra,0x0
    80001382:	99c080e7          	jalr	-1636(ra) # 80000d1a <memmove>
}
    80001386:	70a2                	ld	ra,40(sp)
    80001388:	7402                	ld	s0,32(sp)
    8000138a:	64e2                	ld	s1,24(sp)
    8000138c:	6942                	ld	s2,16(sp)
    8000138e:	69a2                	ld	s3,8(sp)
    80001390:	6a02                	ld	s4,0(sp)
    80001392:	6145                	addi	sp,sp,48
    80001394:	8082                	ret
    panic("inituvm: more than a page");
    80001396:	00007517          	auipc	a0,0x7
    8000139a:	daa50513          	addi	a0,a0,-598 # 80008140 <digits+0x100>
    8000139e:	fffff097          	auipc	ra,0xfffff
    800013a2:	18c080e7          	jalr	396(ra) # 8000052a <panic>

00000000800013a6 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013a6:	1101                	addi	sp,sp,-32
    800013a8:	ec06                	sd	ra,24(sp)
    800013aa:	e822                	sd	s0,16(sp)
    800013ac:	e426                	sd	s1,8(sp)
    800013ae:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013b0:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013b2:	00b67d63          	bgeu	a2,a1,800013cc <uvmdealloc+0x26>
    800013b6:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013b8:	6785                	lui	a5,0x1
    800013ba:	17fd                	addi	a5,a5,-1
    800013bc:	00f60733          	add	a4,a2,a5
    800013c0:	767d                	lui	a2,0xfffff
    800013c2:	8f71                	and	a4,a4,a2
    800013c4:	97ae                	add	a5,a5,a1
    800013c6:	8ff1                	and	a5,a5,a2
    800013c8:	00f76863          	bltu	a4,a5,800013d8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013cc:	8526                	mv	a0,s1
    800013ce:	60e2                	ld	ra,24(sp)
    800013d0:	6442                	ld	s0,16(sp)
    800013d2:	64a2                	ld	s1,8(sp)
    800013d4:	6105                	addi	sp,sp,32
    800013d6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013d8:	8f99                	sub	a5,a5,a4
    800013da:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013dc:	4685                	li	a3,1
    800013de:	0007861b          	sext.w	a2,a5
    800013e2:	85ba                	mv	a1,a4
    800013e4:	00000097          	auipc	ra,0x0
    800013e8:	e5e080e7          	jalr	-418(ra) # 80001242 <uvmunmap>
    800013ec:	b7c5                	j	800013cc <uvmdealloc+0x26>

00000000800013ee <uvmalloc>:
  if(newsz < oldsz)
    800013ee:	0ab66163          	bltu	a2,a1,80001490 <uvmalloc+0xa2>
{
    800013f2:	7139                	addi	sp,sp,-64
    800013f4:	fc06                	sd	ra,56(sp)
    800013f6:	f822                	sd	s0,48(sp)
    800013f8:	f426                	sd	s1,40(sp)
    800013fa:	f04a                	sd	s2,32(sp)
    800013fc:	ec4e                	sd	s3,24(sp)
    800013fe:	e852                	sd	s4,16(sp)
    80001400:	e456                	sd	s5,8(sp)
    80001402:	0080                	addi	s0,sp,64
    80001404:	8aaa                	mv	s5,a0
    80001406:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001408:	6985                	lui	s3,0x1
    8000140a:	19fd                	addi	s3,s3,-1
    8000140c:	95ce                	add	a1,a1,s3
    8000140e:	79fd                	lui	s3,0xfffff
    80001410:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001414:	08c9f063          	bgeu	s3,a2,80001494 <uvmalloc+0xa6>
    80001418:	894e                	mv	s2,s3
    mem = kalloc();
    8000141a:	fffff097          	auipc	ra,0xfffff
    8000141e:	6b8080e7          	jalr	1720(ra) # 80000ad2 <kalloc>
    80001422:	84aa                	mv	s1,a0
    if(mem == 0){
    80001424:	c51d                	beqz	a0,80001452 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001426:	6605                	lui	a2,0x1
    80001428:	4581                	li	a1,0
    8000142a:	00000097          	auipc	ra,0x0
    8000142e:	894080e7          	jalr	-1900(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001432:	4779                	li	a4,30
    80001434:	86a6                	mv	a3,s1
    80001436:	6605                	lui	a2,0x1
    80001438:	85ca                	mv	a1,s2
    8000143a:	8556                	mv	a0,s5
    8000143c:	00000097          	auipc	ra,0x0
    80001440:	c52080e7          	jalr	-942(ra) # 8000108e <mappages>
    80001444:	e905                	bnez	a0,80001474 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001446:	6785                	lui	a5,0x1
    80001448:	993e                	add	s2,s2,a5
    8000144a:	fd4968e3          	bltu	s2,s4,8000141a <uvmalloc+0x2c>
  return newsz;
    8000144e:	8552                	mv	a0,s4
    80001450:	a809                	j	80001462 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001452:	864e                	mv	a2,s3
    80001454:	85ca                	mv	a1,s2
    80001456:	8556                	mv	a0,s5
    80001458:	00000097          	auipc	ra,0x0
    8000145c:	f4e080e7          	jalr	-178(ra) # 800013a6 <uvmdealloc>
      return 0;
    80001460:	4501                	li	a0,0
}
    80001462:	70e2                	ld	ra,56(sp)
    80001464:	7442                	ld	s0,48(sp)
    80001466:	74a2                	ld	s1,40(sp)
    80001468:	7902                	ld	s2,32(sp)
    8000146a:	69e2                	ld	s3,24(sp)
    8000146c:	6a42                	ld	s4,16(sp)
    8000146e:	6aa2                	ld	s5,8(sp)
    80001470:	6121                	addi	sp,sp,64
    80001472:	8082                	ret
      kfree(mem);
    80001474:	8526                	mv	a0,s1
    80001476:	fffff097          	auipc	ra,0xfffff
    8000147a:	560080e7          	jalr	1376(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000147e:	864e                	mv	a2,s3
    80001480:	85ca                	mv	a1,s2
    80001482:	8556                	mv	a0,s5
    80001484:	00000097          	auipc	ra,0x0
    80001488:	f22080e7          	jalr	-222(ra) # 800013a6 <uvmdealloc>
      return 0;
    8000148c:	4501                	li	a0,0
    8000148e:	bfd1                	j	80001462 <uvmalloc+0x74>
    return oldsz;
    80001490:	852e                	mv	a0,a1
}
    80001492:	8082                	ret
  return newsz;
    80001494:	8532                	mv	a0,a2
    80001496:	b7f1                	j	80001462 <uvmalloc+0x74>

0000000080001498 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001498:	7179                	addi	sp,sp,-48
    8000149a:	f406                	sd	ra,40(sp)
    8000149c:	f022                	sd	s0,32(sp)
    8000149e:	ec26                	sd	s1,24(sp)
    800014a0:	e84a                	sd	s2,16(sp)
    800014a2:	e44e                	sd	s3,8(sp)
    800014a4:	e052                	sd	s4,0(sp)
    800014a6:	1800                	addi	s0,sp,48
    800014a8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014aa:	84aa                	mv	s1,a0
    800014ac:	6905                	lui	s2,0x1
    800014ae:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014b0:	4985                	li	s3,1
    800014b2:	a821                	j	800014ca <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014b4:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014b6:	0532                	slli	a0,a0,0xc
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	fe0080e7          	jalr	-32(ra) # 80001498 <freewalk>
      pagetable[i] = 0;
    800014c0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014c4:	04a1                	addi	s1,s1,8
    800014c6:	03248163          	beq	s1,s2,800014e8 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014ca:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014cc:	00f57793          	andi	a5,a0,15
    800014d0:	ff3782e3          	beq	a5,s3,800014b4 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014d4:	8905                	andi	a0,a0,1
    800014d6:	d57d                	beqz	a0,800014c4 <freewalk+0x2c>
      panic("freewalk: leaf");
    800014d8:	00007517          	auipc	a0,0x7
    800014dc:	c8850513          	addi	a0,a0,-888 # 80008160 <digits+0x120>
    800014e0:	fffff097          	auipc	ra,0xfffff
    800014e4:	04a080e7          	jalr	74(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    800014e8:	8552                	mv	a0,s4
    800014ea:	fffff097          	auipc	ra,0xfffff
    800014ee:	4ec080e7          	jalr	1260(ra) # 800009d6 <kfree>
}
    800014f2:	70a2                	ld	ra,40(sp)
    800014f4:	7402                	ld	s0,32(sp)
    800014f6:	64e2                	ld	s1,24(sp)
    800014f8:	6942                	ld	s2,16(sp)
    800014fa:	69a2                	ld	s3,8(sp)
    800014fc:	6a02                	ld	s4,0(sp)
    800014fe:	6145                	addi	sp,sp,48
    80001500:	8082                	ret

0000000080001502 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001502:	1101                	addi	sp,sp,-32
    80001504:	ec06                	sd	ra,24(sp)
    80001506:	e822                	sd	s0,16(sp)
    80001508:	e426                	sd	s1,8(sp)
    8000150a:	1000                	addi	s0,sp,32
    8000150c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000150e:	e999                	bnez	a1,80001524 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001510:	8526                	mv	a0,s1
    80001512:	00000097          	auipc	ra,0x0
    80001516:	f86080e7          	jalr	-122(ra) # 80001498 <freewalk>
}
    8000151a:	60e2                	ld	ra,24(sp)
    8000151c:	6442                	ld	s0,16(sp)
    8000151e:	64a2                	ld	s1,8(sp)
    80001520:	6105                	addi	sp,sp,32
    80001522:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001524:	6605                	lui	a2,0x1
    80001526:	167d                	addi	a2,a2,-1
    80001528:	962e                	add	a2,a2,a1
    8000152a:	4685                	li	a3,1
    8000152c:	8231                	srli	a2,a2,0xc
    8000152e:	4581                	li	a1,0
    80001530:	00000097          	auipc	ra,0x0
    80001534:	d12080e7          	jalr	-750(ra) # 80001242 <uvmunmap>
    80001538:	bfe1                	j	80001510 <uvmfree+0xe>

000000008000153a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000153a:	c679                	beqz	a2,80001608 <uvmcopy+0xce>
{
    8000153c:	715d                	addi	sp,sp,-80
    8000153e:	e486                	sd	ra,72(sp)
    80001540:	e0a2                	sd	s0,64(sp)
    80001542:	fc26                	sd	s1,56(sp)
    80001544:	f84a                	sd	s2,48(sp)
    80001546:	f44e                	sd	s3,40(sp)
    80001548:	f052                	sd	s4,32(sp)
    8000154a:	ec56                	sd	s5,24(sp)
    8000154c:	e85a                	sd	s6,16(sp)
    8000154e:	e45e                	sd	s7,8(sp)
    80001550:	0880                	addi	s0,sp,80
    80001552:	8b2a                	mv	s6,a0
    80001554:	8aae                	mv	s5,a1
    80001556:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001558:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000155a:	4601                	li	a2,0
    8000155c:	85ce                	mv	a1,s3
    8000155e:	855a                	mv	a0,s6
    80001560:	00000097          	auipc	ra,0x0
    80001564:	a46080e7          	jalr	-1466(ra) # 80000fa6 <walk>
    80001568:	c531                	beqz	a0,800015b4 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000156a:	6118                	ld	a4,0(a0)
    8000156c:	00177793          	andi	a5,a4,1
    80001570:	cbb1                	beqz	a5,800015c4 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001572:	00a75593          	srli	a1,a4,0xa
    80001576:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000157a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000157e:	fffff097          	auipc	ra,0xfffff
    80001582:	554080e7          	jalr	1364(ra) # 80000ad2 <kalloc>
    80001586:	892a                	mv	s2,a0
    80001588:	c939                	beqz	a0,800015de <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000158a:	6605                	lui	a2,0x1
    8000158c:	85de                	mv	a1,s7
    8000158e:	fffff097          	auipc	ra,0xfffff
    80001592:	78c080e7          	jalr	1932(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001596:	8726                	mv	a4,s1
    80001598:	86ca                	mv	a3,s2
    8000159a:	6605                	lui	a2,0x1
    8000159c:	85ce                	mv	a1,s3
    8000159e:	8556                	mv	a0,s5
    800015a0:	00000097          	auipc	ra,0x0
    800015a4:	aee080e7          	jalr	-1298(ra) # 8000108e <mappages>
    800015a8:	e515                	bnez	a0,800015d4 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015aa:	6785                	lui	a5,0x1
    800015ac:	99be                	add	s3,s3,a5
    800015ae:	fb49e6e3          	bltu	s3,s4,8000155a <uvmcopy+0x20>
    800015b2:	a081                	j	800015f2 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015b4:	00007517          	auipc	a0,0x7
    800015b8:	bbc50513          	addi	a0,a0,-1092 # 80008170 <digits+0x130>
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	f6e080e7          	jalr	-146(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    800015c4:	00007517          	auipc	a0,0x7
    800015c8:	bcc50513          	addi	a0,a0,-1076 # 80008190 <digits+0x150>
    800015cc:	fffff097          	auipc	ra,0xfffff
    800015d0:	f5e080e7          	jalr	-162(ra) # 8000052a <panic>
      kfree(mem);
    800015d4:	854a                	mv	a0,s2
    800015d6:	fffff097          	auipc	ra,0xfffff
    800015da:	400080e7          	jalr	1024(ra) # 800009d6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015de:	4685                	li	a3,1
    800015e0:	00c9d613          	srli	a2,s3,0xc
    800015e4:	4581                	li	a1,0
    800015e6:	8556                	mv	a0,s5
    800015e8:	00000097          	auipc	ra,0x0
    800015ec:	c5a080e7          	jalr	-934(ra) # 80001242 <uvmunmap>
  return -1;
    800015f0:	557d                	li	a0,-1
}
    800015f2:	60a6                	ld	ra,72(sp)
    800015f4:	6406                	ld	s0,64(sp)
    800015f6:	74e2                	ld	s1,56(sp)
    800015f8:	7942                	ld	s2,48(sp)
    800015fa:	79a2                	ld	s3,40(sp)
    800015fc:	7a02                	ld	s4,32(sp)
    800015fe:	6ae2                	ld	s5,24(sp)
    80001600:	6b42                	ld	s6,16(sp)
    80001602:	6ba2                	ld	s7,8(sp)
    80001604:	6161                	addi	sp,sp,80
    80001606:	8082                	ret
  return 0;
    80001608:	4501                	li	a0,0
}
    8000160a:	8082                	ret

000000008000160c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000160c:	1141                	addi	sp,sp,-16
    8000160e:	e406                	sd	ra,8(sp)
    80001610:	e022                	sd	s0,0(sp)
    80001612:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001614:	4601                	li	a2,0
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	990080e7          	jalr	-1648(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000161e:	c901                	beqz	a0,8000162e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001620:	611c                	ld	a5,0(a0)
    80001622:	9bbd                	andi	a5,a5,-17
    80001624:	e11c                	sd	a5,0(a0)
}
    80001626:	60a2                	ld	ra,8(sp)
    80001628:	6402                	ld	s0,0(sp)
    8000162a:	0141                	addi	sp,sp,16
    8000162c:	8082                	ret
    panic("uvmclear");
    8000162e:	00007517          	auipc	a0,0x7
    80001632:	b8250513          	addi	a0,a0,-1150 # 800081b0 <digits+0x170>
    80001636:	fffff097          	auipc	ra,0xfffff
    8000163a:	ef4080e7          	jalr	-268(ra) # 8000052a <panic>

000000008000163e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000163e:	c6bd                	beqz	a3,800016ac <copyout+0x6e>
{
    80001640:	715d                	addi	sp,sp,-80
    80001642:	e486                	sd	ra,72(sp)
    80001644:	e0a2                	sd	s0,64(sp)
    80001646:	fc26                	sd	s1,56(sp)
    80001648:	f84a                	sd	s2,48(sp)
    8000164a:	f44e                	sd	s3,40(sp)
    8000164c:	f052                	sd	s4,32(sp)
    8000164e:	ec56                	sd	s5,24(sp)
    80001650:	e85a                	sd	s6,16(sp)
    80001652:	e45e                	sd	s7,8(sp)
    80001654:	e062                	sd	s8,0(sp)
    80001656:	0880                	addi	s0,sp,80
    80001658:	8b2a                	mv	s6,a0
    8000165a:	8c2e                	mv	s8,a1
    8000165c:	8a32                	mv	s4,a2
    8000165e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001660:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001662:	6a85                	lui	s5,0x1
    80001664:	a015                	j	80001688 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001666:	9562                	add	a0,a0,s8
    80001668:	0004861b          	sext.w	a2,s1
    8000166c:	85d2                	mv	a1,s4
    8000166e:	41250533          	sub	a0,a0,s2
    80001672:	fffff097          	auipc	ra,0xfffff
    80001676:	6a8080e7          	jalr	1704(ra) # 80000d1a <memmove>

    len -= n;
    8000167a:	409989b3          	sub	s3,s3,s1
    src += n;
    8000167e:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001680:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001684:	02098263          	beqz	s3,800016a8 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001688:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000168c:	85ca                	mv	a1,s2
    8000168e:	855a                	mv	a0,s6
    80001690:	00000097          	auipc	ra,0x0
    80001694:	9bc080e7          	jalr	-1604(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001698:	cd01                	beqz	a0,800016b0 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000169a:	418904b3          	sub	s1,s2,s8
    8000169e:	94d6                	add	s1,s1,s5
    if(n > len)
    800016a0:	fc99f3e3          	bgeu	s3,s1,80001666 <copyout+0x28>
    800016a4:	84ce                	mv	s1,s3
    800016a6:	b7c1                	j	80001666 <copyout+0x28>
  }
  return 0;
    800016a8:	4501                	li	a0,0
    800016aa:	a021                	j	800016b2 <copyout+0x74>
    800016ac:	4501                	li	a0,0
}
    800016ae:	8082                	ret
      return -1;
    800016b0:	557d                	li	a0,-1
}
    800016b2:	60a6                	ld	ra,72(sp)
    800016b4:	6406                	ld	s0,64(sp)
    800016b6:	74e2                	ld	s1,56(sp)
    800016b8:	7942                	ld	s2,48(sp)
    800016ba:	79a2                	ld	s3,40(sp)
    800016bc:	7a02                	ld	s4,32(sp)
    800016be:	6ae2                	ld	s5,24(sp)
    800016c0:	6b42                	ld	s6,16(sp)
    800016c2:	6ba2                	ld	s7,8(sp)
    800016c4:	6c02                	ld	s8,0(sp)
    800016c6:	6161                	addi	sp,sp,80
    800016c8:	8082                	ret

00000000800016ca <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016ca:	caa5                	beqz	a3,8000173a <copyin+0x70>
{
    800016cc:	715d                	addi	sp,sp,-80
    800016ce:	e486                	sd	ra,72(sp)
    800016d0:	e0a2                	sd	s0,64(sp)
    800016d2:	fc26                	sd	s1,56(sp)
    800016d4:	f84a                	sd	s2,48(sp)
    800016d6:	f44e                	sd	s3,40(sp)
    800016d8:	f052                	sd	s4,32(sp)
    800016da:	ec56                	sd	s5,24(sp)
    800016dc:	e85a                	sd	s6,16(sp)
    800016de:	e45e                	sd	s7,8(sp)
    800016e0:	e062                	sd	s8,0(sp)
    800016e2:	0880                	addi	s0,sp,80
    800016e4:	8b2a                	mv	s6,a0
    800016e6:	8a2e                	mv	s4,a1
    800016e8:	8c32                	mv	s8,a2
    800016ea:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800016ec:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016ee:	6a85                	lui	s5,0x1
    800016f0:	a01d                	j	80001716 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016f2:	018505b3          	add	a1,a0,s8
    800016f6:	0004861b          	sext.w	a2,s1
    800016fa:	412585b3          	sub	a1,a1,s2
    800016fe:	8552                	mv	a0,s4
    80001700:	fffff097          	auipc	ra,0xfffff
    80001704:	61a080e7          	jalr	1562(ra) # 80000d1a <memmove>

    len -= n;
    80001708:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000170c:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000170e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001712:	02098263          	beqz	s3,80001736 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001716:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000171a:	85ca                	mv	a1,s2
    8000171c:	855a                	mv	a0,s6
    8000171e:	00000097          	auipc	ra,0x0
    80001722:	92e080e7          	jalr	-1746(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001726:	cd01                	beqz	a0,8000173e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001728:	418904b3          	sub	s1,s2,s8
    8000172c:	94d6                	add	s1,s1,s5
    if(n > len)
    8000172e:	fc99f2e3          	bgeu	s3,s1,800016f2 <copyin+0x28>
    80001732:	84ce                	mv	s1,s3
    80001734:	bf7d                	j	800016f2 <copyin+0x28>
  }
  return 0;
    80001736:	4501                	li	a0,0
    80001738:	a021                	j	80001740 <copyin+0x76>
    8000173a:	4501                	li	a0,0
}
    8000173c:	8082                	ret
      return -1;
    8000173e:	557d                	li	a0,-1
}
    80001740:	60a6                	ld	ra,72(sp)
    80001742:	6406                	ld	s0,64(sp)
    80001744:	74e2                	ld	s1,56(sp)
    80001746:	7942                	ld	s2,48(sp)
    80001748:	79a2                	ld	s3,40(sp)
    8000174a:	7a02                	ld	s4,32(sp)
    8000174c:	6ae2                	ld	s5,24(sp)
    8000174e:	6b42                	ld	s6,16(sp)
    80001750:	6ba2                	ld	s7,8(sp)
    80001752:	6c02                	ld	s8,0(sp)
    80001754:	6161                	addi	sp,sp,80
    80001756:	8082                	ret

0000000080001758 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001758:	c6c5                	beqz	a3,80001800 <copyinstr+0xa8>
{
    8000175a:	715d                	addi	sp,sp,-80
    8000175c:	e486                	sd	ra,72(sp)
    8000175e:	e0a2                	sd	s0,64(sp)
    80001760:	fc26                	sd	s1,56(sp)
    80001762:	f84a                	sd	s2,48(sp)
    80001764:	f44e                	sd	s3,40(sp)
    80001766:	f052                	sd	s4,32(sp)
    80001768:	ec56                	sd	s5,24(sp)
    8000176a:	e85a                	sd	s6,16(sp)
    8000176c:	e45e                	sd	s7,8(sp)
    8000176e:	0880                	addi	s0,sp,80
    80001770:	8a2a                	mv	s4,a0
    80001772:	8b2e                	mv	s6,a1
    80001774:	8bb2                	mv	s7,a2
    80001776:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001778:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000177a:	6985                	lui	s3,0x1
    8000177c:	a035                	j	800017a8 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000177e:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001782:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001784:	0017b793          	seqz	a5,a5
    80001788:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000178c:	60a6                	ld	ra,72(sp)
    8000178e:	6406                	ld	s0,64(sp)
    80001790:	74e2                	ld	s1,56(sp)
    80001792:	7942                	ld	s2,48(sp)
    80001794:	79a2                	ld	s3,40(sp)
    80001796:	7a02                	ld	s4,32(sp)
    80001798:	6ae2                	ld	s5,24(sp)
    8000179a:	6b42                	ld	s6,16(sp)
    8000179c:	6ba2                	ld	s7,8(sp)
    8000179e:	6161                	addi	sp,sp,80
    800017a0:	8082                	ret
    srcva = va0 + PGSIZE;
    800017a2:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017a6:	c8a9                	beqz	s1,800017f8 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017a8:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017ac:	85ca                	mv	a1,s2
    800017ae:	8552                	mv	a0,s4
    800017b0:	00000097          	auipc	ra,0x0
    800017b4:	89c080e7          	jalr	-1892(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    800017b8:	c131                	beqz	a0,800017fc <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ba:	41790833          	sub	a6,s2,s7
    800017be:	984e                	add	a6,a6,s3
    if(n > max)
    800017c0:	0104f363          	bgeu	s1,a6,800017c6 <copyinstr+0x6e>
    800017c4:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017c6:	955e                	add	a0,a0,s7
    800017c8:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017cc:	fc080be3          	beqz	a6,800017a2 <copyinstr+0x4a>
    800017d0:	985a                	add	a6,a6,s6
    800017d2:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017d4:	41650633          	sub	a2,a0,s6
    800017d8:	14fd                	addi	s1,s1,-1
    800017da:	9b26                	add	s6,s6,s1
    800017dc:	00f60733          	add	a4,a2,a5
    800017e0:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd3000>
    800017e4:	df49                	beqz	a4,8000177e <copyinstr+0x26>
        *dst = *p;
    800017e6:	00e78023          	sb	a4,0(a5)
      --max;
    800017ea:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800017ee:	0785                	addi	a5,a5,1
    while(n > 0){
    800017f0:	ff0796e3          	bne	a5,a6,800017dc <copyinstr+0x84>
      dst++;
    800017f4:	8b42                	mv	s6,a6
    800017f6:	b775                	j	800017a2 <copyinstr+0x4a>
    800017f8:	4781                	li	a5,0
    800017fa:	b769                	j	80001784 <copyinstr+0x2c>
      return -1;
    800017fc:	557d                	li	a0,-1
    800017fe:	b779                	j	8000178c <copyinstr+0x34>
  int got_null = 0;
    80001800:	4781                	li	a5,0
  if(got_null){
    80001802:	0017b793          	seqz	a5,a5
    80001806:	40f00533          	neg	a0,a5
}
    8000180a:	8082                	ret

000000008000180c <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000180c:	7139                	addi	sp,sp,-64
    8000180e:	fc06                	sd	ra,56(sp)
    80001810:	f822                	sd	s0,48(sp)
    80001812:	f426                	sd	s1,40(sp)
    80001814:	f04a                	sd	s2,32(sp)
    80001816:	ec4e                	sd	s3,24(sp)
    80001818:	e852                	sd	s4,16(sp)
    8000181a:	e456                	sd	s5,8(sp)
    8000181c:	e05a                	sd	s6,0(sp)
    8000181e:	0080                	addi	s0,sp,64
    80001820:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001822:	00010497          	auipc	s1,0x10
    80001826:	eae48493          	addi	s1,s1,-338 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000182a:	8b26                	mv	s6,s1
    8000182c:	00006a97          	auipc	s5,0x6
    80001830:	7d4a8a93          	addi	s5,s5,2004 # 80008000 <etext>
    80001834:	04000937          	lui	s2,0x4000
    80001838:	197d                	addi	s2,s2,-1
    8000183a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183c:	0001ca17          	auipc	s4,0x1c
    80001840:	094a0a13          	addi	s4,s4,148 # 8001d8d0 <tickslock>
    char *pa = kalloc();
    80001844:	fffff097          	auipc	ra,0xfffff
    80001848:	28e080e7          	jalr	654(ra) # 80000ad2 <kalloc>
    8000184c:	862a                	mv	a2,a0
    if(pa == 0)
    8000184e:	c131                	beqz	a0,80001892 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001850:	416485b3          	sub	a1,s1,s6
    80001854:	858d                	srai	a1,a1,0x3
    80001856:	000ab783          	ld	a5,0(s5)
    8000185a:	02f585b3          	mul	a1,a1,a5
    8000185e:	2585                	addiw	a1,a1,1
    80001860:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001864:	4719                	li	a4,6
    80001866:	6685                	lui	a3,0x1
    80001868:	40b905b3          	sub	a1,s2,a1
    8000186c:	854e                	mv	a0,s3
    8000186e:	00000097          	auipc	ra,0x0
    80001872:	8ae080e7          	jalr	-1874(ra) # 8000111c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001876:	30848493          	addi	s1,s1,776
    8000187a:	fd4495e3          	bne	s1,s4,80001844 <proc_mapstacks+0x38>
  }
}
    8000187e:	70e2                	ld	ra,56(sp)
    80001880:	7442                	ld	s0,48(sp)
    80001882:	74a2                	ld	s1,40(sp)
    80001884:	7902                	ld	s2,32(sp)
    80001886:	69e2                	ld	s3,24(sp)
    80001888:	6a42                	ld	s4,16(sp)
    8000188a:	6aa2                	ld	s5,8(sp)
    8000188c:	6b02                	ld	s6,0(sp)
    8000188e:	6121                	addi	sp,sp,64
    80001890:	8082                	ret
      panic("kalloc");
    80001892:	00007517          	auipc	a0,0x7
    80001896:	92e50513          	addi	a0,a0,-1746 # 800081c0 <digits+0x180>
    8000189a:	fffff097          	auipc	ra,0xfffff
    8000189e:	c90080e7          	jalr	-880(ra) # 8000052a <panic>

00000000800018a2 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018a2:	7139                	addi	sp,sp,-64
    800018a4:	fc06                	sd	ra,56(sp)
    800018a6:	f822                	sd	s0,48(sp)
    800018a8:	f426                	sd	s1,40(sp)
    800018aa:	f04a                	sd	s2,32(sp)
    800018ac:	ec4e                	sd	s3,24(sp)
    800018ae:	e852                	sd	s4,16(sp)
    800018b0:	e456                	sd	s5,8(sp)
    800018b2:	e05a                	sd	s6,0(sp)
    800018b4:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018b6:	00007597          	auipc	a1,0x7
    800018ba:	91258593          	addi	a1,a1,-1774 # 800081c8 <digits+0x188>
    800018be:	00010517          	auipc	a0,0x10
    800018c2:	9e250513          	addi	a0,a0,-1566 # 800112a0 <pid_lock>
    800018c6:	fffff097          	auipc	ra,0xfffff
    800018ca:	26c080e7          	jalr	620(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018ce:	00007597          	auipc	a1,0x7
    800018d2:	90258593          	addi	a1,a1,-1790 # 800081d0 <digits+0x190>
    800018d6:	00010517          	auipc	a0,0x10
    800018da:	9e250513          	addi	a0,a0,-1566 # 800112b8 <wait_lock>
    800018de:	fffff097          	auipc	ra,0xfffff
    800018e2:	254080e7          	jalr	596(ra) # 80000b32 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e6:	00010497          	auipc	s1,0x10
    800018ea:	dea48493          	addi	s1,s1,-534 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    800018ee:	00007b17          	auipc	s6,0x7
    800018f2:	8f2b0b13          	addi	s6,s6,-1806 # 800081e0 <digits+0x1a0>
      p->kstack = KSTACK((int) (p - proc));
    800018f6:	8aa6                	mv	s5,s1
    800018f8:	00006a17          	auipc	s4,0x6
    800018fc:	708a0a13          	addi	s4,s4,1800 # 80008000 <etext>
    80001900:	04000937          	lui	s2,0x4000
    80001904:	197d                	addi	s2,s2,-1
    80001906:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001908:	0001c997          	auipc	s3,0x1c
    8000190c:	fc898993          	addi	s3,s3,-56 # 8001d8d0 <tickslock>
      initlock(&p->lock, "proc");
    80001910:	85da                	mv	a1,s6
    80001912:	8526                	mv	a0,s1
    80001914:	fffff097          	auipc	ra,0xfffff
    80001918:	21e080e7          	jalr	542(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    8000191c:	415487b3          	sub	a5,s1,s5
    80001920:	878d                	srai	a5,a5,0x3
    80001922:	000a3703          	ld	a4,0(s4)
    80001926:	02e787b3          	mul	a5,a5,a4
    8000192a:	2785                	addiw	a5,a5,1
    8000192c:	00d7979b          	slliw	a5,a5,0xd
    80001930:	40f907b3          	sub	a5,s2,a5
    80001934:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001936:	30848493          	addi	s1,s1,776
    8000193a:	fd349be3          	bne	s1,s3,80001910 <procinit+0x6e>
  }
}
    8000193e:	70e2                	ld	ra,56(sp)
    80001940:	7442                	ld	s0,48(sp)
    80001942:	74a2                	ld	s1,40(sp)
    80001944:	7902                	ld	s2,32(sp)
    80001946:	69e2                	ld	s3,24(sp)
    80001948:	6a42                	ld	s4,16(sp)
    8000194a:	6aa2                	ld	s5,8(sp)
    8000194c:	6b02                	ld	s6,0(sp)
    8000194e:	6121                	addi	sp,sp,64
    80001950:	8082                	ret

0000000080001952 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001952:	1141                	addi	sp,sp,-16
    80001954:	e422                	sd	s0,8(sp)
    80001956:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001958:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000195a:	2501                	sext.w	a0,a0
    8000195c:	6422                	ld	s0,8(sp)
    8000195e:	0141                	addi	sp,sp,16
    80001960:	8082                	ret

0000000080001962 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001962:	1141                	addi	sp,sp,-16
    80001964:	e422                	sd	s0,8(sp)
    80001966:	0800                	addi	s0,sp,16
    80001968:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000196a:	2781                	sext.w	a5,a5
    8000196c:	079e                	slli	a5,a5,0x7
  return c;
}
    8000196e:	00010517          	auipc	a0,0x10
    80001972:	96250513          	addi	a0,a0,-1694 # 800112d0 <cpus>
    80001976:	953e                	add	a0,a0,a5
    80001978:	6422                	ld	s0,8(sp)
    8000197a:	0141                	addi	sp,sp,16
    8000197c:	8082                	ret

000000008000197e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    8000197e:	1101                	addi	sp,sp,-32
    80001980:	ec06                	sd	ra,24(sp)
    80001982:	e822                	sd	s0,16(sp)
    80001984:	e426                	sd	s1,8(sp)
    80001986:	1000                	addi	s0,sp,32
  push_off();
    80001988:	fffff097          	auipc	ra,0xfffff
    8000198c:	1ee080e7          	jalr	494(ra) # 80000b76 <push_off>
    80001990:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001992:	2781                	sext.w	a5,a5
    80001994:	079e                	slli	a5,a5,0x7
    80001996:	00010717          	auipc	a4,0x10
    8000199a:	90a70713          	addi	a4,a4,-1782 # 800112a0 <pid_lock>
    8000199e:	97ba                	add	a5,a5,a4
    800019a0:	7b84                	ld	s1,48(a5)
  //  struct proc *p = c->thread->parent_proc;
  pop_off();
    800019a2:	fffff097          	auipc	ra,0xfffff
    800019a6:	274080e7          	jalr	628(ra) # 80000c16 <pop_off>
  return p;
}
    800019aa:	8526                	mv	a0,s1
    800019ac:	60e2                	ld	ra,24(sp)
    800019ae:	6442                	ld	s0,16(sp)
    800019b0:	64a2                	ld	s1,8(sp)
    800019b2:	6105                	addi	sp,sp,32
    800019b4:	8082                	ret

00000000800019b6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019b6:	1141                	addi	sp,sp,-16
    800019b8:	e406                	sd	ra,8(sp)
    800019ba:	e022                	sd	s0,0(sp)
    800019bc:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019be:	00000097          	auipc	ra,0x0
    800019c2:	fc0080e7          	jalr	-64(ra) # 8000197e <myproc>
    800019c6:	fffff097          	auipc	ra,0xfffff
    800019ca:	2b0080e7          	jalr	688(ra) # 80000c76 <release>

  if (first) {
    800019ce:	00007797          	auipc	a5,0x7
    800019d2:	e827a783          	lw	a5,-382(a5) # 80008850 <first.1>
    800019d6:	eb89                	bnez	a5,800019e8 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019d8:	00001097          	auipc	ra,0x1
    800019dc:	0ce080e7          	jalr	206(ra) # 80002aa6 <usertrapret>
}
    800019e0:	60a2                	ld	ra,8(sp)
    800019e2:	6402                	ld	s0,0(sp)
    800019e4:	0141                	addi	sp,sp,16
    800019e6:	8082                	ret
    first = 0;
    800019e8:	00007797          	auipc	a5,0x7
    800019ec:	e607a423          	sw	zero,-408(a5) # 80008850 <first.1>
    fsinit(ROOTDEV);
    800019f0:	4505                	li	a0,1
    800019f2:	00002097          	auipc	ra,0x2
    800019f6:	06a080e7          	jalr	106(ra) # 80003a5c <fsinit>
    800019fa:	bff9                	j	800019d8 <forkret+0x22>

00000000800019fc <allocpid>:
allocpid() {
    800019fc:	1101                	addi	sp,sp,-32
    800019fe:	ec06                	sd	ra,24(sp)
    80001a00:	e822                	sd	s0,16(sp)
    80001a02:	e426                	sd	s1,8(sp)
    80001a04:	e04a                	sd	s2,0(sp)
    80001a06:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a08:	00010917          	auipc	s2,0x10
    80001a0c:	89890913          	addi	s2,s2,-1896 # 800112a0 <pid_lock>
    80001a10:	854a                	mv	a0,s2
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	1b0080e7          	jalr	432(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001a1a:	00007797          	auipc	a5,0x7
    80001a1e:	e3a78793          	addi	a5,a5,-454 # 80008854 <nextpid>
    80001a22:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a24:	0014871b          	addiw	a4,s1,1
    80001a28:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a2a:	854a                	mv	a0,s2
    80001a2c:	fffff097          	auipc	ra,0xfffff
    80001a30:	24a080e7          	jalr	586(ra) # 80000c76 <release>
}
    80001a34:	8526                	mv	a0,s1
    80001a36:	60e2                	ld	ra,24(sp)
    80001a38:	6442                	ld	s0,16(sp)
    80001a3a:	64a2                	ld	s1,8(sp)
    80001a3c:	6902                	ld	s2,0(sp)
    80001a3e:	6105                	addi	sp,sp,32
    80001a40:	8082                	ret

0000000080001a42 <proc_pagetable>:
{
    80001a42:	1101                	addi	sp,sp,-32
    80001a44:	ec06                	sd	ra,24(sp)
    80001a46:	e822                	sd	s0,16(sp)
    80001a48:	e426                	sd	s1,8(sp)
    80001a4a:	e04a                	sd	s2,0(sp)
    80001a4c:	1000                	addi	s0,sp,32
    80001a4e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a50:	00000097          	auipc	ra,0x0
    80001a54:	8b6080e7          	jalr	-1866(ra) # 80001306 <uvmcreate>
    80001a58:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a5a:	c121                	beqz	a0,80001a9a <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a5c:	4729                	li	a4,10
    80001a5e:	00005697          	auipc	a3,0x5
    80001a62:	5a268693          	addi	a3,a3,1442 # 80007000 <_trampoline>
    80001a66:	6605                	lui	a2,0x1
    80001a68:	040005b7          	lui	a1,0x4000
    80001a6c:	15fd                	addi	a1,a1,-1
    80001a6e:	05b2                	slli	a1,a1,0xc
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	61e080e7          	jalr	1566(ra) # 8000108e <mappages>
    80001a78:	02054863          	bltz	a0,80001aa8 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a7c:	4719                	li	a4,6
    80001a7e:	05893683          	ld	a3,88(s2)
    80001a82:	6605                	lui	a2,0x1
    80001a84:	020005b7          	lui	a1,0x2000
    80001a88:	15fd                	addi	a1,a1,-1
    80001a8a:	05b6                	slli	a1,a1,0xd
    80001a8c:	8526                	mv	a0,s1
    80001a8e:	fffff097          	auipc	ra,0xfffff
    80001a92:	600080e7          	jalr	1536(ra) # 8000108e <mappages>
    80001a96:	02054163          	bltz	a0,80001ab8 <proc_pagetable+0x76>
}
    80001a9a:	8526                	mv	a0,s1
    80001a9c:	60e2                	ld	ra,24(sp)
    80001a9e:	6442                	ld	s0,16(sp)
    80001aa0:	64a2                	ld	s1,8(sp)
    80001aa2:	6902                	ld	s2,0(sp)
    80001aa4:	6105                	addi	sp,sp,32
    80001aa6:	8082                	ret
    uvmfree(pagetable, 0);
    80001aa8:	4581                	li	a1,0
    80001aaa:	8526                	mv	a0,s1
    80001aac:	00000097          	auipc	ra,0x0
    80001ab0:	a56080e7          	jalr	-1450(ra) # 80001502 <uvmfree>
    return 0;
    80001ab4:	4481                	li	s1,0
    80001ab6:	b7d5                	j	80001a9a <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ab8:	4681                	li	a3,0
    80001aba:	4605                	li	a2,1
    80001abc:	040005b7          	lui	a1,0x4000
    80001ac0:	15fd                	addi	a1,a1,-1
    80001ac2:	05b2                	slli	a1,a1,0xc
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	fffff097          	auipc	ra,0xfffff
    80001aca:	77c080e7          	jalr	1916(ra) # 80001242 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ace:	4581                	li	a1,0
    80001ad0:	8526                	mv	a0,s1
    80001ad2:	00000097          	auipc	ra,0x0
    80001ad6:	a30080e7          	jalr	-1488(ra) # 80001502 <uvmfree>
    return 0;
    80001ada:	4481                	li	s1,0
    80001adc:	bf7d                	j	80001a9a <proc_pagetable+0x58>

0000000080001ade <proc_freepagetable>:
{
    80001ade:	1101                	addi	sp,sp,-32
    80001ae0:	ec06                	sd	ra,24(sp)
    80001ae2:	e822                	sd	s0,16(sp)
    80001ae4:	e426                	sd	s1,8(sp)
    80001ae6:	e04a                	sd	s2,0(sp)
    80001ae8:	1000                	addi	s0,sp,32
    80001aea:	84aa                	mv	s1,a0
    80001aec:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aee:	4681                	li	a3,0
    80001af0:	4605                	li	a2,1
    80001af2:	040005b7          	lui	a1,0x4000
    80001af6:	15fd                	addi	a1,a1,-1
    80001af8:	05b2                	slli	a1,a1,0xc
    80001afa:	fffff097          	auipc	ra,0xfffff
    80001afe:	748080e7          	jalr	1864(ra) # 80001242 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b02:	4681                	li	a3,0
    80001b04:	4605                	li	a2,1
    80001b06:	020005b7          	lui	a1,0x2000
    80001b0a:	15fd                	addi	a1,a1,-1
    80001b0c:	05b6                	slli	a1,a1,0xd
    80001b0e:	8526                	mv	a0,s1
    80001b10:	fffff097          	auipc	ra,0xfffff
    80001b14:	732080e7          	jalr	1842(ra) # 80001242 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b18:	85ca                	mv	a1,s2
    80001b1a:	8526                	mv	a0,s1
    80001b1c:	00000097          	auipc	ra,0x0
    80001b20:	9e6080e7          	jalr	-1562(ra) # 80001502 <uvmfree>
}
    80001b24:	60e2                	ld	ra,24(sp)
    80001b26:	6442                	ld	s0,16(sp)
    80001b28:	64a2                	ld	s1,8(sp)
    80001b2a:	6902                	ld	s2,0(sp)
    80001b2c:	6105                	addi	sp,sp,32
    80001b2e:	8082                	ret

0000000080001b30 <freeproc>:
{
    80001b30:	1101                	addi	sp,sp,-32
    80001b32:	ec06                	sd	ra,24(sp)
    80001b34:	e822                	sd	s0,16(sp)
    80001b36:	e426                	sd	s1,8(sp)
    80001b38:	1000                	addi	s0,sp,32
    80001b3a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b3c:	6d28                	ld	a0,88(a0)
    80001b3e:	c509                	beqz	a0,80001b48 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b40:	fffff097          	auipc	ra,0xfffff
    80001b44:	e96080e7          	jalr	-362(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001b48:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b4c:	68a8                	ld	a0,80(s1)
    80001b4e:	c511                	beqz	a0,80001b5a <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b50:	64ac                	ld	a1,72(s1)
    80001b52:	00000097          	auipc	ra,0x0
    80001b56:	f8c080e7          	jalr	-116(ra) # 80001ade <proc_freepagetable>
  p->pagetable = 0;
    80001b5a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b5e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b62:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b66:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b6a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b6e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b72:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b76:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b7a:	0004ac23          	sw	zero,24(s1)
}
    80001b7e:	60e2                	ld	ra,24(sp)
    80001b80:	6442                	ld	s0,16(sp)
    80001b82:	64a2                	ld	s1,8(sp)
    80001b84:	6105                	addi	sp,sp,32
    80001b86:	8082                	ret

0000000080001b88 <allocproc>:
{
    80001b88:	7179                	addi	sp,sp,-48
    80001b8a:	f406                	sd	ra,40(sp)
    80001b8c:	f022                	sd	s0,32(sp)
    80001b8e:	ec26                	sd	s1,24(sp)
    80001b90:	e84a                	sd	s2,16(sp)
    80001b92:	e44e                	sd	s3,8(sp)
    80001b94:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b96:	00010497          	auipc	s1,0x10
    80001b9a:	b3a48493          	addi	s1,s1,-1222 # 800116d0 <proc>
    80001b9e:	0001c997          	auipc	s3,0x1c
    80001ba2:	d3298993          	addi	s3,s3,-718 # 8001d8d0 <tickslock>
    acquire(&p->lock);
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	fffff097          	auipc	ra,0xfffff
    80001bac:	01a080e7          	jalr	26(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    80001bb0:	4c9c                	lw	a5,24(s1)
    80001bb2:	cf81                	beqz	a5,80001bca <allocproc+0x42>
      release(&p->lock);
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	fffff097          	auipc	ra,0xfffff
    80001bba:	0c0080e7          	jalr	192(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bbe:	30848493          	addi	s1,s1,776
    80001bc2:	ff3492e3          	bne	s1,s3,80001ba6 <allocproc+0x1e>
  return 0;
    80001bc6:	4481                	li	s1,0
    80001bc8:	a851                	j	80001c5c <allocproc+0xd4>
  p->pid = allocpid();
    80001bca:	00000097          	auipc	ra,0x0
    80001bce:	e32080e7          	jalr	-462(ra) # 800019fc <allocpid>
    80001bd2:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bd4:	4785                	li	a5,1
    80001bd6:	cc9c                	sw	a5,24(s1)
  p->signalMask = 0;
    80001bd8:	1604a623          	sw	zero,364(s1)
  p->signalMaskBackup = 0;
    80001bdc:	1604a823          	sw	zero,368(s1)
  p-> userHandlerFlag = 0;
    80001be0:	3004a023          	sw	zero,768(s1)
  p->pendingSignals = 0;
    80001be4:	1604a423          	sw	zero,360(s1)
  for(int i = 0; i<SIGNUM; i++){
    80001be8:	17848713          	addi	a4,s1,376
    80001bec:	28048793          	addi	a5,s1,640
    80001bf0:	30048693          	addi	a3,s1,768
    p->sigHandlers[i] = SIG_DFL; 
    80001bf4:	00073023          	sd	zero,0(a4)
    p->handlersMask[i] = 0;
    80001bf8:	0007a023          	sw	zero,0(a5)
  for(int i = 0; i<SIGNUM; i++){
    80001bfc:	0721                	addi	a4,a4,8
    80001bfe:	0791                	addi	a5,a5,4
    80001c00:	fed79ae3          	bne	a5,a3,80001bf4 <allocproc+0x6c>
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	ece080e7          	jalr	-306(ra) # 80000ad2 <kalloc>
    80001c0c:	892a                	mv	s2,a0
    80001c0e:	eca8                	sd	a0,88(s1)
    80001c10:	cd31                	beqz	a0,80001c6c <allocproc+0xe4>
  if((p->trapframeBackup = (struct trapframe *)kalloc()) == 0){
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	ec0080e7          	jalr	-320(ra) # 80000ad2 <kalloc>
    80001c1a:	892a                	mv	s2,a0
    80001c1c:	26a4bc23          	sd	a0,632(s1)
    80001c20:	c135                	beqz	a0,80001c84 <allocproc+0xfc>
  p->pagetable = proc_pagetable(p);
    80001c22:	8526                	mv	a0,s1
    80001c24:	00000097          	auipc	ra,0x0
    80001c28:	e1e080e7          	jalr	-482(ra) # 80001a42 <proc_pagetable>
    80001c2c:	892a                	mv	s2,a0
    80001c2e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c30:	c535                	beqz	a0,80001c9c <allocproc+0x114>
  memset(&p->context, 0, sizeof(p->context));
    80001c32:	07000613          	li	a2,112
    80001c36:	4581                	li	a1,0
    80001c38:	06048513          	addi	a0,s1,96
    80001c3c:	fffff097          	auipc	ra,0xfffff
    80001c40:	082080e7          	jalr	130(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001c44:	00000797          	auipc	a5,0x0
    80001c48:	d7278793          	addi	a5,a5,-654 # 800019b6 <forkret>
    80001c4c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c4e:	60bc                	ld	a5,64(s1)
    80001c50:	6705                	lui	a4,0x1
    80001c52:	97ba                	add	a5,a5,a4
    80001c54:	f4bc                	sd	a5,104(s1)
  p->waitingForSem = -1; // added task4
    80001c56:	57fd                	li	a5,-1
    80001c58:	30f4a223          	sw	a5,772(s1)
}
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	70a2                	ld	ra,40(sp)
    80001c60:	7402                	ld	s0,32(sp)
    80001c62:	64e2                	ld	s1,24(sp)
    80001c64:	6942                	ld	s2,16(sp)
    80001c66:	69a2                	ld	s3,8(sp)
    80001c68:	6145                	addi	sp,sp,48
    80001c6a:	8082                	ret
    freeproc(p);
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	00000097          	auipc	ra,0x0
    80001c72:	ec2080e7          	jalr	-318(ra) # 80001b30 <freeproc>
    release(&p->lock);
    80001c76:	8526                	mv	a0,s1
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	ffe080e7          	jalr	-2(ra) # 80000c76 <release>
    return 0;
    80001c80:	84ca                	mv	s1,s2
    80001c82:	bfe9                	j	80001c5c <allocproc+0xd4>
    freeproc(p);
    80001c84:	8526                	mv	a0,s1
    80001c86:	00000097          	auipc	ra,0x0
    80001c8a:	eaa080e7          	jalr	-342(ra) # 80001b30 <freeproc>
    release(&p->lock);
    80001c8e:	8526                	mv	a0,s1
    80001c90:	fffff097          	auipc	ra,0xfffff
    80001c94:	fe6080e7          	jalr	-26(ra) # 80000c76 <release>
    return 0;
    80001c98:	84ca                	mv	s1,s2
    80001c9a:	b7c9                	j	80001c5c <allocproc+0xd4>
    freeproc(p);
    80001c9c:	8526                	mv	a0,s1
    80001c9e:	00000097          	auipc	ra,0x0
    80001ca2:	e92080e7          	jalr	-366(ra) # 80001b30 <freeproc>
    release(&p->lock);
    80001ca6:	8526                	mv	a0,s1
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	fce080e7          	jalr	-50(ra) # 80000c76 <release>
    return 0;
    80001cb0:	84ca                	mv	s1,s2
    80001cb2:	b76d                	j	80001c5c <allocproc+0xd4>

0000000080001cb4 <userinit>:
{
    80001cb4:	1101                	addi	sp,sp,-32
    80001cb6:	ec06                	sd	ra,24(sp)
    80001cb8:	e822                	sd	s0,16(sp)
    80001cba:	e426                	sd	s1,8(sp)
    80001cbc:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cbe:	00000097          	auipc	ra,0x0
    80001cc2:	eca080e7          	jalr	-310(ra) # 80001b88 <allocproc>
    80001cc6:	84aa                	mv	s1,a0
  initproc = p;
    80001cc8:	00007797          	auipc	a5,0x7
    80001ccc:	36a7b023          	sd	a0,864(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cd0:	03400613          	li	a2,52
    80001cd4:	00007597          	auipc	a1,0x7
    80001cd8:	b8c58593          	addi	a1,a1,-1140 # 80008860 <initcode>
    80001cdc:	6928                	ld	a0,80(a0)
    80001cde:	fffff097          	auipc	ra,0xfffff
    80001ce2:	656080e7          	jalr	1622(ra) # 80001334 <uvminit>
  p->sz = PGSIZE;
    80001ce6:	6785                	lui	a5,0x1
    80001ce8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cea:	6cb8                	ld	a4,88(s1)
    80001cec:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cf0:	6cb8                	ld	a4,88(s1)
    80001cf2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cf4:	4641                	li	a2,16
    80001cf6:	00006597          	auipc	a1,0x6
    80001cfa:	4f258593          	addi	a1,a1,1266 # 800081e8 <digits+0x1a8>
    80001cfe:	15848513          	addi	a0,s1,344
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	10e080e7          	jalr	270(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80001d0a:	00006517          	auipc	a0,0x6
    80001d0e:	4ee50513          	addi	a0,a0,1262 # 800081f8 <digits+0x1b8>
    80001d12:	00002097          	auipc	ra,0x2
    80001d16:	778080e7          	jalr	1912(ra) # 8000448a <namei>
    80001d1a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d1e:	478d                	li	a5,3
    80001d20:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d22:	8526                	mv	a0,s1
    80001d24:	fffff097          	auipc	ra,0xfffff
    80001d28:	f52080e7          	jalr	-174(ra) # 80000c76 <release>
}
    80001d2c:	60e2                	ld	ra,24(sp)
    80001d2e:	6442                	ld	s0,16(sp)
    80001d30:	64a2                	ld	s1,8(sp)
    80001d32:	6105                	addi	sp,sp,32
    80001d34:	8082                	ret

0000000080001d36 <growproc>:
{
    80001d36:	1101                	addi	sp,sp,-32
    80001d38:	ec06                	sd	ra,24(sp)
    80001d3a:	e822                	sd	s0,16(sp)
    80001d3c:	e426                	sd	s1,8(sp)
    80001d3e:	e04a                	sd	s2,0(sp)
    80001d40:	1000                	addi	s0,sp,32
    80001d42:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d44:	00000097          	auipc	ra,0x0
    80001d48:	c3a080e7          	jalr	-966(ra) # 8000197e <myproc>
    80001d4c:	892a                	mv	s2,a0
  sz = p->sz;
    80001d4e:	652c                	ld	a1,72(a0)
    80001d50:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d54:	00904f63          	bgtz	s1,80001d72 <growproc+0x3c>
  } else if(n < 0){
    80001d58:	0204cc63          	bltz	s1,80001d90 <growproc+0x5a>
  p->sz = sz;
    80001d5c:	1602                	slli	a2,a2,0x20
    80001d5e:	9201                	srli	a2,a2,0x20
    80001d60:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d64:	4501                	li	a0,0
}
    80001d66:	60e2                	ld	ra,24(sp)
    80001d68:	6442                	ld	s0,16(sp)
    80001d6a:	64a2                	ld	s1,8(sp)
    80001d6c:	6902                	ld	s2,0(sp)
    80001d6e:	6105                	addi	sp,sp,32
    80001d70:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d72:	9e25                	addw	a2,a2,s1
    80001d74:	1602                	slli	a2,a2,0x20
    80001d76:	9201                	srli	a2,a2,0x20
    80001d78:	1582                	slli	a1,a1,0x20
    80001d7a:	9181                	srli	a1,a1,0x20
    80001d7c:	6928                	ld	a0,80(a0)
    80001d7e:	fffff097          	auipc	ra,0xfffff
    80001d82:	670080e7          	jalr	1648(ra) # 800013ee <uvmalloc>
    80001d86:	0005061b          	sext.w	a2,a0
    80001d8a:	fa69                	bnez	a2,80001d5c <growproc+0x26>
      return -1;
    80001d8c:	557d                	li	a0,-1
    80001d8e:	bfe1                	j	80001d66 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d90:	9e25                	addw	a2,a2,s1
    80001d92:	1602                	slli	a2,a2,0x20
    80001d94:	9201                	srli	a2,a2,0x20
    80001d96:	1582                	slli	a1,a1,0x20
    80001d98:	9181                	srli	a1,a1,0x20
    80001d9a:	6928                	ld	a0,80(a0)
    80001d9c:	fffff097          	auipc	ra,0xfffff
    80001da0:	60a080e7          	jalr	1546(ra) # 800013a6 <uvmdealloc>
    80001da4:	0005061b          	sext.w	a2,a0
    80001da8:	bf55                	j	80001d5c <growproc+0x26>

0000000080001daa <fork>:
{
    80001daa:	7139                	addi	sp,sp,-64
    80001dac:	fc06                	sd	ra,56(sp)
    80001dae:	f822                	sd	s0,48(sp)
    80001db0:	f426                	sd	s1,40(sp)
    80001db2:	f04a                	sd	s2,32(sp)
    80001db4:	ec4e                	sd	s3,24(sp)
    80001db6:	e852                	sd	s4,16(sp)
    80001db8:	e456                	sd	s5,8(sp)
    80001dba:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dbc:	00000097          	auipc	ra,0x0
    80001dc0:	bc2080e7          	jalr	-1086(ra) # 8000197e <myproc>
    80001dc4:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    80001dc6:	00000097          	auipc	ra,0x0
    80001dca:	dc2080e7          	jalr	-574(ra) # 80001b88 <allocproc>
    80001dce:	14050563          	beqz	a0,80001f18 <fork+0x16e>
    80001dd2:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dd4:	0489b603          	ld	a2,72(s3)
    80001dd8:	692c                	ld	a1,80(a0)
    80001dda:	0509b503          	ld	a0,80(s3)
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	75c080e7          	jalr	1884(ra) # 8000153a <uvmcopy>
    80001de6:	08054163          	bltz	a0,80001e68 <fork+0xbe>
  np->sz = p->sz;
    80001dea:	0489b783          	ld	a5,72(s3)
    80001dee:	04f93423          	sd	a5,72(s2)
  np->signalMask = p->signalMask;
    80001df2:	16c9a783          	lw	a5,364(s3)
    80001df6:	16f92623          	sw	a5,364(s2)
  for(int i = 0; i<SIGNUM; i++){
    80001dfa:	17898693          	addi	a3,s3,376
    80001dfe:	17890713          	addi	a4,s2,376
  np->signalMask = p->signalMask;
    80001e02:	28000793          	li	a5,640
  for(int i = 0; i<SIGNUM; i++){
    80001e06:	30000513          	li	a0,768
    np->sigHandlers[i] = p->sigHandlers[i];
    80001e0a:	6290                	ld	a2,0(a3)
    80001e0c:	e310                	sd	a2,0(a4)
    np->handlersMask[i] = p->handlersMask[i]; 
    80001e0e:	00f98633          	add	a2,s3,a5
    80001e12:	420c                	lw	a1,0(a2)
    80001e14:	00f90633          	add	a2,s2,a5
    80001e18:	c20c                	sw	a1,0(a2)
  for(int i = 0; i<SIGNUM; i++){
    80001e1a:	06a1                	addi	a3,a3,8
    80001e1c:	0721                	addi	a4,a4,8
    80001e1e:	0791                	addi	a5,a5,4
    80001e20:	fea795e3          	bne	a5,a0,80001e0a <fork+0x60>
  *(np->trapframe) = *(p->trapframe);
    80001e24:	0589b683          	ld	a3,88(s3)
    80001e28:	87b6                	mv	a5,a3
    80001e2a:	05893703          	ld	a4,88(s2)
    80001e2e:	12068693          	addi	a3,a3,288
    80001e32:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e36:	6788                	ld	a0,8(a5)
    80001e38:	6b8c                	ld	a1,16(a5)
    80001e3a:	6f90                	ld	a2,24(a5)
    80001e3c:	01073023          	sd	a6,0(a4)
    80001e40:	e708                	sd	a0,8(a4)
    80001e42:	eb0c                	sd	a1,16(a4)
    80001e44:	ef10                	sd	a2,24(a4)
    80001e46:	02078793          	addi	a5,a5,32
    80001e4a:	02070713          	addi	a4,a4,32
    80001e4e:	fed792e3          	bne	a5,a3,80001e32 <fork+0x88>
  np->trapframe->a0 = 0;
    80001e52:	05893783          	ld	a5,88(s2)
    80001e56:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e5a:	0d098493          	addi	s1,s3,208
    80001e5e:	0d090a13          	addi	s4,s2,208
    80001e62:	15098a93          	addi	s5,s3,336
    80001e66:	a00d                	j	80001e88 <fork+0xde>
    freeproc(np);
    80001e68:	854a                	mv	a0,s2
    80001e6a:	00000097          	auipc	ra,0x0
    80001e6e:	cc6080e7          	jalr	-826(ra) # 80001b30 <freeproc>
    release(&np->lock);
    80001e72:	854a                	mv	a0,s2
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	e02080e7          	jalr	-510(ra) # 80000c76 <release>
    return -1;
    80001e7c:	5a7d                	li	s4,-1
    80001e7e:	a059                	j	80001f04 <fork+0x15a>
  for(i = 0; i < NOFILE; i++)
    80001e80:	04a1                	addi	s1,s1,8
    80001e82:	0a21                	addi	s4,s4,8
    80001e84:	01548b63          	beq	s1,s5,80001e9a <fork+0xf0>
    if(p->ofile[i])
    80001e88:	6088                	ld	a0,0(s1)
    80001e8a:	d97d                	beqz	a0,80001e80 <fork+0xd6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e8c:	00003097          	auipc	ra,0x3
    80001e90:	c98080e7          	jalr	-872(ra) # 80004b24 <filedup>
    80001e94:	00aa3023          	sd	a0,0(s4)
    80001e98:	b7e5                	j	80001e80 <fork+0xd6>
  np->cwd = idup(p->cwd);
    80001e9a:	1509b503          	ld	a0,336(s3)
    80001e9e:	00002097          	auipc	ra,0x2
    80001ea2:	df8080e7          	jalr	-520(ra) # 80003c96 <idup>
    80001ea6:	14a93823          	sd	a0,336(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001eaa:	4641                	li	a2,16
    80001eac:	15898593          	addi	a1,s3,344
    80001eb0:	15890513          	addi	a0,s2,344
    80001eb4:	fffff097          	auipc	ra,0xfffff
    80001eb8:	f5c080e7          	jalr	-164(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80001ebc:	03092a03          	lw	s4,48(s2)
  release(&np->lock);
    80001ec0:	854a                	mv	a0,s2
    80001ec2:	fffff097          	auipc	ra,0xfffff
    80001ec6:	db4080e7          	jalr	-588(ra) # 80000c76 <release>
  acquire(&wait_lock);
    80001eca:	0000f497          	auipc	s1,0xf
    80001ece:	3ee48493          	addi	s1,s1,1006 # 800112b8 <wait_lock>
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	fffff097          	auipc	ra,0xfffff
    80001ed8:	cee080e7          	jalr	-786(ra) # 80000bc2 <acquire>
  np->parent = p;
    80001edc:	03393c23          	sd	s3,56(s2)
  release(&wait_lock);
    80001ee0:	8526                	mv	a0,s1
    80001ee2:	fffff097          	auipc	ra,0xfffff
    80001ee6:	d94080e7          	jalr	-620(ra) # 80000c76 <release>
  acquire(&np->lock);
    80001eea:	854a                	mv	a0,s2
    80001eec:	fffff097          	auipc	ra,0xfffff
    80001ef0:	cd6080e7          	jalr	-810(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80001ef4:	478d                	li	a5,3
    80001ef6:	00f92c23          	sw	a5,24(s2)
  release(&np->lock);
    80001efa:	854a                	mv	a0,s2
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	d7a080e7          	jalr	-646(ra) # 80000c76 <release>
}
    80001f04:	8552                	mv	a0,s4
    80001f06:	70e2                	ld	ra,56(sp)
    80001f08:	7442                	ld	s0,48(sp)
    80001f0a:	74a2                	ld	s1,40(sp)
    80001f0c:	7902                	ld	s2,32(sp)
    80001f0e:	69e2                	ld	s3,24(sp)
    80001f10:	6a42                	ld	s4,16(sp)
    80001f12:	6aa2                	ld	s5,8(sp)
    80001f14:	6121                	addi	sp,sp,64
    80001f16:	8082                	ret
    return -1;
    80001f18:	5a7d                	li	s4,-1
    80001f1a:	b7ed                	j	80001f04 <fork+0x15a>

0000000080001f1c <scheduler>:
{
    80001f1c:	7139                	addi	sp,sp,-64
    80001f1e:	fc06                	sd	ra,56(sp)
    80001f20:	f822                	sd	s0,48(sp)
    80001f22:	f426                	sd	s1,40(sp)
    80001f24:	f04a                	sd	s2,32(sp)
    80001f26:	ec4e                	sd	s3,24(sp)
    80001f28:	e852                	sd	s4,16(sp)
    80001f2a:	e456                	sd	s5,8(sp)
    80001f2c:	e05a                	sd	s6,0(sp)
    80001f2e:	0080                	addi	s0,sp,64
    80001f30:	8792                	mv	a5,tp
  int id = r_tp();
    80001f32:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f34:	00779a93          	slli	s5,a5,0x7
    80001f38:	0000f717          	auipc	a4,0xf
    80001f3c:	36870713          	addi	a4,a4,872 # 800112a0 <pid_lock>
    80001f40:	9756                	add	a4,a4,s5
    80001f42:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f46:	0000f717          	auipc	a4,0xf
    80001f4a:	39270713          	addi	a4,a4,914 # 800112d8 <cpus+0x8>
    80001f4e:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) { //in threads implementation - remove this line.
    80001f50:	498d                	li	s3,3
        p->state = RUNNING;
    80001f52:	4b11                	li	s6,4
        c->proc = p;
    80001f54:	079e                	slli	a5,a5,0x7
    80001f56:	0000fa17          	auipc	s4,0xf
    80001f5a:	34aa0a13          	addi	s4,s4,842 # 800112a0 <pid_lock>
    80001f5e:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f60:	0001c917          	auipc	s2,0x1c
    80001f64:	97090913          	addi	s2,s2,-1680 # 8001d8d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f68:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f6c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f70:	10079073          	csrw	sstatus,a5
    80001f74:	0000f497          	auipc	s1,0xf
    80001f78:	75c48493          	addi	s1,s1,1884 # 800116d0 <proc>
    80001f7c:	a811                	j	80001f90 <scheduler+0x74>
      release(&p->lock);
    80001f7e:	8526                	mv	a0,s1
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	cf6080e7          	jalr	-778(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f88:	30848493          	addi	s1,s1,776
    80001f8c:	fd248ee3          	beq	s1,s2,80001f68 <scheduler+0x4c>
      acquire(&p->lock);
    80001f90:	8526                	mv	a0,s1
    80001f92:	fffff097          	auipc	ra,0xfffff
    80001f96:	c30080e7          	jalr	-976(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE) { //in threads implementation - remove this line.
    80001f9a:	4c9c                	lw	a5,24(s1)
    80001f9c:	ff3791e3          	bne	a5,s3,80001f7e <scheduler+0x62>
        p->state = RUNNING;
    80001fa0:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fa4:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fa8:	06048593          	addi	a1,s1,96
    80001fac:	8556                	mv	a0,s5
    80001fae:	00001097          	auipc	ra,0x1
    80001fb2:	a4e080e7          	jalr	-1458(ra) # 800029fc <swtch>
        c->proc = 0;
    80001fb6:	020a3823          	sd	zero,48(s4)
    80001fba:	b7d1                	j	80001f7e <scheduler+0x62>

0000000080001fbc <sched>:
{
    80001fbc:	7179                	addi	sp,sp,-48
    80001fbe:	f406                	sd	ra,40(sp)
    80001fc0:	f022                	sd	s0,32(sp)
    80001fc2:	ec26                	sd	s1,24(sp)
    80001fc4:	e84a                	sd	s2,16(sp)
    80001fc6:	e44e                	sd	s3,8(sp)
    80001fc8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fca:	00000097          	auipc	ra,0x0
    80001fce:	9b4080e7          	jalr	-1612(ra) # 8000197e <myproc>
    80001fd2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fd4:	fffff097          	auipc	ra,0xfffff
    80001fd8:	b74080e7          	jalr	-1164(ra) # 80000b48 <holding>
    80001fdc:	c93d                	beqz	a0,80002052 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fde:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fe0:	2781                	sext.w	a5,a5
    80001fe2:	079e                	slli	a5,a5,0x7
    80001fe4:	0000f717          	auipc	a4,0xf
    80001fe8:	2bc70713          	addi	a4,a4,700 # 800112a0 <pid_lock>
    80001fec:	97ba                	add	a5,a5,a4
    80001fee:	0a87a703          	lw	a4,168(a5)
    80001ff2:	4785                	li	a5,1
    80001ff4:	06f71763          	bne	a4,a5,80002062 <sched+0xa6>
  if(p->state == RUNNING)
    80001ff8:	4c98                	lw	a4,24(s1)
    80001ffa:	4791                	li	a5,4
    80001ffc:	06f70b63          	beq	a4,a5,80002072 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002000:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002004:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002006:	efb5                	bnez	a5,80002082 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002008:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000200a:	0000f917          	auipc	s2,0xf
    8000200e:	29690913          	addi	s2,s2,662 # 800112a0 <pid_lock>
    80002012:	2781                	sext.w	a5,a5
    80002014:	079e                	slli	a5,a5,0x7
    80002016:	97ca                	add	a5,a5,s2
    80002018:	0ac7a983          	lw	s3,172(a5)
    8000201c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000201e:	2781                	sext.w	a5,a5
    80002020:	079e                	slli	a5,a5,0x7
    80002022:	0000f597          	auipc	a1,0xf
    80002026:	2b658593          	addi	a1,a1,694 # 800112d8 <cpus+0x8>
    8000202a:	95be                	add	a1,a1,a5
    8000202c:	06048513          	addi	a0,s1,96
    80002030:	00001097          	auipc	ra,0x1
    80002034:	9cc080e7          	jalr	-1588(ra) # 800029fc <swtch>
    80002038:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000203a:	2781                	sext.w	a5,a5
    8000203c:	079e                	slli	a5,a5,0x7
    8000203e:	97ca                	add	a5,a5,s2
    80002040:	0b37a623          	sw	s3,172(a5)
}
    80002044:	70a2                	ld	ra,40(sp)
    80002046:	7402                	ld	s0,32(sp)
    80002048:	64e2                	ld	s1,24(sp)
    8000204a:	6942                	ld	s2,16(sp)
    8000204c:	69a2                	ld	s3,8(sp)
    8000204e:	6145                	addi	sp,sp,48
    80002050:	8082                	ret
    panic("sched p->lock");
    80002052:	00006517          	auipc	a0,0x6
    80002056:	1ae50513          	addi	a0,a0,430 # 80008200 <digits+0x1c0>
    8000205a:	ffffe097          	auipc	ra,0xffffe
    8000205e:	4d0080e7          	jalr	1232(ra) # 8000052a <panic>
    panic("sched locks");
    80002062:	00006517          	auipc	a0,0x6
    80002066:	1ae50513          	addi	a0,a0,430 # 80008210 <digits+0x1d0>
    8000206a:	ffffe097          	auipc	ra,0xffffe
    8000206e:	4c0080e7          	jalr	1216(ra) # 8000052a <panic>
    panic("sched running");
    80002072:	00006517          	auipc	a0,0x6
    80002076:	1ae50513          	addi	a0,a0,430 # 80008220 <digits+0x1e0>
    8000207a:	ffffe097          	auipc	ra,0xffffe
    8000207e:	4b0080e7          	jalr	1200(ra) # 8000052a <panic>
    panic("sched interruptible");
    80002082:	00006517          	auipc	a0,0x6
    80002086:	1ae50513          	addi	a0,a0,430 # 80008230 <digits+0x1f0>
    8000208a:	ffffe097          	auipc	ra,0xffffe
    8000208e:	4a0080e7          	jalr	1184(ra) # 8000052a <panic>

0000000080002092 <yield>:
{
    80002092:	1101                	addi	sp,sp,-32
    80002094:	ec06                	sd	ra,24(sp)
    80002096:	e822                	sd	s0,16(sp)
    80002098:	e426                	sd	s1,8(sp)
    8000209a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000209c:	00000097          	auipc	ra,0x0
    800020a0:	8e2080e7          	jalr	-1822(ra) # 8000197e <myproc>
    800020a4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020a6:	fffff097          	auipc	ra,0xfffff
    800020aa:	b1c080e7          	jalr	-1252(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    800020ae:	478d                	li	a5,3
    800020b0:	cc9c                	sw	a5,24(s1)
  sched();
    800020b2:	00000097          	auipc	ra,0x0
    800020b6:	f0a080e7          	jalr	-246(ra) # 80001fbc <sched>
  release(&p->lock);
    800020ba:	8526                	mv	a0,s1
    800020bc:	fffff097          	auipc	ra,0xfffff
    800020c0:	bba080e7          	jalr	-1094(ra) # 80000c76 <release>
}
    800020c4:	60e2                	ld	ra,24(sp)
    800020c6:	6442                	ld	s0,16(sp)
    800020c8:	64a2                	ld	s1,8(sp)
    800020ca:	6105                	addi	sp,sp,32
    800020cc:	8082                	ret

00000000800020ce <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020ce:	7179                	addi	sp,sp,-48
    800020d0:	f406                	sd	ra,40(sp)
    800020d2:	f022                	sd	s0,32(sp)
    800020d4:	ec26                	sd	s1,24(sp)
    800020d6:	e84a                	sd	s2,16(sp)
    800020d8:	e44e                	sd	s3,8(sp)
    800020da:	1800                	addi	s0,sp,48
    800020dc:	89aa                	mv	s3,a0
    800020de:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020e0:	00000097          	auipc	ra,0x0
    800020e4:	89e080e7          	jalr	-1890(ra) # 8000197e <myproc>
    800020e8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020ea:	fffff097          	auipc	ra,0xfffff
    800020ee:	ad8080e7          	jalr	-1320(ra) # 80000bc2 <acquire>
  release(lk);
    800020f2:	854a                	mv	a0,s2
    800020f4:	fffff097          	auipc	ra,0xfffff
    800020f8:	b82080e7          	jalr	-1150(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    800020fc:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002100:	4789                	li	a5,2
    80002102:	cc9c                	sw	a5,24(s1)

  sched();
    80002104:	00000097          	auipc	ra,0x0
    80002108:	eb8080e7          	jalr	-328(ra) # 80001fbc <sched>

  // Tidy up.
  p->chan = 0;
    8000210c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002110:	8526                	mv	a0,s1
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	b64080e7          	jalr	-1180(ra) # 80000c76 <release>
  acquire(lk);
    8000211a:	854a                	mv	a0,s2
    8000211c:	fffff097          	auipc	ra,0xfffff
    80002120:	aa6080e7          	jalr	-1370(ra) # 80000bc2 <acquire>
}
    80002124:	70a2                	ld	ra,40(sp)
    80002126:	7402                	ld	s0,32(sp)
    80002128:	64e2                	ld	s1,24(sp)
    8000212a:	6942                	ld	s2,16(sp)
    8000212c:	69a2                	ld	s3,8(sp)
    8000212e:	6145                	addi	sp,sp,48
    80002130:	8082                	ret

0000000080002132 <wait>:
{
    80002132:	715d                	addi	sp,sp,-80
    80002134:	e486                	sd	ra,72(sp)
    80002136:	e0a2                	sd	s0,64(sp)
    80002138:	fc26                	sd	s1,56(sp)
    8000213a:	f84a                	sd	s2,48(sp)
    8000213c:	f44e                	sd	s3,40(sp)
    8000213e:	f052                	sd	s4,32(sp)
    80002140:	ec56                	sd	s5,24(sp)
    80002142:	e85a                	sd	s6,16(sp)
    80002144:	e45e                	sd	s7,8(sp)
    80002146:	e062                	sd	s8,0(sp)
    80002148:	0880                	addi	s0,sp,80
    8000214a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000214c:	00000097          	auipc	ra,0x0
    80002150:	832080e7          	jalr	-1998(ra) # 8000197e <myproc>
    80002154:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002156:	0000f517          	auipc	a0,0xf
    8000215a:	16250513          	addi	a0,a0,354 # 800112b8 <wait_lock>
    8000215e:	fffff097          	auipc	ra,0xfffff
    80002162:	a64080e7          	jalr	-1436(ra) # 80000bc2 <acquire>
    havekids = 0;
    80002166:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002168:	4a15                	li	s4,5
        havekids = 1;
    8000216a:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000216c:	0001b997          	auipc	s3,0x1b
    80002170:	76498993          	addi	s3,s3,1892 # 8001d8d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002174:	0000fc17          	auipc	s8,0xf
    80002178:	144c0c13          	addi	s8,s8,324 # 800112b8 <wait_lock>
    havekids = 0;
    8000217c:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000217e:	0000f497          	auipc	s1,0xf
    80002182:	55248493          	addi	s1,s1,1362 # 800116d0 <proc>
    80002186:	a0bd                	j	800021f4 <wait+0xc2>
          pid = np->pid;
    80002188:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000218c:	000b0e63          	beqz	s6,800021a8 <wait+0x76>
    80002190:	4691                	li	a3,4
    80002192:	02c48613          	addi	a2,s1,44
    80002196:	85da                	mv	a1,s6
    80002198:	05093503          	ld	a0,80(s2)
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	4a2080e7          	jalr	1186(ra) # 8000163e <copyout>
    800021a4:	02054563          	bltz	a0,800021ce <wait+0x9c>
          freeproc(np);
    800021a8:	8526                	mv	a0,s1
    800021aa:	00000097          	auipc	ra,0x0
    800021ae:	986080e7          	jalr	-1658(ra) # 80001b30 <freeproc>
          release(&np->lock);
    800021b2:	8526                	mv	a0,s1
    800021b4:	fffff097          	auipc	ra,0xfffff
    800021b8:	ac2080e7          	jalr	-1342(ra) # 80000c76 <release>
          release(&wait_lock);
    800021bc:	0000f517          	auipc	a0,0xf
    800021c0:	0fc50513          	addi	a0,a0,252 # 800112b8 <wait_lock>
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	ab2080e7          	jalr	-1358(ra) # 80000c76 <release>
          return pid;
    800021cc:	a09d                	j	80002232 <wait+0x100>
            release(&np->lock);
    800021ce:	8526                	mv	a0,s1
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	aa6080e7          	jalr	-1370(ra) # 80000c76 <release>
            release(&wait_lock);
    800021d8:	0000f517          	auipc	a0,0xf
    800021dc:	0e050513          	addi	a0,a0,224 # 800112b8 <wait_lock>
    800021e0:	fffff097          	auipc	ra,0xfffff
    800021e4:	a96080e7          	jalr	-1386(ra) # 80000c76 <release>
            return -1;
    800021e8:	59fd                	li	s3,-1
    800021ea:	a0a1                	j	80002232 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800021ec:	30848493          	addi	s1,s1,776
    800021f0:	03348463          	beq	s1,s3,80002218 <wait+0xe6>
      if(np->parent == p){
    800021f4:	7c9c                	ld	a5,56(s1)
    800021f6:	ff279be3          	bne	a5,s2,800021ec <wait+0xba>
        acquire(&np->lock);
    800021fa:	8526                	mv	a0,s1
    800021fc:	fffff097          	auipc	ra,0xfffff
    80002200:	9c6080e7          	jalr	-1594(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    80002204:	4c9c                	lw	a5,24(s1)
    80002206:	f94781e3          	beq	a5,s4,80002188 <wait+0x56>
        release(&np->lock);
    8000220a:	8526                	mv	a0,s1
    8000220c:	fffff097          	auipc	ra,0xfffff
    80002210:	a6a080e7          	jalr	-1430(ra) # 80000c76 <release>
        havekids = 1;
    80002214:	8756                	mv	a4,s5
    80002216:	bfd9                	j	800021ec <wait+0xba>
    if(!havekids || p->killed){
    80002218:	c701                	beqz	a4,80002220 <wait+0xee>
    8000221a:	02892783          	lw	a5,40(s2)
    8000221e:	c79d                	beqz	a5,8000224c <wait+0x11a>
      release(&wait_lock);
    80002220:	0000f517          	auipc	a0,0xf
    80002224:	09850513          	addi	a0,a0,152 # 800112b8 <wait_lock>
    80002228:	fffff097          	auipc	ra,0xfffff
    8000222c:	a4e080e7          	jalr	-1458(ra) # 80000c76 <release>
      return -1;
    80002230:	59fd                	li	s3,-1
}
    80002232:	854e                	mv	a0,s3
    80002234:	60a6                	ld	ra,72(sp)
    80002236:	6406                	ld	s0,64(sp)
    80002238:	74e2                	ld	s1,56(sp)
    8000223a:	7942                	ld	s2,48(sp)
    8000223c:	79a2                	ld	s3,40(sp)
    8000223e:	7a02                	ld	s4,32(sp)
    80002240:	6ae2                	ld	s5,24(sp)
    80002242:	6b42                	ld	s6,16(sp)
    80002244:	6ba2                	ld	s7,8(sp)
    80002246:	6c02                	ld	s8,0(sp)
    80002248:	6161                	addi	sp,sp,80
    8000224a:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000224c:	85e2                	mv	a1,s8
    8000224e:	854a                	mv	a0,s2
    80002250:	00000097          	auipc	ra,0x0
    80002254:	e7e080e7          	jalr	-386(ra) # 800020ce <sleep>
    havekids = 0;
    80002258:	b715                	j	8000217c <wait+0x4a>

000000008000225a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000225a:	7139                	addi	sp,sp,-64
    8000225c:	fc06                	sd	ra,56(sp)
    8000225e:	f822                	sd	s0,48(sp)
    80002260:	f426                	sd	s1,40(sp)
    80002262:	f04a                	sd	s2,32(sp)
    80002264:	ec4e                	sd	s3,24(sp)
    80002266:	e852                	sd	s4,16(sp)
    80002268:	e456                	sd	s5,8(sp)
    8000226a:	0080                	addi	s0,sp,64
    8000226c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000226e:	0000f497          	auipc	s1,0xf
    80002272:	46248493          	addi	s1,s1,1122 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002276:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002278:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000227a:	0001b917          	auipc	s2,0x1b
    8000227e:	65690913          	addi	s2,s2,1622 # 8001d8d0 <tickslock>
    80002282:	a811                	j	80002296 <wakeup+0x3c>
      }
      release(&p->lock);
    80002284:	8526                	mv	a0,s1
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	9f0080e7          	jalr	-1552(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000228e:	30848493          	addi	s1,s1,776
    80002292:	03248663          	beq	s1,s2,800022be <wakeup+0x64>
    if(p != myproc()){
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	6e8080e7          	jalr	1768(ra) # 8000197e <myproc>
    8000229e:	fea488e3          	beq	s1,a0,8000228e <wakeup+0x34>
      acquire(&p->lock);
    800022a2:	8526                	mv	a0,s1
    800022a4:	fffff097          	auipc	ra,0xfffff
    800022a8:	91e080e7          	jalr	-1762(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022ac:	4c9c                	lw	a5,24(s1)
    800022ae:	fd379be3          	bne	a5,s3,80002284 <wakeup+0x2a>
    800022b2:	709c                	ld	a5,32(s1)
    800022b4:	fd4798e3          	bne	a5,s4,80002284 <wakeup+0x2a>
        p->state = RUNNABLE;
    800022b8:	0154ac23          	sw	s5,24(s1)
    800022bc:	b7e1                	j	80002284 <wakeup+0x2a>
    }
  }
}
    800022be:	70e2                	ld	ra,56(sp)
    800022c0:	7442                	ld	s0,48(sp)
    800022c2:	74a2                	ld	s1,40(sp)
    800022c4:	7902                	ld	s2,32(sp)
    800022c6:	69e2                	ld	s3,24(sp)
    800022c8:	6a42                	ld	s4,16(sp)
    800022ca:	6aa2                	ld	s5,8(sp)
    800022cc:	6121                	addi	sp,sp,64
    800022ce:	8082                	ret

00000000800022d0 <reparent>:
{
    800022d0:	7179                	addi	sp,sp,-48
    800022d2:	f406                	sd	ra,40(sp)
    800022d4:	f022                	sd	s0,32(sp)
    800022d6:	ec26                	sd	s1,24(sp)
    800022d8:	e84a                	sd	s2,16(sp)
    800022da:	e44e                	sd	s3,8(sp)
    800022dc:	e052                	sd	s4,0(sp)
    800022de:	1800                	addi	s0,sp,48
    800022e0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022e2:	0000f497          	auipc	s1,0xf
    800022e6:	3ee48493          	addi	s1,s1,1006 # 800116d0 <proc>
      pp->parent = initproc;
    800022ea:	00007a17          	auipc	s4,0x7
    800022ee:	d3ea0a13          	addi	s4,s4,-706 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022f2:	0001b997          	auipc	s3,0x1b
    800022f6:	5de98993          	addi	s3,s3,1502 # 8001d8d0 <tickslock>
    800022fa:	a029                	j	80002304 <reparent+0x34>
    800022fc:	30848493          	addi	s1,s1,776
    80002300:	01348d63          	beq	s1,s3,8000231a <reparent+0x4a>
    if(pp->parent == p){
    80002304:	7c9c                	ld	a5,56(s1)
    80002306:	ff279be3          	bne	a5,s2,800022fc <reparent+0x2c>
      pp->parent = initproc;
    8000230a:	000a3503          	ld	a0,0(s4)
    8000230e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002310:	00000097          	auipc	ra,0x0
    80002314:	f4a080e7          	jalr	-182(ra) # 8000225a <wakeup>
    80002318:	b7d5                	j	800022fc <reparent+0x2c>
}
    8000231a:	70a2                	ld	ra,40(sp)
    8000231c:	7402                	ld	s0,32(sp)
    8000231e:	64e2                	ld	s1,24(sp)
    80002320:	6942                	ld	s2,16(sp)
    80002322:	69a2                	ld	s3,8(sp)
    80002324:	6a02                	ld	s4,0(sp)
    80002326:	6145                	addi	sp,sp,48
    80002328:	8082                	ret

000000008000232a <exit>:
{
    8000232a:	7179                	addi	sp,sp,-48
    8000232c:	f406                	sd	ra,40(sp)
    8000232e:	f022                	sd	s0,32(sp)
    80002330:	ec26                	sd	s1,24(sp)
    80002332:	e84a                	sd	s2,16(sp)
    80002334:	e44e                	sd	s3,8(sp)
    80002336:	e052                	sd	s4,0(sp)
    80002338:	1800                	addi	s0,sp,48
    8000233a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	642080e7          	jalr	1602(ra) # 8000197e <myproc>
    80002344:	89aa                	mv	s3,a0
  if(p == initproc)
    80002346:	00007797          	auipc	a5,0x7
    8000234a:	ce27b783          	ld	a5,-798(a5) # 80009028 <initproc>
    8000234e:	0d050493          	addi	s1,a0,208
    80002352:	15050913          	addi	s2,a0,336
    80002356:	02a79363          	bne	a5,a0,8000237c <exit+0x52>
    panic("init exiting");
    8000235a:	00006517          	auipc	a0,0x6
    8000235e:	eee50513          	addi	a0,a0,-274 # 80008248 <digits+0x208>
    80002362:	ffffe097          	auipc	ra,0xffffe
    80002366:	1c8080e7          	jalr	456(ra) # 8000052a <panic>
      fileclose(f);
    8000236a:	00003097          	auipc	ra,0x3
    8000236e:	80c080e7          	jalr	-2036(ra) # 80004b76 <fileclose>
      p->ofile[fd] = 0;
    80002372:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002376:	04a1                	addi	s1,s1,8
    80002378:	01248563          	beq	s1,s2,80002382 <exit+0x58>
    if(p->ofile[fd]){
    8000237c:	6088                	ld	a0,0(s1)
    8000237e:	f575                	bnez	a0,8000236a <exit+0x40>
    80002380:	bfdd                	j	80002376 <exit+0x4c>
  begin_op();
    80002382:	00002097          	auipc	ra,0x2
    80002386:	328080e7          	jalr	808(ra) # 800046aa <begin_op>
  iput(p->cwd);
    8000238a:	1509b503          	ld	a0,336(s3)
    8000238e:	00002097          	auipc	ra,0x2
    80002392:	b00080e7          	jalr	-1280(ra) # 80003e8e <iput>
  end_op();
    80002396:	00002097          	auipc	ra,0x2
    8000239a:	394080e7          	jalr	916(ra) # 8000472a <end_op>
  p->cwd = 0;
    8000239e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800023a2:	0000f497          	auipc	s1,0xf
    800023a6:	f1648493          	addi	s1,s1,-234 # 800112b8 <wait_lock>
    800023aa:	8526                	mv	a0,s1
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	816080e7          	jalr	-2026(ra) # 80000bc2 <acquire>
  reparent(p);
    800023b4:	854e                	mv	a0,s3
    800023b6:	00000097          	auipc	ra,0x0
    800023ba:	f1a080e7          	jalr	-230(ra) # 800022d0 <reparent>
  wakeup(p->parent);
    800023be:	0389b503          	ld	a0,56(s3)
    800023c2:	00000097          	auipc	ra,0x0
    800023c6:	e98080e7          	jalr	-360(ra) # 8000225a <wakeup>
  acquire(&p->lock);
    800023ca:	854e                	mv	a0,s3
    800023cc:	ffffe097          	auipc	ra,0xffffe
    800023d0:	7f6080e7          	jalr	2038(ra) # 80000bc2 <acquire>
  p->xstate = status;
    800023d4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800023d8:	4795                	li	a5,5
    800023da:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	896080e7          	jalr	-1898(ra) # 80000c76 <release>
  sched();
    800023e8:	00000097          	auipc	ra,0x0
    800023ec:	bd4080e7          	jalr	-1068(ra) # 80001fbc <sched>
  panic("zombie exit");
    800023f0:	00006517          	auipc	a0,0x6
    800023f4:	e6850513          	addi	a0,a0,-408 # 80008258 <digits+0x218>
    800023f8:	ffffe097          	auipc	ra,0xffffe
    800023fc:	132080e7          	jalr	306(ra) # 8000052a <panic>

0000000080002400 <kill>:
// to user space (see usertrap() in trap.c).
int
kill(int pid, int signum)
{
  struct proc *p;
  if(signum>=SIGNUM || signum<0) // CHANGED >= SIGNUM
    80002400:	477d                	li	a4,31
    80002402:	06b76d63          	bltu	a4,a1,8000247c <kill+0x7c>
{
    80002406:	7179                	addi	sp,sp,-48
    80002408:	f406                	sd	ra,40(sp)
    8000240a:	f022                	sd	s0,32(sp)
    8000240c:	ec26                	sd	s1,24(sp)
    8000240e:	e84a                	sd	s2,16(sp)
    80002410:	e44e                	sd	s3,8(sp)
    80002412:	e052                	sd	s4,0(sp)
    80002414:	1800                	addi	s0,sp,48
    80002416:	892a                	mv	s2,a0
    return -1;
  uint32 signal = 1 << signum;
    80002418:	4785                	li	a5,1
    8000241a:	00b79a3b          	sllw	s4,a5,a1

  for(p = proc; p < &proc[NPROC]; p++){
    8000241e:	0000f497          	auipc	s1,0xf
    80002422:	2b248493          	addi	s1,s1,690 # 800116d0 <proc>
    80002426:	0001b997          	auipc	s3,0x1b
    8000242a:	4aa98993          	addi	s3,s3,1194 # 8001d8d0 <tickslock>
    acquire(&p->lock);
    8000242e:	8526                	mv	a0,s1
    80002430:	ffffe097          	auipc	ra,0xffffe
    80002434:	792080e7          	jalr	1938(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80002438:	589c                	lw	a5,48(s1)
    8000243a:	01278d63          	beq	a5,s2,80002454 <kill+0x54>
        p->pendingSignals = p->pendingSignals | signal; // logic or?
        // printf("**pending sigs: %d!\n", p->pendingSignals);
        release(&p->lock);
        return 0;
    }
    release(&p->lock);
    8000243e:	8526                	mv	a0,s1
    80002440:	fffff097          	auipc	ra,0xfffff
    80002444:	836080e7          	jalr	-1994(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002448:	30848493          	addi	s1,s1,776
    8000244c:	ff3491e3          	bne	s1,s3,8000242e <kill+0x2e>
  }
  return -1;
    80002450:	557d                	li	a0,-1
    80002452:	a829                	j	8000246c <kill+0x6c>
        p->pendingSignals = p->pendingSignals | signal; // logic or?
    80002454:	1684a783          	lw	a5,360(s1)
    80002458:	0147e7b3          	or	a5,a5,s4
    8000245c:	16f4a423          	sw	a5,360(s1)
        release(&p->lock);
    80002460:	8526                	mv	a0,s1
    80002462:	fffff097          	auipc	ra,0xfffff
    80002466:	814080e7          	jalr	-2028(ra) # 80000c76 <release>
        return 0;
    8000246a:	4501                	li	a0,0
}
    8000246c:	70a2                	ld	ra,40(sp)
    8000246e:	7402                	ld	s0,32(sp)
    80002470:	64e2                	ld	s1,24(sp)
    80002472:	6942                	ld	s2,16(sp)
    80002474:	69a2                	ld	s3,8(sp)
    80002476:	6a02                	ld	s4,0(sp)
    80002478:	6145                	addi	sp,sp,48
    8000247a:	8082                	ret
    return -1;
    8000247c:	557d                	li	a0,-1
}
    8000247e:	8082                	ret

0000000080002480 <sigprocmask>:

//updates process signal mask. returns old mask.
uint
sigprocmask(uint sigmask)
{
    80002480:	1101                	addi	sp,sp,-32
    80002482:	ec06                	sd	ra,24(sp)
    80002484:	e822                	sd	s0,16(sp)
    80002486:	e426                	sd	s1,8(sp)
    80002488:	1000                	addi	s0,sp,32
    8000248a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	4f2080e7          	jalr	1266(ra) # 8000197e <myproc>
    80002494:	87aa                	mv	a5,a0
  uint oldMask = p->signalMask;
    80002496:	16c52503          	lw	a0,364(a0)
  p->signalMask = sigmask;
    8000249a:	1697a623          	sw	s1,364(a5)
  return oldMask;
}
    8000249e:	60e2                	ld	ra,24(sp)
    800024a0:	6442                	ld	s0,16(sp)
    800024a2:	64a2                	ld	s1,8(sp)
    800024a4:	6105                	addi	sp,sp,32
    800024a6:	8082                	ret

00000000800024a8 <sigaction>:
{

  struct sigaction prevAct; //CHANGED
  struct sigaction currAct; //CHANGED

  if(act == 0) //checks if act is null
    800024a8:	cdd1                	beqz	a1,80002544 <sigaction+0x9c>
{
    800024aa:	711d                	addi	sp,sp,-96
    800024ac:	ec86                	sd	ra,88(sp)
    800024ae:	e8a2                	sd	s0,80(sp)
    800024b0:	e4a6                	sd	s1,72(sp)
    800024b2:	e0ca                	sd	s2,64(sp)
    800024b4:	fc4e                	sd	s3,56(sp)
    800024b6:	f852                	sd	s4,48(sp)
    800024b8:	f456                	sd	s5,40(sp)
    800024ba:	1080                	addi	s0,sp,96
    800024bc:	84aa                	mv	s1,a0
    800024be:	89ae                	mv	s3,a1
    800024c0:	8ab2                	mv	s5,a2
    return -1; 
  if(signum == SIGKILL || signum == SIGSTOP || signum < 0 || signum >=SIGNUM)
    800024c2:	0005071b          	sext.w	a4,a0
    800024c6:	ff75079b          	addiw	a5,a0,-9
    800024ca:	9bdd                	andi	a5,a5,-9
    800024cc:	2781                	sext.w	a5,a5
    800024ce:	cfad                	beqz	a5,80002548 <sigaction+0xa0>
    800024d0:	47fd                	li	a5,31
    800024d2:	06e7ed63          	bltu	a5,a4,8000254c <sigaction+0xa4>
    return -1;  
  if(act->sigmask < 0) // CHANGED < 0
    return -1;  

  struct proc *p = myproc();
    800024d6:	fffff097          	auipc	ra,0xfffff
    800024da:	4a8080e7          	jalr	1192(ra) # 8000197e <myproc>
    800024de:	892a                	mv	s2,a0

  if(oldact < 0) // check CHANGED
    return -1;

  prevAct.sa_handler = p->sigHandlers[signum]; 
    800024e0:	00349a13          	slli	s4,s1,0x3
    800024e4:	9a2a                	add	s4,s4,a0
    800024e6:	178a3783          	ld	a5,376(s4)
    800024ea:	faf43823          	sd	a5,-80(s0)
  prevAct.sigmask = p->handlersMask[signum]; 
    800024ee:	048a                	slli	s1,s1,0x2
    800024f0:	94aa                	add	s1,s1,a0
    800024f2:	2804a783          	lw	a5,640(s1)
    800024f6:	faf42c23          	sw	a5,-72(s0)
  copyout(p->pagetable, (uint64)oldact, (char*)&prevAct, sizeof(struct sigaction));
    800024fa:	46c1                	li	a3,16
    800024fc:	fb040613          	addi	a2,s0,-80
    80002500:	85d6                	mv	a1,s5
    80002502:	6928                	ld	a0,80(a0)
    80002504:	fffff097          	auipc	ra,0xfffff
    80002508:	13a080e7          	jalr	314(ra) # 8000163e <copyout>
  // if(!p->sigHandlers[signum]){ //checks if old act is not null
  //   oldact->sa_handler = (void*)p->sigHandlers[signum];
  // }
  //copyin(p->pagetable, (char*)&p->sigHandlers[signum], (uint64)act, sizeof(struct sigaction));

  copyin(p->pagetable, (char*)&currAct, (uint64)act, sizeof(struct sigaction));
    8000250c:	46c1                	li	a3,16
    8000250e:	864e                	mv	a2,s3
    80002510:	fa040593          	addi	a1,s0,-96
    80002514:	05093503          	ld	a0,80(s2)
    80002518:	fffff097          	auipc	ra,0xfffff
    8000251c:	1b2080e7          	jalr	434(ra) # 800016ca <copyin>
  p->sigHandlers[signum] = currAct.sa_handler; 
    80002520:	fa043783          	ld	a5,-96(s0)
    80002524:	16fa3c23          	sd	a5,376(s4)
  p->handlersMask[signum] = currAct.sigmask; 
    80002528:	fa842783          	lw	a5,-88(s0)
    8000252c:	28f4a023          	sw	a5,640(s1)

  // p->sigHandlers[signum] = (void*)act->sa_handler;
  // p->signalMask = act->sigmask;
  
 return 0; //success
    80002530:	4501                	li	a0,0
}
    80002532:	60e6                	ld	ra,88(sp)
    80002534:	6446                	ld	s0,80(sp)
    80002536:	64a6                	ld	s1,72(sp)
    80002538:	6906                	ld	s2,64(sp)
    8000253a:	79e2                	ld	s3,56(sp)
    8000253c:	7a42                	ld	s4,48(sp)
    8000253e:	7aa2                	ld	s5,40(sp)
    80002540:	6125                	addi	sp,sp,96
    80002542:	8082                	ret
    return -1; 
    80002544:	557d                	li	a0,-1
}
    80002546:	8082                	ret
    return -1;  
    80002548:	557d                	li	a0,-1
    8000254a:	b7e5                	j	80002532 <sigaction+0x8a>
    8000254c:	557d                	li	a0,-1
    8000254e:	b7d5                	j	80002532 <sigaction+0x8a>

0000000080002550 <sigret>:

void sigret (void)
{
    80002550:	1101                	addi	sp,sp,-32
    80002552:	ec06                	sd	ra,24(sp)
    80002554:	e822                	sd	s0,16(sp)
    80002556:	e426                	sd	s1,8(sp)
    80002558:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000255a:	fffff097          	auipc	ra,0xfffff
    8000255e:	424080e7          	jalr	1060(ra) # 8000197e <myproc>
    80002562:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->trapframeBackup, sizeof(struct trapframe));
    80002564:	12000613          	li	a2,288
    80002568:	27853583          	ld	a1,632(a0)
    8000256c:	6d28                	ld	a0,88(a0)
    8000256e:	ffffe097          	auipc	ra,0xffffe
    80002572:	7ac080e7          	jalr	1964(ra) # 80000d1a <memmove>
  p->signalMask = p->signalMaskBackup;
    80002576:	1704a783          	lw	a5,368(s1)
    8000257a:	16f4a623          	sw	a5,364(s1)
  p->userHandlerFlag = 0;
    8000257e:	3004a023          	sw	zero,768(s1)
}
    80002582:	60e2                	ld	ra,24(sp)
    80002584:	6442                	ld	s0,16(sp)
    80002586:	64a2                	ld	s1,8(sp)
    80002588:	6105                	addi	sp,sp,32
    8000258a:	8082                	ret

000000008000258c <signal_handler>:

extern void signal_handler(){
    8000258c:	7175                	addi	sp,sp,-144
    8000258e:	e506                	sd	ra,136(sp)
    80002590:	e122                	sd	s0,128(sp)
    80002592:	fca6                	sd	s1,120(sp)
    80002594:	f8ca                	sd	s2,112(sp)
    80002596:	f4ce                	sd	s3,104(sp)
    80002598:	f0d2                	sd	s4,96(sp)
    8000259a:	ecd6                	sd	s5,88(sp)
    8000259c:	e8da                	sd	s6,80(sp)
    8000259e:	e4de                	sd	s7,72(sp)
    800025a0:	e0e2                	sd	s8,64(sp)
    800025a2:	fc66                	sd	s9,56(sp)
    800025a4:	f86a                	sd	s10,48(sp)
    800025a6:	f46e                	sd	s11,40(sp)
    800025a8:	0900                	addi	s0,sp,144
  struct proc *p = myproc();
    800025aa:	fffff097          	auipc	ra,0xfffff
    800025ae:	3d4080e7          	jalr	980(ra) # 8000197e <myproc>
    800025b2:	84aa                	mv	s1,a0
  uint32 contBit = 1 << SIGCONT;
  uint32 stopBit = 1 << SIGSTOP;
  while( ((p->pendingSignals & stopBit) !=0) && (p->pendingSignals & contBit) == 0 ){
    800025b4:	16852783          	lw	a5,360(a0)
    800025b8:	0117d713          	srli	a4,a5,0x11
    800025bc:	8b05                	andi	a4,a4,1
    800025be:	00080937          	lui	s2,0x80
    800025c2:	000209b7          	lui	s3,0x20
    800025c6:	cf19                	beqz	a4,800025e4 <signal_handler+0x58>
    800025c8:	0127f7b3          	and	a5,a5,s2
    800025cc:	2781                	sext.w	a5,a5
    800025ce:	eb99                	bnez	a5,800025e4 <signal_handler+0x58>
    // printf("***yielding\n");
    yield();
    800025d0:	00000097          	auipc	ra,0x0
    800025d4:	ac2080e7          	jalr	-1342(ra) # 80002092 <yield>
  while( ((p->pendingSignals & stopBit) !=0) && (p->pendingSignals & contBit) == 0 ){
    800025d8:	1684a783          	lw	a5,360(s1)
    800025dc:	0137f733          	and	a4,a5,s3
    800025e0:	2701                	sext.w	a4,a4
    800025e2:	f37d                	bnez	a4,800025c8 <signal_handler+0x3c>
  }

  for(int i=0; i<SIGNUM; i++){
    800025e4:	28048b13          	addi	s6,s1,640
    800025e8:	17848a13          	addi	s4,s1,376
extern void signal_handler(){
    800025ec:	4a85                	li	s5,1
    800025ee:	4901                	li	s2,0
    if( (p->pendingSignals & (1 << i)) == 0 ) //check if signal i is pending
    800025f0:	4b85                	li	s7,1
  for(int i=0; i<SIGNUM; i++){
    800025f2:	4c7d                	li	s8,31
    // if( p->pendingSignals & (1 << SIGSTOP) == 1 ) //handling SIGSTOP is in trap.c->usertrapret()
    //   continue;
    if( ( p->signalMask & (1<< i) ) != 0)
      continue;

    if (p->sigHandlers[i] == (void*)SIG_IGN){
    800025f4:	4c85                	li	s9,1
      p->pendingSignals ^= (1<<i); //xor, to set the i'th bit to 0
      continue;
    }
    if(p->sigHandlers[i] == (void*)SIG_DFL){
      switch (i)
    800025f6:	4dc5                	li	s11,17
    800025f8:	4d4d                	li	s10,19
    800025fa:	a829                	j	80002614 <signal_handler+0x88>
      p->pendingSignals ^= (1<<i); //xor, to set the i'th bit to 0
    800025fc:	01374733          	xor	a4,a4,s3
    80002600:	16e4a423          	sw	a4,360(s1)
  for(int i=0; i<SIGNUM; i++){
    80002604:	000a879b          	sext.w	a5,s5
    80002608:	0afc4d63          	blt	s8,a5,800026c2 <signal_handler+0x136>
    8000260c:	0905                	addi	s2,s2,1
    8000260e:	2a85                	addiw	s5,s5,1
    80002610:	0b11                	addi	s6,s6,4
    80002612:	0a21                	addi	s4,s4,8
    80002614:	0009069b          	sext.w	a3,s2
    if( (p->pendingSignals & (1 << i)) == 0 ) //check if signal i is pending
    80002618:	1684a703          	lw	a4,360(s1)
    8000261c:	012b99bb          	sllw	s3,s7,s2
    80002620:	013777b3          	and	a5,a4,s3
    80002624:	2781                	sext.w	a5,a5
    80002626:	dff9                	beqz	a5,80002604 <signal_handler+0x78>
    if( ( p->signalMask & (1<< i) ) != 0)
    80002628:	16c4a783          	lw	a5,364(s1)
    8000262c:	0137f7b3          	and	a5,a5,s3
    80002630:	2781                	sext.w	a5,a5
    80002632:	fbe9                	bnez	a5,80002604 <signal_handler+0x78>
    if (p->sigHandlers[i] == (void*)SIG_IGN){
    80002634:	f7443c23          	sd	s4,-136(s0)
    80002638:	000a3603          	ld	a2,0(s4)
    8000263c:	fd9600e3          	beq	a2,s9,800025fc <signal_handler+0x70>
    if(p->sigHandlers[i] == (void*)SIG_DFL){
    80002640:	c23d                	beqz	a2,800026a6 <signal_handler+0x11a>
    
    else{ //user handler for the signal
      // printf("**user handling\n");

      uint64 handlerPtr;
      copyin(p->pagetable, (char*)&handlerPtr, (uint64)p->sigHandlers[i], sizeof(uint64));
    80002642:	46a1                	li	a3,8
    80002644:	f8840593          	addi	a1,s0,-120
    80002648:	68a8                	ld	a0,80(s1)
    8000264a:	fffff097          	auipc	ra,0xfffff
    8000264e:	080080e7          	jalr	128(ra) # 800016ca <copyin>

      p->signalMaskBackup = p->signalMask;
    80002652:	16c4a783          	lw	a5,364(s1)
    80002656:	16f4a823          	sw	a5,368(s1)
      p->signalMask = p->handlersMask[i];
    8000265a:	000b2783          	lw	a5,0(s6)
    8000265e:	16f4a623          	sw	a5,364(s1)

      p->userHandlerFlag = 1;
    80002662:	3194a023          	sw	s9,768(s1)

      p->trapframe->sp = p->trapframe->sp - sizeof(struct trapframe);
    80002666:	6cb8                	ld	a4,88(s1)
    80002668:	7b1c                	ld	a5,48(a4)
    8000266a:	ee078793          	addi	a5,a5,-288
    8000266e:	fb1c                	sd	a5,48(a4)

      memmove(p->trapframeBackup, p->trapframe, sizeof(struct trapframe));
    80002670:	12000613          	li	a2,288
    80002674:	6cac                	ld	a1,88(s1)
    80002676:	2784b503          	ld	a0,632(s1)
    8000267a:	ffffe097          	auipc	ra,0xffffe
    8000267e:	6a0080e7          	jalr	1696(ra) # 80000d1a <memmove>
      p->trapframe->epc = (uint64)p->sigHandlers[i];
    80002682:	6cbc                	ld	a5,88(s1)
    80002684:	f7843703          	ld	a4,-136(s0)
    80002688:	6318                	ld	a4,0(a4)
    8000268a:	ef98                	sd	a4,24(a5)
      //TODO: reduces sp by length of the function
      //p->trapframe->sp = p->trapframe->sp - (funcEnd-funcStart);

      // copyout(p->pagetable, p->trapframe->sp, (char*)&funcStart, funcEnd-funcStart);

      p->trapframe->a0 = i;
    8000268c:	6cbc                	ld	a5,88(s1)
    8000268e:	0727b823          	sd	s2,112(a5)
      p->trapframe->ra = p->trapframe->sp;
    80002692:	6cbc                	ld	a5,88(s1)
    80002694:	7b98                	ld	a4,48(a5)
    80002696:	f798                	sd	a4,40(a5)

      p->pendingSignals ^= (1 << i);
    80002698:	1684a783          	lw	a5,360(s1)
    8000269c:	0137c9b3          	xor	s3,a5,s3
    800026a0:	1734a423          	sw	s3,360(s1)
    800026a4:	b785                	j	80002604 <signal_handler+0x78>
      switch (i)
    800026a6:	01b68e63          	beq	a3,s11,800026c2 <signal_handler+0x136>
    800026aa:	05a69163          	bne	a3,s10,800026ec <signal_handler+0x160>
        if((p->pendingSignals & (1<< SIGSTOP)) == 0){
    800026ae:	000207b7          	lui	a5,0x20
    800026b2:	8ff9                	and	a5,a5,a4
    800026b4:	2781                	sext.w	a5,a5
    800026b6:	c78d                	beqz	a5,800026e0 <signal_handler+0x154>
        p->pendingSignals ^= (1<<SIGCONT); //set CONT bit to 0 
    800026b8:	000a07b7          	lui	a5,0xa0
    800026bc:	8f3d                	xor	a4,a4,a5
    800026be:	16e4a423          	sw	a4,360(s1)

    }
  }
}
    800026c2:	60aa                	ld	ra,136(sp)
    800026c4:	640a                	ld	s0,128(sp)
    800026c6:	74e6                	ld	s1,120(sp)
    800026c8:	7946                	ld	s2,112(sp)
    800026ca:	79a6                	ld	s3,104(sp)
    800026cc:	7a06                	ld	s4,96(sp)
    800026ce:	6ae6                	ld	s5,88(sp)
    800026d0:	6b46                	ld	s6,80(sp)
    800026d2:	6ba6                	ld	s7,72(sp)
    800026d4:	6c06                	ld	s8,64(sp)
    800026d6:	7ce2                	ld	s9,56(sp)
    800026d8:	7d42                	ld	s10,48(sp)
    800026da:	7da2                	ld	s11,40(sp)
    800026dc:	6149                	addi	sp,sp,144
    800026de:	8082                	ret
          p->pendingSignals ^= (1<<SIGCONT);
    800026e0:	000807b7          	lui	a5,0x80
    800026e4:	8f3d                	xor	a4,a4,a5
    800026e6:	16e4a423          	sw	a4,360(s1)
  for(int i=0; i<SIGNUM; i++){
    800026ea:	b70d                	j	8000260c <signal_handler+0x80>
        p->killed = 1;
    800026ec:	4785                	li	a5,1
    800026ee:	d49c                	sw	a5,40(s1)
        if(p->state == SLEEPING){
    800026f0:	4c98                	lw	a4,24(s1)
    800026f2:	4789                	li	a5,2
    800026f4:	fcf717e3          	bne	a4,a5,800026c2 <signal_handler+0x136>
          p->state = RUNNABLE;
    800026f8:	478d                	li	a5,3
    800026fa:	cc9c                	sw	a5,24(s1)
    800026fc:	b7d9                	j	800026c2 <signal_handler+0x136>

00000000800026fe <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026fe:	7179                	addi	sp,sp,-48
    80002700:	f406                	sd	ra,40(sp)
    80002702:	f022                	sd	s0,32(sp)
    80002704:	ec26                	sd	s1,24(sp)
    80002706:	e84a                	sd	s2,16(sp)
    80002708:	e44e                	sd	s3,8(sp)
    8000270a:	e052                	sd	s4,0(sp)
    8000270c:	1800                	addi	s0,sp,48
    8000270e:	84aa                	mv	s1,a0
    80002710:	892e                	mv	s2,a1
    80002712:	89b2                	mv	s3,a2
    80002714:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002716:	fffff097          	auipc	ra,0xfffff
    8000271a:	268080e7          	jalr	616(ra) # 8000197e <myproc>
  if(user_dst){
    8000271e:	c08d                	beqz	s1,80002740 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002720:	86d2                	mv	a3,s4
    80002722:	864e                	mv	a2,s3
    80002724:	85ca                	mv	a1,s2
    80002726:	6928                	ld	a0,80(a0)
    80002728:	fffff097          	auipc	ra,0xfffff
    8000272c:	f16080e7          	jalr	-234(ra) # 8000163e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002730:	70a2                	ld	ra,40(sp)
    80002732:	7402                	ld	s0,32(sp)
    80002734:	64e2                	ld	s1,24(sp)
    80002736:	6942                	ld	s2,16(sp)
    80002738:	69a2                	ld	s3,8(sp)
    8000273a:	6a02                	ld	s4,0(sp)
    8000273c:	6145                	addi	sp,sp,48
    8000273e:	8082                	ret
    memmove((char *)dst, src, len);
    80002740:	000a061b          	sext.w	a2,s4
    80002744:	85ce                	mv	a1,s3
    80002746:	854a                	mv	a0,s2
    80002748:	ffffe097          	auipc	ra,0xffffe
    8000274c:	5d2080e7          	jalr	1490(ra) # 80000d1a <memmove>
    return 0;
    80002750:	8526                	mv	a0,s1
    80002752:	bff9                	j	80002730 <either_copyout+0x32>

0000000080002754 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002754:	7179                	addi	sp,sp,-48
    80002756:	f406                	sd	ra,40(sp)
    80002758:	f022                	sd	s0,32(sp)
    8000275a:	ec26                	sd	s1,24(sp)
    8000275c:	e84a                	sd	s2,16(sp)
    8000275e:	e44e                	sd	s3,8(sp)
    80002760:	e052                	sd	s4,0(sp)
    80002762:	1800                	addi	s0,sp,48
    80002764:	892a                	mv	s2,a0
    80002766:	84ae                	mv	s1,a1
    80002768:	89b2                	mv	s3,a2
    8000276a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000276c:	fffff097          	auipc	ra,0xfffff
    80002770:	212080e7          	jalr	530(ra) # 8000197e <myproc>
  if(user_src){
    80002774:	c08d                	beqz	s1,80002796 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002776:	86d2                	mv	a3,s4
    80002778:	864e                	mv	a2,s3
    8000277a:	85ca                	mv	a1,s2
    8000277c:	6928                	ld	a0,80(a0)
    8000277e:	fffff097          	auipc	ra,0xfffff
    80002782:	f4c080e7          	jalr	-180(ra) # 800016ca <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002786:	70a2                	ld	ra,40(sp)
    80002788:	7402                	ld	s0,32(sp)
    8000278a:	64e2                	ld	s1,24(sp)
    8000278c:	6942                	ld	s2,16(sp)
    8000278e:	69a2                	ld	s3,8(sp)
    80002790:	6a02                	ld	s4,0(sp)
    80002792:	6145                	addi	sp,sp,48
    80002794:	8082                	ret
    memmove(dst, (char*)src, len);
    80002796:	000a061b          	sext.w	a2,s4
    8000279a:	85ce                	mv	a1,s3
    8000279c:	854a                	mv	a0,s2
    8000279e:	ffffe097          	auipc	ra,0xffffe
    800027a2:	57c080e7          	jalr	1404(ra) # 80000d1a <memmove>
    return 0;
    800027a6:	8526                	mv	a0,s1
    800027a8:	bff9                	j	80002786 <either_copyin+0x32>

00000000800027aa <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800027aa:	715d                	addi	sp,sp,-80
    800027ac:	e486                	sd	ra,72(sp)
    800027ae:	e0a2                	sd	s0,64(sp)
    800027b0:	fc26                	sd	s1,56(sp)
    800027b2:	f84a                	sd	s2,48(sp)
    800027b4:	f44e                	sd	s3,40(sp)
    800027b6:	f052                	sd	s4,32(sp)
    800027b8:	ec56                	sd	s5,24(sp)
    800027ba:	e85a                	sd	s6,16(sp)
    800027bc:	e45e                	sd	s7,8(sp)
    800027be:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800027c0:	00006517          	auipc	a0,0x6
    800027c4:	90850513          	addi	a0,a0,-1784 # 800080c8 <digits+0x88>
    800027c8:	ffffe097          	auipc	ra,0xffffe
    800027cc:	dac080e7          	jalr	-596(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027d0:	0000f497          	auipc	s1,0xf
    800027d4:	05848493          	addi	s1,s1,88 # 80011828 <proc+0x158>
    800027d8:	0001b917          	auipc	s2,0x1b
    800027dc:	25090913          	addi	s2,s2,592 # 8001da28 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027e0:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800027e2:	00006997          	auipc	s3,0x6
    800027e6:	a8698993          	addi	s3,s3,-1402 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    800027ea:	00006a97          	auipc	s5,0x6
    800027ee:	a86a8a93          	addi	s5,s5,-1402 # 80008270 <digits+0x230>
    printf("\n");
    800027f2:	00006a17          	auipc	s4,0x6
    800027f6:	8d6a0a13          	addi	s4,s4,-1834 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027fa:	00006b97          	auipc	s7,0x6
    800027fe:	aaeb8b93          	addi	s7,s7,-1362 # 800082a8 <states.0>
    80002802:	a00d                	j	80002824 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002804:	ed86a583          	lw	a1,-296(a3)
    80002808:	8556                	mv	a0,s5
    8000280a:	ffffe097          	auipc	ra,0xffffe
    8000280e:	d6a080e7          	jalr	-662(ra) # 80000574 <printf>
    printf("\n");
    80002812:	8552                	mv	a0,s4
    80002814:	ffffe097          	auipc	ra,0xffffe
    80002818:	d60080e7          	jalr	-672(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000281c:	30848493          	addi	s1,s1,776
    80002820:	03248263          	beq	s1,s2,80002844 <procdump+0x9a>
    if(p->state == UNUSED)
    80002824:	86a6                	mv	a3,s1
    80002826:	ec04a783          	lw	a5,-320(s1)
    8000282a:	dbed                	beqz	a5,8000281c <procdump+0x72>
      state = "???";
    8000282c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000282e:	fcfb6be3          	bltu	s6,a5,80002804 <procdump+0x5a>
    80002832:	02079713          	slli	a4,a5,0x20
    80002836:	01d75793          	srli	a5,a4,0x1d
    8000283a:	97de                	add	a5,a5,s7
    8000283c:	6390                	ld	a2,0(a5)
    8000283e:	f279                	bnez	a2,80002804 <procdump+0x5a>
      state = "???";
    80002840:	864e                	mv	a2,s3
    80002842:	b7c9                	j	80002804 <procdump+0x5a>
  }
  
}
    80002844:	60a6                	ld	ra,72(sp)
    80002846:	6406                	ld	s0,64(sp)
    80002848:	74e2                	ld	s1,56(sp)
    8000284a:	7942                	ld	s2,48(sp)
    8000284c:	79a2                	ld	s3,40(sp)
    8000284e:	7a02                	ld	s4,32(sp)
    80002850:	6ae2                	ld	s5,24(sp)
    80002852:	6b42                	ld	s6,16(sp)
    80002854:	6ba2                	ld	s7,8(sp)
    80002856:	6161                	addi	sp,sp,80
    80002858:	8082                	ret

000000008000285a <bsem_alloc>:
//-1 not init
// 0 lock is take - acquired
// 1 lock is free


int bsem_alloc(){
    8000285a:	1141                	addi	sp,sp,-16
    8000285c:	e422                	sd	s0,8(sp)
    8000285e:	0800                	addi	s0,sp,16
    for(int i =0; i< MAX_BSEM; i++){
    80002860:	00006797          	auipc	a5,0x6
    80002864:	03878793          	addi	a5,a5,56 # 80008898 <semaphore_table>
    80002868:	4501                	li	a0,0
      if(semaphore_table[i] == -1){ // free semaphore
    8000286a:	56fd                	li	a3,-1
    for(int i =0; i< MAX_BSEM; i++){
    8000286c:	08000613          	li	a2,128
      if(semaphore_table[i] == -1){ // free semaphore
    80002870:	4398                	lw	a4,0(a5)
    80002872:	00d70863          	beq	a4,a3,80002882 <bsem_alloc+0x28>
    for(int i =0; i< MAX_BSEM; i++){
    80002876:	2505                	addiw	a0,a0,1
    80002878:	0791                	addi	a5,a5,4
    8000287a:	fec51be3          	bne	a0,a2,80002870 <bsem_alloc+0x16>
        semaphore_table[i] = 1; // unlock semaphore
        return i;
      }
    }
      return -1; // if all full
    8000287e:	557d                	li	a0,-1
    80002880:	a811                	j	80002894 <bsem_alloc+0x3a>
        semaphore_table[i] = 1; // unlock semaphore
    80002882:	00251713          	slli	a4,a0,0x2
    80002886:	00006797          	auipc	a5,0x6
    8000288a:	fda78793          	addi	a5,a5,-38 # 80008860 <initcode>
    8000288e:	97ba                	add	a5,a5,a4
    80002890:	4705                	li	a4,1
    80002892:	df98                	sw	a4,56(a5)
}
    80002894:	6422                	ld	s0,8(sp)
    80002896:	0141                	addi	sp,sp,16
    80002898:	8082                	ret

000000008000289a <bsem_free>:

void bsem_free(int semNum){
    8000289a:	1141                	addi	sp,sp,-16
    8000289c:	e422                	sd	s0,8(sp)
    8000289e:	0800                	addi	s0,sp,16
  semaphore_table[semNum] = -1;
    800028a0:	00251793          	slli	a5,a0,0x2
    800028a4:	00006517          	auipc	a0,0x6
    800028a8:	fbc50513          	addi	a0,a0,-68 # 80008860 <initcode>
    800028ac:	953e                	add	a0,a0,a5
    800028ae:	57fd                	li	a5,-1
    800028b0:	dd1c                	sw	a5,56(a0)
}
    800028b2:	6422                	ld	s0,8(sp)
    800028b4:	0141                	addi	sp,sp,16
    800028b6:	8082                	ret

00000000800028b8 <bsem_down>:
//       semaphore_table[semNum] = 1; // free
//     }
// }

void bsem_down(int semNum){
    if(semaphore_table[semNum] == -1) // if semaphore wasnt init - not suppose to happend
    800028b8:	00251713          	slli	a4,a0,0x2
    800028bc:	00006797          	auipc	a5,0x6
    800028c0:	fa478793          	addi	a5,a5,-92 # 80008860 <initcode>
    800028c4:	97ba                	add	a5,a5,a4
    800028c6:	5f9c                	lw	a5,56(a5)
    800028c8:	577d                	li	a4,-1
    800028ca:	06e78363          	beq	a5,a4,80002930 <bsem_down+0x78>
void bsem_down(int semNum){
    800028ce:	1101                	addi	sp,sp,-32
    800028d0:	ec06                	sd	ra,24(sp)
    800028d2:	e822                	sd	s0,16(sp)
    800028d4:	e426                	sd	s1,8(sp)
    800028d6:	e04a                	sd	s2,0(sp)
    800028d8:	1000                	addi	s0,sp,32
    800028da:	84aa                	mv	s1,a0
      return;
    // while(true){

    
    if(semaphore_table[semNum] == 1) // lock is free
    800028dc:	4705                	li	a4,1
    800028de:	02e79163          	bne	a5,a4,80002900 <bsem_down+0x48>
      semaphore_table[semNum] = 0; // locks and finish
    800028e2:	00251493          	slli	s1,a0,0x2
    800028e6:	00006517          	auipc	a0,0x6
    800028ea:	f7a50513          	addi	a0,a0,-134 # 80008860 <initcode>
    800028ee:	94aa                	add	s1,s1,a0
    800028f0:	0204ac23          	sw	zero,56(s1)
      sched();
      release(&p->lock);
      // kill(p->pid,SIGSTOP);  // make procces stop
    }
  // } end while
}
    800028f4:	60e2                	ld	ra,24(sp)
    800028f6:	6442                	ld	s0,16(sp)
    800028f8:	64a2                	ld	s1,8(sp)
    800028fa:	6902                	ld	s2,0(sp)
    800028fc:	6105                	addi	sp,sp,32
    800028fe:	8082                	ret
      struct proc *p = myproc();
    80002900:	fffff097          	auipc	ra,0xfffff
    80002904:	07e080e7          	jalr	126(ra) # 8000197e <myproc>
    80002908:	892a                	mv	s2,a0
      acquire(&p->lock);
    8000290a:	ffffe097          	auipc	ra,0xffffe
    8000290e:	2b8080e7          	jalr	696(ra) # 80000bc2 <acquire>
      p->waitingForSem = semNum;
    80002912:	30992223          	sw	s1,772(s2)
      p->state = SLEEPING; // needed?
    80002916:	4789                	li	a5,2
    80002918:	00f92c23          	sw	a5,24(s2)
      sched();
    8000291c:	fffff097          	auipc	ra,0xfffff
    80002920:	6a0080e7          	jalr	1696(ra) # 80001fbc <sched>
      release(&p->lock);
    80002924:	854a                	mv	a0,s2
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	350080e7          	jalr	848(ra) # 80000c76 <release>
    8000292e:	b7d9                	j	800028f4 <bsem_down+0x3c>
    80002930:	8082                	ret

0000000080002932 <bsem_up>:

void bsem_up(int semNum){
    if(semaphore_table[semNum] == -1) // if semaphore wasnt init - not suppose to happend
    80002932:	00251713          	slli	a4,a0,0x2
    80002936:	00006797          	auipc	a5,0x6
    8000293a:	f2a78793          	addi	a5,a5,-214 # 80008860 <initcode>
    8000293e:	97ba                	add	a5,a5,a4
    80002940:	5f9c                	lw	a5,56(a5)
    80002942:	2785                	addiw	a5,a5,1
    80002944:	9bf5                	andi	a5,a5,-3
    80002946:	2781                	sext.w	a5,a5
    80002948:	cfb5                	beqz	a5,800029c4 <bsem_up+0x92>
void bsem_up(int semNum){
    8000294a:	7179                	addi	sp,sp,-48
    8000294c:	f406                	sd	ra,40(sp)
    8000294e:	f022                	sd	s0,32(sp)
    80002950:	ec26                	sd	s1,24(sp)
    80002952:	e84a                	sd	s2,16(sp)
    80002954:	e44e                	sd	s3,8(sp)
    80002956:	1800                	addi	s0,sp,48
    80002958:	892a                	mv	s2,a0
    if(semaphore_table[semNum] == 1) // lock is free
      return; // do nothing
  
    else{ // lock is taken
      struct proc *p;
      for(p = proc; p<&proc[NPROC];p++){
    8000295a:	0000f497          	auipc	s1,0xf
    8000295e:	d7648493          	addi	s1,s1,-650 # 800116d0 <proc>
    80002962:	0001b997          	auipc	s3,0x1b
    80002966:	f6e98993          	addi	s3,s3,-146 # 8001d8d0 <tickslock>
          acquire(&p->lock);
    8000296a:	8526                	mv	a0,s1
    8000296c:	ffffe097          	auipc	ra,0xffffe
    80002970:	256080e7          	jalr	598(ra) # 80000bc2 <acquire>
          if(p->waitingForSem == semNum){
    80002974:	3044a783          	lw	a5,772(s1)
    80002978:	03278563          	beq	a5,s2,800029a2 <bsem_up+0x70>
            p->waitingForSem = -1;
            release(&p->lock);
            // kill(p->pid,SIGCONT); // make procces run again
            return; // someone took the semaphore and finish
          }
          release(&p->lock);
    8000297c:	8526                	mv	a0,s1
    8000297e:	ffffe097          	auipc	ra,0xffffe
    80002982:	2f8080e7          	jalr	760(ra) # 80000c76 <release>
      for(p = proc; p<&proc[NPROC];p++){
    80002986:	30848493          	addi	s1,s1,776
    8000298a:	ff3490e3          	bne	s1,s3,8000296a <bsem_up+0x38>
      }
      //no one waits for semaphore
      semaphore_table[semNum] = 1; // free
    8000298e:	090a                	slli	s2,s2,0x2
    80002990:	00006797          	auipc	a5,0x6
    80002994:	ed078793          	addi	a5,a5,-304 # 80008860 <initcode>
    80002998:	993e                	add	s2,s2,a5
    8000299a:	4785                	li	a5,1
    8000299c:	02f92c23          	sw	a5,56(s2)
    800029a0:	a819                	j	800029b6 <bsem_up+0x84>
            p->state = RUNNABLE;
    800029a2:	478d                	li	a5,3
    800029a4:	cc9c                	sw	a5,24(s1)
            p->waitingForSem = -1;
    800029a6:	57fd                	li	a5,-1
    800029a8:	30f4a223          	sw	a5,772(s1)
            release(&p->lock);
    800029ac:	8526                	mv	a0,s1
    800029ae:	ffffe097          	auipc	ra,0xffffe
    800029b2:	2c8080e7          	jalr	712(ra) # 80000c76 <release>
    }
}
    800029b6:	70a2                	ld	ra,40(sp)
    800029b8:	7402                	ld	s0,32(sp)
    800029ba:	64e2                	ld	s1,24(sp)
    800029bc:	6942                	ld	s2,16(sp)
    800029be:	69a2                	ld	s3,8(sp)
    800029c0:	6145                	addi	sp,sp,48
    800029c2:	8082                	ret
    800029c4:	8082                	ret

00000000800029c6 <kthread_create>:

/*Calling kthread_create will create a new thread within the context of the calling
process. returns the new thread's id, or -1 in error.
*/
int kthread_create(void (*start_func)(), void* stack){
    800029c6:	1141                	addi	sp,sp,-16
    800029c8:	e422                	sd	s0,8(sp)
    800029ca:	0800                	addi	s0,sp,16
  // t->trapframe->epc = start_func;
  // t->state = TRUNNABLE;

  // release(&t->lock);
  // return t->id;
}
    800029cc:	557d                	li	a0,-1
    800029ce:	6422                	ld	s0,8(sp)
    800029d0:	0141                	addi	sp,sp,16
    800029d2:	8082                	ret

00000000800029d4 <kthread_id>:

//returns calling thread id
int kthread_id(){
    800029d4:	1141                	addi	sp,sp,-16
    800029d6:	e422                	sd	s0,8(sp)
    800029d8:	0800                	addi	s0,sp,16
  return -1;

  // struct thread *t=mythread();
  // return t->id;
}
    800029da:	557d                	li	a0,-1
    800029dc:	6422                	ld	s0,8(sp)
    800029de:	0141                	addi	sp,sp,16
    800029e0:	8082                	ret

00000000800029e2 <kthread_exit>:
/*This function terminates the execution of the calling thread. If called by a thread
(even the main thread) while other threads exist within the same process, it shouldn't
terminate the whole process. If it is the last running thread, the process should
terminate.
*/
void kthread_exit(int status){
    800029e2:	1141                	addi	sp,sp,-16
    800029e4:	e422                	sd	s0,8(sp)
    800029e6:	0800                	addi	s0,sp,16
  //   {
  //     t->parent_proc->killed = 1;
  //     release(&tempThread->lock);
  //   }
  // }
}
    800029e8:	6422                	ld	s0,8(sp)
    800029ea:	0141                	addi	sp,sp,16
    800029ec:	8082                	ret

00000000800029ee <kthread_join>:

int kthread_join(int thread_id, uint64 status){
    800029ee:	1141                	addi	sp,sp,-16
    800029f0:	e422                	sd	s0,8(sp)
    800029f2:	0800                	addi	s0,sp,16
  //   }
    
  //   // Wait for the thread to exit.
  //   sleep(t, &wait_lock);  //DOC: wait-sleep
  // }
    800029f4:	557d                	li	a0,-1
    800029f6:	6422                	ld	s0,8(sp)
    800029f8:	0141                	addi	sp,sp,16
    800029fa:	8082                	ret

00000000800029fc <swtch>:
    800029fc:	00153023          	sd	ra,0(a0)
    80002a00:	00253423          	sd	sp,8(a0)
    80002a04:	e900                	sd	s0,16(a0)
    80002a06:	ed04                	sd	s1,24(a0)
    80002a08:	03253023          	sd	s2,32(a0)
    80002a0c:	03353423          	sd	s3,40(a0)
    80002a10:	03453823          	sd	s4,48(a0)
    80002a14:	03553c23          	sd	s5,56(a0)
    80002a18:	05653023          	sd	s6,64(a0)
    80002a1c:	05753423          	sd	s7,72(a0)
    80002a20:	05853823          	sd	s8,80(a0)
    80002a24:	05953c23          	sd	s9,88(a0)
    80002a28:	07a53023          	sd	s10,96(a0)
    80002a2c:	07b53423          	sd	s11,104(a0)
    80002a30:	0005b083          	ld	ra,0(a1)
    80002a34:	0085b103          	ld	sp,8(a1)
    80002a38:	6980                	ld	s0,16(a1)
    80002a3a:	6d84                	ld	s1,24(a1)
    80002a3c:	0205b903          	ld	s2,32(a1)
    80002a40:	0285b983          	ld	s3,40(a1)
    80002a44:	0305ba03          	ld	s4,48(a1)
    80002a48:	0385ba83          	ld	s5,56(a1)
    80002a4c:	0405bb03          	ld	s6,64(a1)
    80002a50:	0485bb83          	ld	s7,72(a1)
    80002a54:	0505bc03          	ld	s8,80(a1)
    80002a58:	0585bc83          	ld	s9,88(a1)
    80002a5c:	0605bd03          	ld	s10,96(a1)
    80002a60:	0685bd83          	ld	s11,104(a1)
    80002a64:	8082                	ret

0000000080002a66 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a66:	1141                	addi	sp,sp,-16
    80002a68:	e406                	sd	ra,8(sp)
    80002a6a:	e022                	sd	s0,0(sp)
    80002a6c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a6e:	00006597          	auipc	a1,0x6
    80002a72:	86a58593          	addi	a1,a1,-1942 # 800082d8 <states.0+0x30>
    80002a76:	0001b517          	auipc	a0,0x1b
    80002a7a:	e5a50513          	addi	a0,a0,-422 # 8001d8d0 <tickslock>
    80002a7e:	ffffe097          	auipc	ra,0xffffe
    80002a82:	0b4080e7          	jalr	180(ra) # 80000b32 <initlock>
}
    80002a86:	60a2                	ld	ra,8(sp)
    80002a88:	6402                	ld	s0,0(sp)
    80002a8a:	0141                	addi	sp,sp,16
    80002a8c:	8082                	ret

0000000080002a8e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a8e:	1141                	addi	sp,sp,-16
    80002a90:	e422                	sd	s0,8(sp)
    80002a92:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a94:	00003797          	auipc	a5,0x3
    80002a98:	70c78793          	addi	a5,a5,1804 # 800061a0 <kernelvec>
    80002a9c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002aa0:	6422                	ld	s0,8(sp)
    80002aa2:	0141                	addi	sp,sp,16
    80002aa4:	8082                	ret

0000000080002aa6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002aa6:	1101                	addi	sp,sp,-32
    80002aa8:	ec06                	sd	ra,24(sp)
    80002aaa:	e822                	sd	s0,16(sp)
    80002aac:	e426                	sd	s1,8(sp)
    80002aae:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002ab0:	fffff097          	auipc	ra,0xfffff
    80002ab4:	ece080e7          	jalr	-306(ra) # 8000197e <myproc>
    80002ab8:	84aa                	mv	s1,a0
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aba:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002abe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ac0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  //CHANGED put here signal_handler();
  signal_handler(); // function from proc.c
    80002ac4:	00000097          	auipc	ra,0x0
    80002ac8:	ac8080e7          	jalr	-1336(ra) # 8000258c <signal_handler>
  //   // printf("***yielding\n");
  //   yield();
  // }

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002acc:	00004617          	auipc	a2,0x4
    80002ad0:	53460613          	addi	a2,a2,1332 # 80007000 <_trampoline>
    80002ad4:	00004697          	auipc	a3,0x4
    80002ad8:	52c68693          	addi	a3,a3,1324 # 80007000 <_trampoline>
    80002adc:	8e91                	sub	a3,a3,a2
    80002ade:	040007b7          	lui	a5,0x4000
    80002ae2:	17fd                	addi	a5,a5,-1
    80002ae4:	07b2                	slli	a5,a5,0xc
    80002ae6:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ae8:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002aec:	6cb8                	ld	a4,88(s1)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002aee:	180026f3          	csrr	a3,satp
    80002af2:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002af4:	6cb8                	ld	a4,88(s1)
    80002af6:	60b4                	ld	a3,64(s1)
    80002af8:	6585                	lui	a1,0x1
    80002afa:	96ae                	add	a3,a3,a1
    80002afc:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002afe:	6cb8                	ld	a4,88(s1)
    80002b00:	00000697          	auipc	a3,0x0
    80002b04:	13a68693          	addi	a3,a3,314 # 80002c3a <usertrap>
    80002b08:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b0a:	6cb8                	ld	a4,88(s1)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b0c:	8692                	mv	a3,tp
    80002b0e:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b10:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b14:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b18:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b1c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b20:	6cb8                	ld	a4,88(s1)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b22:	6f18                	ld	a4,24(a4)
    80002b24:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b28:	68ac                	ld	a1,80(s1)
    80002b2a:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002b2c:	00004717          	auipc	a4,0x4
    80002b30:	56470713          	addi	a4,a4,1380 # 80007090 <userret>
    80002b34:	8f11                	sub	a4,a4,a2
    80002b36:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002b38:	577d                	li	a4,-1
    80002b3a:	177e                	slli	a4,a4,0x3f
    80002b3c:	8dd9                	or	a1,a1,a4
    80002b3e:	02000537          	lui	a0,0x2000
    80002b42:	157d                	addi	a0,a0,-1
    80002b44:	0536                	slli	a0,a0,0xd
    80002b46:	9782                	jalr	a5
}
    80002b48:	60e2                	ld	ra,24(sp)
    80002b4a:	6442                	ld	s0,16(sp)
    80002b4c:	64a2                	ld	s1,8(sp)
    80002b4e:	6105                	addi	sp,sp,32
    80002b50:	8082                	ret

0000000080002b52 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b52:	1101                	addi	sp,sp,-32
    80002b54:	ec06                	sd	ra,24(sp)
    80002b56:	e822                	sd	s0,16(sp)
    80002b58:	e426                	sd	s1,8(sp)
    80002b5a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002b5c:	0001b497          	auipc	s1,0x1b
    80002b60:	d7448493          	addi	s1,s1,-652 # 8001d8d0 <tickslock>
    80002b64:	8526                	mv	a0,s1
    80002b66:	ffffe097          	auipc	ra,0xffffe
    80002b6a:	05c080e7          	jalr	92(ra) # 80000bc2 <acquire>
  ticks++;
    80002b6e:	00006517          	auipc	a0,0x6
    80002b72:	4c250513          	addi	a0,a0,1218 # 80009030 <ticks>
    80002b76:	411c                	lw	a5,0(a0)
    80002b78:	2785                	addiw	a5,a5,1
    80002b7a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002b7c:	fffff097          	auipc	ra,0xfffff
    80002b80:	6de080e7          	jalr	1758(ra) # 8000225a <wakeup>
  release(&tickslock);
    80002b84:	8526                	mv	a0,s1
    80002b86:	ffffe097          	auipc	ra,0xffffe
    80002b8a:	0f0080e7          	jalr	240(ra) # 80000c76 <release>
}
    80002b8e:	60e2                	ld	ra,24(sp)
    80002b90:	6442                	ld	s0,16(sp)
    80002b92:	64a2                	ld	s1,8(sp)
    80002b94:	6105                	addi	sp,sp,32
    80002b96:	8082                	ret

0000000080002b98 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002b98:	1101                	addi	sp,sp,-32
    80002b9a:	ec06                	sd	ra,24(sp)
    80002b9c:	e822                	sd	s0,16(sp)
    80002b9e:	e426                	sd	s1,8(sp)
    80002ba0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ba2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002ba6:	00074d63          	bltz	a4,80002bc0 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002baa:	57fd                	li	a5,-1
    80002bac:	17fe                	slli	a5,a5,0x3f
    80002bae:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002bb0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002bb2:	06f70363          	beq	a4,a5,80002c18 <devintr+0x80>
  }
}
    80002bb6:	60e2                	ld	ra,24(sp)
    80002bb8:	6442                	ld	s0,16(sp)
    80002bba:	64a2                	ld	s1,8(sp)
    80002bbc:	6105                	addi	sp,sp,32
    80002bbe:	8082                	ret
     (scause & 0xff) == 9){
    80002bc0:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002bc4:	46a5                	li	a3,9
    80002bc6:	fed792e3          	bne	a5,a3,80002baa <devintr+0x12>
    int irq = plic_claim();
    80002bca:	00003097          	auipc	ra,0x3
    80002bce:	6de080e7          	jalr	1758(ra) # 800062a8 <plic_claim>
    80002bd2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002bd4:	47a9                	li	a5,10
    80002bd6:	02f50763          	beq	a0,a5,80002c04 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002bda:	4785                	li	a5,1
    80002bdc:	02f50963          	beq	a0,a5,80002c0e <devintr+0x76>
    return 1;
    80002be0:	4505                	li	a0,1
    } else if(irq){
    80002be2:	d8f1                	beqz	s1,80002bb6 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002be4:	85a6                	mv	a1,s1
    80002be6:	00005517          	auipc	a0,0x5
    80002bea:	6fa50513          	addi	a0,a0,1786 # 800082e0 <states.0+0x38>
    80002bee:	ffffe097          	auipc	ra,0xffffe
    80002bf2:	986080e7          	jalr	-1658(ra) # 80000574 <printf>
      plic_complete(irq);
    80002bf6:	8526                	mv	a0,s1
    80002bf8:	00003097          	auipc	ra,0x3
    80002bfc:	6d4080e7          	jalr	1748(ra) # 800062cc <plic_complete>
    return 1;
    80002c00:	4505                	li	a0,1
    80002c02:	bf55                	j	80002bb6 <devintr+0x1e>
      uartintr();
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	d82080e7          	jalr	-638(ra) # 80000986 <uartintr>
    80002c0c:	b7ed                	j	80002bf6 <devintr+0x5e>
      virtio_disk_intr();
    80002c0e:	00004097          	auipc	ra,0x4
    80002c12:	b50080e7          	jalr	-1200(ra) # 8000675e <virtio_disk_intr>
    80002c16:	b7c5                	j	80002bf6 <devintr+0x5e>
    if(cpuid() == 0){
    80002c18:	fffff097          	auipc	ra,0xfffff
    80002c1c:	d3a080e7          	jalr	-710(ra) # 80001952 <cpuid>
    80002c20:	c901                	beqz	a0,80002c30 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c22:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c26:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c28:	14479073          	csrw	sip,a5
    return 2;
    80002c2c:	4509                	li	a0,2
    80002c2e:	b761                	j	80002bb6 <devintr+0x1e>
      clockintr();
    80002c30:	00000097          	auipc	ra,0x0
    80002c34:	f22080e7          	jalr	-222(ra) # 80002b52 <clockintr>
    80002c38:	b7ed                	j	80002c22 <devintr+0x8a>

0000000080002c3a <usertrap>:
{
    80002c3a:	1101                	addi	sp,sp,-32
    80002c3c:	ec06                	sd	ra,24(sp)
    80002c3e:	e822                	sd	s0,16(sp)
    80002c40:	e426                	sd	s1,8(sp)
    80002c42:	e04a                	sd	s2,0(sp)
    80002c44:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c46:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c4a:	1007f793          	andi	a5,a5,256
    80002c4e:	e3ad                	bnez	a5,80002cb0 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c50:	00003797          	auipc	a5,0x3
    80002c54:	55078793          	addi	a5,a5,1360 # 800061a0 <kernelvec>
    80002c58:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	d22080e7          	jalr	-734(ra) # 8000197e <myproc>
    80002c64:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c66:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c68:	14102773          	csrr	a4,sepc
    80002c6c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c6e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c72:	47a1                	li	a5,8
    80002c74:	04f71c63          	bne	a4,a5,80002ccc <usertrap+0x92>
    if(p->killed)
    80002c78:	551c                	lw	a5,40(a0)
    80002c7a:	e3b9                	bnez	a5,80002cc0 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002c7c:	6cb8                	ld	a4,88(s1)
    80002c7e:	6f1c                	ld	a5,24(a4)
    80002c80:	0791                	addi	a5,a5,4
    80002c82:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c88:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c8c:	10079073          	csrw	sstatus,a5
    syscall();
    80002c90:	00000097          	auipc	ra,0x0
    80002c94:	2e0080e7          	jalr	736(ra) # 80002f70 <syscall>
  if(p->killed)
    80002c98:	549c                	lw	a5,40(s1)
    80002c9a:	ebc1                	bnez	a5,80002d2a <usertrap+0xf0>
  usertrapret();
    80002c9c:	00000097          	auipc	ra,0x0
    80002ca0:	e0a080e7          	jalr	-502(ra) # 80002aa6 <usertrapret>
}
    80002ca4:	60e2                	ld	ra,24(sp)
    80002ca6:	6442                	ld	s0,16(sp)
    80002ca8:	64a2                	ld	s1,8(sp)
    80002caa:	6902                	ld	s2,0(sp)
    80002cac:	6105                	addi	sp,sp,32
    80002cae:	8082                	ret
    panic("usertrap: not from user mode");
    80002cb0:	00005517          	auipc	a0,0x5
    80002cb4:	65050513          	addi	a0,a0,1616 # 80008300 <states.0+0x58>
    80002cb8:	ffffe097          	auipc	ra,0xffffe
    80002cbc:	872080e7          	jalr	-1934(ra) # 8000052a <panic>
      exit(-1);
    80002cc0:	557d                	li	a0,-1
    80002cc2:	fffff097          	auipc	ra,0xfffff
    80002cc6:	668080e7          	jalr	1640(ra) # 8000232a <exit>
    80002cca:	bf4d                	j	80002c7c <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002ccc:	00000097          	auipc	ra,0x0
    80002cd0:	ecc080e7          	jalr	-308(ra) # 80002b98 <devintr>
    80002cd4:	892a                	mv	s2,a0
    80002cd6:	c501                	beqz	a0,80002cde <usertrap+0xa4>
  if(p->killed)
    80002cd8:	549c                	lw	a5,40(s1)
    80002cda:	c3a1                	beqz	a5,80002d1a <usertrap+0xe0>
    80002cdc:	a815                	j	80002d10 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cde:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ce2:	5890                	lw	a2,48(s1)
    80002ce4:	00005517          	auipc	a0,0x5
    80002ce8:	63c50513          	addi	a0,a0,1596 # 80008320 <states.0+0x78>
    80002cec:	ffffe097          	auipc	ra,0xffffe
    80002cf0:	888080e7          	jalr	-1912(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cf4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cf8:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cfc:	00005517          	auipc	a0,0x5
    80002d00:	65450513          	addi	a0,a0,1620 # 80008350 <states.0+0xa8>
    80002d04:	ffffe097          	auipc	ra,0xffffe
    80002d08:	870080e7          	jalr	-1936(ra) # 80000574 <printf>
    p->killed = 1;
    80002d0c:	4785                	li	a5,1
    80002d0e:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002d10:	557d                	li	a0,-1
    80002d12:	fffff097          	auipc	ra,0xfffff
    80002d16:	618080e7          	jalr	1560(ra) # 8000232a <exit>
  if(which_dev == 2)
    80002d1a:	4789                	li	a5,2
    80002d1c:	f8f910e3          	bne	s2,a5,80002c9c <usertrap+0x62>
    yield();
    80002d20:	fffff097          	auipc	ra,0xfffff
    80002d24:	372080e7          	jalr	882(ra) # 80002092 <yield>
    80002d28:	bf95                	j	80002c9c <usertrap+0x62>
  int which_dev = 0;
    80002d2a:	4901                	li	s2,0
    80002d2c:	b7d5                	j	80002d10 <usertrap+0xd6>

0000000080002d2e <kerneltrap>:
{
    80002d2e:	7179                	addi	sp,sp,-48
    80002d30:	f406                	sd	ra,40(sp)
    80002d32:	f022                	sd	s0,32(sp)
    80002d34:	ec26                	sd	s1,24(sp)
    80002d36:	e84a                	sd	s2,16(sp)
    80002d38:	e44e                	sd	s3,8(sp)
    80002d3a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d3c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d40:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d44:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002d48:	1004f793          	andi	a5,s1,256
    80002d4c:	cb85                	beqz	a5,80002d7c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d52:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d54:	ef85                	bnez	a5,80002d8c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002d56:	00000097          	auipc	ra,0x0
    80002d5a:	e42080e7          	jalr	-446(ra) # 80002b98 <devintr>
    80002d5e:	cd1d                	beqz	a0,80002d9c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d60:	4789                	li	a5,2
    80002d62:	06f50a63          	beq	a0,a5,80002dd6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d66:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d6a:	10049073          	csrw	sstatus,s1
}
    80002d6e:	70a2                	ld	ra,40(sp)
    80002d70:	7402                	ld	s0,32(sp)
    80002d72:	64e2                	ld	s1,24(sp)
    80002d74:	6942                	ld	s2,16(sp)
    80002d76:	69a2                	ld	s3,8(sp)
    80002d78:	6145                	addi	sp,sp,48
    80002d7a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d7c:	00005517          	auipc	a0,0x5
    80002d80:	5f450513          	addi	a0,a0,1524 # 80008370 <states.0+0xc8>
    80002d84:	ffffd097          	auipc	ra,0xffffd
    80002d88:	7a6080e7          	jalr	1958(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80002d8c:	00005517          	auipc	a0,0x5
    80002d90:	60c50513          	addi	a0,a0,1548 # 80008398 <states.0+0xf0>
    80002d94:	ffffd097          	auipc	ra,0xffffd
    80002d98:	796080e7          	jalr	1942(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80002d9c:	85ce                	mv	a1,s3
    80002d9e:	00005517          	auipc	a0,0x5
    80002da2:	61a50513          	addi	a0,a0,1562 # 800083b8 <states.0+0x110>
    80002da6:	ffffd097          	auipc	ra,0xffffd
    80002daa:	7ce080e7          	jalr	1998(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dae:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002db2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002db6:	00005517          	auipc	a0,0x5
    80002dba:	61250513          	addi	a0,a0,1554 # 800083c8 <states.0+0x120>
    80002dbe:	ffffd097          	auipc	ra,0xffffd
    80002dc2:	7b6080e7          	jalr	1974(ra) # 80000574 <printf>
    panic("kerneltrap");
    80002dc6:	00005517          	auipc	a0,0x5
    80002dca:	61a50513          	addi	a0,a0,1562 # 800083e0 <states.0+0x138>
    80002dce:	ffffd097          	auipc	ra,0xffffd
    80002dd2:	75c080e7          	jalr	1884(ra) # 8000052a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002dd6:	fffff097          	auipc	ra,0xfffff
    80002dda:	ba8080e7          	jalr	-1112(ra) # 8000197e <myproc>
    80002dde:	d541                	beqz	a0,80002d66 <kerneltrap+0x38>
    80002de0:	fffff097          	auipc	ra,0xfffff
    80002de4:	b9e080e7          	jalr	-1122(ra) # 8000197e <myproc>
    80002de8:	4d18                	lw	a4,24(a0)
    80002dea:	4791                	li	a5,4
    80002dec:	f6f71de3          	bne	a4,a5,80002d66 <kerneltrap+0x38>
    yield();
    80002df0:	fffff097          	auipc	ra,0xfffff
    80002df4:	2a2080e7          	jalr	674(ra) # 80002092 <yield>
    80002df8:	b7bd                	j	80002d66 <kerneltrap+0x38>

0000000080002dfa <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002dfa:	1101                	addi	sp,sp,-32
    80002dfc:	ec06                	sd	ra,24(sp)
    80002dfe:	e822                	sd	s0,16(sp)
    80002e00:	e426                	sd	s1,8(sp)
    80002e02:	1000                	addi	s0,sp,32
    80002e04:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e06:	fffff097          	auipc	ra,0xfffff
    80002e0a:	b78080e7          	jalr	-1160(ra) # 8000197e <myproc>
  switch (n) {
    80002e0e:	4795                	li	a5,5
    80002e10:	0497e163          	bltu	a5,s1,80002e52 <argraw+0x58>
    80002e14:	048a                	slli	s1,s1,0x2
    80002e16:	00005717          	auipc	a4,0x5
    80002e1a:	60270713          	addi	a4,a4,1538 # 80008418 <states.0+0x170>
    80002e1e:	94ba                	add	s1,s1,a4
    80002e20:	409c                	lw	a5,0(s1)
    80002e22:	97ba                	add	a5,a5,a4
    80002e24:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002e26:	6d3c                	ld	a5,88(a0)
    80002e28:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e2a:	60e2                	ld	ra,24(sp)
    80002e2c:	6442                	ld	s0,16(sp)
    80002e2e:	64a2                	ld	s1,8(sp)
    80002e30:	6105                	addi	sp,sp,32
    80002e32:	8082                	ret
    return p->trapframe->a1;
    80002e34:	6d3c                	ld	a5,88(a0)
    80002e36:	7fa8                	ld	a0,120(a5)
    80002e38:	bfcd                	j	80002e2a <argraw+0x30>
    return p->trapframe->a2;
    80002e3a:	6d3c                	ld	a5,88(a0)
    80002e3c:	63c8                	ld	a0,128(a5)
    80002e3e:	b7f5                	j	80002e2a <argraw+0x30>
    return p->trapframe->a3;
    80002e40:	6d3c                	ld	a5,88(a0)
    80002e42:	67c8                	ld	a0,136(a5)
    80002e44:	b7dd                	j	80002e2a <argraw+0x30>
    return p->trapframe->a4;
    80002e46:	6d3c                	ld	a5,88(a0)
    80002e48:	6bc8                	ld	a0,144(a5)
    80002e4a:	b7c5                	j	80002e2a <argraw+0x30>
    return p->trapframe->a5;
    80002e4c:	6d3c                	ld	a5,88(a0)
    80002e4e:	6fc8                	ld	a0,152(a5)
    80002e50:	bfe9                	j	80002e2a <argraw+0x30>
  panic("argraw");
    80002e52:	00005517          	auipc	a0,0x5
    80002e56:	59e50513          	addi	a0,a0,1438 # 800083f0 <states.0+0x148>
    80002e5a:	ffffd097          	auipc	ra,0xffffd
    80002e5e:	6d0080e7          	jalr	1744(ra) # 8000052a <panic>

0000000080002e62 <fetchaddr>:
{
    80002e62:	1101                	addi	sp,sp,-32
    80002e64:	ec06                	sd	ra,24(sp)
    80002e66:	e822                	sd	s0,16(sp)
    80002e68:	e426                	sd	s1,8(sp)
    80002e6a:	e04a                	sd	s2,0(sp)
    80002e6c:	1000                	addi	s0,sp,32
    80002e6e:	84aa                	mv	s1,a0
    80002e70:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e72:	fffff097          	auipc	ra,0xfffff
    80002e76:	b0c080e7          	jalr	-1268(ra) # 8000197e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002e7a:	653c                	ld	a5,72(a0)
    80002e7c:	02f4f863          	bgeu	s1,a5,80002eac <fetchaddr+0x4a>
    80002e80:	00848713          	addi	a4,s1,8
    80002e84:	02e7e663          	bltu	a5,a4,80002eb0 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e88:	46a1                	li	a3,8
    80002e8a:	8626                	mv	a2,s1
    80002e8c:	85ca                	mv	a1,s2
    80002e8e:	6928                	ld	a0,80(a0)
    80002e90:	fffff097          	auipc	ra,0xfffff
    80002e94:	83a080e7          	jalr	-1990(ra) # 800016ca <copyin>
    80002e98:	00a03533          	snez	a0,a0
    80002e9c:	40a00533          	neg	a0,a0
}
    80002ea0:	60e2                	ld	ra,24(sp)
    80002ea2:	6442                	ld	s0,16(sp)
    80002ea4:	64a2                	ld	s1,8(sp)
    80002ea6:	6902                	ld	s2,0(sp)
    80002ea8:	6105                	addi	sp,sp,32
    80002eaa:	8082                	ret
    return -1;
    80002eac:	557d                	li	a0,-1
    80002eae:	bfcd                	j	80002ea0 <fetchaddr+0x3e>
    80002eb0:	557d                	li	a0,-1
    80002eb2:	b7fd                	j	80002ea0 <fetchaddr+0x3e>

0000000080002eb4 <fetchstr>:
{
    80002eb4:	7179                	addi	sp,sp,-48
    80002eb6:	f406                	sd	ra,40(sp)
    80002eb8:	f022                	sd	s0,32(sp)
    80002eba:	ec26                	sd	s1,24(sp)
    80002ebc:	e84a                	sd	s2,16(sp)
    80002ebe:	e44e                	sd	s3,8(sp)
    80002ec0:	1800                	addi	s0,sp,48
    80002ec2:	892a                	mv	s2,a0
    80002ec4:	84ae                	mv	s1,a1
    80002ec6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ec8:	fffff097          	auipc	ra,0xfffff
    80002ecc:	ab6080e7          	jalr	-1354(ra) # 8000197e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002ed0:	86ce                	mv	a3,s3
    80002ed2:	864a                	mv	a2,s2
    80002ed4:	85a6                	mv	a1,s1
    80002ed6:	6928                	ld	a0,80(a0)
    80002ed8:	fffff097          	auipc	ra,0xfffff
    80002edc:	880080e7          	jalr	-1920(ra) # 80001758 <copyinstr>
  if(err < 0)
    80002ee0:	00054763          	bltz	a0,80002eee <fetchstr+0x3a>
  return strlen(buf);
    80002ee4:	8526                	mv	a0,s1
    80002ee6:	ffffe097          	auipc	ra,0xffffe
    80002eea:	f5c080e7          	jalr	-164(ra) # 80000e42 <strlen>
}
    80002eee:	70a2                	ld	ra,40(sp)
    80002ef0:	7402                	ld	s0,32(sp)
    80002ef2:	64e2                	ld	s1,24(sp)
    80002ef4:	6942                	ld	s2,16(sp)
    80002ef6:	69a2                	ld	s3,8(sp)
    80002ef8:	6145                	addi	sp,sp,48
    80002efa:	8082                	ret

0000000080002efc <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002efc:	1101                	addi	sp,sp,-32
    80002efe:	ec06                	sd	ra,24(sp)
    80002f00:	e822                	sd	s0,16(sp)
    80002f02:	e426                	sd	s1,8(sp)
    80002f04:	1000                	addi	s0,sp,32
    80002f06:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f08:	00000097          	auipc	ra,0x0
    80002f0c:	ef2080e7          	jalr	-270(ra) # 80002dfa <argraw>
    80002f10:	c088                	sw	a0,0(s1)
  return 0;
}
    80002f12:	4501                	li	a0,0
    80002f14:	60e2                	ld	ra,24(sp)
    80002f16:	6442                	ld	s0,16(sp)
    80002f18:	64a2                	ld	s1,8(sp)
    80002f1a:	6105                	addi	sp,sp,32
    80002f1c:	8082                	ret

0000000080002f1e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002f1e:	1101                	addi	sp,sp,-32
    80002f20:	ec06                	sd	ra,24(sp)
    80002f22:	e822                	sd	s0,16(sp)
    80002f24:	e426                	sd	s1,8(sp)
    80002f26:	1000                	addi	s0,sp,32
    80002f28:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f2a:	00000097          	auipc	ra,0x0
    80002f2e:	ed0080e7          	jalr	-304(ra) # 80002dfa <argraw>
    80002f32:	e088                	sd	a0,0(s1)
  return 0;
}
    80002f34:	4501                	li	a0,0
    80002f36:	60e2                	ld	ra,24(sp)
    80002f38:	6442                	ld	s0,16(sp)
    80002f3a:	64a2                	ld	s1,8(sp)
    80002f3c:	6105                	addi	sp,sp,32
    80002f3e:	8082                	ret

0000000080002f40 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002f40:	1101                	addi	sp,sp,-32
    80002f42:	ec06                	sd	ra,24(sp)
    80002f44:	e822                	sd	s0,16(sp)
    80002f46:	e426                	sd	s1,8(sp)
    80002f48:	e04a                	sd	s2,0(sp)
    80002f4a:	1000                	addi	s0,sp,32
    80002f4c:	84ae                	mv	s1,a1
    80002f4e:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002f50:	00000097          	auipc	ra,0x0
    80002f54:	eaa080e7          	jalr	-342(ra) # 80002dfa <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002f58:	864a                	mv	a2,s2
    80002f5a:	85a6                	mv	a1,s1
    80002f5c:	00000097          	auipc	ra,0x0
    80002f60:	f58080e7          	jalr	-168(ra) # 80002eb4 <fetchstr>
}
    80002f64:	60e2                	ld	ra,24(sp)
    80002f66:	6442                	ld	s0,16(sp)
    80002f68:	64a2                	ld	s1,8(sp)
    80002f6a:	6902                	ld	s2,0(sp)
    80002f6c:	6105                	addi	sp,sp,32
    80002f6e:	8082                	ret

0000000080002f70 <syscall>:
[SYS_kthread_join]  sys_kthread_join,
};

void
syscall(void)
{
    80002f70:	1101                	addi	sp,sp,-32
    80002f72:	ec06                	sd	ra,24(sp)
    80002f74:	e822                	sd	s0,16(sp)
    80002f76:	e426                	sd	s1,8(sp)
    80002f78:	e04a                	sd	s2,0(sp)
    80002f7a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002f7c:	fffff097          	auipc	ra,0xfffff
    80002f80:	a02080e7          	jalr	-1534(ra) # 8000197e <myproc>
    80002f84:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002f86:	05853903          	ld	s2,88(a0)
    80002f8a:	0a893783          	ld	a5,168(s2)
    80002f8e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f92:	37fd                	addiw	a5,a5,-1
    80002f94:	477d                	li	a4,31
    80002f96:	00f76f63          	bltu	a4,a5,80002fb4 <syscall+0x44>
    80002f9a:	00369713          	slli	a4,a3,0x3
    80002f9e:	00005797          	auipc	a5,0x5
    80002fa2:	49278793          	addi	a5,a5,1170 # 80008430 <syscalls>
    80002fa6:	97ba                	add	a5,a5,a4
    80002fa8:	639c                	ld	a5,0(a5)
    80002faa:	c789                	beqz	a5,80002fb4 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002fac:	9782                	jalr	a5
    80002fae:	06a93823          	sd	a0,112(s2)
    80002fb2:	a839                	j	80002fd0 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002fb4:	15848613          	addi	a2,s1,344
    80002fb8:	588c                	lw	a1,48(s1)
    80002fba:	00005517          	auipc	a0,0x5
    80002fbe:	43e50513          	addi	a0,a0,1086 # 800083f8 <states.0+0x150>
    80002fc2:	ffffd097          	auipc	ra,0xffffd
    80002fc6:	5b2080e7          	jalr	1458(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002fca:	6cbc                	ld	a5,88(s1)
    80002fcc:	577d                	li	a4,-1
    80002fce:	fbb8                	sd	a4,112(a5)
  }
}
    80002fd0:	60e2                	ld	ra,24(sp)
    80002fd2:	6442                	ld	s0,16(sp)
    80002fd4:	64a2                	ld	s1,8(sp)
    80002fd6:	6902                	ld	s2,0(sp)
    80002fd8:	6105                	addi	sp,sp,32
    80002fda:	8082                	ret

0000000080002fdc <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002fdc:	1101                	addi	sp,sp,-32
    80002fde:	ec06                	sd	ra,24(sp)
    80002fe0:	e822                	sd	s0,16(sp)
    80002fe2:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002fe4:	fec40593          	addi	a1,s0,-20
    80002fe8:	4501                	li	a0,0
    80002fea:	00000097          	auipc	ra,0x0
    80002fee:	f12080e7          	jalr	-238(ra) # 80002efc <argint>
    return -1;
    80002ff2:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ff4:	00054963          	bltz	a0,80003006 <sys_exit+0x2a>
  exit(n);
    80002ff8:	fec42503          	lw	a0,-20(s0)
    80002ffc:	fffff097          	auipc	ra,0xfffff
    80003000:	32e080e7          	jalr	814(ra) # 8000232a <exit>
  return 0;  // not reached
    80003004:	4781                	li	a5,0
}
    80003006:	853e                	mv	a0,a5
    80003008:	60e2                	ld	ra,24(sp)
    8000300a:	6442                	ld	s0,16(sp)
    8000300c:	6105                	addi	sp,sp,32
    8000300e:	8082                	ret

0000000080003010 <sys_kthread_create>:

uint64
sys_kthread_create(void)
{
    80003010:	1101                	addi	sp,sp,-32
    80003012:	ec06                	sd	ra,24(sp)
    80003014:	e822                	sd	s0,16(sp)
    80003016:	1000                	addi	s0,sp,32
  uint64 start_func;
  uint64 stack;
  if(argaddr(0, &start_func) < 0)
    80003018:	fe840593          	addi	a1,s0,-24
    8000301c:	4501                	li	a0,0
    8000301e:	00000097          	auipc	ra,0x0
    80003022:	f00080e7          	jalr	-256(ra) # 80002f1e <argaddr>
    return -1;
    80003026:	57fd                	li	a5,-1
  if(argaddr(0, &start_func) < 0)
    80003028:	02054563          	bltz	a0,80003052 <sys_kthread_create+0x42>
  if(argaddr(1, &stack) < 0)
    8000302c:	fe040593          	addi	a1,s0,-32
    80003030:	4505                	li	a0,1
    80003032:	00000097          	auipc	ra,0x0
    80003036:	eec080e7          	jalr	-276(ra) # 80002f1e <argaddr>
    return -1;
    8000303a:	57fd                	li	a5,-1
  if(argaddr(1, &stack) < 0)
    8000303c:	00054b63          	bltz	a0,80003052 <sys_kthread_create+0x42>
  return kthread_create((void*)start_func, &stack);
    80003040:	fe040593          	addi	a1,s0,-32
    80003044:	fe843503          	ld	a0,-24(s0)
    80003048:	00000097          	auipc	ra,0x0
    8000304c:	97e080e7          	jalr	-1666(ra) # 800029c6 <kthread_create>
    80003050:	87aa                	mv	a5,a0
}
    80003052:	853e                	mv	a0,a5
    80003054:	60e2                	ld	ra,24(sp)
    80003056:	6442                	ld	s0,16(sp)
    80003058:	6105                	addi	sp,sp,32
    8000305a:	8082                	ret

000000008000305c <sys_kthread_id>:

uint64
sys_kthread_id(void){
    8000305c:	1141                	addi	sp,sp,-16
    8000305e:	e406                	sd	ra,8(sp)
    80003060:	e022                	sd	s0,0(sp)
    80003062:	0800                	addi	s0,sp,16
  return kthread_id();
    80003064:	00000097          	auipc	ra,0x0
    80003068:	970080e7          	jalr	-1680(ra) # 800029d4 <kthread_id>
}
    8000306c:	60a2                	ld	ra,8(sp)
    8000306e:	6402                	ld	s0,0(sp)
    80003070:	0141                	addi	sp,sp,16
    80003072:	8082                	ret

0000000080003074 <sys_kthread_exit>:

uint64
sys_kthread_exit(void)
{
    80003074:	1101                	addi	sp,sp,-32
    80003076:	ec06                	sd	ra,24(sp)
    80003078:	e822                	sd	s0,16(sp)
    8000307a:	1000                	addi	s0,sp,32
  int status;
  if(argint(0, &status) < 0)
    8000307c:	fec40593          	addi	a1,s0,-20
    80003080:	4501                	li	a0,0
    80003082:	00000097          	auipc	ra,0x0
    80003086:	e7a080e7          	jalr	-390(ra) # 80002efc <argint>
    return -1;
    8000308a:	57fd                	li	a5,-1
  if(argint(0, &status) < 0)
    8000308c:	00054963          	bltz	a0,8000309e <sys_kthread_exit+0x2a>
  kthread_exit(status);
    80003090:	fec42503          	lw	a0,-20(s0)
    80003094:	00000097          	auipc	ra,0x0
    80003098:	94e080e7          	jalr	-1714(ra) # 800029e2 <kthread_exit>
  return 0;
    8000309c:	4781                	li	a5,0
}
    8000309e:	853e                	mv	a0,a5
    800030a0:	60e2                	ld	ra,24(sp)
    800030a2:	6442                	ld	s0,16(sp)
    800030a4:	6105                	addi	sp,sp,32
    800030a6:	8082                	ret

00000000800030a8 <sys_kthread_join>:

uint64
sys_kthread_join(void)
{
    800030a8:	1101                	addi	sp,sp,-32
    800030aa:	ec06                	sd	ra,24(sp)
    800030ac:	e822                	sd	s0,16(sp)
    800030ae:	1000                	addi	s0,sp,32
  int thread_id;
  uint64 status;
  //int* status;
  if(argint(0, &thread_id) < 0)
    800030b0:	fec40593          	addi	a1,s0,-20
    800030b4:	4501                	li	a0,0
    800030b6:	00000097          	auipc	ra,0x0
    800030ba:	e46080e7          	jalr	-442(ra) # 80002efc <argint>
    return -1;
    800030be:	57fd                	li	a5,-1
  if(argint(0, &thread_id) < 0)
    800030c0:	02054563          	bltz	a0,800030ea <sys_kthread_join+0x42>
  if(argaddr(1, &status) < 0)
    800030c4:	fe040593          	addi	a1,s0,-32
    800030c8:	4505                	li	a0,1
    800030ca:	00000097          	auipc	ra,0x0
    800030ce:	e54080e7          	jalr	-428(ra) # 80002f1e <argaddr>
    return -1;
    800030d2:	57fd                	li	a5,-1
  if(argaddr(1, &status) < 0)
    800030d4:	00054b63          	bltz	a0,800030ea <sys_kthread_join+0x42>
  return kthread_join(thread_id, status);
    800030d8:	fe043583          	ld	a1,-32(s0)
    800030dc:	fec42503          	lw	a0,-20(s0)
    800030e0:	00000097          	auipc	ra,0x0
    800030e4:	90e080e7          	jalr	-1778(ra) # 800029ee <kthread_join>
    800030e8:	87aa                	mv	a5,a0
}
    800030ea:	853e                	mv	a0,a5
    800030ec:	60e2                	ld	ra,24(sp)
    800030ee:	6442                	ld	s0,16(sp)
    800030f0:	6105                	addi	sp,sp,32
    800030f2:	8082                	ret

00000000800030f4 <sys_bsem_alloc>:

uint64
sys_bsem_alloc(void)
{
    800030f4:	1141                	addi	sp,sp,-16
    800030f6:	e406                	sd	ra,8(sp)
    800030f8:	e022                	sd	s0,0(sp)
    800030fa:	0800                	addi	s0,sp,16
  return bsem_alloc();
    800030fc:	fffff097          	auipc	ra,0xfffff
    80003100:	75e080e7          	jalr	1886(ra) # 8000285a <bsem_alloc>
}
    80003104:	60a2                	ld	ra,8(sp)
    80003106:	6402                	ld	s0,0(sp)
    80003108:	0141                	addi	sp,sp,16
    8000310a:	8082                	ret

000000008000310c <sys_bsem_free>:

uint64
sys_bsem_free(void)
{
    8000310c:	1101                	addi	sp,sp,-32
    8000310e:	ec06                	sd	ra,24(sp)
    80003110:	e822                	sd	s0,16(sp)
    80003112:	1000                	addi	s0,sp,32
  int semNum;
  if(argint(0, &semNum) < 0)
    80003114:	fec40593          	addi	a1,s0,-20
    80003118:	4501                	li	a0,0
    8000311a:	00000097          	auipc	ra,0x0
    8000311e:	de2080e7          	jalr	-542(ra) # 80002efc <argint>
    return -1;
    80003122:	57fd                	li	a5,-1
  if(argint(0, &semNum) < 0)
    80003124:	00054963          	bltz	a0,80003136 <sys_bsem_free+0x2a>
  bsem_free(semNum);
    80003128:	fec42503          	lw	a0,-20(s0)
    8000312c:	fffff097          	auipc	ra,0xfffff
    80003130:	76e080e7          	jalr	1902(ra) # 8000289a <bsem_free>
  return 0;
    80003134:	4781                	li	a5,0
}
    80003136:	853e                	mv	a0,a5
    80003138:	60e2                	ld	ra,24(sp)
    8000313a:	6442                	ld	s0,16(sp)
    8000313c:	6105                	addi	sp,sp,32
    8000313e:	8082                	ret

0000000080003140 <sys_bsem_down>:

uint64
sys_bsem_down(void)
{
    80003140:	1101                	addi	sp,sp,-32
    80003142:	ec06                	sd	ra,24(sp)
    80003144:	e822                	sd	s0,16(sp)
    80003146:	1000                	addi	s0,sp,32
  int semNum;
  if(argint(0, &semNum) < 0)
    80003148:	fec40593          	addi	a1,s0,-20
    8000314c:	4501                	li	a0,0
    8000314e:	00000097          	auipc	ra,0x0
    80003152:	dae080e7          	jalr	-594(ra) # 80002efc <argint>
    return -1;
    80003156:	57fd                	li	a5,-1
  if(argint(0, &semNum) < 0)
    80003158:	00054963          	bltz	a0,8000316a <sys_bsem_down+0x2a>
  bsem_down(semNum);
    8000315c:	fec42503          	lw	a0,-20(s0)
    80003160:	fffff097          	auipc	ra,0xfffff
    80003164:	758080e7          	jalr	1880(ra) # 800028b8 <bsem_down>
  return 0;
    80003168:	4781                	li	a5,0
}
    8000316a:	853e                	mv	a0,a5
    8000316c:	60e2                	ld	ra,24(sp)
    8000316e:	6442                	ld	s0,16(sp)
    80003170:	6105                	addi	sp,sp,32
    80003172:	8082                	ret

0000000080003174 <sys_bsem_up>:

uint64
sys_bsem_up(void)
{
    80003174:	1101                	addi	sp,sp,-32
    80003176:	ec06                	sd	ra,24(sp)
    80003178:	e822                	sd	s0,16(sp)
    8000317a:	1000                	addi	s0,sp,32
  int semNum;
  if(argint(0, &semNum) < 0)
    8000317c:	fec40593          	addi	a1,s0,-20
    80003180:	4501                	li	a0,0
    80003182:	00000097          	auipc	ra,0x0
    80003186:	d7a080e7          	jalr	-646(ra) # 80002efc <argint>
    return -1;
    8000318a:	57fd                	li	a5,-1
  if(argint(0, &semNum) < 0)
    8000318c:	00054963          	bltz	a0,8000319e <sys_bsem_up+0x2a>
  bsem_up(semNum);
    80003190:	fec42503          	lw	a0,-20(s0)
    80003194:	fffff097          	auipc	ra,0xfffff
    80003198:	79e080e7          	jalr	1950(ra) # 80002932 <bsem_up>
  return 0;
    8000319c:	4781                	li	a5,0
}
    8000319e:	853e                	mv	a0,a5
    800031a0:	60e2                	ld	ra,24(sp)
    800031a2:	6442                	ld	s0,16(sp)
    800031a4:	6105                	addi	sp,sp,32
    800031a6:	8082                	ret

00000000800031a8 <sys_sigprocmask>:

//on success returns old mask. else - returns -1.
uint64
sys_sigprocmask(void)
{
    800031a8:	1101                	addi	sp,sp,-32
    800031aa:	ec06                	sd	ra,24(sp)
    800031ac:	e822                	sd	s0,16(sp)
    800031ae:	1000                	addi	s0,sp,32
  int sigmask;
  if(argint(0, &sigmask) < 0)
    800031b0:	fec40593          	addi	a1,s0,-20
    800031b4:	4501                	li	a0,0
    800031b6:	00000097          	auipc	ra,0x0
    800031ba:	d46080e7          	jalr	-698(ra) # 80002efc <argint>
    800031be:	87aa                	mv	a5,a0
    return -1;
    800031c0:	557d                	li	a0,-1
  if(argint(0, &sigmask) < 0)
    800031c2:	0007ca63          	bltz	a5,800031d6 <sys_sigprocmask+0x2e>
  return sigprocmask(sigmask);
    800031c6:	fec42503          	lw	a0,-20(s0)
    800031ca:	fffff097          	auipc	ra,0xfffff
    800031ce:	2b6080e7          	jalr	694(ra) # 80002480 <sigprocmask>
    800031d2:	1502                	slli	a0,a0,0x20
    800031d4:	9101                	srli	a0,a0,0x20
}
    800031d6:	60e2                	ld	ra,24(sp)
    800031d8:	6442                	ld	s0,16(sp)
    800031da:	6105                	addi	sp,sp,32
    800031dc:	8082                	ret

00000000800031de <sys_sigaction>:

//register a new handler for a given signal number (signum).
// sigaction returns 0 on success, on error, -1 is returned.
uint64
sys_sigaction(void)
{
    800031de:	7179                	addi	sp,sp,-48
    800031e0:	f406                	sd	ra,40(sp)
    800031e2:	f022                	sd	s0,32(sp)
    800031e4:	1800                	addi	s0,sp,48
  int signum;
  uint64 act;
  uint64 oldact;
  if(argint(0, &signum) < 0)
    800031e6:	fec40593          	addi	a1,s0,-20
    800031ea:	4501                	li	a0,0
    800031ec:	00000097          	auipc	ra,0x0
    800031f0:	d10080e7          	jalr	-752(ra) # 80002efc <argint>
    return -1;
    800031f4:	57fd                	li	a5,-1
  if(argint(0, &signum) < 0)
    800031f6:	04054163          	bltz	a0,80003238 <sys_sigaction+0x5a>
  if(argaddr(1, &act) < 0)
    800031fa:	fe040593          	addi	a1,s0,-32
    800031fe:	4505                	li	a0,1
    80003200:	00000097          	auipc	ra,0x0
    80003204:	d1e080e7          	jalr	-738(ra) # 80002f1e <argaddr>
    return -1;
    80003208:	57fd                	li	a5,-1
  if(argaddr(1, &act) < 0)
    8000320a:	02054763          	bltz	a0,80003238 <sys_sigaction+0x5a>
  if(argaddr(2, &oldact) < 0)
    8000320e:	fd840593          	addi	a1,s0,-40
    80003212:	4509                	li	a0,2
    80003214:	00000097          	auipc	ra,0x0
    80003218:	d0a080e7          	jalr	-758(ra) # 80002f1e <argaddr>
    return -1;
    8000321c:	57fd                	li	a5,-1
  if(argaddr(2, &oldact) < 0)
    8000321e:	00054d63          	bltz	a0,80003238 <sys_sigaction+0x5a>

  return sigaction(signum, (struct sigaction*)act, (struct sigaction*)oldact);
    80003222:	fd843603          	ld	a2,-40(s0)
    80003226:	fe043583          	ld	a1,-32(s0)
    8000322a:	fec42503          	lw	a0,-20(s0)
    8000322e:	fffff097          	auipc	ra,0xfffff
    80003232:	27a080e7          	jalr	634(ra) # 800024a8 <sigaction>
    80003236:	87aa                	mv	a5,a0
}
    80003238:	853e                	mv	a0,a5
    8000323a:	70a2                	ld	ra,40(sp)
    8000323c:	7402                	ld	s0,32(sp)
    8000323e:	6145                	addi	sp,sp,48
    80003240:	8082                	ret

0000000080003242 <sys_sigret>:

uint64
sys_sigret(void)
{
    80003242:	1141                	addi	sp,sp,-16
    80003244:	e406                	sd	ra,8(sp)
    80003246:	e022                	sd	s0,0(sp)
    80003248:	0800                	addi	s0,sp,16
  sigret();
    8000324a:	fffff097          	auipc	ra,0xfffff
    8000324e:	306080e7          	jalr	774(ra) # 80002550 <sigret>
  return 0;
}
    80003252:	4501                	li	a0,0
    80003254:	60a2                	ld	ra,8(sp)
    80003256:	6402                	ld	s0,0(sp)
    80003258:	0141                	addi	sp,sp,16
    8000325a:	8082                	ret

000000008000325c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000325c:	1141                	addi	sp,sp,-16
    8000325e:	e406                	sd	ra,8(sp)
    80003260:	e022                	sd	s0,0(sp)
    80003262:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003264:	ffffe097          	auipc	ra,0xffffe
    80003268:	71a080e7          	jalr	1818(ra) # 8000197e <myproc>
}
    8000326c:	5908                	lw	a0,48(a0)
    8000326e:	60a2                	ld	ra,8(sp)
    80003270:	6402                	ld	s0,0(sp)
    80003272:	0141                	addi	sp,sp,16
    80003274:	8082                	ret

0000000080003276 <sys_fork>:

uint64
sys_fork(void)
{
    80003276:	1141                	addi	sp,sp,-16
    80003278:	e406                	sd	ra,8(sp)
    8000327a:	e022                	sd	s0,0(sp)
    8000327c:	0800                	addi	s0,sp,16
  return fork();
    8000327e:	fffff097          	auipc	ra,0xfffff
    80003282:	b2c080e7          	jalr	-1236(ra) # 80001daa <fork>
}
    80003286:	60a2                	ld	ra,8(sp)
    80003288:	6402                	ld	s0,0(sp)
    8000328a:	0141                	addi	sp,sp,16
    8000328c:	8082                	ret

000000008000328e <sys_wait>:

uint64
sys_wait(void)
{
    8000328e:	1101                	addi	sp,sp,-32
    80003290:	ec06                	sd	ra,24(sp)
    80003292:	e822                	sd	s0,16(sp)
    80003294:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003296:	fe840593          	addi	a1,s0,-24
    8000329a:	4501                	li	a0,0
    8000329c:	00000097          	auipc	ra,0x0
    800032a0:	c82080e7          	jalr	-894(ra) # 80002f1e <argaddr>
    800032a4:	87aa                	mv	a5,a0
    return -1;
    800032a6:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800032a8:	0007c863          	bltz	a5,800032b8 <sys_wait+0x2a>
  return wait(p);
    800032ac:	fe843503          	ld	a0,-24(s0)
    800032b0:	fffff097          	auipc	ra,0xfffff
    800032b4:	e82080e7          	jalr	-382(ra) # 80002132 <wait>
}
    800032b8:	60e2                	ld	ra,24(sp)
    800032ba:	6442                	ld	s0,16(sp)
    800032bc:	6105                	addi	sp,sp,32
    800032be:	8082                	ret

00000000800032c0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800032c0:	7179                	addi	sp,sp,-48
    800032c2:	f406                	sd	ra,40(sp)
    800032c4:	f022                	sd	s0,32(sp)
    800032c6:	ec26                	sd	s1,24(sp)
    800032c8:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800032ca:	fdc40593          	addi	a1,s0,-36
    800032ce:	4501                	li	a0,0
    800032d0:	00000097          	auipc	ra,0x0
    800032d4:	c2c080e7          	jalr	-980(ra) # 80002efc <argint>
    return -1;
    800032d8:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    800032da:	00054f63          	bltz	a0,800032f8 <sys_sbrk+0x38>
  addr = myproc()->sz;
    800032de:	ffffe097          	auipc	ra,0xffffe
    800032e2:	6a0080e7          	jalr	1696(ra) # 8000197e <myproc>
    800032e6:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    800032e8:	fdc42503          	lw	a0,-36(s0)
    800032ec:	fffff097          	auipc	ra,0xfffff
    800032f0:	a4a080e7          	jalr	-1462(ra) # 80001d36 <growproc>
    800032f4:	00054863          	bltz	a0,80003304 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800032f8:	8526                	mv	a0,s1
    800032fa:	70a2                	ld	ra,40(sp)
    800032fc:	7402                	ld	s0,32(sp)
    800032fe:	64e2                	ld	s1,24(sp)
    80003300:	6145                	addi	sp,sp,48
    80003302:	8082                	ret
    return -1;
    80003304:	54fd                	li	s1,-1
    80003306:	bfcd                	j	800032f8 <sys_sbrk+0x38>

0000000080003308 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003308:	7139                	addi	sp,sp,-64
    8000330a:	fc06                	sd	ra,56(sp)
    8000330c:	f822                	sd	s0,48(sp)
    8000330e:	f426                	sd	s1,40(sp)
    80003310:	f04a                	sd	s2,32(sp)
    80003312:	ec4e                	sd	s3,24(sp)
    80003314:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003316:	fcc40593          	addi	a1,s0,-52
    8000331a:	4501                	li	a0,0
    8000331c:	00000097          	auipc	ra,0x0
    80003320:	be0080e7          	jalr	-1056(ra) # 80002efc <argint>
    return -1;
    80003324:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003326:	06054563          	bltz	a0,80003390 <sys_sleep+0x88>
  acquire(&tickslock);
    8000332a:	0001a517          	auipc	a0,0x1a
    8000332e:	5a650513          	addi	a0,a0,1446 # 8001d8d0 <tickslock>
    80003332:	ffffe097          	auipc	ra,0xffffe
    80003336:	890080e7          	jalr	-1904(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    8000333a:	00006917          	auipc	s2,0x6
    8000333e:	cf692903          	lw	s2,-778(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80003342:	fcc42783          	lw	a5,-52(s0)
    80003346:	cf85                	beqz	a5,8000337e <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003348:	0001a997          	auipc	s3,0x1a
    8000334c:	58898993          	addi	s3,s3,1416 # 8001d8d0 <tickslock>
    80003350:	00006497          	auipc	s1,0x6
    80003354:	ce048493          	addi	s1,s1,-800 # 80009030 <ticks>
    if(myproc()->killed){
    80003358:	ffffe097          	auipc	ra,0xffffe
    8000335c:	626080e7          	jalr	1574(ra) # 8000197e <myproc>
    80003360:	551c                	lw	a5,40(a0)
    80003362:	ef9d                	bnez	a5,800033a0 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003364:	85ce                	mv	a1,s3
    80003366:	8526                	mv	a0,s1
    80003368:	fffff097          	auipc	ra,0xfffff
    8000336c:	d66080e7          	jalr	-666(ra) # 800020ce <sleep>
  while(ticks - ticks0 < n){
    80003370:	409c                	lw	a5,0(s1)
    80003372:	412787bb          	subw	a5,a5,s2
    80003376:	fcc42703          	lw	a4,-52(s0)
    8000337a:	fce7efe3          	bltu	a5,a4,80003358 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000337e:	0001a517          	auipc	a0,0x1a
    80003382:	55250513          	addi	a0,a0,1362 # 8001d8d0 <tickslock>
    80003386:	ffffe097          	auipc	ra,0xffffe
    8000338a:	8f0080e7          	jalr	-1808(ra) # 80000c76 <release>
  return 0;
    8000338e:	4781                	li	a5,0
}
    80003390:	853e                	mv	a0,a5
    80003392:	70e2                	ld	ra,56(sp)
    80003394:	7442                	ld	s0,48(sp)
    80003396:	74a2                	ld	s1,40(sp)
    80003398:	7902                	ld	s2,32(sp)
    8000339a:	69e2                	ld	s3,24(sp)
    8000339c:	6121                	addi	sp,sp,64
    8000339e:	8082                	ret
      release(&tickslock);
    800033a0:	0001a517          	auipc	a0,0x1a
    800033a4:	53050513          	addi	a0,a0,1328 # 8001d8d0 <tickslock>
    800033a8:	ffffe097          	auipc	ra,0xffffe
    800033ac:	8ce080e7          	jalr	-1842(ra) # 80000c76 <release>
      return -1;
    800033b0:	57fd                	li	a5,-1
    800033b2:	bff9                	j	80003390 <sys_sleep+0x88>

00000000800033b4 <sys_kill>:

uint64
sys_kill(void)
{
    800033b4:	1101                	addi	sp,sp,-32
    800033b6:	ec06                	sd	ra,24(sp)
    800033b8:	e822                	sd	s0,16(sp)
    800033ba:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    800033bc:	fec40593          	addi	a1,s0,-20
    800033c0:	4501                	li	a0,0
    800033c2:	00000097          	auipc	ra,0x0
    800033c6:	b3a080e7          	jalr	-1222(ra) # 80002efc <argint>
    return -1;
    800033ca:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    800033cc:	02054563          	bltz	a0,800033f6 <sys_kill+0x42>
  if(argint(1, &signum) < 0)
    800033d0:	fe840593          	addi	a1,s0,-24
    800033d4:	4505                	li	a0,1
    800033d6:	00000097          	auipc	ra,0x0
    800033da:	b26080e7          	jalr	-1242(ra) # 80002efc <argint>
    return -1;
    800033de:	57fd                	li	a5,-1
  if(argint(1, &signum) < 0)
    800033e0:	00054b63          	bltz	a0,800033f6 <sys_kill+0x42>
  return kill(pid, signum);
    800033e4:	fe842583          	lw	a1,-24(s0)
    800033e8:	fec42503          	lw	a0,-20(s0)
    800033ec:	fffff097          	auipc	ra,0xfffff
    800033f0:	014080e7          	jalr	20(ra) # 80002400 <kill>
    800033f4:	87aa                	mv	a5,a0
}
    800033f6:	853e                	mv	a0,a5
    800033f8:	60e2                	ld	ra,24(sp)
    800033fa:	6442                	ld	s0,16(sp)
    800033fc:	6105                	addi	sp,sp,32
    800033fe:	8082                	ret

0000000080003400 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003400:	1101                	addi	sp,sp,-32
    80003402:	ec06                	sd	ra,24(sp)
    80003404:	e822                	sd	s0,16(sp)
    80003406:	e426                	sd	s1,8(sp)
    80003408:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000340a:	0001a517          	auipc	a0,0x1a
    8000340e:	4c650513          	addi	a0,a0,1222 # 8001d8d0 <tickslock>
    80003412:	ffffd097          	auipc	ra,0xffffd
    80003416:	7b0080e7          	jalr	1968(ra) # 80000bc2 <acquire>
  xticks = ticks;
    8000341a:	00006497          	auipc	s1,0x6
    8000341e:	c164a483          	lw	s1,-1002(s1) # 80009030 <ticks>
  release(&tickslock);
    80003422:	0001a517          	auipc	a0,0x1a
    80003426:	4ae50513          	addi	a0,a0,1198 # 8001d8d0 <tickslock>
    8000342a:	ffffe097          	auipc	ra,0xffffe
    8000342e:	84c080e7          	jalr	-1972(ra) # 80000c76 <release>
  return xticks;
}
    80003432:	02049513          	slli	a0,s1,0x20
    80003436:	9101                	srli	a0,a0,0x20
    80003438:	60e2                	ld	ra,24(sp)
    8000343a:	6442                	ld	s0,16(sp)
    8000343c:	64a2                	ld	s1,8(sp)
    8000343e:	6105                	addi	sp,sp,32
    80003440:	8082                	ret

0000000080003442 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003442:	7179                	addi	sp,sp,-48
    80003444:	f406                	sd	ra,40(sp)
    80003446:	f022                	sd	s0,32(sp)
    80003448:	ec26                	sd	s1,24(sp)
    8000344a:	e84a                	sd	s2,16(sp)
    8000344c:	e44e                	sd	s3,8(sp)
    8000344e:	e052                	sd	s4,0(sp)
    80003450:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003452:	00005597          	auipc	a1,0x5
    80003456:	0e658593          	addi	a1,a1,230 # 80008538 <syscalls+0x108>
    8000345a:	0001a517          	auipc	a0,0x1a
    8000345e:	48e50513          	addi	a0,a0,1166 # 8001d8e8 <bcache>
    80003462:	ffffd097          	auipc	ra,0xffffd
    80003466:	6d0080e7          	jalr	1744(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000346a:	00022797          	auipc	a5,0x22
    8000346e:	47e78793          	addi	a5,a5,1150 # 800258e8 <bcache+0x8000>
    80003472:	00022717          	auipc	a4,0x22
    80003476:	6de70713          	addi	a4,a4,1758 # 80025b50 <bcache+0x8268>
    8000347a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000347e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003482:	0001a497          	auipc	s1,0x1a
    80003486:	47e48493          	addi	s1,s1,1150 # 8001d900 <bcache+0x18>
    b->next = bcache.head.next;
    8000348a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000348c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000348e:	00005a17          	auipc	s4,0x5
    80003492:	0b2a0a13          	addi	s4,s4,178 # 80008540 <syscalls+0x110>
    b->next = bcache.head.next;
    80003496:	2b893783          	ld	a5,696(s2)
    8000349a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000349c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800034a0:	85d2                	mv	a1,s4
    800034a2:	01048513          	addi	a0,s1,16
    800034a6:	00001097          	auipc	ra,0x1
    800034aa:	4c2080e7          	jalr	1218(ra) # 80004968 <initsleeplock>
    bcache.head.next->prev = b;
    800034ae:	2b893783          	ld	a5,696(s2)
    800034b2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800034b4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034b8:	45848493          	addi	s1,s1,1112
    800034bc:	fd349de3          	bne	s1,s3,80003496 <binit+0x54>
  }
}
    800034c0:	70a2                	ld	ra,40(sp)
    800034c2:	7402                	ld	s0,32(sp)
    800034c4:	64e2                	ld	s1,24(sp)
    800034c6:	6942                	ld	s2,16(sp)
    800034c8:	69a2                	ld	s3,8(sp)
    800034ca:	6a02                	ld	s4,0(sp)
    800034cc:	6145                	addi	sp,sp,48
    800034ce:	8082                	ret

00000000800034d0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800034d0:	7179                	addi	sp,sp,-48
    800034d2:	f406                	sd	ra,40(sp)
    800034d4:	f022                	sd	s0,32(sp)
    800034d6:	ec26                	sd	s1,24(sp)
    800034d8:	e84a                	sd	s2,16(sp)
    800034da:	e44e                	sd	s3,8(sp)
    800034dc:	1800                	addi	s0,sp,48
    800034de:	892a                	mv	s2,a0
    800034e0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800034e2:	0001a517          	auipc	a0,0x1a
    800034e6:	40650513          	addi	a0,a0,1030 # 8001d8e8 <bcache>
    800034ea:	ffffd097          	auipc	ra,0xffffd
    800034ee:	6d8080e7          	jalr	1752(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800034f2:	00022497          	auipc	s1,0x22
    800034f6:	6ae4b483          	ld	s1,1710(s1) # 80025ba0 <bcache+0x82b8>
    800034fa:	00022797          	auipc	a5,0x22
    800034fe:	65678793          	addi	a5,a5,1622 # 80025b50 <bcache+0x8268>
    80003502:	02f48f63          	beq	s1,a5,80003540 <bread+0x70>
    80003506:	873e                	mv	a4,a5
    80003508:	a021                	j	80003510 <bread+0x40>
    8000350a:	68a4                	ld	s1,80(s1)
    8000350c:	02e48a63          	beq	s1,a4,80003540 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003510:	449c                	lw	a5,8(s1)
    80003512:	ff279ce3          	bne	a5,s2,8000350a <bread+0x3a>
    80003516:	44dc                	lw	a5,12(s1)
    80003518:	ff3799e3          	bne	a5,s3,8000350a <bread+0x3a>
      b->refcnt++;
    8000351c:	40bc                	lw	a5,64(s1)
    8000351e:	2785                	addiw	a5,a5,1
    80003520:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003522:	0001a517          	auipc	a0,0x1a
    80003526:	3c650513          	addi	a0,a0,966 # 8001d8e8 <bcache>
    8000352a:	ffffd097          	auipc	ra,0xffffd
    8000352e:	74c080e7          	jalr	1868(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003532:	01048513          	addi	a0,s1,16
    80003536:	00001097          	auipc	ra,0x1
    8000353a:	46c080e7          	jalr	1132(ra) # 800049a2 <acquiresleep>
      return b;
    8000353e:	a8b9                	j	8000359c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003540:	00022497          	auipc	s1,0x22
    80003544:	6584b483          	ld	s1,1624(s1) # 80025b98 <bcache+0x82b0>
    80003548:	00022797          	auipc	a5,0x22
    8000354c:	60878793          	addi	a5,a5,1544 # 80025b50 <bcache+0x8268>
    80003550:	00f48863          	beq	s1,a5,80003560 <bread+0x90>
    80003554:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003556:	40bc                	lw	a5,64(s1)
    80003558:	cf81                	beqz	a5,80003570 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000355a:	64a4                	ld	s1,72(s1)
    8000355c:	fee49de3          	bne	s1,a4,80003556 <bread+0x86>
  panic("bget: no buffers");
    80003560:	00005517          	auipc	a0,0x5
    80003564:	fe850513          	addi	a0,a0,-24 # 80008548 <syscalls+0x118>
    80003568:	ffffd097          	auipc	ra,0xffffd
    8000356c:	fc2080e7          	jalr	-62(ra) # 8000052a <panic>
      b->dev = dev;
    80003570:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003574:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003578:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000357c:	4785                	li	a5,1
    8000357e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003580:	0001a517          	auipc	a0,0x1a
    80003584:	36850513          	addi	a0,a0,872 # 8001d8e8 <bcache>
    80003588:	ffffd097          	auipc	ra,0xffffd
    8000358c:	6ee080e7          	jalr	1774(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003590:	01048513          	addi	a0,s1,16
    80003594:	00001097          	auipc	ra,0x1
    80003598:	40e080e7          	jalr	1038(ra) # 800049a2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000359c:	409c                	lw	a5,0(s1)
    8000359e:	cb89                	beqz	a5,800035b0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800035a0:	8526                	mv	a0,s1
    800035a2:	70a2                	ld	ra,40(sp)
    800035a4:	7402                	ld	s0,32(sp)
    800035a6:	64e2                	ld	s1,24(sp)
    800035a8:	6942                	ld	s2,16(sp)
    800035aa:	69a2                	ld	s3,8(sp)
    800035ac:	6145                	addi	sp,sp,48
    800035ae:	8082                	ret
    virtio_disk_rw(b, 0);
    800035b0:	4581                	li	a1,0
    800035b2:	8526                	mv	a0,s1
    800035b4:	00003097          	auipc	ra,0x3
    800035b8:	f22080e7          	jalr	-222(ra) # 800064d6 <virtio_disk_rw>
    b->valid = 1;
    800035bc:	4785                	li	a5,1
    800035be:	c09c                	sw	a5,0(s1)
  return b;
    800035c0:	b7c5                	j	800035a0 <bread+0xd0>

00000000800035c2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800035c2:	1101                	addi	sp,sp,-32
    800035c4:	ec06                	sd	ra,24(sp)
    800035c6:	e822                	sd	s0,16(sp)
    800035c8:	e426                	sd	s1,8(sp)
    800035ca:	1000                	addi	s0,sp,32
    800035cc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035ce:	0541                	addi	a0,a0,16
    800035d0:	00001097          	auipc	ra,0x1
    800035d4:	46c080e7          	jalr	1132(ra) # 80004a3c <holdingsleep>
    800035d8:	cd01                	beqz	a0,800035f0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800035da:	4585                	li	a1,1
    800035dc:	8526                	mv	a0,s1
    800035de:	00003097          	auipc	ra,0x3
    800035e2:	ef8080e7          	jalr	-264(ra) # 800064d6 <virtio_disk_rw>
}
    800035e6:	60e2                	ld	ra,24(sp)
    800035e8:	6442                	ld	s0,16(sp)
    800035ea:	64a2                	ld	s1,8(sp)
    800035ec:	6105                	addi	sp,sp,32
    800035ee:	8082                	ret
    panic("bwrite");
    800035f0:	00005517          	auipc	a0,0x5
    800035f4:	f7050513          	addi	a0,a0,-144 # 80008560 <syscalls+0x130>
    800035f8:	ffffd097          	auipc	ra,0xffffd
    800035fc:	f32080e7          	jalr	-206(ra) # 8000052a <panic>

0000000080003600 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003600:	1101                	addi	sp,sp,-32
    80003602:	ec06                	sd	ra,24(sp)
    80003604:	e822                	sd	s0,16(sp)
    80003606:	e426                	sd	s1,8(sp)
    80003608:	e04a                	sd	s2,0(sp)
    8000360a:	1000                	addi	s0,sp,32
    8000360c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000360e:	01050913          	addi	s2,a0,16
    80003612:	854a                	mv	a0,s2
    80003614:	00001097          	auipc	ra,0x1
    80003618:	428080e7          	jalr	1064(ra) # 80004a3c <holdingsleep>
    8000361c:	c92d                	beqz	a0,8000368e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000361e:	854a                	mv	a0,s2
    80003620:	00001097          	auipc	ra,0x1
    80003624:	3d8080e7          	jalr	984(ra) # 800049f8 <releasesleep>

  acquire(&bcache.lock);
    80003628:	0001a517          	auipc	a0,0x1a
    8000362c:	2c050513          	addi	a0,a0,704 # 8001d8e8 <bcache>
    80003630:	ffffd097          	auipc	ra,0xffffd
    80003634:	592080e7          	jalr	1426(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003638:	40bc                	lw	a5,64(s1)
    8000363a:	37fd                	addiw	a5,a5,-1
    8000363c:	0007871b          	sext.w	a4,a5
    80003640:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003642:	eb05                	bnez	a4,80003672 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003644:	68bc                	ld	a5,80(s1)
    80003646:	64b8                	ld	a4,72(s1)
    80003648:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000364a:	64bc                	ld	a5,72(s1)
    8000364c:	68b8                	ld	a4,80(s1)
    8000364e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003650:	00022797          	auipc	a5,0x22
    80003654:	29878793          	addi	a5,a5,664 # 800258e8 <bcache+0x8000>
    80003658:	2b87b703          	ld	a4,696(a5)
    8000365c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000365e:	00022717          	auipc	a4,0x22
    80003662:	4f270713          	addi	a4,a4,1266 # 80025b50 <bcache+0x8268>
    80003666:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003668:	2b87b703          	ld	a4,696(a5)
    8000366c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000366e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003672:	0001a517          	auipc	a0,0x1a
    80003676:	27650513          	addi	a0,a0,630 # 8001d8e8 <bcache>
    8000367a:	ffffd097          	auipc	ra,0xffffd
    8000367e:	5fc080e7          	jalr	1532(ra) # 80000c76 <release>
}
    80003682:	60e2                	ld	ra,24(sp)
    80003684:	6442                	ld	s0,16(sp)
    80003686:	64a2                	ld	s1,8(sp)
    80003688:	6902                	ld	s2,0(sp)
    8000368a:	6105                	addi	sp,sp,32
    8000368c:	8082                	ret
    panic("brelse");
    8000368e:	00005517          	auipc	a0,0x5
    80003692:	eda50513          	addi	a0,a0,-294 # 80008568 <syscalls+0x138>
    80003696:	ffffd097          	auipc	ra,0xffffd
    8000369a:	e94080e7          	jalr	-364(ra) # 8000052a <panic>

000000008000369e <bpin>:

void
bpin(struct buf *b) {
    8000369e:	1101                	addi	sp,sp,-32
    800036a0:	ec06                	sd	ra,24(sp)
    800036a2:	e822                	sd	s0,16(sp)
    800036a4:	e426                	sd	s1,8(sp)
    800036a6:	1000                	addi	s0,sp,32
    800036a8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036aa:	0001a517          	auipc	a0,0x1a
    800036ae:	23e50513          	addi	a0,a0,574 # 8001d8e8 <bcache>
    800036b2:	ffffd097          	auipc	ra,0xffffd
    800036b6:	510080e7          	jalr	1296(ra) # 80000bc2 <acquire>
  b->refcnt++;
    800036ba:	40bc                	lw	a5,64(s1)
    800036bc:	2785                	addiw	a5,a5,1
    800036be:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036c0:	0001a517          	auipc	a0,0x1a
    800036c4:	22850513          	addi	a0,a0,552 # 8001d8e8 <bcache>
    800036c8:	ffffd097          	auipc	ra,0xffffd
    800036cc:	5ae080e7          	jalr	1454(ra) # 80000c76 <release>
}
    800036d0:	60e2                	ld	ra,24(sp)
    800036d2:	6442                	ld	s0,16(sp)
    800036d4:	64a2                	ld	s1,8(sp)
    800036d6:	6105                	addi	sp,sp,32
    800036d8:	8082                	ret

00000000800036da <bunpin>:

void
bunpin(struct buf *b) {
    800036da:	1101                	addi	sp,sp,-32
    800036dc:	ec06                	sd	ra,24(sp)
    800036de:	e822                	sd	s0,16(sp)
    800036e0:	e426                	sd	s1,8(sp)
    800036e2:	1000                	addi	s0,sp,32
    800036e4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036e6:	0001a517          	auipc	a0,0x1a
    800036ea:	20250513          	addi	a0,a0,514 # 8001d8e8 <bcache>
    800036ee:	ffffd097          	auipc	ra,0xffffd
    800036f2:	4d4080e7          	jalr	1236(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800036f6:	40bc                	lw	a5,64(s1)
    800036f8:	37fd                	addiw	a5,a5,-1
    800036fa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036fc:	0001a517          	auipc	a0,0x1a
    80003700:	1ec50513          	addi	a0,a0,492 # 8001d8e8 <bcache>
    80003704:	ffffd097          	auipc	ra,0xffffd
    80003708:	572080e7          	jalr	1394(ra) # 80000c76 <release>
}
    8000370c:	60e2                	ld	ra,24(sp)
    8000370e:	6442                	ld	s0,16(sp)
    80003710:	64a2                	ld	s1,8(sp)
    80003712:	6105                	addi	sp,sp,32
    80003714:	8082                	ret

0000000080003716 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003716:	1101                	addi	sp,sp,-32
    80003718:	ec06                	sd	ra,24(sp)
    8000371a:	e822                	sd	s0,16(sp)
    8000371c:	e426                	sd	s1,8(sp)
    8000371e:	e04a                	sd	s2,0(sp)
    80003720:	1000                	addi	s0,sp,32
    80003722:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003724:	00d5d59b          	srliw	a1,a1,0xd
    80003728:	00023797          	auipc	a5,0x23
    8000372c:	89c7a783          	lw	a5,-1892(a5) # 80025fc4 <sb+0x1c>
    80003730:	9dbd                	addw	a1,a1,a5
    80003732:	00000097          	auipc	ra,0x0
    80003736:	d9e080e7          	jalr	-610(ra) # 800034d0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000373a:	0074f713          	andi	a4,s1,7
    8000373e:	4785                	li	a5,1
    80003740:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003744:	14ce                	slli	s1,s1,0x33
    80003746:	90d9                	srli	s1,s1,0x36
    80003748:	00950733          	add	a4,a0,s1
    8000374c:	05874703          	lbu	a4,88(a4)
    80003750:	00e7f6b3          	and	a3,a5,a4
    80003754:	c69d                	beqz	a3,80003782 <bfree+0x6c>
    80003756:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003758:	94aa                	add	s1,s1,a0
    8000375a:	fff7c793          	not	a5,a5
    8000375e:	8ff9                	and	a5,a5,a4
    80003760:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003764:	00001097          	auipc	ra,0x1
    80003768:	11e080e7          	jalr	286(ra) # 80004882 <log_write>
  brelse(bp);
    8000376c:	854a                	mv	a0,s2
    8000376e:	00000097          	auipc	ra,0x0
    80003772:	e92080e7          	jalr	-366(ra) # 80003600 <brelse>
}
    80003776:	60e2                	ld	ra,24(sp)
    80003778:	6442                	ld	s0,16(sp)
    8000377a:	64a2                	ld	s1,8(sp)
    8000377c:	6902                	ld	s2,0(sp)
    8000377e:	6105                	addi	sp,sp,32
    80003780:	8082                	ret
    panic("freeing free block");
    80003782:	00005517          	auipc	a0,0x5
    80003786:	dee50513          	addi	a0,a0,-530 # 80008570 <syscalls+0x140>
    8000378a:	ffffd097          	auipc	ra,0xffffd
    8000378e:	da0080e7          	jalr	-608(ra) # 8000052a <panic>

0000000080003792 <balloc>:
{
    80003792:	711d                	addi	sp,sp,-96
    80003794:	ec86                	sd	ra,88(sp)
    80003796:	e8a2                	sd	s0,80(sp)
    80003798:	e4a6                	sd	s1,72(sp)
    8000379a:	e0ca                	sd	s2,64(sp)
    8000379c:	fc4e                	sd	s3,56(sp)
    8000379e:	f852                	sd	s4,48(sp)
    800037a0:	f456                	sd	s5,40(sp)
    800037a2:	f05a                	sd	s6,32(sp)
    800037a4:	ec5e                	sd	s7,24(sp)
    800037a6:	e862                	sd	s8,16(sp)
    800037a8:	e466                	sd	s9,8(sp)
    800037aa:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800037ac:	00023797          	auipc	a5,0x23
    800037b0:	8007a783          	lw	a5,-2048(a5) # 80025fac <sb+0x4>
    800037b4:	cbd1                	beqz	a5,80003848 <balloc+0xb6>
    800037b6:	8baa                	mv	s7,a0
    800037b8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800037ba:	00022b17          	auipc	s6,0x22
    800037be:	7eeb0b13          	addi	s6,s6,2030 # 80025fa8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037c2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800037c4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037c6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800037c8:	6c89                	lui	s9,0x2
    800037ca:	a831                	j	800037e6 <balloc+0x54>
    brelse(bp);
    800037cc:	854a                	mv	a0,s2
    800037ce:	00000097          	auipc	ra,0x0
    800037d2:	e32080e7          	jalr	-462(ra) # 80003600 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800037d6:	015c87bb          	addw	a5,s9,s5
    800037da:	00078a9b          	sext.w	s5,a5
    800037de:	004b2703          	lw	a4,4(s6)
    800037e2:	06eaf363          	bgeu	s5,a4,80003848 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800037e6:	41fad79b          	sraiw	a5,s5,0x1f
    800037ea:	0137d79b          	srliw	a5,a5,0x13
    800037ee:	015787bb          	addw	a5,a5,s5
    800037f2:	40d7d79b          	sraiw	a5,a5,0xd
    800037f6:	01cb2583          	lw	a1,28(s6)
    800037fa:	9dbd                	addw	a1,a1,a5
    800037fc:	855e                	mv	a0,s7
    800037fe:	00000097          	auipc	ra,0x0
    80003802:	cd2080e7          	jalr	-814(ra) # 800034d0 <bread>
    80003806:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003808:	004b2503          	lw	a0,4(s6)
    8000380c:	000a849b          	sext.w	s1,s5
    80003810:	8662                	mv	a2,s8
    80003812:	faa4fde3          	bgeu	s1,a0,800037cc <balloc+0x3a>
      m = 1 << (bi % 8);
    80003816:	41f6579b          	sraiw	a5,a2,0x1f
    8000381a:	01d7d69b          	srliw	a3,a5,0x1d
    8000381e:	00c6873b          	addw	a4,a3,a2
    80003822:	00777793          	andi	a5,a4,7
    80003826:	9f95                	subw	a5,a5,a3
    80003828:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000382c:	4037571b          	sraiw	a4,a4,0x3
    80003830:	00e906b3          	add	a3,s2,a4
    80003834:	0586c683          	lbu	a3,88(a3)
    80003838:	00d7f5b3          	and	a1,a5,a3
    8000383c:	cd91                	beqz	a1,80003858 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000383e:	2605                	addiw	a2,a2,1
    80003840:	2485                	addiw	s1,s1,1
    80003842:	fd4618e3          	bne	a2,s4,80003812 <balloc+0x80>
    80003846:	b759                	j	800037cc <balloc+0x3a>
  panic("balloc: out of blocks");
    80003848:	00005517          	auipc	a0,0x5
    8000384c:	d4050513          	addi	a0,a0,-704 # 80008588 <syscalls+0x158>
    80003850:	ffffd097          	auipc	ra,0xffffd
    80003854:	cda080e7          	jalr	-806(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003858:	974a                	add	a4,a4,s2
    8000385a:	8fd5                	or	a5,a5,a3
    8000385c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003860:	854a                	mv	a0,s2
    80003862:	00001097          	auipc	ra,0x1
    80003866:	020080e7          	jalr	32(ra) # 80004882 <log_write>
        brelse(bp);
    8000386a:	854a                	mv	a0,s2
    8000386c:	00000097          	auipc	ra,0x0
    80003870:	d94080e7          	jalr	-620(ra) # 80003600 <brelse>
  bp = bread(dev, bno);
    80003874:	85a6                	mv	a1,s1
    80003876:	855e                	mv	a0,s7
    80003878:	00000097          	auipc	ra,0x0
    8000387c:	c58080e7          	jalr	-936(ra) # 800034d0 <bread>
    80003880:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003882:	40000613          	li	a2,1024
    80003886:	4581                	li	a1,0
    80003888:	05850513          	addi	a0,a0,88
    8000388c:	ffffd097          	auipc	ra,0xffffd
    80003890:	432080e7          	jalr	1074(ra) # 80000cbe <memset>
  log_write(bp);
    80003894:	854a                	mv	a0,s2
    80003896:	00001097          	auipc	ra,0x1
    8000389a:	fec080e7          	jalr	-20(ra) # 80004882 <log_write>
  brelse(bp);
    8000389e:	854a                	mv	a0,s2
    800038a0:	00000097          	auipc	ra,0x0
    800038a4:	d60080e7          	jalr	-672(ra) # 80003600 <brelse>
}
    800038a8:	8526                	mv	a0,s1
    800038aa:	60e6                	ld	ra,88(sp)
    800038ac:	6446                	ld	s0,80(sp)
    800038ae:	64a6                	ld	s1,72(sp)
    800038b0:	6906                	ld	s2,64(sp)
    800038b2:	79e2                	ld	s3,56(sp)
    800038b4:	7a42                	ld	s4,48(sp)
    800038b6:	7aa2                	ld	s5,40(sp)
    800038b8:	7b02                	ld	s6,32(sp)
    800038ba:	6be2                	ld	s7,24(sp)
    800038bc:	6c42                	ld	s8,16(sp)
    800038be:	6ca2                	ld	s9,8(sp)
    800038c0:	6125                	addi	sp,sp,96
    800038c2:	8082                	ret

00000000800038c4 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800038c4:	7179                	addi	sp,sp,-48
    800038c6:	f406                	sd	ra,40(sp)
    800038c8:	f022                	sd	s0,32(sp)
    800038ca:	ec26                	sd	s1,24(sp)
    800038cc:	e84a                	sd	s2,16(sp)
    800038ce:	e44e                	sd	s3,8(sp)
    800038d0:	e052                	sd	s4,0(sp)
    800038d2:	1800                	addi	s0,sp,48
    800038d4:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800038d6:	47ad                	li	a5,11
    800038d8:	04b7fe63          	bgeu	a5,a1,80003934 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800038dc:	ff45849b          	addiw	s1,a1,-12
    800038e0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800038e4:	0ff00793          	li	a5,255
    800038e8:	0ae7e463          	bltu	a5,a4,80003990 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800038ec:	08052583          	lw	a1,128(a0)
    800038f0:	c5b5                	beqz	a1,8000395c <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800038f2:	00092503          	lw	a0,0(s2)
    800038f6:	00000097          	auipc	ra,0x0
    800038fa:	bda080e7          	jalr	-1062(ra) # 800034d0 <bread>
    800038fe:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003900:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003904:	02049713          	slli	a4,s1,0x20
    80003908:	01e75593          	srli	a1,a4,0x1e
    8000390c:	00b784b3          	add	s1,a5,a1
    80003910:	0004a983          	lw	s3,0(s1)
    80003914:	04098e63          	beqz	s3,80003970 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003918:	8552                	mv	a0,s4
    8000391a:	00000097          	auipc	ra,0x0
    8000391e:	ce6080e7          	jalr	-794(ra) # 80003600 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003922:	854e                	mv	a0,s3
    80003924:	70a2                	ld	ra,40(sp)
    80003926:	7402                	ld	s0,32(sp)
    80003928:	64e2                	ld	s1,24(sp)
    8000392a:	6942                	ld	s2,16(sp)
    8000392c:	69a2                	ld	s3,8(sp)
    8000392e:	6a02                	ld	s4,0(sp)
    80003930:	6145                	addi	sp,sp,48
    80003932:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003934:	02059793          	slli	a5,a1,0x20
    80003938:	01e7d593          	srli	a1,a5,0x1e
    8000393c:	00b504b3          	add	s1,a0,a1
    80003940:	0504a983          	lw	s3,80(s1)
    80003944:	fc099fe3          	bnez	s3,80003922 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003948:	4108                	lw	a0,0(a0)
    8000394a:	00000097          	auipc	ra,0x0
    8000394e:	e48080e7          	jalr	-440(ra) # 80003792 <balloc>
    80003952:	0005099b          	sext.w	s3,a0
    80003956:	0534a823          	sw	s3,80(s1)
    8000395a:	b7e1                	j	80003922 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000395c:	4108                	lw	a0,0(a0)
    8000395e:	00000097          	auipc	ra,0x0
    80003962:	e34080e7          	jalr	-460(ra) # 80003792 <balloc>
    80003966:	0005059b          	sext.w	a1,a0
    8000396a:	08b92023          	sw	a1,128(s2)
    8000396e:	b751                	j	800038f2 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003970:	00092503          	lw	a0,0(s2)
    80003974:	00000097          	auipc	ra,0x0
    80003978:	e1e080e7          	jalr	-482(ra) # 80003792 <balloc>
    8000397c:	0005099b          	sext.w	s3,a0
    80003980:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003984:	8552                	mv	a0,s4
    80003986:	00001097          	auipc	ra,0x1
    8000398a:	efc080e7          	jalr	-260(ra) # 80004882 <log_write>
    8000398e:	b769                	j	80003918 <bmap+0x54>
  panic("bmap: out of range");
    80003990:	00005517          	auipc	a0,0x5
    80003994:	c1050513          	addi	a0,a0,-1008 # 800085a0 <syscalls+0x170>
    80003998:	ffffd097          	auipc	ra,0xffffd
    8000399c:	b92080e7          	jalr	-1134(ra) # 8000052a <panic>

00000000800039a0 <iget>:
{
    800039a0:	7179                	addi	sp,sp,-48
    800039a2:	f406                	sd	ra,40(sp)
    800039a4:	f022                	sd	s0,32(sp)
    800039a6:	ec26                	sd	s1,24(sp)
    800039a8:	e84a                	sd	s2,16(sp)
    800039aa:	e44e                	sd	s3,8(sp)
    800039ac:	e052                	sd	s4,0(sp)
    800039ae:	1800                	addi	s0,sp,48
    800039b0:	89aa                	mv	s3,a0
    800039b2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800039b4:	00022517          	auipc	a0,0x22
    800039b8:	61450513          	addi	a0,a0,1556 # 80025fc8 <itable>
    800039bc:	ffffd097          	auipc	ra,0xffffd
    800039c0:	206080e7          	jalr	518(ra) # 80000bc2 <acquire>
  empty = 0;
    800039c4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039c6:	00022497          	auipc	s1,0x22
    800039ca:	61a48493          	addi	s1,s1,1562 # 80025fe0 <itable+0x18>
    800039ce:	00024697          	auipc	a3,0x24
    800039d2:	0a268693          	addi	a3,a3,162 # 80027a70 <log>
    800039d6:	a039                	j	800039e4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039d8:	02090b63          	beqz	s2,80003a0e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039dc:	08848493          	addi	s1,s1,136
    800039e0:	02d48a63          	beq	s1,a3,80003a14 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800039e4:	449c                	lw	a5,8(s1)
    800039e6:	fef059e3          	blez	a5,800039d8 <iget+0x38>
    800039ea:	4098                	lw	a4,0(s1)
    800039ec:	ff3716e3          	bne	a4,s3,800039d8 <iget+0x38>
    800039f0:	40d8                	lw	a4,4(s1)
    800039f2:	ff4713e3          	bne	a4,s4,800039d8 <iget+0x38>
      ip->ref++;
    800039f6:	2785                	addiw	a5,a5,1
    800039f8:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800039fa:	00022517          	auipc	a0,0x22
    800039fe:	5ce50513          	addi	a0,a0,1486 # 80025fc8 <itable>
    80003a02:	ffffd097          	auipc	ra,0xffffd
    80003a06:	274080e7          	jalr	628(ra) # 80000c76 <release>
      return ip;
    80003a0a:	8926                	mv	s2,s1
    80003a0c:	a03d                	j	80003a3a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a0e:	f7f9                	bnez	a5,800039dc <iget+0x3c>
    80003a10:	8926                	mv	s2,s1
    80003a12:	b7e9                	j	800039dc <iget+0x3c>
  if(empty == 0)
    80003a14:	02090c63          	beqz	s2,80003a4c <iget+0xac>
  ip->dev = dev;
    80003a18:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003a1c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a20:	4785                	li	a5,1
    80003a22:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a26:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a2a:	00022517          	auipc	a0,0x22
    80003a2e:	59e50513          	addi	a0,a0,1438 # 80025fc8 <itable>
    80003a32:	ffffd097          	auipc	ra,0xffffd
    80003a36:	244080e7          	jalr	580(ra) # 80000c76 <release>
}
    80003a3a:	854a                	mv	a0,s2
    80003a3c:	70a2                	ld	ra,40(sp)
    80003a3e:	7402                	ld	s0,32(sp)
    80003a40:	64e2                	ld	s1,24(sp)
    80003a42:	6942                	ld	s2,16(sp)
    80003a44:	69a2                	ld	s3,8(sp)
    80003a46:	6a02                	ld	s4,0(sp)
    80003a48:	6145                	addi	sp,sp,48
    80003a4a:	8082                	ret
    panic("iget: no inodes");
    80003a4c:	00005517          	auipc	a0,0x5
    80003a50:	b6c50513          	addi	a0,a0,-1172 # 800085b8 <syscalls+0x188>
    80003a54:	ffffd097          	auipc	ra,0xffffd
    80003a58:	ad6080e7          	jalr	-1322(ra) # 8000052a <panic>

0000000080003a5c <fsinit>:
fsinit(int dev) {
    80003a5c:	7179                	addi	sp,sp,-48
    80003a5e:	f406                	sd	ra,40(sp)
    80003a60:	f022                	sd	s0,32(sp)
    80003a62:	ec26                	sd	s1,24(sp)
    80003a64:	e84a                	sd	s2,16(sp)
    80003a66:	e44e                	sd	s3,8(sp)
    80003a68:	1800                	addi	s0,sp,48
    80003a6a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a6c:	4585                	li	a1,1
    80003a6e:	00000097          	auipc	ra,0x0
    80003a72:	a62080e7          	jalr	-1438(ra) # 800034d0 <bread>
    80003a76:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a78:	00022997          	auipc	s3,0x22
    80003a7c:	53098993          	addi	s3,s3,1328 # 80025fa8 <sb>
    80003a80:	02000613          	li	a2,32
    80003a84:	05850593          	addi	a1,a0,88
    80003a88:	854e                	mv	a0,s3
    80003a8a:	ffffd097          	auipc	ra,0xffffd
    80003a8e:	290080e7          	jalr	656(ra) # 80000d1a <memmove>
  brelse(bp);
    80003a92:	8526                	mv	a0,s1
    80003a94:	00000097          	auipc	ra,0x0
    80003a98:	b6c080e7          	jalr	-1172(ra) # 80003600 <brelse>
  if(sb.magic != FSMAGIC)
    80003a9c:	0009a703          	lw	a4,0(s3)
    80003aa0:	102037b7          	lui	a5,0x10203
    80003aa4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003aa8:	02f71263          	bne	a4,a5,80003acc <fsinit+0x70>
  initlog(dev, &sb);
    80003aac:	00022597          	auipc	a1,0x22
    80003ab0:	4fc58593          	addi	a1,a1,1276 # 80025fa8 <sb>
    80003ab4:	854a                	mv	a0,s2
    80003ab6:	00001097          	auipc	ra,0x1
    80003aba:	b4e080e7          	jalr	-1202(ra) # 80004604 <initlog>
}
    80003abe:	70a2                	ld	ra,40(sp)
    80003ac0:	7402                	ld	s0,32(sp)
    80003ac2:	64e2                	ld	s1,24(sp)
    80003ac4:	6942                	ld	s2,16(sp)
    80003ac6:	69a2                	ld	s3,8(sp)
    80003ac8:	6145                	addi	sp,sp,48
    80003aca:	8082                	ret
    panic("invalid file system");
    80003acc:	00005517          	auipc	a0,0x5
    80003ad0:	afc50513          	addi	a0,a0,-1284 # 800085c8 <syscalls+0x198>
    80003ad4:	ffffd097          	auipc	ra,0xffffd
    80003ad8:	a56080e7          	jalr	-1450(ra) # 8000052a <panic>

0000000080003adc <iinit>:
{
    80003adc:	7179                	addi	sp,sp,-48
    80003ade:	f406                	sd	ra,40(sp)
    80003ae0:	f022                	sd	s0,32(sp)
    80003ae2:	ec26                	sd	s1,24(sp)
    80003ae4:	e84a                	sd	s2,16(sp)
    80003ae6:	e44e                	sd	s3,8(sp)
    80003ae8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003aea:	00005597          	auipc	a1,0x5
    80003aee:	af658593          	addi	a1,a1,-1290 # 800085e0 <syscalls+0x1b0>
    80003af2:	00022517          	auipc	a0,0x22
    80003af6:	4d650513          	addi	a0,a0,1238 # 80025fc8 <itable>
    80003afa:	ffffd097          	auipc	ra,0xffffd
    80003afe:	038080e7          	jalr	56(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003b02:	00022497          	auipc	s1,0x22
    80003b06:	4ee48493          	addi	s1,s1,1262 # 80025ff0 <itable+0x28>
    80003b0a:	00024997          	auipc	s3,0x24
    80003b0e:	f7698993          	addi	s3,s3,-138 # 80027a80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003b12:	00005917          	auipc	s2,0x5
    80003b16:	ad690913          	addi	s2,s2,-1322 # 800085e8 <syscalls+0x1b8>
    80003b1a:	85ca                	mv	a1,s2
    80003b1c:	8526                	mv	a0,s1
    80003b1e:	00001097          	auipc	ra,0x1
    80003b22:	e4a080e7          	jalr	-438(ra) # 80004968 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b26:	08848493          	addi	s1,s1,136
    80003b2a:	ff3498e3          	bne	s1,s3,80003b1a <iinit+0x3e>
}
    80003b2e:	70a2                	ld	ra,40(sp)
    80003b30:	7402                	ld	s0,32(sp)
    80003b32:	64e2                	ld	s1,24(sp)
    80003b34:	6942                	ld	s2,16(sp)
    80003b36:	69a2                	ld	s3,8(sp)
    80003b38:	6145                	addi	sp,sp,48
    80003b3a:	8082                	ret

0000000080003b3c <ialloc>:
{
    80003b3c:	715d                	addi	sp,sp,-80
    80003b3e:	e486                	sd	ra,72(sp)
    80003b40:	e0a2                	sd	s0,64(sp)
    80003b42:	fc26                	sd	s1,56(sp)
    80003b44:	f84a                	sd	s2,48(sp)
    80003b46:	f44e                	sd	s3,40(sp)
    80003b48:	f052                	sd	s4,32(sp)
    80003b4a:	ec56                	sd	s5,24(sp)
    80003b4c:	e85a                	sd	s6,16(sp)
    80003b4e:	e45e                	sd	s7,8(sp)
    80003b50:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b52:	00022717          	auipc	a4,0x22
    80003b56:	46272703          	lw	a4,1122(a4) # 80025fb4 <sb+0xc>
    80003b5a:	4785                	li	a5,1
    80003b5c:	04e7fa63          	bgeu	a5,a4,80003bb0 <ialloc+0x74>
    80003b60:	8aaa                	mv	s5,a0
    80003b62:	8bae                	mv	s7,a1
    80003b64:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b66:	00022a17          	auipc	s4,0x22
    80003b6a:	442a0a13          	addi	s4,s4,1090 # 80025fa8 <sb>
    80003b6e:	00048b1b          	sext.w	s6,s1
    80003b72:	0044d793          	srli	a5,s1,0x4
    80003b76:	018a2583          	lw	a1,24(s4)
    80003b7a:	9dbd                	addw	a1,a1,a5
    80003b7c:	8556                	mv	a0,s5
    80003b7e:	00000097          	auipc	ra,0x0
    80003b82:	952080e7          	jalr	-1710(ra) # 800034d0 <bread>
    80003b86:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b88:	05850993          	addi	s3,a0,88
    80003b8c:	00f4f793          	andi	a5,s1,15
    80003b90:	079a                	slli	a5,a5,0x6
    80003b92:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b94:	00099783          	lh	a5,0(s3)
    80003b98:	c785                	beqz	a5,80003bc0 <ialloc+0x84>
    brelse(bp);
    80003b9a:	00000097          	auipc	ra,0x0
    80003b9e:	a66080e7          	jalr	-1434(ra) # 80003600 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ba2:	0485                	addi	s1,s1,1
    80003ba4:	00ca2703          	lw	a4,12(s4)
    80003ba8:	0004879b          	sext.w	a5,s1
    80003bac:	fce7e1e3          	bltu	a5,a4,80003b6e <ialloc+0x32>
  panic("ialloc: no inodes");
    80003bb0:	00005517          	auipc	a0,0x5
    80003bb4:	a4050513          	addi	a0,a0,-1472 # 800085f0 <syscalls+0x1c0>
    80003bb8:	ffffd097          	auipc	ra,0xffffd
    80003bbc:	972080e7          	jalr	-1678(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003bc0:	04000613          	li	a2,64
    80003bc4:	4581                	li	a1,0
    80003bc6:	854e                	mv	a0,s3
    80003bc8:	ffffd097          	auipc	ra,0xffffd
    80003bcc:	0f6080e7          	jalr	246(ra) # 80000cbe <memset>
      dip->type = type;
    80003bd0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003bd4:	854a                	mv	a0,s2
    80003bd6:	00001097          	auipc	ra,0x1
    80003bda:	cac080e7          	jalr	-852(ra) # 80004882 <log_write>
      brelse(bp);
    80003bde:	854a                	mv	a0,s2
    80003be0:	00000097          	auipc	ra,0x0
    80003be4:	a20080e7          	jalr	-1504(ra) # 80003600 <brelse>
      return iget(dev, inum);
    80003be8:	85da                	mv	a1,s6
    80003bea:	8556                	mv	a0,s5
    80003bec:	00000097          	auipc	ra,0x0
    80003bf0:	db4080e7          	jalr	-588(ra) # 800039a0 <iget>
}
    80003bf4:	60a6                	ld	ra,72(sp)
    80003bf6:	6406                	ld	s0,64(sp)
    80003bf8:	74e2                	ld	s1,56(sp)
    80003bfa:	7942                	ld	s2,48(sp)
    80003bfc:	79a2                	ld	s3,40(sp)
    80003bfe:	7a02                	ld	s4,32(sp)
    80003c00:	6ae2                	ld	s5,24(sp)
    80003c02:	6b42                	ld	s6,16(sp)
    80003c04:	6ba2                	ld	s7,8(sp)
    80003c06:	6161                	addi	sp,sp,80
    80003c08:	8082                	ret

0000000080003c0a <iupdate>:
{
    80003c0a:	1101                	addi	sp,sp,-32
    80003c0c:	ec06                	sd	ra,24(sp)
    80003c0e:	e822                	sd	s0,16(sp)
    80003c10:	e426                	sd	s1,8(sp)
    80003c12:	e04a                	sd	s2,0(sp)
    80003c14:	1000                	addi	s0,sp,32
    80003c16:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c18:	415c                	lw	a5,4(a0)
    80003c1a:	0047d79b          	srliw	a5,a5,0x4
    80003c1e:	00022597          	auipc	a1,0x22
    80003c22:	3a25a583          	lw	a1,930(a1) # 80025fc0 <sb+0x18>
    80003c26:	9dbd                	addw	a1,a1,a5
    80003c28:	4108                	lw	a0,0(a0)
    80003c2a:	00000097          	auipc	ra,0x0
    80003c2e:	8a6080e7          	jalr	-1882(ra) # 800034d0 <bread>
    80003c32:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c34:	05850793          	addi	a5,a0,88
    80003c38:	40c8                	lw	a0,4(s1)
    80003c3a:	893d                	andi	a0,a0,15
    80003c3c:	051a                	slli	a0,a0,0x6
    80003c3e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003c40:	04449703          	lh	a4,68(s1)
    80003c44:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003c48:	04649703          	lh	a4,70(s1)
    80003c4c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003c50:	04849703          	lh	a4,72(s1)
    80003c54:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003c58:	04a49703          	lh	a4,74(s1)
    80003c5c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003c60:	44f8                	lw	a4,76(s1)
    80003c62:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c64:	03400613          	li	a2,52
    80003c68:	05048593          	addi	a1,s1,80
    80003c6c:	0531                	addi	a0,a0,12
    80003c6e:	ffffd097          	auipc	ra,0xffffd
    80003c72:	0ac080e7          	jalr	172(ra) # 80000d1a <memmove>
  log_write(bp);
    80003c76:	854a                	mv	a0,s2
    80003c78:	00001097          	auipc	ra,0x1
    80003c7c:	c0a080e7          	jalr	-1014(ra) # 80004882 <log_write>
  brelse(bp);
    80003c80:	854a                	mv	a0,s2
    80003c82:	00000097          	auipc	ra,0x0
    80003c86:	97e080e7          	jalr	-1666(ra) # 80003600 <brelse>
}
    80003c8a:	60e2                	ld	ra,24(sp)
    80003c8c:	6442                	ld	s0,16(sp)
    80003c8e:	64a2                	ld	s1,8(sp)
    80003c90:	6902                	ld	s2,0(sp)
    80003c92:	6105                	addi	sp,sp,32
    80003c94:	8082                	ret

0000000080003c96 <idup>:
{
    80003c96:	1101                	addi	sp,sp,-32
    80003c98:	ec06                	sd	ra,24(sp)
    80003c9a:	e822                	sd	s0,16(sp)
    80003c9c:	e426                	sd	s1,8(sp)
    80003c9e:	1000                	addi	s0,sp,32
    80003ca0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ca2:	00022517          	auipc	a0,0x22
    80003ca6:	32650513          	addi	a0,a0,806 # 80025fc8 <itable>
    80003caa:	ffffd097          	auipc	ra,0xffffd
    80003cae:	f18080e7          	jalr	-232(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003cb2:	449c                	lw	a5,8(s1)
    80003cb4:	2785                	addiw	a5,a5,1
    80003cb6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cb8:	00022517          	auipc	a0,0x22
    80003cbc:	31050513          	addi	a0,a0,784 # 80025fc8 <itable>
    80003cc0:	ffffd097          	auipc	ra,0xffffd
    80003cc4:	fb6080e7          	jalr	-74(ra) # 80000c76 <release>
}
    80003cc8:	8526                	mv	a0,s1
    80003cca:	60e2                	ld	ra,24(sp)
    80003ccc:	6442                	ld	s0,16(sp)
    80003cce:	64a2                	ld	s1,8(sp)
    80003cd0:	6105                	addi	sp,sp,32
    80003cd2:	8082                	ret

0000000080003cd4 <ilock>:
{
    80003cd4:	1101                	addi	sp,sp,-32
    80003cd6:	ec06                	sd	ra,24(sp)
    80003cd8:	e822                	sd	s0,16(sp)
    80003cda:	e426                	sd	s1,8(sp)
    80003cdc:	e04a                	sd	s2,0(sp)
    80003cde:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ce0:	c115                	beqz	a0,80003d04 <ilock+0x30>
    80003ce2:	84aa                	mv	s1,a0
    80003ce4:	451c                	lw	a5,8(a0)
    80003ce6:	00f05f63          	blez	a5,80003d04 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003cea:	0541                	addi	a0,a0,16
    80003cec:	00001097          	auipc	ra,0x1
    80003cf0:	cb6080e7          	jalr	-842(ra) # 800049a2 <acquiresleep>
  if(ip->valid == 0){
    80003cf4:	40bc                	lw	a5,64(s1)
    80003cf6:	cf99                	beqz	a5,80003d14 <ilock+0x40>
}
    80003cf8:	60e2                	ld	ra,24(sp)
    80003cfa:	6442                	ld	s0,16(sp)
    80003cfc:	64a2                	ld	s1,8(sp)
    80003cfe:	6902                	ld	s2,0(sp)
    80003d00:	6105                	addi	sp,sp,32
    80003d02:	8082                	ret
    panic("ilock");
    80003d04:	00005517          	auipc	a0,0x5
    80003d08:	90450513          	addi	a0,a0,-1788 # 80008608 <syscalls+0x1d8>
    80003d0c:	ffffd097          	auipc	ra,0xffffd
    80003d10:	81e080e7          	jalr	-2018(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d14:	40dc                	lw	a5,4(s1)
    80003d16:	0047d79b          	srliw	a5,a5,0x4
    80003d1a:	00022597          	auipc	a1,0x22
    80003d1e:	2a65a583          	lw	a1,678(a1) # 80025fc0 <sb+0x18>
    80003d22:	9dbd                	addw	a1,a1,a5
    80003d24:	4088                	lw	a0,0(s1)
    80003d26:	fffff097          	auipc	ra,0xfffff
    80003d2a:	7aa080e7          	jalr	1962(ra) # 800034d0 <bread>
    80003d2e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d30:	05850593          	addi	a1,a0,88
    80003d34:	40dc                	lw	a5,4(s1)
    80003d36:	8bbd                	andi	a5,a5,15
    80003d38:	079a                	slli	a5,a5,0x6
    80003d3a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d3c:	00059783          	lh	a5,0(a1)
    80003d40:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003d44:	00259783          	lh	a5,2(a1)
    80003d48:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d4c:	00459783          	lh	a5,4(a1)
    80003d50:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d54:	00659783          	lh	a5,6(a1)
    80003d58:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d5c:	459c                	lw	a5,8(a1)
    80003d5e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d60:	03400613          	li	a2,52
    80003d64:	05b1                	addi	a1,a1,12
    80003d66:	05048513          	addi	a0,s1,80
    80003d6a:	ffffd097          	auipc	ra,0xffffd
    80003d6e:	fb0080e7          	jalr	-80(ra) # 80000d1a <memmove>
    brelse(bp);
    80003d72:	854a                	mv	a0,s2
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	88c080e7          	jalr	-1908(ra) # 80003600 <brelse>
    ip->valid = 1;
    80003d7c:	4785                	li	a5,1
    80003d7e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d80:	04449783          	lh	a5,68(s1)
    80003d84:	fbb5                	bnez	a5,80003cf8 <ilock+0x24>
      panic("ilock: no type");
    80003d86:	00005517          	auipc	a0,0x5
    80003d8a:	88a50513          	addi	a0,a0,-1910 # 80008610 <syscalls+0x1e0>
    80003d8e:	ffffc097          	auipc	ra,0xffffc
    80003d92:	79c080e7          	jalr	1948(ra) # 8000052a <panic>

0000000080003d96 <iunlock>:
{
    80003d96:	1101                	addi	sp,sp,-32
    80003d98:	ec06                	sd	ra,24(sp)
    80003d9a:	e822                	sd	s0,16(sp)
    80003d9c:	e426                	sd	s1,8(sp)
    80003d9e:	e04a                	sd	s2,0(sp)
    80003da0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003da2:	c905                	beqz	a0,80003dd2 <iunlock+0x3c>
    80003da4:	84aa                	mv	s1,a0
    80003da6:	01050913          	addi	s2,a0,16
    80003daa:	854a                	mv	a0,s2
    80003dac:	00001097          	auipc	ra,0x1
    80003db0:	c90080e7          	jalr	-880(ra) # 80004a3c <holdingsleep>
    80003db4:	cd19                	beqz	a0,80003dd2 <iunlock+0x3c>
    80003db6:	449c                	lw	a5,8(s1)
    80003db8:	00f05d63          	blez	a5,80003dd2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003dbc:	854a                	mv	a0,s2
    80003dbe:	00001097          	auipc	ra,0x1
    80003dc2:	c3a080e7          	jalr	-966(ra) # 800049f8 <releasesleep>
}
    80003dc6:	60e2                	ld	ra,24(sp)
    80003dc8:	6442                	ld	s0,16(sp)
    80003dca:	64a2                	ld	s1,8(sp)
    80003dcc:	6902                	ld	s2,0(sp)
    80003dce:	6105                	addi	sp,sp,32
    80003dd0:	8082                	ret
    panic("iunlock");
    80003dd2:	00005517          	auipc	a0,0x5
    80003dd6:	84e50513          	addi	a0,a0,-1970 # 80008620 <syscalls+0x1f0>
    80003dda:	ffffc097          	auipc	ra,0xffffc
    80003dde:	750080e7          	jalr	1872(ra) # 8000052a <panic>

0000000080003de2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003de2:	7179                	addi	sp,sp,-48
    80003de4:	f406                	sd	ra,40(sp)
    80003de6:	f022                	sd	s0,32(sp)
    80003de8:	ec26                	sd	s1,24(sp)
    80003dea:	e84a                	sd	s2,16(sp)
    80003dec:	e44e                	sd	s3,8(sp)
    80003dee:	e052                	sd	s4,0(sp)
    80003df0:	1800                	addi	s0,sp,48
    80003df2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003df4:	05050493          	addi	s1,a0,80
    80003df8:	08050913          	addi	s2,a0,128
    80003dfc:	a021                	j	80003e04 <itrunc+0x22>
    80003dfe:	0491                	addi	s1,s1,4
    80003e00:	01248d63          	beq	s1,s2,80003e1a <itrunc+0x38>
    if(ip->addrs[i]){
    80003e04:	408c                	lw	a1,0(s1)
    80003e06:	dde5                	beqz	a1,80003dfe <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003e08:	0009a503          	lw	a0,0(s3)
    80003e0c:	00000097          	auipc	ra,0x0
    80003e10:	90a080e7          	jalr	-1782(ra) # 80003716 <bfree>
      ip->addrs[i] = 0;
    80003e14:	0004a023          	sw	zero,0(s1)
    80003e18:	b7dd                	j	80003dfe <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003e1a:	0809a583          	lw	a1,128(s3)
    80003e1e:	e185                	bnez	a1,80003e3e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e20:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e24:	854e                	mv	a0,s3
    80003e26:	00000097          	auipc	ra,0x0
    80003e2a:	de4080e7          	jalr	-540(ra) # 80003c0a <iupdate>
}
    80003e2e:	70a2                	ld	ra,40(sp)
    80003e30:	7402                	ld	s0,32(sp)
    80003e32:	64e2                	ld	s1,24(sp)
    80003e34:	6942                	ld	s2,16(sp)
    80003e36:	69a2                	ld	s3,8(sp)
    80003e38:	6a02                	ld	s4,0(sp)
    80003e3a:	6145                	addi	sp,sp,48
    80003e3c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e3e:	0009a503          	lw	a0,0(s3)
    80003e42:	fffff097          	auipc	ra,0xfffff
    80003e46:	68e080e7          	jalr	1678(ra) # 800034d0 <bread>
    80003e4a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e4c:	05850493          	addi	s1,a0,88
    80003e50:	45850913          	addi	s2,a0,1112
    80003e54:	a021                	j	80003e5c <itrunc+0x7a>
    80003e56:	0491                	addi	s1,s1,4
    80003e58:	01248b63          	beq	s1,s2,80003e6e <itrunc+0x8c>
      if(a[j])
    80003e5c:	408c                	lw	a1,0(s1)
    80003e5e:	dde5                	beqz	a1,80003e56 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003e60:	0009a503          	lw	a0,0(s3)
    80003e64:	00000097          	auipc	ra,0x0
    80003e68:	8b2080e7          	jalr	-1870(ra) # 80003716 <bfree>
    80003e6c:	b7ed                	j	80003e56 <itrunc+0x74>
    brelse(bp);
    80003e6e:	8552                	mv	a0,s4
    80003e70:	fffff097          	auipc	ra,0xfffff
    80003e74:	790080e7          	jalr	1936(ra) # 80003600 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e78:	0809a583          	lw	a1,128(s3)
    80003e7c:	0009a503          	lw	a0,0(s3)
    80003e80:	00000097          	auipc	ra,0x0
    80003e84:	896080e7          	jalr	-1898(ra) # 80003716 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e88:	0809a023          	sw	zero,128(s3)
    80003e8c:	bf51                	j	80003e20 <itrunc+0x3e>

0000000080003e8e <iput>:
{
    80003e8e:	1101                	addi	sp,sp,-32
    80003e90:	ec06                	sd	ra,24(sp)
    80003e92:	e822                	sd	s0,16(sp)
    80003e94:	e426                	sd	s1,8(sp)
    80003e96:	e04a                	sd	s2,0(sp)
    80003e98:	1000                	addi	s0,sp,32
    80003e9a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e9c:	00022517          	auipc	a0,0x22
    80003ea0:	12c50513          	addi	a0,a0,300 # 80025fc8 <itable>
    80003ea4:	ffffd097          	auipc	ra,0xffffd
    80003ea8:	d1e080e7          	jalr	-738(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003eac:	4498                	lw	a4,8(s1)
    80003eae:	4785                	li	a5,1
    80003eb0:	02f70363          	beq	a4,a5,80003ed6 <iput+0x48>
  ip->ref--;
    80003eb4:	449c                	lw	a5,8(s1)
    80003eb6:	37fd                	addiw	a5,a5,-1
    80003eb8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003eba:	00022517          	auipc	a0,0x22
    80003ebe:	10e50513          	addi	a0,a0,270 # 80025fc8 <itable>
    80003ec2:	ffffd097          	auipc	ra,0xffffd
    80003ec6:	db4080e7          	jalr	-588(ra) # 80000c76 <release>
}
    80003eca:	60e2                	ld	ra,24(sp)
    80003ecc:	6442                	ld	s0,16(sp)
    80003ece:	64a2                	ld	s1,8(sp)
    80003ed0:	6902                	ld	s2,0(sp)
    80003ed2:	6105                	addi	sp,sp,32
    80003ed4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ed6:	40bc                	lw	a5,64(s1)
    80003ed8:	dff1                	beqz	a5,80003eb4 <iput+0x26>
    80003eda:	04a49783          	lh	a5,74(s1)
    80003ede:	fbf9                	bnez	a5,80003eb4 <iput+0x26>
    acquiresleep(&ip->lock);
    80003ee0:	01048913          	addi	s2,s1,16
    80003ee4:	854a                	mv	a0,s2
    80003ee6:	00001097          	auipc	ra,0x1
    80003eea:	abc080e7          	jalr	-1348(ra) # 800049a2 <acquiresleep>
    release(&itable.lock);
    80003eee:	00022517          	auipc	a0,0x22
    80003ef2:	0da50513          	addi	a0,a0,218 # 80025fc8 <itable>
    80003ef6:	ffffd097          	auipc	ra,0xffffd
    80003efa:	d80080e7          	jalr	-640(ra) # 80000c76 <release>
    itrunc(ip);
    80003efe:	8526                	mv	a0,s1
    80003f00:	00000097          	auipc	ra,0x0
    80003f04:	ee2080e7          	jalr	-286(ra) # 80003de2 <itrunc>
    ip->type = 0;
    80003f08:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f0c:	8526                	mv	a0,s1
    80003f0e:	00000097          	auipc	ra,0x0
    80003f12:	cfc080e7          	jalr	-772(ra) # 80003c0a <iupdate>
    ip->valid = 0;
    80003f16:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f1a:	854a                	mv	a0,s2
    80003f1c:	00001097          	auipc	ra,0x1
    80003f20:	adc080e7          	jalr	-1316(ra) # 800049f8 <releasesleep>
    acquire(&itable.lock);
    80003f24:	00022517          	auipc	a0,0x22
    80003f28:	0a450513          	addi	a0,a0,164 # 80025fc8 <itable>
    80003f2c:	ffffd097          	auipc	ra,0xffffd
    80003f30:	c96080e7          	jalr	-874(ra) # 80000bc2 <acquire>
    80003f34:	b741                	j	80003eb4 <iput+0x26>

0000000080003f36 <iunlockput>:
{
    80003f36:	1101                	addi	sp,sp,-32
    80003f38:	ec06                	sd	ra,24(sp)
    80003f3a:	e822                	sd	s0,16(sp)
    80003f3c:	e426                	sd	s1,8(sp)
    80003f3e:	1000                	addi	s0,sp,32
    80003f40:	84aa                	mv	s1,a0
  iunlock(ip);
    80003f42:	00000097          	auipc	ra,0x0
    80003f46:	e54080e7          	jalr	-428(ra) # 80003d96 <iunlock>
  iput(ip);
    80003f4a:	8526                	mv	a0,s1
    80003f4c:	00000097          	auipc	ra,0x0
    80003f50:	f42080e7          	jalr	-190(ra) # 80003e8e <iput>
}
    80003f54:	60e2                	ld	ra,24(sp)
    80003f56:	6442                	ld	s0,16(sp)
    80003f58:	64a2                	ld	s1,8(sp)
    80003f5a:	6105                	addi	sp,sp,32
    80003f5c:	8082                	ret

0000000080003f5e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f5e:	1141                	addi	sp,sp,-16
    80003f60:	e422                	sd	s0,8(sp)
    80003f62:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f64:	411c                	lw	a5,0(a0)
    80003f66:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f68:	415c                	lw	a5,4(a0)
    80003f6a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f6c:	04451783          	lh	a5,68(a0)
    80003f70:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f74:	04a51783          	lh	a5,74(a0)
    80003f78:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f7c:	04c56783          	lwu	a5,76(a0)
    80003f80:	e99c                	sd	a5,16(a1)
}
    80003f82:	6422                	ld	s0,8(sp)
    80003f84:	0141                	addi	sp,sp,16
    80003f86:	8082                	ret

0000000080003f88 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f88:	457c                	lw	a5,76(a0)
    80003f8a:	0ed7e963          	bltu	a5,a3,8000407c <readi+0xf4>
{
    80003f8e:	7159                	addi	sp,sp,-112
    80003f90:	f486                	sd	ra,104(sp)
    80003f92:	f0a2                	sd	s0,96(sp)
    80003f94:	eca6                	sd	s1,88(sp)
    80003f96:	e8ca                	sd	s2,80(sp)
    80003f98:	e4ce                	sd	s3,72(sp)
    80003f9a:	e0d2                	sd	s4,64(sp)
    80003f9c:	fc56                	sd	s5,56(sp)
    80003f9e:	f85a                	sd	s6,48(sp)
    80003fa0:	f45e                	sd	s7,40(sp)
    80003fa2:	f062                	sd	s8,32(sp)
    80003fa4:	ec66                	sd	s9,24(sp)
    80003fa6:	e86a                	sd	s10,16(sp)
    80003fa8:	e46e                	sd	s11,8(sp)
    80003faa:	1880                	addi	s0,sp,112
    80003fac:	8baa                	mv	s7,a0
    80003fae:	8c2e                	mv	s8,a1
    80003fb0:	8ab2                	mv	s5,a2
    80003fb2:	84b6                	mv	s1,a3
    80003fb4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fb6:	9f35                	addw	a4,a4,a3
    return 0;
    80003fb8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003fba:	0ad76063          	bltu	a4,a3,8000405a <readi+0xd2>
  if(off + n > ip->size)
    80003fbe:	00e7f463          	bgeu	a5,a4,80003fc6 <readi+0x3e>
    n = ip->size - off;
    80003fc2:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fc6:	0a0b0963          	beqz	s6,80004078 <readi+0xf0>
    80003fca:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fcc:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003fd0:	5cfd                	li	s9,-1
    80003fd2:	a82d                	j	8000400c <readi+0x84>
    80003fd4:	020a1d93          	slli	s11,s4,0x20
    80003fd8:	020ddd93          	srli	s11,s11,0x20
    80003fdc:	05890793          	addi	a5,s2,88
    80003fe0:	86ee                	mv	a3,s11
    80003fe2:	963e                	add	a2,a2,a5
    80003fe4:	85d6                	mv	a1,s5
    80003fe6:	8562                	mv	a0,s8
    80003fe8:	ffffe097          	auipc	ra,0xffffe
    80003fec:	716080e7          	jalr	1814(ra) # 800026fe <either_copyout>
    80003ff0:	05950d63          	beq	a0,s9,8000404a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ff4:	854a                	mv	a0,s2
    80003ff6:	fffff097          	auipc	ra,0xfffff
    80003ffa:	60a080e7          	jalr	1546(ra) # 80003600 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ffe:	013a09bb          	addw	s3,s4,s3
    80004002:	009a04bb          	addw	s1,s4,s1
    80004006:	9aee                	add	s5,s5,s11
    80004008:	0569f763          	bgeu	s3,s6,80004056 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000400c:	000ba903          	lw	s2,0(s7)
    80004010:	00a4d59b          	srliw	a1,s1,0xa
    80004014:	855e                	mv	a0,s7
    80004016:	00000097          	auipc	ra,0x0
    8000401a:	8ae080e7          	jalr	-1874(ra) # 800038c4 <bmap>
    8000401e:	0005059b          	sext.w	a1,a0
    80004022:	854a                	mv	a0,s2
    80004024:	fffff097          	auipc	ra,0xfffff
    80004028:	4ac080e7          	jalr	1196(ra) # 800034d0 <bread>
    8000402c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000402e:	3ff4f613          	andi	a2,s1,1023
    80004032:	40cd07bb          	subw	a5,s10,a2
    80004036:	413b073b          	subw	a4,s6,s3
    8000403a:	8a3e                	mv	s4,a5
    8000403c:	2781                	sext.w	a5,a5
    8000403e:	0007069b          	sext.w	a3,a4
    80004042:	f8f6f9e3          	bgeu	a3,a5,80003fd4 <readi+0x4c>
    80004046:	8a3a                	mv	s4,a4
    80004048:	b771                	j	80003fd4 <readi+0x4c>
      brelse(bp);
    8000404a:	854a                	mv	a0,s2
    8000404c:	fffff097          	auipc	ra,0xfffff
    80004050:	5b4080e7          	jalr	1460(ra) # 80003600 <brelse>
      tot = -1;
    80004054:	59fd                	li	s3,-1
  }
  return tot;
    80004056:	0009851b          	sext.w	a0,s3
}
    8000405a:	70a6                	ld	ra,104(sp)
    8000405c:	7406                	ld	s0,96(sp)
    8000405e:	64e6                	ld	s1,88(sp)
    80004060:	6946                	ld	s2,80(sp)
    80004062:	69a6                	ld	s3,72(sp)
    80004064:	6a06                	ld	s4,64(sp)
    80004066:	7ae2                	ld	s5,56(sp)
    80004068:	7b42                	ld	s6,48(sp)
    8000406a:	7ba2                	ld	s7,40(sp)
    8000406c:	7c02                	ld	s8,32(sp)
    8000406e:	6ce2                	ld	s9,24(sp)
    80004070:	6d42                	ld	s10,16(sp)
    80004072:	6da2                	ld	s11,8(sp)
    80004074:	6165                	addi	sp,sp,112
    80004076:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004078:	89da                	mv	s3,s6
    8000407a:	bff1                	j	80004056 <readi+0xce>
    return 0;
    8000407c:	4501                	li	a0,0
}
    8000407e:	8082                	ret

0000000080004080 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004080:	457c                	lw	a5,76(a0)
    80004082:	10d7e863          	bltu	a5,a3,80004192 <writei+0x112>
{
    80004086:	7159                	addi	sp,sp,-112
    80004088:	f486                	sd	ra,104(sp)
    8000408a:	f0a2                	sd	s0,96(sp)
    8000408c:	eca6                	sd	s1,88(sp)
    8000408e:	e8ca                	sd	s2,80(sp)
    80004090:	e4ce                	sd	s3,72(sp)
    80004092:	e0d2                	sd	s4,64(sp)
    80004094:	fc56                	sd	s5,56(sp)
    80004096:	f85a                	sd	s6,48(sp)
    80004098:	f45e                	sd	s7,40(sp)
    8000409a:	f062                	sd	s8,32(sp)
    8000409c:	ec66                	sd	s9,24(sp)
    8000409e:	e86a                	sd	s10,16(sp)
    800040a0:	e46e                	sd	s11,8(sp)
    800040a2:	1880                	addi	s0,sp,112
    800040a4:	8b2a                	mv	s6,a0
    800040a6:	8c2e                	mv	s8,a1
    800040a8:	8ab2                	mv	s5,a2
    800040aa:	8936                	mv	s2,a3
    800040ac:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800040ae:	00e687bb          	addw	a5,a3,a4
    800040b2:	0ed7e263          	bltu	a5,a3,80004196 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800040b6:	00043737          	lui	a4,0x43
    800040ba:	0ef76063          	bltu	a4,a5,8000419a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040be:	0c0b8863          	beqz	s7,8000418e <writei+0x10e>
    800040c2:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800040c4:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800040c8:	5cfd                	li	s9,-1
    800040ca:	a091                	j	8000410e <writei+0x8e>
    800040cc:	02099d93          	slli	s11,s3,0x20
    800040d0:	020ddd93          	srli	s11,s11,0x20
    800040d4:	05848793          	addi	a5,s1,88
    800040d8:	86ee                	mv	a3,s11
    800040da:	8656                	mv	a2,s5
    800040dc:	85e2                	mv	a1,s8
    800040de:	953e                	add	a0,a0,a5
    800040e0:	ffffe097          	auipc	ra,0xffffe
    800040e4:	674080e7          	jalr	1652(ra) # 80002754 <either_copyin>
    800040e8:	07950263          	beq	a0,s9,8000414c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800040ec:	8526                	mv	a0,s1
    800040ee:	00000097          	auipc	ra,0x0
    800040f2:	794080e7          	jalr	1940(ra) # 80004882 <log_write>
    brelse(bp);
    800040f6:	8526                	mv	a0,s1
    800040f8:	fffff097          	auipc	ra,0xfffff
    800040fc:	508080e7          	jalr	1288(ra) # 80003600 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004100:	01498a3b          	addw	s4,s3,s4
    80004104:	0129893b          	addw	s2,s3,s2
    80004108:	9aee                	add	s5,s5,s11
    8000410a:	057a7663          	bgeu	s4,s7,80004156 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000410e:	000b2483          	lw	s1,0(s6)
    80004112:	00a9559b          	srliw	a1,s2,0xa
    80004116:	855a                	mv	a0,s6
    80004118:	fffff097          	auipc	ra,0xfffff
    8000411c:	7ac080e7          	jalr	1964(ra) # 800038c4 <bmap>
    80004120:	0005059b          	sext.w	a1,a0
    80004124:	8526                	mv	a0,s1
    80004126:	fffff097          	auipc	ra,0xfffff
    8000412a:	3aa080e7          	jalr	938(ra) # 800034d0 <bread>
    8000412e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004130:	3ff97513          	andi	a0,s2,1023
    80004134:	40ad07bb          	subw	a5,s10,a0
    80004138:	414b873b          	subw	a4,s7,s4
    8000413c:	89be                	mv	s3,a5
    8000413e:	2781                	sext.w	a5,a5
    80004140:	0007069b          	sext.w	a3,a4
    80004144:	f8f6f4e3          	bgeu	a3,a5,800040cc <writei+0x4c>
    80004148:	89ba                	mv	s3,a4
    8000414a:	b749                	j	800040cc <writei+0x4c>
      brelse(bp);
    8000414c:	8526                	mv	a0,s1
    8000414e:	fffff097          	auipc	ra,0xfffff
    80004152:	4b2080e7          	jalr	1202(ra) # 80003600 <brelse>
  }

  if(off > ip->size)
    80004156:	04cb2783          	lw	a5,76(s6)
    8000415a:	0127f463          	bgeu	a5,s2,80004162 <writei+0xe2>
    ip->size = off;
    8000415e:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004162:	855a                	mv	a0,s6
    80004164:	00000097          	auipc	ra,0x0
    80004168:	aa6080e7          	jalr	-1370(ra) # 80003c0a <iupdate>

  return tot;
    8000416c:	000a051b          	sext.w	a0,s4
}
    80004170:	70a6                	ld	ra,104(sp)
    80004172:	7406                	ld	s0,96(sp)
    80004174:	64e6                	ld	s1,88(sp)
    80004176:	6946                	ld	s2,80(sp)
    80004178:	69a6                	ld	s3,72(sp)
    8000417a:	6a06                	ld	s4,64(sp)
    8000417c:	7ae2                	ld	s5,56(sp)
    8000417e:	7b42                	ld	s6,48(sp)
    80004180:	7ba2                	ld	s7,40(sp)
    80004182:	7c02                	ld	s8,32(sp)
    80004184:	6ce2                	ld	s9,24(sp)
    80004186:	6d42                	ld	s10,16(sp)
    80004188:	6da2                	ld	s11,8(sp)
    8000418a:	6165                	addi	sp,sp,112
    8000418c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000418e:	8a5e                	mv	s4,s7
    80004190:	bfc9                	j	80004162 <writei+0xe2>
    return -1;
    80004192:	557d                	li	a0,-1
}
    80004194:	8082                	ret
    return -1;
    80004196:	557d                	li	a0,-1
    80004198:	bfe1                	j	80004170 <writei+0xf0>
    return -1;
    8000419a:	557d                	li	a0,-1
    8000419c:	bfd1                	j	80004170 <writei+0xf0>

000000008000419e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000419e:	1141                	addi	sp,sp,-16
    800041a0:	e406                	sd	ra,8(sp)
    800041a2:	e022                	sd	s0,0(sp)
    800041a4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800041a6:	4639                	li	a2,14
    800041a8:	ffffd097          	auipc	ra,0xffffd
    800041ac:	bee080e7          	jalr	-1042(ra) # 80000d96 <strncmp>
}
    800041b0:	60a2                	ld	ra,8(sp)
    800041b2:	6402                	ld	s0,0(sp)
    800041b4:	0141                	addi	sp,sp,16
    800041b6:	8082                	ret

00000000800041b8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800041b8:	7139                	addi	sp,sp,-64
    800041ba:	fc06                	sd	ra,56(sp)
    800041bc:	f822                	sd	s0,48(sp)
    800041be:	f426                	sd	s1,40(sp)
    800041c0:	f04a                	sd	s2,32(sp)
    800041c2:	ec4e                	sd	s3,24(sp)
    800041c4:	e852                	sd	s4,16(sp)
    800041c6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800041c8:	04451703          	lh	a4,68(a0)
    800041cc:	4785                	li	a5,1
    800041ce:	00f71a63          	bne	a4,a5,800041e2 <dirlookup+0x2a>
    800041d2:	892a                	mv	s2,a0
    800041d4:	89ae                	mv	s3,a1
    800041d6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800041d8:	457c                	lw	a5,76(a0)
    800041da:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800041dc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041de:	e79d                	bnez	a5,8000420c <dirlookup+0x54>
    800041e0:	a8a5                	j	80004258 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800041e2:	00004517          	auipc	a0,0x4
    800041e6:	44650513          	addi	a0,a0,1094 # 80008628 <syscalls+0x1f8>
    800041ea:	ffffc097          	auipc	ra,0xffffc
    800041ee:	340080e7          	jalr	832(ra) # 8000052a <panic>
      panic("dirlookup read");
    800041f2:	00004517          	auipc	a0,0x4
    800041f6:	44e50513          	addi	a0,a0,1102 # 80008640 <syscalls+0x210>
    800041fa:	ffffc097          	auipc	ra,0xffffc
    800041fe:	330080e7          	jalr	816(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004202:	24c1                	addiw	s1,s1,16
    80004204:	04c92783          	lw	a5,76(s2)
    80004208:	04f4f763          	bgeu	s1,a5,80004256 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000420c:	4741                	li	a4,16
    8000420e:	86a6                	mv	a3,s1
    80004210:	fc040613          	addi	a2,s0,-64
    80004214:	4581                	li	a1,0
    80004216:	854a                	mv	a0,s2
    80004218:	00000097          	auipc	ra,0x0
    8000421c:	d70080e7          	jalr	-656(ra) # 80003f88 <readi>
    80004220:	47c1                	li	a5,16
    80004222:	fcf518e3          	bne	a0,a5,800041f2 <dirlookup+0x3a>
    if(de.inum == 0)
    80004226:	fc045783          	lhu	a5,-64(s0)
    8000422a:	dfe1                	beqz	a5,80004202 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000422c:	fc240593          	addi	a1,s0,-62
    80004230:	854e                	mv	a0,s3
    80004232:	00000097          	auipc	ra,0x0
    80004236:	f6c080e7          	jalr	-148(ra) # 8000419e <namecmp>
    8000423a:	f561                	bnez	a0,80004202 <dirlookup+0x4a>
      if(poff)
    8000423c:	000a0463          	beqz	s4,80004244 <dirlookup+0x8c>
        *poff = off;
    80004240:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004244:	fc045583          	lhu	a1,-64(s0)
    80004248:	00092503          	lw	a0,0(s2)
    8000424c:	fffff097          	auipc	ra,0xfffff
    80004250:	754080e7          	jalr	1876(ra) # 800039a0 <iget>
    80004254:	a011                	j	80004258 <dirlookup+0xa0>
  return 0;
    80004256:	4501                	li	a0,0
}
    80004258:	70e2                	ld	ra,56(sp)
    8000425a:	7442                	ld	s0,48(sp)
    8000425c:	74a2                	ld	s1,40(sp)
    8000425e:	7902                	ld	s2,32(sp)
    80004260:	69e2                	ld	s3,24(sp)
    80004262:	6a42                	ld	s4,16(sp)
    80004264:	6121                	addi	sp,sp,64
    80004266:	8082                	ret

0000000080004268 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004268:	711d                	addi	sp,sp,-96
    8000426a:	ec86                	sd	ra,88(sp)
    8000426c:	e8a2                	sd	s0,80(sp)
    8000426e:	e4a6                	sd	s1,72(sp)
    80004270:	e0ca                	sd	s2,64(sp)
    80004272:	fc4e                	sd	s3,56(sp)
    80004274:	f852                	sd	s4,48(sp)
    80004276:	f456                	sd	s5,40(sp)
    80004278:	f05a                	sd	s6,32(sp)
    8000427a:	ec5e                	sd	s7,24(sp)
    8000427c:	e862                	sd	s8,16(sp)
    8000427e:	e466                	sd	s9,8(sp)
    80004280:	1080                	addi	s0,sp,96
    80004282:	84aa                	mv	s1,a0
    80004284:	8aae                	mv	s5,a1
    80004286:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004288:	00054703          	lbu	a4,0(a0)
    8000428c:	02f00793          	li	a5,47
    80004290:	02f70363          	beq	a4,a5,800042b6 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004294:	ffffd097          	auipc	ra,0xffffd
    80004298:	6ea080e7          	jalr	1770(ra) # 8000197e <myproc>
    8000429c:	15053503          	ld	a0,336(a0)
    800042a0:	00000097          	auipc	ra,0x0
    800042a4:	9f6080e7          	jalr	-1546(ra) # 80003c96 <idup>
    800042a8:	89aa                	mv	s3,a0
  while(*path == '/')
    800042aa:	02f00913          	li	s2,47
  len = path - s;
    800042ae:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800042b0:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800042b2:	4b85                	li	s7,1
    800042b4:	a865                	j	8000436c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800042b6:	4585                	li	a1,1
    800042b8:	4505                	li	a0,1
    800042ba:	fffff097          	auipc	ra,0xfffff
    800042be:	6e6080e7          	jalr	1766(ra) # 800039a0 <iget>
    800042c2:	89aa                	mv	s3,a0
    800042c4:	b7dd                	j	800042aa <namex+0x42>
      iunlockput(ip);
    800042c6:	854e                	mv	a0,s3
    800042c8:	00000097          	auipc	ra,0x0
    800042cc:	c6e080e7          	jalr	-914(ra) # 80003f36 <iunlockput>
      return 0;
    800042d0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800042d2:	854e                	mv	a0,s3
    800042d4:	60e6                	ld	ra,88(sp)
    800042d6:	6446                	ld	s0,80(sp)
    800042d8:	64a6                	ld	s1,72(sp)
    800042da:	6906                	ld	s2,64(sp)
    800042dc:	79e2                	ld	s3,56(sp)
    800042de:	7a42                	ld	s4,48(sp)
    800042e0:	7aa2                	ld	s5,40(sp)
    800042e2:	7b02                	ld	s6,32(sp)
    800042e4:	6be2                	ld	s7,24(sp)
    800042e6:	6c42                	ld	s8,16(sp)
    800042e8:	6ca2                	ld	s9,8(sp)
    800042ea:	6125                	addi	sp,sp,96
    800042ec:	8082                	ret
      iunlock(ip);
    800042ee:	854e                	mv	a0,s3
    800042f0:	00000097          	auipc	ra,0x0
    800042f4:	aa6080e7          	jalr	-1370(ra) # 80003d96 <iunlock>
      return ip;
    800042f8:	bfe9                	j	800042d2 <namex+0x6a>
      iunlockput(ip);
    800042fa:	854e                	mv	a0,s3
    800042fc:	00000097          	auipc	ra,0x0
    80004300:	c3a080e7          	jalr	-966(ra) # 80003f36 <iunlockput>
      return 0;
    80004304:	89e6                	mv	s3,s9
    80004306:	b7f1                	j	800042d2 <namex+0x6a>
  len = path - s;
    80004308:	40b48633          	sub	a2,s1,a1
    8000430c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004310:	099c5463          	bge	s8,s9,80004398 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004314:	4639                	li	a2,14
    80004316:	8552                	mv	a0,s4
    80004318:	ffffd097          	auipc	ra,0xffffd
    8000431c:	a02080e7          	jalr	-1534(ra) # 80000d1a <memmove>
  while(*path == '/')
    80004320:	0004c783          	lbu	a5,0(s1)
    80004324:	01279763          	bne	a5,s2,80004332 <namex+0xca>
    path++;
    80004328:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000432a:	0004c783          	lbu	a5,0(s1)
    8000432e:	ff278de3          	beq	a5,s2,80004328 <namex+0xc0>
    ilock(ip);
    80004332:	854e                	mv	a0,s3
    80004334:	00000097          	auipc	ra,0x0
    80004338:	9a0080e7          	jalr	-1632(ra) # 80003cd4 <ilock>
    if(ip->type != T_DIR){
    8000433c:	04499783          	lh	a5,68(s3)
    80004340:	f97793e3          	bne	a5,s7,800042c6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004344:	000a8563          	beqz	s5,8000434e <namex+0xe6>
    80004348:	0004c783          	lbu	a5,0(s1)
    8000434c:	d3cd                	beqz	a5,800042ee <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000434e:	865a                	mv	a2,s6
    80004350:	85d2                	mv	a1,s4
    80004352:	854e                	mv	a0,s3
    80004354:	00000097          	auipc	ra,0x0
    80004358:	e64080e7          	jalr	-412(ra) # 800041b8 <dirlookup>
    8000435c:	8caa                	mv	s9,a0
    8000435e:	dd51                	beqz	a0,800042fa <namex+0x92>
    iunlockput(ip);
    80004360:	854e                	mv	a0,s3
    80004362:	00000097          	auipc	ra,0x0
    80004366:	bd4080e7          	jalr	-1068(ra) # 80003f36 <iunlockput>
    ip = next;
    8000436a:	89e6                	mv	s3,s9
  while(*path == '/')
    8000436c:	0004c783          	lbu	a5,0(s1)
    80004370:	05279763          	bne	a5,s2,800043be <namex+0x156>
    path++;
    80004374:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004376:	0004c783          	lbu	a5,0(s1)
    8000437a:	ff278de3          	beq	a5,s2,80004374 <namex+0x10c>
  if(*path == 0)
    8000437e:	c79d                	beqz	a5,800043ac <namex+0x144>
    path++;
    80004380:	85a6                	mv	a1,s1
  len = path - s;
    80004382:	8cda                	mv	s9,s6
    80004384:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004386:	01278963          	beq	a5,s2,80004398 <namex+0x130>
    8000438a:	dfbd                	beqz	a5,80004308 <namex+0xa0>
    path++;
    8000438c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000438e:	0004c783          	lbu	a5,0(s1)
    80004392:	ff279ce3          	bne	a5,s2,8000438a <namex+0x122>
    80004396:	bf8d                	j	80004308 <namex+0xa0>
    memmove(name, s, len);
    80004398:	2601                	sext.w	a2,a2
    8000439a:	8552                	mv	a0,s4
    8000439c:	ffffd097          	auipc	ra,0xffffd
    800043a0:	97e080e7          	jalr	-1666(ra) # 80000d1a <memmove>
    name[len] = 0;
    800043a4:	9cd2                	add	s9,s9,s4
    800043a6:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800043aa:	bf9d                	j	80004320 <namex+0xb8>
  if(nameiparent){
    800043ac:	f20a83e3          	beqz	s5,800042d2 <namex+0x6a>
    iput(ip);
    800043b0:	854e                	mv	a0,s3
    800043b2:	00000097          	auipc	ra,0x0
    800043b6:	adc080e7          	jalr	-1316(ra) # 80003e8e <iput>
    return 0;
    800043ba:	4981                	li	s3,0
    800043bc:	bf19                	j	800042d2 <namex+0x6a>
  if(*path == 0)
    800043be:	d7fd                	beqz	a5,800043ac <namex+0x144>
  while(*path != '/' && *path != 0)
    800043c0:	0004c783          	lbu	a5,0(s1)
    800043c4:	85a6                	mv	a1,s1
    800043c6:	b7d1                	j	8000438a <namex+0x122>

00000000800043c8 <dirlink>:
{
    800043c8:	7139                	addi	sp,sp,-64
    800043ca:	fc06                	sd	ra,56(sp)
    800043cc:	f822                	sd	s0,48(sp)
    800043ce:	f426                	sd	s1,40(sp)
    800043d0:	f04a                	sd	s2,32(sp)
    800043d2:	ec4e                	sd	s3,24(sp)
    800043d4:	e852                	sd	s4,16(sp)
    800043d6:	0080                	addi	s0,sp,64
    800043d8:	892a                	mv	s2,a0
    800043da:	8a2e                	mv	s4,a1
    800043dc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800043de:	4601                	li	a2,0
    800043e0:	00000097          	auipc	ra,0x0
    800043e4:	dd8080e7          	jalr	-552(ra) # 800041b8 <dirlookup>
    800043e8:	e93d                	bnez	a0,8000445e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043ea:	04c92483          	lw	s1,76(s2)
    800043ee:	c49d                	beqz	s1,8000441c <dirlink+0x54>
    800043f0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043f2:	4741                	li	a4,16
    800043f4:	86a6                	mv	a3,s1
    800043f6:	fc040613          	addi	a2,s0,-64
    800043fa:	4581                	li	a1,0
    800043fc:	854a                	mv	a0,s2
    800043fe:	00000097          	auipc	ra,0x0
    80004402:	b8a080e7          	jalr	-1142(ra) # 80003f88 <readi>
    80004406:	47c1                	li	a5,16
    80004408:	06f51163          	bne	a0,a5,8000446a <dirlink+0xa2>
    if(de.inum == 0)
    8000440c:	fc045783          	lhu	a5,-64(s0)
    80004410:	c791                	beqz	a5,8000441c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004412:	24c1                	addiw	s1,s1,16
    80004414:	04c92783          	lw	a5,76(s2)
    80004418:	fcf4ede3          	bltu	s1,a5,800043f2 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000441c:	4639                	li	a2,14
    8000441e:	85d2                	mv	a1,s4
    80004420:	fc240513          	addi	a0,s0,-62
    80004424:	ffffd097          	auipc	ra,0xffffd
    80004428:	9ae080e7          	jalr	-1618(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    8000442c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004430:	4741                	li	a4,16
    80004432:	86a6                	mv	a3,s1
    80004434:	fc040613          	addi	a2,s0,-64
    80004438:	4581                	li	a1,0
    8000443a:	854a                	mv	a0,s2
    8000443c:	00000097          	auipc	ra,0x0
    80004440:	c44080e7          	jalr	-956(ra) # 80004080 <writei>
    80004444:	872a                	mv	a4,a0
    80004446:	47c1                	li	a5,16
  return 0;
    80004448:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000444a:	02f71863          	bne	a4,a5,8000447a <dirlink+0xb2>
}
    8000444e:	70e2                	ld	ra,56(sp)
    80004450:	7442                	ld	s0,48(sp)
    80004452:	74a2                	ld	s1,40(sp)
    80004454:	7902                	ld	s2,32(sp)
    80004456:	69e2                	ld	s3,24(sp)
    80004458:	6a42                	ld	s4,16(sp)
    8000445a:	6121                	addi	sp,sp,64
    8000445c:	8082                	ret
    iput(ip);
    8000445e:	00000097          	auipc	ra,0x0
    80004462:	a30080e7          	jalr	-1488(ra) # 80003e8e <iput>
    return -1;
    80004466:	557d                	li	a0,-1
    80004468:	b7dd                	j	8000444e <dirlink+0x86>
      panic("dirlink read");
    8000446a:	00004517          	auipc	a0,0x4
    8000446e:	1e650513          	addi	a0,a0,486 # 80008650 <syscalls+0x220>
    80004472:	ffffc097          	auipc	ra,0xffffc
    80004476:	0b8080e7          	jalr	184(ra) # 8000052a <panic>
    panic("dirlink");
    8000447a:	00004517          	auipc	a0,0x4
    8000447e:	2e650513          	addi	a0,a0,742 # 80008760 <syscalls+0x330>
    80004482:	ffffc097          	auipc	ra,0xffffc
    80004486:	0a8080e7          	jalr	168(ra) # 8000052a <panic>

000000008000448a <namei>:

struct inode*
namei(char *path)
{
    8000448a:	1101                	addi	sp,sp,-32
    8000448c:	ec06                	sd	ra,24(sp)
    8000448e:	e822                	sd	s0,16(sp)
    80004490:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004492:	fe040613          	addi	a2,s0,-32
    80004496:	4581                	li	a1,0
    80004498:	00000097          	auipc	ra,0x0
    8000449c:	dd0080e7          	jalr	-560(ra) # 80004268 <namex>
}
    800044a0:	60e2                	ld	ra,24(sp)
    800044a2:	6442                	ld	s0,16(sp)
    800044a4:	6105                	addi	sp,sp,32
    800044a6:	8082                	ret

00000000800044a8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800044a8:	1141                	addi	sp,sp,-16
    800044aa:	e406                	sd	ra,8(sp)
    800044ac:	e022                	sd	s0,0(sp)
    800044ae:	0800                	addi	s0,sp,16
    800044b0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800044b2:	4585                	li	a1,1
    800044b4:	00000097          	auipc	ra,0x0
    800044b8:	db4080e7          	jalr	-588(ra) # 80004268 <namex>
}
    800044bc:	60a2                	ld	ra,8(sp)
    800044be:	6402                	ld	s0,0(sp)
    800044c0:	0141                	addi	sp,sp,16
    800044c2:	8082                	ret

00000000800044c4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800044c4:	1101                	addi	sp,sp,-32
    800044c6:	ec06                	sd	ra,24(sp)
    800044c8:	e822                	sd	s0,16(sp)
    800044ca:	e426                	sd	s1,8(sp)
    800044cc:	e04a                	sd	s2,0(sp)
    800044ce:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044d0:	00023917          	auipc	s2,0x23
    800044d4:	5a090913          	addi	s2,s2,1440 # 80027a70 <log>
    800044d8:	01892583          	lw	a1,24(s2)
    800044dc:	02892503          	lw	a0,40(s2)
    800044e0:	fffff097          	auipc	ra,0xfffff
    800044e4:	ff0080e7          	jalr	-16(ra) # 800034d0 <bread>
    800044e8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800044ea:	02c92683          	lw	a3,44(s2)
    800044ee:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800044f0:	02d05863          	blez	a3,80004520 <write_head+0x5c>
    800044f4:	00023797          	auipc	a5,0x23
    800044f8:	5ac78793          	addi	a5,a5,1452 # 80027aa0 <log+0x30>
    800044fc:	05c50713          	addi	a4,a0,92
    80004500:	36fd                	addiw	a3,a3,-1
    80004502:	02069613          	slli	a2,a3,0x20
    80004506:	01e65693          	srli	a3,a2,0x1e
    8000450a:	00023617          	auipc	a2,0x23
    8000450e:	59a60613          	addi	a2,a2,1434 # 80027aa4 <log+0x34>
    80004512:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004514:	4390                	lw	a2,0(a5)
    80004516:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004518:	0791                	addi	a5,a5,4
    8000451a:	0711                	addi	a4,a4,4
    8000451c:	fed79ce3          	bne	a5,a3,80004514 <write_head+0x50>
  }
  bwrite(buf);
    80004520:	8526                	mv	a0,s1
    80004522:	fffff097          	auipc	ra,0xfffff
    80004526:	0a0080e7          	jalr	160(ra) # 800035c2 <bwrite>
  brelse(buf);
    8000452a:	8526                	mv	a0,s1
    8000452c:	fffff097          	auipc	ra,0xfffff
    80004530:	0d4080e7          	jalr	212(ra) # 80003600 <brelse>
}
    80004534:	60e2                	ld	ra,24(sp)
    80004536:	6442                	ld	s0,16(sp)
    80004538:	64a2                	ld	s1,8(sp)
    8000453a:	6902                	ld	s2,0(sp)
    8000453c:	6105                	addi	sp,sp,32
    8000453e:	8082                	ret

0000000080004540 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004540:	00023797          	auipc	a5,0x23
    80004544:	55c7a783          	lw	a5,1372(a5) # 80027a9c <log+0x2c>
    80004548:	0af05d63          	blez	a5,80004602 <install_trans+0xc2>
{
    8000454c:	7139                	addi	sp,sp,-64
    8000454e:	fc06                	sd	ra,56(sp)
    80004550:	f822                	sd	s0,48(sp)
    80004552:	f426                	sd	s1,40(sp)
    80004554:	f04a                	sd	s2,32(sp)
    80004556:	ec4e                	sd	s3,24(sp)
    80004558:	e852                	sd	s4,16(sp)
    8000455a:	e456                	sd	s5,8(sp)
    8000455c:	e05a                	sd	s6,0(sp)
    8000455e:	0080                	addi	s0,sp,64
    80004560:	8b2a                	mv	s6,a0
    80004562:	00023a97          	auipc	s5,0x23
    80004566:	53ea8a93          	addi	s5,s5,1342 # 80027aa0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000456a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000456c:	00023997          	auipc	s3,0x23
    80004570:	50498993          	addi	s3,s3,1284 # 80027a70 <log>
    80004574:	a00d                	j	80004596 <install_trans+0x56>
    brelse(lbuf);
    80004576:	854a                	mv	a0,s2
    80004578:	fffff097          	auipc	ra,0xfffff
    8000457c:	088080e7          	jalr	136(ra) # 80003600 <brelse>
    brelse(dbuf);
    80004580:	8526                	mv	a0,s1
    80004582:	fffff097          	auipc	ra,0xfffff
    80004586:	07e080e7          	jalr	126(ra) # 80003600 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000458a:	2a05                	addiw	s4,s4,1
    8000458c:	0a91                	addi	s5,s5,4
    8000458e:	02c9a783          	lw	a5,44(s3)
    80004592:	04fa5e63          	bge	s4,a5,800045ee <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004596:	0189a583          	lw	a1,24(s3)
    8000459a:	014585bb          	addw	a1,a1,s4
    8000459e:	2585                	addiw	a1,a1,1
    800045a0:	0289a503          	lw	a0,40(s3)
    800045a4:	fffff097          	auipc	ra,0xfffff
    800045a8:	f2c080e7          	jalr	-212(ra) # 800034d0 <bread>
    800045ac:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800045ae:	000aa583          	lw	a1,0(s5)
    800045b2:	0289a503          	lw	a0,40(s3)
    800045b6:	fffff097          	auipc	ra,0xfffff
    800045ba:	f1a080e7          	jalr	-230(ra) # 800034d0 <bread>
    800045be:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045c0:	40000613          	li	a2,1024
    800045c4:	05890593          	addi	a1,s2,88
    800045c8:	05850513          	addi	a0,a0,88
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	74e080e7          	jalr	1870(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    800045d4:	8526                	mv	a0,s1
    800045d6:	fffff097          	auipc	ra,0xfffff
    800045da:	fec080e7          	jalr	-20(ra) # 800035c2 <bwrite>
    if(recovering == 0)
    800045de:	f80b1ce3          	bnez	s6,80004576 <install_trans+0x36>
      bunpin(dbuf);
    800045e2:	8526                	mv	a0,s1
    800045e4:	fffff097          	auipc	ra,0xfffff
    800045e8:	0f6080e7          	jalr	246(ra) # 800036da <bunpin>
    800045ec:	b769                	j	80004576 <install_trans+0x36>
}
    800045ee:	70e2                	ld	ra,56(sp)
    800045f0:	7442                	ld	s0,48(sp)
    800045f2:	74a2                	ld	s1,40(sp)
    800045f4:	7902                	ld	s2,32(sp)
    800045f6:	69e2                	ld	s3,24(sp)
    800045f8:	6a42                	ld	s4,16(sp)
    800045fa:	6aa2                	ld	s5,8(sp)
    800045fc:	6b02                	ld	s6,0(sp)
    800045fe:	6121                	addi	sp,sp,64
    80004600:	8082                	ret
    80004602:	8082                	ret

0000000080004604 <initlog>:
{
    80004604:	7179                	addi	sp,sp,-48
    80004606:	f406                	sd	ra,40(sp)
    80004608:	f022                	sd	s0,32(sp)
    8000460a:	ec26                	sd	s1,24(sp)
    8000460c:	e84a                	sd	s2,16(sp)
    8000460e:	e44e                	sd	s3,8(sp)
    80004610:	1800                	addi	s0,sp,48
    80004612:	892a                	mv	s2,a0
    80004614:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004616:	00023497          	auipc	s1,0x23
    8000461a:	45a48493          	addi	s1,s1,1114 # 80027a70 <log>
    8000461e:	00004597          	auipc	a1,0x4
    80004622:	04258593          	addi	a1,a1,66 # 80008660 <syscalls+0x230>
    80004626:	8526                	mv	a0,s1
    80004628:	ffffc097          	auipc	ra,0xffffc
    8000462c:	50a080e7          	jalr	1290(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004630:	0149a583          	lw	a1,20(s3)
    80004634:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004636:	0109a783          	lw	a5,16(s3)
    8000463a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000463c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004640:	854a                	mv	a0,s2
    80004642:	fffff097          	auipc	ra,0xfffff
    80004646:	e8e080e7          	jalr	-370(ra) # 800034d0 <bread>
  log.lh.n = lh->n;
    8000464a:	4d34                	lw	a3,88(a0)
    8000464c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000464e:	02d05663          	blez	a3,8000467a <initlog+0x76>
    80004652:	05c50793          	addi	a5,a0,92
    80004656:	00023717          	auipc	a4,0x23
    8000465a:	44a70713          	addi	a4,a4,1098 # 80027aa0 <log+0x30>
    8000465e:	36fd                	addiw	a3,a3,-1
    80004660:	02069613          	slli	a2,a3,0x20
    80004664:	01e65693          	srli	a3,a2,0x1e
    80004668:	06050613          	addi	a2,a0,96
    8000466c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000466e:	4390                	lw	a2,0(a5)
    80004670:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004672:	0791                	addi	a5,a5,4
    80004674:	0711                	addi	a4,a4,4
    80004676:	fed79ce3          	bne	a5,a3,8000466e <initlog+0x6a>
  brelse(buf);
    8000467a:	fffff097          	auipc	ra,0xfffff
    8000467e:	f86080e7          	jalr	-122(ra) # 80003600 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004682:	4505                	li	a0,1
    80004684:	00000097          	auipc	ra,0x0
    80004688:	ebc080e7          	jalr	-324(ra) # 80004540 <install_trans>
  log.lh.n = 0;
    8000468c:	00023797          	auipc	a5,0x23
    80004690:	4007a823          	sw	zero,1040(a5) # 80027a9c <log+0x2c>
  write_head(); // clear the log
    80004694:	00000097          	auipc	ra,0x0
    80004698:	e30080e7          	jalr	-464(ra) # 800044c4 <write_head>
}
    8000469c:	70a2                	ld	ra,40(sp)
    8000469e:	7402                	ld	s0,32(sp)
    800046a0:	64e2                	ld	s1,24(sp)
    800046a2:	6942                	ld	s2,16(sp)
    800046a4:	69a2                	ld	s3,8(sp)
    800046a6:	6145                	addi	sp,sp,48
    800046a8:	8082                	ret

00000000800046aa <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800046aa:	1101                	addi	sp,sp,-32
    800046ac:	ec06                	sd	ra,24(sp)
    800046ae:	e822                	sd	s0,16(sp)
    800046b0:	e426                	sd	s1,8(sp)
    800046b2:	e04a                	sd	s2,0(sp)
    800046b4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800046b6:	00023517          	auipc	a0,0x23
    800046ba:	3ba50513          	addi	a0,a0,954 # 80027a70 <log>
    800046be:	ffffc097          	auipc	ra,0xffffc
    800046c2:	504080e7          	jalr	1284(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    800046c6:	00023497          	auipc	s1,0x23
    800046ca:	3aa48493          	addi	s1,s1,938 # 80027a70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046ce:	4979                	li	s2,30
    800046d0:	a039                	j	800046de <begin_op+0x34>
      sleep(&log, &log.lock);
    800046d2:	85a6                	mv	a1,s1
    800046d4:	8526                	mv	a0,s1
    800046d6:	ffffe097          	auipc	ra,0xffffe
    800046da:	9f8080e7          	jalr	-1544(ra) # 800020ce <sleep>
    if(log.committing){
    800046de:	50dc                	lw	a5,36(s1)
    800046e0:	fbed                	bnez	a5,800046d2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046e2:	509c                	lw	a5,32(s1)
    800046e4:	0017871b          	addiw	a4,a5,1
    800046e8:	0007069b          	sext.w	a3,a4
    800046ec:	0027179b          	slliw	a5,a4,0x2
    800046f0:	9fb9                	addw	a5,a5,a4
    800046f2:	0017979b          	slliw	a5,a5,0x1
    800046f6:	54d8                	lw	a4,44(s1)
    800046f8:	9fb9                	addw	a5,a5,a4
    800046fa:	00f95963          	bge	s2,a5,8000470c <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800046fe:	85a6                	mv	a1,s1
    80004700:	8526                	mv	a0,s1
    80004702:	ffffe097          	auipc	ra,0xffffe
    80004706:	9cc080e7          	jalr	-1588(ra) # 800020ce <sleep>
    8000470a:	bfd1                	j	800046de <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000470c:	00023517          	auipc	a0,0x23
    80004710:	36450513          	addi	a0,a0,868 # 80027a70 <log>
    80004714:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004716:	ffffc097          	auipc	ra,0xffffc
    8000471a:	560080e7          	jalr	1376(ra) # 80000c76 <release>
      break;
    }
  }
}
    8000471e:	60e2                	ld	ra,24(sp)
    80004720:	6442                	ld	s0,16(sp)
    80004722:	64a2                	ld	s1,8(sp)
    80004724:	6902                	ld	s2,0(sp)
    80004726:	6105                	addi	sp,sp,32
    80004728:	8082                	ret

000000008000472a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000472a:	7139                	addi	sp,sp,-64
    8000472c:	fc06                	sd	ra,56(sp)
    8000472e:	f822                	sd	s0,48(sp)
    80004730:	f426                	sd	s1,40(sp)
    80004732:	f04a                	sd	s2,32(sp)
    80004734:	ec4e                	sd	s3,24(sp)
    80004736:	e852                	sd	s4,16(sp)
    80004738:	e456                	sd	s5,8(sp)
    8000473a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000473c:	00023497          	auipc	s1,0x23
    80004740:	33448493          	addi	s1,s1,820 # 80027a70 <log>
    80004744:	8526                	mv	a0,s1
    80004746:	ffffc097          	auipc	ra,0xffffc
    8000474a:	47c080e7          	jalr	1148(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    8000474e:	509c                	lw	a5,32(s1)
    80004750:	37fd                	addiw	a5,a5,-1
    80004752:	0007891b          	sext.w	s2,a5
    80004756:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004758:	50dc                	lw	a5,36(s1)
    8000475a:	e7b9                	bnez	a5,800047a8 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000475c:	04091e63          	bnez	s2,800047b8 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004760:	00023497          	auipc	s1,0x23
    80004764:	31048493          	addi	s1,s1,784 # 80027a70 <log>
    80004768:	4785                	li	a5,1
    8000476a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000476c:	8526                	mv	a0,s1
    8000476e:	ffffc097          	auipc	ra,0xffffc
    80004772:	508080e7          	jalr	1288(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004776:	54dc                	lw	a5,44(s1)
    80004778:	06f04763          	bgtz	a5,800047e6 <end_op+0xbc>
    acquire(&log.lock);
    8000477c:	00023497          	auipc	s1,0x23
    80004780:	2f448493          	addi	s1,s1,756 # 80027a70 <log>
    80004784:	8526                	mv	a0,s1
    80004786:	ffffc097          	auipc	ra,0xffffc
    8000478a:	43c080e7          	jalr	1084(ra) # 80000bc2 <acquire>
    log.committing = 0;
    8000478e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004792:	8526                	mv	a0,s1
    80004794:	ffffe097          	auipc	ra,0xffffe
    80004798:	ac6080e7          	jalr	-1338(ra) # 8000225a <wakeup>
    release(&log.lock);
    8000479c:	8526                	mv	a0,s1
    8000479e:	ffffc097          	auipc	ra,0xffffc
    800047a2:	4d8080e7          	jalr	1240(ra) # 80000c76 <release>
}
    800047a6:	a03d                	j	800047d4 <end_op+0xaa>
    panic("log.committing");
    800047a8:	00004517          	auipc	a0,0x4
    800047ac:	ec050513          	addi	a0,a0,-320 # 80008668 <syscalls+0x238>
    800047b0:	ffffc097          	auipc	ra,0xffffc
    800047b4:	d7a080e7          	jalr	-646(ra) # 8000052a <panic>
    wakeup(&log);
    800047b8:	00023497          	auipc	s1,0x23
    800047bc:	2b848493          	addi	s1,s1,696 # 80027a70 <log>
    800047c0:	8526                	mv	a0,s1
    800047c2:	ffffe097          	auipc	ra,0xffffe
    800047c6:	a98080e7          	jalr	-1384(ra) # 8000225a <wakeup>
  release(&log.lock);
    800047ca:	8526                	mv	a0,s1
    800047cc:	ffffc097          	auipc	ra,0xffffc
    800047d0:	4aa080e7          	jalr	1194(ra) # 80000c76 <release>
}
    800047d4:	70e2                	ld	ra,56(sp)
    800047d6:	7442                	ld	s0,48(sp)
    800047d8:	74a2                	ld	s1,40(sp)
    800047da:	7902                	ld	s2,32(sp)
    800047dc:	69e2                	ld	s3,24(sp)
    800047de:	6a42                	ld	s4,16(sp)
    800047e0:	6aa2                	ld	s5,8(sp)
    800047e2:	6121                	addi	sp,sp,64
    800047e4:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800047e6:	00023a97          	auipc	s5,0x23
    800047ea:	2baa8a93          	addi	s5,s5,698 # 80027aa0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800047ee:	00023a17          	auipc	s4,0x23
    800047f2:	282a0a13          	addi	s4,s4,642 # 80027a70 <log>
    800047f6:	018a2583          	lw	a1,24(s4)
    800047fa:	012585bb          	addw	a1,a1,s2
    800047fe:	2585                	addiw	a1,a1,1
    80004800:	028a2503          	lw	a0,40(s4)
    80004804:	fffff097          	auipc	ra,0xfffff
    80004808:	ccc080e7          	jalr	-820(ra) # 800034d0 <bread>
    8000480c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000480e:	000aa583          	lw	a1,0(s5)
    80004812:	028a2503          	lw	a0,40(s4)
    80004816:	fffff097          	auipc	ra,0xfffff
    8000481a:	cba080e7          	jalr	-838(ra) # 800034d0 <bread>
    8000481e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004820:	40000613          	li	a2,1024
    80004824:	05850593          	addi	a1,a0,88
    80004828:	05848513          	addi	a0,s1,88
    8000482c:	ffffc097          	auipc	ra,0xffffc
    80004830:	4ee080e7          	jalr	1262(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004834:	8526                	mv	a0,s1
    80004836:	fffff097          	auipc	ra,0xfffff
    8000483a:	d8c080e7          	jalr	-628(ra) # 800035c2 <bwrite>
    brelse(from);
    8000483e:	854e                	mv	a0,s3
    80004840:	fffff097          	auipc	ra,0xfffff
    80004844:	dc0080e7          	jalr	-576(ra) # 80003600 <brelse>
    brelse(to);
    80004848:	8526                	mv	a0,s1
    8000484a:	fffff097          	auipc	ra,0xfffff
    8000484e:	db6080e7          	jalr	-586(ra) # 80003600 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004852:	2905                	addiw	s2,s2,1
    80004854:	0a91                	addi	s5,s5,4
    80004856:	02ca2783          	lw	a5,44(s4)
    8000485a:	f8f94ee3          	blt	s2,a5,800047f6 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000485e:	00000097          	auipc	ra,0x0
    80004862:	c66080e7          	jalr	-922(ra) # 800044c4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004866:	4501                	li	a0,0
    80004868:	00000097          	auipc	ra,0x0
    8000486c:	cd8080e7          	jalr	-808(ra) # 80004540 <install_trans>
    log.lh.n = 0;
    80004870:	00023797          	auipc	a5,0x23
    80004874:	2207a623          	sw	zero,556(a5) # 80027a9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004878:	00000097          	auipc	ra,0x0
    8000487c:	c4c080e7          	jalr	-948(ra) # 800044c4 <write_head>
    80004880:	bdf5                	j	8000477c <end_op+0x52>

0000000080004882 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004882:	1101                	addi	sp,sp,-32
    80004884:	ec06                	sd	ra,24(sp)
    80004886:	e822                	sd	s0,16(sp)
    80004888:	e426                	sd	s1,8(sp)
    8000488a:	e04a                	sd	s2,0(sp)
    8000488c:	1000                	addi	s0,sp,32
    8000488e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004890:	00023917          	auipc	s2,0x23
    80004894:	1e090913          	addi	s2,s2,480 # 80027a70 <log>
    80004898:	854a                	mv	a0,s2
    8000489a:	ffffc097          	auipc	ra,0xffffc
    8000489e:	328080e7          	jalr	808(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800048a2:	02c92603          	lw	a2,44(s2)
    800048a6:	47f5                	li	a5,29
    800048a8:	06c7c563          	blt	a5,a2,80004912 <log_write+0x90>
    800048ac:	00023797          	auipc	a5,0x23
    800048b0:	1e07a783          	lw	a5,480(a5) # 80027a8c <log+0x1c>
    800048b4:	37fd                	addiw	a5,a5,-1
    800048b6:	04f65e63          	bge	a2,a5,80004912 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800048ba:	00023797          	auipc	a5,0x23
    800048be:	1d67a783          	lw	a5,470(a5) # 80027a90 <log+0x20>
    800048c2:	06f05063          	blez	a5,80004922 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800048c6:	4781                	li	a5,0
    800048c8:	06c05563          	blez	a2,80004932 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800048cc:	44cc                	lw	a1,12(s1)
    800048ce:	00023717          	auipc	a4,0x23
    800048d2:	1d270713          	addi	a4,a4,466 # 80027aa0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800048d6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800048d8:	4314                	lw	a3,0(a4)
    800048da:	04b68c63          	beq	a3,a1,80004932 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800048de:	2785                	addiw	a5,a5,1
    800048e0:	0711                	addi	a4,a4,4
    800048e2:	fef61be3          	bne	a2,a5,800048d8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800048e6:	0621                	addi	a2,a2,8
    800048e8:	060a                	slli	a2,a2,0x2
    800048ea:	00023797          	auipc	a5,0x23
    800048ee:	18678793          	addi	a5,a5,390 # 80027a70 <log>
    800048f2:	963e                	add	a2,a2,a5
    800048f4:	44dc                	lw	a5,12(s1)
    800048f6:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800048f8:	8526                	mv	a0,s1
    800048fa:	fffff097          	auipc	ra,0xfffff
    800048fe:	da4080e7          	jalr	-604(ra) # 8000369e <bpin>
    log.lh.n++;
    80004902:	00023717          	auipc	a4,0x23
    80004906:	16e70713          	addi	a4,a4,366 # 80027a70 <log>
    8000490a:	575c                	lw	a5,44(a4)
    8000490c:	2785                	addiw	a5,a5,1
    8000490e:	d75c                	sw	a5,44(a4)
    80004910:	a835                	j	8000494c <log_write+0xca>
    panic("too big a transaction");
    80004912:	00004517          	auipc	a0,0x4
    80004916:	d6650513          	addi	a0,a0,-666 # 80008678 <syscalls+0x248>
    8000491a:	ffffc097          	auipc	ra,0xffffc
    8000491e:	c10080e7          	jalr	-1008(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004922:	00004517          	auipc	a0,0x4
    80004926:	d6e50513          	addi	a0,a0,-658 # 80008690 <syscalls+0x260>
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	c00080e7          	jalr	-1024(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004932:	00878713          	addi	a4,a5,8
    80004936:	00271693          	slli	a3,a4,0x2
    8000493a:	00023717          	auipc	a4,0x23
    8000493e:	13670713          	addi	a4,a4,310 # 80027a70 <log>
    80004942:	9736                	add	a4,a4,a3
    80004944:	44d4                	lw	a3,12(s1)
    80004946:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004948:	faf608e3          	beq	a2,a5,800048f8 <log_write+0x76>
  }
  release(&log.lock);
    8000494c:	00023517          	auipc	a0,0x23
    80004950:	12450513          	addi	a0,a0,292 # 80027a70 <log>
    80004954:	ffffc097          	auipc	ra,0xffffc
    80004958:	322080e7          	jalr	802(ra) # 80000c76 <release>
}
    8000495c:	60e2                	ld	ra,24(sp)
    8000495e:	6442                	ld	s0,16(sp)
    80004960:	64a2                	ld	s1,8(sp)
    80004962:	6902                	ld	s2,0(sp)
    80004964:	6105                	addi	sp,sp,32
    80004966:	8082                	ret

0000000080004968 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004968:	1101                	addi	sp,sp,-32
    8000496a:	ec06                	sd	ra,24(sp)
    8000496c:	e822                	sd	s0,16(sp)
    8000496e:	e426                	sd	s1,8(sp)
    80004970:	e04a                	sd	s2,0(sp)
    80004972:	1000                	addi	s0,sp,32
    80004974:	84aa                	mv	s1,a0
    80004976:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004978:	00004597          	auipc	a1,0x4
    8000497c:	d3858593          	addi	a1,a1,-712 # 800086b0 <syscalls+0x280>
    80004980:	0521                	addi	a0,a0,8
    80004982:	ffffc097          	auipc	ra,0xffffc
    80004986:	1b0080e7          	jalr	432(ra) # 80000b32 <initlock>
  lk->name = name;
    8000498a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000498e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004992:	0204a423          	sw	zero,40(s1)
}
    80004996:	60e2                	ld	ra,24(sp)
    80004998:	6442                	ld	s0,16(sp)
    8000499a:	64a2                	ld	s1,8(sp)
    8000499c:	6902                	ld	s2,0(sp)
    8000499e:	6105                	addi	sp,sp,32
    800049a0:	8082                	ret

00000000800049a2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800049a2:	1101                	addi	sp,sp,-32
    800049a4:	ec06                	sd	ra,24(sp)
    800049a6:	e822                	sd	s0,16(sp)
    800049a8:	e426                	sd	s1,8(sp)
    800049aa:	e04a                	sd	s2,0(sp)
    800049ac:	1000                	addi	s0,sp,32
    800049ae:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049b0:	00850913          	addi	s2,a0,8
    800049b4:	854a                	mv	a0,s2
    800049b6:	ffffc097          	auipc	ra,0xffffc
    800049ba:	20c080e7          	jalr	524(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    800049be:	409c                	lw	a5,0(s1)
    800049c0:	cb89                	beqz	a5,800049d2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800049c2:	85ca                	mv	a1,s2
    800049c4:	8526                	mv	a0,s1
    800049c6:	ffffd097          	auipc	ra,0xffffd
    800049ca:	708080e7          	jalr	1800(ra) # 800020ce <sleep>
  while (lk->locked) {
    800049ce:	409c                	lw	a5,0(s1)
    800049d0:	fbed                	bnez	a5,800049c2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800049d2:	4785                	li	a5,1
    800049d4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800049d6:	ffffd097          	auipc	ra,0xffffd
    800049da:	fa8080e7          	jalr	-88(ra) # 8000197e <myproc>
    800049de:	591c                	lw	a5,48(a0)
    800049e0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800049e2:	854a                	mv	a0,s2
    800049e4:	ffffc097          	auipc	ra,0xffffc
    800049e8:	292080e7          	jalr	658(ra) # 80000c76 <release>
}
    800049ec:	60e2                	ld	ra,24(sp)
    800049ee:	6442                	ld	s0,16(sp)
    800049f0:	64a2                	ld	s1,8(sp)
    800049f2:	6902                	ld	s2,0(sp)
    800049f4:	6105                	addi	sp,sp,32
    800049f6:	8082                	ret

00000000800049f8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800049f8:	1101                	addi	sp,sp,-32
    800049fa:	ec06                	sd	ra,24(sp)
    800049fc:	e822                	sd	s0,16(sp)
    800049fe:	e426                	sd	s1,8(sp)
    80004a00:	e04a                	sd	s2,0(sp)
    80004a02:	1000                	addi	s0,sp,32
    80004a04:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a06:	00850913          	addi	s2,a0,8
    80004a0a:	854a                	mv	a0,s2
    80004a0c:	ffffc097          	auipc	ra,0xffffc
    80004a10:	1b6080e7          	jalr	438(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80004a14:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a18:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a1c:	8526                	mv	a0,s1
    80004a1e:	ffffe097          	auipc	ra,0xffffe
    80004a22:	83c080e7          	jalr	-1988(ra) # 8000225a <wakeup>
  release(&lk->lk);
    80004a26:	854a                	mv	a0,s2
    80004a28:	ffffc097          	auipc	ra,0xffffc
    80004a2c:	24e080e7          	jalr	590(ra) # 80000c76 <release>
}
    80004a30:	60e2                	ld	ra,24(sp)
    80004a32:	6442                	ld	s0,16(sp)
    80004a34:	64a2                	ld	s1,8(sp)
    80004a36:	6902                	ld	s2,0(sp)
    80004a38:	6105                	addi	sp,sp,32
    80004a3a:	8082                	ret

0000000080004a3c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a3c:	7179                	addi	sp,sp,-48
    80004a3e:	f406                	sd	ra,40(sp)
    80004a40:	f022                	sd	s0,32(sp)
    80004a42:	ec26                	sd	s1,24(sp)
    80004a44:	e84a                	sd	s2,16(sp)
    80004a46:	e44e                	sd	s3,8(sp)
    80004a48:	1800                	addi	s0,sp,48
    80004a4a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a4c:	00850913          	addi	s2,a0,8
    80004a50:	854a                	mv	a0,s2
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	170080e7          	jalr	368(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a5a:	409c                	lw	a5,0(s1)
    80004a5c:	ef99                	bnez	a5,80004a7a <holdingsleep+0x3e>
    80004a5e:	4481                	li	s1,0
  release(&lk->lk);
    80004a60:	854a                	mv	a0,s2
    80004a62:	ffffc097          	auipc	ra,0xffffc
    80004a66:	214080e7          	jalr	532(ra) # 80000c76 <release>
  return r;
}
    80004a6a:	8526                	mv	a0,s1
    80004a6c:	70a2                	ld	ra,40(sp)
    80004a6e:	7402                	ld	s0,32(sp)
    80004a70:	64e2                	ld	s1,24(sp)
    80004a72:	6942                	ld	s2,16(sp)
    80004a74:	69a2                	ld	s3,8(sp)
    80004a76:	6145                	addi	sp,sp,48
    80004a78:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a7a:	0284a983          	lw	s3,40(s1)
    80004a7e:	ffffd097          	auipc	ra,0xffffd
    80004a82:	f00080e7          	jalr	-256(ra) # 8000197e <myproc>
    80004a86:	5904                	lw	s1,48(a0)
    80004a88:	413484b3          	sub	s1,s1,s3
    80004a8c:	0014b493          	seqz	s1,s1
    80004a90:	bfc1                	j	80004a60 <holdingsleep+0x24>

0000000080004a92 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a92:	1141                	addi	sp,sp,-16
    80004a94:	e406                	sd	ra,8(sp)
    80004a96:	e022                	sd	s0,0(sp)
    80004a98:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a9a:	00004597          	auipc	a1,0x4
    80004a9e:	c2658593          	addi	a1,a1,-986 # 800086c0 <syscalls+0x290>
    80004aa2:	00023517          	auipc	a0,0x23
    80004aa6:	11650513          	addi	a0,a0,278 # 80027bb8 <ftable>
    80004aaa:	ffffc097          	auipc	ra,0xffffc
    80004aae:	088080e7          	jalr	136(ra) # 80000b32 <initlock>
}
    80004ab2:	60a2                	ld	ra,8(sp)
    80004ab4:	6402                	ld	s0,0(sp)
    80004ab6:	0141                	addi	sp,sp,16
    80004ab8:	8082                	ret

0000000080004aba <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004aba:	1101                	addi	sp,sp,-32
    80004abc:	ec06                	sd	ra,24(sp)
    80004abe:	e822                	sd	s0,16(sp)
    80004ac0:	e426                	sd	s1,8(sp)
    80004ac2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004ac4:	00023517          	auipc	a0,0x23
    80004ac8:	0f450513          	addi	a0,a0,244 # 80027bb8 <ftable>
    80004acc:	ffffc097          	auipc	ra,0xffffc
    80004ad0:	0f6080e7          	jalr	246(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ad4:	00023497          	auipc	s1,0x23
    80004ad8:	0fc48493          	addi	s1,s1,252 # 80027bd0 <ftable+0x18>
    80004adc:	00024717          	auipc	a4,0x24
    80004ae0:	09470713          	addi	a4,a4,148 # 80028b70 <ftable+0xfb8>
    if(f->ref == 0){
    80004ae4:	40dc                	lw	a5,4(s1)
    80004ae6:	cf99                	beqz	a5,80004b04 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ae8:	02848493          	addi	s1,s1,40
    80004aec:	fee49ce3          	bne	s1,a4,80004ae4 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004af0:	00023517          	auipc	a0,0x23
    80004af4:	0c850513          	addi	a0,a0,200 # 80027bb8 <ftable>
    80004af8:	ffffc097          	auipc	ra,0xffffc
    80004afc:	17e080e7          	jalr	382(ra) # 80000c76 <release>
  return 0;
    80004b00:	4481                	li	s1,0
    80004b02:	a819                	j	80004b18 <filealloc+0x5e>
      f->ref = 1;
    80004b04:	4785                	li	a5,1
    80004b06:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b08:	00023517          	auipc	a0,0x23
    80004b0c:	0b050513          	addi	a0,a0,176 # 80027bb8 <ftable>
    80004b10:	ffffc097          	auipc	ra,0xffffc
    80004b14:	166080e7          	jalr	358(ra) # 80000c76 <release>
}
    80004b18:	8526                	mv	a0,s1
    80004b1a:	60e2                	ld	ra,24(sp)
    80004b1c:	6442                	ld	s0,16(sp)
    80004b1e:	64a2                	ld	s1,8(sp)
    80004b20:	6105                	addi	sp,sp,32
    80004b22:	8082                	ret

0000000080004b24 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b24:	1101                	addi	sp,sp,-32
    80004b26:	ec06                	sd	ra,24(sp)
    80004b28:	e822                	sd	s0,16(sp)
    80004b2a:	e426                	sd	s1,8(sp)
    80004b2c:	1000                	addi	s0,sp,32
    80004b2e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b30:	00023517          	auipc	a0,0x23
    80004b34:	08850513          	addi	a0,a0,136 # 80027bb8 <ftable>
    80004b38:	ffffc097          	auipc	ra,0xffffc
    80004b3c:	08a080e7          	jalr	138(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004b40:	40dc                	lw	a5,4(s1)
    80004b42:	02f05263          	blez	a5,80004b66 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b46:	2785                	addiw	a5,a5,1
    80004b48:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b4a:	00023517          	auipc	a0,0x23
    80004b4e:	06e50513          	addi	a0,a0,110 # 80027bb8 <ftable>
    80004b52:	ffffc097          	auipc	ra,0xffffc
    80004b56:	124080e7          	jalr	292(ra) # 80000c76 <release>
  return f;
}
    80004b5a:	8526                	mv	a0,s1
    80004b5c:	60e2                	ld	ra,24(sp)
    80004b5e:	6442                	ld	s0,16(sp)
    80004b60:	64a2                	ld	s1,8(sp)
    80004b62:	6105                	addi	sp,sp,32
    80004b64:	8082                	ret
    panic("filedup");
    80004b66:	00004517          	auipc	a0,0x4
    80004b6a:	b6250513          	addi	a0,a0,-1182 # 800086c8 <syscalls+0x298>
    80004b6e:	ffffc097          	auipc	ra,0xffffc
    80004b72:	9bc080e7          	jalr	-1604(ra) # 8000052a <panic>

0000000080004b76 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b76:	7139                	addi	sp,sp,-64
    80004b78:	fc06                	sd	ra,56(sp)
    80004b7a:	f822                	sd	s0,48(sp)
    80004b7c:	f426                	sd	s1,40(sp)
    80004b7e:	f04a                	sd	s2,32(sp)
    80004b80:	ec4e                	sd	s3,24(sp)
    80004b82:	e852                	sd	s4,16(sp)
    80004b84:	e456                	sd	s5,8(sp)
    80004b86:	0080                	addi	s0,sp,64
    80004b88:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b8a:	00023517          	auipc	a0,0x23
    80004b8e:	02e50513          	addi	a0,a0,46 # 80027bb8 <ftable>
    80004b92:	ffffc097          	auipc	ra,0xffffc
    80004b96:	030080e7          	jalr	48(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004b9a:	40dc                	lw	a5,4(s1)
    80004b9c:	06f05163          	blez	a5,80004bfe <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004ba0:	37fd                	addiw	a5,a5,-1
    80004ba2:	0007871b          	sext.w	a4,a5
    80004ba6:	c0dc                	sw	a5,4(s1)
    80004ba8:	06e04363          	bgtz	a4,80004c0e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004bac:	0004a903          	lw	s2,0(s1)
    80004bb0:	0094ca83          	lbu	s5,9(s1)
    80004bb4:	0104ba03          	ld	s4,16(s1)
    80004bb8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004bbc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004bc0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004bc4:	00023517          	auipc	a0,0x23
    80004bc8:	ff450513          	addi	a0,a0,-12 # 80027bb8 <ftable>
    80004bcc:	ffffc097          	auipc	ra,0xffffc
    80004bd0:	0aa080e7          	jalr	170(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80004bd4:	4785                	li	a5,1
    80004bd6:	04f90d63          	beq	s2,a5,80004c30 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004bda:	3979                	addiw	s2,s2,-2
    80004bdc:	4785                	li	a5,1
    80004bde:	0527e063          	bltu	a5,s2,80004c1e <fileclose+0xa8>
    begin_op();
    80004be2:	00000097          	auipc	ra,0x0
    80004be6:	ac8080e7          	jalr	-1336(ra) # 800046aa <begin_op>
    iput(ff.ip);
    80004bea:	854e                	mv	a0,s3
    80004bec:	fffff097          	auipc	ra,0xfffff
    80004bf0:	2a2080e7          	jalr	674(ra) # 80003e8e <iput>
    end_op();
    80004bf4:	00000097          	auipc	ra,0x0
    80004bf8:	b36080e7          	jalr	-1226(ra) # 8000472a <end_op>
    80004bfc:	a00d                	j	80004c1e <fileclose+0xa8>
    panic("fileclose");
    80004bfe:	00004517          	auipc	a0,0x4
    80004c02:	ad250513          	addi	a0,a0,-1326 # 800086d0 <syscalls+0x2a0>
    80004c06:	ffffc097          	auipc	ra,0xffffc
    80004c0a:	924080e7          	jalr	-1756(ra) # 8000052a <panic>
    release(&ftable.lock);
    80004c0e:	00023517          	auipc	a0,0x23
    80004c12:	faa50513          	addi	a0,a0,-86 # 80027bb8 <ftable>
    80004c16:	ffffc097          	auipc	ra,0xffffc
    80004c1a:	060080e7          	jalr	96(ra) # 80000c76 <release>
  }
}
    80004c1e:	70e2                	ld	ra,56(sp)
    80004c20:	7442                	ld	s0,48(sp)
    80004c22:	74a2                	ld	s1,40(sp)
    80004c24:	7902                	ld	s2,32(sp)
    80004c26:	69e2                	ld	s3,24(sp)
    80004c28:	6a42                	ld	s4,16(sp)
    80004c2a:	6aa2                	ld	s5,8(sp)
    80004c2c:	6121                	addi	sp,sp,64
    80004c2e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c30:	85d6                	mv	a1,s5
    80004c32:	8552                	mv	a0,s4
    80004c34:	00000097          	auipc	ra,0x0
    80004c38:	34c080e7          	jalr	844(ra) # 80004f80 <pipeclose>
    80004c3c:	b7cd                	j	80004c1e <fileclose+0xa8>

0000000080004c3e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c3e:	715d                	addi	sp,sp,-80
    80004c40:	e486                	sd	ra,72(sp)
    80004c42:	e0a2                	sd	s0,64(sp)
    80004c44:	fc26                	sd	s1,56(sp)
    80004c46:	f84a                	sd	s2,48(sp)
    80004c48:	f44e                	sd	s3,40(sp)
    80004c4a:	0880                	addi	s0,sp,80
    80004c4c:	84aa                	mv	s1,a0
    80004c4e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c50:	ffffd097          	auipc	ra,0xffffd
    80004c54:	d2e080e7          	jalr	-722(ra) # 8000197e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c58:	409c                	lw	a5,0(s1)
    80004c5a:	37f9                	addiw	a5,a5,-2
    80004c5c:	4705                	li	a4,1
    80004c5e:	04f76763          	bltu	a4,a5,80004cac <filestat+0x6e>
    80004c62:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c64:	6c88                	ld	a0,24(s1)
    80004c66:	fffff097          	auipc	ra,0xfffff
    80004c6a:	06e080e7          	jalr	110(ra) # 80003cd4 <ilock>
    stati(f->ip, &st);
    80004c6e:	fb840593          	addi	a1,s0,-72
    80004c72:	6c88                	ld	a0,24(s1)
    80004c74:	fffff097          	auipc	ra,0xfffff
    80004c78:	2ea080e7          	jalr	746(ra) # 80003f5e <stati>
    iunlock(f->ip);
    80004c7c:	6c88                	ld	a0,24(s1)
    80004c7e:	fffff097          	auipc	ra,0xfffff
    80004c82:	118080e7          	jalr	280(ra) # 80003d96 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c86:	46e1                	li	a3,24
    80004c88:	fb840613          	addi	a2,s0,-72
    80004c8c:	85ce                	mv	a1,s3
    80004c8e:	05093503          	ld	a0,80(s2)
    80004c92:	ffffd097          	auipc	ra,0xffffd
    80004c96:	9ac080e7          	jalr	-1620(ra) # 8000163e <copyout>
    80004c9a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004c9e:	60a6                	ld	ra,72(sp)
    80004ca0:	6406                	ld	s0,64(sp)
    80004ca2:	74e2                	ld	s1,56(sp)
    80004ca4:	7942                	ld	s2,48(sp)
    80004ca6:	79a2                	ld	s3,40(sp)
    80004ca8:	6161                	addi	sp,sp,80
    80004caa:	8082                	ret
  return -1;
    80004cac:	557d                	li	a0,-1
    80004cae:	bfc5                	j	80004c9e <filestat+0x60>

0000000080004cb0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004cb0:	7179                	addi	sp,sp,-48
    80004cb2:	f406                	sd	ra,40(sp)
    80004cb4:	f022                	sd	s0,32(sp)
    80004cb6:	ec26                	sd	s1,24(sp)
    80004cb8:	e84a                	sd	s2,16(sp)
    80004cba:	e44e                	sd	s3,8(sp)
    80004cbc:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004cbe:	00854783          	lbu	a5,8(a0)
    80004cc2:	c3d5                	beqz	a5,80004d66 <fileread+0xb6>
    80004cc4:	84aa                	mv	s1,a0
    80004cc6:	89ae                	mv	s3,a1
    80004cc8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cca:	411c                	lw	a5,0(a0)
    80004ccc:	4705                	li	a4,1
    80004cce:	04e78963          	beq	a5,a4,80004d20 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cd2:	470d                	li	a4,3
    80004cd4:	04e78d63          	beq	a5,a4,80004d2e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cd8:	4709                	li	a4,2
    80004cda:	06e79e63          	bne	a5,a4,80004d56 <fileread+0xa6>
    ilock(f->ip);
    80004cde:	6d08                	ld	a0,24(a0)
    80004ce0:	fffff097          	auipc	ra,0xfffff
    80004ce4:	ff4080e7          	jalr	-12(ra) # 80003cd4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ce8:	874a                	mv	a4,s2
    80004cea:	5094                	lw	a3,32(s1)
    80004cec:	864e                	mv	a2,s3
    80004cee:	4585                	li	a1,1
    80004cf0:	6c88                	ld	a0,24(s1)
    80004cf2:	fffff097          	auipc	ra,0xfffff
    80004cf6:	296080e7          	jalr	662(ra) # 80003f88 <readi>
    80004cfa:	892a                	mv	s2,a0
    80004cfc:	00a05563          	blez	a0,80004d06 <fileread+0x56>
      f->off += r;
    80004d00:	509c                	lw	a5,32(s1)
    80004d02:	9fa9                	addw	a5,a5,a0
    80004d04:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d06:	6c88                	ld	a0,24(s1)
    80004d08:	fffff097          	auipc	ra,0xfffff
    80004d0c:	08e080e7          	jalr	142(ra) # 80003d96 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004d10:	854a                	mv	a0,s2
    80004d12:	70a2                	ld	ra,40(sp)
    80004d14:	7402                	ld	s0,32(sp)
    80004d16:	64e2                	ld	s1,24(sp)
    80004d18:	6942                	ld	s2,16(sp)
    80004d1a:	69a2                	ld	s3,8(sp)
    80004d1c:	6145                	addi	sp,sp,48
    80004d1e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d20:	6908                	ld	a0,16(a0)
    80004d22:	00000097          	auipc	ra,0x0
    80004d26:	3c0080e7          	jalr	960(ra) # 800050e2 <piperead>
    80004d2a:	892a                	mv	s2,a0
    80004d2c:	b7d5                	j	80004d10 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d2e:	02451783          	lh	a5,36(a0)
    80004d32:	03079693          	slli	a3,a5,0x30
    80004d36:	92c1                	srli	a3,a3,0x30
    80004d38:	4725                	li	a4,9
    80004d3a:	02d76863          	bltu	a4,a3,80004d6a <fileread+0xba>
    80004d3e:	0792                	slli	a5,a5,0x4
    80004d40:	00023717          	auipc	a4,0x23
    80004d44:	dd870713          	addi	a4,a4,-552 # 80027b18 <devsw>
    80004d48:	97ba                	add	a5,a5,a4
    80004d4a:	639c                	ld	a5,0(a5)
    80004d4c:	c38d                	beqz	a5,80004d6e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004d4e:	4505                	li	a0,1
    80004d50:	9782                	jalr	a5
    80004d52:	892a                	mv	s2,a0
    80004d54:	bf75                	j	80004d10 <fileread+0x60>
    panic("fileread");
    80004d56:	00004517          	auipc	a0,0x4
    80004d5a:	98a50513          	addi	a0,a0,-1654 # 800086e0 <syscalls+0x2b0>
    80004d5e:	ffffb097          	auipc	ra,0xffffb
    80004d62:	7cc080e7          	jalr	1996(ra) # 8000052a <panic>
    return -1;
    80004d66:	597d                	li	s2,-1
    80004d68:	b765                	j	80004d10 <fileread+0x60>
      return -1;
    80004d6a:	597d                	li	s2,-1
    80004d6c:	b755                	j	80004d10 <fileread+0x60>
    80004d6e:	597d                	li	s2,-1
    80004d70:	b745                	j	80004d10 <fileread+0x60>

0000000080004d72 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d72:	715d                	addi	sp,sp,-80
    80004d74:	e486                	sd	ra,72(sp)
    80004d76:	e0a2                	sd	s0,64(sp)
    80004d78:	fc26                	sd	s1,56(sp)
    80004d7a:	f84a                	sd	s2,48(sp)
    80004d7c:	f44e                	sd	s3,40(sp)
    80004d7e:	f052                	sd	s4,32(sp)
    80004d80:	ec56                	sd	s5,24(sp)
    80004d82:	e85a                	sd	s6,16(sp)
    80004d84:	e45e                	sd	s7,8(sp)
    80004d86:	e062                	sd	s8,0(sp)
    80004d88:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004d8a:	00954783          	lbu	a5,9(a0)
    80004d8e:	10078663          	beqz	a5,80004e9a <filewrite+0x128>
    80004d92:	892a                	mv	s2,a0
    80004d94:	8aae                	mv	s5,a1
    80004d96:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d98:	411c                	lw	a5,0(a0)
    80004d9a:	4705                	li	a4,1
    80004d9c:	02e78263          	beq	a5,a4,80004dc0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004da0:	470d                	li	a4,3
    80004da2:	02e78663          	beq	a5,a4,80004dce <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004da6:	4709                	li	a4,2
    80004da8:	0ee79163          	bne	a5,a4,80004e8a <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004dac:	0ac05d63          	blez	a2,80004e66 <filewrite+0xf4>
    int i = 0;
    80004db0:	4981                	li	s3,0
    80004db2:	6b05                	lui	s6,0x1
    80004db4:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004db8:	6b85                	lui	s7,0x1
    80004dba:	c00b8b9b          	addiw	s7,s7,-1024
    80004dbe:	a861                	j	80004e56 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004dc0:	6908                	ld	a0,16(a0)
    80004dc2:	00000097          	auipc	ra,0x0
    80004dc6:	22e080e7          	jalr	558(ra) # 80004ff0 <pipewrite>
    80004dca:	8a2a                	mv	s4,a0
    80004dcc:	a045                	j	80004e6c <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004dce:	02451783          	lh	a5,36(a0)
    80004dd2:	03079693          	slli	a3,a5,0x30
    80004dd6:	92c1                	srli	a3,a3,0x30
    80004dd8:	4725                	li	a4,9
    80004dda:	0cd76263          	bltu	a4,a3,80004e9e <filewrite+0x12c>
    80004dde:	0792                	slli	a5,a5,0x4
    80004de0:	00023717          	auipc	a4,0x23
    80004de4:	d3870713          	addi	a4,a4,-712 # 80027b18 <devsw>
    80004de8:	97ba                	add	a5,a5,a4
    80004dea:	679c                	ld	a5,8(a5)
    80004dec:	cbdd                	beqz	a5,80004ea2 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004dee:	4505                	li	a0,1
    80004df0:	9782                	jalr	a5
    80004df2:	8a2a                	mv	s4,a0
    80004df4:	a8a5                	j	80004e6c <filewrite+0xfa>
    80004df6:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004dfa:	00000097          	auipc	ra,0x0
    80004dfe:	8b0080e7          	jalr	-1872(ra) # 800046aa <begin_op>
      ilock(f->ip);
    80004e02:	01893503          	ld	a0,24(s2)
    80004e06:	fffff097          	auipc	ra,0xfffff
    80004e0a:	ece080e7          	jalr	-306(ra) # 80003cd4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e0e:	8762                	mv	a4,s8
    80004e10:	02092683          	lw	a3,32(s2)
    80004e14:	01598633          	add	a2,s3,s5
    80004e18:	4585                	li	a1,1
    80004e1a:	01893503          	ld	a0,24(s2)
    80004e1e:	fffff097          	auipc	ra,0xfffff
    80004e22:	262080e7          	jalr	610(ra) # 80004080 <writei>
    80004e26:	84aa                	mv	s1,a0
    80004e28:	00a05763          	blez	a0,80004e36 <filewrite+0xc4>
        f->off += r;
    80004e2c:	02092783          	lw	a5,32(s2)
    80004e30:	9fa9                	addw	a5,a5,a0
    80004e32:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e36:	01893503          	ld	a0,24(s2)
    80004e3a:	fffff097          	auipc	ra,0xfffff
    80004e3e:	f5c080e7          	jalr	-164(ra) # 80003d96 <iunlock>
      end_op();
    80004e42:	00000097          	auipc	ra,0x0
    80004e46:	8e8080e7          	jalr	-1816(ra) # 8000472a <end_op>

      if(r != n1){
    80004e4a:	009c1f63          	bne	s8,s1,80004e68 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004e4e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e52:	0149db63          	bge	s3,s4,80004e68 <filewrite+0xf6>
      int n1 = n - i;
    80004e56:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004e5a:	84be                	mv	s1,a5
    80004e5c:	2781                	sext.w	a5,a5
    80004e5e:	f8fb5ce3          	bge	s6,a5,80004df6 <filewrite+0x84>
    80004e62:	84de                	mv	s1,s7
    80004e64:	bf49                	j	80004df6 <filewrite+0x84>
    int i = 0;
    80004e66:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e68:	013a1f63          	bne	s4,s3,80004e86 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e6c:	8552                	mv	a0,s4
    80004e6e:	60a6                	ld	ra,72(sp)
    80004e70:	6406                	ld	s0,64(sp)
    80004e72:	74e2                	ld	s1,56(sp)
    80004e74:	7942                	ld	s2,48(sp)
    80004e76:	79a2                	ld	s3,40(sp)
    80004e78:	7a02                	ld	s4,32(sp)
    80004e7a:	6ae2                	ld	s5,24(sp)
    80004e7c:	6b42                	ld	s6,16(sp)
    80004e7e:	6ba2                	ld	s7,8(sp)
    80004e80:	6c02                	ld	s8,0(sp)
    80004e82:	6161                	addi	sp,sp,80
    80004e84:	8082                	ret
    ret = (i == n ? n : -1);
    80004e86:	5a7d                	li	s4,-1
    80004e88:	b7d5                	j	80004e6c <filewrite+0xfa>
    panic("filewrite");
    80004e8a:	00004517          	auipc	a0,0x4
    80004e8e:	86650513          	addi	a0,a0,-1946 # 800086f0 <syscalls+0x2c0>
    80004e92:	ffffb097          	auipc	ra,0xffffb
    80004e96:	698080e7          	jalr	1688(ra) # 8000052a <panic>
    return -1;
    80004e9a:	5a7d                	li	s4,-1
    80004e9c:	bfc1                	j	80004e6c <filewrite+0xfa>
      return -1;
    80004e9e:	5a7d                	li	s4,-1
    80004ea0:	b7f1                	j	80004e6c <filewrite+0xfa>
    80004ea2:	5a7d                	li	s4,-1
    80004ea4:	b7e1                	j	80004e6c <filewrite+0xfa>

0000000080004ea6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ea6:	7179                	addi	sp,sp,-48
    80004ea8:	f406                	sd	ra,40(sp)
    80004eaa:	f022                	sd	s0,32(sp)
    80004eac:	ec26                	sd	s1,24(sp)
    80004eae:	e84a                	sd	s2,16(sp)
    80004eb0:	e44e                	sd	s3,8(sp)
    80004eb2:	e052                	sd	s4,0(sp)
    80004eb4:	1800                	addi	s0,sp,48
    80004eb6:	84aa                	mv	s1,a0
    80004eb8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004eba:	0005b023          	sd	zero,0(a1)
    80004ebe:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ec2:	00000097          	auipc	ra,0x0
    80004ec6:	bf8080e7          	jalr	-1032(ra) # 80004aba <filealloc>
    80004eca:	e088                	sd	a0,0(s1)
    80004ecc:	c551                	beqz	a0,80004f58 <pipealloc+0xb2>
    80004ece:	00000097          	auipc	ra,0x0
    80004ed2:	bec080e7          	jalr	-1044(ra) # 80004aba <filealloc>
    80004ed6:	00aa3023          	sd	a0,0(s4)
    80004eda:	c92d                	beqz	a0,80004f4c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004edc:	ffffc097          	auipc	ra,0xffffc
    80004ee0:	bf6080e7          	jalr	-1034(ra) # 80000ad2 <kalloc>
    80004ee4:	892a                	mv	s2,a0
    80004ee6:	c125                	beqz	a0,80004f46 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ee8:	4985                	li	s3,1
    80004eea:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004eee:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ef2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ef6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004efa:	00004597          	auipc	a1,0x4
    80004efe:	80658593          	addi	a1,a1,-2042 # 80008700 <syscalls+0x2d0>
    80004f02:	ffffc097          	auipc	ra,0xffffc
    80004f06:	c30080e7          	jalr	-976(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80004f0a:	609c                	ld	a5,0(s1)
    80004f0c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f10:	609c                	ld	a5,0(s1)
    80004f12:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f16:	609c                	ld	a5,0(s1)
    80004f18:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f1c:	609c                	ld	a5,0(s1)
    80004f1e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f22:	000a3783          	ld	a5,0(s4)
    80004f26:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f2a:	000a3783          	ld	a5,0(s4)
    80004f2e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f32:	000a3783          	ld	a5,0(s4)
    80004f36:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f3a:	000a3783          	ld	a5,0(s4)
    80004f3e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f42:	4501                	li	a0,0
    80004f44:	a025                	j	80004f6c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f46:	6088                	ld	a0,0(s1)
    80004f48:	e501                	bnez	a0,80004f50 <pipealloc+0xaa>
    80004f4a:	a039                	j	80004f58 <pipealloc+0xb2>
    80004f4c:	6088                	ld	a0,0(s1)
    80004f4e:	c51d                	beqz	a0,80004f7c <pipealloc+0xd6>
    fileclose(*f0);
    80004f50:	00000097          	auipc	ra,0x0
    80004f54:	c26080e7          	jalr	-986(ra) # 80004b76 <fileclose>
  if(*f1)
    80004f58:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f5c:	557d                	li	a0,-1
  if(*f1)
    80004f5e:	c799                	beqz	a5,80004f6c <pipealloc+0xc6>
    fileclose(*f1);
    80004f60:	853e                	mv	a0,a5
    80004f62:	00000097          	auipc	ra,0x0
    80004f66:	c14080e7          	jalr	-1004(ra) # 80004b76 <fileclose>
  return -1;
    80004f6a:	557d                	li	a0,-1
}
    80004f6c:	70a2                	ld	ra,40(sp)
    80004f6e:	7402                	ld	s0,32(sp)
    80004f70:	64e2                	ld	s1,24(sp)
    80004f72:	6942                	ld	s2,16(sp)
    80004f74:	69a2                	ld	s3,8(sp)
    80004f76:	6a02                	ld	s4,0(sp)
    80004f78:	6145                	addi	sp,sp,48
    80004f7a:	8082                	ret
  return -1;
    80004f7c:	557d                	li	a0,-1
    80004f7e:	b7fd                	j	80004f6c <pipealloc+0xc6>

0000000080004f80 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f80:	1101                	addi	sp,sp,-32
    80004f82:	ec06                	sd	ra,24(sp)
    80004f84:	e822                	sd	s0,16(sp)
    80004f86:	e426                	sd	s1,8(sp)
    80004f88:	e04a                	sd	s2,0(sp)
    80004f8a:	1000                	addi	s0,sp,32
    80004f8c:	84aa                	mv	s1,a0
    80004f8e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f90:	ffffc097          	auipc	ra,0xffffc
    80004f94:	c32080e7          	jalr	-974(ra) # 80000bc2 <acquire>
  if(writable){
    80004f98:	02090d63          	beqz	s2,80004fd2 <pipeclose+0x52>
    pi->writeopen = 0;
    80004f9c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004fa0:	21848513          	addi	a0,s1,536
    80004fa4:	ffffd097          	auipc	ra,0xffffd
    80004fa8:	2b6080e7          	jalr	694(ra) # 8000225a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004fac:	2204b783          	ld	a5,544(s1)
    80004fb0:	eb95                	bnez	a5,80004fe4 <pipeclose+0x64>
    release(&pi->lock);
    80004fb2:	8526                	mv	a0,s1
    80004fb4:	ffffc097          	auipc	ra,0xffffc
    80004fb8:	cc2080e7          	jalr	-830(ra) # 80000c76 <release>
    kfree((char*)pi);
    80004fbc:	8526                	mv	a0,s1
    80004fbe:	ffffc097          	auipc	ra,0xffffc
    80004fc2:	a18080e7          	jalr	-1512(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80004fc6:	60e2                	ld	ra,24(sp)
    80004fc8:	6442                	ld	s0,16(sp)
    80004fca:	64a2                	ld	s1,8(sp)
    80004fcc:	6902                	ld	s2,0(sp)
    80004fce:	6105                	addi	sp,sp,32
    80004fd0:	8082                	ret
    pi->readopen = 0;
    80004fd2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004fd6:	21c48513          	addi	a0,s1,540
    80004fda:	ffffd097          	auipc	ra,0xffffd
    80004fde:	280080e7          	jalr	640(ra) # 8000225a <wakeup>
    80004fe2:	b7e9                	j	80004fac <pipeclose+0x2c>
    release(&pi->lock);
    80004fe4:	8526                	mv	a0,s1
    80004fe6:	ffffc097          	auipc	ra,0xffffc
    80004fea:	c90080e7          	jalr	-880(ra) # 80000c76 <release>
}
    80004fee:	bfe1                	j	80004fc6 <pipeclose+0x46>

0000000080004ff0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ff0:	711d                	addi	sp,sp,-96
    80004ff2:	ec86                	sd	ra,88(sp)
    80004ff4:	e8a2                	sd	s0,80(sp)
    80004ff6:	e4a6                	sd	s1,72(sp)
    80004ff8:	e0ca                	sd	s2,64(sp)
    80004ffa:	fc4e                	sd	s3,56(sp)
    80004ffc:	f852                	sd	s4,48(sp)
    80004ffe:	f456                	sd	s5,40(sp)
    80005000:	f05a                	sd	s6,32(sp)
    80005002:	ec5e                	sd	s7,24(sp)
    80005004:	e862                	sd	s8,16(sp)
    80005006:	1080                	addi	s0,sp,96
    80005008:	84aa                	mv	s1,a0
    8000500a:	8aae                	mv	s5,a1
    8000500c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000500e:	ffffd097          	auipc	ra,0xffffd
    80005012:	970080e7          	jalr	-1680(ra) # 8000197e <myproc>
    80005016:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005018:	8526                	mv	a0,s1
    8000501a:	ffffc097          	auipc	ra,0xffffc
    8000501e:	ba8080e7          	jalr	-1112(ra) # 80000bc2 <acquire>
  while(i < n){
    80005022:	0b405363          	blez	s4,800050c8 <pipewrite+0xd8>
  int i = 0;
    80005026:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005028:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000502a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000502e:	21c48b93          	addi	s7,s1,540
    80005032:	a089                	j	80005074 <pipewrite+0x84>
      release(&pi->lock);
    80005034:	8526                	mv	a0,s1
    80005036:	ffffc097          	auipc	ra,0xffffc
    8000503a:	c40080e7          	jalr	-960(ra) # 80000c76 <release>
      return -1;
    8000503e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005040:	854a                	mv	a0,s2
    80005042:	60e6                	ld	ra,88(sp)
    80005044:	6446                	ld	s0,80(sp)
    80005046:	64a6                	ld	s1,72(sp)
    80005048:	6906                	ld	s2,64(sp)
    8000504a:	79e2                	ld	s3,56(sp)
    8000504c:	7a42                	ld	s4,48(sp)
    8000504e:	7aa2                	ld	s5,40(sp)
    80005050:	7b02                	ld	s6,32(sp)
    80005052:	6be2                	ld	s7,24(sp)
    80005054:	6c42                	ld	s8,16(sp)
    80005056:	6125                	addi	sp,sp,96
    80005058:	8082                	ret
      wakeup(&pi->nread);
    8000505a:	8562                	mv	a0,s8
    8000505c:	ffffd097          	auipc	ra,0xffffd
    80005060:	1fe080e7          	jalr	510(ra) # 8000225a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005064:	85a6                	mv	a1,s1
    80005066:	855e                	mv	a0,s7
    80005068:	ffffd097          	auipc	ra,0xffffd
    8000506c:	066080e7          	jalr	102(ra) # 800020ce <sleep>
  while(i < n){
    80005070:	05495d63          	bge	s2,s4,800050ca <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80005074:	2204a783          	lw	a5,544(s1)
    80005078:	dfd5                	beqz	a5,80005034 <pipewrite+0x44>
    8000507a:	0289a783          	lw	a5,40(s3)
    8000507e:	fbdd                	bnez	a5,80005034 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005080:	2184a783          	lw	a5,536(s1)
    80005084:	21c4a703          	lw	a4,540(s1)
    80005088:	2007879b          	addiw	a5,a5,512
    8000508c:	fcf707e3          	beq	a4,a5,8000505a <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005090:	4685                	li	a3,1
    80005092:	01590633          	add	a2,s2,s5
    80005096:	faf40593          	addi	a1,s0,-81
    8000509a:	0509b503          	ld	a0,80(s3)
    8000509e:	ffffc097          	auipc	ra,0xffffc
    800050a2:	62c080e7          	jalr	1580(ra) # 800016ca <copyin>
    800050a6:	03650263          	beq	a0,s6,800050ca <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800050aa:	21c4a783          	lw	a5,540(s1)
    800050ae:	0017871b          	addiw	a4,a5,1
    800050b2:	20e4ae23          	sw	a4,540(s1)
    800050b6:	1ff7f793          	andi	a5,a5,511
    800050ba:	97a6                	add	a5,a5,s1
    800050bc:	faf44703          	lbu	a4,-81(s0)
    800050c0:	00e78c23          	sb	a4,24(a5)
      i++;
    800050c4:	2905                	addiw	s2,s2,1
    800050c6:	b76d                	j	80005070 <pipewrite+0x80>
  int i = 0;
    800050c8:	4901                	li	s2,0
  wakeup(&pi->nread);
    800050ca:	21848513          	addi	a0,s1,536
    800050ce:	ffffd097          	auipc	ra,0xffffd
    800050d2:	18c080e7          	jalr	396(ra) # 8000225a <wakeup>
  release(&pi->lock);
    800050d6:	8526                	mv	a0,s1
    800050d8:	ffffc097          	auipc	ra,0xffffc
    800050dc:	b9e080e7          	jalr	-1122(ra) # 80000c76 <release>
  return i;
    800050e0:	b785                	j	80005040 <pipewrite+0x50>

00000000800050e2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800050e2:	715d                	addi	sp,sp,-80
    800050e4:	e486                	sd	ra,72(sp)
    800050e6:	e0a2                	sd	s0,64(sp)
    800050e8:	fc26                	sd	s1,56(sp)
    800050ea:	f84a                	sd	s2,48(sp)
    800050ec:	f44e                	sd	s3,40(sp)
    800050ee:	f052                	sd	s4,32(sp)
    800050f0:	ec56                	sd	s5,24(sp)
    800050f2:	e85a                	sd	s6,16(sp)
    800050f4:	0880                	addi	s0,sp,80
    800050f6:	84aa                	mv	s1,a0
    800050f8:	892e                	mv	s2,a1
    800050fa:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800050fc:	ffffd097          	auipc	ra,0xffffd
    80005100:	882080e7          	jalr	-1918(ra) # 8000197e <myproc>
    80005104:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005106:	8526                	mv	a0,s1
    80005108:	ffffc097          	auipc	ra,0xffffc
    8000510c:	aba080e7          	jalr	-1350(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005110:	2184a703          	lw	a4,536(s1)
    80005114:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005118:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000511c:	02f71463          	bne	a4,a5,80005144 <piperead+0x62>
    80005120:	2244a783          	lw	a5,548(s1)
    80005124:	c385                	beqz	a5,80005144 <piperead+0x62>
    if(pr->killed){
    80005126:	028a2783          	lw	a5,40(s4)
    8000512a:	ebc1                	bnez	a5,800051ba <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000512c:	85a6                	mv	a1,s1
    8000512e:	854e                	mv	a0,s3
    80005130:	ffffd097          	auipc	ra,0xffffd
    80005134:	f9e080e7          	jalr	-98(ra) # 800020ce <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005138:	2184a703          	lw	a4,536(s1)
    8000513c:	21c4a783          	lw	a5,540(s1)
    80005140:	fef700e3          	beq	a4,a5,80005120 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005144:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005146:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005148:	05505363          	blez	s5,8000518e <piperead+0xac>
    if(pi->nread == pi->nwrite)
    8000514c:	2184a783          	lw	a5,536(s1)
    80005150:	21c4a703          	lw	a4,540(s1)
    80005154:	02f70d63          	beq	a4,a5,8000518e <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005158:	0017871b          	addiw	a4,a5,1
    8000515c:	20e4ac23          	sw	a4,536(s1)
    80005160:	1ff7f793          	andi	a5,a5,511
    80005164:	97a6                	add	a5,a5,s1
    80005166:	0187c783          	lbu	a5,24(a5)
    8000516a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000516e:	4685                	li	a3,1
    80005170:	fbf40613          	addi	a2,s0,-65
    80005174:	85ca                	mv	a1,s2
    80005176:	050a3503          	ld	a0,80(s4)
    8000517a:	ffffc097          	auipc	ra,0xffffc
    8000517e:	4c4080e7          	jalr	1220(ra) # 8000163e <copyout>
    80005182:	01650663          	beq	a0,s6,8000518e <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005186:	2985                	addiw	s3,s3,1
    80005188:	0905                	addi	s2,s2,1
    8000518a:	fd3a91e3          	bne	s5,s3,8000514c <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000518e:	21c48513          	addi	a0,s1,540
    80005192:	ffffd097          	auipc	ra,0xffffd
    80005196:	0c8080e7          	jalr	200(ra) # 8000225a <wakeup>
  release(&pi->lock);
    8000519a:	8526                	mv	a0,s1
    8000519c:	ffffc097          	auipc	ra,0xffffc
    800051a0:	ada080e7          	jalr	-1318(ra) # 80000c76 <release>
  return i;
}
    800051a4:	854e                	mv	a0,s3
    800051a6:	60a6                	ld	ra,72(sp)
    800051a8:	6406                	ld	s0,64(sp)
    800051aa:	74e2                	ld	s1,56(sp)
    800051ac:	7942                	ld	s2,48(sp)
    800051ae:	79a2                	ld	s3,40(sp)
    800051b0:	7a02                	ld	s4,32(sp)
    800051b2:	6ae2                	ld	s5,24(sp)
    800051b4:	6b42                	ld	s6,16(sp)
    800051b6:	6161                	addi	sp,sp,80
    800051b8:	8082                	ret
      release(&pi->lock);
    800051ba:	8526                	mv	a0,s1
    800051bc:	ffffc097          	auipc	ra,0xffffc
    800051c0:	aba080e7          	jalr	-1350(ra) # 80000c76 <release>
      return -1;
    800051c4:	59fd                	li	s3,-1
    800051c6:	bff9                	j	800051a4 <piperead+0xc2>

00000000800051c8 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800051c8:	de010113          	addi	sp,sp,-544
    800051cc:	20113c23          	sd	ra,536(sp)
    800051d0:	20813823          	sd	s0,528(sp)
    800051d4:	20913423          	sd	s1,520(sp)
    800051d8:	21213023          	sd	s2,512(sp)
    800051dc:	ffce                	sd	s3,504(sp)
    800051de:	fbd2                	sd	s4,496(sp)
    800051e0:	f7d6                	sd	s5,488(sp)
    800051e2:	f3da                	sd	s6,480(sp)
    800051e4:	efde                	sd	s7,472(sp)
    800051e6:	ebe2                	sd	s8,464(sp)
    800051e8:	e7e6                	sd	s9,456(sp)
    800051ea:	e3ea                	sd	s10,448(sp)
    800051ec:	ff6e                	sd	s11,440(sp)
    800051ee:	1400                	addi	s0,sp,544
    800051f0:	dea43c23          	sd	a0,-520(s0)
    800051f4:	deb43423          	sd	a1,-536(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800051f8:	ffffc097          	auipc	ra,0xffffc
    800051fc:	786080e7          	jalr	1926(ra) # 8000197e <myproc>
    80005200:	84aa                	mv	s1,a0
  // }
  // t->trapframe = p->trapframe;
  // swtch(&p->context, &t->context);


  for(int i = 0; i<SIGNUM; i++){
    80005202:	17850793          	addi	a5,a0,376
    80005206:	27850713          	addi	a4,a0,632
    p->sigHandlers[i] = SIG_DFL;
    8000520a:	0007b023          	sd	zero,0(a5)
  for(int i = 0; i<SIGNUM; i++){
    8000520e:	07a1                	addi	a5,a5,8
    80005210:	fee79de3          	bne	a5,a4,8000520a <exec+0x42>
  }//TODO: SIG_IGN and SIG_DFL should be kept

  begin_op();
    80005214:	fffff097          	auipc	ra,0xfffff
    80005218:	496080e7          	jalr	1174(ra) # 800046aa <begin_op>

  if((ip = namei(path)) == 0){
    8000521c:	df843503          	ld	a0,-520(s0)
    80005220:	fffff097          	auipc	ra,0xfffff
    80005224:	26a080e7          	jalr	618(ra) # 8000448a <namei>
    80005228:	8aaa                	mv	s5,a0
    8000522a:	c935                	beqz	a0,8000529e <exec+0xd6>
    end_op();
    return -1;
  }
  ilock(ip);
    8000522c:	fffff097          	auipc	ra,0xfffff
    80005230:	aa8080e7          	jalr	-1368(ra) # 80003cd4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005234:	04000713          	li	a4,64
    80005238:	4681                	li	a3,0
    8000523a:	e4840613          	addi	a2,s0,-440
    8000523e:	4581                	li	a1,0
    80005240:	8556                	mv	a0,s5
    80005242:	fffff097          	auipc	ra,0xfffff
    80005246:	d46080e7          	jalr	-698(ra) # 80003f88 <readi>
    8000524a:	04000793          	li	a5,64
    8000524e:	00f51a63          	bne	a0,a5,80005262 <exec+0x9a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005252:	e4842703          	lw	a4,-440(s0)
    80005256:	464c47b7          	lui	a5,0x464c4
    8000525a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000525e:	04f70663          	beq	a4,a5,800052aa <exec+0xe2>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005262:	8556                	mv	a0,s5
    80005264:	fffff097          	auipc	ra,0xfffff
    80005268:	cd2080e7          	jalr	-814(ra) # 80003f36 <iunlockput>
    end_op();
    8000526c:	fffff097          	auipc	ra,0xfffff
    80005270:	4be080e7          	jalr	1214(ra) # 8000472a <end_op>
  }
  return -1;
    80005274:	557d                	li	a0,-1
}
    80005276:	21813083          	ld	ra,536(sp)
    8000527a:	21013403          	ld	s0,528(sp)
    8000527e:	20813483          	ld	s1,520(sp)
    80005282:	20013903          	ld	s2,512(sp)
    80005286:	79fe                	ld	s3,504(sp)
    80005288:	7a5e                	ld	s4,496(sp)
    8000528a:	7abe                	ld	s5,488(sp)
    8000528c:	7b1e                	ld	s6,480(sp)
    8000528e:	6bfe                	ld	s7,472(sp)
    80005290:	6c5e                	ld	s8,464(sp)
    80005292:	6cbe                	ld	s9,456(sp)
    80005294:	6d1e                	ld	s10,448(sp)
    80005296:	7dfa                	ld	s11,440(sp)
    80005298:	22010113          	addi	sp,sp,544
    8000529c:	8082                	ret
    end_op();
    8000529e:	fffff097          	auipc	ra,0xfffff
    800052a2:	48c080e7          	jalr	1164(ra) # 8000472a <end_op>
    return -1;
    800052a6:	557d                	li	a0,-1
    800052a8:	b7f9                	j	80005276 <exec+0xae>
  if((pagetable = proc_pagetable(p)) == 0)
    800052aa:	8526                	mv	a0,s1
    800052ac:	ffffc097          	auipc	ra,0xffffc
    800052b0:	796080e7          	jalr	1942(ra) # 80001a42 <proc_pagetable>
    800052b4:	8b2a                	mv	s6,a0
    800052b6:	d555                	beqz	a0,80005262 <exec+0x9a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052b8:	e6842783          	lw	a5,-408(s0)
    800052bc:	e8045703          	lhu	a4,-384(s0)
    800052c0:	c735                	beqz	a4,8000532c <exec+0x164>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800052c2:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052c4:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800052c8:	6a05                	lui	s4,0x1
    800052ca:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800052ce:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    800052d2:	6d85                	lui	s11,0x1
    800052d4:	7d7d                	lui	s10,0xfffff
    800052d6:	a425                	j	800054fe <exec+0x336>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800052d8:	00003517          	auipc	a0,0x3
    800052dc:	43050513          	addi	a0,a0,1072 # 80008708 <syscalls+0x2d8>
    800052e0:	ffffb097          	auipc	ra,0xffffb
    800052e4:	24a080e7          	jalr	586(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800052e8:	874a                	mv	a4,s2
    800052ea:	009c86bb          	addw	a3,s9,s1
    800052ee:	4581                	li	a1,0
    800052f0:	8556                	mv	a0,s5
    800052f2:	fffff097          	auipc	ra,0xfffff
    800052f6:	c96080e7          	jalr	-874(ra) # 80003f88 <readi>
    800052fa:	2501                	sext.w	a0,a0
    800052fc:	1aa91763          	bne	s2,a0,800054aa <exec+0x2e2>
  for(i = 0; i < sz; i += PGSIZE){
    80005300:	009d84bb          	addw	s1,s11,s1
    80005304:	013d09bb          	addw	s3,s10,s3
    80005308:	1d74fb63          	bgeu	s1,s7,800054de <exec+0x316>
    pa = walkaddr(pagetable, va + i);
    8000530c:	02049593          	slli	a1,s1,0x20
    80005310:	9181                	srli	a1,a1,0x20
    80005312:	95e2                	add	a1,a1,s8
    80005314:	855a                	mv	a0,s6
    80005316:	ffffc097          	auipc	ra,0xffffc
    8000531a:	d36080e7          	jalr	-714(ra) # 8000104c <walkaddr>
    8000531e:	862a                	mv	a2,a0
    if(pa == 0)
    80005320:	dd45                	beqz	a0,800052d8 <exec+0x110>
      n = PGSIZE;
    80005322:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005324:	fd49f2e3          	bgeu	s3,s4,800052e8 <exec+0x120>
      n = sz - i;
    80005328:	894e                	mv	s2,s3
    8000532a:	bf7d                	j	800052e8 <exec+0x120>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000532c:	4481                	li	s1,0
  iunlockput(ip);
    8000532e:	8556                	mv	a0,s5
    80005330:	fffff097          	auipc	ra,0xfffff
    80005334:	c06080e7          	jalr	-1018(ra) # 80003f36 <iunlockput>
  end_op();
    80005338:	fffff097          	auipc	ra,0xfffff
    8000533c:	3f2080e7          	jalr	1010(ra) # 8000472a <end_op>
  p = myproc();
    80005340:	ffffc097          	auipc	ra,0xffffc
    80005344:	63e080e7          	jalr	1598(ra) # 8000197e <myproc>
    80005348:	8a2a                	mv	s4,a0
  uint64 oldsz = p->sz;
    8000534a:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000534e:	6785                	lui	a5,0x1
    80005350:	17fd                	addi	a5,a5,-1
    80005352:	94be                	add	s1,s1,a5
    80005354:	77fd                	lui	a5,0xfffff
    80005356:	8cfd                	and	s1,s1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005358:	6609                	lui	a2,0x2
    8000535a:	9626                	add	a2,a2,s1
    8000535c:	85a6                	mv	a1,s1
    8000535e:	855a                	mv	a0,s6
    80005360:	ffffc097          	auipc	ra,0xffffc
    80005364:	08e080e7          	jalr	142(ra) # 800013ee <uvmalloc>
    80005368:	892a                	mv	s2,a0
    8000536a:	dea43823          	sd	a0,-528(s0)
    8000536e:	e509                	bnez	a0,80005378 <exec+0x1b0>
  sz = PGROUNDUP(sz);
    80005370:	de943823          	sd	s1,-528(s0)
  ip = 0;
    80005374:	4a81                	li	s5,0
    80005376:	aa15                	j	800054aa <exec+0x2e2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005378:	75f9                	lui	a1,0xffffe
    8000537a:	95aa                	add	a1,a1,a0
    8000537c:	855a                	mv	a0,s6
    8000537e:	ffffc097          	auipc	ra,0xffffc
    80005382:	28e080e7          	jalr	654(ra) # 8000160c <uvmclear>
  stackbase = sp - PGSIZE;
    80005386:	7bfd                	lui	s7,0xfffff
    80005388:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    8000538a:	de843783          	ld	a5,-536(s0)
    8000538e:	6388                	ld	a0,0(a5)
    80005390:	c52d                	beqz	a0,800053fa <exec+0x232>
    80005392:	e8840993          	addi	s3,s0,-376
    80005396:	f8840c13          	addi	s8,s0,-120
    8000539a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000539c:	ffffc097          	auipc	ra,0xffffc
    800053a0:	aa6080e7          	jalr	-1370(ra) # 80000e42 <strlen>
    800053a4:	0015079b          	addiw	a5,a0,1
    800053a8:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800053ac:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800053b0:	13796163          	bltu	s2,s7,800054d2 <exec+0x30a>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800053b4:	de843d03          	ld	s10,-536(s0)
    800053b8:	000d3a83          	ld	s5,0(s10) # fffffffffffff000 <end+0xffffffff7ffd3000>
    800053bc:	8556                	mv	a0,s5
    800053be:	ffffc097          	auipc	ra,0xffffc
    800053c2:	a84080e7          	jalr	-1404(ra) # 80000e42 <strlen>
    800053c6:	0015069b          	addiw	a3,a0,1
    800053ca:	8656                	mv	a2,s5
    800053cc:	85ca                	mv	a1,s2
    800053ce:	855a                	mv	a0,s6
    800053d0:	ffffc097          	auipc	ra,0xffffc
    800053d4:	26e080e7          	jalr	622(ra) # 8000163e <copyout>
    800053d8:	0e054f63          	bltz	a0,800054d6 <exec+0x30e>
    ustack[argc] = sp;
    800053dc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800053e0:	0485                	addi	s1,s1,1
    800053e2:	008d0793          	addi	a5,s10,8
    800053e6:	def43423          	sd	a5,-536(s0)
    800053ea:	008d3503          	ld	a0,8(s10)
    800053ee:	c909                	beqz	a0,80005400 <exec+0x238>
    if(argc >= MAXARG)
    800053f0:	09a1                	addi	s3,s3,8
    800053f2:	fb3c15e3          	bne	s8,s3,8000539c <exec+0x1d4>
  ip = 0;
    800053f6:	4a81                	li	s5,0
    800053f8:	a84d                	j	800054aa <exec+0x2e2>
  sp = sz;
    800053fa:	df043903          	ld	s2,-528(s0)
  for(argc = 0; argv[argc]; argc++) {
    800053fe:	4481                	li	s1,0
  ustack[argc] = 0;
    80005400:	00349793          	slli	a5,s1,0x3
    80005404:	f9040713          	addi	a4,s0,-112
    80005408:	97ba                	add	a5,a5,a4
    8000540a:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd2ef8>
  sp -= (argc+1) * sizeof(uint64);
    8000540e:	00148693          	addi	a3,s1,1
    80005412:	068e                	slli	a3,a3,0x3
    80005414:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005418:	ff097913          	andi	s2,s2,-16
  ip = 0;
    8000541c:	4a81                	li	s5,0
  if(sp < stackbase)
    8000541e:	09796663          	bltu	s2,s7,800054aa <exec+0x2e2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005422:	e8840613          	addi	a2,s0,-376
    80005426:	85ca                	mv	a1,s2
    80005428:	855a                	mv	a0,s6
    8000542a:	ffffc097          	auipc	ra,0xffffc
    8000542e:	214080e7          	jalr	532(ra) # 8000163e <copyout>
    80005432:	0a054463          	bltz	a0,800054da <exec+0x312>
  p->trapframe->a1 = sp;
    80005436:	058a3783          	ld	a5,88(s4)
    8000543a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000543e:	df843783          	ld	a5,-520(s0)
    80005442:	0007c703          	lbu	a4,0(a5)
    80005446:	cf11                	beqz	a4,80005462 <exec+0x29a>
    80005448:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000544a:	02f00693          	li	a3,47
    8000544e:	a029                	j	80005458 <exec+0x290>
  for(last=s=path; *s; s++)
    80005450:	0785                	addi	a5,a5,1
    80005452:	fff7c703          	lbu	a4,-1(a5)
    80005456:	c711                	beqz	a4,80005462 <exec+0x29a>
    if(*s == '/')
    80005458:	fed71ce3          	bne	a4,a3,80005450 <exec+0x288>
      last = s+1;
    8000545c:	def43c23          	sd	a5,-520(s0)
    80005460:	bfc5                	j	80005450 <exec+0x288>
  safestrcpy(p->name, last, sizeof(p->name));
    80005462:	4641                	li	a2,16
    80005464:	df843583          	ld	a1,-520(s0)
    80005468:	158a0513          	addi	a0,s4,344
    8000546c:	ffffc097          	auipc	ra,0xffffc
    80005470:	9a4080e7          	jalr	-1628(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005474:	050a3503          	ld	a0,80(s4)
  p->pagetable = pagetable;
    80005478:	056a3823          	sd	s6,80(s4)
  p->sz = sz;
    8000547c:	df043783          	ld	a5,-528(s0)
    80005480:	04fa3423          	sd	a5,72(s4)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005484:	058a3783          	ld	a5,88(s4)
    80005488:	e6043703          	ld	a4,-416(s0)
    8000548c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000548e:	058a3783          	ld	a5,88(s4)
    80005492:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005496:	85e6                	mv	a1,s9
    80005498:	ffffc097          	auipc	ra,0xffffc
    8000549c:	646080e7          	jalr	1606(ra) # 80001ade <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800054a0:	0004851b          	sext.w	a0,s1
    800054a4:	bbc9                	j	80005276 <exec+0xae>
    800054a6:	de943823          	sd	s1,-528(s0)
    proc_freepagetable(pagetable, sz);
    800054aa:	df043583          	ld	a1,-528(s0)
    800054ae:	855a                	mv	a0,s6
    800054b0:	ffffc097          	auipc	ra,0xffffc
    800054b4:	62e080e7          	jalr	1582(ra) # 80001ade <proc_freepagetable>
  if(ip){
    800054b8:	da0a95e3          	bnez	s5,80005262 <exec+0x9a>
  return -1;
    800054bc:	557d                	li	a0,-1
    800054be:	bb65                	j	80005276 <exec+0xae>
    800054c0:	de943823          	sd	s1,-528(s0)
    800054c4:	b7dd                	j	800054aa <exec+0x2e2>
    800054c6:	de943823          	sd	s1,-528(s0)
    800054ca:	b7c5                	j	800054aa <exec+0x2e2>
    800054cc:	de943823          	sd	s1,-528(s0)
    800054d0:	bfe9                	j	800054aa <exec+0x2e2>
  ip = 0;
    800054d2:	4a81                	li	s5,0
    800054d4:	bfd9                	j	800054aa <exec+0x2e2>
    800054d6:	4a81                	li	s5,0
    800054d8:	bfc9                	j	800054aa <exec+0x2e2>
    800054da:	4a81                	li	s5,0
    800054dc:	b7f9                	j	800054aa <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800054de:	df043483          	ld	s1,-528(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054e2:	e0843783          	ld	a5,-504(s0)
    800054e6:	0017869b          	addiw	a3,a5,1
    800054ea:	e0d43423          	sd	a3,-504(s0)
    800054ee:	e0043783          	ld	a5,-512(s0)
    800054f2:	0387879b          	addiw	a5,a5,56
    800054f6:	e8045703          	lhu	a4,-384(s0)
    800054fa:	e2e6dae3          	bge	a3,a4,8000532e <exec+0x166>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800054fe:	2781                	sext.w	a5,a5
    80005500:	e0f43023          	sd	a5,-512(s0)
    80005504:	03800713          	li	a4,56
    80005508:	86be                	mv	a3,a5
    8000550a:	e1040613          	addi	a2,s0,-496
    8000550e:	4581                	li	a1,0
    80005510:	8556                	mv	a0,s5
    80005512:	fffff097          	auipc	ra,0xfffff
    80005516:	a76080e7          	jalr	-1418(ra) # 80003f88 <readi>
    8000551a:	03800793          	li	a5,56
    8000551e:	f8f514e3          	bne	a0,a5,800054a6 <exec+0x2de>
    if(ph.type != ELF_PROG_LOAD)
    80005522:	e1042783          	lw	a5,-496(s0)
    80005526:	4705                	li	a4,1
    80005528:	fae79de3          	bne	a5,a4,800054e2 <exec+0x31a>
    if(ph.memsz < ph.filesz)
    8000552c:	e3843603          	ld	a2,-456(s0)
    80005530:	e3043783          	ld	a5,-464(s0)
    80005534:	f8f666e3          	bltu	a2,a5,800054c0 <exec+0x2f8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005538:	e2043783          	ld	a5,-480(s0)
    8000553c:	963e                	add	a2,a2,a5
    8000553e:	f8f664e3          	bltu	a2,a5,800054c6 <exec+0x2fe>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005542:	85a6                	mv	a1,s1
    80005544:	855a                	mv	a0,s6
    80005546:	ffffc097          	auipc	ra,0xffffc
    8000554a:	ea8080e7          	jalr	-344(ra) # 800013ee <uvmalloc>
    8000554e:	dea43823          	sd	a0,-528(s0)
    80005552:	dd2d                	beqz	a0,800054cc <exec+0x304>
    if(ph.vaddr % PGSIZE != 0)
    80005554:	e2043c03          	ld	s8,-480(s0)
    80005558:	de043783          	ld	a5,-544(s0)
    8000555c:	00fc77b3          	and	a5,s8,a5
    80005560:	f7a9                	bnez	a5,800054aa <exec+0x2e2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005562:	e1842c83          	lw	s9,-488(s0)
    80005566:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000556a:	f60b8ae3          	beqz	s7,800054de <exec+0x316>
    8000556e:	89de                	mv	s3,s7
    80005570:	4481                	li	s1,0
    80005572:	bb69                	j	8000530c <exec+0x144>

0000000080005574 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005574:	7179                	addi	sp,sp,-48
    80005576:	f406                	sd	ra,40(sp)
    80005578:	f022                	sd	s0,32(sp)
    8000557a:	ec26                	sd	s1,24(sp)
    8000557c:	e84a                	sd	s2,16(sp)
    8000557e:	1800                	addi	s0,sp,48
    80005580:	892e                	mv	s2,a1
    80005582:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005584:	fdc40593          	addi	a1,s0,-36
    80005588:	ffffe097          	auipc	ra,0xffffe
    8000558c:	974080e7          	jalr	-1676(ra) # 80002efc <argint>
    80005590:	04054063          	bltz	a0,800055d0 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005594:	fdc42703          	lw	a4,-36(s0)
    80005598:	47bd                	li	a5,15
    8000559a:	02e7ed63          	bltu	a5,a4,800055d4 <argfd+0x60>
    8000559e:	ffffc097          	auipc	ra,0xffffc
    800055a2:	3e0080e7          	jalr	992(ra) # 8000197e <myproc>
    800055a6:	fdc42703          	lw	a4,-36(s0)
    800055aa:	01a70793          	addi	a5,a4,26
    800055ae:	078e                	slli	a5,a5,0x3
    800055b0:	953e                	add	a0,a0,a5
    800055b2:	611c                	ld	a5,0(a0)
    800055b4:	c395                	beqz	a5,800055d8 <argfd+0x64>
    return -1;
  if(pfd)
    800055b6:	00090463          	beqz	s2,800055be <argfd+0x4a>
    *pfd = fd;
    800055ba:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800055be:	4501                	li	a0,0
  if(pf)
    800055c0:	c091                	beqz	s1,800055c4 <argfd+0x50>
    *pf = f;
    800055c2:	e09c                	sd	a5,0(s1)
}
    800055c4:	70a2                	ld	ra,40(sp)
    800055c6:	7402                	ld	s0,32(sp)
    800055c8:	64e2                	ld	s1,24(sp)
    800055ca:	6942                	ld	s2,16(sp)
    800055cc:	6145                	addi	sp,sp,48
    800055ce:	8082                	ret
    return -1;
    800055d0:	557d                	li	a0,-1
    800055d2:	bfcd                	j	800055c4 <argfd+0x50>
    return -1;
    800055d4:	557d                	li	a0,-1
    800055d6:	b7fd                	j	800055c4 <argfd+0x50>
    800055d8:	557d                	li	a0,-1
    800055da:	b7ed                	j	800055c4 <argfd+0x50>

00000000800055dc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800055dc:	1101                	addi	sp,sp,-32
    800055de:	ec06                	sd	ra,24(sp)
    800055e0:	e822                	sd	s0,16(sp)
    800055e2:	e426                	sd	s1,8(sp)
    800055e4:	1000                	addi	s0,sp,32
    800055e6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800055e8:	ffffc097          	auipc	ra,0xffffc
    800055ec:	396080e7          	jalr	918(ra) # 8000197e <myproc>
    800055f0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800055f2:	0d050793          	addi	a5,a0,208
    800055f6:	4501                	li	a0,0
    800055f8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800055fa:	6398                	ld	a4,0(a5)
    800055fc:	cb19                	beqz	a4,80005612 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800055fe:	2505                	addiw	a0,a0,1
    80005600:	07a1                	addi	a5,a5,8
    80005602:	fed51ce3          	bne	a0,a3,800055fa <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005606:	557d                	li	a0,-1
}
    80005608:	60e2                	ld	ra,24(sp)
    8000560a:	6442                	ld	s0,16(sp)
    8000560c:	64a2                	ld	s1,8(sp)
    8000560e:	6105                	addi	sp,sp,32
    80005610:	8082                	ret
      p->ofile[fd] = f;
    80005612:	01a50793          	addi	a5,a0,26
    80005616:	078e                	slli	a5,a5,0x3
    80005618:	963e                	add	a2,a2,a5
    8000561a:	e204                	sd	s1,0(a2)
      return fd;
    8000561c:	b7f5                	j	80005608 <fdalloc+0x2c>

000000008000561e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000561e:	715d                	addi	sp,sp,-80
    80005620:	e486                	sd	ra,72(sp)
    80005622:	e0a2                	sd	s0,64(sp)
    80005624:	fc26                	sd	s1,56(sp)
    80005626:	f84a                	sd	s2,48(sp)
    80005628:	f44e                	sd	s3,40(sp)
    8000562a:	f052                	sd	s4,32(sp)
    8000562c:	ec56                	sd	s5,24(sp)
    8000562e:	0880                	addi	s0,sp,80
    80005630:	89ae                	mv	s3,a1
    80005632:	8ab2                	mv	s5,a2
    80005634:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005636:	fb040593          	addi	a1,s0,-80
    8000563a:	fffff097          	auipc	ra,0xfffff
    8000563e:	e6e080e7          	jalr	-402(ra) # 800044a8 <nameiparent>
    80005642:	892a                	mv	s2,a0
    80005644:	12050e63          	beqz	a0,80005780 <create+0x162>
    return 0;

  ilock(dp);
    80005648:	ffffe097          	auipc	ra,0xffffe
    8000564c:	68c080e7          	jalr	1676(ra) # 80003cd4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005650:	4601                	li	a2,0
    80005652:	fb040593          	addi	a1,s0,-80
    80005656:	854a                	mv	a0,s2
    80005658:	fffff097          	auipc	ra,0xfffff
    8000565c:	b60080e7          	jalr	-1184(ra) # 800041b8 <dirlookup>
    80005660:	84aa                	mv	s1,a0
    80005662:	c921                	beqz	a0,800056b2 <create+0x94>
    iunlockput(dp);
    80005664:	854a                	mv	a0,s2
    80005666:	fffff097          	auipc	ra,0xfffff
    8000566a:	8d0080e7          	jalr	-1840(ra) # 80003f36 <iunlockput>
    ilock(ip);
    8000566e:	8526                	mv	a0,s1
    80005670:	ffffe097          	auipc	ra,0xffffe
    80005674:	664080e7          	jalr	1636(ra) # 80003cd4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005678:	2981                	sext.w	s3,s3
    8000567a:	4789                	li	a5,2
    8000567c:	02f99463          	bne	s3,a5,800056a4 <create+0x86>
    80005680:	0444d783          	lhu	a5,68(s1)
    80005684:	37f9                	addiw	a5,a5,-2
    80005686:	17c2                	slli	a5,a5,0x30
    80005688:	93c1                	srli	a5,a5,0x30
    8000568a:	4705                	li	a4,1
    8000568c:	00f76c63          	bltu	a4,a5,800056a4 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005690:	8526                	mv	a0,s1
    80005692:	60a6                	ld	ra,72(sp)
    80005694:	6406                	ld	s0,64(sp)
    80005696:	74e2                	ld	s1,56(sp)
    80005698:	7942                	ld	s2,48(sp)
    8000569a:	79a2                	ld	s3,40(sp)
    8000569c:	7a02                	ld	s4,32(sp)
    8000569e:	6ae2                	ld	s5,24(sp)
    800056a0:	6161                	addi	sp,sp,80
    800056a2:	8082                	ret
    iunlockput(ip);
    800056a4:	8526                	mv	a0,s1
    800056a6:	fffff097          	auipc	ra,0xfffff
    800056aa:	890080e7          	jalr	-1904(ra) # 80003f36 <iunlockput>
    return 0;
    800056ae:	4481                	li	s1,0
    800056b0:	b7c5                	j	80005690 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800056b2:	85ce                	mv	a1,s3
    800056b4:	00092503          	lw	a0,0(s2)
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	484080e7          	jalr	1156(ra) # 80003b3c <ialloc>
    800056c0:	84aa                	mv	s1,a0
    800056c2:	c521                	beqz	a0,8000570a <create+0xec>
  ilock(ip);
    800056c4:	ffffe097          	auipc	ra,0xffffe
    800056c8:	610080e7          	jalr	1552(ra) # 80003cd4 <ilock>
  ip->major = major;
    800056cc:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800056d0:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800056d4:	4a05                	li	s4,1
    800056d6:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800056da:	8526                	mv	a0,s1
    800056dc:	ffffe097          	auipc	ra,0xffffe
    800056e0:	52e080e7          	jalr	1326(ra) # 80003c0a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800056e4:	2981                	sext.w	s3,s3
    800056e6:	03498a63          	beq	s3,s4,8000571a <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800056ea:	40d0                	lw	a2,4(s1)
    800056ec:	fb040593          	addi	a1,s0,-80
    800056f0:	854a                	mv	a0,s2
    800056f2:	fffff097          	auipc	ra,0xfffff
    800056f6:	cd6080e7          	jalr	-810(ra) # 800043c8 <dirlink>
    800056fa:	06054b63          	bltz	a0,80005770 <create+0x152>
  iunlockput(dp);
    800056fe:	854a                	mv	a0,s2
    80005700:	fffff097          	auipc	ra,0xfffff
    80005704:	836080e7          	jalr	-1994(ra) # 80003f36 <iunlockput>
  return ip;
    80005708:	b761                	j	80005690 <create+0x72>
    panic("create: ialloc");
    8000570a:	00003517          	auipc	a0,0x3
    8000570e:	01e50513          	addi	a0,a0,30 # 80008728 <syscalls+0x2f8>
    80005712:	ffffb097          	auipc	ra,0xffffb
    80005716:	e18080e7          	jalr	-488(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    8000571a:	04a95783          	lhu	a5,74(s2)
    8000571e:	2785                	addiw	a5,a5,1
    80005720:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005724:	854a                	mv	a0,s2
    80005726:	ffffe097          	auipc	ra,0xffffe
    8000572a:	4e4080e7          	jalr	1252(ra) # 80003c0a <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000572e:	40d0                	lw	a2,4(s1)
    80005730:	00003597          	auipc	a1,0x3
    80005734:	00858593          	addi	a1,a1,8 # 80008738 <syscalls+0x308>
    80005738:	8526                	mv	a0,s1
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	c8e080e7          	jalr	-882(ra) # 800043c8 <dirlink>
    80005742:	00054f63          	bltz	a0,80005760 <create+0x142>
    80005746:	00492603          	lw	a2,4(s2)
    8000574a:	00003597          	auipc	a1,0x3
    8000574e:	ff658593          	addi	a1,a1,-10 # 80008740 <syscalls+0x310>
    80005752:	8526                	mv	a0,s1
    80005754:	fffff097          	auipc	ra,0xfffff
    80005758:	c74080e7          	jalr	-908(ra) # 800043c8 <dirlink>
    8000575c:	f80557e3          	bgez	a0,800056ea <create+0xcc>
      panic("create dots");
    80005760:	00003517          	auipc	a0,0x3
    80005764:	fe850513          	addi	a0,a0,-24 # 80008748 <syscalls+0x318>
    80005768:	ffffb097          	auipc	ra,0xffffb
    8000576c:	dc2080e7          	jalr	-574(ra) # 8000052a <panic>
    panic("create: dirlink");
    80005770:	00003517          	auipc	a0,0x3
    80005774:	fe850513          	addi	a0,a0,-24 # 80008758 <syscalls+0x328>
    80005778:	ffffb097          	auipc	ra,0xffffb
    8000577c:	db2080e7          	jalr	-590(ra) # 8000052a <panic>
    return 0;
    80005780:	84aa                	mv	s1,a0
    80005782:	b739                	j	80005690 <create+0x72>

0000000080005784 <sys_dup>:
{
    80005784:	7179                	addi	sp,sp,-48
    80005786:	f406                	sd	ra,40(sp)
    80005788:	f022                	sd	s0,32(sp)
    8000578a:	ec26                	sd	s1,24(sp)
    8000578c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000578e:	fd840613          	addi	a2,s0,-40
    80005792:	4581                	li	a1,0
    80005794:	4501                	li	a0,0
    80005796:	00000097          	auipc	ra,0x0
    8000579a:	dde080e7          	jalr	-546(ra) # 80005574 <argfd>
    return -1;
    8000579e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800057a0:	02054363          	bltz	a0,800057c6 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800057a4:	fd843503          	ld	a0,-40(s0)
    800057a8:	00000097          	auipc	ra,0x0
    800057ac:	e34080e7          	jalr	-460(ra) # 800055dc <fdalloc>
    800057b0:	84aa                	mv	s1,a0
    return -1;
    800057b2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800057b4:	00054963          	bltz	a0,800057c6 <sys_dup+0x42>
  filedup(f);
    800057b8:	fd843503          	ld	a0,-40(s0)
    800057bc:	fffff097          	auipc	ra,0xfffff
    800057c0:	368080e7          	jalr	872(ra) # 80004b24 <filedup>
  return fd;
    800057c4:	87a6                	mv	a5,s1
}
    800057c6:	853e                	mv	a0,a5
    800057c8:	70a2                	ld	ra,40(sp)
    800057ca:	7402                	ld	s0,32(sp)
    800057cc:	64e2                	ld	s1,24(sp)
    800057ce:	6145                	addi	sp,sp,48
    800057d0:	8082                	ret

00000000800057d2 <sys_read>:
{
    800057d2:	7179                	addi	sp,sp,-48
    800057d4:	f406                	sd	ra,40(sp)
    800057d6:	f022                	sd	s0,32(sp)
    800057d8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057da:	fe840613          	addi	a2,s0,-24
    800057de:	4581                	li	a1,0
    800057e0:	4501                	li	a0,0
    800057e2:	00000097          	auipc	ra,0x0
    800057e6:	d92080e7          	jalr	-622(ra) # 80005574 <argfd>
    return -1;
    800057ea:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057ec:	04054163          	bltz	a0,8000582e <sys_read+0x5c>
    800057f0:	fe440593          	addi	a1,s0,-28
    800057f4:	4509                	li	a0,2
    800057f6:	ffffd097          	auipc	ra,0xffffd
    800057fa:	706080e7          	jalr	1798(ra) # 80002efc <argint>
    return -1;
    800057fe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005800:	02054763          	bltz	a0,8000582e <sys_read+0x5c>
    80005804:	fd840593          	addi	a1,s0,-40
    80005808:	4505                	li	a0,1
    8000580a:	ffffd097          	auipc	ra,0xffffd
    8000580e:	714080e7          	jalr	1812(ra) # 80002f1e <argaddr>
    return -1;
    80005812:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005814:	00054d63          	bltz	a0,8000582e <sys_read+0x5c>
  return fileread(f, p, n);
    80005818:	fe442603          	lw	a2,-28(s0)
    8000581c:	fd843583          	ld	a1,-40(s0)
    80005820:	fe843503          	ld	a0,-24(s0)
    80005824:	fffff097          	auipc	ra,0xfffff
    80005828:	48c080e7          	jalr	1164(ra) # 80004cb0 <fileread>
    8000582c:	87aa                	mv	a5,a0
}
    8000582e:	853e                	mv	a0,a5
    80005830:	70a2                	ld	ra,40(sp)
    80005832:	7402                	ld	s0,32(sp)
    80005834:	6145                	addi	sp,sp,48
    80005836:	8082                	ret

0000000080005838 <sys_write>:
{
    80005838:	7179                	addi	sp,sp,-48
    8000583a:	f406                	sd	ra,40(sp)
    8000583c:	f022                	sd	s0,32(sp)
    8000583e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005840:	fe840613          	addi	a2,s0,-24
    80005844:	4581                	li	a1,0
    80005846:	4501                	li	a0,0
    80005848:	00000097          	auipc	ra,0x0
    8000584c:	d2c080e7          	jalr	-724(ra) # 80005574 <argfd>
    return -1;
    80005850:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005852:	04054163          	bltz	a0,80005894 <sys_write+0x5c>
    80005856:	fe440593          	addi	a1,s0,-28
    8000585a:	4509                	li	a0,2
    8000585c:	ffffd097          	auipc	ra,0xffffd
    80005860:	6a0080e7          	jalr	1696(ra) # 80002efc <argint>
    return -1;
    80005864:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005866:	02054763          	bltz	a0,80005894 <sys_write+0x5c>
    8000586a:	fd840593          	addi	a1,s0,-40
    8000586e:	4505                	li	a0,1
    80005870:	ffffd097          	auipc	ra,0xffffd
    80005874:	6ae080e7          	jalr	1710(ra) # 80002f1e <argaddr>
    return -1;
    80005878:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000587a:	00054d63          	bltz	a0,80005894 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000587e:	fe442603          	lw	a2,-28(s0)
    80005882:	fd843583          	ld	a1,-40(s0)
    80005886:	fe843503          	ld	a0,-24(s0)
    8000588a:	fffff097          	auipc	ra,0xfffff
    8000588e:	4e8080e7          	jalr	1256(ra) # 80004d72 <filewrite>
    80005892:	87aa                	mv	a5,a0
}
    80005894:	853e                	mv	a0,a5
    80005896:	70a2                	ld	ra,40(sp)
    80005898:	7402                	ld	s0,32(sp)
    8000589a:	6145                	addi	sp,sp,48
    8000589c:	8082                	ret

000000008000589e <sys_close>:
{
    8000589e:	1101                	addi	sp,sp,-32
    800058a0:	ec06                	sd	ra,24(sp)
    800058a2:	e822                	sd	s0,16(sp)
    800058a4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800058a6:	fe040613          	addi	a2,s0,-32
    800058aa:	fec40593          	addi	a1,s0,-20
    800058ae:	4501                	li	a0,0
    800058b0:	00000097          	auipc	ra,0x0
    800058b4:	cc4080e7          	jalr	-828(ra) # 80005574 <argfd>
    return -1;
    800058b8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800058ba:	02054463          	bltz	a0,800058e2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800058be:	ffffc097          	auipc	ra,0xffffc
    800058c2:	0c0080e7          	jalr	192(ra) # 8000197e <myproc>
    800058c6:	fec42783          	lw	a5,-20(s0)
    800058ca:	07e9                	addi	a5,a5,26
    800058cc:	078e                	slli	a5,a5,0x3
    800058ce:	97aa                	add	a5,a5,a0
    800058d0:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800058d4:	fe043503          	ld	a0,-32(s0)
    800058d8:	fffff097          	auipc	ra,0xfffff
    800058dc:	29e080e7          	jalr	670(ra) # 80004b76 <fileclose>
  return 0;
    800058e0:	4781                	li	a5,0
}
    800058e2:	853e                	mv	a0,a5
    800058e4:	60e2                	ld	ra,24(sp)
    800058e6:	6442                	ld	s0,16(sp)
    800058e8:	6105                	addi	sp,sp,32
    800058ea:	8082                	ret

00000000800058ec <sys_fstat>:
{
    800058ec:	1101                	addi	sp,sp,-32
    800058ee:	ec06                	sd	ra,24(sp)
    800058f0:	e822                	sd	s0,16(sp)
    800058f2:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800058f4:	fe840613          	addi	a2,s0,-24
    800058f8:	4581                	li	a1,0
    800058fa:	4501                	li	a0,0
    800058fc:	00000097          	auipc	ra,0x0
    80005900:	c78080e7          	jalr	-904(ra) # 80005574 <argfd>
    return -1;
    80005904:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005906:	02054563          	bltz	a0,80005930 <sys_fstat+0x44>
    8000590a:	fe040593          	addi	a1,s0,-32
    8000590e:	4505                	li	a0,1
    80005910:	ffffd097          	auipc	ra,0xffffd
    80005914:	60e080e7          	jalr	1550(ra) # 80002f1e <argaddr>
    return -1;
    80005918:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000591a:	00054b63          	bltz	a0,80005930 <sys_fstat+0x44>
  return filestat(f, st);
    8000591e:	fe043583          	ld	a1,-32(s0)
    80005922:	fe843503          	ld	a0,-24(s0)
    80005926:	fffff097          	auipc	ra,0xfffff
    8000592a:	318080e7          	jalr	792(ra) # 80004c3e <filestat>
    8000592e:	87aa                	mv	a5,a0
}
    80005930:	853e                	mv	a0,a5
    80005932:	60e2                	ld	ra,24(sp)
    80005934:	6442                	ld	s0,16(sp)
    80005936:	6105                	addi	sp,sp,32
    80005938:	8082                	ret

000000008000593a <sys_link>:
{
    8000593a:	7169                	addi	sp,sp,-304
    8000593c:	f606                	sd	ra,296(sp)
    8000593e:	f222                	sd	s0,288(sp)
    80005940:	ee26                	sd	s1,280(sp)
    80005942:	ea4a                	sd	s2,272(sp)
    80005944:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005946:	08000613          	li	a2,128
    8000594a:	ed040593          	addi	a1,s0,-304
    8000594e:	4501                	li	a0,0
    80005950:	ffffd097          	auipc	ra,0xffffd
    80005954:	5f0080e7          	jalr	1520(ra) # 80002f40 <argstr>
    return -1;
    80005958:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000595a:	10054e63          	bltz	a0,80005a76 <sys_link+0x13c>
    8000595e:	08000613          	li	a2,128
    80005962:	f5040593          	addi	a1,s0,-176
    80005966:	4505                	li	a0,1
    80005968:	ffffd097          	auipc	ra,0xffffd
    8000596c:	5d8080e7          	jalr	1496(ra) # 80002f40 <argstr>
    return -1;
    80005970:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005972:	10054263          	bltz	a0,80005a76 <sys_link+0x13c>
  begin_op();
    80005976:	fffff097          	auipc	ra,0xfffff
    8000597a:	d34080e7          	jalr	-716(ra) # 800046aa <begin_op>
  if((ip = namei(old)) == 0){
    8000597e:	ed040513          	addi	a0,s0,-304
    80005982:	fffff097          	auipc	ra,0xfffff
    80005986:	b08080e7          	jalr	-1272(ra) # 8000448a <namei>
    8000598a:	84aa                	mv	s1,a0
    8000598c:	c551                	beqz	a0,80005a18 <sys_link+0xde>
  ilock(ip);
    8000598e:	ffffe097          	auipc	ra,0xffffe
    80005992:	346080e7          	jalr	838(ra) # 80003cd4 <ilock>
  if(ip->type == T_DIR){
    80005996:	04449703          	lh	a4,68(s1)
    8000599a:	4785                	li	a5,1
    8000599c:	08f70463          	beq	a4,a5,80005a24 <sys_link+0xea>
  ip->nlink++;
    800059a0:	04a4d783          	lhu	a5,74(s1)
    800059a4:	2785                	addiw	a5,a5,1
    800059a6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059aa:	8526                	mv	a0,s1
    800059ac:	ffffe097          	auipc	ra,0xffffe
    800059b0:	25e080e7          	jalr	606(ra) # 80003c0a <iupdate>
  iunlock(ip);
    800059b4:	8526                	mv	a0,s1
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	3e0080e7          	jalr	992(ra) # 80003d96 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800059be:	fd040593          	addi	a1,s0,-48
    800059c2:	f5040513          	addi	a0,s0,-176
    800059c6:	fffff097          	auipc	ra,0xfffff
    800059ca:	ae2080e7          	jalr	-1310(ra) # 800044a8 <nameiparent>
    800059ce:	892a                	mv	s2,a0
    800059d0:	c935                	beqz	a0,80005a44 <sys_link+0x10a>
  ilock(dp);
    800059d2:	ffffe097          	auipc	ra,0xffffe
    800059d6:	302080e7          	jalr	770(ra) # 80003cd4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800059da:	00092703          	lw	a4,0(s2)
    800059de:	409c                	lw	a5,0(s1)
    800059e0:	04f71d63          	bne	a4,a5,80005a3a <sys_link+0x100>
    800059e4:	40d0                	lw	a2,4(s1)
    800059e6:	fd040593          	addi	a1,s0,-48
    800059ea:	854a                	mv	a0,s2
    800059ec:	fffff097          	auipc	ra,0xfffff
    800059f0:	9dc080e7          	jalr	-1572(ra) # 800043c8 <dirlink>
    800059f4:	04054363          	bltz	a0,80005a3a <sys_link+0x100>
  iunlockput(dp);
    800059f8:	854a                	mv	a0,s2
    800059fa:	ffffe097          	auipc	ra,0xffffe
    800059fe:	53c080e7          	jalr	1340(ra) # 80003f36 <iunlockput>
  iput(ip);
    80005a02:	8526                	mv	a0,s1
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	48a080e7          	jalr	1162(ra) # 80003e8e <iput>
  end_op();
    80005a0c:	fffff097          	auipc	ra,0xfffff
    80005a10:	d1e080e7          	jalr	-738(ra) # 8000472a <end_op>
  return 0;
    80005a14:	4781                	li	a5,0
    80005a16:	a085                	j	80005a76 <sys_link+0x13c>
    end_op();
    80005a18:	fffff097          	auipc	ra,0xfffff
    80005a1c:	d12080e7          	jalr	-750(ra) # 8000472a <end_op>
    return -1;
    80005a20:	57fd                	li	a5,-1
    80005a22:	a891                	j	80005a76 <sys_link+0x13c>
    iunlockput(ip);
    80005a24:	8526                	mv	a0,s1
    80005a26:	ffffe097          	auipc	ra,0xffffe
    80005a2a:	510080e7          	jalr	1296(ra) # 80003f36 <iunlockput>
    end_op();
    80005a2e:	fffff097          	auipc	ra,0xfffff
    80005a32:	cfc080e7          	jalr	-772(ra) # 8000472a <end_op>
    return -1;
    80005a36:	57fd                	li	a5,-1
    80005a38:	a83d                	j	80005a76 <sys_link+0x13c>
    iunlockput(dp);
    80005a3a:	854a                	mv	a0,s2
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	4fa080e7          	jalr	1274(ra) # 80003f36 <iunlockput>
  ilock(ip);
    80005a44:	8526                	mv	a0,s1
    80005a46:	ffffe097          	auipc	ra,0xffffe
    80005a4a:	28e080e7          	jalr	654(ra) # 80003cd4 <ilock>
  ip->nlink--;
    80005a4e:	04a4d783          	lhu	a5,74(s1)
    80005a52:	37fd                	addiw	a5,a5,-1
    80005a54:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a58:	8526                	mv	a0,s1
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	1b0080e7          	jalr	432(ra) # 80003c0a <iupdate>
  iunlockput(ip);
    80005a62:	8526                	mv	a0,s1
    80005a64:	ffffe097          	auipc	ra,0xffffe
    80005a68:	4d2080e7          	jalr	1234(ra) # 80003f36 <iunlockput>
  end_op();
    80005a6c:	fffff097          	auipc	ra,0xfffff
    80005a70:	cbe080e7          	jalr	-834(ra) # 8000472a <end_op>
  return -1;
    80005a74:	57fd                	li	a5,-1
}
    80005a76:	853e                	mv	a0,a5
    80005a78:	70b2                	ld	ra,296(sp)
    80005a7a:	7412                	ld	s0,288(sp)
    80005a7c:	64f2                	ld	s1,280(sp)
    80005a7e:	6952                	ld	s2,272(sp)
    80005a80:	6155                	addi	sp,sp,304
    80005a82:	8082                	ret

0000000080005a84 <sys_unlink>:
{
    80005a84:	7151                	addi	sp,sp,-240
    80005a86:	f586                	sd	ra,232(sp)
    80005a88:	f1a2                	sd	s0,224(sp)
    80005a8a:	eda6                	sd	s1,216(sp)
    80005a8c:	e9ca                	sd	s2,208(sp)
    80005a8e:	e5ce                	sd	s3,200(sp)
    80005a90:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a92:	08000613          	li	a2,128
    80005a96:	f3040593          	addi	a1,s0,-208
    80005a9a:	4501                	li	a0,0
    80005a9c:	ffffd097          	auipc	ra,0xffffd
    80005aa0:	4a4080e7          	jalr	1188(ra) # 80002f40 <argstr>
    80005aa4:	18054163          	bltz	a0,80005c26 <sys_unlink+0x1a2>
  begin_op();
    80005aa8:	fffff097          	auipc	ra,0xfffff
    80005aac:	c02080e7          	jalr	-1022(ra) # 800046aa <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005ab0:	fb040593          	addi	a1,s0,-80
    80005ab4:	f3040513          	addi	a0,s0,-208
    80005ab8:	fffff097          	auipc	ra,0xfffff
    80005abc:	9f0080e7          	jalr	-1552(ra) # 800044a8 <nameiparent>
    80005ac0:	84aa                	mv	s1,a0
    80005ac2:	c979                	beqz	a0,80005b98 <sys_unlink+0x114>
  ilock(dp);
    80005ac4:	ffffe097          	auipc	ra,0xffffe
    80005ac8:	210080e7          	jalr	528(ra) # 80003cd4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005acc:	00003597          	auipc	a1,0x3
    80005ad0:	c6c58593          	addi	a1,a1,-916 # 80008738 <syscalls+0x308>
    80005ad4:	fb040513          	addi	a0,s0,-80
    80005ad8:	ffffe097          	auipc	ra,0xffffe
    80005adc:	6c6080e7          	jalr	1734(ra) # 8000419e <namecmp>
    80005ae0:	14050a63          	beqz	a0,80005c34 <sys_unlink+0x1b0>
    80005ae4:	00003597          	auipc	a1,0x3
    80005ae8:	c5c58593          	addi	a1,a1,-932 # 80008740 <syscalls+0x310>
    80005aec:	fb040513          	addi	a0,s0,-80
    80005af0:	ffffe097          	auipc	ra,0xffffe
    80005af4:	6ae080e7          	jalr	1710(ra) # 8000419e <namecmp>
    80005af8:	12050e63          	beqz	a0,80005c34 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005afc:	f2c40613          	addi	a2,s0,-212
    80005b00:	fb040593          	addi	a1,s0,-80
    80005b04:	8526                	mv	a0,s1
    80005b06:	ffffe097          	auipc	ra,0xffffe
    80005b0a:	6b2080e7          	jalr	1714(ra) # 800041b8 <dirlookup>
    80005b0e:	892a                	mv	s2,a0
    80005b10:	12050263          	beqz	a0,80005c34 <sys_unlink+0x1b0>
  ilock(ip);
    80005b14:	ffffe097          	auipc	ra,0xffffe
    80005b18:	1c0080e7          	jalr	448(ra) # 80003cd4 <ilock>
  if(ip->nlink < 1)
    80005b1c:	04a91783          	lh	a5,74(s2)
    80005b20:	08f05263          	blez	a5,80005ba4 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005b24:	04491703          	lh	a4,68(s2)
    80005b28:	4785                	li	a5,1
    80005b2a:	08f70563          	beq	a4,a5,80005bb4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005b2e:	4641                	li	a2,16
    80005b30:	4581                	li	a1,0
    80005b32:	fc040513          	addi	a0,s0,-64
    80005b36:	ffffb097          	auipc	ra,0xffffb
    80005b3a:	188080e7          	jalr	392(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b3e:	4741                	li	a4,16
    80005b40:	f2c42683          	lw	a3,-212(s0)
    80005b44:	fc040613          	addi	a2,s0,-64
    80005b48:	4581                	li	a1,0
    80005b4a:	8526                	mv	a0,s1
    80005b4c:	ffffe097          	auipc	ra,0xffffe
    80005b50:	534080e7          	jalr	1332(ra) # 80004080 <writei>
    80005b54:	47c1                	li	a5,16
    80005b56:	0af51563          	bne	a0,a5,80005c00 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005b5a:	04491703          	lh	a4,68(s2)
    80005b5e:	4785                	li	a5,1
    80005b60:	0af70863          	beq	a4,a5,80005c10 <sys_unlink+0x18c>
  iunlockput(dp);
    80005b64:	8526                	mv	a0,s1
    80005b66:	ffffe097          	auipc	ra,0xffffe
    80005b6a:	3d0080e7          	jalr	976(ra) # 80003f36 <iunlockput>
  ip->nlink--;
    80005b6e:	04a95783          	lhu	a5,74(s2)
    80005b72:	37fd                	addiw	a5,a5,-1
    80005b74:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b78:	854a                	mv	a0,s2
    80005b7a:	ffffe097          	auipc	ra,0xffffe
    80005b7e:	090080e7          	jalr	144(ra) # 80003c0a <iupdate>
  iunlockput(ip);
    80005b82:	854a                	mv	a0,s2
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	3b2080e7          	jalr	946(ra) # 80003f36 <iunlockput>
  end_op();
    80005b8c:	fffff097          	auipc	ra,0xfffff
    80005b90:	b9e080e7          	jalr	-1122(ra) # 8000472a <end_op>
  return 0;
    80005b94:	4501                	li	a0,0
    80005b96:	a84d                	j	80005c48 <sys_unlink+0x1c4>
    end_op();
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	b92080e7          	jalr	-1134(ra) # 8000472a <end_op>
    return -1;
    80005ba0:	557d                	li	a0,-1
    80005ba2:	a05d                	j	80005c48 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005ba4:	00003517          	auipc	a0,0x3
    80005ba8:	bc450513          	addi	a0,a0,-1084 # 80008768 <syscalls+0x338>
    80005bac:	ffffb097          	auipc	ra,0xffffb
    80005bb0:	97e080e7          	jalr	-1666(ra) # 8000052a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bb4:	04c92703          	lw	a4,76(s2)
    80005bb8:	02000793          	li	a5,32
    80005bbc:	f6e7f9e3          	bgeu	a5,a4,80005b2e <sys_unlink+0xaa>
    80005bc0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005bc4:	4741                	li	a4,16
    80005bc6:	86ce                	mv	a3,s3
    80005bc8:	f1840613          	addi	a2,s0,-232
    80005bcc:	4581                	li	a1,0
    80005bce:	854a                	mv	a0,s2
    80005bd0:	ffffe097          	auipc	ra,0xffffe
    80005bd4:	3b8080e7          	jalr	952(ra) # 80003f88 <readi>
    80005bd8:	47c1                	li	a5,16
    80005bda:	00f51b63          	bne	a0,a5,80005bf0 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005bde:	f1845783          	lhu	a5,-232(s0)
    80005be2:	e7a1                	bnez	a5,80005c2a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005be4:	29c1                	addiw	s3,s3,16
    80005be6:	04c92783          	lw	a5,76(s2)
    80005bea:	fcf9ede3          	bltu	s3,a5,80005bc4 <sys_unlink+0x140>
    80005bee:	b781                	j	80005b2e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005bf0:	00003517          	auipc	a0,0x3
    80005bf4:	b9050513          	addi	a0,a0,-1136 # 80008780 <syscalls+0x350>
    80005bf8:	ffffb097          	auipc	ra,0xffffb
    80005bfc:	932080e7          	jalr	-1742(ra) # 8000052a <panic>
    panic("unlink: writei");
    80005c00:	00003517          	auipc	a0,0x3
    80005c04:	b9850513          	addi	a0,a0,-1128 # 80008798 <syscalls+0x368>
    80005c08:	ffffb097          	auipc	ra,0xffffb
    80005c0c:	922080e7          	jalr	-1758(ra) # 8000052a <panic>
    dp->nlink--;
    80005c10:	04a4d783          	lhu	a5,74(s1)
    80005c14:	37fd                	addiw	a5,a5,-1
    80005c16:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c1a:	8526                	mv	a0,s1
    80005c1c:	ffffe097          	auipc	ra,0xffffe
    80005c20:	fee080e7          	jalr	-18(ra) # 80003c0a <iupdate>
    80005c24:	b781                	j	80005b64 <sys_unlink+0xe0>
    return -1;
    80005c26:	557d                	li	a0,-1
    80005c28:	a005                	j	80005c48 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005c2a:	854a                	mv	a0,s2
    80005c2c:	ffffe097          	auipc	ra,0xffffe
    80005c30:	30a080e7          	jalr	778(ra) # 80003f36 <iunlockput>
  iunlockput(dp);
    80005c34:	8526                	mv	a0,s1
    80005c36:	ffffe097          	auipc	ra,0xffffe
    80005c3a:	300080e7          	jalr	768(ra) # 80003f36 <iunlockput>
  end_op();
    80005c3e:	fffff097          	auipc	ra,0xfffff
    80005c42:	aec080e7          	jalr	-1300(ra) # 8000472a <end_op>
  return -1;
    80005c46:	557d                	li	a0,-1
}
    80005c48:	70ae                	ld	ra,232(sp)
    80005c4a:	740e                	ld	s0,224(sp)
    80005c4c:	64ee                	ld	s1,216(sp)
    80005c4e:	694e                	ld	s2,208(sp)
    80005c50:	69ae                	ld	s3,200(sp)
    80005c52:	616d                	addi	sp,sp,240
    80005c54:	8082                	ret

0000000080005c56 <sys_open>:

uint64
sys_open(void)
{
    80005c56:	7131                	addi	sp,sp,-192
    80005c58:	fd06                	sd	ra,184(sp)
    80005c5a:	f922                	sd	s0,176(sp)
    80005c5c:	f526                	sd	s1,168(sp)
    80005c5e:	f14a                	sd	s2,160(sp)
    80005c60:	ed4e                	sd	s3,152(sp)
    80005c62:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c64:	08000613          	li	a2,128
    80005c68:	f5040593          	addi	a1,s0,-176
    80005c6c:	4501                	li	a0,0
    80005c6e:	ffffd097          	auipc	ra,0xffffd
    80005c72:	2d2080e7          	jalr	722(ra) # 80002f40 <argstr>
    return -1;
    80005c76:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c78:	0c054163          	bltz	a0,80005d3a <sys_open+0xe4>
    80005c7c:	f4c40593          	addi	a1,s0,-180
    80005c80:	4505                	li	a0,1
    80005c82:	ffffd097          	auipc	ra,0xffffd
    80005c86:	27a080e7          	jalr	634(ra) # 80002efc <argint>
    80005c8a:	0a054863          	bltz	a0,80005d3a <sys_open+0xe4>

  begin_op();
    80005c8e:	fffff097          	auipc	ra,0xfffff
    80005c92:	a1c080e7          	jalr	-1508(ra) # 800046aa <begin_op>

  if(omode & O_CREATE){
    80005c96:	f4c42783          	lw	a5,-180(s0)
    80005c9a:	2007f793          	andi	a5,a5,512
    80005c9e:	cbdd                	beqz	a5,80005d54 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005ca0:	4681                	li	a3,0
    80005ca2:	4601                	li	a2,0
    80005ca4:	4589                	li	a1,2
    80005ca6:	f5040513          	addi	a0,s0,-176
    80005caa:	00000097          	auipc	ra,0x0
    80005cae:	974080e7          	jalr	-1676(ra) # 8000561e <create>
    80005cb2:	892a                	mv	s2,a0
    if(ip == 0){
    80005cb4:	c959                	beqz	a0,80005d4a <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005cb6:	04491703          	lh	a4,68(s2)
    80005cba:	478d                	li	a5,3
    80005cbc:	00f71763          	bne	a4,a5,80005cca <sys_open+0x74>
    80005cc0:	04695703          	lhu	a4,70(s2)
    80005cc4:	47a5                	li	a5,9
    80005cc6:	0ce7ec63          	bltu	a5,a4,80005d9e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005cca:	fffff097          	auipc	ra,0xfffff
    80005cce:	df0080e7          	jalr	-528(ra) # 80004aba <filealloc>
    80005cd2:	89aa                	mv	s3,a0
    80005cd4:	10050263          	beqz	a0,80005dd8 <sys_open+0x182>
    80005cd8:	00000097          	auipc	ra,0x0
    80005cdc:	904080e7          	jalr	-1788(ra) # 800055dc <fdalloc>
    80005ce0:	84aa                	mv	s1,a0
    80005ce2:	0e054663          	bltz	a0,80005dce <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ce6:	04491703          	lh	a4,68(s2)
    80005cea:	478d                	li	a5,3
    80005cec:	0cf70463          	beq	a4,a5,80005db4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005cf0:	4789                	li	a5,2
    80005cf2:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005cf6:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005cfa:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005cfe:	f4c42783          	lw	a5,-180(s0)
    80005d02:	0017c713          	xori	a4,a5,1
    80005d06:	8b05                	andi	a4,a4,1
    80005d08:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005d0c:	0037f713          	andi	a4,a5,3
    80005d10:	00e03733          	snez	a4,a4
    80005d14:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005d18:	4007f793          	andi	a5,a5,1024
    80005d1c:	c791                	beqz	a5,80005d28 <sys_open+0xd2>
    80005d1e:	04491703          	lh	a4,68(s2)
    80005d22:	4789                	li	a5,2
    80005d24:	08f70f63          	beq	a4,a5,80005dc2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005d28:	854a                	mv	a0,s2
    80005d2a:	ffffe097          	auipc	ra,0xffffe
    80005d2e:	06c080e7          	jalr	108(ra) # 80003d96 <iunlock>
  end_op();
    80005d32:	fffff097          	auipc	ra,0xfffff
    80005d36:	9f8080e7          	jalr	-1544(ra) # 8000472a <end_op>

  return fd;
}
    80005d3a:	8526                	mv	a0,s1
    80005d3c:	70ea                	ld	ra,184(sp)
    80005d3e:	744a                	ld	s0,176(sp)
    80005d40:	74aa                	ld	s1,168(sp)
    80005d42:	790a                	ld	s2,160(sp)
    80005d44:	69ea                	ld	s3,152(sp)
    80005d46:	6129                	addi	sp,sp,192
    80005d48:	8082                	ret
      end_op();
    80005d4a:	fffff097          	auipc	ra,0xfffff
    80005d4e:	9e0080e7          	jalr	-1568(ra) # 8000472a <end_op>
      return -1;
    80005d52:	b7e5                	j	80005d3a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005d54:	f5040513          	addi	a0,s0,-176
    80005d58:	ffffe097          	auipc	ra,0xffffe
    80005d5c:	732080e7          	jalr	1842(ra) # 8000448a <namei>
    80005d60:	892a                	mv	s2,a0
    80005d62:	c905                	beqz	a0,80005d92 <sys_open+0x13c>
    ilock(ip);
    80005d64:	ffffe097          	auipc	ra,0xffffe
    80005d68:	f70080e7          	jalr	-144(ra) # 80003cd4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d6c:	04491703          	lh	a4,68(s2)
    80005d70:	4785                	li	a5,1
    80005d72:	f4f712e3          	bne	a4,a5,80005cb6 <sys_open+0x60>
    80005d76:	f4c42783          	lw	a5,-180(s0)
    80005d7a:	dba1                	beqz	a5,80005cca <sys_open+0x74>
      iunlockput(ip);
    80005d7c:	854a                	mv	a0,s2
    80005d7e:	ffffe097          	auipc	ra,0xffffe
    80005d82:	1b8080e7          	jalr	440(ra) # 80003f36 <iunlockput>
      end_op();
    80005d86:	fffff097          	auipc	ra,0xfffff
    80005d8a:	9a4080e7          	jalr	-1628(ra) # 8000472a <end_op>
      return -1;
    80005d8e:	54fd                	li	s1,-1
    80005d90:	b76d                	j	80005d3a <sys_open+0xe4>
      end_op();
    80005d92:	fffff097          	auipc	ra,0xfffff
    80005d96:	998080e7          	jalr	-1640(ra) # 8000472a <end_op>
      return -1;
    80005d9a:	54fd                	li	s1,-1
    80005d9c:	bf79                	j	80005d3a <sys_open+0xe4>
    iunlockput(ip);
    80005d9e:	854a                	mv	a0,s2
    80005da0:	ffffe097          	auipc	ra,0xffffe
    80005da4:	196080e7          	jalr	406(ra) # 80003f36 <iunlockput>
    end_op();
    80005da8:	fffff097          	auipc	ra,0xfffff
    80005dac:	982080e7          	jalr	-1662(ra) # 8000472a <end_op>
    return -1;
    80005db0:	54fd                	li	s1,-1
    80005db2:	b761                	j	80005d3a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005db4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005db8:	04691783          	lh	a5,70(s2)
    80005dbc:	02f99223          	sh	a5,36(s3)
    80005dc0:	bf2d                	j	80005cfa <sys_open+0xa4>
    itrunc(ip);
    80005dc2:	854a                	mv	a0,s2
    80005dc4:	ffffe097          	auipc	ra,0xffffe
    80005dc8:	01e080e7          	jalr	30(ra) # 80003de2 <itrunc>
    80005dcc:	bfb1                	j	80005d28 <sys_open+0xd2>
      fileclose(f);
    80005dce:	854e                	mv	a0,s3
    80005dd0:	fffff097          	auipc	ra,0xfffff
    80005dd4:	da6080e7          	jalr	-602(ra) # 80004b76 <fileclose>
    iunlockput(ip);
    80005dd8:	854a                	mv	a0,s2
    80005dda:	ffffe097          	auipc	ra,0xffffe
    80005dde:	15c080e7          	jalr	348(ra) # 80003f36 <iunlockput>
    end_op();
    80005de2:	fffff097          	auipc	ra,0xfffff
    80005de6:	948080e7          	jalr	-1720(ra) # 8000472a <end_op>
    return -1;
    80005dea:	54fd                	li	s1,-1
    80005dec:	b7b9                	j	80005d3a <sys_open+0xe4>

0000000080005dee <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005dee:	7175                	addi	sp,sp,-144
    80005df0:	e506                	sd	ra,136(sp)
    80005df2:	e122                	sd	s0,128(sp)
    80005df4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005df6:	fffff097          	auipc	ra,0xfffff
    80005dfa:	8b4080e7          	jalr	-1868(ra) # 800046aa <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005dfe:	08000613          	li	a2,128
    80005e02:	f7040593          	addi	a1,s0,-144
    80005e06:	4501                	li	a0,0
    80005e08:	ffffd097          	auipc	ra,0xffffd
    80005e0c:	138080e7          	jalr	312(ra) # 80002f40 <argstr>
    80005e10:	02054963          	bltz	a0,80005e42 <sys_mkdir+0x54>
    80005e14:	4681                	li	a3,0
    80005e16:	4601                	li	a2,0
    80005e18:	4585                	li	a1,1
    80005e1a:	f7040513          	addi	a0,s0,-144
    80005e1e:	00000097          	auipc	ra,0x0
    80005e22:	800080e7          	jalr	-2048(ra) # 8000561e <create>
    80005e26:	cd11                	beqz	a0,80005e42 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e28:	ffffe097          	auipc	ra,0xffffe
    80005e2c:	10e080e7          	jalr	270(ra) # 80003f36 <iunlockput>
  end_op();
    80005e30:	fffff097          	auipc	ra,0xfffff
    80005e34:	8fa080e7          	jalr	-1798(ra) # 8000472a <end_op>
  return 0;
    80005e38:	4501                	li	a0,0
}
    80005e3a:	60aa                	ld	ra,136(sp)
    80005e3c:	640a                	ld	s0,128(sp)
    80005e3e:	6149                	addi	sp,sp,144
    80005e40:	8082                	ret
    end_op();
    80005e42:	fffff097          	auipc	ra,0xfffff
    80005e46:	8e8080e7          	jalr	-1816(ra) # 8000472a <end_op>
    return -1;
    80005e4a:	557d                	li	a0,-1
    80005e4c:	b7fd                	j	80005e3a <sys_mkdir+0x4c>

0000000080005e4e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e4e:	7135                	addi	sp,sp,-160
    80005e50:	ed06                	sd	ra,152(sp)
    80005e52:	e922                	sd	s0,144(sp)
    80005e54:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e56:	fffff097          	auipc	ra,0xfffff
    80005e5a:	854080e7          	jalr	-1964(ra) # 800046aa <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e5e:	08000613          	li	a2,128
    80005e62:	f7040593          	addi	a1,s0,-144
    80005e66:	4501                	li	a0,0
    80005e68:	ffffd097          	auipc	ra,0xffffd
    80005e6c:	0d8080e7          	jalr	216(ra) # 80002f40 <argstr>
    80005e70:	04054a63          	bltz	a0,80005ec4 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005e74:	f6c40593          	addi	a1,s0,-148
    80005e78:	4505                	li	a0,1
    80005e7a:	ffffd097          	auipc	ra,0xffffd
    80005e7e:	082080e7          	jalr	130(ra) # 80002efc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e82:	04054163          	bltz	a0,80005ec4 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005e86:	f6840593          	addi	a1,s0,-152
    80005e8a:	4509                	li	a0,2
    80005e8c:	ffffd097          	auipc	ra,0xffffd
    80005e90:	070080e7          	jalr	112(ra) # 80002efc <argint>
     argint(1, &major) < 0 ||
    80005e94:	02054863          	bltz	a0,80005ec4 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e98:	f6841683          	lh	a3,-152(s0)
    80005e9c:	f6c41603          	lh	a2,-148(s0)
    80005ea0:	458d                	li	a1,3
    80005ea2:	f7040513          	addi	a0,s0,-144
    80005ea6:	fffff097          	auipc	ra,0xfffff
    80005eaa:	778080e7          	jalr	1912(ra) # 8000561e <create>
     argint(2, &minor) < 0 ||
    80005eae:	c919                	beqz	a0,80005ec4 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005eb0:	ffffe097          	auipc	ra,0xffffe
    80005eb4:	086080e7          	jalr	134(ra) # 80003f36 <iunlockput>
  end_op();
    80005eb8:	fffff097          	auipc	ra,0xfffff
    80005ebc:	872080e7          	jalr	-1934(ra) # 8000472a <end_op>
  return 0;
    80005ec0:	4501                	li	a0,0
    80005ec2:	a031                	j	80005ece <sys_mknod+0x80>
    end_op();
    80005ec4:	fffff097          	auipc	ra,0xfffff
    80005ec8:	866080e7          	jalr	-1946(ra) # 8000472a <end_op>
    return -1;
    80005ecc:	557d                	li	a0,-1
}
    80005ece:	60ea                	ld	ra,152(sp)
    80005ed0:	644a                	ld	s0,144(sp)
    80005ed2:	610d                	addi	sp,sp,160
    80005ed4:	8082                	ret

0000000080005ed6 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005ed6:	7135                	addi	sp,sp,-160
    80005ed8:	ed06                	sd	ra,152(sp)
    80005eda:	e922                	sd	s0,144(sp)
    80005edc:	e526                	sd	s1,136(sp)
    80005ede:	e14a                	sd	s2,128(sp)
    80005ee0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ee2:	ffffc097          	auipc	ra,0xffffc
    80005ee6:	a9c080e7          	jalr	-1380(ra) # 8000197e <myproc>
    80005eea:	892a                	mv	s2,a0
  
  begin_op();
    80005eec:	ffffe097          	auipc	ra,0xffffe
    80005ef0:	7be080e7          	jalr	1982(ra) # 800046aa <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ef4:	08000613          	li	a2,128
    80005ef8:	f6040593          	addi	a1,s0,-160
    80005efc:	4501                	li	a0,0
    80005efe:	ffffd097          	auipc	ra,0xffffd
    80005f02:	042080e7          	jalr	66(ra) # 80002f40 <argstr>
    80005f06:	04054b63          	bltz	a0,80005f5c <sys_chdir+0x86>
    80005f0a:	f6040513          	addi	a0,s0,-160
    80005f0e:	ffffe097          	auipc	ra,0xffffe
    80005f12:	57c080e7          	jalr	1404(ra) # 8000448a <namei>
    80005f16:	84aa                	mv	s1,a0
    80005f18:	c131                	beqz	a0,80005f5c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005f1a:	ffffe097          	auipc	ra,0xffffe
    80005f1e:	dba080e7          	jalr	-582(ra) # 80003cd4 <ilock>
  if(ip->type != T_DIR){
    80005f22:	04449703          	lh	a4,68(s1)
    80005f26:	4785                	li	a5,1
    80005f28:	04f71063          	bne	a4,a5,80005f68 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f2c:	8526                	mv	a0,s1
    80005f2e:	ffffe097          	auipc	ra,0xffffe
    80005f32:	e68080e7          	jalr	-408(ra) # 80003d96 <iunlock>
  iput(p->cwd);
    80005f36:	15093503          	ld	a0,336(s2)
    80005f3a:	ffffe097          	auipc	ra,0xffffe
    80005f3e:	f54080e7          	jalr	-172(ra) # 80003e8e <iput>
  end_op();
    80005f42:	ffffe097          	auipc	ra,0xffffe
    80005f46:	7e8080e7          	jalr	2024(ra) # 8000472a <end_op>
  p->cwd = ip;
    80005f4a:	14993823          	sd	s1,336(s2)
  return 0;
    80005f4e:	4501                	li	a0,0
}
    80005f50:	60ea                	ld	ra,152(sp)
    80005f52:	644a                	ld	s0,144(sp)
    80005f54:	64aa                	ld	s1,136(sp)
    80005f56:	690a                	ld	s2,128(sp)
    80005f58:	610d                	addi	sp,sp,160
    80005f5a:	8082                	ret
    end_op();
    80005f5c:	ffffe097          	auipc	ra,0xffffe
    80005f60:	7ce080e7          	jalr	1998(ra) # 8000472a <end_op>
    return -1;
    80005f64:	557d                	li	a0,-1
    80005f66:	b7ed                	j	80005f50 <sys_chdir+0x7a>
    iunlockput(ip);
    80005f68:	8526                	mv	a0,s1
    80005f6a:	ffffe097          	auipc	ra,0xffffe
    80005f6e:	fcc080e7          	jalr	-52(ra) # 80003f36 <iunlockput>
    end_op();
    80005f72:	ffffe097          	auipc	ra,0xffffe
    80005f76:	7b8080e7          	jalr	1976(ra) # 8000472a <end_op>
    return -1;
    80005f7a:	557d                	li	a0,-1
    80005f7c:	bfd1                	j	80005f50 <sys_chdir+0x7a>

0000000080005f7e <sys_exec>:

uint64
sys_exec(void)
{
    80005f7e:	7145                	addi	sp,sp,-464
    80005f80:	e786                	sd	ra,456(sp)
    80005f82:	e3a2                	sd	s0,448(sp)
    80005f84:	ff26                	sd	s1,440(sp)
    80005f86:	fb4a                	sd	s2,432(sp)
    80005f88:	f74e                	sd	s3,424(sp)
    80005f8a:	f352                	sd	s4,416(sp)
    80005f8c:	ef56                	sd	s5,408(sp)
    80005f8e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005f90:	08000613          	li	a2,128
    80005f94:	f4040593          	addi	a1,s0,-192
    80005f98:	4501                	li	a0,0
    80005f9a:	ffffd097          	auipc	ra,0xffffd
    80005f9e:	fa6080e7          	jalr	-90(ra) # 80002f40 <argstr>
    return -1;
    80005fa2:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005fa4:	0c054a63          	bltz	a0,80006078 <sys_exec+0xfa>
    80005fa8:	e3840593          	addi	a1,s0,-456
    80005fac:	4505                	li	a0,1
    80005fae:	ffffd097          	auipc	ra,0xffffd
    80005fb2:	f70080e7          	jalr	-144(ra) # 80002f1e <argaddr>
    80005fb6:	0c054163          	bltz	a0,80006078 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005fba:	10000613          	li	a2,256
    80005fbe:	4581                	li	a1,0
    80005fc0:	e4040513          	addi	a0,s0,-448
    80005fc4:	ffffb097          	auipc	ra,0xffffb
    80005fc8:	cfa080e7          	jalr	-774(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005fcc:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005fd0:	89a6                	mv	s3,s1
    80005fd2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005fd4:	02000a13          	li	s4,32
    80005fd8:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005fdc:	00391793          	slli	a5,s2,0x3
    80005fe0:	e3040593          	addi	a1,s0,-464
    80005fe4:	e3843503          	ld	a0,-456(s0)
    80005fe8:	953e                	add	a0,a0,a5
    80005fea:	ffffd097          	auipc	ra,0xffffd
    80005fee:	e78080e7          	jalr	-392(ra) # 80002e62 <fetchaddr>
    80005ff2:	02054a63          	bltz	a0,80006026 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005ff6:	e3043783          	ld	a5,-464(s0)
    80005ffa:	c3b9                	beqz	a5,80006040 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ffc:	ffffb097          	auipc	ra,0xffffb
    80006000:	ad6080e7          	jalr	-1322(ra) # 80000ad2 <kalloc>
    80006004:	85aa                	mv	a1,a0
    80006006:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000600a:	cd11                	beqz	a0,80006026 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000600c:	6605                	lui	a2,0x1
    8000600e:	e3043503          	ld	a0,-464(s0)
    80006012:	ffffd097          	auipc	ra,0xffffd
    80006016:	ea2080e7          	jalr	-350(ra) # 80002eb4 <fetchstr>
    8000601a:	00054663          	bltz	a0,80006026 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    8000601e:	0905                	addi	s2,s2,1
    80006020:	09a1                	addi	s3,s3,8
    80006022:	fb491be3          	bne	s2,s4,80005fd8 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006026:	10048913          	addi	s2,s1,256
    8000602a:	6088                	ld	a0,0(s1)
    8000602c:	c529                	beqz	a0,80006076 <sys_exec+0xf8>
    kfree(argv[i]);
    8000602e:	ffffb097          	auipc	ra,0xffffb
    80006032:	9a8080e7          	jalr	-1624(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006036:	04a1                	addi	s1,s1,8
    80006038:	ff2499e3          	bne	s1,s2,8000602a <sys_exec+0xac>
  return -1;
    8000603c:	597d                	li	s2,-1
    8000603e:	a82d                	j	80006078 <sys_exec+0xfa>
      argv[i] = 0;
    80006040:	0a8e                	slli	s5,s5,0x3
    80006042:	fc040793          	addi	a5,s0,-64
    80006046:	9abe                	add	s5,s5,a5
    80006048:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000604c:	e4040593          	addi	a1,s0,-448
    80006050:	f4040513          	addi	a0,s0,-192
    80006054:	fffff097          	auipc	ra,0xfffff
    80006058:	174080e7          	jalr	372(ra) # 800051c8 <exec>
    8000605c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000605e:	10048993          	addi	s3,s1,256
    80006062:	6088                	ld	a0,0(s1)
    80006064:	c911                	beqz	a0,80006078 <sys_exec+0xfa>
    kfree(argv[i]);
    80006066:	ffffb097          	auipc	ra,0xffffb
    8000606a:	970080e7          	jalr	-1680(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000606e:	04a1                	addi	s1,s1,8
    80006070:	ff3499e3          	bne	s1,s3,80006062 <sys_exec+0xe4>
    80006074:	a011                	j	80006078 <sys_exec+0xfa>
  return -1;
    80006076:	597d                	li	s2,-1
}
    80006078:	854a                	mv	a0,s2
    8000607a:	60be                	ld	ra,456(sp)
    8000607c:	641e                	ld	s0,448(sp)
    8000607e:	74fa                	ld	s1,440(sp)
    80006080:	795a                	ld	s2,432(sp)
    80006082:	79ba                	ld	s3,424(sp)
    80006084:	7a1a                	ld	s4,416(sp)
    80006086:	6afa                	ld	s5,408(sp)
    80006088:	6179                	addi	sp,sp,464
    8000608a:	8082                	ret

000000008000608c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000608c:	7139                	addi	sp,sp,-64
    8000608e:	fc06                	sd	ra,56(sp)
    80006090:	f822                	sd	s0,48(sp)
    80006092:	f426                	sd	s1,40(sp)
    80006094:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006096:	ffffc097          	auipc	ra,0xffffc
    8000609a:	8e8080e7          	jalr	-1816(ra) # 8000197e <myproc>
    8000609e:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800060a0:	fd840593          	addi	a1,s0,-40
    800060a4:	4501                	li	a0,0
    800060a6:	ffffd097          	auipc	ra,0xffffd
    800060aa:	e78080e7          	jalr	-392(ra) # 80002f1e <argaddr>
    return -1;
    800060ae:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800060b0:	0e054063          	bltz	a0,80006190 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800060b4:	fc840593          	addi	a1,s0,-56
    800060b8:	fd040513          	addi	a0,s0,-48
    800060bc:	fffff097          	auipc	ra,0xfffff
    800060c0:	dea080e7          	jalr	-534(ra) # 80004ea6 <pipealloc>
    return -1;
    800060c4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800060c6:	0c054563          	bltz	a0,80006190 <sys_pipe+0x104>
  fd0 = -1;
    800060ca:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800060ce:	fd043503          	ld	a0,-48(s0)
    800060d2:	fffff097          	auipc	ra,0xfffff
    800060d6:	50a080e7          	jalr	1290(ra) # 800055dc <fdalloc>
    800060da:	fca42223          	sw	a0,-60(s0)
    800060de:	08054c63          	bltz	a0,80006176 <sys_pipe+0xea>
    800060e2:	fc843503          	ld	a0,-56(s0)
    800060e6:	fffff097          	auipc	ra,0xfffff
    800060ea:	4f6080e7          	jalr	1270(ra) # 800055dc <fdalloc>
    800060ee:	fca42023          	sw	a0,-64(s0)
    800060f2:	06054863          	bltz	a0,80006162 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060f6:	4691                	li	a3,4
    800060f8:	fc440613          	addi	a2,s0,-60
    800060fc:	fd843583          	ld	a1,-40(s0)
    80006100:	68a8                	ld	a0,80(s1)
    80006102:	ffffb097          	auipc	ra,0xffffb
    80006106:	53c080e7          	jalr	1340(ra) # 8000163e <copyout>
    8000610a:	02054063          	bltz	a0,8000612a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000610e:	4691                	li	a3,4
    80006110:	fc040613          	addi	a2,s0,-64
    80006114:	fd843583          	ld	a1,-40(s0)
    80006118:	0591                	addi	a1,a1,4
    8000611a:	68a8                	ld	a0,80(s1)
    8000611c:	ffffb097          	auipc	ra,0xffffb
    80006120:	522080e7          	jalr	1314(ra) # 8000163e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006124:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006126:	06055563          	bgez	a0,80006190 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    8000612a:	fc442783          	lw	a5,-60(s0)
    8000612e:	07e9                	addi	a5,a5,26
    80006130:	078e                	slli	a5,a5,0x3
    80006132:	97a6                	add	a5,a5,s1
    80006134:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006138:	fc042503          	lw	a0,-64(s0)
    8000613c:	0569                	addi	a0,a0,26
    8000613e:	050e                	slli	a0,a0,0x3
    80006140:	9526                	add	a0,a0,s1
    80006142:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006146:	fd043503          	ld	a0,-48(s0)
    8000614a:	fffff097          	auipc	ra,0xfffff
    8000614e:	a2c080e7          	jalr	-1492(ra) # 80004b76 <fileclose>
    fileclose(wf);
    80006152:	fc843503          	ld	a0,-56(s0)
    80006156:	fffff097          	auipc	ra,0xfffff
    8000615a:	a20080e7          	jalr	-1504(ra) # 80004b76 <fileclose>
    return -1;
    8000615e:	57fd                	li	a5,-1
    80006160:	a805                	j	80006190 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006162:	fc442783          	lw	a5,-60(s0)
    80006166:	0007c863          	bltz	a5,80006176 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    8000616a:	01a78513          	addi	a0,a5,26
    8000616e:	050e                	slli	a0,a0,0x3
    80006170:	9526                	add	a0,a0,s1
    80006172:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006176:	fd043503          	ld	a0,-48(s0)
    8000617a:	fffff097          	auipc	ra,0xfffff
    8000617e:	9fc080e7          	jalr	-1540(ra) # 80004b76 <fileclose>
    fileclose(wf);
    80006182:	fc843503          	ld	a0,-56(s0)
    80006186:	fffff097          	auipc	ra,0xfffff
    8000618a:	9f0080e7          	jalr	-1552(ra) # 80004b76 <fileclose>
    return -1;
    8000618e:	57fd                	li	a5,-1
}
    80006190:	853e                	mv	a0,a5
    80006192:	70e2                	ld	ra,56(sp)
    80006194:	7442                	ld	s0,48(sp)
    80006196:	74a2                	ld	s1,40(sp)
    80006198:	6121                	addi	sp,sp,64
    8000619a:	8082                	ret
    8000619c:	0000                	unimp
	...

00000000800061a0 <kernelvec>:
    800061a0:	7111                	addi	sp,sp,-256
    800061a2:	e006                	sd	ra,0(sp)
    800061a4:	e40a                	sd	sp,8(sp)
    800061a6:	e80e                	sd	gp,16(sp)
    800061a8:	ec12                	sd	tp,24(sp)
    800061aa:	f016                	sd	t0,32(sp)
    800061ac:	f41a                	sd	t1,40(sp)
    800061ae:	f81e                	sd	t2,48(sp)
    800061b0:	fc22                	sd	s0,56(sp)
    800061b2:	e0a6                	sd	s1,64(sp)
    800061b4:	e4aa                	sd	a0,72(sp)
    800061b6:	e8ae                	sd	a1,80(sp)
    800061b8:	ecb2                	sd	a2,88(sp)
    800061ba:	f0b6                	sd	a3,96(sp)
    800061bc:	f4ba                	sd	a4,104(sp)
    800061be:	f8be                	sd	a5,112(sp)
    800061c0:	fcc2                	sd	a6,120(sp)
    800061c2:	e146                	sd	a7,128(sp)
    800061c4:	e54a                	sd	s2,136(sp)
    800061c6:	e94e                	sd	s3,144(sp)
    800061c8:	ed52                	sd	s4,152(sp)
    800061ca:	f156                	sd	s5,160(sp)
    800061cc:	f55a                	sd	s6,168(sp)
    800061ce:	f95e                	sd	s7,176(sp)
    800061d0:	fd62                	sd	s8,184(sp)
    800061d2:	e1e6                	sd	s9,192(sp)
    800061d4:	e5ea                	sd	s10,200(sp)
    800061d6:	e9ee                	sd	s11,208(sp)
    800061d8:	edf2                	sd	t3,216(sp)
    800061da:	f1f6                	sd	t4,224(sp)
    800061dc:	f5fa                	sd	t5,232(sp)
    800061de:	f9fe                	sd	t6,240(sp)
    800061e0:	b4ffc0ef          	jal	ra,80002d2e <kerneltrap>
    800061e4:	6082                	ld	ra,0(sp)
    800061e6:	6122                	ld	sp,8(sp)
    800061e8:	61c2                	ld	gp,16(sp)
    800061ea:	7282                	ld	t0,32(sp)
    800061ec:	7322                	ld	t1,40(sp)
    800061ee:	73c2                	ld	t2,48(sp)
    800061f0:	7462                	ld	s0,56(sp)
    800061f2:	6486                	ld	s1,64(sp)
    800061f4:	6526                	ld	a0,72(sp)
    800061f6:	65c6                	ld	a1,80(sp)
    800061f8:	6666                	ld	a2,88(sp)
    800061fa:	7686                	ld	a3,96(sp)
    800061fc:	7726                	ld	a4,104(sp)
    800061fe:	77c6                	ld	a5,112(sp)
    80006200:	7866                	ld	a6,120(sp)
    80006202:	688a                	ld	a7,128(sp)
    80006204:	692a                	ld	s2,136(sp)
    80006206:	69ca                	ld	s3,144(sp)
    80006208:	6a6a                	ld	s4,152(sp)
    8000620a:	7a8a                	ld	s5,160(sp)
    8000620c:	7b2a                	ld	s6,168(sp)
    8000620e:	7bca                	ld	s7,176(sp)
    80006210:	7c6a                	ld	s8,184(sp)
    80006212:	6c8e                	ld	s9,192(sp)
    80006214:	6d2e                	ld	s10,200(sp)
    80006216:	6dce                	ld	s11,208(sp)
    80006218:	6e6e                	ld	t3,216(sp)
    8000621a:	7e8e                	ld	t4,224(sp)
    8000621c:	7f2e                	ld	t5,232(sp)
    8000621e:	7fce                	ld	t6,240(sp)
    80006220:	6111                	addi	sp,sp,256
    80006222:	10200073          	sret
    80006226:	00000013          	nop
    8000622a:	00000013          	nop
    8000622e:	0001                	nop

0000000080006230 <timervec>:
    80006230:	34051573          	csrrw	a0,mscratch,a0
    80006234:	e10c                	sd	a1,0(a0)
    80006236:	e510                	sd	a2,8(a0)
    80006238:	e914                	sd	a3,16(a0)
    8000623a:	6d0c                	ld	a1,24(a0)
    8000623c:	7110                	ld	a2,32(a0)
    8000623e:	6194                	ld	a3,0(a1)
    80006240:	96b2                	add	a3,a3,a2
    80006242:	e194                	sd	a3,0(a1)
    80006244:	4589                	li	a1,2
    80006246:	14459073          	csrw	sip,a1
    8000624a:	6914                	ld	a3,16(a0)
    8000624c:	6510                	ld	a2,8(a0)
    8000624e:	610c                	ld	a1,0(a0)
    80006250:	34051573          	csrrw	a0,mscratch,a0
    80006254:	30200073          	mret
	...

000000008000625a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000625a:	1141                	addi	sp,sp,-16
    8000625c:	e422                	sd	s0,8(sp)
    8000625e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006260:	0c0007b7          	lui	a5,0xc000
    80006264:	4705                	li	a4,1
    80006266:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006268:	c3d8                	sw	a4,4(a5)
}
    8000626a:	6422                	ld	s0,8(sp)
    8000626c:	0141                	addi	sp,sp,16
    8000626e:	8082                	ret

0000000080006270 <plicinithart>:

void
plicinithart(void)
{
    80006270:	1141                	addi	sp,sp,-16
    80006272:	e406                	sd	ra,8(sp)
    80006274:	e022                	sd	s0,0(sp)
    80006276:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006278:	ffffb097          	auipc	ra,0xffffb
    8000627c:	6da080e7          	jalr	1754(ra) # 80001952 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006280:	0085171b          	slliw	a4,a0,0x8
    80006284:	0c0027b7          	lui	a5,0xc002
    80006288:	97ba                	add	a5,a5,a4
    8000628a:	40200713          	li	a4,1026
    8000628e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006292:	00d5151b          	slliw	a0,a0,0xd
    80006296:	0c2017b7          	lui	a5,0xc201
    8000629a:	953e                	add	a0,a0,a5
    8000629c:	00052023          	sw	zero,0(a0)
}
    800062a0:	60a2                	ld	ra,8(sp)
    800062a2:	6402                	ld	s0,0(sp)
    800062a4:	0141                	addi	sp,sp,16
    800062a6:	8082                	ret

00000000800062a8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800062a8:	1141                	addi	sp,sp,-16
    800062aa:	e406                	sd	ra,8(sp)
    800062ac:	e022                	sd	s0,0(sp)
    800062ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062b0:	ffffb097          	auipc	ra,0xffffb
    800062b4:	6a2080e7          	jalr	1698(ra) # 80001952 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800062b8:	00d5179b          	slliw	a5,a0,0xd
    800062bc:	0c201537          	lui	a0,0xc201
    800062c0:	953e                	add	a0,a0,a5
  return irq;
}
    800062c2:	4148                	lw	a0,4(a0)
    800062c4:	60a2                	ld	ra,8(sp)
    800062c6:	6402                	ld	s0,0(sp)
    800062c8:	0141                	addi	sp,sp,16
    800062ca:	8082                	ret

00000000800062cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800062cc:	1101                	addi	sp,sp,-32
    800062ce:	ec06                	sd	ra,24(sp)
    800062d0:	e822                	sd	s0,16(sp)
    800062d2:	e426                	sd	s1,8(sp)
    800062d4:	1000                	addi	s0,sp,32
    800062d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800062d8:	ffffb097          	auipc	ra,0xffffb
    800062dc:	67a080e7          	jalr	1658(ra) # 80001952 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800062e0:	00d5151b          	slliw	a0,a0,0xd
    800062e4:	0c2017b7          	lui	a5,0xc201
    800062e8:	97aa                	add	a5,a5,a0
    800062ea:	c3c4                	sw	s1,4(a5)
}
    800062ec:	60e2                	ld	ra,24(sp)
    800062ee:	6442                	ld	s0,16(sp)
    800062f0:	64a2                	ld	s1,8(sp)
    800062f2:	6105                	addi	sp,sp,32
    800062f4:	8082                	ret

00000000800062f6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800062f6:	1141                	addi	sp,sp,-16
    800062f8:	e406                	sd	ra,8(sp)
    800062fa:	e022                	sd	s0,0(sp)
    800062fc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800062fe:	479d                	li	a5,7
    80006300:	06a7c963          	blt	a5,a0,80006372 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006304:	00023797          	auipc	a5,0x23
    80006308:	cfc78793          	addi	a5,a5,-772 # 80029000 <disk>
    8000630c:	00a78733          	add	a4,a5,a0
    80006310:	6789                	lui	a5,0x2
    80006312:	97ba                	add	a5,a5,a4
    80006314:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006318:	e7ad                	bnez	a5,80006382 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000631a:	00451793          	slli	a5,a0,0x4
    8000631e:	00025717          	auipc	a4,0x25
    80006322:	ce270713          	addi	a4,a4,-798 # 8002b000 <disk+0x2000>
    80006326:	6314                	ld	a3,0(a4)
    80006328:	96be                	add	a3,a3,a5
    8000632a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000632e:	6314                	ld	a3,0(a4)
    80006330:	96be                	add	a3,a3,a5
    80006332:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006336:	6314                	ld	a3,0(a4)
    80006338:	96be                	add	a3,a3,a5
    8000633a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000633e:	6318                	ld	a4,0(a4)
    80006340:	97ba                	add	a5,a5,a4
    80006342:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006346:	00023797          	auipc	a5,0x23
    8000634a:	cba78793          	addi	a5,a5,-838 # 80029000 <disk>
    8000634e:	97aa                	add	a5,a5,a0
    80006350:	6509                	lui	a0,0x2
    80006352:	953e                	add	a0,a0,a5
    80006354:	4785                	li	a5,1
    80006356:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000635a:	00025517          	auipc	a0,0x25
    8000635e:	cbe50513          	addi	a0,a0,-834 # 8002b018 <disk+0x2018>
    80006362:	ffffc097          	auipc	ra,0xffffc
    80006366:	ef8080e7          	jalr	-264(ra) # 8000225a <wakeup>
}
    8000636a:	60a2                	ld	ra,8(sp)
    8000636c:	6402                	ld	s0,0(sp)
    8000636e:	0141                	addi	sp,sp,16
    80006370:	8082                	ret
    panic("free_desc 1");
    80006372:	00002517          	auipc	a0,0x2
    80006376:	43650513          	addi	a0,a0,1078 # 800087a8 <syscalls+0x378>
    8000637a:	ffffa097          	auipc	ra,0xffffa
    8000637e:	1b0080e7          	jalr	432(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006382:	00002517          	auipc	a0,0x2
    80006386:	43650513          	addi	a0,a0,1078 # 800087b8 <syscalls+0x388>
    8000638a:	ffffa097          	auipc	ra,0xffffa
    8000638e:	1a0080e7          	jalr	416(ra) # 8000052a <panic>

0000000080006392 <virtio_disk_init>:
{
    80006392:	1101                	addi	sp,sp,-32
    80006394:	ec06                	sd	ra,24(sp)
    80006396:	e822                	sd	s0,16(sp)
    80006398:	e426                	sd	s1,8(sp)
    8000639a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000639c:	00002597          	auipc	a1,0x2
    800063a0:	42c58593          	addi	a1,a1,1068 # 800087c8 <syscalls+0x398>
    800063a4:	00025517          	auipc	a0,0x25
    800063a8:	d8450513          	addi	a0,a0,-636 # 8002b128 <disk+0x2128>
    800063ac:	ffffa097          	auipc	ra,0xffffa
    800063b0:	786080e7          	jalr	1926(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063b4:	100017b7          	lui	a5,0x10001
    800063b8:	4398                	lw	a4,0(a5)
    800063ba:	2701                	sext.w	a4,a4
    800063bc:	747277b7          	lui	a5,0x74727
    800063c0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800063c4:	0ef71163          	bne	a4,a5,800064a6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800063c8:	100017b7          	lui	a5,0x10001
    800063cc:	43dc                	lw	a5,4(a5)
    800063ce:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063d0:	4705                	li	a4,1
    800063d2:	0ce79a63          	bne	a5,a4,800064a6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063d6:	100017b7          	lui	a5,0x10001
    800063da:	479c                	lw	a5,8(a5)
    800063dc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800063de:	4709                	li	a4,2
    800063e0:	0ce79363          	bne	a5,a4,800064a6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800063e4:	100017b7          	lui	a5,0x10001
    800063e8:	47d8                	lw	a4,12(a5)
    800063ea:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063ec:	554d47b7          	lui	a5,0x554d4
    800063f0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800063f4:	0af71963          	bne	a4,a5,800064a6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063f8:	100017b7          	lui	a5,0x10001
    800063fc:	4705                	li	a4,1
    800063fe:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006400:	470d                	li	a4,3
    80006402:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006404:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006406:	c7ffe737          	lui	a4,0xc7ffe
    8000640a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd275f>
    8000640e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006410:	2701                	sext.w	a4,a4
    80006412:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006414:	472d                	li	a4,11
    80006416:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006418:	473d                	li	a4,15
    8000641a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000641c:	6705                	lui	a4,0x1
    8000641e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006420:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006424:	5bdc                	lw	a5,52(a5)
    80006426:	2781                	sext.w	a5,a5
  if(max == 0)
    80006428:	c7d9                	beqz	a5,800064b6 <virtio_disk_init+0x124>
  if(max < NUM)
    8000642a:	471d                	li	a4,7
    8000642c:	08f77d63          	bgeu	a4,a5,800064c6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006430:	100014b7          	lui	s1,0x10001
    80006434:	47a1                	li	a5,8
    80006436:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006438:	6609                	lui	a2,0x2
    8000643a:	4581                	li	a1,0
    8000643c:	00023517          	auipc	a0,0x23
    80006440:	bc450513          	addi	a0,a0,-1084 # 80029000 <disk>
    80006444:	ffffb097          	auipc	ra,0xffffb
    80006448:	87a080e7          	jalr	-1926(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000644c:	00023717          	auipc	a4,0x23
    80006450:	bb470713          	addi	a4,a4,-1100 # 80029000 <disk>
    80006454:	00c75793          	srli	a5,a4,0xc
    80006458:	2781                	sext.w	a5,a5
    8000645a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000645c:	00025797          	auipc	a5,0x25
    80006460:	ba478793          	addi	a5,a5,-1116 # 8002b000 <disk+0x2000>
    80006464:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006466:	00023717          	auipc	a4,0x23
    8000646a:	c1a70713          	addi	a4,a4,-998 # 80029080 <disk+0x80>
    8000646e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006470:	00024717          	auipc	a4,0x24
    80006474:	b9070713          	addi	a4,a4,-1136 # 8002a000 <disk+0x1000>
    80006478:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000647a:	4705                	li	a4,1
    8000647c:	00e78c23          	sb	a4,24(a5)
    80006480:	00e78ca3          	sb	a4,25(a5)
    80006484:	00e78d23          	sb	a4,26(a5)
    80006488:	00e78da3          	sb	a4,27(a5)
    8000648c:	00e78e23          	sb	a4,28(a5)
    80006490:	00e78ea3          	sb	a4,29(a5)
    80006494:	00e78f23          	sb	a4,30(a5)
    80006498:	00e78fa3          	sb	a4,31(a5)
}
    8000649c:	60e2                	ld	ra,24(sp)
    8000649e:	6442                	ld	s0,16(sp)
    800064a0:	64a2                	ld	s1,8(sp)
    800064a2:	6105                	addi	sp,sp,32
    800064a4:	8082                	ret
    panic("could not find virtio disk");
    800064a6:	00002517          	auipc	a0,0x2
    800064aa:	33250513          	addi	a0,a0,818 # 800087d8 <syscalls+0x3a8>
    800064ae:	ffffa097          	auipc	ra,0xffffa
    800064b2:	07c080e7          	jalr	124(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    800064b6:	00002517          	auipc	a0,0x2
    800064ba:	34250513          	addi	a0,a0,834 # 800087f8 <syscalls+0x3c8>
    800064be:	ffffa097          	auipc	ra,0xffffa
    800064c2:	06c080e7          	jalr	108(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    800064c6:	00002517          	auipc	a0,0x2
    800064ca:	35250513          	addi	a0,a0,850 # 80008818 <syscalls+0x3e8>
    800064ce:	ffffa097          	auipc	ra,0xffffa
    800064d2:	05c080e7          	jalr	92(ra) # 8000052a <panic>

00000000800064d6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800064d6:	7119                	addi	sp,sp,-128
    800064d8:	fc86                	sd	ra,120(sp)
    800064da:	f8a2                	sd	s0,112(sp)
    800064dc:	f4a6                	sd	s1,104(sp)
    800064de:	f0ca                	sd	s2,96(sp)
    800064e0:	ecce                	sd	s3,88(sp)
    800064e2:	e8d2                	sd	s4,80(sp)
    800064e4:	e4d6                	sd	s5,72(sp)
    800064e6:	e0da                	sd	s6,64(sp)
    800064e8:	fc5e                	sd	s7,56(sp)
    800064ea:	f862                	sd	s8,48(sp)
    800064ec:	f466                	sd	s9,40(sp)
    800064ee:	f06a                	sd	s10,32(sp)
    800064f0:	ec6e                	sd	s11,24(sp)
    800064f2:	0100                	addi	s0,sp,128
    800064f4:	8aaa                	mv	s5,a0
    800064f6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800064f8:	00c52c83          	lw	s9,12(a0)
    800064fc:	001c9c9b          	slliw	s9,s9,0x1
    80006500:	1c82                	slli	s9,s9,0x20
    80006502:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006506:	00025517          	auipc	a0,0x25
    8000650a:	c2250513          	addi	a0,a0,-990 # 8002b128 <disk+0x2128>
    8000650e:	ffffa097          	auipc	ra,0xffffa
    80006512:	6b4080e7          	jalr	1716(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006516:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006518:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000651a:	00023c17          	auipc	s8,0x23
    8000651e:	ae6c0c13          	addi	s8,s8,-1306 # 80029000 <disk>
    80006522:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006524:	4b0d                	li	s6,3
    80006526:	a0ad                	j	80006590 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006528:	00fc0733          	add	a4,s8,a5
    8000652c:	975e                	add	a4,a4,s7
    8000652e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006532:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006534:	0207c563          	bltz	a5,8000655e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006538:	2905                	addiw	s2,s2,1
    8000653a:	0611                	addi	a2,a2,4
    8000653c:	19690d63          	beq	s2,s6,800066d6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006540:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006542:	00025717          	auipc	a4,0x25
    80006546:	ad670713          	addi	a4,a4,-1322 # 8002b018 <disk+0x2018>
    8000654a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000654c:	00074683          	lbu	a3,0(a4)
    80006550:	fee1                	bnez	a3,80006528 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006552:	2785                	addiw	a5,a5,1
    80006554:	0705                	addi	a4,a4,1
    80006556:	fe979be3          	bne	a5,s1,8000654c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000655a:	57fd                	li	a5,-1
    8000655c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000655e:	01205d63          	blez	s2,80006578 <virtio_disk_rw+0xa2>
    80006562:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006564:	000a2503          	lw	a0,0(s4)
    80006568:	00000097          	auipc	ra,0x0
    8000656c:	d8e080e7          	jalr	-626(ra) # 800062f6 <free_desc>
      for(int j = 0; j < i; j++)
    80006570:	2d85                	addiw	s11,s11,1
    80006572:	0a11                	addi	s4,s4,4
    80006574:	ffb918e3          	bne	s2,s11,80006564 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006578:	00025597          	auipc	a1,0x25
    8000657c:	bb058593          	addi	a1,a1,-1104 # 8002b128 <disk+0x2128>
    80006580:	00025517          	auipc	a0,0x25
    80006584:	a9850513          	addi	a0,a0,-1384 # 8002b018 <disk+0x2018>
    80006588:	ffffc097          	auipc	ra,0xffffc
    8000658c:	b46080e7          	jalr	-1210(ra) # 800020ce <sleep>
  for(int i = 0; i < 3; i++){
    80006590:	f8040a13          	addi	s4,s0,-128
{
    80006594:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006596:	894e                	mv	s2,s3
    80006598:	b765                	j	80006540 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000659a:	00025697          	auipc	a3,0x25
    8000659e:	a666b683          	ld	a3,-1434(a3) # 8002b000 <disk+0x2000>
    800065a2:	96ba                	add	a3,a3,a4
    800065a4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800065a8:	00023817          	auipc	a6,0x23
    800065ac:	a5880813          	addi	a6,a6,-1448 # 80029000 <disk>
    800065b0:	00025697          	auipc	a3,0x25
    800065b4:	a5068693          	addi	a3,a3,-1456 # 8002b000 <disk+0x2000>
    800065b8:	6290                	ld	a2,0(a3)
    800065ba:	963a                	add	a2,a2,a4
    800065bc:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800065c0:	0015e593          	ori	a1,a1,1
    800065c4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800065c8:	f8842603          	lw	a2,-120(s0)
    800065cc:	628c                	ld	a1,0(a3)
    800065ce:	972e                	add	a4,a4,a1
    800065d0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800065d4:	20050593          	addi	a1,a0,512
    800065d8:	0592                	slli	a1,a1,0x4
    800065da:	95c2                	add	a1,a1,a6
    800065dc:	577d                	li	a4,-1
    800065de:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800065e2:	00461713          	slli	a4,a2,0x4
    800065e6:	6290                	ld	a2,0(a3)
    800065e8:	963a                	add	a2,a2,a4
    800065ea:	03078793          	addi	a5,a5,48
    800065ee:	97c2                	add	a5,a5,a6
    800065f0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800065f2:	629c                	ld	a5,0(a3)
    800065f4:	97ba                	add	a5,a5,a4
    800065f6:	4605                	li	a2,1
    800065f8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800065fa:	629c                	ld	a5,0(a3)
    800065fc:	97ba                	add	a5,a5,a4
    800065fe:	4809                	li	a6,2
    80006600:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006604:	629c                	ld	a5,0(a3)
    80006606:	973e                	add	a4,a4,a5
    80006608:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000660c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006610:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006614:	6698                	ld	a4,8(a3)
    80006616:	00275783          	lhu	a5,2(a4)
    8000661a:	8b9d                	andi	a5,a5,7
    8000661c:	0786                	slli	a5,a5,0x1
    8000661e:	97ba                	add	a5,a5,a4
    80006620:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006624:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006628:	6698                	ld	a4,8(a3)
    8000662a:	00275783          	lhu	a5,2(a4)
    8000662e:	2785                	addiw	a5,a5,1
    80006630:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006634:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006638:	100017b7          	lui	a5,0x10001
    8000663c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006640:	004aa783          	lw	a5,4(s5)
    80006644:	02c79163          	bne	a5,a2,80006666 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006648:	00025917          	auipc	s2,0x25
    8000664c:	ae090913          	addi	s2,s2,-1312 # 8002b128 <disk+0x2128>
  while(b->disk == 1) {
    80006650:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006652:	85ca                	mv	a1,s2
    80006654:	8556                	mv	a0,s5
    80006656:	ffffc097          	auipc	ra,0xffffc
    8000665a:	a78080e7          	jalr	-1416(ra) # 800020ce <sleep>
  while(b->disk == 1) {
    8000665e:	004aa783          	lw	a5,4(s5)
    80006662:	fe9788e3          	beq	a5,s1,80006652 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006666:	f8042903          	lw	s2,-128(s0)
    8000666a:	20090793          	addi	a5,s2,512
    8000666e:	00479713          	slli	a4,a5,0x4
    80006672:	00023797          	auipc	a5,0x23
    80006676:	98e78793          	addi	a5,a5,-1650 # 80029000 <disk>
    8000667a:	97ba                	add	a5,a5,a4
    8000667c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006680:	00025997          	auipc	s3,0x25
    80006684:	98098993          	addi	s3,s3,-1664 # 8002b000 <disk+0x2000>
    80006688:	00491713          	slli	a4,s2,0x4
    8000668c:	0009b783          	ld	a5,0(s3)
    80006690:	97ba                	add	a5,a5,a4
    80006692:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006696:	854a                	mv	a0,s2
    80006698:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000669c:	00000097          	auipc	ra,0x0
    800066a0:	c5a080e7          	jalr	-934(ra) # 800062f6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800066a4:	8885                	andi	s1,s1,1
    800066a6:	f0ed                	bnez	s1,80006688 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800066a8:	00025517          	auipc	a0,0x25
    800066ac:	a8050513          	addi	a0,a0,-1408 # 8002b128 <disk+0x2128>
    800066b0:	ffffa097          	auipc	ra,0xffffa
    800066b4:	5c6080e7          	jalr	1478(ra) # 80000c76 <release>
}
    800066b8:	70e6                	ld	ra,120(sp)
    800066ba:	7446                	ld	s0,112(sp)
    800066bc:	74a6                	ld	s1,104(sp)
    800066be:	7906                	ld	s2,96(sp)
    800066c0:	69e6                	ld	s3,88(sp)
    800066c2:	6a46                	ld	s4,80(sp)
    800066c4:	6aa6                	ld	s5,72(sp)
    800066c6:	6b06                	ld	s6,64(sp)
    800066c8:	7be2                	ld	s7,56(sp)
    800066ca:	7c42                	ld	s8,48(sp)
    800066cc:	7ca2                	ld	s9,40(sp)
    800066ce:	7d02                	ld	s10,32(sp)
    800066d0:	6de2                	ld	s11,24(sp)
    800066d2:	6109                	addi	sp,sp,128
    800066d4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066d6:	f8042503          	lw	a0,-128(s0)
    800066da:	20050793          	addi	a5,a0,512
    800066de:	0792                	slli	a5,a5,0x4
  if(write)
    800066e0:	00023817          	auipc	a6,0x23
    800066e4:	92080813          	addi	a6,a6,-1760 # 80029000 <disk>
    800066e8:	00f80733          	add	a4,a6,a5
    800066ec:	01a036b3          	snez	a3,s10
    800066f0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800066f4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800066f8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800066fc:	7679                	lui	a2,0xffffe
    800066fe:	963e                	add	a2,a2,a5
    80006700:	00025697          	auipc	a3,0x25
    80006704:	90068693          	addi	a3,a3,-1792 # 8002b000 <disk+0x2000>
    80006708:	6298                	ld	a4,0(a3)
    8000670a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000670c:	0a878593          	addi	a1,a5,168
    80006710:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006712:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006714:	6298                	ld	a4,0(a3)
    80006716:	9732                	add	a4,a4,a2
    80006718:	45c1                	li	a1,16
    8000671a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000671c:	6298                	ld	a4,0(a3)
    8000671e:	9732                	add	a4,a4,a2
    80006720:	4585                	li	a1,1
    80006722:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006726:	f8442703          	lw	a4,-124(s0)
    8000672a:	628c                	ld	a1,0(a3)
    8000672c:	962e                	add	a2,a2,a1
    8000672e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd200e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006732:	0712                	slli	a4,a4,0x4
    80006734:	6290                	ld	a2,0(a3)
    80006736:	963a                	add	a2,a2,a4
    80006738:	058a8593          	addi	a1,s5,88
    8000673c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000673e:	6294                	ld	a3,0(a3)
    80006740:	96ba                	add	a3,a3,a4
    80006742:	40000613          	li	a2,1024
    80006746:	c690                	sw	a2,8(a3)
  if(write)
    80006748:	e40d19e3          	bnez	s10,8000659a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000674c:	00025697          	auipc	a3,0x25
    80006750:	8b46b683          	ld	a3,-1868(a3) # 8002b000 <disk+0x2000>
    80006754:	96ba                	add	a3,a3,a4
    80006756:	4609                	li	a2,2
    80006758:	00c69623          	sh	a2,12(a3)
    8000675c:	b5b1                	j	800065a8 <virtio_disk_rw+0xd2>

000000008000675e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000675e:	1101                	addi	sp,sp,-32
    80006760:	ec06                	sd	ra,24(sp)
    80006762:	e822                	sd	s0,16(sp)
    80006764:	e426                	sd	s1,8(sp)
    80006766:	e04a                	sd	s2,0(sp)
    80006768:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000676a:	00025517          	auipc	a0,0x25
    8000676e:	9be50513          	addi	a0,a0,-1602 # 8002b128 <disk+0x2128>
    80006772:	ffffa097          	auipc	ra,0xffffa
    80006776:	450080e7          	jalr	1104(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000677a:	10001737          	lui	a4,0x10001
    8000677e:	533c                	lw	a5,96(a4)
    80006780:	8b8d                	andi	a5,a5,3
    80006782:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006784:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006788:	00025797          	auipc	a5,0x25
    8000678c:	87878793          	addi	a5,a5,-1928 # 8002b000 <disk+0x2000>
    80006790:	6b94                	ld	a3,16(a5)
    80006792:	0207d703          	lhu	a4,32(a5)
    80006796:	0026d783          	lhu	a5,2(a3)
    8000679a:	06f70163          	beq	a4,a5,800067fc <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000679e:	00023917          	auipc	s2,0x23
    800067a2:	86290913          	addi	s2,s2,-1950 # 80029000 <disk>
    800067a6:	00025497          	auipc	s1,0x25
    800067aa:	85a48493          	addi	s1,s1,-1958 # 8002b000 <disk+0x2000>
    __sync_synchronize();
    800067ae:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800067b2:	6898                	ld	a4,16(s1)
    800067b4:	0204d783          	lhu	a5,32(s1)
    800067b8:	8b9d                	andi	a5,a5,7
    800067ba:	078e                	slli	a5,a5,0x3
    800067bc:	97ba                	add	a5,a5,a4
    800067be:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800067c0:	20078713          	addi	a4,a5,512
    800067c4:	0712                	slli	a4,a4,0x4
    800067c6:	974a                	add	a4,a4,s2
    800067c8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800067cc:	e731                	bnez	a4,80006818 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800067ce:	20078793          	addi	a5,a5,512
    800067d2:	0792                	slli	a5,a5,0x4
    800067d4:	97ca                	add	a5,a5,s2
    800067d6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800067d8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800067dc:	ffffc097          	auipc	ra,0xffffc
    800067e0:	a7e080e7          	jalr	-1410(ra) # 8000225a <wakeup>

    disk.used_idx += 1;
    800067e4:	0204d783          	lhu	a5,32(s1)
    800067e8:	2785                	addiw	a5,a5,1
    800067ea:	17c2                	slli	a5,a5,0x30
    800067ec:	93c1                	srli	a5,a5,0x30
    800067ee:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800067f2:	6898                	ld	a4,16(s1)
    800067f4:	00275703          	lhu	a4,2(a4)
    800067f8:	faf71be3          	bne	a4,a5,800067ae <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800067fc:	00025517          	auipc	a0,0x25
    80006800:	92c50513          	addi	a0,a0,-1748 # 8002b128 <disk+0x2128>
    80006804:	ffffa097          	auipc	ra,0xffffa
    80006808:	472080e7          	jalr	1138(ra) # 80000c76 <release>
}
    8000680c:	60e2                	ld	ra,24(sp)
    8000680e:	6442                	ld	s0,16(sp)
    80006810:	64a2                	ld	s1,8(sp)
    80006812:	6902                	ld	s2,0(sp)
    80006814:	6105                	addi	sp,sp,32
    80006816:	8082                	ret
      panic("virtio_disk_intr status");
    80006818:	00002517          	auipc	a0,0x2
    8000681c:	02050513          	addi	a0,a0,32 # 80008838 <syscalls+0x408>
    80006820:	ffffa097          	auipc	ra,0xffffa
    80006824:	d0a080e7          	jalr	-758(ra) # 8000052a <panic>
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
