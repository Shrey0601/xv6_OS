
user/_pipeline:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <func>:
#include "kernel/stat.h"
#include "user/user.h"
#include <stddef.h>

void func(int n, int x){
	if(n==0){
   0:	e111                	bnez	a0,4 <func+0x4>
   2:	8082                	ret
void func(int n, int x){
   4:	7139                	addi	sp,sp,-64
   6:	fc06                	sd	ra,56(sp)
   8:	f822                	sd	s0,48(sp)
   a:	f426                	sd	s1,40(sp)
   c:	f04a                	sd	s2,32(sp)
   e:	0080                	addi	s0,sp,64
  10:	84aa                	mv	s1,a0
  12:	892e                	mv	s2,a1
		return;
	}
	else{
		int fd1[2], fd2[2];

        if (pipe(fd1) < 0) {
  14:	fd040513          	addi	a0,s0,-48
  18:	00000097          	auipc	ra,0x0
  1c:	47e080e7          	jalr	1150(ra) # 496 <pipe>
  20:	08054f63          	bltz	a0,be <func+0xbe>
           printf("Pipe 1 Failed");
           exit(0);
        }
        if (pipe(fd2) < 0) {
  24:	fd840513          	addi	a0,s0,-40
  28:	00000097          	auipc	ra,0x0
  2c:	46e080e7          	jalr	1134(ra) # 496 <pipe>
  30:	0a054463          	bltz	a0,d8 <func+0xd8>
           printf("Pipe 2 Failed");
           exit(0);
        }
		int ret = fork();
  34:	00000097          	auipc	ra,0x0
  38:	44a080e7          	jalr	1098(ra) # 47e <fork>
		if(ret > 0){
  3c:	0aa05b63          	blez	a0,f2 <func+0xf2>
			int temp = x, ans;
  40:	fd242423          	sw	s2,-56(s0)
			write(fd1[1], &temp, sizeof(temp));
  44:	4611                	li	a2,4
  46:	fc840593          	addi	a1,s0,-56
  4a:	fd442503          	lw	a0,-44(s0)
  4e:	00000097          	auipc	ra,0x0
  52:	458080e7          	jalr	1112(ra) # 4a6 <write>
			wait(NULL);
  56:	4501                	li	a0,0
  58:	00000097          	auipc	ra,0x0
  5c:	436080e7          	jalr	1078(ra) # 48e <wait>
			read(fd2[0], &ans, sizeof(ans));
  60:	4611                	li	a2,4
  62:	fcc40593          	addi	a1,s0,-52
  66:	fd842503          	lw	a0,-40(s0)
  6a:	00000097          	auipc	ra,0x0
  6e:	434080e7          	jalr	1076(ra) # 49e <read>
			close(fd1[0]);
  72:	fd042503          	lw	a0,-48(s0)
  76:	00000097          	auipc	ra,0x0
  7a:	438080e7          	jalr	1080(ra) # 4ae <close>
			close(fd1[1]);
  7e:	fd442503          	lw	a0,-44(s0)
  82:	00000097          	auipc	ra,0x0
  86:	42c080e7          	jalr	1068(ra) # 4ae <close>
			close(fd2[0]);
  8a:	fd842503          	lw	a0,-40(s0)
  8e:	00000097          	auipc	ra,0x0
  92:	420080e7          	jalr	1056(ra) # 4ae <close>
			close(fd2[1]);
  96:	fdc42503          	lw	a0,-36(s0)
  9a:	00000097          	auipc	ra,0x0
  9e:	414080e7          	jalr	1044(ra) # 4ae <close>
			return func(n-1, ans);
  a2:	fcc42583          	lw	a1,-52(s0)
  a6:	fff4851b          	addiw	a0,s1,-1
  aa:	00000097          	auipc	ra,0x0
  ae:	f56080e7          	jalr	-170(ra) # 0 <func>
			close(fd2[1]);
			return;
		}
	}
	
}
  b2:	70e2                	ld	ra,56(sp)
  b4:	7442                	ld	s0,48(sp)
  b6:	74a2                	ld	s1,40(sp)
  b8:	7902                	ld	s2,32(sp)
  ba:	6121                	addi	sp,sp,64
  bc:	8082                	ret
           printf("Pipe 1 Failed");
  be:	00001517          	auipc	a0,0x1
  c2:	91a50513          	addi	a0,a0,-1766 # 9d8 <malloc+0xe4>
  c6:	00000097          	auipc	ra,0x0
  ca:	770080e7          	jalr	1904(ra) # 836 <printf>
           exit(0);
  ce:	4501                	li	a0,0
  d0:	00000097          	auipc	ra,0x0
  d4:	3b6080e7          	jalr	950(ra) # 486 <exit>
           printf("Pipe 2 Failed");
  d8:	00001517          	auipc	a0,0x1
  dc:	91050513          	addi	a0,a0,-1776 # 9e8 <malloc+0xf4>
  e0:	00000097          	auipc	ra,0x0
  e4:	756080e7          	jalr	1878(ra) # 836 <printf>
           exit(0);
  e8:	4501                	li	a0,0
  ea:	00000097          	auipc	ra,0x0
  ee:	39c080e7          	jalr	924(ra) # 486 <exit>
			read(fd1[0], &temp, sizeof(temp));
  f2:	4611                	li	a2,4
  f4:	fc840593          	addi	a1,s0,-56
  f8:	fd042503          	lw	a0,-48(s0)
  fc:	00000097          	auipc	ra,0x0
 100:	3a2080e7          	jalr	930(ra) # 49e <read>
			ans = temp;
 104:	fc842783          	lw	a5,-56(s0)
 108:	fcf42623          	sw	a5,-52(s0)
			ans += getpid();
 10c:	00000097          	auipc	ra,0x0
 110:	3fa080e7          	jalr	1018(ra) # 506 <getpid>
 114:	fcc42783          	lw	a5,-52(s0)
 118:	9fa9                	addw	a5,a5,a0
 11a:	fcf42623          	sw	a5,-52(s0)
			printf("%d : %d\n",getpid(),ans);
 11e:	00000097          	auipc	ra,0x0
 122:	3e8080e7          	jalr	1000(ra) # 506 <getpid>
 126:	85aa                	mv	a1,a0
 128:	fcc42603          	lw	a2,-52(s0)
 12c:	00001517          	auipc	a0,0x1
 130:	8cc50513          	addi	a0,a0,-1844 # 9f8 <malloc+0x104>
 134:	00000097          	auipc	ra,0x0
 138:	702080e7          	jalr	1794(ra) # 836 <printf>
			write(fd2[1], &ans, sizeof(ans));
 13c:	4611                	li	a2,4
 13e:	fcc40593          	addi	a1,s0,-52
 142:	fdc42503          	lw	a0,-36(s0)
 146:	00000097          	auipc	ra,0x0
 14a:	360080e7          	jalr	864(ra) # 4a6 <write>
			close(fd1[0]);
 14e:	fd042503          	lw	a0,-48(s0)
 152:	00000097          	auipc	ra,0x0
 156:	35c080e7          	jalr	860(ra) # 4ae <close>
			close(fd2[0]);
 15a:	fd842503          	lw	a0,-40(s0)
 15e:	00000097          	auipc	ra,0x0
 162:	350080e7          	jalr	848(ra) # 4ae <close>
			close(fd1[1]);
 166:	fd442503          	lw	a0,-44(s0)
 16a:	00000097          	auipc	ra,0x0
 16e:	344080e7          	jalr	836(ra) # 4ae <close>
			close(fd2[1]);
 172:	fdc42503          	lw	a0,-36(s0)
 176:	00000097          	auipc	ra,0x0
 17a:	338080e7          	jalr	824(ra) # 4ae <close>
			return;
 17e:	bf15                	j	b2 <func+0xb2>

0000000000000180 <main>:

int main(int argc, char* argv[]){
 180:	7179                	addi	sp,sp,-48
 182:	f406                	sd	ra,40(sp)
 184:	f022                	sd	s0,32(sp)
 186:	ec26                	sd	s1,24(sp)
 188:	e84a                	sd	s2,16(sp)
 18a:	e44e                	sd	s3,8(sp)
 18c:	1800                	addi	s0,sp,48
    if(argc!=3){
 18e:	478d                	li	a5,3
 190:	00f50763          	beq	a0,a5,19e <main+0x1e>
        exit(0);
 194:	4501                	li	a0,0
 196:	00000097          	auipc	ra,0x0
 19a:	2f0080e7          	jalr	752(ra) # 486 <exit>
 19e:	84ae                	mv	s1,a1
    }
    else{
        int n = atoi(argv[1]);
 1a0:	6588                	ld	a0,8(a1)
 1a2:	00000097          	auipc	ra,0x0
 1a6:	1e4080e7          	jalr	484(ra) # 386 <atoi>
 1aa:	892a                	mv	s2,a0
        int x = atoi(argv[2]);
 1ac:	6888                	ld	a0,16(s1)
 1ae:	00000097          	auipc	ra,0x0
 1b2:	1d8080e7          	jalr	472(ra) # 386 <atoi>
 1b6:	84aa                	mv	s1,a0
        // printf("%d\n", getpid());
        if(n<=0){
 1b8:	05205763          	blez	s2,206 <main+0x86>
            exit(0);
        }
        printf("%d : %d\n",getpid(), x + getpid());
 1bc:	00000097          	auipc	ra,0x0
 1c0:	34a080e7          	jalr	842(ra) # 506 <getpid>
 1c4:	89aa                	mv	s3,a0
 1c6:	00000097          	auipc	ra,0x0
 1ca:	340080e7          	jalr	832(ra) # 506 <getpid>
 1ce:	0095063b          	addw	a2,a0,s1
 1d2:	85ce                	mv	a1,s3
 1d4:	00001517          	auipc	a0,0x1
 1d8:	82450513          	addi	a0,a0,-2012 # 9f8 <malloc+0x104>
 1dc:	00000097          	auipc	ra,0x0
 1e0:	65a080e7          	jalr	1626(ra) # 836 <printf>
		func(n-1, x+getpid());
 1e4:	00000097          	auipc	ra,0x0
 1e8:	322080e7          	jalr	802(ra) # 506 <getpid>
 1ec:	009505bb          	addw	a1,a0,s1
 1f0:	fff9051b          	addiw	a0,s2,-1
 1f4:	00000097          	auipc	ra,0x0
 1f8:	e0c080e7          	jalr	-500(ra) # 0 <func>
        
    }
    exit(0);
 1fc:	4501                	li	a0,0
 1fe:	00000097          	auipc	ra,0x0
 202:	288080e7          	jalr	648(ra) # 486 <exit>
            exit(0);
 206:	4501                	li	a0,0
 208:	00000097          	auipc	ra,0x0
 20c:	27e080e7          	jalr	638(ra) # 486 <exit>

0000000000000210 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 210:	1141                	addi	sp,sp,-16
 212:	e422                	sd	s0,8(sp)
 214:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 216:	87aa                	mv	a5,a0
 218:	0585                	addi	a1,a1,1
 21a:	0785                	addi	a5,a5,1
 21c:	fff5c703          	lbu	a4,-1(a1)
 220:	fee78fa3          	sb	a4,-1(a5)
 224:	fb75                	bnez	a4,218 <strcpy+0x8>
    ;
  return os;
}
 226:	6422                	ld	s0,8(sp)
 228:	0141                	addi	sp,sp,16
 22a:	8082                	ret

000000000000022c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 232:	00054783          	lbu	a5,0(a0)
 236:	cb91                	beqz	a5,24a <strcmp+0x1e>
 238:	0005c703          	lbu	a4,0(a1)
 23c:	00f71763          	bne	a4,a5,24a <strcmp+0x1e>
    p++, q++;
 240:	0505                	addi	a0,a0,1
 242:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 244:	00054783          	lbu	a5,0(a0)
 248:	fbe5                	bnez	a5,238 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 24a:	0005c503          	lbu	a0,0(a1)
}
 24e:	40a7853b          	subw	a0,a5,a0
 252:	6422                	ld	s0,8(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret

0000000000000258 <strlen>:

uint
strlen(const char *s)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e422                	sd	s0,8(sp)
 25c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 25e:	00054783          	lbu	a5,0(a0)
 262:	cf91                	beqz	a5,27e <strlen+0x26>
 264:	0505                	addi	a0,a0,1
 266:	87aa                	mv	a5,a0
 268:	4685                	li	a3,1
 26a:	9e89                	subw	a3,a3,a0
 26c:	00f6853b          	addw	a0,a3,a5
 270:	0785                	addi	a5,a5,1
 272:	fff7c703          	lbu	a4,-1(a5)
 276:	fb7d                	bnez	a4,26c <strlen+0x14>
    ;
  return n;
}
 278:	6422                	ld	s0,8(sp)
 27a:	0141                	addi	sp,sp,16
 27c:	8082                	ret
  for(n = 0; s[n]; n++)
 27e:	4501                	li	a0,0
 280:	bfe5                	j	278 <strlen+0x20>

