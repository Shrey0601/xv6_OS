
user/_forksleep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int m, n, x;

  if (argc != 3) {
   c:	478d                	li	a5,3
   e:	02f50063          	beq	a0,a5,2e <main+0x2e>
     fprintf(2, "syntax: forksleep m n\nAborting...\n");
  12:	00001597          	auipc	a1,0x1
  16:	8ee58593          	addi	a1,a1,-1810 # 900 <malloc+0xe8>
  1a:	4509                	li	a0,2
  1c:	00000097          	auipc	ra,0x0
  20:	710080e7          	jalr	1808(ra) # 72c <fprintf>
     exit(0);
  24:	4501                	li	a0,0
  26:	00000097          	auipc	ra,0x0
  2a:	374080e7          	jalr	884(ra) # 39a <exit>
  2e:	84ae                	mv	s1,a1
  }

  m = atoi(argv[1]);
  30:	6588                	ld	a0,8(a1)
  32:	00000097          	auipc	ra,0x0
  36:	268080e7          	jalr	616(ra) # 29a <atoi>
  3a:	892a                	mv	s2,a0
  if (m <= 0) {
  3c:	02a05b63          	blez	a0,72 <main+0x72>
     fprintf(2, "Invalid input\nAborting...\n");
     exit(0);
  }
  n = atoi(argv[2]);
  40:	6888                	ld	a0,16(s1)
  42:	00000097          	auipc	ra,0x0
  46:	258080e7          	jalr	600(ra) # 29a <atoi>
  4a:	84aa                	mv	s1,a0
  if ((n != 0) && (n != 1)) {
  4c:	0005071b          	sext.w	a4,a0
  50:	4785                	li	a5,1
  52:	02e7fe63          	bgeu	a5,a4,8e <main+0x8e>
     fprintf(2, "Invalid input\nAborting...\n");
  56:	00001597          	auipc	a1,0x1
  5a:	8d258593          	addi	a1,a1,-1838 # 928 <malloc+0x110>
  5e:	4509                	li	a0,2
  60:	00000097          	auipc	ra,0x0
  64:	6cc080e7          	jalr	1740(ra) # 72c <fprintf>
     exit(0);
  68:	4501                	li	a0,0
  6a:	00000097          	auipc	ra,0x0
  6e:	330080e7          	jalr	816(ra) # 39a <exit>
     fprintf(2, "Invalid input\nAborting...\n");
  72:	00001597          	auipc	a1,0x1
  76:	8b658593          	addi	a1,a1,-1866 # 928 <malloc+0x110>
  7a:	4509                	li	a0,2
  7c:	00000097          	auipc	ra,0x0
  80:	6b0080e7          	jalr	1712(ra) # 72c <fprintf>
     exit(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	314080e7          	jalr	788(ra) # 39a <exit>
  }

  x = fork();
  8e:	00000097          	auipc	ra,0x0
  92:	304080e7          	jalr	772(ra) # 392 <fork>
  if (x < 0) {
  96:	02054d63          	bltz	a0,d0 <main+0xd0>
     fprintf(2, "Error: cannot fork\nAborting...\n");
     exit(0);
  }
  else if (x > 0) {
  9a:	04a05f63          	blez	a0,f8 <main+0xf8>
     if (n) sleep(m);
  9e:	e4b9                	bnez	s1,ec <main+0xec>
     fprintf(1, "%d: Parent.\n", getpid());
  a0:	00000097          	auipc	ra,0x0
  a4:	37a080e7          	jalr	890(ra) # 41a <getpid>
  a8:	862a                	mv	a2,a0
  aa:	00001597          	auipc	a1,0x1
  ae:	8be58593          	addi	a1,a1,-1858 # 968 <malloc+0x150>
  b2:	4505                	li	a0,1
  b4:	00000097          	auipc	ra,0x0
  b8:	678080e7          	jalr	1656(ra) # 72c <fprintf>
     wait(0);
  bc:	4501                	li	a0,0
  be:	00000097          	auipc	ra,0x0
  c2:	2e4080e7          	jalr	740(ra) # 3a2 <wait>
  else {
     if (!n) sleep(m);
     fprintf(1, "%d: Child.\n", getpid());
  }

  exit(0);
  c6:	4501                	li	a0,0
  c8:	00000097          	auipc	ra,0x0
  cc:	2d2080e7          	jalr	722(ra) # 39a <exit>
     fprintf(2, "Error: cannot fork\nAborting...\n");
  d0:	00001597          	auipc	a1,0x1
  d4:	87858593          	addi	a1,a1,-1928 # 948 <malloc+0x130>
  d8:	4509                	li	a0,2
  da:	00000097          	auipc	ra,0x0
  de:	652080e7          	jalr	1618(ra) # 72c <fprintf>
     exit(0);
  e2:	4501                	li	a0,0
  e4:	00000097          	auipc	ra,0x0
  e8:	2b6080e7          	jalr	694(ra) # 39a <exit>
     if (n) sleep(m);
  ec:	854a                	mv	a0,s2
  ee:	00000097          	auipc	ra,0x0
  f2:	33c080e7          	jalr	828(ra) # 42a <sleep>
  f6:	b76d                	j	a0 <main+0xa0>
     if (!n) sleep(m);
  f8:	c085                	beqz	s1,118 <main+0x118>
     fprintf(1, "%d: Child.\n", getpid());
  fa:	00000097          	auipc	ra,0x0
  fe:	320080e7          	jalr	800(ra) # 41a <getpid>
 102:	862a                	mv	a2,a0
 104:	00001597          	auipc	a1,0x1
 108:	87458593          	addi	a1,a1,-1932 # 978 <malloc+0x160>
 10c:	4505                	li	a0,1
 10e:	00000097          	auipc	ra,0x0
 112:	61e080e7          	jalr	1566(ra) # 72c <fprintf>
 116:	bf45                	j	c6 <main+0xc6>
     if (!n) sleep(m);
 118:	854a                	mv	a0,s2
 11a:	00000097          	auipc	ra,0x0
 11e:	310080e7          	jalr	784(ra) # 42a <sleep>
 122:	bfe1                	j	fa <main+0xfa>

0000000000000124 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 124:	1141                	addi	sp,sp,-16
 126:	e422                	sd	s0,8(sp)
 128:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 12a:	87aa                	mv	a5,a0
 12c:	0585                	addi	a1,a1,1
 12e:	0785                	addi	a5,a5,1
 130:	fff5c703          	lbu	a4,-1(a1)
 134:	fee78fa3          	sb	a4,-1(a5)
 138:	fb75                	bnez	a4,12c <strcpy+0x8>
    ;
  return os;
}
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	addi	sp,sp,16
 13e:	8082                	ret

0000000000000140 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 140:	1141                	addi	sp,sp,-16
 142:	e422                	sd	s0,8(sp)
 144:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 146:	00054783          	lbu	a5,0(a0)
 14a:	cb91                	beqz	a5,15e <strcmp+0x1e>
 14c:	0005c703          	lbu	a4,0(a1)
 150:	00f71763          	bne	a4,a5,15e <strcmp+0x1e>
    p++, q++;
 154:	0505                	addi	a0,a0,1
 156:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 158:	00054783          	lbu	a5,0(a0)
 15c:	fbe5                	bnez	a5,14c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 15e:	0005c503          	lbu	a0,0(a1)
}
 162:	40a7853b          	subw	a0,a5,a0
 166:	6422                	ld	s0,8(sp)
 168:	0141                	addi	sp,sp,16
 16a:	8082                	ret

