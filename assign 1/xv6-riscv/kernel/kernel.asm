
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
    80000068:	fac78793          	addi	a5,a5,-84 # 80006010 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
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
    80000122:	6a6080e7          	jalr	1702(ra) # 800027c4 <either_copyin>
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
    800001c6:	01e080e7          	jalr	30(ra) # 800021e0 <sleep>
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
    80000202:	570080e7          	jalr	1392(ra) # 8000276e <either_copyout>
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
    800002e2:	53c080e7          	jalr	1340(ra) # 8000281a <procdump>
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
    80000436:	0ec080e7          	jalr	236(ra) # 8000251e <wakeup>
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
    80000464:	00021797          	auipc	a5,0x21
    80000468:	6b478793          	addi	a5,a5,1716 # 80021b18 <devsw>
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
    80000882:	ca0080e7          	jalr	-864(ra) # 8000251e <wakeup>
    
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
    8000090a:	00002097          	auipc	ra,0x2
    8000090e:	8d6080e7          	jalr	-1834(ra) # 800021e0 <sleep>
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
    800009ea:	00025797          	auipc	a5,0x25
    800009ee:	61678793          	addi	a5,a5,1558 # 80026000 <end>
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
    80000aba:	00025517          	auipc	a0,0x25
    80000abe:	54650513          	addi	a0,a0,1350 # 80026000 <end>
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
    80000eb6:	b06080e7          	jalr	-1274(ra) # 800029b8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00005097          	auipc	ra,0x5
    80000ebe:	196080e7          	jalr	406(ra) # 80006050 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	118080e7          	jalr	280(ra) # 80001fda <scheduler>
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
    80000f2e:	a66080e7          	jalr	-1434(ra) # 80002990 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	a86080e7          	jalr	-1402(ra) # 800029b8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00005097          	auipc	ra,0x5
    80000f3e:	100080e7          	jalr	256(ra) # 8000603a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	10e080e7          	jalr	270(ra) # 80006050 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	2dc080e7          	jalr	732(ra) # 80003226 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	96e080e7          	jalr	-1682(ra) # 800038c0 <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	91c080e7          	jalr	-1764(ra) # 80004876 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	210080e7          	jalr	528(ra) # 80006172 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	e06080e7          	jalr	-506(ra) # 80001d70 <userinit>
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
    800017e0:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
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
    8000183c:	00016a17          	auipc	s4,0x16
    80001840:	094a0a13          	addi	s4,s4,148 # 800178d0 <tickslock>
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
    80001876:	18848493          	addi	s1,s1,392
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
    80001908:	00016997          	auipc	s3,0x16
    8000190c:	fc898993          	addi	s3,s3,-56 # 800178d0 <tickslock>
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
    80001936:	18848493          	addi	s1,s1,392
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
    800019d2:	f627a783          	lw	a5,-158(a5) # 80008930 <first.1>
    800019d6:	eb89                	bnez	a5,800019e8 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019d8:	00001097          	auipc	ra,0x1
    800019dc:	ff8080e7          	jalr	-8(ra) # 800029d0 <usertrapret>
}
    800019e0:	60a2                	ld	ra,8(sp)
    800019e2:	6402                	ld	s0,0(sp)
    800019e4:	0141                	addi	sp,sp,16
    800019e6:	8082                	ret
    first = 0;
    800019e8:	00007797          	auipc	a5,0x7
    800019ec:	f407a423          	sw	zero,-184(a5) # 80008930 <first.1>
    fsinit(ROOTDEV);
    800019f0:	4505                	li	a0,1
    800019f2:	00002097          	auipc	ra,0x2
    800019f6:	e4e080e7          	jalr	-434(ra) # 80003840 <fsinit>
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
    80001a1e:	f1a78793          	addi	a5,a5,-230 # 80008934 <nextpid>
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

0000000080001a42 <trace>:
trace(int mask, int pid){
    80001a42:	7179                	addi	sp,sp,-48
    80001a44:	f406                	sd	ra,40(sp)
    80001a46:	f022                	sd	s0,32(sp)
    80001a48:	ec26                	sd	s1,24(sp)
    80001a4a:	e84a                	sd	s2,16(sp)
    80001a4c:	e44e                	sd	s3,8(sp)
    80001a4e:	e052                	sd	s4,0(sp)
    80001a50:	1800                	addi	s0,sp,48
    80001a52:	8a2a                	mv	s4,a0
    80001a54:	892e                	mv	s2,a1
  for(p = proc; p < &proc[NPROC]; p++){
    80001a56:	00010497          	auipc	s1,0x10
    80001a5a:	c7a48493          	addi	s1,s1,-902 # 800116d0 <proc>
    80001a5e:	00016997          	auipc	s3,0x16
    80001a62:	e7298993          	addi	s3,s3,-398 # 800178d0 <tickslock>
    acquire(&p->lock);
    80001a66:	8526                	mv	a0,s1
    80001a68:	fffff097          	auipc	ra,0xfffff
    80001a6c:	15a080e7          	jalr	346(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80001a70:	589c                	lw	a5,48(s1)
    80001a72:	01278d63          	beq	a5,s2,80001a8c <trace+0x4a>
    release(&p->lock);
    80001a76:	8526                	mv	a0,s1
    80001a78:	fffff097          	auipc	ra,0xfffff
    80001a7c:	1fe080e7          	jalr	510(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a80:	18848493          	addi	s1,s1,392
    80001a84:	ff3491e3          	bne	s1,s3,80001a66 <trace+0x24>
  return -1;
    80001a88:	557d                	li	a0,-1
    80001a8a:	a809                	j	80001a9c <trace+0x5a>
      p->mask = mask;
    80001a8c:	0344aa23          	sw	s4,52(s1)
      release(&p->lock);
    80001a90:	8526                	mv	a0,s1
    80001a92:	fffff097          	auipc	ra,0xfffff
    80001a96:	1e4080e7          	jalr	484(ra) # 80000c76 <release>
      return 0;
    80001a9a:	4501                	li	a0,0
}
    80001a9c:	70a2                	ld	ra,40(sp)
    80001a9e:	7402                	ld	s0,32(sp)
    80001aa0:	64e2                	ld	s1,24(sp)
    80001aa2:	6942                	ld	s2,16(sp)
    80001aa4:	69a2                	ld	s3,8(sp)
    80001aa6:	6a02                	ld	s4,0(sp)
    80001aa8:	6145                	addi	sp,sp,48
    80001aaa:	8082                	ret

0000000080001aac <set_priority>:
  if(newPriority < 1 || newPriority > 5)
    80001aac:	fff5071b          	addiw	a4,a0,-1
    80001ab0:	4791                	li	a5,4
    80001ab2:	06e7ec63          	bltu	a5,a4,80001b2a <set_priority+0x7e>
set_priority(int newPriority){
    80001ab6:	1101                	addi	sp,sp,-32
    80001ab8:	ec06                	sd	ra,24(sp)
    80001aba:	e822                	sd	s0,16(sp)
    80001abc:	e426                	sd	s1,8(sp)
    80001abe:	e04a                	sd	s2,0(sp)
    80001ac0:	1000                	addi	s0,sp,32
    80001ac2:	84aa                	mv	s1,a0
  struct proc *p =  myproc();
    80001ac4:	00000097          	auipc	ra,0x0
    80001ac8:	eba080e7          	jalr	-326(ra) # 8000197e <myproc>
    80001acc:	892a                	mv	s2,a0
  acquire(&p->lock);
    80001ace:	fffff097          	auipc	ra,0xfffff
    80001ad2:	0f4080e7          	jalr	244(ra) # 80000bc2 <acquire>
  switch (newPriority)
    80001ad6:	4791                	li	a5,4
    80001ad8:	02f48d63          	beq	s1,a5,80001b12 <set_priority+0x66>
    80001adc:	0297cf63          	blt	a5,s1,80001b1a <set_priority+0x6e>
    80001ae0:	4789                	li	a5,2
    80001ae2:	00f48963          	beq	s1,a5,80001af4 <set_priority+0x48>
    80001ae6:	478d                	li	a5,3
    80001ae8:	02f49d63          	bne	s1,a5,80001b22 <set_priority+0x76>
    p->priority = 5;
    80001aec:	4795                	li	a5,5
    80001aee:	18f92223          	sw	a5,388(s2)
    break;
    80001af2:	a021                	j	80001afa <set_priority+0x4e>
    p->priority = 3;
    80001af4:	478d                	li	a5,3
    80001af6:	18f92223          	sw	a5,388(s2)
  release(&p->lock);
    80001afa:	854a                	mv	a0,s2
    80001afc:	fffff097          	auipc	ra,0xfffff
    80001b00:	17a080e7          	jalr	378(ra) # 80000c76 <release>
  return 0;
    80001b04:	4501                	li	a0,0
}
    80001b06:	60e2                	ld	ra,24(sp)
    80001b08:	6442                	ld	s0,16(sp)
    80001b0a:	64a2                	ld	s1,8(sp)
    80001b0c:	6902                	ld	s2,0(sp)
    80001b0e:	6105                	addi	sp,sp,32
    80001b10:	8082                	ret
    p->priority = 7;
    80001b12:	479d                	li	a5,7
    80001b14:	18f92223          	sw	a5,388(s2)
    break;
    80001b18:	b7cd                	j	80001afa <set_priority+0x4e>
    p->priority = 25;
    80001b1a:	47e5                	li	a5,25
    80001b1c:	18f92223          	sw	a5,388(s2)
    break;
    80001b20:	bfe9                	j	80001afa <set_priority+0x4e>
    p->priority = 1;
    80001b22:	4785                	li	a5,1
    80001b24:	18f92223          	sw	a5,388(s2)
    break;
    80001b28:	bfc9                	j	80001afa <set_priority+0x4e>
    return -1;
    80001b2a:	557d                	li	a0,-1
}
    80001b2c:	8082                	ret

0000000080001b2e <proc_pagetable>:
{
    80001b2e:	1101                	addi	sp,sp,-32
    80001b30:	ec06                	sd	ra,24(sp)
    80001b32:	e822                	sd	s0,16(sp)
    80001b34:	e426                	sd	s1,8(sp)
    80001b36:	e04a                	sd	s2,0(sp)
    80001b38:	1000                	addi	s0,sp,32
    80001b3a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b3c:	fffff097          	auipc	ra,0xfffff
    80001b40:	7ca080e7          	jalr	1994(ra) # 80001306 <uvmcreate>
    80001b44:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b46:	c121                	beqz	a0,80001b86 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b48:	4729                	li	a4,10
    80001b4a:	00005697          	auipc	a3,0x5
    80001b4e:	4b668693          	addi	a3,a3,1206 # 80007000 <_trampoline>
    80001b52:	6605                	lui	a2,0x1
    80001b54:	040005b7          	lui	a1,0x4000
    80001b58:	15fd                	addi	a1,a1,-1
    80001b5a:	05b2                	slli	a1,a1,0xc
    80001b5c:	fffff097          	auipc	ra,0xfffff
    80001b60:	532080e7          	jalr	1330(ra) # 8000108e <mappages>
    80001b64:	02054863          	bltz	a0,80001b94 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b68:	4719                	li	a4,6
    80001b6a:	05893683          	ld	a3,88(s2)
    80001b6e:	6605                	lui	a2,0x1
    80001b70:	020005b7          	lui	a1,0x2000
    80001b74:	15fd                	addi	a1,a1,-1
    80001b76:	05b6                	slli	a1,a1,0xd
    80001b78:	8526                	mv	a0,s1
    80001b7a:	fffff097          	auipc	ra,0xfffff
    80001b7e:	514080e7          	jalr	1300(ra) # 8000108e <mappages>
    80001b82:	02054163          	bltz	a0,80001ba4 <proc_pagetable+0x76>
}
    80001b86:	8526                	mv	a0,s1
    80001b88:	60e2                	ld	ra,24(sp)
    80001b8a:	6442                	ld	s0,16(sp)
    80001b8c:	64a2                	ld	s1,8(sp)
    80001b8e:	6902                	ld	s2,0(sp)
    80001b90:	6105                	addi	sp,sp,32
    80001b92:	8082                	ret
    uvmfree(pagetable, 0);
    80001b94:	4581                	li	a1,0
    80001b96:	8526                	mv	a0,s1
    80001b98:	00000097          	auipc	ra,0x0
    80001b9c:	96a080e7          	jalr	-1686(ra) # 80001502 <uvmfree>
    return 0;
    80001ba0:	4481                	li	s1,0
    80001ba2:	b7d5                	j	80001b86 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ba4:	4681                	li	a3,0
    80001ba6:	4605                	li	a2,1
    80001ba8:	040005b7          	lui	a1,0x4000
    80001bac:	15fd                	addi	a1,a1,-1
    80001bae:	05b2                	slli	a1,a1,0xc
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	fffff097          	auipc	ra,0xfffff
    80001bb6:	690080e7          	jalr	1680(ra) # 80001242 <uvmunmap>
    uvmfree(pagetable, 0);
    80001bba:	4581                	li	a1,0
    80001bbc:	8526                	mv	a0,s1
    80001bbe:	00000097          	auipc	ra,0x0
    80001bc2:	944080e7          	jalr	-1724(ra) # 80001502 <uvmfree>
    return 0;
    80001bc6:	4481                	li	s1,0
    80001bc8:	bf7d                	j	80001b86 <proc_pagetable+0x58>

0000000080001bca <proc_freepagetable>:
{
    80001bca:	1101                	addi	sp,sp,-32
    80001bcc:	ec06                	sd	ra,24(sp)
    80001bce:	e822                	sd	s0,16(sp)
    80001bd0:	e426                	sd	s1,8(sp)
    80001bd2:	e04a                	sd	s2,0(sp)
    80001bd4:	1000                	addi	s0,sp,32
    80001bd6:	84aa                	mv	s1,a0
    80001bd8:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bda:	4681                	li	a3,0
    80001bdc:	4605                	li	a2,1
    80001bde:	040005b7          	lui	a1,0x4000
    80001be2:	15fd                	addi	a1,a1,-1
    80001be4:	05b2                	slli	a1,a1,0xc
    80001be6:	fffff097          	auipc	ra,0xfffff
    80001bea:	65c080e7          	jalr	1628(ra) # 80001242 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bee:	4681                	li	a3,0
    80001bf0:	4605                	li	a2,1
    80001bf2:	020005b7          	lui	a1,0x2000
    80001bf6:	15fd                	addi	a1,a1,-1
    80001bf8:	05b6                	slli	a1,a1,0xd
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	646080e7          	jalr	1606(ra) # 80001242 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c04:	85ca                	mv	a1,s2
    80001c06:	8526                	mv	a0,s1
    80001c08:	00000097          	auipc	ra,0x0
    80001c0c:	8fa080e7          	jalr	-1798(ra) # 80001502 <uvmfree>
}
    80001c10:	60e2                	ld	ra,24(sp)
    80001c12:	6442                	ld	s0,16(sp)
    80001c14:	64a2                	ld	s1,8(sp)
    80001c16:	6902                	ld	s2,0(sp)
    80001c18:	6105                	addi	sp,sp,32
    80001c1a:	8082                	ret

0000000080001c1c <freeproc>:
{
    80001c1c:	1101                	addi	sp,sp,-32
    80001c1e:	ec06                	sd	ra,24(sp)
    80001c20:	e822                	sd	s0,16(sp)
    80001c22:	e426                	sd	s1,8(sp)
    80001c24:	1000                	addi	s0,sp,32
    80001c26:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c28:	6d28                	ld	a0,88(a0)
    80001c2a:	c509                	beqz	a0,80001c34 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c2c:	fffff097          	auipc	ra,0xfffff
    80001c30:	daa080e7          	jalr	-598(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001c34:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c38:	68a8                	ld	a0,80(s1)
    80001c3a:	c511                	beqz	a0,80001c46 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c3c:	64ac                	ld	a1,72(s1)
    80001c3e:	00000097          	auipc	ra,0x0
    80001c42:	f8c080e7          	jalr	-116(ra) # 80001bca <proc_freepagetable>
  p->pagetable = 0;
    80001c46:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c4a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c4e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c52:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c56:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c5a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c5e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c62:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c66:	0004ac23          	sw	zero,24(s1)
}
    80001c6a:	60e2                	ld	ra,24(sp)
    80001c6c:	6442                	ld	s0,16(sp)
    80001c6e:	64a2                	ld	s1,8(sp)
    80001c70:	6105                	addi	sp,sp,32
    80001c72:	8082                	ret

0000000080001c74 <allocproc>:
{
    80001c74:	1101                	addi	sp,sp,-32
    80001c76:	ec06                	sd	ra,24(sp)
    80001c78:	e822                	sd	s0,16(sp)
    80001c7a:	e426                	sd	s1,8(sp)
    80001c7c:	e04a                	sd	s2,0(sp)
    80001c7e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c80:	00010497          	auipc	s1,0x10
    80001c84:	a5048493          	addi	s1,s1,-1456 # 800116d0 <proc>
    80001c88:	00016917          	auipc	s2,0x16
    80001c8c:	c4890913          	addi	s2,s2,-952 # 800178d0 <tickslock>
    acquire(&p->lock);
    80001c90:	8526                	mv	a0,s1
    80001c92:	fffff097          	auipc	ra,0xfffff
    80001c96:	f30080e7          	jalr	-208(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    80001c9a:	4c9c                	lw	a5,24(s1)
    80001c9c:	cf81                	beqz	a5,80001cb4 <allocproc+0x40>
      release(&p->lock);
    80001c9e:	8526                	mv	a0,s1
    80001ca0:	fffff097          	auipc	ra,0xfffff
    80001ca4:	fd6080e7          	jalr	-42(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ca8:	18848493          	addi	s1,s1,392
    80001cac:	ff2492e3          	bne	s1,s2,80001c90 <allocproc+0x1c>
  return 0;
    80001cb0:	4481                	li	s1,0
    80001cb2:	a041                	j	80001d32 <allocproc+0xbe>
  p->pid = allocpid();
    80001cb4:	00000097          	auipc	ra,0x0
    80001cb8:	d48080e7          	jalr	-696(ra) # 800019fc <allocpid>
    80001cbc:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001cbe:	4785                	li	a5,1
    80001cc0:	cc9c                	sw	a5,24(s1)
  p->mask = 0; //added in assign1 for trace syscall.
    80001cc2:	0204aa23          	sw	zero,52(s1)
  p->priority = 5;
    80001cc6:	4795                	li	a5,5
    80001cc8:	18f4a223          	sw	a5,388(s1)
  p->average_bursttime = QUANTUM * 100; //added in assign1.4
    80001ccc:	1f400793          	li	a5,500
    80001cd0:	16f4ae23          	sw	a5,380(s1)
  p->ctime = ticks;
    80001cd4:	00007797          	auipc	a5,0x7
    80001cd8:	35c7a783          	lw	a5,860(a5) # 80009030 <ticks>
    80001cdc:	16f4a423          	sw	a5,360(s1)
  p->ttime = 0;
    80001ce0:	1604a623          	sw	zero,364(s1)
  p->stime = 0;
    80001ce4:	1604a823          	sw	zero,368(s1)
  p->retime = 0;
    80001ce8:	1604aa23          	sw	zero,372(s1)
  p->rutime = 0;
    80001cec:	1604ac23          	sw	zero,376(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	de2080e7          	jalr	-542(ra) # 80000ad2 <kalloc>
    80001cf8:	892a                	mv	s2,a0
    80001cfa:	eca8                	sd	a0,88(s1)
    80001cfc:	c131                	beqz	a0,80001d40 <allocproc+0xcc>
  p->pagetable = proc_pagetable(p);
    80001cfe:	8526                	mv	a0,s1
    80001d00:	00000097          	auipc	ra,0x0
    80001d04:	e2e080e7          	jalr	-466(ra) # 80001b2e <proc_pagetable>
    80001d08:	892a                	mv	s2,a0
    80001d0a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d0c:	c531                	beqz	a0,80001d58 <allocproc+0xe4>
  memset(&p->context, 0, sizeof(p->context));
    80001d0e:	07000613          	li	a2,112
    80001d12:	4581                	li	a1,0
    80001d14:	06048513          	addi	a0,s1,96
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	fa6080e7          	jalr	-90(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001d20:	00000797          	auipc	a5,0x0
    80001d24:	c9678793          	addi	a5,a5,-874 # 800019b6 <forkret>
    80001d28:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d2a:	60bc                	ld	a5,64(s1)
    80001d2c:	6705                	lui	a4,0x1
    80001d2e:	97ba                	add	a5,a5,a4
    80001d30:	f4bc                	sd	a5,104(s1)
}
    80001d32:	8526                	mv	a0,s1
    80001d34:	60e2                	ld	ra,24(sp)
    80001d36:	6442                	ld	s0,16(sp)
    80001d38:	64a2                	ld	s1,8(sp)
    80001d3a:	6902                	ld	s2,0(sp)
    80001d3c:	6105                	addi	sp,sp,32
    80001d3e:	8082                	ret
    freeproc(p);
    80001d40:	8526                	mv	a0,s1
    80001d42:	00000097          	auipc	ra,0x0
    80001d46:	eda080e7          	jalr	-294(ra) # 80001c1c <freeproc>
    release(&p->lock);
    80001d4a:	8526                	mv	a0,s1
    80001d4c:	fffff097          	auipc	ra,0xfffff
    80001d50:	f2a080e7          	jalr	-214(ra) # 80000c76 <release>
    return 0;
    80001d54:	84ca                	mv	s1,s2
    80001d56:	bff1                	j	80001d32 <allocproc+0xbe>
    freeproc(p);
    80001d58:	8526                	mv	a0,s1
    80001d5a:	00000097          	auipc	ra,0x0
    80001d5e:	ec2080e7          	jalr	-318(ra) # 80001c1c <freeproc>
    release(&p->lock);
    80001d62:	8526                	mv	a0,s1
    80001d64:	fffff097          	auipc	ra,0xfffff
    80001d68:	f12080e7          	jalr	-238(ra) # 80000c76 <release>
    return 0;
    80001d6c:	84ca                	mv	s1,s2
    80001d6e:	b7d1                	j	80001d32 <allocproc+0xbe>

0000000080001d70 <userinit>:
{
    80001d70:	1101                	addi	sp,sp,-32
    80001d72:	ec06                	sd	ra,24(sp)
    80001d74:	e822                	sd	s0,16(sp)
    80001d76:	e426                	sd	s1,8(sp)
    80001d78:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d7a:	00000097          	auipc	ra,0x0
    80001d7e:	efa080e7          	jalr	-262(ra) # 80001c74 <allocproc>
    80001d82:	84aa                	mv	s1,a0
  initproc = p;
    80001d84:	00007797          	auipc	a5,0x7
    80001d88:	2aa7b223          	sd	a0,676(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d8c:	03400613          	li	a2,52
    80001d90:	00007597          	auipc	a1,0x7
    80001d94:	bb058593          	addi	a1,a1,-1104 # 80008940 <initcode>
    80001d98:	6928                	ld	a0,80(a0)
    80001d9a:	fffff097          	auipc	ra,0xfffff
    80001d9e:	59a080e7          	jalr	1434(ra) # 80001334 <uvminit>
  p->sz = PGSIZE;
    80001da2:	6785                	lui	a5,0x1
    80001da4:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001da6:	6cb8                	ld	a4,88(s1)
    80001da8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001dac:	6cb8                	ld	a4,88(s1)
    80001dae:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001db0:	4641                	li	a2,16
    80001db2:	00006597          	auipc	a1,0x6
    80001db6:	43658593          	addi	a1,a1,1078 # 800081e8 <digits+0x1a8>
    80001dba:	15848513          	addi	a0,s1,344
    80001dbe:	fffff097          	auipc	ra,0xfffff
    80001dc2:	052080e7          	jalr	82(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80001dc6:	00006517          	auipc	a0,0x6
    80001dca:	43250513          	addi	a0,a0,1074 # 800081f8 <digits+0x1b8>
    80001dce:	00002097          	auipc	ra,0x2
    80001dd2:	4a0080e7          	jalr	1184(ra) # 8000426e <namei>
    80001dd6:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001dda:	478d                	li	a5,3
    80001ddc:	cc9c                	sw	a5,24(s1)
  p->FCFSCounter = FCFSIdCounter; //added in assign1.4
    80001dde:	00007717          	auipc	a4,0x7
    80001de2:	b5a70713          	addi	a4,a4,-1190 # 80008938 <FCFSIdCounter>
    80001de6:	431c                	lw	a5,0(a4)
    80001de8:	18f4a023          	sw	a5,384(s1)
  FCFSIdCounter++;
    80001dec:	2785                	addiw	a5,a5,1
    80001dee:	c31c                	sw	a5,0(a4)
  release(&p->lock);
    80001df0:	8526                	mv	a0,s1
    80001df2:	fffff097          	auipc	ra,0xfffff
    80001df6:	e84080e7          	jalr	-380(ra) # 80000c76 <release>
}
    80001dfa:	60e2                	ld	ra,24(sp)
    80001dfc:	6442                	ld	s0,16(sp)
    80001dfe:	64a2                	ld	s1,8(sp)
    80001e00:	6105                	addi	sp,sp,32
    80001e02:	8082                	ret

0000000080001e04 <growproc>:
{
    80001e04:	1101                	addi	sp,sp,-32
    80001e06:	ec06                	sd	ra,24(sp)
    80001e08:	e822                	sd	s0,16(sp)
    80001e0a:	e426                	sd	s1,8(sp)
    80001e0c:	e04a                	sd	s2,0(sp)
    80001e0e:	1000                	addi	s0,sp,32
    80001e10:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e12:	00000097          	auipc	ra,0x0
    80001e16:	b6c080e7          	jalr	-1172(ra) # 8000197e <myproc>
    80001e1a:	892a                	mv	s2,a0
  sz = p->sz;
    80001e1c:	652c                	ld	a1,72(a0)
    80001e1e:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001e22:	00904f63          	bgtz	s1,80001e40 <growproc+0x3c>
  } else if(n < 0){
    80001e26:	0204cc63          	bltz	s1,80001e5e <growproc+0x5a>
  p->sz = sz;
    80001e2a:	1602                	slli	a2,a2,0x20
    80001e2c:	9201                	srli	a2,a2,0x20
    80001e2e:	04c93423          	sd	a2,72(s2)
  return 0;
    80001e32:	4501                	li	a0,0
}
    80001e34:	60e2                	ld	ra,24(sp)
    80001e36:	6442                	ld	s0,16(sp)
    80001e38:	64a2                	ld	s1,8(sp)
    80001e3a:	6902                	ld	s2,0(sp)
    80001e3c:	6105                	addi	sp,sp,32
    80001e3e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e40:	9e25                	addw	a2,a2,s1
    80001e42:	1602                	slli	a2,a2,0x20
    80001e44:	9201                	srli	a2,a2,0x20
    80001e46:	1582                	slli	a1,a1,0x20
    80001e48:	9181                	srli	a1,a1,0x20
    80001e4a:	6928                	ld	a0,80(a0)
    80001e4c:	fffff097          	auipc	ra,0xfffff
    80001e50:	5a2080e7          	jalr	1442(ra) # 800013ee <uvmalloc>
    80001e54:	0005061b          	sext.w	a2,a0
    80001e58:	fa69                	bnez	a2,80001e2a <growproc+0x26>
      return -1;
    80001e5a:	557d                	li	a0,-1
    80001e5c:	bfe1                	j	80001e34 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e5e:	9e25                	addw	a2,a2,s1
    80001e60:	1602                	slli	a2,a2,0x20
    80001e62:	9201                	srli	a2,a2,0x20
    80001e64:	1582                	slli	a1,a1,0x20
    80001e66:	9181                	srli	a1,a1,0x20
    80001e68:	6928                	ld	a0,80(a0)
    80001e6a:	fffff097          	auipc	ra,0xfffff
    80001e6e:	53c080e7          	jalr	1340(ra) # 800013a6 <uvmdealloc>
    80001e72:	0005061b          	sext.w	a2,a0
    80001e76:	bf55                	j	80001e2a <growproc+0x26>

0000000080001e78 <fork>:
{
    80001e78:	7139                	addi	sp,sp,-64
    80001e7a:	fc06                	sd	ra,56(sp)
    80001e7c:	f822                	sd	s0,48(sp)
    80001e7e:	f426                	sd	s1,40(sp)
    80001e80:	f04a                	sd	s2,32(sp)
    80001e82:	ec4e                	sd	s3,24(sp)
    80001e84:	e852                	sd	s4,16(sp)
    80001e86:	e456                	sd	s5,8(sp)
    80001e88:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e8a:	00000097          	auipc	ra,0x0
    80001e8e:	af4080e7          	jalr	-1292(ra) # 8000197e <myproc>
    80001e92:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e94:	00000097          	auipc	ra,0x0
    80001e98:	de0080e7          	jalr	-544(ra) # 80001c74 <allocproc>
    80001e9c:	12050d63          	beqz	a0,80001fd6 <fork+0x15e>
    80001ea0:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001ea2:	048ab603          	ld	a2,72(s5)
    80001ea6:	692c                	ld	a1,80(a0)
    80001ea8:	050ab503          	ld	a0,80(s5)
    80001eac:	fffff097          	auipc	ra,0xfffff
    80001eb0:	68e080e7          	jalr	1678(ra) # 8000153a <uvmcopy>
    80001eb4:	06054063          	bltz	a0,80001f14 <fork+0x9c>
  np->sz = p->sz;
    80001eb8:	048ab783          	ld	a5,72(s5)
    80001ebc:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001ec0:	058ab683          	ld	a3,88(s5)
    80001ec4:	87b6                	mv	a5,a3
    80001ec6:	0589b703          	ld	a4,88(s3)
    80001eca:	12068693          	addi	a3,a3,288
    80001ece:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ed2:	6788                	ld	a0,8(a5)
    80001ed4:	6b8c                	ld	a1,16(a5)
    80001ed6:	6f90                	ld	a2,24(a5)
    80001ed8:	01073023          	sd	a6,0(a4)
    80001edc:	e708                	sd	a0,8(a4)
    80001ede:	eb0c                	sd	a1,16(a4)
    80001ee0:	ef10                	sd	a2,24(a4)
    80001ee2:	02078793          	addi	a5,a5,32
    80001ee6:	02070713          	addi	a4,a4,32
    80001eea:	fed792e3          	bne	a5,a3,80001ece <fork+0x56>
  np->trapframe->a0 = 0;
    80001eee:	0589b783          	ld	a5,88(s3)
    80001ef2:	0607b823          	sd	zero,112(a5)
  np->mask = p->mask; //added in assign1, for trace syscall.
    80001ef6:	034aa783          	lw	a5,52(s5)
    80001efa:	02f9aa23          	sw	a5,52(s3)
  np->priority = p->priority;
    80001efe:	184aa783          	lw	a5,388(s5)
    80001f02:	18f9a223          	sw	a5,388(s3)
  for(i = 0; i < NOFILE; i++)
    80001f06:	0d0a8493          	addi	s1,s5,208
    80001f0a:	0d098913          	addi	s2,s3,208
    80001f0e:	150a8a13          	addi	s4,s5,336
    80001f12:	a00d                	j	80001f34 <fork+0xbc>
    freeproc(np);
    80001f14:	854e                	mv	a0,s3
    80001f16:	00000097          	auipc	ra,0x0
    80001f1a:	d06080e7          	jalr	-762(ra) # 80001c1c <freeproc>
    release(&np->lock);
    80001f1e:	854e                	mv	a0,s3
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	d56080e7          	jalr	-682(ra) # 80000c76 <release>
    return -1;
    80001f28:	597d                	li	s2,-1
    80001f2a:	a861                	j	80001fc2 <fork+0x14a>
  for(i = 0; i < NOFILE; i++)
    80001f2c:	04a1                	addi	s1,s1,8
    80001f2e:	0921                	addi	s2,s2,8
    80001f30:	01448b63          	beq	s1,s4,80001f46 <fork+0xce>
    if(p->ofile[i])
    80001f34:	6088                	ld	a0,0(s1)
    80001f36:	d97d                	beqz	a0,80001f2c <fork+0xb4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f38:	00003097          	auipc	ra,0x3
    80001f3c:	9d0080e7          	jalr	-1584(ra) # 80004908 <filedup>
    80001f40:	00a93023          	sd	a0,0(s2)
    80001f44:	b7e5                	j	80001f2c <fork+0xb4>
  np->cwd = idup(p->cwd);
    80001f46:	150ab503          	ld	a0,336(s5)
    80001f4a:	00002097          	auipc	ra,0x2
    80001f4e:	b30080e7          	jalr	-1232(ra) # 80003a7a <idup>
    80001f52:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f56:	4641                	li	a2,16
    80001f58:	158a8593          	addi	a1,s5,344
    80001f5c:	15898513          	addi	a0,s3,344
    80001f60:	fffff097          	auipc	ra,0xfffff
    80001f64:	eb0080e7          	jalr	-336(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80001f68:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001f6c:	854e                	mv	a0,s3
    80001f6e:	fffff097          	auipc	ra,0xfffff
    80001f72:	d08080e7          	jalr	-760(ra) # 80000c76 <release>
  acquire(&wait_lock);
    80001f76:	0000f497          	auipc	s1,0xf
    80001f7a:	34248493          	addi	s1,s1,834 # 800112b8 <wait_lock>
    80001f7e:	8526                	mv	a0,s1
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	c42080e7          	jalr	-958(ra) # 80000bc2 <acquire>
  np->parent = p;
    80001f88:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001f8c:	8526                	mv	a0,s1
    80001f8e:	fffff097          	auipc	ra,0xfffff
    80001f92:	ce8080e7          	jalr	-792(ra) # 80000c76 <release>
  acquire(&np->lock);
    80001f96:	854e                	mv	a0,s3
    80001f98:	fffff097          	auipc	ra,0xfffff
    80001f9c:	c2a080e7          	jalr	-982(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80001fa0:	478d                	li	a5,3
    80001fa2:	00f9ac23          	sw	a5,24(s3)
  p->FCFSCounter = FCFSIdCounter; //added in assign1.4
    80001fa6:	00007717          	auipc	a4,0x7
    80001faa:	99270713          	addi	a4,a4,-1646 # 80008938 <FCFSIdCounter>
    80001fae:	431c                	lw	a5,0(a4)
    80001fb0:	18faa023          	sw	a5,384(s5)
  FCFSIdCounter++;
    80001fb4:	2785                	addiw	a5,a5,1
    80001fb6:	c31c                	sw	a5,0(a4)
  release(&np->lock);
    80001fb8:	854e                	mv	a0,s3
    80001fba:	fffff097          	auipc	ra,0xfffff
    80001fbe:	cbc080e7          	jalr	-836(ra) # 80000c76 <release>
}
    80001fc2:	854a                	mv	a0,s2
    80001fc4:	70e2                	ld	ra,56(sp)
    80001fc6:	7442                	ld	s0,48(sp)
    80001fc8:	74a2                	ld	s1,40(sp)
    80001fca:	7902                	ld	s2,32(sp)
    80001fcc:	69e2                	ld	s3,24(sp)
    80001fce:	6a42                	ld	s4,16(sp)
    80001fd0:	6aa2                	ld	s5,8(sp)
    80001fd2:	6121                	addi	sp,sp,64
    80001fd4:	8082                	ret
    return -1;
    80001fd6:	597d                	li	s2,-1
    80001fd8:	b7ed                	j	80001fc2 <fork+0x14a>

0000000080001fda <scheduler>:
{
    80001fda:	711d                	addi	sp,sp,-96
    80001fdc:	ec86                	sd	ra,88(sp)
    80001fde:	e8a2                	sd	s0,80(sp)
    80001fe0:	e4a6                	sd	s1,72(sp)
    80001fe2:	e0ca                	sd	s2,64(sp)
    80001fe4:	fc4e                	sd	s3,56(sp)
    80001fe6:	f852                	sd	s4,48(sp)
    80001fe8:	f456                	sd	s5,40(sp)
    80001fea:	f05a                	sd	s6,32(sp)
    80001fec:	ec5e                	sd	s7,24(sp)
    80001fee:	e862                	sd	s8,16(sp)
    80001ff0:	e466                	sd	s9,8(sp)
    80001ff2:	e06a                	sd	s10,0(sp)
    80001ff4:	1080                	addi	s0,sp,96
    80001ff6:	8792                	mv	a5,tp
  int id = r_tp();
    80001ff8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ffa:	00779c93          	slli	s9,a5,0x7
    80001ffe:	0000f717          	auipc	a4,0xf
    80002002:	2a270713          	addi	a4,a4,674 # 800112a0 <pid_lock>
    80002006:	9766                	add	a4,a4,s9
    80002008:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &pNext->context);
    8000200c:	0000f717          	auipc	a4,0xf
    80002010:	2cc70713          	addi	a4,a4,716 # 800112d8 <cpus+0x8>
    80002014:	9cba                	add	s9,s9,a4
    struct proc *pNext = proc;
    80002016:	0000fb17          	auipc	s6,0xf
    8000201a:	6bab0b13          	addi	s6,s6,1722 # 800116d0 <proc>
    minCounter = 999999999;
    8000201e:	3b9adbb7          	lui	s7,0x3b9ad
    80002022:	9ffb8b93          	addi	s7,s7,-1537 # 3b9ac9ff <_entry-0x44653601>
      if(p->state == RUNNABLE && p->FCFSCounter < minCounter){
    80002026:	490d                	li	s2,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80002028:	00016997          	auipc	s3,0x16
    8000202c:	8a898993          	addi	s3,s3,-1880 # 800178d0 <tickslock>
      pNext->state = RUNNING;
    80002030:	4d11                	li	s10,4
      c->proc = pNext;
    80002032:	079e                	slli	a5,a5,0x7
    80002034:	0000fc17          	auipc	s8,0xf
    80002038:	26cc0c13          	addi	s8,s8,620 # 800112a0 <pid_lock>
    8000203c:	9c3e                	add	s8,s8,a5
    8000203e:	a0ad                	j	800020a8 <scheduler+0xce>
      release(&p->lock);
    80002040:	8526                	mv	a0,s1
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	c34080e7          	jalr	-972(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000204a:	18848493          	addi	s1,s1,392
    8000204e:	03348163          	beq	s1,s3,80002070 <scheduler+0x96>
      acquire(&p->lock);
    80002052:	8526                	mv	a0,s1
    80002054:	fffff097          	auipc	ra,0xfffff
    80002058:	b6e080e7          	jalr	-1170(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE && p->FCFSCounter < minCounter){
    8000205c:	4c9c                	lw	a5,24(s1)
    8000205e:	ff2791e3          	bne	a5,s2,80002040 <scheduler+0x66>
    80002062:	1804a783          	lw	a5,384(s1)
    80002066:	fd47dde3          	bge	a5,s4,80002040 <scheduler+0x66>
    8000206a:	8aa6                	mv	s5,s1
        minCounter = p->FCFSCounter;
    8000206c:	8a3e                	mv	s4,a5
    8000206e:	bfc9                	j	80002040 <scheduler+0x66>
    acquire(&pNext->lock);
    80002070:	84d6                	mv	s1,s5
    80002072:	8556                	mv	a0,s5
    80002074:	fffff097          	auipc	ra,0xfffff
    80002078:	b4e080e7          	jalr	-1202(ra) # 80000bc2 <acquire>
    if(pNext->state == RUNNABLE) {
    8000207c:	018aa783          	lw	a5,24(s5)
    80002080:	01279f63          	bne	a5,s2,8000209e <scheduler+0xc4>
      pNext->state = RUNNING;
    80002084:	01aaac23          	sw	s10,24(s5)
      c->proc = pNext;
    80002088:	035c3823          	sd	s5,48(s8)
      swtch(&c->context, &pNext->context);
    8000208c:	060a8593          	addi	a1,s5,96
    80002090:	8566                	mv	a0,s9
    80002092:	00001097          	auipc	ra,0x1
    80002096:	894080e7          	jalr	-1900(ra) # 80002926 <swtch>
      c->proc = 0;
    8000209a:	020c3823          	sd	zero,48(s8)
    release(&pNext->lock);
    8000209e:	8526                	mv	a0,s1
    800020a0:	fffff097          	auipc	ra,0xfffff
    800020a4:	bd6080e7          	jalr	-1066(ra) # 80000c76 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020a8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020ac:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020b0:	10079073          	csrw	sstatus,a5
    struct proc *pNext = proc;
    800020b4:	8ada                	mv	s5,s6
    minCounter = 999999999;
    800020b6:	8a5e                	mv	s4,s7
    for(p = proc; p < &proc[NPROC]; p++) {
    800020b8:	84da                	mv	s1,s6
    800020ba:	bf61                	j	80002052 <scheduler+0x78>

00000000800020bc <sched>:
{
    800020bc:	7179                	addi	sp,sp,-48
    800020be:	f406                	sd	ra,40(sp)
    800020c0:	f022                	sd	s0,32(sp)
    800020c2:	ec26                	sd	s1,24(sp)
    800020c4:	e84a                	sd	s2,16(sp)
    800020c6:	e44e                	sd	s3,8(sp)
    800020c8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020ca:	00000097          	auipc	ra,0x0
    800020ce:	8b4080e7          	jalr	-1868(ra) # 8000197e <myproc>
    800020d2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800020d4:	fffff097          	auipc	ra,0xfffff
    800020d8:	a74080e7          	jalr	-1420(ra) # 80000b48 <holding>
    800020dc:	c93d                	beqz	a0,80002152 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020de:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020e0:	2781                	sext.w	a5,a5
    800020e2:	079e                	slli	a5,a5,0x7
    800020e4:	0000f717          	auipc	a4,0xf
    800020e8:	1bc70713          	addi	a4,a4,444 # 800112a0 <pid_lock>
    800020ec:	97ba                	add	a5,a5,a4
    800020ee:	0a87a703          	lw	a4,168(a5)
    800020f2:	4785                	li	a5,1
    800020f4:	06f71763          	bne	a4,a5,80002162 <sched+0xa6>
  if(p->state == RUNNING)
    800020f8:	4c98                	lw	a4,24(s1)
    800020fa:	4791                	li	a5,4
    800020fc:	06f70b63          	beq	a4,a5,80002172 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002100:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002104:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002106:	efb5                	bnez	a5,80002182 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002108:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000210a:	0000f917          	auipc	s2,0xf
    8000210e:	19690913          	addi	s2,s2,406 # 800112a0 <pid_lock>
    80002112:	2781                	sext.w	a5,a5
    80002114:	079e                	slli	a5,a5,0x7
    80002116:	97ca                	add	a5,a5,s2
    80002118:	0ac7a983          	lw	s3,172(a5)
    8000211c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000211e:	2781                	sext.w	a5,a5
    80002120:	079e                	slli	a5,a5,0x7
    80002122:	0000f597          	auipc	a1,0xf
    80002126:	1b658593          	addi	a1,a1,438 # 800112d8 <cpus+0x8>
    8000212a:	95be                	add	a1,a1,a5
    8000212c:	06048513          	addi	a0,s1,96
    80002130:	00000097          	auipc	ra,0x0
    80002134:	7f6080e7          	jalr	2038(ra) # 80002926 <swtch>
    80002138:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000213a:	2781                	sext.w	a5,a5
    8000213c:	079e                	slli	a5,a5,0x7
    8000213e:	97ca                	add	a5,a5,s2
    80002140:	0b37a623          	sw	s3,172(a5)
}
    80002144:	70a2                	ld	ra,40(sp)
    80002146:	7402                	ld	s0,32(sp)
    80002148:	64e2                	ld	s1,24(sp)
    8000214a:	6942                	ld	s2,16(sp)
    8000214c:	69a2                	ld	s3,8(sp)
    8000214e:	6145                	addi	sp,sp,48
    80002150:	8082                	ret
    panic("sched p->lock");
    80002152:	00006517          	auipc	a0,0x6
    80002156:	0ae50513          	addi	a0,a0,174 # 80008200 <digits+0x1c0>
    8000215a:	ffffe097          	auipc	ra,0xffffe
    8000215e:	3d0080e7          	jalr	976(ra) # 8000052a <panic>
    panic("sched locks");
    80002162:	00006517          	auipc	a0,0x6
    80002166:	0ae50513          	addi	a0,a0,174 # 80008210 <digits+0x1d0>
    8000216a:	ffffe097          	auipc	ra,0xffffe
    8000216e:	3c0080e7          	jalr	960(ra) # 8000052a <panic>
    panic("sched running");
    80002172:	00006517          	auipc	a0,0x6
    80002176:	0ae50513          	addi	a0,a0,174 # 80008220 <digits+0x1e0>
    8000217a:	ffffe097          	auipc	ra,0xffffe
    8000217e:	3b0080e7          	jalr	944(ra) # 8000052a <panic>
    panic("sched interruptible");
    80002182:	00006517          	auipc	a0,0x6
    80002186:	0ae50513          	addi	a0,a0,174 # 80008230 <digits+0x1f0>
    8000218a:	ffffe097          	auipc	ra,0xffffe
    8000218e:	3a0080e7          	jalr	928(ra) # 8000052a <panic>

0000000080002192 <yield>:
{
    80002192:	1101                	addi	sp,sp,-32
    80002194:	ec06                	sd	ra,24(sp)
    80002196:	e822                	sd	s0,16(sp)
    80002198:	e426                	sd	s1,8(sp)
    8000219a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	7e2080e7          	jalr	2018(ra) # 8000197e <myproc>
    800021a4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021a6:	fffff097          	auipc	ra,0xfffff
    800021aa:	a1c080e7          	jalr	-1508(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    800021ae:	478d                	li	a5,3
    800021b0:	cc9c                	sw	a5,24(s1)
  p->FCFSCounter = FCFSIdCounter; //added in assign1.4
    800021b2:	00006717          	auipc	a4,0x6
    800021b6:	78670713          	addi	a4,a4,1926 # 80008938 <FCFSIdCounter>
    800021ba:	431c                	lw	a5,0(a4)
    800021bc:	18f4a023          	sw	a5,384(s1)
  FCFSIdCounter++;
    800021c0:	2785                	addiw	a5,a5,1
    800021c2:	c31c                	sw	a5,0(a4)
  sched();
    800021c4:	00000097          	auipc	ra,0x0
    800021c8:	ef8080e7          	jalr	-264(ra) # 800020bc <sched>
  release(&p->lock);
    800021cc:	8526                	mv	a0,s1
    800021ce:	fffff097          	auipc	ra,0xfffff
    800021d2:	aa8080e7          	jalr	-1368(ra) # 80000c76 <release>
}
    800021d6:	60e2                	ld	ra,24(sp)
    800021d8:	6442                	ld	s0,16(sp)
    800021da:	64a2                	ld	s1,8(sp)
    800021dc:	6105                	addi	sp,sp,32
    800021de:	8082                	ret

00000000800021e0 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800021e0:	7179                	addi	sp,sp,-48
    800021e2:	f406                	sd	ra,40(sp)
    800021e4:	f022                	sd	s0,32(sp)
    800021e6:	ec26                	sd	s1,24(sp)
    800021e8:	e84a                	sd	s2,16(sp)
    800021ea:	e44e                	sd	s3,8(sp)
    800021ec:	1800                	addi	s0,sp,48
    800021ee:	89aa                	mv	s3,a0
    800021f0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800021f2:	fffff097          	auipc	ra,0xfffff
    800021f6:	78c080e7          	jalr	1932(ra) # 8000197e <myproc>
    800021fa:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800021fc:	fffff097          	auipc	ra,0xfffff
    80002200:	9c6080e7          	jalr	-1594(ra) # 80000bc2 <acquire>
  release(lk);
    80002204:	854a                	mv	a0,s2
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	a70080e7          	jalr	-1424(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    8000220e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002212:	4789                	li	a5,2
    80002214:	cc9c                	sw	a5,24(s1)
    
  sched();
    80002216:	00000097          	auipc	ra,0x0
    8000221a:	ea6080e7          	jalr	-346(ra) # 800020bc <sched>

  // Tidy up.
  p->chan = 0;
    8000221e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002222:	8526                	mv	a0,s1
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	a52080e7          	jalr	-1454(ra) # 80000c76 <release>
  acquire(lk);
    8000222c:	854a                	mv	a0,s2
    8000222e:	fffff097          	auipc	ra,0xfffff
    80002232:	994080e7          	jalr	-1644(ra) # 80000bc2 <acquire>
}
    80002236:	70a2                	ld	ra,40(sp)
    80002238:	7402                	ld	s0,32(sp)
    8000223a:	64e2                	ld	s1,24(sp)
    8000223c:	6942                	ld	s2,16(sp)
    8000223e:	69a2                	ld	s3,8(sp)
    80002240:	6145                	addi	sp,sp,48
    80002242:	8082                	ret

0000000080002244 <wait_stat>:
wait_stat(uint64 status, struct perf *perf){
    80002244:	711d                	addi	sp,sp,-96
    80002246:	ec86                	sd	ra,88(sp)
    80002248:	e8a2                	sd	s0,80(sp)
    8000224a:	e4a6                	sd	s1,72(sp)
    8000224c:	e0ca                	sd	s2,64(sp)
    8000224e:	fc4e                	sd	s3,56(sp)
    80002250:	f852                	sd	s4,48(sp)
    80002252:	f456                	sd	s5,40(sp)
    80002254:	f05a                	sd	s6,32(sp)
    80002256:	ec5e                	sd	s7,24(sp)
    80002258:	e862                	sd	s8,16(sp)
    8000225a:	1080                	addi	s0,sp,96
    8000225c:	faa43423          	sd	a0,-88(s0)
    80002260:	8bae                	mv	s7,a1
  struct proc *p = myproc();
    80002262:	fffff097          	auipc	ra,0xfffff
    80002266:	71c080e7          	jalr	1820(ra) # 8000197e <myproc>
    8000226a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000226c:	0000f517          	auipc	a0,0xf
    80002270:	04c50513          	addi	a0,a0,76 # 800112b8 <wait_lock>
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	94e080e7          	jalr	-1714(ra) # 80000bc2 <acquire>
    havekids = 0;
    8000227c:	4b01                	li	s6,0
        if(np->state == ZOMBIE){
    8000227e:	4a15                	li	s4,5
        havekids = 1;
    80002280:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002282:	00015997          	auipc	s3,0x15
    80002286:	64e98993          	addi	s3,s3,1614 # 800178d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000228a:	0000fc17          	auipc	s8,0xf
    8000228e:	02ec0c13          	addi	s8,s8,46 # 800112b8 <wait_lock>
    havekids = 0;
    80002292:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    80002294:	0000f497          	auipc	s1,0xf
    80002298:	43c48493          	addi	s1,s1,1084 # 800116d0 <proc>
    8000229c:	a8d5                	j	80002390 <wait_stat+0x14c>
          copyout(p->pagetable, (uint64)perf, (char*)&np->ctime, sizeof(np->ctime));
    8000229e:	4691                	li	a3,4
    800022a0:	16848613          	addi	a2,s1,360
    800022a4:	85de                	mv	a1,s7
    800022a6:	05093503          	ld	a0,80(s2)
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	394080e7          	jalr	916(ra) # 8000163e <copyout>
          copyout(p->pagetable, (uint64)perf + sizeof(int), (char*)&np->ttime, sizeof(np->ttime));
    800022b2:	4691                	li	a3,4
    800022b4:	16c48613          	addi	a2,s1,364
    800022b8:	004b8593          	addi	a1,s7,4
    800022bc:	05093503          	ld	a0,80(s2)
    800022c0:	fffff097          	auipc	ra,0xfffff
    800022c4:	37e080e7          	jalr	894(ra) # 8000163e <copyout>
          copyout(p->pagetable, (uint64)perf + 2 * sizeof(int), (char*)&np->stime, sizeof(np->stime));
    800022c8:	4691                	li	a3,4
    800022ca:	17048613          	addi	a2,s1,368
    800022ce:	008b8593          	addi	a1,s7,8
    800022d2:	05093503          	ld	a0,80(s2)
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	368080e7          	jalr	872(ra) # 8000163e <copyout>
          copyout(p->pagetable, (uint64)perf + 3 * sizeof(int), (char*)&np->retime, sizeof(np->retime));
    800022de:	4691                	li	a3,4
    800022e0:	17448613          	addi	a2,s1,372
    800022e4:	00cb8593          	addi	a1,s7,12
    800022e8:	05093503          	ld	a0,80(s2)
    800022ec:	fffff097          	auipc	ra,0xfffff
    800022f0:	352080e7          	jalr	850(ra) # 8000163e <copyout>
          copyout(p->pagetable, (uint64)perf + 4 * sizeof(int), (char*)&np->rutime, sizeof(np->rutime));
    800022f4:	4691                	li	a3,4
    800022f6:	17848613          	addi	a2,s1,376
    800022fa:	010b8593          	addi	a1,s7,16
    800022fe:	05093503          	ld	a0,80(s2)
    80002302:	fffff097          	auipc	ra,0xfffff
    80002306:	33c080e7          	jalr	828(ra) # 8000163e <copyout>
          copyout(p->pagetable, (uint64)perf + 5 * sizeof(int), (char*)&np->average_bursttime, sizeof(np->average_bursttime));
    8000230a:	4691                	li	a3,4
    8000230c:	17c48613          	addi	a2,s1,380
    80002310:	014b8593          	addi	a1,s7,20
    80002314:	05093503          	ld	a0,80(s2)
    80002318:	fffff097          	auipc	ra,0xfffff
    8000231c:	326080e7          	jalr	806(ra) # 8000163e <copyout>
          pid = np->pid;
    80002320:	0304a983          	lw	s3,48(s1)
          if(status != 0 && copyout(p->pagetable, (uint64)&status, (char *)&np->xstate, sizeof(np->xstate)) < 0) {
    80002324:	fa843783          	ld	a5,-88(s0)
    80002328:	cf91                	beqz	a5,80002344 <wait_stat+0x100>
    8000232a:	4691                	li	a3,4
    8000232c:	02c48613          	addi	a2,s1,44
    80002330:	fa840593          	addi	a1,s0,-88
    80002334:	05093503          	ld	a0,80(s2)
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	306080e7          	jalr	774(ra) # 8000163e <copyout>
    80002340:	02054563          	bltz	a0,8000236a <wait_stat+0x126>
          freeproc(np);
    80002344:	8526                	mv	a0,s1
    80002346:	00000097          	auipc	ra,0x0
    8000234a:	8d6080e7          	jalr	-1834(ra) # 80001c1c <freeproc>
          release(&np->lock);
    8000234e:	8526                	mv	a0,s1
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	926080e7          	jalr	-1754(ra) # 80000c76 <release>
          release(&wait_lock);
    80002358:	0000f517          	auipc	a0,0xf
    8000235c:	f6050513          	addi	a0,a0,-160 # 800112b8 <wait_lock>
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	916080e7          	jalr	-1770(ra) # 80000c76 <release>
          return pid;
    80002368:	a09d                	j	800023ce <wait_stat+0x18a>
            release(&np->lock);
    8000236a:	8526                	mv	a0,s1
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	90a080e7          	jalr	-1782(ra) # 80000c76 <release>
            release(&wait_lock);
    80002374:	0000f517          	auipc	a0,0xf
    80002378:	f4450513          	addi	a0,a0,-188 # 800112b8 <wait_lock>
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	8fa080e7          	jalr	-1798(ra) # 80000c76 <release>
            return -1;
    80002384:	59fd                	li	s3,-1
    80002386:	a0a1                	j	800023ce <wait_stat+0x18a>
    for(np = proc; np < &proc[NPROC]; np++){
    80002388:	18848493          	addi	s1,s1,392
    8000238c:	03348463          	beq	s1,s3,800023b4 <wait_stat+0x170>
      if(np->parent == p){
    80002390:	7c9c                	ld	a5,56(s1)
    80002392:	ff279be3          	bne	a5,s2,80002388 <wait_stat+0x144>
        acquire(&np->lock);
    80002396:	8526                	mv	a0,s1
    80002398:	fffff097          	auipc	ra,0xfffff
    8000239c:	82a080e7          	jalr	-2006(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    800023a0:	4c9c                	lw	a5,24(s1)
    800023a2:	ef478ee3          	beq	a5,s4,8000229e <wait_stat+0x5a>
        release(&np->lock);
    800023a6:	8526                	mv	a0,s1
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	8ce080e7          	jalr	-1842(ra) # 80000c76 <release>
        havekids = 1;
    800023b0:	8756                	mv	a4,s5
    800023b2:	bfd9                	j	80002388 <wait_stat+0x144>
    if(!havekids || p->killed){
    800023b4:	c701                	beqz	a4,800023bc <wait_stat+0x178>
    800023b6:	02892783          	lw	a5,40(s2)
    800023ba:	c79d                	beqz	a5,800023e8 <wait_stat+0x1a4>
      release(&wait_lock);
    800023bc:	0000f517          	auipc	a0,0xf
    800023c0:	efc50513          	addi	a0,a0,-260 # 800112b8 <wait_lock>
    800023c4:	fffff097          	auipc	ra,0xfffff
    800023c8:	8b2080e7          	jalr	-1870(ra) # 80000c76 <release>
      return -1;
    800023cc:	59fd                	li	s3,-1
}
    800023ce:	854e                	mv	a0,s3
    800023d0:	60e6                	ld	ra,88(sp)
    800023d2:	6446                	ld	s0,80(sp)
    800023d4:	64a6                	ld	s1,72(sp)
    800023d6:	6906                	ld	s2,64(sp)
    800023d8:	79e2                	ld	s3,56(sp)
    800023da:	7a42                	ld	s4,48(sp)
    800023dc:	7aa2                	ld	s5,40(sp)
    800023de:	7b02                	ld	s6,32(sp)
    800023e0:	6be2                	ld	s7,24(sp)
    800023e2:	6c42                	ld	s8,16(sp)
    800023e4:	6125                	addi	sp,sp,96
    800023e6:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023e8:	85e2                	mv	a1,s8
    800023ea:	854a                	mv	a0,s2
    800023ec:	00000097          	auipc	ra,0x0
    800023f0:	df4080e7          	jalr	-524(ra) # 800021e0 <sleep>
    havekids = 0;
    800023f4:	bd79                	j	80002292 <wait_stat+0x4e>

00000000800023f6 <wait>:
{
    800023f6:	715d                	addi	sp,sp,-80
    800023f8:	e486                	sd	ra,72(sp)
    800023fa:	e0a2                	sd	s0,64(sp)
    800023fc:	fc26                	sd	s1,56(sp)
    800023fe:	f84a                	sd	s2,48(sp)
    80002400:	f44e                	sd	s3,40(sp)
    80002402:	f052                	sd	s4,32(sp)
    80002404:	ec56                	sd	s5,24(sp)
    80002406:	e85a                	sd	s6,16(sp)
    80002408:	e45e                	sd	s7,8(sp)
    8000240a:	e062                	sd	s8,0(sp)
    8000240c:	0880                	addi	s0,sp,80
    8000240e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	56e080e7          	jalr	1390(ra) # 8000197e <myproc>
    80002418:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000241a:	0000f517          	auipc	a0,0xf
    8000241e:	e9e50513          	addi	a0,a0,-354 # 800112b8 <wait_lock>
    80002422:	ffffe097          	auipc	ra,0xffffe
    80002426:	7a0080e7          	jalr	1952(ra) # 80000bc2 <acquire>
    havekids = 0;
    8000242a:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000242c:	4a15                	li	s4,5
        havekids = 1;
    8000242e:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002430:	00015997          	auipc	s3,0x15
    80002434:	4a098993          	addi	s3,s3,1184 # 800178d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002438:	0000fc17          	auipc	s8,0xf
    8000243c:	e80c0c13          	addi	s8,s8,-384 # 800112b8 <wait_lock>
    havekids = 0;
    80002440:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002442:	0000f497          	auipc	s1,0xf
    80002446:	28e48493          	addi	s1,s1,654 # 800116d0 <proc>
    8000244a:	a0bd                	j	800024b8 <wait+0xc2>
          pid = np->pid;
    8000244c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002450:	000b0e63          	beqz	s6,8000246c <wait+0x76>
    80002454:	4691                	li	a3,4
    80002456:	02c48613          	addi	a2,s1,44
    8000245a:	85da                	mv	a1,s6
    8000245c:	05093503          	ld	a0,80(s2)
    80002460:	fffff097          	auipc	ra,0xfffff
    80002464:	1de080e7          	jalr	478(ra) # 8000163e <copyout>
    80002468:	02054563          	bltz	a0,80002492 <wait+0x9c>
          freeproc(np);
    8000246c:	8526                	mv	a0,s1
    8000246e:	fffff097          	auipc	ra,0xfffff
    80002472:	7ae080e7          	jalr	1966(ra) # 80001c1c <freeproc>
          release(&np->lock);
    80002476:	8526                	mv	a0,s1
    80002478:	ffffe097          	auipc	ra,0xffffe
    8000247c:	7fe080e7          	jalr	2046(ra) # 80000c76 <release>
          release(&wait_lock);
    80002480:	0000f517          	auipc	a0,0xf
    80002484:	e3850513          	addi	a0,a0,-456 # 800112b8 <wait_lock>
    80002488:	ffffe097          	auipc	ra,0xffffe
    8000248c:	7ee080e7          	jalr	2030(ra) # 80000c76 <release>
          return pid;
    80002490:	a09d                	j	800024f6 <wait+0x100>
            release(&np->lock);
    80002492:	8526                	mv	a0,s1
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	7e2080e7          	jalr	2018(ra) # 80000c76 <release>
            release(&wait_lock);
    8000249c:	0000f517          	auipc	a0,0xf
    800024a0:	e1c50513          	addi	a0,a0,-484 # 800112b8 <wait_lock>
    800024a4:	ffffe097          	auipc	ra,0xffffe
    800024a8:	7d2080e7          	jalr	2002(ra) # 80000c76 <release>
            return -1;
    800024ac:	59fd                	li	s3,-1
    800024ae:	a0a1                	j	800024f6 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800024b0:	18848493          	addi	s1,s1,392
    800024b4:	03348463          	beq	s1,s3,800024dc <wait+0xe6>
      if(np->parent == p){
    800024b8:	7c9c                	ld	a5,56(s1)
    800024ba:	ff279be3          	bne	a5,s2,800024b0 <wait+0xba>
        acquire(&np->lock);
    800024be:	8526                	mv	a0,s1
    800024c0:	ffffe097          	auipc	ra,0xffffe
    800024c4:	702080e7          	jalr	1794(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    800024c8:	4c9c                	lw	a5,24(s1)
    800024ca:	f94781e3          	beq	a5,s4,8000244c <wait+0x56>
        release(&np->lock);
    800024ce:	8526                	mv	a0,s1
    800024d0:	ffffe097          	auipc	ra,0xffffe
    800024d4:	7a6080e7          	jalr	1958(ra) # 80000c76 <release>
        havekids = 1;
    800024d8:	8756                	mv	a4,s5
    800024da:	bfd9                	j	800024b0 <wait+0xba>
    if(!havekids || p->killed){
    800024dc:	c701                	beqz	a4,800024e4 <wait+0xee>
    800024de:	02892783          	lw	a5,40(s2)
    800024e2:	c79d                	beqz	a5,80002510 <wait+0x11a>
      release(&wait_lock);
    800024e4:	0000f517          	auipc	a0,0xf
    800024e8:	dd450513          	addi	a0,a0,-556 # 800112b8 <wait_lock>
    800024ec:	ffffe097          	auipc	ra,0xffffe
    800024f0:	78a080e7          	jalr	1930(ra) # 80000c76 <release>
      return -1;
    800024f4:	59fd                	li	s3,-1
}
    800024f6:	854e                	mv	a0,s3
    800024f8:	60a6                	ld	ra,72(sp)
    800024fa:	6406                	ld	s0,64(sp)
    800024fc:	74e2                	ld	s1,56(sp)
    800024fe:	7942                	ld	s2,48(sp)
    80002500:	79a2                	ld	s3,40(sp)
    80002502:	7a02                	ld	s4,32(sp)
    80002504:	6ae2                	ld	s5,24(sp)
    80002506:	6b42                	ld	s6,16(sp)
    80002508:	6ba2                	ld	s7,8(sp)
    8000250a:	6c02                	ld	s8,0(sp)
    8000250c:	6161                	addi	sp,sp,80
    8000250e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002510:	85e2                	mv	a1,s8
    80002512:	854a                	mv	a0,s2
    80002514:	00000097          	auipc	ra,0x0
    80002518:	ccc080e7          	jalr	-820(ra) # 800021e0 <sleep>
    havekids = 0;
    8000251c:	b715                	j	80002440 <wait+0x4a>

000000008000251e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000251e:	7139                	addi	sp,sp,-64
    80002520:	fc06                	sd	ra,56(sp)
    80002522:	f822                	sd	s0,48(sp)
    80002524:	f426                	sd	s1,40(sp)
    80002526:	f04a                	sd	s2,32(sp)
    80002528:	ec4e                	sd	s3,24(sp)
    8000252a:	e852                	sd	s4,16(sp)
    8000252c:	e456                	sd	s5,8(sp)
    8000252e:	e05a                	sd	s6,0(sp)
    80002530:	0080                	addi	s0,sp,64
    80002532:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002534:	0000f497          	auipc	s1,0xf
    80002538:	19c48493          	addi	s1,s1,412 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000253c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000253e:	4b0d                	li	s6,3

        p->FCFSCounter = FCFSIdCounter; //added in assign1.4
    80002540:	00006a97          	auipc	s5,0x6
    80002544:	3f8a8a93          	addi	s5,s5,1016 # 80008938 <FCFSIdCounter>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002548:	00015917          	auipc	s2,0x15
    8000254c:	38890913          	addi	s2,s2,904 # 800178d0 <tickslock>
    80002550:	a811                	j	80002564 <wakeup+0x46>
        FCFSIdCounter++;
      }
      release(&p->lock);
    80002552:	8526                	mv	a0,s1
    80002554:	ffffe097          	auipc	ra,0xffffe
    80002558:	722080e7          	jalr	1826(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000255c:	18848493          	addi	s1,s1,392
    80002560:	03248d63          	beq	s1,s2,8000259a <wakeup+0x7c>
    if(p != myproc()){
    80002564:	fffff097          	auipc	ra,0xfffff
    80002568:	41a080e7          	jalr	1050(ra) # 8000197e <myproc>
    8000256c:	fea488e3          	beq	s1,a0,8000255c <wakeup+0x3e>
      acquire(&p->lock);
    80002570:	8526                	mv	a0,s1
    80002572:	ffffe097          	auipc	ra,0xffffe
    80002576:	650080e7          	jalr	1616(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000257a:	4c9c                	lw	a5,24(s1)
    8000257c:	fd379be3          	bne	a5,s3,80002552 <wakeup+0x34>
    80002580:	709c                	ld	a5,32(s1)
    80002582:	fd4798e3          	bne	a5,s4,80002552 <wakeup+0x34>
        p->state = RUNNABLE;
    80002586:	0164ac23          	sw	s6,24(s1)
        p->FCFSCounter = FCFSIdCounter; //added in assign1.4
    8000258a:	000aa783          	lw	a5,0(s5)
    8000258e:	18f4a023          	sw	a5,384(s1)
        FCFSIdCounter++;
    80002592:	2785                	addiw	a5,a5,1
    80002594:	00faa023          	sw	a5,0(s5)
    80002598:	bf6d                	j	80002552 <wakeup+0x34>
    }
  }
}
    8000259a:	70e2                	ld	ra,56(sp)
    8000259c:	7442                	ld	s0,48(sp)
    8000259e:	74a2                	ld	s1,40(sp)
    800025a0:	7902                	ld	s2,32(sp)
    800025a2:	69e2                	ld	s3,24(sp)
    800025a4:	6a42                	ld	s4,16(sp)
    800025a6:	6aa2                	ld	s5,8(sp)
    800025a8:	6b02                	ld	s6,0(sp)
    800025aa:	6121                	addi	sp,sp,64
    800025ac:	8082                	ret

00000000800025ae <reparent>:
{
    800025ae:	7179                	addi	sp,sp,-48
    800025b0:	f406                	sd	ra,40(sp)
    800025b2:	f022                	sd	s0,32(sp)
    800025b4:	ec26                	sd	s1,24(sp)
    800025b6:	e84a                	sd	s2,16(sp)
    800025b8:	e44e                	sd	s3,8(sp)
    800025ba:	e052                	sd	s4,0(sp)
    800025bc:	1800                	addi	s0,sp,48
    800025be:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800025c0:	0000f497          	auipc	s1,0xf
    800025c4:	11048493          	addi	s1,s1,272 # 800116d0 <proc>
      pp->parent = initproc;
    800025c8:	00007a17          	auipc	s4,0x7
    800025cc:	a60a0a13          	addi	s4,s4,-1440 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800025d0:	00015997          	auipc	s3,0x15
    800025d4:	30098993          	addi	s3,s3,768 # 800178d0 <tickslock>
    800025d8:	a029                	j	800025e2 <reparent+0x34>
    800025da:	18848493          	addi	s1,s1,392
    800025de:	01348d63          	beq	s1,s3,800025f8 <reparent+0x4a>
    if(pp->parent == p){
    800025e2:	7c9c                	ld	a5,56(s1)
    800025e4:	ff279be3          	bne	a5,s2,800025da <reparent+0x2c>
      pp->parent = initproc;
    800025e8:	000a3503          	ld	a0,0(s4)
    800025ec:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800025ee:	00000097          	auipc	ra,0x0
    800025f2:	f30080e7          	jalr	-208(ra) # 8000251e <wakeup>
    800025f6:	b7d5                	j	800025da <reparent+0x2c>
}
    800025f8:	70a2                	ld	ra,40(sp)
    800025fa:	7402                	ld	s0,32(sp)
    800025fc:	64e2                	ld	s1,24(sp)
    800025fe:	6942                	ld	s2,16(sp)
    80002600:	69a2                	ld	s3,8(sp)
    80002602:	6a02                	ld	s4,0(sp)
    80002604:	6145                	addi	sp,sp,48
    80002606:	8082                	ret

0000000080002608 <exit>:
{
    80002608:	7179                	addi	sp,sp,-48
    8000260a:	f406                	sd	ra,40(sp)
    8000260c:	f022                	sd	s0,32(sp)
    8000260e:	ec26                	sd	s1,24(sp)
    80002610:	e84a                	sd	s2,16(sp)
    80002612:	e44e                	sd	s3,8(sp)
    80002614:	e052                	sd	s4,0(sp)
    80002616:	1800                	addi	s0,sp,48
    80002618:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000261a:	fffff097          	auipc	ra,0xfffff
    8000261e:	364080e7          	jalr	868(ra) # 8000197e <myproc>
    80002622:	89aa                	mv	s3,a0
  if(p == initproc)
    80002624:	00007797          	auipc	a5,0x7
    80002628:	a047b783          	ld	a5,-1532(a5) # 80009028 <initproc>
    8000262c:	0d050493          	addi	s1,a0,208
    80002630:	15050913          	addi	s2,a0,336
    80002634:	02a79363          	bne	a5,a0,8000265a <exit+0x52>
    panic("init exiting");
    80002638:	00006517          	auipc	a0,0x6
    8000263c:	c1050513          	addi	a0,a0,-1008 # 80008248 <digits+0x208>
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	eea080e7          	jalr	-278(ra) # 8000052a <panic>
      fileclose(f);
    80002648:	00002097          	auipc	ra,0x2
    8000264c:	312080e7          	jalr	786(ra) # 8000495a <fileclose>
      p->ofile[fd] = 0;
    80002650:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002654:	04a1                	addi	s1,s1,8
    80002656:	01248563          	beq	s1,s2,80002660 <exit+0x58>
    if(p->ofile[fd]){
    8000265a:	6088                	ld	a0,0(s1)
    8000265c:	f575                	bnez	a0,80002648 <exit+0x40>
    8000265e:	bfdd                	j	80002654 <exit+0x4c>
  begin_op();
    80002660:	00002097          	auipc	ra,0x2
    80002664:	e2e080e7          	jalr	-466(ra) # 8000448e <begin_op>
  iput(p->cwd);
    80002668:	1509b503          	ld	a0,336(s3)
    8000266c:	00001097          	auipc	ra,0x1
    80002670:	606080e7          	jalr	1542(ra) # 80003c72 <iput>
  end_op();
    80002674:	00002097          	auipc	ra,0x2
    80002678:	e9a080e7          	jalr	-358(ra) # 8000450e <end_op>
  p->cwd = 0;
    8000267c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002680:	0000f497          	auipc	s1,0xf
    80002684:	c3848493          	addi	s1,s1,-968 # 800112b8 <wait_lock>
    80002688:	8526                	mv	a0,s1
    8000268a:	ffffe097          	auipc	ra,0xffffe
    8000268e:	538080e7          	jalr	1336(ra) # 80000bc2 <acquire>
  reparent(p);
    80002692:	854e                	mv	a0,s3
    80002694:	00000097          	auipc	ra,0x0
    80002698:	f1a080e7          	jalr	-230(ra) # 800025ae <reparent>
  wakeup(p->parent);
    8000269c:	0389b503          	ld	a0,56(s3)
    800026a0:	00000097          	auipc	ra,0x0
    800026a4:	e7e080e7          	jalr	-386(ra) # 8000251e <wakeup>
  acquire(&p->lock);
    800026a8:	854e                	mv	a0,s3
    800026aa:	ffffe097          	auipc	ra,0xffffe
    800026ae:	518080e7          	jalr	1304(ra) # 80000bc2 <acquire>
  p->xstate = status;
    800026b2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800026b6:	4795                	li	a5,5
    800026b8:	00f9ac23          	sw	a5,24(s3)
  p->ttime = ticks;// added in assign1
    800026bc:	00007797          	auipc	a5,0x7
    800026c0:	9747a783          	lw	a5,-1676(a5) # 80009030 <ticks>
    800026c4:	16f9a623          	sw	a5,364(s3)
  release(&wait_lock);
    800026c8:	8526                	mv	a0,s1
    800026ca:	ffffe097          	auipc	ra,0xffffe
    800026ce:	5ac080e7          	jalr	1452(ra) # 80000c76 <release>
  sched();
    800026d2:	00000097          	auipc	ra,0x0
    800026d6:	9ea080e7          	jalr	-1558(ra) # 800020bc <sched>
  panic("zombie exit");
    800026da:	00006517          	auipc	a0,0x6
    800026de:	b7e50513          	addi	a0,a0,-1154 # 80008258 <digits+0x218>
    800026e2:	ffffe097          	auipc	ra,0xffffe
    800026e6:	e48080e7          	jalr	-440(ra) # 8000052a <panic>

00000000800026ea <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800026ea:	7179                	addi	sp,sp,-48
    800026ec:	f406                	sd	ra,40(sp)
    800026ee:	f022                	sd	s0,32(sp)
    800026f0:	ec26                	sd	s1,24(sp)
    800026f2:	e84a                	sd	s2,16(sp)
    800026f4:	e44e                	sd	s3,8(sp)
    800026f6:	1800                	addi	s0,sp,48
    800026f8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800026fa:	0000f497          	auipc	s1,0xf
    800026fe:	fd648493          	addi	s1,s1,-42 # 800116d0 <proc>
    80002702:	00015997          	auipc	s3,0x15
    80002706:	1ce98993          	addi	s3,s3,462 # 800178d0 <tickslock>
    acquire(&p->lock);
    8000270a:	8526                	mv	a0,s1
    8000270c:	ffffe097          	auipc	ra,0xffffe
    80002710:	4b6080e7          	jalr	1206(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80002714:	589c                	lw	a5,48(s1)
    80002716:	01278d63          	beq	a5,s2,80002730 <kill+0x46>
        FCFSIdCounter++;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000271a:	8526                	mv	a0,s1
    8000271c:	ffffe097          	auipc	ra,0xffffe
    80002720:	55a080e7          	jalr	1370(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002724:	18848493          	addi	s1,s1,392
    80002728:	ff3491e3          	bne	s1,s3,8000270a <kill+0x20>
  }
  return -1;
    8000272c:	557d                	li	a0,-1
    8000272e:	a829                	j	80002748 <kill+0x5e>
      p->killed = 1;
    80002730:	4785                	li	a5,1
    80002732:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002734:	4c98                	lw	a4,24(s1)
    80002736:	4789                	li	a5,2
    80002738:	00f70f63          	beq	a4,a5,80002756 <kill+0x6c>
      release(&p->lock);
    8000273c:	8526                	mv	a0,s1
    8000273e:	ffffe097          	auipc	ra,0xffffe
    80002742:	538080e7          	jalr	1336(ra) # 80000c76 <release>
      return 0;
    80002746:	4501                	li	a0,0
}
    80002748:	70a2                	ld	ra,40(sp)
    8000274a:	7402                	ld	s0,32(sp)
    8000274c:	64e2                	ld	s1,24(sp)
    8000274e:	6942                	ld	s2,16(sp)
    80002750:	69a2                	ld	s3,8(sp)
    80002752:	6145                	addi	sp,sp,48
    80002754:	8082                	ret
        p->state = RUNNABLE;
    80002756:	478d                	li	a5,3
    80002758:	cc9c                	sw	a5,24(s1)
        p->FCFSCounter = FCFSIdCounter; //added in assign1.4
    8000275a:	00006717          	auipc	a4,0x6
    8000275e:	1de70713          	addi	a4,a4,478 # 80008938 <FCFSIdCounter>
    80002762:	431c                	lw	a5,0(a4)
    80002764:	18f4a023          	sw	a5,384(s1)
        FCFSIdCounter++;
    80002768:	2785                	addiw	a5,a5,1
    8000276a:	c31c                	sw	a5,0(a4)
    8000276c:	bfc1                	j	8000273c <kill+0x52>

000000008000276e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000276e:	7179                	addi	sp,sp,-48
    80002770:	f406                	sd	ra,40(sp)
    80002772:	f022                	sd	s0,32(sp)
    80002774:	ec26                	sd	s1,24(sp)
    80002776:	e84a                	sd	s2,16(sp)
    80002778:	e44e                	sd	s3,8(sp)
    8000277a:	e052                	sd	s4,0(sp)
    8000277c:	1800                	addi	s0,sp,48
    8000277e:	84aa                	mv	s1,a0
    80002780:	892e                	mv	s2,a1
    80002782:	89b2                	mv	s3,a2
    80002784:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002786:	fffff097          	auipc	ra,0xfffff
    8000278a:	1f8080e7          	jalr	504(ra) # 8000197e <myproc>
  if(user_dst){
    8000278e:	c08d                	beqz	s1,800027b0 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002790:	86d2                	mv	a3,s4
    80002792:	864e                	mv	a2,s3
    80002794:	85ca                	mv	a1,s2
    80002796:	6928                	ld	a0,80(a0)
    80002798:	fffff097          	auipc	ra,0xfffff
    8000279c:	ea6080e7          	jalr	-346(ra) # 8000163e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800027a0:	70a2                	ld	ra,40(sp)
    800027a2:	7402                	ld	s0,32(sp)
    800027a4:	64e2                	ld	s1,24(sp)
    800027a6:	6942                	ld	s2,16(sp)
    800027a8:	69a2                	ld	s3,8(sp)
    800027aa:	6a02                	ld	s4,0(sp)
    800027ac:	6145                	addi	sp,sp,48
    800027ae:	8082                	ret
    memmove((char *)dst, src, len);
    800027b0:	000a061b          	sext.w	a2,s4
    800027b4:	85ce                	mv	a1,s3
    800027b6:	854a                	mv	a0,s2
    800027b8:	ffffe097          	auipc	ra,0xffffe
    800027bc:	562080e7          	jalr	1378(ra) # 80000d1a <memmove>
    return 0;
    800027c0:	8526                	mv	a0,s1
    800027c2:	bff9                	j	800027a0 <either_copyout+0x32>

00000000800027c4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800027c4:	7179                	addi	sp,sp,-48
    800027c6:	f406                	sd	ra,40(sp)
    800027c8:	f022                	sd	s0,32(sp)
    800027ca:	ec26                	sd	s1,24(sp)
    800027cc:	e84a                	sd	s2,16(sp)
    800027ce:	e44e                	sd	s3,8(sp)
    800027d0:	e052                	sd	s4,0(sp)
    800027d2:	1800                	addi	s0,sp,48
    800027d4:	892a                	mv	s2,a0
    800027d6:	84ae                	mv	s1,a1
    800027d8:	89b2                	mv	s3,a2
    800027da:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027dc:	fffff097          	auipc	ra,0xfffff
    800027e0:	1a2080e7          	jalr	418(ra) # 8000197e <myproc>
  if(user_src){
    800027e4:	c08d                	beqz	s1,80002806 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800027e6:	86d2                	mv	a3,s4
    800027e8:	864e                	mv	a2,s3
    800027ea:	85ca                	mv	a1,s2
    800027ec:	6928                	ld	a0,80(a0)
    800027ee:	fffff097          	auipc	ra,0xfffff
    800027f2:	edc080e7          	jalr	-292(ra) # 800016ca <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800027f6:	70a2                	ld	ra,40(sp)
    800027f8:	7402                	ld	s0,32(sp)
    800027fa:	64e2                	ld	s1,24(sp)
    800027fc:	6942                	ld	s2,16(sp)
    800027fe:	69a2                	ld	s3,8(sp)
    80002800:	6a02                	ld	s4,0(sp)
    80002802:	6145                	addi	sp,sp,48
    80002804:	8082                	ret
    memmove(dst, (char*)src, len);
    80002806:	000a061b          	sext.w	a2,s4
    8000280a:	85ce                	mv	a1,s3
    8000280c:	854a                	mv	a0,s2
    8000280e:	ffffe097          	auipc	ra,0xffffe
    80002812:	50c080e7          	jalr	1292(ra) # 80000d1a <memmove>
    return 0;
    80002816:	8526                	mv	a0,s1
    80002818:	bff9                	j	800027f6 <either_copyin+0x32>

000000008000281a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000281a:	715d                	addi	sp,sp,-80
    8000281c:	e486                	sd	ra,72(sp)
    8000281e:	e0a2                	sd	s0,64(sp)
    80002820:	fc26                	sd	s1,56(sp)
    80002822:	f84a                	sd	s2,48(sp)
    80002824:	f44e                	sd	s3,40(sp)
    80002826:	f052                	sd	s4,32(sp)
    80002828:	ec56                	sd	s5,24(sp)
    8000282a:	e85a                	sd	s6,16(sp)
    8000282c:	e45e                	sd	s7,8(sp)
    8000282e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002830:	00006517          	auipc	a0,0x6
    80002834:	89850513          	addi	a0,a0,-1896 # 800080c8 <digits+0x88>
    80002838:	ffffe097          	auipc	ra,0xffffe
    8000283c:	d3c080e7          	jalr	-708(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002840:	0000f497          	auipc	s1,0xf
    80002844:	fe848493          	addi	s1,s1,-24 # 80011828 <proc+0x158>
    80002848:	00015917          	auipc	s2,0x15
    8000284c:	1e090913          	addi	s2,s2,480 # 80017a28 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002850:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002852:	00006997          	auipc	s3,0x6
    80002856:	a1698993          	addi	s3,s3,-1514 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    8000285a:	00006a97          	auipc	s5,0x6
    8000285e:	a16a8a93          	addi	s5,s5,-1514 # 80008270 <digits+0x230>
    printf("\n");
    80002862:	00006a17          	auipc	s4,0x6
    80002866:	866a0a13          	addi	s4,s4,-1946 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000286a:	00006b97          	auipc	s7,0x6
    8000286e:	a3eb8b93          	addi	s7,s7,-1474 # 800082a8 <states.0>
    80002872:	a00d                	j	80002894 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002874:	ed86a583          	lw	a1,-296(a3)
    80002878:	8556                	mv	a0,s5
    8000287a:	ffffe097          	auipc	ra,0xffffe
    8000287e:	cfa080e7          	jalr	-774(ra) # 80000574 <printf>
    printf("\n");
    80002882:	8552                	mv	a0,s4
    80002884:	ffffe097          	auipc	ra,0xffffe
    80002888:	cf0080e7          	jalr	-784(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000288c:	18848493          	addi	s1,s1,392
    80002890:	03248263          	beq	s1,s2,800028b4 <procdump+0x9a>
    if(p->state == UNUSED)
    80002894:	86a6                	mv	a3,s1
    80002896:	ec04a783          	lw	a5,-320(s1)
    8000289a:	dbed                	beqz	a5,8000288c <procdump+0x72>
      state = "???";
    8000289c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000289e:	fcfb6be3          	bltu	s6,a5,80002874 <procdump+0x5a>
    800028a2:	02079713          	slli	a4,a5,0x20
    800028a6:	01d75793          	srli	a5,a4,0x1d
    800028aa:	97de                	add	a5,a5,s7
    800028ac:	6390                	ld	a2,0(a5)
    800028ae:	f279                	bnez	a2,80002874 <procdump+0x5a>
      state = "???";
    800028b0:	864e                	mv	a2,s3
    800028b2:	b7c9                	j	80002874 <procdump+0x5a>
  }
}
    800028b4:	60a6                	ld	ra,72(sp)
    800028b6:	6406                	ld	s0,64(sp)
    800028b8:	74e2                	ld	s1,56(sp)
    800028ba:	7942                	ld	s2,48(sp)
    800028bc:	79a2                	ld	s3,40(sp)
    800028be:	7a02                	ld	s4,32(sp)
    800028c0:	6ae2                	ld	s5,24(sp)
    800028c2:	6b42                	ld	s6,16(sp)
    800028c4:	6ba2                	ld	s7,8(sp)
    800028c6:	6161                	addi	sp,sp,80
    800028c8:	8082                	ret

00000000800028ca <updatePerf>:

//assign1
void
updatePerf(){
    800028ca:	1141                	addi	sp,sp,-16
    800028cc:	e422                	sd	s0,8(sp)
    800028ce:	0800                	addi	s0,sp,16
  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++){
    800028d0:	0000f797          	auipc	a5,0xf
    800028d4:	e0078793          	addi	a5,a5,-512 # 800116d0 <proc>
    switch (p->state)
    800028d8:	450d                	li	a0,3
    800028da:	4591                	li	a1,4
    800028dc:	4609                	li	a2,2
  for(p = proc; p < &proc[NPROC]; p++){
    800028de:	00015697          	auipc	a3,0x15
    800028e2:	ff268693          	addi	a3,a3,-14 # 800178d0 <tickslock>
    800028e6:	a811                	j	800028fa <updatePerf+0x30>
    {
    case SLEEPING:
      p->stime++;
      break;
    case RUNNABLE:
      p->retime++;
    800028e8:	1747a703          	lw	a4,372(a5)
    800028ec:	2705                	addiw	a4,a4,1
    800028ee:	16e7aa23          	sw	a4,372(a5)
  for(p = proc; p < &proc[NPROC]; p++){
    800028f2:	18878793          	addi	a5,a5,392
    800028f6:	02d78563          	beq	a5,a3,80002920 <updatePerf+0x56>
    switch (p->state)
    800028fa:	4f98                	lw	a4,24(a5)
    800028fc:	fea706e3          	beq	a4,a0,800028e8 <updatePerf+0x1e>
    80002900:	00b70a63          	beq	a4,a1,80002914 <updatePerf+0x4a>
    80002904:	fec717e3          	bne	a4,a2,800028f2 <updatePerf+0x28>
      p->stime++;
    80002908:	1707a703          	lw	a4,368(a5)
    8000290c:	2705                	addiw	a4,a4,1
    8000290e:	16e7a823          	sw	a4,368(a5)
      break;
    80002912:	b7c5                	j	800028f2 <updatePerf+0x28>
      break;
    case RUNNING:
      p->rutime++;
    80002914:	1787a703          	lw	a4,376(a5)
    80002918:	2705                	addiw	a4,a4,1
    8000291a:	16e7ac23          	sw	a4,376(a5)
      break;  
    8000291e:	bfd1                	j	800028f2 <updatePerf+0x28>
    default:
      break;
    }
  }
}
    80002920:	6422                	ld	s0,8(sp)
    80002922:	0141                	addi	sp,sp,16
    80002924:	8082                	ret

0000000080002926 <swtch>:
    80002926:	00153023          	sd	ra,0(a0)
    8000292a:	00253423          	sd	sp,8(a0)
    8000292e:	e900                	sd	s0,16(a0)
    80002930:	ed04                	sd	s1,24(a0)
    80002932:	03253023          	sd	s2,32(a0)
    80002936:	03353423          	sd	s3,40(a0)
    8000293a:	03453823          	sd	s4,48(a0)
    8000293e:	03553c23          	sd	s5,56(a0)
    80002942:	05653023          	sd	s6,64(a0)
    80002946:	05753423          	sd	s7,72(a0)
    8000294a:	05853823          	sd	s8,80(a0)
    8000294e:	05953c23          	sd	s9,88(a0)
    80002952:	07a53023          	sd	s10,96(a0)
    80002956:	07b53423          	sd	s11,104(a0)
    8000295a:	0005b083          	ld	ra,0(a1)
    8000295e:	0085b103          	ld	sp,8(a1)
    80002962:	6980                	ld	s0,16(a1)
    80002964:	6d84                	ld	s1,24(a1)
    80002966:	0205b903          	ld	s2,32(a1)
    8000296a:	0285b983          	ld	s3,40(a1)
    8000296e:	0305ba03          	ld	s4,48(a1)
    80002972:	0385ba83          	ld	s5,56(a1)
    80002976:	0405bb03          	ld	s6,64(a1)
    8000297a:	0485bb83          	ld	s7,72(a1)
    8000297e:	0505bc03          	ld	s8,80(a1)
    80002982:	0585bc83          	ld	s9,88(a1)
    80002986:	0605bd03          	ld	s10,96(a1)
    8000298a:	0685bd83          	ld	s11,104(a1)
    8000298e:	8082                	ret

0000000080002990 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002990:	1141                	addi	sp,sp,-16
    80002992:	e406                	sd	ra,8(sp)
    80002994:	e022                	sd	s0,0(sp)
    80002996:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002998:	00006597          	auipc	a1,0x6
    8000299c:	94058593          	addi	a1,a1,-1728 # 800082d8 <states.0+0x30>
    800029a0:	00015517          	auipc	a0,0x15
    800029a4:	f3050513          	addi	a0,a0,-208 # 800178d0 <tickslock>
    800029a8:	ffffe097          	auipc	ra,0xffffe
    800029ac:	18a080e7          	jalr	394(ra) # 80000b32 <initlock>
}
    800029b0:	60a2                	ld	ra,8(sp)
    800029b2:	6402                	ld	s0,0(sp)
    800029b4:	0141                	addi	sp,sp,16
    800029b6:	8082                	ret

00000000800029b8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800029b8:	1141                	addi	sp,sp,-16
    800029ba:	e422                	sd	s0,8(sp)
    800029bc:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029be:	00003797          	auipc	a5,0x3
    800029c2:	5c278793          	addi	a5,a5,1474 # 80005f80 <kernelvec>
    800029c6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029ca:	6422                	ld	s0,8(sp)
    800029cc:	0141                	addi	sp,sp,16
    800029ce:	8082                	ret

00000000800029d0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800029d0:	1141                	addi	sp,sp,-16
    800029d2:	e406                	sd	ra,8(sp)
    800029d4:	e022                	sd	s0,0(sp)
    800029d6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800029d8:	fffff097          	auipc	ra,0xfffff
    800029dc:	fa6080e7          	jalr	-90(ra) # 8000197e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029e4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029e6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800029ea:	00004617          	auipc	a2,0x4
    800029ee:	61660613          	addi	a2,a2,1558 # 80007000 <_trampoline>
    800029f2:	00004697          	auipc	a3,0x4
    800029f6:	60e68693          	addi	a3,a3,1550 # 80007000 <_trampoline>
    800029fa:	8e91                	sub	a3,a3,a2
    800029fc:	040007b7          	lui	a5,0x4000
    80002a00:	17fd                	addi	a5,a5,-1
    80002a02:	07b2                	slli	a5,a5,0xc
    80002a04:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a06:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a0a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a0c:	180026f3          	csrr	a3,satp
    80002a10:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a12:	6d38                	ld	a4,88(a0)
    80002a14:	6134                	ld	a3,64(a0)
    80002a16:	6585                	lui	a1,0x1
    80002a18:	96ae                	add	a3,a3,a1
    80002a1a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a1c:	6d38                	ld	a4,88(a0)
    80002a1e:	00000697          	auipc	a3,0x0
    80002a22:	14668693          	addi	a3,a3,326 # 80002b64 <usertrap>
    80002a26:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a28:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a2a:	8692                	mv	a3,tp
    80002a2c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a2e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a32:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a36:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a3a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a3e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a40:	6f18                	ld	a4,24(a4)
    80002a42:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a46:	692c                	ld	a1,80(a0)
    80002a48:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002a4a:	00004717          	auipc	a4,0x4
    80002a4e:	64670713          	addi	a4,a4,1606 # 80007090 <userret>
    80002a52:	8f11                	sub	a4,a4,a2
    80002a54:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002a56:	577d                	li	a4,-1
    80002a58:	177e                	slli	a4,a4,0x3f
    80002a5a:	8dd9                	or	a1,a1,a4
    80002a5c:	02000537          	lui	a0,0x2000
    80002a60:	157d                	addi	a0,a0,-1
    80002a62:	0536                	slli	a0,a0,0xd
    80002a64:	9782                	jalr	a5
}
    80002a66:	60a2                	ld	ra,8(sp)
    80002a68:	6402                	ld	s0,0(sp)
    80002a6a:	0141                	addi	sp,sp,16
    80002a6c:	8082                	ret

0000000080002a6e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a6e:	1101                	addi	sp,sp,-32
    80002a70:	ec06                	sd	ra,24(sp)
    80002a72:	e822                	sd	s0,16(sp)
    80002a74:	e426                	sd	s1,8(sp)
    80002a76:	e04a                	sd	s2,0(sp)
    80002a78:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a7a:	00015917          	auipc	s2,0x15
    80002a7e:	e5690913          	addi	s2,s2,-426 # 800178d0 <tickslock>
    80002a82:	854a                	mv	a0,s2
    80002a84:	ffffe097          	auipc	ra,0xffffe
    80002a88:	13e080e7          	jalr	318(ra) # 80000bc2 <acquire>
  ticks++;
    80002a8c:	00006497          	auipc	s1,0x6
    80002a90:	5a448493          	addi	s1,s1,1444 # 80009030 <ticks>
    80002a94:	409c                	lw	a5,0(s1)
    80002a96:	2785                	addiw	a5,a5,1
    80002a98:	c09c                	sw	a5,0(s1)
  // isQuantumTicks = ticks % 5;
  updatePerf(); //updates performance measurement for assign1
    80002a9a:	00000097          	auipc	ra,0x0
    80002a9e:	e30080e7          	jalr	-464(ra) # 800028ca <updatePerf>
  wakeup(&ticks);
    80002aa2:	8526                	mv	a0,s1
    80002aa4:	00000097          	auipc	ra,0x0
    80002aa8:	a7a080e7          	jalr	-1414(ra) # 8000251e <wakeup>
  release(&tickslock);
    80002aac:	854a                	mv	a0,s2
    80002aae:	ffffe097          	auipc	ra,0xffffe
    80002ab2:	1c8080e7          	jalr	456(ra) # 80000c76 <release>
}
    80002ab6:	60e2                	ld	ra,24(sp)
    80002ab8:	6442                	ld	s0,16(sp)
    80002aba:	64a2                	ld	s1,8(sp)
    80002abc:	6902                	ld	s2,0(sp)
    80002abe:	6105                	addi	sp,sp,32
    80002ac0:	8082                	ret

0000000080002ac2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002ac2:	1101                	addi	sp,sp,-32
    80002ac4:	ec06                	sd	ra,24(sp)
    80002ac6:	e822                	sd	s0,16(sp)
    80002ac8:	e426                	sd	s1,8(sp)
    80002aca:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002acc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002ad0:	00074d63          	bltz	a4,80002aea <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002ad4:	57fd                	li	a5,-1
    80002ad6:	17fe                	slli	a5,a5,0x3f
    80002ad8:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002ada:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002adc:	06f70363          	beq	a4,a5,80002b42 <devintr+0x80>
  }
}
    80002ae0:	60e2                	ld	ra,24(sp)
    80002ae2:	6442                	ld	s0,16(sp)
    80002ae4:	64a2                	ld	s1,8(sp)
    80002ae6:	6105                	addi	sp,sp,32
    80002ae8:	8082                	ret
     (scause & 0xff) == 9){
    80002aea:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002aee:	46a5                	li	a3,9
    80002af0:	fed792e3          	bne	a5,a3,80002ad4 <devintr+0x12>
    int irq = plic_claim();
    80002af4:	00003097          	auipc	ra,0x3
    80002af8:	594080e7          	jalr	1428(ra) # 80006088 <plic_claim>
    80002afc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002afe:	47a9                	li	a5,10
    80002b00:	02f50763          	beq	a0,a5,80002b2e <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002b04:	4785                	li	a5,1
    80002b06:	02f50963          	beq	a0,a5,80002b38 <devintr+0x76>
    return 1;
    80002b0a:	4505                	li	a0,1
    } else if(irq){
    80002b0c:	d8f1                	beqz	s1,80002ae0 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b0e:	85a6                	mv	a1,s1
    80002b10:	00005517          	auipc	a0,0x5
    80002b14:	7d050513          	addi	a0,a0,2000 # 800082e0 <states.0+0x38>
    80002b18:	ffffe097          	auipc	ra,0xffffe
    80002b1c:	a5c080e7          	jalr	-1444(ra) # 80000574 <printf>
      plic_complete(irq);
    80002b20:	8526                	mv	a0,s1
    80002b22:	00003097          	auipc	ra,0x3
    80002b26:	58a080e7          	jalr	1418(ra) # 800060ac <plic_complete>
    return 1;
    80002b2a:	4505                	li	a0,1
    80002b2c:	bf55                	j	80002ae0 <devintr+0x1e>
      uartintr();
    80002b2e:	ffffe097          	auipc	ra,0xffffe
    80002b32:	e58080e7          	jalr	-424(ra) # 80000986 <uartintr>
    80002b36:	b7ed                	j	80002b20 <devintr+0x5e>
      virtio_disk_intr();
    80002b38:	00004097          	auipc	ra,0x4
    80002b3c:	a06080e7          	jalr	-1530(ra) # 8000653e <virtio_disk_intr>
    80002b40:	b7c5                	j	80002b20 <devintr+0x5e>
    if(cpuid() == 0){
    80002b42:	fffff097          	auipc	ra,0xfffff
    80002b46:	e10080e7          	jalr	-496(ra) # 80001952 <cpuid>
    80002b4a:	c901                	beqz	a0,80002b5a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b4c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b50:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b52:	14479073          	csrw	sip,a5
    return 2;
    80002b56:	4509                	li	a0,2
    80002b58:	b761                	j	80002ae0 <devintr+0x1e>
      clockintr();
    80002b5a:	00000097          	auipc	ra,0x0
    80002b5e:	f14080e7          	jalr	-236(ra) # 80002a6e <clockintr>
    80002b62:	b7ed                	j	80002b4c <devintr+0x8a>

0000000080002b64 <usertrap>:
{
    80002b64:	1101                	addi	sp,sp,-32
    80002b66:	ec06                	sd	ra,24(sp)
    80002b68:	e822                	sd	s0,16(sp)
    80002b6a:	e426                	sd	s1,8(sp)
    80002b6c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b6e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b72:	1007f793          	andi	a5,a5,256
    80002b76:	e3a5                	bnez	a5,80002bd6 <usertrap+0x72>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b78:	00003797          	auipc	a5,0x3
    80002b7c:	40878793          	addi	a5,a5,1032 # 80005f80 <kernelvec>
    80002b80:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b84:	fffff097          	auipc	ra,0xfffff
    80002b88:	dfa080e7          	jalr	-518(ra) # 8000197e <myproc>
    80002b8c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b8e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b90:	14102773          	csrr	a4,sepc
    80002b94:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b96:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b9a:	47a1                	li	a5,8
    80002b9c:	04f71b63          	bne	a4,a5,80002bf2 <usertrap+0x8e>
    if(p->killed)
    80002ba0:	551c                	lw	a5,40(a0)
    80002ba2:	e3b1                	bnez	a5,80002be6 <usertrap+0x82>
    p->trapframe->epc += 4;
    80002ba4:	6cb8                	ld	a4,88(s1)
    80002ba6:	6f1c                	ld	a5,24(a4)
    80002ba8:	0791                	addi	a5,a5,4
    80002baa:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bac:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002bb0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bb4:	10079073          	csrw	sstatus,a5
    syscall();
    80002bb8:	00000097          	auipc	ra,0x0
    80002bbc:	29a080e7          	jalr	666(ra) # 80002e52 <syscall>
  if(p->killed)
    80002bc0:	549c                	lw	a5,40(s1)
    80002bc2:	e7b5                	bnez	a5,80002c2e <usertrap+0xca>
  usertrapret();
    80002bc4:	00000097          	auipc	ra,0x0
    80002bc8:	e0c080e7          	jalr	-500(ra) # 800029d0 <usertrapret>
}
    80002bcc:	60e2                	ld	ra,24(sp)
    80002bce:	6442                	ld	s0,16(sp)
    80002bd0:	64a2                	ld	s1,8(sp)
    80002bd2:	6105                	addi	sp,sp,32
    80002bd4:	8082                	ret
    panic("usertrap: not from user mode");
    80002bd6:	00005517          	auipc	a0,0x5
    80002bda:	72a50513          	addi	a0,a0,1834 # 80008300 <states.0+0x58>
    80002bde:	ffffe097          	auipc	ra,0xffffe
    80002be2:	94c080e7          	jalr	-1716(ra) # 8000052a <panic>
      exit(-1);
    80002be6:	557d                	li	a0,-1
    80002be8:	00000097          	auipc	ra,0x0
    80002bec:	a20080e7          	jalr	-1504(ra) # 80002608 <exit>
    80002bf0:	bf55                	j	80002ba4 <usertrap+0x40>
  } else if((which_dev = devintr()) != 0){
    80002bf2:	00000097          	auipc	ra,0x0
    80002bf6:	ed0080e7          	jalr	-304(ra) # 80002ac2 <devintr>
    80002bfa:	f179                	bnez	a0,80002bc0 <usertrap+0x5c>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bfc:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c00:	5890                	lw	a2,48(s1)
    80002c02:	00005517          	auipc	a0,0x5
    80002c06:	71e50513          	addi	a0,a0,1822 # 80008320 <states.0+0x78>
    80002c0a:	ffffe097          	auipc	ra,0xffffe
    80002c0e:	96a080e7          	jalr	-1686(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c12:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c16:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c1a:	00005517          	auipc	a0,0x5
    80002c1e:	73650513          	addi	a0,a0,1846 # 80008350 <states.0+0xa8>
    80002c22:	ffffe097          	auipc	ra,0xffffe
    80002c26:	952080e7          	jalr	-1710(ra) # 80000574 <printf>
    p->killed = 1;
    80002c2a:	4785                	li	a5,1
    80002c2c:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002c2e:	557d                	li	a0,-1
    80002c30:	00000097          	auipc	ra,0x0
    80002c34:	9d8080e7          	jalr	-1576(ra) # 80002608 <exit>
    80002c38:	b771                	j	80002bc4 <usertrap+0x60>

0000000080002c3a <kerneltrap>:
{
    80002c3a:	7179                	addi	sp,sp,-48
    80002c3c:	f406                	sd	ra,40(sp)
    80002c3e:	f022                	sd	s0,32(sp)
    80002c40:	ec26                	sd	s1,24(sp)
    80002c42:	e84a                	sd	s2,16(sp)
    80002c44:	e44e                	sd	s3,8(sp)
    80002c46:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c48:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c4c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c50:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c54:	1004f793          	andi	a5,s1,256
    80002c58:	c78d                	beqz	a5,80002c82 <kerneltrap+0x48>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c5a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c5e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c60:	eb8d                	bnez	a5,80002c92 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002c62:	00000097          	auipc	ra,0x0
    80002c66:	e60080e7          	jalr	-416(ra) # 80002ac2 <devintr>
    80002c6a:	cd05                	beqz	a0,80002ca2 <kerneltrap+0x68>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c6c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c70:	10049073          	csrw	sstatus,s1
}
    80002c74:	70a2                	ld	ra,40(sp)
    80002c76:	7402                	ld	s0,32(sp)
    80002c78:	64e2                	ld	s1,24(sp)
    80002c7a:	6942                	ld	s2,16(sp)
    80002c7c:	69a2                	ld	s3,8(sp)
    80002c7e:	6145                	addi	sp,sp,48
    80002c80:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c82:	00005517          	auipc	a0,0x5
    80002c86:	6ee50513          	addi	a0,a0,1774 # 80008370 <states.0+0xc8>
    80002c8a:	ffffe097          	auipc	ra,0xffffe
    80002c8e:	8a0080e7          	jalr	-1888(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80002c92:	00005517          	auipc	a0,0x5
    80002c96:	70650513          	addi	a0,a0,1798 # 80008398 <states.0+0xf0>
    80002c9a:	ffffe097          	auipc	ra,0xffffe
    80002c9e:	890080e7          	jalr	-1904(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80002ca2:	85ce                	mv	a1,s3
    80002ca4:	00005517          	auipc	a0,0x5
    80002ca8:	71450513          	addi	a0,a0,1812 # 800083b8 <states.0+0x110>
    80002cac:	ffffe097          	auipc	ra,0xffffe
    80002cb0:	8c8080e7          	jalr	-1848(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cb4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cb8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cbc:	00005517          	auipc	a0,0x5
    80002cc0:	70c50513          	addi	a0,a0,1804 # 800083c8 <states.0+0x120>
    80002cc4:	ffffe097          	auipc	ra,0xffffe
    80002cc8:	8b0080e7          	jalr	-1872(ra) # 80000574 <printf>
    panic("kerneltrap");
    80002ccc:	00005517          	auipc	a0,0x5
    80002cd0:	71450513          	addi	a0,a0,1812 # 800083e0 <states.0+0x138>
    80002cd4:	ffffe097          	auipc	ra,0xffffe
    80002cd8:	856080e7          	jalr	-1962(ra) # 8000052a <panic>

0000000080002cdc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cdc:	1101                	addi	sp,sp,-32
    80002cde:	ec06                	sd	ra,24(sp)
    80002ce0:	e822                	sd	s0,16(sp)
    80002ce2:	e426                	sd	s1,8(sp)
    80002ce4:	1000                	addi	s0,sp,32
    80002ce6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ce8:	fffff097          	auipc	ra,0xfffff
    80002cec:	c96080e7          	jalr	-874(ra) # 8000197e <myproc>
  switch (n) {
    80002cf0:	4795                	li	a5,5
    80002cf2:	0497e163          	bltu	a5,s1,80002d34 <argraw+0x58>
    80002cf6:	048a                	slli	s1,s1,0x2
    80002cf8:	00006717          	auipc	a4,0x6
    80002cfc:	84870713          	addi	a4,a4,-1976 # 80008540 <states.0+0x298>
    80002d00:	94ba                	add	s1,s1,a4
    80002d02:	409c                	lw	a5,0(s1)
    80002d04:	97ba                	add	a5,a5,a4
    80002d06:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d08:	6d3c                	ld	a5,88(a0)
    80002d0a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d0c:	60e2                	ld	ra,24(sp)
    80002d0e:	6442                	ld	s0,16(sp)
    80002d10:	64a2                	ld	s1,8(sp)
    80002d12:	6105                	addi	sp,sp,32
    80002d14:	8082                	ret
    return p->trapframe->a1;
    80002d16:	6d3c                	ld	a5,88(a0)
    80002d18:	7fa8                	ld	a0,120(a5)
    80002d1a:	bfcd                	j	80002d0c <argraw+0x30>
    return p->trapframe->a2;
    80002d1c:	6d3c                	ld	a5,88(a0)
    80002d1e:	63c8                	ld	a0,128(a5)
    80002d20:	b7f5                	j	80002d0c <argraw+0x30>
    return p->trapframe->a3;
    80002d22:	6d3c                	ld	a5,88(a0)
    80002d24:	67c8                	ld	a0,136(a5)
    80002d26:	b7dd                	j	80002d0c <argraw+0x30>
    return p->trapframe->a4;
    80002d28:	6d3c                	ld	a5,88(a0)
    80002d2a:	6bc8                	ld	a0,144(a5)
    80002d2c:	b7c5                	j	80002d0c <argraw+0x30>
    return p->trapframe->a5;
    80002d2e:	6d3c                	ld	a5,88(a0)
    80002d30:	6fc8                	ld	a0,152(a5)
    80002d32:	bfe9                	j	80002d0c <argraw+0x30>
  panic("argraw");
    80002d34:	00005517          	auipc	a0,0x5
    80002d38:	6bc50513          	addi	a0,a0,1724 # 800083f0 <states.0+0x148>
    80002d3c:	ffffd097          	auipc	ra,0xffffd
    80002d40:	7ee080e7          	jalr	2030(ra) # 8000052a <panic>

0000000080002d44 <fetchaddr>:
{
    80002d44:	1101                	addi	sp,sp,-32
    80002d46:	ec06                	sd	ra,24(sp)
    80002d48:	e822                	sd	s0,16(sp)
    80002d4a:	e426                	sd	s1,8(sp)
    80002d4c:	e04a                	sd	s2,0(sp)
    80002d4e:	1000                	addi	s0,sp,32
    80002d50:	84aa                	mv	s1,a0
    80002d52:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d54:	fffff097          	auipc	ra,0xfffff
    80002d58:	c2a080e7          	jalr	-982(ra) # 8000197e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002d5c:	653c                	ld	a5,72(a0)
    80002d5e:	02f4f863          	bgeu	s1,a5,80002d8e <fetchaddr+0x4a>
    80002d62:	00848713          	addi	a4,s1,8
    80002d66:	02e7e663          	bltu	a5,a4,80002d92 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d6a:	46a1                	li	a3,8
    80002d6c:	8626                	mv	a2,s1
    80002d6e:	85ca                	mv	a1,s2
    80002d70:	6928                	ld	a0,80(a0)
    80002d72:	fffff097          	auipc	ra,0xfffff
    80002d76:	958080e7          	jalr	-1704(ra) # 800016ca <copyin>
    80002d7a:	00a03533          	snez	a0,a0
    80002d7e:	40a00533          	neg	a0,a0
}
    80002d82:	60e2                	ld	ra,24(sp)
    80002d84:	6442                	ld	s0,16(sp)
    80002d86:	64a2                	ld	s1,8(sp)
    80002d88:	6902                	ld	s2,0(sp)
    80002d8a:	6105                	addi	sp,sp,32
    80002d8c:	8082                	ret
    return -1;
    80002d8e:	557d                	li	a0,-1
    80002d90:	bfcd                	j	80002d82 <fetchaddr+0x3e>
    80002d92:	557d                	li	a0,-1
    80002d94:	b7fd                	j	80002d82 <fetchaddr+0x3e>

0000000080002d96 <fetchstr>:
{
    80002d96:	7179                	addi	sp,sp,-48
    80002d98:	f406                	sd	ra,40(sp)
    80002d9a:	f022                	sd	s0,32(sp)
    80002d9c:	ec26                	sd	s1,24(sp)
    80002d9e:	e84a                	sd	s2,16(sp)
    80002da0:	e44e                	sd	s3,8(sp)
    80002da2:	1800                	addi	s0,sp,48
    80002da4:	892a                	mv	s2,a0
    80002da6:	84ae                	mv	s1,a1
    80002da8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002daa:	fffff097          	auipc	ra,0xfffff
    80002dae:	bd4080e7          	jalr	-1068(ra) # 8000197e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002db2:	86ce                	mv	a3,s3
    80002db4:	864a                	mv	a2,s2
    80002db6:	85a6                	mv	a1,s1
    80002db8:	6928                	ld	a0,80(a0)
    80002dba:	fffff097          	auipc	ra,0xfffff
    80002dbe:	99e080e7          	jalr	-1634(ra) # 80001758 <copyinstr>
  if(err < 0)
    80002dc2:	00054763          	bltz	a0,80002dd0 <fetchstr+0x3a>
  return strlen(buf);
    80002dc6:	8526                	mv	a0,s1
    80002dc8:	ffffe097          	auipc	ra,0xffffe
    80002dcc:	07a080e7          	jalr	122(ra) # 80000e42 <strlen>
}
    80002dd0:	70a2                	ld	ra,40(sp)
    80002dd2:	7402                	ld	s0,32(sp)
    80002dd4:	64e2                	ld	s1,24(sp)
    80002dd6:	6942                	ld	s2,16(sp)
    80002dd8:	69a2                	ld	s3,8(sp)
    80002dda:	6145                	addi	sp,sp,48
    80002ddc:	8082                	ret

0000000080002dde <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002dde:	1101                	addi	sp,sp,-32
    80002de0:	ec06                	sd	ra,24(sp)
    80002de2:	e822                	sd	s0,16(sp)
    80002de4:	e426                	sd	s1,8(sp)
    80002de6:	1000                	addi	s0,sp,32
    80002de8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dea:	00000097          	auipc	ra,0x0
    80002dee:	ef2080e7          	jalr	-270(ra) # 80002cdc <argraw>
    80002df2:	c088                	sw	a0,0(s1)
  return 0;
}
    80002df4:	4501                	li	a0,0
    80002df6:	60e2                	ld	ra,24(sp)
    80002df8:	6442                	ld	s0,16(sp)
    80002dfa:	64a2                	ld	s1,8(sp)
    80002dfc:	6105                	addi	sp,sp,32
    80002dfe:	8082                	ret

0000000080002e00 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e00:	1101                	addi	sp,sp,-32
    80002e02:	ec06                	sd	ra,24(sp)
    80002e04:	e822                	sd	s0,16(sp)
    80002e06:	e426                	sd	s1,8(sp)
    80002e08:	1000                	addi	s0,sp,32
    80002e0a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e0c:	00000097          	auipc	ra,0x0
    80002e10:	ed0080e7          	jalr	-304(ra) # 80002cdc <argraw>
    80002e14:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e16:	4501                	li	a0,0
    80002e18:	60e2                	ld	ra,24(sp)
    80002e1a:	6442                	ld	s0,16(sp)
    80002e1c:	64a2                	ld	s1,8(sp)
    80002e1e:	6105                	addi	sp,sp,32
    80002e20:	8082                	ret

0000000080002e22 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e22:	1101                	addi	sp,sp,-32
    80002e24:	ec06                	sd	ra,24(sp)
    80002e26:	e822                	sd	s0,16(sp)
    80002e28:	e426                	sd	s1,8(sp)
    80002e2a:	e04a                	sd	s2,0(sp)
    80002e2c:	1000                	addi	s0,sp,32
    80002e2e:	84ae                	mv	s1,a1
    80002e30:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002e32:	00000097          	auipc	ra,0x0
    80002e36:	eaa080e7          	jalr	-342(ra) # 80002cdc <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002e3a:	864a                	mv	a2,s2
    80002e3c:	85a6                	mv	a1,s1
    80002e3e:	00000097          	auipc	ra,0x0
    80002e42:	f58080e7          	jalr	-168(ra) # 80002d96 <fetchstr>
}
    80002e46:	60e2                	ld	ra,24(sp)
    80002e48:	6442                	ld	s0,16(sp)
    80002e4a:	64a2                	ld	s1,8(sp)
    80002e4c:	6902                	ld	s2,0(sp)
    80002e4e:	6105                	addi	sp,sp,32
    80002e50:	8082                	ret

0000000080002e52 <syscall>:
   "set_priority"
};

void
syscall(void)
{
    80002e52:	7179                	addi	sp,sp,-48
    80002e54:	f406                	sd	ra,40(sp)
    80002e56:	f022                	sd	s0,32(sp)
    80002e58:	ec26                	sd	s1,24(sp)
    80002e5a:	e84a                	sd	s2,16(sp)
    80002e5c:	e44e                	sd	s3,8(sp)
    80002e5e:	e052                	sd	s4,0(sp)
    80002e60:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002e62:	fffff097          	auipc	ra,0xfffff
    80002e66:	b1c080e7          	jalr	-1252(ra) # 8000197e <myproc>
    80002e6a:	84aa                	mv	s1,a0
  int arg1 = p->trapframe->a0;
    80002e6c:	05853903          	ld	s2,88(a0)
  num = p->trapframe->a7;
    80002e70:	0a893783          	ld	a5,168(s2)
    80002e74:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e78:	37fd                	addiw	a5,a5,-1
    80002e7a:	475d                	li	a4,23
    80002e7c:	0af76863          	bltu	a4,a5,80002f2c <syscall+0xda>
    80002e80:	00399713          	slli	a4,s3,0x3
    80002e84:	00005797          	auipc	a5,0x5
    80002e88:	6d478793          	addi	a5,a5,1748 # 80008558 <syscalls>
    80002e8c:	97ba                	add	a5,a5,a4
    80002e8e:	639c                	ld	a5,0(a5)
    80002e90:	cfd1                	beqz	a5,80002f2c <syscall+0xda>
  int arg1 = p->trapframe->a0;
    80002e92:	07093a03          	ld	s4,112(s2)
    p->trapframe->a0 = syscalls[num]();
    80002e96:	9782                	jalr	a5
    80002e98:	06a93823          	sd	a0,112(s2)
    if( (p->mask) & (1 << num) ){
    80002e9c:	58dc                	lw	a5,52(s1)
    80002e9e:	4137d7bb          	sraw	a5,a5,s3
    80002ea2:	8b85                	andi	a5,a5,1
    80002ea4:	c3dd                	beqz	a5,80002f4a <syscall+0xf8>
      if (num == SYS_fork){
    80002ea6:	4785                	li	a5,1
    80002ea8:	02f98e63          	beq	s3,a5,80002ee4 <syscall+0x92>
        printf("%d: syscall %s NULL -> %d\n", p->pid, syscalls_str[num], p->trapframe->a0);

      }else if (num == SYS_kill || num == SYS_sbrk){
    80002eac:	4799                	li	a5,6
    80002eae:	00f98563          	beq	s3,a5,80002eb8 <syscall+0x66>
    80002eb2:	47b1                	li	a5,12
    80002eb4:	04f99863          	bne	s3,a5,80002f04 <syscall+0xb2>
        printf("%d: syscall %s %d -> %d\n", p->pid, syscalls_str[num], arg1, p->trapframe->a0);
    80002eb8:	6cb8                	ld	a4,88(s1)
    80002eba:	098e                	slli	s3,s3,0x3
    80002ebc:	00006797          	auipc	a5,0x6
    80002ec0:	abc78793          	addi	a5,a5,-1348 # 80008978 <syscalls_str>
    80002ec4:	99be                	add	s3,s3,a5
    80002ec6:	7b38                	ld	a4,112(a4)
    80002ec8:	000a069b          	sext.w	a3,s4
    80002ecc:	0009b603          	ld	a2,0(s3)
    80002ed0:	588c                	lw	a1,48(s1)
    80002ed2:	00005517          	auipc	a0,0x5
    80002ed6:	54650513          	addi	a0,a0,1350 # 80008418 <states.0+0x170>
    80002eda:	ffffd097          	auipc	ra,0xffffd
    80002ede:	69a080e7          	jalr	1690(ra) # 80000574 <printf>
    80002ee2:	a0a5                	j	80002f4a <syscall+0xf8>
        printf("%d: syscall %s NULL -> %d\n", p->pid, syscalls_str[num], p->trapframe->a0);
    80002ee4:	6cbc                	ld	a5,88(s1)
    80002ee6:	7bb4                	ld	a3,112(a5)
    80002ee8:	00006617          	auipc	a2,0x6
    80002eec:	a9863603          	ld	a2,-1384(a2) # 80008980 <syscalls_str+0x8>
    80002ef0:	588c                	lw	a1,48(s1)
    80002ef2:	00005517          	auipc	a0,0x5
    80002ef6:	50650513          	addi	a0,a0,1286 # 800083f8 <states.0+0x150>
    80002efa:	ffffd097          	auipc	ra,0xffffd
    80002efe:	67a080e7          	jalr	1658(ra) # 80000574 <printf>
    80002f02:	a0a1                	j	80002f4a <syscall+0xf8>
      }
      else //not fork/kill/sbrk
        printf("%d: syscall %s -> %d\n", p->pid, syscalls_str[num], p->trapframe->a0);
    80002f04:	6cb8                	ld	a4,88(s1)
    80002f06:	098e                	slli	s3,s3,0x3
    80002f08:	00006797          	auipc	a5,0x6
    80002f0c:	a7078793          	addi	a5,a5,-1424 # 80008978 <syscalls_str>
    80002f10:	99be                	add	s3,s3,a5
    80002f12:	7b34                	ld	a3,112(a4)
    80002f14:	0009b603          	ld	a2,0(s3)
    80002f18:	588c                	lw	a1,48(s1)
    80002f1a:	00005517          	auipc	a0,0x5
    80002f1e:	51e50513          	addi	a0,a0,1310 # 80008438 <states.0+0x190>
    80002f22:	ffffd097          	auipc	ra,0xffffd
    80002f26:	652080e7          	jalr	1618(ra) # 80000574 <printf>
    80002f2a:	a005                	j	80002f4a <syscall+0xf8>
    }
  }
  else {
      printf("%d %s: unknown sys call %d\n",
    80002f2c:	86ce                	mv	a3,s3
    80002f2e:	15848613          	addi	a2,s1,344
    80002f32:	588c                	lw	a1,48(s1)
    80002f34:	00005517          	auipc	a0,0x5
    80002f38:	51c50513          	addi	a0,a0,1308 # 80008450 <states.0+0x1a8>
    80002f3c:	ffffd097          	auipc	ra,0xffffd
    80002f40:	638080e7          	jalr	1592(ra) # 80000574 <printf>
      p->pid, p->name, num);
      p->trapframe->a0 = -1;
    80002f44:	6cbc                	ld	a5,88(s1)
    80002f46:	577d                	li	a4,-1
    80002f48:	fbb8                	sd	a4,112(a5)
  }
}
    80002f4a:	70a2                	ld	ra,40(sp)
    80002f4c:	7402                	ld	s0,32(sp)
    80002f4e:	64e2                	ld	s1,24(sp)
    80002f50:	6942                	ld	s2,16(sp)
    80002f52:	69a2                	ld	s3,8(sp)
    80002f54:	6a02                	ld	s4,0(sp)
    80002f56:	6145                	addi	sp,sp,48
    80002f58:	8082                	ret

0000000080002f5a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f5a:	1101                	addi	sp,sp,-32
    80002f5c:	ec06                	sd	ra,24(sp)
    80002f5e:	e822                	sd	s0,16(sp)
    80002f60:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002f62:	fec40593          	addi	a1,s0,-20
    80002f66:	4501                	li	a0,0
    80002f68:	00000097          	auipc	ra,0x0
    80002f6c:	e76080e7          	jalr	-394(ra) # 80002dde <argint>
    return -1;
    80002f70:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f72:	00054963          	bltz	a0,80002f84 <sys_exit+0x2a>
  exit(n);
    80002f76:	fec42503          	lw	a0,-20(s0)
    80002f7a:	fffff097          	auipc	ra,0xfffff
    80002f7e:	68e080e7          	jalr	1678(ra) # 80002608 <exit>
  return 0;  // not reached
    80002f82:	4781                	li	a5,0
}
    80002f84:	853e                	mv	a0,a5
    80002f86:	60e2                	ld	ra,24(sp)
    80002f88:	6442                	ld	s0,16(sp)
    80002f8a:	6105                	addi	sp,sp,32
    80002f8c:	8082                	ret

0000000080002f8e <sys_trace>:

uint64
sys_trace(void)
{
    80002f8e:	1101                	addi	sp,sp,-32
    80002f90:	ec06                	sd	ra,24(sp)
    80002f92:	e822                	sd	s0,16(sp)
    80002f94:	1000                	addi	s0,sp,32
  int mask;
  int pid;
  if(argint(0, &mask) < 0 || argint(1, &pid) < 0){
    80002f96:	fec40593          	addi	a1,s0,-20
    80002f9a:	4501                	li	a0,0
    80002f9c:	00000097          	auipc	ra,0x0
    80002fa0:	e42080e7          	jalr	-446(ra) # 80002dde <argint>
    return -1;
    80002fa4:	57fd                	li	a5,-1
  if(argint(0, &mask) < 0 || argint(1, &pid) < 0){
    80002fa6:	02054563          	bltz	a0,80002fd0 <sys_trace+0x42>
    80002faa:	fe840593          	addi	a1,s0,-24
    80002fae:	4505                	li	a0,1
    80002fb0:	00000097          	auipc	ra,0x0
    80002fb4:	e2e080e7          	jalr	-466(ra) # 80002dde <argint>
    return -1;
    80002fb8:	57fd                	li	a5,-1
  if(argint(0, &mask) < 0 || argint(1, &pid) < 0){
    80002fba:	00054b63          	bltz	a0,80002fd0 <sys_trace+0x42>
  }
  trace(mask, pid);
    80002fbe:	fe842583          	lw	a1,-24(s0)
    80002fc2:	fec42503          	lw	a0,-20(s0)
    80002fc6:	fffff097          	auipc	ra,0xfffff
    80002fca:	a7c080e7          	jalr	-1412(ra) # 80001a42 <trace>
  return 0;
    80002fce:	4781                	li	a5,0
}
    80002fd0:	853e                	mv	a0,a5
    80002fd2:	60e2                	ld	ra,24(sp)
    80002fd4:	6442                	ld	s0,16(sp)
    80002fd6:	6105                	addi	sp,sp,32
    80002fd8:	8082                	ret

0000000080002fda <sys_wait_stat>:

uint
sys_wait_stat(void)
{
    80002fda:	1101                	addi	sp,sp,-32
    80002fdc:	ec06                	sd	ra,24(sp)
    80002fde:	e822                	sd	s0,16(sp)
    80002fe0:	1000                	addi	s0,sp,32
  uint64 status;
  uint64 performance;
  if(argaddr(0, &status) < 0 || argaddr(1, &performance) < 0){
    80002fe2:	fe840593          	addi	a1,s0,-24
    80002fe6:	4501                	li	a0,0
    80002fe8:	00000097          	auipc	ra,0x0
    80002fec:	e18080e7          	jalr	-488(ra) # 80002e00 <argaddr>
    return -1;
    80002ff0:	57fd                	li	a5,-1
  if(argaddr(0, &status) < 0 || argaddr(1, &performance) < 0){
    80002ff2:	02054663          	bltz	a0,8000301e <sys_wait_stat+0x44>
    80002ff6:	fe040593          	addi	a1,s0,-32
    80002ffa:	4505                	li	a0,1
    80002ffc:	00000097          	auipc	ra,0x0
    80003000:	e04080e7          	jalr	-508(ra) # 80002e00 <argaddr>
    return -1;
    80003004:	57fd                	li	a5,-1
  if(argaddr(0, &status) < 0 || argaddr(1, &performance) < 0){
    80003006:	00054c63          	bltz	a0,8000301e <sys_wait_stat+0x44>
  }
  return wait_stat(status, (struct perf*)performance);
    8000300a:	fe043583          	ld	a1,-32(s0)
    8000300e:	fe843503          	ld	a0,-24(s0)
    80003012:	fffff097          	auipc	ra,0xfffff
    80003016:	232080e7          	jalr	562(ra) # 80002244 <wait_stat>
    8000301a:	0005079b          	sext.w	a5,a0
}
    8000301e:	853e                	mv	a0,a5
    80003020:	60e2                	ld	ra,24(sp)
    80003022:	6442                	ld	s0,16(sp)
    80003024:	6105                	addi	sp,sp,32
    80003026:	8082                	ret

0000000080003028 <sys_set_priority>:

uint64
sys_set_priority(void)
{
    80003028:	1101                	addi	sp,sp,-32
    8000302a:	ec06                	sd	ra,24(sp)
    8000302c:	e822                	sd	s0,16(sp)
    8000302e:	1000                	addi	s0,sp,32
  int newPriority;
  if(argint(0, &newPriority) < 0)
    80003030:	fec40593          	addi	a1,s0,-20
    80003034:	4501                	li	a0,0
    80003036:	00000097          	auipc	ra,0x0
    8000303a:	da8080e7          	jalr	-600(ra) # 80002dde <argint>
    8000303e:	87aa                	mv	a5,a0
    return -1;
    80003040:	557d                	li	a0,-1
  if(argint(0, &newPriority) < 0)
    80003042:	0007c863          	bltz	a5,80003052 <sys_set_priority+0x2a>
  return set_priority(newPriority);
    80003046:	fec42503          	lw	a0,-20(s0)
    8000304a:	fffff097          	auipc	ra,0xfffff
    8000304e:	a62080e7          	jalr	-1438(ra) # 80001aac <set_priority>
}
    80003052:	60e2                	ld	ra,24(sp)
    80003054:	6442                	ld	s0,16(sp)
    80003056:	6105                	addi	sp,sp,32
    80003058:	8082                	ret

000000008000305a <sys_getpid>:


uint64
sys_getpid(void)
{
    8000305a:	1141                	addi	sp,sp,-16
    8000305c:	e406                	sd	ra,8(sp)
    8000305e:	e022                	sd	s0,0(sp)
    80003060:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003062:	fffff097          	auipc	ra,0xfffff
    80003066:	91c080e7          	jalr	-1764(ra) # 8000197e <myproc>
}
    8000306a:	5908                	lw	a0,48(a0)
    8000306c:	60a2                	ld	ra,8(sp)
    8000306e:	6402                	ld	s0,0(sp)
    80003070:	0141                	addi	sp,sp,16
    80003072:	8082                	ret

0000000080003074 <sys_fork>:

uint64
sys_fork(void)
{
    80003074:	1141                	addi	sp,sp,-16
    80003076:	e406                	sd	ra,8(sp)
    80003078:	e022                	sd	s0,0(sp)
    8000307a:	0800                	addi	s0,sp,16
  return fork();
    8000307c:	fffff097          	auipc	ra,0xfffff
    80003080:	dfc080e7          	jalr	-516(ra) # 80001e78 <fork>
}
    80003084:	60a2                	ld	ra,8(sp)
    80003086:	6402                	ld	s0,0(sp)
    80003088:	0141                	addi	sp,sp,16
    8000308a:	8082                	ret

000000008000308c <sys_wait>:

uint64
sys_wait(void)
{
    8000308c:	1101                	addi	sp,sp,-32
    8000308e:	ec06                	sd	ra,24(sp)
    80003090:	e822                	sd	s0,16(sp)
    80003092:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003094:	fe840593          	addi	a1,s0,-24
    80003098:	4501                	li	a0,0
    8000309a:	00000097          	auipc	ra,0x0
    8000309e:	d66080e7          	jalr	-666(ra) # 80002e00 <argaddr>
    800030a2:	87aa                	mv	a5,a0
    return -1;
    800030a4:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800030a6:	0007c863          	bltz	a5,800030b6 <sys_wait+0x2a>
  return wait(p);
    800030aa:	fe843503          	ld	a0,-24(s0)
    800030ae:	fffff097          	auipc	ra,0xfffff
    800030b2:	348080e7          	jalr	840(ra) # 800023f6 <wait>
}
    800030b6:	60e2                	ld	ra,24(sp)
    800030b8:	6442                	ld	s0,16(sp)
    800030ba:	6105                	addi	sp,sp,32
    800030bc:	8082                	ret

00000000800030be <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800030be:	7179                	addi	sp,sp,-48
    800030c0:	f406                	sd	ra,40(sp)
    800030c2:	f022                	sd	s0,32(sp)
    800030c4:	ec26                	sd	s1,24(sp)
    800030c6:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800030c8:	fdc40593          	addi	a1,s0,-36
    800030cc:	4501                	li	a0,0
    800030ce:	00000097          	auipc	ra,0x0
    800030d2:	d10080e7          	jalr	-752(ra) # 80002dde <argint>
    return -1;
    800030d6:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    800030d8:	00054f63          	bltz	a0,800030f6 <sys_sbrk+0x38>
  addr = myproc()->sz;
    800030dc:	fffff097          	auipc	ra,0xfffff
    800030e0:	8a2080e7          	jalr	-1886(ra) # 8000197e <myproc>
    800030e4:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    800030e6:	fdc42503          	lw	a0,-36(s0)
    800030ea:	fffff097          	auipc	ra,0xfffff
    800030ee:	d1a080e7          	jalr	-742(ra) # 80001e04 <growproc>
    800030f2:	00054863          	bltz	a0,80003102 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800030f6:	8526                	mv	a0,s1
    800030f8:	70a2                	ld	ra,40(sp)
    800030fa:	7402                	ld	s0,32(sp)
    800030fc:	64e2                	ld	s1,24(sp)
    800030fe:	6145                	addi	sp,sp,48
    80003100:	8082                	ret
    return -1;
    80003102:	54fd                	li	s1,-1
    80003104:	bfcd                	j	800030f6 <sys_sbrk+0x38>

0000000080003106 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003106:	7139                	addi	sp,sp,-64
    80003108:	fc06                	sd	ra,56(sp)
    8000310a:	f822                	sd	s0,48(sp)
    8000310c:	f426                	sd	s1,40(sp)
    8000310e:	f04a                	sd	s2,32(sp)
    80003110:	ec4e                	sd	s3,24(sp)
    80003112:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003114:	fcc40593          	addi	a1,s0,-52
    80003118:	4501                	li	a0,0
    8000311a:	00000097          	auipc	ra,0x0
    8000311e:	cc4080e7          	jalr	-828(ra) # 80002dde <argint>
    return -1;
    80003122:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003124:	06054563          	bltz	a0,8000318e <sys_sleep+0x88>
  acquire(&tickslock);
    80003128:	00014517          	auipc	a0,0x14
    8000312c:	7a850513          	addi	a0,a0,1960 # 800178d0 <tickslock>
    80003130:	ffffe097          	auipc	ra,0xffffe
    80003134:	a92080e7          	jalr	-1390(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    80003138:	00006917          	auipc	s2,0x6
    8000313c:	ef892903          	lw	s2,-264(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80003140:	fcc42783          	lw	a5,-52(s0)
    80003144:	cf85                	beqz	a5,8000317c <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003146:	00014997          	auipc	s3,0x14
    8000314a:	78a98993          	addi	s3,s3,1930 # 800178d0 <tickslock>
    8000314e:	00006497          	auipc	s1,0x6
    80003152:	ee248493          	addi	s1,s1,-286 # 80009030 <ticks>
    if(myproc()->killed){
    80003156:	fffff097          	auipc	ra,0xfffff
    8000315a:	828080e7          	jalr	-2008(ra) # 8000197e <myproc>
    8000315e:	551c                	lw	a5,40(a0)
    80003160:	ef9d                	bnez	a5,8000319e <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003162:	85ce                	mv	a1,s3
    80003164:	8526                	mv	a0,s1
    80003166:	fffff097          	auipc	ra,0xfffff
    8000316a:	07a080e7          	jalr	122(ra) # 800021e0 <sleep>
  while(ticks - ticks0 < n){
    8000316e:	409c                	lw	a5,0(s1)
    80003170:	412787bb          	subw	a5,a5,s2
    80003174:	fcc42703          	lw	a4,-52(s0)
    80003178:	fce7efe3          	bltu	a5,a4,80003156 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000317c:	00014517          	auipc	a0,0x14
    80003180:	75450513          	addi	a0,a0,1876 # 800178d0 <tickslock>
    80003184:	ffffe097          	auipc	ra,0xffffe
    80003188:	af2080e7          	jalr	-1294(ra) # 80000c76 <release>
  return 0;
    8000318c:	4781                	li	a5,0
}
    8000318e:	853e                	mv	a0,a5
    80003190:	70e2                	ld	ra,56(sp)
    80003192:	7442                	ld	s0,48(sp)
    80003194:	74a2                	ld	s1,40(sp)
    80003196:	7902                	ld	s2,32(sp)
    80003198:	69e2                	ld	s3,24(sp)
    8000319a:	6121                	addi	sp,sp,64
    8000319c:	8082                	ret
      release(&tickslock);
    8000319e:	00014517          	auipc	a0,0x14
    800031a2:	73250513          	addi	a0,a0,1842 # 800178d0 <tickslock>
    800031a6:	ffffe097          	auipc	ra,0xffffe
    800031aa:	ad0080e7          	jalr	-1328(ra) # 80000c76 <release>
      return -1;
    800031ae:	57fd                	li	a5,-1
    800031b0:	bff9                	j	8000318e <sys_sleep+0x88>

00000000800031b2 <sys_kill>:

uint64
sys_kill(void)
{
    800031b2:	1101                	addi	sp,sp,-32
    800031b4:	ec06                	sd	ra,24(sp)
    800031b6:	e822                	sd	s0,16(sp)
    800031b8:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800031ba:	fec40593          	addi	a1,s0,-20
    800031be:	4501                	li	a0,0
    800031c0:	00000097          	auipc	ra,0x0
    800031c4:	c1e080e7          	jalr	-994(ra) # 80002dde <argint>
    800031c8:	87aa                	mv	a5,a0
    return -1;
    800031ca:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800031cc:	0007c863          	bltz	a5,800031dc <sys_kill+0x2a>
  return kill(pid);
    800031d0:	fec42503          	lw	a0,-20(s0)
    800031d4:	fffff097          	auipc	ra,0xfffff
    800031d8:	516080e7          	jalr	1302(ra) # 800026ea <kill>
}
    800031dc:	60e2                	ld	ra,24(sp)
    800031de:	6442                	ld	s0,16(sp)
    800031e0:	6105                	addi	sp,sp,32
    800031e2:	8082                	ret

00000000800031e4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800031e4:	1101                	addi	sp,sp,-32
    800031e6:	ec06                	sd	ra,24(sp)
    800031e8:	e822                	sd	s0,16(sp)
    800031ea:	e426                	sd	s1,8(sp)
    800031ec:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800031ee:	00014517          	auipc	a0,0x14
    800031f2:	6e250513          	addi	a0,a0,1762 # 800178d0 <tickslock>
    800031f6:	ffffe097          	auipc	ra,0xffffe
    800031fa:	9cc080e7          	jalr	-1588(ra) # 80000bc2 <acquire>
  xticks = ticks;
    800031fe:	00006497          	auipc	s1,0x6
    80003202:	e324a483          	lw	s1,-462(s1) # 80009030 <ticks>
  release(&tickslock);
    80003206:	00014517          	auipc	a0,0x14
    8000320a:	6ca50513          	addi	a0,a0,1738 # 800178d0 <tickslock>
    8000320e:	ffffe097          	auipc	ra,0xffffe
    80003212:	a68080e7          	jalr	-1432(ra) # 80000c76 <release>
  return xticks;
}
    80003216:	02049513          	slli	a0,s1,0x20
    8000321a:	9101                	srli	a0,a0,0x20
    8000321c:	60e2                	ld	ra,24(sp)
    8000321e:	6442                	ld	s0,16(sp)
    80003220:	64a2                	ld	s1,8(sp)
    80003222:	6105                	addi	sp,sp,32
    80003224:	8082                	ret

0000000080003226 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003226:	7179                	addi	sp,sp,-48
    80003228:	f406                	sd	ra,40(sp)
    8000322a:	f022                	sd	s0,32(sp)
    8000322c:	ec26                	sd	s1,24(sp)
    8000322e:	e84a                	sd	s2,16(sp)
    80003230:	e44e                	sd	s3,8(sp)
    80003232:	e052                	sd	s4,0(sp)
    80003234:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003236:	00005597          	auipc	a1,0x5
    8000323a:	3ea58593          	addi	a1,a1,1002 # 80008620 <syscalls+0xc8>
    8000323e:	00014517          	auipc	a0,0x14
    80003242:	6aa50513          	addi	a0,a0,1706 # 800178e8 <bcache>
    80003246:	ffffe097          	auipc	ra,0xffffe
    8000324a:	8ec080e7          	jalr	-1812(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000324e:	0001c797          	auipc	a5,0x1c
    80003252:	69a78793          	addi	a5,a5,1690 # 8001f8e8 <bcache+0x8000>
    80003256:	0001d717          	auipc	a4,0x1d
    8000325a:	8fa70713          	addi	a4,a4,-1798 # 8001fb50 <bcache+0x8268>
    8000325e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003262:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003266:	00014497          	auipc	s1,0x14
    8000326a:	69a48493          	addi	s1,s1,1690 # 80017900 <bcache+0x18>
    b->next = bcache.head.next;
    8000326e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003270:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003272:	00005a17          	auipc	s4,0x5
    80003276:	3b6a0a13          	addi	s4,s4,950 # 80008628 <syscalls+0xd0>
    b->next = bcache.head.next;
    8000327a:	2b893783          	ld	a5,696(s2)
    8000327e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003280:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003284:	85d2                	mv	a1,s4
    80003286:	01048513          	addi	a0,s1,16
    8000328a:	00001097          	auipc	ra,0x1
    8000328e:	4c2080e7          	jalr	1218(ra) # 8000474c <initsleeplock>
    bcache.head.next->prev = b;
    80003292:	2b893783          	ld	a5,696(s2)
    80003296:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003298:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000329c:	45848493          	addi	s1,s1,1112
    800032a0:	fd349de3          	bne	s1,s3,8000327a <binit+0x54>
  }
}
    800032a4:	70a2                	ld	ra,40(sp)
    800032a6:	7402                	ld	s0,32(sp)
    800032a8:	64e2                	ld	s1,24(sp)
    800032aa:	6942                	ld	s2,16(sp)
    800032ac:	69a2                	ld	s3,8(sp)
    800032ae:	6a02                	ld	s4,0(sp)
    800032b0:	6145                	addi	sp,sp,48
    800032b2:	8082                	ret

00000000800032b4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800032b4:	7179                	addi	sp,sp,-48
    800032b6:	f406                	sd	ra,40(sp)
    800032b8:	f022                	sd	s0,32(sp)
    800032ba:	ec26                	sd	s1,24(sp)
    800032bc:	e84a                	sd	s2,16(sp)
    800032be:	e44e                	sd	s3,8(sp)
    800032c0:	1800                	addi	s0,sp,48
    800032c2:	892a                	mv	s2,a0
    800032c4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800032c6:	00014517          	auipc	a0,0x14
    800032ca:	62250513          	addi	a0,a0,1570 # 800178e8 <bcache>
    800032ce:	ffffe097          	auipc	ra,0xffffe
    800032d2:	8f4080e7          	jalr	-1804(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800032d6:	0001d497          	auipc	s1,0x1d
    800032da:	8ca4b483          	ld	s1,-1846(s1) # 8001fba0 <bcache+0x82b8>
    800032de:	0001d797          	auipc	a5,0x1d
    800032e2:	87278793          	addi	a5,a5,-1934 # 8001fb50 <bcache+0x8268>
    800032e6:	02f48f63          	beq	s1,a5,80003324 <bread+0x70>
    800032ea:	873e                	mv	a4,a5
    800032ec:	a021                	j	800032f4 <bread+0x40>
    800032ee:	68a4                	ld	s1,80(s1)
    800032f0:	02e48a63          	beq	s1,a4,80003324 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800032f4:	449c                	lw	a5,8(s1)
    800032f6:	ff279ce3          	bne	a5,s2,800032ee <bread+0x3a>
    800032fa:	44dc                	lw	a5,12(s1)
    800032fc:	ff3799e3          	bne	a5,s3,800032ee <bread+0x3a>
      b->refcnt++;
    80003300:	40bc                	lw	a5,64(s1)
    80003302:	2785                	addiw	a5,a5,1
    80003304:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003306:	00014517          	auipc	a0,0x14
    8000330a:	5e250513          	addi	a0,a0,1506 # 800178e8 <bcache>
    8000330e:	ffffe097          	auipc	ra,0xffffe
    80003312:	968080e7          	jalr	-1688(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003316:	01048513          	addi	a0,s1,16
    8000331a:	00001097          	auipc	ra,0x1
    8000331e:	46c080e7          	jalr	1132(ra) # 80004786 <acquiresleep>
      return b;
    80003322:	a8b9                	j	80003380 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003324:	0001d497          	auipc	s1,0x1d
    80003328:	8744b483          	ld	s1,-1932(s1) # 8001fb98 <bcache+0x82b0>
    8000332c:	0001d797          	auipc	a5,0x1d
    80003330:	82478793          	addi	a5,a5,-2012 # 8001fb50 <bcache+0x8268>
    80003334:	00f48863          	beq	s1,a5,80003344 <bread+0x90>
    80003338:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000333a:	40bc                	lw	a5,64(s1)
    8000333c:	cf81                	beqz	a5,80003354 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000333e:	64a4                	ld	s1,72(s1)
    80003340:	fee49de3          	bne	s1,a4,8000333a <bread+0x86>
  panic("bget: no buffers");
    80003344:	00005517          	auipc	a0,0x5
    80003348:	2ec50513          	addi	a0,a0,748 # 80008630 <syscalls+0xd8>
    8000334c:	ffffd097          	auipc	ra,0xffffd
    80003350:	1de080e7          	jalr	478(ra) # 8000052a <panic>
      b->dev = dev;
    80003354:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003358:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000335c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003360:	4785                	li	a5,1
    80003362:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003364:	00014517          	auipc	a0,0x14
    80003368:	58450513          	addi	a0,a0,1412 # 800178e8 <bcache>
    8000336c:	ffffe097          	auipc	ra,0xffffe
    80003370:	90a080e7          	jalr	-1782(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003374:	01048513          	addi	a0,s1,16
    80003378:	00001097          	auipc	ra,0x1
    8000337c:	40e080e7          	jalr	1038(ra) # 80004786 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003380:	409c                	lw	a5,0(s1)
    80003382:	cb89                	beqz	a5,80003394 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003384:	8526                	mv	a0,s1
    80003386:	70a2                	ld	ra,40(sp)
    80003388:	7402                	ld	s0,32(sp)
    8000338a:	64e2                	ld	s1,24(sp)
    8000338c:	6942                	ld	s2,16(sp)
    8000338e:	69a2                	ld	s3,8(sp)
    80003390:	6145                	addi	sp,sp,48
    80003392:	8082                	ret
    virtio_disk_rw(b, 0);
    80003394:	4581                	li	a1,0
    80003396:	8526                	mv	a0,s1
    80003398:	00003097          	auipc	ra,0x3
    8000339c:	f1e080e7          	jalr	-226(ra) # 800062b6 <virtio_disk_rw>
    b->valid = 1;
    800033a0:	4785                	li	a5,1
    800033a2:	c09c                	sw	a5,0(s1)
  return b;
    800033a4:	b7c5                	j	80003384 <bread+0xd0>

00000000800033a6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800033a6:	1101                	addi	sp,sp,-32
    800033a8:	ec06                	sd	ra,24(sp)
    800033aa:	e822                	sd	s0,16(sp)
    800033ac:	e426                	sd	s1,8(sp)
    800033ae:	1000                	addi	s0,sp,32
    800033b0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033b2:	0541                	addi	a0,a0,16
    800033b4:	00001097          	auipc	ra,0x1
    800033b8:	46c080e7          	jalr	1132(ra) # 80004820 <holdingsleep>
    800033bc:	cd01                	beqz	a0,800033d4 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800033be:	4585                	li	a1,1
    800033c0:	8526                	mv	a0,s1
    800033c2:	00003097          	auipc	ra,0x3
    800033c6:	ef4080e7          	jalr	-268(ra) # 800062b6 <virtio_disk_rw>
}
    800033ca:	60e2                	ld	ra,24(sp)
    800033cc:	6442                	ld	s0,16(sp)
    800033ce:	64a2                	ld	s1,8(sp)
    800033d0:	6105                	addi	sp,sp,32
    800033d2:	8082                	ret
    panic("bwrite");
    800033d4:	00005517          	auipc	a0,0x5
    800033d8:	27450513          	addi	a0,a0,628 # 80008648 <syscalls+0xf0>
    800033dc:	ffffd097          	auipc	ra,0xffffd
    800033e0:	14e080e7          	jalr	334(ra) # 8000052a <panic>

00000000800033e4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800033e4:	1101                	addi	sp,sp,-32
    800033e6:	ec06                	sd	ra,24(sp)
    800033e8:	e822                	sd	s0,16(sp)
    800033ea:	e426                	sd	s1,8(sp)
    800033ec:	e04a                	sd	s2,0(sp)
    800033ee:	1000                	addi	s0,sp,32
    800033f0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033f2:	01050913          	addi	s2,a0,16
    800033f6:	854a                	mv	a0,s2
    800033f8:	00001097          	auipc	ra,0x1
    800033fc:	428080e7          	jalr	1064(ra) # 80004820 <holdingsleep>
    80003400:	c92d                	beqz	a0,80003472 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003402:	854a                	mv	a0,s2
    80003404:	00001097          	auipc	ra,0x1
    80003408:	3d8080e7          	jalr	984(ra) # 800047dc <releasesleep>

  acquire(&bcache.lock);
    8000340c:	00014517          	auipc	a0,0x14
    80003410:	4dc50513          	addi	a0,a0,1244 # 800178e8 <bcache>
    80003414:	ffffd097          	auipc	ra,0xffffd
    80003418:	7ae080e7          	jalr	1966(ra) # 80000bc2 <acquire>
  b->refcnt--;
    8000341c:	40bc                	lw	a5,64(s1)
    8000341e:	37fd                	addiw	a5,a5,-1
    80003420:	0007871b          	sext.w	a4,a5
    80003424:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003426:	eb05                	bnez	a4,80003456 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003428:	68bc                	ld	a5,80(s1)
    8000342a:	64b8                	ld	a4,72(s1)
    8000342c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000342e:	64bc                	ld	a5,72(s1)
    80003430:	68b8                	ld	a4,80(s1)
    80003432:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003434:	0001c797          	auipc	a5,0x1c
    80003438:	4b478793          	addi	a5,a5,1204 # 8001f8e8 <bcache+0x8000>
    8000343c:	2b87b703          	ld	a4,696(a5)
    80003440:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003442:	0001c717          	auipc	a4,0x1c
    80003446:	70e70713          	addi	a4,a4,1806 # 8001fb50 <bcache+0x8268>
    8000344a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000344c:	2b87b703          	ld	a4,696(a5)
    80003450:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003452:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003456:	00014517          	auipc	a0,0x14
    8000345a:	49250513          	addi	a0,a0,1170 # 800178e8 <bcache>
    8000345e:	ffffe097          	auipc	ra,0xffffe
    80003462:	818080e7          	jalr	-2024(ra) # 80000c76 <release>
}
    80003466:	60e2                	ld	ra,24(sp)
    80003468:	6442                	ld	s0,16(sp)
    8000346a:	64a2                	ld	s1,8(sp)
    8000346c:	6902                	ld	s2,0(sp)
    8000346e:	6105                	addi	sp,sp,32
    80003470:	8082                	ret
    panic("brelse");
    80003472:	00005517          	auipc	a0,0x5
    80003476:	1de50513          	addi	a0,a0,478 # 80008650 <syscalls+0xf8>
    8000347a:	ffffd097          	auipc	ra,0xffffd
    8000347e:	0b0080e7          	jalr	176(ra) # 8000052a <panic>

0000000080003482 <bpin>:

void
bpin(struct buf *b) {
    80003482:	1101                	addi	sp,sp,-32
    80003484:	ec06                	sd	ra,24(sp)
    80003486:	e822                	sd	s0,16(sp)
    80003488:	e426                	sd	s1,8(sp)
    8000348a:	1000                	addi	s0,sp,32
    8000348c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000348e:	00014517          	auipc	a0,0x14
    80003492:	45a50513          	addi	a0,a0,1114 # 800178e8 <bcache>
    80003496:	ffffd097          	auipc	ra,0xffffd
    8000349a:	72c080e7          	jalr	1836(ra) # 80000bc2 <acquire>
  b->refcnt++;
    8000349e:	40bc                	lw	a5,64(s1)
    800034a0:	2785                	addiw	a5,a5,1
    800034a2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034a4:	00014517          	auipc	a0,0x14
    800034a8:	44450513          	addi	a0,a0,1092 # 800178e8 <bcache>
    800034ac:	ffffd097          	auipc	ra,0xffffd
    800034b0:	7ca080e7          	jalr	1994(ra) # 80000c76 <release>
}
    800034b4:	60e2                	ld	ra,24(sp)
    800034b6:	6442                	ld	s0,16(sp)
    800034b8:	64a2                	ld	s1,8(sp)
    800034ba:	6105                	addi	sp,sp,32
    800034bc:	8082                	ret

00000000800034be <bunpin>:

void
bunpin(struct buf *b) {
    800034be:	1101                	addi	sp,sp,-32
    800034c0:	ec06                	sd	ra,24(sp)
    800034c2:	e822                	sd	s0,16(sp)
    800034c4:	e426                	sd	s1,8(sp)
    800034c6:	1000                	addi	s0,sp,32
    800034c8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034ca:	00014517          	auipc	a0,0x14
    800034ce:	41e50513          	addi	a0,a0,1054 # 800178e8 <bcache>
    800034d2:	ffffd097          	auipc	ra,0xffffd
    800034d6:	6f0080e7          	jalr	1776(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800034da:	40bc                	lw	a5,64(s1)
    800034dc:	37fd                	addiw	a5,a5,-1
    800034de:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034e0:	00014517          	auipc	a0,0x14
    800034e4:	40850513          	addi	a0,a0,1032 # 800178e8 <bcache>
    800034e8:	ffffd097          	auipc	ra,0xffffd
    800034ec:	78e080e7          	jalr	1934(ra) # 80000c76 <release>
}
    800034f0:	60e2                	ld	ra,24(sp)
    800034f2:	6442                	ld	s0,16(sp)
    800034f4:	64a2                	ld	s1,8(sp)
    800034f6:	6105                	addi	sp,sp,32
    800034f8:	8082                	ret

00000000800034fa <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800034fa:	1101                	addi	sp,sp,-32
    800034fc:	ec06                	sd	ra,24(sp)
    800034fe:	e822                	sd	s0,16(sp)
    80003500:	e426                	sd	s1,8(sp)
    80003502:	e04a                	sd	s2,0(sp)
    80003504:	1000                	addi	s0,sp,32
    80003506:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003508:	00d5d59b          	srliw	a1,a1,0xd
    8000350c:	0001d797          	auipc	a5,0x1d
    80003510:	ab87a783          	lw	a5,-1352(a5) # 8001ffc4 <sb+0x1c>
    80003514:	9dbd                	addw	a1,a1,a5
    80003516:	00000097          	auipc	ra,0x0
    8000351a:	d9e080e7          	jalr	-610(ra) # 800032b4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000351e:	0074f713          	andi	a4,s1,7
    80003522:	4785                	li	a5,1
    80003524:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003528:	14ce                	slli	s1,s1,0x33
    8000352a:	90d9                	srli	s1,s1,0x36
    8000352c:	00950733          	add	a4,a0,s1
    80003530:	05874703          	lbu	a4,88(a4)
    80003534:	00e7f6b3          	and	a3,a5,a4
    80003538:	c69d                	beqz	a3,80003566 <bfree+0x6c>
    8000353a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000353c:	94aa                	add	s1,s1,a0
    8000353e:	fff7c793          	not	a5,a5
    80003542:	8ff9                	and	a5,a5,a4
    80003544:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003548:	00001097          	auipc	ra,0x1
    8000354c:	11e080e7          	jalr	286(ra) # 80004666 <log_write>
  brelse(bp);
    80003550:	854a                	mv	a0,s2
    80003552:	00000097          	auipc	ra,0x0
    80003556:	e92080e7          	jalr	-366(ra) # 800033e4 <brelse>
}
    8000355a:	60e2                	ld	ra,24(sp)
    8000355c:	6442                	ld	s0,16(sp)
    8000355e:	64a2                	ld	s1,8(sp)
    80003560:	6902                	ld	s2,0(sp)
    80003562:	6105                	addi	sp,sp,32
    80003564:	8082                	ret
    panic("freeing free block");
    80003566:	00005517          	auipc	a0,0x5
    8000356a:	0f250513          	addi	a0,a0,242 # 80008658 <syscalls+0x100>
    8000356e:	ffffd097          	auipc	ra,0xffffd
    80003572:	fbc080e7          	jalr	-68(ra) # 8000052a <panic>

0000000080003576 <balloc>:
{
    80003576:	711d                	addi	sp,sp,-96
    80003578:	ec86                	sd	ra,88(sp)
    8000357a:	e8a2                	sd	s0,80(sp)
    8000357c:	e4a6                	sd	s1,72(sp)
    8000357e:	e0ca                	sd	s2,64(sp)
    80003580:	fc4e                	sd	s3,56(sp)
    80003582:	f852                	sd	s4,48(sp)
    80003584:	f456                	sd	s5,40(sp)
    80003586:	f05a                	sd	s6,32(sp)
    80003588:	ec5e                	sd	s7,24(sp)
    8000358a:	e862                	sd	s8,16(sp)
    8000358c:	e466                	sd	s9,8(sp)
    8000358e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003590:	0001d797          	auipc	a5,0x1d
    80003594:	a1c7a783          	lw	a5,-1508(a5) # 8001ffac <sb+0x4>
    80003598:	cbd1                	beqz	a5,8000362c <balloc+0xb6>
    8000359a:	8baa                	mv	s7,a0
    8000359c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000359e:	0001db17          	auipc	s6,0x1d
    800035a2:	a0ab0b13          	addi	s6,s6,-1526 # 8001ffa8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035a6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800035a8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035aa:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800035ac:	6c89                	lui	s9,0x2
    800035ae:	a831                	j	800035ca <balloc+0x54>
    brelse(bp);
    800035b0:	854a                	mv	a0,s2
    800035b2:	00000097          	auipc	ra,0x0
    800035b6:	e32080e7          	jalr	-462(ra) # 800033e4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800035ba:	015c87bb          	addw	a5,s9,s5
    800035be:	00078a9b          	sext.w	s5,a5
    800035c2:	004b2703          	lw	a4,4(s6)
    800035c6:	06eaf363          	bgeu	s5,a4,8000362c <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800035ca:	41fad79b          	sraiw	a5,s5,0x1f
    800035ce:	0137d79b          	srliw	a5,a5,0x13
    800035d2:	015787bb          	addw	a5,a5,s5
    800035d6:	40d7d79b          	sraiw	a5,a5,0xd
    800035da:	01cb2583          	lw	a1,28(s6)
    800035de:	9dbd                	addw	a1,a1,a5
    800035e0:	855e                	mv	a0,s7
    800035e2:	00000097          	auipc	ra,0x0
    800035e6:	cd2080e7          	jalr	-814(ra) # 800032b4 <bread>
    800035ea:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035ec:	004b2503          	lw	a0,4(s6)
    800035f0:	000a849b          	sext.w	s1,s5
    800035f4:	8662                	mv	a2,s8
    800035f6:	faa4fde3          	bgeu	s1,a0,800035b0 <balloc+0x3a>
      m = 1 << (bi % 8);
    800035fa:	41f6579b          	sraiw	a5,a2,0x1f
    800035fe:	01d7d69b          	srliw	a3,a5,0x1d
    80003602:	00c6873b          	addw	a4,a3,a2
    80003606:	00777793          	andi	a5,a4,7
    8000360a:	9f95                	subw	a5,a5,a3
    8000360c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003610:	4037571b          	sraiw	a4,a4,0x3
    80003614:	00e906b3          	add	a3,s2,a4
    80003618:	0586c683          	lbu	a3,88(a3)
    8000361c:	00d7f5b3          	and	a1,a5,a3
    80003620:	cd91                	beqz	a1,8000363c <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003622:	2605                	addiw	a2,a2,1
    80003624:	2485                	addiw	s1,s1,1
    80003626:	fd4618e3          	bne	a2,s4,800035f6 <balloc+0x80>
    8000362a:	b759                	j	800035b0 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000362c:	00005517          	auipc	a0,0x5
    80003630:	04450513          	addi	a0,a0,68 # 80008670 <syscalls+0x118>
    80003634:	ffffd097          	auipc	ra,0xffffd
    80003638:	ef6080e7          	jalr	-266(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000363c:	974a                	add	a4,a4,s2
    8000363e:	8fd5                	or	a5,a5,a3
    80003640:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003644:	854a                	mv	a0,s2
    80003646:	00001097          	auipc	ra,0x1
    8000364a:	020080e7          	jalr	32(ra) # 80004666 <log_write>
        brelse(bp);
    8000364e:	854a                	mv	a0,s2
    80003650:	00000097          	auipc	ra,0x0
    80003654:	d94080e7          	jalr	-620(ra) # 800033e4 <brelse>
  bp = bread(dev, bno);
    80003658:	85a6                	mv	a1,s1
    8000365a:	855e                	mv	a0,s7
    8000365c:	00000097          	auipc	ra,0x0
    80003660:	c58080e7          	jalr	-936(ra) # 800032b4 <bread>
    80003664:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003666:	40000613          	li	a2,1024
    8000366a:	4581                	li	a1,0
    8000366c:	05850513          	addi	a0,a0,88
    80003670:	ffffd097          	auipc	ra,0xffffd
    80003674:	64e080e7          	jalr	1614(ra) # 80000cbe <memset>
  log_write(bp);
    80003678:	854a                	mv	a0,s2
    8000367a:	00001097          	auipc	ra,0x1
    8000367e:	fec080e7          	jalr	-20(ra) # 80004666 <log_write>
  brelse(bp);
    80003682:	854a                	mv	a0,s2
    80003684:	00000097          	auipc	ra,0x0
    80003688:	d60080e7          	jalr	-672(ra) # 800033e4 <brelse>
}
    8000368c:	8526                	mv	a0,s1
    8000368e:	60e6                	ld	ra,88(sp)
    80003690:	6446                	ld	s0,80(sp)
    80003692:	64a6                	ld	s1,72(sp)
    80003694:	6906                	ld	s2,64(sp)
    80003696:	79e2                	ld	s3,56(sp)
    80003698:	7a42                	ld	s4,48(sp)
    8000369a:	7aa2                	ld	s5,40(sp)
    8000369c:	7b02                	ld	s6,32(sp)
    8000369e:	6be2                	ld	s7,24(sp)
    800036a0:	6c42                	ld	s8,16(sp)
    800036a2:	6ca2                	ld	s9,8(sp)
    800036a4:	6125                	addi	sp,sp,96
    800036a6:	8082                	ret

00000000800036a8 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800036a8:	7179                	addi	sp,sp,-48
    800036aa:	f406                	sd	ra,40(sp)
    800036ac:	f022                	sd	s0,32(sp)
    800036ae:	ec26                	sd	s1,24(sp)
    800036b0:	e84a                	sd	s2,16(sp)
    800036b2:	e44e                	sd	s3,8(sp)
    800036b4:	e052                	sd	s4,0(sp)
    800036b6:	1800                	addi	s0,sp,48
    800036b8:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800036ba:	47ad                	li	a5,11
    800036bc:	04b7fe63          	bgeu	a5,a1,80003718 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800036c0:	ff45849b          	addiw	s1,a1,-12
    800036c4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800036c8:	0ff00793          	li	a5,255
    800036cc:	0ae7e463          	bltu	a5,a4,80003774 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800036d0:	08052583          	lw	a1,128(a0)
    800036d4:	c5b5                	beqz	a1,80003740 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800036d6:	00092503          	lw	a0,0(s2)
    800036da:	00000097          	auipc	ra,0x0
    800036de:	bda080e7          	jalr	-1062(ra) # 800032b4 <bread>
    800036e2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800036e4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800036e8:	02049713          	slli	a4,s1,0x20
    800036ec:	01e75593          	srli	a1,a4,0x1e
    800036f0:	00b784b3          	add	s1,a5,a1
    800036f4:	0004a983          	lw	s3,0(s1)
    800036f8:	04098e63          	beqz	s3,80003754 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800036fc:	8552                	mv	a0,s4
    800036fe:	00000097          	auipc	ra,0x0
    80003702:	ce6080e7          	jalr	-794(ra) # 800033e4 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003706:	854e                	mv	a0,s3
    80003708:	70a2                	ld	ra,40(sp)
    8000370a:	7402                	ld	s0,32(sp)
    8000370c:	64e2                	ld	s1,24(sp)
    8000370e:	6942                	ld	s2,16(sp)
    80003710:	69a2                	ld	s3,8(sp)
    80003712:	6a02                	ld	s4,0(sp)
    80003714:	6145                	addi	sp,sp,48
    80003716:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003718:	02059793          	slli	a5,a1,0x20
    8000371c:	01e7d593          	srli	a1,a5,0x1e
    80003720:	00b504b3          	add	s1,a0,a1
    80003724:	0504a983          	lw	s3,80(s1)
    80003728:	fc099fe3          	bnez	s3,80003706 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000372c:	4108                	lw	a0,0(a0)
    8000372e:	00000097          	auipc	ra,0x0
    80003732:	e48080e7          	jalr	-440(ra) # 80003576 <balloc>
    80003736:	0005099b          	sext.w	s3,a0
    8000373a:	0534a823          	sw	s3,80(s1)
    8000373e:	b7e1                	j	80003706 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003740:	4108                	lw	a0,0(a0)
    80003742:	00000097          	auipc	ra,0x0
    80003746:	e34080e7          	jalr	-460(ra) # 80003576 <balloc>
    8000374a:	0005059b          	sext.w	a1,a0
    8000374e:	08b92023          	sw	a1,128(s2)
    80003752:	b751                	j	800036d6 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003754:	00092503          	lw	a0,0(s2)
    80003758:	00000097          	auipc	ra,0x0
    8000375c:	e1e080e7          	jalr	-482(ra) # 80003576 <balloc>
    80003760:	0005099b          	sext.w	s3,a0
    80003764:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003768:	8552                	mv	a0,s4
    8000376a:	00001097          	auipc	ra,0x1
    8000376e:	efc080e7          	jalr	-260(ra) # 80004666 <log_write>
    80003772:	b769                	j	800036fc <bmap+0x54>
  panic("bmap: out of range");
    80003774:	00005517          	auipc	a0,0x5
    80003778:	f1450513          	addi	a0,a0,-236 # 80008688 <syscalls+0x130>
    8000377c:	ffffd097          	auipc	ra,0xffffd
    80003780:	dae080e7          	jalr	-594(ra) # 8000052a <panic>

0000000080003784 <iget>:
{
    80003784:	7179                	addi	sp,sp,-48
    80003786:	f406                	sd	ra,40(sp)
    80003788:	f022                	sd	s0,32(sp)
    8000378a:	ec26                	sd	s1,24(sp)
    8000378c:	e84a                	sd	s2,16(sp)
    8000378e:	e44e                	sd	s3,8(sp)
    80003790:	e052                	sd	s4,0(sp)
    80003792:	1800                	addi	s0,sp,48
    80003794:	89aa                	mv	s3,a0
    80003796:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003798:	0001d517          	auipc	a0,0x1d
    8000379c:	83050513          	addi	a0,a0,-2000 # 8001ffc8 <itable>
    800037a0:	ffffd097          	auipc	ra,0xffffd
    800037a4:	422080e7          	jalr	1058(ra) # 80000bc2 <acquire>
  empty = 0;
    800037a8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037aa:	0001d497          	auipc	s1,0x1d
    800037ae:	83648493          	addi	s1,s1,-1994 # 8001ffe0 <itable+0x18>
    800037b2:	0001e697          	auipc	a3,0x1e
    800037b6:	2be68693          	addi	a3,a3,702 # 80021a70 <log>
    800037ba:	a039                	j	800037c8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037bc:	02090b63          	beqz	s2,800037f2 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037c0:	08848493          	addi	s1,s1,136
    800037c4:	02d48a63          	beq	s1,a3,800037f8 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800037c8:	449c                	lw	a5,8(s1)
    800037ca:	fef059e3          	blez	a5,800037bc <iget+0x38>
    800037ce:	4098                	lw	a4,0(s1)
    800037d0:	ff3716e3          	bne	a4,s3,800037bc <iget+0x38>
    800037d4:	40d8                	lw	a4,4(s1)
    800037d6:	ff4713e3          	bne	a4,s4,800037bc <iget+0x38>
      ip->ref++;
    800037da:	2785                	addiw	a5,a5,1
    800037dc:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800037de:	0001c517          	auipc	a0,0x1c
    800037e2:	7ea50513          	addi	a0,a0,2026 # 8001ffc8 <itable>
    800037e6:	ffffd097          	auipc	ra,0xffffd
    800037ea:	490080e7          	jalr	1168(ra) # 80000c76 <release>
      return ip;
    800037ee:	8926                	mv	s2,s1
    800037f0:	a03d                	j	8000381e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037f2:	f7f9                	bnez	a5,800037c0 <iget+0x3c>
    800037f4:	8926                	mv	s2,s1
    800037f6:	b7e9                	j	800037c0 <iget+0x3c>
  if(empty == 0)
    800037f8:	02090c63          	beqz	s2,80003830 <iget+0xac>
  ip->dev = dev;
    800037fc:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003800:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003804:	4785                	li	a5,1
    80003806:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000380a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000380e:	0001c517          	auipc	a0,0x1c
    80003812:	7ba50513          	addi	a0,a0,1978 # 8001ffc8 <itable>
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	460080e7          	jalr	1120(ra) # 80000c76 <release>
}
    8000381e:	854a                	mv	a0,s2
    80003820:	70a2                	ld	ra,40(sp)
    80003822:	7402                	ld	s0,32(sp)
    80003824:	64e2                	ld	s1,24(sp)
    80003826:	6942                	ld	s2,16(sp)
    80003828:	69a2                	ld	s3,8(sp)
    8000382a:	6a02                	ld	s4,0(sp)
    8000382c:	6145                	addi	sp,sp,48
    8000382e:	8082                	ret
    panic("iget: no inodes");
    80003830:	00005517          	auipc	a0,0x5
    80003834:	e7050513          	addi	a0,a0,-400 # 800086a0 <syscalls+0x148>
    80003838:	ffffd097          	auipc	ra,0xffffd
    8000383c:	cf2080e7          	jalr	-782(ra) # 8000052a <panic>

0000000080003840 <fsinit>:
fsinit(int dev) {
    80003840:	7179                	addi	sp,sp,-48
    80003842:	f406                	sd	ra,40(sp)
    80003844:	f022                	sd	s0,32(sp)
    80003846:	ec26                	sd	s1,24(sp)
    80003848:	e84a                	sd	s2,16(sp)
    8000384a:	e44e                	sd	s3,8(sp)
    8000384c:	1800                	addi	s0,sp,48
    8000384e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003850:	4585                	li	a1,1
    80003852:	00000097          	auipc	ra,0x0
    80003856:	a62080e7          	jalr	-1438(ra) # 800032b4 <bread>
    8000385a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000385c:	0001c997          	auipc	s3,0x1c
    80003860:	74c98993          	addi	s3,s3,1868 # 8001ffa8 <sb>
    80003864:	02000613          	li	a2,32
    80003868:	05850593          	addi	a1,a0,88
    8000386c:	854e                	mv	a0,s3
    8000386e:	ffffd097          	auipc	ra,0xffffd
    80003872:	4ac080e7          	jalr	1196(ra) # 80000d1a <memmove>
  brelse(bp);
    80003876:	8526                	mv	a0,s1
    80003878:	00000097          	auipc	ra,0x0
    8000387c:	b6c080e7          	jalr	-1172(ra) # 800033e4 <brelse>
  if(sb.magic != FSMAGIC)
    80003880:	0009a703          	lw	a4,0(s3)
    80003884:	102037b7          	lui	a5,0x10203
    80003888:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000388c:	02f71263          	bne	a4,a5,800038b0 <fsinit+0x70>
  initlog(dev, &sb);
    80003890:	0001c597          	auipc	a1,0x1c
    80003894:	71858593          	addi	a1,a1,1816 # 8001ffa8 <sb>
    80003898:	854a                	mv	a0,s2
    8000389a:	00001097          	auipc	ra,0x1
    8000389e:	b4e080e7          	jalr	-1202(ra) # 800043e8 <initlog>
}
    800038a2:	70a2                	ld	ra,40(sp)
    800038a4:	7402                	ld	s0,32(sp)
    800038a6:	64e2                	ld	s1,24(sp)
    800038a8:	6942                	ld	s2,16(sp)
    800038aa:	69a2                	ld	s3,8(sp)
    800038ac:	6145                	addi	sp,sp,48
    800038ae:	8082                	ret
    panic("invalid file system");
    800038b0:	00005517          	auipc	a0,0x5
    800038b4:	e0050513          	addi	a0,a0,-512 # 800086b0 <syscalls+0x158>
    800038b8:	ffffd097          	auipc	ra,0xffffd
    800038bc:	c72080e7          	jalr	-910(ra) # 8000052a <panic>

00000000800038c0 <iinit>:
{
    800038c0:	7179                	addi	sp,sp,-48
    800038c2:	f406                	sd	ra,40(sp)
    800038c4:	f022                	sd	s0,32(sp)
    800038c6:	ec26                	sd	s1,24(sp)
    800038c8:	e84a                	sd	s2,16(sp)
    800038ca:	e44e                	sd	s3,8(sp)
    800038cc:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800038ce:	00005597          	auipc	a1,0x5
    800038d2:	dfa58593          	addi	a1,a1,-518 # 800086c8 <syscalls+0x170>
    800038d6:	0001c517          	auipc	a0,0x1c
    800038da:	6f250513          	addi	a0,a0,1778 # 8001ffc8 <itable>
    800038de:	ffffd097          	auipc	ra,0xffffd
    800038e2:	254080e7          	jalr	596(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    800038e6:	0001c497          	auipc	s1,0x1c
    800038ea:	70a48493          	addi	s1,s1,1802 # 8001fff0 <itable+0x28>
    800038ee:	0001e997          	auipc	s3,0x1e
    800038f2:	19298993          	addi	s3,s3,402 # 80021a80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800038f6:	00005917          	auipc	s2,0x5
    800038fa:	dda90913          	addi	s2,s2,-550 # 800086d0 <syscalls+0x178>
    800038fe:	85ca                	mv	a1,s2
    80003900:	8526                	mv	a0,s1
    80003902:	00001097          	auipc	ra,0x1
    80003906:	e4a080e7          	jalr	-438(ra) # 8000474c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000390a:	08848493          	addi	s1,s1,136
    8000390e:	ff3498e3          	bne	s1,s3,800038fe <iinit+0x3e>
}
    80003912:	70a2                	ld	ra,40(sp)
    80003914:	7402                	ld	s0,32(sp)
    80003916:	64e2                	ld	s1,24(sp)
    80003918:	6942                	ld	s2,16(sp)
    8000391a:	69a2                	ld	s3,8(sp)
    8000391c:	6145                	addi	sp,sp,48
    8000391e:	8082                	ret

0000000080003920 <ialloc>:
{
    80003920:	715d                	addi	sp,sp,-80
    80003922:	e486                	sd	ra,72(sp)
    80003924:	e0a2                	sd	s0,64(sp)
    80003926:	fc26                	sd	s1,56(sp)
    80003928:	f84a                	sd	s2,48(sp)
    8000392a:	f44e                	sd	s3,40(sp)
    8000392c:	f052                	sd	s4,32(sp)
    8000392e:	ec56                	sd	s5,24(sp)
    80003930:	e85a                	sd	s6,16(sp)
    80003932:	e45e                	sd	s7,8(sp)
    80003934:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003936:	0001c717          	auipc	a4,0x1c
    8000393a:	67e72703          	lw	a4,1662(a4) # 8001ffb4 <sb+0xc>
    8000393e:	4785                	li	a5,1
    80003940:	04e7fa63          	bgeu	a5,a4,80003994 <ialloc+0x74>
    80003944:	8aaa                	mv	s5,a0
    80003946:	8bae                	mv	s7,a1
    80003948:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000394a:	0001ca17          	auipc	s4,0x1c
    8000394e:	65ea0a13          	addi	s4,s4,1630 # 8001ffa8 <sb>
    80003952:	00048b1b          	sext.w	s6,s1
    80003956:	0044d793          	srli	a5,s1,0x4
    8000395a:	018a2583          	lw	a1,24(s4)
    8000395e:	9dbd                	addw	a1,a1,a5
    80003960:	8556                	mv	a0,s5
    80003962:	00000097          	auipc	ra,0x0
    80003966:	952080e7          	jalr	-1710(ra) # 800032b4 <bread>
    8000396a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000396c:	05850993          	addi	s3,a0,88
    80003970:	00f4f793          	andi	a5,s1,15
    80003974:	079a                	slli	a5,a5,0x6
    80003976:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003978:	00099783          	lh	a5,0(s3)
    8000397c:	c785                	beqz	a5,800039a4 <ialloc+0x84>
    brelse(bp);
    8000397e:	00000097          	auipc	ra,0x0
    80003982:	a66080e7          	jalr	-1434(ra) # 800033e4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003986:	0485                	addi	s1,s1,1
    80003988:	00ca2703          	lw	a4,12(s4)
    8000398c:	0004879b          	sext.w	a5,s1
    80003990:	fce7e1e3          	bltu	a5,a4,80003952 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003994:	00005517          	auipc	a0,0x5
    80003998:	d4450513          	addi	a0,a0,-700 # 800086d8 <syscalls+0x180>
    8000399c:	ffffd097          	auipc	ra,0xffffd
    800039a0:	b8e080e7          	jalr	-1138(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    800039a4:	04000613          	li	a2,64
    800039a8:	4581                	li	a1,0
    800039aa:	854e                	mv	a0,s3
    800039ac:	ffffd097          	auipc	ra,0xffffd
    800039b0:	312080e7          	jalr	786(ra) # 80000cbe <memset>
      dip->type = type;
    800039b4:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800039b8:	854a                	mv	a0,s2
    800039ba:	00001097          	auipc	ra,0x1
    800039be:	cac080e7          	jalr	-852(ra) # 80004666 <log_write>
      brelse(bp);
    800039c2:	854a                	mv	a0,s2
    800039c4:	00000097          	auipc	ra,0x0
    800039c8:	a20080e7          	jalr	-1504(ra) # 800033e4 <brelse>
      return iget(dev, inum);
    800039cc:	85da                	mv	a1,s6
    800039ce:	8556                	mv	a0,s5
    800039d0:	00000097          	auipc	ra,0x0
    800039d4:	db4080e7          	jalr	-588(ra) # 80003784 <iget>
}
    800039d8:	60a6                	ld	ra,72(sp)
    800039da:	6406                	ld	s0,64(sp)
    800039dc:	74e2                	ld	s1,56(sp)
    800039de:	7942                	ld	s2,48(sp)
    800039e0:	79a2                	ld	s3,40(sp)
    800039e2:	7a02                	ld	s4,32(sp)
    800039e4:	6ae2                	ld	s5,24(sp)
    800039e6:	6b42                	ld	s6,16(sp)
    800039e8:	6ba2                	ld	s7,8(sp)
    800039ea:	6161                	addi	sp,sp,80
    800039ec:	8082                	ret

00000000800039ee <iupdate>:
{
    800039ee:	1101                	addi	sp,sp,-32
    800039f0:	ec06                	sd	ra,24(sp)
    800039f2:	e822                	sd	s0,16(sp)
    800039f4:	e426                	sd	s1,8(sp)
    800039f6:	e04a                	sd	s2,0(sp)
    800039f8:	1000                	addi	s0,sp,32
    800039fa:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039fc:	415c                	lw	a5,4(a0)
    800039fe:	0047d79b          	srliw	a5,a5,0x4
    80003a02:	0001c597          	auipc	a1,0x1c
    80003a06:	5be5a583          	lw	a1,1470(a1) # 8001ffc0 <sb+0x18>
    80003a0a:	9dbd                	addw	a1,a1,a5
    80003a0c:	4108                	lw	a0,0(a0)
    80003a0e:	00000097          	auipc	ra,0x0
    80003a12:	8a6080e7          	jalr	-1882(ra) # 800032b4 <bread>
    80003a16:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a18:	05850793          	addi	a5,a0,88
    80003a1c:	40c8                	lw	a0,4(s1)
    80003a1e:	893d                	andi	a0,a0,15
    80003a20:	051a                	slli	a0,a0,0x6
    80003a22:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003a24:	04449703          	lh	a4,68(s1)
    80003a28:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003a2c:	04649703          	lh	a4,70(s1)
    80003a30:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003a34:	04849703          	lh	a4,72(s1)
    80003a38:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003a3c:	04a49703          	lh	a4,74(s1)
    80003a40:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003a44:	44f8                	lw	a4,76(s1)
    80003a46:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003a48:	03400613          	li	a2,52
    80003a4c:	05048593          	addi	a1,s1,80
    80003a50:	0531                	addi	a0,a0,12
    80003a52:	ffffd097          	auipc	ra,0xffffd
    80003a56:	2c8080e7          	jalr	712(ra) # 80000d1a <memmove>
  log_write(bp);
    80003a5a:	854a                	mv	a0,s2
    80003a5c:	00001097          	auipc	ra,0x1
    80003a60:	c0a080e7          	jalr	-1014(ra) # 80004666 <log_write>
  brelse(bp);
    80003a64:	854a                	mv	a0,s2
    80003a66:	00000097          	auipc	ra,0x0
    80003a6a:	97e080e7          	jalr	-1666(ra) # 800033e4 <brelse>
}
    80003a6e:	60e2                	ld	ra,24(sp)
    80003a70:	6442                	ld	s0,16(sp)
    80003a72:	64a2                	ld	s1,8(sp)
    80003a74:	6902                	ld	s2,0(sp)
    80003a76:	6105                	addi	sp,sp,32
    80003a78:	8082                	ret

0000000080003a7a <idup>:
{
    80003a7a:	1101                	addi	sp,sp,-32
    80003a7c:	ec06                	sd	ra,24(sp)
    80003a7e:	e822                	sd	s0,16(sp)
    80003a80:	e426                	sd	s1,8(sp)
    80003a82:	1000                	addi	s0,sp,32
    80003a84:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a86:	0001c517          	auipc	a0,0x1c
    80003a8a:	54250513          	addi	a0,a0,1346 # 8001ffc8 <itable>
    80003a8e:	ffffd097          	auipc	ra,0xffffd
    80003a92:	134080e7          	jalr	308(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003a96:	449c                	lw	a5,8(s1)
    80003a98:	2785                	addiw	a5,a5,1
    80003a9a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a9c:	0001c517          	auipc	a0,0x1c
    80003aa0:	52c50513          	addi	a0,a0,1324 # 8001ffc8 <itable>
    80003aa4:	ffffd097          	auipc	ra,0xffffd
    80003aa8:	1d2080e7          	jalr	466(ra) # 80000c76 <release>
}
    80003aac:	8526                	mv	a0,s1
    80003aae:	60e2                	ld	ra,24(sp)
    80003ab0:	6442                	ld	s0,16(sp)
    80003ab2:	64a2                	ld	s1,8(sp)
    80003ab4:	6105                	addi	sp,sp,32
    80003ab6:	8082                	ret

0000000080003ab8 <ilock>:
{
    80003ab8:	1101                	addi	sp,sp,-32
    80003aba:	ec06                	sd	ra,24(sp)
    80003abc:	e822                	sd	s0,16(sp)
    80003abe:	e426                	sd	s1,8(sp)
    80003ac0:	e04a                	sd	s2,0(sp)
    80003ac2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ac4:	c115                	beqz	a0,80003ae8 <ilock+0x30>
    80003ac6:	84aa                	mv	s1,a0
    80003ac8:	451c                	lw	a5,8(a0)
    80003aca:	00f05f63          	blez	a5,80003ae8 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003ace:	0541                	addi	a0,a0,16
    80003ad0:	00001097          	auipc	ra,0x1
    80003ad4:	cb6080e7          	jalr	-842(ra) # 80004786 <acquiresleep>
  if(ip->valid == 0){
    80003ad8:	40bc                	lw	a5,64(s1)
    80003ada:	cf99                	beqz	a5,80003af8 <ilock+0x40>
}
    80003adc:	60e2                	ld	ra,24(sp)
    80003ade:	6442                	ld	s0,16(sp)
    80003ae0:	64a2                	ld	s1,8(sp)
    80003ae2:	6902                	ld	s2,0(sp)
    80003ae4:	6105                	addi	sp,sp,32
    80003ae6:	8082                	ret
    panic("ilock");
    80003ae8:	00005517          	auipc	a0,0x5
    80003aec:	c0850513          	addi	a0,a0,-1016 # 800086f0 <syscalls+0x198>
    80003af0:	ffffd097          	auipc	ra,0xffffd
    80003af4:	a3a080e7          	jalr	-1478(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003af8:	40dc                	lw	a5,4(s1)
    80003afa:	0047d79b          	srliw	a5,a5,0x4
    80003afe:	0001c597          	auipc	a1,0x1c
    80003b02:	4c25a583          	lw	a1,1218(a1) # 8001ffc0 <sb+0x18>
    80003b06:	9dbd                	addw	a1,a1,a5
    80003b08:	4088                	lw	a0,0(s1)
    80003b0a:	fffff097          	auipc	ra,0xfffff
    80003b0e:	7aa080e7          	jalr	1962(ra) # 800032b4 <bread>
    80003b12:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b14:	05850593          	addi	a1,a0,88
    80003b18:	40dc                	lw	a5,4(s1)
    80003b1a:	8bbd                	andi	a5,a5,15
    80003b1c:	079a                	slli	a5,a5,0x6
    80003b1e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b20:	00059783          	lh	a5,0(a1)
    80003b24:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b28:	00259783          	lh	a5,2(a1)
    80003b2c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003b30:	00459783          	lh	a5,4(a1)
    80003b34:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003b38:	00659783          	lh	a5,6(a1)
    80003b3c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003b40:	459c                	lw	a5,8(a1)
    80003b42:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b44:	03400613          	li	a2,52
    80003b48:	05b1                	addi	a1,a1,12
    80003b4a:	05048513          	addi	a0,s1,80
    80003b4e:	ffffd097          	auipc	ra,0xffffd
    80003b52:	1cc080e7          	jalr	460(ra) # 80000d1a <memmove>
    brelse(bp);
    80003b56:	854a                	mv	a0,s2
    80003b58:	00000097          	auipc	ra,0x0
    80003b5c:	88c080e7          	jalr	-1908(ra) # 800033e4 <brelse>
    ip->valid = 1;
    80003b60:	4785                	li	a5,1
    80003b62:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003b64:	04449783          	lh	a5,68(s1)
    80003b68:	fbb5                	bnez	a5,80003adc <ilock+0x24>
      panic("ilock: no type");
    80003b6a:	00005517          	auipc	a0,0x5
    80003b6e:	b8e50513          	addi	a0,a0,-1138 # 800086f8 <syscalls+0x1a0>
    80003b72:	ffffd097          	auipc	ra,0xffffd
    80003b76:	9b8080e7          	jalr	-1608(ra) # 8000052a <panic>

0000000080003b7a <iunlock>:
{
    80003b7a:	1101                	addi	sp,sp,-32
    80003b7c:	ec06                	sd	ra,24(sp)
    80003b7e:	e822                	sd	s0,16(sp)
    80003b80:	e426                	sd	s1,8(sp)
    80003b82:	e04a                	sd	s2,0(sp)
    80003b84:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003b86:	c905                	beqz	a0,80003bb6 <iunlock+0x3c>
    80003b88:	84aa                	mv	s1,a0
    80003b8a:	01050913          	addi	s2,a0,16
    80003b8e:	854a                	mv	a0,s2
    80003b90:	00001097          	auipc	ra,0x1
    80003b94:	c90080e7          	jalr	-880(ra) # 80004820 <holdingsleep>
    80003b98:	cd19                	beqz	a0,80003bb6 <iunlock+0x3c>
    80003b9a:	449c                	lw	a5,8(s1)
    80003b9c:	00f05d63          	blez	a5,80003bb6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ba0:	854a                	mv	a0,s2
    80003ba2:	00001097          	auipc	ra,0x1
    80003ba6:	c3a080e7          	jalr	-966(ra) # 800047dc <releasesleep>
}
    80003baa:	60e2                	ld	ra,24(sp)
    80003bac:	6442                	ld	s0,16(sp)
    80003bae:	64a2                	ld	s1,8(sp)
    80003bb0:	6902                	ld	s2,0(sp)
    80003bb2:	6105                	addi	sp,sp,32
    80003bb4:	8082                	ret
    panic("iunlock");
    80003bb6:	00005517          	auipc	a0,0x5
    80003bba:	b5250513          	addi	a0,a0,-1198 # 80008708 <syscalls+0x1b0>
    80003bbe:	ffffd097          	auipc	ra,0xffffd
    80003bc2:	96c080e7          	jalr	-1684(ra) # 8000052a <panic>

0000000080003bc6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003bc6:	7179                	addi	sp,sp,-48
    80003bc8:	f406                	sd	ra,40(sp)
    80003bca:	f022                	sd	s0,32(sp)
    80003bcc:	ec26                	sd	s1,24(sp)
    80003bce:	e84a                	sd	s2,16(sp)
    80003bd0:	e44e                	sd	s3,8(sp)
    80003bd2:	e052                	sd	s4,0(sp)
    80003bd4:	1800                	addi	s0,sp,48
    80003bd6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003bd8:	05050493          	addi	s1,a0,80
    80003bdc:	08050913          	addi	s2,a0,128
    80003be0:	a021                	j	80003be8 <itrunc+0x22>
    80003be2:	0491                	addi	s1,s1,4
    80003be4:	01248d63          	beq	s1,s2,80003bfe <itrunc+0x38>
    if(ip->addrs[i]){
    80003be8:	408c                	lw	a1,0(s1)
    80003bea:	dde5                	beqz	a1,80003be2 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003bec:	0009a503          	lw	a0,0(s3)
    80003bf0:	00000097          	auipc	ra,0x0
    80003bf4:	90a080e7          	jalr	-1782(ra) # 800034fa <bfree>
      ip->addrs[i] = 0;
    80003bf8:	0004a023          	sw	zero,0(s1)
    80003bfc:	b7dd                	j	80003be2 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003bfe:	0809a583          	lw	a1,128(s3)
    80003c02:	e185                	bnez	a1,80003c22 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c04:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c08:	854e                	mv	a0,s3
    80003c0a:	00000097          	auipc	ra,0x0
    80003c0e:	de4080e7          	jalr	-540(ra) # 800039ee <iupdate>
}
    80003c12:	70a2                	ld	ra,40(sp)
    80003c14:	7402                	ld	s0,32(sp)
    80003c16:	64e2                	ld	s1,24(sp)
    80003c18:	6942                	ld	s2,16(sp)
    80003c1a:	69a2                	ld	s3,8(sp)
    80003c1c:	6a02                	ld	s4,0(sp)
    80003c1e:	6145                	addi	sp,sp,48
    80003c20:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c22:	0009a503          	lw	a0,0(s3)
    80003c26:	fffff097          	auipc	ra,0xfffff
    80003c2a:	68e080e7          	jalr	1678(ra) # 800032b4 <bread>
    80003c2e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c30:	05850493          	addi	s1,a0,88
    80003c34:	45850913          	addi	s2,a0,1112
    80003c38:	a021                	j	80003c40 <itrunc+0x7a>
    80003c3a:	0491                	addi	s1,s1,4
    80003c3c:	01248b63          	beq	s1,s2,80003c52 <itrunc+0x8c>
      if(a[j])
    80003c40:	408c                	lw	a1,0(s1)
    80003c42:	dde5                	beqz	a1,80003c3a <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003c44:	0009a503          	lw	a0,0(s3)
    80003c48:	00000097          	auipc	ra,0x0
    80003c4c:	8b2080e7          	jalr	-1870(ra) # 800034fa <bfree>
    80003c50:	b7ed                	j	80003c3a <itrunc+0x74>
    brelse(bp);
    80003c52:	8552                	mv	a0,s4
    80003c54:	fffff097          	auipc	ra,0xfffff
    80003c58:	790080e7          	jalr	1936(ra) # 800033e4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c5c:	0809a583          	lw	a1,128(s3)
    80003c60:	0009a503          	lw	a0,0(s3)
    80003c64:	00000097          	auipc	ra,0x0
    80003c68:	896080e7          	jalr	-1898(ra) # 800034fa <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c6c:	0809a023          	sw	zero,128(s3)
    80003c70:	bf51                	j	80003c04 <itrunc+0x3e>

0000000080003c72 <iput>:
{
    80003c72:	1101                	addi	sp,sp,-32
    80003c74:	ec06                	sd	ra,24(sp)
    80003c76:	e822                	sd	s0,16(sp)
    80003c78:	e426                	sd	s1,8(sp)
    80003c7a:	e04a                	sd	s2,0(sp)
    80003c7c:	1000                	addi	s0,sp,32
    80003c7e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c80:	0001c517          	auipc	a0,0x1c
    80003c84:	34850513          	addi	a0,a0,840 # 8001ffc8 <itable>
    80003c88:	ffffd097          	auipc	ra,0xffffd
    80003c8c:	f3a080e7          	jalr	-198(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c90:	4498                	lw	a4,8(s1)
    80003c92:	4785                	li	a5,1
    80003c94:	02f70363          	beq	a4,a5,80003cba <iput+0x48>
  ip->ref--;
    80003c98:	449c                	lw	a5,8(s1)
    80003c9a:	37fd                	addiw	a5,a5,-1
    80003c9c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c9e:	0001c517          	auipc	a0,0x1c
    80003ca2:	32a50513          	addi	a0,a0,810 # 8001ffc8 <itable>
    80003ca6:	ffffd097          	auipc	ra,0xffffd
    80003caa:	fd0080e7          	jalr	-48(ra) # 80000c76 <release>
}
    80003cae:	60e2                	ld	ra,24(sp)
    80003cb0:	6442                	ld	s0,16(sp)
    80003cb2:	64a2                	ld	s1,8(sp)
    80003cb4:	6902                	ld	s2,0(sp)
    80003cb6:	6105                	addi	sp,sp,32
    80003cb8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cba:	40bc                	lw	a5,64(s1)
    80003cbc:	dff1                	beqz	a5,80003c98 <iput+0x26>
    80003cbe:	04a49783          	lh	a5,74(s1)
    80003cc2:	fbf9                	bnez	a5,80003c98 <iput+0x26>
    acquiresleep(&ip->lock);
    80003cc4:	01048913          	addi	s2,s1,16
    80003cc8:	854a                	mv	a0,s2
    80003cca:	00001097          	auipc	ra,0x1
    80003cce:	abc080e7          	jalr	-1348(ra) # 80004786 <acquiresleep>
    release(&itable.lock);
    80003cd2:	0001c517          	auipc	a0,0x1c
    80003cd6:	2f650513          	addi	a0,a0,758 # 8001ffc8 <itable>
    80003cda:	ffffd097          	auipc	ra,0xffffd
    80003cde:	f9c080e7          	jalr	-100(ra) # 80000c76 <release>
    itrunc(ip);
    80003ce2:	8526                	mv	a0,s1
    80003ce4:	00000097          	auipc	ra,0x0
    80003ce8:	ee2080e7          	jalr	-286(ra) # 80003bc6 <itrunc>
    ip->type = 0;
    80003cec:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003cf0:	8526                	mv	a0,s1
    80003cf2:	00000097          	auipc	ra,0x0
    80003cf6:	cfc080e7          	jalr	-772(ra) # 800039ee <iupdate>
    ip->valid = 0;
    80003cfa:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003cfe:	854a                	mv	a0,s2
    80003d00:	00001097          	auipc	ra,0x1
    80003d04:	adc080e7          	jalr	-1316(ra) # 800047dc <releasesleep>
    acquire(&itable.lock);
    80003d08:	0001c517          	auipc	a0,0x1c
    80003d0c:	2c050513          	addi	a0,a0,704 # 8001ffc8 <itable>
    80003d10:	ffffd097          	auipc	ra,0xffffd
    80003d14:	eb2080e7          	jalr	-334(ra) # 80000bc2 <acquire>
    80003d18:	b741                	j	80003c98 <iput+0x26>

0000000080003d1a <iunlockput>:
{
    80003d1a:	1101                	addi	sp,sp,-32
    80003d1c:	ec06                	sd	ra,24(sp)
    80003d1e:	e822                	sd	s0,16(sp)
    80003d20:	e426                	sd	s1,8(sp)
    80003d22:	1000                	addi	s0,sp,32
    80003d24:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d26:	00000097          	auipc	ra,0x0
    80003d2a:	e54080e7          	jalr	-428(ra) # 80003b7a <iunlock>
  iput(ip);
    80003d2e:	8526                	mv	a0,s1
    80003d30:	00000097          	auipc	ra,0x0
    80003d34:	f42080e7          	jalr	-190(ra) # 80003c72 <iput>
}
    80003d38:	60e2                	ld	ra,24(sp)
    80003d3a:	6442                	ld	s0,16(sp)
    80003d3c:	64a2                	ld	s1,8(sp)
    80003d3e:	6105                	addi	sp,sp,32
    80003d40:	8082                	ret

0000000080003d42 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d42:	1141                	addi	sp,sp,-16
    80003d44:	e422                	sd	s0,8(sp)
    80003d46:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d48:	411c                	lw	a5,0(a0)
    80003d4a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d4c:	415c                	lw	a5,4(a0)
    80003d4e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d50:	04451783          	lh	a5,68(a0)
    80003d54:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d58:	04a51783          	lh	a5,74(a0)
    80003d5c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d60:	04c56783          	lwu	a5,76(a0)
    80003d64:	e99c                	sd	a5,16(a1)
}
    80003d66:	6422                	ld	s0,8(sp)
    80003d68:	0141                	addi	sp,sp,16
    80003d6a:	8082                	ret

0000000080003d6c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d6c:	457c                	lw	a5,76(a0)
    80003d6e:	0ed7e963          	bltu	a5,a3,80003e60 <readi+0xf4>
{
    80003d72:	7159                	addi	sp,sp,-112
    80003d74:	f486                	sd	ra,104(sp)
    80003d76:	f0a2                	sd	s0,96(sp)
    80003d78:	eca6                	sd	s1,88(sp)
    80003d7a:	e8ca                	sd	s2,80(sp)
    80003d7c:	e4ce                	sd	s3,72(sp)
    80003d7e:	e0d2                	sd	s4,64(sp)
    80003d80:	fc56                	sd	s5,56(sp)
    80003d82:	f85a                	sd	s6,48(sp)
    80003d84:	f45e                	sd	s7,40(sp)
    80003d86:	f062                	sd	s8,32(sp)
    80003d88:	ec66                	sd	s9,24(sp)
    80003d8a:	e86a                	sd	s10,16(sp)
    80003d8c:	e46e                	sd	s11,8(sp)
    80003d8e:	1880                	addi	s0,sp,112
    80003d90:	8baa                	mv	s7,a0
    80003d92:	8c2e                	mv	s8,a1
    80003d94:	8ab2                	mv	s5,a2
    80003d96:	84b6                	mv	s1,a3
    80003d98:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d9a:	9f35                	addw	a4,a4,a3
    return 0;
    80003d9c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003d9e:	0ad76063          	bltu	a4,a3,80003e3e <readi+0xd2>
  if(off + n > ip->size)
    80003da2:	00e7f463          	bgeu	a5,a4,80003daa <readi+0x3e>
    n = ip->size - off;
    80003da6:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003daa:	0a0b0963          	beqz	s6,80003e5c <readi+0xf0>
    80003dae:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003db0:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003db4:	5cfd                	li	s9,-1
    80003db6:	a82d                	j	80003df0 <readi+0x84>
    80003db8:	020a1d93          	slli	s11,s4,0x20
    80003dbc:	020ddd93          	srli	s11,s11,0x20
    80003dc0:	05890793          	addi	a5,s2,88
    80003dc4:	86ee                	mv	a3,s11
    80003dc6:	963e                	add	a2,a2,a5
    80003dc8:	85d6                	mv	a1,s5
    80003dca:	8562                	mv	a0,s8
    80003dcc:	fffff097          	auipc	ra,0xfffff
    80003dd0:	9a2080e7          	jalr	-1630(ra) # 8000276e <either_copyout>
    80003dd4:	05950d63          	beq	a0,s9,80003e2e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003dd8:	854a                	mv	a0,s2
    80003dda:	fffff097          	auipc	ra,0xfffff
    80003dde:	60a080e7          	jalr	1546(ra) # 800033e4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003de2:	013a09bb          	addw	s3,s4,s3
    80003de6:	009a04bb          	addw	s1,s4,s1
    80003dea:	9aee                	add	s5,s5,s11
    80003dec:	0569f763          	bgeu	s3,s6,80003e3a <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003df0:	000ba903          	lw	s2,0(s7)
    80003df4:	00a4d59b          	srliw	a1,s1,0xa
    80003df8:	855e                	mv	a0,s7
    80003dfa:	00000097          	auipc	ra,0x0
    80003dfe:	8ae080e7          	jalr	-1874(ra) # 800036a8 <bmap>
    80003e02:	0005059b          	sext.w	a1,a0
    80003e06:	854a                	mv	a0,s2
    80003e08:	fffff097          	auipc	ra,0xfffff
    80003e0c:	4ac080e7          	jalr	1196(ra) # 800032b4 <bread>
    80003e10:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e12:	3ff4f613          	andi	a2,s1,1023
    80003e16:	40cd07bb          	subw	a5,s10,a2
    80003e1a:	413b073b          	subw	a4,s6,s3
    80003e1e:	8a3e                	mv	s4,a5
    80003e20:	2781                	sext.w	a5,a5
    80003e22:	0007069b          	sext.w	a3,a4
    80003e26:	f8f6f9e3          	bgeu	a3,a5,80003db8 <readi+0x4c>
    80003e2a:	8a3a                	mv	s4,a4
    80003e2c:	b771                	j	80003db8 <readi+0x4c>
      brelse(bp);
    80003e2e:	854a                	mv	a0,s2
    80003e30:	fffff097          	auipc	ra,0xfffff
    80003e34:	5b4080e7          	jalr	1460(ra) # 800033e4 <brelse>
      tot = -1;
    80003e38:	59fd                	li	s3,-1
  }
  return tot;
    80003e3a:	0009851b          	sext.w	a0,s3
}
    80003e3e:	70a6                	ld	ra,104(sp)
    80003e40:	7406                	ld	s0,96(sp)
    80003e42:	64e6                	ld	s1,88(sp)
    80003e44:	6946                	ld	s2,80(sp)
    80003e46:	69a6                	ld	s3,72(sp)
    80003e48:	6a06                	ld	s4,64(sp)
    80003e4a:	7ae2                	ld	s5,56(sp)
    80003e4c:	7b42                	ld	s6,48(sp)
    80003e4e:	7ba2                	ld	s7,40(sp)
    80003e50:	7c02                	ld	s8,32(sp)
    80003e52:	6ce2                	ld	s9,24(sp)
    80003e54:	6d42                	ld	s10,16(sp)
    80003e56:	6da2                	ld	s11,8(sp)
    80003e58:	6165                	addi	sp,sp,112
    80003e5a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e5c:	89da                	mv	s3,s6
    80003e5e:	bff1                	j	80003e3a <readi+0xce>
    return 0;
    80003e60:	4501                	li	a0,0
}
    80003e62:	8082                	ret

0000000080003e64 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e64:	457c                	lw	a5,76(a0)
    80003e66:	10d7e863          	bltu	a5,a3,80003f76 <writei+0x112>
{
    80003e6a:	7159                	addi	sp,sp,-112
    80003e6c:	f486                	sd	ra,104(sp)
    80003e6e:	f0a2                	sd	s0,96(sp)
    80003e70:	eca6                	sd	s1,88(sp)
    80003e72:	e8ca                	sd	s2,80(sp)
    80003e74:	e4ce                	sd	s3,72(sp)
    80003e76:	e0d2                	sd	s4,64(sp)
    80003e78:	fc56                	sd	s5,56(sp)
    80003e7a:	f85a                	sd	s6,48(sp)
    80003e7c:	f45e                	sd	s7,40(sp)
    80003e7e:	f062                	sd	s8,32(sp)
    80003e80:	ec66                	sd	s9,24(sp)
    80003e82:	e86a                	sd	s10,16(sp)
    80003e84:	e46e                	sd	s11,8(sp)
    80003e86:	1880                	addi	s0,sp,112
    80003e88:	8b2a                	mv	s6,a0
    80003e8a:	8c2e                	mv	s8,a1
    80003e8c:	8ab2                	mv	s5,a2
    80003e8e:	8936                	mv	s2,a3
    80003e90:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003e92:	00e687bb          	addw	a5,a3,a4
    80003e96:	0ed7e263          	bltu	a5,a3,80003f7a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003e9a:	00043737          	lui	a4,0x43
    80003e9e:	0ef76063          	bltu	a4,a5,80003f7e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ea2:	0c0b8863          	beqz	s7,80003f72 <writei+0x10e>
    80003ea6:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ea8:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003eac:	5cfd                	li	s9,-1
    80003eae:	a091                	j	80003ef2 <writei+0x8e>
    80003eb0:	02099d93          	slli	s11,s3,0x20
    80003eb4:	020ddd93          	srli	s11,s11,0x20
    80003eb8:	05848793          	addi	a5,s1,88
    80003ebc:	86ee                	mv	a3,s11
    80003ebe:	8656                	mv	a2,s5
    80003ec0:	85e2                	mv	a1,s8
    80003ec2:	953e                	add	a0,a0,a5
    80003ec4:	fffff097          	auipc	ra,0xfffff
    80003ec8:	900080e7          	jalr	-1792(ra) # 800027c4 <either_copyin>
    80003ecc:	07950263          	beq	a0,s9,80003f30 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ed0:	8526                	mv	a0,s1
    80003ed2:	00000097          	auipc	ra,0x0
    80003ed6:	794080e7          	jalr	1940(ra) # 80004666 <log_write>
    brelse(bp);
    80003eda:	8526                	mv	a0,s1
    80003edc:	fffff097          	auipc	ra,0xfffff
    80003ee0:	508080e7          	jalr	1288(ra) # 800033e4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ee4:	01498a3b          	addw	s4,s3,s4
    80003ee8:	0129893b          	addw	s2,s3,s2
    80003eec:	9aee                	add	s5,s5,s11
    80003eee:	057a7663          	bgeu	s4,s7,80003f3a <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ef2:	000b2483          	lw	s1,0(s6)
    80003ef6:	00a9559b          	srliw	a1,s2,0xa
    80003efa:	855a                	mv	a0,s6
    80003efc:	fffff097          	auipc	ra,0xfffff
    80003f00:	7ac080e7          	jalr	1964(ra) # 800036a8 <bmap>
    80003f04:	0005059b          	sext.w	a1,a0
    80003f08:	8526                	mv	a0,s1
    80003f0a:	fffff097          	auipc	ra,0xfffff
    80003f0e:	3aa080e7          	jalr	938(ra) # 800032b4 <bread>
    80003f12:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f14:	3ff97513          	andi	a0,s2,1023
    80003f18:	40ad07bb          	subw	a5,s10,a0
    80003f1c:	414b873b          	subw	a4,s7,s4
    80003f20:	89be                	mv	s3,a5
    80003f22:	2781                	sext.w	a5,a5
    80003f24:	0007069b          	sext.w	a3,a4
    80003f28:	f8f6f4e3          	bgeu	a3,a5,80003eb0 <writei+0x4c>
    80003f2c:	89ba                	mv	s3,a4
    80003f2e:	b749                	j	80003eb0 <writei+0x4c>
      brelse(bp);
    80003f30:	8526                	mv	a0,s1
    80003f32:	fffff097          	auipc	ra,0xfffff
    80003f36:	4b2080e7          	jalr	1202(ra) # 800033e4 <brelse>
  }

  if(off > ip->size)
    80003f3a:	04cb2783          	lw	a5,76(s6)
    80003f3e:	0127f463          	bgeu	a5,s2,80003f46 <writei+0xe2>
    ip->size = off;
    80003f42:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003f46:	855a                	mv	a0,s6
    80003f48:	00000097          	auipc	ra,0x0
    80003f4c:	aa6080e7          	jalr	-1370(ra) # 800039ee <iupdate>

  return tot;
    80003f50:	000a051b          	sext.w	a0,s4
}
    80003f54:	70a6                	ld	ra,104(sp)
    80003f56:	7406                	ld	s0,96(sp)
    80003f58:	64e6                	ld	s1,88(sp)
    80003f5a:	6946                	ld	s2,80(sp)
    80003f5c:	69a6                	ld	s3,72(sp)
    80003f5e:	6a06                	ld	s4,64(sp)
    80003f60:	7ae2                	ld	s5,56(sp)
    80003f62:	7b42                	ld	s6,48(sp)
    80003f64:	7ba2                	ld	s7,40(sp)
    80003f66:	7c02                	ld	s8,32(sp)
    80003f68:	6ce2                	ld	s9,24(sp)
    80003f6a:	6d42                	ld	s10,16(sp)
    80003f6c:	6da2                	ld	s11,8(sp)
    80003f6e:	6165                	addi	sp,sp,112
    80003f70:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f72:	8a5e                	mv	s4,s7
    80003f74:	bfc9                	j	80003f46 <writei+0xe2>
    return -1;
    80003f76:	557d                	li	a0,-1
}
    80003f78:	8082                	ret
    return -1;
    80003f7a:	557d                	li	a0,-1
    80003f7c:	bfe1                	j	80003f54 <writei+0xf0>
    return -1;
    80003f7e:	557d                	li	a0,-1
    80003f80:	bfd1                	j	80003f54 <writei+0xf0>

0000000080003f82 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f82:	1141                	addi	sp,sp,-16
    80003f84:	e406                	sd	ra,8(sp)
    80003f86:	e022                	sd	s0,0(sp)
    80003f88:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003f8a:	4639                	li	a2,14
    80003f8c:	ffffd097          	auipc	ra,0xffffd
    80003f90:	e0a080e7          	jalr	-502(ra) # 80000d96 <strncmp>
}
    80003f94:	60a2                	ld	ra,8(sp)
    80003f96:	6402                	ld	s0,0(sp)
    80003f98:	0141                	addi	sp,sp,16
    80003f9a:	8082                	ret

0000000080003f9c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003f9c:	7139                	addi	sp,sp,-64
    80003f9e:	fc06                	sd	ra,56(sp)
    80003fa0:	f822                	sd	s0,48(sp)
    80003fa2:	f426                	sd	s1,40(sp)
    80003fa4:	f04a                	sd	s2,32(sp)
    80003fa6:	ec4e                	sd	s3,24(sp)
    80003fa8:	e852                	sd	s4,16(sp)
    80003faa:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003fac:	04451703          	lh	a4,68(a0)
    80003fb0:	4785                	li	a5,1
    80003fb2:	00f71a63          	bne	a4,a5,80003fc6 <dirlookup+0x2a>
    80003fb6:	892a                	mv	s2,a0
    80003fb8:	89ae                	mv	s3,a1
    80003fba:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fbc:	457c                	lw	a5,76(a0)
    80003fbe:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003fc0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fc2:	e79d                	bnez	a5,80003ff0 <dirlookup+0x54>
    80003fc4:	a8a5                	j	8000403c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003fc6:	00004517          	auipc	a0,0x4
    80003fca:	74a50513          	addi	a0,a0,1866 # 80008710 <syscalls+0x1b8>
    80003fce:	ffffc097          	auipc	ra,0xffffc
    80003fd2:	55c080e7          	jalr	1372(ra) # 8000052a <panic>
      panic("dirlookup read");
    80003fd6:	00004517          	auipc	a0,0x4
    80003fda:	75250513          	addi	a0,a0,1874 # 80008728 <syscalls+0x1d0>
    80003fde:	ffffc097          	auipc	ra,0xffffc
    80003fe2:	54c080e7          	jalr	1356(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fe6:	24c1                	addiw	s1,s1,16
    80003fe8:	04c92783          	lw	a5,76(s2)
    80003fec:	04f4f763          	bgeu	s1,a5,8000403a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ff0:	4741                	li	a4,16
    80003ff2:	86a6                	mv	a3,s1
    80003ff4:	fc040613          	addi	a2,s0,-64
    80003ff8:	4581                	li	a1,0
    80003ffa:	854a                	mv	a0,s2
    80003ffc:	00000097          	auipc	ra,0x0
    80004000:	d70080e7          	jalr	-656(ra) # 80003d6c <readi>
    80004004:	47c1                	li	a5,16
    80004006:	fcf518e3          	bne	a0,a5,80003fd6 <dirlookup+0x3a>
    if(de.inum == 0)
    8000400a:	fc045783          	lhu	a5,-64(s0)
    8000400e:	dfe1                	beqz	a5,80003fe6 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004010:	fc240593          	addi	a1,s0,-62
    80004014:	854e                	mv	a0,s3
    80004016:	00000097          	auipc	ra,0x0
    8000401a:	f6c080e7          	jalr	-148(ra) # 80003f82 <namecmp>
    8000401e:	f561                	bnez	a0,80003fe6 <dirlookup+0x4a>
      if(poff)
    80004020:	000a0463          	beqz	s4,80004028 <dirlookup+0x8c>
        *poff = off;
    80004024:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004028:	fc045583          	lhu	a1,-64(s0)
    8000402c:	00092503          	lw	a0,0(s2)
    80004030:	fffff097          	auipc	ra,0xfffff
    80004034:	754080e7          	jalr	1876(ra) # 80003784 <iget>
    80004038:	a011                	j	8000403c <dirlookup+0xa0>
  return 0;
    8000403a:	4501                	li	a0,0
}
    8000403c:	70e2                	ld	ra,56(sp)
    8000403e:	7442                	ld	s0,48(sp)
    80004040:	74a2                	ld	s1,40(sp)
    80004042:	7902                	ld	s2,32(sp)
    80004044:	69e2                	ld	s3,24(sp)
    80004046:	6a42                	ld	s4,16(sp)
    80004048:	6121                	addi	sp,sp,64
    8000404a:	8082                	ret

000000008000404c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000404c:	711d                	addi	sp,sp,-96
    8000404e:	ec86                	sd	ra,88(sp)
    80004050:	e8a2                	sd	s0,80(sp)
    80004052:	e4a6                	sd	s1,72(sp)
    80004054:	e0ca                	sd	s2,64(sp)
    80004056:	fc4e                	sd	s3,56(sp)
    80004058:	f852                	sd	s4,48(sp)
    8000405a:	f456                	sd	s5,40(sp)
    8000405c:	f05a                	sd	s6,32(sp)
    8000405e:	ec5e                	sd	s7,24(sp)
    80004060:	e862                	sd	s8,16(sp)
    80004062:	e466                	sd	s9,8(sp)
    80004064:	1080                	addi	s0,sp,96
    80004066:	84aa                	mv	s1,a0
    80004068:	8aae                	mv	s5,a1
    8000406a:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000406c:	00054703          	lbu	a4,0(a0)
    80004070:	02f00793          	li	a5,47
    80004074:	02f70363          	beq	a4,a5,8000409a <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004078:	ffffe097          	auipc	ra,0xffffe
    8000407c:	906080e7          	jalr	-1786(ra) # 8000197e <myproc>
    80004080:	15053503          	ld	a0,336(a0)
    80004084:	00000097          	auipc	ra,0x0
    80004088:	9f6080e7          	jalr	-1546(ra) # 80003a7a <idup>
    8000408c:	89aa                	mv	s3,a0
  while(*path == '/')
    8000408e:	02f00913          	li	s2,47
  len = path - s;
    80004092:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004094:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004096:	4b85                	li	s7,1
    80004098:	a865                	j	80004150 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000409a:	4585                	li	a1,1
    8000409c:	4505                	li	a0,1
    8000409e:	fffff097          	auipc	ra,0xfffff
    800040a2:	6e6080e7          	jalr	1766(ra) # 80003784 <iget>
    800040a6:	89aa                	mv	s3,a0
    800040a8:	b7dd                	j	8000408e <namex+0x42>
      iunlockput(ip);
    800040aa:	854e                	mv	a0,s3
    800040ac:	00000097          	auipc	ra,0x0
    800040b0:	c6e080e7          	jalr	-914(ra) # 80003d1a <iunlockput>
      return 0;
    800040b4:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800040b6:	854e                	mv	a0,s3
    800040b8:	60e6                	ld	ra,88(sp)
    800040ba:	6446                	ld	s0,80(sp)
    800040bc:	64a6                	ld	s1,72(sp)
    800040be:	6906                	ld	s2,64(sp)
    800040c0:	79e2                	ld	s3,56(sp)
    800040c2:	7a42                	ld	s4,48(sp)
    800040c4:	7aa2                	ld	s5,40(sp)
    800040c6:	7b02                	ld	s6,32(sp)
    800040c8:	6be2                	ld	s7,24(sp)
    800040ca:	6c42                	ld	s8,16(sp)
    800040cc:	6ca2                	ld	s9,8(sp)
    800040ce:	6125                	addi	sp,sp,96
    800040d0:	8082                	ret
      iunlock(ip);
    800040d2:	854e                	mv	a0,s3
    800040d4:	00000097          	auipc	ra,0x0
    800040d8:	aa6080e7          	jalr	-1370(ra) # 80003b7a <iunlock>
      return ip;
    800040dc:	bfe9                	j	800040b6 <namex+0x6a>
      iunlockput(ip);
    800040de:	854e                	mv	a0,s3
    800040e0:	00000097          	auipc	ra,0x0
    800040e4:	c3a080e7          	jalr	-966(ra) # 80003d1a <iunlockput>
      return 0;
    800040e8:	89e6                	mv	s3,s9
    800040ea:	b7f1                	j	800040b6 <namex+0x6a>
  len = path - s;
    800040ec:	40b48633          	sub	a2,s1,a1
    800040f0:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800040f4:	099c5463          	bge	s8,s9,8000417c <namex+0x130>
    memmove(name, s, DIRSIZ);
    800040f8:	4639                	li	a2,14
    800040fa:	8552                	mv	a0,s4
    800040fc:	ffffd097          	auipc	ra,0xffffd
    80004100:	c1e080e7          	jalr	-994(ra) # 80000d1a <memmove>
  while(*path == '/')
    80004104:	0004c783          	lbu	a5,0(s1)
    80004108:	01279763          	bne	a5,s2,80004116 <namex+0xca>
    path++;
    8000410c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000410e:	0004c783          	lbu	a5,0(s1)
    80004112:	ff278de3          	beq	a5,s2,8000410c <namex+0xc0>
    ilock(ip);
    80004116:	854e                	mv	a0,s3
    80004118:	00000097          	auipc	ra,0x0
    8000411c:	9a0080e7          	jalr	-1632(ra) # 80003ab8 <ilock>
    if(ip->type != T_DIR){
    80004120:	04499783          	lh	a5,68(s3)
    80004124:	f97793e3          	bne	a5,s7,800040aa <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004128:	000a8563          	beqz	s5,80004132 <namex+0xe6>
    8000412c:	0004c783          	lbu	a5,0(s1)
    80004130:	d3cd                	beqz	a5,800040d2 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004132:	865a                	mv	a2,s6
    80004134:	85d2                	mv	a1,s4
    80004136:	854e                	mv	a0,s3
    80004138:	00000097          	auipc	ra,0x0
    8000413c:	e64080e7          	jalr	-412(ra) # 80003f9c <dirlookup>
    80004140:	8caa                	mv	s9,a0
    80004142:	dd51                	beqz	a0,800040de <namex+0x92>
    iunlockput(ip);
    80004144:	854e                	mv	a0,s3
    80004146:	00000097          	auipc	ra,0x0
    8000414a:	bd4080e7          	jalr	-1068(ra) # 80003d1a <iunlockput>
    ip = next;
    8000414e:	89e6                	mv	s3,s9
  while(*path == '/')
    80004150:	0004c783          	lbu	a5,0(s1)
    80004154:	05279763          	bne	a5,s2,800041a2 <namex+0x156>
    path++;
    80004158:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000415a:	0004c783          	lbu	a5,0(s1)
    8000415e:	ff278de3          	beq	a5,s2,80004158 <namex+0x10c>
  if(*path == 0)
    80004162:	c79d                	beqz	a5,80004190 <namex+0x144>
    path++;
    80004164:	85a6                	mv	a1,s1
  len = path - s;
    80004166:	8cda                	mv	s9,s6
    80004168:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    8000416a:	01278963          	beq	a5,s2,8000417c <namex+0x130>
    8000416e:	dfbd                	beqz	a5,800040ec <namex+0xa0>
    path++;
    80004170:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004172:	0004c783          	lbu	a5,0(s1)
    80004176:	ff279ce3          	bne	a5,s2,8000416e <namex+0x122>
    8000417a:	bf8d                	j	800040ec <namex+0xa0>
    memmove(name, s, len);
    8000417c:	2601                	sext.w	a2,a2
    8000417e:	8552                	mv	a0,s4
    80004180:	ffffd097          	auipc	ra,0xffffd
    80004184:	b9a080e7          	jalr	-1126(ra) # 80000d1a <memmove>
    name[len] = 0;
    80004188:	9cd2                	add	s9,s9,s4
    8000418a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000418e:	bf9d                	j	80004104 <namex+0xb8>
  if(nameiparent){
    80004190:	f20a83e3          	beqz	s5,800040b6 <namex+0x6a>
    iput(ip);
    80004194:	854e                	mv	a0,s3
    80004196:	00000097          	auipc	ra,0x0
    8000419a:	adc080e7          	jalr	-1316(ra) # 80003c72 <iput>
    return 0;
    8000419e:	4981                	li	s3,0
    800041a0:	bf19                	j	800040b6 <namex+0x6a>
  if(*path == 0)
    800041a2:	d7fd                	beqz	a5,80004190 <namex+0x144>
  while(*path != '/' && *path != 0)
    800041a4:	0004c783          	lbu	a5,0(s1)
    800041a8:	85a6                	mv	a1,s1
    800041aa:	b7d1                	j	8000416e <namex+0x122>

00000000800041ac <dirlink>:
{
    800041ac:	7139                	addi	sp,sp,-64
    800041ae:	fc06                	sd	ra,56(sp)
    800041b0:	f822                	sd	s0,48(sp)
    800041b2:	f426                	sd	s1,40(sp)
    800041b4:	f04a                	sd	s2,32(sp)
    800041b6:	ec4e                	sd	s3,24(sp)
    800041b8:	e852                	sd	s4,16(sp)
    800041ba:	0080                	addi	s0,sp,64
    800041bc:	892a                	mv	s2,a0
    800041be:	8a2e                	mv	s4,a1
    800041c0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800041c2:	4601                	li	a2,0
    800041c4:	00000097          	auipc	ra,0x0
    800041c8:	dd8080e7          	jalr	-552(ra) # 80003f9c <dirlookup>
    800041cc:	e93d                	bnez	a0,80004242 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041ce:	04c92483          	lw	s1,76(s2)
    800041d2:	c49d                	beqz	s1,80004200 <dirlink+0x54>
    800041d4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041d6:	4741                	li	a4,16
    800041d8:	86a6                	mv	a3,s1
    800041da:	fc040613          	addi	a2,s0,-64
    800041de:	4581                	li	a1,0
    800041e0:	854a                	mv	a0,s2
    800041e2:	00000097          	auipc	ra,0x0
    800041e6:	b8a080e7          	jalr	-1142(ra) # 80003d6c <readi>
    800041ea:	47c1                	li	a5,16
    800041ec:	06f51163          	bne	a0,a5,8000424e <dirlink+0xa2>
    if(de.inum == 0)
    800041f0:	fc045783          	lhu	a5,-64(s0)
    800041f4:	c791                	beqz	a5,80004200 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041f6:	24c1                	addiw	s1,s1,16
    800041f8:	04c92783          	lw	a5,76(s2)
    800041fc:	fcf4ede3          	bltu	s1,a5,800041d6 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004200:	4639                	li	a2,14
    80004202:	85d2                	mv	a1,s4
    80004204:	fc240513          	addi	a0,s0,-62
    80004208:	ffffd097          	auipc	ra,0xffffd
    8000420c:	bca080e7          	jalr	-1078(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    80004210:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004214:	4741                	li	a4,16
    80004216:	86a6                	mv	a3,s1
    80004218:	fc040613          	addi	a2,s0,-64
    8000421c:	4581                	li	a1,0
    8000421e:	854a                	mv	a0,s2
    80004220:	00000097          	auipc	ra,0x0
    80004224:	c44080e7          	jalr	-956(ra) # 80003e64 <writei>
    80004228:	872a                	mv	a4,a0
    8000422a:	47c1                	li	a5,16
  return 0;
    8000422c:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000422e:	02f71863          	bne	a4,a5,8000425e <dirlink+0xb2>
}
    80004232:	70e2                	ld	ra,56(sp)
    80004234:	7442                	ld	s0,48(sp)
    80004236:	74a2                	ld	s1,40(sp)
    80004238:	7902                	ld	s2,32(sp)
    8000423a:	69e2                	ld	s3,24(sp)
    8000423c:	6a42                	ld	s4,16(sp)
    8000423e:	6121                	addi	sp,sp,64
    80004240:	8082                	ret
    iput(ip);
    80004242:	00000097          	auipc	ra,0x0
    80004246:	a30080e7          	jalr	-1488(ra) # 80003c72 <iput>
    return -1;
    8000424a:	557d                	li	a0,-1
    8000424c:	b7dd                	j	80004232 <dirlink+0x86>
      panic("dirlink read");
    8000424e:	00004517          	auipc	a0,0x4
    80004252:	4ea50513          	addi	a0,a0,1258 # 80008738 <syscalls+0x1e0>
    80004256:	ffffc097          	auipc	ra,0xffffc
    8000425a:	2d4080e7          	jalr	724(ra) # 8000052a <panic>
    panic("dirlink");
    8000425e:	00004517          	auipc	a0,0x4
    80004262:	5e250513          	addi	a0,a0,1506 # 80008840 <syscalls+0x2e8>
    80004266:	ffffc097          	auipc	ra,0xffffc
    8000426a:	2c4080e7          	jalr	708(ra) # 8000052a <panic>

000000008000426e <namei>:

struct inode*
namei(char *path)
{
    8000426e:	1101                	addi	sp,sp,-32
    80004270:	ec06                	sd	ra,24(sp)
    80004272:	e822                	sd	s0,16(sp)
    80004274:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004276:	fe040613          	addi	a2,s0,-32
    8000427a:	4581                	li	a1,0
    8000427c:	00000097          	auipc	ra,0x0
    80004280:	dd0080e7          	jalr	-560(ra) # 8000404c <namex>
}
    80004284:	60e2                	ld	ra,24(sp)
    80004286:	6442                	ld	s0,16(sp)
    80004288:	6105                	addi	sp,sp,32
    8000428a:	8082                	ret

000000008000428c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000428c:	1141                	addi	sp,sp,-16
    8000428e:	e406                	sd	ra,8(sp)
    80004290:	e022                	sd	s0,0(sp)
    80004292:	0800                	addi	s0,sp,16
    80004294:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004296:	4585                	li	a1,1
    80004298:	00000097          	auipc	ra,0x0
    8000429c:	db4080e7          	jalr	-588(ra) # 8000404c <namex>
}
    800042a0:	60a2                	ld	ra,8(sp)
    800042a2:	6402                	ld	s0,0(sp)
    800042a4:	0141                	addi	sp,sp,16
    800042a6:	8082                	ret

00000000800042a8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800042a8:	1101                	addi	sp,sp,-32
    800042aa:	ec06                	sd	ra,24(sp)
    800042ac:	e822                	sd	s0,16(sp)
    800042ae:	e426                	sd	s1,8(sp)
    800042b0:	e04a                	sd	s2,0(sp)
    800042b2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800042b4:	0001d917          	auipc	s2,0x1d
    800042b8:	7bc90913          	addi	s2,s2,1980 # 80021a70 <log>
    800042bc:	01892583          	lw	a1,24(s2)
    800042c0:	02892503          	lw	a0,40(s2)
    800042c4:	fffff097          	auipc	ra,0xfffff
    800042c8:	ff0080e7          	jalr	-16(ra) # 800032b4 <bread>
    800042cc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800042ce:	02c92683          	lw	a3,44(s2)
    800042d2:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800042d4:	02d05863          	blez	a3,80004304 <write_head+0x5c>
    800042d8:	0001d797          	auipc	a5,0x1d
    800042dc:	7c878793          	addi	a5,a5,1992 # 80021aa0 <log+0x30>
    800042e0:	05c50713          	addi	a4,a0,92
    800042e4:	36fd                	addiw	a3,a3,-1
    800042e6:	02069613          	slli	a2,a3,0x20
    800042ea:	01e65693          	srli	a3,a2,0x1e
    800042ee:	0001d617          	auipc	a2,0x1d
    800042f2:	7b660613          	addi	a2,a2,1974 # 80021aa4 <log+0x34>
    800042f6:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800042f8:	4390                	lw	a2,0(a5)
    800042fa:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042fc:	0791                	addi	a5,a5,4
    800042fe:	0711                	addi	a4,a4,4
    80004300:	fed79ce3          	bne	a5,a3,800042f8 <write_head+0x50>
  }
  bwrite(buf);
    80004304:	8526                	mv	a0,s1
    80004306:	fffff097          	auipc	ra,0xfffff
    8000430a:	0a0080e7          	jalr	160(ra) # 800033a6 <bwrite>
  brelse(buf);
    8000430e:	8526                	mv	a0,s1
    80004310:	fffff097          	auipc	ra,0xfffff
    80004314:	0d4080e7          	jalr	212(ra) # 800033e4 <brelse>
}
    80004318:	60e2                	ld	ra,24(sp)
    8000431a:	6442                	ld	s0,16(sp)
    8000431c:	64a2                	ld	s1,8(sp)
    8000431e:	6902                	ld	s2,0(sp)
    80004320:	6105                	addi	sp,sp,32
    80004322:	8082                	ret

0000000080004324 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004324:	0001d797          	auipc	a5,0x1d
    80004328:	7787a783          	lw	a5,1912(a5) # 80021a9c <log+0x2c>
    8000432c:	0af05d63          	blez	a5,800043e6 <install_trans+0xc2>
{
    80004330:	7139                	addi	sp,sp,-64
    80004332:	fc06                	sd	ra,56(sp)
    80004334:	f822                	sd	s0,48(sp)
    80004336:	f426                	sd	s1,40(sp)
    80004338:	f04a                	sd	s2,32(sp)
    8000433a:	ec4e                	sd	s3,24(sp)
    8000433c:	e852                	sd	s4,16(sp)
    8000433e:	e456                	sd	s5,8(sp)
    80004340:	e05a                	sd	s6,0(sp)
    80004342:	0080                	addi	s0,sp,64
    80004344:	8b2a                	mv	s6,a0
    80004346:	0001da97          	auipc	s5,0x1d
    8000434a:	75aa8a93          	addi	s5,s5,1882 # 80021aa0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000434e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004350:	0001d997          	auipc	s3,0x1d
    80004354:	72098993          	addi	s3,s3,1824 # 80021a70 <log>
    80004358:	a00d                	j	8000437a <install_trans+0x56>
    brelse(lbuf);
    8000435a:	854a                	mv	a0,s2
    8000435c:	fffff097          	auipc	ra,0xfffff
    80004360:	088080e7          	jalr	136(ra) # 800033e4 <brelse>
    brelse(dbuf);
    80004364:	8526                	mv	a0,s1
    80004366:	fffff097          	auipc	ra,0xfffff
    8000436a:	07e080e7          	jalr	126(ra) # 800033e4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000436e:	2a05                	addiw	s4,s4,1
    80004370:	0a91                	addi	s5,s5,4
    80004372:	02c9a783          	lw	a5,44(s3)
    80004376:	04fa5e63          	bge	s4,a5,800043d2 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000437a:	0189a583          	lw	a1,24(s3)
    8000437e:	014585bb          	addw	a1,a1,s4
    80004382:	2585                	addiw	a1,a1,1
    80004384:	0289a503          	lw	a0,40(s3)
    80004388:	fffff097          	auipc	ra,0xfffff
    8000438c:	f2c080e7          	jalr	-212(ra) # 800032b4 <bread>
    80004390:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004392:	000aa583          	lw	a1,0(s5)
    80004396:	0289a503          	lw	a0,40(s3)
    8000439a:	fffff097          	auipc	ra,0xfffff
    8000439e:	f1a080e7          	jalr	-230(ra) # 800032b4 <bread>
    800043a2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800043a4:	40000613          	li	a2,1024
    800043a8:	05890593          	addi	a1,s2,88
    800043ac:	05850513          	addi	a0,a0,88
    800043b0:	ffffd097          	auipc	ra,0xffffd
    800043b4:	96a080e7          	jalr	-1686(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    800043b8:	8526                	mv	a0,s1
    800043ba:	fffff097          	auipc	ra,0xfffff
    800043be:	fec080e7          	jalr	-20(ra) # 800033a6 <bwrite>
    if(recovering == 0)
    800043c2:	f80b1ce3          	bnez	s6,8000435a <install_trans+0x36>
      bunpin(dbuf);
    800043c6:	8526                	mv	a0,s1
    800043c8:	fffff097          	auipc	ra,0xfffff
    800043cc:	0f6080e7          	jalr	246(ra) # 800034be <bunpin>
    800043d0:	b769                	j	8000435a <install_trans+0x36>
}
    800043d2:	70e2                	ld	ra,56(sp)
    800043d4:	7442                	ld	s0,48(sp)
    800043d6:	74a2                	ld	s1,40(sp)
    800043d8:	7902                	ld	s2,32(sp)
    800043da:	69e2                	ld	s3,24(sp)
    800043dc:	6a42                	ld	s4,16(sp)
    800043de:	6aa2                	ld	s5,8(sp)
    800043e0:	6b02                	ld	s6,0(sp)
    800043e2:	6121                	addi	sp,sp,64
    800043e4:	8082                	ret
    800043e6:	8082                	ret

00000000800043e8 <initlog>:
{
    800043e8:	7179                	addi	sp,sp,-48
    800043ea:	f406                	sd	ra,40(sp)
    800043ec:	f022                	sd	s0,32(sp)
    800043ee:	ec26                	sd	s1,24(sp)
    800043f0:	e84a                	sd	s2,16(sp)
    800043f2:	e44e                	sd	s3,8(sp)
    800043f4:	1800                	addi	s0,sp,48
    800043f6:	892a                	mv	s2,a0
    800043f8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800043fa:	0001d497          	auipc	s1,0x1d
    800043fe:	67648493          	addi	s1,s1,1654 # 80021a70 <log>
    80004402:	00004597          	auipc	a1,0x4
    80004406:	34658593          	addi	a1,a1,838 # 80008748 <syscalls+0x1f0>
    8000440a:	8526                	mv	a0,s1
    8000440c:	ffffc097          	auipc	ra,0xffffc
    80004410:	726080e7          	jalr	1830(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004414:	0149a583          	lw	a1,20(s3)
    80004418:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000441a:	0109a783          	lw	a5,16(s3)
    8000441e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004420:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004424:	854a                	mv	a0,s2
    80004426:	fffff097          	auipc	ra,0xfffff
    8000442a:	e8e080e7          	jalr	-370(ra) # 800032b4 <bread>
  log.lh.n = lh->n;
    8000442e:	4d34                	lw	a3,88(a0)
    80004430:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004432:	02d05663          	blez	a3,8000445e <initlog+0x76>
    80004436:	05c50793          	addi	a5,a0,92
    8000443a:	0001d717          	auipc	a4,0x1d
    8000443e:	66670713          	addi	a4,a4,1638 # 80021aa0 <log+0x30>
    80004442:	36fd                	addiw	a3,a3,-1
    80004444:	02069613          	slli	a2,a3,0x20
    80004448:	01e65693          	srli	a3,a2,0x1e
    8000444c:	06050613          	addi	a2,a0,96
    80004450:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004452:	4390                	lw	a2,0(a5)
    80004454:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004456:	0791                	addi	a5,a5,4
    80004458:	0711                	addi	a4,a4,4
    8000445a:	fed79ce3          	bne	a5,a3,80004452 <initlog+0x6a>
  brelse(buf);
    8000445e:	fffff097          	auipc	ra,0xfffff
    80004462:	f86080e7          	jalr	-122(ra) # 800033e4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004466:	4505                	li	a0,1
    80004468:	00000097          	auipc	ra,0x0
    8000446c:	ebc080e7          	jalr	-324(ra) # 80004324 <install_trans>
  log.lh.n = 0;
    80004470:	0001d797          	auipc	a5,0x1d
    80004474:	6207a623          	sw	zero,1580(a5) # 80021a9c <log+0x2c>
  write_head(); // clear the log
    80004478:	00000097          	auipc	ra,0x0
    8000447c:	e30080e7          	jalr	-464(ra) # 800042a8 <write_head>
}
    80004480:	70a2                	ld	ra,40(sp)
    80004482:	7402                	ld	s0,32(sp)
    80004484:	64e2                	ld	s1,24(sp)
    80004486:	6942                	ld	s2,16(sp)
    80004488:	69a2                	ld	s3,8(sp)
    8000448a:	6145                	addi	sp,sp,48
    8000448c:	8082                	ret

000000008000448e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000448e:	1101                	addi	sp,sp,-32
    80004490:	ec06                	sd	ra,24(sp)
    80004492:	e822                	sd	s0,16(sp)
    80004494:	e426                	sd	s1,8(sp)
    80004496:	e04a                	sd	s2,0(sp)
    80004498:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000449a:	0001d517          	auipc	a0,0x1d
    8000449e:	5d650513          	addi	a0,a0,1494 # 80021a70 <log>
    800044a2:	ffffc097          	auipc	ra,0xffffc
    800044a6:	720080e7          	jalr	1824(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    800044aa:	0001d497          	auipc	s1,0x1d
    800044ae:	5c648493          	addi	s1,s1,1478 # 80021a70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044b2:	4979                	li	s2,30
    800044b4:	a039                	j	800044c2 <begin_op+0x34>
      sleep(&log, &log.lock);
    800044b6:	85a6                	mv	a1,s1
    800044b8:	8526                	mv	a0,s1
    800044ba:	ffffe097          	auipc	ra,0xffffe
    800044be:	d26080e7          	jalr	-730(ra) # 800021e0 <sleep>
    if(log.committing){
    800044c2:	50dc                	lw	a5,36(s1)
    800044c4:	fbed                	bnez	a5,800044b6 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044c6:	509c                	lw	a5,32(s1)
    800044c8:	0017871b          	addiw	a4,a5,1
    800044cc:	0007069b          	sext.w	a3,a4
    800044d0:	0027179b          	slliw	a5,a4,0x2
    800044d4:	9fb9                	addw	a5,a5,a4
    800044d6:	0017979b          	slliw	a5,a5,0x1
    800044da:	54d8                	lw	a4,44(s1)
    800044dc:	9fb9                	addw	a5,a5,a4
    800044de:	00f95963          	bge	s2,a5,800044f0 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800044e2:	85a6                	mv	a1,s1
    800044e4:	8526                	mv	a0,s1
    800044e6:	ffffe097          	auipc	ra,0xffffe
    800044ea:	cfa080e7          	jalr	-774(ra) # 800021e0 <sleep>
    800044ee:	bfd1                	j	800044c2 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800044f0:	0001d517          	auipc	a0,0x1d
    800044f4:	58050513          	addi	a0,a0,1408 # 80021a70 <log>
    800044f8:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800044fa:	ffffc097          	auipc	ra,0xffffc
    800044fe:	77c080e7          	jalr	1916(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004502:	60e2                	ld	ra,24(sp)
    80004504:	6442                	ld	s0,16(sp)
    80004506:	64a2                	ld	s1,8(sp)
    80004508:	6902                	ld	s2,0(sp)
    8000450a:	6105                	addi	sp,sp,32
    8000450c:	8082                	ret

000000008000450e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000450e:	7139                	addi	sp,sp,-64
    80004510:	fc06                	sd	ra,56(sp)
    80004512:	f822                	sd	s0,48(sp)
    80004514:	f426                	sd	s1,40(sp)
    80004516:	f04a                	sd	s2,32(sp)
    80004518:	ec4e                	sd	s3,24(sp)
    8000451a:	e852                	sd	s4,16(sp)
    8000451c:	e456                	sd	s5,8(sp)
    8000451e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004520:	0001d497          	auipc	s1,0x1d
    80004524:	55048493          	addi	s1,s1,1360 # 80021a70 <log>
    80004528:	8526                	mv	a0,s1
    8000452a:	ffffc097          	auipc	ra,0xffffc
    8000452e:	698080e7          	jalr	1688(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004532:	509c                	lw	a5,32(s1)
    80004534:	37fd                	addiw	a5,a5,-1
    80004536:	0007891b          	sext.w	s2,a5
    8000453a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000453c:	50dc                	lw	a5,36(s1)
    8000453e:	e7b9                	bnez	a5,8000458c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004540:	04091e63          	bnez	s2,8000459c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004544:	0001d497          	auipc	s1,0x1d
    80004548:	52c48493          	addi	s1,s1,1324 # 80021a70 <log>
    8000454c:	4785                	li	a5,1
    8000454e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004550:	8526                	mv	a0,s1
    80004552:	ffffc097          	auipc	ra,0xffffc
    80004556:	724080e7          	jalr	1828(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000455a:	54dc                	lw	a5,44(s1)
    8000455c:	06f04763          	bgtz	a5,800045ca <end_op+0xbc>
    acquire(&log.lock);
    80004560:	0001d497          	auipc	s1,0x1d
    80004564:	51048493          	addi	s1,s1,1296 # 80021a70 <log>
    80004568:	8526                	mv	a0,s1
    8000456a:	ffffc097          	auipc	ra,0xffffc
    8000456e:	658080e7          	jalr	1624(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004572:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004576:	8526                	mv	a0,s1
    80004578:	ffffe097          	auipc	ra,0xffffe
    8000457c:	fa6080e7          	jalr	-90(ra) # 8000251e <wakeup>
    release(&log.lock);
    80004580:	8526                	mv	a0,s1
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	6f4080e7          	jalr	1780(ra) # 80000c76 <release>
}
    8000458a:	a03d                	j	800045b8 <end_op+0xaa>
    panic("log.committing");
    8000458c:	00004517          	auipc	a0,0x4
    80004590:	1c450513          	addi	a0,a0,452 # 80008750 <syscalls+0x1f8>
    80004594:	ffffc097          	auipc	ra,0xffffc
    80004598:	f96080e7          	jalr	-106(ra) # 8000052a <panic>
    wakeup(&log);
    8000459c:	0001d497          	auipc	s1,0x1d
    800045a0:	4d448493          	addi	s1,s1,1236 # 80021a70 <log>
    800045a4:	8526                	mv	a0,s1
    800045a6:	ffffe097          	auipc	ra,0xffffe
    800045aa:	f78080e7          	jalr	-136(ra) # 8000251e <wakeup>
  release(&log.lock);
    800045ae:	8526                	mv	a0,s1
    800045b0:	ffffc097          	auipc	ra,0xffffc
    800045b4:	6c6080e7          	jalr	1734(ra) # 80000c76 <release>
}
    800045b8:	70e2                	ld	ra,56(sp)
    800045ba:	7442                	ld	s0,48(sp)
    800045bc:	74a2                	ld	s1,40(sp)
    800045be:	7902                	ld	s2,32(sp)
    800045c0:	69e2                	ld	s3,24(sp)
    800045c2:	6a42                	ld	s4,16(sp)
    800045c4:	6aa2                	ld	s5,8(sp)
    800045c6:	6121                	addi	sp,sp,64
    800045c8:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800045ca:	0001da97          	auipc	s5,0x1d
    800045ce:	4d6a8a93          	addi	s5,s5,1238 # 80021aa0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800045d2:	0001da17          	auipc	s4,0x1d
    800045d6:	49ea0a13          	addi	s4,s4,1182 # 80021a70 <log>
    800045da:	018a2583          	lw	a1,24(s4)
    800045de:	012585bb          	addw	a1,a1,s2
    800045e2:	2585                	addiw	a1,a1,1
    800045e4:	028a2503          	lw	a0,40(s4)
    800045e8:	fffff097          	auipc	ra,0xfffff
    800045ec:	ccc080e7          	jalr	-820(ra) # 800032b4 <bread>
    800045f0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800045f2:	000aa583          	lw	a1,0(s5)
    800045f6:	028a2503          	lw	a0,40(s4)
    800045fa:	fffff097          	auipc	ra,0xfffff
    800045fe:	cba080e7          	jalr	-838(ra) # 800032b4 <bread>
    80004602:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004604:	40000613          	li	a2,1024
    80004608:	05850593          	addi	a1,a0,88
    8000460c:	05848513          	addi	a0,s1,88
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	70a080e7          	jalr	1802(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004618:	8526                	mv	a0,s1
    8000461a:	fffff097          	auipc	ra,0xfffff
    8000461e:	d8c080e7          	jalr	-628(ra) # 800033a6 <bwrite>
    brelse(from);
    80004622:	854e                	mv	a0,s3
    80004624:	fffff097          	auipc	ra,0xfffff
    80004628:	dc0080e7          	jalr	-576(ra) # 800033e4 <brelse>
    brelse(to);
    8000462c:	8526                	mv	a0,s1
    8000462e:	fffff097          	auipc	ra,0xfffff
    80004632:	db6080e7          	jalr	-586(ra) # 800033e4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004636:	2905                	addiw	s2,s2,1
    80004638:	0a91                	addi	s5,s5,4
    8000463a:	02ca2783          	lw	a5,44(s4)
    8000463e:	f8f94ee3          	blt	s2,a5,800045da <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004642:	00000097          	auipc	ra,0x0
    80004646:	c66080e7          	jalr	-922(ra) # 800042a8 <write_head>
    install_trans(0); // Now install writes to home locations
    8000464a:	4501                	li	a0,0
    8000464c:	00000097          	auipc	ra,0x0
    80004650:	cd8080e7          	jalr	-808(ra) # 80004324 <install_trans>
    log.lh.n = 0;
    80004654:	0001d797          	auipc	a5,0x1d
    80004658:	4407a423          	sw	zero,1096(a5) # 80021a9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000465c:	00000097          	auipc	ra,0x0
    80004660:	c4c080e7          	jalr	-948(ra) # 800042a8 <write_head>
    80004664:	bdf5                	j	80004560 <end_op+0x52>

0000000080004666 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004666:	1101                	addi	sp,sp,-32
    80004668:	ec06                	sd	ra,24(sp)
    8000466a:	e822                	sd	s0,16(sp)
    8000466c:	e426                	sd	s1,8(sp)
    8000466e:	e04a                	sd	s2,0(sp)
    80004670:	1000                	addi	s0,sp,32
    80004672:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004674:	0001d917          	auipc	s2,0x1d
    80004678:	3fc90913          	addi	s2,s2,1020 # 80021a70 <log>
    8000467c:	854a                	mv	a0,s2
    8000467e:	ffffc097          	auipc	ra,0xffffc
    80004682:	544080e7          	jalr	1348(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004686:	02c92603          	lw	a2,44(s2)
    8000468a:	47f5                	li	a5,29
    8000468c:	06c7c563          	blt	a5,a2,800046f6 <log_write+0x90>
    80004690:	0001d797          	auipc	a5,0x1d
    80004694:	3fc7a783          	lw	a5,1020(a5) # 80021a8c <log+0x1c>
    80004698:	37fd                	addiw	a5,a5,-1
    8000469a:	04f65e63          	bge	a2,a5,800046f6 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000469e:	0001d797          	auipc	a5,0x1d
    800046a2:	3f27a783          	lw	a5,1010(a5) # 80021a90 <log+0x20>
    800046a6:	06f05063          	blez	a5,80004706 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800046aa:	4781                	li	a5,0
    800046ac:	06c05563          	blez	a2,80004716 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800046b0:	44cc                	lw	a1,12(s1)
    800046b2:	0001d717          	auipc	a4,0x1d
    800046b6:	3ee70713          	addi	a4,a4,1006 # 80021aa0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800046ba:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800046bc:	4314                	lw	a3,0(a4)
    800046be:	04b68c63          	beq	a3,a1,80004716 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800046c2:	2785                	addiw	a5,a5,1
    800046c4:	0711                	addi	a4,a4,4
    800046c6:	fef61be3          	bne	a2,a5,800046bc <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800046ca:	0621                	addi	a2,a2,8
    800046cc:	060a                	slli	a2,a2,0x2
    800046ce:	0001d797          	auipc	a5,0x1d
    800046d2:	3a278793          	addi	a5,a5,930 # 80021a70 <log>
    800046d6:	963e                	add	a2,a2,a5
    800046d8:	44dc                	lw	a5,12(s1)
    800046da:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800046dc:	8526                	mv	a0,s1
    800046de:	fffff097          	auipc	ra,0xfffff
    800046e2:	da4080e7          	jalr	-604(ra) # 80003482 <bpin>
    log.lh.n++;
    800046e6:	0001d717          	auipc	a4,0x1d
    800046ea:	38a70713          	addi	a4,a4,906 # 80021a70 <log>
    800046ee:	575c                	lw	a5,44(a4)
    800046f0:	2785                	addiw	a5,a5,1
    800046f2:	d75c                	sw	a5,44(a4)
    800046f4:	a835                	j	80004730 <log_write+0xca>
    panic("too big a transaction");
    800046f6:	00004517          	auipc	a0,0x4
    800046fa:	06a50513          	addi	a0,a0,106 # 80008760 <syscalls+0x208>
    800046fe:	ffffc097          	auipc	ra,0xffffc
    80004702:	e2c080e7          	jalr	-468(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004706:	00004517          	auipc	a0,0x4
    8000470a:	07250513          	addi	a0,a0,114 # 80008778 <syscalls+0x220>
    8000470e:	ffffc097          	auipc	ra,0xffffc
    80004712:	e1c080e7          	jalr	-484(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004716:	00878713          	addi	a4,a5,8
    8000471a:	00271693          	slli	a3,a4,0x2
    8000471e:	0001d717          	auipc	a4,0x1d
    80004722:	35270713          	addi	a4,a4,850 # 80021a70 <log>
    80004726:	9736                	add	a4,a4,a3
    80004728:	44d4                	lw	a3,12(s1)
    8000472a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000472c:	faf608e3          	beq	a2,a5,800046dc <log_write+0x76>
  }
  release(&log.lock);
    80004730:	0001d517          	auipc	a0,0x1d
    80004734:	34050513          	addi	a0,a0,832 # 80021a70 <log>
    80004738:	ffffc097          	auipc	ra,0xffffc
    8000473c:	53e080e7          	jalr	1342(ra) # 80000c76 <release>
}
    80004740:	60e2                	ld	ra,24(sp)
    80004742:	6442                	ld	s0,16(sp)
    80004744:	64a2                	ld	s1,8(sp)
    80004746:	6902                	ld	s2,0(sp)
    80004748:	6105                	addi	sp,sp,32
    8000474a:	8082                	ret

000000008000474c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000474c:	1101                	addi	sp,sp,-32
    8000474e:	ec06                	sd	ra,24(sp)
    80004750:	e822                	sd	s0,16(sp)
    80004752:	e426                	sd	s1,8(sp)
    80004754:	e04a                	sd	s2,0(sp)
    80004756:	1000                	addi	s0,sp,32
    80004758:	84aa                	mv	s1,a0
    8000475a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000475c:	00004597          	auipc	a1,0x4
    80004760:	03c58593          	addi	a1,a1,60 # 80008798 <syscalls+0x240>
    80004764:	0521                	addi	a0,a0,8
    80004766:	ffffc097          	auipc	ra,0xffffc
    8000476a:	3cc080e7          	jalr	972(ra) # 80000b32 <initlock>
  lk->name = name;
    8000476e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004772:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004776:	0204a423          	sw	zero,40(s1)
}
    8000477a:	60e2                	ld	ra,24(sp)
    8000477c:	6442                	ld	s0,16(sp)
    8000477e:	64a2                	ld	s1,8(sp)
    80004780:	6902                	ld	s2,0(sp)
    80004782:	6105                	addi	sp,sp,32
    80004784:	8082                	ret

0000000080004786 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004786:	1101                	addi	sp,sp,-32
    80004788:	ec06                	sd	ra,24(sp)
    8000478a:	e822                	sd	s0,16(sp)
    8000478c:	e426                	sd	s1,8(sp)
    8000478e:	e04a                	sd	s2,0(sp)
    80004790:	1000                	addi	s0,sp,32
    80004792:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004794:	00850913          	addi	s2,a0,8
    80004798:	854a                	mv	a0,s2
    8000479a:	ffffc097          	auipc	ra,0xffffc
    8000479e:	428080e7          	jalr	1064(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    800047a2:	409c                	lw	a5,0(s1)
    800047a4:	cb89                	beqz	a5,800047b6 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800047a6:	85ca                	mv	a1,s2
    800047a8:	8526                	mv	a0,s1
    800047aa:	ffffe097          	auipc	ra,0xffffe
    800047ae:	a36080e7          	jalr	-1482(ra) # 800021e0 <sleep>
  while (lk->locked) {
    800047b2:	409c                	lw	a5,0(s1)
    800047b4:	fbed                	bnez	a5,800047a6 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800047b6:	4785                	li	a5,1
    800047b8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047ba:	ffffd097          	auipc	ra,0xffffd
    800047be:	1c4080e7          	jalr	452(ra) # 8000197e <myproc>
    800047c2:	591c                	lw	a5,48(a0)
    800047c4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800047c6:	854a                	mv	a0,s2
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	4ae080e7          	jalr	1198(ra) # 80000c76 <release>
}
    800047d0:	60e2                	ld	ra,24(sp)
    800047d2:	6442                	ld	s0,16(sp)
    800047d4:	64a2                	ld	s1,8(sp)
    800047d6:	6902                	ld	s2,0(sp)
    800047d8:	6105                	addi	sp,sp,32
    800047da:	8082                	ret

00000000800047dc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800047dc:	1101                	addi	sp,sp,-32
    800047de:	ec06                	sd	ra,24(sp)
    800047e0:	e822                	sd	s0,16(sp)
    800047e2:	e426                	sd	s1,8(sp)
    800047e4:	e04a                	sd	s2,0(sp)
    800047e6:	1000                	addi	s0,sp,32
    800047e8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047ea:	00850913          	addi	s2,a0,8
    800047ee:	854a                	mv	a0,s2
    800047f0:	ffffc097          	auipc	ra,0xffffc
    800047f4:	3d2080e7          	jalr	978(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    800047f8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047fc:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004800:	8526                	mv	a0,s1
    80004802:	ffffe097          	auipc	ra,0xffffe
    80004806:	d1c080e7          	jalr	-740(ra) # 8000251e <wakeup>
  release(&lk->lk);
    8000480a:	854a                	mv	a0,s2
    8000480c:	ffffc097          	auipc	ra,0xffffc
    80004810:	46a080e7          	jalr	1130(ra) # 80000c76 <release>
}
    80004814:	60e2                	ld	ra,24(sp)
    80004816:	6442                	ld	s0,16(sp)
    80004818:	64a2                	ld	s1,8(sp)
    8000481a:	6902                	ld	s2,0(sp)
    8000481c:	6105                	addi	sp,sp,32
    8000481e:	8082                	ret

0000000080004820 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004820:	7179                	addi	sp,sp,-48
    80004822:	f406                	sd	ra,40(sp)
    80004824:	f022                	sd	s0,32(sp)
    80004826:	ec26                	sd	s1,24(sp)
    80004828:	e84a                	sd	s2,16(sp)
    8000482a:	e44e                	sd	s3,8(sp)
    8000482c:	1800                	addi	s0,sp,48
    8000482e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004830:	00850913          	addi	s2,a0,8
    80004834:	854a                	mv	a0,s2
    80004836:	ffffc097          	auipc	ra,0xffffc
    8000483a:	38c080e7          	jalr	908(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000483e:	409c                	lw	a5,0(s1)
    80004840:	ef99                	bnez	a5,8000485e <holdingsleep+0x3e>
    80004842:	4481                	li	s1,0
  release(&lk->lk);
    80004844:	854a                	mv	a0,s2
    80004846:	ffffc097          	auipc	ra,0xffffc
    8000484a:	430080e7          	jalr	1072(ra) # 80000c76 <release>
  return r;
}
    8000484e:	8526                	mv	a0,s1
    80004850:	70a2                	ld	ra,40(sp)
    80004852:	7402                	ld	s0,32(sp)
    80004854:	64e2                	ld	s1,24(sp)
    80004856:	6942                	ld	s2,16(sp)
    80004858:	69a2                	ld	s3,8(sp)
    8000485a:	6145                	addi	sp,sp,48
    8000485c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000485e:	0284a983          	lw	s3,40(s1)
    80004862:	ffffd097          	auipc	ra,0xffffd
    80004866:	11c080e7          	jalr	284(ra) # 8000197e <myproc>
    8000486a:	5904                	lw	s1,48(a0)
    8000486c:	413484b3          	sub	s1,s1,s3
    80004870:	0014b493          	seqz	s1,s1
    80004874:	bfc1                	j	80004844 <holdingsleep+0x24>

0000000080004876 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004876:	1141                	addi	sp,sp,-16
    80004878:	e406                	sd	ra,8(sp)
    8000487a:	e022                	sd	s0,0(sp)
    8000487c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000487e:	00004597          	auipc	a1,0x4
    80004882:	f2a58593          	addi	a1,a1,-214 # 800087a8 <syscalls+0x250>
    80004886:	0001d517          	auipc	a0,0x1d
    8000488a:	33250513          	addi	a0,a0,818 # 80021bb8 <ftable>
    8000488e:	ffffc097          	auipc	ra,0xffffc
    80004892:	2a4080e7          	jalr	676(ra) # 80000b32 <initlock>
}
    80004896:	60a2                	ld	ra,8(sp)
    80004898:	6402                	ld	s0,0(sp)
    8000489a:	0141                	addi	sp,sp,16
    8000489c:	8082                	ret

000000008000489e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000489e:	1101                	addi	sp,sp,-32
    800048a0:	ec06                	sd	ra,24(sp)
    800048a2:	e822                	sd	s0,16(sp)
    800048a4:	e426                	sd	s1,8(sp)
    800048a6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800048a8:	0001d517          	auipc	a0,0x1d
    800048ac:	31050513          	addi	a0,a0,784 # 80021bb8 <ftable>
    800048b0:	ffffc097          	auipc	ra,0xffffc
    800048b4:	312080e7          	jalr	786(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048b8:	0001d497          	auipc	s1,0x1d
    800048bc:	31848493          	addi	s1,s1,792 # 80021bd0 <ftable+0x18>
    800048c0:	0001e717          	auipc	a4,0x1e
    800048c4:	2b070713          	addi	a4,a4,688 # 80022b70 <ftable+0xfb8>
    if(f->ref == 0){
    800048c8:	40dc                	lw	a5,4(s1)
    800048ca:	cf99                	beqz	a5,800048e8 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048cc:	02848493          	addi	s1,s1,40
    800048d0:	fee49ce3          	bne	s1,a4,800048c8 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800048d4:	0001d517          	auipc	a0,0x1d
    800048d8:	2e450513          	addi	a0,a0,740 # 80021bb8 <ftable>
    800048dc:	ffffc097          	auipc	ra,0xffffc
    800048e0:	39a080e7          	jalr	922(ra) # 80000c76 <release>
  return 0;
    800048e4:	4481                	li	s1,0
    800048e6:	a819                	j	800048fc <filealloc+0x5e>
      f->ref = 1;
    800048e8:	4785                	li	a5,1
    800048ea:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800048ec:	0001d517          	auipc	a0,0x1d
    800048f0:	2cc50513          	addi	a0,a0,716 # 80021bb8 <ftable>
    800048f4:	ffffc097          	auipc	ra,0xffffc
    800048f8:	382080e7          	jalr	898(ra) # 80000c76 <release>
}
    800048fc:	8526                	mv	a0,s1
    800048fe:	60e2                	ld	ra,24(sp)
    80004900:	6442                	ld	s0,16(sp)
    80004902:	64a2                	ld	s1,8(sp)
    80004904:	6105                	addi	sp,sp,32
    80004906:	8082                	ret

0000000080004908 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004908:	1101                	addi	sp,sp,-32
    8000490a:	ec06                	sd	ra,24(sp)
    8000490c:	e822                	sd	s0,16(sp)
    8000490e:	e426                	sd	s1,8(sp)
    80004910:	1000                	addi	s0,sp,32
    80004912:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004914:	0001d517          	auipc	a0,0x1d
    80004918:	2a450513          	addi	a0,a0,676 # 80021bb8 <ftable>
    8000491c:	ffffc097          	auipc	ra,0xffffc
    80004920:	2a6080e7          	jalr	678(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004924:	40dc                	lw	a5,4(s1)
    80004926:	02f05263          	blez	a5,8000494a <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000492a:	2785                	addiw	a5,a5,1
    8000492c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000492e:	0001d517          	auipc	a0,0x1d
    80004932:	28a50513          	addi	a0,a0,650 # 80021bb8 <ftable>
    80004936:	ffffc097          	auipc	ra,0xffffc
    8000493a:	340080e7          	jalr	832(ra) # 80000c76 <release>
  return f;
}
    8000493e:	8526                	mv	a0,s1
    80004940:	60e2                	ld	ra,24(sp)
    80004942:	6442                	ld	s0,16(sp)
    80004944:	64a2                	ld	s1,8(sp)
    80004946:	6105                	addi	sp,sp,32
    80004948:	8082                	ret
    panic("filedup");
    8000494a:	00004517          	auipc	a0,0x4
    8000494e:	e6650513          	addi	a0,a0,-410 # 800087b0 <syscalls+0x258>
    80004952:	ffffc097          	auipc	ra,0xffffc
    80004956:	bd8080e7          	jalr	-1064(ra) # 8000052a <panic>

000000008000495a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000495a:	7139                	addi	sp,sp,-64
    8000495c:	fc06                	sd	ra,56(sp)
    8000495e:	f822                	sd	s0,48(sp)
    80004960:	f426                	sd	s1,40(sp)
    80004962:	f04a                	sd	s2,32(sp)
    80004964:	ec4e                	sd	s3,24(sp)
    80004966:	e852                	sd	s4,16(sp)
    80004968:	e456                	sd	s5,8(sp)
    8000496a:	0080                	addi	s0,sp,64
    8000496c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000496e:	0001d517          	auipc	a0,0x1d
    80004972:	24a50513          	addi	a0,a0,586 # 80021bb8 <ftable>
    80004976:	ffffc097          	auipc	ra,0xffffc
    8000497a:	24c080e7          	jalr	588(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    8000497e:	40dc                	lw	a5,4(s1)
    80004980:	06f05163          	blez	a5,800049e2 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004984:	37fd                	addiw	a5,a5,-1
    80004986:	0007871b          	sext.w	a4,a5
    8000498a:	c0dc                	sw	a5,4(s1)
    8000498c:	06e04363          	bgtz	a4,800049f2 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004990:	0004a903          	lw	s2,0(s1)
    80004994:	0094ca83          	lbu	s5,9(s1)
    80004998:	0104ba03          	ld	s4,16(s1)
    8000499c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800049a0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800049a4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800049a8:	0001d517          	auipc	a0,0x1d
    800049ac:	21050513          	addi	a0,a0,528 # 80021bb8 <ftable>
    800049b0:	ffffc097          	auipc	ra,0xffffc
    800049b4:	2c6080e7          	jalr	710(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    800049b8:	4785                	li	a5,1
    800049ba:	04f90d63          	beq	s2,a5,80004a14 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800049be:	3979                	addiw	s2,s2,-2
    800049c0:	4785                	li	a5,1
    800049c2:	0527e063          	bltu	a5,s2,80004a02 <fileclose+0xa8>
    begin_op();
    800049c6:	00000097          	auipc	ra,0x0
    800049ca:	ac8080e7          	jalr	-1336(ra) # 8000448e <begin_op>
    iput(ff.ip);
    800049ce:	854e                	mv	a0,s3
    800049d0:	fffff097          	auipc	ra,0xfffff
    800049d4:	2a2080e7          	jalr	674(ra) # 80003c72 <iput>
    end_op();
    800049d8:	00000097          	auipc	ra,0x0
    800049dc:	b36080e7          	jalr	-1226(ra) # 8000450e <end_op>
    800049e0:	a00d                	j	80004a02 <fileclose+0xa8>
    panic("fileclose");
    800049e2:	00004517          	auipc	a0,0x4
    800049e6:	dd650513          	addi	a0,a0,-554 # 800087b8 <syscalls+0x260>
    800049ea:	ffffc097          	auipc	ra,0xffffc
    800049ee:	b40080e7          	jalr	-1216(ra) # 8000052a <panic>
    release(&ftable.lock);
    800049f2:	0001d517          	auipc	a0,0x1d
    800049f6:	1c650513          	addi	a0,a0,454 # 80021bb8 <ftable>
    800049fa:	ffffc097          	auipc	ra,0xffffc
    800049fe:	27c080e7          	jalr	636(ra) # 80000c76 <release>
  }
}
    80004a02:	70e2                	ld	ra,56(sp)
    80004a04:	7442                	ld	s0,48(sp)
    80004a06:	74a2                	ld	s1,40(sp)
    80004a08:	7902                	ld	s2,32(sp)
    80004a0a:	69e2                	ld	s3,24(sp)
    80004a0c:	6a42                	ld	s4,16(sp)
    80004a0e:	6aa2                	ld	s5,8(sp)
    80004a10:	6121                	addi	sp,sp,64
    80004a12:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a14:	85d6                	mv	a1,s5
    80004a16:	8552                	mv	a0,s4
    80004a18:	00000097          	auipc	ra,0x0
    80004a1c:	34c080e7          	jalr	844(ra) # 80004d64 <pipeclose>
    80004a20:	b7cd                	j	80004a02 <fileclose+0xa8>

0000000080004a22 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a22:	715d                	addi	sp,sp,-80
    80004a24:	e486                	sd	ra,72(sp)
    80004a26:	e0a2                	sd	s0,64(sp)
    80004a28:	fc26                	sd	s1,56(sp)
    80004a2a:	f84a                	sd	s2,48(sp)
    80004a2c:	f44e                	sd	s3,40(sp)
    80004a2e:	0880                	addi	s0,sp,80
    80004a30:	84aa                	mv	s1,a0
    80004a32:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a34:	ffffd097          	auipc	ra,0xffffd
    80004a38:	f4a080e7          	jalr	-182(ra) # 8000197e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a3c:	409c                	lw	a5,0(s1)
    80004a3e:	37f9                	addiw	a5,a5,-2
    80004a40:	4705                	li	a4,1
    80004a42:	04f76763          	bltu	a4,a5,80004a90 <filestat+0x6e>
    80004a46:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a48:	6c88                	ld	a0,24(s1)
    80004a4a:	fffff097          	auipc	ra,0xfffff
    80004a4e:	06e080e7          	jalr	110(ra) # 80003ab8 <ilock>
    stati(f->ip, &st);
    80004a52:	fb840593          	addi	a1,s0,-72
    80004a56:	6c88                	ld	a0,24(s1)
    80004a58:	fffff097          	auipc	ra,0xfffff
    80004a5c:	2ea080e7          	jalr	746(ra) # 80003d42 <stati>
    iunlock(f->ip);
    80004a60:	6c88                	ld	a0,24(s1)
    80004a62:	fffff097          	auipc	ra,0xfffff
    80004a66:	118080e7          	jalr	280(ra) # 80003b7a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a6a:	46e1                	li	a3,24
    80004a6c:	fb840613          	addi	a2,s0,-72
    80004a70:	85ce                	mv	a1,s3
    80004a72:	05093503          	ld	a0,80(s2)
    80004a76:	ffffd097          	auipc	ra,0xffffd
    80004a7a:	bc8080e7          	jalr	-1080(ra) # 8000163e <copyout>
    80004a7e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004a82:	60a6                	ld	ra,72(sp)
    80004a84:	6406                	ld	s0,64(sp)
    80004a86:	74e2                	ld	s1,56(sp)
    80004a88:	7942                	ld	s2,48(sp)
    80004a8a:	79a2                	ld	s3,40(sp)
    80004a8c:	6161                	addi	sp,sp,80
    80004a8e:	8082                	ret
  return -1;
    80004a90:	557d                	li	a0,-1
    80004a92:	bfc5                	j	80004a82 <filestat+0x60>

0000000080004a94 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004a94:	7179                	addi	sp,sp,-48
    80004a96:	f406                	sd	ra,40(sp)
    80004a98:	f022                	sd	s0,32(sp)
    80004a9a:	ec26                	sd	s1,24(sp)
    80004a9c:	e84a                	sd	s2,16(sp)
    80004a9e:	e44e                	sd	s3,8(sp)
    80004aa0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004aa2:	00854783          	lbu	a5,8(a0)
    80004aa6:	c3d5                	beqz	a5,80004b4a <fileread+0xb6>
    80004aa8:	84aa                	mv	s1,a0
    80004aaa:	89ae                	mv	s3,a1
    80004aac:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004aae:	411c                	lw	a5,0(a0)
    80004ab0:	4705                	li	a4,1
    80004ab2:	04e78963          	beq	a5,a4,80004b04 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ab6:	470d                	li	a4,3
    80004ab8:	04e78d63          	beq	a5,a4,80004b12 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004abc:	4709                	li	a4,2
    80004abe:	06e79e63          	bne	a5,a4,80004b3a <fileread+0xa6>
    ilock(f->ip);
    80004ac2:	6d08                	ld	a0,24(a0)
    80004ac4:	fffff097          	auipc	ra,0xfffff
    80004ac8:	ff4080e7          	jalr	-12(ra) # 80003ab8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004acc:	874a                	mv	a4,s2
    80004ace:	5094                	lw	a3,32(s1)
    80004ad0:	864e                	mv	a2,s3
    80004ad2:	4585                	li	a1,1
    80004ad4:	6c88                	ld	a0,24(s1)
    80004ad6:	fffff097          	auipc	ra,0xfffff
    80004ada:	296080e7          	jalr	662(ra) # 80003d6c <readi>
    80004ade:	892a                	mv	s2,a0
    80004ae0:	00a05563          	blez	a0,80004aea <fileread+0x56>
      f->off += r;
    80004ae4:	509c                	lw	a5,32(s1)
    80004ae6:	9fa9                	addw	a5,a5,a0
    80004ae8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004aea:	6c88                	ld	a0,24(s1)
    80004aec:	fffff097          	auipc	ra,0xfffff
    80004af0:	08e080e7          	jalr	142(ra) # 80003b7a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004af4:	854a                	mv	a0,s2
    80004af6:	70a2                	ld	ra,40(sp)
    80004af8:	7402                	ld	s0,32(sp)
    80004afa:	64e2                	ld	s1,24(sp)
    80004afc:	6942                	ld	s2,16(sp)
    80004afe:	69a2                	ld	s3,8(sp)
    80004b00:	6145                	addi	sp,sp,48
    80004b02:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b04:	6908                	ld	a0,16(a0)
    80004b06:	00000097          	auipc	ra,0x0
    80004b0a:	3c0080e7          	jalr	960(ra) # 80004ec6 <piperead>
    80004b0e:	892a                	mv	s2,a0
    80004b10:	b7d5                	j	80004af4 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b12:	02451783          	lh	a5,36(a0)
    80004b16:	03079693          	slli	a3,a5,0x30
    80004b1a:	92c1                	srli	a3,a3,0x30
    80004b1c:	4725                	li	a4,9
    80004b1e:	02d76863          	bltu	a4,a3,80004b4e <fileread+0xba>
    80004b22:	0792                	slli	a5,a5,0x4
    80004b24:	0001d717          	auipc	a4,0x1d
    80004b28:	ff470713          	addi	a4,a4,-12 # 80021b18 <devsw>
    80004b2c:	97ba                	add	a5,a5,a4
    80004b2e:	639c                	ld	a5,0(a5)
    80004b30:	c38d                	beqz	a5,80004b52 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004b32:	4505                	li	a0,1
    80004b34:	9782                	jalr	a5
    80004b36:	892a                	mv	s2,a0
    80004b38:	bf75                	j	80004af4 <fileread+0x60>
    panic("fileread");
    80004b3a:	00004517          	auipc	a0,0x4
    80004b3e:	c8e50513          	addi	a0,a0,-882 # 800087c8 <syscalls+0x270>
    80004b42:	ffffc097          	auipc	ra,0xffffc
    80004b46:	9e8080e7          	jalr	-1560(ra) # 8000052a <panic>
    return -1;
    80004b4a:	597d                	li	s2,-1
    80004b4c:	b765                	j	80004af4 <fileread+0x60>
      return -1;
    80004b4e:	597d                	li	s2,-1
    80004b50:	b755                	j	80004af4 <fileread+0x60>
    80004b52:	597d                	li	s2,-1
    80004b54:	b745                	j	80004af4 <fileread+0x60>

0000000080004b56 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004b56:	715d                	addi	sp,sp,-80
    80004b58:	e486                	sd	ra,72(sp)
    80004b5a:	e0a2                	sd	s0,64(sp)
    80004b5c:	fc26                	sd	s1,56(sp)
    80004b5e:	f84a                	sd	s2,48(sp)
    80004b60:	f44e                	sd	s3,40(sp)
    80004b62:	f052                	sd	s4,32(sp)
    80004b64:	ec56                	sd	s5,24(sp)
    80004b66:	e85a                	sd	s6,16(sp)
    80004b68:	e45e                	sd	s7,8(sp)
    80004b6a:	e062                	sd	s8,0(sp)
    80004b6c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004b6e:	00954783          	lbu	a5,9(a0)
    80004b72:	10078663          	beqz	a5,80004c7e <filewrite+0x128>
    80004b76:	892a                	mv	s2,a0
    80004b78:	8aae                	mv	s5,a1
    80004b7a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b7c:	411c                	lw	a5,0(a0)
    80004b7e:	4705                	li	a4,1
    80004b80:	02e78263          	beq	a5,a4,80004ba4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b84:	470d                	li	a4,3
    80004b86:	02e78663          	beq	a5,a4,80004bb2 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b8a:	4709                	li	a4,2
    80004b8c:	0ee79163          	bne	a5,a4,80004c6e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004b90:	0ac05d63          	blez	a2,80004c4a <filewrite+0xf4>
    int i = 0;
    80004b94:	4981                	li	s3,0
    80004b96:	6b05                	lui	s6,0x1
    80004b98:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004b9c:	6b85                	lui	s7,0x1
    80004b9e:	c00b8b9b          	addiw	s7,s7,-1024
    80004ba2:	a861                	j	80004c3a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004ba4:	6908                	ld	a0,16(a0)
    80004ba6:	00000097          	auipc	ra,0x0
    80004baa:	22e080e7          	jalr	558(ra) # 80004dd4 <pipewrite>
    80004bae:	8a2a                	mv	s4,a0
    80004bb0:	a045                	j	80004c50 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004bb2:	02451783          	lh	a5,36(a0)
    80004bb6:	03079693          	slli	a3,a5,0x30
    80004bba:	92c1                	srli	a3,a3,0x30
    80004bbc:	4725                	li	a4,9
    80004bbe:	0cd76263          	bltu	a4,a3,80004c82 <filewrite+0x12c>
    80004bc2:	0792                	slli	a5,a5,0x4
    80004bc4:	0001d717          	auipc	a4,0x1d
    80004bc8:	f5470713          	addi	a4,a4,-172 # 80021b18 <devsw>
    80004bcc:	97ba                	add	a5,a5,a4
    80004bce:	679c                	ld	a5,8(a5)
    80004bd0:	cbdd                	beqz	a5,80004c86 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004bd2:	4505                	li	a0,1
    80004bd4:	9782                	jalr	a5
    80004bd6:	8a2a                	mv	s4,a0
    80004bd8:	a8a5                	j	80004c50 <filewrite+0xfa>
    80004bda:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004bde:	00000097          	auipc	ra,0x0
    80004be2:	8b0080e7          	jalr	-1872(ra) # 8000448e <begin_op>
      ilock(f->ip);
    80004be6:	01893503          	ld	a0,24(s2)
    80004bea:	fffff097          	auipc	ra,0xfffff
    80004bee:	ece080e7          	jalr	-306(ra) # 80003ab8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004bf2:	8762                	mv	a4,s8
    80004bf4:	02092683          	lw	a3,32(s2)
    80004bf8:	01598633          	add	a2,s3,s5
    80004bfc:	4585                	li	a1,1
    80004bfe:	01893503          	ld	a0,24(s2)
    80004c02:	fffff097          	auipc	ra,0xfffff
    80004c06:	262080e7          	jalr	610(ra) # 80003e64 <writei>
    80004c0a:	84aa                	mv	s1,a0
    80004c0c:	00a05763          	blez	a0,80004c1a <filewrite+0xc4>
        f->off += r;
    80004c10:	02092783          	lw	a5,32(s2)
    80004c14:	9fa9                	addw	a5,a5,a0
    80004c16:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c1a:	01893503          	ld	a0,24(s2)
    80004c1e:	fffff097          	auipc	ra,0xfffff
    80004c22:	f5c080e7          	jalr	-164(ra) # 80003b7a <iunlock>
      end_op();
    80004c26:	00000097          	auipc	ra,0x0
    80004c2a:	8e8080e7          	jalr	-1816(ra) # 8000450e <end_op>

      if(r != n1){
    80004c2e:	009c1f63          	bne	s8,s1,80004c4c <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004c32:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c36:	0149db63          	bge	s3,s4,80004c4c <filewrite+0xf6>
      int n1 = n - i;
    80004c3a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004c3e:	84be                	mv	s1,a5
    80004c40:	2781                	sext.w	a5,a5
    80004c42:	f8fb5ce3          	bge	s6,a5,80004bda <filewrite+0x84>
    80004c46:	84de                	mv	s1,s7
    80004c48:	bf49                	j	80004bda <filewrite+0x84>
    int i = 0;
    80004c4a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004c4c:	013a1f63          	bne	s4,s3,80004c6a <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c50:	8552                	mv	a0,s4
    80004c52:	60a6                	ld	ra,72(sp)
    80004c54:	6406                	ld	s0,64(sp)
    80004c56:	74e2                	ld	s1,56(sp)
    80004c58:	7942                	ld	s2,48(sp)
    80004c5a:	79a2                	ld	s3,40(sp)
    80004c5c:	7a02                	ld	s4,32(sp)
    80004c5e:	6ae2                	ld	s5,24(sp)
    80004c60:	6b42                	ld	s6,16(sp)
    80004c62:	6ba2                	ld	s7,8(sp)
    80004c64:	6c02                	ld	s8,0(sp)
    80004c66:	6161                	addi	sp,sp,80
    80004c68:	8082                	ret
    ret = (i == n ? n : -1);
    80004c6a:	5a7d                	li	s4,-1
    80004c6c:	b7d5                	j	80004c50 <filewrite+0xfa>
    panic("filewrite");
    80004c6e:	00004517          	auipc	a0,0x4
    80004c72:	b6a50513          	addi	a0,a0,-1174 # 800087d8 <syscalls+0x280>
    80004c76:	ffffc097          	auipc	ra,0xffffc
    80004c7a:	8b4080e7          	jalr	-1868(ra) # 8000052a <panic>
    return -1;
    80004c7e:	5a7d                	li	s4,-1
    80004c80:	bfc1                	j	80004c50 <filewrite+0xfa>
      return -1;
    80004c82:	5a7d                	li	s4,-1
    80004c84:	b7f1                	j	80004c50 <filewrite+0xfa>
    80004c86:	5a7d                	li	s4,-1
    80004c88:	b7e1                	j	80004c50 <filewrite+0xfa>

0000000080004c8a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004c8a:	7179                	addi	sp,sp,-48
    80004c8c:	f406                	sd	ra,40(sp)
    80004c8e:	f022                	sd	s0,32(sp)
    80004c90:	ec26                	sd	s1,24(sp)
    80004c92:	e84a                	sd	s2,16(sp)
    80004c94:	e44e                	sd	s3,8(sp)
    80004c96:	e052                	sd	s4,0(sp)
    80004c98:	1800                	addi	s0,sp,48
    80004c9a:	84aa                	mv	s1,a0
    80004c9c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c9e:	0005b023          	sd	zero,0(a1)
    80004ca2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ca6:	00000097          	auipc	ra,0x0
    80004caa:	bf8080e7          	jalr	-1032(ra) # 8000489e <filealloc>
    80004cae:	e088                	sd	a0,0(s1)
    80004cb0:	c551                	beqz	a0,80004d3c <pipealloc+0xb2>
    80004cb2:	00000097          	auipc	ra,0x0
    80004cb6:	bec080e7          	jalr	-1044(ra) # 8000489e <filealloc>
    80004cba:	00aa3023          	sd	a0,0(s4)
    80004cbe:	c92d                	beqz	a0,80004d30 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004cc0:	ffffc097          	auipc	ra,0xffffc
    80004cc4:	e12080e7          	jalr	-494(ra) # 80000ad2 <kalloc>
    80004cc8:	892a                	mv	s2,a0
    80004cca:	c125                	beqz	a0,80004d2a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ccc:	4985                	li	s3,1
    80004cce:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004cd2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004cd6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004cda:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004cde:	00003597          	auipc	a1,0x3
    80004ce2:	7b258593          	addi	a1,a1,1970 # 80008490 <states.0+0x1e8>
    80004ce6:	ffffc097          	auipc	ra,0xffffc
    80004cea:	e4c080e7          	jalr	-436(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80004cee:	609c                	ld	a5,0(s1)
    80004cf0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004cf4:	609c                	ld	a5,0(s1)
    80004cf6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004cfa:	609c                	ld	a5,0(s1)
    80004cfc:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d00:	609c                	ld	a5,0(s1)
    80004d02:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d06:	000a3783          	ld	a5,0(s4)
    80004d0a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d0e:	000a3783          	ld	a5,0(s4)
    80004d12:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d16:	000a3783          	ld	a5,0(s4)
    80004d1a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d1e:	000a3783          	ld	a5,0(s4)
    80004d22:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d26:	4501                	li	a0,0
    80004d28:	a025                	j	80004d50 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d2a:	6088                	ld	a0,0(s1)
    80004d2c:	e501                	bnez	a0,80004d34 <pipealloc+0xaa>
    80004d2e:	a039                	j	80004d3c <pipealloc+0xb2>
    80004d30:	6088                	ld	a0,0(s1)
    80004d32:	c51d                	beqz	a0,80004d60 <pipealloc+0xd6>
    fileclose(*f0);
    80004d34:	00000097          	auipc	ra,0x0
    80004d38:	c26080e7          	jalr	-986(ra) # 8000495a <fileclose>
  if(*f1)
    80004d3c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d40:	557d                	li	a0,-1
  if(*f1)
    80004d42:	c799                	beqz	a5,80004d50 <pipealloc+0xc6>
    fileclose(*f1);
    80004d44:	853e                	mv	a0,a5
    80004d46:	00000097          	auipc	ra,0x0
    80004d4a:	c14080e7          	jalr	-1004(ra) # 8000495a <fileclose>
  return -1;
    80004d4e:	557d                	li	a0,-1
}
    80004d50:	70a2                	ld	ra,40(sp)
    80004d52:	7402                	ld	s0,32(sp)
    80004d54:	64e2                	ld	s1,24(sp)
    80004d56:	6942                	ld	s2,16(sp)
    80004d58:	69a2                	ld	s3,8(sp)
    80004d5a:	6a02                	ld	s4,0(sp)
    80004d5c:	6145                	addi	sp,sp,48
    80004d5e:	8082                	ret
  return -1;
    80004d60:	557d                	li	a0,-1
    80004d62:	b7fd                	j	80004d50 <pipealloc+0xc6>

0000000080004d64 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004d64:	1101                	addi	sp,sp,-32
    80004d66:	ec06                	sd	ra,24(sp)
    80004d68:	e822                	sd	s0,16(sp)
    80004d6a:	e426                	sd	s1,8(sp)
    80004d6c:	e04a                	sd	s2,0(sp)
    80004d6e:	1000                	addi	s0,sp,32
    80004d70:	84aa                	mv	s1,a0
    80004d72:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004d74:	ffffc097          	auipc	ra,0xffffc
    80004d78:	e4e080e7          	jalr	-434(ra) # 80000bc2 <acquire>
  if(writable){
    80004d7c:	02090d63          	beqz	s2,80004db6 <pipeclose+0x52>
    pi->writeopen = 0;
    80004d80:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004d84:	21848513          	addi	a0,s1,536
    80004d88:	ffffd097          	auipc	ra,0xffffd
    80004d8c:	796080e7          	jalr	1942(ra) # 8000251e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004d90:	2204b783          	ld	a5,544(s1)
    80004d94:	eb95                	bnez	a5,80004dc8 <pipeclose+0x64>
    release(&pi->lock);
    80004d96:	8526                	mv	a0,s1
    80004d98:	ffffc097          	auipc	ra,0xffffc
    80004d9c:	ede080e7          	jalr	-290(ra) # 80000c76 <release>
    kfree((char*)pi);
    80004da0:	8526                	mv	a0,s1
    80004da2:	ffffc097          	auipc	ra,0xffffc
    80004da6:	c34080e7          	jalr	-972(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80004daa:	60e2                	ld	ra,24(sp)
    80004dac:	6442                	ld	s0,16(sp)
    80004dae:	64a2                	ld	s1,8(sp)
    80004db0:	6902                	ld	s2,0(sp)
    80004db2:	6105                	addi	sp,sp,32
    80004db4:	8082                	ret
    pi->readopen = 0;
    80004db6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004dba:	21c48513          	addi	a0,s1,540
    80004dbe:	ffffd097          	auipc	ra,0xffffd
    80004dc2:	760080e7          	jalr	1888(ra) # 8000251e <wakeup>
    80004dc6:	b7e9                	j	80004d90 <pipeclose+0x2c>
    release(&pi->lock);
    80004dc8:	8526                	mv	a0,s1
    80004dca:	ffffc097          	auipc	ra,0xffffc
    80004dce:	eac080e7          	jalr	-340(ra) # 80000c76 <release>
}
    80004dd2:	bfe1                	j	80004daa <pipeclose+0x46>

0000000080004dd4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004dd4:	711d                	addi	sp,sp,-96
    80004dd6:	ec86                	sd	ra,88(sp)
    80004dd8:	e8a2                	sd	s0,80(sp)
    80004dda:	e4a6                	sd	s1,72(sp)
    80004ddc:	e0ca                	sd	s2,64(sp)
    80004dde:	fc4e                	sd	s3,56(sp)
    80004de0:	f852                	sd	s4,48(sp)
    80004de2:	f456                	sd	s5,40(sp)
    80004de4:	f05a                	sd	s6,32(sp)
    80004de6:	ec5e                	sd	s7,24(sp)
    80004de8:	e862                	sd	s8,16(sp)
    80004dea:	1080                	addi	s0,sp,96
    80004dec:	84aa                	mv	s1,a0
    80004dee:	8aae                	mv	s5,a1
    80004df0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004df2:	ffffd097          	auipc	ra,0xffffd
    80004df6:	b8c080e7          	jalr	-1140(ra) # 8000197e <myproc>
    80004dfa:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004dfc:	8526                	mv	a0,s1
    80004dfe:	ffffc097          	auipc	ra,0xffffc
    80004e02:	dc4080e7          	jalr	-572(ra) # 80000bc2 <acquire>
  while(i < n){
    80004e06:	0b405363          	blez	s4,80004eac <pipewrite+0xd8>
  int i = 0;
    80004e0a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e0c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e0e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e12:	21c48b93          	addi	s7,s1,540
    80004e16:	a089                	j	80004e58 <pipewrite+0x84>
      release(&pi->lock);
    80004e18:	8526                	mv	a0,s1
    80004e1a:	ffffc097          	auipc	ra,0xffffc
    80004e1e:	e5c080e7          	jalr	-420(ra) # 80000c76 <release>
      return -1;
    80004e22:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004e24:	854a                	mv	a0,s2
    80004e26:	60e6                	ld	ra,88(sp)
    80004e28:	6446                	ld	s0,80(sp)
    80004e2a:	64a6                	ld	s1,72(sp)
    80004e2c:	6906                	ld	s2,64(sp)
    80004e2e:	79e2                	ld	s3,56(sp)
    80004e30:	7a42                	ld	s4,48(sp)
    80004e32:	7aa2                	ld	s5,40(sp)
    80004e34:	7b02                	ld	s6,32(sp)
    80004e36:	6be2                	ld	s7,24(sp)
    80004e38:	6c42                	ld	s8,16(sp)
    80004e3a:	6125                	addi	sp,sp,96
    80004e3c:	8082                	ret
      wakeup(&pi->nread);
    80004e3e:	8562                	mv	a0,s8
    80004e40:	ffffd097          	auipc	ra,0xffffd
    80004e44:	6de080e7          	jalr	1758(ra) # 8000251e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e48:	85a6                	mv	a1,s1
    80004e4a:	855e                	mv	a0,s7
    80004e4c:	ffffd097          	auipc	ra,0xffffd
    80004e50:	394080e7          	jalr	916(ra) # 800021e0 <sleep>
  while(i < n){
    80004e54:	05495d63          	bge	s2,s4,80004eae <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004e58:	2204a783          	lw	a5,544(s1)
    80004e5c:	dfd5                	beqz	a5,80004e18 <pipewrite+0x44>
    80004e5e:	0289a783          	lw	a5,40(s3)
    80004e62:	fbdd                	bnez	a5,80004e18 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004e64:	2184a783          	lw	a5,536(s1)
    80004e68:	21c4a703          	lw	a4,540(s1)
    80004e6c:	2007879b          	addiw	a5,a5,512
    80004e70:	fcf707e3          	beq	a4,a5,80004e3e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e74:	4685                	li	a3,1
    80004e76:	01590633          	add	a2,s2,s5
    80004e7a:	faf40593          	addi	a1,s0,-81
    80004e7e:	0509b503          	ld	a0,80(s3)
    80004e82:	ffffd097          	auipc	ra,0xffffd
    80004e86:	848080e7          	jalr	-1976(ra) # 800016ca <copyin>
    80004e8a:	03650263          	beq	a0,s6,80004eae <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004e8e:	21c4a783          	lw	a5,540(s1)
    80004e92:	0017871b          	addiw	a4,a5,1
    80004e96:	20e4ae23          	sw	a4,540(s1)
    80004e9a:	1ff7f793          	andi	a5,a5,511
    80004e9e:	97a6                	add	a5,a5,s1
    80004ea0:	faf44703          	lbu	a4,-81(s0)
    80004ea4:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ea8:	2905                	addiw	s2,s2,1
    80004eaa:	b76d                	j	80004e54 <pipewrite+0x80>
  int i = 0;
    80004eac:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004eae:	21848513          	addi	a0,s1,536
    80004eb2:	ffffd097          	auipc	ra,0xffffd
    80004eb6:	66c080e7          	jalr	1644(ra) # 8000251e <wakeup>
  release(&pi->lock);
    80004eba:	8526                	mv	a0,s1
    80004ebc:	ffffc097          	auipc	ra,0xffffc
    80004ec0:	dba080e7          	jalr	-582(ra) # 80000c76 <release>
  return i;
    80004ec4:	b785                	j	80004e24 <pipewrite+0x50>

0000000080004ec6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ec6:	715d                	addi	sp,sp,-80
    80004ec8:	e486                	sd	ra,72(sp)
    80004eca:	e0a2                	sd	s0,64(sp)
    80004ecc:	fc26                	sd	s1,56(sp)
    80004ece:	f84a                	sd	s2,48(sp)
    80004ed0:	f44e                	sd	s3,40(sp)
    80004ed2:	f052                	sd	s4,32(sp)
    80004ed4:	ec56                	sd	s5,24(sp)
    80004ed6:	e85a                	sd	s6,16(sp)
    80004ed8:	0880                	addi	s0,sp,80
    80004eda:	84aa                	mv	s1,a0
    80004edc:	892e                	mv	s2,a1
    80004ede:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ee0:	ffffd097          	auipc	ra,0xffffd
    80004ee4:	a9e080e7          	jalr	-1378(ra) # 8000197e <myproc>
    80004ee8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004eea:	8526                	mv	a0,s1
    80004eec:	ffffc097          	auipc	ra,0xffffc
    80004ef0:	cd6080e7          	jalr	-810(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ef4:	2184a703          	lw	a4,536(s1)
    80004ef8:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004efc:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f00:	02f71463          	bne	a4,a5,80004f28 <piperead+0x62>
    80004f04:	2244a783          	lw	a5,548(s1)
    80004f08:	c385                	beqz	a5,80004f28 <piperead+0x62>
    if(pr->killed){
    80004f0a:	028a2783          	lw	a5,40(s4)
    80004f0e:	ebc1                	bnez	a5,80004f9e <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f10:	85a6                	mv	a1,s1
    80004f12:	854e                	mv	a0,s3
    80004f14:	ffffd097          	auipc	ra,0xffffd
    80004f18:	2cc080e7          	jalr	716(ra) # 800021e0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f1c:	2184a703          	lw	a4,536(s1)
    80004f20:	21c4a783          	lw	a5,540(s1)
    80004f24:	fef700e3          	beq	a4,a5,80004f04 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f28:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f2a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f2c:	05505363          	blez	s5,80004f72 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004f30:	2184a783          	lw	a5,536(s1)
    80004f34:	21c4a703          	lw	a4,540(s1)
    80004f38:	02f70d63          	beq	a4,a5,80004f72 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f3c:	0017871b          	addiw	a4,a5,1
    80004f40:	20e4ac23          	sw	a4,536(s1)
    80004f44:	1ff7f793          	andi	a5,a5,511
    80004f48:	97a6                	add	a5,a5,s1
    80004f4a:	0187c783          	lbu	a5,24(a5)
    80004f4e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f52:	4685                	li	a3,1
    80004f54:	fbf40613          	addi	a2,s0,-65
    80004f58:	85ca                	mv	a1,s2
    80004f5a:	050a3503          	ld	a0,80(s4)
    80004f5e:	ffffc097          	auipc	ra,0xffffc
    80004f62:	6e0080e7          	jalr	1760(ra) # 8000163e <copyout>
    80004f66:	01650663          	beq	a0,s6,80004f72 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f6a:	2985                	addiw	s3,s3,1
    80004f6c:	0905                	addi	s2,s2,1
    80004f6e:	fd3a91e3          	bne	s5,s3,80004f30 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004f72:	21c48513          	addi	a0,s1,540
    80004f76:	ffffd097          	auipc	ra,0xffffd
    80004f7a:	5a8080e7          	jalr	1448(ra) # 8000251e <wakeup>
  release(&pi->lock);
    80004f7e:	8526                	mv	a0,s1
    80004f80:	ffffc097          	auipc	ra,0xffffc
    80004f84:	cf6080e7          	jalr	-778(ra) # 80000c76 <release>
  return i;
}
    80004f88:	854e                	mv	a0,s3
    80004f8a:	60a6                	ld	ra,72(sp)
    80004f8c:	6406                	ld	s0,64(sp)
    80004f8e:	74e2                	ld	s1,56(sp)
    80004f90:	7942                	ld	s2,48(sp)
    80004f92:	79a2                	ld	s3,40(sp)
    80004f94:	7a02                	ld	s4,32(sp)
    80004f96:	6ae2                	ld	s5,24(sp)
    80004f98:	6b42                	ld	s6,16(sp)
    80004f9a:	6161                	addi	sp,sp,80
    80004f9c:	8082                	ret
      release(&pi->lock);
    80004f9e:	8526                	mv	a0,s1
    80004fa0:	ffffc097          	auipc	ra,0xffffc
    80004fa4:	cd6080e7          	jalr	-810(ra) # 80000c76 <release>
      return -1;
    80004fa8:	59fd                	li	s3,-1
    80004faa:	bff9                	j	80004f88 <piperead+0xc2>

0000000080004fac <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004fac:	de010113          	addi	sp,sp,-544
    80004fb0:	20113c23          	sd	ra,536(sp)
    80004fb4:	20813823          	sd	s0,528(sp)
    80004fb8:	20913423          	sd	s1,520(sp)
    80004fbc:	21213023          	sd	s2,512(sp)
    80004fc0:	ffce                	sd	s3,504(sp)
    80004fc2:	fbd2                	sd	s4,496(sp)
    80004fc4:	f7d6                	sd	s5,488(sp)
    80004fc6:	f3da                	sd	s6,480(sp)
    80004fc8:	efde                	sd	s7,472(sp)
    80004fca:	ebe2                	sd	s8,464(sp)
    80004fcc:	e7e6                	sd	s9,456(sp)
    80004fce:	e3ea                	sd	s10,448(sp)
    80004fd0:	ff6e                	sd	s11,440(sp)
    80004fd2:	1400                	addi	s0,sp,544
    80004fd4:	892a                	mv	s2,a0
    80004fd6:	dea43423          	sd	a0,-536(s0)
    80004fda:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004fde:	ffffd097          	auipc	ra,0xffffd
    80004fe2:	9a0080e7          	jalr	-1632(ra) # 8000197e <myproc>
    80004fe6:	84aa                	mv	s1,a0

  begin_op();
    80004fe8:	fffff097          	auipc	ra,0xfffff
    80004fec:	4a6080e7          	jalr	1190(ra) # 8000448e <begin_op>

  if((ip = namei(path)) == 0){
    80004ff0:	854a                	mv	a0,s2
    80004ff2:	fffff097          	auipc	ra,0xfffff
    80004ff6:	27c080e7          	jalr	636(ra) # 8000426e <namei>
    80004ffa:	c93d                	beqz	a0,80005070 <exec+0xc4>
    80004ffc:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ffe:	fffff097          	auipc	ra,0xfffff
    80005002:	aba080e7          	jalr	-1350(ra) # 80003ab8 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005006:	04000713          	li	a4,64
    8000500a:	4681                	li	a3,0
    8000500c:	e4840613          	addi	a2,s0,-440
    80005010:	4581                	li	a1,0
    80005012:	8556                	mv	a0,s5
    80005014:	fffff097          	auipc	ra,0xfffff
    80005018:	d58080e7          	jalr	-680(ra) # 80003d6c <readi>
    8000501c:	04000793          	li	a5,64
    80005020:	00f51a63          	bne	a0,a5,80005034 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005024:	e4842703          	lw	a4,-440(s0)
    80005028:	464c47b7          	lui	a5,0x464c4
    8000502c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005030:	04f70663          	beq	a4,a5,8000507c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005034:	8556                	mv	a0,s5
    80005036:	fffff097          	auipc	ra,0xfffff
    8000503a:	ce4080e7          	jalr	-796(ra) # 80003d1a <iunlockput>
    end_op();
    8000503e:	fffff097          	auipc	ra,0xfffff
    80005042:	4d0080e7          	jalr	1232(ra) # 8000450e <end_op>
  }
  return -1;
    80005046:	557d                	li	a0,-1
}
    80005048:	21813083          	ld	ra,536(sp)
    8000504c:	21013403          	ld	s0,528(sp)
    80005050:	20813483          	ld	s1,520(sp)
    80005054:	20013903          	ld	s2,512(sp)
    80005058:	79fe                	ld	s3,504(sp)
    8000505a:	7a5e                	ld	s4,496(sp)
    8000505c:	7abe                	ld	s5,488(sp)
    8000505e:	7b1e                	ld	s6,480(sp)
    80005060:	6bfe                	ld	s7,472(sp)
    80005062:	6c5e                	ld	s8,464(sp)
    80005064:	6cbe                	ld	s9,456(sp)
    80005066:	6d1e                	ld	s10,448(sp)
    80005068:	7dfa                	ld	s11,440(sp)
    8000506a:	22010113          	addi	sp,sp,544
    8000506e:	8082                	ret
    end_op();
    80005070:	fffff097          	auipc	ra,0xfffff
    80005074:	49e080e7          	jalr	1182(ra) # 8000450e <end_op>
    return -1;
    80005078:	557d                	li	a0,-1
    8000507a:	b7f9                	j	80005048 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000507c:	8526                	mv	a0,s1
    8000507e:	ffffd097          	auipc	ra,0xffffd
    80005082:	ab0080e7          	jalr	-1360(ra) # 80001b2e <proc_pagetable>
    80005086:	8b2a                	mv	s6,a0
    80005088:	d555                	beqz	a0,80005034 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000508a:	e6842783          	lw	a5,-408(s0)
    8000508e:	e8045703          	lhu	a4,-384(s0)
    80005092:	c735                	beqz	a4,800050fe <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005094:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005096:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000509a:	6a05                	lui	s4,0x1
    8000509c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800050a0:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    800050a4:	6d85                	lui	s11,0x1
    800050a6:	7d7d                	lui	s10,0xfffff
    800050a8:	ac1d                	j	800052de <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800050aa:	00003517          	auipc	a0,0x3
    800050ae:	73e50513          	addi	a0,a0,1854 # 800087e8 <syscalls+0x290>
    800050b2:	ffffb097          	auipc	ra,0xffffb
    800050b6:	478080e7          	jalr	1144(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800050ba:	874a                	mv	a4,s2
    800050bc:	009c86bb          	addw	a3,s9,s1
    800050c0:	4581                	li	a1,0
    800050c2:	8556                	mv	a0,s5
    800050c4:	fffff097          	auipc	ra,0xfffff
    800050c8:	ca8080e7          	jalr	-856(ra) # 80003d6c <readi>
    800050cc:	2501                	sext.w	a0,a0
    800050ce:	1aa91863          	bne	s2,a0,8000527e <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    800050d2:	009d84bb          	addw	s1,s11,s1
    800050d6:	013d09bb          	addw	s3,s10,s3
    800050da:	1f74f263          	bgeu	s1,s7,800052be <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    800050de:	02049593          	slli	a1,s1,0x20
    800050e2:	9181                	srli	a1,a1,0x20
    800050e4:	95e2                	add	a1,a1,s8
    800050e6:	855a                	mv	a0,s6
    800050e8:	ffffc097          	auipc	ra,0xffffc
    800050ec:	f64080e7          	jalr	-156(ra) # 8000104c <walkaddr>
    800050f0:	862a                	mv	a2,a0
    if(pa == 0)
    800050f2:	dd45                	beqz	a0,800050aa <exec+0xfe>
      n = PGSIZE;
    800050f4:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800050f6:	fd49f2e3          	bgeu	s3,s4,800050ba <exec+0x10e>
      n = sz - i;
    800050fa:	894e                	mv	s2,s3
    800050fc:	bf7d                	j	800050ba <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800050fe:	4481                	li	s1,0
  iunlockput(ip);
    80005100:	8556                	mv	a0,s5
    80005102:	fffff097          	auipc	ra,0xfffff
    80005106:	c18080e7          	jalr	-1000(ra) # 80003d1a <iunlockput>
  end_op();
    8000510a:	fffff097          	auipc	ra,0xfffff
    8000510e:	404080e7          	jalr	1028(ra) # 8000450e <end_op>
  p = myproc();
    80005112:	ffffd097          	auipc	ra,0xffffd
    80005116:	86c080e7          	jalr	-1940(ra) # 8000197e <myproc>
    8000511a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000511c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005120:	6785                	lui	a5,0x1
    80005122:	17fd                	addi	a5,a5,-1
    80005124:	94be                	add	s1,s1,a5
    80005126:	77fd                	lui	a5,0xfffff
    80005128:	8fe5                	and	a5,a5,s1
    8000512a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000512e:	6609                	lui	a2,0x2
    80005130:	963e                	add	a2,a2,a5
    80005132:	85be                	mv	a1,a5
    80005134:	855a                	mv	a0,s6
    80005136:	ffffc097          	auipc	ra,0xffffc
    8000513a:	2b8080e7          	jalr	696(ra) # 800013ee <uvmalloc>
    8000513e:	8c2a                	mv	s8,a0
  ip = 0;
    80005140:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005142:	12050e63          	beqz	a0,8000527e <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005146:	75f9                	lui	a1,0xffffe
    80005148:	95aa                	add	a1,a1,a0
    8000514a:	855a                	mv	a0,s6
    8000514c:	ffffc097          	auipc	ra,0xffffc
    80005150:	4c0080e7          	jalr	1216(ra) # 8000160c <uvmclear>
  stackbase = sp - PGSIZE;
    80005154:	7afd                	lui	s5,0xfffff
    80005156:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005158:	df043783          	ld	a5,-528(s0)
    8000515c:	6388                	ld	a0,0(a5)
    8000515e:	c925                	beqz	a0,800051ce <exec+0x222>
    80005160:	e8840993          	addi	s3,s0,-376
    80005164:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005168:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000516a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000516c:	ffffc097          	auipc	ra,0xffffc
    80005170:	cd6080e7          	jalr	-810(ra) # 80000e42 <strlen>
    80005174:	0015079b          	addiw	a5,a0,1
    80005178:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000517c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005180:	13596363          	bltu	s2,s5,800052a6 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005184:	df043d83          	ld	s11,-528(s0)
    80005188:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000518c:	8552                	mv	a0,s4
    8000518e:	ffffc097          	auipc	ra,0xffffc
    80005192:	cb4080e7          	jalr	-844(ra) # 80000e42 <strlen>
    80005196:	0015069b          	addiw	a3,a0,1
    8000519a:	8652                	mv	a2,s4
    8000519c:	85ca                	mv	a1,s2
    8000519e:	855a                	mv	a0,s6
    800051a0:	ffffc097          	auipc	ra,0xffffc
    800051a4:	49e080e7          	jalr	1182(ra) # 8000163e <copyout>
    800051a8:	10054363          	bltz	a0,800052ae <exec+0x302>
    ustack[argc] = sp;
    800051ac:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800051b0:	0485                	addi	s1,s1,1
    800051b2:	008d8793          	addi	a5,s11,8
    800051b6:	def43823          	sd	a5,-528(s0)
    800051ba:	008db503          	ld	a0,8(s11)
    800051be:	c911                	beqz	a0,800051d2 <exec+0x226>
    if(argc >= MAXARG)
    800051c0:	09a1                	addi	s3,s3,8
    800051c2:	fb3c95e3          	bne	s9,s3,8000516c <exec+0x1c0>
  sz = sz1;
    800051c6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051ca:	4a81                	li	s5,0
    800051cc:	a84d                	j	8000527e <exec+0x2d2>
  sp = sz;
    800051ce:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800051d0:	4481                	li	s1,0
  ustack[argc] = 0;
    800051d2:	00349793          	slli	a5,s1,0x3
    800051d6:	f9040713          	addi	a4,s0,-112
    800051da:	97ba                	add	a5,a5,a4
    800051dc:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    800051e0:	00148693          	addi	a3,s1,1
    800051e4:	068e                	slli	a3,a3,0x3
    800051e6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800051ea:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800051ee:	01597663          	bgeu	s2,s5,800051fa <exec+0x24e>
  sz = sz1;
    800051f2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051f6:	4a81                	li	s5,0
    800051f8:	a059                	j	8000527e <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800051fa:	e8840613          	addi	a2,s0,-376
    800051fe:	85ca                	mv	a1,s2
    80005200:	855a                	mv	a0,s6
    80005202:	ffffc097          	auipc	ra,0xffffc
    80005206:	43c080e7          	jalr	1084(ra) # 8000163e <copyout>
    8000520a:	0a054663          	bltz	a0,800052b6 <exec+0x30a>
  p->trapframe->a1 = sp;
    8000520e:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005212:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005216:	de843783          	ld	a5,-536(s0)
    8000521a:	0007c703          	lbu	a4,0(a5)
    8000521e:	cf11                	beqz	a4,8000523a <exec+0x28e>
    80005220:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005222:	02f00693          	li	a3,47
    80005226:	a039                	j	80005234 <exec+0x288>
      last = s+1;
    80005228:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000522c:	0785                	addi	a5,a5,1
    8000522e:	fff7c703          	lbu	a4,-1(a5)
    80005232:	c701                	beqz	a4,8000523a <exec+0x28e>
    if(*s == '/')
    80005234:	fed71ce3          	bne	a4,a3,8000522c <exec+0x280>
    80005238:	bfc5                	j	80005228 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000523a:	4641                	li	a2,16
    8000523c:	de843583          	ld	a1,-536(s0)
    80005240:	158b8513          	addi	a0,s7,344
    80005244:	ffffc097          	auipc	ra,0xffffc
    80005248:	bcc080e7          	jalr	-1076(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    8000524c:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005250:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005254:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005258:	058bb783          	ld	a5,88(s7)
    8000525c:	e6043703          	ld	a4,-416(s0)
    80005260:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005262:	058bb783          	ld	a5,88(s7)
    80005266:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000526a:	85ea                	mv	a1,s10
    8000526c:	ffffd097          	auipc	ra,0xffffd
    80005270:	95e080e7          	jalr	-1698(ra) # 80001bca <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005274:	0004851b          	sext.w	a0,s1
    80005278:	bbc1                	j	80005048 <exec+0x9c>
    8000527a:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000527e:	df843583          	ld	a1,-520(s0)
    80005282:	855a                	mv	a0,s6
    80005284:	ffffd097          	auipc	ra,0xffffd
    80005288:	946080e7          	jalr	-1722(ra) # 80001bca <proc_freepagetable>
  if(ip){
    8000528c:	da0a94e3          	bnez	s5,80005034 <exec+0x88>
  return -1;
    80005290:	557d                	li	a0,-1
    80005292:	bb5d                	j	80005048 <exec+0x9c>
    80005294:	de943c23          	sd	s1,-520(s0)
    80005298:	b7dd                	j	8000527e <exec+0x2d2>
    8000529a:	de943c23          	sd	s1,-520(s0)
    8000529e:	b7c5                	j	8000527e <exec+0x2d2>
    800052a0:	de943c23          	sd	s1,-520(s0)
    800052a4:	bfe9                	j	8000527e <exec+0x2d2>
  sz = sz1;
    800052a6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052aa:	4a81                	li	s5,0
    800052ac:	bfc9                	j	8000527e <exec+0x2d2>
  sz = sz1;
    800052ae:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052b2:	4a81                	li	s5,0
    800052b4:	b7e9                	j	8000527e <exec+0x2d2>
  sz = sz1;
    800052b6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052ba:	4a81                	li	s5,0
    800052bc:	b7c9                	j	8000527e <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800052be:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052c2:	e0843783          	ld	a5,-504(s0)
    800052c6:	0017869b          	addiw	a3,a5,1
    800052ca:	e0d43423          	sd	a3,-504(s0)
    800052ce:	e0043783          	ld	a5,-512(s0)
    800052d2:	0387879b          	addiw	a5,a5,56
    800052d6:	e8045703          	lhu	a4,-384(s0)
    800052da:	e2e6d3e3          	bge	a3,a4,80005100 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800052de:	2781                	sext.w	a5,a5
    800052e0:	e0f43023          	sd	a5,-512(s0)
    800052e4:	03800713          	li	a4,56
    800052e8:	86be                	mv	a3,a5
    800052ea:	e1040613          	addi	a2,s0,-496
    800052ee:	4581                	li	a1,0
    800052f0:	8556                	mv	a0,s5
    800052f2:	fffff097          	auipc	ra,0xfffff
    800052f6:	a7a080e7          	jalr	-1414(ra) # 80003d6c <readi>
    800052fa:	03800793          	li	a5,56
    800052fe:	f6f51ee3          	bne	a0,a5,8000527a <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80005302:	e1042783          	lw	a5,-496(s0)
    80005306:	4705                	li	a4,1
    80005308:	fae79de3          	bne	a5,a4,800052c2 <exec+0x316>
    if(ph.memsz < ph.filesz)
    8000530c:	e3843603          	ld	a2,-456(s0)
    80005310:	e3043783          	ld	a5,-464(s0)
    80005314:	f8f660e3          	bltu	a2,a5,80005294 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005318:	e2043783          	ld	a5,-480(s0)
    8000531c:	963e                	add	a2,a2,a5
    8000531e:	f6f66ee3          	bltu	a2,a5,8000529a <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005322:	85a6                	mv	a1,s1
    80005324:	855a                	mv	a0,s6
    80005326:	ffffc097          	auipc	ra,0xffffc
    8000532a:	0c8080e7          	jalr	200(ra) # 800013ee <uvmalloc>
    8000532e:	dea43c23          	sd	a0,-520(s0)
    80005332:	d53d                	beqz	a0,800052a0 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80005334:	e2043c03          	ld	s8,-480(s0)
    80005338:	de043783          	ld	a5,-544(s0)
    8000533c:	00fc77b3          	and	a5,s8,a5
    80005340:	ff9d                	bnez	a5,8000527e <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005342:	e1842c83          	lw	s9,-488(s0)
    80005346:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000534a:	f60b8ae3          	beqz	s7,800052be <exec+0x312>
    8000534e:	89de                	mv	s3,s7
    80005350:	4481                	li	s1,0
    80005352:	b371                	j	800050de <exec+0x132>

0000000080005354 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005354:	7179                	addi	sp,sp,-48
    80005356:	f406                	sd	ra,40(sp)
    80005358:	f022                	sd	s0,32(sp)
    8000535a:	ec26                	sd	s1,24(sp)
    8000535c:	e84a                	sd	s2,16(sp)
    8000535e:	1800                	addi	s0,sp,48
    80005360:	892e                	mv	s2,a1
    80005362:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005364:	fdc40593          	addi	a1,s0,-36
    80005368:	ffffe097          	auipc	ra,0xffffe
    8000536c:	a76080e7          	jalr	-1418(ra) # 80002dde <argint>
    80005370:	04054063          	bltz	a0,800053b0 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005374:	fdc42703          	lw	a4,-36(s0)
    80005378:	47bd                	li	a5,15
    8000537a:	02e7ed63          	bltu	a5,a4,800053b4 <argfd+0x60>
    8000537e:	ffffc097          	auipc	ra,0xffffc
    80005382:	600080e7          	jalr	1536(ra) # 8000197e <myproc>
    80005386:	fdc42703          	lw	a4,-36(s0)
    8000538a:	01a70793          	addi	a5,a4,26
    8000538e:	078e                	slli	a5,a5,0x3
    80005390:	953e                	add	a0,a0,a5
    80005392:	611c                	ld	a5,0(a0)
    80005394:	c395                	beqz	a5,800053b8 <argfd+0x64>
    return -1;
  if(pfd)
    80005396:	00090463          	beqz	s2,8000539e <argfd+0x4a>
    *pfd = fd;
    8000539a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000539e:	4501                	li	a0,0
  if(pf)
    800053a0:	c091                	beqz	s1,800053a4 <argfd+0x50>
    *pf = f;
    800053a2:	e09c                	sd	a5,0(s1)
}
    800053a4:	70a2                	ld	ra,40(sp)
    800053a6:	7402                	ld	s0,32(sp)
    800053a8:	64e2                	ld	s1,24(sp)
    800053aa:	6942                	ld	s2,16(sp)
    800053ac:	6145                	addi	sp,sp,48
    800053ae:	8082                	ret
    return -1;
    800053b0:	557d                	li	a0,-1
    800053b2:	bfcd                	j	800053a4 <argfd+0x50>
    return -1;
    800053b4:	557d                	li	a0,-1
    800053b6:	b7fd                	j	800053a4 <argfd+0x50>
    800053b8:	557d                	li	a0,-1
    800053ba:	b7ed                	j	800053a4 <argfd+0x50>

00000000800053bc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800053bc:	1101                	addi	sp,sp,-32
    800053be:	ec06                	sd	ra,24(sp)
    800053c0:	e822                	sd	s0,16(sp)
    800053c2:	e426                	sd	s1,8(sp)
    800053c4:	1000                	addi	s0,sp,32
    800053c6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053c8:	ffffc097          	auipc	ra,0xffffc
    800053cc:	5b6080e7          	jalr	1462(ra) # 8000197e <myproc>
    800053d0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800053d2:	0d050793          	addi	a5,a0,208
    800053d6:	4501                	li	a0,0
    800053d8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800053da:	6398                	ld	a4,0(a5)
    800053dc:	cb19                	beqz	a4,800053f2 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800053de:	2505                	addiw	a0,a0,1
    800053e0:	07a1                	addi	a5,a5,8
    800053e2:	fed51ce3          	bne	a0,a3,800053da <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800053e6:	557d                	li	a0,-1
}
    800053e8:	60e2                	ld	ra,24(sp)
    800053ea:	6442                	ld	s0,16(sp)
    800053ec:	64a2                	ld	s1,8(sp)
    800053ee:	6105                	addi	sp,sp,32
    800053f0:	8082                	ret
      p->ofile[fd] = f;
    800053f2:	01a50793          	addi	a5,a0,26
    800053f6:	078e                	slli	a5,a5,0x3
    800053f8:	963e                	add	a2,a2,a5
    800053fa:	e204                	sd	s1,0(a2)
      return fd;
    800053fc:	b7f5                	j	800053e8 <fdalloc+0x2c>

00000000800053fe <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800053fe:	715d                	addi	sp,sp,-80
    80005400:	e486                	sd	ra,72(sp)
    80005402:	e0a2                	sd	s0,64(sp)
    80005404:	fc26                	sd	s1,56(sp)
    80005406:	f84a                	sd	s2,48(sp)
    80005408:	f44e                	sd	s3,40(sp)
    8000540a:	f052                	sd	s4,32(sp)
    8000540c:	ec56                	sd	s5,24(sp)
    8000540e:	0880                	addi	s0,sp,80
    80005410:	89ae                	mv	s3,a1
    80005412:	8ab2                	mv	s5,a2
    80005414:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005416:	fb040593          	addi	a1,s0,-80
    8000541a:	fffff097          	auipc	ra,0xfffff
    8000541e:	e72080e7          	jalr	-398(ra) # 8000428c <nameiparent>
    80005422:	892a                	mv	s2,a0
    80005424:	12050e63          	beqz	a0,80005560 <create+0x162>
    return 0;

  ilock(dp);
    80005428:	ffffe097          	auipc	ra,0xffffe
    8000542c:	690080e7          	jalr	1680(ra) # 80003ab8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005430:	4601                	li	a2,0
    80005432:	fb040593          	addi	a1,s0,-80
    80005436:	854a                	mv	a0,s2
    80005438:	fffff097          	auipc	ra,0xfffff
    8000543c:	b64080e7          	jalr	-1180(ra) # 80003f9c <dirlookup>
    80005440:	84aa                	mv	s1,a0
    80005442:	c921                	beqz	a0,80005492 <create+0x94>
    iunlockput(dp);
    80005444:	854a                	mv	a0,s2
    80005446:	fffff097          	auipc	ra,0xfffff
    8000544a:	8d4080e7          	jalr	-1836(ra) # 80003d1a <iunlockput>
    ilock(ip);
    8000544e:	8526                	mv	a0,s1
    80005450:	ffffe097          	auipc	ra,0xffffe
    80005454:	668080e7          	jalr	1640(ra) # 80003ab8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005458:	2981                	sext.w	s3,s3
    8000545a:	4789                	li	a5,2
    8000545c:	02f99463          	bne	s3,a5,80005484 <create+0x86>
    80005460:	0444d783          	lhu	a5,68(s1)
    80005464:	37f9                	addiw	a5,a5,-2
    80005466:	17c2                	slli	a5,a5,0x30
    80005468:	93c1                	srli	a5,a5,0x30
    8000546a:	4705                	li	a4,1
    8000546c:	00f76c63          	bltu	a4,a5,80005484 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005470:	8526                	mv	a0,s1
    80005472:	60a6                	ld	ra,72(sp)
    80005474:	6406                	ld	s0,64(sp)
    80005476:	74e2                	ld	s1,56(sp)
    80005478:	7942                	ld	s2,48(sp)
    8000547a:	79a2                	ld	s3,40(sp)
    8000547c:	7a02                	ld	s4,32(sp)
    8000547e:	6ae2                	ld	s5,24(sp)
    80005480:	6161                	addi	sp,sp,80
    80005482:	8082                	ret
    iunlockput(ip);
    80005484:	8526                	mv	a0,s1
    80005486:	fffff097          	auipc	ra,0xfffff
    8000548a:	894080e7          	jalr	-1900(ra) # 80003d1a <iunlockput>
    return 0;
    8000548e:	4481                	li	s1,0
    80005490:	b7c5                	j	80005470 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005492:	85ce                	mv	a1,s3
    80005494:	00092503          	lw	a0,0(s2)
    80005498:	ffffe097          	auipc	ra,0xffffe
    8000549c:	488080e7          	jalr	1160(ra) # 80003920 <ialloc>
    800054a0:	84aa                	mv	s1,a0
    800054a2:	c521                	beqz	a0,800054ea <create+0xec>
  ilock(ip);
    800054a4:	ffffe097          	auipc	ra,0xffffe
    800054a8:	614080e7          	jalr	1556(ra) # 80003ab8 <ilock>
  ip->major = major;
    800054ac:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800054b0:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800054b4:	4a05                	li	s4,1
    800054b6:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800054ba:	8526                	mv	a0,s1
    800054bc:	ffffe097          	auipc	ra,0xffffe
    800054c0:	532080e7          	jalr	1330(ra) # 800039ee <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054c4:	2981                	sext.w	s3,s3
    800054c6:	03498a63          	beq	s3,s4,800054fa <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800054ca:	40d0                	lw	a2,4(s1)
    800054cc:	fb040593          	addi	a1,s0,-80
    800054d0:	854a                	mv	a0,s2
    800054d2:	fffff097          	auipc	ra,0xfffff
    800054d6:	cda080e7          	jalr	-806(ra) # 800041ac <dirlink>
    800054da:	06054b63          	bltz	a0,80005550 <create+0x152>
  iunlockput(dp);
    800054de:	854a                	mv	a0,s2
    800054e0:	fffff097          	auipc	ra,0xfffff
    800054e4:	83a080e7          	jalr	-1990(ra) # 80003d1a <iunlockput>
  return ip;
    800054e8:	b761                	j	80005470 <create+0x72>
    panic("create: ialloc");
    800054ea:	00003517          	auipc	a0,0x3
    800054ee:	31e50513          	addi	a0,a0,798 # 80008808 <syscalls+0x2b0>
    800054f2:	ffffb097          	auipc	ra,0xffffb
    800054f6:	038080e7          	jalr	56(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    800054fa:	04a95783          	lhu	a5,74(s2)
    800054fe:	2785                	addiw	a5,a5,1
    80005500:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005504:	854a                	mv	a0,s2
    80005506:	ffffe097          	auipc	ra,0xffffe
    8000550a:	4e8080e7          	jalr	1256(ra) # 800039ee <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000550e:	40d0                	lw	a2,4(s1)
    80005510:	00003597          	auipc	a1,0x3
    80005514:	30858593          	addi	a1,a1,776 # 80008818 <syscalls+0x2c0>
    80005518:	8526                	mv	a0,s1
    8000551a:	fffff097          	auipc	ra,0xfffff
    8000551e:	c92080e7          	jalr	-878(ra) # 800041ac <dirlink>
    80005522:	00054f63          	bltz	a0,80005540 <create+0x142>
    80005526:	00492603          	lw	a2,4(s2)
    8000552a:	00003597          	auipc	a1,0x3
    8000552e:	2f658593          	addi	a1,a1,758 # 80008820 <syscalls+0x2c8>
    80005532:	8526                	mv	a0,s1
    80005534:	fffff097          	auipc	ra,0xfffff
    80005538:	c78080e7          	jalr	-904(ra) # 800041ac <dirlink>
    8000553c:	f80557e3          	bgez	a0,800054ca <create+0xcc>
      panic("create dots");
    80005540:	00003517          	auipc	a0,0x3
    80005544:	2e850513          	addi	a0,a0,744 # 80008828 <syscalls+0x2d0>
    80005548:	ffffb097          	auipc	ra,0xffffb
    8000554c:	fe2080e7          	jalr	-30(ra) # 8000052a <panic>
    panic("create: dirlink");
    80005550:	00003517          	auipc	a0,0x3
    80005554:	2e850513          	addi	a0,a0,744 # 80008838 <syscalls+0x2e0>
    80005558:	ffffb097          	auipc	ra,0xffffb
    8000555c:	fd2080e7          	jalr	-46(ra) # 8000052a <panic>
    return 0;
    80005560:	84aa                	mv	s1,a0
    80005562:	b739                	j	80005470 <create+0x72>

0000000080005564 <sys_dup>:
{
    80005564:	7179                	addi	sp,sp,-48
    80005566:	f406                	sd	ra,40(sp)
    80005568:	f022                	sd	s0,32(sp)
    8000556a:	ec26                	sd	s1,24(sp)
    8000556c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000556e:	fd840613          	addi	a2,s0,-40
    80005572:	4581                	li	a1,0
    80005574:	4501                	li	a0,0
    80005576:	00000097          	auipc	ra,0x0
    8000557a:	dde080e7          	jalr	-546(ra) # 80005354 <argfd>
    return -1;
    8000557e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005580:	02054363          	bltz	a0,800055a6 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005584:	fd843503          	ld	a0,-40(s0)
    80005588:	00000097          	auipc	ra,0x0
    8000558c:	e34080e7          	jalr	-460(ra) # 800053bc <fdalloc>
    80005590:	84aa                	mv	s1,a0
    return -1;
    80005592:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005594:	00054963          	bltz	a0,800055a6 <sys_dup+0x42>
  filedup(f);
    80005598:	fd843503          	ld	a0,-40(s0)
    8000559c:	fffff097          	auipc	ra,0xfffff
    800055a0:	36c080e7          	jalr	876(ra) # 80004908 <filedup>
  return fd;
    800055a4:	87a6                	mv	a5,s1
}
    800055a6:	853e                	mv	a0,a5
    800055a8:	70a2                	ld	ra,40(sp)
    800055aa:	7402                	ld	s0,32(sp)
    800055ac:	64e2                	ld	s1,24(sp)
    800055ae:	6145                	addi	sp,sp,48
    800055b0:	8082                	ret

00000000800055b2 <sys_read>:
{
    800055b2:	7179                	addi	sp,sp,-48
    800055b4:	f406                	sd	ra,40(sp)
    800055b6:	f022                	sd	s0,32(sp)
    800055b8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055ba:	fe840613          	addi	a2,s0,-24
    800055be:	4581                	li	a1,0
    800055c0:	4501                	li	a0,0
    800055c2:	00000097          	auipc	ra,0x0
    800055c6:	d92080e7          	jalr	-622(ra) # 80005354 <argfd>
    return -1;
    800055ca:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055cc:	04054163          	bltz	a0,8000560e <sys_read+0x5c>
    800055d0:	fe440593          	addi	a1,s0,-28
    800055d4:	4509                	li	a0,2
    800055d6:	ffffe097          	auipc	ra,0xffffe
    800055da:	808080e7          	jalr	-2040(ra) # 80002dde <argint>
    return -1;
    800055de:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055e0:	02054763          	bltz	a0,8000560e <sys_read+0x5c>
    800055e4:	fd840593          	addi	a1,s0,-40
    800055e8:	4505                	li	a0,1
    800055ea:	ffffe097          	auipc	ra,0xffffe
    800055ee:	816080e7          	jalr	-2026(ra) # 80002e00 <argaddr>
    return -1;
    800055f2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055f4:	00054d63          	bltz	a0,8000560e <sys_read+0x5c>
  return fileread(f, p, n);
    800055f8:	fe442603          	lw	a2,-28(s0)
    800055fc:	fd843583          	ld	a1,-40(s0)
    80005600:	fe843503          	ld	a0,-24(s0)
    80005604:	fffff097          	auipc	ra,0xfffff
    80005608:	490080e7          	jalr	1168(ra) # 80004a94 <fileread>
    8000560c:	87aa                	mv	a5,a0
}
    8000560e:	853e                	mv	a0,a5
    80005610:	70a2                	ld	ra,40(sp)
    80005612:	7402                	ld	s0,32(sp)
    80005614:	6145                	addi	sp,sp,48
    80005616:	8082                	ret

0000000080005618 <sys_write>:
{
    80005618:	7179                	addi	sp,sp,-48
    8000561a:	f406                	sd	ra,40(sp)
    8000561c:	f022                	sd	s0,32(sp)
    8000561e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005620:	fe840613          	addi	a2,s0,-24
    80005624:	4581                	li	a1,0
    80005626:	4501                	li	a0,0
    80005628:	00000097          	auipc	ra,0x0
    8000562c:	d2c080e7          	jalr	-724(ra) # 80005354 <argfd>
    return -1;
    80005630:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005632:	04054163          	bltz	a0,80005674 <sys_write+0x5c>
    80005636:	fe440593          	addi	a1,s0,-28
    8000563a:	4509                	li	a0,2
    8000563c:	ffffd097          	auipc	ra,0xffffd
    80005640:	7a2080e7          	jalr	1954(ra) # 80002dde <argint>
    return -1;
    80005644:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005646:	02054763          	bltz	a0,80005674 <sys_write+0x5c>
    8000564a:	fd840593          	addi	a1,s0,-40
    8000564e:	4505                	li	a0,1
    80005650:	ffffd097          	auipc	ra,0xffffd
    80005654:	7b0080e7          	jalr	1968(ra) # 80002e00 <argaddr>
    return -1;
    80005658:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000565a:	00054d63          	bltz	a0,80005674 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000565e:	fe442603          	lw	a2,-28(s0)
    80005662:	fd843583          	ld	a1,-40(s0)
    80005666:	fe843503          	ld	a0,-24(s0)
    8000566a:	fffff097          	auipc	ra,0xfffff
    8000566e:	4ec080e7          	jalr	1260(ra) # 80004b56 <filewrite>
    80005672:	87aa                	mv	a5,a0
}
    80005674:	853e                	mv	a0,a5
    80005676:	70a2                	ld	ra,40(sp)
    80005678:	7402                	ld	s0,32(sp)
    8000567a:	6145                	addi	sp,sp,48
    8000567c:	8082                	ret

000000008000567e <sys_close>:
{
    8000567e:	1101                	addi	sp,sp,-32
    80005680:	ec06                	sd	ra,24(sp)
    80005682:	e822                	sd	s0,16(sp)
    80005684:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005686:	fe040613          	addi	a2,s0,-32
    8000568a:	fec40593          	addi	a1,s0,-20
    8000568e:	4501                	li	a0,0
    80005690:	00000097          	auipc	ra,0x0
    80005694:	cc4080e7          	jalr	-828(ra) # 80005354 <argfd>
    return -1;
    80005698:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000569a:	02054463          	bltz	a0,800056c2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000569e:	ffffc097          	auipc	ra,0xffffc
    800056a2:	2e0080e7          	jalr	736(ra) # 8000197e <myproc>
    800056a6:	fec42783          	lw	a5,-20(s0)
    800056aa:	07e9                	addi	a5,a5,26
    800056ac:	078e                	slli	a5,a5,0x3
    800056ae:	97aa                	add	a5,a5,a0
    800056b0:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800056b4:	fe043503          	ld	a0,-32(s0)
    800056b8:	fffff097          	auipc	ra,0xfffff
    800056bc:	2a2080e7          	jalr	674(ra) # 8000495a <fileclose>
  return 0;
    800056c0:	4781                	li	a5,0
}
    800056c2:	853e                	mv	a0,a5
    800056c4:	60e2                	ld	ra,24(sp)
    800056c6:	6442                	ld	s0,16(sp)
    800056c8:	6105                	addi	sp,sp,32
    800056ca:	8082                	ret

00000000800056cc <sys_fstat>:
{
    800056cc:	1101                	addi	sp,sp,-32
    800056ce:	ec06                	sd	ra,24(sp)
    800056d0:	e822                	sd	s0,16(sp)
    800056d2:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056d4:	fe840613          	addi	a2,s0,-24
    800056d8:	4581                	li	a1,0
    800056da:	4501                	li	a0,0
    800056dc:	00000097          	auipc	ra,0x0
    800056e0:	c78080e7          	jalr	-904(ra) # 80005354 <argfd>
    return -1;
    800056e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056e6:	02054563          	bltz	a0,80005710 <sys_fstat+0x44>
    800056ea:	fe040593          	addi	a1,s0,-32
    800056ee:	4505                	li	a0,1
    800056f0:	ffffd097          	auipc	ra,0xffffd
    800056f4:	710080e7          	jalr	1808(ra) # 80002e00 <argaddr>
    return -1;
    800056f8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056fa:	00054b63          	bltz	a0,80005710 <sys_fstat+0x44>
  return filestat(f, st);
    800056fe:	fe043583          	ld	a1,-32(s0)
    80005702:	fe843503          	ld	a0,-24(s0)
    80005706:	fffff097          	auipc	ra,0xfffff
    8000570a:	31c080e7          	jalr	796(ra) # 80004a22 <filestat>
    8000570e:	87aa                	mv	a5,a0
}
    80005710:	853e                	mv	a0,a5
    80005712:	60e2                	ld	ra,24(sp)
    80005714:	6442                	ld	s0,16(sp)
    80005716:	6105                	addi	sp,sp,32
    80005718:	8082                	ret

000000008000571a <sys_link>:
{
    8000571a:	7169                	addi	sp,sp,-304
    8000571c:	f606                	sd	ra,296(sp)
    8000571e:	f222                	sd	s0,288(sp)
    80005720:	ee26                	sd	s1,280(sp)
    80005722:	ea4a                	sd	s2,272(sp)
    80005724:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005726:	08000613          	li	a2,128
    8000572a:	ed040593          	addi	a1,s0,-304
    8000572e:	4501                	li	a0,0
    80005730:	ffffd097          	auipc	ra,0xffffd
    80005734:	6f2080e7          	jalr	1778(ra) # 80002e22 <argstr>
    return -1;
    80005738:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000573a:	10054e63          	bltz	a0,80005856 <sys_link+0x13c>
    8000573e:	08000613          	li	a2,128
    80005742:	f5040593          	addi	a1,s0,-176
    80005746:	4505                	li	a0,1
    80005748:	ffffd097          	auipc	ra,0xffffd
    8000574c:	6da080e7          	jalr	1754(ra) # 80002e22 <argstr>
    return -1;
    80005750:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005752:	10054263          	bltz	a0,80005856 <sys_link+0x13c>
  begin_op();
    80005756:	fffff097          	auipc	ra,0xfffff
    8000575a:	d38080e7          	jalr	-712(ra) # 8000448e <begin_op>
  if((ip = namei(old)) == 0){
    8000575e:	ed040513          	addi	a0,s0,-304
    80005762:	fffff097          	auipc	ra,0xfffff
    80005766:	b0c080e7          	jalr	-1268(ra) # 8000426e <namei>
    8000576a:	84aa                	mv	s1,a0
    8000576c:	c551                	beqz	a0,800057f8 <sys_link+0xde>
  ilock(ip);
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	34a080e7          	jalr	842(ra) # 80003ab8 <ilock>
  if(ip->type == T_DIR){
    80005776:	04449703          	lh	a4,68(s1)
    8000577a:	4785                	li	a5,1
    8000577c:	08f70463          	beq	a4,a5,80005804 <sys_link+0xea>
  ip->nlink++;
    80005780:	04a4d783          	lhu	a5,74(s1)
    80005784:	2785                	addiw	a5,a5,1
    80005786:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000578a:	8526                	mv	a0,s1
    8000578c:	ffffe097          	auipc	ra,0xffffe
    80005790:	262080e7          	jalr	610(ra) # 800039ee <iupdate>
  iunlock(ip);
    80005794:	8526                	mv	a0,s1
    80005796:	ffffe097          	auipc	ra,0xffffe
    8000579a:	3e4080e7          	jalr	996(ra) # 80003b7a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000579e:	fd040593          	addi	a1,s0,-48
    800057a2:	f5040513          	addi	a0,s0,-176
    800057a6:	fffff097          	auipc	ra,0xfffff
    800057aa:	ae6080e7          	jalr	-1306(ra) # 8000428c <nameiparent>
    800057ae:	892a                	mv	s2,a0
    800057b0:	c935                	beqz	a0,80005824 <sys_link+0x10a>
  ilock(dp);
    800057b2:	ffffe097          	auipc	ra,0xffffe
    800057b6:	306080e7          	jalr	774(ra) # 80003ab8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800057ba:	00092703          	lw	a4,0(s2)
    800057be:	409c                	lw	a5,0(s1)
    800057c0:	04f71d63          	bne	a4,a5,8000581a <sys_link+0x100>
    800057c4:	40d0                	lw	a2,4(s1)
    800057c6:	fd040593          	addi	a1,s0,-48
    800057ca:	854a                	mv	a0,s2
    800057cc:	fffff097          	auipc	ra,0xfffff
    800057d0:	9e0080e7          	jalr	-1568(ra) # 800041ac <dirlink>
    800057d4:	04054363          	bltz	a0,8000581a <sys_link+0x100>
  iunlockput(dp);
    800057d8:	854a                	mv	a0,s2
    800057da:	ffffe097          	auipc	ra,0xffffe
    800057de:	540080e7          	jalr	1344(ra) # 80003d1a <iunlockput>
  iput(ip);
    800057e2:	8526                	mv	a0,s1
    800057e4:	ffffe097          	auipc	ra,0xffffe
    800057e8:	48e080e7          	jalr	1166(ra) # 80003c72 <iput>
  end_op();
    800057ec:	fffff097          	auipc	ra,0xfffff
    800057f0:	d22080e7          	jalr	-734(ra) # 8000450e <end_op>
  return 0;
    800057f4:	4781                	li	a5,0
    800057f6:	a085                	j	80005856 <sys_link+0x13c>
    end_op();
    800057f8:	fffff097          	auipc	ra,0xfffff
    800057fc:	d16080e7          	jalr	-746(ra) # 8000450e <end_op>
    return -1;
    80005800:	57fd                	li	a5,-1
    80005802:	a891                	j	80005856 <sys_link+0x13c>
    iunlockput(ip);
    80005804:	8526                	mv	a0,s1
    80005806:	ffffe097          	auipc	ra,0xffffe
    8000580a:	514080e7          	jalr	1300(ra) # 80003d1a <iunlockput>
    end_op();
    8000580e:	fffff097          	auipc	ra,0xfffff
    80005812:	d00080e7          	jalr	-768(ra) # 8000450e <end_op>
    return -1;
    80005816:	57fd                	li	a5,-1
    80005818:	a83d                	j	80005856 <sys_link+0x13c>
    iunlockput(dp);
    8000581a:	854a                	mv	a0,s2
    8000581c:	ffffe097          	auipc	ra,0xffffe
    80005820:	4fe080e7          	jalr	1278(ra) # 80003d1a <iunlockput>
  ilock(ip);
    80005824:	8526                	mv	a0,s1
    80005826:	ffffe097          	auipc	ra,0xffffe
    8000582a:	292080e7          	jalr	658(ra) # 80003ab8 <ilock>
  ip->nlink--;
    8000582e:	04a4d783          	lhu	a5,74(s1)
    80005832:	37fd                	addiw	a5,a5,-1
    80005834:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005838:	8526                	mv	a0,s1
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	1b4080e7          	jalr	436(ra) # 800039ee <iupdate>
  iunlockput(ip);
    80005842:	8526                	mv	a0,s1
    80005844:	ffffe097          	auipc	ra,0xffffe
    80005848:	4d6080e7          	jalr	1238(ra) # 80003d1a <iunlockput>
  end_op();
    8000584c:	fffff097          	auipc	ra,0xfffff
    80005850:	cc2080e7          	jalr	-830(ra) # 8000450e <end_op>
  return -1;
    80005854:	57fd                	li	a5,-1
}
    80005856:	853e                	mv	a0,a5
    80005858:	70b2                	ld	ra,296(sp)
    8000585a:	7412                	ld	s0,288(sp)
    8000585c:	64f2                	ld	s1,280(sp)
    8000585e:	6952                	ld	s2,272(sp)
    80005860:	6155                	addi	sp,sp,304
    80005862:	8082                	ret

0000000080005864 <sys_unlink>:
{
    80005864:	7151                	addi	sp,sp,-240
    80005866:	f586                	sd	ra,232(sp)
    80005868:	f1a2                	sd	s0,224(sp)
    8000586a:	eda6                	sd	s1,216(sp)
    8000586c:	e9ca                	sd	s2,208(sp)
    8000586e:	e5ce                	sd	s3,200(sp)
    80005870:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005872:	08000613          	li	a2,128
    80005876:	f3040593          	addi	a1,s0,-208
    8000587a:	4501                	li	a0,0
    8000587c:	ffffd097          	auipc	ra,0xffffd
    80005880:	5a6080e7          	jalr	1446(ra) # 80002e22 <argstr>
    80005884:	18054163          	bltz	a0,80005a06 <sys_unlink+0x1a2>
  begin_op();
    80005888:	fffff097          	auipc	ra,0xfffff
    8000588c:	c06080e7          	jalr	-1018(ra) # 8000448e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005890:	fb040593          	addi	a1,s0,-80
    80005894:	f3040513          	addi	a0,s0,-208
    80005898:	fffff097          	auipc	ra,0xfffff
    8000589c:	9f4080e7          	jalr	-1548(ra) # 8000428c <nameiparent>
    800058a0:	84aa                	mv	s1,a0
    800058a2:	c979                	beqz	a0,80005978 <sys_unlink+0x114>
  ilock(dp);
    800058a4:	ffffe097          	auipc	ra,0xffffe
    800058a8:	214080e7          	jalr	532(ra) # 80003ab8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800058ac:	00003597          	auipc	a1,0x3
    800058b0:	f6c58593          	addi	a1,a1,-148 # 80008818 <syscalls+0x2c0>
    800058b4:	fb040513          	addi	a0,s0,-80
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	6ca080e7          	jalr	1738(ra) # 80003f82 <namecmp>
    800058c0:	14050a63          	beqz	a0,80005a14 <sys_unlink+0x1b0>
    800058c4:	00003597          	auipc	a1,0x3
    800058c8:	f5c58593          	addi	a1,a1,-164 # 80008820 <syscalls+0x2c8>
    800058cc:	fb040513          	addi	a0,s0,-80
    800058d0:	ffffe097          	auipc	ra,0xffffe
    800058d4:	6b2080e7          	jalr	1714(ra) # 80003f82 <namecmp>
    800058d8:	12050e63          	beqz	a0,80005a14 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800058dc:	f2c40613          	addi	a2,s0,-212
    800058e0:	fb040593          	addi	a1,s0,-80
    800058e4:	8526                	mv	a0,s1
    800058e6:	ffffe097          	auipc	ra,0xffffe
    800058ea:	6b6080e7          	jalr	1718(ra) # 80003f9c <dirlookup>
    800058ee:	892a                	mv	s2,a0
    800058f0:	12050263          	beqz	a0,80005a14 <sys_unlink+0x1b0>
  ilock(ip);
    800058f4:	ffffe097          	auipc	ra,0xffffe
    800058f8:	1c4080e7          	jalr	452(ra) # 80003ab8 <ilock>
  if(ip->nlink < 1)
    800058fc:	04a91783          	lh	a5,74(s2)
    80005900:	08f05263          	blez	a5,80005984 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005904:	04491703          	lh	a4,68(s2)
    80005908:	4785                	li	a5,1
    8000590a:	08f70563          	beq	a4,a5,80005994 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000590e:	4641                	li	a2,16
    80005910:	4581                	li	a1,0
    80005912:	fc040513          	addi	a0,s0,-64
    80005916:	ffffb097          	auipc	ra,0xffffb
    8000591a:	3a8080e7          	jalr	936(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000591e:	4741                	li	a4,16
    80005920:	f2c42683          	lw	a3,-212(s0)
    80005924:	fc040613          	addi	a2,s0,-64
    80005928:	4581                	li	a1,0
    8000592a:	8526                	mv	a0,s1
    8000592c:	ffffe097          	auipc	ra,0xffffe
    80005930:	538080e7          	jalr	1336(ra) # 80003e64 <writei>
    80005934:	47c1                	li	a5,16
    80005936:	0af51563          	bne	a0,a5,800059e0 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000593a:	04491703          	lh	a4,68(s2)
    8000593e:	4785                	li	a5,1
    80005940:	0af70863          	beq	a4,a5,800059f0 <sys_unlink+0x18c>
  iunlockput(dp);
    80005944:	8526                	mv	a0,s1
    80005946:	ffffe097          	auipc	ra,0xffffe
    8000594a:	3d4080e7          	jalr	980(ra) # 80003d1a <iunlockput>
  ip->nlink--;
    8000594e:	04a95783          	lhu	a5,74(s2)
    80005952:	37fd                	addiw	a5,a5,-1
    80005954:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005958:	854a                	mv	a0,s2
    8000595a:	ffffe097          	auipc	ra,0xffffe
    8000595e:	094080e7          	jalr	148(ra) # 800039ee <iupdate>
  iunlockput(ip);
    80005962:	854a                	mv	a0,s2
    80005964:	ffffe097          	auipc	ra,0xffffe
    80005968:	3b6080e7          	jalr	950(ra) # 80003d1a <iunlockput>
  end_op();
    8000596c:	fffff097          	auipc	ra,0xfffff
    80005970:	ba2080e7          	jalr	-1118(ra) # 8000450e <end_op>
  return 0;
    80005974:	4501                	li	a0,0
    80005976:	a84d                	j	80005a28 <sys_unlink+0x1c4>
    end_op();
    80005978:	fffff097          	auipc	ra,0xfffff
    8000597c:	b96080e7          	jalr	-1130(ra) # 8000450e <end_op>
    return -1;
    80005980:	557d                	li	a0,-1
    80005982:	a05d                	j	80005a28 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005984:	00003517          	auipc	a0,0x3
    80005988:	ec450513          	addi	a0,a0,-316 # 80008848 <syscalls+0x2f0>
    8000598c:	ffffb097          	auipc	ra,0xffffb
    80005990:	b9e080e7          	jalr	-1122(ra) # 8000052a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005994:	04c92703          	lw	a4,76(s2)
    80005998:	02000793          	li	a5,32
    8000599c:	f6e7f9e3          	bgeu	a5,a4,8000590e <sys_unlink+0xaa>
    800059a0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059a4:	4741                	li	a4,16
    800059a6:	86ce                	mv	a3,s3
    800059a8:	f1840613          	addi	a2,s0,-232
    800059ac:	4581                	li	a1,0
    800059ae:	854a                	mv	a0,s2
    800059b0:	ffffe097          	auipc	ra,0xffffe
    800059b4:	3bc080e7          	jalr	956(ra) # 80003d6c <readi>
    800059b8:	47c1                	li	a5,16
    800059ba:	00f51b63          	bne	a0,a5,800059d0 <sys_unlink+0x16c>
    if(de.inum != 0)
    800059be:	f1845783          	lhu	a5,-232(s0)
    800059c2:	e7a1                	bnez	a5,80005a0a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059c4:	29c1                	addiw	s3,s3,16
    800059c6:	04c92783          	lw	a5,76(s2)
    800059ca:	fcf9ede3          	bltu	s3,a5,800059a4 <sys_unlink+0x140>
    800059ce:	b781                	j	8000590e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800059d0:	00003517          	auipc	a0,0x3
    800059d4:	e9050513          	addi	a0,a0,-368 # 80008860 <syscalls+0x308>
    800059d8:	ffffb097          	auipc	ra,0xffffb
    800059dc:	b52080e7          	jalr	-1198(ra) # 8000052a <panic>
    panic("unlink: writei");
    800059e0:	00003517          	auipc	a0,0x3
    800059e4:	e9850513          	addi	a0,a0,-360 # 80008878 <syscalls+0x320>
    800059e8:	ffffb097          	auipc	ra,0xffffb
    800059ec:	b42080e7          	jalr	-1214(ra) # 8000052a <panic>
    dp->nlink--;
    800059f0:	04a4d783          	lhu	a5,74(s1)
    800059f4:	37fd                	addiw	a5,a5,-1
    800059f6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800059fa:	8526                	mv	a0,s1
    800059fc:	ffffe097          	auipc	ra,0xffffe
    80005a00:	ff2080e7          	jalr	-14(ra) # 800039ee <iupdate>
    80005a04:	b781                	j	80005944 <sys_unlink+0xe0>
    return -1;
    80005a06:	557d                	li	a0,-1
    80005a08:	a005                	j	80005a28 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005a0a:	854a                	mv	a0,s2
    80005a0c:	ffffe097          	auipc	ra,0xffffe
    80005a10:	30e080e7          	jalr	782(ra) # 80003d1a <iunlockput>
  iunlockput(dp);
    80005a14:	8526                	mv	a0,s1
    80005a16:	ffffe097          	auipc	ra,0xffffe
    80005a1a:	304080e7          	jalr	772(ra) # 80003d1a <iunlockput>
  end_op();
    80005a1e:	fffff097          	auipc	ra,0xfffff
    80005a22:	af0080e7          	jalr	-1296(ra) # 8000450e <end_op>
  return -1;
    80005a26:	557d                	li	a0,-1
}
    80005a28:	70ae                	ld	ra,232(sp)
    80005a2a:	740e                	ld	s0,224(sp)
    80005a2c:	64ee                	ld	s1,216(sp)
    80005a2e:	694e                	ld	s2,208(sp)
    80005a30:	69ae                	ld	s3,200(sp)
    80005a32:	616d                	addi	sp,sp,240
    80005a34:	8082                	ret

0000000080005a36 <sys_open>:

uint64
sys_open(void)
{
    80005a36:	7131                	addi	sp,sp,-192
    80005a38:	fd06                	sd	ra,184(sp)
    80005a3a:	f922                	sd	s0,176(sp)
    80005a3c:	f526                	sd	s1,168(sp)
    80005a3e:	f14a                	sd	s2,160(sp)
    80005a40:	ed4e                	sd	s3,152(sp)
    80005a42:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a44:	08000613          	li	a2,128
    80005a48:	f5040593          	addi	a1,s0,-176
    80005a4c:	4501                	li	a0,0
    80005a4e:	ffffd097          	auipc	ra,0xffffd
    80005a52:	3d4080e7          	jalr	980(ra) # 80002e22 <argstr>
    return -1;
    80005a56:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a58:	0c054163          	bltz	a0,80005b1a <sys_open+0xe4>
    80005a5c:	f4c40593          	addi	a1,s0,-180
    80005a60:	4505                	li	a0,1
    80005a62:	ffffd097          	auipc	ra,0xffffd
    80005a66:	37c080e7          	jalr	892(ra) # 80002dde <argint>
    80005a6a:	0a054863          	bltz	a0,80005b1a <sys_open+0xe4>

  begin_op();
    80005a6e:	fffff097          	auipc	ra,0xfffff
    80005a72:	a20080e7          	jalr	-1504(ra) # 8000448e <begin_op>

  if(omode & O_CREATE){
    80005a76:	f4c42783          	lw	a5,-180(s0)
    80005a7a:	2007f793          	andi	a5,a5,512
    80005a7e:	cbdd                	beqz	a5,80005b34 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005a80:	4681                	li	a3,0
    80005a82:	4601                	li	a2,0
    80005a84:	4589                	li	a1,2
    80005a86:	f5040513          	addi	a0,s0,-176
    80005a8a:	00000097          	auipc	ra,0x0
    80005a8e:	974080e7          	jalr	-1676(ra) # 800053fe <create>
    80005a92:	892a                	mv	s2,a0
    if(ip == 0){
    80005a94:	c959                	beqz	a0,80005b2a <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a96:	04491703          	lh	a4,68(s2)
    80005a9a:	478d                	li	a5,3
    80005a9c:	00f71763          	bne	a4,a5,80005aaa <sys_open+0x74>
    80005aa0:	04695703          	lhu	a4,70(s2)
    80005aa4:	47a5                	li	a5,9
    80005aa6:	0ce7ec63          	bltu	a5,a4,80005b7e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005aaa:	fffff097          	auipc	ra,0xfffff
    80005aae:	df4080e7          	jalr	-524(ra) # 8000489e <filealloc>
    80005ab2:	89aa                	mv	s3,a0
    80005ab4:	10050263          	beqz	a0,80005bb8 <sys_open+0x182>
    80005ab8:	00000097          	auipc	ra,0x0
    80005abc:	904080e7          	jalr	-1788(ra) # 800053bc <fdalloc>
    80005ac0:	84aa                	mv	s1,a0
    80005ac2:	0e054663          	bltz	a0,80005bae <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ac6:	04491703          	lh	a4,68(s2)
    80005aca:	478d                	li	a5,3
    80005acc:	0cf70463          	beq	a4,a5,80005b94 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ad0:	4789                	li	a5,2
    80005ad2:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005ad6:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005ada:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005ade:	f4c42783          	lw	a5,-180(s0)
    80005ae2:	0017c713          	xori	a4,a5,1
    80005ae6:	8b05                	andi	a4,a4,1
    80005ae8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005aec:	0037f713          	andi	a4,a5,3
    80005af0:	00e03733          	snez	a4,a4
    80005af4:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005af8:	4007f793          	andi	a5,a5,1024
    80005afc:	c791                	beqz	a5,80005b08 <sys_open+0xd2>
    80005afe:	04491703          	lh	a4,68(s2)
    80005b02:	4789                	li	a5,2
    80005b04:	08f70f63          	beq	a4,a5,80005ba2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b08:	854a                	mv	a0,s2
    80005b0a:	ffffe097          	auipc	ra,0xffffe
    80005b0e:	070080e7          	jalr	112(ra) # 80003b7a <iunlock>
  end_op();
    80005b12:	fffff097          	auipc	ra,0xfffff
    80005b16:	9fc080e7          	jalr	-1540(ra) # 8000450e <end_op>

  return fd;
}
    80005b1a:	8526                	mv	a0,s1
    80005b1c:	70ea                	ld	ra,184(sp)
    80005b1e:	744a                	ld	s0,176(sp)
    80005b20:	74aa                	ld	s1,168(sp)
    80005b22:	790a                	ld	s2,160(sp)
    80005b24:	69ea                	ld	s3,152(sp)
    80005b26:	6129                	addi	sp,sp,192
    80005b28:	8082                	ret
      end_op();
    80005b2a:	fffff097          	auipc	ra,0xfffff
    80005b2e:	9e4080e7          	jalr	-1564(ra) # 8000450e <end_op>
      return -1;
    80005b32:	b7e5                	j	80005b1a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005b34:	f5040513          	addi	a0,s0,-176
    80005b38:	ffffe097          	auipc	ra,0xffffe
    80005b3c:	736080e7          	jalr	1846(ra) # 8000426e <namei>
    80005b40:	892a                	mv	s2,a0
    80005b42:	c905                	beqz	a0,80005b72 <sys_open+0x13c>
    ilock(ip);
    80005b44:	ffffe097          	auipc	ra,0xffffe
    80005b48:	f74080e7          	jalr	-140(ra) # 80003ab8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b4c:	04491703          	lh	a4,68(s2)
    80005b50:	4785                	li	a5,1
    80005b52:	f4f712e3          	bne	a4,a5,80005a96 <sys_open+0x60>
    80005b56:	f4c42783          	lw	a5,-180(s0)
    80005b5a:	dba1                	beqz	a5,80005aaa <sys_open+0x74>
      iunlockput(ip);
    80005b5c:	854a                	mv	a0,s2
    80005b5e:	ffffe097          	auipc	ra,0xffffe
    80005b62:	1bc080e7          	jalr	444(ra) # 80003d1a <iunlockput>
      end_op();
    80005b66:	fffff097          	auipc	ra,0xfffff
    80005b6a:	9a8080e7          	jalr	-1624(ra) # 8000450e <end_op>
      return -1;
    80005b6e:	54fd                	li	s1,-1
    80005b70:	b76d                	j	80005b1a <sys_open+0xe4>
      end_op();
    80005b72:	fffff097          	auipc	ra,0xfffff
    80005b76:	99c080e7          	jalr	-1636(ra) # 8000450e <end_op>
      return -1;
    80005b7a:	54fd                	li	s1,-1
    80005b7c:	bf79                	j	80005b1a <sys_open+0xe4>
    iunlockput(ip);
    80005b7e:	854a                	mv	a0,s2
    80005b80:	ffffe097          	auipc	ra,0xffffe
    80005b84:	19a080e7          	jalr	410(ra) # 80003d1a <iunlockput>
    end_op();
    80005b88:	fffff097          	auipc	ra,0xfffff
    80005b8c:	986080e7          	jalr	-1658(ra) # 8000450e <end_op>
    return -1;
    80005b90:	54fd                	li	s1,-1
    80005b92:	b761                	j	80005b1a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005b94:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005b98:	04691783          	lh	a5,70(s2)
    80005b9c:	02f99223          	sh	a5,36(s3)
    80005ba0:	bf2d                	j	80005ada <sys_open+0xa4>
    itrunc(ip);
    80005ba2:	854a                	mv	a0,s2
    80005ba4:	ffffe097          	auipc	ra,0xffffe
    80005ba8:	022080e7          	jalr	34(ra) # 80003bc6 <itrunc>
    80005bac:	bfb1                	j	80005b08 <sys_open+0xd2>
      fileclose(f);
    80005bae:	854e                	mv	a0,s3
    80005bb0:	fffff097          	auipc	ra,0xfffff
    80005bb4:	daa080e7          	jalr	-598(ra) # 8000495a <fileclose>
    iunlockput(ip);
    80005bb8:	854a                	mv	a0,s2
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	160080e7          	jalr	352(ra) # 80003d1a <iunlockput>
    end_op();
    80005bc2:	fffff097          	auipc	ra,0xfffff
    80005bc6:	94c080e7          	jalr	-1716(ra) # 8000450e <end_op>
    return -1;
    80005bca:	54fd                	li	s1,-1
    80005bcc:	b7b9                	j	80005b1a <sys_open+0xe4>

0000000080005bce <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005bce:	7175                	addi	sp,sp,-144
    80005bd0:	e506                	sd	ra,136(sp)
    80005bd2:	e122                	sd	s0,128(sp)
    80005bd4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005bd6:	fffff097          	auipc	ra,0xfffff
    80005bda:	8b8080e7          	jalr	-1864(ra) # 8000448e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005bde:	08000613          	li	a2,128
    80005be2:	f7040593          	addi	a1,s0,-144
    80005be6:	4501                	li	a0,0
    80005be8:	ffffd097          	auipc	ra,0xffffd
    80005bec:	23a080e7          	jalr	570(ra) # 80002e22 <argstr>
    80005bf0:	02054963          	bltz	a0,80005c22 <sys_mkdir+0x54>
    80005bf4:	4681                	li	a3,0
    80005bf6:	4601                	li	a2,0
    80005bf8:	4585                	li	a1,1
    80005bfa:	f7040513          	addi	a0,s0,-144
    80005bfe:	00000097          	auipc	ra,0x0
    80005c02:	800080e7          	jalr	-2048(ra) # 800053fe <create>
    80005c06:	cd11                	beqz	a0,80005c22 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c08:	ffffe097          	auipc	ra,0xffffe
    80005c0c:	112080e7          	jalr	274(ra) # 80003d1a <iunlockput>
  end_op();
    80005c10:	fffff097          	auipc	ra,0xfffff
    80005c14:	8fe080e7          	jalr	-1794(ra) # 8000450e <end_op>
  return 0;
    80005c18:	4501                	li	a0,0
}
    80005c1a:	60aa                	ld	ra,136(sp)
    80005c1c:	640a                	ld	s0,128(sp)
    80005c1e:	6149                	addi	sp,sp,144
    80005c20:	8082                	ret
    end_op();
    80005c22:	fffff097          	auipc	ra,0xfffff
    80005c26:	8ec080e7          	jalr	-1812(ra) # 8000450e <end_op>
    return -1;
    80005c2a:	557d                	li	a0,-1
    80005c2c:	b7fd                	j	80005c1a <sys_mkdir+0x4c>

0000000080005c2e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c2e:	7135                	addi	sp,sp,-160
    80005c30:	ed06                	sd	ra,152(sp)
    80005c32:	e922                	sd	s0,144(sp)
    80005c34:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c36:	fffff097          	auipc	ra,0xfffff
    80005c3a:	858080e7          	jalr	-1960(ra) # 8000448e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c3e:	08000613          	li	a2,128
    80005c42:	f7040593          	addi	a1,s0,-144
    80005c46:	4501                	li	a0,0
    80005c48:	ffffd097          	auipc	ra,0xffffd
    80005c4c:	1da080e7          	jalr	474(ra) # 80002e22 <argstr>
    80005c50:	04054a63          	bltz	a0,80005ca4 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005c54:	f6c40593          	addi	a1,s0,-148
    80005c58:	4505                	li	a0,1
    80005c5a:	ffffd097          	auipc	ra,0xffffd
    80005c5e:	184080e7          	jalr	388(ra) # 80002dde <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c62:	04054163          	bltz	a0,80005ca4 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005c66:	f6840593          	addi	a1,s0,-152
    80005c6a:	4509                	li	a0,2
    80005c6c:	ffffd097          	auipc	ra,0xffffd
    80005c70:	172080e7          	jalr	370(ra) # 80002dde <argint>
     argint(1, &major) < 0 ||
    80005c74:	02054863          	bltz	a0,80005ca4 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c78:	f6841683          	lh	a3,-152(s0)
    80005c7c:	f6c41603          	lh	a2,-148(s0)
    80005c80:	458d                	li	a1,3
    80005c82:	f7040513          	addi	a0,s0,-144
    80005c86:	fffff097          	auipc	ra,0xfffff
    80005c8a:	778080e7          	jalr	1912(ra) # 800053fe <create>
     argint(2, &minor) < 0 ||
    80005c8e:	c919                	beqz	a0,80005ca4 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c90:	ffffe097          	auipc	ra,0xffffe
    80005c94:	08a080e7          	jalr	138(ra) # 80003d1a <iunlockput>
  end_op();
    80005c98:	fffff097          	auipc	ra,0xfffff
    80005c9c:	876080e7          	jalr	-1930(ra) # 8000450e <end_op>
  return 0;
    80005ca0:	4501                	li	a0,0
    80005ca2:	a031                	j	80005cae <sys_mknod+0x80>
    end_op();
    80005ca4:	fffff097          	auipc	ra,0xfffff
    80005ca8:	86a080e7          	jalr	-1942(ra) # 8000450e <end_op>
    return -1;
    80005cac:	557d                	li	a0,-1
}
    80005cae:	60ea                	ld	ra,152(sp)
    80005cb0:	644a                	ld	s0,144(sp)
    80005cb2:	610d                	addi	sp,sp,160
    80005cb4:	8082                	ret

0000000080005cb6 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005cb6:	7135                	addi	sp,sp,-160
    80005cb8:	ed06                	sd	ra,152(sp)
    80005cba:	e922                	sd	s0,144(sp)
    80005cbc:	e526                	sd	s1,136(sp)
    80005cbe:	e14a                	sd	s2,128(sp)
    80005cc0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005cc2:	ffffc097          	auipc	ra,0xffffc
    80005cc6:	cbc080e7          	jalr	-836(ra) # 8000197e <myproc>
    80005cca:	892a                	mv	s2,a0
  
  begin_op();
    80005ccc:	ffffe097          	auipc	ra,0xffffe
    80005cd0:	7c2080e7          	jalr	1986(ra) # 8000448e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005cd4:	08000613          	li	a2,128
    80005cd8:	f6040593          	addi	a1,s0,-160
    80005cdc:	4501                	li	a0,0
    80005cde:	ffffd097          	auipc	ra,0xffffd
    80005ce2:	144080e7          	jalr	324(ra) # 80002e22 <argstr>
    80005ce6:	04054b63          	bltz	a0,80005d3c <sys_chdir+0x86>
    80005cea:	f6040513          	addi	a0,s0,-160
    80005cee:	ffffe097          	auipc	ra,0xffffe
    80005cf2:	580080e7          	jalr	1408(ra) # 8000426e <namei>
    80005cf6:	84aa                	mv	s1,a0
    80005cf8:	c131                	beqz	a0,80005d3c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005cfa:	ffffe097          	auipc	ra,0xffffe
    80005cfe:	dbe080e7          	jalr	-578(ra) # 80003ab8 <ilock>
  if(ip->type != T_DIR){
    80005d02:	04449703          	lh	a4,68(s1)
    80005d06:	4785                	li	a5,1
    80005d08:	04f71063          	bne	a4,a5,80005d48 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d0c:	8526                	mv	a0,s1
    80005d0e:	ffffe097          	auipc	ra,0xffffe
    80005d12:	e6c080e7          	jalr	-404(ra) # 80003b7a <iunlock>
  iput(p->cwd);
    80005d16:	15093503          	ld	a0,336(s2)
    80005d1a:	ffffe097          	auipc	ra,0xffffe
    80005d1e:	f58080e7          	jalr	-168(ra) # 80003c72 <iput>
  end_op();
    80005d22:	ffffe097          	auipc	ra,0xffffe
    80005d26:	7ec080e7          	jalr	2028(ra) # 8000450e <end_op>
  p->cwd = ip;
    80005d2a:	14993823          	sd	s1,336(s2)
  return 0;
    80005d2e:	4501                	li	a0,0
}
    80005d30:	60ea                	ld	ra,152(sp)
    80005d32:	644a                	ld	s0,144(sp)
    80005d34:	64aa                	ld	s1,136(sp)
    80005d36:	690a                	ld	s2,128(sp)
    80005d38:	610d                	addi	sp,sp,160
    80005d3a:	8082                	ret
    end_op();
    80005d3c:	ffffe097          	auipc	ra,0xffffe
    80005d40:	7d2080e7          	jalr	2002(ra) # 8000450e <end_op>
    return -1;
    80005d44:	557d                	li	a0,-1
    80005d46:	b7ed                	j	80005d30 <sys_chdir+0x7a>
    iunlockput(ip);
    80005d48:	8526                	mv	a0,s1
    80005d4a:	ffffe097          	auipc	ra,0xffffe
    80005d4e:	fd0080e7          	jalr	-48(ra) # 80003d1a <iunlockput>
    end_op();
    80005d52:	ffffe097          	auipc	ra,0xffffe
    80005d56:	7bc080e7          	jalr	1980(ra) # 8000450e <end_op>
    return -1;
    80005d5a:	557d                	li	a0,-1
    80005d5c:	bfd1                	j	80005d30 <sys_chdir+0x7a>

0000000080005d5e <sys_exec>:

uint64
sys_exec(void)
{
    80005d5e:	7145                	addi	sp,sp,-464
    80005d60:	e786                	sd	ra,456(sp)
    80005d62:	e3a2                	sd	s0,448(sp)
    80005d64:	ff26                	sd	s1,440(sp)
    80005d66:	fb4a                	sd	s2,432(sp)
    80005d68:	f74e                	sd	s3,424(sp)
    80005d6a:	f352                	sd	s4,416(sp)
    80005d6c:	ef56                	sd	s5,408(sp)
    80005d6e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d70:	08000613          	li	a2,128
    80005d74:	f4040593          	addi	a1,s0,-192
    80005d78:	4501                	li	a0,0
    80005d7a:	ffffd097          	auipc	ra,0xffffd
    80005d7e:	0a8080e7          	jalr	168(ra) # 80002e22 <argstr>
    return -1;
    80005d82:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d84:	0c054a63          	bltz	a0,80005e58 <sys_exec+0xfa>
    80005d88:	e3840593          	addi	a1,s0,-456
    80005d8c:	4505                	li	a0,1
    80005d8e:	ffffd097          	auipc	ra,0xffffd
    80005d92:	072080e7          	jalr	114(ra) # 80002e00 <argaddr>
    80005d96:	0c054163          	bltz	a0,80005e58 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005d9a:	10000613          	li	a2,256
    80005d9e:	4581                	li	a1,0
    80005da0:	e4040513          	addi	a0,s0,-448
    80005da4:	ffffb097          	auipc	ra,0xffffb
    80005da8:	f1a080e7          	jalr	-230(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005dac:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005db0:	89a6                	mv	s3,s1
    80005db2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005db4:	02000a13          	li	s4,32
    80005db8:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005dbc:	00391793          	slli	a5,s2,0x3
    80005dc0:	e3040593          	addi	a1,s0,-464
    80005dc4:	e3843503          	ld	a0,-456(s0)
    80005dc8:	953e                	add	a0,a0,a5
    80005dca:	ffffd097          	auipc	ra,0xffffd
    80005dce:	f7a080e7          	jalr	-134(ra) # 80002d44 <fetchaddr>
    80005dd2:	02054a63          	bltz	a0,80005e06 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005dd6:	e3043783          	ld	a5,-464(s0)
    80005dda:	c3b9                	beqz	a5,80005e20 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ddc:	ffffb097          	auipc	ra,0xffffb
    80005de0:	cf6080e7          	jalr	-778(ra) # 80000ad2 <kalloc>
    80005de4:	85aa                	mv	a1,a0
    80005de6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005dea:	cd11                	beqz	a0,80005e06 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005dec:	6605                	lui	a2,0x1
    80005dee:	e3043503          	ld	a0,-464(s0)
    80005df2:	ffffd097          	auipc	ra,0xffffd
    80005df6:	fa4080e7          	jalr	-92(ra) # 80002d96 <fetchstr>
    80005dfa:	00054663          	bltz	a0,80005e06 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005dfe:	0905                	addi	s2,s2,1
    80005e00:	09a1                	addi	s3,s3,8
    80005e02:	fb491be3          	bne	s2,s4,80005db8 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e06:	10048913          	addi	s2,s1,256
    80005e0a:	6088                	ld	a0,0(s1)
    80005e0c:	c529                	beqz	a0,80005e56 <sys_exec+0xf8>
    kfree(argv[i]);
    80005e0e:	ffffb097          	auipc	ra,0xffffb
    80005e12:	bc8080e7          	jalr	-1080(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e16:	04a1                	addi	s1,s1,8
    80005e18:	ff2499e3          	bne	s1,s2,80005e0a <sys_exec+0xac>
  return -1;
    80005e1c:	597d                	li	s2,-1
    80005e1e:	a82d                	j	80005e58 <sys_exec+0xfa>
      argv[i] = 0;
    80005e20:	0a8e                	slli	s5,s5,0x3
    80005e22:	fc040793          	addi	a5,s0,-64
    80005e26:	9abe                	add	s5,s5,a5
    80005e28:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd8e80>
  int ret = exec(path, argv);
    80005e2c:	e4040593          	addi	a1,s0,-448
    80005e30:	f4040513          	addi	a0,s0,-192
    80005e34:	fffff097          	auipc	ra,0xfffff
    80005e38:	178080e7          	jalr	376(ra) # 80004fac <exec>
    80005e3c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e3e:	10048993          	addi	s3,s1,256
    80005e42:	6088                	ld	a0,0(s1)
    80005e44:	c911                	beqz	a0,80005e58 <sys_exec+0xfa>
    kfree(argv[i]);
    80005e46:	ffffb097          	auipc	ra,0xffffb
    80005e4a:	b90080e7          	jalr	-1136(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e4e:	04a1                	addi	s1,s1,8
    80005e50:	ff3499e3          	bne	s1,s3,80005e42 <sys_exec+0xe4>
    80005e54:	a011                	j	80005e58 <sys_exec+0xfa>
  return -1;
    80005e56:	597d                	li	s2,-1
}
    80005e58:	854a                	mv	a0,s2
    80005e5a:	60be                	ld	ra,456(sp)
    80005e5c:	641e                	ld	s0,448(sp)
    80005e5e:	74fa                	ld	s1,440(sp)
    80005e60:	795a                	ld	s2,432(sp)
    80005e62:	79ba                	ld	s3,424(sp)
    80005e64:	7a1a                	ld	s4,416(sp)
    80005e66:	6afa                	ld	s5,408(sp)
    80005e68:	6179                	addi	sp,sp,464
    80005e6a:	8082                	ret

0000000080005e6c <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e6c:	7139                	addi	sp,sp,-64
    80005e6e:	fc06                	sd	ra,56(sp)
    80005e70:	f822                	sd	s0,48(sp)
    80005e72:	f426                	sd	s1,40(sp)
    80005e74:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e76:	ffffc097          	auipc	ra,0xffffc
    80005e7a:	b08080e7          	jalr	-1272(ra) # 8000197e <myproc>
    80005e7e:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005e80:	fd840593          	addi	a1,s0,-40
    80005e84:	4501                	li	a0,0
    80005e86:	ffffd097          	auipc	ra,0xffffd
    80005e8a:	f7a080e7          	jalr	-134(ra) # 80002e00 <argaddr>
    return -1;
    80005e8e:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005e90:	0e054063          	bltz	a0,80005f70 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005e94:	fc840593          	addi	a1,s0,-56
    80005e98:	fd040513          	addi	a0,s0,-48
    80005e9c:	fffff097          	auipc	ra,0xfffff
    80005ea0:	dee080e7          	jalr	-530(ra) # 80004c8a <pipealloc>
    return -1;
    80005ea4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ea6:	0c054563          	bltz	a0,80005f70 <sys_pipe+0x104>
  fd0 = -1;
    80005eaa:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005eae:	fd043503          	ld	a0,-48(s0)
    80005eb2:	fffff097          	auipc	ra,0xfffff
    80005eb6:	50a080e7          	jalr	1290(ra) # 800053bc <fdalloc>
    80005eba:	fca42223          	sw	a0,-60(s0)
    80005ebe:	08054c63          	bltz	a0,80005f56 <sys_pipe+0xea>
    80005ec2:	fc843503          	ld	a0,-56(s0)
    80005ec6:	fffff097          	auipc	ra,0xfffff
    80005eca:	4f6080e7          	jalr	1270(ra) # 800053bc <fdalloc>
    80005ece:	fca42023          	sw	a0,-64(s0)
    80005ed2:	06054863          	bltz	a0,80005f42 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ed6:	4691                	li	a3,4
    80005ed8:	fc440613          	addi	a2,s0,-60
    80005edc:	fd843583          	ld	a1,-40(s0)
    80005ee0:	68a8                	ld	a0,80(s1)
    80005ee2:	ffffb097          	auipc	ra,0xffffb
    80005ee6:	75c080e7          	jalr	1884(ra) # 8000163e <copyout>
    80005eea:	02054063          	bltz	a0,80005f0a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005eee:	4691                	li	a3,4
    80005ef0:	fc040613          	addi	a2,s0,-64
    80005ef4:	fd843583          	ld	a1,-40(s0)
    80005ef8:	0591                	addi	a1,a1,4
    80005efa:	68a8                	ld	a0,80(s1)
    80005efc:	ffffb097          	auipc	ra,0xffffb
    80005f00:	742080e7          	jalr	1858(ra) # 8000163e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f04:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f06:	06055563          	bgez	a0,80005f70 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005f0a:	fc442783          	lw	a5,-60(s0)
    80005f0e:	07e9                	addi	a5,a5,26
    80005f10:	078e                	slli	a5,a5,0x3
    80005f12:	97a6                	add	a5,a5,s1
    80005f14:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f18:	fc042503          	lw	a0,-64(s0)
    80005f1c:	0569                	addi	a0,a0,26
    80005f1e:	050e                	slli	a0,a0,0x3
    80005f20:	9526                	add	a0,a0,s1
    80005f22:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005f26:	fd043503          	ld	a0,-48(s0)
    80005f2a:	fffff097          	auipc	ra,0xfffff
    80005f2e:	a30080e7          	jalr	-1488(ra) # 8000495a <fileclose>
    fileclose(wf);
    80005f32:	fc843503          	ld	a0,-56(s0)
    80005f36:	fffff097          	auipc	ra,0xfffff
    80005f3a:	a24080e7          	jalr	-1500(ra) # 8000495a <fileclose>
    return -1;
    80005f3e:	57fd                	li	a5,-1
    80005f40:	a805                	j	80005f70 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005f42:	fc442783          	lw	a5,-60(s0)
    80005f46:	0007c863          	bltz	a5,80005f56 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005f4a:	01a78513          	addi	a0,a5,26
    80005f4e:	050e                	slli	a0,a0,0x3
    80005f50:	9526                	add	a0,a0,s1
    80005f52:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005f56:	fd043503          	ld	a0,-48(s0)
    80005f5a:	fffff097          	auipc	ra,0xfffff
    80005f5e:	a00080e7          	jalr	-1536(ra) # 8000495a <fileclose>
    fileclose(wf);
    80005f62:	fc843503          	ld	a0,-56(s0)
    80005f66:	fffff097          	auipc	ra,0xfffff
    80005f6a:	9f4080e7          	jalr	-1548(ra) # 8000495a <fileclose>
    return -1;
    80005f6e:	57fd                	li	a5,-1
}
    80005f70:	853e                	mv	a0,a5
    80005f72:	70e2                	ld	ra,56(sp)
    80005f74:	7442                	ld	s0,48(sp)
    80005f76:	74a2                	ld	s1,40(sp)
    80005f78:	6121                	addi	sp,sp,64
    80005f7a:	8082                	ret
    80005f7c:	0000                	unimp
	...

0000000080005f80 <kernelvec>:
    80005f80:	7111                	addi	sp,sp,-256
    80005f82:	e006                	sd	ra,0(sp)
    80005f84:	e40a                	sd	sp,8(sp)
    80005f86:	e80e                	sd	gp,16(sp)
    80005f88:	ec12                	sd	tp,24(sp)
    80005f8a:	f016                	sd	t0,32(sp)
    80005f8c:	f41a                	sd	t1,40(sp)
    80005f8e:	f81e                	sd	t2,48(sp)
    80005f90:	fc22                	sd	s0,56(sp)
    80005f92:	e0a6                	sd	s1,64(sp)
    80005f94:	e4aa                	sd	a0,72(sp)
    80005f96:	e8ae                	sd	a1,80(sp)
    80005f98:	ecb2                	sd	a2,88(sp)
    80005f9a:	f0b6                	sd	a3,96(sp)
    80005f9c:	f4ba                	sd	a4,104(sp)
    80005f9e:	f8be                	sd	a5,112(sp)
    80005fa0:	fcc2                	sd	a6,120(sp)
    80005fa2:	e146                	sd	a7,128(sp)
    80005fa4:	e54a                	sd	s2,136(sp)
    80005fa6:	e94e                	sd	s3,144(sp)
    80005fa8:	ed52                	sd	s4,152(sp)
    80005faa:	f156                	sd	s5,160(sp)
    80005fac:	f55a                	sd	s6,168(sp)
    80005fae:	f95e                	sd	s7,176(sp)
    80005fb0:	fd62                	sd	s8,184(sp)
    80005fb2:	e1e6                	sd	s9,192(sp)
    80005fb4:	e5ea                	sd	s10,200(sp)
    80005fb6:	e9ee                	sd	s11,208(sp)
    80005fb8:	edf2                	sd	t3,216(sp)
    80005fba:	f1f6                	sd	t4,224(sp)
    80005fbc:	f5fa                	sd	t5,232(sp)
    80005fbe:	f9fe                	sd	t6,240(sp)
    80005fc0:	c7bfc0ef          	jal	ra,80002c3a <kerneltrap>
    80005fc4:	6082                	ld	ra,0(sp)
    80005fc6:	6122                	ld	sp,8(sp)
    80005fc8:	61c2                	ld	gp,16(sp)
    80005fca:	7282                	ld	t0,32(sp)
    80005fcc:	7322                	ld	t1,40(sp)
    80005fce:	73c2                	ld	t2,48(sp)
    80005fd0:	7462                	ld	s0,56(sp)
    80005fd2:	6486                	ld	s1,64(sp)
    80005fd4:	6526                	ld	a0,72(sp)
    80005fd6:	65c6                	ld	a1,80(sp)
    80005fd8:	6666                	ld	a2,88(sp)
    80005fda:	7686                	ld	a3,96(sp)
    80005fdc:	7726                	ld	a4,104(sp)
    80005fde:	77c6                	ld	a5,112(sp)
    80005fe0:	7866                	ld	a6,120(sp)
    80005fe2:	688a                	ld	a7,128(sp)
    80005fe4:	692a                	ld	s2,136(sp)
    80005fe6:	69ca                	ld	s3,144(sp)
    80005fe8:	6a6a                	ld	s4,152(sp)
    80005fea:	7a8a                	ld	s5,160(sp)
    80005fec:	7b2a                	ld	s6,168(sp)
    80005fee:	7bca                	ld	s7,176(sp)
    80005ff0:	7c6a                	ld	s8,184(sp)
    80005ff2:	6c8e                	ld	s9,192(sp)
    80005ff4:	6d2e                	ld	s10,200(sp)
    80005ff6:	6dce                	ld	s11,208(sp)
    80005ff8:	6e6e                	ld	t3,216(sp)
    80005ffa:	7e8e                	ld	t4,224(sp)
    80005ffc:	7f2e                	ld	t5,232(sp)
    80005ffe:	7fce                	ld	t6,240(sp)
    80006000:	6111                	addi	sp,sp,256
    80006002:	10200073          	sret
    80006006:	00000013          	nop
    8000600a:	00000013          	nop
    8000600e:	0001                	nop

0000000080006010 <timervec>:
    80006010:	34051573          	csrrw	a0,mscratch,a0
    80006014:	e10c                	sd	a1,0(a0)
    80006016:	e510                	sd	a2,8(a0)
    80006018:	e914                	sd	a3,16(a0)
    8000601a:	6d0c                	ld	a1,24(a0)
    8000601c:	7110                	ld	a2,32(a0)
    8000601e:	6194                	ld	a3,0(a1)
    80006020:	96b2                	add	a3,a3,a2
    80006022:	e194                	sd	a3,0(a1)
    80006024:	4589                	li	a1,2
    80006026:	14459073          	csrw	sip,a1
    8000602a:	6914                	ld	a3,16(a0)
    8000602c:	6510                	ld	a2,8(a0)
    8000602e:	610c                	ld	a1,0(a0)
    80006030:	34051573          	csrrw	a0,mscratch,a0
    80006034:	30200073          	mret
	...

000000008000603a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000603a:	1141                	addi	sp,sp,-16
    8000603c:	e422                	sd	s0,8(sp)
    8000603e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006040:	0c0007b7          	lui	a5,0xc000
    80006044:	4705                	li	a4,1
    80006046:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006048:	c3d8                	sw	a4,4(a5)
}
    8000604a:	6422                	ld	s0,8(sp)
    8000604c:	0141                	addi	sp,sp,16
    8000604e:	8082                	ret

0000000080006050 <plicinithart>:

void
plicinithart(void)
{
    80006050:	1141                	addi	sp,sp,-16
    80006052:	e406                	sd	ra,8(sp)
    80006054:	e022                	sd	s0,0(sp)
    80006056:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006058:	ffffc097          	auipc	ra,0xffffc
    8000605c:	8fa080e7          	jalr	-1798(ra) # 80001952 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006060:	0085171b          	slliw	a4,a0,0x8
    80006064:	0c0027b7          	lui	a5,0xc002
    80006068:	97ba                	add	a5,a5,a4
    8000606a:	40200713          	li	a4,1026
    8000606e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006072:	00d5151b          	slliw	a0,a0,0xd
    80006076:	0c2017b7          	lui	a5,0xc201
    8000607a:	953e                	add	a0,a0,a5
    8000607c:	00052023          	sw	zero,0(a0)
}
    80006080:	60a2                	ld	ra,8(sp)
    80006082:	6402                	ld	s0,0(sp)
    80006084:	0141                	addi	sp,sp,16
    80006086:	8082                	ret

0000000080006088 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006088:	1141                	addi	sp,sp,-16
    8000608a:	e406                	sd	ra,8(sp)
    8000608c:	e022                	sd	s0,0(sp)
    8000608e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006090:	ffffc097          	auipc	ra,0xffffc
    80006094:	8c2080e7          	jalr	-1854(ra) # 80001952 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006098:	00d5179b          	slliw	a5,a0,0xd
    8000609c:	0c201537          	lui	a0,0xc201
    800060a0:	953e                	add	a0,a0,a5
  return irq;
}
    800060a2:	4148                	lw	a0,4(a0)
    800060a4:	60a2                	ld	ra,8(sp)
    800060a6:	6402                	ld	s0,0(sp)
    800060a8:	0141                	addi	sp,sp,16
    800060aa:	8082                	ret

00000000800060ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800060ac:	1101                	addi	sp,sp,-32
    800060ae:	ec06                	sd	ra,24(sp)
    800060b0:	e822                	sd	s0,16(sp)
    800060b2:	e426                	sd	s1,8(sp)
    800060b4:	1000                	addi	s0,sp,32
    800060b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800060b8:	ffffc097          	auipc	ra,0xffffc
    800060bc:	89a080e7          	jalr	-1894(ra) # 80001952 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060c0:	00d5151b          	slliw	a0,a0,0xd
    800060c4:	0c2017b7          	lui	a5,0xc201
    800060c8:	97aa                	add	a5,a5,a0
    800060ca:	c3c4                	sw	s1,4(a5)
}
    800060cc:	60e2                	ld	ra,24(sp)
    800060ce:	6442                	ld	s0,16(sp)
    800060d0:	64a2                	ld	s1,8(sp)
    800060d2:	6105                	addi	sp,sp,32
    800060d4:	8082                	ret

00000000800060d6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060d6:	1141                	addi	sp,sp,-16
    800060d8:	e406                	sd	ra,8(sp)
    800060da:	e022                	sd	s0,0(sp)
    800060dc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800060de:	479d                	li	a5,7
    800060e0:	06a7c963          	blt	a5,a0,80006152 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800060e4:	0001d797          	auipc	a5,0x1d
    800060e8:	f1c78793          	addi	a5,a5,-228 # 80023000 <disk>
    800060ec:	00a78733          	add	a4,a5,a0
    800060f0:	6789                	lui	a5,0x2
    800060f2:	97ba                	add	a5,a5,a4
    800060f4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800060f8:	e7ad                	bnez	a5,80006162 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800060fa:	00451793          	slli	a5,a0,0x4
    800060fe:	0001f717          	auipc	a4,0x1f
    80006102:	f0270713          	addi	a4,a4,-254 # 80025000 <disk+0x2000>
    80006106:	6314                	ld	a3,0(a4)
    80006108:	96be                	add	a3,a3,a5
    8000610a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000610e:	6314                	ld	a3,0(a4)
    80006110:	96be                	add	a3,a3,a5
    80006112:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006116:	6314                	ld	a3,0(a4)
    80006118:	96be                	add	a3,a3,a5
    8000611a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000611e:	6318                	ld	a4,0(a4)
    80006120:	97ba                	add	a5,a5,a4
    80006122:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006126:	0001d797          	auipc	a5,0x1d
    8000612a:	eda78793          	addi	a5,a5,-294 # 80023000 <disk>
    8000612e:	97aa                	add	a5,a5,a0
    80006130:	6509                	lui	a0,0x2
    80006132:	953e                	add	a0,a0,a5
    80006134:	4785                	li	a5,1
    80006136:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000613a:	0001f517          	auipc	a0,0x1f
    8000613e:	ede50513          	addi	a0,a0,-290 # 80025018 <disk+0x2018>
    80006142:	ffffc097          	auipc	ra,0xffffc
    80006146:	3dc080e7          	jalr	988(ra) # 8000251e <wakeup>
}
    8000614a:	60a2                	ld	ra,8(sp)
    8000614c:	6402                	ld	s0,0(sp)
    8000614e:	0141                	addi	sp,sp,16
    80006150:	8082                	ret
    panic("free_desc 1");
    80006152:	00002517          	auipc	a0,0x2
    80006156:	73650513          	addi	a0,a0,1846 # 80008888 <syscalls+0x330>
    8000615a:	ffffa097          	auipc	ra,0xffffa
    8000615e:	3d0080e7          	jalr	976(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006162:	00002517          	auipc	a0,0x2
    80006166:	73650513          	addi	a0,a0,1846 # 80008898 <syscalls+0x340>
    8000616a:	ffffa097          	auipc	ra,0xffffa
    8000616e:	3c0080e7          	jalr	960(ra) # 8000052a <panic>

0000000080006172 <virtio_disk_init>:
{
    80006172:	1101                	addi	sp,sp,-32
    80006174:	ec06                	sd	ra,24(sp)
    80006176:	e822                	sd	s0,16(sp)
    80006178:	e426                	sd	s1,8(sp)
    8000617a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000617c:	00002597          	auipc	a1,0x2
    80006180:	72c58593          	addi	a1,a1,1836 # 800088a8 <syscalls+0x350>
    80006184:	0001f517          	auipc	a0,0x1f
    80006188:	fa450513          	addi	a0,a0,-92 # 80025128 <disk+0x2128>
    8000618c:	ffffb097          	auipc	ra,0xffffb
    80006190:	9a6080e7          	jalr	-1626(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006194:	100017b7          	lui	a5,0x10001
    80006198:	4398                	lw	a4,0(a5)
    8000619a:	2701                	sext.w	a4,a4
    8000619c:	747277b7          	lui	a5,0x74727
    800061a0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800061a4:	0ef71163          	bne	a4,a5,80006286 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800061a8:	100017b7          	lui	a5,0x10001
    800061ac:	43dc                	lw	a5,4(a5)
    800061ae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061b0:	4705                	li	a4,1
    800061b2:	0ce79a63          	bne	a5,a4,80006286 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061b6:	100017b7          	lui	a5,0x10001
    800061ba:	479c                	lw	a5,8(a5)
    800061bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800061be:	4709                	li	a4,2
    800061c0:	0ce79363          	bne	a5,a4,80006286 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800061c4:	100017b7          	lui	a5,0x10001
    800061c8:	47d8                	lw	a4,12(a5)
    800061ca:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061cc:	554d47b7          	lui	a5,0x554d4
    800061d0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061d4:	0af71963          	bne	a4,a5,80006286 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061d8:	100017b7          	lui	a5,0x10001
    800061dc:	4705                	li	a4,1
    800061de:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061e0:	470d                	li	a4,3
    800061e2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061e4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800061e6:	c7ffe737          	lui	a4,0xc7ffe
    800061ea:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    800061ee:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061f0:	2701                	sext.w	a4,a4
    800061f2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061f4:	472d                	li	a4,11
    800061f6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061f8:	473d                	li	a4,15
    800061fa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800061fc:	6705                	lui	a4,0x1
    800061fe:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006200:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006204:	5bdc                	lw	a5,52(a5)
    80006206:	2781                	sext.w	a5,a5
  if(max == 0)
    80006208:	c7d9                	beqz	a5,80006296 <virtio_disk_init+0x124>
  if(max < NUM)
    8000620a:	471d                	li	a4,7
    8000620c:	08f77d63          	bgeu	a4,a5,800062a6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006210:	100014b7          	lui	s1,0x10001
    80006214:	47a1                	li	a5,8
    80006216:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006218:	6609                	lui	a2,0x2
    8000621a:	4581                	li	a1,0
    8000621c:	0001d517          	auipc	a0,0x1d
    80006220:	de450513          	addi	a0,a0,-540 # 80023000 <disk>
    80006224:	ffffb097          	auipc	ra,0xffffb
    80006228:	a9a080e7          	jalr	-1382(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000622c:	0001d717          	auipc	a4,0x1d
    80006230:	dd470713          	addi	a4,a4,-556 # 80023000 <disk>
    80006234:	00c75793          	srli	a5,a4,0xc
    80006238:	2781                	sext.w	a5,a5
    8000623a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000623c:	0001f797          	auipc	a5,0x1f
    80006240:	dc478793          	addi	a5,a5,-572 # 80025000 <disk+0x2000>
    80006244:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006246:	0001d717          	auipc	a4,0x1d
    8000624a:	e3a70713          	addi	a4,a4,-454 # 80023080 <disk+0x80>
    8000624e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006250:	0001e717          	auipc	a4,0x1e
    80006254:	db070713          	addi	a4,a4,-592 # 80024000 <disk+0x1000>
    80006258:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000625a:	4705                	li	a4,1
    8000625c:	00e78c23          	sb	a4,24(a5)
    80006260:	00e78ca3          	sb	a4,25(a5)
    80006264:	00e78d23          	sb	a4,26(a5)
    80006268:	00e78da3          	sb	a4,27(a5)
    8000626c:	00e78e23          	sb	a4,28(a5)
    80006270:	00e78ea3          	sb	a4,29(a5)
    80006274:	00e78f23          	sb	a4,30(a5)
    80006278:	00e78fa3          	sb	a4,31(a5)
}
    8000627c:	60e2                	ld	ra,24(sp)
    8000627e:	6442                	ld	s0,16(sp)
    80006280:	64a2                	ld	s1,8(sp)
    80006282:	6105                	addi	sp,sp,32
    80006284:	8082                	ret
    panic("could not find virtio disk");
    80006286:	00002517          	auipc	a0,0x2
    8000628a:	63250513          	addi	a0,a0,1586 # 800088b8 <syscalls+0x360>
    8000628e:	ffffa097          	auipc	ra,0xffffa
    80006292:	29c080e7          	jalr	668(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006296:	00002517          	auipc	a0,0x2
    8000629a:	64250513          	addi	a0,a0,1602 # 800088d8 <syscalls+0x380>
    8000629e:	ffffa097          	auipc	ra,0xffffa
    800062a2:	28c080e7          	jalr	652(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    800062a6:	00002517          	auipc	a0,0x2
    800062aa:	65250513          	addi	a0,a0,1618 # 800088f8 <syscalls+0x3a0>
    800062ae:	ffffa097          	auipc	ra,0xffffa
    800062b2:	27c080e7          	jalr	636(ra) # 8000052a <panic>

00000000800062b6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062b6:	7119                	addi	sp,sp,-128
    800062b8:	fc86                	sd	ra,120(sp)
    800062ba:	f8a2                	sd	s0,112(sp)
    800062bc:	f4a6                	sd	s1,104(sp)
    800062be:	f0ca                	sd	s2,96(sp)
    800062c0:	ecce                	sd	s3,88(sp)
    800062c2:	e8d2                	sd	s4,80(sp)
    800062c4:	e4d6                	sd	s5,72(sp)
    800062c6:	e0da                	sd	s6,64(sp)
    800062c8:	fc5e                	sd	s7,56(sp)
    800062ca:	f862                	sd	s8,48(sp)
    800062cc:	f466                	sd	s9,40(sp)
    800062ce:	f06a                	sd	s10,32(sp)
    800062d0:	ec6e                	sd	s11,24(sp)
    800062d2:	0100                	addi	s0,sp,128
    800062d4:	8aaa                	mv	s5,a0
    800062d6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062d8:	00c52c83          	lw	s9,12(a0)
    800062dc:	001c9c9b          	slliw	s9,s9,0x1
    800062e0:	1c82                	slli	s9,s9,0x20
    800062e2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800062e6:	0001f517          	auipc	a0,0x1f
    800062ea:	e4250513          	addi	a0,a0,-446 # 80025128 <disk+0x2128>
    800062ee:	ffffb097          	auipc	ra,0xffffb
    800062f2:	8d4080e7          	jalr	-1836(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    800062f6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800062f8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800062fa:	0001dc17          	auipc	s8,0x1d
    800062fe:	d06c0c13          	addi	s8,s8,-762 # 80023000 <disk>
    80006302:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006304:	4b0d                	li	s6,3
    80006306:	a0ad                	j	80006370 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006308:	00fc0733          	add	a4,s8,a5
    8000630c:	975e                	add	a4,a4,s7
    8000630e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006312:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006314:	0207c563          	bltz	a5,8000633e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006318:	2905                	addiw	s2,s2,1
    8000631a:	0611                	addi	a2,a2,4
    8000631c:	19690d63          	beq	s2,s6,800064b6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006320:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006322:	0001f717          	auipc	a4,0x1f
    80006326:	cf670713          	addi	a4,a4,-778 # 80025018 <disk+0x2018>
    8000632a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000632c:	00074683          	lbu	a3,0(a4)
    80006330:	fee1                	bnez	a3,80006308 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006332:	2785                	addiw	a5,a5,1
    80006334:	0705                	addi	a4,a4,1
    80006336:	fe979be3          	bne	a5,s1,8000632c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000633a:	57fd                	li	a5,-1
    8000633c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000633e:	01205d63          	blez	s2,80006358 <virtio_disk_rw+0xa2>
    80006342:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006344:	000a2503          	lw	a0,0(s4)
    80006348:	00000097          	auipc	ra,0x0
    8000634c:	d8e080e7          	jalr	-626(ra) # 800060d6 <free_desc>
      for(int j = 0; j < i; j++)
    80006350:	2d85                	addiw	s11,s11,1
    80006352:	0a11                	addi	s4,s4,4
    80006354:	ffb918e3          	bne	s2,s11,80006344 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006358:	0001f597          	auipc	a1,0x1f
    8000635c:	dd058593          	addi	a1,a1,-560 # 80025128 <disk+0x2128>
    80006360:	0001f517          	auipc	a0,0x1f
    80006364:	cb850513          	addi	a0,a0,-840 # 80025018 <disk+0x2018>
    80006368:	ffffc097          	auipc	ra,0xffffc
    8000636c:	e78080e7          	jalr	-392(ra) # 800021e0 <sleep>
  for(int i = 0; i < 3; i++){
    80006370:	f8040a13          	addi	s4,s0,-128
{
    80006374:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006376:	894e                	mv	s2,s3
    80006378:	b765                	j	80006320 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000637a:	0001f697          	auipc	a3,0x1f
    8000637e:	c866b683          	ld	a3,-890(a3) # 80025000 <disk+0x2000>
    80006382:	96ba                	add	a3,a3,a4
    80006384:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006388:	0001d817          	auipc	a6,0x1d
    8000638c:	c7880813          	addi	a6,a6,-904 # 80023000 <disk>
    80006390:	0001f697          	auipc	a3,0x1f
    80006394:	c7068693          	addi	a3,a3,-912 # 80025000 <disk+0x2000>
    80006398:	6290                	ld	a2,0(a3)
    8000639a:	963a                	add	a2,a2,a4
    8000639c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800063a0:	0015e593          	ori	a1,a1,1
    800063a4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800063a8:	f8842603          	lw	a2,-120(s0)
    800063ac:	628c                	ld	a1,0(a3)
    800063ae:	972e                	add	a4,a4,a1
    800063b0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800063b4:	20050593          	addi	a1,a0,512
    800063b8:	0592                	slli	a1,a1,0x4
    800063ba:	95c2                	add	a1,a1,a6
    800063bc:	577d                	li	a4,-1
    800063be:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800063c2:	00461713          	slli	a4,a2,0x4
    800063c6:	6290                	ld	a2,0(a3)
    800063c8:	963a                	add	a2,a2,a4
    800063ca:	03078793          	addi	a5,a5,48
    800063ce:	97c2                	add	a5,a5,a6
    800063d0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800063d2:	629c                	ld	a5,0(a3)
    800063d4:	97ba                	add	a5,a5,a4
    800063d6:	4605                	li	a2,1
    800063d8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063da:	629c                	ld	a5,0(a3)
    800063dc:	97ba                	add	a5,a5,a4
    800063de:	4809                	li	a6,2
    800063e0:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800063e4:	629c                	ld	a5,0(a3)
    800063e6:	973e                	add	a4,a4,a5
    800063e8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800063ec:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800063f0:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800063f4:	6698                	ld	a4,8(a3)
    800063f6:	00275783          	lhu	a5,2(a4)
    800063fa:	8b9d                	andi	a5,a5,7
    800063fc:	0786                	slli	a5,a5,0x1
    800063fe:	97ba                	add	a5,a5,a4
    80006400:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006404:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006408:	6698                	ld	a4,8(a3)
    8000640a:	00275783          	lhu	a5,2(a4)
    8000640e:	2785                	addiw	a5,a5,1
    80006410:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006414:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006418:	100017b7          	lui	a5,0x10001
    8000641c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006420:	004aa783          	lw	a5,4(s5)
    80006424:	02c79163          	bne	a5,a2,80006446 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006428:	0001f917          	auipc	s2,0x1f
    8000642c:	d0090913          	addi	s2,s2,-768 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80006430:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006432:	85ca                	mv	a1,s2
    80006434:	8556                	mv	a0,s5
    80006436:	ffffc097          	auipc	ra,0xffffc
    8000643a:	daa080e7          	jalr	-598(ra) # 800021e0 <sleep>
  while(b->disk == 1) {
    8000643e:	004aa783          	lw	a5,4(s5)
    80006442:	fe9788e3          	beq	a5,s1,80006432 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006446:	f8042903          	lw	s2,-128(s0)
    8000644a:	20090793          	addi	a5,s2,512
    8000644e:	00479713          	slli	a4,a5,0x4
    80006452:	0001d797          	auipc	a5,0x1d
    80006456:	bae78793          	addi	a5,a5,-1106 # 80023000 <disk>
    8000645a:	97ba                	add	a5,a5,a4
    8000645c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006460:	0001f997          	auipc	s3,0x1f
    80006464:	ba098993          	addi	s3,s3,-1120 # 80025000 <disk+0x2000>
    80006468:	00491713          	slli	a4,s2,0x4
    8000646c:	0009b783          	ld	a5,0(s3)
    80006470:	97ba                	add	a5,a5,a4
    80006472:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006476:	854a                	mv	a0,s2
    80006478:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000647c:	00000097          	auipc	ra,0x0
    80006480:	c5a080e7          	jalr	-934(ra) # 800060d6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006484:	8885                	andi	s1,s1,1
    80006486:	f0ed                	bnez	s1,80006468 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006488:	0001f517          	auipc	a0,0x1f
    8000648c:	ca050513          	addi	a0,a0,-864 # 80025128 <disk+0x2128>
    80006490:	ffffa097          	auipc	ra,0xffffa
    80006494:	7e6080e7          	jalr	2022(ra) # 80000c76 <release>
}
    80006498:	70e6                	ld	ra,120(sp)
    8000649a:	7446                	ld	s0,112(sp)
    8000649c:	74a6                	ld	s1,104(sp)
    8000649e:	7906                	ld	s2,96(sp)
    800064a0:	69e6                	ld	s3,88(sp)
    800064a2:	6a46                	ld	s4,80(sp)
    800064a4:	6aa6                	ld	s5,72(sp)
    800064a6:	6b06                	ld	s6,64(sp)
    800064a8:	7be2                	ld	s7,56(sp)
    800064aa:	7c42                	ld	s8,48(sp)
    800064ac:	7ca2                	ld	s9,40(sp)
    800064ae:	7d02                	ld	s10,32(sp)
    800064b0:	6de2                	ld	s11,24(sp)
    800064b2:	6109                	addi	sp,sp,128
    800064b4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064b6:	f8042503          	lw	a0,-128(s0)
    800064ba:	20050793          	addi	a5,a0,512
    800064be:	0792                	slli	a5,a5,0x4
  if(write)
    800064c0:	0001d817          	auipc	a6,0x1d
    800064c4:	b4080813          	addi	a6,a6,-1216 # 80023000 <disk>
    800064c8:	00f80733          	add	a4,a6,a5
    800064cc:	01a036b3          	snez	a3,s10
    800064d0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800064d4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800064d8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800064dc:	7679                	lui	a2,0xffffe
    800064de:	963e                	add	a2,a2,a5
    800064e0:	0001f697          	auipc	a3,0x1f
    800064e4:	b2068693          	addi	a3,a3,-1248 # 80025000 <disk+0x2000>
    800064e8:	6298                	ld	a4,0(a3)
    800064ea:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064ec:	0a878593          	addi	a1,a5,168
    800064f0:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800064f2:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800064f4:	6298                	ld	a4,0(a3)
    800064f6:	9732                	add	a4,a4,a2
    800064f8:	45c1                	li	a1,16
    800064fa:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800064fc:	6298                	ld	a4,0(a3)
    800064fe:	9732                	add	a4,a4,a2
    80006500:	4585                	li	a1,1
    80006502:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006506:	f8442703          	lw	a4,-124(s0)
    8000650a:	628c                	ld	a1,0(a3)
    8000650c:	962e                	add	a2,a2,a1
    8000650e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006512:	0712                	slli	a4,a4,0x4
    80006514:	6290                	ld	a2,0(a3)
    80006516:	963a                	add	a2,a2,a4
    80006518:	058a8593          	addi	a1,s5,88
    8000651c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000651e:	6294                	ld	a3,0(a3)
    80006520:	96ba                	add	a3,a3,a4
    80006522:	40000613          	li	a2,1024
    80006526:	c690                	sw	a2,8(a3)
  if(write)
    80006528:	e40d19e3          	bnez	s10,8000637a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000652c:	0001f697          	auipc	a3,0x1f
    80006530:	ad46b683          	ld	a3,-1324(a3) # 80025000 <disk+0x2000>
    80006534:	96ba                	add	a3,a3,a4
    80006536:	4609                	li	a2,2
    80006538:	00c69623          	sh	a2,12(a3)
    8000653c:	b5b1                	j	80006388 <virtio_disk_rw+0xd2>

000000008000653e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000653e:	1101                	addi	sp,sp,-32
    80006540:	ec06                	sd	ra,24(sp)
    80006542:	e822                	sd	s0,16(sp)
    80006544:	e426                	sd	s1,8(sp)
    80006546:	e04a                	sd	s2,0(sp)
    80006548:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000654a:	0001f517          	auipc	a0,0x1f
    8000654e:	bde50513          	addi	a0,a0,-1058 # 80025128 <disk+0x2128>
    80006552:	ffffa097          	auipc	ra,0xffffa
    80006556:	670080e7          	jalr	1648(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000655a:	10001737          	lui	a4,0x10001
    8000655e:	533c                	lw	a5,96(a4)
    80006560:	8b8d                	andi	a5,a5,3
    80006562:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006564:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006568:	0001f797          	auipc	a5,0x1f
    8000656c:	a9878793          	addi	a5,a5,-1384 # 80025000 <disk+0x2000>
    80006570:	6b94                	ld	a3,16(a5)
    80006572:	0207d703          	lhu	a4,32(a5)
    80006576:	0026d783          	lhu	a5,2(a3)
    8000657a:	06f70163          	beq	a4,a5,800065dc <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000657e:	0001d917          	auipc	s2,0x1d
    80006582:	a8290913          	addi	s2,s2,-1406 # 80023000 <disk>
    80006586:	0001f497          	auipc	s1,0x1f
    8000658a:	a7a48493          	addi	s1,s1,-1414 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000658e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006592:	6898                	ld	a4,16(s1)
    80006594:	0204d783          	lhu	a5,32(s1)
    80006598:	8b9d                	andi	a5,a5,7
    8000659a:	078e                	slli	a5,a5,0x3
    8000659c:	97ba                	add	a5,a5,a4
    8000659e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800065a0:	20078713          	addi	a4,a5,512
    800065a4:	0712                	slli	a4,a4,0x4
    800065a6:	974a                	add	a4,a4,s2
    800065a8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800065ac:	e731                	bnez	a4,800065f8 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800065ae:	20078793          	addi	a5,a5,512
    800065b2:	0792                	slli	a5,a5,0x4
    800065b4:	97ca                	add	a5,a5,s2
    800065b6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800065b8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800065bc:	ffffc097          	auipc	ra,0xffffc
    800065c0:	f62080e7          	jalr	-158(ra) # 8000251e <wakeup>

    disk.used_idx += 1;
    800065c4:	0204d783          	lhu	a5,32(s1)
    800065c8:	2785                	addiw	a5,a5,1
    800065ca:	17c2                	slli	a5,a5,0x30
    800065cc:	93c1                	srli	a5,a5,0x30
    800065ce:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800065d2:	6898                	ld	a4,16(s1)
    800065d4:	00275703          	lhu	a4,2(a4)
    800065d8:	faf71be3          	bne	a4,a5,8000658e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800065dc:	0001f517          	auipc	a0,0x1f
    800065e0:	b4c50513          	addi	a0,a0,-1204 # 80025128 <disk+0x2128>
    800065e4:	ffffa097          	auipc	ra,0xffffa
    800065e8:	692080e7          	jalr	1682(ra) # 80000c76 <release>
}
    800065ec:	60e2                	ld	ra,24(sp)
    800065ee:	6442                	ld	s0,16(sp)
    800065f0:	64a2                	ld	s1,8(sp)
    800065f2:	6902                	ld	s2,0(sp)
    800065f4:	6105                	addi	sp,sp,32
    800065f6:	8082                	ret
      panic("virtio_disk_intr status");
    800065f8:	00002517          	auipc	a0,0x2
    800065fc:	32050513          	addi	a0,a0,800 # 80008918 <syscalls+0x3c0>
    80006600:	ffffa097          	auipc	ra,0xffffa
    80006604:	f2a080e7          	jalr	-214(ra) # 8000052a <panic>
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
