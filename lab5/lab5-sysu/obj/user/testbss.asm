
obj/__user_testbss.out:     file format elf32-i386


Disassembly of section .text:

00800020 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800020:	55                   	push   %ebp
  800021:	89 e5                	mov    %esp,%ebp
  800023:	83 ec 28             	sub    $0x28,%esp
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  800026:	8d 45 14             	lea    0x14(%ebp),%eax
  800029:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80002c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80002f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800033:	8b 45 08             	mov    0x8(%ebp),%eax
  800036:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003a:	c7 04 24 a0 10 80 00 	movl   $0x8010a0,(%esp)
  800041:	e8 8a 02 00 00       	call   8002d0 <cprintf>
    vcprintf(fmt, ap);
  800046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	8b 45 10             	mov    0x10(%ebp),%eax
  800050:	89 04 24             	mov    %eax,(%esp)
  800053:	e8 45 02 00 00       	call   80029d <vcprintf>
    cprintf("\n");
  800058:	c7 04 24 ba 10 80 00 	movl   $0x8010ba,(%esp)
  80005f:	e8 6c 02 00 00       	call   8002d0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800064:	c7 04 24 f6 ff ff ff 	movl   $0xfffffff6,(%esp)
  80006b:	e8 5f 01 00 00       	call   8001cf <exit>

00800070 <__warn>:
}

void
__warn(const char *file, int line, const char *fmt, ...) {
  800070:	55                   	push   %ebp
  800071:	89 e5                	mov    %esp,%ebp
  800073:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  800076:	8d 45 14             	lea    0x14(%ebp),%eax
  800079:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user warning at %s:%d:\n    ", file, line);
  80007c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80007f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800083:	8b 45 08             	mov    0x8(%ebp),%eax
  800086:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008a:	c7 04 24 bc 10 80 00 	movl   $0x8010bc,(%esp)
  800091:	e8 3a 02 00 00       	call   8002d0 <cprintf>
    vcprintf(fmt, ap);
  800096:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800099:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009d:	8b 45 10             	mov    0x10(%ebp),%eax
  8000a0:	89 04 24             	mov    %eax,(%esp)
  8000a3:	e8 f5 01 00 00       	call   80029d <vcprintf>
    cprintf("\n");
  8000a8:	c7 04 24 ba 10 80 00 	movl   $0x8010ba,(%esp)
  8000af:	e8 1c 02 00 00       	call   8002d0 <cprintf>
    va_end(ap);
}
  8000b4:	90                   	nop
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    

008000b7 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int num, ...) {
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
  8000bd:	83 ec 20             	sub    $0x20,%esp
    va_list ap;
    va_start(ap, num);
  8000c0:	8d 45 0c             	lea    0xc(%ebp),%eax
  8000c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  8000c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8000cd:	eb 15                	jmp    8000e4 <syscall+0x2d>
        a[i] = va_arg(ap, uint32_t);
  8000cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8000d2:	8d 50 04             	lea    0x4(%eax),%edx
  8000d5:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8000d8:	8b 10                	mov    (%eax),%edx
  8000da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000dd:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
    for (i = 0; i < MAX_ARGS; i ++) {
  8000e1:	ff 45 f0             	incl   -0x10(%ebp)
  8000e4:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
  8000e8:	7e e5                	jle    8000cf <syscall+0x18>
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL),
          "a" (num),
          "d" (a[0]),
  8000ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
          "c" (a[1]),
  8000ed:	8b 4d d8             	mov    -0x28(%ebp),%ecx
          "b" (a[2]),
  8000f0:	8b 5d dc             	mov    -0x24(%ebp),%ebx
          "D" (a[3]),
  8000f3:	8b 7d e0             	mov    -0x20(%ebp),%edi
          "S" (a[4])
  8000f6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
    asm volatile (
  8000f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8000fc:	cd 80                	int    $0x80
  8000fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "cc", "memory");
    return ret;
  800101:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	5b                   	pop    %ebx
  800108:	5e                   	pop    %esi
  800109:	5f                   	pop    %edi
  80010a:	5d                   	pop    %ebp
  80010b:	c3                   	ret    

0080010c <sys_exit>:

int
sys_exit(int error_code) {
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_exit, error_code);
  800112:	8b 45 08             	mov    0x8(%ebp),%eax
  800115:	89 44 24 04          	mov    %eax,0x4(%esp)
  800119:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800120:	e8 92 ff ff ff       	call   8000b7 <syscall>
}
  800125:	c9                   	leave  
  800126:	c3                   	ret    

00800127 <sys_fork>:

int
sys_fork(void) {
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_fork);
  80012d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800134:	e8 7e ff ff ff       	call   8000b7 <syscall>
}
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <sys_wait>:

int
sys_wait(int pid, int *store) {
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_wait, pid, store);
  800141:	8b 45 0c             	mov    0xc(%ebp),%eax
  800144:	89 44 24 08          	mov    %eax,0x8(%esp)
  800148:	8b 45 08             	mov    0x8(%ebp),%eax
  80014b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014f:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800156:	e8 5c ff ff ff       	call   8000b7 <syscall>
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <sys_yield>:

int
sys_yield(void) {
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_yield);
  800163:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80016a:	e8 48 ff ff ff       	call   8000b7 <syscall>
}
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <sys_kill>:

int
sys_kill(int pid) {
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_kill, pid);
  800177:	8b 45 08             	mov    0x8(%ebp),%eax
  80017a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017e:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800185:	e8 2d ff ff ff       	call   8000b7 <syscall>
}
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <sys_getpid>:

int
sys_getpid(void) {
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_getpid);
  800192:	c7 04 24 12 00 00 00 	movl   $0x12,(%esp)
  800199:	e8 19 ff ff ff       	call   8000b7 <syscall>
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <sys_putc>:

int
sys_putc(int c) {
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_putc, c);
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ad:	c7 04 24 1e 00 00 00 	movl   $0x1e,(%esp)
  8001b4:	e8 fe fe ff ff       	call   8000b7 <syscall>
}
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <sys_pgdir>:

int
sys_pgdir(void) {
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_pgdir);
  8001c1:	c7 04 24 1f 00 00 00 	movl   $0x1f,(%esp)
  8001c8:	e8 ea fe ff ff       	call   8000b7 <syscall>
}
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 18             	sub    $0x18,%esp
    sys_exit(error_code);
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	e8 2c ff ff ff       	call   80010c <sys_exit>
    cprintf("BUG: exit failed.\n");
  8001e0:	c7 04 24 d8 10 80 00 	movl   $0x8010d8,(%esp)
  8001e7:	e8 e4 00 00 00       	call   8002d0 <cprintf>
    while (1);
  8001ec:	eb fe                	jmp    8001ec <exit+0x1d>

008001ee <fork>:
}

int
fork(void) {
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  8001f4:	e8 2e ff ff ff       	call   800127 <sys_fork>
}
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <wait>:

int
wait(void) {
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(0, NULL);
  800201:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800208:	00 
  800209:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800210:	e8 26 ff ff ff       	call   80013b <sys_wait>
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <waitpid>:

int
waitpid(int pid, int *store) {
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(pid, store);
  80021d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	89 04 24             	mov    %eax,(%esp)
  80022a:	e8 0c ff ff ff       	call   80013b <sys_wait>
}
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <yield>:

void
yield(void) {
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  800237:	e8 21 ff ff ff       	call   80015d <sys_yield>
}
  80023c:	90                   	nop
  80023d:	c9                   	leave  
  80023e:	c3                   	ret    

0080023f <kill>:

int
kill(int pid) {
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	83 ec 18             	sub    $0x18,%esp
    return sys_kill(pid);
  800245:	8b 45 08             	mov    0x8(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 21 ff ff ff       	call   800171 <sys_kill>
}
  800250:	c9                   	leave  
  800251:	c3                   	ret    

00800252 <getpid>:

int
getpid(void) {
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  800258:	e8 2f ff ff ff       	call   80018c <sys_getpid>
}
  80025d:	c9                   	leave  
  80025e:	c3                   	ret    

0080025f <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  800265:	e8 51 ff ff ff       	call   8001bb <sys_pgdir>
}
  80026a:	90                   	nop
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <_start>:
.text
.globl _start
_start:
    # set ebp for backtrace
    movl $0x0, %ebp
  80026d:	bd 00 00 00 00       	mov    $0x0,%ebp

    # move down the esp register
    # since it may cause page fault in backtrace
    subl $0x20, %esp
  800272:	83 ec 20             	sub    $0x20,%esp

    # call user-program function
    call umain
  800275:	e8 cb 00 00 00       	call   800345 <umain>
1:  jmp 1b
  80027a:	eb fe                	jmp    80027a <_start+0xd>

0080027c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 18             	sub    $0x18,%esp
    sys_putc(c);
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	e8 13 ff ff ff       	call   8001a0 <sys_putc>
    (*cnt) ++;
  80028d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800290:	8b 00                	mov    (%eax),%eax
  800292:	8d 50 01             	lea    0x1(%eax),%edx
  800295:	8b 45 0c             	mov    0xc(%ebp),%eax
  800298:	89 10                	mov    %edx,(%eax)
}
  80029a:	90                   	nop
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    

0080029d <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  8002a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8002aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8002bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bf:	c7 04 24 7c 02 80 00 	movl   $0x80027c,(%esp)
  8002c6:	e8 06 07 00 00       	call   8009d1 <vprintfmt>
    return cnt;
  8002cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002ce:	c9                   	leave  
  8002cf:	c3                   	ret    

008002d0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  8002d6:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vcprintf(fmt, ap);
  8002dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e6:	89 04 24             	mov    %eax,(%esp)
  8002e9:	e8 af ff ff ff       	call   80029d <vcprintf>
  8002ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  8002f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002f4:	c9                   	leave  
  8002f5:	c3                   	ret    

008002f6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  8002fc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  800303:	eb 13                	jmp    800318 <cputs+0x22>
        cputch(c, &cnt);
  800305:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  800309:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80030c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	e8 64 ff ff ff       	call   80027c <cputch>
    while ((c = *str ++) != '\0') {
  800318:	8b 45 08             	mov    0x8(%ebp),%eax
  80031b:	8d 50 01             	lea    0x1(%eax),%edx
  80031e:	89 55 08             	mov    %edx,0x8(%ebp)
  800321:	0f b6 00             	movzbl (%eax),%eax
  800324:	88 45 f7             	mov    %al,-0x9(%ebp)
  800327:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  80032b:	75 d8                	jne    800305 <cputs+0xf>
    }
    cputch('\n', &cnt);
  80032d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800330:	89 44 24 04          	mov    %eax,0x4(%esp)
  800334:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80033b:	e8 3c ff ff ff       	call   80027c <cputch>
    return cnt;
  800340:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 28             	sub    $0x28,%esp
    int ret = main();
  80034b:	e8 2a 0c 00 00       	call   800f7a <main>
  800350:	89 45 f4             	mov    %eax,-0xc(%ebp)
    exit(ret);
  800353:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800356:	89 04 24             	mov    %eax,(%esp)
  800359:	e8 71 fe ff ff       	call   8001cf <exit>

0080035e <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800364:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  80036b:	eb 03                	jmp    800370 <strlen+0x12>
        cnt ++;
  80036d:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  800370:	8b 45 08             	mov    0x8(%ebp),%eax
  800373:	8d 50 01             	lea    0x1(%eax),%edx
  800376:	89 55 08             	mov    %edx,0x8(%ebp)
  800379:	0f b6 00             	movzbl (%eax),%eax
  80037c:	84 c0                	test   %al,%al
  80037e:	75 ed                	jne    80036d <strlen+0xf>
    }
    return cnt;
  800380:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  80038b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  800392:	eb 03                	jmp    800397 <strnlen+0x12>
        cnt ++;
  800394:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  800397:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80039a:	3b 45 0c             	cmp    0xc(%ebp),%eax
  80039d:	73 10                	jae    8003af <strnlen+0x2a>
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	8d 50 01             	lea    0x1(%eax),%edx
  8003a5:	89 55 08             	mov    %edx,0x8(%ebp)
  8003a8:	0f b6 00             	movzbl (%eax),%eax
  8003ab:	84 c0                	test   %al,%al
  8003ad:	75 e5                	jne    800394 <strnlen+0xf>
    }
    return cnt;
  8003af:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8003b2:	c9                   	leave  
  8003b3:	c3                   	ret    

008003b4 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	57                   	push   %edi
  8003b8:	56                   	push   %esi
  8003b9:	83 ec 20             	sub    $0x20,%esp
  8003bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8003c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  8003c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8003cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003ce:	89 d1                	mov    %edx,%ecx
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	89 ce                	mov    %ecx,%esi
  8003d4:	89 d7                	mov    %edx,%edi
  8003d6:	ac                   	lods   %ds:(%esi),%al
  8003d7:	aa                   	stos   %al,%es:(%edi)
  8003d8:	84 c0                	test   %al,%al
  8003da:	75 fa                	jne    8003d6 <strcpy+0x22>
  8003dc:	89 fa                	mov    %edi,%edx
  8003de:	89 f1                	mov    %esi,%ecx
  8003e0:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8003e3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8003e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  8003e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  8003ec:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  8003ed:	83 c4 20             	add    $0x20,%esp
  8003f0:	5e                   	pop    %esi
  8003f1:	5f                   	pop    %edi
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  8003fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  800400:	eb 1e                	jmp    800420 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  800402:	8b 45 0c             	mov    0xc(%ebp),%eax
  800405:	0f b6 10             	movzbl (%eax),%edx
  800408:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80040b:	88 10                	mov    %dl,(%eax)
  80040d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800410:	0f b6 00             	movzbl (%eax),%eax
  800413:	84 c0                	test   %al,%al
  800415:	74 03                	je     80041a <strncpy+0x26>
            src ++;
  800417:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  80041a:	ff 45 fc             	incl   -0x4(%ebp)
  80041d:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  800420:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800424:	75 dc                	jne    800402 <strncpy+0xe>
    }
    return dst;
  800426:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800429:	c9                   	leave  
  80042a:	c3                   	ret    

