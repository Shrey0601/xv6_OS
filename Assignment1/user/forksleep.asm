
user/_forksleep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  if(argc != 3)
   c:	478d                	li	a5,3
   e:	00f50763          	beq	a0,a5,1c <main+0x1c>
  {
  	exit(0);
  12:	4501                	li	a0,0
  14:	00000097          	auipc	ra,0x0
  18:	324080e7          	jalr	804(ra) # 338 <exit>
  1c:	84ae                	mv	s1,a1
  }
  else
  {
  	int m=atoi(argv[1]);
  1e:	6588                	ld	a0,8(a1)
  20:	00000097          	auipc	ra,0x0
  24:	218080e7          	jalr	536(ra) # 238 <atoi>
  28:	892a                	mv	s2,a0
  	int n=atoi(argv[2]);
  2a:	6888                	ld	a0,16(s1)
  2c:	00000097          	auipc	ra,0x0
  30:	20c080e7          	jalr	524(ra) # 238 <atoi>
  34:	84aa                	mv	s1,a0
  	
  	if(m<=0 || n<0 || n>1)
  36:	01205763          	blez	s2,44 <main+0x44>
  3a:	0005079b          	sext.w	a5,a0
  3e:	4705                	li	a4,1
  40:	00f77763          	bgeu	a4,a5,4e <main+0x4e>
		exit(0);
  44:	4501                	li	a0,0
  46:	00000097          	auipc	ra,0x0
  4a:	2f2080e7          	jalr	754(ra) # 338 <exit>
  	
  	/* fork a child process */
   	   	
  	if(fork()==0)
  4e:	00000097          	auipc	ra,0x0
  52:	2e2080e7          	jalr	738(ra) # 330 <fork>
  56:	e915                	bnez	a0,8a <main+0x8a>
  	{
  		if(n==0)
  58:	c09d                	beqz	s1,7e <main+0x7e>
  		{
  			sleep(m);
  		}
  		printf("%d: Child\n",getpid());
  5a:	00000097          	auipc	ra,0x0
  5e:	35e080e7          	jalr	862(ra) # 3b8 <getpid>
  62:	85aa                	mv	a1,a0
  64:	00001517          	auipc	a0,0x1
  68:	82c50513          	addi	a0,a0,-2004 # 890 <malloc+0xea>
  6c:	00000097          	auipc	ra,0x0
  70:	67c080e7          	jalr	1660(ra) # 6e8 <printf>
  		}
  		printf("%d: Parent\n",getpid());
		wait(0);
  	}
  }
  exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	2c2080e7          	jalr	706(ra) # 338 <exit>
  			sleep(m);
  7e:	854a                	mv	a0,s2
  80:	00000097          	auipc	ra,0x0
  84:	348080e7          	jalr	840(ra) # 3c8 <sleep>
  88:	bfc9                	j	5a <main+0x5a>
  		if(n==1)
  8a:	4785                	li	a5,1
  8c:	02f48563          	beq	s1,a5,b6 <main+0xb6>
  		printf("%d: Parent\n",getpid());
  90:	00000097          	auipc	ra,0x0
  94:	328080e7          	jalr	808(ra) # 3b8 <getpid>
  98:	85aa                	mv	a1,a0
  9a:	00001517          	auipc	a0,0x1
  9e:	80650513          	addi	a0,a0,-2042 # 8a0 <malloc+0xfa>
  a2:	00000097          	auipc	ra,0x0
  a6:	646080e7          	jalr	1606(ra) # 6e8 <printf>
		wait(0);
  aa:	4501                	li	a0,0
  ac:	00000097          	auipc	ra,0x0
  b0:	294080e7          	jalr	660(ra) # 340 <wait>
  b4:	b7c1                	j	74 <main+0x74>
  			sleep(m);
  b6:	854a                	mv	a0,s2
  b8:	00000097          	auipc	ra,0x0
  bc:	310080e7          	jalr	784(ra) # 3c8 <sleep>
  c0:	bfc1                	j	90 <main+0x90>

00000000000000c2 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c8:	87aa                	mv	a5,a0
  ca:	0585                	addi	a1,a1,1
  cc:	0785                	addi	a5,a5,1
  ce:	fff5c703          	lbu	a4,-1(a1)
  d2:	fee78fa3          	sb	a4,-1(a5)
  d6:	fb75                	bnez	a4,ca <strcpy+0x8>
    ;
  return os;
}
  d8:	6422                	ld	s0,8(sp)
  da:	0141                	addi	sp,sp,16
  dc:	8082                	ret