0000000000000282 <memset>:

void*
memset(void *dst, int c, uint n)
{
 282:	1141                	addi	sp,sp,-16
 284:	e422                	sd	s0,8(sp)
 286:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 288:	ce09                	beqz	a2,2a2 <memset+0x20>
 28a:	87aa                	mv	a5,a0
 28c:	fff6071b          	addiw	a4,a2,-1
 290:	1702                	slli	a4,a4,0x20
 292:	9301                	srli	a4,a4,0x20
 294:	0705                	addi	a4,a4,1
 296:	972a                	add	a4,a4,a0
    cdst[i] = c;
 298:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 29c:	0785                	addi	a5,a5,1
 29e:	fee79de3          	bne	a5,a4,298 <memset+0x16>
  }
  return dst;
}
 2a2:	6422                	ld	s0,8(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret

00000000000002a8 <strchr>:

char*
strchr(const char *s, char c)
{
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e422                	sd	s0,8(sp)
 2ac:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2ae:	00054783          	lbu	a5,0(a0)
 2b2:	cb99                	beqz	a5,2c8 <strchr+0x20>
    if(*s == c)
 2b4:	00f58763          	beq	a1,a5,2c2 <strchr+0x1a>
  for(; *s; s++)
 2b8:	0505                	addi	a0,a0,1
 2ba:	00054783          	lbu	a5,0(a0)
 2be:	fbfd                	bnez	a5,2b4 <strchr+0xc>
      return (char*)s;
  return 0;
 2c0:	4501                	li	a0,0
}
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret
  return 0;
 2c8:	4501                	li	a0,0
 2ca:	bfe5                	j	2c2 <strchr+0x1a>

00000000000002cc <gets>:

char*
gets(char *buf, int max)
{
 2cc:	711d                	addi	sp,sp,-96
 2ce:	ec86                	sd	ra,88(sp)
 2d0:	e8a2                	sd	s0,80(sp)
 2d2:	e4a6                	sd	s1,72(sp)
 2d4:	e0ca                	sd	s2,64(sp)
 2d6:	fc4e                	sd	s3,56(sp)
 2d8:	f852                	sd	s4,48(sp)
 2da:	f456                	sd	s5,40(sp)
 2dc:	f05a                	sd	s6,32(sp)
 2de:	ec5e                	sd	s7,24(sp)
 2e0:	1080                	addi	s0,sp,96
 2e2:	8baa                	mv	s7,a0
 2e4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e6:	892a                	mv	s2,a0
 2e8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ea:	4aa9                	li	s5,10
 2ec:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2ee:	89a6                	mv	s3,s1
 2f0:	2485                	addiw	s1,s1,1
 2f2:	0344d863          	bge	s1,s4,322 <gets+0x56>
    cc = read(0, &c, 1);
 2f6:	4605                	li	a2,1
 2f8:	faf40593          	addi	a1,s0,-81
 2fc:	4501                	li	a0,0
 2fe:	00000097          	auipc	ra,0x0
 302:	1a0080e7          	jalr	416(ra) # 49e <read>
    if(cc < 1)
 306:	00a05e63          	blez	a0,322 <gets+0x56>
    buf[i++] = c;
 30a:	faf44783          	lbu	a5,-81(s0)
 30e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 312:	01578763          	beq	a5,s5,320 <gets+0x54>
 316:	0905                	addi	s2,s2,1
 318:	fd679be3          	bne	a5,s6,2ee <gets+0x22>
  for(i=0; i+1 < max; ){
 31c:	89a6                	mv	s3,s1
 31e:	a011                	j	322 <gets+0x56>
 320:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 322:	99de                	add	s3,s3,s7
 324:	00098023          	sb	zero,0(s3)
  return buf;
}
 328:	855e                	mv	a0,s7
 32a:	60e6                	ld	ra,88(sp)
 32c:	6446                	ld	s0,80(sp)
 32e:	64a6                	ld	s1,72(sp)
 330:	6906                	ld	s2,64(sp)
 332:	79e2                	ld	s3,56(sp)
 334:	7a42                	ld	s4,48(sp)
 336:	7aa2                	ld	s5,40(sp)
 338:	7b02                	ld	s6,32(sp)
 33a:	6be2                	ld	s7,24(sp)
 33c:	6125                	addi	sp,sp,96
 33e:	8082                	ret

0000000000000340 <stat>:

int
stat(const char *n, struct stat *st)
{
 340:	1101                	addi	sp,sp,-32
 342:	ec06                	sd	ra,24(sp)
 344:	e822                	sd	s0,16(sp)
 346:	e426                	sd	s1,8(sp)
 348:	e04a                	sd	s2,0(sp)
 34a:	1000                	addi	s0,sp,32
 34c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 34e:	4581                	li	a1,0
 350:	00000097          	auipc	ra,0x0
 354:	176080e7          	jalr	374(ra) # 4c6 <open>
  if(fd < 0)
 358:	02054563          	bltz	a0,382 <stat+0x42>
 35c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 35e:	85ca                	mv	a1,s2
 360:	00000097          	auipc	ra,0x0
 364:	17e080e7          	jalr	382(ra) # 4de <fstat>
 368:	892a                	mv	s2,a0
  close(fd);
 36a:	8526                	mv	a0,s1
 36c:	00000097          	auipc	ra,0x0
 370:	142080e7          	jalr	322(ra) # 4ae <close>
  return r;
}
 374:	854a                	mv	a0,s2
 376:	60e2                	ld	ra,24(sp)
 378:	6442                	ld	s0,16(sp)
 37a:	64a2                	ld	s1,8(sp)
 37c:	6902                	ld	s2,0(sp)
 37e:	6105                	addi	sp,sp,32
 380:	8082                	ret
    return -1;
 382:	597d                	li	s2,-1
 384:	bfc5                	j	374 <stat+0x34>

0000000000000386 <atoi>:

int
atoi(const char *s)
{
 386:	1141                	addi	sp,sp,-16
 388:	e422                	sd	s0,8(sp)
 38a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 38c:	00054603          	lbu	a2,0(a0)
 390:	fd06079b          	addiw	a5,a2,-48
 394:	0ff7f793          	andi	a5,a5,255
 398:	4725                	li	a4,9
 39a:	02f76963          	bltu	a4,a5,3cc <atoi+0x46>
 39e:	86aa                	mv	a3,a0
  n = 0;
 3a0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3a2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3a4:	0685                	addi	a3,a3,1
 3a6:	0025179b          	slliw	a5,a0,0x2
 3aa:	9fa9                	addw	a5,a5,a0
 3ac:	0017979b          	slliw	a5,a5,0x1
 3b0:	9fb1                	addw	a5,a5,a2
 3b2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3b6:	0006c603          	lbu	a2,0(a3)
 3ba:	fd06071b          	addiw	a4,a2,-48
 3be:	0ff77713          	andi	a4,a4,255
 3c2:	fee5f1e3          	bgeu	a1,a4,3a4 <atoi+0x1e>
  return n;
}
 3c6:	6422                	ld	s0,8(sp)
 3c8:	0141                	addi	sp,sp,16
 3ca:	8082                	ret
  n = 0;
 3cc:	4501                	li	a0,0
 3ce:	bfe5                	j	3c6 <atoi+0x40>

00000000000003d0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3d0:	1141                	addi	sp,sp,-16
 3d2:	e422                	sd	s0,8(sp)
 3d4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3d6:	02b57663          	bgeu	a0,a1,402 <memmove+0x32>
    while(n-- > 0)
 3da:	02c05163          	blez	a2,3fc <memmove+0x2c>
 3de:	fff6079b          	addiw	a5,a2,-1
 3e2:	1782                	slli	a5,a5,0x20
 3e4:	9381                	srli	a5,a5,0x20
 3e6:	0785                	addi	a5,a5,1
 3e8:	97aa                	add	a5,a5,a0
  dst = vdst;
 3ea:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ec:	0585                	addi	a1,a1,1
 3ee:	0705                	addi	a4,a4,1
 3f0:	fff5c683          	lbu	a3,-1(a1)
 3f4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3f8:	fee79ae3          	bne	a5,a4,3ec <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3fc:	6422                	ld	s0,8(sp)
 3fe:	0141                	addi	sp,sp,16
 400:	8082                	ret
    dst += n;
 402:	00c50733          	add	a4,a0,a2
    src += n;
 406:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 408:	fec05ae3          	blez	a2,3fc <memmove+0x2c>
 40c:	fff6079b          	addiw	a5,a2,-1
 410:	1782                	slli	a5,a5,0x20
 412:	9381                	srli	a5,a5,0x20
 414:	fff7c793          	not	a5,a5
 418:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 41a:	15fd                	addi	a1,a1,-1
 41c:	177d                	addi	a4,a4,-1
 41e:	0005c683          	lbu	a3,0(a1)
 422:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 426:	fee79ae3          	bne	a5,a4,41a <memmove+0x4a>
 42a:	bfc9                	j	3fc <memmove+0x2c>

000000000000042c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 42c:	1141                	addi	sp,sp,-16
 42e:	e422                	sd	s0,8(sp)
 430:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 432:	ca05                	beqz	a2,462 <memcmp+0x36>
 434:	fff6069b          	addiw	a3,a2,-1
 438:	1682                	slli	a3,a3,0x20
 43a:	9281                	srli	a3,a3,0x20
 43c:	0685                	addi	a3,a3,1
 43e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 440:	00054783          	lbu	a5,0(a0)
 444:	0005c703          	lbu	a4,0(a1)
 448:	00e79863          	bne	a5,a4,458 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 44c:	0505                	addi	a0,a0,1
    p2++;
 44e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 450:	fed518e3          	bne	a0,a3,440 <memcmp+0x14>
  }
  return 0;
 454:	4501                	li	a0,0
 456:	a019                	j	45c <memcmp+0x30>
      return *p1 - *p2;
 458:	40e7853b          	subw	a0,a5,a4
}
 45c:	6422                	ld	s0,8(sp)
 45e:	0141                	addi	sp,sp,16
 460:	8082                	ret
  return 0;
 462:	4501                	li	a0,0
 464:	bfe5                	j	45c <memcmp+0x30>

