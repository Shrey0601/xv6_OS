
user/_primefactors:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <func>:

int primes[]={2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97};

int count=0;

void func(int n){
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	e4a6                	sd	s1,72(sp)
   8:	e0ca                	sd	s2,64(sp)
   a:	fc4e                	sd	s3,56(sp)
   c:	1080                	addi	s0,sp,96
   e:	faa42623          	sw	a0,-84(s0)
    if(n==1 || count==25){
  12:	2501                	sext.w	a0,a0
  14:	4785                	li	a5,1
  16:	0af50b63          	beq	a0,a5,cc <func+0xcc>
  1a:	00001717          	auipc	a4,0x1
  1e:	af672703          	lw	a4,-1290(a4) # b10 <count>
  22:	47e5                	li	a5,25
  24:	0af70463          	beq	a4,a5,cc <func+0xcc>
        return;
    }
    else{
        int fd1[2], fd2[2];

        if (pipe(fd1) < 0) {
  28:	fc040513          	addi	a0,s0,-64
  2c:	00000097          	auipc	ra,0x0
  30:	4e4080e7          	jalr	1252(ra) # 510 <pipe>
  34:	0a054363          	bltz	a0,da <func+0xda>
           printf("Pipe 1 Failed");
           exit(0);
        }
        if (pipe(fd2) < 0) {
  38:	fc840513          	addi	a0,s0,-56
  3c:	00000097          	auipc	ra,0x0
  40:	4d4080e7          	jalr	1236(ra) # 510 <pipe>
  44:	0a054863          	bltz	a0,f4 <func+0xf4>
           printf("Pipe 2 Failed");
           exit(0);
        }
		int ret = fork();
  48:	00000097          	auipc	ra,0x0
  4c:	4b0080e7          	jalr	1200(ra) # 4f8 <fork>
		if(ret > 0){
  50:	0aa05f63          	blez	a0,10e <func+0x10e>
			write(fd1[1], &n, sizeof(n));
  54:	4611                	li	a2,4
  56:	fac40593          	addi	a1,s0,-84
  5a:	fc442503          	lw	a0,-60(s0)
  5e:	00000097          	auipc	ra,0x0
  62:	4c2080e7          	jalr	1218(ra) # 520 <write>
			wait(NULL);
  66:	4501                	li	a0,0
  68:	00000097          	auipc	ra,0x0
  6c:	4a0080e7          	jalr	1184(ra) # 508 <wait>
			read(fd2[0], &n, sizeof(n));
  70:	4611                	li	a2,4
  72:	fac40593          	addi	a1,s0,-84
  76:	fc842503          	lw	a0,-56(s0)
  7a:	00000097          	auipc	ra,0x0
  7e:	49e080e7          	jalr	1182(ra) # 518 <read>
			close(fd1[0]);
  82:	fc042503          	lw	a0,-64(s0)
  86:	00000097          	auipc	ra,0x0
  8a:	4a2080e7          	jalr	1186(ra) # 528 <close>
			close(fd1[1]);
  8e:	fc442503          	lw	a0,-60(s0)
  92:	00000097          	auipc	ra,0x0
  96:	496080e7          	jalr	1174(ra) # 528 <close>
			close(fd2[0]);
  9a:	fc842503          	lw	a0,-56(s0)
  9e:	00000097          	auipc	ra,0x0
  a2:	48a080e7          	jalr	1162(ra) # 528 <close>
			close(fd2[1]);
  a6:	fcc42503          	lw	a0,-52(s0)
  aa:	00000097          	auipc	ra,0x0
  ae:	47e080e7          	jalr	1150(ra) # 528 <close>
            count++;
  b2:	00001717          	auipc	a4,0x1
  b6:	a5e70713          	addi	a4,a4,-1442 # b10 <count>
  ba:	431c                	lw	a5,0(a4)
  bc:	2785                	addiw	a5,a5,1
  be:	c31c                	sw	a5,0(a4)
            return func(n);
  c0:	fac42503          	lw	a0,-84(s0)
  c4:	00000097          	auipc	ra,0x0
  c8:	f3c080e7          	jalr	-196(ra) # 0 <func>
			close(fd1[1]);
			close(fd2[1]);
			return;
		}
	}
}
  cc:	60e6                	ld	ra,88(sp)
  ce:	6446                	ld	s0,80(sp)
  d0:	64a6                	ld	s1,72(sp)
  d2:	6906                	ld	s2,64(sp)
  d4:	79e2                	ld	s3,56(sp)
  d6:	6125                	addi	sp,sp,96
  d8:	8082                	ret
           printf("Pipe 1 Failed");
  da:	00001517          	auipc	a0,0x1
  de:	97e50513          	addi	a0,a0,-1666 # a58 <malloc+0xea>
  e2:	00000097          	auipc	ra,0x0
  e6:	7ce080e7          	jalr	1998(ra) # 8b0 <printf>
           exit(0);
  ea:	4501                	li	a0,0
  ec:	00000097          	auipc	ra,0x0
  f0:	414080e7          	jalr	1044(ra) # 500 <exit>
           printf("Pipe 2 Failed");
  f4:	00001517          	auipc	a0,0x1
  f8:	97450513          	addi	a0,a0,-1676 # a68 <malloc+0xfa>
  fc:	00000097          	auipc	ra,0x0
 100:	7b4080e7          	jalr	1972(ra) # 8b0 <printf>
           exit(0);
 104:	4501                	li	a0,0
 106:	00000097          	auipc	ra,0x0
 10a:	3fa080e7          	jalr	1018(ra) # 500 <exit>
			read(fd1[0], &temp, sizeof(temp));
 10e:	4611                	li	a2,4
 110:	fbc40593          	addi	a1,s0,-68
 114:	fc042503          	lw	a0,-64(s0)
 118:	00000097          	auipc	ra,0x0
 11c:	400080e7          	jalr	1024(ra) # 518 <read>
            int div = primes[count];
 120:	00001797          	auipc	a5,0x1
 124:	9f07a783          	lw	a5,-1552(a5) # b10 <count>
 128:	00279713          	slli	a4,a5,0x2
 12c:	00001797          	auipc	a5,0x1
 130:	97c78793          	addi	a5,a5,-1668 # aa8 <primes>
 134:	97ba                	add	a5,a5,a4
 136:	4384                	lw	s1,0(a5)
			while(temp%div==0){
 138:	fbc42903          	lw	s2,-68(s0)
 13c:	0299693b          	remw	s2,s2,s1
 140:	02091863          	bnez	s2,170 <func+0x170>
                printf("%d ", div);
 144:	00001997          	auipc	s3,0x1
 148:	93498993          	addi	s3,s3,-1740 # a78 <malloc+0x10a>
 14c:	85a6                	mv	a1,s1
 14e:	854e                	mv	a0,s3
 150:	00000097          	auipc	ra,0x0
 154:	760080e7          	jalr	1888(ra) # 8b0 <printf>
                temp/=div;
 158:	fbc42783          	lw	a5,-68(s0)
 15c:	0297c7bb          	divw	a5,a5,s1
 160:	faf42e23          	sw	a5,-68(s0)
                num++;
 164:	2905                	addiw	s2,s2,1
			while(temp%div==0){
 166:	0297e7bb          	remw	a5,a5,s1
 16a:	d3ed                	beqz	a5,14c <func+0x14c>
            if(num>0){
 16c:	05204463          	bgtz	s2,1b4 <func+0x1b4>
			write(fd2[1], &temp, sizeof(temp));
 170:	4611                	li	a2,4
 172:	fbc40593          	addi	a1,s0,-68
 176:	fcc42503          	lw	a0,-52(s0)
 17a:	00000097          	auipc	ra,0x0
 17e:	3a6080e7          	jalr	934(ra) # 520 <write>
			close(fd1[0]);
 182:	fc042503          	lw	a0,-64(s0)
 186:	00000097          	auipc	ra,0x0
 18a:	3a2080e7          	jalr	930(ra) # 528 <close>
			close(fd2[0]);
 18e:	fc842503          	lw	a0,-56(s0)
 192:	00000097          	auipc	ra,0x0
 196:	396080e7          	jalr	918(ra) # 528 <close>
			close(fd1[1]);
 19a:	fc442503          	lw	a0,-60(s0)
 19e:	00000097          	auipc	ra,0x0
 1a2:	38a080e7          	jalr	906(ra) # 528 <close>
			close(fd2[1]);
 1a6:	fcc42503          	lw	a0,-52(s0)
 1aa:	00000097          	auipc	ra,0x0
 1ae:	37e080e7          	jalr	894(ra) # 528 <close>
			return;
 1b2:	bf29                	j	cc <func+0xcc>
                printf("[%d]\n", getpid());
 1b4:	00000097          	auipc	ra,0x0
 1b8:	3cc080e7          	jalr	972(ra) # 580 <getpid>
 1bc:	85aa                	mv	a1,a0
 1be:	00001517          	auipc	a0,0x1
 1c2:	8c250513          	addi	a0,a0,-1854 # a80 <malloc+0x112>
 1c6:	00000097          	auipc	ra,0x0
 1ca:	6ea080e7          	jalr	1770(ra) # 8b0 <printf>
 1ce:	b74d                	j	170 <func+0x170>

00000000000001d0 <main>:

int main(int argc, char* argv[]){
 1d0:	7139                	addi	sp,sp,-64
 1d2:	fc06                	sd	ra,56(sp)
 1d4:	f822                	sd	s0,48(sp)
 1d6:	f426                	sd	s1,40(sp)
 1d8:	f04a                	sd	s2,32(sp)
 1da:	ec4e                	sd	s3,24(sp)
 1dc:	e852                	sd	s4,16(sp)
 1de:	e456                	sd	s5,8(sp)
 1e0:	0080                	addi	s0,sp,64

    if(argc!=2){
 1e2:	4789                	li	a5,2
 1e4:	00f50763          	beq	a0,a5,1f2 <main+0x22>
        exit(0);
 1e8:	4501                	li	a0,0
 1ea:	00000097          	auipc	ra,0x0
 1ee:	316080e7          	jalr	790(ra) # 500 <exit>
    }
    else{
        int n = atoi(argv[1]);
 1f2:	6588                	ld	a0,8(a1)
 1f4:	00000097          	auipc	ra,0x0
 1f8:	20c080e7          	jalr	524(ra) # 400 <atoi>
 1fc:	84aa                	mv	s1,a0
        while(1){
            int num = 0;
            while(n%primes[count]==0){
 1fe:	00001917          	auipc	s2,0x1
 202:	91290913          	addi	s2,s2,-1774 # b10 <count>
 206:	00001997          	auipc	s3,0x1
 20a:	8a298993          	addi	s3,s3,-1886 # aa8 <primes>
                printf("%d ", primes[count]);
 20e:	00001a17          	auipc	s4,0x1
 212:	86aa0a13          	addi	s4,s4,-1942 # a78 <malloc+0x10a>
 216:	a021                	j	21e <main+0x4e>
            }
            if(num>0){
                printf("[%d]\n", getpid());
                break;
            }
            count++;
 218:	2705                	addiw	a4,a4,1
 21a:	00e92023          	sw	a4,0(s2)
            while(n%primes[count]==0){
 21e:	00092703          	lw	a4,0(s2)
 222:	00271793          	slli	a5,a4,0x2
 226:	97ce                	add	a5,a5,s3
 228:	438c                	lw	a1,0(a5)
 22a:	02b4eabb          	remw	s5,s1,a1
 22e:	fe0a95e3          	bnez	s5,218 <main+0x48>
                printf("%d ", primes[count]);
 232:	8552                	mv	a0,s4
 234:	00000097          	auipc	ra,0x0
 238:	67c080e7          	jalr	1660(ra) # 8b0 <printf>
                n/=primes[count];
 23c:	00092703          	lw	a4,0(s2)
 240:	00271793          	slli	a5,a4,0x2
 244:	97ce                	add	a5,a5,s3
 246:	438c                	lw	a1,0(a5)
 248:	02b4c7bb          	divw	a5,s1,a1
 24c:	0007849b          	sext.w	s1,a5
                num++;
 250:	2a85                	addiw	s5,s5,1
            while(n%primes[count]==0){
 252:	02b7e7bb          	remw	a5,a5,a1
 256:	dff1                	beqz	a5,232 <main+0x62>
            if(num>0){
 258:	fd5050e3          	blez	s5,218 <main+0x48>
                printf("[%d]\n", getpid());
 25c:	00000097          	auipc	ra,0x0
 260:	324080e7          	jalr	804(ra) # 580 <getpid>
 264:	85aa                	mv	a1,a0
 266:	00001517          	auipc	a0,0x1
 26a:	81a50513          	addi	a0,a0,-2022 # a80 <malloc+0x112>
 26e:	00000097          	auipc	ra,0x0
 272:	642080e7          	jalr	1602(ra) # 8b0 <printf>
        }

        func(n);
 276:	8526                	mv	a0,s1
 278:	00000097          	auipc	ra,0x0
 27c:	d88080e7          	jalr	-632(ra) # 0 <func>

    }


    exit(0);
 280:	4501                	li	a0,0
 282:	00000097          	auipc	ra,0x0
 286:	27e080e7          	jalr	638(ra) # 500 <exit>

000000000000028a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 28a:	1141                	addi	sp,sp,-16
 28c:	e422                	sd	s0,8(sp)
 28e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 290:	87aa                	mv	a5,a0
 292:	0585                	addi	a1,a1,1
 294:	0785                	addi	a5,a5,1
 296:	fff5c703          	lbu	a4,-1(a1)
 29a:	fee78fa3          	sb	a4,-1(a5)
 29e:	fb75                	bnez	a4,292 <strcpy+0x8>
    ;
  return os;
}
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret

00000000000002a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2a6:	1141                	addi	sp,sp,-16
 2a8:	e422                	sd	s0,8(sp)
 2aa:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	cb91                	beqz	a5,2c4 <strcmp+0x1e>
 2b2:	0005c703          	lbu	a4,0(a1)
 2b6:	00f71763          	bne	a4,a5,2c4 <strcmp+0x1e>
    p++, q++;
 2ba:	0505                	addi	a0,a0,1
 2bc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2be:	00054783          	lbu	a5,0(a0)
 2c2:	fbe5                	bnez	a5,2b2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2c4:	0005c503          	lbu	a0,0(a1)
}
 2c8:	40a7853b          	subw	a0,a5,a0
 2cc:	6422                	ld	s0,8(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret

00000000000002d2 <strlen>:

uint
strlen(const char *s)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e422                	sd	s0,8(sp)
 2d6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2d8:	00054783          	lbu	a5,0(a0)
 2dc:	cf91                	beqz	a5,2f8 <strlen+0x26>
 2de:	0505                	addi	a0,a0,1
 2e0:	87aa                	mv	a5,a0
 2e2:	4685                	li	a3,1
 2e4:	9e89                	subw	a3,a3,a0
 2e6:	00f6853b          	addw	a0,a3,a5
 2ea:	0785                	addi	a5,a5,1
 2ec:	fff7c703          	lbu	a4,-1(a5)
 2f0:	fb7d                	bnez	a4,2e6 <strlen+0x14>
    ;
  return n;
}
 2f2:	6422                	ld	s0,8(sp)
 2f4:	0141                	addi	sp,sp,16
 2f6:	8082                	ret
  for(n = 0; s[n]; n++)
 2f8:	4501                	li	a0,0
 2fa:	bfe5                	j	2f2 <strlen+0x20>

00000000000002fc <memset>:

void*
memset(void *dst, int c, uint n)
{
 2fc:	1141                	addi	sp,sp,-16
 2fe:	e422                	sd	s0,8(sp)
 300:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 302:	ce09                	beqz	a2,31c <memset+0x20>
 304:	87aa                	mv	a5,a0
 306:	fff6071b          	addiw	a4,a2,-1
 30a:	1702                	slli	a4,a4,0x20
 30c:	9301                	srli	a4,a4,0x20
 30e:	0705                	addi	a4,a4,1
 310:	972a                	add	a4,a4,a0
    cdst[i] = c;
 312:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 316:	0785                	addi	a5,a5,1
 318:	fee79de3          	bne	a5,a4,312 <memset+0x16>
  }
  return dst;
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret

0000000000000322 <strchr>:

char*
strchr(const char *s, char c)
{
 322:	1141                	addi	sp,sp,-16
 324:	e422                	sd	s0,8(sp)
 326:	0800                	addi	s0,sp,16
  for(; *s; s++)
 328:	00054783          	lbu	a5,0(a0)
 32c:	cb99                	beqz	a5,342 <strchr+0x20>
    if(*s == c)
 32e:	00f58763          	beq	a1,a5,33c <strchr+0x1a>
  for(; *s; s++)
 332:	0505                	addi	a0,a0,1
 334:	00054783          	lbu	a5,0(a0)
 338:	fbfd                	bnez	a5,32e <strchr+0xc>
      return (char*)s;
  return 0;
 33a:	4501                	li	a0,0
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
  return 0;
 342:	4501                	li	a0,0
 344:	bfe5                	j	33c <strchr+0x1a>

0000000000000346 <gets>:

char*
gets(char *buf, int max)
{
 346:	711d                	addi	sp,sp,-96
 348:	ec86                	sd	ra,88(sp)
 34a:	e8a2                	sd	s0,80(sp)
 34c:	e4a6                	sd	s1,72(sp)
 34e:	e0ca                	sd	s2,64(sp)
 350:	fc4e                	sd	s3,56(sp)
 352:	f852                	sd	s4,48(sp)
 354:	f456                	sd	s5,40(sp)
 356:	f05a                	sd	s6,32(sp)
 358:	ec5e                	sd	s7,24(sp)
 35a:	1080                	addi	s0,sp,96
 35c:	8baa                	mv	s7,a0
 35e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 360:	892a                	mv	s2,a0
 362:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 364:	4aa9                	li	s5,10
 366:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 368:	89a6                	mv	s3,s1
 36a:	2485                	addiw	s1,s1,1
 36c:	0344d863          	bge	s1,s4,39c <gets+0x56>
    cc = read(0, &c, 1);
 370:	4605                	li	a2,1
 372:	faf40593          	addi	a1,s0,-81
 376:	4501                	li	a0,0
 378:	00000097          	auipc	ra,0x0
 37c:	1a0080e7          	jalr	416(ra) # 518 <read>
    if(cc < 1)
 380:	00a05e63          	blez	a0,39c <gets+0x56>
    buf[i++] = c;
 384:	faf44783          	lbu	a5,-81(s0)
 388:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 38c:	01578763          	beq	a5,s5,39a <gets+0x54>
 390:	0905                	addi	s2,s2,1
 392:	fd679be3          	bne	a5,s6,368 <gets+0x22>
  for(i=0; i+1 < max; ){
 396:	89a6                	mv	s3,s1
 398:	a011                	j	39c <gets+0x56>
 39a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 39c:	99de                	add	s3,s3,s7
 39e:	00098023          	sb	zero,0(s3)
  return buf;
}
 3a2:	855e                	mv	a0,s7
 3a4:	60e6                	ld	ra,88(sp)
 3a6:	6446                	ld	s0,80(sp)
 3a8:	64a6                	ld	s1,72(sp)
 3aa:	6906                	ld	s2,64(sp)
 3ac:	79e2                	ld	s3,56(sp)
 3ae:	7a42                	ld	s4,48(sp)
 3b0:	7aa2                	ld	s5,40(sp)
 3b2:	7b02                	ld	s6,32(sp)
 3b4:	6be2                	ld	s7,24(sp)
 3b6:	6125                	addi	sp,sp,96
 3b8:	8082                	ret

00000000000003ba <stat>:

int
stat(const char *n, struct stat *st)
{
 3ba:	1101                	addi	sp,sp,-32
 3bc:	ec06                	sd	ra,24(sp)
 3be:	e822                	sd	s0,16(sp)
 3c0:	e426                	sd	s1,8(sp)
 3c2:	e04a                	sd	s2,0(sp)
 3c4:	1000                	addi	s0,sp,32
 3c6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3c8:	4581                	li	a1,0
 3ca:	00000097          	auipc	ra,0x0
 3ce:	176080e7          	jalr	374(ra) # 540 <open>
  if(fd < 0)
 3d2:	02054563          	bltz	a0,3fc <stat+0x42>
 3d6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3d8:	85ca                	mv	a1,s2
 3da:	00000097          	auipc	ra,0x0
 3de:	17e080e7          	jalr	382(ra) # 558 <fstat>
 3e2:	892a                	mv	s2,a0
  close(fd);
 3e4:	8526                	mv	a0,s1
 3e6:	00000097          	auipc	ra,0x0
 3ea:	142080e7          	jalr	322(ra) # 528 <close>
  return r;
}
 3ee:	854a                	mv	a0,s2
 3f0:	60e2                	ld	ra,24(sp)
 3f2:	6442                	ld	s0,16(sp)
 3f4:	64a2                	ld	s1,8(sp)
 3f6:	6902                	ld	s2,0(sp)
 3f8:	6105                	addi	sp,sp,32
 3fa:	8082                	ret
    return -1;
 3fc:	597d                	li	s2,-1
 3fe:	bfc5                	j	3ee <stat+0x34>

0000000000000400 <atoi>:

int
atoi(const char *s)
{
 400:	1141                	addi	sp,sp,-16
 402:	e422                	sd	s0,8(sp)
 404:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 406:	00054603          	lbu	a2,0(a0)
 40a:	fd06079b          	addiw	a5,a2,-48
 40e:	0ff7f793          	andi	a5,a5,255
 412:	4725                	li	a4,9
 414:	02f76963          	bltu	a4,a5,446 <atoi+0x46>
 418:	86aa                	mv	a3,a0
  n = 0;
 41a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 41c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 41e:	0685                	addi	a3,a3,1
 420:	0025179b          	slliw	a5,a0,0x2
 424:	9fa9                	addw	a5,a5,a0
 426:	0017979b          	slliw	a5,a5,0x1
 42a:	9fb1                	addw	a5,a5,a2
 42c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 430:	0006c603          	lbu	a2,0(a3)
 434:	fd06071b          	addiw	a4,a2,-48
 438:	0ff77713          	andi	a4,a4,255
 43c:	fee5f1e3          	bgeu	a1,a4,41e <atoi+0x1e>
  return n;
}
 440:	6422                	ld	s0,8(sp)
 442:	0141                	addi	sp,sp,16
 444:	8082                	ret
  n = 0;
 446:	4501                	li	a0,0
 448:	bfe5                	j	440 <atoi+0x40>

000000000000044a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 44a:	1141                	addi	sp,sp,-16
 44c:	e422                	sd	s0,8(sp)
 44e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 450:	02b57663          	bgeu	a0,a1,47c <memmove+0x32>
    while(n-- > 0)
 454:	02c05163          	blez	a2,476 <memmove+0x2c>
 458:	fff6079b          	addiw	a5,a2,-1
 45c:	1782                	slli	a5,a5,0x20
 45e:	9381                	srli	a5,a5,0x20
 460:	0785                	addi	a5,a5,1
 462:	97aa                	add	a5,a5,a0
  dst = vdst;
 464:	872a                	mv	a4,a0
      *dst++ = *src++;
 466:	0585                	addi	a1,a1,1
 468:	0705                	addi	a4,a4,1
 46a:	fff5c683          	lbu	a3,-1(a1)
 46e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 472:	fee79ae3          	bne	a5,a4,466 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 476:	6422                	ld	s0,8(sp)
 478:	0141                	addi	sp,sp,16
 47a:	8082                	ret
    dst += n;
 47c:	00c50733          	add	a4,a0,a2
    src += n;
 480:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 482:	fec05ae3          	blez	a2,476 <memmove+0x2c>
 486:	fff6079b          	addiw	a5,a2,-1
 48a:	1782                	slli	a5,a5,0x20
 48c:	9381                	srli	a5,a5,0x20
 48e:	fff7c793          	not	a5,a5
 492:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 494:	15fd                	addi	a1,a1,-1
 496:	177d                	addi	a4,a4,-1
 498:	0005c683          	lbu	a3,0(a1)
 49c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4a0:	fee79ae3          	bne	a5,a4,494 <memmove+0x4a>
 4a4:	bfc9                	j	476 <memmove+0x2c>

00000000000004a6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4a6:	1141                	addi	sp,sp,-16
 4a8:	e422                	sd	s0,8(sp)
 4aa:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4ac:	ca05                	beqz	a2,4dc <memcmp+0x36>
 4ae:	fff6069b          	addiw	a3,a2,-1
 4b2:	1682                	slli	a3,a3,0x20
 4b4:	9281                	srli	a3,a3,0x20
 4b6:	0685                	addi	a3,a3,1
 4b8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4ba:	00054783          	lbu	a5,0(a0)
 4be:	0005c703          	lbu	a4,0(a1)
 4c2:	00e79863          	bne	a5,a4,4d2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4c6:	0505                	addi	a0,a0,1
    p2++;
 4c8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4ca:	fed518e3          	bne	a0,a3,4ba <memcmp+0x14>
  }
  return 0;
 4ce:	4501                	li	a0,0
 4d0:	a019                	j	4d6 <memcmp+0x30>
      return *p1 - *p2;
 4d2:	40e7853b          	subw	a0,a5,a4
}
 4d6:	6422                	ld	s0,8(sp)
 4d8:	0141                	addi	sp,sp,16
 4da:	8082                	ret
  return 0;
 4dc:	4501                	li	a0,0
 4de:	bfe5                	j	4d6 <memcmp+0x30>

00000000000004e0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4e0:	1141                	addi	sp,sp,-16
 4e2:	e406                	sd	ra,8(sp)
 4e4:	e022                	sd	s0,0(sp)
 4e6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4e8:	00000097          	auipc	ra,0x0
 4ec:	f62080e7          	jalr	-158(ra) # 44a <memmove>
}
 4f0:	60a2                	ld	ra,8(sp)
 4f2:	6402                	ld	s0,0(sp)
 4f4:	0141                	addi	sp,sp,16
 4f6:	8082                	ret

00000000000004f8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4f8:	4885                	li	a7,1
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <exit>:
.global exit
exit:
 li a7, SYS_exit
 500:	4889                	li	a7,2
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <wait>:
.global wait
wait:
 li a7, SYS_wait
 508:	488d                	li	a7,3
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 510:	4891                	li	a7,4
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <read>:
.global read
read:
 li a7, SYS_read
 518:	4895                	li	a7,5
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <write>:
.global write
write:
 li a7, SYS_write
 520:	48c1                	li	a7,16
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <close>:
.global close
close:
 li a7, SYS_close
 528:	48d5                	li	a7,21
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <kill>:
.global kill
kill:
 li a7, SYS_kill
 530:	4899                	li	a7,6
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <exec>:
.global exec
exec:
 li a7, SYS_exec
 538:	489d                	li	a7,7
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <open>:
.global open
open:
 li a7, SYS_open
 540:	48bd                	li	a7,15
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 548:	48c5                	li	a7,17
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 550:	48c9                	li	a7,18
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 558:	48a1                	li	a7,8
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <link>:
.global link
link:
 li a7, SYS_link
 560:	48cd                	li	a7,19
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 568:	48d1                	li	a7,20
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 570:	48a5                	li	a7,9
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <dup>:
.global dup
dup:
 li a7, SYS_dup
 578:	48a9                	li	a7,10
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 580:	48ad                	li	a7,11
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 588:	48b1                	li	a7,12
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 590:	48b5                	li	a7,13
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 598:	48b9                	li	a7,14
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 5a0:	48d9                	li	a7,22
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <yield>:
.global yield
yield:
 li a7, SYS_yield
 5a8:	48dd                	li	a7,23
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 5b0:	48e1                	li	a7,24
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 5b8:	48e9                	li	a7,26
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 5c0:	48e5                	li	a7,25
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <ps>:
.global ps
ps:
 li a7, SYS_ps
 5c8:	48ed                	li	a7,27
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 5d0:	48f1                	li	a7,28
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5d8:	1101                	addi	sp,sp,-32
 5da:	ec06                	sd	ra,24(sp)
 5dc:	e822                	sd	s0,16(sp)
 5de:	1000                	addi	s0,sp,32
 5e0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5e4:	4605                	li	a2,1
 5e6:	fef40593          	addi	a1,s0,-17
 5ea:	00000097          	auipc	ra,0x0
 5ee:	f36080e7          	jalr	-202(ra) # 520 <write>
}
 5f2:	60e2                	ld	ra,24(sp)
 5f4:	6442                	ld	s0,16(sp)
 5f6:	6105                	addi	sp,sp,32
 5f8:	8082                	ret

00000000000005fa <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5fa:	7139                	addi	sp,sp,-64
 5fc:	fc06                	sd	ra,56(sp)
 5fe:	f822                	sd	s0,48(sp)
 600:	f426                	sd	s1,40(sp)
 602:	f04a                	sd	s2,32(sp)
 604:	ec4e                	sd	s3,24(sp)
 606:	0080                	addi	s0,sp,64
 608:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 60a:	c299                	beqz	a3,610 <printint+0x16>
 60c:	0805c863          	bltz	a1,69c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 610:	2581                	sext.w	a1,a1
  neg = 0;
 612:	4881                	li	a7,0
 614:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 618:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 61a:	2601                	sext.w	a2,a2
 61c:	00000517          	auipc	a0,0x0
 620:	47450513          	addi	a0,a0,1140 # a90 <digits>
 624:	883a                	mv	a6,a4
 626:	2705                	addiw	a4,a4,1
 628:	02c5f7bb          	remuw	a5,a1,a2
 62c:	1782                	slli	a5,a5,0x20
 62e:	9381                	srli	a5,a5,0x20
 630:	97aa                	add	a5,a5,a0
 632:	0007c783          	lbu	a5,0(a5)
 636:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 63a:	0005879b          	sext.w	a5,a1
 63e:	02c5d5bb          	divuw	a1,a1,a2
 642:	0685                	addi	a3,a3,1
 644:	fec7f0e3          	bgeu	a5,a2,624 <printint+0x2a>
  if(neg)
 648:	00088b63          	beqz	a7,65e <printint+0x64>
    buf[i++] = '-';
 64c:	fd040793          	addi	a5,s0,-48
 650:	973e                	add	a4,a4,a5
 652:	02d00793          	li	a5,45
 656:	fef70823          	sb	a5,-16(a4)
 65a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 65e:	02e05863          	blez	a4,68e <printint+0x94>
 662:	fc040793          	addi	a5,s0,-64
 666:	00e78933          	add	s2,a5,a4
 66a:	fff78993          	addi	s3,a5,-1
 66e:	99ba                	add	s3,s3,a4
 670:	377d                	addiw	a4,a4,-1
 672:	1702                	slli	a4,a4,0x20
 674:	9301                	srli	a4,a4,0x20
 676:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 67a:	fff94583          	lbu	a1,-1(s2)
 67e:	8526                	mv	a0,s1
 680:	00000097          	auipc	ra,0x0
 684:	f58080e7          	jalr	-168(ra) # 5d8 <putc>
  while(--i >= 0)
 688:	197d                	addi	s2,s2,-1
 68a:	ff3918e3          	bne	s2,s3,67a <printint+0x80>
}
 68e:	70e2                	ld	ra,56(sp)
 690:	7442                	ld	s0,48(sp)
 692:	74a2                	ld	s1,40(sp)
 694:	7902                	ld	s2,32(sp)
 696:	69e2                	ld	s3,24(sp)
 698:	6121                	addi	sp,sp,64
 69a:	8082                	ret
    x = -xx;
 69c:	40b005bb          	negw	a1,a1
    neg = 1;
 6a0:	4885                	li	a7,1
    x = -xx;
 6a2:	bf8d                	j	614 <printint+0x1a>

00000000000006a4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6a4:	7119                	addi	sp,sp,-128
 6a6:	fc86                	sd	ra,120(sp)
 6a8:	f8a2                	sd	s0,112(sp)
 6aa:	f4a6                	sd	s1,104(sp)
 6ac:	f0ca                	sd	s2,96(sp)
 6ae:	ecce                	sd	s3,88(sp)
 6b0:	e8d2                	sd	s4,80(sp)
 6b2:	e4d6                	sd	s5,72(sp)
 6b4:	e0da                	sd	s6,64(sp)
 6b6:	fc5e                	sd	s7,56(sp)
 6b8:	f862                	sd	s8,48(sp)
 6ba:	f466                	sd	s9,40(sp)
 6bc:	f06a                	sd	s10,32(sp)
 6be:	ec6e                	sd	s11,24(sp)
 6c0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6c2:	0005c903          	lbu	s2,0(a1)
 6c6:	18090f63          	beqz	s2,864 <vprintf+0x1c0>
 6ca:	8aaa                	mv	s5,a0
 6cc:	8b32                	mv	s6,a2
 6ce:	00158493          	addi	s1,a1,1
  state = 0;
 6d2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6d4:	02500a13          	li	s4,37
      if(c == 'd'){
 6d8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 6dc:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 6e0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 6e4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e8:	00000b97          	auipc	s7,0x0
 6ec:	3a8b8b93          	addi	s7,s7,936 # a90 <digits>
 6f0:	a839                	j	70e <vprintf+0x6a>
        putc(fd, c);
 6f2:	85ca                	mv	a1,s2
 6f4:	8556                	mv	a0,s5
 6f6:	00000097          	auipc	ra,0x0
 6fa:	ee2080e7          	jalr	-286(ra) # 5d8 <putc>
 6fe:	a019                	j	704 <vprintf+0x60>
    } else if(state == '%'){
 700:	01498f63          	beq	s3,s4,71e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 704:	0485                	addi	s1,s1,1
 706:	fff4c903          	lbu	s2,-1(s1)
 70a:	14090d63          	beqz	s2,864 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 70e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 712:	fe0997e3          	bnez	s3,700 <vprintf+0x5c>
      if(c == '%'){
 716:	fd479ee3          	bne	a5,s4,6f2 <vprintf+0x4e>
        state = '%';
 71a:	89be                	mv	s3,a5
 71c:	b7e5                	j	704 <vprintf+0x60>
      if(c == 'd'){
 71e:	05878063          	beq	a5,s8,75e <vprintf+0xba>
      } else if(c == 'l') {
 722:	05978c63          	beq	a5,s9,77a <vprintf+0xd6>
      } else if(c == 'x') {
 726:	07a78863          	beq	a5,s10,796 <vprintf+0xf2>
      } else if(c == 'p') {
 72a:	09b78463          	beq	a5,s11,7b2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 72e:	07300713          	li	a4,115
 732:	0ce78663          	beq	a5,a4,7fe <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 736:	06300713          	li	a4,99
 73a:	0ee78e63          	beq	a5,a4,836 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 73e:	11478863          	beq	a5,s4,84e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 742:	85d2                	mv	a1,s4
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	e92080e7          	jalr	-366(ra) # 5d8 <putc>
        putc(fd, c);
 74e:	85ca                	mv	a1,s2
 750:	8556                	mv	a0,s5
 752:	00000097          	auipc	ra,0x0
 756:	e86080e7          	jalr	-378(ra) # 5d8 <putc>
      }
      state = 0;
 75a:	4981                	li	s3,0
 75c:	b765                	j	704 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 75e:	008b0913          	addi	s2,s6,8
 762:	4685                	li	a3,1
 764:	4629                	li	a2,10
 766:	000b2583          	lw	a1,0(s6)
 76a:	8556                	mv	a0,s5
 76c:	00000097          	auipc	ra,0x0
 770:	e8e080e7          	jalr	-370(ra) # 5fa <printint>
 774:	8b4a                	mv	s6,s2
      state = 0;
 776:	4981                	li	s3,0
 778:	b771                	j	704 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 77a:	008b0913          	addi	s2,s6,8
 77e:	4681                	li	a3,0
 780:	4629                	li	a2,10
 782:	000b2583          	lw	a1,0(s6)
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	e72080e7          	jalr	-398(ra) # 5fa <printint>
 790:	8b4a                	mv	s6,s2
      state = 0;
 792:	4981                	li	s3,0
 794:	bf85                	j	704 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 796:	008b0913          	addi	s2,s6,8
 79a:	4681                	li	a3,0
 79c:	4641                	li	a2,16
 79e:	000b2583          	lw	a1,0(s6)
 7a2:	8556                	mv	a0,s5
 7a4:	00000097          	auipc	ra,0x0
 7a8:	e56080e7          	jalr	-426(ra) # 5fa <printint>
 7ac:	8b4a                	mv	s6,s2
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	bf91                	j	704 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7b2:	008b0793          	addi	a5,s6,8
 7b6:	f8f43423          	sd	a5,-120(s0)
 7ba:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7be:	03000593          	li	a1,48
 7c2:	8556                	mv	a0,s5
 7c4:	00000097          	auipc	ra,0x0
 7c8:	e14080e7          	jalr	-492(ra) # 5d8 <putc>
  putc(fd, 'x');
 7cc:	85ea                	mv	a1,s10
 7ce:	8556                	mv	a0,s5
 7d0:	00000097          	auipc	ra,0x0
 7d4:	e08080e7          	jalr	-504(ra) # 5d8 <putc>
 7d8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7da:	03c9d793          	srli	a5,s3,0x3c
 7de:	97de                	add	a5,a5,s7
 7e0:	0007c583          	lbu	a1,0(a5)
 7e4:	8556                	mv	a0,s5
 7e6:	00000097          	auipc	ra,0x0
 7ea:	df2080e7          	jalr	-526(ra) # 5d8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7ee:	0992                	slli	s3,s3,0x4
 7f0:	397d                	addiw	s2,s2,-1
 7f2:	fe0914e3          	bnez	s2,7da <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 7f6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	b721                	j	704 <vprintf+0x60>
        s = va_arg(ap, char*);
 7fe:	008b0993          	addi	s3,s6,8
 802:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 806:	02090163          	beqz	s2,828 <vprintf+0x184>
        while(*s != 0){
 80a:	00094583          	lbu	a1,0(s2)
 80e:	c9a1                	beqz	a1,85e <vprintf+0x1ba>
          putc(fd, *s);
 810:	8556                	mv	a0,s5
 812:	00000097          	auipc	ra,0x0
 816:	dc6080e7          	jalr	-570(ra) # 5d8 <putc>
          s++;
 81a:	0905                	addi	s2,s2,1
        while(*s != 0){
 81c:	00094583          	lbu	a1,0(s2)
 820:	f9e5                	bnez	a1,810 <vprintf+0x16c>
        s = va_arg(ap, char*);
 822:	8b4e                	mv	s6,s3
      state = 0;
 824:	4981                	li	s3,0
 826:	bdf9                	j	704 <vprintf+0x60>
          s = "(null)";
 828:	00000917          	auipc	s2,0x0
 82c:	26090913          	addi	s2,s2,608 # a88 <malloc+0x11a>
        while(*s != 0){
 830:	02800593          	li	a1,40
 834:	bff1                	j	810 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 836:	008b0913          	addi	s2,s6,8
 83a:	000b4583          	lbu	a1,0(s6)
 83e:	8556                	mv	a0,s5
 840:	00000097          	auipc	ra,0x0
 844:	d98080e7          	jalr	-616(ra) # 5d8 <putc>
 848:	8b4a                	mv	s6,s2
      state = 0;
 84a:	4981                	li	s3,0
 84c:	bd65                	j	704 <vprintf+0x60>
        putc(fd, c);
 84e:	85d2                	mv	a1,s4
 850:	8556                	mv	a0,s5
 852:	00000097          	auipc	ra,0x0
 856:	d86080e7          	jalr	-634(ra) # 5d8 <putc>
      state = 0;
 85a:	4981                	li	s3,0
 85c:	b565                	j	704 <vprintf+0x60>
        s = va_arg(ap, char*);
 85e:	8b4e                	mv	s6,s3
      state = 0;
 860:	4981                	li	s3,0
 862:	b54d                	j	704 <vprintf+0x60>
    }
  }
}
 864:	70e6                	ld	ra,120(sp)
 866:	7446                	ld	s0,112(sp)
 868:	74a6                	ld	s1,104(sp)
 86a:	7906                	ld	s2,96(sp)
 86c:	69e6                	ld	s3,88(sp)
 86e:	6a46                	ld	s4,80(sp)
 870:	6aa6                	ld	s5,72(sp)
 872:	6b06                	ld	s6,64(sp)
 874:	7be2                	ld	s7,56(sp)
 876:	7c42                	ld	s8,48(sp)
 878:	7ca2                	ld	s9,40(sp)
 87a:	7d02                	ld	s10,32(sp)
 87c:	6de2                	ld	s11,24(sp)
 87e:	6109                	addi	sp,sp,128
 880:	8082                	ret

0000000000000882 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 882:	715d                	addi	sp,sp,-80
 884:	ec06                	sd	ra,24(sp)
 886:	e822                	sd	s0,16(sp)
 888:	1000                	addi	s0,sp,32
 88a:	e010                	sd	a2,0(s0)
 88c:	e414                	sd	a3,8(s0)
 88e:	e818                	sd	a4,16(s0)
 890:	ec1c                	sd	a5,24(s0)
 892:	03043023          	sd	a6,32(s0)
 896:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 89a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 89e:	8622                	mv	a2,s0
 8a0:	00000097          	auipc	ra,0x0
 8a4:	e04080e7          	jalr	-508(ra) # 6a4 <vprintf>
}
 8a8:	60e2                	ld	ra,24(sp)
 8aa:	6442                	ld	s0,16(sp)
 8ac:	6161                	addi	sp,sp,80
 8ae:	8082                	ret

00000000000008b0 <printf>:

void
printf(const char *fmt, ...)
{
 8b0:	711d                	addi	sp,sp,-96
 8b2:	ec06                	sd	ra,24(sp)
 8b4:	e822                	sd	s0,16(sp)
 8b6:	1000                	addi	s0,sp,32
 8b8:	e40c                	sd	a1,8(s0)
 8ba:	e810                	sd	a2,16(s0)
 8bc:	ec14                	sd	a3,24(s0)
 8be:	f018                	sd	a4,32(s0)
 8c0:	f41c                	sd	a5,40(s0)
 8c2:	03043823          	sd	a6,48(s0)
 8c6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8ca:	00840613          	addi	a2,s0,8
 8ce:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8d2:	85aa                	mv	a1,a0
 8d4:	4505                	li	a0,1
 8d6:	00000097          	auipc	ra,0x0
 8da:	dce080e7          	jalr	-562(ra) # 6a4 <vprintf>
}
 8de:	60e2                	ld	ra,24(sp)
 8e0:	6442                	ld	s0,16(sp)
 8e2:	6125                	addi	sp,sp,96
 8e4:	8082                	ret

00000000000008e6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8e6:	1141                	addi	sp,sp,-16
 8e8:	e422                	sd	s0,8(sp)
 8ea:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8ec:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f0:	00000797          	auipc	a5,0x0
 8f4:	2287b783          	ld	a5,552(a5) # b18 <freep>
 8f8:	a805                	j	928 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8fa:	4618                	lw	a4,8(a2)
 8fc:	9db9                	addw	a1,a1,a4
 8fe:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 902:	6398                	ld	a4,0(a5)
 904:	6318                	ld	a4,0(a4)
 906:	fee53823          	sd	a4,-16(a0)
 90a:	a091                	j	94e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 90c:	ff852703          	lw	a4,-8(a0)
 910:	9e39                	addw	a2,a2,a4
 912:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 914:	ff053703          	ld	a4,-16(a0)
 918:	e398                	sd	a4,0(a5)
 91a:	a099                	j	960 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 91c:	6398                	ld	a4,0(a5)
 91e:	00e7e463          	bltu	a5,a4,926 <free+0x40>
 922:	00e6ea63          	bltu	a3,a4,936 <free+0x50>
{
 926:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 928:	fed7fae3          	bgeu	a5,a3,91c <free+0x36>
 92c:	6398                	ld	a4,0(a5)
 92e:	00e6e463          	bltu	a3,a4,936 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 932:	fee7eae3          	bltu	a5,a4,926 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 936:	ff852583          	lw	a1,-8(a0)
 93a:	6390                	ld	a2,0(a5)
 93c:	02059713          	slli	a4,a1,0x20
 940:	9301                	srli	a4,a4,0x20
 942:	0712                	slli	a4,a4,0x4
 944:	9736                	add	a4,a4,a3
 946:	fae60ae3          	beq	a2,a4,8fa <free+0x14>
    bp->s.ptr = p->s.ptr;
 94a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 94e:	4790                	lw	a2,8(a5)
 950:	02061713          	slli	a4,a2,0x20
 954:	9301                	srli	a4,a4,0x20
 956:	0712                	slli	a4,a4,0x4
 958:	973e                	add	a4,a4,a5
 95a:	fae689e3          	beq	a3,a4,90c <free+0x26>
  } else
    p->s.ptr = bp;
 95e:	e394                	sd	a3,0(a5)
  freep = p;
 960:	00000717          	auipc	a4,0x0
 964:	1af73c23          	sd	a5,440(a4) # b18 <freep>
}
 968:	6422                	ld	s0,8(sp)
 96a:	0141                	addi	sp,sp,16
 96c:	8082                	ret

000000000000096e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 96e:	7139                	addi	sp,sp,-64
 970:	fc06                	sd	ra,56(sp)
 972:	f822                	sd	s0,48(sp)
 974:	f426                	sd	s1,40(sp)
 976:	f04a                	sd	s2,32(sp)
 978:	ec4e                	sd	s3,24(sp)
 97a:	e852                	sd	s4,16(sp)
 97c:	e456                	sd	s5,8(sp)
 97e:	e05a                	sd	s6,0(sp)
 980:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 982:	02051493          	slli	s1,a0,0x20
 986:	9081                	srli	s1,s1,0x20
 988:	04bd                	addi	s1,s1,15
 98a:	8091                	srli	s1,s1,0x4
 98c:	0014899b          	addiw	s3,s1,1
 990:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 992:	00000517          	auipc	a0,0x0
 996:	18653503          	ld	a0,390(a0) # b18 <freep>
 99a:	c515                	beqz	a0,9c6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 99e:	4798                	lw	a4,8(a5)
 9a0:	02977f63          	bgeu	a4,s1,9de <malloc+0x70>
 9a4:	8a4e                	mv	s4,s3
 9a6:	0009871b          	sext.w	a4,s3
 9aa:	6685                	lui	a3,0x1
 9ac:	00d77363          	bgeu	a4,a3,9b2 <malloc+0x44>
 9b0:	6a05                	lui	s4,0x1
 9b2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9b6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9ba:	00000917          	auipc	s2,0x0
 9be:	15e90913          	addi	s2,s2,350 # b18 <freep>
  if(p == (char*)-1)
 9c2:	5afd                	li	s5,-1
 9c4:	a88d                	j	a36 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 9c6:	00000797          	auipc	a5,0x0
 9ca:	15a78793          	addi	a5,a5,346 # b20 <base>
 9ce:	00000717          	auipc	a4,0x0
 9d2:	14f73523          	sd	a5,330(a4) # b18 <freep>
 9d6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9d8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9dc:	b7e1                	j	9a4 <malloc+0x36>
      if(p->s.size == nunits)
 9de:	02e48b63          	beq	s1,a4,a14 <malloc+0xa6>
        p->s.size -= nunits;
 9e2:	4137073b          	subw	a4,a4,s3
 9e6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9e8:	1702                	slli	a4,a4,0x20
 9ea:	9301                	srli	a4,a4,0x20
 9ec:	0712                	slli	a4,a4,0x4
 9ee:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9f0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9f4:	00000717          	auipc	a4,0x0
 9f8:	12a73223          	sd	a0,292(a4) # b18 <freep>
      return (void*)(p + 1);
 9fc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a00:	70e2                	ld	ra,56(sp)
 a02:	7442                	ld	s0,48(sp)
 a04:	74a2                	ld	s1,40(sp)
 a06:	7902                	ld	s2,32(sp)
 a08:	69e2                	ld	s3,24(sp)
 a0a:	6a42                	ld	s4,16(sp)
 a0c:	6aa2                	ld	s5,8(sp)
 a0e:	6b02                	ld	s6,0(sp)
 a10:	6121                	addi	sp,sp,64
 a12:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a14:	6398                	ld	a4,0(a5)
 a16:	e118                	sd	a4,0(a0)
 a18:	bff1                	j	9f4 <malloc+0x86>
  hp->s.size = nu;
 a1a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a1e:	0541                	addi	a0,a0,16
 a20:	00000097          	auipc	ra,0x0
 a24:	ec6080e7          	jalr	-314(ra) # 8e6 <free>
  return freep;
 a28:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a2c:	d971                	beqz	a0,a00 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a2e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a30:	4798                	lw	a4,8(a5)
 a32:	fa9776e3          	bgeu	a4,s1,9de <malloc+0x70>
    if(p == freep)
 a36:	00093703          	ld	a4,0(s2)
 a3a:	853e                	mv	a0,a5
 a3c:	fef719e3          	bne	a4,a5,a2e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a40:	8552                	mv	a0,s4
 a42:	00000097          	auipc	ra,0x0
 a46:	b46080e7          	jalr	-1210(ra) # 588 <sbrk>
  if(p == (char*)-1)
 a4a:	fd5518e3          	bne	a0,s5,a1a <malloc+0xac>
        return 0;
 a4e:	4501                	li	a0,0
 a50:	bf45                	j	a00 <malloc+0x92>