0080042b <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	57                   	push   %edi
  80042f:	56                   	push   %esi
  800430:	83 ec 20             	sub    $0x20,%esp
  800433:	8b 45 08             	mov    0x8(%ebp),%eax
  800436:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800439:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  80043f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800445:	89 d1                	mov    %edx,%ecx
  800447:	89 c2                	mov    %eax,%edx
  800449:	89 ce                	mov    %ecx,%esi
  80044b:	89 d7                	mov    %edx,%edi
  80044d:	ac                   	lods   %ds:(%esi),%al
  80044e:	ae                   	scas   %es:(%edi),%al
  80044f:	75 08                	jne    800459 <strcmp+0x2e>
  800451:	84 c0                	test   %al,%al
  800453:	75 f8                	jne    80044d <strcmp+0x22>
  800455:	31 c0                	xor    %eax,%eax
  800457:	eb 04                	jmp    80045d <strcmp+0x32>
  800459:	19 c0                	sbb    %eax,%eax
  80045b:	0c 01                	or     $0x1,%al
  80045d:	89 fa                	mov    %edi,%edx
  80045f:	89 f1                	mov    %esi,%ecx
  800461:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800464:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800467:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  80046a:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  80046d:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  80046e:	83 c4 20             	add    $0x20,%esp
  800471:	5e                   	pop    %esi
  800472:	5f                   	pop    %edi
  800473:	5d                   	pop    %ebp
  800474:	c3                   	ret    

00800475 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  800475:	55                   	push   %ebp
  800476:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800478:	eb 09                	jmp    800483 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  80047a:	ff 4d 10             	decl   0x10(%ebp)
  80047d:	ff 45 08             	incl   0x8(%ebp)
  800480:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800483:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800487:	74 1a                	je     8004a3 <strncmp+0x2e>
  800489:	8b 45 08             	mov    0x8(%ebp),%eax
  80048c:	0f b6 00             	movzbl (%eax),%eax
  80048f:	84 c0                	test   %al,%al
  800491:	74 10                	je     8004a3 <strncmp+0x2e>
  800493:	8b 45 08             	mov    0x8(%ebp),%eax
  800496:	0f b6 10             	movzbl (%eax),%edx
  800499:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049c:	0f b6 00             	movzbl (%eax),%eax
  80049f:	38 c2                	cmp    %al,%dl
  8004a1:	74 d7                	je     80047a <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  8004a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8004a7:	74 18                	je     8004c1 <strncmp+0x4c>
  8004a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ac:	0f b6 00             	movzbl (%eax),%eax
  8004af:	0f b6 d0             	movzbl %al,%edx
  8004b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b5:	0f b6 00             	movzbl (%eax),%eax
  8004b8:	0f b6 c0             	movzbl %al,%eax
  8004bb:	29 c2                	sub    %eax,%edx
  8004bd:	89 d0                	mov    %edx,%eax
  8004bf:	eb 05                	jmp    8004c6 <strncmp+0x51>
  8004c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004c6:	5d                   	pop    %ebp
  8004c7:	c3                   	ret    

008004c8 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 04             	sub    $0x4,%esp
  8004ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d1:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  8004d4:	eb 13                	jmp    8004e9 <strchr+0x21>
        if (*s == c) {
  8004d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d9:	0f b6 00             	movzbl (%eax),%eax
  8004dc:	38 45 fc             	cmp    %al,-0x4(%ebp)
  8004df:	75 05                	jne    8004e6 <strchr+0x1e>
            return (char *)s;
  8004e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e4:	eb 12                	jmp    8004f8 <strchr+0x30>
        }
        s ++;
  8004e6:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  8004e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ec:	0f b6 00             	movzbl (%eax),%eax
  8004ef:	84 c0                	test   %al,%al
  8004f1:	75 e3                	jne    8004d6 <strchr+0xe>
    }
    return NULL;
  8004f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    

008004fa <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	83 ec 04             	sub    $0x4,%esp
  800500:	8b 45 0c             	mov    0xc(%ebp),%eax
  800503:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800506:	eb 0e                	jmp    800516 <strfind+0x1c>
        if (*s == c) {
  800508:	8b 45 08             	mov    0x8(%ebp),%eax
  80050b:	0f b6 00             	movzbl (%eax),%eax
  80050e:	38 45 fc             	cmp    %al,-0x4(%ebp)
  800511:	74 0f                	je     800522 <strfind+0x28>
            break;
        }
        s ++;
  800513:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  800516:	8b 45 08             	mov    0x8(%ebp),%eax
  800519:	0f b6 00             	movzbl (%eax),%eax
  80051c:	84 c0                	test   %al,%al
  80051e:	75 e8                	jne    800508 <strfind+0xe>
  800520:	eb 01                	jmp    800523 <strfind+0x29>
            break;
  800522:	90                   	nop
    }
    return (char *)s;
  800523:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800526:	c9                   	leave  
  800527:	c3                   	ret    

