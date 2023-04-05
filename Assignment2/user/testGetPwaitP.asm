
user/_testGetPwaitP:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
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
   c:	1800                	addi	s0,sp,48
  int m, n, x;

  if (argc != 3) {
   e:	478d                	li	a5,3
  10:	02f50063          	beq	a0,a5,30 <main+0x30>
     fprintf(2, "syntax: testGetPwaitP m n\nAborting...\n");
  14:	00001597          	auipc	a1,0x1
  18:	91458593          	addi	a1,a1,-1772 # 928 <malloc+0xea>
  1c:	4509                	li	a0,2
  1e:	00000097          	auipc	ra,0x0
  22:	734080e7          	jalr	1844(ra) # 752 <fprintf>
     exit(0);
  26:	4501                	li	a0,0
  28:	00000097          	auipc	ra,0x0
  2c:	398080e7          	jalr	920(ra) # 3c0 <exit>
  30:	84ae                	mv	s1,a1
  }

  m = atoi(argv[1]);
  32:	6588                	ld	a0,8(a1)
  34:	00000097          	auipc	ra,0x0
  38:	28c080e7          	jalr	652(ra) # 2c0 <atoi>
  3c:	892a                	mv	s2,a0
  if (m <= 0) {
  3e:	02a05b63          	blez	a0,74 <main+0x74>
     fprintf(2, "Invalid input\nAborting...\n");
     exit(0);
  }
  n = atoi(argv[2]);
  42:	6888                	ld	a0,16(s1)
  44:	00000097          	auipc	ra,0x0
  48:	27c080e7          	jalr	636(ra) # 2c0 <atoi>
  4c:	84aa                	mv	s1,a0
  if ((n != 0) && (n != 1)) {
  4e:	0005071b          	sext.w	a4,a0
  52:	4785                	li	a5,1
  54:	02e7fe63          	bgeu	a5,a4,90 <main+0x90>
     fprintf(2, "Invalid input\nAborting...\n");
  58:	00001597          	auipc	a1,0x1
  5c:	8f858593          	addi	a1,a1,-1800 # 950 <malloc+0x112>
  60:	4509                	li	a0,2
  62:	00000097          	auipc	ra,0x0
  66:	6f0080e7          	jalr	1776(ra) # 752 <fprintf>
     exit(0);
  6a:	4501                	li	a0,0
  6c:	00000097          	auipc	ra,0x0
  70:	354080e7          	jalr	852(ra) # 3c0 <exit>
     fprintf(2, "Invalid input\nAborting...\n");
  74:	00001597          	auipc	a1,0x1
  78:	8dc58593          	addi	a1,a1,-1828 # 950 <malloc+0x112>
  7c:	4509                	li	a0,2
  7e:	00000097          	auipc	ra,0x0
  82:	6d4080e7          	jalr	1748(ra) # 752 <fprintf>
     exit(0);
  86:	4501                	li	a0,0
  88:	00000097          	auipc	ra,0x0
  8c:	338080e7          	jalr	824(ra) # 3c0 <exit>
  }

  x = fork();
  90:	00000097          	auipc	ra,0x0
  94:	328080e7          	jalr	808(ra) # 3b8 <fork>
  98:	89aa                	mv	s3,a0
  if (x < 0) {
  9a:	04054863          	bltz	a0,ea <main+0xea>
     fprintf(2, "Error: cannot fork\nAborting...\n");
     exit(0);
  }
  else if (x > 0) {
  9e:	06a05a63          	blez	a0,112 <main+0x112>
     if (n) sleep(m);
  a2:	e0b5                	bnez	s1,106 <main+0x106>
     fprintf(1, "%d: Parent.\n", getpid());
  a4:	00000097          	auipc	ra,0x0
  a8:	39c080e7          	jalr	924(ra) # 440 <getpid>
  ac:	862a                	mv	a2,a0
  ae:	00001597          	auipc	a1,0x1
  b2:	8e258593          	addi	a1,a1,-1822 # 990 <malloc+0x152>
  b6:	4505                	li	a0,1
  b8:	00000097          	auipc	ra,0x0
  bc:	69a080e7          	jalr	1690(ra) # 752 <fprintf>
     fprintf(1, "Return value of waitpid=%d\n", waitpid(x, 0));
  c0:	4581                	li	a1,0
  c2:	854e                	mv	a0,s3
  c4:	00000097          	auipc	ra,0x0
  c8:	3bc080e7          	jalr	956(ra) # 480 <waitpid>
  cc:	862a                	mv	a2,a0
  ce:	00001597          	auipc	a1,0x1
  d2:	8d258593          	addi	a1,a1,-1838 # 9a0 <malloc+0x162>
  d6:	4505                	li	a0,1
  d8:	00000097          	auipc	ra,0x0
  dc:	67a080e7          	jalr	1658(ra) # 752 <fprintf>
  else {
     if (!n) sleep(m);
     fprintf(1, "%d: Child with parent %d.\n", getpid(), getppid());
  }

  exit(0);
  e0:	4501                	li	a0,0
  e2:	00000097          	auipc	ra,0x0
  e6:	2de080e7          	jalr	734(ra) # 3c0 <exit>
     fprintf(2, "Error: cannot fork\nAborting...\n");
  ea:	00001597          	auipc	a1,0x1
  ee:	88658593          	addi	a1,a1,-1914 # 970 <malloc+0x132>
  f2:	4509                	li	a0,2
  f4:	00000097          	auipc	ra,0x0
  f8:	65e080e7          	jalr	1630(ra) # 752 <fprintf>
     exit(0);
  fc:	4501                	li	a0,0
  fe:	00000097          	auipc	ra,0x0
 102:	2c2080e7          	jalr	706(ra) # 3c0 <exit>
     if (n) sleep(m);
 106:	854a                	mv	a0,s2
 108:	00000097          	auipc	ra,0x0
 10c:	348080e7          	jalr	840(ra) # 450 <sleep>
 110:	bf51                	j	a4 <main+0xa4>
     if (!n) sleep(m);
 112:	c495                	beqz	s1,13e <main+0x13e>
     fprintf(1, "%d: Child with parent %d.\n", getpid(), getppid());
 114:	00000097          	auipc	ra,0x0
 118:	32c080e7          	jalr	812(ra) # 440 <getpid>
 11c:	84aa                	mv	s1,a0
 11e:	00000097          	auipc	ra,0x0
 122:	342080e7          	jalr	834(ra) # 460 <getppid>
 126:	86aa                	mv	a3,a0
 128:	8626                	mv	a2,s1
 12a:	00001597          	auipc	a1,0x1
 12e:	89658593          	addi	a1,a1,-1898 # 9c0 <malloc+0x182>
 132:	4505                	li	a0,1
 134:	00000097          	auipc	ra,0x0
 138:	61e080e7          	jalr	1566(ra) # 752 <fprintf>
 13c:	b755                	j	e0 <main+0xe0>
     if (!n) sleep(m);
 13e:	854a                	mv	a0,s2
 140:	00000097          	auipc	ra,0x0
 144:	310080e7          	jalr	784(ra) # 450 <sleep>
 148:	b7f1                	j	114 <main+0x114>

000000000000014a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e422                	sd	s0,8(sp)
 14e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 150:	87aa                	mv	a5,a0
 152:	0585                	addi	a1,a1,1
 154:	0785                	addi	a5,a5,1
 156:	fff5c703          	lbu	a4,-1(a1)
 15a:	fee78fa3          	sb	a4,-1(a5)
 15e:	fb75                	bnez	a4,152 <strcpy+0x8>
    ;
  return os;
}
 160:	6422                	ld	s0,8(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret

0000000000000166 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 166:	1141                	addi	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 16c:	00054783          	lbu	a5,0(a0)
 170:	cb91                	beqz	a5,184 <strcmp+0x1e>
 172:	0005c703          	lbu	a4,0(a1)
 176:	00f71763          	bne	a4,a5,184 <strcmp+0x1e>
    p++, q++;
 17a:	0505                	addi	a0,a0,1
 17c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 17e:	00054783          	lbu	a5,0(a0)
 182:	fbe5                	bnez	a5,172 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 184:	0005c503          	lbu	a0,0(a1)
}
 188:	40a7853b          	subw	a0,a5,a0
 18c:	6422                	ld	s0,8(sp)
 18e:	0141                	addi	sp,sp,16
 190:	8082                	ret

