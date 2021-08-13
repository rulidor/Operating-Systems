
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
  fprintf(2, "$ ");
      10:	00001597          	auipc	a1,0x1
      14:	41858593          	addi	a1,a1,1048 # 1428 <malloc+0xec>
      18:	4509                	li	a0,2
      1a:	00001097          	auipc	ra,0x1
      1e:	236080e7          	jalr	566(ra) # 1250 <fprintf>
  memset(buf, 0, nbuf);
      22:	864a                	mv	a2,s2
      24:	4581                	li	a1,0
      26:	8526                	mv	a0,s1
      28:	00001097          	auipc	ra,0x1
      2c:	cca080e7          	jalr	-822(ra) # cf2 <memset>
  gets(buf, nbuf);
      30:	85ca                	mv	a1,s2
      32:	8526                	mv	a0,s1
      34:	00001097          	auipc	ra,0x1
      38:	d04080e7          	jalr	-764(ra) # d38 <gets>
  if(buf[0] == 0) // EOF
      3c:	0004c503          	lbu	a0,0(s1)
      40:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      44:	40a00533          	neg	a0,a0
      48:	60e2                	ld	ra,24(sp)
      4a:	6442                	ld	s0,16(sp)
      4c:	64a2                	ld	s1,8(sp)
      4e:	6902                	ld	s2,0(sp)
      50:	6105                	addi	sp,sp,32
      52:	8082                	ret

0000000000000054 <panic>:
  exit(0);
}

void
panic(char *s)
{
      54:	1141                	addi	sp,sp,-16
      56:	e406                	sd	ra,8(sp)
      58:	e022                	sd	s0,0(sp)
      5a:	0800                	addi	s0,sp,16
      5c:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      5e:	00001597          	auipc	a1,0x1
      62:	3d258593          	addi	a1,a1,978 # 1430 <malloc+0xf4>
      66:	4509                	li	a0,2
      68:	00001097          	auipc	ra,0x1
      6c:	1e8080e7          	jalr	488(ra) # 1250 <fprintf>
  exit(1);
      70:	4505                	li	a0,1
      72:	00001097          	auipc	ra,0x1
      76:	e7c080e7          	jalr	-388(ra) # eee <exit>

000000000000007a <fork1>:
}

int
fork1(void)
{
      7a:	1141                	addi	sp,sp,-16
      7c:	e406                	sd	ra,8(sp)
      7e:	e022                	sd	s0,0(sp)
      80:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      82:	00001097          	auipc	ra,0x1
      86:	e64080e7          	jalr	-412(ra) # ee6 <fork>
  if(pid == -1)
      8a:	57fd                	li	a5,-1
      8c:	00f50663          	beq	a0,a5,98 <fork1+0x1e>
    panic("fork");
  return pid;
}
      90:	60a2                	ld	ra,8(sp)
      92:	6402                	ld	s0,0(sp)
      94:	0141                	addi	sp,sp,16
      96:	8082                	ret
    panic("fork");
      98:	00001517          	auipc	a0,0x1
      9c:	3a050513          	addi	a0,a0,928 # 1438 <malloc+0xfc>
      a0:	00000097          	auipc	ra,0x0
      a4:	fb4080e7          	jalr	-76(ra) # 54 <panic>

00000000000000a8 <runcmd>:
{
      a8:	7159                	addi	sp,sp,-112
      aa:	f486                	sd	ra,104(sp)
      ac:	f0a2                	sd	s0,96(sp)
      ae:	eca6                	sd	s1,88(sp)
      b0:	e8ca                	sd	s2,80(sp)
      b2:	e4ce                	sd	s3,72(sp)
      b4:	e0d2                	sd	s4,64(sp)
      b6:	fc56                	sd	s5,56(sp)
      b8:	f85a                	sd	s6,48(sp)
      ba:	f45e                	sd	s7,40(sp)
      bc:	f062                	sd	s8,32(sp)
      be:	ec66                	sd	s9,24(sp)
      c0:	1880                	addi	s0,sp,112
  if(cmd == 0)
      c2:	c10d                	beqz	a0,e4 <runcmd+0x3c>
      c4:	84aa                	mv	s1,a0
  switch(cmd->type){
      c6:	4118                	lw	a4,0(a0)
      c8:	4795                	li	a5,5
      ca:	02e7e263          	bltu	a5,a4,ee <runcmd+0x46>
      ce:	00056783          	lwu	a5,0(a0)
      d2:	078a                	slli	a5,a5,0x2
      d4:	00001717          	auipc	a4,0x1
      d8:	48c70713          	addi	a4,a4,1164 # 1560 <malloc+0x224>
      dc:	97ba                	add	a5,a5,a4
      de:	439c                	lw	a5,0(a5)
      e0:	97ba                	add	a5,a5,a4
      e2:	8782                	jr	a5
    exit(1);
      e4:	4505                	li	a0,1
      e6:	00001097          	auipc	ra,0x1
      ea:	e08080e7          	jalr	-504(ra) # eee <exit>
    panic("runcmd");
      ee:	00001517          	auipc	a0,0x1
      f2:	35250513          	addi	a0,a0,850 # 1440 <malloc+0x104>
      f6:	00000097          	auipc	ra,0x0
      fa:	f5e080e7          	jalr	-162(ra) # 54 <panic>
    if(ecmd->argv[0] == 0)
      fe:	00853b03          	ld	s6,8(a0)
     102:	060b0263          	beqz	s6,166 <runcmd+0xbe>
     executePath(ecmd->argv[0], ecmd->argv);
     106:	00850493          	addi	s1,a0,8
  }
  return cmd;
}

