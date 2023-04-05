
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	9a013103          	ld	sp,-1632(sp) # 800089a0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000068:	28c78793          	addi	a5,a5,652 # 800062f0 <timervec>
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
    800000b2:	de078793          	addi	a5,a5,-544 # 80000e8e <main>
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
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	696080e7          	jalr	1686(ra) # 800027c2 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	78e080e7          	jalr	1934(ra) # 800008ca <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7119                	addi	sp,sp,-128
    80000166:	fc86                	sd	ra,120(sp)
    80000168:	f8a2                	sd	s0,112(sp)
    8000016a:	f4a6                	sd	s1,104(sp)
    8000016c:	f0ca                	sd	s2,96(sp)
    8000016e:	ecce                	sd	s3,88(sp)
    80000170:	e8d2                	sd	s4,80(sp)
    80000172:	e4d6                	sd	s5,72(sp)
    80000174:	e0da                	sd	s6,64(sp)
    80000176:	fc5e                	sd	s7,56(sp)
    80000178:	f862                	sd	s8,48(sp)
    8000017a:	f466                	sd	s9,40(sp)
    8000017c:	f06a                	sd	s10,32(sp)
    8000017e:	ec6e                	sd	s11,24(sp)
    80000180:	0100                	addi	s0,sp,128
    80000182:	8b2a                	mv	s6,a0
    80000184:	8aae                	mv	s5,a1
    80000186:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	ff450513          	addi	a0,a0,-12 # 80011180 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a50080e7          	jalr	-1456(ra) # 80000be4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	fe448493          	addi	s1,s1,-28 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	07290913          	addi	s2,s2,114 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001ae:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b0:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b2:	4da9                	li	s11,10
  while(n > 0){
    800001b4:	07405863          	blez	s4,80000224 <consoleread+0xc0>
    while(cons.r == cons.w){
    800001b8:	0984a783          	lw	a5,152(s1)
    800001bc:	09c4a703          	lw	a4,156(s1)
    800001c0:	02f71463          	bne	a4,a5,800001e8 <consoleread+0x84>
      if(myproc()->killed){
    800001c4:	00001097          	auipc	ra,0x1
    800001c8:	7ec080e7          	jalr	2028(ra) # 800019b0 <myproc>
    800001cc:	551c                	lw	a5,40(a0)
    800001ce:	e7b5                	bnez	a5,8000023a <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001d0:	85ce                	mv	a1,s3
    800001d2:	854a                	mv	a0,s2
    800001d4:	00002097          	auipc	ra,0x2
    800001d8:	090080e7          	jalr	144(ra) # 80002264 <sleep>
    while(cons.r == cons.w){
    800001dc:	0984a783          	lw	a5,152(s1)
    800001e0:	09c4a703          	lw	a4,156(s1)
    800001e4:	fef700e3          	beq	a4,a5,800001c4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e8:	0017871b          	addiw	a4,a5,1
    800001ec:	08e4ac23          	sw	a4,152(s1)
    800001f0:	07f7f713          	andi	a4,a5,127
    800001f4:	9726                	add	a4,a4,s1
    800001f6:	01874703          	lbu	a4,24(a4)
    800001fa:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    800001fe:	079c0663          	beq	s8,s9,8000026a <consoleread+0x106>
    cbuf = c;
    80000202:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	f8f40613          	addi	a2,s0,-113
    8000020c:	85d6                	mv	a1,s5
    8000020e:	855a                	mv	a0,s6
    80000210:	00002097          	auipc	ra,0x2
    80000214:	55c080e7          	jalr	1372(ra) # 8000276c <either_copyout>
    80000218:	01a50663          	beq	a0,s10,80000224 <consoleread+0xc0>
    dst++;
    8000021c:	0a85                	addi	s5,s5,1
    --n;
    8000021e:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000220:	f9bc1ae3          	bne	s8,s11,800001b4 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000224:	00011517          	auipc	a0,0x11
    80000228:	f5c50513          	addi	a0,a0,-164 # 80011180 <cons>
    8000022c:	00001097          	auipc	ra,0x1
    80000230:	a6c080e7          	jalr	-1428(ra) # 80000c98 <release>

  return target - n;
    80000234:	414b853b          	subw	a0,s7,s4
    80000238:	a811                	j	8000024c <consoleread+0xe8>
        release(&cons.lock);
    8000023a:	00011517          	auipc	a0,0x11
    8000023e:	f4650513          	addi	a0,a0,-186 # 80011180 <cons>
    80000242:	00001097          	auipc	ra,0x1
    80000246:	a56080e7          	jalr	-1450(ra) # 80000c98 <release>
        return -1;
    8000024a:	557d                	li	a0,-1
}
    8000024c:	70e6                	ld	ra,120(sp)
    8000024e:	7446                	ld	s0,112(sp)
    80000250:	74a6                	ld	s1,104(sp)
    80000252:	7906                	ld	s2,96(sp)
    80000254:	69e6                	ld	s3,88(sp)
    80000256:	6a46                	ld	s4,80(sp)
    80000258:	6aa6                	ld	s5,72(sp)
    8000025a:	6b06                	ld	s6,64(sp)
    8000025c:	7be2                	ld	s7,56(sp)
    8000025e:	7c42                	ld	s8,48(sp)
    80000260:	7ca2                	ld	s9,40(sp)
    80000262:	7d02                	ld	s10,32(sp)
    80000264:	6de2                	ld	s11,24(sp)
    80000266:	6109                	addi	sp,sp,128
    80000268:	8082                	ret
      if(n < target){
    8000026a:	000a071b          	sext.w	a4,s4
    8000026e:	fb777be3          	bgeu	a4,s7,80000224 <consoleread+0xc0>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	faf72323          	sw	a5,-90(a4) # 80011218 <cons+0x98>
    8000027a:	b76d                	j	80000224 <consoleread+0xc0>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	564080e7          	jalr	1380(ra) # 800007f0 <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	552080e7          	jalr	1362(ra) # 800007f0 <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	546080e7          	jalr	1350(ra) # 800007f0 <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	53c080e7          	jalr	1340(ra) # 800007f0 <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	eb450513          	addi	a0,a0,-332 # 80011180 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	910080e7          	jalr	-1776(ra) # 80000be4 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	526080e7          	jalr	1318(ra) # 80002818 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	e8650513          	addi	a0,a0,-378 # 80011180 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	996080e7          	jalr	-1642(ra) # 80000c98 <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	e6270713          	addi	a4,a4,-414 # 80011180 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	e3878793          	addi	a5,a5,-456 # 80011180 <cons>
    80000350:	0a07a703          	lw	a4,160(a5)
    80000354:	0017069b          	addiw	a3,a4,1
    80000358:	0006861b          	sext.w	a2,a3
    8000035c:	0ad7a023          	sw	a3,160(a5)
    80000360:	07f77713          	andi	a4,a4,127
    80000364:	97ba                	add	a5,a5,a4
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	ea27a783          	lw	a5,-350(a5) # 80011218 <cons+0x98>
    8000037e:	0807879b          	addiw	a5,a5,128
    80000382:	f6f61ce3          	bne	a2,a5,800002fa <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000386:	863e                	mv	a2,a5
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	df670713          	addi	a4,a4,-522 # 80011180 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	de648493          	addi	s1,s1,-538 # 80011180 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00011717          	auipc	a4,0x11
    800003da:	daa70713          	addi	a4,a4,-598 # 80011180 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	e2f72a23          	sw	a5,-460(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000412:	00011797          	auipc	a5,0x11
    80000416:	d6e78793          	addi	a5,a5,-658 # 80011180 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	dec7a323          	sw	a2,-538(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	dda50513          	addi	a0,a0,-550 # 80011218 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	0de080e7          	jalr	222(ra) # 80002524 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00011517          	auipc	a0,0x11
    80000464:	d2050513          	addi	a0,a0,-736 # 80011180 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6ec080e7          	jalr	1772(ra) # 80000b54 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	330080e7          	jalr	816(ra) # 800007a0 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	4a078793          	addi	a5,a5,1184 # 80021918 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00011797          	auipc	a5,0x11
    8000054e:	ce07ab23          	sw	zero,-778(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00009717          	auipc	a4,0x9
    80000582:	a8f72123          	sw	a5,-1406(a4) # 80009000 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00011d97          	auipc	s11,0x11
    800005be:	c86dad83          	lw	s11,-890(s11) # 80011240 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	16050263          	beqz	a0,8000073a <printf+0x1b2>
    800005da:	4481                	li	s1,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b13          	li	s6,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b97          	auipc	s7,0x8
    800005ea:	a5ab8b93          	addi	s7,s7,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00011517          	auipc	a0,0x11
    800005fc:	c3050513          	addi	a0,a0,-976 # 80011228 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5e4080e7          	jalr	1508(ra) # 80000be4 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2485                	addiw	s1,s1,1
    80000624:	009a07b3          	add	a5,s4,s1
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050763          	beqz	a0,8000073a <printf+0x1b2>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2485                	addiw	s1,s1,1
    80000636:	009a07b3          	add	a5,s4,s1
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000642:	cfe5                	beqz	a5,8000073a <printf+0x1b2>
    switch(c){
    80000644:	05678a63          	beq	a5,s6,80000698 <printf+0x110>
    80000648:	02fb7663          	bgeu	s6,a5,80000674 <printf+0xec>
    8000064c:	09978963          	beq	a5,s9,800006de <printf+0x156>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79863          	bne	a5,a4,80000724 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	0b578263          	beq	a5,s5,80000718 <printf+0x190>
    80000678:	0b879663          	bne	a5,s8,80000724 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c9d793          	srli	a5,s3,0x3c
    800006c6:	97de                	add	a5,a5,s7
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0992                	slli	s3,s3,0x4
    800006d6:	397d                	addiw	s2,s2,-1
    800006d8:	fe0915e3          	bnez	s2,800006c2 <printf+0x13a>
    800006dc:	b799                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	0007b903          	ld	s2,0(a5)
    800006ee:	00090e63          	beqz	s2,8000070a <printf+0x182>
      for(; *s; s++)
    800006f2:	00094503          	lbu	a0,0(s2)
    800006f6:	d515                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f8:	00000097          	auipc	ra,0x0
    800006fc:	b84080e7          	jalr	-1148(ra) # 8000027c <consputc>
      for(; *s; s++)
    80000700:	0905                	addi	s2,s2,1
    80000702:	00094503          	lbu	a0,0(s2)
    80000706:	f96d                	bnez	a0,800006f8 <printf+0x170>
    80000708:	bf29                	j	80000622 <printf+0x9a>
        s = "(null)";
    8000070a:	00008917          	auipc	s2,0x8
    8000070e:	91690913          	addi	s2,s2,-1770 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000712:	02800513          	li	a0,40
    80000716:	b7cd                	j	800006f8 <printf+0x170>
      consputc('%');
    80000718:	8556                	mv	a0,s5
    8000071a:	00000097          	auipc	ra,0x0
    8000071e:	b62080e7          	jalr	-1182(ra) # 8000027c <consputc>
      break;
    80000722:	b701                	j	80000622 <printf+0x9a>
      consputc('%');
    80000724:	8556                	mv	a0,s5
    80000726:	00000097          	auipc	ra,0x0
    8000072a:	b56080e7          	jalr	-1194(ra) # 8000027c <consputc>
      consputc(c);
    8000072e:	854a                	mv	a0,s2
    80000730:	00000097          	auipc	ra,0x0
    80000734:	b4c080e7          	jalr	-1204(ra) # 8000027c <consputc>
      break;
    80000738:	b5ed                	j	80000622 <printf+0x9a>
  if(locking)
    8000073a:	020d9163          	bnez	s11,8000075c <printf+0x1d4>
}
    8000073e:	70e6                	ld	ra,120(sp)
    80000740:	7446                	ld	s0,112(sp)
    80000742:	74a6                	ld	s1,104(sp)
    80000744:	7906                	ld	s2,96(sp)
    80000746:	69e6                	ld	s3,88(sp)
    80000748:	6a46                	ld	s4,80(sp)
    8000074a:	6aa6                	ld	s5,72(sp)
    8000074c:	6b06                	ld	s6,64(sp)
    8000074e:	7be2                	ld	s7,56(sp)
    80000750:	7c42                	ld	s8,48(sp)
    80000752:	7ca2                	ld	s9,40(sp)
    80000754:	7d02                	ld	s10,32(sp)
    80000756:	6de2                	ld	s11,24(sp)
    80000758:	6129                	addi	sp,sp,192
    8000075a:	8082                	ret
    release(&pr.lock);
    8000075c:	00011517          	auipc	a0,0x11
    80000760:	acc50513          	addi	a0,a0,-1332 # 80011228 <pr>
    80000764:	00000097          	auipc	ra,0x0
    80000768:	534080e7          	jalr	1332(ra) # 80000c98 <release>
}
    8000076c:	bfc9                	j	8000073e <printf+0x1b6>

000000008000076e <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076e:	1101                	addi	sp,sp,-32
    80000770:	ec06                	sd	ra,24(sp)
    80000772:	e822                	sd	s0,16(sp)
    80000774:	e426                	sd	s1,8(sp)
    80000776:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000778:	00011497          	auipc	s1,0x11
    8000077c:	ab048493          	addi	s1,s1,-1360 # 80011228 <pr>
    80000780:	00008597          	auipc	a1,0x8
    80000784:	8b858593          	addi	a1,a1,-1864 # 80008038 <etext+0x38>
    80000788:	8526                	mv	a0,s1
    8000078a:	00000097          	auipc	ra,0x0
    8000078e:	3ca080e7          	jalr	970(ra) # 80000b54 <initlock>
  pr.locking = 1;
    80000792:	4785                	li	a5,1
    80000794:	cc9c                	sw	a5,24(s1)
}
    80000796:	60e2                	ld	ra,24(sp)
    80000798:	6442                	ld	s0,16(sp)
    8000079a:	64a2                	ld	s1,8(sp)
    8000079c:	6105                	addi	sp,sp,32
    8000079e:	8082                	ret

00000000800007a0 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a0:	1141                	addi	sp,sp,-16
    800007a2:	e406                	sd	ra,8(sp)
    800007a4:	e022                	sd	s0,0(sp)
    800007a6:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a8:	100007b7          	lui	a5,0x10000
    800007ac:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b0:	f8000713          	li	a4,-128
    800007b4:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b8:	470d                	li	a4,3
    800007ba:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007be:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c2:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c6:	469d                	li	a3,7
    800007c8:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007cc:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d0:	00008597          	auipc	a1,0x8
    800007d4:	88858593          	addi	a1,a1,-1912 # 80008058 <digits+0x18>
    800007d8:	00011517          	auipc	a0,0x11
    800007dc:	a7050513          	addi	a0,a0,-1424 # 80011248 <uart_tx_lock>
    800007e0:	00000097          	auipc	ra,0x0
    800007e4:	374080e7          	jalr	884(ra) # 80000b54 <initlock>
}
    800007e8:	60a2                	ld	ra,8(sp)
    800007ea:	6402                	ld	s0,0(sp)
    800007ec:	0141                	addi	sp,sp,16
    800007ee:	8082                	ret

00000000800007f0 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f0:	1101                	addi	sp,sp,-32
    800007f2:	ec06                	sd	ra,24(sp)
    800007f4:	e822                	sd	s0,16(sp)
    800007f6:	e426                	sd	s1,8(sp)
    800007f8:	1000                	addi	s0,sp,32
    800007fa:	84aa                	mv	s1,a0
  push_off();
    800007fc:	00000097          	auipc	ra,0x0
    80000800:	39c080e7          	jalr	924(ra) # 80000b98 <push_off>

  if(panicked){
    80000804:	00008797          	auipc	a5,0x8
    80000808:	7fc7a783          	lw	a5,2044(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	10000737          	lui	a4,0x10000
  if(panicked){
    80000810:	c391                	beqz	a5,80000814 <uartputc_sync+0x24>
    for(;;)
    80000812:	a001                	j	80000812 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000814:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000818:	0ff7f793          	andi	a5,a5,255
    8000081c:	0207f793          	andi	a5,a5,32
    80000820:	dbf5                	beqz	a5,80000814 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000822:	0ff4f793          	andi	a5,s1,255
    80000826:	10000737          	lui	a4,0x10000
    8000082a:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000082e:	00000097          	auipc	ra,0x0
    80000832:	40a080e7          	jalr	1034(ra) # 80000c38 <pop_off>
}
    80000836:	60e2                	ld	ra,24(sp)
    80000838:	6442                	ld	s0,16(sp)
    8000083a:	64a2                	ld	s1,8(sp)
    8000083c:	6105                	addi	sp,sp,32
    8000083e:	8082                	ret

0000000080000840 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000840:	00008717          	auipc	a4,0x8
    80000844:	7c873703          	ld	a4,1992(a4) # 80009008 <uart_tx_r>
    80000848:	00008797          	auipc	a5,0x8
    8000084c:	7c87b783          	ld	a5,1992(a5) # 80009010 <uart_tx_w>
    80000850:	06e78c63          	beq	a5,a4,800008c8 <uartstart+0x88>
{
    80000854:	7139                	addi	sp,sp,-64
    80000856:	fc06                	sd	ra,56(sp)
    80000858:	f822                	sd	s0,48(sp)
    8000085a:	f426                	sd	s1,40(sp)
    8000085c:	f04a                	sd	s2,32(sp)
    8000085e:	ec4e                	sd	s3,24(sp)
    80000860:	e852                	sd	s4,16(sp)
    80000862:	e456                	sd	s5,8(sp)
    80000864:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000866:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086a:	00011a17          	auipc	s4,0x11
    8000086e:	9dea0a13          	addi	s4,s4,-1570 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000872:	00008497          	auipc	s1,0x8
    80000876:	79648493          	addi	s1,s1,1942 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000087a:	00008997          	auipc	s3,0x8
    8000087e:	79698993          	addi	s3,s3,1942 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000882:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000886:	0ff7f793          	andi	a5,a5,255
    8000088a:	0207f793          	andi	a5,a5,32
    8000088e:	c785                	beqz	a5,800008b6 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000890:	01f77793          	andi	a5,a4,31
    80000894:	97d2                	add	a5,a5,s4
    80000896:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    8000089a:	0705                	addi	a4,a4,1
    8000089c:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000089e:	8526                	mv	a0,s1
    800008a0:	00002097          	auipc	ra,0x2
    800008a4:	c84080e7          	jalr	-892(ra) # 80002524 <wakeup>
    
    WriteReg(THR, c);
    800008a8:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008ac:	6098                	ld	a4,0(s1)
    800008ae:	0009b783          	ld	a5,0(s3)
    800008b2:	fce798e3          	bne	a5,a4,80000882 <uartstart+0x42>
  }
}
    800008b6:	70e2                	ld	ra,56(sp)
    800008b8:	7442                	ld	s0,48(sp)
    800008ba:	74a2                	ld	s1,40(sp)
    800008bc:	7902                	ld	s2,32(sp)
    800008be:	69e2                	ld	s3,24(sp)
    800008c0:	6a42                	ld	s4,16(sp)
    800008c2:	6aa2                	ld	s5,8(sp)
    800008c4:	6121                	addi	sp,sp,64
    800008c6:	8082                	ret
    800008c8:	8082                	ret

00000000800008ca <uartputc>:
{
    800008ca:	7179                	addi	sp,sp,-48
    800008cc:	f406                	sd	ra,40(sp)
    800008ce:	f022                	sd	s0,32(sp)
    800008d0:	ec26                	sd	s1,24(sp)
    800008d2:	e84a                	sd	s2,16(sp)
    800008d4:	e44e                	sd	s3,8(sp)
    800008d6:	e052                	sd	s4,0(sp)
    800008d8:	1800                	addi	s0,sp,48
    800008da:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008dc:	00011517          	auipc	a0,0x11
    800008e0:	96c50513          	addi	a0,a0,-1684 # 80011248 <uart_tx_lock>
    800008e4:	00000097          	auipc	ra,0x0
    800008e8:	300080e7          	jalr	768(ra) # 80000be4 <acquire>
  if(panicked){
    800008ec:	00008797          	auipc	a5,0x8
    800008f0:	7147a783          	lw	a5,1812(a5) # 80009000 <panicked>
    800008f4:	c391                	beqz	a5,800008f8 <uartputc+0x2e>
    for(;;)
    800008f6:	a001                	j	800008f6 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008f8:	00008797          	auipc	a5,0x8
    800008fc:	7187b783          	ld	a5,1816(a5) # 80009010 <uart_tx_w>
    80000900:	00008717          	auipc	a4,0x8
    80000904:	70873703          	ld	a4,1800(a4) # 80009008 <uart_tx_r>
    80000908:	02070713          	addi	a4,a4,32
    8000090c:	02f71b63          	bne	a4,a5,80000942 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00011a17          	auipc	s4,0x11
    80000914:	938a0a13          	addi	s4,s4,-1736 # 80011248 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	6f048493          	addi	s1,s1,1776 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	6f090913          	addi	s2,s2,1776 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000928:	85d2                	mv	a1,s4
    8000092a:	8526                	mv	a0,s1
    8000092c:	00002097          	auipc	ra,0x2
    80000930:	938080e7          	jalr	-1736(ra) # 80002264 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000934:	00093783          	ld	a5,0(s2)
    80000938:	6098                	ld	a4,0(s1)
    8000093a:	02070713          	addi	a4,a4,32
    8000093e:	fef705e3          	beq	a4,a5,80000928 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000942:	00011497          	auipc	s1,0x11
    80000946:	90648493          	addi	s1,s1,-1786 # 80011248 <uart_tx_lock>
    8000094a:	01f7f713          	andi	a4,a5,31
    8000094e:	9726                	add	a4,a4,s1
    80000950:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    80000954:	0785                	addi	a5,a5,1
    80000956:	00008717          	auipc	a4,0x8
    8000095a:	6af73d23          	sd	a5,1722(a4) # 80009010 <uart_tx_w>
      uartstart();
    8000095e:	00000097          	auipc	ra,0x0
    80000962:	ee2080e7          	jalr	-286(ra) # 80000840 <uartstart>
      release(&uart_tx_lock);
    80000966:	8526                	mv	a0,s1
    80000968:	00000097          	auipc	ra,0x0
    8000096c:	330080e7          	jalr	816(ra) # 80000c98 <release>
}
    80000970:	70a2                	ld	ra,40(sp)
    80000972:	7402                	ld	s0,32(sp)
    80000974:	64e2                	ld	s1,24(sp)
    80000976:	6942                	ld	s2,16(sp)
    80000978:	69a2                	ld	s3,8(sp)
    8000097a:	6a02                	ld	s4,0(sp)
    8000097c:	6145                	addi	sp,sp,48
    8000097e:	8082                	ret

0000000080000980 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000980:	1141                	addi	sp,sp,-16
    80000982:	e422                	sd	s0,8(sp)
    80000984:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000098e:	8b85                	andi	a5,a5,1
    80000990:	cb91                	beqz	a5,800009a4 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000992:	100007b7          	lui	a5,0x10000
    80000996:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000099a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000099e:	6422                	ld	s0,8(sp)
    800009a0:	0141                	addi	sp,sp,16
    800009a2:	8082                	ret
    return -1;
    800009a4:	557d                	li	a0,-1
    800009a6:	bfe5                	j	8000099e <uartgetc+0x1e>

00000000800009a8 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009a8:	1101                	addi	sp,sp,-32
    800009aa:	ec06                	sd	ra,24(sp)
    800009ac:	e822                	sd	s0,16(sp)
    800009ae:	e426                	sd	s1,8(sp)
    800009b0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b2:	54fd                	li	s1,-1
    int c = uartgetc();
    800009b4:	00000097          	auipc	ra,0x0
    800009b8:	fcc080e7          	jalr	-52(ra) # 80000980 <uartgetc>
    if(c == -1)
    800009bc:	00950763          	beq	a0,s1,800009ca <uartintr+0x22>
      break;
    consoleintr(c);
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	8fe080e7          	jalr	-1794(ra) # 800002be <consoleintr>
  while(1){
    800009c8:	b7f5                	j	800009b4 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ca:	00011497          	auipc	s1,0x11
    800009ce:	87e48493          	addi	s1,s1,-1922 # 80011248 <uart_tx_lock>
    800009d2:	8526                	mv	a0,s1
    800009d4:	00000097          	auipc	ra,0x0
    800009d8:	210080e7          	jalr	528(ra) # 80000be4 <acquire>
  uartstart();
    800009dc:	00000097          	auipc	ra,0x0
    800009e0:	e64080e7          	jalr	-412(ra) # 80000840 <uartstart>
  release(&uart_tx_lock);
    800009e4:	8526                	mv	a0,s1
    800009e6:	00000097          	auipc	ra,0x0
    800009ea:	2b2080e7          	jalr	690(ra) # 80000c98 <release>
}
    800009ee:	60e2                	ld	ra,24(sp)
    800009f0:	6442                	ld	s0,16(sp)
    800009f2:	64a2                	ld	s1,8(sp)
    800009f4:	6105                	addi	sp,sp,32
    800009f6:	8082                	ret

00000000800009f8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009f8:	1101                	addi	sp,sp,-32
    800009fa:	ec06                	sd	ra,24(sp)
    800009fc:	e822                	sd	s0,16(sp)
    800009fe:	e426                	sd	s1,8(sp)
    80000a00:	e04a                	sd	s2,0(sp)
    80000a02:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a04:	03451793          	slli	a5,a0,0x34
    80000a08:	ebb9                	bnez	a5,80000a5e <kfree+0x66>
    80000a0a:	84aa                	mv	s1,a0
    80000a0c:	00025797          	auipc	a5,0x25
    80000a10:	5f478793          	addi	a5,a5,1524 # 80026000 <end>
    80000a14:	04f56563          	bltu	a0,a5,80000a5e <kfree+0x66>
    80000a18:	47c5                	li	a5,17
    80000a1a:	07ee                	slli	a5,a5,0x1b
    80000a1c:	04f57163          	bgeu	a0,a5,80000a5e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a20:	6605                	lui	a2,0x1
    80000a22:	4585                	li	a1,1
    80000a24:	00000097          	auipc	ra,0x0
    80000a28:	2bc080e7          	jalr	700(ra) # 80000ce0 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a2c:	00011917          	auipc	s2,0x11
    80000a30:	85490913          	addi	s2,s2,-1964 # 80011280 <kmem>
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	1ae080e7          	jalr	430(ra) # 80000be4 <acquire>
  r->next = kmem.freelist;
    80000a3e:	01893783          	ld	a5,24(s2)
    80000a42:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a44:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a48:	854a                	mv	a0,s2
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	24e080e7          	jalr	590(ra) # 80000c98 <release>
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6902                	ld	s2,0(sp)
    80000a5a:	6105                	addi	sp,sp,32
    80000a5c:	8082                	ret
    panic("kfree");
    80000a5e:	00007517          	auipc	a0,0x7
    80000a62:	60250513          	addi	a0,a0,1538 # 80008060 <digits+0x20>
    80000a66:	00000097          	auipc	ra,0x0
    80000a6a:	ad8080e7          	jalr	-1320(ra) # 8000053e <panic>

0000000080000a6e <freerange>:
{
    80000a6e:	7179                	addi	sp,sp,-48
    80000a70:	f406                	sd	ra,40(sp)
    80000a72:	f022                	sd	s0,32(sp)
    80000a74:	ec26                	sd	s1,24(sp)
    80000a76:	e84a                	sd	s2,16(sp)
    80000a78:	e44e                	sd	s3,8(sp)
    80000a7a:	e052                	sd	s4,0(sp)
    80000a7c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a7e:	6785                	lui	a5,0x1
    80000a80:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a84:	94aa                	add	s1,s1,a0
    80000a86:	757d                	lui	a0,0xfffff
    80000a88:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8a:	94be                	add	s1,s1,a5
    80000a8c:	0095ee63          	bltu	a1,s1,80000aa8 <freerange+0x3a>
    80000a90:	892e                	mv	s2,a1
    kfree(p);
    80000a92:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	6985                	lui	s3,0x1
    kfree(p);
    80000a96:	01448533          	add	a0,s1,s4
    80000a9a:	00000097          	auipc	ra,0x0
    80000a9e:	f5e080e7          	jalr	-162(ra) # 800009f8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa2:	94ce                	add	s1,s1,s3
    80000aa4:	fe9979e3          	bgeu	s2,s1,80000a96 <freerange+0x28>
}
    80000aa8:	70a2                	ld	ra,40(sp)
    80000aaa:	7402                	ld	s0,32(sp)
    80000aac:	64e2                	ld	s1,24(sp)
    80000aae:	6942                	ld	s2,16(sp)
    80000ab0:	69a2                	ld	s3,8(sp)
    80000ab2:	6a02                	ld	s4,0(sp)
    80000ab4:	6145                	addi	sp,sp,48
    80000ab6:	8082                	ret

0000000080000ab8 <kinit>:
{
    80000ab8:	1141                	addi	sp,sp,-16
    80000aba:	e406                	sd	ra,8(sp)
    80000abc:	e022                	sd	s0,0(sp)
    80000abe:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ac0:	00007597          	auipc	a1,0x7
    80000ac4:	5a858593          	addi	a1,a1,1448 # 80008068 <digits+0x28>
    80000ac8:	00010517          	auipc	a0,0x10
    80000acc:	7b850513          	addi	a0,a0,1976 # 80011280 <kmem>
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	084080e7          	jalr	132(ra) # 80000b54 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ad8:	45c5                	li	a1,17
    80000ada:	05ee                	slli	a1,a1,0x1b
    80000adc:	00025517          	auipc	a0,0x25
    80000ae0:	52450513          	addi	a0,a0,1316 # 80026000 <end>
    80000ae4:	00000097          	auipc	ra,0x0
    80000ae8:	f8a080e7          	jalr	-118(ra) # 80000a6e <freerange>
}
    80000aec:	60a2                	ld	ra,8(sp)
    80000aee:	6402                	ld	s0,0(sp)
    80000af0:	0141                	addi	sp,sp,16
    80000af2:	8082                	ret

0000000080000af4 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000af4:	1101                	addi	sp,sp,-32
    80000af6:	ec06                	sd	ra,24(sp)
    80000af8:	e822                	sd	s0,16(sp)
    80000afa:	e426                	sd	s1,8(sp)
    80000afc:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000afe:	00010497          	auipc	s1,0x10
    80000b02:	78248493          	addi	s1,s1,1922 # 80011280 <kmem>
    80000b06:	8526                	mv	a0,s1
    80000b08:	00000097          	auipc	ra,0x0
    80000b0c:	0dc080e7          	jalr	220(ra) # 80000be4 <acquire>
  r = kmem.freelist;
    80000b10:	6c84                	ld	s1,24(s1)
  if(r)
    80000b12:	c885                	beqz	s1,80000b42 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b14:	609c                	ld	a5,0(s1)
    80000b16:	00010517          	auipc	a0,0x10
    80000b1a:	76a50513          	addi	a0,a0,1898 # 80011280 <kmem>
    80000b1e:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	178080e7          	jalr	376(ra) # 80000c98 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b28:	6605                	lui	a2,0x1
    80000b2a:	4595                	li	a1,5
    80000b2c:	8526                	mv	a0,s1
    80000b2e:	00000097          	auipc	ra,0x0
    80000b32:	1b2080e7          	jalr	434(ra) # 80000ce0 <memset>
  return (void*)r;
}
    80000b36:	8526                	mv	a0,s1
    80000b38:	60e2                	ld	ra,24(sp)
    80000b3a:	6442                	ld	s0,16(sp)
    80000b3c:	64a2                	ld	s1,8(sp)
    80000b3e:	6105                	addi	sp,sp,32
    80000b40:	8082                	ret
  release(&kmem.lock);
    80000b42:	00010517          	auipc	a0,0x10
    80000b46:	73e50513          	addi	a0,a0,1854 # 80011280 <kmem>
    80000b4a:	00000097          	auipc	ra,0x0
    80000b4e:	14e080e7          	jalr	334(ra) # 80000c98 <release>
  if(r)
    80000b52:	b7d5                	j	80000b36 <kalloc+0x42>

0000000080000b54 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b54:	1141                	addi	sp,sp,-16
    80000b56:	e422                	sd	s0,8(sp)
    80000b58:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b5a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b5c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b60:	00053823          	sd	zero,16(a0)
}
    80000b64:	6422                	ld	s0,8(sp)
    80000b66:	0141                	addi	sp,sp,16
    80000b68:	8082                	ret

0000000080000b6a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	411c                	lw	a5,0(a0)
    80000b6c:	e399                	bnez	a5,80000b72 <holding+0x8>
    80000b6e:	4501                	li	a0,0
  return r;
}
    80000b70:	8082                	ret
{
    80000b72:	1101                	addi	sp,sp,-32
    80000b74:	ec06                	sd	ra,24(sp)
    80000b76:	e822                	sd	s0,16(sp)
    80000b78:	e426                	sd	s1,8(sp)
    80000b7a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b7c:	6904                	ld	s1,16(a0)
    80000b7e:	00001097          	auipc	ra,0x1
    80000b82:	e16080e7          	jalr	-490(ra) # 80001994 <mycpu>
    80000b86:	40a48533          	sub	a0,s1,a0
    80000b8a:	00153513          	seqz	a0,a0
}
    80000b8e:	60e2                	ld	ra,24(sp)
    80000b90:	6442                	ld	s0,16(sp)
    80000b92:	64a2                	ld	s1,8(sp)
    80000b94:	6105                	addi	sp,sp,32
    80000b96:	8082                	ret

0000000080000b98 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b98:	1101                	addi	sp,sp,-32
    80000b9a:	ec06                	sd	ra,24(sp)
    80000b9c:	e822                	sd	s0,16(sp)
    80000b9e:	e426                	sd	s1,8(sp)
    80000ba0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ba2:	100024f3          	csrr	s1,sstatus
    80000ba6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000baa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bac:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bb0:	00001097          	auipc	ra,0x1
    80000bb4:	de4080e7          	jalr	-540(ra) # 80001994 <mycpu>
    80000bb8:	5d3c                	lw	a5,120(a0)
    80000bba:	cf89                	beqz	a5,80000bd4 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bbc:	00001097          	auipc	ra,0x1
    80000bc0:	dd8080e7          	jalr	-552(ra) # 80001994 <mycpu>
    80000bc4:	5d3c                	lw	a5,120(a0)
    80000bc6:	2785                	addiw	a5,a5,1
    80000bc8:	dd3c                	sw	a5,120(a0)
}
    80000bca:	60e2                	ld	ra,24(sp)
    80000bcc:	6442                	ld	s0,16(sp)
    80000bce:	64a2                	ld	s1,8(sp)
    80000bd0:	6105                	addi	sp,sp,32
    80000bd2:	8082                	ret
    mycpu()->intena = old;
    80000bd4:	00001097          	auipc	ra,0x1
    80000bd8:	dc0080e7          	jalr	-576(ra) # 80001994 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bdc:	8085                	srli	s1,s1,0x1
    80000bde:	8885                	andi	s1,s1,1
    80000be0:	dd64                	sw	s1,124(a0)
    80000be2:	bfe9                	j	80000bbc <push_off+0x24>

0000000080000be4 <acquire>:
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
    80000bee:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bf0:	00000097          	auipc	ra,0x0
    80000bf4:	fa8080e7          	jalr	-88(ra) # 80000b98 <push_off>
  if(holding(lk))
    80000bf8:	8526                	mv	a0,s1
    80000bfa:	00000097          	auipc	ra,0x0
    80000bfe:	f70080e7          	jalr	-144(ra) # 80000b6a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c02:	4705                	li	a4,1
  if(holding(lk))
    80000c04:	e115                	bnez	a0,80000c28 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c06:	87ba                	mv	a5,a4
    80000c08:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c0c:	2781                	sext.w	a5,a5
    80000c0e:	ffe5                	bnez	a5,80000c06 <acquire+0x22>
  __sync_synchronize();
    80000c10:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c14:	00001097          	auipc	ra,0x1
    80000c18:	d80080e7          	jalr	-640(ra) # 80001994 <mycpu>
    80000c1c:	e888                	sd	a0,16(s1)
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	addi	sp,sp,32
    80000c26:	8082                	ret
    panic("acquire");
    80000c28:	00007517          	auipc	a0,0x7
    80000c2c:	44850513          	addi	a0,a0,1096 # 80008070 <digits+0x30>
    80000c30:	00000097          	auipc	ra,0x0
    80000c34:	90e080e7          	jalr	-1778(ra) # 8000053e <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	00001097          	auipc	ra,0x1
    80000c44:	d54080e7          	jalr	-684(ra) # 80001994 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c48:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c4c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4e:	e78d                	bnez	a5,80000c78 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c50:	5d3c                	lw	a5,120(a0)
    80000c52:	02f05b63          	blez	a5,80000c88 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c56:	37fd                	addiw	a5,a5,-1
    80000c58:	0007871b          	sext.w	a4,a5
    80000c5c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5e:	eb09                	bnez	a4,80000c70 <pop_off+0x38>
    80000c60:	5d7c                	lw	a5,124(a0)
    80000c62:	c799                	beqz	a5,80000c70 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c64:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c68:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c6c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c70:	60a2                	ld	ra,8(sp)
    80000c72:	6402                	ld	s0,0(sp)
    80000c74:	0141                	addi	sp,sp,16
    80000c76:	8082                	ret
    panic("pop_off - interruptible");
    80000c78:	00007517          	auipc	a0,0x7
    80000c7c:	40050513          	addi	a0,a0,1024 # 80008078 <digits+0x38>
    80000c80:	00000097          	auipc	ra,0x0
    80000c84:	8be080e7          	jalr	-1858(ra) # 8000053e <panic>
    panic("pop_off");
    80000c88:	00007517          	auipc	a0,0x7
    80000c8c:	40850513          	addi	a0,a0,1032 # 80008090 <digits+0x50>
    80000c90:	00000097          	auipc	ra,0x0
    80000c94:	8ae080e7          	jalr	-1874(ra) # 8000053e <panic>

0000000080000c98 <release>:
{
    80000c98:	1101                	addi	sp,sp,-32
    80000c9a:	ec06                	sd	ra,24(sp)
    80000c9c:	e822                	sd	s0,16(sp)
    80000c9e:	e426                	sd	s1,8(sp)
    80000ca0:	1000                	addi	s0,sp,32
    80000ca2:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ca4:	00000097          	auipc	ra,0x0
    80000ca8:	ec6080e7          	jalr	-314(ra) # 80000b6a <holding>
    80000cac:	c115                	beqz	a0,80000cd0 <release+0x38>
  lk->cpu = 0;
    80000cae:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cb6:	0f50000f          	fence	iorw,ow
    80000cba:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cbe:	00000097          	auipc	ra,0x0
    80000cc2:	f7a080e7          	jalr	-134(ra) # 80000c38 <pop_off>
}
    80000cc6:	60e2                	ld	ra,24(sp)
    80000cc8:	6442                	ld	s0,16(sp)
    80000cca:	64a2                	ld	s1,8(sp)
    80000ccc:	6105                	addi	sp,sp,32
    80000cce:	8082                	ret
    panic("release");
    80000cd0:	00007517          	auipc	a0,0x7
    80000cd4:	3c850513          	addi	a0,a0,968 # 80008098 <digits+0x58>
    80000cd8:	00000097          	auipc	ra,0x0
    80000cdc:	866080e7          	jalr	-1946(ra) # 8000053e <panic>

0000000080000ce0 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ce6:	ce09                	beqz	a2,80000d00 <memset+0x20>
    80000ce8:	87aa                	mv	a5,a0
    80000cea:	fff6071b          	addiw	a4,a2,-1
    80000cee:	1702                	slli	a4,a4,0x20
    80000cf0:	9301                	srli	a4,a4,0x20
    80000cf2:	0705                	addi	a4,a4,1
    80000cf4:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000cf6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cfa:	0785                	addi	a5,a5,1
    80000cfc:	fee79de3          	bne	a5,a4,80000cf6 <memset+0x16>
  }
  return dst;
}
    80000d00:	6422                	ld	s0,8(sp)
    80000d02:	0141                	addi	sp,sp,16
    80000d04:	8082                	ret

0000000080000d06 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d06:	1141                	addi	sp,sp,-16
    80000d08:	e422                	sd	s0,8(sp)
    80000d0a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d0c:	ca05                	beqz	a2,80000d3c <memcmp+0x36>
    80000d0e:	fff6069b          	addiw	a3,a2,-1
    80000d12:	1682                	slli	a3,a3,0x20
    80000d14:	9281                	srli	a3,a3,0x20
    80000d16:	0685                	addi	a3,a3,1
    80000d18:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d1a:	00054783          	lbu	a5,0(a0)
    80000d1e:	0005c703          	lbu	a4,0(a1)
    80000d22:	00e79863          	bne	a5,a4,80000d32 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d26:	0505                	addi	a0,a0,1
    80000d28:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d2a:	fed518e3          	bne	a0,a3,80000d1a <memcmp+0x14>
  }

  return 0;
    80000d2e:	4501                	li	a0,0
    80000d30:	a019                	j	80000d36 <memcmp+0x30>
      return *s1 - *s2;
    80000d32:	40e7853b          	subw	a0,a5,a4
}
    80000d36:	6422                	ld	s0,8(sp)
    80000d38:	0141                	addi	sp,sp,16
    80000d3a:	8082                	ret
  return 0;
    80000d3c:	4501                	li	a0,0
    80000d3e:	bfe5                	j	80000d36 <memcmp+0x30>

0000000080000d40 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d40:	1141                	addi	sp,sp,-16
    80000d42:	e422                	sd	s0,8(sp)
    80000d44:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d46:	ca0d                	beqz	a2,80000d78 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d48:	00a5f963          	bgeu	a1,a0,80000d5a <memmove+0x1a>
    80000d4c:	02061693          	slli	a3,a2,0x20
    80000d50:	9281                	srli	a3,a3,0x20
    80000d52:	00d58733          	add	a4,a1,a3
    80000d56:	02e56463          	bltu	a0,a4,80000d7e <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d5a:	fff6079b          	addiw	a5,a2,-1
    80000d5e:	1782                	slli	a5,a5,0x20
    80000d60:	9381                	srli	a5,a5,0x20
    80000d62:	0785                	addi	a5,a5,1
    80000d64:	97ae                	add	a5,a5,a1
    80000d66:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d68:	0585                	addi	a1,a1,1
    80000d6a:	0705                	addi	a4,a4,1
    80000d6c:	fff5c683          	lbu	a3,-1(a1)
    80000d70:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d74:	fef59ae3          	bne	a1,a5,80000d68 <memmove+0x28>

  return dst;
}
    80000d78:	6422                	ld	s0,8(sp)
    80000d7a:	0141                	addi	sp,sp,16
    80000d7c:	8082                	ret
    d += n;
    80000d7e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d80:	fff6079b          	addiw	a5,a2,-1
    80000d84:	1782                	slli	a5,a5,0x20
    80000d86:	9381                	srli	a5,a5,0x20
    80000d88:	fff7c793          	not	a5,a5
    80000d8c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d8e:	177d                	addi	a4,a4,-1
    80000d90:	16fd                	addi	a3,a3,-1
    80000d92:	00074603          	lbu	a2,0(a4)
    80000d96:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d9a:	fef71ae3          	bne	a4,a5,80000d8e <memmove+0x4e>
    80000d9e:	bfe9                	j	80000d78 <memmove+0x38>

0000000080000da0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000da0:	1141                	addi	sp,sp,-16
    80000da2:	e406                	sd	ra,8(sp)
    80000da4:	e022                	sd	s0,0(sp)
    80000da6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000da8:	00000097          	auipc	ra,0x0
    80000dac:	f98080e7          	jalr	-104(ra) # 80000d40 <memmove>
}
    80000db0:	60a2                	ld	ra,8(sp)
    80000db2:	6402                	ld	s0,0(sp)
    80000db4:	0141                	addi	sp,sp,16
    80000db6:	8082                	ret

0000000080000db8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e422                	sd	s0,8(sp)
    80000dbc:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dbe:	ce11                	beqz	a2,80000dda <strncmp+0x22>
    80000dc0:	00054783          	lbu	a5,0(a0)
    80000dc4:	cf89                	beqz	a5,80000dde <strncmp+0x26>
    80000dc6:	0005c703          	lbu	a4,0(a1)
    80000dca:	00f71a63          	bne	a4,a5,80000dde <strncmp+0x26>
    n--, p++, q++;
    80000dce:	367d                	addiw	a2,a2,-1
    80000dd0:	0505                	addi	a0,a0,1
    80000dd2:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dd4:	f675                	bnez	a2,80000dc0 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	a809                	j	80000dea <strncmp+0x32>
    80000dda:	4501                	li	a0,0
    80000ddc:	a039                	j	80000dea <strncmp+0x32>
  if(n == 0)
    80000dde:	ca09                	beqz	a2,80000df0 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000de0:	00054503          	lbu	a0,0(a0)
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	9d1d                	subw	a0,a0,a5
}
    80000dea:	6422                	ld	s0,8(sp)
    80000dec:	0141                	addi	sp,sp,16
    80000dee:	8082                	ret
    return 0;
    80000df0:	4501                	li	a0,0
    80000df2:	bfe5                	j	80000dea <strncmp+0x32>

0000000080000df4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000df4:	1141                	addi	sp,sp,-16
    80000df6:	e422                	sd	s0,8(sp)
    80000df8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dfa:	872a                	mv	a4,a0
    80000dfc:	8832                	mv	a6,a2
    80000dfe:	367d                	addiw	a2,a2,-1
    80000e00:	01005963          	blez	a6,80000e12 <strncpy+0x1e>
    80000e04:	0705                	addi	a4,a4,1
    80000e06:	0005c783          	lbu	a5,0(a1)
    80000e0a:	fef70fa3          	sb	a5,-1(a4)
    80000e0e:	0585                	addi	a1,a1,1
    80000e10:	f7f5                	bnez	a5,80000dfc <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e12:	00c05d63          	blez	a2,80000e2c <strncpy+0x38>
    80000e16:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e18:	0685                	addi	a3,a3,1
    80000e1a:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e1e:	fff6c793          	not	a5,a3
    80000e22:	9fb9                	addw	a5,a5,a4
    80000e24:	010787bb          	addw	a5,a5,a6
    80000e28:	fef048e3          	bgtz	a5,80000e18 <strncpy+0x24>
  return os;
}
    80000e2c:	6422                	ld	s0,8(sp)
    80000e2e:	0141                	addi	sp,sp,16
    80000e30:	8082                	ret

0000000080000e32 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e32:	1141                	addi	sp,sp,-16
    80000e34:	e422                	sd	s0,8(sp)
    80000e36:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e38:	02c05363          	blez	a2,80000e5e <safestrcpy+0x2c>
    80000e3c:	fff6069b          	addiw	a3,a2,-1
    80000e40:	1682                	slli	a3,a3,0x20
    80000e42:	9281                	srli	a3,a3,0x20
    80000e44:	96ae                	add	a3,a3,a1
    80000e46:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e48:	00d58963          	beq	a1,a3,80000e5a <safestrcpy+0x28>
    80000e4c:	0585                	addi	a1,a1,1
    80000e4e:	0785                	addi	a5,a5,1
    80000e50:	fff5c703          	lbu	a4,-1(a1)
    80000e54:	fee78fa3          	sb	a4,-1(a5)
    80000e58:	fb65                	bnez	a4,80000e48 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e5a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e5e:	6422                	ld	s0,8(sp)
    80000e60:	0141                	addi	sp,sp,16
    80000e62:	8082                	ret

0000000080000e64 <strlen>:

int
strlen(const char *s)
{
    80000e64:	1141                	addi	sp,sp,-16
    80000e66:	e422                	sd	s0,8(sp)
    80000e68:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e6a:	00054783          	lbu	a5,0(a0)
    80000e6e:	cf91                	beqz	a5,80000e8a <strlen+0x26>
    80000e70:	0505                	addi	a0,a0,1
    80000e72:	87aa                	mv	a5,a0
    80000e74:	4685                	li	a3,1
    80000e76:	9e89                	subw	a3,a3,a0
    80000e78:	00f6853b          	addw	a0,a3,a5
    80000e7c:	0785                	addi	a5,a5,1
    80000e7e:	fff7c703          	lbu	a4,-1(a5)
    80000e82:	fb7d                	bnez	a4,80000e78 <strlen+0x14>
    ;
  return n;
}
    80000e84:	6422                	ld	s0,8(sp)
    80000e86:	0141                	addi	sp,sp,16
    80000e88:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e8a:	4501                	li	a0,0
    80000e8c:	bfe5                	j	80000e84 <strlen+0x20>

0000000080000e8e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e8e:	1141                	addi	sp,sp,-16
    80000e90:	e406                	sd	ra,8(sp)
    80000e92:	e022                	sd	s0,0(sp)
    80000e94:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	aee080e7          	jalr	-1298(ra) # 80001984 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e9e:	00008717          	auipc	a4,0x8
    80000ea2:	17a70713          	addi	a4,a4,378 # 80009018 <started>
  if(cpuid() == 0){
    80000ea6:	c139                	beqz	a0,80000eec <main+0x5e>
    while(started == 0)
    80000ea8:	431c                	lw	a5,0(a4)
    80000eaa:	2781                	sext.w	a5,a5
    80000eac:	dff5                	beqz	a5,80000ea8 <main+0x1a>
      ;
    __sync_synchronize();
    80000eae:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb2:	00001097          	auipc	ra,0x1
    80000eb6:	ad2080e7          	jalr	-1326(ra) # 80001984 <cpuid>
    80000eba:	85aa                	mv	a1,a0
    80000ebc:	00007517          	auipc	a0,0x7
    80000ec0:	1fc50513          	addi	a0,a0,508 # 800080b8 <digits+0x78>
    80000ec4:	fffff097          	auipc	ra,0xfffff
    80000ec8:	6c4080e7          	jalr	1732(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000ecc:	00000097          	auipc	ra,0x0
    80000ed0:	0d8080e7          	jalr	216(ra) # 80000fa4 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ed4:	00002097          	auipc	ra,0x2
    80000ed8:	dc2080e7          	jalr	-574(ra) # 80002c96 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000edc:	00005097          	auipc	ra,0x5
    80000ee0:	454080e7          	jalr	1108(ra) # 80006330 <plicinithart>
  }

  scheduler();        
    80000ee4:	00001097          	auipc	ra,0x1
    80000ee8:	1ce080e7          	jalr	462(ra) # 800020b2 <scheduler>
    consoleinit();
    80000eec:	fffff097          	auipc	ra,0xfffff
    80000ef0:	564080e7          	jalr	1380(ra) # 80000450 <consoleinit>
    printfinit();
    80000ef4:	00000097          	auipc	ra,0x0
    80000ef8:	87a080e7          	jalr	-1926(ra) # 8000076e <printfinit>
    printf("\n");
    80000efc:	00007517          	auipc	a0,0x7
    80000f00:	1cc50513          	addi	a0,a0,460 # 800080c8 <digits+0x88>
    80000f04:	fffff097          	auipc	ra,0xfffff
    80000f08:	684080e7          	jalr	1668(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000f0c:	00007517          	auipc	a0,0x7
    80000f10:	19450513          	addi	a0,a0,404 # 800080a0 <digits+0x60>
    80000f14:	fffff097          	auipc	ra,0xfffff
    80000f18:	674080e7          	jalr	1652(ra) # 80000588 <printf>
    printf("\n");
    80000f1c:	00007517          	auipc	a0,0x7
    80000f20:	1ac50513          	addi	a0,a0,428 # 800080c8 <digits+0x88>
    80000f24:	fffff097          	auipc	ra,0xfffff
    80000f28:	664080e7          	jalr	1636(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f2c:	00000097          	auipc	ra,0x0
    80000f30:	b8c080e7          	jalr	-1140(ra) # 80000ab8 <kinit>
    kvminit();       // create kernel page table
    80000f34:	00000097          	auipc	ra,0x0
    80000f38:	322080e7          	jalr	802(ra) # 80001256 <kvminit>
    kvminithart();   // turn on paging
    80000f3c:	00000097          	auipc	ra,0x0
    80000f40:	068080e7          	jalr	104(ra) # 80000fa4 <kvminithart>
    procinit();      // process table
    80000f44:	00001097          	auipc	ra,0x1
    80000f48:	990080e7          	jalr	-1648(ra) # 800018d4 <procinit>
    trapinit();      // trap vectors
    80000f4c:	00002097          	auipc	ra,0x2
    80000f50:	d22080e7          	jalr	-734(ra) # 80002c6e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f54:	00002097          	auipc	ra,0x2
    80000f58:	d42080e7          	jalr	-702(ra) # 80002c96 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f5c:	00005097          	auipc	ra,0x5
    80000f60:	3be080e7          	jalr	958(ra) # 8000631a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f64:	00005097          	auipc	ra,0x5
    80000f68:	3cc080e7          	jalr	972(ra) # 80006330 <plicinithart>
    binit();         // buffer cache
    80000f6c:	00002097          	auipc	ra,0x2
    80000f70:	5b0080e7          	jalr	1456(ra) # 8000351c <binit>
    iinit();         // inode table
    80000f74:	00003097          	auipc	ra,0x3
    80000f78:	c40080e7          	jalr	-960(ra) # 80003bb4 <iinit>
    fileinit();      // file table
    80000f7c:	00004097          	auipc	ra,0x4
    80000f80:	bea080e7          	jalr	-1046(ra) # 80004b66 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f84:	00005097          	auipc	ra,0x5
    80000f88:	4ce080e7          	jalr	1230(ra) # 80006452 <virtio_disk_init>
    userinit();      // first user process
    80000f8c:	00001097          	auipc	ra,0x1
    80000f90:	d44080e7          	jalr	-700(ra) # 80001cd0 <userinit>
    __sync_synchronize();
    80000f94:	0ff0000f          	fence
    started = 1;
    80000f98:	4785                	li	a5,1
    80000f9a:	00008717          	auipc	a4,0x8
    80000f9e:	06f72f23          	sw	a5,126(a4) # 80009018 <started>
    80000fa2:	b789                	j	80000ee4 <main+0x56>

0000000080000fa4 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fa4:	1141                	addi	sp,sp,-16
    80000fa6:	e422                	sd	s0,8(sp)
    80000fa8:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000faa:	00008797          	auipc	a5,0x8
    80000fae:	0767b783          	ld	a5,118(a5) # 80009020 <kernel_pagetable>
    80000fb2:	83b1                	srli	a5,a5,0xc
    80000fb4:	577d                	li	a4,-1
    80000fb6:	177e                	slli	a4,a4,0x3f
    80000fb8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fba:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fbe:	12000073          	sfence.vma
  sfence_vma();
}
    80000fc2:	6422                	ld	s0,8(sp)
    80000fc4:	0141                	addi	sp,sp,16
    80000fc6:	8082                	ret

0000000080000fc8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc8:	7139                	addi	sp,sp,-64
    80000fca:	fc06                	sd	ra,56(sp)
    80000fcc:	f822                	sd	s0,48(sp)
    80000fce:	f426                	sd	s1,40(sp)
    80000fd0:	f04a                	sd	s2,32(sp)
    80000fd2:	ec4e                	sd	s3,24(sp)
    80000fd4:	e852                	sd	s4,16(sp)
    80000fd6:	e456                	sd	s5,8(sp)
    80000fd8:	e05a                	sd	s6,0(sp)
    80000fda:	0080                	addi	s0,sp,64
    80000fdc:	84aa                	mv	s1,a0
    80000fde:	89ae                	mv	s3,a1
    80000fe0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fe2:	57fd                	li	a5,-1
    80000fe4:	83e9                	srli	a5,a5,0x1a
    80000fe6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe8:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fea:	04b7f263          	bgeu	a5,a1,8000102e <walk+0x66>
    panic("walk");
    80000fee:	00007517          	auipc	a0,0x7
    80000ff2:	0e250513          	addi	a0,a0,226 # 800080d0 <digits+0x90>
    80000ff6:	fffff097          	auipc	ra,0xfffff
    80000ffa:	548080e7          	jalr	1352(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffe:	060a8663          	beqz	s5,8000106a <walk+0xa2>
    80001002:	00000097          	auipc	ra,0x0
    80001006:	af2080e7          	jalr	-1294(ra) # 80000af4 <kalloc>
    8000100a:	84aa                	mv	s1,a0
    8000100c:	c529                	beqz	a0,80001056 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000100e:	6605                	lui	a2,0x1
    80001010:	4581                	li	a1,0
    80001012:	00000097          	auipc	ra,0x0
    80001016:	cce080e7          	jalr	-818(ra) # 80000ce0 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000101a:	00c4d793          	srli	a5,s1,0xc
    8000101e:	07aa                	slli	a5,a5,0xa
    80001020:	0017e793          	ori	a5,a5,1
    80001024:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001028:	3a5d                	addiw	s4,s4,-9
    8000102a:	036a0063          	beq	s4,s6,8000104a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000102e:	0149d933          	srl	s2,s3,s4
    80001032:	1ff97913          	andi	s2,s2,511
    80001036:	090e                	slli	s2,s2,0x3
    80001038:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000103a:	00093483          	ld	s1,0(s2)
    8000103e:	0014f793          	andi	a5,s1,1
    80001042:	dfd5                	beqz	a5,80000ffe <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001044:	80a9                	srli	s1,s1,0xa
    80001046:	04b2                	slli	s1,s1,0xc
    80001048:	b7c5                	j	80001028 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000104a:	00c9d513          	srli	a0,s3,0xc
    8000104e:	1ff57513          	andi	a0,a0,511
    80001052:	050e                	slli	a0,a0,0x3
    80001054:	9526                	add	a0,a0,s1
}
    80001056:	70e2                	ld	ra,56(sp)
    80001058:	7442                	ld	s0,48(sp)
    8000105a:	74a2                	ld	s1,40(sp)
    8000105c:	7902                	ld	s2,32(sp)
    8000105e:	69e2                	ld	s3,24(sp)
    80001060:	6a42                	ld	s4,16(sp)
    80001062:	6aa2                	ld	s5,8(sp)
    80001064:	6b02                	ld	s6,0(sp)
    80001066:	6121                	addi	sp,sp,64
    80001068:	8082                	ret
        return 0;
    8000106a:	4501                	li	a0,0
    8000106c:	b7ed                	j	80001056 <walk+0x8e>

000000008000106e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000106e:	57fd                	li	a5,-1
    80001070:	83e9                	srli	a5,a5,0x1a
    80001072:	00b7f463          	bgeu	a5,a1,8000107a <walkaddr+0xc>
    return 0;
    80001076:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001078:	8082                	ret
{
    8000107a:	1141                	addi	sp,sp,-16
    8000107c:	e406                	sd	ra,8(sp)
    8000107e:	e022                	sd	s0,0(sp)
    80001080:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001082:	4601                	li	a2,0
    80001084:	00000097          	auipc	ra,0x0
    80001088:	f44080e7          	jalr	-188(ra) # 80000fc8 <walk>
  if(pte == 0)
    8000108c:	c105                	beqz	a0,800010ac <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000108e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001090:	0117f693          	andi	a3,a5,17
    80001094:	4745                	li	a4,17
    return 0;
    80001096:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001098:	00e68663          	beq	a3,a4,800010a4 <walkaddr+0x36>
}
    8000109c:	60a2                	ld	ra,8(sp)
    8000109e:	6402                	ld	s0,0(sp)
    800010a0:	0141                	addi	sp,sp,16
    800010a2:	8082                	ret
  pa = PTE2PA(*pte);
    800010a4:	00a7d513          	srli	a0,a5,0xa
    800010a8:	0532                	slli	a0,a0,0xc
  return pa;
    800010aa:	bfcd                	j	8000109c <walkaddr+0x2e>
    return 0;
    800010ac:	4501                	li	a0,0
    800010ae:	b7fd                	j	8000109c <walkaddr+0x2e>

00000000800010b0 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010b0:	715d                	addi	sp,sp,-80
    800010b2:	e486                	sd	ra,72(sp)
    800010b4:	e0a2                	sd	s0,64(sp)
    800010b6:	fc26                	sd	s1,56(sp)
    800010b8:	f84a                	sd	s2,48(sp)
    800010ba:	f44e                	sd	s3,40(sp)
    800010bc:	f052                	sd	s4,32(sp)
    800010be:	ec56                	sd	s5,24(sp)
    800010c0:	e85a                	sd	s6,16(sp)
    800010c2:	e45e                	sd	s7,8(sp)
    800010c4:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010c6:	c205                	beqz	a2,800010e6 <mappages+0x36>
    800010c8:	8aaa                	mv	s5,a0
    800010ca:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010cc:	77fd                	lui	a5,0xfffff
    800010ce:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010d2:	15fd                	addi	a1,a1,-1
    800010d4:	00c589b3          	add	s3,a1,a2
    800010d8:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010dc:	8952                	mv	s2,s4
    800010de:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010e2:	6b85                	lui	s7,0x1
    800010e4:	a015                	j	80001108 <mappages+0x58>
    panic("mappages: size");
    800010e6:	00007517          	auipc	a0,0x7
    800010ea:	ff250513          	addi	a0,a0,-14 # 800080d8 <digits+0x98>
    800010ee:	fffff097          	auipc	ra,0xfffff
    800010f2:	450080e7          	jalr	1104(ra) # 8000053e <panic>
      panic("mappages: remap");
    800010f6:	00007517          	auipc	a0,0x7
    800010fa:	ff250513          	addi	a0,a0,-14 # 800080e8 <digits+0xa8>
    800010fe:	fffff097          	auipc	ra,0xfffff
    80001102:	440080e7          	jalr	1088(ra) # 8000053e <panic>
    a += PGSIZE;
    80001106:	995e                	add	s2,s2,s7
  for(;;){
    80001108:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000110c:	4605                	li	a2,1
    8000110e:	85ca                	mv	a1,s2
    80001110:	8556                	mv	a0,s5
    80001112:	00000097          	auipc	ra,0x0
    80001116:	eb6080e7          	jalr	-330(ra) # 80000fc8 <walk>
    8000111a:	cd19                	beqz	a0,80001138 <mappages+0x88>
    if(*pte & PTE_V)
    8000111c:	611c                	ld	a5,0(a0)
    8000111e:	8b85                	andi	a5,a5,1
    80001120:	fbf9                	bnez	a5,800010f6 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001122:	80b1                	srli	s1,s1,0xc
    80001124:	04aa                	slli	s1,s1,0xa
    80001126:	0164e4b3          	or	s1,s1,s6
    8000112a:	0014e493          	ori	s1,s1,1
    8000112e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001130:	fd391be3          	bne	s2,s3,80001106 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	a011                	j	8000113a <mappages+0x8a>
      return -1;
    80001138:	557d                	li	a0,-1
}
    8000113a:	60a6                	ld	ra,72(sp)
    8000113c:	6406                	ld	s0,64(sp)
    8000113e:	74e2                	ld	s1,56(sp)
    80001140:	7942                	ld	s2,48(sp)
    80001142:	79a2                	ld	s3,40(sp)
    80001144:	7a02                	ld	s4,32(sp)
    80001146:	6ae2                	ld	s5,24(sp)
    80001148:	6b42                	ld	s6,16(sp)
    8000114a:	6ba2                	ld	s7,8(sp)
    8000114c:	6161                	addi	sp,sp,80
    8000114e:	8082                	ret

0000000080001150 <kvmmap>:
{
    80001150:	1141                	addi	sp,sp,-16
    80001152:	e406                	sd	ra,8(sp)
    80001154:	e022                	sd	s0,0(sp)
    80001156:	0800                	addi	s0,sp,16
    80001158:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000115a:	86b2                	mv	a3,a2
    8000115c:	863e                	mv	a2,a5
    8000115e:	00000097          	auipc	ra,0x0
    80001162:	f52080e7          	jalr	-174(ra) # 800010b0 <mappages>
    80001166:	e509                	bnez	a0,80001170 <kvmmap+0x20>
}
    80001168:	60a2                	ld	ra,8(sp)
    8000116a:	6402                	ld	s0,0(sp)
    8000116c:	0141                	addi	sp,sp,16
    8000116e:	8082                	ret
    panic("kvmmap");
    80001170:	00007517          	auipc	a0,0x7
    80001174:	f8850513          	addi	a0,a0,-120 # 800080f8 <digits+0xb8>
    80001178:	fffff097          	auipc	ra,0xfffff
    8000117c:	3c6080e7          	jalr	966(ra) # 8000053e <panic>

0000000080001180 <kvmmake>:
{
    80001180:	1101                	addi	sp,sp,-32
    80001182:	ec06                	sd	ra,24(sp)
    80001184:	e822                	sd	s0,16(sp)
    80001186:	e426                	sd	s1,8(sp)
    80001188:	e04a                	sd	s2,0(sp)
    8000118a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000118c:	00000097          	auipc	ra,0x0
    80001190:	968080e7          	jalr	-1688(ra) # 80000af4 <kalloc>
    80001194:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001196:	6605                	lui	a2,0x1
    80001198:	4581                	li	a1,0
    8000119a:	00000097          	auipc	ra,0x0
    8000119e:	b46080e7          	jalr	-1210(ra) # 80000ce0 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011a2:	4719                	li	a4,6
    800011a4:	6685                	lui	a3,0x1
    800011a6:	10000637          	lui	a2,0x10000
    800011aa:	100005b7          	lui	a1,0x10000
    800011ae:	8526                	mv	a0,s1
    800011b0:	00000097          	auipc	ra,0x0
    800011b4:	fa0080e7          	jalr	-96(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011b8:	4719                	li	a4,6
    800011ba:	6685                	lui	a3,0x1
    800011bc:	10001637          	lui	a2,0x10001
    800011c0:	100015b7          	lui	a1,0x10001
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f8a080e7          	jalr	-118(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011ce:	4719                	li	a4,6
    800011d0:	004006b7          	lui	a3,0x400
    800011d4:	0c000637          	lui	a2,0xc000
    800011d8:	0c0005b7          	lui	a1,0xc000
    800011dc:	8526                	mv	a0,s1
    800011de:	00000097          	auipc	ra,0x0
    800011e2:	f72080e7          	jalr	-142(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011e6:	00007917          	auipc	s2,0x7
    800011ea:	e1a90913          	addi	s2,s2,-486 # 80008000 <etext>
    800011ee:	4729                	li	a4,10
    800011f0:	80007697          	auipc	a3,0x80007
    800011f4:	e1068693          	addi	a3,a3,-496 # 8000 <_entry-0x7fff8000>
    800011f8:	4605                	li	a2,1
    800011fa:	067e                	slli	a2,a2,0x1f
    800011fc:	85b2                	mv	a1,a2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f50080e7          	jalr	-176(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001208:	4719                	li	a4,6
    8000120a:	46c5                	li	a3,17
    8000120c:	06ee                	slli	a3,a3,0x1b
    8000120e:	412686b3          	sub	a3,a3,s2
    80001212:	864a                	mv	a2,s2
    80001214:	85ca                	mv	a1,s2
    80001216:	8526                	mv	a0,s1
    80001218:	00000097          	auipc	ra,0x0
    8000121c:	f38080e7          	jalr	-200(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001220:	4729                	li	a4,10
    80001222:	6685                	lui	a3,0x1
    80001224:	00006617          	auipc	a2,0x6
    80001228:	ddc60613          	addi	a2,a2,-548 # 80007000 <_trampoline>
    8000122c:	040005b7          	lui	a1,0x4000
    80001230:	15fd                	addi	a1,a1,-1
    80001232:	05b2                	slli	a1,a1,0xc
    80001234:	8526                	mv	a0,s1
    80001236:	00000097          	auipc	ra,0x0
    8000123a:	f1a080e7          	jalr	-230(ra) # 80001150 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000123e:	8526                	mv	a0,s1
    80001240:	00000097          	auipc	ra,0x0
    80001244:	5fe080e7          	jalr	1534(ra) # 8000183e <proc_mapstacks>
}
    80001248:	8526                	mv	a0,s1
    8000124a:	60e2                	ld	ra,24(sp)
    8000124c:	6442                	ld	s0,16(sp)
    8000124e:	64a2                	ld	s1,8(sp)
    80001250:	6902                	ld	s2,0(sp)
    80001252:	6105                	addi	sp,sp,32
    80001254:	8082                	ret

0000000080001256 <kvminit>:
{
    80001256:	1141                	addi	sp,sp,-16
    80001258:	e406                	sd	ra,8(sp)
    8000125a:	e022                	sd	s0,0(sp)
    8000125c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f22080e7          	jalr	-222(ra) # 80001180 <kvmmake>
    80001266:	00008797          	auipc	a5,0x8
    8000126a:	daa7bd23          	sd	a0,-582(a5) # 80009020 <kernel_pagetable>
}
    8000126e:	60a2                	ld	ra,8(sp)
    80001270:	6402                	ld	s0,0(sp)
    80001272:	0141                	addi	sp,sp,16
    80001274:	8082                	ret

0000000080001276 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001276:	715d                	addi	sp,sp,-80
    80001278:	e486                	sd	ra,72(sp)
    8000127a:	e0a2                	sd	s0,64(sp)
    8000127c:	fc26                	sd	s1,56(sp)
    8000127e:	f84a                	sd	s2,48(sp)
    80001280:	f44e                	sd	s3,40(sp)
    80001282:	f052                	sd	s4,32(sp)
    80001284:	ec56                	sd	s5,24(sp)
    80001286:	e85a                	sd	s6,16(sp)
    80001288:	e45e                	sd	s7,8(sp)
    8000128a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000128c:	03459793          	slli	a5,a1,0x34
    80001290:	e795                	bnez	a5,800012bc <uvmunmap+0x46>
    80001292:	8a2a                	mv	s4,a0
    80001294:	892e                	mv	s2,a1
    80001296:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001298:	0632                	slli	a2,a2,0xc
    8000129a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000129e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a0:	6b05                	lui	s6,0x1
    800012a2:	0735e863          	bltu	a1,s3,80001312 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012a6:	60a6                	ld	ra,72(sp)
    800012a8:	6406                	ld	s0,64(sp)
    800012aa:	74e2                	ld	s1,56(sp)
    800012ac:	7942                	ld	s2,48(sp)
    800012ae:	79a2                	ld	s3,40(sp)
    800012b0:	7a02                	ld	s4,32(sp)
    800012b2:	6ae2                	ld	s5,24(sp)
    800012b4:	6b42                	ld	s6,16(sp)
    800012b6:	6ba2                	ld	s7,8(sp)
    800012b8:	6161                	addi	sp,sp,80
    800012ba:	8082                	ret
    panic("uvmunmap: not aligned");
    800012bc:	00007517          	auipc	a0,0x7
    800012c0:	e4450513          	addi	a0,a0,-444 # 80008100 <digits+0xc0>
    800012c4:	fffff097          	auipc	ra,0xfffff
    800012c8:	27a080e7          	jalr	634(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012cc:	00007517          	auipc	a0,0x7
    800012d0:	e4c50513          	addi	a0,a0,-436 # 80008118 <digits+0xd8>
    800012d4:	fffff097          	auipc	ra,0xfffff
    800012d8:	26a080e7          	jalr	618(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012dc:	00007517          	auipc	a0,0x7
    800012e0:	e4c50513          	addi	a0,a0,-436 # 80008128 <digits+0xe8>
    800012e4:	fffff097          	auipc	ra,0xfffff
    800012e8:	25a080e7          	jalr	602(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012ec:	00007517          	auipc	a0,0x7
    800012f0:	e5450513          	addi	a0,a0,-428 # 80008140 <digits+0x100>
    800012f4:	fffff097          	auipc	ra,0xfffff
    800012f8:	24a080e7          	jalr	586(ra) # 8000053e <panic>
      uint64 pa = PTE2PA(*pte);
    800012fc:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012fe:	0532                	slli	a0,a0,0xc
    80001300:	fffff097          	auipc	ra,0xfffff
    80001304:	6f8080e7          	jalr	1784(ra) # 800009f8 <kfree>
    *pte = 0;
    80001308:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130c:	995a                	add	s2,s2,s6
    8000130e:	f9397ce3          	bgeu	s2,s3,800012a6 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001312:	4601                	li	a2,0
    80001314:	85ca                	mv	a1,s2
    80001316:	8552                	mv	a0,s4
    80001318:	00000097          	auipc	ra,0x0
    8000131c:	cb0080e7          	jalr	-848(ra) # 80000fc8 <walk>
    80001320:	84aa                	mv	s1,a0
    80001322:	d54d                	beqz	a0,800012cc <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001324:	6108                	ld	a0,0(a0)
    80001326:	00157793          	andi	a5,a0,1
    8000132a:	dbcd                	beqz	a5,800012dc <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000132c:	3ff57793          	andi	a5,a0,1023
    80001330:	fb778ee3          	beq	a5,s7,800012ec <uvmunmap+0x76>
    if(do_free){
    80001334:	fc0a8ae3          	beqz	s5,80001308 <uvmunmap+0x92>
    80001338:	b7d1                	j	800012fc <uvmunmap+0x86>

000000008000133a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000133a:	1101                	addi	sp,sp,-32
    8000133c:	ec06                	sd	ra,24(sp)
    8000133e:	e822                	sd	s0,16(sp)
    80001340:	e426                	sd	s1,8(sp)
    80001342:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001344:	fffff097          	auipc	ra,0xfffff
    80001348:	7b0080e7          	jalr	1968(ra) # 80000af4 <kalloc>
    8000134c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000134e:	c519                	beqz	a0,8000135c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001350:	6605                	lui	a2,0x1
    80001352:	4581                	li	a1,0
    80001354:	00000097          	auipc	ra,0x0
    80001358:	98c080e7          	jalr	-1652(ra) # 80000ce0 <memset>
  return pagetable;
}
    8000135c:	8526                	mv	a0,s1
    8000135e:	60e2                	ld	ra,24(sp)
    80001360:	6442                	ld	s0,16(sp)
    80001362:	64a2                	ld	s1,8(sp)
    80001364:	6105                	addi	sp,sp,32
    80001366:	8082                	ret

0000000080001368 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001368:	7179                	addi	sp,sp,-48
    8000136a:	f406                	sd	ra,40(sp)
    8000136c:	f022                	sd	s0,32(sp)
    8000136e:	ec26                	sd	s1,24(sp)
    80001370:	e84a                	sd	s2,16(sp)
    80001372:	e44e                	sd	s3,8(sp)
    80001374:	e052                	sd	s4,0(sp)
    80001376:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001378:	6785                	lui	a5,0x1
    8000137a:	04f67863          	bgeu	a2,a5,800013ca <uvminit+0x62>
    8000137e:	8a2a                	mv	s4,a0
    80001380:	89ae                	mv	s3,a1
    80001382:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001384:	fffff097          	auipc	ra,0xfffff
    80001388:	770080e7          	jalr	1904(ra) # 80000af4 <kalloc>
    8000138c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000138e:	6605                	lui	a2,0x1
    80001390:	4581                	li	a1,0
    80001392:	00000097          	auipc	ra,0x0
    80001396:	94e080e7          	jalr	-1714(ra) # 80000ce0 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000139a:	4779                	li	a4,30
    8000139c:	86ca                	mv	a3,s2
    8000139e:	6605                	lui	a2,0x1
    800013a0:	4581                	li	a1,0
    800013a2:	8552                	mv	a0,s4
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	d0c080e7          	jalr	-756(ra) # 800010b0 <mappages>
  memmove(mem, src, sz);
    800013ac:	8626                	mv	a2,s1
    800013ae:	85ce                	mv	a1,s3
    800013b0:	854a                	mv	a0,s2
    800013b2:	00000097          	auipc	ra,0x0
    800013b6:	98e080e7          	jalr	-1650(ra) # 80000d40 <memmove>
}
    800013ba:	70a2                	ld	ra,40(sp)
    800013bc:	7402                	ld	s0,32(sp)
    800013be:	64e2                	ld	s1,24(sp)
    800013c0:	6942                	ld	s2,16(sp)
    800013c2:	69a2                	ld	s3,8(sp)
    800013c4:	6a02                	ld	s4,0(sp)
    800013c6:	6145                	addi	sp,sp,48
    800013c8:	8082                	ret
    panic("inituvm: more than a page");
    800013ca:	00007517          	auipc	a0,0x7
    800013ce:	d8e50513          	addi	a0,a0,-626 # 80008158 <digits+0x118>
    800013d2:	fffff097          	auipc	ra,0xfffff
    800013d6:	16c080e7          	jalr	364(ra) # 8000053e <panic>

00000000800013da <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013da:	1101                	addi	sp,sp,-32
    800013dc:	ec06                	sd	ra,24(sp)
    800013de:	e822                	sd	s0,16(sp)
    800013e0:	e426                	sd	s1,8(sp)
    800013e2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013e4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013e6:	00b67d63          	bgeu	a2,a1,80001400 <uvmdealloc+0x26>
    800013ea:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013ec:	6785                	lui	a5,0x1
    800013ee:	17fd                	addi	a5,a5,-1
    800013f0:	00f60733          	add	a4,a2,a5
    800013f4:	767d                	lui	a2,0xfffff
    800013f6:	8f71                	and	a4,a4,a2
    800013f8:	97ae                	add	a5,a5,a1
    800013fa:	8ff1                	and	a5,a5,a2
    800013fc:	00f76863          	bltu	a4,a5,8000140c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001400:	8526                	mv	a0,s1
    80001402:	60e2                	ld	ra,24(sp)
    80001404:	6442                	ld	s0,16(sp)
    80001406:	64a2                	ld	s1,8(sp)
    80001408:	6105                	addi	sp,sp,32
    8000140a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000140c:	8f99                	sub	a5,a5,a4
    8000140e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001410:	4685                	li	a3,1
    80001412:	0007861b          	sext.w	a2,a5
    80001416:	85ba                	mv	a1,a4
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	e5e080e7          	jalr	-418(ra) # 80001276 <uvmunmap>
    80001420:	b7c5                	j	80001400 <uvmdealloc+0x26>

0000000080001422 <uvmalloc>:
  if(newsz < oldsz)
    80001422:	0ab66163          	bltu	a2,a1,800014c4 <uvmalloc+0xa2>
{
    80001426:	7139                	addi	sp,sp,-64
    80001428:	fc06                	sd	ra,56(sp)
    8000142a:	f822                	sd	s0,48(sp)
    8000142c:	f426                	sd	s1,40(sp)
    8000142e:	f04a                	sd	s2,32(sp)
    80001430:	ec4e                	sd	s3,24(sp)
    80001432:	e852                	sd	s4,16(sp)
    80001434:	e456                	sd	s5,8(sp)
    80001436:	0080                	addi	s0,sp,64
    80001438:	8aaa                	mv	s5,a0
    8000143a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000143c:	6985                	lui	s3,0x1
    8000143e:	19fd                	addi	s3,s3,-1
    80001440:	95ce                	add	a1,a1,s3
    80001442:	79fd                	lui	s3,0xfffff
    80001444:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001448:	08c9f063          	bgeu	s3,a2,800014c8 <uvmalloc+0xa6>
    8000144c:	894e                	mv	s2,s3
    mem = kalloc();
    8000144e:	fffff097          	auipc	ra,0xfffff
    80001452:	6a6080e7          	jalr	1702(ra) # 80000af4 <kalloc>
    80001456:	84aa                	mv	s1,a0
    if(mem == 0){
    80001458:	c51d                	beqz	a0,80001486 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000145a:	6605                	lui	a2,0x1
    8000145c:	4581                	li	a1,0
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	882080e7          	jalr	-1918(ra) # 80000ce0 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001466:	4779                	li	a4,30
    80001468:	86a6                	mv	a3,s1
    8000146a:	6605                	lui	a2,0x1
    8000146c:	85ca                	mv	a1,s2
    8000146e:	8556                	mv	a0,s5
    80001470:	00000097          	auipc	ra,0x0
    80001474:	c40080e7          	jalr	-960(ra) # 800010b0 <mappages>
    80001478:	e905                	bnez	a0,800014a8 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000147a:	6785                	lui	a5,0x1
    8000147c:	993e                	add	s2,s2,a5
    8000147e:	fd4968e3          	bltu	s2,s4,8000144e <uvmalloc+0x2c>
  return newsz;
    80001482:	8552                	mv	a0,s4
    80001484:	a809                	j	80001496 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001486:	864e                	mv	a2,s3
    80001488:	85ca                	mv	a1,s2
    8000148a:	8556                	mv	a0,s5
    8000148c:	00000097          	auipc	ra,0x0
    80001490:	f4e080e7          	jalr	-178(ra) # 800013da <uvmdealloc>
      return 0;
    80001494:	4501                	li	a0,0
}
    80001496:	70e2                	ld	ra,56(sp)
    80001498:	7442                	ld	s0,48(sp)
    8000149a:	74a2                	ld	s1,40(sp)
    8000149c:	7902                	ld	s2,32(sp)
    8000149e:	69e2                	ld	s3,24(sp)
    800014a0:	6a42                	ld	s4,16(sp)
    800014a2:	6aa2                	ld	s5,8(sp)
    800014a4:	6121                	addi	sp,sp,64
    800014a6:	8082                	ret
      kfree(mem);
    800014a8:	8526                	mv	a0,s1
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	54e080e7          	jalr	1358(ra) # 800009f8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b2:	864e                	mv	a2,s3
    800014b4:	85ca                	mv	a1,s2
    800014b6:	8556                	mv	a0,s5
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	f22080e7          	jalr	-222(ra) # 800013da <uvmdealloc>
      return 0;
    800014c0:	4501                	li	a0,0
    800014c2:	bfd1                	j	80001496 <uvmalloc+0x74>
    return oldsz;
    800014c4:	852e                	mv	a0,a1
}
    800014c6:	8082                	ret
  return newsz;
    800014c8:	8532                	mv	a0,a2
    800014ca:	b7f1                	j	80001496 <uvmalloc+0x74>

00000000800014cc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014cc:	7179                	addi	sp,sp,-48
    800014ce:	f406                	sd	ra,40(sp)
    800014d0:	f022                	sd	s0,32(sp)
    800014d2:	ec26                	sd	s1,24(sp)
    800014d4:	e84a                	sd	s2,16(sp)
    800014d6:	e44e                	sd	s3,8(sp)
    800014d8:	e052                	sd	s4,0(sp)
    800014da:	1800                	addi	s0,sp,48
    800014dc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014de:	84aa                	mv	s1,a0
    800014e0:	6905                	lui	s2,0x1
    800014e2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e4:	4985                	li	s3,1
    800014e6:	a821                	j	800014fe <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e8:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014ea:	0532                	slli	a0,a0,0xc
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	fe0080e7          	jalr	-32(ra) # 800014cc <freewalk>
      pagetable[i] = 0;
    800014f4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f8:	04a1                	addi	s1,s1,8
    800014fa:	03248163          	beq	s1,s2,8000151c <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014fe:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001500:	00f57793          	andi	a5,a0,15
    80001504:	ff3782e3          	beq	a5,s3,800014e8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001508:	8905                	andi	a0,a0,1
    8000150a:	d57d                	beqz	a0,800014f8 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000150c:	00007517          	auipc	a0,0x7
    80001510:	c6c50513          	addi	a0,a0,-916 # 80008178 <digits+0x138>
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	02a080e7          	jalr	42(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    8000151c:	8552                	mv	a0,s4
    8000151e:	fffff097          	auipc	ra,0xfffff
    80001522:	4da080e7          	jalr	1242(ra) # 800009f8 <kfree>
}
    80001526:	70a2                	ld	ra,40(sp)
    80001528:	7402                	ld	s0,32(sp)
    8000152a:	64e2                	ld	s1,24(sp)
    8000152c:	6942                	ld	s2,16(sp)
    8000152e:	69a2                	ld	s3,8(sp)
    80001530:	6a02                	ld	s4,0(sp)
    80001532:	6145                	addi	sp,sp,48
    80001534:	8082                	ret

0000000080001536 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001536:	1101                	addi	sp,sp,-32
    80001538:	ec06                	sd	ra,24(sp)
    8000153a:	e822                	sd	s0,16(sp)
    8000153c:	e426                	sd	s1,8(sp)
    8000153e:	1000                	addi	s0,sp,32
    80001540:	84aa                	mv	s1,a0
  if(sz > 0)
    80001542:	e999                	bnez	a1,80001558 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001544:	8526                	mv	a0,s1
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	f86080e7          	jalr	-122(ra) # 800014cc <freewalk>
}
    8000154e:	60e2                	ld	ra,24(sp)
    80001550:	6442                	ld	s0,16(sp)
    80001552:	64a2                	ld	s1,8(sp)
    80001554:	6105                	addi	sp,sp,32
    80001556:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001558:	6605                	lui	a2,0x1
    8000155a:	167d                	addi	a2,a2,-1
    8000155c:	962e                	add	a2,a2,a1
    8000155e:	4685                	li	a3,1
    80001560:	8231                	srli	a2,a2,0xc
    80001562:	4581                	li	a1,0
    80001564:	00000097          	auipc	ra,0x0
    80001568:	d12080e7          	jalr	-750(ra) # 80001276 <uvmunmap>
    8000156c:	bfe1                	j	80001544 <uvmfree+0xe>

000000008000156e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000156e:	c679                	beqz	a2,8000163c <uvmcopy+0xce>
{
    80001570:	715d                	addi	sp,sp,-80
    80001572:	e486                	sd	ra,72(sp)
    80001574:	e0a2                	sd	s0,64(sp)
    80001576:	fc26                	sd	s1,56(sp)
    80001578:	f84a                	sd	s2,48(sp)
    8000157a:	f44e                	sd	s3,40(sp)
    8000157c:	f052                	sd	s4,32(sp)
    8000157e:	ec56                	sd	s5,24(sp)
    80001580:	e85a                	sd	s6,16(sp)
    80001582:	e45e                	sd	s7,8(sp)
    80001584:	0880                	addi	s0,sp,80
    80001586:	8b2a                	mv	s6,a0
    80001588:	8aae                	mv	s5,a1
    8000158a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000158c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000158e:	4601                	li	a2,0
    80001590:	85ce                	mv	a1,s3
    80001592:	855a                	mv	a0,s6
    80001594:	00000097          	auipc	ra,0x0
    80001598:	a34080e7          	jalr	-1484(ra) # 80000fc8 <walk>
    8000159c:	c531                	beqz	a0,800015e8 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000159e:	6118                	ld	a4,0(a0)
    800015a0:	00177793          	andi	a5,a4,1
    800015a4:	cbb1                	beqz	a5,800015f8 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a6:	00a75593          	srli	a1,a4,0xa
    800015aa:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015ae:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015b2:	fffff097          	auipc	ra,0xfffff
    800015b6:	542080e7          	jalr	1346(ra) # 80000af4 <kalloc>
    800015ba:	892a                	mv	s2,a0
    800015bc:	c939                	beqz	a0,80001612 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015be:	6605                	lui	a2,0x1
    800015c0:	85de                	mv	a1,s7
    800015c2:	fffff097          	auipc	ra,0xfffff
    800015c6:	77e080e7          	jalr	1918(ra) # 80000d40 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ca:	8726                	mv	a4,s1
    800015cc:	86ca                	mv	a3,s2
    800015ce:	6605                	lui	a2,0x1
    800015d0:	85ce                	mv	a1,s3
    800015d2:	8556                	mv	a0,s5
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	adc080e7          	jalr	-1316(ra) # 800010b0 <mappages>
    800015dc:	e515                	bnez	a0,80001608 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015de:	6785                	lui	a5,0x1
    800015e0:	99be                	add	s3,s3,a5
    800015e2:	fb49e6e3          	bltu	s3,s4,8000158e <uvmcopy+0x20>
    800015e6:	a081                	j	80001626 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e8:	00007517          	auipc	a0,0x7
    800015ec:	ba050513          	addi	a0,a0,-1120 # 80008188 <digits+0x148>
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	f4e080e7          	jalr	-178(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015f8:	00007517          	auipc	a0,0x7
    800015fc:	bb050513          	addi	a0,a0,-1104 # 800081a8 <digits+0x168>
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	f3e080e7          	jalr	-194(ra) # 8000053e <panic>
      kfree(mem);
    80001608:	854a                	mv	a0,s2
    8000160a:	fffff097          	auipc	ra,0xfffff
    8000160e:	3ee080e7          	jalr	1006(ra) # 800009f8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001612:	4685                	li	a3,1
    80001614:	00c9d613          	srli	a2,s3,0xc
    80001618:	4581                	li	a1,0
    8000161a:	8556                	mv	a0,s5
    8000161c:	00000097          	auipc	ra,0x0
    80001620:	c5a080e7          	jalr	-934(ra) # 80001276 <uvmunmap>
  return -1;
    80001624:	557d                	li	a0,-1
}
    80001626:	60a6                	ld	ra,72(sp)
    80001628:	6406                	ld	s0,64(sp)
    8000162a:	74e2                	ld	s1,56(sp)
    8000162c:	7942                	ld	s2,48(sp)
    8000162e:	79a2                	ld	s3,40(sp)
    80001630:	7a02                	ld	s4,32(sp)
    80001632:	6ae2                	ld	s5,24(sp)
    80001634:	6b42                	ld	s6,16(sp)
    80001636:	6ba2                	ld	s7,8(sp)
    80001638:	6161                	addi	sp,sp,80
    8000163a:	8082                	ret
  return 0;
    8000163c:	4501                	li	a0,0
}
    8000163e:	8082                	ret

0000000080001640 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001640:	1141                	addi	sp,sp,-16
    80001642:	e406                	sd	ra,8(sp)
    80001644:	e022                	sd	s0,0(sp)
    80001646:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001648:	4601                	li	a2,0
    8000164a:	00000097          	auipc	ra,0x0
    8000164e:	97e080e7          	jalr	-1666(ra) # 80000fc8 <walk>
  if(pte == 0)
    80001652:	c901                	beqz	a0,80001662 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001654:	611c                	ld	a5,0(a0)
    80001656:	9bbd                	andi	a5,a5,-17
    80001658:	e11c                	sd	a5,0(a0)
}
    8000165a:	60a2                	ld	ra,8(sp)
    8000165c:	6402                	ld	s0,0(sp)
    8000165e:	0141                	addi	sp,sp,16
    80001660:	8082                	ret
    panic("uvmclear");
    80001662:	00007517          	auipc	a0,0x7
    80001666:	b6650513          	addi	a0,a0,-1178 # 800081c8 <digits+0x188>
    8000166a:	fffff097          	auipc	ra,0xfffff
    8000166e:	ed4080e7          	jalr	-300(ra) # 8000053e <panic>

0000000080001672 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001672:	c6bd                	beqz	a3,800016e0 <copyout+0x6e>
{
    80001674:	715d                	addi	sp,sp,-80
    80001676:	e486                	sd	ra,72(sp)
    80001678:	e0a2                	sd	s0,64(sp)
    8000167a:	fc26                	sd	s1,56(sp)
    8000167c:	f84a                	sd	s2,48(sp)
    8000167e:	f44e                	sd	s3,40(sp)
    80001680:	f052                	sd	s4,32(sp)
    80001682:	ec56                	sd	s5,24(sp)
    80001684:	e85a                	sd	s6,16(sp)
    80001686:	e45e                	sd	s7,8(sp)
    80001688:	e062                	sd	s8,0(sp)
    8000168a:	0880                	addi	s0,sp,80
    8000168c:	8b2a                	mv	s6,a0
    8000168e:	8c2e                	mv	s8,a1
    80001690:	8a32                	mv	s4,a2
    80001692:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001694:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001696:	6a85                	lui	s5,0x1
    80001698:	a015                	j	800016bc <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000169a:	9562                	add	a0,a0,s8
    8000169c:	0004861b          	sext.w	a2,s1
    800016a0:	85d2                	mv	a1,s4
    800016a2:	41250533          	sub	a0,a0,s2
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	69a080e7          	jalr	1690(ra) # 80000d40 <memmove>

    len -= n;
    800016ae:	409989b3          	sub	s3,s3,s1
    src += n;
    800016b2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016b4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b8:	02098263          	beqz	s3,800016dc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016bc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016c0:	85ca                	mv	a1,s2
    800016c2:	855a                	mv	a0,s6
    800016c4:	00000097          	auipc	ra,0x0
    800016c8:	9aa080e7          	jalr	-1622(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    800016cc:	cd01                	beqz	a0,800016e4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016ce:	418904b3          	sub	s1,s2,s8
    800016d2:	94d6                	add	s1,s1,s5
    if(n > len)
    800016d4:	fc99f3e3          	bgeu	s3,s1,8000169a <copyout+0x28>
    800016d8:	84ce                	mv	s1,s3
    800016da:	b7c1                	j	8000169a <copyout+0x28>
  }
  return 0;
    800016dc:	4501                	li	a0,0
    800016de:	a021                	j	800016e6 <copyout+0x74>
    800016e0:	4501                	li	a0,0
}
    800016e2:	8082                	ret
      return -1;
    800016e4:	557d                	li	a0,-1
}
    800016e6:	60a6                	ld	ra,72(sp)
    800016e8:	6406                	ld	s0,64(sp)
    800016ea:	74e2                	ld	s1,56(sp)
    800016ec:	7942                	ld	s2,48(sp)
    800016ee:	79a2                	ld	s3,40(sp)
    800016f0:	7a02                	ld	s4,32(sp)
    800016f2:	6ae2                	ld	s5,24(sp)
    800016f4:	6b42                	ld	s6,16(sp)
    800016f6:	6ba2                	ld	s7,8(sp)
    800016f8:	6c02                	ld	s8,0(sp)
    800016fa:	6161                	addi	sp,sp,80
    800016fc:	8082                	ret

00000000800016fe <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016fe:	c6bd                	beqz	a3,8000176c <copyin+0x6e>
{
    80001700:	715d                	addi	sp,sp,-80
    80001702:	e486                	sd	ra,72(sp)
    80001704:	e0a2                	sd	s0,64(sp)
    80001706:	fc26                	sd	s1,56(sp)
    80001708:	f84a                	sd	s2,48(sp)
    8000170a:	f44e                	sd	s3,40(sp)
    8000170c:	f052                	sd	s4,32(sp)
    8000170e:	ec56                	sd	s5,24(sp)
    80001710:	e85a                	sd	s6,16(sp)
    80001712:	e45e                	sd	s7,8(sp)
    80001714:	e062                	sd	s8,0(sp)
    80001716:	0880                	addi	s0,sp,80
    80001718:	8b2a                	mv	s6,a0
    8000171a:	8a2e                	mv	s4,a1
    8000171c:	8c32                	mv	s8,a2
    8000171e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001720:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001722:	6a85                	lui	s5,0x1
    80001724:	a015                	j	80001748 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001726:	9562                	add	a0,a0,s8
    80001728:	0004861b          	sext.w	a2,s1
    8000172c:	412505b3          	sub	a1,a0,s2
    80001730:	8552                	mv	a0,s4
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	60e080e7          	jalr	1550(ra) # 80000d40 <memmove>

    len -= n;
    8000173a:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173e:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001740:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001744:	02098263          	beqz	s3,80001768 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001748:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000174c:	85ca                	mv	a1,s2
    8000174e:	855a                	mv	a0,s6
    80001750:	00000097          	auipc	ra,0x0
    80001754:	91e080e7          	jalr	-1762(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    80001758:	cd01                	beqz	a0,80001770 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000175a:	418904b3          	sub	s1,s2,s8
    8000175e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001760:	fc99f3e3          	bgeu	s3,s1,80001726 <copyin+0x28>
    80001764:	84ce                	mv	s1,s3
    80001766:	b7c1                	j	80001726 <copyin+0x28>
  }
  return 0;
    80001768:	4501                	li	a0,0
    8000176a:	a021                	j	80001772 <copyin+0x74>
    8000176c:	4501                	li	a0,0
}
    8000176e:	8082                	ret
      return -1;
    80001770:	557d                	li	a0,-1
}
    80001772:	60a6                	ld	ra,72(sp)
    80001774:	6406                	ld	s0,64(sp)
    80001776:	74e2                	ld	s1,56(sp)
    80001778:	7942                	ld	s2,48(sp)
    8000177a:	79a2                	ld	s3,40(sp)
    8000177c:	7a02                	ld	s4,32(sp)
    8000177e:	6ae2                	ld	s5,24(sp)
    80001780:	6b42                	ld	s6,16(sp)
    80001782:	6ba2                	ld	s7,8(sp)
    80001784:	6c02                	ld	s8,0(sp)
    80001786:	6161                	addi	sp,sp,80
    80001788:	8082                	ret

000000008000178a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000178a:	c6c5                	beqz	a3,80001832 <copyinstr+0xa8>
{
    8000178c:	715d                	addi	sp,sp,-80
    8000178e:	e486                	sd	ra,72(sp)
    80001790:	e0a2                	sd	s0,64(sp)
    80001792:	fc26                	sd	s1,56(sp)
    80001794:	f84a                	sd	s2,48(sp)
    80001796:	f44e                	sd	s3,40(sp)
    80001798:	f052                	sd	s4,32(sp)
    8000179a:	ec56                	sd	s5,24(sp)
    8000179c:	e85a                	sd	s6,16(sp)
    8000179e:	e45e                	sd	s7,8(sp)
    800017a0:	0880                	addi	s0,sp,80
    800017a2:	8a2a                	mv	s4,a0
    800017a4:	8b2e                	mv	s6,a1
    800017a6:	8bb2                	mv	s7,a2
    800017a8:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017aa:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ac:	6985                	lui	s3,0x1
    800017ae:	a035                	j	800017da <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017b0:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b4:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b6:	0017b793          	seqz	a5,a5
    800017ba:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017be:	60a6                	ld	ra,72(sp)
    800017c0:	6406                	ld	s0,64(sp)
    800017c2:	74e2                	ld	s1,56(sp)
    800017c4:	7942                	ld	s2,48(sp)
    800017c6:	79a2                	ld	s3,40(sp)
    800017c8:	7a02                	ld	s4,32(sp)
    800017ca:	6ae2                	ld	s5,24(sp)
    800017cc:	6b42                	ld	s6,16(sp)
    800017ce:	6ba2                	ld	s7,8(sp)
    800017d0:	6161                	addi	sp,sp,80
    800017d2:	8082                	ret
    srcva = va0 + PGSIZE;
    800017d4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d8:	c8a9                	beqz	s1,8000182a <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017da:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017de:	85ca                	mv	a1,s2
    800017e0:	8552                	mv	a0,s4
    800017e2:	00000097          	auipc	ra,0x0
    800017e6:	88c080e7          	jalr	-1908(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    800017ea:	c131                	beqz	a0,8000182e <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ec:	41790833          	sub	a6,s2,s7
    800017f0:	984e                	add	a6,a6,s3
    if(n > max)
    800017f2:	0104f363          	bgeu	s1,a6,800017f8 <copyinstr+0x6e>
    800017f6:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f8:	955e                	add	a0,a0,s7
    800017fa:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017fe:	fc080be3          	beqz	a6,800017d4 <copyinstr+0x4a>
    80001802:	985a                	add	a6,a6,s6
    80001804:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001806:	41650633          	sub	a2,a0,s6
    8000180a:	14fd                	addi	s1,s1,-1
    8000180c:	9b26                	add	s6,s6,s1
    8000180e:	00f60733          	add	a4,a2,a5
    80001812:	00074703          	lbu	a4,0(a4)
    80001816:	df49                	beqz	a4,800017b0 <copyinstr+0x26>
        *dst = *p;
    80001818:	00e78023          	sb	a4,0(a5)
      --max;
    8000181c:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001820:	0785                	addi	a5,a5,1
    while(n > 0){
    80001822:	ff0796e3          	bne	a5,a6,8000180e <copyinstr+0x84>
      dst++;
    80001826:	8b42                	mv	s6,a6
    80001828:	b775                	j	800017d4 <copyinstr+0x4a>
    8000182a:	4781                	li	a5,0
    8000182c:	b769                	j	800017b6 <copyinstr+0x2c>
      return -1;
    8000182e:	557d                	li	a0,-1
    80001830:	b779                	j	800017be <copyinstr+0x34>
  int got_null = 0;
    80001832:	4781                	li	a5,0
  if(got_null){
    80001834:	0017b793          	seqz	a5,a5
    80001838:	40f00533          	neg	a0,a5
}
    8000183c:	8082                	ret

000000008000183e <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000183e:	7139                	addi	sp,sp,-64
    80001840:	fc06                	sd	ra,56(sp)
    80001842:	f822                	sd	s0,48(sp)
    80001844:	f426                	sd	s1,40(sp)
    80001846:	f04a                	sd	s2,32(sp)
    80001848:	ec4e                	sd	s3,24(sp)
    8000184a:	e852                	sd	s4,16(sp)
    8000184c:	e456                	sd	s5,8(sp)
    8000184e:	e05a                	sd	s6,0(sp)
    80001850:	0080                	addi	s0,sp,64
    80001852:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001854:	00010497          	auipc	s1,0x10
    80001858:	e7c48493          	addi	s1,s1,-388 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000185c:	8b26                	mv	s6,s1
    8000185e:	00006a97          	auipc	s5,0x6
    80001862:	7a2a8a93          	addi	s5,s5,1954 # 80008000 <etext>
    80001866:	04000937          	lui	s2,0x4000
    8000186a:	197d                	addi	s2,s2,-1
    8000186c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00016a17          	auipc	s4,0x16
    80001872:	e62a0a13          	addi	s4,s4,-414 # 800176d0 <tickslock>
    char *pa = kalloc();
    80001876:	fffff097          	auipc	ra,0xfffff
    8000187a:	27e080e7          	jalr	638(ra) # 80000af4 <kalloc>
    8000187e:	862a                	mv	a2,a0
    if(pa == 0)
    80001880:	c131                	beqz	a0,800018c4 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001882:	416485b3          	sub	a1,s1,s6
    80001886:	859d                	srai	a1,a1,0x7
    80001888:	000ab783          	ld	a5,0(s5)
    8000188c:	02f585b3          	mul	a1,a1,a5
    80001890:	2585                	addiw	a1,a1,1
    80001892:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001896:	4719                	li	a4,6
    80001898:	6685                	lui	a3,0x1
    8000189a:	40b905b3          	sub	a1,s2,a1
    8000189e:	854e                	mv	a0,s3
    800018a0:	00000097          	auipc	ra,0x0
    800018a4:	8b0080e7          	jalr	-1872(ra) # 80001150 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a8:	18048493          	addi	s1,s1,384
    800018ac:	fd4495e3          	bne	s1,s4,80001876 <proc_mapstacks+0x38>
  }
}
    800018b0:	70e2                	ld	ra,56(sp)
    800018b2:	7442                	ld	s0,48(sp)
    800018b4:	74a2                	ld	s1,40(sp)
    800018b6:	7902                	ld	s2,32(sp)
    800018b8:	69e2                	ld	s3,24(sp)
    800018ba:	6a42                	ld	s4,16(sp)
    800018bc:	6aa2                	ld	s5,8(sp)
    800018be:	6b02                	ld	s6,0(sp)
    800018c0:	6121                	addi	sp,sp,64
    800018c2:	8082                	ret
      panic("kalloc");
    800018c4:	00007517          	auipc	a0,0x7
    800018c8:	91450513          	addi	a0,a0,-1772 # 800081d8 <digits+0x198>
    800018cc:	fffff097          	auipc	ra,0xfffff
    800018d0:	c72080e7          	jalr	-910(ra) # 8000053e <panic>

00000000800018d4 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018d4:	7139                	addi	sp,sp,-64
    800018d6:	fc06                	sd	ra,56(sp)
    800018d8:	f822                	sd	s0,48(sp)
    800018da:	f426                	sd	s1,40(sp)
    800018dc:	f04a                	sd	s2,32(sp)
    800018de:	ec4e                	sd	s3,24(sp)
    800018e0:	e852                	sd	s4,16(sp)
    800018e2:	e456                	sd	s5,8(sp)
    800018e4:	e05a                	sd	s6,0(sp)
    800018e6:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e8:	00007597          	auipc	a1,0x7
    800018ec:	8f858593          	addi	a1,a1,-1800 # 800081e0 <digits+0x1a0>
    800018f0:	00010517          	auipc	a0,0x10
    800018f4:	9b050513          	addi	a0,a0,-1616 # 800112a0 <pid_lock>
    800018f8:	fffff097          	auipc	ra,0xfffff
    800018fc:	25c080e7          	jalr	604(ra) # 80000b54 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001900:	00007597          	auipc	a1,0x7
    80001904:	8e858593          	addi	a1,a1,-1816 # 800081e8 <digits+0x1a8>
    80001908:	00010517          	auipc	a0,0x10
    8000190c:	9b050513          	addi	a0,a0,-1616 # 800112b8 <wait_lock>
    80001910:	fffff097          	auipc	ra,0xfffff
    80001914:	244080e7          	jalr	580(ra) # 80000b54 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001918:	00010497          	auipc	s1,0x10
    8000191c:	db848493          	addi	s1,s1,-584 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001920:	00007b17          	auipc	s6,0x7
    80001924:	8d8b0b13          	addi	s6,s6,-1832 # 800081f8 <digits+0x1b8>
      p->kstack = KSTACK((int) (p - proc));
    80001928:	8aa6                	mv	s5,s1
    8000192a:	00006a17          	auipc	s4,0x6
    8000192e:	6d6a0a13          	addi	s4,s4,1750 # 80008000 <etext>
    80001932:	04000937          	lui	s2,0x4000
    80001936:	197d                	addi	s2,s2,-1
    80001938:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193a:	00016997          	auipc	s3,0x16
    8000193e:	d9698993          	addi	s3,s3,-618 # 800176d0 <tickslock>
      initlock(&p->lock, "proc");
    80001942:	85da                	mv	a1,s6
    80001944:	8526                	mv	a0,s1
    80001946:	fffff097          	auipc	ra,0xfffff
    8000194a:	20e080e7          	jalr	526(ra) # 80000b54 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    8000194e:	415487b3          	sub	a5,s1,s5
    80001952:	879d                	srai	a5,a5,0x7
    80001954:	000a3703          	ld	a4,0(s4)
    80001958:	02e787b3          	mul	a5,a5,a4
    8000195c:	2785                	addiw	a5,a5,1
    8000195e:	00d7979b          	slliw	a5,a5,0xd
    80001962:	40f907b3          	sub	a5,s2,a5
    80001966:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001968:	18048493          	addi	s1,s1,384
    8000196c:	fd349be3          	bne	s1,s3,80001942 <procinit+0x6e>
  }
}
    80001970:	70e2                	ld	ra,56(sp)
    80001972:	7442                	ld	s0,48(sp)
    80001974:	74a2                	ld	s1,40(sp)
    80001976:	7902                	ld	s2,32(sp)
    80001978:	69e2                	ld	s3,24(sp)
    8000197a:	6a42                	ld	s4,16(sp)
    8000197c:	6aa2                	ld	s5,8(sp)
    8000197e:	6b02                	ld	s6,0(sp)
    80001980:	6121                	addi	sp,sp,64
    80001982:	8082                	ret

0000000080001984 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001984:	1141                	addi	sp,sp,-16
    80001986:	e422                	sd	s0,8(sp)
    80001988:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000198a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000198c:	2501                	sext.w	a0,a0
    8000198e:	6422                	ld	s0,8(sp)
    80001990:	0141                	addi	sp,sp,16
    80001992:	8082                	ret

0000000080001994 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001994:	1141                	addi	sp,sp,-16
    80001996:	e422                	sd	s0,8(sp)
    80001998:	0800                	addi	s0,sp,16
    8000199a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000199c:	2781                	sext.w	a5,a5
    8000199e:	079e                	slli	a5,a5,0x7
  return c;
}
    800019a0:	00010517          	auipc	a0,0x10
    800019a4:	93050513          	addi	a0,a0,-1744 # 800112d0 <cpus>
    800019a8:	953e                	add	a0,a0,a5
    800019aa:	6422                	ld	s0,8(sp)
    800019ac:	0141                	addi	sp,sp,16
    800019ae:	8082                	ret

00000000800019b0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    800019b0:	1101                	addi	sp,sp,-32
    800019b2:	ec06                	sd	ra,24(sp)
    800019b4:	e822                	sd	s0,16(sp)
    800019b6:	e426                	sd	s1,8(sp)
    800019b8:	1000                	addi	s0,sp,32
  push_off();
    800019ba:	fffff097          	auipc	ra,0xfffff
    800019be:	1de080e7          	jalr	478(ra) # 80000b98 <push_off>
    800019c2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c4:	2781                	sext.w	a5,a5
    800019c6:	079e                	slli	a5,a5,0x7
    800019c8:	00010717          	auipc	a4,0x10
    800019cc:	8d870713          	addi	a4,a4,-1832 # 800112a0 <pid_lock>
    800019d0:	97ba                	add	a5,a5,a4
    800019d2:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d4:	fffff097          	auipc	ra,0xfffff
    800019d8:	264080e7          	jalr	612(ra) # 80000c38 <pop_off>
  return p;
}
    800019dc:	8526                	mv	a0,s1
    800019de:	60e2                	ld	ra,24(sp)
    800019e0:	6442                	ld	s0,16(sp)
    800019e2:	64a2                	ld	s1,8(sp)
    800019e4:	6105                	addi	sp,sp,32
    800019e6:	8082                	ret

00000000800019e8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019e8:	1101                	addi	sp,sp,-32
    800019ea:	ec06                	sd	ra,24(sp)
    800019ec:	e822                	sd	s0,16(sp)
    800019ee:	e426                	sd	s1,8(sp)
    800019f0:	1000                	addi	s0,sp,32
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019f2:	00000097          	auipc	ra,0x0
    800019f6:	fbe080e7          	jalr	-66(ra) # 800019b0 <myproc>
    800019fa:	fffff097          	auipc	ra,0xfffff
    800019fe:	29e080e7          	jalr	670(ra) # 80000c98 <release>

  if (first) {
    80001a02:	00007797          	auipc	a5,0x7
    80001a06:	f4e7a783          	lw	a5,-178(a5) # 80008950 <first.1729>
    80001a0a:	efa1                	bnez	a5,80001a62 <forkret+0x7a>
    fsinit(ROOTDEV);
  }

  uint xticks;

        acquire(&tickslock);
    80001a0c:	00016517          	auipc	a0,0x16
    80001a10:	cc450513          	addi	a0,a0,-828 # 800176d0 <tickslock>
    80001a14:	fffff097          	auipc	ra,0xfffff
    80001a18:	1d0080e7          	jalr	464(ra) # 80000be4 <acquire>
        xticks = ticks;
    80001a1c:	00007497          	auipc	s1,0x7
    80001a20:	6144a483          	lw	s1,1556(s1) # 80009030 <ticks>
        release(&tickslock);
    80001a24:	00016517          	auipc	a0,0x16
    80001a28:	cac50513          	addi	a0,a0,-852 # 800176d0 <tickslock>
    80001a2c:	fffff097          	auipc	ra,0xfffff
    80001a30:	26c080e7          	jalr	620(ra) # 80000c98 <release>

        myproc()->stime = xticks;
    80001a34:	00000097          	auipc	ra,0x0
    80001a38:	f7c080e7          	jalr	-132(ra) # 800019b0 <myproc>
    80001a3c:	1482                	slli	s1,s1,0x20
    80001a3e:	9081                	srli	s1,s1,0x20
    80001a40:	16953823          	sd	s1,368(a0)
        myproc()->etime = xticks;
    80001a44:	00000097          	auipc	ra,0x0
    80001a48:	f6c080e7          	jalr	-148(ra) # 800019b0 <myproc>
    80001a4c:	16953c23          	sd	s1,376(a0)



  usertrapret();
    80001a50:	00001097          	auipc	ra,0x1
    80001a54:	25e080e7          	jalr	606(ra) # 80002cae <usertrapret>
}
    80001a58:	60e2                	ld	ra,24(sp)
    80001a5a:	6442                	ld	s0,16(sp)
    80001a5c:	64a2                	ld	s1,8(sp)
    80001a5e:	6105                	addi	sp,sp,32
    80001a60:	8082                	ret
    first = 0;
    80001a62:	00007797          	auipc	a5,0x7
    80001a66:	ee07a723          	sw	zero,-274(a5) # 80008950 <first.1729>
    fsinit(ROOTDEV);
    80001a6a:	4505                	li	a0,1
    80001a6c:	00002097          	auipc	ra,0x2
    80001a70:	0c8080e7          	jalr	200(ra) # 80003b34 <fsinit>
    80001a74:	bf61                	j	80001a0c <forkret+0x24>

0000000080001a76 <allocpid>:
allocpid() {
    80001a76:	1101                	addi	sp,sp,-32
    80001a78:	ec06                	sd	ra,24(sp)
    80001a7a:	e822                	sd	s0,16(sp)
    80001a7c:	e426                	sd	s1,8(sp)
    80001a7e:	e04a                	sd	s2,0(sp)
    80001a80:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a82:	00010917          	auipc	s2,0x10
    80001a86:	81e90913          	addi	s2,s2,-2018 # 800112a0 <pid_lock>
    80001a8a:	854a                	mv	a0,s2
    80001a8c:	fffff097          	auipc	ra,0xfffff
    80001a90:	158080e7          	jalr	344(ra) # 80000be4 <acquire>
  pid = nextpid;
    80001a94:	00007797          	auipc	a5,0x7
    80001a98:	ec078793          	addi	a5,a5,-320 # 80008954 <nextpid>
    80001a9c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a9e:	0014871b          	addiw	a4,s1,1
    80001aa2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001aa4:	854a                	mv	a0,s2
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	1f2080e7          	jalr	498(ra) # 80000c98 <release>
}
    80001aae:	8526                	mv	a0,s1
    80001ab0:	60e2                	ld	ra,24(sp)
    80001ab2:	6442                	ld	s0,16(sp)
    80001ab4:	64a2                	ld	s1,8(sp)
    80001ab6:	6902                	ld	s2,0(sp)
    80001ab8:	6105                	addi	sp,sp,32
    80001aba:	8082                	ret

0000000080001abc <proc_pagetable>:
{
    80001abc:	1101                	addi	sp,sp,-32
    80001abe:	ec06                	sd	ra,24(sp)
    80001ac0:	e822                	sd	s0,16(sp)
    80001ac2:	e426                	sd	s1,8(sp)
    80001ac4:	e04a                	sd	s2,0(sp)
    80001ac6:	1000                	addi	s0,sp,32
    80001ac8:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001aca:	00000097          	auipc	ra,0x0
    80001ace:	870080e7          	jalr	-1936(ra) # 8000133a <uvmcreate>
    80001ad2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ad4:	c121                	beqz	a0,80001b14 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ad6:	4729                	li	a4,10
    80001ad8:	00005697          	auipc	a3,0x5
    80001adc:	52868693          	addi	a3,a3,1320 # 80007000 <_trampoline>
    80001ae0:	6605                	lui	a2,0x1
    80001ae2:	040005b7          	lui	a1,0x4000
    80001ae6:	15fd                	addi	a1,a1,-1
    80001ae8:	05b2                	slli	a1,a1,0xc
    80001aea:	fffff097          	auipc	ra,0xfffff
    80001aee:	5c6080e7          	jalr	1478(ra) # 800010b0 <mappages>
    80001af2:	02054863          	bltz	a0,80001b22 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001af6:	4719                	li	a4,6
    80001af8:	05893683          	ld	a3,88(s2)
    80001afc:	6605                	lui	a2,0x1
    80001afe:	020005b7          	lui	a1,0x2000
    80001b02:	15fd                	addi	a1,a1,-1
    80001b04:	05b6                	slli	a1,a1,0xd
    80001b06:	8526                	mv	a0,s1
    80001b08:	fffff097          	auipc	ra,0xfffff
    80001b0c:	5a8080e7          	jalr	1448(ra) # 800010b0 <mappages>
    80001b10:	02054163          	bltz	a0,80001b32 <proc_pagetable+0x76>
}
    80001b14:	8526                	mv	a0,s1
    80001b16:	60e2                	ld	ra,24(sp)
    80001b18:	6442                	ld	s0,16(sp)
    80001b1a:	64a2                	ld	s1,8(sp)
    80001b1c:	6902                	ld	s2,0(sp)
    80001b1e:	6105                	addi	sp,sp,32
    80001b20:	8082                	ret
    uvmfree(pagetable, 0);
    80001b22:	4581                	li	a1,0
    80001b24:	8526                	mv	a0,s1
    80001b26:	00000097          	auipc	ra,0x0
    80001b2a:	a10080e7          	jalr	-1520(ra) # 80001536 <uvmfree>
    return 0;
    80001b2e:	4481                	li	s1,0
    80001b30:	b7d5                	j	80001b14 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b32:	4681                	li	a3,0
    80001b34:	4605                	li	a2,1
    80001b36:	040005b7          	lui	a1,0x4000
    80001b3a:	15fd                	addi	a1,a1,-1
    80001b3c:	05b2                	slli	a1,a1,0xc
    80001b3e:	8526                	mv	a0,s1
    80001b40:	fffff097          	auipc	ra,0xfffff
    80001b44:	736080e7          	jalr	1846(ra) # 80001276 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b48:	4581                	li	a1,0
    80001b4a:	8526                	mv	a0,s1
    80001b4c:	00000097          	auipc	ra,0x0
    80001b50:	9ea080e7          	jalr	-1558(ra) # 80001536 <uvmfree>
    return 0;
    80001b54:	4481                	li	s1,0
    80001b56:	bf7d                	j	80001b14 <proc_pagetable+0x58>

0000000080001b58 <proc_freepagetable>:
{
    80001b58:	1101                	addi	sp,sp,-32
    80001b5a:	ec06                	sd	ra,24(sp)
    80001b5c:	e822                	sd	s0,16(sp)
    80001b5e:	e426                	sd	s1,8(sp)
    80001b60:	e04a                	sd	s2,0(sp)
    80001b62:	1000                	addi	s0,sp,32
    80001b64:	84aa                	mv	s1,a0
    80001b66:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b68:	4681                	li	a3,0
    80001b6a:	4605                	li	a2,1
    80001b6c:	040005b7          	lui	a1,0x4000
    80001b70:	15fd                	addi	a1,a1,-1
    80001b72:	05b2                	slli	a1,a1,0xc
    80001b74:	fffff097          	auipc	ra,0xfffff
    80001b78:	702080e7          	jalr	1794(ra) # 80001276 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b7c:	4681                	li	a3,0
    80001b7e:	4605                	li	a2,1
    80001b80:	020005b7          	lui	a1,0x2000
    80001b84:	15fd                	addi	a1,a1,-1
    80001b86:	05b6                	slli	a1,a1,0xd
    80001b88:	8526                	mv	a0,s1
    80001b8a:	fffff097          	auipc	ra,0xfffff
    80001b8e:	6ec080e7          	jalr	1772(ra) # 80001276 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b92:	85ca                	mv	a1,s2
    80001b94:	8526                	mv	a0,s1
    80001b96:	00000097          	auipc	ra,0x0
    80001b9a:	9a0080e7          	jalr	-1632(ra) # 80001536 <uvmfree>
}
    80001b9e:	60e2                	ld	ra,24(sp)
    80001ba0:	6442                	ld	s0,16(sp)
    80001ba2:	64a2                	ld	s1,8(sp)
    80001ba4:	6902                	ld	s2,0(sp)
    80001ba6:	6105                	addi	sp,sp,32
    80001ba8:	8082                	ret

0000000080001baa <freeproc>:
{
    80001baa:	1101                	addi	sp,sp,-32
    80001bac:	ec06                	sd	ra,24(sp)
    80001bae:	e822                	sd	s0,16(sp)
    80001bb0:	e426                	sd	s1,8(sp)
    80001bb2:	1000                	addi	s0,sp,32
    80001bb4:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bb6:	6d28                	ld	a0,88(a0)
    80001bb8:	c509                	beqz	a0,80001bc2 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bba:	fffff097          	auipc	ra,0xfffff
    80001bbe:	e3e080e7          	jalr	-450(ra) # 800009f8 <kfree>
  p->trapframe = 0;
    80001bc2:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bc6:	68a8                	ld	a0,80(s1)
    80001bc8:	c511                	beqz	a0,80001bd4 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bca:	64ac                	ld	a1,72(s1)
    80001bcc:	00000097          	auipc	ra,0x0
    80001bd0:	f8c080e7          	jalr	-116(ra) # 80001b58 <proc_freepagetable>
  p->pagetable = 0;
    80001bd4:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bd8:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bdc:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001be0:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001be4:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001be8:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bec:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bf0:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bf4:	0004ac23          	sw	zero,24(s1)
}
    80001bf8:	60e2                	ld	ra,24(sp)
    80001bfa:	6442                	ld	s0,16(sp)
    80001bfc:	64a2                	ld	s1,8(sp)
    80001bfe:	6105                	addi	sp,sp,32
    80001c00:	8082                	ret

0000000080001c02 <allocproc>:
{
    80001c02:	1101                	addi	sp,sp,-32
    80001c04:	ec06                	sd	ra,24(sp)
    80001c06:	e822                	sd	s0,16(sp)
    80001c08:	e426                	sd	s1,8(sp)
    80001c0a:	e04a                	sd	s2,0(sp)
    80001c0c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c0e:	00010497          	auipc	s1,0x10
    80001c12:	ac248493          	addi	s1,s1,-1342 # 800116d0 <proc>
    80001c16:	00016917          	auipc	s2,0x16
    80001c1a:	aba90913          	addi	s2,s2,-1350 # 800176d0 <tickslock>
    acquire(&p->lock);
    80001c1e:	8526                	mv	a0,s1
    80001c20:	fffff097          	auipc	ra,0xfffff
    80001c24:	fc4080e7          	jalr	-60(ra) # 80000be4 <acquire>
    if(p->state == UNUSED) {
    80001c28:	4c9c                	lw	a5,24(s1)
    80001c2a:	cf81                	beqz	a5,80001c42 <allocproc+0x40>
      release(&p->lock);
    80001c2c:	8526                	mv	a0,s1
    80001c2e:	fffff097          	auipc	ra,0xfffff
    80001c32:	06a080e7          	jalr	106(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c36:	18048493          	addi	s1,s1,384
    80001c3a:	ff2492e3          	bne	s1,s2,80001c1e <allocproc+0x1c>
  return 0;
    80001c3e:	4481                	li	s1,0
    80001c40:	a889                	j	80001c92 <allocproc+0x90>
  p->pid = allocpid();
    80001c42:	00000097          	auipc	ra,0x0
    80001c46:	e34080e7          	jalr	-460(ra) # 80001a76 <allocpid>
    80001c4a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c4c:	4785                	li	a5,1
    80001c4e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c50:	fffff097          	auipc	ra,0xfffff
    80001c54:	ea4080e7          	jalr	-348(ra) # 80000af4 <kalloc>
    80001c58:	892a                	mv	s2,a0
    80001c5a:	eca8                	sd	a0,88(s1)
    80001c5c:	c131                	beqz	a0,80001ca0 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	00000097          	auipc	ra,0x0
    80001c64:	e5c080e7          	jalr	-420(ra) # 80001abc <proc_pagetable>
    80001c68:	892a                	mv	s2,a0
    80001c6a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c6c:	c531                	beqz	a0,80001cb8 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c6e:	07000613          	li	a2,112
    80001c72:	4581                	li	a1,0
    80001c74:	06048513          	addi	a0,s1,96
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	068080e7          	jalr	104(ra) # 80000ce0 <memset>
  p->context.ra = (uint64)forkret;
    80001c80:	00000797          	auipc	a5,0x0
    80001c84:	d6878793          	addi	a5,a5,-664 # 800019e8 <forkret>
    80001c88:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c8a:	60bc                	ld	a5,64(s1)
    80001c8c:	6705                	lui	a4,0x1
    80001c8e:	97ba                	add	a5,a5,a4
    80001c90:	f4bc                	sd	a5,104(s1)
}
    80001c92:	8526                	mv	a0,s1
    80001c94:	60e2                	ld	ra,24(sp)
    80001c96:	6442                	ld	s0,16(sp)
    80001c98:	64a2                	ld	s1,8(sp)
    80001c9a:	6902                	ld	s2,0(sp)
    80001c9c:	6105                	addi	sp,sp,32
    80001c9e:	8082                	ret
    freeproc(p);
    80001ca0:	8526                	mv	a0,s1
    80001ca2:	00000097          	auipc	ra,0x0
    80001ca6:	f08080e7          	jalr	-248(ra) # 80001baa <freeproc>
    release(&p->lock);
    80001caa:	8526                	mv	a0,s1
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	fec080e7          	jalr	-20(ra) # 80000c98 <release>
    return 0;
    80001cb4:	84ca                	mv	s1,s2
    80001cb6:	bff1                	j	80001c92 <allocproc+0x90>
    freeproc(p);
    80001cb8:	8526                	mv	a0,s1
    80001cba:	00000097          	auipc	ra,0x0
    80001cbe:	ef0080e7          	jalr	-272(ra) # 80001baa <freeproc>
    release(&p->lock);
    80001cc2:	8526                	mv	a0,s1
    80001cc4:	fffff097          	auipc	ra,0xfffff
    80001cc8:	fd4080e7          	jalr	-44(ra) # 80000c98 <release>
    return 0;
    80001ccc:	84ca                	mv	s1,s2
    80001cce:	b7d1                	j	80001c92 <allocproc+0x90>

0000000080001cd0 <userinit>:
{
    80001cd0:	1101                	addi	sp,sp,-32
    80001cd2:	ec06                	sd	ra,24(sp)
    80001cd4:	e822                	sd	s0,16(sp)
    80001cd6:	e426                	sd	s1,8(sp)
    80001cd8:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cda:	00000097          	auipc	ra,0x0
    80001cde:	f28080e7          	jalr	-216(ra) # 80001c02 <allocproc>
    80001ce2:	84aa                	mv	s1,a0
  initproc = p;
    80001ce4:	00007797          	auipc	a5,0x7
    80001ce8:	34a7b223          	sd	a0,836(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cec:	03400613          	li	a2,52
    80001cf0:	00007597          	auipc	a1,0x7
    80001cf4:	c7058593          	addi	a1,a1,-912 # 80008960 <initcode>
    80001cf8:	6928                	ld	a0,80(a0)
    80001cfa:	fffff097          	auipc	ra,0xfffff
    80001cfe:	66e080e7          	jalr	1646(ra) # 80001368 <uvminit>
  p->sz = PGSIZE;
    80001d02:	6785                	lui	a5,0x1
    80001d04:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d06:	6cb8                	ld	a4,88(s1)
    80001d08:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d0c:	6cb8                	ld	a4,88(s1)
    80001d0e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d10:	4641                	li	a2,16
    80001d12:	00006597          	auipc	a1,0x6
    80001d16:	4ee58593          	addi	a1,a1,1262 # 80008200 <digits+0x1c0>
    80001d1a:	15848513          	addi	a0,s1,344
    80001d1e:	fffff097          	auipc	ra,0xfffff
    80001d22:	114080e7          	jalr	276(ra) # 80000e32 <safestrcpy>
  p->cwd = namei("/");
    80001d26:	00006517          	auipc	a0,0x6
    80001d2a:	4ea50513          	addi	a0,a0,1258 # 80008210 <digits+0x1d0>
    80001d2e:	00003097          	auipc	ra,0x3
    80001d32:	834080e7          	jalr	-1996(ra) # 80004562 <namei>
    80001d36:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d3a:	478d                	li	a5,3
    80001d3c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d3e:	8526                	mv	a0,s1
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	f58080e7          	jalr	-168(ra) # 80000c98 <release>
}
    80001d48:	60e2                	ld	ra,24(sp)
    80001d4a:	6442                	ld	s0,16(sp)
    80001d4c:	64a2                	ld	s1,8(sp)
    80001d4e:	6105                	addi	sp,sp,32
    80001d50:	8082                	ret

0000000080001d52 <growproc>:
{
    80001d52:	1101                	addi	sp,sp,-32
    80001d54:	ec06                	sd	ra,24(sp)
    80001d56:	e822                	sd	s0,16(sp)
    80001d58:	e426                	sd	s1,8(sp)
    80001d5a:	e04a                	sd	s2,0(sp)
    80001d5c:	1000                	addi	s0,sp,32
    80001d5e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d60:	00000097          	auipc	ra,0x0
    80001d64:	c50080e7          	jalr	-944(ra) # 800019b0 <myproc>
    80001d68:	892a                	mv	s2,a0
  sz = p->sz;
    80001d6a:	652c                	ld	a1,72(a0)
    80001d6c:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d70:	00904f63          	bgtz	s1,80001d8e <growproc+0x3c>
  } else if(n < 0){
    80001d74:	0204cc63          	bltz	s1,80001dac <growproc+0x5a>
  p->sz = sz;
    80001d78:	1602                	slli	a2,a2,0x20
    80001d7a:	9201                	srli	a2,a2,0x20
    80001d7c:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d80:	4501                	li	a0,0
}
    80001d82:	60e2                	ld	ra,24(sp)
    80001d84:	6442                	ld	s0,16(sp)
    80001d86:	64a2                	ld	s1,8(sp)
    80001d88:	6902                	ld	s2,0(sp)
    80001d8a:	6105                	addi	sp,sp,32
    80001d8c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d8e:	9e25                	addw	a2,a2,s1
    80001d90:	1602                	slli	a2,a2,0x20
    80001d92:	9201                	srli	a2,a2,0x20
    80001d94:	1582                	slli	a1,a1,0x20
    80001d96:	9181                	srli	a1,a1,0x20
    80001d98:	6928                	ld	a0,80(a0)
    80001d9a:	fffff097          	auipc	ra,0xfffff
    80001d9e:	688080e7          	jalr	1672(ra) # 80001422 <uvmalloc>
    80001da2:	0005061b          	sext.w	a2,a0
    80001da6:	fa69                	bnez	a2,80001d78 <growproc+0x26>
      return -1;
    80001da8:	557d                	li	a0,-1
    80001daa:	bfe1                	j	80001d82 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dac:	9e25                	addw	a2,a2,s1
    80001dae:	1602                	slli	a2,a2,0x20
    80001db0:	9201                	srli	a2,a2,0x20
    80001db2:	1582                	slli	a1,a1,0x20
    80001db4:	9181                	srli	a1,a1,0x20
    80001db6:	6928                	ld	a0,80(a0)
    80001db8:	fffff097          	auipc	ra,0xfffff
    80001dbc:	622080e7          	jalr	1570(ra) # 800013da <uvmdealloc>
    80001dc0:	0005061b          	sext.w	a2,a0
    80001dc4:	bf55                	j	80001d78 <growproc+0x26>

0000000080001dc6 <fork>:
{
    80001dc6:	7179                	addi	sp,sp,-48
    80001dc8:	f406                	sd	ra,40(sp)
    80001dca:	f022                	sd	s0,32(sp)
    80001dcc:	ec26                	sd	s1,24(sp)
    80001dce:	e84a                	sd	s2,16(sp)
    80001dd0:	e44e                	sd	s3,8(sp)
    80001dd2:	e052                	sd	s4,0(sp)
    80001dd4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dd6:	00000097          	auipc	ra,0x0
    80001dda:	bda080e7          	jalr	-1062(ra) # 800019b0 <myproc>
    80001dde:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001de0:	00000097          	auipc	ra,0x0
    80001de4:	e22080e7          	jalr	-478(ra) # 80001c02 <allocproc>
    80001de8:	14050463          	beqz	a0,80001f30 <fork+0x16a>
    80001dec:	89aa                	mv	s3,a0
  acquire(&tickslock);
    80001dee:	00016517          	auipc	a0,0x16
    80001df2:	8e250513          	addi	a0,a0,-1822 # 800176d0 <tickslock>
    80001df6:	fffff097          	auipc	ra,0xfffff
    80001dfa:	dee080e7          	jalr	-530(ra) # 80000be4 <acquire>
  xticks = ticks;
    80001dfe:	00007497          	auipc	s1,0x7
    80001e02:	2324a483          	lw	s1,562(s1) # 80009030 <ticks>
  release(&tickslock);
    80001e06:	00016517          	auipc	a0,0x16
    80001e0a:	8ca50513          	addi	a0,a0,-1846 # 800176d0 <tickslock>
    80001e0e:	fffff097          	auipc	ra,0xfffff
    80001e12:	e8a080e7          	jalr	-374(ra) # 80000c98 <release>
  p->ctime = xticks;
    80001e16:	1482                	slli	s1,s1,0x20
    80001e18:	9081                	srli	s1,s1,0x20
    80001e1a:	16993423          	sd	s1,360(s2)
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e1e:	04893603          	ld	a2,72(s2)
    80001e22:	0509b583          	ld	a1,80(s3)
    80001e26:	05093503          	ld	a0,80(s2)
    80001e2a:	fffff097          	auipc	ra,0xfffff
    80001e2e:	744080e7          	jalr	1860(ra) # 8000156e <uvmcopy>
    80001e32:	04054663          	bltz	a0,80001e7e <fork+0xb8>
  np->sz = p->sz;
    80001e36:	04893783          	ld	a5,72(s2)
    80001e3a:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e3e:	05893683          	ld	a3,88(s2)
    80001e42:	87b6                	mv	a5,a3
    80001e44:	0589b703          	ld	a4,88(s3)
    80001e48:	12068693          	addi	a3,a3,288
    80001e4c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e50:	6788                	ld	a0,8(a5)
    80001e52:	6b8c                	ld	a1,16(a5)
    80001e54:	6f90                	ld	a2,24(a5)
    80001e56:	01073023          	sd	a6,0(a4)
    80001e5a:	e708                	sd	a0,8(a4)
    80001e5c:	eb0c                	sd	a1,16(a4)
    80001e5e:	ef10                	sd	a2,24(a4)
    80001e60:	02078793          	addi	a5,a5,32
    80001e64:	02070713          	addi	a4,a4,32
    80001e68:	fed792e3          	bne	a5,a3,80001e4c <fork+0x86>
  np->trapframe->a0 = 0;
    80001e6c:	0589b783          	ld	a5,88(s3)
    80001e70:	0607b823          	sd	zero,112(a5)
    80001e74:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001e78:	15000a13          	li	s4,336
    80001e7c:	a03d                	j	80001eaa <fork+0xe4>
    freeproc(np);
    80001e7e:	854e                	mv	a0,s3
    80001e80:	00000097          	auipc	ra,0x0
    80001e84:	d2a080e7          	jalr	-726(ra) # 80001baa <freeproc>
    release(&np->lock);
    80001e88:	854e                	mv	a0,s3
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	e0e080e7          	jalr	-498(ra) # 80000c98 <release>
    return -1;
    80001e92:	5a7d                	li	s4,-1
    80001e94:	a069                	j	80001f1e <fork+0x158>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e96:	00003097          	auipc	ra,0x3
    80001e9a:	d62080e7          	jalr	-670(ra) # 80004bf8 <filedup>
    80001e9e:	009987b3          	add	a5,s3,s1
    80001ea2:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001ea4:	04a1                	addi	s1,s1,8
    80001ea6:	01448763          	beq	s1,s4,80001eb4 <fork+0xee>
    if(p->ofile[i])
    80001eaa:	009907b3          	add	a5,s2,s1
    80001eae:	6388                	ld	a0,0(a5)
    80001eb0:	f17d                	bnez	a0,80001e96 <fork+0xd0>
    80001eb2:	bfcd                	j	80001ea4 <fork+0xde>
  np->cwd = idup(p->cwd);
    80001eb4:	15093503          	ld	a0,336(s2)
    80001eb8:	00002097          	auipc	ra,0x2
    80001ebc:	eb6080e7          	jalr	-330(ra) # 80003d6e <idup>
    80001ec0:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ec4:	4641                	li	a2,16
    80001ec6:	15890593          	addi	a1,s2,344
    80001eca:	15898513          	addi	a0,s3,344
    80001ece:	fffff097          	auipc	ra,0xfffff
    80001ed2:	f64080e7          	jalr	-156(ra) # 80000e32 <safestrcpy>
  pid = np->pid;
    80001ed6:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001eda:	854e                	mv	a0,s3
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	dbc080e7          	jalr	-580(ra) # 80000c98 <release>
  acquire(&wait_lock);
    80001ee4:	0000f497          	auipc	s1,0xf
    80001ee8:	3d448493          	addi	s1,s1,980 # 800112b8 <wait_lock>
    80001eec:	8526                	mv	a0,s1
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	cf6080e7          	jalr	-778(ra) # 80000be4 <acquire>
  np->parent = p;
    80001ef6:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001efa:	8526                	mv	a0,s1
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	d9c080e7          	jalr	-612(ra) # 80000c98 <release>
  acquire(&np->lock);
    80001f04:	854e                	mv	a0,s3
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	cde080e7          	jalr	-802(ra) # 80000be4 <acquire>
  np->state = RUNNABLE;
    80001f0e:	478d                	li	a5,3
    80001f10:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f14:	854e                	mv	a0,s3
    80001f16:	fffff097          	auipc	ra,0xfffff
    80001f1a:	d82080e7          	jalr	-638(ra) # 80000c98 <release>
}
    80001f1e:	8552                	mv	a0,s4
    80001f20:	70a2                	ld	ra,40(sp)
    80001f22:	7402                	ld	s0,32(sp)
    80001f24:	64e2                	ld	s1,24(sp)
    80001f26:	6942                	ld	s2,16(sp)
    80001f28:	69a2                	ld	s3,8(sp)
    80001f2a:	6a02                	ld	s4,0(sp)
    80001f2c:	6145                	addi	sp,sp,48
    80001f2e:	8082                	ret
    return -1;
    80001f30:	5a7d                	li	s4,-1
    80001f32:	b7f5                	j	80001f1e <fork+0x158>

0000000080001f34 <forkf>:
{
    80001f34:	7179                	addi	sp,sp,-48
    80001f36:	f406                	sd	ra,40(sp)
    80001f38:	f022                	sd	s0,32(sp)
    80001f3a:	ec26                	sd	s1,24(sp)
    80001f3c:	e84a                	sd	s2,16(sp)
    80001f3e:	e44e                	sd	s3,8(sp)
    80001f40:	e052                	sd	s4,0(sp)
    80001f42:	1800                	addi	s0,sp,48
    80001f44:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f46:	00000097          	auipc	ra,0x0
    80001f4a:	a6a080e7          	jalr	-1430(ra) # 800019b0 <myproc>
    80001f4e:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001f50:	00000097          	auipc	ra,0x0
    80001f54:	cb2080e7          	jalr	-846(ra) # 80001c02 <allocproc>
    80001f58:	14050b63          	beqz	a0,800020ae <forkf+0x17a>
    80001f5c:	89aa                	mv	s3,a0
  acquire(&tickslock);
    80001f5e:	00015517          	auipc	a0,0x15
    80001f62:	77250513          	addi	a0,a0,1906 # 800176d0 <tickslock>
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	c7e080e7          	jalr	-898(ra) # 80000be4 <acquire>
  xticks = ticks;
    80001f6e:	00007a17          	auipc	s4,0x7
    80001f72:	0c2a2a03          	lw	s4,194(s4) # 80009030 <ticks>
  release(&tickslock);
    80001f76:	00015517          	auipc	a0,0x15
    80001f7a:	75a50513          	addi	a0,a0,1882 # 800176d0 <tickslock>
    80001f7e:	fffff097          	auipc	ra,0xfffff
    80001f82:	d1a080e7          	jalr	-742(ra) # 80000c98 <release>
  p->ctime = xticks;
    80001f86:	1a02                	slli	s4,s4,0x20
    80001f88:	020a5a13          	srli	s4,s4,0x20
    80001f8c:	17493423          	sd	s4,360(s2)
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f90:	04893603          	ld	a2,72(s2)
    80001f94:	0509b583          	ld	a1,80(s3)
    80001f98:	05093503          	ld	a0,80(s2)
    80001f9c:	fffff097          	auipc	ra,0xfffff
    80001fa0:	5d2080e7          	jalr	1490(ra) # 8000156e <uvmcopy>
    80001fa4:	04054c63          	bltz	a0,80001ffc <forkf+0xc8>
  np->sz = p->sz;
    80001fa8:	04893783          	ld	a5,72(s2)
    80001fac:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001fb0:	05893683          	ld	a3,88(s2)
    80001fb4:	87b6                	mv	a5,a3
    80001fb6:	0589b703          	ld	a4,88(s3)
    80001fba:	12068693          	addi	a3,a3,288
    80001fbe:	0007b883          	ld	a7,0(a5)
    80001fc2:	0087b803          	ld	a6,8(a5)
    80001fc6:	6b8c                	ld	a1,16(a5)
    80001fc8:	6f90                	ld	a2,24(a5)
    80001fca:	01173023          	sd	a7,0(a4)
    80001fce:	01073423          	sd	a6,8(a4)
    80001fd2:	eb0c                	sd	a1,16(a4)
    80001fd4:	ef10                	sd	a2,24(a4)
    80001fd6:	02078793          	addi	a5,a5,32
    80001fda:	02070713          	addi	a4,a4,32
    80001fde:	fed790e3          	bne	a5,a3,80001fbe <forkf+0x8a>
  np->trapframe->epc = *((int*)(f));
    80001fe2:	0589b783          	ld	a5,88(s3)
    80001fe6:	4098                	lw	a4,0(s1)
    80001fe8:	ef98                	sd	a4,24(a5)
  np->trapframe->a0 = 0;
    80001fea:	0589b783          	ld	a5,88(s3)
    80001fee:	0607b823          	sd	zero,112(a5)
    80001ff2:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001ff6:	15000a13          	li	s4,336
    80001ffa:	a03d                	j	80002028 <forkf+0xf4>
    freeproc(np);
    80001ffc:	854e                	mv	a0,s3
    80001ffe:	00000097          	auipc	ra,0x0
    80002002:	bac080e7          	jalr	-1108(ra) # 80001baa <freeproc>
    release(&np->lock);
    80002006:	854e                	mv	a0,s3
    80002008:	fffff097          	auipc	ra,0xfffff
    8000200c:	c90080e7          	jalr	-880(ra) # 80000c98 <release>
    return -1;
    80002010:	5a7d                	li	s4,-1
    80002012:	a069                	j	8000209c <forkf+0x168>
      np->ofile[i] = filedup(p->ofile[i]);
    80002014:	00003097          	auipc	ra,0x3
    80002018:	be4080e7          	jalr	-1052(ra) # 80004bf8 <filedup>
    8000201c:	009987b3          	add	a5,s3,s1
    80002020:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80002022:	04a1                	addi	s1,s1,8
    80002024:	01448763          	beq	s1,s4,80002032 <forkf+0xfe>
    if(p->ofile[i])
    80002028:	009907b3          	add	a5,s2,s1
    8000202c:	6388                	ld	a0,0(a5)
    8000202e:	f17d                	bnez	a0,80002014 <forkf+0xe0>
    80002030:	bfcd                	j	80002022 <forkf+0xee>
  np->cwd = idup(p->cwd);
    80002032:	15093503          	ld	a0,336(s2)
    80002036:	00002097          	auipc	ra,0x2
    8000203a:	d38080e7          	jalr	-712(ra) # 80003d6e <idup>
    8000203e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002042:	4641                	li	a2,16
    80002044:	15890593          	addi	a1,s2,344
    80002048:	15898513          	addi	a0,s3,344
    8000204c:	fffff097          	auipc	ra,0xfffff
    80002050:	de6080e7          	jalr	-538(ra) # 80000e32 <safestrcpy>
  pid = np->pid;
    80002054:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80002058:	854e                	mv	a0,s3
    8000205a:	fffff097          	auipc	ra,0xfffff
    8000205e:	c3e080e7          	jalr	-962(ra) # 80000c98 <release>
  acquire(&wait_lock);
    80002062:	0000f497          	auipc	s1,0xf
    80002066:	25648493          	addi	s1,s1,598 # 800112b8 <wait_lock>
    8000206a:	8526                	mv	a0,s1
    8000206c:	fffff097          	auipc	ra,0xfffff
    80002070:	b78080e7          	jalr	-1160(ra) # 80000be4 <acquire>
  np->parent = p;
    80002074:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80002078:	8526                	mv	a0,s1
    8000207a:	fffff097          	auipc	ra,0xfffff
    8000207e:	c1e080e7          	jalr	-994(ra) # 80000c98 <release>
  acquire(&np->lock);
    80002082:	854e                	mv	a0,s3
    80002084:	fffff097          	auipc	ra,0xfffff
    80002088:	b60080e7          	jalr	-1184(ra) # 80000be4 <acquire>
  np->state = RUNNABLE;
    8000208c:	478d                	li	a5,3
    8000208e:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002092:	854e                	mv	a0,s3
    80002094:	fffff097          	auipc	ra,0xfffff
    80002098:	c04080e7          	jalr	-1020(ra) # 80000c98 <release>
}
    8000209c:	8552                	mv	a0,s4
    8000209e:	70a2                	ld	ra,40(sp)
    800020a0:	7402                	ld	s0,32(sp)
    800020a2:	64e2                	ld	s1,24(sp)
    800020a4:	6942                	ld	s2,16(sp)
    800020a6:	69a2                	ld	s3,8(sp)
    800020a8:	6a02                	ld	s4,0(sp)
    800020aa:	6145                	addi	sp,sp,48
    800020ac:	8082                	ret
    return -1;
    800020ae:	5a7d                	li	s4,-1
    800020b0:	b7f5                	j	8000209c <forkf+0x168>

00000000800020b2 <scheduler>:
{
    800020b2:	7139                	addi	sp,sp,-64
    800020b4:	fc06                	sd	ra,56(sp)
    800020b6:	f822                	sd	s0,48(sp)
    800020b8:	f426                	sd	s1,40(sp)
    800020ba:	f04a                	sd	s2,32(sp)
    800020bc:	ec4e                	sd	s3,24(sp)
    800020be:	e852                	sd	s4,16(sp)
    800020c0:	e456                	sd	s5,8(sp)
    800020c2:	e05a                	sd	s6,0(sp)
    800020c4:	0080                	addi	s0,sp,64
    800020c6:	8792                	mv	a5,tp
  int id = r_tp();
    800020c8:	2781                	sext.w	a5,a5
  c->proc = 0;
    800020ca:	00779a93          	slli	s5,a5,0x7
    800020ce:	0000f717          	auipc	a4,0xf
    800020d2:	1d270713          	addi	a4,a4,466 # 800112a0 <pid_lock>
    800020d6:	9756                	add	a4,a4,s5
    800020d8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800020dc:	0000f717          	auipc	a4,0xf
    800020e0:	1fc70713          	addi	a4,a4,508 # 800112d8 <cpus+0x8>
    800020e4:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    800020e6:	498d                	li	s3,3
        p->state = RUNNING;
    800020e8:	4b11                	li	s6,4
        c->proc = p;
    800020ea:	079e                	slli	a5,a5,0x7
    800020ec:	0000fa17          	auipc	s4,0xf
    800020f0:	1b4a0a13          	addi	s4,s4,436 # 800112a0 <pid_lock>
    800020f4:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800020f6:	00015917          	auipc	s2,0x15
    800020fa:	5da90913          	addi	s2,s2,1498 # 800176d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020fe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002102:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002106:	10079073          	csrw	sstatus,a5
    8000210a:	0000f497          	auipc	s1,0xf
    8000210e:	5c648493          	addi	s1,s1,1478 # 800116d0 <proc>
    80002112:	a03d                	j	80002140 <scheduler+0x8e>
        p->state = RUNNING;
    80002114:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002118:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000211c:	06048593          	addi	a1,s1,96
    80002120:	8556                	mv	a0,s5
    80002122:	00001097          	auipc	ra,0x1
    80002126:	ae2080e7          	jalr	-1310(ra) # 80002c04 <swtch>
        c->proc = 0;
    8000212a:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    8000212e:	8526                	mv	a0,s1
    80002130:	fffff097          	auipc	ra,0xfffff
    80002134:	b68080e7          	jalr	-1176(ra) # 80000c98 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002138:	18048493          	addi	s1,s1,384
    8000213c:	fd2481e3          	beq	s1,s2,800020fe <scheduler+0x4c>
      acquire(&p->lock);
    80002140:	8526                	mv	a0,s1
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	aa2080e7          	jalr	-1374(ra) # 80000be4 <acquire>
      if(p->state == RUNNABLE) {
    8000214a:	4c9c                	lw	a5,24(s1)
    8000214c:	ff3791e3          	bne	a5,s3,8000212e <scheduler+0x7c>
    80002150:	b7d1                	j	80002114 <scheduler+0x62>

0000000080002152 <sched>:
{
    80002152:	7179                	addi	sp,sp,-48
    80002154:	f406                	sd	ra,40(sp)
    80002156:	f022                	sd	s0,32(sp)
    80002158:	ec26                	sd	s1,24(sp)
    8000215a:	e84a                	sd	s2,16(sp)
    8000215c:	e44e                	sd	s3,8(sp)
    8000215e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002160:	00000097          	auipc	ra,0x0
    80002164:	850080e7          	jalr	-1968(ra) # 800019b0 <myproc>
    80002168:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	a00080e7          	jalr	-1536(ra) # 80000b6a <holding>
    80002172:	c93d                	beqz	a0,800021e8 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002174:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002176:	2781                	sext.w	a5,a5
    80002178:	079e                	slli	a5,a5,0x7
    8000217a:	0000f717          	auipc	a4,0xf
    8000217e:	12670713          	addi	a4,a4,294 # 800112a0 <pid_lock>
    80002182:	97ba                	add	a5,a5,a4
    80002184:	0a87a703          	lw	a4,168(a5)
    80002188:	4785                	li	a5,1
    8000218a:	06f71763          	bne	a4,a5,800021f8 <sched+0xa6>
  if(p->state == RUNNING)
    8000218e:	4c98                	lw	a4,24(s1)
    80002190:	4791                	li	a5,4
    80002192:	06f70b63          	beq	a4,a5,80002208 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002196:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000219a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000219c:	efb5                	bnez	a5,80002218 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000219e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800021a0:	0000f917          	auipc	s2,0xf
    800021a4:	10090913          	addi	s2,s2,256 # 800112a0 <pid_lock>
    800021a8:	2781                	sext.w	a5,a5
    800021aa:	079e                	slli	a5,a5,0x7
    800021ac:	97ca                	add	a5,a5,s2
    800021ae:	0ac7a983          	lw	s3,172(a5)
    800021b2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800021b4:	2781                	sext.w	a5,a5
    800021b6:	079e                	slli	a5,a5,0x7
    800021b8:	0000f597          	auipc	a1,0xf
    800021bc:	12058593          	addi	a1,a1,288 # 800112d8 <cpus+0x8>
    800021c0:	95be                	add	a1,a1,a5
    800021c2:	06048513          	addi	a0,s1,96
    800021c6:	00001097          	auipc	ra,0x1
    800021ca:	a3e080e7          	jalr	-1474(ra) # 80002c04 <swtch>
    800021ce:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021d0:	2781                	sext.w	a5,a5
    800021d2:	079e                	slli	a5,a5,0x7
    800021d4:	97ca                	add	a5,a5,s2
    800021d6:	0b37a623          	sw	s3,172(a5)
}
    800021da:	70a2                	ld	ra,40(sp)
    800021dc:	7402                	ld	s0,32(sp)
    800021de:	64e2                	ld	s1,24(sp)
    800021e0:	6942                	ld	s2,16(sp)
    800021e2:	69a2                	ld	s3,8(sp)
    800021e4:	6145                	addi	sp,sp,48
    800021e6:	8082                	ret
    panic("sched p->lock");
    800021e8:	00006517          	auipc	a0,0x6
    800021ec:	03050513          	addi	a0,a0,48 # 80008218 <digits+0x1d8>
    800021f0:	ffffe097          	auipc	ra,0xffffe
    800021f4:	34e080e7          	jalr	846(ra) # 8000053e <panic>
    panic("sched locks");
    800021f8:	00006517          	auipc	a0,0x6
    800021fc:	03050513          	addi	a0,a0,48 # 80008228 <digits+0x1e8>
    80002200:	ffffe097          	auipc	ra,0xffffe
    80002204:	33e080e7          	jalr	830(ra) # 8000053e <panic>
    panic("sched running");
    80002208:	00006517          	auipc	a0,0x6
    8000220c:	03050513          	addi	a0,a0,48 # 80008238 <digits+0x1f8>
    80002210:	ffffe097          	auipc	ra,0xffffe
    80002214:	32e080e7          	jalr	814(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002218:	00006517          	auipc	a0,0x6
    8000221c:	03050513          	addi	a0,a0,48 # 80008248 <digits+0x208>
    80002220:	ffffe097          	auipc	ra,0xffffe
    80002224:	31e080e7          	jalr	798(ra) # 8000053e <panic>

0000000080002228 <yield>:
{
    80002228:	1101                	addi	sp,sp,-32
    8000222a:	ec06                	sd	ra,24(sp)
    8000222c:	e822                	sd	s0,16(sp)
    8000222e:	e426                	sd	s1,8(sp)
    80002230:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	77e080e7          	jalr	1918(ra) # 800019b0 <myproc>
    8000223a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000223c:	fffff097          	auipc	ra,0xfffff
    80002240:	9a8080e7          	jalr	-1624(ra) # 80000be4 <acquire>
  p->state = RUNNABLE;
    80002244:	478d                	li	a5,3
    80002246:	cc9c                	sw	a5,24(s1)
  sched();
    80002248:	00000097          	auipc	ra,0x0
    8000224c:	f0a080e7          	jalr	-246(ra) # 80002152 <sched>
  release(&p->lock);
    80002250:	8526                	mv	a0,s1
    80002252:	fffff097          	auipc	ra,0xfffff
    80002256:	a46080e7          	jalr	-1466(ra) # 80000c98 <release>
}
    8000225a:	60e2                	ld	ra,24(sp)
    8000225c:	6442                	ld	s0,16(sp)
    8000225e:	64a2                	ld	s1,8(sp)
    80002260:	6105                	addi	sp,sp,32
    80002262:	8082                	ret

0000000080002264 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002264:	7179                	addi	sp,sp,-48
    80002266:	f406                	sd	ra,40(sp)
    80002268:	f022                	sd	s0,32(sp)
    8000226a:	ec26                	sd	s1,24(sp)
    8000226c:	e84a                	sd	s2,16(sp)
    8000226e:	e44e                	sd	s3,8(sp)
    80002270:	1800                	addi	s0,sp,48
    80002272:	89aa                	mv	s3,a0
    80002274:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	73a080e7          	jalr	1850(ra) # 800019b0 <myproc>
    8000227e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	964080e7          	jalr	-1692(ra) # 80000be4 <acquire>
  release(lk);
    80002288:	854a                	mv	a0,s2
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	a0e080e7          	jalr	-1522(ra) # 80000c98 <release>

  // Go to sleep.
  p->chan = chan;
    80002292:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002296:	4789                	li	a5,2
    80002298:	cc9c                	sw	a5,24(s1)

  sched();
    8000229a:	00000097          	auipc	ra,0x0
    8000229e:	eb8080e7          	jalr	-328(ra) # 80002152 <sched>

  // Tidy up.
  p->chan = 0;
    800022a2:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800022a6:	8526                	mv	a0,s1
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	9f0080e7          	jalr	-1552(ra) # 80000c98 <release>
  acquire(lk);
    800022b0:	854a                	mv	a0,s2
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	932080e7          	jalr	-1742(ra) # 80000be4 <acquire>
}
    800022ba:	70a2                	ld	ra,40(sp)
    800022bc:	7402                	ld	s0,32(sp)
    800022be:	64e2                	ld	s1,24(sp)
    800022c0:	6942                	ld	s2,16(sp)
    800022c2:	69a2                	ld	s3,8(sp)
    800022c4:	6145                	addi	sp,sp,48
    800022c6:	8082                	ret

00000000800022c8 <wait>:
{
    800022c8:	715d                	addi	sp,sp,-80
    800022ca:	e486                	sd	ra,72(sp)
    800022cc:	e0a2                	sd	s0,64(sp)
    800022ce:	fc26                	sd	s1,56(sp)
    800022d0:	f84a                	sd	s2,48(sp)
    800022d2:	f44e                	sd	s3,40(sp)
    800022d4:	f052                	sd	s4,32(sp)
    800022d6:	ec56                	sd	s5,24(sp)
    800022d8:	e85a                	sd	s6,16(sp)
    800022da:	e45e                	sd	s7,8(sp)
    800022dc:	e062                	sd	s8,0(sp)
    800022de:	0880                	addi	s0,sp,80
    800022e0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022e2:	fffff097          	auipc	ra,0xfffff
    800022e6:	6ce080e7          	jalr	1742(ra) # 800019b0 <myproc>
    800022ea:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800022ec:	0000f517          	auipc	a0,0xf
    800022f0:	fcc50513          	addi	a0,a0,-52 # 800112b8 <wait_lock>
    800022f4:	fffff097          	auipc	ra,0xfffff
    800022f8:	8f0080e7          	jalr	-1808(ra) # 80000be4 <acquire>
    havekids = 0;
    800022fc:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800022fe:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    80002300:	00015997          	auipc	s3,0x15
    80002304:	3d098993          	addi	s3,s3,976 # 800176d0 <tickslock>
        havekids = 1;
    80002308:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000230a:	0000fc17          	auipc	s8,0xf
    8000230e:	faec0c13          	addi	s8,s8,-82 # 800112b8 <wait_lock>
    havekids = 0;
    80002312:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002314:	0000f497          	auipc	s1,0xf
    80002318:	3bc48493          	addi	s1,s1,956 # 800116d0 <proc>
    8000231c:	a0bd                	j	8000238a <wait+0xc2>
          pid = np->pid;
    8000231e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002322:	000b0e63          	beqz	s6,8000233e <wait+0x76>
    80002326:	4691                	li	a3,4
    80002328:	02c48613          	addi	a2,s1,44
    8000232c:	85da                	mv	a1,s6
    8000232e:	05093503          	ld	a0,80(s2)
    80002332:	fffff097          	auipc	ra,0xfffff
    80002336:	340080e7          	jalr	832(ra) # 80001672 <copyout>
    8000233a:	02054563          	bltz	a0,80002364 <wait+0x9c>
          freeproc(np);
    8000233e:	8526                	mv	a0,s1
    80002340:	00000097          	auipc	ra,0x0
    80002344:	86a080e7          	jalr	-1942(ra) # 80001baa <freeproc>
          release(&np->lock);
    80002348:	8526                	mv	a0,s1
    8000234a:	fffff097          	auipc	ra,0xfffff
    8000234e:	94e080e7          	jalr	-1714(ra) # 80000c98 <release>
          release(&wait_lock);
    80002352:	0000f517          	auipc	a0,0xf
    80002356:	f6650513          	addi	a0,a0,-154 # 800112b8 <wait_lock>
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	93e080e7          	jalr	-1730(ra) # 80000c98 <release>
          return pid;
    80002362:	a09d                	j	800023c8 <wait+0x100>
            release(&np->lock);
    80002364:	8526                	mv	a0,s1
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	932080e7          	jalr	-1742(ra) # 80000c98 <release>
            release(&wait_lock);
    8000236e:	0000f517          	auipc	a0,0xf
    80002372:	f4a50513          	addi	a0,a0,-182 # 800112b8 <wait_lock>
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	922080e7          	jalr	-1758(ra) # 80000c98 <release>
            return -1;
    8000237e:	59fd                	li	s3,-1
    80002380:	a0a1                	j	800023c8 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002382:	18048493          	addi	s1,s1,384
    80002386:	03348463          	beq	s1,s3,800023ae <wait+0xe6>
      if(np->parent == p){
    8000238a:	7c9c                	ld	a5,56(s1)
    8000238c:	ff279be3          	bne	a5,s2,80002382 <wait+0xba>
        acquire(&np->lock);
    80002390:	8526                	mv	a0,s1
    80002392:	fffff097          	auipc	ra,0xfffff
    80002396:	852080e7          	jalr	-1966(ra) # 80000be4 <acquire>
        if(np->state == ZOMBIE){
    8000239a:	4c9c                	lw	a5,24(s1)
    8000239c:	f94781e3          	beq	a5,s4,8000231e <wait+0x56>
        release(&np->lock);
    800023a0:	8526                	mv	a0,s1
    800023a2:	fffff097          	auipc	ra,0xfffff
    800023a6:	8f6080e7          	jalr	-1802(ra) # 80000c98 <release>
        havekids = 1;
    800023aa:	8756                	mv	a4,s5
    800023ac:	bfd9                	j	80002382 <wait+0xba>
    if(!havekids || p->killed){
    800023ae:	c701                	beqz	a4,800023b6 <wait+0xee>
    800023b0:	02892783          	lw	a5,40(s2)
    800023b4:	c79d                	beqz	a5,800023e2 <wait+0x11a>
      release(&wait_lock);
    800023b6:	0000f517          	auipc	a0,0xf
    800023ba:	f0250513          	addi	a0,a0,-254 # 800112b8 <wait_lock>
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	8da080e7          	jalr	-1830(ra) # 80000c98 <release>
      return -1;
    800023c6:	59fd                	li	s3,-1
}
    800023c8:	854e                	mv	a0,s3
    800023ca:	60a6                	ld	ra,72(sp)
    800023cc:	6406                	ld	s0,64(sp)
    800023ce:	74e2                	ld	s1,56(sp)
    800023d0:	7942                	ld	s2,48(sp)
    800023d2:	79a2                	ld	s3,40(sp)
    800023d4:	7a02                	ld	s4,32(sp)
    800023d6:	6ae2                	ld	s5,24(sp)
    800023d8:	6b42                	ld	s6,16(sp)
    800023da:	6ba2                	ld	s7,8(sp)
    800023dc:	6c02                	ld	s8,0(sp)
    800023de:	6161                	addi	sp,sp,80
    800023e0:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023e2:	85e2                	mv	a1,s8
    800023e4:	854a                	mv	a0,s2
    800023e6:	00000097          	auipc	ra,0x0
    800023ea:	e7e080e7          	jalr	-386(ra) # 80002264 <sleep>
    havekids = 0;
    800023ee:	b715                	j	80002312 <wait+0x4a>

00000000800023f0 <waitpid>:
{
    800023f0:	711d                	addi	sp,sp,-96
    800023f2:	ec86                	sd	ra,88(sp)
    800023f4:	e8a2                	sd	s0,80(sp)
    800023f6:	e4a6                	sd	s1,72(sp)
    800023f8:	e0ca                	sd	s2,64(sp)
    800023fa:	fc4e                	sd	s3,56(sp)
    800023fc:	f852                	sd	s4,48(sp)
    800023fe:	f456                	sd	s5,40(sp)
    80002400:	f05a                	sd	s6,32(sp)
    80002402:	ec5e                	sd	s7,24(sp)
    80002404:	e862                	sd	s8,16(sp)
    80002406:	e466                	sd	s9,8(sp)
    80002408:	1080                	addi	s0,sp,96
    8000240a:	892a                	mv	s2,a0
    8000240c:	8bae                	mv	s7,a1
  struct proc *p = myproc();
    8000240e:	fffff097          	auipc	ra,0xfffff
    80002412:	5a2080e7          	jalr	1442(ra) # 800019b0 <myproc>
    80002416:	8a2a                	mv	s4,a0
  acquire(&wait_lock);
    80002418:	0000f517          	auipc	a0,0xf
    8000241c:	ea050513          	addi	a0,a0,-352 # 800112b8 <wait_lock>
    80002420:	ffffe097          	auipc	ra,0xffffe
    80002424:	7c4080e7          	jalr	1988(ra) # 80000be4 <acquire>
    pexists = 0;
    80002428:	4c01                	li	s8,0
        if(np->state == ZOMBIE){
    8000242a:	4a95                	li	s5,5
    for(np = proc; np < &proc[NPROC]; np++){
    8000242c:	00015997          	auipc	s3,0x15
    80002430:	2a498993          	addi	s3,s3,676 # 800176d0 <tickslock>
        pexists = 1;
    80002434:	4b05                	li	s6,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002436:	0000fc97          	auipc	s9,0xf
    8000243a:	e82c8c93          	addi	s9,s9,-382 # 800112b8 <wait_lock>
    pexists = 0;
    8000243e:	8762                	mv	a4,s8
    for(np = proc; np < &proc[NPROC]; np++){
    80002440:	0000f497          	auipc	s1,0xf
    80002444:	29048493          	addi	s1,s1,656 # 800116d0 <proc>
    80002448:	a0bd                	j	800024b6 <waitpid+0xc6>
          cpid = np->pid;
    8000244a:	0304a903          	lw	s2,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000244e:	000b8e63          	beqz	s7,8000246a <waitpid+0x7a>
    80002452:	4691                	li	a3,4
    80002454:	02c48613          	addi	a2,s1,44
    80002458:	85de                	mv	a1,s7
    8000245a:	050a3503          	ld	a0,80(s4)
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	214080e7          	jalr	532(ra) # 80001672 <copyout>
    80002466:	02054563          	bltz	a0,80002490 <waitpid+0xa0>
          freeproc(np);
    8000246a:	8526                	mv	a0,s1
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	73e080e7          	jalr	1854(ra) # 80001baa <freeproc>
          release(&np->lock);
    80002474:	8526                	mv	a0,s1
    80002476:	fffff097          	auipc	ra,0xfffff
    8000247a:	822080e7          	jalr	-2014(ra) # 80000c98 <release>
          release(&wait_lock);
    8000247e:	0000f517          	auipc	a0,0xf
    80002482:	e3a50513          	addi	a0,a0,-454 # 800112b8 <wait_lock>
    80002486:	fffff097          	auipc	ra,0xfffff
    8000248a:	812080e7          	jalr	-2030(ra) # 80000c98 <release>
          return cpid;
    8000248e:	a0b5                	j	800024fa <waitpid+0x10a>
            release(&np->lock);
    80002490:	8526                	mv	a0,s1
    80002492:	fffff097          	auipc	ra,0xfffff
    80002496:	806080e7          	jalr	-2042(ra) # 80000c98 <release>
            release(&wait_lock);
    8000249a:	0000f517          	auipc	a0,0xf
    8000249e:	e1e50513          	addi	a0,a0,-482 # 800112b8 <wait_lock>
    800024a2:	ffffe097          	auipc	ra,0xffffe
    800024a6:	7f6080e7          	jalr	2038(ra) # 80000c98 <release>
            return -1;
    800024aa:	597d                	li	s2,-1
    800024ac:	a0b9                	j	800024fa <waitpid+0x10a>
    for(np = proc; np < &proc[NPROC]; np++){
    800024ae:	18048493          	addi	s1,s1,384
    800024b2:	03348763          	beq	s1,s3,800024e0 <waitpid+0xf0>
      if(np->pid == pid && np->parent == p){
    800024b6:	589c                	lw	a5,48(s1)
    800024b8:	ff279be3          	bne	a5,s2,800024ae <waitpid+0xbe>
    800024bc:	7c9c                	ld	a5,56(s1)
    800024be:	ff4798e3          	bne	a5,s4,800024ae <waitpid+0xbe>
        acquire(&np->lock);
    800024c2:	8526                	mv	a0,s1
    800024c4:	ffffe097          	auipc	ra,0xffffe
    800024c8:	720080e7          	jalr	1824(ra) # 80000be4 <acquire>
        if(np->state == ZOMBIE){
    800024cc:	4c9c                	lw	a5,24(s1)
    800024ce:	f7578ee3          	beq	a5,s5,8000244a <waitpid+0x5a>
        release(&np->lock);
    800024d2:	8526                	mv	a0,s1
    800024d4:	ffffe097          	auipc	ra,0xffffe
    800024d8:	7c4080e7          	jalr	1988(ra) # 80000c98 <release>
        pexists = 1;
    800024dc:	875a                	mv	a4,s6
    800024de:	bfc1                	j	800024ae <waitpid+0xbe>
    if(!pexists || p->killed){
    800024e0:	c701                	beqz	a4,800024e8 <waitpid+0xf8>
    800024e2:	028a2783          	lw	a5,40(s4)
    800024e6:	cb85                	beqz	a5,80002516 <waitpid+0x126>
      release(&wait_lock);
    800024e8:	0000f517          	auipc	a0,0xf
    800024ec:	dd050513          	addi	a0,a0,-560 # 800112b8 <wait_lock>
    800024f0:	ffffe097          	auipc	ra,0xffffe
    800024f4:	7a8080e7          	jalr	1960(ra) # 80000c98 <release>
      return -1;
    800024f8:	597d                	li	s2,-1
}
    800024fa:	854a                	mv	a0,s2
    800024fc:	60e6                	ld	ra,88(sp)
    800024fe:	6446                	ld	s0,80(sp)
    80002500:	64a6                	ld	s1,72(sp)
    80002502:	6906                	ld	s2,64(sp)
    80002504:	79e2                	ld	s3,56(sp)
    80002506:	7a42                	ld	s4,48(sp)
    80002508:	7aa2                	ld	s5,40(sp)
    8000250a:	7b02                	ld	s6,32(sp)
    8000250c:	6be2                	ld	s7,24(sp)
    8000250e:	6c42                	ld	s8,16(sp)
    80002510:	6ca2                	ld	s9,8(sp)
    80002512:	6125                	addi	sp,sp,96
    80002514:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002516:	85e6                	mv	a1,s9
    80002518:	8552                	mv	a0,s4
    8000251a:	00000097          	auipc	ra,0x0
    8000251e:	d4a080e7          	jalr	-694(ra) # 80002264 <sleep>
    pexists = 0;
    80002522:	bf31                	j	8000243e <waitpid+0x4e>

0000000080002524 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002524:	7139                	addi	sp,sp,-64
    80002526:	fc06                	sd	ra,56(sp)
    80002528:	f822                	sd	s0,48(sp)
    8000252a:	f426                	sd	s1,40(sp)
    8000252c:	f04a                	sd	s2,32(sp)
    8000252e:	ec4e                	sd	s3,24(sp)
    80002530:	e852                	sd	s4,16(sp)
    80002532:	e456                	sd	s5,8(sp)
    80002534:	0080                	addi	s0,sp,64
    80002536:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002538:	0000f497          	auipc	s1,0xf
    8000253c:	19848493          	addi	s1,s1,408 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002540:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002542:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002544:	00015917          	auipc	s2,0x15
    80002548:	18c90913          	addi	s2,s2,396 # 800176d0 <tickslock>
    8000254c:	a821                	j	80002564 <wakeup+0x40>
        p->state = RUNNABLE;
    8000254e:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    80002552:	8526                	mv	a0,s1
    80002554:	ffffe097          	auipc	ra,0xffffe
    80002558:	744080e7          	jalr	1860(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000255c:	18048493          	addi	s1,s1,384
    80002560:	03248463          	beq	s1,s2,80002588 <wakeup+0x64>
    if(p != myproc()){
    80002564:	fffff097          	auipc	ra,0xfffff
    80002568:	44c080e7          	jalr	1100(ra) # 800019b0 <myproc>
    8000256c:	fea488e3          	beq	s1,a0,8000255c <wakeup+0x38>
      acquire(&p->lock);
    80002570:	8526                	mv	a0,s1
    80002572:	ffffe097          	auipc	ra,0xffffe
    80002576:	672080e7          	jalr	1650(ra) # 80000be4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000257a:	4c9c                	lw	a5,24(s1)
    8000257c:	fd379be3          	bne	a5,s3,80002552 <wakeup+0x2e>
    80002580:	709c                	ld	a5,32(s1)
    80002582:	fd4798e3          	bne	a5,s4,80002552 <wakeup+0x2e>
    80002586:	b7e1                	j	8000254e <wakeup+0x2a>
    }
  }
}
    80002588:	70e2                	ld	ra,56(sp)
    8000258a:	7442                	ld	s0,48(sp)
    8000258c:	74a2                	ld	s1,40(sp)
    8000258e:	7902                	ld	s2,32(sp)
    80002590:	69e2                	ld	s3,24(sp)
    80002592:	6a42                	ld	s4,16(sp)
    80002594:	6aa2                	ld	s5,8(sp)
    80002596:	6121                	addi	sp,sp,64
    80002598:	8082                	ret

000000008000259a <reparent>:
{
    8000259a:	7179                	addi	sp,sp,-48
    8000259c:	f406                	sd	ra,40(sp)
    8000259e:	f022                	sd	s0,32(sp)
    800025a0:	ec26                	sd	s1,24(sp)
    800025a2:	e84a                	sd	s2,16(sp)
    800025a4:	e44e                	sd	s3,8(sp)
    800025a6:	e052                	sd	s4,0(sp)
    800025a8:	1800                	addi	s0,sp,48
    800025aa:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800025ac:	0000f497          	auipc	s1,0xf
    800025b0:	12448493          	addi	s1,s1,292 # 800116d0 <proc>
      pp->parent = initproc;
    800025b4:	00007a17          	auipc	s4,0x7
    800025b8:	a74a0a13          	addi	s4,s4,-1420 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800025bc:	00015997          	auipc	s3,0x15
    800025c0:	11498993          	addi	s3,s3,276 # 800176d0 <tickslock>
    800025c4:	a029                	j	800025ce <reparent+0x34>
    800025c6:	18048493          	addi	s1,s1,384
    800025ca:	01348d63          	beq	s1,s3,800025e4 <reparent+0x4a>
    if(pp->parent == p){
    800025ce:	7c9c                	ld	a5,56(s1)
    800025d0:	ff279be3          	bne	a5,s2,800025c6 <reparent+0x2c>
      pp->parent = initproc;
    800025d4:	000a3503          	ld	a0,0(s4)
    800025d8:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800025da:	00000097          	auipc	ra,0x0
    800025de:	f4a080e7          	jalr	-182(ra) # 80002524 <wakeup>
    800025e2:	b7d5                	j	800025c6 <reparent+0x2c>
}
    800025e4:	70a2                	ld	ra,40(sp)
    800025e6:	7402                	ld	s0,32(sp)
    800025e8:	64e2                	ld	s1,24(sp)
    800025ea:	6942                	ld	s2,16(sp)
    800025ec:	69a2                	ld	s3,8(sp)
    800025ee:	6a02                	ld	s4,0(sp)
    800025f0:	6145                	addi	sp,sp,48
    800025f2:	8082                	ret

00000000800025f4 <exit>:
{
    800025f4:	7179                	addi	sp,sp,-48
    800025f6:	f406                	sd	ra,40(sp)
    800025f8:	f022                	sd	s0,32(sp)
    800025fa:	ec26                	sd	s1,24(sp)
    800025fc:	e84a                	sd	s2,16(sp)
    800025fe:	e44e                	sd	s3,8(sp)
    80002600:	e052                	sd	s4,0(sp)
    80002602:	1800                	addi	s0,sp,48
    80002604:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002606:	fffff097          	auipc	ra,0xfffff
    8000260a:	3aa080e7          	jalr	938(ra) # 800019b0 <myproc>
    8000260e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002610:	00007797          	auipc	a5,0x7
    80002614:	a187b783          	ld	a5,-1512(a5) # 80009028 <initproc>
    80002618:	0d050493          	addi	s1,a0,208
    8000261c:	15050913          	addi	s2,a0,336
    80002620:	02a79363          	bne	a5,a0,80002646 <exit+0x52>
    panic("init exiting");
    80002624:	00006517          	auipc	a0,0x6
    80002628:	c3c50513          	addi	a0,a0,-964 # 80008260 <digits+0x220>
    8000262c:	ffffe097          	auipc	ra,0xffffe
    80002630:	f12080e7          	jalr	-238(ra) # 8000053e <panic>
      fileclose(f);
    80002634:	00002097          	auipc	ra,0x2
    80002638:	616080e7          	jalr	1558(ra) # 80004c4a <fileclose>
      p->ofile[fd] = 0;
    8000263c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002640:	04a1                	addi	s1,s1,8
    80002642:	01248563          	beq	s1,s2,8000264c <exit+0x58>
    if(p->ofile[fd]){
    80002646:	6088                	ld	a0,0(s1)
    80002648:	f575                	bnez	a0,80002634 <exit+0x40>
    8000264a:	bfdd                	j	80002640 <exit+0x4c>
  begin_op();
    8000264c:	00002097          	auipc	ra,0x2
    80002650:	132080e7          	jalr	306(ra) # 8000477e <begin_op>
  iput(p->cwd);
    80002654:	1509b503          	ld	a0,336(s3)
    80002658:	00002097          	auipc	ra,0x2
    8000265c:	90e080e7          	jalr	-1778(ra) # 80003f66 <iput>
  end_op();
    80002660:	00002097          	auipc	ra,0x2
    80002664:	19e080e7          	jalr	414(ra) # 800047fe <end_op>
  p->cwd = 0;
    80002668:	1409b823          	sd	zero,336(s3)
  acquire(&tickslock);
    8000266c:	00015517          	auipc	a0,0x15
    80002670:	06450513          	addi	a0,a0,100 # 800176d0 <tickslock>
    80002674:	ffffe097          	auipc	ra,0xffffe
    80002678:	570080e7          	jalr	1392(ra) # 80000be4 <acquire>
  xticks = ticks;
    8000267c:	00007497          	auipc	s1,0x7
    80002680:	9b44a483          	lw	s1,-1612(s1) # 80009030 <ticks>
  release(&tickslock);
    80002684:	00015517          	auipc	a0,0x15
    80002688:	04c50513          	addi	a0,a0,76 # 800176d0 <tickslock>
    8000268c:	ffffe097          	auipc	ra,0xffffe
    80002690:	60c080e7          	jalr	1548(ra) # 80000c98 <release>
  p->etime = xticks;
    80002694:	1482                	slli	s1,s1,0x20
    80002696:	9081                	srli	s1,s1,0x20
    80002698:	1699bc23          	sd	s1,376(s3)
  acquire(&wait_lock);
    8000269c:	0000f497          	auipc	s1,0xf
    800026a0:	c1c48493          	addi	s1,s1,-996 # 800112b8 <wait_lock>
    800026a4:	8526                	mv	a0,s1
    800026a6:	ffffe097          	auipc	ra,0xffffe
    800026aa:	53e080e7          	jalr	1342(ra) # 80000be4 <acquire>
  reparent(p);
    800026ae:	854e                	mv	a0,s3
    800026b0:	00000097          	auipc	ra,0x0
    800026b4:	eea080e7          	jalr	-278(ra) # 8000259a <reparent>
  wakeup(p->parent);
    800026b8:	0389b503          	ld	a0,56(s3)
    800026bc:	00000097          	auipc	ra,0x0
    800026c0:	e68080e7          	jalr	-408(ra) # 80002524 <wakeup>
  acquire(&p->lock);
    800026c4:	854e                	mv	a0,s3
    800026c6:	ffffe097          	auipc	ra,0xffffe
    800026ca:	51e080e7          	jalr	1310(ra) # 80000be4 <acquire>
  p->xstate = status;
    800026ce:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800026d2:	4795                	li	a5,5
    800026d4:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800026d8:	8526                	mv	a0,s1
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	5be080e7          	jalr	1470(ra) # 80000c98 <release>
  sched();
    800026e2:	00000097          	auipc	ra,0x0
    800026e6:	a70080e7          	jalr	-1424(ra) # 80002152 <sched>
  panic("zombie exit");
    800026ea:	00006517          	auipc	a0,0x6
    800026ee:	b8650513          	addi	a0,a0,-1146 # 80008270 <digits+0x230>
    800026f2:	ffffe097          	auipc	ra,0xffffe
    800026f6:	e4c080e7          	jalr	-436(ra) # 8000053e <panic>

00000000800026fa <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800026fa:	7179                	addi	sp,sp,-48
    800026fc:	f406                	sd	ra,40(sp)
    800026fe:	f022                	sd	s0,32(sp)
    80002700:	ec26                	sd	s1,24(sp)
    80002702:	e84a                	sd	s2,16(sp)
    80002704:	e44e                	sd	s3,8(sp)
    80002706:	1800                	addi	s0,sp,48
    80002708:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000270a:	0000f497          	auipc	s1,0xf
    8000270e:	fc648493          	addi	s1,s1,-58 # 800116d0 <proc>
    80002712:	00015997          	auipc	s3,0x15
    80002716:	fbe98993          	addi	s3,s3,-66 # 800176d0 <tickslock>
    acquire(&p->lock);
    8000271a:	8526                	mv	a0,s1
    8000271c:	ffffe097          	auipc	ra,0xffffe
    80002720:	4c8080e7          	jalr	1224(ra) # 80000be4 <acquire>
    if(p->pid == pid){
    80002724:	589c                	lw	a5,48(s1)
    80002726:	01278d63          	beq	a5,s2,80002740 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000272a:	8526                	mv	a0,s1
    8000272c:	ffffe097          	auipc	ra,0xffffe
    80002730:	56c080e7          	jalr	1388(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002734:	18048493          	addi	s1,s1,384
    80002738:	ff3491e3          	bne	s1,s3,8000271a <kill+0x20>
  }
  return -1;
    8000273c:	557d                	li	a0,-1
    8000273e:	a829                	j	80002758 <kill+0x5e>
      p->killed = 1;
    80002740:	4785                	li	a5,1
    80002742:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002744:	4c98                	lw	a4,24(s1)
    80002746:	4789                	li	a5,2
    80002748:	00f70f63          	beq	a4,a5,80002766 <kill+0x6c>
      release(&p->lock);
    8000274c:	8526                	mv	a0,s1
    8000274e:	ffffe097          	auipc	ra,0xffffe
    80002752:	54a080e7          	jalr	1354(ra) # 80000c98 <release>
      return 0;
    80002756:	4501                	li	a0,0
}
    80002758:	70a2                	ld	ra,40(sp)
    8000275a:	7402                	ld	s0,32(sp)
    8000275c:	64e2                	ld	s1,24(sp)
    8000275e:	6942                	ld	s2,16(sp)
    80002760:	69a2                	ld	s3,8(sp)
    80002762:	6145                	addi	sp,sp,48
    80002764:	8082                	ret
        p->state = RUNNABLE;
    80002766:	478d                	li	a5,3
    80002768:	cc9c                	sw	a5,24(s1)
    8000276a:	b7cd                	j	8000274c <kill+0x52>

000000008000276c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000276c:	7179                	addi	sp,sp,-48
    8000276e:	f406                	sd	ra,40(sp)
    80002770:	f022                	sd	s0,32(sp)
    80002772:	ec26                	sd	s1,24(sp)
    80002774:	e84a                	sd	s2,16(sp)
    80002776:	e44e                	sd	s3,8(sp)
    80002778:	e052                	sd	s4,0(sp)
    8000277a:	1800                	addi	s0,sp,48
    8000277c:	84aa                	mv	s1,a0
    8000277e:	892e                	mv	s2,a1
    80002780:	89b2                	mv	s3,a2
    80002782:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002784:	fffff097          	auipc	ra,0xfffff
    80002788:	22c080e7          	jalr	556(ra) # 800019b0 <myproc>
  if(user_dst){
    8000278c:	c08d                	beqz	s1,800027ae <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000278e:	86d2                	mv	a3,s4
    80002790:	864e                	mv	a2,s3
    80002792:	85ca                	mv	a1,s2
    80002794:	6928                	ld	a0,80(a0)
    80002796:	fffff097          	auipc	ra,0xfffff
    8000279a:	edc080e7          	jalr	-292(ra) # 80001672 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000279e:	70a2                	ld	ra,40(sp)
    800027a0:	7402                	ld	s0,32(sp)
    800027a2:	64e2                	ld	s1,24(sp)
    800027a4:	6942                	ld	s2,16(sp)
    800027a6:	69a2                	ld	s3,8(sp)
    800027a8:	6a02                	ld	s4,0(sp)
    800027aa:	6145                	addi	sp,sp,48
    800027ac:	8082                	ret
    memmove((char *)dst, src, len);
    800027ae:	000a061b          	sext.w	a2,s4
    800027b2:	85ce                	mv	a1,s3
    800027b4:	854a                	mv	a0,s2
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	58a080e7          	jalr	1418(ra) # 80000d40 <memmove>
    return 0;
    800027be:	8526                	mv	a0,s1
    800027c0:	bff9                	j	8000279e <either_copyout+0x32>

00000000800027c2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800027c2:	7179                	addi	sp,sp,-48
    800027c4:	f406                	sd	ra,40(sp)
    800027c6:	f022                	sd	s0,32(sp)
    800027c8:	ec26                	sd	s1,24(sp)
    800027ca:	e84a                	sd	s2,16(sp)
    800027cc:	e44e                	sd	s3,8(sp)
    800027ce:	e052                	sd	s4,0(sp)
    800027d0:	1800                	addi	s0,sp,48
    800027d2:	892a                	mv	s2,a0
    800027d4:	84ae                	mv	s1,a1
    800027d6:	89b2                	mv	s3,a2
    800027d8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027da:	fffff097          	auipc	ra,0xfffff
    800027de:	1d6080e7          	jalr	470(ra) # 800019b0 <myproc>
  if(user_src){
    800027e2:	c08d                	beqz	s1,80002804 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800027e4:	86d2                	mv	a3,s4
    800027e6:	864e                	mv	a2,s3
    800027e8:	85ca                	mv	a1,s2
    800027ea:	6928                	ld	a0,80(a0)
    800027ec:	fffff097          	auipc	ra,0xfffff
    800027f0:	f12080e7          	jalr	-238(ra) # 800016fe <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800027f4:	70a2                	ld	ra,40(sp)
    800027f6:	7402                	ld	s0,32(sp)
    800027f8:	64e2                	ld	s1,24(sp)
    800027fa:	6942                	ld	s2,16(sp)
    800027fc:	69a2                	ld	s3,8(sp)
    800027fe:	6a02                	ld	s4,0(sp)
    80002800:	6145                	addi	sp,sp,48
    80002802:	8082                	ret
    memmove(dst, (char*)src, len);
    80002804:	000a061b          	sext.w	a2,s4
    80002808:	85ce                	mv	a1,s3
    8000280a:	854a                	mv	a0,s2
    8000280c:	ffffe097          	auipc	ra,0xffffe
    80002810:	534080e7          	jalr	1332(ra) # 80000d40 <memmove>
    return 0;
    80002814:	8526                	mv	a0,s1
    80002816:	bff9                	j	800027f4 <either_copyin+0x32>

0000000080002818 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002818:	715d                	addi	sp,sp,-80
    8000281a:	e486                	sd	ra,72(sp)
    8000281c:	e0a2                	sd	s0,64(sp)
    8000281e:	fc26                	sd	s1,56(sp)
    80002820:	f84a                	sd	s2,48(sp)
    80002822:	f44e                	sd	s3,40(sp)
    80002824:	f052                	sd	s4,32(sp)
    80002826:	ec56                	sd	s5,24(sp)
    80002828:	e85a                	sd	s6,16(sp)
    8000282a:	e45e                	sd	s7,8(sp)
    8000282c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000282e:	00006517          	auipc	a0,0x6
    80002832:	89a50513          	addi	a0,a0,-1894 # 800080c8 <digits+0x88>
    80002836:	ffffe097          	auipc	ra,0xffffe
    8000283a:	d52080e7          	jalr	-686(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000283e:	0000f497          	auipc	s1,0xf
    80002842:	fea48493          	addi	s1,s1,-22 # 80011828 <proc+0x158>
    80002846:	00015917          	auipc	s2,0x15
    8000284a:	fe290913          	addi	s2,s2,-30 # 80017828 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000284e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002850:	00006997          	auipc	s3,0x6
    80002854:	a3098993          	addi	s3,s3,-1488 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002858:	00006a97          	auipc	s5,0x6
    8000285c:	a30a8a93          	addi	s5,s5,-1488 # 80008288 <digits+0x248>
    printf("\n");
    80002860:	00006a17          	auipc	s4,0x6
    80002864:	868a0a13          	addi	s4,s4,-1944 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002868:	00006b97          	auipc	s7,0x6
    8000286c:	b00b8b93          	addi	s7,s7,-1280 # 80008368 <states.1767>
    80002870:	a00d                	j	80002892 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002872:	ed86a583          	lw	a1,-296(a3)
    80002876:	8556                	mv	a0,s5
    80002878:	ffffe097          	auipc	ra,0xffffe
    8000287c:	d10080e7          	jalr	-752(ra) # 80000588 <printf>
    printf("\n");
    80002880:	8552                	mv	a0,s4
    80002882:	ffffe097          	auipc	ra,0xffffe
    80002886:	d06080e7          	jalr	-762(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000288a:	18048493          	addi	s1,s1,384
    8000288e:	03248163          	beq	s1,s2,800028b0 <procdump+0x98>
    if(p->state == UNUSED)
    80002892:	86a6                	mv	a3,s1
    80002894:	ec04a783          	lw	a5,-320(s1)
    80002898:	dbed                	beqz	a5,8000288a <procdump+0x72>
      state = "???";
    8000289a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000289c:	fcfb6be3          	bltu	s6,a5,80002872 <procdump+0x5a>
    800028a0:	1782                	slli	a5,a5,0x20
    800028a2:	9381                	srli	a5,a5,0x20
    800028a4:	078e                	slli	a5,a5,0x3
    800028a6:	97de                	add	a5,a5,s7
    800028a8:	6390                	ld	a2,0(a5)
    800028aa:	f661                	bnez	a2,80002872 <procdump+0x5a>
      state = "???";
    800028ac:	864e                	mv	a2,s3
    800028ae:	b7d1                	j	80002872 <procdump+0x5a>
  }
}
    800028b0:	60a6                	ld	ra,72(sp)
    800028b2:	6406                	ld	s0,64(sp)
    800028b4:	74e2                	ld	s1,56(sp)
    800028b6:	7942                	ld	s2,48(sp)
    800028b8:	79a2                	ld	s3,40(sp)
    800028ba:	7a02                	ld	s4,32(sp)
    800028bc:	6ae2                	ld	s5,24(sp)
    800028be:	6b42                	ld	s6,16(sp)
    800028c0:	6ba2                	ld	s7,8(sp)
    800028c2:	6161                	addi	sp,sp,80
    800028c4:	8082                	ret

00000000800028c6 <ps>:

// Implementing ps 
int
ps(void)
{
    800028c6:	7159                	addi	sp,sp,-112
    800028c8:	f486                	sd	ra,104(sp)
    800028ca:	f0a2                	sd	s0,96(sp)
    800028cc:	eca6                	sd	s1,88(sp)
    800028ce:	e8ca                	sd	s2,80(sp)
    800028d0:	e4ce                	sd	s3,72(sp)
    800028d2:	e0d2                	sd	s4,64(sp)
    800028d4:	fc56                	sd	s5,56(sp)
    800028d6:	f85a                	sd	s6,48(sp)
    800028d8:	f45e                	sd	s7,40(sp)
    800028da:	f062                	sd	s8,32(sp)
    800028dc:	ec66                	sd	s9,24(sp)
    800028de:	e86a                	sd	s10,16(sp)
    800028e0:	e46e                	sd	s11,8(sp)
    800028e2:	1880                	addi	s0,sp,112
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800028e4:	00005517          	auipc	a0,0x5
    800028e8:	7e450513          	addi	a0,a0,2020 # 800080c8 <digits+0x88>
    800028ec:	ffffe097          	auipc	ra,0xffffe
    800028f0:	c9c080e7          	jalr	-868(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028f4:	0000f917          	auipc	s2,0xf
    800028f8:	f3490913          	addi	s2,s2,-204 # 80011828 <proc+0x158>
    800028fc:	00015a17          	auipc	s4,0x15
    80002900:	f2ca0a13          	addi	s4,s4,-212 # 80017828 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002904:	4c95                	li	s9,5
      state = states[p->state];
    else
      state = "???";
    // printf("%d %s %s", p->pid, state, p->name);
    printf("pid=%d ", p->pid);
    80002906:	00006c17          	auipc	s8,0x6
    8000290a:	992c0c13          	addi	s8,s8,-1646 # 80008298 <digits+0x258>
    printf("ppid=%d ", p->parent->pid);
    }
    else{
      printf("ppid=-1 ");
    }
    printf("state=%s ", state);
    8000290e:	00006b97          	auipc	s7,0x6
    80002912:	9b2b8b93          	addi	s7,s7,-1614 # 800082c0 <digits+0x280>
    printf("cmd=%s ", p->name);
    80002916:	00006b17          	auipc	s6,0x6
    8000291a:	9bab0b13          	addi	s6,s6,-1606 # 800082d0 <digits+0x290>
    printf("ctime=%d ", p->ctime);
    8000291e:	00006a97          	auipc	s5,0x6
    80002922:	9baa8a93          	addi	s5,s5,-1606 # 800082d8 <digits+0x298>
    }
    else{
      uint xticks;

      acquire(&tickslock);
      xticks = ticks;
    80002926:	00006d97          	auipc	s11,0x6
    8000292a:	70ad8d93          	addi	s11,s11,1802 # 80009030 <ticks>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000292e:	00006d17          	auipc	s10,0x6
    80002932:	a3ad0d13          	addi	s10,s10,-1478 # 80008368 <states.1767>
    80002936:	a055                	j	800029da <ps+0x114>
    printf("pid=%d ", p->pid);
    80002938:	ed84a583          	lw	a1,-296(s1)
    8000293c:	8562                	mv	a0,s8
    8000293e:	ffffe097          	auipc	ra,0xffffe
    80002942:	c4a080e7          	jalr	-950(ra) # 80000588 <printf>
    if(p->parent!=0){
    80002946:	ee04b783          	ld	a5,-288(s1)
    8000294a:	cfdd                	beqz	a5,80002a08 <ps+0x142>
    printf("ppid=%d ", p->parent->pid);
    8000294c:	5b8c                	lw	a1,48(a5)
    8000294e:	00006517          	auipc	a0,0x6
    80002952:	95250513          	addi	a0,a0,-1710 # 800082a0 <digits+0x260>
    80002956:	ffffe097          	auipc	ra,0xffffe
    8000295a:	c32080e7          	jalr	-974(ra) # 80000588 <printf>
    printf("state=%s ", state);
    8000295e:	85ce                	mv	a1,s3
    80002960:	855e                	mv	a0,s7
    80002962:	ffffe097          	auipc	ra,0xffffe
    80002966:	c26080e7          	jalr	-986(ra) # 80000588 <printf>
    printf("cmd=%s ", p->name);
    8000296a:	85a6                	mv	a1,s1
    8000296c:	855a                	mv	a0,s6
    8000296e:	ffffe097          	auipc	ra,0xffffe
    80002972:	c1a080e7          	jalr	-998(ra) # 80000588 <printf>
    printf("ctime=%d ", p->ctime);
    80002976:	688c                	ld	a1,16(s1)
    80002978:	8556                	mv	a0,s5
    8000297a:	ffffe097          	auipc	ra,0xffffe
    8000297e:	c0e080e7          	jalr	-1010(ra) # 80000588 <printf>
    printf("stime=%d ", p->stime);
    80002982:	6c8c                	ld	a1,24(s1)
    80002984:	00006517          	auipc	a0,0x6
    80002988:	96450513          	addi	a0,a0,-1692 # 800082e8 <digits+0x2a8>
    8000298c:	ffffe097          	auipc	ra,0xffffe
    80002990:	bfc080e7          	jalr	-1028(ra) # 80000588 <printf>
    if(p->stime!=p->etime)
    80002994:	6c98                	ld	a4,24(s1)
    80002996:	709c                	ld	a5,32(s1)
    80002998:	08f70163          	beq	a4,a5,80002a1a <ps+0x154>
    printf("etime=%d ", p->name);
    8000299c:	85a6                	mv	a1,s1
    8000299e:	00006517          	auipc	a0,0x6
    800029a2:	95a50513          	addi	a0,a0,-1702 # 800082f8 <digits+0x2b8>
    800029a6:	ffffe097          	auipc	ra,0xffffe
    800029aa:	be2080e7          	jalr	-1054(ra) # 80000588 <printf>
     release(&tickslock);
      printf("etime=%d ", xticks - p->stime);
    }
    printf("size=%p ", p->sz);
    800029ae:	ef04b583          	ld	a1,-272(s1)
    800029b2:	00006517          	auipc	a0,0x6
    800029b6:	95650513          	addi	a0,a0,-1706 # 80008308 <digits+0x2c8>
    800029ba:	ffffe097          	auipc	ra,0xffffe
    800029be:	bce080e7          	jalr	-1074(ra) # 80000588 <printf>
    printf("\n");
    800029c2:	00005517          	auipc	a0,0x5
    800029c6:	70650513          	addi	a0,a0,1798 # 800080c8 <digits+0x88>
    800029ca:	ffffe097          	auipc	ra,0xffffe
    800029ce:	bbe080e7          	jalr	-1090(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800029d2:	18090913          	addi	s2,s2,384
    800029d6:	09490363          	beq	s2,s4,80002a5c <ps+0x196>
    if(p->state == UNUSED)
    800029da:	84ca                	mv	s1,s2
    800029dc:	ec092783          	lw	a5,-320(s2)
    800029e0:	dbed                	beqz	a5,800029d2 <ps+0x10c>
      state = "???";
    800029e2:	00006997          	auipc	s3,0x6
    800029e6:	89e98993          	addi	s3,s3,-1890 # 80008280 <digits+0x240>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029ea:	f4fce7e3          	bltu	s9,a5,80002938 <ps+0x72>
    800029ee:	1782                	slli	a5,a5,0x20
    800029f0:	9381                	srli	a5,a5,0x20
    800029f2:	078e                	slli	a5,a5,0x3
    800029f4:	97ea                	add	a5,a5,s10
    800029f6:	0307b983          	ld	s3,48(a5)
    800029fa:	f2099fe3          	bnez	s3,80002938 <ps+0x72>
      state = "???";
    800029fe:	00006997          	auipc	s3,0x6
    80002a02:	88298993          	addi	s3,s3,-1918 # 80008280 <digits+0x240>
    80002a06:	bf0d                	j	80002938 <ps+0x72>
      printf("ppid=-1 ");
    80002a08:	00006517          	auipc	a0,0x6
    80002a0c:	8a850513          	addi	a0,a0,-1880 # 800082b0 <digits+0x270>
    80002a10:	ffffe097          	auipc	ra,0xffffe
    80002a14:	b78080e7          	jalr	-1160(ra) # 80000588 <printf>
    80002a18:	b799                	j	8000295e <ps+0x98>
      acquire(&tickslock);
    80002a1a:	00015517          	auipc	a0,0x15
    80002a1e:	cb650513          	addi	a0,a0,-842 # 800176d0 <tickslock>
    80002a22:	ffffe097          	auipc	ra,0xffffe
    80002a26:	1c2080e7          	jalr	450(ra) # 80000be4 <acquire>
      xticks = ticks;
    80002a2a:	000da983          	lw	s3,0(s11)
     release(&tickslock);
    80002a2e:	00015517          	auipc	a0,0x15
    80002a32:	ca250513          	addi	a0,a0,-862 # 800176d0 <tickslock>
    80002a36:	ffffe097          	auipc	ra,0xffffe
    80002a3a:	262080e7          	jalr	610(ra) # 80000c98 <release>
      printf("etime=%d ", xticks - p->stime);
    80002a3e:	1982                	slli	s3,s3,0x20
    80002a40:	0209d993          	srli	s3,s3,0x20
    80002a44:	6c8c                	ld	a1,24(s1)
    80002a46:	40b985b3          	sub	a1,s3,a1
    80002a4a:	00006517          	auipc	a0,0x6
    80002a4e:	8ae50513          	addi	a0,a0,-1874 # 800082f8 <digits+0x2b8>
    80002a52:	ffffe097          	auipc	ra,0xffffe
    80002a56:	b36080e7          	jalr	-1226(ra) # 80000588 <printf>
    80002a5a:	bf91                	j	800029ae <ps+0xe8>
  }
  return 0;
}
    80002a5c:	4501                	li	a0,0
    80002a5e:	70a6                	ld	ra,104(sp)
    80002a60:	7406                	ld	s0,96(sp)
    80002a62:	64e6                	ld	s1,88(sp)
    80002a64:	6946                	ld	s2,80(sp)
    80002a66:	69a6                	ld	s3,72(sp)
    80002a68:	6a06                	ld	s4,64(sp)
    80002a6a:	7ae2                	ld	s5,56(sp)
    80002a6c:	7b42                	ld	s6,48(sp)
    80002a6e:	7ba2                	ld	s7,40(sp)
    80002a70:	7c02                	ld	s8,32(sp)
    80002a72:	6ce2                	ld	s9,24(sp)
    80002a74:	6d42                	ld	s10,16(sp)
    80002a76:	6da2                	ld	s11,8(sp)
    80002a78:	6165                	addi	sp,sp,112
    80002a7a:	8082                	ret

0000000080002a7c <pinfo>:

//Implementing procstat
int 
pinfo(int pid, uint64 pst){
    80002a7c:	7159                	addi	sp,sp,-112
    80002a7e:	f486                	sd	ra,104(sp)
    80002a80:	f0a2                	sd	s0,96(sp)
    80002a82:	eca6                	sd	s1,88(sp)
    80002a84:	e8ca                	sd	s2,80(sp)
    80002a86:	e4ce                	sd	s3,72(sp)
    80002a88:	e0d2                	sd	s4,64(sp)
    80002a8a:	fc56                	sd	s5,56(sp)
    80002a8c:	f85a                	sd	s6,48(sp)
    80002a8e:	f45e                	sd	s7,40(sp)
    80002a90:	f062                	sd	s8,32(sp)
    80002a92:	ec66                	sd	s9,24(sp)
    80002a94:	e86a                	sd	s10,16(sp)
    80002a96:	e46e                	sd	s11,8(sp)
    80002a98:	1880                	addi	s0,sp,112
    80002a9a:	8a2a                	mv	s4,a0
    80002a9c:	8b2e                	mv	s6,a1
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  

  struct procstat *pstat = (struct procstat*) kalloc();
    80002a9e:	ffffe097          	auipc	ra,0xffffe
    80002aa2:	056080e7          	jalr	86(ra) # 80000af4 <kalloc>
    80002aa6:	89aa                	mv	s3,a0
  //  ps();
  struct proc *p;
  char *state;
  int pexists = 0;

  if(pid == -1){
    80002aa8:	57fd                	li	a5,-1
    80002aaa:	02fa0963          	beq	s4,a5,80002adc <pinfo+0x60>
    pid = myproc()->pid;
  }
  for(p = proc; p < &proc[NPROC]; p++){
    80002aae:	0000f497          	auipc	s1,0xf
    80002ab2:	d8a48493          	addi	s1,s1,-630 # 80011838 <proc+0x168>
    80002ab6:	00015a97          	auipc	s5,0x15
    80002aba:	d82a8a93          	addi	s5,s5,-638 # 80017838 <bcache+0x150>
  int pexists = 0;
    80002abe:	4701                	li	a4,0
    if(p->pid == pid){
    pexists = 1;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002ac0:	4c15                	li	s8,5
      state = states[p->state];
    else
      state = "???";
    80002ac2:	00005b97          	auipc	s7,0x5
    80002ac6:	7beb8b93          	addi	s7,s7,1982 # 80008280 <digits+0x240>
    pstat->etime = p->etime;
    }
    else{
      uint xticks;

      acquire(&tickslock);
    80002aca:	00015d97          	auipc	s11,0x15
    80002ace:	c06d8d93          	addi	s11,s11,-1018 # 800176d0 <tickslock>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002ad2:	00006d17          	auipc	s10,0x6
    80002ad6:	896d0d13          	addi	s10,s10,-1898 # 80008368 <states.1767>
    80002ada:	a879                	j	80002b78 <pinfo+0xfc>
    pid = myproc()->pid;
    80002adc:	fffff097          	auipc	ra,0xfffff
    80002ae0:	ed4080e7          	jalr	-300(ra) # 800019b0 <myproc>
    80002ae4:	03052a03          	lw	s4,48(a0)
    80002ae8:	b7d9                	j	80002aae <pinfo+0x32>
    pstat->pid = p->pid;
    80002aea:	00f9a023          	sw	a5,0(s3)
    for(int i=0;i<8;++i){
    80002aee:	87b2                	mv	a5,a2
    80002af0:	00898713          	addi	a4,s3,8
    80002af4:	0621                	addi	a2,a2,8
      pstat->state[i] = state[i];   
    80002af6:	0007c683          	lbu	a3,0(a5)
    80002afa:	00d70023          	sb	a3,0(a4)
    for(int i=0;i<8;++i){
    80002afe:	0785                	addi	a5,a5,1
    80002b00:	0705                	addi	a4,a4,1
    80002b02:	fec79ae3          	bne	a5,a2,80002af6 <pinfo+0x7a>
    pstat->ppid = p->parent->pid;
    80002b06:	ed093783          	ld	a5,-304(s2)
    80002b0a:	5b9c                	lw	a5,48(a5)
    80002b0c:	00f9a223          	sw	a5,4(s3)
    for(int i=0;i<16;++i){
    80002b10:	ff048793          	addi	a5,s1,-16
    80002b14:	01098713          	addi	a4,s3,16
      pstat->command[i] = p->name[i];   
    80002b18:	0007c683          	lbu	a3,0(a5)
    80002b1c:	00d70023          	sb	a3,0(a4)
    for(int i=0;i<16;++i){
    80002b20:	0785                	addi	a5,a5,1
    80002b22:	0705                	addi	a4,a4,1
    80002b24:	fe979ae3          	bne	a5,s1,80002b18 <pinfo+0x9c>
    pstat->ctime = p->ctime;
    80002b28:	00093783          	ld	a5,0(s2)
    80002b2c:	02f9a023          	sw	a5,32(s3)
    pstat->stime = p->stime;
    80002b30:	00893783          	ld	a5,8(s2)
    80002b34:	02f9a223          	sw	a5,36(s3)
    if(p->stime!=p->etime)
    80002b38:	01093783          	ld	a5,16(s2)
    80002b3c:	00893703          	ld	a4,8(s2)
    80002b40:	04f70e63          	beq	a4,a5,80002b9c <pinfo+0x120>
    pstat->etime = p->etime;
    80002b44:	02f9a423          	sw	a5,40(s3)
     release(&tickslock);
      // printf("etime=%l", xticks - p->stime);
      pstat->etime = xticks - p->stime;
    }
    // printf("size=%l", p->sz);
    pstat->size = p->sz;
    80002b48:	ee093783          	ld	a5,-288(s2)
    80002b4c:	02f9b823          	sd	a5,48(s3)
    // printf("size=%p ", pstat->size);
    // printf("\n");
///////////////////////////////////////////////////////////////////////////////////////
    // printf("\n");
    // printf("%s\n", pstat->state);
    if(copyout(myproc()->pagetable, pst, (char*)(pstat), sizeof(*pstat)) < 0){
    80002b50:	fffff097          	auipc	ra,0xfffff
    80002b54:	e60080e7          	jalr	-416(ra) # 800019b0 <myproc>
    80002b58:	03800693          	li	a3,56
    80002b5c:	864e                	mv	a2,s3
    80002b5e:	85da                	mv	a1,s6
    80002b60:	6928                	ld	a0,80(a0)
    80002b62:	fffff097          	auipc	ra,0xfffff
    80002b66:	b10080e7          	jalr	-1264(ra) # 80001672 <copyout>
    80002b6a:	08054b63          	bltz	a0,80002c00 <pinfo+0x184>
    pexists = 1;
    80002b6e:	4705                	li	a4,1
  for(p = proc; p < &proc[NPROC]; p++){
    80002b70:	18048493          	addi	s1,s1,384
    80002b74:	05548b63          	beq	s1,s5,80002bca <pinfo+0x14e>
    if(p->pid == pid){
    80002b78:	8926                	mv	s2,s1
    80002b7a:	ec84a783          	lw	a5,-312(s1)
    80002b7e:	ff4799e3          	bne	a5,s4,80002b70 <pinfo+0xf4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b82:	eb04a703          	lw	a4,-336(s1)
      state = "???";
    80002b86:	865e                	mv	a2,s7
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b88:	f6ec61e3          	bltu	s8,a4,80002aea <pinfo+0x6e>
    80002b8c:	1702                	slli	a4,a4,0x20
    80002b8e:	9301                	srli	a4,a4,0x20
    80002b90:	070e                	slli	a4,a4,0x3
    80002b92:	976a                	add	a4,a4,s10
    80002b94:	7330                	ld	a2,96(a4)
    80002b96:	fa31                	bnez	a2,80002aea <pinfo+0x6e>
      state = "???";
    80002b98:	865e                	mv	a2,s7
    80002b9a:	bf81                	j	80002aea <pinfo+0x6e>
      acquire(&tickslock);
    80002b9c:	856e                	mv	a0,s11
    80002b9e:	ffffe097          	auipc	ra,0xffffe
    80002ba2:	046080e7          	jalr	70(ra) # 80000be4 <acquire>
      xticks = ticks;
    80002ba6:	00006797          	auipc	a5,0x6
    80002baa:	48a78793          	addi	a5,a5,1162 # 80009030 <ticks>
    80002bae:	0007ac83          	lw	s9,0(a5)
     release(&tickslock);
    80002bb2:	856e                	mv	a0,s11
    80002bb4:	ffffe097          	auipc	ra,0xffffe
    80002bb8:	0e4080e7          	jalr	228(ra) # 80000c98 <release>
      pstat->etime = xticks - p->stime;
    80002bbc:	00893783          	ld	a5,8(s2)
    80002bc0:	40fc8cbb          	subw	s9,s9,a5
    80002bc4:	0399a423          	sw	s9,40(s3)
    80002bc8:	b741                	j	80002b48 <pinfo+0xcc>
  if(pexists == 0){
    printf("Process doesn't exist");
    return -1;
  }

  return 0;
    80002bca:	4501                	li	a0,0
  if(pexists == 0){
    80002bcc:	c305                	beqz	a4,80002bec <pinfo+0x170>
}
    80002bce:	70a6                	ld	ra,104(sp)
    80002bd0:	7406                	ld	s0,96(sp)
    80002bd2:	64e6                	ld	s1,88(sp)
    80002bd4:	6946                	ld	s2,80(sp)
    80002bd6:	69a6                	ld	s3,72(sp)
    80002bd8:	6a06                	ld	s4,64(sp)
    80002bda:	7ae2                	ld	s5,56(sp)
    80002bdc:	7b42                	ld	s6,48(sp)
    80002bde:	7ba2                	ld	s7,40(sp)
    80002be0:	7c02                	ld	s8,32(sp)
    80002be2:	6ce2                	ld	s9,24(sp)
    80002be4:	6d42                	ld	s10,16(sp)
    80002be6:	6da2                	ld	s11,8(sp)
    80002be8:	6165                	addi	sp,sp,112
    80002bea:	8082                	ret
    printf("Process doesn't exist");
    80002bec:	00005517          	auipc	a0,0x5
    80002bf0:	72c50513          	addi	a0,a0,1836 # 80008318 <digits+0x2d8>
    80002bf4:	ffffe097          	auipc	ra,0xffffe
    80002bf8:	994080e7          	jalr	-1644(ra) # 80000588 <printf>
    return -1;
    80002bfc:	557d                	li	a0,-1
    80002bfe:	bfc1                	j	80002bce <pinfo+0x152>
      return -1;
    80002c00:	557d                	li	a0,-1
    80002c02:	b7f1                	j	80002bce <pinfo+0x152>

0000000080002c04 <swtch>:
    80002c04:	00153023          	sd	ra,0(a0)
    80002c08:	00253423          	sd	sp,8(a0)
    80002c0c:	e900                	sd	s0,16(a0)
    80002c0e:	ed04                	sd	s1,24(a0)
    80002c10:	03253023          	sd	s2,32(a0)
    80002c14:	03353423          	sd	s3,40(a0)
    80002c18:	03453823          	sd	s4,48(a0)
    80002c1c:	03553c23          	sd	s5,56(a0)
    80002c20:	05653023          	sd	s6,64(a0)
    80002c24:	05753423          	sd	s7,72(a0)
    80002c28:	05853823          	sd	s8,80(a0)
    80002c2c:	05953c23          	sd	s9,88(a0)
    80002c30:	07a53023          	sd	s10,96(a0)
    80002c34:	07b53423          	sd	s11,104(a0)
    80002c38:	0005b083          	ld	ra,0(a1)
    80002c3c:	0085b103          	ld	sp,8(a1)
    80002c40:	6980                	ld	s0,16(a1)
    80002c42:	6d84                	ld	s1,24(a1)
    80002c44:	0205b903          	ld	s2,32(a1)
    80002c48:	0285b983          	ld	s3,40(a1)
    80002c4c:	0305ba03          	ld	s4,48(a1)
    80002c50:	0385ba83          	ld	s5,56(a1)
    80002c54:	0405bb03          	ld	s6,64(a1)
    80002c58:	0485bb83          	ld	s7,72(a1)
    80002c5c:	0505bc03          	ld	s8,80(a1)
    80002c60:	0585bc83          	ld	s9,88(a1)
    80002c64:	0605bd03          	ld	s10,96(a1)
    80002c68:	0685bd83          	ld	s11,104(a1)
    80002c6c:	8082                	ret

0000000080002c6e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002c6e:	1141                	addi	sp,sp,-16
    80002c70:	e406                	sd	ra,8(sp)
    80002c72:	e022                	sd	s0,0(sp)
    80002c74:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002c76:	00005597          	auipc	a1,0x5
    80002c7a:	78258593          	addi	a1,a1,1922 # 800083f8 <states.1789+0x30>
    80002c7e:	00015517          	auipc	a0,0x15
    80002c82:	a5250513          	addi	a0,a0,-1454 # 800176d0 <tickslock>
    80002c86:	ffffe097          	auipc	ra,0xffffe
    80002c8a:	ece080e7          	jalr	-306(ra) # 80000b54 <initlock>
}
    80002c8e:	60a2                	ld	ra,8(sp)
    80002c90:	6402                	ld	s0,0(sp)
    80002c92:	0141                	addi	sp,sp,16
    80002c94:	8082                	ret

0000000080002c96 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002c96:	1141                	addi	sp,sp,-16
    80002c98:	e422                	sd	s0,8(sp)
    80002c9a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c9c:	00003797          	auipc	a5,0x3
    80002ca0:	5c478793          	addi	a5,a5,1476 # 80006260 <kernelvec>
    80002ca4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002ca8:	6422                	ld	s0,8(sp)
    80002caa:	0141                	addi	sp,sp,16
    80002cac:	8082                	ret

0000000080002cae <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002cae:	1141                	addi	sp,sp,-16
    80002cb0:	e406                	sd	ra,8(sp)
    80002cb2:	e022                	sd	s0,0(sp)
    80002cb4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002cb6:	fffff097          	auipc	ra,0xfffff
    80002cba:	cfa080e7          	jalr	-774(ra) # 800019b0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cbe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002cc2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cc4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002cc8:	00004617          	auipc	a2,0x4
    80002ccc:	33860613          	addi	a2,a2,824 # 80007000 <_trampoline>
    80002cd0:	00004697          	auipc	a3,0x4
    80002cd4:	33068693          	addi	a3,a3,816 # 80007000 <_trampoline>
    80002cd8:	8e91                	sub	a3,a3,a2
    80002cda:	040007b7          	lui	a5,0x4000
    80002cde:	17fd                	addi	a5,a5,-1
    80002ce0:	07b2                	slli	a5,a5,0xc
    80002ce2:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ce4:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ce8:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002cea:	180026f3          	csrr	a3,satp
    80002cee:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002cf0:	6d38                	ld	a4,88(a0)
    80002cf2:	6134                	ld	a3,64(a0)
    80002cf4:	6585                	lui	a1,0x1
    80002cf6:	96ae                	add	a3,a3,a1
    80002cf8:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002cfa:	6d38                	ld	a4,88(a0)
    80002cfc:	00000697          	auipc	a3,0x0
    80002d00:	13868693          	addi	a3,a3,312 # 80002e34 <usertrap>
    80002d04:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002d06:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002d08:	8692                	mv	a3,tp
    80002d0a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d0c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002d10:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002d14:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d18:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002d1c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d1e:	6f18                	ld	a4,24(a4)
    80002d20:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002d24:	692c                	ld	a1,80(a0)
    80002d26:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002d28:	00004717          	auipc	a4,0x4
    80002d2c:	36870713          	addi	a4,a4,872 # 80007090 <userret>
    80002d30:	8f11                	sub	a4,a4,a2
    80002d32:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002d34:	577d                	li	a4,-1
    80002d36:	177e                	slli	a4,a4,0x3f
    80002d38:	8dd9                	or	a1,a1,a4
    80002d3a:	02000537          	lui	a0,0x2000
    80002d3e:	157d                	addi	a0,a0,-1
    80002d40:	0536                	slli	a0,a0,0xd
    80002d42:	9782                	jalr	a5
}
    80002d44:	60a2                	ld	ra,8(sp)
    80002d46:	6402                	ld	s0,0(sp)
    80002d48:	0141                	addi	sp,sp,16
    80002d4a:	8082                	ret

0000000080002d4c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002d4c:	1101                	addi	sp,sp,-32
    80002d4e:	ec06                	sd	ra,24(sp)
    80002d50:	e822                	sd	s0,16(sp)
    80002d52:	e426                	sd	s1,8(sp)
    80002d54:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002d56:	00015497          	auipc	s1,0x15
    80002d5a:	97a48493          	addi	s1,s1,-1670 # 800176d0 <tickslock>
    80002d5e:	8526                	mv	a0,s1
    80002d60:	ffffe097          	auipc	ra,0xffffe
    80002d64:	e84080e7          	jalr	-380(ra) # 80000be4 <acquire>
  ticks++;
    80002d68:	00006517          	auipc	a0,0x6
    80002d6c:	2c850513          	addi	a0,a0,712 # 80009030 <ticks>
    80002d70:	411c                	lw	a5,0(a0)
    80002d72:	2785                	addiw	a5,a5,1
    80002d74:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002d76:	fffff097          	auipc	ra,0xfffff
    80002d7a:	7ae080e7          	jalr	1966(ra) # 80002524 <wakeup>
  release(&tickslock);
    80002d7e:	8526                	mv	a0,s1
    80002d80:	ffffe097          	auipc	ra,0xffffe
    80002d84:	f18080e7          	jalr	-232(ra) # 80000c98 <release>
}
    80002d88:	60e2                	ld	ra,24(sp)
    80002d8a:	6442                	ld	s0,16(sp)
    80002d8c:	64a2                	ld	s1,8(sp)
    80002d8e:	6105                	addi	sp,sp,32
    80002d90:	8082                	ret

0000000080002d92 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002d92:	1101                	addi	sp,sp,-32
    80002d94:	ec06                	sd	ra,24(sp)
    80002d96:	e822                	sd	s0,16(sp)
    80002d98:	e426                	sd	s1,8(sp)
    80002d9a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d9c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002da0:	00074d63          	bltz	a4,80002dba <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002da4:	57fd                	li	a5,-1
    80002da6:	17fe                	slli	a5,a5,0x3f
    80002da8:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002daa:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002dac:	06f70363          	beq	a4,a5,80002e12 <devintr+0x80>
  }
}
    80002db0:	60e2                	ld	ra,24(sp)
    80002db2:	6442                	ld	s0,16(sp)
    80002db4:	64a2                	ld	s1,8(sp)
    80002db6:	6105                	addi	sp,sp,32
    80002db8:	8082                	ret
     (scause & 0xff) == 9){
    80002dba:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002dbe:	46a5                	li	a3,9
    80002dc0:	fed792e3          	bne	a5,a3,80002da4 <devintr+0x12>
    int irq = plic_claim();
    80002dc4:	00003097          	auipc	ra,0x3
    80002dc8:	5a4080e7          	jalr	1444(ra) # 80006368 <plic_claim>
    80002dcc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002dce:	47a9                	li	a5,10
    80002dd0:	02f50763          	beq	a0,a5,80002dfe <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002dd4:	4785                	li	a5,1
    80002dd6:	02f50963          	beq	a0,a5,80002e08 <devintr+0x76>
    return 1;
    80002dda:	4505                	li	a0,1
    } else if(irq){
    80002ddc:	d8f1                	beqz	s1,80002db0 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002dde:	85a6                	mv	a1,s1
    80002de0:	00005517          	auipc	a0,0x5
    80002de4:	62050513          	addi	a0,a0,1568 # 80008400 <states.1789+0x38>
    80002de8:	ffffd097          	auipc	ra,0xffffd
    80002dec:	7a0080e7          	jalr	1952(ra) # 80000588 <printf>
      plic_complete(irq);
    80002df0:	8526                	mv	a0,s1
    80002df2:	00003097          	auipc	ra,0x3
    80002df6:	59a080e7          	jalr	1434(ra) # 8000638c <plic_complete>
    return 1;
    80002dfa:	4505                	li	a0,1
    80002dfc:	bf55                	j	80002db0 <devintr+0x1e>
      uartintr();
    80002dfe:	ffffe097          	auipc	ra,0xffffe
    80002e02:	baa080e7          	jalr	-1110(ra) # 800009a8 <uartintr>
    80002e06:	b7ed                	j	80002df0 <devintr+0x5e>
      virtio_disk_intr();
    80002e08:	00004097          	auipc	ra,0x4
    80002e0c:	a64080e7          	jalr	-1436(ra) # 8000686c <virtio_disk_intr>
    80002e10:	b7c5                	j	80002df0 <devintr+0x5e>
    if(cpuid() == 0){
    80002e12:	fffff097          	auipc	ra,0xfffff
    80002e16:	b72080e7          	jalr	-1166(ra) # 80001984 <cpuid>
    80002e1a:	c901                	beqz	a0,80002e2a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002e1c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002e20:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002e22:	14479073          	csrw	sip,a5
    return 2;
    80002e26:	4509                	li	a0,2
    80002e28:	b761                	j	80002db0 <devintr+0x1e>
      clockintr();
    80002e2a:	00000097          	auipc	ra,0x0
    80002e2e:	f22080e7          	jalr	-222(ra) # 80002d4c <clockintr>
    80002e32:	b7ed                	j	80002e1c <devintr+0x8a>

0000000080002e34 <usertrap>:
{
    80002e34:	1101                	addi	sp,sp,-32
    80002e36:	ec06                	sd	ra,24(sp)
    80002e38:	e822                	sd	s0,16(sp)
    80002e3a:	e426                	sd	s1,8(sp)
    80002e3c:	e04a                	sd	s2,0(sp)
    80002e3e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e40:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002e44:	1007f793          	andi	a5,a5,256
    80002e48:	e3ad                	bnez	a5,80002eaa <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e4a:	00003797          	auipc	a5,0x3
    80002e4e:	41678793          	addi	a5,a5,1046 # 80006260 <kernelvec>
    80002e52:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002e56:	fffff097          	auipc	ra,0xfffff
    80002e5a:	b5a080e7          	jalr	-1190(ra) # 800019b0 <myproc>
    80002e5e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002e60:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e62:	14102773          	csrr	a4,sepc
    80002e66:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e68:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002e6c:	47a1                	li	a5,8
    80002e6e:	04f71c63          	bne	a4,a5,80002ec6 <usertrap+0x92>
    if(p->killed)
    80002e72:	551c                	lw	a5,40(a0)
    80002e74:	e3b9                	bnez	a5,80002eba <usertrap+0x86>
    p->trapframe->epc += 4;
    80002e76:	6cb8                	ld	a4,88(s1)
    80002e78:	6f1c                	ld	a5,24(a4)
    80002e7a:	0791                	addi	a5,a5,4
    80002e7c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e7e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002e82:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e86:	10079073          	csrw	sstatus,a5
    syscall();
    80002e8a:	00000097          	auipc	ra,0x0
    80002e8e:	2e0080e7          	jalr	736(ra) # 8000316a <syscall>
  if(p->killed)
    80002e92:	549c                	lw	a5,40(s1)
    80002e94:	ebc1                	bnez	a5,80002f24 <usertrap+0xf0>
  usertrapret();
    80002e96:	00000097          	auipc	ra,0x0
    80002e9a:	e18080e7          	jalr	-488(ra) # 80002cae <usertrapret>
}
    80002e9e:	60e2                	ld	ra,24(sp)
    80002ea0:	6442                	ld	s0,16(sp)
    80002ea2:	64a2                	ld	s1,8(sp)
    80002ea4:	6902                	ld	s2,0(sp)
    80002ea6:	6105                	addi	sp,sp,32
    80002ea8:	8082                	ret
    panic("usertrap: not from user mode");
    80002eaa:	00005517          	auipc	a0,0x5
    80002eae:	57650513          	addi	a0,a0,1398 # 80008420 <states.1789+0x58>
    80002eb2:	ffffd097          	auipc	ra,0xffffd
    80002eb6:	68c080e7          	jalr	1676(ra) # 8000053e <panic>
      exit(-1);
    80002eba:	557d                	li	a0,-1
    80002ebc:	fffff097          	auipc	ra,0xfffff
    80002ec0:	738080e7          	jalr	1848(ra) # 800025f4 <exit>
    80002ec4:	bf4d                	j	80002e76 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002ec6:	00000097          	auipc	ra,0x0
    80002eca:	ecc080e7          	jalr	-308(ra) # 80002d92 <devintr>
    80002ece:	892a                	mv	s2,a0
    80002ed0:	c501                	beqz	a0,80002ed8 <usertrap+0xa4>
  if(p->killed)
    80002ed2:	549c                	lw	a5,40(s1)
    80002ed4:	c3a1                	beqz	a5,80002f14 <usertrap+0xe0>
    80002ed6:	a815                	j	80002f0a <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ed8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002edc:	5890                	lw	a2,48(s1)
    80002ede:	00005517          	auipc	a0,0x5
    80002ee2:	56250513          	addi	a0,a0,1378 # 80008440 <states.1789+0x78>
    80002ee6:	ffffd097          	auipc	ra,0xffffd
    80002eea:	6a2080e7          	jalr	1698(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002eee:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ef2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ef6:	00005517          	auipc	a0,0x5
    80002efa:	57a50513          	addi	a0,a0,1402 # 80008470 <states.1789+0xa8>
    80002efe:	ffffd097          	auipc	ra,0xffffd
    80002f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    p->killed = 1;
    80002f06:	4785                	li	a5,1
    80002f08:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002f0a:	557d                	li	a0,-1
    80002f0c:	fffff097          	auipc	ra,0xfffff
    80002f10:	6e8080e7          	jalr	1768(ra) # 800025f4 <exit>
  if(which_dev == 2)
    80002f14:	4789                	li	a5,2
    80002f16:	f8f910e3          	bne	s2,a5,80002e96 <usertrap+0x62>
    yield();
    80002f1a:	fffff097          	auipc	ra,0xfffff
    80002f1e:	30e080e7          	jalr	782(ra) # 80002228 <yield>
    80002f22:	bf95                	j	80002e96 <usertrap+0x62>
  int which_dev = 0;
    80002f24:	4901                	li	s2,0
    80002f26:	b7d5                	j	80002f0a <usertrap+0xd6>

0000000080002f28 <kerneltrap>:
{
    80002f28:	7179                	addi	sp,sp,-48
    80002f2a:	f406                	sd	ra,40(sp)
    80002f2c:	f022                	sd	s0,32(sp)
    80002f2e:	ec26                	sd	s1,24(sp)
    80002f30:	e84a                	sd	s2,16(sp)
    80002f32:	e44e                	sd	s3,8(sp)
    80002f34:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f36:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f3a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f3e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002f42:	1004f793          	andi	a5,s1,256
    80002f46:	cb85                	beqz	a5,80002f76 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f48:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002f4c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002f4e:	ef85                	bnez	a5,80002f86 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002f50:	00000097          	auipc	ra,0x0
    80002f54:	e42080e7          	jalr	-446(ra) # 80002d92 <devintr>
    80002f58:	cd1d                	beqz	a0,80002f96 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f5a:	4789                	li	a5,2
    80002f5c:	06f50a63          	beq	a0,a5,80002fd0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f60:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f64:	10049073          	csrw	sstatus,s1
}
    80002f68:	70a2                	ld	ra,40(sp)
    80002f6a:	7402                	ld	s0,32(sp)
    80002f6c:	64e2                	ld	s1,24(sp)
    80002f6e:	6942                	ld	s2,16(sp)
    80002f70:	69a2                	ld	s3,8(sp)
    80002f72:	6145                	addi	sp,sp,48
    80002f74:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002f76:	00005517          	auipc	a0,0x5
    80002f7a:	51a50513          	addi	a0,a0,1306 # 80008490 <states.1789+0xc8>
    80002f7e:	ffffd097          	auipc	ra,0xffffd
    80002f82:	5c0080e7          	jalr	1472(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002f86:	00005517          	auipc	a0,0x5
    80002f8a:	53250513          	addi	a0,a0,1330 # 800084b8 <states.1789+0xf0>
    80002f8e:	ffffd097          	auipc	ra,0xffffd
    80002f92:	5b0080e7          	jalr	1456(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002f96:	85ce                	mv	a1,s3
    80002f98:	00005517          	auipc	a0,0x5
    80002f9c:	54050513          	addi	a0,a0,1344 # 800084d8 <states.1789+0x110>
    80002fa0:	ffffd097          	auipc	ra,0xffffd
    80002fa4:	5e8080e7          	jalr	1512(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fa8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002fac:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002fb0:	00005517          	auipc	a0,0x5
    80002fb4:	53850513          	addi	a0,a0,1336 # 800084e8 <states.1789+0x120>
    80002fb8:	ffffd097          	auipc	ra,0xffffd
    80002fbc:	5d0080e7          	jalr	1488(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002fc0:	00005517          	auipc	a0,0x5
    80002fc4:	54050513          	addi	a0,a0,1344 # 80008500 <states.1789+0x138>
    80002fc8:	ffffd097          	auipc	ra,0xffffd
    80002fcc:	576080e7          	jalr	1398(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002fd0:	fffff097          	auipc	ra,0xfffff
    80002fd4:	9e0080e7          	jalr	-1568(ra) # 800019b0 <myproc>
    80002fd8:	d541                	beqz	a0,80002f60 <kerneltrap+0x38>
    80002fda:	fffff097          	auipc	ra,0xfffff
    80002fde:	9d6080e7          	jalr	-1578(ra) # 800019b0 <myproc>
    80002fe2:	4d18                	lw	a4,24(a0)
    80002fe4:	4791                	li	a5,4
    80002fe6:	f6f71de3          	bne	a4,a5,80002f60 <kerneltrap+0x38>
    yield();
    80002fea:	fffff097          	auipc	ra,0xfffff
    80002fee:	23e080e7          	jalr	574(ra) # 80002228 <yield>
    80002ff2:	b7bd                	j	80002f60 <kerneltrap+0x38>

0000000080002ff4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ff4:	1101                	addi	sp,sp,-32
    80002ff6:	ec06                	sd	ra,24(sp)
    80002ff8:	e822                	sd	s0,16(sp)
    80002ffa:	e426                	sd	s1,8(sp)
    80002ffc:	1000                	addi	s0,sp,32
    80002ffe:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003000:	fffff097          	auipc	ra,0xfffff
    80003004:	9b0080e7          	jalr	-1616(ra) # 800019b0 <myproc>
  switch (n) {
    80003008:	4795                	li	a5,5
    8000300a:	0497e163          	bltu	a5,s1,8000304c <argraw+0x58>
    8000300e:	048a                	slli	s1,s1,0x2
    80003010:	00005717          	auipc	a4,0x5
    80003014:	52870713          	addi	a4,a4,1320 # 80008538 <states.1789+0x170>
    80003018:	94ba                	add	s1,s1,a4
    8000301a:	409c                	lw	a5,0(s1)
    8000301c:	97ba                	add	a5,a5,a4
    8000301e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003020:	6d3c                	ld	a5,88(a0)
    80003022:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003024:	60e2                	ld	ra,24(sp)
    80003026:	6442                	ld	s0,16(sp)
    80003028:	64a2                	ld	s1,8(sp)
    8000302a:	6105                	addi	sp,sp,32
    8000302c:	8082                	ret
    return p->trapframe->a1;
    8000302e:	6d3c                	ld	a5,88(a0)
    80003030:	7fa8                	ld	a0,120(a5)
    80003032:	bfcd                	j	80003024 <argraw+0x30>
    return p->trapframe->a2;
    80003034:	6d3c                	ld	a5,88(a0)
    80003036:	63c8                	ld	a0,128(a5)
    80003038:	b7f5                	j	80003024 <argraw+0x30>
    return p->trapframe->a3;
    8000303a:	6d3c                	ld	a5,88(a0)
    8000303c:	67c8                	ld	a0,136(a5)
    8000303e:	b7dd                	j	80003024 <argraw+0x30>
    return p->trapframe->a4;
    80003040:	6d3c                	ld	a5,88(a0)
    80003042:	6bc8                	ld	a0,144(a5)
    80003044:	b7c5                	j	80003024 <argraw+0x30>
    return p->trapframe->a5;
    80003046:	6d3c                	ld	a5,88(a0)
    80003048:	6fc8                	ld	a0,152(a5)
    8000304a:	bfe9                	j	80003024 <argraw+0x30>
  panic("argraw");
    8000304c:	00005517          	auipc	a0,0x5
    80003050:	4c450513          	addi	a0,a0,1220 # 80008510 <states.1789+0x148>
    80003054:	ffffd097          	auipc	ra,0xffffd
    80003058:	4ea080e7          	jalr	1258(ra) # 8000053e <panic>

000000008000305c <fetchaddr>:
{
    8000305c:	1101                	addi	sp,sp,-32
    8000305e:	ec06                	sd	ra,24(sp)
    80003060:	e822                	sd	s0,16(sp)
    80003062:	e426                	sd	s1,8(sp)
    80003064:	e04a                	sd	s2,0(sp)
    80003066:	1000                	addi	s0,sp,32
    80003068:	84aa                	mv	s1,a0
    8000306a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000306c:	fffff097          	auipc	ra,0xfffff
    80003070:	944080e7          	jalr	-1724(ra) # 800019b0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003074:	653c                	ld	a5,72(a0)
    80003076:	02f4f863          	bgeu	s1,a5,800030a6 <fetchaddr+0x4a>
    8000307a:	00848713          	addi	a4,s1,8
    8000307e:	02e7e663          	bltu	a5,a4,800030aa <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003082:	46a1                	li	a3,8
    80003084:	8626                	mv	a2,s1
    80003086:	85ca                	mv	a1,s2
    80003088:	6928                	ld	a0,80(a0)
    8000308a:	ffffe097          	auipc	ra,0xffffe
    8000308e:	674080e7          	jalr	1652(ra) # 800016fe <copyin>
    80003092:	00a03533          	snez	a0,a0
    80003096:	40a00533          	neg	a0,a0
}
    8000309a:	60e2                	ld	ra,24(sp)
    8000309c:	6442                	ld	s0,16(sp)
    8000309e:	64a2                	ld	s1,8(sp)
    800030a0:	6902                	ld	s2,0(sp)
    800030a2:	6105                	addi	sp,sp,32
    800030a4:	8082                	ret
    return -1;
    800030a6:	557d                	li	a0,-1
    800030a8:	bfcd                	j	8000309a <fetchaddr+0x3e>
    800030aa:	557d                	li	a0,-1
    800030ac:	b7fd                	j	8000309a <fetchaddr+0x3e>

00000000800030ae <fetchstr>:
{
    800030ae:	7179                	addi	sp,sp,-48
    800030b0:	f406                	sd	ra,40(sp)
    800030b2:	f022                	sd	s0,32(sp)
    800030b4:	ec26                	sd	s1,24(sp)
    800030b6:	e84a                	sd	s2,16(sp)
    800030b8:	e44e                	sd	s3,8(sp)
    800030ba:	1800                	addi	s0,sp,48
    800030bc:	892a                	mv	s2,a0
    800030be:	84ae                	mv	s1,a1
    800030c0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800030c2:	fffff097          	auipc	ra,0xfffff
    800030c6:	8ee080e7          	jalr	-1810(ra) # 800019b0 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800030ca:	86ce                	mv	a3,s3
    800030cc:	864a                	mv	a2,s2
    800030ce:	85a6                	mv	a1,s1
    800030d0:	6928                	ld	a0,80(a0)
    800030d2:	ffffe097          	auipc	ra,0xffffe
    800030d6:	6b8080e7          	jalr	1720(ra) # 8000178a <copyinstr>
  if(err < 0)
    800030da:	00054763          	bltz	a0,800030e8 <fetchstr+0x3a>
  return strlen(buf);
    800030de:	8526                	mv	a0,s1
    800030e0:	ffffe097          	auipc	ra,0xffffe
    800030e4:	d84080e7          	jalr	-636(ra) # 80000e64 <strlen>
}
    800030e8:	70a2                	ld	ra,40(sp)
    800030ea:	7402                	ld	s0,32(sp)
    800030ec:	64e2                	ld	s1,24(sp)
    800030ee:	6942                	ld	s2,16(sp)
    800030f0:	69a2                	ld	s3,8(sp)
    800030f2:	6145                	addi	sp,sp,48
    800030f4:	8082                	ret

00000000800030f6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800030f6:	1101                	addi	sp,sp,-32
    800030f8:	ec06                	sd	ra,24(sp)
    800030fa:	e822                	sd	s0,16(sp)
    800030fc:	e426                	sd	s1,8(sp)
    800030fe:	1000                	addi	s0,sp,32
    80003100:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003102:	00000097          	auipc	ra,0x0
    80003106:	ef2080e7          	jalr	-270(ra) # 80002ff4 <argraw>
    8000310a:	c088                	sw	a0,0(s1)
  return 0;
}
    8000310c:	4501                	li	a0,0
    8000310e:	60e2                	ld	ra,24(sp)
    80003110:	6442                	ld	s0,16(sp)
    80003112:	64a2                	ld	s1,8(sp)
    80003114:	6105                	addi	sp,sp,32
    80003116:	8082                	ret

0000000080003118 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003118:	1101                	addi	sp,sp,-32
    8000311a:	ec06                	sd	ra,24(sp)
    8000311c:	e822                	sd	s0,16(sp)
    8000311e:	e426                	sd	s1,8(sp)
    80003120:	1000                	addi	s0,sp,32
    80003122:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003124:	00000097          	auipc	ra,0x0
    80003128:	ed0080e7          	jalr	-304(ra) # 80002ff4 <argraw>
    8000312c:	e088                	sd	a0,0(s1)
  return 0;
}
    8000312e:	4501                	li	a0,0
    80003130:	60e2                	ld	ra,24(sp)
    80003132:	6442                	ld	s0,16(sp)
    80003134:	64a2                	ld	s1,8(sp)
    80003136:	6105                	addi	sp,sp,32
    80003138:	8082                	ret

000000008000313a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000313a:	1101                	addi	sp,sp,-32
    8000313c:	ec06                	sd	ra,24(sp)
    8000313e:	e822                	sd	s0,16(sp)
    80003140:	e426                	sd	s1,8(sp)
    80003142:	e04a                	sd	s2,0(sp)
    80003144:	1000                	addi	s0,sp,32
    80003146:	84ae                	mv	s1,a1
    80003148:	8932                	mv	s2,a2
  *ip = argraw(n);
    8000314a:	00000097          	auipc	ra,0x0
    8000314e:	eaa080e7          	jalr	-342(ra) # 80002ff4 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003152:	864a                	mv	a2,s2
    80003154:	85a6                	mv	a1,s1
    80003156:	00000097          	auipc	ra,0x0
    8000315a:	f58080e7          	jalr	-168(ra) # 800030ae <fetchstr>
}
    8000315e:	60e2                	ld	ra,24(sp)
    80003160:	6442                	ld	s0,16(sp)
    80003162:	64a2                	ld	s1,8(sp)
    80003164:	6902                	ld	s2,0(sp)
    80003166:	6105                	addi	sp,sp,32
    80003168:	8082                	ret

000000008000316a <syscall>:
[SYS_ps]      sys_ps,
};

void
syscall(void)
{
    8000316a:	1101                	addi	sp,sp,-32
    8000316c:	ec06                	sd	ra,24(sp)
    8000316e:	e822                	sd	s0,16(sp)
    80003170:	e426                	sd	s1,8(sp)
    80003172:	e04a                	sd	s2,0(sp)
    80003174:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003176:	fffff097          	auipc	ra,0xfffff
    8000317a:	83a080e7          	jalr	-1990(ra) # 800019b0 <myproc>
    8000317e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003180:	05853903          	ld	s2,88(a0)
    80003184:	0a893783          	ld	a5,168(s2)
    80003188:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000318c:	37fd                	addiw	a5,a5,-1
    8000318e:	476d                	li	a4,27
    80003190:	00f76f63          	bltu	a4,a5,800031ae <syscall+0x44>
    80003194:	00369713          	slli	a4,a3,0x3
    80003198:	00005797          	auipc	a5,0x5
    8000319c:	3b878793          	addi	a5,a5,952 # 80008550 <syscalls>
    800031a0:	97ba                	add	a5,a5,a4
    800031a2:	639c                	ld	a5,0(a5)
    800031a4:	c789                	beqz	a5,800031ae <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800031a6:	9782                	jalr	a5
    800031a8:	06a93823          	sd	a0,112(s2)
    800031ac:	a839                	j	800031ca <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800031ae:	15848613          	addi	a2,s1,344
    800031b2:	588c                	lw	a1,48(s1)
    800031b4:	00005517          	auipc	a0,0x5
    800031b8:	36450513          	addi	a0,a0,868 # 80008518 <states.1789+0x150>
    800031bc:	ffffd097          	auipc	ra,0xffffd
    800031c0:	3cc080e7          	jalr	972(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800031c4:	6cbc                	ld	a5,88(s1)
    800031c6:	577d                	li	a4,-1
    800031c8:	fbb8                	sd	a4,112(a5)
  }
}
    800031ca:	60e2                	ld	ra,24(sp)
    800031cc:	6442                	ld	s0,16(sp)
    800031ce:	64a2                	ld	s1,8(sp)
    800031d0:	6902                	ld	s2,0(sp)
    800031d2:	6105                	addi	sp,sp,32
    800031d4:	8082                	ret

00000000800031d6 <sys_exit>:
// int forkf(int(*f)());


uint64
sys_exit(void)
{
    800031d6:	1101                	addi	sp,sp,-32
    800031d8:	ec06                	sd	ra,24(sp)
    800031da:	e822                	sd	s0,16(sp)
    800031dc:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800031de:	fec40593          	addi	a1,s0,-20
    800031e2:	4501                	li	a0,0
    800031e4:	00000097          	auipc	ra,0x0
    800031e8:	f12080e7          	jalr	-238(ra) # 800030f6 <argint>
    return -1;
    800031ec:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800031ee:	00054963          	bltz	a0,80003200 <sys_exit+0x2a>
  exit(n);
    800031f2:	fec42503          	lw	a0,-20(s0)
    800031f6:	fffff097          	auipc	ra,0xfffff
    800031fa:	3fe080e7          	jalr	1022(ra) # 800025f4 <exit>
  return 0;  // not reached
    800031fe:	4781                	li	a5,0
}
    80003200:	853e                	mv	a0,a5
    80003202:	60e2                	ld	ra,24(sp)
    80003204:	6442                	ld	s0,16(sp)
    80003206:	6105                	addi	sp,sp,32
    80003208:	8082                	ret

000000008000320a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000320a:	1141                	addi	sp,sp,-16
    8000320c:	e406                	sd	ra,8(sp)
    8000320e:	e022                	sd	s0,0(sp)
    80003210:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003212:	ffffe097          	auipc	ra,0xffffe
    80003216:	79e080e7          	jalr	1950(ra) # 800019b0 <myproc>
}
    8000321a:	5908                	lw	a0,48(a0)
    8000321c:	60a2                	ld	ra,8(sp)
    8000321e:	6402                	ld	s0,0(sp)
    80003220:	0141                	addi	sp,sp,16
    80003222:	8082                	ret

0000000080003224 <sys_getppid>:

uint64
sys_getppid(void)
{
    80003224:	1141                	addi	sp,sp,-16
    80003226:	e406                	sd	ra,8(sp)
    80003228:	e022                	sd	s0,0(sp)
    8000322a:	0800                	addi	s0,sp,16
  return myproc()->parent->pid;
    8000322c:	ffffe097          	auipc	ra,0xffffe
    80003230:	784080e7          	jalr	1924(ra) # 800019b0 <myproc>
    80003234:	7d1c                	ld	a5,56(a0)
}
    80003236:	5b88                	lw	a0,48(a5)
    80003238:	60a2                	ld	ra,8(sp)
    8000323a:	6402                	ld	s0,0(sp)
    8000323c:	0141                	addi	sp,sp,16
    8000323e:	8082                	ret

0000000080003240 <sys_forkf>:

uint64
sys_forkf(int(*f)(void))
{
    80003240:	1141                	addi	sp,sp,-16
    80003242:	e406                	sd	ra,8(sp)
    80003244:	e022                	sd	s0,0(sp)
    80003246:	0800                	addi	s0,sp,16
  // uint64 n;
  // if(argaddr(0, &n) < 0)
  //   return -1;
  
  // return forkf(n);
  return forkf(f);
    80003248:	fffff097          	auipc	ra,0xfffff
    8000324c:	cec080e7          	jalr	-788(ra) # 80001f34 <forkf>
}
    80003250:	60a2                	ld	ra,8(sp)
    80003252:	6402                	ld	s0,0(sp)
    80003254:	0141                	addi	sp,sp,16
    80003256:	8082                	ret

0000000080003258 <sys_pinfo>:

uint64 sys_pinfo(void)
{ 
    80003258:	1101                	addi	sp,sp,-32
    8000325a:	ec06                	sd	ra,24(sp)
    8000325c:	e822                	sd	s0,16(sp)
    8000325e:	1000                	addi	s0,sp,32
  // printf("%d\n", pid);
  int p;
  if(argint(0, &p) < 0){
    80003260:	fec40593          	addi	a1,s0,-20
    80003264:	4501                	li	a0,0
    80003266:	00000097          	auipc	ra,0x0
    8000326a:	e90080e7          	jalr	-368(ra) # 800030f6 <argint>
    return -1;
    8000326e:	57fd                	li	a5,-1
  if(argint(0, &p) < 0){
    80003270:	02054563          	bltz	a0,8000329a <sys_pinfo+0x42>
  }
  uint64 pstat;
  if(argaddr(1, &pstat) < 0){
    80003274:	fe040593          	addi	a1,s0,-32
    80003278:	4505                	li	a0,1
    8000327a:	00000097          	auipc	ra,0x0
    8000327e:	e9e080e7          	jalr	-354(ra) # 80003118 <argaddr>
    return -1;
    80003282:	57fd                	li	a5,-1
  if(argaddr(1, &pstat) < 0){
    80003284:	00054b63          	bltz	a0,8000329a <sys_pinfo+0x42>
  }
  int x = pinfo(p, pstat);
    80003288:	fe043583          	ld	a1,-32(s0)
    8000328c:	fec42503          	lw	a0,-20(s0)
    80003290:	fffff097          	auipc	ra,0xfffff
    80003294:	7ec080e7          	jalr	2028(ra) # 80002a7c <pinfo>
  // printf("%d\n", x);
  return x;
    80003298:	87aa                	mv	a5,a0
}
    8000329a:	853e                	mv	a0,a5
    8000329c:	60e2                	ld	ra,24(sp)
    8000329e:	6442                	ld	s0,16(sp)
    800032a0:	6105                	addi	sp,sp,32
    800032a2:	8082                	ret

00000000800032a4 <sys_ps>:

uint64
sys_ps(void){
    800032a4:	1141                	addi	sp,sp,-16
    800032a6:	e406                	sd	ra,8(sp)
    800032a8:	e022                	sd	s0,0(sp)
    800032aa:	0800                	addi	s0,sp,16
  return ps();
    800032ac:	fffff097          	auipc	ra,0xfffff
    800032b0:	61a080e7          	jalr	1562(ra) # 800028c6 <ps>
}
    800032b4:	60a2                	ld	ra,8(sp)
    800032b6:	6402                	ld	s0,0(sp)
    800032b8:	0141                	addi	sp,sp,16
    800032ba:	8082                	ret

00000000800032bc <sys_fork>:

uint64
sys_fork(void)
{
    800032bc:	1141                	addi	sp,sp,-16
    800032be:	e406                	sd	ra,8(sp)
    800032c0:	e022                	sd	s0,0(sp)
    800032c2:	0800                	addi	s0,sp,16
  return fork();
    800032c4:	fffff097          	auipc	ra,0xfffff
    800032c8:	b02080e7          	jalr	-1278(ra) # 80001dc6 <fork>
}
    800032cc:	60a2                	ld	ra,8(sp)
    800032ce:	6402                	ld	s0,0(sp)
    800032d0:	0141                	addi	sp,sp,16
    800032d2:	8082                	ret

00000000800032d4 <sys_getpa>:

uint64
sys_getpa(void)
{
    800032d4:	1101                	addi	sp,sp,-32
    800032d6:	ec06                	sd	ra,24(sp)
    800032d8:	e822                	sd	s0,16(sp)
    800032da:	1000                	addi	s0,sp,32
  uint64 n;
  if(argaddr(1, &n) < 0)
    800032dc:	fe840593          	addi	a1,s0,-24
    800032e0:	4505                	li	a0,1
    800032e2:	00000097          	auipc	ra,0x0
    800032e6:	e36080e7          	jalr	-458(ra) # 80003118 <argaddr>
    800032ea:	87aa                	mv	a5,a0
    return -1;
    800032ec:	557d                	li	a0,-1
  if(argaddr(1, &n) < 0)
    800032ee:	0207c263          	bltz	a5,80003312 <sys_getpa+0x3e>
  return walkaddr(myproc()->pagetable, n) + (n & (PGSIZE - 1));
    800032f2:	ffffe097          	auipc	ra,0xffffe
    800032f6:	6be080e7          	jalr	1726(ra) # 800019b0 <myproc>
    800032fa:	fe843583          	ld	a1,-24(s0)
    800032fe:	6928                	ld	a0,80(a0)
    80003300:	ffffe097          	auipc	ra,0xffffe
    80003304:	d6e080e7          	jalr	-658(ra) # 8000106e <walkaddr>
    80003308:	fe843783          	ld	a5,-24(s0)
    8000330c:	17d2                	slli	a5,a5,0x34
    8000330e:	93d1                	srli	a5,a5,0x34
    80003310:	953e                	add	a0,a0,a5
}
    80003312:	60e2                	ld	ra,24(sp)
    80003314:	6442                	ld	s0,16(sp)
    80003316:	6105                	addi	sp,sp,32
    80003318:	8082                	ret

000000008000331a <sys_waitpid>:

uint64
sys_waitpid(void)
{
    8000331a:	1101                	addi	sp,sp,-32
    8000331c:	ec06                	sd	ra,24(sp)
    8000331e:	e822                	sd	s0,16(sp)
    80003320:	1000                	addi	s0,sp,32
  uint64 pid;
  if(argaddr(0, &pid) < 0)
    80003322:	fe840593          	addi	a1,s0,-24
    80003326:	4501                	li	a0,0
    80003328:	00000097          	auipc	ra,0x0
    8000332c:	df0080e7          	jalr	-528(ra) # 80003118 <argaddr>
    return -1;
    80003330:	57fd                	li	a5,-1
  if(argaddr(0, &pid) < 0)
    80003332:	02054563          	bltz	a0,8000335c <sys_waitpid+0x42>
  uint64 p;
  if(argaddr(0, &p) < 0) // Do it 1
    80003336:	fe040593          	addi	a1,s0,-32
    8000333a:	4501                	li	a0,0
    8000333c:	00000097          	auipc	ra,0x0
    80003340:	ddc080e7          	jalr	-548(ra) # 80003118 <argaddr>
    return -1;
    80003344:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0) // Do it 1
    80003346:	00054b63          	bltz	a0,8000335c <sys_waitpid+0x42>
  return waitpid(pid, p);
    8000334a:	fe043583          	ld	a1,-32(s0)
    8000334e:	fe843503          	ld	a0,-24(s0)
    80003352:	fffff097          	auipc	ra,0xfffff
    80003356:	09e080e7          	jalr	158(ra) # 800023f0 <waitpid>
    8000335a:	87aa                	mv	a5,a0
  return 0;
}
    8000335c:	853e                	mv	a0,a5
    8000335e:	60e2                	ld	ra,24(sp)
    80003360:	6442                	ld	s0,16(sp)
    80003362:	6105                	addi	sp,sp,32
    80003364:	8082                	ret

0000000080003366 <sys_yield>:

uint64
sys_yield(void)
{
    80003366:	1141                	addi	sp,sp,-16
    80003368:	e406                	sd	ra,8(sp)
    8000336a:	e022                	sd	s0,0(sp)
    8000336c:	0800                	addi	s0,sp,16
  yield();
    8000336e:	fffff097          	auipc	ra,0xfffff
    80003372:	eba080e7          	jalr	-326(ra) # 80002228 <yield>
  return 0;
}
    80003376:	4501                	li	a0,0
    80003378:	60a2                	ld	ra,8(sp)
    8000337a:	6402                	ld	s0,0(sp)
    8000337c:	0141                	addi	sp,sp,16
    8000337e:	8082                	ret

0000000080003380 <sys_wait>:

uint64
sys_wait(void)
{
    80003380:	1101                	addi	sp,sp,-32
    80003382:	ec06                	sd	ra,24(sp)
    80003384:	e822                	sd	s0,16(sp)
    80003386:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003388:	fe840593          	addi	a1,s0,-24
    8000338c:	4501                	li	a0,0
    8000338e:	00000097          	auipc	ra,0x0
    80003392:	d8a080e7          	jalr	-630(ra) # 80003118 <argaddr>
    80003396:	87aa                	mv	a5,a0
    return -1;
    80003398:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    8000339a:	0007c863          	bltz	a5,800033aa <sys_wait+0x2a>
  return wait(p);
    8000339e:	fe843503          	ld	a0,-24(s0)
    800033a2:	fffff097          	auipc	ra,0xfffff
    800033a6:	f26080e7          	jalr	-218(ra) # 800022c8 <wait>
}
    800033aa:	60e2                	ld	ra,24(sp)
    800033ac:	6442                	ld	s0,16(sp)
    800033ae:	6105                	addi	sp,sp,32
    800033b0:	8082                	ret

00000000800033b2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800033b2:	7179                	addi	sp,sp,-48
    800033b4:	f406                	sd	ra,40(sp)
    800033b6:	f022                	sd	s0,32(sp)
    800033b8:	ec26                	sd	s1,24(sp)
    800033ba:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800033bc:	fdc40593          	addi	a1,s0,-36
    800033c0:	4501                	li	a0,0
    800033c2:	00000097          	auipc	ra,0x0
    800033c6:	d34080e7          	jalr	-716(ra) # 800030f6 <argint>
    800033ca:	87aa                	mv	a5,a0
    return -1;
    800033cc:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    800033ce:	0207c063          	bltz	a5,800033ee <sys_sbrk+0x3c>
  addr = myproc()->sz;
    800033d2:	ffffe097          	auipc	ra,0xffffe
    800033d6:	5de080e7          	jalr	1502(ra) # 800019b0 <myproc>
    800033da:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    800033dc:	fdc42503          	lw	a0,-36(s0)
    800033e0:	fffff097          	auipc	ra,0xfffff
    800033e4:	972080e7          	jalr	-1678(ra) # 80001d52 <growproc>
    800033e8:	00054863          	bltz	a0,800033f8 <sys_sbrk+0x46>
    return -1;
  return addr;
    800033ec:	8526                	mv	a0,s1
}
    800033ee:	70a2                	ld	ra,40(sp)
    800033f0:	7402                	ld	s0,32(sp)
    800033f2:	64e2                	ld	s1,24(sp)
    800033f4:	6145                	addi	sp,sp,48
    800033f6:	8082                	ret
    return -1;
    800033f8:	557d                	li	a0,-1
    800033fa:	bfd5                	j	800033ee <sys_sbrk+0x3c>

00000000800033fc <sys_sleep>:

uint64
sys_sleep(void)
{
    800033fc:	7139                	addi	sp,sp,-64
    800033fe:	fc06                	sd	ra,56(sp)
    80003400:	f822                	sd	s0,48(sp)
    80003402:	f426                	sd	s1,40(sp)
    80003404:	f04a                	sd	s2,32(sp)
    80003406:	ec4e                	sd	s3,24(sp)
    80003408:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    8000340a:	fcc40593          	addi	a1,s0,-52
    8000340e:	4501                	li	a0,0
    80003410:	00000097          	auipc	ra,0x0
    80003414:	ce6080e7          	jalr	-794(ra) # 800030f6 <argint>
    return -1;
    80003418:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000341a:	06054563          	bltz	a0,80003484 <sys_sleep+0x88>
  acquire(&tickslock);
    8000341e:	00014517          	auipc	a0,0x14
    80003422:	2b250513          	addi	a0,a0,690 # 800176d0 <tickslock>
    80003426:	ffffd097          	auipc	ra,0xffffd
    8000342a:	7be080e7          	jalr	1982(ra) # 80000be4 <acquire>
  ticks0 = ticks;
    8000342e:	00006917          	auipc	s2,0x6
    80003432:	c0292903          	lw	s2,-1022(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80003436:	fcc42783          	lw	a5,-52(s0)
    8000343a:	cf85                	beqz	a5,80003472 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000343c:	00014997          	auipc	s3,0x14
    80003440:	29498993          	addi	s3,s3,660 # 800176d0 <tickslock>
    80003444:	00006497          	auipc	s1,0x6
    80003448:	bec48493          	addi	s1,s1,-1044 # 80009030 <ticks>
    if(myproc()->killed){
    8000344c:	ffffe097          	auipc	ra,0xffffe
    80003450:	564080e7          	jalr	1380(ra) # 800019b0 <myproc>
    80003454:	551c                	lw	a5,40(a0)
    80003456:	ef9d                	bnez	a5,80003494 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003458:	85ce                	mv	a1,s3
    8000345a:	8526                	mv	a0,s1
    8000345c:	fffff097          	auipc	ra,0xfffff
    80003460:	e08080e7          	jalr	-504(ra) # 80002264 <sleep>
  while(ticks - ticks0 < n){
    80003464:	409c                	lw	a5,0(s1)
    80003466:	412787bb          	subw	a5,a5,s2
    8000346a:	fcc42703          	lw	a4,-52(s0)
    8000346e:	fce7efe3          	bltu	a5,a4,8000344c <sys_sleep+0x50>
  }
  release(&tickslock);
    80003472:	00014517          	auipc	a0,0x14
    80003476:	25e50513          	addi	a0,a0,606 # 800176d0 <tickslock>
    8000347a:	ffffe097          	auipc	ra,0xffffe
    8000347e:	81e080e7          	jalr	-2018(ra) # 80000c98 <release>
  return 0;
    80003482:	4781                	li	a5,0
}
    80003484:	853e                	mv	a0,a5
    80003486:	70e2                	ld	ra,56(sp)
    80003488:	7442                	ld	s0,48(sp)
    8000348a:	74a2                	ld	s1,40(sp)
    8000348c:	7902                	ld	s2,32(sp)
    8000348e:	69e2                	ld	s3,24(sp)
    80003490:	6121                	addi	sp,sp,64
    80003492:	8082                	ret
      release(&tickslock);
    80003494:	00014517          	auipc	a0,0x14
    80003498:	23c50513          	addi	a0,a0,572 # 800176d0 <tickslock>
    8000349c:	ffffd097          	auipc	ra,0xffffd
    800034a0:	7fc080e7          	jalr	2044(ra) # 80000c98 <release>
      return -1;
    800034a4:	57fd                	li	a5,-1
    800034a6:	bff9                	j	80003484 <sys_sleep+0x88>

00000000800034a8 <sys_kill>:

uint64
sys_kill(void)
{
    800034a8:	1101                	addi	sp,sp,-32
    800034aa:	ec06                	sd	ra,24(sp)
    800034ac:	e822                	sd	s0,16(sp)
    800034ae:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800034b0:	fec40593          	addi	a1,s0,-20
    800034b4:	4501                	li	a0,0
    800034b6:	00000097          	auipc	ra,0x0
    800034ba:	c40080e7          	jalr	-960(ra) # 800030f6 <argint>
    800034be:	87aa                	mv	a5,a0
    return -1;
    800034c0:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800034c2:	0007c863          	bltz	a5,800034d2 <sys_kill+0x2a>
  return kill(pid);
    800034c6:	fec42503          	lw	a0,-20(s0)
    800034ca:	fffff097          	auipc	ra,0xfffff
    800034ce:	230080e7          	jalr	560(ra) # 800026fa <kill>
}
    800034d2:	60e2                	ld	ra,24(sp)
    800034d4:	6442                	ld	s0,16(sp)
    800034d6:	6105                	addi	sp,sp,32
    800034d8:	8082                	ret

00000000800034da <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800034da:	1101                	addi	sp,sp,-32
    800034dc:	ec06                	sd	ra,24(sp)
    800034de:	e822                	sd	s0,16(sp)
    800034e0:	e426                	sd	s1,8(sp)
    800034e2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800034e4:	00014517          	auipc	a0,0x14
    800034e8:	1ec50513          	addi	a0,a0,492 # 800176d0 <tickslock>
    800034ec:	ffffd097          	auipc	ra,0xffffd
    800034f0:	6f8080e7          	jalr	1784(ra) # 80000be4 <acquire>
  xticks = ticks;
    800034f4:	00006497          	auipc	s1,0x6
    800034f8:	b3c4a483          	lw	s1,-1220(s1) # 80009030 <ticks>
  release(&tickslock);
    800034fc:	00014517          	auipc	a0,0x14
    80003500:	1d450513          	addi	a0,a0,468 # 800176d0 <tickslock>
    80003504:	ffffd097          	auipc	ra,0xffffd
    80003508:	794080e7          	jalr	1940(ra) # 80000c98 <release>
  return xticks;
}
    8000350c:	02049513          	slli	a0,s1,0x20
    80003510:	9101                	srli	a0,a0,0x20
    80003512:	60e2                	ld	ra,24(sp)
    80003514:	6442                	ld	s0,16(sp)
    80003516:	64a2                	ld	s1,8(sp)
    80003518:	6105                	addi	sp,sp,32
    8000351a:	8082                	ret

000000008000351c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000351c:	7179                	addi	sp,sp,-48
    8000351e:	f406                	sd	ra,40(sp)
    80003520:	f022                	sd	s0,32(sp)
    80003522:	ec26                	sd	s1,24(sp)
    80003524:	e84a                	sd	s2,16(sp)
    80003526:	e44e                	sd	s3,8(sp)
    80003528:	e052                	sd	s4,0(sp)
    8000352a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000352c:	00005597          	auipc	a1,0x5
    80003530:	10c58593          	addi	a1,a1,268 # 80008638 <syscalls+0xe8>
    80003534:	00014517          	auipc	a0,0x14
    80003538:	1b450513          	addi	a0,a0,436 # 800176e8 <bcache>
    8000353c:	ffffd097          	auipc	ra,0xffffd
    80003540:	618080e7          	jalr	1560(ra) # 80000b54 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003544:	0001c797          	auipc	a5,0x1c
    80003548:	1a478793          	addi	a5,a5,420 # 8001f6e8 <bcache+0x8000>
    8000354c:	0001c717          	auipc	a4,0x1c
    80003550:	40470713          	addi	a4,a4,1028 # 8001f950 <bcache+0x8268>
    80003554:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003558:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000355c:	00014497          	auipc	s1,0x14
    80003560:	1a448493          	addi	s1,s1,420 # 80017700 <bcache+0x18>
    b->next = bcache.head.next;
    80003564:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003566:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003568:	00005a17          	auipc	s4,0x5
    8000356c:	0d8a0a13          	addi	s4,s4,216 # 80008640 <syscalls+0xf0>
    b->next = bcache.head.next;
    80003570:	2b893783          	ld	a5,696(s2)
    80003574:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003576:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000357a:	85d2                	mv	a1,s4
    8000357c:	01048513          	addi	a0,s1,16
    80003580:	00001097          	auipc	ra,0x1
    80003584:	4bc080e7          	jalr	1212(ra) # 80004a3c <initsleeplock>
    bcache.head.next->prev = b;
    80003588:	2b893783          	ld	a5,696(s2)
    8000358c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000358e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003592:	45848493          	addi	s1,s1,1112
    80003596:	fd349de3          	bne	s1,s3,80003570 <binit+0x54>
  }
}
    8000359a:	70a2                	ld	ra,40(sp)
    8000359c:	7402                	ld	s0,32(sp)
    8000359e:	64e2                	ld	s1,24(sp)
    800035a0:	6942                	ld	s2,16(sp)
    800035a2:	69a2                	ld	s3,8(sp)
    800035a4:	6a02                	ld	s4,0(sp)
    800035a6:	6145                	addi	sp,sp,48
    800035a8:	8082                	ret

00000000800035aa <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800035aa:	7179                	addi	sp,sp,-48
    800035ac:	f406                	sd	ra,40(sp)
    800035ae:	f022                	sd	s0,32(sp)
    800035b0:	ec26                	sd	s1,24(sp)
    800035b2:	e84a                	sd	s2,16(sp)
    800035b4:	e44e                	sd	s3,8(sp)
    800035b6:	1800                	addi	s0,sp,48
    800035b8:	89aa                	mv	s3,a0
    800035ba:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800035bc:	00014517          	auipc	a0,0x14
    800035c0:	12c50513          	addi	a0,a0,300 # 800176e8 <bcache>
    800035c4:	ffffd097          	auipc	ra,0xffffd
    800035c8:	620080e7          	jalr	1568(ra) # 80000be4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800035cc:	0001c497          	auipc	s1,0x1c
    800035d0:	3d44b483          	ld	s1,980(s1) # 8001f9a0 <bcache+0x82b8>
    800035d4:	0001c797          	auipc	a5,0x1c
    800035d8:	37c78793          	addi	a5,a5,892 # 8001f950 <bcache+0x8268>
    800035dc:	02f48f63          	beq	s1,a5,8000361a <bread+0x70>
    800035e0:	873e                	mv	a4,a5
    800035e2:	a021                	j	800035ea <bread+0x40>
    800035e4:	68a4                	ld	s1,80(s1)
    800035e6:	02e48a63          	beq	s1,a4,8000361a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800035ea:	449c                	lw	a5,8(s1)
    800035ec:	ff379ce3          	bne	a5,s3,800035e4 <bread+0x3a>
    800035f0:	44dc                	lw	a5,12(s1)
    800035f2:	ff2799e3          	bne	a5,s2,800035e4 <bread+0x3a>
      b->refcnt++;
    800035f6:	40bc                	lw	a5,64(s1)
    800035f8:	2785                	addiw	a5,a5,1
    800035fa:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035fc:	00014517          	auipc	a0,0x14
    80003600:	0ec50513          	addi	a0,a0,236 # 800176e8 <bcache>
    80003604:	ffffd097          	auipc	ra,0xffffd
    80003608:	694080e7          	jalr	1684(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    8000360c:	01048513          	addi	a0,s1,16
    80003610:	00001097          	auipc	ra,0x1
    80003614:	466080e7          	jalr	1126(ra) # 80004a76 <acquiresleep>
      return b;
    80003618:	a8b9                	j	80003676 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000361a:	0001c497          	auipc	s1,0x1c
    8000361e:	37e4b483          	ld	s1,894(s1) # 8001f998 <bcache+0x82b0>
    80003622:	0001c797          	auipc	a5,0x1c
    80003626:	32e78793          	addi	a5,a5,814 # 8001f950 <bcache+0x8268>
    8000362a:	00f48863          	beq	s1,a5,8000363a <bread+0x90>
    8000362e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003630:	40bc                	lw	a5,64(s1)
    80003632:	cf81                	beqz	a5,8000364a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003634:	64a4                	ld	s1,72(s1)
    80003636:	fee49de3          	bne	s1,a4,80003630 <bread+0x86>
  panic("bget: no buffers");
    8000363a:	00005517          	auipc	a0,0x5
    8000363e:	00e50513          	addi	a0,a0,14 # 80008648 <syscalls+0xf8>
    80003642:	ffffd097          	auipc	ra,0xffffd
    80003646:	efc080e7          	jalr	-260(ra) # 8000053e <panic>
      b->dev = dev;
    8000364a:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000364e:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003652:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003656:	4785                	li	a5,1
    80003658:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000365a:	00014517          	auipc	a0,0x14
    8000365e:	08e50513          	addi	a0,a0,142 # 800176e8 <bcache>
    80003662:	ffffd097          	auipc	ra,0xffffd
    80003666:	636080e7          	jalr	1590(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    8000366a:	01048513          	addi	a0,s1,16
    8000366e:	00001097          	auipc	ra,0x1
    80003672:	408080e7          	jalr	1032(ra) # 80004a76 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003676:	409c                	lw	a5,0(s1)
    80003678:	cb89                	beqz	a5,8000368a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000367a:	8526                	mv	a0,s1
    8000367c:	70a2                	ld	ra,40(sp)
    8000367e:	7402                	ld	s0,32(sp)
    80003680:	64e2                	ld	s1,24(sp)
    80003682:	6942                	ld	s2,16(sp)
    80003684:	69a2                	ld	s3,8(sp)
    80003686:	6145                	addi	sp,sp,48
    80003688:	8082                	ret
    virtio_disk_rw(b, 0);
    8000368a:	4581                	li	a1,0
    8000368c:	8526                	mv	a0,s1
    8000368e:	00003097          	auipc	ra,0x3
    80003692:	f08080e7          	jalr	-248(ra) # 80006596 <virtio_disk_rw>
    b->valid = 1;
    80003696:	4785                	li	a5,1
    80003698:	c09c                	sw	a5,0(s1)
  return b;
    8000369a:	b7c5                	j	8000367a <bread+0xd0>

000000008000369c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000369c:	1101                	addi	sp,sp,-32
    8000369e:	ec06                	sd	ra,24(sp)
    800036a0:	e822                	sd	s0,16(sp)
    800036a2:	e426                	sd	s1,8(sp)
    800036a4:	1000                	addi	s0,sp,32
    800036a6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036a8:	0541                	addi	a0,a0,16
    800036aa:	00001097          	auipc	ra,0x1
    800036ae:	466080e7          	jalr	1126(ra) # 80004b10 <holdingsleep>
    800036b2:	cd01                	beqz	a0,800036ca <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800036b4:	4585                	li	a1,1
    800036b6:	8526                	mv	a0,s1
    800036b8:	00003097          	auipc	ra,0x3
    800036bc:	ede080e7          	jalr	-290(ra) # 80006596 <virtio_disk_rw>
}
    800036c0:	60e2                	ld	ra,24(sp)
    800036c2:	6442                	ld	s0,16(sp)
    800036c4:	64a2                	ld	s1,8(sp)
    800036c6:	6105                	addi	sp,sp,32
    800036c8:	8082                	ret
    panic("bwrite");
    800036ca:	00005517          	auipc	a0,0x5
    800036ce:	f9650513          	addi	a0,a0,-106 # 80008660 <syscalls+0x110>
    800036d2:	ffffd097          	auipc	ra,0xffffd
    800036d6:	e6c080e7          	jalr	-404(ra) # 8000053e <panic>

00000000800036da <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800036da:	1101                	addi	sp,sp,-32
    800036dc:	ec06                	sd	ra,24(sp)
    800036de:	e822                	sd	s0,16(sp)
    800036e0:	e426                	sd	s1,8(sp)
    800036e2:	e04a                	sd	s2,0(sp)
    800036e4:	1000                	addi	s0,sp,32
    800036e6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036e8:	01050913          	addi	s2,a0,16
    800036ec:	854a                	mv	a0,s2
    800036ee:	00001097          	auipc	ra,0x1
    800036f2:	422080e7          	jalr	1058(ra) # 80004b10 <holdingsleep>
    800036f6:	c92d                	beqz	a0,80003768 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800036f8:	854a                	mv	a0,s2
    800036fa:	00001097          	auipc	ra,0x1
    800036fe:	3d2080e7          	jalr	978(ra) # 80004acc <releasesleep>

  acquire(&bcache.lock);
    80003702:	00014517          	auipc	a0,0x14
    80003706:	fe650513          	addi	a0,a0,-26 # 800176e8 <bcache>
    8000370a:	ffffd097          	auipc	ra,0xffffd
    8000370e:	4da080e7          	jalr	1242(ra) # 80000be4 <acquire>
  b->refcnt--;
    80003712:	40bc                	lw	a5,64(s1)
    80003714:	37fd                	addiw	a5,a5,-1
    80003716:	0007871b          	sext.w	a4,a5
    8000371a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000371c:	eb05                	bnez	a4,8000374c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000371e:	68bc                	ld	a5,80(s1)
    80003720:	64b8                	ld	a4,72(s1)
    80003722:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003724:	64bc                	ld	a5,72(s1)
    80003726:	68b8                	ld	a4,80(s1)
    80003728:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000372a:	0001c797          	auipc	a5,0x1c
    8000372e:	fbe78793          	addi	a5,a5,-66 # 8001f6e8 <bcache+0x8000>
    80003732:	2b87b703          	ld	a4,696(a5)
    80003736:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003738:	0001c717          	auipc	a4,0x1c
    8000373c:	21870713          	addi	a4,a4,536 # 8001f950 <bcache+0x8268>
    80003740:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003742:	2b87b703          	ld	a4,696(a5)
    80003746:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003748:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000374c:	00014517          	auipc	a0,0x14
    80003750:	f9c50513          	addi	a0,a0,-100 # 800176e8 <bcache>
    80003754:	ffffd097          	auipc	ra,0xffffd
    80003758:	544080e7          	jalr	1348(ra) # 80000c98 <release>
}
    8000375c:	60e2                	ld	ra,24(sp)
    8000375e:	6442                	ld	s0,16(sp)
    80003760:	64a2                	ld	s1,8(sp)
    80003762:	6902                	ld	s2,0(sp)
    80003764:	6105                	addi	sp,sp,32
    80003766:	8082                	ret
    panic("brelse");
    80003768:	00005517          	auipc	a0,0x5
    8000376c:	f0050513          	addi	a0,a0,-256 # 80008668 <syscalls+0x118>
    80003770:	ffffd097          	auipc	ra,0xffffd
    80003774:	dce080e7          	jalr	-562(ra) # 8000053e <panic>

0000000080003778 <bpin>:

void
bpin(struct buf *b) {
    80003778:	1101                	addi	sp,sp,-32
    8000377a:	ec06                	sd	ra,24(sp)
    8000377c:	e822                	sd	s0,16(sp)
    8000377e:	e426                	sd	s1,8(sp)
    80003780:	1000                	addi	s0,sp,32
    80003782:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003784:	00014517          	auipc	a0,0x14
    80003788:	f6450513          	addi	a0,a0,-156 # 800176e8 <bcache>
    8000378c:	ffffd097          	auipc	ra,0xffffd
    80003790:	458080e7          	jalr	1112(ra) # 80000be4 <acquire>
  b->refcnt++;
    80003794:	40bc                	lw	a5,64(s1)
    80003796:	2785                	addiw	a5,a5,1
    80003798:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000379a:	00014517          	auipc	a0,0x14
    8000379e:	f4e50513          	addi	a0,a0,-178 # 800176e8 <bcache>
    800037a2:	ffffd097          	auipc	ra,0xffffd
    800037a6:	4f6080e7          	jalr	1270(ra) # 80000c98 <release>
}
    800037aa:	60e2                	ld	ra,24(sp)
    800037ac:	6442                	ld	s0,16(sp)
    800037ae:	64a2                	ld	s1,8(sp)
    800037b0:	6105                	addi	sp,sp,32
    800037b2:	8082                	ret

00000000800037b4 <bunpin>:

void
bunpin(struct buf *b) {
    800037b4:	1101                	addi	sp,sp,-32
    800037b6:	ec06                	sd	ra,24(sp)
    800037b8:	e822                	sd	s0,16(sp)
    800037ba:	e426                	sd	s1,8(sp)
    800037bc:	1000                	addi	s0,sp,32
    800037be:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037c0:	00014517          	auipc	a0,0x14
    800037c4:	f2850513          	addi	a0,a0,-216 # 800176e8 <bcache>
    800037c8:	ffffd097          	auipc	ra,0xffffd
    800037cc:	41c080e7          	jalr	1052(ra) # 80000be4 <acquire>
  b->refcnt--;
    800037d0:	40bc                	lw	a5,64(s1)
    800037d2:	37fd                	addiw	a5,a5,-1
    800037d4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037d6:	00014517          	auipc	a0,0x14
    800037da:	f1250513          	addi	a0,a0,-238 # 800176e8 <bcache>
    800037de:	ffffd097          	auipc	ra,0xffffd
    800037e2:	4ba080e7          	jalr	1210(ra) # 80000c98 <release>
}
    800037e6:	60e2                	ld	ra,24(sp)
    800037e8:	6442                	ld	s0,16(sp)
    800037ea:	64a2                	ld	s1,8(sp)
    800037ec:	6105                	addi	sp,sp,32
    800037ee:	8082                	ret

00000000800037f0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800037f0:	1101                	addi	sp,sp,-32
    800037f2:	ec06                	sd	ra,24(sp)
    800037f4:	e822                	sd	s0,16(sp)
    800037f6:	e426                	sd	s1,8(sp)
    800037f8:	e04a                	sd	s2,0(sp)
    800037fa:	1000                	addi	s0,sp,32
    800037fc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800037fe:	00d5d59b          	srliw	a1,a1,0xd
    80003802:	0001c797          	auipc	a5,0x1c
    80003806:	5c27a783          	lw	a5,1474(a5) # 8001fdc4 <sb+0x1c>
    8000380a:	9dbd                	addw	a1,a1,a5
    8000380c:	00000097          	auipc	ra,0x0
    80003810:	d9e080e7          	jalr	-610(ra) # 800035aa <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003814:	0074f713          	andi	a4,s1,7
    80003818:	4785                	li	a5,1
    8000381a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000381e:	14ce                	slli	s1,s1,0x33
    80003820:	90d9                	srli	s1,s1,0x36
    80003822:	00950733          	add	a4,a0,s1
    80003826:	05874703          	lbu	a4,88(a4)
    8000382a:	00e7f6b3          	and	a3,a5,a4
    8000382e:	c69d                	beqz	a3,8000385c <bfree+0x6c>
    80003830:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003832:	94aa                	add	s1,s1,a0
    80003834:	fff7c793          	not	a5,a5
    80003838:	8ff9                	and	a5,a5,a4
    8000383a:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000383e:	00001097          	auipc	ra,0x1
    80003842:	118080e7          	jalr	280(ra) # 80004956 <log_write>
  brelse(bp);
    80003846:	854a                	mv	a0,s2
    80003848:	00000097          	auipc	ra,0x0
    8000384c:	e92080e7          	jalr	-366(ra) # 800036da <brelse>
}
    80003850:	60e2                	ld	ra,24(sp)
    80003852:	6442                	ld	s0,16(sp)
    80003854:	64a2                	ld	s1,8(sp)
    80003856:	6902                	ld	s2,0(sp)
    80003858:	6105                	addi	sp,sp,32
    8000385a:	8082                	ret
    panic("freeing free block");
    8000385c:	00005517          	auipc	a0,0x5
    80003860:	e1450513          	addi	a0,a0,-492 # 80008670 <syscalls+0x120>
    80003864:	ffffd097          	auipc	ra,0xffffd
    80003868:	cda080e7          	jalr	-806(ra) # 8000053e <panic>

000000008000386c <balloc>:
{
    8000386c:	711d                	addi	sp,sp,-96
    8000386e:	ec86                	sd	ra,88(sp)
    80003870:	e8a2                	sd	s0,80(sp)
    80003872:	e4a6                	sd	s1,72(sp)
    80003874:	e0ca                	sd	s2,64(sp)
    80003876:	fc4e                	sd	s3,56(sp)
    80003878:	f852                	sd	s4,48(sp)
    8000387a:	f456                	sd	s5,40(sp)
    8000387c:	f05a                	sd	s6,32(sp)
    8000387e:	ec5e                	sd	s7,24(sp)
    80003880:	e862                	sd	s8,16(sp)
    80003882:	e466                	sd	s9,8(sp)
    80003884:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003886:	0001c797          	auipc	a5,0x1c
    8000388a:	5267a783          	lw	a5,1318(a5) # 8001fdac <sb+0x4>
    8000388e:	cbd1                	beqz	a5,80003922 <balloc+0xb6>
    80003890:	8baa                	mv	s7,a0
    80003892:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003894:	0001cb17          	auipc	s6,0x1c
    80003898:	514b0b13          	addi	s6,s6,1300 # 8001fda8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000389c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000389e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038a0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800038a2:	6c89                	lui	s9,0x2
    800038a4:	a831                	j	800038c0 <balloc+0x54>
    brelse(bp);
    800038a6:	854a                	mv	a0,s2
    800038a8:	00000097          	auipc	ra,0x0
    800038ac:	e32080e7          	jalr	-462(ra) # 800036da <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800038b0:	015c87bb          	addw	a5,s9,s5
    800038b4:	00078a9b          	sext.w	s5,a5
    800038b8:	004b2703          	lw	a4,4(s6)
    800038bc:	06eaf363          	bgeu	s5,a4,80003922 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800038c0:	41fad79b          	sraiw	a5,s5,0x1f
    800038c4:	0137d79b          	srliw	a5,a5,0x13
    800038c8:	015787bb          	addw	a5,a5,s5
    800038cc:	40d7d79b          	sraiw	a5,a5,0xd
    800038d0:	01cb2583          	lw	a1,28(s6)
    800038d4:	9dbd                	addw	a1,a1,a5
    800038d6:	855e                	mv	a0,s7
    800038d8:	00000097          	auipc	ra,0x0
    800038dc:	cd2080e7          	jalr	-814(ra) # 800035aa <bread>
    800038e0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038e2:	004b2503          	lw	a0,4(s6)
    800038e6:	000a849b          	sext.w	s1,s5
    800038ea:	8662                	mv	a2,s8
    800038ec:	faa4fde3          	bgeu	s1,a0,800038a6 <balloc+0x3a>
      m = 1 << (bi % 8);
    800038f0:	41f6579b          	sraiw	a5,a2,0x1f
    800038f4:	01d7d69b          	srliw	a3,a5,0x1d
    800038f8:	00c6873b          	addw	a4,a3,a2
    800038fc:	00777793          	andi	a5,a4,7
    80003900:	9f95                	subw	a5,a5,a3
    80003902:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003906:	4037571b          	sraiw	a4,a4,0x3
    8000390a:	00e906b3          	add	a3,s2,a4
    8000390e:	0586c683          	lbu	a3,88(a3)
    80003912:	00d7f5b3          	and	a1,a5,a3
    80003916:	cd91                	beqz	a1,80003932 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003918:	2605                	addiw	a2,a2,1
    8000391a:	2485                	addiw	s1,s1,1
    8000391c:	fd4618e3          	bne	a2,s4,800038ec <balloc+0x80>
    80003920:	b759                	j	800038a6 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003922:	00005517          	auipc	a0,0x5
    80003926:	d6650513          	addi	a0,a0,-666 # 80008688 <syscalls+0x138>
    8000392a:	ffffd097          	auipc	ra,0xffffd
    8000392e:	c14080e7          	jalr	-1004(ra) # 8000053e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003932:	974a                	add	a4,a4,s2
    80003934:	8fd5                	or	a5,a5,a3
    80003936:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000393a:	854a                	mv	a0,s2
    8000393c:	00001097          	auipc	ra,0x1
    80003940:	01a080e7          	jalr	26(ra) # 80004956 <log_write>
        brelse(bp);
    80003944:	854a                	mv	a0,s2
    80003946:	00000097          	auipc	ra,0x0
    8000394a:	d94080e7          	jalr	-620(ra) # 800036da <brelse>
  bp = bread(dev, bno);
    8000394e:	85a6                	mv	a1,s1
    80003950:	855e                	mv	a0,s7
    80003952:	00000097          	auipc	ra,0x0
    80003956:	c58080e7          	jalr	-936(ra) # 800035aa <bread>
    8000395a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000395c:	40000613          	li	a2,1024
    80003960:	4581                	li	a1,0
    80003962:	05850513          	addi	a0,a0,88
    80003966:	ffffd097          	auipc	ra,0xffffd
    8000396a:	37a080e7          	jalr	890(ra) # 80000ce0 <memset>
  log_write(bp);
    8000396e:	854a                	mv	a0,s2
    80003970:	00001097          	auipc	ra,0x1
    80003974:	fe6080e7          	jalr	-26(ra) # 80004956 <log_write>
  brelse(bp);
    80003978:	854a                	mv	a0,s2
    8000397a:	00000097          	auipc	ra,0x0
    8000397e:	d60080e7          	jalr	-672(ra) # 800036da <brelse>
}
    80003982:	8526                	mv	a0,s1
    80003984:	60e6                	ld	ra,88(sp)
    80003986:	6446                	ld	s0,80(sp)
    80003988:	64a6                	ld	s1,72(sp)
    8000398a:	6906                	ld	s2,64(sp)
    8000398c:	79e2                	ld	s3,56(sp)
    8000398e:	7a42                	ld	s4,48(sp)
    80003990:	7aa2                	ld	s5,40(sp)
    80003992:	7b02                	ld	s6,32(sp)
    80003994:	6be2                	ld	s7,24(sp)
    80003996:	6c42                	ld	s8,16(sp)
    80003998:	6ca2                	ld	s9,8(sp)
    8000399a:	6125                	addi	sp,sp,96
    8000399c:	8082                	ret

000000008000399e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000399e:	7179                	addi	sp,sp,-48
    800039a0:	f406                	sd	ra,40(sp)
    800039a2:	f022                	sd	s0,32(sp)
    800039a4:	ec26                	sd	s1,24(sp)
    800039a6:	e84a                	sd	s2,16(sp)
    800039a8:	e44e                	sd	s3,8(sp)
    800039aa:	e052                	sd	s4,0(sp)
    800039ac:	1800                	addi	s0,sp,48
    800039ae:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800039b0:	47ad                	li	a5,11
    800039b2:	04b7fe63          	bgeu	a5,a1,80003a0e <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800039b6:	ff45849b          	addiw	s1,a1,-12
    800039ba:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800039be:	0ff00793          	li	a5,255
    800039c2:	0ae7e363          	bltu	a5,a4,80003a68 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800039c6:	08052583          	lw	a1,128(a0)
    800039ca:	c5ad                	beqz	a1,80003a34 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800039cc:	00092503          	lw	a0,0(s2)
    800039d0:	00000097          	auipc	ra,0x0
    800039d4:	bda080e7          	jalr	-1062(ra) # 800035aa <bread>
    800039d8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800039da:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800039de:	02049593          	slli	a1,s1,0x20
    800039e2:	9181                	srli	a1,a1,0x20
    800039e4:	058a                	slli	a1,a1,0x2
    800039e6:	00b784b3          	add	s1,a5,a1
    800039ea:	0004a983          	lw	s3,0(s1)
    800039ee:	04098d63          	beqz	s3,80003a48 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800039f2:	8552                	mv	a0,s4
    800039f4:	00000097          	auipc	ra,0x0
    800039f8:	ce6080e7          	jalr	-794(ra) # 800036da <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800039fc:	854e                	mv	a0,s3
    800039fe:	70a2                	ld	ra,40(sp)
    80003a00:	7402                	ld	s0,32(sp)
    80003a02:	64e2                	ld	s1,24(sp)
    80003a04:	6942                	ld	s2,16(sp)
    80003a06:	69a2                	ld	s3,8(sp)
    80003a08:	6a02                	ld	s4,0(sp)
    80003a0a:	6145                	addi	sp,sp,48
    80003a0c:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003a0e:	02059493          	slli	s1,a1,0x20
    80003a12:	9081                	srli	s1,s1,0x20
    80003a14:	048a                	slli	s1,s1,0x2
    80003a16:	94aa                	add	s1,s1,a0
    80003a18:	0504a983          	lw	s3,80(s1)
    80003a1c:	fe0990e3          	bnez	s3,800039fc <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003a20:	4108                	lw	a0,0(a0)
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	e4a080e7          	jalr	-438(ra) # 8000386c <balloc>
    80003a2a:	0005099b          	sext.w	s3,a0
    80003a2e:	0534a823          	sw	s3,80(s1)
    80003a32:	b7e9                	j	800039fc <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003a34:	4108                	lw	a0,0(a0)
    80003a36:	00000097          	auipc	ra,0x0
    80003a3a:	e36080e7          	jalr	-458(ra) # 8000386c <balloc>
    80003a3e:	0005059b          	sext.w	a1,a0
    80003a42:	08b92023          	sw	a1,128(s2)
    80003a46:	b759                	j	800039cc <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003a48:	00092503          	lw	a0,0(s2)
    80003a4c:	00000097          	auipc	ra,0x0
    80003a50:	e20080e7          	jalr	-480(ra) # 8000386c <balloc>
    80003a54:	0005099b          	sext.w	s3,a0
    80003a58:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003a5c:	8552                	mv	a0,s4
    80003a5e:	00001097          	auipc	ra,0x1
    80003a62:	ef8080e7          	jalr	-264(ra) # 80004956 <log_write>
    80003a66:	b771                	j	800039f2 <bmap+0x54>
  panic("bmap: out of range");
    80003a68:	00005517          	auipc	a0,0x5
    80003a6c:	c3850513          	addi	a0,a0,-968 # 800086a0 <syscalls+0x150>
    80003a70:	ffffd097          	auipc	ra,0xffffd
    80003a74:	ace080e7          	jalr	-1330(ra) # 8000053e <panic>

0000000080003a78 <iget>:
{
    80003a78:	7179                	addi	sp,sp,-48
    80003a7a:	f406                	sd	ra,40(sp)
    80003a7c:	f022                	sd	s0,32(sp)
    80003a7e:	ec26                	sd	s1,24(sp)
    80003a80:	e84a                	sd	s2,16(sp)
    80003a82:	e44e                	sd	s3,8(sp)
    80003a84:	e052                	sd	s4,0(sp)
    80003a86:	1800                	addi	s0,sp,48
    80003a88:	89aa                	mv	s3,a0
    80003a8a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003a8c:	0001c517          	auipc	a0,0x1c
    80003a90:	33c50513          	addi	a0,a0,828 # 8001fdc8 <itable>
    80003a94:	ffffd097          	auipc	ra,0xffffd
    80003a98:	150080e7          	jalr	336(ra) # 80000be4 <acquire>
  empty = 0;
    80003a9c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a9e:	0001c497          	auipc	s1,0x1c
    80003aa2:	34248493          	addi	s1,s1,834 # 8001fde0 <itable+0x18>
    80003aa6:	0001e697          	auipc	a3,0x1e
    80003aaa:	dca68693          	addi	a3,a3,-566 # 80021870 <log>
    80003aae:	a039                	j	80003abc <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ab0:	02090b63          	beqz	s2,80003ae6 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ab4:	08848493          	addi	s1,s1,136
    80003ab8:	02d48a63          	beq	s1,a3,80003aec <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003abc:	449c                	lw	a5,8(s1)
    80003abe:	fef059e3          	blez	a5,80003ab0 <iget+0x38>
    80003ac2:	4098                	lw	a4,0(s1)
    80003ac4:	ff3716e3          	bne	a4,s3,80003ab0 <iget+0x38>
    80003ac8:	40d8                	lw	a4,4(s1)
    80003aca:	ff4713e3          	bne	a4,s4,80003ab0 <iget+0x38>
      ip->ref++;
    80003ace:	2785                	addiw	a5,a5,1
    80003ad0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003ad2:	0001c517          	auipc	a0,0x1c
    80003ad6:	2f650513          	addi	a0,a0,758 # 8001fdc8 <itable>
    80003ada:	ffffd097          	auipc	ra,0xffffd
    80003ade:	1be080e7          	jalr	446(ra) # 80000c98 <release>
      return ip;
    80003ae2:	8926                	mv	s2,s1
    80003ae4:	a03d                	j	80003b12 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ae6:	f7f9                	bnez	a5,80003ab4 <iget+0x3c>
    80003ae8:	8926                	mv	s2,s1
    80003aea:	b7e9                	j	80003ab4 <iget+0x3c>
  if(empty == 0)
    80003aec:	02090c63          	beqz	s2,80003b24 <iget+0xac>
  ip->dev = dev;
    80003af0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003af4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003af8:	4785                	li	a5,1
    80003afa:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003afe:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003b02:	0001c517          	auipc	a0,0x1c
    80003b06:	2c650513          	addi	a0,a0,710 # 8001fdc8 <itable>
    80003b0a:	ffffd097          	auipc	ra,0xffffd
    80003b0e:	18e080e7          	jalr	398(ra) # 80000c98 <release>
}
    80003b12:	854a                	mv	a0,s2
    80003b14:	70a2                	ld	ra,40(sp)
    80003b16:	7402                	ld	s0,32(sp)
    80003b18:	64e2                	ld	s1,24(sp)
    80003b1a:	6942                	ld	s2,16(sp)
    80003b1c:	69a2                	ld	s3,8(sp)
    80003b1e:	6a02                	ld	s4,0(sp)
    80003b20:	6145                	addi	sp,sp,48
    80003b22:	8082                	ret
    panic("iget: no inodes");
    80003b24:	00005517          	auipc	a0,0x5
    80003b28:	b9450513          	addi	a0,a0,-1132 # 800086b8 <syscalls+0x168>
    80003b2c:	ffffd097          	auipc	ra,0xffffd
    80003b30:	a12080e7          	jalr	-1518(ra) # 8000053e <panic>

0000000080003b34 <fsinit>:
fsinit(int dev) {
    80003b34:	7179                	addi	sp,sp,-48
    80003b36:	f406                	sd	ra,40(sp)
    80003b38:	f022                	sd	s0,32(sp)
    80003b3a:	ec26                	sd	s1,24(sp)
    80003b3c:	e84a                	sd	s2,16(sp)
    80003b3e:	e44e                	sd	s3,8(sp)
    80003b40:	1800                	addi	s0,sp,48
    80003b42:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b44:	4585                	li	a1,1
    80003b46:	00000097          	auipc	ra,0x0
    80003b4a:	a64080e7          	jalr	-1436(ra) # 800035aa <bread>
    80003b4e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b50:	0001c997          	auipc	s3,0x1c
    80003b54:	25898993          	addi	s3,s3,600 # 8001fda8 <sb>
    80003b58:	02000613          	li	a2,32
    80003b5c:	05850593          	addi	a1,a0,88
    80003b60:	854e                	mv	a0,s3
    80003b62:	ffffd097          	auipc	ra,0xffffd
    80003b66:	1de080e7          	jalr	478(ra) # 80000d40 <memmove>
  brelse(bp);
    80003b6a:	8526                	mv	a0,s1
    80003b6c:	00000097          	auipc	ra,0x0
    80003b70:	b6e080e7          	jalr	-1170(ra) # 800036da <brelse>
  if(sb.magic != FSMAGIC)
    80003b74:	0009a703          	lw	a4,0(s3)
    80003b78:	102037b7          	lui	a5,0x10203
    80003b7c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b80:	02f71263          	bne	a4,a5,80003ba4 <fsinit+0x70>
  initlog(dev, &sb);
    80003b84:	0001c597          	auipc	a1,0x1c
    80003b88:	22458593          	addi	a1,a1,548 # 8001fda8 <sb>
    80003b8c:	854a                	mv	a0,s2
    80003b8e:	00001097          	auipc	ra,0x1
    80003b92:	b4c080e7          	jalr	-1204(ra) # 800046da <initlog>
}
    80003b96:	70a2                	ld	ra,40(sp)
    80003b98:	7402                	ld	s0,32(sp)
    80003b9a:	64e2                	ld	s1,24(sp)
    80003b9c:	6942                	ld	s2,16(sp)
    80003b9e:	69a2                	ld	s3,8(sp)
    80003ba0:	6145                	addi	sp,sp,48
    80003ba2:	8082                	ret
    panic("invalid file system");
    80003ba4:	00005517          	auipc	a0,0x5
    80003ba8:	b2450513          	addi	a0,a0,-1244 # 800086c8 <syscalls+0x178>
    80003bac:	ffffd097          	auipc	ra,0xffffd
    80003bb0:	992080e7          	jalr	-1646(ra) # 8000053e <panic>

0000000080003bb4 <iinit>:
{
    80003bb4:	7179                	addi	sp,sp,-48
    80003bb6:	f406                	sd	ra,40(sp)
    80003bb8:	f022                	sd	s0,32(sp)
    80003bba:	ec26                	sd	s1,24(sp)
    80003bbc:	e84a                	sd	s2,16(sp)
    80003bbe:	e44e                	sd	s3,8(sp)
    80003bc0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003bc2:	00005597          	auipc	a1,0x5
    80003bc6:	b1e58593          	addi	a1,a1,-1250 # 800086e0 <syscalls+0x190>
    80003bca:	0001c517          	auipc	a0,0x1c
    80003bce:	1fe50513          	addi	a0,a0,510 # 8001fdc8 <itable>
    80003bd2:	ffffd097          	auipc	ra,0xffffd
    80003bd6:	f82080e7          	jalr	-126(ra) # 80000b54 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003bda:	0001c497          	auipc	s1,0x1c
    80003bde:	21648493          	addi	s1,s1,534 # 8001fdf0 <itable+0x28>
    80003be2:	0001e997          	auipc	s3,0x1e
    80003be6:	c9e98993          	addi	s3,s3,-866 # 80021880 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003bea:	00005917          	auipc	s2,0x5
    80003bee:	afe90913          	addi	s2,s2,-1282 # 800086e8 <syscalls+0x198>
    80003bf2:	85ca                	mv	a1,s2
    80003bf4:	8526                	mv	a0,s1
    80003bf6:	00001097          	auipc	ra,0x1
    80003bfa:	e46080e7          	jalr	-442(ra) # 80004a3c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003bfe:	08848493          	addi	s1,s1,136
    80003c02:	ff3498e3          	bne	s1,s3,80003bf2 <iinit+0x3e>
}
    80003c06:	70a2                	ld	ra,40(sp)
    80003c08:	7402                	ld	s0,32(sp)
    80003c0a:	64e2                	ld	s1,24(sp)
    80003c0c:	6942                	ld	s2,16(sp)
    80003c0e:	69a2                	ld	s3,8(sp)
    80003c10:	6145                	addi	sp,sp,48
    80003c12:	8082                	ret

0000000080003c14 <ialloc>:
{
    80003c14:	715d                	addi	sp,sp,-80
    80003c16:	e486                	sd	ra,72(sp)
    80003c18:	e0a2                	sd	s0,64(sp)
    80003c1a:	fc26                	sd	s1,56(sp)
    80003c1c:	f84a                	sd	s2,48(sp)
    80003c1e:	f44e                	sd	s3,40(sp)
    80003c20:	f052                	sd	s4,32(sp)
    80003c22:	ec56                	sd	s5,24(sp)
    80003c24:	e85a                	sd	s6,16(sp)
    80003c26:	e45e                	sd	s7,8(sp)
    80003c28:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c2a:	0001c717          	auipc	a4,0x1c
    80003c2e:	18a72703          	lw	a4,394(a4) # 8001fdb4 <sb+0xc>
    80003c32:	4785                	li	a5,1
    80003c34:	04e7fa63          	bgeu	a5,a4,80003c88 <ialloc+0x74>
    80003c38:	8aaa                	mv	s5,a0
    80003c3a:	8bae                	mv	s7,a1
    80003c3c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003c3e:	0001ca17          	auipc	s4,0x1c
    80003c42:	16aa0a13          	addi	s4,s4,362 # 8001fda8 <sb>
    80003c46:	00048b1b          	sext.w	s6,s1
    80003c4a:	0044d593          	srli	a1,s1,0x4
    80003c4e:	018a2783          	lw	a5,24(s4)
    80003c52:	9dbd                	addw	a1,a1,a5
    80003c54:	8556                	mv	a0,s5
    80003c56:	00000097          	auipc	ra,0x0
    80003c5a:	954080e7          	jalr	-1708(ra) # 800035aa <bread>
    80003c5e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003c60:	05850993          	addi	s3,a0,88
    80003c64:	00f4f793          	andi	a5,s1,15
    80003c68:	079a                	slli	a5,a5,0x6
    80003c6a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003c6c:	00099783          	lh	a5,0(s3)
    80003c70:	c785                	beqz	a5,80003c98 <ialloc+0x84>
    brelse(bp);
    80003c72:	00000097          	auipc	ra,0x0
    80003c76:	a68080e7          	jalr	-1432(ra) # 800036da <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c7a:	0485                	addi	s1,s1,1
    80003c7c:	00ca2703          	lw	a4,12(s4)
    80003c80:	0004879b          	sext.w	a5,s1
    80003c84:	fce7e1e3          	bltu	a5,a4,80003c46 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003c88:	00005517          	auipc	a0,0x5
    80003c8c:	a6850513          	addi	a0,a0,-1432 # 800086f0 <syscalls+0x1a0>
    80003c90:	ffffd097          	auipc	ra,0xffffd
    80003c94:	8ae080e7          	jalr	-1874(ra) # 8000053e <panic>
      memset(dip, 0, sizeof(*dip));
    80003c98:	04000613          	li	a2,64
    80003c9c:	4581                	li	a1,0
    80003c9e:	854e                	mv	a0,s3
    80003ca0:	ffffd097          	auipc	ra,0xffffd
    80003ca4:	040080e7          	jalr	64(ra) # 80000ce0 <memset>
      dip->type = type;
    80003ca8:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003cac:	854a                	mv	a0,s2
    80003cae:	00001097          	auipc	ra,0x1
    80003cb2:	ca8080e7          	jalr	-856(ra) # 80004956 <log_write>
      brelse(bp);
    80003cb6:	854a                	mv	a0,s2
    80003cb8:	00000097          	auipc	ra,0x0
    80003cbc:	a22080e7          	jalr	-1502(ra) # 800036da <brelse>
      return iget(dev, inum);
    80003cc0:	85da                	mv	a1,s6
    80003cc2:	8556                	mv	a0,s5
    80003cc4:	00000097          	auipc	ra,0x0
    80003cc8:	db4080e7          	jalr	-588(ra) # 80003a78 <iget>
}
    80003ccc:	60a6                	ld	ra,72(sp)
    80003cce:	6406                	ld	s0,64(sp)
    80003cd0:	74e2                	ld	s1,56(sp)
    80003cd2:	7942                	ld	s2,48(sp)
    80003cd4:	79a2                	ld	s3,40(sp)
    80003cd6:	7a02                	ld	s4,32(sp)
    80003cd8:	6ae2                	ld	s5,24(sp)
    80003cda:	6b42                	ld	s6,16(sp)
    80003cdc:	6ba2                	ld	s7,8(sp)
    80003cde:	6161                	addi	sp,sp,80
    80003ce0:	8082                	ret

0000000080003ce2 <iupdate>:
{
    80003ce2:	1101                	addi	sp,sp,-32
    80003ce4:	ec06                	sd	ra,24(sp)
    80003ce6:	e822                	sd	s0,16(sp)
    80003ce8:	e426                	sd	s1,8(sp)
    80003cea:	e04a                	sd	s2,0(sp)
    80003cec:	1000                	addi	s0,sp,32
    80003cee:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cf0:	415c                	lw	a5,4(a0)
    80003cf2:	0047d79b          	srliw	a5,a5,0x4
    80003cf6:	0001c597          	auipc	a1,0x1c
    80003cfa:	0ca5a583          	lw	a1,202(a1) # 8001fdc0 <sb+0x18>
    80003cfe:	9dbd                	addw	a1,a1,a5
    80003d00:	4108                	lw	a0,0(a0)
    80003d02:	00000097          	auipc	ra,0x0
    80003d06:	8a8080e7          	jalr	-1880(ra) # 800035aa <bread>
    80003d0a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d0c:	05850793          	addi	a5,a0,88
    80003d10:	40c8                	lw	a0,4(s1)
    80003d12:	893d                	andi	a0,a0,15
    80003d14:	051a                	slli	a0,a0,0x6
    80003d16:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003d18:	04449703          	lh	a4,68(s1)
    80003d1c:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003d20:	04649703          	lh	a4,70(s1)
    80003d24:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003d28:	04849703          	lh	a4,72(s1)
    80003d2c:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003d30:	04a49703          	lh	a4,74(s1)
    80003d34:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003d38:	44f8                	lw	a4,76(s1)
    80003d3a:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003d3c:	03400613          	li	a2,52
    80003d40:	05048593          	addi	a1,s1,80
    80003d44:	0531                	addi	a0,a0,12
    80003d46:	ffffd097          	auipc	ra,0xffffd
    80003d4a:	ffa080e7          	jalr	-6(ra) # 80000d40 <memmove>
  log_write(bp);
    80003d4e:	854a                	mv	a0,s2
    80003d50:	00001097          	auipc	ra,0x1
    80003d54:	c06080e7          	jalr	-1018(ra) # 80004956 <log_write>
  brelse(bp);
    80003d58:	854a                	mv	a0,s2
    80003d5a:	00000097          	auipc	ra,0x0
    80003d5e:	980080e7          	jalr	-1664(ra) # 800036da <brelse>
}
    80003d62:	60e2                	ld	ra,24(sp)
    80003d64:	6442                	ld	s0,16(sp)
    80003d66:	64a2                	ld	s1,8(sp)
    80003d68:	6902                	ld	s2,0(sp)
    80003d6a:	6105                	addi	sp,sp,32
    80003d6c:	8082                	ret

0000000080003d6e <idup>:
{
    80003d6e:	1101                	addi	sp,sp,-32
    80003d70:	ec06                	sd	ra,24(sp)
    80003d72:	e822                	sd	s0,16(sp)
    80003d74:	e426                	sd	s1,8(sp)
    80003d76:	1000                	addi	s0,sp,32
    80003d78:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d7a:	0001c517          	auipc	a0,0x1c
    80003d7e:	04e50513          	addi	a0,a0,78 # 8001fdc8 <itable>
    80003d82:	ffffd097          	auipc	ra,0xffffd
    80003d86:	e62080e7          	jalr	-414(ra) # 80000be4 <acquire>
  ip->ref++;
    80003d8a:	449c                	lw	a5,8(s1)
    80003d8c:	2785                	addiw	a5,a5,1
    80003d8e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d90:	0001c517          	auipc	a0,0x1c
    80003d94:	03850513          	addi	a0,a0,56 # 8001fdc8 <itable>
    80003d98:	ffffd097          	auipc	ra,0xffffd
    80003d9c:	f00080e7          	jalr	-256(ra) # 80000c98 <release>
}
    80003da0:	8526                	mv	a0,s1
    80003da2:	60e2                	ld	ra,24(sp)
    80003da4:	6442                	ld	s0,16(sp)
    80003da6:	64a2                	ld	s1,8(sp)
    80003da8:	6105                	addi	sp,sp,32
    80003daa:	8082                	ret

0000000080003dac <ilock>:
{
    80003dac:	1101                	addi	sp,sp,-32
    80003dae:	ec06                	sd	ra,24(sp)
    80003db0:	e822                	sd	s0,16(sp)
    80003db2:	e426                	sd	s1,8(sp)
    80003db4:	e04a                	sd	s2,0(sp)
    80003db6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003db8:	c115                	beqz	a0,80003ddc <ilock+0x30>
    80003dba:	84aa                	mv	s1,a0
    80003dbc:	451c                	lw	a5,8(a0)
    80003dbe:	00f05f63          	blez	a5,80003ddc <ilock+0x30>
  acquiresleep(&ip->lock);
    80003dc2:	0541                	addi	a0,a0,16
    80003dc4:	00001097          	auipc	ra,0x1
    80003dc8:	cb2080e7          	jalr	-846(ra) # 80004a76 <acquiresleep>
  if(ip->valid == 0){
    80003dcc:	40bc                	lw	a5,64(s1)
    80003dce:	cf99                	beqz	a5,80003dec <ilock+0x40>
}
    80003dd0:	60e2                	ld	ra,24(sp)
    80003dd2:	6442                	ld	s0,16(sp)
    80003dd4:	64a2                	ld	s1,8(sp)
    80003dd6:	6902                	ld	s2,0(sp)
    80003dd8:	6105                	addi	sp,sp,32
    80003dda:	8082                	ret
    panic("ilock");
    80003ddc:	00005517          	auipc	a0,0x5
    80003de0:	92c50513          	addi	a0,a0,-1748 # 80008708 <syscalls+0x1b8>
    80003de4:	ffffc097          	auipc	ra,0xffffc
    80003de8:	75a080e7          	jalr	1882(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003dec:	40dc                	lw	a5,4(s1)
    80003dee:	0047d79b          	srliw	a5,a5,0x4
    80003df2:	0001c597          	auipc	a1,0x1c
    80003df6:	fce5a583          	lw	a1,-50(a1) # 8001fdc0 <sb+0x18>
    80003dfa:	9dbd                	addw	a1,a1,a5
    80003dfc:	4088                	lw	a0,0(s1)
    80003dfe:	fffff097          	auipc	ra,0xfffff
    80003e02:	7ac080e7          	jalr	1964(ra) # 800035aa <bread>
    80003e06:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e08:	05850593          	addi	a1,a0,88
    80003e0c:	40dc                	lw	a5,4(s1)
    80003e0e:	8bbd                	andi	a5,a5,15
    80003e10:	079a                	slli	a5,a5,0x6
    80003e12:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003e14:	00059783          	lh	a5,0(a1)
    80003e18:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003e1c:	00259783          	lh	a5,2(a1)
    80003e20:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003e24:	00459783          	lh	a5,4(a1)
    80003e28:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003e2c:	00659783          	lh	a5,6(a1)
    80003e30:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003e34:	459c                	lw	a5,8(a1)
    80003e36:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003e38:	03400613          	li	a2,52
    80003e3c:	05b1                	addi	a1,a1,12
    80003e3e:	05048513          	addi	a0,s1,80
    80003e42:	ffffd097          	auipc	ra,0xffffd
    80003e46:	efe080e7          	jalr	-258(ra) # 80000d40 <memmove>
    brelse(bp);
    80003e4a:	854a                	mv	a0,s2
    80003e4c:	00000097          	auipc	ra,0x0
    80003e50:	88e080e7          	jalr	-1906(ra) # 800036da <brelse>
    ip->valid = 1;
    80003e54:	4785                	li	a5,1
    80003e56:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003e58:	04449783          	lh	a5,68(s1)
    80003e5c:	fbb5                	bnez	a5,80003dd0 <ilock+0x24>
      panic("ilock: no type");
    80003e5e:	00005517          	auipc	a0,0x5
    80003e62:	8b250513          	addi	a0,a0,-1870 # 80008710 <syscalls+0x1c0>
    80003e66:	ffffc097          	auipc	ra,0xffffc
    80003e6a:	6d8080e7          	jalr	1752(ra) # 8000053e <panic>

0000000080003e6e <iunlock>:
{
    80003e6e:	1101                	addi	sp,sp,-32
    80003e70:	ec06                	sd	ra,24(sp)
    80003e72:	e822                	sd	s0,16(sp)
    80003e74:	e426                	sd	s1,8(sp)
    80003e76:	e04a                	sd	s2,0(sp)
    80003e78:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003e7a:	c905                	beqz	a0,80003eaa <iunlock+0x3c>
    80003e7c:	84aa                	mv	s1,a0
    80003e7e:	01050913          	addi	s2,a0,16
    80003e82:	854a                	mv	a0,s2
    80003e84:	00001097          	auipc	ra,0x1
    80003e88:	c8c080e7          	jalr	-884(ra) # 80004b10 <holdingsleep>
    80003e8c:	cd19                	beqz	a0,80003eaa <iunlock+0x3c>
    80003e8e:	449c                	lw	a5,8(s1)
    80003e90:	00f05d63          	blez	a5,80003eaa <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003e94:	854a                	mv	a0,s2
    80003e96:	00001097          	auipc	ra,0x1
    80003e9a:	c36080e7          	jalr	-970(ra) # 80004acc <releasesleep>
}
    80003e9e:	60e2                	ld	ra,24(sp)
    80003ea0:	6442                	ld	s0,16(sp)
    80003ea2:	64a2                	ld	s1,8(sp)
    80003ea4:	6902                	ld	s2,0(sp)
    80003ea6:	6105                	addi	sp,sp,32
    80003ea8:	8082                	ret
    panic("iunlock");
    80003eaa:	00005517          	auipc	a0,0x5
    80003eae:	87650513          	addi	a0,a0,-1930 # 80008720 <syscalls+0x1d0>
    80003eb2:	ffffc097          	auipc	ra,0xffffc
    80003eb6:	68c080e7          	jalr	1676(ra) # 8000053e <panic>

0000000080003eba <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003eba:	7179                	addi	sp,sp,-48
    80003ebc:	f406                	sd	ra,40(sp)
    80003ebe:	f022                	sd	s0,32(sp)
    80003ec0:	ec26                	sd	s1,24(sp)
    80003ec2:	e84a                	sd	s2,16(sp)
    80003ec4:	e44e                	sd	s3,8(sp)
    80003ec6:	e052                	sd	s4,0(sp)
    80003ec8:	1800                	addi	s0,sp,48
    80003eca:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003ecc:	05050493          	addi	s1,a0,80
    80003ed0:	08050913          	addi	s2,a0,128
    80003ed4:	a021                	j	80003edc <itrunc+0x22>
    80003ed6:	0491                	addi	s1,s1,4
    80003ed8:	01248d63          	beq	s1,s2,80003ef2 <itrunc+0x38>
    if(ip->addrs[i]){
    80003edc:	408c                	lw	a1,0(s1)
    80003ede:	dde5                	beqz	a1,80003ed6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003ee0:	0009a503          	lw	a0,0(s3)
    80003ee4:	00000097          	auipc	ra,0x0
    80003ee8:	90c080e7          	jalr	-1780(ra) # 800037f0 <bfree>
      ip->addrs[i] = 0;
    80003eec:	0004a023          	sw	zero,0(s1)
    80003ef0:	b7dd                	j	80003ed6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ef2:	0809a583          	lw	a1,128(s3)
    80003ef6:	e185                	bnez	a1,80003f16 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ef8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003efc:	854e                	mv	a0,s3
    80003efe:	00000097          	auipc	ra,0x0
    80003f02:	de4080e7          	jalr	-540(ra) # 80003ce2 <iupdate>
}
    80003f06:	70a2                	ld	ra,40(sp)
    80003f08:	7402                	ld	s0,32(sp)
    80003f0a:	64e2                	ld	s1,24(sp)
    80003f0c:	6942                	ld	s2,16(sp)
    80003f0e:	69a2                	ld	s3,8(sp)
    80003f10:	6a02                	ld	s4,0(sp)
    80003f12:	6145                	addi	sp,sp,48
    80003f14:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003f16:	0009a503          	lw	a0,0(s3)
    80003f1a:	fffff097          	auipc	ra,0xfffff
    80003f1e:	690080e7          	jalr	1680(ra) # 800035aa <bread>
    80003f22:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003f24:	05850493          	addi	s1,a0,88
    80003f28:	45850913          	addi	s2,a0,1112
    80003f2c:	a811                	j	80003f40 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003f2e:	0009a503          	lw	a0,0(s3)
    80003f32:	00000097          	auipc	ra,0x0
    80003f36:	8be080e7          	jalr	-1858(ra) # 800037f0 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003f3a:	0491                	addi	s1,s1,4
    80003f3c:	01248563          	beq	s1,s2,80003f46 <itrunc+0x8c>
      if(a[j])
    80003f40:	408c                	lw	a1,0(s1)
    80003f42:	dde5                	beqz	a1,80003f3a <itrunc+0x80>
    80003f44:	b7ed                	j	80003f2e <itrunc+0x74>
    brelse(bp);
    80003f46:	8552                	mv	a0,s4
    80003f48:	fffff097          	auipc	ra,0xfffff
    80003f4c:	792080e7          	jalr	1938(ra) # 800036da <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003f50:	0809a583          	lw	a1,128(s3)
    80003f54:	0009a503          	lw	a0,0(s3)
    80003f58:	00000097          	auipc	ra,0x0
    80003f5c:	898080e7          	jalr	-1896(ra) # 800037f0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003f60:	0809a023          	sw	zero,128(s3)
    80003f64:	bf51                	j	80003ef8 <itrunc+0x3e>

0000000080003f66 <iput>:
{
    80003f66:	1101                	addi	sp,sp,-32
    80003f68:	ec06                	sd	ra,24(sp)
    80003f6a:	e822                	sd	s0,16(sp)
    80003f6c:	e426                	sd	s1,8(sp)
    80003f6e:	e04a                	sd	s2,0(sp)
    80003f70:	1000                	addi	s0,sp,32
    80003f72:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f74:	0001c517          	auipc	a0,0x1c
    80003f78:	e5450513          	addi	a0,a0,-428 # 8001fdc8 <itable>
    80003f7c:	ffffd097          	auipc	ra,0xffffd
    80003f80:	c68080e7          	jalr	-920(ra) # 80000be4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f84:	4498                	lw	a4,8(s1)
    80003f86:	4785                	li	a5,1
    80003f88:	02f70363          	beq	a4,a5,80003fae <iput+0x48>
  ip->ref--;
    80003f8c:	449c                	lw	a5,8(s1)
    80003f8e:	37fd                	addiw	a5,a5,-1
    80003f90:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f92:	0001c517          	auipc	a0,0x1c
    80003f96:	e3650513          	addi	a0,a0,-458 # 8001fdc8 <itable>
    80003f9a:	ffffd097          	auipc	ra,0xffffd
    80003f9e:	cfe080e7          	jalr	-770(ra) # 80000c98 <release>
}
    80003fa2:	60e2                	ld	ra,24(sp)
    80003fa4:	6442                	ld	s0,16(sp)
    80003fa6:	64a2                	ld	s1,8(sp)
    80003fa8:	6902                	ld	s2,0(sp)
    80003faa:	6105                	addi	sp,sp,32
    80003fac:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003fae:	40bc                	lw	a5,64(s1)
    80003fb0:	dff1                	beqz	a5,80003f8c <iput+0x26>
    80003fb2:	04a49783          	lh	a5,74(s1)
    80003fb6:	fbf9                	bnez	a5,80003f8c <iput+0x26>
    acquiresleep(&ip->lock);
    80003fb8:	01048913          	addi	s2,s1,16
    80003fbc:	854a                	mv	a0,s2
    80003fbe:	00001097          	auipc	ra,0x1
    80003fc2:	ab8080e7          	jalr	-1352(ra) # 80004a76 <acquiresleep>
    release(&itable.lock);
    80003fc6:	0001c517          	auipc	a0,0x1c
    80003fca:	e0250513          	addi	a0,a0,-510 # 8001fdc8 <itable>
    80003fce:	ffffd097          	auipc	ra,0xffffd
    80003fd2:	cca080e7          	jalr	-822(ra) # 80000c98 <release>
    itrunc(ip);
    80003fd6:	8526                	mv	a0,s1
    80003fd8:	00000097          	auipc	ra,0x0
    80003fdc:	ee2080e7          	jalr	-286(ra) # 80003eba <itrunc>
    ip->type = 0;
    80003fe0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003fe4:	8526                	mv	a0,s1
    80003fe6:	00000097          	auipc	ra,0x0
    80003fea:	cfc080e7          	jalr	-772(ra) # 80003ce2 <iupdate>
    ip->valid = 0;
    80003fee:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ff2:	854a                	mv	a0,s2
    80003ff4:	00001097          	auipc	ra,0x1
    80003ff8:	ad8080e7          	jalr	-1320(ra) # 80004acc <releasesleep>
    acquire(&itable.lock);
    80003ffc:	0001c517          	auipc	a0,0x1c
    80004000:	dcc50513          	addi	a0,a0,-564 # 8001fdc8 <itable>
    80004004:	ffffd097          	auipc	ra,0xffffd
    80004008:	be0080e7          	jalr	-1056(ra) # 80000be4 <acquire>
    8000400c:	b741                	j	80003f8c <iput+0x26>

000000008000400e <iunlockput>:
{
    8000400e:	1101                	addi	sp,sp,-32
    80004010:	ec06                	sd	ra,24(sp)
    80004012:	e822                	sd	s0,16(sp)
    80004014:	e426                	sd	s1,8(sp)
    80004016:	1000                	addi	s0,sp,32
    80004018:	84aa                	mv	s1,a0
  iunlock(ip);
    8000401a:	00000097          	auipc	ra,0x0
    8000401e:	e54080e7          	jalr	-428(ra) # 80003e6e <iunlock>
  iput(ip);
    80004022:	8526                	mv	a0,s1
    80004024:	00000097          	auipc	ra,0x0
    80004028:	f42080e7          	jalr	-190(ra) # 80003f66 <iput>
}
    8000402c:	60e2                	ld	ra,24(sp)
    8000402e:	6442                	ld	s0,16(sp)
    80004030:	64a2                	ld	s1,8(sp)
    80004032:	6105                	addi	sp,sp,32
    80004034:	8082                	ret

0000000080004036 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004036:	1141                	addi	sp,sp,-16
    80004038:	e422                	sd	s0,8(sp)
    8000403a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000403c:	411c                	lw	a5,0(a0)
    8000403e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004040:	415c                	lw	a5,4(a0)
    80004042:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004044:	04451783          	lh	a5,68(a0)
    80004048:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000404c:	04a51783          	lh	a5,74(a0)
    80004050:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004054:	04c56783          	lwu	a5,76(a0)
    80004058:	e99c                	sd	a5,16(a1)
}
    8000405a:	6422                	ld	s0,8(sp)
    8000405c:	0141                	addi	sp,sp,16
    8000405e:	8082                	ret

0000000080004060 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004060:	457c                	lw	a5,76(a0)
    80004062:	0ed7e963          	bltu	a5,a3,80004154 <readi+0xf4>
{
    80004066:	7159                	addi	sp,sp,-112
    80004068:	f486                	sd	ra,104(sp)
    8000406a:	f0a2                	sd	s0,96(sp)
    8000406c:	eca6                	sd	s1,88(sp)
    8000406e:	e8ca                	sd	s2,80(sp)
    80004070:	e4ce                	sd	s3,72(sp)
    80004072:	e0d2                	sd	s4,64(sp)
    80004074:	fc56                	sd	s5,56(sp)
    80004076:	f85a                	sd	s6,48(sp)
    80004078:	f45e                	sd	s7,40(sp)
    8000407a:	f062                	sd	s8,32(sp)
    8000407c:	ec66                	sd	s9,24(sp)
    8000407e:	e86a                	sd	s10,16(sp)
    80004080:	e46e                	sd	s11,8(sp)
    80004082:	1880                	addi	s0,sp,112
    80004084:	8baa                	mv	s7,a0
    80004086:	8c2e                	mv	s8,a1
    80004088:	8ab2                	mv	s5,a2
    8000408a:	84b6                	mv	s1,a3
    8000408c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000408e:	9f35                	addw	a4,a4,a3
    return 0;
    80004090:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004092:	0ad76063          	bltu	a4,a3,80004132 <readi+0xd2>
  if(off + n > ip->size)
    80004096:	00e7f463          	bgeu	a5,a4,8000409e <readi+0x3e>
    n = ip->size - off;
    8000409a:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000409e:	0a0b0963          	beqz	s6,80004150 <readi+0xf0>
    800040a2:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800040a4:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800040a8:	5cfd                	li	s9,-1
    800040aa:	a82d                	j	800040e4 <readi+0x84>
    800040ac:	020a1d93          	slli	s11,s4,0x20
    800040b0:	020ddd93          	srli	s11,s11,0x20
    800040b4:	05890613          	addi	a2,s2,88
    800040b8:	86ee                	mv	a3,s11
    800040ba:	963a                	add	a2,a2,a4
    800040bc:	85d6                	mv	a1,s5
    800040be:	8562                	mv	a0,s8
    800040c0:	ffffe097          	auipc	ra,0xffffe
    800040c4:	6ac080e7          	jalr	1708(ra) # 8000276c <either_copyout>
    800040c8:	05950d63          	beq	a0,s9,80004122 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800040cc:	854a                	mv	a0,s2
    800040ce:	fffff097          	auipc	ra,0xfffff
    800040d2:	60c080e7          	jalr	1548(ra) # 800036da <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040d6:	013a09bb          	addw	s3,s4,s3
    800040da:	009a04bb          	addw	s1,s4,s1
    800040de:	9aee                	add	s5,s5,s11
    800040e0:	0569f763          	bgeu	s3,s6,8000412e <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800040e4:	000ba903          	lw	s2,0(s7)
    800040e8:	00a4d59b          	srliw	a1,s1,0xa
    800040ec:	855e                	mv	a0,s7
    800040ee:	00000097          	auipc	ra,0x0
    800040f2:	8b0080e7          	jalr	-1872(ra) # 8000399e <bmap>
    800040f6:	0005059b          	sext.w	a1,a0
    800040fa:	854a                	mv	a0,s2
    800040fc:	fffff097          	auipc	ra,0xfffff
    80004100:	4ae080e7          	jalr	1198(ra) # 800035aa <bread>
    80004104:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004106:	3ff4f713          	andi	a4,s1,1023
    8000410a:	40ed07bb          	subw	a5,s10,a4
    8000410e:	413b06bb          	subw	a3,s6,s3
    80004112:	8a3e                	mv	s4,a5
    80004114:	2781                	sext.w	a5,a5
    80004116:	0006861b          	sext.w	a2,a3
    8000411a:	f8f679e3          	bgeu	a2,a5,800040ac <readi+0x4c>
    8000411e:	8a36                	mv	s4,a3
    80004120:	b771                	j	800040ac <readi+0x4c>
      brelse(bp);
    80004122:	854a                	mv	a0,s2
    80004124:	fffff097          	auipc	ra,0xfffff
    80004128:	5b6080e7          	jalr	1462(ra) # 800036da <brelse>
      tot = -1;
    8000412c:	59fd                	li	s3,-1
  }
  return tot;
    8000412e:	0009851b          	sext.w	a0,s3
}
    80004132:	70a6                	ld	ra,104(sp)
    80004134:	7406                	ld	s0,96(sp)
    80004136:	64e6                	ld	s1,88(sp)
    80004138:	6946                	ld	s2,80(sp)
    8000413a:	69a6                	ld	s3,72(sp)
    8000413c:	6a06                	ld	s4,64(sp)
    8000413e:	7ae2                	ld	s5,56(sp)
    80004140:	7b42                	ld	s6,48(sp)
    80004142:	7ba2                	ld	s7,40(sp)
    80004144:	7c02                	ld	s8,32(sp)
    80004146:	6ce2                	ld	s9,24(sp)
    80004148:	6d42                	ld	s10,16(sp)
    8000414a:	6da2                	ld	s11,8(sp)
    8000414c:	6165                	addi	sp,sp,112
    8000414e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004150:	89da                	mv	s3,s6
    80004152:	bff1                	j	8000412e <readi+0xce>
    return 0;
    80004154:	4501                	li	a0,0
}
    80004156:	8082                	ret

0000000080004158 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004158:	457c                	lw	a5,76(a0)
    8000415a:	10d7e863          	bltu	a5,a3,8000426a <writei+0x112>
{
    8000415e:	7159                	addi	sp,sp,-112
    80004160:	f486                	sd	ra,104(sp)
    80004162:	f0a2                	sd	s0,96(sp)
    80004164:	eca6                	sd	s1,88(sp)
    80004166:	e8ca                	sd	s2,80(sp)
    80004168:	e4ce                	sd	s3,72(sp)
    8000416a:	e0d2                	sd	s4,64(sp)
    8000416c:	fc56                	sd	s5,56(sp)
    8000416e:	f85a                	sd	s6,48(sp)
    80004170:	f45e                	sd	s7,40(sp)
    80004172:	f062                	sd	s8,32(sp)
    80004174:	ec66                	sd	s9,24(sp)
    80004176:	e86a                	sd	s10,16(sp)
    80004178:	e46e                	sd	s11,8(sp)
    8000417a:	1880                	addi	s0,sp,112
    8000417c:	8b2a                	mv	s6,a0
    8000417e:	8c2e                	mv	s8,a1
    80004180:	8ab2                	mv	s5,a2
    80004182:	8936                	mv	s2,a3
    80004184:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004186:	00e687bb          	addw	a5,a3,a4
    8000418a:	0ed7e263          	bltu	a5,a3,8000426e <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000418e:	00043737          	lui	a4,0x43
    80004192:	0ef76063          	bltu	a4,a5,80004272 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004196:	0c0b8863          	beqz	s7,80004266 <writei+0x10e>
    8000419a:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000419c:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800041a0:	5cfd                	li	s9,-1
    800041a2:	a091                	j	800041e6 <writei+0x8e>
    800041a4:	02099d93          	slli	s11,s3,0x20
    800041a8:	020ddd93          	srli	s11,s11,0x20
    800041ac:	05848513          	addi	a0,s1,88
    800041b0:	86ee                	mv	a3,s11
    800041b2:	8656                	mv	a2,s5
    800041b4:	85e2                	mv	a1,s8
    800041b6:	953a                	add	a0,a0,a4
    800041b8:	ffffe097          	auipc	ra,0xffffe
    800041bc:	60a080e7          	jalr	1546(ra) # 800027c2 <either_copyin>
    800041c0:	07950263          	beq	a0,s9,80004224 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800041c4:	8526                	mv	a0,s1
    800041c6:	00000097          	auipc	ra,0x0
    800041ca:	790080e7          	jalr	1936(ra) # 80004956 <log_write>
    brelse(bp);
    800041ce:	8526                	mv	a0,s1
    800041d0:	fffff097          	auipc	ra,0xfffff
    800041d4:	50a080e7          	jalr	1290(ra) # 800036da <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041d8:	01498a3b          	addw	s4,s3,s4
    800041dc:	0129893b          	addw	s2,s3,s2
    800041e0:	9aee                	add	s5,s5,s11
    800041e2:	057a7663          	bgeu	s4,s7,8000422e <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800041e6:	000b2483          	lw	s1,0(s6)
    800041ea:	00a9559b          	srliw	a1,s2,0xa
    800041ee:	855a                	mv	a0,s6
    800041f0:	fffff097          	auipc	ra,0xfffff
    800041f4:	7ae080e7          	jalr	1966(ra) # 8000399e <bmap>
    800041f8:	0005059b          	sext.w	a1,a0
    800041fc:	8526                	mv	a0,s1
    800041fe:	fffff097          	auipc	ra,0xfffff
    80004202:	3ac080e7          	jalr	940(ra) # 800035aa <bread>
    80004206:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004208:	3ff97713          	andi	a4,s2,1023
    8000420c:	40ed07bb          	subw	a5,s10,a4
    80004210:	414b86bb          	subw	a3,s7,s4
    80004214:	89be                	mv	s3,a5
    80004216:	2781                	sext.w	a5,a5
    80004218:	0006861b          	sext.w	a2,a3
    8000421c:	f8f674e3          	bgeu	a2,a5,800041a4 <writei+0x4c>
    80004220:	89b6                	mv	s3,a3
    80004222:	b749                	j	800041a4 <writei+0x4c>
      brelse(bp);
    80004224:	8526                	mv	a0,s1
    80004226:	fffff097          	auipc	ra,0xfffff
    8000422a:	4b4080e7          	jalr	1204(ra) # 800036da <brelse>
  }

  if(off > ip->size)
    8000422e:	04cb2783          	lw	a5,76(s6)
    80004232:	0127f463          	bgeu	a5,s2,8000423a <writei+0xe2>
    ip->size = off;
    80004236:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000423a:	855a                	mv	a0,s6
    8000423c:	00000097          	auipc	ra,0x0
    80004240:	aa6080e7          	jalr	-1370(ra) # 80003ce2 <iupdate>

  return tot;
    80004244:	000a051b          	sext.w	a0,s4
}
    80004248:	70a6                	ld	ra,104(sp)
    8000424a:	7406                	ld	s0,96(sp)
    8000424c:	64e6                	ld	s1,88(sp)
    8000424e:	6946                	ld	s2,80(sp)
    80004250:	69a6                	ld	s3,72(sp)
    80004252:	6a06                	ld	s4,64(sp)
    80004254:	7ae2                	ld	s5,56(sp)
    80004256:	7b42                	ld	s6,48(sp)
    80004258:	7ba2                	ld	s7,40(sp)
    8000425a:	7c02                	ld	s8,32(sp)
    8000425c:	6ce2                	ld	s9,24(sp)
    8000425e:	6d42                	ld	s10,16(sp)
    80004260:	6da2                	ld	s11,8(sp)
    80004262:	6165                	addi	sp,sp,112
    80004264:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004266:	8a5e                	mv	s4,s7
    80004268:	bfc9                	j	8000423a <writei+0xe2>
    return -1;
    8000426a:	557d                	li	a0,-1
}
    8000426c:	8082                	ret
    return -1;
    8000426e:	557d                	li	a0,-1
    80004270:	bfe1                	j	80004248 <writei+0xf0>
    return -1;
    80004272:	557d                	li	a0,-1
    80004274:	bfd1                	j	80004248 <writei+0xf0>

0000000080004276 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004276:	1141                	addi	sp,sp,-16
    80004278:	e406                	sd	ra,8(sp)
    8000427a:	e022                	sd	s0,0(sp)
    8000427c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000427e:	4639                	li	a2,14
    80004280:	ffffd097          	auipc	ra,0xffffd
    80004284:	b38080e7          	jalr	-1224(ra) # 80000db8 <strncmp>
}
    80004288:	60a2                	ld	ra,8(sp)
    8000428a:	6402                	ld	s0,0(sp)
    8000428c:	0141                	addi	sp,sp,16
    8000428e:	8082                	ret

0000000080004290 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004290:	7139                	addi	sp,sp,-64
    80004292:	fc06                	sd	ra,56(sp)
    80004294:	f822                	sd	s0,48(sp)
    80004296:	f426                	sd	s1,40(sp)
    80004298:	f04a                	sd	s2,32(sp)
    8000429a:	ec4e                	sd	s3,24(sp)
    8000429c:	e852                	sd	s4,16(sp)
    8000429e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800042a0:	04451703          	lh	a4,68(a0)
    800042a4:	4785                	li	a5,1
    800042a6:	00f71a63          	bne	a4,a5,800042ba <dirlookup+0x2a>
    800042aa:	892a                	mv	s2,a0
    800042ac:	89ae                	mv	s3,a1
    800042ae:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800042b0:	457c                	lw	a5,76(a0)
    800042b2:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800042b4:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042b6:	e79d                	bnez	a5,800042e4 <dirlookup+0x54>
    800042b8:	a8a5                	j	80004330 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800042ba:	00004517          	auipc	a0,0x4
    800042be:	46e50513          	addi	a0,a0,1134 # 80008728 <syscalls+0x1d8>
    800042c2:	ffffc097          	auipc	ra,0xffffc
    800042c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
      panic("dirlookup read");
    800042ca:	00004517          	auipc	a0,0x4
    800042ce:	47650513          	addi	a0,a0,1142 # 80008740 <syscalls+0x1f0>
    800042d2:	ffffc097          	auipc	ra,0xffffc
    800042d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042da:	24c1                	addiw	s1,s1,16
    800042dc:	04c92783          	lw	a5,76(s2)
    800042e0:	04f4f763          	bgeu	s1,a5,8000432e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042e4:	4741                	li	a4,16
    800042e6:	86a6                	mv	a3,s1
    800042e8:	fc040613          	addi	a2,s0,-64
    800042ec:	4581                	li	a1,0
    800042ee:	854a                	mv	a0,s2
    800042f0:	00000097          	auipc	ra,0x0
    800042f4:	d70080e7          	jalr	-656(ra) # 80004060 <readi>
    800042f8:	47c1                	li	a5,16
    800042fa:	fcf518e3          	bne	a0,a5,800042ca <dirlookup+0x3a>
    if(de.inum == 0)
    800042fe:	fc045783          	lhu	a5,-64(s0)
    80004302:	dfe1                	beqz	a5,800042da <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004304:	fc240593          	addi	a1,s0,-62
    80004308:	854e                	mv	a0,s3
    8000430a:	00000097          	auipc	ra,0x0
    8000430e:	f6c080e7          	jalr	-148(ra) # 80004276 <namecmp>
    80004312:	f561                	bnez	a0,800042da <dirlookup+0x4a>
      if(poff)
    80004314:	000a0463          	beqz	s4,8000431c <dirlookup+0x8c>
        *poff = off;
    80004318:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000431c:	fc045583          	lhu	a1,-64(s0)
    80004320:	00092503          	lw	a0,0(s2)
    80004324:	fffff097          	auipc	ra,0xfffff
    80004328:	754080e7          	jalr	1876(ra) # 80003a78 <iget>
    8000432c:	a011                	j	80004330 <dirlookup+0xa0>
  return 0;
    8000432e:	4501                	li	a0,0
}
    80004330:	70e2                	ld	ra,56(sp)
    80004332:	7442                	ld	s0,48(sp)
    80004334:	74a2                	ld	s1,40(sp)
    80004336:	7902                	ld	s2,32(sp)
    80004338:	69e2                	ld	s3,24(sp)
    8000433a:	6a42                	ld	s4,16(sp)
    8000433c:	6121                	addi	sp,sp,64
    8000433e:	8082                	ret

0000000080004340 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004340:	711d                	addi	sp,sp,-96
    80004342:	ec86                	sd	ra,88(sp)
    80004344:	e8a2                	sd	s0,80(sp)
    80004346:	e4a6                	sd	s1,72(sp)
    80004348:	e0ca                	sd	s2,64(sp)
    8000434a:	fc4e                	sd	s3,56(sp)
    8000434c:	f852                	sd	s4,48(sp)
    8000434e:	f456                	sd	s5,40(sp)
    80004350:	f05a                	sd	s6,32(sp)
    80004352:	ec5e                	sd	s7,24(sp)
    80004354:	e862                	sd	s8,16(sp)
    80004356:	e466                	sd	s9,8(sp)
    80004358:	1080                	addi	s0,sp,96
    8000435a:	84aa                	mv	s1,a0
    8000435c:	8b2e                	mv	s6,a1
    8000435e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004360:	00054703          	lbu	a4,0(a0)
    80004364:	02f00793          	li	a5,47
    80004368:	02f70363          	beq	a4,a5,8000438e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000436c:	ffffd097          	auipc	ra,0xffffd
    80004370:	644080e7          	jalr	1604(ra) # 800019b0 <myproc>
    80004374:	15053503          	ld	a0,336(a0)
    80004378:	00000097          	auipc	ra,0x0
    8000437c:	9f6080e7          	jalr	-1546(ra) # 80003d6e <idup>
    80004380:	89aa                	mv	s3,a0
  while(*path == '/')
    80004382:	02f00913          	li	s2,47
  len = path - s;
    80004386:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004388:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000438a:	4c05                	li	s8,1
    8000438c:	a865                	j	80004444 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000438e:	4585                	li	a1,1
    80004390:	4505                	li	a0,1
    80004392:	fffff097          	auipc	ra,0xfffff
    80004396:	6e6080e7          	jalr	1766(ra) # 80003a78 <iget>
    8000439a:	89aa                	mv	s3,a0
    8000439c:	b7dd                	j	80004382 <namex+0x42>
      iunlockput(ip);
    8000439e:	854e                	mv	a0,s3
    800043a0:	00000097          	auipc	ra,0x0
    800043a4:	c6e080e7          	jalr	-914(ra) # 8000400e <iunlockput>
      return 0;
    800043a8:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800043aa:	854e                	mv	a0,s3
    800043ac:	60e6                	ld	ra,88(sp)
    800043ae:	6446                	ld	s0,80(sp)
    800043b0:	64a6                	ld	s1,72(sp)
    800043b2:	6906                	ld	s2,64(sp)
    800043b4:	79e2                	ld	s3,56(sp)
    800043b6:	7a42                	ld	s4,48(sp)
    800043b8:	7aa2                	ld	s5,40(sp)
    800043ba:	7b02                	ld	s6,32(sp)
    800043bc:	6be2                	ld	s7,24(sp)
    800043be:	6c42                	ld	s8,16(sp)
    800043c0:	6ca2                	ld	s9,8(sp)
    800043c2:	6125                	addi	sp,sp,96
    800043c4:	8082                	ret
      iunlock(ip);
    800043c6:	854e                	mv	a0,s3
    800043c8:	00000097          	auipc	ra,0x0
    800043cc:	aa6080e7          	jalr	-1370(ra) # 80003e6e <iunlock>
      return ip;
    800043d0:	bfe9                	j	800043aa <namex+0x6a>
      iunlockput(ip);
    800043d2:	854e                	mv	a0,s3
    800043d4:	00000097          	auipc	ra,0x0
    800043d8:	c3a080e7          	jalr	-966(ra) # 8000400e <iunlockput>
      return 0;
    800043dc:	89d2                	mv	s3,s4
    800043de:	b7f1                	j	800043aa <namex+0x6a>
  len = path - s;
    800043e0:	40b48633          	sub	a2,s1,a1
    800043e4:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800043e8:	094cd463          	bge	s9,s4,80004470 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800043ec:	4639                	li	a2,14
    800043ee:	8556                	mv	a0,s5
    800043f0:	ffffd097          	auipc	ra,0xffffd
    800043f4:	950080e7          	jalr	-1712(ra) # 80000d40 <memmove>
  while(*path == '/')
    800043f8:	0004c783          	lbu	a5,0(s1)
    800043fc:	01279763          	bne	a5,s2,8000440a <namex+0xca>
    path++;
    80004400:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004402:	0004c783          	lbu	a5,0(s1)
    80004406:	ff278de3          	beq	a5,s2,80004400 <namex+0xc0>
    ilock(ip);
    8000440a:	854e                	mv	a0,s3
    8000440c:	00000097          	auipc	ra,0x0
    80004410:	9a0080e7          	jalr	-1632(ra) # 80003dac <ilock>
    if(ip->type != T_DIR){
    80004414:	04499783          	lh	a5,68(s3)
    80004418:	f98793e3          	bne	a5,s8,8000439e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000441c:	000b0563          	beqz	s6,80004426 <namex+0xe6>
    80004420:	0004c783          	lbu	a5,0(s1)
    80004424:	d3cd                	beqz	a5,800043c6 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004426:	865e                	mv	a2,s7
    80004428:	85d6                	mv	a1,s5
    8000442a:	854e                	mv	a0,s3
    8000442c:	00000097          	auipc	ra,0x0
    80004430:	e64080e7          	jalr	-412(ra) # 80004290 <dirlookup>
    80004434:	8a2a                	mv	s4,a0
    80004436:	dd51                	beqz	a0,800043d2 <namex+0x92>
    iunlockput(ip);
    80004438:	854e                	mv	a0,s3
    8000443a:	00000097          	auipc	ra,0x0
    8000443e:	bd4080e7          	jalr	-1068(ra) # 8000400e <iunlockput>
    ip = next;
    80004442:	89d2                	mv	s3,s4
  while(*path == '/')
    80004444:	0004c783          	lbu	a5,0(s1)
    80004448:	05279763          	bne	a5,s2,80004496 <namex+0x156>
    path++;
    8000444c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000444e:	0004c783          	lbu	a5,0(s1)
    80004452:	ff278de3          	beq	a5,s2,8000444c <namex+0x10c>
  if(*path == 0)
    80004456:	c79d                	beqz	a5,80004484 <namex+0x144>
    path++;
    80004458:	85a6                	mv	a1,s1
  len = path - s;
    8000445a:	8a5e                	mv	s4,s7
    8000445c:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000445e:	01278963          	beq	a5,s2,80004470 <namex+0x130>
    80004462:	dfbd                	beqz	a5,800043e0 <namex+0xa0>
    path++;
    80004464:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004466:	0004c783          	lbu	a5,0(s1)
    8000446a:	ff279ce3          	bne	a5,s2,80004462 <namex+0x122>
    8000446e:	bf8d                	j	800043e0 <namex+0xa0>
    memmove(name, s, len);
    80004470:	2601                	sext.w	a2,a2
    80004472:	8556                	mv	a0,s5
    80004474:	ffffd097          	auipc	ra,0xffffd
    80004478:	8cc080e7          	jalr	-1844(ra) # 80000d40 <memmove>
    name[len] = 0;
    8000447c:	9a56                	add	s4,s4,s5
    8000447e:	000a0023          	sb	zero,0(s4)
    80004482:	bf9d                	j	800043f8 <namex+0xb8>
  if(nameiparent){
    80004484:	f20b03e3          	beqz	s6,800043aa <namex+0x6a>
    iput(ip);
    80004488:	854e                	mv	a0,s3
    8000448a:	00000097          	auipc	ra,0x0
    8000448e:	adc080e7          	jalr	-1316(ra) # 80003f66 <iput>
    return 0;
    80004492:	4981                	li	s3,0
    80004494:	bf19                	j	800043aa <namex+0x6a>
  if(*path == 0)
    80004496:	d7fd                	beqz	a5,80004484 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004498:	0004c783          	lbu	a5,0(s1)
    8000449c:	85a6                	mv	a1,s1
    8000449e:	b7d1                	j	80004462 <namex+0x122>

00000000800044a0 <dirlink>:
{
    800044a0:	7139                	addi	sp,sp,-64
    800044a2:	fc06                	sd	ra,56(sp)
    800044a4:	f822                	sd	s0,48(sp)
    800044a6:	f426                	sd	s1,40(sp)
    800044a8:	f04a                	sd	s2,32(sp)
    800044aa:	ec4e                	sd	s3,24(sp)
    800044ac:	e852                	sd	s4,16(sp)
    800044ae:	0080                	addi	s0,sp,64
    800044b0:	892a                	mv	s2,a0
    800044b2:	8a2e                	mv	s4,a1
    800044b4:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800044b6:	4601                	li	a2,0
    800044b8:	00000097          	auipc	ra,0x0
    800044bc:	dd8080e7          	jalr	-552(ra) # 80004290 <dirlookup>
    800044c0:	e93d                	bnez	a0,80004536 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044c2:	04c92483          	lw	s1,76(s2)
    800044c6:	c49d                	beqz	s1,800044f4 <dirlink+0x54>
    800044c8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044ca:	4741                	li	a4,16
    800044cc:	86a6                	mv	a3,s1
    800044ce:	fc040613          	addi	a2,s0,-64
    800044d2:	4581                	li	a1,0
    800044d4:	854a                	mv	a0,s2
    800044d6:	00000097          	auipc	ra,0x0
    800044da:	b8a080e7          	jalr	-1142(ra) # 80004060 <readi>
    800044de:	47c1                	li	a5,16
    800044e0:	06f51163          	bne	a0,a5,80004542 <dirlink+0xa2>
    if(de.inum == 0)
    800044e4:	fc045783          	lhu	a5,-64(s0)
    800044e8:	c791                	beqz	a5,800044f4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044ea:	24c1                	addiw	s1,s1,16
    800044ec:	04c92783          	lw	a5,76(s2)
    800044f0:	fcf4ede3          	bltu	s1,a5,800044ca <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800044f4:	4639                	li	a2,14
    800044f6:	85d2                	mv	a1,s4
    800044f8:	fc240513          	addi	a0,s0,-62
    800044fc:	ffffd097          	auipc	ra,0xffffd
    80004500:	8f8080e7          	jalr	-1800(ra) # 80000df4 <strncpy>
  de.inum = inum;
    80004504:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004508:	4741                	li	a4,16
    8000450a:	86a6                	mv	a3,s1
    8000450c:	fc040613          	addi	a2,s0,-64
    80004510:	4581                	li	a1,0
    80004512:	854a                	mv	a0,s2
    80004514:	00000097          	auipc	ra,0x0
    80004518:	c44080e7          	jalr	-956(ra) # 80004158 <writei>
    8000451c:	872a                	mv	a4,a0
    8000451e:	47c1                	li	a5,16
  return 0;
    80004520:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004522:	02f71863          	bne	a4,a5,80004552 <dirlink+0xb2>
}
    80004526:	70e2                	ld	ra,56(sp)
    80004528:	7442                	ld	s0,48(sp)
    8000452a:	74a2                	ld	s1,40(sp)
    8000452c:	7902                	ld	s2,32(sp)
    8000452e:	69e2                	ld	s3,24(sp)
    80004530:	6a42                	ld	s4,16(sp)
    80004532:	6121                	addi	sp,sp,64
    80004534:	8082                	ret
    iput(ip);
    80004536:	00000097          	auipc	ra,0x0
    8000453a:	a30080e7          	jalr	-1488(ra) # 80003f66 <iput>
    return -1;
    8000453e:	557d                	li	a0,-1
    80004540:	b7dd                	j	80004526 <dirlink+0x86>
      panic("dirlink read");
    80004542:	00004517          	auipc	a0,0x4
    80004546:	20e50513          	addi	a0,a0,526 # 80008750 <syscalls+0x200>
    8000454a:	ffffc097          	auipc	ra,0xffffc
    8000454e:	ff4080e7          	jalr	-12(ra) # 8000053e <panic>
    panic("dirlink");
    80004552:	00004517          	auipc	a0,0x4
    80004556:	30e50513          	addi	a0,a0,782 # 80008860 <syscalls+0x310>
    8000455a:	ffffc097          	auipc	ra,0xffffc
    8000455e:	fe4080e7          	jalr	-28(ra) # 8000053e <panic>

0000000080004562 <namei>:

struct inode*
namei(char *path)
{
    80004562:	1101                	addi	sp,sp,-32
    80004564:	ec06                	sd	ra,24(sp)
    80004566:	e822                	sd	s0,16(sp)
    80004568:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000456a:	fe040613          	addi	a2,s0,-32
    8000456e:	4581                	li	a1,0
    80004570:	00000097          	auipc	ra,0x0
    80004574:	dd0080e7          	jalr	-560(ra) # 80004340 <namex>
}
    80004578:	60e2                	ld	ra,24(sp)
    8000457a:	6442                	ld	s0,16(sp)
    8000457c:	6105                	addi	sp,sp,32
    8000457e:	8082                	ret

0000000080004580 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004580:	1141                	addi	sp,sp,-16
    80004582:	e406                	sd	ra,8(sp)
    80004584:	e022                	sd	s0,0(sp)
    80004586:	0800                	addi	s0,sp,16
    80004588:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000458a:	4585                	li	a1,1
    8000458c:	00000097          	auipc	ra,0x0
    80004590:	db4080e7          	jalr	-588(ra) # 80004340 <namex>
}
    80004594:	60a2                	ld	ra,8(sp)
    80004596:	6402                	ld	s0,0(sp)
    80004598:	0141                	addi	sp,sp,16
    8000459a:	8082                	ret

000000008000459c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000459c:	1101                	addi	sp,sp,-32
    8000459e:	ec06                	sd	ra,24(sp)
    800045a0:	e822                	sd	s0,16(sp)
    800045a2:	e426                	sd	s1,8(sp)
    800045a4:	e04a                	sd	s2,0(sp)
    800045a6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800045a8:	0001d917          	auipc	s2,0x1d
    800045ac:	2c890913          	addi	s2,s2,712 # 80021870 <log>
    800045b0:	01892583          	lw	a1,24(s2)
    800045b4:	02892503          	lw	a0,40(s2)
    800045b8:	fffff097          	auipc	ra,0xfffff
    800045bc:	ff2080e7          	jalr	-14(ra) # 800035aa <bread>
    800045c0:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800045c2:	02c92683          	lw	a3,44(s2)
    800045c6:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800045c8:	02d05763          	blez	a3,800045f6 <write_head+0x5a>
    800045cc:	0001d797          	auipc	a5,0x1d
    800045d0:	2d478793          	addi	a5,a5,724 # 800218a0 <log+0x30>
    800045d4:	05c50713          	addi	a4,a0,92
    800045d8:	36fd                	addiw	a3,a3,-1
    800045da:	1682                	slli	a3,a3,0x20
    800045dc:	9281                	srli	a3,a3,0x20
    800045de:	068a                	slli	a3,a3,0x2
    800045e0:	0001d617          	auipc	a2,0x1d
    800045e4:	2c460613          	addi	a2,a2,708 # 800218a4 <log+0x34>
    800045e8:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800045ea:	4390                	lw	a2,0(a5)
    800045ec:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800045ee:	0791                	addi	a5,a5,4
    800045f0:	0711                	addi	a4,a4,4
    800045f2:	fed79ce3          	bne	a5,a3,800045ea <write_head+0x4e>
  }
  bwrite(buf);
    800045f6:	8526                	mv	a0,s1
    800045f8:	fffff097          	auipc	ra,0xfffff
    800045fc:	0a4080e7          	jalr	164(ra) # 8000369c <bwrite>
  brelse(buf);
    80004600:	8526                	mv	a0,s1
    80004602:	fffff097          	auipc	ra,0xfffff
    80004606:	0d8080e7          	jalr	216(ra) # 800036da <brelse>
}
    8000460a:	60e2                	ld	ra,24(sp)
    8000460c:	6442                	ld	s0,16(sp)
    8000460e:	64a2                	ld	s1,8(sp)
    80004610:	6902                	ld	s2,0(sp)
    80004612:	6105                	addi	sp,sp,32
    80004614:	8082                	ret

0000000080004616 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004616:	0001d797          	auipc	a5,0x1d
    8000461a:	2867a783          	lw	a5,646(a5) # 8002189c <log+0x2c>
    8000461e:	0af05d63          	blez	a5,800046d8 <install_trans+0xc2>
{
    80004622:	7139                	addi	sp,sp,-64
    80004624:	fc06                	sd	ra,56(sp)
    80004626:	f822                	sd	s0,48(sp)
    80004628:	f426                	sd	s1,40(sp)
    8000462a:	f04a                	sd	s2,32(sp)
    8000462c:	ec4e                	sd	s3,24(sp)
    8000462e:	e852                	sd	s4,16(sp)
    80004630:	e456                	sd	s5,8(sp)
    80004632:	e05a                	sd	s6,0(sp)
    80004634:	0080                	addi	s0,sp,64
    80004636:	8b2a                	mv	s6,a0
    80004638:	0001da97          	auipc	s5,0x1d
    8000463c:	268a8a93          	addi	s5,s5,616 # 800218a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004640:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004642:	0001d997          	auipc	s3,0x1d
    80004646:	22e98993          	addi	s3,s3,558 # 80021870 <log>
    8000464a:	a035                	j	80004676 <install_trans+0x60>
      bunpin(dbuf);
    8000464c:	8526                	mv	a0,s1
    8000464e:	fffff097          	auipc	ra,0xfffff
    80004652:	166080e7          	jalr	358(ra) # 800037b4 <bunpin>
    brelse(lbuf);
    80004656:	854a                	mv	a0,s2
    80004658:	fffff097          	auipc	ra,0xfffff
    8000465c:	082080e7          	jalr	130(ra) # 800036da <brelse>
    brelse(dbuf);
    80004660:	8526                	mv	a0,s1
    80004662:	fffff097          	auipc	ra,0xfffff
    80004666:	078080e7          	jalr	120(ra) # 800036da <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000466a:	2a05                	addiw	s4,s4,1
    8000466c:	0a91                	addi	s5,s5,4
    8000466e:	02c9a783          	lw	a5,44(s3)
    80004672:	04fa5963          	bge	s4,a5,800046c4 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004676:	0189a583          	lw	a1,24(s3)
    8000467a:	014585bb          	addw	a1,a1,s4
    8000467e:	2585                	addiw	a1,a1,1
    80004680:	0289a503          	lw	a0,40(s3)
    80004684:	fffff097          	auipc	ra,0xfffff
    80004688:	f26080e7          	jalr	-218(ra) # 800035aa <bread>
    8000468c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000468e:	000aa583          	lw	a1,0(s5)
    80004692:	0289a503          	lw	a0,40(s3)
    80004696:	fffff097          	auipc	ra,0xfffff
    8000469a:	f14080e7          	jalr	-236(ra) # 800035aa <bread>
    8000469e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800046a0:	40000613          	li	a2,1024
    800046a4:	05890593          	addi	a1,s2,88
    800046a8:	05850513          	addi	a0,a0,88
    800046ac:	ffffc097          	auipc	ra,0xffffc
    800046b0:	694080e7          	jalr	1684(ra) # 80000d40 <memmove>
    bwrite(dbuf);  // write dst to disk
    800046b4:	8526                	mv	a0,s1
    800046b6:	fffff097          	auipc	ra,0xfffff
    800046ba:	fe6080e7          	jalr	-26(ra) # 8000369c <bwrite>
    if(recovering == 0)
    800046be:	f80b1ce3          	bnez	s6,80004656 <install_trans+0x40>
    800046c2:	b769                	j	8000464c <install_trans+0x36>
}
    800046c4:	70e2                	ld	ra,56(sp)
    800046c6:	7442                	ld	s0,48(sp)
    800046c8:	74a2                	ld	s1,40(sp)
    800046ca:	7902                	ld	s2,32(sp)
    800046cc:	69e2                	ld	s3,24(sp)
    800046ce:	6a42                	ld	s4,16(sp)
    800046d0:	6aa2                	ld	s5,8(sp)
    800046d2:	6b02                	ld	s6,0(sp)
    800046d4:	6121                	addi	sp,sp,64
    800046d6:	8082                	ret
    800046d8:	8082                	ret

00000000800046da <initlog>:
{
    800046da:	7179                	addi	sp,sp,-48
    800046dc:	f406                	sd	ra,40(sp)
    800046de:	f022                	sd	s0,32(sp)
    800046e0:	ec26                	sd	s1,24(sp)
    800046e2:	e84a                	sd	s2,16(sp)
    800046e4:	e44e                	sd	s3,8(sp)
    800046e6:	1800                	addi	s0,sp,48
    800046e8:	892a                	mv	s2,a0
    800046ea:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800046ec:	0001d497          	auipc	s1,0x1d
    800046f0:	18448493          	addi	s1,s1,388 # 80021870 <log>
    800046f4:	00004597          	auipc	a1,0x4
    800046f8:	06c58593          	addi	a1,a1,108 # 80008760 <syscalls+0x210>
    800046fc:	8526                	mv	a0,s1
    800046fe:	ffffc097          	auipc	ra,0xffffc
    80004702:	456080e7          	jalr	1110(ra) # 80000b54 <initlock>
  log.start = sb->logstart;
    80004706:	0149a583          	lw	a1,20(s3)
    8000470a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000470c:	0109a783          	lw	a5,16(s3)
    80004710:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004712:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004716:	854a                	mv	a0,s2
    80004718:	fffff097          	auipc	ra,0xfffff
    8000471c:	e92080e7          	jalr	-366(ra) # 800035aa <bread>
  log.lh.n = lh->n;
    80004720:	4d3c                	lw	a5,88(a0)
    80004722:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004724:	02f05563          	blez	a5,8000474e <initlog+0x74>
    80004728:	05c50713          	addi	a4,a0,92
    8000472c:	0001d697          	auipc	a3,0x1d
    80004730:	17468693          	addi	a3,a3,372 # 800218a0 <log+0x30>
    80004734:	37fd                	addiw	a5,a5,-1
    80004736:	1782                	slli	a5,a5,0x20
    80004738:	9381                	srli	a5,a5,0x20
    8000473a:	078a                	slli	a5,a5,0x2
    8000473c:	06050613          	addi	a2,a0,96
    80004740:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004742:	4310                	lw	a2,0(a4)
    80004744:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004746:	0711                	addi	a4,a4,4
    80004748:	0691                	addi	a3,a3,4
    8000474a:	fef71ce3          	bne	a4,a5,80004742 <initlog+0x68>
  brelse(buf);
    8000474e:	fffff097          	auipc	ra,0xfffff
    80004752:	f8c080e7          	jalr	-116(ra) # 800036da <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004756:	4505                	li	a0,1
    80004758:	00000097          	auipc	ra,0x0
    8000475c:	ebe080e7          	jalr	-322(ra) # 80004616 <install_trans>
  log.lh.n = 0;
    80004760:	0001d797          	auipc	a5,0x1d
    80004764:	1207ae23          	sw	zero,316(a5) # 8002189c <log+0x2c>
  write_head(); // clear the log
    80004768:	00000097          	auipc	ra,0x0
    8000476c:	e34080e7          	jalr	-460(ra) # 8000459c <write_head>
}
    80004770:	70a2                	ld	ra,40(sp)
    80004772:	7402                	ld	s0,32(sp)
    80004774:	64e2                	ld	s1,24(sp)
    80004776:	6942                	ld	s2,16(sp)
    80004778:	69a2                	ld	s3,8(sp)
    8000477a:	6145                	addi	sp,sp,48
    8000477c:	8082                	ret

000000008000477e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000477e:	1101                	addi	sp,sp,-32
    80004780:	ec06                	sd	ra,24(sp)
    80004782:	e822                	sd	s0,16(sp)
    80004784:	e426                	sd	s1,8(sp)
    80004786:	e04a                	sd	s2,0(sp)
    80004788:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000478a:	0001d517          	auipc	a0,0x1d
    8000478e:	0e650513          	addi	a0,a0,230 # 80021870 <log>
    80004792:	ffffc097          	auipc	ra,0xffffc
    80004796:	452080e7          	jalr	1106(ra) # 80000be4 <acquire>
  while(1){
    if(log.committing){
    8000479a:	0001d497          	auipc	s1,0x1d
    8000479e:	0d648493          	addi	s1,s1,214 # 80021870 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047a2:	4979                	li	s2,30
    800047a4:	a039                	j	800047b2 <begin_op+0x34>
      sleep(&log, &log.lock);
    800047a6:	85a6                	mv	a1,s1
    800047a8:	8526                	mv	a0,s1
    800047aa:	ffffe097          	auipc	ra,0xffffe
    800047ae:	aba080e7          	jalr	-1350(ra) # 80002264 <sleep>
    if(log.committing){
    800047b2:	50dc                	lw	a5,36(s1)
    800047b4:	fbed                	bnez	a5,800047a6 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047b6:	509c                	lw	a5,32(s1)
    800047b8:	0017871b          	addiw	a4,a5,1
    800047bc:	0007069b          	sext.w	a3,a4
    800047c0:	0027179b          	slliw	a5,a4,0x2
    800047c4:	9fb9                	addw	a5,a5,a4
    800047c6:	0017979b          	slliw	a5,a5,0x1
    800047ca:	54d8                	lw	a4,44(s1)
    800047cc:	9fb9                	addw	a5,a5,a4
    800047ce:	00f95963          	bge	s2,a5,800047e0 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800047d2:	85a6                	mv	a1,s1
    800047d4:	8526                	mv	a0,s1
    800047d6:	ffffe097          	auipc	ra,0xffffe
    800047da:	a8e080e7          	jalr	-1394(ra) # 80002264 <sleep>
    800047de:	bfd1                	j	800047b2 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800047e0:	0001d517          	auipc	a0,0x1d
    800047e4:	09050513          	addi	a0,a0,144 # 80021870 <log>
    800047e8:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800047ea:	ffffc097          	auipc	ra,0xffffc
    800047ee:	4ae080e7          	jalr	1198(ra) # 80000c98 <release>
      break;
    }
  }
}
    800047f2:	60e2                	ld	ra,24(sp)
    800047f4:	6442                	ld	s0,16(sp)
    800047f6:	64a2                	ld	s1,8(sp)
    800047f8:	6902                	ld	s2,0(sp)
    800047fa:	6105                	addi	sp,sp,32
    800047fc:	8082                	ret

00000000800047fe <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800047fe:	7139                	addi	sp,sp,-64
    80004800:	fc06                	sd	ra,56(sp)
    80004802:	f822                	sd	s0,48(sp)
    80004804:	f426                	sd	s1,40(sp)
    80004806:	f04a                	sd	s2,32(sp)
    80004808:	ec4e                	sd	s3,24(sp)
    8000480a:	e852                	sd	s4,16(sp)
    8000480c:	e456                	sd	s5,8(sp)
    8000480e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004810:	0001d497          	auipc	s1,0x1d
    80004814:	06048493          	addi	s1,s1,96 # 80021870 <log>
    80004818:	8526                	mv	a0,s1
    8000481a:	ffffc097          	auipc	ra,0xffffc
    8000481e:	3ca080e7          	jalr	970(ra) # 80000be4 <acquire>
  log.outstanding -= 1;
    80004822:	509c                	lw	a5,32(s1)
    80004824:	37fd                	addiw	a5,a5,-1
    80004826:	0007891b          	sext.w	s2,a5
    8000482a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000482c:	50dc                	lw	a5,36(s1)
    8000482e:	efb9                	bnez	a5,8000488c <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004830:	06091663          	bnez	s2,8000489c <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004834:	0001d497          	auipc	s1,0x1d
    80004838:	03c48493          	addi	s1,s1,60 # 80021870 <log>
    8000483c:	4785                	li	a5,1
    8000483e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004840:	8526                	mv	a0,s1
    80004842:	ffffc097          	auipc	ra,0xffffc
    80004846:	456080e7          	jalr	1110(ra) # 80000c98 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000484a:	54dc                	lw	a5,44(s1)
    8000484c:	06f04763          	bgtz	a5,800048ba <end_op+0xbc>
    acquire(&log.lock);
    80004850:	0001d497          	auipc	s1,0x1d
    80004854:	02048493          	addi	s1,s1,32 # 80021870 <log>
    80004858:	8526                	mv	a0,s1
    8000485a:	ffffc097          	auipc	ra,0xffffc
    8000485e:	38a080e7          	jalr	906(ra) # 80000be4 <acquire>
    log.committing = 0;
    80004862:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004866:	8526                	mv	a0,s1
    80004868:	ffffe097          	auipc	ra,0xffffe
    8000486c:	cbc080e7          	jalr	-836(ra) # 80002524 <wakeup>
    release(&log.lock);
    80004870:	8526                	mv	a0,s1
    80004872:	ffffc097          	auipc	ra,0xffffc
    80004876:	426080e7          	jalr	1062(ra) # 80000c98 <release>
}
    8000487a:	70e2                	ld	ra,56(sp)
    8000487c:	7442                	ld	s0,48(sp)
    8000487e:	74a2                	ld	s1,40(sp)
    80004880:	7902                	ld	s2,32(sp)
    80004882:	69e2                	ld	s3,24(sp)
    80004884:	6a42                	ld	s4,16(sp)
    80004886:	6aa2                	ld	s5,8(sp)
    80004888:	6121                	addi	sp,sp,64
    8000488a:	8082                	ret
    panic("log.committing");
    8000488c:	00004517          	auipc	a0,0x4
    80004890:	edc50513          	addi	a0,a0,-292 # 80008768 <syscalls+0x218>
    80004894:	ffffc097          	auipc	ra,0xffffc
    80004898:	caa080e7          	jalr	-854(ra) # 8000053e <panic>
    wakeup(&log);
    8000489c:	0001d497          	auipc	s1,0x1d
    800048a0:	fd448493          	addi	s1,s1,-44 # 80021870 <log>
    800048a4:	8526                	mv	a0,s1
    800048a6:	ffffe097          	auipc	ra,0xffffe
    800048aa:	c7e080e7          	jalr	-898(ra) # 80002524 <wakeup>
  release(&log.lock);
    800048ae:	8526                	mv	a0,s1
    800048b0:	ffffc097          	auipc	ra,0xffffc
    800048b4:	3e8080e7          	jalr	1000(ra) # 80000c98 <release>
  if(do_commit){
    800048b8:	b7c9                	j	8000487a <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800048ba:	0001da97          	auipc	s5,0x1d
    800048be:	fe6a8a93          	addi	s5,s5,-26 # 800218a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800048c2:	0001da17          	auipc	s4,0x1d
    800048c6:	faea0a13          	addi	s4,s4,-82 # 80021870 <log>
    800048ca:	018a2583          	lw	a1,24(s4)
    800048ce:	012585bb          	addw	a1,a1,s2
    800048d2:	2585                	addiw	a1,a1,1
    800048d4:	028a2503          	lw	a0,40(s4)
    800048d8:	fffff097          	auipc	ra,0xfffff
    800048dc:	cd2080e7          	jalr	-814(ra) # 800035aa <bread>
    800048e0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800048e2:	000aa583          	lw	a1,0(s5)
    800048e6:	028a2503          	lw	a0,40(s4)
    800048ea:	fffff097          	auipc	ra,0xfffff
    800048ee:	cc0080e7          	jalr	-832(ra) # 800035aa <bread>
    800048f2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800048f4:	40000613          	li	a2,1024
    800048f8:	05850593          	addi	a1,a0,88
    800048fc:	05848513          	addi	a0,s1,88
    80004900:	ffffc097          	auipc	ra,0xffffc
    80004904:	440080e7          	jalr	1088(ra) # 80000d40 <memmove>
    bwrite(to);  // write the log
    80004908:	8526                	mv	a0,s1
    8000490a:	fffff097          	auipc	ra,0xfffff
    8000490e:	d92080e7          	jalr	-622(ra) # 8000369c <bwrite>
    brelse(from);
    80004912:	854e                	mv	a0,s3
    80004914:	fffff097          	auipc	ra,0xfffff
    80004918:	dc6080e7          	jalr	-570(ra) # 800036da <brelse>
    brelse(to);
    8000491c:	8526                	mv	a0,s1
    8000491e:	fffff097          	auipc	ra,0xfffff
    80004922:	dbc080e7          	jalr	-580(ra) # 800036da <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004926:	2905                	addiw	s2,s2,1
    80004928:	0a91                	addi	s5,s5,4
    8000492a:	02ca2783          	lw	a5,44(s4)
    8000492e:	f8f94ee3          	blt	s2,a5,800048ca <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004932:	00000097          	auipc	ra,0x0
    80004936:	c6a080e7          	jalr	-918(ra) # 8000459c <write_head>
    install_trans(0); // Now install writes to home locations
    8000493a:	4501                	li	a0,0
    8000493c:	00000097          	auipc	ra,0x0
    80004940:	cda080e7          	jalr	-806(ra) # 80004616 <install_trans>
    log.lh.n = 0;
    80004944:	0001d797          	auipc	a5,0x1d
    80004948:	f407ac23          	sw	zero,-168(a5) # 8002189c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000494c:	00000097          	auipc	ra,0x0
    80004950:	c50080e7          	jalr	-944(ra) # 8000459c <write_head>
    80004954:	bdf5                	j	80004850 <end_op+0x52>

0000000080004956 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004956:	1101                	addi	sp,sp,-32
    80004958:	ec06                	sd	ra,24(sp)
    8000495a:	e822                	sd	s0,16(sp)
    8000495c:	e426                	sd	s1,8(sp)
    8000495e:	e04a                	sd	s2,0(sp)
    80004960:	1000                	addi	s0,sp,32
    80004962:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004964:	0001d917          	auipc	s2,0x1d
    80004968:	f0c90913          	addi	s2,s2,-244 # 80021870 <log>
    8000496c:	854a                	mv	a0,s2
    8000496e:	ffffc097          	auipc	ra,0xffffc
    80004972:	276080e7          	jalr	630(ra) # 80000be4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004976:	02c92603          	lw	a2,44(s2)
    8000497a:	47f5                	li	a5,29
    8000497c:	06c7c563          	blt	a5,a2,800049e6 <log_write+0x90>
    80004980:	0001d797          	auipc	a5,0x1d
    80004984:	f0c7a783          	lw	a5,-244(a5) # 8002188c <log+0x1c>
    80004988:	37fd                	addiw	a5,a5,-1
    8000498a:	04f65e63          	bge	a2,a5,800049e6 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000498e:	0001d797          	auipc	a5,0x1d
    80004992:	f027a783          	lw	a5,-254(a5) # 80021890 <log+0x20>
    80004996:	06f05063          	blez	a5,800049f6 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000499a:	4781                	li	a5,0
    8000499c:	06c05563          	blez	a2,80004a06 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800049a0:	44cc                	lw	a1,12(s1)
    800049a2:	0001d717          	auipc	a4,0x1d
    800049a6:	efe70713          	addi	a4,a4,-258 # 800218a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800049aa:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800049ac:	4314                	lw	a3,0(a4)
    800049ae:	04b68c63          	beq	a3,a1,80004a06 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800049b2:	2785                	addiw	a5,a5,1
    800049b4:	0711                	addi	a4,a4,4
    800049b6:	fef61be3          	bne	a2,a5,800049ac <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800049ba:	0621                	addi	a2,a2,8
    800049bc:	060a                	slli	a2,a2,0x2
    800049be:	0001d797          	auipc	a5,0x1d
    800049c2:	eb278793          	addi	a5,a5,-334 # 80021870 <log>
    800049c6:	963e                	add	a2,a2,a5
    800049c8:	44dc                	lw	a5,12(s1)
    800049ca:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800049cc:	8526                	mv	a0,s1
    800049ce:	fffff097          	auipc	ra,0xfffff
    800049d2:	daa080e7          	jalr	-598(ra) # 80003778 <bpin>
    log.lh.n++;
    800049d6:	0001d717          	auipc	a4,0x1d
    800049da:	e9a70713          	addi	a4,a4,-358 # 80021870 <log>
    800049de:	575c                	lw	a5,44(a4)
    800049e0:	2785                	addiw	a5,a5,1
    800049e2:	d75c                	sw	a5,44(a4)
    800049e4:	a835                	j	80004a20 <log_write+0xca>
    panic("too big a transaction");
    800049e6:	00004517          	auipc	a0,0x4
    800049ea:	d9250513          	addi	a0,a0,-622 # 80008778 <syscalls+0x228>
    800049ee:	ffffc097          	auipc	ra,0xffffc
    800049f2:	b50080e7          	jalr	-1200(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    800049f6:	00004517          	auipc	a0,0x4
    800049fa:	d9a50513          	addi	a0,a0,-614 # 80008790 <syscalls+0x240>
    800049fe:	ffffc097          	auipc	ra,0xffffc
    80004a02:	b40080e7          	jalr	-1216(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004a06:	00878713          	addi	a4,a5,8
    80004a0a:	00271693          	slli	a3,a4,0x2
    80004a0e:	0001d717          	auipc	a4,0x1d
    80004a12:	e6270713          	addi	a4,a4,-414 # 80021870 <log>
    80004a16:	9736                	add	a4,a4,a3
    80004a18:	44d4                	lw	a3,12(s1)
    80004a1a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004a1c:	faf608e3          	beq	a2,a5,800049cc <log_write+0x76>
  }
  release(&log.lock);
    80004a20:	0001d517          	auipc	a0,0x1d
    80004a24:	e5050513          	addi	a0,a0,-432 # 80021870 <log>
    80004a28:	ffffc097          	auipc	ra,0xffffc
    80004a2c:	270080e7          	jalr	624(ra) # 80000c98 <release>
}
    80004a30:	60e2                	ld	ra,24(sp)
    80004a32:	6442                	ld	s0,16(sp)
    80004a34:	64a2                	ld	s1,8(sp)
    80004a36:	6902                	ld	s2,0(sp)
    80004a38:	6105                	addi	sp,sp,32
    80004a3a:	8082                	ret

0000000080004a3c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004a3c:	1101                	addi	sp,sp,-32
    80004a3e:	ec06                	sd	ra,24(sp)
    80004a40:	e822                	sd	s0,16(sp)
    80004a42:	e426                	sd	s1,8(sp)
    80004a44:	e04a                	sd	s2,0(sp)
    80004a46:	1000                	addi	s0,sp,32
    80004a48:	84aa                	mv	s1,a0
    80004a4a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004a4c:	00004597          	auipc	a1,0x4
    80004a50:	d6458593          	addi	a1,a1,-668 # 800087b0 <syscalls+0x260>
    80004a54:	0521                	addi	a0,a0,8
    80004a56:	ffffc097          	auipc	ra,0xffffc
    80004a5a:	0fe080e7          	jalr	254(ra) # 80000b54 <initlock>
  lk->name = name;
    80004a5e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004a62:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a66:	0204a423          	sw	zero,40(s1)
}
    80004a6a:	60e2                	ld	ra,24(sp)
    80004a6c:	6442                	ld	s0,16(sp)
    80004a6e:	64a2                	ld	s1,8(sp)
    80004a70:	6902                	ld	s2,0(sp)
    80004a72:	6105                	addi	sp,sp,32
    80004a74:	8082                	ret

0000000080004a76 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004a76:	1101                	addi	sp,sp,-32
    80004a78:	ec06                	sd	ra,24(sp)
    80004a7a:	e822                	sd	s0,16(sp)
    80004a7c:	e426                	sd	s1,8(sp)
    80004a7e:	e04a                	sd	s2,0(sp)
    80004a80:	1000                	addi	s0,sp,32
    80004a82:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a84:	00850913          	addi	s2,a0,8
    80004a88:	854a                	mv	a0,s2
    80004a8a:	ffffc097          	auipc	ra,0xffffc
    80004a8e:	15a080e7          	jalr	346(ra) # 80000be4 <acquire>
  while (lk->locked) {
    80004a92:	409c                	lw	a5,0(s1)
    80004a94:	cb89                	beqz	a5,80004aa6 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004a96:	85ca                	mv	a1,s2
    80004a98:	8526                	mv	a0,s1
    80004a9a:	ffffd097          	auipc	ra,0xffffd
    80004a9e:	7ca080e7          	jalr	1994(ra) # 80002264 <sleep>
  while (lk->locked) {
    80004aa2:	409c                	lw	a5,0(s1)
    80004aa4:	fbed                	bnez	a5,80004a96 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004aa6:	4785                	li	a5,1
    80004aa8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004aaa:	ffffd097          	auipc	ra,0xffffd
    80004aae:	f06080e7          	jalr	-250(ra) # 800019b0 <myproc>
    80004ab2:	591c                	lw	a5,48(a0)
    80004ab4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004ab6:	854a                	mv	a0,s2
    80004ab8:	ffffc097          	auipc	ra,0xffffc
    80004abc:	1e0080e7          	jalr	480(ra) # 80000c98 <release>
}
    80004ac0:	60e2                	ld	ra,24(sp)
    80004ac2:	6442                	ld	s0,16(sp)
    80004ac4:	64a2                	ld	s1,8(sp)
    80004ac6:	6902                	ld	s2,0(sp)
    80004ac8:	6105                	addi	sp,sp,32
    80004aca:	8082                	ret

0000000080004acc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004acc:	1101                	addi	sp,sp,-32
    80004ace:	ec06                	sd	ra,24(sp)
    80004ad0:	e822                	sd	s0,16(sp)
    80004ad2:	e426                	sd	s1,8(sp)
    80004ad4:	e04a                	sd	s2,0(sp)
    80004ad6:	1000                	addi	s0,sp,32
    80004ad8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004ada:	00850913          	addi	s2,a0,8
    80004ade:	854a                	mv	a0,s2
    80004ae0:	ffffc097          	auipc	ra,0xffffc
    80004ae4:	104080e7          	jalr	260(ra) # 80000be4 <acquire>
  lk->locked = 0;
    80004ae8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004aec:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004af0:	8526                	mv	a0,s1
    80004af2:	ffffe097          	auipc	ra,0xffffe
    80004af6:	a32080e7          	jalr	-1486(ra) # 80002524 <wakeup>
  release(&lk->lk);
    80004afa:	854a                	mv	a0,s2
    80004afc:	ffffc097          	auipc	ra,0xffffc
    80004b00:	19c080e7          	jalr	412(ra) # 80000c98 <release>
}
    80004b04:	60e2                	ld	ra,24(sp)
    80004b06:	6442                	ld	s0,16(sp)
    80004b08:	64a2                	ld	s1,8(sp)
    80004b0a:	6902                	ld	s2,0(sp)
    80004b0c:	6105                	addi	sp,sp,32
    80004b0e:	8082                	ret

0000000080004b10 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004b10:	7179                	addi	sp,sp,-48
    80004b12:	f406                	sd	ra,40(sp)
    80004b14:	f022                	sd	s0,32(sp)
    80004b16:	ec26                	sd	s1,24(sp)
    80004b18:	e84a                	sd	s2,16(sp)
    80004b1a:	e44e                	sd	s3,8(sp)
    80004b1c:	1800                	addi	s0,sp,48
    80004b1e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004b20:	00850913          	addi	s2,a0,8
    80004b24:	854a                	mv	a0,s2
    80004b26:	ffffc097          	auipc	ra,0xffffc
    80004b2a:	0be080e7          	jalr	190(ra) # 80000be4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b2e:	409c                	lw	a5,0(s1)
    80004b30:	ef99                	bnez	a5,80004b4e <holdingsleep+0x3e>
    80004b32:	4481                	li	s1,0
  release(&lk->lk);
    80004b34:	854a                	mv	a0,s2
    80004b36:	ffffc097          	auipc	ra,0xffffc
    80004b3a:	162080e7          	jalr	354(ra) # 80000c98 <release>
  return r;
}
    80004b3e:	8526                	mv	a0,s1
    80004b40:	70a2                	ld	ra,40(sp)
    80004b42:	7402                	ld	s0,32(sp)
    80004b44:	64e2                	ld	s1,24(sp)
    80004b46:	6942                	ld	s2,16(sp)
    80004b48:	69a2                	ld	s3,8(sp)
    80004b4a:	6145                	addi	sp,sp,48
    80004b4c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b4e:	0284a983          	lw	s3,40(s1)
    80004b52:	ffffd097          	auipc	ra,0xffffd
    80004b56:	e5e080e7          	jalr	-418(ra) # 800019b0 <myproc>
    80004b5a:	5904                	lw	s1,48(a0)
    80004b5c:	413484b3          	sub	s1,s1,s3
    80004b60:	0014b493          	seqz	s1,s1
    80004b64:	bfc1                	j	80004b34 <holdingsleep+0x24>

0000000080004b66 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004b66:	1141                	addi	sp,sp,-16
    80004b68:	e406                	sd	ra,8(sp)
    80004b6a:	e022                	sd	s0,0(sp)
    80004b6c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004b6e:	00004597          	auipc	a1,0x4
    80004b72:	c5258593          	addi	a1,a1,-942 # 800087c0 <syscalls+0x270>
    80004b76:	0001d517          	auipc	a0,0x1d
    80004b7a:	e4250513          	addi	a0,a0,-446 # 800219b8 <ftable>
    80004b7e:	ffffc097          	auipc	ra,0xffffc
    80004b82:	fd6080e7          	jalr	-42(ra) # 80000b54 <initlock>
}
    80004b86:	60a2                	ld	ra,8(sp)
    80004b88:	6402                	ld	s0,0(sp)
    80004b8a:	0141                	addi	sp,sp,16
    80004b8c:	8082                	ret

0000000080004b8e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004b8e:	1101                	addi	sp,sp,-32
    80004b90:	ec06                	sd	ra,24(sp)
    80004b92:	e822                	sd	s0,16(sp)
    80004b94:	e426                	sd	s1,8(sp)
    80004b96:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004b98:	0001d517          	auipc	a0,0x1d
    80004b9c:	e2050513          	addi	a0,a0,-480 # 800219b8 <ftable>
    80004ba0:	ffffc097          	auipc	ra,0xffffc
    80004ba4:	044080e7          	jalr	68(ra) # 80000be4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ba8:	0001d497          	auipc	s1,0x1d
    80004bac:	e2848493          	addi	s1,s1,-472 # 800219d0 <ftable+0x18>
    80004bb0:	0001e717          	auipc	a4,0x1e
    80004bb4:	dc070713          	addi	a4,a4,-576 # 80022970 <ftable+0xfb8>
    if(f->ref == 0){
    80004bb8:	40dc                	lw	a5,4(s1)
    80004bba:	cf99                	beqz	a5,80004bd8 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004bbc:	02848493          	addi	s1,s1,40
    80004bc0:	fee49ce3          	bne	s1,a4,80004bb8 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004bc4:	0001d517          	auipc	a0,0x1d
    80004bc8:	df450513          	addi	a0,a0,-524 # 800219b8 <ftable>
    80004bcc:	ffffc097          	auipc	ra,0xffffc
    80004bd0:	0cc080e7          	jalr	204(ra) # 80000c98 <release>
  return 0;
    80004bd4:	4481                	li	s1,0
    80004bd6:	a819                	j	80004bec <filealloc+0x5e>
      f->ref = 1;
    80004bd8:	4785                	li	a5,1
    80004bda:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004bdc:	0001d517          	auipc	a0,0x1d
    80004be0:	ddc50513          	addi	a0,a0,-548 # 800219b8 <ftable>
    80004be4:	ffffc097          	auipc	ra,0xffffc
    80004be8:	0b4080e7          	jalr	180(ra) # 80000c98 <release>
}
    80004bec:	8526                	mv	a0,s1
    80004bee:	60e2                	ld	ra,24(sp)
    80004bf0:	6442                	ld	s0,16(sp)
    80004bf2:	64a2                	ld	s1,8(sp)
    80004bf4:	6105                	addi	sp,sp,32
    80004bf6:	8082                	ret

0000000080004bf8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004bf8:	1101                	addi	sp,sp,-32
    80004bfa:	ec06                	sd	ra,24(sp)
    80004bfc:	e822                	sd	s0,16(sp)
    80004bfe:	e426                	sd	s1,8(sp)
    80004c00:	1000                	addi	s0,sp,32
    80004c02:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004c04:	0001d517          	auipc	a0,0x1d
    80004c08:	db450513          	addi	a0,a0,-588 # 800219b8 <ftable>
    80004c0c:	ffffc097          	auipc	ra,0xffffc
    80004c10:	fd8080e7          	jalr	-40(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    80004c14:	40dc                	lw	a5,4(s1)
    80004c16:	02f05263          	blez	a5,80004c3a <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004c1a:	2785                	addiw	a5,a5,1
    80004c1c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004c1e:	0001d517          	auipc	a0,0x1d
    80004c22:	d9a50513          	addi	a0,a0,-614 # 800219b8 <ftable>
    80004c26:	ffffc097          	auipc	ra,0xffffc
    80004c2a:	072080e7          	jalr	114(ra) # 80000c98 <release>
  return f;
}
    80004c2e:	8526                	mv	a0,s1
    80004c30:	60e2                	ld	ra,24(sp)
    80004c32:	6442                	ld	s0,16(sp)
    80004c34:	64a2                	ld	s1,8(sp)
    80004c36:	6105                	addi	sp,sp,32
    80004c38:	8082                	ret
    panic("filedup");
    80004c3a:	00004517          	auipc	a0,0x4
    80004c3e:	b8e50513          	addi	a0,a0,-1138 # 800087c8 <syscalls+0x278>
    80004c42:	ffffc097          	auipc	ra,0xffffc
    80004c46:	8fc080e7          	jalr	-1796(ra) # 8000053e <panic>

0000000080004c4a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004c4a:	7139                	addi	sp,sp,-64
    80004c4c:	fc06                	sd	ra,56(sp)
    80004c4e:	f822                	sd	s0,48(sp)
    80004c50:	f426                	sd	s1,40(sp)
    80004c52:	f04a                	sd	s2,32(sp)
    80004c54:	ec4e                	sd	s3,24(sp)
    80004c56:	e852                	sd	s4,16(sp)
    80004c58:	e456                	sd	s5,8(sp)
    80004c5a:	0080                	addi	s0,sp,64
    80004c5c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004c5e:	0001d517          	auipc	a0,0x1d
    80004c62:	d5a50513          	addi	a0,a0,-678 # 800219b8 <ftable>
    80004c66:	ffffc097          	auipc	ra,0xffffc
    80004c6a:	f7e080e7          	jalr	-130(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    80004c6e:	40dc                	lw	a5,4(s1)
    80004c70:	06f05163          	blez	a5,80004cd2 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004c74:	37fd                	addiw	a5,a5,-1
    80004c76:	0007871b          	sext.w	a4,a5
    80004c7a:	c0dc                	sw	a5,4(s1)
    80004c7c:	06e04363          	bgtz	a4,80004ce2 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004c80:	0004a903          	lw	s2,0(s1)
    80004c84:	0094ca83          	lbu	s5,9(s1)
    80004c88:	0104ba03          	ld	s4,16(s1)
    80004c8c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004c90:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004c94:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004c98:	0001d517          	auipc	a0,0x1d
    80004c9c:	d2050513          	addi	a0,a0,-736 # 800219b8 <ftable>
    80004ca0:	ffffc097          	auipc	ra,0xffffc
    80004ca4:	ff8080e7          	jalr	-8(ra) # 80000c98 <release>

  if(ff.type == FD_PIPE){
    80004ca8:	4785                	li	a5,1
    80004caa:	04f90d63          	beq	s2,a5,80004d04 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004cae:	3979                	addiw	s2,s2,-2
    80004cb0:	4785                	li	a5,1
    80004cb2:	0527e063          	bltu	a5,s2,80004cf2 <fileclose+0xa8>
    begin_op();
    80004cb6:	00000097          	auipc	ra,0x0
    80004cba:	ac8080e7          	jalr	-1336(ra) # 8000477e <begin_op>
    iput(ff.ip);
    80004cbe:	854e                	mv	a0,s3
    80004cc0:	fffff097          	auipc	ra,0xfffff
    80004cc4:	2a6080e7          	jalr	678(ra) # 80003f66 <iput>
    end_op();
    80004cc8:	00000097          	auipc	ra,0x0
    80004ccc:	b36080e7          	jalr	-1226(ra) # 800047fe <end_op>
    80004cd0:	a00d                	j	80004cf2 <fileclose+0xa8>
    panic("fileclose");
    80004cd2:	00004517          	auipc	a0,0x4
    80004cd6:	afe50513          	addi	a0,a0,-1282 # 800087d0 <syscalls+0x280>
    80004cda:	ffffc097          	auipc	ra,0xffffc
    80004cde:	864080e7          	jalr	-1948(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004ce2:	0001d517          	auipc	a0,0x1d
    80004ce6:	cd650513          	addi	a0,a0,-810 # 800219b8 <ftable>
    80004cea:	ffffc097          	auipc	ra,0xffffc
    80004cee:	fae080e7          	jalr	-82(ra) # 80000c98 <release>
  }
}
    80004cf2:	70e2                	ld	ra,56(sp)
    80004cf4:	7442                	ld	s0,48(sp)
    80004cf6:	74a2                	ld	s1,40(sp)
    80004cf8:	7902                	ld	s2,32(sp)
    80004cfa:	69e2                	ld	s3,24(sp)
    80004cfc:	6a42                	ld	s4,16(sp)
    80004cfe:	6aa2                	ld	s5,8(sp)
    80004d00:	6121                	addi	sp,sp,64
    80004d02:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004d04:	85d6                	mv	a1,s5
    80004d06:	8552                	mv	a0,s4
    80004d08:	00000097          	auipc	ra,0x0
    80004d0c:	34c080e7          	jalr	844(ra) # 80005054 <pipeclose>
    80004d10:	b7cd                	j	80004cf2 <fileclose+0xa8>

0000000080004d12 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004d12:	715d                	addi	sp,sp,-80
    80004d14:	e486                	sd	ra,72(sp)
    80004d16:	e0a2                	sd	s0,64(sp)
    80004d18:	fc26                	sd	s1,56(sp)
    80004d1a:	f84a                	sd	s2,48(sp)
    80004d1c:	f44e                	sd	s3,40(sp)
    80004d1e:	0880                	addi	s0,sp,80
    80004d20:	84aa                	mv	s1,a0
    80004d22:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004d24:	ffffd097          	auipc	ra,0xffffd
    80004d28:	c8c080e7          	jalr	-884(ra) # 800019b0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004d2c:	409c                	lw	a5,0(s1)
    80004d2e:	37f9                	addiw	a5,a5,-2
    80004d30:	4705                	li	a4,1
    80004d32:	04f76763          	bltu	a4,a5,80004d80 <filestat+0x6e>
    80004d36:	892a                	mv	s2,a0
    ilock(f->ip);
    80004d38:	6c88                	ld	a0,24(s1)
    80004d3a:	fffff097          	auipc	ra,0xfffff
    80004d3e:	072080e7          	jalr	114(ra) # 80003dac <ilock>
    stati(f->ip, &st);
    80004d42:	fb840593          	addi	a1,s0,-72
    80004d46:	6c88                	ld	a0,24(s1)
    80004d48:	fffff097          	auipc	ra,0xfffff
    80004d4c:	2ee080e7          	jalr	750(ra) # 80004036 <stati>
    iunlock(f->ip);
    80004d50:	6c88                	ld	a0,24(s1)
    80004d52:	fffff097          	auipc	ra,0xfffff
    80004d56:	11c080e7          	jalr	284(ra) # 80003e6e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004d5a:	46e1                	li	a3,24
    80004d5c:	fb840613          	addi	a2,s0,-72
    80004d60:	85ce                	mv	a1,s3
    80004d62:	05093503          	ld	a0,80(s2)
    80004d66:	ffffd097          	auipc	ra,0xffffd
    80004d6a:	90c080e7          	jalr	-1780(ra) # 80001672 <copyout>
    80004d6e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004d72:	60a6                	ld	ra,72(sp)
    80004d74:	6406                	ld	s0,64(sp)
    80004d76:	74e2                	ld	s1,56(sp)
    80004d78:	7942                	ld	s2,48(sp)
    80004d7a:	79a2                	ld	s3,40(sp)
    80004d7c:	6161                	addi	sp,sp,80
    80004d7e:	8082                	ret
  return -1;
    80004d80:	557d                	li	a0,-1
    80004d82:	bfc5                	j	80004d72 <filestat+0x60>

0000000080004d84 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004d84:	7179                	addi	sp,sp,-48
    80004d86:	f406                	sd	ra,40(sp)
    80004d88:	f022                	sd	s0,32(sp)
    80004d8a:	ec26                	sd	s1,24(sp)
    80004d8c:	e84a                	sd	s2,16(sp)
    80004d8e:	e44e                	sd	s3,8(sp)
    80004d90:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004d92:	00854783          	lbu	a5,8(a0)
    80004d96:	c3d5                	beqz	a5,80004e3a <fileread+0xb6>
    80004d98:	84aa                	mv	s1,a0
    80004d9a:	89ae                	mv	s3,a1
    80004d9c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d9e:	411c                	lw	a5,0(a0)
    80004da0:	4705                	li	a4,1
    80004da2:	04e78963          	beq	a5,a4,80004df4 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004da6:	470d                	li	a4,3
    80004da8:	04e78d63          	beq	a5,a4,80004e02 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004dac:	4709                	li	a4,2
    80004dae:	06e79e63          	bne	a5,a4,80004e2a <fileread+0xa6>
    ilock(f->ip);
    80004db2:	6d08                	ld	a0,24(a0)
    80004db4:	fffff097          	auipc	ra,0xfffff
    80004db8:	ff8080e7          	jalr	-8(ra) # 80003dac <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004dbc:	874a                	mv	a4,s2
    80004dbe:	5094                	lw	a3,32(s1)
    80004dc0:	864e                	mv	a2,s3
    80004dc2:	4585                	li	a1,1
    80004dc4:	6c88                	ld	a0,24(s1)
    80004dc6:	fffff097          	auipc	ra,0xfffff
    80004dca:	29a080e7          	jalr	666(ra) # 80004060 <readi>
    80004dce:	892a                	mv	s2,a0
    80004dd0:	00a05563          	blez	a0,80004dda <fileread+0x56>
      f->off += r;
    80004dd4:	509c                	lw	a5,32(s1)
    80004dd6:	9fa9                	addw	a5,a5,a0
    80004dd8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004dda:	6c88                	ld	a0,24(s1)
    80004ddc:	fffff097          	auipc	ra,0xfffff
    80004de0:	092080e7          	jalr	146(ra) # 80003e6e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004de4:	854a                	mv	a0,s2
    80004de6:	70a2                	ld	ra,40(sp)
    80004de8:	7402                	ld	s0,32(sp)
    80004dea:	64e2                	ld	s1,24(sp)
    80004dec:	6942                	ld	s2,16(sp)
    80004dee:	69a2                	ld	s3,8(sp)
    80004df0:	6145                	addi	sp,sp,48
    80004df2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004df4:	6908                	ld	a0,16(a0)
    80004df6:	00000097          	auipc	ra,0x0
    80004dfa:	3c8080e7          	jalr	968(ra) # 800051be <piperead>
    80004dfe:	892a                	mv	s2,a0
    80004e00:	b7d5                	j	80004de4 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004e02:	02451783          	lh	a5,36(a0)
    80004e06:	03079693          	slli	a3,a5,0x30
    80004e0a:	92c1                	srli	a3,a3,0x30
    80004e0c:	4725                	li	a4,9
    80004e0e:	02d76863          	bltu	a4,a3,80004e3e <fileread+0xba>
    80004e12:	0792                	slli	a5,a5,0x4
    80004e14:	0001d717          	auipc	a4,0x1d
    80004e18:	b0470713          	addi	a4,a4,-1276 # 80021918 <devsw>
    80004e1c:	97ba                	add	a5,a5,a4
    80004e1e:	639c                	ld	a5,0(a5)
    80004e20:	c38d                	beqz	a5,80004e42 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004e22:	4505                	li	a0,1
    80004e24:	9782                	jalr	a5
    80004e26:	892a                	mv	s2,a0
    80004e28:	bf75                	j	80004de4 <fileread+0x60>
    panic("fileread");
    80004e2a:	00004517          	auipc	a0,0x4
    80004e2e:	9b650513          	addi	a0,a0,-1610 # 800087e0 <syscalls+0x290>
    80004e32:	ffffb097          	auipc	ra,0xffffb
    80004e36:	70c080e7          	jalr	1804(ra) # 8000053e <panic>
    return -1;
    80004e3a:	597d                	li	s2,-1
    80004e3c:	b765                	j	80004de4 <fileread+0x60>
      return -1;
    80004e3e:	597d                	li	s2,-1
    80004e40:	b755                	j	80004de4 <fileread+0x60>
    80004e42:	597d                	li	s2,-1
    80004e44:	b745                	j	80004de4 <fileread+0x60>

0000000080004e46 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004e46:	715d                	addi	sp,sp,-80
    80004e48:	e486                	sd	ra,72(sp)
    80004e4a:	e0a2                	sd	s0,64(sp)
    80004e4c:	fc26                	sd	s1,56(sp)
    80004e4e:	f84a                	sd	s2,48(sp)
    80004e50:	f44e                	sd	s3,40(sp)
    80004e52:	f052                	sd	s4,32(sp)
    80004e54:	ec56                	sd	s5,24(sp)
    80004e56:	e85a                	sd	s6,16(sp)
    80004e58:	e45e                	sd	s7,8(sp)
    80004e5a:	e062                	sd	s8,0(sp)
    80004e5c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004e5e:	00954783          	lbu	a5,9(a0)
    80004e62:	10078663          	beqz	a5,80004f6e <filewrite+0x128>
    80004e66:	892a                	mv	s2,a0
    80004e68:	8aae                	mv	s5,a1
    80004e6a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e6c:	411c                	lw	a5,0(a0)
    80004e6e:	4705                	li	a4,1
    80004e70:	02e78263          	beq	a5,a4,80004e94 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e74:	470d                	li	a4,3
    80004e76:	02e78663          	beq	a5,a4,80004ea2 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e7a:	4709                	li	a4,2
    80004e7c:	0ee79163          	bne	a5,a4,80004f5e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004e80:	0ac05d63          	blez	a2,80004f3a <filewrite+0xf4>
    int i = 0;
    80004e84:	4981                	li	s3,0
    80004e86:	6b05                	lui	s6,0x1
    80004e88:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004e8c:	6b85                	lui	s7,0x1
    80004e8e:	c00b8b9b          	addiw	s7,s7,-1024
    80004e92:	a861                	j	80004f2a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004e94:	6908                	ld	a0,16(a0)
    80004e96:	00000097          	auipc	ra,0x0
    80004e9a:	22e080e7          	jalr	558(ra) # 800050c4 <pipewrite>
    80004e9e:	8a2a                	mv	s4,a0
    80004ea0:	a045                	j	80004f40 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ea2:	02451783          	lh	a5,36(a0)
    80004ea6:	03079693          	slli	a3,a5,0x30
    80004eaa:	92c1                	srli	a3,a3,0x30
    80004eac:	4725                	li	a4,9
    80004eae:	0cd76263          	bltu	a4,a3,80004f72 <filewrite+0x12c>
    80004eb2:	0792                	slli	a5,a5,0x4
    80004eb4:	0001d717          	auipc	a4,0x1d
    80004eb8:	a6470713          	addi	a4,a4,-1436 # 80021918 <devsw>
    80004ebc:	97ba                	add	a5,a5,a4
    80004ebe:	679c                	ld	a5,8(a5)
    80004ec0:	cbdd                	beqz	a5,80004f76 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004ec2:	4505                	li	a0,1
    80004ec4:	9782                	jalr	a5
    80004ec6:	8a2a                	mv	s4,a0
    80004ec8:	a8a5                	j	80004f40 <filewrite+0xfa>
    80004eca:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004ece:	00000097          	auipc	ra,0x0
    80004ed2:	8b0080e7          	jalr	-1872(ra) # 8000477e <begin_op>
      ilock(f->ip);
    80004ed6:	01893503          	ld	a0,24(s2)
    80004eda:	fffff097          	auipc	ra,0xfffff
    80004ede:	ed2080e7          	jalr	-302(ra) # 80003dac <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ee2:	8762                	mv	a4,s8
    80004ee4:	02092683          	lw	a3,32(s2)
    80004ee8:	01598633          	add	a2,s3,s5
    80004eec:	4585                	li	a1,1
    80004eee:	01893503          	ld	a0,24(s2)
    80004ef2:	fffff097          	auipc	ra,0xfffff
    80004ef6:	266080e7          	jalr	614(ra) # 80004158 <writei>
    80004efa:	84aa                	mv	s1,a0
    80004efc:	00a05763          	blez	a0,80004f0a <filewrite+0xc4>
        f->off += r;
    80004f00:	02092783          	lw	a5,32(s2)
    80004f04:	9fa9                	addw	a5,a5,a0
    80004f06:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004f0a:	01893503          	ld	a0,24(s2)
    80004f0e:	fffff097          	auipc	ra,0xfffff
    80004f12:	f60080e7          	jalr	-160(ra) # 80003e6e <iunlock>
      end_op();
    80004f16:	00000097          	auipc	ra,0x0
    80004f1a:	8e8080e7          	jalr	-1816(ra) # 800047fe <end_op>

      if(r != n1){
    80004f1e:	009c1f63          	bne	s8,s1,80004f3c <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004f22:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004f26:	0149db63          	bge	s3,s4,80004f3c <filewrite+0xf6>
      int n1 = n - i;
    80004f2a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004f2e:	84be                	mv	s1,a5
    80004f30:	2781                	sext.w	a5,a5
    80004f32:	f8fb5ce3          	bge	s6,a5,80004eca <filewrite+0x84>
    80004f36:	84de                	mv	s1,s7
    80004f38:	bf49                	j	80004eca <filewrite+0x84>
    int i = 0;
    80004f3a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004f3c:	013a1f63          	bne	s4,s3,80004f5a <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004f40:	8552                	mv	a0,s4
    80004f42:	60a6                	ld	ra,72(sp)
    80004f44:	6406                	ld	s0,64(sp)
    80004f46:	74e2                	ld	s1,56(sp)
    80004f48:	7942                	ld	s2,48(sp)
    80004f4a:	79a2                	ld	s3,40(sp)
    80004f4c:	7a02                	ld	s4,32(sp)
    80004f4e:	6ae2                	ld	s5,24(sp)
    80004f50:	6b42                	ld	s6,16(sp)
    80004f52:	6ba2                	ld	s7,8(sp)
    80004f54:	6c02                	ld	s8,0(sp)
    80004f56:	6161                	addi	sp,sp,80
    80004f58:	8082                	ret
    ret = (i == n ? n : -1);
    80004f5a:	5a7d                	li	s4,-1
    80004f5c:	b7d5                	j	80004f40 <filewrite+0xfa>
    panic("filewrite");
    80004f5e:	00004517          	auipc	a0,0x4
    80004f62:	89250513          	addi	a0,a0,-1902 # 800087f0 <syscalls+0x2a0>
    80004f66:	ffffb097          	auipc	ra,0xffffb
    80004f6a:	5d8080e7          	jalr	1496(ra) # 8000053e <panic>
    return -1;
    80004f6e:	5a7d                	li	s4,-1
    80004f70:	bfc1                	j	80004f40 <filewrite+0xfa>
      return -1;
    80004f72:	5a7d                	li	s4,-1
    80004f74:	b7f1                	j	80004f40 <filewrite+0xfa>
    80004f76:	5a7d                	li	s4,-1
    80004f78:	b7e1                	j	80004f40 <filewrite+0xfa>

0000000080004f7a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004f7a:	7179                	addi	sp,sp,-48
    80004f7c:	f406                	sd	ra,40(sp)
    80004f7e:	f022                	sd	s0,32(sp)
    80004f80:	ec26                	sd	s1,24(sp)
    80004f82:	e84a                	sd	s2,16(sp)
    80004f84:	e44e                	sd	s3,8(sp)
    80004f86:	e052                	sd	s4,0(sp)
    80004f88:	1800                	addi	s0,sp,48
    80004f8a:	84aa                	mv	s1,a0
    80004f8c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004f8e:	0005b023          	sd	zero,0(a1)
    80004f92:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004f96:	00000097          	auipc	ra,0x0
    80004f9a:	bf8080e7          	jalr	-1032(ra) # 80004b8e <filealloc>
    80004f9e:	e088                	sd	a0,0(s1)
    80004fa0:	c551                	beqz	a0,8000502c <pipealloc+0xb2>
    80004fa2:	00000097          	auipc	ra,0x0
    80004fa6:	bec080e7          	jalr	-1044(ra) # 80004b8e <filealloc>
    80004faa:	00aa3023          	sd	a0,0(s4)
    80004fae:	c92d                	beqz	a0,80005020 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004fb0:	ffffc097          	auipc	ra,0xffffc
    80004fb4:	b44080e7          	jalr	-1212(ra) # 80000af4 <kalloc>
    80004fb8:	892a                	mv	s2,a0
    80004fba:	c125                	beqz	a0,8000501a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004fbc:	4985                	li	s3,1
    80004fbe:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004fc2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004fc6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004fca:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004fce:	00004597          	auipc	a1,0x4
    80004fd2:	83258593          	addi	a1,a1,-1998 # 80008800 <syscalls+0x2b0>
    80004fd6:	ffffc097          	auipc	ra,0xffffc
    80004fda:	b7e080e7          	jalr	-1154(ra) # 80000b54 <initlock>
  (*f0)->type = FD_PIPE;
    80004fde:	609c                	ld	a5,0(s1)
    80004fe0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004fe4:	609c                	ld	a5,0(s1)
    80004fe6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004fea:	609c                	ld	a5,0(s1)
    80004fec:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ff0:	609c                	ld	a5,0(s1)
    80004ff2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ff6:	000a3783          	ld	a5,0(s4)
    80004ffa:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ffe:	000a3783          	ld	a5,0(s4)
    80005002:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005006:	000a3783          	ld	a5,0(s4)
    8000500a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000500e:	000a3783          	ld	a5,0(s4)
    80005012:	0127b823          	sd	s2,16(a5)
  return 0;
    80005016:	4501                	li	a0,0
    80005018:	a025                	j	80005040 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000501a:	6088                	ld	a0,0(s1)
    8000501c:	e501                	bnez	a0,80005024 <pipealloc+0xaa>
    8000501e:	a039                	j	8000502c <pipealloc+0xb2>
    80005020:	6088                	ld	a0,0(s1)
    80005022:	c51d                	beqz	a0,80005050 <pipealloc+0xd6>
    fileclose(*f0);
    80005024:	00000097          	auipc	ra,0x0
    80005028:	c26080e7          	jalr	-986(ra) # 80004c4a <fileclose>
  if(*f1)
    8000502c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005030:	557d                	li	a0,-1
  if(*f1)
    80005032:	c799                	beqz	a5,80005040 <pipealloc+0xc6>
    fileclose(*f1);
    80005034:	853e                	mv	a0,a5
    80005036:	00000097          	auipc	ra,0x0
    8000503a:	c14080e7          	jalr	-1004(ra) # 80004c4a <fileclose>
  return -1;
    8000503e:	557d                	li	a0,-1
}
    80005040:	70a2                	ld	ra,40(sp)
    80005042:	7402                	ld	s0,32(sp)
    80005044:	64e2                	ld	s1,24(sp)
    80005046:	6942                	ld	s2,16(sp)
    80005048:	69a2                	ld	s3,8(sp)
    8000504a:	6a02                	ld	s4,0(sp)
    8000504c:	6145                	addi	sp,sp,48
    8000504e:	8082                	ret
  return -1;
    80005050:	557d                	li	a0,-1
    80005052:	b7fd                	j	80005040 <pipealloc+0xc6>

0000000080005054 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005054:	1101                	addi	sp,sp,-32
    80005056:	ec06                	sd	ra,24(sp)
    80005058:	e822                	sd	s0,16(sp)
    8000505a:	e426                	sd	s1,8(sp)
    8000505c:	e04a                	sd	s2,0(sp)
    8000505e:	1000                	addi	s0,sp,32
    80005060:	84aa                	mv	s1,a0
    80005062:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005064:	ffffc097          	auipc	ra,0xffffc
    80005068:	b80080e7          	jalr	-1152(ra) # 80000be4 <acquire>
  if(writable){
    8000506c:	02090d63          	beqz	s2,800050a6 <pipeclose+0x52>
    pi->writeopen = 0;
    80005070:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005074:	21848513          	addi	a0,s1,536
    80005078:	ffffd097          	auipc	ra,0xffffd
    8000507c:	4ac080e7          	jalr	1196(ra) # 80002524 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005080:	2204b783          	ld	a5,544(s1)
    80005084:	eb95                	bnez	a5,800050b8 <pipeclose+0x64>
    release(&pi->lock);
    80005086:	8526                	mv	a0,s1
    80005088:	ffffc097          	auipc	ra,0xffffc
    8000508c:	c10080e7          	jalr	-1008(ra) # 80000c98 <release>
    kfree((char*)pi);
    80005090:	8526                	mv	a0,s1
    80005092:	ffffc097          	auipc	ra,0xffffc
    80005096:	966080e7          	jalr	-1690(ra) # 800009f8 <kfree>
  } else
    release(&pi->lock);
}
    8000509a:	60e2                	ld	ra,24(sp)
    8000509c:	6442                	ld	s0,16(sp)
    8000509e:	64a2                	ld	s1,8(sp)
    800050a0:	6902                	ld	s2,0(sp)
    800050a2:	6105                	addi	sp,sp,32
    800050a4:	8082                	ret
    pi->readopen = 0;
    800050a6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800050aa:	21c48513          	addi	a0,s1,540
    800050ae:	ffffd097          	auipc	ra,0xffffd
    800050b2:	476080e7          	jalr	1142(ra) # 80002524 <wakeup>
    800050b6:	b7e9                	j	80005080 <pipeclose+0x2c>
    release(&pi->lock);
    800050b8:	8526                	mv	a0,s1
    800050ba:	ffffc097          	auipc	ra,0xffffc
    800050be:	bde080e7          	jalr	-1058(ra) # 80000c98 <release>
}
    800050c2:	bfe1                	j	8000509a <pipeclose+0x46>

00000000800050c4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800050c4:	7159                	addi	sp,sp,-112
    800050c6:	f486                	sd	ra,104(sp)
    800050c8:	f0a2                	sd	s0,96(sp)
    800050ca:	eca6                	sd	s1,88(sp)
    800050cc:	e8ca                	sd	s2,80(sp)
    800050ce:	e4ce                	sd	s3,72(sp)
    800050d0:	e0d2                	sd	s4,64(sp)
    800050d2:	fc56                	sd	s5,56(sp)
    800050d4:	f85a                	sd	s6,48(sp)
    800050d6:	f45e                	sd	s7,40(sp)
    800050d8:	f062                	sd	s8,32(sp)
    800050da:	ec66                	sd	s9,24(sp)
    800050dc:	1880                	addi	s0,sp,112
    800050de:	84aa                	mv	s1,a0
    800050e0:	8aae                	mv	s5,a1
    800050e2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800050e4:	ffffd097          	auipc	ra,0xffffd
    800050e8:	8cc080e7          	jalr	-1844(ra) # 800019b0 <myproc>
    800050ec:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800050ee:	8526                	mv	a0,s1
    800050f0:	ffffc097          	auipc	ra,0xffffc
    800050f4:	af4080e7          	jalr	-1292(ra) # 80000be4 <acquire>
  while(i < n){
    800050f8:	0d405163          	blez	s4,800051ba <pipewrite+0xf6>
    800050fc:	8ba6                	mv	s7,s1
  int i = 0;
    800050fe:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005100:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005102:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005106:	21c48c13          	addi	s8,s1,540
    8000510a:	a08d                	j	8000516c <pipewrite+0xa8>
      release(&pi->lock);
    8000510c:	8526                	mv	a0,s1
    8000510e:	ffffc097          	auipc	ra,0xffffc
    80005112:	b8a080e7          	jalr	-1142(ra) # 80000c98 <release>
      return -1;
    80005116:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005118:	854a                	mv	a0,s2
    8000511a:	70a6                	ld	ra,104(sp)
    8000511c:	7406                	ld	s0,96(sp)
    8000511e:	64e6                	ld	s1,88(sp)
    80005120:	6946                	ld	s2,80(sp)
    80005122:	69a6                	ld	s3,72(sp)
    80005124:	6a06                	ld	s4,64(sp)
    80005126:	7ae2                	ld	s5,56(sp)
    80005128:	7b42                	ld	s6,48(sp)
    8000512a:	7ba2                	ld	s7,40(sp)
    8000512c:	7c02                	ld	s8,32(sp)
    8000512e:	6ce2                	ld	s9,24(sp)
    80005130:	6165                	addi	sp,sp,112
    80005132:	8082                	ret
      wakeup(&pi->nread);
    80005134:	8566                	mv	a0,s9
    80005136:	ffffd097          	auipc	ra,0xffffd
    8000513a:	3ee080e7          	jalr	1006(ra) # 80002524 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000513e:	85de                	mv	a1,s7
    80005140:	8562                	mv	a0,s8
    80005142:	ffffd097          	auipc	ra,0xffffd
    80005146:	122080e7          	jalr	290(ra) # 80002264 <sleep>
    8000514a:	a839                	j	80005168 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000514c:	21c4a783          	lw	a5,540(s1)
    80005150:	0017871b          	addiw	a4,a5,1
    80005154:	20e4ae23          	sw	a4,540(s1)
    80005158:	1ff7f793          	andi	a5,a5,511
    8000515c:	97a6                	add	a5,a5,s1
    8000515e:	f9f44703          	lbu	a4,-97(s0)
    80005162:	00e78c23          	sb	a4,24(a5)
      i++;
    80005166:	2905                	addiw	s2,s2,1
  while(i < n){
    80005168:	03495d63          	bge	s2,s4,800051a2 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    8000516c:	2204a783          	lw	a5,544(s1)
    80005170:	dfd1                	beqz	a5,8000510c <pipewrite+0x48>
    80005172:	0289a783          	lw	a5,40(s3)
    80005176:	fbd9                	bnez	a5,8000510c <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005178:	2184a783          	lw	a5,536(s1)
    8000517c:	21c4a703          	lw	a4,540(s1)
    80005180:	2007879b          	addiw	a5,a5,512
    80005184:	faf708e3          	beq	a4,a5,80005134 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005188:	4685                	li	a3,1
    8000518a:	01590633          	add	a2,s2,s5
    8000518e:	f9f40593          	addi	a1,s0,-97
    80005192:	0509b503          	ld	a0,80(s3)
    80005196:	ffffc097          	auipc	ra,0xffffc
    8000519a:	568080e7          	jalr	1384(ra) # 800016fe <copyin>
    8000519e:	fb6517e3          	bne	a0,s6,8000514c <pipewrite+0x88>
  wakeup(&pi->nread);
    800051a2:	21848513          	addi	a0,s1,536
    800051a6:	ffffd097          	auipc	ra,0xffffd
    800051aa:	37e080e7          	jalr	894(ra) # 80002524 <wakeup>
  release(&pi->lock);
    800051ae:	8526                	mv	a0,s1
    800051b0:	ffffc097          	auipc	ra,0xffffc
    800051b4:	ae8080e7          	jalr	-1304(ra) # 80000c98 <release>
  return i;
    800051b8:	b785                	j	80005118 <pipewrite+0x54>
  int i = 0;
    800051ba:	4901                	li	s2,0
    800051bc:	b7dd                	j	800051a2 <pipewrite+0xde>

00000000800051be <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800051be:	715d                	addi	sp,sp,-80
    800051c0:	e486                	sd	ra,72(sp)
    800051c2:	e0a2                	sd	s0,64(sp)
    800051c4:	fc26                	sd	s1,56(sp)
    800051c6:	f84a                	sd	s2,48(sp)
    800051c8:	f44e                	sd	s3,40(sp)
    800051ca:	f052                	sd	s4,32(sp)
    800051cc:	ec56                	sd	s5,24(sp)
    800051ce:	e85a                	sd	s6,16(sp)
    800051d0:	0880                	addi	s0,sp,80
    800051d2:	84aa                	mv	s1,a0
    800051d4:	892e                	mv	s2,a1
    800051d6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800051d8:	ffffc097          	auipc	ra,0xffffc
    800051dc:	7d8080e7          	jalr	2008(ra) # 800019b0 <myproc>
    800051e0:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800051e2:	8b26                	mv	s6,s1
    800051e4:	8526                	mv	a0,s1
    800051e6:	ffffc097          	auipc	ra,0xffffc
    800051ea:	9fe080e7          	jalr	-1538(ra) # 80000be4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800051ee:	2184a703          	lw	a4,536(s1)
    800051f2:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800051f6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800051fa:	02f71463          	bne	a4,a5,80005222 <piperead+0x64>
    800051fe:	2244a783          	lw	a5,548(s1)
    80005202:	c385                	beqz	a5,80005222 <piperead+0x64>
    if(pr->killed){
    80005204:	028a2783          	lw	a5,40(s4)
    80005208:	ebc1                	bnez	a5,80005298 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000520a:	85da                	mv	a1,s6
    8000520c:	854e                	mv	a0,s3
    8000520e:	ffffd097          	auipc	ra,0xffffd
    80005212:	056080e7          	jalr	86(ra) # 80002264 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005216:	2184a703          	lw	a4,536(s1)
    8000521a:	21c4a783          	lw	a5,540(s1)
    8000521e:	fef700e3          	beq	a4,a5,800051fe <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005222:	09505263          	blez	s5,800052a6 <piperead+0xe8>
    80005226:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005228:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    8000522a:	2184a783          	lw	a5,536(s1)
    8000522e:	21c4a703          	lw	a4,540(s1)
    80005232:	02f70d63          	beq	a4,a5,8000526c <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005236:	0017871b          	addiw	a4,a5,1
    8000523a:	20e4ac23          	sw	a4,536(s1)
    8000523e:	1ff7f793          	andi	a5,a5,511
    80005242:	97a6                	add	a5,a5,s1
    80005244:	0187c783          	lbu	a5,24(a5)
    80005248:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000524c:	4685                	li	a3,1
    8000524e:	fbf40613          	addi	a2,s0,-65
    80005252:	85ca                	mv	a1,s2
    80005254:	050a3503          	ld	a0,80(s4)
    80005258:	ffffc097          	auipc	ra,0xffffc
    8000525c:	41a080e7          	jalr	1050(ra) # 80001672 <copyout>
    80005260:	01650663          	beq	a0,s6,8000526c <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005264:	2985                	addiw	s3,s3,1
    80005266:	0905                	addi	s2,s2,1
    80005268:	fd3a91e3          	bne	s5,s3,8000522a <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000526c:	21c48513          	addi	a0,s1,540
    80005270:	ffffd097          	auipc	ra,0xffffd
    80005274:	2b4080e7          	jalr	692(ra) # 80002524 <wakeup>
  release(&pi->lock);
    80005278:	8526                	mv	a0,s1
    8000527a:	ffffc097          	auipc	ra,0xffffc
    8000527e:	a1e080e7          	jalr	-1506(ra) # 80000c98 <release>
  return i;
}
    80005282:	854e                	mv	a0,s3
    80005284:	60a6                	ld	ra,72(sp)
    80005286:	6406                	ld	s0,64(sp)
    80005288:	74e2                	ld	s1,56(sp)
    8000528a:	7942                	ld	s2,48(sp)
    8000528c:	79a2                	ld	s3,40(sp)
    8000528e:	7a02                	ld	s4,32(sp)
    80005290:	6ae2                	ld	s5,24(sp)
    80005292:	6b42                	ld	s6,16(sp)
    80005294:	6161                	addi	sp,sp,80
    80005296:	8082                	ret
      release(&pi->lock);
    80005298:	8526                	mv	a0,s1
    8000529a:	ffffc097          	auipc	ra,0xffffc
    8000529e:	9fe080e7          	jalr	-1538(ra) # 80000c98 <release>
      return -1;
    800052a2:	59fd                	li	s3,-1
    800052a4:	bff9                	j	80005282 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800052a6:	4981                	li	s3,0
    800052a8:	b7d1                	j	8000526c <piperead+0xae>

00000000800052aa <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800052aa:	df010113          	addi	sp,sp,-528
    800052ae:	20113423          	sd	ra,520(sp)
    800052b2:	20813023          	sd	s0,512(sp)
    800052b6:	ffa6                	sd	s1,504(sp)
    800052b8:	fbca                	sd	s2,496(sp)
    800052ba:	f7ce                	sd	s3,488(sp)
    800052bc:	f3d2                	sd	s4,480(sp)
    800052be:	efd6                	sd	s5,472(sp)
    800052c0:	ebda                	sd	s6,464(sp)
    800052c2:	e7de                	sd	s7,456(sp)
    800052c4:	e3e2                	sd	s8,448(sp)
    800052c6:	ff66                	sd	s9,440(sp)
    800052c8:	fb6a                	sd	s10,432(sp)
    800052ca:	f76e                	sd	s11,424(sp)
    800052cc:	0c00                	addi	s0,sp,528
    800052ce:	84aa                	mv	s1,a0
    800052d0:	dea43c23          	sd	a0,-520(s0)
    800052d4:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800052d8:	ffffc097          	auipc	ra,0xffffc
    800052dc:	6d8080e7          	jalr	1752(ra) # 800019b0 <myproc>
    800052e0:	892a                	mv	s2,a0

  begin_op();
    800052e2:	fffff097          	auipc	ra,0xfffff
    800052e6:	49c080e7          	jalr	1180(ra) # 8000477e <begin_op>

  if((ip = namei(path)) == 0){
    800052ea:	8526                	mv	a0,s1
    800052ec:	fffff097          	auipc	ra,0xfffff
    800052f0:	276080e7          	jalr	630(ra) # 80004562 <namei>
    800052f4:	c92d                	beqz	a0,80005366 <exec+0xbc>
    800052f6:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800052f8:	fffff097          	auipc	ra,0xfffff
    800052fc:	ab4080e7          	jalr	-1356(ra) # 80003dac <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005300:	04000713          	li	a4,64
    80005304:	4681                	li	a3,0
    80005306:	e5040613          	addi	a2,s0,-432
    8000530a:	4581                	li	a1,0
    8000530c:	8526                	mv	a0,s1
    8000530e:	fffff097          	auipc	ra,0xfffff
    80005312:	d52080e7          	jalr	-686(ra) # 80004060 <readi>
    80005316:	04000793          	li	a5,64
    8000531a:	00f51a63          	bne	a0,a5,8000532e <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000531e:	e5042703          	lw	a4,-432(s0)
    80005322:	464c47b7          	lui	a5,0x464c4
    80005326:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000532a:	04f70463          	beq	a4,a5,80005372 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000532e:	8526                	mv	a0,s1
    80005330:	fffff097          	auipc	ra,0xfffff
    80005334:	cde080e7          	jalr	-802(ra) # 8000400e <iunlockput>
    end_op();
    80005338:	fffff097          	auipc	ra,0xfffff
    8000533c:	4c6080e7          	jalr	1222(ra) # 800047fe <end_op>
  }
  return -1;
    80005340:	557d                	li	a0,-1
}
    80005342:	20813083          	ld	ra,520(sp)
    80005346:	20013403          	ld	s0,512(sp)
    8000534a:	74fe                	ld	s1,504(sp)
    8000534c:	795e                	ld	s2,496(sp)
    8000534e:	79be                	ld	s3,488(sp)
    80005350:	7a1e                	ld	s4,480(sp)
    80005352:	6afe                	ld	s5,472(sp)
    80005354:	6b5e                	ld	s6,464(sp)
    80005356:	6bbe                	ld	s7,456(sp)
    80005358:	6c1e                	ld	s8,448(sp)
    8000535a:	7cfa                	ld	s9,440(sp)
    8000535c:	7d5a                	ld	s10,432(sp)
    8000535e:	7dba                	ld	s11,424(sp)
    80005360:	21010113          	addi	sp,sp,528
    80005364:	8082                	ret
    end_op();
    80005366:	fffff097          	auipc	ra,0xfffff
    8000536a:	498080e7          	jalr	1176(ra) # 800047fe <end_op>
    return -1;
    8000536e:	557d                	li	a0,-1
    80005370:	bfc9                	j	80005342 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80005372:	854a                	mv	a0,s2
    80005374:	ffffc097          	auipc	ra,0xffffc
    80005378:	748080e7          	jalr	1864(ra) # 80001abc <proc_pagetable>
    8000537c:	8baa                	mv	s7,a0
    8000537e:	d945                	beqz	a0,8000532e <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005380:	e7042983          	lw	s3,-400(s0)
    80005384:	e8845783          	lhu	a5,-376(s0)
    80005388:	c7ad                	beqz	a5,800053f2 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000538a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000538c:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    8000538e:	6c85                	lui	s9,0x1
    80005390:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005394:	def43823          	sd	a5,-528(s0)
    80005398:	a42d                	j	800055c2 <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000539a:	00003517          	auipc	a0,0x3
    8000539e:	46e50513          	addi	a0,a0,1134 # 80008808 <syscalls+0x2b8>
    800053a2:	ffffb097          	auipc	ra,0xffffb
    800053a6:	19c080e7          	jalr	412(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800053aa:	8756                	mv	a4,s5
    800053ac:	012d86bb          	addw	a3,s11,s2
    800053b0:	4581                	li	a1,0
    800053b2:	8526                	mv	a0,s1
    800053b4:	fffff097          	auipc	ra,0xfffff
    800053b8:	cac080e7          	jalr	-852(ra) # 80004060 <readi>
    800053bc:	2501                	sext.w	a0,a0
    800053be:	1aaa9963          	bne	s5,a0,80005570 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    800053c2:	6785                	lui	a5,0x1
    800053c4:	0127893b          	addw	s2,a5,s2
    800053c8:	77fd                	lui	a5,0xfffff
    800053ca:	01478a3b          	addw	s4,a5,s4
    800053ce:	1f897163          	bgeu	s2,s8,800055b0 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    800053d2:	02091593          	slli	a1,s2,0x20
    800053d6:	9181                	srli	a1,a1,0x20
    800053d8:	95ea                	add	a1,a1,s10
    800053da:	855e                	mv	a0,s7
    800053dc:	ffffc097          	auipc	ra,0xffffc
    800053e0:	c92080e7          	jalr	-878(ra) # 8000106e <walkaddr>
    800053e4:	862a                	mv	a2,a0
    if(pa == 0)
    800053e6:	d955                	beqz	a0,8000539a <exec+0xf0>
      n = PGSIZE;
    800053e8:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800053ea:	fd9a70e3          	bgeu	s4,s9,800053aa <exec+0x100>
      n = sz - i;
    800053ee:	8ad2                	mv	s5,s4
    800053f0:	bf6d                	j	800053aa <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800053f2:	4901                	li	s2,0
  iunlockput(ip);
    800053f4:	8526                	mv	a0,s1
    800053f6:	fffff097          	auipc	ra,0xfffff
    800053fa:	c18080e7          	jalr	-1000(ra) # 8000400e <iunlockput>
  end_op();
    800053fe:	fffff097          	auipc	ra,0xfffff
    80005402:	400080e7          	jalr	1024(ra) # 800047fe <end_op>
  p = myproc();
    80005406:	ffffc097          	auipc	ra,0xffffc
    8000540a:	5aa080e7          	jalr	1450(ra) # 800019b0 <myproc>
    8000540e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005410:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005414:	6785                	lui	a5,0x1
    80005416:	17fd                	addi	a5,a5,-1
    80005418:	993e                	add	s2,s2,a5
    8000541a:	757d                	lui	a0,0xfffff
    8000541c:	00a977b3          	and	a5,s2,a0
    80005420:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005424:	6609                	lui	a2,0x2
    80005426:	963e                	add	a2,a2,a5
    80005428:	85be                	mv	a1,a5
    8000542a:	855e                	mv	a0,s7
    8000542c:	ffffc097          	auipc	ra,0xffffc
    80005430:	ff6080e7          	jalr	-10(ra) # 80001422 <uvmalloc>
    80005434:	8b2a                	mv	s6,a0
  ip = 0;
    80005436:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005438:	12050c63          	beqz	a0,80005570 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000543c:	75f9                	lui	a1,0xffffe
    8000543e:	95aa                	add	a1,a1,a0
    80005440:	855e                	mv	a0,s7
    80005442:	ffffc097          	auipc	ra,0xffffc
    80005446:	1fe080e7          	jalr	510(ra) # 80001640 <uvmclear>
  stackbase = sp - PGSIZE;
    8000544a:	7c7d                	lui	s8,0xfffff
    8000544c:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000544e:	e0043783          	ld	a5,-512(s0)
    80005452:	6388                	ld	a0,0(a5)
    80005454:	c535                	beqz	a0,800054c0 <exec+0x216>
    80005456:	e9040993          	addi	s3,s0,-368
    8000545a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000545e:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005460:	ffffc097          	auipc	ra,0xffffc
    80005464:	a04080e7          	jalr	-1532(ra) # 80000e64 <strlen>
    80005468:	2505                	addiw	a0,a0,1
    8000546a:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000546e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005472:	13896363          	bltu	s2,s8,80005598 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005476:	e0043d83          	ld	s11,-512(s0)
    8000547a:	000dba03          	ld	s4,0(s11)
    8000547e:	8552                	mv	a0,s4
    80005480:	ffffc097          	auipc	ra,0xffffc
    80005484:	9e4080e7          	jalr	-1564(ra) # 80000e64 <strlen>
    80005488:	0015069b          	addiw	a3,a0,1
    8000548c:	8652                	mv	a2,s4
    8000548e:	85ca                	mv	a1,s2
    80005490:	855e                	mv	a0,s7
    80005492:	ffffc097          	auipc	ra,0xffffc
    80005496:	1e0080e7          	jalr	480(ra) # 80001672 <copyout>
    8000549a:	10054363          	bltz	a0,800055a0 <exec+0x2f6>
    ustack[argc] = sp;
    8000549e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800054a2:	0485                	addi	s1,s1,1
    800054a4:	008d8793          	addi	a5,s11,8
    800054a8:	e0f43023          	sd	a5,-512(s0)
    800054ac:	008db503          	ld	a0,8(s11)
    800054b0:	c911                	beqz	a0,800054c4 <exec+0x21a>
    if(argc >= MAXARG)
    800054b2:	09a1                	addi	s3,s3,8
    800054b4:	fb3c96e3          	bne	s9,s3,80005460 <exec+0x1b6>
  sz = sz1;
    800054b8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800054bc:	4481                	li	s1,0
    800054be:	a84d                	j	80005570 <exec+0x2c6>
  sp = sz;
    800054c0:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800054c2:	4481                	li	s1,0
  ustack[argc] = 0;
    800054c4:	00349793          	slli	a5,s1,0x3
    800054c8:	f9040713          	addi	a4,s0,-112
    800054cc:	97ba                	add	a5,a5,a4
    800054ce:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800054d2:	00148693          	addi	a3,s1,1
    800054d6:	068e                	slli	a3,a3,0x3
    800054d8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800054dc:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800054e0:	01897663          	bgeu	s2,s8,800054ec <exec+0x242>
  sz = sz1;
    800054e4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800054e8:	4481                	li	s1,0
    800054ea:	a059                	j	80005570 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800054ec:	e9040613          	addi	a2,s0,-368
    800054f0:	85ca                	mv	a1,s2
    800054f2:	855e                	mv	a0,s7
    800054f4:	ffffc097          	auipc	ra,0xffffc
    800054f8:	17e080e7          	jalr	382(ra) # 80001672 <copyout>
    800054fc:	0a054663          	bltz	a0,800055a8 <exec+0x2fe>
  p->trapframe->a1 = sp;
    80005500:	058ab783          	ld	a5,88(s5)
    80005504:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005508:	df843783          	ld	a5,-520(s0)
    8000550c:	0007c703          	lbu	a4,0(a5)
    80005510:	cf11                	beqz	a4,8000552c <exec+0x282>
    80005512:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005514:	02f00693          	li	a3,47
    80005518:	a039                	j	80005526 <exec+0x27c>
      last = s+1;
    8000551a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000551e:	0785                	addi	a5,a5,1
    80005520:	fff7c703          	lbu	a4,-1(a5)
    80005524:	c701                	beqz	a4,8000552c <exec+0x282>
    if(*s == '/')
    80005526:	fed71ce3          	bne	a4,a3,8000551e <exec+0x274>
    8000552a:	bfc5                	j	8000551a <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    8000552c:	4641                	li	a2,16
    8000552e:	df843583          	ld	a1,-520(s0)
    80005532:	158a8513          	addi	a0,s5,344
    80005536:	ffffc097          	auipc	ra,0xffffc
    8000553a:	8fc080e7          	jalr	-1796(ra) # 80000e32 <safestrcpy>
  oldpagetable = p->pagetable;
    8000553e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005542:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80005546:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000554a:	058ab783          	ld	a5,88(s5)
    8000554e:	e6843703          	ld	a4,-408(s0)
    80005552:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005554:	058ab783          	ld	a5,88(s5)
    80005558:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000555c:	85ea                	mv	a1,s10
    8000555e:	ffffc097          	auipc	ra,0xffffc
    80005562:	5fa080e7          	jalr	1530(ra) # 80001b58 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005566:	0004851b          	sext.w	a0,s1
    8000556a:	bbe1                	j	80005342 <exec+0x98>
    8000556c:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005570:	e0843583          	ld	a1,-504(s0)
    80005574:	855e                	mv	a0,s7
    80005576:	ffffc097          	auipc	ra,0xffffc
    8000557a:	5e2080e7          	jalr	1506(ra) # 80001b58 <proc_freepagetable>
  if(ip){
    8000557e:	da0498e3          	bnez	s1,8000532e <exec+0x84>
  return -1;
    80005582:	557d                	li	a0,-1
    80005584:	bb7d                	j	80005342 <exec+0x98>
    80005586:	e1243423          	sd	s2,-504(s0)
    8000558a:	b7dd                	j	80005570 <exec+0x2c6>
    8000558c:	e1243423          	sd	s2,-504(s0)
    80005590:	b7c5                	j	80005570 <exec+0x2c6>
    80005592:	e1243423          	sd	s2,-504(s0)
    80005596:	bfe9                	j	80005570 <exec+0x2c6>
  sz = sz1;
    80005598:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000559c:	4481                	li	s1,0
    8000559e:	bfc9                	j	80005570 <exec+0x2c6>
  sz = sz1;
    800055a0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800055a4:	4481                	li	s1,0
    800055a6:	b7e9                	j	80005570 <exec+0x2c6>
  sz = sz1;
    800055a8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800055ac:	4481                	li	s1,0
    800055ae:	b7c9                	j	80005570 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800055b0:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055b4:	2b05                	addiw	s6,s6,1
    800055b6:	0389899b          	addiw	s3,s3,56
    800055ba:	e8845783          	lhu	a5,-376(s0)
    800055be:	e2fb5be3          	bge	s6,a5,800053f4 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800055c2:	2981                	sext.w	s3,s3
    800055c4:	03800713          	li	a4,56
    800055c8:	86ce                	mv	a3,s3
    800055ca:	e1840613          	addi	a2,s0,-488
    800055ce:	4581                	li	a1,0
    800055d0:	8526                	mv	a0,s1
    800055d2:	fffff097          	auipc	ra,0xfffff
    800055d6:	a8e080e7          	jalr	-1394(ra) # 80004060 <readi>
    800055da:	03800793          	li	a5,56
    800055de:	f8f517e3          	bne	a0,a5,8000556c <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    800055e2:	e1842783          	lw	a5,-488(s0)
    800055e6:	4705                	li	a4,1
    800055e8:	fce796e3          	bne	a5,a4,800055b4 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    800055ec:	e4043603          	ld	a2,-448(s0)
    800055f0:	e3843783          	ld	a5,-456(s0)
    800055f4:	f8f669e3          	bltu	a2,a5,80005586 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800055f8:	e2843783          	ld	a5,-472(s0)
    800055fc:	963e                	add	a2,a2,a5
    800055fe:	f8f667e3          	bltu	a2,a5,8000558c <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005602:	85ca                	mv	a1,s2
    80005604:	855e                	mv	a0,s7
    80005606:	ffffc097          	auipc	ra,0xffffc
    8000560a:	e1c080e7          	jalr	-484(ra) # 80001422 <uvmalloc>
    8000560e:	e0a43423          	sd	a0,-504(s0)
    80005612:	d141                	beqz	a0,80005592 <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    80005614:	e2843d03          	ld	s10,-472(s0)
    80005618:	df043783          	ld	a5,-528(s0)
    8000561c:	00fd77b3          	and	a5,s10,a5
    80005620:	fba1                	bnez	a5,80005570 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005622:	e2042d83          	lw	s11,-480(s0)
    80005626:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000562a:	f80c03e3          	beqz	s8,800055b0 <exec+0x306>
    8000562e:	8a62                	mv	s4,s8
    80005630:	4901                	li	s2,0
    80005632:	b345                	j	800053d2 <exec+0x128>

0000000080005634 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005634:	7179                	addi	sp,sp,-48
    80005636:	f406                	sd	ra,40(sp)
    80005638:	f022                	sd	s0,32(sp)
    8000563a:	ec26                	sd	s1,24(sp)
    8000563c:	e84a                	sd	s2,16(sp)
    8000563e:	1800                	addi	s0,sp,48
    80005640:	892e                	mv	s2,a1
    80005642:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005644:	fdc40593          	addi	a1,s0,-36
    80005648:	ffffe097          	auipc	ra,0xffffe
    8000564c:	aae080e7          	jalr	-1362(ra) # 800030f6 <argint>
    80005650:	04054063          	bltz	a0,80005690 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005654:	fdc42703          	lw	a4,-36(s0)
    80005658:	47bd                	li	a5,15
    8000565a:	02e7ed63          	bltu	a5,a4,80005694 <argfd+0x60>
    8000565e:	ffffc097          	auipc	ra,0xffffc
    80005662:	352080e7          	jalr	850(ra) # 800019b0 <myproc>
    80005666:	fdc42703          	lw	a4,-36(s0)
    8000566a:	01a70793          	addi	a5,a4,26
    8000566e:	078e                	slli	a5,a5,0x3
    80005670:	953e                	add	a0,a0,a5
    80005672:	611c                	ld	a5,0(a0)
    80005674:	c395                	beqz	a5,80005698 <argfd+0x64>
    return -1;
  if(pfd)
    80005676:	00090463          	beqz	s2,8000567e <argfd+0x4a>
    *pfd = fd;
    8000567a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000567e:	4501                	li	a0,0
  if(pf)
    80005680:	c091                	beqz	s1,80005684 <argfd+0x50>
    *pf = f;
    80005682:	e09c                	sd	a5,0(s1)
}
    80005684:	70a2                	ld	ra,40(sp)
    80005686:	7402                	ld	s0,32(sp)
    80005688:	64e2                	ld	s1,24(sp)
    8000568a:	6942                	ld	s2,16(sp)
    8000568c:	6145                	addi	sp,sp,48
    8000568e:	8082                	ret
    return -1;
    80005690:	557d                	li	a0,-1
    80005692:	bfcd                	j	80005684 <argfd+0x50>
    return -1;
    80005694:	557d                	li	a0,-1
    80005696:	b7fd                	j	80005684 <argfd+0x50>
    80005698:	557d                	li	a0,-1
    8000569a:	b7ed                	j	80005684 <argfd+0x50>

000000008000569c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000569c:	1101                	addi	sp,sp,-32
    8000569e:	ec06                	sd	ra,24(sp)
    800056a0:	e822                	sd	s0,16(sp)
    800056a2:	e426                	sd	s1,8(sp)
    800056a4:	1000                	addi	s0,sp,32
    800056a6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800056a8:	ffffc097          	auipc	ra,0xffffc
    800056ac:	308080e7          	jalr	776(ra) # 800019b0 <myproc>
    800056b0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800056b2:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd90d0>
    800056b6:	4501                	li	a0,0
    800056b8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800056ba:	6398                	ld	a4,0(a5)
    800056bc:	cb19                	beqz	a4,800056d2 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800056be:	2505                	addiw	a0,a0,1
    800056c0:	07a1                	addi	a5,a5,8
    800056c2:	fed51ce3          	bne	a0,a3,800056ba <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800056c6:	557d                	li	a0,-1
}
    800056c8:	60e2                	ld	ra,24(sp)
    800056ca:	6442                	ld	s0,16(sp)
    800056cc:	64a2                	ld	s1,8(sp)
    800056ce:	6105                	addi	sp,sp,32
    800056d0:	8082                	ret
      p->ofile[fd] = f;
    800056d2:	01a50793          	addi	a5,a0,26
    800056d6:	078e                	slli	a5,a5,0x3
    800056d8:	963e                	add	a2,a2,a5
    800056da:	e204                	sd	s1,0(a2)
      return fd;
    800056dc:	b7f5                	j	800056c8 <fdalloc+0x2c>

00000000800056de <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800056de:	715d                	addi	sp,sp,-80
    800056e0:	e486                	sd	ra,72(sp)
    800056e2:	e0a2                	sd	s0,64(sp)
    800056e4:	fc26                	sd	s1,56(sp)
    800056e6:	f84a                	sd	s2,48(sp)
    800056e8:	f44e                	sd	s3,40(sp)
    800056ea:	f052                	sd	s4,32(sp)
    800056ec:	ec56                	sd	s5,24(sp)
    800056ee:	0880                	addi	s0,sp,80
    800056f0:	89ae                	mv	s3,a1
    800056f2:	8ab2                	mv	s5,a2
    800056f4:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800056f6:	fb040593          	addi	a1,s0,-80
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	e86080e7          	jalr	-378(ra) # 80004580 <nameiparent>
    80005702:	892a                	mv	s2,a0
    80005704:	12050f63          	beqz	a0,80005842 <create+0x164>
    return 0;

  ilock(dp);
    80005708:	ffffe097          	auipc	ra,0xffffe
    8000570c:	6a4080e7          	jalr	1700(ra) # 80003dac <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005710:	4601                	li	a2,0
    80005712:	fb040593          	addi	a1,s0,-80
    80005716:	854a                	mv	a0,s2
    80005718:	fffff097          	auipc	ra,0xfffff
    8000571c:	b78080e7          	jalr	-1160(ra) # 80004290 <dirlookup>
    80005720:	84aa                	mv	s1,a0
    80005722:	c921                	beqz	a0,80005772 <create+0x94>
    iunlockput(dp);
    80005724:	854a                	mv	a0,s2
    80005726:	fffff097          	auipc	ra,0xfffff
    8000572a:	8e8080e7          	jalr	-1816(ra) # 8000400e <iunlockput>
    ilock(ip);
    8000572e:	8526                	mv	a0,s1
    80005730:	ffffe097          	auipc	ra,0xffffe
    80005734:	67c080e7          	jalr	1660(ra) # 80003dac <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005738:	2981                	sext.w	s3,s3
    8000573a:	4789                	li	a5,2
    8000573c:	02f99463          	bne	s3,a5,80005764 <create+0x86>
    80005740:	0444d783          	lhu	a5,68(s1)
    80005744:	37f9                	addiw	a5,a5,-2
    80005746:	17c2                	slli	a5,a5,0x30
    80005748:	93c1                	srli	a5,a5,0x30
    8000574a:	4705                	li	a4,1
    8000574c:	00f76c63          	bltu	a4,a5,80005764 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005750:	8526                	mv	a0,s1
    80005752:	60a6                	ld	ra,72(sp)
    80005754:	6406                	ld	s0,64(sp)
    80005756:	74e2                	ld	s1,56(sp)
    80005758:	7942                	ld	s2,48(sp)
    8000575a:	79a2                	ld	s3,40(sp)
    8000575c:	7a02                	ld	s4,32(sp)
    8000575e:	6ae2                	ld	s5,24(sp)
    80005760:	6161                	addi	sp,sp,80
    80005762:	8082                	ret
    iunlockput(ip);
    80005764:	8526                	mv	a0,s1
    80005766:	fffff097          	auipc	ra,0xfffff
    8000576a:	8a8080e7          	jalr	-1880(ra) # 8000400e <iunlockput>
    return 0;
    8000576e:	4481                	li	s1,0
    80005770:	b7c5                	j	80005750 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005772:	85ce                	mv	a1,s3
    80005774:	00092503          	lw	a0,0(s2)
    80005778:	ffffe097          	auipc	ra,0xffffe
    8000577c:	49c080e7          	jalr	1180(ra) # 80003c14 <ialloc>
    80005780:	84aa                	mv	s1,a0
    80005782:	c529                	beqz	a0,800057cc <create+0xee>
  ilock(ip);
    80005784:	ffffe097          	auipc	ra,0xffffe
    80005788:	628080e7          	jalr	1576(ra) # 80003dac <ilock>
  ip->major = major;
    8000578c:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005790:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005794:	4785                	li	a5,1
    80005796:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000579a:	8526                	mv	a0,s1
    8000579c:	ffffe097          	auipc	ra,0xffffe
    800057a0:	546080e7          	jalr	1350(ra) # 80003ce2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800057a4:	2981                	sext.w	s3,s3
    800057a6:	4785                	li	a5,1
    800057a8:	02f98a63          	beq	s3,a5,800057dc <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800057ac:	40d0                	lw	a2,4(s1)
    800057ae:	fb040593          	addi	a1,s0,-80
    800057b2:	854a                	mv	a0,s2
    800057b4:	fffff097          	auipc	ra,0xfffff
    800057b8:	cec080e7          	jalr	-788(ra) # 800044a0 <dirlink>
    800057bc:	06054b63          	bltz	a0,80005832 <create+0x154>
  iunlockput(dp);
    800057c0:	854a                	mv	a0,s2
    800057c2:	fffff097          	auipc	ra,0xfffff
    800057c6:	84c080e7          	jalr	-1972(ra) # 8000400e <iunlockput>
  return ip;
    800057ca:	b759                	j	80005750 <create+0x72>
    panic("create: ialloc");
    800057cc:	00003517          	auipc	a0,0x3
    800057d0:	05c50513          	addi	a0,a0,92 # 80008828 <syscalls+0x2d8>
    800057d4:	ffffb097          	auipc	ra,0xffffb
    800057d8:	d6a080e7          	jalr	-662(ra) # 8000053e <panic>
    dp->nlink++;  // for ".."
    800057dc:	04a95783          	lhu	a5,74(s2)
    800057e0:	2785                	addiw	a5,a5,1
    800057e2:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800057e6:	854a                	mv	a0,s2
    800057e8:	ffffe097          	auipc	ra,0xffffe
    800057ec:	4fa080e7          	jalr	1274(ra) # 80003ce2 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800057f0:	40d0                	lw	a2,4(s1)
    800057f2:	00003597          	auipc	a1,0x3
    800057f6:	04658593          	addi	a1,a1,70 # 80008838 <syscalls+0x2e8>
    800057fa:	8526                	mv	a0,s1
    800057fc:	fffff097          	auipc	ra,0xfffff
    80005800:	ca4080e7          	jalr	-860(ra) # 800044a0 <dirlink>
    80005804:	00054f63          	bltz	a0,80005822 <create+0x144>
    80005808:	00492603          	lw	a2,4(s2)
    8000580c:	00003597          	auipc	a1,0x3
    80005810:	03458593          	addi	a1,a1,52 # 80008840 <syscalls+0x2f0>
    80005814:	8526                	mv	a0,s1
    80005816:	fffff097          	auipc	ra,0xfffff
    8000581a:	c8a080e7          	jalr	-886(ra) # 800044a0 <dirlink>
    8000581e:	f80557e3          	bgez	a0,800057ac <create+0xce>
      panic("create dots");
    80005822:	00003517          	auipc	a0,0x3
    80005826:	02650513          	addi	a0,a0,38 # 80008848 <syscalls+0x2f8>
    8000582a:	ffffb097          	auipc	ra,0xffffb
    8000582e:	d14080e7          	jalr	-748(ra) # 8000053e <panic>
    panic("create: dirlink");
    80005832:	00003517          	auipc	a0,0x3
    80005836:	02650513          	addi	a0,a0,38 # 80008858 <syscalls+0x308>
    8000583a:	ffffb097          	auipc	ra,0xffffb
    8000583e:	d04080e7          	jalr	-764(ra) # 8000053e <panic>
    return 0;
    80005842:	84aa                	mv	s1,a0
    80005844:	b731                	j	80005750 <create+0x72>

0000000080005846 <sys_dup>:
{
    80005846:	7179                	addi	sp,sp,-48
    80005848:	f406                	sd	ra,40(sp)
    8000584a:	f022                	sd	s0,32(sp)
    8000584c:	ec26                	sd	s1,24(sp)
    8000584e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005850:	fd840613          	addi	a2,s0,-40
    80005854:	4581                	li	a1,0
    80005856:	4501                	li	a0,0
    80005858:	00000097          	auipc	ra,0x0
    8000585c:	ddc080e7          	jalr	-548(ra) # 80005634 <argfd>
    return -1;
    80005860:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005862:	02054363          	bltz	a0,80005888 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005866:	fd843503          	ld	a0,-40(s0)
    8000586a:	00000097          	auipc	ra,0x0
    8000586e:	e32080e7          	jalr	-462(ra) # 8000569c <fdalloc>
    80005872:	84aa                	mv	s1,a0
    return -1;
    80005874:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005876:	00054963          	bltz	a0,80005888 <sys_dup+0x42>
  filedup(f);
    8000587a:	fd843503          	ld	a0,-40(s0)
    8000587e:	fffff097          	auipc	ra,0xfffff
    80005882:	37a080e7          	jalr	890(ra) # 80004bf8 <filedup>
  return fd;
    80005886:	87a6                	mv	a5,s1
}
    80005888:	853e                	mv	a0,a5
    8000588a:	70a2                	ld	ra,40(sp)
    8000588c:	7402                	ld	s0,32(sp)
    8000588e:	64e2                	ld	s1,24(sp)
    80005890:	6145                	addi	sp,sp,48
    80005892:	8082                	ret

0000000080005894 <sys_read>:
{
    80005894:	7179                	addi	sp,sp,-48
    80005896:	f406                	sd	ra,40(sp)
    80005898:	f022                	sd	s0,32(sp)
    8000589a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000589c:	fe840613          	addi	a2,s0,-24
    800058a0:	4581                	li	a1,0
    800058a2:	4501                	li	a0,0
    800058a4:	00000097          	auipc	ra,0x0
    800058a8:	d90080e7          	jalr	-624(ra) # 80005634 <argfd>
    return -1;
    800058ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058ae:	04054163          	bltz	a0,800058f0 <sys_read+0x5c>
    800058b2:	fe440593          	addi	a1,s0,-28
    800058b6:	4509                	li	a0,2
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	83e080e7          	jalr	-1986(ra) # 800030f6 <argint>
    return -1;
    800058c0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058c2:	02054763          	bltz	a0,800058f0 <sys_read+0x5c>
    800058c6:	fd840593          	addi	a1,s0,-40
    800058ca:	4505                	li	a0,1
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	84c080e7          	jalr	-1972(ra) # 80003118 <argaddr>
    return -1;
    800058d4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058d6:	00054d63          	bltz	a0,800058f0 <sys_read+0x5c>
  return fileread(f, p, n);
    800058da:	fe442603          	lw	a2,-28(s0)
    800058de:	fd843583          	ld	a1,-40(s0)
    800058e2:	fe843503          	ld	a0,-24(s0)
    800058e6:	fffff097          	auipc	ra,0xfffff
    800058ea:	49e080e7          	jalr	1182(ra) # 80004d84 <fileread>
    800058ee:	87aa                	mv	a5,a0
}
    800058f0:	853e                	mv	a0,a5
    800058f2:	70a2                	ld	ra,40(sp)
    800058f4:	7402                	ld	s0,32(sp)
    800058f6:	6145                	addi	sp,sp,48
    800058f8:	8082                	ret

00000000800058fa <sys_write>:
{
    800058fa:	7179                	addi	sp,sp,-48
    800058fc:	f406                	sd	ra,40(sp)
    800058fe:	f022                	sd	s0,32(sp)
    80005900:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005902:	fe840613          	addi	a2,s0,-24
    80005906:	4581                	li	a1,0
    80005908:	4501                	li	a0,0
    8000590a:	00000097          	auipc	ra,0x0
    8000590e:	d2a080e7          	jalr	-726(ra) # 80005634 <argfd>
    return -1;
    80005912:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005914:	04054163          	bltz	a0,80005956 <sys_write+0x5c>
    80005918:	fe440593          	addi	a1,s0,-28
    8000591c:	4509                	li	a0,2
    8000591e:	ffffd097          	auipc	ra,0xffffd
    80005922:	7d8080e7          	jalr	2008(ra) # 800030f6 <argint>
    return -1;
    80005926:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005928:	02054763          	bltz	a0,80005956 <sys_write+0x5c>
    8000592c:	fd840593          	addi	a1,s0,-40
    80005930:	4505                	li	a0,1
    80005932:	ffffd097          	auipc	ra,0xffffd
    80005936:	7e6080e7          	jalr	2022(ra) # 80003118 <argaddr>
    return -1;
    8000593a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000593c:	00054d63          	bltz	a0,80005956 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005940:	fe442603          	lw	a2,-28(s0)
    80005944:	fd843583          	ld	a1,-40(s0)
    80005948:	fe843503          	ld	a0,-24(s0)
    8000594c:	fffff097          	auipc	ra,0xfffff
    80005950:	4fa080e7          	jalr	1274(ra) # 80004e46 <filewrite>
    80005954:	87aa                	mv	a5,a0
}
    80005956:	853e                	mv	a0,a5
    80005958:	70a2                	ld	ra,40(sp)
    8000595a:	7402                	ld	s0,32(sp)
    8000595c:	6145                	addi	sp,sp,48
    8000595e:	8082                	ret

0000000080005960 <sys_close>:
{
    80005960:	1101                	addi	sp,sp,-32
    80005962:	ec06                	sd	ra,24(sp)
    80005964:	e822                	sd	s0,16(sp)
    80005966:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005968:	fe040613          	addi	a2,s0,-32
    8000596c:	fec40593          	addi	a1,s0,-20
    80005970:	4501                	li	a0,0
    80005972:	00000097          	auipc	ra,0x0
    80005976:	cc2080e7          	jalr	-830(ra) # 80005634 <argfd>
    return -1;
    8000597a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000597c:	02054463          	bltz	a0,800059a4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005980:	ffffc097          	auipc	ra,0xffffc
    80005984:	030080e7          	jalr	48(ra) # 800019b0 <myproc>
    80005988:	fec42783          	lw	a5,-20(s0)
    8000598c:	07e9                	addi	a5,a5,26
    8000598e:	078e                	slli	a5,a5,0x3
    80005990:	97aa                	add	a5,a5,a0
    80005992:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005996:	fe043503          	ld	a0,-32(s0)
    8000599a:	fffff097          	auipc	ra,0xfffff
    8000599e:	2b0080e7          	jalr	688(ra) # 80004c4a <fileclose>
  return 0;
    800059a2:	4781                	li	a5,0
}
    800059a4:	853e                	mv	a0,a5
    800059a6:	60e2                	ld	ra,24(sp)
    800059a8:	6442                	ld	s0,16(sp)
    800059aa:	6105                	addi	sp,sp,32
    800059ac:	8082                	ret

00000000800059ae <sys_fstat>:
{
    800059ae:	1101                	addi	sp,sp,-32
    800059b0:	ec06                	sd	ra,24(sp)
    800059b2:	e822                	sd	s0,16(sp)
    800059b4:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800059b6:	fe840613          	addi	a2,s0,-24
    800059ba:	4581                	li	a1,0
    800059bc:	4501                	li	a0,0
    800059be:	00000097          	auipc	ra,0x0
    800059c2:	c76080e7          	jalr	-906(ra) # 80005634 <argfd>
    return -1;
    800059c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800059c8:	02054563          	bltz	a0,800059f2 <sys_fstat+0x44>
    800059cc:	fe040593          	addi	a1,s0,-32
    800059d0:	4505                	li	a0,1
    800059d2:	ffffd097          	auipc	ra,0xffffd
    800059d6:	746080e7          	jalr	1862(ra) # 80003118 <argaddr>
    return -1;
    800059da:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800059dc:	00054b63          	bltz	a0,800059f2 <sys_fstat+0x44>
  return filestat(f, st);
    800059e0:	fe043583          	ld	a1,-32(s0)
    800059e4:	fe843503          	ld	a0,-24(s0)
    800059e8:	fffff097          	auipc	ra,0xfffff
    800059ec:	32a080e7          	jalr	810(ra) # 80004d12 <filestat>
    800059f0:	87aa                	mv	a5,a0
}
    800059f2:	853e                	mv	a0,a5
    800059f4:	60e2                	ld	ra,24(sp)
    800059f6:	6442                	ld	s0,16(sp)
    800059f8:	6105                	addi	sp,sp,32
    800059fa:	8082                	ret

00000000800059fc <sys_link>:
{
    800059fc:	7169                	addi	sp,sp,-304
    800059fe:	f606                	sd	ra,296(sp)
    80005a00:	f222                	sd	s0,288(sp)
    80005a02:	ee26                	sd	s1,280(sp)
    80005a04:	ea4a                	sd	s2,272(sp)
    80005a06:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a08:	08000613          	li	a2,128
    80005a0c:	ed040593          	addi	a1,s0,-304
    80005a10:	4501                	li	a0,0
    80005a12:	ffffd097          	auipc	ra,0xffffd
    80005a16:	728080e7          	jalr	1832(ra) # 8000313a <argstr>
    return -1;
    80005a1a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a1c:	10054e63          	bltz	a0,80005b38 <sys_link+0x13c>
    80005a20:	08000613          	li	a2,128
    80005a24:	f5040593          	addi	a1,s0,-176
    80005a28:	4505                	li	a0,1
    80005a2a:	ffffd097          	auipc	ra,0xffffd
    80005a2e:	710080e7          	jalr	1808(ra) # 8000313a <argstr>
    return -1;
    80005a32:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a34:	10054263          	bltz	a0,80005b38 <sys_link+0x13c>
  begin_op();
    80005a38:	fffff097          	auipc	ra,0xfffff
    80005a3c:	d46080e7          	jalr	-698(ra) # 8000477e <begin_op>
  if((ip = namei(old)) == 0){
    80005a40:	ed040513          	addi	a0,s0,-304
    80005a44:	fffff097          	auipc	ra,0xfffff
    80005a48:	b1e080e7          	jalr	-1250(ra) # 80004562 <namei>
    80005a4c:	84aa                	mv	s1,a0
    80005a4e:	c551                	beqz	a0,80005ada <sys_link+0xde>
  ilock(ip);
    80005a50:	ffffe097          	auipc	ra,0xffffe
    80005a54:	35c080e7          	jalr	860(ra) # 80003dac <ilock>
  if(ip->type == T_DIR){
    80005a58:	04449703          	lh	a4,68(s1)
    80005a5c:	4785                	li	a5,1
    80005a5e:	08f70463          	beq	a4,a5,80005ae6 <sys_link+0xea>
  ip->nlink++;
    80005a62:	04a4d783          	lhu	a5,74(s1)
    80005a66:	2785                	addiw	a5,a5,1
    80005a68:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a6c:	8526                	mv	a0,s1
    80005a6e:	ffffe097          	auipc	ra,0xffffe
    80005a72:	274080e7          	jalr	628(ra) # 80003ce2 <iupdate>
  iunlock(ip);
    80005a76:	8526                	mv	a0,s1
    80005a78:	ffffe097          	auipc	ra,0xffffe
    80005a7c:	3f6080e7          	jalr	1014(ra) # 80003e6e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005a80:	fd040593          	addi	a1,s0,-48
    80005a84:	f5040513          	addi	a0,s0,-176
    80005a88:	fffff097          	auipc	ra,0xfffff
    80005a8c:	af8080e7          	jalr	-1288(ra) # 80004580 <nameiparent>
    80005a90:	892a                	mv	s2,a0
    80005a92:	c935                	beqz	a0,80005b06 <sys_link+0x10a>
  ilock(dp);
    80005a94:	ffffe097          	auipc	ra,0xffffe
    80005a98:	318080e7          	jalr	792(ra) # 80003dac <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a9c:	00092703          	lw	a4,0(s2)
    80005aa0:	409c                	lw	a5,0(s1)
    80005aa2:	04f71d63          	bne	a4,a5,80005afc <sys_link+0x100>
    80005aa6:	40d0                	lw	a2,4(s1)
    80005aa8:	fd040593          	addi	a1,s0,-48
    80005aac:	854a                	mv	a0,s2
    80005aae:	fffff097          	auipc	ra,0xfffff
    80005ab2:	9f2080e7          	jalr	-1550(ra) # 800044a0 <dirlink>
    80005ab6:	04054363          	bltz	a0,80005afc <sys_link+0x100>
  iunlockput(dp);
    80005aba:	854a                	mv	a0,s2
    80005abc:	ffffe097          	auipc	ra,0xffffe
    80005ac0:	552080e7          	jalr	1362(ra) # 8000400e <iunlockput>
  iput(ip);
    80005ac4:	8526                	mv	a0,s1
    80005ac6:	ffffe097          	auipc	ra,0xffffe
    80005aca:	4a0080e7          	jalr	1184(ra) # 80003f66 <iput>
  end_op();
    80005ace:	fffff097          	auipc	ra,0xfffff
    80005ad2:	d30080e7          	jalr	-720(ra) # 800047fe <end_op>
  return 0;
    80005ad6:	4781                	li	a5,0
    80005ad8:	a085                	j	80005b38 <sys_link+0x13c>
    end_op();
    80005ada:	fffff097          	auipc	ra,0xfffff
    80005ade:	d24080e7          	jalr	-732(ra) # 800047fe <end_op>
    return -1;
    80005ae2:	57fd                	li	a5,-1
    80005ae4:	a891                	j	80005b38 <sys_link+0x13c>
    iunlockput(ip);
    80005ae6:	8526                	mv	a0,s1
    80005ae8:	ffffe097          	auipc	ra,0xffffe
    80005aec:	526080e7          	jalr	1318(ra) # 8000400e <iunlockput>
    end_op();
    80005af0:	fffff097          	auipc	ra,0xfffff
    80005af4:	d0e080e7          	jalr	-754(ra) # 800047fe <end_op>
    return -1;
    80005af8:	57fd                	li	a5,-1
    80005afa:	a83d                	j	80005b38 <sys_link+0x13c>
    iunlockput(dp);
    80005afc:	854a                	mv	a0,s2
    80005afe:	ffffe097          	auipc	ra,0xffffe
    80005b02:	510080e7          	jalr	1296(ra) # 8000400e <iunlockput>
  ilock(ip);
    80005b06:	8526                	mv	a0,s1
    80005b08:	ffffe097          	auipc	ra,0xffffe
    80005b0c:	2a4080e7          	jalr	676(ra) # 80003dac <ilock>
  ip->nlink--;
    80005b10:	04a4d783          	lhu	a5,74(s1)
    80005b14:	37fd                	addiw	a5,a5,-1
    80005b16:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b1a:	8526                	mv	a0,s1
    80005b1c:	ffffe097          	auipc	ra,0xffffe
    80005b20:	1c6080e7          	jalr	454(ra) # 80003ce2 <iupdate>
  iunlockput(ip);
    80005b24:	8526                	mv	a0,s1
    80005b26:	ffffe097          	auipc	ra,0xffffe
    80005b2a:	4e8080e7          	jalr	1256(ra) # 8000400e <iunlockput>
  end_op();
    80005b2e:	fffff097          	auipc	ra,0xfffff
    80005b32:	cd0080e7          	jalr	-816(ra) # 800047fe <end_op>
  return -1;
    80005b36:	57fd                	li	a5,-1
}
    80005b38:	853e                	mv	a0,a5
    80005b3a:	70b2                	ld	ra,296(sp)
    80005b3c:	7412                	ld	s0,288(sp)
    80005b3e:	64f2                	ld	s1,280(sp)
    80005b40:	6952                	ld	s2,272(sp)
    80005b42:	6155                	addi	sp,sp,304
    80005b44:	8082                	ret

0000000080005b46 <sys_unlink>:
{
    80005b46:	7151                	addi	sp,sp,-240
    80005b48:	f586                	sd	ra,232(sp)
    80005b4a:	f1a2                	sd	s0,224(sp)
    80005b4c:	eda6                	sd	s1,216(sp)
    80005b4e:	e9ca                	sd	s2,208(sp)
    80005b50:	e5ce                	sd	s3,200(sp)
    80005b52:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005b54:	08000613          	li	a2,128
    80005b58:	f3040593          	addi	a1,s0,-208
    80005b5c:	4501                	li	a0,0
    80005b5e:	ffffd097          	auipc	ra,0xffffd
    80005b62:	5dc080e7          	jalr	1500(ra) # 8000313a <argstr>
    80005b66:	18054163          	bltz	a0,80005ce8 <sys_unlink+0x1a2>
  begin_op();
    80005b6a:	fffff097          	auipc	ra,0xfffff
    80005b6e:	c14080e7          	jalr	-1004(ra) # 8000477e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005b72:	fb040593          	addi	a1,s0,-80
    80005b76:	f3040513          	addi	a0,s0,-208
    80005b7a:	fffff097          	auipc	ra,0xfffff
    80005b7e:	a06080e7          	jalr	-1530(ra) # 80004580 <nameiparent>
    80005b82:	84aa                	mv	s1,a0
    80005b84:	c979                	beqz	a0,80005c5a <sys_unlink+0x114>
  ilock(dp);
    80005b86:	ffffe097          	auipc	ra,0xffffe
    80005b8a:	226080e7          	jalr	550(ra) # 80003dac <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b8e:	00003597          	auipc	a1,0x3
    80005b92:	caa58593          	addi	a1,a1,-854 # 80008838 <syscalls+0x2e8>
    80005b96:	fb040513          	addi	a0,s0,-80
    80005b9a:	ffffe097          	auipc	ra,0xffffe
    80005b9e:	6dc080e7          	jalr	1756(ra) # 80004276 <namecmp>
    80005ba2:	14050a63          	beqz	a0,80005cf6 <sys_unlink+0x1b0>
    80005ba6:	00003597          	auipc	a1,0x3
    80005baa:	c9a58593          	addi	a1,a1,-870 # 80008840 <syscalls+0x2f0>
    80005bae:	fb040513          	addi	a0,s0,-80
    80005bb2:	ffffe097          	auipc	ra,0xffffe
    80005bb6:	6c4080e7          	jalr	1732(ra) # 80004276 <namecmp>
    80005bba:	12050e63          	beqz	a0,80005cf6 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005bbe:	f2c40613          	addi	a2,s0,-212
    80005bc2:	fb040593          	addi	a1,s0,-80
    80005bc6:	8526                	mv	a0,s1
    80005bc8:	ffffe097          	auipc	ra,0xffffe
    80005bcc:	6c8080e7          	jalr	1736(ra) # 80004290 <dirlookup>
    80005bd0:	892a                	mv	s2,a0
    80005bd2:	12050263          	beqz	a0,80005cf6 <sys_unlink+0x1b0>
  ilock(ip);
    80005bd6:	ffffe097          	auipc	ra,0xffffe
    80005bda:	1d6080e7          	jalr	470(ra) # 80003dac <ilock>
  if(ip->nlink < 1)
    80005bde:	04a91783          	lh	a5,74(s2)
    80005be2:	08f05263          	blez	a5,80005c66 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005be6:	04491703          	lh	a4,68(s2)
    80005bea:	4785                	li	a5,1
    80005bec:	08f70563          	beq	a4,a5,80005c76 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005bf0:	4641                	li	a2,16
    80005bf2:	4581                	li	a1,0
    80005bf4:	fc040513          	addi	a0,s0,-64
    80005bf8:	ffffb097          	auipc	ra,0xffffb
    80005bfc:	0e8080e7          	jalr	232(ra) # 80000ce0 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c00:	4741                	li	a4,16
    80005c02:	f2c42683          	lw	a3,-212(s0)
    80005c06:	fc040613          	addi	a2,s0,-64
    80005c0a:	4581                	li	a1,0
    80005c0c:	8526                	mv	a0,s1
    80005c0e:	ffffe097          	auipc	ra,0xffffe
    80005c12:	54a080e7          	jalr	1354(ra) # 80004158 <writei>
    80005c16:	47c1                	li	a5,16
    80005c18:	0af51563          	bne	a0,a5,80005cc2 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005c1c:	04491703          	lh	a4,68(s2)
    80005c20:	4785                	li	a5,1
    80005c22:	0af70863          	beq	a4,a5,80005cd2 <sys_unlink+0x18c>
  iunlockput(dp);
    80005c26:	8526                	mv	a0,s1
    80005c28:	ffffe097          	auipc	ra,0xffffe
    80005c2c:	3e6080e7          	jalr	998(ra) # 8000400e <iunlockput>
  ip->nlink--;
    80005c30:	04a95783          	lhu	a5,74(s2)
    80005c34:	37fd                	addiw	a5,a5,-1
    80005c36:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005c3a:	854a                	mv	a0,s2
    80005c3c:	ffffe097          	auipc	ra,0xffffe
    80005c40:	0a6080e7          	jalr	166(ra) # 80003ce2 <iupdate>
  iunlockput(ip);
    80005c44:	854a                	mv	a0,s2
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	3c8080e7          	jalr	968(ra) # 8000400e <iunlockput>
  end_op();
    80005c4e:	fffff097          	auipc	ra,0xfffff
    80005c52:	bb0080e7          	jalr	-1104(ra) # 800047fe <end_op>
  return 0;
    80005c56:	4501                	li	a0,0
    80005c58:	a84d                	j	80005d0a <sys_unlink+0x1c4>
    end_op();
    80005c5a:	fffff097          	auipc	ra,0xfffff
    80005c5e:	ba4080e7          	jalr	-1116(ra) # 800047fe <end_op>
    return -1;
    80005c62:	557d                	li	a0,-1
    80005c64:	a05d                	j	80005d0a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005c66:	00003517          	auipc	a0,0x3
    80005c6a:	c0250513          	addi	a0,a0,-1022 # 80008868 <syscalls+0x318>
    80005c6e:	ffffb097          	auipc	ra,0xffffb
    80005c72:	8d0080e7          	jalr	-1840(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c76:	04c92703          	lw	a4,76(s2)
    80005c7a:	02000793          	li	a5,32
    80005c7e:	f6e7f9e3          	bgeu	a5,a4,80005bf0 <sys_unlink+0xaa>
    80005c82:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c86:	4741                	li	a4,16
    80005c88:	86ce                	mv	a3,s3
    80005c8a:	f1840613          	addi	a2,s0,-232
    80005c8e:	4581                	li	a1,0
    80005c90:	854a                	mv	a0,s2
    80005c92:	ffffe097          	auipc	ra,0xffffe
    80005c96:	3ce080e7          	jalr	974(ra) # 80004060 <readi>
    80005c9a:	47c1                	li	a5,16
    80005c9c:	00f51b63          	bne	a0,a5,80005cb2 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005ca0:	f1845783          	lhu	a5,-232(s0)
    80005ca4:	e7a1                	bnez	a5,80005cec <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ca6:	29c1                	addiw	s3,s3,16
    80005ca8:	04c92783          	lw	a5,76(s2)
    80005cac:	fcf9ede3          	bltu	s3,a5,80005c86 <sys_unlink+0x140>
    80005cb0:	b781                	j	80005bf0 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005cb2:	00003517          	auipc	a0,0x3
    80005cb6:	bce50513          	addi	a0,a0,-1074 # 80008880 <syscalls+0x330>
    80005cba:	ffffb097          	auipc	ra,0xffffb
    80005cbe:	884080e7          	jalr	-1916(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005cc2:	00003517          	auipc	a0,0x3
    80005cc6:	bd650513          	addi	a0,a0,-1066 # 80008898 <syscalls+0x348>
    80005cca:	ffffb097          	auipc	ra,0xffffb
    80005cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>
    dp->nlink--;
    80005cd2:	04a4d783          	lhu	a5,74(s1)
    80005cd6:	37fd                	addiw	a5,a5,-1
    80005cd8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005cdc:	8526                	mv	a0,s1
    80005cde:	ffffe097          	auipc	ra,0xffffe
    80005ce2:	004080e7          	jalr	4(ra) # 80003ce2 <iupdate>
    80005ce6:	b781                	j	80005c26 <sys_unlink+0xe0>
    return -1;
    80005ce8:	557d                	li	a0,-1
    80005cea:	a005                	j	80005d0a <sys_unlink+0x1c4>
    iunlockput(ip);
    80005cec:	854a                	mv	a0,s2
    80005cee:	ffffe097          	auipc	ra,0xffffe
    80005cf2:	320080e7          	jalr	800(ra) # 8000400e <iunlockput>
  iunlockput(dp);
    80005cf6:	8526                	mv	a0,s1
    80005cf8:	ffffe097          	auipc	ra,0xffffe
    80005cfc:	316080e7          	jalr	790(ra) # 8000400e <iunlockput>
  end_op();
    80005d00:	fffff097          	auipc	ra,0xfffff
    80005d04:	afe080e7          	jalr	-1282(ra) # 800047fe <end_op>
  return -1;
    80005d08:	557d                	li	a0,-1
}
    80005d0a:	70ae                	ld	ra,232(sp)
    80005d0c:	740e                	ld	s0,224(sp)
    80005d0e:	64ee                	ld	s1,216(sp)
    80005d10:	694e                	ld	s2,208(sp)
    80005d12:	69ae                	ld	s3,200(sp)
    80005d14:	616d                	addi	sp,sp,240
    80005d16:	8082                	ret

0000000080005d18 <sys_open>:

uint64
sys_open(void)
{
    80005d18:	7131                	addi	sp,sp,-192
    80005d1a:	fd06                	sd	ra,184(sp)
    80005d1c:	f922                	sd	s0,176(sp)
    80005d1e:	f526                	sd	s1,168(sp)
    80005d20:	f14a                	sd	s2,160(sp)
    80005d22:	ed4e                	sd	s3,152(sp)
    80005d24:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005d26:	08000613          	li	a2,128
    80005d2a:	f5040593          	addi	a1,s0,-176
    80005d2e:	4501                	li	a0,0
    80005d30:	ffffd097          	auipc	ra,0xffffd
    80005d34:	40a080e7          	jalr	1034(ra) # 8000313a <argstr>
    return -1;
    80005d38:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005d3a:	0c054163          	bltz	a0,80005dfc <sys_open+0xe4>
    80005d3e:	f4c40593          	addi	a1,s0,-180
    80005d42:	4505                	li	a0,1
    80005d44:	ffffd097          	auipc	ra,0xffffd
    80005d48:	3b2080e7          	jalr	946(ra) # 800030f6 <argint>
    80005d4c:	0a054863          	bltz	a0,80005dfc <sys_open+0xe4>

  begin_op();
    80005d50:	fffff097          	auipc	ra,0xfffff
    80005d54:	a2e080e7          	jalr	-1490(ra) # 8000477e <begin_op>

  if(omode & O_CREATE){
    80005d58:	f4c42783          	lw	a5,-180(s0)
    80005d5c:	2007f793          	andi	a5,a5,512
    80005d60:	cbdd                	beqz	a5,80005e16 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005d62:	4681                	li	a3,0
    80005d64:	4601                	li	a2,0
    80005d66:	4589                	li	a1,2
    80005d68:	f5040513          	addi	a0,s0,-176
    80005d6c:	00000097          	auipc	ra,0x0
    80005d70:	972080e7          	jalr	-1678(ra) # 800056de <create>
    80005d74:	892a                	mv	s2,a0
    if(ip == 0){
    80005d76:	c959                	beqz	a0,80005e0c <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005d78:	04491703          	lh	a4,68(s2)
    80005d7c:	478d                	li	a5,3
    80005d7e:	00f71763          	bne	a4,a5,80005d8c <sys_open+0x74>
    80005d82:	04695703          	lhu	a4,70(s2)
    80005d86:	47a5                	li	a5,9
    80005d88:	0ce7ec63          	bltu	a5,a4,80005e60 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005d8c:	fffff097          	auipc	ra,0xfffff
    80005d90:	e02080e7          	jalr	-510(ra) # 80004b8e <filealloc>
    80005d94:	89aa                	mv	s3,a0
    80005d96:	10050263          	beqz	a0,80005e9a <sys_open+0x182>
    80005d9a:	00000097          	auipc	ra,0x0
    80005d9e:	902080e7          	jalr	-1790(ra) # 8000569c <fdalloc>
    80005da2:	84aa                	mv	s1,a0
    80005da4:	0e054663          	bltz	a0,80005e90 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005da8:	04491703          	lh	a4,68(s2)
    80005dac:	478d                	li	a5,3
    80005dae:	0cf70463          	beq	a4,a5,80005e76 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005db2:	4789                	li	a5,2
    80005db4:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005db8:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005dbc:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005dc0:	f4c42783          	lw	a5,-180(s0)
    80005dc4:	0017c713          	xori	a4,a5,1
    80005dc8:	8b05                	andi	a4,a4,1
    80005dca:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005dce:	0037f713          	andi	a4,a5,3
    80005dd2:	00e03733          	snez	a4,a4
    80005dd6:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005dda:	4007f793          	andi	a5,a5,1024
    80005dde:	c791                	beqz	a5,80005dea <sys_open+0xd2>
    80005de0:	04491703          	lh	a4,68(s2)
    80005de4:	4789                	li	a5,2
    80005de6:	08f70f63          	beq	a4,a5,80005e84 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005dea:	854a                	mv	a0,s2
    80005dec:	ffffe097          	auipc	ra,0xffffe
    80005df0:	082080e7          	jalr	130(ra) # 80003e6e <iunlock>
  end_op();
    80005df4:	fffff097          	auipc	ra,0xfffff
    80005df8:	a0a080e7          	jalr	-1526(ra) # 800047fe <end_op>

  return fd;
}
    80005dfc:	8526                	mv	a0,s1
    80005dfe:	70ea                	ld	ra,184(sp)
    80005e00:	744a                	ld	s0,176(sp)
    80005e02:	74aa                	ld	s1,168(sp)
    80005e04:	790a                	ld	s2,160(sp)
    80005e06:	69ea                	ld	s3,152(sp)
    80005e08:	6129                	addi	sp,sp,192
    80005e0a:	8082                	ret
      end_op();
    80005e0c:	fffff097          	auipc	ra,0xfffff
    80005e10:	9f2080e7          	jalr	-1550(ra) # 800047fe <end_op>
      return -1;
    80005e14:	b7e5                	j	80005dfc <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005e16:	f5040513          	addi	a0,s0,-176
    80005e1a:	ffffe097          	auipc	ra,0xffffe
    80005e1e:	748080e7          	jalr	1864(ra) # 80004562 <namei>
    80005e22:	892a                	mv	s2,a0
    80005e24:	c905                	beqz	a0,80005e54 <sys_open+0x13c>
    ilock(ip);
    80005e26:	ffffe097          	auipc	ra,0xffffe
    80005e2a:	f86080e7          	jalr	-122(ra) # 80003dac <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005e2e:	04491703          	lh	a4,68(s2)
    80005e32:	4785                	li	a5,1
    80005e34:	f4f712e3          	bne	a4,a5,80005d78 <sys_open+0x60>
    80005e38:	f4c42783          	lw	a5,-180(s0)
    80005e3c:	dba1                	beqz	a5,80005d8c <sys_open+0x74>
      iunlockput(ip);
    80005e3e:	854a                	mv	a0,s2
    80005e40:	ffffe097          	auipc	ra,0xffffe
    80005e44:	1ce080e7          	jalr	462(ra) # 8000400e <iunlockput>
      end_op();
    80005e48:	fffff097          	auipc	ra,0xfffff
    80005e4c:	9b6080e7          	jalr	-1610(ra) # 800047fe <end_op>
      return -1;
    80005e50:	54fd                	li	s1,-1
    80005e52:	b76d                	j	80005dfc <sys_open+0xe4>
      end_op();
    80005e54:	fffff097          	auipc	ra,0xfffff
    80005e58:	9aa080e7          	jalr	-1622(ra) # 800047fe <end_op>
      return -1;
    80005e5c:	54fd                	li	s1,-1
    80005e5e:	bf79                	j	80005dfc <sys_open+0xe4>
    iunlockput(ip);
    80005e60:	854a                	mv	a0,s2
    80005e62:	ffffe097          	auipc	ra,0xffffe
    80005e66:	1ac080e7          	jalr	428(ra) # 8000400e <iunlockput>
    end_op();
    80005e6a:	fffff097          	auipc	ra,0xfffff
    80005e6e:	994080e7          	jalr	-1644(ra) # 800047fe <end_op>
    return -1;
    80005e72:	54fd                	li	s1,-1
    80005e74:	b761                	j	80005dfc <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005e76:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005e7a:	04691783          	lh	a5,70(s2)
    80005e7e:	02f99223          	sh	a5,36(s3)
    80005e82:	bf2d                	j	80005dbc <sys_open+0xa4>
    itrunc(ip);
    80005e84:	854a                	mv	a0,s2
    80005e86:	ffffe097          	auipc	ra,0xffffe
    80005e8a:	034080e7          	jalr	52(ra) # 80003eba <itrunc>
    80005e8e:	bfb1                	j	80005dea <sys_open+0xd2>
      fileclose(f);
    80005e90:	854e                	mv	a0,s3
    80005e92:	fffff097          	auipc	ra,0xfffff
    80005e96:	db8080e7          	jalr	-584(ra) # 80004c4a <fileclose>
    iunlockput(ip);
    80005e9a:	854a                	mv	a0,s2
    80005e9c:	ffffe097          	auipc	ra,0xffffe
    80005ea0:	172080e7          	jalr	370(ra) # 8000400e <iunlockput>
    end_op();
    80005ea4:	fffff097          	auipc	ra,0xfffff
    80005ea8:	95a080e7          	jalr	-1702(ra) # 800047fe <end_op>
    return -1;
    80005eac:	54fd                	li	s1,-1
    80005eae:	b7b9                	j	80005dfc <sys_open+0xe4>

0000000080005eb0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005eb0:	7175                	addi	sp,sp,-144
    80005eb2:	e506                	sd	ra,136(sp)
    80005eb4:	e122                	sd	s0,128(sp)
    80005eb6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005eb8:	fffff097          	auipc	ra,0xfffff
    80005ebc:	8c6080e7          	jalr	-1850(ra) # 8000477e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ec0:	08000613          	li	a2,128
    80005ec4:	f7040593          	addi	a1,s0,-144
    80005ec8:	4501                	li	a0,0
    80005eca:	ffffd097          	auipc	ra,0xffffd
    80005ece:	270080e7          	jalr	624(ra) # 8000313a <argstr>
    80005ed2:	02054963          	bltz	a0,80005f04 <sys_mkdir+0x54>
    80005ed6:	4681                	li	a3,0
    80005ed8:	4601                	li	a2,0
    80005eda:	4585                	li	a1,1
    80005edc:	f7040513          	addi	a0,s0,-144
    80005ee0:	fffff097          	auipc	ra,0xfffff
    80005ee4:	7fe080e7          	jalr	2046(ra) # 800056de <create>
    80005ee8:	cd11                	beqz	a0,80005f04 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005eea:	ffffe097          	auipc	ra,0xffffe
    80005eee:	124080e7          	jalr	292(ra) # 8000400e <iunlockput>
  end_op();
    80005ef2:	fffff097          	auipc	ra,0xfffff
    80005ef6:	90c080e7          	jalr	-1780(ra) # 800047fe <end_op>
  return 0;
    80005efa:	4501                	li	a0,0
}
    80005efc:	60aa                	ld	ra,136(sp)
    80005efe:	640a                	ld	s0,128(sp)
    80005f00:	6149                	addi	sp,sp,144
    80005f02:	8082                	ret
    end_op();
    80005f04:	fffff097          	auipc	ra,0xfffff
    80005f08:	8fa080e7          	jalr	-1798(ra) # 800047fe <end_op>
    return -1;
    80005f0c:	557d                	li	a0,-1
    80005f0e:	b7fd                	j	80005efc <sys_mkdir+0x4c>

0000000080005f10 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005f10:	7135                	addi	sp,sp,-160
    80005f12:	ed06                	sd	ra,152(sp)
    80005f14:	e922                	sd	s0,144(sp)
    80005f16:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005f18:	fffff097          	auipc	ra,0xfffff
    80005f1c:	866080e7          	jalr	-1946(ra) # 8000477e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f20:	08000613          	li	a2,128
    80005f24:	f7040593          	addi	a1,s0,-144
    80005f28:	4501                	li	a0,0
    80005f2a:	ffffd097          	auipc	ra,0xffffd
    80005f2e:	210080e7          	jalr	528(ra) # 8000313a <argstr>
    80005f32:	04054a63          	bltz	a0,80005f86 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005f36:	f6c40593          	addi	a1,s0,-148
    80005f3a:	4505                	li	a0,1
    80005f3c:	ffffd097          	auipc	ra,0xffffd
    80005f40:	1ba080e7          	jalr	442(ra) # 800030f6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f44:	04054163          	bltz	a0,80005f86 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005f48:	f6840593          	addi	a1,s0,-152
    80005f4c:	4509                	li	a0,2
    80005f4e:	ffffd097          	auipc	ra,0xffffd
    80005f52:	1a8080e7          	jalr	424(ra) # 800030f6 <argint>
     argint(1, &major) < 0 ||
    80005f56:	02054863          	bltz	a0,80005f86 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005f5a:	f6841683          	lh	a3,-152(s0)
    80005f5e:	f6c41603          	lh	a2,-148(s0)
    80005f62:	458d                	li	a1,3
    80005f64:	f7040513          	addi	a0,s0,-144
    80005f68:	fffff097          	auipc	ra,0xfffff
    80005f6c:	776080e7          	jalr	1910(ra) # 800056de <create>
     argint(2, &minor) < 0 ||
    80005f70:	c919                	beqz	a0,80005f86 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f72:	ffffe097          	auipc	ra,0xffffe
    80005f76:	09c080e7          	jalr	156(ra) # 8000400e <iunlockput>
  end_op();
    80005f7a:	fffff097          	auipc	ra,0xfffff
    80005f7e:	884080e7          	jalr	-1916(ra) # 800047fe <end_op>
  return 0;
    80005f82:	4501                	li	a0,0
    80005f84:	a031                	j	80005f90 <sys_mknod+0x80>
    end_op();
    80005f86:	fffff097          	auipc	ra,0xfffff
    80005f8a:	878080e7          	jalr	-1928(ra) # 800047fe <end_op>
    return -1;
    80005f8e:	557d                	li	a0,-1
}
    80005f90:	60ea                	ld	ra,152(sp)
    80005f92:	644a                	ld	s0,144(sp)
    80005f94:	610d                	addi	sp,sp,160
    80005f96:	8082                	ret

0000000080005f98 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f98:	7135                	addi	sp,sp,-160
    80005f9a:	ed06                	sd	ra,152(sp)
    80005f9c:	e922                	sd	s0,144(sp)
    80005f9e:	e526                	sd	s1,136(sp)
    80005fa0:	e14a                	sd	s2,128(sp)
    80005fa2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005fa4:	ffffc097          	auipc	ra,0xffffc
    80005fa8:	a0c080e7          	jalr	-1524(ra) # 800019b0 <myproc>
    80005fac:	892a                	mv	s2,a0
  
  begin_op();
    80005fae:	ffffe097          	auipc	ra,0xffffe
    80005fb2:	7d0080e7          	jalr	2000(ra) # 8000477e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005fb6:	08000613          	li	a2,128
    80005fba:	f6040593          	addi	a1,s0,-160
    80005fbe:	4501                	li	a0,0
    80005fc0:	ffffd097          	auipc	ra,0xffffd
    80005fc4:	17a080e7          	jalr	378(ra) # 8000313a <argstr>
    80005fc8:	04054b63          	bltz	a0,8000601e <sys_chdir+0x86>
    80005fcc:	f6040513          	addi	a0,s0,-160
    80005fd0:	ffffe097          	auipc	ra,0xffffe
    80005fd4:	592080e7          	jalr	1426(ra) # 80004562 <namei>
    80005fd8:	84aa                	mv	s1,a0
    80005fda:	c131                	beqz	a0,8000601e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005fdc:	ffffe097          	auipc	ra,0xffffe
    80005fe0:	dd0080e7          	jalr	-560(ra) # 80003dac <ilock>
  if(ip->type != T_DIR){
    80005fe4:	04449703          	lh	a4,68(s1)
    80005fe8:	4785                	li	a5,1
    80005fea:	04f71063          	bne	a4,a5,8000602a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005fee:	8526                	mv	a0,s1
    80005ff0:	ffffe097          	auipc	ra,0xffffe
    80005ff4:	e7e080e7          	jalr	-386(ra) # 80003e6e <iunlock>
  iput(p->cwd);
    80005ff8:	15093503          	ld	a0,336(s2)
    80005ffc:	ffffe097          	auipc	ra,0xffffe
    80006000:	f6a080e7          	jalr	-150(ra) # 80003f66 <iput>
  end_op();
    80006004:	ffffe097          	auipc	ra,0xffffe
    80006008:	7fa080e7          	jalr	2042(ra) # 800047fe <end_op>
  p->cwd = ip;
    8000600c:	14993823          	sd	s1,336(s2)
  return 0;
    80006010:	4501                	li	a0,0
}
    80006012:	60ea                	ld	ra,152(sp)
    80006014:	644a                	ld	s0,144(sp)
    80006016:	64aa                	ld	s1,136(sp)
    80006018:	690a                	ld	s2,128(sp)
    8000601a:	610d                	addi	sp,sp,160
    8000601c:	8082                	ret
    end_op();
    8000601e:	ffffe097          	auipc	ra,0xffffe
    80006022:	7e0080e7          	jalr	2016(ra) # 800047fe <end_op>
    return -1;
    80006026:	557d                	li	a0,-1
    80006028:	b7ed                	j	80006012 <sys_chdir+0x7a>
    iunlockput(ip);
    8000602a:	8526                	mv	a0,s1
    8000602c:	ffffe097          	auipc	ra,0xffffe
    80006030:	fe2080e7          	jalr	-30(ra) # 8000400e <iunlockput>
    end_op();
    80006034:	ffffe097          	auipc	ra,0xffffe
    80006038:	7ca080e7          	jalr	1994(ra) # 800047fe <end_op>
    return -1;
    8000603c:	557d                	li	a0,-1
    8000603e:	bfd1                	j	80006012 <sys_chdir+0x7a>

0000000080006040 <sys_exec>:

uint64
sys_exec(void)
{
    80006040:	7145                	addi	sp,sp,-464
    80006042:	e786                	sd	ra,456(sp)
    80006044:	e3a2                	sd	s0,448(sp)
    80006046:	ff26                	sd	s1,440(sp)
    80006048:	fb4a                	sd	s2,432(sp)
    8000604a:	f74e                	sd	s3,424(sp)
    8000604c:	f352                	sd	s4,416(sp)
    8000604e:	ef56                	sd	s5,408(sp)
    80006050:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006052:	08000613          	li	a2,128
    80006056:	f4040593          	addi	a1,s0,-192
    8000605a:	4501                	li	a0,0
    8000605c:	ffffd097          	auipc	ra,0xffffd
    80006060:	0de080e7          	jalr	222(ra) # 8000313a <argstr>
    return -1;
    80006064:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006066:	0c054a63          	bltz	a0,8000613a <sys_exec+0xfa>
    8000606a:	e3840593          	addi	a1,s0,-456
    8000606e:	4505                	li	a0,1
    80006070:	ffffd097          	auipc	ra,0xffffd
    80006074:	0a8080e7          	jalr	168(ra) # 80003118 <argaddr>
    80006078:	0c054163          	bltz	a0,8000613a <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    8000607c:	10000613          	li	a2,256
    80006080:	4581                	li	a1,0
    80006082:	e4040513          	addi	a0,s0,-448
    80006086:	ffffb097          	auipc	ra,0xffffb
    8000608a:	c5a080e7          	jalr	-934(ra) # 80000ce0 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000608e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006092:	89a6                	mv	s3,s1
    80006094:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006096:	02000a13          	li	s4,32
    8000609a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000609e:	00391513          	slli	a0,s2,0x3
    800060a2:	e3040593          	addi	a1,s0,-464
    800060a6:	e3843783          	ld	a5,-456(s0)
    800060aa:	953e                	add	a0,a0,a5
    800060ac:	ffffd097          	auipc	ra,0xffffd
    800060b0:	fb0080e7          	jalr	-80(ra) # 8000305c <fetchaddr>
    800060b4:	02054a63          	bltz	a0,800060e8 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    800060b8:	e3043783          	ld	a5,-464(s0)
    800060bc:	c3b9                	beqz	a5,80006102 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800060be:	ffffb097          	auipc	ra,0xffffb
    800060c2:	a36080e7          	jalr	-1482(ra) # 80000af4 <kalloc>
    800060c6:	85aa                	mv	a1,a0
    800060c8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800060cc:	cd11                	beqz	a0,800060e8 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800060ce:	6605                	lui	a2,0x1
    800060d0:	e3043503          	ld	a0,-464(s0)
    800060d4:	ffffd097          	auipc	ra,0xffffd
    800060d8:	fda080e7          	jalr	-38(ra) # 800030ae <fetchstr>
    800060dc:	00054663          	bltz	a0,800060e8 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    800060e0:	0905                	addi	s2,s2,1
    800060e2:	09a1                	addi	s3,s3,8
    800060e4:	fb491be3          	bne	s2,s4,8000609a <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060e8:	10048913          	addi	s2,s1,256
    800060ec:	6088                	ld	a0,0(s1)
    800060ee:	c529                	beqz	a0,80006138 <sys_exec+0xf8>
    kfree(argv[i]);
    800060f0:	ffffb097          	auipc	ra,0xffffb
    800060f4:	908080e7          	jalr	-1784(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060f8:	04a1                	addi	s1,s1,8
    800060fa:	ff2499e3          	bne	s1,s2,800060ec <sys_exec+0xac>
  return -1;
    800060fe:	597d                	li	s2,-1
    80006100:	a82d                	j	8000613a <sys_exec+0xfa>
      argv[i] = 0;
    80006102:	0a8e                	slli	s5,s5,0x3
    80006104:	fc040793          	addi	a5,s0,-64
    80006108:	9abe                	add	s5,s5,a5
    8000610a:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000610e:	e4040593          	addi	a1,s0,-448
    80006112:	f4040513          	addi	a0,s0,-192
    80006116:	fffff097          	auipc	ra,0xfffff
    8000611a:	194080e7          	jalr	404(ra) # 800052aa <exec>
    8000611e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006120:	10048993          	addi	s3,s1,256
    80006124:	6088                	ld	a0,0(s1)
    80006126:	c911                	beqz	a0,8000613a <sys_exec+0xfa>
    kfree(argv[i]);
    80006128:	ffffb097          	auipc	ra,0xffffb
    8000612c:	8d0080e7          	jalr	-1840(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006130:	04a1                	addi	s1,s1,8
    80006132:	ff3499e3          	bne	s1,s3,80006124 <sys_exec+0xe4>
    80006136:	a011                	j	8000613a <sys_exec+0xfa>
  return -1;
    80006138:	597d                	li	s2,-1
}
    8000613a:	854a                	mv	a0,s2
    8000613c:	60be                	ld	ra,456(sp)
    8000613e:	641e                	ld	s0,448(sp)
    80006140:	74fa                	ld	s1,440(sp)
    80006142:	795a                	ld	s2,432(sp)
    80006144:	79ba                	ld	s3,424(sp)
    80006146:	7a1a                	ld	s4,416(sp)
    80006148:	6afa                	ld	s5,408(sp)
    8000614a:	6179                	addi	sp,sp,464
    8000614c:	8082                	ret

000000008000614e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000614e:	7139                	addi	sp,sp,-64
    80006150:	fc06                	sd	ra,56(sp)
    80006152:	f822                	sd	s0,48(sp)
    80006154:	f426                	sd	s1,40(sp)
    80006156:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006158:	ffffc097          	auipc	ra,0xffffc
    8000615c:	858080e7          	jalr	-1960(ra) # 800019b0 <myproc>
    80006160:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006162:	fd840593          	addi	a1,s0,-40
    80006166:	4501                	li	a0,0
    80006168:	ffffd097          	auipc	ra,0xffffd
    8000616c:	fb0080e7          	jalr	-80(ra) # 80003118 <argaddr>
    return -1;
    80006170:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006172:	0e054063          	bltz	a0,80006252 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006176:	fc840593          	addi	a1,s0,-56
    8000617a:	fd040513          	addi	a0,s0,-48
    8000617e:	fffff097          	auipc	ra,0xfffff
    80006182:	dfc080e7          	jalr	-516(ra) # 80004f7a <pipealloc>
    return -1;
    80006186:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006188:	0c054563          	bltz	a0,80006252 <sys_pipe+0x104>
  fd0 = -1;
    8000618c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006190:	fd043503          	ld	a0,-48(s0)
    80006194:	fffff097          	auipc	ra,0xfffff
    80006198:	508080e7          	jalr	1288(ra) # 8000569c <fdalloc>
    8000619c:	fca42223          	sw	a0,-60(s0)
    800061a0:	08054c63          	bltz	a0,80006238 <sys_pipe+0xea>
    800061a4:	fc843503          	ld	a0,-56(s0)
    800061a8:	fffff097          	auipc	ra,0xfffff
    800061ac:	4f4080e7          	jalr	1268(ra) # 8000569c <fdalloc>
    800061b0:	fca42023          	sw	a0,-64(s0)
    800061b4:	06054863          	bltz	a0,80006224 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800061b8:	4691                	li	a3,4
    800061ba:	fc440613          	addi	a2,s0,-60
    800061be:	fd843583          	ld	a1,-40(s0)
    800061c2:	68a8                	ld	a0,80(s1)
    800061c4:	ffffb097          	auipc	ra,0xffffb
    800061c8:	4ae080e7          	jalr	1198(ra) # 80001672 <copyout>
    800061cc:	02054063          	bltz	a0,800061ec <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800061d0:	4691                	li	a3,4
    800061d2:	fc040613          	addi	a2,s0,-64
    800061d6:	fd843583          	ld	a1,-40(s0)
    800061da:	0591                	addi	a1,a1,4
    800061dc:	68a8                	ld	a0,80(s1)
    800061de:	ffffb097          	auipc	ra,0xffffb
    800061e2:	494080e7          	jalr	1172(ra) # 80001672 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800061e6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800061e8:	06055563          	bgez	a0,80006252 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800061ec:	fc442783          	lw	a5,-60(s0)
    800061f0:	07e9                	addi	a5,a5,26
    800061f2:	078e                	slli	a5,a5,0x3
    800061f4:	97a6                	add	a5,a5,s1
    800061f6:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800061fa:	fc042503          	lw	a0,-64(s0)
    800061fe:	0569                	addi	a0,a0,26
    80006200:	050e                	slli	a0,a0,0x3
    80006202:	9526                	add	a0,a0,s1
    80006204:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006208:	fd043503          	ld	a0,-48(s0)
    8000620c:	fffff097          	auipc	ra,0xfffff
    80006210:	a3e080e7          	jalr	-1474(ra) # 80004c4a <fileclose>
    fileclose(wf);
    80006214:	fc843503          	ld	a0,-56(s0)
    80006218:	fffff097          	auipc	ra,0xfffff
    8000621c:	a32080e7          	jalr	-1486(ra) # 80004c4a <fileclose>
    return -1;
    80006220:	57fd                	li	a5,-1
    80006222:	a805                	j	80006252 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006224:	fc442783          	lw	a5,-60(s0)
    80006228:	0007c863          	bltz	a5,80006238 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    8000622c:	01a78513          	addi	a0,a5,26
    80006230:	050e                	slli	a0,a0,0x3
    80006232:	9526                	add	a0,a0,s1
    80006234:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006238:	fd043503          	ld	a0,-48(s0)
    8000623c:	fffff097          	auipc	ra,0xfffff
    80006240:	a0e080e7          	jalr	-1522(ra) # 80004c4a <fileclose>
    fileclose(wf);
    80006244:	fc843503          	ld	a0,-56(s0)
    80006248:	fffff097          	auipc	ra,0xfffff
    8000624c:	a02080e7          	jalr	-1534(ra) # 80004c4a <fileclose>
    return -1;
    80006250:	57fd                	li	a5,-1
}
    80006252:	853e                	mv	a0,a5
    80006254:	70e2                	ld	ra,56(sp)
    80006256:	7442                	ld	s0,48(sp)
    80006258:	74a2                	ld	s1,40(sp)
    8000625a:	6121                	addi	sp,sp,64
    8000625c:	8082                	ret
	...

0000000080006260 <kernelvec>:
    80006260:	7111                	addi	sp,sp,-256
    80006262:	e006                	sd	ra,0(sp)
    80006264:	e40a                	sd	sp,8(sp)
    80006266:	e80e                	sd	gp,16(sp)
    80006268:	ec12                	sd	tp,24(sp)
    8000626a:	f016                	sd	t0,32(sp)
    8000626c:	f41a                	sd	t1,40(sp)
    8000626e:	f81e                	sd	t2,48(sp)
    80006270:	fc22                	sd	s0,56(sp)
    80006272:	e0a6                	sd	s1,64(sp)
    80006274:	e4aa                	sd	a0,72(sp)
    80006276:	e8ae                	sd	a1,80(sp)
    80006278:	ecb2                	sd	a2,88(sp)
    8000627a:	f0b6                	sd	a3,96(sp)
    8000627c:	f4ba                	sd	a4,104(sp)
    8000627e:	f8be                	sd	a5,112(sp)
    80006280:	fcc2                	sd	a6,120(sp)
    80006282:	e146                	sd	a7,128(sp)
    80006284:	e54a                	sd	s2,136(sp)
    80006286:	e94e                	sd	s3,144(sp)
    80006288:	ed52                	sd	s4,152(sp)
    8000628a:	f156                	sd	s5,160(sp)
    8000628c:	f55a                	sd	s6,168(sp)
    8000628e:	f95e                	sd	s7,176(sp)
    80006290:	fd62                	sd	s8,184(sp)
    80006292:	e1e6                	sd	s9,192(sp)
    80006294:	e5ea                	sd	s10,200(sp)
    80006296:	e9ee                	sd	s11,208(sp)
    80006298:	edf2                	sd	t3,216(sp)
    8000629a:	f1f6                	sd	t4,224(sp)
    8000629c:	f5fa                	sd	t5,232(sp)
    8000629e:	f9fe                	sd	t6,240(sp)
    800062a0:	c89fc0ef          	jal	ra,80002f28 <kerneltrap>
    800062a4:	6082                	ld	ra,0(sp)
    800062a6:	6122                	ld	sp,8(sp)
    800062a8:	61c2                	ld	gp,16(sp)
    800062aa:	7282                	ld	t0,32(sp)
    800062ac:	7322                	ld	t1,40(sp)
    800062ae:	73c2                	ld	t2,48(sp)
    800062b0:	7462                	ld	s0,56(sp)
    800062b2:	6486                	ld	s1,64(sp)
    800062b4:	6526                	ld	a0,72(sp)
    800062b6:	65c6                	ld	a1,80(sp)
    800062b8:	6666                	ld	a2,88(sp)
    800062ba:	7686                	ld	a3,96(sp)
    800062bc:	7726                	ld	a4,104(sp)
    800062be:	77c6                	ld	a5,112(sp)
    800062c0:	7866                	ld	a6,120(sp)
    800062c2:	688a                	ld	a7,128(sp)
    800062c4:	692a                	ld	s2,136(sp)
    800062c6:	69ca                	ld	s3,144(sp)
    800062c8:	6a6a                	ld	s4,152(sp)
    800062ca:	7a8a                	ld	s5,160(sp)
    800062cc:	7b2a                	ld	s6,168(sp)
    800062ce:	7bca                	ld	s7,176(sp)
    800062d0:	7c6a                	ld	s8,184(sp)
    800062d2:	6c8e                	ld	s9,192(sp)
    800062d4:	6d2e                	ld	s10,200(sp)
    800062d6:	6dce                	ld	s11,208(sp)
    800062d8:	6e6e                	ld	t3,216(sp)
    800062da:	7e8e                	ld	t4,224(sp)
    800062dc:	7f2e                	ld	t5,232(sp)
    800062de:	7fce                	ld	t6,240(sp)
    800062e0:	6111                	addi	sp,sp,256
    800062e2:	10200073          	sret
    800062e6:	00000013          	nop
    800062ea:	00000013          	nop
    800062ee:	0001                	nop

00000000800062f0 <timervec>:
    800062f0:	34051573          	csrrw	a0,mscratch,a0
    800062f4:	e10c                	sd	a1,0(a0)
    800062f6:	e510                	sd	a2,8(a0)
    800062f8:	e914                	sd	a3,16(a0)
    800062fa:	6d0c                	ld	a1,24(a0)
    800062fc:	7110                	ld	a2,32(a0)
    800062fe:	6194                	ld	a3,0(a1)
    80006300:	96b2                	add	a3,a3,a2
    80006302:	e194                	sd	a3,0(a1)
    80006304:	4589                	li	a1,2
    80006306:	14459073          	csrw	sip,a1
    8000630a:	6914                	ld	a3,16(a0)
    8000630c:	6510                	ld	a2,8(a0)
    8000630e:	610c                	ld	a1,0(a0)
    80006310:	34051573          	csrrw	a0,mscratch,a0
    80006314:	30200073          	mret
	...

000000008000631a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000631a:	1141                	addi	sp,sp,-16
    8000631c:	e422                	sd	s0,8(sp)
    8000631e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006320:	0c0007b7          	lui	a5,0xc000
    80006324:	4705                	li	a4,1
    80006326:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006328:	c3d8                	sw	a4,4(a5)
}
    8000632a:	6422                	ld	s0,8(sp)
    8000632c:	0141                	addi	sp,sp,16
    8000632e:	8082                	ret

0000000080006330 <plicinithart>:

void
plicinithart(void)
{
    80006330:	1141                	addi	sp,sp,-16
    80006332:	e406                	sd	ra,8(sp)
    80006334:	e022                	sd	s0,0(sp)
    80006336:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006338:	ffffb097          	auipc	ra,0xffffb
    8000633c:	64c080e7          	jalr	1612(ra) # 80001984 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006340:	0085171b          	slliw	a4,a0,0x8
    80006344:	0c0027b7          	lui	a5,0xc002
    80006348:	97ba                	add	a5,a5,a4
    8000634a:	40200713          	li	a4,1026
    8000634e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006352:	00d5151b          	slliw	a0,a0,0xd
    80006356:	0c2017b7          	lui	a5,0xc201
    8000635a:	953e                	add	a0,a0,a5
    8000635c:	00052023          	sw	zero,0(a0)
}
    80006360:	60a2                	ld	ra,8(sp)
    80006362:	6402                	ld	s0,0(sp)
    80006364:	0141                	addi	sp,sp,16
    80006366:	8082                	ret

0000000080006368 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006368:	1141                	addi	sp,sp,-16
    8000636a:	e406                	sd	ra,8(sp)
    8000636c:	e022                	sd	s0,0(sp)
    8000636e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006370:	ffffb097          	auipc	ra,0xffffb
    80006374:	614080e7          	jalr	1556(ra) # 80001984 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006378:	00d5179b          	slliw	a5,a0,0xd
    8000637c:	0c201537          	lui	a0,0xc201
    80006380:	953e                	add	a0,a0,a5
  return irq;
}
    80006382:	4148                	lw	a0,4(a0)
    80006384:	60a2                	ld	ra,8(sp)
    80006386:	6402                	ld	s0,0(sp)
    80006388:	0141                	addi	sp,sp,16
    8000638a:	8082                	ret

000000008000638c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000638c:	1101                	addi	sp,sp,-32
    8000638e:	ec06                	sd	ra,24(sp)
    80006390:	e822                	sd	s0,16(sp)
    80006392:	e426                	sd	s1,8(sp)
    80006394:	1000                	addi	s0,sp,32
    80006396:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006398:	ffffb097          	auipc	ra,0xffffb
    8000639c:	5ec080e7          	jalr	1516(ra) # 80001984 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800063a0:	00d5151b          	slliw	a0,a0,0xd
    800063a4:	0c2017b7          	lui	a5,0xc201
    800063a8:	97aa                	add	a5,a5,a0
    800063aa:	c3c4                	sw	s1,4(a5)
}
    800063ac:	60e2                	ld	ra,24(sp)
    800063ae:	6442                	ld	s0,16(sp)
    800063b0:	64a2                	ld	s1,8(sp)
    800063b2:	6105                	addi	sp,sp,32
    800063b4:	8082                	ret

00000000800063b6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800063b6:	1141                	addi	sp,sp,-16
    800063b8:	e406                	sd	ra,8(sp)
    800063ba:	e022                	sd	s0,0(sp)
    800063bc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800063be:	479d                	li	a5,7
    800063c0:	06a7c963          	blt	a5,a0,80006432 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800063c4:	0001d797          	auipc	a5,0x1d
    800063c8:	c3c78793          	addi	a5,a5,-964 # 80023000 <disk>
    800063cc:	00a78733          	add	a4,a5,a0
    800063d0:	6789                	lui	a5,0x2
    800063d2:	97ba                	add	a5,a5,a4
    800063d4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800063d8:	e7ad                	bnez	a5,80006442 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800063da:	00451793          	slli	a5,a0,0x4
    800063de:	0001f717          	auipc	a4,0x1f
    800063e2:	c2270713          	addi	a4,a4,-990 # 80025000 <disk+0x2000>
    800063e6:	6314                	ld	a3,0(a4)
    800063e8:	96be                	add	a3,a3,a5
    800063ea:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800063ee:	6314                	ld	a3,0(a4)
    800063f0:	96be                	add	a3,a3,a5
    800063f2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800063f6:	6314                	ld	a3,0(a4)
    800063f8:	96be                	add	a3,a3,a5
    800063fa:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800063fe:	6318                	ld	a4,0(a4)
    80006400:	97ba                	add	a5,a5,a4
    80006402:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006406:	0001d797          	auipc	a5,0x1d
    8000640a:	bfa78793          	addi	a5,a5,-1030 # 80023000 <disk>
    8000640e:	97aa                	add	a5,a5,a0
    80006410:	6509                	lui	a0,0x2
    80006412:	953e                	add	a0,a0,a5
    80006414:	4785                	li	a5,1
    80006416:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000641a:	0001f517          	auipc	a0,0x1f
    8000641e:	bfe50513          	addi	a0,a0,-1026 # 80025018 <disk+0x2018>
    80006422:	ffffc097          	auipc	ra,0xffffc
    80006426:	102080e7          	jalr	258(ra) # 80002524 <wakeup>
}
    8000642a:	60a2                	ld	ra,8(sp)
    8000642c:	6402                	ld	s0,0(sp)
    8000642e:	0141                	addi	sp,sp,16
    80006430:	8082                	ret
    panic("free_desc 1");
    80006432:	00002517          	auipc	a0,0x2
    80006436:	47650513          	addi	a0,a0,1142 # 800088a8 <syscalls+0x358>
    8000643a:	ffffa097          	auipc	ra,0xffffa
    8000643e:	104080e7          	jalr	260(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006442:	00002517          	auipc	a0,0x2
    80006446:	47650513          	addi	a0,a0,1142 # 800088b8 <syscalls+0x368>
    8000644a:	ffffa097          	auipc	ra,0xffffa
    8000644e:	0f4080e7          	jalr	244(ra) # 8000053e <panic>

0000000080006452 <virtio_disk_init>:
{
    80006452:	1101                	addi	sp,sp,-32
    80006454:	ec06                	sd	ra,24(sp)
    80006456:	e822                	sd	s0,16(sp)
    80006458:	e426                	sd	s1,8(sp)
    8000645a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000645c:	00002597          	auipc	a1,0x2
    80006460:	46c58593          	addi	a1,a1,1132 # 800088c8 <syscalls+0x378>
    80006464:	0001f517          	auipc	a0,0x1f
    80006468:	cc450513          	addi	a0,a0,-828 # 80025128 <disk+0x2128>
    8000646c:	ffffa097          	auipc	ra,0xffffa
    80006470:	6e8080e7          	jalr	1768(ra) # 80000b54 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006474:	100017b7          	lui	a5,0x10001
    80006478:	4398                	lw	a4,0(a5)
    8000647a:	2701                	sext.w	a4,a4
    8000647c:	747277b7          	lui	a5,0x74727
    80006480:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006484:	0ef71163          	bne	a4,a5,80006566 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006488:	100017b7          	lui	a5,0x10001
    8000648c:	43dc                	lw	a5,4(a5)
    8000648e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006490:	4705                	li	a4,1
    80006492:	0ce79a63          	bne	a5,a4,80006566 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006496:	100017b7          	lui	a5,0x10001
    8000649a:	479c                	lw	a5,8(a5)
    8000649c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000649e:	4709                	li	a4,2
    800064a0:	0ce79363          	bne	a5,a4,80006566 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800064a4:	100017b7          	lui	a5,0x10001
    800064a8:	47d8                	lw	a4,12(a5)
    800064aa:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064ac:	554d47b7          	lui	a5,0x554d4
    800064b0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800064b4:	0af71963          	bne	a4,a5,80006566 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800064b8:	100017b7          	lui	a5,0x10001
    800064bc:	4705                	li	a4,1
    800064be:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800064c0:	470d                	li	a4,3
    800064c2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800064c4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800064c6:	c7ffe737          	lui	a4,0xc7ffe
    800064ca:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    800064ce:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800064d0:	2701                	sext.w	a4,a4
    800064d2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800064d4:	472d                	li	a4,11
    800064d6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800064d8:	473d                	li	a4,15
    800064da:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800064dc:	6705                	lui	a4,0x1
    800064de:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800064e0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800064e4:	5bdc                	lw	a5,52(a5)
    800064e6:	2781                	sext.w	a5,a5
  if(max == 0)
    800064e8:	c7d9                	beqz	a5,80006576 <virtio_disk_init+0x124>
  if(max < NUM)
    800064ea:	471d                	li	a4,7
    800064ec:	08f77d63          	bgeu	a4,a5,80006586 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800064f0:	100014b7          	lui	s1,0x10001
    800064f4:	47a1                	li	a5,8
    800064f6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800064f8:	6609                	lui	a2,0x2
    800064fa:	4581                	li	a1,0
    800064fc:	0001d517          	auipc	a0,0x1d
    80006500:	b0450513          	addi	a0,a0,-1276 # 80023000 <disk>
    80006504:	ffffa097          	auipc	ra,0xffffa
    80006508:	7dc080e7          	jalr	2012(ra) # 80000ce0 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000650c:	0001d717          	auipc	a4,0x1d
    80006510:	af470713          	addi	a4,a4,-1292 # 80023000 <disk>
    80006514:	00c75793          	srli	a5,a4,0xc
    80006518:	2781                	sext.w	a5,a5
    8000651a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000651c:	0001f797          	auipc	a5,0x1f
    80006520:	ae478793          	addi	a5,a5,-1308 # 80025000 <disk+0x2000>
    80006524:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006526:	0001d717          	auipc	a4,0x1d
    8000652a:	b5a70713          	addi	a4,a4,-1190 # 80023080 <disk+0x80>
    8000652e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006530:	0001e717          	auipc	a4,0x1e
    80006534:	ad070713          	addi	a4,a4,-1328 # 80024000 <disk+0x1000>
    80006538:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000653a:	4705                	li	a4,1
    8000653c:	00e78c23          	sb	a4,24(a5)
    80006540:	00e78ca3          	sb	a4,25(a5)
    80006544:	00e78d23          	sb	a4,26(a5)
    80006548:	00e78da3          	sb	a4,27(a5)
    8000654c:	00e78e23          	sb	a4,28(a5)
    80006550:	00e78ea3          	sb	a4,29(a5)
    80006554:	00e78f23          	sb	a4,30(a5)
    80006558:	00e78fa3          	sb	a4,31(a5)
}
    8000655c:	60e2                	ld	ra,24(sp)
    8000655e:	6442                	ld	s0,16(sp)
    80006560:	64a2                	ld	s1,8(sp)
    80006562:	6105                	addi	sp,sp,32
    80006564:	8082                	ret
    panic("could not find virtio disk");
    80006566:	00002517          	auipc	a0,0x2
    8000656a:	37250513          	addi	a0,a0,882 # 800088d8 <syscalls+0x388>
    8000656e:	ffffa097          	auipc	ra,0xffffa
    80006572:	fd0080e7          	jalr	-48(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006576:	00002517          	auipc	a0,0x2
    8000657a:	38250513          	addi	a0,a0,898 # 800088f8 <syscalls+0x3a8>
    8000657e:	ffffa097          	auipc	ra,0xffffa
    80006582:	fc0080e7          	jalr	-64(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006586:	00002517          	auipc	a0,0x2
    8000658a:	39250513          	addi	a0,a0,914 # 80008918 <syscalls+0x3c8>
    8000658e:	ffffa097          	auipc	ra,0xffffa
    80006592:	fb0080e7          	jalr	-80(ra) # 8000053e <panic>

0000000080006596 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006596:	7159                	addi	sp,sp,-112
    80006598:	f486                	sd	ra,104(sp)
    8000659a:	f0a2                	sd	s0,96(sp)
    8000659c:	eca6                	sd	s1,88(sp)
    8000659e:	e8ca                	sd	s2,80(sp)
    800065a0:	e4ce                	sd	s3,72(sp)
    800065a2:	e0d2                	sd	s4,64(sp)
    800065a4:	fc56                	sd	s5,56(sp)
    800065a6:	f85a                	sd	s6,48(sp)
    800065a8:	f45e                	sd	s7,40(sp)
    800065aa:	f062                	sd	s8,32(sp)
    800065ac:	ec66                	sd	s9,24(sp)
    800065ae:	e86a                	sd	s10,16(sp)
    800065b0:	1880                	addi	s0,sp,112
    800065b2:	892a                	mv	s2,a0
    800065b4:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800065b6:	00c52c83          	lw	s9,12(a0)
    800065ba:	001c9c9b          	slliw	s9,s9,0x1
    800065be:	1c82                	slli	s9,s9,0x20
    800065c0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800065c4:	0001f517          	auipc	a0,0x1f
    800065c8:	b6450513          	addi	a0,a0,-1180 # 80025128 <disk+0x2128>
    800065cc:	ffffa097          	auipc	ra,0xffffa
    800065d0:	618080e7          	jalr	1560(ra) # 80000be4 <acquire>
  for(int i = 0; i < 3; i++){
    800065d4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800065d6:	4c21                	li	s8,8
      disk.free[i] = 0;
    800065d8:	0001db97          	auipc	s7,0x1d
    800065dc:	a28b8b93          	addi	s7,s7,-1496 # 80023000 <disk>
    800065e0:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    800065e2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800065e4:	8a4e                	mv	s4,s3
    800065e6:	a051                	j	8000666a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    800065e8:	00fb86b3          	add	a3,s7,a5
    800065ec:	96da                	add	a3,a3,s6
    800065ee:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800065f2:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800065f4:	0207c563          	bltz	a5,8000661e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800065f8:	2485                	addiw	s1,s1,1
    800065fa:	0711                	addi	a4,a4,4
    800065fc:	25548063          	beq	s1,s5,8000683c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80006600:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006602:	0001f697          	auipc	a3,0x1f
    80006606:	a1668693          	addi	a3,a3,-1514 # 80025018 <disk+0x2018>
    8000660a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    8000660c:	0006c583          	lbu	a1,0(a3)
    80006610:	fde1                	bnez	a1,800065e8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006612:	2785                	addiw	a5,a5,1
    80006614:	0685                	addi	a3,a3,1
    80006616:	ff879be3          	bne	a5,s8,8000660c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000661a:	57fd                	li	a5,-1
    8000661c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000661e:	02905a63          	blez	s1,80006652 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006622:	f9042503          	lw	a0,-112(s0)
    80006626:	00000097          	auipc	ra,0x0
    8000662a:	d90080e7          	jalr	-624(ra) # 800063b6 <free_desc>
      for(int j = 0; j < i; j++)
    8000662e:	4785                	li	a5,1
    80006630:	0297d163          	bge	a5,s1,80006652 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006634:	f9442503          	lw	a0,-108(s0)
    80006638:	00000097          	auipc	ra,0x0
    8000663c:	d7e080e7          	jalr	-642(ra) # 800063b6 <free_desc>
      for(int j = 0; j < i; j++)
    80006640:	4789                	li	a5,2
    80006642:	0097d863          	bge	a5,s1,80006652 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006646:	f9842503          	lw	a0,-104(s0)
    8000664a:	00000097          	auipc	ra,0x0
    8000664e:	d6c080e7          	jalr	-660(ra) # 800063b6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006652:	0001f597          	auipc	a1,0x1f
    80006656:	ad658593          	addi	a1,a1,-1322 # 80025128 <disk+0x2128>
    8000665a:	0001f517          	auipc	a0,0x1f
    8000665e:	9be50513          	addi	a0,a0,-1602 # 80025018 <disk+0x2018>
    80006662:	ffffc097          	auipc	ra,0xffffc
    80006666:	c02080e7          	jalr	-1022(ra) # 80002264 <sleep>
  for(int i = 0; i < 3; i++){
    8000666a:	f9040713          	addi	a4,s0,-112
    8000666e:	84ce                	mv	s1,s3
    80006670:	bf41                	j	80006600 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006672:	20058713          	addi	a4,a1,512
    80006676:	00471693          	slli	a3,a4,0x4
    8000667a:	0001d717          	auipc	a4,0x1d
    8000667e:	98670713          	addi	a4,a4,-1658 # 80023000 <disk>
    80006682:	9736                	add	a4,a4,a3
    80006684:	4685                	li	a3,1
    80006686:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000668a:	20058713          	addi	a4,a1,512
    8000668e:	00471693          	slli	a3,a4,0x4
    80006692:	0001d717          	auipc	a4,0x1d
    80006696:	96e70713          	addi	a4,a4,-1682 # 80023000 <disk>
    8000669a:	9736                	add	a4,a4,a3
    8000669c:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800066a0:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800066a4:	7679                	lui	a2,0xffffe
    800066a6:	963e                	add	a2,a2,a5
    800066a8:	0001f697          	auipc	a3,0x1f
    800066ac:	95868693          	addi	a3,a3,-1704 # 80025000 <disk+0x2000>
    800066b0:	6298                	ld	a4,0(a3)
    800066b2:	9732                	add	a4,a4,a2
    800066b4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800066b6:	6298                	ld	a4,0(a3)
    800066b8:	9732                	add	a4,a4,a2
    800066ba:	4541                	li	a0,16
    800066bc:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800066be:	6298                	ld	a4,0(a3)
    800066c0:	9732                	add	a4,a4,a2
    800066c2:	4505                	li	a0,1
    800066c4:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800066c8:	f9442703          	lw	a4,-108(s0)
    800066cc:	6288                	ld	a0,0(a3)
    800066ce:	962a                	add	a2,a2,a0
    800066d0:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    800066d4:	0712                	slli	a4,a4,0x4
    800066d6:	6290                	ld	a2,0(a3)
    800066d8:	963a                	add	a2,a2,a4
    800066da:	05890513          	addi	a0,s2,88
    800066de:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800066e0:	6294                	ld	a3,0(a3)
    800066e2:	96ba                	add	a3,a3,a4
    800066e4:	40000613          	li	a2,1024
    800066e8:	c690                	sw	a2,8(a3)
  if(write)
    800066ea:	140d0063          	beqz	s10,8000682a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800066ee:	0001f697          	auipc	a3,0x1f
    800066f2:	9126b683          	ld	a3,-1774(a3) # 80025000 <disk+0x2000>
    800066f6:	96ba                	add	a3,a3,a4
    800066f8:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800066fc:	0001d817          	auipc	a6,0x1d
    80006700:	90480813          	addi	a6,a6,-1788 # 80023000 <disk>
    80006704:	0001f517          	auipc	a0,0x1f
    80006708:	8fc50513          	addi	a0,a0,-1796 # 80025000 <disk+0x2000>
    8000670c:	6114                	ld	a3,0(a0)
    8000670e:	96ba                	add	a3,a3,a4
    80006710:	00c6d603          	lhu	a2,12(a3)
    80006714:	00166613          	ori	a2,a2,1
    80006718:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000671c:	f9842683          	lw	a3,-104(s0)
    80006720:	6110                	ld	a2,0(a0)
    80006722:	9732                	add	a4,a4,a2
    80006724:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006728:	20058613          	addi	a2,a1,512
    8000672c:	0612                	slli	a2,a2,0x4
    8000672e:	9642                	add	a2,a2,a6
    80006730:	577d                	li	a4,-1
    80006732:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006736:	00469713          	slli	a4,a3,0x4
    8000673a:	6114                	ld	a3,0(a0)
    8000673c:	96ba                	add	a3,a3,a4
    8000673e:	03078793          	addi	a5,a5,48
    80006742:	97c2                	add	a5,a5,a6
    80006744:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80006746:	611c                	ld	a5,0(a0)
    80006748:	97ba                	add	a5,a5,a4
    8000674a:	4685                	li	a3,1
    8000674c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000674e:	611c                	ld	a5,0(a0)
    80006750:	97ba                	add	a5,a5,a4
    80006752:	4809                	li	a6,2
    80006754:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006758:	611c                	ld	a5,0(a0)
    8000675a:	973e                	add	a4,a4,a5
    8000675c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006760:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80006764:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006768:	6518                	ld	a4,8(a0)
    8000676a:	00275783          	lhu	a5,2(a4)
    8000676e:	8b9d                	andi	a5,a5,7
    80006770:	0786                	slli	a5,a5,0x1
    80006772:	97ba                	add	a5,a5,a4
    80006774:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006778:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000677c:	6518                	ld	a4,8(a0)
    8000677e:	00275783          	lhu	a5,2(a4)
    80006782:	2785                	addiw	a5,a5,1
    80006784:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006788:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000678c:	100017b7          	lui	a5,0x10001
    80006790:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006794:	00492703          	lw	a4,4(s2)
    80006798:	4785                	li	a5,1
    8000679a:	02f71163          	bne	a4,a5,800067bc <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    8000679e:	0001f997          	auipc	s3,0x1f
    800067a2:	98a98993          	addi	s3,s3,-1654 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    800067a6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800067a8:	85ce                	mv	a1,s3
    800067aa:	854a                	mv	a0,s2
    800067ac:	ffffc097          	auipc	ra,0xffffc
    800067b0:	ab8080e7          	jalr	-1352(ra) # 80002264 <sleep>
  while(b->disk == 1) {
    800067b4:	00492783          	lw	a5,4(s2)
    800067b8:	fe9788e3          	beq	a5,s1,800067a8 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    800067bc:	f9042903          	lw	s2,-112(s0)
    800067c0:	20090793          	addi	a5,s2,512
    800067c4:	00479713          	slli	a4,a5,0x4
    800067c8:	0001d797          	auipc	a5,0x1d
    800067cc:	83878793          	addi	a5,a5,-1992 # 80023000 <disk>
    800067d0:	97ba                	add	a5,a5,a4
    800067d2:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800067d6:	0001f997          	auipc	s3,0x1f
    800067da:	82a98993          	addi	s3,s3,-2006 # 80025000 <disk+0x2000>
    800067de:	00491713          	slli	a4,s2,0x4
    800067e2:	0009b783          	ld	a5,0(s3)
    800067e6:	97ba                	add	a5,a5,a4
    800067e8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800067ec:	854a                	mv	a0,s2
    800067ee:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800067f2:	00000097          	auipc	ra,0x0
    800067f6:	bc4080e7          	jalr	-1084(ra) # 800063b6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800067fa:	8885                	andi	s1,s1,1
    800067fc:	f0ed                	bnez	s1,800067de <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800067fe:	0001f517          	auipc	a0,0x1f
    80006802:	92a50513          	addi	a0,a0,-1750 # 80025128 <disk+0x2128>
    80006806:	ffffa097          	auipc	ra,0xffffa
    8000680a:	492080e7          	jalr	1170(ra) # 80000c98 <release>
}
    8000680e:	70a6                	ld	ra,104(sp)
    80006810:	7406                	ld	s0,96(sp)
    80006812:	64e6                	ld	s1,88(sp)
    80006814:	6946                	ld	s2,80(sp)
    80006816:	69a6                	ld	s3,72(sp)
    80006818:	6a06                	ld	s4,64(sp)
    8000681a:	7ae2                	ld	s5,56(sp)
    8000681c:	7b42                	ld	s6,48(sp)
    8000681e:	7ba2                	ld	s7,40(sp)
    80006820:	7c02                	ld	s8,32(sp)
    80006822:	6ce2                	ld	s9,24(sp)
    80006824:	6d42                	ld	s10,16(sp)
    80006826:	6165                	addi	sp,sp,112
    80006828:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000682a:	0001e697          	auipc	a3,0x1e
    8000682e:	7d66b683          	ld	a3,2006(a3) # 80025000 <disk+0x2000>
    80006832:	96ba                	add	a3,a3,a4
    80006834:	4609                	li	a2,2
    80006836:	00c69623          	sh	a2,12(a3)
    8000683a:	b5c9                	j	800066fc <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000683c:	f9042583          	lw	a1,-112(s0)
    80006840:	20058793          	addi	a5,a1,512
    80006844:	0792                	slli	a5,a5,0x4
    80006846:	0001d517          	auipc	a0,0x1d
    8000684a:	86250513          	addi	a0,a0,-1950 # 800230a8 <disk+0xa8>
    8000684e:	953e                	add	a0,a0,a5
  if(write)
    80006850:	e20d11e3          	bnez	s10,80006672 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006854:	20058713          	addi	a4,a1,512
    80006858:	00471693          	slli	a3,a4,0x4
    8000685c:	0001c717          	auipc	a4,0x1c
    80006860:	7a470713          	addi	a4,a4,1956 # 80023000 <disk>
    80006864:	9736                	add	a4,a4,a3
    80006866:	0a072423          	sw	zero,168(a4)
    8000686a:	b505                	j	8000668a <virtio_disk_rw+0xf4>

000000008000686c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000686c:	1101                	addi	sp,sp,-32
    8000686e:	ec06                	sd	ra,24(sp)
    80006870:	e822                	sd	s0,16(sp)
    80006872:	e426                	sd	s1,8(sp)
    80006874:	e04a                	sd	s2,0(sp)
    80006876:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006878:	0001f517          	auipc	a0,0x1f
    8000687c:	8b050513          	addi	a0,a0,-1872 # 80025128 <disk+0x2128>
    80006880:	ffffa097          	auipc	ra,0xffffa
    80006884:	364080e7          	jalr	868(ra) # 80000be4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006888:	10001737          	lui	a4,0x10001
    8000688c:	533c                	lw	a5,96(a4)
    8000688e:	8b8d                	andi	a5,a5,3
    80006890:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006892:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006896:	0001e797          	auipc	a5,0x1e
    8000689a:	76a78793          	addi	a5,a5,1898 # 80025000 <disk+0x2000>
    8000689e:	6b94                	ld	a3,16(a5)
    800068a0:	0207d703          	lhu	a4,32(a5)
    800068a4:	0026d783          	lhu	a5,2(a3)
    800068a8:	06f70163          	beq	a4,a5,8000690a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800068ac:	0001c917          	auipc	s2,0x1c
    800068b0:	75490913          	addi	s2,s2,1876 # 80023000 <disk>
    800068b4:	0001e497          	auipc	s1,0x1e
    800068b8:	74c48493          	addi	s1,s1,1868 # 80025000 <disk+0x2000>
    __sync_synchronize();
    800068bc:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800068c0:	6898                	ld	a4,16(s1)
    800068c2:	0204d783          	lhu	a5,32(s1)
    800068c6:	8b9d                	andi	a5,a5,7
    800068c8:	078e                	slli	a5,a5,0x3
    800068ca:	97ba                	add	a5,a5,a4
    800068cc:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800068ce:	20078713          	addi	a4,a5,512
    800068d2:	0712                	slli	a4,a4,0x4
    800068d4:	974a                	add	a4,a4,s2
    800068d6:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800068da:	e731                	bnez	a4,80006926 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800068dc:	20078793          	addi	a5,a5,512
    800068e0:	0792                	slli	a5,a5,0x4
    800068e2:	97ca                	add	a5,a5,s2
    800068e4:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800068e6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800068ea:	ffffc097          	auipc	ra,0xffffc
    800068ee:	c3a080e7          	jalr	-966(ra) # 80002524 <wakeup>

    disk.used_idx += 1;
    800068f2:	0204d783          	lhu	a5,32(s1)
    800068f6:	2785                	addiw	a5,a5,1
    800068f8:	17c2                	slli	a5,a5,0x30
    800068fa:	93c1                	srli	a5,a5,0x30
    800068fc:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006900:	6898                	ld	a4,16(s1)
    80006902:	00275703          	lhu	a4,2(a4)
    80006906:	faf71be3          	bne	a4,a5,800068bc <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000690a:	0001f517          	auipc	a0,0x1f
    8000690e:	81e50513          	addi	a0,a0,-2018 # 80025128 <disk+0x2128>
    80006912:	ffffa097          	auipc	ra,0xffffa
    80006916:	386080e7          	jalr	902(ra) # 80000c98 <release>
}
    8000691a:	60e2                	ld	ra,24(sp)
    8000691c:	6442                	ld	s0,16(sp)
    8000691e:	64a2                	ld	s1,8(sp)
    80006920:	6902                	ld	s2,0(sp)
    80006922:	6105                	addi	sp,sp,32
    80006924:	8082                	ret
      panic("virtio_disk_intr status");
    80006926:	00002517          	auipc	a0,0x2
    8000692a:	01250513          	addi	a0,a0,18 # 80008938 <syscalls+0x3e8>
    8000692e:	ffffa097          	auipc	ra,0xffffa
    80006932:	c10080e7          	jalr	-1008(ra) # 8000053e <panic>
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