0000000000000192 <strlen>:

uint
strlen(const char *s)
{
 192:	1141                	addi	sp,sp,-16
 194:	e422                	sd	s0,8(sp)
 196:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 198:	00054783          	lbu	a5,0(a0)
 19c:	cf91                	beqz	a5,1b8 <strlen+0x26>
 19e:	0505                	addi	a0,a0,1
 1a0:	87aa                	mv	a5,a0
 1a2:	4685                	li	a3,1
 1a4:	9e89                	subw	a3,a3,a0
 1a6:	00f6853b          	addw	a0,a3,a5
 1aa:	0785                	addi	a5,a5,1
 1ac:	fff7c703          	lbu	a4,-1(a5)
 1b0:	fb7d                	bnez	a4,1a6 <strlen+0x14>
    ;
  return n;
}
 1b2:	6422                	ld	s0,8(sp)
 1b4:	0141                	addi	sp,sp,16
 1b6:	8082                	ret
  for(n = 0; s[n]; n++)
 1b8:	4501                	li	a0,0
 1ba:	bfe5                	j	1b2 <strlen+0x20>

00000000000001bc <memset>:

void*
memset(void *dst, int c, uint n)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e422                	sd	s0,8(sp)
 1c0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1c2:	ce09                	beqz	a2,1dc <memset+0x20>
 1c4:	87aa                	mv	a5,a0
 1c6:	fff6071b          	addiw	a4,a2,-1
 1ca:	1702                	slli	a4,a4,0x20
 1cc:	9301                	srli	a4,a4,0x20
 1ce:	0705                	addi	a4,a4,1
 1d0:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1d2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1d6:	0785                	addi	a5,a5,1
 1d8:	fee79de3          	bne	a5,a4,1d2 <memset+0x16>
  }
  return dst;
}
 1dc:	6422                	ld	s0,8(sp)
 1de:	0141                	addi	sp,sp,16
 1e0:	8082                	ret

00000000000001e2 <strchr>:

char*
strchr(const char *s, char c)
{
 1e2:	1141                	addi	sp,sp,-16
 1e4:	e422                	sd	s0,8(sp)
 1e6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1e8:	00054783          	lbu	a5,0(a0)
 1ec:	cb99                	beqz	a5,202 <strchr+0x20>
    if(*s == c)
 1ee:	00f58763          	beq	a1,a5,1fc <strchr+0x1a>
  for(; *s; s++)
 1f2:	0505                	addi	a0,a0,1
 1f4:	00054783          	lbu	a5,0(a0)
 1f8:	fbfd                	bnez	a5,1ee <strchr+0xc>
      return (char*)s;
  return 0;
 1fa:	4501                	li	a0,0
}
 1fc:	6422                	ld	s0,8(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret
  return 0;
 202:	4501                	li	a0,0
 204:	bfe5                	j	1fc <strchr+0x1a>

0000000000000206 <gets>:

char*
gets(char *buf, int max)
{
 206:	711d                	addi	sp,sp,-96
 208:	ec86                	sd	ra,88(sp)
 20a:	e8a2                	sd	s0,80(sp)
 20c:	e4a6                	sd	s1,72(sp)
 20e:	e0ca                	sd	s2,64(sp)
 210:	fc4e                	sd	s3,56(sp)
 212:	f852                	sd	s4,48(sp)
 214:	f456                	sd	s5,40(sp)
 216:	f05a                	sd	s6,32(sp)
 218:	ec5e                	sd	s7,24(sp)
 21a:	1080                	addi	s0,sp,96
 21c:	8baa                	mv	s7,a0
 21e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 220:	892a                	mv	s2,a0
 222:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 224:	4aa9                	li	s5,10
 226:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 228:	89a6                	mv	s3,s1
 22a:	2485                	addiw	s1,s1,1
 22c:	0344d863          	bge	s1,s4,25c <gets+0x56>
    cc = read(0, &c, 1);
 230:	4605                	li	a2,1
 232:	faf40593          	addi	a1,s0,-81
 236:	4501                	li	a0,0
 238:	00000097          	auipc	ra,0x0
 23c:	1a0080e7          	jalr	416(ra) # 3d8 <read>
    if(cc < 1)
 240:	00a05e63          	blez	a0,25c <gets+0x56>
    buf[i++] = c;
 244:	faf44783          	lbu	a5,-81(s0)
 248:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 24c:	01578763          	beq	a5,s5,25a <gets+0x54>
 250:	0905                	addi	s2,s2,1
 252:	fd679be3          	bne	a5,s6,228 <gets+0x22>
  for(i=0; i+1 < max; ){
 256:	89a6                	mv	s3,s1
 258:	a011                	j	25c <gets+0x56>
 25a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 25c:	99de                	add	s3,s3,s7
 25e:	00098023          	sb	zero,0(s3)
  return buf;
}
 262:	855e                	mv	a0,s7
 264:	60e6                	ld	ra,88(sp)
 266:	6446                	ld	s0,80(sp)
 268:	64a6                	ld	s1,72(sp)
 26a:	6906                	ld	s2,64(sp)
 26c:	79e2                	ld	s3,56(sp)
 26e:	7a42                	ld	s4,48(sp)
 270:	7aa2                	ld	s5,40(sp)
 272:	7b02                	ld	s6,32(sp)
 274:	6be2                	ld	s7,24(sp)
 276:	6125                	addi	sp,sp,96
 278:	8082                	ret

000000000000027a <stat>:

int
stat(const char *n, struct stat *st)
{
 27a:	1101                	addi	sp,sp,-32
 27c:	ec06                	sd	ra,24(sp)
 27e:	e822                	sd	s0,16(sp)
 280:	e426                	sd	s1,8(sp)
 282:	e04a                	sd	s2,0(sp)
 284:	1000                	addi	s0,sp,32
 286:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 288:	4581                	li	a1,0
 28a:	00000097          	auipc	ra,0x0
 28e:	176080e7          	jalr	374(ra) # 400 <open>
  if(fd < 0)
 292:	02054563          	bltz	a0,2bc <stat+0x42>
 296:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 298:	85ca                	mv	a1,s2
 29a:	00000097          	auipc	ra,0x0
 29e:	17e080e7          	jalr	382(ra) # 418 <fstat>
 2a2:	892a                	mv	s2,a0
  close(fd);
 2a4:	8526                	mv	a0,s1
 2a6:	00000097          	auipc	ra,0x0
 2aa:	142080e7          	jalr	322(ra) # 3e8 <close>
  return r;
}
 2ae:	854a                	mv	a0,s2
 2b0:	60e2                	ld	ra,24(sp)
 2b2:	6442                	ld	s0,16(sp)
 2b4:	64a2                	ld	s1,8(sp)
 2b6:	6902                	ld	s2,0(sp)
 2b8:	6105                	addi	sp,sp,32
 2ba:	8082                	ret
    return -1;
 2bc:	597d                	li	s2,-1
 2be:	bfc5                	j	2ae <stat+0x34>

00000000000002c0 <atoi>:

int
atoi(const char *s)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c6:	00054603          	lbu	a2,0(a0)
 2ca:	fd06079b          	addiw	a5,a2,-48
 2ce:	0ff7f793          	andi	a5,a5,255
 2d2:	4725                	li	a4,9
 2d4:	02f76963          	bltu	a4,a5,306 <atoi+0x46>
 2d8:	86aa                	mv	a3,a0
  n = 0;
 2da:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2dc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2de:	0685                	addi	a3,a3,1
 2e0:	0025179b          	slliw	a5,a0,0x2
 2e4:	9fa9                	addw	a5,a5,a0
 2e6:	0017979b          	slliw	a5,a5,0x1
 2ea:	9fb1                	addw	a5,a5,a2
 2ec:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2f0:	0006c603          	lbu	a2,0(a3)
 2f4:	fd06071b          	addiw	a4,a2,-48
 2f8:	0ff77713          	andi	a4,a4,255
 2fc:	fee5f1e3          	bgeu	a1,a4,2de <atoi+0x1e>
  return n;
}
 300:	6422                	ld	s0,8(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret
  n = 0;
 306:	4501                	li	a0,0
 308:	bfe5                	j	300 <atoi+0x40>

000000000000030a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 30a:	1141                	addi	sp,sp,-16
 30c:	e422                	sd	s0,8(sp)
 30e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 310:	02b57663          	bgeu	a0,a1,33c <memmove+0x32>
    while(n-- > 0)
 314:	02c05163          	blez	a2,336 <memmove+0x2c>
 318:	fff6079b          	addiw	a5,a2,-1
 31c:	1782                	slli	a5,a5,0x20
 31e:	9381                	srli	a5,a5,0x20
 320:	0785                	addi	a5,a5,1
 322:	97aa                	add	a5,a5,a0
  dst = vdst;
 324:	872a                	mv	a4,a0
      *dst++ = *src++;
 326:	0585                	addi	a1,a1,1
 328:	0705                	addi	a4,a4,1
 32a:	fff5c683          	lbu	a3,-1(a1)
 32e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 332:	fee79ae3          	bne	a5,a4,326 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 336:	6422                	ld	s0,8(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret
    dst += n;
 33c:	00c50733          	add	a4,a0,a2
    src += n;
 340:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 342:	fec05ae3          	blez	a2,336 <memmove+0x2c>
 346:	fff6079b          	addiw	a5,a2,-1
 34a:	1782                	slli	a5,a5,0x20
 34c:	9381                	srli	a5,a5,0x20
 34e:	fff7c793          	not	a5,a5
 352:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 354:	15fd                	addi	a1,a1,-1
 356:	177d                	addi	a4,a4,-1
 358:	0005c683          	lbu	a3,0(a1)
 35c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 360:	fee79ae3          	bne	a5,a4,354 <memmove+0x4a>
 364:	bfc9                	j	336 <memmove+0x2c>

0000000000000366 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 366:	1141                	addi	sp,sp,-16
 368:	e422                	sd	s0,8(sp)
 36a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 36c:	ca05                	beqz	a2,39c <memcmp+0x36>
 36e:	fff6069b          	addiw	a3,a2,-1
 372:	1682                	slli	a3,a3,0x20
 374:	9281                	srli	a3,a3,0x20
 376:	0685                	addi	a3,a3,1
 378:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 37a:	00054783          	lbu	a5,0(a0)
 37e:	0005c703          	lbu	a4,0(a1)
 382:	00e79863          	bne	a5,a4,392 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 386:	0505                	addi	a0,a0,1
    p2++;
 388:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 38a:	fed518e3          	bne	a0,a3,37a <memcmp+0x14>
  }
  return 0;
 38e:	4501                	li	a0,0
 390:	a019                	j	396 <memcmp+0x30>
      return *p1 - *p2;
 392:	40e7853b          	subw	a0,a5,a4
}
 396:	6422                	ld	s0,8(sp)
 398:	0141                	addi	sp,sp,16
 39a:	8082                	ret
  return 0;
 39c:	4501                	li	a0,0
 39e:	bfe5                	j	396 <memcmp+0x30>

00000000000003a0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a0:	1141                	addi	sp,sp,-16
 3a2:	e406                	sd	ra,8(sp)
 3a4:	e022                	sd	s0,0(sp)
 3a6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3a8:	00000097          	auipc	ra,0x0
 3ac:	f62080e7          	jalr	-158(ra) # 30a <memmove>
}
 3b0:	60a2                	ld	ra,8(sp)
 3b2:	6402                	ld	s0,0(sp)
 3b4:	0141                	addi	sp,sp,16
 3b6:	8082                	ret

