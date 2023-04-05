
user/_submitjobs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	716d                	addi	sp,sp,-272
   2:	e606                	sd	ra,264(sp)
   4:	e222                	sd	s0,256(sp)
   6:	fda6                	sd	s1,248(sp)
   8:	f9ca                	sd	s2,240(sp)
   a:	f5ce                	sd	s3,232(sp)
   c:	f1d2                	sd	s4,224(sp)
   e:	edd6                	sd	s5,216(sp)
  10:	e9da                	sd	s6,208(sp)
  12:	e5de                	sd	s7,200(sp)
  14:	e1e2                	sd	s8,192(sp)
  16:	fd66                	sd	s9,184(sp)
  18:	f96a                	sd	s10,176(sp)
  1a:	f56e                	sd	s11,168(sp)
  1c:	0a00                	addi	s0,sp,272
  char buf[128], prio[4], policy[2];
  char **args;
  int i, j, k;

  args = (char**)malloc(sizeof(char*)*16);
  1e:	08000513          	li	a0,128
  22:	00001097          	auipc	ra,0x1
  26:	84a080e7          	jalr	-1974(ra) # 86c <malloc>
  2a:	8daa                	mv	s11,a0
  for (i=0; i<16; i++) args[i] = 0;
  2c:	eea43c23          	sd	a0,-264(s0)
  30:	08050713          	addi	a4,a0,128
  args = (char**)malloc(sizeof(char*)*16);
  34:	87aa                	mv	a5,a0
  for (i=0; i<16; i++) args[i] = 0;
  36:	0007b023          	sd	zero,0(a5)
  3a:	07a1                	addi	a5,a5,8
  3c:	fee79de3          	bne	a5,a4,36 <main+0x36>

  gets(buf, sizeof(buf));
  40:	08000593          	li	a1,128
  44:	f1040513          	addi	a0,s0,-240
  48:	00000097          	auipc	ra,0x0
  4c:	1ec080e7          	jalr	492(ra) # 234 <gets>
  policy[0] = buf[0];
  50:	f1044783          	lbu	a5,-240(s0)
  54:	f0f40023          	sb	a5,-256(s0)
  policy[1] = '\0';
  58:	f00400a3          	sb	zero,-255(s0)
  schedpolicy(atoi((const char*)policy));
  5c:	f0040513          	addi	a0,s0,-256
  60:	00000097          	auipc	ra,0x0
  64:	28e080e7          	jalr	654(ra) # 2ee <atoi>
  68:	00000097          	auipc	ra,0x0
  6c:	466080e7          	jalr	1126(ra) # 4ce <schedpolicy>
  while (1) {
     gets(buf, sizeof(buf));
  70:	f1040b13          	addi	s6,s0,-240
     if(buf[0] == 0) break;
     i=0;
     while (buf[i] != ' ') {
  74:	02000a13          	li	s4,32
  78:	4c05                	li	s8,1
  7a:	416c0c3b          	subw	s8,s8,s6
     k=0;
     while (1) {
	i++;
        j=0;
	if (!args[k]) args[k] = (char*)malloc(sizeof(char)*32);
        while ((buf[i] != ' ') && (buf[i] != '\n')) {
  7e:	8cd2                	mv	s9,s4
  80:	4aa9                	li	s5,10
  82:	a861                	j	11a <main+0x11a>
     i=0;
  84:	4901                	li	s2,0
  86:	a0d9                	j	14c <main+0x14c>
	if (!args[k]) args[k] = (char*)malloc(sizeof(char)*32);
  88:	8566                	mv	a0,s9
  8a:	00000097          	auipc	ra,0x0
  8e:	7e2080e7          	jalr	2018(ra) # 86c <malloc>
  92:	00abb023          	sd	a0,0(s7)
  96:	a805                	j	c6 <main+0xc6>
        while ((buf[i] != ' ') && (buf[i] != '\n')) {
  98:	8926                	mv	s2,s1
  9a:	86ea                	mv	a3,s10
  9c:	a011                	j	a0 <main+0xa0>
  9e:	8926                	mv	s2,s1
           args[k][j] = buf[i];
           i++;
	   j++;
        }
        args[k][j] = '\0';
  a0:	0009b783          	ld	a5,0(s3)
  a4:	96be                	add	a3,a3,a5
  a6:	00068023          	sb	zero,0(a3)
	if (buf[i] == '\n') {
  aa:	0ba1                	addi	s7,s7,8
  ac:	f9040793          	addi	a5,s0,-112
  b0:	97ca                	add	a5,a5,s2
  b2:	f807c783          	lbu	a5,-128(a5)
  b6:	05578763          	beq	a5,s5,104 <main+0x104>
	i++;
  ba:	0019049b          	addiw	s1,s2,1
	if (!args[k]) args[k] = (char*)malloc(sizeof(char)*32);
  be:	89de                	mv	s3,s7
  c0:	000bb783          	ld	a5,0(s7)
  c4:	d3f1                	beqz	a5,88 <main+0x88>
        while ((buf[i] != ' ') && (buf[i] != '\n')) {
  c6:	f9040793          	addi	a5,s0,-112
  ca:	97a6                	add	a5,a5,s1
  cc:	f807c703          	lbu	a4,-128(a5)
  d0:	4781                	li	a5,0
  d2:	fd4703e3          	beq	a4,s4,98 <main+0x98>
  d6:	0007861b          	sext.w	a2,a5
  da:	86b2                	mv	a3,a2
  dc:	fd5701e3          	beq	a4,s5,9e <main+0x9e>
           args[k][j] = buf[i];
  e0:	0009b683          	ld	a3,0(s3)
  e4:	96be                	add	a3,a3,a5
  e6:	00e68023          	sb	a4,0(a3)
           i++;
  ea:	2485                	addiw	s1,s1,1
	   j++;
  ec:	0016069b          	addiw	a3,a2,1
        while ((buf[i] != ' ') && (buf[i] != '\n')) {
  f0:	0785                	addi	a5,a5,1
  f2:	00f90733          	add	a4,s2,a5
  f6:	975a                	add	a4,a4,s6
  f8:	00174703          	lbu	a4,1(a4)
  fc:	fd471de3          	bne	a4,s4,d6 <main+0xd6>
           i++;
 100:	8926                	mv	s2,s1
 102:	bf79                	j	a0 <main+0xa0>
	   break;
	}
	k++;
     }
     if (forkp(atoi((const char*)prio)) == 0) exec(args[0], args);
 104:	f0840513          	addi	a0,s0,-248
 108:	00000097          	auipc	ra,0x0
 10c:	1e6080e7          	jalr	486(ra) # 2ee <atoi>
 110:	00000097          	auipc	ra,0x0
 114:	3b6080e7          	jalr	950(ra) # 4c6 <forkp>
 118:	c139                	beqz	a0,15e <main+0x15e>
     gets(buf, sizeof(buf));
 11a:	08000593          	li	a1,128
 11e:	855a                	mv	a0,s6
 120:	00000097          	auipc	ra,0x0
 124:	114080e7          	jalr	276(ra) # 234 <gets>
     if(buf[0] == 0) break;
 128:	f1044703          	lbu	a4,-240(s0)
 12c:	c329                	beqz	a4,16e <main+0x16e>
     while (buf[i] != ' ') {
 12e:	f5470be3          	beq	a4,s4,84 <main+0x84>
 132:	f0840693          	addi	a3,s0,-248
 136:	87da                	mv	a5,s6
        prio[i] = buf[i];
 138:	00e68023          	sb	a4,0(a3)
	i++;
 13c:	00fc093b          	addw	s2,s8,a5
     while (buf[i] != ' ') {
 140:	0017c703          	lbu	a4,1(a5)
 144:	0685                	addi	a3,a3,1
 146:	0785                	addi	a5,a5,1
 148:	ff4718e3          	bne	a4,s4,138 <main+0x138>
     prio[i] = '\0';
 14c:	f9040793          	addi	a5,s0,-112
 150:	97ca                	add	a5,a5,s2
 152:	f6078c23          	sb	zero,-136(a5)
 156:	ef843b83          	ld	s7,-264(s0)
        while ((buf[i] != ' ') && (buf[i] != '\n')) {
 15a:	4d01                	li	s10,0
 15c:	bfb9                	j	ba <main+0xba>
     if (forkp(atoi((const char*)prio)) == 0) exec(args[0], args);
 15e:	85ee                	mv	a1,s11
 160:	000db503          	ld	a0,0(s11)
 164:	00000097          	auipc	ra,0x0
 168:	2c2080e7          	jalr	706(ra) # 426 <exec>
 16c:	bf11                	j	80 <main+0x80>
  }

  exit(0);
 16e:	4501                	li	a0,0
 170:	00000097          	auipc	ra,0x0
 174:	27e080e7          	jalr	638(ra) # 3ee <exit>

0000000000000178 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 178:	1141                	addi	sp,sp,-16
 17a:	e422                	sd	s0,8(sp)
 17c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 17e:	87aa                	mv	a5,a0
 180:	0585                	addi	a1,a1,1
 182:	0785                	addi	a5,a5,1
 184:	fff5c703          	lbu	a4,-1(a1)
 188:	fee78fa3          	sb	a4,-1(a5)
 18c:	fb75                	bnez	a4,180 <strcpy+0x8>
    ;
  return os;
}
 18e:	6422                	ld	s0,8(sp)
 190:	0141                	addi	sp,sp,16
 192:	8082                	ret

0000000000000194 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 194:	1141                	addi	sp,sp,-16
 196:	e422                	sd	s0,8(sp)
 198:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 19a:	00054783          	lbu	a5,0(a0)
 19e:	cb91                	beqz	a5,1b2 <strcmp+0x1e>
 1a0:	0005c703          	lbu	a4,0(a1)
 1a4:	00f71763          	bne	a4,a5,1b2 <strcmp+0x1e>
    p++, q++;
 1a8:	0505                	addi	a0,a0,1
 1aa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ac:	00054783          	lbu	a5,0(a0)
 1b0:	fbe5                	bnez	a5,1a0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1b2:	0005c503          	lbu	a0,0(a1)
}
 1b6:	40a7853b          	subw	a0,a5,a0
 1ba:	6422                	ld	s0,8(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret

00000000000001c0 <strlen>:

uint
strlen(const char *s)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e422                	sd	s0,8(sp)
 1c4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1c6:	00054783          	lbu	a5,0(a0)
 1ca:	cf91                	beqz	a5,1e6 <strlen+0x26>
 1cc:	0505                	addi	a0,a0,1
 1ce:	87aa                	mv	a5,a0
 1d0:	4685                	li	a3,1
 1d2:	9e89                	subw	a3,a3,a0
 1d4:	00f6853b          	addw	a0,a3,a5
 1d8:	0785                	addi	a5,a5,1
 1da:	fff7c703          	lbu	a4,-1(a5)
 1de:	fb7d                	bnez	a4,1d4 <strlen+0x14>
    ;
  return n;
}
 1e0:	6422                	ld	s0,8(sp)
 1e2:	0141                	addi	sp,sp,16
 1e4:	8082                	ret
  for(n = 0; s[n]; n++)
 1e6:	4501                	li	a0,0
 1e8:	bfe5                	j	1e0 <strlen+0x20>

00000000000001ea <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1f0:	ce09                	beqz	a2,20a <memset+0x20>
 1f2:	87aa                	mv	a5,a0
 1f4:	fff6071b          	addiw	a4,a2,-1
 1f8:	1702                	slli	a4,a4,0x20
 1fa:	9301                	srli	a4,a4,0x20
 1fc:	0705                	addi	a4,a4,1
 1fe:	972a                	add	a4,a4,a0
    cdst[i] = c;
 200:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 204:	0785                	addi	a5,a5,1
 206:	fee79de3          	bne	a5,a4,200 <memset+0x16>
  }
  return dst;
}
 20a:	6422                	ld	s0,8(sp)
 20c:	0141                	addi	sp,sp,16
 20e:	8082                	ret

0000000000000210 <strchr>:

char*
strchr(const char *s, char c)
{
 210:	1141                	addi	sp,sp,-16
 212:	e422                	sd	s0,8(sp)
 214:	0800                	addi	s0,sp,16
  for(; *s; s++)
 216:	00054783          	lbu	a5,0(a0)
 21a:	cb99                	beqz	a5,230 <strchr+0x20>
    if(*s == c)
 21c:	00f58763          	beq	a1,a5,22a <strchr+0x1a>
  for(; *s; s++)
 220:	0505                	addi	a0,a0,1
 222:	00054783          	lbu	a5,0(a0)
 226:	fbfd                	bnez	a5,21c <strchr+0xc>
      return (char*)s;
  return 0;
 228:	4501                	li	a0,0
}
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret
  return 0;
 230:	4501                	li	a0,0
 232:	bfe5                	j	22a <strchr+0x1a>

0000000000000234 <gets>:

char*
gets(char *buf, int max)
{
 234:	711d                	addi	sp,sp,-96
 236:	ec86                	sd	ra,88(sp)
 238:	e8a2                	sd	s0,80(sp)
 23a:	e4a6                	sd	s1,72(sp)
 23c:	e0ca                	sd	s2,64(sp)
 23e:	fc4e                	sd	s3,56(sp)
 240:	f852                	sd	s4,48(sp)
 242:	f456                	sd	s5,40(sp)
 244:	f05a                	sd	s6,32(sp)
 246:	ec5e                	sd	s7,24(sp)
 248:	1080                	addi	s0,sp,96
 24a:	8baa                	mv	s7,a0
 24c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 24e:	892a                	mv	s2,a0
 250:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 252:	4aa9                	li	s5,10
 254:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 256:	89a6                	mv	s3,s1
 258:	2485                	addiw	s1,s1,1
 25a:	0344d863          	bge	s1,s4,28a <gets+0x56>
    cc = read(0, &c, 1);
 25e:	4605                	li	a2,1
 260:	faf40593          	addi	a1,s0,-81
 264:	4501                	li	a0,0
 266:	00000097          	auipc	ra,0x0
 26a:	1a0080e7          	jalr	416(ra) # 406 <read>
    if(cc < 1)
 26e:	00a05e63          	blez	a0,28a <gets+0x56>
    buf[i++] = c;
 272:	faf44783          	lbu	a5,-81(s0)
 276:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27a:	01578763          	beq	a5,s5,288 <gets+0x54>
 27e:	0905                	addi	s2,s2,1
 280:	fd679be3          	bne	a5,s6,256 <gets+0x22>
  for(i=0; i+1 < max; ){
 284:	89a6                	mv	s3,s1
 286:	a011                	j	28a <gets+0x56>
 288:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 28a:	99de                	add	s3,s3,s7
 28c:	00098023          	sb	zero,0(s3)
  return buf;
}
 290:	855e                	mv	a0,s7
 292:	60e6                	ld	ra,88(sp)
 294:	6446                	ld	s0,80(sp)
 296:	64a6                	ld	s1,72(sp)
 298:	6906                	ld	s2,64(sp)
 29a:	79e2                	ld	s3,56(sp)
 29c:	7a42                	ld	s4,48(sp)
 29e:	7aa2                	ld	s5,40(sp)
 2a0:	7b02                	ld	s6,32(sp)
 2a2:	6be2                	ld	s7,24(sp)
 2a4:	6125                	addi	sp,sp,96
 2a6:	8082                	ret

00000000000002a8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a8:	1101                	addi	sp,sp,-32
 2aa:	ec06                	sd	ra,24(sp)
 2ac:	e822                	sd	s0,16(sp)
 2ae:	e426                	sd	s1,8(sp)
 2b0:	e04a                	sd	s2,0(sp)
 2b2:	1000                	addi	s0,sp,32
 2b4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b6:	4581                	li	a1,0
 2b8:	00000097          	auipc	ra,0x0
 2bc:	176080e7          	jalr	374(ra) # 42e <open>
  if(fd < 0)
 2c0:	02054563          	bltz	a0,2ea <stat+0x42>
 2c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c6:	85ca                	mv	a1,s2
 2c8:	00000097          	auipc	ra,0x0
 2cc:	17e080e7          	jalr	382(ra) # 446 <fstat>
 2d0:	892a                	mv	s2,a0
  close(fd);
 2d2:	8526                	mv	a0,s1
 2d4:	00000097          	auipc	ra,0x0
 2d8:	142080e7          	jalr	322(ra) # 416 <close>
  return r;
}
 2dc:	854a                	mv	a0,s2
 2de:	60e2                	ld	ra,24(sp)
 2e0:	6442                	ld	s0,16(sp)
 2e2:	64a2                	ld	s1,8(sp)
 2e4:	6902                	ld	s2,0(sp)
 2e6:	6105                	addi	sp,sp,32
 2e8:	8082                	ret
    return -1;
 2ea:	597d                	li	s2,-1
 2ec:	bfc5                	j	2dc <stat+0x34>

00000000000002ee <atoi>:

int
atoi(const char *s)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f4:	00054603          	lbu	a2,0(a0)
 2f8:	fd06079b          	addiw	a5,a2,-48
 2fc:	0ff7f793          	andi	a5,a5,255
 300:	4725                	li	a4,9
 302:	02f76963          	bltu	a4,a5,334 <atoi+0x46>
 306:	86aa                	mv	a3,a0
  n = 0;
 308:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 30a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 30c:	0685                	addi	a3,a3,1
 30e:	0025179b          	slliw	a5,a0,0x2
 312:	9fa9                	addw	a5,a5,a0
 314:	0017979b          	slliw	a5,a5,0x1
 318:	9fb1                	addw	a5,a5,a2
 31a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 31e:	0006c603          	lbu	a2,0(a3)
 322:	fd06071b          	addiw	a4,a2,-48
 326:	0ff77713          	andi	a4,a4,255
 32a:	fee5f1e3          	bgeu	a1,a4,30c <atoi+0x1e>
  return n;
}
 32e:	6422                	ld	s0,8(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret
  n = 0;
 334:	4501                	li	a0,0
 336:	bfe5                	j	32e <atoi+0x40>

0000000000000338 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 338:	1141                	addi	sp,sp,-16
 33a:	e422                	sd	s0,8(sp)
 33c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 33e:	02b57663          	bgeu	a0,a1,36a <memmove+0x32>
    while(n-- > 0)
 342:	02c05163          	blez	a2,364 <memmove+0x2c>
 346:	fff6079b          	addiw	a5,a2,-1
 34a:	1782                	slli	a5,a5,0x20
 34c:	9381                	srli	a5,a5,0x20
 34e:	0785                	addi	a5,a5,1
 350:	97aa                	add	a5,a5,a0
  dst = vdst;
 352:	872a                	mv	a4,a0
      *dst++ = *src++;
 354:	0585                	addi	a1,a1,1
 356:	0705                	addi	a4,a4,1
 358:	fff5c683          	lbu	a3,-1(a1)
 35c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 360:	fee79ae3          	bne	a5,a4,354 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 364:	6422                	ld	s0,8(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret
    dst += n;
 36a:	00c50733          	add	a4,a0,a2
    src += n;
 36e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 370:	fec05ae3          	blez	a2,364 <memmove+0x2c>
 374:	fff6079b          	addiw	a5,a2,-1
 378:	1782                	slli	a5,a5,0x20
 37a:	9381                	srli	a5,a5,0x20
 37c:	fff7c793          	not	a5,a5
 380:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 382:	15fd                	addi	a1,a1,-1
 384:	177d                	addi	a4,a4,-1
 386:	0005c683          	lbu	a3,0(a1)
 38a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 38e:	fee79ae3          	bne	a5,a4,382 <memmove+0x4a>
 392:	bfc9                	j	364 <memmove+0x2c>

0000000000000394 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 394:	1141                	addi	sp,sp,-16
 396:	e422                	sd	s0,8(sp)
 398:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 39a:	ca05                	beqz	a2,3ca <memcmp+0x36>
 39c:	fff6069b          	addiw	a3,a2,-1
 3a0:	1682                	slli	a3,a3,0x20
 3a2:	9281                	srli	a3,a3,0x20
 3a4:	0685                	addi	a3,a3,1
 3a6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3a8:	00054783          	lbu	a5,0(a0)
 3ac:	0005c703          	lbu	a4,0(a1)
 3b0:	00e79863          	bne	a5,a4,3c0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3b4:	0505                	addi	a0,a0,1
    p2++;
 3b6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b8:	fed518e3          	bne	a0,a3,3a8 <memcmp+0x14>
  }
  return 0;
 3bc:	4501                	li	a0,0
 3be:	a019                	j	3c4 <memcmp+0x30>
      return *p1 - *p2;
 3c0:	40e7853b          	subw	a0,a5,a4
}
 3c4:	6422                	ld	s0,8(sp)
 3c6:	0141                	addi	sp,sp,16
 3c8:	8082                	ret
  return 0;
 3ca:	4501                	li	a0,0
 3cc:	bfe5                	j	3c4 <memcmp+0x30>

00000000000003ce <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ce:	1141                	addi	sp,sp,-16
 3d0:	e406                	sd	ra,8(sp)
 3d2:	e022                	sd	s0,0(sp)
 3d4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3d6:	00000097          	auipc	ra,0x0
 3da:	f62080e7          	jalr	-158(ra) # 338 <memmove>
}
 3de:	60a2                	ld	ra,8(sp)
 3e0:	6402                	ld	s0,0(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret

00000000000003e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3e6:	4885                	li	a7,1
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ee:	4889                	li	a7,2
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3f6:	488d                	li	a7,3
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3fe:	4891                	li	a7,4
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <read>:
.global read
read:
 li a7, SYS_read
 406:	4895                	li	a7,5
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <write>:
.global write
write:
 li a7, SYS_write
 40e:	48c1                	li	a7,16
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <close>:
.global close
close:
 li a7, SYS_close
 416:	48d5                	li	a7,21
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <kill>:
.global kill
kill:
 li a7, SYS_kill
 41e:	4899                	li	a7,6
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <exec>:
.global exec
exec:
 li a7, SYS_exec
 426:	489d                	li	a7,7
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <open>:
.global open
open:
 li a7, SYS_open
 42e:	48bd                	li	a7,15
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 436:	48c5                	li	a7,17
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 43e:	48c9                	li	a7,18
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 446:	48a1                	li	a7,8
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <link>:
.global link
link:
 li a7, SYS_link
 44e:	48cd                	li	a7,19
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 456:	48d1                	li	a7,20
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 45e:	48a5                	li	a7,9
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <dup>:
.global dup
dup:
 li a7, SYS_dup
 466:	48a9                	li	a7,10
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 46e:	48ad                	li	a7,11
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 476:	48b1                	li	a7,12
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 47e:	48b5                	li	a7,13
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 486:	48b9                	li	a7,14
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 48e:	48d9                	li	a7,22
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <yield>:
.global yield
yield:
 li a7, SYS_yield
 496:	48dd                	li	a7,23
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 49e:	48e1                	li	a7,24
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 4a6:	48e5                	li	a7,25
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 4ae:	48e9                	li	a7,26
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <ps>:
.global ps
ps:
 li a7, SYS_ps
 4b6:	48ed                	li	a7,27
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 4be:	48f1                	li	a7,28
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 4c6:	48f5                	li	a7,29
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 4ce:	48f9                	li	a7,30
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4d6:	1101                	addi	sp,sp,-32
 4d8:	ec06                	sd	ra,24(sp)
 4da:	e822                	sd	s0,16(sp)
 4dc:	1000                	addi	s0,sp,32
 4de:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4e2:	4605                	li	a2,1
 4e4:	fef40593          	addi	a1,s0,-17
 4e8:	00000097          	auipc	ra,0x0
 4ec:	f26080e7          	jalr	-218(ra) # 40e <write>
}
 4f0:	60e2                	ld	ra,24(sp)
 4f2:	6442                	ld	s0,16(sp)
 4f4:	6105                	addi	sp,sp,32
 4f6:	8082                	ret

00000000000004f8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f8:	7139                	addi	sp,sp,-64
 4fa:	fc06                	sd	ra,56(sp)
 4fc:	f822                	sd	s0,48(sp)
 4fe:	f426                	sd	s1,40(sp)
 500:	f04a                	sd	s2,32(sp)
 502:	ec4e                	sd	s3,24(sp)
 504:	0080                	addi	s0,sp,64
 506:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 508:	c299                	beqz	a3,50e <printint+0x16>
 50a:	0805c863          	bltz	a1,59a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 50e:	2581                	sext.w	a1,a1
  neg = 0;
 510:	4881                	li	a7,0
 512:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 516:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 518:	2601                	sext.w	a2,a2
 51a:	00000517          	auipc	a0,0x0
 51e:	43e50513          	addi	a0,a0,1086 # 958 <digits>
 522:	883a                	mv	a6,a4
 524:	2705                	addiw	a4,a4,1
 526:	02c5f7bb          	remuw	a5,a1,a2
 52a:	1782                	slli	a5,a5,0x20
 52c:	9381                	srli	a5,a5,0x20
 52e:	97aa                	add	a5,a5,a0
 530:	0007c783          	lbu	a5,0(a5)
 534:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 538:	0005879b          	sext.w	a5,a1
 53c:	02c5d5bb          	divuw	a1,a1,a2
 540:	0685                	addi	a3,a3,1
 542:	fec7f0e3          	bgeu	a5,a2,522 <printint+0x2a>
  if(neg)
 546:	00088b63          	beqz	a7,55c <printint+0x64>
    buf[i++] = '-';
 54a:	fd040793          	addi	a5,s0,-48
 54e:	973e                	add	a4,a4,a5
 550:	02d00793          	li	a5,45
 554:	fef70823          	sb	a5,-16(a4)
 558:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 55c:	02e05863          	blez	a4,58c <printint+0x94>
 560:	fc040793          	addi	a5,s0,-64
 564:	00e78933          	add	s2,a5,a4
 568:	fff78993          	addi	s3,a5,-1
 56c:	99ba                	add	s3,s3,a4
 56e:	377d                	addiw	a4,a4,-1
 570:	1702                	slli	a4,a4,0x20
 572:	9301                	srli	a4,a4,0x20
 574:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 578:	fff94583          	lbu	a1,-1(s2)
 57c:	8526                	mv	a0,s1
 57e:	00000097          	auipc	ra,0x0
 582:	f58080e7          	jalr	-168(ra) # 4d6 <putc>
  while(--i >= 0)
 586:	197d                	addi	s2,s2,-1
 588:	ff3918e3          	bne	s2,s3,578 <printint+0x80>
}
 58c:	70e2                	ld	ra,56(sp)
 58e:	7442                	ld	s0,48(sp)
 590:	74a2                	ld	s1,40(sp)
 592:	7902                	ld	s2,32(sp)
 594:	69e2                	ld	s3,24(sp)
 596:	6121                	addi	sp,sp,64
 598:	8082                	ret
    x = -xx;
 59a:	40b005bb          	negw	a1,a1
    neg = 1;
 59e:	4885                	li	a7,1
    x = -xx;
 5a0:	bf8d                	j	512 <printint+0x1a>

