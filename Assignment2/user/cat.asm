
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	95890913          	addi	s2,s2,-1704 # 968 <buf>
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	00000097          	auipc	ra,0x0
  24:	38c080e7          	jalr	908(ra) # 3ac <read>
  28:	84aa                	mv	s1,a0
  2a:	02a05963          	blez	a0,5c <cat+0x5c>
    if (write(1, buf, n) != n) {
  2e:	8626                	mv	a2,s1
  30:	85ca                	mv	a1,s2
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	380080e7          	jalr	896(ra) # 3b4 <write>
  3c:	fc950ee3          	beq	a0,s1,18 <cat+0x18>
      fprintf(2, "cat: write error\n");
  40:	00001597          	auipc	a1,0x1
  44:	8b858593          	addi	a1,a1,-1864 # 8f8 <malloc+0xe6>
  48:	4509                	li	a0,2
  4a:	00000097          	auipc	ra,0x0
  4e:	6dc080e7          	jalr	1756(ra) # 726 <fprintf>
      exit(1);
  52:	4505                	li	a0,1
  54:	00000097          	auipc	ra,0x0
  58:	340080e7          	jalr	832(ra) # 394 <exit>
    }
  }
  if(n < 0){
  5c:	00054963          	bltz	a0,6e <cat+0x6e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  60:	70a2                	ld	ra,40(sp)
  62:	7402                	ld	s0,32(sp)
  64:	64e2                	ld	s1,24(sp)
  66:	6942                	ld	s2,16(sp)
  68:	69a2                	ld	s3,8(sp)
  6a:	6145                	addi	sp,sp,48
  6c:	8082                	ret
    fprintf(2, "cat: read error\n");
  6e:	00001597          	auipc	a1,0x1
  72:	8a258593          	addi	a1,a1,-1886 # 910 <malloc+0xfe>
  76:	4509                	li	a0,2
  78:	00000097          	auipc	ra,0x0
  7c:	6ae080e7          	jalr	1710(ra) # 726 <fprintf>
    exit(1);
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	312080e7          	jalr	786(ra) # 394 <exit>

000000000000008a <main>:

int
main(int argc, char *argv[])
{
  8a:	7179                	addi	sp,sp,-48
  8c:	f406                	sd	ra,40(sp)
  8e:	f022                	sd	s0,32(sp)
  90:	ec26                	sd	s1,24(sp)
  92:	e84a                	sd	s2,16(sp)
  94:	e44e                	sd	s3,8(sp)
  96:	e052                	sd	s4,0(sp)
  98:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  9a:	4785                	li	a5,1
  9c:	04a7d763          	bge	a5,a0,ea <main+0x60>
  a0:	00858913          	addi	s2,a1,8
  a4:	ffe5099b          	addiw	s3,a0,-2
  a8:	1982                	slli	s3,s3,0x20
  aa:	0209d993          	srli	s3,s3,0x20
  ae:	098e                	slli	s3,s3,0x3
  b0:	05c1                	addi	a1,a1,16
  b2:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  b4:	4581                	li	a1,0
  b6:	00093503          	ld	a0,0(s2)
  ba:	00000097          	auipc	ra,0x0
  be:	31a080e7          	jalr	794(ra) # 3d4 <open>
  c2:	84aa                	mv	s1,a0
  c4:	02054d63          	bltz	a0,fe <main+0x74>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  c8:	00000097          	auipc	ra,0x0
  cc:	f38080e7          	jalr	-200(ra) # 0 <cat>
    close(fd);
  d0:	8526                	mv	a0,s1
  d2:	00000097          	auipc	ra,0x0
  d6:	2ea080e7          	jalr	746(ra) # 3bc <close>
  for(i = 1; i < argc; i++){
  da:	0921                	addi	s2,s2,8
  dc:	fd391ce3          	bne	s2,s3,b4 <main+0x2a>
  }
  exit(0);
  e0:	4501                	li	a0,0
  e2:	00000097          	auipc	ra,0x0
  e6:	2b2080e7          	jalr	690(ra) # 394 <exit>
    cat(0);
  ea:	4501                	li	a0,0
  ec:	00000097          	auipc	ra,0x0
  f0:	f14080e7          	jalr	-236(ra) # 0 <cat>
    exit(0);
  f4:	4501                	li	a0,0
  f6:	00000097          	auipc	ra,0x0
  fa:	29e080e7          	jalr	670(ra) # 394 <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
  fe:	00093603          	ld	a2,0(s2)
 102:	00001597          	auipc	a1,0x1
 106:	82658593          	addi	a1,a1,-2010 # 928 <malloc+0x116>
 10a:	4509                	li	a0,2
 10c:	00000097          	auipc	ra,0x0
 110:	61a080e7          	jalr	1562(ra) # 726 <fprintf>
      exit(1);
 114:	4505                	li	a0,1
 116:	00000097          	auipc	ra,0x0
 11a:	27e080e7          	jalr	638(ra) # 394 <exit>

000000000000011e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e422                	sd	s0,8(sp)
 122:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 124:	87aa                	mv	a5,a0
 126:	0585                	addi	a1,a1,1
 128:	0785                	addi	a5,a5,1
 12a:	fff5c703          	lbu	a4,-1(a1)
 12e:	fee78fa3          	sb	a4,-1(a5)
 132:	fb75                	bnez	a4,126 <strcpy+0x8>
    ;
  return os;
}
 134:	6422                	ld	s0,8(sp)
 136:	0141                	addi	sp,sp,16
 138:	8082                	ret

000000000000013a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 13a:	1141                	addi	sp,sp,-16
 13c:	e422                	sd	s0,8(sp)
 13e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 140:	00054783          	lbu	a5,0(a0)
 144:	cb91                	beqz	a5,158 <strcmp+0x1e>
 146:	0005c703          	lbu	a4,0(a1)
 14a:	00f71763          	bne	a4,a5,158 <strcmp+0x1e>
    p++, q++;
 14e:	0505                	addi	a0,a0,1
 150:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 152:	00054783          	lbu	a5,0(a0)
 156:	fbe5                	bnez	a5,146 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 158:	0005c503          	lbu	a0,0(a1)
}
 15c:	40a7853b          	subw	a0,a5,a0
 160:	6422                	ld	s0,8(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret

0000000000000166 <strlen>:

uint
strlen(const char *s)
{
 166:	1141                	addi	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 16c:	00054783          	lbu	a5,0(a0)
 170:	cf91                	beqz	a5,18c <strlen+0x26>
 172:	0505                	addi	a0,a0,1
 174:	87aa                	mv	a5,a0
 176:	4685                	li	a3,1
 178:	9e89                	subw	a3,a3,a0
 17a:	00f6853b          	addw	a0,a3,a5
 17e:	0785                	addi	a5,a5,1
 180:	fff7c703          	lbu	a4,-1(a5)
 184:	fb7d                	bnez	a4,17a <strlen+0x14>
    ;
  return n;
}
 186:	6422                	ld	s0,8(sp)
 188:	0141                	addi	sp,sp,16
 18a:	8082                	ret
  for(n = 0; s[n]; n++)
 18c:	4501                	li	a0,0
 18e:	bfe5                	j	186 <strlen+0x20>

0000000000000190 <memset>:

void*
memset(void *dst, int c, uint n)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 196:	ce09                	beqz	a2,1b0 <memset+0x20>
 198:	87aa                	mv	a5,a0
 19a:	fff6071b          	addiw	a4,a2,-1
 19e:	1702                	slli	a4,a4,0x20
 1a0:	9301                	srli	a4,a4,0x20
 1a2:	0705                	addi	a4,a4,1
 1a4:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1a6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1aa:	0785                	addi	a5,a5,1
 1ac:	fee79de3          	bne	a5,a4,1a6 <memset+0x16>
  }
  return dst;
}
 1b0:	6422                	ld	s0,8(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret

00000000000001b6 <strchr>:

char*
strchr(const char *s, char c)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	cb99                	beqz	a5,1d6 <strchr+0x20>
    if(*s == c)
 1c2:	00f58763          	beq	a1,a5,1d0 <strchr+0x1a>
  for(; *s; s++)
 1c6:	0505                	addi	a0,a0,1
 1c8:	00054783          	lbu	a5,0(a0)
 1cc:	fbfd                	bnez	a5,1c2 <strchr+0xc>
      return (char*)s;
  return 0;
 1ce:	4501                	li	a0,0
}
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret
  return 0;
 1d6:	4501                	li	a0,0
 1d8:	bfe5                	j	1d0 <strchr+0x1a>