000000000000016c <strlen>:

uint
strlen(const char *s)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 172:	00054783          	lbu	a5,0(a0)
 176:	cf91                	beqz	a5,192 <strlen+0x26>
 178:	0505                	addi	a0,a0,1
 17a:	87aa                	mv	a5,a0
 17c:	4685                	li	a3,1
 17e:	9e89                	subw	a3,a3,a0
 180:	00f6853b          	addw	a0,a3,a5
 184:	0785                	addi	a5,a5,1
 186:	fff7c703          	lbu	a4,-1(a5)
 18a:	fb7d                	bnez	a4,180 <strlen+0x14>
    ;
  return n;
}
 18c:	6422                	ld	s0,8(sp)
 18e:	0141                	addi	sp,sp,16
 190:	8082                	ret
  for(n = 0; s[n]; n++)
 192:	4501                	li	a0,0
 194:	bfe5                	j	18c <strlen+0x20>

0000000000000196 <memset>:

void*
memset(void *dst, int c, uint n)
{
 196:	1141                	addi	sp,sp,-16
 198:	e422                	sd	s0,8(sp)
 19a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 19c:	ce09                	beqz	a2,1b6 <memset+0x20>
 19e:	87aa                	mv	a5,a0
 1a0:	fff6071b          	addiw	a4,a2,-1
 1a4:	1702                	slli	a4,a4,0x20
 1a6:	9301                	srli	a4,a4,0x20
 1a8:	0705                	addi	a4,a4,1
 1aa:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1ac:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1b0:	0785                	addi	a5,a5,1
 1b2:	fee79de3          	bne	a5,a4,1ac <memset+0x16>
  }
  return dst;
}
 1b6:	6422                	ld	s0,8(sp)
 1b8:	0141                	addi	sp,sp,16
 1ba:	8082                	ret

00000000000001bc <strchr>:

char*
strchr(const char *s, char c)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e422                	sd	s0,8(sp)
 1c0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1c2:	00054783          	lbu	a5,0(a0)
 1c6:	cb99                	beqz	a5,1dc <strchr+0x20>
    if(*s == c)
 1c8:	00f58763          	beq	a1,a5,1d6 <strchr+0x1a>
  for(; *s; s++)
 1cc:	0505                	addi	a0,a0,1
 1ce:	00054783          	lbu	a5,0(a0)
 1d2:	fbfd                	bnez	a5,1c8 <strchr+0xc>
      return (char*)s;
  return 0;
 1d4:	4501                	li	a0,0
}
 1d6:	6422                	ld	s0,8(sp)
 1d8:	0141                	addi	sp,sp,16
 1da:	8082                	ret
  return 0;
 1dc:	4501                	li	a0,0
 1de:	bfe5                	j	1d6 <strchr+0x1a>

00000000000001e0 <gets>:

char*
gets(char *buf, int max)
{
 1e0:	711d                	addi	sp,sp,-96
 1e2:	ec86                	sd	ra,88(sp)
 1e4:	e8a2                	sd	s0,80(sp)
 1e6:	e4a6                	sd	s1,72(sp)
 1e8:	e0ca                	sd	s2,64(sp)
 1ea:	fc4e                	sd	s3,56(sp)
 1ec:	f852                	sd	s4,48(sp)
 1ee:	f456                	sd	s5,40(sp)
 1f0:	f05a                	sd	s6,32(sp)
 1f2:	ec5e                	sd	s7,24(sp)
 1f4:	1080                	addi	s0,sp,96
 1f6:	8baa                	mv	s7,a0
 1f8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fa:	892a                	mv	s2,a0
 1fc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1fe:	4aa9                	li	s5,10
 200:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 202:	89a6                	mv	s3,s1
 204:	2485                	addiw	s1,s1,1
 206:	0344d863          	bge	s1,s4,236 <gets+0x56>
    cc = read(0, &c, 1);
 20a:	4605                	li	a2,1
 20c:	faf40593          	addi	a1,s0,-81
 210:	4501                	li	a0,0
 212:	00000097          	auipc	ra,0x0
 216:	1a0080e7          	jalr	416(ra) # 3b2 <read>
    if(cc < 1)
 21a:	00a05e63          	blez	a0,236 <gets+0x56>
    buf[i++] = c;
 21e:	faf44783          	lbu	a5,-81(s0)
 222:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 226:	01578763          	beq	a5,s5,234 <gets+0x54>
 22a:	0905                	addi	s2,s2,1
 22c:	fd679be3          	bne	a5,s6,202 <gets+0x22>
  for(i=0; i+1 < max; ){
 230:	89a6                	mv	s3,s1
 232:	a011                	j	236 <gets+0x56>
 234:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 236:	99de                	add	s3,s3,s7
 238:	00098023          	sb	zero,0(s3)
  return buf;
}
 23c:	855e                	mv	a0,s7
 23e:	60e6                	ld	ra,88(sp)
 240:	6446                	ld	s0,80(sp)
 242:	64a6                	ld	s1,72(sp)
 244:	6906                	ld	s2,64(sp)
 246:	79e2                	ld	s3,56(sp)
 248:	7a42                	ld	s4,48(sp)
 24a:	7aa2                	ld	s5,40(sp)
 24c:	7b02                	ld	s6,32(sp)
 24e:	6be2                	ld	s7,24(sp)
 250:	6125                	addi	sp,sp,96
 252:	8082                	ret

0000000000000254 <stat>:

int
stat(const char *n, struct stat *st)
{
 254:	1101                	addi	sp,sp,-32
 256:	ec06                	sd	ra,24(sp)
 258:	e822                	sd	s0,16(sp)
 25a:	e426                	sd	s1,8(sp)
 25c:	e04a                	sd	s2,0(sp)
 25e:	1000                	addi	s0,sp,32
 260:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 262:	4581                	li	a1,0
 264:	00000097          	auipc	ra,0x0
 268:	176080e7          	jalr	374(ra) # 3da <open>
  if(fd < 0)
 26c:	02054563          	bltz	a0,296 <stat+0x42>
 270:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 272:	85ca                	mv	a1,s2
 274:	00000097          	auipc	ra,0x0
 278:	17e080e7          	jalr	382(ra) # 3f2 <fstat>
 27c:	892a                	mv	s2,a0
  close(fd);
 27e:	8526                	mv	a0,s1
 280:	00000097          	auipc	ra,0x0
 284:	142080e7          	jalr	322(ra) # 3c2 <close>
  return r;
}
 288:	854a                	mv	a0,s2
 28a:	60e2                	ld	ra,24(sp)
 28c:	6442                	ld	s0,16(sp)
 28e:	64a2                	ld	s1,8(sp)
 290:	6902                	ld	s2,0(sp)
 292:	6105                	addi	sp,sp,32
 294:	8082                	ret
    return -1;
 296:	597d                	li	s2,-1
 298:	bfc5                	j	288 <stat+0x34>

000000000000029a <atoi>:

int
atoi(const char *s)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e422                	sd	s0,8(sp)
 29e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2a0:	00054603          	lbu	a2,0(a0)
 2a4:	fd06079b          	addiw	a5,a2,-48
 2a8:	0ff7f793          	andi	a5,a5,255
 2ac:	4725                	li	a4,9
 2ae:	02f76963          	bltu	a4,a5,2e0 <atoi+0x46>
 2b2:	86aa                	mv	a3,a0
  n = 0;
 2b4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2b6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2b8:	0685                	addi	a3,a3,1
 2ba:	0025179b          	slliw	a5,a0,0x2
 2be:	9fa9                	addw	a5,a5,a0
 2c0:	0017979b          	slliw	a5,a5,0x1
 2c4:	9fb1                	addw	a5,a5,a2
 2c6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ca:	0006c603          	lbu	a2,0(a3)
 2ce:	fd06071b          	addiw	a4,a2,-48
 2d2:	0ff77713          	andi	a4,a4,255
 2d6:	fee5f1e3          	bgeu	a1,a4,2b8 <atoi+0x1e>
  return n;
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret
  n = 0;
 2e0:	4501                	li	a0,0
 2e2:	bfe5                	j	2da <atoi+0x40>

00000000000002e4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2e4:	1141                	addi	sp,sp,-16
 2e6:	e422                	sd	s0,8(sp)
 2e8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2ea:	02b57663          	bgeu	a0,a1,316 <memmove+0x32>
    while(n-- > 0)
 2ee:	02c05163          	blez	a2,310 <memmove+0x2c>
 2f2:	fff6079b          	addiw	a5,a2,-1
 2f6:	1782                	slli	a5,a5,0x20
 2f8:	9381                	srli	a5,a5,0x20
 2fa:	0785                	addi	a5,a5,1
 2fc:	97aa                	add	a5,a5,a0
  dst = vdst;
 2fe:	872a                	mv	a4,a0
      *dst++ = *src++;
 300:	0585                	addi	a1,a1,1
 302:	0705                	addi	a4,a4,1
 304:	fff5c683          	lbu	a3,-1(a1)
 308:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 30c:	fee79ae3          	bne	a5,a4,300 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 310:	6422                	ld	s0,8(sp)
 312:	0141                	addi	sp,sp,16
 314:	8082                	ret
    dst += n;
 316:	00c50733          	add	a4,a0,a2
    src += n;
 31a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 31c:	fec05ae3          	blez	a2,310 <memmove+0x2c>
 320:	fff6079b          	addiw	a5,a2,-1
 324:	1782                	slli	a5,a5,0x20
 326:	9381                	srli	a5,a5,0x20
 328:	fff7c793          	not	a5,a5
 32c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 32e:	15fd                	addi	a1,a1,-1
 330:	177d                	addi	a4,a4,-1
 332:	0005c683          	lbu	a3,0(a1)
 336:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 33a:	fee79ae3          	bne	a5,a4,32e <memmove+0x4a>
 33e:	bfc9                	j	310 <memmove+0x2c>

0000000000000340 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 340:	1141                	addi	sp,sp,-16
 342:	e422                	sd	s0,8(sp)
 344:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 346:	ca05                	beqz	a2,376 <memcmp+0x36>
 348:	fff6069b          	addiw	a3,a2,-1
 34c:	1682                	slli	a3,a3,0x20
 34e:	9281                	srli	a3,a3,0x20
 350:	0685                	addi	a3,a3,1
 352:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 354:	00054783          	lbu	a5,0(a0)
 358:	0005c703          	lbu	a4,0(a1)
 35c:	00e79863          	bne	a5,a4,36c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 360:	0505                	addi	a0,a0,1
    p2++;
 362:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 364:	fed518e3          	bne	a0,a3,354 <memcmp+0x14>
  }
  return 0;
 368:	4501                	li	a0,0
 36a:	a019                	j	370 <memcmp+0x30>
      return *p1 - *p2;
 36c:	40e7853b          	subw	a0,a5,a4
}
 370:	6422                	ld	s0,8(sp)
 372:	0141                	addi	sp,sp,16
 374:	8082                	ret
  return 0;
 376:	4501                	li	a0,0
 378:	bfe5                	j	370 <memcmp+0x30>