00000000000003b8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3b8:	4885                	li	a7,1
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3c0:	4889                	li	a7,2
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3c8:	488d                	li	a7,3
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3d0:	4891                	li	a7,4
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <read>:
.global read
read:
 li a7, SYS_read
 3d8:	4895                	li	a7,5
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <write>:
.global write
write:
 li a7, SYS_write
 3e0:	48c1                	li	a7,16
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <close>:
.global close
close:
 li a7, SYS_close
 3e8:	48d5                	li	a7,21
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3f0:	4899                	li	a7,6
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3f8:	489d                	li	a7,7
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <open>:
.global open
open:
 li a7, SYS_open
 400:	48bd                	li	a7,15
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 408:	48c5                	li	a7,17
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 410:	48c9                	li	a7,18
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 418:	48a1                	li	a7,8
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <link>:
.global link
link:
 li a7, SYS_link
 420:	48cd                	li	a7,19
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 428:	48d1                	li	a7,20
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 430:	48a5                	li	a7,9
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <dup>:
.global dup
dup:
 li a7, SYS_dup
 438:	48a9                	li	a7,10
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 440:	48ad                	li	a7,11
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 448:	48b1                	li	a7,12
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 450:	48b5                	li	a7,13
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 458:	48b9                	li	a7,14
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 460:	48d9                	li	a7,22
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <yield>:
.global yield
yield:
 li a7, SYS_yield
 468:	48dd                	li	a7,23
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 470:	48e1                	li	a7,24
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 478:	48e5                	li	a7,25
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 480:	48e9                	li	a7,26
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <ps>:
.global ps
ps:
 li a7, SYS_ps
 488:	48ed                	li	a7,27
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 490:	48f1                	li	a7,28
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 498:	48f5                	li	a7,29
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 4a0:	48f9                	li	a7,30
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4a8:	1101                	addi	sp,sp,-32
 4aa:	ec06                	sd	ra,24(sp)
 4ac:	e822                	sd	s0,16(sp)
 4ae:	1000                	addi	s0,sp,32
 4b0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4b4:	4605                	li	a2,1
 4b6:	fef40593          	addi	a1,s0,-17
 4ba:	00000097          	auipc	ra,0x0
 4be:	f26080e7          	jalr	-218(ra) # 3e0 <write>
}
 4c2:	60e2                	ld	ra,24(sp)
 4c4:	6442                	ld	s0,16(sp)
 4c6:	6105                	addi	sp,sp,32
 4c8:	8082                	ret