00000000000001da <gets>:

char*
gets(char *buf, int max)
{
 1da:	711d                	addi	sp,sp,-96
 1dc:	ec86                	sd	ra,88(sp)
 1de:	e8a2                	sd	s0,80(sp)
 1e0:	e4a6                	sd	s1,72(sp)
 1e2:	e0ca                	sd	s2,64(sp)
 1e4:	fc4e                	sd	s3,56(sp)
 1e6:	f852                	sd	s4,48(sp)
 1e8:	f456                	sd	s5,40(sp)
 1ea:	f05a                	sd	s6,32(sp)
 1ec:	ec5e                	sd	s7,24(sp)
 1ee:	1080                	addi	s0,sp,96
 1f0:	8baa                	mv	s7,a0
 1f2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f4:	892a                	mv	s2,a0
 1f6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1f8:	4aa9                	li	s5,10
 1fa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1fc:	89a6                	mv	s3,s1
 1fe:	2485                	addiw	s1,s1,1
 200:	0344d863          	bge	s1,s4,230 <gets+0x56>
    cc = read(0, &c, 1);
 204:	4605                	li	a2,1
 206:	faf40593          	addi	a1,s0,-81
 20a:	4501                	li	a0,0
 20c:	00000097          	auipc	ra,0x0
 210:	1a0080e7          	jalr	416(ra) # 3ac <read>
    if(cc < 1)
 214:	00a05e63          	blez	a0,230 <gets+0x56>
    buf[i++] = c;
 218:	faf44783          	lbu	a5,-81(s0)
 21c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 220:	01578763          	beq	a5,s5,22e <gets+0x54>
 224:	0905                	addi	s2,s2,1
 226:	fd679be3          	bne	a5,s6,1fc <gets+0x22>
  for(i=0; i+1 < max; ){
 22a:	89a6                	mv	s3,s1
 22c:	a011                	j	230 <gets+0x56>
 22e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 230:	99de                	add	s3,s3,s7
 232:	00098023          	sb	zero,0(s3)
  return buf;
}
 236:	855e                	mv	a0,s7
 238:	60e6                	ld	ra,88(sp)
 23a:	6446                	ld	s0,80(sp)
 23c:	64a6                	ld	s1,72(sp)
 23e:	6906                	ld	s2,64(sp)
 240:	79e2                	ld	s3,56(sp)
 242:	7a42                	ld	s4,48(sp)
 244:	7aa2                	ld	s5,40(sp)
 246:	7b02                	ld	s6,32(sp)
 248:	6be2                	ld	s7,24(sp)
 24a:	6125                	addi	sp,sp,96
 24c:	8082                	ret

000000000000024e <stat>:

int
stat(const char *n, struct stat *st)
{
 24e:	1101                	addi	sp,sp,-32
 250:	ec06                	sd	ra,24(sp)
 252:	e822                	sd	s0,16(sp)
 254:	e426                	sd	s1,8(sp)
 256:	e04a                	sd	s2,0(sp)
 258:	1000                	addi	s0,sp,32
 25a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 25c:	4581                	li	a1,0
 25e:	00000097          	auipc	ra,0x0
 262:	176080e7          	jalr	374(ra) # 3d4 <open>
  if(fd < 0)
 266:	02054563          	bltz	a0,290 <stat+0x42>
 26a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 26c:	85ca                	mv	a1,s2
 26e:	00000097          	auipc	ra,0x0
 272:	17e080e7          	jalr	382(ra) # 3ec <fstat>
 276:	892a                	mv	s2,a0
  close(fd);
 278:	8526                	mv	a0,s1
 27a:	00000097          	auipc	ra,0x0
 27e:	142080e7          	jalr	322(ra) # 3bc <close>
  return r;
}
 282:	854a                	mv	a0,s2
 284:	60e2                	ld	ra,24(sp)
 286:	6442                	ld	s0,16(sp)
 288:	64a2                	ld	s1,8(sp)
 28a:	6902                	ld	s2,0(sp)
 28c:	6105                	addi	sp,sp,32
 28e:	8082                	ret
    return -1;
 290:	597d                	li	s2,-1
 292:	bfc5                	j	282 <stat+0x34>

0000000000000294 <atoi>:

int
atoi(const char *s)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29a:	00054603          	lbu	a2,0(a0)
 29e:	fd06079b          	addiw	a5,a2,-48
 2a2:	0ff7f793          	andi	a5,a5,255
 2a6:	4725                	li	a4,9
 2a8:	02f76963          	bltu	a4,a5,2da <atoi+0x46>
 2ac:	86aa                	mv	a3,a0
  n = 0;
 2ae:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2b0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2b2:	0685                	addi	a3,a3,1
 2b4:	0025179b          	slliw	a5,a0,0x2
 2b8:	9fa9                	addw	a5,a5,a0
 2ba:	0017979b          	slliw	a5,a5,0x1
 2be:	9fb1                	addw	a5,a5,a2
 2c0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2c4:	0006c603          	lbu	a2,0(a3)
 2c8:	fd06071b          	addiw	a4,a2,-48
 2cc:	0ff77713          	andi	a4,a4,255
 2d0:	fee5f1e3          	bgeu	a1,a4,2b2 <atoi+0x1e>
  return n;
}
 2d4:	6422                	ld	s0,8(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret
  n = 0;
 2da:	4501                	li	a0,0
 2dc:	bfe5                	j	2d4 <atoi+0x40>

00000000000002de <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e422                	sd	s0,8(sp)
 2e2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e4:	02b57663          	bgeu	a0,a1,310 <memmove+0x32>
    while(n-- > 0)
 2e8:	02c05163          	blez	a2,30a <memmove+0x2c>
 2ec:	fff6079b          	addiw	a5,a2,-1
 2f0:	1782                	slli	a5,a5,0x20
 2f2:	9381                	srli	a5,a5,0x20
 2f4:	0785                	addi	a5,a5,1
 2f6:	97aa                	add	a5,a5,a0
  dst = vdst;
 2f8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2fa:	0585                	addi	a1,a1,1
 2fc:	0705                	addi	a4,a4,1
 2fe:	fff5c683          	lbu	a3,-1(a1)
 302:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 306:	fee79ae3          	bne	a5,a4,2fa <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret
    dst += n;
 310:	00c50733          	add	a4,a0,a2
    src += n;
 314:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 316:	fec05ae3          	blez	a2,30a <memmove+0x2c>
 31a:	fff6079b          	addiw	a5,a2,-1
 31e:	1782                	slli	a5,a5,0x20
 320:	9381                	srli	a5,a5,0x20
 322:	fff7c793          	not	a5,a5
 326:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 328:	15fd                	addi	a1,a1,-1
 32a:	177d                	addi	a4,a4,-1
 32c:	0005c683          	lbu	a3,0(a1)
 330:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 334:	fee79ae3          	bne	a5,a4,328 <memmove+0x4a>
 338:	bfc9                	j	30a <memmove+0x2c>

000000000000033a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 33a:	1141                	addi	sp,sp,-16
 33c:	e422                	sd	s0,8(sp)
 33e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 340:	ca05                	beqz	a2,370 <memcmp+0x36>
 342:	fff6069b          	addiw	a3,a2,-1
 346:	1682                	slli	a3,a3,0x20
 348:	9281                	srli	a3,a3,0x20
 34a:	0685                	addi	a3,a3,1
 34c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 34e:	00054783          	lbu	a5,0(a0)
 352:	0005c703          	lbu	a4,0(a1)
 356:	00e79863          	bne	a5,a4,366 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 35a:	0505                	addi	a0,a0,1
    p2++;
 35c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 35e:	fed518e3          	bne	a0,a3,34e <memcmp+0x14>
  }
  return 0;
 362:	4501                	li	a0,0
 364:	a019                	j	36a <memcmp+0x30>
      return *p1 - *p2;
 366:	40e7853b          	subw	a0,a5,a4
}
 36a:	6422                	ld	s0,8(sp)
 36c:	0141                	addi	sp,sp,16
 36e:	8082                	ret
  return 0;
 370:	4501                	li	a0,0
 372:	bfe5                	j	36a <memcmp+0x30>