00000000000000de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  de:	1141                	addi	sp,sp,-16
  e0:	e422                	sd	s0,8(sp)
  e2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  e4:	00054783          	lbu	a5,0(a0)
  e8:	cb91                	beqz	a5,fc <strcmp+0x1e>
  ea:	0005c703          	lbu	a4,0(a1)
  ee:	00f71763          	bne	a4,a5,fc <strcmp+0x1e>
    p++, q++;
  f2:	0505                	addi	a0,a0,1
  f4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	fbe5                	bnez	a5,ea <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  fc:	0005c503          	lbu	a0,0(a1)
}
 100:	40a7853b          	subw	a0,a5,a0
 104:	6422                	ld	s0,8(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret

000000000000010a <strlen>:

uint
strlen(const char *s)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 110:	00054783          	lbu	a5,0(a0)
 114:	cf91                	beqz	a5,130 <strlen+0x26>
 116:	0505                	addi	a0,a0,1
 118:	87aa                	mv	a5,a0
 11a:	4685                	li	a3,1
 11c:	9e89                	subw	a3,a3,a0
 11e:	00f6853b          	addw	a0,a3,a5
 122:	0785                	addi	a5,a5,1
 124:	fff7c703          	lbu	a4,-1(a5)
 128:	fb7d                	bnez	a4,11e <strlen+0x14>
    ;
  return n;
}
 12a:	6422                	ld	s0,8(sp)
 12c:	0141                	addi	sp,sp,16
 12e:	8082                	ret
  for(n = 0; s[n]; n++)
 130:	4501                	li	a0,0
 132:	bfe5                	j	12a <strlen+0x20>

0000000000000134 <memset>:

void*
memset(void *dst, int c, uint n)
{
 134:	1141                	addi	sp,sp,-16
 136:	e422                	sd	s0,8(sp)
 138:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 13a:	ce09                	beqz	a2,154 <memset+0x20>
 13c:	87aa                	mv	a5,a0
 13e:	fff6071b          	addiw	a4,a2,-1
 142:	1702                	slli	a4,a4,0x20
 144:	9301                	srli	a4,a4,0x20
 146:	0705                	addi	a4,a4,1
 148:	972a                	add	a4,a4,a0
    cdst[i] = c;
 14a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 14e:	0785                	addi	a5,a5,1
 150:	fee79de3          	bne	a5,a4,14a <memset+0x16>
  }
  return dst;
}
 154:	6422                	ld	s0,8(sp)
 156:	0141                	addi	sp,sp,16
 158:	8082                	ret

000000000000015a <strchr>:

char*
strchr(const char *s, char c)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 160:	00054783          	lbu	a5,0(a0)
 164:	cb99                	beqz	a5,17a <strchr+0x20>
    if(*s == c)
 166:	00f58763          	beq	a1,a5,174 <strchr+0x1a>
  for(; *s; s++)
 16a:	0505                	addi	a0,a0,1
 16c:	00054783          	lbu	a5,0(a0)
 170:	fbfd                	bnez	a5,166 <strchr+0xc>
      return (char*)s;
  return 0;
 172:	4501                	li	a0,0
}
 174:	6422                	ld	s0,8(sp)
 176:	0141                	addi	sp,sp,16
 178:	8082                	ret
  return 0;
 17a:	4501                	li	a0,0
 17c:	bfe5                	j	174 <strchr+0x1a>

000000000000017e <gets>:

char*
gets(char *buf, int max)
{
 17e:	711d                	addi	sp,sp,-96
 180:	ec86                	sd	ra,88(sp)
 182:	e8a2                	sd	s0,80(sp)
 184:	e4a6                	sd	s1,72(sp)
 186:	e0ca                	sd	s2,64(sp)
 188:	fc4e                	sd	s3,56(sp)
 18a:	f852                	sd	s4,48(sp)
 18c:	f456                	sd	s5,40(sp)
 18e:	f05a                	sd	s6,32(sp)
 190:	ec5e                	sd	s7,24(sp)
 192:	1080                	addi	s0,sp,96
 194:	8baa                	mv	s7,a0
 196:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 198:	892a                	mv	s2,a0
 19a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 19c:	4aa9                	li	s5,10
 19e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1a0:	89a6                	mv	s3,s1
 1a2:	2485                	addiw	s1,s1,1
 1a4:	0344d863          	bge	s1,s4,1d4 <gets+0x56>
    cc = read(0, &c, 1);
 1a8:	4605                	li	a2,1
 1aa:	faf40593          	addi	a1,s0,-81
 1ae:	4501                	li	a0,0
 1b0:	00000097          	auipc	ra,0x0
 1b4:	1a0080e7          	jalr	416(ra) # 350 <read>
    if(cc < 1)
 1b8:	00a05e63          	blez	a0,1d4 <gets+0x56>
    buf[i++] = c;
 1bc:	faf44783          	lbu	a5,-81(s0)
 1c0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c4:	01578763          	beq	a5,s5,1d2 <gets+0x54>
 1c8:	0905                	addi	s2,s2,1
 1ca:	fd679be3          	bne	a5,s6,1a0 <gets+0x22>
  for(i=0; i+1 < max; ){
 1ce:	89a6                	mv	s3,s1
 1d0:	a011                	j	1d4 <gets+0x56>
 1d2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1d4:	99de                	add	s3,s3,s7
 1d6:	00098023          	sb	zero,0(s3)
  return buf;
}
 1da:	855e                	mv	a0,s7
 1dc:	60e6                	ld	ra,88(sp)
 1de:	6446                	ld	s0,80(sp)
 1e0:	64a6                	ld	s1,72(sp)
 1e2:	6906                	ld	s2,64(sp)
 1e4:	79e2                	ld	s3,56(sp)
 1e6:	7a42                	ld	s4,48(sp)
 1e8:	7aa2                	ld	s5,40(sp)
 1ea:	7b02                	ld	s6,32(sp)
 1ec:	6be2                	ld	s7,24(sp)
 1ee:	6125                	addi	sp,sp,96
 1f0:	8082                	ret

00000000000001f2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f2:	1101                	addi	sp,sp,-32
 1f4:	ec06                	sd	ra,24(sp)
 1f6:	e822                	sd	s0,16(sp)
 1f8:	e426                	sd	s1,8(sp)
 1fa:	e04a                	sd	s2,0(sp)
 1fc:	1000                	addi	s0,sp,32
 1fe:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 200:	4581                	li	a1,0
 202:	00000097          	auipc	ra,0x0
 206:	176080e7          	jalr	374(ra) # 378 <open>
  if(fd < 0)
 20a:	02054563          	bltz	a0,234 <stat+0x42>
 20e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 210:	85ca                	mv	a1,s2
 212:	00000097          	auipc	ra,0x0
 216:	17e080e7          	jalr	382(ra) # 390 <fstat>
 21a:	892a                	mv	s2,a0
  close(fd);
 21c:	8526                	mv	a0,s1
 21e:	00000097          	auipc	ra,0x0
 222:	142080e7          	jalr	322(ra) # 360 <close>
  return r;
}
 226:	854a                	mv	a0,s2
 228:	60e2                	ld	ra,24(sp)
 22a:	6442                	ld	s0,16(sp)
 22c:	64a2                	ld	s1,8(sp)
 22e:	6902                	ld	s2,0(sp)
 230:	6105                	addi	sp,sp,32
 232:	8082                	ret
    return -1;
 234:	597d                	li	s2,-1
 236:	bfc5                	j	226 <stat+0x34>