00800528 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  80052e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  800535:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  80053c:	eb 03                	jmp    800541 <strtol+0x19>
        s ++;
  80053e:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  800541:	8b 45 08             	mov    0x8(%ebp),%eax
  800544:	0f b6 00             	movzbl (%eax),%eax
  800547:	3c 20                	cmp    $0x20,%al
  800549:	74 f3                	je     80053e <strtol+0x16>
  80054b:	8b 45 08             	mov    0x8(%ebp),%eax
  80054e:	0f b6 00             	movzbl (%eax),%eax
  800551:	3c 09                	cmp    $0x9,%al
  800553:	74 e9                	je     80053e <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  800555:	8b 45 08             	mov    0x8(%ebp),%eax
  800558:	0f b6 00             	movzbl (%eax),%eax
  80055b:	3c 2b                	cmp    $0x2b,%al
  80055d:	75 05                	jne    800564 <strtol+0x3c>
        s ++;
  80055f:	ff 45 08             	incl   0x8(%ebp)
  800562:	eb 14                	jmp    800578 <strtol+0x50>
    }
    else if (*s == '-') {
  800564:	8b 45 08             	mov    0x8(%ebp),%eax
  800567:	0f b6 00             	movzbl (%eax),%eax
  80056a:	3c 2d                	cmp    $0x2d,%al
  80056c:	75 0a                	jne    800578 <strtol+0x50>
        s ++, neg = 1;
  80056e:	ff 45 08             	incl   0x8(%ebp)
  800571:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  800578:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80057c:	74 06                	je     800584 <strtol+0x5c>
  80057e:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800582:	75 22                	jne    8005a6 <strtol+0x7e>
  800584:	8b 45 08             	mov    0x8(%ebp),%eax
  800587:	0f b6 00             	movzbl (%eax),%eax
  80058a:	3c 30                	cmp    $0x30,%al
  80058c:	75 18                	jne    8005a6 <strtol+0x7e>
  80058e:	8b 45 08             	mov    0x8(%ebp),%eax
  800591:	40                   	inc    %eax
  800592:	0f b6 00             	movzbl (%eax),%eax
  800595:	3c 78                	cmp    $0x78,%al
  800597:	75 0d                	jne    8005a6 <strtol+0x7e>
        s += 2, base = 16;
  800599:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  80059d:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8005a4:	eb 29                	jmp    8005cf <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  8005a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8005aa:	75 16                	jne    8005c2 <strtol+0x9a>
  8005ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8005af:	0f b6 00             	movzbl (%eax),%eax
  8005b2:	3c 30                	cmp    $0x30,%al
  8005b4:	75 0c                	jne    8005c2 <strtol+0x9a>
        s ++, base = 8;
  8005b6:	ff 45 08             	incl   0x8(%ebp)
  8005b9:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8005c0:	eb 0d                	jmp    8005cf <strtol+0xa7>
    }
    else if (base == 0) {
  8005c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8005c6:	75 07                	jne    8005cf <strtol+0xa7>
        base = 10;
  8005c8:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  8005cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d2:	0f b6 00             	movzbl (%eax),%eax
  8005d5:	3c 2f                	cmp    $0x2f,%al
  8005d7:	7e 1b                	jle    8005f4 <strtol+0xcc>
  8005d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005dc:	0f b6 00             	movzbl (%eax),%eax
  8005df:	3c 39                	cmp    $0x39,%al
  8005e1:	7f 11                	jg     8005f4 <strtol+0xcc>
            dig = *s - '0';
  8005e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e6:	0f b6 00             	movzbl (%eax),%eax
  8005e9:	0f be c0             	movsbl %al,%eax
  8005ec:	83 e8 30             	sub    $0x30,%eax
  8005ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8005f2:	eb 48                	jmp    80063c <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  8005f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f7:	0f b6 00             	movzbl (%eax),%eax
  8005fa:	3c 60                	cmp    $0x60,%al
  8005fc:	7e 1b                	jle    800619 <strtol+0xf1>
  8005fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800601:	0f b6 00             	movzbl (%eax),%eax
  800604:	3c 7a                	cmp    $0x7a,%al
  800606:	7f 11                	jg     800619 <strtol+0xf1>
            dig = *s - 'a' + 10;
  800608:	8b 45 08             	mov    0x8(%ebp),%eax
  80060b:	0f b6 00             	movzbl (%eax),%eax
  80060e:	0f be c0             	movsbl %al,%eax
  800611:	83 e8 57             	sub    $0x57,%eax
  800614:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800617:	eb 23                	jmp    80063c <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  800619:	8b 45 08             	mov    0x8(%ebp),%eax
  80061c:	0f b6 00             	movzbl (%eax),%eax
  80061f:	3c 40                	cmp    $0x40,%al
  800621:	7e 3b                	jle    80065e <strtol+0x136>
  800623:	8b 45 08             	mov    0x8(%ebp),%eax
  800626:	0f b6 00             	movzbl (%eax),%eax
  800629:	3c 5a                	cmp    $0x5a,%al
  80062b:	7f 31                	jg     80065e <strtol+0x136>
            dig = *s - 'A' + 10;
  80062d:	8b 45 08             	mov    0x8(%ebp),%eax
  800630:	0f b6 00             	movzbl (%eax),%eax
  800633:	0f be c0             	movsbl %al,%eax
  800636:	83 e8 37             	sub    $0x37,%eax
  800639:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  80063c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80063f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800642:	7d 19                	jge    80065d <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  800644:	ff 45 08             	incl   0x8(%ebp)
  800647:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80064a:	0f af 45 10          	imul   0x10(%ebp),%eax
  80064e:	89 c2                	mov    %eax,%edx
  800650:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800653:	01 d0                	add    %edx,%eax
  800655:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  800658:	e9 72 ff ff ff       	jmp    8005cf <strtol+0xa7>
            break;
  80065d:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  80065e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800662:	74 08                	je     80066c <strtol+0x144>
        *endptr = (char *) s;
  800664:	8b 45 0c             	mov    0xc(%ebp),%eax
  800667:	8b 55 08             	mov    0x8(%ebp),%edx
  80066a:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  80066c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800670:	74 07                	je     800679 <strtol+0x151>
  800672:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800675:	f7 d8                	neg    %eax
  800677:	eb 03                	jmp    80067c <strtol+0x154>
  800679:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80067c:	c9                   	leave  
  80067d:	c3                   	ret    

0080067e <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  80067e:	55                   	push   %ebp
  80067f:	89 e5                	mov    %esp,%ebp
  800681:	57                   	push   %edi
  800682:	83 ec 24             	sub    $0x24,%esp
  800685:	8b 45 0c             	mov    0xc(%ebp),%eax
  800688:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  80068b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80068f:	8b 55 08             	mov    0x8(%ebp),%edx
  800692:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800695:	88 45 f7             	mov    %al,-0x9(%ebp)
  800698:	8b 45 10             	mov    0x10(%ebp),%eax
  80069b:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  80069e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8006a1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8006a5:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8006a8:	89 d7                	mov    %edx,%edi
  8006aa:	f3 aa                	rep stos %al,%es:(%edi)
  8006ac:	89 fa                	mov    %edi,%edx
  8006ae:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8006b1:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  8006b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8006b7:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  8006b8:	83 c4 24             	add    $0x24,%esp
  8006bb:	5f                   	pop    %edi
  8006bc:	5d                   	pop    %ebp
  8006bd:	c3                   	ret    

008006be <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
  8006c1:	57                   	push   %edi
  8006c2:	56                   	push   %esi
  8006c3:	53                   	push   %ebx
  8006c4:	83 ec 30             	sub    $0x30,%esp
  8006c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d6:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  8006d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006dc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  8006df:	73 42                	jae    800723 <memmove+0x65>
  8006e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  8006f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006f6:	c1 e8 02             	shr    $0x2,%eax
  8006f9:	89 c1                	mov    %eax,%ecx
    asm volatile (
  8006fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800701:	89 d7                	mov    %edx,%edi
  800703:	89 c6                	mov    %eax,%esi
  800705:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800707:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80070a:	83 e1 03             	and    $0x3,%ecx
  80070d:	74 02                	je     800711 <memmove+0x53>
  80070f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800711:	89 f0                	mov    %esi,%eax
  800713:	89 fa                	mov    %edi,%edx
  800715:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800718:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80071b:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  80071e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  800721:	eb 36                	jmp    800759 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  800723:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800726:	8d 50 ff             	lea    -0x1(%eax),%edx
  800729:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072c:	01 c2                	add    %eax,%edx
  80072e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800731:	8d 48 ff             	lea    -0x1(%eax),%ecx
  800734:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800737:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  80073a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80073d:	89 c1                	mov    %eax,%ecx
  80073f:	89 d8                	mov    %ebx,%eax
  800741:	89 d6                	mov    %edx,%esi
  800743:	89 c7                	mov    %eax,%edi
  800745:	fd                   	std    
  800746:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800748:	fc                   	cld    
  800749:	89 f8                	mov    %edi,%eax
  80074b:	89 f2                	mov    %esi,%edx
  80074d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800750:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800753:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  800756:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  800759:	83 c4 30             	add    $0x30,%esp
  80075c:	5b                   	pop    %ebx
  80075d:	5e                   	pop    %esi
  80075e:	5f                   	pop    %edi
  80075f:	5d                   	pop    %ebp
  800760:	c3                   	ret    

00800761 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	57                   	push   %edi
  800765:	56                   	push   %esi
  800766:	83 ec 20             	sub    $0x20,%esp
  800769:	8b 45 08             	mov    0x8(%ebp),%eax
  80076c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80076f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800772:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800775:	8b 45 10             	mov    0x10(%ebp),%eax
  800778:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  80077b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077e:	c1 e8 02             	shr    $0x2,%eax
  800781:	89 c1                	mov    %eax,%ecx
    asm volatile (
  800783:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800786:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800789:	89 d7                	mov    %edx,%edi
  80078b:	89 c6                	mov    %eax,%esi
  80078d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80078f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800792:	83 e1 03             	and    $0x3,%ecx
  800795:	74 02                	je     800799 <memcpy+0x38>
  800797:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800799:	89 f0                	mov    %esi,%eax
  80079b:	89 fa                	mov    %edi,%edx
  80079d:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  8007a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  8007a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  8007a9:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  8007aa:	83 c4 20             	add    $0x20,%esp
  8007ad:	5e                   	pop    %esi
  8007ae:	5f                   	pop    %edi
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  8007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  8007c3:	eb 2e                	jmp    8007f3 <memcmp+0x42>
        if (*s1 != *s2) {
  8007c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c8:	0f b6 10             	movzbl (%eax),%edx
  8007cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8007ce:	0f b6 00             	movzbl (%eax),%eax
  8007d1:	38 c2                	cmp    %al,%dl
  8007d3:	74 18                	je     8007ed <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  8007d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d8:	0f b6 00             	movzbl (%eax),%eax
  8007db:	0f b6 d0             	movzbl %al,%edx
  8007de:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8007e1:	0f b6 00             	movzbl (%eax),%eax
  8007e4:	0f b6 c0             	movzbl %al,%eax
  8007e7:	29 c2                	sub    %eax,%edx
  8007e9:	89 d0                	mov    %edx,%eax
  8007eb:	eb 18                	jmp    800805 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  8007ed:	ff 45 fc             	incl   -0x4(%ebp)
  8007f0:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  8007f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f6:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007f9:	89 55 10             	mov    %edx,0x10(%ebp)
  8007fc:	85 c0                	test   %eax,%eax
  8007fe:	75 c5                	jne    8007c5 <memcmp+0x14>
    }
    return 0;
  800800:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	83 ec 58             	sub    $0x58,%esp
  80080d:	8b 45 10             	mov    0x10(%ebp),%eax
  800810:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800813:	8b 45 14             	mov    0x14(%ebp),%eax
  800816:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  800819:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80081c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80081f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800822:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  800825:	8b 45 18             	mov    0x18(%ebp),%eax
  800828:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80082b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80082e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800831:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800834:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800837:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80083d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800841:	74 1c                	je     80085f <printnum+0x58>
  800843:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800846:	ba 00 00 00 00       	mov    $0x0,%edx
  80084b:	f7 75 e4             	divl   -0x1c(%ebp)
  80084e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800851:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800854:	ba 00 00 00 00       	mov    $0x0,%edx
  800859:	f7 75 e4             	divl   -0x1c(%ebp)
  80085c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80085f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800862:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800865:	f7 75 e4             	divl   -0x1c(%ebp)
  800868:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80086b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80086e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800871:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800874:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800877:	89 55 ec             	mov    %edx,-0x14(%ebp)
  80087a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80087d:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800880:	8b 45 18             	mov    0x18(%ebp),%eax
  800883:	ba 00 00 00 00       	mov    $0x0,%edx
  800888:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80088b:	72 56                	jb     8008e3 <printnum+0xdc>
  80088d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800890:	77 05                	ja     800897 <printnum+0x90>
  800892:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  800895:	72 4c                	jb     8008e3 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  800897:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80089a:	8d 50 ff             	lea    -0x1(%eax),%edx
  80089d:	8b 45 20             	mov    0x20(%ebp),%eax
  8008a0:	89 44 24 18          	mov    %eax,0x18(%esp)
  8008a4:	89 54 24 14          	mov    %edx,0x14(%esp)
  8008a8:	8b 45 18             	mov    0x18(%ebp),%eax
  8008ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008af:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8008b2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8008b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	89 04 24             	mov    %eax,(%esp)
  8008ca:	e8 38 ff ff ff       	call   800807 <printnum>
  8008cf:	eb 1b                	jmp    8008ec <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  8008d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d8:	8b 45 20             	mov    0x20(%ebp),%eax
  8008db:	89 04 24             	mov    %eax,(%esp)
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	ff d0                	call   *%eax
        while (-- width > 0)
  8008e3:	ff 4d 1c             	decl   0x1c(%ebp)
  8008e6:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8008ea:	7f e5                	jg     8008d1 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8008ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008ef:	05 04 12 80 00       	add    $0x801204,%eax
  8008f4:	0f b6 00             	movzbl (%eax),%eax
  8008f7:	0f be c0             	movsbl %al,%eax
  8008fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800901:	89 04 24             	mov    %eax,(%esp)
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	ff d0                	call   *%eax
}
  800909:	90                   	nop
  80090a:	c9                   	leave  
  80090b:	c3                   	ret    

0080090c <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  80090f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800913:	7e 14                	jle    800929 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8b 00                	mov    (%eax),%eax
  80091a:	8d 48 08             	lea    0x8(%eax),%ecx
  80091d:	8b 55 08             	mov    0x8(%ebp),%edx
  800920:	89 0a                	mov    %ecx,(%edx)
  800922:	8b 50 04             	mov    0x4(%eax),%edx
  800925:	8b 00                	mov    (%eax),%eax
  800927:	eb 30                	jmp    800959 <getuint+0x4d>
    }
    else if (lflag) {
  800929:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80092d:	74 16                	je     800945 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 00                	mov    (%eax),%eax
  800934:	8d 48 04             	lea    0x4(%eax),%ecx
  800937:	8b 55 08             	mov    0x8(%ebp),%edx
  80093a:	89 0a                	mov    %ecx,(%edx)
  80093c:	8b 00                	mov    (%eax),%eax
  80093e:	ba 00 00 00 00       	mov    $0x0,%edx
  800943:	eb 14                	jmp    800959 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8b 00                	mov    (%eax),%eax
  80094a:	8d 48 04             	lea    0x4(%eax),%ecx
  80094d:	8b 55 08             	mov    0x8(%ebp),%edx
  800950:	89 0a                	mov    %ecx,(%edx)
  800952:	8b 00                	mov    (%eax),%eax
  800954:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  80095e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800962:	7e 14                	jle    800978 <getint+0x1d>
        return va_arg(*ap, long long);
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8b 00                	mov    (%eax),%eax
  800969:	8d 48 08             	lea    0x8(%eax),%ecx
  80096c:	8b 55 08             	mov    0x8(%ebp),%edx
  80096f:	89 0a                	mov    %ecx,(%edx)
  800971:	8b 50 04             	mov    0x4(%eax),%edx
  800974:	8b 00                	mov    (%eax),%eax
  800976:	eb 28                	jmp    8009a0 <getint+0x45>
    }
    else if (lflag) {
  800978:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80097c:	74 12                	je     800990 <getint+0x35>
        return va_arg(*ap, long);
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 00                	mov    (%eax),%eax
  800983:	8d 48 04             	lea    0x4(%eax),%ecx
  800986:	8b 55 08             	mov    0x8(%ebp),%edx
  800989:	89 0a                	mov    %ecx,(%edx)
  80098b:	8b 00                	mov    (%eax),%eax
  80098d:	99                   	cltd   
  80098e:	eb 10                	jmp    8009a0 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 00                	mov    (%eax),%eax
  800995:	8d 48 04             	lea    0x4(%eax),%ecx
  800998:	8b 55 08             	mov    0x8(%ebp),%edx
  80099b:	89 0a                	mov    %ecx,(%edx)
  80099d:	8b 00                	mov    (%eax),%eax
  80099f:	99                   	cltd   
    }
}
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  8009a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  8009ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	89 04 24             	mov    %eax,(%esp)
  8009c9:	e8 03 00 00 00       	call   8009d1 <vprintfmt>
    va_end(ap);
}
  8009ce:	90                   	nop
  8009cf:	c9                   	leave  
  8009d0:	c3                   	ret    