0000000000000374 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 374:	1141                	addi	sp,sp,-16
 376:	e406                	sd	ra,8(sp)
 378:	e022                	sd	s0,0(sp)
 37a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 37c:	00000097          	auipc	ra,0x0
 380:	f62080e7          	jalr	-158(ra) # 2de <memmove>
}
 384:	60a2                	ld	ra,8(sp)
 386:	6402                	ld	s0,0(sp)
 388:	0141                	addi	sp,sp,16
 38a:	8082                	ret

000000000000038c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 38c:	4885                	li	a7,1
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <exit>:
.global exit
exit:
 li a7, SYS_exit
 394:	4889                	li	a7,2
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <wait>:
.global wait
wait:
 li a7, SYS_wait
 39c:	488d                	li	a7,3
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a4:	4891                	li	a7,4
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <read>:
.global read
read:
 li a7, SYS_read
 3ac:	4895                	li	a7,5
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <write>:
.global write
write:
 li a7, SYS_write
 3b4:	48c1                	li	a7,16
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <close>:
.global close
close:
 li a7, SYS_close
 3bc:	48d5                	li	a7,21
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c4:	4899                	li	a7,6
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <exec>:
.global exec
exec:
 li a7, SYS_exec
 3cc:	489d                	li	a7,7
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <open>:
.global open
open:
 li a7, SYS_open
 3d4:	48bd                	li	a7,15
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3dc:	48c5                	li	a7,17
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e4:	48c9                	li	a7,18
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ec:	48a1                	li	a7,8
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <link>:
.global link
link:
 li a7, SYS_link
 3f4:	48cd                	li	a7,19
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3fc:	48d1                	li	a7,20
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 404:	48a5                	li	a7,9
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <dup>:
.global dup
dup:
 li a7, SYS_dup
 40c:	48a9                	li	a7,10
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 414:	48ad                	li	a7,11
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 41c:	48b1                	li	a7,12
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 424:	48b5                	li	a7,13
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 42c:	48b9                	li	a7,14
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 434:	48d9                	li	a7,22
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <yield>:
.global yield
yield:
 li a7, SYS_yield
 43c:	48dd                	li	a7,23
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 444:	48e1                	li	a7,24
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 44c:	48e5                	li	a7,25
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 454:	48e9                	li	a7,26
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <ps>:
.global ps
ps:
 li a7, SYS_ps
 45c:	48ed                	li	a7,27
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 464:	48f1                	li	a7,28
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 46c:	48f5                	li	a7,29
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 474:	48f9                	li	a7,30
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 47c:	1101                	addi	sp,sp,-32
 47e:	ec06                	sd	ra,24(sp)
 480:	e822                	sd	s0,16(sp)
 482:	1000                	addi	s0,sp,32
 484:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 488:	4605                	li	a2,1
 48a:	fef40593          	addi	a1,s0,-17
 48e:	00000097          	auipc	ra,0x0
 492:	f26080e7          	jalr	-218(ra) # 3b4 <write>
}
 496:	60e2                	ld	ra,24(sp)
 498:	6442                	ld	s0,16(sp)
 49a:	6105                	addi	sp,sp,32
 49c:	8082                	ret

