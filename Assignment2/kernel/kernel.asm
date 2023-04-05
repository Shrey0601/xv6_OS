
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	ac013103          	ld	sp,-1344(sp) # 80009ac0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

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
  int interval = TIMER_INTERVAL; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	6661                	lui	a2,0x18
    8000003e:	6a060613          	addi	a2,a2,1696 # 186a0 <_entry-0x7ffe7960>
    80000042:	95b2                	add	a1,a1,a2
    80000044:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000046:	00269713          	slli	a4,a3,0x2
    8000004a:	9736                	add	a4,a4,a3
    8000004c:	00371693          	slli	a3,a4,0x3
    80000050:	0000a717          	auipc	a4,0xa
    80000054:	03070713          	addi	a4,a4,48 # 8000a080 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00007797          	auipc	a5,0x7
    80000066:	cce78793          	addi	a5,a5,-818 # 80006d30 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd77ff>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	de078793          	addi	a5,a5,-544 # 80000e8c <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05663          	blez	a2,8000015e <consolewrite+0x5e>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00003097          	auipc	ra,0x3
    8000012e:	016080e7          	jalr	22(ra) # 80003140 <either_copyin>
    80000132:	01550c63          	beq	a0,s5,8000014a <consolewrite+0x4a>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	78e080e7          	jalr	1934(ra) # 800008c8 <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
  }

  return i;
}
    8000014a:	854a                	mv	a0,s2
    8000014c:	60a6                	ld	ra,72(sp)
    8000014e:	6406                	ld	s0,64(sp)
    80000150:	74e2                	ld	s1,56(sp)
    80000152:	7942                	ld	s2,48(sp)
    80000154:	79a2                	ld	s3,40(sp)
    80000156:	7a02                	ld	s4,32(sp)
    80000158:	6ae2                	ld	s5,24(sp)
    8000015a:	6161                	addi	sp,sp,80
    8000015c:	8082                	ret
  for(i = 0; i < n; i++){
    8000015e:	4901                	li	s2,0
    80000160:	b7ed                	j	8000014a <consolewrite+0x4a>

0000000080000162 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000162:	7119                	addi	sp,sp,-128
    80000164:	fc86                	sd	ra,120(sp)
    80000166:	f8a2                	sd	s0,112(sp)
    80000168:	f4a6                	sd	s1,104(sp)
    8000016a:	f0ca                	sd	s2,96(sp)
    8000016c:	ecce                	sd	s3,88(sp)
    8000016e:	e8d2                	sd	s4,80(sp)
    80000170:	e4d6                	sd	s5,72(sp)
    80000172:	e0da                	sd	s6,64(sp)
    80000174:	fc5e                	sd	s7,56(sp)
    80000176:	f862                	sd	s8,48(sp)
    80000178:	f466                	sd	s9,40(sp)
    8000017a:	f06a                	sd	s10,32(sp)
    8000017c:	ec6e                	sd	s11,24(sp)
    8000017e:	0100                	addi	s0,sp,128
    80000180:	8b2a                	mv	s6,a0
    80000182:	8aae                	mv	s5,a1
    80000184:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000018a:	00012517          	auipc	a0,0x12
    8000018e:	03650513          	addi	a0,a0,54 # 800121c0 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a50080e7          	jalr	-1456(ra) # 80000be2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00012497          	auipc	s1,0x12
    8000019e:	02648493          	addi	s1,s1,38 # 800121c0 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	89a6                	mv	s3,s1
    800001a4:	00012917          	auipc	s2,0x12
    800001a8:	0b490913          	addi	s2,s2,180 # 80012258 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001ac:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ae:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b0:	4da9                	li	s11,10
  while(n > 0){
    800001b2:	07405863          	blez	s4,80000222 <consoleread+0xc0>
    while(cons.r == cons.w){
    800001b6:	0984a783          	lw	a5,152(s1)
    800001ba:	09c4a703          	lw	a4,156(s1)
    800001be:	02f71463          	bne	a4,a5,800001e6 <consoleread+0x84>
      if(myproc()->killed){
    800001c2:	00001097          	auipc	ra,0x1
    800001c6:	7ec080e7          	jalr	2028(ra) # 800019ae <myproc>
    800001ca:	551c                	lw	a5,40(a0)
    800001cc:	e7b5                	bnez	a5,80000238 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001ce:	85ce                	mv	a1,s3
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	524080e7          	jalr	1316(ra) # 800026f6 <sleep>
    while(cons.r == cons.w){
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fef700e3          	beq	a4,a5,800001c2 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e6:	0017871b          	addiw	a4,a5,1
    800001ea:	08e4ac23          	sw	a4,152(s1)
    800001ee:	07f7f713          	andi	a4,a5,127
    800001f2:	9726                	add	a4,a4,s1
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    800001fc:	079c0663          	beq	s8,s9,80000268 <consoleread+0x106>
    cbuf = c;
    80000200:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000204:	4685                	li	a3,1
    80000206:	f8f40613          	addi	a2,s0,-113
    8000020a:	85d6                	mv	a1,s5
    8000020c:	855a                	mv	a0,s6
    8000020e:	00003097          	auipc	ra,0x3
    80000212:	edc080e7          	jalr	-292(ra) # 800030ea <either_copyout>
    80000216:	01a50663          	beq	a0,s10,80000222 <consoleread+0xc0>
    dst++;
    8000021a:	0a85                	addi	s5,s5,1
    --n;
    8000021c:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000021e:	f9bc1ae3          	bne	s8,s11,800001b2 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000222:	00012517          	auipc	a0,0x12
    80000226:	f9e50513          	addi	a0,a0,-98 # 800121c0 <cons>
    8000022a:	00001097          	auipc	ra,0x1
    8000022e:	a6c080e7          	jalr	-1428(ra) # 80000c96 <release>

  return target - n;
    80000232:	414b853b          	subw	a0,s7,s4
    80000236:	a811                	j	8000024a <consoleread+0xe8>
        release(&cons.lock);
    80000238:	00012517          	auipc	a0,0x12
    8000023c:	f8850513          	addi	a0,a0,-120 # 800121c0 <cons>
    80000240:	00001097          	auipc	ra,0x1
    80000244:	a56080e7          	jalr	-1450(ra) # 80000c96 <release>
        return -1;
    80000248:	557d                	li	a0,-1
}
    8000024a:	70e6                	ld	ra,120(sp)
    8000024c:	7446                	ld	s0,112(sp)
    8000024e:	74a6                	ld	s1,104(sp)
    80000250:	7906                	ld	s2,96(sp)
    80000252:	69e6                	ld	s3,88(sp)
    80000254:	6a46                	ld	s4,80(sp)
    80000256:	6aa6                	ld	s5,72(sp)
    80000258:	6b06                	ld	s6,64(sp)
    8000025a:	7be2                	ld	s7,56(sp)
    8000025c:	7c42                	ld	s8,48(sp)
    8000025e:	7ca2                	ld	s9,40(sp)
    80000260:	7d02                	ld	s10,32(sp)
    80000262:	6de2                	ld	s11,24(sp)
    80000264:	6109                	addi	sp,sp,128
    80000266:	8082                	ret
      if(n < target){
    80000268:	000a071b          	sext.w	a4,s4
    8000026c:	fb777be3          	bgeu	a4,s7,80000222 <consoleread+0xc0>
        cons.r--;
    80000270:	00012717          	auipc	a4,0x12
    80000274:	fef72423          	sw	a5,-24(a4) # 80012258 <cons+0x98>
    80000278:	b76d                	j	80000222 <consoleread+0xc0>

000000008000027a <consputc>:
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000282:	10000793          	li	a5,256
    80000286:	00f50a63          	beq	a0,a5,8000029a <consputc+0x20>
    uartputc_sync(c);
    8000028a:	00000097          	auipc	ra,0x0
    8000028e:	564080e7          	jalr	1380(ra) # 800007ee <uartputc_sync>
}
    80000292:	60a2                	ld	ra,8(sp)
    80000294:	6402                	ld	s0,0(sp)
    80000296:	0141                	addi	sp,sp,16
    80000298:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029a:	4521                	li	a0,8
    8000029c:	00000097          	auipc	ra,0x0
    800002a0:	552080e7          	jalr	1362(ra) # 800007ee <uartputc_sync>
    800002a4:	02000513          	li	a0,32
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	546080e7          	jalr	1350(ra) # 800007ee <uartputc_sync>
    800002b0:	4521                	li	a0,8
    800002b2:	00000097          	auipc	ra,0x0
    800002b6:	53c080e7          	jalr	1340(ra) # 800007ee <uartputc_sync>
    800002ba:	bfe1                	j	80000292 <consputc+0x18>

00000000800002bc <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002bc:	1101                	addi	sp,sp,-32
    800002be:	ec06                	sd	ra,24(sp)
    800002c0:	e822                	sd	s0,16(sp)
    800002c2:	e426                	sd	s1,8(sp)
    800002c4:	e04a                	sd	s2,0(sp)
    800002c6:	1000                	addi	s0,sp,32
    800002c8:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002ca:	00012517          	auipc	a0,0x12
    800002ce:	ef650513          	addi	a0,a0,-266 # 800121c0 <cons>
    800002d2:	00001097          	auipc	ra,0x1
    800002d6:	910080e7          	jalr	-1776(ra) # 80000be2 <acquire>

  switch(c){
    800002da:	47d5                	li	a5,21
    800002dc:	0af48663          	beq	s1,a5,80000388 <consoleintr+0xcc>
    800002e0:	0297ca63          	blt	a5,s1,80000314 <consoleintr+0x58>
    800002e4:	47a1                	li	a5,8
    800002e6:	0ef48763          	beq	s1,a5,800003d4 <consoleintr+0x118>
    800002ea:	47c1                	li	a5,16
    800002ec:	10f49a63          	bne	s1,a5,80000400 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f0:	00003097          	auipc	ra,0x3
    800002f4:	ea6080e7          	jalr	-346(ra) # 80003196 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f8:	00012517          	auipc	a0,0x12
    800002fc:	ec850513          	addi	a0,a0,-312 # 800121c0 <cons>
    80000300:	00001097          	auipc	ra,0x1
    80000304:	996080e7          	jalr	-1642(ra) # 80000c96 <release>
}
    80000308:	60e2                	ld	ra,24(sp)
    8000030a:	6442                	ld	s0,16(sp)
    8000030c:	64a2                	ld	s1,8(sp)
    8000030e:	6902                	ld	s2,0(sp)
    80000310:	6105                	addi	sp,sp,32
    80000312:	8082                	ret
  switch(c){
    80000314:	07f00793          	li	a5,127
    80000318:	0af48e63          	beq	s1,a5,800003d4 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000031c:	00012717          	auipc	a4,0x12
    80000320:	ea470713          	addi	a4,a4,-348 # 800121c0 <cons>
    80000324:	0a072783          	lw	a5,160(a4)
    80000328:	09872703          	lw	a4,152(a4)
    8000032c:	9f99                	subw	a5,a5,a4
    8000032e:	07f00713          	li	a4,127
    80000332:	fcf763e3          	bltu	a4,a5,800002f8 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000336:	47b5                	li	a5,13
    80000338:	0cf48763          	beq	s1,a5,80000406 <consoleintr+0x14a>
      consputc(c);
    8000033c:	8526                	mv	a0,s1
    8000033e:	00000097          	auipc	ra,0x0
    80000342:	f3c080e7          	jalr	-196(ra) # 8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000346:	00012797          	auipc	a5,0x12
    8000034a:	e7a78793          	addi	a5,a5,-390 # 800121c0 <cons>
    8000034e:	0a07a703          	lw	a4,160(a5)
    80000352:	0017069b          	addiw	a3,a4,1
    80000356:	0006861b          	sext.w	a2,a3
    8000035a:	0ad7a023          	sw	a3,160(a5)
    8000035e:	07f77713          	andi	a4,a4,127
    80000362:	97ba                	add	a5,a5,a4
    80000364:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000368:	47a9                	li	a5,10
    8000036a:	0cf48563          	beq	s1,a5,80000434 <consoleintr+0x178>
    8000036e:	4791                	li	a5,4
    80000370:	0cf48263          	beq	s1,a5,80000434 <consoleintr+0x178>
    80000374:	00012797          	auipc	a5,0x12
    80000378:	ee47a783          	lw	a5,-284(a5) # 80012258 <cons+0x98>
    8000037c:	0807879b          	addiw	a5,a5,128
    80000380:	f6f61ce3          	bne	a2,a5,800002f8 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000384:	863e                	mv	a2,a5
    80000386:	a07d                	j	80000434 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000388:	00012717          	auipc	a4,0x12
    8000038c:	e3870713          	addi	a4,a4,-456 # 800121c0 <cons>
    80000390:	0a072783          	lw	a5,160(a4)
    80000394:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000398:	00012497          	auipc	s1,0x12
    8000039c:	e2848493          	addi	s1,s1,-472 # 800121c0 <cons>
    while(cons.e != cons.w &&
    800003a0:	4929                	li	s2,10
    800003a2:	f4f70be3          	beq	a4,a5,800002f8 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a6:	37fd                	addiw	a5,a5,-1
    800003a8:	07f7f713          	andi	a4,a5,127
    800003ac:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ae:	01874703          	lbu	a4,24(a4)
    800003b2:	f52703e3          	beq	a4,s2,800002f8 <consoleintr+0x3c>
      cons.e--;
    800003b6:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003ba:	10000513          	li	a0,256
    800003be:	00000097          	auipc	ra,0x0
    800003c2:	ebc080e7          	jalr	-324(ra) # 8000027a <consputc>
    while(cons.e != cons.w &&
    800003c6:	0a04a783          	lw	a5,160(s1)
    800003ca:	09c4a703          	lw	a4,156(s1)
    800003ce:	fcf71ce3          	bne	a4,a5,800003a6 <consoleintr+0xea>
    800003d2:	b71d                	j	800002f8 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d4:	00012717          	auipc	a4,0x12
    800003d8:	dec70713          	addi	a4,a4,-532 # 800121c0 <cons>
    800003dc:	0a072783          	lw	a5,160(a4)
    800003e0:	09c72703          	lw	a4,156(a4)
    800003e4:	f0f70ae3          	beq	a4,a5,800002f8 <consoleintr+0x3c>
      cons.e--;
    800003e8:	37fd                	addiw	a5,a5,-1
    800003ea:	00012717          	auipc	a4,0x12
    800003ee:	e6f72b23          	sw	a5,-394(a4) # 80012260 <cons+0xa0>
      consputc(BACKSPACE);
    800003f2:	10000513          	li	a0,256
    800003f6:	00000097          	auipc	ra,0x0
    800003fa:	e84080e7          	jalr	-380(ra) # 8000027a <consputc>
    800003fe:	bded                	j	800002f8 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000400:	ee048ce3          	beqz	s1,800002f8 <consoleintr+0x3c>
    80000404:	bf21                	j	8000031c <consoleintr+0x60>
      consputc(c);
    80000406:	4529                	li	a0,10
    80000408:	00000097          	auipc	ra,0x0
    8000040c:	e72080e7          	jalr	-398(ra) # 8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000410:	00012797          	auipc	a5,0x12
    80000414:	db078793          	addi	a5,a5,-592 # 800121c0 <cons>
    80000418:	0a07a703          	lw	a4,160(a5)
    8000041c:	0017069b          	addiw	a3,a4,1
    80000420:	0006861b          	sext.w	a2,a3
    80000424:	0ad7a023          	sw	a3,160(a5)
    80000428:	07f77713          	andi	a4,a4,127
    8000042c:	97ba                	add	a5,a5,a4
    8000042e:	4729                	li	a4,10
    80000430:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000434:	00012797          	auipc	a5,0x12
    80000438:	e2c7a423          	sw	a2,-472(a5) # 8001225c <cons+0x9c>
        wakeup(&cons.r);
    8000043c:	00012517          	auipc	a0,0x12
    80000440:	e1c50513          	addi	a0,a0,-484 # 80012258 <cons+0x98>
    80000444:	00002097          	auipc	ra,0x2
    80000448:	754080e7          	jalr	1876(ra) # 80002b98 <wakeup>
    8000044c:	b575                	j	800002f8 <consoleintr+0x3c>

000000008000044e <consoleinit>:

void
consoleinit(void)
{
    8000044e:	1141                	addi	sp,sp,-16
    80000450:	e406                	sd	ra,8(sp)
    80000452:	e022                	sd	s0,0(sp)
    80000454:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000456:	00009597          	auipc	a1,0x9
    8000045a:	bba58593          	addi	a1,a1,-1094 # 80009010 <etext+0x10>
    8000045e:	00012517          	auipc	a0,0x12
    80000462:	d6250513          	addi	a0,a0,-670 # 800121c0 <cons>
    80000466:	00000097          	auipc	ra,0x0
    8000046a:	6ec080e7          	jalr	1772(ra) # 80000b52 <initlock>

  uartinit();
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	330080e7          	jalr	816(ra) # 8000079e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000476:	00023797          	auipc	a5,0x23
    8000047a:	8e278793          	addi	a5,a5,-1822 # 80022d58 <devsw>
    8000047e:	00000717          	auipc	a4,0x0
    80000482:	ce470713          	addi	a4,a4,-796 # 80000162 <consoleread>
    80000486:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000488:	00000717          	auipc	a4,0x0
    8000048c:	c7870713          	addi	a4,a4,-904 # 80000100 <consolewrite>
    80000490:	ef98                	sd	a4,24(a5)
}
    80000492:	60a2                	ld	ra,8(sp)
    80000494:	6402                	ld	s0,0(sp)
    80000496:	0141                	addi	sp,sp,16
    80000498:	8082                	ret

000000008000049a <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049a:	7179                	addi	sp,sp,-48
    8000049c:	f406                	sd	ra,40(sp)
    8000049e:	f022                	sd	s0,32(sp)
    800004a0:	ec26                	sd	s1,24(sp)
    800004a2:	e84a                	sd	s2,16(sp)
    800004a4:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a6:	c219                	beqz	a2,800004ac <printint+0x12>
    800004a8:	08054663          	bltz	a0,80000534 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ac:	2501                	sext.w	a0,a0
    800004ae:	4881                	li	a7,0
    800004b0:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b4:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b6:	2581                	sext.w	a1,a1
    800004b8:	00009617          	auipc	a2,0x9
    800004bc:	b8860613          	addi	a2,a2,-1144 # 80009040 <digits>
    800004c0:	883a                	mv	a6,a4
    800004c2:	2705                	addiw	a4,a4,1
    800004c4:	02b577bb          	remuw	a5,a0,a1
    800004c8:	1782                	slli	a5,a5,0x20
    800004ca:	9381                	srli	a5,a5,0x20
    800004cc:	97b2                	add	a5,a5,a2
    800004ce:	0007c783          	lbu	a5,0(a5)
    800004d2:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d6:	0005079b          	sext.w	a5,a0
    800004da:	02b5553b          	divuw	a0,a0,a1
    800004de:	0685                	addi	a3,a3,1
    800004e0:	feb7f0e3          	bgeu	a5,a1,800004c0 <printint+0x26>

  if(sign)
    800004e4:	00088b63          	beqz	a7,800004fa <printint+0x60>
    buf[i++] = '-';
    800004e8:	fe040793          	addi	a5,s0,-32
    800004ec:	973e                	add	a4,a4,a5
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x8e>
    800004fe:	fd040793          	addi	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	addi	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addiw	a4,a4,-1
    8000050e:	1702                	slli	a4,a4,0x20
    80000510:	9301                	srli	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d60080e7          	jalr	-672(ra) # 8000027a <consputc>
  while(--i >= 0)
    80000522:	14fd                	addi	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7c>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	addi	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf9d                	j	800004b0 <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	addi	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	addi	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00012797          	auipc	a5,0x12
    8000054c:	d207ac23          	sw	zero,-712(a5) # 80012280 <pr+0x18>
  printf("panic: ");
    80000550:	00009517          	auipc	a0,0x9
    80000554:	ac850513          	addi	a0,a0,-1336 # 80009018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00009517          	auipc	a0,0x9
    8000056e:	1de50513          	addi	a0,a0,478 # 80009748 <syscalls+0x108>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	0000a717          	auipc	a4,0xa
    80000580:	a8f72223          	sw	a5,-1404(a4) # 8000a000 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	addi	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	addi	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00012d97          	auipc	s11,0x12
    800005bc:	cc8dad83          	lw	s11,-824(s11) # 80012280 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	addi	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	16050263          	beqz	a0,80000738 <printf+0x1b2>
    800005d8:	4481                	li	s1,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b13          	li	s6,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00009b97          	auipc	s7,0x9
    800005e8:	a5cb8b93          	addi	s7,s7,-1444 # 80009040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00012517          	auipc	a0,0x12
    800005fa:	c7250513          	addi	a0,a0,-910 # 80012268 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5e4080e7          	jalr	1508(ra) # 80000be2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00009517          	auipc	a0,0x9
    8000060c:	a2050513          	addi	a0,a0,-1504 # 80009028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c62080e7          	jalr	-926(ra) # 8000027a <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2485                	addiw	s1,s1,1
    80000622:	009a07b3          	add	a5,s4,s1
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050763          	beqz	a0,80000738 <printf+0x1b2>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2485                	addiw	s1,s1,1
    80000634:	009a07b3          	add	a5,s4,s1
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000640:	cfe5                	beqz	a5,80000738 <printf+0x1b2>
    switch(c){
    80000642:	05678a63          	beq	a5,s6,80000696 <printf+0x110>
    80000646:	02fb7663          	bgeu	s6,a5,80000672 <printf+0xec>
    8000064a:	09978963          	beq	a5,s9,800006dc <printf+0x156>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79863          	bne	a5,a4,80000722 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	addi	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e32080e7          	jalr	-462(ra) # 8000049a <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	0b578263          	beq	a5,s5,80000716 <printf+0x190>
    80000676:	0b879663          	bne	a5,s8,80000722 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0e080e7          	jalr	-498(ra) # 8000049a <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bd0080e7          	jalr	-1072(ra) # 8000027a <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc4080e7          	jalr	-1084(ra) # 8000027a <consputc>
    800006be:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c9d793          	srli	a5,s3,0x3c
    800006c4:	97de                	add	a5,a5,s7
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bb0080e7          	jalr	-1104(ra) # 8000027a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0992                	slli	s3,s3,0x4
    800006d4:	397d                	addiw	s2,s2,-1
    800006d6:	fe0915e3          	bnez	s2,800006c0 <printf+0x13a>
    800006da:	b799                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	0007b903          	ld	s2,0(a5)
    800006ec:	00090e63          	beqz	s2,80000708 <printf+0x182>
      for(; *s; s++)
    800006f0:	00094503          	lbu	a0,0(s2)
    800006f4:	d515                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f6:	00000097          	auipc	ra,0x0
    800006fa:	b84080e7          	jalr	-1148(ra) # 8000027a <consputc>
      for(; *s; s++)
    800006fe:	0905                	addi	s2,s2,1
    80000700:	00094503          	lbu	a0,0(s2)
    80000704:	f96d                	bnez	a0,800006f6 <printf+0x170>
    80000706:	bf29                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000708:	00009917          	auipc	s2,0x9
    8000070c:	91890913          	addi	s2,s2,-1768 # 80009020 <etext+0x20>
      for(; *s; s++)
    80000710:	02800513          	li	a0,40
    80000714:	b7cd                	j	800006f6 <printf+0x170>
      consputc('%');
    80000716:	8556                	mv	a0,s5
    80000718:	00000097          	auipc	ra,0x0
    8000071c:	b62080e7          	jalr	-1182(ra) # 8000027a <consputc>
      break;
    80000720:	b701                	j	80000620 <printf+0x9a>
      consputc('%');
    80000722:	8556                	mv	a0,s5
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b56080e7          	jalr	-1194(ra) # 8000027a <consputc>
      consputc(c);
    8000072c:	854a                	mv	a0,s2
    8000072e:	00000097          	auipc	ra,0x0
    80000732:	b4c080e7          	jalr	-1204(ra) # 8000027a <consputc>
      break;
    80000736:	b5ed                	j	80000620 <printf+0x9a>
  if(locking)
    80000738:	020d9163          	bnez	s11,8000075a <printf+0x1d4>
}
    8000073c:	70e6                	ld	ra,120(sp)
    8000073e:	7446                	ld	s0,112(sp)
    80000740:	74a6                	ld	s1,104(sp)
    80000742:	7906                	ld	s2,96(sp)
    80000744:	69e6                	ld	s3,88(sp)
    80000746:	6a46                	ld	s4,80(sp)
    80000748:	6aa6                	ld	s5,72(sp)
    8000074a:	6b06                	ld	s6,64(sp)
    8000074c:	7be2                	ld	s7,56(sp)
    8000074e:	7c42                	ld	s8,48(sp)
    80000750:	7ca2                	ld	s9,40(sp)
    80000752:	7d02                	ld	s10,32(sp)
    80000754:	6de2                	ld	s11,24(sp)
    80000756:	6129                	addi	sp,sp,192
    80000758:	8082                	ret
    release(&pr.lock);
    8000075a:	00012517          	auipc	a0,0x12
    8000075e:	b0e50513          	addi	a0,a0,-1266 # 80012268 <pr>
    80000762:	00000097          	auipc	ra,0x0
    80000766:	534080e7          	jalr	1332(ra) # 80000c96 <release>
}
    8000076a:	bfc9                	j	8000073c <printf+0x1b6>

000000008000076c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076c:	1101                	addi	sp,sp,-32
    8000076e:	ec06                	sd	ra,24(sp)
    80000770:	e822                	sd	s0,16(sp)
    80000772:	e426                	sd	s1,8(sp)
    80000774:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000776:	00012497          	auipc	s1,0x12
    8000077a:	af248493          	addi	s1,s1,-1294 # 80012268 <pr>
    8000077e:	00009597          	auipc	a1,0x9
    80000782:	8ba58593          	addi	a1,a1,-1862 # 80009038 <etext+0x38>
    80000786:	8526                	mv	a0,s1
    80000788:	00000097          	auipc	ra,0x0
    8000078c:	3ca080e7          	jalr	970(ra) # 80000b52 <initlock>
  pr.locking = 1;
    80000790:	4785                	li	a5,1
    80000792:	cc9c                	sw	a5,24(s1)
}
    80000794:	60e2                	ld	ra,24(sp)
    80000796:	6442                	ld	s0,16(sp)
    80000798:	64a2                	ld	s1,8(sp)
    8000079a:	6105                	addi	sp,sp,32
    8000079c:	8082                	ret

000000008000079e <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079e:	1141                	addi	sp,sp,-16
    800007a0:	e406                	sd	ra,8(sp)
    800007a2:	e022                	sd	s0,0(sp)
    800007a4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a6:	100007b7          	lui	a5,0x10000
    800007aa:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ae:	f8000713          	li	a4,-128
    800007b2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b6:	470d                	li	a4,3
    800007b8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007bc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c4:	469d                	li	a3,7
    800007c6:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007ca:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ce:	00009597          	auipc	a1,0x9
    800007d2:	88a58593          	addi	a1,a1,-1910 # 80009058 <digits+0x18>
    800007d6:	00012517          	auipc	a0,0x12
    800007da:	ab250513          	addi	a0,a0,-1358 # 80012288 <uart_tx_lock>
    800007de:	00000097          	auipc	ra,0x0
    800007e2:	374080e7          	jalr	884(ra) # 80000b52 <initlock>
}
    800007e6:	60a2                	ld	ra,8(sp)
    800007e8:	6402                	ld	s0,0(sp)
    800007ea:	0141                	addi	sp,sp,16
    800007ec:	8082                	ret

00000000800007ee <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ee:	1101                	addi	sp,sp,-32
    800007f0:	ec06                	sd	ra,24(sp)
    800007f2:	e822                	sd	s0,16(sp)
    800007f4:	e426                	sd	s1,8(sp)
    800007f6:	1000                	addi	s0,sp,32
    800007f8:	84aa                	mv	s1,a0
  push_off();
    800007fa:	00000097          	auipc	ra,0x0
    800007fe:	39c080e7          	jalr	924(ra) # 80000b96 <push_off>

  if(panicked){
    80000802:	00009797          	auipc	a5,0x9
    80000806:	7fe7a783          	lw	a5,2046(a5) # 8000a000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080e:	c391                	beqz	a5,80000812 <uartputc_sync+0x24>
    for(;;)
    80000810:	a001                	j	80000810 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000812:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000816:	0ff7f793          	andi	a5,a5,255
    8000081a:	0207f793          	andi	a5,a5,32
    8000081e:	dbf5                	beqz	a5,80000812 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000820:	0ff4f793          	andi	a5,s1,255
    80000824:	10000737          	lui	a4,0x10000
    80000828:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000082c:	00000097          	auipc	ra,0x0
    80000830:	40a080e7          	jalr	1034(ra) # 80000c36 <pop_off>
}
    80000834:	60e2                	ld	ra,24(sp)
    80000836:	6442                	ld	s0,16(sp)
    80000838:	64a2                	ld	s1,8(sp)
    8000083a:	6105                	addi	sp,sp,32
    8000083c:	8082                	ret

000000008000083e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000083e:	00009717          	auipc	a4,0x9
    80000842:	7ca73703          	ld	a4,1994(a4) # 8000a008 <uart_tx_r>
    80000846:	00009797          	auipc	a5,0x9
    8000084a:	7ca7b783          	ld	a5,1994(a5) # 8000a010 <uart_tx_w>
    8000084e:	06e78c63          	beq	a5,a4,800008c6 <uartstart+0x88>
{
    80000852:	7139                	addi	sp,sp,-64
    80000854:	fc06                	sd	ra,56(sp)
    80000856:	f822                	sd	s0,48(sp)
    80000858:	f426                	sd	s1,40(sp)
    8000085a:	f04a                	sd	s2,32(sp)
    8000085c:	ec4e                	sd	s3,24(sp)
    8000085e:	e852                	sd	s4,16(sp)
    80000860:	e456                	sd	s5,8(sp)
    80000862:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000864:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000868:	00012a17          	auipc	s4,0x12
    8000086c:	a20a0a13          	addi	s4,s4,-1504 # 80012288 <uart_tx_lock>
    uart_tx_r += 1;
    80000870:	00009497          	auipc	s1,0x9
    80000874:	79848493          	addi	s1,s1,1944 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000878:	00009997          	auipc	s3,0x9
    8000087c:	79898993          	addi	s3,s3,1944 # 8000a010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000880:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000884:	0ff7f793          	andi	a5,a5,255
    80000888:	0207f793          	andi	a5,a5,32
    8000088c:	c785                	beqz	a5,800008b4 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000088e:	01f77793          	andi	a5,a4,31
    80000892:	97d2                	add	a5,a5,s4
    80000894:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    80000898:	0705                	addi	a4,a4,1
    8000089a:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000089c:	8526                	mv	a0,s1
    8000089e:	00002097          	auipc	ra,0x2
    800008a2:	2fa080e7          	jalr	762(ra) # 80002b98 <wakeup>
    
    WriteReg(THR, c);
    800008a6:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008aa:	6098                	ld	a4,0(s1)
    800008ac:	0009b783          	ld	a5,0(s3)
    800008b0:	fce798e3          	bne	a5,a4,80000880 <uartstart+0x42>
  }
}
    800008b4:	70e2                	ld	ra,56(sp)
    800008b6:	7442                	ld	s0,48(sp)
    800008b8:	74a2                	ld	s1,40(sp)
    800008ba:	7902                	ld	s2,32(sp)
    800008bc:	69e2                	ld	s3,24(sp)
    800008be:	6a42                	ld	s4,16(sp)
    800008c0:	6aa2                	ld	s5,8(sp)
    800008c2:	6121                	addi	sp,sp,64
    800008c4:	8082                	ret
    800008c6:	8082                	ret

00000000800008c8 <uartputc>:
{
    800008c8:	7179                	addi	sp,sp,-48
    800008ca:	f406                	sd	ra,40(sp)
    800008cc:	f022                	sd	s0,32(sp)
    800008ce:	ec26                	sd	s1,24(sp)
    800008d0:	e84a                	sd	s2,16(sp)
    800008d2:	e44e                	sd	s3,8(sp)
    800008d4:	e052                	sd	s4,0(sp)
    800008d6:	1800                	addi	s0,sp,48
    800008d8:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008da:	00012517          	auipc	a0,0x12
    800008de:	9ae50513          	addi	a0,a0,-1618 # 80012288 <uart_tx_lock>
    800008e2:	00000097          	auipc	ra,0x0
    800008e6:	300080e7          	jalr	768(ra) # 80000be2 <acquire>
  if(panicked){
    800008ea:	00009797          	auipc	a5,0x9
    800008ee:	7167a783          	lw	a5,1814(a5) # 8000a000 <panicked>
    800008f2:	c391                	beqz	a5,800008f6 <uartputc+0x2e>
    for(;;)
    800008f4:	a001                	j	800008f4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008f6:	00009797          	auipc	a5,0x9
    800008fa:	71a7b783          	ld	a5,1818(a5) # 8000a010 <uart_tx_w>
    800008fe:	00009717          	auipc	a4,0x9
    80000902:	70a73703          	ld	a4,1802(a4) # 8000a008 <uart_tx_r>
    80000906:	02070713          	addi	a4,a4,32
    8000090a:	02f71b63          	bne	a4,a5,80000940 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000090e:	00012a17          	auipc	s4,0x12
    80000912:	97aa0a13          	addi	s4,s4,-1670 # 80012288 <uart_tx_lock>
    80000916:	00009497          	auipc	s1,0x9
    8000091a:	6f248493          	addi	s1,s1,1778 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000091e:	00009917          	auipc	s2,0x9
    80000922:	6f290913          	addi	s2,s2,1778 # 8000a010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000926:	85d2                	mv	a1,s4
    80000928:	8526                	mv	a0,s1
    8000092a:	00002097          	auipc	ra,0x2
    8000092e:	dcc080e7          	jalr	-564(ra) # 800026f6 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000932:	00093783          	ld	a5,0(s2)
    80000936:	6098                	ld	a4,0(s1)
    80000938:	02070713          	addi	a4,a4,32
    8000093c:	fef705e3          	beq	a4,a5,80000926 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000940:	00012497          	auipc	s1,0x12
    80000944:	94848493          	addi	s1,s1,-1720 # 80012288 <uart_tx_lock>
    80000948:	01f7f713          	andi	a4,a5,31
    8000094c:	9726                	add	a4,a4,s1
    8000094e:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    80000952:	0785                	addi	a5,a5,1
    80000954:	00009717          	auipc	a4,0x9
    80000958:	6af73e23          	sd	a5,1724(a4) # 8000a010 <uart_tx_w>
      uartstart();
    8000095c:	00000097          	auipc	ra,0x0
    80000960:	ee2080e7          	jalr	-286(ra) # 8000083e <uartstart>
      release(&uart_tx_lock);
    80000964:	8526                	mv	a0,s1
    80000966:	00000097          	auipc	ra,0x0
    8000096a:	330080e7          	jalr	816(ra) # 80000c96 <release>
}
    8000096e:	70a2                	ld	ra,40(sp)
    80000970:	7402                	ld	s0,32(sp)
    80000972:	64e2                	ld	s1,24(sp)
    80000974:	6942                	ld	s2,16(sp)
    80000976:	69a2                	ld	s3,8(sp)
    80000978:	6a02                	ld	s4,0(sp)
    8000097a:	6145                	addi	sp,sp,48
    8000097c:	8082                	ret

000000008000097e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000097e:	1141                	addi	sp,sp,-16
    80000980:	e422                	sd	s0,8(sp)
    80000982:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000098c:	8b85                	andi	a5,a5,1
    8000098e:	cb91                	beqz	a5,800009a2 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000998:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000099c:	6422                	ld	s0,8(sp)
    8000099e:	0141                	addi	sp,sp,16
    800009a0:	8082                	ret
    return -1;
    800009a2:	557d                	li	a0,-1
    800009a4:	bfe5                	j	8000099c <uartgetc+0x1e>

00000000800009a6 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009a6:	1101                	addi	sp,sp,-32
    800009a8:	ec06                	sd	ra,24(sp)
    800009aa:	e822                	sd	s0,16(sp)
    800009ac:	e426                	sd	s1,8(sp)
    800009ae:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b0:	54fd                	li	s1,-1
    int c = uartgetc();
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	fcc080e7          	jalr	-52(ra) # 8000097e <uartgetc>
    if(c == -1)
    800009ba:	00950763          	beq	a0,s1,800009c8 <uartintr+0x22>
      break;
    consoleintr(c);
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	8fe080e7          	jalr	-1794(ra) # 800002bc <consoleintr>
  while(1){
    800009c6:	b7f5                	j	800009b2 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009c8:	00012497          	auipc	s1,0x12
    800009cc:	8c048493          	addi	s1,s1,-1856 # 80012288 <uart_tx_lock>
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	210080e7          	jalr	528(ra) # 80000be2 <acquire>
  uartstart();
    800009da:	00000097          	auipc	ra,0x0
    800009de:	e64080e7          	jalr	-412(ra) # 8000083e <uartstart>
  release(&uart_tx_lock);
    800009e2:	8526                	mv	a0,s1
    800009e4:	00000097          	auipc	ra,0x0
    800009e8:	2b2080e7          	jalr	690(ra) # 80000c96 <release>
}
    800009ec:	60e2                	ld	ra,24(sp)
    800009ee:	6442                	ld	s0,16(sp)
    800009f0:	64a2                	ld	s1,8(sp)
    800009f2:	6105                	addi	sp,sp,32
    800009f4:	8082                	ret

00000000800009f6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009f6:	1101                	addi	sp,sp,-32
    800009f8:	ec06                	sd	ra,24(sp)
    800009fa:	e822                	sd	s0,16(sp)
    800009fc:	e426                	sd	s1,8(sp)
    800009fe:	e04a                	sd	s2,0(sp)
    80000a00:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a02:	03451793          	slli	a5,a0,0x34
    80000a06:	ebb9                	bnez	a5,80000a5c <kfree+0x66>
    80000a08:	84aa                	mv	s1,a0
    80000a0a:	00026797          	auipc	a5,0x26
    80000a0e:	5f678793          	addi	a5,a5,1526 # 80027000 <end>
    80000a12:	04f56563          	bltu	a0,a5,80000a5c <kfree+0x66>
    80000a16:	47c5                	li	a5,17
    80000a18:	07ee                	slli	a5,a5,0x1b
    80000a1a:	04f57163          	bgeu	a0,a5,80000a5c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a1e:	6605                	lui	a2,0x1
    80000a20:	4585                	li	a1,1
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	2bc080e7          	jalr	700(ra) # 80000cde <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a2a:	00012917          	auipc	s2,0x12
    80000a2e:	89690913          	addi	s2,s2,-1898 # 800122c0 <kmem>
    80000a32:	854a                	mv	a0,s2
    80000a34:	00000097          	auipc	ra,0x0
    80000a38:	1ae080e7          	jalr	430(ra) # 80000be2 <acquire>
  r->next = kmem.freelist;
    80000a3c:	01893783          	ld	a5,24(s2)
    80000a40:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a42:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a46:	854a                	mv	a0,s2
    80000a48:	00000097          	auipc	ra,0x0
    80000a4c:	24e080e7          	jalr	590(ra) # 80000c96 <release>
}
    80000a50:	60e2                	ld	ra,24(sp)
    80000a52:	6442                	ld	s0,16(sp)
    80000a54:	64a2                	ld	s1,8(sp)
    80000a56:	6902                	ld	s2,0(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret
    panic("kfree");
    80000a5c:	00008517          	auipc	a0,0x8
    80000a60:	60450513          	addi	a0,a0,1540 # 80009060 <digits+0x20>
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	ad8080e7          	jalr	-1320(ra) # 8000053c <panic>

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
    80000a9c:	f5e080e7          	jalr	-162(ra) # 800009f6 <kfree>
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
    80000abe:	00008597          	auipc	a1,0x8
    80000ac2:	5aa58593          	addi	a1,a1,1450 # 80009068 <digits+0x28>
    80000ac6:	00011517          	auipc	a0,0x11
    80000aca:	7fa50513          	addi	a0,a0,2042 # 800122c0 <kmem>
    80000ace:	00000097          	auipc	ra,0x0
    80000ad2:	084080e7          	jalr	132(ra) # 80000b52 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ad6:	45c5                	li	a1,17
    80000ad8:	05ee                	slli	a1,a1,0x1b
    80000ada:	00026517          	auipc	a0,0x26
    80000ade:	52650513          	addi	a0,a0,1318 # 80027000 <end>
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
    80000afc:	00011497          	auipc	s1,0x11
    80000b00:	7c448493          	addi	s1,s1,1988 # 800122c0 <kmem>
    80000b04:	8526                	mv	a0,s1
    80000b06:	00000097          	auipc	ra,0x0
    80000b0a:	0dc080e7          	jalr	220(ra) # 80000be2 <acquire>
  r = kmem.freelist;
    80000b0e:	6c84                	ld	s1,24(s1)
  if(r)
    80000b10:	c885                	beqz	s1,80000b40 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b12:	609c                	ld	a5,0(s1)
    80000b14:	00011517          	auipc	a0,0x11
    80000b18:	7ac50513          	addi	a0,a0,1964 # 800122c0 <kmem>
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
    80000b40:	00011517          	auipc	a0,0x11
    80000b44:	78050513          	addi	a0,a0,1920 # 800122c0 <kmem>
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
    80000b80:	e16080e7          	jalr	-490(ra) # 80001992 <mycpu>
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
    80000bb2:	de4080e7          	jalr	-540(ra) # 80001992 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	cf89                	beqz	a5,80000bd2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bba:	00001097          	auipc	ra,0x1
    80000bbe:	dd8080e7          	jalr	-552(ra) # 80001992 <mycpu>
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
    80000bd6:	dc0080e7          	jalr	-576(ra) # 80001992 <mycpu>
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
    80000c16:	d80080e7          	jalr	-640(ra) # 80001992 <mycpu>
    80000c1a:	e888                	sd	a0,16(s1)
}
    80000c1c:	60e2                	ld	ra,24(sp)
    80000c1e:	6442                	ld	s0,16(sp)
    80000c20:	64a2                	ld	s1,8(sp)
    80000c22:	6105                	addi	sp,sp,32
    80000c24:	8082                	ret
    panic("acquire");
    80000c26:	00008517          	auipc	a0,0x8
    80000c2a:	44a50513          	addi	a0,a0,1098 # 80009070 <digits+0x30>
    80000c2e:	00000097          	auipc	ra,0x0
    80000c32:	90e080e7          	jalr	-1778(ra) # 8000053c <panic>

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
    80000c42:	d54080e7          	jalr	-684(ra) # 80001992 <mycpu>
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
    80000c76:	00008517          	auipc	a0,0x8
    80000c7a:	40250513          	addi	a0,a0,1026 # 80009078 <digits+0x38>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>
    panic("pop_off");
    80000c86:	00008517          	auipc	a0,0x8
    80000c8a:	40a50513          	addi	a0,a0,1034 # 80009090 <digits+0x50>
    80000c8e:	00000097          	auipc	ra,0x0
    80000c92:	8ae080e7          	jalr	-1874(ra) # 8000053c <panic>

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
    80000cce:	00008517          	auipc	a0,0x8
    80000cd2:	3ca50513          	addi	a0,a0,970 # 80009098 <digits+0x58>
    80000cd6:	00000097          	auipc	ra,0x0
    80000cda:	866080e7          	jalr	-1946(ra) # 8000053c <panic>

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
    80000ce4:	ce09                	beqz	a2,80000cfe <memset+0x20>
    80000ce6:	87aa                	mv	a5,a0
    80000ce8:	fff6071b          	addiw	a4,a2,-1
    80000cec:	1702                	slli	a4,a4,0x20
    80000cee:	9301                	srli	a4,a4,0x20
    80000cf0:	0705                	addi	a4,a4,1
    80000cf2:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000cf4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cf8:	0785                	addi	a5,a5,1
    80000cfa:	fee79de3          	bne	a5,a4,80000cf4 <memset+0x16>
  }
  return dst;
}
    80000cfe:	6422                	ld	s0,8(sp)
    80000d00:	0141                	addi	sp,sp,16
    80000d02:	8082                	ret

0000000080000d04 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d04:	1141                	addi	sp,sp,-16
    80000d06:	e422                	sd	s0,8(sp)
    80000d08:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d0a:	ca05                	beqz	a2,80000d3a <memcmp+0x36>
    80000d0c:	fff6069b          	addiw	a3,a2,-1
    80000d10:	1682                	slli	a3,a3,0x20
    80000d12:	9281                	srli	a3,a3,0x20
    80000d14:	0685                	addi	a3,a3,1
    80000d16:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d18:	00054783          	lbu	a5,0(a0)
    80000d1c:	0005c703          	lbu	a4,0(a1)
    80000d20:	00e79863          	bne	a5,a4,80000d30 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d24:	0505                	addi	a0,a0,1
    80000d26:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d28:	fed518e3          	bne	a0,a3,80000d18 <memcmp+0x14>
  }

  return 0;
    80000d2c:	4501                	li	a0,0
    80000d2e:	a019                	j	80000d34 <memcmp+0x30>
      return *s1 - *s2;
    80000d30:	40e7853b          	subw	a0,a5,a4
}
    80000d34:	6422                	ld	s0,8(sp)
    80000d36:	0141                	addi	sp,sp,16
    80000d38:	8082                	ret
  return 0;
    80000d3a:	4501                	li	a0,0
    80000d3c:	bfe5                	j	80000d34 <memcmp+0x30>

0000000080000d3e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d3e:	1141                	addi	sp,sp,-16
    80000d40:	e422                	sd	s0,8(sp)
    80000d42:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d44:	ca0d                	beqz	a2,80000d76 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d46:	00a5f963          	bgeu	a1,a0,80000d58 <memmove+0x1a>
    80000d4a:	02061693          	slli	a3,a2,0x20
    80000d4e:	9281                	srli	a3,a3,0x20
    80000d50:	00d58733          	add	a4,a1,a3
    80000d54:	02e56463          	bltu	a0,a4,80000d7c <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d58:	fff6079b          	addiw	a5,a2,-1
    80000d5c:	1782                	slli	a5,a5,0x20
    80000d5e:	9381                	srli	a5,a5,0x20
    80000d60:	0785                	addi	a5,a5,1
    80000d62:	97ae                	add	a5,a5,a1
    80000d64:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d66:	0585                	addi	a1,a1,1
    80000d68:	0705                	addi	a4,a4,1
    80000d6a:	fff5c683          	lbu	a3,-1(a1)
    80000d6e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d72:	fef59ae3          	bne	a1,a5,80000d66 <memmove+0x28>

  return dst;
}
    80000d76:	6422                	ld	s0,8(sp)
    80000d78:	0141                	addi	sp,sp,16
    80000d7a:	8082                	ret
    d += n;
    80000d7c:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d7e:	fff6079b          	addiw	a5,a2,-1
    80000d82:	1782                	slli	a5,a5,0x20
    80000d84:	9381                	srli	a5,a5,0x20
    80000d86:	fff7c793          	not	a5,a5
    80000d8a:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d8c:	177d                	addi	a4,a4,-1
    80000d8e:	16fd                	addi	a3,a3,-1
    80000d90:	00074603          	lbu	a2,0(a4)
    80000d94:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d98:	fef71ae3          	bne	a4,a5,80000d8c <memmove+0x4e>
    80000d9c:	bfe9                	j	80000d76 <memmove+0x38>

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
    80000daa:	f98080e7          	jalr	-104(ra) # 80000d3e <memmove>
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
    80000e10:	00c05d63          	blez	a2,80000e2a <strncpy+0x38>
    80000e14:	86ba                	mv	a3,a4
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
int SCHED_POLICY = SCHED_PREEMPT_RR;
int OLD_POLICY = SCHED_PREEMPT_RR;
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
    80000e98:	aee080e7          	jalr	-1298(ra) # 80001982 <cpuid>
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
    
  } else {
    while(started == 0)
    80000e9c:	00009717          	auipc	a4,0x9
    80000ea0:	17c70713          	addi	a4,a4,380 # 8000a018 <started>
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
    80000eb4:	ad2080e7          	jalr	-1326(ra) # 80001982 <cpuid>
    80000eb8:	85aa                	mv	a1,a0
    80000eba:	00008517          	auipc	a0,0x8
    80000ebe:	1fe50513          	addi	a0,a0,510 # 800090b8 <digits+0x78>
    80000ec2:	fffff097          	auipc	ra,0xfffff
    80000ec6:	6c4080e7          	jalr	1732(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eca:	00000097          	auipc	ra,0x0
    80000ece:	0d8080e7          	jalr	216(ra) # 80000fa2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ed2:	00002097          	auipc	ra,0x2
    80000ed6:	712080e7          	jalr	1810(ra) # 800035e4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eda:	00006097          	auipc	ra,0x6
    80000ede:	e96080e7          	jalr	-362(ra) # 80006d70 <plicinithart>
  }
  
  scheduler();        
    80000ee2:	00001097          	auipc	ra,0x1
    80000ee6:	318080e7          	jalr	792(ra) # 800021fa <scheduler>
    consoleinit();
    80000eea:	fffff097          	auipc	ra,0xfffff
    80000eee:	564080e7          	jalr	1380(ra) # 8000044e <consoleinit>
    printfinit();
    80000ef2:	00000097          	auipc	ra,0x0
    80000ef6:	87a080e7          	jalr	-1926(ra) # 8000076c <printfinit>
    printf("\n");
    80000efa:	00009517          	auipc	a0,0x9
    80000efe:	84e50513          	addi	a0,a0,-1970 # 80009748 <syscalls+0x108>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	684080e7          	jalr	1668(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000f0a:	00008517          	auipc	a0,0x8
    80000f0e:	19650513          	addi	a0,a0,406 # 800090a0 <digits+0x60>
    80000f12:	fffff097          	auipc	ra,0xfffff
    80000f16:	674080e7          	jalr	1652(ra) # 80000586 <printf>
    printf("\n");
    80000f1a:	00009517          	auipc	a0,0x9
    80000f1e:	82e50513          	addi	a0,a0,-2002 # 80009748 <syscalls+0x108>
    80000f22:	fffff097          	auipc	ra,0xfffff
    80000f26:	664080e7          	jalr	1636(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f2a:	00000097          	auipc	ra,0x0
    80000f2e:	b8c080e7          	jalr	-1140(ra) # 80000ab6 <kinit>
    kvminit();       // create kernel page table
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	322080e7          	jalr	802(ra) # 80001254 <kvminit>
    kvminithart();   // turn on paging
    80000f3a:	00000097          	auipc	ra,0x0
    80000f3e:	068080e7          	jalr	104(ra) # 80000fa2 <kvminithart>
    procinit();      // process table
    80000f42:	00001097          	auipc	ra,0x1
    80000f46:	990080e7          	jalr	-1648(ra) # 800018d2 <procinit>
    trapinit();      // trap vectors
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	672080e7          	jalr	1650(ra) # 800035bc <trapinit>
    trapinithart();  // install kernel trap vector
    80000f52:	00002097          	auipc	ra,0x2
    80000f56:	692080e7          	jalr	1682(ra) # 800035e4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f5a:	00006097          	auipc	ra,0x6
    80000f5e:	e00080e7          	jalr	-512(ra) # 80006d5a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	e0e080e7          	jalr	-498(ra) # 80006d70 <plicinithart>
    binit();         // buffer cache
    80000f6a:	00003097          	auipc	ra,0x3
    80000f6e:	fec080e7          	jalr	-20(ra) # 80003f56 <binit>
    iinit();         // inode table
    80000f72:	00003097          	auipc	ra,0x3
    80000f76:	67c080e7          	jalr	1660(ra) # 800045ee <iinit>
    fileinit();      // file table
    80000f7a:	00004097          	auipc	ra,0x4
    80000f7e:	626080e7          	jalr	1574(ra) # 800055a0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f82:	00006097          	auipc	ra,0x6
    80000f86:	f10080e7          	jalr	-240(ra) # 80006e92 <virtio_disk_init>
    userinit();      // first user process
    80000f8a:	00001097          	auipc	ra,0x1
    80000f8e:	d86080e7          	jalr	-634(ra) # 80001d10 <userinit>
    __sync_synchronize();
    80000f92:	0ff0000f          	fence
    started = 1;
    80000f96:	4785                	li	a5,1
    80000f98:	00009717          	auipc	a4,0x9
    80000f9c:	08f72023          	sw	a5,128(a4) # 8000a018 <started>
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
    80000fa8:	00009797          	auipc	a5,0x9
    80000fac:	0787b783          	ld	a5,120(a5) # 8000a020 <kernel_pagetable>
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
    80000fec:	00008517          	auipc	a0,0x8
    80000ff0:	0e450513          	addi	a0,a0,228 # 800090d0 <digits+0x90>
    80000ff4:	fffff097          	auipc	ra,0xfffff
    80000ff8:	548080e7          	jalr	1352(ra) # 8000053c <panic>
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
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010c4:	c205                	beqz	a2,800010e4 <mappages+0x36>
    800010c6:	8aaa                	mv	s5,a0
    800010c8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ca:	77fd                	lui	a5,0xfffff
    800010cc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010d0:	15fd                	addi	a1,a1,-1
    800010d2:	00c589b3          	add	s3,a1,a2
    800010d6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010da:	8952                	mv	s2,s4
    800010dc:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010e0:	6b85                	lui	s7,0x1
    800010e2:	a015                	j	80001106 <mappages+0x58>
    panic("mappages: size");
    800010e4:	00008517          	auipc	a0,0x8
    800010e8:	ff450513          	addi	a0,a0,-12 # 800090d8 <digits+0x98>
    800010ec:	fffff097          	auipc	ra,0xfffff
    800010f0:	450080e7          	jalr	1104(ra) # 8000053c <panic>
      panic("mappages: remap");
    800010f4:	00008517          	auipc	a0,0x8
    800010f8:	ff450513          	addi	a0,a0,-12 # 800090e8 <digits+0xa8>
    800010fc:	fffff097          	auipc	ra,0xfffff
    80001100:	440080e7          	jalr	1088(ra) # 8000053c <panic>
    a += PGSIZE;
    80001104:	995e                	add	s2,s2,s7
  for(;;){
    80001106:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000110a:	4605                	li	a2,1
    8000110c:	85ca                	mv	a1,s2
    8000110e:	8556                	mv	a0,s5
    80001110:	00000097          	auipc	ra,0x0
    80001114:	eb6080e7          	jalr	-330(ra) # 80000fc6 <walk>
    80001118:	cd19                	beqz	a0,80001136 <mappages+0x88>
    if(*pte & PTE_V)
    8000111a:	611c                	ld	a5,0(a0)
    8000111c:	8b85                	andi	a5,a5,1
    8000111e:	fbf9                	bnez	a5,800010f4 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001120:	80b1                	srli	s1,s1,0xc
    80001122:	04aa                	slli	s1,s1,0xa
    80001124:	0164e4b3          	or	s1,s1,s6
    80001128:	0014e493          	ori	s1,s1,1
    8000112c:	e104                	sd	s1,0(a0)
    if(a == last)
    8000112e:	fd391be3          	bne	s2,s3,80001104 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    80001132:	4501                	li	a0,0
    80001134:	a011                	j	80001138 <mappages+0x8a>
      return -1;
    80001136:	557d                	li	a0,-1
}
    80001138:	60a6                	ld	ra,72(sp)
    8000113a:	6406                	ld	s0,64(sp)
    8000113c:	74e2                	ld	s1,56(sp)
    8000113e:	7942                	ld	s2,48(sp)
    80001140:	79a2                	ld	s3,40(sp)
    80001142:	7a02                	ld	s4,32(sp)
    80001144:	6ae2                	ld	s5,24(sp)
    80001146:	6b42                	ld	s6,16(sp)
    80001148:	6ba2                	ld	s7,8(sp)
    8000114a:	6161                	addi	sp,sp,80
    8000114c:	8082                	ret

000000008000114e <kvmmap>:
{
    8000114e:	1141                	addi	sp,sp,-16
    80001150:	e406                	sd	ra,8(sp)
    80001152:	e022                	sd	s0,0(sp)
    80001154:	0800                	addi	s0,sp,16
    80001156:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001158:	86b2                	mv	a3,a2
    8000115a:	863e                	mv	a2,a5
    8000115c:	00000097          	auipc	ra,0x0
    80001160:	f52080e7          	jalr	-174(ra) # 800010ae <mappages>
    80001164:	e509                	bnez	a0,8000116e <kvmmap+0x20>
}
    80001166:	60a2                	ld	ra,8(sp)
    80001168:	6402                	ld	s0,0(sp)
    8000116a:	0141                	addi	sp,sp,16
    8000116c:	8082                	ret
    panic("kvmmap");
    8000116e:	00008517          	auipc	a0,0x8
    80001172:	f8a50513          	addi	a0,a0,-118 # 800090f8 <digits+0xb8>
    80001176:	fffff097          	auipc	ra,0xfffff
    8000117a:	3c6080e7          	jalr	966(ra) # 8000053c <panic>

000000008000117e <kvmmake>:
{
    8000117e:	1101                	addi	sp,sp,-32
    80001180:	ec06                	sd	ra,24(sp)
    80001182:	e822                	sd	s0,16(sp)
    80001184:	e426                	sd	s1,8(sp)
    80001186:	e04a                	sd	s2,0(sp)
    80001188:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000118a:	00000097          	auipc	ra,0x0
    8000118e:	968080e7          	jalr	-1688(ra) # 80000af2 <kalloc>
    80001192:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001194:	6605                	lui	a2,0x1
    80001196:	4581                	li	a1,0
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	b46080e7          	jalr	-1210(ra) # 80000cde <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10000637          	lui	a2,0x10000
    800011a8:	100005b7          	lui	a1,0x10000
    800011ac:	8526                	mv	a0,s1
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	fa0080e7          	jalr	-96(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011b6:	4719                	li	a4,6
    800011b8:	6685                	lui	a3,0x1
    800011ba:	10001637          	lui	a2,0x10001
    800011be:	100015b7          	lui	a1,0x10001
    800011c2:	8526                	mv	a0,s1
    800011c4:	00000097          	auipc	ra,0x0
    800011c8:	f8a080e7          	jalr	-118(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011cc:	4719                	li	a4,6
    800011ce:	004006b7          	lui	a3,0x400
    800011d2:	0c000637          	lui	a2,0xc000
    800011d6:	0c0005b7          	lui	a1,0xc000
    800011da:	8526                	mv	a0,s1
    800011dc:	00000097          	auipc	ra,0x0
    800011e0:	f72080e7          	jalr	-142(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011e4:	00008917          	auipc	s2,0x8
    800011e8:	e1c90913          	addi	s2,s2,-484 # 80009000 <etext>
    800011ec:	4729                	li	a4,10
    800011ee:	80008697          	auipc	a3,0x80008
    800011f2:	e1268693          	addi	a3,a3,-494 # 9000 <_entry-0x7fff7000>
    800011f6:	4605                	li	a2,1
    800011f8:	067e                	slli	a2,a2,0x1f
    800011fa:	85b2                	mv	a1,a2
    800011fc:	8526                	mv	a0,s1
    800011fe:	00000097          	auipc	ra,0x0
    80001202:	f50080e7          	jalr	-176(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001206:	4719                	li	a4,6
    80001208:	46c5                	li	a3,17
    8000120a:	06ee                	slli	a3,a3,0x1b
    8000120c:	412686b3          	sub	a3,a3,s2
    80001210:	864a                	mv	a2,s2
    80001212:	85ca                	mv	a1,s2
    80001214:	8526                	mv	a0,s1
    80001216:	00000097          	auipc	ra,0x0
    8000121a:	f38080e7          	jalr	-200(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000121e:	4729                	li	a4,10
    80001220:	6685                	lui	a3,0x1
    80001222:	00007617          	auipc	a2,0x7
    80001226:	dde60613          	addi	a2,a2,-546 # 80008000 <_trampoline>
    8000122a:	040005b7          	lui	a1,0x4000
    8000122e:	15fd                	addi	a1,a1,-1
    80001230:	05b2                	slli	a1,a1,0xc
    80001232:	8526                	mv	a0,s1
    80001234:	00000097          	auipc	ra,0x0
    80001238:	f1a080e7          	jalr	-230(ra) # 8000114e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000123c:	8526                	mv	a0,s1
    8000123e:	00000097          	auipc	ra,0x0
    80001242:	5fe080e7          	jalr	1534(ra) # 8000183c <proc_mapstacks>
}
    80001246:	8526                	mv	a0,s1
    80001248:	60e2                	ld	ra,24(sp)
    8000124a:	6442                	ld	s0,16(sp)
    8000124c:	64a2                	ld	s1,8(sp)
    8000124e:	6902                	ld	s2,0(sp)
    80001250:	6105                	addi	sp,sp,32
    80001252:	8082                	ret

0000000080001254 <kvminit>:
{
    80001254:	1141                	addi	sp,sp,-16
    80001256:	e406                	sd	ra,8(sp)
    80001258:	e022                	sd	s0,0(sp)
    8000125a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000125c:	00000097          	auipc	ra,0x0
    80001260:	f22080e7          	jalr	-222(ra) # 8000117e <kvmmake>
    80001264:	00009797          	auipc	a5,0x9
    80001268:	daa7be23          	sd	a0,-580(a5) # 8000a020 <kernel_pagetable>
}
    8000126c:	60a2                	ld	ra,8(sp)
    8000126e:	6402                	ld	s0,0(sp)
    80001270:	0141                	addi	sp,sp,16
    80001272:	8082                	ret

0000000080001274 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001274:	715d                	addi	sp,sp,-80
    80001276:	e486                	sd	ra,72(sp)
    80001278:	e0a2                	sd	s0,64(sp)
    8000127a:	fc26                	sd	s1,56(sp)
    8000127c:	f84a                	sd	s2,48(sp)
    8000127e:	f44e                	sd	s3,40(sp)
    80001280:	f052                	sd	s4,32(sp)
    80001282:	ec56                	sd	s5,24(sp)
    80001284:	e85a                	sd	s6,16(sp)
    80001286:	e45e                	sd	s7,8(sp)
    80001288:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000128a:	03459793          	slli	a5,a1,0x34
    8000128e:	e795                	bnez	a5,800012ba <uvmunmap+0x46>
    80001290:	8a2a                	mv	s4,a0
    80001292:	892e                	mv	s2,a1
    80001294:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001296:	0632                	slli	a2,a2,0xc
    80001298:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000129c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000129e:	6b05                	lui	s6,0x1
    800012a0:	0735e863          	bltu	a1,s3,80001310 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012a4:	60a6                	ld	ra,72(sp)
    800012a6:	6406                	ld	s0,64(sp)
    800012a8:	74e2                	ld	s1,56(sp)
    800012aa:	7942                	ld	s2,48(sp)
    800012ac:	79a2                	ld	s3,40(sp)
    800012ae:	7a02                	ld	s4,32(sp)
    800012b0:	6ae2                	ld	s5,24(sp)
    800012b2:	6b42                	ld	s6,16(sp)
    800012b4:	6ba2                	ld	s7,8(sp)
    800012b6:	6161                	addi	sp,sp,80
    800012b8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012ba:	00008517          	auipc	a0,0x8
    800012be:	e4650513          	addi	a0,a0,-442 # 80009100 <digits+0xc0>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27a080e7          	jalr	634(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012ca:	00008517          	auipc	a0,0x8
    800012ce:	e4e50513          	addi	a0,a0,-434 # 80009118 <digits+0xd8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26a080e7          	jalr	618(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012da:	00008517          	auipc	a0,0x8
    800012de:	e4e50513          	addi	a0,a0,-434 # 80009128 <digits+0xe8>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25a080e7          	jalr	602(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012ea:	00008517          	auipc	a0,0x8
    800012ee:	e5650513          	addi	a0,a0,-426 # 80009140 <digits+0x100>
    800012f2:	fffff097          	auipc	ra,0xfffff
    800012f6:	24a080e7          	jalr	586(ra) # 8000053c <panic>
      uint64 pa = PTE2PA(*pte);
    800012fa:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012fc:	0532                	slli	a0,a0,0xc
    800012fe:	fffff097          	auipc	ra,0xfffff
    80001302:	6f8080e7          	jalr	1784(ra) # 800009f6 <kfree>
    *pte = 0;
    80001306:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130a:	995a                	add	s2,s2,s6
    8000130c:	f9397ce3          	bgeu	s2,s3,800012a4 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001310:	4601                	li	a2,0
    80001312:	85ca                	mv	a1,s2
    80001314:	8552                	mv	a0,s4
    80001316:	00000097          	auipc	ra,0x0
    8000131a:	cb0080e7          	jalr	-848(ra) # 80000fc6 <walk>
    8000131e:	84aa                	mv	s1,a0
    80001320:	d54d                	beqz	a0,800012ca <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001322:	6108                	ld	a0,0(a0)
    80001324:	00157793          	andi	a5,a0,1
    80001328:	dbcd                	beqz	a5,800012da <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000132a:	3ff57793          	andi	a5,a0,1023
    8000132e:	fb778ee3          	beq	a5,s7,800012ea <uvmunmap+0x76>
    if(do_free){
    80001332:	fc0a8ae3          	beqz	s5,80001306 <uvmunmap+0x92>
    80001336:	b7d1                	j	800012fa <uvmunmap+0x86>

0000000080001338 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001338:	1101                	addi	sp,sp,-32
    8000133a:	ec06                	sd	ra,24(sp)
    8000133c:	e822                	sd	s0,16(sp)
    8000133e:	e426                	sd	s1,8(sp)
    80001340:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001342:	fffff097          	auipc	ra,0xfffff
    80001346:	7b0080e7          	jalr	1968(ra) # 80000af2 <kalloc>
    8000134a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000134c:	c519                	beqz	a0,8000135a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000134e:	6605                	lui	a2,0x1
    80001350:	4581                	li	a1,0
    80001352:	00000097          	auipc	ra,0x0
    80001356:	98c080e7          	jalr	-1652(ra) # 80000cde <memset>
  return pagetable;
}
    8000135a:	8526                	mv	a0,s1
    8000135c:	60e2                	ld	ra,24(sp)
    8000135e:	6442                	ld	s0,16(sp)
    80001360:	64a2                	ld	s1,8(sp)
    80001362:	6105                	addi	sp,sp,32
    80001364:	8082                	ret

0000000080001366 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001366:	7179                	addi	sp,sp,-48
    80001368:	f406                	sd	ra,40(sp)
    8000136a:	f022                	sd	s0,32(sp)
    8000136c:	ec26                	sd	s1,24(sp)
    8000136e:	e84a                	sd	s2,16(sp)
    80001370:	e44e                	sd	s3,8(sp)
    80001372:	e052                	sd	s4,0(sp)
    80001374:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001376:	6785                	lui	a5,0x1
    80001378:	04f67863          	bgeu	a2,a5,800013c8 <uvminit+0x62>
    8000137c:	8a2a                	mv	s4,a0
    8000137e:	89ae                	mv	s3,a1
    80001380:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001382:	fffff097          	auipc	ra,0xfffff
    80001386:	770080e7          	jalr	1904(ra) # 80000af2 <kalloc>
    8000138a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	00000097          	auipc	ra,0x0
    80001394:	94e080e7          	jalr	-1714(ra) # 80000cde <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001398:	4779                	li	a4,30
    8000139a:	86ca                	mv	a3,s2
    8000139c:	6605                	lui	a2,0x1
    8000139e:	4581                	li	a1,0
    800013a0:	8552                	mv	a0,s4
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	d0c080e7          	jalr	-756(ra) # 800010ae <mappages>
  memmove(mem, src, sz);
    800013aa:	8626                	mv	a2,s1
    800013ac:	85ce                	mv	a1,s3
    800013ae:	854a                	mv	a0,s2
    800013b0:	00000097          	auipc	ra,0x0
    800013b4:	98e080e7          	jalr	-1650(ra) # 80000d3e <memmove>
}
    800013b8:	70a2                	ld	ra,40(sp)
    800013ba:	7402                	ld	s0,32(sp)
    800013bc:	64e2                	ld	s1,24(sp)
    800013be:	6942                	ld	s2,16(sp)
    800013c0:	69a2                	ld	s3,8(sp)
    800013c2:	6a02                	ld	s4,0(sp)
    800013c4:	6145                	addi	sp,sp,48
    800013c6:	8082                	ret
    panic("inituvm: more than a page");
    800013c8:	00008517          	auipc	a0,0x8
    800013cc:	d9050513          	addi	a0,a0,-624 # 80009158 <digits+0x118>
    800013d0:	fffff097          	auipc	ra,0xfffff
    800013d4:	16c080e7          	jalr	364(ra) # 8000053c <panic>

00000000800013d8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013d8:	1101                	addi	sp,sp,-32
    800013da:	ec06                	sd	ra,24(sp)
    800013dc:	e822                	sd	s0,16(sp)
    800013de:	e426                	sd	s1,8(sp)
    800013e0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013e2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013e4:	00b67d63          	bgeu	a2,a1,800013fe <uvmdealloc+0x26>
    800013e8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013ea:	6785                	lui	a5,0x1
    800013ec:	17fd                	addi	a5,a5,-1
    800013ee:	00f60733          	add	a4,a2,a5
    800013f2:	767d                	lui	a2,0xfffff
    800013f4:	8f71                	and	a4,a4,a2
    800013f6:	97ae                	add	a5,a5,a1
    800013f8:	8ff1                	and	a5,a5,a2
    800013fa:	00f76863          	bltu	a4,a5,8000140a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013fe:	8526                	mv	a0,s1
    80001400:	60e2                	ld	ra,24(sp)
    80001402:	6442                	ld	s0,16(sp)
    80001404:	64a2                	ld	s1,8(sp)
    80001406:	6105                	addi	sp,sp,32
    80001408:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000140a:	8f99                	sub	a5,a5,a4
    8000140c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000140e:	4685                	li	a3,1
    80001410:	0007861b          	sext.w	a2,a5
    80001414:	85ba                	mv	a1,a4
    80001416:	00000097          	auipc	ra,0x0
    8000141a:	e5e080e7          	jalr	-418(ra) # 80001274 <uvmunmap>
    8000141e:	b7c5                	j	800013fe <uvmdealloc+0x26>

0000000080001420 <uvmalloc>:
  if(newsz < oldsz)
    80001420:	0ab66163          	bltu	a2,a1,800014c2 <uvmalloc+0xa2>
{
    80001424:	7139                	addi	sp,sp,-64
    80001426:	fc06                	sd	ra,56(sp)
    80001428:	f822                	sd	s0,48(sp)
    8000142a:	f426                	sd	s1,40(sp)
    8000142c:	f04a                	sd	s2,32(sp)
    8000142e:	ec4e                	sd	s3,24(sp)
    80001430:	e852                	sd	s4,16(sp)
    80001432:	e456                	sd	s5,8(sp)
    80001434:	0080                	addi	s0,sp,64
    80001436:	8aaa                	mv	s5,a0
    80001438:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000143a:	6985                	lui	s3,0x1
    8000143c:	19fd                	addi	s3,s3,-1
    8000143e:	95ce                	add	a1,a1,s3
    80001440:	79fd                	lui	s3,0xfffff
    80001442:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001446:	08c9f063          	bgeu	s3,a2,800014c6 <uvmalloc+0xa6>
    8000144a:	894e                	mv	s2,s3
    mem = kalloc();
    8000144c:	fffff097          	auipc	ra,0xfffff
    80001450:	6a6080e7          	jalr	1702(ra) # 80000af2 <kalloc>
    80001454:	84aa                	mv	s1,a0
    if(mem == 0){
    80001456:	c51d                	beqz	a0,80001484 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001458:	6605                	lui	a2,0x1
    8000145a:	4581                	li	a1,0
    8000145c:	00000097          	auipc	ra,0x0
    80001460:	882080e7          	jalr	-1918(ra) # 80000cde <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001464:	4779                	li	a4,30
    80001466:	86a6                	mv	a3,s1
    80001468:	6605                	lui	a2,0x1
    8000146a:	85ca                	mv	a1,s2
    8000146c:	8556                	mv	a0,s5
    8000146e:	00000097          	auipc	ra,0x0
    80001472:	c40080e7          	jalr	-960(ra) # 800010ae <mappages>
    80001476:	e905                	bnez	a0,800014a6 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001478:	6785                	lui	a5,0x1
    8000147a:	993e                	add	s2,s2,a5
    8000147c:	fd4968e3          	bltu	s2,s4,8000144c <uvmalloc+0x2c>
  return newsz;
    80001480:	8552                	mv	a0,s4
    80001482:	a809                	j	80001494 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001484:	864e                	mv	a2,s3
    80001486:	85ca                	mv	a1,s2
    80001488:	8556                	mv	a0,s5
    8000148a:	00000097          	auipc	ra,0x0
    8000148e:	f4e080e7          	jalr	-178(ra) # 800013d8 <uvmdealloc>
      return 0;
    80001492:	4501                	li	a0,0
}
    80001494:	70e2                	ld	ra,56(sp)
    80001496:	7442                	ld	s0,48(sp)
    80001498:	74a2                	ld	s1,40(sp)
    8000149a:	7902                	ld	s2,32(sp)
    8000149c:	69e2                	ld	s3,24(sp)
    8000149e:	6a42                	ld	s4,16(sp)
    800014a0:	6aa2                	ld	s5,8(sp)
    800014a2:	6121                	addi	sp,sp,64
    800014a4:	8082                	ret
      kfree(mem);
    800014a6:	8526                	mv	a0,s1
    800014a8:	fffff097          	auipc	ra,0xfffff
    800014ac:	54e080e7          	jalr	1358(ra) # 800009f6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b0:	864e                	mv	a2,s3
    800014b2:	85ca                	mv	a1,s2
    800014b4:	8556                	mv	a0,s5
    800014b6:	00000097          	auipc	ra,0x0
    800014ba:	f22080e7          	jalr	-222(ra) # 800013d8 <uvmdealloc>
      return 0;
    800014be:	4501                	li	a0,0
    800014c0:	bfd1                	j	80001494 <uvmalloc+0x74>
    return oldsz;
    800014c2:	852e                	mv	a0,a1
}
    800014c4:	8082                	ret
  return newsz;
    800014c6:	8532                	mv	a0,a2
    800014c8:	b7f1                	j	80001494 <uvmalloc+0x74>

00000000800014ca <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014ca:	7179                	addi	sp,sp,-48
    800014cc:	f406                	sd	ra,40(sp)
    800014ce:	f022                	sd	s0,32(sp)
    800014d0:	ec26                	sd	s1,24(sp)
    800014d2:	e84a                	sd	s2,16(sp)
    800014d4:	e44e                	sd	s3,8(sp)
    800014d6:	e052                	sd	s4,0(sp)
    800014d8:	1800                	addi	s0,sp,48
    800014da:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014dc:	84aa                	mv	s1,a0
    800014de:	6905                	lui	s2,0x1
    800014e0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e2:	4985                	li	s3,1
    800014e4:	a821                	j	800014fc <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e6:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e8:	0532                	slli	a0,a0,0xc
    800014ea:	00000097          	auipc	ra,0x0
    800014ee:	fe0080e7          	jalr	-32(ra) # 800014ca <freewalk>
      pagetable[i] = 0;
    800014f2:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f6:	04a1                	addi	s1,s1,8
    800014f8:	03248163          	beq	s1,s2,8000151a <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014fc:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014fe:	00f57793          	andi	a5,a0,15
    80001502:	ff3782e3          	beq	a5,s3,800014e6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001506:	8905                	andi	a0,a0,1
    80001508:	d57d                	beqz	a0,800014f6 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000150a:	00008517          	auipc	a0,0x8
    8000150e:	c6e50513          	addi	a0,a0,-914 # 80009178 <digits+0x138>
    80001512:	fffff097          	auipc	ra,0xfffff
    80001516:	02a080e7          	jalr	42(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    8000151a:	8552                	mv	a0,s4
    8000151c:	fffff097          	auipc	ra,0xfffff
    80001520:	4da080e7          	jalr	1242(ra) # 800009f6 <kfree>
}
    80001524:	70a2                	ld	ra,40(sp)
    80001526:	7402                	ld	s0,32(sp)
    80001528:	64e2                	ld	s1,24(sp)
    8000152a:	6942                	ld	s2,16(sp)
    8000152c:	69a2                	ld	s3,8(sp)
    8000152e:	6a02                	ld	s4,0(sp)
    80001530:	6145                	addi	sp,sp,48
    80001532:	8082                	ret

0000000080001534 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001534:	1101                	addi	sp,sp,-32
    80001536:	ec06                	sd	ra,24(sp)
    80001538:	e822                	sd	s0,16(sp)
    8000153a:	e426                	sd	s1,8(sp)
    8000153c:	1000                	addi	s0,sp,32
    8000153e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001540:	e999                	bnez	a1,80001556 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001542:	8526                	mv	a0,s1
    80001544:	00000097          	auipc	ra,0x0
    80001548:	f86080e7          	jalr	-122(ra) # 800014ca <freewalk>
}
    8000154c:	60e2                	ld	ra,24(sp)
    8000154e:	6442                	ld	s0,16(sp)
    80001550:	64a2                	ld	s1,8(sp)
    80001552:	6105                	addi	sp,sp,32
    80001554:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001556:	6605                	lui	a2,0x1
    80001558:	167d                	addi	a2,a2,-1
    8000155a:	962e                	add	a2,a2,a1
    8000155c:	4685                	li	a3,1
    8000155e:	8231                	srli	a2,a2,0xc
    80001560:	4581                	li	a1,0
    80001562:	00000097          	auipc	ra,0x0
    80001566:	d12080e7          	jalr	-750(ra) # 80001274 <uvmunmap>
    8000156a:	bfe1                	j	80001542 <uvmfree+0xe>

000000008000156c <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000156c:	c679                	beqz	a2,8000163a <uvmcopy+0xce>
{
    8000156e:	715d                	addi	sp,sp,-80
    80001570:	e486                	sd	ra,72(sp)
    80001572:	e0a2                	sd	s0,64(sp)
    80001574:	fc26                	sd	s1,56(sp)
    80001576:	f84a                	sd	s2,48(sp)
    80001578:	f44e                	sd	s3,40(sp)
    8000157a:	f052                	sd	s4,32(sp)
    8000157c:	ec56                	sd	s5,24(sp)
    8000157e:	e85a                	sd	s6,16(sp)
    80001580:	e45e                	sd	s7,8(sp)
    80001582:	0880                	addi	s0,sp,80
    80001584:	8b2a                	mv	s6,a0
    80001586:	8aae                	mv	s5,a1
    80001588:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000158a:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000158c:	4601                	li	a2,0
    8000158e:	85ce                	mv	a1,s3
    80001590:	855a                	mv	a0,s6
    80001592:	00000097          	auipc	ra,0x0
    80001596:	a34080e7          	jalr	-1484(ra) # 80000fc6 <walk>
    8000159a:	c531                	beqz	a0,800015e6 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000159c:	6118                	ld	a4,0(a0)
    8000159e:	00177793          	andi	a5,a4,1
    800015a2:	cbb1                	beqz	a5,800015f6 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a4:	00a75593          	srli	a1,a4,0xa
    800015a8:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015ac:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015b0:	fffff097          	auipc	ra,0xfffff
    800015b4:	542080e7          	jalr	1346(ra) # 80000af2 <kalloc>
    800015b8:	892a                	mv	s2,a0
    800015ba:	c939                	beqz	a0,80001610 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015bc:	6605                	lui	a2,0x1
    800015be:	85de                	mv	a1,s7
    800015c0:	fffff097          	auipc	ra,0xfffff
    800015c4:	77e080e7          	jalr	1918(ra) # 80000d3e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c8:	8726                	mv	a4,s1
    800015ca:	86ca                	mv	a3,s2
    800015cc:	6605                	lui	a2,0x1
    800015ce:	85ce                	mv	a1,s3
    800015d0:	8556                	mv	a0,s5
    800015d2:	00000097          	auipc	ra,0x0
    800015d6:	adc080e7          	jalr	-1316(ra) # 800010ae <mappages>
    800015da:	e515                	bnez	a0,80001606 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015dc:	6785                	lui	a5,0x1
    800015de:	99be                	add	s3,s3,a5
    800015e0:	fb49e6e3          	bltu	s3,s4,8000158c <uvmcopy+0x20>
    800015e4:	a081                	j	80001624 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e6:	00008517          	auipc	a0,0x8
    800015ea:	ba250513          	addi	a0,a0,-1118 # 80009188 <digits+0x148>
    800015ee:	fffff097          	auipc	ra,0xfffff
    800015f2:	f4e080e7          	jalr	-178(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015f6:	00008517          	auipc	a0,0x8
    800015fa:	bb250513          	addi	a0,a0,-1102 # 800091a8 <digits+0x168>
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	f3e080e7          	jalr	-194(ra) # 8000053c <panic>
      kfree(mem);
    80001606:	854a                	mv	a0,s2
    80001608:	fffff097          	auipc	ra,0xfffff
    8000160c:	3ee080e7          	jalr	1006(ra) # 800009f6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001610:	4685                	li	a3,1
    80001612:	00c9d613          	srli	a2,s3,0xc
    80001616:	4581                	li	a1,0
    80001618:	8556                	mv	a0,s5
    8000161a:	00000097          	auipc	ra,0x0
    8000161e:	c5a080e7          	jalr	-934(ra) # 80001274 <uvmunmap>
  return -1;
    80001622:	557d                	li	a0,-1
}
    80001624:	60a6                	ld	ra,72(sp)
    80001626:	6406                	ld	s0,64(sp)
    80001628:	74e2                	ld	s1,56(sp)
    8000162a:	7942                	ld	s2,48(sp)
    8000162c:	79a2                	ld	s3,40(sp)
    8000162e:	7a02                	ld	s4,32(sp)
    80001630:	6ae2                	ld	s5,24(sp)
    80001632:	6b42                	ld	s6,16(sp)
    80001634:	6ba2                	ld	s7,8(sp)
    80001636:	6161                	addi	sp,sp,80
    80001638:	8082                	ret
  return 0;
    8000163a:	4501                	li	a0,0
}
    8000163c:	8082                	ret

000000008000163e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163e:	1141                	addi	sp,sp,-16
    80001640:	e406                	sd	ra,8(sp)
    80001642:	e022                	sd	s0,0(sp)
    80001644:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001646:	4601                	li	a2,0
    80001648:	00000097          	auipc	ra,0x0
    8000164c:	97e080e7          	jalr	-1666(ra) # 80000fc6 <walk>
  if(pte == 0)
    80001650:	c901                	beqz	a0,80001660 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001652:	611c                	ld	a5,0(a0)
    80001654:	9bbd                	andi	a5,a5,-17
    80001656:	e11c                	sd	a5,0(a0)
}
    80001658:	60a2                	ld	ra,8(sp)
    8000165a:	6402                	ld	s0,0(sp)
    8000165c:	0141                	addi	sp,sp,16
    8000165e:	8082                	ret
    panic("uvmclear");
    80001660:	00008517          	auipc	a0,0x8
    80001664:	b6850513          	addi	a0,a0,-1176 # 800091c8 <digits+0x188>
    80001668:	fffff097          	auipc	ra,0xfffff
    8000166c:	ed4080e7          	jalr	-300(ra) # 8000053c <panic>

0000000080001670 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001670:	c6bd                	beqz	a3,800016de <copyout+0x6e>
{
    80001672:	715d                	addi	sp,sp,-80
    80001674:	e486                	sd	ra,72(sp)
    80001676:	e0a2                	sd	s0,64(sp)
    80001678:	fc26                	sd	s1,56(sp)
    8000167a:	f84a                	sd	s2,48(sp)
    8000167c:	f44e                	sd	s3,40(sp)
    8000167e:	f052                	sd	s4,32(sp)
    80001680:	ec56                	sd	s5,24(sp)
    80001682:	e85a                	sd	s6,16(sp)
    80001684:	e45e                	sd	s7,8(sp)
    80001686:	e062                	sd	s8,0(sp)
    80001688:	0880                	addi	s0,sp,80
    8000168a:	8b2a                	mv	s6,a0
    8000168c:	8c2e                	mv	s8,a1
    8000168e:	8a32                	mv	s4,a2
    80001690:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001692:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001694:	6a85                	lui	s5,0x1
    80001696:	a015                	j	800016ba <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001698:	9562                	add	a0,a0,s8
    8000169a:	0004861b          	sext.w	a2,s1
    8000169e:	85d2                	mv	a1,s4
    800016a0:	41250533          	sub	a0,a0,s2
    800016a4:	fffff097          	auipc	ra,0xfffff
    800016a8:	69a080e7          	jalr	1690(ra) # 80000d3e <memmove>

    len -= n;
    800016ac:	409989b3          	sub	s3,s3,s1
    src += n;
    800016b0:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016b2:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b6:	02098263          	beqz	s3,800016da <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016ba:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016be:	85ca                	mv	a1,s2
    800016c0:	855a                	mv	a0,s6
    800016c2:	00000097          	auipc	ra,0x0
    800016c6:	9aa080e7          	jalr	-1622(ra) # 8000106c <walkaddr>
    if(pa0 == 0)
    800016ca:	cd01                	beqz	a0,800016e2 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016cc:	418904b3          	sub	s1,s2,s8
    800016d0:	94d6                	add	s1,s1,s5
    if(n > len)
    800016d2:	fc99f3e3          	bgeu	s3,s1,80001698 <copyout+0x28>
    800016d6:	84ce                	mv	s1,s3
    800016d8:	b7c1                	j	80001698 <copyout+0x28>
  }
  return 0;
    800016da:	4501                	li	a0,0
    800016dc:	a021                	j	800016e4 <copyout+0x74>
    800016de:	4501                	li	a0,0
}
    800016e0:	8082                	ret
      return -1;
    800016e2:	557d                	li	a0,-1
}
    800016e4:	60a6                	ld	ra,72(sp)
    800016e6:	6406                	ld	s0,64(sp)
    800016e8:	74e2                	ld	s1,56(sp)
    800016ea:	7942                	ld	s2,48(sp)
    800016ec:	79a2                	ld	s3,40(sp)
    800016ee:	7a02                	ld	s4,32(sp)
    800016f0:	6ae2                	ld	s5,24(sp)
    800016f2:	6b42                	ld	s6,16(sp)
    800016f4:	6ba2                	ld	s7,8(sp)
    800016f6:	6c02                	ld	s8,0(sp)
    800016f8:	6161                	addi	sp,sp,80
    800016fa:	8082                	ret

00000000800016fc <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016fc:	c6bd                	beqz	a3,8000176a <copyin+0x6e>
{
    800016fe:	715d                	addi	sp,sp,-80
    80001700:	e486                	sd	ra,72(sp)
    80001702:	e0a2                	sd	s0,64(sp)
    80001704:	fc26                	sd	s1,56(sp)
    80001706:	f84a                	sd	s2,48(sp)
    80001708:	f44e                	sd	s3,40(sp)
    8000170a:	f052                	sd	s4,32(sp)
    8000170c:	ec56                	sd	s5,24(sp)
    8000170e:	e85a                	sd	s6,16(sp)
    80001710:	e45e                	sd	s7,8(sp)
    80001712:	e062                	sd	s8,0(sp)
    80001714:	0880                	addi	s0,sp,80
    80001716:	8b2a                	mv	s6,a0
    80001718:	8a2e                	mv	s4,a1
    8000171a:	8c32                	mv	s8,a2
    8000171c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001720:	6a85                	lui	s5,0x1
    80001722:	a015                	j	80001746 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001724:	9562                	add	a0,a0,s8
    80001726:	0004861b          	sext.w	a2,s1
    8000172a:	412505b3          	sub	a1,a0,s2
    8000172e:	8552                	mv	a0,s4
    80001730:	fffff097          	auipc	ra,0xfffff
    80001734:	60e080e7          	jalr	1550(ra) # 80000d3e <memmove>

    len -= n;
    80001738:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173c:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001742:	02098263          	beqz	s3,80001766 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001746:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000174a:	85ca                	mv	a1,s2
    8000174c:	855a                	mv	a0,s6
    8000174e:	00000097          	auipc	ra,0x0
    80001752:	91e080e7          	jalr	-1762(ra) # 8000106c <walkaddr>
    if(pa0 == 0)
    80001756:	cd01                	beqz	a0,8000176e <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80001758:	418904b3          	sub	s1,s2,s8
    8000175c:	94d6                	add	s1,s1,s5
    if(n > len)
    8000175e:	fc99f3e3          	bgeu	s3,s1,80001724 <copyin+0x28>
    80001762:	84ce                	mv	s1,s3
    80001764:	b7c1                	j	80001724 <copyin+0x28>
  }
  return 0;
    80001766:	4501                	li	a0,0
    80001768:	a021                	j	80001770 <copyin+0x74>
    8000176a:	4501                	li	a0,0
}
    8000176c:	8082                	ret
      return -1;
    8000176e:	557d                	li	a0,-1
}
    80001770:	60a6                	ld	ra,72(sp)
    80001772:	6406                	ld	s0,64(sp)
    80001774:	74e2                	ld	s1,56(sp)
    80001776:	7942                	ld	s2,48(sp)
    80001778:	79a2                	ld	s3,40(sp)
    8000177a:	7a02                	ld	s4,32(sp)
    8000177c:	6ae2                	ld	s5,24(sp)
    8000177e:	6b42                	ld	s6,16(sp)
    80001780:	6ba2                	ld	s7,8(sp)
    80001782:	6c02                	ld	s8,0(sp)
    80001784:	6161                	addi	sp,sp,80
    80001786:	8082                	ret

0000000080001788 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001788:	c6c5                	beqz	a3,80001830 <copyinstr+0xa8>
{
    8000178a:	715d                	addi	sp,sp,-80
    8000178c:	e486                	sd	ra,72(sp)
    8000178e:	e0a2                	sd	s0,64(sp)
    80001790:	fc26                	sd	s1,56(sp)
    80001792:	f84a                	sd	s2,48(sp)
    80001794:	f44e                	sd	s3,40(sp)
    80001796:	f052                	sd	s4,32(sp)
    80001798:	ec56                	sd	s5,24(sp)
    8000179a:	e85a                	sd	s6,16(sp)
    8000179c:	e45e                	sd	s7,8(sp)
    8000179e:	0880                	addi	s0,sp,80
    800017a0:	8a2a                	mv	s4,a0
    800017a2:	8b2e                	mv	s6,a1
    800017a4:	8bb2                	mv	s7,a2
    800017a6:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017aa:	6985                	lui	s3,0x1
    800017ac:	a035                	j	800017d8 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ae:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b4:	0017b793          	seqz	a5,a5
    800017b8:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017bc:	60a6                	ld	ra,72(sp)
    800017be:	6406                	ld	s0,64(sp)
    800017c0:	74e2                	ld	s1,56(sp)
    800017c2:	7942                	ld	s2,48(sp)
    800017c4:	79a2                	ld	s3,40(sp)
    800017c6:	7a02                	ld	s4,32(sp)
    800017c8:	6ae2                	ld	s5,24(sp)
    800017ca:	6b42                	ld	s6,16(sp)
    800017cc:	6ba2                	ld	s7,8(sp)
    800017ce:	6161                	addi	sp,sp,80
    800017d0:	8082                	ret
    srcva = va0 + PGSIZE;
    800017d2:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d6:	c8a9                	beqz	s1,80001828 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017d8:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017dc:	85ca                	mv	a1,s2
    800017de:	8552                	mv	a0,s4
    800017e0:	00000097          	auipc	ra,0x0
    800017e4:	88c080e7          	jalr	-1908(ra) # 8000106c <walkaddr>
    if(pa0 == 0)
    800017e8:	c131                	beqz	a0,8000182c <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ea:	41790833          	sub	a6,s2,s7
    800017ee:	984e                	add	a6,a6,s3
    if(n > max)
    800017f0:	0104f363          	bgeu	s1,a6,800017f6 <copyinstr+0x6e>
    800017f4:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f6:	955e                	add	a0,a0,s7
    800017f8:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017fc:	fc080be3          	beqz	a6,800017d2 <copyinstr+0x4a>
    80001800:	985a                	add	a6,a6,s6
    80001802:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001804:	41650633          	sub	a2,a0,s6
    80001808:	14fd                	addi	s1,s1,-1
    8000180a:	9b26                	add	s6,s6,s1
    8000180c:	00f60733          	add	a4,a2,a5
    80001810:	00074703          	lbu	a4,0(a4)
    80001814:	df49                	beqz	a4,800017ae <copyinstr+0x26>
        *dst = *p;
    80001816:	00e78023          	sb	a4,0(a5)
      --max;
    8000181a:	40fb04b3          	sub	s1,s6,a5
      dst++;
    8000181e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001820:	ff0796e3          	bne	a5,a6,8000180c <copyinstr+0x84>
      dst++;
    80001824:	8b42                	mv	s6,a6
    80001826:	b775                	j	800017d2 <copyinstr+0x4a>
    80001828:	4781                	li	a5,0
    8000182a:	b769                	j	800017b4 <copyinstr+0x2c>
      return -1;
    8000182c:	557d                	li	a0,-1
    8000182e:	b779                	j	800017bc <copyinstr+0x34>
  int got_null = 0;
    80001830:	4781                	li	a5,0
  if(got_null){
    80001832:	0017b793          	seqz	a5,a5
    80001836:	40f00533          	neg	a0,a5
}
    8000183a:	8082                	ret

000000008000183c <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000183c:	7139                	addi	sp,sp,-64
    8000183e:	fc06                	sd	ra,56(sp)
    80001840:	f822                	sd	s0,48(sp)
    80001842:	f426                	sd	s1,40(sp)
    80001844:	f04a                	sd	s2,32(sp)
    80001846:	ec4e                	sd	s3,24(sp)
    80001848:	e852                	sd	s4,16(sp)
    8000184a:	e456                	sd	s5,8(sp)
    8000184c:	e05a                	sd	s6,0(sp)
    8000184e:	0080                	addi	s0,sp,64
    80001850:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001852:	00011497          	auipc	s1,0x11
    80001856:	ebe48493          	addi	s1,s1,-322 # 80012710 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000185a:	8b26                	mv	s6,s1
    8000185c:	00007a97          	auipc	s5,0x7
    80001860:	7a4a8a93          	addi	s5,s5,1956 # 80009000 <etext>
    80001864:	04000937          	lui	s2,0x4000
    80001868:	197d                	addi	s2,s2,-1
    8000186a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186c:	00017a17          	auipc	s4,0x17
    80001870:	2a4a0a13          	addi	s4,s4,676 # 80018b10 <tickslock>
    char *pa = kalloc();
    80001874:	fffff097          	auipc	ra,0xfffff
    80001878:	27e080e7          	jalr	638(ra) # 80000af2 <kalloc>
    8000187c:	862a                	mv	a2,a0
    if(pa == 0)
    8000187e:	c131                	beqz	a0,800018c2 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001880:	416485b3          	sub	a1,s1,s6
    80001884:	8591                	srai	a1,a1,0x4
    80001886:	000ab783          	ld	a5,0(s5)
    8000188a:	02f585b3          	mul	a1,a1,a5
    8000188e:	2585                	addiw	a1,a1,1
    80001890:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001894:	4719                	li	a4,6
    80001896:	6685                	lui	a3,0x1
    80001898:	40b905b3          	sub	a1,s2,a1
    8000189c:	854e                	mv	a0,s3
    8000189e:	00000097          	auipc	ra,0x0
    800018a2:	8b0080e7          	jalr	-1872(ra) # 8000114e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a6:	19048493          	addi	s1,s1,400
    800018aa:	fd4495e3          	bne	s1,s4,80001874 <proc_mapstacks+0x38>
  }
}
    800018ae:	70e2                	ld	ra,56(sp)
    800018b0:	7442                	ld	s0,48(sp)
    800018b2:	74a2                	ld	s1,40(sp)
    800018b4:	7902                	ld	s2,32(sp)
    800018b6:	69e2                	ld	s3,24(sp)
    800018b8:	6a42                	ld	s4,16(sp)
    800018ba:	6aa2                	ld	s5,8(sp)
    800018bc:	6b02                	ld	s6,0(sp)
    800018be:	6121                	addi	sp,sp,64
    800018c0:	8082                	ret
      panic("kalloc");
    800018c2:	00008517          	auipc	a0,0x8
    800018c6:	91650513          	addi	a0,a0,-1770 # 800091d8 <digits+0x198>
    800018ca:	fffff097          	auipc	ra,0xfffff
    800018ce:	c72080e7          	jalr	-910(ra) # 8000053c <panic>

00000000800018d2 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018d2:	7139                	addi	sp,sp,-64
    800018d4:	fc06                	sd	ra,56(sp)
    800018d6:	f822                	sd	s0,48(sp)
    800018d8:	f426                	sd	s1,40(sp)
    800018da:	f04a                	sd	s2,32(sp)
    800018dc:	ec4e                	sd	s3,24(sp)
    800018de:	e852                	sd	s4,16(sp)
    800018e0:	e456                	sd	s5,8(sp)
    800018e2:	e05a                	sd	s6,0(sp)
    800018e4:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e6:	00008597          	auipc	a1,0x8
    800018ea:	8fa58593          	addi	a1,a1,-1798 # 800091e0 <digits+0x1a0>
    800018ee:	00011517          	auipc	a0,0x11
    800018f2:	9f250513          	addi	a0,a0,-1550 # 800122e0 <pid_lock>
    800018f6:	fffff097          	auipc	ra,0xfffff
    800018fa:	25c080e7          	jalr	604(ra) # 80000b52 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018fe:	00008597          	auipc	a1,0x8
    80001902:	8ea58593          	addi	a1,a1,-1814 # 800091e8 <digits+0x1a8>
    80001906:	00011517          	auipc	a0,0x11
    8000190a:	9f250513          	addi	a0,a0,-1550 # 800122f8 <wait_lock>
    8000190e:	fffff097          	auipc	ra,0xfffff
    80001912:	244080e7          	jalr	580(ra) # 80000b52 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001916:	00011497          	auipc	s1,0x11
    8000191a:	dfa48493          	addi	s1,s1,-518 # 80012710 <proc>
      initlock(&p->lock, "proc");
    8000191e:	00008b17          	auipc	s6,0x8
    80001922:	8dab0b13          	addi	s6,s6,-1830 # 800091f8 <digits+0x1b8>
      p->kstack = KSTACK((int) (p - proc));
    80001926:	8aa6                	mv	s5,s1
    80001928:	00007a17          	auipc	s4,0x7
    8000192c:	6d8a0a13          	addi	s4,s4,1752 # 80009000 <etext>
    80001930:	04000937          	lui	s2,0x4000
    80001934:	197d                	addi	s2,s2,-1
    80001936:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001938:	00017997          	auipc	s3,0x17
    8000193c:	1d898993          	addi	s3,s3,472 # 80018b10 <tickslock>
      initlock(&p->lock, "proc");
    80001940:	85da                	mv	a1,s6
    80001942:	8526                	mv	a0,s1
    80001944:	fffff097          	auipc	ra,0xfffff
    80001948:	20e080e7          	jalr	526(ra) # 80000b52 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    8000194c:	415487b3          	sub	a5,s1,s5
    80001950:	8791                	srai	a5,a5,0x4
    80001952:	000a3703          	ld	a4,0(s4)
    80001956:	02e787b3          	mul	a5,a5,a4
    8000195a:	2785                	addiw	a5,a5,1
    8000195c:	00d7979b          	slliw	a5,a5,0xd
    80001960:	40f907b3          	sub	a5,s2,a5
    80001964:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001966:	19048493          	addi	s1,s1,400
    8000196a:	fd349be3          	bne	s1,s3,80001940 <procinit+0x6e>
  }
}
    8000196e:	70e2                	ld	ra,56(sp)
    80001970:	7442                	ld	s0,48(sp)
    80001972:	74a2                	ld	s1,40(sp)
    80001974:	7902                	ld	s2,32(sp)
    80001976:	69e2                	ld	s3,24(sp)
    80001978:	6a42                	ld	s4,16(sp)
    8000197a:	6aa2                	ld	s5,8(sp)
    8000197c:	6b02                	ld	s6,0(sp)
    8000197e:	6121                	addi	sp,sp,64
    80001980:	8082                	ret

0000000080001982 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001982:	1141                	addi	sp,sp,-16
    80001984:	e422                	sd	s0,8(sp)
    80001986:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001988:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000198a:	2501                	sext.w	a0,a0
    8000198c:	6422                	ld	s0,8(sp)
    8000198e:	0141                	addi	sp,sp,16
    80001990:	8082                	ret

0000000080001992 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001992:	1141                	addi	sp,sp,-16
    80001994:	e422                	sd	s0,8(sp)
    80001996:	0800                	addi	s0,sp,16
    80001998:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000199a:	2781                	sext.w	a5,a5
    8000199c:	079e                	slli	a5,a5,0x7
  return c;
}
    8000199e:	00011517          	auipc	a0,0x11
    800019a2:	97250513          	addi	a0,a0,-1678 # 80012310 <cpus>
    800019a6:	953e                	add	a0,a0,a5
    800019a8:	6422                	ld	s0,8(sp)
    800019aa:	0141                	addi	sp,sp,16
    800019ac:	8082                	ret

00000000800019ae <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    800019ae:	1101                	addi	sp,sp,-32
    800019b0:	ec06                	sd	ra,24(sp)
    800019b2:	e822                	sd	s0,16(sp)
    800019b4:	e426                	sd	s1,8(sp)
    800019b6:	1000                	addi	s0,sp,32
  push_off();
    800019b8:	fffff097          	auipc	ra,0xfffff
    800019bc:	1de080e7          	jalr	478(ra) # 80000b96 <push_off>
    800019c0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c2:	2781                	sext.w	a5,a5
    800019c4:	079e                	slli	a5,a5,0x7
    800019c6:	00011717          	auipc	a4,0x11
    800019ca:	91a70713          	addi	a4,a4,-1766 # 800122e0 <pid_lock>
    800019ce:	97ba                	add	a5,a5,a4
    800019d0:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d2:	fffff097          	auipc	ra,0xfffff
    800019d6:	264080e7          	jalr	612(ra) # 80000c36 <pop_off>
  return p;
}
    800019da:	8526                	mv	a0,s1
    800019dc:	60e2                	ld	ra,24(sp)
    800019de:	6442                	ld	s0,16(sp)
    800019e0:	64a2                	ld	s1,8(sp)
    800019e2:	6105                	addi	sp,sp,32
    800019e4:	8082                	ret

00000000800019e6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019e6:	1101                	addi	sp,sp,-32
    800019e8:	ec06                	sd	ra,24(sp)
    800019ea:	e822                	sd	s0,16(sp)
    800019ec:	e426                	sd	s1,8(sp)
    800019ee:	1000                	addi	s0,sp,32
  static int first = 1;
  uint xticks;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019f0:	00000097          	auipc	ra,0x0
    800019f4:	fbe080e7          	jalr	-66(ra) # 800019ae <myproc>
    800019f8:	fffff097          	auipc	ra,0xfffff
    800019fc:	29e080e7          	jalr	670(ra) # 80000c96 <release>

  acquire(&tickslock);
    80001a00:	00017517          	auipc	a0,0x17
    80001a04:	11050513          	addi	a0,a0,272 # 80018b10 <tickslock>
    80001a08:	fffff097          	auipc	ra,0xfffff
    80001a0c:	1da080e7          	jalr	474(ra) # 80000be2 <acquire>
  xticks = ticks;
    80001a10:	00008497          	auipc	s1,0x8
    80001a14:	6604a483          	lw	s1,1632(s1) # 8000a070 <ticks>
  release(&tickslock);
    80001a18:	00017517          	auipc	a0,0x17
    80001a1c:	0f850513          	addi	a0,a0,248 # 80018b10 <tickslock>
    80001a20:	fffff097          	auipc	ra,0xfffff
    80001a24:	276080e7          	jalr	630(ra) # 80000c96 <release>

  myproc()->stime = xticks;
    80001a28:	00000097          	auipc	ra,0x0
    80001a2c:	f86080e7          	jalr	-122(ra) # 800019ae <myproc>
    80001a30:	16952623          	sw	s1,364(a0)

  if (first) {
    80001a34:	00008797          	auipc	a5,0x8
    80001a38:	0447a783          	lw	a5,68(a5) # 80009a78 <first.1778>
    80001a3c:	eb91                	bnez	a5,80001a50 <forkret+0x6a>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a3e:	00002097          	auipc	ra,0x2
    80001a42:	bbe080e7          	jalr	-1090(ra) # 800035fc <usertrapret>
}
    80001a46:	60e2                	ld	ra,24(sp)
    80001a48:	6442                	ld	s0,16(sp)
    80001a4a:	64a2                	ld	s1,8(sp)
    80001a4c:	6105                	addi	sp,sp,32
    80001a4e:	8082                	ret
    first = 0;
    80001a50:	00008797          	auipc	a5,0x8
    80001a54:	0207a423          	sw	zero,40(a5) # 80009a78 <first.1778>
    fsinit(ROOTDEV);
    80001a58:	4505                	li	a0,1
    80001a5a:	00003097          	auipc	ra,0x3
    80001a5e:	b14080e7          	jalr	-1260(ra) # 8000456e <fsinit>
    80001a62:	bff1                	j	80001a3e <forkret+0x58>

0000000080001a64 <allocpid>:
allocpid() {
    80001a64:	1101                	addi	sp,sp,-32
    80001a66:	ec06                	sd	ra,24(sp)
    80001a68:	e822                	sd	s0,16(sp)
    80001a6a:	e426                	sd	s1,8(sp)
    80001a6c:	e04a                	sd	s2,0(sp)
    80001a6e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a70:	00011917          	auipc	s2,0x11
    80001a74:	87090913          	addi	s2,s2,-1936 # 800122e0 <pid_lock>
    80001a78:	854a                	mv	a0,s2
    80001a7a:	fffff097          	auipc	ra,0xfffff
    80001a7e:	168080e7          	jalr	360(ra) # 80000be2 <acquire>
  pid = nextpid;
    80001a82:	00008797          	auipc	a5,0x8
    80001a86:	ffa78793          	addi	a5,a5,-6 # 80009a7c <nextpid>
    80001a8a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a8c:	0014871b          	addiw	a4,s1,1
    80001a90:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a92:	854a                	mv	a0,s2
    80001a94:	fffff097          	auipc	ra,0xfffff
    80001a98:	202080e7          	jalr	514(ra) # 80000c96 <release>
}
    80001a9c:	8526                	mv	a0,s1
    80001a9e:	60e2                	ld	ra,24(sp)
    80001aa0:	6442                	ld	s0,16(sp)
    80001aa2:	64a2                	ld	s1,8(sp)
    80001aa4:	6902                	ld	s2,0(sp)
    80001aa6:	6105                	addi	sp,sp,32
    80001aa8:	8082                	ret

0000000080001aaa <proc_pagetable>:
{
    80001aaa:	1101                	addi	sp,sp,-32
    80001aac:	ec06                	sd	ra,24(sp)
    80001aae:	e822                	sd	s0,16(sp)
    80001ab0:	e426                	sd	s1,8(sp)
    80001ab2:	e04a                	sd	s2,0(sp)
    80001ab4:	1000                	addi	s0,sp,32
    80001ab6:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ab8:	00000097          	auipc	ra,0x0
    80001abc:	880080e7          	jalr	-1920(ra) # 80001338 <uvmcreate>
    80001ac0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ac2:	c121                	beqz	a0,80001b02 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ac4:	4729                	li	a4,10
    80001ac6:	00006697          	auipc	a3,0x6
    80001aca:	53a68693          	addi	a3,a3,1338 # 80008000 <_trampoline>
    80001ace:	6605                	lui	a2,0x1
    80001ad0:	040005b7          	lui	a1,0x4000
    80001ad4:	15fd                	addi	a1,a1,-1
    80001ad6:	05b2                	slli	a1,a1,0xc
    80001ad8:	fffff097          	auipc	ra,0xfffff
    80001adc:	5d6080e7          	jalr	1494(ra) # 800010ae <mappages>
    80001ae0:	02054863          	bltz	a0,80001b10 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ae4:	4719                	li	a4,6
    80001ae6:	05893683          	ld	a3,88(s2)
    80001aea:	6605                	lui	a2,0x1
    80001aec:	020005b7          	lui	a1,0x2000
    80001af0:	15fd                	addi	a1,a1,-1
    80001af2:	05b6                	slli	a1,a1,0xd
    80001af4:	8526                	mv	a0,s1
    80001af6:	fffff097          	auipc	ra,0xfffff
    80001afa:	5b8080e7          	jalr	1464(ra) # 800010ae <mappages>
    80001afe:	02054163          	bltz	a0,80001b20 <proc_pagetable+0x76>
}
    80001b02:	8526                	mv	a0,s1
    80001b04:	60e2                	ld	ra,24(sp)
    80001b06:	6442                	ld	s0,16(sp)
    80001b08:	64a2                	ld	s1,8(sp)
    80001b0a:	6902                	ld	s2,0(sp)
    80001b0c:	6105                	addi	sp,sp,32
    80001b0e:	8082                	ret
    uvmfree(pagetable, 0);
    80001b10:	4581                	li	a1,0
    80001b12:	8526                	mv	a0,s1
    80001b14:	00000097          	auipc	ra,0x0
    80001b18:	a20080e7          	jalr	-1504(ra) # 80001534 <uvmfree>
    return 0;
    80001b1c:	4481                	li	s1,0
    80001b1e:	b7d5                	j	80001b02 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b20:	4681                	li	a3,0
    80001b22:	4605                	li	a2,1
    80001b24:	040005b7          	lui	a1,0x4000
    80001b28:	15fd                	addi	a1,a1,-1
    80001b2a:	05b2                	slli	a1,a1,0xc
    80001b2c:	8526                	mv	a0,s1
    80001b2e:	fffff097          	auipc	ra,0xfffff
    80001b32:	746080e7          	jalr	1862(ra) # 80001274 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b36:	4581                	li	a1,0
    80001b38:	8526                	mv	a0,s1
    80001b3a:	00000097          	auipc	ra,0x0
    80001b3e:	9fa080e7          	jalr	-1542(ra) # 80001534 <uvmfree>
    return 0;
    80001b42:	4481                	li	s1,0
    80001b44:	bf7d                	j	80001b02 <proc_pagetable+0x58>

0000000080001b46 <proc_freepagetable>:
{
    80001b46:	1101                	addi	sp,sp,-32
    80001b48:	ec06                	sd	ra,24(sp)
    80001b4a:	e822                	sd	s0,16(sp)
    80001b4c:	e426                	sd	s1,8(sp)
    80001b4e:	e04a                	sd	s2,0(sp)
    80001b50:	1000                	addi	s0,sp,32
    80001b52:	84aa                	mv	s1,a0
    80001b54:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b56:	4681                	li	a3,0
    80001b58:	4605                	li	a2,1
    80001b5a:	040005b7          	lui	a1,0x4000
    80001b5e:	15fd                	addi	a1,a1,-1
    80001b60:	05b2                	slli	a1,a1,0xc
    80001b62:	fffff097          	auipc	ra,0xfffff
    80001b66:	712080e7          	jalr	1810(ra) # 80001274 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b6a:	4681                	li	a3,0
    80001b6c:	4605                	li	a2,1
    80001b6e:	020005b7          	lui	a1,0x2000
    80001b72:	15fd                	addi	a1,a1,-1
    80001b74:	05b6                	slli	a1,a1,0xd
    80001b76:	8526                	mv	a0,s1
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	6fc080e7          	jalr	1788(ra) # 80001274 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b80:	85ca                	mv	a1,s2
    80001b82:	8526                	mv	a0,s1
    80001b84:	00000097          	auipc	ra,0x0
    80001b88:	9b0080e7          	jalr	-1616(ra) # 80001534 <uvmfree>
}
    80001b8c:	60e2                	ld	ra,24(sp)
    80001b8e:	6442                	ld	s0,16(sp)
    80001b90:	64a2                	ld	s1,8(sp)
    80001b92:	6902                	ld	s2,0(sp)
    80001b94:	6105                	addi	sp,sp,32
    80001b96:	8082                	ret

0000000080001b98 <freeproc>:
{
    80001b98:	1101                	addi	sp,sp,-32
    80001b9a:	ec06                	sd	ra,24(sp)
    80001b9c:	e822                	sd	s0,16(sp)
    80001b9e:	e426                	sd	s1,8(sp)
    80001ba0:	1000                	addi	s0,sp,32
    80001ba2:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001ba4:	6d28                	ld	a0,88(a0)
    80001ba6:	c509                	beqz	a0,80001bb0 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001ba8:	fffff097          	auipc	ra,0xfffff
    80001bac:	e4e080e7          	jalr	-434(ra) # 800009f6 <kfree>
  p->trapframe = 0;
    80001bb0:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bb4:	68a8                	ld	a0,80(s1)
    80001bb6:	c511                	beqz	a0,80001bc2 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bb8:	64ac                	ld	a1,72(s1)
    80001bba:	00000097          	auipc	ra,0x0
    80001bbe:	f8c080e7          	jalr	-116(ra) # 80001b46 <proc_freepagetable>
  p->pagetable = 0;
    80001bc2:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bc6:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bca:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bce:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bd2:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bd6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bda:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bde:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001be2:	0004ac23          	sw	zero,24(s1)
}
    80001be6:	60e2                	ld	ra,24(sp)
    80001be8:	6442                	ld	s0,16(sp)
    80001bea:	64a2                	ld	s1,8(sp)
    80001bec:	6105                	addi	sp,sp,32
    80001bee:	8082                	ret

0000000080001bf0 <allocproc>:
{
    80001bf0:	1101                	addi	sp,sp,-32
    80001bf2:	ec06                	sd	ra,24(sp)
    80001bf4:	e822                	sd	s0,16(sp)
    80001bf6:	e426                	sd	s1,8(sp)
    80001bf8:	e04a                	sd	s2,0(sp)
    80001bfa:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bfc:	00011497          	auipc	s1,0x11
    80001c00:	b1448493          	addi	s1,s1,-1260 # 80012710 <proc>
    80001c04:	00017917          	auipc	s2,0x17
    80001c08:	f0c90913          	addi	s2,s2,-244 # 80018b10 <tickslock>
    acquire(&p->lock);
    80001c0c:	8526                	mv	a0,s1
    80001c0e:	fffff097          	auipc	ra,0xfffff
    80001c12:	fd4080e7          	jalr	-44(ra) # 80000be2 <acquire>
    if(p->state == UNUSED) {
    80001c16:	4c9c                	lw	a5,24(s1)
    80001c18:	cf81                	beqz	a5,80001c30 <allocproc+0x40>
      release(&p->lock);
    80001c1a:	8526                	mv	a0,s1
    80001c1c:	fffff097          	auipc	ra,0xfffff
    80001c20:	07a080e7          	jalr	122(ra) # 80000c96 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c24:	19048493          	addi	s1,s1,400
    80001c28:	ff2492e3          	bne	s1,s2,80001c0c <allocproc+0x1c>
  return 0;
    80001c2c:	4481                	li	s1,0
    80001c2e:	a055                	j	80001cd2 <allocproc+0xe2>
  p->pid = allocpid();
    80001c30:	00000097          	auipc	ra,0x0
    80001c34:	e34080e7          	jalr	-460(ra) # 80001a64 <allocpid>
    80001c38:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c3a:	4785                	li	a5,1
    80001c3c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c3e:	fffff097          	auipc	ra,0xfffff
    80001c42:	eb4080e7          	jalr	-332(ra) # 80000af2 <kalloc>
    80001c46:	892a                	mv	s2,a0
    80001c48:	eca8                	sd	a0,88(s1)
    80001c4a:	c959                	beqz	a0,80001ce0 <allocproc+0xf0>
  p->pagetable = proc_pagetable(p);
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	00000097          	auipc	ra,0x0
    80001c52:	e5c080e7          	jalr	-420(ra) # 80001aaa <proc_pagetable>
    80001c56:	892a                	mv	s2,a0
    80001c58:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c5a:	cd59                	beqz	a0,80001cf8 <allocproc+0x108>
  memset(&p->context, 0, sizeof(p->context));
    80001c5c:	07000613          	li	a2,112
    80001c60:	4581                	li	a1,0
    80001c62:	06048513          	addi	a0,s1,96
    80001c66:	fffff097          	auipc	ra,0xfffff
    80001c6a:	078080e7          	jalr	120(ra) # 80000cde <memset>
  p->context.ra = (uint64)forkret;
    80001c6e:	00000797          	auipc	a5,0x0
    80001c72:	d7878793          	addi	a5,a5,-648 # 800019e6 <forkret>
    80001c76:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c78:	60bc                	ld	a5,64(s1)
    80001c7a:	6705                	lui	a4,0x1
    80001c7c:	97ba                	add	a5,a5,a4
    80001c7e:	f4bc                	sd	a5,104(s1)
  acquire(&tickslock);
    80001c80:	00017517          	auipc	a0,0x17
    80001c84:	e9050513          	addi	a0,a0,-368 # 80018b10 <tickslock>
    80001c88:	fffff097          	auipc	ra,0xfffff
    80001c8c:	f5a080e7          	jalr	-166(ra) # 80000be2 <acquire>
  xticks = ticks;
    80001c90:	00008917          	auipc	s2,0x8
    80001c94:	3e092903          	lw	s2,992(s2) # 8000a070 <ticks>
  release(&tickslock);
    80001c98:	00017517          	auipc	a0,0x17
    80001c9c:	e7850513          	addi	a0,a0,-392 # 80018b10 <tickslock>
    80001ca0:	fffff097          	auipc	ra,0xfffff
    80001ca4:	ff6080e7          	jalr	-10(ra) # 80000c96 <release>
  p->ctime = xticks;
    80001ca8:	1724a423          	sw	s2,360(s1)
  p->stime = -1;
    80001cac:	57fd                	li	a5,-1
    80001cae:	16f4a623          	sw	a5,364(s1)
  p->endtime = -1;
    80001cb2:	16f4a823          	sw	a5,368(s1)
  p->start_ticks = 0;
    80001cb6:	1804a023          	sw	zero,384(s1)
  p->end_ticks = 0;
    80001cba:	1804a223          	sw	zero,388(s1)
  p->batch = 0;
    80001cbe:	1804a423          	sw	zero,392(s1)
  p->estimate = 0;
    80001cc2:	1804a623          	sw	zero,396(s1)
  p->cpu_usage = 0;
    80001cc6:	1604ae23          	sw	zero,380(s1)
  p->priority = 0;
    80001cca:	1604ac23          	sw	zero,376(s1)
  p-> prio = 0;
    80001cce:	1604aa23          	sw	zero,372(s1)
}
    80001cd2:	8526                	mv	a0,s1
    80001cd4:	60e2                	ld	ra,24(sp)
    80001cd6:	6442                	ld	s0,16(sp)
    80001cd8:	64a2                	ld	s1,8(sp)
    80001cda:	6902                	ld	s2,0(sp)
    80001cdc:	6105                	addi	sp,sp,32
    80001cde:	8082                	ret
    freeproc(p);
    80001ce0:	8526                	mv	a0,s1
    80001ce2:	00000097          	auipc	ra,0x0
    80001ce6:	eb6080e7          	jalr	-330(ra) # 80001b98 <freeproc>
    release(&p->lock);
    80001cea:	8526                	mv	a0,s1
    80001cec:	fffff097          	auipc	ra,0xfffff
    80001cf0:	faa080e7          	jalr	-86(ra) # 80000c96 <release>
    return 0;
    80001cf4:	84ca                	mv	s1,s2
    80001cf6:	bff1                	j	80001cd2 <allocproc+0xe2>
    freeproc(p);
    80001cf8:	8526                	mv	a0,s1
    80001cfa:	00000097          	auipc	ra,0x0
    80001cfe:	e9e080e7          	jalr	-354(ra) # 80001b98 <freeproc>
    release(&p->lock);
    80001d02:	8526                	mv	a0,s1
    80001d04:	fffff097          	auipc	ra,0xfffff
    80001d08:	f92080e7          	jalr	-110(ra) # 80000c96 <release>
    return 0;
    80001d0c:	84ca                	mv	s1,s2
    80001d0e:	b7d1                	j	80001cd2 <allocproc+0xe2>

0000000080001d10 <userinit>:
{
    80001d10:	1101                	addi	sp,sp,-32
    80001d12:	ec06                	sd	ra,24(sp)
    80001d14:	e822                	sd	s0,16(sp)
    80001d16:	e426                	sd	s1,8(sp)
    80001d18:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d1a:	00000097          	auipc	ra,0x0
    80001d1e:	ed6080e7          	jalr	-298(ra) # 80001bf0 <allocproc>
    80001d22:	84aa                	mv	s1,a0
  initproc = p;
    80001d24:	00008797          	auipc	a5,0x8
    80001d28:	34a7b223          	sd	a0,836(a5) # 8000a068 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d2c:	03400613          	li	a2,52
    80001d30:	00008597          	auipc	a1,0x8
    80001d34:	d5058593          	addi	a1,a1,-688 # 80009a80 <initcode>
    80001d38:	6928                	ld	a0,80(a0)
    80001d3a:	fffff097          	auipc	ra,0xfffff
    80001d3e:	62c080e7          	jalr	1580(ra) # 80001366 <uvminit>
  p->sz = PGSIZE;
    80001d42:	6785                	lui	a5,0x1
    80001d44:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d46:	6cb8                	ld	a4,88(s1)
    80001d48:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d4c:	6cb8                	ld	a4,88(s1)
    80001d4e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d50:	4641                	li	a2,16
    80001d52:	00007597          	auipc	a1,0x7
    80001d56:	4ae58593          	addi	a1,a1,1198 # 80009200 <digits+0x1c0>
    80001d5a:	15848513          	addi	a0,s1,344
    80001d5e:	fffff097          	auipc	ra,0xfffff
    80001d62:	0d2080e7          	jalr	210(ra) # 80000e30 <safestrcpy>
  p->cwd = namei("/");
    80001d66:	00007517          	auipc	a0,0x7
    80001d6a:	4aa50513          	addi	a0,a0,1194 # 80009210 <digits+0x1d0>
    80001d6e:	00003097          	auipc	ra,0x3
    80001d72:	22e080e7          	jalr	558(ra) # 80004f9c <namei>
    80001d76:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d7a:	478d                	li	a5,3
    80001d7c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d7e:	8526                	mv	a0,s1
    80001d80:	fffff097          	auipc	ra,0xfffff
    80001d84:	f16080e7          	jalr	-234(ra) # 80000c96 <release>
}
    80001d88:	60e2                	ld	ra,24(sp)
    80001d8a:	6442                	ld	s0,16(sp)
    80001d8c:	64a2                	ld	s1,8(sp)
    80001d8e:	6105                	addi	sp,sp,32
    80001d90:	8082                	ret

0000000080001d92 <growproc>:
{
    80001d92:	1101                	addi	sp,sp,-32
    80001d94:	ec06                	sd	ra,24(sp)
    80001d96:	e822                	sd	s0,16(sp)
    80001d98:	e426                	sd	s1,8(sp)
    80001d9a:	e04a                	sd	s2,0(sp)
    80001d9c:	1000                	addi	s0,sp,32
    80001d9e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001da0:	00000097          	auipc	ra,0x0
    80001da4:	c0e080e7          	jalr	-1010(ra) # 800019ae <myproc>
    80001da8:	892a                	mv	s2,a0
  sz = p->sz;
    80001daa:	652c                	ld	a1,72(a0)
    80001dac:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001db0:	00904f63          	bgtz	s1,80001dce <growproc+0x3c>
  } else if(n < 0){
    80001db4:	0204cc63          	bltz	s1,80001dec <growproc+0x5a>
  p->sz = sz;
    80001db8:	1602                	slli	a2,a2,0x20
    80001dba:	9201                	srli	a2,a2,0x20
    80001dbc:	04c93423          	sd	a2,72(s2)
  return 0;
    80001dc0:	4501                	li	a0,0
}
    80001dc2:	60e2                	ld	ra,24(sp)
    80001dc4:	6442                	ld	s0,16(sp)
    80001dc6:	64a2                	ld	s1,8(sp)
    80001dc8:	6902                	ld	s2,0(sp)
    80001dca:	6105                	addi	sp,sp,32
    80001dcc:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dce:	9e25                	addw	a2,a2,s1
    80001dd0:	1602                	slli	a2,a2,0x20
    80001dd2:	9201                	srli	a2,a2,0x20
    80001dd4:	1582                	slli	a1,a1,0x20
    80001dd6:	9181                	srli	a1,a1,0x20
    80001dd8:	6928                	ld	a0,80(a0)
    80001dda:	fffff097          	auipc	ra,0xfffff
    80001dde:	646080e7          	jalr	1606(ra) # 80001420 <uvmalloc>
    80001de2:	0005061b          	sext.w	a2,a0
    80001de6:	fa69                	bnez	a2,80001db8 <growproc+0x26>
      return -1;
    80001de8:	557d                	li	a0,-1
    80001dea:	bfe1                	j	80001dc2 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dec:	9e25                	addw	a2,a2,s1
    80001dee:	1602                	slli	a2,a2,0x20
    80001df0:	9201                	srli	a2,a2,0x20
    80001df2:	1582                	slli	a1,a1,0x20
    80001df4:	9181                	srli	a1,a1,0x20
    80001df6:	6928                	ld	a0,80(a0)
    80001df8:	fffff097          	auipc	ra,0xfffff
    80001dfc:	5e0080e7          	jalr	1504(ra) # 800013d8 <uvmdealloc>
    80001e00:	0005061b          	sext.w	a2,a0
    80001e04:	bf55                	j	80001db8 <growproc+0x26>

0000000080001e06 <fork>:
{
    80001e06:	7179                	addi	sp,sp,-48
    80001e08:	f406                	sd	ra,40(sp)
    80001e0a:	f022                	sd	s0,32(sp)
    80001e0c:	ec26                	sd	s1,24(sp)
    80001e0e:	e84a                	sd	s2,16(sp)
    80001e10:	e44e                	sd	s3,8(sp)
    80001e12:	e052                	sd	s4,0(sp)
    80001e14:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e16:	00000097          	auipc	ra,0x0
    80001e1a:	b98080e7          	jalr	-1128(ra) # 800019ae <myproc>
    80001e1e:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001e20:	00000097          	auipc	ra,0x0
    80001e24:	dd0080e7          	jalr	-560(ra) # 80001bf0 <allocproc>
    80001e28:	10050d63          	beqz	a0,80001f42 <fork+0x13c>
    80001e2c:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e2e:	04893603          	ld	a2,72(s2)
    80001e32:	692c                	ld	a1,80(a0)
    80001e34:	05093503          	ld	a0,80(s2)
    80001e38:	fffff097          	auipc	ra,0xfffff
    80001e3c:	734080e7          	jalr	1844(ra) # 8000156c <uvmcopy>
    80001e40:	04054863          	bltz	a0,80001e90 <fork+0x8a>
  np->sz = p->sz;
    80001e44:	04893783          	ld	a5,72(s2)
    80001e48:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e4c:	05893683          	ld	a3,88(s2)
    80001e50:	87b6                	mv	a5,a3
    80001e52:	0589b703          	ld	a4,88(s3)
    80001e56:	12068693          	addi	a3,a3,288
    80001e5a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e5e:	6788                	ld	a0,8(a5)
    80001e60:	6b8c                	ld	a1,16(a5)
    80001e62:	6f90                	ld	a2,24(a5)
    80001e64:	01073023          	sd	a6,0(a4)
    80001e68:	e708                	sd	a0,8(a4)
    80001e6a:	eb0c                	sd	a1,16(a4)
    80001e6c:	ef10                	sd	a2,24(a4)
    80001e6e:	02078793          	addi	a5,a5,32
    80001e72:	02070713          	addi	a4,a4,32
    80001e76:	fed792e3          	bne	a5,a3,80001e5a <fork+0x54>
  np->trapframe->a0 = 0;
    80001e7a:	0589b783          	ld	a5,88(s3)
    80001e7e:	0607b823          	sd	zero,112(a5)
  np->batch = 0;
    80001e82:	1809a423          	sw	zero,392(s3)
    80001e86:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001e8a:	15000a13          	li	s4,336
    80001e8e:	a03d                	j	80001ebc <fork+0xb6>
    freeproc(np);
    80001e90:	854e                	mv	a0,s3
    80001e92:	00000097          	auipc	ra,0x0
    80001e96:	d06080e7          	jalr	-762(ra) # 80001b98 <freeproc>
    release(&np->lock);
    80001e9a:	854e                	mv	a0,s3
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	dfa080e7          	jalr	-518(ra) # 80000c96 <release>
    return -1;
    80001ea4:	5a7d                	li	s4,-1
    80001ea6:	a069                	j	80001f30 <fork+0x12a>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ea8:	00003097          	auipc	ra,0x3
    80001eac:	78a080e7          	jalr	1930(ra) # 80005632 <filedup>
    80001eb0:	009987b3          	add	a5,s3,s1
    80001eb4:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001eb6:	04a1                	addi	s1,s1,8
    80001eb8:	01448763          	beq	s1,s4,80001ec6 <fork+0xc0>
    if(p->ofile[i])
    80001ebc:	009907b3          	add	a5,s2,s1
    80001ec0:	6388                	ld	a0,0(a5)
    80001ec2:	f17d                	bnez	a0,80001ea8 <fork+0xa2>
    80001ec4:	bfcd                	j	80001eb6 <fork+0xb0>
  np->cwd = idup(p->cwd);
    80001ec6:	15093503          	ld	a0,336(s2)
    80001eca:	00003097          	auipc	ra,0x3
    80001ece:	8de080e7          	jalr	-1826(ra) # 800047a8 <idup>
    80001ed2:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed6:	4641                	li	a2,16
    80001ed8:	15890593          	addi	a1,s2,344
    80001edc:	15898513          	addi	a0,s3,344
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	f50080e7          	jalr	-176(ra) # 80000e30 <safestrcpy>
  pid = np->pid;
    80001ee8:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001eec:	854e                	mv	a0,s3
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	da8080e7          	jalr	-600(ra) # 80000c96 <release>
  acquire(&wait_lock);
    80001ef6:	00010497          	auipc	s1,0x10
    80001efa:	40248493          	addi	s1,s1,1026 # 800122f8 <wait_lock>
    80001efe:	8526                	mv	a0,s1
    80001f00:	fffff097          	auipc	ra,0xfffff
    80001f04:	ce2080e7          	jalr	-798(ra) # 80000be2 <acquire>
  np->parent = p;
    80001f08:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	d88080e7          	jalr	-632(ra) # 80000c96 <release>
  acquire(&np->lock);
    80001f16:	854e                	mv	a0,s3
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	cca080e7          	jalr	-822(ra) # 80000be2 <acquire>
  np->state = RUNNABLE;
    80001f20:	478d                	li	a5,3
    80001f22:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f26:	854e                	mv	a0,s3
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	d6e080e7          	jalr	-658(ra) # 80000c96 <release>
}
    80001f30:	8552                	mv	a0,s4
    80001f32:	70a2                	ld	ra,40(sp)
    80001f34:	7402                	ld	s0,32(sp)
    80001f36:	64e2                	ld	s1,24(sp)
    80001f38:	6942                	ld	s2,16(sp)
    80001f3a:	69a2                	ld	s3,8(sp)
    80001f3c:	6a02                	ld	s4,0(sp)
    80001f3e:	6145                	addi	sp,sp,48
    80001f40:	8082                	ret
    return -1;
    80001f42:	5a7d                	li	s4,-1
    80001f44:	b7f5                	j	80001f30 <fork+0x12a>

0000000080001f46 <forkp>:
{
    80001f46:	7179                	addi	sp,sp,-48
    80001f48:	f406                	sd	ra,40(sp)
    80001f4a:	f022                	sd	s0,32(sp)
    80001f4c:	ec26                	sd	s1,24(sp)
    80001f4e:	e84a                	sd	s2,16(sp)
    80001f50:	e44e                	sd	s3,8(sp)
    80001f52:	e052                	sd	s4,0(sp)
    80001f54:	1800                	addi	s0,sp,48
    80001f56:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f58:	00000097          	auipc	ra,0x0
    80001f5c:	a56080e7          	jalr	-1450(ra) # 800019ae <myproc>
    80001f60:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    80001f62:	00000097          	auipc	ra,0x0
    80001f66:	c8e080e7          	jalr	-882(ra) # 80001bf0 <allocproc>
    80001f6a:	14050063          	beqz	a0,800020aa <forkp+0x164>
    80001f6e:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f70:	0489b603          	ld	a2,72(s3)
    80001f74:	692c                	ld	a1,80(a0)
    80001f76:	0509b503          	ld	a0,80(s3)
    80001f7a:	fffff097          	auipc	ra,0xfffff
    80001f7e:	5f2080e7          	jalr	1522(ra) # 8000156c <uvmcopy>
    80001f82:	06054b63          	bltz	a0,80001ff8 <forkp+0xb2>
  np->sz = p->sz;
    80001f86:	0489b783          	ld	a5,72(s3)
    80001f8a:	04f93423          	sd	a5,72(s2)
  *(np->trapframe) = *(p->trapframe);
    80001f8e:	0589b683          	ld	a3,88(s3)
    80001f92:	87b6                	mv	a5,a3
    80001f94:	05893703          	ld	a4,88(s2)
    80001f98:	12068693          	addi	a3,a3,288
    80001f9c:	0007b883          	ld	a7,0(a5)
    80001fa0:	0087b803          	ld	a6,8(a5)
    80001fa4:	6b8c                	ld	a1,16(a5)
    80001fa6:	6f90                	ld	a2,24(a5)
    80001fa8:	01173023          	sd	a7,0(a4)
    80001fac:	01073423          	sd	a6,8(a4)
    80001fb0:	eb0c                	sd	a1,16(a4)
    80001fb2:	ef10                	sd	a2,24(a4)
    80001fb4:	02078793          	addi	a5,a5,32
    80001fb8:	02070713          	addi	a4,a4,32
    80001fbc:	fed790e3          	bne	a5,a3,80001f9c <forkp+0x56>
  np->trapframe->a0 = 0;
    80001fc0:	05893783          	ld	a5,88(s2)
    80001fc4:	0607b823          	sd	zero,112(a5)
  np->prio = prio;
    80001fc8:	16992a23          	sw	s1,372(s2)
  curr_batch ++ ;
    80001fcc:	00008717          	auipc	a4,0x8
    80001fd0:	09470713          	addi	a4,a4,148 # 8000a060 <curr_batch>
    80001fd4:	431c                	lw	a5,0(a4)
    80001fd6:	2785                	addiw	a5,a5,1
    80001fd8:	c31c                	sw	a5,0(a4)
  net_batch ++;
    80001fda:	00008717          	auipc	a4,0x8
    80001fde:	08270713          	addi	a4,a4,130 # 8000a05c <net_batch>
    80001fe2:	431c                	lw	a5,0(a4)
    80001fe4:	2785                	addiw	a5,a5,1
    80001fe6:	c31c                	sw	a5,0(a4)
  np->batch = 1;
    80001fe8:	4785                	li	a5,1
    80001fea:	18f92423          	sw	a5,392(s2)
    80001fee:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001ff2:	15000a13          	li	s4,336
    80001ff6:	a03d                	j	80002024 <forkp+0xde>
    freeproc(np);
    80001ff8:	854a                	mv	a0,s2
    80001ffa:	00000097          	auipc	ra,0x0
    80001ffe:	b9e080e7          	jalr	-1122(ra) # 80001b98 <freeproc>
    release(&np->lock);
    80002002:	854a                	mv	a0,s2
    80002004:	fffff097          	auipc	ra,0xfffff
    80002008:	c92080e7          	jalr	-878(ra) # 80000c96 <release>
    return -1;
    8000200c:	5a7d                	li	s4,-1
    8000200e:	a069                	j	80002098 <forkp+0x152>
      np->ofile[i] = filedup(p->ofile[i]);
    80002010:	00003097          	auipc	ra,0x3
    80002014:	622080e7          	jalr	1570(ra) # 80005632 <filedup>
    80002018:	009907b3          	add	a5,s2,s1
    8000201c:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    8000201e:	04a1                	addi	s1,s1,8
    80002020:	01448763          	beq	s1,s4,8000202e <forkp+0xe8>
    if(p->ofile[i])
    80002024:	009987b3          	add	a5,s3,s1
    80002028:	6388                	ld	a0,0(a5)
    8000202a:	f17d                	bnez	a0,80002010 <forkp+0xca>
    8000202c:	bfcd                	j	8000201e <forkp+0xd8>
  np->cwd = idup(p->cwd);
    8000202e:	1509b503          	ld	a0,336(s3)
    80002032:	00002097          	auipc	ra,0x2
    80002036:	776080e7          	jalr	1910(ra) # 800047a8 <idup>
    8000203a:	14a93823          	sd	a0,336(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000203e:	4641                	li	a2,16
    80002040:	15898593          	addi	a1,s3,344
    80002044:	15890513          	addi	a0,s2,344
    80002048:	fffff097          	auipc	ra,0xfffff
    8000204c:	de8080e7          	jalr	-536(ra) # 80000e30 <safestrcpy>
  pid = np->pid;
    80002050:	03092a03          	lw	s4,48(s2)
  release(&np->lock);
    80002054:	854a                	mv	a0,s2
    80002056:	fffff097          	auipc	ra,0xfffff
    8000205a:	c40080e7          	jalr	-960(ra) # 80000c96 <release>
  acquire(&wait_lock);
    8000205e:	00010497          	auipc	s1,0x10
    80002062:	29a48493          	addi	s1,s1,666 # 800122f8 <wait_lock>
    80002066:	8526                	mv	a0,s1
    80002068:	fffff097          	auipc	ra,0xfffff
    8000206c:	b7a080e7          	jalr	-1158(ra) # 80000be2 <acquire>
  np->parent = p;
    80002070:	03393c23          	sd	s3,56(s2)
  release(&wait_lock);
    80002074:	8526                	mv	a0,s1
    80002076:	fffff097          	auipc	ra,0xfffff
    8000207a:	c20080e7          	jalr	-992(ra) # 80000c96 <release>
  acquire(&np->lock);
    8000207e:	854a                	mv	a0,s2
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	b62080e7          	jalr	-1182(ra) # 80000be2 <acquire>
  np->state = RUNNABLE;
    80002088:	478d                	li	a5,3
    8000208a:	00f92c23          	sw	a5,24(s2)
  release(&np->lock);
    8000208e:	854a                	mv	a0,s2
    80002090:	fffff097          	auipc	ra,0xfffff
    80002094:	c06080e7          	jalr	-1018(ra) # 80000c96 <release>
}
    80002098:	8552                	mv	a0,s4
    8000209a:	70a2                	ld	ra,40(sp)
    8000209c:	7402                	ld	s0,32(sp)
    8000209e:	64e2                	ld	s1,24(sp)
    800020a0:	6942                	ld	s2,16(sp)
    800020a2:	69a2                	ld	s3,8(sp)
    800020a4:	6a02                	ld	s4,0(sp)
    800020a6:	6145                	addi	sp,sp,48
    800020a8:	8082                	ret
    return -1;
    800020aa:	5a7d                	li	s4,-1
    800020ac:	b7f5                	j	80002098 <forkp+0x152>

00000000800020ae <forkf>:
{
    800020ae:	7179                	addi	sp,sp,-48
    800020b0:	f406                	sd	ra,40(sp)
    800020b2:	f022                	sd	s0,32(sp)
    800020b4:	ec26                	sd	s1,24(sp)
    800020b6:	e84a                	sd	s2,16(sp)
    800020b8:	e44e                	sd	s3,8(sp)
    800020ba:	e052                	sd	s4,0(sp)
    800020bc:	1800                	addi	s0,sp,48
    800020be:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800020c0:	00000097          	auipc	ra,0x0
    800020c4:	8ee080e7          	jalr	-1810(ra) # 800019ae <myproc>
    800020c8:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    800020ca:	00000097          	auipc	ra,0x0
    800020ce:	b26080e7          	jalr	-1242(ra) # 80001bf0 <allocproc>
    800020d2:	12050263          	beqz	a0,800021f6 <forkf+0x148>
    800020d6:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800020d8:	0489b603          	ld	a2,72(s3)
    800020dc:	692c                	ld	a1,80(a0)
    800020de:	0509b503          	ld	a0,80(s3)
    800020e2:	fffff097          	auipc	ra,0xfffff
    800020e6:	48a080e7          	jalr	1162(ra) # 8000156c <uvmcopy>
    800020ea:	04054d63          	bltz	a0,80002144 <forkf+0x96>
  np->sz = p->sz;
    800020ee:	0489b783          	ld	a5,72(s3)
    800020f2:	04f93423          	sd	a5,72(s2)
  *(np->trapframe) = *(p->trapframe);
    800020f6:	0589b683          	ld	a3,88(s3)
    800020fa:	87b6                	mv	a5,a3
    800020fc:	05893703          	ld	a4,88(s2)
    80002100:	12068693          	addi	a3,a3,288
    80002104:	0007b883          	ld	a7,0(a5)
    80002108:	0087b803          	ld	a6,8(a5)
    8000210c:	6b8c                	ld	a1,16(a5)
    8000210e:	6f90                	ld	a2,24(a5)
    80002110:	01173023          	sd	a7,0(a4)
    80002114:	01073423          	sd	a6,8(a4)
    80002118:	eb0c                	sd	a1,16(a4)
    8000211a:	ef10                	sd	a2,24(a4)
    8000211c:	02078793          	addi	a5,a5,32
    80002120:	02070713          	addi	a4,a4,32
    80002124:	fed790e3          	bne	a5,a3,80002104 <forkf+0x56>
  np->trapframe->a0 = 0;
    80002128:	05893783          	ld	a5,88(s2)
    8000212c:	0607b823          	sd	zero,112(a5)
  np->trapframe->epc = faddr;
    80002130:	05893783          	ld	a5,88(s2)
    80002134:	ef84                	sd	s1,24(a5)
  np->batch = 0;
    80002136:	18092423          	sw	zero,392(s2)
    8000213a:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    8000213e:	15000a13          	li	s4,336
    80002142:	a03d                	j	80002170 <forkf+0xc2>
    freeproc(np);
    80002144:	854a                	mv	a0,s2
    80002146:	00000097          	auipc	ra,0x0
    8000214a:	a52080e7          	jalr	-1454(ra) # 80001b98 <freeproc>
    release(&np->lock);
    8000214e:	854a                	mv	a0,s2
    80002150:	fffff097          	auipc	ra,0xfffff
    80002154:	b46080e7          	jalr	-1210(ra) # 80000c96 <release>
    return -1;
    80002158:	5a7d                	li	s4,-1
    8000215a:	a069                	j	800021e4 <forkf+0x136>
      np->ofile[i] = filedup(p->ofile[i]);
    8000215c:	00003097          	auipc	ra,0x3
    80002160:	4d6080e7          	jalr	1238(ra) # 80005632 <filedup>
    80002164:	009907b3          	add	a5,s2,s1
    80002168:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    8000216a:	04a1                	addi	s1,s1,8
    8000216c:	01448763          	beq	s1,s4,8000217a <forkf+0xcc>
    if(p->ofile[i])
    80002170:	009987b3          	add	a5,s3,s1
    80002174:	6388                	ld	a0,0(a5)
    80002176:	f17d                	bnez	a0,8000215c <forkf+0xae>
    80002178:	bfcd                	j	8000216a <forkf+0xbc>
  np->cwd = idup(p->cwd);
    8000217a:	1509b503          	ld	a0,336(s3)
    8000217e:	00002097          	auipc	ra,0x2
    80002182:	62a080e7          	jalr	1578(ra) # 800047a8 <idup>
    80002186:	14a93823          	sd	a0,336(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000218a:	4641                	li	a2,16
    8000218c:	15898593          	addi	a1,s3,344
    80002190:	15890513          	addi	a0,s2,344
    80002194:	fffff097          	auipc	ra,0xfffff
    80002198:	c9c080e7          	jalr	-868(ra) # 80000e30 <safestrcpy>
  pid = np->pid;
    8000219c:	03092a03          	lw	s4,48(s2)
  release(&np->lock);
    800021a0:	854a                	mv	a0,s2
    800021a2:	fffff097          	auipc	ra,0xfffff
    800021a6:	af4080e7          	jalr	-1292(ra) # 80000c96 <release>
  acquire(&wait_lock);
    800021aa:	00010497          	auipc	s1,0x10
    800021ae:	14e48493          	addi	s1,s1,334 # 800122f8 <wait_lock>
    800021b2:	8526                	mv	a0,s1
    800021b4:	fffff097          	auipc	ra,0xfffff
    800021b8:	a2e080e7          	jalr	-1490(ra) # 80000be2 <acquire>
  np->parent = p;
    800021bc:	03393c23          	sd	s3,56(s2)
  release(&wait_lock);
    800021c0:	8526                	mv	a0,s1
    800021c2:	fffff097          	auipc	ra,0xfffff
    800021c6:	ad4080e7          	jalr	-1324(ra) # 80000c96 <release>
  acquire(&np->lock);
    800021ca:	854a                	mv	a0,s2
    800021cc:	fffff097          	auipc	ra,0xfffff
    800021d0:	a16080e7          	jalr	-1514(ra) # 80000be2 <acquire>
  np->state = RUNNABLE;
    800021d4:	478d                	li	a5,3
    800021d6:	00f92c23          	sw	a5,24(s2)
  release(&np->lock);
    800021da:	854a                	mv	a0,s2
    800021dc:	fffff097          	auipc	ra,0xfffff
    800021e0:	aba080e7          	jalr	-1350(ra) # 80000c96 <release>
}
    800021e4:	8552                	mv	a0,s4
    800021e6:	70a2                	ld	ra,40(sp)
    800021e8:	7402                	ld	s0,32(sp)
    800021ea:	64e2                	ld	s1,24(sp)
    800021ec:	6942                	ld	s2,16(sp)
    800021ee:	69a2                	ld	s3,8(sp)
    800021f0:	6a02                	ld	s4,0(sp)
    800021f2:	6145                	addi	sp,sp,48
    800021f4:	8082                	ret
    return -1;
    800021f6:	5a7d                	li	s4,-1
    800021f8:	b7f5                	j	800021e4 <forkf+0x136>

00000000800021fa <scheduler>:
{
    800021fa:	711d                	addi	sp,sp,-96
    800021fc:	ec86                	sd	ra,88(sp)
    800021fe:	e8a2                	sd	s0,80(sp)
    80002200:	e4a6                	sd	s1,72(sp)
    80002202:	e0ca                	sd	s2,64(sp)
    80002204:	fc4e                	sd	s3,56(sp)
    80002206:	f852                	sd	s4,48(sp)
    80002208:	f456                	sd	s5,40(sp)
    8000220a:	f05a                	sd	s6,32(sp)
    8000220c:	ec5e                	sd	s7,24(sp)
    8000220e:	e862                	sd	s8,16(sp)
    80002210:	e466                	sd	s9,8(sp)
    80002212:	e06a                	sd	s10,0(sp)
    80002214:	1080                	addi	s0,sp,96
    80002216:	8792                	mv	a5,tp
  int id = r_tp();
    80002218:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000221a:	00779b93          	slli	s7,a5,0x7
    8000221e:	00010717          	auipc	a4,0x10
    80002222:	0c270713          	addi	a4,a4,194 # 800122e0 <pid_lock>
    80002226:	975e                	add	a4,a4,s7
    80002228:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000222c:	00010717          	auipc	a4,0x10
    80002230:	0ec70713          	addi	a4,a4,236 # 80012318 <cpus+0x8>
    80002234:	9bba                	add	s7,s7,a4
      if(SCHED_POLICY != OLD_POLICY){
    80002236:	00008917          	auipc	s2,0x8
    8000223a:	83e90913          	addi	s2,s2,-1986 # 80009a74 <SCHED_POLICY>
        c->proc = p;
    8000223e:	079e                	slli	a5,a5,0x7
    80002240:	00010a17          	auipc	s4,0x10
    80002244:	0a0a0a13          	addi	s4,s4,160 # 800122e0 <pid_lock>
    80002248:	9a3e                	add	s4,s4,a5
        if(est_max == 0){
    8000224a:	00008c17          	auipc	s8,0x8
    8000224e:	dfac0c13          	addi	s8,s8,-518 # 8000a044 <est_max>
      if(SCHED_POLICY != OLD_POLICY){
    80002252:	00008997          	auipc	s3,0x8
    80002256:	81e98993          	addi	s3,s3,-2018 # 80009a70 <OLD_POLICY>
    8000225a:	a019                	j	80002260 <scheduler+0x66>
        OLD_POLICY = SCHED_POLICY;
    8000225c:	00f9a023          	sw	a5,0(s3)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002260:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002264:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002268:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000226c:	00010497          	auipc	s1,0x10
    80002270:	4a448493          	addi	s1,s1,1188 # 80012710 <proc>
          if(mi_est == 0){
    80002274:	00008b17          	auipc	s6,0x8
    80002278:	dccb0b13          	addi	s6,s6,-564 # 8000a040 <mi_est>
          sum_est += p->estimate;
    8000227c:	00008a97          	auipc	s5,0x8
    80002280:	dc0a8a93          	addi	s5,s5,-576 # 8000a03c <sum_est>
    80002284:	a05d                	j	8000232a <scheduler+0x130>
          if(SCHED_POLICY == SCHED_NPREEMPT_SJF && min_burst < p->estimate && min_burst !=0 ){
    80002286:	00008797          	auipc	a5,0x8
    8000228a:	daa7a783          	lw	a5,-598(a5) # 8000a030 <min_burst>
    8000228e:	18c4a703          	lw	a4,396(s1)
    80002292:	00e7f363          	bgeu	a5,a4,80002298 <scheduler+0x9e>
    80002296:	e7f5                	bnez	a5,80002382 <scheduler+0x188>
        if(est_max == 0){
    80002298:	000c2783          	lw	a5,0(s8)
    8000229c:	ebed                	bnez	a5,8000238e <scheduler+0x194>
            est_max = p->estimate;
    8000229e:	18c4a783          	lw	a5,396(s1)
    800022a2:	00fc2023          	sw	a5,0(s8)
          if(mi_est == 0){
    800022a6:	000b2783          	lw	a5,0(s6)
    800022aa:	ebed                	bnez	a5,8000239c <scheduler+0x1a2>
            mi_est = p->estimate;
    800022ac:	18c4a783          	lw	a5,396(s1)
    800022b0:	00fb2023          	sw	a5,0(s6)
          sum_est += p->estimate;
    800022b4:	18c4a783          	lw	a5,396(s1)
    800022b8:	000aa703          	lw	a4,0(s5)
    800022bc:	9fb9                	addw	a5,a5,a4
    800022be:	00faa023          	sw	a5,0(s5)
        if (!holding(&tickslock)) {
    800022c2:	00017517          	auipc	a0,0x17
    800022c6:	84e50513          	addi	a0,a0,-1970 # 80018b10 <tickslock>
    800022ca:	fffff097          	auipc	ra,0xfffff
    800022ce:	89e080e7          	jalr	-1890(ra) # 80000b68 <holding>
    800022d2:	cd61                	beqz	a0,800023aa <scheduler+0x1b0>
        else xticks = ticks;
    800022d4:	00008d17          	auipc	s10,0x8
    800022d8:	d9cd2d03          	lw	s10,-612(s10) # 8000a070 <ticks>
        p->start_ticks = xticks;
    800022dc:	19a4a023          	sw	s10,384(s1)
        wait_sum += p->start_ticks - p->end_ticks;
    800022e0:	00008717          	auipc	a4,0x8
    800022e4:	d7870713          	addi	a4,a4,-648 # 8000a058 <wait_sum>
    800022e8:	431c                	lw	a5,0(a4)
    800022ea:	1844a683          	lw	a3,388(s1)
    800022ee:	9f95                	subw	a5,a5,a3
    800022f0:	01a787bb          	addw	a5,a5,s10
    800022f4:	c31c                	sw	a5,0(a4)
        p->state = RUNNING;
    800022f6:	4791                	li	a5,4
    800022f8:	cc9c                	sw	a5,24(s1)
        c->proc = p;
    800022fa:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800022fe:	060c8593          	addi	a1,s9,96
    80002302:	855e                	mv	a0,s7
    80002304:	00001097          	auipc	ra,0x1
    80002308:	24e080e7          	jalr	590(ra) # 80003552 <swtch>
        c->proc = 0;
    8000230c:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    80002310:	8526                	mv	a0,s1
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	984080e7          	jalr	-1660(ra) # 80000c96 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000231a:	19048493          	addi	s1,s1,400
    8000231e:	00016797          	auipc	a5,0x16
    80002322:	7f278793          	addi	a5,a5,2034 # 80018b10 <tickslock>
    80002326:	f2f48de3          	beq	s1,a5,80002260 <scheduler+0x66>
      if(SCHED_POLICY != OLD_POLICY){
    8000232a:	00092783          	lw	a5,0(s2)
    8000232e:	0009a703          	lw	a4,0(s3)
    80002332:	f2f715e3          	bne	a4,a5,8000225c <scheduler+0x62>
      acquire(&p->lock);
    80002336:	8ca6                	mv	s9,s1
    80002338:	8526                	mv	a0,s1
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	8a8080e7          	jalr	-1880(ra) # 80000be2 <acquire>
      if(p->state == RUNNABLE) {
    80002342:	4c98                	lw	a4,24(s1)
    80002344:	478d                	li	a5,3
    80002346:	fcf715e3          	bne	a4,a5,80002310 <scheduler+0x116>
        if(p->batch==1){
    8000234a:	1884a703          	lw	a4,392(s1)
    8000234e:	4785                	li	a5,1
    80002350:	faf713e3          	bne	a4,a5,800022f6 <scheduler+0xfc>
          if(SCHED_POLICY == SCHED_NPREEMPT_SJF && min_burst < p->estimate && min_burst !=0 ){
    80002354:	00092783          	lw	a5,0(s2)
    80002358:	4705                	li	a4,1
    8000235a:	f2e786e3          	beq	a5,a4,80002286 <scheduler+0x8c>
        if(SCHED_POLICY == SCHED_PREEMPT_UNIX && min_prio < p->priority && min_prio != 0){
    8000235e:	470d                	li	a4,3
    80002360:	f2e79ce3          	bne	a5,a4,80002298 <scheduler+0x9e>
    80002364:	00008797          	auipc	a5,0x8
    80002368:	cc87a783          	lw	a5,-824(a5) # 8000a02c <min_prio>
    8000236c:	1784a703          	lw	a4,376(s1)
    80002370:	f2e7d4e3          	bge	a5,a4,80002298 <scheduler+0x9e>
    80002374:	d395                	beqz	a5,80002298 <scheduler+0x9e>
          release(&p->lock);
    80002376:	8526                	mv	a0,s1
    80002378:	fffff097          	auipc	ra,0xfffff
    8000237c:	91e080e7          	jalr	-1762(ra) # 80000c96 <release>
          continue;
    80002380:	bf69                	j	8000231a <scheduler+0x120>
          release(&p->lock);
    80002382:	8526                	mv	a0,s1
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	912080e7          	jalr	-1774(ra) # 80000c96 <release>
          continue;
    8000238c:	b779                	j	8000231a <scheduler+0x120>
          else if(est_max < p->estimate){
    8000238e:	18c4a703          	lw	a4,396(s1)
    80002392:	f0e7fae3          	bgeu	a5,a4,800022a6 <scheduler+0xac>
            est_max = p->estimate;
    80002396:	00ec2023          	sw	a4,0(s8)
    8000239a:	b731                	j	800022a6 <scheduler+0xac>
          else if(mi_est > p->estimate){
    8000239c:	18c4a703          	lw	a4,396(s1)
    800023a0:	f0f77ae3          	bgeu	a4,a5,800022b4 <scheduler+0xba>
            mi_est = p->estimate;
    800023a4:	00eb2023          	sw	a4,0(s6)
    800023a8:	b731                	j	800022b4 <scheduler+0xba>
            acquire(&tickslock);
    800023aa:	00016517          	auipc	a0,0x16
    800023ae:	76650513          	addi	a0,a0,1894 # 80018b10 <tickslock>
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	830080e7          	jalr	-2000(ra) # 80000be2 <acquire>
            xticks = ticks;
    800023ba:	00008d17          	auipc	s10,0x8
    800023be:	cb6d2d03          	lw	s10,-842(s10) # 8000a070 <ticks>
            release(&tickslock);
    800023c2:	00016517          	auipc	a0,0x16
    800023c6:	74e50513          	addi	a0,a0,1870 # 80018b10 <tickslock>
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	8cc080e7          	jalr	-1844(ra) # 80000c96 <release>
    800023d2:	b729                	j	800022dc <scheduler+0xe2>

00000000800023d4 <schedpolicy>:
{
    800023d4:	1141                	addi	sp,sp,-16
    800023d6:	e422                	sd	s0,8(sp)
    800023d8:	0800                	addi	s0,sp,16
  OLD_POLICY = SCHED_POLICY;
    800023da:	00007717          	auipc	a4,0x7
    800023de:	69a70713          	addi	a4,a4,1690 # 80009a74 <SCHED_POLICY>
    800023e2:	431c                	lw	a5,0(a4)
    800023e4:	00007697          	auipc	a3,0x7
    800023e8:	68f6a623          	sw	a5,1676(a3) # 80009a70 <OLD_POLICY>
  SCHED_POLICY = new_sched;
    800023ec:	c308                	sw	a0,0(a4)
}
    800023ee:	853e                	mv	a0,a5
    800023f0:	6422                	ld	s0,8(sp)
    800023f2:	0141                	addi	sp,sp,16
    800023f4:	8082                	ret

00000000800023f6 <sched>:
{
    800023f6:	7179                	addi	sp,sp,-48
    800023f8:	f406                	sd	ra,40(sp)
    800023fa:	f022                	sd	s0,32(sp)
    800023fc:	ec26                	sd	s1,24(sp)
    800023fe:	e84a                	sd	s2,16(sp)
    80002400:	e44e                	sd	s3,8(sp)
    80002402:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002404:	fffff097          	auipc	ra,0xfffff
    80002408:	5aa080e7          	jalr	1450(ra) # 800019ae <myproc>
    8000240c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000240e:	ffffe097          	auipc	ra,0xffffe
    80002412:	75a080e7          	jalr	1882(ra) # 80000b68 <holding>
    80002416:	c93d                	beqz	a0,8000248c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002418:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000241a:	2781                	sext.w	a5,a5
    8000241c:	079e                	slli	a5,a5,0x7
    8000241e:	00010717          	auipc	a4,0x10
    80002422:	ec270713          	addi	a4,a4,-318 # 800122e0 <pid_lock>
    80002426:	97ba                	add	a5,a5,a4
    80002428:	0a87a703          	lw	a4,168(a5)
    8000242c:	4785                	li	a5,1
    8000242e:	06f71763          	bne	a4,a5,8000249c <sched+0xa6>
  if(p->state == RUNNING)
    80002432:	4c98                	lw	a4,24(s1)
    80002434:	4791                	li	a5,4
    80002436:	06f70b63          	beq	a4,a5,800024ac <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000243a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000243e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002440:	efb5                	bnez	a5,800024bc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002442:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002444:	00010917          	auipc	s2,0x10
    80002448:	e9c90913          	addi	s2,s2,-356 # 800122e0 <pid_lock>
    8000244c:	2781                	sext.w	a5,a5
    8000244e:	079e                	slli	a5,a5,0x7
    80002450:	97ca                	add	a5,a5,s2
    80002452:	0ac7a983          	lw	s3,172(a5)
    80002456:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002458:	2781                	sext.w	a5,a5
    8000245a:	079e                	slli	a5,a5,0x7
    8000245c:	00010597          	auipc	a1,0x10
    80002460:	ebc58593          	addi	a1,a1,-324 # 80012318 <cpus+0x8>
    80002464:	95be                	add	a1,a1,a5
    80002466:	06048513          	addi	a0,s1,96
    8000246a:	00001097          	auipc	ra,0x1
    8000246e:	0e8080e7          	jalr	232(ra) # 80003552 <swtch>
    80002472:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002474:	2781                	sext.w	a5,a5
    80002476:	079e                	slli	a5,a5,0x7
    80002478:	97ca                	add	a5,a5,s2
    8000247a:	0b37a623          	sw	s3,172(a5)
}
    8000247e:	70a2                	ld	ra,40(sp)
    80002480:	7402                	ld	s0,32(sp)
    80002482:	64e2                	ld	s1,24(sp)
    80002484:	6942                	ld	s2,16(sp)
    80002486:	69a2                	ld	s3,8(sp)
    80002488:	6145                	addi	sp,sp,48
    8000248a:	8082                	ret
    panic("sched p->lock");
    8000248c:	00007517          	auipc	a0,0x7
    80002490:	d8c50513          	addi	a0,a0,-628 # 80009218 <digits+0x1d8>
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	0a8080e7          	jalr	168(ra) # 8000053c <panic>
    panic("sched locks");
    8000249c:	00007517          	auipc	a0,0x7
    800024a0:	d8c50513          	addi	a0,a0,-628 # 80009228 <digits+0x1e8>
    800024a4:	ffffe097          	auipc	ra,0xffffe
    800024a8:	098080e7          	jalr	152(ra) # 8000053c <panic>
    panic("sched running");
    800024ac:	00007517          	auipc	a0,0x7
    800024b0:	d8c50513          	addi	a0,a0,-628 # 80009238 <digits+0x1f8>
    800024b4:	ffffe097          	auipc	ra,0xffffe
    800024b8:	088080e7          	jalr	136(ra) # 8000053c <panic>
    panic("sched interruptible");
    800024bc:	00007517          	auipc	a0,0x7
    800024c0:	d8c50513          	addi	a0,a0,-628 # 80009248 <digits+0x208>
    800024c4:	ffffe097          	auipc	ra,0xffffe
    800024c8:	078080e7          	jalr	120(ra) # 8000053c <panic>

00000000800024cc <yield>:
{
    800024cc:	1101                	addi	sp,sp,-32
    800024ce:	ec06                	sd	ra,24(sp)
    800024d0:	e822                	sd	s0,16(sp)
    800024d2:	e426                	sd	s1,8(sp)
    800024d4:	e04a                	sd	s2,0(sp)
    800024d6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	4d6080e7          	jalr	1238(ra) # 800019ae <myproc>
    800024e0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024e2:	ffffe097          	auipc	ra,0xffffe
    800024e6:	700080e7          	jalr	1792(ra) # 80000be2 <acquire>
  p->state = RUNNABLE;
    800024ea:	478d                	li	a5,3
    800024ec:	cc9c                	sw	a5,24(s1)
    if (!holding(&tickslock)) {
    800024ee:	00016517          	auipc	a0,0x16
    800024f2:	62250513          	addi	a0,a0,1570 # 80018b10 <tickslock>
    800024f6:	ffffe097          	auipc	ra,0xffffe
    800024fa:	672080e7          	jalr	1650(ra) # 80000b68 <holding>
    800024fe:	c15d                	beqz	a0,800025a4 <yield+0xd8>
    else xticks = ticks;
    80002500:	00008917          	auipc	s2,0x8
    80002504:	b7092903          	lw	s2,-1168(s2) # 8000a070 <ticks>
    p->end_ticks = xticks;
    80002508:	1924a223          	sw	s2,388(s1)
    p->cpu_usage = p->cpu_usage + SCHED_PARAM_CPU_USAGE;
    8000250c:	17c4a783          	lw	a5,380(s1)
    80002510:	0c87871b          	addiw	a4,a5,200
    80002514:	16e4ae23          	sw	a4,380(s1)
    if(p->batch == 1 && p->end_ticks > p->start_ticks){
    80002518:	1884a683          	lw	a3,392(s1)
    8000251c:	4785                	li	a5,1
    8000251e:	0af68863          	beq	a3,a5,800025ce <yield+0x102>
      p->estimate = (p->end_ticks - p->start_ticks) - (SCHED_PARAM_SJF_A_NUMER*(p->end_ticks - p->start_ticks))/SCHED_PARAM_SJF_A_DENOM + (SCHED_PARAM_SJF_A_NUMER*(p->estimate))/SCHED_PARAM_SJF_A_DENOM;
    80002522:	1804a783          	lw	a5,384(s1)
    80002526:	40f9093b          	subw	s2,s2,a5
    8000252a:	18c4a783          	lw	a5,396(s1)
    8000252e:	0017d79b          	srliw	a5,a5,0x1
    80002532:	012787bb          	addw	a5,a5,s2
    80002536:	0019591b          	srliw	s2,s2,0x1
    8000253a:	4127893b          	subw	s2,a5,s2
    8000253e:	1924a623          	sw	s2,396(s1)
      p->cpu_usage = p->cpu_usage/2;
    80002542:	01f7579b          	srliw	a5,a4,0x1f
    80002546:	9fb9                	addw	a5,a5,a4
    80002548:	4017d79b          	sraiw	a5,a5,0x1
    8000254c:	16f4ae23          	sw	a5,380(s1)
      p->priority = p->prio + p->cpu_usage/2;
    80002550:	41f7579b          	sraiw	a5,a4,0x1f
    80002554:	01e7d79b          	srliw	a5,a5,0x1e
    80002558:	9fb9                	addw	a5,a5,a4
    8000255a:	4027d79b          	sraiw	a5,a5,0x2
    8000255e:	1744a703          	lw	a4,372(s1)
    80002562:	9fb9                	addw	a5,a5,a4
    80002564:	00078e1b          	sext.w	t3,a5
    80002568:	16f4ac23          	sw	a5,376(s1)
      min_burst = 0;
    8000256c:	00008797          	auipc	a5,0x8
    80002570:	ac07a223          	sw	zero,-1340(a5) # 8000a030 <min_burst>
      min_prio = 0;
    80002574:	00008797          	auipc	a5,0x8
    80002578:	aa07ac23          	sw	zero,-1352(a5) # 8000a02c <min_prio>
      for(p1 = proc; p1 < &proc[NPROC]; ++p1){
    8000257c:	00008f17          	auipc	t5,0x8
    80002580:	ad0f2f03          	lw	t5,-1328(t5) # 8000a04c <mi_burst>
      min_prio = 0;
    80002584:	4501                	li	a0,0
    80002586:	4801                	li	a6,0
    80002588:	4e81                	li	t4,0
    8000258a:	4301                	li	t1,0
    8000258c:	4881                	li	a7,0
      for(p1 = proc; p1 < &proc[NPROC]; ++p1){
    8000258e:	00010797          	auipc	a5,0x10
    80002592:	18278793          	addi	a5,a5,386 # 80012710 <proc>
        if(p1->state == RUNNABLE && p1->batch == 1){
    80002596:	460d                	li	a2,3
    80002598:	4585                	li	a1,1
      for(p1 = proc; p1 < &proc[NPROC]; ++p1){
    8000259a:	00016697          	auipc	a3,0x16
    8000259e:	57668693          	addi	a3,a3,1398 # 80018b10 <tickslock>
    800025a2:	a8c5                	j	80002692 <yield+0x1c6>
      acquire(&tickslock);
    800025a4:	00016517          	auipc	a0,0x16
    800025a8:	56c50513          	addi	a0,a0,1388 # 80018b10 <tickslock>
    800025ac:	ffffe097          	auipc	ra,0xffffe
    800025b0:	636080e7          	jalr	1590(ra) # 80000be2 <acquire>
      xticks = ticks;
    800025b4:	00008917          	auipc	s2,0x8
    800025b8:	abc92903          	lw	s2,-1348(s2) # 8000a070 <ticks>
      release(&tickslock);
    800025bc:	00016517          	auipc	a0,0x16
    800025c0:	55450513          	addi	a0,a0,1364 # 80018b10 <tickslock>
    800025c4:	ffffe097          	auipc	ra,0xffffe
    800025c8:	6d2080e7          	jalr	1746(ra) # 80000c96 <release>
    800025cc:	bf35                	j	80002508 <yield+0x3c>
    if(p->batch == 1 && p->end_ticks > p->start_ticks){
    800025ce:	1804a783          	lw	a5,384(s1)
    800025d2:	f527f8e3          	bgeu	a5,s2,80002522 <yield+0x56>
      if(max_burst < p->end_ticks - p->start_ticks){
    800025d6:	40f906bb          	subw	a3,s2,a5
    800025da:	0006859b          	sext.w	a1,a3
    800025de:	00008617          	auipc	a2,0x8
    800025e2:	a7262603          	lw	a2,-1422(a2) # 8000a050 <max_burst>
    800025e6:	00b67663          	bgeu	a2,a1,800025f2 <yield+0x126>
        max_burst = p->end_ticks - p->start_ticks;
    800025ea:	00008617          	auipc	a2,0x8
    800025ee:	a6d62323          	sw	a3,-1434(a2) # 8000a050 <max_burst>
      if(mi_burst == 0){
    800025f2:	00008617          	auipc	a2,0x8
    800025f6:	a5a62603          	lw	a2,-1446(a2) # 8000a04c <mi_burst>
    800025fa:	ee21                	bnez	a2,80002652 <yield+0x186>
        mi_burst = p->end_ticks - p->start_ticks;
    800025fc:	00008617          	auipc	a2,0x8
    80002600:	a4d62823          	sw	a3,-1456(a2) # 8000a04c <mi_burst>
      sum_burst += p->end_ticks - p->start_ticks;
    80002604:	00008517          	auipc	a0,0x8
    80002608:	a4450513          	addi	a0,a0,-1468 # 8000a048 <sum_burst>
    8000260c:	4110                	lw	a2,0(a0)
    8000260e:	9e35                	addw	a2,a2,a3
    80002610:	c110                	sw	a2,0(a0)
      total_burst ++ ;
    80002612:	00008517          	auipc	a0,0x8
    80002616:	a4250513          	addi	a0,a0,-1470 # 8000a054 <total_burst>
    8000261a:	4110                	lw	a2,0(a0)
    8000261c:	2605                	addiw	a2,a2,1
    8000261e:	c110                	sw	a2,0(a0)
      if(p->estimate){
    80002620:	18c4a603          	lw	a2,396(s1)
    80002624:	ce15                	beqz	a2,80002660 <yield+0x194>
        err_burst ++ ;
    80002626:	00008817          	auipc	a6,0x8
    8000262a:	a1280813          	addi	a6,a6,-1518 # 8000a038 <err_burst>
    8000262e:	00082503          	lw	a0,0(a6)
    80002632:	2505                	addiw	a0,a0,1
    80002634:	00a82023          	sw	a0,0(a6)
        if(p->estimate > p->end_ticks - p->start_ticks){
    80002638:	02c5f463          	bgeu	a1,a2,80002660 <yield+0x194>
          err_sum += p->estimate - (p->end_ticks - p->start_ticks);
    8000263c:	00008697          	auipc	a3,0x8
    80002640:	9f868693          	addi	a3,a3,-1544 # 8000a034 <err_sum>
    80002644:	9fb1                	addw	a5,a5,a2
    80002646:	4290                	lw	a2,0(a3)
    80002648:	9fb1                	addw	a5,a5,a2
    8000264a:	412787bb          	subw	a5,a5,s2
    8000264e:	c29c                	sw	a5,0(a3)
    80002650:	bdc9                	j	80002522 <yield+0x56>
      else if(mi_burst > p->end_ticks - p->start_ticks){
    80002652:	fac5f9e3          	bgeu	a1,a2,80002604 <yield+0x138>
        mi_burst = p->end_ticks - p->start_ticks;
    80002656:	00008617          	auipc	a2,0x8
    8000265a:	9ed62b23          	sw	a3,-1546(a2) # 8000a04c <mi_burst>
    8000265e:	b75d                	j	80002604 <yield+0x138>
          err_sum += (p->end_ticks - p->start_ticks) - p->estimate;
    80002660:	00008597          	auipc	a1,0x8
    80002664:	9d458593          	addi	a1,a1,-1580 # 8000a034 <err_sum>
    80002668:	419c                	lw	a5,0(a1)
    8000266a:	9f91                	subw	a5,a5,a2
    8000266c:	9ebd                	addw	a3,a3,a5
    8000266e:	c194                	sw	a3,0(a1)
    80002670:	bd4d                	j	80002522 <yield+0x56>
            if(min_burst > p1->estimate){
    80002672:	18c7a703          	lw	a4,396(a5)
    80002676:	03177a63          	bgeu	a4,a7,800026aa <yield+0x1de>
              mi_burst = p1->estimate;
    8000267a:	8f3a                	mv	t5,a4
    8000267c:	8eae                	mv	t4,a1
    8000267e:	a035                	j	800026aa <yield+0x1de>
          else if(min_prio > p->priority){
    80002680:	010e5563          	bge	t3,a6,8000268a <yield+0x1be>
            min_prio = p1->priority;
    80002684:	1787a803          	lw	a6,376(a5)
    80002688:	852e                	mv	a0,a1
      for(p1 = proc; p1 < &proc[NPROC]; ++p1){
    8000268a:	19078793          	addi	a5,a5,400
    8000268e:	02d78463          	beq	a5,a3,800026b6 <yield+0x1ea>
        if(p1->state == RUNNABLE && p1->batch == 1){
    80002692:	4f98                	lw	a4,24(a5)
    80002694:	fec71be3          	bne	a4,a2,8000268a <yield+0x1be>
    80002698:	1887a703          	lw	a4,392(a5)
    8000269c:	feb717e3          	bne	a4,a1,8000268a <yield+0x1be>
          if(min_burst == 0){
    800026a0:	fc0899e3          	bnez	a7,80002672 <yield+0x1a6>
            min_burst = p1->estimate;
    800026a4:	18c7a883          	lw	a7,396(a5)
    800026a8:	832e                	mv	t1,a1
          if(min_prio == 0){
    800026aa:	fc081be3          	bnez	a6,80002680 <yield+0x1b4>
            min_prio = p1->priority;
    800026ae:	1787a803          	lw	a6,376(a5)
    800026b2:	852e                	mv	a0,a1
    800026b4:	bfd9                	j	8000268a <yield+0x1be>
    800026b6:	00030663          	beqz	t1,800026c2 <yield+0x1f6>
    800026ba:	00008797          	auipc	a5,0x8
    800026be:	9717ab23          	sw	a7,-1674(a5) # 8000a030 <min_burst>
    800026c2:	000e8663          	beqz	t4,800026ce <yield+0x202>
    800026c6:	00008797          	auipc	a5,0x8
    800026ca:	99e7a323          	sw	t5,-1658(a5) # 8000a04c <mi_burst>
    800026ce:	c509                	beqz	a0,800026d8 <yield+0x20c>
    800026d0:	00008797          	auipc	a5,0x8
    800026d4:	9507ae23          	sw	a6,-1700(a5) # 8000a02c <min_prio>
  sched();
    800026d8:	00000097          	auipc	ra,0x0
    800026dc:	d1e080e7          	jalr	-738(ra) # 800023f6 <sched>
  release(&p->lock);
    800026e0:	8526                	mv	a0,s1
    800026e2:	ffffe097          	auipc	ra,0xffffe
    800026e6:	5b4080e7          	jalr	1460(ra) # 80000c96 <release>
}
    800026ea:	60e2                	ld	ra,24(sp)
    800026ec:	6442                	ld	s0,16(sp)
    800026ee:	64a2                	ld	s1,8(sp)
    800026f0:	6902                	ld	s2,0(sp)
    800026f2:	6105                	addi	sp,sp,32
    800026f4:	8082                	ret

00000000800026f6 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800026f6:	7179                	addi	sp,sp,-48
    800026f8:	f406                	sd	ra,40(sp)
    800026fa:	f022                	sd	s0,32(sp)
    800026fc:	ec26                	sd	s1,24(sp)
    800026fe:	e84a                	sd	s2,16(sp)
    80002700:	e44e                	sd	s3,8(sp)
    80002702:	1800                	addi	s0,sp,48
    80002704:	89aa                	mv	s3,a0
    80002706:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002708:	fffff097          	auipc	ra,0xfffff
    8000270c:	2a6080e7          	jalr	678(ra) # 800019ae <myproc>
    80002710:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002712:	ffffe097          	auipc	ra,0xffffe
    80002716:	4d0080e7          	jalr	1232(ra) # 80000be2 <acquire>
  release(lk);
    8000271a:	854a                	mv	a0,s2
    8000271c:	ffffe097          	auipc	ra,0xffffe
    80002720:	57a080e7          	jalr	1402(ra) # 80000c96 <release>

  // Go to sleep.
  p->chan = chan;
    80002724:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002728:	4789                	li	a5,2
    8000272a:	cc9c                	sw	a5,24(s1)

  //
    uint xticks;
    if (!holding(&tickslock)) {
    8000272c:	00016517          	auipc	a0,0x16
    80002730:	3e450513          	addi	a0,a0,996 # 80018b10 <tickslock>
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	434080e7          	jalr	1076(ra) # 80000b68 <holding>
    8000273c:	c14d                	beqz	a0,800027de <sleep+0xe8>
      acquire(&tickslock);
      xticks = ticks;
      release(&tickslock);
    }
    else xticks = ticks;
    8000273e:	00008997          	auipc	s3,0x8
    80002742:	9329a983          	lw	s3,-1742(s3) # 8000a070 <ticks>

    p->end_ticks = xticks;
    80002746:	1934a223          	sw	s3,388(s1)

    p->cpu_usage = p->cpu_usage + SCHED_PARAM_CPU_USAGE/2;
    8000274a:	17c4a783          	lw	a5,380(s1)
    8000274e:	0647871b          	addiw	a4,a5,100
    80002752:	16e4ae23          	sw	a4,380(s1)

    if(p->batch == 1 && p->end_ticks > p->start_ticks){
    80002756:	1884a683          	lw	a3,392(s1)
    8000275a:	4785                	li	a5,1
    8000275c:	0af68663          	beq	a3,a5,80002808 <sleep+0x112>
      //       min_prio = p->priority;
      //     }
      //   }
      }

      p->estimate = (p->end_ticks - p->start_ticks) - (SCHED_PARAM_SJF_A_NUMER*(p->end_ticks - p->start_ticks))/SCHED_PARAM_SJF_A_DENOM + (SCHED_PARAM_SJF_A_NUMER*(p->estimate))/SCHED_PARAM_SJF_A_DENOM;
    80002760:	1804a783          	lw	a5,384(s1)
    80002764:	40f989bb          	subw	s3,s3,a5
    80002768:	18c4a783          	lw	a5,396(s1)
    8000276c:	0017d79b          	srliw	a5,a5,0x1
    80002770:	013787bb          	addw	a5,a5,s3
    80002774:	0019d99b          	srliw	s3,s3,0x1
    80002778:	413789bb          	subw	s3,a5,s3
    8000277c:	1934a623          	sw	s3,396(s1)
      
      p->cpu_usage = p->cpu_usage/2;
    80002780:	01f7579b          	srliw	a5,a4,0x1f
    80002784:	9fb9                	addw	a5,a5,a4
    80002786:	4017d79b          	sraiw	a5,a5,0x1
    8000278a:	16f4ae23          	sw	a5,380(s1)
      p->priority = p->prio + p->cpu_usage/2;
    8000278e:	41f7579b          	sraiw	a5,a4,0x1f
    80002792:	01e7d79b          	srliw	a5,a5,0x1e
    80002796:	9fb9                	addw	a5,a5,a4
    80002798:	4027d79b          	sraiw	a5,a5,0x2
    8000279c:	1744a703          	lw	a4,372(s1)
    800027a0:	9fb9                	addw	a5,a5,a4
    800027a2:	16f4ac23          	sw	a5,376(s1)
      min_burst = 0;
    800027a6:	00008797          	auipc	a5,0x8
    800027aa:	8807a523          	sw	zero,-1910(a5) # 8000a030 <min_burst>
      min_prio = 0;
    800027ae:	00008797          	auipc	a5,0x8
    800027b2:	8607af23          	sw	zero,-1922(a5) # 8000a02c <min_prio>
      struct proc* p1;
      for(p1 = proc; p1 < &proc[NPROC]; p1++){
    800027b6:	00008e97          	auipc	t4,0x8
    800027ba:	896eae83          	lw	t4,-1898(t4) # 8000a04c <mi_burst>
      min_prio = 0;
    800027be:	4581                	li	a1,0
    800027c0:	4881                	li	a7,0
    800027c2:	4e01                	li	t3,0
    800027c4:	4301                	li	t1,0
    800027c6:	4501                	li	a0,0
      for(p1 = proc; p1 < &proc[NPROC]; p1++){
    800027c8:	00010797          	auipc	a5,0x10
    800027cc:	f4878793          	addi	a5,a5,-184 # 80012710 <proc>
        if(p1->state == RUNNABLE && p1->batch == 1){
    800027d0:	460d                	li	a2,3
    800027d2:	4805                	li	a6,1
      for(p1 = proc; p1 < &proc[NPROC]; p1++){
    800027d4:	00016697          	auipc	a3,0x16
    800027d8:	33c68693          	addi	a3,a3,828 # 80018b10 <tickslock>
    800027dc:	a8cd                	j	800028ce <sleep+0x1d8>
      acquire(&tickslock);
    800027de:	00016517          	auipc	a0,0x16
    800027e2:	33250513          	addi	a0,a0,818 # 80018b10 <tickslock>
    800027e6:	ffffe097          	auipc	ra,0xffffe
    800027ea:	3fc080e7          	jalr	1020(ra) # 80000be2 <acquire>
      xticks = ticks;
    800027ee:	00008997          	auipc	s3,0x8
    800027f2:	8829a983          	lw	s3,-1918(s3) # 8000a070 <ticks>
      release(&tickslock);
    800027f6:	00016517          	auipc	a0,0x16
    800027fa:	31a50513          	addi	a0,a0,794 # 80018b10 <tickslock>
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	498080e7          	jalr	1176(ra) # 80000c96 <release>
    80002806:	b781                	j	80002746 <sleep+0x50>
    if(p->batch == 1 && p->end_ticks > p->start_ticks){
    80002808:	1804a783          	lw	a5,384(s1)
    8000280c:	f537fae3          	bgeu	a5,s3,80002760 <sleep+0x6a>
       if(max_burst < p->end_ticks - p->start_ticks){
    80002810:	40f986bb          	subw	a3,s3,a5
    80002814:	0006859b          	sext.w	a1,a3
    80002818:	00008617          	auipc	a2,0x8
    8000281c:	83862603          	lw	a2,-1992(a2) # 8000a050 <max_burst>
    80002820:	00b67663          	bgeu	a2,a1,8000282c <sleep+0x136>
        max_burst = p->end_ticks - p->start_ticks;
    80002824:	00008617          	auipc	a2,0x8
    80002828:	82d62623          	sw	a3,-2004(a2) # 8000a050 <max_burst>
      if(mi_burst == 0){
    8000282c:	00008617          	auipc	a2,0x8
    80002830:	82062603          	lw	a2,-2016(a2) # 8000a04c <mi_burst>
    80002834:	ee21                	bnez	a2,8000288c <sleep+0x196>
        mi_burst = p->end_ticks - p->start_ticks;
    80002836:	00008617          	auipc	a2,0x8
    8000283a:	80d62b23          	sw	a3,-2026(a2) # 8000a04c <mi_burst>
      sum_burst += p->end_ticks - p->start_ticks;
    8000283e:	00008517          	auipc	a0,0x8
    80002842:	80a50513          	addi	a0,a0,-2038 # 8000a048 <sum_burst>
    80002846:	4110                	lw	a2,0(a0)
    80002848:	9e35                	addw	a2,a2,a3
    8000284a:	c110                	sw	a2,0(a0)
      total_burst ++ ;
    8000284c:	00008517          	auipc	a0,0x8
    80002850:	80850513          	addi	a0,a0,-2040 # 8000a054 <total_burst>
    80002854:	4110                	lw	a2,0(a0)
    80002856:	2605                	addiw	a2,a2,1
    80002858:	c110                	sw	a2,0(a0)
      if(p->estimate){
    8000285a:	18c4a603          	lw	a2,396(s1)
    8000285e:	ce15                	beqz	a2,8000289a <sleep+0x1a4>
        err_burst ++ ;
    80002860:	00007817          	auipc	a6,0x7
    80002864:	7d880813          	addi	a6,a6,2008 # 8000a038 <err_burst>
    80002868:	00082503          	lw	a0,0(a6)
    8000286c:	2505                	addiw	a0,a0,1
    8000286e:	00a82023          	sw	a0,0(a6)
        if(p->estimate > p->end_ticks - p->start_ticks){
    80002872:	02c5f463          	bgeu	a1,a2,8000289a <sleep+0x1a4>
          err_sum += p->estimate - (p->end_ticks - p->start_ticks);
    80002876:	00007697          	auipc	a3,0x7
    8000287a:	7be68693          	addi	a3,a3,1982 # 8000a034 <err_sum>
    8000287e:	9fb1                	addw	a5,a5,a2
    80002880:	4290                	lw	a2,0(a3)
    80002882:	9fb1                	addw	a5,a5,a2
    80002884:	413787bb          	subw	a5,a5,s3
    80002888:	c29c                	sw	a5,0(a3)
    8000288a:	bdd9                	j	80002760 <sleep+0x6a>
      else if(mi_burst > p->end_ticks - p->start_ticks){
    8000288c:	fac5f9e3          	bgeu	a1,a2,8000283e <sleep+0x148>
        mi_burst = p->end_ticks - p->start_ticks;
    80002890:	00007617          	auipc	a2,0x7
    80002894:	7ad62e23          	sw	a3,1980(a2) # 8000a04c <mi_burst>
    80002898:	b75d                	j	8000283e <sleep+0x148>
          err_sum += (p->end_ticks - p->start_ticks) - p->estimate;
    8000289a:	00007597          	auipc	a1,0x7
    8000289e:	79a58593          	addi	a1,a1,1946 # 8000a034 <err_sum>
    800028a2:	419c                	lw	a5,0(a1)
    800028a4:	9f91                	subw	a5,a5,a2
    800028a6:	9ebd                	addw	a3,a3,a5
    800028a8:	c194                	sw	a3,0(a1)
    800028aa:	bd5d                	j	80002760 <sleep+0x6a>
          if(min_burst == 0){
            min_burst = p1->estimate;
          }
          else{
            if(min_burst > p1->estimate){
    800028ac:	18c7a703          	lw	a4,396(a5)
    800028b0:	02a77a63          	bgeu	a4,a0,800028e4 <sleep+0x1ee>
              mi_burst = p1->estimate;
    800028b4:	8eba                	mv	t4,a4
    800028b6:	8e42                	mv	t3,a6
    800028b8:	a035                	j	800028e4 <sleep+0x1ee>
            }
          }
          if(min_prio == 0){
            min_prio = p1->priority;
          }
          else if(min_prio > p1->priority){
    800028ba:	1787a703          	lw	a4,376(a5)
    800028be:	01175463          	bge	a4,a7,800028c6 <sleep+0x1d0>
            min_prio = p1->priority;
    800028c2:	88ba                	mv	a7,a4
    800028c4:	85c2                	mv	a1,a6
      for(p1 = proc; p1 < &proc[NPROC]; p1++){
    800028c6:	19078793          	addi	a5,a5,400
    800028ca:	02d78363          	beq	a5,a3,800028f0 <sleep+0x1fa>
        if(p1->state == RUNNABLE && p1->batch == 1){
    800028ce:	4f98                	lw	a4,24(a5)
    800028d0:	fec71be3          	bne	a4,a2,800028c6 <sleep+0x1d0>
    800028d4:	1887a703          	lw	a4,392(a5)
    800028d8:	ff0717e3          	bne	a4,a6,800028c6 <sleep+0x1d0>
          if(min_burst == 0){
    800028dc:	f961                	bnez	a0,800028ac <sleep+0x1b6>
            min_burst = p1->estimate;
    800028de:	18c7a503          	lw	a0,396(a5)
    800028e2:	8342                	mv	t1,a6
          if(min_prio == 0){
    800028e4:	fc089be3          	bnez	a7,800028ba <sleep+0x1c4>
            min_prio = p1->priority;
    800028e8:	1787a883          	lw	a7,376(a5)
    800028ec:	85c2                	mv	a1,a6
    800028ee:	bfe1                	j	800028c6 <sleep+0x1d0>
    800028f0:	00030663          	beqz	t1,800028fc <sleep+0x206>
    800028f4:	00007797          	auipc	a5,0x7
    800028f8:	72a7ae23          	sw	a0,1852(a5) # 8000a030 <min_burst>
    800028fc:	000e0663          	beqz	t3,80002908 <sleep+0x212>
    80002900:	00007797          	auipc	a5,0x7
    80002904:	75d7a623          	sw	t4,1868(a5) # 8000a04c <mi_burst>
    80002908:	c589                	beqz	a1,80002912 <sleep+0x21c>
    8000290a:	00007797          	auipc	a5,0x7
    8000290e:	7317a123          	sw	a7,1826(a5) # 8000a02c <min_prio>
    }
  

  //

  sched();
    80002912:	00000097          	auipc	ra,0x0
    80002916:	ae4080e7          	jalr	-1308(ra) # 800023f6 <sched>

  // Tidy up.
  p->chan = 0;
    8000291a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000291e:	8526                	mv	a0,s1
    80002920:	ffffe097          	auipc	ra,0xffffe
    80002924:	376080e7          	jalr	886(ra) # 80000c96 <release>
  acquire(lk);
    80002928:	854a                	mv	a0,s2
    8000292a:	ffffe097          	auipc	ra,0xffffe
    8000292e:	2b8080e7          	jalr	696(ra) # 80000be2 <acquire>
}
    80002932:	70a2                	ld	ra,40(sp)
    80002934:	7402                	ld	s0,32(sp)
    80002936:	64e2                	ld	s1,24(sp)
    80002938:	6942                	ld	s2,16(sp)
    8000293a:	69a2                	ld	s3,8(sp)
    8000293c:	6145                	addi	sp,sp,48
    8000293e:	8082                	ret

0000000080002940 <wait>:
{
    80002940:	715d                	addi	sp,sp,-80
    80002942:	e486                	sd	ra,72(sp)
    80002944:	e0a2                	sd	s0,64(sp)
    80002946:	fc26                	sd	s1,56(sp)
    80002948:	f84a                	sd	s2,48(sp)
    8000294a:	f44e                	sd	s3,40(sp)
    8000294c:	f052                	sd	s4,32(sp)
    8000294e:	ec56                	sd	s5,24(sp)
    80002950:	e85a                	sd	s6,16(sp)
    80002952:	e45e                	sd	s7,8(sp)
    80002954:	e062                	sd	s8,0(sp)
    80002956:	0880                	addi	s0,sp,80
    80002958:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000295a:	fffff097          	auipc	ra,0xfffff
    8000295e:	054080e7          	jalr	84(ra) # 800019ae <myproc>
    80002962:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002964:	00010517          	auipc	a0,0x10
    80002968:	99450513          	addi	a0,a0,-1644 # 800122f8 <wait_lock>
    8000296c:	ffffe097          	auipc	ra,0xffffe
    80002970:	276080e7          	jalr	630(ra) # 80000be2 <acquire>
    havekids = 0;
    80002974:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002976:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    80002978:	00016997          	auipc	s3,0x16
    8000297c:	19898993          	addi	s3,s3,408 # 80018b10 <tickslock>
        havekids = 1;
    80002980:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002982:	00010c17          	auipc	s8,0x10
    80002986:	976c0c13          	addi	s8,s8,-1674 # 800122f8 <wait_lock>
    havekids = 0;
    8000298a:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000298c:	00010497          	auipc	s1,0x10
    80002990:	d8448493          	addi	s1,s1,-636 # 80012710 <proc>
    80002994:	a0bd                	j	80002a02 <wait+0xc2>
          pid = np->pid;
    80002996:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000299a:	000b0e63          	beqz	s6,800029b6 <wait+0x76>
    8000299e:	4691                	li	a3,4
    800029a0:	02c48613          	addi	a2,s1,44
    800029a4:	85da                	mv	a1,s6
    800029a6:	05093503          	ld	a0,80(s2)
    800029aa:	fffff097          	auipc	ra,0xfffff
    800029ae:	cc6080e7          	jalr	-826(ra) # 80001670 <copyout>
    800029b2:	02054563          	bltz	a0,800029dc <wait+0x9c>
          freeproc(np);
    800029b6:	8526                	mv	a0,s1
    800029b8:	fffff097          	auipc	ra,0xfffff
    800029bc:	1e0080e7          	jalr	480(ra) # 80001b98 <freeproc>
          release(&np->lock);
    800029c0:	8526                	mv	a0,s1
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	2d4080e7          	jalr	724(ra) # 80000c96 <release>
          release(&wait_lock);
    800029ca:	00010517          	auipc	a0,0x10
    800029ce:	92e50513          	addi	a0,a0,-1746 # 800122f8 <wait_lock>
    800029d2:	ffffe097          	auipc	ra,0xffffe
    800029d6:	2c4080e7          	jalr	708(ra) # 80000c96 <release>
          return pid;
    800029da:	a09d                	j	80002a40 <wait+0x100>
            release(&np->lock);
    800029dc:	8526                	mv	a0,s1
    800029de:	ffffe097          	auipc	ra,0xffffe
    800029e2:	2b8080e7          	jalr	696(ra) # 80000c96 <release>
            release(&wait_lock);
    800029e6:	00010517          	auipc	a0,0x10
    800029ea:	91250513          	addi	a0,a0,-1774 # 800122f8 <wait_lock>
    800029ee:	ffffe097          	auipc	ra,0xffffe
    800029f2:	2a8080e7          	jalr	680(ra) # 80000c96 <release>
            return -1;
    800029f6:	59fd                	li	s3,-1
    800029f8:	a0a1                	j	80002a40 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800029fa:	19048493          	addi	s1,s1,400
    800029fe:	03348463          	beq	s1,s3,80002a26 <wait+0xe6>
      if(np->parent == p){
    80002a02:	7c9c                	ld	a5,56(s1)
    80002a04:	ff279be3          	bne	a5,s2,800029fa <wait+0xba>
        acquire(&np->lock);
    80002a08:	8526                	mv	a0,s1
    80002a0a:	ffffe097          	auipc	ra,0xffffe
    80002a0e:	1d8080e7          	jalr	472(ra) # 80000be2 <acquire>
        if(np->state == ZOMBIE){
    80002a12:	4c9c                	lw	a5,24(s1)
    80002a14:	f94781e3          	beq	a5,s4,80002996 <wait+0x56>
        release(&np->lock);
    80002a18:	8526                	mv	a0,s1
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	27c080e7          	jalr	636(ra) # 80000c96 <release>
        havekids = 1;
    80002a22:	8756                	mv	a4,s5
    80002a24:	bfd9                	j	800029fa <wait+0xba>
    if(!havekids || p->killed){
    80002a26:	c701                	beqz	a4,80002a2e <wait+0xee>
    80002a28:	02892783          	lw	a5,40(s2)
    80002a2c:	c79d                	beqz	a5,80002a5a <wait+0x11a>
      release(&wait_lock);
    80002a2e:	00010517          	auipc	a0,0x10
    80002a32:	8ca50513          	addi	a0,a0,-1846 # 800122f8 <wait_lock>
    80002a36:	ffffe097          	auipc	ra,0xffffe
    80002a3a:	260080e7          	jalr	608(ra) # 80000c96 <release>
      return -1;
    80002a3e:	59fd                	li	s3,-1
}
    80002a40:	854e                	mv	a0,s3
    80002a42:	60a6                	ld	ra,72(sp)
    80002a44:	6406                	ld	s0,64(sp)
    80002a46:	74e2                	ld	s1,56(sp)
    80002a48:	7942                	ld	s2,48(sp)
    80002a4a:	79a2                	ld	s3,40(sp)
    80002a4c:	7a02                	ld	s4,32(sp)
    80002a4e:	6ae2                	ld	s5,24(sp)
    80002a50:	6b42                	ld	s6,16(sp)
    80002a52:	6ba2                	ld	s7,8(sp)
    80002a54:	6c02                	ld	s8,0(sp)
    80002a56:	6161                	addi	sp,sp,80
    80002a58:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a5a:	85e2                	mv	a1,s8
    80002a5c:	854a                	mv	a0,s2
    80002a5e:	00000097          	auipc	ra,0x0
    80002a62:	c98080e7          	jalr	-872(ra) # 800026f6 <sleep>
    havekids = 0;
    80002a66:	b715                	j	8000298a <wait+0x4a>

0000000080002a68 <waitpid>:
{
    80002a68:	711d                	addi	sp,sp,-96
    80002a6a:	ec86                	sd	ra,88(sp)
    80002a6c:	e8a2                	sd	s0,80(sp)
    80002a6e:	e4a6                	sd	s1,72(sp)
    80002a70:	e0ca                	sd	s2,64(sp)
    80002a72:	fc4e                	sd	s3,56(sp)
    80002a74:	f852                	sd	s4,48(sp)
    80002a76:	f456                	sd	s5,40(sp)
    80002a78:	f05a                	sd	s6,32(sp)
    80002a7a:	ec5e                	sd	s7,24(sp)
    80002a7c:	e862                	sd	s8,16(sp)
    80002a7e:	e466                	sd	s9,8(sp)
    80002a80:	1080                	addi	s0,sp,96
    80002a82:	8a2a                	mv	s4,a0
    80002a84:	8c2e                	mv	s8,a1
  struct proc *p = myproc();
    80002a86:	fffff097          	auipc	ra,0xfffff
    80002a8a:	f28080e7          	jalr	-216(ra) # 800019ae <myproc>
    80002a8e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002a90:	00010517          	auipc	a0,0x10
    80002a94:	86850513          	addi	a0,a0,-1944 # 800122f8 <wait_lock>
    80002a98:	ffffe097          	auipc	ra,0xffffe
    80002a9c:	14a080e7          	jalr	330(ra) # 80000be2 <acquire>
  int found=0;
    80002aa0:	4c81                	li	s9,0
        if(np->state == ZOMBIE){
    80002aa2:	4a95                	li	s5,5
    for(np = proc; np < &proc[NPROC]; np++){
    80002aa4:	00016997          	auipc	s3,0x16
    80002aa8:	06c98993          	addi	s3,s3,108 # 80018b10 <tickslock>
	found = 1;
    80002aac:	4b05                	li	s6,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002aae:	00010b97          	auipc	s7,0x10
    80002ab2:	84ab8b93          	addi	s7,s7,-1974 # 800122f8 <wait_lock>
    80002ab6:	a0d1                	j	80002b7a <waitpid+0x112>
           if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002ab8:	000c0e63          	beqz	s8,80002ad4 <waitpid+0x6c>
    80002abc:	4691                	li	a3,4
    80002abe:	02c48613          	addi	a2,s1,44
    80002ac2:	85e2                	mv	a1,s8
    80002ac4:	05093503          	ld	a0,80(s2)
    80002ac8:	fffff097          	auipc	ra,0xfffff
    80002acc:	ba8080e7          	jalr	-1112(ra) # 80001670 <copyout>
    80002ad0:	04054263          	bltz	a0,80002b14 <waitpid+0xac>
           freeproc(np);
    80002ad4:	8526                	mv	a0,s1
    80002ad6:	fffff097          	auipc	ra,0xfffff
    80002ada:	0c2080e7          	jalr	194(ra) # 80001b98 <freeproc>
           release(&np->lock);
    80002ade:	8526                	mv	a0,s1
    80002ae0:	ffffe097          	auipc	ra,0xffffe
    80002ae4:	1b6080e7          	jalr	438(ra) # 80000c96 <release>
           release(&wait_lock);
    80002ae8:	00010517          	auipc	a0,0x10
    80002aec:	81050513          	addi	a0,a0,-2032 # 800122f8 <wait_lock>
    80002af0:	ffffe097          	auipc	ra,0xffffe
    80002af4:	1a6080e7          	jalr	422(ra) # 80000c96 <release>
           return pid;
    80002af8:	8552                	mv	a0,s4
}
    80002afa:	60e6                	ld	ra,88(sp)
    80002afc:	6446                	ld	s0,80(sp)
    80002afe:	64a6                	ld	s1,72(sp)
    80002b00:	6906                	ld	s2,64(sp)
    80002b02:	79e2                	ld	s3,56(sp)
    80002b04:	7a42                	ld	s4,48(sp)
    80002b06:	7aa2                	ld	s5,40(sp)
    80002b08:	7b02                	ld	s6,32(sp)
    80002b0a:	6be2                	ld	s7,24(sp)
    80002b0c:	6c42                	ld	s8,16(sp)
    80002b0e:	6ca2                	ld	s9,8(sp)
    80002b10:	6125                	addi	sp,sp,96
    80002b12:	8082                	ret
             release(&np->lock);
    80002b14:	8526                	mv	a0,s1
    80002b16:	ffffe097          	auipc	ra,0xffffe
    80002b1a:	180080e7          	jalr	384(ra) # 80000c96 <release>
             release(&wait_lock);
    80002b1e:	0000f517          	auipc	a0,0xf
    80002b22:	7da50513          	addi	a0,a0,2010 # 800122f8 <wait_lock>
    80002b26:	ffffe097          	auipc	ra,0xffffe
    80002b2a:	170080e7          	jalr	368(ra) # 80000c96 <release>
             return -1;
    80002b2e:	557d                	li	a0,-1
    80002b30:	b7e9                	j	80002afa <waitpid+0x92>
    for(np = proc; np < &proc[NPROC]; np++){
    80002b32:	19048493          	addi	s1,s1,400
    80002b36:	03348763          	beq	s1,s3,80002b64 <waitpid+0xfc>
      if((np->parent == p) && (np->pid == pid)){
    80002b3a:	7c9c                	ld	a5,56(s1)
    80002b3c:	ff279be3          	bne	a5,s2,80002b32 <waitpid+0xca>
    80002b40:	589c                	lw	a5,48(s1)
    80002b42:	ff4798e3          	bne	a5,s4,80002b32 <waitpid+0xca>
        acquire(&np->lock);
    80002b46:	8526                	mv	a0,s1
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	09a080e7          	jalr	154(ra) # 80000be2 <acquire>
        if(np->state == ZOMBIE){
    80002b50:	4c9c                	lw	a5,24(s1)
    80002b52:	f75783e3          	beq	a5,s5,80002ab8 <waitpid+0x50>
        release(&np->lock);
    80002b56:	8526                	mv	a0,s1
    80002b58:	ffffe097          	auipc	ra,0xffffe
    80002b5c:	13e080e7          	jalr	318(ra) # 80000c96 <release>
	found = 1;
    80002b60:	8cda                	mv	s9,s6
    80002b62:	bfc1                	j	80002b32 <waitpid+0xca>
    if(!found || p->killed){
    80002b64:	020c8063          	beqz	s9,80002b84 <waitpid+0x11c>
    80002b68:	02892783          	lw	a5,40(s2)
    80002b6c:	ef81                	bnez	a5,80002b84 <waitpid+0x11c>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002b6e:	85de                	mv	a1,s7
    80002b70:	854a                	mv	a0,s2
    80002b72:	00000097          	auipc	ra,0x0
    80002b76:	b84080e7          	jalr	-1148(ra) # 800026f6 <sleep>
    for(np = proc; np < &proc[NPROC]; np++){
    80002b7a:	00010497          	auipc	s1,0x10
    80002b7e:	b9648493          	addi	s1,s1,-1130 # 80012710 <proc>
    80002b82:	bf65                	j	80002b3a <waitpid+0xd2>
      release(&wait_lock);
    80002b84:	0000f517          	auipc	a0,0xf
    80002b88:	77450513          	addi	a0,a0,1908 # 800122f8 <wait_lock>
    80002b8c:	ffffe097          	auipc	ra,0xffffe
    80002b90:	10a080e7          	jalr	266(ra) # 80000c96 <release>
      return -1;
    80002b94:	557d                	li	a0,-1
    80002b96:	b795                	j	80002afa <waitpid+0x92>

0000000080002b98 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002b98:	7139                	addi	sp,sp,-64
    80002b9a:	fc06                	sd	ra,56(sp)
    80002b9c:	f822                	sd	s0,48(sp)
    80002b9e:	f426                	sd	s1,40(sp)
    80002ba0:	f04a                	sd	s2,32(sp)
    80002ba2:	ec4e                	sd	s3,24(sp)
    80002ba4:	e852                	sd	s4,16(sp)
    80002ba6:	e456                	sd	s5,8(sp)
    80002ba8:	0080                	addi	s0,sp,64
    80002baa:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002bac:	00010497          	auipc	s1,0x10
    80002bb0:	b6448493          	addi	s1,s1,-1180 # 80012710 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002bb4:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002bb6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002bb8:	00016917          	auipc	s2,0x16
    80002bbc:	f5890913          	addi	s2,s2,-168 # 80018b10 <tickslock>
    80002bc0:	a821                	j	80002bd8 <wakeup+0x40>
        p->state = RUNNABLE;
    80002bc2:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    80002bc6:	8526                	mv	a0,s1
    80002bc8:	ffffe097          	auipc	ra,0xffffe
    80002bcc:	0ce080e7          	jalr	206(ra) # 80000c96 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002bd0:	19048493          	addi	s1,s1,400
    80002bd4:	03248463          	beq	s1,s2,80002bfc <wakeup+0x64>
    if(p != myproc()){
    80002bd8:	fffff097          	auipc	ra,0xfffff
    80002bdc:	dd6080e7          	jalr	-554(ra) # 800019ae <myproc>
    80002be0:	fea488e3          	beq	s1,a0,80002bd0 <wakeup+0x38>
      acquire(&p->lock);
    80002be4:	8526                	mv	a0,s1
    80002be6:	ffffe097          	auipc	ra,0xffffe
    80002bea:	ffc080e7          	jalr	-4(ra) # 80000be2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002bee:	4c9c                	lw	a5,24(s1)
    80002bf0:	fd379be3          	bne	a5,s3,80002bc6 <wakeup+0x2e>
    80002bf4:	709c                	ld	a5,32(s1)
    80002bf6:	fd4798e3          	bne	a5,s4,80002bc6 <wakeup+0x2e>
    80002bfa:	b7e1                	j	80002bc2 <wakeup+0x2a>
    }
  }
}
    80002bfc:	70e2                	ld	ra,56(sp)
    80002bfe:	7442                	ld	s0,48(sp)
    80002c00:	74a2                	ld	s1,40(sp)
    80002c02:	7902                	ld	s2,32(sp)
    80002c04:	69e2                	ld	s3,24(sp)
    80002c06:	6a42                	ld	s4,16(sp)
    80002c08:	6aa2                	ld	s5,8(sp)
    80002c0a:	6121                	addi	sp,sp,64
    80002c0c:	8082                	ret

0000000080002c0e <reparent>:
{
    80002c0e:	7179                	addi	sp,sp,-48
    80002c10:	f406                	sd	ra,40(sp)
    80002c12:	f022                	sd	s0,32(sp)
    80002c14:	ec26                	sd	s1,24(sp)
    80002c16:	e84a                	sd	s2,16(sp)
    80002c18:	e44e                	sd	s3,8(sp)
    80002c1a:	e052                	sd	s4,0(sp)
    80002c1c:	1800                	addi	s0,sp,48
    80002c1e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002c20:	00010497          	auipc	s1,0x10
    80002c24:	af048493          	addi	s1,s1,-1296 # 80012710 <proc>
      pp->parent = initproc;
    80002c28:	00007a17          	auipc	s4,0x7
    80002c2c:	440a0a13          	addi	s4,s4,1088 # 8000a068 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002c30:	00016997          	auipc	s3,0x16
    80002c34:	ee098993          	addi	s3,s3,-288 # 80018b10 <tickslock>
    80002c38:	a029                	j	80002c42 <reparent+0x34>
    80002c3a:	19048493          	addi	s1,s1,400
    80002c3e:	01348d63          	beq	s1,s3,80002c58 <reparent+0x4a>
    if(pp->parent == p){
    80002c42:	7c9c                	ld	a5,56(s1)
    80002c44:	ff279be3          	bne	a5,s2,80002c3a <reparent+0x2c>
      pp->parent = initproc;
    80002c48:	000a3503          	ld	a0,0(s4)
    80002c4c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002c4e:	00000097          	auipc	ra,0x0
    80002c52:	f4a080e7          	jalr	-182(ra) # 80002b98 <wakeup>
    80002c56:	b7d5                	j	80002c3a <reparent+0x2c>
}
    80002c58:	70a2                	ld	ra,40(sp)
    80002c5a:	7402                	ld	s0,32(sp)
    80002c5c:	64e2                	ld	s1,24(sp)
    80002c5e:	6942                	ld	s2,16(sp)
    80002c60:	69a2                	ld	s3,8(sp)
    80002c62:	6a02                	ld	s4,0(sp)
    80002c64:	6145                	addi	sp,sp,48
    80002c66:	8082                	ret

0000000080002c68 <exit>:
{
    80002c68:	7139                	addi	sp,sp,-64
    80002c6a:	fc06                	sd	ra,56(sp)
    80002c6c:	f822                	sd	s0,48(sp)
    80002c6e:	f426                	sd	s1,40(sp)
    80002c70:	f04a                	sd	s2,32(sp)
    80002c72:	ec4e                	sd	s3,24(sp)
    80002c74:	e852                	sd	s4,16(sp)
    80002c76:	e456                	sd	s5,8(sp)
    80002c78:	0080                	addi	s0,sp,64
    80002c7a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002c7c:	fffff097          	auipc	ra,0xfffff
    80002c80:	d32080e7          	jalr	-718(ra) # 800019ae <myproc>
    80002c84:	892a                	mv	s2,a0
  if(p == initproc)
    80002c86:	00007797          	auipc	a5,0x7
    80002c8a:	3e27b783          	ld	a5,994(a5) # 8000a068 <initproc>
    80002c8e:	0d050493          	addi	s1,a0,208
    80002c92:	15050993          	addi	s3,a0,336
    80002c96:	02a79363          	bne	a5,a0,80002cbc <exit+0x54>
    panic("init exiting");
    80002c9a:	00006517          	auipc	a0,0x6
    80002c9e:	5c650513          	addi	a0,a0,1478 # 80009260 <digits+0x220>
    80002ca2:	ffffe097          	auipc	ra,0xffffe
    80002ca6:	89a080e7          	jalr	-1894(ra) # 8000053c <panic>
      fileclose(f);
    80002caa:	00003097          	auipc	ra,0x3
    80002cae:	9da080e7          	jalr	-1574(ra) # 80005684 <fileclose>
      p->ofile[fd] = 0;
    80002cb2:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002cb6:	04a1                	addi	s1,s1,8
    80002cb8:	00998563          	beq	s3,s1,80002cc2 <exit+0x5a>
    if(p->ofile[fd]){
    80002cbc:	6088                	ld	a0,0(s1)
    80002cbe:	f575                	bnez	a0,80002caa <exit+0x42>
    80002cc0:	bfdd                	j	80002cb6 <exit+0x4e>
  begin_op();
    80002cc2:	00002097          	auipc	ra,0x2
    80002cc6:	4f6080e7          	jalr	1270(ra) # 800051b8 <begin_op>
  iput(p->cwd);
    80002cca:	15093503          	ld	a0,336(s2)
    80002cce:	00002097          	auipc	ra,0x2
    80002cd2:	cd2080e7          	jalr	-814(ra) # 800049a0 <iput>
  end_op();
    80002cd6:	00002097          	auipc	ra,0x2
    80002cda:	562080e7          	jalr	1378(ra) # 80005238 <end_op>
  p->cwd = 0;
    80002cde:	14093823          	sd	zero,336(s2)
  acquire(&wait_lock);
    80002ce2:	0000f497          	auipc	s1,0xf
    80002ce6:	61648493          	addi	s1,s1,1558 # 800122f8 <wait_lock>
    80002cea:	8526                	mv	a0,s1
    80002cec:	ffffe097          	auipc	ra,0xffffe
    80002cf0:	ef6080e7          	jalr	-266(ra) # 80000be2 <acquire>
  reparent(p);
    80002cf4:	854a                	mv	a0,s2
    80002cf6:	00000097          	auipc	ra,0x0
    80002cfa:	f18080e7          	jalr	-232(ra) # 80002c0e <reparent>
  wakeup(p->parent);
    80002cfe:	03893503          	ld	a0,56(s2)
    80002d02:	00000097          	auipc	ra,0x0
    80002d06:	e96080e7          	jalr	-362(ra) # 80002b98 <wakeup>
  acquire(&p->lock);
    80002d0a:	854a                	mv	a0,s2
    80002d0c:	ffffe097          	auipc	ra,0xffffe
    80002d10:	ed6080e7          	jalr	-298(ra) # 80000be2 <acquire>
  p->xstate = status;
    80002d14:	03492623          	sw	s4,44(s2)
  p->state = ZOMBIE;
    80002d18:	4795                	li	a5,5
    80002d1a:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    80002d1e:	8526                	mv	a0,s1
    80002d20:	ffffe097          	auipc	ra,0xffffe
    80002d24:	f76080e7          	jalr	-138(ra) # 80000c96 <release>
  acquire(&tickslock);
    80002d28:	00016517          	auipc	a0,0x16
    80002d2c:	de850513          	addi	a0,a0,-536 # 80018b10 <tickslock>
    80002d30:	ffffe097          	auipc	ra,0xffffe
    80002d34:	eb2080e7          	jalr	-334(ra) # 80000be2 <acquire>
  xticks = ticks;
    80002d38:	00007497          	auipc	s1,0x7
    80002d3c:	3384a483          	lw	s1,824(s1) # 8000a070 <ticks>
  release(&tickslock);
    80002d40:	00016517          	auipc	a0,0x16
    80002d44:	dd050513          	addi	a0,a0,-560 # 80018b10 <tickslock>
    80002d48:	ffffe097          	auipc	ra,0xffffe
    80002d4c:	f4e080e7          	jalr	-178(ra) # 80000c96 <release>
  p->endtime = xticks;
    80002d50:	16992823          	sw	s1,368(s2)
      if (!holding(&tickslock)) {
    80002d54:	00016517          	auipc	a0,0x16
    80002d58:	dbc50513          	addi	a0,a0,-580 # 80018b10 <tickslock>
    80002d5c:	ffffe097          	auipc	ra,0xffffe
    80002d60:	e0c080e7          	jalr	-500(ra) # 80000b68 <holding>
    80002d64:	cd05                	beqz	a0,80002d9c <exit+0x134>
      else yticks = ticks;
    80002d66:	00007497          	auipc	s1,0x7
    80002d6a:	30a4a483          	lw	s1,778(s1) # 8000a070 <ticks>
      p->end_ticks = yticks;
    80002d6e:	18992223          	sw	s1,388(s2)
      if(p->batch == 1){
    80002d72:	18892703          	lw	a4,392(s2)
    80002d76:	4785                	li	a5,1
    80002d78:	04f70763          	beq	a4,a5,80002dc6 <exit+0x15e>
  for(p1 = proc; p1< &proc[NPROC]; p1++){
    80002d7c:	00010797          	auipc	a5,0x10
    80002d80:	99478793          	addi	a5,a5,-1644 # 80012710 <proc>
  int tot_exec = 0, maxexec = 0, minexec = 0;
    80002d84:	4481                	li	s1,0
    80002d86:	4901                	li	s2,0
    80002d88:	4981                	li	s3,0
  int sum = 0;
    80002d8a:	4a01                	li	s4,0
  int minstart = 0, maxend = 0;
    80002d8c:	4801                	li	a6,0
    80002d8e:	4581                	li	a1,0
    if(p1->batch == 1){
    80002d90:	4505                	li	a0,1
  for(p1 = proc; p1< &proc[NPROC]; p1++){
    80002d92:	00016617          	auipc	a2,0x16
    80002d96:	d7e60613          	addi	a2,a2,-642 # 80018b10 <tickslock>
    80002d9a:	a8fd                	j	80002e98 <exit+0x230>
        acquire(&tickslock);
    80002d9c:	00016517          	auipc	a0,0x16
    80002da0:	d7450513          	addi	a0,a0,-652 # 80018b10 <tickslock>
    80002da4:	ffffe097          	auipc	ra,0xffffe
    80002da8:	e3e080e7          	jalr	-450(ra) # 80000be2 <acquire>
        yticks = ticks;
    80002dac:	00007497          	auipc	s1,0x7
    80002db0:	2c44a483          	lw	s1,708(s1) # 8000a070 <ticks>
        release(&tickslock);
    80002db4:	00016517          	auipc	a0,0x16
    80002db8:	d5c50513          	addi	a0,a0,-676 # 80018b10 <tickslock>
    80002dbc:	ffffe097          	auipc	ra,0xffffe
    80002dc0:	eda080e7          	jalr	-294(ra) # 80000c96 <release>
    80002dc4:	b76d                	j	80002d6e <exit+0x106>
        curr_batch -- ;
    80002dc6:	00007717          	auipc	a4,0x7
    80002dca:	29a70713          	addi	a4,a4,666 # 8000a060 <curr_batch>
    80002dce:	431c                	lw	a5,0(a4)
    80002dd0:	37fd                	addiw	a5,a5,-1
    80002dd2:	c31c                	sw	a5,0(a4)
      if(p->batch ==1 && p->end_ticks > p->start_ticks){
    80002dd4:	18092783          	lw	a5,384(s2)
    80002dd8:	fa97f2e3          	bgeu	a5,s1,80002d7c <exit+0x114>
      if(max_burst < p->end_ticks - p->start_ticks){
    80002ddc:	40f4873b          	subw	a4,s1,a5
    80002de0:	0007061b          	sext.w	a2,a4
    80002de4:	00007697          	auipc	a3,0x7
    80002de8:	26c6a683          	lw	a3,620(a3) # 8000a050 <max_burst>
    80002dec:	00c6f663          	bgeu	a3,a2,80002df8 <exit+0x190>
        max_burst = p->end_ticks - p->start_ticks;
    80002df0:	00007697          	auipc	a3,0x7
    80002df4:	26e6a023          	sw	a4,608(a3) # 8000a050 <max_burst>
      if(mi_burst == 0){
    80002df8:	00007697          	auipc	a3,0x7
    80002dfc:	2546a683          	lw	a3,596(a3) # 8000a04c <mi_burst>
    80002e00:	eab1                	bnez	a3,80002e54 <exit+0x1ec>
        mi_burst = p->end_ticks - p->start_ticks;
    80002e02:	00007697          	auipc	a3,0x7
    80002e06:	24e6a523          	sw	a4,586(a3) # 8000a04c <mi_burst>
      sum_burst += p->end_ticks - p->start_ticks;
    80002e0a:	00007597          	auipc	a1,0x7
    80002e0e:	23e58593          	addi	a1,a1,574 # 8000a048 <sum_burst>
    80002e12:	4194                	lw	a3,0(a1)
    80002e14:	9eb9                	addw	a3,a3,a4
    80002e16:	c194                	sw	a3,0(a1)
      total_burst ++ ;
    80002e18:	00007597          	auipc	a1,0x7
    80002e1c:	23c58593          	addi	a1,a1,572 # 8000a054 <total_burst>
    80002e20:	4194                	lw	a3,0(a1)
    80002e22:	2685                	addiw	a3,a3,1
    80002e24:	c194                	sw	a3,0(a1)
      if(p->estimate > 0){
    80002e26:	18c92683          	lw	a3,396(s2)
    80002e2a:	ce85                	beqz	a3,80002e62 <exit+0x1fa>
        err_burst ++ ;
    80002e2c:	00007517          	auipc	a0,0x7
    80002e30:	20c50513          	addi	a0,a0,524 # 8000a038 <err_burst>
    80002e34:	410c                	lw	a1,0(a0)
    80002e36:	2585                	addiw	a1,a1,1
    80002e38:	c10c                	sw	a1,0(a0)
        if(p->estimate > p->end_ticks - p->start_ticks){
    80002e3a:	02d67463          	bgeu	a2,a3,80002e62 <exit+0x1fa>
          err_sum += p->estimate - (p->end_ticks - p->start_ticks);
    80002e3e:	00007717          	auipc	a4,0x7
    80002e42:	1f670713          	addi	a4,a4,502 # 8000a034 <err_sum>
    80002e46:	9fb5                	addw	a5,a5,a3
    80002e48:	4314                	lw	a3,0(a4)
    80002e4a:	9fb5                	addw	a5,a5,a3
    80002e4c:	409784bb          	subw	s1,a5,s1
    80002e50:	c304                	sw	s1,0(a4)
    80002e52:	b72d                	j	80002d7c <exit+0x114>
      else if(mi_burst > p->end_ticks - p->start_ticks){
    80002e54:	fad67be3          	bgeu	a2,a3,80002e0a <exit+0x1a2>
        mi_burst = p->end_ticks - p->start_ticks;
    80002e58:	00007697          	auipc	a3,0x7
    80002e5c:	1ee6aa23          	sw	a4,500(a3) # 8000a04c <mi_burst>
    80002e60:	b76d                	j	80002e0a <exit+0x1a2>
          err_sum += (p->end_ticks - p->start_ticks) - p->estimate;
    80002e62:	00007617          	auipc	a2,0x7
    80002e66:	1d260613          	addi	a2,a2,466 # 8000a034 <err_sum>
    80002e6a:	421c                	lw	a5,0(a2)
    80002e6c:	9f95                	subw	a5,a5,a3
    80002e6e:	9f3d                	addw	a4,a4,a5
    80002e70:	c218                	sw	a4,0(a2)
    80002e72:	b729                	j	80002d7c <exit+0x114>
      else if(minstart > p1->stime){
    80002e74:	16c7a703          	lw	a4,364(a5)
    80002e78:	0007069b          	sext.w	a3,a4
    80002e7c:	00d5d363          	bge	a1,a3,80002e82 <exit+0x21a>
    80002e80:	872e                	mv	a4,a1
    80002e82:	0007059b          	sext.w	a1,a4
    80002e86:	a005                	j	80002ea6 <exit+0x23e>
    80002e88:	0006891b          	sext.w	s2,a3
      tot_exec += p1->endtime;
    80002e8c:	013709bb          	addw	s3,a4,s3
  for(p1 = proc; p1< &proc[NPROC]; p1++){
    80002e90:	19078793          	addi	a5,a5,400
    80002e94:	04c78463          	beq	a5,a2,80002edc <exit+0x274>
    if(p1->batch == 1){
    80002e98:	1887a703          	lw	a4,392(a5)
    80002e9c:	fea71ae3          	bne	a4,a0,80002e90 <exit+0x228>
      if(minstart == 0){
    80002ea0:	f9f1                	bnez	a1,80002e74 <exit+0x20c>
        minstart = p1->stime;
    80002ea2:	16c7a583          	lw	a1,364(a5)
      if(maxend < p1->endtime){
    80002ea6:	1707a703          	lw	a4,368(a5)
    80002eaa:	86ba                	mv	a3,a4
    80002eac:	01075363          	bge	a4,a6,80002eb2 <exit+0x24a>
    80002eb0:	86c2                	mv	a3,a6
    80002eb2:	0006881b          	sext.w	a6,a3
      sum += p1->endtime - p1->ctime;
    80002eb6:	1687a683          	lw	a3,360(a5)
    80002eba:	40d706bb          	subw	a3,a4,a3
    80002ebe:	01468a3b          	addw	s4,a3,s4
      if(minexec == 0){
    80002ec2:	e091                	bnez	s1,80002ec6 <exit+0x25e>
        minexec = p1->endtime;
    80002ec4:	84ba                	mv	s1,a4
      if(minexec > p1->endtime){
    80002ec6:	86ba                	mv	a3,a4
    80002ec8:	00e4d363          	bge	s1,a4,80002ece <exit+0x266>
    80002ecc:	86a6                	mv	a3,s1
    80002ece:	0006849b          	sext.w	s1,a3
      if(maxexec < p1->endtime){
    80002ed2:	86ba                	mv	a3,a4
    80002ed4:	fb275ae3          	bge	a4,s2,80002e88 <exit+0x220>
    80002ed8:	86ca                	mv	a3,s2
    80002eda:	b77d                	j	80002e88 <exit+0x220>
   if(curr_batch == 0){
    80002edc:	00007797          	auipc	a5,0x7
    80002ee0:	1847a783          	lw	a5,388(a5) # 8000a060 <curr_batch>
    80002ee4:	cf89                	beqz	a5,80002efe <exit+0x296>
  sched();
    80002ee6:	fffff097          	auipc	ra,0xfffff
    80002eea:	510080e7          	jalr	1296(ra) # 800023f6 <sched>
  panic("zombie exit");
    80002eee:	00006517          	auipc	a0,0x6
    80002ef2:	4ba50513          	addi	a0,a0,1210 # 800093a8 <digits+0x368>
    80002ef6:	ffffd097          	auipc	ra,0xffffd
    80002efa:	646080e7          	jalr	1606(ra) # 8000053c <panic>
    printf("Batch execution time: %d\n", maxend - minstart);
    80002efe:	40b805bb          	subw	a1,a6,a1
    80002f02:	00006517          	auipc	a0,0x6
    80002f06:	36e50513          	addi	a0,a0,878 # 80009270 <digits+0x230>
    80002f0a:	ffffd097          	auipc	ra,0xffffd
    80002f0e:	67c080e7          	jalr	1660(ra) # 80000586 <printf>
    printf("Average turn-around time: %d\n", sum/net_batch);
    80002f12:	00007a97          	auipc	s5,0x7
    80002f16:	14aa8a93          	addi	s5,s5,330 # 8000a05c <net_batch>
    80002f1a:	000aa583          	lw	a1,0(s5)
    80002f1e:	02ba45bb          	divw	a1,s4,a1
    80002f22:	00006517          	auipc	a0,0x6
    80002f26:	36e50513          	addi	a0,a0,878 # 80009290 <digits+0x250>
    80002f2a:	ffffd097          	auipc	ra,0xffffd
    80002f2e:	65c080e7          	jalr	1628(ra) # 80000586 <printf>
    printf("Average waiting time: %d\n", wait_sum/net_batch);
    80002f32:	000aa783          	lw	a5,0(s5)
    80002f36:	00007597          	auipc	a1,0x7
    80002f3a:	1225a583          	lw	a1,290(a1) # 8000a058 <wait_sum>
    80002f3e:	02f5d5bb          	divuw	a1,a1,a5
    80002f42:	00006517          	auipc	a0,0x6
    80002f46:	36e50513          	addi	a0,a0,878 # 800092b0 <digits+0x270>
    80002f4a:	ffffd097          	auipc	ra,0xffffd
    80002f4e:	63c080e7          	jalr	1596(ra) # 80000586 <printf>
    printf("Completion time: avg: %d, max: %d, min: %d\n", tot_exec/net_batch , maxexec, minexec);
    80002f52:	000aa583          	lw	a1,0(s5)
    80002f56:	86a6                	mv	a3,s1
    80002f58:	864a                	mv	a2,s2
    80002f5a:	02b9c5bb          	divw	a1,s3,a1
    80002f5e:	00006517          	auipc	a0,0x6
    80002f62:	37250513          	addi	a0,a0,882 # 800092d0 <digits+0x290>
    80002f66:	ffffd097          	auipc	ra,0xffffd
    80002f6a:	620080e7          	jalr	1568(ra) # 80000586 <printf>
    if(SCHED_POLICY == SCHED_NPREEMPT_SJF){
    80002f6e:	00007717          	auipc	a4,0x7
    80002f72:	b0672703          	lw	a4,-1274(a4) # 80009a74 <SCHED_POLICY>
    80002f76:	4785                	li	a5,1
    80002f78:	06f70b63          	beq	a4,a5,80002fee <exit+0x386>
  curr_batch = 0; net_batch = 0;
    80002f7c:	00007797          	auipc	a5,0x7
    80002f80:	0e07a223          	sw	zero,228(a5) # 8000a060 <curr_batch>
    80002f84:	00007797          	auipc	a5,0x7
    80002f88:	0c07ac23          	sw	zero,216(a5) # 8000a05c <net_batch>
 wait_sum = 0;
    80002f8c:	00007797          	auipc	a5,0x7
    80002f90:	0c07a623          	sw	zero,204(a5) # 8000a058 <wait_sum>
 total_burst = 0;
    80002f94:	00007797          	auipc	a5,0x7
    80002f98:	0c07a023          	sw	zero,192(a5) # 8000a054 <total_burst>
 max_burst = 0; mi_burst = 0; sum_burst = 0;
    80002f9c:	00007797          	auipc	a5,0x7
    80002fa0:	0a07aa23          	sw	zero,180(a5) # 8000a050 <max_burst>
    80002fa4:	00007797          	auipc	a5,0x7
    80002fa8:	0a07a423          	sw	zero,168(a5) # 8000a04c <mi_burst>
    80002fac:	00007797          	auipc	a5,0x7
    80002fb0:	0807ae23          	sw	zero,156(a5) # 8000a048 <sum_burst>
 est_max = 0; mi_est = 0; sum_est = 0;
    80002fb4:	00007797          	auipc	a5,0x7
    80002fb8:	0807a823          	sw	zero,144(a5) # 8000a044 <est_max>
    80002fbc:	00007797          	auipc	a5,0x7
    80002fc0:	0807a223          	sw	zero,132(a5) # 8000a040 <mi_est>
    80002fc4:	00007797          	auipc	a5,0x7
    80002fc8:	0607ac23          	sw	zero,120(a5) # 8000a03c <sum_est>
 err_burst = 0; err_sum = 0;
    80002fcc:	00007797          	auipc	a5,0x7
    80002fd0:	0607a623          	sw	zero,108(a5) # 8000a038 <err_burst>
    80002fd4:	00007797          	auipc	a5,0x7
    80002fd8:	0607a023          	sw	zero,96(a5) # 8000a034 <err_sum>
 min_burst = 0;
    80002fdc:	00007797          	auipc	a5,0x7
    80002fe0:	0407aa23          	sw	zero,84(a5) # 8000a030 <min_burst>
 min_prio = 0;
    80002fe4:	00007797          	auipc	a5,0x7
    80002fe8:	0407a423          	sw	zero,72(a5) # 8000a02c <min_prio>
    80002fec:	bded                	j	80002ee6 <exit+0x27e>
      printf("CPU bursts: count: %d, avg: %d, max: %d, min: %d\n", total_burst, sum_burst/total_burst, max_burst, mi_burst);
    80002fee:	00007497          	auipc	s1,0x7
    80002ff2:	06648493          	addi	s1,s1,102 # 8000a054 <total_burst>
    80002ff6:	408c                	lw	a1,0(s1)
    80002ff8:	00007717          	auipc	a4,0x7
    80002ffc:	05472703          	lw	a4,84(a4) # 8000a04c <mi_burst>
    80003000:	00007697          	auipc	a3,0x7
    80003004:	0506a683          	lw	a3,80(a3) # 8000a050 <max_burst>
    80003008:	00007617          	auipc	a2,0x7
    8000300c:	04062603          	lw	a2,64(a2) # 8000a048 <sum_burst>
    80003010:	02b6563b          	divuw	a2,a2,a1
    80003014:	00006517          	auipc	a0,0x6
    80003018:	2ec50513          	addi	a0,a0,748 # 80009300 <digits+0x2c0>
    8000301c:	ffffd097          	auipc	ra,0xffffd
    80003020:	56a080e7          	jalr	1386(ra) # 80000586 <printf>
      printf("CPU burst estimates: count: %d, avg: %d, max: %d, min: %d\n", total_burst, sum_est/total_burst, est_max, mi_est);
    80003024:	408c                	lw	a1,0(s1)
    80003026:	00007717          	auipc	a4,0x7
    8000302a:	01a72703          	lw	a4,26(a4) # 8000a040 <mi_est>
    8000302e:	00007697          	auipc	a3,0x7
    80003032:	0166a683          	lw	a3,22(a3) # 8000a044 <est_max>
    80003036:	00007617          	auipc	a2,0x7
    8000303a:	00662603          	lw	a2,6(a2) # 8000a03c <sum_est>
    8000303e:	02b6563b          	divuw	a2,a2,a1
    80003042:	00006517          	auipc	a0,0x6
    80003046:	2f650513          	addi	a0,a0,758 # 80009338 <digits+0x2f8>
    8000304a:	ffffd097          	auipc	ra,0xffffd
    8000304e:	53c080e7          	jalr	1340(ra) # 80000586 <printf>
      printf("CPU burst estimation error: count: %d, avg: %d\n", err_burst, err_sum/err_burst);
    80003052:	00007597          	auipc	a1,0x7
    80003056:	fe65a583          	lw	a1,-26(a1) # 8000a038 <err_burst>
    8000305a:	00007617          	auipc	a2,0x7
    8000305e:	fda62603          	lw	a2,-38(a2) # 8000a034 <err_sum>
    80003062:	02b6563b          	divuw	a2,a2,a1
    80003066:	00006517          	auipc	a0,0x6
    8000306a:	31250513          	addi	a0,a0,786 # 80009378 <digits+0x338>
    8000306e:	ffffd097          	auipc	ra,0xffffd
    80003072:	518080e7          	jalr	1304(ra) # 80000586 <printf>
    80003076:	b719                	j	80002f7c <exit+0x314>

0000000080003078 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80003078:	7179                	addi	sp,sp,-48
    8000307a:	f406                	sd	ra,40(sp)
    8000307c:	f022                	sd	s0,32(sp)
    8000307e:	ec26                	sd	s1,24(sp)
    80003080:	e84a                	sd	s2,16(sp)
    80003082:	e44e                	sd	s3,8(sp)
    80003084:	1800                	addi	s0,sp,48
    80003086:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80003088:	0000f497          	auipc	s1,0xf
    8000308c:	68848493          	addi	s1,s1,1672 # 80012710 <proc>
    80003090:	00016997          	auipc	s3,0x16
    80003094:	a8098993          	addi	s3,s3,-1408 # 80018b10 <tickslock>
    acquire(&p->lock);
    80003098:	8526                	mv	a0,s1
    8000309a:	ffffe097          	auipc	ra,0xffffe
    8000309e:	b48080e7          	jalr	-1208(ra) # 80000be2 <acquire>
    if(p->pid == pid){
    800030a2:	589c                	lw	a5,48(s1)
    800030a4:	01278d63          	beq	a5,s2,800030be <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800030a8:	8526                	mv	a0,s1
    800030aa:	ffffe097          	auipc	ra,0xffffe
    800030ae:	bec080e7          	jalr	-1044(ra) # 80000c96 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800030b2:	19048493          	addi	s1,s1,400
    800030b6:	ff3491e3          	bne	s1,s3,80003098 <kill+0x20>
  }
  return -1;
    800030ba:	557d                	li	a0,-1
    800030bc:	a829                	j	800030d6 <kill+0x5e>
      p->killed = 1;
    800030be:	4785                	li	a5,1
    800030c0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800030c2:	4c98                	lw	a4,24(s1)
    800030c4:	4789                	li	a5,2
    800030c6:	00f70f63          	beq	a4,a5,800030e4 <kill+0x6c>
      release(&p->lock);
    800030ca:	8526                	mv	a0,s1
    800030cc:	ffffe097          	auipc	ra,0xffffe
    800030d0:	bca080e7          	jalr	-1078(ra) # 80000c96 <release>
      return 0;
    800030d4:	4501                	li	a0,0
}
    800030d6:	70a2                	ld	ra,40(sp)
    800030d8:	7402                	ld	s0,32(sp)
    800030da:	64e2                	ld	s1,24(sp)
    800030dc:	6942                	ld	s2,16(sp)
    800030de:	69a2                	ld	s3,8(sp)
    800030e0:	6145                	addi	sp,sp,48
    800030e2:	8082                	ret
        p->state = RUNNABLE;
    800030e4:	478d                	li	a5,3
    800030e6:	cc9c                	sw	a5,24(s1)
    800030e8:	b7cd                	j	800030ca <kill+0x52>

00000000800030ea <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800030ea:	7179                	addi	sp,sp,-48
    800030ec:	f406                	sd	ra,40(sp)
    800030ee:	f022                	sd	s0,32(sp)
    800030f0:	ec26                	sd	s1,24(sp)
    800030f2:	e84a                	sd	s2,16(sp)
    800030f4:	e44e                	sd	s3,8(sp)
    800030f6:	e052                	sd	s4,0(sp)
    800030f8:	1800                	addi	s0,sp,48
    800030fa:	84aa                	mv	s1,a0
    800030fc:	892e                	mv	s2,a1
    800030fe:	89b2                	mv	s3,a2
    80003100:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80003102:	fffff097          	auipc	ra,0xfffff
    80003106:	8ac080e7          	jalr	-1876(ra) # 800019ae <myproc>
  if(user_dst){
    8000310a:	c08d                	beqz	s1,8000312c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000310c:	86d2                	mv	a3,s4
    8000310e:	864e                	mv	a2,s3
    80003110:	85ca                	mv	a1,s2
    80003112:	6928                	ld	a0,80(a0)
    80003114:	ffffe097          	auipc	ra,0xffffe
    80003118:	55c080e7          	jalr	1372(ra) # 80001670 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000311c:	70a2                	ld	ra,40(sp)
    8000311e:	7402                	ld	s0,32(sp)
    80003120:	64e2                	ld	s1,24(sp)
    80003122:	6942                	ld	s2,16(sp)
    80003124:	69a2                	ld	s3,8(sp)
    80003126:	6a02                	ld	s4,0(sp)
    80003128:	6145                	addi	sp,sp,48
    8000312a:	8082                	ret
    memmove((char *)dst, src, len);
    8000312c:	000a061b          	sext.w	a2,s4
    80003130:	85ce                	mv	a1,s3
    80003132:	854a                	mv	a0,s2
    80003134:	ffffe097          	auipc	ra,0xffffe
    80003138:	c0a080e7          	jalr	-1014(ra) # 80000d3e <memmove>
    return 0;
    8000313c:	8526                	mv	a0,s1
    8000313e:	bff9                	j	8000311c <either_copyout+0x32>

0000000080003140 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80003140:	7179                	addi	sp,sp,-48
    80003142:	f406                	sd	ra,40(sp)
    80003144:	f022                	sd	s0,32(sp)
    80003146:	ec26                	sd	s1,24(sp)
    80003148:	e84a                	sd	s2,16(sp)
    8000314a:	e44e                	sd	s3,8(sp)
    8000314c:	e052                	sd	s4,0(sp)
    8000314e:	1800                	addi	s0,sp,48
    80003150:	892a                	mv	s2,a0
    80003152:	84ae                	mv	s1,a1
    80003154:	89b2                	mv	s3,a2
    80003156:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80003158:	fffff097          	auipc	ra,0xfffff
    8000315c:	856080e7          	jalr	-1962(ra) # 800019ae <myproc>
  if(user_src){
    80003160:	c08d                	beqz	s1,80003182 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80003162:	86d2                	mv	a3,s4
    80003164:	864e                	mv	a2,s3
    80003166:	85ca                	mv	a1,s2
    80003168:	6928                	ld	a0,80(a0)
    8000316a:	ffffe097          	auipc	ra,0xffffe
    8000316e:	592080e7          	jalr	1426(ra) # 800016fc <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80003172:	70a2                	ld	ra,40(sp)
    80003174:	7402                	ld	s0,32(sp)
    80003176:	64e2                	ld	s1,24(sp)
    80003178:	6942                	ld	s2,16(sp)
    8000317a:	69a2                	ld	s3,8(sp)
    8000317c:	6a02                	ld	s4,0(sp)
    8000317e:	6145                	addi	sp,sp,48
    80003180:	8082                	ret
    memmove(dst, (char*)src, len);
    80003182:	000a061b          	sext.w	a2,s4
    80003186:	85ce                	mv	a1,s3
    80003188:	854a                	mv	a0,s2
    8000318a:	ffffe097          	auipc	ra,0xffffe
    8000318e:	bb4080e7          	jalr	-1100(ra) # 80000d3e <memmove>
    return 0;
    80003192:	8526                	mv	a0,s1
    80003194:	bff9                	j	80003172 <either_copyin+0x32>

0000000080003196 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80003196:	715d                	addi	sp,sp,-80
    80003198:	e486                	sd	ra,72(sp)
    8000319a:	e0a2                	sd	s0,64(sp)
    8000319c:	fc26                	sd	s1,56(sp)
    8000319e:	f84a                	sd	s2,48(sp)
    800031a0:	f44e                	sd	s3,40(sp)
    800031a2:	f052                	sd	s4,32(sp)
    800031a4:	ec56                	sd	s5,24(sp)
    800031a6:	e85a                	sd	s6,16(sp)
    800031a8:	e45e                	sd	s7,8(sp)
    800031aa:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800031ac:	00006517          	auipc	a0,0x6
    800031b0:	59c50513          	addi	a0,a0,1436 # 80009748 <syscalls+0x108>
    800031b4:	ffffd097          	auipc	ra,0xffffd
    800031b8:	3d2080e7          	jalr	978(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800031bc:	0000f497          	auipc	s1,0xf
    800031c0:	6ac48493          	addi	s1,s1,1708 # 80012868 <proc+0x158>
    800031c4:	00016917          	auipc	s2,0x16
    800031c8:	aa490913          	addi	s2,s2,-1372 # 80018c68 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800031cc:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800031ce:	00006997          	auipc	s3,0x6
    800031d2:	1ea98993          	addi	s3,s3,490 # 800093b8 <digits+0x378>
    printf("%d %s %s", p->pid, state, p->name);
    800031d6:	00006a97          	auipc	s5,0x6
    800031da:	1eaa8a93          	addi	s5,s5,490 # 800093c0 <digits+0x380>
    printf("\n");
    800031de:	00006a17          	auipc	s4,0x6
    800031e2:	56aa0a13          	addi	s4,s4,1386 # 80009748 <syscalls+0x108>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800031e6:	00006b97          	auipc	s7,0x6
    800031ea:	272b8b93          	addi	s7,s7,626 # 80009458 <states.1821>
    800031ee:	a00d                	j	80003210 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800031f0:	ed86a583          	lw	a1,-296(a3)
    800031f4:	8556                	mv	a0,s5
    800031f6:	ffffd097          	auipc	ra,0xffffd
    800031fa:	390080e7          	jalr	912(ra) # 80000586 <printf>
    printf("\n");
    800031fe:	8552                	mv	a0,s4
    80003200:	ffffd097          	auipc	ra,0xffffd
    80003204:	386080e7          	jalr	902(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80003208:	19048493          	addi	s1,s1,400
    8000320c:	03248163          	beq	s1,s2,8000322e <procdump+0x98>
    if(p->state == UNUSED)
    80003210:	86a6                	mv	a3,s1
    80003212:	ec04a783          	lw	a5,-320(s1)
    80003216:	dbed                	beqz	a5,80003208 <procdump+0x72>
      state = "???";
    80003218:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000321a:	fcfb6be3          	bltu	s6,a5,800031f0 <procdump+0x5a>
    8000321e:	1782                	slli	a5,a5,0x20
    80003220:	9381                	srli	a5,a5,0x20
    80003222:	078e                	slli	a5,a5,0x3
    80003224:	97de                	add	a5,a5,s7
    80003226:	6390                	ld	a2,0(a5)
    80003228:	f661                	bnez	a2,800031f0 <procdump+0x5a>
      state = "???";
    8000322a:	864e                	mv	a2,s3
    8000322c:	b7d1                	j	800031f0 <procdump+0x5a>
  }
}
    8000322e:	60a6                	ld	ra,72(sp)
    80003230:	6406                	ld	s0,64(sp)
    80003232:	74e2                	ld	s1,56(sp)
    80003234:	7942                	ld	s2,48(sp)
    80003236:	79a2                	ld	s3,40(sp)
    80003238:	7a02                	ld	s4,32(sp)
    8000323a:	6ae2                	ld	s5,24(sp)
    8000323c:	6b42                	ld	s6,16(sp)
    8000323e:	6ba2                	ld	s7,8(sp)
    80003240:	6161                	addi	sp,sp,80
    80003242:	8082                	ret

0000000080003244 <ps>:

// Print a process listing to console with proper locks held.
// Caution: don't invoke too often; can slow down the machine.
int
ps(void)
{
    80003244:	7119                	addi	sp,sp,-128
    80003246:	fc86                	sd	ra,120(sp)
    80003248:	f8a2                	sd	s0,112(sp)
    8000324a:	f4a6                	sd	s1,104(sp)
    8000324c:	f0ca                	sd	s2,96(sp)
    8000324e:	ecce                	sd	s3,88(sp)
    80003250:	e8d2                	sd	s4,80(sp)
    80003252:	e4d6                	sd	s5,72(sp)
    80003254:	e0da                	sd	s6,64(sp)
    80003256:	fc5e                	sd	s7,56(sp)
    80003258:	f862                	sd	s8,48(sp)
    8000325a:	f466                	sd	s9,40(sp)
    8000325c:	f06a                	sd	s10,32(sp)
    8000325e:	ec6e                	sd	s11,24(sp)
    80003260:	0100                	addi	s0,sp,128
  struct proc *p;
  char *state;
  int ppid, pid;
  uint xticks;

  printf("\n");
    80003262:	00006517          	auipc	a0,0x6
    80003266:	4e650513          	addi	a0,a0,1254 # 80009748 <syscalls+0x108>
    8000326a:	ffffd097          	auipc	ra,0xffffd
    8000326e:	31c080e7          	jalr	796(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80003272:	0000f497          	auipc	s1,0xf
    80003276:	49e48493          	addi	s1,s1,1182 # 80012710 <proc>
    acquire(&p->lock);
    if(p->state == UNUSED) {
      release(&p->lock);
      continue;
    }
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000327a:	4d95                	li	s11,5
    else
      state = "???";

    pid = p->pid;
    release(&p->lock);
    acquire(&wait_lock);
    8000327c:	0000fb97          	auipc	s7,0xf
    80003280:	07cb8b93          	addi	s7,s7,124 # 800122f8 <wait_lock>
    if (p->parent) {
       acquire(&p->parent->lock);
       ppid = p->parent->pid;
       release(&p->parent->lock);
    }
    else ppid = -1;
    80003284:	5b7d                	li	s6,-1
    release(&wait_lock);

    acquire(&tickslock);
    80003286:	00016a97          	auipc	s5,0x16
    8000328a:	88aa8a93          	addi	s5,s5,-1910 # 80018b10 <tickslock>
  for(p = proc; p < &proc[NPROC]; p++){
    8000328e:	00016d17          	auipc	s10,0x16
    80003292:	882d0d13          	addi	s10,s10,-1918 # 80018b10 <tickslock>
    80003296:	a85d                	j	8000334c <ps+0x108>
      release(&p->lock);
    80003298:	8526                	mv	a0,s1
    8000329a:	ffffe097          	auipc	ra,0xffffe
    8000329e:	9fc080e7          	jalr	-1540(ra) # 80000c96 <release>
      continue;
    800032a2:	a04d                	j	80003344 <ps+0x100>
    pid = p->pid;
    800032a4:	0304ac03          	lw	s8,48(s1)
    release(&p->lock);
    800032a8:	8526                	mv	a0,s1
    800032aa:	ffffe097          	auipc	ra,0xffffe
    800032ae:	9ec080e7          	jalr	-1556(ra) # 80000c96 <release>
    acquire(&wait_lock);
    800032b2:	855e                	mv	a0,s7
    800032b4:	ffffe097          	auipc	ra,0xffffe
    800032b8:	92e080e7          	jalr	-1746(ra) # 80000be2 <acquire>
    if (p->parent) {
    800032bc:	7c88                	ld	a0,56(s1)
    else ppid = -1;
    800032be:	8a5a                	mv	s4,s6
    if (p->parent) {
    800032c0:	cd01                	beqz	a0,800032d8 <ps+0x94>
       acquire(&p->parent->lock);
    800032c2:	ffffe097          	auipc	ra,0xffffe
    800032c6:	920080e7          	jalr	-1760(ra) # 80000be2 <acquire>
       ppid = p->parent->pid;
    800032ca:	7c88                	ld	a0,56(s1)
    800032cc:	03052a03          	lw	s4,48(a0)
       release(&p->parent->lock);
    800032d0:	ffffe097          	auipc	ra,0xffffe
    800032d4:	9c6080e7          	jalr	-1594(ra) # 80000c96 <release>
    release(&wait_lock);
    800032d8:	855e                	mv	a0,s7
    800032da:	ffffe097          	auipc	ra,0xffffe
    800032de:	9bc080e7          	jalr	-1604(ra) # 80000c96 <release>
    acquire(&tickslock);
    800032e2:	8556                	mv	a0,s5
    800032e4:	ffffe097          	auipc	ra,0xffffe
    800032e8:	8fe080e7          	jalr	-1794(ra) # 80000be2 <acquire>
    xticks = ticks;
    800032ec:	00007797          	auipc	a5,0x7
    800032f0:	d8478793          	addi	a5,a5,-636 # 8000a070 <ticks>
    800032f4:	0007ac83          	lw	s9,0(a5)
    release(&tickslock);
    800032f8:	8556                	mv	a0,s5
    800032fa:	ffffe097          	auipc	ra,0xffffe
    800032fe:	99c080e7          	jalr	-1636(ra) # 80000c96 <release>

    printf("pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p", pid, ppid, state, p->name, p->ctime, p->stime, (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime, p->sz);
    80003302:	15890713          	addi	a4,s2,344
    80003306:	1684a783          	lw	a5,360(s1)
    8000330a:	16c4a803          	lw	a6,364(s1)
    8000330e:	1704a683          	lw	a3,368(s1)
    80003312:	410688bb          	subw	a7,a3,a6
    80003316:	07668a63          	beq	a3,s6,8000338a <ps+0x146>
    8000331a:	64b4                	ld	a3,72(s1)
    8000331c:	e036                	sd	a3,0(sp)
    8000331e:	86ce                	mv	a3,s3
    80003320:	8652                	mv	a2,s4
    80003322:	85e2                	mv	a1,s8
    80003324:	00006517          	auipc	a0,0x6
    80003328:	0ac50513          	addi	a0,a0,172 # 800093d0 <digits+0x390>
    8000332c:	ffffd097          	auipc	ra,0xffffd
    80003330:	25a080e7          	jalr	602(ra) # 80000586 <printf>
    printf("\n");
    80003334:	00006517          	auipc	a0,0x6
    80003338:	41450513          	addi	a0,a0,1044 # 80009748 <syscalls+0x108>
    8000333c:	ffffd097          	auipc	ra,0xffffd
    80003340:	24a080e7          	jalr	586(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80003344:	19048493          	addi	s1,s1,400
    80003348:	05a48463          	beq	s1,s10,80003390 <ps+0x14c>
    acquire(&p->lock);
    8000334c:	8926                	mv	s2,s1
    8000334e:	8526                	mv	a0,s1
    80003350:	ffffe097          	auipc	ra,0xffffe
    80003354:	892080e7          	jalr	-1902(ra) # 80000be2 <acquire>
    if(p->state == UNUSED) {
    80003358:	4c9c                	lw	a5,24(s1)
    8000335a:	df9d                	beqz	a5,80003298 <ps+0x54>
      state = "???";
    8000335c:	00006997          	auipc	s3,0x6
    80003360:	05c98993          	addi	s3,s3,92 # 800093b8 <digits+0x378>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003364:	f4fde0e3          	bltu	s11,a5,800032a4 <ps+0x60>
    80003368:	1782                	slli	a5,a5,0x20
    8000336a:	9381                	srli	a5,a5,0x20
    8000336c:	078e                	slli	a5,a5,0x3
    8000336e:	00006717          	auipc	a4,0x6
    80003372:	0ea70713          	addi	a4,a4,234 # 80009458 <states.1821>
    80003376:	97ba                	add	a5,a5,a4
    80003378:	0307b983          	ld	s3,48(a5)
    8000337c:	f20994e3          	bnez	s3,800032a4 <ps+0x60>
      state = "???";
    80003380:	00006997          	auipc	s3,0x6
    80003384:	03898993          	addi	s3,s3,56 # 800093b8 <digits+0x378>
    80003388:	bf31                	j	800032a4 <ps+0x60>
    printf("pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p", pid, ppid, state, p->name, p->ctime, p->stime, (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime, p->sz);
    8000338a:	410c88bb          	subw	a7,s9,a6
    8000338e:	b771                	j	8000331a <ps+0xd6>
  }
  return 0;
}
    80003390:	4501                	li	a0,0
    80003392:	70e6                	ld	ra,120(sp)
    80003394:	7446                	ld	s0,112(sp)
    80003396:	74a6                	ld	s1,104(sp)
    80003398:	7906                	ld	s2,96(sp)
    8000339a:	69e6                	ld	s3,88(sp)
    8000339c:	6a46                	ld	s4,80(sp)
    8000339e:	6aa6                	ld	s5,72(sp)
    800033a0:	6b06                	ld	s6,64(sp)
    800033a2:	7be2                	ld	s7,56(sp)
    800033a4:	7c42                	ld	s8,48(sp)
    800033a6:	7ca2                	ld	s9,40(sp)
    800033a8:	7d02                	ld	s10,32(sp)
    800033aa:	6de2                	ld	s11,24(sp)
    800033ac:	6109                	addi	sp,sp,128
    800033ae:	8082                	ret

00000000800033b0 <pinfo>:

int
pinfo(int pid, uint64 addr)
{
    800033b0:	7159                	addi	sp,sp,-112
    800033b2:	f486                	sd	ra,104(sp)
    800033b4:	f0a2                	sd	s0,96(sp)
    800033b6:	eca6                	sd	s1,88(sp)
    800033b8:	e8ca                	sd	s2,80(sp)
    800033ba:	e4ce                	sd	s3,72(sp)
    800033bc:	e0d2                	sd	s4,64(sp)
    800033be:	1880                	addi	s0,sp,112
    800033c0:	892a                	mv	s2,a0
    800033c2:	89ae                	mv	s3,a1
  struct proc *p;
  char *state;
  uint xticks;
  int found=0;

  if (pid == -1) {
    800033c4:	57fd                	li	a5,-1
     p = myproc();
     acquire(&p->lock);
     found=1;
  }
  else {
     for(p = proc; p < &proc[NPROC]; p++){
    800033c6:	0000f497          	auipc	s1,0xf
    800033ca:	34a48493          	addi	s1,s1,842 # 80012710 <proc>
    800033ce:	00015a17          	auipc	s4,0x15
    800033d2:	742a0a13          	addi	s4,s4,1858 # 80018b10 <tickslock>
  if (pid == -1) {
    800033d6:	02f51563          	bne	a0,a5,80003400 <pinfo+0x50>
     p = myproc();
    800033da:	ffffe097          	auipc	ra,0xffffe
    800033de:	5d4080e7          	jalr	1492(ra) # 800019ae <myproc>
    800033e2:	84aa                	mv	s1,a0
     acquire(&p->lock);
    800033e4:	ffffd097          	auipc	ra,0xffffd
    800033e8:	7fe080e7          	jalr	2046(ra) # 80000be2 <acquire>
         found=1;
         break;
       }
     }
  }
  if (found) {
    800033ec:	a025                	j	80003414 <pinfo+0x64>
         release(&p->lock);
    800033ee:	8526                	mv	a0,s1
    800033f0:	ffffe097          	auipc	ra,0xffffe
    800033f4:	8a6080e7          	jalr	-1882(ra) # 80000c96 <release>
     for(p = proc; p < &proc[NPROC]; p++){
    800033f8:	19048493          	addi	s1,s1,400
    800033fc:	13448d63          	beq	s1,s4,80003536 <pinfo+0x186>
       acquire(&p->lock);
    80003400:	8526                	mv	a0,s1
    80003402:	ffffd097          	auipc	ra,0xffffd
    80003406:	7e0080e7          	jalr	2016(ra) # 80000be2 <acquire>
       if((p->state == UNUSED) || (p->pid != pid)) {
    8000340a:	4c9c                	lw	a5,24(s1)
    8000340c:	d3ed                	beqz	a5,800033ee <pinfo+0x3e>
    8000340e:	589c                	lw	a5,48(s1)
    80003410:	fd279fe3          	bne	a5,s2,800033ee <pinfo+0x3e>
     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003414:	4c9c                	lw	a5,24(s1)
    80003416:	4715                	li	a4,5
         state = states[p->state];
     else
         state = "???";
    80003418:	00006917          	auipc	s2,0x6
    8000341c:	fa090913          	addi	s2,s2,-96 # 800093b8 <digits+0x378>
     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003420:	00f76e63          	bltu	a4,a5,8000343c <pinfo+0x8c>
    80003424:	1782                	slli	a5,a5,0x20
    80003426:	9381                	srli	a5,a5,0x20
    80003428:	078e                	slli	a5,a5,0x3
    8000342a:	00006717          	auipc	a4,0x6
    8000342e:	02e70713          	addi	a4,a4,46 # 80009458 <states.1821>
    80003432:	97ba                	add	a5,a5,a4
    80003434:	0607b903          	ld	s2,96(a5)
    80003438:	10090163          	beqz	s2,8000353a <pinfo+0x18a>

     pstat.pid = p->pid;
    8000343c:	589c                	lw	a5,48(s1)
    8000343e:	f8f42c23          	sw	a5,-104(s0)
     release(&p->lock);
    80003442:	8526                	mv	a0,s1
    80003444:	ffffe097          	auipc	ra,0xffffe
    80003448:	852080e7          	jalr	-1966(ra) # 80000c96 <release>
     acquire(&wait_lock);
    8000344c:	0000f517          	auipc	a0,0xf
    80003450:	eac50513          	addi	a0,a0,-340 # 800122f8 <wait_lock>
    80003454:	ffffd097          	auipc	ra,0xffffd
    80003458:	78e080e7          	jalr	1934(ra) # 80000be2 <acquire>
     if (p->parent) {
    8000345c:	7c88                	ld	a0,56(s1)
    8000345e:	c17d                	beqz	a0,80003544 <pinfo+0x194>
        acquire(&p->parent->lock);
    80003460:	ffffd097          	auipc	ra,0xffffd
    80003464:	782080e7          	jalr	1922(ra) # 80000be2 <acquire>
        pstat.ppid = p->parent->pid;
    80003468:	7c88                	ld	a0,56(s1)
    8000346a:	591c                	lw	a5,48(a0)
    8000346c:	f8f42e23          	sw	a5,-100(s0)
        release(&p->parent->lock);
    80003470:	ffffe097          	auipc	ra,0xffffe
    80003474:	826080e7          	jalr	-2010(ra) # 80000c96 <release>
     }
     else pstat.ppid = -1;
     release(&wait_lock);
    80003478:	0000f517          	auipc	a0,0xf
    8000347c:	e8050513          	addi	a0,a0,-384 # 800122f8 <wait_lock>
    80003480:	ffffe097          	auipc	ra,0xffffe
    80003484:	816080e7          	jalr	-2026(ra) # 80000c96 <release>

     acquire(&tickslock);
    80003488:	00015517          	auipc	a0,0x15
    8000348c:	68850513          	addi	a0,a0,1672 # 80018b10 <tickslock>
    80003490:	ffffd097          	auipc	ra,0xffffd
    80003494:	752080e7          	jalr	1874(ra) # 80000be2 <acquire>
     xticks = ticks;
    80003498:	00007a17          	auipc	s4,0x7
    8000349c:	bd8a2a03          	lw	s4,-1064(s4) # 8000a070 <ticks>
     release(&tickslock);
    800034a0:	00015517          	auipc	a0,0x15
    800034a4:	67050513          	addi	a0,a0,1648 # 80018b10 <tickslock>
    800034a8:	ffffd097          	auipc	ra,0xffffd
    800034ac:	7ee080e7          	jalr	2030(ra) # 80000c96 <release>

     safestrcpy(&pstat.state[0], state, strlen(state)+1);
    800034b0:	854a                	mv	a0,s2
    800034b2:	ffffe097          	auipc	ra,0xffffe
    800034b6:	9b0080e7          	jalr	-1616(ra) # 80000e62 <strlen>
    800034ba:	0015061b          	addiw	a2,a0,1
    800034be:	85ca                	mv	a1,s2
    800034c0:	fa040513          	addi	a0,s0,-96
    800034c4:	ffffe097          	auipc	ra,0xffffe
    800034c8:	96c080e7          	jalr	-1684(ra) # 80000e30 <safestrcpy>
     safestrcpy(&pstat.command[0], &p->name[0], sizeof(p->name));
    800034cc:	4641                	li	a2,16
    800034ce:	15848593          	addi	a1,s1,344
    800034d2:	fa840513          	addi	a0,s0,-88
    800034d6:	ffffe097          	auipc	ra,0xffffe
    800034da:	95a080e7          	jalr	-1702(ra) # 80000e30 <safestrcpy>
     pstat.ctime = p->ctime;
    800034de:	1684a783          	lw	a5,360(s1)
    800034e2:	faf42c23          	sw	a5,-72(s0)
     pstat.stime = p->stime;
    800034e6:	16c4a783          	lw	a5,364(s1)
    800034ea:	faf42e23          	sw	a5,-68(s0)
     pstat.etime = (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime;
    800034ee:	1704a703          	lw	a4,368(s1)
    800034f2:	567d                	li	a2,-1
    800034f4:	40f706bb          	subw	a3,a4,a5
    800034f8:	04c70a63          	beq	a4,a2,8000354c <pinfo+0x19c>
    800034fc:	fcd42023          	sw	a3,-64(s0)
     pstat.size = p->sz;
    80003500:	64bc                	ld	a5,72(s1)
    80003502:	fcf43423          	sd	a5,-56(s0)
     if(copyout(myproc()->pagetable, addr, (char *)&pstat, sizeof(pstat)) < 0) return -1;
    80003506:	ffffe097          	auipc	ra,0xffffe
    8000350a:	4a8080e7          	jalr	1192(ra) # 800019ae <myproc>
    8000350e:	03800693          	li	a3,56
    80003512:	f9840613          	addi	a2,s0,-104
    80003516:	85ce                	mv	a1,s3
    80003518:	6928                	ld	a0,80(a0)
    8000351a:	ffffe097          	auipc	ra,0xffffe
    8000351e:	156080e7          	jalr	342(ra) # 80001670 <copyout>
    80003522:	41f5551b          	sraiw	a0,a0,0x1f
     return 0;
  }
  else return -1;
    80003526:	70a6                	ld	ra,104(sp)
    80003528:	7406                	ld	s0,96(sp)
    8000352a:	64e6                	ld	s1,88(sp)
    8000352c:	6946                	ld	s2,80(sp)
    8000352e:	69a6                	ld	s3,72(sp)
    80003530:	6a06                	ld	s4,64(sp)
    80003532:	6165                	addi	sp,sp,112
    80003534:	8082                	ret
  else return -1;
    80003536:	557d                	li	a0,-1
    80003538:	b7fd                	j	80003526 <pinfo+0x176>
         state = "???";
    8000353a:	00006917          	auipc	s2,0x6
    8000353e:	e7e90913          	addi	s2,s2,-386 # 800093b8 <digits+0x378>
    80003542:	bded                	j	8000343c <pinfo+0x8c>
     else pstat.ppid = -1;
    80003544:	57fd                	li	a5,-1
    80003546:	f8f42e23          	sw	a5,-100(s0)
    8000354a:	b73d                	j	80003478 <pinfo+0xc8>
     pstat.etime = (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime;
    8000354c:	40fa06bb          	subw	a3,s4,a5
    80003550:	b775                	j	800034fc <pinfo+0x14c>

0000000080003552 <swtch>:
    80003552:	00153023          	sd	ra,0(a0)
    80003556:	00253423          	sd	sp,8(a0)
    8000355a:	e900                	sd	s0,16(a0)
    8000355c:	ed04                	sd	s1,24(a0)
    8000355e:	03253023          	sd	s2,32(a0)
    80003562:	03353423          	sd	s3,40(a0)
    80003566:	03453823          	sd	s4,48(a0)
    8000356a:	03553c23          	sd	s5,56(a0)
    8000356e:	05653023          	sd	s6,64(a0)
    80003572:	05753423          	sd	s7,72(a0)
    80003576:	05853823          	sd	s8,80(a0)
    8000357a:	05953c23          	sd	s9,88(a0)
    8000357e:	07a53023          	sd	s10,96(a0)
    80003582:	07b53423          	sd	s11,104(a0)
    80003586:	0005b083          	ld	ra,0(a1)
    8000358a:	0085b103          	ld	sp,8(a1)
    8000358e:	6980                	ld	s0,16(a1)
    80003590:	6d84                	ld	s1,24(a1)
    80003592:	0205b903          	ld	s2,32(a1)
    80003596:	0285b983          	ld	s3,40(a1)
    8000359a:	0305ba03          	ld	s4,48(a1)
    8000359e:	0385ba83          	ld	s5,56(a1)
    800035a2:	0405bb03          	ld	s6,64(a1)
    800035a6:	0485bb83          	ld	s7,72(a1)
    800035aa:	0505bc03          	ld	s8,80(a1)
    800035ae:	0585bc83          	ld	s9,88(a1)
    800035b2:	0605bd03          	ld	s10,96(a1)
    800035b6:	0685bd83          	ld	s11,104(a1)
    800035ba:	8082                	ret

00000000800035bc <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800035bc:	1141                	addi	sp,sp,-16
    800035be:	e406                	sd	ra,8(sp)
    800035c0:	e022                	sd	s0,0(sp)
    800035c2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800035c4:	00006597          	auipc	a1,0x6
    800035c8:	f2458593          	addi	a1,a1,-220 # 800094e8 <states.1846+0x30>
    800035cc:	00015517          	auipc	a0,0x15
    800035d0:	54450513          	addi	a0,a0,1348 # 80018b10 <tickslock>
    800035d4:	ffffd097          	auipc	ra,0xffffd
    800035d8:	57e080e7          	jalr	1406(ra) # 80000b52 <initlock>
}
    800035dc:	60a2                	ld	ra,8(sp)
    800035de:	6402                	ld	s0,0(sp)
    800035e0:	0141                	addi	sp,sp,16
    800035e2:	8082                	ret

00000000800035e4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800035e4:	1141                	addi	sp,sp,-16
    800035e6:	e422                	sd	s0,8(sp)
    800035e8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800035ea:	00003797          	auipc	a5,0x3
    800035ee:	6b678793          	addi	a5,a5,1718 # 80006ca0 <kernelvec>
    800035f2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800035f6:	6422                	ld	s0,8(sp)
    800035f8:	0141                	addi	sp,sp,16
    800035fa:	8082                	ret

00000000800035fc <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800035fc:	1141                	addi	sp,sp,-16
    800035fe:	e406                	sd	ra,8(sp)
    80003600:	e022                	sd	s0,0(sp)
    80003602:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80003604:	ffffe097          	auipc	ra,0xffffe
    80003608:	3aa080e7          	jalr	938(ra) # 800019ae <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000360c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003610:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003612:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80003616:	00005617          	auipc	a2,0x5
    8000361a:	9ea60613          	addi	a2,a2,-1558 # 80008000 <_trampoline>
    8000361e:	00005697          	auipc	a3,0x5
    80003622:	9e268693          	addi	a3,a3,-1566 # 80008000 <_trampoline>
    80003626:	8e91                	sub	a3,a3,a2
    80003628:	040007b7          	lui	a5,0x4000
    8000362c:	17fd                	addi	a5,a5,-1
    8000362e:	07b2                	slli	a5,a5,0xc
    80003630:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003632:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80003636:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80003638:	180026f3          	csrr	a3,satp
    8000363c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000363e:	6d38                	ld	a4,88(a0)
    80003640:	6134                	ld	a3,64(a0)
    80003642:	6585                	lui	a1,0x1
    80003644:	96ae                	add	a3,a3,a1
    80003646:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80003648:	6d38                	ld	a4,88(a0)
    8000364a:	00000697          	auipc	a3,0x0
    8000364e:	13868693          	addi	a3,a3,312 # 80003782 <usertrap>
    80003652:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80003654:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80003656:	8692                	mv	a3,tp
    80003658:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000365a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000365e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80003662:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003666:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000366a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000366c:	6f18                	ld	a4,24(a4)
    8000366e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80003672:	692c                	ld	a1,80(a0)
    80003674:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80003676:	00005717          	auipc	a4,0x5
    8000367a:	a1a70713          	addi	a4,a4,-1510 # 80008090 <userret>
    8000367e:	8f11                	sub	a4,a4,a2
    80003680:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80003682:	577d                	li	a4,-1
    80003684:	177e                	slli	a4,a4,0x3f
    80003686:	8dd9                	or	a1,a1,a4
    80003688:	02000537          	lui	a0,0x2000
    8000368c:	157d                	addi	a0,a0,-1
    8000368e:	0536                	slli	a0,a0,0xd
    80003690:	9782                	jalr	a5
}
    80003692:	60a2                	ld	ra,8(sp)
    80003694:	6402                	ld	s0,0(sp)
    80003696:	0141                	addi	sp,sp,16
    80003698:	8082                	ret

000000008000369a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000369a:	1101                	addi	sp,sp,-32
    8000369c:	ec06                	sd	ra,24(sp)
    8000369e:	e822                	sd	s0,16(sp)
    800036a0:	e426                	sd	s1,8(sp)
    800036a2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800036a4:	00015497          	auipc	s1,0x15
    800036a8:	46c48493          	addi	s1,s1,1132 # 80018b10 <tickslock>
    800036ac:	8526                	mv	a0,s1
    800036ae:	ffffd097          	auipc	ra,0xffffd
    800036b2:	534080e7          	jalr	1332(ra) # 80000be2 <acquire>
  ticks++;
    800036b6:	00007517          	auipc	a0,0x7
    800036ba:	9ba50513          	addi	a0,a0,-1606 # 8000a070 <ticks>
    800036be:	411c                	lw	a5,0(a0)
    800036c0:	2785                	addiw	a5,a5,1
    800036c2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800036c4:	fffff097          	auipc	ra,0xfffff
    800036c8:	4d4080e7          	jalr	1236(ra) # 80002b98 <wakeup>
  release(&tickslock);
    800036cc:	8526                	mv	a0,s1
    800036ce:	ffffd097          	auipc	ra,0xffffd
    800036d2:	5c8080e7          	jalr	1480(ra) # 80000c96 <release>
}
    800036d6:	60e2                	ld	ra,24(sp)
    800036d8:	6442                	ld	s0,16(sp)
    800036da:	64a2                	ld	s1,8(sp)
    800036dc:	6105                	addi	sp,sp,32
    800036de:	8082                	ret

00000000800036e0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800036e0:	1101                	addi	sp,sp,-32
    800036e2:	ec06                	sd	ra,24(sp)
    800036e4:	e822                	sd	s0,16(sp)
    800036e6:	e426                	sd	s1,8(sp)
    800036e8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800036ea:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800036ee:	00074d63          	bltz	a4,80003708 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800036f2:	57fd                	li	a5,-1
    800036f4:	17fe                	slli	a5,a5,0x3f
    800036f6:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800036f8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800036fa:	06f70363          	beq	a4,a5,80003760 <devintr+0x80>
  }
}
    800036fe:	60e2                	ld	ra,24(sp)
    80003700:	6442                	ld	s0,16(sp)
    80003702:	64a2                	ld	s1,8(sp)
    80003704:	6105                	addi	sp,sp,32
    80003706:	8082                	ret
     (scause & 0xff) == 9){
    80003708:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000370c:	46a5                	li	a3,9
    8000370e:	fed792e3          	bne	a5,a3,800036f2 <devintr+0x12>
    int irq = plic_claim();
    80003712:	00003097          	auipc	ra,0x3
    80003716:	696080e7          	jalr	1686(ra) # 80006da8 <plic_claim>
    8000371a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000371c:	47a9                	li	a5,10
    8000371e:	02f50763          	beq	a0,a5,8000374c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80003722:	4785                	li	a5,1
    80003724:	02f50963          	beq	a0,a5,80003756 <devintr+0x76>
    return 1;
    80003728:	4505                	li	a0,1
    } else if(irq){
    8000372a:	d8f1                	beqz	s1,800036fe <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000372c:	85a6                	mv	a1,s1
    8000372e:	00006517          	auipc	a0,0x6
    80003732:	dc250513          	addi	a0,a0,-574 # 800094f0 <states.1846+0x38>
    80003736:	ffffd097          	auipc	ra,0xffffd
    8000373a:	e50080e7          	jalr	-432(ra) # 80000586 <printf>
      plic_complete(irq);
    8000373e:	8526                	mv	a0,s1
    80003740:	00003097          	auipc	ra,0x3
    80003744:	68c080e7          	jalr	1676(ra) # 80006dcc <plic_complete>
    return 1;
    80003748:	4505                	li	a0,1
    8000374a:	bf55                	j	800036fe <devintr+0x1e>
      uartintr();
    8000374c:	ffffd097          	auipc	ra,0xffffd
    80003750:	25a080e7          	jalr	602(ra) # 800009a6 <uartintr>
    80003754:	b7ed                	j	8000373e <devintr+0x5e>
      virtio_disk_intr();
    80003756:	00004097          	auipc	ra,0x4
    8000375a:	b56080e7          	jalr	-1194(ra) # 800072ac <virtio_disk_intr>
    8000375e:	b7c5                	j	8000373e <devintr+0x5e>
    if(cpuid() == 0){
    80003760:	ffffe097          	auipc	ra,0xffffe
    80003764:	222080e7          	jalr	546(ra) # 80001982 <cpuid>
    80003768:	c901                	beqz	a0,80003778 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000376a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000376e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80003770:	14479073          	csrw	sip,a5
    return 2;
    80003774:	4509                	li	a0,2
    80003776:	b761                	j	800036fe <devintr+0x1e>
      clockintr();
    80003778:	00000097          	auipc	ra,0x0
    8000377c:	f22080e7          	jalr	-222(ra) # 8000369a <clockintr>
    80003780:	b7ed                	j	8000376a <devintr+0x8a>

0000000080003782 <usertrap>:
{
    80003782:	1101                	addi	sp,sp,-32
    80003784:	ec06                	sd	ra,24(sp)
    80003786:	e822                	sd	s0,16(sp)
    80003788:	e426                	sd	s1,8(sp)
    8000378a:	e04a                	sd	s2,0(sp)
    8000378c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000378e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003792:	1007f793          	andi	a5,a5,256
    80003796:	e3ad                	bnez	a5,800037f8 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003798:	00003797          	auipc	a5,0x3
    8000379c:	50878793          	addi	a5,a5,1288 # 80006ca0 <kernelvec>
    800037a0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800037a4:	ffffe097          	auipc	ra,0xffffe
    800037a8:	20a080e7          	jalr	522(ra) # 800019ae <myproc>
    800037ac:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800037ae:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800037b0:	14102773          	csrr	a4,sepc
    800037b4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800037b6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800037ba:	47a1                	li	a5,8
    800037bc:	04f71c63          	bne	a4,a5,80003814 <usertrap+0x92>
    if(p->killed)
    800037c0:	551c                	lw	a5,40(a0)
    800037c2:	e3b9                	bnez	a5,80003808 <usertrap+0x86>
    p->trapframe->epc += 4;
    800037c4:	6cb8                	ld	a4,88(s1)
    800037c6:	6f1c                	ld	a5,24(a4)
    800037c8:	0791                	addi	a5,a5,4
    800037ca:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800037cc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800037d0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800037d4:	10079073          	csrw	sstatus,a5
    syscall();
    800037d8:	00000097          	auipc	ra,0x0
    800037dc:	2fc080e7          	jalr	764(ra) # 80003ad4 <syscall>
  if(p->killed)
    800037e0:	549c                	lw	a5,40(s1)
    800037e2:	efd9                	bnez	a5,80003880 <usertrap+0xfe>
  usertrapret();
    800037e4:	00000097          	auipc	ra,0x0
    800037e8:	e18080e7          	jalr	-488(ra) # 800035fc <usertrapret>
}
    800037ec:	60e2                	ld	ra,24(sp)
    800037ee:	6442                	ld	s0,16(sp)
    800037f0:	64a2                	ld	s1,8(sp)
    800037f2:	6902                	ld	s2,0(sp)
    800037f4:	6105                	addi	sp,sp,32
    800037f6:	8082                	ret
    panic("usertrap: not from user mode");
    800037f8:	00006517          	auipc	a0,0x6
    800037fc:	d1850513          	addi	a0,a0,-744 # 80009510 <states.1846+0x58>
    80003800:	ffffd097          	auipc	ra,0xffffd
    80003804:	d3c080e7          	jalr	-708(ra) # 8000053c <panic>
      exit(-1);
    80003808:	557d                	li	a0,-1
    8000380a:	fffff097          	auipc	ra,0xfffff
    8000380e:	45e080e7          	jalr	1118(ra) # 80002c68 <exit>
    80003812:	bf4d                	j	800037c4 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80003814:	00000097          	auipc	ra,0x0
    80003818:	ecc080e7          	jalr	-308(ra) # 800036e0 <devintr>
    8000381c:	892a                	mv	s2,a0
    8000381e:	c501                	beqz	a0,80003826 <usertrap+0xa4>
  if(p->killed)
    80003820:	549c                	lw	a5,40(s1)
    80003822:	c3a1                	beqz	a5,80003862 <usertrap+0xe0>
    80003824:	a815                	j	80003858 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003826:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000382a:	5890                	lw	a2,48(s1)
    8000382c:	00006517          	auipc	a0,0x6
    80003830:	d0450513          	addi	a0,a0,-764 # 80009530 <states.1846+0x78>
    80003834:	ffffd097          	auipc	ra,0xffffd
    80003838:	d52080e7          	jalr	-686(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000383c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003840:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003844:	00006517          	auipc	a0,0x6
    80003848:	d1c50513          	addi	a0,a0,-740 # 80009560 <states.1846+0xa8>
    8000384c:	ffffd097          	auipc	ra,0xffffd
    80003850:	d3a080e7          	jalr	-710(ra) # 80000586 <printf>
    p->killed = 1;
    80003854:	4785                	li	a5,1
    80003856:	d49c                	sw	a5,40(s1)
    exit(-1);
    80003858:	557d                	li	a0,-1
    8000385a:	fffff097          	auipc	ra,0xfffff
    8000385e:	40e080e7          	jalr	1038(ra) # 80002c68 <exit>
  if(which_dev == 2 && SCHED_POLICY!=SCHED_NPREEMPT_FCFS && SCHED_POLICY!=SCHED_NPREEMPT_SJF)
    80003862:	4789                	li	a5,2
    80003864:	f8f910e3          	bne	s2,a5,800037e4 <usertrap+0x62>
    80003868:	00006717          	auipc	a4,0x6
    8000386c:	20c72703          	lw	a4,524(a4) # 80009a74 <SCHED_POLICY>
    80003870:	4785                	li	a5,1
    80003872:	f6e7f9e3          	bgeu	a5,a4,800037e4 <usertrap+0x62>
    yield();
    80003876:	fffff097          	auipc	ra,0xfffff
    8000387a:	c56080e7          	jalr	-938(ra) # 800024cc <yield>
    8000387e:	b79d                	j	800037e4 <usertrap+0x62>
  int which_dev = 0;
    80003880:	4901                	li	s2,0
    80003882:	bfd9                	j	80003858 <usertrap+0xd6>

0000000080003884 <kerneltrap>:
{
    80003884:	7179                	addi	sp,sp,-48
    80003886:	f406                	sd	ra,40(sp)
    80003888:	f022                	sd	s0,32(sp)
    8000388a:	ec26                	sd	s1,24(sp)
    8000388c:	e84a                	sd	s2,16(sp)
    8000388e:	e44e                	sd	s3,8(sp)
    80003890:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003892:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003896:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000389a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000389e:	1004f793          	andi	a5,s1,256
    800038a2:	cb85                	beqz	a5,800038d2 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800038a4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800038a8:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800038aa:	ef85                	bnez	a5,800038e2 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800038ac:	00000097          	auipc	ra,0x0
    800038b0:	e34080e7          	jalr	-460(ra) # 800036e0 <devintr>
    800038b4:	cd1d                	beqz	a0,800038f2 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING && SCHED_POLICY!=SCHED_NPREEMPT_FCFS && SCHED_POLICY!=SCHED_NPREEMPT_SJF)
    800038b6:	4789                	li	a5,2
    800038b8:	06f50a63          	beq	a0,a5,8000392c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800038bc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800038c0:	10049073          	csrw	sstatus,s1
}
    800038c4:	70a2                	ld	ra,40(sp)
    800038c6:	7402                	ld	s0,32(sp)
    800038c8:	64e2                	ld	s1,24(sp)
    800038ca:	6942                	ld	s2,16(sp)
    800038cc:	69a2                	ld	s3,8(sp)
    800038ce:	6145                	addi	sp,sp,48
    800038d0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800038d2:	00006517          	auipc	a0,0x6
    800038d6:	cae50513          	addi	a0,a0,-850 # 80009580 <states.1846+0xc8>
    800038da:	ffffd097          	auipc	ra,0xffffd
    800038de:	c62080e7          	jalr	-926(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    800038e2:	00006517          	auipc	a0,0x6
    800038e6:	cc650513          	addi	a0,a0,-826 # 800095a8 <states.1846+0xf0>
    800038ea:	ffffd097          	auipc	ra,0xffffd
    800038ee:	c52080e7          	jalr	-942(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    800038f2:	85ce                	mv	a1,s3
    800038f4:	00006517          	auipc	a0,0x6
    800038f8:	cd450513          	addi	a0,a0,-812 # 800095c8 <states.1846+0x110>
    800038fc:	ffffd097          	auipc	ra,0xffffd
    80003900:	c8a080e7          	jalr	-886(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003904:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003908:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000390c:	00006517          	auipc	a0,0x6
    80003910:	ccc50513          	addi	a0,a0,-820 # 800095d8 <states.1846+0x120>
    80003914:	ffffd097          	auipc	ra,0xffffd
    80003918:	c72080e7          	jalr	-910(ra) # 80000586 <printf>
    panic("kerneltrap");
    8000391c:	00006517          	auipc	a0,0x6
    80003920:	cd450513          	addi	a0,a0,-812 # 800095f0 <states.1846+0x138>
    80003924:	ffffd097          	auipc	ra,0xffffd
    80003928:	c18080e7          	jalr	-1000(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING && SCHED_POLICY!=SCHED_NPREEMPT_FCFS && SCHED_POLICY!=SCHED_NPREEMPT_SJF)
    8000392c:	ffffe097          	auipc	ra,0xffffe
    80003930:	082080e7          	jalr	130(ra) # 800019ae <myproc>
    80003934:	d541                	beqz	a0,800038bc <kerneltrap+0x38>
    80003936:	ffffe097          	auipc	ra,0xffffe
    8000393a:	078080e7          	jalr	120(ra) # 800019ae <myproc>
    8000393e:	4d18                	lw	a4,24(a0)
    80003940:	4791                	li	a5,4
    80003942:	f6f71de3          	bne	a4,a5,800038bc <kerneltrap+0x38>
    80003946:	00006717          	auipc	a4,0x6
    8000394a:	12e72703          	lw	a4,302(a4) # 80009a74 <SCHED_POLICY>
    8000394e:	4785                	li	a5,1
    80003950:	f6e7f6e3          	bgeu	a5,a4,800038bc <kerneltrap+0x38>
    yield();
    80003954:	fffff097          	auipc	ra,0xfffff
    80003958:	b78080e7          	jalr	-1160(ra) # 800024cc <yield>
    8000395c:	b785                	j	800038bc <kerneltrap+0x38>

000000008000395e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000395e:	1101                	addi	sp,sp,-32
    80003960:	ec06                	sd	ra,24(sp)
    80003962:	e822                	sd	s0,16(sp)
    80003964:	e426                	sd	s1,8(sp)
    80003966:	1000                	addi	s0,sp,32
    80003968:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000396a:	ffffe097          	auipc	ra,0xffffe
    8000396e:	044080e7          	jalr	68(ra) # 800019ae <myproc>
  switch (n) {
    80003972:	4795                	li	a5,5
    80003974:	0497e163          	bltu	a5,s1,800039b6 <argraw+0x58>
    80003978:	048a                	slli	s1,s1,0x2
    8000397a:	00006717          	auipc	a4,0x6
    8000397e:	cae70713          	addi	a4,a4,-850 # 80009628 <states.1846+0x170>
    80003982:	94ba                	add	s1,s1,a4
    80003984:	409c                	lw	a5,0(s1)
    80003986:	97ba                	add	a5,a5,a4
    80003988:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000398a:	6d3c                	ld	a5,88(a0)
    8000398c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000398e:	60e2                	ld	ra,24(sp)
    80003990:	6442                	ld	s0,16(sp)
    80003992:	64a2                	ld	s1,8(sp)
    80003994:	6105                	addi	sp,sp,32
    80003996:	8082                	ret
    return p->trapframe->a1;
    80003998:	6d3c                	ld	a5,88(a0)
    8000399a:	7fa8                	ld	a0,120(a5)
    8000399c:	bfcd                	j	8000398e <argraw+0x30>
    return p->trapframe->a2;
    8000399e:	6d3c                	ld	a5,88(a0)
    800039a0:	63c8                	ld	a0,128(a5)
    800039a2:	b7f5                	j	8000398e <argraw+0x30>
    return p->trapframe->a3;
    800039a4:	6d3c                	ld	a5,88(a0)
    800039a6:	67c8                	ld	a0,136(a5)
    800039a8:	b7dd                	j	8000398e <argraw+0x30>
    return p->trapframe->a4;
    800039aa:	6d3c                	ld	a5,88(a0)
    800039ac:	6bc8                	ld	a0,144(a5)
    800039ae:	b7c5                	j	8000398e <argraw+0x30>
    return p->trapframe->a5;
    800039b0:	6d3c                	ld	a5,88(a0)
    800039b2:	6fc8                	ld	a0,152(a5)
    800039b4:	bfe9                	j	8000398e <argraw+0x30>
  panic("argraw");
    800039b6:	00006517          	auipc	a0,0x6
    800039ba:	c4a50513          	addi	a0,a0,-950 # 80009600 <states.1846+0x148>
    800039be:	ffffd097          	auipc	ra,0xffffd
    800039c2:	b7e080e7          	jalr	-1154(ra) # 8000053c <panic>

00000000800039c6 <fetchaddr>:
{
    800039c6:	1101                	addi	sp,sp,-32
    800039c8:	ec06                	sd	ra,24(sp)
    800039ca:	e822                	sd	s0,16(sp)
    800039cc:	e426                	sd	s1,8(sp)
    800039ce:	e04a                	sd	s2,0(sp)
    800039d0:	1000                	addi	s0,sp,32
    800039d2:	84aa                	mv	s1,a0
    800039d4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800039d6:	ffffe097          	auipc	ra,0xffffe
    800039da:	fd8080e7          	jalr	-40(ra) # 800019ae <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800039de:	653c                	ld	a5,72(a0)
    800039e0:	02f4f863          	bgeu	s1,a5,80003a10 <fetchaddr+0x4a>
    800039e4:	00848713          	addi	a4,s1,8
    800039e8:	02e7e663          	bltu	a5,a4,80003a14 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800039ec:	46a1                	li	a3,8
    800039ee:	8626                	mv	a2,s1
    800039f0:	85ca                	mv	a1,s2
    800039f2:	6928                	ld	a0,80(a0)
    800039f4:	ffffe097          	auipc	ra,0xffffe
    800039f8:	d08080e7          	jalr	-760(ra) # 800016fc <copyin>
    800039fc:	00a03533          	snez	a0,a0
    80003a00:	40a00533          	neg	a0,a0
}
    80003a04:	60e2                	ld	ra,24(sp)
    80003a06:	6442                	ld	s0,16(sp)
    80003a08:	64a2                	ld	s1,8(sp)
    80003a0a:	6902                	ld	s2,0(sp)
    80003a0c:	6105                	addi	sp,sp,32
    80003a0e:	8082                	ret
    return -1;
    80003a10:	557d                	li	a0,-1
    80003a12:	bfcd                	j	80003a04 <fetchaddr+0x3e>
    80003a14:	557d                	li	a0,-1
    80003a16:	b7fd                	j	80003a04 <fetchaddr+0x3e>

0000000080003a18 <fetchstr>:
{
    80003a18:	7179                	addi	sp,sp,-48
    80003a1a:	f406                	sd	ra,40(sp)
    80003a1c:	f022                	sd	s0,32(sp)
    80003a1e:	ec26                	sd	s1,24(sp)
    80003a20:	e84a                	sd	s2,16(sp)
    80003a22:	e44e                	sd	s3,8(sp)
    80003a24:	1800                	addi	s0,sp,48
    80003a26:	892a                	mv	s2,a0
    80003a28:	84ae                	mv	s1,a1
    80003a2a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003a2c:	ffffe097          	auipc	ra,0xffffe
    80003a30:	f82080e7          	jalr	-126(ra) # 800019ae <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003a34:	86ce                	mv	a3,s3
    80003a36:	864a                	mv	a2,s2
    80003a38:	85a6                	mv	a1,s1
    80003a3a:	6928                	ld	a0,80(a0)
    80003a3c:	ffffe097          	auipc	ra,0xffffe
    80003a40:	d4c080e7          	jalr	-692(ra) # 80001788 <copyinstr>
  if(err < 0)
    80003a44:	00054763          	bltz	a0,80003a52 <fetchstr+0x3a>
  return strlen(buf);
    80003a48:	8526                	mv	a0,s1
    80003a4a:	ffffd097          	auipc	ra,0xffffd
    80003a4e:	418080e7          	jalr	1048(ra) # 80000e62 <strlen>
}
    80003a52:	70a2                	ld	ra,40(sp)
    80003a54:	7402                	ld	s0,32(sp)
    80003a56:	64e2                	ld	s1,24(sp)
    80003a58:	6942                	ld	s2,16(sp)
    80003a5a:	69a2                	ld	s3,8(sp)
    80003a5c:	6145                	addi	sp,sp,48
    80003a5e:	8082                	ret

0000000080003a60 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003a60:	1101                	addi	sp,sp,-32
    80003a62:	ec06                	sd	ra,24(sp)
    80003a64:	e822                	sd	s0,16(sp)
    80003a66:	e426                	sd	s1,8(sp)
    80003a68:	1000                	addi	s0,sp,32
    80003a6a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003a6c:	00000097          	auipc	ra,0x0
    80003a70:	ef2080e7          	jalr	-270(ra) # 8000395e <argraw>
    80003a74:	c088                	sw	a0,0(s1)
  return 0;
}
    80003a76:	4501                	li	a0,0
    80003a78:	60e2                	ld	ra,24(sp)
    80003a7a:	6442                	ld	s0,16(sp)
    80003a7c:	64a2                	ld	s1,8(sp)
    80003a7e:	6105                	addi	sp,sp,32
    80003a80:	8082                	ret

0000000080003a82 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003a82:	1101                	addi	sp,sp,-32
    80003a84:	ec06                	sd	ra,24(sp)
    80003a86:	e822                	sd	s0,16(sp)
    80003a88:	e426                	sd	s1,8(sp)
    80003a8a:	1000                	addi	s0,sp,32
    80003a8c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003a8e:	00000097          	auipc	ra,0x0
    80003a92:	ed0080e7          	jalr	-304(ra) # 8000395e <argraw>
    80003a96:	e088                	sd	a0,0(s1)
  return 0;
}
    80003a98:	4501                	li	a0,0
    80003a9a:	60e2                	ld	ra,24(sp)
    80003a9c:	6442                	ld	s0,16(sp)
    80003a9e:	64a2                	ld	s1,8(sp)
    80003aa0:	6105                	addi	sp,sp,32
    80003aa2:	8082                	ret

0000000080003aa4 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003aa4:	1101                	addi	sp,sp,-32
    80003aa6:	ec06                	sd	ra,24(sp)
    80003aa8:	e822                	sd	s0,16(sp)
    80003aaa:	e426                	sd	s1,8(sp)
    80003aac:	e04a                	sd	s2,0(sp)
    80003aae:	1000                	addi	s0,sp,32
    80003ab0:	84ae                	mv	s1,a1
    80003ab2:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003ab4:	00000097          	auipc	ra,0x0
    80003ab8:	eaa080e7          	jalr	-342(ra) # 8000395e <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003abc:	864a                	mv	a2,s2
    80003abe:	85a6                	mv	a1,s1
    80003ac0:	00000097          	auipc	ra,0x0
    80003ac4:	f58080e7          	jalr	-168(ra) # 80003a18 <fetchstr>
}
    80003ac8:	60e2                	ld	ra,24(sp)
    80003aca:	6442                	ld	s0,16(sp)
    80003acc:	64a2                	ld	s1,8(sp)
    80003ace:	6902                	ld	s2,0(sp)
    80003ad0:	6105                	addi	sp,sp,32
    80003ad2:	8082                	ret

0000000080003ad4 <syscall>:

};

void
syscall(void)
{
    80003ad4:	1101                	addi	sp,sp,-32
    80003ad6:	ec06                	sd	ra,24(sp)
    80003ad8:	e822                	sd	s0,16(sp)
    80003ada:	e426                	sd	s1,8(sp)
    80003adc:	e04a                	sd	s2,0(sp)
    80003ade:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003ae0:	ffffe097          	auipc	ra,0xffffe
    80003ae4:	ece080e7          	jalr	-306(ra) # 800019ae <myproc>
    80003ae8:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003aea:	05853903          	ld	s2,88(a0)
    80003aee:	0a893783          	ld	a5,168(s2)
    80003af2:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003af6:	37fd                	addiw	a5,a5,-1
    80003af8:	4775                	li	a4,29
    80003afa:	00f76f63          	bltu	a4,a5,80003b18 <syscall+0x44>
    80003afe:	00369713          	slli	a4,a3,0x3
    80003b02:	00006797          	auipc	a5,0x6
    80003b06:	b3e78793          	addi	a5,a5,-1218 # 80009640 <syscalls>
    80003b0a:	97ba                	add	a5,a5,a4
    80003b0c:	639c                	ld	a5,0(a5)
    80003b0e:	c789                	beqz	a5,80003b18 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80003b10:	9782                	jalr	a5
    80003b12:	06a93823          	sd	a0,112(s2)
    80003b16:	a839                	j	80003b34 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003b18:	15848613          	addi	a2,s1,344
    80003b1c:	588c                	lw	a1,48(s1)
    80003b1e:	00006517          	auipc	a0,0x6
    80003b22:	aea50513          	addi	a0,a0,-1302 # 80009608 <states.1846+0x150>
    80003b26:	ffffd097          	auipc	ra,0xffffd
    80003b2a:	a60080e7          	jalr	-1440(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003b2e:	6cbc                	ld	a5,88(s1)
    80003b30:	577d                	li	a4,-1
    80003b32:	fbb8                	sd	a4,112(a5)
  }
}
    80003b34:	60e2                	ld	ra,24(sp)
    80003b36:	6442                	ld	s0,16(sp)
    80003b38:	64a2                	ld	s1,8(sp)
    80003b3a:	6902                	ld	s2,0(sp)
    80003b3c:	6105                	addi	sp,sp,32
    80003b3e:	8082                	ret

0000000080003b40 <sys_exit>:
extern int SCHED_POLICY;


uint64
sys_exit(void)
{
    80003b40:	1101                	addi	sp,sp,-32
    80003b42:	ec06                	sd	ra,24(sp)
    80003b44:	e822                	sd	s0,16(sp)
    80003b46:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003b48:	fec40593          	addi	a1,s0,-20
    80003b4c:	4501                	li	a0,0
    80003b4e:	00000097          	auipc	ra,0x0
    80003b52:	f12080e7          	jalr	-238(ra) # 80003a60 <argint>
    return -1;
    80003b56:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003b58:	00054963          	bltz	a0,80003b6a <sys_exit+0x2a>
  exit(n);
    80003b5c:	fec42503          	lw	a0,-20(s0)
    80003b60:	fffff097          	auipc	ra,0xfffff
    80003b64:	108080e7          	jalr	264(ra) # 80002c68 <exit>
  return 0;  // not reached
    80003b68:	4781                	li	a5,0
}
    80003b6a:	853e                	mv	a0,a5
    80003b6c:	60e2                	ld	ra,24(sp)
    80003b6e:	6442                	ld	s0,16(sp)
    80003b70:	6105                	addi	sp,sp,32
    80003b72:	8082                	ret

0000000080003b74 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003b74:	1141                	addi	sp,sp,-16
    80003b76:	e406                	sd	ra,8(sp)
    80003b78:	e022                	sd	s0,0(sp)
    80003b7a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003b7c:	ffffe097          	auipc	ra,0xffffe
    80003b80:	e32080e7          	jalr	-462(ra) # 800019ae <myproc>
}
    80003b84:	5908                	lw	a0,48(a0)
    80003b86:	60a2                	ld	ra,8(sp)
    80003b88:	6402                	ld	s0,0(sp)
    80003b8a:	0141                	addi	sp,sp,16
    80003b8c:	8082                	ret

0000000080003b8e <sys_fork>:

uint64
sys_fork(void)
{
    80003b8e:	1141                	addi	sp,sp,-16
    80003b90:	e406                	sd	ra,8(sp)
    80003b92:	e022                	sd	s0,0(sp)
    80003b94:	0800                	addi	s0,sp,16
  return fork();
    80003b96:	ffffe097          	auipc	ra,0xffffe
    80003b9a:	270080e7          	jalr	624(ra) # 80001e06 <fork>
}
    80003b9e:	60a2                	ld	ra,8(sp)
    80003ba0:	6402                	ld	s0,0(sp)
    80003ba2:	0141                	addi	sp,sp,16
    80003ba4:	8082                	ret

0000000080003ba6 <sys_forkp>:


// Implementing the new system calls : forkp and schedpolicy
uint64
sys_forkp(void)
{
    80003ba6:	1101                	addi	sp,sp,-32
    80003ba8:	ec06                	sd	ra,24(sp)
    80003baa:	e822                	sd	s0,16(sp)
    80003bac:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0){
    80003bae:	fec40593          	addi	a1,s0,-20
    80003bb2:	4501                	li	a0,0
    80003bb4:	00000097          	auipc	ra,0x0
    80003bb8:	eac080e7          	jalr	-340(ra) # 80003a60 <argint>
    80003bbc:	87aa                	mv	a5,a0
    return -1;
    80003bbe:	557d                	li	a0,-1
  if(argint(0, &n) < 0){
    80003bc0:	0007c863          	bltz	a5,80003bd0 <sys_forkp+0x2a>
  }

  return forkp(n);
    80003bc4:	fec42503          	lw	a0,-20(s0)
    80003bc8:	ffffe097          	auipc	ra,0xffffe
    80003bcc:	37e080e7          	jalr	894(ra) # 80001f46 <forkp>

}
    80003bd0:	60e2                	ld	ra,24(sp)
    80003bd2:	6442                	ld	s0,16(sp)
    80003bd4:	6105                	addi	sp,sp,32
    80003bd6:	8082                	ret

0000000080003bd8 <sys_schedpolicy>:

uint64
sys_schedpolicy(void)
{
    80003bd8:	1101                	addi	sp,sp,-32
    80003bda:	ec06                	sd	ra,24(sp)
    80003bdc:	e822                	sd	s0,16(sp)
    80003bde:	1000                	addi	s0,sp,32
  int new_sched;
  if(argint(0, &new_sched) < 0){
    80003be0:	fec40593          	addi	a1,s0,-20
    80003be4:	4501                	li	a0,0
    80003be6:	00000097          	auipc	ra,0x0
    80003bea:	e7a080e7          	jalr	-390(ra) # 80003a60 <argint>
    80003bee:	87aa                	mv	a5,a0
    return -1;
    80003bf0:	557d                	li	a0,-1
  if(argint(0, &new_sched) < 0){
    80003bf2:	0007c863          	bltz	a5,80003c02 <sys_schedpolicy+0x2a>
  }

  return schedpolicy(new_sched);
    80003bf6:	fec42503          	lw	a0,-20(s0)
    80003bfa:	ffffe097          	auipc	ra,0xffffe
    80003bfe:	7da080e7          	jalr	2010(ra) # 800023d4 <schedpolicy>
}
    80003c02:	60e2                	ld	ra,24(sp)
    80003c04:	6442                	ld	s0,16(sp)
    80003c06:	6105                	addi	sp,sp,32
    80003c08:	8082                	ret

0000000080003c0a <sys_wait>:

uint64
sys_wait(void)
{
    80003c0a:	1101                	addi	sp,sp,-32
    80003c0c:	ec06                	sd	ra,24(sp)
    80003c0e:	e822                	sd	s0,16(sp)
    80003c10:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003c12:	fe840593          	addi	a1,s0,-24
    80003c16:	4501                	li	a0,0
    80003c18:	00000097          	auipc	ra,0x0
    80003c1c:	e6a080e7          	jalr	-406(ra) # 80003a82 <argaddr>
    80003c20:	87aa                	mv	a5,a0
    return -1;
    80003c22:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003c24:	0007c863          	bltz	a5,80003c34 <sys_wait+0x2a>
  return wait(p);
    80003c28:	fe843503          	ld	a0,-24(s0)
    80003c2c:	fffff097          	auipc	ra,0xfffff
    80003c30:	d14080e7          	jalr	-748(ra) # 80002940 <wait>
}
    80003c34:	60e2                	ld	ra,24(sp)
    80003c36:	6442                	ld	s0,16(sp)
    80003c38:	6105                	addi	sp,sp,32
    80003c3a:	8082                	ret

0000000080003c3c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003c3c:	7179                	addi	sp,sp,-48
    80003c3e:	f406                	sd	ra,40(sp)
    80003c40:	f022                	sd	s0,32(sp)
    80003c42:	ec26                	sd	s1,24(sp)
    80003c44:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003c46:	fdc40593          	addi	a1,s0,-36
    80003c4a:	4501                	li	a0,0
    80003c4c:	00000097          	auipc	ra,0x0
    80003c50:	e14080e7          	jalr	-492(ra) # 80003a60 <argint>
    80003c54:	87aa                	mv	a5,a0
    return -1;
    80003c56:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80003c58:	0207c063          	bltz	a5,80003c78 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80003c5c:	ffffe097          	auipc	ra,0xffffe
    80003c60:	d52080e7          	jalr	-686(ra) # 800019ae <myproc>
    80003c64:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80003c66:	fdc42503          	lw	a0,-36(s0)
    80003c6a:	ffffe097          	auipc	ra,0xffffe
    80003c6e:	128080e7          	jalr	296(ra) # 80001d92 <growproc>
    80003c72:	00054863          	bltz	a0,80003c82 <sys_sbrk+0x46>
    return -1;
  return addr;
    80003c76:	8526                	mv	a0,s1
}
    80003c78:	70a2                	ld	ra,40(sp)
    80003c7a:	7402                	ld	s0,32(sp)
    80003c7c:	64e2                	ld	s1,24(sp)
    80003c7e:	6145                	addi	sp,sp,48
    80003c80:	8082                	ret
    return -1;
    80003c82:	557d                	li	a0,-1
    80003c84:	bfd5                	j	80003c78 <sys_sbrk+0x3c>

0000000080003c86 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003c86:	7139                	addi	sp,sp,-64
    80003c88:	fc06                	sd	ra,56(sp)
    80003c8a:	f822                	sd	s0,48(sp)
    80003c8c:	f426                	sd	s1,40(sp)
    80003c8e:	f04a                	sd	s2,32(sp)
    80003c90:	ec4e                	sd	s3,24(sp)
    80003c92:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003c94:	fcc40593          	addi	a1,s0,-52
    80003c98:	4501                	li	a0,0
    80003c9a:	00000097          	auipc	ra,0x0
    80003c9e:	dc6080e7          	jalr	-570(ra) # 80003a60 <argint>
    return -1;
    80003ca2:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003ca4:	06054563          	bltz	a0,80003d0e <sys_sleep+0x88>
  acquire(&tickslock);
    80003ca8:	00015517          	auipc	a0,0x15
    80003cac:	e6850513          	addi	a0,a0,-408 # 80018b10 <tickslock>
    80003cb0:	ffffd097          	auipc	ra,0xffffd
    80003cb4:	f32080e7          	jalr	-206(ra) # 80000be2 <acquire>
  ticks0 = ticks;
    80003cb8:	00006917          	auipc	s2,0x6
    80003cbc:	3b892903          	lw	s2,952(s2) # 8000a070 <ticks>
  while(ticks - ticks0 < n){
    80003cc0:	fcc42783          	lw	a5,-52(s0)
    80003cc4:	cf85                	beqz	a5,80003cfc <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003cc6:	00015997          	auipc	s3,0x15
    80003cca:	e4a98993          	addi	s3,s3,-438 # 80018b10 <tickslock>
    80003cce:	00006497          	auipc	s1,0x6
    80003cd2:	3a248493          	addi	s1,s1,930 # 8000a070 <ticks>
    if(myproc()->killed){
    80003cd6:	ffffe097          	auipc	ra,0xffffe
    80003cda:	cd8080e7          	jalr	-808(ra) # 800019ae <myproc>
    80003cde:	551c                	lw	a5,40(a0)
    80003ce0:	ef9d                	bnez	a5,80003d1e <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003ce2:	85ce                	mv	a1,s3
    80003ce4:	8526                	mv	a0,s1
    80003ce6:	fffff097          	auipc	ra,0xfffff
    80003cea:	a10080e7          	jalr	-1520(ra) # 800026f6 <sleep>
  while(ticks - ticks0 < n){
    80003cee:	409c                	lw	a5,0(s1)
    80003cf0:	412787bb          	subw	a5,a5,s2
    80003cf4:	fcc42703          	lw	a4,-52(s0)
    80003cf8:	fce7efe3          	bltu	a5,a4,80003cd6 <sys_sleep+0x50>
  }
  release(&tickslock);
    80003cfc:	00015517          	auipc	a0,0x15
    80003d00:	e1450513          	addi	a0,a0,-492 # 80018b10 <tickslock>
    80003d04:	ffffd097          	auipc	ra,0xffffd
    80003d08:	f92080e7          	jalr	-110(ra) # 80000c96 <release>
  return 0;
    80003d0c:	4781                	li	a5,0
}
    80003d0e:	853e                	mv	a0,a5
    80003d10:	70e2                	ld	ra,56(sp)
    80003d12:	7442                	ld	s0,48(sp)
    80003d14:	74a2                	ld	s1,40(sp)
    80003d16:	7902                	ld	s2,32(sp)
    80003d18:	69e2                	ld	s3,24(sp)
    80003d1a:	6121                	addi	sp,sp,64
    80003d1c:	8082                	ret
      release(&tickslock);
    80003d1e:	00015517          	auipc	a0,0x15
    80003d22:	df250513          	addi	a0,a0,-526 # 80018b10 <tickslock>
    80003d26:	ffffd097          	auipc	ra,0xffffd
    80003d2a:	f70080e7          	jalr	-144(ra) # 80000c96 <release>
      return -1;
    80003d2e:	57fd                	li	a5,-1
    80003d30:	bff9                	j	80003d0e <sys_sleep+0x88>

0000000080003d32 <sys_kill>:

uint64
sys_kill(void)
{
    80003d32:	1101                	addi	sp,sp,-32
    80003d34:	ec06                	sd	ra,24(sp)
    80003d36:	e822                	sd	s0,16(sp)
    80003d38:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003d3a:	fec40593          	addi	a1,s0,-20
    80003d3e:	4501                	li	a0,0
    80003d40:	00000097          	auipc	ra,0x0
    80003d44:	d20080e7          	jalr	-736(ra) # 80003a60 <argint>
    80003d48:	87aa                	mv	a5,a0
    return -1;
    80003d4a:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003d4c:	0007c863          	bltz	a5,80003d5c <sys_kill+0x2a>
  return kill(pid);
    80003d50:	fec42503          	lw	a0,-20(s0)
    80003d54:	fffff097          	auipc	ra,0xfffff
    80003d58:	324080e7          	jalr	804(ra) # 80003078 <kill>
}
    80003d5c:	60e2                	ld	ra,24(sp)
    80003d5e:	6442                	ld	s0,16(sp)
    80003d60:	6105                	addi	sp,sp,32
    80003d62:	8082                	ret

0000000080003d64 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003d64:	1101                	addi	sp,sp,-32
    80003d66:	ec06                	sd	ra,24(sp)
    80003d68:	e822                	sd	s0,16(sp)
    80003d6a:	e426                	sd	s1,8(sp)
    80003d6c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003d6e:	00015517          	auipc	a0,0x15
    80003d72:	da250513          	addi	a0,a0,-606 # 80018b10 <tickslock>
    80003d76:	ffffd097          	auipc	ra,0xffffd
    80003d7a:	e6c080e7          	jalr	-404(ra) # 80000be2 <acquire>
  xticks = ticks;
    80003d7e:	00006497          	auipc	s1,0x6
    80003d82:	2f24a483          	lw	s1,754(s1) # 8000a070 <ticks>
  release(&tickslock);
    80003d86:	00015517          	auipc	a0,0x15
    80003d8a:	d8a50513          	addi	a0,a0,-630 # 80018b10 <tickslock>
    80003d8e:	ffffd097          	auipc	ra,0xffffd
    80003d92:	f08080e7          	jalr	-248(ra) # 80000c96 <release>
  return xticks;
}
    80003d96:	02049513          	slli	a0,s1,0x20
    80003d9a:	9101                	srli	a0,a0,0x20
    80003d9c:	60e2                	ld	ra,24(sp)
    80003d9e:	6442                	ld	s0,16(sp)
    80003da0:	64a2                	ld	s1,8(sp)
    80003da2:	6105                	addi	sp,sp,32
    80003da4:	8082                	ret

0000000080003da6 <sys_getppid>:

uint64
sys_getppid(void)
{
    80003da6:	1141                	addi	sp,sp,-16
    80003da8:	e406                	sd	ra,8(sp)
    80003daa:	e022                	sd	s0,0(sp)
    80003dac:	0800                	addi	s0,sp,16
  if (myproc()->parent) return myproc()->parent->pid;
    80003dae:	ffffe097          	auipc	ra,0xffffe
    80003db2:	c00080e7          	jalr	-1024(ra) # 800019ae <myproc>
    80003db6:	7d1c                	ld	a5,56(a0)
    80003db8:	cb99                	beqz	a5,80003dce <sys_getppid+0x28>
    80003dba:	ffffe097          	auipc	ra,0xffffe
    80003dbe:	bf4080e7          	jalr	-1036(ra) # 800019ae <myproc>
    80003dc2:	7d1c                	ld	a5,56(a0)
    80003dc4:	5b88                	lw	a0,48(a5)
  else {
     printf("No parent found.\n");
     return 0;
  }
}
    80003dc6:	60a2                	ld	ra,8(sp)
    80003dc8:	6402                	ld	s0,0(sp)
    80003dca:	0141                	addi	sp,sp,16
    80003dcc:	8082                	ret
     printf("No parent found.\n");
    80003dce:	00006517          	auipc	a0,0x6
    80003dd2:	96a50513          	addi	a0,a0,-1686 # 80009738 <syscalls+0xf8>
    80003dd6:	ffffc097          	auipc	ra,0xffffc
    80003dda:	7b0080e7          	jalr	1968(ra) # 80000586 <printf>
     return 0;
    80003dde:	4501                	li	a0,0
    80003de0:	b7dd                	j	80003dc6 <sys_getppid+0x20>

0000000080003de2 <sys_yield>:

uint64
sys_yield(void)
{
    80003de2:	1141                	addi	sp,sp,-16
    80003de4:	e406                	sd	ra,8(sp)
    80003de6:	e022                	sd	s0,0(sp)
    80003de8:	0800                	addi	s0,sp,16
  yield();
    80003dea:	ffffe097          	auipc	ra,0xffffe
    80003dee:	6e2080e7          	jalr	1762(ra) # 800024cc <yield>
  return 0;
}
    80003df2:	4501                	li	a0,0
    80003df4:	60a2                	ld	ra,8(sp)
    80003df6:	6402                	ld	s0,0(sp)
    80003df8:	0141                	addi	sp,sp,16
    80003dfa:	8082                	ret

0000000080003dfc <sys_getpa>:

uint64
sys_getpa(void)
{
    80003dfc:	1101                	addi	sp,sp,-32
    80003dfe:	ec06                	sd	ra,24(sp)
    80003e00:	e822                	sd	s0,16(sp)
    80003e02:	1000                	addi	s0,sp,32
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
    80003e04:	fe840593          	addi	a1,s0,-24
    80003e08:	4501                	li	a0,0
    80003e0a:	00000097          	auipc	ra,0x0
    80003e0e:	c78080e7          	jalr	-904(ra) # 80003a82 <argaddr>
    80003e12:	87aa                	mv	a5,a0
    80003e14:	557d                	li	a0,-1
    80003e16:	0207c263          	bltz	a5,80003e3a <sys_getpa+0x3e>
  return walkaddr(myproc()->pagetable, x) + (x & (PGSIZE - 1));
    80003e1a:	ffffe097          	auipc	ra,0xffffe
    80003e1e:	b94080e7          	jalr	-1132(ra) # 800019ae <myproc>
    80003e22:	fe843583          	ld	a1,-24(s0)
    80003e26:	6928                	ld	a0,80(a0)
    80003e28:	ffffd097          	auipc	ra,0xffffd
    80003e2c:	244080e7          	jalr	580(ra) # 8000106c <walkaddr>
    80003e30:	fe843783          	ld	a5,-24(s0)
    80003e34:	17d2                	slli	a5,a5,0x34
    80003e36:	93d1                	srli	a5,a5,0x34
    80003e38:	953e                	add	a0,a0,a5
}
    80003e3a:	60e2                	ld	ra,24(sp)
    80003e3c:	6442                	ld	s0,16(sp)
    80003e3e:	6105                	addi	sp,sp,32
    80003e40:	8082                	ret

0000000080003e42 <sys_forkf>:

uint64
sys_forkf(void)
{
    80003e42:	1101                	addi	sp,sp,-32
    80003e44:	ec06                	sd	ra,24(sp)
    80003e46:	e822                	sd	s0,16(sp)
    80003e48:	1000                	addi	s0,sp,32
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
    80003e4a:	fe840593          	addi	a1,s0,-24
    80003e4e:	4501                	li	a0,0
    80003e50:	00000097          	auipc	ra,0x0
    80003e54:	c32080e7          	jalr	-974(ra) # 80003a82 <argaddr>
    80003e58:	87aa                	mv	a5,a0
    80003e5a:	557d                	li	a0,-1
    80003e5c:	0007c863          	bltz	a5,80003e6c <sys_forkf+0x2a>
  return forkf(x);
    80003e60:	fe843503          	ld	a0,-24(s0)
    80003e64:	ffffe097          	auipc	ra,0xffffe
    80003e68:	24a080e7          	jalr	586(ra) # 800020ae <forkf>
}
    80003e6c:	60e2                	ld	ra,24(sp)
    80003e6e:	6442                	ld	s0,16(sp)
    80003e70:	6105                	addi	sp,sp,32
    80003e72:	8082                	ret

0000000080003e74 <sys_waitpid>:

uint64
sys_waitpid(void)
{
    80003e74:	1101                	addi	sp,sp,-32
    80003e76:	ec06                	sd	ra,24(sp)
    80003e78:	e822                	sd	s0,16(sp)
    80003e7a:	1000                	addi	s0,sp,32
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    80003e7c:	fe440593          	addi	a1,s0,-28
    80003e80:	4501                	li	a0,0
    80003e82:	00000097          	auipc	ra,0x0
    80003e86:	bde080e7          	jalr	-1058(ra) # 80003a60 <argint>
    return -1;
    80003e8a:	57fd                	li	a5,-1
  if(argint(0, &x) < 0)
    80003e8c:	02054c63          	bltz	a0,80003ec4 <sys_waitpid+0x50>
  if(argaddr(1, &p) < 0)
    80003e90:	fe840593          	addi	a1,s0,-24
    80003e94:	4505                	li	a0,1
    80003e96:	00000097          	auipc	ra,0x0
    80003e9a:	bec080e7          	jalr	-1044(ra) # 80003a82 <argaddr>
    80003e9e:	04054063          	bltz	a0,80003ede <sys_waitpid+0x6a>
    return -1;

  if (x == -1) return wait(p);
    80003ea2:	fe442503          	lw	a0,-28(s0)
    80003ea6:	57fd                	li	a5,-1
    80003ea8:	02f50363          	beq	a0,a5,80003ece <sys_waitpid+0x5a>
  if ((x == 0) || (x < -1)) return -1;
    80003eac:	57fd                	li	a5,-1
    80003eae:	c919                	beqz	a0,80003ec4 <sys_waitpid+0x50>
    80003eb0:	577d                	li	a4,-1
    80003eb2:	00e54963          	blt	a0,a4,80003ec4 <sys_waitpid+0x50>
  return waitpid(x, p);
    80003eb6:	fe843583          	ld	a1,-24(s0)
    80003eba:	fffff097          	auipc	ra,0xfffff
    80003ebe:	bae080e7          	jalr	-1106(ra) # 80002a68 <waitpid>
    80003ec2:	87aa                	mv	a5,a0
}
    80003ec4:	853e                	mv	a0,a5
    80003ec6:	60e2                	ld	ra,24(sp)
    80003ec8:	6442                	ld	s0,16(sp)
    80003eca:	6105                	addi	sp,sp,32
    80003ecc:	8082                	ret
  if (x == -1) return wait(p);
    80003ece:	fe843503          	ld	a0,-24(s0)
    80003ed2:	fffff097          	auipc	ra,0xfffff
    80003ed6:	a6e080e7          	jalr	-1426(ra) # 80002940 <wait>
    80003eda:	87aa                	mv	a5,a0
    80003edc:	b7e5                	j	80003ec4 <sys_waitpid+0x50>
    return -1;
    80003ede:	57fd                	li	a5,-1
    80003ee0:	b7d5                	j	80003ec4 <sys_waitpid+0x50>

0000000080003ee2 <sys_ps>:

uint64
sys_ps(void)
{
    80003ee2:	1141                	addi	sp,sp,-16
    80003ee4:	e406                	sd	ra,8(sp)
    80003ee6:	e022                	sd	s0,0(sp)
    80003ee8:	0800                	addi	s0,sp,16
   return ps();
    80003eea:	fffff097          	auipc	ra,0xfffff
    80003eee:	35a080e7          	jalr	858(ra) # 80003244 <ps>
}
    80003ef2:	60a2                	ld	ra,8(sp)
    80003ef4:	6402                	ld	s0,0(sp)
    80003ef6:	0141                	addi	sp,sp,16
    80003ef8:	8082                	ret

0000000080003efa <sys_pinfo>:

uint64
sys_pinfo(void)
{
    80003efa:	1101                	addi	sp,sp,-32
    80003efc:	ec06                	sd	ra,24(sp)
    80003efe:	e822                	sd	s0,16(sp)
    80003f00:	1000                	addi	s0,sp,32
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    80003f02:	fe440593          	addi	a1,s0,-28
    80003f06:	4501                	li	a0,0
    80003f08:	00000097          	auipc	ra,0x0
    80003f0c:	b58080e7          	jalr	-1192(ra) # 80003a60 <argint>
    return -1;
    80003f10:	57fd                	li	a5,-1
  if(argint(0, &x) < 0)
    80003f12:	02054963          	bltz	a0,80003f44 <sys_pinfo+0x4a>
  if(argaddr(1, &p) < 0)
    80003f16:	fe840593          	addi	a1,s0,-24
    80003f1a:	4505                	li	a0,1
    80003f1c:	00000097          	auipc	ra,0x0
    80003f20:	b66080e7          	jalr	-1178(ra) # 80003a82 <argaddr>
    80003f24:	02054563          	bltz	a0,80003f4e <sys_pinfo+0x54>
    return -1;

  if ((x == 0) || (x < -1) || (p == 0)) return -1;
    80003f28:	fe442503          	lw	a0,-28(s0)
    80003f2c:	57fd                	li	a5,-1
    80003f2e:	c919                	beqz	a0,80003f44 <sys_pinfo+0x4a>
    80003f30:	02f54163          	blt	a0,a5,80003f52 <sys_pinfo+0x58>
    80003f34:	fe843583          	ld	a1,-24(s0)
    80003f38:	c591                	beqz	a1,80003f44 <sys_pinfo+0x4a>
  return pinfo(x, p);
    80003f3a:	fffff097          	auipc	ra,0xfffff
    80003f3e:	476080e7          	jalr	1142(ra) # 800033b0 <pinfo>
    80003f42:	87aa                	mv	a5,a0
}
    80003f44:	853e                	mv	a0,a5
    80003f46:	60e2                	ld	ra,24(sp)
    80003f48:	6442                	ld	s0,16(sp)
    80003f4a:	6105                	addi	sp,sp,32
    80003f4c:	8082                	ret
    return -1;
    80003f4e:	57fd                	li	a5,-1
    80003f50:	bfd5                	j	80003f44 <sys_pinfo+0x4a>
  if ((x == 0) || (x < -1) || (p == 0)) return -1;
    80003f52:	57fd                	li	a5,-1
    80003f54:	bfc5                	j	80003f44 <sys_pinfo+0x4a>

0000000080003f56 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003f56:	7179                	addi	sp,sp,-48
    80003f58:	f406                	sd	ra,40(sp)
    80003f5a:	f022                	sd	s0,32(sp)
    80003f5c:	ec26                	sd	s1,24(sp)
    80003f5e:	e84a                	sd	s2,16(sp)
    80003f60:	e44e                	sd	s3,8(sp)
    80003f62:	e052                	sd	s4,0(sp)
    80003f64:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003f66:	00005597          	auipc	a1,0x5
    80003f6a:	7ea58593          	addi	a1,a1,2026 # 80009750 <syscalls+0x110>
    80003f6e:	00015517          	auipc	a0,0x15
    80003f72:	bba50513          	addi	a0,a0,-1094 # 80018b28 <bcache>
    80003f76:	ffffd097          	auipc	ra,0xffffd
    80003f7a:	bdc080e7          	jalr	-1060(ra) # 80000b52 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003f7e:	0001d797          	auipc	a5,0x1d
    80003f82:	baa78793          	addi	a5,a5,-1110 # 80020b28 <bcache+0x8000>
    80003f86:	0001d717          	auipc	a4,0x1d
    80003f8a:	e0a70713          	addi	a4,a4,-502 # 80020d90 <bcache+0x8268>
    80003f8e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003f92:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003f96:	00015497          	auipc	s1,0x15
    80003f9a:	baa48493          	addi	s1,s1,-1110 # 80018b40 <bcache+0x18>
    b->next = bcache.head.next;
    80003f9e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003fa0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003fa2:	00005a17          	auipc	s4,0x5
    80003fa6:	7b6a0a13          	addi	s4,s4,1974 # 80009758 <syscalls+0x118>
    b->next = bcache.head.next;
    80003faa:	2b893783          	ld	a5,696(s2)
    80003fae:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003fb0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003fb4:	85d2                	mv	a1,s4
    80003fb6:	01048513          	addi	a0,s1,16
    80003fba:	00001097          	auipc	ra,0x1
    80003fbe:	4bc080e7          	jalr	1212(ra) # 80005476 <initsleeplock>
    bcache.head.next->prev = b;
    80003fc2:	2b893783          	ld	a5,696(s2)
    80003fc6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003fc8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003fcc:	45848493          	addi	s1,s1,1112
    80003fd0:	fd349de3          	bne	s1,s3,80003faa <binit+0x54>
  }
}
    80003fd4:	70a2                	ld	ra,40(sp)
    80003fd6:	7402                	ld	s0,32(sp)
    80003fd8:	64e2                	ld	s1,24(sp)
    80003fda:	6942                	ld	s2,16(sp)
    80003fdc:	69a2                	ld	s3,8(sp)
    80003fde:	6a02                	ld	s4,0(sp)
    80003fe0:	6145                	addi	sp,sp,48
    80003fe2:	8082                	ret

0000000080003fe4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003fe4:	7179                	addi	sp,sp,-48
    80003fe6:	f406                	sd	ra,40(sp)
    80003fe8:	f022                	sd	s0,32(sp)
    80003fea:	ec26                	sd	s1,24(sp)
    80003fec:	e84a                	sd	s2,16(sp)
    80003fee:	e44e                	sd	s3,8(sp)
    80003ff0:	1800                	addi	s0,sp,48
    80003ff2:	89aa                	mv	s3,a0
    80003ff4:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003ff6:	00015517          	auipc	a0,0x15
    80003ffa:	b3250513          	addi	a0,a0,-1230 # 80018b28 <bcache>
    80003ffe:	ffffd097          	auipc	ra,0xffffd
    80004002:	be4080e7          	jalr	-1052(ra) # 80000be2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80004006:	0001d497          	auipc	s1,0x1d
    8000400a:	dda4b483          	ld	s1,-550(s1) # 80020de0 <bcache+0x82b8>
    8000400e:	0001d797          	auipc	a5,0x1d
    80004012:	d8278793          	addi	a5,a5,-638 # 80020d90 <bcache+0x8268>
    80004016:	02f48f63          	beq	s1,a5,80004054 <bread+0x70>
    8000401a:	873e                	mv	a4,a5
    8000401c:	a021                	j	80004024 <bread+0x40>
    8000401e:	68a4                	ld	s1,80(s1)
    80004020:	02e48a63          	beq	s1,a4,80004054 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80004024:	449c                	lw	a5,8(s1)
    80004026:	ff379ce3          	bne	a5,s3,8000401e <bread+0x3a>
    8000402a:	44dc                	lw	a5,12(s1)
    8000402c:	ff2799e3          	bne	a5,s2,8000401e <bread+0x3a>
      b->refcnt++;
    80004030:	40bc                	lw	a5,64(s1)
    80004032:	2785                	addiw	a5,a5,1
    80004034:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80004036:	00015517          	auipc	a0,0x15
    8000403a:	af250513          	addi	a0,a0,-1294 # 80018b28 <bcache>
    8000403e:	ffffd097          	auipc	ra,0xffffd
    80004042:	c58080e7          	jalr	-936(ra) # 80000c96 <release>
      acquiresleep(&b->lock);
    80004046:	01048513          	addi	a0,s1,16
    8000404a:	00001097          	auipc	ra,0x1
    8000404e:	466080e7          	jalr	1126(ra) # 800054b0 <acquiresleep>
      return b;
    80004052:	a8b9                	j	800040b0 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80004054:	0001d497          	auipc	s1,0x1d
    80004058:	d844b483          	ld	s1,-636(s1) # 80020dd8 <bcache+0x82b0>
    8000405c:	0001d797          	auipc	a5,0x1d
    80004060:	d3478793          	addi	a5,a5,-716 # 80020d90 <bcache+0x8268>
    80004064:	00f48863          	beq	s1,a5,80004074 <bread+0x90>
    80004068:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000406a:	40bc                	lw	a5,64(s1)
    8000406c:	cf81                	beqz	a5,80004084 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000406e:	64a4                	ld	s1,72(s1)
    80004070:	fee49de3          	bne	s1,a4,8000406a <bread+0x86>
  panic("bget: no buffers");
    80004074:	00005517          	auipc	a0,0x5
    80004078:	6ec50513          	addi	a0,a0,1772 # 80009760 <syscalls+0x120>
    8000407c:	ffffc097          	auipc	ra,0xffffc
    80004080:	4c0080e7          	jalr	1216(ra) # 8000053c <panic>
      b->dev = dev;
    80004084:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80004088:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000408c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80004090:	4785                	li	a5,1
    80004092:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80004094:	00015517          	auipc	a0,0x15
    80004098:	a9450513          	addi	a0,a0,-1388 # 80018b28 <bcache>
    8000409c:	ffffd097          	auipc	ra,0xffffd
    800040a0:	bfa080e7          	jalr	-1030(ra) # 80000c96 <release>
      acquiresleep(&b->lock);
    800040a4:	01048513          	addi	a0,s1,16
    800040a8:	00001097          	auipc	ra,0x1
    800040ac:	408080e7          	jalr	1032(ra) # 800054b0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800040b0:	409c                	lw	a5,0(s1)
    800040b2:	cb89                	beqz	a5,800040c4 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800040b4:	8526                	mv	a0,s1
    800040b6:	70a2                	ld	ra,40(sp)
    800040b8:	7402                	ld	s0,32(sp)
    800040ba:	64e2                	ld	s1,24(sp)
    800040bc:	6942                	ld	s2,16(sp)
    800040be:	69a2                	ld	s3,8(sp)
    800040c0:	6145                	addi	sp,sp,48
    800040c2:	8082                	ret
    virtio_disk_rw(b, 0);
    800040c4:	4581                	li	a1,0
    800040c6:	8526                	mv	a0,s1
    800040c8:	00003097          	auipc	ra,0x3
    800040cc:	f0e080e7          	jalr	-242(ra) # 80006fd6 <virtio_disk_rw>
    b->valid = 1;
    800040d0:	4785                	li	a5,1
    800040d2:	c09c                	sw	a5,0(s1)
  return b;
    800040d4:	b7c5                	j	800040b4 <bread+0xd0>

00000000800040d6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800040d6:	1101                	addi	sp,sp,-32
    800040d8:	ec06                	sd	ra,24(sp)
    800040da:	e822                	sd	s0,16(sp)
    800040dc:	e426                	sd	s1,8(sp)
    800040de:	1000                	addi	s0,sp,32
    800040e0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800040e2:	0541                	addi	a0,a0,16
    800040e4:	00001097          	auipc	ra,0x1
    800040e8:	466080e7          	jalr	1126(ra) # 8000554a <holdingsleep>
    800040ec:	cd01                	beqz	a0,80004104 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800040ee:	4585                	li	a1,1
    800040f0:	8526                	mv	a0,s1
    800040f2:	00003097          	auipc	ra,0x3
    800040f6:	ee4080e7          	jalr	-284(ra) # 80006fd6 <virtio_disk_rw>
}
    800040fa:	60e2                	ld	ra,24(sp)
    800040fc:	6442                	ld	s0,16(sp)
    800040fe:	64a2                	ld	s1,8(sp)
    80004100:	6105                	addi	sp,sp,32
    80004102:	8082                	ret
    panic("bwrite");
    80004104:	00005517          	auipc	a0,0x5
    80004108:	67450513          	addi	a0,a0,1652 # 80009778 <syscalls+0x138>
    8000410c:	ffffc097          	auipc	ra,0xffffc
    80004110:	430080e7          	jalr	1072(ra) # 8000053c <panic>

0000000080004114 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80004114:	1101                	addi	sp,sp,-32
    80004116:	ec06                	sd	ra,24(sp)
    80004118:	e822                	sd	s0,16(sp)
    8000411a:	e426                	sd	s1,8(sp)
    8000411c:	e04a                	sd	s2,0(sp)
    8000411e:	1000                	addi	s0,sp,32
    80004120:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004122:	01050913          	addi	s2,a0,16
    80004126:	854a                	mv	a0,s2
    80004128:	00001097          	auipc	ra,0x1
    8000412c:	422080e7          	jalr	1058(ra) # 8000554a <holdingsleep>
    80004130:	c92d                	beqz	a0,800041a2 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80004132:	854a                	mv	a0,s2
    80004134:	00001097          	auipc	ra,0x1
    80004138:	3d2080e7          	jalr	978(ra) # 80005506 <releasesleep>

  acquire(&bcache.lock);
    8000413c:	00015517          	auipc	a0,0x15
    80004140:	9ec50513          	addi	a0,a0,-1556 # 80018b28 <bcache>
    80004144:	ffffd097          	auipc	ra,0xffffd
    80004148:	a9e080e7          	jalr	-1378(ra) # 80000be2 <acquire>
  b->refcnt--;
    8000414c:	40bc                	lw	a5,64(s1)
    8000414e:	37fd                	addiw	a5,a5,-1
    80004150:	0007871b          	sext.w	a4,a5
    80004154:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80004156:	eb05                	bnez	a4,80004186 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80004158:	68bc                	ld	a5,80(s1)
    8000415a:	64b8                	ld	a4,72(s1)
    8000415c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000415e:	64bc                	ld	a5,72(s1)
    80004160:	68b8                	ld	a4,80(s1)
    80004162:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80004164:	0001d797          	auipc	a5,0x1d
    80004168:	9c478793          	addi	a5,a5,-1596 # 80020b28 <bcache+0x8000>
    8000416c:	2b87b703          	ld	a4,696(a5)
    80004170:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80004172:	0001d717          	auipc	a4,0x1d
    80004176:	c1e70713          	addi	a4,a4,-994 # 80020d90 <bcache+0x8268>
    8000417a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000417c:	2b87b703          	ld	a4,696(a5)
    80004180:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80004182:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80004186:	00015517          	auipc	a0,0x15
    8000418a:	9a250513          	addi	a0,a0,-1630 # 80018b28 <bcache>
    8000418e:	ffffd097          	auipc	ra,0xffffd
    80004192:	b08080e7          	jalr	-1272(ra) # 80000c96 <release>
}
    80004196:	60e2                	ld	ra,24(sp)
    80004198:	6442                	ld	s0,16(sp)
    8000419a:	64a2                	ld	s1,8(sp)
    8000419c:	6902                	ld	s2,0(sp)
    8000419e:	6105                	addi	sp,sp,32
    800041a0:	8082                	ret
    panic("brelse");
    800041a2:	00005517          	auipc	a0,0x5
    800041a6:	5de50513          	addi	a0,a0,1502 # 80009780 <syscalls+0x140>
    800041aa:	ffffc097          	auipc	ra,0xffffc
    800041ae:	392080e7          	jalr	914(ra) # 8000053c <panic>

00000000800041b2 <bpin>:

void
bpin(struct buf *b) {
    800041b2:	1101                	addi	sp,sp,-32
    800041b4:	ec06                	sd	ra,24(sp)
    800041b6:	e822                	sd	s0,16(sp)
    800041b8:	e426                	sd	s1,8(sp)
    800041ba:	1000                	addi	s0,sp,32
    800041bc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800041be:	00015517          	auipc	a0,0x15
    800041c2:	96a50513          	addi	a0,a0,-1686 # 80018b28 <bcache>
    800041c6:	ffffd097          	auipc	ra,0xffffd
    800041ca:	a1c080e7          	jalr	-1508(ra) # 80000be2 <acquire>
  b->refcnt++;
    800041ce:	40bc                	lw	a5,64(s1)
    800041d0:	2785                	addiw	a5,a5,1
    800041d2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800041d4:	00015517          	auipc	a0,0x15
    800041d8:	95450513          	addi	a0,a0,-1708 # 80018b28 <bcache>
    800041dc:	ffffd097          	auipc	ra,0xffffd
    800041e0:	aba080e7          	jalr	-1350(ra) # 80000c96 <release>
}
    800041e4:	60e2                	ld	ra,24(sp)
    800041e6:	6442                	ld	s0,16(sp)
    800041e8:	64a2                	ld	s1,8(sp)
    800041ea:	6105                	addi	sp,sp,32
    800041ec:	8082                	ret

00000000800041ee <bunpin>:

void
bunpin(struct buf *b) {
    800041ee:	1101                	addi	sp,sp,-32
    800041f0:	ec06                	sd	ra,24(sp)
    800041f2:	e822                	sd	s0,16(sp)
    800041f4:	e426                	sd	s1,8(sp)
    800041f6:	1000                	addi	s0,sp,32
    800041f8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800041fa:	00015517          	auipc	a0,0x15
    800041fe:	92e50513          	addi	a0,a0,-1746 # 80018b28 <bcache>
    80004202:	ffffd097          	auipc	ra,0xffffd
    80004206:	9e0080e7          	jalr	-1568(ra) # 80000be2 <acquire>
  b->refcnt--;
    8000420a:	40bc                	lw	a5,64(s1)
    8000420c:	37fd                	addiw	a5,a5,-1
    8000420e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004210:	00015517          	auipc	a0,0x15
    80004214:	91850513          	addi	a0,a0,-1768 # 80018b28 <bcache>
    80004218:	ffffd097          	auipc	ra,0xffffd
    8000421c:	a7e080e7          	jalr	-1410(ra) # 80000c96 <release>
}
    80004220:	60e2                	ld	ra,24(sp)
    80004222:	6442                	ld	s0,16(sp)
    80004224:	64a2                	ld	s1,8(sp)
    80004226:	6105                	addi	sp,sp,32
    80004228:	8082                	ret

000000008000422a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000422a:	1101                	addi	sp,sp,-32
    8000422c:	ec06                	sd	ra,24(sp)
    8000422e:	e822                	sd	s0,16(sp)
    80004230:	e426                	sd	s1,8(sp)
    80004232:	e04a                	sd	s2,0(sp)
    80004234:	1000                	addi	s0,sp,32
    80004236:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80004238:	00d5d59b          	srliw	a1,a1,0xd
    8000423c:	0001d797          	auipc	a5,0x1d
    80004240:	fc87a783          	lw	a5,-56(a5) # 80021204 <sb+0x1c>
    80004244:	9dbd                	addw	a1,a1,a5
    80004246:	00000097          	auipc	ra,0x0
    8000424a:	d9e080e7          	jalr	-610(ra) # 80003fe4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000424e:	0074f713          	andi	a4,s1,7
    80004252:	4785                	li	a5,1
    80004254:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80004258:	14ce                	slli	s1,s1,0x33
    8000425a:	90d9                	srli	s1,s1,0x36
    8000425c:	00950733          	add	a4,a0,s1
    80004260:	05874703          	lbu	a4,88(a4)
    80004264:	00e7f6b3          	and	a3,a5,a4
    80004268:	c69d                	beqz	a3,80004296 <bfree+0x6c>
    8000426a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000426c:	94aa                	add	s1,s1,a0
    8000426e:	fff7c793          	not	a5,a5
    80004272:	8ff9                	and	a5,a5,a4
    80004274:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80004278:	00001097          	auipc	ra,0x1
    8000427c:	118080e7          	jalr	280(ra) # 80005390 <log_write>
  brelse(bp);
    80004280:	854a                	mv	a0,s2
    80004282:	00000097          	auipc	ra,0x0
    80004286:	e92080e7          	jalr	-366(ra) # 80004114 <brelse>
}
    8000428a:	60e2                	ld	ra,24(sp)
    8000428c:	6442                	ld	s0,16(sp)
    8000428e:	64a2                	ld	s1,8(sp)
    80004290:	6902                	ld	s2,0(sp)
    80004292:	6105                	addi	sp,sp,32
    80004294:	8082                	ret
    panic("freeing free block");
    80004296:	00005517          	auipc	a0,0x5
    8000429a:	4f250513          	addi	a0,a0,1266 # 80009788 <syscalls+0x148>
    8000429e:	ffffc097          	auipc	ra,0xffffc
    800042a2:	29e080e7          	jalr	670(ra) # 8000053c <panic>

00000000800042a6 <balloc>:
{
    800042a6:	711d                	addi	sp,sp,-96
    800042a8:	ec86                	sd	ra,88(sp)
    800042aa:	e8a2                	sd	s0,80(sp)
    800042ac:	e4a6                	sd	s1,72(sp)
    800042ae:	e0ca                	sd	s2,64(sp)
    800042b0:	fc4e                	sd	s3,56(sp)
    800042b2:	f852                	sd	s4,48(sp)
    800042b4:	f456                	sd	s5,40(sp)
    800042b6:	f05a                	sd	s6,32(sp)
    800042b8:	ec5e                	sd	s7,24(sp)
    800042ba:	e862                	sd	s8,16(sp)
    800042bc:	e466                	sd	s9,8(sp)
    800042be:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800042c0:	0001d797          	auipc	a5,0x1d
    800042c4:	f2c7a783          	lw	a5,-212(a5) # 800211ec <sb+0x4>
    800042c8:	cbd1                	beqz	a5,8000435c <balloc+0xb6>
    800042ca:	8baa                	mv	s7,a0
    800042cc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800042ce:	0001db17          	auipc	s6,0x1d
    800042d2:	f1ab0b13          	addi	s6,s6,-230 # 800211e8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800042d6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800042d8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800042da:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800042dc:	6c89                	lui	s9,0x2
    800042de:	a831                	j	800042fa <balloc+0x54>
    brelse(bp);
    800042e0:	854a                	mv	a0,s2
    800042e2:	00000097          	auipc	ra,0x0
    800042e6:	e32080e7          	jalr	-462(ra) # 80004114 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800042ea:	015c87bb          	addw	a5,s9,s5
    800042ee:	00078a9b          	sext.w	s5,a5
    800042f2:	004b2703          	lw	a4,4(s6)
    800042f6:	06eaf363          	bgeu	s5,a4,8000435c <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800042fa:	41fad79b          	sraiw	a5,s5,0x1f
    800042fe:	0137d79b          	srliw	a5,a5,0x13
    80004302:	015787bb          	addw	a5,a5,s5
    80004306:	40d7d79b          	sraiw	a5,a5,0xd
    8000430a:	01cb2583          	lw	a1,28(s6)
    8000430e:	9dbd                	addw	a1,a1,a5
    80004310:	855e                	mv	a0,s7
    80004312:	00000097          	auipc	ra,0x0
    80004316:	cd2080e7          	jalr	-814(ra) # 80003fe4 <bread>
    8000431a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000431c:	004b2503          	lw	a0,4(s6)
    80004320:	000a849b          	sext.w	s1,s5
    80004324:	8662                	mv	a2,s8
    80004326:	faa4fde3          	bgeu	s1,a0,800042e0 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000432a:	41f6579b          	sraiw	a5,a2,0x1f
    8000432e:	01d7d69b          	srliw	a3,a5,0x1d
    80004332:	00c6873b          	addw	a4,a3,a2
    80004336:	00777793          	andi	a5,a4,7
    8000433a:	9f95                	subw	a5,a5,a3
    8000433c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80004340:	4037571b          	sraiw	a4,a4,0x3
    80004344:	00e906b3          	add	a3,s2,a4
    80004348:	0586c683          	lbu	a3,88(a3)
    8000434c:	00d7f5b3          	and	a1,a5,a3
    80004350:	cd91                	beqz	a1,8000436c <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004352:	2605                	addiw	a2,a2,1
    80004354:	2485                	addiw	s1,s1,1
    80004356:	fd4618e3          	bne	a2,s4,80004326 <balloc+0x80>
    8000435a:	b759                	j	800042e0 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000435c:	00005517          	auipc	a0,0x5
    80004360:	44450513          	addi	a0,a0,1092 # 800097a0 <syscalls+0x160>
    80004364:	ffffc097          	auipc	ra,0xffffc
    80004368:	1d8080e7          	jalr	472(ra) # 8000053c <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000436c:	974a                	add	a4,a4,s2
    8000436e:	8fd5                	or	a5,a5,a3
    80004370:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80004374:	854a                	mv	a0,s2
    80004376:	00001097          	auipc	ra,0x1
    8000437a:	01a080e7          	jalr	26(ra) # 80005390 <log_write>
        brelse(bp);
    8000437e:	854a                	mv	a0,s2
    80004380:	00000097          	auipc	ra,0x0
    80004384:	d94080e7          	jalr	-620(ra) # 80004114 <brelse>
  bp = bread(dev, bno);
    80004388:	85a6                	mv	a1,s1
    8000438a:	855e                	mv	a0,s7
    8000438c:	00000097          	auipc	ra,0x0
    80004390:	c58080e7          	jalr	-936(ra) # 80003fe4 <bread>
    80004394:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80004396:	40000613          	li	a2,1024
    8000439a:	4581                	li	a1,0
    8000439c:	05850513          	addi	a0,a0,88
    800043a0:	ffffd097          	auipc	ra,0xffffd
    800043a4:	93e080e7          	jalr	-1730(ra) # 80000cde <memset>
  log_write(bp);
    800043a8:	854a                	mv	a0,s2
    800043aa:	00001097          	auipc	ra,0x1
    800043ae:	fe6080e7          	jalr	-26(ra) # 80005390 <log_write>
  brelse(bp);
    800043b2:	854a                	mv	a0,s2
    800043b4:	00000097          	auipc	ra,0x0
    800043b8:	d60080e7          	jalr	-672(ra) # 80004114 <brelse>
}
    800043bc:	8526                	mv	a0,s1
    800043be:	60e6                	ld	ra,88(sp)
    800043c0:	6446                	ld	s0,80(sp)
    800043c2:	64a6                	ld	s1,72(sp)
    800043c4:	6906                	ld	s2,64(sp)
    800043c6:	79e2                	ld	s3,56(sp)
    800043c8:	7a42                	ld	s4,48(sp)
    800043ca:	7aa2                	ld	s5,40(sp)
    800043cc:	7b02                	ld	s6,32(sp)
    800043ce:	6be2                	ld	s7,24(sp)
    800043d0:	6c42                	ld	s8,16(sp)
    800043d2:	6ca2                	ld	s9,8(sp)
    800043d4:	6125                	addi	sp,sp,96
    800043d6:	8082                	ret

00000000800043d8 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800043d8:	7179                	addi	sp,sp,-48
    800043da:	f406                	sd	ra,40(sp)
    800043dc:	f022                	sd	s0,32(sp)
    800043de:	ec26                	sd	s1,24(sp)
    800043e0:	e84a                	sd	s2,16(sp)
    800043e2:	e44e                	sd	s3,8(sp)
    800043e4:	e052                	sd	s4,0(sp)
    800043e6:	1800                	addi	s0,sp,48
    800043e8:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800043ea:	47ad                	li	a5,11
    800043ec:	04b7fe63          	bgeu	a5,a1,80004448 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800043f0:	ff45849b          	addiw	s1,a1,-12
    800043f4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800043f8:	0ff00793          	li	a5,255
    800043fc:	0ae7e363          	bltu	a5,a4,800044a2 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80004400:	08052583          	lw	a1,128(a0)
    80004404:	c5ad                	beqz	a1,8000446e <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80004406:	00092503          	lw	a0,0(s2)
    8000440a:	00000097          	auipc	ra,0x0
    8000440e:	bda080e7          	jalr	-1062(ra) # 80003fe4 <bread>
    80004412:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004414:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004418:	02049593          	slli	a1,s1,0x20
    8000441c:	9181                	srli	a1,a1,0x20
    8000441e:	058a                	slli	a1,a1,0x2
    80004420:	00b784b3          	add	s1,a5,a1
    80004424:	0004a983          	lw	s3,0(s1)
    80004428:	04098d63          	beqz	s3,80004482 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000442c:	8552                	mv	a0,s4
    8000442e:	00000097          	auipc	ra,0x0
    80004432:	ce6080e7          	jalr	-794(ra) # 80004114 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80004436:	854e                	mv	a0,s3
    80004438:	70a2                	ld	ra,40(sp)
    8000443a:	7402                	ld	s0,32(sp)
    8000443c:	64e2                	ld	s1,24(sp)
    8000443e:	6942                	ld	s2,16(sp)
    80004440:	69a2                	ld	s3,8(sp)
    80004442:	6a02                	ld	s4,0(sp)
    80004444:	6145                	addi	sp,sp,48
    80004446:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80004448:	02059493          	slli	s1,a1,0x20
    8000444c:	9081                	srli	s1,s1,0x20
    8000444e:	048a                	slli	s1,s1,0x2
    80004450:	94aa                	add	s1,s1,a0
    80004452:	0504a983          	lw	s3,80(s1)
    80004456:	fe0990e3          	bnez	s3,80004436 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000445a:	4108                	lw	a0,0(a0)
    8000445c:	00000097          	auipc	ra,0x0
    80004460:	e4a080e7          	jalr	-438(ra) # 800042a6 <balloc>
    80004464:	0005099b          	sext.w	s3,a0
    80004468:	0534a823          	sw	s3,80(s1)
    8000446c:	b7e9                	j	80004436 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000446e:	4108                	lw	a0,0(a0)
    80004470:	00000097          	auipc	ra,0x0
    80004474:	e36080e7          	jalr	-458(ra) # 800042a6 <balloc>
    80004478:	0005059b          	sext.w	a1,a0
    8000447c:	08b92023          	sw	a1,128(s2)
    80004480:	b759                	j	80004406 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80004482:	00092503          	lw	a0,0(s2)
    80004486:	00000097          	auipc	ra,0x0
    8000448a:	e20080e7          	jalr	-480(ra) # 800042a6 <balloc>
    8000448e:	0005099b          	sext.w	s3,a0
    80004492:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80004496:	8552                	mv	a0,s4
    80004498:	00001097          	auipc	ra,0x1
    8000449c:	ef8080e7          	jalr	-264(ra) # 80005390 <log_write>
    800044a0:	b771                	j	8000442c <bmap+0x54>
  panic("bmap: out of range");
    800044a2:	00005517          	auipc	a0,0x5
    800044a6:	31650513          	addi	a0,a0,790 # 800097b8 <syscalls+0x178>
    800044aa:	ffffc097          	auipc	ra,0xffffc
    800044ae:	092080e7          	jalr	146(ra) # 8000053c <panic>

00000000800044b2 <iget>:
{
    800044b2:	7179                	addi	sp,sp,-48
    800044b4:	f406                	sd	ra,40(sp)
    800044b6:	f022                	sd	s0,32(sp)
    800044b8:	ec26                	sd	s1,24(sp)
    800044ba:	e84a                	sd	s2,16(sp)
    800044bc:	e44e                	sd	s3,8(sp)
    800044be:	e052                	sd	s4,0(sp)
    800044c0:	1800                	addi	s0,sp,48
    800044c2:	89aa                	mv	s3,a0
    800044c4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800044c6:	0001d517          	auipc	a0,0x1d
    800044ca:	d4250513          	addi	a0,a0,-702 # 80021208 <itable>
    800044ce:	ffffc097          	auipc	ra,0xffffc
    800044d2:	714080e7          	jalr	1812(ra) # 80000be2 <acquire>
  empty = 0;
    800044d6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800044d8:	0001d497          	auipc	s1,0x1d
    800044dc:	d4848493          	addi	s1,s1,-696 # 80021220 <itable+0x18>
    800044e0:	0001e697          	auipc	a3,0x1e
    800044e4:	7d068693          	addi	a3,a3,2000 # 80022cb0 <log>
    800044e8:	a039                	j	800044f6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800044ea:	02090b63          	beqz	s2,80004520 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800044ee:	08848493          	addi	s1,s1,136
    800044f2:	02d48a63          	beq	s1,a3,80004526 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800044f6:	449c                	lw	a5,8(s1)
    800044f8:	fef059e3          	blez	a5,800044ea <iget+0x38>
    800044fc:	4098                	lw	a4,0(s1)
    800044fe:	ff3716e3          	bne	a4,s3,800044ea <iget+0x38>
    80004502:	40d8                	lw	a4,4(s1)
    80004504:	ff4713e3          	bne	a4,s4,800044ea <iget+0x38>
      ip->ref++;
    80004508:	2785                	addiw	a5,a5,1
    8000450a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000450c:	0001d517          	auipc	a0,0x1d
    80004510:	cfc50513          	addi	a0,a0,-772 # 80021208 <itable>
    80004514:	ffffc097          	auipc	ra,0xffffc
    80004518:	782080e7          	jalr	1922(ra) # 80000c96 <release>
      return ip;
    8000451c:	8926                	mv	s2,s1
    8000451e:	a03d                	j	8000454c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004520:	f7f9                	bnez	a5,800044ee <iget+0x3c>
    80004522:	8926                	mv	s2,s1
    80004524:	b7e9                	j	800044ee <iget+0x3c>
  if(empty == 0)
    80004526:	02090c63          	beqz	s2,8000455e <iget+0xac>
  ip->dev = dev;
    8000452a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000452e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80004532:	4785                	li	a5,1
    80004534:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004538:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000453c:	0001d517          	auipc	a0,0x1d
    80004540:	ccc50513          	addi	a0,a0,-820 # 80021208 <itable>
    80004544:	ffffc097          	auipc	ra,0xffffc
    80004548:	752080e7          	jalr	1874(ra) # 80000c96 <release>
}
    8000454c:	854a                	mv	a0,s2
    8000454e:	70a2                	ld	ra,40(sp)
    80004550:	7402                	ld	s0,32(sp)
    80004552:	64e2                	ld	s1,24(sp)
    80004554:	6942                	ld	s2,16(sp)
    80004556:	69a2                	ld	s3,8(sp)
    80004558:	6a02                	ld	s4,0(sp)
    8000455a:	6145                	addi	sp,sp,48
    8000455c:	8082                	ret
    panic("iget: no inodes");
    8000455e:	00005517          	auipc	a0,0x5
    80004562:	27250513          	addi	a0,a0,626 # 800097d0 <syscalls+0x190>
    80004566:	ffffc097          	auipc	ra,0xffffc
    8000456a:	fd6080e7          	jalr	-42(ra) # 8000053c <panic>

000000008000456e <fsinit>:
fsinit(int dev) {
    8000456e:	7179                	addi	sp,sp,-48
    80004570:	f406                	sd	ra,40(sp)
    80004572:	f022                	sd	s0,32(sp)
    80004574:	ec26                	sd	s1,24(sp)
    80004576:	e84a                	sd	s2,16(sp)
    80004578:	e44e                	sd	s3,8(sp)
    8000457a:	1800                	addi	s0,sp,48
    8000457c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000457e:	4585                	li	a1,1
    80004580:	00000097          	auipc	ra,0x0
    80004584:	a64080e7          	jalr	-1436(ra) # 80003fe4 <bread>
    80004588:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000458a:	0001d997          	auipc	s3,0x1d
    8000458e:	c5e98993          	addi	s3,s3,-930 # 800211e8 <sb>
    80004592:	02000613          	li	a2,32
    80004596:	05850593          	addi	a1,a0,88
    8000459a:	854e                	mv	a0,s3
    8000459c:	ffffc097          	auipc	ra,0xffffc
    800045a0:	7a2080e7          	jalr	1954(ra) # 80000d3e <memmove>
  brelse(bp);
    800045a4:	8526                	mv	a0,s1
    800045a6:	00000097          	auipc	ra,0x0
    800045aa:	b6e080e7          	jalr	-1170(ra) # 80004114 <brelse>
  if(sb.magic != FSMAGIC)
    800045ae:	0009a703          	lw	a4,0(s3)
    800045b2:	102037b7          	lui	a5,0x10203
    800045b6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800045ba:	02f71263          	bne	a4,a5,800045de <fsinit+0x70>
  initlog(dev, &sb);
    800045be:	0001d597          	auipc	a1,0x1d
    800045c2:	c2a58593          	addi	a1,a1,-982 # 800211e8 <sb>
    800045c6:	854a                	mv	a0,s2
    800045c8:	00001097          	auipc	ra,0x1
    800045cc:	b4c080e7          	jalr	-1204(ra) # 80005114 <initlog>
}
    800045d0:	70a2                	ld	ra,40(sp)
    800045d2:	7402                	ld	s0,32(sp)
    800045d4:	64e2                	ld	s1,24(sp)
    800045d6:	6942                	ld	s2,16(sp)
    800045d8:	69a2                	ld	s3,8(sp)
    800045da:	6145                	addi	sp,sp,48
    800045dc:	8082                	ret
    panic("invalid file system");
    800045de:	00005517          	auipc	a0,0x5
    800045e2:	20250513          	addi	a0,a0,514 # 800097e0 <syscalls+0x1a0>
    800045e6:	ffffc097          	auipc	ra,0xffffc
    800045ea:	f56080e7          	jalr	-170(ra) # 8000053c <panic>

00000000800045ee <iinit>:
{
    800045ee:	7179                	addi	sp,sp,-48
    800045f0:	f406                	sd	ra,40(sp)
    800045f2:	f022                	sd	s0,32(sp)
    800045f4:	ec26                	sd	s1,24(sp)
    800045f6:	e84a                	sd	s2,16(sp)
    800045f8:	e44e                	sd	s3,8(sp)
    800045fa:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800045fc:	00005597          	auipc	a1,0x5
    80004600:	1fc58593          	addi	a1,a1,508 # 800097f8 <syscalls+0x1b8>
    80004604:	0001d517          	auipc	a0,0x1d
    80004608:	c0450513          	addi	a0,a0,-1020 # 80021208 <itable>
    8000460c:	ffffc097          	auipc	ra,0xffffc
    80004610:	546080e7          	jalr	1350(ra) # 80000b52 <initlock>
  for(i = 0; i < NINODE; i++) {
    80004614:	0001d497          	auipc	s1,0x1d
    80004618:	c1c48493          	addi	s1,s1,-996 # 80021230 <itable+0x28>
    8000461c:	0001e997          	auipc	s3,0x1e
    80004620:	6a498993          	addi	s3,s3,1700 # 80022cc0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004624:	00005917          	auipc	s2,0x5
    80004628:	1dc90913          	addi	s2,s2,476 # 80009800 <syscalls+0x1c0>
    8000462c:	85ca                	mv	a1,s2
    8000462e:	8526                	mv	a0,s1
    80004630:	00001097          	auipc	ra,0x1
    80004634:	e46080e7          	jalr	-442(ra) # 80005476 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004638:	08848493          	addi	s1,s1,136
    8000463c:	ff3498e3          	bne	s1,s3,8000462c <iinit+0x3e>
}
    80004640:	70a2                	ld	ra,40(sp)
    80004642:	7402                	ld	s0,32(sp)
    80004644:	64e2                	ld	s1,24(sp)
    80004646:	6942                	ld	s2,16(sp)
    80004648:	69a2                	ld	s3,8(sp)
    8000464a:	6145                	addi	sp,sp,48
    8000464c:	8082                	ret

000000008000464e <ialloc>:
{
    8000464e:	715d                	addi	sp,sp,-80
    80004650:	e486                	sd	ra,72(sp)
    80004652:	e0a2                	sd	s0,64(sp)
    80004654:	fc26                	sd	s1,56(sp)
    80004656:	f84a                	sd	s2,48(sp)
    80004658:	f44e                	sd	s3,40(sp)
    8000465a:	f052                	sd	s4,32(sp)
    8000465c:	ec56                	sd	s5,24(sp)
    8000465e:	e85a                	sd	s6,16(sp)
    80004660:	e45e                	sd	s7,8(sp)
    80004662:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80004664:	0001d717          	auipc	a4,0x1d
    80004668:	b9072703          	lw	a4,-1136(a4) # 800211f4 <sb+0xc>
    8000466c:	4785                	li	a5,1
    8000466e:	04e7fa63          	bgeu	a5,a4,800046c2 <ialloc+0x74>
    80004672:	8aaa                	mv	s5,a0
    80004674:	8bae                	mv	s7,a1
    80004676:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80004678:	0001da17          	auipc	s4,0x1d
    8000467c:	b70a0a13          	addi	s4,s4,-1168 # 800211e8 <sb>
    80004680:	00048b1b          	sext.w	s6,s1
    80004684:	0044d593          	srli	a1,s1,0x4
    80004688:	018a2783          	lw	a5,24(s4)
    8000468c:	9dbd                	addw	a1,a1,a5
    8000468e:	8556                	mv	a0,s5
    80004690:	00000097          	auipc	ra,0x0
    80004694:	954080e7          	jalr	-1708(ra) # 80003fe4 <bread>
    80004698:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000469a:	05850993          	addi	s3,a0,88
    8000469e:	00f4f793          	andi	a5,s1,15
    800046a2:	079a                	slli	a5,a5,0x6
    800046a4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800046a6:	00099783          	lh	a5,0(s3)
    800046aa:	c785                	beqz	a5,800046d2 <ialloc+0x84>
    brelse(bp);
    800046ac:	00000097          	auipc	ra,0x0
    800046b0:	a68080e7          	jalr	-1432(ra) # 80004114 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800046b4:	0485                	addi	s1,s1,1
    800046b6:	00ca2703          	lw	a4,12(s4)
    800046ba:	0004879b          	sext.w	a5,s1
    800046be:	fce7e1e3          	bltu	a5,a4,80004680 <ialloc+0x32>
  panic("ialloc: no inodes");
    800046c2:	00005517          	auipc	a0,0x5
    800046c6:	14650513          	addi	a0,a0,326 # 80009808 <syscalls+0x1c8>
    800046ca:	ffffc097          	auipc	ra,0xffffc
    800046ce:	e72080e7          	jalr	-398(ra) # 8000053c <panic>
      memset(dip, 0, sizeof(*dip));
    800046d2:	04000613          	li	a2,64
    800046d6:	4581                	li	a1,0
    800046d8:	854e                	mv	a0,s3
    800046da:	ffffc097          	auipc	ra,0xffffc
    800046de:	604080e7          	jalr	1540(ra) # 80000cde <memset>
      dip->type = type;
    800046e2:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800046e6:	854a                	mv	a0,s2
    800046e8:	00001097          	auipc	ra,0x1
    800046ec:	ca8080e7          	jalr	-856(ra) # 80005390 <log_write>
      brelse(bp);
    800046f0:	854a                	mv	a0,s2
    800046f2:	00000097          	auipc	ra,0x0
    800046f6:	a22080e7          	jalr	-1502(ra) # 80004114 <brelse>
      return iget(dev, inum);
    800046fa:	85da                	mv	a1,s6
    800046fc:	8556                	mv	a0,s5
    800046fe:	00000097          	auipc	ra,0x0
    80004702:	db4080e7          	jalr	-588(ra) # 800044b2 <iget>
}
    80004706:	60a6                	ld	ra,72(sp)
    80004708:	6406                	ld	s0,64(sp)
    8000470a:	74e2                	ld	s1,56(sp)
    8000470c:	7942                	ld	s2,48(sp)
    8000470e:	79a2                	ld	s3,40(sp)
    80004710:	7a02                	ld	s4,32(sp)
    80004712:	6ae2                	ld	s5,24(sp)
    80004714:	6b42                	ld	s6,16(sp)
    80004716:	6ba2                	ld	s7,8(sp)
    80004718:	6161                	addi	sp,sp,80
    8000471a:	8082                	ret

000000008000471c <iupdate>:
{
    8000471c:	1101                	addi	sp,sp,-32
    8000471e:	ec06                	sd	ra,24(sp)
    80004720:	e822                	sd	s0,16(sp)
    80004722:	e426                	sd	s1,8(sp)
    80004724:	e04a                	sd	s2,0(sp)
    80004726:	1000                	addi	s0,sp,32
    80004728:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000472a:	415c                	lw	a5,4(a0)
    8000472c:	0047d79b          	srliw	a5,a5,0x4
    80004730:	0001d597          	auipc	a1,0x1d
    80004734:	ad05a583          	lw	a1,-1328(a1) # 80021200 <sb+0x18>
    80004738:	9dbd                	addw	a1,a1,a5
    8000473a:	4108                	lw	a0,0(a0)
    8000473c:	00000097          	auipc	ra,0x0
    80004740:	8a8080e7          	jalr	-1880(ra) # 80003fe4 <bread>
    80004744:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004746:	05850793          	addi	a5,a0,88
    8000474a:	40c8                	lw	a0,4(s1)
    8000474c:	893d                	andi	a0,a0,15
    8000474e:	051a                	slli	a0,a0,0x6
    80004750:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80004752:	04449703          	lh	a4,68(s1)
    80004756:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000475a:	04649703          	lh	a4,70(s1)
    8000475e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80004762:	04849703          	lh	a4,72(s1)
    80004766:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000476a:	04a49703          	lh	a4,74(s1)
    8000476e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80004772:	44f8                	lw	a4,76(s1)
    80004774:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004776:	03400613          	li	a2,52
    8000477a:	05048593          	addi	a1,s1,80
    8000477e:	0531                	addi	a0,a0,12
    80004780:	ffffc097          	auipc	ra,0xffffc
    80004784:	5be080e7          	jalr	1470(ra) # 80000d3e <memmove>
  log_write(bp);
    80004788:	854a                	mv	a0,s2
    8000478a:	00001097          	auipc	ra,0x1
    8000478e:	c06080e7          	jalr	-1018(ra) # 80005390 <log_write>
  brelse(bp);
    80004792:	854a                	mv	a0,s2
    80004794:	00000097          	auipc	ra,0x0
    80004798:	980080e7          	jalr	-1664(ra) # 80004114 <brelse>
}
    8000479c:	60e2                	ld	ra,24(sp)
    8000479e:	6442                	ld	s0,16(sp)
    800047a0:	64a2                	ld	s1,8(sp)
    800047a2:	6902                	ld	s2,0(sp)
    800047a4:	6105                	addi	sp,sp,32
    800047a6:	8082                	ret

00000000800047a8 <idup>:
{
    800047a8:	1101                	addi	sp,sp,-32
    800047aa:	ec06                	sd	ra,24(sp)
    800047ac:	e822                	sd	s0,16(sp)
    800047ae:	e426                	sd	s1,8(sp)
    800047b0:	1000                	addi	s0,sp,32
    800047b2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800047b4:	0001d517          	auipc	a0,0x1d
    800047b8:	a5450513          	addi	a0,a0,-1452 # 80021208 <itable>
    800047bc:	ffffc097          	auipc	ra,0xffffc
    800047c0:	426080e7          	jalr	1062(ra) # 80000be2 <acquire>
  ip->ref++;
    800047c4:	449c                	lw	a5,8(s1)
    800047c6:	2785                	addiw	a5,a5,1
    800047c8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800047ca:	0001d517          	auipc	a0,0x1d
    800047ce:	a3e50513          	addi	a0,a0,-1474 # 80021208 <itable>
    800047d2:	ffffc097          	auipc	ra,0xffffc
    800047d6:	4c4080e7          	jalr	1220(ra) # 80000c96 <release>
}
    800047da:	8526                	mv	a0,s1
    800047dc:	60e2                	ld	ra,24(sp)
    800047de:	6442                	ld	s0,16(sp)
    800047e0:	64a2                	ld	s1,8(sp)
    800047e2:	6105                	addi	sp,sp,32
    800047e4:	8082                	ret

00000000800047e6 <ilock>:
{
    800047e6:	1101                	addi	sp,sp,-32
    800047e8:	ec06                	sd	ra,24(sp)
    800047ea:	e822                	sd	s0,16(sp)
    800047ec:	e426                	sd	s1,8(sp)
    800047ee:	e04a                	sd	s2,0(sp)
    800047f0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800047f2:	c115                	beqz	a0,80004816 <ilock+0x30>
    800047f4:	84aa                	mv	s1,a0
    800047f6:	451c                	lw	a5,8(a0)
    800047f8:	00f05f63          	blez	a5,80004816 <ilock+0x30>
  acquiresleep(&ip->lock);
    800047fc:	0541                	addi	a0,a0,16
    800047fe:	00001097          	auipc	ra,0x1
    80004802:	cb2080e7          	jalr	-846(ra) # 800054b0 <acquiresleep>
  if(ip->valid == 0){
    80004806:	40bc                	lw	a5,64(s1)
    80004808:	cf99                	beqz	a5,80004826 <ilock+0x40>
}
    8000480a:	60e2                	ld	ra,24(sp)
    8000480c:	6442                	ld	s0,16(sp)
    8000480e:	64a2                	ld	s1,8(sp)
    80004810:	6902                	ld	s2,0(sp)
    80004812:	6105                	addi	sp,sp,32
    80004814:	8082                	ret
    panic("ilock");
    80004816:	00005517          	auipc	a0,0x5
    8000481a:	00a50513          	addi	a0,a0,10 # 80009820 <syscalls+0x1e0>
    8000481e:	ffffc097          	auipc	ra,0xffffc
    80004822:	d1e080e7          	jalr	-738(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004826:	40dc                	lw	a5,4(s1)
    80004828:	0047d79b          	srliw	a5,a5,0x4
    8000482c:	0001d597          	auipc	a1,0x1d
    80004830:	9d45a583          	lw	a1,-1580(a1) # 80021200 <sb+0x18>
    80004834:	9dbd                	addw	a1,a1,a5
    80004836:	4088                	lw	a0,0(s1)
    80004838:	fffff097          	auipc	ra,0xfffff
    8000483c:	7ac080e7          	jalr	1964(ra) # 80003fe4 <bread>
    80004840:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004842:	05850593          	addi	a1,a0,88
    80004846:	40dc                	lw	a5,4(s1)
    80004848:	8bbd                	andi	a5,a5,15
    8000484a:	079a                	slli	a5,a5,0x6
    8000484c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000484e:	00059783          	lh	a5,0(a1)
    80004852:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004856:	00259783          	lh	a5,2(a1)
    8000485a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000485e:	00459783          	lh	a5,4(a1)
    80004862:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004866:	00659783          	lh	a5,6(a1)
    8000486a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000486e:	459c                	lw	a5,8(a1)
    80004870:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004872:	03400613          	li	a2,52
    80004876:	05b1                	addi	a1,a1,12
    80004878:	05048513          	addi	a0,s1,80
    8000487c:	ffffc097          	auipc	ra,0xffffc
    80004880:	4c2080e7          	jalr	1218(ra) # 80000d3e <memmove>
    brelse(bp);
    80004884:	854a                	mv	a0,s2
    80004886:	00000097          	auipc	ra,0x0
    8000488a:	88e080e7          	jalr	-1906(ra) # 80004114 <brelse>
    ip->valid = 1;
    8000488e:	4785                	li	a5,1
    80004890:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004892:	04449783          	lh	a5,68(s1)
    80004896:	fbb5                	bnez	a5,8000480a <ilock+0x24>
      panic("ilock: no type");
    80004898:	00005517          	auipc	a0,0x5
    8000489c:	f9050513          	addi	a0,a0,-112 # 80009828 <syscalls+0x1e8>
    800048a0:	ffffc097          	auipc	ra,0xffffc
    800048a4:	c9c080e7          	jalr	-868(ra) # 8000053c <panic>

00000000800048a8 <iunlock>:
{
    800048a8:	1101                	addi	sp,sp,-32
    800048aa:	ec06                	sd	ra,24(sp)
    800048ac:	e822                	sd	s0,16(sp)
    800048ae:	e426                	sd	s1,8(sp)
    800048b0:	e04a                	sd	s2,0(sp)
    800048b2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800048b4:	c905                	beqz	a0,800048e4 <iunlock+0x3c>
    800048b6:	84aa                	mv	s1,a0
    800048b8:	01050913          	addi	s2,a0,16
    800048bc:	854a                	mv	a0,s2
    800048be:	00001097          	auipc	ra,0x1
    800048c2:	c8c080e7          	jalr	-884(ra) # 8000554a <holdingsleep>
    800048c6:	cd19                	beqz	a0,800048e4 <iunlock+0x3c>
    800048c8:	449c                	lw	a5,8(s1)
    800048ca:	00f05d63          	blez	a5,800048e4 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800048ce:	854a                	mv	a0,s2
    800048d0:	00001097          	auipc	ra,0x1
    800048d4:	c36080e7          	jalr	-970(ra) # 80005506 <releasesleep>
}
    800048d8:	60e2                	ld	ra,24(sp)
    800048da:	6442                	ld	s0,16(sp)
    800048dc:	64a2                	ld	s1,8(sp)
    800048de:	6902                	ld	s2,0(sp)
    800048e0:	6105                	addi	sp,sp,32
    800048e2:	8082                	ret
    panic("iunlock");
    800048e4:	00005517          	auipc	a0,0x5
    800048e8:	f5450513          	addi	a0,a0,-172 # 80009838 <syscalls+0x1f8>
    800048ec:	ffffc097          	auipc	ra,0xffffc
    800048f0:	c50080e7          	jalr	-944(ra) # 8000053c <panic>

00000000800048f4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800048f4:	7179                	addi	sp,sp,-48
    800048f6:	f406                	sd	ra,40(sp)
    800048f8:	f022                	sd	s0,32(sp)
    800048fa:	ec26                	sd	s1,24(sp)
    800048fc:	e84a                	sd	s2,16(sp)
    800048fe:	e44e                	sd	s3,8(sp)
    80004900:	e052                	sd	s4,0(sp)
    80004902:	1800                	addi	s0,sp,48
    80004904:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004906:	05050493          	addi	s1,a0,80
    8000490a:	08050913          	addi	s2,a0,128
    8000490e:	a021                	j	80004916 <itrunc+0x22>
    80004910:	0491                	addi	s1,s1,4
    80004912:	01248d63          	beq	s1,s2,8000492c <itrunc+0x38>
    if(ip->addrs[i]){
    80004916:	408c                	lw	a1,0(s1)
    80004918:	dde5                	beqz	a1,80004910 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000491a:	0009a503          	lw	a0,0(s3)
    8000491e:	00000097          	auipc	ra,0x0
    80004922:	90c080e7          	jalr	-1780(ra) # 8000422a <bfree>
      ip->addrs[i] = 0;
    80004926:	0004a023          	sw	zero,0(s1)
    8000492a:	b7dd                	j	80004910 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000492c:	0809a583          	lw	a1,128(s3)
    80004930:	e185                	bnez	a1,80004950 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004932:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004936:	854e                	mv	a0,s3
    80004938:	00000097          	auipc	ra,0x0
    8000493c:	de4080e7          	jalr	-540(ra) # 8000471c <iupdate>
}
    80004940:	70a2                	ld	ra,40(sp)
    80004942:	7402                	ld	s0,32(sp)
    80004944:	64e2                	ld	s1,24(sp)
    80004946:	6942                	ld	s2,16(sp)
    80004948:	69a2                	ld	s3,8(sp)
    8000494a:	6a02                	ld	s4,0(sp)
    8000494c:	6145                	addi	sp,sp,48
    8000494e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004950:	0009a503          	lw	a0,0(s3)
    80004954:	fffff097          	auipc	ra,0xfffff
    80004958:	690080e7          	jalr	1680(ra) # 80003fe4 <bread>
    8000495c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000495e:	05850493          	addi	s1,a0,88
    80004962:	45850913          	addi	s2,a0,1112
    80004966:	a811                	j	8000497a <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80004968:	0009a503          	lw	a0,0(s3)
    8000496c:	00000097          	auipc	ra,0x0
    80004970:	8be080e7          	jalr	-1858(ra) # 8000422a <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80004974:	0491                	addi	s1,s1,4
    80004976:	01248563          	beq	s1,s2,80004980 <itrunc+0x8c>
      if(a[j])
    8000497a:	408c                	lw	a1,0(s1)
    8000497c:	dde5                	beqz	a1,80004974 <itrunc+0x80>
    8000497e:	b7ed                	j	80004968 <itrunc+0x74>
    brelse(bp);
    80004980:	8552                	mv	a0,s4
    80004982:	fffff097          	auipc	ra,0xfffff
    80004986:	792080e7          	jalr	1938(ra) # 80004114 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000498a:	0809a583          	lw	a1,128(s3)
    8000498e:	0009a503          	lw	a0,0(s3)
    80004992:	00000097          	auipc	ra,0x0
    80004996:	898080e7          	jalr	-1896(ra) # 8000422a <bfree>
    ip->addrs[NDIRECT] = 0;
    8000499a:	0809a023          	sw	zero,128(s3)
    8000499e:	bf51                	j	80004932 <itrunc+0x3e>

00000000800049a0 <iput>:
{
    800049a0:	1101                	addi	sp,sp,-32
    800049a2:	ec06                	sd	ra,24(sp)
    800049a4:	e822                	sd	s0,16(sp)
    800049a6:	e426                	sd	s1,8(sp)
    800049a8:	e04a                	sd	s2,0(sp)
    800049aa:	1000                	addi	s0,sp,32
    800049ac:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800049ae:	0001d517          	auipc	a0,0x1d
    800049b2:	85a50513          	addi	a0,a0,-1958 # 80021208 <itable>
    800049b6:	ffffc097          	auipc	ra,0xffffc
    800049ba:	22c080e7          	jalr	556(ra) # 80000be2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800049be:	4498                	lw	a4,8(s1)
    800049c0:	4785                	li	a5,1
    800049c2:	02f70363          	beq	a4,a5,800049e8 <iput+0x48>
  ip->ref--;
    800049c6:	449c                	lw	a5,8(s1)
    800049c8:	37fd                	addiw	a5,a5,-1
    800049ca:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800049cc:	0001d517          	auipc	a0,0x1d
    800049d0:	83c50513          	addi	a0,a0,-1988 # 80021208 <itable>
    800049d4:	ffffc097          	auipc	ra,0xffffc
    800049d8:	2c2080e7          	jalr	706(ra) # 80000c96 <release>
}
    800049dc:	60e2                	ld	ra,24(sp)
    800049de:	6442                	ld	s0,16(sp)
    800049e0:	64a2                	ld	s1,8(sp)
    800049e2:	6902                	ld	s2,0(sp)
    800049e4:	6105                	addi	sp,sp,32
    800049e6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800049e8:	40bc                	lw	a5,64(s1)
    800049ea:	dff1                	beqz	a5,800049c6 <iput+0x26>
    800049ec:	04a49783          	lh	a5,74(s1)
    800049f0:	fbf9                	bnez	a5,800049c6 <iput+0x26>
    acquiresleep(&ip->lock);
    800049f2:	01048913          	addi	s2,s1,16
    800049f6:	854a                	mv	a0,s2
    800049f8:	00001097          	auipc	ra,0x1
    800049fc:	ab8080e7          	jalr	-1352(ra) # 800054b0 <acquiresleep>
    release(&itable.lock);
    80004a00:	0001d517          	auipc	a0,0x1d
    80004a04:	80850513          	addi	a0,a0,-2040 # 80021208 <itable>
    80004a08:	ffffc097          	auipc	ra,0xffffc
    80004a0c:	28e080e7          	jalr	654(ra) # 80000c96 <release>
    itrunc(ip);
    80004a10:	8526                	mv	a0,s1
    80004a12:	00000097          	auipc	ra,0x0
    80004a16:	ee2080e7          	jalr	-286(ra) # 800048f4 <itrunc>
    ip->type = 0;
    80004a1a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004a1e:	8526                	mv	a0,s1
    80004a20:	00000097          	auipc	ra,0x0
    80004a24:	cfc080e7          	jalr	-772(ra) # 8000471c <iupdate>
    ip->valid = 0;
    80004a28:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004a2c:	854a                	mv	a0,s2
    80004a2e:	00001097          	auipc	ra,0x1
    80004a32:	ad8080e7          	jalr	-1320(ra) # 80005506 <releasesleep>
    acquire(&itable.lock);
    80004a36:	0001c517          	auipc	a0,0x1c
    80004a3a:	7d250513          	addi	a0,a0,2002 # 80021208 <itable>
    80004a3e:	ffffc097          	auipc	ra,0xffffc
    80004a42:	1a4080e7          	jalr	420(ra) # 80000be2 <acquire>
    80004a46:	b741                	j	800049c6 <iput+0x26>

0000000080004a48 <iunlockput>:
{
    80004a48:	1101                	addi	sp,sp,-32
    80004a4a:	ec06                	sd	ra,24(sp)
    80004a4c:	e822                	sd	s0,16(sp)
    80004a4e:	e426                	sd	s1,8(sp)
    80004a50:	1000                	addi	s0,sp,32
    80004a52:	84aa                	mv	s1,a0
  iunlock(ip);
    80004a54:	00000097          	auipc	ra,0x0
    80004a58:	e54080e7          	jalr	-428(ra) # 800048a8 <iunlock>
  iput(ip);
    80004a5c:	8526                	mv	a0,s1
    80004a5e:	00000097          	auipc	ra,0x0
    80004a62:	f42080e7          	jalr	-190(ra) # 800049a0 <iput>
}
    80004a66:	60e2                	ld	ra,24(sp)
    80004a68:	6442                	ld	s0,16(sp)
    80004a6a:	64a2                	ld	s1,8(sp)
    80004a6c:	6105                	addi	sp,sp,32
    80004a6e:	8082                	ret

0000000080004a70 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004a70:	1141                	addi	sp,sp,-16
    80004a72:	e422                	sd	s0,8(sp)
    80004a74:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004a76:	411c                	lw	a5,0(a0)
    80004a78:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004a7a:	415c                	lw	a5,4(a0)
    80004a7c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004a7e:	04451783          	lh	a5,68(a0)
    80004a82:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004a86:	04a51783          	lh	a5,74(a0)
    80004a8a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004a8e:	04c56783          	lwu	a5,76(a0)
    80004a92:	e99c                	sd	a5,16(a1)
}
    80004a94:	6422                	ld	s0,8(sp)
    80004a96:	0141                	addi	sp,sp,16
    80004a98:	8082                	ret

0000000080004a9a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004a9a:	457c                	lw	a5,76(a0)
    80004a9c:	0ed7e963          	bltu	a5,a3,80004b8e <readi+0xf4>
{
    80004aa0:	7159                	addi	sp,sp,-112
    80004aa2:	f486                	sd	ra,104(sp)
    80004aa4:	f0a2                	sd	s0,96(sp)
    80004aa6:	eca6                	sd	s1,88(sp)
    80004aa8:	e8ca                	sd	s2,80(sp)
    80004aaa:	e4ce                	sd	s3,72(sp)
    80004aac:	e0d2                	sd	s4,64(sp)
    80004aae:	fc56                	sd	s5,56(sp)
    80004ab0:	f85a                	sd	s6,48(sp)
    80004ab2:	f45e                	sd	s7,40(sp)
    80004ab4:	f062                	sd	s8,32(sp)
    80004ab6:	ec66                	sd	s9,24(sp)
    80004ab8:	e86a                	sd	s10,16(sp)
    80004aba:	e46e                	sd	s11,8(sp)
    80004abc:	1880                	addi	s0,sp,112
    80004abe:	8baa                	mv	s7,a0
    80004ac0:	8c2e                	mv	s8,a1
    80004ac2:	8ab2                	mv	s5,a2
    80004ac4:	84b6                	mv	s1,a3
    80004ac6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004ac8:	9f35                	addw	a4,a4,a3
    return 0;
    80004aca:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004acc:	0ad76063          	bltu	a4,a3,80004b6c <readi+0xd2>
  if(off + n > ip->size)
    80004ad0:	00e7f463          	bgeu	a5,a4,80004ad8 <readi+0x3e>
    n = ip->size - off;
    80004ad4:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004ad8:	0a0b0963          	beqz	s6,80004b8a <readi+0xf0>
    80004adc:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004ade:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004ae2:	5cfd                	li	s9,-1
    80004ae4:	a82d                	j	80004b1e <readi+0x84>
    80004ae6:	020a1d93          	slli	s11,s4,0x20
    80004aea:	020ddd93          	srli	s11,s11,0x20
    80004aee:	05890613          	addi	a2,s2,88
    80004af2:	86ee                	mv	a3,s11
    80004af4:	963a                	add	a2,a2,a4
    80004af6:	85d6                	mv	a1,s5
    80004af8:	8562                	mv	a0,s8
    80004afa:	ffffe097          	auipc	ra,0xffffe
    80004afe:	5f0080e7          	jalr	1520(ra) # 800030ea <either_copyout>
    80004b02:	05950d63          	beq	a0,s9,80004b5c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004b06:	854a                	mv	a0,s2
    80004b08:	fffff097          	auipc	ra,0xfffff
    80004b0c:	60c080e7          	jalr	1548(ra) # 80004114 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004b10:	013a09bb          	addw	s3,s4,s3
    80004b14:	009a04bb          	addw	s1,s4,s1
    80004b18:	9aee                	add	s5,s5,s11
    80004b1a:	0569f763          	bgeu	s3,s6,80004b68 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004b1e:	000ba903          	lw	s2,0(s7)
    80004b22:	00a4d59b          	srliw	a1,s1,0xa
    80004b26:	855e                	mv	a0,s7
    80004b28:	00000097          	auipc	ra,0x0
    80004b2c:	8b0080e7          	jalr	-1872(ra) # 800043d8 <bmap>
    80004b30:	0005059b          	sext.w	a1,a0
    80004b34:	854a                	mv	a0,s2
    80004b36:	fffff097          	auipc	ra,0xfffff
    80004b3a:	4ae080e7          	jalr	1198(ra) # 80003fe4 <bread>
    80004b3e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004b40:	3ff4f713          	andi	a4,s1,1023
    80004b44:	40ed07bb          	subw	a5,s10,a4
    80004b48:	413b06bb          	subw	a3,s6,s3
    80004b4c:	8a3e                	mv	s4,a5
    80004b4e:	2781                	sext.w	a5,a5
    80004b50:	0006861b          	sext.w	a2,a3
    80004b54:	f8f679e3          	bgeu	a2,a5,80004ae6 <readi+0x4c>
    80004b58:	8a36                	mv	s4,a3
    80004b5a:	b771                	j	80004ae6 <readi+0x4c>
      brelse(bp);
    80004b5c:	854a                	mv	a0,s2
    80004b5e:	fffff097          	auipc	ra,0xfffff
    80004b62:	5b6080e7          	jalr	1462(ra) # 80004114 <brelse>
      tot = -1;
    80004b66:	59fd                	li	s3,-1
  }
  return tot;
    80004b68:	0009851b          	sext.w	a0,s3
}
    80004b6c:	70a6                	ld	ra,104(sp)
    80004b6e:	7406                	ld	s0,96(sp)
    80004b70:	64e6                	ld	s1,88(sp)
    80004b72:	6946                	ld	s2,80(sp)
    80004b74:	69a6                	ld	s3,72(sp)
    80004b76:	6a06                	ld	s4,64(sp)
    80004b78:	7ae2                	ld	s5,56(sp)
    80004b7a:	7b42                	ld	s6,48(sp)
    80004b7c:	7ba2                	ld	s7,40(sp)
    80004b7e:	7c02                	ld	s8,32(sp)
    80004b80:	6ce2                	ld	s9,24(sp)
    80004b82:	6d42                	ld	s10,16(sp)
    80004b84:	6da2                	ld	s11,8(sp)
    80004b86:	6165                	addi	sp,sp,112
    80004b88:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004b8a:	89da                	mv	s3,s6
    80004b8c:	bff1                	j	80004b68 <readi+0xce>
    return 0;
    80004b8e:	4501                	li	a0,0
}
    80004b90:	8082                	ret

0000000080004b92 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004b92:	457c                	lw	a5,76(a0)
    80004b94:	10d7e863          	bltu	a5,a3,80004ca4 <writei+0x112>
{
    80004b98:	7159                	addi	sp,sp,-112
    80004b9a:	f486                	sd	ra,104(sp)
    80004b9c:	f0a2                	sd	s0,96(sp)
    80004b9e:	eca6                	sd	s1,88(sp)
    80004ba0:	e8ca                	sd	s2,80(sp)
    80004ba2:	e4ce                	sd	s3,72(sp)
    80004ba4:	e0d2                	sd	s4,64(sp)
    80004ba6:	fc56                	sd	s5,56(sp)
    80004ba8:	f85a                	sd	s6,48(sp)
    80004baa:	f45e                	sd	s7,40(sp)
    80004bac:	f062                	sd	s8,32(sp)
    80004bae:	ec66                	sd	s9,24(sp)
    80004bb0:	e86a                	sd	s10,16(sp)
    80004bb2:	e46e                	sd	s11,8(sp)
    80004bb4:	1880                	addi	s0,sp,112
    80004bb6:	8b2a                	mv	s6,a0
    80004bb8:	8c2e                	mv	s8,a1
    80004bba:	8ab2                	mv	s5,a2
    80004bbc:	8936                	mv	s2,a3
    80004bbe:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004bc0:	00e687bb          	addw	a5,a3,a4
    80004bc4:	0ed7e263          	bltu	a5,a3,80004ca8 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004bc8:	00043737          	lui	a4,0x43
    80004bcc:	0ef76063          	bltu	a4,a5,80004cac <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004bd0:	0c0b8863          	beqz	s7,80004ca0 <writei+0x10e>
    80004bd4:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004bd6:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004bda:	5cfd                	li	s9,-1
    80004bdc:	a091                	j	80004c20 <writei+0x8e>
    80004bde:	02099d93          	slli	s11,s3,0x20
    80004be2:	020ddd93          	srli	s11,s11,0x20
    80004be6:	05848513          	addi	a0,s1,88
    80004bea:	86ee                	mv	a3,s11
    80004bec:	8656                	mv	a2,s5
    80004bee:	85e2                	mv	a1,s8
    80004bf0:	953a                	add	a0,a0,a4
    80004bf2:	ffffe097          	auipc	ra,0xffffe
    80004bf6:	54e080e7          	jalr	1358(ra) # 80003140 <either_copyin>
    80004bfa:	07950263          	beq	a0,s9,80004c5e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004bfe:	8526                	mv	a0,s1
    80004c00:	00000097          	auipc	ra,0x0
    80004c04:	790080e7          	jalr	1936(ra) # 80005390 <log_write>
    brelse(bp);
    80004c08:	8526                	mv	a0,s1
    80004c0a:	fffff097          	auipc	ra,0xfffff
    80004c0e:	50a080e7          	jalr	1290(ra) # 80004114 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004c12:	01498a3b          	addw	s4,s3,s4
    80004c16:	0129893b          	addw	s2,s3,s2
    80004c1a:	9aee                	add	s5,s5,s11
    80004c1c:	057a7663          	bgeu	s4,s7,80004c68 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004c20:	000b2483          	lw	s1,0(s6)
    80004c24:	00a9559b          	srliw	a1,s2,0xa
    80004c28:	855a                	mv	a0,s6
    80004c2a:	fffff097          	auipc	ra,0xfffff
    80004c2e:	7ae080e7          	jalr	1966(ra) # 800043d8 <bmap>
    80004c32:	0005059b          	sext.w	a1,a0
    80004c36:	8526                	mv	a0,s1
    80004c38:	fffff097          	auipc	ra,0xfffff
    80004c3c:	3ac080e7          	jalr	940(ra) # 80003fe4 <bread>
    80004c40:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004c42:	3ff97713          	andi	a4,s2,1023
    80004c46:	40ed07bb          	subw	a5,s10,a4
    80004c4a:	414b86bb          	subw	a3,s7,s4
    80004c4e:	89be                	mv	s3,a5
    80004c50:	2781                	sext.w	a5,a5
    80004c52:	0006861b          	sext.w	a2,a3
    80004c56:	f8f674e3          	bgeu	a2,a5,80004bde <writei+0x4c>
    80004c5a:	89b6                	mv	s3,a3
    80004c5c:	b749                	j	80004bde <writei+0x4c>
      brelse(bp);
    80004c5e:	8526                	mv	a0,s1
    80004c60:	fffff097          	auipc	ra,0xfffff
    80004c64:	4b4080e7          	jalr	1204(ra) # 80004114 <brelse>
  }

  if(off > ip->size)
    80004c68:	04cb2783          	lw	a5,76(s6)
    80004c6c:	0127f463          	bgeu	a5,s2,80004c74 <writei+0xe2>
    ip->size = off;
    80004c70:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004c74:	855a                	mv	a0,s6
    80004c76:	00000097          	auipc	ra,0x0
    80004c7a:	aa6080e7          	jalr	-1370(ra) # 8000471c <iupdate>

  return tot;
    80004c7e:	000a051b          	sext.w	a0,s4
}
    80004c82:	70a6                	ld	ra,104(sp)
    80004c84:	7406                	ld	s0,96(sp)
    80004c86:	64e6                	ld	s1,88(sp)
    80004c88:	6946                	ld	s2,80(sp)
    80004c8a:	69a6                	ld	s3,72(sp)
    80004c8c:	6a06                	ld	s4,64(sp)
    80004c8e:	7ae2                	ld	s5,56(sp)
    80004c90:	7b42                	ld	s6,48(sp)
    80004c92:	7ba2                	ld	s7,40(sp)
    80004c94:	7c02                	ld	s8,32(sp)
    80004c96:	6ce2                	ld	s9,24(sp)
    80004c98:	6d42                	ld	s10,16(sp)
    80004c9a:	6da2                	ld	s11,8(sp)
    80004c9c:	6165                	addi	sp,sp,112
    80004c9e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004ca0:	8a5e                	mv	s4,s7
    80004ca2:	bfc9                	j	80004c74 <writei+0xe2>
    return -1;
    80004ca4:	557d                	li	a0,-1
}
    80004ca6:	8082                	ret
    return -1;
    80004ca8:	557d                	li	a0,-1
    80004caa:	bfe1                	j	80004c82 <writei+0xf0>
    return -1;
    80004cac:	557d                	li	a0,-1
    80004cae:	bfd1                	j	80004c82 <writei+0xf0>

0000000080004cb0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004cb0:	1141                	addi	sp,sp,-16
    80004cb2:	e406                	sd	ra,8(sp)
    80004cb4:	e022                	sd	s0,0(sp)
    80004cb6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004cb8:	4639                	li	a2,14
    80004cba:	ffffc097          	auipc	ra,0xffffc
    80004cbe:	0fc080e7          	jalr	252(ra) # 80000db6 <strncmp>
}
    80004cc2:	60a2                	ld	ra,8(sp)
    80004cc4:	6402                	ld	s0,0(sp)
    80004cc6:	0141                	addi	sp,sp,16
    80004cc8:	8082                	ret

0000000080004cca <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004cca:	7139                	addi	sp,sp,-64
    80004ccc:	fc06                	sd	ra,56(sp)
    80004cce:	f822                	sd	s0,48(sp)
    80004cd0:	f426                	sd	s1,40(sp)
    80004cd2:	f04a                	sd	s2,32(sp)
    80004cd4:	ec4e                	sd	s3,24(sp)
    80004cd6:	e852                	sd	s4,16(sp)
    80004cd8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004cda:	04451703          	lh	a4,68(a0)
    80004cde:	4785                	li	a5,1
    80004ce0:	00f71a63          	bne	a4,a5,80004cf4 <dirlookup+0x2a>
    80004ce4:	892a                	mv	s2,a0
    80004ce6:	89ae                	mv	s3,a1
    80004ce8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004cea:	457c                	lw	a5,76(a0)
    80004cec:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004cee:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004cf0:	e79d                	bnez	a5,80004d1e <dirlookup+0x54>
    80004cf2:	a8a5                	j	80004d6a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004cf4:	00005517          	auipc	a0,0x5
    80004cf8:	b4c50513          	addi	a0,a0,-1204 # 80009840 <syscalls+0x200>
    80004cfc:	ffffc097          	auipc	ra,0xffffc
    80004d00:	840080e7          	jalr	-1984(ra) # 8000053c <panic>
      panic("dirlookup read");
    80004d04:	00005517          	auipc	a0,0x5
    80004d08:	b5450513          	addi	a0,a0,-1196 # 80009858 <syscalls+0x218>
    80004d0c:	ffffc097          	auipc	ra,0xffffc
    80004d10:	830080e7          	jalr	-2000(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d14:	24c1                	addiw	s1,s1,16
    80004d16:	04c92783          	lw	a5,76(s2)
    80004d1a:	04f4f763          	bgeu	s1,a5,80004d68 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d1e:	4741                	li	a4,16
    80004d20:	86a6                	mv	a3,s1
    80004d22:	fc040613          	addi	a2,s0,-64
    80004d26:	4581                	li	a1,0
    80004d28:	854a                	mv	a0,s2
    80004d2a:	00000097          	auipc	ra,0x0
    80004d2e:	d70080e7          	jalr	-656(ra) # 80004a9a <readi>
    80004d32:	47c1                	li	a5,16
    80004d34:	fcf518e3          	bne	a0,a5,80004d04 <dirlookup+0x3a>
    if(de.inum == 0)
    80004d38:	fc045783          	lhu	a5,-64(s0)
    80004d3c:	dfe1                	beqz	a5,80004d14 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004d3e:	fc240593          	addi	a1,s0,-62
    80004d42:	854e                	mv	a0,s3
    80004d44:	00000097          	auipc	ra,0x0
    80004d48:	f6c080e7          	jalr	-148(ra) # 80004cb0 <namecmp>
    80004d4c:	f561                	bnez	a0,80004d14 <dirlookup+0x4a>
      if(poff)
    80004d4e:	000a0463          	beqz	s4,80004d56 <dirlookup+0x8c>
        *poff = off;
    80004d52:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004d56:	fc045583          	lhu	a1,-64(s0)
    80004d5a:	00092503          	lw	a0,0(s2)
    80004d5e:	fffff097          	auipc	ra,0xfffff
    80004d62:	754080e7          	jalr	1876(ra) # 800044b2 <iget>
    80004d66:	a011                	j	80004d6a <dirlookup+0xa0>
  return 0;
    80004d68:	4501                	li	a0,0
}
    80004d6a:	70e2                	ld	ra,56(sp)
    80004d6c:	7442                	ld	s0,48(sp)
    80004d6e:	74a2                	ld	s1,40(sp)
    80004d70:	7902                	ld	s2,32(sp)
    80004d72:	69e2                	ld	s3,24(sp)
    80004d74:	6a42                	ld	s4,16(sp)
    80004d76:	6121                	addi	sp,sp,64
    80004d78:	8082                	ret

0000000080004d7a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004d7a:	711d                	addi	sp,sp,-96
    80004d7c:	ec86                	sd	ra,88(sp)
    80004d7e:	e8a2                	sd	s0,80(sp)
    80004d80:	e4a6                	sd	s1,72(sp)
    80004d82:	e0ca                	sd	s2,64(sp)
    80004d84:	fc4e                	sd	s3,56(sp)
    80004d86:	f852                	sd	s4,48(sp)
    80004d88:	f456                	sd	s5,40(sp)
    80004d8a:	f05a                	sd	s6,32(sp)
    80004d8c:	ec5e                	sd	s7,24(sp)
    80004d8e:	e862                	sd	s8,16(sp)
    80004d90:	e466                	sd	s9,8(sp)
    80004d92:	1080                	addi	s0,sp,96
    80004d94:	84aa                	mv	s1,a0
    80004d96:	8b2e                	mv	s6,a1
    80004d98:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004d9a:	00054703          	lbu	a4,0(a0)
    80004d9e:	02f00793          	li	a5,47
    80004da2:	02f70363          	beq	a4,a5,80004dc8 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004da6:	ffffd097          	auipc	ra,0xffffd
    80004daa:	c08080e7          	jalr	-1016(ra) # 800019ae <myproc>
    80004dae:	15053503          	ld	a0,336(a0)
    80004db2:	00000097          	auipc	ra,0x0
    80004db6:	9f6080e7          	jalr	-1546(ra) # 800047a8 <idup>
    80004dba:	89aa                	mv	s3,a0
  while(*path == '/')
    80004dbc:	02f00913          	li	s2,47
  len = path - s;
    80004dc0:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004dc2:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004dc4:	4c05                	li	s8,1
    80004dc6:	a865                	j	80004e7e <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004dc8:	4585                	li	a1,1
    80004dca:	4505                	li	a0,1
    80004dcc:	fffff097          	auipc	ra,0xfffff
    80004dd0:	6e6080e7          	jalr	1766(ra) # 800044b2 <iget>
    80004dd4:	89aa                	mv	s3,a0
    80004dd6:	b7dd                	j	80004dbc <namex+0x42>
      iunlockput(ip);
    80004dd8:	854e                	mv	a0,s3
    80004dda:	00000097          	auipc	ra,0x0
    80004dde:	c6e080e7          	jalr	-914(ra) # 80004a48 <iunlockput>
      return 0;
    80004de2:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004de4:	854e                	mv	a0,s3
    80004de6:	60e6                	ld	ra,88(sp)
    80004de8:	6446                	ld	s0,80(sp)
    80004dea:	64a6                	ld	s1,72(sp)
    80004dec:	6906                	ld	s2,64(sp)
    80004dee:	79e2                	ld	s3,56(sp)
    80004df0:	7a42                	ld	s4,48(sp)
    80004df2:	7aa2                	ld	s5,40(sp)
    80004df4:	7b02                	ld	s6,32(sp)
    80004df6:	6be2                	ld	s7,24(sp)
    80004df8:	6c42                	ld	s8,16(sp)
    80004dfa:	6ca2                	ld	s9,8(sp)
    80004dfc:	6125                	addi	sp,sp,96
    80004dfe:	8082                	ret
      iunlock(ip);
    80004e00:	854e                	mv	a0,s3
    80004e02:	00000097          	auipc	ra,0x0
    80004e06:	aa6080e7          	jalr	-1370(ra) # 800048a8 <iunlock>
      return ip;
    80004e0a:	bfe9                	j	80004de4 <namex+0x6a>
      iunlockput(ip);
    80004e0c:	854e                	mv	a0,s3
    80004e0e:	00000097          	auipc	ra,0x0
    80004e12:	c3a080e7          	jalr	-966(ra) # 80004a48 <iunlockput>
      return 0;
    80004e16:	89d2                	mv	s3,s4
    80004e18:	b7f1                	j	80004de4 <namex+0x6a>
  len = path - s;
    80004e1a:	40b48633          	sub	a2,s1,a1
    80004e1e:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004e22:	094cd463          	bge	s9,s4,80004eaa <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004e26:	4639                	li	a2,14
    80004e28:	8556                	mv	a0,s5
    80004e2a:	ffffc097          	auipc	ra,0xffffc
    80004e2e:	f14080e7          	jalr	-236(ra) # 80000d3e <memmove>
  while(*path == '/')
    80004e32:	0004c783          	lbu	a5,0(s1)
    80004e36:	01279763          	bne	a5,s2,80004e44 <namex+0xca>
    path++;
    80004e3a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004e3c:	0004c783          	lbu	a5,0(s1)
    80004e40:	ff278de3          	beq	a5,s2,80004e3a <namex+0xc0>
    ilock(ip);
    80004e44:	854e                	mv	a0,s3
    80004e46:	00000097          	auipc	ra,0x0
    80004e4a:	9a0080e7          	jalr	-1632(ra) # 800047e6 <ilock>
    if(ip->type != T_DIR){
    80004e4e:	04499783          	lh	a5,68(s3)
    80004e52:	f98793e3          	bne	a5,s8,80004dd8 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004e56:	000b0563          	beqz	s6,80004e60 <namex+0xe6>
    80004e5a:	0004c783          	lbu	a5,0(s1)
    80004e5e:	d3cd                	beqz	a5,80004e00 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004e60:	865e                	mv	a2,s7
    80004e62:	85d6                	mv	a1,s5
    80004e64:	854e                	mv	a0,s3
    80004e66:	00000097          	auipc	ra,0x0
    80004e6a:	e64080e7          	jalr	-412(ra) # 80004cca <dirlookup>
    80004e6e:	8a2a                	mv	s4,a0
    80004e70:	dd51                	beqz	a0,80004e0c <namex+0x92>
    iunlockput(ip);
    80004e72:	854e                	mv	a0,s3
    80004e74:	00000097          	auipc	ra,0x0
    80004e78:	bd4080e7          	jalr	-1068(ra) # 80004a48 <iunlockput>
    ip = next;
    80004e7c:	89d2                	mv	s3,s4
  while(*path == '/')
    80004e7e:	0004c783          	lbu	a5,0(s1)
    80004e82:	05279763          	bne	a5,s2,80004ed0 <namex+0x156>
    path++;
    80004e86:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004e88:	0004c783          	lbu	a5,0(s1)
    80004e8c:	ff278de3          	beq	a5,s2,80004e86 <namex+0x10c>
  if(*path == 0)
    80004e90:	c79d                	beqz	a5,80004ebe <namex+0x144>
    path++;
    80004e92:	85a6                	mv	a1,s1
  len = path - s;
    80004e94:	8a5e                	mv	s4,s7
    80004e96:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004e98:	01278963          	beq	a5,s2,80004eaa <namex+0x130>
    80004e9c:	dfbd                	beqz	a5,80004e1a <namex+0xa0>
    path++;
    80004e9e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004ea0:	0004c783          	lbu	a5,0(s1)
    80004ea4:	ff279ce3          	bne	a5,s2,80004e9c <namex+0x122>
    80004ea8:	bf8d                	j	80004e1a <namex+0xa0>
    memmove(name, s, len);
    80004eaa:	2601                	sext.w	a2,a2
    80004eac:	8556                	mv	a0,s5
    80004eae:	ffffc097          	auipc	ra,0xffffc
    80004eb2:	e90080e7          	jalr	-368(ra) # 80000d3e <memmove>
    name[len] = 0;
    80004eb6:	9a56                	add	s4,s4,s5
    80004eb8:	000a0023          	sb	zero,0(s4)
    80004ebc:	bf9d                	j	80004e32 <namex+0xb8>
  if(nameiparent){
    80004ebe:	f20b03e3          	beqz	s6,80004de4 <namex+0x6a>
    iput(ip);
    80004ec2:	854e                	mv	a0,s3
    80004ec4:	00000097          	auipc	ra,0x0
    80004ec8:	adc080e7          	jalr	-1316(ra) # 800049a0 <iput>
    return 0;
    80004ecc:	4981                	li	s3,0
    80004ece:	bf19                	j	80004de4 <namex+0x6a>
  if(*path == 0)
    80004ed0:	d7fd                	beqz	a5,80004ebe <namex+0x144>
  while(*path != '/' && *path != 0)
    80004ed2:	0004c783          	lbu	a5,0(s1)
    80004ed6:	85a6                	mv	a1,s1
    80004ed8:	b7d1                	j	80004e9c <namex+0x122>

0000000080004eda <dirlink>:
{
    80004eda:	7139                	addi	sp,sp,-64
    80004edc:	fc06                	sd	ra,56(sp)
    80004ede:	f822                	sd	s0,48(sp)
    80004ee0:	f426                	sd	s1,40(sp)
    80004ee2:	f04a                	sd	s2,32(sp)
    80004ee4:	ec4e                	sd	s3,24(sp)
    80004ee6:	e852                	sd	s4,16(sp)
    80004ee8:	0080                	addi	s0,sp,64
    80004eea:	892a                	mv	s2,a0
    80004eec:	8a2e                	mv	s4,a1
    80004eee:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004ef0:	4601                	li	a2,0
    80004ef2:	00000097          	auipc	ra,0x0
    80004ef6:	dd8080e7          	jalr	-552(ra) # 80004cca <dirlookup>
    80004efa:	e93d                	bnez	a0,80004f70 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004efc:	04c92483          	lw	s1,76(s2)
    80004f00:	c49d                	beqz	s1,80004f2e <dirlink+0x54>
    80004f02:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f04:	4741                	li	a4,16
    80004f06:	86a6                	mv	a3,s1
    80004f08:	fc040613          	addi	a2,s0,-64
    80004f0c:	4581                	li	a1,0
    80004f0e:	854a                	mv	a0,s2
    80004f10:	00000097          	auipc	ra,0x0
    80004f14:	b8a080e7          	jalr	-1142(ra) # 80004a9a <readi>
    80004f18:	47c1                	li	a5,16
    80004f1a:	06f51163          	bne	a0,a5,80004f7c <dirlink+0xa2>
    if(de.inum == 0)
    80004f1e:	fc045783          	lhu	a5,-64(s0)
    80004f22:	c791                	beqz	a5,80004f2e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004f24:	24c1                	addiw	s1,s1,16
    80004f26:	04c92783          	lw	a5,76(s2)
    80004f2a:	fcf4ede3          	bltu	s1,a5,80004f04 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004f2e:	4639                	li	a2,14
    80004f30:	85d2                	mv	a1,s4
    80004f32:	fc240513          	addi	a0,s0,-62
    80004f36:	ffffc097          	auipc	ra,0xffffc
    80004f3a:	ebc080e7          	jalr	-324(ra) # 80000df2 <strncpy>
  de.inum = inum;
    80004f3e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f42:	4741                	li	a4,16
    80004f44:	86a6                	mv	a3,s1
    80004f46:	fc040613          	addi	a2,s0,-64
    80004f4a:	4581                	li	a1,0
    80004f4c:	854a                	mv	a0,s2
    80004f4e:	00000097          	auipc	ra,0x0
    80004f52:	c44080e7          	jalr	-956(ra) # 80004b92 <writei>
    80004f56:	872a                	mv	a4,a0
    80004f58:	47c1                	li	a5,16
  return 0;
    80004f5a:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f5c:	02f71863          	bne	a4,a5,80004f8c <dirlink+0xb2>
}
    80004f60:	70e2                	ld	ra,56(sp)
    80004f62:	7442                	ld	s0,48(sp)
    80004f64:	74a2                	ld	s1,40(sp)
    80004f66:	7902                	ld	s2,32(sp)
    80004f68:	69e2                	ld	s3,24(sp)
    80004f6a:	6a42                	ld	s4,16(sp)
    80004f6c:	6121                	addi	sp,sp,64
    80004f6e:	8082                	ret
    iput(ip);
    80004f70:	00000097          	auipc	ra,0x0
    80004f74:	a30080e7          	jalr	-1488(ra) # 800049a0 <iput>
    return -1;
    80004f78:	557d                	li	a0,-1
    80004f7a:	b7dd                	j	80004f60 <dirlink+0x86>
      panic("dirlink read");
    80004f7c:	00005517          	auipc	a0,0x5
    80004f80:	8ec50513          	addi	a0,a0,-1812 # 80009868 <syscalls+0x228>
    80004f84:	ffffb097          	auipc	ra,0xffffb
    80004f88:	5b8080e7          	jalr	1464(ra) # 8000053c <panic>
    panic("dirlink");
    80004f8c:	00005517          	auipc	a0,0x5
    80004f90:	9ec50513          	addi	a0,a0,-1556 # 80009978 <syscalls+0x338>
    80004f94:	ffffb097          	auipc	ra,0xffffb
    80004f98:	5a8080e7          	jalr	1448(ra) # 8000053c <panic>

0000000080004f9c <namei>:

struct inode*
namei(char *path)
{
    80004f9c:	1101                	addi	sp,sp,-32
    80004f9e:	ec06                	sd	ra,24(sp)
    80004fa0:	e822                	sd	s0,16(sp)
    80004fa2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004fa4:	fe040613          	addi	a2,s0,-32
    80004fa8:	4581                	li	a1,0
    80004faa:	00000097          	auipc	ra,0x0
    80004fae:	dd0080e7          	jalr	-560(ra) # 80004d7a <namex>
}
    80004fb2:	60e2                	ld	ra,24(sp)
    80004fb4:	6442                	ld	s0,16(sp)
    80004fb6:	6105                	addi	sp,sp,32
    80004fb8:	8082                	ret

0000000080004fba <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004fba:	1141                	addi	sp,sp,-16
    80004fbc:	e406                	sd	ra,8(sp)
    80004fbe:	e022                	sd	s0,0(sp)
    80004fc0:	0800                	addi	s0,sp,16
    80004fc2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004fc4:	4585                	li	a1,1
    80004fc6:	00000097          	auipc	ra,0x0
    80004fca:	db4080e7          	jalr	-588(ra) # 80004d7a <namex>
}
    80004fce:	60a2                	ld	ra,8(sp)
    80004fd0:	6402                	ld	s0,0(sp)
    80004fd2:	0141                	addi	sp,sp,16
    80004fd4:	8082                	ret

0000000080004fd6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004fd6:	1101                	addi	sp,sp,-32
    80004fd8:	ec06                	sd	ra,24(sp)
    80004fda:	e822                	sd	s0,16(sp)
    80004fdc:	e426                	sd	s1,8(sp)
    80004fde:	e04a                	sd	s2,0(sp)
    80004fe0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004fe2:	0001e917          	auipc	s2,0x1e
    80004fe6:	cce90913          	addi	s2,s2,-818 # 80022cb0 <log>
    80004fea:	01892583          	lw	a1,24(s2)
    80004fee:	02892503          	lw	a0,40(s2)
    80004ff2:	fffff097          	auipc	ra,0xfffff
    80004ff6:	ff2080e7          	jalr	-14(ra) # 80003fe4 <bread>
    80004ffa:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004ffc:	02c92683          	lw	a3,44(s2)
    80005000:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80005002:	02d05763          	blez	a3,80005030 <write_head+0x5a>
    80005006:	0001e797          	auipc	a5,0x1e
    8000500a:	cda78793          	addi	a5,a5,-806 # 80022ce0 <log+0x30>
    8000500e:	05c50713          	addi	a4,a0,92
    80005012:	36fd                	addiw	a3,a3,-1
    80005014:	1682                	slli	a3,a3,0x20
    80005016:	9281                	srli	a3,a3,0x20
    80005018:	068a                	slli	a3,a3,0x2
    8000501a:	0001e617          	auipc	a2,0x1e
    8000501e:	cca60613          	addi	a2,a2,-822 # 80022ce4 <log+0x34>
    80005022:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80005024:	4390                	lw	a2,0(a5)
    80005026:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005028:	0791                	addi	a5,a5,4
    8000502a:	0711                	addi	a4,a4,4
    8000502c:	fed79ce3          	bne	a5,a3,80005024 <write_head+0x4e>
  }
  bwrite(buf);
    80005030:	8526                	mv	a0,s1
    80005032:	fffff097          	auipc	ra,0xfffff
    80005036:	0a4080e7          	jalr	164(ra) # 800040d6 <bwrite>
  brelse(buf);
    8000503a:	8526                	mv	a0,s1
    8000503c:	fffff097          	auipc	ra,0xfffff
    80005040:	0d8080e7          	jalr	216(ra) # 80004114 <brelse>
}
    80005044:	60e2                	ld	ra,24(sp)
    80005046:	6442                	ld	s0,16(sp)
    80005048:	64a2                	ld	s1,8(sp)
    8000504a:	6902                	ld	s2,0(sp)
    8000504c:	6105                	addi	sp,sp,32
    8000504e:	8082                	ret

0000000080005050 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80005050:	0001e797          	auipc	a5,0x1e
    80005054:	c8c7a783          	lw	a5,-884(a5) # 80022cdc <log+0x2c>
    80005058:	0af05d63          	blez	a5,80005112 <install_trans+0xc2>
{
    8000505c:	7139                	addi	sp,sp,-64
    8000505e:	fc06                	sd	ra,56(sp)
    80005060:	f822                	sd	s0,48(sp)
    80005062:	f426                	sd	s1,40(sp)
    80005064:	f04a                	sd	s2,32(sp)
    80005066:	ec4e                	sd	s3,24(sp)
    80005068:	e852                	sd	s4,16(sp)
    8000506a:	e456                	sd	s5,8(sp)
    8000506c:	e05a                	sd	s6,0(sp)
    8000506e:	0080                	addi	s0,sp,64
    80005070:	8b2a                	mv	s6,a0
    80005072:	0001ea97          	auipc	s5,0x1e
    80005076:	c6ea8a93          	addi	s5,s5,-914 # 80022ce0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000507a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000507c:	0001e997          	auipc	s3,0x1e
    80005080:	c3498993          	addi	s3,s3,-972 # 80022cb0 <log>
    80005084:	a035                	j	800050b0 <install_trans+0x60>
      bunpin(dbuf);
    80005086:	8526                	mv	a0,s1
    80005088:	fffff097          	auipc	ra,0xfffff
    8000508c:	166080e7          	jalr	358(ra) # 800041ee <bunpin>
    brelse(lbuf);
    80005090:	854a                	mv	a0,s2
    80005092:	fffff097          	auipc	ra,0xfffff
    80005096:	082080e7          	jalr	130(ra) # 80004114 <brelse>
    brelse(dbuf);
    8000509a:	8526                	mv	a0,s1
    8000509c:	fffff097          	auipc	ra,0xfffff
    800050a0:	078080e7          	jalr	120(ra) # 80004114 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800050a4:	2a05                	addiw	s4,s4,1
    800050a6:	0a91                	addi	s5,s5,4
    800050a8:	02c9a783          	lw	a5,44(s3)
    800050ac:	04fa5963          	bge	s4,a5,800050fe <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800050b0:	0189a583          	lw	a1,24(s3)
    800050b4:	014585bb          	addw	a1,a1,s4
    800050b8:	2585                	addiw	a1,a1,1
    800050ba:	0289a503          	lw	a0,40(s3)
    800050be:	fffff097          	auipc	ra,0xfffff
    800050c2:	f26080e7          	jalr	-218(ra) # 80003fe4 <bread>
    800050c6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800050c8:	000aa583          	lw	a1,0(s5)
    800050cc:	0289a503          	lw	a0,40(s3)
    800050d0:	fffff097          	auipc	ra,0xfffff
    800050d4:	f14080e7          	jalr	-236(ra) # 80003fe4 <bread>
    800050d8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800050da:	40000613          	li	a2,1024
    800050de:	05890593          	addi	a1,s2,88
    800050e2:	05850513          	addi	a0,a0,88
    800050e6:	ffffc097          	auipc	ra,0xffffc
    800050ea:	c58080e7          	jalr	-936(ra) # 80000d3e <memmove>
    bwrite(dbuf);  // write dst to disk
    800050ee:	8526                	mv	a0,s1
    800050f0:	fffff097          	auipc	ra,0xfffff
    800050f4:	fe6080e7          	jalr	-26(ra) # 800040d6 <bwrite>
    if(recovering == 0)
    800050f8:	f80b1ce3          	bnez	s6,80005090 <install_trans+0x40>
    800050fc:	b769                	j	80005086 <install_trans+0x36>
}
    800050fe:	70e2                	ld	ra,56(sp)
    80005100:	7442                	ld	s0,48(sp)
    80005102:	74a2                	ld	s1,40(sp)
    80005104:	7902                	ld	s2,32(sp)
    80005106:	69e2                	ld	s3,24(sp)
    80005108:	6a42                	ld	s4,16(sp)
    8000510a:	6aa2                	ld	s5,8(sp)
    8000510c:	6b02                	ld	s6,0(sp)
    8000510e:	6121                	addi	sp,sp,64
    80005110:	8082                	ret
    80005112:	8082                	ret

0000000080005114 <initlog>:
{
    80005114:	7179                	addi	sp,sp,-48
    80005116:	f406                	sd	ra,40(sp)
    80005118:	f022                	sd	s0,32(sp)
    8000511a:	ec26                	sd	s1,24(sp)
    8000511c:	e84a                	sd	s2,16(sp)
    8000511e:	e44e                	sd	s3,8(sp)
    80005120:	1800                	addi	s0,sp,48
    80005122:	892a                	mv	s2,a0
    80005124:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80005126:	0001e497          	auipc	s1,0x1e
    8000512a:	b8a48493          	addi	s1,s1,-1142 # 80022cb0 <log>
    8000512e:	00004597          	auipc	a1,0x4
    80005132:	74a58593          	addi	a1,a1,1866 # 80009878 <syscalls+0x238>
    80005136:	8526                	mv	a0,s1
    80005138:	ffffc097          	auipc	ra,0xffffc
    8000513c:	a1a080e7          	jalr	-1510(ra) # 80000b52 <initlock>
  log.start = sb->logstart;
    80005140:	0149a583          	lw	a1,20(s3)
    80005144:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80005146:	0109a783          	lw	a5,16(s3)
    8000514a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000514c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80005150:	854a                	mv	a0,s2
    80005152:	fffff097          	auipc	ra,0xfffff
    80005156:	e92080e7          	jalr	-366(ra) # 80003fe4 <bread>
  log.lh.n = lh->n;
    8000515a:	4d3c                	lw	a5,88(a0)
    8000515c:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000515e:	02f05563          	blez	a5,80005188 <initlog+0x74>
    80005162:	05c50713          	addi	a4,a0,92
    80005166:	0001e697          	auipc	a3,0x1e
    8000516a:	b7a68693          	addi	a3,a3,-1158 # 80022ce0 <log+0x30>
    8000516e:	37fd                	addiw	a5,a5,-1
    80005170:	1782                	slli	a5,a5,0x20
    80005172:	9381                	srli	a5,a5,0x20
    80005174:	078a                	slli	a5,a5,0x2
    80005176:	06050613          	addi	a2,a0,96
    8000517a:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    8000517c:	4310                	lw	a2,0(a4)
    8000517e:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80005180:	0711                	addi	a4,a4,4
    80005182:	0691                	addi	a3,a3,4
    80005184:	fef71ce3          	bne	a4,a5,8000517c <initlog+0x68>
  brelse(buf);
    80005188:	fffff097          	auipc	ra,0xfffff
    8000518c:	f8c080e7          	jalr	-116(ra) # 80004114 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80005190:	4505                	li	a0,1
    80005192:	00000097          	auipc	ra,0x0
    80005196:	ebe080e7          	jalr	-322(ra) # 80005050 <install_trans>
  log.lh.n = 0;
    8000519a:	0001e797          	auipc	a5,0x1e
    8000519e:	b407a123          	sw	zero,-1214(a5) # 80022cdc <log+0x2c>
  write_head(); // clear the log
    800051a2:	00000097          	auipc	ra,0x0
    800051a6:	e34080e7          	jalr	-460(ra) # 80004fd6 <write_head>
}
    800051aa:	70a2                	ld	ra,40(sp)
    800051ac:	7402                	ld	s0,32(sp)
    800051ae:	64e2                	ld	s1,24(sp)
    800051b0:	6942                	ld	s2,16(sp)
    800051b2:	69a2                	ld	s3,8(sp)
    800051b4:	6145                	addi	sp,sp,48
    800051b6:	8082                	ret

00000000800051b8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800051b8:	1101                	addi	sp,sp,-32
    800051ba:	ec06                	sd	ra,24(sp)
    800051bc:	e822                	sd	s0,16(sp)
    800051be:	e426                	sd	s1,8(sp)
    800051c0:	e04a                	sd	s2,0(sp)
    800051c2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800051c4:	0001e517          	auipc	a0,0x1e
    800051c8:	aec50513          	addi	a0,a0,-1300 # 80022cb0 <log>
    800051cc:	ffffc097          	auipc	ra,0xffffc
    800051d0:	a16080e7          	jalr	-1514(ra) # 80000be2 <acquire>
  while(1){
    if(log.committing){
    800051d4:	0001e497          	auipc	s1,0x1e
    800051d8:	adc48493          	addi	s1,s1,-1316 # 80022cb0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800051dc:	4979                	li	s2,30
    800051de:	a039                	j	800051ec <begin_op+0x34>
      sleep(&log, &log.lock);
    800051e0:	85a6                	mv	a1,s1
    800051e2:	8526                	mv	a0,s1
    800051e4:	ffffd097          	auipc	ra,0xffffd
    800051e8:	512080e7          	jalr	1298(ra) # 800026f6 <sleep>
    if(log.committing){
    800051ec:	50dc                	lw	a5,36(s1)
    800051ee:	fbed                	bnez	a5,800051e0 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800051f0:	509c                	lw	a5,32(s1)
    800051f2:	0017871b          	addiw	a4,a5,1
    800051f6:	0007069b          	sext.w	a3,a4
    800051fa:	0027179b          	slliw	a5,a4,0x2
    800051fe:	9fb9                	addw	a5,a5,a4
    80005200:	0017979b          	slliw	a5,a5,0x1
    80005204:	54d8                	lw	a4,44(s1)
    80005206:	9fb9                	addw	a5,a5,a4
    80005208:	00f95963          	bge	s2,a5,8000521a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000520c:	85a6                	mv	a1,s1
    8000520e:	8526                	mv	a0,s1
    80005210:	ffffd097          	auipc	ra,0xffffd
    80005214:	4e6080e7          	jalr	1254(ra) # 800026f6 <sleep>
    80005218:	bfd1                	j	800051ec <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000521a:	0001e517          	auipc	a0,0x1e
    8000521e:	a9650513          	addi	a0,a0,-1386 # 80022cb0 <log>
    80005222:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80005224:	ffffc097          	auipc	ra,0xffffc
    80005228:	a72080e7          	jalr	-1422(ra) # 80000c96 <release>
      break;
    }
  }
}
    8000522c:	60e2                	ld	ra,24(sp)
    8000522e:	6442                	ld	s0,16(sp)
    80005230:	64a2                	ld	s1,8(sp)
    80005232:	6902                	ld	s2,0(sp)
    80005234:	6105                	addi	sp,sp,32
    80005236:	8082                	ret

0000000080005238 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80005238:	7139                	addi	sp,sp,-64
    8000523a:	fc06                	sd	ra,56(sp)
    8000523c:	f822                	sd	s0,48(sp)
    8000523e:	f426                	sd	s1,40(sp)
    80005240:	f04a                	sd	s2,32(sp)
    80005242:	ec4e                	sd	s3,24(sp)
    80005244:	e852                	sd	s4,16(sp)
    80005246:	e456                	sd	s5,8(sp)
    80005248:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000524a:	0001e497          	auipc	s1,0x1e
    8000524e:	a6648493          	addi	s1,s1,-1434 # 80022cb0 <log>
    80005252:	8526                	mv	a0,s1
    80005254:	ffffc097          	auipc	ra,0xffffc
    80005258:	98e080e7          	jalr	-1650(ra) # 80000be2 <acquire>
  log.outstanding -= 1;
    8000525c:	509c                	lw	a5,32(s1)
    8000525e:	37fd                	addiw	a5,a5,-1
    80005260:	0007891b          	sext.w	s2,a5
    80005264:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80005266:	50dc                	lw	a5,36(s1)
    80005268:	efb9                	bnez	a5,800052c6 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000526a:	06091663          	bnez	s2,800052d6 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000526e:	0001e497          	auipc	s1,0x1e
    80005272:	a4248493          	addi	s1,s1,-1470 # 80022cb0 <log>
    80005276:	4785                	li	a5,1
    80005278:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000527a:	8526                	mv	a0,s1
    8000527c:	ffffc097          	auipc	ra,0xffffc
    80005280:	a1a080e7          	jalr	-1510(ra) # 80000c96 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80005284:	54dc                	lw	a5,44(s1)
    80005286:	06f04763          	bgtz	a5,800052f4 <end_op+0xbc>
    acquire(&log.lock);
    8000528a:	0001e497          	auipc	s1,0x1e
    8000528e:	a2648493          	addi	s1,s1,-1498 # 80022cb0 <log>
    80005292:	8526                	mv	a0,s1
    80005294:	ffffc097          	auipc	ra,0xffffc
    80005298:	94e080e7          	jalr	-1714(ra) # 80000be2 <acquire>
    log.committing = 0;
    8000529c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800052a0:	8526                	mv	a0,s1
    800052a2:	ffffe097          	auipc	ra,0xffffe
    800052a6:	8f6080e7          	jalr	-1802(ra) # 80002b98 <wakeup>
    release(&log.lock);
    800052aa:	8526                	mv	a0,s1
    800052ac:	ffffc097          	auipc	ra,0xffffc
    800052b0:	9ea080e7          	jalr	-1558(ra) # 80000c96 <release>
}
    800052b4:	70e2                	ld	ra,56(sp)
    800052b6:	7442                	ld	s0,48(sp)
    800052b8:	74a2                	ld	s1,40(sp)
    800052ba:	7902                	ld	s2,32(sp)
    800052bc:	69e2                	ld	s3,24(sp)
    800052be:	6a42                	ld	s4,16(sp)
    800052c0:	6aa2                	ld	s5,8(sp)
    800052c2:	6121                	addi	sp,sp,64
    800052c4:	8082                	ret
    panic("log.committing");
    800052c6:	00004517          	auipc	a0,0x4
    800052ca:	5ba50513          	addi	a0,a0,1466 # 80009880 <syscalls+0x240>
    800052ce:	ffffb097          	auipc	ra,0xffffb
    800052d2:	26e080e7          	jalr	622(ra) # 8000053c <panic>
    wakeup(&log);
    800052d6:	0001e497          	auipc	s1,0x1e
    800052da:	9da48493          	addi	s1,s1,-1574 # 80022cb0 <log>
    800052de:	8526                	mv	a0,s1
    800052e0:	ffffe097          	auipc	ra,0xffffe
    800052e4:	8b8080e7          	jalr	-1864(ra) # 80002b98 <wakeup>
  release(&log.lock);
    800052e8:	8526                	mv	a0,s1
    800052ea:	ffffc097          	auipc	ra,0xffffc
    800052ee:	9ac080e7          	jalr	-1620(ra) # 80000c96 <release>
  if(do_commit){
    800052f2:	b7c9                	j	800052b4 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800052f4:	0001ea97          	auipc	s5,0x1e
    800052f8:	9eca8a93          	addi	s5,s5,-1556 # 80022ce0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800052fc:	0001ea17          	auipc	s4,0x1e
    80005300:	9b4a0a13          	addi	s4,s4,-1612 # 80022cb0 <log>
    80005304:	018a2583          	lw	a1,24(s4)
    80005308:	012585bb          	addw	a1,a1,s2
    8000530c:	2585                	addiw	a1,a1,1
    8000530e:	028a2503          	lw	a0,40(s4)
    80005312:	fffff097          	auipc	ra,0xfffff
    80005316:	cd2080e7          	jalr	-814(ra) # 80003fe4 <bread>
    8000531a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000531c:	000aa583          	lw	a1,0(s5)
    80005320:	028a2503          	lw	a0,40(s4)
    80005324:	fffff097          	auipc	ra,0xfffff
    80005328:	cc0080e7          	jalr	-832(ra) # 80003fe4 <bread>
    8000532c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000532e:	40000613          	li	a2,1024
    80005332:	05850593          	addi	a1,a0,88
    80005336:	05848513          	addi	a0,s1,88
    8000533a:	ffffc097          	auipc	ra,0xffffc
    8000533e:	a04080e7          	jalr	-1532(ra) # 80000d3e <memmove>
    bwrite(to);  // write the log
    80005342:	8526                	mv	a0,s1
    80005344:	fffff097          	auipc	ra,0xfffff
    80005348:	d92080e7          	jalr	-622(ra) # 800040d6 <bwrite>
    brelse(from);
    8000534c:	854e                	mv	a0,s3
    8000534e:	fffff097          	auipc	ra,0xfffff
    80005352:	dc6080e7          	jalr	-570(ra) # 80004114 <brelse>
    brelse(to);
    80005356:	8526                	mv	a0,s1
    80005358:	fffff097          	auipc	ra,0xfffff
    8000535c:	dbc080e7          	jalr	-580(ra) # 80004114 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005360:	2905                	addiw	s2,s2,1
    80005362:	0a91                	addi	s5,s5,4
    80005364:	02ca2783          	lw	a5,44(s4)
    80005368:	f8f94ee3          	blt	s2,a5,80005304 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000536c:	00000097          	auipc	ra,0x0
    80005370:	c6a080e7          	jalr	-918(ra) # 80004fd6 <write_head>
    install_trans(0); // Now install writes to home locations
    80005374:	4501                	li	a0,0
    80005376:	00000097          	auipc	ra,0x0
    8000537a:	cda080e7          	jalr	-806(ra) # 80005050 <install_trans>
    log.lh.n = 0;
    8000537e:	0001e797          	auipc	a5,0x1e
    80005382:	9407af23          	sw	zero,-1698(a5) # 80022cdc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80005386:	00000097          	auipc	ra,0x0
    8000538a:	c50080e7          	jalr	-944(ra) # 80004fd6 <write_head>
    8000538e:	bdf5                	j	8000528a <end_op+0x52>

0000000080005390 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80005390:	1101                	addi	sp,sp,-32
    80005392:	ec06                	sd	ra,24(sp)
    80005394:	e822                	sd	s0,16(sp)
    80005396:	e426                	sd	s1,8(sp)
    80005398:	e04a                	sd	s2,0(sp)
    8000539a:	1000                	addi	s0,sp,32
    8000539c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000539e:	0001e917          	auipc	s2,0x1e
    800053a2:	91290913          	addi	s2,s2,-1774 # 80022cb0 <log>
    800053a6:	854a                	mv	a0,s2
    800053a8:	ffffc097          	auipc	ra,0xffffc
    800053ac:	83a080e7          	jalr	-1990(ra) # 80000be2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800053b0:	02c92603          	lw	a2,44(s2)
    800053b4:	47f5                	li	a5,29
    800053b6:	06c7c563          	blt	a5,a2,80005420 <log_write+0x90>
    800053ba:	0001e797          	auipc	a5,0x1e
    800053be:	9127a783          	lw	a5,-1774(a5) # 80022ccc <log+0x1c>
    800053c2:	37fd                	addiw	a5,a5,-1
    800053c4:	04f65e63          	bge	a2,a5,80005420 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800053c8:	0001e797          	auipc	a5,0x1e
    800053cc:	9087a783          	lw	a5,-1784(a5) # 80022cd0 <log+0x20>
    800053d0:	06f05063          	blez	a5,80005430 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800053d4:	4781                	li	a5,0
    800053d6:	06c05563          	blez	a2,80005440 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800053da:	44cc                	lw	a1,12(s1)
    800053dc:	0001e717          	auipc	a4,0x1e
    800053e0:	90470713          	addi	a4,a4,-1788 # 80022ce0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800053e4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800053e6:	4314                	lw	a3,0(a4)
    800053e8:	04b68c63          	beq	a3,a1,80005440 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800053ec:	2785                	addiw	a5,a5,1
    800053ee:	0711                	addi	a4,a4,4
    800053f0:	fef61be3          	bne	a2,a5,800053e6 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800053f4:	0621                	addi	a2,a2,8
    800053f6:	060a                	slli	a2,a2,0x2
    800053f8:	0001e797          	auipc	a5,0x1e
    800053fc:	8b878793          	addi	a5,a5,-1864 # 80022cb0 <log>
    80005400:	963e                	add	a2,a2,a5
    80005402:	44dc                	lw	a5,12(s1)
    80005404:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005406:	8526                	mv	a0,s1
    80005408:	fffff097          	auipc	ra,0xfffff
    8000540c:	daa080e7          	jalr	-598(ra) # 800041b2 <bpin>
    log.lh.n++;
    80005410:	0001e717          	auipc	a4,0x1e
    80005414:	8a070713          	addi	a4,a4,-1888 # 80022cb0 <log>
    80005418:	575c                	lw	a5,44(a4)
    8000541a:	2785                	addiw	a5,a5,1
    8000541c:	d75c                	sw	a5,44(a4)
    8000541e:	a835                	j	8000545a <log_write+0xca>
    panic("too big a transaction");
    80005420:	00004517          	auipc	a0,0x4
    80005424:	47050513          	addi	a0,a0,1136 # 80009890 <syscalls+0x250>
    80005428:	ffffb097          	auipc	ra,0xffffb
    8000542c:	114080e7          	jalr	276(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    80005430:	00004517          	auipc	a0,0x4
    80005434:	47850513          	addi	a0,a0,1144 # 800098a8 <syscalls+0x268>
    80005438:	ffffb097          	auipc	ra,0xffffb
    8000543c:	104080e7          	jalr	260(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    80005440:	00878713          	addi	a4,a5,8
    80005444:	00271693          	slli	a3,a4,0x2
    80005448:	0001e717          	auipc	a4,0x1e
    8000544c:	86870713          	addi	a4,a4,-1944 # 80022cb0 <log>
    80005450:	9736                	add	a4,a4,a3
    80005452:	44d4                	lw	a3,12(s1)
    80005454:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80005456:	faf608e3          	beq	a2,a5,80005406 <log_write+0x76>
  }
  release(&log.lock);
    8000545a:	0001e517          	auipc	a0,0x1e
    8000545e:	85650513          	addi	a0,a0,-1962 # 80022cb0 <log>
    80005462:	ffffc097          	auipc	ra,0xffffc
    80005466:	834080e7          	jalr	-1996(ra) # 80000c96 <release>
}
    8000546a:	60e2                	ld	ra,24(sp)
    8000546c:	6442                	ld	s0,16(sp)
    8000546e:	64a2                	ld	s1,8(sp)
    80005470:	6902                	ld	s2,0(sp)
    80005472:	6105                	addi	sp,sp,32
    80005474:	8082                	ret

0000000080005476 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80005476:	1101                	addi	sp,sp,-32
    80005478:	ec06                	sd	ra,24(sp)
    8000547a:	e822                	sd	s0,16(sp)
    8000547c:	e426                	sd	s1,8(sp)
    8000547e:	e04a                	sd	s2,0(sp)
    80005480:	1000                	addi	s0,sp,32
    80005482:	84aa                	mv	s1,a0
    80005484:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80005486:	00004597          	auipc	a1,0x4
    8000548a:	44258593          	addi	a1,a1,1090 # 800098c8 <syscalls+0x288>
    8000548e:	0521                	addi	a0,a0,8
    80005490:	ffffb097          	auipc	ra,0xffffb
    80005494:	6c2080e7          	jalr	1730(ra) # 80000b52 <initlock>
  lk->name = name;
    80005498:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000549c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800054a0:	0204a423          	sw	zero,40(s1)
}
    800054a4:	60e2                	ld	ra,24(sp)
    800054a6:	6442                	ld	s0,16(sp)
    800054a8:	64a2                	ld	s1,8(sp)
    800054aa:	6902                	ld	s2,0(sp)
    800054ac:	6105                	addi	sp,sp,32
    800054ae:	8082                	ret

00000000800054b0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800054b0:	1101                	addi	sp,sp,-32
    800054b2:	ec06                	sd	ra,24(sp)
    800054b4:	e822                	sd	s0,16(sp)
    800054b6:	e426                	sd	s1,8(sp)
    800054b8:	e04a                	sd	s2,0(sp)
    800054ba:	1000                	addi	s0,sp,32
    800054bc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800054be:	00850913          	addi	s2,a0,8
    800054c2:	854a                	mv	a0,s2
    800054c4:	ffffb097          	auipc	ra,0xffffb
    800054c8:	71e080e7          	jalr	1822(ra) # 80000be2 <acquire>
  while (lk->locked) {
    800054cc:	409c                	lw	a5,0(s1)
    800054ce:	cb89                	beqz	a5,800054e0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800054d0:	85ca                	mv	a1,s2
    800054d2:	8526                	mv	a0,s1
    800054d4:	ffffd097          	auipc	ra,0xffffd
    800054d8:	222080e7          	jalr	546(ra) # 800026f6 <sleep>
  while (lk->locked) {
    800054dc:	409c                	lw	a5,0(s1)
    800054de:	fbed                	bnez	a5,800054d0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800054e0:	4785                	li	a5,1
    800054e2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800054e4:	ffffc097          	auipc	ra,0xffffc
    800054e8:	4ca080e7          	jalr	1226(ra) # 800019ae <myproc>
    800054ec:	591c                	lw	a5,48(a0)
    800054ee:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800054f0:	854a                	mv	a0,s2
    800054f2:	ffffb097          	auipc	ra,0xffffb
    800054f6:	7a4080e7          	jalr	1956(ra) # 80000c96 <release>
}
    800054fa:	60e2                	ld	ra,24(sp)
    800054fc:	6442                	ld	s0,16(sp)
    800054fe:	64a2                	ld	s1,8(sp)
    80005500:	6902                	ld	s2,0(sp)
    80005502:	6105                	addi	sp,sp,32
    80005504:	8082                	ret

0000000080005506 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005506:	1101                	addi	sp,sp,-32
    80005508:	ec06                	sd	ra,24(sp)
    8000550a:	e822                	sd	s0,16(sp)
    8000550c:	e426                	sd	s1,8(sp)
    8000550e:	e04a                	sd	s2,0(sp)
    80005510:	1000                	addi	s0,sp,32
    80005512:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005514:	00850913          	addi	s2,a0,8
    80005518:	854a                	mv	a0,s2
    8000551a:	ffffb097          	auipc	ra,0xffffb
    8000551e:	6c8080e7          	jalr	1736(ra) # 80000be2 <acquire>
  lk->locked = 0;
    80005522:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005526:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000552a:	8526                	mv	a0,s1
    8000552c:	ffffd097          	auipc	ra,0xffffd
    80005530:	66c080e7          	jalr	1644(ra) # 80002b98 <wakeup>
  release(&lk->lk);
    80005534:	854a                	mv	a0,s2
    80005536:	ffffb097          	auipc	ra,0xffffb
    8000553a:	760080e7          	jalr	1888(ra) # 80000c96 <release>
}
    8000553e:	60e2                	ld	ra,24(sp)
    80005540:	6442                	ld	s0,16(sp)
    80005542:	64a2                	ld	s1,8(sp)
    80005544:	6902                	ld	s2,0(sp)
    80005546:	6105                	addi	sp,sp,32
    80005548:	8082                	ret

000000008000554a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000554a:	7179                	addi	sp,sp,-48
    8000554c:	f406                	sd	ra,40(sp)
    8000554e:	f022                	sd	s0,32(sp)
    80005550:	ec26                	sd	s1,24(sp)
    80005552:	e84a                	sd	s2,16(sp)
    80005554:	e44e                	sd	s3,8(sp)
    80005556:	1800                	addi	s0,sp,48
    80005558:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000555a:	00850913          	addi	s2,a0,8
    8000555e:	854a                	mv	a0,s2
    80005560:	ffffb097          	auipc	ra,0xffffb
    80005564:	682080e7          	jalr	1666(ra) # 80000be2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80005568:	409c                	lw	a5,0(s1)
    8000556a:	ef99                	bnez	a5,80005588 <holdingsleep+0x3e>
    8000556c:	4481                	li	s1,0
  release(&lk->lk);
    8000556e:	854a                	mv	a0,s2
    80005570:	ffffb097          	auipc	ra,0xffffb
    80005574:	726080e7          	jalr	1830(ra) # 80000c96 <release>
  return r;
}
    80005578:	8526                	mv	a0,s1
    8000557a:	70a2                	ld	ra,40(sp)
    8000557c:	7402                	ld	s0,32(sp)
    8000557e:	64e2                	ld	s1,24(sp)
    80005580:	6942                	ld	s2,16(sp)
    80005582:	69a2                	ld	s3,8(sp)
    80005584:	6145                	addi	sp,sp,48
    80005586:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80005588:	0284a983          	lw	s3,40(s1)
    8000558c:	ffffc097          	auipc	ra,0xffffc
    80005590:	422080e7          	jalr	1058(ra) # 800019ae <myproc>
    80005594:	5904                	lw	s1,48(a0)
    80005596:	413484b3          	sub	s1,s1,s3
    8000559a:	0014b493          	seqz	s1,s1
    8000559e:	bfc1                	j	8000556e <holdingsleep+0x24>

00000000800055a0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800055a0:	1141                	addi	sp,sp,-16
    800055a2:	e406                	sd	ra,8(sp)
    800055a4:	e022                	sd	s0,0(sp)
    800055a6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800055a8:	00004597          	auipc	a1,0x4
    800055ac:	33058593          	addi	a1,a1,816 # 800098d8 <syscalls+0x298>
    800055b0:	0001e517          	auipc	a0,0x1e
    800055b4:	84850513          	addi	a0,a0,-1976 # 80022df8 <ftable>
    800055b8:	ffffb097          	auipc	ra,0xffffb
    800055bc:	59a080e7          	jalr	1434(ra) # 80000b52 <initlock>
}
    800055c0:	60a2                	ld	ra,8(sp)
    800055c2:	6402                	ld	s0,0(sp)
    800055c4:	0141                	addi	sp,sp,16
    800055c6:	8082                	ret

00000000800055c8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800055c8:	1101                	addi	sp,sp,-32
    800055ca:	ec06                	sd	ra,24(sp)
    800055cc:	e822                	sd	s0,16(sp)
    800055ce:	e426                	sd	s1,8(sp)
    800055d0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800055d2:	0001e517          	auipc	a0,0x1e
    800055d6:	82650513          	addi	a0,a0,-2010 # 80022df8 <ftable>
    800055da:	ffffb097          	auipc	ra,0xffffb
    800055de:	608080e7          	jalr	1544(ra) # 80000be2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800055e2:	0001e497          	auipc	s1,0x1e
    800055e6:	82e48493          	addi	s1,s1,-2002 # 80022e10 <ftable+0x18>
    800055ea:	0001e717          	auipc	a4,0x1e
    800055ee:	7c670713          	addi	a4,a4,1990 # 80023db0 <ftable+0xfb8>
    if(f->ref == 0){
    800055f2:	40dc                	lw	a5,4(s1)
    800055f4:	cf99                	beqz	a5,80005612 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800055f6:	02848493          	addi	s1,s1,40
    800055fa:	fee49ce3          	bne	s1,a4,800055f2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800055fe:	0001d517          	auipc	a0,0x1d
    80005602:	7fa50513          	addi	a0,a0,2042 # 80022df8 <ftable>
    80005606:	ffffb097          	auipc	ra,0xffffb
    8000560a:	690080e7          	jalr	1680(ra) # 80000c96 <release>
  return 0;
    8000560e:	4481                	li	s1,0
    80005610:	a819                	j	80005626 <filealloc+0x5e>
      f->ref = 1;
    80005612:	4785                	li	a5,1
    80005614:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005616:	0001d517          	auipc	a0,0x1d
    8000561a:	7e250513          	addi	a0,a0,2018 # 80022df8 <ftable>
    8000561e:	ffffb097          	auipc	ra,0xffffb
    80005622:	678080e7          	jalr	1656(ra) # 80000c96 <release>
}
    80005626:	8526                	mv	a0,s1
    80005628:	60e2                	ld	ra,24(sp)
    8000562a:	6442                	ld	s0,16(sp)
    8000562c:	64a2                	ld	s1,8(sp)
    8000562e:	6105                	addi	sp,sp,32
    80005630:	8082                	ret

0000000080005632 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005632:	1101                	addi	sp,sp,-32
    80005634:	ec06                	sd	ra,24(sp)
    80005636:	e822                	sd	s0,16(sp)
    80005638:	e426                	sd	s1,8(sp)
    8000563a:	1000                	addi	s0,sp,32
    8000563c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000563e:	0001d517          	auipc	a0,0x1d
    80005642:	7ba50513          	addi	a0,a0,1978 # 80022df8 <ftable>
    80005646:	ffffb097          	auipc	ra,0xffffb
    8000564a:	59c080e7          	jalr	1436(ra) # 80000be2 <acquire>
  if(f->ref < 1)
    8000564e:	40dc                	lw	a5,4(s1)
    80005650:	02f05263          	blez	a5,80005674 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80005654:	2785                	addiw	a5,a5,1
    80005656:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80005658:	0001d517          	auipc	a0,0x1d
    8000565c:	7a050513          	addi	a0,a0,1952 # 80022df8 <ftable>
    80005660:	ffffb097          	auipc	ra,0xffffb
    80005664:	636080e7          	jalr	1590(ra) # 80000c96 <release>
  return f;
}
    80005668:	8526                	mv	a0,s1
    8000566a:	60e2                	ld	ra,24(sp)
    8000566c:	6442                	ld	s0,16(sp)
    8000566e:	64a2                	ld	s1,8(sp)
    80005670:	6105                	addi	sp,sp,32
    80005672:	8082                	ret
    panic("filedup");
    80005674:	00004517          	auipc	a0,0x4
    80005678:	26c50513          	addi	a0,a0,620 # 800098e0 <syscalls+0x2a0>
    8000567c:	ffffb097          	auipc	ra,0xffffb
    80005680:	ec0080e7          	jalr	-320(ra) # 8000053c <panic>

0000000080005684 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80005684:	7139                	addi	sp,sp,-64
    80005686:	fc06                	sd	ra,56(sp)
    80005688:	f822                	sd	s0,48(sp)
    8000568a:	f426                	sd	s1,40(sp)
    8000568c:	f04a                	sd	s2,32(sp)
    8000568e:	ec4e                	sd	s3,24(sp)
    80005690:	e852                	sd	s4,16(sp)
    80005692:	e456                	sd	s5,8(sp)
    80005694:	0080                	addi	s0,sp,64
    80005696:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80005698:	0001d517          	auipc	a0,0x1d
    8000569c:	76050513          	addi	a0,a0,1888 # 80022df8 <ftable>
    800056a0:	ffffb097          	auipc	ra,0xffffb
    800056a4:	542080e7          	jalr	1346(ra) # 80000be2 <acquire>
  if(f->ref < 1)
    800056a8:	40dc                	lw	a5,4(s1)
    800056aa:	06f05163          	blez	a5,8000570c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800056ae:	37fd                	addiw	a5,a5,-1
    800056b0:	0007871b          	sext.w	a4,a5
    800056b4:	c0dc                	sw	a5,4(s1)
    800056b6:	06e04363          	bgtz	a4,8000571c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800056ba:	0004a903          	lw	s2,0(s1)
    800056be:	0094ca83          	lbu	s5,9(s1)
    800056c2:	0104ba03          	ld	s4,16(s1)
    800056c6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800056ca:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800056ce:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800056d2:	0001d517          	auipc	a0,0x1d
    800056d6:	72650513          	addi	a0,a0,1830 # 80022df8 <ftable>
    800056da:	ffffb097          	auipc	ra,0xffffb
    800056de:	5bc080e7          	jalr	1468(ra) # 80000c96 <release>

  if(ff.type == FD_PIPE){
    800056e2:	4785                	li	a5,1
    800056e4:	04f90d63          	beq	s2,a5,8000573e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800056e8:	3979                	addiw	s2,s2,-2
    800056ea:	4785                	li	a5,1
    800056ec:	0527e063          	bltu	a5,s2,8000572c <fileclose+0xa8>
    begin_op();
    800056f0:	00000097          	auipc	ra,0x0
    800056f4:	ac8080e7          	jalr	-1336(ra) # 800051b8 <begin_op>
    iput(ff.ip);
    800056f8:	854e                	mv	a0,s3
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	2a6080e7          	jalr	678(ra) # 800049a0 <iput>
    end_op();
    80005702:	00000097          	auipc	ra,0x0
    80005706:	b36080e7          	jalr	-1226(ra) # 80005238 <end_op>
    8000570a:	a00d                	j	8000572c <fileclose+0xa8>
    panic("fileclose");
    8000570c:	00004517          	auipc	a0,0x4
    80005710:	1dc50513          	addi	a0,a0,476 # 800098e8 <syscalls+0x2a8>
    80005714:	ffffb097          	auipc	ra,0xffffb
    80005718:	e28080e7          	jalr	-472(ra) # 8000053c <panic>
    release(&ftable.lock);
    8000571c:	0001d517          	auipc	a0,0x1d
    80005720:	6dc50513          	addi	a0,a0,1756 # 80022df8 <ftable>
    80005724:	ffffb097          	auipc	ra,0xffffb
    80005728:	572080e7          	jalr	1394(ra) # 80000c96 <release>
  }
}
    8000572c:	70e2                	ld	ra,56(sp)
    8000572e:	7442                	ld	s0,48(sp)
    80005730:	74a2                	ld	s1,40(sp)
    80005732:	7902                	ld	s2,32(sp)
    80005734:	69e2                	ld	s3,24(sp)
    80005736:	6a42                	ld	s4,16(sp)
    80005738:	6aa2                	ld	s5,8(sp)
    8000573a:	6121                	addi	sp,sp,64
    8000573c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000573e:	85d6                	mv	a1,s5
    80005740:	8552                	mv	a0,s4
    80005742:	00000097          	auipc	ra,0x0
    80005746:	34c080e7          	jalr	844(ra) # 80005a8e <pipeclose>
    8000574a:	b7cd                	j	8000572c <fileclose+0xa8>

000000008000574c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000574c:	715d                	addi	sp,sp,-80
    8000574e:	e486                	sd	ra,72(sp)
    80005750:	e0a2                	sd	s0,64(sp)
    80005752:	fc26                	sd	s1,56(sp)
    80005754:	f84a                	sd	s2,48(sp)
    80005756:	f44e                	sd	s3,40(sp)
    80005758:	0880                	addi	s0,sp,80
    8000575a:	84aa                	mv	s1,a0
    8000575c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000575e:	ffffc097          	auipc	ra,0xffffc
    80005762:	250080e7          	jalr	592(ra) # 800019ae <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005766:	409c                	lw	a5,0(s1)
    80005768:	37f9                	addiw	a5,a5,-2
    8000576a:	4705                	li	a4,1
    8000576c:	04f76763          	bltu	a4,a5,800057ba <filestat+0x6e>
    80005770:	892a                	mv	s2,a0
    ilock(f->ip);
    80005772:	6c88                	ld	a0,24(s1)
    80005774:	fffff097          	auipc	ra,0xfffff
    80005778:	072080e7          	jalr	114(ra) # 800047e6 <ilock>
    stati(f->ip, &st);
    8000577c:	fb840593          	addi	a1,s0,-72
    80005780:	6c88                	ld	a0,24(s1)
    80005782:	fffff097          	auipc	ra,0xfffff
    80005786:	2ee080e7          	jalr	750(ra) # 80004a70 <stati>
    iunlock(f->ip);
    8000578a:	6c88                	ld	a0,24(s1)
    8000578c:	fffff097          	auipc	ra,0xfffff
    80005790:	11c080e7          	jalr	284(ra) # 800048a8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005794:	46e1                	li	a3,24
    80005796:	fb840613          	addi	a2,s0,-72
    8000579a:	85ce                	mv	a1,s3
    8000579c:	05093503          	ld	a0,80(s2)
    800057a0:	ffffc097          	auipc	ra,0xffffc
    800057a4:	ed0080e7          	jalr	-304(ra) # 80001670 <copyout>
    800057a8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800057ac:	60a6                	ld	ra,72(sp)
    800057ae:	6406                	ld	s0,64(sp)
    800057b0:	74e2                	ld	s1,56(sp)
    800057b2:	7942                	ld	s2,48(sp)
    800057b4:	79a2                	ld	s3,40(sp)
    800057b6:	6161                	addi	sp,sp,80
    800057b8:	8082                	ret
  return -1;
    800057ba:	557d                	li	a0,-1
    800057bc:	bfc5                	j	800057ac <filestat+0x60>

00000000800057be <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800057be:	7179                	addi	sp,sp,-48
    800057c0:	f406                	sd	ra,40(sp)
    800057c2:	f022                	sd	s0,32(sp)
    800057c4:	ec26                	sd	s1,24(sp)
    800057c6:	e84a                	sd	s2,16(sp)
    800057c8:	e44e                	sd	s3,8(sp)
    800057ca:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800057cc:	00854783          	lbu	a5,8(a0)
    800057d0:	c3d5                	beqz	a5,80005874 <fileread+0xb6>
    800057d2:	84aa                	mv	s1,a0
    800057d4:	89ae                	mv	s3,a1
    800057d6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800057d8:	411c                	lw	a5,0(a0)
    800057da:	4705                	li	a4,1
    800057dc:	04e78963          	beq	a5,a4,8000582e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800057e0:	470d                	li	a4,3
    800057e2:	04e78d63          	beq	a5,a4,8000583c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800057e6:	4709                	li	a4,2
    800057e8:	06e79e63          	bne	a5,a4,80005864 <fileread+0xa6>
    ilock(f->ip);
    800057ec:	6d08                	ld	a0,24(a0)
    800057ee:	fffff097          	auipc	ra,0xfffff
    800057f2:	ff8080e7          	jalr	-8(ra) # 800047e6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800057f6:	874a                	mv	a4,s2
    800057f8:	5094                	lw	a3,32(s1)
    800057fa:	864e                	mv	a2,s3
    800057fc:	4585                	li	a1,1
    800057fe:	6c88                	ld	a0,24(s1)
    80005800:	fffff097          	auipc	ra,0xfffff
    80005804:	29a080e7          	jalr	666(ra) # 80004a9a <readi>
    80005808:	892a                	mv	s2,a0
    8000580a:	00a05563          	blez	a0,80005814 <fileread+0x56>
      f->off += r;
    8000580e:	509c                	lw	a5,32(s1)
    80005810:	9fa9                	addw	a5,a5,a0
    80005812:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005814:	6c88                	ld	a0,24(s1)
    80005816:	fffff097          	auipc	ra,0xfffff
    8000581a:	092080e7          	jalr	146(ra) # 800048a8 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000581e:	854a                	mv	a0,s2
    80005820:	70a2                	ld	ra,40(sp)
    80005822:	7402                	ld	s0,32(sp)
    80005824:	64e2                	ld	s1,24(sp)
    80005826:	6942                	ld	s2,16(sp)
    80005828:	69a2                	ld	s3,8(sp)
    8000582a:	6145                	addi	sp,sp,48
    8000582c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000582e:	6908                	ld	a0,16(a0)
    80005830:	00000097          	auipc	ra,0x0
    80005834:	3c8080e7          	jalr	968(ra) # 80005bf8 <piperead>
    80005838:	892a                	mv	s2,a0
    8000583a:	b7d5                	j	8000581e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000583c:	02451783          	lh	a5,36(a0)
    80005840:	03079693          	slli	a3,a5,0x30
    80005844:	92c1                	srli	a3,a3,0x30
    80005846:	4725                	li	a4,9
    80005848:	02d76863          	bltu	a4,a3,80005878 <fileread+0xba>
    8000584c:	0792                	slli	a5,a5,0x4
    8000584e:	0001d717          	auipc	a4,0x1d
    80005852:	50a70713          	addi	a4,a4,1290 # 80022d58 <devsw>
    80005856:	97ba                	add	a5,a5,a4
    80005858:	639c                	ld	a5,0(a5)
    8000585a:	c38d                	beqz	a5,8000587c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000585c:	4505                	li	a0,1
    8000585e:	9782                	jalr	a5
    80005860:	892a                	mv	s2,a0
    80005862:	bf75                	j	8000581e <fileread+0x60>
    panic("fileread");
    80005864:	00004517          	auipc	a0,0x4
    80005868:	09450513          	addi	a0,a0,148 # 800098f8 <syscalls+0x2b8>
    8000586c:	ffffb097          	auipc	ra,0xffffb
    80005870:	cd0080e7          	jalr	-816(ra) # 8000053c <panic>
    return -1;
    80005874:	597d                	li	s2,-1
    80005876:	b765                	j	8000581e <fileread+0x60>
      return -1;
    80005878:	597d                	li	s2,-1
    8000587a:	b755                	j	8000581e <fileread+0x60>
    8000587c:	597d                	li	s2,-1
    8000587e:	b745                	j	8000581e <fileread+0x60>

0000000080005880 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005880:	715d                	addi	sp,sp,-80
    80005882:	e486                	sd	ra,72(sp)
    80005884:	e0a2                	sd	s0,64(sp)
    80005886:	fc26                	sd	s1,56(sp)
    80005888:	f84a                	sd	s2,48(sp)
    8000588a:	f44e                	sd	s3,40(sp)
    8000588c:	f052                	sd	s4,32(sp)
    8000588e:	ec56                	sd	s5,24(sp)
    80005890:	e85a                	sd	s6,16(sp)
    80005892:	e45e                	sd	s7,8(sp)
    80005894:	e062                	sd	s8,0(sp)
    80005896:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005898:	00954783          	lbu	a5,9(a0)
    8000589c:	10078663          	beqz	a5,800059a8 <filewrite+0x128>
    800058a0:	892a                	mv	s2,a0
    800058a2:	8aae                	mv	s5,a1
    800058a4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800058a6:	411c                	lw	a5,0(a0)
    800058a8:	4705                	li	a4,1
    800058aa:	02e78263          	beq	a5,a4,800058ce <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800058ae:	470d                	li	a4,3
    800058b0:	02e78663          	beq	a5,a4,800058dc <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800058b4:	4709                	li	a4,2
    800058b6:	0ee79163          	bne	a5,a4,80005998 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800058ba:	0ac05d63          	blez	a2,80005974 <filewrite+0xf4>
    int i = 0;
    800058be:	4981                	li	s3,0
    800058c0:	6b05                	lui	s6,0x1
    800058c2:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800058c6:	6b85                	lui	s7,0x1
    800058c8:	c00b8b9b          	addiw	s7,s7,-1024
    800058cc:	a861                	j	80005964 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800058ce:	6908                	ld	a0,16(a0)
    800058d0:	00000097          	auipc	ra,0x0
    800058d4:	22e080e7          	jalr	558(ra) # 80005afe <pipewrite>
    800058d8:	8a2a                	mv	s4,a0
    800058da:	a045                	j	8000597a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800058dc:	02451783          	lh	a5,36(a0)
    800058e0:	03079693          	slli	a3,a5,0x30
    800058e4:	92c1                	srli	a3,a3,0x30
    800058e6:	4725                	li	a4,9
    800058e8:	0cd76263          	bltu	a4,a3,800059ac <filewrite+0x12c>
    800058ec:	0792                	slli	a5,a5,0x4
    800058ee:	0001d717          	auipc	a4,0x1d
    800058f2:	46a70713          	addi	a4,a4,1130 # 80022d58 <devsw>
    800058f6:	97ba                	add	a5,a5,a4
    800058f8:	679c                	ld	a5,8(a5)
    800058fa:	cbdd                	beqz	a5,800059b0 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800058fc:	4505                	li	a0,1
    800058fe:	9782                	jalr	a5
    80005900:	8a2a                	mv	s4,a0
    80005902:	a8a5                	j	8000597a <filewrite+0xfa>
    80005904:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005908:	00000097          	auipc	ra,0x0
    8000590c:	8b0080e7          	jalr	-1872(ra) # 800051b8 <begin_op>
      ilock(f->ip);
    80005910:	01893503          	ld	a0,24(s2)
    80005914:	fffff097          	auipc	ra,0xfffff
    80005918:	ed2080e7          	jalr	-302(ra) # 800047e6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000591c:	8762                	mv	a4,s8
    8000591e:	02092683          	lw	a3,32(s2)
    80005922:	01598633          	add	a2,s3,s5
    80005926:	4585                	li	a1,1
    80005928:	01893503          	ld	a0,24(s2)
    8000592c:	fffff097          	auipc	ra,0xfffff
    80005930:	266080e7          	jalr	614(ra) # 80004b92 <writei>
    80005934:	84aa                	mv	s1,a0
    80005936:	00a05763          	blez	a0,80005944 <filewrite+0xc4>
        f->off += r;
    8000593a:	02092783          	lw	a5,32(s2)
    8000593e:	9fa9                	addw	a5,a5,a0
    80005940:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005944:	01893503          	ld	a0,24(s2)
    80005948:	fffff097          	auipc	ra,0xfffff
    8000594c:	f60080e7          	jalr	-160(ra) # 800048a8 <iunlock>
      end_op();
    80005950:	00000097          	auipc	ra,0x0
    80005954:	8e8080e7          	jalr	-1816(ra) # 80005238 <end_op>

      if(r != n1){
    80005958:	009c1f63          	bne	s8,s1,80005976 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000595c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005960:	0149db63          	bge	s3,s4,80005976 <filewrite+0xf6>
      int n1 = n - i;
    80005964:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005968:	84be                	mv	s1,a5
    8000596a:	2781                	sext.w	a5,a5
    8000596c:	f8fb5ce3          	bge	s6,a5,80005904 <filewrite+0x84>
    80005970:	84de                	mv	s1,s7
    80005972:	bf49                	j	80005904 <filewrite+0x84>
    int i = 0;
    80005974:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005976:	013a1f63          	bne	s4,s3,80005994 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000597a:	8552                	mv	a0,s4
    8000597c:	60a6                	ld	ra,72(sp)
    8000597e:	6406                	ld	s0,64(sp)
    80005980:	74e2                	ld	s1,56(sp)
    80005982:	7942                	ld	s2,48(sp)
    80005984:	79a2                	ld	s3,40(sp)
    80005986:	7a02                	ld	s4,32(sp)
    80005988:	6ae2                	ld	s5,24(sp)
    8000598a:	6b42                	ld	s6,16(sp)
    8000598c:	6ba2                	ld	s7,8(sp)
    8000598e:	6c02                	ld	s8,0(sp)
    80005990:	6161                	addi	sp,sp,80
    80005992:	8082                	ret
    ret = (i == n ? n : -1);
    80005994:	5a7d                	li	s4,-1
    80005996:	b7d5                	j	8000597a <filewrite+0xfa>
    panic("filewrite");
    80005998:	00004517          	auipc	a0,0x4
    8000599c:	f7050513          	addi	a0,a0,-144 # 80009908 <syscalls+0x2c8>
    800059a0:	ffffb097          	auipc	ra,0xffffb
    800059a4:	b9c080e7          	jalr	-1124(ra) # 8000053c <panic>
    return -1;
    800059a8:	5a7d                	li	s4,-1
    800059aa:	bfc1                	j	8000597a <filewrite+0xfa>
      return -1;
    800059ac:	5a7d                	li	s4,-1
    800059ae:	b7f1                	j	8000597a <filewrite+0xfa>
    800059b0:	5a7d                	li	s4,-1
    800059b2:	b7e1                	j	8000597a <filewrite+0xfa>

00000000800059b4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800059b4:	7179                	addi	sp,sp,-48
    800059b6:	f406                	sd	ra,40(sp)
    800059b8:	f022                	sd	s0,32(sp)
    800059ba:	ec26                	sd	s1,24(sp)
    800059bc:	e84a                	sd	s2,16(sp)
    800059be:	e44e                	sd	s3,8(sp)
    800059c0:	e052                	sd	s4,0(sp)
    800059c2:	1800                	addi	s0,sp,48
    800059c4:	84aa                	mv	s1,a0
    800059c6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800059c8:	0005b023          	sd	zero,0(a1)
    800059cc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800059d0:	00000097          	auipc	ra,0x0
    800059d4:	bf8080e7          	jalr	-1032(ra) # 800055c8 <filealloc>
    800059d8:	e088                	sd	a0,0(s1)
    800059da:	c551                	beqz	a0,80005a66 <pipealloc+0xb2>
    800059dc:	00000097          	auipc	ra,0x0
    800059e0:	bec080e7          	jalr	-1044(ra) # 800055c8 <filealloc>
    800059e4:	00aa3023          	sd	a0,0(s4)
    800059e8:	c92d                	beqz	a0,80005a5a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800059ea:	ffffb097          	auipc	ra,0xffffb
    800059ee:	108080e7          	jalr	264(ra) # 80000af2 <kalloc>
    800059f2:	892a                	mv	s2,a0
    800059f4:	c125                	beqz	a0,80005a54 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800059f6:	4985                	li	s3,1
    800059f8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800059fc:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005a00:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005a04:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005a08:	00004597          	auipc	a1,0x4
    80005a0c:	f1058593          	addi	a1,a1,-240 # 80009918 <syscalls+0x2d8>
    80005a10:	ffffb097          	auipc	ra,0xffffb
    80005a14:	142080e7          	jalr	322(ra) # 80000b52 <initlock>
  (*f0)->type = FD_PIPE;
    80005a18:	609c                	ld	a5,0(s1)
    80005a1a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005a1e:	609c                	ld	a5,0(s1)
    80005a20:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005a24:	609c                	ld	a5,0(s1)
    80005a26:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005a2a:	609c                	ld	a5,0(s1)
    80005a2c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005a30:	000a3783          	ld	a5,0(s4)
    80005a34:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005a38:	000a3783          	ld	a5,0(s4)
    80005a3c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005a40:	000a3783          	ld	a5,0(s4)
    80005a44:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005a48:	000a3783          	ld	a5,0(s4)
    80005a4c:	0127b823          	sd	s2,16(a5)
  return 0;
    80005a50:	4501                	li	a0,0
    80005a52:	a025                	j	80005a7a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005a54:	6088                	ld	a0,0(s1)
    80005a56:	e501                	bnez	a0,80005a5e <pipealloc+0xaa>
    80005a58:	a039                	j	80005a66 <pipealloc+0xb2>
    80005a5a:	6088                	ld	a0,0(s1)
    80005a5c:	c51d                	beqz	a0,80005a8a <pipealloc+0xd6>
    fileclose(*f0);
    80005a5e:	00000097          	auipc	ra,0x0
    80005a62:	c26080e7          	jalr	-986(ra) # 80005684 <fileclose>
  if(*f1)
    80005a66:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005a6a:	557d                	li	a0,-1
  if(*f1)
    80005a6c:	c799                	beqz	a5,80005a7a <pipealloc+0xc6>
    fileclose(*f1);
    80005a6e:	853e                	mv	a0,a5
    80005a70:	00000097          	auipc	ra,0x0
    80005a74:	c14080e7          	jalr	-1004(ra) # 80005684 <fileclose>
  return -1;
    80005a78:	557d                	li	a0,-1
}
    80005a7a:	70a2                	ld	ra,40(sp)
    80005a7c:	7402                	ld	s0,32(sp)
    80005a7e:	64e2                	ld	s1,24(sp)
    80005a80:	6942                	ld	s2,16(sp)
    80005a82:	69a2                	ld	s3,8(sp)
    80005a84:	6a02                	ld	s4,0(sp)
    80005a86:	6145                	addi	sp,sp,48
    80005a88:	8082                	ret
  return -1;
    80005a8a:	557d                	li	a0,-1
    80005a8c:	b7fd                	j	80005a7a <pipealloc+0xc6>

0000000080005a8e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005a8e:	1101                	addi	sp,sp,-32
    80005a90:	ec06                	sd	ra,24(sp)
    80005a92:	e822                	sd	s0,16(sp)
    80005a94:	e426                	sd	s1,8(sp)
    80005a96:	e04a                	sd	s2,0(sp)
    80005a98:	1000                	addi	s0,sp,32
    80005a9a:	84aa                	mv	s1,a0
    80005a9c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005a9e:	ffffb097          	auipc	ra,0xffffb
    80005aa2:	144080e7          	jalr	324(ra) # 80000be2 <acquire>
  if(writable){
    80005aa6:	02090d63          	beqz	s2,80005ae0 <pipeclose+0x52>
    pi->writeopen = 0;
    80005aaa:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005aae:	21848513          	addi	a0,s1,536
    80005ab2:	ffffd097          	auipc	ra,0xffffd
    80005ab6:	0e6080e7          	jalr	230(ra) # 80002b98 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005aba:	2204b783          	ld	a5,544(s1)
    80005abe:	eb95                	bnez	a5,80005af2 <pipeclose+0x64>
    release(&pi->lock);
    80005ac0:	8526                	mv	a0,s1
    80005ac2:	ffffb097          	auipc	ra,0xffffb
    80005ac6:	1d4080e7          	jalr	468(ra) # 80000c96 <release>
    kfree((char*)pi);
    80005aca:	8526                	mv	a0,s1
    80005acc:	ffffb097          	auipc	ra,0xffffb
    80005ad0:	f2a080e7          	jalr	-214(ra) # 800009f6 <kfree>
  } else
    release(&pi->lock);
}
    80005ad4:	60e2                	ld	ra,24(sp)
    80005ad6:	6442                	ld	s0,16(sp)
    80005ad8:	64a2                	ld	s1,8(sp)
    80005ada:	6902                	ld	s2,0(sp)
    80005adc:	6105                	addi	sp,sp,32
    80005ade:	8082                	ret
    pi->readopen = 0;
    80005ae0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005ae4:	21c48513          	addi	a0,s1,540
    80005ae8:	ffffd097          	auipc	ra,0xffffd
    80005aec:	0b0080e7          	jalr	176(ra) # 80002b98 <wakeup>
    80005af0:	b7e9                	j	80005aba <pipeclose+0x2c>
    release(&pi->lock);
    80005af2:	8526                	mv	a0,s1
    80005af4:	ffffb097          	auipc	ra,0xffffb
    80005af8:	1a2080e7          	jalr	418(ra) # 80000c96 <release>
}
    80005afc:	bfe1                	j	80005ad4 <pipeclose+0x46>

0000000080005afe <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005afe:	7159                	addi	sp,sp,-112
    80005b00:	f486                	sd	ra,104(sp)
    80005b02:	f0a2                	sd	s0,96(sp)
    80005b04:	eca6                	sd	s1,88(sp)
    80005b06:	e8ca                	sd	s2,80(sp)
    80005b08:	e4ce                	sd	s3,72(sp)
    80005b0a:	e0d2                	sd	s4,64(sp)
    80005b0c:	fc56                	sd	s5,56(sp)
    80005b0e:	f85a                	sd	s6,48(sp)
    80005b10:	f45e                	sd	s7,40(sp)
    80005b12:	f062                	sd	s8,32(sp)
    80005b14:	ec66                	sd	s9,24(sp)
    80005b16:	1880                	addi	s0,sp,112
    80005b18:	84aa                	mv	s1,a0
    80005b1a:	8aae                	mv	s5,a1
    80005b1c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005b1e:	ffffc097          	auipc	ra,0xffffc
    80005b22:	e90080e7          	jalr	-368(ra) # 800019ae <myproc>
    80005b26:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005b28:	8526                	mv	a0,s1
    80005b2a:	ffffb097          	auipc	ra,0xffffb
    80005b2e:	0b8080e7          	jalr	184(ra) # 80000be2 <acquire>
  while(i < n){
    80005b32:	0d405163          	blez	s4,80005bf4 <pipewrite+0xf6>
    80005b36:	8ba6                	mv	s7,s1
  int i = 0;
    80005b38:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005b3a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005b3c:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005b40:	21c48c13          	addi	s8,s1,540
    80005b44:	a08d                	j	80005ba6 <pipewrite+0xa8>
      release(&pi->lock);
    80005b46:	8526                	mv	a0,s1
    80005b48:	ffffb097          	auipc	ra,0xffffb
    80005b4c:	14e080e7          	jalr	334(ra) # 80000c96 <release>
      return -1;
    80005b50:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005b52:	854a                	mv	a0,s2
    80005b54:	70a6                	ld	ra,104(sp)
    80005b56:	7406                	ld	s0,96(sp)
    80005b58:	64e6                	ld	s1,88(sp)
    80005b5a:	6946                	ld	s2,80(sp)
    80005b5c:	69a6                	ld	s3,72(sp)
    80005b5e:	6a06                	ld	s4,64(sp)
    80005b60:	7ae2                	ld	s5,56(sp)
    80005b62:	7b42                	ld	s6,48(sp)
    80005b64:	7ba2                	ld	s7,40(sp)
    80005b66:	7c02                	ld	s8,32(sp)
    80005b68:	6ce2                	ld	s9,24(sp)
    80005b6a:	6165                	addi	sp,sp,112
    80005b6c:	8082                	ret
      wakeup(&pi->nread);
    80005b6e:	8566                	mv	a0,s9
    80005b70:	ffffd097          	auipc	ra,0xffffd
    80005b74:	028080e7          	jalr	40(ra) # 80002b98 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005b78:	85de                	mv	a1,s7
    80005b7a:	8562                	mv	a0,s8
    80005b7c:	ffffd097          	auipc	ra,0xffffd
    80005b80:	b7a080e7          	jalr	-1158(ra) # 800026f6 <sleep>
    80005b84:	a839                	j	80005ba2 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005b86:	21c4a783          	lw	a5,540(s1)
    80005b8a:	0017871b          	addiw	a4,a5,1
    80005b8e:	20e4ae23          	sw	a4,540(s1)
    80005b92:	1ff7f793          	andi	a5,a5,511
    80005b96:	97a6                	add	a5,a5,s1
    80005b98:	f9f44703          	lbu	a4,-97(s0)
    80005b9c:	00e78c23          	sb	a4,24(a5)
      i++;
    80005ba0:	2905                	addiw	s2,s2,1
  while(i < n){
    80005ba2:	03495d63          	bge	s2,s4,80005bdc <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80005ba6:	2204a783          	lw	a5,544(s1)
    80005baa:	dfd1                	beqz	a5,80005b46 <pipewrite+0x48>
    80005bac:	0289a783          	lw	a5,40(s3)
    80005bb0:	fbd9                	bnez	a5,80005b46 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005bb2:	2184a783          	lw	a5,536(s1)
    80005bb6:	21c4a703          	lw	a4,540(s1)
    80005bba:	2007879b          	addiw	a5,a5,512
    80005bbe:	faf708e3          	beq	a4,a5,80005b6e <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005bc2:	4685                	li	a3,1
    80005bc4:	01590633          	add	a2,s2,s5
    80005bc8:	f9f40593          	addi	a1,s0,-97
    80005bcc:	0509b503          	ld	a0,80(s3)
    80005bd0:	ffffc097          	auipc	ra,0xffffc
    80005bd4:	b2c080e7          	jalr	-1236(ra) # 800016fc <copyin>
    80005bd8:	fb6517e3          	bne	a0,s6,80005b86 <pipewrite+0x88>
  wakeup(&pi->nread);
    80005bdc:	21848513          	addi	a0,s1,536
    80005be0:	ffffd097          	auipc	ra,0xffffd
    80005be4:	fb8080e7          	jalr	-72(ra) # 80002b98 <wakeup>
  release(&pi->lock);
    80005be8:	8526                	mv	a0,s1
    80005bea:	ffffb097          	auipc	ra,0xffffb
    80005bee:	0ac080e7          	jalr	172(ra) # 80000c96 <release>
  return i;
    80005bf2:	b785                	j	80005b52 <pipewrite+0x54>
  int i = 0;
    80005bf4:	4901                	li	s2,0
    80005bf6:	b7dd                	j	80005bdc <pipewrite+0xde>

0000000080005bf8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005bf8:	715d                	addi	sp,sp,-80
    80005bfa:	e486                	sd	ra,72(sp)
    80005bfc:	e0a2                	sd	s0,64(sp)
    80005bfe:	fc26                	sd	s1,56(sp)
    80005c00:	f84a                	sd	s2,48(sp)
    80005c02:	f44e                	sd	s3,40(sp)
    80005c04:	f052                	sd	s4,32(sp)
    80005c06:	ec56                	sd	s5,24(sp)
    80005c08:	e85a                	sd	s6,16(sp)
    80005c0a:	0880                	addi	s0,sp,80
    80005c0c:	84aa                	mv	s1,a0
    80005c0e:	892e                	mv	s2,a1
    80005c10:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005c12:	ffffc097          	auipc	ra,0xffffc
    80005c16:	d9c080e7          	jalr	-612(ra) # 800019ae <myproc>
    80005c1a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005c1c:	8b26                	mv	s6,s1
    80005c1e:	8526                	mv	a0,s1
    80005c20:	ffffb097          	auipc	ra,0xffffb
    80005c24:	fc2080e7          	jalr	-62(ra) # 80000be2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005c28:	2184a703          	lw	a4,536(s1)
    80005c2c:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005c30:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005c34:	02f71463          	bne	a4,a5,80005c5c <piperead+0x64>
    80005c38:	2244a783          	lw	a5,548(s1)
    80005c3c:	c385                	beqz	a5,80005c5c <piperead+0x64>
    if(pr->killed){
    80005c3e:	028a2783          	lw	a5,40(s4)
    80005c42:	ebc1                	bnez	a5,80005cd2 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005c44:	85da                	mv	a1,s6
    80005c46:	854e                	mv	a0,s3
    80005c48:	ffffd097          	auipc	ra,0xffffd
    80005c4c:	aae080e7          	jalr	-1362(ra) # 800026f6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005c50:	2184a703          	lw	a4,536(s1)
    80005c54:	21c4a783          	lw	a5,540(s1)
    80005c58:	fef700e3          	beq	a4,a5,80005c38 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005c5c:	09505263          	blez	s5,80005ce0 <piperead+0xe8>
    80005c60:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005c62:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80005c64:	2184a783          	lw	a5,536(s1)
    80005c68:	21c4a703          	lw	a4,540(s1)
    80005c6c:	02f70d63          	beq	a4,a5,80005ca6 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005c70:	0017871b          	addiw	a4,a5,1
    80005c74:	20e4ac23          	sw	a4,536(s1)
    80005c78:	1ff7f793          	andi	a5,a5,511
    80005c7c:	97a6                	add	a5,a5,s1
    80005c7e:	0187c783          	lbu	a5,24(a5)
    80005c82:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005c86:	4685                	li	a3,1
    80005c88:	fbf40613          	addi	a2,s0,-65
    80005c8c:	85ca                	mv	a1,s2
    80005c8e:	050a3503          	ld	a0,80(s4)
    80005c92:	ffffc097          	auipc	ra,0xffffc
    80005c96:	9de080e7          	jalr	-1570(ra) # 80001670 <copyout>
    80005c9a:	01650663          	beq	a0,s6,80005ca6 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005c9e:	2985                	addiw	s3,s3,1
    80005ca0:	0905                	addi	s2,s2,1
    80005ca2:	fd3a91e3          	bne	s5,s3,80005c64 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005ca6:	21c48513          	addi	a0,s1,540
    80005caa:	ffffd097          	auipc	ra,0xffffd
    80005cae:	eee080e7          	jalr	-274(ra) # 80002b98 <wakeup>
  release(&pi->lock);
    80005cb2:	8526                	mv	a0,s1
    80005cb4:	ffffb097          	auipc	ra,0xffffb
    80005cb8:	fe2080e7          	jalr	-30(ra) # 80000c96 <release>
  return i;
}
    80005cbc:	854e                	mv	a0,s3
    80005cbe:	60a6                	ld	ra,72(sp)
    80005cc0:	6406                	ld	s0,64(sp)
    80005cc2:	74e2                	ld	s1,56(sp)
    80005cc4:	7942                	ld	s2,48(sp)
    80005cc6:	79a2                	ld	s3,40(sp)
    80005cc8:	7a02                	ld	s4,32(sp)
    80005cca:	6ae2                	ld	s5,24(sp)
    80005ccc:	6b42                	ld	s6,16(sp)
    80005cce:	6161                	addi	sp,sp,80
    80005cd0:	8082                	ret
      release(&pi->lock);
    80005cd2:	8526                	mv	a0,s1
    80005cd4:	ffffb097          	auipc	ra,0xffffb
    80005cd8:	fc2080e7          	jalr	-62(ra) # 80000c96 <release>
      return -1;
    80005cdc:	59fd                	li	s3,-1
    80005cde:	bff9                	j	80005cbc <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005ce0:	4981                	li	s3,0
    80005ce2:	b7d1                	j	80005ca6 <piperead+0xae>

0000000080005ce4 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005ce4:	df010113          	addi	sp,sp,-528
    80005ce8:	20113423          	sd	ra,520(sp)
    80005cec:	20813023          	sd	s0,512(sp)
    80005cf0:	ffa6                	sd	s1,504(sp)
    80005cf2:	fbca                	sd	s2,496(sp)
    80005cf4:	f7ce                	sd	s3,488(sp)
    80005cf6:	f3d2                	sd	s4,480(sp)
    80005cf8:	efd6                	sd	s5,472(sp)
    80005cfa:	ebda                	sd	s6,464(sp)
    80005cfc:	e7de                	sd	s7,456(sp)
    80005cfe:	e3e2                	sd	s8,448(sp)
    80005d00:	ff66                	sd	s9,440(sp)
    80005d02:	fb6a                	sd	s10,432(sp)
    80005d04:	f76e                	sd	s11,424(sp)
    80005d06:	0c00                	addi	s0,sp,528
    80005d08:	84aa                	mv	s1,a0
    80005d0a:	dea43c23          	sd	a0,-520(s0)
    80005d0e:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005d12:	ffffc097          	auipc	ra,0xffffc
    80005d16:	c9c080e7          	jalr	-868(ra) # 800019ae <myproc>
    80005d1a:	892a                	mv	s2,a0

  begin_op();
    80005d1c:	fffff097          	auipc	ra,0xfffff
    80005d20:	49c080e7          	jalr	1180(ra) # 800051b8 <begin_op>

  if((ip = namei(path)) == 0){
    80005d24:	8526                	mv	a0,s1
    80005d26:	fffff097          	auipc	ra,0xfffff
    80005d2a:	276080e7          	jalr	630(ra) # 80004f9c <namei>
    80005d2e:	c92d                	beqz	a0,80005da0 <exec+0xbc>
    80005d30:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005d32:	fffff097          	auipc	ra,0xfffff
    80005d36:	ab4080e7          	jalr	-1356(ra) # 800047e6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005d3a:	04000713          	li	a4,64
    80005d3e:	4681                	li	a3,0
    80005d40:	e5040613          	addi	a2,s0,-432
    80005d44:	4581                	li	a1,0
    80005d46:	8526                	mv	a0,s1
    80005d48:	fffff097          	auipc	ra,0xfffff
    80005d4c:	d52080e7          	jalr	-686(ra) # 80004a9a <readi>
    80005d50:	04000793          	li	a5,64
    80005d54:	00f51a63          	bne	a0,a5,80005d68 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005d58:	e5042703          	lw	a4,-432(s0)
    80005d5c:	464c47b7          	lui	a5,0x464c4
    80005d60:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005d64:	04f70463          	beq	a4,a5,80005dac <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005d68:	8526                	mv	a0,s1
    80005d6a:	fffff097          	auipc	ra,0xfffff
    80005d6e:	cde080e7          	jalr	-802(ra) # 80004a48 <iunlockput>
    end_op();
    80005d72:	fffff097          	auipc	ra,0xfffff
    80005d76:	4c6080e7          	jalr	1222(ra) # 80005238 <end_op>
  }
  return -1;
    80005d7a:	557d                	li	a0,-1
}
    80005d7c:	20813083          	ld	ra,520(sp)
    80005d80:	20013403          	ld	s0,512(sp)
    80005d84:	74fe                	ld	s1,504(sp)
    80005d86:	795e                	ld	s2,496(sp)
    80005d88:	79be                	ld	s3,488(sp)
    80005d8a:	7a1e                	ld	s4,480(sp)
    80005d8c:	6afe                	ld	s5,472(sp)
    80005d8e:	6b5e                	ld	s6,464(sp)
    80005d90:	6bbe                	ld	s7,456(sp)
    80005d92:	6c1e                	ld	s8,448(sp)
    80005d94:	7cfa                	ld	s9,440(sp)
    80005d96:	7d5a                	ld	s10,432(sp)
    80005d98:	7dba                	ld	s11,424(sp)
    80005d9a:	21010113          	addi	sp,sp,528
    80005d9e:	8082                	ret
    end_op();
    80005da0:	fffff097          	auipc	ra,0xfffff
    80005da4:	498080e7          	jalr	1176(ra) # 80005238 <end_op>
    return -1;
    80005da8:	557d                	li	a0,-1
    80005daa:	bfc9                	j	80005d7c <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80005dac:	854a                	mv	a0,s2
    80005dae:	ffffc097          	auipc	ra,0xffffc
    80005db2:	cfc080e7          	jalr	-772(ra) # 80001aaa <proc_pagetable>
    80005db6:	8baa                	mv	s7,a0
    80005db8:	d945                	beqz	a0,80005d68 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005dba:	e7042983          	lw	s3,-400(s0)
    80005dbe:	e8845783          	lhu	a5,-376(s0)
    80005dc2:	c7ad                	beqz	a5,80005e2c <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005dc4:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005dc6:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    80005dc8:	6c85                	lui	s9,0x1
    80005dca:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005dce:	def43823          	sd	a5,-528(s0)
    80005dd2:	a42d                	j	80005ffc <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005dd4:	00004517          	auipc	a0,0x4
    80005dd8:	b4c50513          	addi	a0,a0,-1204 # 80009920 <syscalls+0x2e0>
    80005ddc:	ffffa097          	auipc	ra,0xffffa
    80005de0:	760080e7          	jalr	1888(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005de4:	8756                	mv	a4,s5
    80005de6:	012d86bb          	addw	a3,s11,s2
    80005dea:	4581                	li	a1,0
    80005dec:	8526                	mv	a0,s1
    80005dee:	fffff097          	auipc	ra,0xfffff
    80005df2:	cac080e7          	jalr	-852(ra) # 80004a9a <readi>
    80005df6:	2501                	sext.w	a0,a0
    80005df8:	1aaa9963          	bne	s5,a0,80005faa <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80005dfc:	6785                	lui	a5,0x1
    80005dfe:	0127893b          	addw	s2,a5,s2
    80005e02:	77fd                	lui	a5,0xfffff
    80005e04:	01478a3b          	addw	s4,a5,s4
    80005e08:	1f897163          	bgeu	s2,s8,80005fea <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80005e0c:	02091593          	slli	a1,s2,0x20
    80005e10:	9181                	srli	a1,a1,0x20
    80005e12:	95ea                	add	a1,a1,s10
    80005e14:	855e                	mv	a0,s7
    80005e16:	ffffb097          	auipc	ra,0xffffb
    80005e1a:	256080e7          	jalr	598(ra) # 8000106c <walkaddr>
    80005e1e:	862a                	mv	a2,a0
    if(pa == 0)
    80005e20:	d955                	beqz	a0,80005dd4 <exec+0xf0>
      n = PGSIZE;
    80005e22:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005e24:	fd9a70e3          	bgeu	s4,s9,80005de4 <exec+0x100>
      n = sz - i;
    80005e28:	8ad2                	mv	s5,s4
    80005e2a:	bf6d                	j	80005de4 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005e2c:	4901                	li	s2,0
  iunlockput(ip);
    80005e2e:	8526                	mv	a0,s1
    80005e30:	fffff097          	auipc	ra,0xfffff
    80005e34:	c18080e7          	jalr	-1000(ra) # 80004a48 <iunlockput>
  end_op();
    80005e38:	fffff097          	auipc	ra,0xfffff
    80005e3c:	400080e7          	jalr	1024(ra) # 80005238 <end_op>
  p = myproc();
    80005e40:	ffffc097          	auipc	ra,0xffffc
    80005e44:	b6e080e7          	jalr	-1170(ra) # 800019ae <myproc>
    80005e48:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005e4a:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005e4e:	6785                	lui	a5,0x1
    80005e50:	17fd                	addi	a5,a5,-1
    80005e52:	993e                	add	s2,s2,a5
    80005e54:	757d                	lui	a0,0xfffff
    80005e56:	00a977b3          	and	a5,s2,a0
    80005e5a:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005e5e:	6609                	lui	a2,0x2
    80005e60:	963e                	add	a2,a2,a5
    80005e62:	85be                	mv	a1,a5
    80005e64:	855e                	mv	a0,s7
    80005e66:	ffffb097          	auipc	ra,0xffffb
    80005e6a:	5ba080e7          	jalr	1466(ra) # 80001420 <uvmalloc>
    80005e6e:	8b2a                	mv	s6,a0
  ip = 0;
    80005e70:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005e72:	12050c63          	beqz	a0,80005faa <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005e76:	75f9                	lui	a1,0xffffe
    80005e78:	95aa                	add	a1,a1,a0
    80005e7a:	855e                	mv	a0,s7
    80005e7c:	ffffb097          	auipc	ra,0xffffb
    80005e80:	7c2080e7          	jalr	1986(ra) # 8000163e <uvmclear>
  stackbase = sp - PGSIZE;
    80005e84:	7c7d                	lui	s8,0xfffff
    80005e86:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80005e88:	e0043783          	ld	a5,-512(s0)
    80005e8c:	6388                	ld	a0,0(a5)
    80005e8e:	c535                	beqz	a0,80005efa <exec+0x216>
    80005e90:	e9040993          	addi	s3,s0,-368
    80005e94:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005e98:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005e9a:	ffffb097          	auipc	ra,0xffffb
    80005e9e:	fc8080e7          	jalr	-56(ra) # 80000e62 <strlen>
    80005ea2:	2505                	addiw	a0,a0,1
    80005ea4:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005ea8:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005eac:	13896363          	bltu	s2,s8,80005fd2 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005eb0:	e0043d83          	ld	s11,-512(s0)
    80005eb4:	000dba03          	ld	s4,0(s11)
    80005eb8:	8552                	mv	a0,s4
    80005eba:	ffffb097          	auipc	ra,0xffffb
    80005ebe:	fa8080e7          	jalr	-88(ra) # 80000e62 <strlen>
    80005ec2:	0015069b          	addiw	a3,a0,1
    80005ec6:	8652                	mv	a2,s4
    80005ec8:	85ca                	mv	a1,s2
    80005eca:	855e                	mv	a0,s7
    80005ecc:	ffffb097          	auipc	ra,0xffffb
    80005ed0:	7a4080e7          	jalr	1956(ra) # 80001670 <copyout>
    80005ed4:	10054363          	bltz	a0,80005fda <exec+0x2f6>
    ustack[argc] = sp;
    80005ed8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005edc:	0485                	addi	s1,s1,1
    80005ede:	008d8793          	addi	a5,s11,8
    80005ee2:	e0f43023          	sd	a5,-512(s0)
    80005ee6:	008db503          	ld	a0,8(s11)
    80005eea:	c911                	beqz	a0,80005efe <exec+0x21a>
    if(argc >= MAXARG)
    80005eec:	09a1                	addi	s3,s3,8
    80005eee:	fb3c96e3          	bne	s9,s3,80005e9a <exec+0x1b6>
  sz = sz1;
    80005ef2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005ef6:	4481                	li	s1,0
    80005ef8:	a84d                	j	80005faa <exec+0x2c6>
  sp = sz;
    80005efa:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005efc:	4481                	li	s1,0
  ustack[argc] = 0;
    80005efe:	00349793          	slli	a5,s1,0x3
    80005f02:	f9040713          	addi	a4,s0,-112
    80005f06:	97ba                	add	a5,a5,a4
    80005f08:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005f0c:	00148693          	addi	a3,s1,1
    80005f10:	068e                	slli	a3,a3,0x3
    80005f12:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005f16:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005f1a:	01897663          	bgeu	s2,s8,80005f26 <exec+0x242>
  sz = sz1;
    80005f1e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005f22:	4481                	li	s1,0
    80005f24:	a059                	j	80005faa <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005f26:	e9040613          	addi	a2,s0,-368
    80005f2a:	85ca                	mv	a1,s2
    80005f2c:	855e                	mv	a0,s7
    80005f2e:	ffffb097          	auipc	ra,0xffffb
    80005f32:	742080e7          	jalr	1858(ra) # 80001670 <copyout>
    80005f36:	0a054663          	bltz	a0,80005fe2 <exec+0x2fe>
  p->trapframe->a1 = sp;
    80005f3a:	058ab783          	ld	a5,88(s5)
    80005f3e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005f42:	df843783          	ld	a5,-520(s0)
    80005f46:	0007c703          	lbu	a4,0(a5)
    80005f4a:	cf11                	beqz	a4,80005f66 <exec+0x282>
    80005f4c:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005f4e:	02f00693          	li	a3,47
    80005f52:	a039                	j	80005f60 <exec+0x27c>
      last = s+1;
    80005f54:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005f58:	0785                	addi	a5,a5,1
    80005f5a:	fff7c703          	lbu	a4,-1(a5)
    80005f5e:	c701                	beqz	a4,80005f66 <exec+0x282>
    if(*s == '/')
    80005f60:	fed71ce3          	bne	a4,a3,80005f58 <exec+0x274>
    80005f64:	bfc5                	j	80005f54 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80005f66:	4641                	li	a2,16
    80005f68:	df843583          	ld	a1,-520(s0)
    80005f6c:	158a8513          	addi	a0,s5,344
    80005f70:	ffffb097          	auipc	ra,0xffffb
    80005f74:	ec0080e7          	jalr	-320(ra) # 80000e30 <safestrcpy>
  oldpagetable = p->pagetable;
    80005f78:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005f7c:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80005f80:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005f84:	058ab783          	ld	a5,88(s5)
    80005f88:	e6843703          	ld	a4,-408(s0)
    80005f8c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005f8e:	058ab783          	ld	a5,88(s5)
    80005f92:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005f96:	85ea                	mv	a1,s10
    80005f98:	ffffc097          	auipc	ra,0xffffc
    80005f9c:	bae080e7          	jalr	-1106(ra) # 80001b46 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005fa0:	0004851b          	sext.w	a0,s1
    80005fa4:	bbe1                	j	80005d7c <exec+0x98>
    80005fa6:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005faa:	e0843583          	ld	a1,-504(s0)
    80005fae:	855e                	mv	a0,s7
    80005fb0:	ffffc097          	auipc	ra,0xffffc
    80005fb4:	b96080e7          	jalr	-1130(ra) # 80001b46 <proc_freepagetable>
  if(ip){
    80005fb8:	da0498e3          	bnez	s1,80005d68 <exec+0x84>
  return -1;
    80005fbc:	557d                	li	a0,-1
    80005fbe:	bb7d                	j	80005d7c <exec+0x98>
    80005fc0:	e1243423          	sd	s2,-504(s0)
    80005fc4:	b7dd                	j	80005faa <exec+0x2c6>
    80005fc6:	e1243423          	sd	s2,-504(s0)
    80005fca:	b7c5                	j	80005faa <exec+0x2c6>
    80005fcc:	e1243423          	sd	s2,-504(s0)
    80005fd0:	bfe9                	j	80005faa <exec+0x2c6>
  sz = sz1;
    80005fd2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005fd6:	4481                	li	s1,0
    80005fd8:	bfc9                	j	80005faa <exec+0x2c6>
  sz = sz1;
    80005fda:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005fde:	4481                	li	s1,0
    80005fe0:	b7e9                	j	80005faa <exec+0x2c6>
  sz = sz1;
    80005fe2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005fe6:	4481                	li	s1,0
    80005fe8:	b7c9                	j	80005faa <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005fea:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005fee:	2b05                	addiw	s6,s6,1
    80005ff0:	0389899b          	addiw	s3,s3,56
    80005ff4:	e8845783          	lhu	a5,-376(s0)
    80005ff8:	e2fb5be3          	bge	s6,a5,80005e2e <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005ffc:	2981                	sext.w	s3,s3
    80005ffe:	03800713          	li	a4,56
    80006002:	86ce                	mv	a3,s3
    80006004:	e1840613          	addi	a2,s0,-488
    80006008:	4581                	li	a1,0
    8000600a:	8526                	mv	a0,s1
    8000600c:	fffff097          	auipc	ra,0xfffff
    80006010:	a8e080e7          	jalr	-1394(ra) # 80004a9a <readi>
    80006014:	03800793          	li	a5,56
    80006018:	f8f517e3          	bne	a0,a5,80005fa6 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    8000601c:	e1842783          	lw	a5,-488(s0)
    80006020:	4705                	li	a4,1
    80006022:	fce796e3          	bne	a5,a4,80005fee <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80006026:	e4043603          	ld	a2,-448(s0)
    8000602a:	e3843783          	ld	a5,-456(s0)
    8000602e:	f8f669e3          	bltu	a2,a5,80005fc0 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80006032:	e2843783          	ld	a5,-472(s0)
    80006036:	963e                	add	a2,a2,a5
    80006038:	f8f667e3          	bltu	a2,a5,80005fc6 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000603c:	85ca                	mv	a1,s2
    8000603e:	855e                	mv	a0,s7
    80006040:	ffffb097          	auipc	ra,0xffffb
    80006044:	3e0080e7          	jalr	992(ra) # 80001420 <uvmalloc>
    80006048:	e0a43423          	sd	a0,-504(s0)
    8000604c:	d141                	beqz	a0,80005fcc <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    8000604e:	e2843d03          	ld	s10,-472(s0)
    80006052:	df043783          	ld	a5,-528(s0)
    80006056:	00fd77b3          	and	a5,s10,a5
    8000605a:	fba1                	bnez	a5,80005faa <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000605c:	e2042d83          	lw	s11,-480(s0)
    80006060:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80006064:	f80c03e3          	beqz	s8,80005fea <exec+0x306>
    80006068:	8a62                	mv	s4,s8
    8000606a:	4901                	li	s2,0
    8000606c:	b345                	j	80005e0c <exec+0x128>

000000008000606e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000606e:	7179                	addi	sp,sp,-48
    80006070:	f406                	sd	ra,40(sp)
    80006072:	f022                	sd	s0,32(sp)
    80006074:	ec26                	sd	s1,24(sp)
    80006076:	e84a                	sd	s2,16(sp)
    80006078:	1800                	addi	s0,sp,48
    8000607a:	892e                	mv	s2,a1
    8000607c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000607e:	fdc40593          	addi	a1,s0,-36
    80006082:	ffffe097          	auipc	ra,0xffffe
    80006086:	9de080e7          	jalr	-1570(ra) # 80003a60 <argint>
    8000608a:	04054063          	bltz	a0,800060ca <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000608e:	fdc42703          	lw	a4,-36(s0)
    80006092:	47bd                	li	a5,15
    80006094:	02e7ed63          	bltu	a5,a4,800060ce <argfd+0x60>
    80006098:	ffffc097          	auipc	ra,0xffffc
    8000609c:	916080e7          	jalr	-1770(ra) # 800019ae <myproc>
    800060a0:	fdc42703          	lw	a4,-36(s0)
    800060a4:	01a70793          	addi	a5,a4,26
    800060a8:	078e                	slli	a5,a5,0x3
    800060aa:	953e                	add	a0,a0,a5
    800060ac:	611c                	ld	a5,0(a0)
    800060ae:	c395                	beqz	a5,800060d2 <argfd+0x64>
    return -1;
  if(pfd)
    800060b0:	00090463          	beqz	s2,800060b8 <argfd+0x4a>
    *pfd = fd;
    800060b4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800060b8:	4501                	li	a0,0
  if(pf)
    800060ba:	c091                	beqz	s1,800060be <argfd+0x50>
    *pf = f;
    800060bc:	e09c                	sd	a5,0(s1)
}
    800060be:	70a2                	ld	ra,40(sp)
    800060c0:	7402                	ld	s0,32(sp)
    800060c2:	64e2                	ld	s1,24(sp)
    800060c4:	6942                	ld	s2,16(sp)
    800060c6:	6145                	addi	sp,sp,48
    800060c8:	8082                	ret
    return -1;
    800060ca:	557d                	li	a0,-1
    800060cc:	bfcd                	j	800060be <argfd+0x50>
    return -1;
    800060ce:	557d                	li	a0,-1
    800060d0:	b7fd                	j	800060be <argfd+0x50>
    800060d2:	557d                	li	a0,-1
    800060d4:	b7ed                	j	800060be <argfd+0x50>

00000000800060d6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800060d6:	1101                	addi	sp,sp,-32
    800060d8:	ec06                	sd	ra,24(sp)
    800060da:	e822                	sd	s0,16(sp)
    800060dc:	e426                	sd	s1,8(sp)
    800060de:	1000                	addi	s0,sp,32
    800060e0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800060e2:	ffffc097          	auipc	ra,0xffffc
    800060e6:	8cc080e7          	jalr	-1844(ra) # 800019ae <myproc>
    800060ea:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800060ec:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd80d0>
    800060f0:	4501                	li	a0,0
    800060f2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800060f4:	6398                	ld	a4,0(a5)
    800060f6:	cb19                	beqz	a4,8000610c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800060f8:	2505                	addiw	a0,a0,1
    800060fa:	07a1                	addi	a5,a5,8
    800060fc:	fed51ce3          	bne	a0,a3,800060f4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80006100:	557d                	li	a0,-1
}
    80006102:	60e2                	ld	ra,24(sp)
    80006104:	6442                	ld	s0,16(sp)
    80006106:	64a2                	ld	s1,8(sp)
    80006108:	6105                	addi	sp,sp,32
    8000610a:	8082                	ret
      p->ofile[fd] = f;
    8000610c:	01a50793          	addi	a5,a0,26
    80006110:	078e                	slli	a5,a5,0x3
    80006112:	963e                	add	a2,a2,a5
    80006114:	e204                	sd	s1,0(a2)
      return fd;
    80006116:	b7f5                	j	80006102 <fdalloc+0x2c>

0000000080006118 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80006118:	715d                	addi	sp,sp,-80
    8000611a:	e486                	sd	ra,72(sp)
    8000611c:	e0a2                	sd	s0,64(sp)
    8000611e:	fc26                	sd	s1,56(sp)
    80006120:	f84a                	sd	s2,48(sp)
    80006122:	f44e                	sd	s3,40(sp)
    80006124:	f052                	sd	s4,32(sp)
    80006126:	ec56                	sd	s5,24(sp)
    80006128:	0880                	addi	s0,sp,80
    8000612a:	89ae                	mv	s3,a1
    8000612c:	8ab2                	mv	s5,a2
    8000612e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80006130:	fb040593          	addi	a1,s0,-80
    80006134:	fffff097          	auipc	ra,0xfffff
    80006138:	e86080e7          	jalr	-378(ra) # 80004fba <nameiparent>
    8000613c:	892a                	mv	s2,a0
    8000613e:	12050f63          	beqz	a0,8000627c <create+0x164>
    return 0;

  ilock(dp);
    80006142:	ffffe097          	auipc	ra,0xffffe
    80006146:	6a4080e7          	jalr	1700(ra) # 800047e6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000614a:	4601                	li	a2,0
    8000614c:	fb040593          	addi	a1,s0,-80
    80006150:	854a                	mv	a0,s2
    80006152:	fffff097          	auipc	ra,0xfffff
    80006156:	b78080e7          	jalr	-1160(ra) # 80004cca <dirlookup>
    8000615a:	84aa                	mv	s1,a0
    8000615c:	c921                	beqz	a0,800061ac <create+0x94>
    iunlockput(dp);
    8000615e:	854a                	mv	a0,s2
    80006160:	fffff097          	auipc	ra,0xfffff
    80006164:	8e8080e7          	jalr	-1816(ra) # 80004a48 <iunlockput>
    ilock(ip);
    80006168:	8526                	mv	a0,s1
    8000616a:	ffffe097          	auipc	ra,0xffffe
    8000616e:	67c080e7          	jalr	1660(ra) # 800047e6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006172:	2981                	sext.w	s3,s3
    80006174:	4789                	li	a5,2
    80006176:	02f99463          	bne	s3,a5,8000619e <create+0x86>
    8000617a:	0444d783          	lhu	a5,68(s1)
    8000617e:	37f9                	addiw	a5,a5,-2
    80006180:	17c2                	slli	a5,a5,0x30
    80006182:	93c1                	srli	a5,a5,0x30
    80006184:	4705                	li	a4,1
    80006186:	00f76c63          	bltu	a4,a5,8000619e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000618a:	8526                	mv	a0,s1
    8000618c:	60a6                	ld	ra,72(sp)
    8000618e:	6406                	ld	s0,64(sp)
    80006190:	74e2                	ld	s1,56(sp)
    80006192:	7942                	ld	s2,48(sp)
    80006194:	79a2                	ld	s3,40(sp)
    80006196:	7a02                	ld	s4,32(sp)
    80006198:	6ae2                	ld	s5,24(sp)
    8000619a:	6161                	addi	sp,sp,80
    8000619c:	8082                	ret
    iunlockput(ip);
    8000619e:	8526                	mv	a0,s1
    800061a0:	fffff097          	auipc	ra,0xfffff
    800061a4:	8a8080e7          	jalr	-1880(ra) # 80004a48 <iunlockput>
    return 0;
    800061a8:	4481                	li	s1,0
    800061aa:	b7c5                	j	8000618a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800061ac:	85ce                	mv	a1,s3
    800061ae:	00092503          	lw	a0,0(s2)
    800061b2:	ffffe097          	auipc	ra,0xffffe
    800061b6:	49c080e7          	jalr	1180(ra) # 8000464e <ialloc>
    800061ba:	84aa                	mv	s1,a0
    800061bc:	c529                	beqz	a0,80006206 <create+0xee>
  ilock(ip);
    800061be:	ffffe097          	auipc	ra,0xffffe
    800061c2:	628080e7          	jalr	1576(ra) # 800047e6 <ilock>
  ip->major = major;
    800061c6:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800061ca:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800061ce:	4785                	li	a5,1
    800061d0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800061d4:	8526                	mv	a0,s1
    800061d6:	ffffe097          	auipc	ra,0xffffe
    800061da:	546080e7          	jalr	1350(ra) # 8000471c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800061de:	2981                	sext.w	s3,s3
    800061e0:	4785                	li	a5,1
    800061e2:	02f98a63          	beq	s3,a5,80006216 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800061e6:	40d0                	lw	a2,4(s1)
    800061e8:	fb040593          	addi	a1,s0,-80
    800061ec:	854a                	mv	a0,s2
    800061ee:	fffff097          	auipc	ra,0xfffff
    800061f2:	cec080e7          	jalr	-788(ra) # 80004eda <dirlink>
    800061f6:	06054b63          	bltz	a0,8000626c <create+0x154>
  iunlockput(dp);
    800061fa:	854a                	mv	a0,s2
    800061fc:	fffff097          	auipc	ra,0xfffff
    80006200:	84c080e7          	jalr	-1972(ra) # 80004a48 <iunlockput>
  return ip;
    80006204:	b759                	j	8000618a <create+0x72>
    panic("create: ialloc");
    80006206:	00003517          	auipc	a0,0x3
    8000620a:	73a50513          	addi	a0,a0,1850 # 80009940 <syscalls+0x300>
    8000620e:	ffffa097          	auipc	ra,0xffffa
    80006212:	32e080e7          	jalr	814(ra) # 8000053c <panic>
    dp->nlink++;  // for ".."
    80006216:	04a95783          	lhu	a5,74(s2)
    8000621a:	2785                	addiw	a5,a5,1
    8000621c:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006220:	854a                	mv	a0,s2
    80006222:	ffffe097          	auipc	ra,0xffffe
    80006226:	4fa080e7          	jalr	1274(ra) # 8000471c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000622a:	40d0                	lw	a2,4(s1)
    8000622c:	00003597          	auipc	a1,0x3
    80006230:	72458593          	addi	a1,a1,1828 # 80009950 <syscalls+0x310>
    80006234:	8526                	mv	a0,s1
    80006236:	fffff097          	auipc	ra,0xfffff
    8000623a:	ca4080e7          	jalr	-860(ra) # 80004eda <dirlink>
    8000623e:	00054f63          	bltz	a0,8000625c <create+0x144>
    80006242:	00492603          	lw	a2,4(s2)
    80006246:	00003597          	auipc	a1,0x3
    8000624a:	71258593          	addi	a1,a1,1810 # 80009958 <syscalls+0x318>
    8000624e:	8526                	mv	a0,s1
    80006250:	fffff097          	auipc	ra,0xfffff
    80006254:	c8a080e7          	jalr	-886(ra) # 80004eda <dirlink>
    80006258:	f80557e3          	bgez	a0,800061e6 <create+0xce>
      panic("create dots");
    8000625c:	00003517          	auipc	a0,0x3
    80006260:	70450513          	addi	a0,a0,1796 # 80009960 <syscalls+0x320>
    80006264:	ffffa097          	auipc	ra,0xffffa
    80006268:	2d8080e7          	jalr	728(ra) # 8000053c <panic>
    panic("create: dirlink");
    8000626c:	00003517          	auipc	a0,0x3
    80006270:	70450513          	addi	a0,a0,1796 # 80009970 <syscalls+0x330>
    80006274:	ffffa097          	auipc	ra,0xffffa
    80006278:	2c8080e7          	jalr	712(ra) # 8000053c <panic>
    return 0;
    8000627c:	84aa                	mv	s1,a0
    8000627e:	b731                	j	8000618a <create+0x72>

0000000080006280 <sys_dup>:
{
    80006280:	7179                	addi	sp,sp,-48
    80006282:	f406                	sd	ra,40(sp)
    80006284:	f022                	sd	s0,32(sp)
    80006286:	ec26                	sd	s1,24(sp)
    80006288:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000628a:	fd840613          	addi	a2,s0,-40
    8000628e:	4581                	li	a1,0
    80006290:	4501                	li	a0,0
    80006292:	00000097          	auipc	ra,0x0
    80006296:	ddc080e7          	jalr	-548(ra) # 8000606e <argfd>
    return -1;
    8000629a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000629c:	02054363          	bltz	a0,800062c2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800062a0:	fd843503          	ld	a0,-40(s0)
    800062a4:	00000097          	auipc	ra,0x0
    800062a8:	e32080e7          	jalr	-462(ra) # 800060d6 <fdalloc>
    800062ac:	84aa                	mv	s1,a0
    return -1;
    800062ae:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800062b0:	00054963          	bltz	a0,800062c2 <sys_dup+0x42>
  filedup(f);
    800062b4:	fd843503          	ld	a0,-40(s0)
    800062b8:	fffff097          	auipc	ra,0xfffff
    800062bc:	37a080e7          	jalr	890(ra) # 80005632 <filedup>
  return fd;
    800062c0:	87a6                	mv	a5,s1
}
    800062c2:	853e                	mv	a0,a5
    800062c4:	70a2                	ld	ra,40(sp)
    800062c6:	7402                	ld	s0,32(sp)
    800062c8:	64e2                	ld	s1,24(sp)
    800062ca:	6145                	addi	sp,sp,48
    800062cc:	8082                	ret

00000000800062ce <sys_read>:
{
    800062ce:	7179                	addi	sp,sp,-48
    800062d0:	f406                	sd	ra,40(sp)
    800062d2:	f022                	sd	s0,32(sp)
    800062d4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800062d6:	fe840613          	addi	a2,s0,-24
    800062da:	4581                	li	a1,0
    800062dc:	4501                	li	a0,0
    800062de:	00000097          	auipc	ra,0x0
    800062e2:	d90080e7          	jalr	-624(ra) # 8000606e <argfd>
    return -1;
    800062e6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800062e8:	04054163          	bltz	a0,8000632a <sys_read+0x5c>
    800062ec:	fe440593          	addi	a1,s0,-28
    800062f0:	4509                	li	a0,2
    800062f2:	ffffd097          	auipc	ra,0xffffd
    800062f6:	76e080e7          	jalr	1902(ra) # 80003a60 <argint>
    return -1;
    800062fa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800062fc:	02054763          	bltz	a0,8000632a <sys_read+0x5c>
    80006300:	fd840593          	addi	a1,s0,-40
    80006304:	4505                	li	a0,1
    80006306:	ffffd097          	auipc	ra,0xffffd
    8000630a:	77c080e7          	jalr	1916(ra) # 80003a82 <argaddr>
    return -1;
    8000630e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006310:	00054d63          	bltz	a0,8000632a <sys_read+0x5c>
  return fileread(f, p, n);
    80006314:	fe442603          	lw	a2,-28(s0)
    80006318:	fd843583          	ld	a1,-40(s0)
    8000631c:	fe843503          	ld	a0,-24(s0)
    80006320:	fffff097          	auipc	ra,0xfffff
    80006324:	49e080e7          	jalr	1182(ra) # 800057be <fileread>
    80006328:	87aa                	mv	a5,a0
}
    8000632a:	853e                	mv	a0,a5
    8000632c:	70a2                	ld	ra,40(sp)
    8000632e:	7402                	ld	s0,32(sp)
    80006330:	6145                	addi	sp,sp,48
    80006332:	8082                	ret

0000000080006334 <sys_write>:
{
    80006334:	7179                	addi	sp,sp,-48
    80006336:	f406                	sd	ra,40(sp)
    80006338:	f022                	sd	s0,32(sp)
    8000633a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000633c:	fe840613          	addi	a2,s0,-24
    80006340:	4581                	li	a1,0
    80006342:	4501                	li	a0,0
    80006344:	00000097          	auipc	ra,0x0
    80006348:	d2a080e7          	jalr	-726(ra) # 8000606e <argfd>
    return -1;
    8000634c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000634e:	04054163          	bltz	a0,80006390 <sys_write+0x5c>
    80006352:	fe440593          	addi	a1,s0,-28
    80006356:	4509                	li	a0,2
    80006358:	ffffd097          	auipc	ra,0xffffd
    8000635c:	708080e7          	jalr	1800(ra) # 80003a60 <argint>
    return -1;
    80006360:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006362:	02054763          	bltz	a0,80006390 <sys_write+0x5c>
    80006366:	fd840593          	addi	a1,s0,-40
    8000636a:	4505                	li	a0,1
    8000636c:	ffffd097          	auipc	ra,0xffffd
    80006370:	716080e7          	jalr	1814(ra) # 80003a82 <argaddr>
    return -1;
    80006374:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006376:	00054d63          	bltz	a0,80006390 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000637a:	fe442603          	lw	a2,-28(s0)
    8000637e:	fd843583          	ld	a1,-40(s0)
    80006382:	fe843503          	ld	a0,-24(s0)
    80006386:	fffff097          	auipc	ra,0xfffff
    8000638a:	4fa080e7          	jalr	1274(ra) # 80005880 <filewrite>
    8000638e:	87aa                	mv	a5,a0
}
    80006390:	853e                	mv	a0,a5
    80006392:	70a2                	ld	ra,40(sp)
    80006394:	7402                	ld	s0,32(sp)
    80006396:	6145                	addi	sp,sp,48
    80006398:	8082                	ret

000000008000639a <sys_close>:
{
    8000639a:	1101                	addi	sp,sp,-32
    8000639c:	ec06                	sd	ra,24(sp)
    8000639e:	e822                	sd	s0,16(sp)
    800063a0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800063a2:	fe040613          	addi	a2,s0,-32
    800063a6:	fec40593          	addi	a1,s0,-20
    800063aa:	4501                	li	a0,0
    800063ac:	00000097          	auipc	ra,0x0
    800063b0:	cc2080e7          	jalr	-830(ra) # 8000606e <argfd>
    return -1;
    800063b4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800063b6:	02054463          	bltz	a0,800063de <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800063ba:	ffffb097          	auipc	ra,0xffffb
    800063be:	5f4080e7          	jalr	1524(ra) # 800019ae <myproc>
    800063c2:	fec42783          	lw	a5,-20(s0)
    800063c6:	07e9                	addi	a5,a5,26
    800063c8:	078e                	slli	a5,a5,0x3
    800063ca:	97aa                	add	a5,a5,a0
    800063cc:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800063d0:	fe043503          	ld	a0,-32(s0)
    800063d4:	fffff097          	auipc	ra,0xfffff
    800063d8:	2b0080e7          	jalr	688(ra) # 80005684 <fileclose>
  return 0;
    800063dc:	4781                	li	a5,0
}
    800063de:	853e                	mv	a0,a5
    800063e0:	60e2                	ld	ra,24(sp)
    800063e2:	6442                	ld	s0,16(sp)
    800063e4:	6105                	addi	sp,sp,32
    800063e6:	8082                	ret

00000000800063e8 <sys_fstat>:
{
    800063e8:	1101                	addi	sp,sp,-32
    800063ea:	ec06                	sd	ra,24(sp)
    800063ec:	e822                	sd	s0,16(sp)
    800063ee:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800063f0:	fe840613          	addi	a2,s0,-24
    800063f4:	4581                	li	a1,0
    800063f6:	4501                	li	a0,0
    800063f8:	00000097          	auipc	ra,0x0
    800063fc:	c76080e7          	jalr	-906(ra) # 8000606e <argfd>
    return -1;
    80006400:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006402:	02054563          	bltz	a0,8000642c <sys_fstat+0x44>
    80006406:	fe040593          	addi	a1,s0,-32
    8000640a:	4505                	li	a0,1
    8000640c:	ffffd097          	auipc	ra,0xffffd
    80006410:	676080e7          	jalr	1654(ra) # 80003a82 <argaddr>
    return -1;
    80006414:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006416:	00054b63          	bltz	a0,8000642c <sys_fstat+0x44>
  return filestat(f, st);
    8000641a:	fe043583          	ld	a1,-32(s0)
    8000641e:	fe843503          	ld	a0,-24(s0)
    80006422:	fffff097          	auipc	ra,0xfffff
    80006426:	32a080e7          	jalr	810(ra) # 8000574c <filestat>
    8000642a:	87aa                	mv	a5,a0
}
    8000642c:	853e                	mv	a0,a5
    8000642e:	60e2                	ld	ra,24(sp)
    80006430:	6442                	ld	s0,16(sp)
    80006432:	6105                	addi	sp,sp,32
    80006434:	8082                	ret

0000000080006436 <sys_link>:
{
    80006436:	7169                	addi	sp,sp,-304
    80006438:	f606                	sd	ra,296(sp)
    8000643a:	f222                	sd	s0,288(sp)
    8000643c:	ee26                	sd	s1,280(sp)
    8000643e:	ea4a                	sd	s2,272(sp)
    80006440:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006442:	08000613          	li	a2,128
    80006446:	ed040593          	addi	a1,s0,-304
    8000644a:	4501                	li	a0,0
    8000644c:	ffffd097          	auipc	ra,0xffffd
    80006450:	658080e7          	jalr	1624(ra) # 80003aa4 <argstr>
    return -1;
    80006454:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006456:	10054e63          	bltz	a0,80006572 <sys_link+0x13c>
    8000645a:	08000613          	li	a2,128
    8000645e:	f5040593          	addi	a1,s0,-176
    80006462:	4505                	li	a0,1
    80006464:	ffffd097          	auipc	ra,0xffffd
    80006468:	640080e7          	jalr	1600(ra) # 80003aa4 <argstr>
    return -1;
    8000646c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000646e:	10054263          	bltz	a0,80006572 <sys_link+0x13c>
  begin_op();
    80006472:	fffff097          	auipc	ra,0xfffff
    80006476:	d46080e7          	jalr	-698(ra) # 800051b8 <begin_op>
  if((ip = namei(old)) == 0){
    8000647a:	ed040513          	addi	a0,s0,-304
    8000647e:	fffff097          	auipc	ra,0xfffff
    80006482:	b1e080e7          	jalr	-1250(ra) # 80004f9c <namei>
    80006486:	84aa                	mv	s1,a0
    80006488:	c551                	beqz	a0,80006514 <sys_link+0xde>
  ilock(ip);
    8000648a:	ffffe097          	auipc	ra,0xffffe
    8000648e:	35c080e7          	jalr	860(ra) # 800047e6 <ilock>
  if(ip->type == T_DIR){
    80006492:	04449703          	lh	a4,68(s1)
    80006496:	4785                	li	a5,1
    80006498:	08f70463          	beq	a4,a5,80006520 <sys_link+0xea>
  ip->nlink++;
    8000649c:	04a4d783          	lhu	a5,74(s1)
    800064a0:	2785                	addiw	a5,a5,1
    800064a2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800064a6:	8526                	mv	a0,s1
    800064a8:	ffffe097          	auipc	ra,0xffffe
    800064ac:	274080e7          	jalr	628(ra) # 8000471c <iupdate>
  iunlock(ip);
    800064b0:	8526                	mv	a0,s1
    800064b2:	ffffe097          	auipc	ra,0xffffe
    800064b6:	3f6080e7          	jalr	1014(ra) # 800048a8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800064ba:	fd040593          	addi	a1,s0,-48
    800064be:	f5040513          	addi	a0,s0,-176
    800064c2:	fffff097          	auipc	ra,0xfffff
    800064c6:	af8080e7          	jalr	-1288(ra) # 80004fba <nameiparent>
    800064ca:	892a                	mv	s2,a0
    800064cc:	c935                	beqz	a0,80006540 <sys_link+0x10a>
  ilock(dp);
    800064ce:	ffffe097          	auipc	ra,0xffffe
    800064d2:	318080e7          	jalr	792(ra) # 800047e6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800064d6:	00092703          	lw	a4,0(s2)
    800064da:	409c                	lw	a5,0(s1)
    800064dc:	04f71d63          	bne	a4,a5,80006536 <sys_link+0x100>
    800064e0:	40d0                	lw	a2,4(s1)
    800064e2:	fd040593          	addi	a1,s0,-48
    800064e6:	854a                	mv	a0,s2
    800064e8:	fffff097          	auipc	ra,0xfffff
    800064ec:	9f2080e7          	jalr	-1550(ra) # 80004eda <dirlink>
    800064f0:	04054363          	bltz	a0,80006536 <sys_link+0x100>
  iunlockput(dp);
    800064f4:	854a                	mv	a0,s2
    800064f6:	ffffe097          	auipc	ra,0xffffe
    800064fa:	552080e7          	jalr	1362(ra) # 80004a48 <iunlockput>
  iput(ip);
    800064fe:	8526                	mv	a0,s1
    80006500:	ffffe097          	auipc	ra,0xffffe
    80006504:	4a0080e7          	jalr	1184(ra) # 800049a0 <iput>
  end_op();
    80006508:	fffff097          	auipc	ra,0xfffff
    8000650c:	d30080e7          	jalr	-720(ra) # 80005238 <end_op>
  return 0;
    80006510:	4781                	li	a5,0
    80006512:	a085                	j	80006572 <sys_link+0x13c>
    end_op();
    80006514:	fffff097          	auipc	ra,0xfffff
    80006518:	d24080e7          	jalr	-732(ra) # 80005238 <end_op>
    return -1;
    8000651c:	57fd                	li	a5,-1
    8000651e:	a891                	j	80006572 <sys_link+0x13c>
    iunlockput(ip);
    80006520:	8526                	mv	a0,s1
    80006522:	ffffe097          	auipc	ra,0xffffe
    80006526:	526080e7          	jalr	1318(ra) # 80004a48 <iunlockput>
    end_op();
    8000652a:	fffff097          	auipc	ra,0xfffff
    8000652e:	d0e080e7          	jalr	-754(ra) # 80005238 <end_op>
    return -1;
    80006532:	57fd                	li	a5,-1
    80006534:	a83d                	j	80006572 <sys_link+0x13c>
    iunlockput(dp);
    80006536:	854a                	mv	a0,s2
    80006538:	ffffe097          	auipc	ra,0xffffe
    8000653c:	510080e7          	jalr	1296(ra) # 80004a48 <iunlockput>
  ilock(ip);
    80006540:	8526                	mv	a0,s1
    80006542:	ffffe097          	auipc	ra,0xffffe
    80006546:	2a4080e7          	jalr	676(ra) # 800047e6 <ilock>
  ip->nlink--;
    8000654a:	04a4d783          	lhu	a5,74(s1)
    8000654e:	37fd                	addiw	a5,a5,-1
    80006550:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006554:	8526                	mv	a0,s1
    80006556:	ffffe097          	auipc	ra,0xffffe
    8000655a:	1c6080e7          	jalr	454(ra) # 8000471c <iupdate>
  iunlockput(ip);
    8000655e:	8526                	mv	a0,s1
    80006560:	ffffe097          	auipc	ra,0xffffe
    80006564:	4e8080e7          	jalr	1256(ra) # 80004a48 <iunlockput>
  end_op();
    80006568:	fffff097          	auipc	ra,0xfffff
    8000656c:	cd0080e7          	jalr	-816(ra) # 80005238 <end_op>
  return -1;
    80006570:	57fd                	li	a5,-1
}
    80006572:	853e                	mv	a0,a5
    80006574:	70b2                	ld	ra,296(sp)
    80006576:	7412                	ld	s0,288(sp)
    80006578:	64f2                	ld	s1,280(sp)
    8000657a:	6952                	ld	s2,272(sp)
    8000657c:	6155                	addi	sp,sp,304
    8000657e:	8082                	ret

0000000080006580 <sys_unlink>:
{
    80006580:	7151                	addi	sp,sp,-240
    80006582:	f586                	sd	ra,232(sp)
    80006584:	f1a2                	sd	s0,224(sp)
    80006586:	eda6                	sd	s1,216(sp)
    80006588:	e9ca                	sd	s2,208(sp)
    8000658a:	e5ce                	sd	s3,200(sp)
    8000658c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000658e:	08000613          	li	a2,128
    80006592:	f3040593          	addi	a1,s0,-208
    80006596:	4501                	li	a0,0
    80006598:	ffffd097          	auipc	ra,0xffffd
    8000659c:	50c080e7          	jalr	1292(ra) # 80003aa4 <argstr>
    800065a0:	18054163          	bltz	a0,80006722 <sys_unlink+0x1a2>
  begin_op();
    800065a4:	fffff097          	auipc	ra,0xfffff
    800065a8:	c14080e7          	jalr	-1004(ra) # 800051b8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800065ac:	fb040593          	addi	a1,s0,-80
    800065b0:	f3040513          	addi	a0,s0,-208
    800065b4:	fffff097          	auipc	ra,0xfffff
    800065b8:	a06080e7          	jalr	-1530(ra) # 80004fba <nameiparent>
    800065bc:	84aa                	mv	s1,a0
    800065be:	c979                	beqz	a0,80006694 <sys_unlink+0x114>
  ilock(dp);
    800065c0:	ffffe097          	auipc	ra,0xffffe
    800065c4:	226080e7          	jalr	550(ra) # 800047e6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800065c8:	00003597          	auipc	a1,0x3
    800065cc:	38858593          	addi	a1,a1,904 # 80009950 <syscalls+0x310>
    800065d0:	fb040513          	addi	a0,s0,-80
    800065d4:	ffffe097          	auipc	ra,0xffffe
    800065d8:	6dc080e7          	jalr	1756(ra) # 80004cb0 <namecmp>
    800065dc:	14050a63          	beqz	a0,80006730 <sys_unlink+0x1b0>
    800065e0:	00003597          	auipc	a1,0x3
    800065e4:	37858593          	addi	a1,a1,888 # 80009958 <syscalls+0x318>
    800065e8:	fb040513          	addi	a0,s0,-80
    800065ec:	ffffe097          	auipc	ra,0xffffe
    800065f0:	6c4080e7          	jalr	1732(ra) # 80004cb0 <namecmp>
    800065f4:	12050e63          	beqz	a0,80006730 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800065f8:	f2c40613          	addi	a2,s0,-212
    800065fc:	fb040593          	addi	a1,s0,-80
    80006600:	8526                	mv	a0,s1
    80006602:	ffffe097          	auipc	ra,0xffffe
    80006606:	6c8080e7          	jalr	1736(ra) # 80004cca <dirlookup>
    8000660a:	892a                	mv	s2,a0
    8000660c:	12050263          	beqz	a0,80006730 <sys_unlink+0x1b0>
  ilock(ip);
    80006610:	ffffe097          	auipc	ra,0xffffe
    80006614:	1d6080e7          	jalr	470(ra) # 800047e6 <ilock>
  if(ip->nlink < 1)
    80006618:	04a91783          	lh	a5,74(s2)
    8000661c:	08f05263          	blez	a5,800066a0 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006620:	04491703          	lh	a4,68(s2)
    80006624:	4785                	li	a5,1
    80006626:	08f70563          	beq	a4,a5,800066b0 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000662a:	4641                	li	a2,16
    8000662c:	4581                	li	a1,0
    8000662e:	fc040513          	addi	a0,s0,-64
    80006632:	ffffa097          	auipc	ra,0xffffa
    80006636:	6ac080e7          	jalr	1708(ra) # 80000cde <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000663a:	4741                	li	a4,16
    8000663c:	f2c42683          	lw	a3,-212(s0)
    80006640:	fc040613          	addi	a2,s0,-64
    80006644:	4581                	li	a1,0
    80006646:	8526                	mv	a0,s1
    80006648:	ffffe097          	auipc	ra,0xffffe
    8000664c:	54a080e7          	jalr	1354(ra) # 80004b92 <writei>
    80006650:	47c1                	li	a5,16
    80006652:	0af51563          	bne	a0,a5,800066fc <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80006656:	04491703          	lh	a4,68(s2)
    8000665a:	4785                	li	a5,1
    8000665c:	0af70863          	beq	a4,a5,8000670c <sys_unlink+0x18c>
  iunlockput(dp);
    80006660:	8526                	mv	a0,s1
    80006662:	ffffe097          	auipc	ra,0xffffe
    80006666:	3e6080e7          	jalr	998(ra) # 80004a48 <iunlockput>
  ip->nlink--;
    8000666a:	04a95783          	lhu	a5,74(s2)
    8000666e:	37fd                	addiw	a5,a5,-1
    80006670:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006674:	854a                	mv	a0,s2
    80006676:	ffffe097          	auipc	ra,0xffffe
    8000667a:	0a6080e7          	jalr	166(ra) # 8000471c <iupdate>
  iunlockput(ip);
    8000667e:	854a                	mv	a0,s2
    80006680:	ffffe097          	auipc	ra,0xffffe
    80006684:	3c8080e7          	jalr	968(ra) # 80004a48 <iunlockput>
  end_op();
    80006688:	fffff097          	auipc	ra,0xfffff
    8000668c:	bb0080e7          	jalr	-1104(ra) # 80005238 <end_op>
  return 0;
    80006690:	4501                	li	a0,0
    80006692:	a84d                	j	80006744 <sys_unlink+0x1c4>
    end_op();
    80006694:	fffff097          	auipc	ra,0xfffff
    80006698:	ba4080e7          	jalr	-1116(ra) # 80005238 <end_op>
    return -1;
    8000669c:	557d                	li	a0,-1
    8000669e:	a05d                	j	80006744 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800066a0:	00003517          	auipc	a0,0x3
    800066a4:	2e050513          	addi	a0,a0,736 # 80009980 <syscalls+0x340>
    800066a8:	ffffa097          	auipc	ra,0xffffa
    800066ac:	e94080e7          	jalr	-364(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800066b0:	04c92703          	lw	a4,76(s2)
    800066b4:	02000793          	li	a5,32
    800066b8:	f6e7f9e3          	bgeu	a5,a4,8000662a <sys_unlink+0xaa>
    800066bc:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800066c0:	4741                	li	a4,16
    800066c2:	86ce                	mv	a3,s3
    800066c4:	f1840613          	addi	a2,s0,-232
    800066c8:	4581                	li	a1,0
    800066ca:	854a                	mv	a0,s2
    800066cc:	ffffe097          	auipc	ra,0xffffe
    800066d0:	3ce080e7          	jalr	974(ra) # 80004a9a <readi>
    800066d4:	47c1                	li	a5,16
    800066d6:	00f51b63          	bne	a0,a5,800066ec <sys_unlink+0x16c>
    if(de.inum != 0)
    800066da:	f1845783          	lhu	a5,-232(s0)
    800066de:	e7a1                	bnez	a5,80006726 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800066e0:	29c1                	addiw	s3,s3,16
    800066e2:	04c92783          	lw	a5,76(s2)
    800066e6:	fcf9ede3          	bltu	s3,a5,800066c0 <sys_unlink+0x140>
    800066ea:	b781                	j	8000662a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800066ec:	00003517          	auipc	a0,0x3
    800066f0:	2ac50513          	addi	a0,a0,684 # 80009998 <syscalls+0x358>
    800066f4:	ffffa097          	auipc	ra,0xffffa
    800066f8:	e48080e7          	jalr	-440(ra) # 8000053c <panic>
    panic("unlink: writei");
    800066fc:	00003517          	auipc	a0,0x3
    80006700:	2b450513          	addi	a0,a0,692 # 800099b0 <syscalls+0x370>
    80006704:	ffffa097          	auipc	ra,0xffffa
    80006708:	e38080e7          	jalr	-456(ra) # 8000053c <panic>
    dp->nlink--;
    8000670c:	04a4d783          	lhu	a5,74(s1)
    80006710:	37fd                	addiw	a5,a5,-1
    80006712:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006716:	8526                	mv	a0,s1
    80006718:	ffffe097          	auipc	ra,0xffffe
    8000671c:	004080e7          	jalr	4(ra) # 8000471c <iupdate>
    80006720:	b781                	j	80006660 <sys_unlink+0xe0>
    return -1;
    80006722:	557d                	li	a0,-1
    80006724:	a005                	j	80006744 <sys_unlink+0x1c4>
    iunlockput(ip);
    80006726:	854a                	mv	a0,s2
    80006728:	ffffe097          	auipc	ra,0xffffe
    8000672c:	320080e7          	jalr	800(ra) # 80004a48 <iunlockput>
  iunlockput(dp);
    80006730:	8526                	mv	a0,s1
    80006732:	ffffe097          	auipc	ra,0xffffe
    80006736:	316080e7          	jalr	790(ra) # 80004a48 <iunlockput>
  end_op();
    8000673a:	fffff097          	auipc	ra,0xfffff
    8000673e:	afe080e7          	jalr	-1282(ra) # 80005238 <end_op>
  return -1;
    80006742:	557d                	li	a0,-1
}
    80006744:	70ae                	ld	ra,232(sp)
    80006746:	740e                	ld	s0,224(sp)
    80006748:	64ee                	ld	s1,216(sp)
    8000674a:	694e                	ld	s2,208(sp)
    8000674c:	69ae                	ld	s3,200(sp)
    8000674e:	616d                	addi	sp,sp,240
    80006750:	8082                	ret

0000000080006752 <sys_open>:

uint64
sys_open(void)
{
    80006752:	7131                	addi	sp,sp,-192
    80006754:	fd06                	sd	ra,184(sp)
    80006756:	f922                	sd	s0,176(sp)
    80006758:	f526                	sd	s1,168(sp)
    8000675a:	f14a                	sd	s2,160(sp)
    8000675c:	ed4e                	sd	s3,152(sp)
    8000675e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006760:	08000613          	li	a2,128
    80006764:	f5040593          	addi	a1,s0,-176
    80006768:	4501                	li	a0,0
    8000676a:	ffffd097          	auipc	ra,0xffffd
    8000676e:	33a080e7          	jalr	826(ra) # 80003aa4 <argstr>
    return -1;
    80006772:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006774:	0c054163          	bltz	a0,80006836 <sys_open+0xe4>
    80006778:	f4c40593          	addi	a1,s0,-180
    8000677c:	4505                	li	a0,1
    8000677e:	ffffd097          	auipc	ra,0xffffd
    80006782:	2e2080e7          	jalr	738(ra) # 80003a60 <argint>
    80006786:	0a054863          	bltz	a0,80006836 <sys_open+0xe4>

  begin_op();
    8000678a:	fffff097          	auipc	ra,0xfffff
    8000678e:	a2e080e7          	jalr	-1490(ra) # 800051b8 <begin_op>

  if(omode & O_CREATE){
    80006792:	f4c42783          	lw	a5,-180(s0)
    80006796:	2007f793          	andi	a5,a5,512
    8000679a:	cbdd                	beqz	a5,80006850 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000679c:	4681                	li	a3,0
    8000679e:	4601                	li	a2,0
    800067a0:	4589                	li	a1,2
    800067a2:	f5040513          	addi	a0,s0,-176
    800067a6:	00000097          	auipc	ra,0x0
    800067aa:	972080e7          	jalr	-1678(ra) # 80006118 <create>
    800067ae:	892a                	mv	s2,a0
    if(ip == 0){
    800067b0:	c959                	beqz	a0,80006846 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800067b2:	04491703          	lh	a4,68(s2)
    800067b6:	478d                	li	a5,3
    800067b8:	00f71763          	bne	a4,a5,800067c6 <sys_open+0x74>
    800067bc:	04695703          	lhu	a4,70(s2)
    800067c0:	47a5                	li	a5,9
    800067c2:	0ce7ec63          	bltu	a5,a4,8000689a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800067c6:	fffff097          	auipc	ra,0xfffff
    800067ca:	e02080e7          	jalr	-510(ra) # 800055c8 <filealloc>
    800067ce:	89aa                	mv	s3,a0
    800067d0:	10050263          	beqz	a0,800068d4 <sys_open+0x182>
    800067d4:	00000097          	auipc	ra,0x0
    800067d8:	902080e7          	jalr	-1790(ra) # 800060d6 <fdalloc>
    800067dc:	84aa                	mv	s1,a0
    800067de:	0e054663          	bltz	a0,800068ca <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800067e2:	04491703          	lh	a4,68(s2)
    800067e6:	478d                	li	a5,3
    800067e8:	0cf70463          	beq	a4,a5,800068b0 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800067ec:	4789                	li	a5,2
    800067ee:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800067f2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800067f6:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800067fa:	f4c42783          	lw	a5,-180(s0)
    800067fe:	0017c713          	xori	a4,a5,1
    80006802:	8b05                	andi	a4,a4,1
    80006804:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006808:	0037f713          	andi	a4,a5,3
    8000680c:	00e03733          	snez	a4,a4
    80006810:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006814:	4007f793          	andi	a5,a5,1024
    80006818:	c791                	beqz	a5,80006824 <sys_open+0xd2>
    8000681a:	04491703          	lh	a4,68(s2)
    8000681e:	4789                	li	a5,2
    80006820:	08f70f63          	beq	a4,a5,800068be <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006824:	854a                	mv	a0,s2
    80006826:	ffffe097          	auipc	ra,0xffffe
    8000682a:	082080e7          	jalr	130(ra) # 800048a8 <iunlock>
  end_op();
    8000682e:	fffff097          	auipc	ra,0xfffff
    80006832:	a0a080e7          	jalr	-1526(ra) # 80005238 <end_op>

  return fd;
}
    80006836:	8526                	mv	a0,s1
    80006838:	70ea                	ld	ra,184(sp)
    8000683a:	744a                	ld	s0,176(sp)
    8000683c:	74aa                	ld	s1,168(sp)
    8000683e:	790a                	ld	s2,160(sp)
    80006840:	69ea                	ld	s3,152(sp)
    80006842:	6129                	addi	sp,sp,192
    80006844:	8082                	ret
      end_op();
    80006846:	fffff097          	auipc	ra,0xfffff
    8000684a:	9f2080e7          	jalr	-1550(ra) # 80005238 <end_op>
      return -1;
    8000684e:	b7e5                	j	80006836 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006850:	f5040513          	addi	a0,s0,-176
    80006854:	ffffe097          	auipc	ra,0xffffe
    80006858:	748080e7          	jalr	1864(ra) # 80004f9c <namei>
    8000685c:	892a                	mv	s2,a0
    8000685e:	c905                	beqz	a0,8000688e <sys_open+0x13c>
    ilock(ip);
    80006860:	ffffe097          	auipc	ra,0xffffe
    80006864:	f86080e7          	jalr	-122(ra) # 800047e6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006868:	04491703          	lh	a4,68(s2)
    8000686c:	4785                	li	a5,1
    8000686e:	f4f712e3          	bne	a4,a5,800067b2 <sys_open+0x60>
    80006872:	f4c42783          	lw	a5,-180(s0)
    80006876:	dba1                	beqz	a5,800067c6 <sys_open+0x74>
      iunlockput(ip);
    80006878:	854a                	mv	a0,s2
    8000687a:	ffffe097          	auipc	ra,0xffffe
    8000687e:	1ce080e7          	jalr	462(ra) # 80004a48 <iunlockput>
      end_op();
    80006882:	fffff097          	auipc	ra,0xfffff
    80006886:	9b6080e7          	jalr	-1610(ra) # 80005238 <end_op>
      return -1;
    8000688a:	54fd                	li	s1,-1
    8000688c:	b76d                	j	80006836 <sys_open+0xe4>
      end_op();
    8000688e:	fffff097          	auipc	ra,0xfffff
    80006892:	9aa080e7          	jalr	-1622(ra) # 80005238 <end_op>
      return -1;
    80006896:	54fd                	li	s1,-1
    80006898:	bf79                	j	80006836 <sys_open+0xe4>
    iunlockput(ip);
    8000689a:	854a                	mv	a0,s2
    8000689c:	ffffe097          	auipc	ra,0xffffe
    800068a0:	1ac080e7          	jalr	428(ra) # 80004a48 <iunlockput>
    end_op();
    800068a4:	fffff097          	auipc	ra,0xfffff
    800068a8:	994080e7          	jalr	-1644(ra) # 80005238 <end_op>
    return -1;
    800068ac:	54fd                	li	s1,-1
    800068ae:	b761                	j	80006836 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800068b0:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800068b4:	04691783          	lh	a5,70(s2)
    800068b8:	02f99223          	sh	a5,36(s3)
    800068bc:	bf2d                	j	800067f6 <sys_open+0xa4>
    itrunc(ip);
    800068be:	854a                	mv	a0,s2
    800068c0:	ffffe097          	auipc	ra,0xffffe
    800068c4:	034080e7          	jalr	52(ra) # 800048f4 <itrunc>
    800068c8:	bfb1                	j	80006824 <sys_open+0xd2>
      fileclose(f);
    800068ca:	854e                	mv	a0,s3
    800068cc:	fffff097          	auipc	ra,0xfffff
    800068d0:	db8080e7          	jalr	-584(ra) # 80005684 <fileclose>
    iunlockput(ip);
    800068d4:	854a                	mv	a0,s2
    800068d6:	ffffe097          	auipc	ra,0xffffe
    800068da:	172080e7          	jalr	370(ra) # 80004a48 <iunlockput>
    end_op();
    800068de:	fffff097          	auipc	ra,0xfffff
    800068e2:	95a080e7          	jalr	-1702(ra) # 80005238 <end_op>
    return -1;
    800068e6:	54fd                	li	s1,-1
    800068e8:	b7b9                	j	80006836 <sys_open+0xe4>

00000000800068ea <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800068ea:	7175                	addi	sp,sp,-144
    800068ec:	e506                	sd	ra,136(sp)
    800068ee:	e122                	sd	s0,128(sp)
    800068f0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800068f2:	fffff097          	auipc	ra,0xfffff
    800068f6:	8c6080e7          	jalr	-1850(ra) # 800051b8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800068fa:	08000613          	li	a2,128
    800068fe:	f7040593          	addi	a1,s0,-144
    80006902:	4501                	li	a0,0
    80006904:	ffffd097          	auipc	ra,0xffffd
    80006908:	1a0080e7          	jalr	416(ra) # 80003aa4 <argstr>
    8000690c:	02054963          	bltz	a0,8000693e <sys_mkdir+0x54>
    80006910:	4681                	li	a3,0
    80006912:	4601                	li	a2,0
    80006914:	4585                	li	a1,1
    80006916:	f7040513          	addi	a0,s0,-144
    8000691a:	fffff097          	auipc	ra,0xfffff
    8000691e:	7fe080e7          	jalr	2046(ra) # 80006118 <create>
    80006922:	cd11                	beqz	a0,8000693e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006924:	ffffe097          	auipc	ra,0xffffe
    80006928:	124080e7          	jalr	292(ra) # 80004a48 <iunlockput>
  end_op();
    8000692c:	fffff097          	auipc	ra,0xfffff
    80006930:	90c080e7          	jalr	-1780(ra) # 80005238 <end_op>
  return 0;
    80006934:	4501                	li	a0,0
}
    80006936:	60aa                	ld	ra,136(sp)
    80006938:	640a                	ld	s0,128(sp)
    8000693a:	6149                	addi	sp,sp,144
    8000693c:	8082                	ret
    end_op();
    8000693e:	fffff097          	auipc	ra,0xfffff
    80006942:	8fa080e7          	jalr	-1798(ra) # 80005238 <end_op>
    return -1;
    80006946:	557d                	li	a0,-1
    80006948:	b7fd                	j	80006936 <sys_mkdir+0x4c>

000000008000694a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000694a:	7135                	addi	sp,sp,-160
    8000694c:	ed06                	sd	ra,152(sp)
    8000694e:	e922                	sd	s0,144(sp)
    80006950:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006952:	fffff097          	auipc	ra,0xfffff
    80006956:	866080e7          	jalr	-1946(ra) # 800051b8 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000695a:	08000613          	li	a2,128
    8000695e:	f7040593          	addi	a1,s0,-144
    80006962:	4501                	li	a0,0
    80006964:	ffffd097          	auipc	ra,0xffffd
    80006968:	140080e7          	jalr	320(ra) # 80003aa4 <argstr>
    8000696c:	04054a63          	bltz	a0,800069c0 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80006970:	f6c40593          	addi	a1,s0,-148
    80006974:	4505                	li	a0,1
    80006976:	ffffd097          	auipc	ra,0xffffd
    8000697a:	0ea080e7          	jalr	234(ra) # 80003a60 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000697e:	04054163          	bltz	a0,800069c0 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80006982:	f6840593          	addi	a1,s0,-152
    80006986:	4509                	li	a0,2
    80006988:	ffffd097          	auipc	ra,0xffffd
    8000698c:	0d8080e7          	jalr	216(ra) # 80003a60 <argint>
     argint(1, &major) < 0 ||
    80006990:	02054863          	bltz	a0,800069c0 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006994:	f6841683          	lh	a3,-152(s0)
    80006998:	f6c41603          	lh	a2,-148(s0)
    8000699c:	458d                	li	a1,3
    8000699e:	f7040513          	addi	a0,s0,-144
    800069a2:	fffff097          	auipc	ra,0xfffff
    800069a6:	776080e7          	jalr	1910(ra) # 80006118 <create>
     argint(2, &minor) < 0 ||
    800069aa:	c919                	beqz	a0,800069c0 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800069ac:	ffffe097          	auipc	ra,0xffffe
    800069b0:	09c080e7          	jalr	156(ra) # 80004a48 <iunlockput>
  end_op();
    800069b4:	fffff097          	auipc	ra,0xfffff
    800069b8:	884080e7          	jalr	-1916(ra) # 80005238 <end_op>
  return 0;
    800069bc:	4501                	li	a0,0
    800069be:	a031                	j	800069ca <sys_mknod+0x80>
    end_op();
    800069c0:	fffff097          	auipc	ra,0xfffff
    800069c4:	878080e7          	jalr	-1928(ra) # 80005238 <end_op>
    return -1;
    800069c8:	557d                	li	a0,-1
}
    800069ca:	60ea                	ld	ra,152(sp)
    800069cc:	644a                	ld	s0,144(sp)
    800069ce:	610d                	addi	sp,sp,160
    800069d0:	8082                	ret

00000000800069d2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800069d2:	7135                	addi	sp,sp,-160
    800069d4:	ed06                	sd	ra,152(sp)
    800069d6:	e922                	sd	s0,144(sp)
    800069d8:	e526                	sd	s1,136(sp)
    800069da:	e14a                	sd	s2,128(sp)
    800069dc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800069de:	ffffb097          	auipc	ra,0xffffb
    800069e2:	fd0080e7          	jalr	-48(ra) # 800019ae <myproc>
    800069e6:	892a                	mv	s2,a0
  
  begin_op();
    800069e8:	ffffe097          	auipc	ra,0xffffe
    800069ec:	7d0080e7          	jalr	2000(ra) # 800051b8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800069f0:	08000613          	li	a2,128
    800069f4:	f6040593          	addi	a1,s0,-160
    800069f8:	4501                	li	a0,0
    800069fa:	ffffd097          	auipc	ra,0xffffd
    800069fe:	0aa080e7          	jalr	170(ra) # 80003aa4 <argstr>
    80006a02:	04054b63          	bltz	a0,80006a58 <sys_chdir+0x86>
    80006a06:	f6040513          	addi	a0,s0,-160
    80006a0a:	ffffe097          	auipc	ra,0xffffe
    80006a0e:	592080e7          	jalr	1426(ra) # 80004f9c <namei>
    80006a12:	84aa                	mv	s1,a0
    80006a14:	c131                	beqz	a0,80006a58 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006a16:	ffffe097          	auipc	ra,0xffffe
    80006a1a:	dd0080e7          	jalr	-560(ra) # 800047e6 <ilock>
  if(ip->type != T_DIR){
    80006a1e:	04449703          	lh	a4,68(s1)
    80006a22:	4785                	li	a5,1
    80006a24:	04f71063          	bne	a4,a5,80006a64 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006a28:	8526                	mv	a0,s1
    80006a2a:	ffffe097          	auipc	ra,0xffffe
    80006a2e:	e7e080e7          	jalr	-386(ra) # 800048a8 <iunlock>
  iput(p->cwd);
    80006a32:	15093503          	ld	a0,336(s2)
    80006a36:	ffffe097          	auipc	ra,0xffffe
    80006a3a:	f6a080e7          	jalr	-150(ra) # 800049a0 <iput>
  end_op();
    80006a3e:	ffffe097          	auipc	ra,0xffffe
    80006a42:	7fa080e7          	jalr	2042(ra) # 80005238 <end_op>
  p->cwd = ip;
    80006a46:	14993823          	sd	s1,336(s2)
  return 0;
    80006a4a:	4501                	li	a0,0
}
    80006a4c:	60ea                	ld	ra,152(sp)
    80006a4e:	644a                	ld	s0,144(sp)
    80006a50:	64aa                	ld	s1,136(sp)
    80006a52:	690a                	ld	s2,128(sp)
    80006a54:	610d                	addi	sp,sp,160
    80006a56:	8082                	ret
    end_op();
    80006a58:	ffffe097          	auipc	ra,0xffffe
    80006a5c:	7e0080e7          	jalr	2016(ra) # 80005238 <end_op>
    return -1;
    80006a60:	557d                	li	a0,-1
    80006a62:	b7ed                	j	80006a4c <sys_chdir+0x7a>
    iunlockput(ip);
    80006a64:	8526                	mv	a0,s1
    80006a66:	ffffe097          	auipc	ra,0xffffe
    80006a6a:	fe2080e7          	jalr	-30(ra) # 80004a48 <iunlockput>
    end_op();
    80006a6e:	ffffe097          	auipc	ra,0xffffe
    80006a72:	7ca080e7          	jalr	1994(ra) # 80005238 <end_op>
    return -1;
    80006a76:	557d                	li	a0,-1
    80006a78:	bfd1                	j	80006a4c <sys_chdir+0x7a>

0000000080006a7a <sys_exec>:

uint64
sys_exec(void)
{
    80006a7a:	7145                	addi	sp,sp,-464
    80006a7c:	e786                	sd	ra,456(sp)
    80006a7e:	e3a2                	sd	s0,448(sp)
    80006a80:	ff26                	sd	s1,440(sp)
    80006a82:	fb4a                	sd	s2,432(sp)
    80006a84:	f74e                	sd	s3,424(sp)
    80006a86:	f352                	sd	s4,416(sp)
    80006a88:	ef56                	sd	s5,408(sp)
    80006a8a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006a8c:	08000613          	li	a2,128
    80006a90:	f4040593          	addi	a1,s0,-192
    80006a94:	4501                	li	a0,0
    80006a96:	ffffd097          	auipc	ra,0xffffd
    80006a9a:	00e080e7          	jalr	14(ra) # 80003aa4 <argstr>
    return -1;
    80006a9e:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006aa0:	0c054a63          	bltz	a0,80006b74 <sys_exec+0xfa>
    80006aa4:	e3840593          	addi	a1,s0,-456
    80006aa8:	4505                	li	a0,1
    80006aaa:	ffffd097          	auipc	ra,0xffffd
    80006aae:	fd8080e7          	jalr	-40(ra) # 80003a82 <argaddr>
    80006ab2:	0c054163          	bltz	a0,80006b74 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006ab6:	10000613          	li	a2,256
    80006aba:	4581                	li	a1,0
    80006abc:	e4040513          	addi	a0,s0,-448
    80006ac0:	ffffa097          	auipc	ra,0xffffa
    80006ac4:	21e080e7          	jalr	542(ra) # 80000cde <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006ac8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006acc:	89a6                	mv	s3,s1
    80006ace:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006ad0:	02000a13          	li	s4,32
    80006ad4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006ad8:	00391513          	slli	a0,s2,0x3
    80006adc:	e3040593          	addi	a1,s0,-464
    80006ae0:	e3843783          	ld	a5,-456(s0)
    80006ae4:	953e                	add	a0,a0,a5
    80006ae6:	ffffd097          	auipc	ra,0xffffd
    80006aea:	ee0080e7          	jalr	-288(ra) # 800039c6 <fetchaddr>
    80006aee:	02054a63          	bltz	a0,80006b22 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006af2:	e3043783          	ld	a5,-464(s0)
    80006af6:	c3b9                	beqz	a5,80006b3c <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006af8:	ffffa097          	auipc	ra,0xffffa
    80006afc:	ffa080e7          	jalr	-6(ra) # 80000af2 <kalloc>
    80006b00:	85aa                	mv	a1,a0
    80006b02:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006b06:	cd11                	beqz	a0,80006b22 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006b08:	6605                	lui	a2,0x1
    80006b0a:	e3043503          	ld	a0,-464(s0)
    80006b0e:	ffffd097          	auipc	ra,0xffffd
    80006b12:	f0a080e7          	jalr	-246(ra) # 80003a18 <fetchstr>
    80006b16:	00054663          	bltz	a0,80006b22 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006b1a:	0905                	addi	s2,s2,1
    80006b1c:	09a1                	addi	s3,s3,8
    80006b1e:	fb491be3          	bne	s2,s4,80006ad4 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006b22:	10048913          	addi	s2,s1,256
    80006b26:	6088                	ld	a0,0(s1)
    80006b28:	c529                	beqz	a0,80006b72 <sys_exec+0xf8>
    kfree(argv[i]);
    80006b2a:	ffffa097          	auipc	ra,0xffffa
    80006b2e:	ecc080e7          	jalr	-308(ra) # 800009f6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006b32:	04a1                	addi	s1,s1,8
    80006b34:	ff2499e3          	bne	s1,s2,80006b26 <sys_exec+0xac>
  return -1;
    80006b38:	597d                	li	s2,-1
    80006b3a:	a82d                	j	80006b74 <sys_exec+0xfa>
      argv[i] = 0;
    80006b3c:	0a8e                	slli	s5,s5,0x3
    80006b3e:	fc040793          	addi	a5,s0,-64
    80006b42:	9abe                	add	s5,s5,a5
    80006b44:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006b48:	e4040593          	addi	a1,s0,-448
    80006b4c:	f4040513          	addi	a0,s0,-192
    80006b50:	fffff097          	auipc	ra,0xfffff
    80006b54:	194080e7          	jalr	404(ra) # 80005ce4 <exec>
    80006b58:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006b5a:	10048993          	addi	s3,s1,256
    80006b5e:	6088                	ld	a0,0(s1)
    80006b60:	c911                	beqz	a0,80006b74 <sys_exec+0xfa>
    kfree(argv[i]);
    80006b62:	ffffa097          	auipc	ra,0xffffa
    80006b66:	e94080e7          	jalr	-364(ra) # 800009f6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006b6a:	04a1                	addi	s1,s1,8
    80006b6c:	ff3499e3          	bne	s1,s3,80006b5e <sys_exec+0xe4>
    80006b70:	a011                	j	80006b74 <sys_exec+0xfa>
  return -1;
    80006b72:	597d                	li	s2,-1
}
    80006b74:	854a                	mv	a0,s2
    80006b76:	60be                	ld	ra,456(sp)
    80006b78:	641e                	ld	s0,448(sp)
    80006b7a:	74fa                	ld	s1,440(sp)
    80006b7c:	795a                	ld	s2,432(sp)
    80006b7e:	79ba                	ld	s3,424(sp)
    80006b80:	7a1a                	ld	s4,416(sp)
    80006b82:	6afa                	ld	s5,408(sp)
    80006b84:	6179                	addi	sp,sp,464
    80006b86:	8082                	ret

0000000080006b88 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006b88:	7139                	addi	sp,sp,-64
    80006b8a:	fc06                	sd	ra,56(sp)
    80006b8c:	f822                	sd	s0,48(sp)
    80006b8e:	f426                	sd	s1,40(sp)
    80006b90:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006b92:	ffffb097          	auipc	ra,0xffffb
    80006b96:	e1c080e7          	jalr	-484(ra) # 800019ae <myproc>
    80006b9a:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006b9c:	fd840593          	addi	a1,s0,-40
    80006ba0:	4501                	li	a0,0
    80006ba2:	ffffd097          	auipc	ra,0xffffd
    80006ba6:	ee0080e7          	jalr	-288(ra) # 80003a82 <argaddr>
    return -1;
    80006baa:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006bac:	0e054063          	bltz	a0,80006c8c <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006bb0:	fc840593          	addi	a1,s0,-56
    80006bb4:	fd040513          	addi	a0,s0,-48
    80006bb8:	fffff097          	auipc	ra,0xfffff
    80006bbc:	dfc080e7          	jalr	-516(ra) # 800059b4 <pipealloc>
    return -1;
    80006bc0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006bc2:	0c054563          	bltz	a0,80006c8c <sys_pipe+0x104>
  fd0 = -1;
    80006bc6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006bca:	fd043503          	ld	a0,-48(s0)
    80006bce:	fffff097          	auipc	ra,0xfffff
    80006bd2:	508080e7          	jalr	1288(ra) # 800060d6 <fdalloc>
    80006bd6:	fca42223          	sw	a0,-60(s0)
    80006bda:	08054c63          	bltz	a0,80006c72 <sys_pipe+0xea>
    80006bde:	fc843503          	ld	a0,-56(s0)
    80006be2:	fffff097          	auipc	ra,0xfffff
    80006be6:	4f4080e7          	jalr	1268(ra) # 800060d6 <fdalloc>
    80006bea:	fca42023          	sw	a0,-64(s0)
    80006bee:	06054863          	bltz	a0,80006c5e <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006bf2:	4691                	li	a3,4
    80006bf4:	fc440613          	addi	a2,s0,-60
    80006bf8:	fd843583          	ld	a1,-40(s0)
    80006bfc:	68a8                	ld	a0,80(s1)
    80006bfe:	ffffb097          	auipc	ra,0xffffb
    80006c02:	a72080e7          	jalr	-1422(ra) # 80001670 <copyout>
    80006c06:	02054063          	bltz	a0,80006c26 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006c0a:	4691                	li	a3,4
    80006c0c:	fc040613          	addi	a2,s0,-64
    80006c10:	fd843583          	ld	a1,-40(s0)
    80006c14:	0591                	addi	a1,a1,4
    80006c16:	68a8                	ld	a0,80(s1)
    80006c18:	ffffb097          	auipc	ra,0xffffb
    80006c1c:	a58080e7          	jalr	-1448(ra) # 80001670 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006c20:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006c22:	06055563          	bgez	a0,80006c8c <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006c26:	fc442783          	lw	a5,-60(s0)
    80006c2a:	07e9                	addi	a5,a5,26
    80006c2c:	078e                	slli	a5,a5,0x3
    80006c2e:	97a6                	add	a5,a5,s1
    80006c30:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006c34:	fc042503          	lw	a0,-64(s0)
    80006c38:	0569                	addi	a0,a0,26
    80006c3a:	050e                	slli	a0,a0,0x3
    80006c3c:	9526                	add	a0,a0,s1
    80006c3e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006c42:	fd043503          	ld	a0,-48(s0)
    80006c46:	fffff097          	auipc	ra,0xfffff
    80006c4a:	a3e080e7          	jalr	-1474(ra) # 80005684 <fileclose>
    fileclose(wf);
    80006c4e:	fc843503          	ld	a0,-56(s0)
    80006c52:	fffff097          	auipc	ra,0xfffff
    80006c56:	a32080e7          	jalr	-1486(ra) # 80005684 <fileclose>
    return -1;
    80006c5a:	57fd                	li	a5,-1
    80006c5c:	a805                	j	80006c8c <sys_pipe+0x104>
    if(fd0 >= 0)
    80006c5e:	fc442783          	lw	a5,-60(s0)
    80006c62:	0007c863          	bltz	a5,80006c72 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006c66:	01a78513          	addi	a0,a5,26
    80006c6a:	050e                	slli	a0,a0,0x3
    80006c6c:	9526                	add	a0,a0,s1
    80006c6e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006c72:	fd043503          	ld	a0,-48(s0)
    80006c76:	fffff097          	auipc	ra,0xfffff
    80006c7a:	a0e080e7          	jalr	-1522(ra) # 80005684 <fileclose>
    fileclose(wf);
    80006c7e:	fc843503          	ld	a0,-56(s0)
    80006c82:	fffff097          	auipc	ra,0xfffff
    80006c86:	a02080e7          	jalr	-1534(ra) # 80005684 <fileclose>
    return -1;
    80006c8a:	57fd                	li	a5,-1
}
    80006c8c:	853e                	mv	a0,a5
    80006c8e:	70e2                	ld	ra,56(sp)
    80006c90:	7442                	ld	s0,48(sp)
    80006c92:	74a2                	ld	s1,40(sp)
    80006c94:	6121                	addi	sp,sp,64
    80006c96:	8082                	ret
	...

0000000080006ca0 <kernelvec>:
    80006ca0:	7111                	addi	sp,sp,-256
    80006ca2:	e006                	sd	ra,0(sp)
    80006ca4:	e40a                	sd	sp,8(sp)
    80006ca6:	e80e                	sd	gp,16(sp)
    80006ca8:	ec12                	sd	tp,24(sp)
    80006caa:	f016                	sd	t0,32(sp)
    80006cac:	f41a                	sd	t1,40(sp)
    80006cae:	f81e                	sd	t2,48(sp)
    80006cb0:	fc22                	sd	s0,56(sp)
    80006cb2:	e0a6                	sd	s1,64(sp)
    80006cb4:	e4aa                	sd	a0,72(sp)
    80006cb6:	e8ae                	sd	a1,80(sp)
    80006cb8:	ecb2                	sd	a2,88(sp)
    80006cba:	f0b6                	sd	a3,96(sp)
    80006cbc:	f4ba                	sd	a4,104(sp)
    80006cbe:	f8be                	sd	a5,112(sp)
    80006cc0:	fcc2                	sd	a6,120(sp)
    80006cc2:	e146                	sd	a7,128(sp)
    80006cc4:	e54a                	sd	s2,136(sp)
    80006cc6:	e94e                	sd	s3,144(sp)
    80006cc8:	ed52                	sd	s4,152(sp)
    80006cca:	f156                	sd	s5,160(sp)
    80006ccc:	f55a                	sd	s6,168(sp)
    80006cce:	f95e                	sd	s7,176(sp)
    80006cd0:	fd62                	sd	s8,184(sp)
    80006cd2:	e1e6                	sd	s9,192(sp)
    80006cd4:	e5ea                	sd	s10,200(sp)
    80006cd6:	e9ee                	sd	s11,208(sp)
    80006cd8:	edf2                	sd	t3,216(sp)
    80006cda:	f1f6                	sd	t4,224(sp)
    80006cdc:	f5fa                	sd	t5,232(sp)
    80006cde:	f9fe                	sd	t6,240(sp)
    80006ce0:	ba5fc0ef          	jal	ra,80003884 <kerneltrap>
    80006ce4:	6082                	ld	ra,0(sp)
    80006ce6:	6122                	ld	sp,8(sp)
    80006ce8:	61c2                	ld	gp,16(sp)
    80006cea:	7282                	ld	t0,32(sp)
    80006cec:	7322                	ld	t1,40(sp)
    80006cee:	73c2                	ld	t2,48(sp)
    80006cf0:	7462                	ld	s0,56(sp)
    80006cf2:	6486                	ld	s1,64(sp)
    80006cf4:	6526                	ld	a0,72(sp)
    80006cf6:	65c6                	ld	a1,80(sp)
    80006cf8:	6666                	ld	a2,88(sp)
    80006cfa:	7686                	ld	a3,96(sp)
    80006cfc:	7726                	ld	a4,104(sp)
    80006cfe:	77c6                	ld	a5,112(sp)
    80006d00:	7866                	ld	a6,120(sp)
    80006d02:	688a                	ld	a7,128(sp)
    80006d04:	692a                	ld	s2,136(sp)
    80006d06:	69ca                	ld	s3,144(sp)
    80006d08:	6a6a                	ld	s4,152(sp)
    80006d0a:	7a8a                	ld	s5,160(sp)
    80006d0c:	7b2a                	ld	s6,168(sp)
    80006d0e:	7bca                	ld	s7,176(sp)
    80006d10:	7c6a                	ld	s8,184(sp)
    80006d12:	6c8e                	ld	s9,192(sp)
    80006d14:	6d2e                	ld	s10,200(sp)
    80006d16:	6dce                	ld	s11,208(sp)
    80006d18:	6e6e                	ld	t3,216(sp)
    80006d1a:	7e8e                	ld	t4,224(sp)
    80006d1c:	7f2e                	ld	t5,232(sp)
    80006d1e:	7fce                	ld	t6,240(sp)
    80006d20:	6111                	addi	sp,sp,256
    80006d22:	10200073          	sret
    80006d26:	00000013          	nop
    80006d2a:	00000013          	nop
    80006d2e:	0001                	nop

0000000080006d30 <timervec>:
    80006d30:	34051573          	csrrw	a0,mscratch,a0
    80006d34:	e10c                	sd	a1,0(a0)
    80006d36:	e510                	sd	a2,8(a0)
    80006d38:	e914                	sd	a3,16(a0)
    80006d3a:	6d0c                	ld	a1,24(a0)
    80006d3c:	7110                	ld	a2,32(a0)
    80006d3e:	6194                	ld	a3,0(a1)
    80006d40:	96b2                	add	a3,a3,a2
    80006d42:	e194                	sd	a3,0(a1)
    80006d44:	4589                	li	a1,2
    80006d46:	14459073          	csrw	sip,a1
    80006d4a:	6914                	ld	a3,16(a0)
    80006d4c:	6510                	ld	a2,8(a0)
    80006d4e:	610c                	ld	a1,0(a0)
    80006d50:	34051573          	csrrw	a0,mscratch,a0
    80006d54:	30200073          	mret
	...

0000000080006d5a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006d5a:	1141                	addi	sp,sp,-16
    80006d5c:	e422                	sd	s0,8(sp)
    80006d5e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006d60:	0c0007b7          	lui	a5,0xc000
    80006d64:	4705                	li	a4,1
    80006d66:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006d68:	c3d8                	sw	a4,4(a5)
}
    80006d6a:	6422                	ld	s0,8(sp)
    80006d6c:	0141                	addi	sp,sp,16
    80006d6e:	8082                	ret

0000000080006d70 <plicinithart>:

void
plicinithart(void)
{
    80006d70:	1141                	addi	sp,sp,-16
    80006d72:	e406                	sd	ra,8(sp)
    80006d74:	e022                	sd	s0,0(sp)
    80006d76:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006d78:	ffffb097          	auipc	ra,0xffffb
    80006d7c:	c0a080e7          	jalr	-1014(ra) # 80001982 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006d80:	0085171b          	slliw	a4,a0,0x8
    80006d84:	0c0027b7          	lui	a5,0xc002
    80006d88:	97ba                	add	a5,a5,a4
    80006d8a:	40200713          	li	a4,1026
    80006d8e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006d92:	00d5151b          	slliw	a0,a0,0xd
    80006d96:	0c2017b7          	lui	a5,0xc201
    80006d9a:	953e                	add	a0,a0,a5
    80006d9c:	00052023          	sw	zero,0(a0)
}
    80006da0:	60a2                	ld	ra,8(sp)
    80006da2:	6402                	ld	s0,0(sp)
    80006da4:	0141                	addi	sp,sp,16
    80006da6:	8082                	ret

0000000080006da8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006da8:	1141                	addi	sp,sp,-16
    80006daa:	e406                	sd	ra,8(sp)
    80006dac:	e022                	sd	s0,0(sp)
    80006dae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006db0:	ffffb097          	auipc	ra,0xffffb
    80006db4:	bd2080e7          	jalr	-1070(ra) # 80001982 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006db8:	00d5179b          	slliw	a5,a0,0xd
    80006dbc:	0c201537          	lui	a0,0xc201
    80006dc0:	953e                	add	a0,a0,a5
  return irq;
}
    80006dc2:	4148                	lw	a0,4(a0)
    80006dc4:	60a2                	ld	ra,8(sp)
    80006dc6:	6402                	ld	s0,0(sp)
    80006dc8:	0141                	addi	sp,sp,16
    80006dca:	8082                	ret

0000000080006dcc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006dcc:	1101                	addi	sp,sp,-32
    80006dce:	ec06                	sd	ra,24(sp)
    80006dd0:	e822                	sd	s0,16(sp)
    80006dd2:	e426                	sd	s1,8(sp)
    80006dd4:	1000                	addi	s0,sp,32
    80006dd6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006dd8:	ffffb097          	auipc	ra,0xffffb
    80006ddc:	baa080e7          	jalr	-1110(ra) # 80001982 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006de0:	00d5151b          	slliw	a0,a0,0xd
    80006de4:	0c2017b7          	lui	a5,0xc201
    80006de8:	97aa                	add	a5,a5,a0
    80006dea:	c3c4                	sw	s1,4(a5)
}
    80006dec:	60e2                	ld	ra,24(sp)
    80006dee:	6442                	ld	s0,16(sp)
    80006df0:	64a2                	ld	s1,8(sp)
    80006df2:	6105                	addi	sp,sp,32
    80006df4:	8082                	ret

0000000080006df6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006df6:	1141                	addi	sp,sp,-16
    80006df8:	e406                	sd	ra,8(sp)
    80006dfa:	e022                	sd	s0,0(sp)
    80006dfc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006dfe:	479d                	li	a5,7
    80006e00:	06a7c963          	blt	a5,a0,80006e72 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006e04:	0001d797          	auipc	a5,0x1d
    80006e08:	1fc78793          	addi	a5,a5,508 # 80024000 <disk>
    80006e0c:	00a78733          	add	a4,a5,a0
    80006e10:	6789                	lui	a5,0x2
    80006e12:	97ba                	add	a5,a5,a4
    80006e14:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006e18:	e7ad                	bnez	a5,80006e82 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006e1a:	00451793          	slli	a5,a0,0x4
    80006e1e:	0001f717          	auipc	a4,0x1f
    80006e22:	1e270713          	addi	a4,a4,482 # 80026000 <disk+0x2000>
    80006e26:	6314                	ld	a3,0(a4)
    80006e28:	96be                	add	a3,a3,a5
    80006e2a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006e2e:	6314                	ld	a3,0(a4)
    80006e30:	96be                	add	a3,a3,a5
    80006e32:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006e36:	6314                	ld	a3,0(a4)
    80006e38:	96be                	add	a3,a3,a5
    80006e3a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006e3e:	6318                	ld	a4,0(a4)
    80006e40:	97ba                	add	a5,a5,a4
    80006e42:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006e46:	0001d797          	auipc	a5,0x1d
    80006e4a:	1ba78793          	addi	a5,a5,442 # 80024000 <disk>
    80006e4e:	97aa                	add	a5,a5,a0
    80006e50:	6509                	lui	a0,0x2
    80006e52:	953e                	add	a0,a0,a5
    80006e54:	4785                	li	a5,1
    80006e56:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006e5a:	0001f517          	auipc	a0,0x1f
    80006e5e:	1be50513          	addi	a0,a0,446 # 80026018 <disk+0x2018>
    80006e62:	ffffc097          	auipc	ra,0xffffc
    80006e66:	d36080e7          	jalr	-714(ra) # 80002b98 <wakeup>
}
    80006e6a:	60a2                	ld	ra,8(sp)
    80006e6c:	6402                	ld	s0,0(sp)
    80006e6e:	0141                	addi	sp,sp,16
    80006e70:	8082                	ret
    panic("free_desc 1");
    80006e72:	00003517          	auipc	a0,0x3
    80006e76:	b4e50513          	addi	a0,a0,-1202 # 800099c0 <syscalls+0x380>
    80006e7a:	ffff9097          	auipc	ra,0xffff9
    80006e7e:	6c2080e7          	jalr	1730(ra) # 8000053c <panic>
    panic("free_desc 2");
    80006e82:	00003517          	auipc	a0,0x3
    80006e86:	b4e50513          	addi	a0,a0,-1202 # 800099d0 <syscalls+0x390>
    80006e8a:	ffff9097          	auipc	ra,0xffff9
    80006e8e:	6b2080e7          	jalr	1714(ra) # 8000053c <panic>

0000000080006e92 <virtio_disk_init>:
{
    80006e92:	1101                	addi	sp,sp,-32
    80006e94:	ec06                	sd	ra,24(sp)
    80006e96:	e822                	sd	s0,16(sp)
    80006e98:	e426                	sd	s1,8(sp)
    80006e9a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006e9c:	00003597          	auipc	a1,0x3
    80006ea0:	b4458593          	addi	a1,a1,-1212 # 800099e0 <syscalls+0x3a0>
    80006ea4:	0001f517          	auipc	a0,0x1f
    80006ea8:	28450513          	addi	a0,a0,644 # 80026128 <disk+0x2128>
    80006eac:	ffffa097          	auipc	ra,0xffffa
    80006eb0:	ca6080e7          	jalr	-858(ra) # 80000b52 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006eb4:	100017b7          	lui	a5,0x10001
    80006eb8:	4398                	lw	a4,0(a5)
    80006eba:	2701                	sext.w	a4,a4
    80006ebc:	747277b7          	lui	a5,0x74727
    80006ec0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006ec4:	0ef71163          	bne	a4,a5,80006fa6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006ec8:	100017b7          	lui	a5,0x10001
    80006ecc:	43dc                	lw	a5,4(a5)
    80006ece:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006ed0:	4705                	li	a4,1
    80006ed2:	0ce79a63          	bne	a5,a4,80006fa6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006ed6:	100017b7          	lui	a5,0x10001
    80006eda:	479c                	lw	a5,8(a5)
    80006edc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006ede:	4709                	li	a4,2
    80006ee0:	0ce79363          	bne	a5,a4,80006fa6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006ee4:	100017b7          	lui	a5,0x10001
    80006ee8:	47d8                	lw	a4,12(a5)
    80006eea:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006eec:	554d47b7          	lui	a5,0x554d4
    80006ef0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006ef4:	0af71963          	bne	a4,a5,80006fa6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006ef8:	100017b7          	lui	a5,0x10001
    80006efc:	4705                	li	a4,1
    80006efe:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006f00:	470d                	li	a4,3
    80006f02:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006f04:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006f06:	c7ffe737          	lui	a4,0xc7ffe
    80006f0a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd775f>
    80006f0e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006f10:	2701                	sext.w	a4,a4
    80006f12:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006f14:	472d                	li	a4,11
    80006f16:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006f18:	473d                	li	a4,15
    80006f1a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006f1c:	6705                	lui	a4,0x1
    80006f1e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006f20:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006f24:	5bdc                	lw	a5,52(a5)
    80006f26:	2781                	sext.w	a5,a5
  if(max == 0)
    80006f28:	c7d9                	beqz	a5,80006fb6 <virtio_disk_init+0x124>
  if(max < NUM)
    80006f2a:	471d                	li	a4,7
    80006f2c:	08f77d63          	bgeu	a4,a5,80006fc6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006f30:	100014b7          	lui	s1,0x10001
    80006f34:	47a1                	li	a5,8
    80006f36:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006f38:	6609                	lui	a2,0x2
    80006f3a:	4581                	li	a1,0
    80006f3c:	0001d517          	auipc	a0,0x1d
    80006f40:	0c450513          	addi	a0,a0,196 # 80024000 <disk>
    80006f44:	ffffa097          	auipc	ra,0xffffa
    80006f48:	d9a080e7          	jalr	-614(ra) # 80000cde <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006f4c:	0001d717          	auipc	a4,0x1d
    80006f50:	0b470713          	addi	a4,a4,180 # 80024000 <disk>
    80006f54:	00c75793          	srli	a5,a4,0xc
    80006f58:	2781                	sext.w	a5,a5
    80006f5a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006f5c:	0001f797          	auipc	a5,0x1f
    80006f60:	0a478793          	addi	a5,a5,164 # 80026000 <disk+0x2000>
    80006f64:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006f66:	0001d717          	auipc	a4,0x1d
    80006f6a:	11a70713          	addi	a4,a4,282 # 80024080 <disk+0x80>
    80006f6e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006f70:	0001e717          	auipc	a4,0x1e
    80006f74:	09070713          	addi	a4,a4,144 # 80025000 <disk+0x1000>
    80006f78:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006f7a:	4705                	li	a4,1
    80006f7c:	00e78c23          	sb	a4,24(a5)
    80006f80:	00e78ca3          	sb	a4,25(a5)
    80006f84:	00e78d23          	sb	a4,26(a5)
    80006f88:	00e78da3          	sb	a4,27(a5)
    80006f8c:	00e78e23          	sb	a4,28(a5)
    80006f90:	00e78ea3          	sb	a4,29(a5)
    80006f94:	00e78f23          	sb	a4,30(a5)
    80006f98:	00e78fa3          	sb	a4,31(a5)
}
    80006f9c:	60e2                	ld	ra,24(sp)
    80006f9e:	6442                	ld	s0,16(sp)
    80006fa0:	64a2                	ld	s1,8(sp)
    80006fa2:	6105                	addi	sp,sp,32
    80006fa4:	8082                	ret
    panic("could not find virtio disk");
    80006fa6:	00003517          	auipc	a0,0x3
    80006faa:	a4a50513          	addi	a0,a0,-1462 # 800099f0 <syscalls+0x3b0>
    80006fae:	ffff9097          	auipc	ra,0xffff9
    80006fb2:	58e080e7          	jalr	1422(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80006fb6:	00003517          	auipc	a0,0x3
    80006fba:	a5a50513          	addi	a0,a0,-1446 # 80009a10 <syscalls+0x3d0>
    80006fbe:	ffff9097          	auipc	ra,0xffff9
    80006fc2:	57e080e7          	jalr	1406(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80006fc6:	00003517          	auipc	a0,0x3
    80006fca:	a6a50513          	addi	a0,a0,-1430 # 80009a30 <syscalls+0x3f0>
    80006fce:	ffff9097          	auipc	ra,0xffff9
    80006fd2:	56e080e7          	jalr	1390(ra) # 8000053c <panic>

0000000080006fd6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006fd6:	7159                	addi	sp,sp,-112
    80006fd8:	f486                	sd	ra,104(sp)
    80006fda:	f0a2                	sd	s0,96(sp)
    80006fdc:	eca6                	sd	s1,88(sp)
    80006fde:	e8ca                	sd	s2,80(sp)
    80006fe0:	e4ce                	sd	s3,72(sp)
    80006fe2:	e0d2                	sd	s4,64(sp)
    80006fe4:	fc56                	sd	s5,56(sp)
    80006fe6:	f85a                	sd	s6,48(sp)
    80006fe8:	f45e                	sd	s7,40(sp)
    80006fea:	f062                	sd	s8,32(sp)
    80006fec:	ec66                	sd	s9,24(sp)
    80006fee:	e86a                	sd	s10,16(sp)
    80006ff0:	1880                	addi	s0,sp,112
    80006ff2:	892a                	mv	s2,a0
    80006ff4:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006ff6:	00c52c83          	lw	s9,12(a0)
    80006ffa:	001c9c9b          	slliw	s9,s9,0x1
    80006ffe:	1c82                	slli	s9,s9,0x20
    80007000:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80007004:	0001f517          	auipc	a0,0x1f
    80007008:	12450513          	addi	a0,a0,292 # 80026128 <disk+0x2128>
    8000700c:	ffffa097          	auipc	ra,0xffffa
    80007010:	bd6080e7          	jalr	-1066(ra) # 80000be2 <acquire>
  for(int i = 0; i < 3; i++){
    80007014:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80007016:	4c21                	li	s8,8
      disk.free[i] = 0;
    80007018:	0001db97          	auipc	s7,0x1d
    8000701c:	fe8b8b93          	addi	s7,s7,-24 # 80024000 <disk>
    80007020:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80007022:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80007024:	8a4e                	mv	s4,s3
    80007026:	a051                	j	800070aa <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80007028:	00fb86b3          	add	a3,s7,a5
    8000702c:	96da                	add	a3,a3,s6
    8000702e:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80007032:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80007034:	0207c563          	bltz	a5,8000705e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80007038:	2485                	addiw	s1,s1,1
    8000703a:	0711                	addi	a4,a4,4
    8000703c:	25548063          	beq	s1,s5,8000727c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80007040:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80007042:	0001f697          	auipc	a3,0x1f
    80007046:	fd668693          	addi	a3,a3,-42 # 80026018 <disk+0x2018>
    8000704a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    8000704c:	0006c583          	lbu	a1,0(a3)
    80007050:	fde1                	bnez	a1,80007028 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80007052:	2785                	addiw	a5,a5,1
    80007054:	0685                	addi	a3,a3,1
    80007056:	ff879be3          	bne	a5,s8,8000704c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000705a:	57fd                	li	a5,-1
    8000705c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000705e:	02905a63          	blez	s1,80007092 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80007062:	f9042503          	lw	a0,-112(s0)
    80007066:	00000097          	auipc	ra,0x0
    8000706a:	d90080e7          	jalr	-624(ra) # 80006df6 <free_desc>
      for(int j = 0; j < i; j++)
    8000706e:	4785                	li	a5,1
    80007070:	0297d163          	bge	a5,s1,80007092 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80007074:	f9442503          	lw	a0,-108(s0)
    80007078:	00000097          	auipc	ra,0x0
    8000707c:	d7e080e7          	jalr	-642(ra) # 80006df6 <free_desc>
      for(int j = 0; j < i; j++)
    80007080:	4789                	li	a5,2
    80007082:	0097d863          	bge	a5,s1,80007092 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80007086:	f9842503          	lw	a0,-104(s0)
    8000708a:	00000097          	auipc	ra,0x0
    8000708e:	d6c080e7          	jalr	-660(ra) # 80006df6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80007092:	0001f597          	auipc	a1,0x1f
    80007096:	09658593          	addi	a1,a1,150 # 80026128 <disk+0x2128>
    8000709a:	0001f517          	auipc	a0,0x1f
    8000709e:	f7e50513          	addi	a0,a0,-130 # 80026018 <disk+0x2018>
    800070a2:	ffffb097          	auipc	ra,0xffffb
    800070a6:	654080e7          	jalr	1620(ra) # 800026f6 <sleep>
  for(int i = 0; i < 3; i++){
    800070aa:	f9040713          	addi	a4,s0,-112
    800070ae:	84ce                	mv	s1,s3
    800070b0:	bf41                	j	80007040 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800070b2:	20058713          	addi	a4,a1,512
    800070b6:	00471693          	slli	a3,a4,0x4
    800070ba:	0001d717          	auipc	a4,0x1d
    800070be:	f4670713          	addi	a4,a4,-186 # 80024000 <disk>
    800070c2:	9736                	add	a4,a4,a3
    800070c4:	4685                	li	a3,1
    800070c6:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800070ca:	20058713          	addi	a4,a1,512
    800070ce:	00471693          	slli	a3,a4,0x4
    800070d2:	0001d717          	auipc	a4,0x1d
    800070d6:	f2e70713          	addi	a4,a4,-210 # 80024000 <disk>
    800070da:	9736                	add	a4,a4,a3
    800070dc:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800070e0:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800070e4:	7679                	lui	a2,0xffffe
    800070e6:	963e                	add	a2,a2,a5
    800070e8:	0001f697          	auipc	a3,0x1f
    800070ec:	f1868693          	addi	a3,a3,-232 # 80026000 <disk+0x2000>
    800070f0:	6298                	ld	a4,0(a3)
    800070f2:	9732                	add	a4,a4,a2
    800070f4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800070f6:	6298                	ld	a4,0(a3)
    800070f8:	9732                	add	a4,a4,a2
    800070fa:	4541                	li	a0,16
    800070fc:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800070fe:	6298                	ld	a4,0(a3)
    80007100:	9732                	add	a4,a4,a2
    80007102:	4505                	li	a0,1
    80007104:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007108:	f9442703          	lw	a4,-108(s0)
    8000710c:	6288                	ld	a0,0(a3)
    8000710e:	962a                	add	a2,a2,a0
    80007110:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd700e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80007114:	0712                	slli	a4,a4,0x4
    80007116:	6290                	ld	a2,0(a3)
    80007118:	963a                	add	a2,a2,a4
    8000711a:	05890513          	addi	a0,s2,88
    8000711e:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80007120:	6294                	ld	a3,0(a3)
    80007122:	96ba                	add	a3,a3,a4
    80007124:	40000613          	li	a2,1024
    80007128:	c690                	sw	a2,8(a3)
  if(write)
    8000712a:	140d0063          	beqz	s10,8000726a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000712e:	0001f697          	auipc	a3,0x1f
    80007132:	ed26b683          	ld	a3,-302(a3) # 80026000 <disk+0x2000>
    80007136:	96ba                	add	a3,a3,a4
    80007138:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000713c:	0001d817          	auipc	a6,0x1d
    80007140:	ec480813          	addi	a6,a6,-316 # 80024000 <disk>
    80007144:	0001f517          	auipc	a0,0x1f
    80007148:	ebc50513          	addi	a0,a0,-324 # 80026000 <disk+0x2000>
    8000714c:	6114                	ld	a3,0(a0)
    8000714e:	96ba                	add	a3,a3,a4
    80007150:	00c6d603          	lhu	a2,12(a3)
    80007154:	00166613          	ori	a2,a2,1
    80007158:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000715c:	f9842683          	lw	a3,-104(s0)
    80007160:	6110                	ld	a2,0(a0)
    80007162:	9732                	add	a4,a4,a2
    80007164:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80007168:	20058613          	addi	a2,a1,512
    8000716c:	0612                	slli	a2,a2,0x4
    8000716e:	9642                	add	a2,a2,a6
    80007170:	577d                	li	a4,-1
    80007172:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80007176:	00469713          	slli	a4,a3,0x4
    8000717a:	6114                	ld	a3,0(a0)
    8000717c:	96ba                	add	a3,a3,a4
    8000717e:	03078793          	addi	a5,a5,48
    80007182:	97c2                	add	a5,a5,a6
    80007184:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80007186:	611c                	ld	a5,0(a0)
    80007188:	97ba                	add	a5,a5,a4
    8000718a:	4685                	li	a3,1
    8000718c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000718e:	611c                	ld	a5,0(a0)
    80007190:	97ba                	add	a5,a5,a4
    80007192:	4809                	li	a6,2
    80007194:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80007198:	611c                	ld	a5,0(a0)
    8000719a:	973e                	add	a4,a4,a5
    8000719c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800071a0:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    800071a4:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800071a8:	6518                	ld	a4,8(a0)
    800071aa:	00275783          	lhu	a5,2(a4)
    800071ae:	8b9d                	andi	a5,a5,7
    800071b0:	0786                	slli	a5,a5,0x1
    800071b2:	97ba                	add	a5,a5,a4
    800071b4:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800071b8:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800071bc:	6518                	ld	a4,8(a0)
    800071be:	00275783          	lhu	a5,2(a4)
    800071c2:	2785                	addiw	a5,a5,1
    800071c4:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800071c8:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800071cc:	100017b7          	lui	a5,0x10001
    800071d0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800071d4:	00492703          	lw	a4,4(s2)
    800071d8:	4785                	li	a5,1
    800071da:	02f71163          	bne	a4,a5,800071fc <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    800071de:	0001f997          	auipc	s3,0x1f
    800071e2:	f4a98993          	addi	s3,s3,-182 # 80026128 <disk+0x2128>
  while(b->disk == 1) {
    800071e6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800071e8:	85ce                	mv	a1,s3
    800071ea:	854a                	mv	a0,s2
    800071ec:	ffffb097          	auipc	ra,0xffffb
    800071f0:	50a080e7          	jalr	1290(ra) # 800026f6 <sleep>
  while(b->disk == 1) {
    800071f4:	00492783          	lw	a5,4(s2)
    800071f8:	fe9788e3          	beq	a5,s1,800071e8 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    800071fc:	f9042903          	lw	s2,-112(s0)
    80007200:	20090793          	addi	a5,s2,512
    80007204:	00479713          	slli	a4,a5,0x4
    80007208:	0001d797          	auipc	a5,0x1d
    8000720c:	df878793          	addi	a5,a5,-520 # 80024000 <disk>
    80007210:	97ba                	add	a5,a5,a4
    80007212:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80007216:	0001f997          	auipc	s3,0x1f
    8000721a:	dea98993          	addi	s3,s3,-534 # 80026000 <disk+0x2000>
    8000721e:	00491713          	slli	a4,s2,0x4
    80007222:	0009b783          	ld	a5,0(s3)
    80007226:	97ba                	add	a5,a5,a4
    80007228:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000722c:	854a                	mv	a0,s2
    8000722e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80007232:	00000097          	auipc	ra,0x0
    80007236:	bc4080e7          	jalr	-1084(ra) # 80006df6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000723a:	8885                	andi	s1,s1,1
    8000723c:	f0ed                	bnez	s1,8000721e <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000723e:	0001f517          	auipc	a0,0x1f
    80007242:	eea50513          	addi	a0,a0,-278 # 80026128 <disk+0x2128>
    80007246:	ffffa097          	auipc	ra,0xffffa
    8000724a:	a50080e7          	jalr	-1456(ra) # 80000c96 <release>
}
    8000724e:	70a6                	ld	ra,104(sp)
    80007250:	7406                	ld	s0,96(sp)
    80007252:	64e6                	ld	s1,88(sp)
    80007254:	6946                	ld	s2,80(sp)
    80007256:	69a6                	ld	s3,72(sp)
    80007258:	6a06                	ld	s4,64(sp)
    8000725a:	7ae2                	ld	s5,56(sp)
    8000725c:	7b42                	ld	s6,48(sp)
    8000725e:	7ba2                	ld	s7,40(sp)
    80007260:	7c02                	ld	s8,32(sp)
    80007262:	6ce2                	ld	s9,24(sp)
    80007264:	6d42                	ld	s10,16(sp)
    80007266:	6165                	addi	sp,sp,112
    80007268:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000726a:	0001f697          	auipc	a3,0x1f
    8000726e:	d966b683          	ld	a3,-618(a3) # 80026000 <disk+0x2000>
    80007272:	96ba                	add	a3,a3,a4
    80007274:	4609                	li	a2,2
    80007276:	00c69623          	sh	a2,12(a3)
    8000727a:	b5c9                	j	8000713c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000727c:	f9042583          	lw	a1,-112(s0)
    80007280:	20058793          	addi	a5,a1,512
    80007284:	0792                	slli	a5,a5,0x4
    80007286:	0001d517          	auipc	a0,0x1d
    8000728a:	e2250513          	addi	a0,a0,-478 # 800240a8 <disk+0xa8>
    8000728e:	953e                	add	a0,a0,a5
  if(write)
    80007290:	e20d11e3          	bnez	s10,800070b2 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80007294:	20058713          	addi	a4,a1,512
    80007298:	00471693          	slli	a3,a4,0x4
    8000729c:	0001d717          	auipc	a4,0x1d
    800072a0:	d6470713          	addi	a4,a4,-668 # 80024000 <disk>
    800072a4:	9736                	add	a4,a4,a3
    800072a6:	0a072423          	sw	zero,168(a4)
    800072aa:	b505                	j	800070ca <virtio_disk_rw+0xf4>

00000000800072ac <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800072ac:	1101                	addi	sp,sp,-32
    800072ae:	ec06                	sd	ra,24(sp)
    800072b0:	e822                	sd	s0,16(sp)
    800072b2:	e426                	sd	s1,8(sp)
    800072b4:	e04a                	sd	s2,0(sp)
    800072b6:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800072b8:	0001f517          	auipc	a0,0x1f
    800072bc:	e7050513          	addi	a0,a0,-400 # 80026128 <disk+0x2128>
    800072c0:	ffffa097          	auipc	ra,0xffffa
    800072c4:	922080e7          	jalr	-1758(ra) # 80000be2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800072c8:	10001737          	lui	a4,0x10001
    800072cc:	533c                	lw	a5,96(a4)
    800072ce:	8b8d                	andi	a5,a5,3
    800072d0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800072d2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800072d6:	0001f797          	auipc	a5,0x1f
    800072da:	d2a78793          	addi	a5,a5,-726 # 80026000 <disk+0x2000>
    800072de:	6b94                	ld	a3,16(a5)
    800072e0:	0207d703          	lhu	a4,32(a5)
    800072e4:	0026d783          	lhu	a5,2(a3)
    800072e8:	06f70163          	beq	a4,a5,8000734a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800072ec:	0001d917          	auipc	s2,0x1d
    800072f0:	d1490913          	addi	s2,s2,-748 # 80024000 <disk>
    800072f4:	0001f497          	auipc	s1,0x1f
    800072f8:	d0c48493          	addi	s1,s1,-756 # 80026000 <disk+0x2000>
    __sync_synchronize();
    800072fc:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007300:	6898                	ld	a4,16(s1)
    80007302:	0204d783          	lhu	a5,32(s1)
    80007306:	8b9d                	andi	a5,a5,7
    80007308:	078e                	slli	a5,a5,0x3
    8000730a:	97ba                	add	a5,a5,a4
    8000730c:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000730e:	20078713          	addi	a4,a5,512
    80007312:	0712                	slli	a4,a4,0x4
    80007314:	974a                	add	a4,a4,s2
    80007316:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000731a:	e731                	bnez	a4,80007366 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000731c:	20078793          	addi	a5,a5,512
    80007320:	0792                	slli	a5,a5,0x4
    80007322:	97ca                	add	a5,a5,s2
    80007324:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007326:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000732a:	ffffc097          	auipc	ra,0xffffc
    8000732e:	86e080e7          	jalr	-1938(ra) # 80002b98 <wakeup>

    disk.used_idx += 1;
    80007332:	0204d783          	lhu	a5,32(s1)
    80007336:	2785                	addiw	a5,a5,1
    80007338:	17c2                	slli	a5,a5,0x30
    8000733a:	93c1                	srli	a5,a5,0x30
    8000733c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007340:	6898                	ld	a4,16(s1)
    80007342:	00275703          	lhu	a4,2(a4)
    80007346:	faf71be3          	bne	a4,a5,800072fc <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000734a:	0001f517          	auipc	a0,0x1f
    8000734e:	dde50513          	addi	a0,a0,-546 # 80026128 <disk+0x2128>
    80007352:	ffffa097          	auipc	ra,0xffffa
    80007356:	944080e7          	jalr	-1724(ra) # 80000c96 <release>
}
    8000735a:	60e2                	ld	ra,24(sp)
    8000735c:	6442                	ld	s0,16(sp)
    8000735e:	64a2                	ld	s1,8(sp)
    80007360:	6902                	ld	s2,0(sp)
    80007362:	6105                	addi	sp,sp,32
    80007364:	8082                	ret
      panic("virtio_disk_intr status");
    80007366:	00002517          	auipc	a0,0x2
    8000736a:	6ea50513          	addi	a0,a0,1770 # 80009a50 <syscalls+0x410>
    8000736e:	ffff9097          	auipc	ra,0xffff9
    80007372:	1ce080e7          	jalr	462(ra) # 8000053c <panic>
	...

0000000080008000 <_trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
	...
