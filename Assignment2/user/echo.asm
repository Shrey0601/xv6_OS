
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  int i;

  for(i = 1; i < argc; i++){
  10:	4785                	li	a5,1
  12:	06a7d463          	bge	a5,a0,7a <main+0x7a>
  16:	00858493          	addi	s1,a1,8
  1a:	ffe5099b          	addiw	s3,a0,-2
  1e:	1982                	slli	s3,s3,0x20
  20:	0209d993          	srli	s3,s3,0x20
  24:	098e                	slli	s3,s3,0x3
  26:	05c1                	addi	a1,a1,16
  28:	99ae                	add	s3,s3,a1
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  2a:	00001a17          	auipc	s4,0x1
  2e:	836a0a13          	addi	s4,s4,-1994 # 860 <malloc+0xe8>
    write(1, argv[i], strlen(argv[i]));
  32:	0004b903          	ld	s2,0(s1)
  36:	854a                	mv	a0,s2
  38:	00000097          	auipc	ra,0x0
  3c:	094080e7          	jalr	148(ra) # cc <strlen>
  40:	0005061b          	sext.w	a2,a0
  44:	85ca                	mv	a1,s2
  46:	4505                	li	a0,1
  48:	00000097          	auipc	ra,0x0
  4c:	2d2080e7          	jalr	722(ra) # 31a <write>
    if(i + 1 < argc){
  50:	04a1                	addi	s1,s1,8
  52:	01348a63          	beq	s1,s3,66 <main+0x66>
      write(1, " ", 1);
  56:	4605                	li	a2,1
  58:	85d2                	mv	a1,s4
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	2be080e7          	jalr	702(ra) # 31a <write>
  for(i = 1; i < argc; i++){
  64:	b7f9                	j	32 <main+0x32>
    } else {
      write(1, "\n", 1);
  66:	4605                	li	a2,1
  68:	00001597          	auipc	a1,0x1
  6c:	80058593          	addi	a1,a1,-2048 # 868 <malloc+0xf0>
  70:	4505                	li	a0,1
  72:	00000097          	auipc	ra,0x0
  76:	2a8080e7          	jalr	680(ra) # 31a <write>
    }
  }
  exit(0);
  7a:	4501                	li	a0,0
  7c:	00000097          	auipc	ra,0x0
  80:	27e080e7          	jalr	638(ra) # 2fa <exit>

0000000000000084 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  84:	1141                	addi	sp,sp,-16
  86:	e422                	sd	s0,8(sp)
  88:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  8a:	87aa                	mv	a5,a0
  8c:	0585                	addi	a1,a1,1
  8e:	0785                	addi	a5,a5,1
  90:	fff5c703          	lbu	a4,-1(a1)
  94:	fee78fa3          	sb	a4,-1(a5)
  98:	fb75                	bnez	a4,8c <strcpy+0x8>
    ;
  return os;
}
  9a:	6422                	ld	s0,8(sp)
  9c:	0141                	addi	sp,sp,16
  9e:	8082                	ret

00000000000000a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a6:	00054783          	lbu	a5,0(a0)
  aa:	cb91                	beqz	a5,be <strcmp+0x1e>
  ac:	0005c703          	lbu	a4,0(a1)
  b0:	00f71763          	bne	a4,a5,be <strcmp+0x1e>
    p++, q++;
  b4:	0505                	addi	a0,a0,1
  b6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b8:	00054783          	lbu	a5,0(a0)
  bc:	fbe5                	bnez	a5,ac <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  be:	0005c503          	lbu	a0,0(a1)
}
  c2:	40a7853b          	subw	a0,a5,a0
  c6:	6422                	ld	s0,8(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret

00000000000000cc <strlen>:

uint
strlen(const char *s)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d2:	00054783          	lbu	a5,0(a0)
  d6:	cf91                	beqz	a5,f2 <strlen+0x26>
  d8:	0505                	addi	a0,a0,1
  da:	87aa                	mv	a5,a0
  dc:	4685                	li	a3,1
  de:	9e89                	subw	a3,a3,a0
  e0:	00f6853b          	addw	a0,a3,a5
  e4:	0785                	addi	a5,a5,1
  e6:	fff7c703          	lbu	a4,-1(a5)
  ea:	fb7d                	bnez	a4,e0 <strlen+0x14>
    ;
  return n;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret
  for(n = 0; s[n]; n++)
  f2:	4501                	li	a0,0
  f4:	bfe5                	j	ec <strlen+0x20>

00000000000000f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e422                	sd	s0,8(sp)
  fa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  fc:	ce09                	beqz	a2,116 <memset+0x20>
  fe:	87aa                	mv	a5,a0
 100:	fff6071b          	addiw	a4,a2,-1
 104:	1702                	slli	a4,a4,0x20
 106:	9301                	srli	a4,a4,0x20
 108:	0705                	addi	a4,a4,1
 10a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 10c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 110:	0785                	addi	a5,a5,1
 112:	fee79de3          	bne	a5,a4,10c <memset+0x16>
  }
  return dst;
}
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strchr>:

char*
strchr(const char *s, char c)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e422                	sd	s0,8(sp)
 120:	0800                	addi	s0,sp,16
  for(; *s; s++)
 122:	00054783          	lbu	a5,0(a0)
 126:	cb99                	beqz	a5,13c <strchr+0x20>
    if(*s == c)
 128:	00f58763          	beq	a1,a5,136 <strchr+0x1a>
  for(; *s; s++)
 12c:	0505                	addi	a0,a0,1
 12e:	00054783          	lbu	a5,0(a0)
 132:	fbfd                	bnez	a5,128 <strchr+0xc>
      return (char*)s;
  return 0;
 134:	4501                	li	a0,0
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret
  return 0;
 13c:	4501                	li	a0,0
 13e:	bfe5                	j	136 <strchr+0x1a>

0000000000000140 <gets>:

char*
gets(char *buf, int max)
{
 140:	711d                	addi	sp,sp,-96
 142:	ec86                	sd	ra,88(sp)
 144:	e8a2                	sd	s0,80(sp)
 146:	e4a6                	sd	s1,72(sp)
 148:	e0ca                	sd	s2,64(sp)
 14a:	fc4e                	sd	s3,56(sp)
 14c:	f852                	sd	s4,48(sp)
 14e:	f456                	sd	s5,40(sp)
 150:	f05a                	sd	s6,32(sp)
 152:	ec5e                	sd	s7,24(sp)
 154:	1080                	addi	s0,sp,96
 156:	8baa                	mv	s7,a0
 158:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15a:	892a                	mv	s2,a0
 15c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 15e:	4aa9                	li	s5,10
 160:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 162:	89a6                	mv	s3,s1
 164:	2485                	addiw	s1,s1,1
 166:	0344d863          	bge	s1,s4,196 <gets+0x56>
    cc = read(0, &c, 1);
 16a:	4605                	li	a2,1
 16c:	faf40593          	addi	a1,s0,-81
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	1a0080e7          	jalr	416(ra) # 312 <read>
    if(cc < 1)
 17a:	00a05e63          	blez	a0,196 <gets+0x56>
    buf[i++] = c;
 17e:	faf44783          	lbu	a5,-81(s0)
 182:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 186:	01578763          	beq	a5,s5,194 <gets+0x54>
 18a:	0905                	addi	s2,s2,1
 18c:	fd679be3          	bne	a5,s6,162 <gets+0x22>
  for(i=0; i+1 < max; ){
 190:	89a6                	mv	s3,s1
 192:	a011                	j	196 <gets+0x56>
 194:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 196:	99de                	add	s3,s3,s7
 198:	00098023          	sb	zero,0(s3)
  return buf;
}
 19c:	855e                	mv	a0,s7
 19e:	60e6                	ld	ra,88(sp)
 1a0:	6446                	ld	s0,80(sp)
 1a2:	64a6                	ld	s1,72(sp)
 1a4:	6906                	ld	s2,64(sp)
 1a6:	79e2                	ld	s3,56(sp)
 1a8:	7a42                	ld	s4,48(sp)
 1aa:	7aa2                	ld	s5,40(sp)
 1ac:	7b02                	ld	s6,32(sp)
 1ae:	6be2                	ld	s7,24(sp)
 1b0:	6125                	addi	sp,sp,96
 1b2:	8082                	ret

00000000000001b4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b4:	1101                	addi	sp,sp,-32
 1b6:	ec06                	sd	ra,24(sp)
 1b8:	e822                	sd	s0,16(sp)
 1ba:	e426                	sd	s1,8(sp)
 1bc:	e04a                	sd	s2,0(sp)
 1be:	1000                	addi	s0,sp,32
 1c0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c2:	4581                	li	a1,0
 1c4:	00000097          	auipc	ra,0x0
 1c8:	176080e7          	jalr	374(ra) # 33a <open>
  if(fd < 0)
 1cc:	02054563          	bltz	a0,1f6 <stat+0x42>
 1d0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1d2:	85ca                	mv	a1,s2
 1d4:	00000097          	auipc	ra,0x0
 1d8:	17e080e7          	jalr	382(ra) # 352 <fstat>
 1dc:	892a                	mv	s2,a0
  close(fd);
 1de:	8526                	mv	a0,s1
 1e0:	00000097          	auipc	ra,0x0
 1e4:	142080e7          	jalr	322(ra) # 322 <close>
  return r;
}
 1e8:	854a                	mv	a0,s2
 1ea:	60e2                	ld	ra,24(sp)
 1ec:	6442                	ld	s0,16(sp)
 1ee:	64a2                	ld	s1,8(sp)
 1f0:	6902                	ld	s2,0(sp)
 1f2:	6105                	addi	sp,sp,32
 1f4:	8082                	ret
    return -1;
 1f6:	597d                	li	s2,-1
 1f8:	bfc5                	j	1e8 <stat+0x34>