000000000000049e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 49e:	7139                	addi	sp,sp,-64
 4a0:	fc06                	sd	ra,56(sp)
 4a2:	f822                	sd	s0,48(sp)
 4a4:	f426                	sd	s1,40(sp)
 4a6:	f04a                	sd	s2,32(sp)
 4a8:	ec4e                	sd	s3,24(sp)
 4aa:	0080                	addi	s0,sp,64
 4ac:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ae:	c299                	beqz	a3,4b4 <printint+0x16>
 4b0:	0805c863          	bltz	a1,540 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4b4:	2581                	sext.w	a1,a1
  neg = 0;
 4b6:	4881                	li	a7,0
 4b8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4bc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4be:	2601                	sext.w	a2,a2
 4c0:	00000517          	auipc	a0,0x0
 4c4:	48850513          	addi	a0,a0,1160 # 948 <digits>
 4c8:	883a                	mv	a6,a4
 4ca:	2705                	addiw	a4,a4,1
 4cc:	02c5f7bb          	remuw	a5,a1,a2
 4d0:	1782                	slli	a5,a5,0x20
 4d2:	9381                	srli	a5,a5,0x20
 4d4:	97aa                	add	a5,a5,a0
 4d6:	0007c783          	lbu	a5,0(a5)
 4da:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4de:	0005879b          	sext.w	a5,a1
 4e2:	02c5d5bb          	divuw	a1,a1,a2
 4e6:	0685                	addi	a3,a3,1
 4e8:	fec7f0e3          	bgeu	a5,a2,4c8 <printint+0x2a>
  if(neg)
 4ec:	00088b63          	beqz	a7,502 <printint+0x64>
    buf[i++] = '-';
 4f0:	fd040793          	addi	a5,s0,-48
 4f4:	973e                	add	a4,a4,a5
 4f6:	02d00793          	li	a5,45
 4fa:	fef70823          	sb	a5,-16(a4)
 4fe:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 502:	02e05863          	blez	a4,532 <printint+0x94>
 506:	fc040793          	addi	a5,s0,-64
 50a:	00e78933          	add	s2,a5,a4
 50e:	fff78993          	addi	s3,a5,-1
 512:	99ba                	add	s3,s3,a4
 514:	377d                	addiw	a4,a4,-1
 516:	1702                	slli	a4,a4,0x20
 518:	9301                	srli	a4,a4,0x20
 51a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 51e:	fff94583          	lbu	a1,-1(s2)
 522:	8526                	mv	a0,s1
 524:	00000097          	auipc	ra,0x0
 528:	f58080e7          	jalr	-168(ra) # 47c <putc>
  while(--i >= 0)
 52c:	197d                	addi	s2,s2,-1
 52e:	ff3918e3          	bne	s2,s3,51e <printint+0x80>
}
 532:	70e2                	ld	ra,56(sp)
 534:	7442                	ld	s0,48(sp)
 536:	74a2                	ld	s1,40(sp)
 538:	7902                	ld	s2,32(sp)
 53a:	69e2                	ld	s3,24(sp)
 53c:	6121                	addi	sp,sp,64
 53e:	8082                	ret
    x = -xx;
 540:	40b005bb          	negw	a1,a1
    neg = 1;
 544:	4885                	li	a7,1
    x = -xx;
 546:	bf8d                	j	4b8 <printint+0x1a>