0000000000000238 <atoi>:

int
atoi(const char *s)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23e:	00054603          	lbu	a2,0(a0)
 242:	fd06079b          	addiw	a5,a2,-48
 246:	0ff7f793          	andi	a5,a5,255
 24a:	4725                	li	a4,9
 24c:	02f76963          	bltu	a4,a5,27e <atoi+0x46>
 250:	86aa                	mv	a3,a0
  n = 0;
 252:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 254:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 256:	0685                	addi	a3,a3,1
 258:	0025179b          	slliw	a5,a0,0x2
 25c:	9fa9                	addw	a5,a5,a0
 25e:	0017979b          	slliw	a5,a5,0x1
 262:	9fb1                	addw	a5,a5,a2
 264:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 268:	0006c603          	lbu	a2,0(a3)
 26c:	fd06071b          	addiw	a4,a2,-48
 270:	0ff77713          	andi	a4,a4,255
 274:	fee5f1e3          	bgeu	a1,a4,256 <atoi+0x1e>
  return n;
}
 278:	6422                	ld	s0,8(sp)
 27a:	0141                	addi	sp,sp,16
 27c:	8082                	ret
  n = 0;
 27e:	4501                	li	a0,0
 280:	bfe5                	j	278 <atoi+0x40>

0000000000000282 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 282:	1141                	addi	sp,sp,-16
 284:	e422                	sd	s0,8(sp)
 286:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 288:	02b57663          	bgeu	a0,a1,2b4 <memmove+0x32>
    while(n-- > 0)
 28c:	02c05163          	blez	a2,2ae <memmove+0x2c>
 290:	fff6079b          	addiw	a5,a2,-1
 294:	1782                	slli	a5,a5,0x20
 296:	9381                	srli	a5,a5,0x20
 298:	0785                	addi	a5,a5,1
 29a:	97aa                	add	a5,a5,a0
  dst = vdst;
 29c:	872a                	mv	a4,a0
      *dst++ = *src++;
 29e:	0585                	addi	a1,a1,1
 2a0:	0705                	addi	a4,a4,1
 2a2:	fff5c683          	lbu	a3,-1(a1)
 2a6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2aa:	fee79ae3          	bne	a5,a4,29e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ae:	6422                	ld	s0,8(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret
    dst += n;
 2b4:	00c50733          	add	a4,a0,a2
    src += n;
 2b8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ba:	fec05ae3          	blez	a2,2ae <memmove+0x2c>
 2be:	fff6079b          	addiw	a5,a2,-1
 2c2:	1782                	slli	a5,a5,0x20
 2c4:	9381                	srli	a5,a5,0x20
 2c6:	fff7c793          	not	a5,a5
 2ca:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2cc:	15fd                	addi	a1,a1,-1
 2ce:	177d                	addi	a4,a4,-1
 2d0:	0005c683          	lbu	a3,0(a1)
 2d4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d8:	fee79ae3          	bne	a5,a4,2cc <memmove+0x4a>
 2dc:	bfc9                	j	2ae <memmove+0x2c>

00000000000002de <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e422                	sd	s0,8(sp)
 2e2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2e4:	ca05                	beqz	a2,314 <memcmp+0x36>
 2e6:	fff6069b          	addiw	a3,a2,-1
 2ea:	1682                	slli	a3,a3,0x20
 2ec:	9281                	srli	a3,a3,0x20
 2ee:	0685                	addi	a3,a3,1
 2f0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2f2:	00054783          	lbu	a5,0(a0)
 2f6:	0005c703          	lbu	a4,0(a1)
 2fa:	00e79863          	bne	a5,a4,30a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2fe:	0505                	addi	a0,a0,1
    p2++;
 300:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 302:	fed518e3          	bne	a0,a3,2f2 <memcmp+0x14>
  }
  return 0;
 306:	4501                	li	a0,0
 308:	a019                	j	30e <memcmp+0x30>
      return *p1 - *p2;
 30a:	40e7853b          	subw	a0,a5,a4
}
 30e:	6422                	ld	s0,8(sp)
 310:	0141                	addi	sp,sp,16
 312:	8082                	ret
  return 0;
 314:	4501                	li	a0,0
 316:	bfe5                	j	30e <memcmp+0x30>