000000000000037a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 37a:	1141                	addi	sp,sp,-16
 37c:	e406                	sd	ra,8(sp)
 37e:	e022                	sd	s0,0(sp)
 380:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 382:	00000097          	auipc	ra,0x0
 386:	f62080e7          	jalr	-158(ra) # 2e4 <memmove>
}
 38a:	60a2                	ld	ra,8(sp)
 38c:	6402                	ld	s0,0(sp)
 38e:	0141                	addi	sp,sp,16
 390:	8082                	ret

0000000000000392 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 392:	4885                	li	a7,1
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <exit>:
.global exit
exit:
 li a7, SYS_exit
 39a:	4889                	li	a7,2
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3a2:	488d                	li	a7,3
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3aa:	4891                	li	a7,4
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <read>:
.global read
read:
 li a7, SYS_read
 3b2:	4895                	li	a7,5
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <write>:
.global write
write:
 li a7, SYS_write
 3ba:	48c1                	li	a7,16
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <close>:
.global close
close:
 li a7, SYS_close
 3c2:	48d5                	li	a7,21
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ca:	4899                	li	a7,6
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3d2:	489d                	li	a7,7
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <open>:
.global open
open:
 li a7, SYS_open
 3da:	48bd                	li	a7,15
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3e2:	48c5                	li	a7,17
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ea:	48c9                	li	a7,18
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3f2:	48a1                	li	a7,8
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <link>:
.global link
link:
 li a7, SYS_link
 3fa:	48cd                	li	a7,19
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 402:	48d1                	li	a7,20
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 40a:	48a5                	li	a7,9
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <dup>:
.global dup
dup:
 li a7, SYS_dup
 412:	48a9                	li	a7,10
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 41a:	48ad                	li	a7,11
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 422:	48b1                	li	a7,12
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 42a:	48b5                	li	a7,13
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 432:	48b9                	li	a7,14
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 43a:	48d9                	li	a7,22
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <yield>:
.global yield
yield:
 li a7, SYS_yield
 442:	48dd                	li	a7,23
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 44a:	48e1                	li	a7,24
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 452:	48e5                	li	a7,25
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 45a:	48e9                	li	a7,26
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <ps>:
.global ps
ps:
 li a7, SYS_ps
 462:	48ed                	li	a7,27
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 46a:	48f1                	li	a7,28
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 472:	48f5                	li	a7,29
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 47a:	48f9                	li	a7,30
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 482:	1101                	addi	sp,sp,-32
 484:	ec06                	sd	ra,24(sp)
 486:	e822                	sd	s0,16(sp)
 488:	1000                	addi	s0,sp,32
 48a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 48e:	4605                	li	a2,1
 490:	fef40593          	addi	a1,s0,-17
 494:	00000097          	auipc	ra,0x0
 498:	f26080e7          	jalr	-218(ra) # 3ba <write>
}
 49c:	60e2                	ld	ra,24(sp)
 49e:	6442                	ld	s0,16(sp)
 4a0:	6105                	addi	sp,sp,32
 4a2:	8082                	ret