0000000000000548 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 548:	7119                	addi	sp,sp,-128
 54a:	fc86                	sd	ra,120(sp)
 54c:	f8a2                	sd	s0,112(sp)
 54e:	f4a6                	sd	s1,104(sp)
 550:	f0ca                	sd	s2,96(sp)
 552:	ecce                	sd	s3,88(sp)
 554:	e8d2                	sd	s4,80(sp)
 556:	e4d6                	sd	s5,72(sp)
 558:	e0da                	sd	s6,64(sp)
 55a:	fc5e                	sd	s7,56(sp)
 55c:	f862                	sd	s8,48(sp)
 55e:	f466                	sd	s9,40(sp)
 560:	f06a                	sd	s10,32(sp)
 562:	ec6e                	sd	s11,24(sp)
 564:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 566:	0005c903          	lbu	s2,0(a1)
 56a:	18090f63          	beqz	s2,708 <vprintf+0x1c0>
 56e:	8aaa                	mv	s5,a0
 570:	8b32                	mv	s6,a2
 572:	00158493          	addi	s1,a1,1
  state = 0;
 576:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 578:	02500a13          	li	s4,37
      if(c == 'd'){
 57c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 580:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 584:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 588:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 58c:	00000b97          	auipc	s7,0x0
 590:	3bcb8b93          	addi	s7,s7,956 # 948 <digits>
 594:	a839                	j	5b2 <vprintf+0x6a>
        putc(fd, c);
 596:	85ca                	mv	a1,s2
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	ee2080e7          	jalr	-286(ra) # 47c <putc>
 5a2:	a019                	j	5a8 <vprintf+0x60>
    } else if(state == '%'){
 5a4:	01498f63          	beq	s3,s4,5c2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5a8:	0485                	addi	s1,s1,1
 5aa:	fff4c903          	lbu	s2,-1(s1)
 5ae:	14090d63          	beqz	s2,708 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5b2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5b6:	fe0997e3          	bnez	s3,5a4 <vprintf+0x5c>
      if(c == '%'){
 5ba:	fd479ee3          	bne	a5,s4,596 <vprintf+0x4e>
        state = '%';
 5be:	89be                	mv	s3,a5
 5c0:	b7e5                	j	5a8 <vprintf+0x60>
      if(c == 'd'){
 5c2:	05878063          	beq	a5,s8,602 <vprintf+0xba>
      } else if(c == 'l') {
 5c6:	05978c63          	beq	a5,s9,61e <vprintf+0xd6>
      } else if(c == 'x') {
 5ca:	07a78863          	beq	a5,s10,63a <vprintf+0xf2>
      } else if(c == 'p') {
 5ce:	09b78463          	beq	a5,s11,656 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5d2:	07300713          	li	a4,115
 5d6:	0ce78663          	beq	a5,a4,6a2 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5da:	06300713          	li	a4,99
 5de:	0ee78e63          	beq	a5,a4,6da <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5e2:	11478863          	beq	a5,s4,6f2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5e6:	85d2                	mv	a1,s4
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	e92080e7          	jalr	-366(ra) # 47c <putc>
        putc(fd, c);
 5f2:	85ca                	mv	a1,s2
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	e86080e7          	jalr	-378(ra) # 47c <putc>
      }
      state = 0;
 5fe:	4981                	li	s3,0
 600:	b765                	j	5a8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 602:	008b0913          	addi	s2,s6,8
 606:	4685                	li	a3,1
 608:	4629                	li	a2,10
 60a:	000b2583          	lw	a1,0(s6)
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	e8e080e7          	jalr	-370(ra) # 49e <printint>
 618:	8b4a                	mv	s6,s2
      state = 0;
 61a:	4981                	li	s3,0
 61c:	b771                	j	5a8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61e:	008b0913          	addi	s2,s6,8
 622:	4681                	li	a3,0
 624:	4629                	li	a2,10
 626:	000b2583          	lw	a1,0(s6)
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	e72080e7          	jalr	-398(ra) # 49e <printint>
 634:	8b4a                	mv	s6,s2
      state = 0;
 636:	4981                	li	s3,0
 638:	bf85                	j	5a8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 63a:	008b0913          	addi	s2,s6,8
 63e:	4681                	li	a3,0
 640:	4641                	li	a2,16
 642:	000b2583          	lw	a1,0(s6)
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	e56080e7          	jalr	-426(ra) # 49e <printint>
 650:	8b4a                	mv	s6,s2
      state = 0;
 652:	4981                	li	s3,0
 654:	bf91                	j	5a8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 656:	008b0793          	addi	a5,s6,8
 65a:	f8f43423          	sd	a5,-120(s0)
 65e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 662:	03000593          	li	a1,48
 666:	8556                	mv	a0,s5
 668:	00000097          	auipc	ra,0x0
 66c:	e14080e7          	jalr	-492(ra) # 47c <putc>
  putc(fd, 'x');
 670:	85ea                	mv	a1,s10
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	e08080e7          	jalr	-504(ra) # 47c <putc>
 67c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 67e:	03c9d793          	srli	a5,s3,0x3c
 682:	97de                	add	a5,a5,s7
 684:	0007c583          	lbu	a1,0(a5)
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	df2080e7          	jalr	-526(ra) # 47c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 692:	0992                	slli	s3,s3,0x4
 694:	397d                	addiw	s2,s2,-1
 696:	fe0914e3          	bnez	s2,67e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 69a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	b721                	j	5a8 <vprintf+0x60>
        s = va_arg(ap, char*);
 6a2:	008b0993          	addi	s3,s6,8
 6a6:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6aa:	02090163          	beqz	s2,6cc <vprintf+0x184>
        while(*s != 0){
 6ae:	00094583          	lbu	a1,0(s2)
 6b2:	c9a1                	beqz	a1,702 <vprintf+0x1ba>
          putc(fd, *s);
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	dc6080e7          	jalr	-570(ra) # 47c <putc>
          s++;
 6be:	0905                	addi	s2,s2,1
        while(*s != 0){
 6c0:	00094583          	lbu	a1,0(s2)
 6c4:	f9e5                	bnez	a1,6b4 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6c6:	8b4e                	mv	s6,s3
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	bdf9                	j	5a8 <vprintf+0x60>
          s = "(null)";
 6cc:	00000917          	auipc	s2,0x0
 6d0:	27490913          	addi	s2,s2,628 # 940 <malloc+0x12e>
        while(*s != 0){
 6d4:	02800593          	li	a1,40
 6d8:	bff1                	j	6b4 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6da:	008b0913          	addi	s2,s6,8
 6de:	000b4583          	lbu	a1,0(s6)
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	d98080e7          	jalr	-616(ra) # 47c <putc>
 6ec:	8b4a                	mv	s6,s2
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	bd65                	j	5a8 <vprintf+0x60>
        putc(fd, c);
 6f2:	85d2                	mv	a1,s4
 6f4:	8556                	mv	a0,s5
 6f6:	00000097          	auipc	ra,0x0
 6fa:	d86080e7          	jalr	-634(ra) # 47c <putc>
      state = 0;
 6fe:	4981                	li	s3,0
 700:	b565                	j	5a8 <vprintf+0x60>
        s = va_arg(ap, char*);
 702:	8b4e                	mv	s6,s3
      state = 0;
 704:	4981                	li	s3,0
 706:	b54d                	j	5a8 <vprintf+0x60>
    }
  }
}
 708:	70e6                	ld	ra,120(sp)
 70a:	7446                	ld	s0,112(sp)
 70c:	74a6                	ld	s1,104(sp)
 70e:	7906                	ld	s2,96(sp)
 710:	69e6                	ld	s3,88(sp)
 712:	6a46                	ld	s4,80(sp)
 714:	6aa6                	ld	s5,72(sp)
 716:	6b06                	ld	s6,64(sp)
 718:	7be2                	ld	s7,56(sp)
 71a:	7c42                	ld	s8,48(sp)
 71c:	7ca2                	ld	s9,40(sp)
 71e:	7d02                	ld	s10,32(sp)
 720:	6de2                	ld	s11,24(sp)
 722:	6109                	addi	sp,sp,128
 724:	8082                	ret

0000000000000726 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 726:	715d                	addi	sp,sp,-80
 728:	ec06                	sd	ra,24(sp)
 72a:	e822                	sd	s0,16(sp)
 72c:	1000                	addi	s0,sp,32
 72e:	e010                	sd	a2,0(s0)
 730:	e414                	sd	a3,8(s0)
 732:	e818                	sd	a4,16(s0)
 734:	ec1c                	sd	a5,24(s0)
 736:	03043023          	sd	a6,32(s0)
 73a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 73e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 742:	8622                	mv	a2,s0
 744:	00000097          	auipc	ra,0x0
 748:	e04080e7          	jalr	-508(ra) # 548 <vprintf>
}
 74c:	60e2                	ld	ra,24(sp)
 74e:	6442                	ld	s0,16(sp)
 750:	6161                	addi	sp,sp,80
 752:	8082                	ret

0000000000000754 <printf>:

void
printf(const char *fmt, ...)
{
 754:	711d                	addi	sp,sp,-96
 756:	ec06                	sd	ra,24(sp)
 758:	e822                	sd	s0,16(sp)
 75a:	1000                	addi	s0,sp,32
 75c:	e40c                	sd	a1,8(s0)
 75e:	e810                	sd	a2,16(s0)
 760:	ec14                	sd	a3,24(s0)
 762:	f018                	sd	a4,32(s0)
 764:	f41c                	sd	a5,40(s0)
 766:	03043823          	sd	a6,48(s0)
 76a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 76e:	00840613          	addi	a2,s0,8
 772:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 776:	85aa                	mv	a1,a0
 778:	4505                	li	a0,1
 77a:	00000097          	auipc	ra,0x0
 77e:	dce080e7          	jalr	-562(ra) # 548 <vprintf>
}
 782:	60e2                	ld	ra,24(sp)
 784:	6442                	ld	s0,16(sp)
 786:	6125                	addi	sp,sp,96
 788:	8082                	ret

000000000000078a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 78a:	1141                	addi	sp,sp,-16
 78c:	e422                	sd	s0,8(sp)
 78e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 790:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 794:	00000797          	auipc	a5,0x0
 798:	1cc7b783          	ld	a5,460(a5) # 960 <freep>
 79c:	a805                	j	7cc <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 79e:	4618                	lw	a4,8(a2)
 7a0:	9db9                	addw	a1,a1,a4
 7a2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a6:	6398                	ld	a4,0(a5)
 7a8:	6318                	ld	a4,0(a4)
 7aa:	fee53823          	sd	a4,-16(a0)
 7ae:	a091                	j	7f2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7b0:	ff852703          	lw	a4,-8(a0)
 7b4:	9e39                	addw	a2,a2,a4
 7b6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7b8:	ff053703          	ld	a4,-16(a0)
 7bc:	e398                	sd	a4,0(a5)
 7be:	a099                	j	804 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c0:	6398                	ld	a4,0(a5)
 7c2:	00e7e463          	bltu	a5,a4,7ca <free+0x40>
 7c6:	00e6ea63          	bltu	a3,a4,7da <free+0x50>
{
 7ca:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7cc:	fed7fae3          	bgeu	a5,a3,7c0 <free+0x36>
 7d0:	6398                	ld	a4,0(a5)
 7d2:	00e6e463          	bltu	a3,a4,7da <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d6:	fee7eae3          	bltu	a5,a4,7ca <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7da:	ff852583          	lw	a1,-8(a0)
 7de:	6390                	ld	a2,0(a5)
 7e0:	02059713          	slli	a4,a1,0x20
 7e4:	9301                	srli	a4,a4,0x20
 7e6:	0712                	slli	a4,a4,0x4
 7e8:	9736                	add	a4,a4,a3
 7ea:	fae60ae3          	beq	a2,a4,79e <free+0x14>
    bp->s.ptr = p->s.ptr;
 7ee:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7f2:	4790                	lw	a2,8(a5)
 7f4:	02061713          	slli	a4,a2,0x20
 7f8:	9301                	srli	a4,a4,0x20
 7fa:	0712                	slli	a4,a4,0x4
 7fc:	973e                	add	a4,a4,a5
 7fe:	fae689e3          	beq	a3,a4,7b0 <free+0x26>
  } else
    p->s.ptr = bp;
 802:	e394                	sd	a3,0(a5)
  freep = p;
 804:	00000717          	auipc	a4,0x0
 808:	14f73e23          	sd	a5,348(a4) # 960 <freep>
}
 80c:	6422                	ld	s0,8(sp)
 80e:	0141                	addi	sp,sp,16
 810:	8082                	ret