0000000000000466 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 466:	1141                	addi	sp,sp,-16
 468:	e406                	sd	ra,8(sp)
 46a:	e022                	sd	s0,0(sp)
 46c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 46e:	00000097          	auipc	ra,0x0
 472:	f62080e7          	jalr	-158(ra) # 3d0 <memmove>
}
 476:	60a2                	ld	ra,8(sp)
 478:	6402                	ld	s0,0(sp)
 47a:	0141                	addi	sp,sp,16
 47c:	8082                	ret

000000000000047e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 47e:	4885                	li	a7,1
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <exit>:
.global exit
exit:
 li a7, SYS_exit
 486:	4889                	li	a7,2
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <wait>:
.global wait
wait:
 li a7, SYS_wait
 48e:	488d                	li	a7,3
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 496:	4891                	li	a7,4
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <read>:
.global read
read:
 li a7, SYS_read
 49e:	4895                	li	a7,5
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <write>:
.global write
write:
 li a7, SYS_write
 4a6:	48c1                	li	a7,16
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <close>:
.global close
close:
 li a7, SYS_close
 4ae:	48d5                	li	a7,21
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4b6:	4899                	li	a7,6
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <exec>:
.global exec
exec:
 li a7, SYS_exec
 4be:	489d                	li	a7,7
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <open>:
.global open
open:
 li a7, SYS_open
 4c6:	48bd                	li	a7,15
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4ce:	48c5                	li	a7,17
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4d6:	48c9                	li	a7,18
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4de:	48a1                	li	a7,8
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <link>:
.global link
link:
 li a7, SYS_link
 4e6:	48cd                	li	a7,19
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4ee:	48d1                	li	a7,20
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4f6:	48a5                	li	a7,9
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <dup>:
.global dup
dup:
 li a7, SYS_dup
 4fe:	48a9                	li	a7,10
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 506:	48ad                	li	a7,11
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 50e:	48b1                	li	a7,12
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 516:	48b5                	li	a7,13
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 51e:	48b9                	li	a7,14
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 526:	48d9                	li	a7,22
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <yield>:
.global yield
yield:
 li a7, SYS_yield
 52e:	48dd                	li	a7,23
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 536:	48e1                	li	a7,24
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 53e:	48e9                	li	a7,26
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 546:	48e5                	li	a7,25
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <ps>:
.global ps
ps:
 li a7, SYS_ps
 54e:	48ed                	li	a7,27
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 556:	48f1                	li	a7,28
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 55e:	1101                	addi	sp,sp,-32
 560:	ec06                	sd	ra,24(sp)
 562:	e822                	sd	s0,16(sp)
 564:	1000                	addi	s0,sp,32
 566:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 56a:	4605                	li	a2,1
 56c:	fef40593          	addi	a1,s0,-17
 570:	00000097          	auipc	ra,0x0
 574:	f36080e7          	jalr	-202(ra) # 4a6 <write>
}
 578:	60e2                	ld	ra,24(sp)
 57a:	6442                	ld	s0,16(sp)
 57c:	6105                	addi	sp,sp,32
 57e:	8082                	ret