00000000000001fa <atoi>:

int
atoi(const char *s)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 200:	00054603          	lbu	a2,0(a0)
 204:	fd06079b          	addiw	a5,a2,-48
 208:	0ff7f793          	andi	a5,a5,255
 20c:	4725                	li	a4,9
 20e:	02f76963          	bltu	a4,a5,240 <atoi+0x46>
 212:	86aa                	mv	a3,a0
  n = 0;
 214:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 216:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 218:	0685                	addi	a3,a3,1
 21a:	0025179b          	slliw	a5,a0,0x2
 21e:	9fa9                	addw	a5,a5,a0
 220:	0017979b          	slliw	a5,a5,0x1
 224:	9fb1                	addw	a5,a5,a2
 226:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 22a:	0006c603          	lbu	a2,0(a3)
 22e:	fd06071b          	addiw	a4,a2,-48
 232:	0ff77713          	andi	a4,a4,255
 236:	fee5f1e3          	bgeu	a1,a4,218 <atoi+0x1e>
  return n;
}
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret
  n = 0;
 240:	4501                	li	a0,0
 242:	bfe5                	j	23a <atoi+0x40>

0000000000000244 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 244:	1141                	addi	sp,sp,-16
 246:	e422                	sd	s0,8(sp)
 248:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 24a:	02b57663          	bgeu	a0,a1,276 <memmove+0x32>
    while(n-- > 0)
 24e:	02c05163          	blez	a2,270 <memmove+0x2c>
 252:	fff6079b          	addiw	a5,a2,-1
 256:	1782                	slli	a5,a5,0x20
 258:	9381                	srli	a5,a5,0x20
 25a:	0785                	addi	a5,a5,1
 25c:	97aa                	add	a5,a5,a0
  dst = vdst;
 25e:	872a                	mv	a4,a0
      *dst++ = *src++;
 260:	0585                	addi	a1,a1,1
 262:	0705                	addi	a4,a4,1
 264:	fff5c683          	lbu	a3,-1(a1)
 268:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 26c:	fee79ae3          	bne	a5,a4,260 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 270:	6422                	ld	s0,8(sp)
 272:	0141                	addi	sp,sp,16
 274:	8082                	ret
    dst += n;
 276:	00c50733          	add	a4,a0,a2
    src += n;
 27a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 27c:	fec05ae3          	blez	a2,270 <memmove+0x2c>
 280:	fff6079b          	addiw	a5,a2,-1
 284:	1782                	slli	a5,a5,0x20
 286:	9381                	srli	a5,a5,0x20
 288:	fff7c793          	not	a5,a5
 28c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 28e:	15fd                	addi	a1,a1,-1
 290:	177d                	addi	a4,a4,-1
 292:	0005c683          	lbu	a3,0(a1)
 296:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 29a:	fee79ae3          	bne	a5,a4,28e <memmove+0x4a>
 29e:	bfc9                	j	270 <memmove+0x2c>

00000000000002a0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e422                	sd	s0,8(sp)
 2a4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2a6:	ca05                	beqz	a2,2d6 <memcmp+0x36>
 2a8:	fff6069b          	addiw	a3,a2,-1
 2ac:	1682                	slli	a3,a3,0x20
 2ae:	9281                	srli	a3,a3,0x20
 2b0:	0685                	addi	a3,a3,1
 2b2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2b4:	00054783          	lbu	a5,0(a0)
 2b8:	0005c703          	lbu	a4,0(a1)
 2bc:	00e79863          	bne	a5,a4,2cc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2c0:	0505                	addi	a0,a0,1
    p2++;
 2c2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2c4:	fed518e3          	bne	a0,a3,2b4 <memcmp+0x14>
  }
  return 0;
 2c8:	4501                	li	a0,0
 2ca:	a019                	j	2d0 <memcmp+0x30>
      return *p1 - *p2;
 2cc:	40e7853b          	subw	a0,a5,a4
}
 2d0:	6422                	ld	s0,8(sp)
 2d2:	0141                	addi	sp,sp,16
 2d4:	8082                	ret
  return 0;
 2d6:	4501                	li	a0,0
 2d8:	bfe5                	j	2d0 <memcmp+0x30>