008009d1 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8009d9:	eb 17                	jmp    8009f2 <vprintfmt+0x21>
            if (ch == '\0') {
  8009db:	85 db                	test   %ebx,%ebx
  8009dd:	0f 84 bf 03 00 00    	je     800da2 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  8009e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ea:	89 1c 24             	mov    %ebx,(%esp)
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8009f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f5:	8d 50 01             	lea    0x1(%eax),%edx
  8009f8:	89 55 10             	mov    %edx,0x10(%ebp)
  8009fb:	0f b6 00             	movzbl (%eax),%eax
  8009fe:	0f b6 d8             	movzbl %al,%ebx
  800a01:	83 fb 25             	cmp    $0x25,%ebx
  800a04:	75 d5                	jne    8009db <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  800a06:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  800a0a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800a11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a14:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  800a17:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800a1e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a21:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800a24:	8b 45 10             	mov    0x10(%ebp),%eax
  800a27:	8d 50 01             	lea    0x1(%eax),%edx
  800a2a:	89 55 10             	mov    %edx,0x10(%ebp)
  800a2d:	0f b6 00             	movzbl (%eax),%eax
  800a30:	0f b6 d8             	movzbl %al,%ebx
  800a33:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800a36:	83 f8 55             	cmp    $0x55,%eax
  800a39:	0f 87 37 03 00 00    	ja     800d76 <vprintfmt+0x3a5>
  800a3f:	8b 04 85 28 12 80 00 	mov    0x801228(,%eax,4),%eax
  800a46:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  800a48:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  800a4c:	eb d6                	jmp    800a24 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  800a4e:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  800a52:	eb d0                	jmp    800a24 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800a54:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  800a5b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a5e:	89 d0                	mov    %edx,%eax
  800a60:	c1 e0 02             	shl    $0x2,%eax
  800a63:	01 d0                	add    %edx,%eax
  800a65:	01 c0                	add    %eax,%eax
  800a67:	01 d8                	add    %ebx,%eax
  800a69:	83 e8 30             	sub    $0x30,%eax
  800a6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  800a6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a72:	0f b6 00             	movzbl (%eax),%eax
  800a75:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  800a78:	83 fb 2f             	cmp    $0x2f,%ebx
  800a7b:	7e 38                	jle    800ab5 <vprintfmt+0xe4>
  800a7d:	83 fb 39             	cmp    $0x39,%ebx
  800a80:	7f 33                	jg     800ab5 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  800a82:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  800a85:	eb d4                	jmp    800a5b <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  800a87:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8a:	8d 50 04             	lea    0x4(%eax),%edx
  800a8d:	89 55 14             	mov    %edx,0x14(%ebp)
  800a90:	8b 00                	mov    (%eax),%eax
  800a92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  800a95:	eb 1f                	jmp    800ab6 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  800a97:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800a9b:	79 87                	jns    800a24 <vprintfmt+0x53>
                width = 0;
  800a9d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  800aa4:	e9 7b ff ff ff       	jmp    800a24 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  800aa9:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  800ab0:	e9 6f ff ff ff       	jmp    800a24 <vprintfmt+0x53>
            goto process_precision;
  800ab5:	90                   	nop

        process_precision:
            if (width < 0)
  800ab6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800aba:	0f 89 64 ff ff ff    	jns    800a24 <vprintfmt+0x53>
                width = precision, precision = -1;
  800ac0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ac3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ac6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  800acd:	e9 52 ff ff ff       	jmp    800a24 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  800ad2:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  800ad5:	e9 4a ff ff ff       	jmp    800a24 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  800ada:	8b 45 14             	mov    0x14(%ebp),%eax
  800add:	8d 50 04             	lea    0x4(%eax),%edx
  800ae0:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae3:	8b 00                	mov    (%eax),%eax
  800ae5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aec:	89 04 24             	mov    %eax,(%esp)
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	ff d0                	call   *%eax
            break;
  800af4:	e9 a4 02 00 00       	jmp    800d9d <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  800af9:	8b 45 14             	mov    0x14(%ebp),%eax
  800afc:	8d 50 04             	lea    0x4(%eax),%edx
  800aff:	89 55 14             	mov    %edx,0x14(%ebp)
  800b02:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  800b04:	85 db                	test   %ebx,%ebx
  800b06:	79 02                	jns    800b0a <vprintfmt+0x139>
                err = -err;
  800b08:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800b0a:	83 fb 18             	cmp    $0x18,%ebx
  800b0d:	7f 0b                	jg     800b1a <vprintfmt+0x149>
  800b0f:	8b 34 9d a0 11 80 00 	mov    0x8011a0(,%ebx,4),%esi
  800b16:	85 f6                	test   %esi,%esi
  800b18:	75 23                	jne    800b3d <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  800b1a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800b1e:	c7 44 24 08 15 12 80 	movl   $0x801215,0x8(%esp)
  800b25:	00 
  800b26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b29:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b30:	89 04 24             	mov    %eax,(%esp)
  800b33:	e8 6a fe ff ff       	call   8009a2 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  800b38:	e9 60 02 00 00       	jmp    800d9d <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  800b3d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b41:	c7 44 24 08 1e 12 80 	movl   $0x80121e,0x8(%esp)
  800b48:	00 
  800b49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	89 04 24             	mov    %eax,(%esp)
  800b56:	e8 47 fe ff ff       	call   8009a2 <printfmt>
            break;
  800b5b:	e9 3d 02 00 00       	jmp    800d9d <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  800b60:	8b 45 14             	mov    0x14(%ebp),%eax
  800b63:	8d 50 04             	lea    0x4(%eax),%edx
  800b66:	89 55 14             	mov    %edx,0x14(%ebp)
  800b69:	8b 30                	mov    (%eax),%esi
  800b6b:	85 f6                	test   %esi,%esi
  800b6d:	75 05                	jne    800b74 <vprintfmt+0x1a3>
                p = "(null)";
  800b6f:	be 21 12 80 00       	mov    $0x801221,%esi
            }
            if (width > 0 && padc != '-') {
  800b74:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800b78:	7e 76                	jle    800bf0 <vprintfmt+0x21f>
  800b7a:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800b7e:	74 70                	je     800bf0 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800b80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b87:	89 34 24             	mov    %esi,(%esp)
  800b8a:	e8 f6 f7 ff ff       	call   800385 <strnlen>
  800b8f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800b92:	29 c2                	sub    %eax,%edx
  800b94:	89 d0                	mov    %edx,%eax
  800b96:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800b99:	eb 16                	jmp    800bb1 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  800b9b:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800b9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba2:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ba6:	89 04 24             	mov    %eax,(%esp)
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  800bae:	ff 4d e8             	decl   -0x18(%ebp)
  800bb1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800bb5:	7f e4                	jg     800b9b <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800bb7:	eb 37                	jmp    800bf0 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  800bb9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800bbd:	74 1f                	je     800bde <vprintfmt+0x20d>
  800bbf:	83 fb 1f             	cmp    $0x1f,%ebx
  800bc2:	7e 05                	jle    800bc9 <vprintfmt+0x1f8>
  800bc4:	83 fb 7e             	cmp    $0x7e,%ebx
  800bc7:	7e 15                	jle    800bde <vprintfmt+0x20d>
                    putch('?', putdat);
  800bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	ff d0                	call   *%eax
  800bdc:	eb 0f                	jmp    800bed <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  800bde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be5:	89 1c 24             	mov    %ebx,(%esp)
  800be8:	8b 45 08             	mov    0x8(%ebp),%eax
  800beb:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800bed:	ff 4d e8             	decl   -0x18(%ebp)
  800bf0:	89 f0                	mov    %esi,%eax
  800bf2:	8d 70 01             	lea    0x1(%eax),%esi
  800bf5:	0f b6 00             	movzbl (%eax),%eax
  800bf8:	0f be d8             	movsbl %al,%ebx
  800bfb:	85 db                	test   %ebx,%ebx
  800bfd:	74 27                	je     800c26 <vprintfmt+0x255>
  800bff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c03:	78 b4                	js     800bb9 <vprintfmt+0x1e8>
  800c05:	ff 4d e4             	decl   -0x1c(%ebp)
  800c08:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c0c:	79 ab                	jns    800bb9 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  800c0e:	eb 16                	jmp    800c26 <vprintfmt+0x255>
                putch(' ', putdat);
  800c10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c17:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  800c23:	ff 4d e8             	decl   -0x18(%ebp)
  800c26:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800c2a:	7f e4                	jg     800c10 <vprintfmt+0x23f>
            }
            break;
  800c2c:	e9 6c 01 00 00       	jmp    800d9d <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  800c31:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c38:	8d 45 14             	lea    0x14(%ebp),%eax
  800c3b:	89 04 24             	mov    %eax,(%esp)
  800c3e:	e8 18 fd ff ff       	call   80095b <getint>
  800c43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c46:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  800c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c4f:	85 d2                	test   %edx,%edx
  800c51:	79 26                	jns    800c79 <vprintfmt+0x2a8>
                putch('-', putdat);
  800c53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c5a:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c61:	8b 45 08             	mov    0x8(%ebp),%eax
  800c64:	ff d0                	call   *%eax
                num = -(long long)num;
  800c66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c69:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c6c:	f7 d8                	neg    %eax
  800c6e:	83 d2 00             	adc    $0x0,%edx
  800c71:	f7 da                	neg    %edx
  800c73:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c76:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  800c79:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800c80:	e9 a8 00 00 00       	jmp    800d2d <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  800c85:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8c:	8d 45 14             	lea    0x14(%ebp),%eax
  800c8f:	89 04 24             	mov    %eax,(%esp)
  800c92:	e8 75 fc ff ff       	call   80090c <getuint>
  800c97:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c9a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  800c9d:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800ca4:	e9 84 00 00 00       	jmp    800d2d <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  800ca9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb0:	8d 45 14             	lea    0x14(%ebp),%eax
  800cb3:	89 04 24             	mov    %eax,(%esp)
  800cb6:	e8 51 fc ff ff       	call   80090c <getuint>
  800cbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cbe:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  800cc1:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  800cc8:	eb 63                	jmp    800d2d <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  800cca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdb:	ff d0                	call   *%eax
            putch('x', putdat);
  800cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800cf0:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf3:	8d 50 04             	lea    0x4(%eax),%edx
  800cf6:	89 55 14             	mov    %edx,0x14(%ebp)
  800cf9:	8b 00                	mov    (%eax),%eax
  800cfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cfe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  800d05:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  800d0c:	eb 1f                	jmp    800d2d <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  800d0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d15:	8d 45 14             	lea    0x14(%ebp),%eax
  800d18:	89 04 24             	mov    %eax,(%esp)
  800d1b:	e8 ec fb ff ff       	call   80090c <getuint>
  800d20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d23:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  800d26:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  800d2d:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800d31:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d34:	89 54 24 18          	mov    %edx,0x18(%esp)
  800d38:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d3b:	89 54 24 14          	mov    %edx,0x14(%esp)
  800d3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d49:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d4d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	89 04 24             	mov    %eax,(%esp)
  800d5e:	e8 a4 fa ff ff       	call   800807 <printnum>
            break;
  800d63:	eb 38                	jmp    800d9d <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  800d65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d68:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d6c:	89 1c 24             	mov    %ebx,(%esp)
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	ff d0                	call   *%eax
            break;
  800d74:	eb 27                	jmp    800d9d <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  800d76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d7d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  800d89:	ff 4d 10             	decl   0x10(%ebp)
  800d8c:	eb 03                	jmp    800d91 <vprintfmt+0x3c0>
  800d8e:	ff 4d 10             	decl   0x10(%ebp)
  800d91:	8b 45 10             	mov    0x10(%ebp),%eax
  800d94:	48                   	dec    %eax
  800d95:	0f b6 00             	movzbl (%eax),%eax
  800d98:	3c 25                	cmp    $0x25,%al
  800d9a:	75 f2                	jne    800d8e <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  800d9c:	90                   	nop
    while (1) {
  800d9d:	e9 37 fc ff ff       	jmp    8009d9 <vprintfmt+0x8>
                return;
  800da2:	90                   	nop
        }
    }
}
  800da3:	83 c4 40             	add    $0x40,%esp
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  800dad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db0:	8b 40 08             	mov    0x8(%eax),%eax
  800db3:	8d 50 01             	lea    0x1(%eax),%edx
  800db6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db9:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  800dbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbf:	8b 10                	mov    (%eax),%edx
  800dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc4:	8b 40 04             	mov    0x4(%eax),%eax
  800dc7:	39 c2                	cmp    %eax,%edx
  800dc9:	73 12                	jae    800ddd <sprintputch+0x33>
        *b->buf ++ = ch;
  800dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dce:	8b 00                	mov    (%eax),%eax
  800dd0:	8d 48 01             	lea    0x1(%eax),%ecx
  800dd3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd6:	89 0a                	mov    %ecx,(%edx)
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	88 10                	mov    %dl,(%eax)
    }
}
  800ddd:	90                   	nop
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  800de6:	8d 45 14             	lea    0x14(%ebp),%eax
  800de9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  800dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800def:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800df3:	8b 45 10             	mov    0x10(%ebp),%eax
  800df6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	89 04 24             	mov    %eax,(%esp)
  800e07:	e8 08 00 00 00       	call   800e14 <vsnprintf>
  800e0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  800e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800e12:	c9                   	leave  
  800e13:	c3                   	ret    