void executePath (char *cmd, char** argv) {
  if (cmd[0] != '/'){
     10a:	000b4703          	lbu	a4,0(s6)
     10e:	02f00793          	li	a5,47
     112:	12f70963          	beq	a4,a5,244 <runcmd+0x19c>
     116:	8c0a                	mv	s8,sp
    int fd = open("/path", O_RDONLY);
     118:	4581                	li	a1,0
     11a:	00001517          	auipc	a0,0x1
     11e:	32e50513          	addi	a0,a0,814 # 1448 <malloc+0x10c>
     122:	00001097          	auipc	ra,0x1
     126:	e0c080e7          	jalr	-500(ra) # f2e <open>
     12a:	89aa                	mv	s3,a0
    if (fd < 0) {
     12c:	04054263          	bltz	a0,170 <runcmd+0xc8>
          fprintf(2, "could not open the path file\n");
          exit(0);
    }

    int maxSize = 1000; //max number of chars to put in buffer
    char buffer[maxSize];
     130:	c1010113          	addi	sp,sp,-1008
     134:	890a                	mv	s2,sp

    if ( read(fd,buffer,maxSize) < 0 )
     136:	3e800613          	li	a2,1000
     13a:	858a                	mv	a1,sp
     13c:	00001097          	auipc	ra,0x1
     140:	dca080e7          	jalr	-566(ra) # f06 <read>
     144:	04054463          	bltz	a0,18c <runcmd+0xe4>
        fprintf(2, "could not open the path file\n");
        close(fd);
        exit(0);
    }
    
    close(fd);
     148:	854e                	mv	a0,s3
     14a:	00001097          	auipc	ra,0x1
     14e:	dcc080e7          	jalr	-564(ra) # f16 <close>

    buffer[maxSize-1] = 0;
     152:	3e0903a3          	sb	zero,999(s2)

    char* path = buffer;
    int cmd_size = strlen(cmd);
     156:	855a                	mv	a0,s6
     158:	00001097          	auipc	ra,0x1
     15c:	b70080e7          	jalr	-1168(ra) # cc8 <strlen>
     160:	00050a9b          	sext.w	s5,a0
    int path_size;
    char* currPath;
    int totalSize; //path_size + cmd_Size
    while( *path!=0 ){
     164:	a86d                	j	21e <runcmd+0x176>
      exit(1);
     166:	4505                	li	a0,1
     168:	00001097          	auipc	ra,0x1
     16c:	d86080e7          	jalr	-634(ra) # eee <exit>
          fprintf(2, "could not open the path file\n");
     170:	00001597          	auipc	a1,0x1
     174:	2e058593          	addi	a1,a1,736 # 1450 <malloc+0x114>
     178:	4509                	li	a0,2
     17a:	00001097          	auipc	ra,0x1
     17e:	0d6080e7          	jalr	214(ra) # 1250 <fprintf>
          exit(0);
     182:	4501                	li	a0,0
     184:	00001097          	auipc	ra,0x1
     188:	d6a080e7          	jalr	-662(ra) # eee <exit>
        fprintf(2, "could not open the path file\n");
     18c:	00001597          	auipc	a1,0x1
     190:	2c458593          	addi	a1,a1,708 # 1450 <malloc+0x114>
     194:	4509                	li	a0,2
     196:	00001097          	auipc	ra,0x1
     19a:	0ba080e7          	jalr	186(ra) # 1250 <fprintf>
        close(fd);
     19e:	854e                	mv	a0,s3
     1a0:	00001097          	auipc	ra,0x1
     1a4:	d76080e7          	jalr	-650(ra) # f16 <close>
        exit(0);
     1a8:	4501                	li	a0,0
     1aa:	00001097          	auipc	ra,0x1
     1ae:	d44080e7          	jalr	-700(ra) # eee <exit>
    while( *path!=0 ){
     1b2:	8b8a                	mv	s7,sp
      currPath = strchr(path, ':'); // currPath points to ":"
     1b4:	03a00593          	li	a1,58
     1b8:	854a                	mv	a0,s2
     1ba:	00001097          	auipc	ra,0x1
     1be:	b5a080e7          	jalr	-1190(ra) # d14 <strchr>
     1c2:	89aa                	mv	s3,a0
      *currPath = 0;
     1c4:	00050023          	sb	zero,0(a0)
      path_size = strlen(path);
     1c8:	854a                	mv	a0,s2
     1ca:	00001097          	auipc	ra,0x1
     1ce:	afe080e7          	jalr	-1282(ra) # cc8 <strlen>
     1d2:	00050a1b          	sext.w	s4,a0
      totalSize = path_size + cmd_size;
     1d6:	00aa87bb          	addw	a5,s5,a0
     1da:	00078c9b          	sext.w	s9,a5

      char pathAndCmd[totalSize + 1];
     1de:	2785                	addiw	a5,a5,1
     1e0:	07bd                	addi	a5,a5,15
     1e2:	9bc1                	andi	a5,a5,-16
     1e4:	40f10133          	sub	sp,sp,a5

      memmove(pathAndCmd, path, path_size); //copy the path
     1e8:	8652                	mv	a2,s4
     1ea:	85ca                	mv	a1,s2
     1ec:	850a                	mv	a0,sp
     1ee:	00001097          	auipc	ra,0x1
     1f2:	c4e080e7          	jalr	-946(ra) # e3c <memmove>
      memmove(pathAndCmd + path_size, cmd, cmd_size); //after path, copies the cmd
     1f6:	8656                	mv	a2,s5
     1f8:	85da                	mv	a1,s6
     1fa:	01410533          	add	a0,sp,s4
     1fe:	00001097          	auipc	ra,0x1
     202:	c3e080e7          	jalr	-962(ra) # e3c <memmove>
      pathAndCmd[totalSize] = 0; //put null to end the string
     206:	9c8a                	add	s9,s9,sp
     208:	000c8023          	sb	zero,0(s9)
      exec(pathAndCmd, argv); //should not return if executed succeed. else:
     20c:	85a6                	mv	a1,s1
     20e:	850a                	mv	a0,sp
     210:	00001097          	auipc	ra,0x1
     214:	d16080e7          	jalr	-746(ra) # f26 <exec>
      path = currPath + 1;
     218:	00198913          	addi	s2,s3,1
     21c:	815e                	mv	sp,s7
    while( *path!=0 ){
     21e:	00094783          	lbu	a5,0(s2)
     222:	fbc1                	bnez	a5,1b2 <runcmd+0x10a>
     224:	8162                	mv	sp,s8
    }
  }
  else
    exec(cmd, argv);

  fprintf(2, "exec %s failed\n", cmd);
     226:	865a                	mv	a2,s6
     228:	00001597          	auipc	a1,0x1
     22c:	24858593          	addi	a1,a1,584 # 1470 <malloc+0x134>
     230:	4509                	li	a0,2
     232:	00001097          	auipc	ra,0x1
     236:	01e080e7          	jalr	30(ra) # 1250 <fprintf>
  exit(0);
     23a:	4501                	li	a0,0
     23c:	00001097          	auipc	ra,0x1
     240:	cb2080e7          	jalr	-846(ra) # eee <exit>
    exec(cmd, argv);
     244:	85a6                	mv	a1,s1
     246:	855a                	mv	a0,s6
     248:	00001097          	auipc	ra,0x1
     24c:	cde080e7          	jalr	-802(ra) # f26 <exec>
     250:	bfd9                	j	226 <runcmd+0x17e>
    close(rcmd->fd);
     252:	5148                	lw	a0,36(a0)
     254:	00001097          	auipc	ra,0x1
     258:	cc2080e7          	jalr	-830(ra) # f16 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     25c:	508c                	lw	a1,32(s1)
     25e:	6888                	ld	a0,16(s1)
     260:	00001097          	auipc	ra,0x1
     264:	cce080e7          	jalr	-818(ra) # f2e <open>
     268:	00054763          	bltz	a0,276 <runcmd+0x1ce>
    runcmd(rcmd->cmd);
     26c:	6488                	ld	a0,8(s1)
     26e:	00000097          	auipc	ra,0x0
     272:	e3a080e7          	jalr	-454(ra) # a8 <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     276:	6890                	ld	a2,16(s1)
     278:	00001597          	auipc	a1,0x1
     27c:	20858593          	addi	a1,a1,520 # 1480 <malloc+0x144>
     280:	4509                	li	a0,2
     282:	00001097          	auipc	ra,0x1
     286:	fce080e7          	jalr	-50(ra) # 1250 <fprintf>
      exit(1);
     28a:	4505                	li	a0,1
     28c:	00001097          	auipc	ra,0x1
     290:	c62080e7          	jalr	-926(ra) # eee <exit>
    if(fork1() == 0)
     294:	00000097          	auipc	ra,0x0
     298:	de6080e7          	jalr	-538(ra) # 7a <fork1>
     29c:	c919                	beqz	a0,2b2 <runcmd+0x20a>
    wait(0);
     29e:	4501                	li	a0,0
     2a0:	00001097          	auipc	ra,0x1
     2a4:	c56080e7          	jalr	-938(ra) # ef6 <wait>
    runcmd(lcmd->right);
     2a8:	6888                	ld	a0,16(s1)
     2aa:	00000097          	auipc	ra,0x0
     2ae:	dfe080e7          	jalr	-514(ra) # a8 <runcmd>
      runcmd(lcmd->left);
     2b2:	6488                	ld	a0,8(s1)
     2b4:	00000097          	auipc	ra,0x0
     2b8:	df4080e7          	jalr	-524(ra) # a8 <runcmd>
    if(pipe(p) < 0)
     2bc:	f9840513          	addi	a0,s0,-104
     2c0:	00001097          	auipc	ra,0x1
     2c4:	c3e080e7          	jalr	-962(ra) # efe <pipe>
     2c8:	04054363          	bltz	a0,30e <runcmd+0x266>
    if(fork1() == 0){
     2cc:	00000097          	auipc	ra,0x0
     2d0:	dae080e7          	jalr	-594(ra) # 7a <fork1>
     2d4:	c529                	beqz	a0,31e <runcmd+0x276>
    if(fork1() == 0){
     2d6:	00000097          	auipc	ra,0x0
     2da:	da4080e7          	jalr	-604(ra) # 7a <fork1>
     2de:	cd25                	beqz	a0,356 <runcmd+0x2ae>
    close(p[0]);
     2e0:	f9842503          	lw	a0,-104(s0)
     2e4:	00001097          	auipc	ra,0x1
     2e8:	c32080e7          	jalr	-974(ra) # f16 <close>
    close(p[1]);
     2ec:	f9c42503          	lw	a0,-100(s0)
     2f0:	00001097          	auipc	ra,0x1
     2f4:	c26080e7          	jalr	-986(ra) # f16 <close>
    wait(0);
     2f8:	4501                	li	a0,0
     2fa:	00001097          	auipc	ra,0x1
     2fe:	bfc080e7          	jalr	-1028(ra) # ef6 <wait>
    wait(0);
     302:	4501                	li	a0,0
     304:	00001097          	auipc	ra,0x1
     308:	bf2080e7          	jalr	-1038(ra) # ef6 <wait>
    break;
     30c:	b73d                	j	23a <runcmd+0x192>
      panic("pipe");
     30e:	00001517          	auipc	a0,0x1
     312:	18250513          	addi	a0,a0,386 # 1490 <malloc+0x154>
     316:	00000097          	auipc	ra,0x0
     31a:	d3e080e7          	jalr	-706(ra) # 54 <panic>
      close(1);
     31e:	4505                	li	a0,1
     320:	00001097          	auipc	ra,0x1
     324:	bf6080e7          	jalr	-1034(ra) # f16 <close>
      dup(p[1]);
     328:	f9c42503          	lw	a0,-100(s0)
     32c:	00001097          	auipc	ra,0x1
     330:	c3a080e7          	jalr	-966(ra) # f66 <dup>
      close(p[0]);
     334:	f9842503          	lw	a0,-104(s0)
     338:	00001097          	auipc	ra,0x1
     33c:	bde080e7          	jalr	-1058(ra) # f16 <close>
      close(p[1]);
     340:	f9c42503          	lw	a0,-100(s0)
     344:	00001097          	auipc	ra,0x1
     348:	bd2080e7          	jalr	-1070(ra) # f16 <close>
      runcmd(pcmd->left);
     34c:	6488                	ld	a0,8(s1)
     34e:	00000097          	auipc	ra,0x0
     352:	d5a080e7          	jalr	-678(ra) # a8 <runcmd>
      close(0);
     356:	00001097          	auipc	ra,0x1
     35a:	bc0080e7          	jalr	-1088(ra) # f16 <close>
      dup(p[0]);
     35e:	f9842503          	lw	a0,-104(s0)
     362:	00001097          	auipc	ra,0x1
     366:	c04080e7          	jalr	-1020(ra) # f66 <dup>
      close(p[0]);
     36a:	f9842503          	lw	a0,-104(s0)
     36e:	00001097          	auipc	ra,0x1
     372:	ba8080e7          	jalr	-1112(ra) # f16 <close>
      close(p[1]);
     376:	f9c42503          	lw	a0,-100(s0)
     37a:	00001097          	auipc	ra,0x1
     37e:	b9c080e7          	jalr	-1124(ra) # f16 <close>
      runcmd(pcmd->right);
     382:	6888                	ld	a0,16(s1)
     384:	00000097          	auipc	ra,0x0
     388:	d24080e7          	jalr	-732(ra) # a8 <runcmd>
    if(fork1() == 0)
     38c:	00000097          	auipc	ra,0x0
     390:	cee080e7          	jalr	-786(ra) # 7a <fork1>
     394:	ea0513e3          	bnez	a0,23a <runcmd+0x192>
      runcmd(bcmd->cmd);
     398:	6488                	ld	a0,8(s1)
     39a:	00000097          	auipc	ra,0x0
     39e:	d0e080e7          	jalr	-754(ra) # a8 <runcmd>

00000000000003a2 <execcmd>:
{
     3a2:	1101                	addi	sp,sp,-32
     3a4:	ec06                	sd	ra,24(sp)
     3a6:	e822                	sd	s0,16(sp)
     3a8:	e426                	sd	s1,8(sp)
     3aa:	1000                	addi	s0,sp,32
  cmd = malloc(sizeof(*cmd));
     3ac:	0a800513          	li	a0,168
     3b0:	00001097          	auipc	ra,0x1
     3b4:	f8c080e7          	jalr	-116(ra) # 133c <malloc>
     3b8:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3ba:	0a800613          	li	a2,168
     3be:	4581                	li	a1,0
     3c0:	00001097          	auipc	ra,0x1
     3c4:	932080e7          	jalr	-1742(ra) # cf2 <memset>
  cmd->type = EXEC;
     3c8:	4785                	li	a5,1
     3ca:	c09c                	sw	a5,0(s1)
}
     3cc:	8526                	mv	a0,s1
     3ce:	60e2                	ld	ra,24(sp)
     3d0:	6442                	ld	s0,16(sp)
     3d2:	64a2                	ld	s1,8(sp)
     3d4:	6105                	addi	sp,sp,32
     3d6:	8082                	ret

00000000000003d8 <redircmd>:
{
     3d8:	7139                	addi	sp,sp,-64
     3da:	fc06                	sd	ra,56(sp)
     3dc:	f822                	sd	s0,48(sp)
     3de:	f426                	sd	s1,40(sp)
     3e0:	f04a                	sd	s2,32(sp)
     3e2:	ec4e                	sd	s3,24(sp)
     3e4:	e852                	sd	s4,16(sp)
     3e6:	e456                	sd	s5,8(sp)
     3e8:	e05a                	sd	s6,0(sp)
     3ea:	0080                	addi	s0,sp,64
     3ec:	8b2a                	mv	s6,a0
     3ee:	8aae                	mv	s5,a1
     3f0:	8a32                	mv	s4,a2
     3f2:	89b6                	mv	s3,a3
     3f4:	893a                	mv	s2,a4
  cmd = malloc(sizeof(*cmd));
     3f6:	02800513          	li	a0,40
     3fa:	00001097          	auipc	ra,0x1
     3fe:	f42080e7          	jalr	-190(ra) # 133c <malloc>
     402:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     404:	02800613          	li	a2,40
     408:	4581                	li	a1,0
     40a:	00001097          	auipc	ra,0x1
     40e:	8e8080e7          	jalr	-1816(ra) # cf2 <memset>
  cmd->type = REDIR;
     412:	4789                	li	a5,2
     414:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     416:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     41a:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     41e:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     422:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     426:	0324a223          	sw	s2,36(s1)
}
     42a:	8526                	mv	a0,s1
     42c:	70e2                	ld	ra,56(sp)
     42e:	7442                	ld	s0,48(sp)
     430:	74a2                	ld	s1,40(sp)
     432:	7902                	ld	s2,32(sp)
     434:	69e2                	ld	s3,24(sp)
     436:	6a42                	ld	s4,16(sp)
     438:	6aa2                	ld	s5,8(sp)
     43a:	6b02                	ld	s6,0(sp)
     43c:	6121                	addi	sp,sp,64
     43e:	8082                	ret

0000000000000440 <pipecmd>:
{
     440:	7179                	addi	sp,sp,-48
     442:	f406                	sd	ra,40(sp)
     444:	f022                	sd	s0,32(sp)
     446:	ec26                	sd	s1,24(sp)
     448:	e84a                	sd	s2,16(sp)
     44a:	e44e                	sd	s3,8(sp)
     44c:	1800                	addi	s0,sp,48
     44e:	89aa                	mv	s3,a0
     450:	892e                	mv	s2,a1
  cmd = malloc(sizeof(*cmd));
     452:	4561                	li	a0,24
     454:	00001097          	auipc	ra,0x1
     458:	ee8080e7          	jalr	-280(ra) # 133c <malloc>
     45c:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     45e:	4661                	li	a2,24
     460:	4581                	li	a1,0
     462:	00001097          	auipc	ra,0x1
     466:	890080e7          	jalr	-1904(ra) # cf2 <memset>
  cmd->type = PIPE;
     46a:	478d                	li	a5,3
     46c:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     46e:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     472:	0124b823          	sd	s2,16(s1)
}
     476:	8526                	mv	a0,s1
     478:	70a2                	ld	ra,40(sp)
     47a:	7402                	ld	s0,32(sp)
     47c:	64e2                	ld	s1,24(sp)
     47e:	6942                	ld	s2,16(sp)
     480:	69a2                	ld	s3,8(sp)
     482:	6145                	addi	sp,sp,48
     484:	8082                	ret

0000000000000486 <listcmd>:
{
     486:	7179                	addi	sp,sp,-48
     488:	f406                	sd	ra,40(sp)
     48a:	f022                	sd	s0,32(sp)
     48c:	ec26                	sd	s1,24(sp)
     48e:	e84a                	sd	s2,16(sp)
     490:	e44e                	sd	s3,8(sp)
     492:	1800                	addi	s0,sp,48
     494:	89aa                	mv	s3,a0
     496:	892e                	mv	s2,a1
  cmd = malloc(sizeof(*cmd));
     498:	4561                	li	a0,24
     49a:	00001097          	auipc	ra,0x1
     49e:	ea2080e7          	jalr	-350(ra) # 133c <malloc>
     4a2:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     4a4:	4661                	li	a2,24
     4a6:	4581                	li	a1,0
     4a8:	00001097          	auipc	ra,0x1
     4ac:	84a080e7          	jalr	-1974(ra) # cf2 <memset>
  cmd->type = LIST;
     4b0:	4791                	li	a5,4
     4b2:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     4b4:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     4b8:	0124b823          	sd	s2,16(s1)
}
     4bc:	8526                	mv	a0,s1
     4be:	70a2                	ld	ra,40(sp)
     4c0:	7402                	ld	s0,32(sp)
     4c2:	64e2                	ld	s1,24(sp)
     4c4:	6942                	ld	s2,16(sp)
     4c6:	69a2                	ld	s3,8(sp)
     4c8:	6145                	addi	sp,sp,48
     4ca:	8082                	ret

00000000000004cc <backcmd>:
{
     4cc:	1101                	addi	sp,sp,-32
     4ce:	ec06                	sd	ra,24(sp)
     4d0:	e822                	sd	s0,16(sp)
     4d2:	e426                	sd	s1,8(sp)
     4d4:	e04a                	sd	s2,0(sp)
     4d6:	1000                	addi	s0,sp,32
     4d8:	892a                	mv	s2,a0
  cmd = malloc(sizeof(*cmd));
     4da:	4541                	li	a0,16
     4dc:	00001097          	auipc	ra,0x1
     4e0:	e60080e7          	jalr	-416(ra) # 133c <malloc>
     4e4:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     4e6:	4641                	li	a2,16
     4e8:	4581                	li	a1,0
     4ea:	00001097          	auipc	ra,0x1
     4ee:	808080e7          	jalr	-2040(ra) # cf2 <memset>
  cmd->type = BACK;
     4f2:	4795                	li	a5,5
     4f4:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     4f6:	0124b423          	sd	s2,8(s1)
}
     4fa:	8526                	mv	a0,s1
     4fc:	60e2                	ld	ra,24(sp)
     4fe:	6442                	ld	s0,16(sp)
     500:	64a2                	ld	s1,8(sp)
     502:	6902                	ld	s2,0(sp)
     504:	6105                	addi	sp,sp,32
     506:	8082                	ret

0000000000000508 <gettoken>:
{
     508:	7139                	addi	sp,sp,-64
     50a:	fc06                	sd	ra,56(sp)
     50c:	f822                	sd	s0,48(sp)
     50e:	f426                	sd	s1,40(sp)
     510:	f04a                	sd	s2,32(sp)
     512:	ec4e                	sd	s3,24(sp)
     514:	e852                	sd	s4,16(sp)
     516:	e456                	sd	s5,8(sp)
     518:	e05a                	sd	s6,0(sp)
     51a:	0080                	addi	s0,sp,64
     51c:	8a2a                	mv	s4,a0
     51e:	892e                	mv	s2,a1
     520:	8ab2                	mv	s5,a2
     522:	8b36                	mv	s6,a3
  s = *ps;
     524:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     526:	00001997          	auipc	s3,0x1
     52a:	09298993          	addi	s3,s3,146 # 15b8 <whitespace>
     52e:	00b4fd63          	bgeu	s1,a1,548 <gettoken+0x40>
     532:	0004c583          	lbu	a1,0(s1)
     536:	854e                	mv	a0,s3
     538:	00000097          	auipc	ra,0x0
     53c:	7dc080e7          	jalr	2012(ra) # d14 <strchr>
     540:	c501                	beqz	a0,548 <gettoken+0x40>
    s++;
     542:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     544:	fe9917e3          	bne	s2,s1,532 <gettoken+0x2a>
  if(q)
     548:	000a8463          	beqz	s5,550 <gettoken+0x48>
    *q = s;
     54c:	009ab023          	sd	s1,0(s5)
  ret = *s;
     550:	0004c783          	lbu	a5,0(s1)
     554:	00078a9b          	sext.w	s5,a5
  switch(*s){
     558:	03c00713          	li	a4,60
     55c:	06f76563          	bltu	a4,a5,5c6 <gettoken+0xbe>
     560:	03a00713          	li	a4,58
     564:	00f76e63          	bltu	a4,a5,580 <gettoken+0x78>
     568:	cf89                	beqz	a5,582 <gettoken+0x7a>
     56a:	02600713          	li	a4,38
     56e:	00e78963          	beq	a5,a4,580 <gettoken+0x78>
     572:	fd87879b          	addiw	a5,a5,-40
     576:	0ff7f793          	andi	a5,a5,255
     57a:	4705                	li	a4,1
     57c:	06f76c63          	bltu	a4,a5,5f4 <gettoken+0xec>
    s++;
     580:	0485                	addi	s1,s1,1
  if(eq)
     582:	000b0463          	beqz	s6,58a <gettoken+0x82>
    *eq = s;
     586:	009b3023          	sd	s1,0(s6)
  while(s < es && strchr(whitespace, *s))
     58a:	00001997          	auipc	s3,0x1
     58e:	02e98993          	addi	s3,s3,46 # 15b8 <whitespace>
     592:	0124fd63          	bgeu	s1,s2,5ac <gettoken+0xa4>
     596:	0004c583          	lbu	a1,0(s1)
     59a:	854e                	mv	a0,s3
     59c:	00000097          	auipc	ra,0x0
     5a0:	778080e7          	jalr	1912(ra) # d14 <strchr>
     5a4:	c501                	beqz	a0,5ac <gettoken+0xa4>
    s++;
     5a6:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     5a8:	fe9917e3          	bne	s2,s1,596 <gettoken+0x8e>
  *ps = s;
     5ac:	009a3023          	sd	s1,0(s4)
}
     5b0:	8556                	mv	a0,s5
     5b2:	70e2                	ld	ra,56(sp)
     5b4:	7442                	ld	s0,48(sp)
     5b6:	74a2                	ld	s1,40(sp)
     5b8:	7902                	ld	s2,32(sp)
     5ba:	69e2                	ld	s3,24(sp)
     5bc:	6a42                	ld	s4,16(sp)
     5be:	6aa2                	ld	s5,8(sp)
     5c0:	6b02                	ld	s6,0(sp)
     5c2:	6121                	addi	sp,sp,64
     5c4:	8082                	ret
  switch(*s){
     5c6:	03e00713          	li	a4,62
     5ca:	02e79163          	bne	a5,a4,5ec <gettoken+0xe4>
    s++;
     5ce:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     5d2:	0014c703          	lbu	a4,1(s1)
     5d6:	03e00793          	li	a5,62
      s++;
     5da:	0489                	addi	s1,s1,2
      ret = '+';
     5dc:	02b00a93          	li	s5,43
    if(*s == '>'){
     5e0:	faf701e3          	beq	a4,a5,582 <gettoken+0x7a>
    s++;
     5e4:	84b6                	mv	s1,a3
  ret = *s;
     5e6:	03e00a93          	li	s5,62
     5ea:	bf61                	j	582 <gettoken+0x7a>
  switch(*s){
     5ec:	07c00713          	li	a4,124
     5f0:	f8e788e3          	beq	a5,a4,580 <gettoken+0x78>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     5f4:	00001997          	auipc	s3,0x1
     5f8:	fc498993          	addi	s3,s3,-60 # 15b8 <whitespace>
     5fc:	00001a97          	auipc	s5,0x1
     600:	fb4a8a93          	addi	s5,s5,-76 # 15b0 <symbols>
     604:	0324f563          	bgeu	s1,s2,62e <gettoken+0x126>
     608:	0004c583          	lbu	a1,0(s1)
     60c:	854e                	mv	a0,s3
     60e:	00000097          	auipc	ra,0x0
     612:	706080e7          	jalr	1798(ra) # d14 <strchr>
     616:	e505                	bnez	a0,63e <gettoken+0x136>
     618:	0004c583          	lbu	a1,0(s1)
     61c:	8556                	mv	a0,s5
     61e:	00000097          	auipc	ra,0x0
     622:	6f6080e7          	jalr	1782(ra) # d14 <strchr>
     626:	e909                	bnez	a0,638 <gettoken+0x130>
      s++;
     628:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     62a:	fc991fe3          	bne	s2,s1,608 <gettoken+0x100>
  if(eq)
     62e:	06100a93          	li	s5,97
     632:	f40b1ae3          	bnez	s6,586 <gettoken+0x7e>
     636:	bf9d                	j	5ac <gettoken+0xa4>
    ret = 'a';
     638:	06100a93          	li	s5,97
     63c:	b799                	j	582 <gettoken+0x7a>
     63e:	06100a93          	li	s5,97
     642:	b781                	j	582 <gettoken+0x7a>

0000000000000644 <peek>:
{
     644:	7139                	addi	sp,sp,-64
     646:	fc06                	sd	ra,56(sp)
     648:	f822                	sd	s0,48(sp)
     64a:	f426                	sd	s1,40(sp)
     64c:	f04a                	sd	s2,32(sp)
     64e:	ec4e                	sd	s3,24(sp)
     650:	e852                	sd	s4,16(sp)
     652:	e456                	sd	s5,8(sp)
     654:	0080                	addi	s0,sp,64
     656:	8a2a                	mv	s4,a0
     658:	892e                	mv	s2,a1
     65a:	8ab2                	mv	s5,a2
  s = *ps;
     65c:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     65e:	00001997          	auipc	s3,0x1
     662:	f5a98993          	addi	s3,s3,-166 # 15b8 <whitespace>
     666:	00b4fd63          	bgeu	s1,a1,680 <peek+0x3c>
     66a:	0004c583          	lbu	a1,0(s1)
     66e:	854e                	mv	a0,s3
     670:	00000097          	auipc	ra,0x0
     674:	6a4080e7          	jalr	1700(ra) # d14 <strchr>
     678:	c501                	beqz	a0,680 <peek+0x3c>
    s++;
     67a:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     67c:	fe9917e3          	bne	s2,s1,66a <peek+0x26>
  *ps = s;
     680:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     684:	0004c583          	lbu	a1,0(s1)
     688:	4501                	li	a0,0
     68a:	e991                	bnez	a1,69e <peek+0x5a>
}
     68c:	70e2                	ld	ra,56(sp)
     68e:	7442                	ld	s0,48(sp)
     690:	74a2                	ld	s1,40(sp)
     692:	7902                	ld	s2,32(sp)
     694:	69e2                	ld	s3,24(sp)
     696:	6a42                	ld	s4,16(sp)
     698:	6aa2                	ld	s5,8(sp)
     69a:	6121                	addi	sp,sp,64
     69c:	8082                	ret
  return *s && strchr(toks, *s);
     69e:	8556                	mv	a0,s5
     6a0:	00000097          	auipc	ra,0x0
     6a4:	674080e7          	jalr	1652(ra) # d14 <strchr>
     6a8:	00a03533          	snez	a0,a0
     6ac:	b7c5                	j	68c <peek+0x48>

00000000000006ae <parseredirs>:
{
     6ae:	7159                	addi	sp,sp,-112
     6b0:	f486                	sd	ra,104(sp)
     6b2:	f0a2                	sd	s0,96(sp)
     6b4:	eca6                	sd	s1,88(sp)
     6b6:	e8ca                	sd	s2,80(sp)
     6b8:	e4ce                	sd	s3,72(sp)
     6ba:	e0d2                	sd	s4,64(sp)
     6bc:	fc56                	sd	s5,56(sp)
     6be:	f85a                	sd	s6,48(sp)
     6c0:	f45e                	sd	s7,40(sp)
     6c2:	f062                	sd	s8,32(sp)
     6c4:	ec66                	sd	s9,24(sp)
     6c6:	1880                	addi	s0,sp,112
     6c8:	8a2a                	mv	s4,a0
     6ca:	89ae                	mv	s3,a1
     6cc:	8932                	mv	s2,a2
  while(peek(ps, es, "<>")){
     6ce:	00001b97          	auipc	s7,0x1
     6d2:	deab8b93          	addi	s7,s7,-534 # 14b8 <malloc+0x17c>
    if(gettoken(ps, es, &q, &eq) != 'a')
     6d6:	06100c13          	li	s8,97
    switch(tok){
     6da:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     6de:	a02d                	j	708 <parseredirs+0x5a>
      panic("missing file for redirection");
     6e0:	00001517          	auipc	a0,0x1
     6e4:	db850513          	addi	a0,a0,-584 # 1498 <malloc+0x15c>
     6e8:	00000097          	auipc	ra,0x0
     6ec:	96c080e7          	jalr	-1684(ra) # 54 <panic>
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     6f0:	4701                	li	a4,0
     6f2:	4681                	li	a3,0
     6f4:	f9043603          	ld	a2,-112(s0)
     6f8:	f9843583          	ld	a1,-104(s0)
     6fc:	8552                	mv	a0,s4
     6fe:	00000097          	auipc	ra,0x0
     702:	cda080e7          	jalr	-806(ra) # 3d8 <redircmd>
     706:	8a2a                	mv	s4,a0
    switch(tok){
     708:	03e00b13          	li	s6,62
     70c:	02b00a93          	li	s5,43
  while(peek(ps, es, "<>")){
     710:	865e                	mv	a2,s7
     712:	85ca                	mv	a1,s2
     714:	854e                	mv	a0,s3
     716:	00000097          	auipc	ra,0x0
     71a:	f2e080e7          	jalr	-210(ra) # 644 <peek>
     71e:	c925                	beqz	a0,78e <parseredirs+0xe0>
    tok = gettoken(ps, es, 0, 0);
     720:	4681                	li	a3,0
     722:	4601                	li	a2,0
     724:	85ca                	mv	a1,s2
     726:	854e                	mv	a0,s3
     728:	00000097          	auipc	ra,0x0
     72c:	de0080e7          	jalr	-544(ra) # 508 <gettoken>
     730:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     732:	f9040693          	addi	a3,s0,-112
     736:	f9840613          	addi	a2,s0,-104
     73a:	85ca                	mv	a1,s2
     73c:	854e                	mv	a0,s3
     73e:	00000097          	auipc	ra,0x0
     742:	dca080e7          	jalr	-566(ra) # 508 <gettoken>
     746:	f9851de3          	bne	a0,s8,6e0 <parseredirs+0x32>
    switch(tok){
     74a:	fb9483e3          	beq	s1,s9,6f0 <parseredirs+0x42>
     74e:	03648263          	beq	s1,s6,772 <parseredirs+0xc4>
     752:	fb549fe3          	bne	s1,s5,710 <parseredirs+0x62>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     756:	4705                	li	a4,1
     758:	20100693          	li	a3,513
     75c:	f9043603          	ld	a2,-112(s0)
     760:	f9843583          	ld	a1,-104(s0)
     764:	8552                	mv	a0,s4
     766:	00000097          	auipc	ra,0x0
     76a:	c72080e7          	jalr	-910(ra) # 3d8 <redircmd>
     76e:	8a2a                	mv	s4,a0
      break;
     770:	bf61                	j	708 <parseredirs+0x5a>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     772:	4705                	li	a4,1
     774:	60100693          	li	a3,1537
     778:	f9043603          	ld	a2,-112(s0)
     77c:	f9843583          	ld	a1,-104(s0)
     780:	8552                	mv	a0,s4
     782:	00000097          	auipc	ra,0x0
     786:	c56080e7          	jalr	-938(ra) # 3d8 <redircmd>
     78a:	8a2a                	mv	s4,a0
      break;
     78c:	bfb5                	j	708 <parseredirs+0x5a>
}
     78e:	8552                	mv	a0,s4
     790:	70a6                	ld	ra,104(sp)
     792:	7406                	ld	s0,96(sp)
     794:	64e6                	ld	s1,88(sp)
     796:	6946                	ld	s2,80(sp)
     798:	69a6                	ld	s3,72(sp)
     79a:	6a06                	ld	s4,64(sp)
     79c:	7ae2                	ld	s5,56(sp)
     79e:	7b42                	ld	s6,48(sp)
     7a0:	7ba2                	ld	s7,40(sp)
     7a2:	7c02                	ld	s8,32(sp)
     7a4:	6ce2                	ld	s9,24(sp)
     7a6:	6165                	addi	sp,sp,112
     7a8:	8082                	ret

00000000000007aa <parseexec>:
{
     7aa:	7159                	addi	sp,sp,-112
     7ac:	f486                	sd	ra,104(sp)
     7ae:	f0a2                	sd	s0,96(sp)
     7b0:	eca6                	sd	s1,88(sp)
     7b2:	e8ca                	sd	s2,80(sp)
     7b4:	e4ce                	sd	s3,72(sp)
     7b6:	e0d2                	sd	s4,64(sp)
     7b8:	fc56                	sd	s5,56(sp)
     7ba:	f85a                	sd	s6,48(sp)
     7bc:	f45e                	sd	s7,40(sp)
     7be:	f062                	sd	s8,32(sp)
     7c0:	ec66                	sd	s9,24(sp)
     7c2:	1880                	addi	s0,sp,112
     7c4:	8a2a                	mv	s4,a0
     7c6:	8aae                	mv	s5,a1
  if(peek(ps, es, "("))
     7c8:	00001617          	auipc	a2,0x1
     7cc:	cf860613          	addi	a2,a2,-776 # 14c0 <malloc+0x184>
     7d0:	00000097          	auipc	ra,0x0
     7d4:	e74080e7          	jalr	-396(ra) # 644 <peek>
     7d8:	e905                	bnez	a0,808 <parseexec+0x5e>
     7da:	89aa                	mv	s3,a0
  ret = execcmd();
     7dc:	00000097          	auipc	ra,0x0
     7e0:	bc6080e7          	jalr	-1082(ra) # 3a2 <execcmd>
     7e4:	8c2a                	mv	s8,a0
  ret = parseredirs(ret, ps, es);
     7e6:	8656                	mv	a2,s5
     7e8:	85d2                	mv	a1,s4
     7ea:	00000097          	auipc	ra,0x0
     7ee:	ec4080e7          	jalr	-316(ra) # 6ae <parseredirs>
     7f2:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     7f4:	008c0913          	addi	s2,s8,8
     7f8:	00001b17          	auipc	s6,0x1
     7fc:	ce8b0b13          	addi	s6,s6,-792 # 14e0 <malloc+0x1a4>
    if(tok != 'a')
     800:	06100c93          	li	s9,97
    if(argc >= MAXARGS)
     804:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     806:	a0b1                	j	852 <parseexec+0xa8>
    return parseblock(ps, es);
     808:	85d6                	mv	a1,s5
     80a:	8552                	mv	a0,s4
     80c:	00000097          	auipc	ra,0x0
     810:	1bc080e7          	jalr	444(ra) # 9c8 <parseblock>
     814:	84aa                	mv	s1,a0
}
     816:	8526                	mv	a0,s1
     818:	70a6                	ld	ra,104(sp)
     81a:	7406                	ld	s0,96(sp)
     81c:	64e6                	ld	s1,88(sp)
     81e:	6946                	ld	s2,80(sp)
     820:	69a6                	ld	s3,72(sp)
     822:	6a06                	ld	s4,64(sp)
     824:	7ae2                	ld	s5,56(sp)
     826:	7b42                	ld	s6,48(sp)
     828:	7ba2                	ld	s7,40(sp)
     82a:	7c02                	ld	s8,32(sp)
     82c:	6ce2                	ld	s9,24(sp)
     82e:	6165                	addi	sp,sp,112
     830:	8082                	ret
      panic("syntax");
     832:	00001517          	auipc	a0,0x1
     836:	c9650513          	addi	a0,a0,-874 # 14c8 <malloc+0x18c>
     83a:	00000097          	auipc	ra,0x0
     83e:	81a080e7          	jalr	-2022(ra) # 54 <panic>
    ret = parseredirs(ret, ps, es);
     842:	8656                	mv	a2,s5
     844:	85d2                	mv	a1,s4
     846:	8526                	mv	a0,s1
     848:	00000097          	auipc	ra,0x0
     84c:	e66080e7          	jalr	-410(ra) # 6ae <parseredirs>
     850:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     852:	865a                	mv	a2,s6
     854:	85d6                	mv	a1,s5
     856:	8552                	mv	a0,s4
     858:	00000097          	auipc	ra,0x0
     85c:	dec080e7          	jalr	-532(ra) # 644 <peek>
     860:	e131                	bnez	a0,8a4 <parseexec+0xfa>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     862:	f9040693          	addi	a3,s0,-112
     866:	f9840613          	addi	a2,s0,-104
     86a:	85d6                	mv	a1,s5
     86c:	8552                	mv	a0,s4
     86e:	00000097          	auipc	ra,0x0
     872:	c9a080e7          	jalr	-870(ra) # 508 <gettoken>
     876:	c51d                	beqz	a0,8a4 <parseexec+0xfa>
    if(tok != 'a')
     878:	fb951de3          	bne	a0,s9,832 <parseexec+0x88>
    cmd->argv[argc] = q;
     87c:	f9843783          	ld	a5,-104(s0)
     880:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     884:	f9043783          	ld	a5,-112(s0)
     888:	04f93823          	sd	a5,80(s2)
    argc++;
     88c:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     88e:	0921                	addi	s2,s2,8
     890:	fb7999e3          	bne	s3,s7,842 <parseexec+0x98>
      panic("too many args");
     894:	00001517          	auipc	a0,0x1
     898:	c3c50513          	addi	a0,a0,-964 # 14d0 <malloc+0x194>
     89c:	fffff097          	auipc	ra,0xfffff
     8a0:	7b8080e7          	jalr	1976(ra) # 54 <panic>
  cmd->argv[argc] = 0;
     8a4:	098e                	slli	s3,s3,0x3
     8a6:	99e2                	add	s3,s3,s8
     8a8:	0009b423          	sd	zero,8(s3)
  cmd->eargv[argc] = 0;
     8ac:	0409bc23          	sd	zero,88(s3)
  return ret;
     8b0:	b79d                	j	816 <parseexec+0x6c>

00000000000008b2 <parsepipe>:
{
     8b2:	7179                	addi	sp,sp,-48
     8b4:	f406                	sd	ra,40(sp)
     8b6:	f022                	sd	s0,32(sp)
     8b8:	ec26                	sd	s1,24(sp)
     8ba:	e84a                	sd	s2,16(sp)
     8bc:	e44e                	sd	s3,8(sp)
     8be:	1800                	addi	s0,sp,48
     8c0:	892a                	mv	s2,a0
     8c2:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     8c4:	00000097          	auipc	ra,0x0
     8c8:	ee6080e7          	jalr	-282(ra) # 7aa <parseexec>
     8cc:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     8ce:	00001617          	auipc	a2,0x1
     8d2:	c1a60613          	addi	a2,a2,-998 # 14e8 <malloc+0x1ac>
     8d6:	85ce                	mv	a1,s3
     8d8:	854a                	mv	a0,s2
     8da:	00000097          	auipc	ra,0x0
     8de:	d6a080e7          	jalr	-662(ra) # 644 <peek>
     8e2:	e909                	bnez	a0,8f4 <parsepipe+0x42>
}
     8e4:	8526                	mv	a0,s1
     8e6:	70a2                	ld	ra,40(sp)
     8e8:	7402                	ld	s0,32(sp)
     8ea:	64e2                	ld	s1,24(sp)
     8ec:	6942                	ld	s2,16(sp)
     8ee:	69a2                	ld	s3,8(sp)
     8f0:	6145                	addi	sp,sp,48
     8f2:	8082                	ret
    gettoken(ps, es, 0, 0);
     8f4:	4681                	li	a3,0
     8f6:	4601                	li	a2,0
     8f8:	85ce                	mv	a1,s3
     8fa:	854a                	mv	a0,s2
     8fc:	00000097          	auipc	ra,0x0
     900:	c0c080e7          	jalr	-1012(ra) # 508 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     904:	85ce                	mv	a1,s3
     906:	854a                	mv	a0,s2
     908:	00000097          	auipc	ra,0x0
     90c:	faa080e7          	jalr	-86(ra) # 8b2 <parsepipe>
     910:	85aa                	mv	a1,a0
     912:	8526                	mv	a0,s1
     914:	00000097          	auipc	ra,0x0
     918:	b2c080e7          	jalr	-1236(ra) # 440 <pipecmd>
     91c:	84aa                	mv	s1,a0
  return cmd;
     91e:	b7d9                	j	8e4 <parsepipe+0x32>

0000000000000920 <parseline>:
{
     920:	7179                	addi	sp,sp,-48
     922:	f406                	sd	ra,40(sp)
     924:	f022                	sd	s0,32(sp)
     926:	ec26                	sd	s1,24(sp)
     928:	e84a                	sd	s2,16(sp)
     92a:	e44e                	sd	s3,8(sp)
     92c:	e052                	sd	s4,0(sp)
     92e:	1800                	addi	s0,sp,48
     930:	892a                	mv	s2,a0
     932:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     934:	00000097          	auipc	ra,0x0
     938:	f7e080e7          	jalr	-130(ra) # 8b2 <parsepipe>
     93c:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     93e:	00001a17          	auipc	s4,0x1
     942:	bb2a0a13          	addi	s4,s4,-1102 # 14f0 <malloc+0x1b4>
     946:	a839                	j	964 <parseline+0x44>
    gettoken(ps, es, 0, 0);
     948:	4681                	li	a3,0
     94a:	4601                	li	a2,0
     94c:	85ce                	mv	a1,s3
     94e:	854a                	mv	a0,s2
     950:	00000097          	auipc	ra,0x0
     954:	bb8080e7          	jalr	-1096(ra) # 508 <gettoken>
    cmd = backcmd(cmd);
     958:	8526                	mv	a0,s1
     95a:	00000097          	auipc	ra,0x0
     95e:	b72080e7          	jalr	-1166(ra) # 4cc <backcmd>
     962:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     964:	8652                	mv	a2,s4
     966:	85ce                	mv	a1,s3
     968:	854a                	mv	a0,s2
     96a:	00000097          	auipc	ra,0x0
     96e:	cda080e7          	jalr	-806(ra) # 644 <peek>
     972:	f979                	bnez	a0,948 <parseline+0x28>
  if(peek(ps, es, ";")){
     974:	00001617          	auipc	a2,0x1
     978:	b8460613          	addi	a2,a2,-1148 # 14f8 <malloc+0x1bc>
     97c:	85ce                	mv	a1,s3
     97e:	854a                	mv	a0,s2
     980:	00000097          	auipc	ra,0x0
     984:	cc4080e7          	jalr	-828(ra) # 644 <peek>
     988:	e911                	bnez	a0,99c <parseline+0x7c>
}
     98a:	8526                	mv	a0,s1
     98c:	70a2                	ld	ra,40(sp)
     98e:	7402                	ld	s0,32(sp)
     990:	64e2                	ld	s1,24(sp)
     992:	6942                	ld	s2,16(sp)
     994:	69a2                	ld	s3,8(sp)
     996:	6a02                	ld	s4,0(sp)
     998:	6145                	addi	sp,sp,48
     99a:	8082                	ret
    gettoken(ps, es, 0, 0);
     99c:	4681                	li	a3,0
     99e:	4601                	li	a2,0
     9a0:	85ce                	mv	a1,s3
     9a2:	854a                	mv	a0,s2
     9a4:	00000097          	auipc	ra,0x0
     9a8:	b64080e7          	jalr	-1180(ra) # 508 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     9ac:	85ce                	mv	a1,s3
     9ae:	854a                	mv	a0,s2
     9b0:	00000097          	auipc	ra,0x0
     9b4:	f70080e7          	jalr	-144(ra) # 920 <parseline>
     9b8:	85aa                	mv	a1,a0
     9ba:	8526                	mv	a0,s1
     9bc:	00000097          	auipc	ra,0x0
     9c0:	aca080e7          	jalr	-1334(ra) # 486 <listcmd>
     9c4:	84aa                	mv	s1,a0
  return cmd;
     9c6:	b7d1                	j	98a <parseline+0x6a>

00000000000009c8 <parseblock>:
{
     9c8:	7179                	addi	sp,sp,-48
     9ca:	f406                	sd	ra,40(sp)
     9cc:	f022                	sd	s0,32(sp)
     9ce:	ec26                	sd	s1,24(sp)
     9d0:	e84a                	sd	s2,16(sp)
     9d2:	e44e                	sd	s3,8(sp)
     9d4:	1800                	addi	s0,sp,48
     9d6:	84aa                	mv	s1,a0
     9d8:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     9da:	00001617          	auipc	a2,0x1
     9de:	ae660613          	addi	a2,a2,-1306 # 14c0 <malloc+0x184>
     9e2:	00000097          	auipc	ra,0x0
     9e6:	c62080e7          	jalr	-926(ra) # 644 <peek>
     9ea:	c12d                	beqz	a0,a4c <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     9ec:	4681                	li	a3,0
     9ee:	4601                	li	a2,0
     9f0:	85ca                	mv	a1,s2
     9f2:	8526                	mv	a0,s1
     9f4:	00000097          	auipc	ra,0x0
     9f8:	b14080e7          	jalr	-1260(ra) # 508 <gettoken>
  cmd = parseline(ps, es);
     9fc:	85ca                	mv	a1,s2
     9fe:	8526                	mv	a0,s1
     a00:	00000097          	auipc	ra,0x0
     a04:	f20080e7          	jalr	-224(ra) # 920 <parseline>
     a08:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     a0a:	00001617          	auipc	a2,0x1
     a0e:	b0660613          	addi	a2,a2,-1274 # 1510 <malloc+0x1d4>
     a12:	85ca                	mv	a1,s2
     a14:	8526                	mv	a0,s1
     a16:	00000097          	auipc	ra,0x0
     a1a:	c2e080e7          	jalr	-978(ra) # 644 <peek>
     a1e:	cd1d                	beqz	a0,a5c <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     a20:	4681                	li	a3,0
     a22:	4601                	li	a2,0
     a24:	85ca                	mv	a1,s2
     a26:	8526                	mv	a0,s1
     a28:	00000097          	auipc	ra,0x0
     a2c:	ae0080e7          	jalr	-1312(ra) # 508 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     a30:	864a                	mv	a2,s2
     a32:	85a6                	mv	a1,s1
     a34:	854e                	mv	a0,s3
     a36:	00000097          	auipc	ra,0x0
     a3a:	c78080e7          	jalr	-904(ra) # 6ae <parseredirs>
}
     a3e:	70a2                	ld	ra,40(sp)
     a40:	7402                	ld	s0,32(sp)
     a42:	64e2                	ld	s1,24(sp)
     a44:	6942                	ld	s2,16(sp)
     a46:	69a2                	ld	s3,8(sp)
     a48:	6145                	addi	sp,sp,48
     a4a:	8082                	ret
    panic("parseblock");
     a4c:	00001517          	auipc	a0,0x1
     a50:	ab450513          	addi	a0,a0,-1356 # 1500 <malloc+0x1c4>
     a54:	fffff097          	auipc	ra,0xfffff
     a58:	600080e7          	jalr	1536(ra) # 54 <panic>
    panic("syntax - missing )");
     a5c:	00001517          	auipc	a0,0x1
     a60:	abc50513          	addi	a0,a0,-1348 # 1518 <malloc+0x1dc>
     a64:	fffff097          	auipc	ra,0xfffff
     a68:	5f0080e7          	jalr	1520(ra) # 54 <panic>

0000000000000a6c <nulterminate>:
{
     a6c:	1101                	addi	sp,sp,-32
     a6e:	ec06                	sd	ra,24(sp)
     a70:	e822                	sd	s0,16(sp)
     a72:	e426                	sd	s1,8(sp)
     a74:	1000                	addi	s0,sp,32
     a76:	84aa                	mv	s1,a0
  if(cmd == 0)
     a78:	c521                	beqz	a0,ac0 <nulterminate+0x54>
  switch(cmd->type){
     a7a:	4118                	lw	a4,0(a0)
     a7c:	4795                	li	a5,5
     a7e:	04e7e163          	bltu	a5,a4,ac0 <nulterminate+0x54>
     a82:	00056783          	lwu	a5,0(a0)
     a86:	078a                	slli	a5,a5,0x2
     a88:	00001717          	auipc	a4,0x1
     a8c:	af070713          	addi	a4,a4,-1296 # 1578 <malloc+0x23c>
     a90:	97ba                	add	a5,a5,a4
     a92:	439c                	lw	a5,0(a5)
     a94:	97ba                	add	a5,a5,a4
     a96:	8782                	jr	a5
    for(i=0; ecmd->argv[i]; i++)
     a98:	651c                	ld	a5,8(a0)
     a9a:	c39d                	beqz	a5,ac0 <nulterminate+0x54>
     a9c:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     aa0:	67b8                	ld	a4,72(a5)
     aa2:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     aa6:	07a1                	addi	a5,a5,8
     aa8:	ff87b703          	ld	a4,-8(a5)
     aac:	fb75                	bnez	a4,aa0 <nulterminate+0x34>
     aae:	a809                	j	ac0 <nulterminate+0x54>
    nulterminate(rcmd->cmd);
     ab0:	6508                	ld	a0,8(a0)
     ab2:	00000097          	auipc	ra,0x0
     ab6:	fba080e7          	jalr	-70(ra) # a6c <nulterminate>
    *rcmd->efile = 0;
     aba:	6c9c                	ld	a5,24(s1)
     abc:	00078023          	sb	zero,0(a5)
}
     ac0:	8526                	mv	a0,s1
     ac2:	60e2                	ld	ra,24(sp)
     ac4:	6442                	ld	s0,16(sp)
     ac6:	64a2                	ld	s1,8(sp)
     ac8:	6105                	addi	sp,sp,32
     aca:	8082                	ret
    nulterminate(pcmd->left);
     acc:	6508                	ld	a0,8(a0)
     ace:	00000097          	auipc	ra,0x0
     ad2:	f9e080e7          	jalr	-98(ra) # a6c <nulterminate>
    nulterminate(pcmd->right);
     ad6:	6888                	ld	a0,16(s1)
     ad8:	00000097          	auipc	ra,0x0
     adc:	f94080e7          	jalr	-108(ra) # a6c <nulterminate>
    break;
     ae0:	b7c5                	j	ac0 <nulterminate+0x54>
    nulterminate(lcmd->left);
     ae2:	6508                	ld	a0,8(a0)
     ae4:	00000097          	auipc	ra,0x0
     ae8:	f88080e7          	jalr	-120(ra) # a6c <nulterminate>
    nulterminate(lcmd->right);
     aec:	6888                	ld	a0,16(s1)
     aee:	00000097          	auipc	ra,0x0
     af2:	f7e080e7          	jalr	-130(ra) # a6c <nulterminate>
    break;
     af6:	b7e9                	j	ac0 <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     af8:	6508                	ld	a0,8(a0)
     afa:	00000097          	auipc	ra,0x0
     afe:	f72080e7          	jalr	-142(ra) # a6c <nulterminate>
    break;
     b02:	bf7d                	j	ac0 <nulterminate+0x54>

0000000000000b04 <parsecmd>:
{
     b04:	7179                	addi	sp,sp,-48
     b06:	f406                	sd	ra,40(sp)
     b08:	f022                	sd	s0,32(sp)
     b0a:	ec26                	sd	s1,24(sp)
     b0c:	e84a                	sd	s2,16(sp)
     b0e:	1800                	addi	s0,sp,48
     b10:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     b14:	84aa                	mv	s1,a0
     b16:	00000097          	auipc	ra,0x0
     b1a:	1b2080e7          	jalr	434(ra) # cc8 <strlen>
     b1e:	1502                	slli	a0,a0,0x20
     b20:	9101                	srli	a0,a0,0x20
     b22:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     b24:	85a6                	mv	a1,s1
     b26:	fd840513          	addi	a0,s0,-40
     b2a:	00000097          	auipc	ra,0x0
     b2e:	df6080e7          	jalr	-522(ra) # 920 <parseline>
     b32:	892a                	mv	s2,a0
  peek(&s, es, "");
     b34:	00001617          	auipc	a2,0x1
     b38:	9fc60613          	addi	a2,a2,-1540 # 1530 <malloc+0x1f4>
     b3c:	85a6                	mv	a1,s1
     b3e:	fd840513          	addi	a0,s0,-40
     b42:	00000097          	auipc	ra,0x0
     b46:	b02080e7          	jalr	-1278(ra) # 644 <peek>
  if(s != es){
     b4a:	fd843603          	ld	a2,-40(s0)
     b4e:	00961e63          	bne	a2,s1,b6a <parsecmd+0x66>
  nulterminate(cmd);
     b52:	854a                	mv	a0,s2
     b54:	00000097          	auipc	ra,0x0
     b58:	f18080e7          	jalr	-232(ra) # a6c <nulterminate>
}
     b5c:	854a                	mv	a0,s2
     b5e:	70a2                	ld	ra,40(sp)
     b60:	7402                	ld	s0,32(sp)
     b62:	64e2                	ld	s1,24(sp)
     b64:	6942                	ld	s2,16(sp)
     b66:	6145                	addi	sp,sp,48
     b68:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     b6a:	00001597          	auipc	a1,0x1
     b6e:	9ce58593          	addi	a1,a1,-1586 # 1538 <malloc+0x1fc>
     b72:	4509                	li	a0,2
     b74:	00000097          	auipc	ra,0x0
     b78:	6dc080e7          	jalr	1756(ra) # 1250 <fprintf>
    panic("syntax");
     b7c:	00001517          	auipc	a0,0x1
     b80:	94c50513          	addi	a0,a0,-1716 # 14c8 <malloc+0x18c>
     b84:	fffff097          	auipc	ra,0xfffff
     b88:	4d0080e7          	jalr	1232(ra) # 54 <panic>

0000000000000b8c <main>:
{
     b8c:	7139                	addi	sp,sp,-64
     b8e:	fc06                	sd	ra,56(sp)
     b90:	f822                	sd	s0,48(sp)
     b92:	f426                	sd	s1,40(sp)
     b94:	f04a                	sd	s2,32(sp)
     b96:	ec4e                	sd	s3,24(sp)
     b98:	e852                	sd	s4,16(sp)
     b9a:	e456                	sd	s5,8(sp)
     b9c:	0080                	addi	s0,sp,64
  while((fd = open("console", O_RDWR)) >= 0){
     b9e:	00001497          	auipc	s1,0x1
     ba2:	9aa48493          	addi	s1,s1,-1622 # 1548 <malloc+0x20c>
     ba6:	4589                	li	a1,2
     ba8:	8526                	mv	a0,s1
     baa:	00000097          	auipc	ra,0x0
     bae:	384080e7          	jalr	900(ra) # f2e <open>
     bb2:	00054963          	bltz	a0,bc4 <main+0x38>
    if(fd >= 3){
     bb6:	4789                	li	a5,2
     bb8:	fea7d7e3          	bge	a5,a0,ba6 <main+0x1a>
      close(fd);
     bbc:	00000097          	auipc	ra,0x0
     bc0:	35a080e7          	jalr	858(ra) # f16 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     bc4:	00001497          	auipc	s1,0x1
     bc8:	a0448493          	addi	s1,s1,-1532 # 15c8 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     bcc:	06300913          	li	s2,99
     bd0:	02000993          	li	s3,32
      if(chdir(buf+3) < 0)
     bd4:	00001a17          	auipc	s4,0x1
     bd8:	9f7a0a13          	addi	s4,s4,-1545 # 15cb <buf.0+0x3>
        fprintf(2, "cannot cd %s\n", buf+3);
     bdc:	00001a97          	auipc	s5,0x1
     be0:	974a8a93          	addi	s5,s5,-1676 # 1550 <malloc+0x214>
     be4:	a819                	j	bfa <main+0x6e>
    if(fork1() == 0)
     be6:	fffff097          	auipc	ra,0xfffff
     bea:	494080e7          	jalr	1172(ra) # 7a <fork1>
     bee:	c925                	beqz	a0,c5e <main+0xd2>
    wait(0);
     bf0:	4501                	li	a0,0
     bf2:	00000097          	auipc	ra,0x0
     bf6:	304080e7          	jalr	772(ra) # ef6 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     bfa:	06400593          	li	a1,100
     bfe:	8526                	mv	a0,s1
     c00:	fffff097          	auipc	ra,0xfffff
     c04:	400080e7          	jalr	1024(ra) # 0 <getcmd>
     c08:	06054763          	bltz	a0,c76 <main+0xea>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     c0c:	0004c783          	lbu	a5,0(s1)
     c10:	fd279be3          	bne	a5,s2,be6 <main+0x5a>
     c14:	0014c703          	lbu	a4,1(s1)
     c18:	06400793          	li	a5,100
     c1c:	fcf715e3          	bne	a4,a5,be6 <main+0x5a>
     c20:	0024c783          	lbu	a5,2(s1)
     c24:	fd3791e3          	bne	a5,s3,be6 <main+0x5a>
      buf[strlen(buf)-1] = 0;  // chop \n
     c28:	8526                	mv	a0,s1
     c2a:	00000097          	auipc	ra,0x0
     c2e:	09e080e7          	jalr	158(ra) # cc8 <strlen>
     c32:	fff5079b          	addiw	a5,a0,-1
     c36:	1782                	slli	a5,a5,0x20
     c38:	9381                	srli	a5,a5,0x20
     c3a:	97a6                	add	a5,a5,s1
     c3c:	00078023          	sb	zero,0(a5)
      if(chdir(buf+3) < 0)
     c40:	8552                	mv	a0,s4
     c42:	00000097          	auipc	ra,0x0
     c46:	31c080e7          	jalr	796(ra) # f5e <chdir>
     c4a:	fa0558e3          	bgez	a0,bfa <main+0x6e>
        fprintf(2, "cannot cd %s\n", buf+3);
     c4e:	8652                	mv	a2,s4
     c50:	85d6                	mv	a1,s5
     c52:	4509                	li	a0,2
     c54:	00000097          	auipc	ra,0x0
     c58:	5fc080e7          	jalr	1532(ra) # 1250 <fprintf>
     c5c:	bf79                	j	bfa <main+0x6e>
      runcmd(parsecmd(buf));
     c5e:	00001517          	auipc	a0,0x1
     c62:	96a50513          	addi	a0,a0,-1686 # 15c8 <buf.0>
     c66:	00000097          	auipc	ra,0x0
     c6a:	e9e080e7          	jalr	-354(ra) # b04 <parsecmd>
     c6e:	fffff097          	auipc	ra,0xfffff
     c72:	43a080e7          	jalr	1082(ra) # a8 <runcmd>
  exit(0);
     c76:	4501                	li	a0,0
     c78:	00000097          	auipc	ra,0x0
     c7c:	276080e7          	jalr	630(ra) # eee <exit>

0000000000000c80 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     c80:	1141                	addi	sp,sp,-16
     c82:	e422                	sd	s0,8(sp)
     c84:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c86:	87aa                	mv	a5,a0
     c88:	0585                	addi	a1,a1,1
     c8a:	0785                	addi	a5,a5,1
     c8c:	fff5c703          	lbu	a4,-1(a1)
     c90:	fee78fa3          	sb	a4,-1(a5)
     c94:	fb75                	bnez	a4,c88 <strcpy+0x8>
    ;
  return os;
}
     c96:	6422                	ld	s0,8(sp)
     c98:	0141                	addi	sp,sp,16
     c9a:	8082                	ret

0000000000000c9c <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c9c:	1141                	addi	sp,sp,-16
     c9e:	e422                	sd	s0,8(sp)
     ca0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     ca2:	00054783          	lbu	a5,0(a0)
     ca6:	cb91                	beqz	a5,cba <strcmp+0x1e>
     ca8:	0005c703          	lbu	a4,0(a1)
     cac:	00f71763          	bne	a4,a5,cba <strcmp+0x1e>
    p++, q++;
     cb0:	0505                	addi	a0,a0,1
     cb2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     cb4:	00054783          	lbu	a5,0(a0)
     cb8:	fbe5                	bnez	a5,ca8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     cba:	0005c503          	lbu	a0,0(a1)
}
     cbe:	40a7853b          	subw	a0,a5,a0
     cc2:	6422                	ld	s0,8(sp)
     cc4:	0141                	addi	sp,sp,16
     cc6:	8082                	ret

0000000000000cc8 <strlen>:

uint
strlen(const char *s)
{
     cc8:	1141                	addi	sp,sp,-16
     cca:	e422                	sd	s0,8(sp)
     ccc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     cce:	00054783          	lbu	a5,0(a0)
     cd2:	cf91                	beqz	a5,cee <strlen+0x26>
     cd4:	0505                	addi	a0,a0,1
     cd6:	87aa                	mv	a5,a0
     cd8:	4685                	li	a3,1
     cda:	9e89                	subw	a3,a3,a0
     cdc:	00f6853b          	addw	a0,a3,a5
     ce0:	0785                	addi	a5,a5,1
     ce2:	fff7c703          	lbu	a4,-1(a5)
     ce6:	fb7d                	bnez	a4,cdc <strlen+0x14>
    ;
  return n;
}
     ce8:	6422                	ld	s0,8(sp)
     cea:	0141                	addi	sp,sp,16
     cec:	8082                	ret
  for(n = 0; s[n]; n++)
     cee:	4501                	li	a0,0
     cf0:	bfe5                	j	ce8 <strlen+0x20>

0000000000000cf2 <memset>:

void*
memset(void *dst, int c, uint n)
{
     cf2:	1141                	addi	sp,sp,-16
     cf4:	e422                	sd	s0,8(sp)
     cf6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     cf8:	ca19                	beqz	a2,d0e <memset+0x1c>
     cfa:	87aa                	mv	a5,a0
     cfc:	1602                	slli	a2,a2,0x20
     cfe:	9201                	srli	a2,a2,0x20
     d00:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     d04:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     d08:	0785                	addi	a5,a5,1
     d0a:	fee79de3          	bne	a5,a4,d04 <memset+0x12>
  }
  return dst;
}
     d0e:	6422                	ld	s0,8(sp)
     d10:	0141                	addi	sp,sp,16
     d12:	8082                	ret

0000000000000d14 <strchr>:

char*
strchr(const char *s, char c)
{
     d14:	1141                	addi	sp,sp,-16
     d16:	e422                	sd	s0,8(sp)
     d18:	0800                	addi	s0,sp,16
  for(; *s; s++)
     d1a:	00054783          	lbu	a5,0(a0)
     d1e:	cb99                	beqz	a5,d34 <strchr+0x20>
    if(*s == c)
     d20:	00f58763          	beq	a1,a5,d2e <strchr+0x1a>
  for(; *s; s++)
     d24:	0505                	addi	a0,a0,1
     d26:	00054783          	lbu	a5,0(a0)
     d2a:	fbfd                	bnez	a5,d20 <strchr+0xc>
      return (char*)s;
  return 0;
     d2c:	4501                	li	a0,0
}
     d2e:	6422                	ld	s0,8(sp)
     d30:	0141                	addi	sp,sp,16
     d32:	8082                	ret
  return 0;
     d34:	4501                	li	a0,0
     d36:	bfe5                	j	d2e <strchr+0x1a>

0000000000000d38 <gets>:

char*
gets(char *buf, int max)
{
     d38:	711d                	addi	sp,sp,-96
     d3a:	ec86                	sd	ra,88(sp)
     d3c:	e8a2                	sd	s0,80(sp)
     d3e:	e4a6                	sd	s1,72(sp)
     d40:	e0ca                	sd	s2,64(sp)
     d42:	fc4e                	sd	s3,56(sp)
     d44:	f852                	sd	s4,48(sp)
     d46:	f456                	sd	s5,40(sp)
     d48:	f05a                	sd	s6,32(sp)
     d4a:	ec5e                	sd	s7,24(sp)
     d4c:	1080                	addi	s0,sp,96
     d4e:	8baa                	mv	s7,a0
     d50:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d52:	892a                	mv	s2,a0
     d54:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     d56:	4aa9                	li	s5,10
     d58:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     d5a:	89a6                	mv	s3,s1
     d5c:	2485                	addiw	s1,s1,1
     d5e:	0344d863          	bge	s1,s4,d8e <gets+0x56>
    cc = read(0, &c, 1);
     d62:	4605                	li	a2,1
     d64:	faf40593          	addi	a1,s0,-81
     d68:	4501                	li	a0,0
     d6a:	00000097          	auipc	ra,0x0
     d6e:	19c080e7          	jalr	412(ra) # f06 <read>
    if(cc < 1)
     d72:	00a05e63          	blez	a0,d8e <gets+0x56>
    buf[i++] = c;
     d76:	faf44783          	lbu	a5,-81(s0)
     d7a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d7e:	01578763          	beq	a5,s5,d8c <gets+0x54>
     d82:	0905                	addi	s2,s2,1
     d84:	fd679be3          	bne	a5,s6,d5a <gets+0x22>
  for(i=0; i+1 < max; ){
     d88:	89a6                	mv	s3,s1
     d8a:	a011                	j	d8e <gets+0x56>
     d8c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d8e:	99de                	add	s3,s3,s7
     d90:	00098023          	sb	zero,0(s3)
  return buf;
}
     d94:	855e                	mv	a0,s7
     d96:	60e6                	ld	ra,88(sp)
     d98:	6446                	ld	s0,80(sp)
     d9a:	64a6                	ld	s1,72(sp)
     d9c:	6906                	ld	s2,64(sp)
     d9e:	79e2                	ld	s3,56(sp)
     da0:	7a42                	ld	s4,48(sp)
     da2:	7aa2                	ld	s5,40(sp)
     da4:	7b02                	ld	s6,32(sp)
     da6:	6be2                	ld	s7,24(sp)
     da8:	6125                	addi	sp,sp,96
     daa:	8082                	ret

0000000000000dac <stat>:

int
stat(const char *n, struct stat *st)
{
     dac:	1101                	addi	sp,sp,-32
     dae:	ec06                	sd	ra,24(sp)
     db0:	e822                	sd	s0,16(sp)
     db2:	e426                	sd	s1,8(sp)
     db4:	e04a                	sd	s2,0(sp)
     db6:	1000                	addi	s0,sp,32
     db8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     dba:	4581                	li	a1,0
     dbc:	00000097          	auipc	ra,0x0
     dc0:	172080e7          	jalr	370(ra) # f2e <open>
  if(fd < 0)
     dc4:	02054563          	bltz	a0,dee <stat+0x42>
     dc8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     dca:	85ca                	mv	a1,s2
     dcc:	00000097          	auipc	ra,0x0
     dd0:	17a080e7          	jalr	378(ra) # f46 <fstat>
     dd4:	892a                	mv	s2,a0
  close(fd);
     dd6:	8526                	mv	a0,s1
     dd8:	00000097          	auipc	ra,0x0
     ddc:	13e080e7          	jalr	318(ra) # f16 <close>
  return r;
}
     de0:	854a                	mv	a0,s2
     de2:	60e2                	ld	ra,24(sp)
     de4:	6442                	ld	s0,16(sp)
     de6:	64a2                	ld	s1,8(sp)
     de8:	6902                	ld	s2,0(sp)
     dea:	6105                	addi	sp,sp,32
     dec:	8082                	ret
    return -1;
     dee:	597d                	li	s2,-1
     df0:	bfc5                	j	de0 <stat+0x34>

0000000000000df2 <atoi>:

int
atoi(const char *s)
{
     df2:	1141                	addi	sp,sp,-16
     df4:	e422                	sd	s0,8(sp)
     df6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     df8:	00054603          	lbu	a2,0(a0)
     dfc:	fd06079b          	addiw	a5,a2,-48
     e00:	0ff7f793          	andi	a5,a5,255
     e04:	4725                	li	a4,9
     e06:	02f76963          	bltu	a4,a5,e38 <atoi+0x46>
     e0a:	86aa                	mv	a3,a0
  n = 0;
     e0c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     e0e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     e10:	0685                	addi	a3,a3,1
     e12:	0025179b          	slliw	a5,a0,0x2
     e16:	9fa9                	addw	a5,a5,a0
     e18:	0017979b          	slliw	a5,a5,0x1
     e1c:	9fb1                	addw	a5,a5,a2
     e1e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     e22:	0006c603          	lbu	a2,0(a3)
     e26:	fd06071b          	addiw	a4,a2,-48
     e2a:	0ff77713          	andi	a4,a4,255
     e2e:	fee5f1e3          	bgeu	a1,a4,e10 <atoi+0x1e>
  return n;
}
     e32:	6422                	ld	s0,8(sp)
     e34:	0141                	addi	sp,sp,16
     e36:	8082                	ret
  n = 0;
     e38:	4501                	li	a0,0
     e3a:	bfe5                	j	e32 <atoi+0x40>

0000000000000e3c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     e3c:	1141                	addi	sp,sp,-16
     e3e:	e422                	sd	s0,8(sp)
     e40:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     e42:	02b57463          	bgeu	a0,a1,e6a <memmove+0x2e>
    while(n-- > 0)
     e46:	00c05f63          	blez	a2,e64 <memmove+0x28>
     e4a:	1602                	slli	a2,a2,0x20
     e4c:	9201                	srli	a2,a2,0x20
     e4e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     e52:	872a                	mv	a4,a0
      *dst++ = *src++;
     e54:	0585                	addi	a1,a1,1
     e56:	0705                	addi	a4,a4,1
     e58:	fff5c683          	lbu	a3,-1(a1)
     e5c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e60:	fee79ae3          	bne	a5,a4,e54 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     e64:	6422                	ld	s0,8(sp)
     e66:	0141                	addi	sp,sp,16
     e68:	8082                	ret
    dst += n;
     e6a:	00c50733          	add	a4,a0,a2
    src += n;
     e6e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     e70:	fec05ae3          	blez	a2,e64 <memmove+0x28>
     e74:	fff6079b          	addiw	a5,a2,-1
     e78:	1782                	slli	a5,a5,0x20
     e7a:	9381                	srli	a5,a5,0x20
     e7c:	fff7c793          	not	a5,a5
     e80:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e82:	15fd                	addi	a1,a1,-1
     e84:	177d                	addi	a4,a4,-1
     e86:	0005c683          	lbu	a3,0(a1)
     e8a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e8e:	fee79ae3          	bne	a5,a4,e82 <memmove+0x46>
     e92:	bfc9                	j	e64 <memmove+0x28>

0000000000000e94 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e94:	1141                	addi	sp,sp,-16
     e96:	e422                	sd	s0,8(sp)
     e98:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e9a:	ca05                	beqz	a2,eca <memcmp+0x36>
     e9c:	fff6069b          	addiw	a3,a2,-1
     ea0:	1682                	slli	a3,a3,0x20
     ea2:	9281                	srli	a3,a3,0x20
     ea4:	0685                	addi	a3,a3,1
     ea6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     ea8:	00054783          	lbu	a5,0(a0)
     eac:	0005c703          	lbu	a4,0(a1)
     eb0:	00e79863          	bne	a5,a4,ec0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     eb4:	0505                	addi	a0,a0,1
    p2++;
     eb6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     eb8:	fed518e3          	bne	a0,a3,ea8 <memcmp+0x14>
  }
  return 0;
     ebc:	4501                	li	a0,0
     ebe:	a019                	j	ec4 <memcmp+0x30>
      return *p1 - *p2;
     ec0:	40e7853b          	subw	a0,a5,a4
}
     ec4:	6422                	ld	s0,8(sp)
     ec6:	0141                	addi	sp,sp,16
     ec8:	8082                	ret
  return 0;
     eca:	4501                	li	a0,0
     ecc:	bfe5                	j	ec4 <memcmp+0x30>

0000000000000ece <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     ece:	1141                	addi	sp,sp,-16
     ed0:	e406                	sd	ra,8(sp)
     ed2:	e022                	sd	s0,0(sp)
     ed4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     ed6:	00000097          	auipc	ra,0x0
     eda:	f66080e7          	jalr	-154(ra) # e3c <memmove>
}
     ede:	60a2                	ld	ra,8(sp)
     ee0:	6402                	ld	s0,0(sp)
     ee2:	0141                	addi	sp,sp,16
     ee4:	8082                	ret

0000000000000ee6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     ee6:	4885                	li	a7,1
 ecall
     ee8:	00000073          	ecall
 ret
     eec:	8082                	ret

0000000000000eee <exit>:
.global exit
exit:
 li a7, SYS_exit
     eee:	4889                	li	a7,2
 ecall
     ef0:	00000073          	ecall
 ret
     ef4:	8082                	ret

0000000000000ef6 <wait>:
.global wait
wait:
 li a7, SYS_wait
     ef6:	488d                	li	a7,3
 ecall
     ef8:	00000073          	ecall
 ret
     efc:	8082                	ret

0000000000000efe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     efe:	4891                	li	a7,4
 ecall
     f00:	00000073          	ecall
 ret
     f04:	8082                	ret

0000000000000f06 <read>:
.global read
read:
 li a7, SYS_read
     f06:	4895                	li	a7,5
 ecall
     f08:	00000073          	ecall
 ret
     f0c:	8082                	ret

0000000000000f0e <write>:
.global write
write:
 li a7, SYS_write
     f0e:	48c1                	li	a7,16
 ecall
     f10:	00000073          	ecall
 ret
     f14:	8082                	ret

0000000000000f16 <close>:
.global close
close:
 li a7, SYS_close
     f16:	48d5                	li	a7,21
 ecall
     f18:	00000073          	ecall
 ret
     f1c:	8082                	ret

0000000000000f1e <kill>:
.global kill
kill:
 li a7, SYS_kill
     f1e:	4899                	li	a7,6
 ecall
     f20:	00000073          	ecall
 ret
     f24:	8082                	ret

0000000000000f26 <exec>:
.global exec
exec:
 li a7, SYS_exec
     f26:	489d                	li	a7,7
 ecall
     f28:	00000073          	ecall
 ret
     f2c:	8082                	ret

0000000000000f2e <open>:
.global open
open:
 li a7, SYS_open
     f2e:	48bd                	li	a7,15
 ecall
     f30:	00000073          	ecall
 ret
     f34:	8082                	ret

0000000000000f36 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     f36:	48c5                	li	a7,17
 ecall
     f38:	00000073          	ecall
 ret
     f3c:	8082                	ret

0000000000000f3e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     f3e:	48c9                	li	a7,18
 ecall
     f40:	00000073          	ecall
 ret
     f44:	8082                	ret

0000000000000f46 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     f46:	48a1                	li	a7,8
 ecall
     f48:	00000073          	ecall
 ret
     f4c:	8082                	ret

0000000000000f4e <link>:
.global link
link:
 li a7, SYS_link
     f4e:	48cd                	li	a7,19
 ecall
     f50:	00000073          	ecall
 ret
     f54:	8082                	ret

0000000000000f56 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f56:	48d1                	li	a7,20
 ecall
     f58:	00000073          	ecall
 ret
     f5c:	8082                	ret

0000000000000f5e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f5e:	48a5                	li	a7,9
 ecall
     f60:	00000073          	ecall
 ret
     f64:	8082                	ret

0000000000000f66 <dup>:
.global dup
dup:
 li a7, SYS_dup
     f66:	48a9                	li	a7,10
 ecall
     f68:	00000073          	ecall
 ret
     f6c:	8082                	ret

0000000000000f6e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f6e:	48ad                	li	a7,11
 ecall
     f70:	00000073          	ecall
 ret
     f74:	8082                	ret

0000000000000f76 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f76:	48b1                	li	a7,12
 ecall
     f78:	00000073          	ecall
 ret
     f7c:	8082                	ret

0000000000000f7e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f7e:	48b5                	li	a7,13
 ecall
     f80:	00000073          	ecall
 ret
     f84:	8082                	ret

0000000000000f86 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f86:	48b9                	li	a7,14
 ecall
     f88:	00000073          	ecall
 ret
     f8c:	8082                	ret

0000000000000f8e <trace>:
.global trace
trace:
 li a7, SYS_trace
     f8e:	48d9                	li	a7,22
 ecall
     f90:	00000073          	ecall
 ret
     f94:	8082                	ret

0000000000000f96 <wait_stat>:
.global wait_stat
wait_stat:
 li a7, SYS_wait_stat
     f96:	48dd                	li	a7,23
 ecall
     f98:	00000073          	ecall
 ret
     f9c:	8082                	ret

0000000000000f9e <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
     f9e:	48e1                	li	a7,24
 ecall
     fa0:	00000073          	ecall
 ret
     fa4:	8082                	ret

0000000000000fa6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     fa6:	1101                	addi	sp,sp,-32
     fa8:	ec06                	sd	ra,24(sp)
     faa:	e822                	sd	s0,16(sp)
     fac:	1000                	addi	s0,sp,32
     fae:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     fb2:	4605                	li	a2,1
     fb4:	fef40593          	addi	a1,s0,-17
     fb8:	00000097          	auipc	ra,0x0
     fbc:	f56080e7          	jalr	-170(ra) # f0e <write>
}
     fc0:	60e2                	ld	ra,24(sp)
     fc2:	6442                	ld	s0,16(sp)
     fc4:	6105                	addi	sp,sp,32
     fc6:	8082                	ret

0000000000000fc8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     fc8:	7139                	addi	sp,sp,-64
     fca:	fc06                	sd	ra,56(sp)
     fcc:	f822                	sd	s0,48(sp)
     fce:	f426                	sd	s1,40(sp)
     fd0:	f04a                	sd	s2,32(sp)
     fd2:	ec4e                	sd	s3,24(sp)
     fd4:	0080                	addi	s0,sp,64
     fd6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     fd8:	c299                	beqz	a3,fde <printint+0x16>
     fda:	0805c863          	bltz	a1,106a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     fde:	2581                	sext.w	a1,a1
  neg = 0;
     fe0:	4881                	li	a7,0
     fe2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     fe6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     fe8:	2601                	sext.w	a2,a2
     fea:	00000517          	auipc	a0,0x0
     fee:	5ae50513          	addi	a0,a0,1454 # 1598 <digits>
     ff2:	883a                	mv	a6,a4
     ff4:	2705                	addiw	a4,a4,1
     ff6:	02c5f7bb          	remuw	a5,a1,a2
     ffa:	1782                	slli	a5,a5,0x20
     ffc:	9381                	srli	a5,a5,0x20
     ffe:	97aa                	add	a5,a5,a0
    1000:	0007c783          	lbu	a5,0(a5)
    1004:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    1008:	0005879b          	sext.w	a5,a1
    100c:	02c5d5bb          	divuw	a1,a1,a2
    1010:	0685                	addi	a3,a3,1
    1012:	fec7f0e3          	bgeu	a5,a2,ff2 <printint+0x2a>
  if(neg)
    1016:	00088b63          	beqz	a7,102c <printint+0x64>
    buf[i++] = '-';
    101a:	fd040793          	addi	a5,s0,-48
    101e:	973e                	add	a4,a4,a5
    1020:	02d00793          	li	a5,45
    1024:	fef70823          	sb	a5,-16(a4)
    1028:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    102c:	02e05863          	blez	a4,105c <printint+0x94>
    1030:	fc040793          	addi	a5,s0,-64
    1034:	00e78933          	add	s2,a5,a4
    1038:	fff78993          	addi	s3,a5,-1
    103c:	99ba                	add	s3,s3,a4
    103e:	377d                	addiw	a4,a4,-1
    1040:	1702                	slli	a4,a4,0x20
    1042:	9301                	srli	a4,a4,0x20
    1044:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1048:	fff94583          	lbu	a1,-1(s2)
    104c:	8526                	mv	a0,s1
    104e:	00000097          	auipc	ra,0x0
    1052:	f58080e7          	jalr	-168(ra) # fa6 <putc>
  while(--i >= 0)
    1056:	197d                	addi	s2,s2,-1
    1058:	ff3918e3          	bne	s2,s3,1048 <printint+0x80>
}
    105c:	70e2                	ld	ra,56(sp)
    105e:	7442                	ld	s0,48(sp)
    1060:	74a2                	ld	s1,40(sp)
    1062:	7902                	ld	s2,32(sp)
    1064:	69e2                	ld	s3,24(sp)
    1066:	6121                	addi	sp,sp,64
    1068:	8082                	ret
    x = -xx;
    106a:	40b005bb          	negw	a1,a1
    neg = 1;
    106e:	4885                	li	a7,1
    x = -xx;
    1070:	bf8d                	j	fe2 <printint+0x1a>

0000000000001072 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    1072:	7119                	addi	sp,sp,-128
    1074:	fc86                	sd	ra,120(sp)
    1076:	f8a2                	sd	s0,112(sp)
    1078:	f4a6                	sd	s1,104(sp)
    107a:	f0ca                	sd	s2,96(sp)
    107c:	ecce                	sd	s3,88(sp)
    107e:	e8d2                	sd	s4,80(sp)
    1080:	e4d6                	sd	s5,72(sp)
    1082:	e0da                	sd	s6,64(sp)
    1084:	fc5e                	sd	s7,56(sp)
    1086:	f862                	sd	s8,48(sp)
    1088:	f466                	sd	s9,40(sp)
    108a:	f06a                	sd	s10,32(sp)
    108c:	ec6e                	sd	s11,24(sp)
    108e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    1090:	0005c903          	lbu	s2,0(a1)
    1094:	18090f63          	beqz	s2,1232 <vprintf+0x1c0>
    1098:	8aaa                	mv	s5,a0
    109a:	8b32                	mv	s6,a2
    109c:	00158493          	addi	s1,a1,1
  state = 0;
    10a0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    10a2:	02500a13          	li	s4,37
      if(c == 'd'){
    10a6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    10aa:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    10ae:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    10b2:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10b6:	00000b97          	auipc	s7,0x0
    10ba:	4e2b8b93          	addi	s7,s7,1250 # 1598 <digits>
    10be:	a839                	j	10dc <vprintf+0x6a>
        putc(fd, c);
    10c0:	85ca                	mv	a1,s2
    10c2:	8556                	mv	a0,s5
    10c4:	00000097          	auipc	ra,0x0
    10c8:	ee2080e7          	jalr	-286(ra) # fa6 <putc>
    10cc:	a019                	j	10d2 <vprintf+0x60>
    } else if(state == '%'){
    10ce:	01498f63          	beq	s3,s4,10ec <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    10d2:	0485                	addi	s1,s1,1
    10d4:	fff4c903          	lbu	s2,-1(s1)
    10d8:	14090d63          	beqz	s2,1232 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    10dc:	0009079b          	sext.w	a5,s2
    if(state == 0){
    10e0:	fe0997e3          	bnez	s3,10ce <vprintf+0x5c>
      if(c == '%'){
    10e4:	fd479ee3          	bne	a5,s4,10c0 <vprintf+0x4e>
        state = '%';
    10e8:	89be                	mv	s3,a5
    10ea:	b7e5                	j	10d2 <vprintf+0x60>
      if(c == 'd'){
    10ec:	05878063          	beq	a5,s8,112c <vprintf+0xba>
      } else if(c == 'l') {
    10f0:	05978c63          	beq	a5,s9,1148 <vprintf+0xd6>
      } else if(c == 'x') {
    10f4:	07a78863          	beq	a5,s10,1164 <vprintf+0xf2>
      } else if(c == 'p') {
    10f8:	09b78463          	beq	a5,s11,1180 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    10fc:	07300713          	li	a4,115
    1100:	0ce78663          	beq	a5,a4,11cc <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1104:	06300713          	li	a4,99
    1108:	0ee78e63          	beq	a5,a4,1204 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    110c:	11478863          	beq	a5,s4,121c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1110:	85d2                	mv	a1,s4
    1112:	8556                	mv	a0,s5
    1114:	00000097          	auipc	ra,0x0
    1118:	e92080e7          	jalr	-366(ra) # fa6 <putc>
        putc(fd, c);
    111c:	85ca                	mv	a1,s2
    111e:	8556                	mv	a0,s5
    1120:	00000097          	auipc	ra,0x0
    1124:	e86080e7          	jalr	-378(ra) # fa6 <putc>
      }
      state = 0;
    1128:	4981                	li	s3,0
    112a:	b765                	j	10d2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    112c:	008b0913          	addi	s2,s6,8
    1130:	4685                	li	a3,1
    1132:	4629                	li	a2,10
    1134:	000b2583          	lw	a1,0(s6)
    1138:	8556                	mv	a0,s5
    113a:	00000097          	auipc	ra,0x0
    113e:	e8e080e7          	jalr	-370(ra) # fc8 <printint>
    1142:	8b4a                	mv	s6,s2
      state = 0;
    1144:	4981                	li	s3,0
    1146:	b771                	j	10d2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1148:	008b0913          	addi	s2,s6,8
    114c:	4681                	li	a3,0
    114e:	4629                	li	a2,10
    1150:	000b2583          	lw	a1,0(s6)
    1154:	8556                	mv	a0,s5
    1156:	00000097          	auipc	ra,0x0
    115a:	e72080e7          	jalr	-398(ra) # fc8 <printint>
    115e:	8b4a                	mv	s6,s2
      state = 0;
    1160:	4981                	li	s3,0
    1162:	bf85                	j	10d2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    1164:	008b0913          	addi	s2,s6,8
    1168:	4681                	li	a3,0
    116a:	4641                	li	a2,16
    116c:	000b2583          	lw	a1,0(s6)
    1170:	8556                	mv	a0,s5
    1172:	00000097          	auipc	ra,0x0
    1176:	e56080e7          	jalr	-426(ra) # fc8 <printint>
    117a:	8b4a                	mv	s6,s2
      state = 0;
    117c:	4981                	li	s3,0
    117e:	bf91                	j	10d2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    1180:	008b0793          	addi	a5,s6,8
    1184:	f8f43423          	sd	a5,-120(s0)
    1188:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    118c:	03000593          	li	a1,48
    1190:	8556                	mv	a0,s5
    1192:	00000097          	auipc	ra,0x0
    1196:	e14080e7          	jalr	-492(ra) # fa6 <putc>
  putc(fd, 'x');
    119a:	85ea                	mv	a1,s10
    119c:	8556                	mv	a0,s5
    119e:	00000097          	auipc	ra,0x0
    11a2:	e08080e7          	jalr	-504(ra) # fa6 <putc>
    11a6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    11a8:	03c9d793          	srli	a5,s3,0x3c
    11ac:	97de                	add	a5,a5,s7
    11ae:	0007c583          	lbu	a1,0(a5)
    11b2:	8556                	mv	a0,s5
    11b4:	00000097          	auipc	ra,0x0
    11b8:	df2080e7          	jalr	-526(ra) # fa6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    11bc:	0992                	slli	s3,s3,0x4
    11be:	397d                	addiw	s2,s2,-1
    11c0:	fe0914e3          	bnez	s2,11a8 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    11c4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    11c8:	4981                	li	s3,0
    11ca:	b721                	j	10d2 <vprintf+0x60>
        s = va_arg(ap, char*);
    11cc:	008b0993          	addi	s3,s6,8
    11d0:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    11d4:	02090163          	beqz	s2,11f6 <vprintf+0x184>
        while(*s != 0){
    11d8:	00094583          	lbu	a1,0(s2)
    11dc:	c9a1                	beqz	a1,122c <vprintf+0x1ba>
          putc(fd, *s);
    11de:	8556                	mv	a0,s5
    11e0:	00000097          	auipc	ra,0x0
    11e4:	dc6080e7          	jalr	-570(ra) # fa6 <putc>
          s++;
    11e8:	0905                	addi	s2,s2,1
        while(*s != 0){
    11ea:	00094583          	lbu	a1,0(s2)
    11ee:	f9e5                	bnez	a1,11de <vprintf+0x16c>
        s = va_arg(ap, char*);
    11f0:	8b4e                	mv	s6,s3
      state = 0;
    11f2:	4981                	li	s3,0
    11f4:	bdf9                	j	10d2 <vprintf+0x60>
          s = "(null)";
    11f6:	00000917          	auipc	s2,0x0
    11fa:	39a90913          	addi	s2,s2,922 # 1590 <malloc+0x254>
        while(*s != 0){
    11fe:	02800593          	li	a1,40
    1202:	bff1                	j	11de <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    1204:	008b0913          	addi	s2,s6,8
    1208:	000b4583          	lbu	a1,0(s6)
    120c:	8556                	mv	a0,s5
    120e:	00000097          	auipc	ra,0x0
    1212:	d98080e7          	jalr	-616(ra) # fa6 <putc>
    1216:	8b4a                	mv	s6,s2
      state = 0;
    1218:	4981                	li	s3,0
    121a:	bd65                	j	10d2 <vprintf+0x60>
        putc(fd, c);
    121c:	85d2                	mv	a1,s4
    121e:	8556                	mv	a0,s5
    1220:	00000097          	auipc	ra,0x0
    1224:	d86080e7          	jalr	-634(ra) # fa6 <putc>
      state = 0;
    1228:	4981                	li	s3,0
    122a:	b565                	j	10d2 <vprintf+0x60>
        s = va_arg(ap, char*);
    122c:	8b4e                	mv	s6,s3
      state = 0;
    122e:	4981                	li	s3,0
    1230:	b54d                	j	10d2 <vprintf+0x60>
    }
  }
}
    1232:	70e6                	ld	ra,120(sp)
    1234:	7446                	ld	s0,112(sp)
    1236:	74a6                	ld	s1,104(sp)
    1238:	7906                	ld	s2,96(sp)
    123a:	69e6                	ld	s3,88(sp)
    123c:	6a46                	ld	s4,80(sp)
    123e:	6aa6                	ld	s5,72(sp)
    1240:	6b06                	ld	s6,64(sp)
    1242:	7be2                	ld	s7,56(sp)
    1244:	7c42                	ld	s8,48(sp)
    1246:	7ca2                	ld	s9,40(sp)
    1248:	7d02                	ld	s10,32(sp)
    124a:	6de2                	ld	s11,24(sp)
    124c:	6109                	addi	sp,sp,128
    124e:	8082                	ret

0000000000001250 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1250:	715d                	addi	sp,sp,-80
    1252:	ec06                	sd	ra,24(sp)
    1254:	e822                	sd	s0,16(sp)
    1256:	1000                	addi	s0,sp,32
    1258:	e010                	sd	a2,0(s0)
    125a:	e414                	sd	a3,8(s0)
    125c:	e818                	sd	a4,16(s0)
    125e:	ec1c                	sd	a5,24(s0)
    1260:	03043023          	sd	a6,32(s0)
    1264:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1268:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    126c:	8622                	mv	a2,s0
    126e:	00000097          	auipc	ra,0x0
    1272:	e04080e7          	jalr	-508(ra) # 1072 <vprintf>
}
    1276:	60e2                	ld	ra,24(sp)
    1278:	6442                	ld	s0,16(sp)
    127a:	6161                	addi	sp,sp,80
    127c:	8082                	ret

000000000000127e <printf>:

void
printf(const char *fmt, ...)
{
    127e:	711d                	addi	sp,sp,-96
    1280:	ec06                	sd	ra,24(sp)
    1282:	e822                	sd	s0,16(sp)
    1284:	1000                	addi	s0,sp,32
    1286:	e40c                	sd	a1,8(s0)
    1288:	e810                	sd	a2,16(s0)
    128a:	ec14                	sd	a3,24(s0)
    128c:	f018                	sd	a4,32(s0)
    128e:	f41c                	sd	a5,40(s0)
    1290:	03043823          	sd	a6,48(s0)
    1294:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1298:	00840613          	addi	a2,s0,8
    129c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    12a0:	85aa                	mv	a1,a0
    12a2:	4505                	li	a0,1
    12a4:	00000097          	auipc	ra,0x0
    12a8:	dce080e7          	jalr	-562(ra) # 1072 <vprintf>
}
    12ac:	60e2                	ld	ra,24(sp)
    12ae:	6442                	ld	s0,16(sp)
    12b0:	6125                	addi	sp,sp,96
    12b2:	8082                	ret

00000000000012b4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    12b4:	1141                	addi	sp,sp,-16
    12b6:	e422                	sd	s0,8(sp)
    12b8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    12ba:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12be:	00000797          	auipc	a5,0x0
    12c2:	3027b783          	ld	a5,770(a5) # 15c0 <freep>
    12c6:	a805                	j	12f6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    12c8:	4618                	lw	a4,8(a2)
    12ca:	9db9                	addw	a1,a1,a4
    12cc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    12d0:	6398                	ld	a4,0(a5)
    12d2:	6318                	ld	a4,0(a4)
    12d4:	fee53823          	sd	a4,-16(a0)
    12d8:	a091                	j	131c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    12da:	ff852703          	lw	a4,-8(a0)
    12de:	9e39                	addw	a2,a2,a4
    12e0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    12e2:	ff053703          	ld	a4,-16(a0)
    12e6:	e398                	sd	a4,0(a5)
    12e8:	a099                	j	132e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12ea:	6398                	ld	a4,0(a5)
    12ec:	00e7e463          	bltu	a5,a4,12f4 <free+0x40>
    12f0:	00e6ea63          	bltu	a3,a4,1304 <free+0x50>
{
    12f4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12f6:	fed7fae3          	bgeu	a5,a3,12ea <free+0x36>
    12fa:	6398                	ld	a4,0(a5)
    12fc:	00e6e463          	bltu	a3,a4,1304 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1300:	fee7eae3          	bltu	a5,a4,12f4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    1304:	ff852583          	lw	a1,-8(a0)
    1308:	6390                	ld	a2,0(a5)
    130a:	02059813          	slli	a6,a1,0x20
    130e:	01c85713          	srli	a4,a6,0x1c
    1312:	9736                	add	a4,a4,a3
    1314:	fae60ae3          	beq	a2,a4,12c8 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1318:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    131c:	4790                	lw	a2,8(a5)
    131e:	02061593          	slli	a1,a2,0x20
    1322:	01c5d713          	srli	a4,a1,0x1c
    1326:	973e                	add	a4,a4,a5
    1328:	fae689e3          	beq	a3,a4,12da <free+0x26>
  } else
    p->s.ptr = bp;
    132c:	e394                	sd	a3,0(a5)
  freep = p;
    132e:	00000717          	auipc	a4,0x0
    1332:	28f73923          	sd	a5,658(a4) # 15c0 <freep>
}
    1336:	6422                	ld	s0,8(sp)
    1338:	0141                	addi	sp,sp,16
    133a:	8082                	ret

000000000000133c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    133c:	7139                	addi	sp,sp,-64
    133e:	fc06                	sd	ra,56(sp)
    1340:	f822                	sd	s0,48(sp)
    1342:	f426                	sd	s1,40(sp)
    1344:	f04a                	sd	s2,32(sp)
    1346:	ec4e                	sd	s3,24(sp)
    1348:	e852                	sd	s4,16(sp)
    134a:	e456                	sd	s5,8(sp)
    134c:	e05a                	sd	s6,0(sp)
    134e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1350:	02051493          	slli	s1,a0,0x20
    1354:	9081                	srli	s1,s1,0x20
    1356:	04bd                	addi	s1,s1,15
    1358:	8091                	srli	s1,s1,0x4
    135a:	0014899b          	addiw	s3,s1,1
    135e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1360:	00000517          	auipc	a0,0x0
    1364:	26053503          	ld	a0,608(a0) # 15c0 <freep>
    1368:	c515                	beqz	a0,1394 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    136a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    136c:	4798                	lw	a4,8(a5)
    136e:	02977f63          	bgeu	a4,s1,13ac <malloc+0x70>
    1372:	8a4e                	mv	s4,s3
    1374:	0009871b          	sext.w	a4,s3
    1378:	6685                	lui	a3,0x1
    137a:	00d77363          	bgeu	a4,a3,1380 <malloc+0x44>
    137e:	6a05                	lui	s4,0x1
    1380:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1384:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1388:	00000917          	auipc	s2,0x0
    138c:	23890913          	addi	s2,s2,568 # 15c0 <freep>
  if(p == (char*)-1)
    1390:	5afd                	li	s5,-1
    1392:	a895                	j	1406 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    1394:	00000797          	auipc	a5,0x0
    1398:	29c78793          	addi	a5,a5,668 # 1630 <base>
    139c:	00000717          	auipc	a4,0x0
    13a0:	22f73223          	sd	a5,548(a4) # 15c0 <freep>
    13a4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    13a6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    13aa:	b7e1                	j	1372 <malloc+0x36>
      if(p->s.size == nunits)
    13ac:	02e48c63          	beq	s1,a4,13e4 <malloc+0xa8>
        p->s.size -= nunits;
    13b0:	4137073b          	subw	a4,a4,s3
    13b4:	c798                	sw	a4,8(a5)
        p += p->s.size;
    13b6:	02071693          	slli	a3,a4,0x20
    13ba:	01c6d713          	srli	a4,a3,0x1c
    13be:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    13c0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    13c4:	00000717          	auipc	a4,0x0
    13c8:	1ea73e23          	sd	a0,508(a4) # 15c0 <freep>
      return (void*)(p + 1);
    13cc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    13d0:	70e2                	ld	ra,56(sp)
    13d2:	7442                	ld	s0,48(sp)
    13d4:	74a2                	ld	s1,40(sp)
    13d6:	7902                	ld	s2,32(sp)
    13d8:	69e2                	ld	s3,24(sp)
    13da:	6a42                	ld	s4,16(sp)
    13dc:	6aa2                	ld	s5,8(sp)
    13de:	6b02                	ld	s6,0(sp)
    13e0:	6121                	addi	sp,sp,64
    13e2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    13e4:	6398                	ld	a4,0(a5)
    13e6:	e118                	sd	a4,0(a0)
    13e8:	bff1                	j	13c4 <malloc+0x88>
  hp->s.size = nu;
    13ea:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    13ee:	0541                	addi	a0,a0,16
    13f0:	00000097          	auipc	ra,0x0
    13f4:	ec4080e7          	jalr	-316(ra) # 12b4 <free>
  return freep;
    13f8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    13fc:	d971                	beqz	a0,13d0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13fe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1400:	4798                	lw	a4,8(a5)
    1402:	fa9775e3          	bgeu	a4,s1,13ac <malloc+0x70>
    if(p == freep)
    1406:	00093703          	ld	a4,0(s2)
    140a:	853e                	mv	a0,a5
    140c:	fef719e3          	bne	a4,a5,13fe <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    1410:	8552                	mv	a0,s4
    1412:	00000097          	auipc	ra,0x0
    1416:	b64080e7          	jalr	-1180(ra) # f76 <sbrk>
  if(p == (char*)-1)
    141a:	fd5518e3          	bne	a0,s5,13ea <malloc+0xae>
        return 0;
    141e:	4501                	li	a0,0
    1420:	bf45                	j	13d0 <malloc+0x94>