00000000000002da <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e406                	sd	ra,8(sp)
 2de:	e022                	sd	s0,0(sp)
 2e0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2e2:	00000097          	auipc	ra,0x0
 2e6:	f62080e7          	jalr	-158(ra) # 244 <memmove>
}
 2ea:	60a2                	ld	ra,8(sp)
 2ec:	6402                	ld	s0,0(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret

00000000000002f2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2f2:	4885                	li	a7,1
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <exit>:
.global exit
exit:
 li a7, SYS_exit
 2fa:	4889                	li	a7,2
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <wait>:
.global wait
wait:
 li a7, SYS_wait
 302:	488d                	li	a7,3
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 30a:	4891                	li	a7,4
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <read>:
.global read
read:
 li a7, SYS_read
 312:	4895                	li	a7,5
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <write>:
.global write
write:
 li a7, SYS_write
 31a:	48c1                	li	a7,16
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <close>:
.global close
close:
 li a7, SYS_close
 322:	48d5                	li	a7,21
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <kill>:
.global kill
kill:
 li a7, SYS_kill
 32a:	4899                	li	a7,6
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <exec>:
.global exec
exec:
 li a7, SYS_exec
 332:	489d                	li	a7,7
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <open>:
.global open
open:
 li a7, SYS_open
 33a:	48bd                	li	a7,15
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 342:	48c5                	li	a7,17
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 34a:	48c9                	li	a7,18
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 352:	48a1                	li	a7,8
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <link>:
.global link
link:
 li a7, SYS_link
 35a:	48cd                	li	a7,19
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 362:	48d1                	li	a7,20
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 36a:	48a5                	li	a7,9
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <dup>:
.global dup
dup:
 li a7, SYS_dup
 372:	48a9                	li	a7,10
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 37a:	48ad                	li	a7,11
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 382:	48b1                	li	a7,12
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 38a:	48b5                	li	a7,13
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 392:	48b9                	li	a7,14
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 39a:	48d9                	li	a7,22
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <yield>:
.global yield
yield:
 li a7, SYS_yield
 3a2:	48dd                	li	a7,23
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 3aa:	48e1                	li	a7,24
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 3b2:	48e5                	li	a7,25
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 3ba:	48e9                	li	a7,26
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <ps>:
.global ps
ps:
 li a7, SYS_ps
 3c2:	48ed                	li	a7,27
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 3ca:	48f1                	li	a7,28
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 3d2:	48f5                	li	a7,29
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 3da:	48f9                	li	a7,30
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3e2:	1101                	addi	sp,sp,-32
 3e4:	ec06                	sd	ra,24(sp)
 3e6:	e822                	sd	s0,16(sp)
 3e8:	1000                	addi	s0,sp,32
 3ea:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ee:	4605                	li	a2,1
 3f0:	fef40593          	addi	a1,s0,-17
 3f4:	00000097          	auipc	ra,0x0
 3f8:	f26080e7          	jalr	-218(ra) # 31a <write>
}
 3fc:	60e2                	ld	ra,24(sp)
 3fe:	6442                	ld	s0,16(sp)
 400:	6105                	addi	sp,sp,32
 402:	8082                	ret

0000000000000404 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 404:	7139                	addi	sp,sp,-64
 406:	fc06                	sd	ra,56(sp)
 408:	f822                	sd	s0,48(sp)
 40a:	f426                	sd	s1,40(sp)
 40c:	f04a                	sd	s2,32(sp)
 40e:	ec4e                	sd	s3,24(sp)
 410:	0080                	addi	s0,sp,64
 412:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 414:	c299                	beqz	a3,41a <printint+0x16>
 416:	0805c863          	bltz	a1,4a6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 41a:	2581                	sext.w	a1,a1
  neg = 0;
 41c:	4881                	li	a7,0
 41e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 422:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 424:	2601                	sext.w	a2,a2
 426:	00000517          	auipc	a0,0x0
 42a:	45250513          	addi	a0,a0,1106 # 878 <digits>
 42e:	883a                	mv	a6,a4
 430:	2705                	addiw	a4,a4,1
 432:	02c5f7bb          	remuw	a5,a1,a2
 436:	1782                	slli	a5,a5,0x20
 438:	9381                	srli	a5,a5,0x20
 43a:	97aa                	add	a5,a5,a0
 43c:	0007c783          	lbu	a5,0(a5)
 440:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 444:	0005879b          	sext.w	a5,a1
 448:	02c5d5bb          	divuw	a1,a1,a2
 44c:	0685                	addi	a3,a3,1
 44e:	fec7f0e3          	bgeu	a5,a2,42e <printint+0x2a>
  if(neg)
 452:	00088b63          	beqz	a7,468 <printint+0x64>
    buf[i++] = '-';
 456:	fd040793          	addi	a5,s0,-48
 45a:	973e                	add	a4,a4,a5
 45c:	02d00793          	li	a5,45
 460:	fef70823          	sb	a5,-16(a4)
 464:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 468:	02e05863          	blez	a4,498 <printint+0x94>
 46c:	fc040793          	addi	a5,s0,-64
 470:	00e78933          	add	s2,a5,a4
 474:	fff78993          	addi	s3,a5,-1
 478:	99ba                	add	s3,s3,a4
 47a:	377d                	addiw	a4,a4,-1
 47c:	1702                	slli	a4,a4,0x20
 47e:	9301                	srli	a4,a4,0x20
 480:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 484:	fff94583          	lbu	a1,-1(s2)
 488:	8526                	mv	a0,s1
 48a:	00000097          	auipc	ra,0x0
 48e:	f58080e7          	jalr	-168(ra) # 3e2 <putc>
  while(--i >= 0)
 492:	197d                	addi	s2,s2,-1
 494:	ff3918e3          	bne	s2,s3,484 <printint+0x80>
}
 498:	70e2                	ld	ra,56(sp)
 49a:	7442                	ld	s0,48(sp)
 49c:	74a2                	ld	s1,40(sp)
 49e:	7902                	ld	s2,32(sp)
 4a0:	69e2                	ld	s3,24(sp)
 4a2:	6121                	addi	sp,sp,64
 4a4:	8082                	ret
    x = -xx;
 4a6:	40b005bb          	negw	a1,a1
    neg = 1;
 4aa:	4885                	li	a7,1
    x = -xx;
 4ac:	bf8d                	j	41e <printint+0x1a>