00000000000004a4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4a4:	7139                	addi	sp,sp,-64
 4a6:	fc06                	sd	ra,56(sp)
 4a8:	f822                	sd	s0,48(sp)
 4aa:	f426                	sd	s1,40(sp)
 4ac:	f04a                	sd	s2,32(sp)
 4ae:	ec4e                	sd	s3,24(sp)
 4b0:	0080                	addi	s0,sp,64
 4b2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4b4:	c299                	beqz	a3,4ba <printint+0x16>
 4b6:	0805c863          	bltz	a1,546 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ba:	2581                	sext.w	a1,a1
  neg = 0;
 4bc:	4881                	li	a7,0
 4be:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4c2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4c4:	2601                	sext.w	a2,a2
 4c6:	00000517          	auipc	a0,0x0
 4ca:	4ca50513          	addi	a0,a0,1226 # 990 <digits>
 4ce:	883a                	mv	a6,a4
 4d0:	2705                	addiw	a4,a4,1
 4d2:	02c5f7bb          	remuw	a5,a1,a2
 4d6:	1782                	slli	a5,a5,0x20
 4d8:	9381                	srli	a5,a5,0x20
 4da:	97aa                	add	a5,a5,a0
 4dc:	0007c783          	lbu	a5,0(a5)
 4e0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4e4:	0005879b          	sext.w	a5,a1
 4e8:	02c5d5bb          	divuw	a1,a1,a2
 4ec:	0685                	addi	a3,a3,1
 4ee:	fec7f0e3          	bgeu	a5,a2,4ce <printint+0x2a>
  if(neg)
 4f2:	00088b63          	beqz	a7,508 <printint+0x64>
    buf[i++] = '-';
 4f6:	fd040793          	addi	a5,s0,-48
 4fa:	973e                	add	a4,a4,a5
 4fc:	02d00793          	li	a5,45
 500:	fef70823          	sb	a5,-16(a4)
 504:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 508:	02e05863          	blez	a4,538 <printint+0x94>
 50c:	fc040793          	addi	a5,s0,-64
 510:	00e78933          	add	s2,a5,a4
 514:	fff78993          	addi	s3,a5,-1
 518:	99ba                	add	s3,s3,a4
 51a:	377d                	addiw	a4,a4,-1
 51c:	1702                	slli	a4,a4,0x20
 51e:	9301                	srli	a4,a4,0x20
 520:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 524:	fff94583          	lbu	a1,-1(s2)
 528:	8526                	mv	a0,s1
 52a:	00000097          	auipc	ra,0x0
 52e:	f58080e7          	jalr	-168(ra) # 482 <putc>
  while(--i >= 0)
 532:	197d                	addi	s2,s2,-1
 534:	ff3918e3          	bne	s2,s3,524 <printint+0x80>
}
 538:	70e2                	ld	ra,56(sp)
 53a:	7442                	ld	s0,48(sp)
 53c:	74a2                	ld	s1,40(sp)
 53e:	7902                	ld	s2,32(sp)
 540:	69e2                	ld	s3,24(sp)
 542:	6121                	addi	sp,sp,64
 544:	8082                	ret
    x = -xx;
 546:	40b005bb          	negw	a1,a1
    neg = 1;
 54a:	4885                	li	a7,1
    x = -xx;
 54c:	bf8d                	j	4be <printint+0x1a>