0000000000000318 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 318:	1141                	addi	sp,sp,-16
 31a:	e406                	sd	ra,8(sp)
 31c:	e022                	sd	s0,0(sp)
 31e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 320:	00000097          	auipc	ra,0x0
 324:	f62080e7          	jalr	-158(ra) # 282 <memmove>
}
 328:	60a2                	ld	ra,8(sp)
 32a:	6402                	ld	s0,0(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret

0000000000000330 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 330:	4885                	li	a7,1
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <exit>:
.global exit
exit:
 li a7, SYS_exit
 338:	4889                	li	a7,2
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <wait>:
.global wait
wait:
 li a7, SYS_wait
 340:	488d                	li	a7,3
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 348:	4891                	li	a7,4
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <read>:
.global read
read:
 li a7, SYS_read
 350:	4895                	li	a7,5
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <write>:
.global write
write:
 li a7, SYS_write
 358:	48c1                	li	a7,16
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <close>:
.global close
close:
 li a7, SYS_close
 360:	48d5                	li	a7,21
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <kill>:
.global kill
kill:
 li a7, SYS_kill
 368:	4899                	li	a7,6
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <exec>:
.global exec
exec:
 li a7, SYS_exec
 370:	489d                	li	a7,7
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <open>:
.global open
open:
 li a7, SYS_open
 378:	48bd                	li	a7,15
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 380:	48c5                	li	a7,17
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 388:	48c9                	li	a7,18
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 390:	48a1                	li	a7,8
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <link>:
.global link
link:
 li a7, SYS_link
 398:	48cd                	li	a7,19
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a0:	48d1                	li	a7,20
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3a8:	48a5                	li	a7,9
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b0:	48a9                	li	a7,10
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3b8:	48ad                	li	a7,11
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3c0:	48b1                	li	a7,12
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3c8:	48b5                	li	a7,13
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d0:	48b9                	li	a7,14
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 3d8:	48d9                	li	a7,22
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <yield>:
.global yield
yield:
 li a7, SYS_yield
 3e0:	48dd                	li	a7,23
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 3e8:	48e1                	li	a7,24
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 3f0:	48e9                	li	a7,26
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 3f8:	48e5                	li	a7,25
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <ps>:
.global ps
ps:
 li a7, SYS_ps
 400:	48ed                	li	a7,27
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 408:	48f1                	li	a7,28
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 410:	1101                	addi	sp,sp,-32
 412:	ec06                	sd	ra,24(sp)
 414:	e822                	sd	s0,16(sp)
 416:	1000                	addi	s0,sp,32
 418:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 41c:	4605                	li	a2,1
 41e:	fef40593          	addi	a1,s0,-17
 422:	00000097          	auipc	ra,0x0
 426:	f36080e7          	jalr	-202(ra) # 358 <write>
}
 42a:	60e2                	ld	ra,24(sp)
 42c:	6442                	ld	s0,16(sp)
 42e:	6105                	addi	sp,sp,32
 430:	8082                	ret