0000000000000580 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 580:	7139                	addi	sp,sp,-64
 582:	fc06                	sd	ra,56(sp)
 584:	f822                	sd	s0,48(sp)
 586:	f426                	sd	s1,40(sp)
 588:	f04a                	sd	s2,32(sp)
 58a:	ec4e                	sd	s3,24(sp)
 58c:	0080                	addi	s0,sp,64
 58e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 590:	c299                	beqz	a3,596 <printint+0x16>
 592:	0805c863          	bltz	a1,622 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 596:	2581                	sext.w	a1,a1
  neg = 0;
 598:	4881                	li	a7,0
 59a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 59e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5a0:	2601                	sext.w	a2,a2
 5a2:	00000517          	auipc	a0,0x0
 5a6:	46e50513          	addi	a0,a0,1134 # a10 <digits>
 5aa:	883a                	mv	a6,a4
 5ac:	2705                	addiw	a4,a4,1
 5ae:	02c5f7bb          	remuw	a5,a1,a2
 5b2:	1782                	slli	a5,a5,0x20
 5b4:	9381                	srli	a5,a5,0x20
 5b6:	97aa                	add	a5,a5,a0
 5b8:	0007c783          	lbu	a5,0(a5)
 5bc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5c0:	0005879b          	sext.w	a5,a1
 5c4:	02c5d5bb          	divuw	a1,a1,a2
 5c8:	0685                	addi	a3,a3,1
 5ca:	fec7f0e3          	bgeu	a5,a2,5aa <printint+0x2a>
  if(neg)
 5ce:	00088b63          	beqz	a7,5e4 <printint+0x64>
    buf[i++] = '-';
 5d2:	fd040793          	addi	a5,s0,-48
 5d6:	973e                	add	a4,a4,a5
 5d8:	02d00793          	li	a5,45
 5dc:	fef70823          	sb	a5,-16(a4)
 5e0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5e4:	02e05863          	blez	a4,614 <printint+0x94>
 5e8:	fc040793          	addi	a5,s0,-64
 5ec:	00e78933          	add	s2,a5,a4
 5f0:	fff78993          	addi	s3,a5,-1
 5f4:	99ba                	add	s3,s3,a4
 5f6:	377d                	addiw	a4,a4,-1
 5f8:	1702                	slli	a4,a4,0x20
 5fa:	9301                	srli	a4,a4,0x20
 5fc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 600:	fff94583          	lbu	a1,-1(s2)
 604:	8526                	mv	a0,s1
 606:	00000097          	auipc	ra,0x0
 60a:	f58080e7          	jalr	-168(ra) # 55e <putc>
  while(--i >= 0)
 60e:	197d                	addi	s2,s2,-1
 610:	ff3918e3          	bne	s2,s3,600 <printint+0x80>
}
 614:	70e2                	ld	ra,56(sp)
 616:	7442                	ld	s0,48(sp)
 618:	74a2                	ld	s1,40(sp)
 61a:	7902                	ld	s2,32(sp)
 61c:	69e2                	ld	s3,24(sp)
 61e:	6121                	addi	sp,sp,64
 620:	8082                	ret
    x = -xx;
 622:	40b005bb          	negw	a1,a1
    neg = 1;
 626:	4885                	li	a7,1
    x = -xx;
 628:	bf8d                	j	59a <printint+0x1a>