00000000000004ca <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ca:	7139                	addi	sp,sp,-64
 4cc:	fc06                	sd	ra,56(sp)
 4ce:	f822                	sd	s0,48(sp)
 4d0:	f426                	sd	s1,40(sp)
 4d2:	f04a                	sd	s2,32(sp)
 4d4:	ec4e                	sd	s3,24(sp)
 4d6:	0080                	addi	s0,sp,64
 4d8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4da:	c299                	beqz	a3,4e0 <printint+0x16>
 4dc:	0805c863          	bltz	a1,56c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4e0:	2581                	sext.w	a1,a1
  neg = 0;
 4e2:	4881                	li	a7,0
 4e4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4e8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4ea:	2601                	sext.w	a2,a2
 4ec:	00000517          	auipc	a0,0x0
 4f0:	4fc50513          	addi	a0,a0,1276 # 9e8 <digits>
 4f4:	883a                	mv	a6,a4
 4f6:	2705                	addiw	a4,a4,1
 4f8:	02c5f7bb          	remuw	a5,a1,a2
 4fc:	1782                	slli	a5,a5,0x20
 4fe:	9381                	srli	a5,a5,0x20
 500:	97aa                	add	a5,a5,a0
 502:	0007c783          	lbu	a5,0(a5)
 506:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 50a:	0005879b          	sext.w	a5,a1
 50e:	02c5d5bb          	divuw	a1,a1,a2
 512:	0685                	addi	a3,a3,1
 514:	fec7f0e3          	bgeu	a5,a2,4f4 <printint+0x2a>
  if(neg)
 518:	00088b63          	beqz	a7,52e <printint+0x64>
    buf[i++] = '-';
 51c:	fd040793          	addi	a5,s0,-48
 520:	973e                	add	a4,a4,a5
 522:	02d00793          	li	a5,45
 526:	fef70823          	sb	a5,-16(a4)
 52a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 52e:	02e05863          	blez	a4,55e <printint+0x94>
 532:	fc040793          	addi	a5,s0,-64
 536:	00e78933          	add	s2,a5,a4
 53a:	fff78993          	addi	s3,a5,-1
 53e:	99ba                	add	s3,s3,a4
 540:	377d                	addiw	a4,a4,-1
 542:	1702                	slli	a4,a4,0x20
 544:	9301                	srli	a4,a4,0x20
 546:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 54a:	fff94583          	lbu	a1,-1(s2)
 54e:	8526                	mv	a0,s1
 550:	00000097          	auipc	ra,0x0
 554:	f58080e7          	jalr	-168(ra) # 4a8 <putc>
  while(--i >= 0)
 558:	197d                	addi	s2,s2,-1
 55a:	ff3918e3          	bne	s2,s3,54a <printint+0x80>
}
 55e:	70e2                	ld	ra,56(sp)
 560:	7442                	ld	s0,48(sp)
 562:	74a2                	ld	s1,40(sp)
 564:	7902                	ld	s2,32(sp)
 566:	69e2                	ld	s3,24(sp)
 568:	6121                	addi	sp,sp,64
 56a:	8082                	ret
    x = -xx;
 56c:	40b005bb          	negw	a1,a1
    neg = 1;
 570:	4885                	li	a7,1
    x = -xx;
 572:	bf8d                	j	4e4 <printint+0x1a>