0000000000000432 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 432:	7139                	addi	sp,sp,-64
 434:	fc06                	sd	ra,56(sp)
 436:	f822                	sd	s0,48(sp)
 438:	f426                	sd	s1,40(sp)
 43a:	f04a                	sd	s2,32(sp)
 43c:	ec4e                	sd	s3,24(sp)
 43e:	0080                	addi	s0,sp,64
 440:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 442:	c299                	beqz	a3,448 <printint+0x16>
 444:	0805c863          	bltz	a1,4d4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 448:	2581                	sext.w	a1,a1
  neg = 0;
 44a:	4881                	li	a7,0
 44c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 450:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 452:	2601                	sext.w	a2,a2
 454:	00000517          	auipc	a0,0x0
 458:	46450513          	addi	a0,a0,1124 # 8b8 <digits>
 45c:	883a                	mv	a6,a4
 45e:	2705                	addiw	a4,a4,1
 460:	02c5f7bb          	remuw	a5,a1,a2
 464:	1782                	slli	a5,a5,0x20
 466:	9381                	srli	a5,a5,0x20
 468:	97aa                	add	a5,a5,a0
 46a:	0007c783          	lbu	a5,0(a5)
 46e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 472:	0005879b          	sext.w	a5,a1
 476:	02c5d5bb          	divuw	a1,a1,a2
 47a:	0685                	addi	a3,a3,1
 47c:	fec7f0e3          	bgeu	a5,a2,45c <printint+0x2a>
  if(neg)
 480:	00088b63          	beqz	a7,496 <printint+0x64>
    buf[i++] = '-';
 484:	fd040793          	addi	a5,s0,-48
 488:	973e                	add	a4,a4,a5
 48a:	02d00793          	li	a5,45
 48e:	fef70823          	sb	a5,-16(a4)
 492:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 496:	02e05863          	blez	a4,4c6 <printint+0x94>
 49a:	fc040793          	addi	a5,s0,-64
 49e:	00e78933          	add	s2,a5,a4
 4a2:	fff78993          	addi	s3,a5,-1
 4a6:	99ba                	add	s3,s3,a4
 4a8:	377d                	addiw	a4,a4,-1
 4aa:	1702                	slli	a4,a4,0x20
 4ac:	9301                	srli	a4,a4,0x20
 4ae:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4b2:	fff94583          	lbu	a1,-1(s2)
 4b6:	8526                	mv	a0,s1
 4b8:	00000097          	auipc	ra,0x0
 4bc:	f58080e7          	jalr	-168(ra) # 410 <putc>
  while(--i >= 0)
 4c0:	197d                	addi	s2,s2,-1
 4c2:	ff3918e3          	bne	s2,s3,4b2 <printint+0x80>
}
 4c6:	70e2                	ld	ra,56(sp)
 4c8:	7442                	ld	s0,48(sp)
 4ca:	74a2                	ld	s1,40(sp)
 4cc:	7902                	ld	s2,32(sp)
 4ce:	69e2                	ld	s3,24(sp)
 4d0:	6121                	addi	sp,sp,64
 4d2:	8082                	ret
    x = -xx;
 4d4:	40b005bb          	negw	a1,a1
    neg = 1;
 4d8:	4885                	li	a7,1
    x = -xx;
 4da:	bf8d                	j	44c <printint+0x1a>