000000000000054e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 54e:	7119                	addi	sp,sp,-128
 550:	fc86                	sd	ra,120(sp)
 552:	f8a2                	sd	s0,112(sp)
 554:	f4a6                	sd	s1,104(sp)
 556:	f0ca                	sd	s2,96(sp)
 558:	ecce                	sd	s3,88(sp)
 55a:	e8d2                	sd	s4,80(sp)
 55c:	e4d6                	sd	s5,72(sp)
 55e:	e0da                	sd	s6,64(sp)
 560:	fc5e                	sd	s7,56(sp)
 562:	f862                	sd	s8,48(sp)
 564:	f466                	sd	s9,40(sp)
 566:	f06a                	sd	s10,32(sp)
 568:	ec6e                	sd	s11,24(sp)
 56a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 56c:	0005c903          	lbu	s2,0(a1)
 570:	18090f63          	beqz	s2,70e <vprintf+0x1c0>
 574:	8aaa                	mv	s5,a0
 576:	8b32                	mv	s6,a2
 578:	00158493          	addi	s1,a1,1
  state = 0;
 57c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 57e:	02500a13          	li	s4,37
      if(c == 'd'){
 582:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 586:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 58a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 58e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 592:	00000b97          	auipc	s7,0x0
 596:	3feb8b93          	addi	s7,s7,1022 # 990 <digits>
 59a:	a839                	j	5b8 <vprintf+0x6a>
        putc(fd, c);
 59c:	85ca                	mv	a1,s2
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	ee2080e7          	jalr	-286(ra) # 482 <putc>
 5a8:	a019                	j	5ae <vprintf+0x60>
    } else if(state == '%'){
 5aa:	01498f63          	beq	s3,s4,5c8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5ae:	0485                	addi	s1,s1,1
 5b0:	fff4c903          	lbu	s2,-1(s1)
 5b4:	14090d63          	beqz	s2,70e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5b8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5bc:	fe0997e3          	bnez	s3,5aa <vprintf+0x5c>
      if(c == '%'){
 5c0:	fd479ee3          	bne	a5,s4,59c <vprintf+0x4e>
        state = '%';
 5c4:	89be                	mv	s3,a5
 5c6:	b7e5                	j	5ae <vprintf+0x60>
      if(c == 'd'){
 5c8:	05878063          	beq	a5,s8,608 <vprintf+0xba>
      } else if(c == 'l') {
 5cc:	05978c63          	beq	a5,s9,624 <vprintf+0xd6>
      } else if(c == 'x') {
 5d0:	07a78863          	beq	a5,s10,640 <vprintf+0xf2>
      } else if(c == 'p') {
 5d4:	09b78463          	beq	a5,s11,65c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5d8:	07300713          	li	a4,115
 5dc:	0ce78663          	beq	a5,a4,6a8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5e0:	06300713          	li	a4,99
 5e4:	0ee78e63          	beq	a5,a4,6e0 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5e8:	11478863          	beq	a5,s4,6f8 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ec:	85d2                	mv	a1,s4
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	e92080e7          	jalr	-366(ra) # 482 <putc>
        putc(fd, c);
 5f8:	85ca                	mv	a1,s2
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	e86080e7          	jalr	-378(ra) # 482 <putc>
      }
      state = 0;
 604:	4981                	li	s3,0
 606:	b765                	j	5ae <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 608:	008b0913          	addi	s2,s6,8
 60c:	4685                	li	a3,1
 60e:	4629                	li	a2,10
 610:	000b2583          	lw	a1,0(s6)
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	e8e080e7          	jalr	-370(ra) # 4a4 <printint>
 61e:	8b4a                	mv	s6,s2
      state = 0;
 620:	4981                	li	s3,0
 622:	b771                	j	5ae <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 624:	008b0913          	addi	s2,s6,8
 628:	4681                	li	a3,0
 62a:	4629                	li	a2,10
 62c:	000b2583          	lw	a1,0(s6)
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	e72080e7          	jalr	-398(ra) # 4a4 <printint>
 63a:	8b4a                	mv	s6,s2
      state = 0;
 63c:	4981                	li	s3,0
 63e:	bf85                	j	5ae <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 640:	008b0913          	addi	s2,s6,8
 644:	4681                	li	a3,0
 646:	4641                	li	a2,16
 648:	000b2583          	lw	a1,0(s6)
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	e56080e7          	jalr	-426(ra) # 4a4 <printint>
 656:	8b4a                	mv	s6,s2
      state = 0;
 658:	4981                	li	s3,0
 65a:	bf91                	j	5ae <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 65c:	008b0793          	addi	a5,s6,8
 660:	f8f43423          	sd	a5,-120(s0)
 664:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 668:	03000593          	li	a1,48
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	e14080e7          	jalr	-492(ra) # 482 <putc>
  putc(fd, 'x');
 676:	85ea                	mv	a1,s10
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	e08080e7          	jalr	-504(ra) # 482 <putc>
 682:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 684:	03c9d793          	srli	a5,s3,0x3c
 688:	97de                	add	a5,a5,s7
 68a:	0007c583          	lbu	a1,0(a5)
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	df2080e7          	jalr	-526(ra) # 482 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 698:	0992                	slli	s3,s3,0x4
 69a:	397d                	addiw	s2,s2,-1
 69c:	fe0914e3          	bnez	s2,684 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6a0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	b721                	j	5ae <vprintf+0x60>
        s = va_arg(ap, char*);
 6a8:	008b0993          	addi	s3,s6,8
 6ac:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6b0:	02090163          	beqz	s2,6d2 <vprintf+0x184>
        while(*s != 0){
 6b4:	00094583          	lbu	a1,0(s2)
 6b8:	c9a1                	beqz	a1,708 <vprintf+0x1ba>
          putc(fd, *s);
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	dc6080e7          	jalr	-570(ra) # 482 <putc>
          s++;
 6c4:	0905                	addi	s2,s2,1
        while(*s != 0){
 6c6:	00094583          	lbu	a1,0(s2)
 6ca:	f9e5                	bnez	a1,6ba <vprintf+0x16c>
        s = va_arg(ap, char*);
 6cc:	8b4e                	mv	s6,s3
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	bdf9                	j	5ae <vprintf+0x60>
          s = "(null)";
 6d2:	00000917          	auipc	s2,0x0
 6d6:	2b690913          	addi	s2,s2,694 # 988 <malloc+0x170>
        while(*s != 0){
 6da:	02800593          	li	a1,40
 6de:	bff1                	j	6ba <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6e0:	008b0913          	addi	s2,s6,8
 6e4:	000b4583          	lbu	a1,0(s6)
 6e8:	8556                	mv	a0,s5
 6ea:	00000097          	auipc	ra,0x0
 6ee:	d98080e7          	jalr	-616(ra) # 482 <putc>
 6f2:	8b4a                	mv	s6,s2
      state = 0;
 6f4:	4981                	li	s3,0
 6f6:	bd65                	j	5ae <vprintf+0x60>
        putc(fd, c);
 6f8:	85d2                	mv	a1,s4
 6fa:	8556                	mv	a0,s5
 6fc:	00000097          	auipc	ra,0x0
 700:	d86080e7          	jalr	-634(ra) # 482 <putc>
      state = 0;
 704:	4981                	li	s3,0
 706:	b565                	j	5ae <vprintf+0x60>
        s = va_arg(ap, char*);
 708:	8b4e                	mv	s6,s3
      state = 0;
 70a:	4981                	li	s3,0
 70c:	b54d                	j	5ae <vprintf+0x60>
    }
  }
}
 70e:	70e6                	ld	ra,120(sp)
 710:	7446                	ld	s0,112(sp)
 712:	74a6                	ld	s1,104(sp)
 714:	7906                	ld	s2,96(sp)
 716:	69e6                	ld	s3,88(sp)
 718:	6a46                	ld	s4,80(sp)
 71a:	6aa6                	ld	s5,72(sp)
 71c:	6b06                	ld	s6,64(sp)
 71e:	7be2                	ld	s7,56(sp)
 720:	7c42                	ld	s8,48(sp)
 722:	7ca2                	ld	s9,40(sp)
 724:	7d02                	ld	s10,32(sp)
 726:	6de2                	ld	s11,24(sp)
 728:	6109                	addi	sp,sp,128
 72a:	8082                	ret

000000000000072c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 72c:	715d                	addi	sp,sp,-80
 72e:	ec06                	sd	ra,24(sp)
 730:	e822                	sd	s0,16(sp)
 732:	1000                	addi	s0,sp,32
 734:	e010                	sd	a2,0(s0)
 736:	e414                	sd	a3,8(s0)
 738:	e818                	sd	a4,16(s0)
 73a:	ec1c                	sd	a5,24(s0)
 73c:	03043023          	sd	a6,32(s0)
 740:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 744:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 748:	8622                	mv	a2,s0
 74a:	00000097          	auipc	ra,0x0
 74e:	e04080e7          	jalr	-508(ra) # 54e <vprintf>
}
 752:	60e2                	ld	ra,24(sp)
 754:	6442                	ld	s0,16(sp)
 756:	6161                	addi	sp,sp,80
 758:	8082                	ret

000000000000075a <printf>:

void
printf(const char *fmt, ...)
{
 75a:	711d                	addi	sp,sp,-96
 75c:	ec06                	sd	ra,24(sp)
 75e:	e822                	sd	s0,16(sp)
 760:	1000                	addi	s0,sp,32
 762:	e40c                	sd	a1,8(s0)
 764:	e810                	sd	a2,16(s0)
 766:	ec14                	sd	a3,24(s0)
 768:	f018                	sd	a4,32(s0)
 76a:	f41c                	sd	a5,40(s0)
 76c:	03043823          	sd	a6,48(s0)
 770:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 774:	00840613          	addi	a2,s0,8
 778:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 77c:	85aa                	mv	a1,a0
 77e:	4505                	li	a0,1
 780:	00000097          	auipc	ra,0x0
 784:	dce080e7          	jalr	-562(ra) # 54e <vprintf>
}
 788:	60e2                	ld	ra,24(sp)
 78a:	6442                	ld	s0,16(sp)
 78c:	6125                	addi	sp,sp,96
 78e:	8082                	ret

0000000000000790 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 790:	1141                	addi	sp,sp,-16
 792:	e422                	sd	s0,8(sp)
 794:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 796:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79a:	00000797          	auipc	a5,0x0
 79e:	20e7b783          	ld	a5,526(a5) # 9a8 <freep>
 7a2:	a805                	j	7d2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7a4:	4618                	lw	a4,8(a2)
 7a6:	9db9                	addw	a1,a1,a4
 7a8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ac:	6398                	ld	a4,0(a5)
 7ae:	6318                	ld	a4,0(a4)
 7b0:	fee53823          	sd	a4,-16(a0)
 7b4:	a091                	j	7f8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7b6:	ff852703          	lw	a4,-8(a0)
 7ba:	9e39                	addw	a2,a2,a4
 7bc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7be:	ff053703          	ld	a4,-16(a0)
 7c2:	e398                	sd	a4,0(a5)
 7c4:	a099                	j	80a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c6:	6398                	ld	a4,0(a5)
 7c8:	00e7e463          	bltu	a5,a4,7d0 <free+0x40>
 7cc:	00e6ea63          	bltu	a3,a4,7e0 <free+0x50>
{
 7d0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d2:	fed7fae3          	bgeu	a5,a3,7c6 <free+0x36>
 7d6:	6398                	ld	a4,0(a5)
 7d8:	00e6e463          	bltu	a3,a4,7e0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7dc:	fee7eae3          	bltu	a5,a4,7d0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7e0:	ff852583          	lw	a1,-8(a0)
 7e4:	6390                	ld	a2,0(a5)
 7e6:	02059713          	slli	a4,a1,0x20
 7ea:	9301                	srli	a4,a4,0x20
 7ec:	0712                	slli	a4,a4,0x4
 7ee:	9736                	add	a4,a4,a3
 7f0:	fae60ae3          	beq	a2,a4,7a4 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7f4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7f8:	4790                	lw	a2,8(a5)
 7fa:	02061713          	slli	a4,a2,0x20
 7fe:	9301                	srli	a4,a4,0x20
 800:	0712                	slli	a4,a4,0x4
 802:	973e                	add	a4,a4,a5
 804:	fae689e3          	beq	a3,a4,7b6 <free+0x26>
  } else
    p->s.ptr = bp;
 808:	e394                	sd	a3,0(a5)
  freep = p;
 80a:	00000717          	auipc	a4,0x0
 80e:	18f73f23          	sd	a5,414(a4) # 9a8 <freep>
}
 812:	6422                	ld	s0,8(sp)
 814:	0141                	addi	sp,sp,16
 816:	8082                	ret

