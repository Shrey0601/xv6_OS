
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <__global_pointer$+0x1d454>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <__global_pointer$+0x22de>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <__global_pointer$+0xffffffffffffd623>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00001517          	auipc	a0,0x1
      64:	67050513          	addi	a0,a0,1648 # 16d0 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	addi	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	addi	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	e8ca                	sd	s2,80(sp)
      82:	e4ce                	sd	s3,72(sp)
      84:	e0d2                	sd	s4,64(sp)
      86:	fc56                	sd	s5,56(sp)
      88:	f85a                	sd	s6,48(sp)
      8a:	1880                	addi	s0,sp,112
      8c:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8e:	4501                	li	a0,0
      90:	00001097          	auipc	ra,0x1
      94:	e5e080e7          	jalr	-418(ra) # eee <sbrk>
      98:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      9a:	00001517          	auipc	a0,0x1
      9e:	32e50513          	addi	a0,a0,814 # 13c8 <malloc+0xe4>
      a2:	00001097          	auipc	ra,0x1
      a6:	e2c080e7          	jalr	-468(ra) # ece <mkdir>
  if(chdir("grindir") != 0){
      aa:	00001517          	auipc	a0,0x1
      ae:	31e50513          	addi	a0,a0,798 # 13c8 <malloc+0xe4>
      b2:	00001097          	auipc	ra,0x1
      b6:	e24080e7          	jalr	-476(ra) # ed6 <chdir>
      ba:	cd11                	beqz	a0,d6 <go+0x5e>
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	31450513          	addi	a0,a0,788 # 13d0 <malloc+0xec>
      c4:	00001097          	auipc	ra,0x1
      c8:	162080e7          	jalr	354(ra) # 1226 <printf>
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	d98080e7          	jalr	-616(ra) # e66 <exit>
  }
  chdir("/");
      d6:	00001517          	auipc	a0,0x1
      da:	31a50513          	addi	a0,a0,794 # 13f0 <malloc+0x10c>
      de:	00001097          	auipc	ra,0x1
      e2:	df8080e7          	jalr	-520(ra) # ed6 <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      e6:	00001997          	auipc	s3,0x1
      ea:	31a98993          	addi	s3,s3,794 # 1400 <malloc+0x11c>
      ee:	c489                	beqz	s1,f8 <go+0x80>
      f0:	00001997          	auipc	s3,0x1
      f4:	30898993          	addi	s3,s3,776 # 13f8 <malloc+0x114>
    iters++;
      f8:	4485                	li	s1,1
  int fd = -1;
      fa:	597d                	li	s2,-1
      close(fd);
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
      fc:	00001a17          	auipc	s4,0x1
     100:	5e4a0a13          	addi	s4,s4,1508 # 16e0 <buf.1258>
     104:	a825                	j	13c <go+0xc4>
      close(open("grindir/../a", O_CREATE|O_RDWR));
     106:	20200593          	li	a1,514
     10a:	00001517          	auipc	a0,0x1
     10e:	2fe50513          	addi	a0,a0,766 # 1408 <malloc+0x124>
     112:	00001097          	auipc	ra,0x1
     116:	d94080e7          	jalr	-620(ra) # ea6 <open>
     11a:	00001097          	auipc	ra,0x1
     11e:	d74080e7          	jalr	-652(ra) # e8e <close>
    iters++;
     122:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     124:	1f400793          	li	a5,500
     128:	02f4f7b3          	remu	a5,s1,a5
     12c:	eb81                	bnez	a5,13c <go+0xc4>
      write(1, which_child?"B":"A", 1);
     12e:	4605                	li	a2,1
     130:	85ce                	mv	a1,s3
     132:	4505                	li	a0,1
     134:	00001097          	auipc	ra,0x1
     138:	d52080e7          	jalr	-686(ra) # e86 <write>
    int what = rand() % 23;
     13c:	00000097          	auipc	ra,0x0
     140:	f1c080e7          	jalr	-228(ra) # 58 <rand>
     144:	47dd                	li	a5,23
     146:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     14a:	4785                	li	a5,1
     14c:	faf50de3          	beq	a0,a5,106 <go+0x8e>
    } else if(what == 2){
     150:	4789                	li	a5,2
     152:	18f50563          	beq	a0,a5,2dc <go+0x264>
    } else if(what == 3){
     156:	478d                	li	a5,3
     158:	1af50163          	beq	a0,a5,2fa <go+0x282>
    } else if(what == 4){
     15c:	4791                	li	a5,4
     15e:	1af50763          	beq	a0,a5,30c <go+0x294>
    } else if(what == 5){
     162:	4795                	li	a5,5
     164:	1ef50b63          	beq	a0,a5,35a <go+0x2e2>
    } else if(what == 6){
     168:	4799                	li	a5,6
     16a:	20f50963          	beq	a0,a5,37c <go+0x304>
    } else if(what == 7){
     16e:	479d                	li	a5,7
     170:	22f50763          	beq	a0,a5,39e <go+0x326>
    } else if(what == 8){
     174:	47a1                	li	a5,8
     176:	22f50d63          	beq	a0,a5,3b0 <go+0x338>
    } else if(what == 9){
     17a:	47a5                	li	a5,9
     17c:	24f50363          	beq	a0,a5,3c2 <go+0x34a>
      mkdir("grindir/../a");
      close(open("a/../a/./a", O_CREATE|O_RDWR));
      unlink("a/a");
    } else if(what == 10){
     180:	47a9                	li	a5,10
     182:	26f50f63          	beq	a0,a5,400 <go+0x388>
      mkdir("/../b");
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
      unlink("b/b");
    } else if(what == 11){
     186:	47ad                	li	a5,11
     188:	2af50b63          	beq	a0,a5,43e <go+0x3c6>
      unlink("b");
      link("../grindir/./../a", "../b");
    } else if(what == 12){
     18c:	47b1                	li	a5,12
     18e:	2cf50d63          	beq	a0,a5,468 <go+0x3f0>
      unlink("../grindir/../a");
      link(".././b", "/grindir/../a");
    } else if(what == 13){
     192:	47b5                	li	a5,13
     194:	2ef50f63          	beq	a0,a5,492 <go+0x41a>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 14){
     198:	47b9                	li	a5,14
     19a:	32f50a63          	beq	a0,a5,4ce <go+0x456>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 15){
     19e:	47bd                	li	a5,15
     1a0:	36f50e63          	beq	a0,a5,51c <go+0x4a4>
      sbrk(6011);
    } else if(what == 16){
     1a4:	47c1                	li	a5,16
     1a6:	38f50363          	beq	a0,a5,52c <go+0x4b4>
      if(sbrk(0) > break0)
        sbrk(-(sbrk(0) - break0));
    } else if(what == 17){
     1aa:	47c5                	li	a5,17
     1ac:	3af50363          	beq	a0,a5,552 <go+0x4da>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
      wait(0);
    } else if(what == 18){
     1b0:	47c9                	li	a5,18
     1b2:	42f50963          	beq	a0,a5,5e4 <go+0x56c>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 19){
     1b6:	47cd                	li	a5,19
     1b8:	46f50d63          	beq	a0,a5,632 <go+0x5ba>
        exit(1);
      }
      close(fds[0]);
      close(fds[1]);
      wait(0);
    } else if(what == 20){
     1bc:	47d1                	li	a5,20
     1be:	54f50e63          	beq	a0,a5,71a <go+0x6a2>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 21){
     1c2:	47d5                	li	a5,21
     1c4:	5ef50c63          	beq	a0,a5,7bc <go+0x744>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
      unlink("c");
    } else if(what == 22){
     1c8:	47d9                	li	a5,22
     1ca:	f4f51ce3          	bne	a0,a5,122 <go+0xaa>
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     1ce:	f9840513          	addi	a0,s0,-104
     1d2:	00001097          	auipc	ra,0x1
     1d6:	ca4080e7          	jalr	-860(ra) # e76 <pipe>
     1da:	6e054563          	bltz	a0,8c4 <go+0x84c>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     1de:	fa040513          	addi	a0,s0,-96
     1e2:	00001097          	auipc	ra,0x1
     1e6:	c94080e7          	jalr	-876(ra) # e76 <pipe>
     1ea:	6e054b63          	bltz	a0,8e0 <go+0x868>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     1ee:	00001097          	auipc	ra,0x1
     1f2:	c70080e7          	jalr	-912(ra) # e5e <fork>
      if(pid1 == 0){
     1f6:	70050363          	beqz	a0,8fc <go+0x884>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     1fa:	7a054b63          	bltz	a0,9b0 <go+0x938>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     1fe:	00001097          	auipc	ra,0x1
     202:	c60080e7          	jalr	-928(ra) # e5e <fork>
      if(pid2 == 0){
     206:	7c050363          	beqz	a0,9cc <go+0x954>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     20a:	08054fe3          	bltz	a0,aa8 <go+0xa30>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     20e:	f9842503          	lw	a0,-104(s0)
     212:	00001097          	auipc	ra,0x1
     216:	c7c080e7          	jalr	-900(ra) # e8e <close>
      close(aa[1]);
     21a:	f9c42503          	lw	a0,-100(s0)
     21e:	00001097          	auipc	ra,0x1
     222:	c70080e7          	jalr	-912(ra) # e8e <close>
      close(bb[1]);
     226:	fa442503          	lw	a0,-92(s0)
     22a:	00001097          	auipc	ra,0x1
     22e:	c64080e7          	jalr	-924(ra) # e8e <close>
      char buf[4] = { 0, 0, 0, 0 };
     232:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     236:	4605                	li	a2,1
     238:	f9040593          	addi	a1,s0,-112
     23c:	fa042503          	lw	a0,-96(s0)
     240:	00001097          	auipc	ra,0x1
     244:	c3e080e7          	jalr	-962(ra) # e7e <read>
      read(bb[0], buf+1, 1);
     248:	4605                	li	a2,1
     24a:	f9140593          	addi	a1,s0,-111
     24e:	fa042503          	lw	a0,-96(s0)
     252:	00001097          	auipc	ra,0x1
     256:	c2c080e7          	jalr	-980(ra) # e7e <read>
      read(bb[0], buf+2, 1);
     25a:	4605                	li	a2,1
     25c:	f9240593          	addi	a1,s0,-110
     260:	fa042503          	lw	a0,-96(s0)
     264:	00001097          	auipc	ra,0x1
     268:	c1a080e7          	jalr	-998(ra) # e7e <read>
      close(bb[0]);
     26c:	fa042503          	lw	a0,-96(s0)
     270:	00001097          	auipc	ra,0x1
     274:	c1e080e7          	jalr	-994(ra) # e8e <close>
      int st1, st2;
      wait(&st1);
     278:	f9440513          	addi	a0,s0,-108
     27c:	00001097          	auipc	ra,0x1
     280:	bf2080e7          	jalr	-1038(ra) # e6e <wait>
      wait(&st2);
     284:	fa840513          	addi	a0,s0,-88
     288:	00001097          	auipc	ra,0x1
     28c:	be6080e7          	jalr	-1050(ra) # e6e <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     290:	f9442783          	lw	a5,-108(s0)
     294:	fa842703          	lw	a4,-88(s0)
     298:	8fd9                	or	a5,a5,a4
     29a:	2781                	sext.w	a5,a5
     29c:	ef89                	bnez	a5,2b6 <go+0x23e>
     29e:	00001597          	auipc	a1,0x1
     2a2:	3e258593          	addi	a1,a1,994 # 1680 <malloc+0x39c>
     2a6:	f9040513          	addi	a0,s0,-112
     2aa:	00001097          	auipc	ra,0x1
     2ae:	962080e7          	jalr	-1694(ra) # c0c <strcmp>
     2b2:	e60508e3          	beqz	a0,122 <go+0xaa>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     2b6:	f9040693          	addi	a3,s0,-112
     2ba:	fa842603          	lw	a2,-88(s0)
     2be:	f9442583          	lw	a1,-108(s0)
     2c2:	00001517          	auipc	a0,0x1
     2c6:	3c650513          	addi	a0,a0,966 # 1688 <malloc+0x3a4>
     2ca:	00001097          	auipc	ra,0x1
     2ce:	f5c080e7          	jalr	-164(ra) # 1226 <printf>
        exit(1);
     2d2:	4505                	li	a0,1
     2d4:	00001097          	auipc	ra,0x1
     2d8:	b92080e7          	jalr	-1134(ra) # e66 <exit>
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     2dc:	20200593          	li	a1,514
     2e0:	00001517          	auipc	a0,0x1
     2e4:	13850513          	addi	a0,a0,312 # 1418 <malloc+0x134>
     2e8:	00001097          	auipc	ra,0x1
     2ec:	bbe080e7          	jalr	-1090(ra) # ea6 <open>
     2f0:	00001097          	auipc	ra,0x1
     2f4:	b9e080e7          	jalr	-1122(ra) # e8e <close>
     2f8:	b52d                	j	122 <go+0xaa>
      unlink("grindir/../a");
     2fa:	00001517          	auipc	a0,0x1
     2fe:	10e50513          	addi	a0,a0,270 # 1408 <malloc+0x124>
     302:	00001097          	auipc	ra,0x1
     306:	bb4080e7          	jalr	-1100(ra) # eb6 <unlink>
     30a:	bd21                	j	122 <go+0xaa>
      if(chdir("grindir") != 0){
     30c:	00001517          	auipc	a0,0x1
     310:	0bc50513          	addi	a0,a0,188 # 13c8 <malloc+0xe4>
     314:	00001097          	auipc	ra,0x1
     318:	bc2080e7          	jalr	-1086(ra) # ed6 <chdir>
     31c:	e115                	bnez	a0,340 <go+0x2c8>
      unlink("../b");
     31e:	00001517          	auipc	a0,0x1
     322:	11250513          	addi	a0,a0,274 # 1430 <malloc+0x14c>
     326:	00001097          	auipc	ra,0x1
     32a:	b90080e7          	jalr	-1136(ra) # eb6 <unlink>
      chdir("/");
     32e:	00001517          	auipc	a0,0x1
     332:	0c250513          	addi	a0,a0,194 # 13f0 <malloc+0x10c>
     336:	00001097          	auipc	ra,0x1
     33a:	ba0080e7          	jalr	-1120(ra) # ed6 <chdir>
     33e:	b3d5                	j	122 <go+0xaa>
        printf("grind: chdir grindir failed\n");
     340:	00001517          	auipc	a0,0x1
     344:	09050513          	addi	a0,a0,144 # 13d0 <malloc+0xec>
     348:	00001097          	auipc	ra,0x1
     34c:	ede080e7          	jalr	-290(ra) # 1226 <printf>
        exit(1);
     350:	4505                	li	a0,1
     352:	00001097          	auipc	ra,0x1
     356:	b14080e7          	jalr	-1260(ra) # e66 <exit>
      close(fd);
     35a:	854a                	mv	a0,s2
     35c:	00001097          	auipc	ra,0x1
     360:	b32080e7          	jalr	-1230(ra) # e8e <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     364:	20200593          	li	a1,514
     368:	00001517          	auipc	a0,0x1
     36c:	0d050513          	addi	a0,a0,208 # 1438 <malloc+0x154>
     370:	00001097          	auipc	ra,0x1
     374:	b36080e7          	jalr	-1226(ra) # ea6 <open>
     378:	892a                	mv	s2,a0
     37a:	b365                	j	122 <go+0xaa>
      close(fd);
     37c:	854a                	mv	a0,s2
     37e:	00001097          	auipc	ra,0x1
     382:	b10080e7          	jalr	-1264(ra) # e8e <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     386:	20200593          	li	a1,514
     38a:	00001517          	auipc	a0,0x1
     38e:	0be50513          	addi	a0,a0,190 # 1448 <malloc+0x164>
     392:	00001097          	auipc	ra,0x1
     396:	b14080e7          	jalr	-1260(ra) # ea6 <open>
     39a:	892a                	mv	s2,a0
     39c:	b359                	j	122 <go+0xaa>
      write(fd, buf, sizeof(buf));
     39e:	3e700613          	li	a2,999
     3a2:	85d2                	mv	a1,s4
     3a4:	854a                	mv	a0,s2
     3a6:	00001097          	auipc	ra,0x1
     3aa:	ae0080e7          	jalr	-1312(ra) # e86 <write>
     3ae:	bb95                	j	122 <go+0xaa>
      read(fd, buf, sizeof(buf));
     3b0:	3e700613          	li	a2,999
     3b4:	85d2                	mv	a1,s4
     3b6:	854a                	mv	a0,s2
     3b8:	00001097          	auipc	ra,0x1
     3bc:	ac6080e7          	jalr	-1338(ra) # e7e <read>
     3c0:	b38d                	j	122 <go+0xaa>
      mkdir("grindir/../a");
     3c2:	00001517          	auipc	a0,0x1
     3c6:	04650513          	addi	a0,a0,70 # 1408 <malloc+0x124>
     3ca:	00001097          	auipc	ra,0x1
     3ce:	b04080e7          	jalr	-1276(ra) # ece <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     3d2:	20200593          	li	a1,514
     3d6:	00001517          	auipc	a0,0x1
     3da:	08a50513          	addi	a0,a0,138 # 1460 <malloc+0x17c>
     3de:	00001097          	auipc	ra,0x1
     3e2:	ac8080e7          	jalr	-1336(ra) # ea6 <open>
     3e6:	00001097          	auipc	ra,0x1
     3ea:	aa8080e7          	jalr	-1368(ra) # e8e <close>
      unlink("a/a");
     3ee:	00001517          	auipc	a0,0x1
     3f2:	08250513          	addi	a0,a0,130 # 1470 <malloc+0x18c>
     3f6:	00001097          	auipc	ra,0x1
     3fa:	ac0080e7          	jalr	-1344(ra) # eb6 <unlink>
     3fe:	b315                	j	122 <go+0xaa>
      mkdir("/../b");
     400:	00001517          	auipc	a0,0x1
     404:	07850513          	addi	a0,a0,120 # 1478 <malloc+0x194>
     408:	00001097          	auipc	ra,0x1
     40c:	ac6080e7          	jalr	-1338(ra) # ece <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     410:	20200593          	li	a1,514
     414:	00001517          	auipc	a0,0x1
     418:	06c50513          	addi	a0,a0,108 # 1480 <malloc+0x19c>
     41c:	00001097          	auipc	ra,0x1
     420:	a8a080e7          	jalr	-1398(ra) # ea6 <open>
     424:	00001097          	auipc	ra,0x1
     428:	a6a080e7          	jalr	-1430(ra) # e8e <close>
      unlink("b/b");
     42c:	00001517          	auipc	a0,0x1
     430:	06450513          	addi	a0,a0,100 # 1490 <malloc+0x1ac>
     434:	00001097          	auipc	ra,0x1
     438:	a82080e7          	jalr	-1406(ra) # eb6 <unlink>
     43c:	b1dd                	j	122 <go+0xaa>
      unlink("b");
     43e:	00001517          	auipc	a0,0x1
     442:	01a50513          	addi	a0,a0,26 # 1458 <malloc+0x174>
     446:	00001097          	auipc	ra,0x1
     44a:	a70080e7          	jalr	-1424(ra) # eb6 <unlink>
      link("../grindir/./../a", "../b");
     44e:	00001597          	auipc	a1,0x1
     452:	fe258593          	addi	a1,a1,-30 # 1430 <malloc+0x14c>
     456:	00001517          	auipc	a0,0x1
     45a:	04250513          	addi	a0,a0,66 # 1498 <malloc+0x1b4>
     45e:	00001097          	auipc	ra,0x1
     462:	a68080e7          	jalr	-1432(ra) # ec6 <link>
     466:	b975                	j	122 <go+0xaa>
      unlink("../grindir/../a");
     468:	00001517          	auipc	a0,0x1
     46c:	04850513          	addi	a0,a0,72 # 14b0 <malloc+0x1cc>
     470:	00001097          	auipc	ra,0x1
     474:	a46080e7          	jalr	-1466(ra) # eb6 <unlink>
      link(".././b", "/grindir/../a");
     478:	00001597          	auipc	a1,0x1
     47c:	fc058593          	addi	a1,a1,-64 # 1438 <malloc+0x154>
     480:	00001517          	auipc	a0,0x1
     484:	04050513          	addi	a0,a0,64 # 14c0 <malloc+0x1dc>
     488:	00001097          	auipc	ra,0x1
     48c:	a3e080e7          	jalr	-1474(ra) # ec6 <link>
     490:	b949                	j	122 <go+0xaa>
      int pid = fork();
     492:	00001097          	auipc	ra,0x1
     496:	9cc080e7          	jalr	-1588(ra) # e5e <fork>
      if(pid == 0){
     49a:	c909                	beqz	a0,4ac <go+0x434>
      } else if(pid < 0){
     49c:	00054c63          	bltz	a0,4b4 <go+0x43c>
      wait(0);
     4a0:	4501                	li	a0,0
     4a2:	00001097          	auipc	ra,0x1
     4a6:	9cc080e7          	jalr	-1588(ra) # e6e <wait>
     4aa:	b9a5                	j	122 <go+0xaa>
        exit(0);
     4ac:	00001097          	auipc	ra,0x1
     4b0:	9ba080e7          	jalr	-1606(ra) # e66 <exit>
        printf("grind: fork failed\n");
     4b4:	00001517          	auipc	a0,0x1
     4b8:	01450513          	addi	a0,a0,20 # 14c8 <malloc+0x1e4>
     4bc:	00001097          	auipc	ra,0x1
     4c0:	d6a080e7          	jalr	-662(ra) # 1226 <printf>
        exit(1);
     4c4:	4505                	li	a0,1
     4c6:	00001097          	auipc	ra,0x1
     4ca:	9a0080e7          	jalr	-1632(ra) # e66 <exit>
      int pid = fork();
     4ce:	00001097          	auipc	ra,0x1
     4d2:	990080e7          	jalr	-1648(ra) # e5e <fork>
      if(pid == 0){
     4d6:	c909                	beqz	a0,4e8 <go+0x470>
      } else if(pid < 0){
     4d8:	02054563          	bltz	a0,502 <go+0x48a>
      wait(0);
     4dc:	4501                	li	a0,0
     4de:	00001097          	auipc	ra,0x1
     4e2:	990080e7          	jalr	-1648(ra) # e6e <wait>
     4e6:	b935                	j	122 <go+0xaa>
        fork();
     4e8:	00001097          	auipc	ra,0x1
     4ec:	976080e7          	jalr	-1674(ra) # e5e <fork>
        fork();
     4f0:	00001097          	auipc	ra,0x1
     4f4:	96e080e7          	jalr	-1682(ra) # e5e <fork>
        exit(0);
     4f8:	4501                	li	a0,0
     4fa:	00001097          	auipc	ra,0x1
     4fe:	96c080e7          	jalr	-1684(ra) # e66 <exit>
        printf("grind: fork failed\n");
     502:	00001517          	auipc	a0,0x1
     506:	fc650513          	addi	a0,a0,-58 # 14c8 <malloc+0x1e4>
     50a:	00001097          	auipc	ra,0x1
     50e:	d1c080e7          	jalr	-740(ra) # 1226 <printf>
        exit(1);
     512:	4505                	li	a0,1
     514:	00001097          	auipc	ra,0x1
     518:	952080e7          	jalr	-1710(ra) # e66 <exit>
      sbrk(6011);
     51c:	6505                	lui	a0,0x1
     51e:	77b50513          	addi	a0,a0,1915 # 177b <buf.1258+0x9b>
     522:	00001097          	auipc	ra,0x1
     526:	9cc080e7          	jalr	-1588(ra) # eee <sbrk>
     52a:	bee5                	j	122 <go+0xaa>
      if(sbrk(0) > break0)
     52c:	4501                	li	a0,0
     52e:	00001097          	auipc	ra,0x1
     532:	9c0080e7          	jalr	-1600(ra) # eee <sbrk>
     536:	beaaf6e3          	bgeu	s5,a0,122 <go+0xaa>
        sbrk(-(sbrk(0) - break0));
     53a:	4501                	li	a0,0
     53c:	00001097          	auipc	ra,0x1
     540:	9b2080e7          	jalr	-1614(ra) # eee <sbrk>
     544:	40aa853b          	subw	a0,s5,a0
     548:	00001097          	auipc	ra,0x1
     54c:	9a6080e7          	jalr	-1626(ra) # eee <sbrk>
     550:	bec9                	j	122 <go+0xaa>
      int pid = fork();
     552:	00001097          	auipc	ra,0x1
     556:	90c080e7          	jalr	-1780(ra) # e5e <fork>
     55a:	8b2a                	mv	s6,a0
      if(pid == 0){
     55c:	c51d                	beqz	a0,58a <go+0x512>
      } else if(pid < 0){
     55e:	04054963          	bltz	a0,5b0 <go+0x538>
      if(chdir("../grindir/..") != 0){
     562:	00001517          	auipc	a0,0x1
     566:	f7e50513          	addi	a0,a0,-130 # 14e0 <malloc+0x1fc>
     56a:	00001097          	auipc	ra,0x1
     56e:	96c080e7          	jalr	-1684(ra) # ed6 <chdir>
     572:	ed21                	bnez	a0,5ca <go+0x552>
      kill(pid);
     574:	855a                	mv	a0,s6
     576:	00001097          	auipc	ra,0x1
     57a:	920080e7          	jalr	-1760(ra) # e96 <kill>
      wait(0);
     57e:	4501                	li	a0,0
     580:	00001097          	auipc	ra,0x1
     584:	8ee080e7          	jalr	-1810(ra) # e6e <wait>
     588:	be69                	j	122 <go+0xaa>
        close(open("a", O_CREATE|O_RDWR));
     58a:	20200593          	li	a1,514
     58e:	00001517          	auipc	a0,0x1
     592:	f1a50513          	addi	a0,a0,-230 # 14a8 <malloc+0x1c4>
     596:	00001097          	auipc	ra,0x1
     59a:	910080e7          	jalr	-1776(ra) # ea6 <open>
     59e:	00001097          	auipc	ra,0x1
     5a2:	8f0080e7          	jalr	-1808(ra) # e8e <close>
        exit(0);
     5a6:	4501                	li	a0,0
     5a8:	00001097          	auipc	ra,0x1
     5ac:	8be080e7          	jalr	-1858(ra) # e66 <exit>
        printf("grind: fork failed\n");
     5b0:	00001517          	auipc	a0,0x1
     5b4:	f1850513          	addi	a0,a0,-232 # 14c8 <malloc+0x1e4>
     5b8:	00001097          	auipc	ra,0x1
     5bc:	c6e080e7          	jalr	-914(ra) # 1226 <printf>
        exit(1);
     5c0:	4505                	li	a0,1
     5c2:	00001097          	auipc	ra,0x1
     5c6:	8a4080e7          	jalr	-1884(ra) # e66 <exit>
        printf("grind: chdir failed\n");
     5ca:	00001517          	auipc	a0,0x1
     5ce:	f2650513          	addi	a0,a0,-218 # 14f0 <malloc+0x20c>
     5d2:	00001097          	auipc	ra,0x1
     5d6:	c54080e7          	jalr	-940(ra) # 1226 <printf>
        exit(1);
     5da:	4505                	li	a0,1
     5dc:	00001097          	auipc	ra,0x1
     5e0:	88a080e7          	jalr	-1910(ra) # e66 <exit>
      int pid = fork();
     5e4:	00001097          	auipc	ra,0x1
     5e8:	87a080e7          	jalr	-1926(ra) # e5e <fork>
      if(pid == 0){
     5ec:	c909                	beqz	a0,5fe <go+0x586>
      } else if(pid < 0){
     5ee:	02054563          	bltz	a0,618 <go+0x5a0>
      wait(0);
     5f2:	4501                	li	a0,0
     5f4:	00001097          	auipc	ra,0x1
     5f8:	87a080e7          	jalr	-1926(ra) # e6e <wait>
     5fc:	b61d                	j	122 <go+0xaa>
        kill(getpid());
     5fe:	00001097          	auipc	ra,0x1
     602:	8e8080e7          	jalr	-1816(ra) # ee6 <getpid>
     606:	00001097          	auipc	ra,0x1
     60a:	890080e7          	jalr	-1904(ra) # e96 <kill>
        exit(0);
     60e:	4501                	li	a0,0
     610:	00001097          	auipc	ra,0x1
     614:	856080e7          	jalr	-1962(ra) # e66 <exit>
        printf("grind: fork failed\n");
     618:	00001517          	auipc	a0,0x1
     61c:	eb050513          	addi	a0,a0,-336 # 14c8 <malloc+0x1e4>
     620:	00001097          	auipc	ra,0x1
     624:	c06080e7          	jalr	-1018(ra) # 1226 <printf>
        exit(1);
     628:	4505                	li	a0,1
     62a:	00001097          	auipc	ra,0x1
     62e:	83c080e7          	jalr	-1988(ra) # e66 <exit>
      if(pipe(fds) < 0){
     632:	fa840513          	addi	a0,s0,-88
     636:	00001097          	auipc	ra,0x1
     63a:	840080e7          	jalr	-1984(ra) # e76 <pipe>
     63e:	02054b63          	bltz	a0,674 <go+0x5fc>
      int pid = fork();
     642:	00001097          	auipc	ra,0x1
     646:	81c080e7          	jalr	-2020(ra) # e5e <fork>
      if(pid == 0){
     64a:	c131                	beqz	a0,68e <go+0x616>
      } else if(pid < 0){
     64c:	0a054a63          	bltz	a0,700 <go+0x688>
      close(fds[0]);
     650:	fa842503          	lw	a0,-88(s0)
     654:	00001097          	auipc	ra,0x1
     658:	83a080e7          	jalr	-1990(ra) # e8e <close>
      close(fds[1]);
     65c:	fac42503          	lw	a0,-84(s0)
     660:	00001097          	auipc	ra,0x1
     664:	82e080e7          	jalr	-2002(ra) # e8e <close>
      wait(0);
     668:	4501                	li	a0,0
     66a:	00001097          	auipc	ra,0x1
     66e:	804080e7          	jalr	-2044(ra) # e6e <wait>
     672:	bc45                	j	122 <go+0xaa>
        printf("grind: pipe failed\n");
     674:	00001517          	auipc	a0,0x1
     678:	e9450513          	addi	a0,a0,-364 # 1508 <malloc+0x224>
     67c:	00001097          	auipc	ra,0x1
     680:	baa080e7          	jalr	-1110(ra) # 1226 <printf>
        exit(1);
     684:	4505                	li	a0,1
     686:	00000097          	auipc	ra,0x0
     68a:	7e0080e7          	jalr	2016(ra) # e66 <exit>
        fork();
     68e:	00000097          	auipc	ra,0x0
     692:	7d0080e7          	jalr	2000(ra) # e5e <fork>
        fork();
     696:	00000097          	auipc	ra,0x0
     69a:	7c8080e7          	jalr	1992(ra) # e5e <fork>
        if(write(fds[1], "x", 1) != 1)
     69e:	4605                	li	a2,1
     6a0:	00001597          	auipc	a1,0x1
     6a4:	e8058593          	addi	a1,a1,-384 # 1520 <malloc+0x23c>
     6a8:	fac42503          	lw	a0,-84(s0)
     6ac:	00000097          	auipc	ra,0x0
     6b0:	7da080e7          	jalr	2010(ra) # e86 <write>
     6b4:	4785                	li	a5,1
     6b6:	02f51363          	bne	a0,a5,6dc <go+0x664>
        if(read(fds[0], &c, 1) != 1)
     6ba:	4605                	li	a2,1
     6bc:	fa040593          	addi	a1,s0,-96
     6c0:	fa842503          	lw	a0,-88(s0)
     6c4:	00000097          	auipc	ra,0x0
     6c8:	7ba080e7          	jalr	1978(ra) # e7e <read>
     6cc:	4785                	li	a5,1
     6ce:	02f51063          	bne	a0,a5,6ee <go+0x676>
        exit(0);
     6d2:	4501                	li	a0,0
     6d4:	00000097          	auipc	ra,0x0
     6d8:	792080e7          	jalr	1938(ra) # e66 <exit>
          printf("grind: pipe write failed\n");
     6dc:	00001517          	auipc	a0,0x1
     6e0:	e4c50513          	addi	a0,a0,-436 # 1528 <malloc+0x244>
     6e4:	00001097          	auipc	ra,0x1
     6e8:	b42080e7          	jalr	-1214(ra) # 1226 <printf>
     6ec:	b7f9                	j	6ba <go+0x642>
          printf("grind: pipe read failed\n");
     6ee:	00001517          	auipc	a0,0x1
     6f2:	e5a50513          	addi	a0,a0,-422 # 1548 <malloc+0x264>
     6f6:	00001097          	auipc	ra,0x1
     6fa:	b30080e7          	jalr	-1232(ra) # 1226 <printf>
     6fe:	bfd1                	j	6d2 <go+0x65a>
        printf("grind: fork failed\n");
     700:	00001517          	auipc	a0,0x1
     704:	dc850513          	addi	a0,a0,-568 # 14c8 <malloc+0x1e4>
     708:	00001097          	auipc	ra,0x1
     70c:	b1e080e7          	jalr	-1250(ra) # 1226 <printf>
        exit(1);
     710:	4505                	li	a0,1
     712:	00000097          	auipc	ra,0x0
     716:	754080e7          	jalr	1876(ra) # e66 <exit>
      int pid = fork();
     71a:	00000097          	auipc	ra,0x0
     71e:	744080e7          	jalr	1860(ra) # e5e <fork>
      if(pid == 0){
     722:	c909                	beqz	a0,734 <go+0x6bc>
      } else if(pid < 0){
     724:	06054f63          	bltz	a0,7a2 <go+0x72a>
      wait(0);
     728:	4501                	li	a0,0
     72a:	00000097          	auipc	ra,0x0
     72e:	744080e7          	jalr	1860(ra) # e6e <wait>
     732:	bac5                	j	122 <go+0xaa>
        unlink("a");
     734:	00001517          	auipc	a0,0x1
     738:	d7450513          	addi	a0,a0,-652 # 14a8 <malloc+0x1c4>
     73c:	00000097          	auipc	ra,0x0
     740:	77a080e7          	jalr	1914(ra) # eb6 <unlink>
        mkdir("a");
     744:	00001517          	auipc	a0,0x1
     748:	d6450513          	addi	a0,a0,-668 # 14a8 <malloc+0x1c4>
     74c:	00000097          	auipc	ra,0x0
     750:	782080e7          	jalr	1922(ra) # ece <mkdir>
        chdir("a");
     754:	00001517          	auipc	a0,0x1
     758:	d5450513          	addi	a0,a0,-684 # 14a8 <malloc+0x1c4>
     75c:	00000097          	auipc	ra,0x0
     760:	77a080e7          	jalr	1914(ra) # ed6 <chdir>
        unlink("../a");
     764:	00001517          	auipc	a0,0x1
     768:	cac50513          	addi	a0,a0,-852 # 1410 <malloc+0x12c>
     76c:	00000097          	auipc	ra,0x0
     770:	74a080e7          	jalr	1866(ra) # eb6 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     774:	20200593          	li	a1,514
     778:	00001517          	auipc	a0,0x1
     77c:	da850513          	addi	a0,a0,-600 # 1520 <malloc+0x23c>
     780:	00000097          	auipc	ra,0x0
     784:	726080e7          	jalr	1830(ra) # ea6 <open>
        unlink("x");
     788:	00001517          	auipc	a0,0x1
     78c:	d9850513          	addi	a0,a0,-616 # 1520 <malloc+0x23c>
     790:	00000097          	auipc	ra,0x0
     794:	726080e7          	jalr	1830(ra) # eb6 <unlink>
        exit(0);
     798:	4501                	li	a0,0
     79a:	00000097          	auipc	ra,0x0
     79e:	6cc080e7          	jalr	1740(ra) # e66 <exit>
        printf("grind: fork failed\n");
     7a2:	00001517          	auipc	a0,0x1
     7a6:	d2650513          	addi	a0,a0,-730 # 14c8 <malloc+0x1e4>
     7aa:	00001097          	auipc	ra,0x1
     7ae:	a7c080e7          	jalr	-1412(ra) # 1226 <printf>
        exit(1);
     7b2:	4505                	li	a0,1
     7b4:	00000097          	auipc	ra,0x0
     7b8:	6b2080e7          	jalr	1714(ra) # e66 <exit>
      unlink("c");
     7bc:	00001517          	auipc	a0,0x1
     7c0:	dac50513          	addi	a0,a0,-596 # 1568 <malloc+0x284>
     7c4:	00000097          	auipc	ra,0x0
     7c8:	6f2080e7          	jalr	1778(ra) # eb6 <unlink>
      int fd1 = open("c", O_CREATE|O_RDWR);
     7cc:	20200593          	li	a1,514
     7d0:	00001517          	auipc	a0,0x1
     7d4:	d9850513          	addi	a0,a0,-616 # 1568 <malloc+0x284>
     7d8:	00000097          	auipc	ra,0x0
     7dc:	6ce080e7          	jalr	1742(ra) # ea6 <open>
     7e0:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     7e2:	04054f63          	bltz	a0,840 <go+0x7c8>
      if(write(fd1, "x", 1) != 1){
     7e6:	4605                	li	a2,1
     7e8:	00001597          	auipc	a1,0x1
     7ec:	d3858593          	addi	a1,a1,-712 # 1520 <malloc+0x23c>
     7f0:	00000097          	auipc	ra,0x0
     7f4:	696080e7          	jalr	1686(ra) # e86 <write>
     7f8:	4785                	li	a5,1
     7fa:	06f51063          	bne	a0,a5,85a <go+0x7e2>
      if(fstat(fd1, &st) != 0){
     7fe:	fa840593          	addi	a1,s0,-88
     802:	855a                	mv	a0,s6
     804:	00000097          	auipc	ra,0x0
     808:	6ba080e7          	jalr	1722(ra) # ebe <fstat>
     80c:	e525                	bnez	a0,874 <go+0x7fc>
      if(st.size != 1){
     80e:	fb843583          	ld	a1,-72(s0)
     812:	4785                	li	a5,1
     814:	06f59d63          	bne	a1,a5,88e <go+0x816>
      if(st.ino > 200){
     818:	fac42583          	lw	a1,-84(s0)
     81c:	0c800793          	li	a5,200
     820:	08b7e563          	bltu	a5,a1,8aa <go+0x832>
      close(fd1);
     824:	855a                	mv	a0,s6
     826:	00000097          	auipc	ra,0x0
     82a:	668080e7          	jalr	1640(ra) # e8e <close>
      unlink("c");
     82e:	00001517          	auipc	a0,0x1
     832:	d3a50513          	addi	a0,a0,-710 # 1568 <malloc+0x284>
     836:	00000097          	auipc	ra,0x0
     83a:	680080e7          	jalr	1664(ra) # eb6 <unlink>
     83e:	b0d5                	j	122 <go+0xaa>
        printf("grind: create c failed\n");
     840:	00001517          	auipc	a0,0x1
     844:	d3050513          	addi	a0,a0,-720 # 1570 <malloc+0x28c>
     848:	00001097          	auipc	ra,0x1
     84c:	9de080e7          	jalr	-1570(ra) # 1226 <printf>
        exit(1);
     850:	4505                	li	a0,1
     852:	00000097          	auipc	ra,0x0
     856:	614080e7          	jalr	1556(ra) # e66 <exit>
        printf("grind: write c failed\n");
     85a:	00001517          	auipc	a0,0x1
     85e:	d2e50513          	addi	a0,a0,-722 # 1588 <malloc+0x2a4>
     862:	00001097          	auipc	ra,0x1
     866:	9c4080e7          	jalr	-1596(ra) # 1226 <printf>
        exit(1);
     86a:	4505                	li	a0,1
     86c:	00000097          	auipc	ra,0x0
     870:	5fa080e7          	jalr	1530(ra) # e66 <exit>
        printf("grind: fstat failed\n");
     874:	00001517          	auipc	a0,0x1
     878:	d2c50513          	addi	a0,a0,-724 # 15a0 <malloc+0x2bc>
     87c:	00001097          	auipc	ra,0x1
     880:	9aa080e7          	jalr	-1622(ra) # 1226 <printf>
        exit(1);
     884:	4505                	li	a0,1
     886:	00000097          	auipc	ra,0x0
     88a:	5e0080e7          	jalr	1504(ra) # e66 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     88e:	2581                	sext.w	a1,a1
     890:	00001517          	auipc	a0,0x1
     894:	d2850513          	addi	a0,a0,-728 # 15b8 <malloc+0x2d4>
     898:	00001097          	auipc	ra,0x1
     89c:	98e080e7          	jalr	-1650(ra) # 1226 <printf>
        exit(1);
     8a0:	4505                	li	a0,1
     8a2:	00000097          	auipc	ra,0x0
     8a6:	5c4080e7          	jalr	1476(ra) # e66 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     8aa:	00001517          	auipc	a0,0x1
     8ae:	d3650513          	addi	a0,a0,-714 # 15e0 <malloc+0x2fc>
     8b2:	00001097          	auipc	ra,0x1
     8b6:	974080e7          	jalr	-1676(ra) # 1226 <printf>
        exit(1);
     8ba:	4505                	li	a0,1
     8bc:	00000097          	auipc	ra,0x0
     8c0:	5aa080e7          	jalr	1450(ra) # e66 <exit>
        fprintf(2, "grind: pipe failed\n");
     8c4:	00001597          	auipc	a1,0x1
     8c8:	c4458593          	addi	a1,a1,-956 # 1508 <malloc+0x224>
     8cc:	4509                	li	a0,2
     8ce:	00001097          	auipc	ra,0x1
     8d2:	92a080e7          	jalr	-1750(ra) # 11f8 <fprintf>
        exit(1);
     8d6:	4505                	li	a0,1
     8d8:	00000097          	auipc	ra,0x0
     8dc:	58e080e7          	jalr	1422(ra) # e66 <exit>
        fprintf(2, "grind: pipe failed\n");
     8e0:	00001597          	auipc	a1,0x1
     8e4:	c2858593          	addi	a1,a1,-984 # 1508 <malloc+0x224>
     8e8:	4509                	li	a0,2
     8ea:	00001097          	auipc	ra,0x1
     8ee:	90e080e7          	jalr	-1778(ra) # 11f8 <fprintf>
        exit(1);
     8f2:	4505                	li	a0,1
     8f4:	00000097          	auipc	ra,0x0
     8f8:	572080e7          	jalr	1394(ra) # e66 <exit>
        close(bb[0]);
     8fc:	fa042503          	lw	a0,-96(s0)
     900:	00000097          	auipc	ra,0x0
     904:	58e080e7          	jalr	1422(ra) # e8e <close>
        close(bb[1]);
     908:	fa442503          	lw	a0,-92(s0)
     90c:	00000097          	auipc	ra,0x0
     910:	582080e7          	jalr	1410(ra) # e8e <close>
        close(aa[0]);
     914:	f9842503          	lw	a0,-104(s0)
     918:	00000097          	auipc	ra,0x0
     91c:	576080e7          	jalr	1398(ra) # e8e <close>
        close(1);
     920:	4505                	li	a0,1
     922:	00000097          	auipc	ra,0x0
     926:	56c080e7          	jalr	1388(ra) # e8e <close>
        if(dup(aa[1]) != 1){
     92a:	f9c42503          	lw	a0,-100(s0)
     92e:	00000097          	auipc	ra,0x0
     932:	5b0080e7          	jalr	1456(ra) # ede <dup>
     936:	4785                	li	a5,1
     938:	02f50063          	beq	a0,a5,958 <go+0x8e0>
          fprintf(2, "grind: dup failed\n");
     93c:	00001597          	auipc	a1,0x1
     940:	ccc58593          	addi	a1,a1,-820 # 1608 <malloc+0x324>
     944:	4509                	li	a0,2
     946:	00001097          	auipc	ra,0x1
     94a:	8b2080e7          	jalr	-1870(ra) # 11f8 <fprintf>
          exit(1);
     94e:	4505                	li	a0,1
     950:	00000097          	auipc	ra,0x0
     954:	516080e7          	jalr	1302(ra) # e66 <exit>
        close(aa[1]);
     958:	f9c42503          	lw	a0,-100(s0)
     95c:	00000097          	auipc	ra,0x0
     960:	532080e7          	jalr	1330(ra) # e8e <close>
        char *args[3] = { "echo", "hi", 0 };
     964:	00001797          	auipc	a5,0x1
     968:	cbc78793          	addi	a5,a5,-836 # 1620 <malloc+0x33c>
     96c:	faf43423          	sd	a5,-88(s0)
     970:	00001797          	auipc	a5,0x1
     974:	cb878793          	addi	a5,a5,-840 # 1628 <malloc+0x344>
     978:	faf43823          	sd	a5,-80(s0)
     97c:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     980:	fa840593          	addi	a1,s0,-88
     984:	00001517          	auipc	a0,0x1
     988:	cac50513          	addi	a0,a0,-852 # 1630 <malloc+0x34c>
     98c:	00000097          	auipc	ra,0x0
     990:	512080e7          	jalr	1298(ra) # e9e <exec>
        fprintf(2, "grind: echo: not found\n");
     994:	00001597          	auipc	a1,0x1
     998:	cac58593          	addi	a1,a1,-852 # 1640 <malloc+0x35c>
     99c:	4509                	li	a0,2
     99e:	00001097          	auipc	ra,0x1
     9a2:	85a080e7          	jalr	-1958(ra) # 11f8 <fprintf>
        exit(2);
     9a6:	4509                	li	a0,2
     9a8:	00000097          	auipc	ra,0x0
     9ac:	4be080e7          	jalr	1214(ra) # e66 <exit>
        fprintf(2, "grind: fork failed\n");
     9b0:	00001597          	auipc	a1,0x1
     9b4:	b1858593          	addi	a1,a1,-1256 # 14c8 <malloc+0x1e4>
     9b8:	4509                	li	a0,2
     9ba:	00001097          	auipc	ra,0x1
     9be:	83e080e7          	jalr	-1986(ra) # 11f8 <fprintf>
        exit(3);
     9c2:	450d                	li	a0,3
     9c4:	00000097          	auipc	ra,0x0
     9c8:	4a2080e7          	jalr	1186(ra) # e66 <exit>
        close(aa[1]);
     9cc:	f9c42503          	lw	a0,-100(s0)
     9d0:	00000097          	auipc	ra,0x0
     9d4:	4be080e7          	jalr	1214(ra) # e8e <close>
        close(bb[0]);
     9d8:	fa042503          	lw	a0,-96(s0)
     9dc:	00000097          	auipc	ra,0x0
     9e0:	4b2080e7          	jalr	1202(ra) # e8e <close>
        close(0);
     9e4:	4501                	li	a0,0
     9e6:	00000097          	auipc	ra,0x0
     9ea:	4a8080e7          	jalr	1192(ra) # e8e <close>
        if(dup(aa[0]) != 0){
     9ee:	f9842503          	lw	a0,-104(s0)
     9f2:	00000097          	auipc	ra,0x0
     9f6:	4ec080e7          	jalr	1260(ra) # ede <dup>
     9fa:	cd19                	beqz	a0,a18 <go+0x9a0>
          fprintf(2, "grind: dup failed\n");
     9fc:	00001597          	auipc	a1,0x1
     a00:	c0c58593          	addi	a1,a1,-1012 # 1608 <malloc+0x324>
     a04:	4509                	li	a0,2
     a06:	00000097          	auipc	ra,0x0
     a0a:	7f2080e7          	jalr	2034(ra) # 11f8 <fprintf>
          exit(4);
     a0e:	4511                	li	a0,4
     a10:	00000097          	auipc	ra,0x0
     a14:	456080e7          	jalr	1110(ra) # e66 <exit>
        close(aa[0]);
     a18:	f9842503          	lw	a0,-104(s0)
     a1c:	00000097          	auipc	ra,0x0
     a20:	472080e7          	jalr	1138(ra) # e8e <close>
        close(1);
     a24:	4505                	li	a0,1
     a26:	00000097          	auipc	ra,0x0
     a2a:	468080e7          	jalr	1128(ra) # e8e <close>
        if(dup(bb[1]) != 1){
     a2e:	fa442503          	lw	a0,-92(s0)
     a32:	00000097          	auipc	ra,0x0
     a36:	4ac080e7          	jalr	1196(ra) # ede <dup>
     a3a:	4785                	li	a5,1
     a3c:	02f50063          	beq	a0,a5,a5c <go+0x9e4>
          fprintf(2, "grind: dup failed\n");
     a40:	00001597          	auipc	a1,0x1
     a44:	bc858593          	addi	a1,a1,-1080 # 1608 <malloc+0x324>
     a48:	4509                	li	a0,2
     a4a:	00000097          	auipc	ra,0x0
     a4e:	7ae080e7          	jalr	1966(ra) # 11f8 <fprintf>
          exit(5);
     a52:	4515                	li	a0,5
     a54:	00000097          	auipc	ra,0x0
     a58:	412080e7          	jalr	1042(ra) # e66 <exit>
        close(bb[1]);
     a5c:	fa442503          	lw	a0,-92(s0)
     a60:	00000097          	auipc	ra,0x0
     a64:	42e080e7          	jalr	1070(ra) # e8e <close>
        char *args[2] = { "cat", 0 };
     a68:	00001797          	auipc	a5,0x1
     a6c:	bf078793          	addi	a5,a5,-1040 # 1658 <malloc+0x374>
     a70:	faf43423          	sd	a5,-88(s0)
     a74:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a78:	fa840593          	addi	a1,s0,-88
     a7c:	00001517          	auipc	a0,0x1
     a80:	be450513          	addi	a0,a0,-1052 # 1660 <malloc+0x37c>
     a84:	00000097          	auipc	ra,0x0
     a88:	41a080e7          	jalr	1050(ra) # e9e <exec>
        fprintf(2, "grind: cat: not found\n");
     a8c:	00001597          	auipc	a1,0x1
     a90:	bdc58593          	addi	a1,a1,-1060 # 1668 <malloc+0x384>
     a94:	4509                	li	a0,2
     a96:	00000097          	auipc	ra,0x0
     a9a:	762080e7          	jalr	1890(ra) # 11f8 <fprintf>
        exit(6);
     a9e:	4519                	li	a0,6
     aa0:	00000097          	auipc	ra,0x0
     aa4:	3c6080e7          	jalr	966(ra) # e66 <exit>
        fprintf(2, "grind: fork failed\n");
     aa8:	00001597          	auipc	a1,0x1
     aac:	a2058593          	addi	a1,a1,-1504 # 14c8 <malloc+0x1e4>
     ab0:	4509                	li	a0,2
     ab2:	00000097          	auipc	ra,0x0
     ab6:	746080e7          	jalr	1862(ra) # 11f8 <fprintf>
        exit(7);
     aba:	451d                	li	a0,7
     abc:	00000097          	auipc	ra,0x0
     ac0:	3aa080e7          	jalr	938(ra) # e66 <exit>

0000000000000ac4 <iter>:
  }
}

void
iter()
{
     ac4:	7179                	addi	sp,sp,-48
     ac6:	f406                	sd	ra,40(sp)
     ac8:	f022                	sd	s0,32(sp)
     aca:	ec26                	sd	s1,24(sp)
     acc:	e84a                	sd	s2,16(sp)
     ace:	1800                	addi	s0,sp,48
  unlink("a");
     ad0:	00001517          	auipc	a0,0x1
     ad4:	9d850513          	addi	a0,a0,-1576 # 14a8 <malloc+0x1c4>
     ad8:	00000097          	auipc	ra,0x0
     adc:	3de080e7          	jalr	990(ra) # eb6 <unlink>
  unlink("b");
     ae0:	00001517          	auipc	a0,0x1
     ae4:	97850513          	addi	a0,a0,-1672 # 1458 <malloc+0x174>
     ae8:	00000097          	auipc	ra,0x0
     aec:	3ce080e7          	jalr	974(ra) # eb6 <unlink>
  
  int pid1 = fork();
     af0:	00000097          	auipc	ra,0x0
     af4:	36e080e7          	jalr	878(ra) # e5e <fork>
  if(pid1 < 0){
     af8:	00054e63          	bltz	a0,b14 <iter+0x50>
     afc:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     afe:	e905                	bnez	a0,b2e <iter+0x6a>
    rand_next = 31;
     b00:	47fd                	li	a5,31
     b02:	00001717          	auipc	a4,0x1
     b06:	bcf73723          	sd	a5,-1074(a4) # 16d0 <rand_next>
    go(0);
     b0a:	4501                	li	a0,0
     b0c:	fffff097          	auipc	ra,0xfffff
     b10:	56c080e7          	jalr	1388(ra) # 78 <go>
    printf("grind: fork failed\n");
     b14:	00001517          	auipc	a0,0x1
     b18:	9b450513          	addi	a0,a0,-1612 # 14c8 <malloc+0x1e4>
     b1c:	00000097          	auipc	ra,0x0
     b20:	70a080e7          	jalr	1802(ra) # 1226 <printf>
    exit(1);
     b24:	4505                	li	a0,1
     b26:	00000097          	auipc	ra,0x0
     b2a:	340080e7          	jalr	832(ra) # e66 <exit>
    exit(0);
  }

  int pid2 = fork();
     b2e:	00000097          	auipc	ra,0x0
     b32:	330080e7          	jalr	816(ra) # e5e <fork>
     b36:	892a                	mv	s2,a0
  if(pid2 < 0){
     b38:	00054f63          	bltz	a0,b56 <iter+0x92>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     b3c:	e915                	bnez	a0,b70 <iter+0xac>
    rand_next = 7177;
     b3e:	6789                	lui	a5,0x2
     b40:	c0978793          	addi	a5,a5,-1015 # 1c09 <__BSS_END__+0x131>
     b44:	00001717          	auipc	a4,0x1
     b48:	b8f73623          	sd	a5,-1140(a4) # 16d0 <rand_next>
    go(1);
     b4c:	4505                	li	a0,1
     b4e:	fffff097          	auipc	ra,0xfffff
     b52:	52a080e7          	jalr	1322(ra) # 78 <go>
    printf("grind: fork failed\n");
     b56:	00001517          	auipc	a0,0x1
     b5a:	97250513          	addi	a0,a0,-1678 # 14c8 <malloc+0x1e4>
     b5e:	00000097          	auipc	ra,0x0
     b62:	6c8080e7          	jalr	1736(ra) # 1226 <printf>
    exit(1);
     b66:	4505                	li	a0,1
     b68:	00000097          	auipc	ra,0x0
     b6c:	2fe080e7          	jalr	766(ra) # e66 <exit>
    exit(0);
  }

  int st1 = -1;
     b70:	57fd                	li	a5,-1
     b72:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     b76:	fdc40513          	addi	a0,s0,-36
     b7a:	00000097          	auipc	ra,0x0
     b7e:	2f4080e7          	jalr	756(ra) # e6e <wait>
  if(st1 != 0){
     b82:	fdc42783          	lw	a5,-36(s0)
     b86:	ef99                	bnez	a5,ba4 <iter+0xe0>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     b88:	57fd                	li	a5,-1
     b8a:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     b8e:	fd840513          	addi	a0,s0,-40
     b92:	00000097          	auipc	ra,0x0
     b96:	2dc080e7          	jalr	732(ra) # e6e <wait>

  exit(0);
     b9a:	4501                	li	a0,0
     b9c:	00000097          	auipc	ra,0x0
     ba0:	2ca080e7          	jalr	714(ra) # e66 <exit>
    kill(pid1);
     ba4:	8526                	mv	a0,s1
     ba6:	00000097          	auipc	ra,0x0
     baa:	2f0080e7          	jalr	752(ra) # e96 <kill>
    kill(pid2);
     bae:	854a                	mv	a0,s2
     bb0:	00000097          	auipc	ra,0x0
     bb4:	2e6080e7          	jalr	742(ra) # e96 <kill>
     bb8:	bfc1                	j	b88 <iter+0xc4>

0000000000000bba <main>:
}

int
main()
{
     bba:	1141                	addi	sp,sp,-16
     bbc:	e406                	sd	ra,8(sp)
     bbe:	e022                	sd	s0,0(sp)
     bc0:	0800                	addi	s0,sp,16
     bc2:	a811                	j	bd6 <main+0x1c>
  while(1){
    int pid = fork();
    if(pid == 0){
      iter();
     bc4:	00000097          	auipc	ra,0x0
     bc8:	f00080e7          	jalr	-256(ra) # ac4 <iter>
      exit(0);
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
     bcc:	4551                	li	a0,20
     bce:	00000097          	auipc	ra,0x0
     bd2:	328080e7          	jalr	808(ra) # ef6 <sleep>
    int pid = fork();
     bd6:	00000097          	auipc	ra,0x0
     bda:	288080e7          	jalr	648(ra) # e5e <fork>
    if(pid == 0){
     bde:	d17d                	beqz	a0,bc4 <main+0xa>
    if(pid > 0){
     be0:	fea056e3          	blez	a0,bcc <main+0x12>
      wait(0);
     be4:	4501                	li	a0,0
     be6:	00000097          	auipc	ra,0x0
     bea:	288080e7          	jalr	648(ra) # e6e <wait>
     bee:	bff9                	j	bcc <main+0x12>

0000000000000bf0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     bf0:	1141                	addi	sp,sp,-16
     bf2:	e422                	sd	s0,8(sp)
     bf4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bf6:	87aa                	mv	a5,a0
     bf8:	0585                	addi	a1,a1,1
     bfa:	0785                	addi	a5,a5,1
     bfc:	fff5c703          	lbu	a4,-1(a1)
     c00:	fee78fa3          	sb	a4,-1(a5)
     c04:	fb75                	bnez	a4,bf8 <strcpy+0x8>
    ;
  return os;
}
     c06:	6422                	ld	s0,8(sp)
     c08:	0141                	addi	sp,sp,16
     c0a:	8082                	ret

0000000000000c0c <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c0c:	1141                	addi	sp,sp,-16
     c0e:	e422                	sd	s0,8(sp)
     c10:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c12:	00054783          	lbu	a5,0(a0)
     c16:	cb91                	beqz	a5,c2a <strcmp+0x1e>
     c18:	0005c703          	lbu	a4,0(a1)
     c1c:	00f71763          	bne	a4,a5,c2a <strcmp+0x1e>
    p++, q++;
     c20:	0505                	addi	a0,a0,1
     c22:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c24:	00054783          	lbu	a5,0(a0)
     c28:	fbe5                	bnez	a5,c18 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c2a:	0005c503          	lbu	a0,0(a1)
}
     c2e:	40a7853b          	subw	a0,a5,a0
     c32:	6422                	ld	s0,8(sp)
     c34:	0141                	addi	sp,sp,16
     c36:	8082                	ret

0000000000000c38 <strlen>:

uint
strlen(const char *s)
{
     c38:	1141                	addi	sp,sp,-16
     c3a:	e422                	sd	s0,8(sp)
     c3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c3e:	00054783          	lbu	a5,0(a0)
     c42:	cf91                	beqz	a5,c5e <strlen+0x26>
     c44:	0505                	addi	a0,a0,1
     c46:	87aa                	mv	a5,a0
     c48:	4685                	li	a3,1
     c4a:	9e89                	subw	a3,a3,a0
     c4c:	00f6853b          	addw	a0,a3,a5
     c50:	0785                	addi	a5,a5,1
     c52:	fff7c703          	lbu	a4,-1(a5)
     c56:	fb7d                	bnez	a4,c4c <strlen+0x14>
    ;
  return n;
}
     c58:	6422                	ld	s0,8(sp)
     c5a:	0141                	addi	sp,sp,16
     c5c:	8082                	ret
  for(n = 0; s[n]; n++)
     c5e:	4501                	li	a0,0
     c60:	bfe5                	j	c58 <strlen+0x20>

0000000000000c62 <memset>:

void*
memset(void *dst, int c, uint n)
{
     c62:	1141                	addi	sp,sp,-16
     c64:	e422                	sd	s0,8(sp)
     c66:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c68:	ce09                	beqz	a2,c82 <memset+0x20>
     c6a:	87aa                	mv	a5,a0
     c6c:	fff6071b          	addiw	a4,a2,-1
     c70:	1702                	slli	a4,a4,0x20
     c72:	9301                	srli	a4,a4,0x20
     c74:	0705                	addi	a4,a4,1
     c76:	972a                	add	a4,a4,a0
    cdst[i] = c;
     c78:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c7c:	0785                	addi	a5,a5,1
     c7e:	fee79de3          	bne	a5,a4,c78 <memset+0x16>
  }
  return dst;
}
     c82:	6422                	ld	s0,8(sp)
     c84:	0141                	addi	sp,sp,16
     c86:	8082                	ret

0000000000000c88 <strchr>:

char*
strchr(const char *s, char c)
{
     c88:	1141                	addi	sp,sp,-16
     c8a:	e422                	sd	s0,8(sp)
     c8c:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c8e:	00054783          	lbu	a5,0(a0)
     c92:	cb99                	beqz	a5,ca8 <strchr+0x20>
    if(*s == c)
     c94:	00f58763          	beq	a1,a5,ca2 <strchr+0x1a>
  for(; *s; s++)
     c98:	0505                	addi	a0,a0,1
     c9a:	00054783          	lbu	a5,0(a0)
     c9e:	fbfd                	bnez	a5,c94 <strchr+0xc>
      return (char*)s;
  return 0;
     ca0:	4501                	li	a0,0
}
     ca2:	6422                	ld	s0,8(sp)
     ca4:	0141                	addi	sp,sp,16
     ca6:	8082                	ret
  return 0;
     ca8:	4501                	li	a0,0
     caa:	bfe5                	j	ca2 <strchr+0x1a>

0000000000000cac <gets>:

char*
gets(char *buf, int max)
{
     cac:	711d                	addi	sp,sp,-96
     cae:	ec86                	sd	ra,88(sp)
     cb0:	e8a2                	sd	s0,80(sp)
     cb2:	e4a6                	sd	s1,72(sp)
     cb4:	e0ca                	sd	s2,64(sp)
     cb6:	fc4e                	sd	s3,56(sp)
     cb8:	f852                	sd	s4,48(sp)
     cba:	f456                	sd	s5,40(sp)
     cbc:	f05a                	sd	s6,32(sp)
     cbe:	ec5e                	sd	s7,24(sp)
     cc0:	1080                	addi	s0,sp,96
     cc2:	8baa                	mv	s7,a0
     cc4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     cc6:	892a                	mv	s2,a0
     cc8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     cca:	4aa9                	li	s5,10
     ccc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     cce:	89a6                	mv	s3,s1
     cd0:	2485                	addiw	s1,s1,1
     cd2:	0344d863          	bge	s1,s4,d02 <gets+0x56>
    cc = read(0, &c, 1);
     cd6:	4605                	li	a2,1
     cd8:	faf40593          	addi	a1,s0,-81
     cdc:	4501                	li	a0,0
     cde:	00000097          	auipc	ra,0x0
     ce2:	1a0080e7          	jalr	416(ra) # e7e <read>
    if(cc < 1)
     ce6:	00a05e63          	blez	a0,d02 <gets+0x56>
    buf[i++] = c;
     cea:	faf44783          	lbu	a5,-81(s0)
     cee:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     cf2:	01578763          	beq	a5,s5,d00 <gets+0x54>
     cf6:	0905                	addi	s2,s2,1
     cf8:	fd679be3          	bne	a5,s6,cce <gets+0x22>
  for(i=0; i+1 < max; ){
     cfc:	89a6                	mv	s3,s1
     cfe:	a011                	j	d02 <gets+0x56>
     d00:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d02:	99de                	add	s3,s3,s7
     d04:	00098023          	sb	zero,0(s3)
  return buf;
}
     d08:	855e                	mv	a0,s7
     d0a:	60e6                	ld	ra,88(sp)
     d0c:	6446                	ld	s0,80(sp)
     d0e:	64a6                	ld	s1,72(sp)
     d10:	6906                	ld	s2,64(sp)
     d12:	79e2                	ld	s3,56(sp)
     d14:	7a42                	ld	s4,48(sp)
     d16:	7aa2                	ld	s5,40(sp)
     d18:	7b02                	ld	s6,32(sp)
     d1a:	6be2                	ld	s7,24(sp)
     d1c:	6125                	addi	sp,sp,96
     d1e:	8082                	ret

0000000000000d20 <stat>:

int
stat(const char *n, struct stat *st)
{
     d20:	1101                	addi	sp,sp,-32
     d22:	ec06                	sd	ra,24(sp)
     d24:	e822                	sd	s0,16(sp)
     d26:	e426                	sd	s1,8(sp)
     d28:	e04a                	sd	s2,0(sp)
     d2a:	1000                	addi	s0,sp,32
     d2c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d2e:	4581                	li	a1,0
     d30:	00000097          	auipc	ra,0x0
     d34:	176080e7          	jalr	374(ra) # ea6 <open>
  if(fd < 0)
     d38:	02054563          	bltz	a0,d62 <stat+0x42>
     d3c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d3e:	85ca                	mv	a1,s2
     d40:	00000097          	auipc	ra,0x0
     d44:	17e080e7          	jalr	382(ra) # ebe <fstat>
     d48:	892a                	mv	s2,a0
  close(fd);
     d4a:	8526                	mv	a0,s1
     d4c:	00000097          	auipc	ra,0x0
     d50:	142080e7          	jalr	322(ra) # e8e <close>
  return r;
}
     d54:	854a                	mv	a0,s2
     d56:	60e2                	ld	ra,24(sp)
     d58:	6442                	ld	s0,16(sp)
     d5a:	64a2                	ld	s1,8(sp)
     d5c:	6902                	ld	s2,0(sp)
     d5e:	6105                	addi	sp,sp,32
     d60:	8082                	ret
    return -1;
     d62:	597d                	li	s2,-1
     d64:	bfc5                	j	d54 <stat+0x34>

0000000000000d66 <atoi>:

int
atoi(const char *s)
{
     d66:	1141                	addi	sp,sp,-16
     d68:	e422                	sd	s0,8(sp)
     d6a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d6c:	00054603          	lbu	a2,0(a0)
     d70:	fd06079b          	addiw	a5,a2,-48
     d74:	0ff7f793          	andi	a5,a5,255
     d78:	4725                	li	a4,9
     d7a:	02f76963          	bltu	a4,a5,dac <atoi+0x46>
     d7e:	86aa                	mv	a3,a0
  n = 0;
     d80:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     d82:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     d84:	0685                	addi	a3,a3,1
     d86:	0025179b          	slliw	a5,a0,0x2
     d8a:	9fa9                	addw	a5,a5,a0
     d8c:	0017979b          	slliw	a5,a5,0x1
     d90:	9fb1                	addw	a5,a5,a2
     d92:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d96:	0006c603          	lbu	a2,0(a3)
     d9a:	fd06071b          	addiw	a4,a2,-48
     d9e:	0ff77713          	andi	a4,a4,255
     da2:	fee5f1e3          	bgeu	a1,a4,d84 <atoi+0x1e>
  return n;
}
     da6:	6422                	ld	s0,8(sp)
     da8:	0141                	addi	sp,sp,16
     daa:	8082                	ret
  n = 0;
     dac:	4501                	li	a0,0
     dae:	bfe5                	j	da6 <atoi+0x40>

0000000000000db0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     db0:	1141                	addi	sp,sp,-16
     db2:	e422                	sd	s0,8(sp)
     db4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     db6:	02b57663          	bgeu	a0,a1,de2 <memmove+0x32>
    while(n-- > 0)
     dba:	02c05163          	blez	a2,ddc <memmove+0x2c>
     dbe:	fff6079b          	addiw	a5,a2,-1
     dc2:	1782                	slli	a5,a5,0x20
     dc4:	9381                	srli	a5,a5,0x20
     dc6:	0785                	addi	a5,a5,1
     dc8:	97aa                	add	a5,a5,a0
  dst = vdst;
     dca:	872a                	mv	a4,a0
      *dst++ = *src++;
     dcc:	0585                	addi	a1,a1,1
     dce:	0705                	addi	a4,a4,1
     dd0:	fff5c683          	lbu	a3,-1(a1)
     dd4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     dd8:	fee79ae3          	bne	a5,a4,dcc <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     ddc:	6422                	ld	s0,8(sp)
     dde:	0141                	addi	sp,sp,16
     de0:	8082                	ret
    dst += n;
     de2:	00c50733          	add	a4,a0,a2
    src += n;
     de6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     de8:	fec05ae3          	blez	a2,ddc <memmove+0x2c>
     dec:	fff6079b          	addiw	a5,a2,-1
     df0:	1782                	slli	a5,a5,0x20
     df2:	9381                	srli	a5,a5,0x20
     df4:	fff7c793          	not	a5,a5
     df8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     dfa:	15fd                	addi	a1,a1,-1
     dfc:	177d                	addi	a4,a4,-1
     dfe:	0005c683          	lbu	a3,0(a1)
     e02:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e06:	fee79ae3          	bne	a5,a4,dfa <memmove+0x4a>
     e0a:	bfc9                	j	ddc <memmove+0x2c>

0000000000000e0c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e0c:	1141                	addi	sp,sp,-16
     e0e:	e422                	sd	s0,8(sp)
     e10:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e12:	ca05                	beqz	a2,e42 <memcmp+0x36>
     e14:	fff6069b          	addiw	a3,a2,-1
     e18:	1682                	slli	a3,a3,0x20
     e1a:	9281                	srli	a3,a3,0x20
     e1c:	0685                	addi	a3,a3,1
     e1e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e20:	00054783          	lbu	a5,0(a0)
     e24:	0005c703          	lbu	a4,0(a1)
     e28:	00e79863          	bne	a5,a4,e38 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e2c:	0505                	addi	a0,a0,1
    p2++;
     e2e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e30:	fed518e3          	bne	a0,a3,e20 <memcmp+0x14>
  }
  return 0;
     e34:	4501                	li	a0,0
     e36:	a019                	j	e3c <memcmp+0x30>
      return *p1 - *p2;
     e38:	40e7853b          	subw	a0,a5,a4
}
     e3c:	6422                	ld	s0,8(sp)
     e3e:	0141                	addi	sp,sp,16
     e40:	8082                	ret
  return 0;
     e42:	4501                	li	a0,0
     e44:	bfe5                	j	e3c <memcmp+0x30>

0000000000000e46 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e46:	1141                	addi	sp,sp,-16
     e48:	e406                	sd	ra,8(sp)
     e4a:	e022                	sd	s0,0(sp)
     e4c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e4e:	00000097          	auipc	ra,0x0
     e52:	f62080e7          	jalr	-158(ra) # db0 <memmove>
}
     e56:	60a2                	ld	ra,8(sp)
     e58:	6402                	ld	s0,0(sp)
     e5a:	0141                	addi	sp,sp,16
     e5c:	8082                	ret

0000000000000e5e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e5e:	4885                	li	a7,1
 ecall
     e60:	00000073          	ecall
 ret
     e64:	8082                	ret

0000000000000e66 <exit>:
.global exit
exit:
 li a7, SYS_exit
     e66:	4889                	li	a7,2
 ecall
     e68:	00000073          	ecall
 ret
     e6c:	8082                	ret

0000000000000e6e <wait>:
.global wait
wait:
 li a7, SYS_wait
     e6e:	488d                	li	a7,3
 ecall
     e70:	00000073          	ecall
 ret
     e74:	8082                	ret

0000000000000e76 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e76:	4891                	li	a7,4
 ecall
     e78:	00000073          	ecall
 ret
     e7c:	8082                	ret

0000000000000e7e <read>:
.global read
read:
 li a7, SYS_read
     e7e:	4895                	li	a7,5
 ecall
     e80:	00000073          	ecall
 ret
     e84:	8082                	ret

0000000000000e86 <write>:
.global write
write:
 li a7, SYS_write
     e86:	48c1                	li	a7,16
 ecall
     e88:	00000073          	ecall
 ret
     e8c:	8082                	ret

0000000000000e8e <close>:
.global close
close:
 li a7, SYS_close
     e8e:	48d5                	li	a7,21
 ecall
     e90:	00000073          	ecall
 ret
     e94:	8082                	ret

0000000000000e96 <kill>:
.global kill
kill:
 li a7, SYS_kill
     e96:	4899                	li	a7,6
 ecall
     e98:	00000073          	ecall
 ret
     e9c:	8082                	ret

0000000000000e9e <exec>:
.global exec
exec:
 li a7, SYS_exec
     e9e:	489d                	li	a7,7
 ecall
     ea0:	00000073          	ecall
 ret
     ea4:	8082                	ret

0000000000000ea6 <open>:
.global open
open:
 li a7, SYS_open
     ea6:	48bd                	li	a7,15
 ecall
     ea8:	00000073          	ecall
 ret
     eac:	8082                	ret

0000000000000eae <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     eae:	48c5                	li	a7,17
 ecall
     eb0:	00000073          	ecall
 ret
     eb4:	8082                	ret

0000000000000eb6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     eb6:	48c9                	li	a7,18
 ecall
     eb8:	00000073          	ecall
 ret
     ebc:	8082                	ret

0000000000000ebe <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     ebe:	48a1                	li	a7,8
 ecall
     ec0:	00000073          	ecall
 ret
     ec4:	8082                	ret

0000000000000ec6 <link>:
.global link
link:
 li a7, SYS_link
     ec6:	48cd                	li	a7,19
 ecall
     ec8:	00000073          	ecall
 ret
     ecc:	8082                	ret

0000000000000ece <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     ece:	48d1                	li	a7,20
 ecall
     ed0:	00000073          	ecall
 ret
     ed4:	8082                	ret

0000000000000ed6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     ed6:	48a5                	li	a7,9
 ecall
     ed8:	00000073          	ecall
 ret
     edc:	8082                	ret

0000000000000ede <dup>:
.global dup
dup:
 li a7, SYS_dup
     ede:	48a9                	li	a7,10
 ecall
     ee0:	00000073          	ecall
 ret
     ee4:	8082                	ret

0000000000000ee6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     ee6:	48ad                	li	a7,11
 ecall
     ee8:	00000073          	ecall
 ret
     eec:	8082                	ret

0000000000000eee <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     eee:	48b1                	li	a7,12
 ecall
     ef0:	00000073          	ecall
 ret
     ef4:	8082                	ret

0000000000000ef6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     ef6:	48b5                	li	a7,13
 ecall
     ef8:	00000073          	ecall
 ret
     efc:	8082                	ret

0000000000000efe <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     efe:	48b9                	li	a7,14
 ecall
     f00:	00000073          	ecall
 ret
     f04:	8082                	ret

0000000000000f06 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
     f06:	48d9                	li	a7,22
 ecall
     f08:	00000073          	ecall
 ret
     f0c:	8082                	ret

0000000000000f0e <yield>:
.global yield
yield:
 li a7, SYS_yield
     f0e:	48dd                	li	a7,23
 ecall
     f10:	00000073          	ecall
 ret
     f14:	8082                	ret

0000000000000f16 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
     f16:	48e1                	li	a7,24
 ecall
     f18:	00000073          	ecall
 ret
     f1c:	8082                	ret

0000000000000f1e <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
     f1e:	48e5                	li	a7,25
 ecall
     f20:	00000073          	ecall
 ret
     f24:	8082                	ret

0000000000000f26 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
     f26:	48e9                	li	a7,26
 ecall
     f28:	00000073          	ecall
 ret
     f2c:	8082                	ret

0000000000000f2e <ps>:
.global ps
ps:
 li a7, SYS_ps
     f2e:	48ed                	li	a7,27
 ecall
     f30:	00000073          	ecall
 ret
     f34:	8082                	ret

0000000000000f36 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
     f36:	48f1                	li	a7,28
 ecall
     f38:	00000073          	ecall
 ret
     f3c:	8082                	ret

0000000000000f3e <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
     f3e:	48f5                	li	a7,29
 ecall
     f40:	00000073          	ecall
 ret
     f44:	8082                	ret

0000000000000f46 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
     f46:	48f9                	li	a7,30
 ecall
     f48:	00000073          	ecall
 ret
     f4c:	8082                	ret

0000000000000f4e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f4e:	1101                	addi	sp,sp,-32
     f50:	ec06                	sd	ra,24(sp)
     f52:	e822                	sd	s0,16(sp)
     f54:	1000                	addi	s0,sp,32
     f56:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f5a:	4605                	li	a2,1
     f5c:	fef40593          	addi	a1,s0,-17
     f60:	00000097          	auipc	ra,0x0
     f64:	f26080e7          	jalr	-218(ra) # e86 <write>
}
     f68:	60e2                	ld	ra,24(sp)
     f6a:	6442                	ld	s0,16(sp)
     f6c:	6105                	addi	sp,sp,32
     f6e:	8082                	ret

0000000000000f70 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f70:	7139                	addi	sp,sp,-64
     f72:	fc06                	sd	ra,56(sp)
     f74:	f822                	sd	s0,48(sp)
     f76:	f426                	sd	s1,40(sp)
     f78:	f04a                	sd	s2,32(sp)
     f7a:	ec4e                	sd	s3,24(sp)
     f7c:	0080                	addi	s0,sp,64
     f7e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f80:	c299                	beqz	a3,f86 <printint+0x16>
     f82:	0805c863          	bltz	a1,1012 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f86:	2581                	sext.w	a1,a1
  neg = 0;
     f88:	4881                	li	a7,0
     f8a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f8e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f90:	2601                	sext.w	a2,a2
     f92:	00000517          	auipc	a0,0x0
     f96:	72650513          	addi	a0,a0,1830 # 16b8 <digits>
     f9a:	883a                	mv	a6,a4
     f9c:	2705                	addiw	a4,a4,1
     f9e:	02c5f7bb          	remuw	a5,a1,a2
     fa2:	1782                	slli	a5,a5,0x20
     fa4:	9381                	srli	a5,a5,0x20
     fa6:	97aa                	add	a5,a5,a0
     fa8:	0007c783          	lbu	a5,0(a5)
     fac:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     fb0:	0005879b          	sext.w	a5,a1
     fb4:	02c5d5bb          	divuw	a1,a1,a2
     fb8:	0685                	addi	a3,a3,1
     fba:	fec7f0e3          	bgeu	a5,a2,f9a <printint+0x2a>
  if(neg)
     fbe:	00088b63          	beqz	a7,fd4 <printint+0x64>
    buf[i++] = '-';
     fc2:	fd040793          	addi	a5,s0,-48
     fc6:	973e                	add	a4,a4,a5
     fc8:	02d00793          	li	a5,45
     fcc:	fef70823          	sb	a5,-16(a4)
     fd0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     fd4:	02e05863          	blez	a4,1004 <printint+0x94>
     fd8:	fc040793          	addi	a5,s0,-64
     fdc:	00e78933          	add	s2,a5,a4
     fe0:	fff78993          	addi	s3,a5,-1
     fe4:	99ba                	add	s3,s3,a4
     fe6:	377d                	addiw	a4,a4,-1
     fe8:	1702                	slli	a4,a4,0x20
     fea:	9301                	srli	a4,a4,0x20
     fec:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     ff0:	fff94583          	lbu	a1,-1(s2)
     ff4:	8526                	mv	a0,s1
     ff6:	00000097          	auipc	ra,0x0
     ffa:	f58080e7          	jalr	-168(ra) # f4e <putc>
  while(--i >= 0)
     ffe:	197d                	addi	s2,s2,-1
    1000:	ff3918e3          	bne	s2,s3,ff0 <printint+0x80>
}
    1004:	70e2                	ld	ra,56(sp)
    1006:	7442                	ld	s0,48(sp)
    1008:	74a2                	ld	s1,40(sp)
    100a:	7902                	ld	s2,32(sp)
    100c:	69e2                	ld	s3,24(sp)
    100e:	6121                	addi	sp,sp,64
    1010:	8082                	ret
    x = -xx;
    1012:	40b005bb          	negw	a1,a1
    neg = 1;
    1016:	4885                	li	a7,1
    x = -xx;
    1018:	bf8d                	j	f8a <printint+0x1a>

000000000000101a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    101a:	7119                	addi	sp,sp,-128
    101c:	fc86                	sd	ra,120(sp)
    101e:	f8a2                	sd	s0,112(sp)
    1020:	f4a6                	sd	s1,104(sp)
    1022:	f0ca                	sd	s2,96(sp)
    1024:	ecce                	sd	s3,88(sp)
    1026:	e8d2                	sd	s4,80(sp)
    1028:	e4d6                	sd	s5,72(sp)
    102a:	e0da                	sd	s6,64(sp)
    102c:	fc5e                	sd	s7,56(sp)
    102e:	f862                	sd	s8,48(sp)
    1030:	f466                	sd	s9,40(sp)
    1032:	f06a                	sd	s10,32(sp)
    1034:	ec6e                	sd	s11,24(sp)
    1036:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    1038:	0005c903          	lbu	s2,0(a1)
    103c:	18090f63          	beqz	s2,11da <vprintf+0x1c0>
    1040:	8aaa                	mv	s5,a0
    1042:	8b32                	mv	s6,a2
    1044:	00158493          	addi	s1,a1,1
  state = 0;
    1048:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    104a:	02500a13          	li	s4,37
      if(c == 'd'){
    104e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1052:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    1056:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    105a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    105e:	00000b97          	auipc	s7,0x0
    1062:	65ab8b93          	addi	s7,s7,1626 # 16b8 <digits>
    1066:	a839                	j	1084 <vprintf+0x6a>
        putc(fd, c);
    1068:	85ca                	mv	a1,s2
    106a:	8556                	mv	a0,s5
    106c:	00000097          	auipc	ra,0x0
    1070:	ee2080e7          	jalr	-286(ra) # f4e <putc>
    1074:	a019                	j	107a <vprintf+0x60>
    } else if(state == '%'){
    1076:	01498f63          	beq	s3,s4,1094 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    107a:	0485                	addi	s1,s1,1
    107c:	fff4c903          	lbu	s2,-1(s1)
    1080:	14090d63          	beqz	s2,11da <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    1084:	0009079b          	sext.w	a5,s2
    if(state == 0){
    1088:	fe0997e3          	bnez	s3,1076 <vprintf+0x5c>
      if(c == '%'){
    108c:	fd479ee3          	bne	a5,s4,1068 <vprintf+0x4e>
        state = '%';
    1090:	89be                	mv	s3,a5
    1092:	b7e5                	j	107a <vprintf+0x60>
      if(c == 'd'){
    1094:	05878063          	beq	a5,s8,10d4 <vprintf+0xba>
      } else if(c == 'l') {
    1098:	05978c63          	beq	a5,s9,10f0 <vprintf+0xd6>
      } else if(c == 'x') {
    109c:	07a78863          	beq	a5,s10,110c <vprintf+0xf2>
      } else if(c == 'p') {
    10a0:	09b78463          	beq	a5,s11,1128 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    10a4:	07300713          	li	a4,115
    10a8:	0ce78663          	beq	a5,a4,1174 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    10ac:	06300713          	li	a4,99
    10b0:	0ee78e63          	beq	a5,a4,11ac <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    10b4:	11478863          	beq	a5,s4,11c4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    10b8:	85d2                	mv	a1,s4
    10ba:	8556                	mv	a0,s5
    10bc:	00000097          	auipc	ra,0x0
    10c0:	e92080e7          	jalr	-366(ra) # f4e <putc>
        putc(fd, c);
    10c4:	85ca                	mv	a1,s2
    10c6:	8556                	mv	a0,s5
    10c8:	00000097          	auipc	ra,0x0
    10cc:	e86080e7          	jalr	-378(ra) # f4e <putc>
      }
      state = 0;
    10d0:	4981                	li	s3,0
    10d2:	b765                	j	107a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    10d4:	008b0913          	addi	s2,s6,8
    10d8:	4685                	li	a3,1
    10da:	4629                	li	a2,10
    10dc:	000b2583          	lw	a1,0(s6)
    10e0:	8556                	mv	a0,s5
    10e2:	00000097          	auipc	ra,0x0
    10e6:	e8e080e7          	jalr	-370(ra) # f70 <printint>
    10ea:	8b4a                	mv	s6,s2
      state = 0;
    10ec:	4981                	li	s3,0
    10ee:	b771                	j	107a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    10f0:	008b0913          	addi	s2,s6,8
    10f4:	4681                	li	a3,0
    10f6:	4629                	li	a2,10
    10f8:	000b2583          	lw	a1,0(s6)
    10fc:	8556                	mv	a0,s5
    10fe:	00000097          	auipc	ra,0x0
    1102:	e72080e7          	jalr	-398(ra) # f70 <printint>
    1106:	8b4a                	mv	s6,s2
      state = 0;
    1108:	4981                	li	s3,0
    110a:	bf85                	j	107a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    110c:	008b0913          	addi	s2,s6,8
    1110:	4681                	li	a3,0
    1112:	4641                	li	a2,16
    1114:	000b2583          	lw	a1,0(s6)
    1118:	8556                	mv	a0,s5
    111a:	00000097          	auipc	ra,0x0
    111e:	e56080e7          	jalr	-426(ra) # f70 <printint>
    1122:	8b4a                	mv	s6,s2
      state = 0;
    1124:	4981                	li	s3,0
    1126:	bf91                	j	107a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    1128:	008b0793          	addi	a5,s6,8
    112c:	f8f43423          	sd	a5,-120(s0)
    1130:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1134:	03000593          	li	a1,48
    1138:	8556                	mv	a0,s5
    113a:	00000097          	auipc	ra,0x0
    113e:	e14080e7          	jalr	-492(ra) # f4e <putc>
  putc(fd, 'x');
    1142:	85ea                	mv	a1,s10
    1144:	8556                	mv	a0,s5
    1146:	00000097          	auipc	ra,0x0
    114a:	e08080e7          	jalr	-504(ra) # f4e <putc>
    114e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1150:	03c9d793          	srli	a5,s3,0x3c
    1154:	97de                	add	a5,a5,s7
    1156:	0007c583          	lbu	a1,0(a5)
    115a:	8556                	mv	a0,s5
    115c:	00000097          	auipc	ra,0x0
    1160:	df2080e7          	jalr	-526(ra) # f4e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1164:	0992                	slli	s3,s3,0x4
    1166:	397d                	addiw	s2,s2,-1
    1168:	fe0914e3          	bnez	s2,1150 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    116c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1170:	4981                	li	s3,0
    1172:	b721                	j	107a <vprintf+0x60>
        s = va_arg(ap, char*);
    1174:	008b0993          	addi	s3,s6,8
    1178:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    117c:	02090163          	beqz	s2,119e <vprintf+0x184>
        while(*s != 0){
    1180:	00094583          	lbu	a1,0(s2)
    1184:	c9a1                	beqz	a1,11d4 <vprintf+0x1ba>
          putc(fd, *s);
    1186:	8556                	mv	a0,s5
    1188:	00000097          	auipc	ra,0x0
    118c:	dc6080e7          	jalr	-570(ra) # f4e <putc>
          s++;
    1190:	0905                	addi	s2,s2,1
        while(*s != 0){
    1192:	00094583          	lbu	a1,0(s2)
    1196:	f9e5                	bnez	a1,1186 <vprintf+0x16c>
        s = va_arg(ap, char*);
    1198:	8b4e                	mv	s6,s3
      state = 0;
    119a:	4981                	li	s3,0
    119c:	bdf9                	j	107a <vprintf+0x60>
          s = "(null)";
    119e:	00000917          	auipc	s2,0x0
    11a2:	51290913          	addi	s2,s2,1298 # 16b0 <malloc+0x3cc>
        while(*s != 0){
    11a6:	02800593          	li	a1,40
    11aa:	bff1                	j	1186 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    11ac:	008b0913          	addi	s2,s6,8
    11b0:	000b4583          	lbu	a1,0(s6)
    11b4:	8556                	mv	a0,s5
    11b6:	00000097          	auipc	ra,0x0
    11ba:	d98080e7          	jalr	-616(ra) # f4e <putc>
    11be:	8b4a                	mv	s6,s2
      state = 0;
    11c0:	4981                	li	s3,0
    11c2:	bd65                	j	107a <vprintf+0x60>
        putc(fd, c);
    11c4:	85d2                	mv	a1,s4
    11c6:	8556                	mv	a0,s5
    11c8:	00000097          	auipc	ra,0x0
    11cc:	d86080e7          	jalr	-634(ra) # f4e <putc>
      state = 0;
    11d0:	4981                	li	s3,0
    11d2:	b565                	j	107a <vprintf+0x60>
        s = va_arg(ap, char*);
    11d4:	8b4e                	mv	s6,s3
      state = 0;
    11d6:	4981                	li	s3,0
    11d8:	b54d                	j	107a <vprintf+0x60>
    }
  }
}
    11da:	70e6                	ld	ra,120(sp)
    11dc:	7446                	ld	s0,112(sp)
    11de:	74a6                	ld	s1,104(sp)
    11e0:	7906                	ld	s2,96(sp)
    11e2:	69e6                	ld	s3,88(sp)
    11e4:	6a46                	ld	s4,80(sp)
    11e6:	6aa6                	ld	s5,72(sp)
    11e8:	6b06                	ld	s6,64(sp)
    11ea:	7be2                	ld	s7,56(sp)
    11ec:	7c42                	ld	s8,48(sp)
    11ee:	7ca2                	ld	s9,40(sp)
    11f0:	7d02                	ld	s10,32(sp)
    11f2:	6de2                	ld	s11,24(sp)
    11f4:	6109                	addi	sp,sp,128
    11f6:	8082                	ret

00000000000011f8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    11f8:	715d                	addi	sp,sp,-80
    11fa:	ec06                	sd	ra,24(sp)
    11fc:	e822                	sd	s0,16(sp)
    11fe:	1000                	addi	s0,sp,32
    1200:	e010                	sd	a2,0(s0)
    1202:	e414                	sd	a3,8(s0)
    1204:	e818                	sd	a4,16(s0)
    1206:	ec1c                	sd	a5,24(s0)
    1208:	03043023          	sd	a6,32(s0)
    120c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1210:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1214:	8622                	mv	a2,s0
    1216:	00000097          	auipc	ra,0x0
    121a:	e04080e7          	jalr	-508(ra) # 101a <vprintf>
}
    121e:	60e2                	ld	ra,24(sp)
    1220:	6442                	ld	s0,16(sp)
    1222:	6161                	addi	sp,sp,80
    1224:	8082                	ret

0000000000001226 <printf>:

void
printf(const char *fmt, ...)
{
    1226:	711d                	addi	sp,sp,-96
    1228:	ec06                	sd	ra,24(sp)
    122a:	e822                	sd	s0,16(sp)
    122c:	1000                	addi	s0,sp,32
    122e:	e40c                	sd	a1,8(s0)
    1230:	e810                	sd	a2,16(s0)
    1232:	ec14                	sd	a3,24(s0)
    1234:	f018                	sd	a4,32(s0)
    1236:	f41c                	sd	a5,40(s0)
    1238:	03043823          	sd	a6,48(s0)
    123c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1240:	00840613          	addi	a2,s0,8
    1244:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1248:	85aa                	mv	a1,a0
    124a:	4505                	li	a0,1
    124c:	00000097          	auipc	ra,0x0
    1250:	dce080e7          	jalr	-562(ra) # 101a <vprintf>
}
    1254:	60e2                	ld	ra,24(sp)
    1256:	6442                	ld	s0,16(sp)
    1258:	6125                	addi	sp,sp,96
    125a:	8082                	ret

000000000000125c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    125c:	1141                	addi	sp,sp,-16
    125e:	e422                	sd	s0,8(sp)
    1260:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1262:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1266:	00000797          	auipc	a5,0x0
    126a:	4727b783          	ld	a5,1138(a5) # 16d8 <freep>
    126e:	a805                	j	129e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1270:	4618                	lw	a4,8(a2)
    1272:	9db9                	addw	a1,a1,a4
    1274:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1278:	6398                	ld	a4,0(a5)
    127a:	6318                	ld	a4,0(a4)
    127c:	fee53823          	sd	a4,-16(a0)
    1280:	a091                	j	12c4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1282:	ff852703          	lw	a4,-8(a0)
    1286:	9e39                	addw	a2,a2,a4
    1288:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    128a:	ff053703          	ld	a4,-16(a0)
    128e:	e398                	sd	a4,0(a5)
    1290:	a099                	j	12d6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1292:	6398                	ld	a4,0(a5)
    1294:	00e7e463          	bltu	a5,a4,129c <free+0x40>
    1298:	00e6ea63          	bltu	a3,a4,12ac <free+0x50>
{
    129c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    129e:	fed7fae3          	bgeu	a5,a3,1292 <free+0x36>
    12a2:	6398                	ld	a4,0(a5)
    12a4:	00e6e463          	bltu	a3,a4,12ac <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12a8:	fee7eae3          	bltu	a5,a4,129c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    12ac:	ff852583          	lw	a1,-8(a0)
    12b0:	6390                	ld	a2,0(a5)
    12b2:	02059713          	slli	a4,a1,0x20
    12b6:	9301                	srli	a4,a4,0x20
    12b8:	0712                	slli	a4,a4,0x4
    12ba:	9736                	add	a4,a4,a3
    12bc:	fae60ae3          	beq	a2,a4,1270 <free+0x14>
    bp->s.ptr = p->s.ptr;
    12c0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    12c4:	4790                	lw	a2,8(a5)
    12c6:	02061713          	slli	a4,a2,0x20
    12ca:	9301                	srli	a4,a4,0x20
    12cc:	0712                	slli	a4,a4,0x4
    12ce:	973e                	add	a4,a4,a5
    12d0:	fae689e3          	beq	a3,a4,1282 <free+0x26>
  } else
    p->s.ptr = bp;
    12d4:	e394                	sd	a3,0(a5)
  freep = p;
    12d6:	00000717          	auipc	a4,0x0
    12da:	40f73123          	sd	a5,1026(a4) # 16d8 <freep>
}
    12de:	6422                	ld	s0,8(sp)
    12e0:	0141                	addi	sp,sp,16
    12e2:	8082                	ret

00000000000012e4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    12e4:	7139                	addi	sp,sp,-64
    12e6:	fc06                	sd	ra,56(sp)
    12e8:	f822                	sd	s0,48(sp)
    12ea:	f426                	sd	s1,40(sp)
    12ec:	f04a                	sd	s2,32(sp)
    12ee:	ec4e                	sd	s3,24(sp)
    12f0:	e852                	sd	s4,16(sp)
    12f2:	e456                	sd	s5,8(sp)
    12f4:	e05a                	sd	s6,0(sp)
    12f6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    12f8:	02051493          	slli	s1,a0,0x20
    12fc:	9081                	srli	s1,s1,0x20
    12fe:	04bd                	addi	s1,s1,15
    1300:	8091                	srli	s1,s1,0x4
    1302:	0014899b          	addiw	s3,s1,1
    1306:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1308:	00000517          	auipc	a0,0x0
    130c:	3d053503          	ld	a0,976(a0) # 16d8 <freep>
    1310:	c515                	beqz	a0,133c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1312:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1314:	4798                	lw	a4,8(a5)
    1316:	02977f63          	bgeu	a4,s1,1354 <malloc+0x70>
    131a:	8a4e                	mv	s4,s3
    131c:	0009871b          	sext.w	a4,s3
    1320:	6685                	lui	a3,0x1
    1322:	00d77363          	bgeu	a4,a3,1328 <malloc+0x44>
    1326:	6a05                	lui	s4,0x1
    1328:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    132c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1330:	00000917          	auipc	s2,0x0
    1334:	3a890913          	addi	s2,s2,936 # 16d8 <freep>
  if(p == (char*)-1)
    1338:	5afd                	li	s5,-1
    133a:	a88d                	j	13ac <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    133c:	00000797          	auipc	a5,0x0
    1340:	78c78793          	addi	a5,a5,1932 # 1ac8 <base>
    1344:	00000717          	auipc	a4,0x0
    1348:	38f73a23          	sd	a5,916(a4) # 16d8 <freep>
    134c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    134e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1352:	b7e1                	j	131a <malloc+0x36>
      if(p->s.size == nunits)
    1354:	02e48b63          	beq	s1,a4,138a <malloc+0xa6>
        p->s.size -= nunits;
    1358:	4137073b          	subw	a4,a4,s3
    135c:	c798                	sw	a4,8(a5)
        p += p->s.size;
    135e:	1702                	slli	a4,a4,0x20
    1360:	9301                	srli	a4,a4,0x20
    1362:	0712                	slli	a4,a4,0x4
    1364:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1366:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    136a:	00000717          	auipc	a4,0x0
    136e:	36a73723          	sd	a0,878(a4) # 16d8 <freep>
      return (void*)(p + 1);
    1372:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1376:	70e2                	ld	ra,56(sp)
    1378:	7442                	ld	s0,48(sp)
    137a:	74a2                	ld	s1,40(sp)
    137c:	7902                	ld	s2,32(sp)
    137e:	69e2                	ld	s3,24(sp)
    1380:	6a42                	ld	s4,16(sp)
    1382:	6aa2                	ld	s5,8(sp)
    1384:	6b02                	ld	s6,0(sp)
    1386:	6121                	addi	sp,sp,64
    1388:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    138a:	6398                	ld	a4,0(a5)
    138c:	e118                	sd	a4,0(a0)
    138e:	bff1                	j	136a <malloc+0x86>
  hp->s.size = nu;
    1390:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1394:	0541                	addi	a0,a0,16
    1396:	00000097          	auipc	ra,0x0
    139a:	ec6080e7          	jalr	-314(ra) # 125c <free>
  return freep;
    139e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    13a2:	d971                	beqz	a0,1376 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13a4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13a6:	4798                	lw	a4,8(a5)
    13a8:	fa9776e3          	bgeu	a4,s1,1354 <malloc+0x70>
    if(p == freep)
    13ac:	00093703          	ld	a4,0(s2)
    13b0:	853e                	mv	a0,a5
    13b2:	fef719e3          	bne	a4,a5,13a4 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    13b6:	8552                	mv	a0,s4
    13b8:	00000097          	auipc	ra,0x0
    13bc:	b36080e7          	jalr	-1226(ra) # eee <sbrk>
  if(p == (char*)-1)
    13c0:	fd5518e3          	bne	a0,s5,1390 <malloc+0xac>
        return 0;
    13c4:	4501                	li	a0,0
    13c6:	bf45                	j	1376 <malloc+0x92>