00800e14 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e23:	8d 50 ff             	lea    -0x1(%eax),%edx
  800e26:	8b 45 08             	mov    0x8(%ebp),%eax
  800e29:	01 d0                	add    %edx,%eax
  800e2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  800e35:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800e39:	74 0a                	je     800e45 <vsnprintf+0x31>
  800e3b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e41:	39 c2                	cmp    %eax,%edx
  800e43:	76 07                	jbe    800e4c <vsnprintf+0x38>
        return -E_INVAL;
  800e45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e4a:	eb 2a                	jmp    800e76 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e4c:	8b 45 14             	mov    0x14(%ebp),%eax
  800e4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e53:	8b 45 10             	mov    0x10(%ebp),%eax
  800e56:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e5a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e61:	c7 04 24 aa 0d 80 00 	movl   $0x800daa,(%esp)
  800e68:	e8 64 fb ff ff       	call   8009d1 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800e6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e70:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  800e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800e76:	c9                   	leave  
  800e77:	c3                   	ret    

00800e78 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  800e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e81:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  800e87:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  800e8a:	b8 20 00 00 00       	mov    $0x20,%eax
  800e8f:	2b 45 0c             	sub    0xc(%ebp),%eax
  800e92:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800e95:	88 c1                	mov    %al,%cl
  800e97:	d3 ea                	shr    %cl,%edx
  800e99:	89 d0                	mov    %edx,%eax
}
  800e9b:	c9                   	leave  
  800e9c:	c3                   	ret    