0000000000000574 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 574:	7119                	addi	sp,sp,-128
 576:	fc86                	sd	ra,120(sp)
 578:	f8a2                	sd	s0,112(sp)
 57a:	f4a6                	sd	s1,104(sp)
 57c:	f0ca                	sd	s2,96(sp)
 57e:	ecce                	sd	s3,88(sp)
 580:	e8d2                	sd	s4,80(sp)
 582:	e4d6                	sd	s5,72(sp)
 584:	e0da                	sd	s6,64(sp)
 586:	fc5e                	sd	s7,56(sp)
 588:	f862                	sd	s8,48(sp)
 58a:	f466                	sd	s9,40(sp)
 58c:	f06a                	sd	s10,32(sp)
 58e:	ec6e                	sd	s11,24(sp)
 590:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 592:	0005c903          	lbu	s2,0(a1)
 596:	18090f63          	beqz	s2,734 <vprintf+0x1c0>
 59a:	8aaa                	mv	s5,a0
 59c:	8b32                	mv	s6,a2
 59e:	00158493          	addi	s1,a1,1
  state = 0;
 5a2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5a4:	02500a13          	li	s4,37
      if(c == 'd'){
 5a8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5ac:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5b0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5b4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5b8:	00000b97          	auipc	s7,0x0
 5bc:	430b8b93          	addi	s7,s7,1072 # 9e8 <digits>
 5c0:	a839                	j	5de <vprintf+0x6a>
        putc(fd, c);
 5c2:	85ca                	mv	a1,s2
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	ee2080e7          	jalr	-286(ra) # 4a8 <putc>
 5ce:	a019                	j	5d4 <vprintf+0x60>
    } else if(state == '%'){
 5d0:	01498f63          	beq	s3,s4,5ee <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5d4:	0485                	addi	s1,s1,1
 5d6:	fff4c903          	lbu	s2,-1(s1)
 5da:	14090d63          	beqz	s2,734 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5de:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5e2:	fe0997e3          	bnez	s3,5d0 <vprintf+0x5c>
      if(c == '%'){
 5e6:	fd479ee3          	bne	a5,s4,5c2 <vprintf+0x4e>
        state = '%';
 5ea:	89be                	mv	s3,a5
 5ec:	b7e5                	j	5d4 <vprintf+0x60>
      if(c == 'd'){
 5ee:	05878063          	beq	a5,s8,62e <vprintf+0xba>
      } else if(c == 'l') {
 5f2:	05978c63          	beq	a5,s9,64a <vprintf+0xd6>
      } else if(c == 'x') {
 5f6:	07a78863          	beq	a5,s10,666 <vprintf+0xf2>
      } else if(c == 'p') {
 5fa:	09b78463          	beq	a5,s11,682 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5fe:	07300713          	li	a4,115
 602:	0ce78663          	beq	a5,a4,6ce <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 606:	06300713          	li	a4,99
 60a:	0ee78e63          	beq	a5,a4,706 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 60e:	11478863          	beq	a5,s4,71e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 612:	85d2                	mv	a1,s4
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	e92080e7          	jalr	-366(ra) # 4a8 <putc>
        putc(fd, c);
 61e:	85ca                	mv	a1,s2
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	e86080e7          	jalr	-378(ra) # 4a8 <putc>
      }
      state = 0;
 62a:	4981                	li	s3,0
 62c:	b765                	j	5d4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 62e:	008b0913          	addi	s2,s6,8
 632:	4685                	li	a3,1
 634:	4629                	li	a2,10
 636:	000b2583          	lw	a1,0(s6)
 63a:	8556                	mv	a0,s5
 63c:	00000097          	auipc	ra,0x0
 640:	e8e080e7          	jalr	-370(ra) # 4ca <printint>
 644:	8b4a                	mv	s6,s2
      state = 0;
 646:	4981                	li	s3,0
 648:	b771                	j	5d4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 64a:	008b0913          	addi	s2,s6,8
 64e:	4681                	li	a3,0
 650:	4629                	li	a2,10
 652:	000b2583          	lw	a1,0(s6)
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	e72080e7          	jalr	-398(ra) # 4ca <printint>
 660:	8b4a                	mv	s6,s2
      state = 0;
 662:	4981                	li	s3,0
 664:	bf85                	j	5d4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 666:	008b0913          	addi	s2,s6,8
 66a:	4681                	li	a3,0
 66c:	4641                	li	a2,16
 66e:	000b2583          	lw	a1,0(s6)
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	e56080e7          	jalr	-426(ra) # 4ca <printint>
 67c:	8b4a                	mv	s6,s2
      state = 0;
 67e:	4981                	li	s3,0
 680:	bf91                	j	5d4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 682:	008b0793          	addi	a5,s6,8
 686:	f8f43423          	sd	a5,-120(s0)
 68a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 68e:	03000593          	li	a1,48
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	e14080e7          	jalr	-492(ra) # 4a8 <putc>
  putc(fd, 'x');
 69c:	85ea                	mv	a1,s10
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	e08080e7          	jalr	-504(ra) # 4a8 <putc>
 6a8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6aa:	03c9d793          	srli	a5,s3,0x3c
 6ae:	97de                	add	a5,a5,s7
 6b0:	0007c583          	lbu	a1,0(a5)
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	df2080e7          	jalr	-526(ra) # 4a8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6be:	0992                	slli	s3,s3,0x4
 6c0:	397d                	addiw	s2,s2,-1
 6c2:	fe0914e3          	bnez	s2,6aa <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6c6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	b721                	j	5d4 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ce:	008b0993          	addi	s3,s6,8
 6d2:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6d6:	02090163          	beqz	s2,6f8 <vprintf+0x184>
        while(*s != 0){
 6da:	00094583          	lbu	a1,0(s2)
 6de:	c9a1                	beqz	a1,72e <vprintf+0x1ba>
          putc(fd, *s);
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	dc6080e7          	jalr	-570(ra) # 4a8 <putc>
          s++;
 6ea:	0905                	addi	s2,s2,1
        while(*s != 0){
 6ec:	00094583          	lbu	a1,0(s2)
 6f0:	f9e5                	bnez	a1,6e0 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6f2:	8b4e                	mv	s6,s3
      state = 0;
 6f4:	4981                	li	s3,0
 6f6:	bdf9                	j	5d4 <vprintf+0x60>
          s = "(null)";
 6f8:	00000917          	auipc	s2,0x0
 6fc:	2e890913          	addi	s2,s2,744 # 9e0 <malloc+0x1a2>
        while(*s != 0){
 700:	02800593          	li	a1,40
 704:	bff1                	j	6e0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 706:	008b0913          	addi	s2,s6,8
 70a:	000b4583          	lbu	a1,0(s6)
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	d98080e7          	jalr	-616(ra) # 4a8 <putc>
 718:	8b4a                	mv	s6,s2
      state = 0;
 71a:	4981                	li	s3,0
 71c:	bd65                	j	5d4 <vprintf+0x60>
        putc(fd, c);
 71e:	85d2                	mv	a1,s4
 720:	8556                	mv	a0,s5
 722:	00000097          	auipc	ra,0x0
 726:	d86080e7          	jalr	-634(ra) # 4a8 <putc>
      state = 0;
 72a:	4981                	li	s3,0
 72c:	b565                	j	5d4 <vprintf+0x60>
        s = va_arg(ap, char*);
 72e:	8b4e                	mv	s6,s3
      state = 0;
 730:	4981                	li	s3,0
 732:	b54d                	j	5d4 <vprintf+0x60>
    }
  }
}
 734:	70e6                	ld	ra,120(sp)
 736:	7446                	ld	s0,112(sp)
 738:	74a6                	ld	s1,104(sp)
 73a:	7906                	ld	s2,96(sp)
 73c:	69e6                	ld	s3,88(sp)
 73e:	6a46                	ld	s4,80(sp)
 740:	6aa6                	ld	s5,72(sp)
 742:	6b06                	ld	s6,64(sp)
 744:	7be2                	ld	s7,56(sp)
 746:	7c42                	ld	s8,48(sp)
 748:	7ca2                	ld	s9,40(sp)
 74a:	7d02                	ld	s10,32(sp)
 74c:	6de2                	ld	s11,24(sp)
 74e:	6109                	addi	sp,sp,128
 750:	8082                	ret

0000000000000752 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 752:	715d                	addi	sp,sp,-80
 754:	ec06                	sd	ra,24(sp)
 756:	e822                	sd	s0,16(sp)
 758:	1000                	addi	s0,sp,32
 75a:	e010                	sd	a2,0(s0)
 75c:	e414                	sd	a3,8(s0)
 75e:	e818                	sd	a4,16(s0)
 760:	ec1c                	sd	a5,24(s0)
 762:	03043023          	sd	a6,32(s0)
 766:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 76a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 76e:	8622                	mv	a2,s0
 770:	00000097          	auipc	ra,0x0
 774:	e04080e7          	jalr	-508(ra) # 574 <vprintf>
}
 778:	60e2                	ld	ra,24(sp)
 77a:	6442                	ld	s0,16(sp)
 77c:	6161                	addi	sp,sp,80
 77e:	8082                	ret

0000000000000780 <printf>:

void
printf(const char *fmt, ...)
{
 780:	711d                	addi	sp,sp,-96
 782:	ec06                	sd	ra,24(sp)
 784:	e822                	sd	s0,16(sp)
 786:	1000                	addi	s0,sp,32
 788:	e40c                	sd	a1,8(s0)
 78a:	e810                	sd	a2,16(s0)
 78c:	ec14                	sd	a3,24(s0)
 78e:	f018                	sd	a4,32(s0)
 790:	f41c                	sd	a5,40(s0)
 792:	03043823          	sd	a6,48(s0)
 796:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 79a:	00840613          	addi	a2,s0,8
 79e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7a2:	85aa                	mv	a1,a0
 7a4:	4505                	li	a0,1
 7a6:	00000097          	auipc	ra,0x0
 7aa:	dce080e7          	jalr	-562(ra) # 574 <vprintf>
}
 7ae:	60e2                	ld	ra,24(sp)
 7b0:	6442                	ld	s0,16(sp)
 7b2:	6125                	addi	sp,sp,96
 7b4:	8082                	ret

00000000000007b6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b6:	1141                	addi	sp,sp,-16
 7b8:	e422                	sd	s0,8(sp)
 7ba:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7bc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c0:	00000797          	auipc	a5,0x0
 7c4:	2407b783          	ld	a5,576(a5) # a00 <freep>
 7c8:	a805                	j	7f8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ca:	4618                	lw	a4,8(a2)
 7cc:	9db9                	addw	a1,a1,a4
 7ce:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d2:	6398                	ld	a4,0(a5)
 7d4:	6318                	ld	a4,0(a4)
 7d6:	fee53823          	sd	a4,-16(a0)
 7da:	a091                	j	81e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7dc:	ff852703          	lw	a4,-8(a0)
 7e0:	9e39                	addw	a2,a2,a4
 7e2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7e4:	ff053703          	ld	a4,-16(a0)
 7e8:	e398                	sd	a4,0(a5)
 7ea:	a099                	j	830 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ec:	6398                	ld	a4,0(a5)
 7ee:	00e7e463          	bltu	a5,a4,7f6 <free+0x40>
 7f2:	00e6ea63          	bltu	a3,a4,806 <free+0x50>
{
 7f6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f8:	fed7fae3          	bgeu	a5,a3,7ec <free+0x36>
 7fc:	6398                	ld	a4,0(a5)
 7fe:	00e6e463          	bltu	a3,a4,806 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 802:	fee7eae3          	bltu	a5,a4,7f6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 806:	ff852583          	lw	a1,-8(a0)
 80a:	6390                	ld	a2,0(a5)
 80c:	02059713          	slli	a4,a1,0x20
 810:	9301                	srli	a4,a4,0x20
 812:	0712                	slli	a4,a4,0x4
 814:	9736                	add	a4,a4,a3
 816:	fae60ae3          	beq	a2,a4,7ca <free+0x14>
    bp->s.ptr = p->s.ptr;
 81a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 81e:	4790                	lw	a2,8(a5)
 820:	02061713          	slli	a4,a2,0x20
 824:	9301                	srli	a4,a4,0x20
 826:	0712                	slli	a4,a4,0x4
 828:	973e                	add	a4,a4,a5
 82a:	fae689e3          	beq	a3,a4,7dc <free+0x26>
  } else
    p->s.ptr = bp;
 82e:	e394                	sd	a3,0(a5)
  freep = p;
 830:	00000717          	auipc	a4,0x0
 834:	1cf73823          	sd	a5,464(a4) # a00 <freep>
}
 838:	6422                	ld	s0,8(sp)
 83a:	0141                	addi	sp,sp,16
 83c:	8082                	ret