00000000000005a2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5a2:	7119                	addi	sp,sp,-128
 5a4:	fc86                	sd	ra,120(sp)
 5a6:	f8a2                	sd	s0,112(sp)
 5a8:	f4a6                	sd	s1,104(sp)
 5aa:	f0ca                	sd	s2,96(sp)
 5ac:	ecce                	sd	s3,88(sp)
 5ae:	e8d2                	sd	s4,80(sp)
 5b0:	e4d6                	sd	s5,72(sp)
 5b2:	e0da                	sd	s6,64(sp)
 5b4:	fc5e                	sd	s7,56(sp)
 5b6:	f862                	sd	s8,48(sp)
 5b8:	f466                	sd	s9,40(sp)
 5ba:	f06a                	sd	s10,32(sp)
 5bc:	ec6e                	sd	s11,24(sp)
 5be:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5c0:	0005c903          	lbu	s2,0(a1)
 5c4:	18090f63          	beqz	s2,762 <vprintf+0x1c0>
 5c8:	8aaa                	mv	s5,a0
 5ca:	8b32                	mv	s6,a2
 5cc:	00158493          	addi	s1,a1,1
  state = 0;
 5d0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5d2:	02500a13          	li	s4,37
      if(c == 'd'){
 5d6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5da:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5de:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5e2:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5e6:	00000b97          	auipc	s7,0x0
 5ea:	372b8b93          	addi	s7,s7,882 # 958 <digits>
 5ee:	a839                	j	60c <vprintf+0x6a>
        putc(fd, c);
 5f0:	85ca                	mv	a1,s2
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	ee2080e7          	jalr	-286(ra) # 4d6 <putc>
 5fc:	a019                	j	602 <vprintf+0x60>
    } else if(state == '%'){
 5fe:	01498f63          	beq	s3,s4,61c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 602:	0485                	addi	s1,s1,1
 604:	fff4c903          	lbu	s2,-1(s1)
 608:	14090d63          	beqz	s2,762 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 60c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 610:	fe0997e3          	bnez	s3,5fe <vprintf+0x5c>
      if(c == '%'){
 614:	fd479ee3          	bne	a5,s4,5f0 <vprintf+0x4e>
        state = '%';
 618:	89be                	mv	s3,a5
 61a:	b7e5                	j	602 <vprintf+0x60>
      if(c == 'd'){
 61c:	05878063          	beq	a5,s8,65c <vprintf+0xba>
      } else if(c == 'l') {
 620:	05978c63          	beq	a5,s9,678 <vprintf+0xd6>
      } else if(c == 'x') {
 624:	07a78863          	beq	a5,s10,694 <vprintf+0xf2>
      } else if(c == 'p') {
 628:	09b78463          	beq	a5,s11,6b0 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 62c:	07300713          	li	a4,115
 630:	0ce78663          	beq	a5,a4,6fc <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 634:	06300713          	li	a4,99
 638:	0ee78e63          	beq	a5,a4,734 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 63c:	11478863          	beq	a5,s4,74c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 640:	85d2                	mv	a1,s4
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	e92080e7          	jalr	-366(ra) # 4d6 <putc>
        putc(fd, c);
 64c:	85ca                	mv	a1,s2
 64e:	8556                	mv	a0,s5
 650:	00000097          	auipc	ra,0x0
 654:	e86080e7          	jalr	-378(ra) # 4d6 <putc>
      }
      state = 0;
 658:	4981                	li	s3,0
 65a:	b765                	j	602 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 65c:	008b0913          	addi	s2,s6,8
 660:	4685                	li	a3,1
 662:	4629                	li	a2,10
 664:	000b2583          	lw	a1,0(s6)
 668:	8556                	mv	a0,s5
 66a:	00000097          	auipc	ra,0x0
 66e:	e8e080e7          	jalr	-370(ra) # 4f8 <printint>
 672:	8b4a                	mv	s6,s2
      state = 0;
 674:	4981                	li	s3,0
 676:	b771                	j	602 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 678:	008b0913          	addi	s2,s6,8
 67c:	4681                	li	a3,0
 67e:	4629                	li	a2,10
 680:	000b2583          	lw	a1,0(s6)
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	e72080e7          	jalr	-398(ra) # 4f8 <printint>
 68e:	8b4a                	mv	s6,s2
      state = 0;
 690:	4981                	li	s3,0
 692:	bf85                	j	602 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 694:	008b0913          	addi	s2,s6,8
 698:	4681                	li	a3,0
 69a:	4641                	li	a2,16
 69c:	000b2583          	lw	a1,0(s6)
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	e56080e7          	jalr	-426(ra) # 4f8 <printint>
 6aa:	8b4a                	mv	s6,s2
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	bf91                	j	602 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6b0:	008b0793          	addi	a5,s6,8
 6b4:	f8f43423          	sd	a5,-120(s0)
 6b8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6bc:	03000593          	li	a1,48
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	e14080e7          	jalr	-492(ra) # 4d6 <putc>
  putc(fd, 'x');
 6ca:	85ea                	mv	a1,s10
 6cc:	8556                	mv	a0,s5
 6ce:	00000097          	auipc	ra,0x0
 6d2:	e08080e7          	jalr	-504(ra) # 4d6 <putc>
 6d6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6d8:	03c9d793          	srli	a5,s3,0x3c
 6dc:	97de                	add	a5,a5,s7
 6de:	0007c583          	lbu	a1,0(a5)
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	df2080e7          	jalr	-526(ra) # 4d6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ec:	0992                	slli	s3,s3,0x4
 6ee:	397d                	addiw	s2,s2,-1
 6f0:	fe0914e3          	bnez	s2,6d8 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6f4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	b721                	j	602 <vprintf+0x60>
        s = va_arg(ap, char*);
 6fc:	008b0993          	addi	s3,s6,8
 700:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 704:	02090163          	beqz	s2,726 <vprintf+0x184>
        while(*s != 0){
 708:	00094583          	lbu	a1,0(s2)
 70c:	c9a1                	beqz	a1,75c <vprintf+0x1ba>
          putc(fd, *s);
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	dc6080e7          	jalr	-570(ra) # 4d6 <putc>
          s++;
 718:	0905                	addi	s2,s2,1
        while(*s != 0){
 71a:	00094583          	lbu	a1,0(s2)
 71e:	f9e5                	bnez	a1,70e <vprintf+0x16c>
        s = va_arg(ap, char*);
 720:	8b4e                	mv	s6,s3
      state = 0;
 722:	4981                	li	s3,0
 724:	bdf9                	j	602 <vprintf+0x60>
          s = "(null)";
 726:	00000917          	auipc	s2,0x0
 72a:	22a90913          	addi	s2,s2,554 # 950 <malloc+0xe4>
        while(*s != 0){
 72e:	02800593          	li	a1,40
 732:	bff1                	j	70e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 734:	008b0913          	addi	s2,s6,8
 738:	000b4583          	lbu	a1,0(s6)
 73c:	8556                	mv	a0,s5
 73e:	00000097          	auipc	ra,0x0
 742:	d98080e7          	jalr	-616(ra) # 4d6 <putc>
 746:	8b4a                	mv	s6,s2
      state = 0;
 748:	4981                	li	s3,0
 74a:	bd65                	j	602 <vprintf+0x60>
        putc(fd, c);
 74c:	85d2                	mv	a1,s4
 74e:	8556                	mv	a0,s5
 750:	00000097          	auipc	ra,0x0
 754:	d86080e7          	jalr	-634(ra) # 4d6 <putc>
      state = 0;
 758:	4981                	li	s3,0
 75a:	b565                	j	602 <vprintf+0x60>
        s = va_arg(ap, char*);
 75c:	8b4e                	mv	s6,s3
      state = 0;
 75e:	4981                	li	s3,0
 760:	b54d                	j	602 <vprintf+0x60>
    }
  }
}
 762:	70e6                	ld	ra,120(sp)
 764:	7446                	ld	s0,112(sp)
 766:	74a6                	ld	s1,104(sp)
 768:	7906                	ld	s2,96(sp)
 76a:	69e6                	ld	s3,88(sp)
 76c:	6a46                	ld	s4,80(sp)
 76e:	6aa6                	ld	s5,72(sp)
 770:	6b06                	ld	s6,64(sp)
 772:	7be2                	ld	s7,56(sp)
 774:	7c42                	ld	s8,48(sp)
 776:	7ca2                	ld	s9,40(sp)
 778:	7d02                	ld	s10,32(sp)
 77a:	6de2                	ld	s11,24(sp)
 77c:	6109                	addi	sp,sp,128
 77e:	8082                	ret

0000000000000780 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 780:	715d                	addi	sp,sp,-80
 782:	ec06                	sd	ra,24(sp)
 784:	e822                	sd	s0,16(sp)
 786:	1000                	addi	s0,sp,32
 788:	e010                	sd	a2,0(s0)
 78a:	e414                	sd	a3,8(s0)
 78c:	e818                	sd	a4,16(s0)
 78e:	ec1c                	sd	a5,24(s0)
 790:	03043023          	sd	a6,32(s0)
 794:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 798:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 79c:	8622                	mv	a2,s0
 79e:	00000097          	auipc	ra,0x0
 7a2:	e04080e7          	jalr	-508(ra) # 5a2 <vprintf>
}
 7a6:	60e2                	ld	ra,24(sp)
 7a8:	6442                	ld	s0,16(sp)
 7aa:	6161                	addi	sp,sp,80
 7ac:	8082                	ret

00000000000007ae <printf>:

void
printf(const char *fmt, ...)
{
 7ae:	711d                	addi	sp,sp,-96
 7b0:	ec06                	sd	ra,24(sp)
 7b2:	e822                	sd	s0,16(sp)
 7b4:	1000                	addi	s0,sp,32
 7b6:	e40c                	sd	a1,8(s0)
 7b8:	e810                	sd	a2,16(s0)
 7ba:	ec14                	sd	a3,24(s0)
 7bc:	f018                	sd	a4,32(s0)
 7be:	f41c                	sd	a5,40(s0)
 7c0:	03043823          	sd	a6,48(s0)
 7c4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7c8:	00840613          	addi	a2,s0,8
 7cc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d0:	85aa                	mv	a1,a0
 7d2:	4505                	li	a0,1
 7d4:	00000097          	auipc	ra,0x0
 7d8:	dce080e7          	jalr	-562(ra) # 5a2 <vprintf>
}
 7dc:	60e2                	ld	ra,24(sp)
 7de:	6442                	ld	s0,16(sp)
 7e0:	6125                	addi	sp,sp,96
 7e2:	8082                	ret

00000000000007e4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e4:	1141                	addi	sp,sp,-16
 7e6:	e422                	sd	s0,8(sp)
 7e8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ea:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ee:	00000797          	auipc	a5,0x0
 7f2:	1827b783          	ld	a5,386(a5) # 970 <freep>
 7f6:	a805                	j	826 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7f8:	4618                	lw	a4,8(a2)
 7fa:	9db9                	addw	a1,a1,a4
 7fc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 800:	6398                	ld	a4,0(a5)
 802:	6318                	ld	a4,0(a4)
 804:	fee53823          	sd	a4,-16(a0)
 808:	a091                	j	84c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 80a:	ff852703          	lw	a4,-8(a0)
 80e:	9e39                	addw	a2,a2,a4
 810:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 812:	ff053703          	ld	a4,-16(a0)
 816:	e398                	sd	a4,0(a5)
 818:	a099                	j	85e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81a:	6398                	ld	a4,0(a5)
 81c:	00e7e463          	bltu	a5,a4,824 <free+0x40>
 820:	00e6ea63          	bltu	a3,a4,834 <free+0x50>
{
 824:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 826:	fed7fae3          	bgeu	a5,a3,81a <free+0x36>
 82a:	6398                	ld	a4,0(a5)
 82c:	00e6e463          	bltu	a3,a4,834 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 830:	fee7eae3          	bltu	a5,a4,824 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 834:	ff852583          	lw	a1,-8(a0)
 838:	6390                	ld	a2,0(a5)
 83a:	02059713          	slli	a4,a1,0x20
 83e:	9301                	srli	a4,a4,0x20
 840:	0712                	slli	a4,a4,0x4
 842:	9736                	add	a4,a4,a3
 844:	fae60ae3          	beq	a2,a4,7f8 <free+0x14>
    bp->s.ptr = p->s.ptr;
 848:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 84c:	4790                	lw	a2,8(a5)
 84e:	02061713          	slli	a4,a2,0x20
 852:	9301                	srli	a4,a4,0x20
 854:	0712                	slli	a4,a4,0x4
 856:	973e                	add	a4,a4,a5
 858:	fae689e3          	beq	a3,a4,80a <free+0x26>
  } else
    p->s.ptr = bp;
 85c:	e394                	sd	a3,0(a5)
  freep = p;
 85e:	00000717          	auipc	a4,0x0
 862:	10f73923          	sd	a5,274(a4) # 970 <freep>
}
 866:	6422                	ld	s0,8(sp)
 868:	0141                	addi	sp,sp,16
 86a:	8082                	ret