000000000000062a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 62a:	7119                	addi	sp,sp,-128
 62c:	fc86                	sd	ra,120(sp)
 62e:	f8a2                	sd	s0,112(sp)
 630:	f4a6                	sd	s1,104(sp)
 632:	f0ca                	sd	s2,96(sp)
 634:	ecce                	sd	s3,88(sp)
 636:	e8d2                	sd	s4,80(sp)
 638:	e4d6                	sd	s5,72(sp)
 63a:	e0da                	sd	s6,64(sp)
 63c:	fc5e                	sd	s7,56(sp)
 63e:	f862                	sd	s8,48(sp)
 640:	f466                	sd	s9,40(sp)
 642:	f06a                	sd	s10,32(sp)
 644:	ec6e                	sd	s11,24(sp)
 646:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 648:	0005c903          	lbu	s2,0(a1)
 64c:	18090f63          	beqz	s2,7ea <vprintf+0x1c0>
 650:	8aaa                	mv	s5,a0
 652:	8b32                	mv	s6,a2
 654:	00158493          	addi	s1,a1,1
  state = 0;
 658:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 65a:	02500a13          	li	s4,37
      if(c == 'd'){
 65e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 662:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 666:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 66a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 66e:	00000b97          	auipc	s7,0x0
 672:	3a2b8b93          	addi	s7,s7,930 # a10 <digits>
 676:	a839                	j	694 <vprintf+0x6a>
        putc(fd, c);
 678:	85ca                	mv	a1,s2
 67a:	8556                	mv	a0,s5
 67c:	00000097          	auipc	ra,0x0
 680:	ee2080e7          	jalr	-286(ra) # 55e <putc>
 684:	a019                	j	68a <vprintf+0x60>
    } else if(state == '%'){
 686:	01498f63          	beq	s3,s4,6a4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 68a:	0485                	addi	s1,s1,1
 68c:	fff4c903          	lbu	s2,-1(s1)
 690:	14090d63          	beqz	s2,7ea <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 694:	0009079b          	sext.w	a5,s2
    if(state == 0){
 698:	fe0997e3          	bnez	s3,686 <vprintf+0x5c>
      if(c == '%'){
 69c:	fd479ee3          	bne	a5,s4,678 <vprintf+0x4e>
        state = '%';
 6a0:	89be                	mv	s3,a5
 6a2:	b7e5                	j	68a <vprintf+0x60>
      if(c == 'd'){
 6a4:	05878063          	beq	a5,s8,6e4 <vprintf+0xba>
      } else if(c == 'l') {
 6a8:	05978c63          	beq	a5,s9,700 <vprintf+0xd6>
      } else if(c == 'x') {
 6ac:	07a78863          	beq	a5,s10,71c <vprintf+0xf2>
      } else if(c == 'p') {
 6b0:	09b78463          	beq	a5,s11,738 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6b4:	07300713          	li	a4,115
 6b8:	0ce78663          	beq	a5,a4,784 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6bc:	06300713          	li	a4,99
 6c0:	0ee78e63          	beq	a5,a4,7bc <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6c4:	11478863          	beq	a5,s4,7d4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6c8:	85d2                	mv	a1,s4
 6ca:	8556                	mv	a0,s5
 6cc:	00000097          	auipc	ra,0x0
 6d0:	e92080e7          	jalr	-366(ra) # 55e <putc>
        putc(fd, c);
 6d4:	85ca                	mv	a1,s2
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	e86080e7          	jalr	-378(ra) # 55e <putc>
      }
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	b765                	j	68a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6e4:	008b0913          	addi	s2,s6,8
 6e8:	4685                	li	a3,1
 6ea:	4629                	li	a2,10
 6ec:	000b2583          	lw	a1,0(s6)
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	e8e080e7          	jalr	-370(ra) # 580 <printint>
 6fa:	8b4a                	mv	s6,s2
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	b771                	j	68a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 700:	008b0913          	addi	s2,s6,8
 704:	4681                	li	a3,0
 706:	4629                	li	a2,10
 708:	000b2583          	lw	a1,0(s6)
 70c:	8556                	mv	a0,s5
 70e:	00000097          	auipc	ra,0x0
 712:	e72080e7          	jalr	-398(ra) # 580 <printint>
 716:	8b4a                	mv	s6,s2
      state = 0;
 718:	4981                	li	s3,0
 71a:	bf85                	j	68a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 71c:	008b0913          	addi	s2,s6,8
 720:	4681                	li	a3,0
 722:	4641                	li	a2,16
 724:	000b2583          	lw	a1,0(s6)
 728:	8556                	mv	a0,s5
 72a:	00000097          	auipc	ra,0x0
 72e:	e56080e7          	jalr	-426(ra) # 580 <printint>
 732:	8b4a                	mv	s6,s2
      state = 0;
 734:	4981                	li	s3,0
 736:	bf91                	j	68a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 738:	008b0793          	addi	a5,s6,8
 73c:	f8f43423          	sd	a5,-120(s0)
 740:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 744:	03000593          	li	a1,48
 748:	8556                	mv	a0,s5
 74a:	00000097          	auipc	ra,0x0
 74e:	e14080e7          	jalr	-492(ra) # 55e <putc>
  putc(fd, 'x');
 752:	85ea                	mv	a1,s10
 754:	8556                	mv	a0,s5
 756:	00000097          	auipc	ra,0x0
 75a:	e08080e7          	jalr	-504(ra) # 55e <putc>
 75e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 760:	03c9d793          	srli	a5,s3,0x3c
 764:	97de                	add	a5,a5,s7
 766:	0007c583          	lbu	a1,0(a5)
 76a:	8556                	mv	a0,s5
 76c:	00000097          	auipc	ra,0x0
 770:	df2080e7          	jalr	-526(ra) # 55e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 774:	0992                	slli	s3,s3,0x4
 776:	397d                	addiw	s2,s2,-1
 778:	fe0914e3          	bnez	s2,760 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 77c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 780:	4981                	li	s3,0
 782:	b721                	j	68a <vprintf+0x60>
        s = va_arg(ap, char*);
 784:	008b0993          	addi	s3,s6,8
 788:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 78c:	02090163          	beqz	s2,7ae <vprintf+0x184>
        while(*s != 0){
 790:	00094583          	lbu	a1,0(s2)
 794:	c9a1                	beqz	a1,7e4 <vprintf+0x1ba>
          putc(fd, *s);
 796:	8556                	mv	a0,s5
 798:	00000097          	auipc	ra,0x0
 79c:	dc6080e7          	jalr	-570(ra) # 55e <putc>
          s++;
 7a0:	0905                	addi	s2,s2,1
        while(*s != 0){
 7a2:	00094583          	lbu	a1,0(s2)
 7a6:	f9e5                	bnez	a1,796 <vprintf+0x16c>
        s = va_arg(ap, char*);
 7a8:	8b4e                	mv	s6,s3
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	bdf9                	j	68a <vprintf+0x60>
          s = "(null)";
 7ae:	00000917          	auipc	s2,0x0
 7b2:	25a90913          	addi	s2,s2,602 # a08 <malloc+0x114>
        while(*s != 0){
 7b6:	02800593          	li	a1,40
 7ba:	bff1                	j	796 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7bc:	008b0913          	addi	s2,s6,8
 7c0:	000b4583          	lbu	a1,0(s6)
 7c4:	8556                	mv	a0,s5
 7c6:	00000097          	auipc	ra,0x0
 7ca:	d98080e7          	jalr	-616(ra) # 55e <putc>
 7ce:	8b4a                	mv	s6,s2
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	bd65                	j	68a <vprintf+0x60>
        putc(fd, c);
 7d4:	85d2                	mv	a1,s4
 7d6:	8556                	mv	a0,s5
 7d8:	00000097          	auipc	ra,0x0
 7dc:	d86080e7          	jalr	-634(ra) # 55e <putc>
      state = 0;
 7e0:	4981                	li	s3,0
 7e2:	b565                	j	68a <vprintf+0x60>
        s = va_arg(ap, char*);
 7e4:	8b4e                	mv	s6,s3
      state = 0;
 7e6:	4981                	li	s3,0
 7e8:	b54d                	j	68a <vprintf+0x60>
    }
  }
}
 7ea:	70e6                	ld	ra,120(sp)
 7ec:	7446                	ld	s0,112(sp)
 7ee:	74a6                	ld	s1,104(sp)
 7f0:	7906                	ld	s2,96(sp)
 7f2:	69e6                	ld	s3,88(sp)
 7f4:	6a46                	ld	s4,80(sp)
 7f6:	6aa6                	ld	s5,72(sp)
 7f8:	6b06                	ld	s6,64(sp)
 7fa:	7be2                	ld	s7,56(sp)
 7fc:	7c42                	ld	s8,48(sp)
 7fe:	7ca2                	ld	s9,40(sp)
 800:	7d02                	ld	s10,32(sp)
 802:	6de2                	ld	s11,24(sp)
 804:	6109                	addi	sp,sp,128
 806:	8082                	ret

0000000000000808 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 808:	715d                	addi	sp,sp,-80
 80a:	ec06                	sd	ra,24(sp)
 80c:	e822                	sd	s0,16(sp)
 80e:	1000                	addi	s0,sp,32
 810:	e010                	sd	a2,0(s0)
 812:	e414                	sd	a3,8(s0)
 814:	e818                	sd	a4,16(s0)
 816:	ec1c                	sd	a5,24(s0)
 818:	03043023          	sd	a6,32(s0)
 81c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 820:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 824:	8622                	mv	a2,s0
 826:	00000097          	auipc	ra,0x0
 82a:	e04080e7          	jalr	-508(ra) # 62a <vprintf>
}
 82e:	60e2                	ld	ra,24(sp)
 830:	6442                	ld	s0,16(sp)
 832:	6161                	addi	sp,sp,80
 834:	8082                	ret

0000000000000836 <printf>:

void
printf(const char *fmt, ...)
{
 836:	711d                	addi	sp,sp,-96
 838:	ec06                	sd	ra,24(sp)
 83a:	e822                	sd	s0,16(sp)
 83c:	1000                	addi	s0,sp,32
 83e:	e40c                	sd	a1,8(s0)
 840:	e810                	sd	a2,16(s0)
 842:	ec14                	sd	a3,24(s0)
 844:	f018                	sd	a4,32(s0)
 846:	f41c                	sd	a5,40(s0)
 848:	03043823          	sd	a6,48(s0)
 84c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 850:	00840613          	addi	a2,s0,8
 854:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 858:	85aa                	mv	a1,a0
 85a:	4505                	li	a0,1
 85c:	00000097          	auipc	ra,0x0
 860:	dce080e7          	jalr	-562(ra) # 62a <vprintf>
}
 864:	60e2                	ld	ra,24(sp)
 866:	6442                	ld	s0,16(sp)
 868:	6125                	addi	sp,sp,96
 86a:	8082                	ret

000000000000086c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 86c:	1141                	addi	sp,sp,-16
 86e:	e422                	sd	s0,8(sp)
 870:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 872:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 876:	00000797          	auipc	a5,0x0
 87a:	1b27b783          	ld	a5,434(a5) # a28 <freep>
 87e:	a805                	j	8ae <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 880:	4618                	lw	a4,8(a2)
 882:	9db9                	addw	a1,a1,a4
 884:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 888:	6398                	ld	a4,0(a5)
 88a:	6318                	ld	a4,0(a4)
 88c:	fee53823          	sd	a4,-16(a0)
 890:	a091                	j	8d4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 892:	ff852703          	lw	a4,-8(a0)
 896:	9e39                	addw	a2,a2,a4
 898:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 89a:	ff053703          	ld	a4,-16(a0)
 89e:	e398                	sd	a4,0(a5)
 8a0:	a099                	j	8e6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a2:	6398                	ld	a4,0(a5)
 8a4:	00e7e463          	bltu	a5,a4,8ac <free+0x40>
 8a8:	00e6ea63          	bltu	a3,a4,8bc <free+0x50>
{
 8ac:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ae:	fed7fae3          	bgeu	a5,a3,8a2 <free+0x36>
 8b2:	6398                	ld	a4,0(a5)
 8b4:	00e6e463          	bltu	a3,a4,8bc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b8:	fee7eae3          	bltu	a5,a4,8ac <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8bc:	ff852583          	lw	a1,-8(a0)
 8c0:	6390                	ld	a2,0(a5)
 8c2:	02059713          	slli	a4,a1,0x20
 8c6:	9301                	srli	a4,a4,0x20
 8c8:	0712                	slli	a4,a4,0x4
 8ca:	9736                	add	a4,a4,a3
 8cc:	fae60ae3          	beq	a2,a4,880 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8d0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8d4:	4790                	lw	a2,8(a5)
 8d6:	02061713          	slli	a4,a2,0x20
 8da:	9301                	srli	a4,a4,0x20
 8dc:	0712                	slli	a4,a4,0x4
 8de:	973e                	add	a4,a4,a5
 8e0:	fae689e3          	beq	a3,a4,892 <free+0x26>
  } else
    p->s.ptr = bp;
 8e4:	e394                	sd	a3,0(a5)
  freep = p;
 8e6:	00000717          	auipc	a4,0x0
 8ea:	14f73123          	sd	a5,322(a4) # a28 <freep>
}
 8ee:	6422                	ld	s0,8(sp)
 8f0:	0141                	addi	sp,sp,16
 8f2:	8082                	ret

00000000000008f4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8f4:	7139                	addi	sp,sp,-64
 8f6:	fc06                	sd	ra,56(sp)
 8f8:	f822                	sd	s0,48(sp)
 8fa:	f426                	sd	s1,40(sp)
 8fc:	f04a                	sd	s2,32(sp)
 8fe:	ec4e                	sd	s3,24(sp)
 900:	e852                	sd	s4,16(sp)
 902:	e456                	sd	s5,8(sp)
 904:	e05a                	sd	s6,0(sp)
 906:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 908:	02051493          	slli	s1,a0,0x20
 90c:	9081                	srli	s1,s1,0x20
 90e:	04bd                	addi	s1,s1,15
 910:	8091                	srli	s1,s1,0x4
 912:	0014899b          	addiw	s3,s1,1
 916:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 918:	00000517          	auipc	a0,0x0
 91c:	11053503          	ld	a0,272(a0) # a28 <freep>
 920:	c515                	beqz	a0,94c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 922:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 924:	4798                	lw	a4,8(a5)
 926:	02977f63          	bgeu	a4,s1,964 <malloc+0x70>
 92a:	8a4e                	mv	s4,s3
 92c:	0009871b          	sext.w	a4,s3
 930:	6685                	lui	a3,0x1
 932:	00d77363          	bgeu	a4,a3,938 <malloc+0x44>
 936:	6a05                	lui	s4,0x1
 938:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 93c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 940:	00000917          	auipc	s2,0x0
 944:	0e890913          	addi	s2,s2,232 # a28 <freep>
  if(p == (char*)-1)
 948:	5afd                	li	s5,-1
 94a:	a88d                	j	9bc <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 94c:	00000797          	auipc	a5,0x0
 950:	0e478793          	addi	a5,a5,228 # a30 <base>
 954:	00000717          	auipc	a4,0x0
 958:	0cf73a23          	sd	a5,212(a4) # a28 <freep>
 95c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 95e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 962:	b7e1                	j	92a <malloc+0x36>
      if(p->s.size == nunits)
 964:	02e48b63          	beq	s1,a4,99a <malloc+0xa6>
        p->s.size -= nunits;
 968:	4137073b          	subw	a4,a4,s3
 96c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 96e:	1702                	slli	a4,a4,0x20
 970:	9301                	srli	a4,a4,0x20
 972:	0712                	slli	a4,a4,0x4
 974:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 976:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 97a:	00000717          	auipc	a4,0x0
 97e:	0aa73723          	sd	a0,174(a4) # a28 <freep>
      return (void*)(p + 1);
 982:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 986:	70e2                	ld	ra,56(sp)
 988:	7442                	ld	s0,48(sp)
 98a:	74a2                	ld	s1,40(sp)
 98c:	7902                	ld	s2,32(sp)
 98e:	69e2                	ld	s3,24(sp)
 990:	6a42                	ld	s4,16(sp)
 992:	6aa2                	ld	s5,8(sp)
 994:	6b02                	ld	s6,0(sp)
 996:	6121                	addi	sp,sp,64
 998:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 99a:	6398                	ld	a4,0(a5)
 99c:	e118                	sd	a4,0(a0)
 99e:	bff1                	j	97a <malloc+0x86>
  hp->s.size = nu;
 9a0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9a4:	0541                	addi	a0,a0,16
 9a6:	00000097          	auipc	ra,0x0
 9aa:	ec6080e7          	jalr	-314(ra) # 86c <free>
  return freep;
 9ae:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9b2:	d971                	beqz	a0,986 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9b6:	4798                	lw	a4,8(a5)
 9b8:	fa9776e3          	bgeu	a4,s1,964 <malloc+0x70>
    if(p == freep)
 9bc:	00093703          	ld	a4,0(s2)
 9c0:	853e                	mv	a0,a5
 9c2:	fef719e3          	bne	a4,a5,9b4 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9c6:	8552                	mv	a0,s4
 9c8:	00000097          	auipc	ra,0x0
 9cc:	b46080e7          	jalr	-1210(ra) # 50e <sbrk>
  if(p == (char*)-1)
 9d0:	fd5518e3          	bne	a0,s5,9a0 <malloc+0xac>
        return 0;
 9d4:	4501                	li	a0,0
 9d6:	bf45                	j	986 <malloc+0x92>