000000000000083e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 83e:	7139                	addi	sp,sp,-64
 840:	fc06                	sd	ra,56(sp)
 842:	f822                	sd	s0,48(sp)
 844:	f426                	sd	s1,40(sp)
 846:	f04a                	sd	s2,32(sp)
 848:	ec4e                	sd	s3,24(sp)
 84a:	e852                	sd	s4,16(sp)
 84c:	e456                	sd	s5,8(sp)
 84e:	e05a                	sd	s6,0(sp)
 850:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 852:	02051493          	slli	s1,a0,0x20
 856:	9081                	srli	s1,s1,0x20
 858:	04bd                	addi	s1,s1,15
 85a:	8091                	srli	s1,s1,0x4
 85c:	0014899b          	addiw	s3,s1,1
 860:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 862:	00000517          	auipc	a0,0x0
 866:	19e53503          	ld	a0,414(a0) # a00 <freep>
 86a:	c515                	beqz	a0,896 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 86e:	4798                	lw	a4,8(a5)
 870:	02977f63          	bgeu	a4,s1,8ae <malloc+0x70>
 874:	8a4e                	mv	s4,s3
 876:	0009871b          	sext.w	a4,s3
 87a:	6685                	lui	a3,0x1
 87c:	00d77363          	bgeu	a4,a3,882 <malloc+0x44>
 880:	6a05                	lui	s4,0x1
 882:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 886:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 88a:	00000917          	auipc	s2,0x0
 88e:	17690913          	addi	s2,s2,374 # a00 <freep>
  if(p == (char*)-1)
 892:	5afd                	li	s5,-1
 894:	a88d                	j	906 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 896:	00000797          	auipc	a5,0x0
 89a:	17278793          	addi	a5,a5,370 # a08 <base>
 89e:	00000717          	auipc	a4,0x0
 8a2:	16f73123          	sd	a5,354(a4) # a00 <freep>
 8a6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8a8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ac:	b7e1                	j	874 <malloc+0x36>
      if(p->s.size == nunits)
 8ae:	02e48b63          	beq	s1,a4,8e4 <malloc+0xa6>
        p->s.size -= nunits;
 8b2:	4137073b          	subw	a4,a4,s3
 8b6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8b8:	1702                	slli	a4,a4,0x20
 8ba:	9301                	srli	a4,a4,0x20
 8bc:	0712                	slli	a4,a4,0x4
 8be:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8c4:	00000717          	auipc	a4,0x0
 8c8:	12a73e23          	sd	a0,316(a4) # a00 <freep>
      return (void*)(p + 1);
 8cc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8d0:	70e2                	ld	ra,56(sp)
 8d2:	7442                	ld	s0,48(sp)
 8d4:	74a2                	ld	s1,40(sp)
 8d6:	7902                	ld	s2,32(sp)
 8d8:	69e2                	ld	s3,24(sp)
 8da:	6a42                	ld	s4,16(sp)
 8dc:	6aa2                	ld	s5,8(sp)
 8de:	6b02                	ld	s6,0(sp)
 8e0:	6121                	addi	sp,sp,64
 8e2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8e4:	6398                	ld	a4,0(a5)
 8e6:	e118                	sd	a4,0(a0)
 8e8:	bff1                	j	8c4 <malloc+0x86>
  hp->s.size = nu;
 8ea:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ee:	0541                	addi	a0,a0,16
 8f0:	00000097          	auipc	ra,0x0
 8f4:	ec6080e7          	jalr	-314(ra) # 7b6 <free>
  return freep;
 8f8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8fc:	d971                	beqz	a0,8d0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 900:	4798                	lw	a4,8(a5)
 902:	fa9776e3          	bgeu	a4,s1,8ae <malloc+0x70>
    if(p == freep)
 906:	00093703          	ld	a4,0(s2)
 90a:	853e                	mv	a0,a5
 90c:	fef719e3          	bne	a4,a5,8fe <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 910:	8552                	mv	a0,s4
 912:	00000097          	auipc	ra,0x0
 916:	b36080e7          	jalr	-1226(ra) # 448 <sbrk>
  if(p == (char*)-1)
 91a:	fd5518e3          	bne	a0,s5,8ea <malloc+0xac>
        return 0;
 91e:	4501                	li	a0,0
 920:	bf45                	j	8d0 <malloc+0x92>