00000000000004ae <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ae:	7119                	addi	sp,sp,-128
 4b0:	fc86                	sd	ra,120(sp)
 4b2:	f8a2                	sd	s0,112(sp)
 4b4:	f4a6                	sd	s1,104(sp)
 4b6:	f0ca                	sd	s2,96(sp)
 4b8:	ecce                	sd	s3,88(sp)
 4ba:	e8d2                	sd	s4,80(sp)
 4bc:	e4d6                	sd	s5,72(sp)
 4be:	e0da                	sd	s6,64(sp)
 4c0:	fc5e                	sd	s7,56(sp)
 4c2:	f862                	sd	s8,48(sp)
 4c4:	f466                	sd	s9,40(sp)
 4c6:	f06a                	sd	s10,32(sp)
 4c8:	ec6e                	sd	s11,24(sp)
 4ca:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4cc:	0005c903          	lbu	s2,0(a1)
 4d0:	18090f63          	beqz	s2,66e <vprintf+0x1c0>
 4d4:	8aaa                	mv	s5,a0
 4d6:	8b32                	mv	s6,a2
 4d8:	00158493          	addi	s1,a1,1
  state = 0;
 4dc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4de:	02500a13          	li	s4,37
      if(c == 'd'){
 4e2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4e6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4ea:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4ee:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4f2:	00000b97          	auipc	s7,0x0
 4f6:	386b8b93          	addi	s7,s7,902 # 878 <digits>
 4fa:	a839                	j	518 <vprintf+0x6a>
        putc(fd, c);
 4fc:	85ca                	mv	a1,s2
 4fe:	8556                	mv	a0,s5
 500:	00000097          	auipc	ra,0x0
 504:	ee2080e7          	jalr	-286(ra) # 3e2 <putc>
 508:	a019                	j	50e <vprintf+0x60>
    } else if(state == '%'){
 50a:	01498f63          	beq	s3,s4,528 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 50e:	0485                	addi	s1,s1,1
 510:	fff4c903          	lbu	s2,-1(s1)
 514:	14090d63          	beqz	s2,66e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 518:	0009079b          	sext.w	a5,s2
    if(state == 0){
 51c:	fe0997e3          	bnez	s3,50a <vprintf+0x5c>
      if(c == '%'){
 520:	fd479ee3          	bne	a5,s4,4fc <vprintf+0x4e>
        state = '%';
 524:	89be                	mv	s3,a5
 526:	b7e5                	j	50e <vprintf+0x60>
      if(c == 'd'){
 528:	05878063          	beq	a5,s8,568 <vprintf+0xba>
      } else if(c == 'l') {
 52c:	05978c63          	beq	a5,s9,584 <vprintf+0xd6>
      } else if(c == 'x') {
 530:	07a78863          	beq	a5,s10,5a0 <vprintf+0xf2>
      } else if(c == 'p') {
 534:	09b78463          	beq	a5,s11,5bc <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 538:	07300713          	li	a4,115
 53c:	0ce78663          	beq	a5,a4,608 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 540:	06300713          	li	a4,99
 544:	0ee78e63          	beq	a5,a4,640 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 548:	11478863          	beq	a5,s4,658 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 54c:	85d2                	mv	a1,s4
 54e:	8556                	mv	a0,s5
 550:	00000097          	auipc	ra,0x0
 554:	e92080e7          	jalr	-366(ra) # 3e2 <putc>
        putc(fd, c);
 558:	85ca                	mv	a1,s2
 55a:	8556                	mv	a0,s5
 55c:	00000097          	auipc	ra,0x0
 560:	e86080e7          	jalr	-378(ra) # 3e2 <putc>
      }
      state = 0;
 564:	4981                	li	s3,0
 566:	b765                	j	50e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 568:	008b0913          	addi	s2,s6,8
 56c:	4685                	li	a3,1
 56e:	4629                	li	a2,10
 570:	000b2583          	lw	a1,0(s6)
 574:	8556                	mv	a0,s5
 576:	00000097          	auipc	ra,0x0
 57a:	e8e080e7          	jalr	-370(ra) # 404 <printint>
 57e:	8b4a                	mv	s6,s2
      state = 0;
 580:	4981                	li	s3,0
 582:	b771                	j	50e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 584:	008b0913          	addi	s2,s6,8
 588:	4681                	li	a3,0
 58a:	4629                	li	a2,10
 58c:	000b2583          	lw	a1,0(s6)
 590:	8556                	mv	a0,s5
 592:	00000097          	auipc	ra,0x0
 596:	e72080e7          	jalr	-398(ra) # 404 <printint>
 59a:	8b4a                	mv	s6,s2
      state = 0;
 59c:	4981                	li	s3,0
 59e:	bf85                	j	50e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5a0:	008b0913          	addi	s2,s6,8
 5a4:	4681                	li	a3,0
 5a6:	4641                	li	a2,16
 5a8:	000b2583          	lw	a1,0(s6)
 5ac:	8556                	mv	a0,s5
 5ae:	00000097          	auipc	ra,0x0
 5b2:	e56080e7          	jalr	-426(ra) # 404 <printint>
 5b6:	8b4a                	mv	s6,s2
      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	bf91                	j	50e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5bc:	008b0793          	addi	a5,s6,8
 5c0:	f8f43423          	sd	a5,-120(s0)
 5c4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5c8:	03000593          	li	a1,48
 5cc:	8556                	mv	a0,s5
 5ce:	00000097          	auipc	ra,0x0
 5d2:	e14080e7          	jalr	-492(ra) # 3e2 <putc>
  putc(fd, 'x');
 5d6:	85ea                	mv	a1,s10
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	e08080e7          	jalr	-504(ra) # 3e2 <putc>
 5e2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5e4:	03c9d793          	srli	a5,s3,0x3c
 5e8:	97de                	add	a5,a5,s7
 5ea:	0007c583          	lbu	a1,0(a5)
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	df2080e7          	jalr	-526(ra) # 3e2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5f8:	0992                	slli	s3,s3,0x4
 5fa:	397d                	addiw	s2,s2,-1
 5fc:	fe0914e3          	bnez	s2,5e4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 600:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 604:	4981                	li	s3,0
 606:	b721                	j	50e <vprintf+0x60>
        s = va_arg(ap, char*);
 608:	008b0993          	addi	s3,s6,8
 60c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 610:	02090163          	beqz	s2,632 <vprintf+0x184>
        while(*s != 0){
 614:	00094583          	lbu	a1,0(s2)
 618:	c9a1                	beqz	a1,668 <vprintf+0x1ba>
          putc(fd, *s);
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	dc6080e7          	jalr	-570(ra) # 3e2 <putc>
          s++;
 624:	0905                	addi	s2,s2,1
        while(*s != 0){
 626:	00094583          	lbu	a1,0(s2)
 62a:	f9e5                	bnez	a1,61a <vprintf+0x16c>
        s = va_arg(ap, char*);
 62c:	8b4e                	mv	s6,s3
      state = 0;
 62e:	4981                	li	s3,0
 630:	bdf9                	j	50e <vprintf+0x60>
          s = "(null)";
 632:	00000917          	auipc	s2,0x0
 636:	23e90913          	addi	s2,s2,574 # 870 <malloc+0xf8>
        while(*s != 0){
 63a:	02800593          	li	a1,40
 63e:	bff1                	j	61a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 640:	008b0913          	addi	s2,s6,8
 644:	000b4583          	lbu	a1,0(s6)
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	d98080e7          	jalr	-616(ra) # 3e2 <putc>
 652:	8b4a                	mv	s6,s2
      state = 0;
 654:	4981                	li	s3,0
 656:	bd65                	j	50e <vprintf+0x60>
        putc(fd, c);
 658:	85d2                	mv	a1,s4
 65a:	8556                	mv	a0,s5
 65c:	00000097          	auipc	ra,0x0
 660:	d86080e7          	jalr	-634(ra) # 3e2 <putc>
      state = 0;
 664:	4981                	li	s3,0
 666:	b565                	j	50e <vprintf+0x60>
        s = va_arg(ap, char*);
 668:	8b4e                	mv	s6,s3
      state = 0;
 66a:	4981                	li	s3,0
 66c:	b54d                	j	50e <vprintf+0x60>
    }
  }
}
 66e:	70e6                	ld	ra,120(sp)
 670:	7446                	ld	s0,112(sp)
 672:	74a6                	ld	s1,104(sp)
 674:	7906                	ld	s2,96(sp)
 676:	69e6                	ld	s3,88(sp)
 678:	6a46                	ld	s4,80(sp)
 67a:	6aa6                	ld	s5,72(sp)
 67c:	6b06                	ld	s6,64(sp)
 67e:	7be2                	ld	s7,56(sp)
 680:	7c42                	ld	s8,48(sp)
 682:	7ca2                	ld	s9,40(sp)
 684:	7d02                	ld	s10,32(sp)
 686:	6de2                	ld	s11,24(sp)
 688:	6109                	addi	sp,sp,128
 68a:	8082                	ret

000000000000068c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 68c:	715d                	addi	sp,sp,-80
 68e:	ec06                	sd	ra,24(sp)
 690:	e822                	sd	s0,16(sp)
 692:	1000                	addi	s0,sp,32
 694:	e010                	sd	a2,0(s0)
 696:	e414                	sd	a3,8(s0)
 698:	e818                	sd	a4,16(s0)
 69a:	ec1c                	sd	a5,24(s0)
 69c:	03043023          	sd	a6,32(s0)
 6a0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6a4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6a8:	8622                	mv	a2,s0
 6aa:	00000097          	auipc	ra,0x0
 6ae:	e04080e7          	jalr	-508(ra) # 4ae <vprintf>
}
 6b2:	60e2                	ld	ra,24(sp)
 6b4:	6442                	ld	s0,16(sp)
 6b6:	6161                	addi	sp,sp,80
 6b8:	8082                	ret

00000000000006ba <printf>:

void
printf(const char *fmt, ...)
{
 6ba:	711d                	addi	sp,sp,-96
 6bc:	ec06                	sd	ra,24(sp)
 6be:	e822                	sd	s0,16(sp)
 6c0:	1000                	addi	s0,sp,32
 6c2:	e40c                	sd	a1,8(s0)
 6c4:	e810                	sd	a2,16(s0)
 6c6:	ec14                	sd	a3,24(s0)
 6c8:	f018                	sd	a4,32(s0)
 6ca:	f41c                	sd	a5,40(s0)
 6cc:	03043823          	sd	a6,48(s0)
 6d0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6d4:	00840613          	addi	a2,s0,8
 6d8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6dc:	85aa                	mv	a1,a0
 6de:	4505                	li	a0,1
 6e0:	00000097          	auipc	ra,0x0
 6e4:	dce080e7          	jalr	-562(ra) # 4ae <vprintf>
}
 6e8:	60e2                	ld	ra,24(sp)
 6ea:	6442                	ld	s0,16(sp)
 6ec:	6125                	addi	sp,sp,96
 6ee:	8082                	ret

00000000000006f0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6f0:	1141                	addi	sp,sp,-16
 6f2:	e422                	sd	s0,8(sp)
 6f4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6f6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fa:	00000797          	auipc	a5,0x0
 6fe:	1967b783          	ld	a5,406(a5) # 890 <freep>
 702:	a805                	j	732 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 704:	4618                	lw	a4,8(a2)
 706:	9db9                	addw	a1,a1,a4
 708:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 70c:	6398                	ld	a4,0(a5)
 70e:	6318                	ld	a4,0(a4)
 710:	fee53823          	sd	a4,-16(a0)
 714:	a091                	j	758 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 716:	ff852703          	lw	a4,-8(a0)
 71a:	9e39                	addw	a2,a2,a4
 71c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 71e:	ff053703          	ld	a4,-16(a0)
 722:	e398                	sd	a4,0(a5)
 724:	a099                	j	76a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 726:	6398                	ld	a4,0(a5)
 728:	00e7e463          	bltu	a5,a4,730 <free+0x40>
 72c:	00e6ea63          	bltu	a3,a4,740 <free+0x50>
{
 730:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 732:	fed7fae3          	bgeu	a5,a3,726 <free+0x36>
 736:	6398                	ld	a4,0(a5)
 738:	00e6e463          	bltu	a3,a4,740 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 73c:	fee7eae3          	bltu	a5,a4,730 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 740:	ff852583          	lw	a1,-8(a0)
 744:	6390                	ld	a2,0(a5)
 746:	02059713          	slli	a4,a1,0x20
 74a:	9301                	srli	a4,a4,0x20
 74c:	0712                	slli	a4,a4,0x4
 74e:	9736                	add	a4,a4,a3
 750:	fae60ae3          	beq	a2,a4,704 <free+0x14>
    bp->s.ptr = p->s.ptr;
 754:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 758:	4790                	lw	a2,8(a5)
 75a:	02061713          	slli	a4,a2,0x20
 75e:	9301                	srli	a4,a4,0x20
 760:	0712                	slli	a4,a4,0x4
 762:	973e                	add	a4,a4,a5
 764:	fae689e3          	beq	a3,a4,716 <free+0x26>
  } else
    p->s.ptr = bp;
 768:	e394                	sd	a3,0(a5)
  freep = p;
 76a:	00000717          	auipc	a4,0x0
 76e:	12f73323          	sd	a5,294(a4) # 890 <freep>
}
 772:	6422                	ld	s0,8(sp)
 774:	0141                	addi	sp,sp,16
 776:	8082                	ret

0000000000000778 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 778:	7139                	addi	sp,sp,-64
 77a:	fc06                	sd	ra,56(sp)
 77c:	f822                	sd	s0,48(sp)
 77e:	f426                	sd	s1,40(sp)
 780:	f04a                	sd	s2,32(sp)
 782:	ec4e                	sd	s3,24(sp)
 784:	e852                	sd	s4,16(sp)
 786:	e456                	sd	s5,8(sp)
 788:	e05a                	sd	s6,0(sp)
 78a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 78c:	02051493          	slli	s1,a0,0x20
 790:	9081                	srli	s1,s1,0x20
 792:	04bd                	addi	s1,s1,15
 794:	8091                	srli	s1,s1,0x4
 796:	0014899b          	addiw	s3,s1,1
 79a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 79c:	00000517          	auipc	a0,0x0
 7a0:	0f453503          	ld	a0,244(a0) # 890 <freep>
 7a4:	c515                	beqz	a0,7d0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7a8:	4798                	lw	a4,8(a5)
 7aa:	02977f63          	bgeu	a4,s1,7e8 <malloc+0x70>
 7ae:	8a4e                	mv	s4,s3
 7b0:	0009871b          	sext.w	a4,s3
 7b4:	6685                	lui	a3,0x1
 7b6:	00d77363          	bgeu	a4,a3,7bc <malloc+0x44>
 7ba:	6a05                	lui	s4,0x1
 7bc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7c0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7c4:	00000917          	auipc	s2,0x0
 7c8:	0cc90913          	addi	s2,s2,204 # 890 <freep>
  if(p == (char*)-1)
 7cc:	5afd                	li	s5,-1
 7ce:	a88d                	j	840 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7d0:	00000797          	auipc	a5,0x0
 7d4:	0c878793          	addi	a5,a5,200 # 898 <base>
 7d8:	00000717          	auipc	a4,0x0
 7dc:	0af73c23          	sd	a5,184(a4) # 890 <freep>
 7e0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7e2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7e6:	b7e1                	j	7ae <malloc+0x36>
      if(p->s.size == nunits)
 7e8:	02e48b63          	beq	s1,a4,81e <malloc+0xa6>
        p->s.size -= nunits;
 7ec:	4137073b          	subw	a4,a4,s3
 7f0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7f2:	1702                	slli	a4,a4,0x20
 7f4:	9301                	srli	a4,a4,0x20
 7f6:	0712                	slli	a4,a4,0x4
 7f8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7fa:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7fe:	00000717          	auipc	a4,0x0
 802:	08a73923          	sd	a0,146(a4) # 890 <freep>
      return (void*)(p + 1);
 806:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 80a:	70e2                	ld	ra,56(sp)
 80c:	7442                	ld	s0,48(sp)
 80e:	74a2                	ld	s1,40(sp)
 810:	7902                	ld	s2,32(sp)
 812:	69e2                	ld	s3,24(sp)
 814:	6a42                	ld	s4,16(sp)
 816:	6aa2                	ld	s5,8(sp)
 818:	6b02                	ld	s6,0(sp)
 81a:	6121                	addi	sp,sp,64
 81c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 81e:	6398                	ld	a4,0(a5)
 820:	e118                	sd	a4,0(a0)
 822:	bff1                	j	7fe <malloc+0x86>
  hp->s.size = nu;
 824:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 828:	0541                	addi	a0,a0,16
 82a:	00000097          	auipc	ra,0x0
 82e:	ec6080e7          	jalr	-314(ra) # 6f0 <free>
  return freep;
 832:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 836:	d971                	beqz	a0,80a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 838:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 83a:	4798                	lw	a4,8(a5)
 83c:	fa9776e3          	bgeu	a4,s1,7e8 <malloc+0x70>
    if(p == freep)
 840:	00093703          	ld	a4,0(s2)
 844:	853e                	mv	a0,a5
 846:	fef719e3          	bne	a4,a5,838 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 84a:	8552                	mv	a0,s4
 84c:	00000097          	auipc	ra,0x0
 850:	b36080e7          	jalr	-1226(ra) # 382 <sbrk>
  if(p == (char*)-1)
 854:	fd5518e3          	bne	a0,s5,824 <malloc+0xac>
        return 0;
 858:	4501                	li	a0,0
 85a:	bf45                	j	80a <malloc+0x92>