00800e9d <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  800ea6:	a1 00 20 80 00       	mov    0x802000,%eax
  800eab:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800eb1:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  800eb7:	6b f0 05             	imul   $0x5,%eax,%esi
  800eba:	01 fe                	add    %edi,%esi
  800ebc:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
  800ec1:	f7 e7                	mul    %edi
  800ec3:	01 d6                	add    %edx,%esi
  800ec5:	89 f2                	mov    %esi,%edx
  800ec7:	83 c0 0b             	add    $0xb,%eax
  800eca:	83 d2 00             	adc    $0x0,%edx
  800ecd:	89 c7                	mov    %eax,%edi
  800ecf:	83 e7 ff             	and    $0xffffffff,%edi
  800ed2:	89 f9                	mov    %edi,%ecx
  800ed4:	0f b7 da             	movzwl %dx,%ebx
  800ed7:	89 0d 00 20 80 00    	mov    %ecx,0x802000
  800edd:	89 1d 04 20 80 00    	mov    %ebx,0x802004
    unsigned long long result = (next >> 12);
  800ee3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800ee9:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800eef:	89 d8                	mov    %ebx,%eax
  800ef1:	89 f2                	mov    %esi,%edx
  800ef3:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  800ef7:	c1 ea 0c             	shr    $0xc,%edx
  800efa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800efd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  800f00:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  800f07:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f0a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f0d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f10:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f13:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f16:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f19:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800f1d:	74 1c                	je     800f3b <rand+0x9e>
  800f1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f22:	ba 00 00 00 00       	mov    $0x0,%edx
  800f27:	f7 75 dc             	divl   -0x24(%ebp)
  800f2a:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800f2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f30:	ba 00 00 00 00       	mov    $0x0,%edx
  800f35:	f7 75 dc             	divl   -0x24(%ebp)
  800f38:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800f3b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f3e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800f41:	f7 75 dc             	divl   -0x24(%ebp)
  800f44:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f47:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800f4a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f4d:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f50:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f53:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800f56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  800f59:	83 c4 24             	add    $0x24,%esp
  800f5c:	5b                   	pop    %ebx
  800f5d:	5e                   	pop    %esi
  800f5e:	5f                   	pop    %edi
  800f5f:	5d                   	pop    %ebp
  800f60:	c3                   	ret    