0000000000000818 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 818:	7139                	addi	sp,sp,-64
 81a:	fc06                	sd	ra,56(sp)
 81c:	f822                	sd	s0,48(sp)
 81e:	f426                	sd	s1,40(sp)
 820:	f04a                	sd	s2,32(sp)
 822:	ec4e                	sd	s3,24(sp)
 824:	e852                	sd	s4,16(sp)
 826:	e456                	sd	s5,8(sp)
 828:	e05a                	sd	s6,0(sp)
 82a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 82c:	02051493          	slli	s1,a0,0x20
 830:	9081                	srli	s1,s1,0x20
 832:	04bd                	addi	s1,s1,15
 834:	8091                	srli	s1,s1,0x4
 836:	0014899b          	addiw	s3,s1,1
 83a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 83c:	00000517          	auipc	a0,0x0
 840:	16c53503          	ld	a0,364(a0) # 9a8 <freep>
 844:	c515                	beqz	a0,870 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 846:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 848:	4798                	lw	a4,8(a5)
 84a:	02977f63          	bgeu	a4,s1,888 <malloc+0x70>
 84e:	8a4e                	mv	s4,s3
 850:	0009871b          	sext.w	a4,s3
 854:	6685                	lui	a3,0x1
 856:	00d77363          	bgeu	a4,a3,85c <malloc+0x44>
 85a:	6a05                	lui	s4,0x1
 85c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 860:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 864:	00000917          	auipc	s2,0x0
 868:	14490913          	addi	s2,s2,324 # 9a8 <freep>
  if(p == (char*)-1)
 86c:	5afd                	li	s5,-1
 86e:	a88d                	j	8e0 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 870:	00000797          	auipc	a5,0x0
 874:	14078793          	addi	a5,a5,320 # 9b0 <base>
 878:	00000717          	auipc	a4,0x0
 87c:	12f73823          	sd	a5,304(a4) # 9a8 <freep>
 880:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 882:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 886:	b7e1                	j	84e <malloc+0x36>
      if(p->s.size == nunits)
 888:	02e48b63          	beq	s1,a4,8be <malloc+0xa6>
        p->s.size -= nunits;
 88c:	4137073b          	subw	a4,a4,s3
 890:	c798                	sw	a4,8(a5)
        p += p->s.size;
 892:	1702                	slli	a4,a4,0x20
 894:	9301                	srli	a4,a4,0x20
 896:	0712                	slli	a4,a4,0x4
 898:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 89a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 89e:	00000717          	auipc	a4,0x0
 8a2:	10a73523          	sd	a0,266(a4) # 9a8 <freep>
      return (void*)(p + 1);
 8a6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8aa:	70e2                	ld	ra,56(sp)
 8ac:	7442                	ld	s0,48(sp)
 8ae:	74a2                	ld	s1,40(sp)
 8b0:	7902                	ld	s2,32(sp)
 8b2:	69e2                	ld	s3,24(sp)
 8b4:	6a42                	ld	s4,16(sp)
 8b6:	6aa2                	ld	s5,8(sp)
 8b8:	6b02                	ld	s6,0(sp)
 8ba:	6121                	addi	sp,sp,64
 8bc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8be:	6398                	ld	a4,0(a5)
 8c0:	e118                	sd	a4,0(a0)
 8c2:	bff1                	j	89e <malloc+0x86>
  hp->s.size = nu;
 8c4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8c8:	0541                	addi	a0,a0,16
 8ca:	00000097          	auipc	ra,0x0
 8ce:	ec6080e7          	jalr	-314(ra) # 790 <free>
  return freep;
 8d2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8d6:	d971                	beqz	a0,8aa <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8da:	4798                	lw	a4,8(a5)
 8dc:	fa9776e3          	bgeu	a4,s1,888 <malloc+0x70>
    if(p == freep)
 8e0:	00093703          	ld	a4,0(s2)
 8e4:	853e                	mv	a0,a5
 8e6:	fef719e3          	bne	a4,a5,8d8 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8ea:	8552                	mv	a0,s4
 8ec:	00000097          	auipc	ra,0x0
 8f0:	b36080e7          	jalr	-1226(ra) # 422 <sbrk>
  if(p == (char*)-1)
 8f4:	fd5518e3          	bne	a0,s5,8c4 <malloc+0xac>
        return 0;
 8f8:	4501                	li	a0,0
 8fa:	bf45                	j	8aa <malloc+0x92>