0000000000000812 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 812:	7139                	addi	sp,sp,-64
 814:	fc06                	sd	ra,56(sp)
 816:	f822                	sd	s0,48(sp)
 818:	f426                	sd	s1,40(sp)
 81a:	f04a                	sd	s2,32(sp)
 81c:	ec4e                	sd	s3,24(sp)
 81e:	e852                	sd	s4,16(sp)
 820:	e456                	sd	s5,8(sp)
 822:	e05a                	sd	s6,0(sp)
 824:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 826:	02051493          	slli	s1,a0,0x20
 82a:	9081                	srli	s1,s1,0x20
 82c:	04bd                	addi	s1,s1,15
 82e:	8091                	srli	s1,s1,0x4
 830:	0014899b          	addiw	s3,s1,1
 834:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 836:	00000517          	auipc	a0,0x0
 83a:	12a53503          	ld	a0,298(a0) # 960 <freep>
 83e:	c515                	beqz	a0,86a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 840:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 842:	4798                	lw	a4,8(a5)
 844:	02977f63          	bgeu	a4,s1,882 <malloc+0x70>
 848:	8a4e                	mv	s4,s3
 84a:	0009871b          	sext.w	a4,s3
 84e:	6685                	lui	a3,0x1
 850:	00d77363          	bgeu	a4,a3,856 <malloc+0x44>
 854:	6a05                	lui	s4,0x1
 856:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 85a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 85e:	00000917          	auipc	s2,0x0
 862:	10290913          	addi	s2,s2,258 # 960 <freep>
  if(p == (char*)-1)
 866:	5afd                	li	s5,-1
 868:	a88d                	j	8da <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 86a:	00000797          	auipc	a5,0x0
 86e:	2fe78793          	addi	a5,a5,766 # b68 <base>
 872:	00000717          	auipc	a4,0x0
 876:	0ef73723          	sd	a5,238(a4) # 960 <freep>
 87a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 87c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 880:	b7e1                	j	848 <malloc+0x36>
      if(p->s.size == nunits)
 882:	02e48b63          	beq	s1,a4,8b8 <malloc+0xa6>
        p->s.size -= nunits;
 886:	4137073b          	subw	a4,a4,s3
 88a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 88c:	1702                	slli	a4,a4,0x20
 88e:	9301                	srli	a4,a4,0x20
 890:	0712                	slli	a4,a4,0x4
 892:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 894:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 898:	00000717          	auipc	a4,0x0
 89c:	0ca73423          	sd	a0,200(a4) # 960 <freep>
      return (void*)(p + 1);
 8a0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8a4:	70e2                	ld	ra,56(sp)
 8a6:	7442                	ld	s0,48(sp)
 8a8:	74a2                	ld	s1,40(sp)
 8aa:	7902                	ld	s2,32(sp)
 8ac:	69e2                	ld	s3,24(sp)
 8ae:	6a42                	ld	s4,16(sp)
 8b0:	6aa2                	ld	s5,8(sp)
 8b2:	6b02                	ld	s6,0(sp)
 8b4:	6121                	addi	sp,sp,64
 8b6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8b8:	6398                	ld	a4,0(a5)
 8ba:	e118                	sd	a4,0(a0)
 8bc:	bff1                	j	898 <malloc+0x86>
  hp->s.size = nu;
 8be:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8c2:	0541                	addi	a0,a0,16
 8c4:	00000097          	auipc	ra,0x0
 8c8:	ec6080e7          	jalr	-314(ra) # 78a <free>
  return freep;
 8cc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8d0:	d971                	beqz	a0,8a4 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d4:	4798                	lw	a4,8(a5)
 8d6:	fa9776e3          	bgeu	a4,s1,882 <malloc+0x70>
    if(p == freep)
 8da:	00093703          	ld	a4,0(s2)
 8de:	853e                	mv	a0,a5
 8e0:	fef719e3          	bne	a4,a5,8d2 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8e4:	8552                	mv	a0,s4
 8e6:	00000097          	auipc	ra,0x0
 8ea:	b36080e7          	jalr	-1226(ra) # 41c <sbrk>
  if(p == (char*)-1)
 8ee:	fd5518e3          	bne	a0,s5,8be <malloc+0xac>
        return 0;
 8f2:	4501                	li	a0,0
 8f4:	bf45                	j	8a4 <malloc+0x92>