00800f61 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
    next = seed;
  800f64:	8b 45 08             	mov    0x8(%ebp),%eax
  800f67:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6c:	a3 00 20 80 00       	mov    %eax,0x802000
  800f71:	89 15 04 20 80 00    	mov    %edx,0x802004
}
  800f77:	90                   	nop
  800f78:	5d                   	pop    %ebp
  800f79:	c3                   	ret    

00800f7a <main>:
#define ARRAYSIZE (1024*1024)

uint32_t bigarray[ARRAYSIZE];

int
main(void) {
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	83 e4 f0             	and    $0xfffffff0,%esp
  800f80:	83 ec 20             	sub    $0x20,%esp
    cprintf("Making sure bss works right...\n");
  800f83:	c7 04 24 80 13 80 00 	movl   $0x801380,(%esp)
  800f8a:	e8 41 f3 ff ff       	call   8002d0 <cprintf>
    int i;
    for (i = 0; i < ARRAYSIZE; i ++) {
  800f8f:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  800f96:	00 
  800f97:	eb 37                	jmp    800fd0 <main+0x56>
        if (bigarray[i] != 0) {
  800f99:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f9d:	8b 04 85 20 20 80 00 	mov    0x802020(,%eax,4),%eax
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	74 24                	je     800fcc <main+0x52>
            panic("bigarray[%d] isn't cleared!\n", i);
  800fa8:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800fac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fb0:	c7 44 24 08 a0 13 80 	movl   $0x8013a0,0x8(%esp)
  800fb7:	00 
  800fb8:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  800fbf:	00 
  800fc0:	c7 04 24 bd 13 80 00 	movl   $0x8013bd,(%esp)
  800fc7:	e8 54 f0 ff ff       	call   800020 <__panic>
    for (i = 0; i < ARRAYSIZE; i ++) {
  800fcc:	ff 44 24 1c          	incl   0x1c(%esp)
  800fd0:	81 7c 24 1c ff ff 0f 	cmpl   $0xfffff,0x1c(%esp)
  800fd7:	00 
  800fd8:	7e bf                	jle    800f99 <main+0x1f>
        }
    }
    for (i = 0; i < ARRAYSIZE; i ++) {
  800fda:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  800fe1:	00 
  800fe2:	eb 13                	jmp    800ff7 <main+0x7d>
        bigarray[i] = i;
  800fe4:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  800fe8:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800fec:	89 14 85 20 20 80 00 	mov    %edx,0x802020(,%eax,4)
    for (i = 0; i < ARRAYSIZE; i ++) {
  800ff3:	ff 44 24 1c          	incl   0x1c(%esp)
  800ff7:	81 7c 24 1c ff ff 0f 	cmpl   $0xfffff,0x1c(%esp)
  800ffe:	00 
  800fff:	7e e3                	jle    800fe4 <main+0x6a>
    }
    for (i = 0; i < ARRAYSIZE; i ++) {
  801001:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  801008:	00 
  801009:	eb 3b                	jmp    801046 <main+0xcc>
        if (bigarray[i] != i) {
  80100b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80100f:	8b 14 85 20 20 80 00 	mov    0x802020(,%eax,4),%edx
  801016:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80101a:	39 c2                	cmp    %eax,%edx
  80101c:	74 24                	je     801042 <main+0xc8>
            panic("bigarray[%d] didn't hold its value!\n", i);
  80101e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801022:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801026:	c7 44 24 08 cc 13 80 	movl   $0x8013cc,0x8(%esp)
  80102d:	00 
  80102e:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  801035:	00 
  801036:	c7 04 24 bd 13 80 00 	movl   $0x8013bd,(%esp)
  80103d:	e8 de ef ff ff       	call   800020 <__panic>
    for (i = 0; i < ARRAYSIZE; i ++) {
  801042:	ff 44 24 1c          	incl   0x1c(%esp)
  801046:	81 7c 24 1c ff ff 0f 	cmpl   $0xfffff,0x1c(%esp)
  80104d:	00 
  80104e:	7e bb                	jle    80100b <main+0x91>
        }
    }

    cprintf("Yes, good.  Now doing a wild write off the end...\n");
  801050:	c7 04 24 f4 13 80 00 	movl   $0x8013f4,(%esp)
  801057:	e8 74 f2 ff ff       	call   8002d0 <cprintf>
    cprintf("testbss may pass.\n");
  80105c:	c7 04 24 27 14 80 00 	movl   $0x801427,(%esp)
  801063:	e8 68 f2 ff ff       	call   8002d0 <cprintf>

    bigarray[ARRAYSIZE + 1024] = 0;
  801068:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  80106f:	00 00 00 
    asm volatile ("int $0x14");
  801072:	cd 14                	int    $0x14
    panic("FAIL: T.T\n");
  801074:	c7 44 24 08 3a 14 80 	movl   $0x80143a,0x8(%esp)
  80107b:	00 
  80107c:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  801083:	00 
  801084:	c7 04 24 bd 13 80 00 	movl   $0x8013bd,(%esp)
  80108b:	e8 90 ef ff ff       	call   800020 <__panic>