000000000000086c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 86c:	7139                	addi	sp,sp,-64
 86e:	fc06                	sd	ra,56(sp)
 870:	f822                	sd	s0,48(sp)
 872:	f426                	sd	s1,40(sp)
 874:	f04a                	sd	s2,32(sp)
 876:	ec4e                	sd	s3,24(sp)
 878:	e852                	sd	s4,16(sp)
 87a:	e456                	sd	s5,8(sp)
 87c:	e05a                	sd	s6,0(sp)
 87e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 880:	02051493          	slli	s1,a0,0x20
 884:	9081                	srli	s1,s1,0x20
 886:	04bd                	addi	s1,s1,15
 888:	8091                	srli	s1,s1,0x4
 88a:	0014899b          	addiw	s3,s1,1
 88e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 890:	00000517          	auipc	a0,0x0
 894:	0e053503          	ld	a0,224(a0) # 970 <freep>
 898:	c515                	beqz	a0,8c4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 89c:	4798                	lw	a4,8(a5)
 89e:	02977f63          	bgeu	a4,s1,8dc <malloc+0x70>
 8a2:	8a4e                	mv	s4,s3
 8a4:	0009871b          	sext.w	a4,s3
 8a8:	6685                	lui	a3,0x1
 8aa:	00d77363          	bgeu	a4,a3,8b0 <malloc+0x44>
 8ae:	6a05                	lui	s4,0x1
 8b0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8b4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8b8:	00000917          	auipc	s2,0x0
 8bc:	0b890913          	addi	s2,s2,184 # 970 <freep>
  if(p == (char*)-1)
 8c0:	5afd                	li	s5,-1
 8c2:	a88d                	j	934 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8c4:	00000797          	auipc	a5,0x0
 8c8:	0b478793          	addi	a5,a5,180 # 978 <base>
 8cc:	00000717          	auipc	a4,0x0
 8d0:	0af73223          	sd	a5,164(a4) # 970 <freep>
 8d4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8da:	b7e1                	j	8a2 <malloc+0x36>
      if(p->s.size == nunits)
 8dc:	02e48b63          	beq	s1,a4,912 <malloc+0xa6>
        p->s.size -= nunits;
 8e0:	4137073b          	subw	a4,a4,s3
 8e4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8e6:	1702                	slli	a4,a4,0x20
 8e8:	9301                	srli	a4,a4,0x20
 8ea:	0712                	slli	a4,a4,0x4
 8ec:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ee:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8f2:	00000717          	auipc	a4,0x0
 8f6:	06a73f23          	sd	a0,126(a4) # 970 <freep>
      return (void*)(p + 1);
 8fa:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8fe:	70e2                	ld	ra,56(sp)
 900:	7442                	ld	s0,48(sp)
 902:	74a2                	ld	s1,40(sp)
 904:	7902                	ld	s2,32(sp)
 906:	69e2                	ld	s3,24(sp)
 908:	6a42                	ld	s4,16(sp)
 90a:	6aa2                	ld	s5,8(sp)
 90c:	6b02                	ld	s6,0(sp)
 90e:	6121                	addi	sp,sp,64
 910:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 912:	6398                	ld	a4,0(a5)
 914:	e118                	sd	a4,0(a0)
 916:	bff1                	j	8f2 <malloc+0x86>
  hp->s.size = nu;
 918:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 91c:	0541                	addi	a0,a0,16
 91e:	00000097          	auipc	ra,0x0
 922:	ec6080e7          	jalr	-314(ra) # 7e4 <free>
  return freep;
 926:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 92a:	d971                	beqz	a0,8fe <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 92e:	4798                	lw	a4,8(a5)
 930:	fa9776e3          	bgeu	a4,s1,8dc <malloc+0x70>
    if(p == freep)
 934:	00093703          	ld	a4,0(s2)
 938:	853e                	mv	a0,a5
 93a:	fef719e3          	bne	a4,a5,92c <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 93e:	8552                	mv	a0,s4
 940:	00000097          	auipc	ra,0x0
 944:	b36080e7          	jalr	-1226(ra) # 476 <sbrk>
  if(p == (char*)-1)
 948:	fd5518e3          	bne	a0,s5,918 <malloc+0xac>
        return 0;
 94c:	4501                	li	a0,0
 94e:	bf45                	j	8fe <malloc+0x92>