00000000000004dc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4dc:	7119                	addi	sp,sp,-128
 4de:	fc86                	sd	ra,120(sp)
 4e0:	f8a2                	sd	s0,112(sp)
 4e2:	f4a6                	sd	s1,104(sp)
 4e4:	f0ca                	sd	s2,96(sp)
 4e6:	ecce                	sd	s3,88(sp)
 4e8:	e8d2                	sd	s4,80(sp)
 4ea:	e4d6                	sd	s5,72(sp)
 4ec:	e0da                	sd	s6,64(sp)
 4ee:	fc5e                	sd	s7,56(sp)
 4f0:	f862                	sd	s8,48(sp)
 4f2:	f466                	sd	s9,40(sp)
 4f4:	f06a                	sd	s10,32(sp)
 4f6:	ec6e                	sd	s11,24(sp)
 4f8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4fa:	0005c903          	lbu	s2,0(a1)
 4fe:	18090f63          	beqz	s2,69c <vprintf+0x1c0>
 502:	8aaa                	mv	s5,a0
 504:	8b32                	mv	s6,a2
 506:	00158493          	addi	s1,a1,1
  state = 0;
 50a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 50c:	02500a13          	li	s4,37
      if(c == 'd'){
 510:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 514:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 518:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 51c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 520:	00000b97          	auipc	s7,0x0
 524:	398b8b93          	addi	s7,s7,920 # 8b8 <digits>
 528:	a839                	j	546 <vprintf+0x6a>
        putc(fd, c);
 52a:	85ca                	mv	a1,s2
 52c:	8556                	mv	a0,s5
 52e:	00000097          	auipc	ra,0x0
 532:	ee2080e7          	jalr	-286(ra) # 410 <putc>
 536:	a019                	j	53c <vprintf+0x60>
    } else if(state == '%'){
 538:	01498f63          	beq	s3,s4,556 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 53c:	0485                	addi	s1,s1,1
 53e:	fff4c903          	lbu	s2,-1(s1)
 542:	14090d63          	beqz	s2,69c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 546:	0009079b          	sext.w	a5,s2
    if(state == 0){
 54a:	fe0997e3          	bnez	s3,538 <vprintf+0x5c>
      if(c == '%'){
 54e:	fd479ee3          	bne	a5,s4,52a <vprintf+0x4e>
        state = '%';
 552:	89be                	mv	s3,a5
 554:	b7e5                	j	53c <vprintf+0x60>
      if(c == 'd'){
 556:	05878063          	beq	a5,s8,596 <vprintf+0xba>
      } else if(c == 'l') {
 55a:	05978c63          	beq	a5,s9,5b2 <vprintf+0xd6>
      } else if(c == 'x') {
 55e:	07a78863          	beq	a5,s10,5ce <vprintf+0xf2>
      } else if(c == 'p') {
 562:	09b78463          	beq	a5,s11,5ea <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 566:	07300713          	li	a4,115
 56a:	0ce78663          	beq	a5,a4,636 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 56e:	06300713          	li	a4,99
 572:	0ee78e63          	beq	a5,a4,66e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 576:	11478863          	beq	a5,s4,686 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 57a:	85d2                	mv	a1,s4
 57c:	8556                	mv	a0,s5
 57e:	00000097          	auipc	ra,0x0
 582:	e92080e7          	jalr	-366(ra) # 410 <putc>
        putc(fd, c);
 586:	85ca                	mv	a1,s2
 588:	8556                	mv	a0,s5
 58a:	00000097          	auipc	ra,0x0
 58e:	e86080e7          	jalr	-378(ra) # 410 <putc>
      }
      state = 0;
 592:	4981                	li	s3,0
 594:	b765                	j	53c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 596:	008b0913          	addi	s2,s6,8
 59a:	4685                	li	a3,1
 59c:	4629                	li	a2,10
 59e:	000b2583          	lw	a1,0(s6)
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	e8e080e7          	jalr	-370(ra) # 432 <printint>
 5ac:	8b4a                	mv	s6,s2
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	b771                	j	53c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b2:	008b0913          	addi	s2,s6,8
 5b6:	4681                	li	a3,0
 5b8:	4629                	li	a2,10
 5ba:	000b2583          	lw	a1,0(s6)
 5be:	8556                	mv	a0,s5
 5c0:	00000097          	auipc	ra,0x0
 5c4:	e72080e7          	jalr	-398(ra) # 432 <printint>
 5c8:	8b4a                	mv	s6,s2
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	bf85                	j	53c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5ce:	008b0913          	addi	s2,s6,8
 5d2:	4681                	li	a3,0
 5d4:	4641                	li	a2,16
 5d6:	000b2583          	lw	a1,0(s6)
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	e56080e7          	jalr	-426(ra) # 432 <printint>
 5e4:	8b4a                	mv	s6,s2
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	bf91                	j	53c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5ea:	008b0793          	addi	a5,s6,8
 5ee:	f8f43423          	sd	a5,-120(s0)
 5f2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5f6:	03000593          	li	a1,48
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	e14080e7          	jalr	-492(ra) # 410 <putc>
  putc(fd, 'x');
 604:	85ea                	mv	a1,s10
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	e08080e7          	jalr	-504(ra) # 410 <putc>
 610:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 612:	03c9d793          	srli	a5,s3,0x3c
 616:	97de                	add	a5,a5,s7
 618:	0007c583          	lbu	a1,0(a5)
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	df2080e7          	jalr	-526(ra) # 410 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 626:	0992                	slli	s3,s3,0x4
 628:	397d                	addiw	s2,s2,-1
 62a:	fe0914e3          	bnez	s2,612 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 62e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 632:	4981                	li	s3,0
 634:	b721                	j	53c <vprintf+0x60>
        s = va_arg(ap, char*);
 636:	008b0993          	addi	s3,s6,8
 63a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 63e:	02090163          	beqz	s2,660 <vprintf+0x184>
        while(*s != 0){
 642:	00094583          	lbu	a1,0(s2)
 646:	c9a1                	beqz	a1,696 <vprintf+0x1ba>
          putc(fd, *s);
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	dc6080e7          	jalr	-570(ra) # 410 <putc>
          s++;
 652:	0905                	addi	s2,s2,1
        while(*s != 0){
 654:	00094583          	lbu	a1,0(s2)
 658:	f9e5                	bnez	a1,648 <vprintf+0x16c>
        s = va_arg(ap, char*);
 65a:	8b4e                	mv	s6,s3
      state = 0;
 65c:	4981                	li	s3,0
 65e:	bdf9                	j	53c <vprintf+0x60>
          s = "(null)";
 660:	00000917          	auipc	s2,0x0
 664:	25090913          	addi	s2,s2,592 # 8b0 <malloc+0x10a>
        while(*s != 0){
 668:	02800593          	li	a1,40
 66c:	bff1                	j	648 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 66e:	008b0913          	addi	s2,s6,8
 672:	000b4583          	lbu	a1,0(s6)
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	d98080e7          	jalr	-616(ra) # 410 <putc>
 680:	8b4a                	mv	s6,s2
      state = 0;
 682:	4981                	li	s3,0
 684:	bd65                	j	53c <vprintf+0x60>
        putc(fd, c);
 686:	85d2                	mv	a1,s4
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	d86080e7          	jalr	-634(ra) # 410 <putc>
      state = 0;
 692:	4981                	li	s3,0
 694:	b565                	j	53c <vprintf+0x60>
        s = va_arg(ap, char*);
 696:	8b4e                	mv	s6,s3
      state = 0;
 698:	4981                	li	s3,0
 69a:	b54d                	j	53c <vprintf+0x60>
    }
  }
}
 69c:	70e6                	ld	ra,120(sp)
 69e:	7446                	ld	s0,112(sp)
 6a0:	74a6                	ld	s1,104(sp)
 6a2:	7906                	ld	s2,96(sp)
 6a4:	69e6                	ld	s3,88(sp)
 6a6:	6a46                	ld	s4,80(sp)
 6a8:	6aa6                	ld	s5,72(sp)
 6aa:	6b06                	ld	s6,64(sp)
 6ac:	7be2                	ld	s7,56(sp)
 6ae:	7c42                	ld	s8,48(sp)
 6b0:	7ca2                	ld	s9,40(sp)
 6b2:	7d02                	ld	s10,32(sp)
 6b4:	6de2                	ld	s11,24(sp)
 6b6:	6109                	addi	sp,sp,128
 6b8:	8082                	ret

00000000000006ba <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ba:	715d                	addi	sp,sp,-80
 6bc:	ec06                	sd	ra,24(sp)
 6be:	e822                	sd	s0,16(sp)
 6c0:	1000                	addi	s0,sp,32
 6c2:	e010                	sd	a2,0(s0)
 6c4:	e414                	sd	a3,8(s0)
 6c6:	e818                	sd	a4,16(s0)
 6c8:	ec1c                	sd	a5,24(s0)
 6ca:	03043023          	sd	a6,32(s0)
 6ce:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6d2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6d6:	8622                	mv	a2,s0
 6d8:	00000097          	auipc	ra,0x0
 6dc:	e04080e7          	jalr	-508(ra) # 4dc <vprintf>
}
 6e0:	60e2                	ld	ra,24(sp)
 6e2:	6442                	ld	s0,16(sp)
 6e4:	6161                	addi	sp,sp,80
 6e6:	8082                	ret

00000000000006e8 <printf>:

void
printf(const char *fmt, ...)
{
 6e8:	711d                	addi	sp,sp,-96
 6ea:	ec06                	sd	ra,24(sp)
 6ec:	e822                	sd	s0,16(sp)
 6ee:	1000                	addi	s0,sp,32
 6f0:	e40c                	sd	a1,8(s0)
 6f2:	e810                	sd	a2,16(s0)
 6f4:	ec14                	sd	a3,24(s0)
 6f6:	f018                	sd	a4,32(s0)
 6f8:	f41c                	sd	a5,40(s0)
 6fa:	03043823          	sd	a6,48(s0)
 6fe:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 702:	00840613          	addi	a2,s0,8
 706:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 70a:	85aa                	mv	a1,a0
 70c:	4505                	li	a0,1
 70e:	00000097          	auipc	ra,0x0
 712:	dce080e7          	jalr	-562(ra) # 4dc <vprintf>
}
 716:	60e2                	ld	ra,24(sp)
 718:	6442                	ld	s0,16(sp)
 71a:	6125                	addi	sp,sp,96
 71c:	8082                	ret

000000000000071e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 71e:	1141                	addi	sp,sp,-16
 720:	e422                	sd	s0,8(sp)
 722:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 724:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 728:	00000797          	auipc	a5,0x0
 72c:	1a87b783          	ld	a5,424(a5) # 8d0 <freep>
 730:	a805                	j	760 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 732:	4618                	lw	a4,8(a2)
 734:	9db9                	addw	a1,a1,a4
 736:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 73a:	6398                	ld	a4,0(a5)
 73c:	6318                	ld	a4,0(a4)
 73e:	fee53823          	sd	a4,-16(a0)
 742:	a091                	j	786 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 744:	ff852703          	lw	a4,-8(a0)
 748:	9e39                	addw	a2,a2,a4
 74a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 74c:	ff053703          	ld	a4,-16(a0)
 750:	e398                	sd	a4,0(a5)
 752:	a099                	j	798 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 754:	6398                	ld	a4,0(a5)
 756:	00e7e463          	bltu	a5,a4,75e <free+0x40>
 75a:	00e6ea63          	bltu	a3,a4,76e <free+0x50>
{
 75e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 760:	fed7fae3          	bgeu	a5,a3,754 <free+0x36>
 764:	6398                	ld	a4,0(a5)
 766:	00e6e463          	bltu	a3,a4,76e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 76a:	fee7eae3          	bltu	a5,a4,75e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 76e:	ff852583          	lw	a1,-8(a0)
 772:	6390                	ld	a2,0(a5)
 774:	02059713          	slli	a4,a1,0x20
 778:	9301                	srli	a4,a4,0x20
 77a:	0712                	slli	a4,a4,0x4
 77c:	9736                	add	a4,a4,a3
 77e:	fae60ae3          	beq	a2,a4,732 <free+0x14>
    bp->s.ptr = p->s.ptr;
 782:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 786:	4790                	lw	a2,8(a5)
 788:	02061713          	slli	a4,a2,0x20
 78c:	9301                	srli	a4,a4,0x20
 78e:	0712                	slli	a4,a4,0x4
 790:	973e                	add	a4,a4,a5
 792:	fae689e3          	beq	a3,a4,744 <free+0x26>
  } else
    p->s.ptr = bp;
 796:	e394                	sd	a3,0(a5)
  freep = p;
 798:	00000717          	auipc	a4,0x0
 79c:	12f73c23          	sd	a5,312(a4) # 8d0 <freep>
}
 7a0:	6422                	ld	s0,8(sp)
 7a2:	0141                	addi	sp,sp,16
 7a4:	8082                	ret

00000000000007a6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7a6:	7139                	addi	sp,sp,-64
 7a8:	fc06                	sd	ra,56(sp)
 7aa:	f822                	sd	s0,48(sp)
 7ac:	f426                	sd	s1,40(sp)
 7ae:	f04a                	sd	s2,32(sp)
 7b0:	ec4e                	sd	s3,24(sp)
 7b2:	e852                	sd	s4,16(sp)
 7b4:	e456                	sd	s5,8(sp)
 7b6:	e05a                	sd	s6,0(sp)
 7b8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7ba:	02051493          	slli	s1,a0,0x20
 7be:	9081                	srli	s1,s1,0x20
 7c0:	04bd                	addi	s1,s1,15
 7c2:	8091                	srli	s1,s1,0x4
 7c4:	0014899b          	addiw	s3,s1,1
 7c8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7ca:	00000517          	auipc	a0,0x0
 7ce:	10653503          	ld	a0,262(a0) # 8d0 <freep>
 7d2:	c515                	beqz	a0,7fe <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7d6:	4798                	lw	a4,8(a5)
 7d8:	02977f63          	bgeu	a4,s1,816 <malloc+0x70>
 7dc:	8a4e                	mv	s4,s3
 7de:	0009871b          	sext.w	a4,s3
 7e2:	6685                	lui	a3,0x1
 7e4:	00d77363          	bgeu	a4,a3,7ea <malloc+0x44>
 7e8:	6a05                	lui	s4,0x1
 7ea:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ee:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7f2:	00000917          	auipc	s2,0x0
 7f6:	0de90913          	addi	s2,s2,222 # 8d0 <freep>
  if(p == (char*)-1)
 7fa:	5afd                	li	s5,-1
 7fc:	a88d                	j	86e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7fe:	00000797          	auipc	a5,0x0
 802:	0da78793          	addi	a5,a5,218 # 8d8 <base>
 806:	00000717          	auipc	a4,0x0
 80a:	0cf73523          	sd	a5,202(a4) # 8d0 <freep>
 80e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 810:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 814:	b7e1                	j	7dc <malloc+0x36>
      if(p->s.size == nunits)
 816:	02e48b63          	beq	s1,a4,84c <malloc+0xa6>
        p->s.size -= nunits;
 81a:	4137073b          	subw	a4,a4,s3
 81e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 820:	1702                	slli	a4,a4,0x20
 822:	9301                	srli	a4,a4,0x20
 824:	0712                	slli	a4,a4,0x4
 826:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 828:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 82c:	00000717          	auipc	a4,0x0
 830:	0aa73223          	sd	a0,164(a4) # 8d0 <freep>
      return (void*)(p + 1);
 834:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 838:	70e2                	ld	ra,56(sp)
 83a:	7442                	ld	s0,48(sp)
 83c:	74a2                	ld	s1,40(sp)
 83e:	7902                	ld	s2,32(sp)
 840:	69e2                	ld	s3,24(sp)
 842:	6a42                	ld	s4,16(sp)
 844:	6aa2                	ld	s5,8(sp)
 846:	6b02                	ld	s6,0(sp)
 848:	6121                	addi	sp,sp,64
 84a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 84c:	6398                	ld	a4,0(a5)
 84e:	e118                	sd	a4,0(a0)
 850:	bff1                	j	82c <malloc+0x86>
  hp->s.size = nu;
 852:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 856:	0541                	addi	a0,a0,16
 858:	00000097          	auipc	ra,0x0
 85c:	ec6080e7          	jalr	-314(ra) # 71e <free>
  return freep;
 860:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 864:	d971                	beqz	a0,838 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 866:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 868:	4798                	lw	a4,8(a5)
 86a:	fa9776e3          	bgeu	a4,s1,816 <malloc+0x70>
    if(p == freep)
 86e:	00093703          	ld	a4,0(s2)
 872:	853e                	mv	a0,a5
 874:	fef719e3          	bne	a4,a5,866 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 878:	8552                	mv	a0,s4
 87a:	00000097          	auipc	ra,0x0
 87e:	b46080e7          	jalr	-1210(ra) # 3c0 <sbrk>
  if(p == (char*)-1)
 882:	fd5518e3          	bne	a0,s5,852 <malloc+0xac>
        return 0;
 886:	4501                	li	a0,0
 888:	bf45                	j	838 <malloc+0x92>
